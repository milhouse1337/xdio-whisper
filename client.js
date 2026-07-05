const { Worker, Queue, QueueEvents, QueueScheduler } = require('bullmq');
const { spawn } = require('child_process');
const axios = require('axios');

require('dotenv').config();

const conn = {
    connection: {
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT,
        password: process.env.REDIS_AUTH
    }
};

// Tracks the currently running job.sh child so a forced shutdown can kill it.
let currentChild = null;

const worker = new Worker('xdio', async job => {
    console.log(`# Job started: ${job.id}`, job.data);
    return new Promise((resolve, reject) => {

        // Spawn job.sh in its own process group (detached) so a Ctrl+C sent to
        // this worker's group does NOT kill the in-progress transcription.
        // That lets worker.close() wait for the job to finish gracefully.
        // (exec ignores `detached` for process-group purposes, so we use spawn;
        // the argument array also avoids shell interpretation of the hash.)
        let child = spawn('./job.sh', [job.data.hash], { detached: true });
        currentChild = child;

        child.stdout.setEncoding('utf8');
        child.stdout.on('data', function (data) {
            console.log(data);
        });

        child.stderr.setEncoding('utf8');
        child.stderr.on('data', function (data) {
            console.log(data);
            data = data.toString();

            const regex_progress = /whisper_print_progress_callback: progress =\s+(\d+)%/;
            const match_progress = data.match(regex_progress);

            if (match_progress) {
                const percentage = parseInt(match_progress[1], 10);
                job.updateProgress(percentage);
            }

        });

        child.on('error', function (error) {
            currentChild = null;
            console.error(`Execution error: ${error}`);
            reject(error);
        });

        child.on('close', function (code, signal) {
            currentChild = null;
            if (code === 0) {
                resolve({ 'status': 0 });
            } else {
                reject(new Error(`job.sh exited with code ${code}${signal ? ` (signal ${signal})` : ''}`));
            }
        });

    });
}, conn);

worker.on('completed', job => {
    console.log(`# Job completed: ${job.id}`);
});

worker.on('failed', (job, err) => {
    console.log(`# Job failed: ${job.id} with ${err.message}`);
});

worker.on('error', (err) => {
    console.log(`# Worker error: ${err.message}`);
})

let shuttingDown = false;

async function shutdown(signal) {
    if (shuttingDown) {
        // Second interrupt: the user is impatient — kill the running job's
        // whole process group and exit immediately.
        console.log(`** ${signal} again — forcing shutdown now.`);
        if (currentChild) {
            try { process.kill(-currentChild.pid, 'SIGKILL'); } catch (err) { /* already gone */ }
        }
        process.exit(1);
    }

    shuttingDown = true;
    console.log(`** Received ${signal}. Finishing the current job, then stopping. Press Ctrl+C again to force quit.`);
    await worker.close(); // stops fetching new jobs and waits for the active one to finish
    process.exit(0);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

console.log("Worker is running and waiting for jobs.");

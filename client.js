const { Worker, Queue, QueueEvents, QueueScheduler } = require('bullmq');
const { exec } = require('child_process');
const axios = require('axios');

require('dotenv').config();

const conn = {
    connection: {
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT,
        password: process.env.REDIS_AUTH
    }
};

const worker = new Worker('xdio', async job => {
    console.log(`# Job started: ${job.id}`, job.data);
    return new Promise((resolve, reject) => {

        // let time = 0;
        let child = exec('./job.sh ' + job.data.hash, (error, stdout, stderr) => {
            if (error) {
                console.error(`Execution error: ${error}`);
                reject(error);
            }
            resolve({ 'status': 0 });
        });

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

process.on('SIGINT', async () => {
    console.log('** Received SIGINT. The process will terminate (gracefully) after the current job.');
    await worker.close();
    process.exit(0);
});

console.log("Worker is running and waiting for jobs.");

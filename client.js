const { Worker, Queue, QueueEvents, QueueScheduler } = require('bullmq');
const { exec } = require('child_process');
// const axios = require('axios');

require('dotenv').config();

const conn = {
    connection: {
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT,
        password: process.env.REDIS_AUTH
    }
};

const worker = new Worker('xdio', async job => {
    console.log('# Job started: ', job.id, job.data);
    return new Promise((resolve, reject) => {
        exec('./job.sh ' + job.data.hash + ' &> xdio.log', (error, stdout, stderr) => {
            if (error) {
                console.error(`Execution error: ${error}`);
                reject(error);
            }
            // console.log(`stdout: ${stdout}`);
            // console.error(`stderr: ${stderr}`);
            resolve({ stdout, stderr });
        });
    });
}, conn);

worker.on('completed', job => {
    console.log(`# Job completed: ${job.id}`);
});

worker.on('failed', (job, err) => {
    console.log(`# Job failed: ${job.id} with ${err.message}`);
});

console.log("Worker is running and waiting for jobs.");

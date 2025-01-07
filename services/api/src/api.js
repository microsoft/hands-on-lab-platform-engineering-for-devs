const crypto = require('crypto');
const { setTimeout } = require('node:timers/promises');
const { app } = require('@azure/functions');

const RELEASE = +process.env.RELEASE || 1;

app.http('qna', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        const id = crypto.randomUUID();

        context.log(`Processing request ${id}`);
        const payload = await request.json();

        // Simple payload validation
        if (!payload.question) {
            throw new Error('Invalid payload: missing question');
        }

        // Release 2 introduces some errors
        if (RELEASE === 2) {
            // Generate some random errors for testing with a probability of 10%
            if (Math.random() < 0.1) {
                throw new Error('Random error');
            }
        }

        // Release 3 introduces some latency
        if (RELEASE === 3) {
            await setTimeout(2000); // wait 2 seconds
        }

        return {
            jsonBody: {
                id,
                question: payload.question,
                answer: '42',
                createdAt: new Date().toISOString(),
            },
            headers: {
                'X-Release': RELEASE,
            },
        };
    }
});

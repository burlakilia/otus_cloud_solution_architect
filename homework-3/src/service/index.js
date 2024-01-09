const Redis = require("ioredis");

const conn = new Redis({
    sentinels: [
        { host: process.env.REDIS_HOST, port: 26379 },
    ],
    name: process.env.REDIS_USER,
    password: process.env.REDIS_PWD
});

function get(key) {
    return new Promise((resolve, reject) => {
        conn.get(key, (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    });
}

function set(key, value) {
    return new Promise((resolve, reject) => {
        conn.set(key, value, (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    })
}

module.exports.handler = async function (event, context) {
    const value = await get('test');

    if (!value) {
        await set('test', 'ITS setted at' + new Date())
    }

    const value2 = await get('test');

    return {
        statusCode: 200,
        headers: {"content-type": "application/json"},
        body: JSON.stringify({
            hello: value2,
        })
    };
};
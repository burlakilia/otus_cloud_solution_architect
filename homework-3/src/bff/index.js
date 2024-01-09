module.exports.handler = async function (e, ctx) {
    const result = await fetch(`https://functions.yandexcloud.net/${process.env.SERVICE_NAME}`, {
        headers: {
            'authorization': `Bearer ${ctx.token.access_token}`
        }
    }).then(res => res.json());

    const resp = {
        ...result,
        url: `https://functions.yandexcloud.net/${process.env.SERVICE_NAME}`,
    }

    return {
        statusCode: 200,
        body: JSON.stringify(resp),
    };
};
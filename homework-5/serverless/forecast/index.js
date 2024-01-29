module.exports.handler = async function (e, ctx) {
    const { API_TOKEN } = process.env;
    const { lat, lon, region } = e.queryStringParameters;
    let url = `https://api.weather.yandex.ru/v2/forecast?${lat}&lon=${lon}`;

    if (region === 'RU') {
        url += '&lang=ru_RU';
    }


    const result = await fetch(url, {
        headers: {
            'X-Yandex-API-Key': API_TOKEN,
        }
    }).then(res => res.json())

    return {
        statusCode: 200,
        body: result,
    };
};
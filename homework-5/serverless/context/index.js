const pg = require('pg');

const IP_API_HOST = 'http://ip-api.com/json';

async function addStat(context, data) {
    const {
        PROXY_MDB_ID,
        PROXY_MDB_ENDPOINT,
        PG_USER,
    } = process.env;

    const proxyId = PROXY_MDB_ID;
    const proxyEndpoint = PROXY_MDB_ENDPOINT;
    const user = PG_USER;
    const connectionString = "postgres://" + user + ":" + context.token.access_token + "@" + proxyEndpoint + "/" + proxyId + "?ssl=true";

    let client = new pg.Client(connectionString);
    client.connect();

    let result = await client.query(`
        INSERT INTO stats (region, city, country, lat, lon) 
        VALUES ('${data.region}', '${data.city}', '${data.countryCode}', '${data.lat}', '${data.lon}');
    `);
    return result;
}

module.exports.handler = async function (e, ctx) {
    const realIp = e.headers ? e.headers['X-Real-Remote-Address'] : undefined;

    if (!realIp) {
        throw 'Invalid IP Address';
    }

    const geoip = await fetch(`${IP_API_HOST}/${realIp.replace(/:.*/, '')}`).then(res => res.json());
    await addStat(ctx, geoip);

    const whether = await fetch(`https://functions.yandexcloud.net/${process.env.FORECAST_FN}?lon=${geoip.lon}&lat=${geoip.lat}&region=${geoip.countryCode}`, {
        headers: {
            'authorization': `Bearer ${ctx.token.access_token}`
        },
    }).then(res => res.json())

    return {
        statusCode: 200,
        body: whether,
    };
};
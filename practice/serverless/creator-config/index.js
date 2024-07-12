const EasyYandexS3 = require('easy-yandex-s3').default;
const fs = require('fs');

module.exports.handler = async function (e, ctx) {
    const {
        S3_ACCESS_KEY_ID,
        S3_SECRET_KEY,
        BUCKET,
        REGISTRY_ID
    } = process.env;

    const str = e.isBase64Encoded ? Buffer.from(e.body, 'base64').toString() : e.body;

    const s3 = new EasyYandexS3({
        auth: {
            accessKeyId: S3_ACCESS_KEY_ID,
            secretAccessKey: S3_SECRET_KEY,
        },
        Bucket: BUCKET,
        debug: true,
    });

    const [APP_NAME, APP_VERSION] = str.split(',');

    const file = fs.readFileSync('./rs.tpl.yml').toString();

    file
        .replace(/\{APP_NAME}/g, APP_NAME)
        .replace(/\{APP_VERSION}/g, APP_VERSION)
        .replace(/\{REGISTRY_ID}/g, REGISTRY_ID)

    console.log(file)

    const upload = await s3.Upload(
        {
            buffer: Buffer.from(file, 'utf-8'),
            name: `${APP_NAME}.yaml`
        },
        '/kubectl/'
    );

    return {
        statusCode: 200,
        body: {upload},
    };
}
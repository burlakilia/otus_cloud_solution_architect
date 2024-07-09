const jwt = require('jsonwebtoken');

/**
 * {
 *     "body": "{\"login\": \"test\",\"pwd\":\"test\"}"
 * }
 */

module.exports.handler = async function (e, ctx) {
    const str = e.isBase64Encoded ? Buffer.from(e.body, 'base64').toString() : e.body;
    const body = JSON.parse(str);
    const {
        USER_LOGIN,
        USER_PWD,
        GITLAB_HOST,
        GITLAB_TOKEN,
    } = process.env;

    if (body.login !== USER_LOGIN || body.pwd !== USER_PWD) {
        return {statusCode: 401}
    }

    const token = jwt.sign({ gitlabToken: GITLAB_TOKEN, gitlabHost: GITLAB_HOST }, process.env.JWT_PRIVATE_KEY);

    return {
        statusCode: 200,
        body: {
            token,
        },
    };
}
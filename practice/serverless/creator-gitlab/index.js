const jwt = require('jsonwebtoken');

/**
 * {
 *     "body": "{\"login\": \"test\",\"pwd\":\"test\"}"
 * }
 */

module.exports.handler = async function (e, ctx) {
    const str = e.isBase64Encoded ? Buffer.from(e.body, 'base64').toString() : e.body;
    const {token, appName, appDesc} = JSON.parse(str);
    const {
        JWT_PRIVATE_KEY,
        REGISTRY_ID,
        CI_CD_TOKEN,
    } = process.env;

    const data = jwt.verify(token, JWT_PRIVATE_KEY);


    const project = await fetch(`${data.gitlabHost}/api/v4/projects`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            name: appName,
            description: appDesc,
            path: appName,
            initialize_with_readme: true,
        })
    }).then(res => res.json())

    if (!project.id) {
        return {
            statusCode: 400,
            body: project,
        }
    }

    const varToken = await fetch(`${data.gitlabHost}/api/v4/projects/${project.id}/variables`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            key: 'CLOUD_IAM_TOKEN',
            value: CI_CD_TOKEN
        }),
    }).then(res => res.json());

    const varRegistryId = await fetch(`${data.gitlabHost}/api/v4/projects/${project.id}/variables`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            key: 'CLOUD_REGISTRY_ID',
            value: REGISTRY_ID
        }),
    }).then(res => res.json());

    return {
        statusCode: 200,
        body: {
            project,
            varToken,
            varRegistryId,
        },
    };
}
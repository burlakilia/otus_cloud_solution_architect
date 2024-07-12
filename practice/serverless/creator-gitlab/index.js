const jwt = require('jsonwebtoken');
const fs = require('fs');

function addFile(file, name, data, project) {
    return fetch(`${data.gitlabHost}/api/v4/projects/${project.id}/repository/files/${name}`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            branch: 'main',
            content: fs.readFileSync('./' + file).toString(),
            commit_message: 'init add file: ' + name
        }),
    }).then(res => res.json());

}

module.exports.handler = async function (e, ctx) {
    const str = e.isBase64Encoded ? Buffer.from(e.body, 'base64').toString() : e.body;
    const {token, appName, appDesc} = JSON.parse(str);
    const {
        JWT_PRIVATE_KEY,
        REGISTRY_ID,
        CI_CD_TOKEN,
        API_TOKEN,
        UPDATER_ID,
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

    const varName = await fetch(`${data.gitlabHost}/api/v4/projects/${project.id}/variables`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            key: 'APP_NAME',
            value: appName
        }),
    }).then(res => res.json());

    const varApiToken = await fetch(`${data.gitlabHost}/api/v4/projects/${project.id}/variables`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            key: 'API_HEADERS',
            value: `Authorization: Api-Key ${API_TOKEN}`
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

    const varUpdaterId = await fetch(`${data.gitlabHost}/api/v4/projects/${project.id}/variables`, {
        method: 'POST',
        headers: {
            'PRIVATE-TOKEN': data.gitlabToken,
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            key: 'UPDATER_ID',
            value: UPDATER_ID
        }),
    }).then(res => res.json());

    const file2 = await addFile('Dockerfile', 'Dockerfile', data, project);
    const file3 = await addFile('server.js', 'index.js', data, project);
    const file1 = await addFile('gitlab-ci.yml', '.gitlab-ci.yml', data, project);

    return {
        statusCode: 200,
        body: {
            varName,
            project,
            varToken,
            varRegistryId,
            varApiToken,
            varUpdaterId,
            filesResult: [file1, file2, file3],
        },
    };
}
const fetch = require('node-fetch');
const fs = require('fs');
const texts = require('./texts');

async function run() {
    const response = await fetch('https://vkcloud.kz/configuration/configuration.json');
    const body = await response.json();

    const regions = [];
    const selectedRegions = []

    for (const item of body.regions) {

        if (selectedRegions.includes(item.regionName)) {
            continue;
        }
        selectedRegions.push(item.regionName);
        regions.push(item);
    }

    const regionsForReport = regions.map(item => ({
        name: item.localizedRegionName.ru,
        domain: item.publicDomain,
        zones: item.availabilityZones
    }));


    const report = `
        # Отчет об облачном провайдере “VK Cloud”
        
        Данный документ содержит отчет, о возможностях облачного провайдера "VK Cloud"

        ## Генерация отчета
        Для перегенрации отчета, нужно выполнить комманду **npm run report**

        ## Регионы 
        | Регион | Домен | Доступные зоны |
        |---| --- | --- |
        ${regionsForReport.map(item => `
        | ${item.name} | [${item.domain}](${item.domain}) | ${item.zones.map(zone => zone.zoneName).join(' ')} |
        `).join('')}
    
        ## Зоны доступности
        В каждой зоне доступности находится один или несколько центров обработки данных (ЦОДов), где физически размещены объекты облачной инфраструктуры. В VK Cloud зона доступности соответствует отдельному ЦОД уровня Tier III. VK Cloud предоставляет зоны доступности:
        - GZ1: включает в себя дата-центр Goznak;
        Адрес дата-центра: г. Москва, проспект Мира, 105, стр. 6.
        - MS1: включает в себя дата-центр DataLine NORD4;
        Адрес дата-центра: г. Москва, Коровинское ш., 41.
        В зоне доступности MS1 инфраструктура VK Cloud защищена в соответствии с ФЗ РФ «О персональных данных» №152-ФЗ.
        - QAZ: включает в себя дата-центр QazCloud.
        Адрес дата-центра: Республика Казахстан, Акмолинская область, г. Косшы, ул. Республики 1.
    
        ## Реализуемые вендором требования отказоустойчивости
        
        Каждый дата-центр оснащен независимыми системами электропитания и охлаждения.
       
        Зоны доступности *GZ1* и *MS1* соединены с помощью резервированной выделенной оптоволоконной сети высокой пропускной способности и с низким уровнем задержек для высокой скорости передачи данных между зонами.

        ## Спиоск доступных хранилищь 
        ${getCommonDatastores(regions)}
    
        ## Общие сервисы
        ${getServices(body)}
    `

    fs.writeFileSync('../README.md', report.replace(/^\s+/gm, ''));
}

function intersection(a, b) {
    const result = new Set();
    for (const key of b) {
        if (a.has(key)) result.add(key)
    }
    return result;
}

function getCommonDatastores(regions) {
    let result = null;

    for (const firstRegion of regions) {
        for (const secondRegion of regions) {
            if (firstRegion === secondRegion) continue;

            const first = new Set(firstRegion.datastores.map(item => item.name));
            const second = new Set(secondRegion.datastores.map(item => item.name));

            if (!result) result = intersection(first, second);
            else result = intersection(result, intersection(first, second));
        }
    }

    return Array.from(result).map(key => `- ${texts.datastores[key] ?? key}`).join('\n');
}

function getServices(body) {
    const services = new Set();

    for (const key of Object.keys(body.themeToConfig)) {
        if (body.themeToConfig[key].availableServices) {
            body.themeToConfig[key].availableServices.map(item => services.add(item))
        }
    }

    return Array.from(services).map(key => `- ${texts.services[key] ?? key}`).join('\n');
}

run().catch(err => console.error('report error', err))


# Практическая работа

Дизайн проект: https://app.diagrams.net/?libs=c4#D%D0%9F%D1%80%D0%BE%D0%B5%D0%BA%D1%82%D0%BD%D0%B0%D1%8F%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0.drawio#%7B%22pageId%22%3A%22l0RS8J0323dWHU8eCK-F%22%7D

## Настройка

1) Установить зависимости `npm i`
2) Настроить конфиг 
   - скопировать файл `config.defailt.yaml`
   - заполнить параметры вашего облака
3) Запустить сборку статика `npm run build`
4) Добавить имя созданого **js** файла в `config.yaml`
5) Запустить деплой `terraform apply`
6) Настроить **s3fs** для работы с файлами конфигурациями https://yandex.cloud/ru/docs/storage/tools/s3fs

# Домашняя работа 3

Создадим 3-х уровневую инфраструктуру для облачного решения.
Каждый слой состоит из своей подсети:

 - Frontend (public)
 - Backend/App (private)
 - Db (private)

В каждой подсети развернуть ВМ и в них поднять http сервер для демонстрации (frontend - 80 порт, backend - 3000, database - 6000)
При желании в подсети DB можно развернуть любую БД, но слушать она должна порт 6000
Настроим сетевое взаимодействие таким образом что:
внешний трафик мог приходить только в сеть frontend (public)
backend был доступен только из сети frontend и имел возможность обновляться через nat gw
DB был доступен только из сети backend
Проверьте корректность хождения трафика и пришлите скриншоты

## Публикация

```shell
npm run publish
```
yc managed-postgresql cluster restore \
   --backup-id=<идентификатор_резервной_копии> \
   --time=<время> \
   --name=<имя_кластера> \
   --environment=<окружение> \
   --network-name=<имя_сети> \
   --host zone-id=<зона_доступности>,`
         `subnet-name=<имя_подсети>,`
         `assign-public-ip=<публичный_доступ_к_хосту> \
   --resource-preset=<класс_хоста> \
   --disk-size=<размер_хранилища_ГБ> \
   --disk-type=<тип_диска>
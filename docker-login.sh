docker login \
  --username iam \
  --password $(yc iam create-token) \
  cr.yandex
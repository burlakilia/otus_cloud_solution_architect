#!/bin/bash

yc iam key create \
  --service-account-id ajeu2flea71gaajk8db1 \
  --folder-name otus-course \
  --output sa-secret.json
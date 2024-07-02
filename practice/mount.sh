#!/bin/bash

s3fs burlakilia-practice-config ./s3 -o passwd_file=~/.passwd-s3fs \
  -o url=https://storage.yandexcloud.net -o use_path_request_style

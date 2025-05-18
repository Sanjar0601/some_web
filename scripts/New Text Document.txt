#!/bin/bash

cd /home/ubuntu/some_web

# Устанавливаем зависимости
npm install

# Останавливаем старый процесс (если есть)
pkill node || true

# Запускаем заново
nohup node app.js > output.log 2>&1 &

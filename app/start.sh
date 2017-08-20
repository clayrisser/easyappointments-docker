#!/bin/bash

cp /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone
python /app/setup.py /app/www/config.php

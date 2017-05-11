#!/bin/bash

python /app/generate_config.py /app/www/config.php > /app/www/new_config.php
mv /app/www/new_config.php /app/www/config.php

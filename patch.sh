#!/bin/bash

sed -i "s/\$config\['sess_save_path']          = NULL;/\$config\['sess_save_path']          = sys_get_temp_dir();/g" /app/www/application/config/config.php

# Easy!Appointments Docker

A docker image for Easy!Appointments

Please &#9733; this repo if you found it useful &#9733; &#9733; &#9733;


## Features
<!------------------------------------------------------->

* Change settings with environment variables


## Installation
<!------------------------------------------------------->

```sh
docker run --name some-mariadb -e MYSQL_ROOT_PASSWORD=hellodocker -e MYSQL_DATABASE=easyappointments mariadb:latest
docker run --name some-easyappointments -d --link some-mariadb:db -p 8888:8888 jamrizzi/easyappointments:latest
```

## Usage
<!------------------------------------------------------->

| Environment Variable | Deafult Value         |
| -------------------- | --------------------- |
| BASE_URL             | http://localhost:8888 |
| LANGUAGE             | english               |
| DEBUG                | false                 |
| DB_HOST              | db                    |
| DB_NAME              | easyappointments      |
| DB_USERNAME          | root                  |
| DB_PASSWORD          | hellodocker           |
| GOOGLE_SYNC_FEATURE  | false                 |
| GOOGLE_PRODUCT_NAME  | ""                    |
| GOOGLE_CLIENT_ID     | ""                    |
| GOOGLE_CLIENT_SECRET | ""                    |
| GOOGLE_API_KEY       | ""                    |


## Dependencies
<!------------------------------------------------------->

* [Docker](https://www.docker.com/)


## Support
<!------------------------------------------------------->

Submit an [issue](https://github.com/jamrizzi/readme/issues/new)


## Buy Me Coffee
<!------------------------------------------------------->

A ridiculous amount of coffee was consumed in the process of building this project.

[Add some fuel](https://jamrizzi.com/#!/buy-me-coffee) if you'd like to keep me going!


## Contributing
<!------------------------------------------------------->

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D


## License
<!------------------------------------------------------->

[MIT License](https://github.com/jamrizzi/easyappointments-docker/blob/master/LICENSE)

[Jam Risser](https://jamrizzi.com) &copy; 2017


## Credits
<!------------------------------------------------------->

* [Jam Risser](https://jamrizzi.com) - Author


## Changelog
<!------------------------------------------------------->

0.0.1 (2017-05-11)
* Initial release

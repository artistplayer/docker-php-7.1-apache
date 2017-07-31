# docker-php-7.1-apache
Container for php 7.1 for use for lamp web apps

## Example for preparing a LAMP project with docker-compose

`docker-compose-sample.yml`

```
php:
  container_name: limogin/php-7-1-apache
  # build: .
  restart: always
  ports:
    - "8080:80"
  volumes:
    - "./app:/var/www/html/:rw"
    - "./backup:/backup/:rw"
  links:
    - mysql
  environment:
    SITE:  mydomain.com
    SITE1: mydomain.com
    SITE2: myanotherdomain.com

mysql:
  container_name: mysql-container
  image: mysql:latest
  restart: always
  volumes:
    - "./data:/var/lib/mysql"
    - "./mysql/mysql.conf.d:/etc/mysql/mysql.conf.d"
  environment:
    MYSQL_ROOT_PASSWORD: [root-password]
    MYSQL_DATABASE: [database-name]
    MYSQL_USER: [database-user-name]
    MYSQL_PASSWORD: [database-password]
```

### The folders where the applications would be found

````
./app/mydomain.com/www/
./app/myanotherdomain.com/www/
````

### It should be enough

`sudo docker-compose up -d`

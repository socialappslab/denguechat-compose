# denguechat-compose
Docker compose for [DengueChat](https://github.com/socialappslab/denguetorpedo), meant for developers and system administrators whow whish to install and run their local instances of DengueChat, either for development or for local use. 

## How to run: 

1. Clone DengueChat's repository from [GitHub](https://github.com/socialappslab/denguetorpedo). Step inside the folder where the code is cloned. 
```
$ git clone https://github.com/socialappslab/denguetorpedo.git
$ cd denguetorpedo
$ git checkout develop
```

2. Create a folder named `log` where the code is cloned, to avoid errors when the systems tries to create the log file:

```
$ mkdir log
$ cd .. 
```

3. Clone this repository and step inside the folder
```
$ git clone https://github.com/socialappslab/denguechat-compose.git
$ cd denguechat-compose
```

4. If you would like to run this on a local machine, for development purposes, make sure you first checkout the `localdev` branch: 
```
$ git checkout localdev
```

4. Set the path where DengueChat was cloned in the `docker-compose.yml` by replacing the text `<local_folder_of_cloned_denguetorpedo_git_project>` with the right path. For a production environment, you can use something as follows: 
```yaml
  volumes:
    - /home/appcivist/production/denguetorpedo:/home/dengue/denguetorpedo
```

5. Set the path for the redis volume data in the `docker-compose.yml` by replacing the text `<local_folder_for_redis>` with the right path. For production environment, we use something as follows: 
```yaml
  volumes:
    - /home/appcivist/production/denguechat-compose/redis/redisVolume:/bitnami
```
 
6. If you are running with the `localdev` branch, you should also add the IP address of PostgreSQL server. If you are running postgres locally, that would be your docker host (i.e., your local development machine or server IP). For this to work, the postgres server will have to be properly configured, see the section `Database` below. 
Add the following, if not there:

```yaml
extra_hosts:
    postgreshost: 0.0.0.0 
```
- Replace `0.0.0.0` by the right IP of your database
	
	

7. Create a copy of the file `.env.sample`
```
$ cp .env.sample .env
```
8. In the new `.env` file, edit the variable `DATABASE_URL` to include the right database user, password and name: 
    - Replace `postgres:postgres` by the right `username:password` of your database
    - Replace `ddujs2u6bpdf88` with the right name of your database. 


9. In the new `.env` file, edit `REDIS_PASSWORD` with the right pass.

10. Build and run REDIS: 
```
$ docker-compose build redis 
```
and then 
```
$docker-compose up -d redis
```
11. On the file  ``denguetorpedo`` on the Dockerfile add the followin if not there
``RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list``

12. Build and run denguetorpedo 
```
$ docker-compose build denguetorpedo  
```
and then 
```
$docker-compose up -d denguetorpedo 
```
13. Run the following ``docker-compose logs -f --tail=100 denguetorpedo``

14. If creating a new REDIS container, in the new `.env` file, edit `REDISTOGO_URL` and change the `<ingresar_ip_asignada_a_denguetorpedo-redis>` to reference the IP address of the redis container. You can visualize this only after creating the REDIS container, using the command: 
```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' denguetorpedo-redis
```

15. Run `docker-compose build && docker-compose up -d`

16. Access DengueChat UI at `http://localhost:5000`

## Useful Notes: 
### Docker commands: 
1. View denguetorpedo container logs: `docker logs denguetorpedo`
2. View redis containerlogs: `docker logs denguetorpedo-redis`
3. Accessing the container: `docker exec -t -i denguetorpedo /bin/bash` 
4. View sidekiq logs: access the container (3) en run `tail -f -n1 home/dengue/denguetorpedo/log/sidekiq.log`

### Install rbenv and setup host Ruby environment:
For local development, you can take a look at [this article](https://github.com/rbenv/rbenv#homebrew-on-macos). You can also check out this [other article to learn more](https://thoughtbot.com/blog/using-rbenv-to-manage-rubies-and-gems)

### Set Local Ruby Version
The version that works best for the current codebase is: `rbenv local 2.3.0`


### Fix for Puma Gem
Puma's GEM v2.11.2 gives sometimes an installation error, which can be fixed doing as follow in the host machine and the container: 
1. Install openssl: `brew install openssl`
2. Install puma using ssl: `gem install puma -v '2.11.2' --source 'http://rubygems.org/' -- --with-cppflags=-I/usr/local/opt/openssl/include`

**Note:** the line above is also part of the Dockerfile now, but just in case you can install it in the host.  

### Database

Build a PostgreSQL image from Dockerfile using the docker build command.

`sudo docker build -t postgres_db:9.3 `

Use below command to create a user defined network with bridge driver.

`sudo docker network create --driver bridge postgres-network`

 and then 

`sudo docker run --name postgresondocker --network postgres-network -d postgres_db:9.3`

Connect to the Postgres container

`docker run -it --rm --network postgres-network postgres_db:9.3 psql -h postgres_db-U cdparra --password`



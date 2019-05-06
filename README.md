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
 
6. If you are running with the `localdev` branch, you should also replace the variable `<server_ip>` with the IP address of PostgreSQL server. If you are running postgres locally, that would be your docker host (i.e., your local development machine or server IP). For this to work, the postgres server will have to be properly configured, see the section `Database` below.  
```yaml
extra_hosts:
    postgreshost: 0.0.0.0 # use the right IP here. 
```

7. Create a copy of the file `.env.sample`
```
$ cp .env.sample .env
```
8. In the new `.env` file, edit the variable `DATABASE_URL` to include the right database user, password and name: 
    - Replace `postgres:postgres` by the right `username:password` of your database
    - Replace `<ingresar_nombre_base_datos>` with the right database name. 
Where it follows this formatting
```
DATABASE_URL=protocol://username:password@host:port/database
```

docker-compose build && docker-compose up -d

9. In the new `.env` file, edit `REDIS_PASSWORD` with the right pass and add `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` with the right key. 


10. Build and run REDIS: 
```
$ docker-compose build redis && docker-compose up -d redis
```
	- If you have an failure when the Dockerfile tries to run the sudo apt-get update, see the section `DOCKERFILE` below. 

11. If creating a new REDIS container, in the new `.env` file, edit `REDISTOGO_URL` and change the `<ingresar_ip_asignada_a_denguetorpedo-redis>` to reference the IP address of the redis container. You can visualize this only after creating the REDIS container, using the command: 
```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' denguetorpedo-redis
```

12. Run `docker-compose build && docker-compose up -d`
13. Access DengueChat UI at `http://localhost:3000`

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

### DOCKERFILE
Modify the file `denguechat-compose/denguetorpedo/Dockerfile` before running any apt commands, add the following line:
```
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
```

### Database
#### Enable external connections: 
1. Modify the `postgresql.conf` file, typically located at `/usr/local/var/postgres/postgresql.conf`, and add the following, if not there: `listen_addresses='*'`
2. Modify the `pg_hba.conf` file, typically located at `/usr/local/var/postgres/pg_hba.conf`, and add the following: 
```
host   all  all    0.0.0.0/0  trust
local  all  postgres          trust
```

#### Populate database
1. If you have a backup, you can recover data as follows: 
` psql denguetorpedo < denguetorpedo.sql`
    - If you have an error with the role 'XXXX'. You need to create a role with the name 'XXXX' or comment the line where the role 'XXXX' appears in the sql file.
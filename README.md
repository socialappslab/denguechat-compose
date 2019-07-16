# denguechat-compose
Docker compose files for the deployment of the multi-container production and development environments of [DengueChat](https://github.com/socialappslab/denguetorpedo). This tool is for DengueChat Developers and System Administrators who whish to install and run their local instances of DengueChat. 

Before you start, you will need to have the following installed in your machine:
1. PostgreSQL
2. Docker
3. Docker compose
4. Git
5. AWS account credentials (for testing or deployment in production mode) 


## How to run: 

1. **Get the code for DengueChat:** get a copy of [DengueChat's code from GitHub](https://github.com/socialappslab/denguetorpedo) and step inside the directory where the code is cloned. We will refer to this directory as the **code home** from here on. Checkout the `develop` branch and branch out of it if you want to contribute to development.  
```sh
git clone https://github.com/socialappslab/denguetorpedo.git
cd denguetorpedo
# For development or testing
git checkout develop
```

2. Create a directory named `log` inside the Code Home. This is to avoid errors when the systems tries to create the log file:
```sh
mkdir log
cd .. 
```

3. **Get the docker compose files:** get [DengueChat's docker compose from this repository](https://github.com/socialappslab/denguechat-compose) and step inside this directory to build and run the containers. We will refer to this directory as the **Docker Compose Home** from here on.
```sh
git clone https://github.com/socialappslab/denguechat-compose.git
cd denguechat-compose
```

4. **[IMPORTANT FOR DEVELOPERS]:** if you would like to run this on a local machine, for development purposes, make sure you checkout the `localdev` branch. Is this is for a testing of production environment, you can work on the `develop` or `master` branch: 
```sh
git checkout localdev
```

5. **Configure the docker-compose.yml (1):** in the `docker-compose.yml` file, replace the text variable `<local_folder_of_cloned_denguetorpedo_git_project>` with the path to the **Code Home** in the **`host`**. For example, suppose your Code Home is `/home/appcivist/production/denguetorpedo`, you volume should be configured as follows: 
```yaml
  volumes:
    - /home/appcivist/production/denguetorpedo:/home/dengue/denguetorpedo
```

5.  **Configure the docker-compose.yml (2):** in the `docker-compose.yml` file, replace the variable `<local_folder_for_redis>` with the path where you want to store redis data and configuration in the **`host`**. For example, suppose we created `/opt/redis` in the **`host`** and want to use it to share with the redis container, the line should become the following: 
```yaml
  volumes:
    - /home/appcivist/production/denguechat-compose/redis/redisVolume:/bitnami
```
 
6. If you are running with the `localdev` branch, you should also replace the variable `<server_ip>` with `${HOST_IP}`. Later you will have to configure that env variable to point to the IP address of the PostgreSQL server. If you are running postgres locally, that would be your docker host (i.e., your local development machine or server IP). For this to work, the postgres server will have to be properly configured, see the section `Database` below.  
```yaml
extra_hosts:
    postgreshost: ${HOST_IP}
```
 
Execute the following command
```
 - /home/appcivist/production/denguetorpedo:/home/dengue/denguetorpedo$ip=$(ip -f inet -o addr show enp0s8|cut -d\  -f 7 | cut -d/ -f 1)
 - /home/appcivist/production/denguetorpedo:/home/dengue/denguetorped$export HOST_IP=$ip
 ```

7. **Prepare your environment variables (1):** create a copy of the file `.env.sample` and name it `.env` 
```sh
cp .env.sample .env
```

8. **Prepare your environment variables (2):** in the new `.env` file, edit the `DATABASE_URL` variable so that it includes the correct database `user`, `password` and `name` as you have them configured on your local **host** machine PostgreSQL installation:  
    - Replace `postgres:postgres` with the `username:password` of your **host** database:
    - Replace `<ingresar_nombre_base_datos>` with the right database name. 
    - The formatting of this variable is shown below: 

```
DATABASE_URL=protocol://username:password@host:port/database
```

9. **Prepare your environment variables (3):** in the new `.env` file, edit the `REDIS_PASSWORD` variable with the password you would like to configure. If you have an AWS account, use your credentials to configure the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. 

10. **Build and run REDIS:** 
```sh
docker-compose build redis && docker-compose up -d redis
```

11. If creating a new REDIS container, in the new `.env` file, edit `REDISTOGO_URL` and change the `<ingresar_ip_asignada_a_denguetorpedo-redis>` to reference the IP address of the redis container. You can visualize this only after creating the REDIS container, using the command: 
```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' denguetorpedo-redis
```

**Note:** if the command above returns nothing, it means you are using a host network and therefore the IP to use is the same as that of the **host**.  

12. **Build and run the container of DengueChat:** 
```sh
docker-compose build && docker-compose up -d
```
**Notes:** 
   - Remember that you can run `docker-compose up` without the -d if you want to see the output of this process in foreground. If you run it with the -d flag, you can use `docker-compose logs` command to explore the logging output in search for potential issues or problems. 

13. If all went well, you should now be able to access DengueChat's User Interface from your browser at `http://localhost:5000`. You can set up a user with admin rights for local testing by editing the table `admin_users` and changing the encrypted passwords or adding a record. Passwords are encrypted with `bcrypt-ruby` for reference.  

## Other Notes: 
### Docker commands: 
1. View denguetorpedo container logs: `docker logs -f denguetorpedo`
2. View redis container logs: `docker logs -f denguetorpedo-redis`
3. Accessing the denguetorpedo container: `docker exec -t -i denguetorpedo /bin/bash` 
4. Accessing the redis container: use the same command only changing the name of the container. 
5. View sidekiq logs: access the container (3) en run `tail -f -n1 home/dengue/denguetorpedo/log/sidekiq.log`

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
The file `denguechat-compose/denguetorpedo/Dockerfile` now contains the following command before running apt commands:
```
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
```


### Database
#### Enable external connections: 
1. Modify the `postgresql.conf` file, typically located at `/usr/local/var/postgres/postgresql.conf`, and add the following, if not there: `listen_addresses='*'`
2. Modify the `pg_hba.conf` file, typically located at `/usr/local/var/postgres/pg_hba.conf`, and add the following: 
```
host   all  all    0.0.0.0/0  md5
local  all  postgres          md5
```

#### Populate database
1. If you have a backup, you can recover data as follows: 
` psql denguetorpedo < denguetorpedo.sql`
    - If you have an error with the role 'XXXX'. You need to create a role with the name 'XXXX' or comment the line where the role 'XXXX' appears in the sql file.
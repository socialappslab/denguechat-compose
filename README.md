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

2. **Prepare a log directory:** create a directory named `log` inside the Code Home. This is to avoid errors when the system tries to create the log file:
```sh
mkdir log
cd .. 
```

3. **Get the docker compose files:** get [DengueChat's docker compose from this repository](https://github.com/socialappslab/denguechat-compose) and step inside this directory to build and run the containers. We will refer to this directory as the **Docker Compose Home** from here on.
```sh
git clone https://github.com/socialappslab/denguechat-compose.git
cd denguechat-compose
```

4. **[IMPORTANT FOR DEVELOPERS]:** create your docker compose file by renaming the proper base `.yml` file. 


If you would like to run this on a local machine, for development purposes, use the `docker-compose.localdev.yml` as the base file

```sh
cp docker-compose.localdev.yml docker-compose.yml
```

For deployment in a server for testing or production environments, you can work with the default `docker-compose.server.yml` file. 

```sh
cp docker-compose.server.yml docker-compose.yml
```

5. **Configure the docker-compose.yml (1):** in the `docker-compose.yml` file, replace the text variable `<local_folder_of_cloned_denguetorpedo_git_project>` with the path to the **Code Home** in the **`host`**. For example, suppose your Code Home is `/home/user/projects/denguetorpedo`, you volume should be configured as follows: 
```yaml
  volumes:
    - /home/user/projects/denguetorpedo:/home/dengue/denguetorpedo
```

5.  **Configure the docker-compose.yml (2):** in the `docker-compose.yml` file, replace the variable `<local_folder_for_redis>` with the path where you want to store redis data and configuration in the **`host`**. For example, suppose we created `/opt/redis` in the **`host`** and want to use it to share with the redis container, the line should become the following: 
```yaml
  volumes:
    - /home/user/projects/denguechat-compose/redis/redisVolume:/bitnami
```
 
6.  **Configure the docker-compose.yml (3):** if you are using the `localdev` branch, you should configure the ENV variable `${HOST_IP}` to point to the IP address of the PostgreSQL server. If you are running postgres locally, that would be your **`host`** machine (i.e., your local development machine or server IP). For this to work, the postgres server will have to be properly configured. See the section [Database](#database) below for more notes about configuring your database. You can use the script `setenv_compose.localdev.sh` to add the `HOST_IP` variable to your environment, before building the containers. Make sure the command in this script is correct for your local environment. If it is not, you can create your own version with the proper command to set the `HOST_IP` to the host machine IP. 

```sh
chmod +x setenv_compose.sh
. ./setenv_compose.sh
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
DATABASE_URL=protocol://username:password@postgreshost:port/database
```

9. **Prepare your environment variables (3):** in the new `.env` file, edit the `REDIS_PASSWORD` variable with the password you would like to configure. If you have an AWS account, use your credentials to configure the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. 

10. **Build and run REDIS:** 
```sh
docker-compose build redis && docker-compose up -d redis
```

**Notes:** 
   - Remember you can run `docker-compose up` without the -d if you want to see the output of this process in foreground. If you run it with the -d flag, you can use `docker-compose logs` command to explore the logging output in search for potential issues or problems. 
    - If you have a failure when the docker tries to run the `sudo apt-get update` command, see the section `DOCKERFILE` below for a potential fix. 

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
You can either use your host provided postgres (if you have one running) or create your own postgres container. 

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

# denguechat-compose
Docker compose for [DengueChat](https://github.com/socialappslab/denguetorpedo)

## To Run

If you are running for local development, make sure to first checkout the `localdev` branch. 

1. Clone the DengueChat repository from this [link](https://github.com/socialappslab/denguetorpedo) 
2. Set the path where DengueChat was cloned in the `docker-compose.yml` 
3. Create a copy of the file `.env.sample` and edit the varialbles for: 
    - PostgreSQL database user, password and database name
    - Redis password
4. Run `docker-compose build && docker-compose up -d`

Access DengueChat UI at `http://localhost:3000`

## Useful docker commands: 
1. View denguetorpedo container logs: `docker logs denguetorpedo`
2. View redis containerlogs: `docker logs denguetorpedo-redis`
3. Accessing the container: `docker exec -t -i denguetorpedo /bin/bash` 
4. View sidekiq logs: access the container (3) en run `tail -f -n1 home/dengue/denguetorpedo/log/sidekiq.log`

# Local Development 
**Obs.** these are tips based on Mac OSX development environment. 

### Install rbenv
https://github.com/rbenv/rbenv#homebrew-on-macos 

### Set Local Ruby Version
`rbenv local 2.2.4`

### Fix of Puma Gem
La gema puma -v '2.11.2' da un error de instalación que se corrige de la siguiente manera: 
1. Instalar openssl
`brew install openssl`
2. Instalar la gema utilizando open ssl
`gem install puma -v '2.11.2' --source 'http://rubygems.org/' -- --with-cppflags=-I/usr/local/opt/openssl/include
`

### .env.sample.mac
1. Modificar DATABASE_URL
Reemplazar `<ingresar_nombre_base_datos>` por el nombre creado en extra_hosts en el archivo docker-compose. 
2. Modificar REDISTOGO_URL 
Reemplazar `<ingresar_ip_asignada_a_denguetorpedo-redis>` por la ip asignada al contenedor denguetorpedo-redis. 
Para visualizar eso se puede utilizar: `docker inspect --format '{{ .NetworkSettings.IPAddress }}' denguetorpedo-redis`

### docker-compose.yml
1. Se deben exponer los puertos:
- denguetorpedo: 3001, 5000
- denguetorpedo-redis: 6379.
2. Reemplazar `<local_folder_for_redis>` por la carpeta local que se utilizará como volumen de Redis. 
3. Reemplazar `<local_folder_of_cloned_denguetorpedo_git_project>` por la carpeta local donde se encuentra el repositorio clonado.
4. Si la base de datos está en localhost (fuera de los contenedores) se debe agregar la IP en la porción que dice `extra_hosts` agregando la IP asignada a nuestro servidor. (Se puede visualizar con `ifconfig`). Reemplazar `<server_ip>` por la ip asignada a nuestro servidor en la red. 


### Recover Database
#### Habilitar conexiones externas en nuestro servidor de base de datos
1. Abrir el archivo `/usr/local/var/postgres/postgresql.conf`
Y agregar o modificar:  `listen_addresses='*'`
2. Abrir el archivo `/usr/local/var/postgres/pg_hba.conf`
Y agregar o modificar: 
`host   all  all    0.0.0.0/0  md5`
`local  all  postgres          md5`

#### Poblar la base de datos
1. Recuperar la estructura y datos (obtenidos de un pg_dump)
` psql denguetorpedo < denguetorpedo.sql`


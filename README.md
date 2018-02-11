# denguechat-compose
Docker compose for DengueChat 
## To Run
- Clone the repo https://github.com/socialappslab/denguetorpedo and set his path in the docker-compose.yml 
- Create a copy of the file .env.sample and edit according to the postgresql database user, password and database name, and the redis password.
- run `docker-compose build && docker-compose up -d`

Access http://localhost:3000
## To view logs:
- `docker logs denguetorpedo`
- `docker logs denguetorpedo-redis`

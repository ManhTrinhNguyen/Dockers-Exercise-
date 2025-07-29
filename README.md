- [Start Mysql container](#Start-Mysql-container)

- [Start Mysql GUI container](#Start-Mysql-GUI-container)

- [Dockerize your Java Application](#Dockerize-your-Java-Application)

## Docker Exercise 

## Start Mysql container 

I will first test running MySQL as a container in my Local Machine 

I don't want to expose the password to your database by hardcoding it into the app and checking it into the repository:

- Export all needed environment variables for your application for connecting with the database . For example : 

```
export DB_USER=tim
export DB_PWD=password
export DB_SERVER=localhost 
export DB_NAME=test-db
```

Then I will `Build a jar file` and start the application : `gradle clean build`

Now first I will run Mysql : 

```
docker run -d -p 3306:3306 -n mysql-network \                
-e MYSQL_ROOT_PASSWORD=rootpassword \
-e MYSQL_DATABASE=test-db \
-e MYSQL_USER=tim \       
-e MYSQL_PASSWORD=password \        
mysql
```

To check container log : `docker logs <container-id>`

Then I will run java application with the Jar file I just created above : `java -jar build/libs/docker-exercises-project-1.0-SNAPSHOT.jar`

## Start Mysql GUI container

```
docker run -d --name phpmyadmin -p 8083:80 \
--link mysql:db \
--network mysql-network \
phpmyadmin
```

## Use docker-compose for Mysql and Phpmyadmin

```
version: '3'
services:
  mysql:
    image: mysql
    restart: always
    ports: 
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=test-db
      - MYSQL_USER=tim 
      - MYSQL_PASSWORD=password
    volumes:
      - mysql-data:/var/lib/mysql
    container_name: mysql
  phpmyadin:
    image: phpmyadmin
    restart: always
    ports:
      - 8083:80
    depends_on:
      - "mysql"
    environment:
      - PMA_HOST=mysql
    container_name: phpmyadmin

volumes:
  mysql-data:
    driver: local 

```

I have an error that I can't login to `phpmyadmin` with my `tim` user and `password`. Bcs of my `named volume mysql-data` that I created before and I attach it with the new `docker-compose` . So it use the `data before` that I saved in `mysql-data` .

- I know that bcs I Open MySQL shell in container : `docker exec -it mysql mysql -u root -p` (enter: rootpassword)

- I then I use `SELECT user, host, plugin FROM mysql.user;` and I don't see `tim user` in there so I know it used the Volume that I created before 

- To fix this issue I delete the volume (bcs I don't need that) `docker volume rm mysql-data` and then just run `docker-compose` again 

##  Dockerize your Java Application

```
FROM gradle:jdk24

RUN mkdir -p /java ## Create new /java folder 

COPY ./build/libs/docker-exercises-project-1.0-SNAPSHOT.jar /java/app.jar ## Copy jar file from local and change its name into app.jar

WORKDIR /java ## Working directory 

CMD ["java", "-jar", "app.jar"] ## Run jar file
```

To dockerize : `docker build -t java-gradle .`

## Build and push Java Application Docker Image

I need to change docker image name tag : `docker tag java-gradle  nguyenmanhtrinh/demo-app:java-gradle` . Bcs Docker need to know which reposiotry I am trying to push into 

Push Docker image : `docker push nguyenmanhtrinh/demo-app:java-gradle`

## Add application to docker-compose

```
version: '3'
services:
  mysql:
    image: mysql
    restart: always
    ports: 
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
      - MYSQL_USER=${DB_USER}
      - MYSQL_PASSWORD=${DB_PWD}
    volumes:
      - mysql-data:/var/lib/mysql
    container_name: mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
  phpmyadin:
    image: phpmyadmin
    restart: always
    ports:
      - 8083:80
    depends_on:
      - "mysql"
    environment:
      - PMA_HOST=mysql
    container_name: phpmyadmin
  java-gradle:
    image: nguyenmanhtrinh/demo-app:java-gradle
    ports:
      - 8080:8080
    depends_on:
      - "mysql"
    environment:
      - DB_USER=${DB_USER}
      - DB_PWD=${DB_PWD}
      - DB_SERVER=${DB_SERVER}
      - DB_NAME=${DB_NAME}

volumes:
  mysql-data:
    driver: local 
  
```

Since `docker-compose` is part of your application and checked in to the repo, it shouldn't contain any sensitive data. But also allow configuring these values from outside based on an environment

## Create Server And run Docker compose in there

I will go to AWS UI and create EC2 instance (Amazon Linux t2.large)

Then I will create a install docker and docker compose script : 

```
sudo yum update -y 

sudo amazon-linux-extras install docker

sudo yum install -y docker

sudo service docker start

sudo usermod -a -G docker ec2-user

sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version
```

Then I will create a run docker compose script : 

```
export DB_USER=$1 
export DB_PWD=$2
export DB_SERVER=$3
export DB_NAME=$4 
export MYSQL_ROOT_PASSWORD=$5
export dockerhub_password=$6

docker login -u nguyenmanhtrinh -p $dockerhub_password

docker-compose -f docker-compose.yaml up
```

To ssh to the instance : `ssh -i <.pem> ec2-user@public-ip`

To copy files from local to server : `scp <file want to copy from local> ec2@public-ip:/home/ec2-user/`

Then i will run all those `bash` file on the server 

Set Security Group for my Instance :

SSH -> 22 

TCP -> 8080 and 8083 
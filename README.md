- [Start Mysql container](#Start-Mysql-container)

- [Start Mysql GUI container](#Start-Mysql-GUI-container)

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
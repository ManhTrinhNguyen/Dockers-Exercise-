export DB_USER=$1 
export DB_PWD=$2
export DB_SERVER=$3
export DB_NAME=$4 
export MYSQL_ROOT_PASSWORD=$5
export dockerhub_password=$6

docker login -u nguyenmanhtrinh -p $dockerhub_password

docker-compose -f docker-compose.yaml up
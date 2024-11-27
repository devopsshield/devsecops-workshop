# prompt the user for the variables
# ask for the instance name
#echo "Enter the instance name (e.g. defectdojo-002):"
#read instanceName
#echo "Instance name is: $instanceName"
# set as environment variable
export instanceName="app-defectdojo-ek005"

# set all variables here:
export USERNAME="ddadmin"
export PASSWORD="booWgDmaYdgNxO5eNWql"
export postgresHostname="$instanceName-postgresql.devopsshield.com"
export NEWHOSTNAME="$instanceName.devopsshield.com"
export nginx_folder="$HOME/django-DefectDojo/nginx"
export databaseName="defectdojo"
export databasePort="5432"
export doPauses="false" # set to "true" to pause after each step
# wait time for the container to be up and migrations to be done
export waitTime=300

export EMAIL="emmanuel.knafo@devopsshield.com"
export adminUser="emmanuel"
export adminPassword="N9rw04entPmou3Rbf6JP!"

# check that the hostname is correct
echo "The hostname is: $NEWHOSTNAME"
# check that it resolves to the correct IP
echo "The IP address for the hostname is:"
dig +short $NEWHOSTNAME


# update the system
# skip a line
echo ""
echo "STEP 1: Updating the system"
echo "==========================="

# disble auto updates
sudo apt-get update -y
sudo apt-get upgrade -y
#sudo apt-get autoremove -y
#sudo apt-get autoclean -y
sudo NEEDRESTART_MODE=a apt-get dist-upgrade --yes

# find and replace the variables in the files
find $HOME/OSS_django-DefectDojo/docker/environments/postgres-redis.env -type f -exec sed -i "s/__DD_DATABASE_USER__/$USERNAME/g" {} \;
find $HOME/OSS_django-DefectDojo/docker/environments/postgres-redis.env -type f -exec sed -i "s/__DD_DATABASE_PASSWORD__/$PASSWORD/g" {} \;
find $HOME/OSS_django-DefectDojo/docker/environments/postgres-redis.env -type f -exec sed -i "s/__DD_DATABASE_HOST__/$postgresHostname/g" {} \;
find $HOME/OSS_django-DefectDojo/docker/environments/postgres-redis.env -type f -exec sed -i "s/__DD_DATABASE_NAME__/$databaseName/g" {} \;
find $HOME/OSS_django-DefectDojo/docker/environments/postgres-redis.env -type f -exec sed -i "s/__DD_DATABASE_PORT__/$databasePort/g" {} \;

# show the files
cat $HOME/OSS_django-DefectDojo/docker/environments/postgres-redis.env

# pause if needed
if [ "$doPauses" = "true" ]; then
    read -p "Press enter to continue"
fi

echo ""
echo "STEP 2: Installing Docker and Docker Compose"
echo "============================================"

# install docker and docker compose
# on Ubuntu 22.04
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# install docker-compose
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# allow to run docker without sudo
sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt install acl -y
sudo setfacl -m user:$USER:rw /var/run/docker.sock
docker run hello-world

# pause if needed
if [ "$doPauses" = "true" ]; then
    read -p "Press enter to continue"
fi

echo ""
echo "STEP 3: Fix hostname and create certificates"
echo "============================================"

# hostname change
# set the hostname
sudo hostnamectl set-hostname $NEWHOSTNAME
sudo hostnamectl set-hostname "Defect Dojo VM" --pretty
sudo hostnamectl set-hostname $NEWHOSTNAME --static
sudo hostnamectl set-hostname $NEWHOSTNAME --transient

# check hostname
hostnamectl

# create certificates using certbot -- should be done after the DNS is set
# may need to set dns entry for the hostname
sudo apt-get update -y
sudo apt-get install certbot -y
sudo certbot certonly --standalone --non-interactive -d $NEWHOSTNAME --agree-tos --email $EMAIL

# copy certificates to the nginx folder
sudo cp /etc/letsencrypt/live/$NEWHOSTNAME/fullchain.pem $nginx_folder/nginx.crt
sudo cp /etc/letsencrypt/live/$NEWHOSTNAME/privkey.pem $nginx_folder/nginx.key
ls -ls $nginx_folder

# pause if needed
if [ "$doPauses" = "true" ]; then
    read -p "Press enter to continue"
fi

echo ""
echo "STEP 4: Install Postgresql client and create database"
echo "====================================================="

# install postgresql client
sudo apt update -y
sudo apt install gnupg2 wget vim -y
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update -y
sudo apt-get install postgresql-client-16 -y

#psql "postgres://$USERNAME:$PASSWORD@$postgresHostname:5432/postgres"

# create database and user in psql client

# create the database with psql then exit
echo "CREATE DATABASE defectdojo on $postgresHostname"
psql "postgres://$USERNAME:$PASSWORD@$postgresHostname:5432/postgres" -c 'create database defectdojo;'

#psql "postgres://$USERNAME:$PASSWORD@$postgresHostname:5432/postgres" -c 'create database defectdojo; quit();'

# pause if needed
if [ "$doPauses" = "true" ]; then
    read -p "Press enter to continue"
fi

echo ""
echo "STEP 5: Install DefectDojo"
echo "=========================="

rm -f docker-compose.override.yml
ln -s docker-compose.override.https.yml docker-compose.override.yml

echo "current docker-compose.override.yml"
cat docker-compose.override.yml

# build and run the docker-compose
# first time should take a while
sudo ./dc-build.sh
#sudo ./dc-up.sh
sudo ./dc-up-d.sh

# check the logs if your quick
# look for the Admin user
# loop until the logs are available
#docker logs dojo-initializer-1 | grep Admin

# wait for container to be up and migrations to be done
echo "Waiting for the container to be up and migrations to be done for $waitTime seconds..."
sleep $waitTime

# pause if needed
if [ "$doPauses" = "true" ]; then
    read -p "Press enter to continue"
fi

echo ""
echo "STEP 6: Create a superuser"
echo "=========================="

# create a superuser
#docker exec -it oss_django-defectdojo-uwsgi-1 /bin/bash
#python manage.py createsuperuser
#export DJANGO_SUPERUSER_PASSWORD="admin7"; python manage.py createsuperuser --no-input --username admin7 --email admin7@defectdojo.local;
#docker exec oss_django-defectdojo-uwsgi-1 /bin/bash -c 'export DJANGO_SUPERUSER_PASSWORD="admin9"; python manage.py createsuperuser --no-input --username admin9 --email admin9@defectdojo.local;'

export COMMAND="export DJANGO_SUPERUSER_PASSWORD="$adminPassword"; export DJANGO_SUPERUSER_USERNAME="$adminUser"; export DJANGO_SUPERUSER_EMAIL="$EMAIL"; python manage.py createsuperuser --no-input"
echo "COMMAND: $COMMAND"
docker exec oss_django-defectdojo-uwsgi-1 /bin/bash -c "$COMMAND"

# test the application
# open a browser and go to https://$NEWHOSTNAME:8443/dashboard
echo "https://$NEWHOSTNAME:8443/dashboard"

# pause if needed
if [ "$doPauses" = "true" ]; then
    read -p "Press enter to continue"
fi

echo ""
echo "STEP 7: Setup systemd service for docker-compose automation"
echo "==========================================================="

# put back DD_INITIALIZE to false
rm -f docker-compose.override.yml
ln -s docker-compose.override.https.initializefalse.yml docker-compose.override.yml

echo "current docker-compose.override.yml"
cat docker-compose.override.yml

# docker-compose service
sudo cp $HOME/OSS_django-DefectDojo/systemd/defectdojo-composer.service /etc/systemd/system/
sudo systemctl enable defectdojo-composer

echo ""
echo "STEP 8: Double check there are 5 running containers"
echo "==================================================="

docker ps

echo "Done!"
echo "The DefectDojo instance is now available at https://$NEWHOSTNAME:8443/dashboard"
echo "The superuser is $adminUser with password $adminPassword"
echo "Don't forget to change the password for the superuser!"

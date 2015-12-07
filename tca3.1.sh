docker build -t teamcity-agent:docker-3.1 .
docker run -d --name tca3.1 --hostname=tca3.1 --restart=always --link teamcity:cis -e DOCKER_HOST=tcp://172.17.0.1:2375 -e TEAMCITY_SERVER=http://cis:8111/cis teamcity-agent:docker-3.1

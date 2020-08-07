1. sudo docker network create elk
2. sudo /usr/local/bin/docker-compose -f docker-compose-redis.yml up -d 
3. sudo /usr/local/bin/docker-compose --compatibility -f docker-compose-elk.yml up -d
4. sudo /usr/local/bin/docker-compose -f docker-compose-nginx.yml up -d

Explore Access: http://localhost:7601
web password: jack/123456

Task-3 Report: Dockerized Strapi with PostgreSQL and Nginx Reverse Proxy

Name: Piyush Sharma
Date: 10-Feb-2026
Repository: https://github.com/piyushhsharma/strapi-docker-app

Pull Request: https://github.com/piyushhsharma/strapi-docker-app/pull/2

Loom Video: <Add Loom link here>

1. Objective

The task was to set up a Dockerized environment for a Strapi application with the following:

User-defined Docker network

PostgreSQL container with proper credentials

Strapi container connected to PostgreSQL

Nginx container as a reverse proxy

All containers running on the same network

Accessible Strapi Admin Dashboard at http://localhost/admin (or alternative port on Windows)

2. Setup Steps
2.1 Directory Structure
strapi-docker-app/
├─ Dockerfile
├─ docker-compose.yml
├─ config/
│  └─ database.js
├─ nginx/
│  └─ nginx.conf
├─ package.json
└─ package-lock.json

2.2 Docker Network

Created a user-defined network strapi-net in docker-compose.yml:

networks:
  strapi-net:
    driver: bridge


All containers (postgres, strapi, nginx) are attached to this network.

2.3 PostgreSQL Container

Configured PostgreSQL in docker-compose.yml:

postgres:
  image: postgres:15
  container_name: postgres
  restart: always
  environment:
    POSTGRES_USER: strapi
    POSTGRES_PASSWORD: strapi123
    POSTGRES_DB: strapi_db
  volumes:
    - pgdata:/var/lib/postgresql/data
  networks:
    - strapi-net

2.4 Strapi Container

Dockerfile:

FROM node:18-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install
RUN npm install pg

COPY . .

RUN npm run build

EXPOSE 1337
CMD ["npm", "run", "develop"]


Environment variables for PostgreSQL in docker-compose.yml:

strapi:
  build: .
  container_name: strapi
  restart: always
  environment:
    DATABASE_CLIENT: postgres
    DATABASE_HOST: postgres
    DATABASE_PORT: 5432
    DATABASE_NAME: strapi_db
    DATABASE_USERNAME: strapi
    DATABASE_PASSWORD: strapi123
    NODE_ENV: development
  depends_on:
    - postgres
  networks:
    - strapi-net


Database configuration (config/database.js):

module.exports = ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: env('DATABASE_HOST', 'postgres'),
      port: env.int('DATABASE_PORT', 5432),
      database: env('DATABASE_NAME', 'strapi_db'),
      user: env('DATABASE_USERNAME', 'strapi'),
      password: env('DATABASE_PASSWORD', 'strapi123'),
      ssl: false,
    },
  },
});

2.5 Nginx Container (Reverse Proxy)

nginx/nginx.conf:

events {}

http {
  server {
    listen 80;

    location / {
      proxy_pass http://strapi:1337;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
  }
}


docker-compose.yml entry for Nginx:

nginx:
  image: nginx:latest
  container_name: nginx
  ports:
    - "8080:80"  # Using 8080 due to Windows port 80 restriction
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  depends_on:
    - strapi
  networks:
    - strapi-net

2.6 Volumes
volumes:
  pgdata:


This ensures PostgreSQL data persistence.

2.7 Commands to Build and Run
cd C:\Users\ASUS\strapi-docker-app
docker-compose down
docker-compose build --no-cache
docker-compose up -d


Check logs:

docker-compose logs --tail=30 strapi


Strapi should display: Strapi started successfully

Admin panel accessible at: http://localhost:8080/admin

3. Verification

Containers running:

docker ps


Expected:

postgres → Up

strapi → Up

nginx → Up

Admin panel:

Open browser → http://localhost:8080/admin

Create first admin user

Access dashboard successfully

4. Notes / Observations

Installed pg package in Dockerfile for PostgreSQL support.

Changed Nginx host port to 8080 due to Windows port 80 restrictions.

Used user-defined Docker network strapi-net for all containers.

5. References

Repo: https://github.com/piyushhsharma/strapi-docker-app

Pull Request: https://github.com/piyushhsharma/strapi-docker-app/pull/2

Loom Video: <Add Loom link here>

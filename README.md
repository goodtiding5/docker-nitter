# Nitter

[Nitter](https://nitter.net) is an alternative [Twitter](https://twitter.com) front-end with the focus on privacy. According to its author, it is inspired by the [invidio.us](https://invidio.us) project and is released under GPL 3 license.

Here are some of Nitter features:

* No JavaScript or Twitter ads
* Prevents Twitter from tracking your IP or JavaScript fingerprint
* No rate limits or developer account required
* Lightweight, docker image is about 5Mb in size
* Native RSS feeds
* Responsive UI design

## Screenshot
![nitter](https://github.com/zedeus/nitter/raw/master/screenshot.png)

## Usage

We use docker composer to manage this nitter instance.

### Installation

Create a directory for the nitter deployment.  Create a subdirectory `data` to keep all nitter data.

Here is the `docker-compose.yml` file:

```
version: '3.3'

services:
  app:
    image: epenguincom/nitter:latest
    volumes:
      - ./data:/data
    ports:
      - "127.0.0.1:8080:8080"
    restart: always
```

### Bootstrap

Run the following command to bootstrap/populate nitter configuration file and working directories.

```
$ docker-compose run app bootstrap
```

Make any necessary changes to the configuration file `data/nitter.conf` before run the instance.

### Running the instance

This image has a builtin health check mechanism to terminate the container if any problems occur.  Therefore, it is desired that we should start the container with *auto restart* enabled.

To start the container, run the following command:

```
$ docker-compose up -d
```

It's recommend to put a reverse proxy in front of it for public access.

For nginx, here is the sample setup with letsencryp for the reference:

```
server {
    listen [::]:443 ssl;
    listen 443 ssl;

    server_name server.tld;

    ssl_certificate /etc/letsencrypt/live/server.tld/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/server.tld/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf; 
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; 

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass http://localhost:8080;
    }
}

```

### Update

Nitter is still under active development.  Docker images for nitter will be updated constantly.

To utilize the latest image, run the following commands:

```
$ docker-compose down
$ docker-compose pull
$ docker-compose up -d
```






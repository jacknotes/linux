## 部署Sentry

#### 安装sentry
```
git clone https://github.com/getsentry/onpremise sentry
cd sentry/
git reset --hard 23.1.1		#经过测试此版本正常，22.12.0有问题
./install.sh --skip-commit-check	#此过程会下镜像，会很慢

▶ Setting up GeoIP integration ...
Setting up IP address geolocation ...
Installing (empty) IP address geolocation database ... done.
IP address geolocation is not configured for updates.
See https://develop.sentry.dev/self-hosted/geolocation/ for instructions.
Error setting up IP address geolocation.
-----------------------------------------------------------------

You're all done! Run the following command to get Sentry running:

  docker-compose up -d

-----------------------------------------------------------------
```


#### 启动sentry
```
docker-compose up -d
```

#### 查看sentry状态
[root@docker sentry]# docker-compose ps -a
                            Name                                           Command                  State                  Ports
--------------------------------------------------------------------------------------------------------------------------------------------
sentry-self-hosted_clickhouse_1                                 /entrypoint.sh                   Up (healthy)   8123/tcp, 9000/tcp, 9009/tcp
sentry-self-hosted_cron_1                                       /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_geoipupdate_1                                /usr/bin/geoipupdate -d /s ...   Exit 1
sentry-self-hosted_ingest-consumer_1                            /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_kafka_1                                      /etc/confluent/docker/run        Up (healthy)   9092/tcp
sentry-self-hosted_memcached_1                                  docker-entrypoint.sh memcached   Up (healthy)   11211/tcp
sentry-self-hosted_nginx_1                                      /docker-entrypoint.sh ngin ...   Up             0.0.0.0:9000->80/tcp
sentry-self-hosted_post-process-forwarder-errors_1              /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_post-process-forwarder-transactions_1        /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_postgres_1                                   /opt/sentry/postgres-entry ...   Up (healthy)   5432/tcp
sentry-self-hosted_redis_1                                      docker-entrypoint.sh redis ...   Up (healthy)   6379/tcp
sentry-self-hosted_relay_1                                      /bin/bash /docker-entrypoi ...   Up             3000/tcp
sentry-self-hosted_sentry-cleanup_1                             /entrypoint.sh 0 0 * * * g ...   Up             9000/tcp
sentry-self-hosted_smtp_1                                       docker-entrypoint.sh exim  ...   Up             25/tcp
sentry-self-hosted_snuba-api_1                                  ./docker_entrypoint.sh api       Up             1218/tcp
sentry-self-hosted_snuba-cleanup_1                              /entrypoint.sh */5 * * * * ...   Up             1218/tcp
sentry-self-hosted_snuba-consumer_1                             ./docker_entrypoint.sh con ...   Up             1218/tcp
sentry-self-hosted_snuba-outcomes-consumer_1                    ./docker_entrypoint.sh con ...   Up             1218/tcp
sentry-self-hosted_snuba-replacer_1                             ./docker_entrypoint.sh rep ...   Up             1218/tcp
sentry-self-hosted_snuba-sessions-consumer_1                    ./docker_entrypoint.sh con ...   Up             1218/tcp
sentry-self-hosted_snuba-subscription-consumer-events_1         ./docker_entrypoint.sh sub ...   Up             1218/tcp
sentry-self-hosted_snuba-subscription-consumer-transactions_1   ./docker_entrypoint.sh sub ...   Up             1218/tcp
sentry-self-hosted_snuba-transactions-cleanup_1                 /entrypoint.sh */5 * * * * ...   Up             1218/tcp
sentry-self-hosted_snuba-transactions-consumer_1                ./docker_entrypoint.sh con ...   Up             1218/tcp
sentry-self-hosted_subscription-consumer-events_1               /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_subscription-consumer-transactions_1         /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_symbolicator-cleanup_1                       /entrypoint.sh 55 23 * * * ...   Up             3021/tcp
sentry-self-hosted_symbolicator_1                               /bin/bash /docker-entrypoi ...   Up             3021/tcp
sentry-self-hosted_web_1                                        /etc/sentry/entrypoint.sh  ...   Up (healthy)   9000/tcp
sentry-self-hosted_worker_1                                     /etc/sentry/entrypoint.sh  ...   Up             9000/tcp
sentry-self-hosted_zookeeper_1                                  /etc/confluent/docker/run        Up (healthy)   2181/tcp, 2888/tcp, 3888/tcp


#### 访问sentry
WEB访问http://172.168.2.20:9000/auth/login/sentry/
用户：your@email.com
密码：your-password


#### 命令行创建用户，不加--superuser为普通用户，--force-update用来覆盖已经存在的账号
[root@docker sentry]# docker-compose run --rm web createuser --superuser --force-update
Creating sentry-self-hosted_web_run ... done
Updating certificates in /etc/ssl/certs...
0 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
/usr/local/lib/python3.8/site-packages/sentry/runner/initializer.py:243: DeprecationWarning: `structlog.threadlocal` is deprecated, please use `structlog.contextvars` instead.
  WrappedDictClass = structlog.threadlocal.wrap_dict(dict)
01:24:35 [INFO] sentry.plugins.github: apps-not-configured
Email: test@email.com
Password:
Repeat for confirmation:
Added to organization: sentry
User created: test@email.com


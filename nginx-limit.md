# nginx 设置限制单个ip请求速率



其它公司例子：最近遇到网站突然流量激增，流量穿透 nginx 到后端，导致后端服务器 502，本以为是突发流量没太重视，经过日志分析发现是单个 ip 在1分钟内高并发请求 1200 次所致。这种行为已经不是正常的爬虫，而是恶意攻击行为，那么 nginx 可否对这种攻击行为进行限制呢？



## 限速模块

Nginx有三种类型的模块用来限速，都是Nginx的内置模块，配置简单，开箱即用，且各有其特点：
* limit_conn_zone 模块: 限制同一IP 地址并发连接数；	
* limit_request 模块: 限制同一 IP 某段时间的访问量；	
* core 模块提供: limit_rate 限制同一 IP 流量。




## limit_conn_zone

```bash
指令: limit_conn_zone
语法: limit_conn_zone $variable zone=name:size;
默认值：no
使用字段：http
指令描述会话状态存储区域。
会话的数目按照指定的变量来决定，它依赖于使用的变量大小和memory_max_size的值。


指令: limit_conn
语法: limit_conn zone_name max_clients_per_ip
默认值：no
使用字段：http, server, location
指令指定一个会话的最大同时连接数，超过这个数字的请求将被返回”Service unavailable” (503)代码。
```

```bash
http {
	limit_conn_zone $binary_remote_addr zone=connzone:10m;
	............

	server {
        listen       80;
        server_name zkui.test.hs.com;

        location / {
                add_header backendIP $upstream_addr;
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_read_timeout 300s;
                proxy_buffer_size  128k;
                proxy_busy_buffers_size 128k;
                proxy_buffers   32 32k;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-Port $remote_port;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_pass http://172.168.2.32:9090;
                limit_conn connzone 4;	 #这将指定一个地址只能同时存在4个连接。"connzone"与上面的对应，也可以自定义命名
                limit_conn_status 478;
                limit_rate 300k;
                #limit_req zone=reqzone burst=20 nodelay;
                #limit_req_status 478;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
                root   html;
        }
    }


limit_zone： 是针对每个IP定义一个存储session状态的容器.这个示例中定义了一个10m的容器，按照32bytes/session， 可以处理320000个session。
limit_conn connzone 4：限制每个IP只能发起4个并发连接。
limit_rate 300k： 对每个连接限速300k, 注意，这里是对连接限速，而不是对IP限速。如果一个IP允许两个并发连接，那么这个IP就是限速limit_rate×2。
```




## limit_request

通过限制单个 ip 的请求次数来达到防止单 ip 的高频词访问行为。



### 频率限制

频率限制主要有2个主要指令，limit_req_zone 和limit_req, 示例如下：
```bash
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;
server {
    location /login/ {
        limit_req zone=mylimit;
        proxy_pass http://my_upstream;
    }
}
```

1. limit_req_zone指令定义了速度限制的参数，同时在出现的上下文中启用速率限制，通常定义在HTTP块中，这样可以用于多个上下文，它包含3个参数：
   - Key - 定义应用限制的请求特征。 在这个例子中，它是 Nginx 变量 $binary_remote_addr ，它保存着客户端 IP 地址的二进制表示。 这意味着我们将每个唯一的IP地址限制为由第三个参数定义的请求速率。
   - Zone - 定义用于存储每个IP地址状态的共享内存区域以及访问请求受限URL的频率。 将信息保存在共享内存中意味着它可以在Nginx工作进程之间共享。

2. 定义有两个部分： zone=keyword 标识的区域名称和冒号后面的大小。 大约16,000个IP地址的状态信息需要1兆字节，所以我们的区域可以存储大约160,000个地址。 如果Nginx需要添加一个新条目时，存储空间将被耗尽，它将删除最旧的条目。
3. 如果释放的空间不足以容纳新记录，则 Nginx返回状态码503 (Temporarily Unavailable) 。 此外，为了防止内存耗尽，每当Nginx创建一个新条目时，最多可以删除两个在前60秒内没有使用的条目。
4. Rate: 设置最大请求率。 在这个例子中，速率不能超过每秒 10 个请求。 Nginx实际上以毫秒粒度跟踪请求，所以这个限制对应于每 100 毫秒 1 个请求。 由于我们不允许爆发，这意味着如果请求在前一个允许的时间之后小于 100 毫秒时被拒绝。
5. limit_req_zone 指令为速率限制和共享内存区域设置参数，但实际上并不限制请求速率。
因此，需要通过在其中包含 limit_req 指令来将限制应用于特定 http, location 或 server 块。 



### 处理并发

* 如果我们在 100 毫秒内得到两个请求会怎么样？ 对于第二个请求，Nginx将状态码503返回给客户端。 这可能不是我们想要的，因为应用程序本质上是突发性的。
* 相反，我们想要缓冲任何多余的请求并及时提供服务。 这时我们使用 burst 参数 limit_req，在这个更新的配置：
```bash
location /login/ {
	limit_req zone=mylimit burst=20;
	proxy_pass http://my_upstream;
}
```
* 这意味着如果 21 个请求同时从一个给定的IP地址到达，Nginx 立即将第一个请求转发到上游服务器组，并将剩下的20个放入队列中。 然后，它每 100 毫秒转发一个排队的请求，并且只有当传入的请求使排队请求的数量超过 20 时才返回 503 给客户端。



### 无延迟队列

* 具有 burst 的配置会导致流量畅通，但不是很实用，因为它可能会使您的网站显得很慢。
在我们的例子中，队列中的第 20 个数据包等待 2 秒钟被转发，此时对其的响应可能对客户端不再有用。 要解决这种情况，请将nodelay 参数与 burst 参数一起添加：
```bash
location /login/ {
	limit_req zone=mylimit burst=20 nodelay;
	proxy_pass http://my_upstream;
}
```
* 假设像以前一样，20 个时隙的队列是空的，21 个请求同时从给定的 IP 地址到达。 Nginx 立即转发所有 21 个请求，并将队列中的 20 个插槽标记为已占用，然后每 100 毫秒释放 1 个插槽（如果有 25 个请求，Nginx会立即转发 21 个插槽，标记20个插槽，拒绝4个请求状态503 ）。




### 二段式速率限制

我们将 NGINX 配置为限速每秒 5 个请求 (r/s)，以保护网站。该网站每个页面一般有 4-6 个资源，最多不超过 12 个资源。此配置允许的突发请求上限为 12 个，其中前 8 个请求可以立即得到处理。超过 8 个请求后，新增请求将被强制施加 5 r/s 的速率限制。超过 12 个请求后，新增的任何请求都将被拒绝。
```bash
limit_req_zone $binary_remote_addr zone=ip:10m rate=5r/s;

server {
    listen 80;
    location / {
        limit_req zone=ip burst=12 delay=8;
        proxy_pass http://website;
    }
}
```



### 高级配置示例

通过组合使用基本速率限制与其他 NGINX 功能，可实现更精细的流量限制。

#### 允许列表
```bash
geo $limit {
    default 1;
    10.0.0.0/8 0;
    192.168.0.0/24 0;
}
 
map $limit $limit_key {
    0 "";
    1 $binary_remote_addr;
}
 
limit_req_zone $limit_key zone=req_zone:10m rate=5r/s;
 
server {
    location / {
        limit_req zone=req_zone burst=10 nodelay;
 
        # ...
    }
}
```
本例同时使用了 geo 和 map 指令。geo 模块为允许列表中 IP 地址的 $limit 赋值 0，为所有其他 IP 地址的 $limit 赋值 1。然后，我们使用 map 指令将这些值转换为关键字，例如：
* 如果 $limit 值为 0，则 $limit_key 设为空字符串
* 如果 $limit 值为 1，则 $limit_key 设为二进制格式的客户端 IP 地址
* 两者组合使用：如果客户端 IP 地址在允许列表中，则 $limit_key 设为空字符串；否则设置为该客户端的 IP 地址。当 limit_req_zone 目录的第一个参数（key）为空字符串时，不应用限制，因此允许列表中的 IP 地址（在 10.0.0.0/8 和 192.168.0.0/24 子网中）不受限制。而其他 IP 地址一律限速为每秒 5 个请求。
* limit_req 指令对 / location 限速，但允许无延迟转发最多 10 个超出配置上限的突发请求数据包。





#### 在单一 Location 中使用多个 limit_req 指令

* 用户可以在单一 location 中使用多个 limit_req 指令。此时会对符合条件的特定请求应用全部限制，这意味着最严格的一项限制会生效。例如，如果有多项指令施加延迟效果，则最长的延迟生效。同样，如果有任何一项指令的效果是拒绝请求，则该请求将被拒绝，其他指令的准入无效。
* 继续扩展上面示例，我们可以对允许列表中的 IP 地址应用速率限制：

http {
    # ...

    limit_req_zone $limit_key zone=req_zone:10m rate=5r/s;
    limit_req_zone $binary_remote_addr zone=req_zone_wl:10m rate=15r/s;
     
    server {
        # ...
        location / {
            limit_req zone=req_zone burst=10 nodelay;
            limit_req zone=req_zone_wl burst=20 nodelay;
            # ...
        }
    }
}
* 允许列表中的 IP 地址不符合第一个速率限制条件 (req_zone)，但符合第二个条件 (req_zone_wl)，因此被限制为每秒 15 个请求。允许列表以外的 IP 地址同时符合两个速率限制条件，因此更严格的一项限制生效：每秒 5 个请求。




#### 配置相关功能

**日志记录**

默认情况下，NGINX 会记录因速率限制而延迟或弃置的请求，例如：
2015/06/13 04:20:00 [error] 120315#0: *32086 limiting requests, excess: 1.000 by zone "mylimit", client: 192.168.1.2, server: nginx.com, request: "GET / HTTP/1.0", host: "nginx.com"
日志条目包含以下字段：

2015/06/13 04:20:00 – 日志的录入日期和时间
[error] – 错误等级
120315#0 – NGINX worker 的 process ID 和 thread ID，以 # 号分隔
*32086 – 速率受限的代理连接的 ID
limiting requests – 表明日志条目记录到一次速率限制
excess – 显示此请求超过配置速率的每毫秒请求数
zone – 定义了强制执行速率限制的区域
client – 发出该请求的客户端 IP 地址
server – 服务器的 IP 地址或主机名
request – 客户端发出的实际 HTTP 请求
host – Host HTTP 的 header 值
默认情况下，NGINX 的被拒请求记录等级为 error 级，如上例中的 [error]所示。（NGINX 的被延迟请求记录等级为较低一级，默认为 warn 级。）如需更改日志记录等级，可使用 limit_req_log_level 指令。下面，我们将被拒请求的记录等级设置为 warn：
```bash
location /login/ {
    limit_req zone=mylimit burst=20 nodelay;
    limit_req_log_level warn;
 
    proxy_pass http://my_upstream;
}
```


**发送至客户端的错误代码**

默认情况下，当客户端超过速率限制时，NGINX 会返回状态码 503(Service Temporarily Unavailable)。可使用 limit_req_status 指令设置不同的状态码（本例中为 444）：

location /login/ {
    limit_req zone=mylimit burst=20 nodelay;
    limit_req_status 444;
}


**拒绝对特定 Location 的所有请求**

如果要拒绝指向特定 URL 的所有请求，而不仅仅是加以限制，请为其配置一个 location 块，并使用 deny all 指令：

```bash
location /foo.php {
    deny all;
}
```




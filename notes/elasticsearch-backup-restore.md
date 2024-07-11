# 阿里云ES备份到对象存储



## 创建Bucket

地域：华东2（上海）
创建Bucket：${BUCKET_NAME}
存储冗余类型：本地冗余存储
读写权限：私有



## 创建子用户

创建子用户：elasticsearch-backup
生成AK、SK



## 创建自定义策略

创建自定义策略，授权策略可以访问特定Bucket
自定义策略名称：OSSPolicy-Buket--${BUCKET_NAME}

**权限内容：**
```json
{
    "Version": "1",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "oss:*",
            "Resource": [
                "acs:oss:*:*:${BUCKET_NAME}",
                "acs:oss:*:*:${BUCKET_NAME}/*"
            ]
        }
    ]
}
```





## 备份ES



### 在ES上创建快照仓库

```bash
GET _snapshot/my_backup

PUT _snapshot/my_backup/
{
    "type": "oss",
    "settings": {
        "endpoint": "http://oss-cn-shanghai-internal.aliyuncs.com",
        "access_key_id": "AK",
        "secret_access_key": "SK",
        "bucket": "${BUCKET_NAME}",
        "compress": true,
        "chunk_size": "500mb",
        "base_path": "snapshot/"
    }
}
```



### 在ES上备份索引

```bash
# 备份所有索引
PUT _snapshot/my_backup/snapshot_1?wait_for_completion=true

# 查看当前快照备份的状态
GET _snapshot/my_backup/snapshot_1/_status

## 备份指定索引
#PUT _snapshot/my_backup/snapshot_test?wait_for_completion=true
#{
#    "indices": "inter_corehotel_db_pro_v1_daolv"
#}

# 查看备份的快照状态
GET _snapshot/my_backup/snapshot_1/_status

# 查看所有备份的快照状态
GET _snapshot/my_backup/_all


## 删除指定的快照。如果该快照正在进行，执行以下命令，系统会中断快照进程并删除仓库中创建到一半的快照。
#DELETE _snapshot/my_backup/snapshot_3
```





## 恢复ES



### 在新ES上恢复索引

```bash
# 把备份快照中的所有索引恢复到Elasticsearch集群中
POST _snapshot/my_backup/snapshot_1/_restore?wait_for_completion=true

## 恢复所有索引（除.开头的系统索引，-表示不包括）
#POST _snapshot/my_backup/snapshot_1/_restore 
#{
#  "indices":"*,-.monitoring*,-.security*,-.kibana*,-.apm*",
#  "ignore_unavailable":"true",
#  "index_settings": {
#    "index.number_of_replicas": 0
#  }
#}

## 将指定快照中的指定索引以重命名名称恢复到Elasticsearch集群中
#POST /_snapshot/my_backup/snapshot_1/_restore
#{
# "indices": "index_1", 
# "rename_pattern": "index_(.+)", 
# "rename_replacement": "restored_index_$1" 
#}
#
## 查看快照恢复信息
#GET snapshot_1/_recovery
#
## 查看集群中的所有索引的恢复信息（可能包含跟您的恢复进程无关的其他分片的恢复信息）。
#GET /_recovery/
#
## 取消快照恢复
#DELETE /snapshot_1

```










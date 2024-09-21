# 等保3



## 1. 增加用户auditadmin、sysadmin

```bash
# 增加用户auditadmin、sysadmin
useradd -r -s /sbin/nologin auditadmin && usermod -L auditadmin && useradd -r -s /sbin/nologin sysadmin && usermod -L sysadmin ;id auditadmin;id sysadmin
```




## 2. 配置口令约束
```bash
## 配置步骤一：
# Centos7
$ vim /etc/pam.d/system-auth
password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 difok=5 enforce_for_root

# Ubuntu18
$ vim /etc/pam.d/common-password
password        requisite                       pam_cracklib.so retry=3 minlen=8 difok=5 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root


## 配置步骤二：
$ vim /etc/login.defs
# 密码最长过期天数
PASS_MAX_DAYS 180 　
# 密码最小过期天数　
PASS_MIN_DAYS 0 　
# 密码最小长度　　
PASS_MIN_LEN 8 　
#密码过期警告天数　　　
PASS_WARN_AGE 15


## 检验配置
grep PASS_ /etc/login.defs; grep "password    requisite     pam_pwquality.so" /etc/pam.d/system-auth || grep "password        requisite                       pam_cracklib.so" /etc/pam.d/common-password
```
>retry=3 允许重试3次。
>difok=5 默认值为8。这个参数设置允许的新、旧密码相同字符的个数。
>minlen=8 密码最小8位。
>ucredit=-1 密码包含大写字母至少1位。
>lcredit=-1 密码包含小写字母至少1位。
>dcredit=-1 密码包含数字至少1位。
>ocrdit=-1 密码包含特殊字符至少1位。
>local_users_only 这个参数用于指定只有本地用户才会受到密码策略的约束。网络用户或非本地用户将不受这些限制。
>authtok_type= 该参数用于指定要检验的密码类型。一般情况下，这个参数不是很常用，可以忽略。
>enforce_for_root 确保即使是root用户设置密码，也应强制执行复杂性策略。 










## 3. sqlserver
属性 - 安全性 - 登录审核 - 失败和成功的登录(需要开启)
属性 - 安全性 - 选项 - 符合通用标准符合性(需要开启)

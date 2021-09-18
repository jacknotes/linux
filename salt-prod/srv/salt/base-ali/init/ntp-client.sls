ntpdate-install:
  pkg.installed:
    - name: ntpdate

TimeZone:
  timezone.system:
    - name: Asia/Shanghai

cron-ntpdate:
  cron.present:
    - name: ntpdate time1.aliyun.com
    - user: root
    - minute: '*/5'

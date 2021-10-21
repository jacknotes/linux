ntpdate-install:
  pkg.installed:
    - name: ntpdate

TimeZone:
  timezone.system:
    - name: Asia/Shanghai

cron-ntpdate:
  cron.present:
    - name: ntpdate time.hs.com
    - user: root
    - minute: '*/5'

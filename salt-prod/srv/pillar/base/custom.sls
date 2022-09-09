cloud: aliyun

{% if grains['ip4_interfaces']['eth0'][0] == '10.10.10.230' %}
role: master
{% else %}
role: minion
{% endif %}



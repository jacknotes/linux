{% if grains['fqdn'] == 'node2' %}
type: docker_server
{% elif grains['fqdn_ip4'][0] == '192.168.15.202' %}
type: docker_server
{% endif %}

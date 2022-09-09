nfsd:
  pkg.installed:
    - names:
      - nfs-utils
      - rpcbind
  cmd.run:
    - name: mkdir -p /backup && chmod -R 777 /backup && chown -R 1000:1000 /backup 
    - unless: test -d /backup

nfsd-config:
  file.managed:
    - name: /etc/exports
    - source: salt://nfsd/files/exports
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nfsd

rpcbind-service:
  service.running:
    - name: rpcbind
    - enable: True
    - require:
      - pkg: nfsd

nfs-service:
  service.running:
    - name: nfs
    - enable: True
    - require:
      - pkg: nfsd

nfsd-end:
  cmd.run: 
    - name: exportfs -arv
    - require:
      - service: rpcbind-service
      - service: nfs-service
    - watch:
      - file: nfsd-config

nfsd:
  pkg.installed:
    - names:
      - nfs-utils
      - rpcbind
  cmd.run:
    - name: echo '/backup	*(rw,async)' >> /etc/exports && mkdir -p /backup && chown -R 1000:1000 /backup 
    - unless: test -d /backup

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

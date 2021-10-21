#require sysctl.sls
enable-ipvs-modules:
  file.managed:
    - name: //etc/sysconfig/modules/ipvs.modules
    - source: salt://init/files/ipvs.modules
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: bash /etc/sysconfig/modules/ipvs.modules
    - unless: lsmod | grep -e ip_vs
  pkg.installed:
    - pkgs:
      - ipset
      - ipvsadm


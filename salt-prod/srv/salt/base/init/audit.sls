/etc/profile.d/audit.sh:
  cmd.run:
    - name: touch /var/log/audit.log && chmod 666 /var/log/audit.log
    - unless: test -w /var/log/audit.log
  file.append:
    - text:
      - export PROMPT_COMMAND='{ date "+%Y-%m-%d %T %A [$(id | cut -c 1-11)]:[$(who am i |awk "{print \$2\" \"\$3\" \"\$4\" \"\$5}")]:[$(pwd)]:[$(history 1 | { read a b c d e; echo $e;})]"; } >> ~/.audit.log'

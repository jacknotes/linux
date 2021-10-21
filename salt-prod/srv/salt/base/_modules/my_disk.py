def list():
    cmd = 'df -h'
    ret = __salt__['cmd.run'](cmd)
    return ret

redis master,slave mode
在sentinal模式下，redis配置文件中replica-priority，优先级越小越有可能成为master。
在sentinal配置文件中，这个表示当master死掉之后过多少秒切换到新master:sentinel down-after-milliseconds mymaster 15000

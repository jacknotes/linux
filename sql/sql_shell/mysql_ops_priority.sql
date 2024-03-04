-- 查看进程列表
show processlist;
-- 查看进程列表，通过条件筛选
SELECT id,db,info FROM INFORMATION_SCHEMA.PROCESSLIST 
where db='czndc' and info !='';

-- 查看当前使用的表
show OPEN TABLES where In_use > 0;

-- kill进程
-- kill 964702

-- 查看innodb事务ID
select * from INFORMATION_SCHEMA.INNODB_TRX

-- 查看innodb当前状态
show engine innodb status;

-- 查看innode锁、等待锁
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS; 
SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS; 

-- 查看当前表状态及行锁状态
show status like 'table%';
show status like 'InnoDB_row_lock%';

-- 查看告警信息
show WARNINGS;
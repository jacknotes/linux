 USE master
 GO


-- 查看死锁
EXEC [dbo].[sp_who_lock_TMP]

--KILL 301



-- 查看数据库名称
SELECT DB_NAME(7)


-- 查看当前系统会话数01
SELECT COUNT(*) FROM sys.[sysprocesses] WHERE [spid]>50 
--AND DB_NAME([dbid])='gposdb'

SELECT spid,hostname,loginame,dbid,uid,cpu,physical_io,memusage,login_time,last_batch,status,program_name,cmd
FROM sys.[sysprocesses] WHERE [spid]>50 
--AND DB_NAME([dbid])='gposdb'
ORDER BY cpu DESC


-- 查看当前系统会话数02
SELECT COUNT(*) FROM [sys].[dm_exec_sessions] WHERE [session_id]>50

SELECT session_id,host_name,login_name,cpu_time,memory_usage,total_scheduled_time,total_elapsed_time,reads,writes,logical_reads,status 
FROM [sys].[dm_exec_sessions] WHERE [session_id]>50 
ORDER BY cpu_time DESC


-- 查看Top 10最耗CPU时间的会话
SELECT TOP 10
[session_id],
[request_id],
[start_time] AS '开始时间',
[status] AS '状态',
[command] AS '命令',
dest.[text] AS 'sql语句', 
DB_NAME([database_id]) AS '数据库名',
[blocking_session_id] AS '正在阻塞其他会话的会话ID',
[wait_type] AS '等待资源类型',
[wait_time] AS '等待时间',
[wait_resource] AS '等待的资源',
[reads] AS '物理读次数',
[writes] AS '写次数',
[logical_reads] AS '逻辑读次数',
[row_count] AS '返回结果行数'
FROM sys.[dm_exec_requests] AS der 
CROSS APPLY 
sys.[dm_exec_sql_text](der.[sql_handle]) AS dest 
WHERE [session_id]>50-- AND DB_NAME(der.[database_id])='topway'  
ORDER BY [cpu_time] DESC


--查看CPU数和user scheduler数目
SELECT cpu_count,scheduler_count FROM sys.dm_os_sys_info
--查看最大工作线程数
SELECT max_workers_count FROM sys.dm_os_sys_info


-- 查看worker是否用完，如果达到最大线程数的时候需要检查blocking
SELECT
scheduler_address,
scheduler_id,
cpu_id,
status,
current_tasks_count,
current_workers_count,active_workers_count
FROM sys.dm_os_schedulers

SELECT sum(current_workers_count) FROM sys.dm_os_schedulers

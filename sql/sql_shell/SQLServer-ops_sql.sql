 USE master
 GO


-- �鿴����
EXEC [dbo].[sp_who_lock_TMP]

--KILL 301



-- �鿴���ݿ�����
SELECT DB_NAME(7)


-- �鿴��ǰϵͳ�Ự��01
SELECT COUNT(*) FROM sys.[sysprocesses] WHERE [spid]>50 
--AND DB_NAME([dbid])='gposdb'

SELECT spid,hostname,loginame,dbid,uid,cpu,physical_io,memusage,login_time,last_batch,status,program_name,cmd
FROM sys.[sysprocesses] WHERE [spid]>50 
--AND DB_NAME([dbid])='gposdb'
ORDER BY cpu DESC


-- �鿴��ǰϵͳ�Ự��02
SELECT COUNT(*) FROM [sys].[dm_exec_sessions] WHERE [session_id]>50

SELECT session_id,host_name,login_name,cpu_time,memory_usage,total_scheduled_time,total_elapsed_time,reads,writes,logical_reads,status 
FROM [sys].[dm_exec_sessions] WHERE [session_id]>50 
ORDER BY cpu_time DESC


-- �鿴Top 10���CPUʱ��ĻỰ
SELECT TOP 10
[session_id],
[request_id],
[start_time] AS '��ʼʱ��',
[status] AS '״̬',
[command] AS '����',
dest.[text] AS 'sql���', 
DB_NAME([database_id]) AS '���ݿ���',
[blocking_session_id] AS '�������������Ự�ĻỰID',
[wait_type] AS '�ȴ���Դ����',
[wait_time] AS '�ȴ�ʱ��',
[wait_resource] AS '�ȴ�����Դ',
[reads] AS '���������',
[writes] AS 'д����',
[logical_reads] AS '�߼�������',
[row_count] AS '���ؽ������'
FROM sys.[dm_exec_requests] AS der 
CROSS APPLY 
sys.[dm_exec_sql_text](der.[sql_handle]) AS dest 
WHERE [session_id]>50-- AND DB_NAME(der.[database_id])='topway'  
ORDER BY [cpu_time] DESC


--�鿴CPU����user scheduler��Ŀ
SELECT cpu_count,scheduler_count FROM sys.dm_os_sys_info
--�鿴������߳���
SELECT max_workers_count FROM sys.dm_os_sys_info


-- �鿴worker�Ƿ����꣬����ﵽ����߳�����ʱ����Ҫ���blocking
SELECT
scheduler_address,
scheduler_id,
cpu_id,
status,
current_tasks_count,
current_workers_count,active_workers_count
FROM sys.dm_os_schedulers

SELECT sum(current_workers_count) FROM sys.dm_os_schedulers

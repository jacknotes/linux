-- aliyun mysql




flush privileges;
-- create database server_job;
-- create user '0829'@'10.10.10.%' IDENTIFIED by 'password';
-- drop user '0829'@'10.10.10.%'


-- product GRANT
-- SELECT DISTINCT CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, REFERENCES ON ','xxl_job.* To ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='program_java';
-- SELECT DISTINCT CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, REFERENCES ON ','interhotelresource_v1.* To ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='commonuser';

-- product REVOKE
-- SELECT DISTINCT CONCAT('REVOKE SELECT, INSERT, UPDATE, DELETE, CREATE, REFERENCES ON ','hotelresource_redafterburner.* From ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='commonuser';





-- select user,host,account_locked from mysql.user where user like 'prod-dbuser%'
-- show grants for 'prod-dbuser'@'%'
-- show grants for 'program_java'@'10.10.10.%'
-- show grants for 'commonuser'@'%'
-- show grants for 'admin'@'192.168.13.%'
-- alter user 'prod-dbuser'@'%' account lock;
-- alter user 'prod-dbuser'@'%' account unlock;




-- create user '0931'@'192.168.10.%' IDENTIFIED by 'password';



-- local product mysql

-- product GRANT
-- SELECT DISTINCT CONCAT('GRANT SELECT ON ','dingtalk_selfbuilt.* To ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='0851';

-- product REVOKE
-- SELECT DISTINCT CONCAT('REVOKE SELECT ON ','jointlogin.* From ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='0790';


-- GRANT SELECT ON email_sms_tmpl.* To '0894'@'192.168.10.%' identified by 'password';

-- GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON *.* TO 'prod-dbuser'@'192.168.13.103'

-- -- local SQL 
-- create user 'xxljob'@'%' identified by 'xxl@job';
-- drop user '0933'@'192.168.10.%'
-- set password for 'xxljob'@'%'=password('l5RXXpxeYKSRGw6ctSS0gZLqzDFB1345');
-- update mysql.user set authentication_string=password('password') where user=0889 and host='172.168.2.%'

-- -- select full username
-- SELECT DISTINCT CONCAT('''',user,'''@''',host,'''') AS full_username FROM mysql.user where user='0869' order by user;
-- SELECT DISTINCT CONCAT('show grants for ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user order by user;

-- show grants for 'commonuser'@'192.168.13.%';
-- show grants for 'program_java'@'192.168.13.%';
-- show grants for '0869'@'192.168.10.%'
-- show grants for '0851'@'192.168.10.%'




-- create database if not exists interhotelresource_expedia ;

-- product GRANT
-- SELECT DISTINCT CONCAT('GRANT SELECT ON ','pay_wallet.* To ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='0894';
-- product REVOKE
-- SELECT DISTINCT CONCAT('REVOKE SELECT ON ','weixin_work_thirdparty.* From ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='0790';


-- select user,host,account_locked from mysql.user where user like 'prod-dbuser%';
-- show grants for '0906'@'172.168.2.%';
-- alter user 'prod-dbuser'@'192.168.13.103' account lock;
-- alter user 'prod-dbuser'@'192.168.13.103' account unlock;

-- show grants for 'xxljob'@'192.168.13.%';


-- SELECT DISTINCT CONCAT('''',user,'''@''',host,'''',';') AS full_username FROM mysql.user









-- create user '0970'@'192.168.10.%' identified by 'password';

-- dev,uat GRANT
-- SELECT DISTINCT CONCAT('GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER ON ','`weixin_custom_app`.* To ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user in ('0848')
-- dev,uat REVOKE
-- SELECT DISTINCT CONCAT('REVOKE SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, REFERENCES, INDEX, ALTER ON ','`travel_account`.* From ','''',user,'''@''',host,'''',';') AS full_username FROM mysql.user where user='0894';








-- -- select custom user privileges
-- show grants for '0925'@'192.168.10.%';
-- REVOKE SELECT ON `train_huade`.* FROM '0861'@'192.168.10.%'

-- -- show databases
-- show databases
-- select database()


-- show user info 
-- select USER,HOST,authentication_string from mysql.user order by user;
-- alter user commonuser@'192.168.13.%' identified by 'password'

-- create user '0894'@'192.168.10.%' IDENTIFIED by 'password';
-- update mysql.user set authentication_string=password('password') where user='0848' and host='192.168.10.%'


-- -- show user lock status
-- select user,host,account_locked from mysql.user where user like '0%' and account_locked='N';
-- select user,host,account_locked from mysql.user where account_locked='N';

-- -- disable user
-- SELECT DISTINCT CONCAT('alter user ','''',user,'''@''',host,'''',' account lock;') AS full_username FROM mysql.user where user != '0799' and
-- user like '0%'  and user not in ('0799','0046','0050','0628','0639')
-- user like '0%' and account_locked='N' ;
-- -- alter user 'commonuser'@'%' account lock;

-- -- enable user
-- SELECT DISTINCT CONCAT('alter user ','''',user,'''@''',host,'''',' account unlock;') AS full_username FROM mysql.user where 
-- user like '0%'  and user not in ('0799','0046','0050','0628','0639')
-- user='0894';

-- show grants for '0050'@'172.168.2.%'

-- alter user ''@'172.168.2.%' account lock;
-- alter user ''@'172.168.2.%' account unlock;
-- alter user '0790'@'192.168.10.%' account lock;
-- alter user '0790'@'192.168.10.%' account unlock;

flush PRIVILEGES








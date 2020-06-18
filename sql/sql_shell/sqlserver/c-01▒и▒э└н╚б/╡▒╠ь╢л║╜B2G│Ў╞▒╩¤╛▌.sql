select COUNT(1) as p2
from 
OPENROWSET('SQLNCLI10','Server=connlog;Database=log20170801;Trusted_Connection=yes',log20170801.dbo.log) AS a
where Resource='MUB2G运价查询' and CreateTime>=cast(convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120) as datetime) and CreateTime<cast(convert(varchar(10),DATEADD(DAY,-0,GETDATE()),120) as datetime)


select COUNT(1) as p1
from Topway..tbcash 
where datetime= cast(convert(varchar(10),DATEADD(DAY,-1,GETDATE()),120) as datetime) and inf=0 
and t_source like '%官网东航%'
and oper0='自动录入'




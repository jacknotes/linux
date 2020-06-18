select indate,cmpid,cmptype,cmpname,(case hztype when '1' then '正常合作正常月结' when '2' then '正常合作仅限现结' else '' end) as hztype 
from Topway..tbCompanyM 
where indate<'1990-01-01' and hztype>0 and hztype<4

select indate,cmpid,cmptype,cmpname,(case hztype when '1' then '正常合作正常月结' when '2' then '正常合作仅限现结' else '' end) as hztype 
from Topway..tbCompanyM 
update Topway..tbCompanyM set indate='2012-07-01'
where cmpid='006596' 
update Topway..tbCompanyM set indate='2013-06-07'
where cmpid='013174' 
update Topway..tbCompanyM set indate='2013-05-18'
where cmpid='014539' 
update Topway..tbCompanyM set indate='2012-08-01'
where cmpid='016087' 
update Topway..tbCompanyM set indate='2013-06-07'
where cmpid='016213' 
update Topway..tbCompanyM set indate='2013-04-27'
where cmpid='017950' 
update Topway..tbCompanyM set indate='2014-05-05'
where cmpid='018655'
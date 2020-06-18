--匹配单位名称和差旅顾问
select 'UC'+Cmpid,UN.Name, S.Name
from homsomDB..Trv_UnitCompanies un
left join homsomDB..Trv_TktUnitCompanies_TktTCs t on t.TktUnitCompanyID=un.ID
left join homsomDB..SSO_Users s on s.ID=t.TktTCID
where Cmpid in ('020561',
'019901',
'020432',
'019643',
'020155',
'016258',
'018296',
'020586',
'018480',
'016701',
'017740',
'020656',
'020180',
'020698',
'019771',
'018482',
'020315',
'020497',
'020324',
'020560',
'020052',
'020565',
'020157',
'020425',
'020372',
'020266',
'016720',
'020552',
'020675',
'020096',
'020191',
'020335')


--结算单数据恢复
select * from Topway..tbcash 
where settleno='11178'



--机票业务顾问信息
select SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='周琦'
where coupno ='AS001633974'

--财务修改未核销
select dzhxDate,status,oper2,opernum,* from Topway..tbcash 
--update Topway..tbcash  set dzhxDate='1900-01-01',oper2='',opernum=0
where coupno='AS002464319'

/*
提取国际自签三方，产品系统中维护的三方协议后信息，谢谢
 
  报表格式：  UC号、单位名称、航司2字码 、三方协议号中的内容 
*/

select t.CmpId,un.Name,AirCompany,SfxyInfo from ehomsom..tbCompanyXY t
left join homsomDB..Trv_UnitCompanies  un on t.CmpId=un.Cmpid
where t.Type=2 
and IsSelfRv=1 
order by t.CmpId


--账单撤销
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019361_20190401'


--火车票销售单作废
select * 
--delete
from Topway..tbTrainTicketInfo where CoupNo in ('RS000023782','RS000023783','RS000023784')

select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in (select ID from Topway..tbTrainTicketInfo 
where CoupNo in ('RS000023782','RS000023783','RS000023784'))


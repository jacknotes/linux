--ƥ�䵥λ���ƺͲ��ù���
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


--���㵥���ݻָ�
select * from Topway..tbcash 
where settleno='11178'



--��Ʊҵ�������Ϣ
select SpareTC,* from Topway..tbcash 
--update Topway..tbcash set SpareTC='����'
where coupno ='AS001633974'

--�����޸�δ����
select dzhxDate,status,oper2,opernum,* from Topway..tbcash 
--update Topway..tbcash  set dzhxDate='1900-01-01',oper2='',opernum=0
where coupno='AS002464319'

/*
��ȡ������ǩ��������Ʒϵͳ��ά��������Э�����Ϣ��лл
 
  �����ʽ��  UC�š���λ���ơ���˾2���� ������Э����е����� 
*/

select t.CmpId,un.Name,AirCompany,SfxyInfo from ehomsom..tbCompanyXY t
left join homsomDB..Trv_UnitCompanies  un on t.CmpId=un.Cmpid
where t.Type=2 
and IsSelfRv=1 
order by t.CmpId


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement set SubmitState=1
where BillNumber='019361_20190401'


--��Ʊ���۵�����
select * 
--delete
from Topway..tbTrainTicketInfo where CoupNo in ('RS000023782','RS000023783','RS000023784')

select * 
--delete
from Topway..tbTrainUser where TrainTicketNo in (select ID from Topway..tbTrainTicketInfo 
where CoupNo in ('RS000023782','RS000023783','RS000023784'))


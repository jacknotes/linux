/*��Ʊ����2018.7.1-2019.6.9�����ڻ�Ʊ����ƾ֤ĿǰΪ����Ʊ���������ˡ�FM MU�������ݡ�
��Ҫ�ֶΣ�UC�š�������������������ѽ���Ʊ���������������/���������İٷֱȣ������ֶ������иߵ��ͣ�
*/

select cmpcode UC��,SUM(totprice) ��������,SUM(originalprice-price) ��������ѽ��,COUNT(1 )��Ʊ����
from Topway..tbcash c
left join homsomDB..Trv_UnitCompanies un on un.Cmpid=c.cmpcode
where CertificateD=2
and inf=0
and ride in('FM','mu')
and datetime>='2018-07-01'
and datetime<'2019-06-10'
--and tickettype='����Ʊ'
group by cmpcode
order by ��������


/*UC019707
 UC016682
 �޸�������
 */
 select depdate0,indate,Cmpid,* from Topway..tbCompanyM 
 --update Topway..tbCompanyM  set depdate0='2019-06-01'
 where cmpid in('019707')
 
 select AdditionMonthA,RegisterMonth,Cmpid,* from homsomDB..Trv_UnitCompanies 
 --update homsomDB..Trv_UnitCompanies  set AdditionMonthA='2019-06-01'
 where Cmpid in('019707')
 

--UC020543  �Ϻ����ࣨ���ţ����޹�˾ �¾���������������ǰ�æ�����̧ͷ��2019��1-5�µ��˵�����������ߵ�ģ�������벢�ύ����


select convert(varchar(10),datetime,120) ��Ʊʱ��,convert(varchar(10),begdate,120)  ���ʱ��,Department,isnull(co.DepName,'') ����,DATEDIFF(DD,datetime,begdate)��ǰ��Ʊ����,pasname �˻���,route �г�,ride+flightno ����� 
,tcode+ticketno Ʊ��,priceinfo,'' �ۿ���,price ���۵���,tax ˰��,fuprice �����,totprice ���ۼ�,reti ��Ʊ����,tickettype ����
from Topway..tbcash c with (nolock)
left join homsomDB..Trv_Human h on (h.Name=pasname or h.LastName+'/'+h.FirstName+h.MiddleName=pasname) and h.ID in(Select id from homsomDB..Trv_UnitPersons where CompanyID='D4FEB10C-36BC-4E43-B99D-A94A010FE8A0')
left join homsomDB..Trv_UnitPersons u on u.ID =h.ID
left join homsomDB..Trv_CompanyStructure co on co.ID=u.CompanyDptId
where ModifyBillNumber in('020543_20190101','020543_20190201','020543_20190301','020543_20190401','020543_20190501')
order by ��Ʊʱ��

/*
UC020543�Ϻ����ࣨ���ţ����޹�˾  _20180901--20190501 
�� MU/FM���գ����۵��š�Ʊ�š���Ʊ���ڣ�������ڣ���λ���룬�˿�����������ţ���·�����۵��ۣ�˰�գ������ܼۣ�����ѡ�ȫ�ۡ� ԭ�ۡ��ۿ�

�ڳ�MU/FM ����ͬ���ϡ�
*/
select coupno ���۵���,tcode+ticketno Ʊ��,convert(varchar(10),datetime,120) ��Ʊʱ��,convert(varchar(10),begdate,120)  ���ʱ��,nclass ��λ����,
pasname �˿�����,route ��·,price ���۵���,tax ˰��,totprice �����ܼ�,fuprice �����,priceinfo ȫ��,originalprice ԭ��,'' �ۿ���,reti ��Ʊ����,tickettype ����
from Topway..tbcash 
where cmpcode='020543'
and datetime>='2018-09-01'
and datetime<'2019-05-01'
and ride in ('mu','fm')
order by ��Ʊʱ��

select coupno ���۵���,tcode+ticketno Ʊ��,convert(varchar(10),datetime,120) ��Ʊʱ��,convert(varchar(10),begdate,120)  ���ʱ��,nclass ��λ����,
pasname �˿�����,route ��·,price ���۵���,tax ˰��,totprice �����ܼ�,fuprice �����,priceinfo ȫ��,originalprice ԭ��,'' �ۿ���,reti ��Ʊ����,tickettype ����
from Topway..tbcash 
where cmpcode='020543'
and datetime>='2018-09-01'
and datetime<'2019-05-01'
and ride not in ('mu','fm')
order by ��Ʊʱ��

--�޸���Ʊ�������
select ExamineDate,* from Topway..tbReti 
--update Topway..tbReti  set ExamineDate='2019-05-29'
where reno='9267103'

--�г̵�
SELECT info3,* from  Topway..tbcash 
--update Topway..tbcash  set info3='���ӡ�г̵�'
where coupno='AS002488145'


select ProccessDate,*
from HM_rptSalesNewlyProfit where Cmpid='019707'

--�Ƶ���㵥����
select  settleStatus,pstatus,prdate,* from Topway..tbHtlSettlementApp 
--update Topway..tbHtlSettlementApp  set settleStatus=3
where  id='25960'

select settleno,pstatus,prdate,status2,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf  set settleno=null,status2=0
where settleno='25960'


--��Ʊ���㵥����
select settleStatus,* from topway..tbSettlementApp
--update topway..tbSettlementApp set settleStatus='3' 
where id='112934'

select wstatus,settleno,* from Topway..tbcash 
--update Topway..tbcash  set wstatus='0',settleno='0' 
where settleno='112934'

select Status,* from Topway..Tab_WF_Instance
--update Tab_WF_Instance set Status='4' 
where BusinessID='112934'


/*
���æ��ȡ2017��2��-2019��2�£��������ù��������ڵĸ��˿ͻ���Ϣ��

��Ҫ��ϸ�����˿ͻ��������ֻ��ţ��������ۼۺϼƣ���������ϼƣ��������ۼۺϼƣ���������ϼ�
*/

select top 100 * from homsomDB..Trv_DomesticTicketRecord
select top 100 * from homsomDB..Trv_PnrInfos
select top 100 * from homsomDB..Trv_Passengers
select * from Topway..tbCusmem

select pasname,sum(totprice) �������ۼۺϼ�,SUM(profit) ��������ϼ�
from Topway..tbcash 
where SpareTC='����'
and datetime>='2017-02-01'
and datetime<'2019-03-01'
and inf=1
and cmpcode=''
group by pasname


select pasname,mobile,sum(totprice) �������ۼۺϼ�,SUM(profit) ��������ϼ�
from Topway..tbcash c
left join Topway..tbCusmem t on t.idno=c.idno and name=pasname 
where SpareTC='����'
and datetime>='2017-02-01'
and datetime<'2019-03-01'
and inf=1
and cmpcode=''
group by pasname,mobile


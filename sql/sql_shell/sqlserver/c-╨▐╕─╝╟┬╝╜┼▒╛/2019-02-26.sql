--�޸������տ��������
select dzHxDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set dzHxDate='2019-02-22'
where TrvId='29606' and Id='227047'

--����������
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=2072,profit=112
where coupno='AS002266755'

--�޸Ĺ�Ӧ����Դ
select t_source,* from Topway..tbcash  
--update Topway..tbcash  set t_source='ZSBSPETI'
where coupno='AS002253266'

select * from Topway..tbcash c
left join Topway..tbCompanyM m on m.cmpid=c.cmpcode
left join Topway..tbCusholder m1 on m1.

--�ؿ���ӡ

select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus=0
where TrvId='029591'


select SUM(profitcompensation) from Topway..tbTrvCoup where OperDate>='2017-01-01' and OperDate<'2019-01-01'

--ɾ��Ա���ű�
--TMS
select * from homsomDB..Trv_Human 
--update homsomDB..Trv_Human set IsDisplay=0
where ID in (
select a.ID from homsomDB..Trv_Human a
inner join homsomDB..Trv_UnitPersons b on a.ID=b.ID
where b.CompanyID=(select ID from homsomDB..Trv_UnitCompanies where Cmpid='018163')
and IsDisplay=1 and Name not in ('½����','���','��ع��','���ǿ','������','����','�ܽ�'))

--ERPɾ��������Ϣ
select * from Topway..tbCusholderM where cmpid='018163' and custname not in('½����','���','��ع��','���ǿ','������','����','�ܽ�')
delete from Topway..tbCusholderM where cmpid='018163'  and custname not in('½����','���','��ع��','���ǿ','������','����','�ܽ�')  and id between 167283 and 167305
--delete from Topway..tbCusholderM where cmpid='018163' and custname not in('½����','���','��ع��','���ǿ','������','����','�ܽ�')

--TMS���ÿ͵���ERP
insert into tbcusholderM(cmpid,custid,ccustid,custname,custtype1,male,username,phone,mobilephone,personemail,CardId,custtype,homeadd,joindate) 
select cmpid,CustID,CustID,h.Name,
CASE
WHEN u.Type='��ͨԱ��' THEN ''
WHEN u.Type='������' THEN '3'
WHEN u.Type='������' THEN '4'
WHEN u.Type='�߹�' THEN '5'
ELSE 2 end,
CASE 
WHEN h.Gender=1 THEN '��'
WHEN h.Gender=0 THEN 'Ů'
ELSE '��' end
,'',h.Telephone,h.Mobile,h.Email,'',u.CustomerType,'�ֹ���������' ,h.CreateDate
FROM homsomDB..Trv_UnitPersons u
INNER JOIN homsomDB..Trv_Human h ON u.id =h.ID
INNER JOIN homsomDB..Trv_UnitCompanies c ON u.CompanyID=c.ID
WHERE Cmpid='018163' AND h.IsDisplay=1 and h.Name not in ('½����','���','��ع��','���ǿ','������','����','�ܽ�')

select custid from Topway..tbcash where cmpcode='018919' group by custid
select CustId from topway..tbTrvCoup where CmpId='018919' group by CustId

--��Ʊҵ�������Ϣ
select sales,SpareTC,* from Topway..tbcash 
--update Topway..tbcash set sales='��ޱ',SpareTC='��ޱ'
where coupno='AS001447710'


--����۲�����
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash  set totsprice=6866,profit=478
where coupno='AS002262985'
select totsprice,profit,* from Topway..tbcash 
--update Topway..tbcash set totsprice=2267,profit=1031
where coupno='AS002265405'

--��˾����
select * from ehomsom..tbInfAirCompany where code2='mu'

--�޸��ʽ�����
select Mcost,* from Topway..tbcash 
--update Topway..tbcash set Mcost=0
where coupno in('AS002257180','AS002257215')

select Mcost,* from Topway..tbcash 
--update Topway..tbcash set Mcost=0
where coupno='AS002257312'

--�ؿ���ӡ
select PrDate,Pstatus,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk set PrDate='1900-01-01',Pstatus=0
where TrvId='29627'

--��Ʊ����
--����
--select cmpid, * from Topway..tbCompanyM where cmpname like 'ŷ�ݿ˹�ҵ��������޹�˾�Ϻ��ֹ�˾'
select * from Topway..tbcash 
where cmpcode='018487' 
and datetime>='2018-08-01' 
and inf=0 and reti='' 
and tickettype='����Ʊ' 
--and (route like '%����%' or route like '%����%') 
--��Ʊ
select * from Topway..tbReti 
where cmpcode ='018487' 
and datetime>='2018-08-01'
and inf=0 
--��������
select * from Topway..tbcash 
where cmpcode='018487' 
and datetime>='2018-08-01' 
and inf=0 and reti='' 
and (tickettype like'%����%' or tickettype like'%����%')
--����
select * from Topway..tbcash 
where cmpcode='018487' 
and datetime>='2018-08-01' 
and inf=1 and reti='' 
and tickettype='����Ʊ' 
 
 

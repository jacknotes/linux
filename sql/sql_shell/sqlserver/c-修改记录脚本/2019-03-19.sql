--�����տ��Ϣ
select Pstatus,PrDate,totprice,owe,totprice+InvoiceTax,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk set Pstatus=0,PrDate='1900-01-01'
where ConventionId='1403' and Id='2651'

--�ؿ���ӡȨ��
select Pstatus,PrDate,* from Topway..tbTrvKhSk 
--update Topway..tbTrvKhSk  set Pstatus=0,PrDate='1900-01-01'
 where TrvId='029736'
 
 select rtprice,* from Topway..tbReti where reno='0429727'
 select reti,* from Topway..tbcash where coupno='AS002303250'
 
 --��λ�ͻ����Ŷ�ȵ���
 select SX_BaseCreditLine,SX_TomporaryCreditLine,SX_TotalCreditLine,* from Topway..AccountStatement 
 --update Topway..AccountStatement set SX_TotalCreditLine=260000
 where BillNumber='020585_20190301'
 
 --����Ԥ�㵥��Ϣ��λ�ĸ���
 select Cmpid,Custinfo,CustomerType,* from Topway..tbTravelBudget 
 --update  Topway..tbTravelBudget  set Cmpid='',Custinfo='15921532592@���S@@@���S@15921532592@D176763',CustomerType='���˿ͻ�'
 where TrvId='029736'
 select * from Topway..tbTrvKhSk where TrvId='029736'
 select * from Topway..tbTrvJS where TrvId='029736'
 
 SELECT * FROM homsomDB..Trv_Cities
 
 --�˵�����
 select SubmitState,* from Topway..AccountStatement  
 --update  Topway..AccountStatement set SubmitState=1
 where BillNumber='019974_20190201'
 
 --�޸����ۼ���Ϣ
 select price,totprice,owe,amount,* from Topway..tbcash 
 --update Topway..tbcash set price=0,totprice=0,owe=0,amount=0
 where coupno in ('AS002254813','AS002254814')
 
 --�˵�����
 select SubmitState,* from Topway..AccountStatement 
 --update Topway..AccountStatement set SubmitState=1
 where BillNumber='000126_20190201'
 
 --��Ʊҵ�������Ϣ
 select sales,SpareTC,* from Topway..tbcash  
 --update Topway..tbcash set sales='�ν�',SpareTC='�ν�'
 where coupno in ('AS002329545','AS002329552','AS002331249')
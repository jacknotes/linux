--ƥ���λ����

SELECT  coupno,nclass FROM topway..tbcash where coupno in('AS001881594',
'AS001881584',
'AS001881586',
'AS001905163',
'AS001886834',
'AS001924496',
'AS002131798',
'AS002131764',
'AS001879488',
'AS001881562',
'AS001890687',
'AS001892666',
'AS001892668',
'AS001868710',
'AS001892674',
'AS001872872',
'AS001872896',
'AS001915461',
'AS001918210',
'AS001925969',
'AS001920885',
'AS001920887',
'AS001935954',
'AS001953588',
'AS001959233',
'AS001958883',
'AS001973269',
'AS001952463',
'AS001981214',
'AS001981439',
'AS001982191',
'AS002002872',
'AS002013637',
'AS002053790',
'AS002064146',
'AS002071696',
'AS002077647',
'AS002108376',
'AS002071700',
'AS002071700',
'AS001873446',
'AS001872951',
'AS001910716',
'AS001905311',
'AS001872965',
'AS001905561',
'AS001921359',
'AS001900591',
'AS001919800',
'AS001919802',
'AS001987998',
'AS001988012',
'AS002030521',
'AS002051523',
'AS002054479',
'AS002054470',
'AS002092444',
'AS002092396',
'AS002127510',
'AS002127504')

--��������

select coupno as ���۵���,tcode+ticketno as Ʊ��,recno as PNR,begdate as ��������,route as �г�,sales as �������ù��� ,ride as ������
from  Topway..tbcash where datetime>='2018-07-01' and datetime<'2019-01-14' and inf=1 and ride='ca' and (route like'%SYD%' or route like'%MEL%')
order by begdate

--����Ʒ��ר�ã���Ʊ��Ӧ����Դ�����ڣ�
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETD'
where coupno='AS002195146'
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETD'
where coupno='AS002199947'
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002185336'
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002189661'
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002193197'
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETD'
where coupno='AS002192338'
select t_source from topway..tbcash 
--update topway..tbcash set t_source='HSBSPETI'
where coupno='AS002187303'

--���ν��㵥��Ϣ
select SettleStatus,* from  topway..tbTrvSettleApp 
--update topway..tbTrvSettleApp set SettleStatus='3'
where Id='26599'
select Jstatus,settleno,pstatus,Pdatetime,* from topway..tbConventionJS 
--update topway..tbConventionJS  set ='0',settleno='0',pstatus='0',Pdatetime='1900-01-01'
where Settleno='26599'

--�˿ͷֵ�
select Pasname,MobileList,Idno,CostCenter,pcs,Department,BirthPlace,* from tbFiveCoupInfosub 
--update tbFiveCoupInfosub set Idno=Idno+',��,��,��,��,��,��,��,��,��,��',MobileList=MobileList+',-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',CostCenter='-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1',pcs='11',Department='��,��,��,��,��,��,��,��,��,��,��',Pasname=Pasname+',�˿�2,�˿�3,�˿�4,�˿�5,�˿�6,�˿�7,�˿�8,�˿�9,�˿�10,�˿�11',BirthPlace='1982-01-03,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01,1900-01-01'
where FkfiveNo in (select fiveno from tbFiveCoupInfo where CoupNo='AS002206408')

--�Ƶ����۵�����
SELECT price,totprofit,sprice,*  from Topway..tbHtlcoupYf  
--UPDATE Topway..tbHtlcoupYf SET price='-6698',totprofit=0
WHERE CoupNo='-PTW071668'
select price,totprofit ,sprice,* from tbHtlcoupYf where coupno in ('-PTW071668')

--�Ƶ����۵���Ӧ����Դ
select sprice,profitsource,* from Topway..tbHtlcoupYf 
--update Topway..tbHtlcoupYf set profitsource='Ա���渶(�������п�)'
where CoupNo in('PTW074822','PTW074824')

--HSBSP�ĵ�λ�ͻ�ǰ300��BSP��������
select Top 300 t.cmpcode as ��λ���,t2.cmpname as ��λ����,SUM(t.totprice) as ���� from Topway..tbcash t
left join Topway..tbCompanyM t2 on t2.cmpid=t.cmpcode
where t_source like'%HSBSP%' and datetime>='2018-06-01' and datetime<'2019-01-01' and t.cmpcode<>''
group by t.cmpcode,t2.cmpname
order by ���� desc

--�����ˣ���λ

SELECT coupno as ���۵���,tcode+ticketno as Ʊ��,route as �г�,nclass as ��λ,begdate as �׶γ�������,sprice1+sprice2+sprice3+sprice4 as '�ļ���(��˰)' ,sales as ҵ����� from Topway..tbcash 
where begdate>='2018-01-01' and begdate<'2018-04-01' and ride in ('MU','FM') and tickettype ='����Ʊ' and reti='' and totsprice<>0 --and nclass in ('U','F','P','J','C','D','I','Q')
 and inf=1
order by begdate

--��Ʊ��
select pasname,tcode,ticketno,* from tbcash where coupno in ('AS002206408')
update topway..tbcash set pasname='1.CHEN/MIN',tcode='217',ticketno='2327125541' where coupno in ('AS002206408') and pasname='ZHANG/WEIWEI'
update topway..tbcash set pasname='2.CHEN/YU CHEN',tcode='217',ticketno='2327125542' where coupno in ('AS002206408') and pasname='�˿�2'
update topway..tbcash set pasname=' 3.LEE/CHIH HAO',tcode='217',ticketno='2327125543' where coupno in ('AS002206408') and pasname='�˿�3'
update topway..tbcash set pasname='4.LIAO/JUI YANG',tcode='217',ticketno='2327125544' where coupno in ('AS002206408') and pasname='�˿�4'
update topway..tbcash set pasname='5.QIU/SHIMING',tcode='217',ticketno='2327125545' where coupno in ('AS002206408') and pasname='�˿�5'
update topway..tbcash set pasname=' 6.QIU/YULAN',tcode='217',ticketno='2327125546' where coupno in ('AS002206408') and pasname='�˿�6'
update topway..tbcash set pasname='7.SHEN/YAN',tcode='217',ticketno='2327125547' where coupno in ('AS002206408') and pasname='�˿�7'
update topway..tbcash set pasname='8.WU/YUGUAN',tcode='217',ticketno='2327125548' where coupno in ('AS002206408') and pasname='�˿�8'
update topway..tbcash set pasname='9.ZHANG/JIANJIAN',tcode='217',ticketno='2327125549' where coupno in ('AS002206408') and pasname='�˿�9'
update topway..tbcash set pasname='10.ZHANG/QING',tcode='217',ticketno='2327125550' where coupno in ('AS002206408') and pasname='�˿�10'
update topway..tbcash set pasname='11.ZHANG/WEIWEI',tcode='217',ticketno='2327125551' where coupno in ('AS002206408') and pasname='�˿�11'

update topway..tbcash set pasname='LI/TSAITI',tcode='217',ticketno='2327125552' where coupno in ('AS002206409') and pasname='LI/TSAI TI'


--�˵�����
select SubmitState,* from Topway..AccountStatement 
--update Topway..AccountStatement  set SubmitState='1'
where BillNumber='020359_20190101'

--�������ż����������Ϣ������
delete from Topway..tbConventionCoup where ConventionId in ('966','975','980')
select Status,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Status='14'
where ConventionId in ('966','975','980')

delete from Topway..tbConventionCoup where ConventionId in ('1155','1068')
select Status,* from Topway..tbConventionBudget 
--update Topway..tbConventionBudget set Status='14'
where ConventionId in ('1155','1068')


--�����տ��Ϣ
select Skstatus,* from Topway..tbConventionKhSk 
--update Topway..tbConventionKhSk  set Skstatus='2'
where Conventionid in ('1155','1068','966','975','980')

--�޸�UC�ţ��Ƶ꣩

select custid AS �ֻ�Ա���,* from tbCusholderM where cmpid ='020543'
select cmpname AS �ֹ�˾ȫ��,* from tbcompanyM where cmpid ='020543'
select SettleMentManner AS �ֽ��㷽ʽ,* from HM_SetCompanySettleMentManner where CmpId='020543' and Type=1 and Status=1
select newModifyBillNumber AS ���˵���,OriginalBillNumber,cmpid,custid,datetime,* from tbHtlcoupYf where coupno in ('PTW075889','PTW075906','PTW075909')  
select HSLastPaymentDate,* from AccountStatement where CompanyCode='020543' order by BillNumber desc
select cmpid,OriginalBillNumber,NewModifyBillNumber,custid,pform,custinfo,spersoninfo from Topway..tbHtlcoupYf
--update tbHtlcoupYf set cmpid='020543',OriginalBillNumber='020543_20190201',NewModifyBillNumber='020543_20190201',custid='D605872',pform='�½�(����)',custinfo='�Ϻ����ࣨ���ţ����޹�˾|��ѩ��|13681737627|13681737627',spersoninfo='��ѩ��|13681737627||' 
where coupno in ('PTW075889','PTW075906','PTW075909')

--��Ʊ��
select pasname,* from Topway..tbcash where coupno='AS002244520'
update topway..tbcash set pasname='DU/YIXIN',tcode='781',ticketno='2318785313' where coupno in ('AS002244520') and pasname='�˿�0'
update topway..tbcash set pasname='HU/HAOKUN',tcode='781',ticketno='2318785314' where coupno in ('AS002244520') and pasname='�˿�1'
update topway..tbcash set pasname='HUANG/QIANQIAN',tcode='781',ticketno='2318785315' where coupno in ('AS002244520') and pasname='�˿�2'
update topway..tbcash set pasname='LI/QINGXIA',tcode='781',ticketno='2318785316' where coupno in ('AS002244520') and pasname='�˿�3'
update topway..tbcash set pasname='LIN/FAN',tcode='781',ticketno='2318785317' where coupno in ('AS002244520') and pasname='�˿�4'
update topway..tbcash set pasname='LU/YUHE',tcode='781',ticketno='2318785318' where coupno in ('AS002244520') and pasname='�˿�5'
update topway..tbcash set pasname='LUO/MEIFANG',tcode='781',ticketno='2318785319' where coupno in ('AS002244520') and pasname='�˿�6'
update topway..tbcash set pasname='QIAN/LIWEN',tcode='781',ticketno='2318785320' where coupno in ('AS002244520') and pasname='�˿�7'
update topway..tbcash set pasname='SONG/YIPING',tcode='781',ticketno='2318785321' where coupno in ('AS002244520') and pasname='�˿�8'
update topway..tbcash set pasname='WANG/HONGJIA',tcode='781',ticketno='2318785322' where coupno in ('AS002244520') and pasname='�˿�9'
update topway..tbcash set pasname='WU/YINGQI',tcode='781',ticketno='2318785323' where coupno in ('AS002244520') and pasname='�˿�10'
update topway..tbcash set pasname='XIA/WENCHONG',tcode='781',ticketno='2318785324' where coupno in ('AS002244520') and pasname='�˿�11'
update topway..tbcash set pasname='ZHANG/YIKANG',tcode='781',ticketno='2318785325' where coupno in ('AS002244520') and pasname='�˿�12'
update topway..tbcash set pasname='ZHANG/ZEHAO',tcode='781',ticketno='2318785326' where coupno in ('AS002244520') and pasname='�˿�13'
select pasname,* from Topway..tbcash where coupno='AS002244656'
update topway..tbcash set pasname='CHEN/YI',tcode='781',ticketno='2318786091' where coupno in ('AS002244656') and pasname='�˿�0'
update topway..tbcash set pasname='HAN/SONG',tcode='781',ticketno='2318786092' where coupno in ('AS002244656') and pasname='�˿�1'
update topway..tbcash set pasname='HUANG/TIAN',tcode='781',ticketno='2318786093' where coupno in ('AS002244655')
update topway..tbcash set pasname='JI/WENJING',tcode='781',ticketno='2318786094' where coupno in ('AS002244656') and pasname='�˿�2'
update topway..tbcash set pasname='JIA/ZHIWEN',tcode='781',ticketno='2318786095' where coupno in ('AS002244656') and pasname='�˿�3'
update topway..tbcash set pasname='LIN/MENGJIAO',tcode='781',ticketno='2318786096' where coupno in ('AS002244656') and pasname='�˿�4'
update topway..tbcash set pasname='LU/YAO',tcode='781',ticketno='2318786097' where coupno in ('AS002244656') and pasname='�˿�5'
update topway..tbcash set pasname='SHAO/JING',tcode='781',ticketno='2318786098' where coupno in ('AS002244656') and pasname='�˿�6'
update topway..tbcash set pasname='SHIMAHARA/MASAKIYO',tcode='781',ticketno='2318786099' where coupno in ('AS002244656') and pasname='�˿�7'
update topway..tbcash set pasname='SHIMAHARA/SAORI',tcode='781',ticketno='2318786100' where coupno in ('AS002244656') and pasname='�˿�8'
update topway..tbcash set pasname='SUN/YAFEI',tcode='781',ticketno='2318786102' where coupno in ('AS002244656') and pasname='�˿�9'
update topway..tbcash set pasname='TAN/JIAFENG',tcode='781',ticketno='2318786103' where coupno in ('AS002244656') and pasname='�˿�10'
update topway..tbcash set pasname='TAN/XUECHUN',tcode='781',ticketno='2318786104' where coupno in ('AS002244656') and pasname='�˿�11'
update topway..tbcash set pasname='WANG/HONGSHENG',tcode='781',ticketno='2318786105' where coupno in ('AS002244656') and pasname='�˿�12'
update topway..tbcash set pasname='WEI/YUANHUA',tcode='781',ticketno='2318786106' where coupno in ('AS002244656') and pasname='�˿�13'
update topway..tbcash set pasname='YANG/XI',tcode='781',ticketno='2318786107' where coupno in ('AS002244656') and pasname='�˿�14'
update topway..tbcash set pasname='YAO/ZHANGFAN',tcode='781',ticketno='2318786108' where coupno in ('AS002244656') and pasname='�˿�15'
update topway..tbcash set pasname='YE/XIAOLEI',tcode='781',ticketno='2318786109' where coupno in ('AS002244656') and pasname='�˿�16'
update topway..tbcash set pasname='YIN/BEI',tcode='781',ticketno='2318786110' where coupno in ('AS002244656') and pasname='�˿�17'
update topway..tbcash set pasname='YU/FANG',tcode='781',ticketno='2318786111' where coupno in ('AS002244656') and pasname='�˿�18'


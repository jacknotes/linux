select datetime as ��Ʊ����,begdate as �������,c.coupno as ���۵���,pasname as �˿�����,c.route as ��·,tair+flightno as �����,tcode+ticketno as Ʊ��,c.tax as ˰��,totprice as  ���ۼ�,reti as ��Ʊ���� 
,(select DepName from homsomdb..Trv_CompanyStructure where ID in (select CompanyDptId from homsomDB..Trv_UnitPersons where ID in (select id from homsomdb..Trv_Human where Name=c.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='019837')))) as ����
,(select name from homsomDB..Trv_CostCenter where ID in (select CostCenterID from homsomDB..Trv_UnitPersons where ID in (select id from homsomdb..Trv_Human where Name=c.pasname and companyid in (select id from homsomDB..Trv_UnitCompanies where Cmpid='019837')))) as �ɱ�����
,tkt.Purpose [����Ŀ��]
from tbcash c
LEFT join homsomDB.dbo.Trv_DomesticTicketRecord rec ON C.coupno=rec.recordNumber 
LEFT JOIN homsomDB..Trv_PnrInfos pnr ON rec.PnrinfoID=pnr.ID
LEFT JOIN homsomDB..Trv_TktBookings tkt ON pnr.ItktBookingID=tkt.ID 
LEFT JOIN homsomDB.dbo.Trv_itktBookings itk ON itk.ID=tkt.id
where cmpcode='019837'
and (datetime>='2017-03-21' and datetime<'2017-09-21')
order by datetime
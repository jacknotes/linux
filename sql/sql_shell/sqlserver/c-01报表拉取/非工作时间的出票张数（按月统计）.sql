--���ڻ�Ʊ
select SpareTC as ����ҵ�����,year(indate) as ��,month(indate) as ��,COUNT(*) as ���� from tbcash where datetime>='2017-03-01' and datetime<'2018-06-01'
and  ((datepart (HOUR,(indate))>18 or  (datepart (HOUR,(indate))=17 and  datepart (MINUTE,(indate))>=45))
or (datepart (HOUR,(indate))<8 or  (datepart (HOUR,(indate))=8 and  datepart (MINUTE,(indate))<45)))
and inf=0
group by SpareTC,year(indate),month(indate)
order by year(indate),month(indate)
--���ʻ�Ʊ
select SpareTC as ����ҵ�����,year(indate) as ��,month(indate) as ��,COUNT(*) as ���� from tbcash where datetime>='2017-03-01' and datetime<'2018-06-01'
and  ((datepart (HOUR,(indate))>18 or  (datepart (HOUR,(indate))=17 and  datepart (MINUTE,(indate))>=45))
or (datepart (HOUR,(indate))<8 or  (datepart (HOUR,(indate))=8 and  datepart (MINUTE,(indate))<45)))
and inf=1
group by SpareTC,year(indate),month(indate)
order by year(indate),month(indate)
--�Ƶ�
select Sales as ����ҵ�����,year(prdate) as ��,month(prdate) as ��,COUNT(*) as ���� from tbHtlcoupYf where prdate>='2017-03-01' and prdate<'2018-06-01'
and  ((datepart (HOUR,(prdate))>18 or  (datepart (HOUR,(prdate))=17 and  datepart (MINUTE,(prdate))>=45))
or (datepart (HOUR,(prdate))<8 or  (datepart (HOUR,(prdate))=8 and  datepart (MINUTE,(prdate))<45)))
group by Sales,year(prdate),month(prdate)
order by year(prdate),month(prdate)
--��Ʊ
select ModifyBy as ����ҵ�����,year(CreateDate) as ��,month(CreateDate) as ��,COUNT(*) as ����  from tbTrainTicketInfo where (CreateDate>='2017-03-01' and CreateDate<'2018-06-01')
and  ((datepart (HOUR,(CreateDate))>18 or  (datepart (HOUR,(CreateDate))=17 and  datepart (MINUTE,(CreateDate))>=45))
or (datepart (HOUR,(CreateDate))<8 or  (datepart (HOUR,(CreateDate))=8 and  datepart (MINUTE,(CreateDate))<45)))
group by ModifyBy,year(CreateDate),month(CreateDate)
order by year(CreateDate),month(CreateDate)
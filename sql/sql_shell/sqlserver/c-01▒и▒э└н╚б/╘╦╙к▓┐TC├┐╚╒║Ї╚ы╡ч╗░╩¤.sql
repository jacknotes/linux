use MyRecSystem
go

SELECT d as [����]
,SUM(CASE WHEN AGENT='107' THEN [�������] ELSE 0 END) AS [�³ػ�]
,SUM(CASE WHEN AGENT='102' THEN [�������] ELSE 0 END) AS [�򴺸�]
,SUM(CASE WHEN AGENT='127' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='136' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='150' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='151' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='153' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='177' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='197' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='198' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='199' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='313' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='128' THEN [�������] ELSE 0 END) AS [Ҧ��]
--��Ʊ�Ƶ�һ��--
,SUM(CASE WHEN AGENT='109' THEN [�������] ELSE 0 END) AS [�ν�]
,SUM(CASE WHEN AGENT='110' THEN [�������] ELSE 0 END) AS [ʩ�۾�]
,SUM(CASE WHEN AGENT='135' THEN [�������] ELSE 0 END) AS [��ѩ÷]
,SUM(CASE WHEN AGENT='137' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='171' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='172' THEN [�������] ELSE 0 END) AS [��ޱ]
,SUM(CASE WHEN AGENT='176' THEN [�������] ELSE 0 END) AS [����Ƽ]
,SUM(CASE WHEN AGENT='178' THEN [�������] ELSE 0 END) AS [���Ͼ�]
,SUM(CASE WHEN AGENT='179' THEN [�������] ELSE 0 END) AS [���໪]
,SUM(CASE WHEN AGENT='180' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='190' THEN [�������] ELSE 0 END) AS [��־ǿ]
,SUM(CASE WHEN AGENT='196' THEN [�������] ELSE 0 END) AS [���ĸ�]
,SUM(CASE WHEN AGENT='119' THEN [�������] ELSE 0 END) AS [���]
--��Ʊ�Ƶ����--
,SUM(CASE WHEN AGENT='101' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='108' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='113' THEN [�������] ELSE 0 END) AS [��ӱ]
,SUM(CASE WHEN AGENT='123' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='125' THEN [�������] ELSE 0 END) AS [���Ʒ�]
,SUM(CASE WHEN AGENT='116' THEN [�������] ELSE 0 END) AS [�߲�]
,SUM(CASE WHEN AGENT='138' THEN [�������] ELSE 0 END) AS [�̾��]
,SUM(CASE WHEN AGENT='155' THEN [�������] ELSE 0 END) AS [�̾���]
,SUM(CASE WHEN AGENT='156' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='162' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='165' THEN [�������] ELSE 0 END) AS [���ջ�]
,SUM(CASE WHEN AGENT='168' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='173' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='200' THEN [�������] ELSE 0 END) AS [��ѩ��]
--��Ʊ�Ƶ�����--
,SUM(CASE WHEN AGENT='105' THEN [�������] ELSE 0 END) AS [��С��]
,SUM(CASE WHEN AGENT='106' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='187' THEN [�������] ELSE 0 END) AS [�ս��F]
,SUM(CASE WHEN AGENT='189' THEN [�������] ELSE 0 END) AS [���Գ�]
,SUM(CASE WHEN AGENT='191' THEN [�������] ELSE 0 END) AS [տ����]
,SUM(CASE WHEN AGENT='193' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='201' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='160' THEN [�������] ELSE 0 END) AS [���˷�]
,SUM(CASE WHEN AGENT='111' THEN [�������] ELSE 0 END) AS [��С��]
--ֵ����--
,SUM(CASE WHEN AGENT='117' THEN [�������] ELSE 0 END) AS [�߽ྲ]
,SUM(CASE WHEN AGENT='333' THEN [�������] ELSE 0 END) AS [����ܿ]
,SUM(CASE WHEN AGENT='334' THEN [�������] ELSE 0 END) AS [��]
,SUM(CASE WHEN AGENT='339' THEN [�������] ELSE 0 END) AS [½����]
,SUM(CASE WHEN AGENT='350' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='351' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='355' THEN [�������] ELSE 0 END) AS [������]
,SUM(CASE WHEN AGENT='358' THEN [�������] ELSE 0 END) AS [�����]
,SUM(CASE WHEN AGENT='360' THEN [�������] ELSE 0 END) AS [�ܽ�]

--���λ�����һ��--
,SUM(CASE WHEN AGENT='331' THEN [�������] ELSE 0 END) AS [���]
,SUM(CASE WHEN AGENT='330' THEN [�������] ELSE 0 END) AS [����]
,SUM(CASE WHEN AGENT='336' THEN [�������] ELSE 0 END) AS [�ܺ���]
,SUM(CASE WHEN AGENT='338' THEN [�������] ELSE 0 END) AS [��Խ]
,SUM(CASE WHEN AGENT='352' THEN [�������] ELSE 0 END) AS [ʷ��]
,SUM(CASE WHEN AGENT='337' THEN [�������] ELSE 0 END) AS [�ܴ���]
,SUM(CASE WHEN AGENT='361' THEN [�������] ELSE 0 END) AS [�ܾ�]
,SUM(CASE WHEN AGENT='363' THEN [�������] ELSE 0 END) AS [�ƺ���]
--���λ��������--

FROM (SELECT convert(nvarchar(10),SYSTEMTIM,120) d,AGENT,COUNT(1) AS [�������]
FROM RecPhone
WHERE SYSTEMTIM between '2015-8-1' and '2015-9-1' and DIRECTION='0' and SECONDS>3
	AND AGENT IN ('107','102','127','136','150','151','153','177','197','198','199','313','128','109','110','135','137','171','172','176','178','179','180','190','196','119','101','108','113','123','125','116','138','155','156','162','165','168','173','200','105','106','187','189','191','193','201','160','111','117','333','334','339','350','351','355','358','360','331','330','336','338','352','337','361','363')
GROUP BY convert(nvarchar(10),SYSTEMTIM,120),AGENT)t
GROUP BY d
ORDER BY d
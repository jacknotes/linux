select coupno as ÏúÊÛµ¥ºÅ,tcode as Æ±ºÅÇ°ÈıÎ»,ticketno as Æ±ºÅºóÊ®Î»,pasname as ³Ë¿ÍĞÕÃû,idno as Ö¤¼şºÅ,cmpcode as µ¥Î»±àºÅ,route as º½³Ì,nclass as ²ÕÎ»,flightno as º½°àºÅ,sales as ËùÊôÒµÎñ¹ËÎÊ from tbcash
where tair='CZ' 
and datetime>='2016-09-01' and datetime<'2016-10-01'
and (route like '%ÆÖ¶«-ÉòÑô%' 
or route like '%ÆÖ¶«-¹ş¶û±õ%' 
or route like '%ÆÖ¶«-´óÁ¬%'
or route like '%ÆÖ¶«-Îäºº%'
or route like '%ÆÖ¶«-³¤É³%'
or route like '%ÆÖ¶«-Ö£Öİ%'
or route like '%ºçÇÅ-ÉòÑô%' 
or route like '%ºçÇÅ-¹ş¶û±õ%' 
or route like '%ºçÇÅ-´óÁ¬%'
or route like '%ºçÇÅ-Îäºº%'
or route like '%ºçÇÅ-³¤É³%'
or route like '%ºçÇÅ-Ö£Öİ%')
order by coupno


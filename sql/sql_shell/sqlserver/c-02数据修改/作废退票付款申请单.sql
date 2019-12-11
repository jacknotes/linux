select * from topway..HM_tbReti_tbReFundPayMent where Id='703551'

update topway..HM_tbReti_tbReFundPayMent set Status='4' where Id='703551'

select * from topway..tbReti where PayMentNo='703551'

update topway..tbReti set PayMentNo='0',status2='2' where PayMentNo='703551'
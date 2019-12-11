--退票付款单修改/作废
select Status,* from Topway..HM_tbReti_tbReFundPayMent 
--update Topway..HM_tbReti_tbReFundPayMent set Status=4
where Id='703781'

select status2,* from Topway..tbReti 
--update Topway..tbReti set status2=2
where reno='9267003'
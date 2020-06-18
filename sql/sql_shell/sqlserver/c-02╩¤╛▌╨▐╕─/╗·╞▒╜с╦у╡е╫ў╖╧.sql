select * from tbSettlementApp where id='64924  '
update tbSettlementApp set settleStatus='3' where id in (64924  )


select * from tbcash where settleno='64924  '
update tbcash set wstatus='0',settleno='0' where settleno in (64924  )

select * from tbReti where settleno='64924  '
update tbReti set inf2='0',settleno='0' where settleno in (64924  )

select id from Tab_WF_Instance where BusinessID='64924  '
update Tab_WF_Instance set Status='4' where BusinessID in (64924  )

select * from Tab_WF_Instance_Node where InstanceID in (select id from Tab_WF_Instance where BusinessID='64924  ')
delete from  Tab_WF_Instance_Node where InstanceID in (select id from Tab_WF_Instance where BusinessID in (64924  )) and Status='0'


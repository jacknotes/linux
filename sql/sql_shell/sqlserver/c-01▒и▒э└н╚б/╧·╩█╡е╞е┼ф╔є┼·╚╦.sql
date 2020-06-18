
--机票
SELECT t1.RecordNumber,t5.Name 
FROM homsomDB..Trv_DomesticTicketRecord t1
left join homsomDB..Trv_PnrInfos t2 on t2.ID=t1.PnrInfoID
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t2.ItktBookingID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.RecordNumber in 
('AS002220025',
'AS002220565',
'AS002221139',
'AS002224817',
'AS002228886',
'AS002228985',
'AS002228993',
'AS002229123',
'AS002229246',
'AS002229825',
'AS002230091',
'AS002230264',
'AS002230942',
'AS002231169',
'AS002231676',
'AS002231900',
'AS002231958',
'AS002233613',
'AS002233679',
'AS002233741',
'AS002233824',
'AS002234245',
'AS002236930',
'AS002237266',
'AS002237340',
'AS002237495',
'AS002239262',
'AS002240001',
'AS002240045',
'AS002240851',
'AS002240851',
'AS002240857',
'AS002240859',
'AS002240861',
'AS002241109',
'AS002241154',
'AS002241156',
'AS002241588',
'AS002241588',
'AS002246321',
'AS002246629',
'AS002246629',
'AS002247691',
'AS002247693',
'AS002247693',
'AS002247759',
'AS002250549',
'AS002250936',
'AS002251098',
'AS002252021',
'AS002252727',
'AS002252913',
'AS002252977',
'AS002253543',
'AS002253552',
'AS002253697',
'AS002199713') and NodeType=110 and NodeID=110

--一级 NodeType=110 and NodeID=110
--二级 NodeType=110 and NodeID=111

--酒店
SELECT CoupNo,t5.Name FROM HotelOrderDB..HTL_Orders t1
left join workflow..Homsom_WF_Instance t3 on t3.BusinessID=t1.OrderID
left join workflow..Homsom_WF_Template_Node t4 on t4.TemplateID=t3.TemplateID and NodeName='审批'
left join homsomDB..Trv_Human t5 on t5.ID=t4.ProcessPerson
where t1.CoupNo in 
( 'PTW075924') and NodeType=110 and NodeID=111


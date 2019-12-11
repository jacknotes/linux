/*筛选条件：
1.国内报销凭证：行程单
2.申请国内特殊票价：是

需要拉取的信息
UC、单位名称、差旅顾问、运营经理

*/
select u.Cmpid,u.Name,isnull(s.Name,'') 差旅顾问,isnull(MaintainName,'') 运营经理
from homsomDB..Trv_UnitCompanies u
left join homsomDB..Trv_TktUnitCompanies_TktTCs a on a.TktUnitCompanyID=u.ID 
LEFT JOIN homsomDB..SSO_Users s ON s.ID=a.TktTCID
left join Topway..HM_ThePreservationOfHumanInformation t on t.CmpId=u.Cmpid and MaintainType=9 and t.IsDisplay=1
where CertificateD=1
and IsSepPrice=1
and CooperativeStatus in ('1','2','3')
and u.Cmpid not in ('000003','000006')

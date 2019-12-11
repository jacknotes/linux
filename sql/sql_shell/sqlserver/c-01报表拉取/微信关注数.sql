SELECT COUNT(1)  FROM dbo.Wechat_UserAssociation T1
LEFT JOIN  dbo.Trv_UnitCompanies T2 ON T1.CompanyId=T2.ID
WHERE T2.Cmpid not in ('000003','000006')
GROUP BY T2.Name,T2.Cmpid
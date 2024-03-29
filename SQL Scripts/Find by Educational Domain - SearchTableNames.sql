/*Search all tables with name like*/
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' 
and TABLE_CATALOG='EdFi_Glendale_v31'
and TABLE_NAME like '%atten%';

/*Search columns*/
SELECT  c.name  as 'ColumnName', t.name as 'TableName'
FROM sys.columns c
JOIN sys.tables  t ON c.object_id = t.object_id
WHERE c.name like '%instructional%'
ORDER BY TableName, ColumnName;

SELECT * FROM edfi.Descriptor
WHERE 
--CodeValue like '%Abs%'
Namespace like '%AttendanceEventCategoryDescriptor%'
;
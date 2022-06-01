/*
	TASK 07
		- Identify tables in all databases where Blobs or filestreams
*/

-- Get the physical locations of all the filestreams in perticular database
SELECT      
			DB_NAME() AS 'Database Name',
			t.name AS 'Table',
            c.name AS 'Column', 
            fg.name AS 'Filegroup_Name', 
            dbf.type_desc AS 'Type_Description',
            dbf.physical_name AS 'Physical_Location'
FROM        sys.filegroups fg
INNER JOIN  sys.database_files dbf ON fg.data_space_id = dbf.data_space_id
INNER JOIN  sys.tables t ON fg.data_space_id = t.filestream_data_space_id
INNER JOIN  sys.columns c ON t.object_id = c.object_id
AND c.is_filestream = 1


-- Get All the Tables and Columns which are filestream & Blobs
SELECT
	DB_NAME() AS 'Database Name',
	o.[name] AS 'Table Name', 
	--o.[object_id] AS 'Object_ID',
	--c.[object_id] AS 'Column Object ID', 
	c.[name] AS 'Column Name', 
	t.[name] AS 'File Type',
	c.system_type_id AS 'Type ID'
FROM sys.all_columns c
INNER JOIN sys.all_objects o ON c.object_id = o.object_id
INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
WHERE c.system_type_id IN (35, 165, 99, 34, 173)
AND o.[name] NOT LIKE 'sys%'
AND o.[name] <> 'dtproperties'
AND o.[type] = 'U'
GO


--Get All the size of BLOB/Filestream files in each table 
SELECT 
	DB_NAME() AS 'Database Name',
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN
	sys.all_columns c ON t.OBJECT_ID = c.object_id
INNER JOIN 
	sys.all_objects o ON c.object_id = o.object_id
INNER JOIN 
	sys.types ty ON c.system_type_id = ty.system_type_id
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	AND c.system_type_id IN (35, 165, 99, 34, 173)
	AND o.[name] NOT LIKE 'sys%'
	AND o.[name] <> 'dtproperties'
	AND o.[type] = 'U'
GROUP BY 
    t.Name, s.Name, p.Rows  
ORDER BY 
    TotalSpaceMB DESC, t.Name

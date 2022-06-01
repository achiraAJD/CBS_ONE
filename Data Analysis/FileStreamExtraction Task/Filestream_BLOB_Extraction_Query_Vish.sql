-- Used to Extract Filestream,BLOB types files from MSSQL Server tables in a given Database into a given physical location
--USE database name
-- Need to run Below commented T-SQL to enable Ole Automation Procedures in SQL Server first
/*
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO
*/

DECLARE
	@outPutPath VARCHAR(50) = 'C:\Users\ven-talent-axwar\Desktop\File', --need to enter the path here
	@i			BIGINT,
	@init		INT,
	@data		VARBINARY(MAX),
	@fPath		VARCHAR(MAX),
	@folderPath VARCHAR(MAX)
	
--Get relevant Data into temp Table from actual table in the database, so that we can iterate over it to extract
DECLARE @Doctable TABLE (id INT IDENTITY(1,1), [DocumentID] VARCHAR , [UploadedFilename] NVARCHAR(100), [Content] VARBINARY(MAX) )
INSERT INTO @Doctable([DocumentID] , [UploadedFilename],[Content])
--type the table name and column names in the database here,
SELECT TOP 5 [DocumentID] , [UploadedFilename],[Content] FROM [dbo].[Documents] --  to extract 5 files from the table
--SELECT TOP 10 [DocumentID] , [UploadedFilename],[Content] FROM [dbo].[Documents] -- to extract 10 files from the table
--SELECT TOP 100 [DocumentID] , [UploadedFilename],[Content] FROM [dbo].[Documents] -- to extract 100 files from the table
--SELECT TOP 1000 [DocumentID] , [UploadedFilename],[Content] FROM [dbo].[Documents] -- to extract 1000 files from the table
--SELECT [DocumentID] , [UploadedFilename],[Content] FROM [dbo].[Documents] -- to extract all thew files from the table
--SELECT * FROM @Doctable --testing purpose

SELECT @i = COUNT(1) FROM @Doctable

WHILE @i >= 1
BEGIN
	SELECT
		@data = [Content], -- store actual file (base64 content) into @data variable 
		@fPath = @outPutPath + '\'+ [UploadedFilename], --[DocumentID] + '\' +[UploadedFilename], store actual path for the file
		@folderPath = @outPutPath + '\'--+ [DocumentID] -- store actual folder path
	FROM @Doctable WHERE id = @i
	
	--Create folder first, If you need to create a new folder then use below stored procedure
	--EXEC [dbo].[CreateFolder] @folderPath

	--entire process from opening the file from the database table and saving it into the given path
	EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT; -- An instace created
	EXEC sp_OASetProperty @init, 'Type', 1;
	EXEC sp_OAMethod @init, 'Open'; -- Calling a method (opening the file)
	EXEC sp_OAMethod @init, 'Write', NULL, @data; -- Calling a method (Writing the file))
	EXEC sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2; -- Calling a method (saving that file into the given path)
	EXEC sp_OAMethod @init, 'Close'; -- Calling a method (closing the file)
	EXEC sp_OADestroy @init; -- Closed the resources
	print 'Document Generated at - '+ @fPath -- printing message in sqlserver message to check whether it worked
	
	--Reset the variables for next file in the @Doctable table to use
	SELECT
	@data = NULL,
	@init = NULL,
	@fPath = NULL,
	@folderPath = NULL
	
	SET @i -= 1 --decrementing the value of i (i stores the number of rows in the table)
END
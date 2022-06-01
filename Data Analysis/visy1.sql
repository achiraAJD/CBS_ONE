create database test_db;
--use test_db

CREATE TABLE [dbo].[AchiraDocument](
   [Doc_Num] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
   [Extension] [varchar](50) NULL,
   [FileName] [varchar](200) NULL,
   [Doc_Content] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


INSERT [dbo].[AchiraDocument] ([Extension] ,[FileName] , [Doc_Content] )
SELECT 'jpg', 'a.jpg',[Doc_Data].*
FROM OPENROWSET
    (BULK 'C:\Desktop\a.jpg', SINGLE_BLOB)  [Doc_Data]

select top 10 DocumentID,UploadedFilename from Documents


--tpo activate OLe stuff
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO

DECLARE 
    @outPutPath varchar(50) = 'C:\Users\ACWAR\Documents\ACWAR\iApply_Integration\New folder',
	@i bigint,
    @init int,
    @data varbinary(max),
    @fPath varchar(max),
    @folderPath  varchar(max)

--Get Data into temp Table variable so that we can iterate over it
DECLARE @Doctable TABLE (id int identity(1,1), [DocumentID]  varchar(100) , [UploadedFilename]  varchar(100), [Content] varBinary(max) )
INSERT INTO @Doctable([DocumentID] , [UploadedFilename],[Content])

Select [DocumentID] , [UploadedFilename],[Content] FROM  [dbo].[Documents]
--SELECT * FROM @table
SELECT @i = COUNT(1) FROM Documents --@Doctable

WHILE @i >= 1
BEGIN
    SELECT
     @data = [Content],
     @fPath = @outPutPath + '\' +[UploadedFilename], --+ '\'+ [Doc_Num] + '\' +[FileName],
     @folderPath = [Content]-- + '\'+[Doc_Num]
    FROM @Doctable WHERE id = @i
  
  --Create folder first
  EXEC  [dbo].[CreateFolder]  @folderPath
  EXEC sp_OACreate 'ADODB.Stream', @init OUTPUT; -- An instace created
  EXEC sp_OASetProperty @init, 'Type', 1; 
  EXEC sp_OAMethod @init, 'Open'; -- Calling a method
  EXEC sp_OAMethod @init, 'Write', NULL, @data; -- Calling a method
  EXEC sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2; -- Calling a method
  EXEC sp_OAMethod @init, 'Close'; -- Calling a method
  EXEC sp_OADestroy @init; -- Closed the resources
  print 'Document Generated at - '+  @fPath  

--Reset the variables for next use

SELECT 
	@data = NULL, 
	@init = NULL,
	@fPath = NULL, 
	@folderPath = NULL

/*IF @i = 2
	BREAK;*/

SET @i -= 1
END


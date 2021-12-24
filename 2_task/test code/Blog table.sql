CREATE TABLE Blog (
	BlogId int IDENTITY(1, 1),
	Name varchar(50) NOT NULL, 
	Description varchar(250) NULL,
	CreatedDate datetime NOT NULL,
	UserId int NOT NULL
) 
GO

ALTER TABLE Blog
ADD CONSTRAINT PK_Blog_BlogId PRIMARY KEY CLUSTERED (BlogId)
GO

ALTER TABLE Blog
ADD CONSTRAINT DF_Blog_CreatedDate_Default DEFAULT (getdate()) FOR CreatedDate
GO

ALTER TABLE Blog
WITH CHECK ADD CONSTRAINT FK_Blog_BlogUser FOREIGN KEY(UserId)
REFERENCES BlogUser (UserId)
ON UPDATE CASCADE 
ON DELETE CASCADE
GO
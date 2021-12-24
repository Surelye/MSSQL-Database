USE [TestDB]
GO

/****** Object:  Table [dbo].[BlogUser]    Script Date: 10/9/2021 7:57:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BlogUser](
	[UserLogin] [varchar](25) NOT NULL,
	[Password] [varchar](30) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[Surname] [nvarchar](30) NOT NULL,
	[Patronymic] [nvarchar](30) NULL,
	[Email] [varchar](50) NOT NULL,
	[RegistrationDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[BlogUser] ADD  CONSTRAINT [DF_BlogUser_RegistrationDate]  DEFAULT (getdate()) FOR [RegistrationDate]
GO

ALTER TABLE BlogUser
ADD CONSTRAINT DF_BlogUser_UserLogin_Unique UNIQUE (UserLogin)
GO

ALTER TABLE BlogUser
ADD CONSTRAINT DF_BlogUser_Email_Unique UNIQUE (Email)
GO

ALTER TABLE BlogUser
ADD UserId int IDENTITY(1, 1)
GO

ALTER TABLE BlogUser
ADD CONSTRAINT PK_BlogUser_UserID PRIMARY KEY CLUSTERED (UserId)
GO
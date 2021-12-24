CREATE TABLE Client (
	client_id int NOT NULL,
	account_id int NOT NULL,
	surname nvarchar(50) NOT NULL,
	[name] nvarchar(50) NOT NULL,
	patronymic nvarchar(50) NULL,
	phone_number varchar(15) NOT NULL,
	discount int NOT NULL,
	PRIMARY KEY (client_id) 
)
GO

ALTER TABLE [Client]
WITH CHECK ADD CONSTRAINT FK_Client_Account FOREIGN KEY(account_id)
REFERENCES Account (account_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
CREATE TABLE Account (
	account_id int NOT NULL,
	[name] nvarchar(50) NOT NULL,
	surname nvarchar(50) NOT NULL,
	patronymic nvarchar(50) NULL,
	city nvarchar(40) NOT NULL,
	favourite_goods nvarchar(300) NULL,
	cart nvarchar(300) NULL,
	total_order_sum int NOT NULL,
	personal_discount int NOT NULL,
	PRIMARY KEY (account_id)
)
GO
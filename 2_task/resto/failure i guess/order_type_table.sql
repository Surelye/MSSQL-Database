CREATE TABLE OrderType (
	order_type_id int NOT NULL,
	name nvarchar(20) NOT NULL,
	payment_method nvarchar(40) NOT NULL,
	PRIMARY KEY (order_type_id)
)
GO
CREATE TABLE [Order] (
	order_id int NOT NULL,
	number_of_goods int NOT NULL,
	[date] date NOT NULL,
	[time] time NOT NULL,
	client_id int NOT NULL,
	employee_id int NOT NULL,
	order_type_id int NOT NULL,
	PRIMARY KEY (order_id)
)
GO

ALTER TABLE [Order]
WITH CHECK ADD CONSTRAINT FK_Order_Client FOREIGN KEY(client_id)
REFERENCES Client (client_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE [Order]
WITH CHECK ADD CONSTRAINT FK_Order_Employee FOREIGN KEY(employee_id)
REFERENCES Employee (employee_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE [Order]
WITH CHECK ADD CONSTRAINT FK_Order_OrderType FOREIGN KEY(order_type_id)
REFERENCES OrderType (order_type_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
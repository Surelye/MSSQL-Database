CREATE TABLE Cart (
	cart_number int NOT NULL,
	client_full_name nvarchar(70) NOT NULL,
	overall_dish_quantity int NOT NULL
	PRIMARY KEY (cart_number)
)
GO

ALTER TABLE Cart
WITH CHECK ADD CONSTRAINT FK_Cart_Individual_cart FOREIGN KEY ([cart_number])
REFERENCES [Order] ([order_id])
ON UPDATE CASCADE
ON DELETE CASCADE
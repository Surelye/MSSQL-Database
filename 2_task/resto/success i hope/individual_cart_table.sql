CREATE TABLE Individual_cart (
	individual_cart_number int NOT NULL,
	dish_name nvarchar(100) NOT NULL,
	dish_quantity int NOT NULL
)
GO

ALTER TABLE Individual_cart
WITH CHECK ADD CONSTRAINT FK_Individual_cart_Order FOREIGN KEY ([individual_cart_number])
REFERENCES [Cart] ([cart_number])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE Individual_cart
WITH CHECK ADD CONSTRAINT FK_Individual_cart_Dish FOREIGN KEY ([dish_name])
REFERENCES [Dish] ([name])
ON UPDATE CASCADE
ON DELETE CASCADE


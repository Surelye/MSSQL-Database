CREATE DATABASE Restaurant
USE Restaurant

CREATE TABLE [Type] (
	[type_id] int IDENTITY(1, 1),
	[name] nvarchar(30) NOT NULL,
	PRIMARY KEY ([type_id])
)
GO

CREATE TABLE OrderType (
	order_type_id int NOT NULL,
	name nvarchar(20) NOT NULL,
	payment_method nvarchar(40) NOT NULL,
	PRIMARY KEY (order_type_id)
)
GO

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

CREATE TABLE Position (
	position_id int NOT NULL,
	[name] nvarchar(40) NOT NULL,
	salary int NOT NULL,
	functions nvarchar(100) NOT NULL,
	working_hours nvarchar(150) NOT NULL,
	vacation_days date NOT NULL
	PRIMARY KEY (position_id)
)
GO

CREATE TABLE Employee (
	employee_id int NOT NULL,
	[name] nvarchar(50) NOT NULL,
	position_id int NOT NULL,
	surname nvarchar(50) NOT NULL,
	patronymic nvarchar(50) NOT NULL,
	salary int NOT NULL,
	date_of_birth date NOT NULL,
	passport_id varchar(20) NOT NULL,
	home_address nvarchar(100) NOT NULL,
	phone_number varchar(12) NOT NULL,
	works_since date NOT NULL,
	PRIMARY KEY (employee_id)
)
GO

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

CREATE TABLE Recipe (
	recipe_id int IDENTITY(1, 1),
	[name] nvarchar(100) NOT NULL,
	preparation_method nvarchar(500) NULL,
	preparation_time int NOT NULL,
	PRIMARY KEY (recipe_id)
)
GO

CREATE TABLE Ingredient (
	name nvarchar(60) NOT NULL,
	recipe_id int NOT NULL,
	in_stock int NOT NULL,
	purchase_cost int NOT NULL,
	date_of_delivery int NOT NULL
)
GO

CREATE TABLE Cart (
	cart_number int NOT NULL,
	client_full_name nvarchar(70) NOT NULL,
	overall_dish_quantity int NOT NULL
	PRIMARY KEY (cart_number)
)
GO

CREATE TABLE Dish (
	[name] nvarchar(100) NOT NULL,
	[type_id] int NOT NULL,
	menu_price int NOT NULL,
	preparation_price int NOT NULL,
	calorie_content int NOT NULL,
	[weight] int NOT NULL,
	recipe_id int NOT NULL,
	PRIMARY KEY ([name])
)
GO

CREATE TABLE Individual_cart (
	individual_cart_number int NOT NULL,
	dish_name nvarchar(100) NOT NULL,
	dish_quantity int NOT NULL
)
GO

ALTER TABLE [Client]
WITH CHECK ADD CONSTRAINT FK_Client_Account FOREIGN KEY(account_id)
REFERENCES Account (account_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE Employee
WITH CHECK ADD CONSTRAINT FK_Employee_Position FOREIGN KEY(position_id)
REFERENCES Position (position_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
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

ALTER TABLE Ingredient
WITH CHECK ADD CONSTRAINT FK_Ingredient_Recipe FOREIGN KEY(recipe_id)
REFERENCES Recipe (recipe_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE Cart
WITH CHECK ADD CONSTRAINT FK_Cart_Individual_cart FOREIGN KEY ([cart_number])
REFERENCES [Order] ([order_id])
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE Dish
WITH CHECK ADD CONSTRAINT FK_Dish_Type FOREIGN KEY([type_id])
REFERENCES [Type] ([type_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE Dish
WITH CHECK ADD CONSTRAINT FK_Dish_Recipe FOREIGN KEY(recipe_id)
REFERENCES [Recipe] (recipe_id)
ON UPDATE CASCADE
ON DELETE CASCADE
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

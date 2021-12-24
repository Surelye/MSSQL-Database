CREATE TABLE Dish (
	dish_id int NOT NULL,
	[type_id] int NOT NULL,
	[name] nvarchar(100) NOT NULL,
	menu_price int NOT NULL,
	preparation_price int NOT NULL,
	calorie_content int NOT NULL,
	preparation_time int NOT NULL,
	[weight] int NOT NULL,
	ingredient_id int NOT NULL,
	PRIMARY KEY (dish_id)
)
GO

ALTER TABLE Dish
WITH CHECK ADD CONSTRAINT FK_Dish_Type FOREIGN KEY([type_id])
REFERENCES [Type] ([type_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE Dish
WITH CHECK ADD CONSTRAINT FK_Dish_Recipe FOREIGN KEY(ingredient_id, dish_id)
REFERENCES Recipe (ingredient_id, dish_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
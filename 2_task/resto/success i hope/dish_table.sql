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


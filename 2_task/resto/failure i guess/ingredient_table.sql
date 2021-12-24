CREATE TABLE Ingredient (
	ingredient_id int NOT NULL,
	name nvarchar(60) NOT NULL,
	dish_id int NOT NULL,
	quantity int NOT NULL,
	purchase_cost int NOT NULL,
	date_of_delivery int NOT NULL
	PRIMARY KEY (ingredient_id)
)
GO

ALTER TABLE Ingredient
WITH CHECK ADD CONSTRAINT FK_Ingredient_Recipe FOREIGN KEY(ingredient_id, dish_id)
REFERENCES Recipe (ingredient_id, dish_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
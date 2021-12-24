CREATE TABLE Ingredient (
	name nvarchar(60) NOT NULL,
	recipe_id int NOT NULL,
	in_stock int NOT NULL,
	purchase_cost int NOT NULL,
	date_of_delivery datetime NOT NULL
)
GO

ALTER TABLE Ingredient
WITH CHECK ADD CONSTRAINT FK_Ingredient_Recipe FOREIGN KEY(recipe_id)
REFERENCES Recipe (recipe_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
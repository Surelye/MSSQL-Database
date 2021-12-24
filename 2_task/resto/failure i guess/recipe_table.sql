CREATE TABLE Recipe (
	ingredient_id int NOT NULL,
	dish_id int NOT NULL,
	[name] nvarchar(100) NOT NULL,
	preparation_method nvarchar(500) NOT NULL,
	preparation_time int NOT NULL,
	quantity_in_dish smallint NOT NULL,
	PRIMARY KEY (ingredient_id, dish_id)
)
GO
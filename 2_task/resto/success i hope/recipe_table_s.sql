CREATE TABLE Recipe (
	recipe_id int IDENTITY(1, 1),
	[name] nvarchar(100) NOT NULL,
	preparation_method nvarchar(500) NULL,
	preparation_time int NOT NULL,
	PRIMARY KEY (recipe_id)
)
GO
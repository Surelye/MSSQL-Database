CREATE TABLE Bouquet (
	goods_id int NOT NULL,
	size nvarchar(20) NOT NULL, 
	[name] nvarchar(30) NOT NULL, 
	flower_quantity int NOT NULL,
	PRIMARY KEY (goods_id)
)
GO

ALTER TABLE Bouquet
WITH CHECK ADD CONSTRAINT FK_Bouquet_Goods FOREIGN KEY(goods_id)
REFERENCES Goods (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
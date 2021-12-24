CREATE TABLE Flower (
	goods_id int NOT NULL,
	flower_type nvarchar(20) NOT NULL, 
	color nvarchar(30) NOT NULL, 
	aroma nvarchar(30) NOT NULL, 
	height nvarchar(30) NOT NULL
	PRIMARY KEY (goods_id)
)
GO

ALTER TABLE Flower
WITH CHECK ADD CONSTRAINT FK_Flower_Goods FOREIGN KEY(goods_id)
REFERENCES Goods (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
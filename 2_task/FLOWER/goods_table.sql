CREATE TABLE Goods (
	goods_id int NOT NULL,
	quantity int NOT NULL, 
	goods_type_id int NOT NULL, 
	price_per_item int NOT NULL,
	PRIMARY KEY (goods_id)
)
GO

ALTER TABLE Goods
WITH CHECK ADD CONSTRAINT FK_Goods_Goods_type FOREIGN KEY(goods_type_id)
REFERENCES Goods_type (goods_type_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
CREATE TABLE Decoration (
	goods_id int NOT NULL,
	[name] nvarchar(20) NOT NULL, 
	color nvarchar(25) NOT NULL
)
GO

ALTER TABLE Decoration
WITH CHECK ADD CONSTRAINT FK_Decoration_Goods FOREIGN KEY(goods_id)
REFERENCES Goods (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
CREATE TABLE Flowers_in_Bouquet (
	flower_id int NOT NULL, 
	quantity int NOT NULL,
	bouquet_id int NOT NULL, 
)
GO

ALTER TABLE Flowers_in_Bouquet
WITH CHECK ADD CONSTRAINT FK_Flowers_in_Bouquet_Flower FOREIGN KEY(flower_id)
REFERENCES Flower (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE Flowers_in_Bouquet
WITH CHECK ADD CONSTRAINT FK_Flowers_in_Bouquet_Bouquet FOREIGN KEY(boquet_id)
REFERENCES Bouquet (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
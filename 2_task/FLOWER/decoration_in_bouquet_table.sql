CREATE TABLE Decoration_in_bouquet (
	decoration_id int NOT NULL, 
	quantity int NOT NULL, 
	bouquet_id int NOT NULL, 
)
GO

ALTER TABLE Decoration_in_bouquet
WITH CHECK ADD CONSTRAINT FK_Decoration_in_bouquet_Decoration FOREIGN KEY(decoration_id)
REFERENCES Decoration (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE Decoration_in_bouquet
WITH CHECK ADD CONSTRAINT FK_Decoration_in_bouquet_Bouquet FOREIGN KEY(bouquet_id)
REFERENCES Bouquet (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
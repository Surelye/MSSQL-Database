CREATE TABLE Goods_shipment (
	goods_shipment_id int IDENTITY(1,1),
	shipment_id int NOT NULL, 
	goods_id int NOT NULL, 
	quantity int NOT NULL,
	purchase_price int NOT NULL,
	PRIMARY KEY (goods_shipment_id)
)
GO

ALTER TABLE Goods_shipment
WITH CHECK ADD CONSTRAINT FK_Goods_shipment_Shipment FOREIGN KEY(shipment_id)
REFERENCES Shipment (shipment_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO

ALTER TABLE Goods_shipment
WITH CHECK ADD CONSTRAINT FK_Goods_shipment_Goods FOREIGN KEY(goods_id)
REFERENCES Goods (goods_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
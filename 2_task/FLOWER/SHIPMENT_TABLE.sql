CREATE TABLE Shipment (
	shipment_id int NOT NULL,
	date_of_shipment date NOT NULL, 
	quantity int NOT NULL, 
	[sum] int NOT NULL,
	shipment_place nvarchar(50) NOT NULL, 
	PRIMARY KEY (shipment_id)
)
GO


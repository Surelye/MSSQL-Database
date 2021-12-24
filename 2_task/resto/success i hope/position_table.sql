CREATE TABLE Position (
	position_id int NOT NULL,
	[name] nvarchar(40) NOT NULL,
	salary int NOT NULL,
	functions nvarchar(100) NOT NULL,
	working_hours nvarchar(150) NOT NULL,
	vacation_days date NOT NULL
	PRIMARY KEY (position_id)
)
GO
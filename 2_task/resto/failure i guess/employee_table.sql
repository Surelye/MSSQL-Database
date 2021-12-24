CREATE TABLE Employee (
	employee_id int NOT NULL,
	[name] nvarchar(50) NOT NULL,
	position_id int NOT NULL,
	surname nvarchar(50) NOT NULL,
	patronymic nvarchar(50) NOT NULL,
	date_of_birth date NOT NULL,
	passport_id varchar(20) NOT NULL,
	home_address nvarchar(100) NOT NULL,
	phone_number varchar(12) NOT NULL,
	works_since time NOT NULL,
	PRIMARY KEY (employee_id)
)
GO

ALTER TABLE Employee
WITH CHECK ADD CONSTRAINT FK_Employee_Position FOREIGN KEY(position_id)
REFERENCES Position (position_id)
ON UPDATE CASCADE
ON DELETE CASCADE 
GO
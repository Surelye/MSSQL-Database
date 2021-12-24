USE Restaurant
GO

SELECT * FROM sysobjects WHERE xtype='TR'

select objectproperty(object_id('account_change_t'), 'ExecIsTriggerDisabled')

-- 1) Разработать и реализовать триггеры AFTER для операций INSERT, UPDATE, DELETE

-- 1. Триггер, обновляющий количество ингредиентов в таблице Ingredients

CREATE TRIGGER ingredient_insert_t
ON [dbo].[Individual_cart]
AFTER INSERT
AS
BEGIN
	DECLARE @inserted_quantity int
	DECLARE @inserted_ingredient_name nvarchar(60)
	DECLARE @ingredient_in_stock int
	DECLARE @order_number int

	SELECT @inserted_quantity = (SELECT [dish_quantity] FROM inserted)
	SELECT @inserted_ingredient_name = (SELECT [dish_name] FROM inserted)
	SELECT @order_number = (SELECT [individual_cart_number] FROM inserted)
	SELECT @ingredient_in_stock = (SELECT in_stock 
								   FROM Ingredient 
								   WHERE [name] = @inserted_ingredient_name)
	
	DECLARE @quantity_difference int = @ingredient_in_stock - @inserted_quantity
	   
	IF @quantity_difference >= 0
		UPDATE Ingredient
		SET in_stock = @quantity_difference
		WHERE [name] = @inserted_ingredient_name
	ELSE 
		BEGIN
			PRINT 'SORRY, WE ARE SHORT OF INGREDIENTS.' -- raiseerror
			DECLARE @number_of_ingredients_to_return int
			SELECT @number_of_ingredients_to_return = (SELECT SUM(dish_quantity)
													   FROM Individual_cart
													   WHERE [individual_cart_number] = @order_number AND [dish_name] = @inserted_ingredient_name)
			DELETE FROM Individual_cart
			WHERE [individual_cart_number] = @order_number AND [dish_name] = @inserted_ingredient_name
			UPDATE Ingredient
			SET in_stock = in_stock + (@number_of_ingredients_to_return - @inserted_quantity)
			WHERE [name] = @inserted_ingredient_name
		END ;
END

DROP TRIGGER ingredient_insert_t

INSERT INTO Individual_cart ([individual_cart_number], [dish_name], [dish_quantity])
VALUES (3, 'MMZPLCQJFJIFYJT', 15)

INSERT INTO Individual_cart ([individual_cart_number], [dish_name], [dish_quantity])
VALUES (4, 'FKMBAVGHSJWJGGZ', 1000)

SELECT *
FROM Ingredient
WHERE [name] = 'MMZPLCQJFJIFYJT'

INSERT INTO Individual_cart ([individual_cart_number], [dish_name], [dish_quantity])
VALUES (3, 'MMZPLCQJFJIFYJT', 125)

UPDATE Ingredient
SET in_stock = 200
WHERE [name] = 'MMZPLCQJFJIFYJT'

-- 2. Триггер, объединяющий одинаковые строки в таблице

CREATE TRIGGER ingredient_merge_t
ON [dbo].[Individual_cart]
AFTER INSERT
AS
BEGIN
	DECLARE @inserted_order_number int
	DECLARE @inserted_name nvarchar(60)
	DECLARE @inserted_quantity int
	DECLARE @accumulating_quantity int

	SELECT @inserted_order_number = (SELECT [individual_cart_number] FROM inserted)
	SELECT @inserted_name = (SELECT [dish_name] FROM inserted)
	SELECT @inserted_quantity = (SELECT [dish_quantity] FROM inserted)
	SELECT @accumulating_quantity = (SELECT SUM([dish_quantity]) 
									 FROM Individual_cart
									 WHERE [dish_name] = @inserted_name AND [individual_cart_number] = @inserted_order_number)
	
	UPDATE Individual_cart
	SET dish_quantity = @accumulating_quantity
	WHERE [dish_name] = @inserted_name AND [individual_cart_number] = @inserted_order_number;
		
	WITH CTE AS (
		SELECT [individual_cart_number], [dish_name], [dish_quantity], 
			RN = ROW_NUMBER()OVER(PARTITION BY [individual_cart_number] ORDER BY [individual_cart_number]) -- 
		FROM Individual_cart
	)
	DELETE FROM CTE WHERE RN > 1
END

DROP TRIGGER ingredient_merge_t

-- 3. Не работает
CREATE TRIGGER ingredient_delete_t
ON [dbo].[Individual_cart]
AFTER DELETE
AS 
BEGIN 
	DECLARE @deleted_dish_name nvarchar(60)
	DECLARE @deleted_dish_quantity int

	SELECT @deleted_dish_name = (SELECT [dish_name] FROM deleted)
	SELECT @deleted_dish_quantity = (SELECT [dish_quantity] FROM deleted)

	UPDATE Ingredient
	SET in_stock = in_stock + @deleted_dish_quantity
	WHERE [name] = @deleted_dish_name
END

DROP TRIGGER ingredient_delete_t

DELETE FROM Individual_cart
WHERE individual_cart_number = 3

-- 

-- 4. Обновляет имя и/или фамилию и/или отчество в таблице Client при обновлении значений в таблице Account

CREATE TRIGGER account_change_t
ON [dbo].[Account]
AFTER UPDATE
AS 
BEGIN
	DECLARE @updated_name nvarchar(50)
	DECLARE @updated_surname nvarchar(50)
	DECLARE @updated_patronymic nvarchar(50)
	DECLARE @account_id int
	
	SELECT @updated_name = (SELECT [name] FROM inserted)
	SELECT @updated_surname = (SELECT [surname] FROM inserted)
	SELECT @updated_patronymic = (SELECT [patronymic] FROM inserted)
	SELECT @account_id =(SELECT [account_id] FROM inserted)

	UPDATE Client
	SET [name] = @updated_name,
		[surname] = @updated_surname,
		[patronymic] = @updated_patronymic
	WHERE account_id = @account_id
END

DROP TRIGGER account_change_t

INSERT INTO Account
VALUES (1, 'Alexandra', 'Domrina', 'Vladimirovna', 'Moscow', 'Salad ...', '... salad', 1729, 3)

INSERT INTO Client
VALUES (1, 1, 'Domrina', 'Alexandra', 'Vladimirovna', 495, 2)

UPDATE Account
SET [name] = 'Maria', [surname] = 'Shaposhnikova', [patronymic] = 'Sergeevna'
WHERE account_id = 1

UPDATE Account
SET [name] = 'Alexandra', [surname] = 'Domrina', [patronymic] = 'Vladimirovna'
WHERE account_id = 1

-- 5. При увольнении или ухода сотрудника его зарплата распределяется в процентном соотношении между остальными сотрудниками

CREATE TRIGGER employee_delete_t
ON [dbo].[Employee]
AFTER DELETE
AS
BEGIN 
	DECLARE @overall_salaries int
	DECLARE @deleted_employee_salary int

	SELECT @overall_salaries = (SELECT SUM(salary) FROM Employee)
	SELECT @deleted_employee_salary = (SELECT salary FROM deleted)

	UPDATE Employee
	SET salary = salary + ROUND(1.0 * salary / @overall_salaries * @deleted_employee_salary, 0)
END

DROP TRIGGER employee_delete_t

SELECT * 
FROM Employee

DELETE FROM Employee
WHERE employee_id = 9

SELECT * 
FROM Employee

-- 2) Создайте представление на основе нескольких базовых таблиц и сделайте его обновляемым с помощью триггера INSTEAD OF (для INSERT, UPDATE, DELETE). 

-- INSTEAD OF INSERT В файле views

DROP TABLE cart_aux
DROP TABLE order_aux
DROP TABLE account_aux

CREATE TABLE account_aux (
	account_id int NOT NULL,
	[name] nvarchar(100) NOT NULL,
	spent_total int NOT NULL
	PRIMARY KEY (account_id)
)

CREATE TABLE order_aux (
	order_id int NOT NULL,
	account_id int NOT NULL,
	purchase_price int NOT NULL
	PRIMARY KEY (order_id)
)

ALTER TABLE order_aux
WITH CHECK ADD CONSTRAINT FK_order_account FOREIGN KEY ([account_id])
REFERENCES account_aux ([account_id])
ON UPDATE CASCADE
ON DELETE CASCADE

CREATE TABLE cart_aux (
	order_id int NOT NULL,
	good_name nvarchar(100) NOT NULL,
	quantity int NOT NULL,
	goods_price int NOT NULL
)
GO

ALTER TABLE cart_aux
WITH CHECK ADD CONSTRAINT FK_cart_order FOREIGN KEY ([order_id])
REFERENCES order_aux ([order_id])
ON UPDATE CASCADE
ON DELETE CASCADE

INSERT INTO account_aux
VALUES (1, 'Daniel Johnson', 0),
	   (2, 'Christopher Lewis', 0),
	   (3, 'Margaret Chavez', 0),
	   (4, 'Leroy Lewis', 0),
	   (5, 'Amy Hall', 0),
	   (6, 'Melissa Underwood', 0),
	   (7, 'Rhonda Lopez', 0),
	   (8, 'Francisco Hall', 0),
	   (9, 'Kelly Wood', 0),
	   (10, 'Lynn Jimenez', 0)

SELECT *
FROM account_aux

SELECT *
FROM order_aux

CREATE VIEW order_statistics_v
AS SELECT o.[order_id] AS order_id,
		  a.[name] AS customers_name,
		  a.[account_id] AS account_id,
		  o.[purchase_price] AS purchase_price
FROM account_aux AS a JOIN order_aux AS o
ON a.account_id = o.account_id

DROP VIEW order_statistics_v

SELECT *
FROM order_statistics_v


CREATE TRIGGER total_spent_insert
ON order_statistics_v
INSTEAD OF INSERT
AS 
BEGIN
	DECLARE @FIRST_ORDER_ID_INSERTED int = (SELECT MIN(order_id) FROM inserted)
	DECLARE @LAST_ORDER_ID_INSERTED int = (SELECT MAX(order_id) FROM inserted)
	DECLARE @COUNTER int = @FIRST_ORDER_ID_INSERTED
	DECLARE @purchase_price_placeholder int
	DECLARE @account_id_placeholder int
	DECLARE @account_name_placeholder nvarchar(100)
	
	WHILE @COUNTER < @LAST_ORDER_ID_INSERTED + 1
		BEGIN
			SELECT @purchase_price_placeholder = (SELECT purchase_price FROM inserted WHERE order_id = @COUNTER)
			SELECT @account_id_placeholder = (SELECT account_id FROM inserted WHERE order_id = @COUNTER)
			SELECT @account_name_placeholder = (SELECT customers_name FROM inserted WHERE order_id = @COUNTER)

			IF @account_id_placeholder IN (SELECT DISTINCT account_id FROM account_aux)
				UPDATE account_aux
				SET spent_total = spent_total + @purchase_price_placeholder
				WHERE account_id = @account_id_placeholder
			ELSE
				INSERT INTO account_aux
				VALUES (@account_id_placeholder, @account_name_placeholder, @purchase_price_placeholder)

			INSERT INTO order_aux
			VALUES (@COUNTER, @account_id_placeholder, @purchase_price_placeholder)

			SET @COUNTER = @COUNTER + 1
		END ;
END

DROP TRIGGER total_spent_insert

INSERT INTO order_statistics_v
VALUES (3, 'Daniel Johnson', 1, 500),
	   (2, 'Kelly Wood', 9, 1000),
	   (1, 'Donald Glower', 11, 300)

CREATE TRIGGER on_order_delete_t
ON order_statistics_v
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @FIRST_ORDER_ID_DELETED int = (SELECT MIN(order_id) FROM deleted)
	DECLARE @LAST_ORDER_ID_DELETED int = (SELECT MAX(order_id) FROM deleted)
	DECLARE @COUNTER int = @FIRST_ORDER_ID_DELETED 	
	DECLARE @account_id_placeholder int
	DECLARE @purchase_price_placeholder int

	WHILE @COUNTER < @LAST_ORDER_ID_DELETED + 1
		BEGIN
			SELECT @account_id_placeholder = (SELECT account_id FROM deleted WHERE order_id = @COUNTER)
			SELECT @purchase_price_placeholder = (SELECT purchase_price FROM deleted WHERE order_id = @COUNTER)

			DELETE FROM order_aux
			WHERE order_id = @COUNTER

			UPDATE account_aux
			SET spent_total = spent_total - @purchase_price_placeholder
			WHERE account_id = @account_id_placeholder

			SET @COUNTER = @COUNTER + 1
		END
END

CREATE TRIGGER on_order_update_t
ON order_statistics_v
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @order_id int = (SELECT order_id FROM inserted)
	DECLARE @customers_name_deleted nvarchar(100) = (SELECT customers_name FROM deleted)
	DECLARE @customers_name_inserted nvarchar(100) = (SELECT customers_name FROM inserted)
	DECLARE @account_id_deleted int = (SELECT account_id FROM deleted)
	DECLARE @account_id_inserted int = (SELECT account_id FROM inserted)
	DECLARE @purchase_price_deleted int  = (SELECT purchase_price FROM deleted)
	DECLARE @purchase_price_inserted int = (SELECT purchase_price FROM inserted)

	IF @account_id_inserted <> @account_id_deleted
		BEGIN
			UPDATE account_aux
			SET account_id = @account_id_inserted
			WHERE account_id = @account_id_deleted

			UPDATE order_aux
			SET account_id = @account_id_inserted
			WHERE account_id = @account_id_deleted	
		END ;

	IF @customers_name_inserted <> @customers_name_deleted
		UPDATE account_aux
		SET [name] = @customers_name_inserted
		WHERE account_id = @account_id_inserted
	
	IF @purchase_price_inserted <> @purchase_price_deleted
		BEGIN
			UPDATE order_aux
			SET purchase_price = purchase_price + (@purchase_price_inserted - @purchase_price_deleted)
			WHERE order_id = @order_id

			UPDATE account_aux
			SET spent_total = spent_total + (@purchase_price_inserted - @purchase_price_deleted)
			WHERE account_id = @account_id_inserted
		END ;
END

DELETE FROM order_statistics_v
WHERE order_id > 0







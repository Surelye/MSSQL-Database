DROP TABLE Individual_cart
DROP TABLE Dish
DROP TABLE Ingredient
DROP TABLE Recipe
DROP TABLE Cart
DROP TABLE [Order]
DROP TABLE Client
DROP TABLE Account
DROP TABLE Employee
DROP TABLE Position
DROP TABLE OrderType
DROP TABLE [Type]

CREATE TABLE [Order]
(
    order_id int NOT NULL,
    number_of_goods int NOT NULL,
    [date] datetime NOT NULL,
    client_id int NOT NULL,
    employee_id int NOT NULL,
    payment_method nvarchar(40) NOT NULL
    PRIMARY KEY (order_id)
)

CREATE TABLE Ingredient (
	name nvarchar(60) NOT NULL,
	in_stock int NOT NULL,
	purchase_cost int NOT NULL,
	date_of_delivery date NOT NULL
)
GO

DROP TABLE cart_aux
DROP TABLE order_aux
DROP TABLE account_aux

USE base_aux
USE Restaurant

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
VALUES (3, 'Daniel Johnson', 1, 800),
	   (2, 'Kelly Wood', 9, 1000),
	   (1, 'Donald Glower', 11, 500)

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

-- DELETE FROM order_statistics_v
-- WHERE order_id > 0

-- 1. Выводит средний чек заказа отнсительно некоторого порогового значения 

CREATE PROCEDURE [average_cheque_value]
    @cheque_value_threshold int = 0
AS
BEGIN
    DECLARE @ROW_COUNT int = (SELECT COUNT(1) FROM order_aux WHERE purchase_price >= @cheque_value_threshold)
    DECLARE @cheque_value_accumulator int = 0
    DECLARE @cheque_value_placeholder int
    DECLARE @cheque_cursor CURSOR

    IF @ROW_COUNT = 0
        BEGIN
            RAISERROR ('NO CLIENTS FOUND.', 0, 1)
            RETURN -1
        END

    
    SET @cheque_cursor = CURSOR SCROLL FOR
        SELECT purchase_price
        FROM order_aux
        WHERE purchase_price >= @cheque_value_threshold
    
    OPEN @cheque_cursor
    FETCH NEXT FROM @cheque_cursor INTO @cheque_value_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        SET @cheque_value_accumulator += @cheque_value_placeholder
            
        FETCH NEXT FROM @cheque_cursor INTO @cheque_value_placeholder
    END

    CLOSE @cheque_cursor
    DEALLOCATE @cheque_cursor

    PRINT FORMATMESSAGE('AVERAGE CHEQUE VALUE WITH CHEQUE VALUE THRESHOLD %d IS:', @cheque_value_threshold)
    PRINT 1.0 * @cheque_value_accumulator / @ROW_COUNT
    RETURN 1.0 * @cheque_value_accumulator / @ROW_COUNT
END

DROP PROCEDURE [average_cheque_value]

EXEC [average_cheque_value] 


-- 2. Расчёт стандартного отклонения чека

CREATE PROCEDURE [standard_deviation]
    @cheque_value_threshold int = 0
AS
BEGIN
    DECLARE @average_cheque_value int
    DECLARE @dispersion_accumulator int = 0
    DECLARE @dispersion_placeholder int
    DECLARE @dispersion_cursor CURSOR
    DECLARE @ROW_COUNT int = (SELECT COUNT(1) FROM order_aux WHERE purchase_price >= @cheque_value_threshold)

    EXEC @average_cheque_value = [average_cheque_value] @cheque_value_threshold
    
    IF @average_cheque_value = -1
        BEGIN
            RAISERROR ('DISPERSION CANNOT BE FOUND.', 0, 1)
            RETURN -1
        END

    SET @dispersion_cursor = CURSOR SCROLL FOR
        SELECT purchase_price 
        FROM order_aux
        WHERE purchase_price >= @cheque_value_threshold

    OPEN @dispersion_cursor
    FETCH NEXT FROM @dispersion_cursor INTO @dispersion_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        SET @dispersion_accumulator += (@dispersion_placeholder - @average_cheque_value) 
                                     * (@dispersion_placeholder - @average_cheque_value)

        FETCH NEXT FROM @dispersion_cursor INTO @dispersion_placeholder
    END
    
    CLOSE @dispersion_cursor
    DEALLOCATE @dispersion_cursor

    PRINT FORMATMESSAGE('STANDARD DEVIATION WITH CHEQUE VALUE THRESHOLD %d IS', @cheque_value_threshold) 
    PRINT SQRT(@dispersion_accumulator / @ROW_COUNT)
    RETURN SQRT(@dispersion_accumulator / @ROW_COUNT)
END

DROP PROCEDURE [standard_deviation]

EXEC [standard_deviation] 500


-- 3. Расчёт коэффициента асимметрии

CREATE PROCEDURE [asymmetry_coefficient]
    @cheque_value_threshold int = 0
AS
BEGIN
    DECLARE @average_cheque_value int
    DECLARE @standard_deviation real
    DECLARE @asymmetry_accumulator int = 0
    DECLARE @asymmetry_placeholder int
    DECLARE @asymmetry_cursor CURSOR
    DECLARE @ROW_COUNT int = (SELECT COUNT(1) FROM order_aux WHERE purchase_price >= @cheque_value_threshold)
    DECLARE @asymmetry_coefficient real

    EXEC @average_cheque_value = [average_cheque_value] @cheque_value_threshold
        
    IF @average_cheque_value = -1
        BEGIN
            RAISERROR ('ASYMMETRY COEFFICIENT CANNOT BE FOUND.', 0, 1)
            RETURN -1
        END

    EXEC @standard_deviation = [standard_deviation] @cheque_value_threshold

    SET @asymmetry_cursor = CURSOR SCROLL FOR
        SELECT purchase_price 
        FROM order_aux
        WHERE purchase_price >= @cheque_value_threshold

    OPEN @asymmetry_cursor
    FETCH NEXT FROM @asymmetry_cursor INTO @asymmetry_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        SET @asymmetry_accumulator += (@asymmetry_placeholder - @average_cheque_value) / @standard_deviation
                                     * (@asymmetry_placeholder - @average_cheque_value) /@standard_deviation
                                     * (@asymmetry_placeholder - @average_cheque_value)

        FETCH NEXT FROM @asymmetry_cursor INTO @asymmetry_placeholder
    END
    
    CLOSE @asymmetry_cursor
    DEALLOCATE @asymmetry_cursor

    SET @asymmetry_coefficient = 
        @asymmetry_accumulator / (@standard_deviation * @ROW_COUNT)
        

    PRINT FORMATMESSAGE('ASYMMETRY COEFFICIENT WITH CHEQUE VALUE THRESHOLD %d IS', @cheque_value_threshold) 
    PRINT @asymmetry_coefficient
    RETURN @asymmetry_coefficient
END

DROP PROCEDURE [asymmetry_coefficient]

EXEC [asymmetry_coefficient]


-- 4. Расчёт коэффициента эксцесса 

CREATE PROCEDURE [excess_coefficient]
    @cheque_value_threshold int = 0
AS
BEGIN
    DECLARE @average_cheque_value int
    DECLARE @standard_deviation real
    DECLARE @excess_accumulator bigint = 0
    DECLARE @excess_placeholder int
    DECLARE @excess_cursor CURSOR
    DECLARE @ROW_COUNT int = (SELECT COUNT(1) FROM order_aux WHERE purchase_price >= @cheque_value_threshold)
    DECLARE @excess_coefficient real

    EXEC @average_cheque_value = [average_cheque_value] @cheque_value_threshold
        
    IF @average_cheque_value = -1
        BEGIN
            RAISERROR ('ASYMMETRY COEFFICIENT CANNOT BE FOUND.', 0, 1)
            RETURN -1
        END

    EXEC @standard_deviation = [standard_deviation] @cheque_value_threshold

    SET @excess_cursor = CURSOR SCROLL FOR
        SELECT purchase_price 
        FROM order_aux
        WHERE purchase_price >= @cheque_value_threshold

    OPEN @excess_cursor
    FETCH NEXT FROM @excess_cursor INTO @excess_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        SET @excess_accumulator += (@excess_placeholder - @average_cheque_value) / @standard_deviation
                                 * (@excess_placeholder - @average_cheque_value) / @standard_deviation
                                 * (@excess_placeholder - @average_cheque_value) 
                                 * (@excess_placeholder - @average_cheque_value) 

        FETCH NEXT FROM @excess_cursor INTO @excess_placeholder
    END
    
    CLOSE @excess_cursor
    DEALLOCATE @excess_cursor

    SET @excess_coefficient = 
        @excess_accumulator / (@ROW_COUNT * @standard_deviation * @standard_deviation)
        
    PRINT FORMATMESSAGE('EXCESS COEFFICIENT WITH CHEQUE VALUE THRESHOLD %d IS', @cheque_value_threshold) 
    PRINT @excess_coefficient - 3
    RETURN @excess_coefficient - 3
END

DROP PROCEDURE [excess_coefficient]

EXEC [excess_coefficient]


-- 5. Расчёт выборочного коэффициента вариации

CREATE PROCEDURE [variation_coefficient%]
    @cheque_value_threshold int = 0
AS
BEGIN
    DECLARE @average_cheque_value int
    DECLARE @standard_deviation  real

    EXEC @average_cheque_value = [average_cheque_value] @cheque_value_threshold

    IF @average_cheque_value = -1
        BEGIN
            RAISERROR ('VARIATION COEFFICIENT CANNOT BE FOUND.', 0, 1)
            RETURN -1
        END

    EXEC @standard_deviation = [standard_deviation] @cheque_value_threshold

    PRINT FORMATMESSAGE('VARIATION COEFFICIENT PERCENTAGE WITH CHEQUE VALUE THRESHOLD %d IS:', @cheque_value_threshold)
    PRINT 100 * @standard_deviation / @average_cheque_value
    RETURN 100 * @standard_deviation / @average_cheque_value
END

DROP PROCEDURE [variation_coefficient%]

EXEC [variation_coefficient%]

INSERT INTO order_statistics_v
VALUES (4, 'Daniel Johnson', 1, 400),
	   (5, 'Kelly Wood', 9, 200),
	   (6, 'Donald Glower', 11, 700)

SELECT *
FROM order_aux

SELECT *
FROM account_aux

SELECT *
FROM order_statistics_v


                        -- NEW PROCEDURES 

SELECT *
FROM Account

INSERT INTO Account 
VALUES (1, 'Stanley', 'Curry', NULL, 'LA', NULL, NULL, 1350, 5),
       (2, 'Ashley', 'Diaz', NULL, 'NY', NULL, NULL, 2500, 10),
       (3, 'David', 'Foster', NULL, 'SAR', NULL, NULL, 450, 0),
       (4, 'Robert', 'Parker', NULL, 'QW', NULL, NULL, 1000, 8),
       (5, 'Frances', 'Ferguson', NULL, 'RT', NULL, NULL, 900, 7),
       (6, 'Wallace', 'Gutierrez', NULL, 'PR', NULL, NULL, 450, 3),
       (7, 'Josephine', 'Reynolds', NULL, 'FD', NULL, NULL, 300, 0),
       (8, 'Martha', 'Jones', NULL, 'CS', NULL, NULL, 200, 1),
       (9, 'Peggy', 'Simpson', NULL, 'SD', NULL, NULL, 700, 4),
       (10, 'Kimberly', 'Daniels', NULL, 'CV', NULL, NULL, 800, 3),
       (11, 'Stan', 'Smith', NULL, 'CV', NULL, NULL, 900, 5)

DELETE FROM Account
WHERE account_id > 0

-- 1. Для каждого пользователя отображает сэкономленную им сумму 

CREATE PROCEDURE [money_saved]
    @name nvarchar(50) = '',
    @surname nvarchar(50) = '',
    @city nvarchar(40) = '',
    @total_order_sum int = 0,
    @personal_discount int = 0
AS 
BEGIN
    IF @name = ''
        SET @name = CONCAT(@name, '%')

    IF @surname = ''
        SET @surname = CONCAT(@surname, '%')

    IF @city = ''
        SET @city = CONCAT(@city, '%')

    SELECT account_id, [name], surname, city, 
           total_order_sum, personal_discount,
           total_order_sum * personal_discount / 100 AS money_saved
    FROM Account
    WHERE [name] LIKE @name AND surname LIKE @surname AND 
           city LIKE @city AND total_order_sum >= @total_order_sum AND
           personal_discount >= @personal_discount
END

EXEC [money_saved] @name = 'Stanley'
EXEC [money_saved] @city = 'CV'
EXEC [money_saved] @city = 'CV', @total_order_sum = 900

DROP PROCEDURE [money_saved]



-- 2. Отображение меню 

SELECT *
FROM Dish

INSERT INTO Dish
VALUES ('Sandwich Cezar', 4, 300, 200, 500, 130, 1),
       ('Scramble', 1, 250, 180, 410, 110, 2),
       ('Cream-Soup', 2, 200, 140, 200, 230, 3),
       ('Funchoza', 1, 230, 120, 300, 120, 4),
       ('Meat Tower', 5, 900, 700, 1300, 1000, 5),
       ('Sushi', 3, 500, 375, 700, 500, 6)

CREATE PROCEDURE [menu]
    @name nvarchar(100) = '',
    @menu_price int = 0,
    @calorie_content int = 0,
    @weight int = 0
AS
BEGIN
    DECLARE @menu_cursor CURSOR
    DECLARE @name_placeholder nvarchar(100), @menu_price_placeholder int,
            @calorie_content_placeholder int, @weight_placeholder int
    DECLARE @dish_quantity int = 0

    IF @name = ''
        SET @name = CONCAT(@name, '%')

    SET @menu_cursor = CURSOR SCROLL FOR
        SELECT [name], menu_price, calorie_content, [weight]
        FROM dish
        WHERE [name] LIKE CONCAT(CONCAT('%', @name), '%')
        AND menu_price >= @menu_price AND
            calorie_content >= @calorie_content AND [weight] >= @weight
    
    OPEN @menu_cursor
    FETCH NEXT FROM @menu_cursor 
    INTO @name_placeholder, @menu_price_placeholder,
         @calorie_content_placeholder, @weight_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT ('Dish ' + @name_placeholder + ' has price ' + 
        STR(@menu_price_placeholder) + '. ' + 'Its calorie content is ' +
        STR(@calorie_content_placeholder) + ' and weight is' + STR(@weight_placeholder) + '.')
            
        FETCH NEXT FROM @menu_cursor 
        INTO @name_placeholder, @menu_price_placeholder,
             @calorie_content_placeholder, @weight_placeholder

        SET @dish_quantity = @dish_quantity + 1
    END

    CLOSE @menu_cursor
    DEALLOCATE @menu_cursor

    RETURN @dish_quantity
END

DROP PROCEDURE [menu]

EXEC [menu] @name = 'Cream'

DECLARE @return_value int
EXEC @return_value = [menu] @calorie_content = 300, @menu_price = 300

IF @return_value = 0
    PRINT 'YOUR QUERY RETURNED NOTHING. CHECK YOUR QUERY.'



-- 3. Отображение ингредиентов

SELECT * FROM Ingredient

DELETE 
FROM Ingredient 
WHERE purchase_cost > 0

INSERT INTO Ingredient
VALUES ('Carrot', 125, 19, GETDATE()),
       ('Onion', 50, 7, '2007-3-10'),
       ('Potato', 99, 9, '1998-1-17'),
       ('Garlic', 134, 4, '2021-5-13'),
       ('Venison', 30, 50, '2021-11-24'),
       ('Sparkling water', 200, 65, '1983-02-01'),
       ('Salt', 300, 2, GETDATE()),
       ('Pepper', 300, 2, '2026-5-13'),
       ('Coffee', 250, 25, '2001-07-10'),
       ('Bread', 125, 34, GETDATE())

CREATE PROCEDURE [display_ingredients]
    @name nvarchar(60) = '',
    @in_stock int = 0,
    @purchase_cost int = 0,
    @year int = 0,
    @month int = 0,
    @day int = 0
AS
BEGIN
    DECLARE @ingredient_cursor CURSOR
    DECLARE @name_placeholder nvarchar(60), @in_stock_placeholder int,
            @purchase_cost_placeholder int, @year_placeholder int,
            @month_placeholder int, @day_placeholder int,
            @date_of_delivery_placeholder date
    DECLARE @min_year int = (SELECT MIN(DATEPART(YEAR, date_of_delivery)) FROM Ingredient)
    DECLARE @max_year int = (SELECT MAX(DATEPART(YEAR, date_of_delivery)) FROM Ingredient)
    DECLARE @min_month int = (SELECT MIN(DATEPART(MONTH, date_of_delivery)) FROM Ingredient)
    DECLARE @max_month int = (SELECT MAX(DATEPART(MONTH, date_of_delivery)) FROM Ingredient)
    DECLARE @min_day int = (SELECT MIN(DATEPART(DAY, date_of_delivery)) FROM Ingredient)
    DECLARE @max_day int = (SELECT MAX(DATEPART(DAY, date_of_delivery)) FROM Ingredient)
    DECLARE @processed_row_quantity int = 0

    IF @name = ''
        SET @name = CONCAT(@name, '%')

    IF @year > @max_year OR @year < @min_year
        SET @year = 0

    IF @month > @max_month OR @month < @min_month
        SET @month = 0

    IF @day > @max_day OR @day < @min_day
        SET @day = 0

    SET @ingredient_cursor = CURSOR SCROLL FOR
        SELECT [name], in_stock, purchase_cost, date_of_delivery
        FROM Ingredient
        WHERE [name] LIKE CONCAT(CONCAT('%', @name), '%')
        AND in_stock >= @in_stock AND
            purchase_cost >= @purchase_cost AND DATEPART(YEAR, date_of_delivery) >= @year
        AND DATEPART(MONTH, date_of_delivery) >= @month
        AND DATEPART(YEAR, date_of_delivery) >= @day
    
    OPEN @ingredient_cursor
    FETCH NEXT FROM @ingredient_cursor 
    INTO @name_placeholder, @in_stock_placeholder,
         @purchase_cost_placeholder, @date_of_delivery_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT 'Ingredient ' + @name_placeholder + ' is currently storaged with quantity ' +
        STR(@in_stock_placeholder) + '. It costs ' + STR(@purchase_cost_placeholder) + 
        ' per thing and its latest delivery was on ' + 
        DATENAME(MONTH, DATEPART(MONTH, @date_of_delivery_placeholder)) + ' ' + 
        STR(DATEPART(DAY, @date_of_delivery_placeholder)) + ' of year ' +
        STR(DATEPART(YEAR, @date_of_delivery_placeholder)) + '.'
            
        FETCH NEXT FROM @ingredient_cursor 
        INTO @name_placeholder, @in_stock_placeholder,
             @purchase_cost_placeholder, @date_of_delivery_placeholder

        SET @processed_row_quantity = @processed_row_quantity + 1
    END

    CLOSE @ingredient_cursor
    DEALLOCATE @ingredient_cursor

    RETURN @processed_row_quantity
END

DROP PROCEDURE [display_ingredients]

EXEC [display_ingredients] @year = 2001, @name = 'Carrot'



-- 4. 

CREATE TABLE Client (
	client_id int NOT NULL,
	account_id int NOT NULL,
	surname nvarchar(50) NOT NULL,
	[name] nvarchar(50) NOT NULL,
	patronymic nvarchar(50) NULL,
	phone_number varchar(15) NOT NULL,
	discount int NOT NULL,
	PRIMARY KEY (client_id) 
)
GO

INSERT INTO Client
VALUES (1, 1, 'Jones', 'Robert', 'Jr.', 813952, 1),
       (2, 2, 'Martin', 'Kenneth', NULL, 132756, 3),
       (3, 3, 'Rogers', 'Edwin', 'Van Cleef', 957238, 5),
       (4, 4, 'Moore', 'William', 'Valeer', 750372, 7),
       (5, 5, 'Hanson', 'Robert', NULL, 105839, 9)

SELECT *
FROM Client

CREATE PROCEDURE [display_clients]
    @account_id int = 0,
    @name nvarchar(50) = '',
    @surname nvarchar(50) = '',
    @patronymic nvarchar(50) = '',
    @phone_number varchar(15) = '',
    @discount int = 0
AS
BEGIN
    DECLARE @client_cursor CURSOR
    DECLARE @account_id_placeholder int, @name_placeholder nvarchar(50),
            @surname_placeholder nvarchar(50), @patronymic_placeholder nvarchar(50),
            @phone_number_placeholder varchar(15), @discount_placeholder int
    DECLARE @processed_row_quantity int = 0

    IF @name = ''
        SET @name = CONCAT(@name, '%')

    IF @surname = ''
        SET @surname = CONCAT(@surname, '%')

    IF @patronymic = ''
        SET @patronymic = CONCAT(@patronymic, '%')

    SET @client_cursor = CURSOR SCROLL FOR
        SELECT account_id, [name], surname, patronymic, phone_number, discount
        FROM Client
        WHERE ([name] LIKE CONCAT(CONCAT('%', @name), '%') AND surname LIKE CONCAT(CONCAT('%', @surname), '%')
            AND patronymic LIKE CONCAT(CONCAT('%', ''), '%')
            AND account_id >= @account_id AND phone_number LIKE CONCAT(CONCAT('%', @phone_number), '%') 
            AND discount >= @discount) OR ([name] LIKE CONCAT(CONCAT('%', @name), '%') 
            AND surname LIKE CONCAT(CONCAT('%', @surname), '%') AND patronymic IS NULL
            AND account_id >= @account_id AND phone_number LIKE CONCAT(CONCAT('%', @phone_number), '%') 
            AND discount >= @discount)
    
    OPEN @client_cursor
    FETCH NEXT FROM @client_cursor 
    INTO @account_id_placeholder, @name_placeholder, @surname_placeholder,
         @patronymic_placeholder, @phone_number_placeholder, @discount_placeholder

    WHILE @@FETCH_STATUS = 0 BEGIN
        PRINT 'Client ' + @name_placeholder + ' ' + @surname_placeholder + ' ' + COALESCE(@patronymic_placeholder, '')
        + ' has phone number ' + @phone_number_placeholder + ' and discount of ' + STR(@discount_placeholder) + '%.'
            
        FETCH NEXT FROM @client_cursor 
        INTO @account_id_placeholder, @name_placeholder, @surname_placeholder,
             @patronymic_placeholder, @phone_number_placeholder, @discount_placeholder

        SET @processed_row_quantity = @processed_row_quantity + 1
    END

    CLOSE @client_cursor
    DEALLOCATE @client_cursor

    RETURN @processed_row_quantity
END

EXEC [display_clients] @surname = 'o'

DROP PROCEDURE [display_clients]



-- 5. 

SELECT *
FROM Client

CREATE PROCEDURE [do_clients_exist]
    @name nvarchar(50) = '',
    @surname nvarchar(50) = '',
    @patronymic nvarchar(50) = '',
    @phone_number varchar(15) = ''
AS 
BEGIN
    IF @name = ''
        SET @name = CONCAT('%', @name)

    IF @surname = ''
        SET @surname = CONCAT('%', @surname)

    IF @patronymic = ''
        SET @patronymic = CONCAT('%', @patronymic)

    IF @phone_number = ''
        SET @phone_number = CONCAT('%', @phone_number)

    IF @name != '%' AND NOT EXISTS (SELECT [name] FROM Client WHERE [name] = @name)
        RETURN -1
    ELSE IF @surname != '%' AND NOT EXISTS (SELECT surname FROM Client WHERE surname = @surname)
        RETURN -2
    ELSE IF @patronymic != '%' AND NOT EXISTS (SELECT patronymic FROM Client WHERE patronymic = @patronymic)
        RETURN -3
    ELSE IF @phone_number != '%' AND NOT EXISTS (SELECT @phone_number FROM Client WHERE phone_number = @phone_number)
        RETURN -4

    RETURN (SELECT TOP(1) account_id FROM Client 
            WHERE ([name] LIKE @name AND surname LIKE @surname
                AND patronymic LIKE @patronymic AND phone_number LIKE @phone_number) OR (patronymic IS NULL
                AND [name] LIKE @name AND surname LIKE @surname AND phone_number LIKE @phone_number))
END

DROP PROCEDURE [do_clients_exist]

DECLARE @result int 
DECLARE @name_ nvarchar(50), @surname_ nvarchar(50), @patronymic_ nvarchar(50), @phone_number_ varchar(15)
SET @surname_ = 'Hanson'
SET @name_ = 'Robert'
EXEC @result = [do_clients_exist] @name = @name_, @surname = @surname_

IF @result = -1
    PRINT 'CLIENT WITH GIVEN NAME ' + @name_ + ' WAS NOT FOUND.'
ELSE IF @result = -2
    PRINT 'CLIENT WITH GIVEN SURNAME ' + @surname_ +  ' WAS NOT FOUND.'
ELSE IF @result = -3 
    PRINT 'CLIENT WITH GIVEN PATRONYMIC ' + @patronymic_ +  ' WAS NOT FOUND.'
ELSE IF @result = -4 
    PRINT 'CLIENT WITH GIVEN PHONE NUMBER ' + @phone_number_ +  ' WAS NOT FOUND.'
ELSE 
PRINT 'CLIENT/S SATISFYING GIVEN CONDITIONS IS/ARE FOUND. FIRST SATISFYING CLIENT ID IS ' + STR(@result) + '.'
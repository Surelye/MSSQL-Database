-- 1. Запросы с использованием различных видов соединений таблиц

-- INNER JOIN oбъединяет записи из двух таблиц, если в связующих полях этих таблиц содержатся одинаковые значения.

SELECT *
FROM [Dish]
INNER JOIN [Type] 
ON Dish.[type_id] = Type.[type_id]

-- Операция LEFT JOIN создает левое внешнее соединение.
-- LEFT JOIN

SELECT *
FROM [Type] 
LEFT JOIN [Dish] 
ON Dish.[type_id] = Type.[type_id]

SELECT *
FROM [Dish] 
LEFT JOIN [Type] 
ON Dish.[type_id] = Type.[type_id]

-- RIGHT JOIN

SELECT *
FROM [Dish]	 
RIGHT JOIN [Type] 
ON Dish.[type_id] = Type.[type_id]

SELECT *
FROM [Type]	 
RIGHT JOIN [Dish] 
ON Dish.[type_id] = Type.[type_id]

-- FULL JOIN

SELECT *
FROM [Dish]
FULL JOIN [Type] 
ON Dish.[type_id] = Type.[type_id]

SELECT *
FROM [Type]
FULL JOIN [Dish] 
ON Dish.[type_id] = Type.[type_id]

-- CROSS JOIN - декартово произведение

SELECT * 
FROM [Dish]
CROSS JOIN [Type] 

-- CROSS APPLY works better on things that have no simple JOIN condition.

SELECT *
FROM [Dish]
CROSS APPLY
	(
	SELECT *
	FROM [Type]
	WHERE Dish.[type_id] = Type.[type_id]
	) result_table

-- Cамосоединение

SELECT Dish.[type_id], Dish.[name], correspondence.dish_id, correspondence.[name]
FROM Dish
JOIN Dish correspondence 
ON Dish.[type_id] = correspondence.dish_id


-- 2. Реализация операций над множествами

-- UNION - не выводит дубликаты в таблице-результате, если таковые там имеются

SELECT [name], surname, patronymic
FROM Client
UNION SELECT [name], surname, patronymic FROM Employee

--UNION ALL - выводит дубликаты

SELECT [name], surname, patronymic
FROM Client
UNION ALL SELECT [name], surname, patronymic FROM Employee

-- Возвращает все различные значения, входящие в результаты выполнения, как левого, так и правого запроса оператора INTERSECT

SELECT [name], surname, patronymic
FROM Client
INTERSECT 
SELECT [name], surname, patronymic
FROM Employee

-- Оператор EXCEPT возвращает уникальные строки из левого входного запроса, которые не выводятся правым входным запросом.

SELECT [name], surname, patronymic
FROM Client
EXCEPT
SELECT [name], surname, patronymic
FROM Employee

-- 3. Фильтрация данных в запросах с использованием предикатов

-- EXISTS - если подзапрос не пуст, то выводит нужные сведения

SELECT *
FROM Employee
WHERE EXISTS 
	(
	SELECT * 
	FROM Employee
	WHERE position_id = 2
	);

SELECT *
FROM Employee
WHERE EXISTS 
	(
	SELECT * 
	FROM Employee
	WHERE position_id = 3
	);

-- IN - проверяет наличие в некотором наборе

SELECT *
FROM Employee
WHERE phone_number IN
	(
	SELECT phone_number
	FROM Client
	)

-- ALL 

SELECT *
FROM Dish
WHERE menu_price >= ALL 
	(
	SELECT menu_price
	FROM Dish
	)

-- ANY

SELECT *
FROM Dish
WHERE menu_price > ANY
	(
	SELECT menu_price
	FROM Dish
	)

-- BETWEEN - выражение на проверку принадлежности диапазону

SELECT *
FROM Dish
WHERE dish_id BETWEEN 5 AND 9

-- LIKE - Определяет, совпадает ли указанная символьная строка с заданным шаблоном.

SELECT *
FROM Employee
WHERE phone_number LIKE '%7'


-- 4. Запросы с использованием выражения CASE.

-- CASE - Оценка списка условий и возвращение одного из нескольких возможных выражений результатов.

-- первая форма

SELECT [type_id], [name], menu_price,
CASE [type_id]
	WHEN 1 THEN 'SALAD'
	WHEN 2 THEN 'SOUP'
	WHEN 3 THEN 'DESSERT'
	ELSE 'UNKNOWN'
END dish_type
FROM Dish

-- вторая форма

SELECT [type_id], [name], [weight],
CASE
	WHEN [weight] BETWEEN 100 AND 200 THEN 'SMALL'
	WHEN [weight] BETWEEN 201 AND 400 THEN 'MEDIUM'
	WHEN [weight] > 400 THEN 'LARGE'
	ELSE 'UNKNOWN'
END dish_size
FROM Dish


-- 5. Использование встроенных функций, функций для проверки значений, логических функций.

-- CAST

SELECT CAST('07/26/1999' AS DATETIME) AS 'The Date';
SELECT CAST('1250.00' AS DECIMAL(10, 1)) AS 'A Number';
SELECT CAST(CAST('6/8/1992' AS DATETIME) - CAST('10/3/1989' AS DATETIME) AS INT)

-- CONVERT 

SELECT date_of_birth AS "original", CONVERT(VARCHAR, date_of_birth, 100) AS "converted"
FROM Employee

-- IS NULL

SELECT *
FROM Account
WHERE cart IS NULL

-- NULLIF Возвращает значение NULL, если два указанных выражения равны, возвращается первое значение, если два входных значения различаются.

SELECT NULLIF (4, 4) AS "equal", NULLIF (5, 7) AS "not_equal"

-- COALESCE вычисляет аргументы по порядку и возвращает текущее значение первого выражения, изначально не вычисленного как NULL.
-- CHOOSE возвращает элемент по указанному индексу из списка значений.

SELECT COALESCE(NULL, CHOOSE(2, 'manager', 'developer', 'producer')) AS 'result'
SELECT COALESCE(NULL, 'some_string', CHOOSE(2, 'manager', 'developer', 'producer')) AS 'result'

SELECT client_id, CHOOSE(client_id, 'manager', 'developer', 'producer') AS 'position'
FROM Client

-- IIF возвращает одно из двух значений в зависимости от того, принимает логическое выражение значение true или false.

DECLARE @first_price INT = 320, @second_price INT = 250;
DECLARE @third_price INT = 200, @fourth_price INT = 480;
SELECT COALESCE(IIF(@first_price > @second_price, NULL, 'second dish is more expensive'),
				IIF(@third_price > @fourth_price, 'first dish is more expensive', NULL), 'placeholder') AS 'result'

-- 6. Запросы с использованием функций для  работы со строками

-- REPLACE

-- SELECT home_address, REPLACE(home_address, 'г. Москва', 'г. Санкт-Петербург') AS 'result'
-- FROM Employee

DECLARE @STR NVARCHAR(100)
SET @STR = N'Это предложение содержит пробелы.'
SELECT @STR AS 'original', REPLACE(@STR, N' ', N'') AS 'result'

-- SUBSTRING

SELECT [name], SUBSTRING([name], 1, 1) AS 'first_letter', SUBSTRING([name], 10, 5) AS 'five_letters_after_ten'
FROM Dish

-- STUFF вставляет одну строку в другую. Она удаляет указанное количество символов первой строки в начальной позиции и вставляет на их место вторую строку.

SELECT [name], STUFF([name], 5, 5, [name]) AS 'modified_name'
FROM Dish

-- STR возвращает символьные данные, преобразованные из числовых данных. Символьные данные выровнены по правому краю с заданной длиной и десятичной точностью.

SELECT STR(123.45, 6, 1) AS 'float_to_string', LEN(STR(123.45, 6, 1)) AS 'float_to_string_length'

-- UNICODE

SELECT [name], SUBSTRING([name], 1, 1) AS 'first_letter', UNICODE(SUBSTRING([name], 1, 1)) AS 'unicode_character_number'
FROM Dish

-- LOWER, UPPER

SELECT [name], LOWER([name]) AS 'upper_dish', UPPER([name]) AS 'lower_dish'
FROM Dish

-- 7. Запросы с использованием функций даты и времени

-- DATEPART возвращает целое число, представляющее указанную часть datepart заданного типа date.

SELECT date_of_birth, DATEPART(dayofyear, date_of_birth) AS 'day_of_year'
FROM Employee

-- DATEADD добавляет указанное значение number (целое число со знаком) к заданному аргументу datepart входного значения date, а затем возвращает это измененное значение.
-- DATEDIFF 

SELECT date_of_birth, DATEADD(dayofyear, 20, date_of_birth) AS 'date_added', DATEDIFF(year, date_of_birth, '2040/10/21') AS 'year_difference'
FROM Employee

-- GETDATE(), SYSDATETIMEOFFSET()

SELECT date_of_birth, DATEDIFF(day, date_of_birth, GETDATE()) AS 'date_difference', DATEDIFF(minute, GETDATE(), SYSDATETIMEOFFSET()) AS 'current_date_difference'
FROM Employee

-- 8. Запросы с использованием агрегатных функций, группировок

SELECT SUM(menu_price) AS 'whole_menu_price', COUNT([name]) AS 'number_of_dishes'
FROM Dish

-- GROUP BY, HAVING

SELECT [type_id], CHOOSE([type_id], 'SALAD', 'SOUP', 'DESSERT'), COUNT([name])
FROM Dish
GROUP BY [type_id]

SELECT [type_id], CHOOSE([type_id], 'SALAD', 'SOUP', 'DESSERT'), COUNT([name])
FROM Dish
GROUP BY [type_id]
HAVING [type_id] >= 2


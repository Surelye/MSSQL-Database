-- Представления нужны для:
-- 1. Ограничения доступа к данным, т.к. представление может содержать не все столбцы/строки исходной таблицы
-- 2. Может являться псевдонимом для сложного запроса, например при извлечении данных из нескольких таблиц и работы над ними
-- 3. Сокрытия реализации: пользователи работают только с представлениями, и таблицы в базе данных можно менять

-- 1. Создание представлений

USE Restaurant_for_views
GO

SELECT * FROM sysobjects WHERE xtype='TR'

CREATE VIEW	ingredients_showcase_v
AS SELECT r.[name] AS recipe_name, -- название рецепта
		  i.[name] AS ingredient_name, -- название ингредиента, входящего в рецепт
		  i.in_stock AS number_in_stock,
		  i.purchase_cost AS purchase_cost
FROM Ingredient AS i JOIN Recipe AS r
ON i.recipe_id = r.recipe_id

DROP VIEW ingredients_showcase_v

SELECT *
FROM ingredients_showcase_v

--

CREATE VIEW dish_showcase_v
AS SELECT d.[name] AS dish_name,
		  d.[type_id] AS dish_type,
		  r.[name] AS recipe_name,
		  d.menu_price AS dish_menu_price,
		  d.[weight] AS dish_weight		  
FROM Dish AS d JOIN Recipe AS r
ON d.recipe_id = r.recipe_id

DROP VIEW dish_showcase_v

SELECT *
FROM Dish

SELECT *
FROM dish_showcase_v

-- ТРИГГЕР ДЛЯ ШЕСТОГО ЗАДАНИЯ НА INSERT
-- Представление, основанное на нескольких базовых таблицах, не может быть обновляемым.
-- Триггер на вставку позволяет нам вносить новые записи в представление.

CREATE TRIGGER dish_showcase_v_t
ON dish_showcase_v
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @upper_bound_calorie int = 3000,
			@lower_bound_calorie int = 50,
			@upper_bound_prep_time int = 5,
			@lower_bound_prep_time int = 180

	DECLARE @inserted_dish_name nvarchar(100) = (SELECT dish_name FROM inserted)
	DECLARE	@inserted_dish_type int = (SELECT dish_type FROM inserted)
	DECLARE	@inserted_dish_menu_price int = (SELECT dish_menu_price FROM inserted)
	DECLARE	@preparation_price int = FLOOR(1.0 * @inserted_dish_menu_price / 1.2)
	DECLARE	@calorie_content int = FLOOR(RAND() * (@upper_bound_calorie - @lower_bound_calorie) + @lower_bound_calorie)
	DECLARE	@inserted_dish_weight int = (SELECT dish_weight FROM inserted)

	DECLARE @recipe_name nvarchar(100) = CONCAT('Recipe of ', @inserted_dish_name)
	DECLARE @preparation_time int = FLOOR(RAND() * (@upper_bound_prep_time - @lower_bound_prep_time) + @lower_bound_prep_time)
	
	INSERT INTO Recipe ([name], [preparation_time])
	VALUES (@recipe_name, @preparation_time)

	DECLARE @recipe_id int = (SELECT recipe_id 
							  FROM Recipe 
							  WHERE [name] = @recipe_name)

	INSERT INTO Dish
	VALUES (@inserted_dish_name, @inserted_dish_type, @inserted_dish_menu_price, 
			@preparation_price, @calorie_content, @inserted_dish_weight, @recipe_id)
END

SELECT *
FROM dish_showcase_v

SELECT *
FROM Dish
WHERE [name] = 'NEWEST DISH' OR [name] = 'NEW VALUE'

SELECT *
FROM Recipe

SELECT *
FROM dish_showcase_v
WHERE [name] = 'NEWEST DISH' OR [name] = 'NEW VALUE'

DELETE FROM Dish
WHERE recipe_id > 11

DELETE FROM Recipe
WHERE recipe_id > 11

INSERT INTO dish_showcase_v 
VALUES ('NEWEST DISH', 2, 'NEWEST DISH', 500, 250)
INSERT INTO dish_showcase_v	   
VALUES ('NEW VALUE', 3, 'NEW VALUE', 1729, 300)

DROP TRIGGER dish_showcase_v_t

SELECT *
FROM dish_showcase_v

-- ТРИГГЕР ДЛЯ ШЕСТОГО ЗАДАНИЯ НА INSERT

-- представление как псевдоним для сложного запроса 

CREATE VIEW complex_query_v 
AS SELECT recipe_id AS complex_query_recipe_id,
	   SUM(dish_menu_price) AS overall_price_by_recipe_id, 
	   SUM(dish_weight) AS overall_weight_by_recipe_id,
	   COUNT(recipe_id) AS number_of_dishes_by_recipe_id
FROM
	(
		SELECT d.menu_price AS dish_menu_price,
			   d.[weight] AS dish_weight,
			   r.recipe_id AS recipe_id
		FROM Dish AS d JOIN Recipe AS r
		ON d.recipe_id = r.recipe_id
	) AS placeholder_table
GROUP BY (recipe_id)
		
DROP VIEW complex_query_v

SELECT *
FROM complex_query_v
ORDER BY complex_query_recipe_id

SELECT *
INTO #temp
FROM
	(
		SELECT recipe_id,
			   COUNT(recipe_id) AS number_of_ingredients_by_recipe,
			   SUM(in_stock) AS overall_in_stock_by_recipe,
			   SUM(purchase_cost) AS overall_purchase_cost_by_recipe
		FROM Ingredient
		WHERE recipe_id < 10
		GROUP BY recipe_id
	) AS placeholder_table JOIN complex_query_v
ON placeholder_table.recipe_id = complex_query_v.complex_query_recipe_id
ORDER BY placeholder_table.recipe_id

ALTER TABLE #temp DROP COLUMN complex_query_recipe_id
SELECT * 
FROM #temp

DROP TABLE #temp

-- 2. Создание обновляемого представления

CREATE VIEW ingredients_with_restriction_v
AS SELECT *
FROM Ingredient
WHERE SUBSTRING([name], 1, 1) = 'A' OR SUBSTRING([name], 15, 1) = 'Z'
WITH CHECK OPTION

DROP VIEW ingredients_with_restriction_v

SELECT *
FROM ingredients_with_restriction_v

INSERT INTO ingredients_with_restriction_v ([name], recipe_id, in_stock, purchase_cost, date_of_delivery)
VALUES ('MNUZUQTCKFWUODR', 4, 2601, 27225, 16)

INSERT INTO ingredients_with_restriction_v ([name], recipe_id, in_stock, purchase_cost, date_of_delivery)
VALUES ('AAAALZDQQAOTFOL', 7, 9734, 39758, 32)

-- 3. Создание индексированного представления

SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, 
	CONCAT_NULL_YIELDS_NULL, ARITHABORT, 
	QUOTED_IDENTIFIER, ANSI_NULLS ON;

CREATE VIEW [dbo].indexed_view_v
WITH SCHEMABINDING
AS SELECT SUBSTRING([name], 1, 1) AS ingredient_first_letter,
	   recipe_id, COUNT_BIG(*) AS num_recipes,
	   SUM(in_stock) AS overall_number_in_stock, 
	   SUM(purchase_cost) AS overall_purchase_cost
	   FROM [dbo].Ingredient
	   GROUP BY SUBSTRING([name], 1, 1), recipe_id

DROP VIEW [dbo].indexed_view_v

SELECT *
FROM [dbo].indexed_view_v
WITH (NOEXPAND)
--  Если запрос содержит ссылки на столбцы, присутствующие как в индексированном представлении, 
-- так и в базовых таблицах, а оптимизатор запросов определяет, что использование индексированного
-- представления является лучшим методом выполнения запроса, 
-- то оптимизатор будет использовать индекс представления.

CREATE UNIQUE CLUSTERED INDEX CL_indexed_view_first_letter_recipe_id
ON [dbo].indexed_view_v (ingredient_first_letter, recipe_id)

DROP INDEX CL_indexed_view_first_letter_recipe_id ON [dbo].indexed_view_v

SELECT SUBSTRING([name], 1, 1) AS ingredient_first_letter,
	   recipe_id, COUNT(*) AS num_recipes,
	   SUM(in_stock) AS overall_number_in_stock, 
	   SUM(purchase_cost) AS overall_purchase_cost
FROM Ingredient
GROUP BY SUBSTRING([name], 1, 1), recipe_id

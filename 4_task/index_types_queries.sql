/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
FROM [Restaurant].[dbo].[Ingredient] -- cluster
WHERE [name] = 'IXEOXJMDEYGSRHE'

SELECT *
FROM [Restaurant].[dbo].[Ingredient] -- non-cluster
WHERE purchase_cost = 5000

SELECT *
FROM [Restaurant].[dbo].[Ingredient] -- compound
WHERE in_stock = 2500 AND date_of_delivery = 22

SELECT [name], [in_stock], [purchase_cost] -- covering
FROM [Restaurant].[dbo].[Ingredient]
WHERE purchase_cost BETWEEN N'5000' and N'7790'

SELECT * -- unique
FROM [Restaurant].[dbo].[Ingredient]
WHERE [name] = 'IXEOXJMDEYGSRHE'

SELECT [name], [recipe_id], [purchase_cost], [in_stock], [date_of_delivery] -- included columns
FROM [Restaurant].[dbo].[Ingredient]
WHERE recipe_id > 5 AND in_stock > 5000

SELECT [name], [purchase_cost], [in_stock] -- filtered 
FROM [Restaurant].[dbo].[Ingredient]
WHERE purchase_cost > 9000 AND SUBSTRING([name], 1, 3) = 'ABC'




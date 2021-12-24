declare @upperbound int  
declare @lowerbound int 
select @lowerbound = 65, @upperbound=90

declare @len integer, @i integer, @name varchar(8000)
set @len = 15

DECLARE @recipe_id int
DECLARE @in_stock int
DECLARE @purchase_cost int
DECLARE @date_of_delivery int
DECLARE @counter int

SET @counter = 0

WHILE (@counter < 10000)
begin
	SET @recipe_id = FLOOR(RAND() * (11 - 2) + 2);
	SET @in_stock = FLOOR(RAND() * 5000);
	SET @purchase_cost = FLOOR(RAND() * 10000);
	SET @date_of_delivery = FLOOR(RAND() * 45);

	set @i = 1
	set @name = ''

	while @i <= @len
	begin
		set @name = @name + CHAR(cast(((@upperbound - @lowerbound + 1) * Rand() + @lowerbound) as int))
		set @i = @i+1
	end

	INSERT INTO [dbo].[Ingredient]([name], [recipe_id], [in_stock],
								   [purchase_cost], [date_of_delivery])
	VALUES(@name, @recipe_id, @in_stock, @purchase_cost, @date_of_delivery)

	SET @counter = @counter + 1
END
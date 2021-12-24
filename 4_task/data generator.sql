declare @upperbound int  
declare @lowerbound int 
select @lowerbound = 65, @upperbound=90

declare @len integer, @i integer, @name varchar(8000)
set @len = 15

DECLARE @cart_number int
DECLARE @type_id int
DECLARE @menu_price int
DECLARE @preparation_price int
DECLARE @calorie_content int
DECLARE @weight int
DECLARE @recipe_id int
DECLARE @counter int

SET @counter = 0

WHILE (@counter < 10000)
begin
	SET @type_id = FLOOR(RAND() * (4 - 1) + 1)
	SET @menu_price = FLOOR(RAND() * (3000 - 150) + 150);
	SET @preparation_price = FLOOR(RAND() * (2000 - 100) + 100);
	SET @calorie_content = FLOOR(RAND() * (1000 - 50) + 50);
	SET @weight = FLOOR(RAND() * (3000 - 50) + 50);
	SET @recipe_id = FLOOR(RAND() * (10 - 2) + 2);
	
	set @i = 1
	set @name = ''

	while @i <= @len
	begin
		set @name = @name + CHAR(cast(((@upperbound - @lowerbound + 1) * Rand() + @lowerbound) as int))
		set @i = @i+1
	end

	INSERT INTO [dbo].[Dish]([name], [type_id],[menu_price], [preparation_price], 
							[calorie_content], [weight], [recipe_id])
	VALUES(@name, @type_id, @menu_price, @preparation_price, 
		   @calorie_content, @weight, @recipe_id)
	
	SET @counter = @counter + 1
END
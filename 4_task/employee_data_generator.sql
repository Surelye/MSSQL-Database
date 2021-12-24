declare @upperbound int  
declare @lowerbound int 
select @lowerbound = 65, @upperbound=90

declare @len integer, @i integer, @name varchar(8000) = ''
DECLARE @surname varchar(80) = '', @patronymic varchar(80) = '', @home_address varchar(80) = ''
set @len = 15

DECLARE @employee_id int = 1
DECLARE @position_id int
DECLARE @salary int
DECLARE @date_of_birth date
DECLARE @passport_id int
DECLARE @phone_number int
DECLARE @works_since date
DECLARE @counter int

SET @counter = 0

WHILE (@counter < 10)
begin
	SET @name = ''
	SET @surname = ''
	SET @patronymic = ''
	SET @home_address = ''

	set @i = 1
	while @i <= @len
	begin
		set @name = @name + CHAR(cast(((@upperbound - @lowerbound + 1) * Rand() + @lowerbound) as int))
		set @i = @i+1
	end
			
	SET @position_id = FLOOR(RAND() * (5 - 1) + 1)
	
	SET @i = 1
	while @i <= @len
	begin
		set @surname = @surname + CHAR(cast(((@upperbound - @lowerbound + 1) * Rand() + @lowerbound) as int))
		set @i = @i+1
	end

	SET @i = 1
	while @i <= @len
	begin
		set @patronymic = @patronymic + CHAR(cast(((@upperbound - @lowerbound + 1) * Rand() + @lowerbound) as int))
		set @i = @i+1
	end

	SET @salary = FLOOR(RAND() * (300 - 50) + 50)
	SET @date_of_birth = GETDATE()
	SET @passport_id = FLOOR(RAND() * (900 - 800) + 800)
	
	SET @i = 1
	while @i <= @len
	begin
		set @home_address = @home_address + CHAR(cast(((@upperbound - @lowerbound + 1) * Rand() + @lowerbound) as int))
		set @i = @i+1
	end

	SET @phone_number = FLOOR(RAND() * (4000 -  1000) + 1000)
	SET @works_since = GETDATE()

	INSERT INTO Employee
	VALUES (@employee_id, @name, @position_id, @surname,
			@patronymic, @salary, @date_of_birth, @passport_id,
			@home_address, @phone_number, @works_since)

	SET @counter = @counter + 1
	SET @employee_id = @employee_id + 1
END
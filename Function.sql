--1.	Функцию, возвращающую количество книг, у которых не указана категория.
CREATE	FUNCTION BooksCntCategoryNull()
RETURNS INT 
AS 
BEGIN	
DECLARE @cnt INT = 0
SELECT @cnt = COUNT(b.N) FROM dbo.books b WHERE b.id_category IS NULL
RETURN @cnt
END	
GO 
DROP FUNCTION BooksCntCategoryNull
GO 
DECLARE @cnt INT = 0
EXECUTE @cnt = BooksCntCategoryNull
RAISERROR('BooksCntCategoryNull: %d', 0,1,@cnt)
GO 
--2.	Функцию, возвращающую количество книг по каждому издательству и по каждой из тематик.
CREATE FUNCTION BooksCntPressTheme()
RETURNS TABLE
AS 
RETURN(SELECT p.name Press, t.name Theme, COUNT(b.N) BooksCnt FROM dbo.books b, dbo.press p, dbo.themes t
WHERE b.Id_press = p.id AND b.Id_theme = t.id
GROUP BY p.name, t.NAME)
GO 
SELECT * FROM BooksCntPressTheme()
GO 
--3.	Функцию, возвращающую список книг, отвечающих набору критериев 
--(например, название книги, тематика, категория, издательство),
--и отсортированный по номеру поля, указанному в 5-м параметре, в направлении, указанном в 6-м параметре.
CREATE FUNCTION PagesThemeCategoryPriceSortByFieldNumAndDirection(@Page int, @Theme NVARCHAR(50), @Category NVARCHAR(50), @Price MONEY,  @Field NVARCHAR(50), @Dir VARCHAR(10))
RETURNS @Table TABLE (Book NVARCHAR(255), Pages int, Theme NVARCHAR(255), Category NVARCHAR(255), Price MONEY, Press NVARCHAR(255))
AS 
BEGIN 
DECLARE @TempTable TABLE (Book NVARCHAR(255), Pages int, Theme NVARCHAR(255), Category NVARCHAR(255), Price MONEY, Press NVARCHAR(255))
INSERT @TempTable
SELECT b.NAME Book, b.Pages, t.name Theme, c.name Category, b.Price Price, p.NAME Press 
FROM dbo.books b, dbo.press p, dbo.themes t, dbo.category c 
WHERE b.Id_press = p.id AND b.Id_theme = t.id AND	b.id_category = c.id 
AND b.Pages > @Page AND t.name = @Theme AND	c.name = @Category AND b.Price < @Price
IF(@Field = 'Book')
BEGIN 
	IF (@Dir = 'ASC')INSERT @Table SELECT * FROM @TempTable ORDER BY Book ASC
	ELSE INSERT @Table SELECT * FROM @TempTable ORDER BY Book DESC
END	
ELSE IF	(@Field = 'Pages')
BEGIN 
	IF (@Dir = 'ASC')INSERT @Table SELECT * FROM @TempTable ORDER BY Pages ASC
	ELSE INSERT @Table SELECT * FROM @TempTable ORDER BY Pages DESC
END	
ELSE IF	(@Field ='Price')
BEGIN 
	IF (@Dir = 'ASC')INSERT @Table SELECT * FROM @TempTable ORDER BY Price ASC
	ELSE INSERT @Table SELECT * FROM @TempTable ORDER BY Price DESC
END	
ELSE IF	(@Field = 'Press')
BEGIN 
	IF (@Dir = 'ASC')INSERT @Table SELECT * FROM @TempTable ORDER BY Press ASC
	ELSE INSERT @Table SELECT * FROM @TempTable ORDER BY Press DESC
END	
RETURN
END	
GO 
Declare @Page INT = 100, @Theme NVARCHAR(50) = 'Программирование', @Category NVARCHAR(50) = 'Visual Basic', @Price MONEY = 300,
@FieldN NVARCHAR(50) = 'Pages', @Dir VARCHAR(10) = 'DESC'
SELECT * FROM PagesThemeCategoryPriceSortByFieldNumAndDirection (@Page, @Theme, @Category, @Price, @FieldN, @Dir)
GO 
DROP FUNCTION PagesThemeCategoryPriceSortByFieldNumAndDirection
GO 
--А также реализовать следующие функции:
--4.	Функцию, возвращающую минимальное из трех переданных параметров.
CREATE FUNCTION	MinOfThree (@F INT, @S INT, @Th INT)
RETURNS INT   
AS 
BEGIN 
DECLARE @min INT = 0
IF	(@F < @S AND @F < @TH)
SET @min = @F
ELSE IF	(@S < @F AND @S < @TH)
SET @min = @S
ELSE IF	(@TH < @F AND @TH < @S)
SET @min = @Th
RETURN @min
END 
GO 
DECLARE @min INT
EXECUTE @min = dbo.MinOfThree @F = 1230, @S = 20, @Th = 40 
RAISERROR('MIN: %d',0,1, @min)
GO 
--5.	Функцию, которая принимает в качестве параметра двухразрядное число и определяет какой из разрядов больше,
--либо они равны (используйте % - деление по модулю. Например, 57%10=7).
CREATE FUNCTION TwoDigitNumber(@num int)
RETURNS INT
BEGIN	
DECLARE @temp INT = 0
SET @temp = @num % 10
SET @num = @num / 10
IF(@temp < @num) set @temp = @num  
if (@temp = @num) return 0
RETURN @temp 
END 
GO
drop function TwoDigitNumber
go 
DECLARE @Max INT = 44
DECLARE @temp INT = @Max
EXECUTE @temp = dbo.TwoDigitNumber @temp 
IF (@temp = 0)RAISERROR('Both digits are equally',0,1)
else RAISERROR('Large: %d in %d',0,1, @temp, @Max)

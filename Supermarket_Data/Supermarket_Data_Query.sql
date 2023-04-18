
-- Creating table for the data
-- I like to make sure the table doesnt already exist before creating it
DROP TABLE IF EXISTS Customer_Data
CREATE TABLE Customer_Data (
	Invoice_ID varchar(255),
	Branch varchar(1),
	City varchar(255),
	Customer_type varchar(255),
	Gender varchar(255),
	Product_line varchar(255),
	Unit_price float,
	Quantity float,
	Tax_5 float,
	Total_price float,
	Date date,
	Time time,
	Payment varchar(255),
	Cogs float,
	Gross_margin_percentage float,
	Gross_income float,
	Rating float
)

-- We insert the data from the CSV file
BULK INSERT Customer_Data
-- Insert the filepath to the supermarket_sales file here
FROM 'C:\Users\frede\OneDrive\Skrivebord\Projects\Supermarket_Data\supermarket_sales.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2
)

--Checking to see if table was created correctly
--SELECT * FROM Customer_Data

-- Project idea and data from here https://www.dataquest.io/blog/sql-projects/
-- Some exercise questions about the dataset:
---- 1) Which branch has the best results in the loyalty program?
---- 2) Does the membership depend on customer rating?
---- 3) Does gross income depend on the proportion of customers in the loyalty program? On payment method?
---- 4) Are there any differences in indicators between men and women?
---- 5) Which product category generates the highest income?


-- 1)
PRINT 'Exercise 1): Which branch has the best results in the loyalty program?'

DECLARE @branches TABLE (Branch varchar(1))
INSERT @branches(Branch) values ('A'),('B'),('C')

DECLARE @branch varchar(1)

WHILE exists (SELECT * FROM @branches)
	BEGIN
		SELECT @branch = MIN(Branch) FROM @branches

		DECLARE @member_number float, @normal_number float, @member_avg_price float, @normal_avg_price float

		SELECT @member_number = COUNT(Customer_type)
		FROM Customer_Data
		WHERE Customer_type = 'Member' AND Branch = @branch

		SELECT @normal_number = COUNT(Customer_type)
		FROM Customer_Data
		WHERE Customer_type = 'Normal' AND Branch = @branch

		PRINT 'Members account for ' + CAST(((@member_number / (@member_number + @normal_number)) * 100) AS VARCHAR(10)) +
		'% of all customers at branch ' + @branch

		SELECT @member_avg_price = AVG(Total_price)
		FROM Customer_Data
		WHERE Customer_type = 'Member' AND Branch = @branch

		SELECT @normal_avg_price = AVG(Total_price)
		FROM Customer_Data
		WHERE Customer_type = 'Normal' AND Branch = @branch

		PRINT 'Members spend an average of ' + CAST((@member_avg_price - @normal_avg_price) AS VARCHAR(10)) +
		' USD more/less than normal customers at branch ' + @branch
		PRINT ''

		DELETE FROM @branches WHERE Branch = @branch
	END

-- We see that branch C has the highest proportion of members out of the 3 branches, although this is by a very narrow margin.
-- We also see that customers in branch A spend an average of 17.35 USD more if they are members,
-- while customers in branch C actually spend an average of 1.08 USD less if they are members.
-- Thus, I'd sat that branch A has the best results in the loyalty program.


-- 2)
PRINT ''
PRINT ''
PRINT 'Exercise 2): Does the membership depend on customer rating?'

DECLARE @member_rating float, @normal_rating float

SELECT @member_rating = AVG(Rating)
FROM Customer_Data
WHERE Customer_type = 'Member'

SELECT @normal_rating = AVG(Rating)
FROM Customer_Data
WHERE Customer_type = 'Normal'

PRINT 'Members give an average rating of ' + CAST(@member_rating AS VARCHAR(10)) +
', while normal customers give an average rating of ' + CAST(@normal_rating AS VARCHAR(10))

-- The difference in rating between members and non-members is very small, so membership does likely not depend on customer rating


-- 3)
PRINT ''
PRINT ''
PRINT 'Exercise 3): Does gross income depend on the proportion of customers in the loyalty program? On payment method?'

DECLARE @member_gross_income float, @normal_gross_income float

SELECT @member_gross_income = AVG(Gross_income)
FROM Customer_Data
WHERE Customer_type = 'Member'

SELECT @normal_gross_income = AVG(Gross_income)
FROM Customer_Data
WHERE Customer_type = 'Normal'

PRINT 'Members produce an average gross income of ' + CAST(@member_gross_income AS VARCHAR(10)) +
', while normal customers produce an average gross income of ' + CAST(@normal_gross_income AS VARCHAR(10))


DECLARE @payment_types TABLE (Payment_type varchar(100))
INSERT @payment_types(Payment_type) values ('Ewallet'),('Cash'),('Credit card')

DECLARE @payment_type varchar(100), @gross_inc float

WHILE exists (SELECT * FROM @payment_types)
	BEGIN
		SELECT @payment_type = MIN(Payment_type) FROM @payment_types

		SELECT @gross_inc = AVG(Gross_income)
		FROM Customer_Data
		WHERE Payment = @payment_type

		PRINT 'Customers paying with ' + @payment_type + ' produce an average gross income of ' + CAST(@gross_inc AS VARCHAR(10))
		PRINT ''

		DELETE FROM @payment_types WHERE Payment_type = @payment_type
	END

-- It does seem like customers who are members of the loyalty program prodyce a slightly higher agerage gross income than normal customers.
-- Additionally, customers paying with cash seem to produce a slightly higher average gross income
-- than customers who pay with credit card, or especially ewallet


-- 4)
PRINT 'Exercise 4): Are there any differences in indicators between men and women?'
-- This is a long exercise

INSERT @branches(Branch) values ('A'),('B'),('C')

DECLARE @female_number float, @male_number float, @total_number float

WHILE exists (SELECT * FROM @branches)
	BEGIN
		SELECT @branch = MIN(Branch) FROM @branches

		SELECT @female_number = COUNT(Gender)
		FROM Customer_Data
		WHERE Gender = 'Female' AND Branch = @branch

		SELECT @male_number = COUNT(Gender)
		FROM Customer_Data
		WHERE Gender = 'Male' AND Branch = @branch

		SET @total_number = @male_number + @female_number

		PRINT 'Males make up ' + CAST(((@male_number / @total_number) * 100) AS VARCHAR(10))
		+ '% of the customer base at branch ' + @branch
		PRINT 'Females make up ' + CAST(((@female_number / @total_number) * 100) AS VARCHAR(10))
		+ '% of the customer base at branch ' + @branch
		PRINT ''

		DELETE FROM @branches WHERE Branch = @branch
	END

-- Branch C seems to have a significantly higher proportion of female customers than branch A and B



-- We already know that branch C has both a higher proportion of loyalty program members,
-- and a higher proportion of female customers.
-- Thus we expect a bigger proportion of loyalty program members to be female

DECLARE @genders TABLE (Gender varchar(100))
DECLARE @membership_number float, @gender_number float, @gender varchar(100), @customer_type varchar(100)
INSERT @genders(Gender) values ('Male'), ('Female')

WHILE exists (SELECT * FROM @genders)
	BEGIN
		SELECT @gender = MIN(Gender) FROM @genders

		SELECT @gender_number = COUNT(Gender)
		FROM Customer_Data
		WHERE Gender = @gender

		SELECT @membership_number = COUNT(Customer_type)
		FROM Customer_Data
		WHERE Gender = @gender AND Customer_type = 'Member'

		PRINT 'Loyalty program participation rate among ' + @gender + ' customers is '
		+ CAST(((@membership_number / @gender_number) * 100) AS VARCHAR(10)) + '%'
		PRINT ''

		DELETE FROM @genders WHERE Gender = @gender
	END

-- As we expected, we see here that female customers are more likely to participate in the loyalty program.


DECLARE @product_lines TABLE (Product_line varchar(100))
DECLARE @product_number float, @total_product_number float, @product_line varchar(100)
INSERT @genders(Gender) values ('Male'), ('Female')


WHILE exists (SELECT * FROM @genders)
	BEGIN
		SELECT @gender = MIN(Gender) FROM @genders

		SELECT @gender_number = COUNT(Gender)
		FROM Customer_Data
		WHERE Gender = @gender

		INSERT @product_lines(Product_line) values ('Fashion accessories'),('Home and lifestyle'),
		('Electronic accessories'),('Health and beauty'),('Food and beverages'),('Sports and travel')

		WHILE exists (SELECT * FROM @product_lines)
			BEGIN
				SELECT @product_line = MIN(Product_line) FROM @product_lines

				SELECT @product_number = COUNT(Product_line)
				FROM Customer_Data
				WHERE Gender = @gender AND Product_line = @product_line

				PRINT 'Products in the "' + @product_line + '" category make up '
				+ CAST(((@product_number / @gender_number) * 100) AS VARCHAR(10)) + '% of purchases for '
				+ @gender + ' customers'

				DELETE FROM @product_lines WHERE Product_line = @product_line
			END

		PRINT ''

		DELETE FROM @genders WHERE Gender = @gender
	END

-- We see that female customers are more likely to buy products in the "Fashion accessories", "Food and beverages",
-- and "Sports and travel" categories, while male customers are more likely to buy products in the "Health and beauty"
-- category. Both male and female customers buy a roughly equal number of products in the "Electronic accessories"
-- and "Home and lifestyle" categories

DECLARE @male_price float, @female_price float, @male_quant float, @female_quant float,
@male_tot_price float, @female_tot_price float, @male_gross float, @female_gross float

SELECT @male_price = AVG(Unit_price)
FROM Customer_Data
WHERE Gender = 'Male'

SELECT @female_price = AVG(Unit_price)
FROM Customer_Data
WHERE Gender = 'Female'

PRINT 'The average price of products bought by male customers is ' + CAST(@male_price AS VARCHAR(10))
PRINT 'The average price of products bought by female customers is ' + CAST(@female_price AS VARCHAR(10))

SELECT @male_quant = AVG(Quantity)
FROM Customer_Data
WHERE Gender = 'Male'

SELECT @female_quant = AVG(Quantity)
FROM Customer_Data
WHERE Gender = 'Female'

PRINT 'The average quantity of products bought by male customers is ' + CAST(@male_quant AS VARCHAR(10))
PRINT 'The average quantity of products bought by female customers is ' + CAST(@female_quant AS VARCHAR(10))

SELECT @male_tot_price = AVG(Total_price)
FROM Customer_Data
WHERE Gender = 'Male'

SELECT @female_tot_price = AVG(Total_price)
FROM Customer_Data
WHERE Gender = 'Female'

PRINT 'The average total price of products bought by male customers is ' + CAST(@male_tot_price AS VARCHAR(10))
PRINT 'The average total price of products bought by female customers is ' + CAST(@female_tot_price AS VARCHAR(10))

SELECT @male_gross = AVG(Gross_income)
FROM Customer_Data
WHERE Gender = 'Male'

SELECT @female_gross = AVG(Gross_income)
FROM Customer_Data
WHERE Gender = 'Female'

PRINT 'Male customers produce an average gross income of ' + CAST(@male_gross AS VARCHAR(10))
PRINT 'Female customers produce an average gross income of ' + CAST(@female_gross AS VARCHAR(10))

-- We see that, on average, male customers buy products with a slightly higher price tag than female products.
-- However, we also see that female customers on average buy a higher quantity of products than male customers.
-- This results in female customers on average making more expensive purchases than male customers,
-- and by extention, results in female customers on average producing a higher gross income than male customers.


-- We know that male customers on average produce a lower gross income than females.
-- We also know that customers paying with ewallet produce a lower gross income
-- than customers paying with cash or credit card.
-- Thus, we expect male customers to, on average, make more purchases with ewallet than female customers

DECLARE @payment_number float, @total_payment_number float
INSERT @genders(Gender) values ('Male'), ('Female')

WHILE exists (SELECT * FROM @genders)
	BEGIN
		SELECT @gender = MIN(Gender) FROM @genders

		SELECT @gender_number = COUNT(Gender)
		FROM Customer_Data
		WHERE Gender = @gender

		INSERT @payment_types(Payment_type) values ('Ewallet'),('Cash'),('Credit card')

		WHILE exists (SELECT * FROM @payment_types)
			BEGIN
				SELECT @payment_type = MIN(Payment_type) FROM @payment_types

				SELECT @payment_number = COUNT(Payment)
				FROM Customer_Data
				WHERE Gender = @gender AND Payment = @payment_type

				PRINT @gender + ' customers paid with ' + @payment_type
				+ ' in ' + CAST(((@payment_number / @gender_number) * 100) AS VARCHAR(10)) + '% of purchases'

				DELETE FROM @payment_types WHERE Payment_type = @payment_type
			END

		PRINT ''

		DELETE FROM @genders WHERE Gender = @gender
	END

-- Just like we expected, male customers are significantly more likely to pay with ewallet than female customers

DECLARE @male_rating float, @female_rating float

SELECT @male_rating = AVG(Rating)
FROM Customer_Data
WHERE Gender = 'Male'

SELECT @female_rating = AVG(Rating)
FROM Customer_Data
WHERE Gender = 'Female'

PRINT 'Male customers gave an average rating of ' + CAST(@male_rating AS VARCHAR(10))
PRINT 'Female customers gave an average rating of ' + CAST(@female_rating AS VARCHAR(10))

-- We see that both genders give an almost equal rating on average




-- 5) 
PRINT ''
PRINT ''
PRINT 'Exercise 5): Which product category generates the highest income?'

DECLARE @category_income float
INSERT @product_lines(Product_line) values ('Fashion accessories'),('Home and lifestyle'),
('Electronic accessories'),('Health and beauty'),('Food and beverages'),('Sports and travel')

WHILE exists (SELECT * FROM @product_lines)
	BEGIN
		SELECT @product_line = MIN(Product_line) FROM @product_lines

		SELECT @category_income = AVG(Gross_income)
		FROM Customer_Data
		WHERE Product_line = @product_line

		PRINT 'Products in the "' + @product_line + '" category produce an average gross income of '
		+ CAST(@category_income AS VARCHAR(10))

		DELETE FROM @product_lines WHERE Product_line = @product_line
	END

-- Products in the "Home and lifestyle" category produce the largest gross income,
-- while products in the "Fashion accessories" category produce the lowest income
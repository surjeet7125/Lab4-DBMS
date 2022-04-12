CREATE DATABASE E_Commerce;
USE E_Commerce;

/* Delete if Tables are Present */
DROP TABLE IF EXISTS `Supplier`, `Customer`, `Category`, `Product`, `ProductDetails`, `Order`, `Rating` ;

/* create Tables */
CREATE TABLE Supplier(
	SUPP_ID INT PRIMARY KEY,
    SUPP_NAME VARCHAR(50),
    SUPP_CITY VARCHAR(50),
    SUPP_PHONE BIGINT
);

DESC Supplier;

CREATE TABLE Customer(
	CUS_ID INT PRIMARY KEY,
    CUS_NAME VARCHAR(50),
    CUS_PHONE BIGINT,
    CUS_CITY VARCHAR(50),
    CUS_GENDER VARCHAR(2)
);

DESC Customer;

CREATE TABLE Category(
	CAT_ID INT PRIMARY KEY,
    CAT_NAME VARCHAR(50)
);

DESC Category;

CREATE TABLE Product(
	PRO_ID INT PRIMARY KEY,
    PRO_NAME VARCHAR(50),
    PRO_DESC VARCHAR(50),
    CAT_ID INT,
    FOREIGN KEY(CAT_ID) REFERENCES Category(CAT_ID)
);

DESC Product;

CREATE TABLE ProductDetails(
	PROD_ID INT PRIMARY KEY,
    PRO_ID INT,
    SUPP_ID INT,
    PRICE FLOAT,
    FOREIGN KEY(PRO_ID) REFERENCES Product(PRO_ID), 
    FOREIGN KEY(SUPP_ID) REFERENCES Supplier(SUPP_ID)
);

DESC ProductDetails;

CREATE TABLE `Order`(
	ORD_ID INT PRIMARY KEY,
    ORD_AMOUNT FLOAT,
    ORD_DATE DATE,
    CUS_ID INT,
    PROD_ID INT,
    FOREIGN KEY(CUS_ID) REFERENCES Customer(CUS_ID),
    FOREIGN KEY(PROD_ID) REFERENCES ProductDetails(PROD_ID)
);
	
DESC `Order`;

CREATE TABLE Rating(
	RAT_ID INT PRIMARY KEY,
	CUS_ID INT,
    SUPP_ID INT,
    RAT_RATSTARS INT,
    FOREIGN KEY(CUS_ID) REFERENCES Customer(CUS_ID),
    FOREIGN KEY(SUPP_ID) REFERENCES Supplier(SUPP_ID)
);

DESC Rating;

/* Insert into th Tables */

INSERT INTO Supplier VALUES
	(1,	"Rajesh Retails", "Delhi", 1234567890),
    (2,	"Appario Ltd.", "Mumbai", 2589631470),
    (3,	"Knome products", "Banglore", 9785462315),
    (4,	"Bansal Retails", "Kochi", 8975463285),
    (5,	"Mittal Ltd.", "Lucknow", 7898456532);

SELECT * FROM Supplier;

INSERT INTO Customer VALUES
	(1, "AAKASH", 9999999999, "DELHI", "M"),
    (2, "AMAN", 9785463215, "NOIDA", "M"),
    (3, "NEHA", 9999999999, "MUMBAI", "F"),
    (4, "MEGHA", 9994562399, "KOLKATA", "F"),
    (5, "PULKIT", 7895999999, "LUCKNOW", "M");

SELECT * FROM Customer;

INSERT INTO Category VALUES
	(1, "BOOKS"),
    (2, "GAMES"),
    (3, "GROCERIES"),
    (4, "ELECTRONICS"),
    (5, "CLOTHES");

SELECT * FROM Category;

INSERT INTO Product VALUES
	(1,	"GTA V", "DFJDJFDJFDJFDJFJF", 2),
    (2,	"TSHIRT", "DFDFJDFJDKFD", 5),
    (3,	"ROG LAPTOP", "DFNTTNTNTERND", 4),
    (4,	"OATS", "REURENTBTOTH", 3),
    (5,	"HARRY POTTER", "NBEMCTHTJTH", 1);

SELECT * FROM Product;

INSERT INTO ProductDetails VALUES
	(1, 1, 2, 1500),
    (2, 3, 5, 30000),
    (3, 5, 1, 3000),
    (4, 2, 3, 2500),
    (5, 4, 1, 1000);

SELECT * FROM ProductDetails;

INSERT INTO `Order` VALUES
	(20, 1500, "2021-10-12", 3, 5),
    (25, 30500, "2021-09-16", 5, 2),
    (26, 2000, "2021-10-05", 1, 1),
    (30, 3500, "2021-08-16", 4, 3),
    (50, 2000, "2021-10-06", 2, 1);

SELECT * FROM `Order`;

INSERT INTO Rating VALUES
	(1, 2, 2, 4),
	(2,	3, 4, 3),
	(3,	5, 1, 5),
	(4,	1, 3, 2),
	(5,	4, 5, 4);

SELECT * FROM Rating;

/* 
	3)	Display the number of the customer group by their genders who 
		have placed any order of amount greater than or equal to Rs.3000.
*/

SELECT CUS_GENDER , count(CUS_NAME) FROM
	(SELECT CUS_NAME, CUS_GENDER
		FROM Customer
		INNER JOIN
			(SELECT * FROM `Order` WHERE ORD_AMOUNT >=3000) as q ON Customer.CUS_ID = q.CUS_ID) AS output 
GROUP BY CUS_GENDER;


/* 
	4)	Display all the orders along with the product name ordered by a customer having Customer_Id=2.
*/

SELECT Product.PRO_NAME, Q.* 
	FROM Product
	INNER JOIN
    `Order` AS Q ON Q.PROD_ID = Product.PRO_ID WHERE Q.CUS_ID = 2;
    
    
/*
	5)	Display the Supplier details who can supply more than one product.
*/

SELECT * FROM Supplier
	WHERE Supplier.SUPP_ID IN (SELECT SUPP_ID 
		FROM 
        (SELECT SUPP_ID, COUNT(SUPP_ID) FROM ProductDetails GROUP BY SUPP_ID HAVING COUNT(SUPP_ID)>1) AS S);
        
        
/* 
	6)	Find the category of the product whose order amount is minimum
*/

/* OPTION1: Using Where */
SELECT CAT_NAME FROM Category
	WHERE CAT_ID  = (SELECT CAT_ID FROM Product WHERE Product.PRO_ID = (SELECT PROD_ID 
		FROM
			(SELECT * FROM `Order` WHERE ORD_AMOUNT=(SELECT MIN(ORD_AMOUNT) FROM `Order`)) AS Min
		)
	);

/* 
	7)	Display the Id and Name of the Product ordered after “2021-10-05”.
*/

SELECT PRO_ID, PRO_NAME, ORD_DATE FROM Product
	INNER JOIN
	(SELECT* FROM `Order` WHERE ORD_DATE > "2021-10-05") AS Z ON Z.PROD_ID = Product.PRO_ID;

/* 
	8)	Display customer name and gender whose names start or end with character 'A'.
*/

SELECT CUS_NAME, CUS_GENDER FROM Customer WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';

/* 
	9)	Create a stored procedure to display the Rating for a Supplier if any along with 
		the Verdict on that rating if any like if rating >4 then “Genuine Supplier” if rating >2 
        “ADisplayRatingverage Supplier” else “Supplier should not be considered”.
    
*/


DROP PROCEDURE If EXISTS DisplayRating;
DELIMITER //
CREATE PROCEDURE DisplayRating(id INT)
BEGIN
	SELECT S.SUPP_ID, R.RAT_RATSTARS,
		CASE
			WHEN R.RAT_RATSTARS > 4 THEN "Genuine Supplier"
            WHEN R.RAT_RATSTARS > 2 THEN "Average Supplier"
			ELSE "Supplier should not be considered"
		END AS Verdict
        FROM Supplier S, Rating R
		WHERE S.SUPP_ID = R.SUPP_ID AND S.SUPP_ID = id;
END ;
 
CALL DisplayRating(4);
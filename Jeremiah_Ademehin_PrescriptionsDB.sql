

--Create the database
CREATE DATABASE PrescriptionsDB;
USE PrescriptionsDB;
GO
-- Adding primary key constraint to Drugs table
ALTER TABLE Drugs
ADD CONSTRAINT PK_Drugs PRIMARY KEY (BNF_CODE)

-- Adding primary key constraint to Prescriptions table
ALTER TABLE Prescriptions
ADD CONSTRAINT PK_Prescriptions PRIMARY KEY (PRESCRIPTION_CODE)

-- Adding primary key constraint to Medical_Practice table
ALTER TABLE Medical_Practice
ADD CONSTRAINT PK_Medical_Practice PRIMARY KEY (PRACTICE_CODE)

-- Adding foreign key constraint to Prescriptions table
ALTER TABLE Prescriptions
ADD CONSTRAINT FK_Prescriptions_Drugs FOREIGN KEY (BNF_CODE) 
REFERENCES Drugs(BNF_CODE)

-- Adding foreign key constraint to Prescriptions table
ALTER TABLE Prescriptions
ADD CONSTRAINT FK_Prescriptions_Medical_Practice FOREIGN KEY (PRACTICE_CODE) 
REFERENCES Medical_Practice(PRACTICE_CODE)


--query that returns details of all drugs which are in the form of tablets or capsules.

SELECT *
FROM Drugs
WHERE BNF_DESCRIPTION LIKE '%tablet%' OR BNF_DESCRIPTION LIKE '%capsule%'


--query that returns the total quantity for each of prescriptions
SELECT p.PRESCRIPTION_CODE, ROUND(CAST(p.QUANTITY * p.ITEMS AS FLOAT), 0) AS TOTAL_QUANTITY
FROM Prescriptions p;

--query that returns a list of the distinct chemical substances which appear inthe Drugs table

SELECT DISTINCT CHEMICAL_SUBSTANCE_BNF_DESCR
FROM Drugs

--query that returns the number of prescriptions for eachBNF_CHAPTER_PLUS_CODE, along with the average cost for that chapter code, and theminimum and maximum prescription costs for that chapter code

SELECT d.BNF_CHAPTER_PLUS_CODE, 
COUNT(p.PRESCRIPTION_CODE) AS num_prescriptions, 
AVG(p.ACTUAL_COST) AS avg_cost, 
MIN(p.ACTUAL_COST) AS min_cost, 
MAX(p.ACTUAL_COST) AS max_cost 
FROM Drugs d 
INNER JOIN Prescriptions p ON d.BNF_CODE = p.BNF_CODE 
GROUP BY d.BNF_CHAPTER_PLUS_CODE 

--query that returns the most expensive prescription prescribed by eachpractice, sorted in descending order by prescription cost

SELECT mp.PRACTICE_NAME, p.ACTUAL_COST
FROM Medical_practice mp
JOIN Prescriptions p ON mp.PRACTICE_CODE = p.PRACTICE_CODE
WHERE p.ACTUAL_COST = (
  SELECT MAX(ACTUAL_COST)
  FROM Prescriptions
  WHERE PRACTICE_CODE = p.PRACTICE_CODE
)
GROUP BY mp.PRACTICE_NAME, p.ACTUAL_COST
HAVING p.ACTUAL_COST > 4000
ORDER BY p.ACTUAL_COST DESC


--Retrieving data of medical practices that have prescribed inhalers.
SELECT PRACTICE_NAME, ADDRESS_1, POSTCODE
FROM Medical_practice
WHERE EXISTS (
    SELECT *
    FROM Prescriptions
    INNER JOIN Drugs ON Prescriptions.BNF_CODE = Drugs.BNF_CODE
    WHERE Drugs.BNF_DESCRIPTION LIKE '%inhaler%'
    AND Prescriptions.PRACTICE_CODE = Medical_practice.PRACTICE_CODE
)


--Average character count of the PRACTICE_NAME column in the Medical_practice table
SELECT 
  AVG(LEN(PRACTICE_NAME)) AS AVG_CHAR_COUNT
FROM 
  Medical_practice;


--The number  and the average cost of prescriptions for each medical practice that has prescribed more than 50 prescriptions in descending order of average cost of prescriptions
SELECT 
    p.PRACTICE_NAME,
    COUNT(*) AS NUM_PRESCRIPTIONS,
    AVG(pr.ACTUAL_COST) AS AVG_COST
FROM 
    Medical_practice p
    JOIN Prescriptions pr ON p.PRACTICE_CODE = pr.PRACTICE_CODE
GROUP BY 
    p.PRACTICE_NAME
HAVING 
    COUNT(*) > 50
ORDER BY 
    AVG_COST DESC;


-- Medical practices with more than 500 prescriptions and the total number of prescriptions made by each practice.

SELECT 
  PRACTICE_NAME,
  COUNT(*) AS TOTAL_PRESCRIPTIONS
FROM 
  Medical_practice p
  JOIN Prescriptions pr ON p.PRACTICE_CODE = pr.PRACTICE_CODE
GROUP BY 
  PRACTICE_NAME
HAVING 
  COUNT(*) > 500
ORDER BY 
  TOTAL_PRESCRIPTIONS DESC;


--Top 10 medical practices that have the highest average cost per prescription
SELECT TOP 10
    p.PRACTICE_NAME,
    AVG(pr.ACTUAL_COST) AS AVG_COST_PER_PRESCRIPTION
FROM 
    Medical_practice p
    JOIN Prescriptions pr ON p.PRACTICE_CODE = pr.PRACTICE_CODE
GROUP BY 
    p.PRACTICE_NAME
ORDER BY 
    AVG_COST_PER_PRESCRIPTION DESC;













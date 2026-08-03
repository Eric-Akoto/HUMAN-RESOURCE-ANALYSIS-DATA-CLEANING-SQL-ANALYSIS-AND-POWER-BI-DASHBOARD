SET SQL_MODE = '';

-- DATA CLEANING
SELECT *
FROM hr_table;

-- CREATING AND INSERTING DATA INTO A STAGING TABLE
DROP TABLE 
IF EXISTS hr_staging;

CREATE TABLE hr_staging
LIKE hr_table;

INSERT INTO hr_staging
SELECT *
FROM hr_table;

SELECT *
FROM hr_staging;


-- CHANGING SOME COLUMN NAMES 
ALTER TABLE hr_staging
RENAME COLUMN ï»¿id TO id;

ALTER TABLE hr_staging
RENAME COLUMN birthdate TO birth_date;

ALTER TABLE hr_staging
RENAME COLUMN jobtitle TO job_title;

ALTER TABLE hr_staging
RENAME COLUMN termdate TO term_date;

-- STANDARDIZING DATE FORMATS OF DATE COLUMNS
DESCRIBE hr_staging;

-- A. BIRTH_DATE
UPDATE hr_staging
SET birth_date = CASE
					WHEN birth_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
                    WHEN birth_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birth_date, '%m-%d-%Y'), '%Y-%m-%d')
					ELSE NULL
				END;

-- B. HIRE_DATE
UPDATE hr_staging
SET hire_date = CASE
					WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
                    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
					ELSE NULL
				END;

-- C. TERM_DATE
UPDATE hr_staging
SET term_date = DATE(STR_TO_DATE(term_date, '%Y-%m-%d %H:%i:%s UTC'))
WHERE term_date IS NOT NULL AND term_date != '';

SELECT birth_date, hire_date, term_date
FROM hr_staging;

-- CHANGING DATA TYPES OF DATE COLUMNS
-- A. BIRTH_DATE
ALTER TABLE hr_staging
MODIFY COLUMN birth_date DATE;

-- B. HIRE_DATE
ALTER TABLE hr_staging
MODIFY COLUMN hire_date DATE;

-- C. TERM_DATE
ALTER TABLE hr_staging
MODIFY COLUMN term_date DATE;

DESCRIBE hr_staging;

-- ADDING AND INSERTING DATA INTO A NEW COLUMN(AGE)
ALTER TABLE hr_staging
ADD COLUMN age INT;

UPDATE hr_staging
SET age = TIMESTAMPDIFF(YEAR, birth_date, CURDATE());

SELECT age
FROM hr_staging;

-- DETECTING OUTLIERS IN BIRTH_DATE COLUMN
SELECT birth_date, age
FROM hr_staging
WHERE age < 0;

-- TRANSFORMING OUTLIERS IN BIRTH_DATE COLUMN
SELECT 
		TIMESTAMPDIFF(YEAR, new_date, CURDATE()) AS new_age
FROM (
		SELECT birth_date, age,
				DATE_ADD(birth_date, INTERVAL -100 YEAR) AS new_date
		FROM hr_staging
		WHERE age < 0
	) AS subquery;
    
UPDATE hr_staging
SET birth_date = DATE_ADD(birth_date, INTERVAL -100 YEAR)
WHERE age < 0;

UPDATE hr_staging
SET age = TIMESTAMPDIFF(YEAR, birth_date, CURDATE())
WHERE age < 0;

SELECT birth_date, age
FROM hr_staging
WHERE age < 0;

-- DETECTING OTHER OUTLIERS IN THE BIRTH_DATE COLUMN
SELECT birth_date,
		hire_date,
        TIMESTAMPDIFF(YEAR, birth_date, hire_date) AS emp_age
FROM hr_staging
HAVING emp_age < 18;

SELECT MIN(emp_age), MAX(emp_age)
FROM (
		SELECT birth_date,
				hire_date,
				TIMESTAMPDIFF(YEAR, birth_date, hire_date) AS emp_age
		FROM hr_staging
		HAVING emp_age < 18
	) AS sub;
    

SELECT birth_date,
		hire_date,
        TIMESTAMPDIFF(YEAR, birth_date, hire_date) AS emp_age,
        DATE_ADD(birth_date, INTERVAL -20 YEAR) AS new_bdate
FROM hr_staging
HAVING emp_age < 18;

SELECT *,
	TIMESTAMPDIFF(YEAR, new_bdate, hire_date) AS new_age_diff
FROM (
		SELECT birth_date,
				hire_date,
				TIMESTAMPDIFF(YEAR, birth_date, hire_date) AS emp_age,
				DATE_ADD(birth_date, INTERVAL -20 YEAR) AS new_bdate
		FROM hr_staging
		HAVING emp_age < 18
	) AS new_table;
    
-- TRANSFORMING OTHER OUTLIERS IN THE BIRTH_DATE COLUMN
-- ADDING A NEW COLUMN(AGE_AT_EMPLOYENT)
ALTER TABLE hr_staging
ADD COLUMN age_at_employment INT;

UPDATE hr_staging
SET age_at_employment = TIMESTAMPDIFF(YEAR, birth_date, hire_date);

SELECT age_at_employment
FROM hr_staging
WHERE age_at_employment < 18;

-- UPDATING BIRTH_DATE COLUMN TO TRANSFORM OUTLIERS
UPDATE hr_staging
SET birth_date = DATE_ADD(birth_date, INTERVAL -20 YEAR)
WHERE age_at_employment < 18;

UPDATE hr_staging
SET age = TIMESTAMPDIFF(YEAR, birth_date, CURDATE())
WHERE age_at_employment < 18;

UPDATE hr_staging
SET age_at_employment = TIMESTAMPDIFF(YEAR, birth_date, hire_date)
WHERE age_at_employment < 18;

SELECT birth_date,
		hire_date,
        age,
        age_at_employment
FROM hr_staging
WHERE age_at_employment < 18;

SELECT *
FROM hr_staging;

-- SETTING TERM_DATES WITH VALUE (0000-00-00) TO DATE OF EMPLOYEE RETIREMENT
SELECT *,
		DATE_ADD(birth_date, INTERVAL 67 YEAR) AS retirement_year
FROM hr_staging
WHERE term_date = '0000-00-00';

UPDATE hr_staging
SET term_date = DATE_ADD(birth_date, INTERVAL 67 YEAR)
WHERE term_date = '0000-00-00';

SELECT *
FROM hr_staging
WHERE term_date = '0000-00-00';

-- ADDING A NEW COLUMN(FULL_NAME) AND REMOVING SOME COLUMNS(FIRST_NAME & LAST_NAME)
SELECT 
		CONCAT(first_name,' ',last_name)
FROM hr_staging;

ALTER TABLE hr_staging
ADD COLUMN full_name TEXT AFTER last_name; 

UPDATE hr_staging
SET full_name = CONCAT(first_name,' ',last_name);

UPDATE hr_staging
SET full_name = 'Laurette Stango'
WHERE full_name = 'L;urette Stango';

ALTER TABLE hr_staging
DROP COLUMN first_name;

ALTER TABLE hr_staging
DROP COLUMN last_name;

-- DETECTING & REMOVING DUPLICATES
SELECT *,
		ROW_NUMBER() OVER(PARTITION BY id) AS row_num
FROM hr_staging;

WITH duplicates AS (
		SELECT *,
				ROW_NUMBER() OVER(PARTITION BY id) AS row_num
		FROM hr_staging
)
SELECT *
FROM duplicates
WHERE row_num > 1;

-- NO DUPLICATES FOUND

-- CREATING A NEW COLUMN(EMPLOYEE_TURNOVER) FOR ANALYSIS
SELECT *,
		CASE
			WHEN term_date <= CURDATE() THEN 1
            ELSE 0 
		END AS turnover
FROM hr_staging
WHERE term_date <= CURDATE();

ALTER TABLE hr_staging
ADD COLUMN turnover INT;

UPDATE hr_staging
SET turnover = CASE
					WHEN term_date <= CURDATE() THEN 1
                    ELSE 0
				END;
                
SELECT ROUND(AVG(turnover),2)
FROM hr_staging;

SELECT SUM(turnover), COUNT(*)
FROM hr_staging;

-- CREATING A NEW COLUMN(EMPLOYEE_TENURE) FOR ANALYSIS
SELECT *,
        TIMESTAMPDIFF(YEAR, hire_date, term_date) AS avg_emp_tenure
FROM hr_staging;

ALTER TABLE hr_staging
ADD COLUMN emp_tenure INT;

UPDATE hr_staging
SET emp_tenure = TIMESTAMPDIFF(YEAR, hire_date, term_date);

SELECT ROUND(AVG(emp_tenure),0)
FROM hr_staging;

SELECT SUM(emp_tenure), COUNT(*)
FROM hr_staging;

SELECT *
FROM hr_staging;
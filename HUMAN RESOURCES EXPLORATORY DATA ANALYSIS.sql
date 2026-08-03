SET SQL_MODE = '';

-- EXPLORATORY DATA ANALYSIS QUESTIONS

-- 1. EMPLOYEE DEMOGRAPHICS
-- A. HOW MANY EMPLOYEES ARE CURRENTLY IN THE ORGANIZATION?       
SELECT COUNT(*)
FROM hr_staging
WHERE age < 67 AND
		term_date > CURDATE();

-- B. WHAT IS THE GENDER DISTRIBUTION OF EMPLOYEES?
SELECT gender, COUNT(*) AS hires
FROM hr_staging
GROUP BY gender
ORDER BY hires DESC;

-- C. WHAT IS THE RACIAL OR ETHNIC DISTRIBUTION OF EMPLOYEES?
SELECT race, COUNT(*) AS hires
FROM hr_staging
GROUP BY race
ORDER BY hires DESC;

-- D. WHAT ARE THE AVERAGE, OLDEST AND YOUNGEST AGE OF EMPLOYEES?
SELECT ROUND(AVG(age),0) AS average_age, 
		MAX(age) AS oldest_age, 
        MIN(age) AS youngest_age
FROM hr_staging;

-- E. WHAT IS THE AVERAGE AGE BY GENDER?
SELECT gender, 
		ROUND(AVG(age),0) AS average_age
FROM hr_staging
GROUP BY gender;

-- F. WHAT IS THE AVERAGE EMPLOYEE AGE BY DEPARTMENT?
SELECT department, 
		ROUND(AVG(age),0) AS average_age
FROM hr_staging
GROUP BY department;

-- G. HOW MANY EMPLOYEES FALL INTO EACH AGE GROUP?
SELECT
	CASE 
		WHEN age >= 18 AND age <= 25 THEN '18-25'
		WHEN age >= 26 AND age <= 35 THEN '26-35'
		WHEN age >= 36 AND age <= 45 THEN '36-45'
		WHEN age >= 46 AND age <= 55 THEN '46-55'
		ELSE '56+'
	END AS age_group,
    COUNT(*) AS count
FROM hr_staging
GROUP BY age_group
ORDER BY age_group;


-- 2. HIRING ANALYSIS
-- A. HOW MANY EMPLOYEES WHERE HIRED EACH YEAR?
SELECT year,
		COUNT(*) AS hires
FROM (
		SELECT *,
				YEAR(hire_date) AS year
		FROM hr_staging
	) AS cur_employees
GROUP BY year
ORDER BY year DESC;

-- B. WHAT IS THE HIRING TREND OVER TIME(MONTH)?
SELECT month,
		COUNT(*) AS hires
FROM (
		SELECT *,
				MONTHNAME(hire_date) AS month
		FROM hr_staging
	) AS cur_employees
GROUP BY month
ORDER BY MONTH(hire_date);

-- C. WHICH DEPARTMENT HIRES THE MOST EMPLOYEES?
SELECT department, 
		COUNT(*) AS hires
FROM (
		SELECT *
		FROM hr_staging
	) AS cur_employees
GROUP BY department
ORDER BY hires DESC;

-- D. WHICH JOB TITLE HAS THE HIGHEST NUMBER OF HIRES?
SELECT job_title, 
		COUNT(*) AS hires
FROM hr_staging
GROUP BY job_title
ORDER BY hires DESC;

-- E. WHAT IS THE AVERAGE AGE AT EMPLOYMENT
SELECT 
	ROUND(AVG(age_at_employment),0) AS avg_age_at_employment
FROM hr_staging;


-- 3. DEPARTMENT & JOB TITLE ANALYSIS
-- A. WHAT IS THE GENDER DISTRIBUTION WITHIN EACH DEPARTMENT?
SELECT department, 
		gender,
		COUNT(*) AS hires
FROM hr_staging
GROUP BY department, gender
ORDER BY hires DESC;

-- B. WHICH DEPARTMENT HAS THE HIGHEST EMPLOYEE TURNOVER RATE?
SELECT department,
		COUNT(*),
        SUM(turnover),
        ROUND(AVG(turnover),2) AS turnover_rate
FROM hr_staging
GROUP BY department
ORDER BY turnover_rate DESC;

-- C. WHICH DEPARTMENT HAS THE LONGEST EMPLOYEE TENURE?
SELECT department,
        ROUND(AVG(emp_tenure),0) AS avg_emp_tenure
FROM hr_staging
GROUP BY department
ORDER BY avg_emp_tenure DESC;

-- D. WHICH JOB TITLE HAS THE HIGHEST TURNOVER RATE? 
SELECT job_title,
		COUNT(*),
        SUM(turnover),
        ROUND(AVG(turnover),2) AS turnover_rate
FROM hr_staging
GROUP BY job_title
ORDER BY turnover_rate DESC;

-- E. WHICH JOB TITLE HAS THE LONGEST EMPLOYEE TENURE?
SELECT job_title,
        ROUND(AVG(emp_tenure),0) AS avg_emp_tenure
FROM hr_staging
GROUP BY job_title
ORDER BY avg_emp_tenure DESC;


-- 4. EMPLOYEE TURNOVER & EMPLOYMENT DURATION ANALYSIS
-- A. HOW MANY EMPLOYEES HAVE LEFT THE COMPANY?
SELECT COUNT(*)
FROM hr_staging
WHERE age >= 67 OR
		term_date <= CURDATE();

-- B. WHAT IS THE EMPLOYEE TURNOVER RATE?
SELECT 
	ROUND(AVG(turnover),2) AS turnover_rate
FROM hr_staging;
    
-- C. WHICH YEAR EXPERIENCED THE HIGHEST NUMBER OF TERMINATIONS?
SELECT YEAR(term_date) AS year,
		COUNT(*) AS hires
FROM hr_staging
WHERE term_date <= CURDATE()
GROUP BY year
ORDER BY year;

-- D. WHAT IS THE AVERAGE EMPLOYEE TENURE?
SELECT 
		ROUND(AVG(emp_tenure),0) AS avg_emp_tenure
FROM hr_staging;
    
-- E. WHICH EMPLOYEES HAVE WORKED THE LONGEST
SELECT full_name,
		TIMESTAMPDIFF(YEAR, hire_date, term_date) AS emp_tenure
FROM hr_staging
GROUP BY full_name
ORDER BY emp_tenure DESC;


-- 5. GEOGRAPHICAL ANALYSIS
-- A. HOW ARE EMPLOYEES DISTRIBUTED ACROSS LOCATION?
SELECT location, COUNT(location)
FROM hr_staging
GROUP BY location;

-- B. WHICH CITY HAS THE HIGHEST NUMBER OF EMPLOYEES?
SELECT location_city, COUNT(*) AS hires
FROM hr_staging
GROUP BY location_city
ORDER BY hires DESC;

-- C. WHICH STATE HAS THE HIGHEST NUMBER OF EMPLOYEES?
SELECT location_state, COUNT(*) AS hires
FROM hr_staging
GROUP BY location_state
ORDER BY hires DESC;

-- D. WHAT IS THE AVERAGE EMPLOYEE AGE BY LOCATION, CITY & STATE?
SELECT location, 
        location_state, 
		location_city, 
        ROUND(AVG(age), 0) AS avg_age
FROM hr_staging
GROUP BY location_city
ORDER BY location;


-- KEY PERFORMANCE INDICATORS(KPIs)
-- A. TOTAL EMPLOYEES
SELECT COUNT(*) AS total_employees
FROM hr_staging;

-- B. ACTIVE EMPLOYEES
SELECT COUNT(*) AS active_employees
FROM hr_staging
WHERE age < 67 AND
		term_date > CURDATE();

-- C. TERMINATED EMPLOYEES
SELECT COUNT(*) AS terminated_employees
FROM hr_staging
WHERE term_date <= CURDATE();

-- D. EMPLOYEE TURNOVER RATE
SELECT 
	ROUND(AVG(turnover),2) AS turnover_rate
FROM hr_staging;
    
-- E. AVERAGE EMPLOYEE AGE
SELECT ROUND(AVG(age), 0) AS avg_employees_age
FROM hr_staging;

-- F. AVERAGE EMPLOYEE TENURE
SELECT 
		ROUND(AVG(emp_tenure),0) AS avg_emp_tenure
FROM hr_staging;
    
-- G. TOTAL DISTINCT DEPARTMENTS
SELECT COUNT(DISTINCT(department)) AS total_departments
FROM hr_staging;

-- H. TOTAL DISTINCT JOB TITLES
SELECT COUNT(DISTINCT(job_title)) AS total_job_titles
FROM hr_staging;

-- I. TOTAL MALE EMPLOYEES
SELECT COUNT(*) AS total_male_employees
FROM hr_staging
WHERE gender = 'Male';

-- J. TOTAL FEMALE EMPLOYEES
SELECT COUNT(*) AS total_female_employees
FROM hr_staging
WHERE gender = 'female';

-- K. AVERAGE AGE AT EMPLOYMENT
SELECT ROUND(AVG(age_at_employment), 0) AS avg_age_at_employment
FROM hr_staging;

SELECT *
FROM hr_staging;
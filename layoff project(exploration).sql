-- Exploratory data analysis 

SELECT*
FROM layoff_staging2


SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoff_staging2


--looking at the company that laid off 100% of their staffs 
SELECT*
FROM layoff_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC

--sum of total laid off per company 
SELECT company, SUM(total_laid_off) AS sumoftotallaidoff 
FROM layoff_staging2
GROUP BY company
ORDER BY 2 DESC

SELECT MIN(date),MAX(date)
FROM layoff_staging2

--SUM OF TOTAL LAID OFF PER INDUSTRY 
SELECT industry, SUM(total_laid_off) suoftotallaidofperindustry 
FROM layoff_staging2
GROUP BY industry
ORDER BY 2 DESC

--SUM OF TOTAL LAID OFF PER COUNTRY 
SELECT country, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY country
ORDER BY 2 DESC

--SUM OF TOTAL LAID OFF PER YEAR
SELECT YEAR (date) as year, SUM(total_laid_off) as [sum (total_laid_off)]
FROM layoff_staging2
GROUP BY YEAR (date)
ORDER BY 1 DESC

--SUM OF TOTAL LAID OFF PER STAGE 
SELECT stage, SUM(total_laid_off) as [sum (total_laid_off)]
FROM layoff_staging2
GROUP BY stage
ORDER BY 2 DESC


--rolling total of layoffs based of a month 

SELECT*
FROM layoff_staging2

--THIS THE THE SUM OF TOTAL LAID OF PER MONTH 
SELECT SUBSTRING(DATE,1,7) AS [MONTH], SUM(total_laid_off)
FROM layoff_staging2
WHERE SUBSTRING(DATE,1,7) IS NOT NULL
GROUP BY SUBSTRING(DATE,1,7)
ORDER BY 1 ASC


--WE WANT TO DO ROLLING TOTAL OF THE ABOVE 
WITH rolling_total AS 
(
SELECT SUBSTRING(DATE,1,7) AS [MONTH], SUM(total_laid_off) as total_off
FROM layoff_staging2
WHERE SUBSTRING(DATE,1,7) IS NOT NULL
GROUP BY SUBSTRING(DATE,1,7)
)
SELECT [MONTH],total_off , SUM(total_off) OVER(ORDER BY [MONTH]) AS rolling_total
FROM rolling_total;

--we want to see the companies and see how much they layingoff per year
SELECT company, SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company
ORDER BY 2 DESC
 
 --we take the company and date(Year of the date) looking at the total_lay_off
SELECT company,YEAR(date), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(date)
ORDER BY company ASC

--lets say we want to rank the year they laidoff the most employeee
SELECT company,YEAR(date), SUM(total_laid_off)
FROM layoff_staging2
GROUP BY company, YEAR(date)
ORDER BY 3 DESC

--NOW WE WANT TO RANK THEM 
WITH company_year AS
(
SELECT company,YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY company, YEAR(date)
)
SELECT *
FROM company_year

--we want to partition it based on the years and rank it based of the total_laid_off
--so we get to see who laid off the most people per year
WITH company_year AS
(
SELECT company,YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY company, YEAR(date)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS rank_in_year
FROM company_year
ORDER BY rank_in_year


--to get top5 company per year(we'll use the above as another cte and query off that
WITH company_year AS
(
SELECT company,YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoff_staging2
GROUP BY company, YEAR(date)
), 
company_year_rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS rank_in_year
FROM company_year
WHERE year IS NOT NULL
)
select *
FROM company_year_rank
WHERE rank_in_year <=5


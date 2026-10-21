/* ============================================================
   Staff Layoffs 2020-2023: T-SQL analysis
   Database : LayoffDB (SQL Server)
   Table    : dbo.layoffs_staging  (1,995 rows after cleaning;
              1,994 once the one undated row is excluded)
   Author   : Adebayo Ajayi
   ============================================================ */


/* ------------------------------------------------------------
   Q1. How complete is the data?
   Total rows, rows with no date, rows with no layoff count,
   rows with no percentage.
   Result: 1,995 / 1 / 378 / 423
   ------------------------------------------------------------ */
SELECT COUNT(*)                              AS total_rows,
       COUNT(*) - COUNT([date])              AS rows_no_date,
       COUNT(*) - COUNT(total_laid_off)      AS rows_no_total_laid_off,
       COUNT(*) - COUNT(percentage_laid_off) AS rows_no_percentage
FROM dbo.layoffs_staging;


/* ------------------------------------------------------------
   Q2. Which 5 industries had the most layoffs, and what share
   of all layoffs is each?
   Result: the top 5 industries together account for 48.8%.
   ------------------------------------------------------------ */
WITH Q2 AS (
    SELECT industry, SUM(total_laid_off) AS total
    FROM dbo.layoffs_staging
    GROUP BY industry
)
SELECT TOP 5
       industry,
       total,
       ROUND(total * 100.0 / (SELECT SUM(total) FROM Q2), 2) AS pct_of_total
FROM Q2
ORDER BY total DESC;


/* ------------------------------------------------------------
   Q3. For each funding stage: how many companies had layoffs,
   and what was the average percentage of staff laid off?
   No WHERE filter, so every company is counted; AVG skips NULLs
   by itself. percentage_laid_off is stored as a fraction
   (0.25 = 25%), hence * 100.
   ------------------------------------------------------------ */
SELECT COUNT(DISTINCT company)                    AS num_company,
       ROUND(AVG(percentage_laid_off) * 100, 1)   AS avg_pct_laid_off,
       stage
FROM dbo.layoffs_staging
GROUP BY stage
ORDER BY num_company DESC;


/* ------------------------------------------------------------
   Q4. Top 3 countries by total layoffs in each year.
   Result for 2022: United States 106,520; India 14,224;
   Netherlands 5,120.
   ------------------------------------------------------------ */
WITH Country_year AS (
    SELECT Country,
           YEAR([date]) AS yr,
           SUM(total_laid_off) AS total
    FROM dbo.layoffs_staging
    WHERE [date] IS NOT NULL
    GROUP BY Country, YEAR([date])
),
RANKED AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY yr ORDER BY total DESC) AS rnk
    FROM Country_year
)
SELECT yr, rnk, Country, total
FROM RANKED
WHERE rnk <= 3
ORDER BY yr, rnk;


/* ------------------------------------------------------------
   Q5. The 5 months with the biggest increase in layoffs over the
   previous month, with the running total at the end of each.
   Result: biggest increase is 2023-01-01 (+74,385). The running
   total counts from the first month in the data, because window
   functions are calculated before TOP picks its rows.
   ------------------------------------------------------------ */
WITH monthly AS (
    SELECT DATEFROMPARTS(YEAR([date]), MONTH([date]), 1) AS month_start,
           SUM(total_laid_off) AS monthly_total
    FROM dbo.layoffs_staging
    WHERE [date] IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR([date]), MONTH([date]), 1)
)
SELECT TOP 5
       month_start,
       monthly_total,
       LAG(monthly_total) OVER (ORDER BY month_start) AS prev_month,
       monthly_total - LAG(monthly_total) OVER (ORDER BY month_start) AS change_vs_prev,
       SUM(monthly_total) OVER (ORDER BY month_start) AS running_total
FROM monthly
ORDER BY change_vs_prev DESC;


/* ------------------------------------------------------------
   Q6. Companies with layoffs in BOTH 2022 and 2023, with their
   combined total. COUNT(DISTINCT YEAR) = 2 means "appeared in
   both years". Should return 93 companies (same as the self-join
   version).
   ------------------------------------------------------------ */
SELECT company,
       SUM(total_laid_off) AS combined_total
FROM dbo.layoffs_staging
WHERE YEAR([date]) IN (2022, 2023)
GROUP BY company
HAVING COUNT(DISTINCT YEAR([date])) = 2
ORDER BY combined_total DESC;

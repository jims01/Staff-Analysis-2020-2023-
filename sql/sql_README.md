# T-SQL Analysis (SQL Server)

After rebuilding the cleaning in SQL Server, I wrote six queries in T-SQL to answer business questions about the cleaned table (`dbo.layoffs_staging`). The full script is in [`layoffs_analysis.sql`](layoffs_analysis.sql), with a comment above each query.

| # | Question | Techniques | Finding |
|---|---|---|---|
| 1 | How complete is the data? | `COUNT(*)` vs `COUNT(column)` | 1,995 rows: 1 has no date, 378 have no layoff count, 423 have no percentage |
| 2 | Which 5 industries had the most layoffs, and what share of the total? | CTE, `GROUP BY`, scalar subquery, decimal division | The top 5 industries account for 48.8% of all layoffs (Consumer, Retail and Other lead) |
| 3 | By funding stage: how many companies, and the average % of staff laid off? | `GROUP BY`, `COUNT(DISTINCT)`, `AVG` | Every company is counted; `AVG` skips NULL percentages |
| 4 | Top 3 countries by layoffs in each year | Two CTEs, `DENSE_RANK() OVER (PARTITION BY ...)` | 2022: United States (106,520), India (14,224), Netherlands (5,120) |
| 5 | Biggest month-on-month increases, with running totals | CTE, `LAG`, running `SUM() OVER` | January 2023 was the biggest jump: 84,714 layoffs, up 74,385 on December 2022 |
| 6 | Companies with layoffs in both 2022 and 2023 | `GROUP BY`, `HAVING COUNT(DISTINCT YEAR(...))` | Cross-checked against a self-join version of the same question |

**Things I checked along the way**
- The monthly running total ends at 383,159, matching the reconciled total in SQL and Power BI.
- Percentages are stored as fractions (0.25 = 25%), so they are multiplied by 100 before display.
- Integer division was avoided by using `100.0`, so shares are not silently truncated to whole numbers.
- A join key that is not unique silently inflates counts (a duplicate lookup row turned 140 India rows into 280), so lookup tables were checked for duplicates before joining.

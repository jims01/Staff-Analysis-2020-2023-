# **Staff Layoffs Analysis (2020–2023)**
---
## Table of Contents
- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results](#results)
- [Data Visualization](#data-visualization)
- [Limitations](#limitations)
- [Next Steps](#next-steps)

### Project Overview
---
This project analyzes global staff layoffs from 2020 to 2023 to provide insights into trends and patterns during this period. It focuses on identifying monthly and cumulative layoffs and ranking the top 5 companies with the highest layoffs in each year.
 
### Dataset
 
The primary dataset used for this analysis is "layoffs.csv", containing global layoff information from 2020 to 2023..
 
### Tools
 
- MySQL - Original data cleaning and Exploratory Data Analysis
  - [Download here](https://mysql.com)
- SQL Server (T-SQL) - Cleaning rebuilt and re-verified, and the source for the Power BI dashboard
  - [Download here](https://www.microsoft.com/sql-server)
- Power BI - Data modelling and DAX measures for an interactive dashboard
  - [Download here](https://powerbi.microsoft.com)
### Data cleaning 
 
*In the initial data preparation phase, the following tasks were performed:*
 
1. Created a staging dataset: Organized raw data for processing.
2. Removed duplicates: Ensured unique records in the dataset.
3. Standardized the data: Unified formatting for consistency.
4. Handled missing values: Populated null or blank values where necessary.
5. Dropped unnecessary columns: Focused only on relevant data fields.
**Row accounting** (reproduced independently in SQL Server and in pandas, with identical results):
 
| Step | Rows | Total layoffs |
|---|---|---|
| Raw file | 2,361 | 386,379 |
| Remove 5 exact duplicate rows | 2,356 | 383,659 |
| Drop 361 rows with neither `total_laid_off` nor `percentage_laid_off` (nothing to analyse) | 1,995 | 383,659 |
| Drop 1 row with no date (500 layoffs, can't be placed in time) | 1,994 | **383,159** |
 
The final table has 1,994 rows. Duplicates were removed with `ROW_NUMBER()` over every column, and missing industries were filled from other rows for the same company.
 
### Exploratory Data Analysis
 
#### Key questions addressed during the analysis include:
 
- What is the overall number of layoffs?
- How many companies shut down between 2020 and 2023?
- Which are the top 5 countries with the most layoffs in each year?
- What is the ranking of the top 5 companies with the most layoffs in each year?
### Data Analysis
 
```sql
with Country_year (Country, Years, Total_laid_off) as
(
select Country, year(`date`),sum(total_laid_off)
from layoffs_staging2
group by Country, year(`date`)
), Country_year_ranking as
(
select*, dense_rank() Over(Partition by years order by Total_laid_off desc) as ranking
from country_year
where years is not null)
 
Select*
From country_year_ranking
where ranking <= 5;
```
### Results
The analysis results are summarized as follow:
- The total layoff between 2020 and 2023: 383,159
- Layoff records where 100% of staff were laid off (a proxy for company shutdowns): 116 rows. This counts rows, not distinct companies.
  
*Top 5 country with the most Lay offs for;*
- 2020: United states, India, Netherlands, Brazil and Singapore.
- 2021: United states, india, China, Germany and Canada
- 2022: United States, India, Netherlands, Brazil and Canada
- 2023: United States, Sweden, Netherlands, India and Germany
  
*Top 5 company with the most lay offs for;*
- 2020: Uber, Booking.com, Groupon, Swiggy and Arbirb.
- 2021: Bytedance, Katerra, Zillow, InstaCart and WhiteHat Jr
- 2022: Meta, Amazon, Cisco, Pleoton and Carvana/Philips
- 2023: Google, Microsoft, Ericsson, Amazon/Salesforce and Dell.
### Data Visualization
 
To extend the SQL analysis, the cleaned dataset was rebuilt as an interactive Power BI dashboard, with a focus on practicing DAX and time-intelligence patterns.
 
**Data model**
- A dedicated date table was built with `CALENDAR()` spanning the data's full date range, and explicitly marked as the model's official date table, which is what enables time-intelligence functions like `SAMEPERIODLASTYEAR` to work correctly.
**Measures**
- `Total Layoffs` — `SUM` of layoffs
- `Number of Companies` — `DISTINCTCOUNT` of companies with a recorded layoff (1,627; see the note on case-insensitivity below)
- `Avg Percentage Laid Off` — `AVERAGE` of the percentage of staff laid off
- `Layoffs LY` — prior-year layoffs for the same period, using `CALCULATE` with `SAMEPERIODLASTYEAR`
- `YoY % Change` — year-over-year change, using `DIVIDE` to avoid divide-by-zero errors
**Dashboard**
- KPI cards for the headline totals
- A year-by-year trend chart, with 2023 visually flagged in a different color since the data only covers January–March of that year — the YoY comparison for 2023 is real, but it compares partial years, not full ones
- Layoffs broken down by industry and by funding stage, each sorted to surface the largest categories first
- An interactive year slicer
**Data-quality decisions**
- One row had no recorded date at all and was excluded, since it couldn't be placed in any time-based analysis
- Rows with no recorded funding stage (`NULL`) appear as "(Blank)" in the stage breakdown rather than being dropped, so the chart still sums to the full total
**Reconciling the SQL and Power BI totals:** my first Power BI build showed ~193K layoffs and ~820 companies, against 383,159 in the SQL results. The cause turned out to be the input, not the cleaning logic: the CSV I had loaded into Power BI had been truncated to its first 1,000 rows, a default row limit in the tool I used to export it. I found this by rebuilding the cleaning in SQL Server, accounting for every row (table above) and reproducing 383,159 exactly, then connecting Power BI directly to the cleaned SQL Server table instead of a CSV. The dashboard now matches the SQL totals: 383,159 layoffs, 25.81% average percentage laid off, and the same yearly figures (2020: 80,998; 2021: 15,823; 2022: 160,661; 2023: 125,677).
 
**Why 1,627 companies and not 1,632:** `DISTINCTCOUNT` in Power BI ignores letter case, so five names that differ only by case are counted once (AppGate/Appgate, ByteDance/Bytedance, ClearCo/Clearco, CureFit/Curefit, SalesLoft/Salesloft). A case-sensitive count gives 1,632. Treating these as the same company is the more accurate reading, so 1,627 is the figure used.
 
### Limitations
 A limitation of this analysis is the absence of data on the number of staff remaining after the layoffs.
 
### Next Steps
- Standardise company-name casing during cleaning, so the SQL and Power BI company counts agree by construction
- Replace the "(Blank)" funding stage with an explicit "Unknown" label
- Make the `Year Status` measure detect partial years from the data (2023 only covers January to March)
- Detailed Reporting: Enhance the analysis with narrative insights and visual representations.
😄

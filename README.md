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
- [References](#references)


### Project Overview
---
This project analyzes global staff layoffs from 2020 to 2023 to provide insights into trends and patterns during this period. It focuses on identifying monthly and cumulative layoffs and ranking the top 5 companies with the highest layoffs in each year.

### Dataset

The primary dataset used for this analysis is "layoffs.csv", containing global layoff information from 2020 to 2023..

### Tools

- MySQL- Data cleaning and Exploratory Data Analysis
  - [Download here](https://mysql.com)
- Power BI - Data modelling and DAX measures for an interactive dashboard
  - [Download here](https://powerbi.microsoft.com)

### Data cleaning 

*In the initial data preparation phase, the following tasks were performed:*

1. Created a staging dataset: Organized raw data for processing.
2. Removed duplicates: Ensured unique records in the dataset.
3. Standardized the data: Unified formatting for consistency.
4. Handled missing values: Populated null or blank values where necessary.
5. Dropped unnecessary columns: Focused only on relevant data fields.

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
- The total number of company that shutdown: 116
  
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
- `Number of Companies` — `DISTINCTCOUNT` of companies with a recorded layoff
- `Avg Percentage Laid Off` — `AVERAGE` of the percentage of staff laid off
- `Layoffs LY` — prior-year layoffs for the same period, using `CALCULATE` with `SAMEPERIODLASTYEAR`
- `YoY % Change` — year-over-year change, using `DIVIDE` to avoid divide-by-zero errors

**Dashboard**
- KPI cards for the headline totals
- A year-by-year trend chart, with 2023 visually flagged in a different color since the data only covers January–March of that year - the YoY comparison for 2023 is real, but it compares partial years, not full ones
- Layoffs broken down by industry and by funding stage, each sorted to surface the largest categories first
- An interactive year slicer

**Data-quality decisions**
- One row had no recorded date at all and was excluded, since it couldn't be placed in any time-based analysis
- Rows with no recorded funding stage (`NULL`) were excluded from the stage breakdown

**A note on the totals:** this dashboard's totals (~193K layoffs, ~820 companies) are noticeably different from the SQL results above (383,159 layoffs, 116 companies). This project was originally built by following a tutorial, and the exact cleaning logic behind the SQL numbers - in particular, how missing `total_laid_off` values were handled - wasn't something I tracked closely enough at the time to reconstruct with confidence. The Power BI analysis excludes rows with missing values rather than estimating them, which is almost certainly part of the gap, but I can't currently confirm it's the whole story. Flagging this honestly rather than presenting two unexplained numbers side by side.

### Limitations
 A limitation of this analysis is the absence of data on the number of staff remaining after the layoffs.

### Next Steps
- Reconcile the totals between the SQL and Power BI analyses, and document the cleaning logic clearly enough this time to avoid the same gap in future
- Detailed Reporting: Enhance the analysis with narrative insights and visual representations.

😄

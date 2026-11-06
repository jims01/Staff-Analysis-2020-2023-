### AWS Athena: querying the cleaned data in S3 (eu-west-2)

To practise cloud data engineering, I loaded the cleaned layoffs file into Amazon S3, queried it with Amazon Athena, and converted it to Parquet.

**Pipeline:** cleaned CSV in S3 → Athena external table → `CREATE TABLE AS SELECT` (CTAS) → typed Parquet table in S3

| Step | What I did |
|---|---|
| 1. Store | Uploaded the cleaned CSV (1,994 rows) to its own S3 folder, so the table location holds only that file |
| 2. Query the CSV | Created an external table with every column as `string`, because missing values are written as the text `NULL`; cast safely in queries with `TRY_CAST` |
| 3. Convert | Used a CTAS to write a Parquet table with proper types (integer, double, date) and real NULLs |
| 4. Compare | Ran the same `SUM` on both tables and compared the data scanned |

**Checks**
- Row count in Athena: 1,994 (header row skipped with `skip.header.line.count`).
- `SUM(total_laid_off)` on the CSV table and on the Parquet table: 383,159 in both, matching the SQL Server and Power BI reconciliation.
- Data scanned for the same `SUM`: 154.79 KB on the CSV vs 3.24 KB on Parquet, about 48x less. Athena bills by data scanned, so the saving grows with the size of the data.

**Things I learned**
- Athena reads every file under a table's S3 prefix, so each table needs a folder of its own.
- Athena must run in the same region as the bucket, and needs an S3 location for query results.
- Athena SQL uses `LIMIT` instead of `TOP`, single quotes mean text (not an alias), and `TRY_CAST` turns bad values into NULL.
- I set up a budget alert before running any queries.

#### Queried the Parquet table from Python with awswrangler (via AWS CloudShell, no access keys) and got the same totals back as a pandas DataFrame.

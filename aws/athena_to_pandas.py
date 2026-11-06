import awswrangler as wr

df = wr.athena.read_sql_query(
    sql="""
        SELECT country, SUM(total_laid_off) AS total
        FROM layoffs_parquet
        GROUP BY country
        ORDER BY total DESC
        LIMIT 5
    """,
    database="layoffs_db",
    ctas_approach=False,
    s3_output="s3://adebayo-gp-pipeline-data-2026/athena-results/",
)
print(df)

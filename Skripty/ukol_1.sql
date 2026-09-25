-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH yearly_wages AS (
    -- Získání unikátních hodnot mezd pro zamezení duplicit ze spojení s cenami
    SELECT DISTINCT
        year,
        industry,
        avg_wage
    FROM t_erik_hrazdira_project_SQL_primary_final
),
wage_growth AS (
    -- Porovnání mzdy s předchozím rokem pomocí okenní funkce LAG
    SELECT 
        year,
        industry,
        avg_wage,
        LAG(avg_wage) OVER (PARTITION BY industry ORDER BY year) AS prev_year_wage
    FROM yearly_wages
)
-- Filtrace pouze těch záznamů, kde došlo k poklesu mzdy, a výpočet procentuálního propadu
SELECT 
    year,
    industry,
    avg_wage,
    prev_year_wage,
    ROUND((avg_wage - prev_year_wage) / prev_year_wage * 100, 2) AS drop_pct
FROM wage_growth
WHERE prev_year_wage IS NOT NULL 
  AND avg_wage < prev_year_wage
ORDER BY year, industry;
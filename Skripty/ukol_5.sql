-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH czech_gdp AS (
    -- Výpočet meziročního procentuálního růstu HDP specificky pro Českou republiku
    SELECT 
        year,
        ROUND(((gdp - LAG(gdp) OVER (ORDER BY year)) / LAG(gdp) OVER (ORDER BY year) * 100)::numeric, 2) AS gdp_growth_pct
    FROM t_erik_hrazdira_project_SQL_secondary_final
    WHERE country = 'Czech Republic'
),
yearly_national_data AS (
    -- Získání průměrné celorepublikové mzdy a průměrné celorepublikové ceny potravin pro každý rok (obdoba úkolu 4)
    SELECT 
        w.year,
        w.nat_wage,
        p.nat_price
    FROM (
        SELECT year, AVG(avg_wage) AS nat_wage 
        FROM (SELECT DISTINCT year, industry, avg_wage FROM t_erik_hrazdira_project_SQL_primary_final) AS dist_w
        GROUP BY year
    ) w
    JOIN (
        SELECT year, AVG(avg_price_per_unit) AS nat_price 
        FROM (SELECT DISTINCT year, food, avg_price_per_unit FROM t_erik_hrazdira_project_SQL_primary_final) AS dist_p
        GROUP BY year
    ) p ON w.year = p.year
),
price_wage_growth AS (
    -- Výpočet meziročního procentuálního nárůstu pro mzdy i ceny potravin
    SELECT 
        year,
        ROUND(((nat_wage - LAG(nat_wage) OVER (ORDER BY year)) / LAG(nat_wage) OVER (ORDER BY year) * 100)::numeric, 2) AS wage_growth_pct,
        ROUND(((nat_price - LAG(nat_price) OVER (ORDER BY year)) / LAG(nat_price) OVER (ORDER BY year) * 100)::numeric, 2) AS price_growth_pct
    FROM yearly_national_data
)
-- Spojení růstu HDP s růstem mezd a cen potravin pro finální porovnání
SELECT 
    g.year,
    g.gdp_growth_pct,
    pw.wage_growth_pct,
    pw.price_growth_pct
FROM czech_gdp g
JOIN price_wage_growth pw 
    ON g.year = pw.year
WHERE g.gdp_growth_pct IS NOT NULL 
  AND pw.wage_growth_pct IS NOT NULL
ORDER BY g.year;
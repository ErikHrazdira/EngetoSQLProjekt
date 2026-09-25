-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH yearly_national_data AS (
    -- Získání průměrné celorepublikové mzdy a průměrné celorepublikové ceny potravin pro každý rok
    SELECT 
        w.year,
        w.nat_wage,
        p.nat_price
    FROM (
        -- Nejprve extrakce unikátních mezd, následně výpočet jejich průměru
        SELECT year, AVG(avg_wage) AS nat_wage 
        FROM (SELECT DISTINCT year, industry, avg_wage FROM t_erik_hrazdira_project_SQL_primary_final) AS dist_w
        GROUP BY year
    ) w
    JOIN (
        -- Nejprve extrakce unikátních cen potravin, následně výpočet jejich průměru
        SELECT year, AVG(avg_price_per_unit) AS nat_price 
        FROM (SELECT DISTINCT year, food, avg_price_per_unit FROM t_erik_hrazdira_project_SQL_primary_final) AS dist_p
        GROUP BY year
    ) p ON w.year = p.year
),
yoy_growth AS (
    -- Výpočet meziročního procentuálního nárůstu pro mzdy i ceny potravin
    SELECT 
        year,
        ROUND(((nat_wage - LAG(nat_wage) OVER (ORDER BY year)) / LAG(nat_wage) OVER (ORDER BY year) * 100)::numeric, 2) AS wage_growth_pct,
        ROUND(((nat_price - LAG(nat_price) OVER (ORDER BY year)) / LAG(nat_price) OVER (ORDER BY year) * 100)::numeric, 2) AS price_growth_pct
    FROM yearly_national_data
)
-- Porovnání obou nárůstů a výpočet jejich rozdílu
SELECT 
    year,
    wage_growth_pct,
    price_growth_pct,
    (price_growth_pct - wage_growth_pct) AS difference_pct
FROM yoy_growth
WHERE wage_growth_pct IS NOT NULL -- Vyřazení prvního roku (nemá předchozí hodnotu)
-- AND (price_growth_pct - wage_growth_pct) > 10 -- Filtr dle zadání (zakomentován - nic by se nezobrazilo, takto alespoň seřazeno od největšího)
ORDER BY difference_pct DESC;
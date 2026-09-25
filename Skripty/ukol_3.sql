-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH food_yearly_prices AS (
    -- Získání unikátních cen potravin pro daný rok
    SELECT DISTINCT
        year,
        food,
        avg_price_per_unit
    FROM t_erik_hrazdira_project_SQL_primary_final
),
yoy_price_growth AS (
    -- Výpočet meziročního procentuálního nárůstu ceny pro každou potravinu
    SELECT 
        year,
        food,
        avg_price_per_unit,
        LAG(avg_price_per_unit) OVER (PARTITION BY food ORDER BY year) AS prev_year_price,
        (avg_price_per_unit - LAG(avg_price_per_unit) OVER (PARTITION BY food ORDER BY year)) 
        / LAG(avg_price_per_unit) OVER (PARTITION BY food ORDER BY year) * 100 AS growth_pct
    FROM food_yearly_prices
)
-- Výpočet průměrného meziročního nárůstu za celé sledované období seřazeného od nejpomalejšího
SELECT 
    food,
    ROUND(AVG(growth_pct)::numeric, 2) AS avg_yoy_growth_pct
FROM yoy_price_growth
WHERE growth_pct IS NOT NULL -- Vyřazení prvního roku (nemá předchozí hodnotu)
GROUP BY 
    food
ORDER BY 
    avg_yoy_growth_pct ASC;
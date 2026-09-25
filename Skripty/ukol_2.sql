-- TASK 2: How many liters of milk and kilograms of bread can be bought in the first and last comparable periods?

WITH comparable_years AS (
    -- 1. Get the very first and very last year available in our merged dataset
    SELECT 
        MIN(year) AS first_year,
        MAX(year) AS last_year
    FROM t_erik_hrazdira_project_SQL_primary_final
),
national_avg_data AS (
    -- 2. Aggregate the national average wage and average price for specific foods in those years
    SELECT 
        year,
        food,
        unit,
        AVG(avg_wage) AS national_avg_wage,
        AVG(avg_price_per_unit) AS avg_food_price
    FROM t_erik_hrazdira_project_SQL_primary_final
    WHERE year IN (SELECT first_year FROM comparable_years) 
       OR year IN (SELECT last_year FROM comparable_years)
    GROUP BY 
        year, 
        food, 
        unit
)
-- 3. Calculate affordable amount (purchasing power)
SELECT 
    year,
    food,
    ROUND(national_avg_wage, 2) AS avg_wage,
    ROUND(avg_food_price, 2) AS avg_price,
    unit,
    ROUND((national_avg_wage / avg_food_price)::numeric, 0) AS affordable_amount
FROM national_avg_data
WHERE food IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový') 
ORDER BY 
    food, 
    year;
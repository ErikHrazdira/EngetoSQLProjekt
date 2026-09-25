-- Vytvoření finální primární tabulky (Primary Final)
CREATE TABLE t_erik_hrazdira_project_SQL_primary_final AS 
SELECT 
    w.year_w AS year,
    w.industry,
    w.avg_wage,
    p.food,
    p.avg_price_per_unit,
    p.unit
FROM t_erik_hrazdira_wages w
JOIN t_erik_hrazdira_prices p 
    ON w.year_w = p.year_p;
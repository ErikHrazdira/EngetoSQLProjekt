-- Vytvoření dodatečné tabulky o dalších evropských státech (Secondary Final)
CREATE TABLE t_erik_hrazdira_project_SQL_secondary_final AS
SELECT 
    c.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM countries c
JOIN economies e 
    ON c.country = e.country
WHERE c.continent = 'Europe' 
  AND e.gdp IS NOT NULL;
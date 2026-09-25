-- Vytvoření pomocné tabulky pro mzdy
-- Účel: Agregace průměrné hrubé mzdy pro jednotlivá odvětví v konkrétních letech.
-- value_type_code = '5958' filtruje čistě průměrné hrubé mzdy.
-- calculation_code = '200' vybírá pouze přepočtený stav (plné úvazky), čímž odstraňuje zkreslení průměru částečnými úvazky.
CREATE TABLE t_erik_hrazdira_wages AS
SELECT 
    cp.payroll_year AS year_w,
    cpib.name AS industry,
    ROUND(AVG(cp.value), 2) AS avg_wage
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib 
    ON cp.industry_branch_code = cpib.code
WHERE cp.value_type_code = '5958'
  AND cp.calculation_code = '200'
  AND cp.value IS NOT NULL
GROUP BY 
    cp.payroll_year, 
    cpib.name;

-- Vytvoření pomocné tabulky pro ceny potravin
-- Účel: Získání průměrné roční ceny pro jednotlivé kategorie potravin.
-- Ceny jsou přepočítány na přesně 1 standardní jednotku (1 kg, 1 l, 1 ks) pomocí dělení sloupcem price_value.
CREATE TABLE t_erik_hrazdira_prices AS
SELECT 
    EXTRACT(YEAR FROM cp.date_from) AS year_p,
    cpc.name AS food,
    ROUND((AVG(cp.value) / cpc.price_value)::numeric, 2) AS avg_price_per_unit,
    cpc.price_unit AS unit
FROM czechia_price cp
JOIN czechia_price_category cpc 
    ON cp.category_code = cpc.code
GROUP BY 
    EXTRACT(YEAR FROM cp.date_from), 
    cpc.name, 
    cpc.price_value, 
    cpc.price_unit;
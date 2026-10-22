SELECT 
    CASE 
        WHEN TRIM(city) = 'Barcelona' THEN 'Spain'
        WHEN TRIM(city) = 'Budapest'  THEN 'Hungary'
        WHEN TRIM(city) = 'Lisbon'    THEN 'Portugal'
        WHEN TRIM(city) = 'Amsterdam' THEN 'Netherlands'
        WHEN TRIM(city) = 'Athens'    THEN 'Greece'
        WHEN TRIM(city) = 'Berlin'    THEN 'Germany'
        WHEN TRIM(city) = 'London'    THEN 'United Kingdom'
        WHEN TRIM(city) = 'Paris'     THEN 'France'
        WHEN TRIM(city) = 'Rome'      THEN 'Italy'
        WHEN TRIM(city) = 'Vienna'    THEN 'Austria'
        WHEN TRIM(city) = 'Madrid'    THEN 'Spain'
        WHEN TRIM(city) = 'Milan'     THEN 'Italy'
        ELSE 'Other'
    END AS calculated_country,
    COUNT(*) AS total_rows
FROM [SILVER].[listings_standardized]
GROUP BY 
    CASE 
        WHEN TRIM(city) = 'Barcelona' THEN 'Spain'
        WHEN TRIM(city) = 'Budapest'  THEN 'Hungary'
        WHEN TRIM(city) = 'Lisbon'    THEN 'Portugal'
        WHEN TRIM(city) = 'Amsterdam' THEN 'Netherlands'
        WHEN TRIM(city) = 'Athens'    THEN 'Greece'
        WHEN TRIM(city) = 'Berlin'    THEN 'Germany'
        WHEN TRIM(city) = 'London'    THEN 'United Kingdom'
        WHEN TRIM(city) = 'Paris'     THEN 'France'
        WHEN TRIM(city) = 'Rome'      THEN 'Italy'
        WHEN TRIM(city) = 'Vienna'    THEN 'Austria'
        WHEN TRIM(city) = 'Madrid'    THEN 'Spain'
        WHEN TRIM(city) = 'Milan'     THEN 'Italy'
        ELSE 'Other'
    END;

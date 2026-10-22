USE [AirbnbPricesEUROPE]; 
GO

CREATE SCHEMA silver;
GO

CREATE VIEW SILVER.vw_cleaned_historical_premium AS
SELECT 
    ID AS historical_id, -- <-- Removed TRIM since ID is already an integer
    City_Name AS city_name,
    CASE WHEN Day_type = 'weekends' THEN 1 ELSE 0 END AS is_weekend,
    TRY_CAST(realSum AS NUMERIC(12,4)) AS price_total,
    TRY_CAST(dist AS NUMERIC(10,4)) AS center_distance_km,
    TRY_CAST(person_capacity AS INT) AS person_capacity,
    TRY_CAST(bedrooms AS INT) AS bedrooms_count,
    CASE WHEN host_is_superhost = 'TRUE' THEN 1 ELSE 0 END AS is_superhost,
    CASE 
        WHEN biz = '1' THEN 'Commercial Portfolio (>4 listings)'
        WHEN multi = '1' THEN 'Multi-Listing Manager (2-4 listings)'
        ELSE 'Single Listing Property'
    END AS host_tier
FROM [BRONZE].[listings_historical_raw]
WHERE room_type = 'Entire home/apt'               
  AND TRY_CAST(bedrooms AS INT) > 2;              
GO

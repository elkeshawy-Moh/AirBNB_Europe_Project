USE [AirbnbPricesEUROPE]; 
GO
-- Step A: Hydrate Base Core Shared Dimensions
INSERT INTO GOLD.Dim_Location (city, country, market_scope) VALUES 
('Amsterdam', 'Netherlands', 'Historical & Modern Ingestion Scope'),
('Athens', 'Greece', 'Modern Snapshot Scope Only'),
('Barcelona', 'Spain', 'Modern Snapshot Scope Only'),
('Berlin', 'Germany', 'Modern Snapshot Scope Only'),
('Budapest', 'Hungary', 'Modern Snapshot Scope Only'),
('Lisbon', 'Portugal', 'Modern Snapshot Scope Only'),
('London', 'United Kingdom', 'Modern Snapshot Scope Only'),
('Paris', 'France', 'Modern Snapshot Scope Only'),
('Rome', 'Italy', 'Modern Snapshot Scope Only'),
('Vienna', 'Austria', 'Modern Snapshot Scope Only');

INSERT INTO [GOLD].[Dim_Host] (is_superhost, superhost_label, host_tier) VALUES 
(0, 'Regular Host', 'Single Listing Property'),
(0, 'Regular Host', 'Multi-Listing Manager (2-4 listings)'),
(0, 'Regular Host', 'Commercial Portfolio (>4 listings)'),
(0, 'Regular Host', 'Unspecified Modern Listing Tier'),
(1, 'Superhost', 'Single Listing Property'),
(1, 'Superhost', 'Multi-Listing Manager (2-4 listings)'),
(1, 'Superhost', 'Commercial Portfolio (>4 listings)'),
(1, 'Superhost', 'Unspecified Modern Listing Tier');


-- Step B: Populate Property Dimension Table using deterministic MD5 Hashes
INSERT INTO [GOLD].[Dim_Property] (property_key, room_id, property_name, property_type, bedrooms_count, beds_count, baths_count, amenities_count, host_name)
SELECT DISTINCT
    LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5', CHAR(13) + CHAR(10) + TRIM(CAST(listing_id AS VARCHAR(100)))), 2)) AS property_key,
    listing_id, 
    CAST(property_name AS VARCHAR(MAX)) AS property_name, -- <-- Cast legacy TEXT to VARCHAR(MAX)
    CAST(property_type AS VARCHAR(MAX)) AS property_type, -- <-- Cast legacy TEXT to VARCHAR(MAX)
    CAST(bedrooms AS INT), 
    CAST(beds AS INT), 
    CAST(baths AS NUMERIC(3,1)), 
    CAST(amenities_count AS INT),
    CAST(host_name AS VARCHAR(250)) AS host_name       -- Fixed: Casted from text to varchar
FROM silver.listings_standardized
WHERE listing_id IS NOT NULL 
  AND CAST(bedrooms AS INT) > 2                                            
  -- Using CAST here as well since LIKE operations can also struggle with legacy types
  AND CAST(property_type AS VARCHAR(MAX)) NOT LIKE '%Private room%'                             
  AND CAST(property_type AS VARCHAR(MAX)) NOT LIKE '%Shared room%';
  

-- Step C: Hydrate Historical Stays Fact Table
INSERT INTO GOLD.Fact_Historical_Stays (location_key, host_key, price_total, center_distance_km, guest_capacity, bedrooms_count, is_weekend)
SELECT 
    l.location_key, h.host_key, s.price_total, s.center_distance_km, s.person_capacity, s.bedrooms_count, s.is_weekend
FROM silver.vw_cleaned_historical_premium s
JOIN gold.Dim_Location l ON LOWER(s.city_name) = LOWER(l.city)
JOIN gold.Dim_Host h ON h.is_superhost = s.is_superhost AND h.host_tier = s.host_tier;

-- Step D: Hydrate Modern Scraped Bookings Fact Table
INSERT INTO GOLD.Fact_Scraped_Bookings (location_key, host_key, property_key, total_price, price_per_night, rating_score, review_count, is_new_listing)
SELECT 
    l.location_key, h.host_key,
    LOWER(CONVERT(VARCHAR(32), HASHBYTES('MD5', CHAR(13) + CHAR(10) + TRIM(CAST(s.listing_id AS VARCHAR(100)))), 2)) AS property_key,
    CAST(s.total_price AS NUMERIC(12,2)), CAST(s.price_per_night AS NUMERIC(12,2)), CAST(s.rating AS NUMERIC(3,2)), CAST(s.review_count AS INT),
    CASE WHEN s.is_new_listing = 'TRUE' OR s.is_new_listing = '1' THEN 1 ELSE 0 END
FROM SILVER.listings_standardized s
JOIN GOLD.Dim_Location l ON LOWER(s.city) = LOWER(l.city)
JOIN GOLD.Dim_Host h ON h.is_superhost = TRY_CAST(s.is_superhost AS INT) AND h.host_tier = 'Unspecified Modern Listing Tier'
WHERE CAST(s.bedrooms AS INT) > 2                                          -- More than 2 bedrooms (+2 rooms)
  AND s.property_type NOT LIKE '%Private room%'                           -- Entire home/apt properties only
  AND s.property_type NOT LIKE '%Shared room%';
GO

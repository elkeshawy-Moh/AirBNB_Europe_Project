-----------------------
TRUNCATE TABLE SILVER.listings_standardized;

WITH combined_bronze AS (
    SELECT *, 'Weekdays' AS source_file FROM [BRONZE].[WeekdaysPriced]
    UNION ALL
    SELECT *, 'Weekends' AS source_file FROM [BRONZE].[WeekendsPriced]
),
cleaned_data AS (
    SELECT
        -- Fixed: Added source_file to the hash input to make weekday/weekend rows unique
        LOWER(CONVERT(VARCHAR(64), HASHBYTES('MD5', 
            ISNULL(NULLIF(URL, ''), ISNULL(Name, '') + CAST(ISNULL(Latitude, '') AS VARCHAR) + CAST(ISNULL(Longitude, '') AS VARCHAR)) + source_file
        ), 2)) AS listing_id,
        
        Name AS property_name,
        PropertyType AS property_type,
        city,
        
        -- Dynamic extraction of Country
        LTRIM(RTRIM(
            CASE 
                WHEN LocationSubtitle LIKE '%,%' 
                THEN RIGHT(LocationSubtitle, CHARINDEX(',', REVERSE(LocationSubtitle)) - 1)
                ELSE LocationSubtitle 
            END
        )) AS country,

        TRY_CAST(NULLIF(Price, '') AS NUMERIC(10,2)) AS total_price,
        TRY_CAST(NULLIF(Nights, '') AS INT) AS stay_nights,
        TRY_CAST(NULLIF(PricePerNightEst, '') AS NUMERIC(10,2)) AS price_per_night,
        TRY_CAST(NULLIF(Rating, '') AS NUMERIC(3,2)) AS rating,
        TRY_CAST(NULLIF(Reviews, '') AS INT) AS review_count,
        CASE WHEN CAST(Superhost AS VARCHAR(10)) IN ('TRUE', '1', 'Yes') THEN 1 ELSE 0 END AS is_superhost,
        HostName AS host_name,
        TRY_CAST(NULLIF(HostReviews, '') AS INT) AS host_total_reviews,
        TRY_CAST(NULLIF(Latitude, '') AS NUMERIC(9,6)) AS latitude,
        TRY_CAST(NULLIF(Longitude, '') AS NUMERIC(9,6)) AS longitude,
        TRY_CAST(NULLIF(Guests, '') AS INT) AS capacity_guests,
        TRY_CAST(NULLIF(Bedrooms, '') AS INT) AS bedrooms,
        TRY_CAST(NULLIF(Beds, '') AS INT) AS beds,
        TRY_CAST(NULLIF(Baths, '') AS NUMERIC(3,1)) AS baths,
        Amenities AS amenities_raw,
        CASE WHEN CAST(is_new AS VARCHAR(10)) IN ('TRUE', '1') THEN 1 ELSE 0 END AS is_new_listing,
        
        TRY_CAST(NULLIF(AmenitiesCount, '') AS INT) AS amenities_count,
        TRY_CAST(NULLIF(AvailableDatesCount, '') AS INT) AS available_dates_count,
        TRY_CAST(NULLIF(guest_satisfaction_overall, '') AS INT) AS guest_satisfaction_overall,
        TRY_CAST(NULLIF(dist, '') AS NUMERIC(10,2)) AS dist,
        CASE WHEN CAST(is_fav AS VARCHAR(10)) IN ('TRUE', '1', 'Yes') THEN 1 ELSE 0 END AS is_fav,

        source_file,
        -- Fixed: Added source_file here so it only deduplicates true duplicates inside the same file
        ROW_NUMBER() OVER (
            PARTITION BY 
                ISNULL(NULLIF(URL, ''), ISNULL(Name, '') + CAST(ISNULL(Latitude, '') AS VARCHAR) + CAST(ISNULL(Longitude, '') AS VARCHAR)),
                source_file 
            ORDER BY TRY_CAST(NULLIF(Reviews, '') AS INT) DESC
        ) as row_num
    FROM combined_bronze
    WHERE Name IS NOT NULL
)
INSERT INTO silver.listings_standardized (
    listing_id, property_name, property_type, city, country, total_price, stay_nights,
    price_per_night, rating, review_count, is_superhost, host_name, 
    host_total_reviews, latitude, longitude, capacity_guests, bedrooms, beds, 
    baths, amenities_raw, is_new_listing, amenities_count, available_dates_count, 
    guest_satisfaction_overall, dist, is_fav, source_segment, updated_at
)
SELECT 
    listing_id, property_name, property_type, city, country, total_price, stay_nights,
    price_per_night, rating, review_count, is_superhost, host_name, 
    host_total_reviews, latitude, longitude, capacity_guests, bedrooms, beds, 
    baths, amenities_raw, is_new_listing, amenities_count, available_dates_count, 
    guest_satisfaction_overall, dist, is_fav, source_file, CURRENT_TIMESTAMP
FROM cleaned_data
WHERE row_num = 1;


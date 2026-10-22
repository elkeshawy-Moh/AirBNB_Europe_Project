CREATE OR ALTER VIEW GOLD.view_premium_stay_tracker AS
SELECT 
    listing_id,
    property_name,
    city,
    price_per_night,
    rating,
    review_count,
    bedrooms,
    baths,
    capacity_guests
FROM silver.listings_standardized
WHERE rating >= 4.85 
  AND review_count >= 10
  AND price_per_night > (SELECT AVG(price_per_night) FROM SILVER.listings_standardized);
CREATE OR ALTER VIEW GOLD.view_city_market_summary AS
SELECT 
    city,
    COUNT(listing_id) AS total_active_properties,
    ROUND(AVG(price_per_night), 2) AS avg_estimated_nightly_rate,
    ROUND(MIN(price_per_night), 2) AS floor_nightly_rate,
    ROUND(MAX(price_per_night), 2) AS ceiling_nightly_rate,
    ROUND(AVG(rating), 2) AS customer_satisfaction_score,
    SUM(review_count) AS total_market_reviews,
    SUM(CASE WHEN is_superhost = 1 THEN 1 ELSE 0 END) AS active_superhosts
FROM SILVER.listings_standardized
GROUP BY city;

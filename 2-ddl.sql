CREATE TABLE SILVER.listings_standardized (
    listing_id VARCHAR(64) PRIMARY KEY, -- Hash key based on URL
    property_name TEXT,
    property_type VARCHAR(100),
    city VARCHAR(100),
    total_price NUMERIC(10,2),
    stay_nights INT,
    price_per_night NUMERIC(10,2),
    rating NUMERIC(3,2),
    review_count INT,
    is_superhost BIT,                   
    host_name VARCHAR(100),
    host_total_reviews INT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    capacity_guests INT,
    bedrooms INT,
    beds INT,
    baths NUMERIC(3,1),
    amenities_raw TEXT,
    is_new_listing BIT,                  
    source_segment VARCHAR(10),         -- 'weekend' or 'weekdays'
    updated_at DATETIME2 DEFAULT CURRENT_TIMESTAMP -- Fixed: Changed TIMESTAMP to DATETIME2
      country VARCHAR(100),
    amenities_count INT,
    available_dates_count INT,
    guest_satisfaction_overall INT,
    dist NUMERIC(10,2),
    is_fav BIT
);


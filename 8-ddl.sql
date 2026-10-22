
USE [AirbnbPricesEUROPE]; 
GO
-- 1. Dimension Tables Creation
CREATE TABLE GOLD.Dim_Location (
    location_key INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(100) NOT NULL,
    market_scope VARCHAR(100) NOT NULL
);

CREATE TABLE GOLD.Dim_Host (
    host_key INT IDENTITY(1,1) PRIMARY KEY,
    is_superhost INT NOT NULL,
    superhost_label VARCHAR(50) NOT NULL,
    host_tier VARCHAR(100) NOT NULL,
    CONSTRAINT UC_Premium_Host UNIQUE (is_superhost, host_tier)
);

CREATE TABLE GOLD.Dim_Property (
    property_key CHAR(32) PRIMARY KEY,           -- Hexadecimal MD5 Hash string
    room_id VARCHAR(100) NOT NULL UNIQUE,          -- Natural Business Key
    property_name VARCHAR(500),
    property_type VARCHAR(250),
    bedrooms_count INT,
    beds_count INT,
    baths_count NUMERIC(3,1),
    amenities_count INT
);

-- 2. Fact Tables Creation
CREATE TABLE GOLD.Fact_Historical_Stays (
    historical_fact_id INT IDENTITY(1,1) PRIMARY KEY,
    location_key INT NOT NULL,
    host_key INT NOT NULL,
    price_total NUMERIC(12,4),
    center_distance_km NUMERIC(10,4),
    guest_capacity INT,
    bedrooms_count INT,
    is_weekend BIT
);

CREATE TABLE GOLD.Fact_Scraped_Bookings (
    scraped_fact_id INT IDENTITY(1,1) PRIMARY KEY,
    location_key INT NOT NULL,
    host_key INT NOT NULL,
    property_key CHAR(32) NOT NULL,              -- Link to Dim_Property via Hash
    total_price NUMERIC(12,2),
    price_per_night NUMERIC(12,2),
    rating_score NUMERIC(3,2),
    review_count INT,
    is_new_listing BIT
);
GO

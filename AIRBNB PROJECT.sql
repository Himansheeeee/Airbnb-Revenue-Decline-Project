USE AIR_BNB_DATASET;

SELECT * FROM AB_NYC_2019;

--  HOST AND PROPERTY INSIGHTS:

-- Which hosts have the highest number of listings?

SELECT HOST_ID, HOST_NAME, SUM(CALCULATED_HOST_LISTINGS_COUNT) as TOTAL_LISTINGS 
FROM AB_NYC_2019
GROUP BY HOST_ID, HOST_NAME
ORDER BY TOTAL_LISTINGS DESC
LIMIT 10;

-- HOSTS WITH MOST_LISTINGS WITH LOW REVIEWS 

WITH Host_Listings AS (
    SELECT HOST_ID, HOST_NAME, SUM(CALCULATED_HOST_LISTINGS_COUNT) AS TOTAL_LISTINGS, SUM(NUMBER_OF_REVIEWS) AS TOTAL_REVIEWS
    FROM AB_NYC_2019
    GROUP BY HOST_ID, HOST_NAME
)
SELECT HOST_ID, HOST_NAME, TOTAL_LISTINGS, TOTAL_REVIEWS
FROM Host_Listings
WHERE TOTAL_LISTINGS > (SELECT AVG(TOTAL_LISTINGS) FROM Host_Listings)  -- More than avg listings
AND TOTAL_REVIEWS < (SELECT AVG(TOTAL_REVIEWS) FROM Host_Listings)      -- Less than avg reviews
ORDER BY TOTAL_LISTINGS DESC LIMIT 10;


-- [Hosts with Low Listings but High Reviews] 

WITH Host_Listings AS (
    SELECT HOST_ID, HOST_NAME, SUM(CALCULATED_HOST_LISTINGS_COUNT) AS TOTAL_LISTINGS, SUM(NUMBER_OF_REVIEWS) AS TOTAL_REVIEWS
    FROM AB_NYC_2019
    GROUP BY HOST_ID, HOST_NAME
)
SELECT HOST_ID, HOST_NAME, TOTAL_LISTINGS, TOTAL_REVIEWS
FROM Host_Listings
WHERE TOTAL_LISTINGS < (SELECT AVG(TOTAL_LISTINGS) FROM Host_Listings)  -- Less than avg listings
AND TOTAL_REVIEWS > (SELECT AVG(TOTAL_REVIEWS) FROM Host_Listings)      -- More than avg reviews
ORDER BY TOTAL_REVIEWS DESC LIMIT 10;



-- What is the average price per night for each host?
SELECT * FROM AB_NYC_2019;

SELECT DISTINCT HOST_ID,HOST_NAME, ROUND(AVG(PRICE),2) AS AVG_PRICE 
FROM AB_NYC_2019 
WHERE MINIMUM_NIGHTS = 1
GROUP BY HOST_ID,HOST_NAME
ORDER BY  AVG_PRICE DESC ;

-- hosts with high prices, low_listings and reviews per month:-
SELECT DISTINCT HOST_ID,HOST_NAME, ROUND(AVG(PRICE),1) AS AVG_PRICE, SUM(CALCULATED_HOST_LISTINGS_COUNT) AS TOTAL_LISTINGS, SUM(REVIEWS_PER_MONTH) AS REVIEWS_PER_MONTH
FROM AB_NYC_2019 
GROUP BY HOST_ID,HOST_NAME
ORDER BY  AVG_PRICE DESC;


-- total revenue generated: 
SELECT CONCAT('$ ', FORMAT(SUM(PRICE * MINIMUM_NIGHTS),0)) AS total_revenue_million
FROM AB_NYC_2019;


-- THIS IS NOT EXACT ANNUAL REVENUE (BUT WE CAN RELY ON THIS TO GET THE IDEA BUT IT LIES SOMEWHERE AROUND THIS RANGE )

SELECT CONCAT('$ ', FORMAT(SUM(PRICE * AVAILABILITY_365),0))  AS estimated_annual_revenue
FROM AB_NYC_2019;


-- Which hosts have the highest-rated properties?

SELECT NAME AS PROPERTY_NAME, HOST_NAME, SUM(NUMBER_OF_REVIEWS) AS HIGHEST_RATED_PROPERTIES
FROM AB_NYC_2019 
GROUP BY PROPERTY_NAME, HOST_NAME
ORDER BY HIGHEST_RATED_PROPERTIES DESC 
LIMIT 10 ;


-- Which neighbourhood type of property is most commonly listed?

SELECT * FROM AB_NYC_2019;

SELECT NEIGHBOURHOOD_GROUP AS NEIGHBOURHOOD_TYPE, COUNT(*) AS TOTAL_LISTINGS
FROM AB_NYC_2019
GROUP BY NEIGHBOURHOOD_GROUP
ORDER BY total_listings DESC;


-- What are the neighbourhoods AND neighbourhood_type they need to target based on reviews?

SELECT NEIGHBOURHOOD_GROUP AS NEIGHBOURHOOD_TYPE, count(number_of_reviews) as number_of_reviews
FROM AB_NYC_2019
GROUP BY NEIGHBOURHOOD_GROUP
ORDER BY number_of_reviews DESC;

SELECT NEIGHBOURHOOD AS NEIGHBOURHOOD_TYPE, count(number_of_reviews) as number_of_reviews
FROM AB_NYC_2019
GROUP BY NEIGHBOURHOOD_TYPE
ORDER BY number_of_reviews DESC;




-- Which hosts have the most bookings (based on availability and reviews)?

SELECT HOST_ID, HOST_NAME, 
       SUM(AVAILABILITY_365) AS TOTAL_AVAILABILITY, 
       SUM(NUMBER_OF_REVIEWS) AS TOTAL_REVIEWS
FROM AB_NYC_2019
GROUP BY HOST_ID, HOST_NAME
ORDER BY TOTAL_REVIEWS  DESC, TOTAL_AVAILABILITY DESC
LIMIT 10; 



-- [ Customer Preferences & Booking Patterns ]

-- What are the most common property types preferred by customers?

SELECT room_type , COUNT(*) AS total_listings
FROM AB_NYC_2019
GROUP BY room_type
ORDER BY total_listings DESC;

-- Which price ranges are most preferred by customers?

SELECT 
    CASE 
        WHEN price < 50 THEN 'Below $50'
        WHEN price BETWEEN 50 AND 100 THEN '$50-$100'
        WHEN price BETWEEN 100 AND 200 THEN '$100-$200'
        ELSE 'Above $200' 
    END AS price_range,
    COUNT(*) AS listings_count
FROM AB_NYC_2019
GROUP BY price_range
ORDER BY listings_count DESC;


-- Which listings have the highest occupancy rates?

SELECT id, name, host_id, neighbourhood, room_type, price, availability_365, ROUND((1 - (availability_365 / 365)) * 100, 2) AS occupancy_rate
FROM AB_NYC_2019
WHERE availability_365 > 0 -- Ensuring only active listings are considered
ORDER BY occupancy_rate DESC
LIMIT 10;


-- What are the top locations (neighborhoods) based on bookings?

SELECT NEIGHBOURHOOD, COUNT(ID) AS NUMBER_OF_BOOKINGS 
FROM AB_NYC_2019
GROUP BY NEIGHBOURHOOD
ORDER BY NUMBER_OF_BOOKINGS DESC LIMIT 10 ;

-- What is the correlation between price and number of reviews?

SELECT price, ROUND(AVG(number_of_reviews),1) AS avg_reviews
FROM AB_NYC_2019
GROUP BY price
ORDER BY price ASC;

-- Customer preferred properties-

SELECT * FROM AB_NYC_2019;

SELECT 
    NEIGHBOURHOOD_GROUP, 
    ROOM_TYPE, 
    ROUND(AVG(PRICE),1) AS AVG_PRICE, 
    MIN(PRICE) AS MIN_PRICE, 
    MAX(PRICE) AS MAX_PRICE, 
    MINIMUM_NIGHTS, 
    SUM(NUMBER_OF_REVIEWS) AS TOTAL_REVIEWS, 
    ROUND(AVG(REVIEWS_PER_MONTH),1) AS AVG_REVIEWS_PER_MONTH, 
    SUM(CALCULATED_HOST_LISTINGS_COUNT) AS LISTINGS, 
    SUM(AVAILABILITY_365) AS AVAILABILITY 
FROM AB_NYC_2019
GROUP BY NEIGHBOURHOOD_GROUP, ROOM_TYPE, MINIMUM_NIGHTS
ORDER BY TOTAL_REVIEWS DESC, AVG_REVIEWS_PER_MONTH DESC;


-- [ 3️ Location-Based Insights ]


-- Which neighborhoods have the highest number of listings?
SELECT NEIGHBOURHOOD, SUM(CALCULATED_HOST_LISTINGS_COUNT) AS NUMBER_OF_LISTINGS
FROM AB_NYC_2019
GROUP BY NEIGHBOURHOOD
ORDER BY NUMBER_OF_LISTINGS DESC ;

-- What is the average price per night for each neighborhood?

SELECT NEIGHBOURHOOD, ROUND(AVG(PRICE),1) AS AVERAGE_PRICE
FROM AB_NYC_2019 
WHERE MINIMUM_NIGHTS =1
GROUP BY NEIGHBOURHOOD
ORDER BY AVERAGE_PRICE DESC ;


-- Which areas have the most budget-friendly options (lowest average price)?

SELECT NEIGHBOURHOOD, ROUND(AVG(PRICE),1) AS LOWER_AVERAGE_PRICE
FROM AB_NYC_2019 
WHERE MINIMUM_NIGHTS =1
GROUP BY NEIGHBOURHOOD
ORDER BY LOWER_AVERAGE_PRICE ASC LIMIT 10;

-- Which areas have the most high-end/luxury properties (highest average price)?

SELECT NEIGHBOURHOOD, ROUND(AVG(PRICE),1) AS HIGHEST_AVERAGE_PRICE
FROM AB_NYC_2019 
WHERE MINIMUM_NIGHTS =1
GROUP BY NEIGHBOURHOOD
ORDER BY HIGHEST_AVERAGE_PRICE DESC LIMIT 5 ;


-- Which neighborhoods have the most highly-rated properties?
SELECT NEIGHBOURHOOD, ROUND(AVG(REVIEWS_PER_MONTH),1) AS AVG_REVIEWS_PER_MONTH 
FROM AB_NYC_2019 
GROUP BY NEIGHBOURHOOD
ORDER BY AVG_REVIEWS_PER_MONTH DESC LIMIT 10 ;

SELECT NEIGHBOURHOOD, ROUND(AVG(NUMBER_OF_REVIEWS),1) AS AVG_REVIEWS
FROM AB_NYC_2019 
GROUP BY NEIGHBOURHOOD
ORDER BY AVG_REVIEWS DESC LIMIT 10 ;

-- [ Pricing Analysis ]


-- What is the price distribution for each property type?

SELECT ROOM_TYPE, ROUND(AVG(PRICE),1) AS AVG_PRICE
FROM AB_NYC_2019 
GROUP BY ROOM_TYPE
ORDER BY AVG_PRICE DESC LIMIT 10 ;



-- How does pricing vary with location and room type?

SELECT 
    neighbourhood_group, 
    neighbourhood, 
    room_type, 
    AVG(price) AS avg_price, 
    MIN(price) AS min_price, 
    MAX(price) AS max_price, 
    COUNT(id) AS listing_count
FROM AB_NYC_2019
GROUP BY neighbourhood_group, neighbourhood, room_type
ORDER BY neighbourhood_group, neighbourhood, room_type;


-- [ Improving Underperforming Listings ] 


-- Which listings have been available for the most days but have low bookings?
-- here we do not have nay relvant column for count bookings made but we can take idea from the property reviews made
SELECT 
    name, host_name, neighbourhood_group, room_type, availability_365, number_of_reviews 
FROM AB_NYC_2019
WHERE availability_365 > 300  
AND number_of_reviews < 10     
ORDER BY availability_365 DESC, number_of_reviews ASC;


-- Which properties have low ratings and need improvements?

SELECT 
    name as property_need_improvements, host_name, neighbourhood_group, number_of_reviews as Low_Ratings
FROM AB_NYC_2019
WHERE number_of_reviews < 10     
ORDER BY number_of_reviews ASC;


-- Which properties have high prices but low bookings?

SELECT 
    name AS High_Priced_Property, 
    host_name, 
    SUM(price) AS total_price, 
    number_of_reviews
FROM AB_NYC_2019
WHERE number_of_reviews < 10
GROUP BY name, host_name, number_of_reviews
HAVING SUM(price) > (SELECT AVG(price) FROM AB_NYC_2019)
ORDER BY total_price DESC, number_of_reviews ASC;


-- [ 🔹 Advanced-Level Questions for Deeper Analysis: ]

-- Which hosts generate the highest revenue?
SELECT host_id, host_name, 
    CONCAT('$', FORMAT(SUM(price * availability_365), 1)) AS estimated_total_revenue
FROM AB_NYC_2019
GROUP BY host_id, host_name
ORDER BY estimated_total_revenue DESC;

-- Which neighborhoods have a high supply of listings but low customer engagement (reviews)?
SELECT * FROM AB_NYC_2019;

SELECT neighbourhood, COUNT(*) AS total_listings, ROUND(AVG(NUMBER_OF_REVIEWS),1) AS avg_reviews
FROM AB_NYC_2019
GROUP BY neighbourhood
ORDER BY total_listings DESC, avg_reviews ASC;

-- What is the impact of minimum nights requirement on booking frequency?

SELECT minimum_nights, ROUND(AVG(reviews_per_month),1) AS avg_reviews
FROM AB_NYC_2019
GROUP BY minimum_nights
ORDER BY avg_reviews ASC;


-- Which price ranges have the highest review-to-listing ratio?
SELECT 
    CASE 
        WHEN price < 50 THEN 'Below $50'
        WHEN price BETWEEN 50 AND 100 THEN '$50-$100'
        WHEN price BETWEEN 100 AND 200 THEN '$100-$200'
        ELSE 'Above $200' 
    END AS price_range,
    ROUND(SUM(number_of_reviews) / COUNT(*),1) AS avg_review_ratio
FROM AB_NYC_2019
GROUP BY price_range
ORDER BY avg_review_ratio DESC;


-- Adjustments in the existing properties to make it more customer-oriented.
-- Let's see what we can do : 

SELECT ID,
    NAME, 
    HOST_ID,
    NEIGHBOURHOOD_GROUP, 
    ROOM_TYPE, 
    PRICE, 
    MINIMUM_NIGHTS, 
    NUMBER_OF_REVIEWS, 
    REVIEWS_PER_MONTH, 
    AVAILABILITY_365,
    (SELECT AVG(PRICE) 
     FROM AB_NYC_2019 AS sub 
     WHERE sub.NEIGHBOURHOOD_GROUP = main.NEIGHBOURHOOD_GROUP 
     AND sub.ROOM_TYPE = main.ROOM_TYPE) AS AVG_NEIGHBORHOOD_PRICE,
    CASE 
        WHEN PRICE > (SELECT AVG(PRICE) * 1.5 
                      FROM AB_NYC_2019 AS sub 
                      WHERE sub.NEIGHBOURHOOD_GROUP = main.NEIGHBOURHOOD_GROUP 
                      AND sub.ROOM_TYPE = main.ROOM_TYPE) 
        THEN 'Overpriced'
        ELSE 'OK'
    END AS PRICE_ADJUSTMENT,
    CASE 
        WHEN NUMBER_OF_REVIEWS < 5 THEN 'Low Reviews'
        ELSE 'OK'
    END AS REVIEW_STATUS,
    CASE 
        WHEN AVAILABILITY_365 < 100 THEN 'Low Availability'
        ELSE 'OK'
    END AS AVAILABILITY_STATUS,
    CASE 
        WHEN MINIMUM_NIGHTS > 7 THEN 'Consider Lowering Min Nights'
        ELSE 'OK'
    END AS MIN_NIGHTS_ADJUSTMENT
FROM AB_NYC_2019 AS main
ORDER BY PRICE_ADJUSTMENT DESC, REVIEW_STATUS DESC, AVAILABILITY_STATUS DESC;



-- FACTORS WE CAN CONSIDER FOR REVENUE DECLINE :

-- 1. OCCUPANCY RATE : [ HOSTS WITH LOW OCCUPANCY RATE ]

-- LIST OF HOSTS WITH THEIR OCCUPANCY :
SELECT 
        host_id,
        host_name,
        neighbourhood,
        room_type,
        price,
        availability_365,
        (365 - availability_365) AS booked_nights,
        availability_365 AS available_nights,
        ROUND(((365 - availability_365) / 365) * 100, 2) AS occupancy_rate
    FROM AB_NYC_2019
    ORDER BY occupancy_rate DESC;


-- HOSTS WITH THE LOWER OCCUPANCY FROM THE AVERAGE OCCUPANCY RATE:
WITH OCCUPANCY AS (
    SELECT 
        host_id,
        host_name,
        neighbourhood_group,
        room_type,
        price,
        availability_365,
        (365 - availability_365) AS booked_nights,
        availability_365 AS available_nights,
        ROUND(((365 - availability_365) / 365) * 100, 2) AS occupancy_rate
    FROM AB_NYC_2019
)
SELECT 
    o.host_id,
    o.host_name,
    o.neighbourhood_group,
    o.room_type,
    o.occupancy_rate
FROM OCCUPANCY o
WHERE o.occupancy_rate < (SELECT ROUND(AVG(occupancy_rate), 2) FROM OCCUPANCY) 
ORDER BY o.occupancy_rate ASC;



-- [ High Pricing Issues ] → Compare price vs. demand in each neighbourhood_group.

-- NEIGHBOURHOOD_GROUP HAVING HIGHER PRICES THAN THE AVERAGE PRICES

WITH Price_Avg AS (
    SELECT 
        NEIGHBOURHOOD_GROUP, 
        ROUND(AVG(PRICE),1) AS AVERAGE_PRICE
        FROM AB_NYC_2019
    GROUP BY NEIGHBOURHOOD_GROUP
)
SELECT 
    a.NEIGHBOURHOOD_GROUP, 
    b.PRICE, 
    a.AVERAGE_PRICE
    FROM AB_NYC_2019 b
JOIN Price_Avg a ON a.NEIGHBOURHOOD_GROUP = b.NEIGHBOURHOOD_GROUP
WHERE b.PRICE > a.AVERAGE_PRICE
ORDER BY a.AVERAGE_PRICE DESC;


-- TOP 10 NEIGHBOURHOODS WITH HAVING HIGHER PRICES THAN THE AVERAGE PRICES
WITH Price_Avg AS (
    SELECT 
        NEIGHBOURHOOD, 
        ROUND(AVG(PRICE),1) AS AVERAGE_PRICE,
        SUM(REVIEWS_PER_MONTH) AS REVIEWS_PER_MONTH
    FROM AB_NYC_2019
    GROUP BY NEIGHBOURHOOD
)
SELECT 
    a.NEIGHBOURHOOD, 
    b.PRICE, 
    a.AVERAGE_PRICE,
    a.REVIEWS_PER_MONTH
FROM AB_NYC_2019 as b 
JOIN Price_Avg a ON a.NEIGHBOURHOOD = b.NEIGHBOURHOOD
WHERE b.PRICE > a.AVERAGE_PRICE
ORDER BY a.AVERAGE_PRICE DESC LIMIT 10;


-- [ Poor Customer Reviews ] → Check number_of_reviews & reviews_per_month to identify low-rated properties.


WITH Review_Avg AS (
    SELECT 
        AVG(number_of_reviews) AS avg_reviews, 
        AVG(reviews_per_month) AS avg_reviews_per_month
    FROM AB_NYC_2019
)
SELECT 
    id,
    name,
    host_name,
    neighbourhood_group,
    neighbourhood,
    room_type,
    price,
    number_of_reviews,
    reviews_per_month
FROM AB_NYC_2019
WHERE 
    number_of_reviews < (SELECT avg_reviews FROM Review_Avg)
    AND reviews_per_month < (SELECT avg_reviews_per_month FROM Review_Avg)
ORDER BY number_of_reviews ASC, reviews_per_month ASC;


--  [ Unpopular Locations ] → Identify areas with fewer bookings using neighbourhood data.

-- LEAST RATED NEIGHBOURHOOD:
SELECT 
    neighbourhood_group,
    neighbourhood,
    SUM(number_of_reviews) AS total_reviews,
    AVG(reviews_per_month) AS avg_reviews_per_month
FROM AB_NYC_2019
GROUP BY neighbourhood_group, neighbourhood
ORDER BY total_reviews ASC, avg_reviews_per_month ASC LIMIT 10;


-- Host Activity & Listings Count → Review calculated_host_listings_count to see if inactive hosts are affecting supply.

SELECT 
    host_id,
    host_name,
    calculated_host_listings_count,
    SUM(number_of_reviews) AS total_reviews,
    AVG(reviews_per_month) AS avg_reviews_per_month
FROM AB_NYC_2019
GROUP BY host_id, host_name, calculated_host_listings_count
HAVING 
    calculated_host_listings_count > 0 AND 
    SUM(number_of_reviews) = 0
ORDER BY calculated_host_listings_count DESC;

-- [ Seasonal Trends ] → Examine last_review & bookings to see if seasonality impacts revenue.


SELECT 
    MONTH (last_review) AS review_month,
    COUNT(*) AS number_of_properties,
    SUM(number_of_reviews) AS total_reviews,
    ROUND(AVG(reviews_per_month),2) AS avg_reviews_per_month
FROM AB_NYC_2019
WHERE last_review IS NOT NULL
GROUP BY review_month
ORDER BY review_month;



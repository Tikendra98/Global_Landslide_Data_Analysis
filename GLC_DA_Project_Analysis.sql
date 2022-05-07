 /*** DATA EXPLORATION AND ANALYSIS ***/


---------------------------------------------------------------------------------------------------

SELECT event_id,DATEPART(year,event_date_cleaned) AS event_year,country_name,landslide_trigger,landslide_size,fatality_count
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE DATEPART(year,event_date_cleaned) > 2006

--num of rows = 10988, Columns=6

---------------------------------------------------------------------------------------------------

/** Countries with their landslide_count **/

SELECT country_name,COUNT(event_id) AS landslide_count
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NOT NULL AND DATEPART(year,event_date_cleaned)>2006
GROUP BY country_name
ORDER BY COUNT(event_id) DESC

-- United States, India, Philippiness, Nepal and China are top 5 countries having highest number of landslides.
--Total landslide recorded = 10988
-------------------------------------------------------------------------------------------------

/** landslide_trigger va num_of_landslide **/

SELECT landslide_trigger,COUNT(event_id) AS landslide_count
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE landslide_trigger IS NOT NULL AND landslide_trigger <> 'unknown'
      AND DATEPART(year,event_date_cleaned) > 2006
GROUP BY landslide_trigger
ORDER BY COUNT(event_id) DESC
 
 -- downpour and rain are two major cause of landslides

 -------------------------------------------------------------------------------------------------
 
 /** landslide_size vs landslide_count **/

SELECT landslide_size,COUNT(event_id) AS landslide_count
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE landslide_size IS NOT NULL AND landslide_size <> 'unknown'
      AND DATEPART(year,event_date_cleaned) > 2006
GROUP BY landslide_size
ORDER BY COUNT(event_id) DESC

--most are of medium( 50,000 m^3 to 250,000 m^3) and small (5,000 m^3 to 50,000 m^3)

---------------------------------------------------------------------------------------------------

/**fatality_count vs landslide_count**/

SELECT country_name,SUM(fatality_count) AS fatality_count_of_country
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE fatality_count IS NOT NULL 
      AND DATEPART(year,event_date_cleaned) > 2006
GROUP BY country_name
ORDER BY SUM(fatality_count) DESC

--India records the highest number of fatality_count(7199)


SELECT SUM(fatality_count) AS Total_fatality_count
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE fatality_count IS NOT NULL 
      AND DATEPART(year,event_date_cleaned) > 2006


-- Total fatality_count recorded is 30634

SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE fatality_count IS NOT NULL 
      AND DATEPART(year,event_date_cleaned) > 2006
ORDER BY fatality_count DESC

--Inida recorded maximum num of fatality_count(5000) due to any landslide on 2013-06-16 in kedarnath 


----------------------------------------------------------------------------------------------------



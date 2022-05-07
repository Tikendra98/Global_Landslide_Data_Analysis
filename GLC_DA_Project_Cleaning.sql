SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$

/*** DATA CLEANING ***/

------------------------------------------------------------------------------------

/** Cleaning event_date col **/

SELECT REPLACE(event_date,'-','/')
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$

SELECT event_date,LEFT(event_date,10) AS event_date_trimmed,
       REPLACE(LEFT(event_date,10),'-','/') AS event_date_cleaned
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$

-- Adding new col event_date_cleaned

ALTER TABLE DA_Project.dbo.Global_Landslide_Catalog_Export$
ADD event_date_cleaned DATE

UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET event_date_cleaned=REPLACE(LEFT(event_date,10),'-','/')

-----------------------------------------------------------------------------------------
/** Checking for duplicate values **/

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
GROUP BY event_id, event_date_cleaned,country_name
HAVING COUNT(event_id) >1

-- No duplicate values
----------------------------------------------------------------------------------------

/** Checking for null values **/

SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE event_date IS NULL

SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE landslide_category IS NULL

SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE landslide_trigger IS NULL

SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE landslide_size IS NULL

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE fatality_count IS NULL

SELECT *
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL AND  country_code IS NULL 

-- There are 1562 missing values in Country_name column
-- Missing values in Country_name column can be filled from location_description  column


SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE injury_count IS NULL OR injury_count=0

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE longitude IS NULL OR latitude IS NULL

-----------------------------------------------------------------------------------------------------

/** Filling missing Country_name **/

--Spliting location_description to get country_name 

SELECT  location_description,event_title,PARSENAME(REPLACE(location_description,',','.'),1) As loc_dis_1
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 
      
SELECT DISTINCT country_name
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NOT NULL 
ORDER BY country_name

-- Creating new col from location_description col

ALTER TABLE DA_Project.dbo.Global_Landslide_Catalog_Export$
ADD loc_dis_1 nvarchar(255)

UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET loc_dis_1=TRIM(PARSENAME(REPLACE(location_description,',','.'),1))

SELECT loc_dis_1,event_id
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name is NULL AND loc_dis_1 IN
      (SELECT DISTINCT country_name FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
       WHERE country_name IS NOT NULL)

--filling missing country_name values using loc_dis_1 column (459 rows)

UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET country_name=loc_dis_1
WHERE country_name is NULL AND loc_dis_1 IN
      (SELECT DISTINCT country_name FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
       WHERE country_name IS NOT NULL)

---459 rows filled

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 



-----------------------------------------------------------------------------------------------------------------

/* filling country_name using Country_code and loc_dis_1 columns */


SELECT  location_description,event_title,TRIM(PARSENAME(REPLACE(location_description,',','.'),1)) As loc_dis_1
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 

SELECT loc_dis_1,event_id
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name is NULL AND loc_dis_1 IN
      (SELECT DISTINCT country_code FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
       WHERE country_code IS NOT NULL)

--- Changing USA to US in loc_dis_1 col

UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET loc_dis_1='US'
WHERE loc_dis_1='USA'

SELECT DISTINCT country_code
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_code IS NOT NULL 
ORDER BY country_code


--Creating Temp table

CREATE TABLE #TEMP_GLC_1(
cnt_name_A nvarchar(255),
Country_code nvarchar(255),
event_id_A float,
cnt_name_B nvarchar(255),
loc_dis_1 nvarchar(255),
event_id_B float, 
)

INSERT INTO #TEMP_GLC_1
SELECT A.country_name AS cnt_name_A,A.country_code,A.event_id AS event_id_A,B.country_name AS cnt_name_B, B.loc_dis_1,B.event_id AS event_id_B
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN DA_Project.dbo.Global_Landslide_Catalog_Export$ B
      ON A.country_code=B.loc_dis_1
WHERE B.country_name IS NULL


---filling country_name

SELECT *
FROM #TEMP_GLC_1


SELECT DISTINCT A.country_name,event_id_B,cnt_name_A,B.loc_dis_1
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_GLC_1 B
   ON event_id=event_id_B


UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET country_name=cnt_name_A
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_GLC_1 B
   ON event_id=event_id_B

--63 rows filled

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 



----------------------------------------------------------------------------------------------------

/* filling country_name using admin_division_name and loc_dis_1 column */

SELECT loc_dis_1,event_id
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name is NULL AND loc_dis_1 IN
      (SELECT DISTINCT admin_division_name FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
       WHERE admin_division_name IS NOT NULL)


CREATE TABLE #TEMP_GLC_2(
cnt_name_A nvarchar(255),
admin_division_name nvarchar(255),
event_id_A float,
cnt_name_B nvarchar(255),
loc_dis_1 nvarchar(255),
event_id_B float, 
)

INSERT INTO #TEMP_GLC_2
SELECT A.country_name AS cnt_name_A,A.admin_division_name,A.event_id AS event_id_A,B.country_name AS cnt_name_B, B.loc_dis_1,B.event_id AS event_id_B
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN DA_Project.dbo.Global_Landslide_Catalog_Export$ B
      ON A.admin_division_name=B.loc_dis_1
WHERE B.country_name IS NULL

---filling country_name

SELECT *
FROM #TEMP_GLC_2


SELECT DISTINCT A.country_name,event_id_B,cnt_name_A,B.loc_dis_1
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_GLC_2 B
   ON event_id=event_id_B


UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET country_name=cnt_name_A
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_GLC_2 B
   ON event_id=event_id_B

--144 rows filled 

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 



-----------------------------------------------------------------------------------------

/* filling country_name using gazeteer_closest_point and loc_dis_1 column */

SELECT loc_dis_1,event_id
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name is NULL AND loc_dis_1 IN
      (SELECT DISTINCT gazeteer_closest_point FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
       WHERE gazeteer_closest_point IS NOT NULL)

CREATE TABLE #TEMP_GLC_3(
cnt_name_A nvarchar(255),
gazeteer_closest_point nvarchar(255),
event_id_A float,
cnt_name_B nvarchar(255),
loc_dis_1 nvarchar(255),
event_id_B float, 
)

INSERT INTO #TEMP_GLC_3
SELECT A.country_name AS cnt_name_A,A.gazeteer_closest_point,A.event_id AS event_id_A,B.country_name AS cnt_name_B, B.loc_dis_1,B.event_id AS event_id_B
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN DA_Project.dbo.Global_Landslide_Catalog_Export$ B
      ON A.gazeteer_closest_point=B.loc_dis_1
WHERE B.country_name IS NULL

--filling country_name
SELECT *
FROM #TEMP_GLC_3


SELECT DISTINCT A.country_name,event_id_B,cnt_name_A,B.loc_dis_1
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_GLC_3 B
   ON event_id=event_id_B


UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET country_name=cnt_name_A
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_GLC_3 B
   ON event_id=event_id_B

--5 rows filled 

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 



-------------------------------------------------------------------------------------------------

/* splitting and Creating new col from location_description col -- loc_dis_2 */

ALTER TABLE DA_Project.dbo.Global_Landslide_Catalog_Export$
ADD loc_dis_2 nvarchar(255)

UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET loc_dis_2=TRIM(PARSENAME(REPLACE(location_description,',','.'),2))


/* filling country_name using admin_division_name and loc_dis_2 column */

CREATE TABLE #TEMP_loc_dis_2_adm(
cnt_name_A nvarchar(255),
admin_division_name nvarchar(255),
event_id_A float,
cnt_name_B nvarchar(255),
loc_dis_2 nvarchar(255),
event_id_B float, 
)

INSERT INTO #TEMP_loc_dis_2_adm
SELECT A.country_name AS cnt_name_A,A.admin_division_name,A.event_id AS event_id_A,B.country_name AS cnt_name_B, B.loc_dis_2,B.event_id AS event_id_B
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN DA_Project.dbo.Global_Landslide_Catalog_Export$ B
      ON A.admin_division_name=B.loc_dis_2
WHERE B.country_name IS NULL

---filling country_name

SELECT *
FROM #TEMP_loc_dis_2_adm


SELECT DISTINCT A.country_name,event_id_B,cnt_name_A,B.loc_dis_2
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_loc_dis_2_adm B
   ON event_id=event_id_B


UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET country_name=cnt_name_A
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_loc_dis_2_adm B
   ON event_id=event_id_B

---365 row filled

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 



-----------------------------------------------------------------------------------

/* filling country_name using gazeteer_closest_point and loc_dis_2 column */

CREATE TABLE #TEMP_loc_dis_2_gaze(
cnt_name_A nvarchar(255),
gazeteer_closest_point nvarchar(255),
event_id_A float,
cnt_name_B nvarchar(255),
loc_dis_2 nvarchar(255),
event_id_B float, 
)

INSERT INTO #TEMP_loc_dis_2_gaze
SELECT A.country_name AS cnt_name_A,A.gazeteer_closest_point,A.event_id AS event_id_A,B.country_name AS cnt_name_B, B.loc_dis_2,B.event_id AS event_id_B
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN DA_Project.dbo.Global_Landslide_Catalog_Export$ B
      ON A.gazeteer_closest_point=B.loc_dis_2
WHERE B.country_name IS NULL

--filling country_name
SELECT *
FROM #TEMP_loc_dis_2_gaze


SELECT DISTINCT A.country_name,event_id_B,cnt_name_A,B.loc_dis_2
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_loc_dis_2_gaze B
   ON event_id=event_id_B


UPDATE DA_Project.dbo.Global_Landslide_Catalog_Export$
SET country_name=cnt_name_A
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$ A
JOIN #TEMP_loc_dis_2_gaze B
   ON event_id=event_id_B

--39 rows filled 

SELECT COUNT(event_id)
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
WHERE country_name IS NULL 

------------------------------------------------------------------------------------

/** year vs num_of_landslide **/


SELECT DATEPART(year,event_date_cleaned) event_year, COUNT(event_id) AS landslide_count
FROM DA_Project.dbo.Global_Landslide_Catalog_Export$
GROUP BY DATEPART(year,event_date_cleaned)
ORDER BY DATEPART(year,event_date_cleaned)

--landslide_count in years from 1988 to 2006 are much less than the that of others 
--Therefore we will consider data from 1988 to 2006 as outliers and will analyze only the data from 2007 to 2017

-------------------------------------------------------------------------------------------------------------------
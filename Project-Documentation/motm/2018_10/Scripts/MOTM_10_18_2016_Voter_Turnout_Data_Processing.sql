/****** Script for SelectTopNRows command from SSMS  ******/
--=======================================================================
/*
The purpose of this script is to process data related to the October 2018 
Map of the Month
Created on: 10-16-18
Created by: Joshua Croff
*/
--=======================================================================

--=======================================================================
/*
Group select 2016 election year and group by year, state, county, 
FIPS, office, and total votes and create new table
*/
--=======================================================================

SELECT
[year]
,[state]
,[state_po]
,[county]
,[FIPS]
,[office]
,[totalvotes]
INTO COUNTYPRES_2016_TOTAL_VOTES
FROM [Analysis].[dbo].[COUNTYPRES_2000_2016]
WHERE YEAR = 2016
GROUP BY
[year]
,[state]
,[state_po]
,[county]
,[FIPS]
,[office]
,[totalvotes]

--=======================================================================
/*
Add column to COUNTYPRES_2016_TOTAL_VOTES to create 5-digit FIPS code 
for counties 
*/
--=======================================================================

ALTER TABLE [Analysis].[dbo].[COUNTYPRES_2016_TOTAL_VOTES]
ADD 
	FIPS_5 varchar(10),
	STATE_FIPS varchar(2)
	 

--=======================================================================
/*
Update column within COUNTYPRES_2016_TOTAL_VOTES table to 
create 5-digit FIPS code for counties. For FIPS < 5, concat 0 to begginning 
of code. Otherwise, do nothing. 
*/
--=======================================================================

UPDATE [Analysis].[dbo].[COUNTYPRES_2016_TOTAL_VOTES]
SET [FIPS_5] = (CASE WHEN LEN(FIPS) < 5 THEN ('0' + CAST(FIPS AS varchar(5))) ELSE CAST(FIPS AS varchar(5)) END) 

--=======================================================================
/*
Update FIPS_5 column to reflect changes to FIPS codes for Oglala Lakota,
South Dakota & Bedford, Virginia
*/
--=======================================================================

UPDATE [Analysis].[dbo].[COUNTYPRES_2016_TOTAL_VOTES]
SET [FIPS_5] = 51019
WHERE [FIPS] = 51515

UPDATE [Analysis].[dbo].[COUNTYPRES_2016_TOTAL_VOTES]
SET [FIPS_5] = 46102
WHERE [FIPS] = 46113

SELECT * 
FROM [Analysis].[dbo].[COUNTYPRES_2016_TOTAL_VOTES]
WHERE [FIPS_5] = 46102

--=======================================================================
/*
Update state fips column 
*/
--=======================================================================

UPDATE [Analysis].[dbo].[COUNTYPRES_2016_TOTAL_VOTES]
SET [STATE_FIPS] = SUBSTRING(FIPS_5,1,2)

--=======================================================================
/*
Create new table of County Voter Age Population estimates, filtering to 
only include population total   
*/
--=======================================================================

SELECT * 
INTO CVAP_County_2010_2014_ACS_2016POPEST_Total
FROM [Analysis].[dbo].[CVAP_COUNTY_ACS_2010_2014_ACS_2016POPEST]
WHERE [LNNUMBER] = 1

--=======================================================================
/*
Create FIPS column   
*/
--=======================================================================

ALTER TABLE [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]
ADD 
	FIPS varchar(5), 
	STATE_FIPS varchar(2)

--=======================================================================
/*
Update FIPS column   
*/
--=======================================================================

UPDATE [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]
SET 
	[FIPS] = SUBSTRING(GEOID, 8, 5),
	[STATE_FIPS] = SUBSTRING(GEOID, 8, 2)
  
SELECT * 
FROM [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]

--=======================================================================
/*
Update FIPS column to reflect changes to FIPS codes for Oglala Lakota
*/
--=======================================================================

UPDATE [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]
SET [FIPS] = 46102
WHERE [FIPS] = 46113

select * 
from [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]
where FIPS = 46102

--=======================================================================
/*
Create new table which joins U.S. County Population estimates with 
2016 total votes table and calculates the percentage of voter turnout
(votes / population est   
*/
--=======================================================================

SELECT
T2.[FIPS]
,[year]
,[state]
,[state_po]
,[county]
,[office]
,[totalvotes]
,t2.[TOT_EST] as Total_Pop_Est
,t2.[ADU_EST] AS Adult_Pop_Est
,(CAST([totalvotes] AS Float)/CAST([ADU_EST] AS Float)) As Voter_Turnout_PCT
INTO US_Voter_Turnout_2016_Ex_Alaska
FROM [dbo].[COUNTYPRES_2016_TOTAL_VOTES] t1
JOIN [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total] t2
ON t1.FIPS_5 = t2.FIPS

select * 
from [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]
where FIPS = 46102

--=======================================================================
/*
Create new table of total adult pop for State of Alaska  
*/
--=======================================================================

SELECT
[STATE_FIPS]
,SUM([TOT_EST]) AS Total_Pop_Est
,SUM([ADU_EST]) AS Adult_Pop_Est
INTO CVAP_State_2010_2014_ACSpopest_Total_Alaska
FROM [Analysis].[dbo].[CVAP_County_2010_2014_ACS_2016POPEST_Total]
WHERE STATE_FIPS = 02
GROUP BY 
STATE_FIPS

--=======================================================================
/*
Create new table of total votes for State of Alaska  
*/
--=======================================================================

SELECT
[STATE_FIPS]
,[state]
,sum([totalvotes]) as TotalVotes
INTO STATEPRES_2016_TOTAL_VOTES_Alaska
FROM [dbo].[COUNTYPRES_2016_TOTAL_VOTES]
WHERE STATE_FIPS = 02
GROUP BY 
[state]
,[STATE_FIPS]

--=======================================================================
/*
Create new table of total votes and adult pop for State of Alaska  
*/
--=======================================================================

SELECT
cvap.[STATE_FIPS]
,[state]
,[Total_Pop_Est]
,[TotalVotes]
,[Adult_Pop_Est]
,(CAST([TotalVotes] AS Float)/CAST([Adult_Pop_Est] AS Float)) As Voter_Turnout_PCT
INTO US_Voter_Turnout_2016_Alaska
FROM [Analysis].[dbo].[CVAP_State_2010_2014_ACSpopest_Total_Alaska] AS cvap
JOIN [Analysis].[dbo].[STATEPRES_2016_TOTAL_VOTES_Alaska] AS totvotes
ON cvap.STATE_FIPS = totvotes.STATE_FIPS

SELECT * 
FROM US_Voter_Turnout_2016_Alaska

--=======================================================================
/*
Join voter turnout table to geography for all counties except Alaska   
*/
--=======================================================================

SELECT * 
INTO US_Voter_Turnout_2016_Geog_Ex_Alaska
FROM [dbo].[CB_2016_US_COUNTY_20M] AS geog
JOIN [dbo].[US_Voter_Turnout_2016_Ex_Alaska] AS turnout
ON geog.GEOID = turnout.FIPS

SELECT * 
FROM US_Voter_Turnout_2016_Geog_Ex_Alaska
WHERE STATE LIKE 'South Dakota'

--=======================================================================
/*
Join voter turnout table to geography for Alaska   
*/
--=======================================================================

SELECT * 
INTO US_Voter_Turnout_2016_Geog_Alaska
FROM [dbo].[CB_2016_US_COUNTY_20M] AS geog
JOIN US_Voter_Turnout_2016_Alaska as turnout
ON geog.STATEFP = turnout.STATE_FIPS

-- Show Total Cases vs Population
-- Normal approach
SELECT location
		,Max(CONVERT(bigint,total_cases)/population*100) AS PercentageCase
FROM CovidDeath$
WHERE continent is not null
group by location
order by location

-- CTE approach
WITH CTE_CasesVsPopulation AS
(
	SELECT	location
			,Max(CONVERT(bigint,total_cases)/population*100) AS PercentageCase
	FROM CovidDeath$
	WHERE continent is not null
	group by location
)

SELECT	*
FROM CTE_CasesVsPopulation

-- Temp table approach
Drop Table if exists #Temp_PercentageCase
Create Table #Temp_PercentageCase (
		location nvarchar(250),
		Percentagecase float
)

Insert into #Temp_PercentageCase
SELECT location
		,Max(CONVERT(bigint,total_cases)/population*100) AS PercentageCase
FROM CovidDeath$
WHERE continent is not null
group by location

Select *
From #Temp_PercentageCase
order by location


-- Highest new Cases a day by Continent/Location
-- Store Procedure with a single parameter
SELECT 
		location
		, MAX(CONVERT(int,new_cases)) AS HighestDailyCaseCount
FROM CovidDeath$
WHERE continent is not null
GROUP BY location
ORDER BY location

CREATE Procedure FindHighestDailyCaseCountPerCountry @Country nvarchar(250)
AS
	SELECT 
		location
		, MAX(CONVERT(int,new_cases)) AS HighestDailyCaseCount
	FROM CovidDeath$
	WHERE continent is not null
		And @Country = location
	GROUP BY location

EXEC FindHighestDailyCaseCountPerCountry @Country = 'Canada'

-- Rolling Case Count
SELECT
		location, date
		,new_cases
		,SUM(new_cases) OVER (Partition by location order by location, date) AS RollingCaseCount
FROM CovidDeath$ 
WHERE new_cases <> 0
ORDER BY location, date


-- Rolling vaccination count
SELECT
		location, date
		,new_vaccinations
		,SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by location order by location, date) AS RollingVaccinationCount
FROM CovidVaccination$
WHERE new_vaccinations <> 0
ORDER BY location, date
SELECT *
FROM CovidDeath$

SELECT *
FROM CovidVaccination$

-- Show Total Cases vs Population
-- Normal approach
SELECT 
	location, date, cast(population as int) AS TotalPopulation, CONVERT(int,total_cases) AS TotalCases,
	CONVERT(int,total_cases)/population*100 AS PercentageCases
FROM CovidDeath$
Where continent is not null
Order by 1,2

-- CTE approach
WITH CasesPerPopulation as (
SELECT 
	location, date, cast(population as int) AS TotalPopulation, CONVERT(int,total_cases) AS TotalCases,
	CONVERT(int,total_cases)/population*100 AS PercentageCases
FROM CovidDeath$
Where continent is not null
)

SELECT *
FROM CasesPerPopulation
Where PercentageCases > 0.01
order by location


-- Show Total Death vs Population
-- Normal approach
SELECT 
	location, date, Cast(population as int) AS TotalPopulation, Convert(int,total_deaths) as TotalDeaths,
	Convert(int,total_deaths)/population*100 AS PercentageDeath
FROM CovidDeath$
Where continent is not null
Order by 1,2

-- Temp table approach
DROP Table if Exists #PercentageDeath
CREATE Table #PercentageDeath (
	location nvarchar(255),
	date DateTime,
	Population bigint,
	TotalDeaths bigint,
	PercentageDeath numeric
)

INSERT INTO #PercentageDeath
SELECT 
	location, date, Cast(population as int) AS TotalPopulation, Convert(int,total_deaths) as TotalDeaths,
	Convert(int,total_deaths)/population*100 AS PercentageDeath
FROM CovidDeath$
Where continent is not null

SELECT *
FROM #PercentageDeath
order by 1,2



-- Show Total Vaccination vs Population
WITH PercentageVaccination As (
SELECT dea.location, dea.date, CONVERT(numeric, dea.population) as TotalPopulation,
		SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location)	AS TotalVaccination
FROM CovidDeath$ dea
JOIN CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

SELECT location, max(TotalVaccination/TotalPopulation*100) AS PercentageVaccination
from PercentageVaccination
group by location


-- Highest Cases by Continent/Location
SELECT 
		location, MAX(total_cases) AS HighestCaseCount
From CovidDeath$
Where continent is not null
Group by location
order by 2 desc

SELECT 
		continent, MAX(total_cases) AS HighestCaseCount
From CovidDeath$
Where continent is not null
Group by continent
order by 2 desc

-- Highest new Cases a day by Continent/Location
SELECT 
		location, MAX(new_cases) AS HighestNewCaseCount
From CovidDeath$
Where continent is not null
Group by location
order by HighestNewCaseCount desc

-- CTE Approach
With HighestNewCaseCountADay AS ( 
SELECT 
		location, MAX(new_cases) AS HighestNewCaseCount
From CovidDeath$
Where continent is not null
Group by location
)

SELECT hn.location, dea.date, hn.HighestNewCaseCount
From HighestNewCaseCountADay hn
JOIN CovidDeath$ dea
	ON hn.location = dea.location
	and hn.HighestNewCaseCount = dea.new_cases
Order by hn.HighestNewCaseCount desc

-- Store Procedure wiith a single parameter
Create procedure TEST_HighestNewCaseCountADay @Country nvarchar(50)
AS

	With HighestNewCaseCountADay 
	AS ( 
	SELECT 
			location, MAX(new_cases) AS HighestNewCaseCount
	From CovidDeath$
	Where continent is not null
	Group by location
	)

	SELECT hn.location, dea.date, hn.HighestNewCaseCount
	From HighestNewCaseCountADay hn
	JOIN CovidDeath$ dea
		ON hn.location = dea.location
		and hn.HighestNewCaseCount = dea.new_cases
	Where hn.location = @Country
	Order by hn.HighestNewCaseCount desc
	

EXEC TEST_HighestNewCaseCountADay @Country = 'United States'

-- Rolling Case Count
SELECT 
	location, date, new_cases,
	SUM(new_cases) over (partition by location order by location, date) AS TotalCases
FROM CovidDeath$
WHERE continent is not null
	and new_cases <> 0
Order by location, date
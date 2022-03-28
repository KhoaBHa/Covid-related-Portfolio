Select *
From SQLPortfolio..CovidDeath$
Order by 3,4

--Select *
--From SQLPortfolio..CovidVaccination$
--order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths
From SQLPortfolio..CovidDeath$
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From SQLPortfolio..CovidDeath$
where location like '%canada%'
order by 1,2


--Looking at the Total Cases vs Population
--Show what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 As CasesPercentage
From SQLPortfolio..CovidDeath$
where location like '%canada%'
order by 1,2

--Looking at countries with the highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As CasesPercentage
From SQLPortfolio..CovidDeath$
--where location like '%canada%'
where continent is not null
group by location, population
order by CasesPercentage desc

--Showing Countries with Highest Death Count per population
Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From SQLPortfolio..CovidDeath$
--where location like '%canada%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing Continents with Highest Death Count per population
Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From SQLPortfolio..CovidDeath$
--where location like '%canada%'
where continent is null
group by location
order by TotalDeathCount desc

-- Global numbers
Select  SUM(new_cases) As TotalCases,
		SUM(cast(new_deaths as int)) As TotalDeaths,
		SUM(cast(new_deaths as int))/Sum(new_cases)*100 As DeathPercentage
From SQLPortfolio..CovidDeath$
--where location like '%canada%'
Where new_cases <> 0 and new_deaths <> 0
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(new_vaccinations as int)) OVER (partition by dea.location)
FROM SQLPortfolio..CovidDeath$ dea
Join SQLPortfolio..CovidVaccination$ vac
	ON dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
order by 2,3
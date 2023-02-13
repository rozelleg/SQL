Select *
From master.dbo.CovidDeaths
WHERE continent is not null
Order by 3,4

--Select *
--From master.dbo.CovidVaccinations
--Order by 3,4


Select Location,date, total_cases, new_cases, total_deaths, population
From master.dbo.CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract covid in your country

Select Location,date, total_cases,total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
From master.dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location,date, total_cases,population, 
(total_cases/population)*100 AS PercentPopulationInfected
From master.dbo.CovidDeaths
--Where location like '%states%'
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
From master.dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per population

Select Location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From master.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Let's break things down by Continent

-- Showing continents with highest death count


Select continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From master.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc




-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases) *100 AS DeathPercentage
From master.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
--Group By date
Order by 1,2



-- Looking at Total Population va Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated 
--  , (RollingPeopleVaccinated/population)*100
From master.dbo.CovidDeaths dea
Join master.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated 
--  , (RollingPeopleVaccinated/population)*100
From master.dbo.CovidDeaths dea
Join master.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated 
--  , (RollingPeopleVaccinated/population)*100
From master.dbo.CovidDeaths dea
Join master.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for future visualization

Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated 
--  , (RollingPeopleVaccinated/population)*100
From master.dbo.CovidDeaths dea
Join master.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select*
From PercentPopulatuionVaccinated
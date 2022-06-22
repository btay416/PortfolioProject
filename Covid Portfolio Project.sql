SELECT *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4

--SELECT *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null

order by 1, 2


-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
Select Location, continent, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1, 2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population has contracted Covid
Select Location, continent, date, population, total_cases,(total_cases/population)* 100 as InfectionRate
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population


Select Location, continent,population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)* 100 as InfectionRate
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by population, continent, location
order by InfectionRate desc


-- Showing Countries with Highest Death Count per Population

Select Location, continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent, location
order by TotalDeathCount desc

-- Breaking it down by continent


-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
--group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
from PopvsVac


-- TEMP TABLE


Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated
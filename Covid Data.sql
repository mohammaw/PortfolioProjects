
--Select Data that we are using
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths in the United States
-- Shows the likelihood of death if you contract COVID in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population contracted COVID in United States

Select location, date, total_cases, population, (total_cases/population*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population*100)) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
group by population, location
order by PercentagePopulationInfected desc

-- Showing the countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking down data of total deaths by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--  Showing Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2

--  Global Deaths
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Looking at total population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinated/population)*100 as PercentageOfVaccinated
From PopVsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingVaccinated/population)*100 as PercentageOfVaccinated
From #PercentPopulationVaccinated

-- Creating View for later visualizations
Create View PercentPopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

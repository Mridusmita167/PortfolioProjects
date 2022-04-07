
Select * 
From PortfolioProject..['Covid Deaths']
where continent is not null
Order by 3,4

--Select * 
--From PortfolioProject..['Covid Vaccinations']
--Order by 3,4


--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..['Covid Deaths']
order by 1,2


-- Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if infected by covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths']
where location like 'India'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of Population infected by covid
Select location, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..['Covid Deaths']
--where location like 'India'
order by 1,2


--Looking at countries with highest infection rate compared to its population
Select location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..['Covid Deaths']
--where location like 'India'
group by location, population
order by InfectedPercentage desc


--Looking at countries with highest death counts per population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..['Covid Deaths']
--where location like 'India'
where continent is not null
group by location
order by HighestDeathCount desc


--Looking at continents with highest death counts per population
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..['Covid Deaths']
--where location like 'India'
where continent is not null
group by continent
order by HighestDeathCount desc


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths']
--where location like 'India'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))
over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
join PortfolioProject..['Covid Vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))
over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['Covid Deaths'] dea
join PortfolioProject..['Covid Vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table
Drop table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))
over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths'] dea
join PortfolioProject..['Covid Vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualisation
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))
over(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths'] dea
join PortfolioProject..['Covid Vaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
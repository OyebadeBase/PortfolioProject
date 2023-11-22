select *
from PortFolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortFolioProject..CovidVaccination
--Order by 3,4

--Selecting data we are going to be using

select location, date,total_cases,new_cases, total_deaths, population
from PortFolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total cases and  Total deaths

select location, date,total_cases,total_deaths
from PortFolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
order by 1,2

--Looking at total cases VS population
--shows  what percentage of population got covid
select location, date,population, total_cases, (total_cases/population)*100 
from PortFolioProject..CovidDeaths
--where location like '%africa%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestinfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortFolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- showing the countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent


--showing the continent with the highest death count per population 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths
--where location like '%africa%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers 
select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortFolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Looking at total population and vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--USE CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

select *, RollingPeopleVaccinated/ population * 100
from PopVsVac


--TEMP TABLE 
DROP Table if EXISTS #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccination numeric, 
RollingPeopleVaccinated numeric
)

Insert into  #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population) * 100
from #percentPopulationVaccinated


--Creating view to store data for later visualizatios

CREATE VIEW percentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3


Select *
from percentPopulationVaccinated
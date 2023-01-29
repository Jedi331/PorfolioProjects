Select * 
from PorfolioProject..Covid_deaths
order by 3,4

--Select * 
--from PorfolioProject..Covid_vaccinations
--order by 3,4
--Select Data that will be used 
Select location, date,total_cases, new_cases, total_deaths, population
from PorfolioProject..Covid_deaths
order by 1,2;

--Looking at total_cases vs total_deaths
--Shows likelihod of death if affected by covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percent
from PorfolioProject..Covid_deaths
where location like '%canada%'
order by 1,2;

--Looking at total_cases vs population
--shows what percentage of population has covid in your country
Select location, date, total_cases, population, (total_cases/population)*100 as Pop_affected
from PorfolioProject..Covid_deaths
where location like '%canada%'
order by 1,2;
--looking at countries with highest infection rate by population


Select location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 highest_infection
From PorfolioProject..Covid_deaths
Group by location, population
order by highest_infection DESC;

--Show countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..Covid_deaths
where continent is not NULL
Group by location
order by TotalDeathCount DESC;


--Break things down into continents

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..Covid_deaths
--Where location like '%canada$'
where continent is NULL
and location not like '%income%'
Group by location
order by TotalDeathCount DESC;



--Global Numbers Per day
Select date, Sum(new_cases) as Global_cases, sum(cast(new_deaths as int)) as Global_deaths,
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Global_death_rate
from PorfolioProject..Covid_deaths
where continent is not NULL
group by date
order by 1,2


--Total population vs vaccination


--Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..Covid_vaccinations vac
Join PorfolioProject..Covid_deaths dea
On vac.location = dea.location
and vac.date=dea.date
where dea.continent is not NULL
AND vac.new_vaccinations is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
from PopvsVac



--Temp Table
If OBJECT_ID('tempdb.dbo.#PercentpopulationVaccinated', 'U') is not null
DROP TABLE #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..Covid_vaccinations vac
Join PorfolioProject..Covid_deaths dea
On vac.location = dea.location
and vac.date=dea.date
where dea.continent is not NULL
AND vac.new_vaccinations is not NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
from #PercentpopulationVaccinated


--Creating View to Store data for later visualizations

Create View PercentVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations))
Over (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..Covid_vaccinations vac
Join PorfolioProject..Covid_deaths dea
On vac.location = dea.location
and vac.date=dea.date
where dea.continent is not NULL
AND vac.new_vaccinations is not NULL
--order by 2,3

Select *
from PercentVaccinated
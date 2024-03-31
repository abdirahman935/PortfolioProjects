select * from  Portfolioproject.dbo.covidDeathsData
where continent is not null
order by 3,4

--select * from 
--Portfolioproject.dbo.covidVaccs
--order by 3,4 


--Select data that we are going to be using 
select Location, date, total_cases, new_cases, total_deaths, population 
from Portfolioproject.dbo.covidDeathsData
where continent is not null
order by 1,2


--Looking at total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from Portfolioproject.dbo.covidDeathsData
--where Location like '%states%'
where continent is not null
order by 1,2


--Looking at total Cases vs Population
-- shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
from Portfolioproject.dbo.covidDeathsData
--where Location like '%states%'
order by 1,2


--Looking at countries with highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectioncount, Max((total_cases/population))* 100 as  PercentPopulationinfected
--where Location like '%states%'
from Portfolioproject.dbo.covidDeathsData
where continent is not null
Group by Location, Population
order by PercentPopulationinfected desc


--Showing Countries with the highest Death Count Per Population 
Select Location, MAX(Convert (float, total_deaths)) as TotalDeathCount
--where Location like '%states%'
from Portfolioproject.dbo.covidDeathsData
where continent is not null
Group by Location
order by TotalDeathCount desc



-- Breaking it down by continents
-- Showing continents with the highest death count per population
Select continent, MAX(Convert (float, total_deaths)) as TotalDeathCount
--where Location like '%states%'
from Portfolioproject.dbo.covidDeathsData
where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers
Select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) /sum(New_cases)*100 as DeathPercentage
from Portfolioproject.dbo.covidDeathsData
--where Location like '%states%'
where continent is not null
--Group By Date
Order by 1,2


--Looking at total population vs Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (convert(float, ( vac.new_vaccinations ))) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolioproject.dbo.covidDeathsData dea
Join Portfolioproject.dbo.covidVaccs vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by RollingPeopleVaccinated desc


--Using CTE 
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (convert(float, ( vac.new_vaccinations ))) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolioproject.dbo.covidDeathsData dea
Join Portfolioproject.dbo.covidVaccs vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--der by RollingPeopleVaccinated desc
)
select *, (RollingPeoplevaccinated/population)*100
from PopvsVac



--TEMP TABLE
DROP table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
Date datetime ,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (convert(float, ( vac.new_vaccinations ))) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolioproject.dbo.covidDeathsData dea
Join Portfolioproject.dbo.covidVaccs vac
ON dea.location = vac.location
and dea.date = vac.date 
--where dea.continent is not null
--order by RollingPeopleVaccinated desc


select *, (RollingPeoplevaccinated/population)*100
from #percentPopulationVaccinated


-- Creating view to store data for later visualizations 

Create View percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (convert(float, ( vac.new_vaccinations ))) over (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from Portfolioproject.dbo.covidDeathsData dea
Join Portfolioproject.dbo.covidVaccs vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
--order by RollingPeopleVaccinated desc'


select * 
from percentPopulationVaccinated 
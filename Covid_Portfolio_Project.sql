

-- Checking data's summary

select * from information_schema.columns where table_name = 'CovidDeaths'

select *
from CovidProject..CovidDeaths
where continent is not null
order by 3,4

-- converting datatype
alter table CovidDeaths
alter column total_deaths BIGINT
go

-- selecting data to be used
 
 select location, date, total_cases, new_cases, total_deaths, population
 from CovidProject..CovidDeaths
 order by 1,2


 -- looking at the total_cases Vs total_deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
Where location = 'Nigeria'
order by 1,2


-- looking at the total cases vs population
-- shows the percentage of population that got covid
select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as PercentagePopulationInfected
from CovidProject..CovidDeaths
Where location = 'Nigeria'
order by 1,2


--looking at countries with hoghest infection rate
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
from CovidProject..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc


-- showing the countries with the highest death count per population
select location, MAX(total_deaths) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--showing the contitent with the highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
--Where location like '%Nigeria'
where continent is not null 
--Group By date
order by 1,2


--Looking at Total Population Vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



--USE CTE

With PopVsVac (Continent, Location ,Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

--TEMP TABLE
DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #Percent_Population_Vaccinated



-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
On dea.location =vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From Percent_Population_Vaccinated










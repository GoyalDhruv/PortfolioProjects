--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking ar Total Cases vs Total Deaths

select location,date,total_cases,total_deaths, ((total_deaths/total_cases)*100) as Death_Percentage
from PortfolioProject..CovidDeaths
where location like 'China' and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Percentage of Population Got from Covid

select location,date,population, total_cases,((total_cases/population)*100) as Got_Percentage
from PortfolioProject..CovidDeaths
where location like 'China' and continent is not null
order by 1,2


--Countries with Hightest Infection Rate

select location,population, max(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as Percentage_Population_Infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by 4 desc


--Showing Countries with Highest Death Count

select location, max(cast(total_deaths as int)) as TotalDeathCount,max((total_deaths/population)*100) as Percentage_Population_DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc


-- Let's Break Things Down by Continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by 2 desc


 --Global Numbers

select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,(sum(cast(new_deaths as int))/sum(new_cases)*100) as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null


-- Total Population vs Vaccinations

select d.continent,d.location,d.date,d.population,v.new_vaccinations
, sum(CONVERT(int,v.new_vaccinations)) over 
(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d join
PortfolioProject..CovidVaccinations as V
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3



-- Use CTE

with PopvsVac(Continent,Laction,date,population,new_vaccination,RollingPeopleVaccinated)
as 
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
	sum(CONVERT(int,v.new_vaccinations)) over 
	(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d join
PortfolioProject..CovidVaccinations as V
on d.location=v.location and d.date=v.date
where d.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table
--Drop a Table (For Dropping Temp Table If we want to change anything)
Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
	sum(CONVERT(int,v.new_vaccinations)) over 
	(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d join
PortfolioProject..CovidVaccinations as V
on d.location=v.location and d.date=v.date
where d.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating Views

create view Global_Numbers as 
select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,(sum(cast(new_deaths as int))/sum(new_cases)*100) as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null

select *
from Global_Numbers
--Alex the Analyst: Portfolio Project

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select the Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the total cases vs total deaths in % (shows likelyhood of dying of Covid in your country)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
Where location like '%states'
and continent is not null
order by 1,2

--Looking at the total cases vs the population over time
--Shows what % of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as death_percentage
from PortfolioProject..CovidDeaths
Where location like '%states'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 as population_infected_percentage
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at contries with highest infection rate compated to population
select location, max(total_cases) as highest_infection, population, max((total_cases/population))*100 as population_infected_percentage
from PortfolioProject..CovidDeaths
--Where location like '%states'
Group by population, location
order by population_infected_percentage desc

--Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by total_death_count desc

--BREAKDOWN BY CONTINENT

--showing the continents with the highest death count 
select continent, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by total_death_count desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
	as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--looking at rolling vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations))
	over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE:  Common Table Expressions (CTE)
with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations))
	over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as rolling_percent_vaccinated
from pop_vs_vac

--TEMP TABLE
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations))
	over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select *, (rolling_people_vaccinated/population)*100
from #percent_population_vaccinated

--creating a view to store data for later viz

create view rolling_people_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations))
	over (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--	, (rolling_people_vaccinated / population)*100 as percent_of_population_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Self created queries


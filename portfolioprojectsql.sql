select * from [portfolio project]..CovidDeaths
order by 3,4

--select * from [portfolio project]..Covidvaccinations
--order by 3,4

--select data that we are going to be using


select location,date, total_cases, new_cases, total_deaths, population
from [portfolio project]..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
where location like 'india'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as casePercentage
from [portfolio project]..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

--looking at countries with highest infecton rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as casePercentage
from [portfolio project]..CovidDeaths
--where location like 'india'
group by population,location 
order by casePercentage desc

--showing countries with highest death count per population
select location	, max(CAST(total_deaths as int)) as DeathCount
from [portfolio project]..CovidDeaths
--where location like 'india'
where continent is not NULL
group by location
order by DeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
--showing the continents with the highest death count per population

select continent, max(CAST(total_deaths as int)) as DeathCount
from [portfolio project]..CovidDeaths
--where location like 'india'
where continent is  not NULL
group by continent
order by DeathCount desc


--GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
where continent is not null
--where location like '%states%'
--group by date
order by 1,2

select * from
[portfolio project]..Covidvaccinations



--USE CTE
--looking at total population vs vaccinated

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualisations

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated


select * 
from CovidDeaths
order by 2,3

select * 
from CovidVaccination
order by 2,3

--selecting columns to be used 
select location, date, new_cases, total_cases , total_deaths ,population
from CovidDeaths
order by location, date


-- Percent population infected by COVID
select location, date, population, new_cases, total_cases, total_deaths, (total_cases/population)*100 as infected_rate
from CovidDeaths
order by 1,2


--total cases vs total deaths in major economies
select location, date, population, new_cases, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
from CovidDeaths
where location in ('India', 'United Stetes', 'United Kingdom', 'Germany', 'China')
order by 1,2

--Globally total death count and death percentage
with gd (date, total_cases, total_death)
as
(
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death
from CovidDeaths
where continent is not null
group by date
)
select *, (total_death/total_cases)*100 as death_rate
from gd



--Countries with highest infection rate
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as highest_infection_rate
from CovidDeaths
group by location, population
order by 1,2

--Countries with highest death_rate
select location, population, max(total_deaths) as highest_death_count, max((total_deaths/total_cases)*100) as highest_death_rate
from CovidDeaths
group by location, population
order by 1,2


--continent wise highest death count (using CTE)
with hdp(continent, total_population, highest_death_count)
as 
(
select continent, sum(population) as total_population, max(total_deaths) as highest_death_count
from CovidDeaths
where continent is not null
group by continent
)
select *, (highest_death_count/total_population)*100 as highest_death_rate
from hdp



--total deaths vs total vaccination, loication and date wise
select CD.location,CD.date,CD.total_cases,  total_deaths, CV.total_vaccinations
from CovidDeaths CD
join CovidVaccination CV
on CD.location = CV.location and CD.date=CV.date
order by 1,2



--total population vs total vaccination 
select CD.continent, CD.location, CD.date, CD.population, CD.new_cases, CD.total_cases,  new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as total_vaccination
from CovidDeaths CD
join CovidVaccination CV
on CD.location=CV.location and CD.date=CV.date
where CD.continent is not null and CD.location='India'
order by location, date



--total populatiion vs percentage of population vaccinated (using CTE)
with ppv (continent, location, date, population, new_cases,total_cases,new_vaccination, total_vaccination)
as
(
select CD.continent, CD.location, CD.date, CD.population,CD.new_cases,
sum(CD.new_cases) over (partition by CD.location order by CD.location, CD.date) as total_cases,
new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as total_vaccination
from CovidDeaths CD
join CovidVaccination CV
on CD.location=CV.location and CD.date=CV.date
where CD.continent is not null
)
select *, (ppv.total_vaccination/ppv.population)*100 as vaccination_rate
from ppv
where location ='India'
order by location, date

--creating temp table( an alternate of CTE)
create table vaccination_rate
(continent nvarchar(300),
location nvarchar(300),
date datetime,
population numeric,
new_cases numeric,
total_cases numeric,
new_vaccination numeric,
total_vaccination numeric
)

insert into vaccination_rate
select CD.continent, CD.location, CD.date, CD.population,CD.new_cases,
sum(CD.new_cases) over (partition by CD.location order by CD.location, CD.date) as total_cases,
new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as total_vaccination
from CovidDeaths CD
join CovidVaccination CV
on CD.location=CV.location and CD.date=CV.date
where CD.continent is not null and CD.location = 'India'

select *, (vc.total_vaccination/vc.population)*100 as percenat_people_vaccinated
from vaccination_rate vc





















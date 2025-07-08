SELECT * 
FROM CovidDeath

select*
FROM covidvaccination 


--select data that we are using 

--looking at total cases vs total deaths 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) AS death_rate
FROM CovidDeath
order  by 1 , 2


-- showing liklihood of dying if you contact covid in NIGERIA 
SELECT location, date, total_cases, total_deaths, (total_deaths  / total_cases)*100 AS deathpercentage
FROM CovidDeath
WHERE total_cases is not null
AND location like '%nigeria%'
ORDER BY location, date;

--looking at the total case vs population( percent of total_cases per population) 

SELECT  location, date,  total_cases,  population, 
  (total_cases  / population) * 100  AS percentageofpopulationinfected 
FROM CovidDeath
WHERE total_cases IS NOT NULL
ORDER BY percentageofpopulationinfected desc


-- locations/countries that has the highest infection rate per population

SELECT location , population, MAX(total_cases) as highestinfectioncount,
max(total_cases  / population) * 100  AS percentageofpopulationinfected
FROM CovidDeath
WHERE  total_cases IS NOT NULL
and continent is not null
	GROUP BY location, population
ORDER BY percentageofpopulationinfected desc

--showing countries/location with the highest death count per population 

SELECT location , MAX(total_deaths) as totaldeathcount
FROM CovidDeath
WHERE  total_cases IS NOT NULL
and continent is not null
	GROUP BY location, population
ORDER BY totaldeathcount desc

--LETS BREAK THINGS BY CONTINENT

--total death count per continent 
SELECT continent , MAX(total_deaths) as totaldeathcount
FROM CovidDeath
WHERE  total_cases IS NOT NULL
and continent is not null
	GROUP BY continent
ORDER BY totaldeathcount desc


--GLOBAL NUMBERS 
--toal cases and total death per day globally and the death percentage 
SELECT 
      date,SUM(new_cases) AS totalcases , SUM(new_deaths) AS totaldeath , SUM(new_deaths)/SUM(new_cases) * 100 AS deathpercentage
FROM CovidDeath
WHERE total_cases is not null
group by date
ORDER BY 1,2

--LOOKING AT THE DEATH PERCENTAGE ACROSS THE WORLD
SELECT 
      SUM(new_cases) AS totalcases , SUM(new_deaths) AS totaldeath , SUM(new_deaths)/SUM(new_cases) * 100 AS deathpercentage
FROM CovidDeath
WHERE total_cases is not null
ORDER BY 1,2


--looking at total population vs vaccination
 --JOINING TOTALDEATH AND TOTALVACCCINATION DATA 
SELECT *
FROM CovidDeath dea
join CovidVaccination vac
    ON dea.location = vac.location
	and dea.date=vac.date

	
SELECT dea.continent,dea.location, dea.date,dea.population , vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeath dea
join CovidVaccination vac
    ON dea.location = vac.location
	and dea.date=vac.date
	WHERE dea.continent is not null
	and dea.population is not null
	and dea.new_vaccinations is not null
	ORDER BY 2,3
	--  we did the rolling total of people vaccinated people  per location


--NOW WE WANT TO LOOK AT THE TOTAL POPULATION VS THE VACCINATION 
--MEANING HOW MANY PEOPLE IN THAT COUNTRY ARE VACCINATED PER POPULATION 


--USING CTE
with popvsvac (continent, location,date,population,new_vaccination, newrollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location, dea.date,dea.population , vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeath dea
join CovidVaccination vac
    ON dea.location = vac.location
	and dea.date=vac.date
	WHERE dea.continent is not null
	and dea.population is not null
	and dea.new_vaccinations is not null
	--ORDER BY 2,3 
	)
SELECT *, (newrollingpeoplevaccinated/population)*100
FROM popvsvac


-- USING TEMPT TABLE 

DROP table if exists #percentpopulationvaccinated 
create table #percentpopulationvaccinated 
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)
insert #percentpopulationvaccinated
SELECT dea.continent,dea.location, dea.date,dea.population , vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeath dea
join CovidVaccination vac
    ON dea.location = vac.location
	and dea.date=vac.date
	WHERE dea.continent is not null
	and dea.population is not null
	and dea.new_vaccinations is not null
	--ORDER BY 2,3 

	SELECT *, (rollingpeoplevaccinated/population)*100
FROM #percentpopulationvaccinated 

--CREATING VIEW 
DROP VIEW IF EXISTS percentpopulationvaccinated
CREATE VIEW percentpopulationvaccinated  AS
SELECT dea.continent,dea.location, dea.date,dea.population , vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
FROM CovidDeath dea
join CovidVaccination vac
    ON dea.location = vac.location
	and dea.date=vac.date
	WHERE dea.continent is not null
	and dea.population is not null
	and dea.new_vaccinations is not null

CREATE VIEW totaldeathcount_per_continent  AS
	SELECT continent , MAX(total_deaths) as totaldeathcount
FROM CovidDeath
WHERE  total_cases IS NOT NULL
and continent is not null
	GROUP BY continent
--ORDER BY totaldeathcount desc

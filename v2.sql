Select *
From  PortfolioProject..CovidDeath
where continent is not null
order by 3,4


  -- looking at Total cases vs Total Deaths
  select location, date, total_cases, total_deaths,  (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage 
	from PortfolioProject..CovidDeath
	where location like '%Nigeria%'
	order by 1,2		


--looking at Total Cases vs Population
--show what percentage of population got covid 
 select location, date,Population, total_cases,   (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeath
where location like '%Nigeria%'
order by 1,2	


--looking at countries with highest infection rate compared to population
  select location,Population, MAX(total_cases) as HigestInfectionCount , MAX( (cast(total_deaths as float)/cast(total_cases as float)) )*100 as PercentPopulationInfected  
	from PortfolioProject..CovidDeath
	--where location like '%Nigeria%'
	Group by Location, Population
	order by percentPopulationInfected desc

-- Showing Countries with Higest Death Count per Population
 
 select location, MAX(cast(Total_Deaths as  int) ) as TotalDeathCount
 from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

 select continent, MAX(cast(Total_Deaths as  int) ) as TotalDeathCount
 from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc



-- showing the continent with the higest death count per poluplation
 select location, MAX(cast(Total_Deaths as  int) ) as TotalDeathCount
 from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
Where continent is not null
Group by location
order by TotalDeathCount desc





--GLOBAL NUMBERS
  select  SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths,  SUM (New_deaths)/SUM(New_Cases)*100 as DeathPercentage 
	from PortfolioProject..CovidDeath
	--where location like '%Nigeria%'
	where continent is not null
	--Group by date
	order by 1,2



	--looking at total population vs vaccinations


	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location)
	from portfolioProject..Coviddeath dea
	join portfolioProject..covidvaccination  vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3




   -- CTE
with popvsvac(continent, location, Date, population, New_vaccinationss, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from portfolioProject..Coviddeath dea
	join portfolioProject..covidvaccination  vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	select*, (RollingPeopleVaccinated/population)*100
	from popvsvac


	--TEMP TABLE

	drop table if exists #PercentPopulationVaccinated
	create table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	 population numeric,
	 new_vaccinations numeric,
	 RollingPeopleVaccinated numeric 
	 )
	 	
	insert into #PercentPopulationVaccinated 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from portfolioProject..Coviddeath dea
	join portfolioProject..covidvaccination  vac
	on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3
	

	select *, (RollingPeopleVaccinated/population)*100
	from #PercentPopulationVaccinated 




	--- creating view to store data for later visualzations
	  create view PercentPopulationVaccinated as
		select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from portfolioProject..Coviddeath dea
	join portfolioProject..covidvaccination  vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3


	create view continentwiththehighestdeathcount as
select location, MAX(cast(Total_Deaths as  int) ) as TotalDeathCount
 from PortfolioProject..CovidDeath
--where location like '%Nigeria%'
Where continent is not null
Group by location
--order by TotalDeathCount desc
select*
from continentwiththehighestdeathcount




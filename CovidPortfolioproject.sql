Select *
FROM CovidDeaths
order by 3,4;

--Select *
--FROM CovidVaccinations
--order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, total_deaths
FROM CovidDeaths
order by 1,2;

-- Looking at percentage of Total Cases vs Total Deaths
-- In this example we filtered just Czech country where number of total cases increases in our data set

Select location, date,total_cases, total_deaths, (CAST(total_deaths as FLOAT)/CAST(total_cases as FLOAT) *100) as DeathPercentage
FROM CovidDeaths
WHERE total_cases is not null and total_deaths is not null and location like '%Czech%' and continent is not null
order by 1,2

-- Looking at percentage of Total Cases vs Population 
-- In this example we filtered just Czech country where number of total cases increases in our data set

Select location, date, population,total_cases, ((CAST(total_cases as FLOAT)/CAST(population as FLOAT)) *100) as PercentPopulationInfected
FROM CovidDeaths
WHERE total_cases is not null and total_deaths is not null and location like '%Czech%' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 

Select location, population, MAX(CAST(total_cases as FLOAT)) as HighestInfectionCount , MAX(((CAST(total_cases as FLOAT)/CAST(population as FLOAT)) *100)) as PercentPopulationInfected
FROM CovidDeaths
WHERE total_cases is not null and total_deaths is not null and continent is not null
GROUP BY location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population 

Select location, MAX(CAST(total_deaths as FLOAT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
Group by location 
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population 

Select continent, MAX(CAST(total_deaths as FLOAT)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage 
FROM CovidDeaths
WHERE continent is not null 
order by 1,2


-- Looking at Total Population vs Vaccination 


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3 

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

-- TEMP TABLE 
DROP Table If Exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3 

Select *
From PercentPopulationVaccinated



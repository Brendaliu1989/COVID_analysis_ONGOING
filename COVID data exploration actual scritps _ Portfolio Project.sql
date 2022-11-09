SELECT * 
 FROM  Portfolio_Covid_case..CovidDeaths
 ORDER BY 3,4 

--SELECT * 
-- FROM Portfolio_Corona..CovidVaccinations 
-- ORDER BY 3,4
 
-- Select the related data for research interest 

SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM Portfolio_Covid_case..CovidDeaths 
 ORDER BY 1,2

-- Check Total Cases vs. Total Deaths 
-- Shows the likelihood of dying if you contract covid in several big countires 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
 FROM Portfolio_Covid_case..CovidDeaths
 WHERE LOCATION in ('China','United States','Russia','India','Brazil')
 AND continent IS NOT NULL 
 ORDER BY 1,2


 -- Check Total cases vs. Populations 
 -- Shows what percentage of population got Covid  

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
 FROM Portfolio_Covid_case..CovidDeaths 
 WHERE continent IS NOT NULL 
 ORDER BY 1,2

 -- Check countries with the Highest Infection Rate 

 SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases)/population)*100 AS infection_rate
 FROM Portfolio_Covid_case..CovidDeaths
 WHERE continent IS NOT NULL 
 GROUP BY location, population
 ORDER BY 4 DESC

 -- Showing countries with Hightest Death Count per Population 
 
 SELECT location, population, MAX(CAST(total_deaths AS int)) AS total_death_count, MAX((total_deaths)/population)*100 AS death_rate
 FROM Portfolio_Covid_case..CovidDeaths 
 WHERE continent IS NOT NULL 
 GROUP BY location, population
 ORDER BY total_death_count DESC

 -- Showing the Count of deaths by the preset categories 

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count 
 FROM Portfolio_Covid_case..CovidDeaths 
 WHERE continent IS NOT NULL 
 GROUP BY continent
 ORDER BY total_death_count DESC


 -- Showing continents with the highest death count per population 

SELECT continent, SUM(population) AS population_by_continent, MAX(CAST(total_deaths AS int)) AS total_death_count, MAX((total_deaths)/population)*100 AS death_rate
 FROM Portfolio_Covid_case..CovidDeaths 
 WHERE continent IS NOT NULL 
 GROUP BY continent
 ORDER BY total_death_count DESC

-- Global Numbers total numbers 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_rate
FROM Portfolio_Covid_case..CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2 


-- Join two tables of CovidDeaths with CovidVaccinations and check the sum of new vaccinations 


SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated, 
 FROM Portfolio_Covid_case..CovidDeaths  dea
 JOIN Portfolio_Covid_case..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- USE CTE to get the number of percentage of vaccinated population to the whole populations 

WITH PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
 FROM Portfolio_Covid_case..CovidDeaths  dea
 JOIN Portfolio_Covid_case..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
)
SELECT * , RollingPeopleVaccinated/population*100 AS vaccinated_rate
FROM PopvsVac


-- CREATE TEMP TABLE 


CREATE TABLE #PercentPopulationVaccinated 
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric, 
 RollingPeopleVaccinated numeric
 )
INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
 FROM Portfolio_Covid_case..CovidDeaths  dea
 JOIN Portfolio_Covid_case..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 

SELECT *, (RollingPeopleVaccinated/Population)*100 AS vaccinated_rate
 FROM #PercentPopulationVaccinated


 -- CREATE VIEW 

CREATE VIEW total_vaccinations AS 

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
 FROM Portfolio_Covid_case..CovidDeaths  dea
 JOIN Portfolio_Covid_case..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 


SELECT * FROM total_vaccinations
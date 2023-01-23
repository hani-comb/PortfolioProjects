SELECT   *
FROM     portfolioproject..coviddeaths
ORDER BY 3,
         4;SELECT   *
FROM     portfolioproject..covidvaccinations
ORDER BY 3,
         4;SELECT   location,
         date,
         total_cases,
         new_cases,
         total_deaths,
         population
FROM     portfolioproject..coviddeaths
ORDER BY 3,
         4;

-- Looking at Deaths against CasesSELECT   location,
         date,
         total_cases,
         total_deaths,
         (total_deaths/total_cases)*100 AS DeathPercentage
FROM     portfolioproject..coviddeaths
         -- WHERE location like '%Netherlands%'
ORDER BY 3,
         4;

-- Looking at cases against populationSELECT   location,
         date,
         total_cases,
         population,
         (total_cases/population)*100 AS CasePercentage
FROM     portfolioproject..coviddeaths
         -- WHERE location like '%Netherlands%'
ORDER BY 3,
         4;

-- Detecting countires with highest infection ratesSELECT   location,
         Max(total_cases) AS HighestInfectionCount,
         population,
         Max((total_cases/population))*100 AS CasePercentage
FROM     portfolioproject..coviddeaths
         -- WHERE location like '%Netherlands%'
GROUP BY location,
         population
ORDER BY casepercentage DESC;

-- FACETTING BY CONTINENT
-- Displaying contintents with the highest death count per populationSELECT   continent,
         Max(Cast(total_deaths AS INT)) AS TotalDeathCount
FROM     portfolioproject..coviddeaths
         --Where location like '%Netherlands%'
WHERE    continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- Calculating death percentage on a global levelSELECT   Sum(new_cases)                                  AS total_cases,
         Sum(Cast(new_deaths AS INT))                    AS total_deaths,
         Sum(Cast(new_deaths AS INT))/Sum(new_cases)*100 AS DeathPercentage
FROM     portfolioproject..coviddeaths
         --WHERE location like '%Netherlands%'
WHERE    continent IS NOT NULL
         --GROUP BY date
ORDER BY 1,
         2
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid VaccineSELECT   dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations ,
         Sum(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
         --, (RollingPeopleVaccinated/population)*100
FROM     portfolioproject..coviddeaths dea
JOIN     portfolioproject..covidvaccinations vac
ON       dea.location = vac.location
AND      dea.date = vac.date
WHERE    dea.continent IS NOT NULL
ORDER BY 2,
         3
-- Using CTE to perform Calculation on Partition By in previous query
with popvsvac
      (
            continent,
            location,
            date,
            population,
            new_vaccinations,
            rollingpeoplevaccinated
      )
      AS
      (
               SELECT   dea.continent,
                        dea.location,
                        dea.date,
                        dea.population,
                        vac.new_vaccinations ,
                        sum(CONVERT(bigint,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
                        --, (RollingPeopleVaccinated/population)*100
               FROM     portfolioproject..coviddeaths dea
               JOIN     portfolioproject..covidvaccinations vac
               ON       dea.location = vac.location
               AND      dea.date = vac.date
               WHERE    dea.continent IS NOT NULL
                        --order by 2,3
      )SELECT *,
       (rollingpeoplevaccinated/population)*100
FROM   popvsvac
-- Using Temp Table to perform Calculation on Partition By in previous queryDROP TABLEIF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
             (
                          continent               nvarchar(255),
                          location                nvarchar(255),
                                                  date datetime,
                          population              numeric,
                          new_vaccinations        numeric,
                          rollingpeoplevaccinated numeric
             )INSERT INTO #percentpopulationvaccinated
SELECT   dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations ,
         Sum(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
         --, (RollingPeopleVaccinated/population)*100
FROM     portfolioproject..coviddeaths dea
JOIN     portfolioproject..covidvaccinations vac
ON       dea.location = vac.location
AND      dea.date = vac.date
--where dea.continent is not null
--order by 2,3SELECT *,
       (rollingpeoplevaccinated/population)*100
FROM   #percentpopulationvaccinated
-- Creating View to store data for later visualizationsCREATE VIEW percentpopulationvaccinated AS
SELECT   dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations ,
         Sum(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
         --, (RollingPeopleVaccinated/population)*100
FROM     portfolioproject..coviddeaths dea
JOIN     portfolioproject..covidvaccinations vac
ON       dea.location = vac.location
AND      dea.date = vac.date
WHERE    dea.continent IS NOT NULL

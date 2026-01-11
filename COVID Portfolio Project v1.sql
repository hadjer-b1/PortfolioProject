SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVacc
--ORDER BY 3,4

SELECT location, date, total_cases,new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
--Likelyhood of dying if u contract covid in Algeria 
SELECT location, date, total_cases,total_deaths,
(total_deaths*1.0/ total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Algeria%'
ORDER BY 1, 2

--Total Cases VS Population

SELECT location, date, total_cases,population,
(total_cases*1.0/population)*100 AS CasesPerPopPer
FROM PortfolioProject..CovidDeaths
WHERE location like '%Algeria%'
ORDER BY 1, 2

--Countries with the highest Infection Rate Compared to population

SELECT location,population ,
     MAX(total_cases) HighestInfectionCount, 
     MAX ((total_cases*1.0/population))*100 AS PercentagePopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Algeria%'
GROUP By location,population
ORDER BY PercentagePopInfected DESC



-- Countries with the highest death count per population
SELECT location ,
     MAX(total_deaths) TotalDeathCount, 
     MAX ((total_deaths*1.0/population))*100 AS PercentageDeathsPerPop
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Algeria%'
GROUP By location
ORDER BY TotalDeathCount DESC

--  If we wanna change a column into different type we use 
-- cast (col_name as col_type), ex. cast(total as int)


-- Breaking down by continent 

SELECT continent ,
     MAX(total_deaths) TotalDeathCount, 
     MAX ((total_deaths*1.0/population))*100 AS PercentageDeathsPerPop
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Algeria%'
GROUP By continent
ORDER BY TotalDeathCount DESC

----------------------------------------------
SELECT location ,
     MAX(total_deaths) TotalDeathCount, 
     MAX ((total_deaths*1.0/population))*100 AS PercentageDeathsPerPop
FROM PortfolioProject..CovidDeaths
WHERE continent is  NULL
--WHERE location like '%Algeria%'
GROUP By location
ORDER BY TotalDeathCount DESC

-- Continent with highest death
SELECT continent,
     MAX(total_deaths) TotalDeathCount, 
     MAX ((total_deaths*1.0/population))*100 AS PercentageDeathsPerPop
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Algeria%'
GROUP By continent
ORDER BY TotalDeathCount DESC

-- Global Numbers


SELECT   SUM(new_cases) TotalCasesPerDay,
        SUM(new_deaths) TotalDeathsPerDay,
        SUM(new_deaths*.1)/SUM(new_cases)*100 DeathPercentage
--,total_deaths,(total_deaths*1.0/ total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1, 2












-- Total Populations VS Vaccinations
SELECT dea.continent, dea.location, 
       dea.date, vac.new_vaccinations,
       SUM(CONVERT(int,new_vaccinations)) 
           OVER (PARTITION BY dea.location
                 ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
     ON dea.location = vac.location 
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- Use CTE

WITH PopVsVac (continent, location, date, population,new_vacinations, RollinPeopleVaccinated)
as(
SELECT dea.continent, dea.location, 
       dea.date,dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,new_vaccinations)) 
           OVER (PARTITION BY dea.location
                 ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
     ON dea.location = vac.location 
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollinPeopleVaccinated/population)*100 PercentageOfVaccperPopulation
FROM PopVsVac


-- TEMP Table
DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopVacc
SELECT dea.continent, dea.location, 
       dea.date,dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,new_vaccinations)) 
           OVER (PARTITION BY dea.location
                 ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
     ON dea.location = vac.location 
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/population)*100 PercentageOfVaccperPopulation
FROM #PercentPopVacc


-- Creating a view to store data for later visualistion 

CREATE VIEW PercentPopVacc as
SELECT dea.continent, dea.location, 
       dea.date,dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,new_vaccinations)) 
           OVER (PARTITION BY dea.location
                 ORDER BY dea.location, dea.date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacc vac
     ON dea.location = vac.location 
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopVacc


















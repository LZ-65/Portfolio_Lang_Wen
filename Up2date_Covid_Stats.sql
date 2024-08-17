SELECT * 
FROM PortfolioProject..CovidDeath
WHERE continent is not null
ORDER BY 3, 4;

-- SELECT * 
-- FROM PortfolioProject..CovidVaccinations
-- ORDER BY 3,4;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if being infected with Covid-19

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases *100) as death_percentage
FROM PortfolioProject..CovidDeath
WHERE continent is not null and location like '%state%' and total_cases != 0
ORDER BY 1, 2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid-19

SELECT location, date, total_cases, population, (total_cases / population * 100) as infection_rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null and location like '%state%' and total_cases != 0
ORDER BY 1, 2; 

-- Looking at Countries with Highest Infection Rate compare to Population

SELECT location, population, MAX(total_cases) as highest_count, MAX((total_cases / population * 100)) as highest_infection_rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- Looking at Counties with Highest Death Count per Population

SELECT location, MAX(total_deaths) as highest_death_count
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count DESC;

-- BREAKING THINGS DOWN IN CONTINENT
-- Showing Continents with Higherst Death Count per Population

SELECT continent, MAX(total_deaths) as highest_death_count
FROM PortfolioProject..CovidDeath
WHERE continent is not NULL
GROUP BY continent 
ORDER BY highest_death_count DESC;

-- GLOBAL NUMBERS
-- Showing Global Death Rate per Day

SELECT date, SUM(new_cases), SUM(new_deaths), (SUM(new_deaths) / SUM(new_cases) * 100) as death_rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null and new_cases != 0 and date > '2020-01-05'
GROUP BY date 
ORDER BY date;

-- Showing Global Total Cases, Total Deaths, and Death Rate

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) / SUM(new_cases) * 100) as death_rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null and new_cases != 0 and date > '2020-01-05';




SELECT *
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null; 

-- Use CTE

WITH POPvsVAC (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
)
SELECT *, (rolling_vaccinations / CONVERT(FLOAT, population) * 100) as rolling_vac_rate
FROM POPvsVAC;

-- OR

SELECT *, (rolling_vaccinations / CONVERT(FLOAT, population) * 100) as rolling_vac_rate
FROM
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
) t;

-- Use TEMP TABLE

DROP TABLE IF EXISTS #VAC_RATE
CREATE TABLE #VAC_RATE
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_vaccinations NUMERIC
)

INSERT INTO #VAC_RATE
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null

SELECT *, (rolling_vaccinations / CONVERT(FLOAT, population) * 100) as rolling_vac_rate
FROM #VAC_RATE;

-- CREATE VIEW

CREATE VIEW ROLLING_VAC AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null;

SELECT * 
FROM ROLLING_VAC;


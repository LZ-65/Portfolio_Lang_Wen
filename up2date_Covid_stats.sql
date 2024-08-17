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

-- Looking at Counties with Highest Death Count per population
SELECT location, MAX(total_deaths) as highest_death_count
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count DESC;

-- BREAKING THINGS DOWN IN CONTINENT
SELECT location, MAX(total_deaths) as highest_death_count
FROM PortfolioProject..CovidDeath
WHERE continent is NULL
GROUP BY location 
ORDER BY highest_death_count DESC;
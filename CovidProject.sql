USE covid;

SELECT * FROM coviddeaths
WHERE continent is not null
ORDER BY location, date;

SELECT * FROM covidvaccination
ORDER BY location, date;

-- Select date that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY location, date;

-- Looking at Total Cases vs Total deaths
-- Showing likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathprecentage
FROM coviddeaths
WHERE location like '%Japan%'
ORDER BY location, date;

-- Looking at Total Cases vs Population
-- Showing what precentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS caseprecentage
FROM coviddeaths
WHERE location like '%Japan%'
ORDER BY location, date;


-- Looking at countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,
			 MAX((total_cases/population))*100 as CovidPercentage
FROM coviddeaths
GROUP BY location, population
ORDER BY CovidPercentage desc;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc;


-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- Global Numbers

SELECT SUM(new_cases), sum(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 as deathprecentage
FROM coviddeaths
WHERE continent is not null
-- GROUP BY date
ORDER BY 1, 2;


-- Looking at Total Population vs Vaccinations

DROP TABLE IF EXISTS #PrecentPopulationVaccinated;
CREATE Table #PrecentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric);


Insert into #PrecentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated, (SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date)/population)*100
FROM coviddeaths dea
JOIN covidvaccination vac 
			ON dea.location = vac.location
					and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3;


CREATE VIEW PrecentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated, (SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date)/population)*100
FROM coviddeaths dea
JOIN covidvaccination vac 
			ON dea.location = vac.location
					and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3;


SELECT * FROM PrecentPopulationVaccinated
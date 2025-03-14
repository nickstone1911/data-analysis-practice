--Data Exploration

--Select all data from the deaths table

SELECT *
FROM covid-data-448023.Covid_data.Covid_Deaths covd
WHERE continent is NOT NULL
AND location= 'Hong Kong'
ORDER BY 3,4
;

--Select all data from the vaccinations table

SELECT *
FROM covid-data-448023.Covid_data.Covid_Vaccinations covv
WHERE continent is NOT NULL
ORDER BY 3,4
;

--Total Cases vs. Total Deaths
--This shows how likely a person is to die in each country if they contract COVID (Italy used for example)

SELECT location, date, total_cases,ROUND((total_deaths/total_cases)*100,2) as deathPercentage
FROM covid-data-448023.Covid_data.Covid_Deaths covd
WHERE continent is NOT NULL
AND location = 'Italy'
ORDER BY 2
;

--Total Cases vs. Total Deaths grouped by country

SELECT location, MAX(total_cases) as total_cases, MAX(total_deaths) as total_deaths, ROUND((MAX(total_deaths)/MAX(total_cases))*100,2) as deathPercentage
FROM covid-data-448023.Covid_data.Covid_Deaths covd
WHERE continent is NOT NULL
AND total_cases is NOT NULL
AND total_deaths is NOT NULL
GROUP BY location
ORDER BY 4 DESC
;


--Total cases vs. population
--This shows what percent of the population contracted COVID

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) as infectedPercentage
FROM covid-data-448023.Covid_data.Covid_Deaths covd
WHERE continent is NOT NULL
AND location = 'Italy'
ORDER BY 2
;

--Total cases vs. population grouped by country

SELECT location, MAX(total_cases) as total_cases, MAX(population) as population, ROUND((MAX(total_cases)/MAX(population))*100,2) as infectedPercentage
FROM covid-data-448023.Covid_data.Covid_Deaths covd
WHERE continent is NOT NULL
AND total_cases is NOT NULL
GROUP BY location
ORDER BY 4 DESC
;


--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, ROUND(SUM(new_deaths)/SUM(New_Cases)*100,2) as DeathPercentage
FROM covid-data-448023.Covid_data.Covid_Deaths covd
where continent is not null 
order by 1,2
;

--Numbers by continent

SELECT continent, MAX(Total_deaths) as TotalDeathCount, MAX(total_cases) as TotalCaseCount
FROM covid-data-448023.Covid_data.Covid_Deaths covd
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
;


--Join vaccinations table to look at vaccinations vs population

SELECT covd.location, covd.population, SUM(covv.new_vaccinations) as new_vaccinations
FROM covid-data-448023.Covid_data.Covid_Vaccinations covv
JOIN covid-data-448023.Covid_data.Covid_Deaths covd
  ON covv.location = covd.location
  AND covv.date = covd.date
WHERE covd.continent is NOT NULL
GROUP BY location, population
ORDER BY 1
;


-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT covd.continent, covd.location, covd.date, covd.population, covv.new_vaccinations, SUM(covv.new_vaccinations) OVER (PARTITION BY covd.Location ORDER BY covd.location, covd.Date) as RollingPeopleVaccinated,  (SUM(covv.new_vaccinations) OVER (PARTITION BY covd.location ORDER BY covd.date) / covd.population) * 100 AS VaccinationPercentage
FROM covid-data-448023.Covid_data.Covid_Vaccinations covv
JOIN covid-data-448023.Covid_data.Covid_Deaths covd
  ON covv.location = covd.location
  AND covv.date = covd.date
WHERE covd.continent is NOT NULL
AND covv.new_vaccinations is NOT NULL
ORDER BY 2,3
;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac 
AS
(
SELECT covd.continent, covd.location, covd.date, covd.population, covv.new_vaccinations
, SUM(CAST(covv.new_vaccinations AS INT)) OVER (PARTITION BY covd.Location ORDER BY covd.location, covd.Date) AS RollingPeopleVaccinated
FROM covid-data-448023.Covid_data.Covid_Deaths covd
JOIN covid-data-448023.Covid_data.Covid_Vaccinations covv
	ON covd.location = covv.location
	AND covd.date = covv.date
WHERE covd.continent is NOT NULL 
ORDER BY 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100, 2) as Vac_Percentage
FROM PopvsVac
WHERE new_vaccinations is NOT NULL





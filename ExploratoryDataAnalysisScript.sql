/*
COVID-19: Data Exploration

Skills used: Aggregate Functions, Converting Data types, Joins, Arithmetic Functions, Temp Tables, CTEs, windows Functions, Creating Views*/
 
 -- View Datasets

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT*
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select data for analysis

SELECT location,date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Numbers by Continent

SELECT Continent,date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Total cases Vs.Total deaths per Location
-- Likelihood of dying if you were Infected for each location

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS PercentageDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- A look at the Canadian Numbers 
-- Likelihood of dying if you were Infected in Canada

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS PercentageDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
	AND location ='Canada'
ORDER BY 3 DESC

-- Total Cases Vs Total Deaths Globally
-- Likelihood of dying if you were Infected 

SELECT Continent,date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS PercentageDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


-- Total Cases Vs Population
-- Shows what percentage of population reported with covid 

SELECT location,date,population,total_cases, (total_cases/population)*100 AS PecentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order by 1,2


-- Country with the highest Infection Rate per Population 

SELECT location,population, MAX(total_cases)AS HigestInfectionCnt, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC

-- Global Infection rate per Population
-- Showing Infection Rate by Continent

SELECT Continent,population, MAX(total_cases)AS HigestInfectionCnt, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent,population
ORDER BY 4 DESC

-- Location with the Highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 2 DESC


-- A BREAKDOWN BY CONTINENTS
-- Highest Deaths Per continent

SELECT Continent, MAX(CONVERT(int,total_deaths)) AS HighestDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY HighestDeathCount DESC

-- Total rate of new deaths per new cases 

SELECT Date, SUM(new_cases)AS TotalGlobalNewCases,SUM(CAST(new_deaths AS int))AS TotalGlobalDeaths    
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY Date DESC

-- Reath Rate Per day

SELECT Date, SUM(new_cases)AS TotalGlobalNewCases,SUM(CAST(new_deaths AS int))AS TotalGlobalDeaths, 
(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS PercentageGlobalDeaths
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Canada'
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 3 DESC

-- Total Summary of death rate per new cases

SELECT SUM(new_cases)AS TotalGlobalNewCases,SUM(CAST(new_deaths AS int))AS TotalGlobalDeaths, 
(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS PercentageGlobalDeaths
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Canada'
WHERE continent IS NOT NULL 

SELECT*
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT*
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Lets Join the Covid Deaths and Covid Vaccination Table

SELECT *
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations As Vax
	ON death.location =Vax.location
	AND death.date = Vax.date


-- A look at Vaccination
--PARTITION BY location

SELECT death.continent, death.location,death.date,death.population, vax.new_vaccinations,
SUM(CAST(vax.new_vaccinations AS INT))OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS NewVaccinationSum  
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations As Vax
	ON death.location =Vax.location
	AND death.date = Vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE for calculation with PARTITION BY in the Query Above

WITH VaxPop (Continent, location, Date, Population, new_vaccinations, NewVaccinationSum)AS 
(
SELECT death.continent, death.location,death.date,death.population, vax.new_vaccinations,
SUM(CAST(vax.new_vaccinations AS INT))OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS NewVaccinationSum  
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations As Vax
	ON death.location =Vax.location
	AND death.date = Vax.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (NewVaccinationSum/Population)*100 AS PercenatagePopVaxxed
FROM VaxPop

-- Using Temp Table to Perform calculation on Partition By in Previous Query

DROP TABLE IF EXISTS #VaccPop
CREATE TABLE #VaccPop
(Continent varchar(50),
Location Varchar (50),
date datetime,
Population int,
new_vaccination int,
NewVaccinationSum int)

INSERT INTO #VaccPop
SELECT death.continent, death.location,death.date,death.population, vax.new_vaccinations,
SUM(CAST(vax.new_vaccinations AS INT))OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS NewVaccinationSum  
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations As Vax
	ON death.location =Vax.location
	AND death.date = Vax.date
	WHERE death.continent IS NOT NULL
-- Order By 2,3


SELECT*
FROM  #VaccPop
Order By 1,2


-- Creating View to store data for later Visualization 

CREATE VIEW VaccPop AS
SELECT death.continent, death.location,death.date,death.population, vax.new_vaccinations,
SUM(CAST(vax.new_vaccinations AS INT))OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS NewVaccinationSum  
FROM PortfolioProject..CovidDeaths AS death
JOIN PortfolioProject..CovidVaccinations As Vax
	ON death.location =Vax.location
	AND death.date = Vax.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

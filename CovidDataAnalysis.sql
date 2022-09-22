SELECT * 
FROM PortfolioProject..CovidDeaths 

--1)Data Clearing and Understanding

--Data is repeated, in location, they have summed up the information for the whole continent by naming the location by the continent
SELECT * 
FROM PortfolioProject..CovidDeaths 

SELECT DISTINCT(continent) 
FROM PortfolioProject..CovidDeaths 

SELECT DISTINCT(location) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS null

--Ensuring both the population in the summarised version of continent is the same as the individual version
--North America 
WITH NAPopCTE (NALocations, NAPopulation) AS (
SELECT DISTINCT(location) AS NALocations, AVG(population) AS NAPopulation
FROM PortfolioProject..CovidDeaths 
WHERE continent in ('North America')
GROUP BY location
)

SELECT SUM(NAPopulation) 
FROM NAPopCTE

SELECT DISTINCT(population) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL 
AND location in( 'North America')

--Asia
WITH AsiaPopCTE (AsiaLocations, AsiaPopulation) AS (
SELECT DISTINCT(location) AS AsiaLocations, AVG(population) AS AsiaPopulation
FROM PortfolioProject..CovidDeaths 
WHERE continent in ('Asia')
GROUP BY location
)

SELECT SUM(AsiaPopulation) 
FROM AsiaPopCTE

SELECT DISTINCT(population) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL 
AND location in( 'Asia')

--Africa
WITH AfricaPopCTE (AfricaLocations, AfricaPopulation) AS (
SELECT DISTINCT(location) AS AfricaLocations, AVG(population) AS AfricaPopulation
FROM PortfolioProject..CovidDeaths 
WHERE continent in ('Africa')
GROUP BY location
)

SELECT SUM(AfricaPopulation) 
FROM AfricaPopCTE

SELECT DISTINCT(population) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL 
AND location in( 'Africa')

--Oceania
--When dealing with Oceania will have to manually deal with the data as there is a discreptancy in the Individual and combined continent data
WITH OceaniaPopCTE (OceaniaLocations, OceaniaPopulation) AS (
SELECT DISTINCT(location) AS OceaniaLocations, AVG(population) AS OceaniaPopulation
FROM PortfolioProject..CovidDeaths 
WHERE continent in ('Oceania')
GROUP BY location
)

SELECT SUM(OceaniaPopulation) 
FROM OceaniaPopCTE

SELECT DISTINCT(population) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL 
AND location in( 'Oceania')

--South America
WITH SAPopCTE (SALocations, SAPopulation) AS (
SELECT DISTINCT(location) AS SALocations, AVG(population) AS SAPopulation
FROM PortfolioProject..CovidDeaths 
WHERE continent in ('South America')
GROUP BY location
)

SELECT SUM(SAPopulation) 
FROM SAPopCTE

SELECT DISTINCT(population) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL 
AND location in( 'South America')

--Europe
WITH EuropePopCTE (EuropeLocations, EuropePopulation) AS (
SELECT DISTINCT(location) AS EuropeLocations, AVG(population) AS EuropePopulation
FROM PortfolioProject..CovidDeaths 
WHERE continent in ('Europe')
GROUP BY location
)

SELECT SUM(EuropePopulation) 
FROM EuropePopCTE

SELECT DISTINCT(population) 
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NULL 
AND location in( 'Europe')

--Orgenising Data into countries and continents

--Creating view for only countries
--CovidDeath
CREATE VIEW CountCovidDeath AS 
SELECT *
FROM PortfolioProject..CovidDeaths 
WHERE continent is not NULL

--CovidVaccinations
CREATE VIEW CountCovidVac AS
SELECT * FROM PortfolioProject..CovidVaccinations
WHERE continent is not NULL

--Creating view for only continents
--CovidDeath
CREATE VIEW ContCovidDeath AS
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
AND Location in ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')

--CovidVaccinations
CREATE VIEW ContCvoidVac AS
SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is null 
AND Location in ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')


--Data Analysis 
SELECT * 
FROM PortfolioProject..CountCovidDeath 
--1) Total Cases vs Total Deaths
SELECT location, date, total_cases AS TotalCases, CAST(total_deaths AS INT) AS TotalDeath, ROUND((CAST(total_deaths AS INT)/total_cases)*100,4) AS DeathPercentageOfInfected
FROM PortfolioProject..CountCovidDeath 
ORDER BY 1,2

--2) Total Cases vs Population
SELECT location, date, total_cases AS TotalCases, Population, ROUND((total_cases/population)*100,5) AS PercentInfected 
FROM PortfolioProject..CountCovidDeath 
ORDER BY 1, 2

--3)Looking at Countries with Highest Infection Rate per population
SELECT Location, Population, MAX(total_cases) AS HighestInfection, ROUND((MAX(total_cases)/population)*100,4) AS InfectionRateByCountry
FROM PortfolioProject..CountCovidDeath 
GROUP BY Location, population
ORDER BY 4 DESC

--4)Looking at Countries with Highest Death Count
SELECT Location, MAX(CAST(total_deaths AS INT)) AS HighestTotalDeathCount
FROM PortfolioProject..CountCovidDeath
GROUP BY location
ORDER BY HighestTotalDeathCount DESC

--Looking at continent 
SELECT * 
FROM PortfolioProject..ContCovidDeath
ORDER BY location

--5)Continents with the higest death rate due to Covid 

SELECT location, MAX(CAST(total_deaths AS INT))--/population)*100
FROM PortfolioProject..ContCovidDeath
GROUP BY location
ORDER BY MAX(total_deaths)

--Vaccination 

--6)Looking at Total Population Vs Vaccinations (This is for countries)
SELECT dea.continent, dea.Location, dea.Date, dea.Population, CAST(vac.new_vaccinations AS BIGINT) AS NewVaccination,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CountCovidDeath dea
JOIN PortfolioProject..CountCovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date

 DROP TABLE IF EXISTS #Temp_CountPopVaccinated

 CREATE TABLE #Temp_CountPopVaccinated (
 Location varchar (100),
 Date datetime,
 Population float, 
 NewVaccinations float,
 RollingPeopleInCountVaccinated float
 )
 
 INSERT INTO #Temp_CountPopVaccinated
 SELECT dea.Location, dea.Date, dea.Population, CAST(vac.new_vaccinations AS float) AS NewVaccination,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinations
FROM PortfolioProject..CountCovidDeath dea
JOIN PortfolioProject..CountCovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleInCountVaccinated/Population)*100 AS PopulationOfCountryVaccinated
FROM #Temp_CountPopVaccinated
ORDER BY Location, Date


--Looking at Total Population VS Vaccinations (this is for continent)

 --7)Percent of Continent Vaccinated

 DROP TABLE IF EXISTS #Temp_ContPopVaccinated

 CREATE TABLE #Temp_ContPopVaccinated (
 Continent varchar (100),
 Date datetime,
 Population float,
 NewCases float, 
 RollingCases float,
 NewDeaths float,
 RollingDeaths float,
 NewVaccinations float,
 RollingPeopleInContVaccinated float

 )

 SELECT * 
 FROM #Temp_ContPopVaccinated


INSERT INTO #Temp_ContPopVaccinated
SELECT dea.location, dea.date, dea.population, dea.new_cases AS NewCases, SUM(dea.new_cases) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingCases,
CAST(dea.new_deaths AS float) AS NewDeaths, SUM(CAST(dea.new_deaths AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingDeaths,
CAST(vac.new_vaccinations AS float) AS NewVaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)AS RollingPeopleInContVaccinated
FROM PortfolioProject..ContCovidDeath dea
JOIN PortfolioProject..ContCvoidVac vac
 ON dea.location = vac.location
 AND dea.date = vac.date

 SELECT *
 FROM #Temp_ContPopVaccinated


 --SELECT *, (RollingPeopleInContVaccinated/Population)*100 AS PopulationOfContinentVaccinated
 --FROM #Temp_ContPopVaccinated
 --ORDER BY Continent, Date


 --Tableau
 --1)Global Numbers (Centre Top)
DROP TABLE IF EXISTS #Temp_TotalVacCount

CREATE TABLE #Temp_TotalVacCount (
Country varchar (100),
TotalCases float,
TotalDeaths float,
TotalVaccination float
)

INSERT INTO #Temp_TotalVacCount
SELECT dea.location,SUM(dea.new_cases) AS TotalCases, SUM(CAST(new_deaths AS float)) AS TotalDeaths,MAX(CAST(total_vaccinations AS FLOAT)) AS TotalVaccination
FROM PortfolioProject..CountCovidDeath dea
JOIN PortfolioProject..CountCovidVac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
GROUP BY dea.location

SELECT * 
FROM #Temp_TotalVacCount

--Results to display 
SELECT SUM(TotalCases) AS GlobalCases, SUM(TotalDeaths) AS GlobalDeaths, SUM(TotalVaccination) AS GlobalVaccinationsGiven 
FROM #Temp_TotalVacCount


--GRAPHS ON THE RIGHT (using the temp table #Temp_ContPopVaccinated from query 7.)
--1) new cases since the beginning 

SELECT Date, SUM(NewCases) AS DailyNewCases
FROM #Temp_ContPopVaccinated
GROUP BY date
ORDER BY date

SELECT Date, SUM(NewDeaths) AS DailyNewDeaths
FROM #Temp_ContPopVaccinated
GROUP BY date
ORDER BY date

SELECT Date , SUM(NewVaccinations) AS DailyVaccinations
FROM #Temp_ContPopVaccinated
GROUP BY date
ORDER By date 

--Continent Information on the Left
SELECT * FROM 
#Temp_ContPopVaccinated

SELECT Continent, SUM(NewCases) AS TotalCases 
FROM #Temp_ContPopVaccinated
GROUP BY Continent
ORDER BY TotalCases DESC

SELECT Continent, SUM(NewDeaths) AS TotalDeaths
FROM #Temp_ContPopVaccinated
GROUP BY Continent
ORDER BY TotalDeaths DESC

SELECT Continent, SUM(NewVaccinations) AS TotalVaccinations
FROM #Temp_ContPopVaccinated
GROUP BY Continent
ORDER BY TotalVaccinations DESC

--Middle Map For Countries

DROP TABLE IF EXISTS #Temp_CountryInfo 

CREATE TABLE #Temp_CountryInfo (
Country varchar (100),
Date datetime,
Population float, 
NewCases float,
NewDeaths float,
NewVaccinations float
)

SELECT * FROM #Temp_CountryInfo
ORDER BY Country, Date

INSERT INTO #Temp_CountryInfo
SELECT dea.Location, dea.date, dea.Population,  dea.new_cases, CAST(dea.new_deaths AS FLOAT), vac.new_vaccinations 
FROM PortfolioProject..CountCovidDeath dea
JOIN PortfolioProject..CountCovidVac vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
ORDER BY location, date


SELECT Country, SUM(NewCases) AS TotaLCases, SUM(NewDeaths) AS TotalDeaths, (SUM(NewDeaths)/SUM(NewCases)) * 100 AS DeathRateOfInfected, SUM(NewVaccinations) AS TotalVaccinations
FROM #Temp_CountryInfo
GROUP BY Country








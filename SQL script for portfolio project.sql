-- Selecting the data that will be used 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null 
order by 1,2

-- Total Cases vs Total Deaths per country 
-- showing the likleyhooh of dying if contratc COVID in each country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Total cases vs population of UK 
-- showing the percentage of the population got covid 
SELECT location, date, population, total_cases, (total_cases/population)*100 as Percentage_Of_Population_Infected
FROM CovidDeaths
WHERE location = 'United Kingdom'
and continent is not null 
ORDER BY 1,2

-- Looking at what countries had the highest infection rate compared to the popluation
SELECT location, population, MAX(total_cases)as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_Of_Population_Infected
FROM CovidDeaths
WHERE continent is not null 
GROUP BY location, population
ORDER BY Percentage_Of_Population_Infected desc

-- Showing countries with the highest death count per population 
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY Total_Death_Count desc

-- Total death count per continent
-- Showing the continents with the highest death counts
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY Total_Death_Count desc

-- Total new cases and total new deaths golbally each day 
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
*100 as Daily_Death_Percentage
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date 
ORDER BY 1,2

--Total cases, Total deaths and Death percentage globally
-- Shows if you contracted COVID there was a 2.1% chance of death 
SELECT  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Joining Covid death and Covid Vaccine tables together 
-- Using alias for the table names 
SELECT *
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- Population vs Vaccinations

-- Number of Vaccines administered each day per country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Number of Vaccines admistered each day per country and rolling total of vaccines given per country 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as Rolling_Total_of_Vaccines
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Creating a CTE to establish percentage of population that has been vaccinated per country 
WITH populationVsVaccination (Continent, location, date, population, New_Vaccinations, Rolling_Total_of_People_Vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as Rolling_Total_of_People_Vaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
) 
SELECT *, (Rolling_Total_of_People_Vaccinated/population)*100 as Percentage_of_Population_Vaccinated
FROM populationVsVaccination

-- Creating Temp table to establish percentage of population that has been vaccinated per country 
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent  nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Total_of_People_Vaccinated numeric,
)
Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as Rolling_Total_of_People_Vaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT *, (Rolling_Total_of_People_Vaccinated/population)*100 as Percentage_of_Population_Vaccinated
FROM #PercentagePopulationVaccinated

-- Creating View to store data for later visualisations 
Create View Percentage_People_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order By dea.location, dea.date) as Rolling_Total_of_People_Vaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM Percentage_People_Vaccinated

-- Creating view for Death count per continent 
Create view Total_Death_Count_per_Continent as
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidDeaths
WHERE continent is null 
GROUP BY location

SELECT * 
FROM Total_Death_Count_per_Continent

-- Creating view for total cases vs total deaths per country 
Create view Total_Cases_VS_Total_Deaths_per_Country as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidDeaths
WHERE continent is not null 

SELECT *
FROM Total_Cases_VS_Total_Deaths_per_Country

--SELECT location, date, total_cases,	new_cases, total_deaths, population
--FROM CovidDeaths$
--ORDER BY 1,2

--Looking at  Total deaths vs total cases
--Shows liklihood of dying in contract with covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS Death_Percentage
FROM CovidDeaths$
WHERE location  like '%India%'
ORDER BY 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid

SELECT location, date, total_cases, Population, (total_cases / Population) * 100 AS Percentage_of_Population_got_COVID
FROM CovidDeaths$
WHERE location like '%India%'
ORDER BY 1,2

--Looking at highest percent of population infected among all countries

SELECT location, MAX(total_cases) AS Total_Cases, Population, MAX((total_cases / Population)) * 100 AS Percentage_of_Population_got_COVID
FROM CovidDeaths$
GROUP BY location, population
ORDER BY Percentage_of_Population_got_COVID DESC

--Showing total deaths countrywise

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Deaths
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY Total_Deaths DESC

--Showing total deaths continentwise

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Deaths
FROM CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY Total_Deaths DESC

--Looking for golbal numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total deaths, cases and percentage globally

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


--Looking at population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Vaccinated_TillDate
FROM CovidVaccinations$ AS vac
JOIN CovidDeaths$ AS dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
ORDER BY 2,3


-- using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Vaccinated_TillDate)
AS

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Vaccinated_TillDate
FROM CovidVaccinations$ AS vac
JOIN CovidDeaths$ AS dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null
)

SELECT *, (Vaccinated_TillDate/population)*100
FROM PopvsVac


--create view

CREATE VIEW PercentPopulationVaccinate AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS Vaccinated_TillDate
FROM CovidVaccinations$ AS vac
JOIN CovidDeaths$ AS dea
	ON vac.location = dea.location
	and vac.date = dea.date
WHERE dea.continent is not null




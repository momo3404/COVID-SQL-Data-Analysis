-- Percentage of cases that result in deaths each day in Canada
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS 'Death % in cases' 
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY 1,2

-- Percentage of population that is infected each day
SELECT location, date, new_cases, population, (new_cases/population) * 100 AS '% of population infected today'
FROM PortfolioProject..CovidDeaths$ 
WHERE location = 'Canada'
ORDER BY 1,2

-- Percentage of population that has been infected as the pandemic progresses
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS 'total % of population infected'
FROM PortfolioProject..CovidDeaths$ 
WHERE location = 'Canada'
ORDER BY 1,2

-- Most recent percentage of total population that has been infected
SELECT TOP 1 date, (total_cases/population) * 100 AS '% of Canadians infected with COVID-19'
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY date DESC

-- Recent number of new cases, deaths  in Canada
SELECT TOP 10 PortfolioProject..CovidDeaths$.date, new_cases AS 'cases', new_deaths AS 'deaths'
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Canada'
ORDER BY PortfolioProject..CovidDeaths$.date DESC

-- Finding countries with highest case count 
SELECT location, population, MAX(total_cases) as 'Highest total case count' FROM PortfolioProject..CovidDeaths$
WHERE location != 'World' AND continent is not null
GROUP BY location, population
ORDER BY MAX(total_cases) DESC


-- Finding countrie with highest infection rate
SELECT location, population, MAX(total_cases/population * 100) as 'Highest infection rate' FROM PortfolioProject..CovidDeaths$
WHERE location != 'World' AND continent is not null
GROUP BY location, population
ORDER BY MAX(total_cases/population * 100) DESC

-- Finding countries with highest death rate
SELECT location, population, MAX(cast(total_deaths as int)/population * 100) as 'Highest death rate' FROM PortfolioProject..CovidDeaths$
WHERE location != 'World' AND continent is not null
GROUP BY location, population
ORDER BY MAX(cast(total_deaths as int)/population * 100) DESC

-- Finding which continents have the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as 'Total deaths'
FROM PortfolioProject..CovidDeaths$
WHERE location != 'World' AND continent is not null
GROUP BY continent
ORDER BY MAX(cast(total_deaths as int)) DESC


-- Looking at vaccinations numbers throughout the pandemic in Canada
SELECT date, new_vaccinations, total_vaccinations FROM PortfolioProject..CovidVaccinations
WHERE location = 'Canada' AND total_vaccinations is not NULL 
ORDER BY date

-- Percentage of Canadians vaccinated
SELECT date, total_vaccinations, (total_vaccinations/population)*100 as 'Percent vaccinated' FROM PortfolioProject..CovidVaccinations
WHERE location = 'Canada' AND total_vaccinations is not NULL 
ORDER BY date

-- Percentage of Canadians with booster vaccinations
SELECT date, total_boosters, (total_boosters/population)* 100 as 'Percent boosted' FROM PortfolioProject..CovidVaccinations
WHERE location = 'Canada' AND total_boosters is not null
ORDER BY date

-- How many people have received a vaccine in Canada each day
SELECT det.location, det.date, vac.new_vaccinations FROM PortfolioProject..CovidDeaths$ det
INNER JOIN PortfolioProject..CovidVaccinations vac
ON det.location = vac.location AND det.date = vac.date
WHERE det.continent is not NULL AND det.location = 'Canada'
ORDER BY 1,2,3

-- Looking at rising number of Canadians vaccinated throughout the pandemic
SELECT det.location, det.date, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by det.location ORDER BY det.location, det.date) AS Total_Vaccinated
FROM PortfolioProject..CovidDeaths$ det
INNER JOIN PortfolioProject..CovidVaccinations vac
ON det.location = vac.location AND det.date = vac.date
WHERE det.continent is not NULL AND det.location = 'Canada'
ORDER BY 1,2,3;


-- Using a CTE to calculate percentage of Canadians who have been vaccinated throughout the pandemic 
With TotalVaccinated (location, date, population, new_vaccinations, Total_Vaccinated)
as 
	(SELECT det.location, det.date, det.population, vac.new_vaccinations, 
	SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by det.location ORDER BY det.location, det.date) AS Total_Vaccinated
	FROM PortfolioProject..CovidDeaths$ det
	INNER JOIN PortfolioProject..CovidVaccinations vac
	ON det.location = vac.location AND det.date = vac.date
	WHERE det.continent is not NULL AND det.location = 'Canada')
SELECT (Total_Vaccinated/population)*100 AS 'Percentage of Population Vaccinated'
FROM TotalVaccinated



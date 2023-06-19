
-- CovidDeaths

Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Selecting Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Germany%'
order by 1,2

-- Looking at the total cases Vs Population
-- shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%Germany%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PopulationInfectedPercentage desc

-- Showing Countries with highest Death Count per Population

Select Location, Max(total_Deaths) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathsCount desc

-- Showing conintents with the highest death count per population 

Select location, Max(total_Deaths) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where continent is null
and location like '%world%'
or location like '%Europe%'
or location like 'North America'
or location like 'Asia'
or location like 'South America'
or location like 'Afica'
or location like 'Oceania'
or location like 'International'
Group by location
order by TotalDeathsCount desc

-- Global Numbers

Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Covid Vaccinations
-- Looking at Total Population vs Vaccinations

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (Partition by death.location Order by death.location, death.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths death
     On death.location = vac.location
     and death.date = vac.date
Where death.continent is not null
Order by 2,3

-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (Partition by death.location Order by death.location, death.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths death
     On death.location = vac.location
     and death.date = vac.date
Where death.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac 

-- Temp Table

Drop Table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PrecentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (Partition by death.location Order by death.location, death.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths death
     On death.location = vac.location
     and death.date = vac.date
--Where death.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PrecentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PrecentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) Over (Partition by death.location Order by death.location, death.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths death
     On death.location = vac.location
     and death.date = vac.date
Where death.continent is not null
--Order by 2,3

Select *
From PrecentPopulationVaccinated


SELECT * FROM CovidDeaths; 

--LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT location,DATE,TOTAL_CASES,TOTAL_DEATHS,(TOTAL_DEATHS/total_cases)*100 AS "DEATH PERCENTAGE"
FROM CovidDeaths;

-- LOOKING AT TOTAL CASES VS POPULATION
--SHOWS PERCENTAGE OF POPULATION GOT COVID

SELECT LOCATION,DATE,TOTAL_CASES,POPULATION,(TOTAL_CASES/POPULATION) *100 AS "COVID PERCENTAGE"
FROM CovidDeaths;


-- HIGHEST INFECTION RATE AS COMPARED TO POPULATION

SELECT location, population, MAX(TOTAL_CASES), MAX(TOTAL_CASES/POPULATION)*100 AS "POPULATION INFECTED PERCENTAGE"
FROM CovidDeaths
GROUP BY location,population
ORDER BY "POPULATION INFECTED PERCENTAGE" DESC;



 -- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

 SELECT LOCATION,POPULATION,MAX(cast(TOTAL_DEATHS as int)) AS "HIGHEST DEATH COUNT" 
 FROM CovidDeaths
 WHERE continent is NOT NULL
 GROUP BY location,population
 ORDER BY [HIGHEST DEATH COUNT] DESC;


  -- SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

 SELECT continent,MAX(cast(TOTAL_DEATHS as int)) AS "HIGHEST DEATH COUNT" 
 FROM CovidDeaths
 WHERE continent is NOT NULL
 GROUP BY continent
 ORDER BY [HIGHEST DEATH COUNT] DESC;


 -- GLOBAL NUMBERS

SELECT location,DATE,SUM(NEW_CASES) AS "TOTAL CASES",SUM(CAST(NEW_DEATHS AS INT)) AS "TOTAL DEATHS",(SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100) AS "DEATH PERCENTAGE"
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, DATE
ORDER BY 2,3



--LOOKING AT TOTAL POPULATION AND VACCINATIONS
--USE CTE
with popvsvac(Location,Continent,Date,Population,Vaccination,RollingPeopleVaccinated)
AS
(
SELECT DEATH.location,DEATH.continent,DEATH.date,death.population,VACN.new_vaccinations,SUM(CAST(VACN.new_vaccinations AS INT)) OVER(PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) AS ROLLING_PEOPLE_VACCINATED
FROM CovidDeaths DEATH JOIN 
CovidVaccinations VACN
ON DEATH.location=VACN.location AND DEATH.DATE=VACN.date
WHERE DEATH.continent IS NOT NULL
--ORDER BY 1,3
)

select *,(RollingPeopleVaccinated/Population)*100  as "Vaccinattion Percentage"
from popvsvac



--TEMP TABLE
drop table if exists #PopulationVaccinatedPercentage
create table #PopulationVaccinatedPercentage
(
	Location nvarchar(255),
	Continent nvarchar(255), 
	Date datetime,
	Population numeric,
	Vaccination numeric,
	RollingPeopleVaccinated numeric
)


insert into #PopulationVaccinatedPercentage
SELECT DEATH.location,DEATH.continent,DEATH.date,death.population,VACN.new_vaccinations,SUM(CAST(VACN.new_vaccinations AS INT)) OVER(PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) AS ROLLING_PEOPLE_VACCINATED
FROM CovidDeaths DEATH JOIN 
CovidVaccinations VACN
ON DEATH.location=VACN.location AND DEATH.DATE=VACN.date
--WHERE DEATH.continent IS NOT NULL


select *,(RollingPeopleVaccinated/Population)*100  as "Vaccinattion Percentage"
from #PopulationVaccinatedPercentage



--CREATE VIEW TO STORE DATA FOR VISUALIZATAION

CREATE VIEW PERCENTPOPULATIONVACCINATED
AS
SELECT DEATH.location,DEATH.continent,DEATH.date,death.population,VACN.new_vaccinations,SUM(CAST(VACN.new_vaccinations AS INT)) OVER(PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) AS ROLLING_PEOPLE_VACCINATED
FROM CovidDeaths DEATH JOIN 
CovidVaccinations VACN
ON DEATH.location=VACN.location AND DEATH.DATE=VACN.date
WHERE DEATH.continent IS NOT NULL

-- DISPLAY VIEW

SELECT *
FROM PERCENTPOPULATIONVACCINATED



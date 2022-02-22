select * 
from covid_death
order by 3,4

select * 
from covid_vaccine
---where continent is null
order by 3,4

---- Updating Null values in Continent

select a.iso_code,a.continent,b.iso_code,b.location,isnull(a.continent,b.location)
from covid_death a
join covid_death b
on a.iso_code = b.iso_code
where a.continent is null

---Updating in covid_deaths
update a
set Continent = isnull(a.continent,b.location)
from covid_death a
join covid_death b
on a.iso_code = b.iso_code
where a.continent is null

---Updating in covid_vaccines
update a
set Continent = isnull(a.continent,b.location)
from covid_vaccine a
join covid_vaccine b
on a.iso_code = b.iso_code
where a.continent is null

---Deleting Continents and locations which match in both column
delete
from covid_death
where continent = location

delete
from covid_vaccine
where continent = location

---

select distinct(location),continent
from covid_death
---where continent like '%south%'
group by continent,location
order by continent

---Total Death percentage in 2021-India

select month(date) as month, sum(total_cases) as Total_cases,sum(cast(total_deaths as int)) as Total_deaths,round(sum(cast(total_deaths as int)) / sum(total_cases) *100, 3) as Total_Death_percentage
from covid_death
where location = 'India' and date like '%2021%'
group by month(date)
order by 1

--Total new Death percentage in 2021-India

select month(date) as Month,sum(new_cases) as Total_new_cases,sum(cast(new_deaths as int)) as Total_new_deaths,round(sum(cast(new_deaths as int)) / sum(new_cases) *100, 3) as New_Death_percentage
from new_project..covid_death
where location = 'India' and date like '%2021%'
group by month(date),location,continent
order by 1

---Average cases and deaths in 2021- World

select continent,location, round(avg(total_cases),1) as Average_cases,avg(cast(total_deaths as int)) as Average_deaths
from new_project..covid_death
---where location = 'India' and 
where date like '%2021%'
group by continent,location
order by 1

---Average new cases and deaths in India - 2021

select location,month(date) as Month, round(avg(total_cases),1) as Average_cases,avg(cast(total_deaths as int)) as Average_deaths
from new_project..covid_death
where location = 'India' and date like '%2021%'
group by month(date),location
order by 1

---Total deaths in a year in world by covid

select year(date) as Year, round(sum(total_cases),1) as Total_cases,sum(cast(total_deaths as bigint)) as Total_deaths
from new_project..covid_death
---where location = 'India' and 
---where date like '%2021%'
group by year(date)
order by 1

------Total deaths in a year in india by covid

select year(date) as Year, round(sum(total_cases),1) as Total_cases,sum(cast(total_deaths as bigint)) as Total_deaths
from new_project..covid_death
where location = 'India'
group by year(date)
order by 1

--Affected population percentage in 2021

select location,population,max(total_cases) as Total_cases,max(round(((total_cases/population)*100),4))as population_percentage_affected
,dense_rank() over(order by population desc) as Rank
from new_project..covid_death 
where  date like '%2021%'
group by location,population
order by population desc

--- Maximum deaths in a location

select location,max(cast(total_deaths as int)) as Total_death_count
from covid_death
where date like '%2021%'
group by location
order by Total_death_count desc

---By continent in 2021

select continent,sum(cast(total_deaths as bigint)) as Total_death_count
from covid_death 
where  date like '%2021%' 
group by continent
order by Total_death_count desc

---global numbers in 2021

select month(date) as month,continent, sum(new_cases) as Total_new_cases,sum(cast(new_deaths as int)) as Total_new_deaths,round(sum(cast(new_deaths as int)) / sum(new_cases) *100, 3) as Death_percentage
from new_project..covid_death
where continent is not null
group by month(date),continent
order by 1

---Joining covid death and covid vaccine tables
select *
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date 
  


---Cumulative sum of vaccination

select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(convert(bigint,vaccine.new_vaccinations)) OVER(partition by death.location order by death.location,death.date) as cumulative_sum_of_vaccines
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
order by 2,3

---Cumulative sum of vaccination from the date of vaccination started in respective countries

select sub.*
from (select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(convert(bigint,vaccine.new_vaccinations)) OVER(partition by death.location order by death.location,death.date) as cumulative_sum_of_vaccines
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
)sub
where sub.new_vaccinations is not null
order by sub.continent


---Cumulative sum of vaccination from the date of vaccination started in India

select sub.*
from (select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(convert(bigint,vaccine.new_vaccinations)) OVER(partition by death.location order by death.location,death.date) as cumulative_sum_of_vaccines
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
)sub
where sub.new_vaccinations is not null and sub.location = 'India'

----Comparing new cases with people fully vaccinated in 2021 - India

select sub.location,
       sub.month as Month,
       sum(sub.new_cases) as New_cases,
	   sum(cast(sub.people_fully_vaccinated as bigint)) as People_fully_vaccinated
from (
select death.location,month(death.date) as month,death.population,death.new_cases,death.total_cases,
vaccine.new_vaccinations,vaccine.people_fully_vaccinated
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
)sub
where sub.new_vaccinations is not null and sub.location like '%india%'
group by sub.month,sub.location



with covid_data (continent,location,date,population,new_vaccinations,cumulative_sum_of_vaccines)
as
(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(convert(bigint,vaccine.new_vaccinations)) OVER(partition by death.location order by death.location,death.date) as cumulative_sum_of_vaccines
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
--order by 2,3
)
select *,round((cumulative_sum_of_vaccines/population)*100,4) percentage
from covid_data

---Creating a table 

drop table if exists covid_data_percent 
create table covid_data_percent 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_sum_of_vaccines numeric
)
insert into covid_data_percent 
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(convert(bigint,vaccine.new_vaccinations)) OVER(partition by death.location order by death.location,death.date) as cumulative_sum_of_vaccines
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
--order by 2,3

select *,round((cumulative_sum_of_vaccines/population)*100,4) percentage
from covid_data_percent 

---creating view

drop view if exists covid_data_percent_view

create view covid_data_percent_view as
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(convert(bigint,vaccine.new_vaccinations)) OVER(partition by death.location order by death.location,death.date) as cumulative_sum_of_vaccines
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'

---Other factors

select distinct 
       sub.location,
       sub.cardiovasc_death_rate,
	   sub.diabetes_prevalence,
	   sub.handwashing_facilities
from (select death.continent,death.location,month(death.date) as month,death.population,vaccine.new_vaccinations,vaccine.total_vaccinations
,vaccine.handwashing_facilities,vaccine.cardiovasc_death_rate,vaccine.diabetes_prevalence
from new_project..covid_death death
join new_project..covid_vaccine vaccine
   on death.location = vaccine.location
   and death.date = vaccine.date
where death.date like '%2021%'
)sub




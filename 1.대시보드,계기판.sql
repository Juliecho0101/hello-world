/****** SSMS의 SelectTopNRows 명령 스크립트 ******/

/****** FROM 테이블의 날짜 형식이 DATE 인지 DATETIME 인지 주의 ******/
-- 19.07.25 자릿수 조정

declare @date_1y date, @date_1m date, @date_1w date, @date_1d date, @farm_no int 
set @date_1y=convert(date,dateadd(year,-1,getdate()),23)
set @date_1m=convert(date,dateadd(MONTH,-1,getdate()),23)
set @date_1w=convert(date,dateadd(day,-7,getdate()),23)
set @date_1d= convert(date,dateadd(day,-1,getdate()),23)
set @farm_no = 38

--------------------------------------------#계기판
--#착유두수/일 
select 
(sum(case when DATE >= @date_1y then 1 else null end)/count(distinct(case when DATE >= @date_1y then date else null end))) as  착유두수_1년
,(sum(case when DATE >= @date_1m then 1 else null end)/count(distinct(case when DATE >= @date_1m then date else null end))) as 착유두수_1달
,(sum(case when DATE >= @date_1w then 1 else null end)/count(distinct(case when DATE >= @date_1w then date else null end))) as 착유두수_1주
,(sum(case when DATE = @date_1d then 1 else null end)/count(distinct(case when DATE = @date_1d then date else null end))) as 착유두수_1일
FROM [DAIRY_ICT_MANAGEMENT].[T4C].[DAYPRODUCTION]
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 


--#유량/일 
select 
convert(int,(sum (MILK_DAY_PRODUCTION)/count(distinct( DATE)))) as 일유량_1년
,convert(int,(sum(case when DATE >= @date_1m then MILK_DAY_PRODUCTION else null end)/count(distinct(case when DATE >= @date_1m then date else null end)))) as 일유량_1달
,convert(int,(sum(case when DATE >= @date_1w then MILK_DAY_PRODUCTION else null end)/count(distinct(case when DATE >= @date_1w then date else null end)))) as 일유량_1주
,convert(int,(sum(case when DATE = @date_1d then MILK_DAY_PRODUCTION else null end)/count(distinct(case when DATE = @date_1d then date else null end)))) as 일유량_1일
FROM [DAIRY_ICT_MANAGEMENT].[T4C].[DAYPRODUCTION]
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 

--#유량/일/두
select 
convert(numeric(7,1),(sum (case when DATE >= @date_1y then MILK_DAY_PRODUCTION else null end)/sum(case when DATE >= @date_1y then 1 else null end)))  as 두당유량_1년
,convert(numeric(7,1),(sum(case when DATE >= @date_1m then MILK_DAY_PRODUCTION else null end)/sum(case when DATE >= @date_1m then 1 else null end))) as 두당유량_1달
,convert(numeric(7,1),(sum(case when DATE >= @date_1w then MILK_DAY_PRODUCTION else null end)/sum(case when DATE >= @date_1w then 1 else null end))) as 두당유량_1주
,convert(numeric(7,1),(sum(case when DATE = @date_1d then MILK_DAY_PRODUCTION else null end)/sum(case when DATE >= @date_1d then 1 else null end))) as 두당유량_1일
FROM [DAIRY_ICT_MANAGEMENT].[T4C].[DAYPRODUCTION]
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 

--#반추
select 
(sum(case when RUMINATION_DATETIME >= @date_1y then RUMINATION_MINUTES else null end)/sum(case when RUMINATION_DATETIME >= @date_1y  then 1 else null end)) as 반추_1년
,(sum(case when RUMINATION_DATETIME >= @date_1m then RUMINATION_MINUTES else null end)/sum(case when RUMINATION_DATETIME >= @date_1m  then 1 else null end)) as 반추_1달
,(sum(case when RUMINATION_DATETIME >= @date_1w then RUMINATION_MINUTES else null end)/sum(case when RUMINATION_DATETIME >= @date_1w  then 1 else null end)) as 반추_1주
,(sum(case when convert(date,RUMINATION_DATETIME,23) = @date_1d then RUMINATION_MINUTES else null end)/sum(case when convert(date,RUMINATION_DATETIME,23) = @date_1d   then 1 else null end)) as 반추_1일
from [T4C].[RUMINATION]
where FARM_NO = @farm_no and  RUMINATION_DATETIME > = @date_1y and  convert(date, RUMINATION_DATETIME,23) <= @date_1d 


--#체세포
-- 쿼리 수정 19.07.25 (SCC is not null 인 것만 평균)
select 
(sum (case when DATE >= @date_1y then SCC else null end)/sum(case when DATE >= @date_1y  and scc is not null then 1 else null end))  as 체세포_1년
,(sum(case when DATE >= @date_1m then SCC else null end)/sum(case when DATE >= @date_1m and scc is not null then 1 else null end)) as 체세포_1달
,(sum(case when DATE >= @date_1w then SCC else null end)/sum(case when DATE >= @date_1w and scc is not null  then 1 else null end)) as 체세포_1주
,(sum(case when DATE = @date_1d then SCC else null end)/sum(case when DATE >= @date_1d and scc is not null then 1 else null end)) as 체세포_1일
FROM [DAIRY_ICT_MANAGEMENT].[T4C].[DAYPRODUCTION]
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 

--#유지방 
--쿼리수정 19.07.24 

select 
convert(numeric(10,2), (sum (case when DATE >= @date_1y then fat else null end)/sum(case when DATE >= @date_1y then MILK_DAY_PRODUCTION else null end))*100)  as 유지방_1년
,convert(numeric(10,2), (sum (case when DATE >= @date_1m then fat else null end)/sum(case when DATE >= @date_1m then MILK_DAY_PRODUCTION else null end))*100)   as 유지방_1달
,convert(numeric(10,2), (sum (case when DATE >= @date_1w then fat else null end)/sum(case when DATE >= @date_1w then MILK_DAY_PRODUCTION else null end))*100)   as 유지방_1주
,convert(numeric(10,2), (sum (case when DATE = @date_1d then fat else null end)/sum(case when DATE = @date_1d then MILK_DAY_PRODUCTION else null end))*100)  as 유지방_1일
from  ( select 
		      FARM_NO
			  ,LIFE_NUMBER
			  ,DATE
			  ,MILK_DAY_PRODUCTION
			  ,FAT_PERCENTAGE
			  ,MILK_DAY_PRODUCTION*FAT_PERCENTAGE/100 as fat 
			  from DAIRY_ICT_MANAGEMENT.T4C.DAYPRODUCTION
			  ) as a 
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 

--#유단백
--쿼리수정 19.07.24 

select 
 convert(numeric(7,2),(sum (case when DATE >= @date_1y then protein else null end)/sum(case when DATE >= @date_1y then MILK_DAY_PRODUCTION else null end))*100)  as 유단백_1년
,convert(numeric(7,2), (sum (case when DATE >= @date_1m then protein else null end)/sum(case when DATE >= @date_1m then MILK_DAY_PRODUCTION else null end))*100)   as 유단백_1달
,convert(numeric(7,2), (sum (case when DATE >= @date_1w then protein else null end)/sum(case when DATE >= @date_1w then MILK_DAY_PRODUCTION else null end))*100)    as 유단백_1주
,convert(numeric(7,2), (sum (case when DATE = @date_1d then protein else null end)/sum(case when DATE = @date_1d then MILK_DAY_PRODUCTION else null end))*100)   as 유단백_1일
from  ( select 
		      FARM_NO
			  ,LIFE_NUMBER
			  ,DATE
			  ,MILK_DAY_PRODUCTION
			  ,PROTEIN_PERCENTAGE
			  ,MILK_DAY_PRODUCTION*PROTEIN_PERCENTAGE/100 as protein 
			  from DAIRY_ICT_MANAGEMENT.T4C.DAYPRODUCTION
			  ) as a 
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 

--#착유횟수
select 
convert(numeric(7,1), (sum (case when DATE >= @date_1y then MDPMILKINGS else null end)/sum(case when DATE >= @date_1y then 1. else null end)))  as 착유횟수_1년
,convert(numeric(7,1), (sum (case when DATE >= @date_1m then MDPMILKINGS else null end)/sum(case when DATE >= @date_1m then 1. else null end)))  as 착유횟수_1달
,convert(numeric(7,1), (sum (case when DATE >= @date_1w then MDPMILKINGS else null end)/sum(case when DATE >= @date_1w then 1. else null end)))  as 착유횟수_1주
,convert(numeric(7,1), (sum(case when DATE = @date_1d then MDPMILKINGS else null end)/sum(case when DATE >= @date_1d then 1. else null end))) as 착유횟수_1일
from [DAIRY_ICT_MANAGEMENT].[T4C].[DAYPRODUCTIONSQUALITY]
where FARM_NO = @farm_no and DATE > = @date_1y and DATE <= @date_1d 


declare @date_s date, @date_f date,  @farm_no int 
set @date_s= '2019-07-10'
set @date_f= '2019-07-25'
set @farm_no = 38

-- 착유우군의 특성 쿼리는 전체 수정함
-- 로봇성능의 착유시간, 여유시간~~은 비율로만 표시


--#우군생산성 > 일별 생산성 > 생산성 요약  --기존 관리자 대시보드의 농장별 요약과 거의 동일함 (SCC 개체수 부분만 수정하였음.)
-- 2019.07.24 fat, protein, lactose 계산방법 변경( 단순 평균에서 유량*지방%)  

select 
			a.FARM_NO
			,convert(date, a.DATE,112) as date
			,convert(int,sum(MILK_DAY_PRODUCTION)) as 총유량
			--,FPCM
			,convert(numeric(7,1), avg(MILK_DAY_PRODUCTION)) as 두당유량 
			,count(MILK_DAY_PRODUCTION) as 착유두수
			,convert(numeric(7,2),sum(a.fat)/sum(MILK_DAY_PRODUCTION)*100) as 유지방
			,convert(numeric(7,2),sum(a.protein)/sum(MILK_DAY_PRODUCTION)*100) as 유단백
			,convert(numeric(7,2),sum(a.lactose)/sum(MILK_DAY_PRODUCTION)*100) as 유당
			,convert(numeric(7,2),sum(a.fat)/sum(a.protein)) as 'F/P ratio'
			,avg(a.SCC) as 'SCC 평균' 
			,sum(case when a.SCC < 200 then 1 else 0 end) as 'SCC 20만 미만 개체수'
			,sum(case when a.SCC >= 200 and a.SCC<350 then 1 else 0 end) as 'SCC 20만-35만' 
			,sum(case when a.SCC >= 350 and a.SCC <500 then 1 else 0 end) as 'SCC 35만-50만'
			,sum(case when a.SCC >= 500 then 1 else 0 end) as 'SCC 50만 이상 개체수'  
			,avg(b.RUMINATION_MINUTES) as 반추
			,convert(numeric(7,2), avg(c.INTAKE)/1000.) as 사료급이량
			,convert(numeric(7,2), avg(c.REST)/1000.) as 사료잔량
			,convert(int, avg(a.AVERAGE_WEIGHT)) as 체중
			,convert(numeric(7,1), avg(d.MDPMILKINGS*1.)) as 착유
			,convert(numeric(7,1), avg(d.MDPREFUSALS*1.)) as 거절
			,convert(numeric(7,1), avg(d.MDPFAILURES*1.)) as 실패 
from (select *
			,MILK_DAY_PRODUCTION*FAT_PERCENTAGE/100 as fat
			,MILK_DAY_PRODUCTION*PROTEIN_PERCENTAGE/100 as protein
			,MILK_DAY_PRODUCTION*LACTOSE_PERCENTAGE/100 as lactose 
			 from [T4C].[DAYPRODUCTION] 
			 )as a 
left outer join [T4C].[RUMINATION] as b
					on a.FARM_NO=b.FARM_NO and a.LIFE_NUMBER = b.LIFE_NUMBER and a.DATE = convert(date,b.RUMINATION_DATETIME,23) 
left outer join 
					(select 
					FARM_NO
					,LIFE_NUMBER
					,FEED_DATE 
					,sum(TOTAL) as TOTAL 
					,sum(REST) as REST
					,sum(INTAKE)as INTAKE 
					from [T4C].[FEED_AMOUNT_NEW] 
					where FARM_NO = @farm_no and FEED_DATE between @date_s and @date_f
					group by FARM_NO,LIFE_NUMBER, FEED_DATE
					) as c 
					on a.FARM_NO=c.FARM_NO and a.LIFE_NUMBER = c.LIFE_NUMBER and a.DATE = c.FEED_DATE
left outer join [T4C].[DAYPRODUCTIONSQUALITY] as d 
					 on a.FARM_NO=d.FARM_NO and a.LIFE_NUMBER=d.LIFE_NUMBER and a.DATE =d.DATE 
where a.FARM_NO = @farm_no and a.DATE >= @date_s and a.DATE <= @date_f
group by a.FARM_NO, a.DATE 
order by DATE desc 



--#우군생산성 > 일별 생산성 > 착유우군 특성   -- 관리자 대시보드와 동일한 항목 
declare @date_s date, @date_f date,  @farm_no int 
set @date_s= '2019-05-10'
set @date_f= '2019-07-30'
set @farm_no =38


select
convert(date, t1.DATE,112) as 일자
,milk_cnt as 총착유두수
, convert(numeric(7,1),avg_lac) as 평균산차
, avg_dim as 평균착유일령
,t2.calving_cnt as 분만개체수
,t2.calv_interval as 분만간격
,t2.calv_mon1 as '1산차분만월령'
,t3.ins_cnt as 수정개체수
from 
		(select 
		DATE, count(*) as milk_cnt, avg(lac_number*1.) as avg_lac, avg(DAY_IN_MILK) as avg_dim
		from t4c.DAYPRODUCTION where FARM_NO=@farm_no and DATE between @date_s and @date_f group by DATE
		) as t1
left outer join 
			(select 
			farm_no, calving_date, count(*) as calving_cnt
			, avg(case when lac_number>1 then interval else null end ) as calv_interval  -- 2산차이상 분만간격
			, avg(case when lac_number=1 then interval else null end )/30 as calv_mon1 -- 1산차 분만시월령
			from 
				(select 
				farm_no
				, CALVING_DATE
				, LAC_NUMBER
				,datediff(dd, lead(CALVING_DATE, 1, null ) over (partition by farm_no, life_number order by calving_date desc ),CALVING_DATE ) as interval
				from t4c.CALVING where FARM_NO=@farm_no
				) a group by farm_no, calving_date
			) t2 on t1.date=t2.CALVING_DATE 
left outer join
			(select farm_no, INSEMINATION_DATE, count(*) as ins_cnt
			from t4c.INSEMINATION  where FARM_NO=@farm_no group by farm_no, INSEMINATION_DATE
			) t3 on  t1.date=t3.INSEMINATION_DATE 
order by date
		

		


--#우군생산성 > 일별 생산성 > 로봇성능
declare @date_s date, @date_f date,  @farm_no int 
set @date_s= '2019-07-10'
set @date_f= '2019-07-30'
set @farm_no =38


select 
DEVICE_ADDRESS as 로봇주소
,convert(date,ROBOT_DATE,23) as 로봇날짜
,NUMBER_OF_COWS as 개체수 
,MILKING_PER_COW as 개체당_착유횟수
,convert(int, TOTAL_MILK_WITH_FAILED) as 총착유량_실패포함 
,TOTAL_MILK_SEPARATED as 분리된유량
,MILK_PER_COW as 개체당유량
,MILK_PER_MILK as 착유당유량 
,NUMBER_OF_MILKINGS as 착유횟수
,NUMBER_OF_FAILURES as 실패횟수
,NUMBER_OF_REFUSALS as 거절횟수
,convert(numeric(7,1), TIME_MILKING/86400.*100) as 착유시간비율
,convert(numeric(7,1), TIME_FREE/86400.*100) as 여유시간비율
,convert(numeric(7,1), TIME_CLEANING/86400.*100) as 세척시간비율
,convert(numeric(7,1), TIME_REFUSING/86400.*100) as 거절시간비율
--,PERC_FEE as 여유시간비율 ----------------------------------------여유시간비율이맞음? --> 응 맞아(황진아)
,NUMBER_OF_COW_FEED as 사료급이개체수
,NUMBER_OF_FEED_VISITS as 사료방문횟수
,convert(int, FEED1) as 사료1
,convert(int, FEED2) as 사료2
,convert(int, FEED3) as 사료3
,convert(int, FEED4) as 사료4
,convert(int, FEED5) as 사료5
from T4C.ROBOTPERFORMANCE_NEW
where FARM_NO = @farm_no and ROBOT_DATE >= @date_s and ROBOT_DATE <= @date_f
ORDER BY ROBOT_DATE, DEVICE_ADDRESS

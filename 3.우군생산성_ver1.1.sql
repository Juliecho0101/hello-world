
declare @date_s date, @date_f date,  @farm_no int 
set @date_s= '2019-07-10'
set @date_f= '2019-07-25'
set @farm_no = 38

-- �����챺�� Ư�� ������ ��ü ������
-- �κ������� �����ð�, �����ð�~~�� �����θ� ǥ��


--#�챺���꼺 > �Ϻ� ���꼺 > ���꼺 ���  --���� ������ ��ú����� ���庰 ���� ���� ������ (SCC ��ü�� �κи� �����Ͽ���.)
-- 2019.07.24 fat, protein, lactose ����� ����( �ܼ� ��տ��� ����*����%)  

select 
			a.FARM_NO
			,convert(date, a.DATE,112) as date
			,convert(int,sum(MILK_DAY_PRODUCTION)) as ������
			--,FPCM
			,convert(numeric(7,1), avg(MILK_DAY_PRODUCTION)) as �δ����� 
			,count(MILK_DAY_PRODUCTION) as �����μ�
			,convert(numeric(7,2),sum(a.fat)/sum(MILK_DAY_PRODUCTION)*100) as ������
			,convert(numeric(7,2),sum(a.protein)/sum(MILK_DAY_PRODUCTION)*100) as ���ܹ�
			,convert(numeric(7,2),sum(a.lactose)/sum(MILK_DAY_PRODUCTION)*100) as ����
			,convert(numeric(7,2),sum(a.fat)/sum(a.protein)) as 'F/P ratio'
			,avg(a.SCC) as 'SCC ���' 
			,sum(case when a.SCC < 200 then 1 else 0 end) as 'SCC 20�� �̸� ��ü��'
			,sum(case when a.SCC >= 200 and a.SCC<350 then 1 else 0 end) as 'SCC 20��-35��' 
			,sum(case when a.SCC >= 350 and a.SCC <500 then 1 else 0 end) as 'SCC 35��-50��'
			,sum(case when a.SCC >= 500 then 1 else 0 end) as 'SCC 50�� �̻� ��ü��'  
			,avg(b.RUMINATION_MINUTES) as ����
			,convert(numeric(7,2), avg(c.INTAKE)/1000.) as �����̷�
			,convert(numeric(7,2), avg(c.REST)/1000.) as ����ܷ�
			,convert(int, avg(a.AVERAGE_WEIGHT)) as ü��
			,convert(numeric(7,1), avg(d.MDPMILKINGS*1.)) as ����
			,convert(numeric(7,1), avg(d.MDPREFUSALS*1.)) as ����
			,convert(numeric(7,1), avg(d.MDPFAILURES*1.)) as ���� 
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



--#�챺���꼺 > �Ϻ� ���꼺 > �����챺 Ư��   -- ������ ��ú���� ������ �׸� 
declare @date_s date, @date_f date,  @farm_no int 
set @date_s= '2019-05-10'
set @date_f= '2019-07-30'
set @farm_no =38


select
convert(date, t1.DATE,112) as ����
,milk_cnt as �������μ�
, convert(numeric(7,1),avg_lac) as ��ջ���
, avg_dim as ��������Ϸ�
,t2.calving_cnt as �и���ü��
,t2.calv_interval as �и�����
,t2.calv_mon1 as '1�����и�����'
,t3.ins_cnt as ������ü��
from 
		(select 
		DATE, count(*) as milk_cnt, avg(lac_number*1.) as avg_lac, avg(DAY_IN_MILK) as avg_dim
		from t4c.DAYPRODUCTION where FARM_NO=@farm_no and DATE between @date_s and @date_f group by DATE
		) as t1
left outer join 
			(select 
			farm_no, calving_date, count(*) as calving_cnt
			, avg(case when lac_number>1 then interval else null end ) as calv_interval  -- 2�����̻� �и�����
			, avg(case when lac_number=1 then interval else null end )/30 as calv_mon1 -- 1���� �и��ÿ���
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
		

		


--#�챺���꼺 > �Ϻ� ���꼺 > �κ�����
declare @date_s date, @date_f date,  @farm_no int 
set @date_s= '2019-07-10'
set @date_f= '2019-07-30'
set @farm_no =38


select 
DEVICE_ADDRESS as �κ��ּ�
,convert(date,ROBOT_DATE,23) as �κ���¥
,NUMBER_OF_COWS as ��ü�� 
,MILKING_PER_COW as ��ü��_����Ƚ��
,convert(int, TOTAL_MILK_WITH_FAILED) as ��������_�������� 
,TOTAL_MILK_SEPARATED as �и�������
,MILK_PER_COW as ��ü������
,MILK_PER_MILK as ���������� 
,NUMBER_OF_MILKINGS as ����Ƚ��
,NUMBER_OF_FAILURES as ����Ƚ��
,NUMBER_OF_REFUSALS as ����Ƚ��
,convert(numeric(7,1), TIME_MILKING/86400.*100) as �����ð�����
,convert(numeric(7,1), TIME_FREE/86400.*100) as �����ð�����
,convert(numeric(7,1), TIME_CLEANING/86400.*100) as ��ô�ð�����
,convert(numeric(7,1), TIME_REFUSING/86400.*100) as �����ð�����
--,PERC_FEE as �����ð����� ----------------------------------------�����ð������̸���? --> �� �¾�(Ȳ����)
,NUMBER_OF_COW_FEED as �����̰�ü��
,NUMBER_OF_FEED_VISITS as ���湮Ƚ��
,convert(int, FEED1) as ���1
,convert(int, FEED2) as ���2
,convert(int, FEED3) as ���3
,convert(int, FEED4) as ���4
,convert(int, FEED5) as ���5
from T4C.ROBOTPERFORMANCE_NEW
where FARM_NO = @farm_no and ROBOT_DATE >= @date_s and ROBOT_DATE <= @date_f
ORDER BY ROBOT_DATE, DEVICE_ADDRESS

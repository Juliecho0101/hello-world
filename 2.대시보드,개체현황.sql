--# 대시보드 > 개체현황
declare @farm_no int 
set @farm_no = 38

-- 쿼리 수정 19.07.25. 간단히 animal 테이블에서만 처리했음

select
t1.name, t3.name, count(*) as cnt
from 
(select
'In Lactation' as status_n,'착유우' as name, '1' order_n
union all select 'Dry Off', '건유우', '2' 
union all select 'Young Stock', '미경산우', '3' ) t1
left outer join  t4c.ANIMAL t2 on t1.status_n=t2.PRODUCT_STATUS_NAME
left outer join 
(select 'pregnant' as status_n,'임신' as name, '1' order_n
union all select 'inseminated', '수정', '2' 
union all select 'open', '공태', '3'
union all select 'open cylic', '공태', '3'
union all select 'never inseminated', '육성', '4' ) t3 on t2.REPRODUCT_STATUS_NAME=t3.status_n
where KEEP=1 and DELETED=0 and ACTIVE=1
and FARM_NO=@farm_no
group by t1.name, t3.name, t1.order_n, t3.order_n
order by t1.order_n, t3.order_n

/*
그래프 ;   미경산우/ 착유우/ 건유우 나눠서

미경산우 :  x 축 D_DAY , y축  DayInPregnance 
착유우 : x축 DayInMilking , y축: DayInPregnance      구분 : PROD_N ='In Lactation'  pregnant , inseminated ,    open/ open cylic
건유우 :  x축  ,y축 : DayInPrenance

-- 원래 쿼리
select 
sum(case when PROD_N = 'In Lactation' and REPROD_N = 'pregnant' then 1 else 0 end) as '착유우_비유_임신'
,sum(case when PROD_N = 'In Lactation' and REPROD_N = 'inseminated' then 1 else 0 end) as '착유우_비유_수정'
,sum(case when PROD_N = 'In Lactation' and ( REPROD_N = 'open' or REPROD_N='open cylic') then 1 else 0 end) as '착유우_비유_공태'
,sum(case when  PROD_N = 'Dry Off' and REPROD_N = 'pregnant' then 1 else 0 end) as '건유우'
,sum(case when PROD_N = 'Young Stock' and REPROD_N  != 'never inseminated' then 1 else 0 end) as '미경산우_수정O' 
,sum(case when PROD_N = 'Young Stock' and REPROD_N  = 'inseminated' then 1 else 0 end) as '미경산우_수정' 
,sum(case when PROD_N = 'Young Stock' and (REPROD_N =  'open' or reprod_n='open cylic') then 1 else 0 end) as '미경산우_공태' 
,sum(case when PROD_N = 'Young Stock' and REPROD_N  = 'pregnant' then 1 else 0 end) as '미경산우_임신' 
,sum(case when PROD_N = 'Young Stock' and REPROD_N ='never inseminated' then 1 else 0 end) as '미경산우_수정X'
from cow_status

*/
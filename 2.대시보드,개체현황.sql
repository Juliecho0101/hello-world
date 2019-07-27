--# ��ú��� > ��ü��Ȳ
declare @farm_no int 
set @farm_no = 38

-- ���� ���� 19.07.25. ������ animal ���̺����� ó������

select
t1.name, t3.name, count(*) as cnt
from 
(select
'In Lactation' as status_n,'������' as name, '1' order_n
union all select 'Dry Off', '������', '2' 
union all select 'Young Stock', '�̰���', '3' ) t1
left outer join  t4c.ANIMAL t2 on t1.status_n=t2.PRODUCT_STATUS_NAME
left outer join 
(select 'pregnant' as status_n,'�ӽ�' as name, '1' order_n
union all select 'inseminated', '����', '2' 
union all select 'open', '����', '3'
union all select 'open cylic', '����', '3'
union all select 'never inseminated', '����', '4' ) t3 on t2.REPRODUCT_STATUS_NAME=t3.status_n
where KEEP=1 and DELETED=0 and ACTIVE=1
and FARM_NO=@farm_no
group by t1.name, t3.name, t1.order_n, t3.order_n
order by t1.order_n, t3.order_n

/*
�׷��� ;   �̰���/ ������/ ������ ������

�̰��� :  x �� D_DAY , y��  DayInPregnance 
������ : x�� DayInMilking , y��: DayInPregnance      ���� : PROD_N ='In Lactation'  pregnant , inseminated ,    open/ open cylic
������ :  x��  ,y�� : DayInPrenance

-- ���� ����
select 
sum(case when PROD_N = 'In Lactation' and REPROD_N = 'pregnant' then 1 else 0 end) as '������_����_�ӽ�'
,sum(case when PROD_N = 'In Lactation' and REPROD_N = 'inseminated' then 1 else 0 end) as '������_����_����'
,sum(case when PROD_N = 'In Lactation' and ( REPROD_N = 'open' or REPROD_N='open cylic') then 1 else 0 end) as '������_����_����'
,sum(case when  PROD_N = 'Dry Off' and REPROD_N = 'pregnant' then 1 else 0 end) as '������'
,sum(case when PROD_N = 'Young Stock' and REPROD_N  != 'never inseminated' then 1 else 0 end) as '�̰���_����O' 
,sum(case when PROD_N = 'Young Stock' and REPROD_N  = 'inseminated' then 1 else 0 end) as '�̰���_����' 
,sum(case when PROD_N = 'Young Stock' and (REPROD_N =  'open' or reprod_n='open cylic') then 1 else 0 end) as '�̰���_����' 
,sum(case when PROD_N = 'Young Stock' and REPROD_N  = 'pregnant' then 1 else 0 end) as '�̰���_�ӽ�' 
,sum(case when PROD_N = 'Young Stock' and REPROD_N ='never inseminated' then 1 else 0 end) as '�̰���_����X'
from cow_status

*/
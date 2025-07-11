/*Запрос вычисляет количество уникальных покупателей, записанных в базе данных магазина*/
select
count (*) as customers_count
from customers;

/*Запрос вычисляет топ-10 продавцов, их суммарную выручку
и количество проведенных сделок, сортировка по убыванию выручки*/
select
concat(e.first_name,' ', e.last_name) as seller,
count(*) as operations,
round(sum(s.quantity * p.price),0) as income
from sales s
left join employees e
on e.employee_id = s.sales_person_id
left join products p
on s.product_id = p.product_id
group by concat(e.first_name,' ', e.last_name)
order by sum(s.quantity * p.price) desc
limit 10;

/*Запрос выводит продавцов, чья средняя выручка за сделку меньше
средней выручки за сделку по всем продавцам, сортировка по выручке по возрастанию*/
select
concat(e.first_name,' ', e.last_name) as seller,
round(avg(s.quantity * p.price),0) as average_income
from sales s
left join employees e
on e.employee_id = s.sales_person_id
left join products p
on s.product_id = p.product_id
group by concat(e.first_name,' ', e.last_name)
having avg(s.quantity * p.price) <
	(
	select
	avg(s.quantity * p.price)
	from sales s
	left join products p
	on s.product_id = p.product_id
	)
order by average_income asc;

/*Запрос выводит суммарную выручку, распределённую по дням недели и селлерам*/
select
concat(e.first_name,' ', e.last_name) as seller,
to_char(s.sale_date, 'day') as day_of_week,
floor(sum(s.quantity * p.price)) as income
from sales s
left join employees e
on e.employee_id = s.sales_person_id
left join products p
on s.product_id = p.product_id
group by to_char(s.sale_date, 'day'), concat(e.first_name,' ', e.last_name), extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller asc;

/*Запрос вычисляет количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+*/
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(*) as age_count
from customers
group by age_category
order by age_category;

/*Запрос считает, какую выручку и сколько уникальных клиентов принесли магазину за каждый месяц*/
select
to_char(sale_date, 'YYYY-MM') as selling_month,
count (distinct customer_id) as total_customers,
floor(sum(s.quantity * p.price)) as income
from sales s
left join products p
on s.product_id = p.product_id
group by to_char(sale_date, 'YYYY-MM')
order by to_char(sale_date, 'YYYY-MM') asc;

/*Запрос выводит покупателей, чья первая покупка была в ходе проведения акций, сортировка по id покупателя*/
with tab as (
select
*,
(s.quantity * p.price) as income,
row_number() over (partition by customer_id order by sale_date asc) as rn
from sales s
left join products p
on s.product_id = p.product_id
)
select
concat(c.first_name,' ', c.last_name) as customer,
tab.sale_date as sale_date,
concat(e.first_name,' ', e.last_name) as seller
from tab 
left join employees e
on e.employee_id = tab.sales_person_id
left join customers c
on c.customer_id = tab.customer_id
where rn = 1 and income = 0
order by tab.customer_id asc;


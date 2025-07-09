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


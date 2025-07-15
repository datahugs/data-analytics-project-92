/*Запрос вычисляет количество уникальных покупателей,
записанных в базе данных магазина*/
select count(*) as customers_count
from customers;
/*Запрос вычисляет топ-10 продавцов, их суммарную выручку
и количество проведенных сделок, сортировка по убыванию выручки*/
select
    concat(
        trim(e.first_name), ' ', trim(e.last_name)
    ) as seller,
    count(*) as operations,
    floor(sum(s.quantity * p.price)) as income
from sales as s
left join employees as e on s.sales_person_id = e.employee_id
left join products as p on s.product_id = p.product_id
group by
    concat(
        trim(e.first_name), ' ', trim(e.last_name)
    )
order by sum(s.quantity * p.price) desc
limit 10;
/*Запрос выводит продавцов, чья средняя выручка за сделку
меньше средней выручки за сделку по всем продавцам,
сортировка по выручке по возрастанию*/
select
    concat(
        trim(e1.first_name), ' ', trim(e1.last_name)
    ) as seller,
    floor(avg(s1.quantity * p1.price)) as average_income
from sales as s1
left join employees as e1 on s1.sales_person_id = e1.employee_id
left join products as p1 on s1.product_id = p1.product_id
group by
    concat(
        trim(e1.first_name), ' ', trim(e1.last_name)
    )
having
    avg(s1.quantity * p1.price) < (
        select avg(s2.quantity * p2.price)
        from sales as s2
        left join products as p2 on s2.product_id = p2.product_id
    )
order by average_income asc;
/*Запрос выводит суммарную выручку, распределённую по дням недели и селлерам*/
select
    concat(e3.first_name, ' ', e3.last_name) as seller,
    to_char(s3.sale_date, 'day') as day_of_week,
    floor(sum(s3.quantity * p3.price)) as income
from sales as s3
left join employees as e3 on s3.sales_person_id = e3.employee_id
left join products as p3 on s3.product_id = p3.product_id
group by
    to_char(s3.sale_date, 'day'),
    concat(e3.first_name, ' ', e3.last_name),
    extract(isodow from s3.sale_date)
order by
    extract(isodow from s3.sale_date), seller asc;
/*Запрос вычисляет количество покупателей в разных возрастных
группах: 16-25, 26-40 и 40+*/
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
/*Запрос считает, какую выручку и сколько уникальных клиентов
принесли магазину за каждый месяц*/
select
    to_char(s4.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s4.customer_id) as total_customers,
    floor(sum(s4.quantity * p4.price)) as income
from sales as s4
left join products as p4 on s4.product_id = p4.product_id
group by to_char(s4.sale_date, 'YYYY-MM')
order by to_char(s4.sale_date, 'YYYY-MM') asc;
/*Запрос выводит покупателей, чья первая покупка была в ходе
проведения акций, сортировка по id покупателя*/
with tab as (
    select
        s5.*,
        (s5.quantity * p5.price) as income,
        row_number() over (
            partition by s5.customer_id
            order by s5.sale_date asc
        ) as rn
    from sales as s5
    left join products as p5 on s5.product_id = p5.product_id
)

select
    customer,
    sale_date,
    seller
from (
    select
        concat(c2.first_name, ' ', c2.last_name) as customer,
        tab.sale_date,
        concat(e5.first_name, ' ', e5.last_name) as seller,
        tab.customer_id
    from tab
    left join employees as e5 on tab.sales_person_id = e5.employee_id
    left join customers as c2 on tab.customer_id = c2.customer_id
    where tab.rn = 1 and tab.income = 0
) as sub
order by tab.customer_id asc;

explain analyze
select
    (
        select product_category
        from (
            select
                p.product_category,
                count(*) as orders_count
            from opt_orders o
            join opt_clients c
                on c.id = o.client_id
            join opt_products p
                on p.product_id = o.product_id
            where c.status = 'active'
              and extract(year from o.order_date) = 2023
            group by p.product_category
        ) category_stats_1
        order by orders_count desc, product_category asc
        limit 1
    ) as most_popular_category,
    (
        select product_category
        from (
            select
                p.product_category,
                count(*) as orders_count
            from opt_orders o
            join opt_clients c
                on c.id = o.client_id
            join opt_products p
                on p.product_id = o.product_id
            where c.status = 'active'
              and extract(year from o.order_date) = 2023
            group by p.product_category
        ) category_stats_2
        order by orders_count asc, product_category asc
        limit 1
    ) as least_popular_category,
    (
        select avg(orders_count)
        from (
            select
                p.product_category,
                count(*) as orders_count
            from opt_orders o
            join opt_clients c
                on c.id = o.client_id
            join opt_products p
                on p.product_id = o.product_id
            where c.status = 'active'
              and extract(year from o.order_date) = 2023
            group by p.product_category
        ) category_stats_3
    ) as avg_orders_per_category;



create index if not exists idx_opt_orders_date_client_product
    on opt_orders(order_date, client_id, product_id);

create index if not exists idx_opt_clients_status_id
    on opt_clients(status, id);

create index if not exists idx_opt_products_product_id_category
    on opt_products(product_id, product_category);

analyze opt_clients;
analyze opt_orders;
analyze opt_products;

explain analyze
with category_stats as (
    select
        p.product_category,
        count(*) as orders_count
    from opt_orders o
    join opt_clients c
        on c.id = o.client_id
    join opt_products p
        on p.product_id = o.product_id
    where c.status = 'active'
      and o.order_date >= date '2023-01-01'
      and o.order_date < date '2024-01-01'
    group by p.product_category
)
select
    (
        select product_category
        from category_stats
        order by orders_count desc, product_category asc
        limit 1
    ) as most_popular_category,
    (
        select product_category
        from category_stats
        order by orders_count asc, product_category asc
        limit 1
    ) as least_popular_category,
    (
        select avg(orders_count)
        from category_stats
    ) as avg_orders_per_category;

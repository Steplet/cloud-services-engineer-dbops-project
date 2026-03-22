ALTER TABLE product
    ADD COLUMN price double precision;

UPDATE product AS p
SET price = pi.price
FROM product_info AS pi
WHERE p.id = pi.product_id;

ALTER TABLE product
    ALTER COLUMN price SET NOT NULL;

DROP TABLE product_info;

ALTER TABLE orders
    ADD COLUMN date_created date;

UPDATE orders AS o
SET date_created = od.date_created
FROM orders_date AS od
WHERE o.id = od.order_id;

UPDATE orders
SET date_created = CURRENT_DATE
WHERE date_created IS NULL;

ALTER TABLE orders
    ALTER COLUMN date_created SET DEFAULT CURRENT_DATE,
    ALTER COLUMN date_created SET NOT NULL;

DROP TABLE orders_date;

ALTER TABLE product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);

ALTER TABLE orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);

ALTER TABLE order_product
    ADD CONSTRAINT order_product_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders (id),
    ADD CONSTRAINT order_product_product_id_fkey FOREIGN KEY (product_id) REFERENCES product (id);

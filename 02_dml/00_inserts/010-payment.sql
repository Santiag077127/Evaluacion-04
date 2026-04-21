INSERT INTO payment_status (status_code, status_name)
VALUES ('PAID', 'Pagado');

INSERT INTO payment_method (method_code, method_name)
VALUES ('CARD', 'Tarjeta');

INSERT INTO payment (sale_id, payment_status_id, payment_method_id, currency_id, payment_reference, amount)
SELECT s.sale_id, ps.payment_status_id, pm.payment_method_id, c.currency_id, 'PAY123', 500000
FROM sale s, payment_status ps, payment_method pm, currency c;
INSERT INTO reservation_status (status_code, status_name)
VALUES ('CONFIRMED', 'Confirmada');

INSERT INTO sale_channel (channel_code, channel_name)
VALUES ('WEB', 'Web');

INSERT INTO reservation (reservation_status_id, sale_channel_id, reservation_code, booked_at)
SELECT rs.reservation_status_id, sc.sale_channel_id, 'RES123', now()
FROM reservation_status rs, sale_channel sc;

INSERT INTO sale (reservation_id, currency_id, sale_code, sold_at)
SELECT r.reservation_id, c.currency_id, 'SALE123', now()
FROM reservation r, currency c;
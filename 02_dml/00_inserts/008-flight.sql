INSERT INTO flight_status (status_code, status_name)
VALUES ('ON_TIME', 'On Time');

INSERT INTO flight (airline_id, aircraft_id, flight_status_id, flight_number, service_date)
SELECT a.airline_id, ac.aircraft_id, fs.flight_status_id, 'AV123', CURRENT_DATE
FROM airline a, aircraft ac, flight_status fs;

INSERT INTO flight_segment (flight_id, origin_airport_id, destination_airport_id, segment_number, scheduled_departure_at, scheduled_arrival_at)
SELECT f.flight_id, ap.airport_id, ap.airport_id, 1, now(), now() + interval '1 hour'
FROM flight f, airport ap LIMIT 1;
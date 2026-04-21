INSERT INTO aircraft_manufacturer (manufacturer_name)
VALUES ('Airbus');

INSERT INTO aircraft_model (aircraft_manufacturer_id, model_code, model_name)
SELECT aircraft_manufacturer_id, 'A320', 'Airbus A320'
FROM aircraft_manufacturer;

INSERT INTO cabin_class (class_code, class_name)
VALUES ('ECO', 'Economy');

INSERT INTO aircraft (airline_id, aircraft_model_id, registration_number, serial_number)
SELECT a.airline_id, am.aircraft_model_id, 'HK1234', 'SN123'
FROM airline a, aircraft_model am;

INSERT INTO aircraft_cabin (aircraft_id, cabin_class_id, cabin_code)
SELECT ac.aircraft_id, cc.cabin_class_id, 'C1'
FROM aircraft ac, cabin_class cc;

INSERT INTO aircraft_seat (aircraft_cabin_id, seat_row_number, seat_column_code)
SELECT aircraft_cabin_id, 1, 'A' FROM aircraft_cabin;
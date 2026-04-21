INSERT INTO airport (address_id, airport_name, iata_code)
SELECT address_id, 'Aeropuerto Benito Salas', 'NVA' FROM address;

INSERT INTO terminal (airport_id, terminal_code)
SELECT airport_id, 'T1' FROM airport;

INSERT INTO boarding_gate (terminal_id, gate_code)
SELECT terminal_id, 'A1' FROM terminal;

INSERT INTO runway (airport_id, runway_code, length_meters)
SELECT airport_id, 'RW1', 2000 FROM airport;
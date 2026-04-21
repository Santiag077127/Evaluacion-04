INSERT INTO airline (home_country_id, airline_code, airline_name, iata_code, icao_code)
SELECT country_id, 'AVI', 'Avianca', 'AV', 'AVA'
FROM country WHERE iso_alpha2='CO';
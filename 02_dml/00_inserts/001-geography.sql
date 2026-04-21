INSERT INTO time_zone (time_zone_name, utc_offset_minutes)
VALUES ('America/Bogota', -300);

INSERT INTO continent (continent_code, continent_name)
VALUES ('SA', 'South America');

INSERT INTO country (continent_id, iso_alpha2, iso_alpha3, country_name)
SELECT continent_id, 'CO', 'COL', 'Colombia' FROM continent WHERE continent_code='SA';

INSERT INTO state_province (country_id, state_name)
SELECT country_id, 'Huila' FROM country WHERE iso_alpha2='CO';

INSERT INTO city (state_province_id, time_zone_id, city_name)
SELECT sp.state_province_id, tz.time_zone_id, 'Neiva'
FROM state_province sp, time_zone tz;

INSERT INTO district (city_id, district_name)
SELECT city_id, 'Centro' FROM city;

INSERT INTO address (district_id, address_line_1, postal_code, latitude, longitude)
SELECT district_id, 'Calle 1 #2-3', '410001', 2.9386, -75.2809 FROM district;

INSERT INTO currency (iso_currency_code, currency_name, currency_symbol)
VALUES ('COP', 'Peso Colombiano', '$');
INSERT INTO customer_category (category_code, category_name)
VALUES ('REG', 'Regular');

INSERT INTO benefit_type (benefit_code, benefit_name)
VALUES ('VIP', 'Acceso VIP');

INSERT INTO loyalty_program (airline_id, default_currency_id, program_code, program_name)
SELECT a.airline_id, c.currency_id, 'LM', 'LifeMiles'
FROM airline a, currency c;

INSERT INTO loyalty_tier (loyalty_program_id, tier_code, tier_name, priority_level)
SELECT lp.loyalty_program_id, 'GOLD', 'Gold', 1
FROM loyalty_program lp;

INSERT INTO customer (airline_id, person_id)
SELECT a.airline_id, p.person_id
FROM airline a, person p;

INSERT INTO loyalty_account (customer_id, loyalty_program_id, account_number)
SELECT c.customer_id, lp.loyalty_program_id, 'ACC123'
FROM customer c, loyalty_program lp;
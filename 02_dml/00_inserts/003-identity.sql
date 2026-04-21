INSERT INTO person_type (type_code, type_name)
VALUES ('NAT', 'Natural');

INSERT INTO document_type (type_code, type_name)
VALUES ('CC', 'Cedula');

INSERT INTO contact_type (type_code, type_name)
VALUES ('EMAIL', 'Correo');

INSERT INTO person (person_type_id, first_name, last_name, gender_code)
SELECT pt.person_type_id, 'Juan', 'Perez', 'M'
FROM person_type pt;

INSERT INTO person_document (person_id, document_type_id, document_number)
SELECT p.person_id, dt.document_type_id, '123456789'
FROM person p, document_type dt;

INSERT INTO person_contact (person_id, contact_type_id, contact_value)
SELECT p.person_id, ct.contact_type_id, 'juan@email.com'
FROM person p, contact_type ct;
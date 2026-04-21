
CREATE INDEX idx_country_continent_id ON country(continent_id);
CREATE INDEX idx_state_country_id ON state_province(country_id);
CREATE INDEX idx_city_state_id ON city(state_province_id);
CREATE INDEX idx_district_city_id ON district(city_id);
CREATE INDEX idx_address_district_id ON address(district_id);

CREATE INDEX idx_person_person_type_id ON person(person_type_id);
CREATE INDEX idx_person_nationality_country_id ON person(nationality_country_id);
CREATE INDEX idx_person_document_person_id ON person_document(person_id);
CREATE INDEX idx_person_document_number ON person_document(document_number);
CREATE INDEX idx_person_contact_person_id ON person_contact(person_id);
CREATE INDEX idx_person_contact_value ON person_contact(contact_value);

CREATE INDEX idx_user_account_status_id ON user_account(user_status_id);
CREATE INDEX idx_user_role_user_account_id ON user_role(user_account_id);
CREATE INDEX idx_user_role_role_id ON user_role(security_role_id);
CREATE INDEX idx_role_permission_role_id ON role_permission(security_role_id);
CREATE INDEX idx_role_permission_permission_id ON role_permission(security_permission_id);

CREATE INDEX idx_customer_person_id ON customer(person_id);
CREATE INDEX idx_loyalty_program_airline_id ON loyalty_program(airline_id);
CREATE INDEX idx_loyalty_account_customer_id ON loyalty_account(customer_id);
CREATE INDEX idx_loyalty_account_tier_account_id ON loyalty_account_tier(loyalty_account_id);
CREATE INDEX idx_miles_transaction_account_id ON miles_transaction(loyalty_account_id);

CREATE INDEX idx_airport_address_id ON airport(address_id);
CREATE INDEX idx_terminal_airport_id ON terminal(airport_id);
CREATE INDEX idx_boarding_gate_terminal_id ON boarding_gate(terminal_id);
CREATE INDEX idx_runway_airport_id ON runway(airport_id);

CREATE INDEX idx_aircraft_airline_id ON aircraft(airline_id);
CREATE INDEX idx_aircraft_model_id ON aircraft(aircraft_model_id);
CREATE INDEX idx_aircraft_cabin_aircraft_id ON aircraft_cabin(aircraft_id);
CREATE INDEX idx_aircraft_seat_cabin_id ON aircraft_seat(aircraft_cabin_id);
CREATE INDEX idx_maintenance_event_aircraft_id ON maintenance_event(aircraft_id);

CREATE INDEX idx_flight_aircraft_id ON flight(aircraft_id);
CREATE INDEX idx_flight_service_date ON flight(service_date);
CREATE INDEX idx_flight_segment_flight_id ON flight_segment(flight_id);
CREATE INDEX idx_flight_segment_origin_airport_id ON flight_segment(origin_airport_id);
CREATE INDEX idx_flight_segment_destination_airport_id ON flight_segment(destination_airport_id);
CREATE INDEX idx_flight_delay_segment_id ON flight_delay(flight_segment_id);

CREATE INDEX idx_fare_class_cabin_class_id ON fare_class(cabin_class_id);
CREATE INDEX idx_fare_airline_id ON fare(airline_id);
CREATE INDEX idx_reservation_status_id ON reservation(reservation_status_id);
CREATE INDEX idx_reservation_booked_by_customer_id ON reservation(booked_by_customer_id);
CREATE INDEX idx_reservation_passenger_person_id ON reservation_passenger(person_id);
CREATE INDEX idx_sale_reservation_id ON sale(reservation_id);
CREATE INDEX idx_ticket_sale_id ON ticket(sale_id);
CREATE INDEX idx_ticket_reservation_passenger_id ON ticket(reservation_passenger_id);
CREATE INDEX idx_ticket_segment_ticket_id ON ticket_segment(ticket_id);
CREATE INDEX idx_ticket_segment_flight_segment_id ON ticket_segment(flight_segment_id);
CREATE INDEX idx_seat_assignment_aircraft_seat_id ON seat_assignment(aircraft_seat_id);
CREATE INDEX idx_baggage_ticket_segment_id ON baggage(ticket_segment_id);

CREATE INDEX idx_check_in_status_id ON check_in(check_in_status_id);
CREATE INDEX idx_boarding_pass_check_in_id ON boarding_pass(check_in_id);
CREATE INDEX idx_boarding_validation_boarding_pass_id ON boarding_validation(boarding_pass_id);

CREATE INDEX idx_payment_sale_id ON payment(sale_id);
CREATE INDEX idx_payment_status_id ON payment(payment_status_id);
CREATE INDEX idx_payment_transaction_payment_id ON payment_transaction(payment_id);
CREATE INDEX idx_refund_payment_id ON refund(payment_id);

CREATE INDEX idx_exchange_rate_from_to_date ON exchange_rate(from_currency_id, to_currency_id, effective_date);
CREATE INDEX idx_invoice_sale_id ON invoice(sale_id);
CREATE INDEX idx_invoice_status_id ON invoice(invoice_status_id);
CREATE INDEX idx_invoice_line_invoice_id ON invoice_line(invoice_id);

-- ============================================
-- DOMAIN: FLIGHT OPERATIONS
-- ============================================

-- FLIGHT STATUS
CREATE TABLE flight_status (
    flight_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_flight_status_code UNIQUE (status_code),
    CONSTRAINT uq_flight_status_name UNIQUE (status_name)
);

-- DELAY REASON TYPE
CREATE TABLE delay_reason_type (
    delay_reason_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    reason_code varchar(20) NOT NULL,
    reason_name varchar(100) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_delay_reason_code UNIQUE (reason_code),
    CONSTRAINT uq_delay_reason_name UNIQUE (reason_name)
);

-- FLIGHT
CREATE TABLE flight (
    flight_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id uuid NOT NULL REFERENCES airline(airline_id),
    aircraft_id uuid NOT NULL REFERENCES aircraft(aircraft_id),
    flight_status_id uuid NOT NULL REFERENCES flight_status(flight_status_id),
    flight_number varchar(12) NOT NULL,
    service_date date NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_flight_instance UNIQUE (airline_id, flight_number, service_date)
);

-- FLIGHT SEGMENT
CREATE TABLE flight_segment (
    flight_segment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    flight_id uuid NOT NULL REFERENCES flight(flight_id),
    origin_airport_id uuid NOT NULL REFERENCES airport(airport_id),
    destination_airport_id uuid NOT NULL REFERENCES airport(airport_id),
    segment_number integer NOT NULL,
    scheduled_departure_at timestamptz NOT NULL,
    scheduled_arrival_at timestamptz NOT NULL,
    actual_departure_at timestamptz,
    actual_arrival_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_flight_segment_number UNIQUE (flight_id, segment_number),
    CONSTRAINT ck_flight_segment_airports CHECK (origin_airport_id <> destination_airport_id),
    CONSTRAINT ck_flight_segment_schedule CHECK (scheduled_arrival_at > scheduled_departure_at),
    CONSTRAINT ck_flight_segment_actuals CHECK (
        actual_arrival_at IS NULL
        OR actual_departure_at IS NULL
        OR actual_arrival_at >= actual_departure_at
    )
);

-- FLIGHT DELAY
CREATE TABLE flight_delay (
    flight_delay_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    flight_segment_id uuid NOT NULL REFERENCES flight_segment(flight_segment_id),
    delay_reason_type_id uuid NOT NULL REFERENCES delay_reason_type(delay_reason_type_id),
    reported_at timestamptz NOT NULL,
    delay_minutes integer NOT NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_flight_delay_minutes CHECK (delay_minutes > 0)
);
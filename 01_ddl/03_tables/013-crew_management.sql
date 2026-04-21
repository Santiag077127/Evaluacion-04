-- ============================================
-- CREW MANAGEMENT
-- ============================================

CREATE TABLE crew_role (
    crew_role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_code varchar(20) NOT NULL,
    role_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_crew_role_code UNIQUE (role_code),
    CONSTRAINT uq_crew_role_name UNIQUE (role_name)
);

CREATE TABLE crew_member (
    crew_member_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id uuid NOT NULL REFERENCES person(person_id),
    crew_role_id uuid NOT NULL REFERENCES crew_role(crew_role_id),
    airline_id uuid NOT NULL REFERENCES airline(airline_id),
    hire_date date NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_crew_member_person UNIQUE (person_id)
);

CREATE TABLE crew_certification (
    crew_certification_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    crew_member_id uuid NOT NULL REFERENCES crew_member(crew_member_id),
    aircraft_model_id uuid REFERENCES aircraft_model(aircraft_model_id),
    certification_code varchar(30) NOT NULL,
    issued_at date NOT NULL,
    expires_at date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_crew_certification UNIQUE (crew_member_id, certification_code),
    CONSTRAINT ck_crew_certification_dates CHECK (
        expires_at IS NULL OR expires_at >= issued_at
    )
);

CREATE TABLE crew_schedule (
    crew_schedule_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    crew_member_id uuid NOT NULL REFERENCES crew_member(crew_member_id),
    flight_id uuid NOT NULL REFERENCES flight(flight_id),
    assigned_role_id uuid NOT NULL REFERENCES crew_role(crew_role_id),
    assigned_at timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_crew_schedule UNIQUE (crew_member_id, flight_id)
);
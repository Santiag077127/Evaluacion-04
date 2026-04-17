-- ============================================
-- DOMAIN: OPERATIONS
-- ============================================

-- SERVICE
CREATE TABLE service (
    service_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name varchar(120) NOT NULL,
    description varchar(250),
    base_price numeric(12,2),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_service_name UNIQUE (service_name)
);

-- TASK
CREATE TABLE task (
    task_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid REFERENCES service(service_id),
    task_name varchar(120) NOT NULL,
    task_status varchar(30) NOT NULL,
    priority varchar(20) DEFAULT 'MEDIUM',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- ASSIGNMENT
CREATE TABLE assignment (
    assignment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id uuid NOT NULL REFERENCES task(task_id),
    user_id uuid NOT NULL,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    status varchar(30) NOT NULL DEFAULT 'ASSIGNED'
);

-- SCHEDULE
CREATE TABLE schedule (
    schedule_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid NOT NULL REFERENCES service(service_id),
    start_time timestamptz NOT NULL,
    end_time timestamptz,
    status varchar(30) NOT NULL DEFAULT 'PLANNED'
);

-- OPERATION LOG
CREATE TABLE operation_log (
    log_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid REFERENCES service(service_id),
    action varchar(120) NOT NULL,
    details text,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- PROCESS EXECUTION
CREATE TABLE process_execution (
    execution_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid NOT NULL REFERENCES service(service_id),
    execution_status varchar(30) NOT NULL,
    started_at timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz
);
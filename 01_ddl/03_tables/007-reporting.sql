-- ============================================
-- DOMAIN: REPORTING
-- ============================================

-- REPORT TYPE
CREATE TABLE report_type (
    report_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    report_name varchar(120) NOT NULL,
    description varchar(250),
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_report_name UNIQUE (report_name)
);

-- GENERATED REPORT
CREATE TABLE generated_report (
    report_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    report_type_id uuid NOT NULL REFERENCES report_type(report_type_id),
    generated_by uuid,
    report_date timestamptz NOT NULL DEFAULT now(),
    report_data jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- SYSTEM METRIC
CREATE TABLE system_metric (
    metric_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name varchar(120) NOT NULL,
    metric_value numeric(14,4),
    metric_unit varchar(50),
    recorded_at timestamptz NOT NULL DEFAULT now()
);

-- AUDIT SUMMARY (AGREGADO)
CREATE TABLE audit_summary (
    summary_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_name varchar(120) NOT NULL,
    total_actions integer NOT NULL DEFAULT 0,
    last_action_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- USER ACTIVITY REPORT
CREATE TABLE user_activity_report (
    activity_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    activity_type varchar(120) NOT NULL,
    activity_count integer NOT NULL DEFAULT 1,
    activity_date date NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);
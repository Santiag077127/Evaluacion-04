-- ============================================
-- DOMAIN: PAYMENT
-- ============================================

-- PAYMENT STATUS
CREATE TABLE payment_status (
    payment_status_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code varchar(20) NOT NULL,
    status_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_status_code UNIQUE (status_code),
    CONSTRAINT uq_payment_status_name UNIQUE (status_name)
);

-- PAYMENT METHOD
CREATE TABLE payment_method (
    payment_method_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    method_code varchar(20) NOT NULL,
    method_name varchar(80) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_method_code UNIQUE (method_code),
    CONSTRAINT uq_payment_method_name UNIQUE (method_name)
);

-- PAYMENT
CREATE TABLE payment (
    payment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id uuid NOT NULL REFERENCES sale(sale_id),
    payment_status_id uuid NOT NULL REFERENCES payment_status(payment_status_id),
    payment_method_id uuid NOT NULL REFERENCES payment_method(payment_method_id),
    currency_id uuid NOT NULL REFERENCES currency(currency_id),
    payment_reference varchar(40) NOT NULL,
    amount numeric(12, 2) NOT NULL,
    authorized_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_reference UNIQUE (payment_reference),
    CONSTRAINT ck_payment_amount CHECK (amount > 0)
);

-- PAYMENT TRANSACTION
CREATE TABLE payment_transaction (
    payment_transaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id uuid NOT NULL REFERENCES payment(payment_id),
    transaction_reference varchar(60) NOT NULL,
    transaction_type varchar(20) NOT NULL,
    transaction_amount numeric(12, 2) NOT NULL,
    processed_at timestamptz NOT NULL,
    provider_message text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_transaction_reference UNIQUE (transaction_reference),
    CONSTRAINT ck_payment_transaction_type CHECK (transaction_type IN ('AUTH', 'CAPTURE', 'VOID', 'REFUND', 'REVERSAL')),
    CONSTRAINT ck_payment_transaction_amount CHECK (transaction_amount > 0)
);

-- REFUND
CREATE TABLE refund (
    refund_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id uuid NOT NULL REFERENCES payment(payment_id),
    refund_reference varchar(40) NOT NULL,
    amount numeric(12, 2) NOT NULL,
    requested_at timestamptz NOT NULL,
    processed_at timestamptz,
    refund_reason text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_refund_reference UNIQUE (refund_reference),
    CONSTRAINT ck_refund_amount CHECK (amount > 0),
    CONSTRAINT ck_refund_dates CHECK (processed_at IS NULL OR processed_at >= requested_at)
);
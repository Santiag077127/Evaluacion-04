-- ============================================
-- DOMAIN: PAYMENTS
-- ============================================

-- PAYMENT METHOD
CREATE TABLE payment_method (
    payment_method_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    method_name varchar(50) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_method_name UNIQUE (method_name)
);

-- INVOICE
CREATE TABLE invoice (
    invoice_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id uuid NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    invoice_status varchar(30) NOT NULL,
    issued_at timestamptz NOT NULL DEFAULT now(),
    due_date timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- PAYMENT TRANSACTION
CREATE TABLE payment_transaction (
    transaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id uuid NOT NULL REFERENCES invoice(invoice_id),
    payment_method_id uuid NOT NULL REFERENCES payment_method(payment_method_id),
    amount numeric(12,2) NOT NULL,
    transaction_status varchar(30) NOT NULL,
    transaction_reference varchar(120),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- REFUND
CREATE TABLE refund (
    refund_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id uuid NOT NULL REFERENCES payment_transaction(transaction_id),
    amount numeric(12,2) NOT NULL,
    reason varchar(200),
    refunded_at timestamptz DEFAULT now()
);

-- BILLING ADDRESS (RELACIONADO A GEOGRAPHY)
CREATE TABLE billing_address (
    billing_address_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id uuid NOT NULL,
    address_text varchar(250) NOT NULL,
    city varchar(120),
    country varchar(120),
    postal_code varchar(20),
    created_at timestamptz NOT NULL DEFAULT now()
);
-- ============================================
-- DOMAIN: BUSINESS
-- ============================================

-- CUSTOMER
CREATE TABLE customer (
    customer_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name varchar(80) NOT NULL,
    last_name varchar(80) NOT NULL,
    email varchar(150) NOT NULL,
    phone varchar(30),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_email UNIQUE (email)
);

-- PROVIDER
CREATE TABLE provider (
    provider_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_name varchar(120) NOT NULL,
    email varchar(150),
    phone varchar(30),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_provider_name UNIQUE (provider_name)
);

-- PRODUCT / SERVICE
CREATE TABLE product (
    product_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id uuid NOT NULL REFERENCES provider(provider_id),
    product_name varchar(120) NOT NULL,
    price numeric(12,2) NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- ORDER
CREATE TABLE "order" (
    order_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id uuid NOT NULL REFERENCES customer(customer_id),
    order_status varchar(30) NOT NULL,
    total_amount numeric(12,2) NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- ORDER ITEM (PIVOTE)
CREATE TABLE order_item (
    order_id uuid NOT NULL REFERENCES "order"(order_id),
    product_id uuid NOT NULL REFERENCES product(product_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(12,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- PAYMENT
CREATE TABLE payment (
    payment_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid NOT NULL REFERENCES "order"(order_id),
    payment_method varchar(50) NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_status varchar(30) NOT NULL,
    paid_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- ORDER STATUS HISTORY
CREATE TABLE order_status_history (
    history_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id uuid NOT NULL REFERENCES "order"(order_id),
    status varchar(30) NOT NULL,
    changed_at timestamptz NOT NULL DEFAULT now()
);
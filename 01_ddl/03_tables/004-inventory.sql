-- ============================================
-- DOMAIN: INVENTORY
-- ============================================

-- CATEGORY
CREATE TABLE category (
    category_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name varchar(100) NOT NULL,
    description varchar(200),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_category_name UNIQUE (category_name)
);

-- WAREHOUSE
CREATE TABLE warehouse (
    warehouse_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_name varchar(120) NOT NULL,
    location varchar(200),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_warehouse_name UNIQUE (warehouse_name)
);

-- INVENTORY ITEM
CREATE TABLE inventory_item (
    inventory_item_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id uuid REFERENCES category(category_id),
    warehouse_id uuid REFERENCES warehouse(warehouse_id),
    item_name varchar(120) NOT NULL,
    sku varchar(80) NOT NULL UNIQUE,
    quantity integer NOT NULL DEFAULT 0,
    min_stock integer NOT NULL DEFAULT 0,
    price numeric(12,2),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_inventory_quantity CHECK (quantity >= 0)
);

-- STOCK MOVEMENT
CREATE TABLE stock_movement (
    movement_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_item_id uuid NOT NULL REFERENCES inventory_item(inventory_item_id),
    movement_type varchar(20) NOT NULL, -- IN / OUT
    quantity integer NOT NULL CHECK (quantity > 0),
    reason varchar(200),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- SUPPLIER
CREATE TABLE supplier (
    supplier_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_name varchar(120) NOT NULL,
    contact_email varchar(150),
    phone varchar(30),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_supplier_name UNIQUE (supplier_name)
);

-- SUPPLIER INVENTORY (PIVOTE)
CREATE TABLE supplier_inventory (
    supplier_id uuid NOT NULL REFERENCES supplier(supplier_id),
    inventory_item_id uuid NOT NULL REFERENCES inventory_item(inventory_item_id),
    supply_price numeric(12,2),
    PRIMARY KEY (supplier_id, inventory_item_id)
);
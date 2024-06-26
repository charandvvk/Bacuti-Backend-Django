-- Database: `bacuti`
-- DROP DATABASE IF EXISTS is not commonly used in PostgreSQL in this context. Usually handled by tools.
DROP DATABASE IF EXISTS bacuti;
CREATE DATABASE bacuti;

-- Connect to the bacuti database
\c bacuti;

-- Table structure for table `products`
CREATE TABLE products (
  product_id UUID PRIMARY KEY,
  name TEXT NOT NULL
);

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Dumping data for table `products`
INSERT INTO products (product_id, name) VALUES
(uuid_generate_v4(), 'Car');

-- Table structure for table `subassemblies`
CREATE TABLE subassemblies (
  subassembly_id UUID PRIMARY KEY,
  product_id UUID NOT NULL,
  subassembly_parent_id UUID,
  name TEXT NOT NULL,
  quantity INT NOT NULL,
  CONSTRAINT fk_product_id FOREIGN KEY(product_id) REFERENCES products(product_id),
  CONSTRAINT fk_subassembly_parent_id FOREIGN KEY(subassembly_parent_id) REFERENCES subassemblies(subassembly_id)
);

-- Indexes for table `subassemblies`
CREATE INDEX idx_product_id_subassemblies ON subassemblies(product_id);

-- Dumping data for table `subassemblies`
DO $$
DECLARE
    product_id UUID;
BEGIN
    -- Assign the product_id variable
    SELECT p.product_id INTO product_id 
    FROM products p 
    WHERE p.name = 'Car';

    -- Insert data into subassemblies table
    INSERT INTO subassemblies (subassembly_id, product_id, subassembly_parent_id, name, quantity) VALUES
    (uuid_generate_v4(), product_id, NULL, 'Wheel Assembly', 4),
    (uuid_generate_v4(), product_id, NULL, 'Brake Assembly', 4),
    (uuid_generate_v4(), product_id, NULL, 'Light System', 1);
END $$;

-- Table structure for table `components`
CREATE TABLE components (
  component_id UUID PRIMARY KEY,
  product_id UUID NOT NULL,
  subassembly_parent_id UUID,
  name TEXT NOT NULL,
  quantity INT NOT NULL,
  CONSTRAINT fk_product_id FOREIGN KEY(product_id) REFERENCES products(product_id),
  CONSTRAINT fk_subassembly_parent_id FOREIGN KEY(subassembly_parent_id) REFERENCES subassemblies(subassembly_id)
);

-- Indexes for table `components`
CREATE INDEX idx_product_id_components ON components(product_id);

-- Dumping data for table `components`
DO $$ 
DECLARE
    product_id UUID;
    wheelAssembly_id UUID;
    brakeAssembly_id UUID;
    lightSystem_id UUID;
BEGIN
    -- Assign the product_id variable
    SELECT p.product_id INTO product_id 
    FROM products p 
    WHERE p.name = 'Car';

    -- Assign the wheelAssembly_id variable
    SELECT s.subassembly_id INTO wheelAssembly_id 
    FROM subassemblies s 
    WHERE s.name = 'Wheel Assembly';

    -- Assign the brakeAssembly_id variable
    SELECT s.subassembly_id INTO brakeAssembly_id 
    FROM subassemblies s 
    WHERE s.name = 'Brake Assembly';

    -- Assign the lightSystem_id variable
    SELECT s.subassembly_id INTO lightSystem_id 
    FROM subassemblies s 
    WHERE s.name = 'Light System';

    -- Insert data into components table
    INSERT INTO components (component_id, product_id, subassembly_parent_id, name, quantity) VALUES
    (uuid_generate_v4(), product_id, NULL, 'Transmission', 1),
    (uuid_generate_v4(), product_id, NULL, 'Bucket Seats', 2),
    (uuid_generate_v4(), product_id, NULL, 'Back Seat', 1),
    (uuid_generate_v4(), product_id, wheelAssembly_id, 'Nuts', 8),
    (uuid_generate_v4(), product_id, wheelAssembly_id, 'Tire', 1),
    (uuid_generate_v4(), product_id, wheelAssembly_id, 'Faceplate', 1),
    (uuid_generate_v4(), product_id, brakeAssembly_id, 'Brake Pads', 2),
    (uuid_generate_v4(), product_id, brakeAssembly_id, 'Disks', 1),
    (uuid_generate_v4(), product_id, brakeAssembly_id, 'Nuts', 4),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Front Lights', 2),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Rear Lights', 2),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Turning Lights', 4),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Interior', 1),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Turning Switch', 1),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Door Switch', 4),
    (uuid_generate_v4(), product_id, lightSystem_id, 'Overhead Switch', 1);
END $$;

-- Table structure for table `emissions`
CREATE TABLE emissions (
  emission_id SERIAL PRIMARY KEY,
  component_id UUID NOT NULL,
  month TEXT CHECK (month IN ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug')),
  category TEXT CHECK (category IN ('Plan', 'Actual')),
  pef_total INT NOT NULL,
  scope_1 INT NOT NULL,
  scope_2 INT NOT NULL,
  scope_3 INT NOT NULL,
  category_1 INT NOT NULL,
  category_5 INT NOT NULL,
  category_12 INT NOT NULL,
  CONSTRAINT fk_component_id FOREIGN KEY (component_id) REFERENCES components(component_id)
);

-- Indexes for table `emissions`
CREATE INDEX idx_component_id_emissions ON emissions(component_id);

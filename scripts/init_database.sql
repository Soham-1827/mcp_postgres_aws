-- Create sample e-commerce database schema

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

COMMENT ON TABLE users IS 'Store user account information';
COMMENT ON COLUMN users.email IS 'User email address for login';

-- Products table
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE products IS 'Product catalog with pricing and inventory';
COMMENT ON COLUMN products.price IS 'Product price in USD';

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending',
    total_amount DECIMAL(10, 2)
);

COMMENT ON TABLE orders IS 'Customer orders and their status';

-- Insert sample data
INSERT INTO users (username, email, full_name) VALUES
('john_doe', 'john@example.com', 'John Doe'),
('jane_smith', 'jane@example.com', 'Jane Smith'),
('bob_wilson', 'bob@example.com', 'Bob Wilson')
ON CONFLICT (username) DO NOTHING;

INSERT INTO products (name, description, price, stock_quantity, category) VALUES
('Laptop Pro 15', 'High-performance laptop', 1299.99, 50, 'Electronics'),
('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 200, 'Electronics'),
('Office Chair', 'Comfortable ergonomic chair', 349.99, 30, 'Furniture'),
('USB-C Hub', '7-in-1 USB-C hub', 49.99, 150, 'Electronics'),
('Mechanical Keyboard', 'RGB mechanical keyboard', 89.99, 75, 'Electronics')
ON CONFLICT DO NOTHING;

INSERT INTO orders (user_id, status, total_amount) VALUES
(1, 'delivered', 1329.98),
(2, 'shipped', 379.98),
(1, 'pending', 119.97)
ON CONFLICT DO NOTHING;
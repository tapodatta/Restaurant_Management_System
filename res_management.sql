-- Create the database
CREATE DATABASE RestaurantManagement;

USE RestaurantManagement;

-- 1. Users/Admin Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_type ENUM('admin', 'manager', 'staff', 'headchef') NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME
);

-- 2. Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    address TEXT,
    join_date DATE DEFAULT CURRENT_DATE,
    loyalty_points INT DEFAULT 0,
    special_notes TEXT
);

-- 3. MenuItems Table
CREATE TABLE MenuItems (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    preparation_time INT COMMENT 'Preparation time in minutes',
    calories INT,
    dietary_tags VARCHAR(100) COMMENT 'e.g., vegetarian, gluten-free',
    image_url VARCHAR(255)
);

-- 4. RestaurantTables Table
CREATE TABLE RestaurantTables (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    table_number VARCHAR(10) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    location_description VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE,
    min_occupancy INT,
    max_occupancy INT
);

-- 5. Reservations Table
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    table_id INT,
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    party_size INT NOT NULL,
    status ENUM('confirmed', 'waiting', 'cancelled', 'completed') DEFAULT 'confirmed',
    special_requests TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (table_id) REFERENCES RestaurantTables(table_id)
);

-- 6. Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    user_id INT COMMENT 'Staff who took the order',
    table_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'preparing', 'ready', 'served', 'completed', 'cancelled') DEFAULT 'pending',
    order_type ENUM('dine-in', 'takeaway', 'delivery') DEFAULT 'dine-in',
    total_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (table_id) REFERENCES RestaurantTables(table_id)
);

-- 7. OrderItems Table
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    special_instructions TEXT,
    item_price DECIMAL(10,2) NOT NULL,
    item_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
);

-- 8. Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'mobile_payment', 'voucher') NOT NULL,
    transaction_id VARCHAR(100),
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'completed',
    tip_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- 9. Feedback Table
CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_id INT,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    feedback_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    staff_rating INT CHECK (staff_rating BETWEEN 1 AND 5),
    food_rating INT CHECK (food_rating BETWEEN 1 AND 5),
    is_anonymous BOOLEAN DEFAULT FALSE,
    response TEXT COMMENT 'Management response',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Insert sample data into Users table
INSERT INTO Users (username, password_hash, email, user_type, first_name, last_name, phone_number)
VALUES
('admin', '12345', 'Joy@restaurant.com', 'admin', 'Joy', 'Biswas', '01889001265'),
('manager', '1234', 'Tapo@restaurant.com', 'manager', 'Tapo', 'Datta', '01887485500'),
('staff1', '123456', 'Sarah@restaurant.com', 'staff', 'Sarah', 'Waitress', '01974722409'),
('Headchef', '1234567', 'rayhan@restaurant.com', 'headchef', 'Rayhan', 'Islam', '01812205639'),
('waiter1', '0987', 'waiter.sam@restaurant.com', 'staff', 'Sam', 'Waiterson', '0181111111'),
('waiter2', '0988', 'waiter.lisa@restaurant.com', 'staff', 'Lisa', 'Server', '01822222222');

-- Insert sample data into Customers table
INSERT INTO Customers (first_name, last_name, phone_number, email, address, loyalty_points, join_date)
VALUES
('Michael', 'Johnson', '01833333333', 'michael@email.com', '123 Main St, Apt 6, Cityville', 150, '2025-02-21'),
('Emily', 'Davis', '01844444444', 'emily@email.com', '12 KM Das Lane, Tikatull', 75, '2025-03-11'),
('Robert', 'Wilson', '01855555555', 'robert@email.com', '24/A, Avoy Das Lane, Gopibag', 200, '2025-01-10'),
('Jennifer', 'Brown', '01866666666', 'jennifer@email.com', '123 Main St, Apt 4, Cityville', 85, '2025-02-11'),
('David', 'Miller', '555-2002', 'david@email.com', '456 Oak Ave, Townsville', 120, '2023-02-15'),
('Sarah', 'Wilson', '555-2003', 'sarah@email.com', '789 Pine Rd, Villageton', 45, '2023-03-20'),
('James', 'Taylor', '555-2004', 'james@email.com', '321 Elm Blvd, Hamlet City', 200, '2023-01-05'),
('Emma', 'Anderson', '555-2005', 'emma@email.com', '654 Maple Ln, Borough Town', 60, '2023-04-10'),
('Daniel', 'Thomas', '555-2006', 'daniel@email.com', '987 Cedar St, Countyville', 90, '2023-02-28'),
('Olivia', 'Jackson', '555-2007', 'olivia@email.com', '135 Birch Dr, District City', 110, '2023-03-15'),
('William', 'White', '555-2008', 'william@email.com', '246 Spruce Way, Metroville', 75, '2023-04-05'),
('Sophia', 'Harris', '555-2009', 'sophia@email.com', '369 Willow Cir, Urban Town', 150, '2023-01-20'),
('Benjamin', 'Martin', '555-2010', 'benjamin@email.com', '482 Aspen Pl, Capital City', 30, '2023-05-01');

-- Insert sample data into MenuItems table
INSERT INTO MenuItems (item_name, description, category, subcategory, price, cost, is_available, preparation_time, calories, dietary_tags)
VALUES
('Pepperoni Pizza', 'Classic pizza with tomato sauce, mozzarella, and pepperoni', 'Main Course', 'Pizza', 14.99, 5.00, TRUE, 15, 850, ''),
('Vegetarian Pizza', 'Pizza with mixed vegetables and mozzarella', 'Main Course', 'Pizza', 13.99, 4.80, TRUE, 15, 750, 'vegetarian'),
('Greek Salad', 'Fresh vegetables with feta cheese and olives', 'Appetizer', 'Salad', 9.99, 3.50, TRUE, 10, 350, 'vegetarian'),
('Bruschetta', 'Toasted bread topped with tomatoes and garlic', 'Appetizer', 'Starter', 7.99, 2.50, TRUE, 8, 280, 'vegetarian'),
('Spaghetti Carbonara', 'Pasta with creamy egg sauce and pancetta', 'Main Course', 'Pasta', 15.99, 5.50, TRUE, 18, 920, ''),
('Chicken Alfredo', 'Fettuccine with creamy Alfredo sauce and chicken', 'Main Course', 'Pasta', 16.99, 6.00, TRUE, 20, 950, ''),
('Beef Burger', 'Classic beef burger with cheese and vegetables', 'Main Course', 'Sandwich', 11.99, 4.00, TRUE, 12, 780, ''),
('Veggie Burger', 'Plant-based burger with vegetables and cheese', 'Main Course', 'Sandwich', 10.99, 3.80, TRUE, 12, 650, 'vegetarian'),
('Tiramisu', 'Classic Italian coffee-flavored dessert', 'Dessert', '', 7.99, 2.80, TRUE, 5, 450, 'vegetarian'),
('Cheesecake', 'New York style cheesecake with berry sauce', 'Dessert', '', 8.50, 3.00, TRUE, 5, 500, 'vegetarian'),
('Iced Tea', 'Freshly brewed iced tea', 'Beverage', 'Non-Alcoholic', 3.50, 0.80, TRUE, 2, 70, 'vegan'),
('Lemonade', 'Homemade lemonade', 'Beverage', 'Non-Alcoholic', 3.99, 0.90, TRUE, 2, 90, 'vegan'),
('Red Wine', 'House red wine glass', 'Beverage', 'Alcoholic', 7.99, 2.50, TRUE, 1, 120, ''),
('White Wine', 'House white wine glass', 'Beverage', 'Alcoholic', 7.99, 2.50, TRUE, 1, 120, ''),
('Mojo', 'Cold drink', 'Beverage', 'Alcoholic', 5.99, 1.80, TRUE, 1, 150, '');

-- Insert sample data into RestaurantTables table
INSERT INTO RestaurantTables (table_number, capacity, location_description, is_available, min_occupancy, max_occupancy)
VALUES
('T1', 4, 'Window view', TRUE, 2, 4),
('T2', 6, 'Center of dining area', TRUE, 5, 6),
('T3', 2, 'Quiet corner', TRUE, 1, 2),
('T4', 8, 'Private section', TRUE, 3, 7),
('T5', 4, 'Near kitchen', TRUE, 2, 4),
('T6', 6, 'Patio area', TRUE, 4, 6),
('T7', 2, 'Bar side', TRUE, 1, 2),
('T8', 10, 'Private dining room', TRUE, 6, 10),
('T9', 4, 'Window view', TRUE, 2, 4),
('T10', 8, 'Center of dining area', TRUE, 4, 8),
('T11', 4, 'Quiet corner', TRUE, 2, 4),
('T12', 6, 'Near entrance', TRUE, 3, 6);

-- Insert sample data into Reservations table
INSERT INTO Reservations (customer_id, table_id, reservation_date, start_time, end_time, party_size, status, special_requests)
VALUES
(1, 1, '2023-06-15', '18:00:00', '20:00:00', 4, 'confirmed', 'Birthday celebration'),
(2, 2, '2023-06-15', '19:30:00', '21:30:00', 5, 'confirmed', 'Date'),
(3, 3, '2023-06-16', '12:00:00', '14:00:00', 2, 'confirmed', ''),
(4, 5, '2023-06-16', '19:00:00', '21:00:00', 3, 'confirmed', 'Birthday celebration'),
(5, 6, '2023-06-17', '12:30:00', '14:30:00', 5, 'confirmed', 'Allergic to nuts'),
(6, 7, '2023-06-17', '18:30:00', '20:30:00', 2, 'confirmed', 'Anniversary dinner'),
(7, 8, '2023-06-18', '20:00:00', '22:00:00', 8, 'confirmed', 'Business dinner'),
(8, 9, '2023-06-18', '19:30:00', '21:30:00', 4, 'confirmed', 'Window seat preferred'),
(9, 10, '2023-06-19', '13:00:00', '15:00:00', 6, 'confirmed', ''),
(10, 11, '2023-06-19', '18:00:00', '20:00:00', 3, 'confirmed', 'Vegetarian group'),
(1, 12, '2023-06-20', '19:00:00', '21:00:00', 5, 'confirmed', 'High chair needed'),
(2, 5, '2023-06-20', '12:00:00', '14:00:00', 2, 'confirmed', ''),
(3, 6, '2023-06-21', '18:30:00', '20:30:00', 4, 'confirmed', 'Allergic to shellfish');

-- Insert sample data into Orders table
INSERT INTO Orders (customer_id, user_id, table_id, order_date, status, order_type, total_amount, tax_amount, discount_amount, notes)
VALUES
(1, 3, 1, '2023-06-15 18:00:00', 'completed', 'dine-in', 38.97, 3.44, 0, 'Regular customer'),
(2, 3, 2, '2023-06-15 19:30:00', 'completed', 'dine-in', 25.48, 4.52, 5.00, 'Used loyalty points'),
(3, 3, NULL, '2023-06-16 12:00:00', 'completed', 'takeaway', 18.99, 3.84, 0, ''),
(4, 3, 5, '2023-06-10 19:05:00', 'completed', 'dine-in', 42.97, 3.44, 0, 'Regular customer'),
(5, 4, 6, '2023-06-10 19:30:00', 'completed', 'dine-in', 56.45, 4.52, 5.00, 'Used loyalty points'),
(6, 5, NULL, '2023-06-11 18:15:00', 'completed', 'takeaway', 32.98, 2.64, 0, ''),
(7, 3, 8, '2023-06-11 20:10:00', 'completed', 'dine-in', 89.50, 7.16, 0, 'Business meeting'),
(8, 4, 9, '2023-06-12 19:45:00', 'completed', 'dine-in', 47.95, 3.84, 0, ''),
(9, 5, 10, '2023-06-12 13:20:00', 'completed', 'dine-in', 65.30, 5.22, 0, ''),
(10, 3, NULL, '2023-06-13 17:30:00', 'completed', 'delivery', 38.99, 3.12, 0, 'Address: 482 Aspen PI'),
(1, 4, 12, '2023-06-13 19:00:00', 'completed', 'dine-in', 52.75, 4.22, 0, ''),
(2, 5, NULL, '2023-06-14 18:45:00', 'completed', 'takeaway', 27.50, 2.20, 0, ''),
(3, 3, 6, '2023-06-14 20:15:00', 'completed', 'dine-in', 61.80, 4.94, 10.00, 'Anniversary discount'),
(4, 4, 5, '2023-06-15 12:30:00', 'preparing', 'dine-in', 34.25, 2.74, 0, ''),
(5, 5, NULL, '2023-06-15 18:00:00', 'pending', 'delivery', 45.60, 3.65, 0, 'Address: 654 Maple Ln');

-- Insert sample data into OrderItems table
INSERT INTO OrderItems (order_id, item_id, quantity, special_instructions, item_price, item_cost)
VALUES
(1, 1, 2, '', 12.99, 4.50),
(1, 3, 1, '', 6.99, 2.00),
(2, 2, 2, '', 8.50, 3.20),
(2, 4, 1, '', 18.99, 7.50),
(3, 1, 1, '', 12.99, 4.50),
(4, 5, 1, 'Extra pepperoni', 14.99, 5.00),
(4, 9, 1, '', 9.99, 3.50),
(4, 15, 2, '', 7.99, 2.50),
(5, 6, 2, 'One without onions', 13.99, 4.80),
(5, 10, 1, 'Dressing on side', 7.99, 2.50),
(5, 16, 3, '', 5.99, 1.80),
(6, 7, 1, 'Well done', 15.99, 5.50),
(6, 11, 1, '', 6.99, 2.00),
(7, 8, 4, 'Two with no cheese', 16.99, 6.00),
(7, 12, 2, '', 11.99, 4.00),
(7, 17, 4, '', 3.50, 0.80),
(8, 9, 1, '', 9.99, 3.50),
(8, 13, 1, '', 8.50, 3.00),
(8, 18, 2, '', 7.99, 2.50),
(9, 10, 1, '', 7.99, 2.50),
(9, 14, 1, '', 10.99, 3.80),
(10, 11, 2, '', 6.99, 2.00),
(10, 15, 1, '', 7.99, 2.50),
(11, 12, 1, '', 11.99, 4.00),
(11, 16, 1, '', 5.99, 1.80),
(12, 13, 3, '', 8.50, 3.00),
(12, 17, 2, '', 3.50, 0.80);

-- Insert sample data into Payments table
INSERT INTO Payments (order_id, payment_date, amount, payment_method, payment_status, tip_amount)
VALUES
(1, '2023-06-13 21:00:00', 38.97, 'credit_card', 'completed', 0),
(2, '2023-06-11 22:50:00', 25.48, 'cash', 'completed', 0),
(3, '2023-06-16 12:30:00', 18.99, 'debit_card', 'completed', 0),
(4, '2023-06-10 20:30:00', 42.97, 'credit_card', 'completed', 6.50),
(5, '2023-06-10 21:00:00', 56.45, 'debit_card', 'completed', 8.00),
(6, '2023-06-11 18:45:00', 32.98, 'cash', 'completed', 0),
(7, '2023-06-11 21:45:00', 89.50, 'credit_card', 'completed', 12.00),
(8, '2023-06-12 21:00:00', 47.95, 'mobile_payment', 'completed', 7.00),
(9, '2023-06-12 14:30:00', 65.30, 'credit_card', 'completed', 9.00),
(10, '2023-06-13 18:15:00', 38.99, 'cash', 'completed', 5.00),
(11, '2023-06-13 20:30:00', 52.75, 'debit_card', 'completed', 7.50),
(12, '2023-06-14 19:20:00', 27.50, 'credit_card', 'completed', 4.00),
(13, '2023-06-14 21:30:00', 61.80, 'mobile_payment', 'completed', 8.00);

-- Insert sample data into Feedback table
INSERT INTO Feedback (customer_id, order_id, rating, comments, staff_rating, food_rating, is_anonymous)
VALUES
(1, 1, 5, 'Excellent service and food!', 5, 5, TRUE),
(2, 2, 4, 'Good experience overall', 4, 5, FALSE),
(3, 3, 3, 'Food was good but packaging could be better', 5, 3, TRUE),
(4, 4, 5, 'Everything was perfect! Will definitely comeback.', 5, 5, FALSE),
(5, 5, 4, 'Good food but service was a bit slow', 3, 5, FALSE),
(6, 6, 3, 'Take away order had missing items', 4, 2, TRUE),
(7, 7, 5, 'Excellent for our business dinner', 5, 5, FALSE),
(8, 8, 4, 'Nice atmosphere and good food', 4, 4, FALSE),
(9, 9, 5, 'Best Tiramisu I ever had!', 5, 5, FALSE),
(10, 10, 2, 'Delivery was late and food was cold', 1, 3, TRUE),
(1, 11, 4, 'Enjoyable experience overall', 4, 4, FALSE),
(2, 12, 5, 'Perfect anniversary dinner!', 5, 5, FALSE),
(3, 13, 3, 'Food was good but overpriced', 4, 4, TRUE);
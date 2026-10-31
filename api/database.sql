-- ==========================================================
-- Tenkasi Dreams Land - Real Estate MySQL Database Schema
-- Database: `tenkasi_dreams`
-- Compatible with XAMPP MySQL, MariaDB, cPanel
-- ==========================================================

CREATE DATABASE IF NOT EXISTS `tenkasi_dreams` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `tenkasi_dreams`;

-- 1. Admin Users Table
CREATE TABLE IF NOT EXISTS `admin_users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` VARCHAR(30) DEFAULT 'super_admin',
  `full_name` VARCHAR(100) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `admin_users` (`username`, `password`, `role`, `full_name`) 
VALUES ('admin3', '000003', 'super_admin', 'Tenkasi Dreams Super Admin')
ON DUPLICATE KEY UPDATE `password` = '000003';

-- 2. Properties Table
CREATE TABLE IF NOT EXISTS `properties` (
  `id` VARCHAR(64) PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `price` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `location` VARCHAR(150) NOT NULL,
  `city` VARCHAR(80) NOT NULL DEFAULT 'Tenkasi',
  `property_type` VARCHAR(50) NOT NULL,
  `area_sq_ft` INT NOT NULL DEFAULT 0,
  `super_built_up_sq_ft` INT DEFAULT NULL,
  `carpet_area_sq_ft` INT DEFAULT NULL,
  `bedrooms` INT DEFAULT NULL,
  `bathrooms` INT DEFAULT NULL,
  `furnishing_status` VARCHAR(50) DEFAULT 'Unfurnished',
  `facing` VARCHAR(50) DEFAULT 'East',
  `floor` VARCHAR(50) DEFAULT 'Ground Floor',
  `maintenance_monthly` DECIMAL(10,2) DEFAULT NULL,
  `landmark` VARCHAR(150) DEFAULT NULL,
  `poster_type` VARCHAR(50) DEFAULT 'Direct Owner',
  `land_unit` VARCHAR(50) DEFAULT NULL,
  `land_unit_value` DECIMAL(10,2) DEFAULT NULL,
  `land_features` JSON DEFAULT NULL,
  `approval_type` VARCHAR(100) DEFAULT NULL,
  `is_bank_loan_available` TINYINT(1) DEFAULT 0,
  `is_price_negotiable` TINYINT(1) DEFAULT 1,
  `water_source` VARCHAR(50) DEFAULT 'Both',
  `has_lift` TINYINT(1) DEFAULT 0,
  `has_trees` TINYINT(1) DEFAULT 0,
  `trees_details` TEXT DEFAULT NULL,
  `has_income` TINYINT(1) DEFAULT 0,
  `income_details` TEXT DEFAULT NULL,
  `is_lease` TINYINT(1) DEFAULT 0,
  `rental_sub_type` VARCHAR(100) DEFAULT NULL,
  `advance_amount` DECIMAL(12,2) DEFAULT NULL,
  `commercial_area_type` VARCHAR(100) DEFAULT NULL,
  `has_table` TINYINT(1) DEFAULT 0,
  `has_fan` TINYINT(1) DEFAULT 0,
  `has_water_supply` TINYINT(1) DEFAULT 0,
  `has_shutter` TINYINT(1) DEFAULT 0,
  `power_phase` VARCHAR(50) DEFAULT 'Single Phase',
  `contact_phone` VARCHAR(30) DEFAULT '+91 98941 74944',
  `image_keys` JSON DEFAULT NULL,
  `amenities` JSON DEFAULT NULL,
  `agent_id` VARCHAR(50) DEFAULT 'user_agent',
  `agent_name` VARCHAR(100) DEFAULT 'Direct Owner',
  `agent_agency` VARCHAR(100) DEFAULT 'Tenkasi Dreams',
  `agent_phone` VARCHAR(30) DEFAULT '+91 98941 74944',
  `agent_email` VARCHAR(100) DEFAULT 'tenkasidreams@gmail.com',
  `posted_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status` VARCHAR(20) DEFAULT 'active',
  `is_favorite` TINYINT(1) DEFAULT 0,
  `views` INT DEFAULT 0,
  `enquiries` INT DEFAULT 0,
  `is_verified` TINYINT(1) DEFAULT 1,
  `is_featured` TINYINT(1) DEFAULT 0,
  `is_user_posted` TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Buyer Requirements Table (மக்களின் தேவை)
CREATE TABLE IF NOT EXISTS `buyer_requirements` (
  `id` VARCHAR(64) PRIMARY KEY,
  `user_name` VARCHAR(100) NOT NULL,
  `user_phone` VARCHAR(30) NOT NULL,
  `property_type` VARCHAR(50) NOT NULL,
  `target_location` VARCHAR(150) NOT NULL,
  `budget_min` DECIMAL(14,2) DEFAULT 0.00,
  `budget_max` DECIMAL(14,2) DEFAULT 0.00,
  `preferred_size` VARCHAR(100) DEFAULT NULL,
  `facing_preference` VARCHAR(50) DEFAULT 'Any',
  `description` TEXT,
  `posted_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status` VARCHAR(20) DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

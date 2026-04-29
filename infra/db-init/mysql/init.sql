-- =============================
-- CREATE DATABASES IF NOT EXISTS
-- =============================
CREATE DATABASE IF NOT EXISTS cities;
CREATE DATABASE IF NOT EXISTS ratings;

-- =============================
-- CREATE USERS IF NOT EXISTS
-- =============================
CREATE USER IF NOT EXISTS 'shipping'@'%' IDENTIFIED BY 'shipping123';
CREATE USER IF NOT EXISTS 'ratings'@'%' IDENTIFIED BY 'ratings';
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exporter';

GRANT ALL PRIVILEGES ON cities.* TO 'shipping'@'%';
GRANT ALL PRIVILEGES ON ratings.* TO 'ratings'@'%';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
FLUSH PRIVILEGES;

-- =============================
-- RATINGS DB
-- =============================
USE ratings;

CREATE TABLE IF NOT EXISTS ratings (
  sku VARCHAR(80) NOT NULL,
  avg_rating DECIMAL(3,2) NOT NULL,
  rating_count INT NOT NULL,
  PRIMARY KEY (sku)
) ENGINE=InnoDB;
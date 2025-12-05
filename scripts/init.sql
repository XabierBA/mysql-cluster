-- Crear usuario para aplicaciones
CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'%' WITH GRANT OPTION;

-- Crear usuario para HAProxy health checks
CREATE USER IF NOT EXISTS 'haproxy_check'@'%' IDENTIFIED BY '';
FLUSH PRIVILEGES;

-- Crear base de datos de prueba
CREATE DATABASE IF NOT EXISTS test_cluster;
USE test_cluster;

CREATE TABLE IF NOT EXISTS cluster_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    node_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data VARCHAR(255)
) ENGINE=InnoDB;
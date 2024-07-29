create database user_auth;
use user_auth;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    checkInTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

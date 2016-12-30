CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS systems(
       id INT(11) NOT NULL AUTO_INCREMENT,
       name VARCHAR(255),
       template VARCHAR(60),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       completion_count INT(11) DEFAULT 0,
       PRIMARY KEY (id)
) engine=InnoDB
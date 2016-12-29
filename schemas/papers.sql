CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS papers(
       id INT(11) NOT NULL AUTO_INCREMENT,
       name VARCHAR(255),
       link VARCHAR(255),
       description TEXT,
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (id)
) engine=InnoDB

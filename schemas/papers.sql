CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS papers(
       id INT(11) NOT NULL AUTO_INCREMENT,
       name VARCHAR(255),
       link VARCHAR(255),
       description TEXT,
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       read_count INT(11) DEFAULT 0,
       rating TINYINT DEFAULT 0,
       year SMALLINT DEFAULT 0,
       topic VARCHAR(255),
       PRIMARY KEY (id)
) engine=InnoDB;
CREATE INDEX trindex on papers (topic, rating);
CREATE INDEX rindex on papers (rating);

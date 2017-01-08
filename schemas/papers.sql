CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS papers(
       id VARCHAR(36) NOT NULL,
       pos INT(11) DEFAULT 0,
       name VARCHAR(255),
       link VARCHAR(255),
       description TEXT,
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       read_count INT(11) DEFAULT 0,
       rating TINYINT DEFAULT 0,
       year SMALLINT DEFAULT 0,
       topic VARCHAR(255),
       slug VARCHAR(255),
       PRIMARY KEY (id)
) engine=InnoDB;
CREATE INDEX pindex on papers (pos);
CREATE INDEX trindex on papers (topic, rating, pos);
CREATE INDEX rindex on papers (rating, pos);
CREATE INDEX sindex on papers (slug);

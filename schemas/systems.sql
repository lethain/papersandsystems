CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS systems(
       id VARCHAR(36) NOT NULL,
       pos INT(11) DEFAULT 0,       
       name VARCHAR(255),
       template VARCHAR(60),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       completion_count INT(11) DEFAULT 0,
       PRIMARY KEY (id)
) engine=InnoDB;
CREATE INDEX pindex on systems (pos);
CREATE INDEX tindex on systems (template);
CREATE INDEX cindex on systems (completion_count);

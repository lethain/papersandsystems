CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS system_papers(
       id INT(11) NOT NULL AUTO_INCREMENT,
       paper_id VARCHAR(36),
       system_id VARCHAR(36),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (id),
       UNIQUE (paper_id, system_id)
) engine=InnoDB;
CREATE INDEX spindex ON system_papers (paper_id, system_id);
CREATE INDEX psindex ON system_papers (system_id, paper_id);

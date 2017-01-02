CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS user_papers(
       id INT(11) NOT NULL AUTO_INCREMENT,
       paper_id INT(11),
       user_id INT(11),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       rating TINYINT DEFAULT 0,
       PRIMARY KEY (id),
       UNIQUE (paper_id, user_id)
) engine=InnoDB;
CREATE INDEX puindex ON user_papers (paper_id, user_id);
CREATE INDEX upindex ON user_papers (user_id, paper_id);

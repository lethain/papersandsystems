CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS problem_papers(
       id INT(11) NOT NULL AUTO_INCREMENT,
       paper_id INT(11),
       problem_id INT(11),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (id),
       UNIQUE (paper_id, problem_id)
) engine=InnoDB

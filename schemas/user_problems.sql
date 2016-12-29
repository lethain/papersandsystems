CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS user_problems(
       id INT(11) NOT NULL AUTO_INCREMENT,
       user_id INT(11),
       problem_id INT(11),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (id),
       UNIQUE (user_id, problem_id)
) engine=InnoDB

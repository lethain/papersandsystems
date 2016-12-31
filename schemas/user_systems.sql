CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS user_systems(
       id INT(11) NOT NULL AUTO_INCREMENT,
       user_id INT(11),
       system_id INT(11),
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (id),
       UNIQUE (user_id, system_id)
) engine=InnoDB;
CREATE INDEX usindex ON user_systems (user_id, system_id);

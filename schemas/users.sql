CREATE DATABASE IF NOT EXISTS papers;
USE papers;
CREATE TABLE IF NOT EXISTS users(
       id INT(11) NOT NULL,
       access_token VARCHAR(64),
       login VARCHAR(64),
       avatar VARCHAR(128),
       email VARCHAR(128),
       is_admin BOOLEAN NOT NULL DEFAULT 0,
       ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       PRIMARY KEY (id)
) engine=InnoDB

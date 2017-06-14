/*
 * Create root user that will be accessible from the outside
 */
SET @USERNAME = 'root';
SET @PASSWORD = 'root';

SET @query = CONCAT('GRANT ALL PRIVILEGES ON *.* TO \'', @USERNAME, '\'@\'%\' IDENTIFIED BY \'', @PASSWORD, '\'');
PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
FLUSH PRIVILEGES;

/*
 * Create database schema/tables/... (depends on your needs)
 * NOTE: This statements will be executed every time instance is (re)started.
 */
CREATE SCHEMA `default` DEFAULT CHARACTER SET utf8;

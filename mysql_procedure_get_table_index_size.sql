DROP PROCEDURE IF EXISTS mysql.proc_pmm_update_table_index_size;
delimiter //
CREATE PROCEDURE mysql.proc_pmm_update_table_index_size ()
BEGIN
DECLARE inf_datalength INT;
DECLARE pmm_datalenght INT;
DECLARE inf_indexlenght INT;
DECLARE databasename VARCHAR(64);
DECLARE done INT DEFAULT 0;
DECLARE databases_list CURSOR FOR SELECT DISTINCT(TABLE_SCHEMA) FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ('information_schema','mysql','performance_schema','sys');
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
OPEN databases_list;
databases_loop: LOOP
FETCH databases_list INTO databasename;
IF done THEN
LEAVE databases_loop;
END IF;
	BLOCK2: BEGIN
  DECLARE tablename VARCHAR(64);
	DECLARE done INT DEFAULT 0;
	DECLARE tables_list CURSOR FOR SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = databasename;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	OPEN tables_list;
	tables_loop: LOOP
	FETCH tables_list INTO tablename;
  IF done THEN
    LEAVE tables_loop;
  END IF;
   	SELECT IFNULL(DATA_LENGTH,0),IFNULL(INDEX_LENGTH,0) INTO inf_datalength,inf_indexlenght FROM information_schema.TABLES WHERE BINARY TABLE_SCHEMA = databasename AND BINARY TABLE_NAME = tablename;
   	SELECT DATA_LENGTH INTO pmm_datalenght FROM mysql.pmm_custom_informations_data_index_size WHERE BINARY TABLE_SCHEMA = databasename AND BINARY TABLE_NAME = tablename;
   	IF(pmm_datalenght IS NULL) THEN
      SET done = 0;
		  INSERT INTO mysql.pmm_custom_informations_data_index_size (TABLE_SCHEMA,TABLE_NAME,DATA_LENGTH, INDEX_LENGTH) VALUES (databasename,tablename,inf_datalength,inf_indexlenght);
		ELSE
			IF inf_datalength != pmm_datalenght
			THEN
			SELECT 'Màj';
		   UPDATE mysql.pmm_custom_informations_data_index_size SET DATA_LENGTH = inf_datalength, INDEX_LENGTH = inf_indexlenght WHERE BINARY TABLE_SCHEMA = databasename AND BINARY TABLE_NAME = tablename;
			END IF;
		END IF;
	END LOOP;
	CLOSE tables_list;
	END BLOCK2;
END LOOP;
CLOSE databases_list;
END //
delimiter ;
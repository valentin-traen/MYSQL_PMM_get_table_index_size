# pmm_get_table_index_size
Get size of table and indexes on MySQL instances with many tables

By default, table metrics are disabled in PMM if there are more than 1000 tables. It's due to the way that information_schema works.
All informations can be found here : https://dev.mysql.com/doc/refman/5.5/en/information-schema-optimization.html


You'll found a MySQL PROCEDURE in this repository to get the size of your tables and the size of the indexes (test an schema with more than 20 000 tables). You can call it for example with an EVENT.

In my case, I've created a table in mysql schema :

```sql
DROP TABLE IF EXISTS mysql.pmm_custom_informations_data_index_size;
CREATE TABLE mysql.pmm_custom_informations_data_index_size (id INT NOT NULL AUTO_INCREMENT,TABLE_SCHEMA VARCHAR(64),TABLE_NAME VARCHAR(64),DATA_LENGTH INT,INDEX_LENGTH INT, PRIMARY KEY (id));
```

This table is feed by the PROCEDURE mysql.proc_pmm_update_table_index_size.

Don't forget to GRANT your pmm user :

```sql
GRANT EXECUTE ON PROCEDURE mysql.proc_pmm_update_table_index_size TO 'pmm'@'localhost';
GRANT UPDATE, INSERT ON mysql.* TO 'pmm'@'localhost';
```

Dont' forget to update your queries-mysqld.yml.

Of course the execution of the PROCEDURE can be longer than the execution of the full query BUT all the queries run by the PROCEDURE are optimized. You will not have peak RAM or CPU usage with this method unlike the other.

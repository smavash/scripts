SELECT
application_id, DESCRIPTIVE_FLEXFIELD_NAME, application_table_name
--*
FROM
fnd_descriptive_flexs_vl
WHERE
--APPLICATION_TABLE_NAME like '%' || upper('&tab_name') || '%'
creation_date > sysdate - 1 or last_update_date > sysdate -10
ORDER BY APPLICATION_TABLE_NAME


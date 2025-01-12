SELECT DISTINCT
    p.sql_id,
    TO_TIMESTAMP(s.first_load_time, 'yyyy-mm-dd hh24:mi:ss') AS timestamp,
    s.executions AS no_of_executions,
    ROUND(s.elapsed_time / 1000000, 2) AS elapsed_time_seconds,
	DBMS_LOB.SUBSTR(s.sql_fulltext, 4000) AS full_sql_text -- Limiting to 4000 characters for display
FROM V$SQL_PLAN p
JOIN V$SQL s ON p.sql_id = s.sql_id
WHERE
	p.operation = 'TABLE ACCESS' AND
    p.options = 'FULL' AND
   p.object_owner NOT IN (
        'ANONYMOUS', 'APEX_040200', 'APEX_PUBLIC_USER', 'APPQOSSYS', 'AUDSYS', 'BI', 'CTXSYS', 'DBSNMP', 'DIP', 'DVF', 'DVSYS', 'EXFSYS',
        'FLOWS_FILES', 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER', 'HR', 'IX', 'LBACSYS', 'MDDATA', 'MDSYS', 'OE', 'ORACLE_OCM', 'ORDDATA',
        'ORDPLUGINS', 'ORDSYS', 'OUTLN', 'PM', 'SCOTT', 'SH', 'SI_INFORMTN_SCHEMA', 'SPATIAL_CSW_ADMIN_USR', 'SPATIAL_WFS_ADMIN_USR', 'SYS',
        'SYSBACKUP', 'SYSDG', 'SYSKM', 'SYSTEM', 'WMSYS', 'XDB', 'SYSMAN', 'RMAN', 'RMAN_BACKUP', 'OWBSYS', 'OWBSYS_AUDIT', 'APEX_030200',
        'MGMT_VIEW', 'OJVMSYS'
    )
ORDER BY timestamp DESC;

WITH
-- Step 1: Filter active session history for relevant SQL and wait events
ash_data AS (
    SELECT 
        ash.sample_time,
        ash.sql_id,
        ash.event,
        ash.wait_class,
        ash.p1 AS file_id,
        ash.p2 AS block_id,
        ash.p3 AS blocks,
        ash.time_waited / 1000 AS time_waited_ms, -- Convert time waited to milliseconds
        ash.current_obj# AS obj#,
        CASE 
            WHEN ash.wait_class = 'CPU' THEN ash.time_waited
            ELSE 0
        END AS cpu_time_ms,
        CASE 
            WHEN ash.wait_class = 'Cluster' THEN ash.time_waited
            ELSE 0
        END AS cluster_wait_time_ms
    FROM 
        dba_hist_active_sess_history ash
    WHERE 
        ash.sql_id = '&sql_id'
        AND ash.sample_time BETWEEN TO_DATE('05/01/25', 'DD/MM/YY') 
                              AND TO_DATE('06/01/25', 'DD/MM/YY')
        AND ash.event IS NOT NULL
),
-- Step 2: Aggregate wait event times and calculate percentages
wait_time_agg AS (
    SELECT 
        sql_id,
        SUM(cpu_time_ms) AS total_cpu_time_ms,
        SUM(cluster_wait_time_ms) AS total_cluster_wait_time_ms,
        SUM(time_waited_ms) AS total_wait_time_ms
    FROM 
        ash_data
    GROUP BY 
        sql_id
),
-- Step 3: Fetch object details
object_details AS (
    SELECT 
        obj.object_id AS obj#,
        obj.owner,
        obj.object_name,
        obj.object_type
    FROM 
        dba_objects obj
),
-- Step 4: Aggregate segment statistics
segment_stats AS (
    SELECT 
        seg_stat.obj#,
        SUM(seg_stat.physical_reads_delta) AS total_physical_reads,
        SUM(seg_stat.physical_writes_delta) AS total_physical_writes,
        SUM(seg_stat.buffer_busy_waits_delta) AS total_buffer_busy_waits
    FROM 
        dba_hist_seg_stat seg_stat
    WHERE 
        seg_stat.obj# IS NOT NULL
    GROUP BY 
        seg_stat.obj#
),
-- Combine ASH, Object Details, Segment Statistics, and Wait Time Aggregates
combined_data AS (
    SELECT 
        a.sample_time,
        a.sql_id,
        a.event,
        a.wait_class,
        a.file_id,
        a.block_id,
        a.blocks,
        a.time_waited_ms,
        obj.owner,
        obj.object_name,
        obj.object_type,
        stats.total_physical_reads,
        stats.total_physical_writes,
        stats.total_buffer_busy_waits,
        agg.total_cpu_time_ms,
        agg.total_cluster_wait_time_ms,
        agg.total_wait_time_ms
    FROM 
        ash_data a
    LEFT JOIN 
        object_details obj
    ON 
        a.obj# = obj.obj#
    LEFT JOIN 
        segment_stats stats
    ON 
        a.obj# = stats.obj#
    LEFT JOIN 
        wait_time_agg agg
    ON 
        a.sql_id = agg.sql_id
),
-- Include data from GV$SQL
sql_data AS (
    SELECT 
        s.module,
        s.parsing_schema_name,
        s.inst_id,
        s.sql_id,
        s.plan_hash_value,
        s.child_number,
        s.sql_fulltext,
        TO_CHAR(s.last_active_time, 'DD/MM/YY HH24:MI:SS') AS last_active_time,
        s.sql_plan_baseline,
        s.executions,
        CASE 
            WHEN s.executions > 0 THEN s.elapsed_time / s.executions / 1000 / 1000
            ELSE NULL
        END AS elapsed_time_per_execution_seconds,
        s.rows_processed
    FROM 
        gv$sql s
    WHERE 
        s.sql_id = '&sql_id'
),
final_data AS (
    SELECT 
        c.sample_time AS "Sample Time",
        c.sql_id AS "SQL ID",
        c.event AS "Event",
        c.wait_class AS "Wait Class",
        c.file_id AS "File ID",
        c.block_id AS "Block ID",
        c.blocks AS "Blocks",
        c.owner AS "Owner",
        c.object_name AS "Object Name",
        c.object_type AS "Object Type",
        c.total_physical_reads AS "Total Reads",
        c.total_physical_writes AS "Total Writes",
        c.total_buffer_busy_waits AS "Buffer Busy Waits",
        CASE 
            WHEN c.total_wait_time_ms > 0 THEN c.total_cpu_time_ms / c.total_wait_time_ms * 100
            ELSE 0
        END AS "CPU Time %",
        CASE 
            WHEN c.total_wait_time_ms > 0 THEN c.total_cluster_wait_time_ms / c.total_wait_time_ms * 100
            ELSE 0
        END AS "Cluster Wait Time %",
        s.module AS "Module",
        s.parsing_schema_name AS "Parsing Schema",
        s.inst_id AS "Instance ID",
        s.plan_hash_value AS "Plan Hash Value",
        s.child_number AS "Child Number",
        s.sql_fulltext AS "SQL Text",
        s.last_active_time AS "Last Active Time",
        s.sql_plan_baseline AS "SQL Plan Baseline",
        s.executions AS "Executions",
        s.elapsed_time_per_execution_seconds AS "Elapsed Time Per Execution (s)",
        s.rows_processed AS "Rows Processed"
    FROM 
        combined_data c
    LEFT JOIN 
        sql_data s
    ON 
        c.sql_id = s.sql_id
)
SELECT 
    * 
FROM 
    final_data
ORDER BY 
    "Sample Time" DESC;

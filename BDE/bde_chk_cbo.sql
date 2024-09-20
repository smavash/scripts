SET TERM OFF VER OFF TRIMS ON SERVEROUTPUT ON SIZE 1000000 FEED OFF;

VAR v_cpu_count          VARCHAR2(10);
VAR v_database           VARCHAR2(40);
VAR v_host               VARCHAR2(40);
VAR v_instance           VARCHAR2(40);
VAR v_platform           VARCHAR2(40);
VAR v_rdbms_release      VARCHAR2(17);
VAR v_rdbms_version      VARCHAR2(10);
VAR v_sysdate            VARCHAR2(15);
VAR v_apps_release       VARCHAR2(50);

CL BRE COL COMP;
COL p_cpu_count          NEW_V p_cpu_count          FOR A10;
COL p_database           NEW_V p_database           FOR A40;
COL p_host               NEW_V p_host               FOR A40;
COL p_instance           NEW_V p_instance           FOR A40;
COL p_platform           NEW_V p_platform           FOR A40;
COL p_rdbms_release      NEW_V p_rdbms_release      FOR A17;
COL p_rdbms_version      NEW_V p_rdbms_version      FOR A10;
COL p_sysdate            NEW_V p_sysdate            FOR A15;
COL p_apps_release       NEW_V p_apps_release       FOR A50;

COL current_value               FOR A25;
COL default_value               FOR A25;
COL name                        FOR A35;
COL required_value              FOR A25;
COL value                       FOR A100;


SET TERM ON;
PRO Creating staging objects...
SET TERM OFF;

BEGIN
    SELECT SUBSTR( UPPER( i.host_name ),1,40 ),
           SUBSTR( i.version,1,17 ),
           SUBSTR( UPPER( db.name )||'('||TO_CHAR( db.dbid )||')',1,40 ),
           SUBSTR( UPPER( i.instance_name )||'('||TO_CHAR( i.instance_number )||')',1,40 )
      INTO :v_host, :v_rdbms_release, :v_database, :v_instance
      FROM v$database db,
           v$instance i;

    :v_rdbms_version := :v_rdbms_release;
    IF :v_rdbms_release LIKE '%8%.%1%.%7%' THEN :v_rdbms_version := '8.1.7'; END IF;
    IF :v_rdbms_release LIKE '%9%.%0%.%1%' THEN :v_rdbms_version := '9.0.1'; END IF;
    IF :v_rdbms_release LIKE '%9%.%2%.%0%' THEN :v_rdbms_version := '9.2.0'; END IF;
    IF :v_rdbms_release LIKE '%10%.%1%.%0%' THEN :v_rdbms_version := '10.1.0'; END IF;

    SELECT SUBSTR( REPLACE( REPLACE( pcv1.product,'TNS for '),':' )||pcv2.status,1,40 )
      INTO :v_platform
      FROM product_component_version pcv1,
           product_component_version pcv2
     WHERE UPPER( pcv1.product ) LIKE '%TNS%'
       AND UPPER( pcv2.product ) LIKE '%ORACLE%'
       AND ROWNUM = 1;

    SELECT TO_CHAR( SYSDATE,'DD-MON-YY HH24:MI')
      INTO :v_sysdate
      FROM dual;

    SELECT SUBSTR( value,1,10 )
      INTO :v_cpu_count
      FROM v$parameter
     WHERE name = 'cpu_count';

    SELECT release_name
      INTO :v_apps_release
      FROM fnd_product_groups;
END;
/

SELECT :v_cpu_count     p_cpu_count,
       :v_database      p_database,
       :v_host          p_host,
       :v_instance      p_instance,
       :v_platform      p_platform,
       :v_rdbms_release p_rdbms_release,
       :v_rdbms_version p_rdbms_version,
       :v_sysdate       p_sysdate,
       :v_apps_release  p_apps_release
  FROM DUAL;


DROP   TABLE bde$parameter_apps;
CREATE TABLE bde$parameter_apps
(
  name                       VARCHAR2(64),
  required_value             VARCHAR2(512),
  default_value              VARCHAR2(512)
 );

CREATE OR REPLACE PROCEDURE bde$parameters
( rdbms_version_in     IN VARCHAR2
 )
IS
    PROCEDURE ins
    ( name_in              VARCHAR2,
      required_value_in    VARCHAR2,
      default_value_in     VARCHAR2
     )
    IS
    BEGIN /* ins */
        INSERT INTO bde$parameter_apps
        VALUES
        ( name_in,
          required_value_in,
          default_value_in
         );
    END ins;

BEGIN /* bde$parameters */

    INS( 'compatible',                           rdbms_version_in||' #MP',  'none' );
    INS( 'optimizer_features_enable',            rdbms_version_in||' #MP',  'none' );

    IF  rdbms_version_in IN ( '8.1.7','9.0.1','9.2.0','10.1.0' ) THEN
        INS( '_fast_full_scan_enabled',          'FALSE #MP',               'TRUE' );
        INS( '_like_with_bind_as_equality',      'TRUE #MP',                'FALSE' );
        INS( '_sort_elimination_cost_ratio',     '5 #MP',                   '0' );
        INS( '_sortmerge_inequality_join_off',   '<DO NOT SET>',            'FALSE' );
        INS( '_sqlexec_progression_cost',        '2147483647 #MP',          '1000' );
        INS( '_system_trig_enabled',             'TRUE #MP',                'TRUE' );
        INS( '_trace_files_public',              'TRUE',                    'FALSE' );
        INS( '_unnest_subquery',                 '<DO NOT SET>',            'TRUE' );
        INS( 'always_anti_join',                 '<DO NOT SET>',            'NESTED_LOOPS or STANDARD' );
        INS( 'always_semi_join',                 '<DO NOT SET>',            'NESTED_LOOPS or STANDARD' );
        INS( 'aq_tm_processes',                  '1',                       '0' );
        INS( 'background_dump_dest',             '?/prod11i/bdump',         'os dependent' );
        INS( 'core_dump_dest',                   '?/prod11i/cdump',         'os dependent' );
        INS( 'cursor_sharing',                   'EXACT #MP',               'EXACT' );
        INS( 'cursor_space_for_time',            'FALSE #SZ',               'FALSE' );
        INS( 'db_block_checking',                'FALSE',                   'FALSE' );
        INS( 'db_block_size',                    '8192 #MP',                '2048' );
        INS( 'db_file_multiblock_read_count',    '8 #MP',                   '8' );
        INS( 'db_files',                         '512',                     '200' );
        INS( 'dml_locks',                        '10000',                   '4x transactions' );
        INS( 'enqueue_resources',                '32000',                   'derived' );
        INS( 'job_queue_processes',              '2',                       '0' );
        INS( 'log_checkpoint_interval',          '100000',                  'os dependent' );
        INS( 'log_checkpoint_timeout',           '1200 (20 mins)',          '900' );
        INS( 'log_checkpoints_to_alert',         'TRUE',                    'FALSE' );
        INS( 'nls_comp',                         'BINARY #MP',              'BINARY' );
        INS( 'nls_date_format',                  'DD-MON-RR #MP',           'derived' );
        INS( 'nls_language',                     'AMERICAN',                'derived' );
        INS( 'nls_numeric_characters',           '".,"',                    'derived' );
        INS( 'nls_sort',                         'BINARY #MP',              'derived' );
        INS( 'nls_territory',                    'AMERICA',                 'os dependent' );
        INS( 'open_cursors',                     '600',                     '50' );
        INS( 'optimizer_index_caching',          '<DO NOT SET>',            '0' );
        INS( 'optimizer_index_cost_adj',         '<DO NOT SET>',            '100' );
        INS( 'optimizer_percent_parallel',       '<DO NOT SET>',            '0' );
        INS( 'parallel_max_servers',             '8 (<= 2x cpu_count)',     'derived' );
        INS( 'parallel_min_percent',             NULL,                      '0' );
        INS( 'parallel_min_servers',             '0',                       '0' );
        INS( 'parallel_threads_per_cpu',         NULL,                      '2' );
        INS( 'processes',                        '200+ #SZ',                'derived' );
        INS( 'query_rewrite_enabled',            'TRUE #MP',                'FALSE' );
        INS( 'session_cached_cursors',           '200',                     '0' );
        INS( 'sessions',                         '400+ #SZ',                'derived' );
        INS( 'sql_trace',                        'FALSE',                   'FALSE' );
        INS( 'timed_statistics',                 'TRUE',                    'FALSE' );
        INS( 'user_dump_dest',                   '?/prod11i/udump',         'os dependent' );
        INS( 'utl_file_dir',                     '?/prod11i/utl_file_dir',  'none' );
    END IF;

    IF  rdbms_version_in IN ( '9.0.1','9.2.0','10.1.0' ) THEN
        INS( '_always_anti_join',                '<DO NOT SET>',            'CHOOSE' );
        INS( '_always_semi_join',                '<DO NOT SET>',            'CHOOSE' );
        INS( '_complex_view_merging',            '<DO NOT SET>',            'TRUE' );
        INS( '_new_initial_join_orders',         '<DO NOT SET>',            'TRUE' );
        INS( '_optimizer_mode_force',            '<DO NOT SET>',            'FALSE' );
        INS( '_optimizer_undo_changes',          '<DO NOT SET FOR 11i>',    'FALSE' );
        INS( '_or_expand_nvl_predicate',         '<DO NOT SET>',            'TRUE' );
        INS( '_ordered_nested_loop',             '<DO NOT SET>',            'TRUE' );
        INS( '_push_join_predicate',             '<DO NOT SET>',            'TRUE' );
        INS( '_push_join_union_view',            '<DO NOT SET>',            'TRUE' );
        INS( '_use_column_stats_for_function',   '<DO NOT SET>',            'TRUE' );
        INS( 'db_block_buffers',                 '<DO NOT SET>',            '48 MB' );
        INS( 'db_block_checksum',                'TRUE',                    'TRUE' );
        INS( 'hash_area_size',                   '<DO NOT SET>',            '2x sort_area_size' );
        INS( 'job_queue_interval',               '<DO NOT SET>',            '60' );
        INS( 'max_dump_file_size',               '20480 #MP (10M)',         'UNLIMITED' );
        INS( 'nls_length_semantics',             'BYTE #MP',                'BYTE' );
        INS( 'o7_dictionary_accessibility',      'TRUE #MP',                'FALSE' );
        INS( 'pga_aggregate_target',             '1G+ #SZ',                 '0' );
        INS( 'rollback_segments',                '<DO NOT SET>',            'public rbs' );
        INS( 'sort_area_size',                   '<DO NOT SET>',            '65530' );
        INS( 'undo_management',                  'AUTO #MP',                'MANUAL' );
        INS( 'undo_tablespace',                  'APPS_UNDOTS1 #MP',        'first available' );
        INS( 'workarea_size_policy',             'AUTO #MP',                'derived' );
    END IF;

    IF  rdbms_version_in IN ( '8.1.7','9.0.1','9.2.0' ) THEN
        INS( '_shared_pool_reserved_min_alloc',  '4100',                    '5000' );
        INS( 'java_pool_size',                   '52428800 (50M)',          '20000K' );
        INS( 'log_buffer',                       '10485760 (10M)',          '524288' );
        INS( 'max_enabled_roles',                '100 #MP',                 '20' );
        INS( 'optimizer_mode',                   'CHOOSE <FOR 11i> #MP',    'CHOOSE' );
        INS( 'row_locking',                      'ALWAYS #MP',              'ALWAYS' );
        INS( 'shared_pool_reserved_size',        '30M+ #SZ',                '5% shared_pool' );
        INS( 'shared_pool_size',                 '300M+ #SZ',               '16 or 64 MB' );
    END IF;

    IF  rdbms_version_in IN ( '9.2.0','10.1.0' ) THEN
        INS( '_table_scan_cost_plus_one',        '<DO NOT SET>',            'FALSE' );
    END IF;

    IF  rdbms_version_in IN ( '9.0.1','9.2.0' ) THEN
        INS( '_b_tree_bitmap_plans',             'FALSE #MP',               'TRUE' );
        INS( '_index_join_enabled',              'FALSE #MP',               'TRUE' );
        INS( 'db_cache_size',                    '156M+ #SZ',               '48M' );
        INS( 'optimizer_max_permutations',       '2000 #MP',                '2000' );
        INS( 'undo_retention',                   '1800+ #SZ',               '900' );
        INS( 'undo_suppress_errors',             'FALSE #MP',               'FALSE' );
    END IF;

    IF  rdbms_version_in IN ( '8.1.7','9.0.1' ) THEN
        INS( '_table_scan_cost_plus_one',        'TRUE #MP',                'FALSE' );
    END IF;

    IF  rdbms_version_in = '8.1.7' THEN
        INS( '_b_tree_bitmap_plans',             '<DO NOT SET>',            'FALSE' );
        INS( '_complex_view_merging',            'TRUE #MP',                'FALSE' );
        INS( '_index_join_enabled',              '<DO NOT SET>',            'FALSE' );
        INS( '_new_initial_join_orders',         'TRUE #MP',                'FALSE' );
        INS( '_optimizer_mode_force',            'TRUE #MP',                'FALSE' );
        INS( '_optimizer_undo_changes',          '<FALSE FOR 11i> #MP',     'FALSE' );
        INS( '_or_expand_nvl_predicate',         'TRUE #MP',                'TRUE' );
        INS( '_ordered_nested_loop',             'TRUE #MP',                'FALSE' );
        INS( '_push_join_predicate',             'TRUE #MP',                'FALSE' );
        INS( '_push_join_union_view',            'TRUE #MP',                'FALSE' );
        INS( '_use_column_stats_for_function',   'TRUE #MP',                'TRUE' );
        INS( 'db_block_buffers',                 '20000+ #SZ',              '48 MB' );
        INS( 'db_block_checksum',                'TRUE',                    'FALSE' );
        INS( 'hash_area_size',                   '2097152 (2M)',            '2x sort_area_size' );
        INS( 'job_queue_interval',               '90',                      '60' );
        INS( 'max_dump_file_size',               '20480 #MP (10M)',         '10240 (5M)' );
        INS( 'o7_dictionary_accessibility',      'TRUE #MP',                'TRUE' );
        INS( 'optimizer_max_permutations',       '2000 #MP',                '80000' );
        INS( 'rollback_segments',                '(rbs1,rbs2,rbs3,rbs4,rbs5,rbs6)', 'public rbs' );
        INS( 'sort_area_size',                   '1048576 (1M)',            '65536' );
    END IF;

    IF  rdbms_version_in = '9.0.1' THEN
        NULL;
    END IF;

    IF  rdbms_version_in = '9.2.0' THEN
        NULL;
    END IF;

    IF  rdbms_version_in = '10.1.0' THEN
        INS( '_b_tree_bitmap_plans',             '<DO NOT SET>',            'TRUE' );
        INS( '_index_join_enabled',              '<DO NOT SET>',            'TRUE' );
        INS( '_optimizer_cost_based_transformation', 'linear #MP',          'none' );
        INS( '_optimizer_cost_model',            'cpu #MP',                 'none' );
        INS( '_shared_pool_reserved_min_alloc',  '<DO NOT SET>',            '5000' );
        INS( 'db_cache_size',                    '<DO NOT SET>',            '48M' );
        INS( 'java_pool_size',                   '<DO NOT SET>',            '20000K' );
        INS( 'large_pool_size',                  '<DO NOT SET>',            '0' );
        INS( 'log_buffer',                       '<DO NOT SET>',            '524288' );
        INS( 'max_enabled_roles',                '<DO NOT SET>',            '20' );
        INS( 'optimizer_dynamic_sampling',       '2 #MP',                   'none' );
        INS( 'optimizer_max_permutations',       '<DO NOT SET>',            '2000' );
        INS( 'optimizer_mode',                   'ALL_ROWS <FOR 11i> #MP',  'CHOOSE' );
        INS( 'plsql_code_type',                  'native #MP',              'none' );
        INS( 'plsql_compiler_flags',             '<DO NOT SET>',            'INTERPRETED, NON_DEBUG ' );
        INS( 'plsql_native_library_dir',         '?/prod11i/plsql_nativelib', 'none' );
        INS( 'plsql_optimize_level',             '2 #MP',                   'none' );
        INS( 'row_locking',                      '<DO NOT SET>',            'ALWAYS' );
        INS( 'shared_pool_reserved_size',        '<DO NOT SET>',            '5% shared_pool' );
        INS( 'shared_pool_size',                 '<DO NOT SET>',            '16 or 64 MB' );
        INS( 'sga_target',                       '570M+ #SZ',               'none' );
        INS( 'undo_retention',                   '<DO NOT SET>',            '900' );
        INS( 'undo_suppress_errors',             '<DO NOT SET>',            'FALSE' );
    END IF;

END bde$parameters;
/

EXEC BDE$PARAMETERS( :v_rdbms_version );
DROP PROCEDURE bde$parameters;


DROP   TABLE bde$parameter2;
CREATE TABLE bde$parameter2
(
  name                       VARCHAR2(64),
  type                       NUMBER,
  value                      VARCHAR2(512),
  isdefault                  VARCHAR2(9)
 );

INSERT INTO bde$parameter2
( name ,
  type ,
  value,
  isdefault
 )
SELECT LOWER( name ),
       type         ,
       value        ,
       isdefault
  FROM v$parameter2;


DROP   TABLE bde$events;
CREATE TABLE bde$events
(
  apps_version               VARCHAR2(17),
  required                   VARCHAR2(8),
  value                      VARCHAR2(64)
 );

CREATE OR REPLACE PROCEDURE bde$apps_events
( rdbms_version_in     IN VARCHAR2
 )
IS
    PROCEDURE ins
    ( apps_version_in      VARCHAR2,
      required_in          VARCHAR2,
      value_in             VARCHAR2
     )
    IS
    BEGIN /* ins */
        INSERT INTO bde$events
        VALUES
        ( apps_version_in,
          required_in,
          value_in
         );
    END ins;

BEGIN /* bde$apps_events */

    IF  rdbms_version_in IN ( '8.1.7','9.0.1', '9.2.0', '10.1.0' ) THEN
        INS( '11.5.x',          'UNSET', '10943 trace name context forever, level 2' );
    END IF;

    IF  rdbms_version_in IN ( '9.0.1','9.2.0', '10.1.0' ) THEN
        INS( '11.5.x',          'UNSET', '38004 trace name context forever, level 1' );
    END IF;

    IF  rdbms_version_in = '8.1.7' THEN
        INS( '11.5.x',          'UNSET', '10929 trace name context forever' );
        INS( '11.5.x',          'UNSET', '10932 trace name context level 2' );
    END IF;

    IF  rdbms_version_in = '9.0.1' THEN
        INS( '11.5.x',          'SET',   '10932 trace name context level 32768' );
        INS( '11.5.x',          'SET',   '10933 trace name context level 512' );
        INS( '11.5.x',          'SET',   '10943 trace name context level 16384' );
    END IF;

    IF  rdbms_version_in = '9.2.0' THEN
        INS( '11.5.7 OR PRIOR', 'SET',   '10932 trace name context level 32768' );
        INS( '11.5.7 OR PRIOR', 'SET',   '10933 trace name context level 512' );
        INS( '11.5.7 OR PRIOR', 'SET',   '10943 trace name context level 16384' );
        INS( '11.5.8 OR LATER', 'UNSET', '10932 trace name context level 32768' );
        INS( '11.5.8 OR LATER', 'UNSET', '10933 trace name context level 512' );
        INS( '11.5.8 OR LATER', 'UNSET', '10943 trace name context level 16384' );
    END IF;

    IF  rdbms_version_in = '10.1.0' THEN
        INS( '11.5.x', 'UNSET', '10932 trace name context level 32768' );
        INS( '11.5.x', 'UNSET', '10933 trace name context level 512' );
        INS( '11.5.x', 'UNSET', '10943 trace name context level 16384' );
    END IF;

END bde$apps_events;
/

EXEC BDE$APPS_EVENTS( :v_rdbms_version );
DROP PROCEDURE bde$apps_events;


SET TERM ON;
PRO Creating report bde_chk_cbo.txt...
SET TERM OFF;

SPO bde_chk_cbo.txt;
SET TERM OFF VER OFF TRIMS ON SERVEROUTPUT ON SIZE 1000000 FEED OFF;
SET LIN 255 PAGES 255;
PRO bde_chk_cbo.txt
PRO
PRO CURRENT, REQUIRED AND RECOMMENDED APPS 11I INIT.ORA PARAMETERS
PRO ==============================================================
PRO
PRO SYSDATE          = &&p_sysdate
PRO
PRO HOST             = &&p_host
PRO PLATFORM         = &&p_platform
PRO DATABASE         = &&p_database
PRO INSTANCE         = &&p_instance
PRO RDBMS_RELEASE    = &&p_rdbms_release(&&p_rdbms_version)
PRO APPS_RELEASE     = &&p_apps_release
PRO CPU_COUNT        = &&p_cpu_count
PRO

PRO
PRO APPS RELATED
PRO ============
BRE ON name;
SELECT                                                           bpa.name,
       NVL( UPPER( bp2.value ),'<NOT SET>' )                     current_value,
                                                                 bpa.required_value,
                                                                 bpa.default_value
  FROM bde$parameter_apps bpa,
       bde$parameter2     bp2
 WHERE bpa.name            = bp2.name(+)
 ORDER BY
       bpa.name,
       bp2.value;
PRO
PRO #MP: Mandatory Parameter and Value
PRO #SZ: Size corresponding to small instance used for development or testing (<10 users).  For larger environments review Note 216205.1.
PRO

PRO
PRO OTHER PARAMETERS SET
PRO ====================
BRE ON name;
SELECT                                                           bp2.name,
                                                                 bp2.value
  FROM bde$parameter2 bp2
 WHERE bp2.isdefault    = 'FALSE'
   AND NOT EXISTS
       ( SELECT NULL
           FROM bde$parameter_apps bpa
          WHERE bpa.name          = bp2.name
        )
 ORDER BY
       bp2.name,
       bp2.value;

PRO
PRO
PRO APPS REQUIRED EVENTS
PRO ====================
CL BRE;
SELECT                                                           apps_version,
                                                                 required,
                                                                 value
  FROM bde$events
 ORDER BY
       apps_version,
       required,
       value;


SPO OFF;

SET TERM OFF;
DROP TABLE bde$parameter_apps;
DROP TABLE bde$parameter2;
DROP TABLE bde$events;
CL BRE COL COMP;
SET TERM ON VER ON TRIMS OFF PAGES 24 LIN 80 SERVEROUTPUT OFF FEED ON;

EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'APPS', tabname => 'COE_SCHEMAS');
ANALYZE TABLE APPS.COE_SCHEMAS ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'APPS',tabname=>'COE_SCHEMAS',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'APPS', tabname => 'COE_TABLES');
ANALYZE TABLE APPS.COE_TABLES ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'APPS',tabname=>'COE_TABLES',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'APPS', tabname => 'MTL_ONHAND_DISCREPANCY');
ANALYZE TABLE APPS.MTL_ONHAND_DISCREPANCY ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'APPS',tabname=>'MTL_ONHAND_DISCREPANCY',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'APPS', tabname => 'TEMP_DISC_INV_CG_LOOSE');
ANALYZE TABLE APPS.TEMP_DISC_INV_CG_LOOSE ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'APPS',tabname=>'TEMP_DISC_INV_CG_LOOSE',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'APPS', tabname => 'TEMP_DISC_INV_LOOSE');
ANALYZE TABLE APPS.TEMP_DISC_INV_LOOSE ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'APPS',tabname=>'TEMP_DISC_INV_LOOSE',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_FORUM_MESSAGES_TL_N4$I');
ANALYZE TABLE CS.DR$CS_FORUM_MESSAGES_TL_N4$I ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_FORUM_MESSAGES_TL_N4$I',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_FORUM_MESSAGES_TL_N4$K');
ANALYZE TABLE CS.DR$CS_FORUM_MESSAGES_TL_N4$K ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_FORUM_MESSAGES_TL_N4$K',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_FORUM_MESSAGES_TL_N4$N');
ANALYZE TABLE CS.DR$CS_FORUM_MESSAGES_TL_N4$N ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_FORUM_MESSAGES_TL_N4$N',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_FORUM_MESSAGES_TL_N4$P');
ANALYZE TABLE CS.DR$CS_FORUM_MESSAGES_TL_N4$P ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_FORUM_MESSAGES_TL_N4$P',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_FORUM_MESSAGES_TL_N4$R');
ANALYZE TABLE CS.DR$CS_FORUM_MESSAGES_TL_N4$R ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_FORUM_MESSAGES_TL_N4$R',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_ELEMENTS_TL_N1$I');
ANALYZE TABLE CS.DR$CS_KB_ELEMENTS_TL_N1$I ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_ELEMENTS_TL_N1$I',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_ELEMENTS_TL_N1$K');
ANALYZE TABLE CS.DR$CS_KB_ELEMENTS_TL_N1$K ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_ELEMENTS_TL_N1$K',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_ELEMENTS_TL_N1$N');
ANALYZE TABLE CS.DR$CS_KB_ELEMENTS_TL_N1$N ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_ELEMENTS_TL_N1$N',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_ELEMENTS_TL_N1$P');
ANALYZE TABLE CS.DR$CS_KB_ELEMENTS_TL_N1$P ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_ELEMENTS_TL_N1$P',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_ELEMENTS_TL_N1$R');
ANALYZE TABLE CS.DR$CS_KB_ELEMENTS_TL_N1$R ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_ELEMENTS_TL_N1$R',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N3$I');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N3$I ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N3$I',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N3$K');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N3$K ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N3$K',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N3$N');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N3$N ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N3$N',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N3$P');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N3$P ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N3$P',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N3$R');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N3$R ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N3$R',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N5$I');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N5$I ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N5$I',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N5$K');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N5$K ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N5$K',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N5$N');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N5$N ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N5$N',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N5$P');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N5$P ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N5$P',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SETS_TL_N5$R');
ANALYZE TABLE CS.DR$CS_KB_SETS_TL_N5$R ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SETS_TL_N5$R',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SOLN_CAT_TL_N1$I');
ANALYZE TABLE CS.DR$CS_KB_SOLN_CAT_TL_N1$I ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SOLN_CAT_TL_N1$I',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SOLN_CAT_TL_N1$K');
ANALYZE TABLE CS.DR$CS_KB_SOLN_CAT_TL_N1$K ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SOLN_CAT_TL_N1$K',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SOLN_CAT_TL_N1$N');
ANALYZE TABLE CS.DR$CS_KB_SOLN_CAT_TL_N1$N ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SOLN_CAT_TL_N1$N',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SOLN_CAT_TL_N1$P');
ANALYZE TABLE CS.DR$CS_KB_SOLN_CAT_TL_N1$P ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SOLN_CAT_TL_N1$P',percent=>10,degree=>1,granularity=>'DEFAULT');
EXEC DBMS_STATS.DELETE_TABLE_STATS(ownname => 'CS', tabname => 'DR$CS_KB_SOLN_CAT_TL_N1$R');
ANALYZE TABLE CS.DR$CS_KB_SOLN_CAT_TL_N1$R ESTIMATE STATISTICS SAMPLE 1 ROWS;
EXEC FND_STATS.GATHER_TABLE_STATS(ownname=>'CS',tabname=>'DR$CS_KB_SOLN_CAT_TL_N1$R',percent=>10,degree=>1,granularity=>'DEFAULT');

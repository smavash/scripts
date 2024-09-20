create index XLA.XXXLA_AE_LINES_N10 on XLA.XLA_AE_LINES (last_update_date)
  tablespace APPS_TS_TX_IDX
  pctfree 10
  initrans 11
  maxtrans 255
  storage
  (
    initial 16K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  ) compute statistics parallel 8;


ALTER INDEX XLA.XXXLA_AE_LINES_N10 NOPARALLEL LOGGING;
  

EXEC FND_STATS.GATHER_TABLE_STATS('XLA','XLA_AE_LINES',ESTIMATE_PERCENT=>50);
EXEC FND_STATS.GATHER_TABLE_STATS('XLA','XLA_AE_HEADERS',ESTIMATE_PERCENT => 100);
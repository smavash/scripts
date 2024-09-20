Select Round(e.value/s.value,5) "Redo Log Ratio"
  From v$sysstat s, v$sysstat e
  Where s.name = 'redo log space requests'
  and e.name = 'redo entries';

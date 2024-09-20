Select index_owner owner, table_name tab, index_name ind,
column_name colu, column_position position
from DBA_IND_COLUMNS
where table_name in ('GL_ACCOUNT_HIERARCHIES'
,'GL_BALANCES'
,'GL_BC_PACKETS'
,'GL_CODE_COMBINATIONS'  
,'GL_CONCURRENCY_CONTROL'
,'GL_POSTING_INTERIM'
,'GL_SUMMARY_INTERIM'
,'GL_TEMPORARY_COMBINATIONS'
,'GL_INTERFACE'
,'GL_JE_BATCHES'
,'GL_JE_HEADERS'
,'GL_JE_LINES'
)
order by 1, 2, 3, 5
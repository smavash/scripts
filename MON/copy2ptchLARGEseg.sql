COPY FROM apps@prod to apps/apps@ptch APPEND xxdba_large_segs_tbl using select s.tablespace_name ts,s.owner,s.segment_name segn,s.segment_type type,round(s.BYTES / 1024 / 1024) sz from dba_segments s where  s.segment_type in ('INDEX', 'TABLE') and s.BYTES / 1024 / 1024 > 500

  SELECT NUMBER_OF_COPIES ,
               NLS_LANGUAGE ,
               NLS_TERRITORY ,
               PRINTER ,
               PRINT_STYLE ,
               COMPLETION_TEXT ,
               OUTPUT_FILE_TYPE ,
               NLS_CODESET ,
               OUTFILE_NODE_NAME,
               OUTFILE_NAME
  FROM FND_CONCURRENT_REQUESTS 
WHERE REQUEST_ID= &REQID
;

SELECT PRINTER_STYLE_NAME ,
                SRW_DRIVER ,
                WIDTH , 
                LENGTH ,
                ORIENTATION
   FROM FND_PRINTER_STYLES
WHERE PRINTER_STYLE_NAME= ( SELECT PRINT_STYLE
                                                                      FROM FND_CONCURRENT_REQUESTS
                                                                   WHERE REQUEST_ID= &REQID 
                                                                   )
;

SELECT PRINTER_DRIVER_NAME,
                USER_PRINTER_DRIVER_NAME ,
                PRINTER_DRIVER_METHOD_CODE ,
                SPOOL_FLAG ,
                SRW_DRIVER ,
                COMMAND_NAME ,
                ARGUMENTS ,
                INITIALIZATION ,
                RESET
   FROM FND_PRINTER_DRIVERS
WHERE PRINTER_DRIVER_NAME =( SELECT PRINTER_DRIVER
                                                                         FROM FND_PRINTER_INFORMATION
                                                                      WHERE PRINTER_STYLE=( SELECT PRINT_STYLE
                                                                                                                             FROM FND_CONCURRENT_REQUESTS
                                                                                                                          WHERE REQUEST_ID= &REQID 
                                                                                                                          )
                                                                           AND PRINTER_TYPE=( SELECT PRINTER_TYPE
                                                                                                                          FROM FND_PRINTER
                                                                                                                       WHERE PRINTER_NAME=( SELECT PRINTER
                                                                                                                                                                              FROM FND_CONCURRENT_REQUESTS
                                                                                                                                                                            WHERE REQUEST_ID= &REQID
                                                                                                                                                                           )
                                                                                                                        )
                                                                     )
;

CREATE PROCEDURE "informix".sp_depura_sc_movhis_old(fecha_depurar DATE);
   define vcuenta char(20);
   let vcuenta = '';
   set isolation to dirty read;
   set lock mode to wait;
   FOREACH cursor_borra WITH HOLD FOR
                select {+INDEX (sc_movhis_old idx_movhis)} cuenta 
                  into vcuenta
                  FROM sc_movhis_old
                  WHERE empresa = '001'
                   AND cuenta between '10000000000' and '99099999999'
                   AND fech_alt =  fecha_depurar
           BEGIN WORK;
              DELETE FROM sc_movhis_old WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
   END FOREACH
END PROCEDURE;
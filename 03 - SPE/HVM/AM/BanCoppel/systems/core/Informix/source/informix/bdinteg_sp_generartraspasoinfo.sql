CREATE PROCEDURE "informix".sp_generartraspasoinfo()
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(60); --Descripcion de retorno

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE error_info           CHAR(60);
	DEFINE vsSQL 				CHAR (1000);
	
	LET vsSQL = '' ;

	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, error_info
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
				LET vDesErr = error_info;
        END IF;
        RETURN v_cod_ret,vDesErr;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/sp_generartraspasoinfo.out";
	--TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = 'PROCESO EXITOSO';
	
---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA	
	  --DESCARGA DE INFORMACION DE LA TABLA DIARO DE LOS BATCH A UN ARCHIVO PLANO.
				LET vsSQL = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/infotraspaso_batch.unl''' || ' DELIMITER ' || '''|''' || 
							' SELECT empresa,secuencia,sucursal,trama,tipomovto,fecha_insert,fecha_insert'||
							' FROM "informix".si_archivoscopdiario '||
							' " > /resplogifx/archivoscartera/altaunica/envios/queryinfotraspaso_batch.sql';
				SYSTEM vsSQL;

				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdinteg /resplogifx/archivoscartera/altaunica/envios/queryinfotraspaso_batch.sql';
				SYSTEM vsSQL;
				
	  --CARGA DE DATOS DEL ARCHIVO PLANO A LA TABLA HISTORIAL CON LA INFORMACION DE BATCH				
				
				LET vsSQL='';
				LET vsSQL = ' echo "LOAD FROM ' || '''/resplogifx/archivoscartera/altaunica/envios/infotraspaso_batch.unl''' || ' DELIMITER ' || '''|''' || 
				' INSERT INTO '||
				' "informix".si_archivoscophist; '||
				' " > /resplogifx/archivoscartera/altaunica/envios/queryinfotraspaso2_batch.sql';
				SYSTEM vsSQL;

				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdinteg /resplogifx/archivoscartera/altaunica/envios/queryinfotraspaso2_batch.sql';
				SYSTEM vsSQL;			

				LET vsSQL = '';
				LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/infotraspaso_batch.unl";
				SYSTEM vsSQL;
				
				LET vsSQL = '';
				LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/queryinfotraspaso_batch.sql";
				SYSTEM vsSQL;					
				
				LET vsSQL = '';
				LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/queryinfotraspaso2_batch.sql";
				SYSTEM vsSQL;				
				
				--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
				DELETE FROM "informix".si_archivoscopdiario;							
				
	RETURN v_cod_ret,vDesErr;
END;
--##############################################################################
--## Procedimiento   : "informix".sp_generartraspasoinfo.sql
--## Version         : 1.0
--## Creado por      : Maria Elena Angulo
--## Fecha creacion  : Mayo de 2013
--## Descripcion     : Traspaso de información de archivos batch de la tabla diario a la historial.
--##############################################################################
END PROCEDURE;
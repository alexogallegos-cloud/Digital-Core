CREATE PROCEDURE "informix".sp_cilocconsultaregiones()
		RETURNING   CHAR(5) as Codigo,	--codret
					INTEGER as NumeroRegion, --Numero de region
					CHAR(40) as Nombre; --nombre_region
					
	DEFINE cCodRet 			CHAR(5);
	DEFINE iCont            INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE cNumero_region   INTEGER;
	DEFINE cNombre_region    CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cNumero_region=0;
	LET cNombre_region = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocConsultaRegiones.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cNombre_region = 'Error de Informix';
			RETURN cCodRet,cNumero_region,cNombre_region;
		END EXCEPTION;		
		
	--Se realiza consulta a la tabla si_regiones para obtener el listado de las regiones existentes.	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
		FOREACH   
			SELECT NVL(numero_region,0),NVL(nombre_region,'')
			INTO  cNumero_region,cNombre_region
			FROM bdinteg:si_regiones
			LET icont=icont+1;
            RETURN cCodRet,cNumero_region,cNombre_region WITH RESUME;
		END FOREACH;		
		
        IF icont == 0 THEN 
			LET cCodret='00001'; 
			LET cNombre_region='No hay Informacion en la tabla';
            RETURN cCodRet,cNumero_region,cNombre_region WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado de las regiones existentes en la tabla si_regiones',
'FECHA       : 13 de Agosto de 2010',
'VERSION     : 20100813.1200',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_resultados_his()
RETURNING char(6), char(150);

--declaracion de variables
DEFINE sql_err                  INTEGER;
DEFINE isam_err                 INTEGER;
DEFINE error_info               CHAR(150);
DEFINE cMensaje                 CHAR(150); 
DEFINE cCod_ret                 CHAR(6);
DEFINE vempresa                  CHAR(3);
DEFINE vnumcte              	CHAR(20);
DEFINE vid_llamada          	CHAR(100);
DEFINE vtipo_telefono       	SMALLINT;
DEFINE vtelefono            	CHAR(13);
DEFINE vextension           	CHAR(5);
DEFINE vcodigo_resultado    	INTEGER;
DEFINE vfecha_llamar_despues    CHAR(40);
DEFINE vhora_llamar_despues 	CHAR(40);
DEFINE vejecutivo           	CHAR(10);
DEFINE vfh_movimiento       	CHAR(40);
DEFINE vdia						        DATE;
DEFINE vhora					        CHAR(8);
DEFINE vvcCod_ret             CHAR(6);
DEFINE cproceso                 CHAR(4);
DEFINE vrowid                   INTEGER;
DEFINE vfecha_llamada           DATE;
DEFINE vtipo_campania           CHAR(1);
DEFINE vparentesco              CHAR(1);

    --SET DEBUG FILE TO '/ids10_uc9/jtrujillo/sp_cat_resultados_his.out';
    --TRACE ON;
	
	--inicializacion de variables
	LET cCod_ret      = '00000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = ''; 	
	LET cMensaje      = 'PROCESO EXITOSO';
    LET cproceso      = '0010';
    LET vempresa      = '001';
    
    BEGIN
	
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;	
    
		--se obtiene la informacion
		
		
		SET LOCK MODE TO WAIT 3;
	  SET ISOLATION TO DIRTY READ;
    FOREACH cursor_borra WITH HOLD FOR

			SELECT rowid, fecha_llamada, tipo_campania, numcte, id_llamada, tipo_telefono
                ,telefono, extension, codigo_resultado, parentesco, fecha_llamar_despues, hora_llamar_despues
                ,ejecutivo, fh_movimiento
            INTO vrowid, vfecha_llamada, vtipo_campania, vnumcte, vid_llamada, vtipo_telefono
                ,vtelefono, vextension, vcodigo_resultado, vparentesco, vfecha_llamar_despues, vhora_llamar_despues
                ,vejecutivo, vfh_movimiento
            FROM cb_cat_resultado_llamada
            
            INSERT INTO informix.cb_cat_resultado_llamada_his(empresa, fecha_llamada, tipo_campania, numcte, id_llamada
                        ,tipo_telefono, telefono, extension, codigo_resultado, parentesco, fecha_llamar_despues
                        ,hora_llamar_despues, ejecutivo, fh_movimiento, fh_insert) 
            VALUES(vempresa, vfecha_llamada, vtipo_campania, vnumcte, vid_llamada, vtipo_telefono, vtelefono, vextension
                    ,vcodigo_resultado, vparentesco, vfecha_llamar_despues, vhora_llamar_despues, vejecutivo
                    ,vfh_movimiento, TODAY);

            BEGIN WORK;
               DELETE FROM bdicobranza:cb_cat_resultado_llamada
               WHERE CURRENT OF cursor_borra;                                                                             
            COMMIT WORK;

	END FOREACH;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
        RETURNING vvcCod_ret;
				
	RETURN cCod_ret, cMensaje;
	END;
END PROCEDURE;
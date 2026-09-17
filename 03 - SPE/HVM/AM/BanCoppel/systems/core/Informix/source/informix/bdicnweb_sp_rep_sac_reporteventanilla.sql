CREATE PROCEDURE "informix".sp_rep_sac_reporteventanilla(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, pSucursal CHAR(4),pRutaDescarga CHAR(100), pTipoR CHAR(1))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE iProcesados INTEGER;
	DEFINE iReg INTEGER;
	DEFINE iRec INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE iLineaError_Rep INTEGER;
	DEFINE  cBanDetError CHAR(1);
    DEFINE cFecha1 CHAR(10);
    DEFINE cFecha2 CHAR(10);
    DEFINE cSuc CHAR(80);
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET iProcesados = 0;
    LET cFecha1='';
    LET cFecha2='';
	LET  iReg =0;
	LET  iRec=0;
	LET  iNumRegistros=0;
	LET  dFechaHoy = '';
	LET  cFechaHoraArchivo = '';
	LET iLineaError_Rep=0;
	LET cBanDetError = 'f';
    LET cSuc='';
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			UPDATE "informix".sw_sac_reporteventanillagridRep
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
	
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_sac_reporteventanilla.out';
		--TRACE ON;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_rep_sac_reportedomiciliacion.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL  OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';	
			UPDATE "informix".sw_sac_reporteventanillagridRep
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_sac_reporteventanillagridRep
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
		
			 RETURN cCodRet, cNombreArchivo;
		END IF;

        -- SE LIMPIA TABLA POR USUARIO
   
		DELETE FROM "informix".sw_sac_reporteventanillagridRep
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
       
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO informix.sw_sac_reporteventanillagridrep( usuario, nombre_archivo, status, bandera_det_error, error_proceso, tipo_proceso, error, total_registros) 
		VALUES(pUsuario,'','I','','','LECTURA','',0);
        
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		

	    IF nvl(pSucursal,'') ='' THEN
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdisac:sac_reportediariovent_seg WHERE fecha_pago BETWEEN pFechaInicial AND pFechaFinal;
		ELSE
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdisac:sac_reportediariovent_seg WHERE fecha_pago BETWEEN pFechaInicial AND pFechaFinal AND sucursal_pago_ventanilla=pSucursal; 
		END IF;

		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_sac_reporteventanillagridRep
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA'; 
			
			RETURN cCodRet, cNombreArchivo;
		END IF;

        SELECT FIRST 1 (sucursal ||' '|| nombre) as suc 
        INTO cSuc
        FROM bdinteg:si_sucursales where sucursal =pSucursal;


        LET cFecha1= LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
        LET cFecha2= LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);
        LET dFechaHoy = CURRENT;
       

        LET cCmd1 ="";
        IF nvl(pSucursal,'') ='' THEN
        LET cCmd1 =""||TRIM(cCmd1)||"SELECT ' ',' ',' ',' ',' ',' ','REPORTE VENTANILLA CLUB DE PROTECCIÓN FAMILIAR',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    FROM systables WHERE tabid = 1  UNION ALL SELECT ' ','Periodo del: "|| LPAD(DAY(pFechaInicial),2,0)||'/'||LPAD(MONTH(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)||"  A: "|| LPAD(DAY(pFechaFinal),2,0)||'/'||LPAD(MONTH(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)||"',' ','Fecha del reporte:"||LPAD(DAY(dFechaHoy),2,0)||'/'||LPAD(MONTH(dFechaHoy),2,0)||'/'||YEAR(dFechaHoy)||' '||TO_CHAR(CURRENT, '%H:%M:%S')||"',' ','SUCURSAL: TODAS ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    FROM systables WHERE tabid = 1 UNION ALL";
		ELSE
		LET cCmd1 =""||TRIM(cCmd1)||"SELECT ' ',' ',' ',' ',' ',' ','REPORTE VENTANILLA CLUB DE PROTECCIÓN FAMILIAR',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    FROM systables WHERE tabid = 1  UNION ALL SELECT ' ','Periodo del: "|| LPAD(DAY(pFechaInicial),2,0)||'/'||LPAD(MONTH(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial)||"  A: "|| LPAD(DAY(pFechaFinal),2,0)||'/'||LPAD(MONTH(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal)||"',' ','Fecha del reporte:"||LPAD(DAY(dFechaHoy),2,0)||'/'||LPAD(MONTH(dFechaHoy),2,0)||'/'||YEAR(dFechaHoy)||' '||TO_CHAR(CURRENT, '%H:%M:%S')||"',' ','SUCURSAL: "||cSuc||" ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '    FROM systables WHERE tabid = 1 UNION ALL";
		END IF;
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'FECHA PAGO','REFERENCIA PAGO','IMPORTE PAGO','COMISION PAGO','IVA PAGO','MESES PAGO','SUCURSAL PAGO','FORMA PAGO','CAJERO','NOMBRE CAJERO','No. CLIENTE COPPEL','No. CLIENTE','No. POLIZA','MONTO MES','SUCURSAL ALTA','PROMOTOR','NOMBRE PROMOTOR','TIPO PLAN','FECHA ALTA','FECHA CAMBIO' FROM systables WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";       
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT  LPAD(DAY(fecha_pago),2,0)||'/'||LPAD(MONTH(fecha_pago),2,0)||'/'||YEAR(fecha_pago),''''||referencia1::CHAR(40), importe_pago::CHAR(18),SUBSTR((importe_comision_convenio||'%'),2,LENGTH(importe_comision_convenio::CHAR(18)))::CHAR(18), SUBSTR((iva_comision_convenio||'%'),2,LENGTH(iva_comision_convenio::CHAR(18)))::CHAR(18),meses::CHAR(18), ''''||sucursal_pago_ventanilla::CHAR(18), forma_pago::CHAR(18),''''||cajero::CHAR(18),nom_cajero::CHAR(45),''''||numcte_coppel::CHAR(20),''''||numcte::CHAR(20),''''||num_poliza::CHAR(20),monto_mes::CHAR(18),''''||sucursal_alta::CHAR(18),''''||promotor::CHAR(18), nom_promotor::CHAR(45),tipo_plan::CHAR(18),LPAD(DAY(fecha_alta),2,0)||'/'||LPAD(MONTH(fecha_alta),2,0)||'/'||YEAR(fecha_alta),LPAD(DAY(fecha_cambio),2,0)||'/'||LPAD(MONTH(fecha_cambio),2,0)||'/'||YEAR(fecha_cambio)";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_reportediariovent_seg";
		IF nvl(pSucursal,'') ='' THEN
        LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha_pago BETWEEN '"||cFecha1||"' AND '"||cFecha2||"'" ;
		ELSE
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha_pago BETWEEN '"||cFecha1||"' AND '"||cFecha2||"' AND sucursal_pago_ventanilla= '"||pSucursal||"'" ;
		END IF;
		
		LET cFechaHoraArchivo = YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||TO_CHAR(CURRENT, '%H%M%S');
		
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		IF (pTipoR=1) THEN 
		LET cNombreArchivo = 'REP_VENTANILLA_CPF_'||TRIM(cFechaHoraArchivo)||'.xls';
		ELSE 
		LET cNombreArchivo = 'REP_VENTANILLA_CPF_'||TRIM(cFechaHoraArchivo)||'.csv';
		END IF;

        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                       IF (pTipoR='1') THEN 
                	    LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        ELSE
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '','' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        END IF;
                          SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
						
						-- PreProd SOC v2
                        --LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
						
						-- Prod SOC v2
						LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
                        
						SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de línea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la línea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de línea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);


                       
        LET cBanDetError = 't';


				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
				
		UPDATE "informix".sw_sac_reporteventanillagridRep
		SET  status = 'T', error_proceso = 'N',total_registros = iNumRegistros,bandera_det_error = cBanDetError,nombre_archivo=cNombreArchivo
		WHERE usuario = pUsuario AND tipo_proceso = 'LECTURA';

		RETURN cCodRet, cNombreArchivo;


	END;
END PROCEDURE;
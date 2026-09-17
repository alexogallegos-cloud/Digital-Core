CREATE PROCEDURE "informix".sp_rep_sac_reportediario(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicial DATE, pFechaFinal DATE, pRutaDescarga CHAR(100), pTipoR CHAR(1))
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

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
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

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_sac_reportediario.out';
		--TRACE ON;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_rep_sac_reportedomiciliacion.out';
		--TRACE ON;
		

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL  OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';			
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		 
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdisac:sac_reportediario_seg WHERE fecha_proceso BETWEEN pFechaInicial AND pFechaFinal;


		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreArchivo;
		END IF;
        
        LET cFecha1= LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
        LET cFecha2= LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);
        
		LET cCmd1 ="";
        LET cCmd1 ="SELECT 'FECHA','No. MESES VENT','IMPORTE VENT','No. MESES DOMI','IMPORTE DOMI','NO. MESES','IMPORTE TOTAL','COMISION','IVA','IMPORTE PAGO COPPEL' FROM systables WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT  LPAD(DAY(fecha_proceso),2,0)||'/'||LPAD(MONTH(fecha_proceso),2,0)||'/'||YEAR(fecha_proceso),num_mesesvent::CHAR(18), importe_vent::CHAR(18), num_mesesdomi::CHAR(18), importe_domi::CHAR(18),num_meses::CHAR(18), importe_total::CHAR(18), comision::CHAR(18),iva::CHAR(18),importe_pago_coppel::CHAR(18) ";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_reportediario_seg";
        LET cCmd1 =""||TRIM(cCmd1)||" WHERE reportesoc='1' AND  fecha_proceso BETWEEN '"||cFecha1||"' AND '"||cFecha2||"'" ;
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'TOTALES'::CHAR(18),SUM(num_mesesvent)::CHAR(18),SUM (importe_vent)::CHAR(18), SUM (num_mesesdomi)::CHAR(18), SUM(importe_domi)::CHAR(18) ,SUM(num_meses)::CHAR(18), SUM (importe_total)::CHAR(18),SUM(comision)::CHAR(18), SUM(iva)::CHAR(18),SUM(importe_pago_coppel)::CHAR(18) ";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_reportediario_seg";
        LET cCmd1 =""||TRIM(cCmd1)||" WHERE reportesoc='1' AND  fecha_proceso BETWEEN '"||cFecha1||"' AND '"||cFecha2||"'" ;

		LET dFechaHoy = CURRENT;
		LET cFechaHoraArchivo = YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0)||TO_CHAR(CURRENT, '%H%M%S');
		
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		IF (pTipoR=1) THEN 
		LET cNombreArchivo = 'REP_CONCILIACION_CPF_'||TRIM(cFechaHoraArchivo)||'.xls';
		ELSE 
		LET cNombreArchivo = 'REP_CONCILIACION_CPF_'||TRIM(cFechaHoraArchivo)||'.csv';
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
				
		

		RETURN cCodRet, cNombreArchivo;


	END;
END PROCEDURE;
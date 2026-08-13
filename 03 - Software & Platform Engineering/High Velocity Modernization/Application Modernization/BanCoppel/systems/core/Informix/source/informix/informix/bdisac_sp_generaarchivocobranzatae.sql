CREATE PROCEDURE "informix".sp_generaarchivocobranzatae(cId_convenio CHAR(5));
	
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cInfoErr			CHAR(100);
	DEFINE cCategoria		CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE dFechaIni		DATE;
	DEFINE dFecha_Hoy		DATE;
	DEFINE cRutaArch		CHAR(100);
	DEFINE cNomArch			CHAR(30);
	DEFINE cNomes			CHAR(15);
	DEFINE cMes				CHAR(2);
	DEFINE cDia				CHAR(2);
	DEFINE cAnio			CHAR(2);
	DEFINE cAnio2           CHAR(4);
	DEFINE cStmt			CHAR(250);
	DEFINE cCuentaPrestadora CHAR(12);
	DEFINE cFechaPago		CHAR(8);
	DEFINE cSucursal		CHAR(4);
	DEFINE cReferencia1		CHAR(20);
	DEFINE cReferencia2		CHAR(20);
	DEFINE iImportePago		INTEGER;
	DEFINE cSerial			CHAR(40);
	DEFINE cFolioSuc		CHAR(16);
	DEFINE cCompania		CHAR(2);
	DEFINE iNumPagos		INTEGER;
	DEFINE iTotalPagado		INTEGER;
	DEFINE cNumFolio        CHAR(9);
	DEFINE cHoraMovto       CHAR(6);
	
	--EPG 20180613
	DEFINE cFlagCen         INTEGER;
	DEFINE cFlagSuc         INTEGER;
	DEFINE iCuantos         INTEGER;
	DEFINE dFecha_Pago      DATE; 
	
	--SET DEBUG FILE TO '/home/e10000958/archivocobranzatae.out';
	--TRACE ON;

	LET cCategoria	 = SUBSTRING(cId_convenio FROM 1 FOR 2);
	LET cConvenio 	 = SUBSTRING(cId_convenio FROM 3 FOR 3);
	LET cRutaArch 	 = '';
	LET cNomArch 	 = '';
	LET cNomes 		 = '';
	LET cMes 		 = '';
	LET cDia 		 = '';
	LET cAnio 		 = '';
	LET cAnio2		 = '';
	LET cStmt		 = '';
	LET cCuentaPrestadora = '';
	LET cFechaPago 	 = '';
	LET cSucursal 	 = '';
	LET cReferencia1 = '';
	LET cReferencia2 = '';
	LET iImportePago = '000000000';
	LET cSerial      = '';
	LET cFolioSuc	 = '0000000000000000';
	LET cCompania	 = '';
	LET iNumPagos	 = 0;
	LET iTotalPagado = 0;
	LET cNumFolio    = '';
	LET cHoraMovto   = '';
	
	LET cCodRet      = '00000';
	
	--EPG 20180613
	LET cFlagCen     = 0;
	LET cFlagSuc     = 0;
    LET	iCuantos     = 0; 	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;

				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_generaarchivocobranzatae");
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy INTO dFecha_Hoy
		 FROM "informix".sac_fechas;

		SELECT fecha_ultimo_archivo
		  INTO dFechaIni
		  FROM "informix".sac_controlarchivoscobranza
		 WHERE numcategoria = cCategoria
		   AND numconvenio = cConvenio;

		LET cDia   = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMes   = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio  = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE);
		
		SELECT ruta_archivo_cobranza, nombre_archivo_cobranza, cuenta_prestadora
		  INTO cRutaArch, cNomArch, cCuentaPrestadora
		  FROM "informix".sac_convenios
		 WHERE numcategoria = cCategoria
		   AND numconvenio = cConvenio;
		
		
		LET cNomArch  = REPLACE(cNomArch,'AAAA',cAnio2);
		LET cNomArch  = REPLACE(cNomArch,'MM',cMes);
		LET cNomArch  = REPLACE(cNomArch,'DD',cDia);
		LET cNomArch  = TRIM(cNomArch);
		LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArch);
		
		FOREACH
			select * 
				INTO cFechaPago, cSucursal, cReferencia2, cReferencia1, iImportePago, cSerial, cFolioSuc, cNumFolio, cFlagCen, cFlagSuc, dFecha_Pago, cHoraMovto
			FROM (
				SELECT LPAD(DAY(mov.fecha_pago::DATE), 2, '0') || LPAD(MONTH(mov.fecha_pago::DATE), 2, '0') || LPAD(YEAR(mov.fecha_pago:: DATE), 4, '0'),
					mov.id_sucursal, UPPER(mov.referencia2), mov.referencia1, mov.importe_pago, msw.campo22, mov.folio_suc, LPAD(sol.campo14, 9, '0'),
					mov.flag_confirmacion_central, mov.flag_confirmacion_sucursal, mov.fecha_pago, SUBSTR(mov.folio_suc,9,6)                   
				FROM "informix".sac_movimientoshistorial AS mov
					INNER JOIN sac_msw_solicitud AS sol ON (mov.numcategoria = sol.numcategoria AND mov.numconvenio = sol.numconvenio AND mov.folio_suc = sol.folio_suc and sol.num_trama = '1' and sol.fecha_pago = dFecha_Hoy)
					INNER JOIN sac_msw_respuesta AS msw ON (mov.numcategoria = msw.numcategoria AND mov.numconvenio = msw.numconvenio AND mov.folio_suc = msw.folio_suc AND (msw.num_trama = '1' or msw.num_trama = '2') and msw.campo8 <> '' and msw.fecha_pago = dFecha_Hoy)
				WHERE mov.fecha_pago > dFechaIni
					AND mov.fecha_pago <= dFecha_Hoy
					AND	mov.numcategoria = '03'
					AND mov.numconvenio = '001'
					AND mov.id_sucursal <> '5011'
					AND mov.status_cancelado <> 'S'
                    AND mov.referencia2 <> 'TELCEL'
					AND (mov.flag_confirmacion_central = 1 OR mov.flag_confirmacion_sucursal = 1) 
					
				UNION 
				SELECT LPAD(DAY(mov.fecha_pago::DATE), 2, '0') || LPAD(MONTH(mov.fecha_pago::DATE), 2, '0') || LPAD(YEAR(mov.fecha_pago:: DATE), 4, '0'),
					mov.id_sucursal, UPPER(mov.referencia2), mov.referencia1, mov.importe_pago,coalesce (SUBSTRING_INDEX(mov.referencia4, "|", 1),''),  
					mov.folio_suc,coalesce(SUBSTRING_INDEX(SUBSTRING_INDEX(mov.referencia4, "|", 2),"|",-1),''), 
					mov.flag_confirmacion_central, mov.flag_confirmacion_sucursal, mov.fecha_pago , to_char(extend (mov.fecha_insert, hour to second),'%H%M%S')                  
				FROM "informix".sac_movimientoshistorial AS mov             
				WHERE mov.fecha_pago > dFechaIni
					AND mov.fecha_pago <= dFecha_Hoy
					AND	mov.numcategoria = '03'
					AND mov.numconvenio = '001'
					AND mov.id_sucursal = '5011'
					AND  mov.status_cancelado <> 'S'
                    AND mov.referencia2 <> 'TELCEL'
					AND (mov.flag_confirmacion_central = 1 OR mov.flag_confirmacion_sucursal = 1) 
				
			) AS miTabla
			 
			LET cReferencia2 = TRIM (cReferencia2);
			LET cReferencia1 = TRIM (cReferencia1);
			LET iImportePago = iImportePago * 100;
					   
            IF cReferencia2 ='TELCEL' THEN
                LET cCompania = '03';
			ELIF cReferencia2 ='MOVISTAR' THEN	
			    LET cCompania = '04';
            ELIF cReferencia2 ='AT&T' THEN	
			    LET cCompania = '02';
			ELIF cReferencia2 ='UNEFON' THEN	
			    LET cCompania = '01';
            END IF;				
			
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "D|' || cFechaPago || '|' || cSucursal || '|' || cCompania || '|' || LPAD(cReferencia1, 10, 0) || '|' || LPAD(iImportePago ,10,'0') || '|' || LPAD(TRIM(cSerial), 12,'0') || '|' || LPAD(cFolioSuc, 16, '0') || '|' || LPAD (TRIM(cNumFolio), 9, 0)|| '|' || LPAD (TRIM(cHoraMovto), 6, 0)  || '" >> ' || cRutaArch;
			SYSTEM cStmt;

			LET iNumPagos = iNumPagos + 1;
			LET iTotalPagado = iTotalPagado + iImportePago;

            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolioSuc	and cancelad <> 'S';

              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolioSuc AND fech_alt = dFecha_Pago and cancelad <> 'S';

                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;

              IF iCuantos > 0 THEN            
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolioSuc,dFecha_Pago,current);
              END IF;
            END IF;
		
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "T|' || cFechaPago || '|' ||'0000'|| '|' || '00' || '|' || '0000000000' || '|' || LPAD(iTotalPagado ,10,'0') || '|' ||'000000000000'|| '|' ||LPAD(iNumPagos, 16,'0')||'|'||'000000000'||'|'||'000000'||'" >> ' || cRutaArch;
			SYSTEM cStmt;
		ELIF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cStmt = 'echo "T|' || cDia || cMes || cAnio2 || '|' ||'0000'|| '|' || '00' || '|' || '0000000000' || '|' || LPAD(iTotalPagado ,10,'0') || '|' ||'000000000000'|| '|' || LPAD(iNumPagos, 16,'0') ||'|'||'000000000'||'|'||'000000'||'" >> ' || cRutaArch;
			SYSTEM cStmt;
		END IF;

        FOREACH SELECT referencia, folio_suc, fecha_pago 
				  INTO  cReferencia1, cFolioSuc, dFecha_Pago
				  FROM "informix".sac_bitacora_flags 
				 WHERE fecha_insert::DATE = today AND numcategoria = cCategoria AND numconvenio = cConvenio 
       			
    		 UPDATE sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
              WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio
                AND fecha_pago = dFecha_Pago
				AND folio_suc = cFolioSuc
				AND referencia1 = cReferencia1
                AND status_cancelado <> 'S'
                AND flag_confirmacion_sucursal = 0;
        END FOREACH;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		   SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		 WHERE numcategoria = cCategoria
		   AND numconvenio = cConvenio;
		
	END;
END PROCEDURE
DOCUMENT
'Folio: 1454',
'Autor: 95604901',
'Fecha: 12/01/2015',
'Descripcion: Se crea procedimiento que realiza archivo en txt. de la cobranza generada con los pagos para venta de tiempo aire',
'Sustento: RQM 10 471 Venta de tiempo Aire Electronico',
'Solicita: Leonardo Hernandez',
'MODIFICO : Jorge Roberto',
'DESCRIPCION: Se agrega consulta para extraer los datos para el convenio 03001 sucursal 5011',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 14/10/2022',
'VERSION: ',
'BD: bdisac',
--
'Folio: 1454',
'Autor: 95604901',
'Fecha: 21/12/2022',
'Descripcion: Se agrega la hora para el proceso ETL en Coppel',
'Sustento: INC 62 266 Modificacion archivo de cobranza TAE',
'Solicita: Leonardo Hernandez',
'MODIFICO : Jorge Roberto',
'DESCRIPCION: Se agrega consulta para extraer los datos para el convenio 03001 sucursal 5011',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 14/10/2022',
'VERSION: ',
'BD: bdisac',
--
'Folio: 1454',
'Autor: 99804974',
'Fecha: 07/02/2025',
'Descripcion: Se excluye TELCEL poara la conciliaciÃ³n',
'Sustento: INC 62 266 Modificacion archivo de cobranza TAE',
'Solicita: Alejandro Sanchez',
'MODIFICO : RubÃ©n ValdÃ©s',
'DESCRIPCION: Se agrega filtrado para excluir referencia2 cuando sea TELCEL',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 07/02/2025',
'VERSION: ',
'BD: bdisac';


grant  execute on function "informix".sp_actualizaregsuc (char,date,date) to "syspitdc" as "informix";
grant  execute on function "informix".sp_actualizaregsuc (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_actualizaregsuc (char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizaregsuc (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizaregsuc (char,date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizaregsuc (char,date,date) to "sysbts" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio (char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio (char,char,char) to "syspitdc" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio (char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio (char,char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_calculaproxfechahabil (date) to "sysbts" as "informix";
grant  execute on function "informix".sp_calculaproxfechahabil (date) to "public" as "informix";
grant  execute on function "informix".sp_calculaproxfechahabil (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_calculaproxfechahabil (date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_calculaproxfechahabil (date) to "syspitdc" as "informix";
grant  execute on function "informix".sp_calculaproxfechahabil (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacconsultascentral (char) to "syspitdc" as "informix";
grant  execute on function "informix".sp_sacconsultascentral (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacconsultascentral (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacconsultascentral (char) to "public" as "informix";
grant  execute on function "informix".sp_sacconsultascentral (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacconsultascentral (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_consulta_convenio (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio (char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_consulta_convenio (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_convenio (char,char) to "syspitdc" as "informix";
grant  execute on function "informix".sp_consulta_convenio (char,char) to "public" as "informix";
grant  execute on function "informix".sp_calculadv (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_calculadv (char) to "syspitdc" as "informix";
grant  execute on function "informix".sp_calculadv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculadv (char) to "public" as "informix";
grant  execute on function "informix".sp_calculadv (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_calculadv (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_sac_actualizastatusarch (char,date) to "sysbts" as "informix";
grant  execute on function "informix".sp_sac_actualizastatusarch (char,date) to "public" as "informix";
grant  execute on function "informix".sp_sac_actualizastatusarch (char,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_actualizastatusarch (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_actualizastatusarch (char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi (varchar,varchar) to "sysbts" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi (varchar,varchar) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi (varchar,varchar) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_concimovtotal (date) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_sac_concimovtotal (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_concimovtotal (date) to "public" as "informix";
grant  execute on function "informix".sp_sac_concimovtotal (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_concimovtotal (date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_concimovtotal (date) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_consultaidentificaciones () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_consultaidentificaciones () to "public" as "informix";
grant  execute on function "informix".sp_dinya_consultaidentificaciones () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_consultaidentificaciones () to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_consultaidentificaciones () to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_generadigitoverificador (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_generadigitoverificador (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_generadigitoverificador (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_generadigitoverificador (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_generadigitoverificador (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtenerdetalleenvio (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_obtenerdetalleenvio (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtenerdetalleenvio (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtenerdetalleenvio (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtenerdetalleenvio (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtienedetdiario (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtienedetdiario (char,date,date) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_obtienedetdiario (char,date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtienedetdiario (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtienedetdiario (char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam (char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam (char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_obtienetotales (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtienetotales (char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtienetotales (char,date,date) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_obtienetotales (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtienetotales (char,date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtieneconvenios () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtieneconvenios () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtieneconvenios () to "sysbts" as "informix";
grant  execute on function "informix".sp_obtieneconvenios () to "public" as "informix";
grant  execute on function "informix".sp_obtieneconvenios () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_activaenviosnocobrados (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_activaenviosnocobrados (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_activaenviosnocobrados (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_activaenviosnocobrados (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_activaenviosnocobrados (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_actualizacomisiones (char,money,money,money,money,integer,char,date,integer) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_actualizacomisiones (char,money,money,money,money,integer,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_dinya_actualizacomisiones (char,money,money,money,money,integer,char,date,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_actualizacomisiones (char,money,money,money,money,integer,char,date,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_actualizacomisiones (char,money,money,money,money,integer,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_bloqueaenviosnocobrados () to "public" as "informix";
grant  execute on function "informix".sp_dinya_bloqueaenviosnocobrados () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_bloqueaenviosnocobrados () to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_bloqueaenviosnocobrados () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_bloqueaenviosnocobrados () to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_consultaenviosbloqueados (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_consultaenviosbloqueados (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_consultaenviosbloqueados (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_consultaenviosbloqueados (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_consultaenviosbloqueados (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_generanumerocontrol (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_generanumerocontrol (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_generanumerocontrol (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_generanumerocontrol (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_generanumerocontrol (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios2 (money,money,money,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios2 (money,money,money,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios2 (money,money,money,char,char,char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios2 (money,money,money,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios2 (money,money,money,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtienecomisiones (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienecomisiones (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_obtienecomisiones (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtienecomisiones (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtienecomisiones (char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualdish (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_sacreportemensualdish (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualdish (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualdish (char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualdish (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualmastv (char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualmastv (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualmastv (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualmastv (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_sacreportemensualmastv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualsky (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualsky (char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualsky (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualsky (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_sacreportemensualsky (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsky (integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsky (integer) to "sysbts" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsky (integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsky (integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsky (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_repservicios_totales (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_repservicios_totales (char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_repservicios_totales (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_repservicios_totales (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_repservicios_totales (char,char) to "public" as "informix";
grant  execute on function "informix".sp_repservicios_totales (char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_sac_conciliatotbancos (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_conciliatotbancos (date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_conciliatotbancos (date) to "sysbts" as "informix";
grant  execute on function "informix".sp_sac_conciliatotbancos (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_conciliatotbancos (date) to "public" as "informix";
grant  execute on function "informix".sp_sac_conciliatotbancos (date) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_actualizadatosusrl (char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_actualizadatosusrl (char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizadatosusrl (char,char,char,char,char,char,char,char,char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_actualizadatosusrl (char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizadatosusrl (char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultadatosusrl () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultadatosusrl () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultadatosusrl () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultadatosusrl () to "public" as "informix";
grant  execute on function "informix".sp_consultadatosusrl () to "sysbts" as "informix";
grant  execute on function "informix".sp_consdatosticketbts (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consdatosticketbts (char) to "public" as "informix";
grant  execute on function "informix".sp_consdatosticketbts (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_consdatosticketbts (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consdatosticketbts (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consinfobtssif (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consinfobtssif (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consinfobtssif (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consinfobtssif (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_consinfobtssif (char) to "public" as "informix";
grant  execute on function "informix".sp_consultadatosencabezado () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultadatosencabezado () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultadatosencabezado () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultadatosencabezado () to "sysbts" as "informix";
grant  execute on function "informix".sp_consultadatosencabezado () to "public" as "informix";
grant  execute on function "informix".sp_guardarespuestarevi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestarevi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestarevi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardarespuestarevi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "sysbts" as "informix";
grant  execute on function "informix".sp_guardarespuestarevi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportebts_mensual (date) to "sysbts" as "informix";
grant  execute on function "informix".sp_reportebts_mensual (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportebts_mensual (date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportebts_mensual (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportebts_mensual (date) to "public" as "informix";
grant  execute on function "informix".sp_validabts (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_validabts (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validabts (char) to "public" as "informix";
grant  execute on function "informix".sp_validabts (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validabts (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionarabela (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionarabela (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionarabela (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionarabela (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualarabela (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualarabela (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualarabela (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualarabela (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualeci (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualeci (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualeci (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualeci (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalarabela (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalarabela (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanalarabela (char,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalarabela (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanaleci (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanaleci (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanaleci (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanaleci (char,integer) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioneci (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioneci (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioneci (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioneci (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportebts_edocta (date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportebts_edocta (date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_reportebts_edocta (date,date,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_generaarchivoptc (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_generaarchivoptc (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_generaarchivoptc (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_generaarchivoptc (char,char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacion_tmp (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacion_tmp (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacion_tmp (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacion_tmp (char) to "public" as "informix";
grant  execute on function "informix".sp_sac_eliminamovshistoricos (date,date) to "public" as "informix";
grant  execute on function "informix".sp_sac_eliminamovshistoricos (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_eliminamovshistoricos (date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_eliminamovshistoricos (date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_mueveregistrosaold_esp (date,date) to "public" as "informix";
grant  execute on function "informix".sp_mueveregistrosaold_esp (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_mueveregistrosaold_esp (date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_mueveregistrosaold_esp (date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi2 (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi2 (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi2 (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionavon (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionavon (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionavon (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionavon (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondyclass (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondyclass (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondyclass (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondyclass (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualavon (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualavon (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualavon (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualavon (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualdyclass (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualdyclass (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualdyclass (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualdyclass (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalavon (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanalavon (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalavon (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalavon (char,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanaldyclass (char,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanaldyclass (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanaldyclass (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanaldyclass (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_obtieneinfoidentificacion (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_obtieneinfoidentificacion (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_obtieneinfoidentificacion (char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_obtieneinfoidentificacion (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep (char,integer,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep (char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep (char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep (char,integer,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio_pba (char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio_pba (char,date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio_pba (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio_pba (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam_pba (char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam_pba (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam_pba (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtieneparam_pba (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_altascambioscentral_pba (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_altascambioscentral_pba (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_altascambioscentral_pba (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_altascambioscentral_pba (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio_pba (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio_pba (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio_pba (char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizastatusconvenio_pba (char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_calcula_comisiones_pba (char,char,money) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_calcula_comisiones_pba (char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_calcula_comisiones_pba (char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_calcula_comisiones_pba (char,char,money) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi_pba (varchar,varchar) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi_pba (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi_pba (varchar,varchar) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio_bpi_pba (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_consulta_convenio_pba (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_convenio_pba (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_convenio_pba (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_convenio_pba (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_pba (char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_pba (char,money,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_pba (char,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_pba (char,money,char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaeci_pba (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaeci_pba (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaeci_pba (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaeci_pba (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadyclass_pba (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadyclass_pba (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadyclass_pba (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadyclass_pba (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadish_pba (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadish_pba (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadish_pba (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadish_pba (char) to "public" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtspayi (date,date) to "public" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtspayi (date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtspayi (date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtspayi (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtsqryi (date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtsqryi (date,date) to "public" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtsqryi (date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_eliminamovsbtsqryi (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardarespuestaqryi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_guardarespuestaqryi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardarespuestaqryi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta_pba (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta_pba (date) to "public" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta_pba (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta_pba (date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_confirmapayc (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_confirmapayc (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_confirmapayc (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_confirmapayc (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consremcambiost (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consremcambiost (char,date) to "public" as "informix";
grant  execute on function "informix".sp_consremcambiost (char,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consremcambiost (char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validarembtsensac (char,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validarembtsensac (char,char,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_validarembtsensac (char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_validarembtsensac (char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_genreporbenefrem (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genreporbenefrem (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_genreporbenefrem (char,char) to "public" as "informix";
grant  execute on function "informix".sp_genreporbenefrem (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bitacoragdf (char,char,char,char,char,char,char,integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bitacoragdf (char,char,char,char,char,char,char,integer,integer,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bitacoragdf (char,char,char,char,char,char,char,integer,integer,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bitacoragdf (char,char,char,char,char,char,char,integer,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_confirmacionbitacorapgdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_confirmacionbitacorapgdf (char) to "public" as "informix";
grant  execute on function "informix".sp_confirmacionbitacorapgdf (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_confirmacionbitacorapgdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdatosticketpgdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdatosticketpgdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consdatosticketpgdf (char) to "public" as "informix";
grant  execute on function "informix".sp_consdatosticketpgdf (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongdf (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongdf (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongdf (char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualgdf (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualgdf (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualgdf (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualgdf (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalgdf (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanalgdf (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalgdf (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalgdf (char,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_validadvgdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validadvgdf (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_validadvgdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validadvgdf (char) to "public" as "informix";
grant  execute on function "informix".sp_validalimpago (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validalimpago (char) to "public" as "informix";
grant  execute on function "informix".sp_validalimpago (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_validalimpago (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion_pba () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion_pba () to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion_pba () to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion_pba () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev_pba (date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev_pba (date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev_pba (date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev_pba (date,date,char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncam (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncam (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncam (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncam (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalcam (char,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalcam (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanalcam (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalcam (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualcam (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualcam (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualcam (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualcam (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportewu_conciliacion (date,date,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportewu_conciliacion (date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportewu_conciliacion (date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportewu_conciliacion (date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_reportewu_mensual (date,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportewu_mensual (date,char) to "public" as "informix";
grant  execute on function "informix".sp_reportewu_mensual (date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportewu_mensual (date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_comparacaracteres (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_comparacaracteres (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_comparacaracteres (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_comparacaracteres (char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_altascambioscentral (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_altascambioscentral (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_altascambioscentral (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_altascambioscentral (char,char,char,date,date,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,decimal,char,decimal,char,money,char,money,char,integer,char,decimal,char,money,char,integer,char,char,char,integer,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_intcajero_recicla (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_intcajero_recicla (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_intcajero_recicla (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_intcajero_recicla (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_asignabimestre (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_asignabimestre (char) to "public" as "informix";
grant  execute on function "informix".sp_asignabimestre (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_asignabimestre (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_centro_servicio_bpi (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_centro_servicio_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_centro_servicio_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_centro_servicio_bpi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_holograma_gdf_bpi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_holograma_gdf_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_holograma_gdf_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_holograma_gdf_bpi (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_marca_gdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_marca_gdf (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_marca_gdf (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_marca_gdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_periodo_lic_gdf_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_periodo_lic_gdf_bpi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_periodo_lic_gdf_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_periodo_lic_gdf_bpi (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_tipo_impuesto_gdf_bpi (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_tipo_impuesto_gdf_bpi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_tipo_impuesto_gdf_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_tipo_impuesto_gdf_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_tramite_gdf_bpi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_tramite_gdf_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_tramite_gdf_bpi (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consulta_tramite_gdf_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf_bpi (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf_bpi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ejercicio_fiscal_gdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ejercicio_fiscal_gdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_ejercicio_fiscal_gdf (char) to "public" as "informix";
grant  execute on function "informix".sp_ejercicio_fiscal_gdf (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_grababitacoragdf (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_grababitacoragdf (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_grababitacoragdf (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_grababitacoragdf (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_indexof_bpi (char,char) to "public" as "informix";
grant  execute on function "informix".sp_indexof_bpi (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_indexof_bpi (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_indexof_bpi (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_indexof_der_bpi (char,char) to "public" as "informix";
grant  execute on function "informix".sp_indexof_der_bpi (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_indexof_der_bpi (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_indexof_der_bpi (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_isnumeric (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_isnumeric (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_isnumeric (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_isnumeric (char) to "public" as "informix";
grant  execute on function "informix".sp_isnumeric_int (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_isnumeric_int (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_isnumeric_int (char) to "public" as "informix";
grant  execute on function "informix".sp_isnumeric_int (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerdvgdf (char) to "public" as "informix";
grant  execute on function "informix".sp_obtenerdvgdf (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtenerdvgdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerdvgdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_valfecha_banca_gdf (char,date) to "public" as "informix";
grant  execute on function "informix".sp_valfecha_banca_gdf (char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_valfecha_banca_gdf (char,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_valfecha_banca_gdf (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_validacadenanumerica (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validacadenanumerica (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_validacadenanumerica (char) to "public" as "informix";
grant  execute on function "informix".sp_validacadenanumerica (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_pago_servicios_gdf (char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,money,money,money,money,smallint,integer,char,char,char,char,char,char,char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_pago_servicios_gdf (char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,money,money,money,money,smallint,integer,char,char,char,char,char,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_servicios_gdf (char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,money,money,money,money,smallint,integer,char,char,char,char,char,char,char,date,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_pago_servicios_gdf (char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,money,money,money,money,smallint,integer,char,char,char,char,char,char,char,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportebts_edocta (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reportebts_edocta (date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportebts_edocta (date,date) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsuk (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsuk (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsuk (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsuk (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualsuk (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualsuk (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualsuk (char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualsuk (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsuk (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsuk (char,integer) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsuk (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsuk (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev (date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev (date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev (date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbtsrev (date,date,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_grabapagocoppel (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "public" as "informix";
grant  execute on function "informix".sp_grabapagocoppel (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_grabapagocoppel (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapagocoppel (char,char,smallint,smallint,integer,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondish (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondish (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondish (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionmastv (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionmastv (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionmastv (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsky (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsky (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsky (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciontelmex (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciontelmex (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciontelmex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensual (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensual (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensual (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanal (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanal (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanal (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_wu_truncacatalogosdas (char,char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_wu_truncacatalogosdas (char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_wu_truncacatalogosdas (char,char,char,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_wu_obtparamdas (char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_wu_obtparamdas (char,char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_wu_obtparamdas (char,char,char,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_bitacoragdf (char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_bitacoragdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_bitacoragdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_multas (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_multas (char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_multas (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_vehicular (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_vehicular (char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_vehicular (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodificadatosserviciopolicia (char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_decodificadatosserviciopolicia (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatosserviciopolicia (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbts (date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbts (date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadasbts (date,date,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsolfi (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsolfi (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionsolfi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualsolfi (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualsolfi (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualsolfi (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsolfi (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsolfi (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanalsolfi (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_validapagoremesa (char,decimal) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validapagoremesa (char,decimal) to "c90306542" as "informix";
grant  execute on function "informix".sp_validapagoremesa (char,decimal) to "public" as "informix";
grant  execute on function "informix".sp_sacreportecobranzasucursal (char,date,date,smallint) to "public" as "informix";
grant  execute on function "informix".sp_sacreportecobranzasucursal (char,date,date,smallint) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal (char,char,date,date,smallint) to "public" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal (char,char,date,date,smallint) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_select (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_select (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_select (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_paystatus (char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_paystatus (char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_paystatus (char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catmensajeserror (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catmensajeserror (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catmensajeserror (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catisopaises (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catisopaises (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catisopaises (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catisomonedas (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catisomonedas (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catisomonedas (char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catciudadeswu (char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catciudadeswu (char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catciudadeswu (char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catciudadesvgov (char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catciudadesvgov (char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_catciudadesvgov (char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncarnival (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncarnival (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncarnival (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_canc_seg (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_canc_seg (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_canc_seg (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cp_consctesex (char) to "public" as "informix";
grant  execute on function "informix".sp_cp_consctesex (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cp_consctesex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_graba_abono_seg (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_graba_abono_seg (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_graba_abono_seg (char,char) to "public" as "informix";
grant  execute on function "informix".sp_graba_cons_seg (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_graba_cons_seg (char,char) to "public" as "informix";
grant  execute on function "informix".sp_graba_cons_seg (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapagocoppelcp (char,char,smallint,smallint,integer,int8,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_grabapagocoppelcp (char,char,smallint,smallint,integer,int8,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "public" as "informix";
grant  execute on function "informix".sp_grabapagocoppelcp (char,char,smallint,smallint,integer,int8,integer,integer,integer,char,integer,char,integer,integer,integer,char,date) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionstanhome (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionstanhome (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionstanhome (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionyvesroche (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionyvesroche (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionyvesroche (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_wu_obtparamsgenerales (char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_wu_obtparamsgenerales (char,char,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_wu_obtparamsgenerales (char,char,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_graba_vtacam_seg (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_graba_vtacam_seg (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_graba_vtacam_seg (char,char) to "public" as "informix";
grant  execute on function "informix".sp_wu_recuperaparams_hb (char,char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_wu_recuperaparams_hb (char,char,char,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_wu_recuperaparams_hb (char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_hb (char,char,char,char,char,char,char,datetime,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_hb (char,char,char,char,char,char,char,datetime,char,char,char,char,datetime,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_hb (char,char,char,char,char,char,char,datetime,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreporteconciliacionconveniosucursal (char,char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_sacreporteconciliacionconveniosucursal (char,char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreporteconciliacionconveniosucursal (char,char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_search (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_search (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep_pba (char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep_pba (char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_recuperacdep_pba (char,integer,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_bei (char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_bei (char,char,money) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_bei (char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_bpi (char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_bpi (char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva_bpi (char,char,money) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios3 (money,money,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios3 (money,money,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_pasemovshistorial () to "public" as "informix";
grant  execute on function "informix".sp_sac_pasemovshistorial () to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_pasemovshistorial () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_envpag_valmontmax (smallint,money,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_envpag_valmontmax (smallint,money,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_envpag_valmontmax (smallint,money,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".fn_instr (varchar,varchar,integer) to "public" as "informix";
grant  execute on function "informix".fn_instr (varchar,varchar,integer) to "c90306542" as "informix";
grant  execute on function "informix".fn_instr (varchar,varchar,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_bitacorawsedomex (char,char,char,char,date,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bitacorawsedomex (char,char,char,char,date,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bitacorawsedomex (char,char,char,char,date,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_confirmacionbitacoraedomex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_confirmacionbitacoraedomex (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmacionbitacoraedomex (char) to "public" as "informix";
grant  execute on function "informix".sp_consdatosticketedomex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consdatosticketedomex (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdatosticketedomex (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaedomex (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaedomex (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaedomex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_inserta_msw_respuesta (char,char,char,char,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_inserta_msw_respuesta (char,char,char,char,date,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_emex_catrespws (char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_emex_catrespws (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_emex_catrespws (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_intrfz_serv (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_intrfz_serv (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_msw_validacion (char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_msw_validacion (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienelineabaseedomex (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienelineabaseedomex (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienelineabaseedomex (char,char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionedomex (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionedomex (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionedomex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualedomex (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualedomex (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportemensualedomex (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesemanaledomex (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanaledomex (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanaledomex (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_axtel_validadv (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_axtel_validadv (char) to "public" as "informix";
grant  execute on function "informix".sp_axtel_validadv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cablemas_validadv (char) to "public" as "informix";
grant  execute on function "informix".sp_cablemas_validadv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cablemas_validadv (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_cfe_validadv (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cfe_validadv (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_cfe_validadv (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cons_pagos_msw (char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_pagos_msw (char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_cons_pagos_msw (char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_japac_validadv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_japac_validadv (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_japac_validadv (char) to "public" as "informix";
grant  execute on function "informix".sp_obtienefoliocoppel_hs (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienefoliocoppel_hs (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienefoliocoppel_hs (char,char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionaxtel (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionaxtel (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionaxtel (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncablemas (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncablemas (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncablemas (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncfe (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncfe (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncfe (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionjapac (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionjapac (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionjapac (char) to "public" as "informix";
grant  execute on function "informix".sp_validadvcaminemos (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_validadvcaminemos (char) to "public" as "informix";
grant  execute on function "informix".sp_validadvcaminemos (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_sukarne (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_sukarne (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_valida_dv_sukarne (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_solfi (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_solfi (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_valida_dv_solfi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_carnival_validadv (char) to "public" as "informix";
grant  execute on function "informix".sp_carnival_validadv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_carnival_validadv (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_valid_dv_stanhome (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valid_dv_stanhome (char) to "public" as "informix";
grant  execute on function "informix".sp_valid_dv_stanhome (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliaciontotalporconvenio (char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadaswu (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadaswu (date,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadaswu (date,date,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadaswurev (date,date,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadaswurev (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportesremesasnoconciliadaswurev (date,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reportebts_edocta_pba (date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_reportebts_edocta_pba (date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportebts_edocta_pba (date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreporteconciliacionconveniosucursal_pba (char,char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_sacreporteconciliacionconveniosucursal_pba (char,char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreporteconciliacionconveniosucursal_pba (char,char,date,date) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppel_pba (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppel_pba (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppel_pba (char) to "public" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzaservcpl_pba () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzaservcpl_pba () to "public" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzaservcpl_pba () to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzajapac (char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzajapac (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzajapac (char) to "public" as "informix";
grant  execute on function "informix".sp_asignacuenta_edomex (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_asignacuenta_edomex (char) to "public" as "informix";
grant  execute on function "informix".sp_asignacuenta_edomex (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_confirmacionbitacoratae (char,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_confirmacionbitacoratae (char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmacionbitacoratae (char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_inserta_msw_respuesta (char,char,char,char,date,integer,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_inserta_msw_respuesta (char,char,char,char,date,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_intrfz_serv (char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_intrfz_serv (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_msw_validacion (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_msw_validacion (char,char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_tae_catrespws (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtiene_tae_catrespws (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_tae_catrespws (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtienefolio_tae () to "public" as "informix";
grant  execute on function "informix".sp_obtienefolio_tae () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienefolio_tae () to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciontae (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciontae (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciontae (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportecobranzasucursal (char,date,date,smallint,smallint) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportecobranzasucursal (char,date,date,smallint,smallint) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualtae (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportemensualtae (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportemensualtae (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanaltae (char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportesemanaltae (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportesemanaltae (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tramacomunicacionemex (char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_tramacomunicacionemex (char,char,char,char,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_tramacomunicacionemex (char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf (char) to "public" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultaconceptogdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaempleadowu (char,char,char,char,smallint) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultaempleadowu (char,char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,char,char) to "public" as "informix";
grant  execute on procedure "informix".sp_bitacoraspj (integer,char,date,char,char,char,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_bitacoraspj (integer,char,date,char,char,char,char) to "public" as "informix";
grant  execute on procedure "informix".sp_bitacoraspj (integer,char,date,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sac_bts_movspaso (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sac_bts_movspaso (char) to "public" as "informix";
grant  execute on function "informix".sac_bts_movspaso (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_odp_pld (char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_odp_pld (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_odp_pld (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_repormovhistbts () to "c90306542" as "informix";
grant  execute on function "informix".sp_repormovhistbts () to "public" as "informix";
grant  execute on function "informix".sp_repormovhistbts () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizasac_wu_search (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_wu_search (date) to "public" as "informix";
grant  execute on function "informix".sp_actualizasac_wu_search (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_comparacaracteresbts (char,char) to "public" as "informix";
grant  execute on function "informix".sp_comparacaracteresbts (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_comparacaracteresbts (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_comparadesfasamientobanco (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_comparadesfasamientobanco (char,char) to "public" as "informix";
grant  execute on function "informix".sp_comparadesfasamientobanco (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_comparadesfasamientobts (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_comparadesfasamientobts (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_comparadesfasamientobts (char,char) to "public" as "informix";
grant  execute on function "informix".sp_calculadvsky (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculadvsky (char) to "public" as "informix";
grant  execute on function "informix".sp_calculadvsky (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal_soc (char,char,date,date,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal_soc (char,char,date,date,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal_soc (char,char,date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportedetalletransucursalsac (char,char,char,char,date,date,integer,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_reportedetalletransucursalsac (char,char,char,char,date,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportedetalletransucursalsac (char,char,char,char,date,date,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_payc (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_payc (date) to "public" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_payc (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_sdep (date) to "public" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_sdep (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_sdep (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_insertaerrorwu (integer,char,char,char,char,char,char,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_insertaerrorwu (integer,char,char,char,char,char,char,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_insertaerrorwu (integer,char,char,char,char,char,char,char,datetime) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_genarchivomonitoreosearchpaywu () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_genarchivomonitoreosearchpaywu () to "c90306542" as "informix";
grant  execute on function "informix".sp_genarchivomonitoreosearchpaywu () to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesabts (char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesabts (char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_remesasbtsaut_pld (date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_remesasbtsaut_pld (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesasbtsaut_pld (date,date) to "public" as "informix";
grant  execute on function "informix".sp_app_mensajes (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_mensajes (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_mensajes (char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_app_queryorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_app_queryorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_submitpayment (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_app_submitpayment (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_app_submitpayreversal (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_app_submitpayreversal (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_submitpayreversal (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consdatosticketapp (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdatosticketapp (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consdatosticketapp (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_pagaenvios (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_pagaenvios (char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_pagaenvios (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consflag_respuesta (char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consflag_respuesta (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consflag_respuesta (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_insertaconciliaciontotalporconvenio () to "public" as "informix";
grant  execute on function "informix".sp_insertaconciliaciontotalporconvenio () to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncrediavan (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncrediavan (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_crediavance (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_crediavance (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_valmonto (char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesabts (char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal_pbahtm (char,char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal_pbahtm (char,char,date,date,smallint) to "public" as "informix";
grant  execute on function "informix".sp_obtienelineabase_bpi (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtienelineabase_bpi (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesaswu_pld (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_remesaswu_pld (char,date,date) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionmegacable (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionmegacable (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzagobjalisco (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzagobjalisco (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongjalisco (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongjalisco (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_gobjalisco (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_gobjalisco (char,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongobsinaloa (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciongobsinaloa (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_gobsinaloa (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_gobsinaloa (char,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzagobsinaloa (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzagobsinaloa (char) to "public" as "informix";
grant  execute on function "informix".sp_sacreportedetalletransaccionsucursal (char,char,date,date) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncoppelcom (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncoppelcom (char) to "public" as "informix";
grant  execute on function "informix".sp_repmen_remesasporsuc (date) to "public" as "informix";
grant  execute on function "informix".sp_repmen_remesasporsuc (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_inicializatablaspld (char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_inicializatablaspld (char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_domi_ord_remesas_wu () to "c90306542" as "informix";
grant  execute on function "informix".sp_domi_ord_remesas_wu () to "public" as "informix";
grant  execute on function "informix".sp_domi_ord_remesas_bts () to "c90306542" as "informix";
grant  execute on function "informix".sp_domi_ord_remesas_bts () to "public" as "informix";
grant  execute on function "informix".sp_domi_ord_remesas_app () to "c90306542" as "informix";
grant  execute on function "informix".sp_domi_ord_remesas_app () to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_bcpl_cpl_rep () to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_bcpl_cpl_rep () to "c90306542" as "informix";
grant  execute on function "informix".sp_inicializatablas_concbcpl (char,date) to "systelmex" as "informix";
grant  execute on function "informix".sp_inicializatablas_concbcpl (char,date) to "public" as "informix";
grant  execute on function "informix".sp_inicializatablas_concbcpl (char,date) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaemprendamosfin (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaemprendamosfin (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_emprndmsfin (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_emprndmsfin (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionemprendam (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionemprendam (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva (char,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_calcularcomisioniva (char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_decodificadatospermisosadmintemrevo (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatospermisosadmintemrevo (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_datos (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_datos (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_bcpl_cpl () to "c90306542" as "informix";
grant  execute on function "informix".sp_conciliacion_bcpl_cpl () to "public" as "informix";
grant  execute on function "informix".sp_calculadvarabela (char) to "public" as "informix";
grant  execute on function "informix".sp_calculadvarabela (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_carac_msw (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_carac_msw (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_calculadveci (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculadveci (char) to "public" as "informix";
grant  execute on function "informix".sp_cfe_validadv_bpi (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cfe_validadv_bpi (char,char) to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_bcpl_cpl_sig_dia () to "public" as "informix";
grant  execute on function "informix".sp_conciliacion_bcpl_cpl_sig_dia () to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_depinfonavitdv (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_depinfonavitdv (char,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionhipinfona (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionhipinfona (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondepinfona (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidaciondepinfona (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardarespdespagosky (char,char,char,char,datetime,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardarespdespagosky (char,char,char,char,datetime,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_solpagoskyonline (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_solpagoskyonline (char) to "public" as "informix";
grant  execute on function "informix".sp_validadllsky () to "c90306542" as "informix";
grant  execute on function "informix".sp_validadllsky () to "public" as "informix";
grant  execute on function "informix".sp_escenariosmswtae (char,char,char,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_escenariosmswtae (char,char,char,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_tramaconsultatae (char,char,char,char,char,date,integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tramaconsultatae (char,char,char,char,char,date,integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tramarecargatae (char,char,char,char,char,date,integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tramarecargatae (char,char,char,char,char,date,integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_payi (date) to "public" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_payi (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_wu_pay (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_wu_pay (date) to "public" as "informix";
grant  execute on function "informix".sp_consulta_sac_cte_mnsj_remesas (smallint,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_sac_cte_mnsj_remesas (smallint,smallint) to "public" as "informix";
grant  execute on function "informix".sp_replicaconvenios (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_replicaconvenios (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_cte_remesa (char,char,char,char,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_consrevrem (char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_consrevrem (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaderechosvariosgdf_bpi (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaderechosvariosgdf_bpi (char) to "public" as "informix";
grant  execute on function "informix".sp_bitacora_proceso (varchar,integer,integer,varchar,varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bitacora_proceso (varchar,integer,integer,varchar,varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_reportewu_edocta (date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportewu_edocta (date,date,char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacp_pba (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacp_pba (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validadllsky_lib () to "public" as "informix";
grant  execute on function "informix".sp_validadllsky_lib () to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta (date) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_conciliadeta (date) to "public" as "informix";
grant  execute on function "informix".sp_yvesrocher_valdv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_yvesrocher_valdv (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacam (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacam (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacarnival (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacarnival (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadyclass (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadyclass (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaaxtel (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaaxtel (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppel (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppel (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzamastv (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzamastv (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzasolfi (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzasolfi (char) to "public" as "informix";
grant  execute on function "informix".sp_prefijos_cvecobrem (char,char) to "public" as "informix";
grant  execute on function "informix".sp_prefijos_cvecobrem (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genrephompag (char) to "public" as "informix";
grant  execute on function "informix".sp_genrephompag (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_consultaenvios (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_consultaenvios (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_consucursales (varchar) to "public" as "informix";
grant  execute on function "informix".sp_sac_consucursales (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_validamontos (char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtdeserrorsky (char) to "public" as "informix";
grant  execute on function "informix".sp_obtdeserrorsky (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confpgserv_dina (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_confpgserv_dina (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confpagocoppel (char,int8) to "c90306542" as "informix";
grant  execute on function "informix".sp_confpagocoppel (char,int8) to "public" as "informix";
grant  execute on function "informix".sp_obtieneparametro (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtieneparametro (integer) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_validanombre (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_validanombre (char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienefoliocoppel () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienefoliocoppel () to "public" as "informix";
grant  execute on function "informix".sp_calcula_comisiones (char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_calcula_comisiones (char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienedatosconexionservcruzados () to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienedatosconexionservcruzados () to "public" as "informix";
grant  execute on function "informix".sp_reportebts_conciliacion (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportebts_conciliacion (date,date) to "public" as "informix";
grant  execute on function "informix".sp_app_queryorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_ws_login (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_ws_login (char,char,char,char,char,char,char) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_ws_login (char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_linea_base_principal (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_linea_base_principal (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_guardasoldespagosky (money,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardasoldespagosky (money,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardasolpagosky (char,char,char,datetime,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardasolpagosky (char,char,char,datetime,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardaresppagosky (char,char,char,char,datetime,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardaresppagosky (char,char,char,char,datetime,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ws_consultacte (char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ws_consultacte (char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_ws_consultadircte (char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ws_consultadircte (char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultaempleadowu (char,char,char,char,smallint,char) to "public" as "informix";
grant  execute on function "informix".sp_consultasucursalappriza (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultasucursalappriza (char,char) to "public" as "informix";
grant  execute on function "informix".sp_genrepremesasbts () to "c90306542" as "informix";
grant  execute on function "informix".sp_genrepremesasbts () to "public" as "informix";
grant  execute on function "informix".sp_genrepremesasbts_especial (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_genrepremesasbts_especial (date,date) to "public" as "informix";
grant  execute on function "informix".sp_consultasucursal (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultasucursal (char) to "public" as "informix";
grant  execute on function "informix".sp_cp_consultactecoppel (varchar) to "public" as "informix";
grant  execute on function "informix".sp_cp_consultactecoppel (varchar) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacablemas (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacablemas (char) to "public" as "informix";
grant  execute on function "informix".sp_genrepordenespago () to "public" as "informix";
grant  execute on function "informix".sp_genrepordenespago () to "c90306542" as "informix";
grant  execute on function "informix".sp_genrepordenespago_especial (date,date) to "public" as "informix";
grant  execute on function "informix".sp_genrepordenespago_especial (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizaremesa (char,char,char,char,char,char,char,date,varchar,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizaremesa (char,char,char,char,char,char,char,date,varchar,money) to "public" as "informix";
grant  execute on function "informix".sp_grabaremadic (char,char,char,char,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabaremadic (char,char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_obtienedatosremaut (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienedatosremaut (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtieneremadic (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtieneremadic (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienerfcremesa (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_truncaremadic () to "public" as "informix";
grant  execute on function "informix".sp_truncaremadic () to "c90306542" as "informix";
grant  execute on function "informix".sp_guardarespuestaqryi (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_reversion (char,char,char,char,char) to "ifxcons" as "informix";
grant  execute on function "informix".sp_reversion (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reversion (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_search (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_reversionsac (char,char,char,char) to "syssifn_app" as "informix";
grant  execute on function "informix".sp_reversionsac (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reversionsac (char,char,char,char) to "ifxcons" as "informix";
grant  execute on function "informix".sp_reversionsac (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienerfcremesa (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validarefavon (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validarefavon (char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontos (char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_app_valmonto_aut (char,char,char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesabts_aut (char,char,char,char,char,money) to "public" as "informix";
grant  execute on function "informix".sp_app_valdigito (char) to "public" as "informix";
grant  execute on function "informix".sp_app_valdigito (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ws_coppel_ta (char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bitacoraws_antad (char,char,char,char,date,char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_bitacoraws_antad (char,char,char,char,date,char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_escenariosmsw_antad (char,char,char,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_escenariosmsw_antad (char,char,char,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_antadcatrespws (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_antadcatrespws (char,integer) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionantad (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionantad (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaselecciones (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaselecciones (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionseleccion (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacionseleccion (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_selecciones (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_selecciones (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_valmonto_aut (char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesabts_aut (char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_wu_reasoncode (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_wu_reasoncode (varchar) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_cancelpay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_cancelpay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_confpago_remesa (char) to "public" as "informix";
grant  execute on function "informix".sp_validanombenefbts (char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validanombenefbts (char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_segundaautenticawu (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_segundaautenticawu (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_verificaconvenio (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_verificaconvenio (char) to "public" as "informix";
grant  execute on function "informix".sp_generarreporteremesas () to "c90306542" as "informix";
grant  execute on function "informix".sp_generarreporteremesas () to "public" as "informix";
grant  execute on function "informix".sp_genrep_benefremesas (date,date) to "public" as "informix";
grant  execute on function "informix".sp_genrep_benefremesas (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_repor_ord_pago () to "public" as "informix";
grant  execute on function "informix".sp_repor_ord_pago () to "c90306542" as "informix";
grant  execute on function "informix".sp_confpago_remesa (char,char,char,char,char,char,char,char,char,char,datetime,datetime,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_search (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,datetime,datetime) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu (char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_numerocteremesa (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_numerocteremesa (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncontigo (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncontigo (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_contigo (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_contigo (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_cte_remesa (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_cte_remesa (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_submitpayment (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_confpago_remesa (char,char,char,char,char,char,char,char,char,char,datetime,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppelcom (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacoppelcom (char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_coppel_com (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_coppel_com (char) to "public" as "informix";
grant  execute on function "informix".sp_app_obtieneinfoidentificacion (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_obtieneinfoidentificacion (char,char) to "public" as "informix";
grant  execute on function "informix".sp_ctrl_ind_ctes_servs (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ctrl_ind_ctes_servs (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_altactes_aper_prods (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_altactes_aper_prods (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtienedatosusrl (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienedatosusrl (char) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_altactes_por_minuto (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_altactes_por_minuto (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_altaremesas_por_minuto (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_altaremesas_por_minuto (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_cte_remesa (char,char,char,char,char,date,char,char,char,date,char,char,char,char,char,char,char,char,char,integer,char,integer,char,char,char,char,char,char,char,char,char,integer,char,char,date,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_ws_coppel_ta (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_grabapgserv_dina (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapgserv_dina (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_consultacomplementodatos (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultacomplementodatos (char) to "public" as "informix";
grant  execute on function "informix".sp_alta_cardif (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_alta_cardif (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_renovacion_cardif (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_renovacion_cardif (char,char,char,char,char,char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncardif (char) to "public" as "informix";
grant  execute on procedure "informix".sp_reporteliquidacioncardif (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reverso_cardif (char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reversa_remesas_web (char,char,char,char,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_reversa_remesas_web (char,char,char,char,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_pago_appriza_web (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,char,date,char,char,char,char,char,char,char,char,char,money,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,smallint,char,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_servicios (char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,money,money,money,money,smallint,integer,char,char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_pago_servicios (char,char,char,char,char,char,char,char,char,integer,money,char,char,char,char,char,money,money,money,money,smallint,integer,char,char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaestadosucursalbts (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaestadosucursalbts (char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_cancelarordenpago_acuenta (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_cancelarordenpago_acuenta (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargaarchivoaconciliacionbcpl (date) to "public" as "informix";
grant  execute on function "informix".sp_cargaarchivoaconciliacionbcpl (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_qryi (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizasac_bts_qryi (date) to "public" as "informix";
grant  execute on function "informix".sp_registra_unica (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_unica (char) to "public" as "informix";
grant  execute on function "informix".sp_pago_wu_web (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,integer,char,char,char,char,datetime,datetime,char,char,char,char,money,money,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_insertaremesasnoconciliadaswu_pba (date,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_insertaremesasnoconciliadaswu_pba (date,date,char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacrediavance (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacrediavance (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacrediavancedospm (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacrediavancedospm (char) to "public" as "informix";
grant  execute on function "informix".sp_calculadvdish (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculadvdish (char) to "public" as "informix";
grant  execute on function "informix".sp_tramaconsulta_dish (char,char,char,char,char,date,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_tramaconsulta_dish (char,char,char,char,char,date,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_respuesta_ws_dish (char,char,char,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_respuesta_ws_dish (char,char,char,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_pagos_activos_msw (char) to "public" as "informix";
grant  execute on function "informix".sp_pagos_activos_msw (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_consrevrem_web (char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_consrevrem_web (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdatosticketapp_web (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consdatosticketapp_web (char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_intrfz_serv_web (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_intrfz_serv_web (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_msw_validacion_web (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_megacable (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_dv_megacable (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_megacable_cpl (char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_dv_megacable_cpl (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_nac_migrante (varchar) to "public" as "informix";
grant  execute on function "informix".sp_buscar_nac_migrante (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_estatus_cardif () to "public" as "informix";
grant  execute on function "informix".sp_actualiza_estatus_cardif () to "c90306542" as "informix";
grant  execute on function "informix".sp_confpagoservicio (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confpagoservicio (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_pldlim_teldom (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_pldlim_teldom (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_reportebts_diario (date) to "public" as "informix";
grant  execute on function "informix".sp_reportebts_diario (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consflag_respuesta_web (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consflag_respuesta_web (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporteapp_diario (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteapp_diario (date) to "public" as "informix";
grant  execute on function "informix".sp_guarda_tmpresponsecardif (char,char) to "public" as "informix";
grant  execute on function "informix".sp_guarda_tmpresponsecardif (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reverso_cardif (char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_cons_hist_remweb () to "c90306542" as "informix";
grant  execute on function "informix".sp_cons_hist_remweb () to "public" as "informix";
grant  execute on function "informix".sp_reporte_tran_cardif (date) to "public" as "informix";
grant  execute on function "informix".sp_reporte_tran_cardif (date) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzamegacable (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzamegacable (char) to "public" as "informix";
grant  execute on function "informix".sp_pago_cardif (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,integer,money,money,money,money,smallint,char,char,char,char,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_cardif (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,integer,money,money,money,money,smallint,char,char,char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cte_ws (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_cte_ws (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_migra_sorteorem () to "public" as "informix";
grant  execute on function "informix".sp_migra_sorteorem () to "c90306542" as "informix";
grant  execute on function "informix".sp_genera_arch_sorteorem (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genera_arch_sorteorem (char) to "public" as "informix";
grant  execute on function "informix".sp_folios_sorteo_remesas (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_folios_sorteo_remesas (date,date) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaremcpl (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaremcpl (char) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_msw_validacion_web (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_sacreportecobranzasucursal_web (char,date,date,smallint,smallint) to "public" as "informix";
grant  execute on function "informix".sp_sacreportecobranzasucursal_web (char,date,date,smallint,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_saccobranzasucursalhis_web (char,date,smallint,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_saccobranzasucursalhis_web (char,date,smallint,smallint) to "public" as "informix";
grant  execute on function "informix".sp_repaudit_ctesidbox (char) to "public" as "informix";
grant  execute on function "informix".sp_repaudit_ctesidbox (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_indicadores_usabilidad_srvs_exp (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_indicadores_usabilidad_srvs_exp (date) to "public" as "informix";
grant  execute on function "informix".sp_indicadores_usabilidad_srvs (date) to "public" as "informix";
grant  execute on function "informix".sp_indicadores_usabilidad_srvs (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportewu_diario (date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportewu_diario (date,char) to "public" as "informix";
grant  execute on function "informix".sp_agentes (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_agentes (char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_registracdep (char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_registracdep (char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_registrasdep (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_registrasdep (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_getorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_getorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_app_confirmorder (char,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_confirmorder (char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_registrardatosarchivo (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_registrardatosarchivo (char) to "public" as "informix";
grant  execute on function "informix".sp_consultacomplementodatos_web (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardaresptelmex (char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_paymentrejection (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_confirmpayment (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_getorderstoreprocess (char,integer,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienelineabase (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizacteremesafh (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_licencias (char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_licencias (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_licencias (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodificadatosimpuestopredial (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatosimpuestopredial (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_obtenerconfiguracionesremesa_wu (integer,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtenerconfiguracionesremesa (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_migrante_cardif (varchar,varchar,varchar,char,char,varchar,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_updgenero_cte_remesa (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_depuracion () to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_agentes_depuracion () to "c90306542" as "informix";
grant  execute on function "informix".sp_benefremesas_app (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_benefremesas_bts (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_es_cliente_remesa (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculadvtelmex (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteremesascomision_pbajj () to "c90306542" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzacoppel_td (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienerecibo (char,varchar) to "public" as "informix";
grant  execute on function "informix".sp_obtienerecibo (char,varchar) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtienerecibo (char,varchar) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_obtienerecibo (char,varchar) to "syspitdc" as "informix";
grant  execute on function "informix".sp_obtienerecibo (char,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtienerecibo (char,varchar) to "sysbts" as "informix";
grant  execute on function "informix".sp_sac_reportediario_seg (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_app_depuracion (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_app_depuracion (date) to "public" as "informix";
grant  execute on function "informix".sp_consulta_suc_rem_cpl (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_suc_rem_cpl (char,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_rep_sem_remesas (date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesasporestado (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesasporestado (date) to "public" as "informix";
grant  execute on function "informix".sp_generaconciliacioncoppel (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaconciliacioncoppel (date) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacontigo (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacontigo (char) to "public" as "informix";
grant  execute on function "informix".sp_ctrl_estadisticas_sac () to "public" as "informix";
grant  execute on function "informix".sp_ctrl_estadisticas_sac (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_anio (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_anio (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_dia (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_dia (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_diasemana (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_diasemana (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_estado (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_estado (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_minuto (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_minuto (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_sucursal (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_altactes_sucursal (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_correos_minuto (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_correos_minuto (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_mnsj_batch_online (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_mnsj_batch_online (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_pagoservicios (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_pagoservicios (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_remesas_estados (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_remesas_estados (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_remesas_minuto (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_remesas_minuto (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_remesas_sucursal (date,date) to "public" as "informix";
grant  execute on function "informix".sp_estadisticas_sac_remesas_sucursal (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_insdatoenv (char,char,char,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,money,char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_insdatoenv (char,char,char,money,money,money,money,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,money,money,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_datoscteremesa (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_datoscteremesa (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confpagoservicio_hs (char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_submitpayment_web (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_guardarespuestapayi2 (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_soldespagoskyonline (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_soldespagoskyonline (char) to "public" as "informix";
grant  execute on function "informix".sp_act_ine_bdrem () to "c90306542" as "informix";
grant  execute on function "informix".sp_act_ine_bdrem () to "public" as "informix";
grant  execute on function "informix".sp_consultacteremesa_identificacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultacteremesa_identificacion (char) to "public" as "informix";
grant  execute on function "informix".sp_insertaerrorws (integer,char,char,char,char,char,char,char,char,char) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_insertaerrorws (integer,char,char,char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_insertaerrorws (integer,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_insertaerrorws (integer,char,char,char,char,char,char,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_insertaerrorws (integer,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_session (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_session (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_valida_session (char,char,char,char,char,char) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzaservcpl () to "public" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzaservcpl () to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzasky (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzasky (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzasuk (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzasuk (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacp (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacp (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadepinfonavit (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadepinfonavit (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadish (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzadish (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaavon (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaavon (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaavondospm (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaavondospm (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacfe (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacfe (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapagoservicio (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapagoservicio (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,date) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaarabela (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaarabela (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzastanhome (char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzastanhome (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzatelmex (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_queryorder_prue (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,smallint) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaeci (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzayvesrocher (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_hipinfonavitdv (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_valida_hipinfonavitdv (char) to "public" as "informix";
grant  execute on function "informix".sp_generaarchivocobranzacontigo18hrs (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacardif (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzacardif (char) to "public" as "informix";
grant  execute on function "informix".sp_saccobranzasucursalhis (char,date,smallint) to "public" as "informix";
grant  execute on function "informix".sp_saccobranzasucursalhis (char,date,smallint,smallint) to "public" as "informix";
grant  execute on function "informix".sp_grabapagoservicio_hs (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,date,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapagoservicio_hs (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,date,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_benefremesas_wu (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_metricas_envio_dinero (char,date,integer) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzagdf (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzagdf (char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_search_web (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char) to "public" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_search_web (char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay_web (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_wu_guardarespuesta_pay_web (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,datetime,char,char,char,char,char,char,char,char,char,char,datetime,char,datetime,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bitacorawstae (char,char,char,char,date,char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_bitacorawstae (char,char,char,char,date,char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_bitacorawstae (char,char,char,char,date,char,char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_inicremesas () to "public" as "informix";
grant  execute on function "informix".sp_inicremesas () to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_conciliaarchivoptc (char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculaprorrateodecomisiones (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_calculaprorrateodecomisiones (date) to "public" as "informix";
grant  execute on function "informix".sp_calculaprorrateodecomisiones (date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_calculaprorrateodecomisiones (date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_generaarchivoscobranzacentral (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_generaarchivoscobranzacentral (date) to "public" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "select_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "syspitdc" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "sysbts" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "all_role_bdisac" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "systelmex" as "informix";
grant  execute on procedure "informix".sp_sac_guardamensajeerror (integer,integer,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tramapago_dish (char,char,char,char,char,date,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_tramapago_dish (char,char,char,char,char,date,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generainformacionreportesespeciales (date) to "public" as "informix";
grant  execute on function "informix".sp_generainformacionreportesespeciales (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizafechassac () to "public" as "informix";
grant  execute on function "informix".sp_actualizafechassac () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizafechassac () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_actualizafechassac () to "c90306542" as "informix";
grant  execute on function "informix".sp_consultadatoswu (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultadatoswu (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consultadatoswu (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_inicializatablasmovimientosdiarios () to "public" as "informix";
grant  execute on function "informix".sp_inicializatablasmovimientosdiarios () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_inicializatablasmovimientosdiarios () to "c90306542" as "informix";
grant  execute on function "informix".sp_app_aplicapago (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_aplicapago (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_aplicapagos (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_aplicapagos (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validamontoremesabts (char,char,char,char,char,char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_validamontoremesawu_web (char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validamontoremesawu_web (char,char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_actualizahistoricodetransacciones (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_liquidacion_homoserv (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_liquidacion_homoserv (char,char) to "public" as "informix";
grant  execute on function "informix".sp_metricas_envio_dinero_mes (date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_appriza_web (char,char,char,char,char,char,char,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_appriza_web (char,char,char,char,char,char,char,char,char,date,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_appriza_web (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,char,date,char,char,char,char,char,char,char,char,char,money,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,smallint,char,char,varchar,varchar,varchar,varchar,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_bts_web (char,char,char,char,char,char,char,char,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_bts_web (char,char,char,char,char,char,char,char,char,char,date,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaantad (char) to "c90306542" as "informix";
grant  execute on procedure "informix".sp_generaarchivocobranzaantad (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_wu_web (char,char,char,char,char,char,char,char,char,char,date,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_wu_web (char,char,char,char,char,char,char,char,char,char,date,char,char,char,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_wu_web (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,integer,char,char,char,char,datetime,datetime,char,char,char,char,money,money,char,char,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_pago_wu_web (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,integer,char,char,char,char,datetime,datetime,char,char,char,char,money,money,char,char,varchar,varchar,varchar,varchar,varchar,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_appriza_web (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,char,date,char,char,char,char,char,char,char,char,char,money,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,smallint,char,char,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_cat_carac_tae (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cfe_validadv_bcpl (char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_cfe_validadv_bcpl (char,char) to "public" as "informix";
grant  execute on function "informix".sp_cfe_validadv_bcpl (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_reimpresion (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_reimpresion (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_reimpresion (char,char,char,integer) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_ws_consultacta (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteremesascomision () to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_mc_dummy (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sac_mc_dummy (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_remesasapp_pld (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_remesasapp_pld (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesasbts_pld (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesasbts_pld (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_trama_pago_antad (char,char,char,char,char,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_trama_pago_antad (char,char,char,char,char,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios (char,money,money,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios (char,money,money,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios (char,money,money,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios3 (money,money,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_insertaenvios3 (money,money,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_principal (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_principal (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_medio (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_medio (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatosregistrocivil (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodificadatosregistrocivil (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_grabapagocoppel_td (smallint,char,integer,smallint,integer,integer,smallint,smallint,char,integer,integer,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_recuperapayment (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportetotalporconvenios (char,char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_sacreportetotalporconvenios (char,char,date,date) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_sacreportetotalporconvenios (char,char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_sacreportetotalporconvenios (char,char,date,date) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_app_valmonto (char,char,char,char,char,char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_reverso_msw (char,char,char,char,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_reverso_msw (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_reverso_msw (char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_sac_bts_sdep () to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_sac_bts_sdep () to "public" as "informix";
grant  execute on function "informix".sp_remesaswu_pld_vg (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_remesaswu_pld_vg (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesaswu_pld_ov (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_remesaswu_pld_ov (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_remesaswu_pld_wu (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_remesaswu_pld_wu (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaremrevbts (char) to "public" as "informix";
grant  execute on function "informix".sp_consultaremrevbts (char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultaremrevbts (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultaremrevbts (char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_consultaremrevbts (char) to "sysbts" as "informix";
grant  execute on function "informix".sp_app_recordorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion () to "c90306542" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion () to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion () to "sysbts" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion () to "public" as "informix";
grant  execute on function "informix".sp_dinya_obtienemovconciliacion () to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_aplicapagos_cred (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_aplicapagos_cred (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_app_aplicapagos_cred (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_app_aplicapagos_cred (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_bts_web (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,smallint,char,char,char,char,char,char,char,char,money,char) to "public" as "informix";
grant  execute on function "informix".sp_pago_bts_web (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,smallint,char,char,char,char,char,char,char,char,money,char,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_pago_bts_web (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,smallint,char,char,char,char,char,char,char,char,money,char,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_asignaanio (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_asignaanio (char) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_otras (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodifica_linea_base_otras (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatosservicioagua (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_decodificadatosservicioagua (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatostramitesvehiculares (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_decodificadatostramitesvehiculares (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_bts_recuperapayc (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bts_recuperapayc (integer,char,char,char) to "all_role_bdisac" as "informix";
grant  execute on function "informix".sp_bts_recuperapayc (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_bts_recuperapayc (integer,char,char,char) to "select_role_bdisac" as "informix";
grant  execute on function "informix".sp_busquedacteremesa_identificacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busquedacteremesa_identificacion (char) to "public" as "informix";
grant  execute on function "informix".sp_validausuarioremesa (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_validausuarioremesa (char,char,char,char,date) to "c90306542" as "informix";
revoke  execute on function "informix".sp_consultacomplementodatos_web (char) from public as "informix";
revoke  execute on function "informix".sp_guardaresptelmex (char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_app_paymentrejection (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_app_confirmpayment (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_app_getorderstoreprocess (char,integer,char,char) from public as "informix";
revoke  execute on function "informix".sp_obtienelineabase (char,char) from public as "informix";
revoke  execute on function "informix".sp_actualizacteremesafh (date,date) from public as "informix";
revoke  execute on function "informix".sp_obtenerconfiguracionesremesa_wu (integer,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_obtenerconfiguracionesremesa (integer,char) from public as "informix";
revoke  execute on function "informix".sp_buscar_migrante_cardif (varchar,varchar,varchar,char,char,varchar,date,integer) from public as "informix";
revoke  execute on function "informix".sp_updgenero_cte_remesa (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_wu_depuracion () from public as "informix";
revoke  execute on function "informix".sp_sac_agentes_depuracion () from public as "informix";
revoke  execute on function "informix".sp_benefremesas_app (date,date) from public as "informix";
revoke  execute on function "informix".sp_benefremesas_bts (date,date) from public as "informix";
revoke  execute on function "informix".sp_valida_es_cliente_remesa (char) from public as "informix";
revoke  execute on function "informix".sp_calculadvtelmex (char) from public as "informix";
revoke  execute on function "informix".sp_reporteremesascomision_pbajj () from public as "informix";
revoke  execute on function "informix".sp_generaarchivocobranzacoppel_td (char) from public as "informix";
revoke  execute on function "informix".sp_sac_reportediario_seg (date) from public as "informix";
revoke  execute on function "informix".sp_sac_rep_sem_remesas (date,integer) from public as "informix";
revoke  execute on function "informix".sp_confpagoservicio_hs (char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_app_submitpayment_web (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,date,char,char,char,char,char,char) from public as "informix";
revoke  execute on procedure "informix".sp_generaarchivocobranzatelmex (char) from public as "informix";
revoke  execute on function "informix".sp_app_queryorder_prue (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,smallint) from public as "informix";
revoke  execute on procedure "informix".sp_generaarchivocobranzaeci (char) from public as "informix";
revoke  execute on procedure "informix".sp_generaarchivocobranzayvesrocher (char) from public as "informix";
revoke  execute on function "informix".sp_generaarchivocobranzacontigo18hrs (char) from public as "informix";
revoke  execute on function "informix".sp_benefremesas_wu (date,date) from public as "informix";
revoke  execute on function "informix".sp_status_remesasapp () from public as "informix";
revoke  execute on function "informix".sp_metricas_envio_dinero (char,date,integer) from public as "informix";
revoke  execute on function "informix".sp_sac_pago_atm_infonavit (char,char,char,char,char,char,char,char,date,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,decimal,char,char,char,integer,char,char,char,char,integer,decimal,decimal,decimal,integer,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,integer,integer,integer,integer,datetime,date,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_valida_ctesremesas (char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_valida_ctehuella_comp (char) from public as "informix";
revoke  execute on function "informix".sp_sac_conciliaarchivoptc (char,date) from public as "informix";
revoke  execute on function "informix".sp_aplica_pago_msw (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_reverso_remesas_cpl (char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_pldlim_teldom_cpl (varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar) from public as "informix";
revoke  execute on procedure "informix".sp_generaarchivocobranzahipinfonavit (char) from public as "informix";
revoke  execute on function "informix".sp_sacreportedetalletransaccionsucursal2 (char,char,date,date,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_actualizahistoricodetransacciones (date) from public as "informix";
revoke  execute on function "informix".sp_liq_com_cte_cfe (char) from public as "informix";
revoke  execute on function "informix".sp_sac_insertaremesasnoconciliadaswu (date,date,char) from public as "informix";
revoke  execute on function "informix".sp_liqui_comision_sky (char,char) from public as "informix";
revoke  execute on function "informix".sp_metricas_envio_dinero_mes (date) from public as "informix";
revoke  execute on function "informix".sp_consulta_wu_abmt (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_cat_carac_tae (char,char,char) from public as "informix";
revoke  execute on function "informix".extrae_cont (char,smallint,money,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_procesocierresac (char) from public as "informix";
revoke  execute on function "informix".sp_ws_consultacta (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_reporteremesascomision () from public as "informix";
revoke  execute on function "informix".sp_conciliacion_tae_tapi () from public as "informix";
revoke  execute on function "informix".sp_decodifica_linea_base_licencias_permanentes (char,char,integer) from public as "informix";
revoke  execute on function "informix".sp_consrempag (char,date) from public as "informix";
revoke  execute on function "informix".sp_aplica_pago_con_cargo_msw (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_grabapagocoppel_td (smallint,char,integer,smallint,integer,integer,smallint,smallint,char,integer,integer,date) from public as "informix";
revoke  execute on function "informix".sp_app_recuperapayment (integer,char,char,char) from public as "informix";
revoke  execute on procedure "informix".sp_generaarchivocobranzatae (char) from public as "informix";
revoke  execute on function "informix".sp_dinya_obtenerenviospagos (char,char,char,char,char,char,char,char,date,date,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_cardif_nuevolm (char,char,char,char,char,date) from public as "informix";
revoke  execute on function "informix".sp_consulta_cardif (char,char,char,char,char,date) from public as "informix";
revoke  execute on function "informix".sp_conciliacion_telcel (date) from public as "informix";
revoke  execute on function "informix".sp_pago_wu_abmt (char,char,char,char,char,char,char,char,char,char,money,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,date,char,char,char,integer,money,char,char,char,char,char,char,integer,money,money,money,integer,char,char,char,char,char,char,char,char,money,money,char,char,varchar,varchar,varchar,varchar,varchar,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_app_recordorder (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_qry_statusrem (char) from public as "informix";
revoke  execute on function "informix".sp_sac_pay_statusrem (char) from public as "informix";
revoke  execute on function "informix".sp_sac_rev_statusrem (char) from public as "informix";
revoke  execute on function "informix".sp_consulta_cardif_testhmd (varchar,varchar,varchar,varchar,varchar,date) from public as "informix";
revoke  execute on function "informix".sp_consulta_remesas_cpl (char,char,char,char,char,char,char,char,char,date,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_param_remesas_cpl (char,char) from public as "informix";
revoke  execute on function "informix".sp_pago_remesas_cpl (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,date,char,char,char,char,char,char,char,char,char,money,char,char,varchar,varchar,varchar,varchar,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_alta_ctesremesas (char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,char,integer,char,char,char,char,char,char,char,char,char,integer,char,char,char,integer,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,char,integer,integer,integer,integer,integer,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_asignaaniopredial (char) from public as "informix";
revoke  execute on function "informix".sp_saccobranzasucursalhis (varchar,date,smallint) from public as "informix";
revoke  execute on function "informix".sp_saccobranzasucursalhis (varchar,date,smallint,smallint) from public as "informix";
revoke  execute on function "informix".sp_pago_remesas_cpl (char,char,char,char,char,char,decimal,decimal,decimal,decimal,decimal,char,char,char,date,char,char,char,char,char,char,char,char,char,char,money,char,char,varchar,varchar,varchar,varchar,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_tae_notifications (char) from public as "informix";
revoke  execute on function "informix".sp_app_valmonto_cpl (char,char,char,char,char,char,char,char,char,char,money,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_valida_ctesremesas_ob (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_sac_consulta_ctesremesas (char,char,char,char,char,char,char,char,char,char,char,char,char,char) from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


grant select on "informix".numerador to "ifxcons" as "informix";
grant select on "informix".numerador to "ifxconsacc" as "informix";
grant select on "informix".numerador to "ifxdesaa" as "informix";
grant alter on "informix".numerador to "ifxdesaa" as "informix";
grant select on "informix".numerador to "ifxprod" as "informix";
grant alter on "informix".numerador to "ifxprod" as "informix";
grant select on "informix".numerador to "public" as "informix";
grant select on "informix".numerador to "sysctrlinfo" as "informix";
grant select on "informix".numerador to "syspitdc" as "informix";
create index "informix".idx_sac_convenios on "informix".sac_convenios 
    (numconvenio,numcategoria) using btree  in datos03;
create index "informix".idxsac_conv3 on "informix".sac_convenios 
    (nomconvenio) using btree  in datos00;
create index "informix".idx_mensajeerror1 on "informix".sac_mensajeerror 
    (fecha) using btree  in datos00;
create index "informix".idx_mensajeerror2 on "informix".sac_mensajeerror 
    (fecha_insert) using btree  in datos00;
create index "informix".idx_mensajeerror3 on "informix".sac_mensajeerror 
    (sql_error) using btree  in datos00;
create index "informix".idxkeyx on "informix".sac_liquidacionestelmex 
    (keyx) using btree  in datos00;
create index "informix".idx_movdethis on "informix".tmpsac_movimientosdetallehistorial 
    (clave,tipomovimiento,movtoseguro,sucursal) using btree  
    in datos00;
create index "informix".idx_actsucu on "informix".sac_actualizacionsucursales 
    (numsucursal) using btree  in datos00;
create index "informix".idxsc_par on "informix".sac_param (cod_param) 
    using btree  in datos00;
create index "informix".idx_sacmovhissuc on "informix".sac_movhissuc 
    (folio_suc) using btree  in datos00;
create index "informix".idx_sacmovhissuc2 on "informix".sac_movhissuc 
    (sucursal,fech_alt) using btree  in datos00;
create index "informix".idx_eg_arch on "informix".sac_eglobal_archivos 
    (nombre_archivo,estatus) using btree  in datos00;
create index "informix".idx_eg_banco on "informix".sac_eglobal_banco 
    (idbanco,banco) using btree  in datos00;
create index "informix".idxebco on "informix".sac_eglobal_banco 
    (cod_reg) using btree  in datos00;
create index "informix".idx_eg_detalle on "informix".sac_eglobal_detalle 
    (nombre_archivo,fecha_archivo) using btree  in datos00;
create index "informix".idxfarch on "informix".sac_eglobal_detalle 
    (fecha_archivo) using btree  in datos00;
create index "informix".idx_eg_encabezado on "informix".sac_eglobal_encabezado 
    (nombre_archivo) using btree  in datos00;
create index "informix".idx_eg_mensajes on "informix".sac_eglobal_mensajes_error 
    (cod_ret,modulo) using btree  in datos00;
create index "informix".idx_eg_noconcil on "informix".sac_eglobal_noconcil 
    (nombre_archivo,fecha_archivo) using btree  in datos00;
create index "informix".idxfar on "informix".sac_eglobal_noconcil 
    (fecha_archivo) using btree  in datos00;
create index "informix".idx_eg_sumario on "informix".sac_eglobal_sumario 
    (nombre_archivo) using btree  in datos00;
create index "informix".idx_eg_reporte on "informix".sac_reporte 
    (tipo,cod_registro,num_tarjeta) using btree  in datos00;
create index "informix".idxid_cov on "informix".sac_comisiones 
    (id_convenio) using btree  in datos00;
create index "informix".idxsac_conm1 on "informix".sac_comisiones 
    (id_convenio,montominimo) using btree  in datos00;
create index "informix".indx_sacident on "informix".sac_identificacion 
    (identificacion,id_type_cd) using btree  in datos00;
create index "informix".idx_limite_ben_sac_enviosdineroya on 
    "informix".sac_enviosdineroya (pri_nom_ben,apell_pat_ben,estatus,
    fecha_envio) using btree  in datos00;
create index "informix".idx_limite_rem_sac_enviosdineroya on 
    "informix".sac_enviosdineroya (pri_nom_rem,apell_pat_rem,estatus,
    fecha_envio) using btree  in datos00;
create index "informix".idxsac_envdinya13_1 on "informix".sac_enviosdineroya 
    (no_control,estatus) using btree  in datos00;
create index "informix".idxsac_envdinya23_1 on "informix".sac_enviosdineroya 
    (fecha_envio,estatus) using btree  in datos00;
create index "informix".idx_limite_ben_sac_enviosdineroyahis 
    on "informix".sac_enviosdineroyahis (pri_nom_ben,apell_pat_ben,
    estatus,fecha_envio) using btree  in datos00;
create index "informix".idx_limite_rem_sac_enviosdineroyahis 
    on "informix".sac_enviosdineroyahis (pri_nom_rem,apell_pat_rem,
    estatus,fecha_envio) using btree  in datos00;
create index "informix".idxenv_his on "informix".sac_enviosdineroyahis 
    (fecha_insert) using btree  in datos00;
create index "informix".idxsac_envdinyahis13_1 on "informix".sac_enviosdineroyahis 
    (no_control,estatus) using btree  in datos00;
create index "informix".idxsac_envdinyahis23_1 on "informix".sac_enviosdineroyahis 
    (fecha_envio,estatus) using btree  in datos00;
create index "informix".idx_sacliqmesdish on "informix".sac_liquidacionmensualdish 
    (aniomes) using btree  in datos00;
create index "informix".idx_sacliqmesmastv on "informix".sac_liquidacionmensualmastv 
    (aniomes) using btree  in datos00;
create index "informix".idx_sacliqmessky on "informix".sac_liquidacionmensualsky 
    (aniomes) using btree  in datos00;
create index "informix".idxsemsky on "informix".sac_liquidacionsemanalsky 
    (keyx) using btree  in datos00;
create index "informix".idx_logenv on "informix".sac_log_envios 
    (folio_suc) using btree  in datos00;
create index "informix".edos_index on "informix".sac_bts_catestados 
    (cve_estado) using btree  in datos00;
create index "informix".tm_op on "informix".sac_bts_catmensajes 
    (agent_trans_type_code,opcode) using btree  in datos00;
create index "informix".inx_encabezado on "informix".sac_bts_encabezado 
    (from,to,user_domain,user_name) using btree  in datos00;
create index "informix".usrl_indx on "informix".sac_bts_usrl (agent_trans_type_code,
    agent_cd) using btree  in datos00;
create index "informix".strem_indx on "informix".sac_bts_catstatusremesas 
    (dans_status_code) using btree  in datos00;
create index "informix".idx_rmbtspayi on "informix".sac_bts_payi 
    (agent_dt,opcode) using btree  in datos00;
create index "informix".idx_sac_bts_fec_cte on "informix".sac_bts_payi 
    (fecha_insert,numcte) using btree  in dbs_idxinteg;
create index "informix".idx_sac_bts_pay_new on "informix".sac_bts_payi 
    (confirmation_nm,bank_ref_nm,r_first_name,r_middle_name,r_last_name) 
    using btree  in dbs_movhis_idx4;
create index "informix".idx_sac_bts_payi on "informix".sac_bts_payi 
    (confirmation_nm,bank_ref_nm,opcode) using btree  in datos00;
    
create index "informix".idx_sac_bts_payi1 on "informix".sac_bts_payi 
    (agent_trans_type_code,agent_cd,confirmation_nm,terminal) 
    using btree  in datos00;
create index "informix".idx_sac_bts_payi2 on "informix".sac_bts_payi 
    (confirmation_nm,bank_ref_nm,opcode,process_dt) using btree 
     in datos00;
create index "informix".idx_sac_bts_payi3 on "informix".sac_bts_payi 
    (opcode,fecha_insert) using btree  in datos00;
create index "informix".idx_sac_bts_payi4 on "informix".sac_bts_payi 
    (agent_dt,r_first_name,r_middle_name,r_last_name,r_mother_m_name,
    r_fecha_nac,opcode) using btree  in datos00;
create index "informix".idxsac_bts_payifi on "informix".sac_bts_payi 
    (r_fecha_nac,r_identif_nm) using btree  in datos00;
create index "informix".idxsac_bts_payific on "informix".sac_bts_payi 
    (r_fecha_nac,r_identif_nm,confirmation_nm) using btree  in 
    datos00;
create index "informix".idx_btsqryi on "informix".sac_bts_qryi 
    (confirmation_nm,opcode) using btree  in datos00;
create index "informix".idx_rmbtsqryi on "informix".sac_bts_qryi 
    (agent_dt,opcode) using btree  in datos00;
create index "informix".idx_sac_bts_1 on "informix".sac_bts_qryi 
    (fecha_insert) using btree  in dbs_cfd_05;
create index "informix".idx_sac_bts_2 on "informix".sac_bts_qryi 
    (confirmation_nm) using btree  in dbs_cfd_05;
create index "informix".idx_sac_bts_qryi on "informix".sac_bts_qryi 
    (agent_trans_type_code,agent_cd,confirmation_nm,user_name) 
    using btree  in datos00;
create index "informix".idx_sac_bts_qryi_test on "informix".sac_bts_qryi 
    (agent_dt) using btree  in datos00;
create index "informix".idxsac_bts_qryi_06 on "informix".sac_bts_qryi 
    (opcode,fecha_insert) using btree  in dbs_movhis_idx5;
create index "informix".idx_rmbtsrevi on "informix".sac_bts_revi 
    (agent_dt,opcode) using btree  in datos00;
create index "informix".idx_sac_bts_revi on "informix".sac_bts_revi 
    (agent_trans_type_code,agent_cd,confirmation_nm,terminal) 
    using btree  in datos00;
create index "informix".idx_sac_bts_revi1 on "informix".sac_bts_revi 
    (confirmation_nm,bank_ref_nm,opcode) using btree  in datos00;
    
create index "informix".idx_sac_bts_revi2 on "informix".sac_bts_revi 
    (opcode,fecha_insert) using btree  in datos00;
create index "informix".idx_ptcta on "informix".sac_catalogo_pt 
    (cuenta) using btree  in datos00;
create index "informix".idxsac_movhis234 on "informix".sac_movimientoshistorial 
    (numcategoria,numconvenio,referencia1) using btree  in datos00;
    
create index "informix".idxsac_movhis235 on "informix".sac_movimientoshistorial 
    (fecha_pago) using btree  in datos00;
create index "informix".idxsac_movhis236 on "informix".sac_movimientoshistorial 
    (numcategoria,numconvenio,fecha_pago,status_cancelado,flag_confirmacion_central,
    flag_confirmacion_sucursal,origen) using btree  in datos00;
    
create index "informix".idxsac_movhis237 on "informix".sac_movimientoshistorial 
    (fecha_insert,numcategoria,numconvenio,id_sucursal,status_cancelado) 
    using btree  in datos00_idx;
create index "informix".idxsac_movhisfe on "informix".sac_movimientoshistorial 
    (numcategoria,numconvenio,fecha_pago) using btree  in datos00;
    
create index "informix".idx_sacliqsem on "informix".sac_liquidacionsemanal 
    (id_convenio,consecutivo_convenio) using btree  in datos00;
    
create index "informix".idx_sacliqmes on "informix".sac_liquidacionmensual 
    (id_convenio,aniomes) using btree  in datos00;
create index "informix".idx_bts_cdep3 on "informix".sac_bts_cdep 
    (num_confirmacion,opcode) using btree  in datos00;
create index "informix".idx_btscdep1 on "informix".sac_bts_cdep 
    (fecha_proceso,hora_proceso) using btree  in datos00;
create index "informix".idx_btscdep2 on "informix".sac_bts_cdep 
    (num_confirmacion) using btree  in datos00;
create index "informix".idx_sac_bts_payc on "informix".sac_bts_payc 
    (opcode,fecha_insert) using btree  in datos03;
create index "informix".idx_bts_sdep1 on "informix".sac_bts_sdep 
    (num_confirmacion,fecha_proceso,opcode) using btree  in datos00;
    
create index "informix".idx_bts_sdep2 on "informix".sac_bts_sdep 
    (cuenta_benef) using btree  in datos00;
create index "informix".idx_bts_sdep3 on "informix".sac_bts_sdep 
    (num_confirmacion,fecha_proceso,hora_proceso) using btree 
     in datos00;
create index "informix".idx_bts_sdep4 on "informix".sac_bts_sdep 
    (num_confirmacion) using btree  in datos00;
create index "informix".idx_bts_sdep5 on "informix".sac_bts_sdep 
    (num_confirmacion,fecha_proceso) using btree  in datos00;
    
create index "informix".idx_bts_sdep6 on "informix".sac_bts_sdep 
    (num_confirmacion,estatus_sdep) using btree  in datos00;
create index "informix".idx_bts_sdep_8 on "informix".sac_bts_sdep 
    (estatus_sdep,cuenta_benef,fecha_insert) using btree  in 
    datos00_idx;
create index "informix".idx_sac_bts_sdep7 on "informix".sac_bts_sdep 
    (estatus_sdep) using btree  in dbs_movhis_idx3;
create index "informix".idx_ws_login on "informix".sac_ws_login 
    (agent_trans_type_code,fecha_peticion,hora_peticion) using 
    btree  in datos00;
create unique index "informix".idx_sac_ws_transacc_ctes on "informix"
    .sac_ws_transacc_ctes (agent_cd,usuario,transaccion,activa) 
    using btree  in datos00;
create index "informix".idx_tmpchequesrev on "informix".tmpchequesrev 
    (fech_alt) using btree  in datos00;
create index "informix".idx_tmpserviciosrev on "informix".tmpserviciosrev 
    (folio_suc,fecha_pago) using btree  in datos00;
create index "informix".idx_tmpsac_bts_revi on "informix".tmpsac_bts_revi 
    (confirmation_nm,bank_ref_nm) using btree  in datos00;
create index "informix".idx_tmpsac_bts_revi2 on "informix".tmpsac_bts_revi 
    (fecha_insert) using btree  in datos00;
create index "informix".idx_tmpcheques on "informix".tmpcheques 
    (fech_alt) using btree  in datos00;
create index "informix".idx_tmpabono on "informix".tmpabono (confirmation_nm,
    fecha_insert) using btree  in datos00;
create index "informix".idx_tmpabono2 on "informix".tmpabono (fecha_insert) 
    using btree  in datos00;
create index "informix".idx_tmpbtscaja on "informix".tmpbtscaja 
    (confirmation_nm,bank_ref_nm) using btree  in datos00;
create index "informix".idx_tmpbtscaja2 on "informix".tmpbtscaja 
    (fecha_insert) using btree  in datos00;
create index "informix".idx_base20 on "informix".sac_base20 (letra,
    fecha_insert) using btree  in datos00;
create index "informix".idx_sac_base20 on "informix".sac_base20 
    (letra) using btree  in dbs_movhis_idx3;
create index "informix".idx_base30 on "informix".sac_base30 (letra,
    fecha_insert) using btree  in datos00;
create index "informix".idx_letra on "informix".sac_base30 (letra) 
    using btree  in dbs_movhis_idx3;
create index "informix".idx_valor on "informix".sac_base30 (valor) 
    using btree  in dbs_movhis_idx3;
create index "informix".idx_base36 on "informix".sac_base36 (letra,
    fecha_insert) using btree  in datos00;
create index "informix".idx_sac_base36 on "informix".sac_base36 
    (letra) using btree  in dbs_movhis_idx3;
create index "informix".idx_sac_fecha_condensada on "informix"
    .sac_fecha_condensada (combinacion) using btree  in dbs_movhis_idx3;
    
create index "informix".idx_gdf_pagos on "informix".sac_gdf_pagos 
    (linea_captura,fecha_insert) using btree  in datos00;
create index "informix".idx_linea_captura on "informix".sac_gdf_pagos 
    (linea_captura) using btree  in dbs_movhis_idx3;
create index "informix".idx_tmpchequesrevwu1 on "informix".sac_chequesrevwu_paso 
    (fech_alt,usuario) using btree  in datos00;
create index "informix".idx_tmpchequesrevwu2 on "informix".sac_chequesrevwu_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_tmpchequeswu on "informix".sac_chequeswu_paso 
    (fech_alt,usuario) using btree  in datos00;
create index "informix".idx_tmpchequeswu1 on "informix".sac_chequeswu_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_conciliacionrevwu on "informix".sac_conciliacionrevwu_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_conciliacionwu on "informix".sac_conciliacionwu_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_tmpserviciosrevwu on "informix".sac_serviciosrevwu_paso 
    (folio_suc,fecha_pago,usuario) using btree  in datos00;
create index "informix".idx_tmpserviciosrevwu1 on "informix".sac_serviciosrevwu_paso 
    (status_cancelado,fecha_pago,folio_suc) using btree  in datos00;
    
create index "informix".idx_tmpserviciosrevwu2 on "informix".sac_serviciosrevwu_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_tmpservicioswu on "informix".sac_servicioswu_paso 
    (folio_suc,fecha_pago,usuario) using btree  in datos00;
create index "informix".idx_tmpservicioswu1 on "informix".sac_servicioswu_paso 
    (status_cancelado,fecha_pago,flag_confirmacion_sucursal) 
    using btree  in datos00;
create index "informix".idx_tmpservicioswu2 on "informix".sac_servicioswu_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_catciudades_ov on "informix".sac_wu_catciudades_ov 
    (state_name,city,fecha_insert) using btree  in datos00;
create index "informix".idx_catciudades_vg on "informix".sac_wu_catciudades_vg 
    (state_name,city,fecha_insert) using btree  in datos00;
create index "informix".idx_catciudades_wu on "informix".sac_wu_catciudades_wu 
    (state_code,fecha_insert) using btree  in datos00;
create index "informix".idx_wu_catmensajes on "informix".sac_wu_catmensajes 
    (fun_code,fecha_insert) using btree  in datos00;
create index "informix".idx_wu_errores on "informix".sac_wu_errores 
    (proceso,fecha_hora_insert) using btree  in datos00;
create index "informix".idx_wu_estatusrems on "informix".sac_wu_estatusrems 
    (estatus_remesa,fecha_hora_insert) using btree  in datos00;
    
create index "informix".idx_wu_heartbeat on "informix".sac_wu_heartbeat 
    (retcode,fecha_insert) using btree  in datos00;
create index "informix".idx_wu_isomonedas on "informix".sac_wu_isomonedas 
    (currency_cd,foreign_rs_cntid_rq) using btree  in datos00;
    
create index "informix".idx_wu_isopaises on "informix".sac_wu_isopaises 
    (country_long,foreign_rs_cntid_rq) using btree  in datos00;
    
create index "informix".idx_wu_pay_status on "informix".sac_wu_pay_status 
    (mtcn,fecha_insert) using btree  in datos00;
create index "informix".idx_wu_procesos on "informix".sac_wu_procesos 
    (proceso,fecha_insert) using btree  in datos00;
create index "informix".idx_wu_procesos1 on "informix".sac_wu_procesos 
    (fecha_proceso,proceso,status) using btree  in datos00;
create index "informix".idx_wu_select on "informix".sac_wu_select 
    (money_transfer_key_rq,fecha_insert) using btree  in datos00;
    
create index "informix".idx_tmpbtscajawu2 on "informix".sac_wucaja_paso 
    (usuario) using btree  in datos00;
create index "informix".idx_tmpwucajawu on "informix".sac_wucaja_paso 
    (mtcn,foreign_rs_refnum_rq,usuario) using btree  in datos00;
    
create index "informix".idx_tmpwucajawu1 on "informix".sac_wucaja_paso 
    (fecha_insert,usuario) using btree  in datos00;
create index "informix".idx_bitacoragdf on "informix".sac_bitacoragdf 
    (gen1) using btree  in datos00;
create index "informix".idx_btsabnpso1 on "informix".sac_abono_paso 
    (fecha_insert) using btree  in datos00;
create index "informix".idx_btsabnpso2 on "informix".sac_abono_paso 
    (fecha_insert,bank_ref_nm) using btree  in datos00;
create index "informix".idx_btsabnpso3 on "informix".sac_abono_paso 
    (bank_ref_nm,confirmation_nm) using btree  in datos00;
create index "informix".idx_btscjapso1 on "informix".sac_btscaja_paso 
    (fecha_insert) using btree  in datos00;
create index "informix".idx_btscjapso2 on "informix".sac_btscaja_paso 
    (bank_ref_nm,confirmation_nm) using btree  in datos00;
create index "informix".idx_btsrvi1 on "informix".sac_btsrevi_paso 
    (fecha_insert) using btree  in datos00;
create index "informix".idx_btschqspso1 on "informix".sac_cheques_paso 
    (fech_alt) using btree  in datos00;
create index "informix".idx_btschqspso2 on "informix".sac_cheques_paso 
    (fech_alt,folio_suc) using btree  in datos00;
create index "informix".idx_btschqsrvpso1 on "informix".sac_chequesrev_paso 
    (fech_alt) using btree  in datos00;
create index "informix".idx_btschqsrvpso2 on "informix".sac_chequesrev_paso 
    (fech_alt,folio_suc) using btree  in datos00;
create index "informix".idx_btsconcpso1 on "informix".sac_conciliacionbts_paso 
    (referencia) using btree  in datos00;
create index "informix".idx_btsconcrvpso1 on "informix".sac_conciliacionrev_paso 
    (folio_suc,referencia) using btree  in datos00;
create index "informix".idx_btssrvrvpso1 on "informix".sac_serviciosrev_paso 
    (fecha_pago,status_cancelado) using btree  in datos00;
create index "informix".idx_btssrvrvpso2 on "informix".sac_serviciosrev_paso 
    (fecha_pago,folio_suc) using btree  in datos00;
create index "informix".idx_sac_fechas on "informix".sac_fechas 
    (fecha_hoy) using btree  in dbs_movhis_idx3;
create index "informix".idx_wuidents on "informix".sac_wu_identificadores 
    (empresa,marca,sucursal) using btree  in datos00;
create index "informix".crea_idx_sac_controlconvenios_cat_con_se 
    on "informix".sac_controlconvenios (numcategoria,numconvenio) 
    using btree  in dbs_movhis_idx4;
create index "informix".idx_sac_controlconvenios on "informix"
    .sac_controlconvenios (status_cpl) using btree  in datos00_idx;
    
create index "informix".ix_abono_seg on "informix".sac_abono_seg 
    (sucursal,numcliente,recibo) using btree  in datos00;
create index "informix".idxsac_conciliaciontotalporconveniofe 
    on "informix".sac_conciliaciontotalporconvenio (fecha_pago,
    numcategoria,numconvenio) using btree  in datos00;
create index "informix".idxsac_conciliaciontotalporconvenioncnc 
    on "informix".sac_conciliaciontotalporconvenio (numcategoria,
    numconvenio) using btree  in datos00;
create index "informix".idx_recibo_coppel on "informix".sac_recibo_coppel 
    (cod_param) using btree  in datos00;
create index "informix".idx_sac_wu_fec_cte on "informix".sac_wu_pay 
    (fecha_insert,numcte) using btree  in dbs_idxinteg;
create index "informix".idx_sac_wu_pay on "informix".sac_wu_pay 
    (conf_pago,fecha_insert) using btree  in dbs_movhis_idx3;
    
create index "informix".idx_sac_wu_pay1 on "informix".sac_wu_pay 
    (fecha_insert) using btree  in dbs_movhis_idx3;
create index "informix".idx_sac_wu_pay2 on "informix".sac_wu_pay 
    (benef_appaterno,benef_apmaterno,benef_nombre1,benef_nombre2) 
    using btree  in dbs_movhis_idx3;
create index "informix".idx_sac_wu_pay3 on "informix".sac_wu_pay 
    (mtcn) using btree  in datos00;
create index "informix".idx_sac_wu_pay4 on "informix".sac_wu_pay 
    (benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
    benef_fecha_nac,conf_pago,foreign_rs_refnum_rq,mtcn) using 
    btree  in datos00;
create index "informix".idx_sac_wu_pay5 on "informix".sac_wu_pay 
    (foreign_rs_refnum_rp,mtcn) using btree  in datos02_idx;
create index "informix".idx_wu_pay on "informix".sac_wu_pay (mtcn,
    fecha_insert) using btree  in dbs_movhis_idx3;
create index "informix".idx_wu_pay4 on "informix".sac_wu_pay (retcode,
    conf_pago,fecha_insert) using btree  in dbs_movhis_idx5;
create index "informix".idxsac_wu_payfi on "informix".sac_wu_pay 
    (benef_fecha_nac,benef_id_number) using btree  in dbs_movhis_idx3;
    
create index "informix".idxsac_wu_payfim on "informix".sac_wu_pay 
    (benef_fecha_nac,benef_id_number,mtcn) using btree  in dbs_movhis_idx3;
    
create index "informix".idx_wu_search on "informix".sac_wu_search 
    (mtcn,fecha_insert) using btree  in dbs_movhis_idx3;
create index "informix".idx_wu_search2 on "informix".sac_wu_search 
    (mtcn) using btree  in dbs_movhis_idx3;
create index "informix".idx_wu_search3 on "informix".sac_wu_search 
    (fecha_insert) using btree  in dbs_movhis_idx3;
create index "informix".idx_wu_search4 on "informix".sac_wu_search 
    (mtcn,fecha_hora_rp,retcode) using btree  in dbs_cfd_04;
create index "informix".idxsac_pld_odpft on "informix".sac_pld_ordenes_pago 
    (fecha_proceso,tipo_orden) using btree  in datos00;
create index "informix".idxsac_pld_ordenes_pago on "informix".sac_pld_ordenes_pago 
    (fecha_pago,fecha_envio,tipo_orden,estatus) using btree  
    in datos02_idx;
create index "informix".idxsac_procesos_jobsfp on "informix".sac_procesos_jobs 
    (proceso,fecha_proceso) using btree  in datos00;
create index "informix".idxsac_cheques_odpff on "informix".sac_cheques_odp 
    (folio_suc,fech_alt) using btree  in datos00;
create index "informix".idxsac_movtos_odpr1 on "informix".sac_movtos_odp 
    (referencia1) using btree  in datos00;
create index "informix".idxsac_cheques_wuff on "informix".sac_cheques_wu 
    (folio_suc,fech_alt) using btree  in datos00;
create index "informix".idxsac_datos_pay_wum on "informix".sac_datos_pay_wu 
    (mtcn) using btree  in datos00;
create index "informix".idxsac_datos_searchp on "informix".sac_datos_search 
    (pt_mtcn) using btree  in datos00;
create index "informix".idxsac_secuencia_searchps on "informix"
    .sac_secuencia_search (pt_mtcn,secuencia) using btree  in 
    datos00;
create index "informix".idxsac_secuencias_paysm on "informix".sac_secuencias_pay 
    (secuencia,mtcn) using btree  in datos00;
create index "informix".idxsac_servicios_wur1 on "informix".sac_servicios_wu 
    (referencia1) using btree  in datos00;
create index "informix".idxsac_cargo_btsff on "informix".sac_cargo_bts 
    (folio_suc,fech_alt) using btree  in datos00;
create index "informix".idxsac_qryiscs on "informix".sac_qryis 
    (confirmation_nm,secuencia) using btree  in datos00;
create index "informix".idxsac_vntnilla_payics on "informix".sac_vntnilla_payi 
    (confirmation_nm,secuencia) using btree  in datos00;
create index "informix".idxsac_movtos_btsr1 on "informix".sac_movtos_bts 
    (referencia1) using btree  in datos00;
create index "informix".idxsac_vntnilla_cargo_btsffs on "informix"
    .sac_vntnilla_cargo_bts (folio_suc,fech_alt,sucursal) using 
    btree  in datos00;
create index "informix".idxsac_vntnilla_movtosr1 on "informix"
    .sac_vntnilla_movtos (referencia1) using btree  in datos00;
    
create index "informix".idxsac_vntnilla_payi1c on "informix".sac_vntnilla_payi1 
    (confirmation_nm) using btree  in datos00;
create index "informix".idxsac_datos1_queryc on "informix".sac_datos1_query 
    (confirmation_nm) using btree  in datos00;
create index "informix".idxsac_datos2_queryn on "informix".sac_datos2_query 
    (num_confirmacion) using btree  in datos00;
create index "informix".idx_msw_resp on "informix".sac_msw_respuesta 
    (numcategoria,numconvenio,folio_suc) using btree  in dbs_cfd_idxs;
    
create index "informix".idx_msw_resp_1 on "informix".sac_msw_respuesta 
    (fecha_pago) using btree  in dbs_cfd_idxs;
create index "informix".idx_msw_solic on "informix".sac_msw_solicitud 
    (numcategoria,numconvenio,folio_suc) using btree  in dbs_cfd_idxs;
    
create index "informix".idx_msw_solic_1 on "informix".sac_msw_solicitud 
    (fecha_pago) using btree  in dbs_cfd_idxs;
create index "informix".idxsac_tipopago_convenio on "informix"
    .sac_tipopago_convenio (numcategoria,numconvenio) using btree 
     in datos00;
create index "informix".idxsac_wu_remesasnoconciliadasnnr on 
    "informix".sac_wu_remesasnoconciliadas (numconvenio,numcategoria,
    retfecha) using btree  in datos00;
create index "informix".idx_bitacora_reverso_msw on "informix"
    .bitacora_reverso_msw (categoria,convenio,folio,fecha,hora) 
    using btree  in datos00;
create index "informix".idx_sac_serv_conc on "informix".sac_servicios_cpl 
    (conciliacion) using btree  in datos00;
create index "informix".idxsac_servicios_cpl on "informix".sac_servicios_cpl 
    (numcategoria,numconvenio) using btree  in datos00;
create index "informix".idx01_folio_suc on "informix".sac_pagostae 
    (folio_suc) using btree  in dbs_cfd_05;
create index "informix".idx_tmp_movs_soc on "informix".tmp_movs_soc 
    (ejecutivo) using btree  in datos00;
create index "informix".idx_wu_limxsuc on "informix".sac_wu_limxsuc 
    (sucursal) using btree  in datos00;
create index "informix".idx_wu_limxsuc1 on "informix".sac_wu_limxsuc 
    (marca) using btree  in datos00;
create index "informix".idx_wu_limxsuc2 on "informix".sac_wu_limxsuc 
    (sucursal,marca) using btree  in datos00;
create index "informix".idx_sac_app_revi_rcode_fech on "informix"
    .sac_app_revi_old (r_code,fecha) using btree  in datos00;
    
create index "informix".idx_sac_app_revi_ref_fecha on "informix"
    .sac_app_revi_old (unirefnum,fecha) using btree  in datos00;
    
create index "informix".idx_sac_app_revi_ref_folio on "informix"
    .sac_app_revi_old (unirefnum,refnum) using btree  in datos00;
    
create index "informix".idx_bts_limitesuc on "informix".sac_bts_limitesuc 
    (sucursal,marca) using btree  in datos00;
create index "informix".idx_bts_limitesuc1 on "informix".sac_bts_limitesuc 
    (marca) using btree  in datos00;
create index "informix".idx_bts_limitsuc on "informix".sac_bts_limitesuc 
    (sucursal) using btree  in datos00;
create index "informix".idxsac_app_limitesucm on "informix".sac_app_limitesuc 
    (marca) using btree  in datos00;
create index "informix".idxsac_app_limitesucs on "informix".sac_app_limitesuc 
    (sucursal) using btree  in datos00;
create index "informix".idxsac_app_limitesucsm on "informix".sac_app_limitesuc 
    (sucursal,marca) using btree  in datos00;
create index "informix".idxsac_catalogolimitepldc on "informix"
    .sac_catalogolimitepld (codigo) using btree  in datos00;
create index "informix".idxsac_remesaslimitepld_appf_old on "informix"
    .sac_remesaslimitepld_app_old (fecha) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_appfc_old on 
    "informix".sac_remesaslimitepld_app_old (fecha,codigo) using 
    btree  in datos00;
create index "informix".idxsac_remesaslimitepld_appfs_old on 
    "informix".sac_remesaslimitepld_app_old (fecha,sucursal) using 
    btree  in datos00;
create index "informix".idxsac_remesaslimitepld_btsf_old on "informix"
    .sac_remesaslimitepld_bts_old (fecha) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_btsfc_old on 
    "informix".sac_remesaslimitepld_bts_old (fecha,codigo) using 
    btree  in datos00;
create index "informix".idxsac_remesaslimitepld_btsfs_old on 
    "informix".sac_remesaslimitepld_bts_old (fecha,sucursal) using 
    btree  in datos00;
create index "informix".idxsac_remesaslimitepld_wuf_old on "informix"
    .sac_remesaslimitepld_wu_old (fecha) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_wufc_old on "informix"
    .sac_remesaslimitepld_wu_old (fecha,codigo) using btree  
    in datos00;
create index "informix".idxsac_remesaslimitepld_wufs_old on "informix"
    .sac_remesaslimitepld_wu_old (fecha,sucursal) using btree 
     in datos00;
create unique index "informix".idx_sac_estadisticas_altactes_anio 
    on "informix".sac_estadisticas_altactes_anio (mes,anio,mesanio,
    fecha_insert) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_altactes_dia 
    on "informix".sac_estadisticas_altactes_dia (dia,fecha_insert) 
    using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_altactes_diasemana 
    on "informix".sac_estadisticas_altactes_diasemana (mes,anio,
    num_dia,fecha_insert) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_altactes_estado 
    on "informix".sac_estadisticas_altactes_estado (mes,anio,estado,
    fecha_insert) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_altactes_minuto 
    on "informix".sac_estadisticas_altactes_minuto (fecha,fecha_insert) 
    using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_altactes_sucursal 
    on "informix".sac_estadisticas_altactes_sucursal (mes,anio,
    sucursal,fecha_insert) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_mnsj_batch_online 
    on "informix".sac_estadisticas_mnsj_batch_online (anio,mes,
    fecha_insert) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_pagoservicios 
    on "informix".sac_estadisticas_pagoservicios (mesanio,numcategoria,
    numconvenio,fecha_insert) using btree  in dbs_movhis_idx3;
    
create unique index "informix".idx_sac_estadisticas_remesas_minuto 
    on "informix".sac_estadisticas_remesas_minuto (fecha,fecha_insert) 
    using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_remesas_sucursal 
    on "informix".sac_estadisticas_remesas_sucursal (mes,anio,
    suc,fecha_insert) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_correos_minuto 
    on "informix".sac_estadisticas_correos_minuto (fecha,fecha_insert) 
    using btree  in dbs_movhis_idx3;
create unique index "informix".idx_tb_ctrl_estadisticas_sac on 
    "informix".tb_ctrl_estadisticas_sac (id_sp) using btree  in 
    dbs_movhis_idx3;
create unique index "informix".idx_tb_ejecucion_estadisticas_sac 
    on "informix".tb_ejecucion_estadisticas_sac (fecha_hora_ejecucion,
    id_sp) using btree  in dbs_movhis_idx3;
create unique index "informix".idx_sac_estadisticas_remesas_estados 
    on "informix".sac_estadisticas_remesas_estados (mes,anio,estado,
    fecha_insert) using btree  in dbs_movhis_idx3;
create index "informix".idx_tb_sac_altactes_minuto_ctepf on "informix"
    .sac_estadisticas_temp_ctespf_minuto (hora_insert,numcte) 
    using btree  in dbs_movhis_idx3;
create index "informix".idx_id_sucursal_minuto on "informix".sac_estadisticas_temp_remesas_minuto 
    (fecha_pago) using btree  in dbs_movhis_idx3;
create index "informix".idxsac_cheques_appff on "informix".sac_cheques_app 
    (folio_suc,fech_alt) using btree  in datos00;
create index "informix".idxsac_payi_appu on "informix".sac_payi_app 
    (unirefnum) using btree  in datos00;
create index "informix".idxsac_qryi_appu on "informix".sac_qryi_app 
    (unirefnum) using btree  in datos00;
create index "informix".idxsac_secuenciapayi_appus on "informix"
    .sac_secuenciapayi_app (unirefnum,secuencia) using btree 
     in datos00;
create index "informix".idxsac_secuenciaqryi_appus on "informix"
    .sac_secuenciaqryi_app (unirefnum,secuencia) using btree 
     in datos00;
create index "informix".idxsac_servicios_appr1 on "informix".sac_servicios_app 
    (referencia1) using btree  in datos00;
create index "informix".idxsac_cargo_appff on "informix".sac_cargo_app 
    (folio_suc,fech_alt) using btree  in datos00;
create index "informix".idxsac_movtos_appr1 on "informix".sac_movtos_app 
    (referencia1) using btree  in datos00;
create index "informix".idxsac_conc_archtemp1_1 on "informix".sac_conc_archtemp1 
    (fecha_pago) using btree  in datos01;
create index "informix".idxsac_conc_archtemp2_1 on "informix".sac_conc_archtemp2 
    (folio_suc) using btree  in datos01;
create index "informix".idx_sac_concfech_ins on "informix".sac_conciliacion_bcpl_cpl 
    (fecha_insert) using btree  in datos01;
create index "informix".idx_sac_concnomb_arc on "informix".sac_conciliacion_bcpl_cpl 
    (nombre_archivo) using btree  in datos01;
create index "informix".idxsac_conc_folio on "informix".sac_conciliacion_bcpl_cpl 
    (foliosucursal) using btree  in datos01;
create index "informix".idxsac_conc_tcnf on "informix".sac_conciliacion_bcpl_cpl 
    (tienda,caja,numerotiket,foliosucursal) using btree  in datos01;
    
create index "informix".idxsac_conccarga on "informix".sac_conciliacion_bcpl_cpl 
    (fecha_insert,fechapago,tienda,movimiento,tipomovimiento,
    empresa) using btree  in datos01;
create index "informix".idxsac_conciliacion_bcpl_cpl_1 on "informix"
    .sac_conciliacion_bcpl_cpl (movimiento,tipomovimiento,st_conciliado) 
    using btree  in datos01;
create index "informix".idxsac_conc_oldf on "informix".sac_conciliacion_bcpl_cpl_old 
    (fecha_carga) using btree  in datos01;
create index "informix".idxsac_conc_oldftcnf on "informix".sac_conciliacion_bcpl_cpl_old 
    (fecha_carga,tienda,caja,numerotiket,foliosucursal) using 
    btree  in datos01;
create index "informix".idxsac_conc_oldrcnf on "informix".sac_conciliacion_bcpl_cpl_old 
    (foliosucursal) using btree  in datos01;
create index "informix".idxsac_conc_oldscnf on "informix".sac_conciliacion_bcpl_cpl_old 
    (foliosucursal,st_conciliado) using btree  in datos01;
create index "informix".idxsac_conc_oldtcnf on "informix".sac_conciliacion_bcpl_cpl_old 
    (tienda,caja,numerotiket,foliosucursal) using btree  in datos01;
    
create index "informix".idx_sac_conccfras on "informix".sac_conciliacion_cifras 
    (fecha_concil,fechapago,tienda,movimiento,tipomovimiento,
    empresa) using btree  in datos01;
create index "informix".idx_sac_conccfrasnomb_arc on "informix"
    .sac_conciliacion_cifras (nombre_archivo) using btree  in 
    datos01;
create index "informix".idxsac_conc_cifras on "informix".sac_conciliacion_cifras 
    (fechapago,movimiento,tipomovimiento) using btree  in datos01;
    
create index "informix".idxsac_conc_cifras1 on "informix".sac_conciliacion_cifras 
    (fecha_concil,movimiento,tipomovimiento) using btree  in 
    datos01;
create index "informix".idxsac_conc_cifold on "informix".sac_conciliacion_cifras_old 
    (fechapago,movimiento,tipomovimiento) using btree  in datos01;
    
create index "informix".idxsac_conc_cifold1 on "informix".sac_conciliacion_cifras_old 
    (fecha_concil,movimiento,tipomovimiento) using btree  in 
    datos01;
create index "informix".idxsac_conc_cifold2 on "informix".sac_conciliacion_cifras_old 
    (fecha_carga,movimiento,tipomovimiento) using btree  in datos01;
    
create index "informix".idx_actualiza_datos_1 on "informix".tmp_actualiza_datos 
    (numcte,num_credito) using btree  in datos00;
create index "informix".idx_pagosky_01 on "informix".sac_sky_wsgpago 
    (numcuenta,folio_suc,fecha_insert) using btree  in datos00;
    
create index "informix".idx_pagosky_02 on "informix".sac_sky_wsgpago 
    (folio_suc) using btree  in dbs_cfd_05;
create index "informix".idx_reversosky_01 on "informix".sac_sky_wsgreverso 
    (numcuenta,folio_suc,fecha_insert) using btree  in datos00;
    
create index "informix".idx_sac_cte_remesas1 on "informix".sac_cte_remesas 
    (numcte,status_cte,fecha_alta,fecha_vencimiento) using btree 
     in datos01_idx;
create index "informix".idx_sac_cte_remesas2 on "informix".sac_cte_remesas 
    (fecha_alta,sucursal,numcte) using btree  in datos02_idx;
    
create index "informix".idx_sac_cte_remesas3 on "informix".sac_cte_remesas 
    (sucursal,fecha_insert) using btree  in idx_info06;
create index "informix".idx_sac_cte_remesas4 on "informix".sac_cte_remesas 
    (fecha_insert) using btree  in idx_info06;
create index "informix".idx_sac_app_agrupa_totales_01 on "informix"
    .sac_app_agrupa_totales (dateofbirth,numberci) using btree 
     in datos00;
create index "informix".idx_sac_app_agrupa_totales_02 on "informix"
    .sac_app_agrupa_totales (unirefnum) using btree  in datos00;
    
create index "informix".idx_sac_app_agrupa_totales_03 on "informix"
    .sac_app_agrupa_totales (fecha) using btree  in datos00;
create index "informix".idx_sac_app_agrupa_totales_04 on "informix"
    .sac_app_agrupa_totales (unirefnum,refnum) using btree  in 
    datos00;
create index "informix".idx_sac_app_agrupa_totales_05 on "informix"
    .sac_app_agrupa_totales (dateofbirth,numberci,fecha) using 
    btree  in datos00;
create index "informix".idx_sac_app_agrupa_totales_06 on "informix"
    .sac_app_agrupa_totales (unirefnum,reversada) using btree 
     in datos00;
create index "informix".idx_sac_app_filtra_totales_01 on "informix"
    .sac_app_filtra_totales (dateofbirth,numberci) using btree 
     in datos00;
create index "informix".idx_sac_app_filtra_totales_02 on "informix"
    .sac_app_filtra_totales (secuencia) using btree  in datos00;
    
create index "informix".idx_sac_app_filtra_totales_03 on "informix"
    .sac_app_filtra_totales (dateofbirth,numberci,secuencia) 
    using btree  in datos00;
create index "informix".idx_sac_app_filtra_totales_04 on "informix"
    .sac_app_filtra_totales (dateofbirth,numberci,numero_total_remesas,
    monto_total_remesas) using btree  in datos00;
create index "informix".idx_sac_app_final_totales_01 on "informix"
    .sac_app_final_totales (dateofbirth,numberci) using btree 
     in datos00;
create index "informix".idx_sac_app_revi_totales_01 on "informix"
    .sac_app_revi_totales (unirefnum,refnum) using btree  in 
    datos00;
create index "informix".idx_sac_app_tels_totales_01 on "informix"
    .sac_app_tels_totales (dateofbirth,numberci) using btree 
     in datos00;
create index "informix".idx_sac_wu_agrupa_totales_01 on "informix"
    .sac_wu_agrupa_totales (benef_fecha_nac,benef_id_number) 
    using btree  in datos00;
create index "informix".idx_sac_wu_agrupa_totales_02 on "informix"
    .sac_wu_agrupa_totales (mtcn) using btree  in datos00;
create index "informix".idx_sac_wu_agrupa_totales_03 on "informix"
    .sac_wu_agrupa_totales (fecha_insert) using btree  in datos00;
    
create index "informix".idx_sac_wu_agrupa_totales_04 on "informix"
    .sac_wu_agrupa_totales (benef_fecha_nac,benef_id_number,fecha_insert) 
    using btree  in datos00;
create index "informix".idx_sac_wu_filtra_totales_01 on "informix"
    .sac_wu_filtra_totales (benef_fecha_nac,benef_id_number) 
    using btree  in datos00;
create index "informix".idx_sac_wu_filtra_totales_02 on "informix"
    .sac_wu_filtra_totales (secuencia) using btree  in datos00;
    
create index "informix".idx_sac_wu_filtra_totales_03 on "informix"
    .sac_wu_filtra_totales (benef_fecha_nac,benef_id_number,secuencia) 
    using btree  in datos00;
create index "informix".idx_sac_wu_filtra_totales_04 on "informix"
    .sac_wu_filtra_totales (benef_fecha_nac,benef_id_number,numero_total_remesas,
    monto_total_remesas) using btree  in datos00;
create index "informix".idx_sac_wu_final_totales_01 on "informix"
    .sac_wu_final_totales (benef_fecha_nac,benef_id_number) using 
    btree  in datos00;
create index "informix".idx_sac_wu_tels_totales_01 on "informix"
    .sac_wu_tels_totales (benef_fecha_nac,benef_id_number) using 
    btree  in datos00;
create index "informix".idxsac_benefrem_tmpm on "informix".sac_benefrem_tmp 
    (marca) using btree  in datos00;
create index "informix".idx_sac_bts_agrupa_totales_01 on "informix"
    .sac_bts_agrupa_totales (r_fecha_nac,r_identif_nm) using 
    btree  in datos00;
create index "informix".idx_sac_bts_agrupa_totales_02 on "informix"
    .sac_bts_agrupa_totales (confirmation_nm) using btree  in 
    datos00;
create index "informix".idx_sac_bts_agrupa_totales_03 on "informix"
    .sac_bts_agrupa_totales (fecha_insert) using btree  in datos00;
    
create index "informix".idx_sac_bts_agrupa_totales_04 on "informix"
    .sac_bts_agrupa_totales (confirmation_nm,bank_ref_nm) using 
    btree  in datos00;
create index "informix".idx_sac_bts_agrupa_totales_05 on "informix"
    .sac_bts_agrupa_totales (r_fecha_nac,r_identif_nm,fecha_insert) 
    using btree  in datos00;
create index "informix".idx_sac_bts_agrupa_totales_06 on "informix"
    .sac_bts_agrupa_totales (confirmation_nm,reversada) using 
    btree  in datos00;
create index "informix".idx_sac_bts_agrupa_totales_07 on "informix"
    .sac_bts_agrupa_totales (reversada) using btree  in datos00;
    
create index "informix".idx_sac_bts_filtra_totales_01 on "informix"
    .sac_bts_filtra_totales (r_fecha_nac,r_identif_nm) using 
    btree  in datos00;
create index "informix".idx_sac_bts_filtra_totales_02 on "informix"
    .sac_bts_filtra_totales (secuencia) using btree  in datos00;
    
create index "informix".idx_sac_bts_filtra_totales_03 on "informix"
    .sac_bts_filtra_totales (r_fecha_nac,r_identif_nm,secuencia) 
    using btree  in datos00;
create index "informix".idx_sac_bts_filtra_totales_04 on "informix"
    .sac_bts_filtra_totales (r_fecha_nac,r_identif_nm,numero_total_remesas,
    monto_total_remesas) using btree  in datos00;
create index "informix".idx_sac_bts_final_totales_01 on "informix"
    .sac_bts_final_totales (r_fecha_nac,r_identif_nm) using btree 
     in datos00;
create index "informix".idx_sac_bts_qryi_montos_01 on "informix"
    .sac_bts_qryi_montos (confirmation_nm) using btree  in datos00;
    
create index "informix".idx_sac_bts_qryi_montos_02 on "informix"
    .sac_bts_qryi_montos (fecha_insert) using btree  in datos00;
    
create index "informix".idx_sac_bts_qryi_montos_03 on "informix"
    .sac_bts_qryi_montos (confirmation_nm,fecha_insert) using 
    btree  in datos00;
create index "informix".idx_sac_bts_qryi_montos_04 on "informix"
    .sac_bts_qryi_montos (confirmation_nm,monto_total_remesas) 
    using btree  in datos00;
create index "informix".idx_sac_bts_qryi_montos_unique_01 on 
    "informix".sac_bts_qryi_montos_unique (confirmation_nm) using 
    btree  in datos00;
create index "informix".idx_sac_bts_revi_totales_01 on "informix"
    .sac_bts_revi_totales (confirmation_nm,bank_ref_nm) using 
    btree  in datos00;
create index "informix".idx_sac_bts_tels_totales_01 on "informix"
    .sac_bts_tels_totales (r_fecha_nac,r_identif_nm) using btree 
     in datos00;
create index "informix".idx_sac_monitor_01 on "informix".sac_monitor 
    (id_proceso) using btree  in datos00;
create index "informix".idx_sac_movimientos2 on "informix".sac_movimientos 
    (referencia1) using btree  in dbs_movhis_idx5;
create index "informix".idx_sac_movimientos6 on "informix".sac_movimientos 
    (fecha_pago,numconvenio,numcategoria) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_sac_movimientos7 on "informix".sac_movimientos 
    (folio_suc) using btree  in dbs_movhis_idx5;
create unique index "informix".idx_sac_movimientos_2 on "informix"
    .sac_movimientos (id_sucursal,numcategoria,numconvenio,referencia1,
    referencia2,folio_suc) using btree  in dbs_movhis_idx5;
create index "informix".idxsac_mov on "informix".sac_movimientos 
    (numcategoria,numconvenio,referencia1) using btree  in dbs_movhis_idx5;
    
create index "informix".idxsac_mov2 on "informix".sac_movimientos 
    (id_sucursal,folio_suc) using btree  in dbs_movhis_idx5;
create index "informix".idxsac_mov3 on "informix".sac_movimientos 
    (referencia1,numcategoria,numconvenio,flag_confirmacion_central,
    flag_confirmacion_sucursal,status_cancelado) using btree 
    ;
create index "informix".idxsac_mov4 on "informix".sac_movimientos 
    (fecha_pago) using btree ;
create index "informix".idxsac_mov5 on "informix".sac_movimientos 
    (numcategoria,numconvenio,fecha_pago,status_cancelado,flag_confirmacion_central,
    flag_confirmacion_sucursal,origen) using btree ;
create index "informix".idx_btssrvpso1 on "informix".sac_servicios_paso 
    (fecha_pago,status_cancelado,flag_confirmacion_sucursal) 
    using btree  in dbs_cierrecred1;
create index "informix".idx_btssrvpso2 on "informix".sac_servicios_paso 
    (referencia1,fecha_pago) using btree  in dbs_cierrecred2;
    
create index "informix".idx_btssrvpso3 on "informix".sac_servicios_paso 
    (fecha_pago,folio_suc) using btree  in dbs_cierrecred3;
create index "informix".idx_btssrvpso4 on "informix".sac_servicios_paso 
    (fecha_insert,status_cancelado,referencia1) using btree  
    in dbs_cierrecred4;
create index "informix".idx_bitnombre on "informix".sac_bts_bitnombres 
    (s_first_namebts,s_middle_namebts,s_last_namebts,s_mother_m_namebts) 
    using btree  in dbs_cfd_idxs;
create index "informix".idx_sac_limite_edo on "informix".sac_limite_edo 
    (abreviatura,status) using btree  in dbs_cfd_04;
create index "informix".idx_sac_limite_monto on "informix".sac_limite_monto 
    (abreviatura,status) using btree  in dbs_cfd_04;
create index "informix".idx_sac_limite_suc on "informix".sac_limite_suc 
    (abreviatura,sucursal,status) using btree  in dbs_cfd_04;
    
create index "informix".idx_sac_edosremorig_bitacora_validaciones_01 
    on "informix".sac_edosremorig_bitacora_validaciones (cod_validacion) 
    using btree  in dbs_cfd_05;
create index "informix".idx_sac_edosremorig_bitacora_01 on "informix"
    .sac_edosremorig_bitacora (num_remesa) using btree  in dbs_cfd_05;
    
create index "informix".idx_sac_edosremorigexcep_01 on "informix"
    .sac_edosremorigexcep (remesadora) using btree  in dbs_cfd_05;
    
create index "informix".idx_sac_estaremesasorig_01 on "informix"
    .sac_estaremesasorig (remesadora) using btree  in dbs_cfd_05;
    
create index "informix".ix_vta_cambio_seg on "informix".sac_vta_cambio_seg 
    (sucursal,numcliente,recibo,tipomovimiento) using btree  
    in db_lide01;
create index "informix".idx_sac_remesas_adic_01 on "informix".sac_remesas_adic 
    (referencia) using btree  in dbssc_sdodiarioc02;
create index "informix".idx_sac_remesas_adic_02 on "informix".sac_remesas_adic 
    (referencia,numcategoria,numconvenio) using btree  in dbssc_sdodiarioc02;
    
create index "informix".idx_sac_remesas_estadistica_01 on "informix"
    .sac_remesas_estadistica (numcategoria,numconvenio,fecha_pago) 
    using btree  in dbssc_sdodiarioc02;
create index "informix".idx_sac_remesas_estadistica_02 on "informix"
    .sac_remesas_estadistica (numcategoria,numconvenio,referencia) 
    using btree  in dbssc_sdodiarioc02;
create index "informix".idx_sac_remesas_estadistica_03 on "informix"
    .sac_remesas_estadistica (referencia) using btree  in dbssc_sdodiarioc02;
    
create index "informix".idx_sac_remesas_estadistica_04 on "informix"
    .sac_remesas_estadistica (folio_suc) using btree  in dbssc_sdodiarioc02;
    
create index "informix".idx_sac_remesas_estadistica_05 on "informix"
    .sac_remesas_estadistica (origen) using btree  in dbssc_sdodiarioc02;
    
create index "informix".idx_sac_remesas_estadistica_06 on "informix"
    .sac_remesas_estadistica (referencia,origen) using btree 
     in dbssc_sdodiarioc02;
create index "informix".idx_sac_remesas_estadistica_07 on "informix"
    .sac_remesas_estadistica (rfc) using btree  in dbssc_sdodiarioc02;
    
create index "informix".idx_sac_remesas_estadistica_08 on "informix"
    .sac_remesas_estadistica (status_cancelado) using btree  
    in dbssc_sdodiarioc02;
create index "informix".idx_sac_remesas_estadistica_09 on "informix"
    .sac_remesas_estadistica (fecha_pago) using btree  in datos02_idx;
    
create index "informix".idx_rep_remesas_01 on "informix".sac_reg_gen_rep_remesas 
    (reporte,fecha_inicio) using btree  in dbs_movhis_idx3;
create index "informix".idx_rep_remesas_his_01 on "informix".sac_reg_gen_rep_remesas_his 
    (h_folio_suc,h_id_sucursal) using btree  in dbs_movhis_idx3;
    
create index "informix".idx_bts_qryi_old1 on "informix".sac_bts_qryi_old 
    (agent_dt) using btree  in dbs_movhis_idx3;
create index "informix".idx_bts_qryi_old2 on "informix".sac_bts_qryi_old 
    (agent_dt,opcode) using btree  in dbs_movhis_idx3;
create index "informix".idx_bts_qryi_old3 on "informix".sac_bts_qryi_old 
    (confirmation_nm,opcode) using btree  in dbs_movhis_idx3;
    
create index "informix".idx_bts_qryi_old4 on "informix".sac_bts_qryi_old 
    (agent_trans_type_code,agent_cd,confirmation_nm,user_name) 
    using btree  in dbs_movhis_idx3;
create index "informix".idxsac_bts_qryi_old_05 on "informix".sac_bts_qryi_old 
    (opcode,fecha_insert) using btree  in dbs_movhis_idx3;
create index "informix".idx_ws_errores on "informix".sac_ws_errores 
    (proceso,fecha_insert,hora_insert) using btree  in dbs_movhis_idx4;
    
create index "informix".idx_sac_antad_catrespws on "informix".sac_antad_catrespws 
    (clave,num_trama) using btree  in dbs_movhis_idx5;
create index "informix".idx_sac_antad_escenarios on "informix"
    .sac_antad_escenarios (clave,accion) using btree  in dbs_movhis_idx5;
    
create index "informix".idxfolio_suc_antad on "informix".sac_pagos_antad 
    (folio_suc) using btree  in dbs_movhis_idx5;
create index "informix".idx_sac_porcentaje_repsoc_01 on "informix"
    .sac_porcentaje_repsoc (numcategoria,numconvenio,id_provedor) 
    using btree  in dbs_movhis_idx4;
create index "informix".idx_sac_remesas_estados_01 on "informix"
    .sac_remesas_estados (numcategoria,numconvenio,referencia,
    fecha_pago,folio_suc) using btree  in dbs_movhis_idx5;
create index "informix".idx_sac_remesas_estados_02 on "informix"
    .sac_remesas_estados (estado) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_sac_wu_cancelpay on "informix".sac_wu_cancelpay 
    (mtcn,fecha_insert,retcode,referencia_sistema_externo) using 
    btree  in dbs_movhis_idx4;
create index "informix".idx_fecha_altactes_prods on "informix"
    .sac_estadisticas_altactes_aperprods (fecha) using btree 
     in idx_aclaraciones01;
create index "informix".idx_fecha_altactes_minuto on "informix"
    .sac_estadisticas_altactes_por_minuto (fecha) using btree 
     in idx_aclaraciones01;
create index "informix".idx_uniref_fecha_app_payi_old on "informix"
    .sac_app_qryi_oldvacia (unirefnum,fecha) using btree  in 
    dbs_movhis_idx6;
create index "informix".idx_idsp_tb_ctrl_ind_ctes_servs on "informix"
    .tb_ctrl_ind_ctes_servs (id_sp) using btree  in dbssc_sdodiarioc03;
    
create index "informix".idx_fecha_altaremesas_por_minuto on "informix"
    .sac_estadisticas_altaremesas_por_minuto (fecha) using btree 
     in dbssc_sdodiarioc03;
create index "informix".idx_consulta_bts_web on "informix".sac_consulta_bts_web 
    (confirmation_nm,fechaconsulta) using btree  in idx_bitweb;
    
create index "informix".idx_reportcomision_id_suc on "informix"
    .sac_reportcom_rem (id_sucursal) using btree  in db_lide01;
    
create index "informix".idx_sac_cardif_contratante on "informix"
    .sac_cardif_contratante (sucursal,fecha_insert) using btree 
     in datos01_idx;
create index "informix".idx_sac_cardif_migrante on "informix".sac_cardif_migrante 
    (sucursal,num_certificado,estatus,num_poliza,folio_suc,fecha_alta,
    fecha_insert) using btree  in datos00_idx;
create unique index "informix".idx1_consulta_app_web on "informix"
    .sac_consulta_app_web (fechaconsulta,horaconsulta,nmreferencia,
    transaccionqryi) using btree  in datos01_idx;
create index "informix".idx_consulta_app_web on "informix".sac_consulta_app_web 
    (nmreferencia,fechaconsulta) using btree  in datos01_idx;
    
create index "informix".idx_conwuweb on "informix".sac_consulta_wu_web 
    (nmreferencia,fechaconsulta) using btree  in datos01_idx;
    
create index "informix".idx_codrespuesta on "informix".sac_dish_cat_respuestaws 
    (codigorespuesta) using btree  in datos00_idx;
create index "informix".idxsac_secuencia_searchps_wu on "informix"
    .sac_secuencia_search_wu (pt_mtcn,fechahorainsercion) using 
    btree  in idxwu00;
create index "informix".idxsac_pldlimite_domicilios on "informix"
    .sac_pldlimite_domicilios (fecha_insert) using btree  in 
    idx_bitweb;
create index "informix".idxsac_pldlimite_teldom_excpsuc on "informix"
    .sac_pldlimite_teldom_excpsuc (fecha_insert) using btree 
     in idx_bitweb;
create index "informix".idxsac_pldlimite_teldom_rechazos on "informix"
    .sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,periodo,
    tiporechazo,numremesa,folio_suc,fecha_insert) using btree 
     in idx_bitweb;
create index "informix".idxsac_pldlimite_telefonos on "informix"
    .sac_pldlimite_telefonos (fecha_insert) using btree  in idx_bitweb;
    
create index "informix".idxsac_pldlimite_bitacoramodsoc on "informix"
    .sac_pldlimite_bitacoramodsoc (id_sucursal,tipo_remesa,usuario_insert,
    usuario_modifica,fecha_insert,fecha_modifica) using btree 
     in datos02_idx;
create index "informix".idxsac_reportediario_seg on "informix"
    .sac_reportediario_seg (fecha_proceso,fecha_insert) using 
    btree  in datos02_idx;
create index "informix".idx_sac_sorteo_remesas on "informix".sac_sorteo_remesas 
    (fecha_cheques,enviado) using btree  in datos01_idx;
create index "informix".idx_consulta_bts_web_his on "informix"
    .sac_consulta_bts_web_his (confirmation_nm,fechaconsulta) 
    using btree  in datos01_idx;
create unique index "informix".idx_uni_consulta_bts_web_his on 
    "informix".sac_consulta_bts_web_his (transaccionqryi,confirmation_nm,
    terminal,fechaconsulta,horaconsulta) using btree  in datos01_idx;
    
create unique index "informix".idx1_uni_consulta_app_web_his 
    on "informix".sac_consulta_app_web_his (transaccionqryi,nmreferencia,
    fechaconsulta,horaconsulta) using btree  in datos01_idx;
create index "informix".idx_consulta_app_web_his on "informix"
    .sac_consulta_app_web_his (nmreferencia,fechaconsulta) using 
    btree  in datos01_idx;
create unique index "informix".idx_conwuweb_his on "informix".sac_consulta_wu_web_his 
    (transaccionqryi,nmreferencia,fechaconsulta,horaconsulta) 
    using btree  in datos01_idx;
create index "informix".idx_uni_conwuweb_his on "informix".sac_consulta_wu_web_his 
    (nmreferencia,fechaconsulta) using btree  in datos01_idx;
    
create index "informix".idx_ws_ccta on "informix".sac_ws_ccta_old 
    (agent_trans_type_code,agent_cd,num_cta,fecha_peticion,hora_peticion) 
    using btree  in datos01_idx;
create index "informix".idx_sac_reportediariodomi_seg on "informix"
    .sac_reportediariodomi_seg (fecha_pago,num_cliente,importe_pago,
    meses,numcte_coppel,numcte,num_poliza,sucursal_alta,promotor,
    tipo_plan,fecha_alta,fecha_cambio) using btree  in datos00_idx;
    
create index "informix".idx_sac_reportediariodomihis_seg on "informix"
    .sac_reportediariodomihis_seg (fecha_pago,num_cliente,importe_pago,
    meses,numcte_coppel,numcte,num_poliza,sucursal_alta,promotor,
    tipo_plan,fecha_alta,fecha_cambio) using btree  in datos00_idx;
    
create index "informix".idx_sac_reportediariovent_seg on "informix"
    .sac_reportediariovent_seg (fecha_pago,referencia1,importe_pago,
    meses,sucursal_pago_ventanilla,cajero,numcte_coppel,numcte,
    num_poliza,sucursal_alta,promotor,fecha_alta,fecha_cambio) 
    using btree  in datos00_idx;
create index "informix".idx_sac_reportediarioventhis_seg on "informix"
    .sac_reportediarioventhis_seg (fecha_pago,referencia1,importe_pago,
    meses,sucursal_pago_ventanilla,cajero,numcte_coppel,numcte,
    num_poliza,sucursal_alta,promotor,fecha_alta,fecha_cambio) 
    using btree  in datos00_idx;
create index "informix".idx_sac_agentes1 on "informix".sac_agentes_hist 
    (val) using btree  in dbs_movhis_idx6;
create index "informix".idx_sac_app_payi_011 on "informix".sac_app_payi 
    (r_code,r_code_d,fecha) using btree  in datos02_idx;
create index "informix".idx_sac_app_payi_11 on "informix".sac_app_payi 
    (firstname,middlename,lastname,mommaidenname,dateofbirth,
    r_currencycode) using btree  in datos02_idx;
create index "informix".idx_sac_app_payi_fec_ctee on "informix"
    .sac_app_payi (fecha,numcte) using btree  in datos02_idx;
    
create index "informix".idx_sac_app_payi_fii on "informix".sac_app_payi 
    (numberci,dateofbirth) using btree  in datos02_idx;
create index "informix".idx_sac_app_payi_fiuu on "informix".sac_app_payi 
    (unirefnum,numberci,dateofbirth) using btree  in datos02_idx;
    
create index "informix".idx_sac_app_payi_processtimee on "informix"
    .sac_app_payi (processtime) using btree  in datos02_idx;
create index "informix".idx_sac_app_payi_rcode_fechh on "informix"
    .sac_app_payi (r_code,fecha) using btree  in datos02_idx;
    
create index "informix".idx_sac_app_payi_ref_fechaa on "informix"
    .sac_app_payi (unirefnum,fecha) using btree  in datos02_idx;
    
create index "informix".idx_sac_app_payi_ref_folioo on "informix"
    .sac_app_payi (unirefnum,refnum) using btree  in datos02_idx;
    
create index "informix".idx_sac_app_qryi_processtimee on "informix"
    .sac_app_qryi (processtime) using btree  in datos02_idx;
create index "informix".idx_sac_app_qryi_rcode_fechh on "informix"
    .sac_app_qryi (r_code,fecha) using btree  in datos02_idx;
    
create index "informix".idx_sac_app_qryi_ref_fechaa on "informix"
    .sac_app_qryi (unirefnum,fecha) using btree  in datos00_idx;
    
create index "informix".idx_sac_app_qryi_ref_folioo on "informix"
    .sac_app_qryi (unirefnum) using btree  in datos00_idx;
create index "informix".idx_app_getorder_11 on "informix".sac_app_getorder 
    (uniquereferencenumber) using btree  in datos00_idx;
create index "informix".idx_app_getorder_22 on "informix".sac_app_getorder 
    (uniquereferencenumber,fecha_insert) using btree  in datos00_idx;
    
create index "informix".idx_app_getorder_33 on "informix".sac_app_getorder 
    (fecha_insert) using btree  in datos00_idx;
create index "informix".idx_app_getorder_44 on "informix".sac_app_getorder 
    (code,fecha_insert) using btree  in datos00_idx;
create index "informix".idx_app_getorder_55 on "informix".sac_app_getorder 
    (codedetail,fecha_insert) using btree  in datos00_idx;
create index "informix".idx_app_getorder_66 on "informix".sac_app_getorder 
    (estatus_getorder,fecha_insert) using btree  in datos00_idx;
    
create index "informix".idx_app_getorder_77 on "informix".sac_app_getorder 
    (processdaterequest) using btree  in datos00_idx;
create index "informix".idx_app_getorder_88 on "informix".sac_app_getorder 
    (uniquereferencenumber,estatus_getorder) using btree  in 
    datos00_idx;
create index "informix".idx_app_getorder_99 on "informix".sac_app_getorder 
    (uniquereferencenumber,currencycodeorigin,accountnumbersenderpay,
    estatus_getorder) using btree  in datos00_idx;
create index "informix".idx_app_recordorder_11 on "informix".sac_app_recordorder 
    (uniquereferencenumber) using btree  in datos00_idx;
create index "informix".idx_app_recordorder_22 on "informix".sac_app_recordorder 
    (uniquereferencenumber,fecha_insert) using btree  in datos00_idx;
    
create index "informix".idx_app_recordorder_33 on "informix".sac_app_recordorder 
    (fecha_insert) using btree  in datos00_idx;
create index "informix".idx_app_confirmpayment_11 on "informix"
    .sac_app_confirmpayment (uniquereferencenumber) using btree 
     in datos02_idx;
create index "informix".idx_app_confirmpayment_22 on "informix"
    .sac_app_confirmpayment (uniquereferencenumber,referencenumber) 
    using btree  in datos02_idx;
create index "informix".idx_app_confirmpayment_33 on "informix"
    .sac_app_confirmpayment (code,fecha_insert) using btree  
    in datos02_idx;
create index "informix".idx_app_confirmpayment_44 on "informix"
    .sac_app_confirmpayment (uniquereferencenumber,fecha_insert) 
    using btree  in datos02_idx;
create index "informix".idx_ws_ccta_2 on "informix".sac_ws_ccta_old2 
    (agent_trans_type_code,agent_cd,num_cta,fecha_peticion,hora_peticion,
    fecha_insert) using btree  in datos00_idx;
create index "informix".idx_sac_app_revi_rcode_fechh on "informix"
    .sac_app_revi (r_code,fecha) using btree  in datos01_idx;
    
create index "informix".idx_sac_app_revi_ref_fechaa on "informix"
    .sac_app_revi (unirefnum,fecha) using btree  in datos01_idx;
    
create index "informix".idx_sac_app_revi_ref_folioo on "informix"
    .sac_app_revi (unirefnum,refnum) using btree  in datos01_idx;
    
create index "informix".idx_sac_agentes on "informix".sac_agentes 
    (val) using btree  in datos02_idx;
create index "informix".idx_sac_wu_cancelpay_old on "informix"
    .sac_wu_cancelpay_old (retcode,mtcn,referencia_sistema_externo,
    fecha_insert) using btree  in datos02_idx;
create index "informix".idx_pagos_telmex_folio on "informix".sac_pagos_telmex 
    (foliosuc) using btree  in datos02_idx;
create index "informix".idx_pagos_telmex_telfech on "informix"
    .sac_pagos_telmex (numtel,fecha) using btree  in datos02_idx;
    
create index "informix".idx_sac_movimientoshist3 on "informix"
    .sac_movimientoshistorial_old (fecha_pago) using btree  in 
    dbs_movhis_idx3;
create index "informix".idxsac_movhis234_old on "informix".sac_movimientoshistorial_old 
    (numcategoria,numconvenio,referencia1) using btree  in dbs_movhis_idx2;
    
create index "informix".idxsac_movhisfe_old on "informix".sac_movimientoshistorial_old 
    (numcategoria,numconvenio,fecha_pago) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_sac_app_fec_cte on "informix".sac_app_payi_old 
    (fecha,numcte) using btree  in dbs_idxinteg;
create index "informix".idx_sac_app_payi_01 on "informix".sac_app_payi_old 
    (r_code,r_code_d,fecha) using btree  in dbs_movhis_idx2;
create index "informix".idx_sac_app_payi_processtime on "informix"
    .sac_app_payi_old (processtime) using btree  in dbs_idxinteg;
    
create index "informix".idx_sac_app_payi_rcode_fech on "informix"
    .sac_app_payi_old (r_code,fecha) using btree  in dbs_idxinteg;
    
create index "informix".idx_sac_app_payi_ref_fecha on "informix"
    .sac_app_payi_old (unirefnum,fecha) using btree  in dbs_idxinteg;
    
create index "informix".idx_sac_app_payi_ref_folio on "informix"
    .sac_app_payi_old (unirefnum,refnum) using btree  in dbs_movhis_idx2;
    
create index "informix".idxsac_app_payi1 on "informix".sac_app_payi_old 
    (firstname,middlename,lastname,mommaidenname,dateofbirth,
    r_currencycode) using btree  in dbs_movhis_idx2;
create index "informix".idxsac_app_payifi on "informix".sac_app_payi_old 
    (dateofbirth,numberci) using btree  in dbs_movhis_idx2;
create index "informix".idxsac_app_payifiu on "informix".sac_app_payi_old 
    (dateofbirth,numberci,unirefnum) using btree  in dbs_movhis_idx2;
    
create index "informix".idx_wu_search_old1 on "informix".sac_wu_search_old 
    (mtcn,fecha_insert) using btree  in dbs_movhis_idx6;
create index "informix".idx_wu_search_old2 on "informix".sac_wu_search_old 
    (mtcn) using btree  in dbs_movhis_idx6;
create index "informix".idx_wu_search_old3 on "informix".sac_wu_search_old 
    (fecha_insert) using btree  in dbs_movhis_idx6;
create index "informix".idx_bts_sdep_old01 on "informix".sac_bts_sdep_old 
    (opcode,fecha_proceso,num_confirmacion) using btree  in dbs_movhis_idx5;
    
create index "informix".idx_bts_sdep_old02 on "informix".sac_bts_sdep_old 
    (cuenta_benef) using btree  in dbs_movhis_idx5;
create index "informix".idx_bts_sdep_old03 on "informix".sac_bts_sdep_old 
    (fecha_proceso,hora_proceso,num_confirmacion) using btree 
     in dbs_movhis_idx5;
create index "informix".idx_bts_sdep_old04 on "informix".sac_bts_sdep_old 
    (num_confirmacion) using btree  in dbs_movhis_idx5;
create index "informix".idx_bts_sdep_old05 on "informix".sac_bts_sdep_old 
    (fecha_proceso,num_confirmacion) using btree  in dbs_movhis_idx6;
    
create index "informix".idx_bts_sdep_old06 on "informix".sac_bts_sdep_old 
    (num_confirmacion,estatus_sdep) using btree  in dbs_movhis_idx6;
    
create index "informix".idx_bts_sdep_old07 on "informix".sac_bts_sdep_old 
    (estatus_sdep) using btree  in dbs_movhis_idx6;
create index "informix".app_confirmpayment_idx on "informix".sac_app_confirmpayment_old 
    (uniquereferencenumber) using btree  in dbs_movhis_idx5;
create index "informix".app_confirmpayment_idx_2 on "informix"
    .sac_app_confirmpayment_old (uniquereferencenumber,referencenumber) 
    using btree  in dbs_movhis_idx5;
create index "informix".app_confirmpayment_idx_3 on "informix"
    .sac_app_confirmpayment_old (code,fecha_insert) using btree 
     in dbs_movhis_idx6;
create index "informix".app_confirmpayment_idx_4 on "informix"
    .sac_app_confirmpayment_old (uniquereferencenumber,fecha_insert) 
    using btree  in dbs_movhis_idx6;
create index "informix".app_recordorder_idx on "informix".sac_app_recordorder_old 
    (uniquereferencenumber) using btree  in dbs_movhis_idx5;
create index "informix".app_recordorder_idx_2 on "informix".sac_app_recordorder_old 
    (uniquereferencenumber,fecha_insert) using btree  in dbs_movhis_idx5;
    
create index "informix".app_recordorder_idx_3 on "informix".sac_app_recordorder_old 
    (fecha_insert) using btree  in dbs_movhis_idx6;
create index "informix".crea_idx_sac_catalogos_taecoppel_cat_con 
    on "informix".sac_catalogos_taecoppel (numcategoria,numconvenio) 
    using btree  in dbs_movhis_idx3;
create index "informix".idx_sac_catalogos_taecoppel2 on "informix"
    .sac_catalogos_taecoppel (compania) using btree  in dbs_movhis_idx5;
    
create index "informix".crea_idx_sac_control_convenios_canales_cat_con_can 
    on "informix".sac_control_convenios_canales (numcategoria,
    numconvenio,canal) using btree  in datos02_idx;
create index "informix".idx_sac_wu_old_fec_cte on "informix".sac_wu_pay_old 
    (fecha_insert,numcte) using btree ;
create index "informix".idx_wu_pay_old1 on "informix".sac_wu_pay_old 
    (mtcn,fecha_insert) using btree ;
create index "informix".idx_wu_pay_old2 on "informix".sac_wu_pay_old 
    (conf_pago,fecha_insert) using btree ;
create index "informix".idx_wu_pay_old3 on "informix".sac_wu_pay_old 
    (benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno) 
    using btree ;
create index "informix".idx_wu_pay_old4 on "informix".sac_wu_pay_old 
    (retcode,conf_pago,fecha_insert) using btree ;
create index "informix".idxsac_wu_pay_oldfi on "informix".sac_wu_pay_old 
    (benef_fecha_nac,benef_id_number) using btree ;
create index "informix".idxsac_wu_pay_oldfim on "informix".sac_wu_pay_old 
    (benef_fecha_nac,benef_id_number,mtcn) using btree ;
create index "informix".idx_sac_app_qryi_processtime on "informix"
    .sac_app_qryi_old (processtime) using btree ;
create index "informix".idx_sac_app_qryi_rcode_fech on "informix"
    .sac_app_qryi_old (r_code,fecha) using btree ;
create index "informix".idx_sac_app_qryi_ref_fecha on "informix"
    .sac_app_qryi_old (unirefnum,fecha) using btree ;
create index "informix".idx_sac_app_qryi_ref_folio on "informix"
    .sac_app_qryi_old (unirefnum) using btree ;
create index "informix".idx_ws_proces_1 on "informix".sac_ws_procesos_old 
    (proceso,fecha_proceso,estatus) using btree  in dbs_movhis_idx1;
    
create index "informix".idx_bitacora_aplicapago_hs on "informix"
    .bitacora_aplicapago_hs (categoria,convenio,folio_operacion) 
    using btree  in dbs_idxinteg;
create index "informix".idxsac_bitacora_flags on "informix".sac_bitacora_flags 
    (fecha_insert,numcategoria,numconvenio) using btree  in dbs_cfd_idxs;
    
create index "informix".idxsac_benefremesasfm on "informix".sac_benefremesas 
    (fecha,marca) using btree  in idx_info04;
create index "informix".idx_sac_movimientosdetallehistorial on 
    "informix".sac_movimientosdetallehistorial (cliente,recibo,
    fecha) using btree  in dbs_mov_idx_02;
create index "informix".idxsac_remesaslimitepld_appf on "informix"
    .sac_remesaslimitepld_app (fecha) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_appfc on "informix"
    .sac_remesaslimitepld_app (fecha,codigo) using btree  in 
    datos00;
create index "informix".idxsac_remesaslimitepld_appfs on "informix"
    .sac_remesaslimitepld_app (fecha,sucursal) using btree  in 
    datos00;
create index "informix".idxsac_remesaslimitepld_appnc on "informix"
    .sac_remesaslimitepld_app (numconfirmacion) using btree  
    in datos02_idx;
create index "informix".idxsac_remesaslimitepld_btsf on "informix"
    .sac_remesaslimitepld_bts (fecha) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_btsfc on "informix"
    .sac_remesaslimitepld_bts (fecha,codigo) using btree  in 
    datos00;
create index "informix".idxsac_remesaslimitepld_btsfs on "informix"
    .sac_remesaslimitepld_bts (fecha,sucursal) using btree  in 
    datos00;
create index "informix".idxsac_remesaslimitepld_btsnc on "informix"
    .sac_remesaslimitepld_bts (numconfirmacion) using btree  
    in datos02_idx;
create index "informix".idxsac_remesaslimitepld_wuf on "informix"
    .sac_remesaslimitepld_wu (fecha) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_wufc on "informix"
    .sac_remesaslimitepld_wu (fecha,codigo) using btree  in datos00;
    
create index "informix".idxsac_remesaslimitepld_wufs on "informix"
    .sac_remesaslimitepld_wu (fecha,sucursal) using btree  in 
    datos00;
create index "informix".idxsac_remesaslimitepld_wunc on "informix"
    .sac_remesaslimitepld_wu (numconfirmacion) using btree  in 
    datos02_idx;
create index "informix".idx_ws_proces on "informix".sac_ws_procesos 
    (proceso,fecha_proceso,estatus) using btree  in dbs_movhis_idx1;
    
create index "informix".idx_ws_ccta_1 on "informix".sac_ws_ccta 
    (agent_trans_type_code,agent_cd,num_cta,fecha_peticion,hora_peticion,
    fecha_insert) using btree  in datos00_idx;
create index "informix".idx_bitacora1 on "informix".sac_bitacora_errores_remesas 
    (referencia) using btree  in datos01_idx;
create index "informix".idx_bitacora2 on "informix".sac_bitacora_errores_remesas 
    (fecha_insert) using btree  in datos01_idx;
create index "informix".idxsac_bitacora_flagsnnf on "informix"
    .sac_bitacora_flags_old (numcategoria,numconvenio,fecha_pago) 
    using btree  in datos00;
create index "informix".idx_sac_bts_payc_old01 on "informix".sac_bts_payc_old 
    (opcode,fecha_insert) using btree  in datos00_idx;
create index "informix".idx_sac_control_proceso_archivo_tapi_nom_archi 
    on "informix".sac_control_proceso_archivo_tapi (nombre_archivo) 
    using btree  in datos00_idx;
create index "informix".idx_sac_arch_conci_tapi_company_code 
    on "informix".sac_arch_conci_tapi (company_code) using btree 
     in datos00_idx;
create index "informix".idx_sac_bts_old_fec_cte on "informix".sac_bts_payi_old 
    (fecha_insert,numcte) using btree  in dbs_movhis_idx1;
create index "informix".idx_sac_bts_payi01 on "informix".sac_bts_payi_old 
    (agent_dt,opcode) using btree  in dbs_movhis_idx1;
create index "informix".idx_sac_bts_payi02 on "informix".sac_bts_payi_old 
    (confirmation_nm,bank_ref_nm,opcode) using btree  in dbs_movhis_idx1;
    
create index "informix".idx_sac_bts_payi03 on "informix".sac_bts_payi_old 
    (agent_trans_type_code,agent_cd,confirmation_nm,terminal) 
    using btree  in dbs_movhis_idx1;
create index "informix".idx_sac_bts_payi04 on "informix".sac_bts_payi_old 
    (confirmation_nm,bank_ref_nm,opcode,process_dt) using btree 
     in dbs_movhis_idx1;
create index "informix".idx_sac_bts_payi05 on "informix".sac_bts_payi_old 
    (opcode,fecha_insert) using btree  in dbs_movhis_idx2;
create index "informix".idx_sac_bts_payi06 on "informix".sac_bts_payi_old 
    (agent_dt,r_first_name,r_middle_name,r_last_name,r_mother_m_name,
    r_fecha_nac,opcode) using btree  in dbs_movhis_idx2;
create index "informix".idxsac_bts_payi_oldfi on "informix".sac_bts_payi_old 
    (r_identif_nm,r_fecha_nac) using btree  in dbs_movhis_idx1;
    
create index "informix".idxsac_bts_payi_oldfic on "informix".sac_bts_payi_old 
    (confirmation_nm,r_identif_nm,r_fecha_nac) using btree  in 
    dbs_movhis_idx2;
create index "informix".idx_sac_remesas_estadistica_old_01 on 
    "informix".sac_remesas_estadistica_old (numcategoria,numconvenio,
    fecha_pago) using btree  in dbs_idxinteg;
create index "informix".idx_sac_remesas_estadistica_old_03 on 
    "informix".sac_remesas_estadistica_old (referencia) using 
    btree  in dbs_idxinteg;
create index "informix".idx_sac_remesas_estadistica_old_09 on 
    "informix".sac_remesas_estadistica_old (fecha_pago) using 
    btree  in dbs_idxinteg;
create index "informix".idxsac_pld_fecha_remesa on "informix".sac_pld_remesas 
    (tipo_remesa,fecha_remesa) using btree ;
create index "informix".idxsac_pld_fecha_remesa2 on "informix"
    .sac_pld_remesas (fecha_remesa) using btree ;
create index "informix".idxsac_pld_fecha_tipo_abono on "informix"
    .sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta) 
    using btree ;
create index "informix".idxsac_pld_remesasft on "informix".sac_pld_remesas 
    (fecha_proceso,tipo_remesa) using btree ;
create index "informix".idxsac_pld_remesasft2 on "informix".sac_pld_remesas 
    (num_confirmacion,fecha_proceso) using btree ;
create index "informix".idxsac_pld_remesasft3 on "informix".sac_pld_remesas 
    (folio_sucursal) using btree ;
create index "informix".app_getorder_idx on "informix".sac_app_getorder_old 
    (uniquereferencenumber) using btree ;
create index "informix".app_getorder_idx_2 on "informix".sac_app_getorder_old 
    (uniquereferencenumber,fecha_insert) using btree ;
create index "informix".app_getorder_idx_3 on "informix".sac_app_getorder_old 
    (fecha_insert) using btree ;
create index "informix".app_getorder_idx_4 on "informix".sac_app_getorder_old 
    (code,fecha_insert) using btree ;
create index "informix".app_getorder_idx_5 on "informix".sac_app_getorder_old 
    (codedetail,fecha_insert) using btree ;
create index "informix".app_getorder_idx_6 on "informix".sac_app_getorder_old 
    (estatus_getorder,fecha_insert) using btree ;
create index "informix".app_getorder_idx_7 on "informix".sac_app_getorder_old 
    (processdaterequest) using btree ;
create index "informix".app_getorder_idx_8 on "informix".sac_app_getorder_old 
    (uniquereferencenumber,estatus_getorder) using btree ;
create index "informix".app_getorder_idx_9 on "informix".sac_app_getorder_old 
    (uniquereferencenumber,currencycodeorigin,accountnumbersenderpay,
    estatus_getorder) using btree ;
create index "informix".idx_sac_proceso_conciliacion_telcel_nombre_archivo_clave_rastreo_estatus 
    on "informix".sac_proceso_conciliacion_telcel (nombre_archivo,
    clave_rastreo,estatus) using btree  in idx_info04;


alter table "informix".sac_convenios add constraint (foreign 
    key (numcategoria) references "informix".sac_categorias );
    
alter table "informix".sac_convenios add constraint (foreign 
    key (tipo_referencia) references "informix".sac_tiporeferencia 
    );
alter table "informix".sac_convenios add constraint (foreign 
    key (statusconvenio) references "informix".sac_statusconvenio 
    );
alter table "informix".sac_eglobal_encabezado add constraint 
    (foreign key (fecha_archivo,nombre_archivo) references "informix"
    .sac_eglobal_archivos );
alter table "informix".sac_eglobal_sumario add constraint (foreign 
    key (fecha_archivo,nombre_archivo) references "informix".sac_eglobal_archivos 
    );
alter table "informix".sac_enviosdineroya add constraint (foreign 
    key (estatus) references "informix".sac_estatus );
alter table "informix".sac_enviosdineroya add constraint (foreign 
    key (identificacion) references "informix".sac_identificacion 
    );
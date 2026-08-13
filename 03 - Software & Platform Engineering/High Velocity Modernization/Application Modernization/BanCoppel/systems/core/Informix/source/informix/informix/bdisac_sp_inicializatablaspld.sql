CREATE PROCEDURE "informix".sp_inicializatablaspld(pIdentificador CHAR(4),pTiporemesa CHAR(3),FechaFin DATE)
RETURNING CHAR(5);
    DEFINE iSqlErr, iIsamErr  INTEGER;
    DEFINE cCodRet            CHAR(5);
    DEFINE cInfoErr           CHAR(100);
	
    LET cCodRet = '00000';

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_inicializatablaspld");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		IF pIdentificador = 'BBTS' THEN
			delete {+INDEX(bdisac:"informix".sac_cargo_bts idxsac_cargo_btsff)} from bdisac:"informix".sac_cargo_bts;
			delete {+INDEX(bdisac:"informix".sac_movtos_bts idxsac_movtos_btsr1)} from bdisac:"informix".sac_movtos_bts;
			delete {+INDEX(bdisac:"informix".sac_vntnilla_cargo_bts idxsac_vntnilla_cargo_btsffs)} from bdisac:"informix".sac_vntnilla_cargo_bts;
			delete {+INDEX(bdisac:"informix".sac_vntnilla_movtos idxsac_vntnilla_movtosr1)} from bdisac:"informix".sac_vntnilla_movtos;
			delete {+INDEX(bdisac:"informix".sac_qryis idxsac_qryiscs)} from bdisac:"informix".sac_qryis;
			delete {+INDEX(bdisac:"informix".sac_datos1_query idxsac_datos1_queryc)} from bdisac:"informix".sac_datos1_query;
			delete {+INDEX(bdisac:"informix".sac_datos2_query idxsac_datos2_queryn)} from bdisac:"informix".sac_datos2_query;
			delete {+INDEX(bdisac:"informix".sac_vntnilla_payi idxsac_vntnilla_payics)} from bdisac:"informix".sac_vntnilla_payi;
			delete {+INDEX(bdisac:"informix".sac_vntnilla_payi1 idxsac_vntnilla_payi1c)} from bdisac:"informix".sac_vntnilla_payi1;
		
		ELIF pIdentificador = 'BWUN' THEN
			delete {+INDEX(bdisac:"informix".sac_cheques_wu idxsac_cheques_wuff)} from "informix".sac_cheques_wu;
			delete {+INDEX(bdisac:"informix".sac_servicios_wu idxsac_servicios_wur1)} from "informix".sac_servicios_wu;
			delete {+INDEX(bdisac:"informix".sac_secuencia_search idxsac_secuencia_searchps)} from "informix".sac_secuencia_search;
			delete {+INDEX(bdisac:"informix".sac_datos_search idxsac_datos_searchp)} from "informix".sac_datos_search;
			delete {+INDEX(bdisac:"informix".sac_secuencias_pay idxsac_secuencias_paysm)} from "informix".sac_secuencias_pay;
			delete {+INDEX(bdisac:"informix".sac_datos_pay_wu idxsac_datos_pay_wum)} from "informix".sac_datos_pay_wu;
			
		ELIF pIdentificador = 'BAPP' THEN
			delete {+INDEX(bdisac:"informix".sac_cheques_app idxsac_cheques_appff)} from "informix".sac_cheques_app;
			delete {+INDEX(bdisac:"informix".sac_servicios_app idxsac_servicios_appr1)} from "informix".sac_servicios_app;
			delete {+INDEX(bdisac:"informix".sac_secuenciaqryi_app idxsac_secuenciaqryi_appus)} from "informix".sac_secuenciaqryi_app;
			delete {+INDEX(bdisac:"informix".sac_qryi_app idxsac_qryi_appu)} from "informix".sac_qryi_app;
			delete {+INDEX(bdisac:"informix".sac_secuenciapayi_app idxsac_secuenciapayi_appus)} from "informix".sac_secuenciapayi_app;
			delete {+INDEX(bdisac:"informix".sac_payi_app idxsac_payi_appu)} from "informix".sac_payi_app;
			delete {+INDEX(bdisac:"informix".sac_cargo_app idxsac_cargo_appff )} from "informix".sac_cargo_app;
			delete {+INDEX(bdisac:"informix".sac_movtos_app idxsac_movtos_appr1 )} from "informix".sac_movtos_app;
		END IF;
		
		IF pTiporemesa = 'BTS' THEN
			DELETE {+INDEX(bdisac:"informix".sac_pld_remesas idxsac_pld_remesasft)} FROM bdisac:"informix".sac_pld_remesas where tipo_remesa='BTS' and fecha_proceso = FechaFin;										
		ELIF pTiporemesa = 'WUN' THEN
			DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='WUN' and fecha_proceso = FechaFin;										
		ELIF pTiporemesa = 'OVA' THEN
			DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='OVA' and fecha_proceso = FechaFin;	
		ELIF pTiporemesa = 'VIG' THEN  
			DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='VIG' and fecha_proceso = FechaFin;
		ELIF pTiporemesa = 'APP' THEN  
			DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='APP' and fecha_proceso = FechaFin;			
		END IF;
		
		IF pIdentificador = 'UPTD' THEN
			set pdqpriority 0;
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_pld_remesas;		
		END IF;      
        
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Yuridia Espinoza',
'DESCRIPCION: Se encarga de limpiar las tablas de movimientos de PLD',
'EJECUTADO O LLAMADO POR:',
'sp_CierreSACl()',
'FECHA : Noviembre de 2016',
'VERSION: 20161109',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_domi_ord_remesas_wu()
RETURNING VARCHAR(5) AS vsCodRetorno, 
		  VARCHAR(200) AS vsMensaje;

		  
		  
		  
/*DEFINICION DE VARIABLES */
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR (200);

DEFINE iContador_pay	  INTEGER;
DEFINE iContador_movim	  INTEGER;
DEFINE iContador_mov	  INTEGER;
DEFINE iContador_movold   INTEGER;

DEFINE cRemesapay		  CHAR (20);
DEFINE cDomicilio		  CHAR (100);	
DEFINE Cestado			  CHAR (40);

DEFINE cRemesamovim		  CHAR (20);
DEFINE cDomiciliomovim	  CHAR (100);	
DEFINE Cestadomovim		  CHAR (40);
DEFINE cRemesadora		  CHAR (20);
DEFINE dFechamovim		  DATE;
DEFINE cFoliomovim		  CHAR (16);	

DEFINE cRemesamov		  CHAR (20);
DEFINE cDomiciliomov	  CHAR (100);	
DEFINE Cestadomov		  CHAR (40);
DEFINE cRemesadoramov	  CHAR (20);
DEFINE dFechamov		  DATE;

DEFINE cStmt1			  CHAR(200);
DEFINE cStmt2			  CHAR(200);

DEFINE cSQL1			  	  CHAR(500);
DEFINE cSQL				  	  CHAR(500);

DEFINE cNombreArchivo 	  	  CHAR(100);
DEFINE cRutaArchivo 	 	  CHAR(100);


LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = 'PROCESO EXITOSO';

LET iContador_pay	 = '';
LET iContador_movim	 = '';
LET iContador_mov	 = '';
LET iContador_movold = '';

LET cRemesapay = '';
LET cDomicilio = '';
LET Cestado = '';


LET cRemesamovim	= '';
LET cDomiciliomovim	 = '';	
LET Cestadomovim	= '';
LET cRemesadora		= '';
LET dFechamovim		= '';
LET cFoliomovim		= '';

LET cRemesamov	    = '';
LET cDomiciliomov	= '';	
LET Cestadomov	    = '';
LET cRemesadoramov  = '';
LET dFechamov	    = '';


--SET DEBUG FILE TO "/tmp/ALAN/remesas/sp_domi_ord_remesas_wu.out";
--TRACE ON;



BEGIN


	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			LET vsMensaje = 'FALLO EL PROCESO';
			RETURN vsCodRetorno, vsMensaje;
		END IF;
	END EXCEPTION;
	
		TRUNCATE TABLE bdisac:"informix".sac_paso_repremesadoras;
		UPDATE statistics medium FOR TABLE bdisac:"informix".sac_paso_repremesadoras;
	
	
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_wu_rowid') THEN
		DROP TABLE tmp_wu_rowid;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_bitacorawumoneytransfersearch') THEN
		DROP TABLE tmp_bitacorawumoneytransfersearch;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_wu_pay') THEN
		DROP TABLE tmp_sac_wu_pay;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_movimientoshistorial') THEN
		DROP TABLE tmp_sac_movimientoshistorial;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		
		------------------------bitacorawumoneytransfersearch--------------------------------------------------
		
		SELECT {+INDEX(intercard:"informix".bitacorawumoneytransfersearch idxbitacorawumoneytransfersearchfrm )} MAX(rowid) AS id, pt_mtcn FROM intercard:"informix".bitacorawumoneytransfersearch  WHERE fechahorainsercion BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND retcode = '00000'
		GROUP BY 2
		INTO TEMP tmp_wu_rowid WITH NO LOG;
		
		SELECT {+INDEX( intercad:"informix".bitacorawumoneytransfersearch idxbitacorawumoneytransfersearchfrm )} a.pt_mtcn,trim(NVL(receiver_street,''))||' '||trim(NVL(receiver_local_delivery_area,''))||' '||trim(NVL(receiver_state_zip,'')) AS domicilio,trim(NVL(receiver_state,'')) AS estado
		FROM intercard: bitacorawumoneytransfersearch a INNER JOIN tmp_wu_rowid b ON a.rowid = b.id AND a.pt_mtcn = b.pt_mtcn WHERE a.fechahorainsercion BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND a.retcode = '00000'
		INTO TEMP tmp_bitacorawumoneytransfersearch WITH NO LOG;
	
		------------------------sac_wu_pay--------------------------------------------------
		SELECT {+INDEX( bdisac:"informix".sac_wu_pay idx_sac_wu_pay )} a.mtcn,b.domicilio,b.estado
		FROM sac_wu_pay a INNER JOIN tmp_bitacorawumoneytransfersearch b ON a.mtcn = b.pt_mtcn
		WHERE a.conf_pago = 'P' AND a.retcode = '00000'AND a.fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE
		INTO TEMP tmp_sac_wu_pay WITH NO LOG;
		
		
	------------------------sac_wu_pay_old--------------------------------------------------
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT {+INDEX( bdisac:"informix".sac_wu_pay_old idx_wu_pay )} a.mtcn,b.domicilio,b.estado
		INTO cRemesapay,cDomicilio,Cestado
		FROM sac_wu_pay_old a INNER JOIN tmp_bitacorawumoneytransfersearch b ON a.mtcn = b.pt_mtcn
		WHERE a.conf_pago = 'P' AND a.retcode = '00000'AND a.fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE
	LET iContador_pay = iContador_pay + 1;
		INSERT INTO tmp_sac_wu_pay VALUES (cRemesapay, cDomicilio,Cestado);
	IF 	iContador_pay = 1000 THEN
		COMMIT;
		LET	iContador_pay = 0;
		BEGIN WORK;
	END IF;
	END FOREACH;	
	COMMIT;	
	------------------------sac_movimientoshistorial--------------------------------------------------

		SELECT {+INDEX( bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe )}(CASE WHEN numcategoria = '07' AND numconvenio = '006' THEN 'WESTERN UNION' 
		WHEN numcategoria = '07' AND numconvenio = '007' THEN 'ORLANDI VALUTA'
		WHEN numcategoria = '07' AND numconvenio = '008' THEN 'VIGO' END)AS remesadora,a.referencia1,a.fecha_pago,a.folio_suc,b.domicilio,b.estado
		FROM sac_movimientoshistorial a INNER JOIN tmp_sac_wu_pay b ON a.referencia1 = b.mtcn WHERE a.status_cancelado <> 'S' AND a.fecha_pago BETWEEN '03012017' AND '05312017' AND a.numcategoria = '07' AND a.numconvenio IN('007','008','006')
		INTO TEMP tmp_sac_movimientoshistorial WITH NO LOG;

	------------------------sac_movimientoshistorial_old--------------------------------------------------	
	BEGIN WORK;	
	FOREACH WITH HOLD
		SELECT{+INDEX( bdisac:"informix".sac_movimientoshistorial_old idxsac_movhis234_old )} (CASE WHEN numcategoria = '07' AND numconvenio = '006' THEN 'WESTERN UNION' 
		WHEN numcategoria = '07' AND numconvenio = '007' THEN 'ORLANDI VALUTA'
		WHEN numcategoria = '07' AND numconvenio = '008' THEN 'VIGO' END)AS remesadora,a.referencia1,a.fecha_pago,a.folio_suc,b.domicilio,b.estado
		INTO cRemesadora,cRemesamovim,dFechamovim,cFoliomovim,cDomiciliomovim,Cestadomovim
		FROM sac_movimientoshistorial_old a INNER JOIN tmp_sac_wu_pay b ON a.referencia1 = b.mtcn WHERE a.status_cancelado <> 'S' AND a.fecha_pago BETWEEN '03012017' AND '05312017' AND a.numcategoria = '07' AND a.numconvenio IN('007','008','006')
	LET iContador_movim = iContador_movim + 1;
		INSERT INTO tmp_sac_movimientoshistorial VALUES (cRemesadora,cRemesamovim,dFechamovim,cFoliomovim,cDomiciliomovim,Cestadomovim);
	IF 	iContador_movim = 1000 THEN
		COMMIT;
		LET iContador_movim = 0;
		BEGIN WORK;
	END IF;
	END FOREACH;
	COMMIT;
	
		------------------------sc_movhis--------------------------------------------------	
		LET cStmt1 =  'Remesadora'||','||'Num_remesa'||','||'Fecha'||','||'Domicilio'||','||'Estado';
		INSERT INTO sac_paso_repremesadoras (linea)
		VALUES(cStmt1);
		
	BEGIN WORK;	
	FOREACH	WITH HOLD
		SELECT {+INDEX( bdicheq:"informix".sc_movhis idx_movhisnew4 )} b.remesadora,b.referencia1,b.fecha_pago,trim(b.domicilio),trim(b.estado)
		INTO cRemesadoramov,cRemesamov,dFechamov,cDomiciliomov,Cestadomov
		FROM bdicheq:sc_movhis a INNER JOIN tmp_sac_movimientoshistorial b ON a.folio_suc = b.folio_suc
		WHERE a.cancelad  <> 'S' AND a.transacc IN ('1121','1151','1122','1152','1123','1153') AND a.fech_alt BETWEEN '03012017' AND '05312017' AND a.empresa = '001'
	LET iContador_mov = iContador_mov + 1;	
		LET cStmt2 =  trim(cRemesadoramov)||','||trim(cRemesamov)||','||dFechamov||','||trim(NVL(cDomiciliomov,''))||','||trim(NVL(Cestadomov,''));
		INSERT INTO sac_paso_repremesadoras (linea)
		VALUES(cStmt2);
	IF 	iContador_mov = 1000 THEN
		COMMIT;
		LET iContador_mov = 0;
		BEGIN WORK;
	END IF;
	END FOREACH;
	COMMIT;	
	
	LET cRemesamov	    = '';
	LET cDomiciliomov	= '';	
	LET Cestadomov	    = '';
	LET cRemesadoramov  = '';
	LET dFechamov	    = '';
	
	LET cStmt2			= '';
		
	------------------------sc_movhis_old--------------------------------------------------	
	BEGIN WORK;	
	FOREACH	WITH HOLD
		SELECT{+INDEX( bdicheq:"informix".sc_movhis_old movhis1 )} b.remesadora,b.referencia1,b.fecha_pago,trim(b.domicilio),trim(b.estado)
		INTO cRemesadoramov,cRemesamov,dFechamov,cDomiciliomov,Cestadomov
		FROM bdicheq:sc_movhis_old a INNER JOIN tmp_sac_movimientoshistorial b ON a.folio_suc = b.folio_suc
		WHERE a.cancelad  <> 'S' AND a.transacc IN ('1121','1151','1122','1152','1123','1153') AND a.fech_alt BETWEEN '03012017' AND '05312017' AND a.empresa = '001'
	LET iContador_movold = iContador_movold + 1;	
		LET cStmt2 =  trim(cRemesadoramov)||','||trim(cRemesamov)||','||dFechamov||','||trim(NVL(cDomiciliomov,''))||','||trim(NVL(Cestadomov,''));
		INSERT INTO sac_paso_repremesadoras (linea)
		VALUES(cStmt2);
	IF 	iContador_movold = 1000 THEN
		COMMIT;
		LET iContador_movold = 0;
		BEGIN WORK;
	END IF;
	END FOREACH;
	COMMIT;	
	
	--Nombre del archivo
	LET cRutaArchivo = '/RESPALDOS/';
	LET cNombreArchivo = 'Reporte_de_remesadoras_wu'||'.csv';
	
	LET cSQL1 = 'echo "UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNombreArchivo)||' delimiter '||' SELECT linea FROM bdisac	:"informix".sac_paso_repremesadoras ORDER BY secuencial" >'||TRIM(cRutaArchivo)||'Ejecuta_archivo_remesas.sql';
	SYSTEM cSQL1;

	LET cSQL='dbaccess bdisac '||TRIM(cRutaArchivo)||'Ejecuta_archivo_remesas.sql';
	SYSTEM cSQL;
	
		DROP TABLE tmp_wu_rowid;
		DROP TABLE tmp_bitacorawumoneytransfersearch;
		DROP TABLE tmp_sac_wu_pay;
		DROP TABLE tmp_sac_movimientoshistorial;
	
		
	RETURN vsCodRetorno, vsMensaje;
	
	
END;
END PROCEDURE;
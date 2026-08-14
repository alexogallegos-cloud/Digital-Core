CREATE PROCEDURE "informix".sp_domi_ord_remesas_bts()
RETURNING VARCHAR(5) AS vsCodRetorno, 
		  VARCHAR(200) AS vsMensaje;
		    
		  
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR (200);

DEFINE iContador_payi		  INTEGER;
DEFINE iContador_qryi		  INTEGER;
DEFINE iContador_movim		  INTEGER;
DEFINE iContador_mov		  INTEGER;
DEFINE iContador_mov_old	  INTEGER;

DEFINE cRemesabtsqryi	  CHAR (20);
DEFINE cDomiciliobtsqryi  CHAR (100);
DEFINE Cestadobtsqryi	  CHAR (40);    
		  
DEFINE cRemesabts		CHAR (20);
DEFINE cDomiciliobts	CHAR (100);
DEFINE Cestadobts		CHAR (40);
DEFINE cFoliobts		CHAR (16);

DEFINE cRemesamovimbts		  CHAR (20);
DEFINE cDomiciliomovimbts	  CHAR (100);	
DEFINE Cestadomovimbts		  CHAR (40);
DEFINE cRemesadorabts		  CHAR (20);
DEFINE dFechamovimbts		  DATE;
DEFINE cFoliomovimbts		  CHAR (16);

DEFINE cRemesamovbts		  CHAR (20);
DEFINE cDomiciliomovbts	  	  CHAR (100);	
DEFINE Cestadomovbts		  CHAR (40);
DEFINE cRemesadoramovbts	  CHAR (20);
DEFINE dFechamovbts			  DATE;

DEFINE cStmt1			  CHAR(200);
DEFINE cStmt2			  CHAR(200);

DEFINE cSQL1			  	  CHAR(500);
DEFINE cSQL				  	  CHAR(500);

DEFINE cNombreArchivo 	  	  CHAR(100);
DEFINE cRutaArchivo 	 	  CHAR(100);

LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = 'PROCESO EXITOSO';

LET iContador_payi		   = 0;
LET iContador_qryi		   = 0;
LET iContador_movim		   = 0;
LET iContador_mov		   = 0;
LET iContador_mov_old	   = 0;

LET cRemesabtsqryi	  = '';
LET cDomiciliobtsqryi = '';
LET Cestadobtsqryi	  = ''; 

LET cRemesabts	    = '';
LET cDomiciliobts   = '';
LET Cestadobts	    = '';

LET cFoliobts		= '';

LET cRemesamovimbts 	= '';
LET cDomiciliomovimbts	= '';	
LET Cestadomovimbts	    = '';
LET cRemesadorabts		= '';
LET dFechamovimbts		= '';
LET cFoliomovimbts		= '';

LET cRemesamovbts	    = '';
LET cDomiciliomovbts	= '';	
LET Cestadomovbts	    = '';
LET cRemesadoramovbts   = '';
LET dFechamovbts	    = '';

--SET DEBUG FILE TO "/tmp/ALAN/remesas/sp_domi_ord_remesas_bts.out";
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
	
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_bts_rowid') THEN
		DROP TABLE tmp_bts_rowid;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_bts_qryi') THEN
		DROP TABLE tmp_sac_bts_qryi;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_bts_payi') THEN
		DROP TABLE tmp_sac_bts_payi;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_movimientoshistorialbts') THEN
		DROP TABLE tmp_sac_movimientoshistorialbts;
		END IF;
	
		SET ISOLATION TO DIRTY READ;
		
		------------------------BTS VENTANILLA--------------------------------------------------
	
	------------------------sac_bts_qryi--------------------------------------------------
	
		SELECT{+INDEX( bdisac:"informix".sac_bts_qryi idx_btsqryi )} MAX(rowid) AS id, confirmation_nm
		FROM sac_bts_qryi WHERE fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND txn_status = 'A' AND opcode = '1000' AND branch_sd <> '9250' 
		GROUP BY 2
		INTO TEMP tmp_bts_rowid WITH NO LOG;	
	
	    SELECT{+INDEX( bdisac:"informix".sac_bts_qryi idx_btsqryi )} a.confirmation_nm,trim(NVL(r_address,''))||' '||trim(NVL(r_zip_code,'')) AS domicilio,trim(NVL(r_state_cd,'')) AS estado
		FROM sac_bts_qryi a INNER JOIN tmp_bts_rowid b ON a.rowid = b.id AND a.confirmation_nm = b.confirmation_nm  WHERE a.fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND a.txn_status = 'A' AND a.opcode = '1000'
		INTO TEMP tmp_sac_bts_qryi WITH NO LOG;
		
		------------------------sac_bts_qryi_old--------------------------------------------------
	BEGIN WORK;	
	FOREACH WITH HOLD
		SELECT{+INDEX( bdisac:"informix".sac_bts_qryi_old idx_bts_qryi_old2 )} a.confirmation_nm,trim(NVL(r_address,''))||' '||trim(NVL(r_zip_code,'')) AS domicilio,trim(NVL(r_state_cd,'')) AS estado
		INTO cRemesabtsqryi, cDomiciliobtsqryi,Cestadobtsqryi
		FROM sac_bts_qryi_old a INNER JOIN tmp_bts_rowid b ON a.rowid = b.id AND a.confirmation_nm = b.confirmation_nm  WHERE a.fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND a.txn_status = 'A' AND a.opcode = '1000'
	LET iContador_qryi = iContador_qryi + 1; 
		INSERT INTO tmp_sac_bts_qryi VALUES (cRemesabtsqryi, cDomiciliobtsqryi,Cestadobtsqryi);
	IF 	iContador_qryi = 1000 THEN
		COMMIT;
		LET iContador_qryi = 0;
		BEGIN WORK;
	END IF;
	END FOREACH;
	COMMIT;	
    ------------------------sac_bts_payi--------------------------------------------------
	
		SELECT{+INDEX( bdisac:"informix".sac_bts_payi idx_sac_bts_payi3 )} a.confirmation_nm,b.domicilio,b.estado,a.bank_ref_nm
		FROM sac_bts_payi a INNER JOIN tmp_sac_bts_qryi b ON a.confirmation_nm = b.confirmation_nm
		WHERE a.txn_status = 'A' AND a.opcode = '1100' AND a.fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE
		INTO TEMP tmp_sac_bts_payi WITH NO LOG;
		
	------------------------sac_bts_payi_old--------------------------------------------------
	BEGIN WORK;
	FOREACH WITH HOLD 
	
		SELECT{+INDEX( bdisac:"informix".sac_bts_payi_old idx_sac_bts_payi05 )} a.confirmation_nm,b.domicilio,b.estado,a.bank_ref_nm
		INTO cRemesabts, cDomiciliobts,Cestadobts,cFoliobts
		FROM sac_bts_payi_old a INNER JOIN tmp_sac_bts_qryi b ON a.confirmation_nm = b.confirmation_nm   
		WHERE a.txn_status = 'A' AND a.opcode = '1100' AND a.fecha_insert BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE
	LET iContador_payi = iContador_payi + 1;
		INSERT INTO tmp_sac_bts_payi VALUES (cRemesabts, cDomiciliobts,Cestadobts,cFoliobts);
	IF iContador_payi = 1000 THEN
		COMMIT;
		LET iContador_payi = 0;
		BEGIN WORK;
	END IF;	
	END FOREACH;	
	COMMIT;		
	
	------------------------sac_movimientoshistorial--------------------------------------------------

		SELECT{+INDEX( bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe )}(CASE WHEN numcategoria = '07' AND numconvenio = '004' THEN 'BTS'END)AS remesadora,a.referencia1,a.fecha_pago,a.folio_suc,b.domicilio,b.estado
		FROM sac_movimientoshistorial a INNER JOIN tmp_sac_bts_payi b ON a.referencia1 = b.confirmation_nm AND a.folio_suc = b.bank_ref_nm  WHERE a.status_cancelado <> 'S' AND a.fecha_pago BETWEEN '03012017' AND '05312017' AND a.numcategoria = '07' AND a.numconvenio = '004'
		INTO TEMP tmp_sac_movimientoshistorialbts WITH NO LOG;

	------------------------sac_movimientoshistorial_old--------------------------------------------------	
	BEGIN WORK;	
	FOREACH	WITH HOLD
		SELECT{+INDEX( bdisac:"informix".sac_movimientoshistorial_old idxsac_movhis234_old )} (CASE WHEN numcategoria = '07' AND numconvenio = '004' THEN 'BTS'END)AS remesadora,a.referencia1,a.fecha_pago,a.folio_suc,b.domicilio,b.estado
		INTO cRemesadorabts,cRemesamovimbts,dFechamovimbts,cFoliomovimbts,cDomiciliomovimbts,Cestadomovimbts
		FROM sac_movimientoshistorial_old a INNER JOIN tmp_sac_bts_payi b ON a.referencia1 = b.confirmation_nm AND a.folio_suc = b.bank_ref_nm WHERE a.status_cancelado <> 'S' AND a.fecha_pago BETWEEN '03012017' AND '05312017' AND a.numcategoria = '07' AND a.numconvenio = '004'
	LET iContador_movim =  iContador_movim + 1;
		INSERT INTO tmp_sac_movimientoshistorialbts VALUES (cRemesadorabts,cRemesamovimbts,dFechamovimbts,cFoliomovimbts,cDomiciliomovimbts,Cestadomovimbts);
	IF iContador_movim = 1000 THEN 
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
	FOREACH WITH HOLD	
		SELECT {+INDEX( bdicheq:"informix".sc_movhis idx_movhisnew4 )} b.remesadora,b.referencia1,b.fecha_pago,trim(b.domicilio),trim(b.estado)
		INTO cRemesadoramovbts,cRemesamovbts,dFechamovbts,cDomiciliomovbts,Cestadomovbts
		FROM bdicheq:sc_movhis a INNER JOIN tmp_sac_movimientoshistorialbts b ON a.folio_suc = b.folio_suc
		WHERE a.cancelad  <> 'S' AND a.transacc IN ('1110','1140') AND a.usuario <> 'sysbts' AND a.sucursal <> '9250' AND a.fech_alt BETWEEN '03012017' AND '05312017' AND a.empresa = '001'
	LET iContador_mov = iContador_mov + 1;		
		LET cStmt2 =  trim(cRemesadoramovbts)||','||trim(cRemesamovbts)||','||dFechamovbts||','||trim(NVL(cDomiciliomovbts,''))||','||trim(NVL(Cestadomovbts,''));
		INSERT INTO sac_paso_repremesadoras (linea)
		VALUES(cStmt2);
	IF iContador_mov = 1000 THEN 
		COMMIT;
		LET iContador_mov = 0;
		BEGIN WORK;	
	END IF;			
	END FOREACH;
	COMMIT;		
		
		LET cRemesamovbts	    = '';
		LET cDomiciliomovbts	= '';	
		LET Cestadomovbts	    = '';
		LET cRemesadoramovbts   = '';
		LET dFechamovbts	    = '';
		
		LET cStmt2 				= '';			
		
		
	------------------------sc_movhis_old--------------------------------------------------	
	BEGIN WORK;	
	FOREACH WITH HOLD	
		SELECT {+INDEX( bdicheq:"informix".sc_movhis_old movhis1 )} b.remesadora,b.referencia1,b.fecha_pago,trim(b.domicilio),trim(b.estado)
		INTO cRemesadoramovbts,cRemesamovbts,dFechamovbts,cDomiciliomovbts,Cestadomovbts
		FROM bdicheq:sc_movhis_old a INNER JOIN tmp_sac_movimientoshistorialbts b ON a.folio_suc = b.folio_suc
		WHERE a.cancelad  <> 'S' AND a.transacc IN ('1110','1140') AND a.usuario <> 'sysbts' AND a.sucursal <> '9250' AND a.fech_alt BETWEEN '03012017' AND '05312017' AND a.empresa = '001'
	LET iContador_mov_old = iContador_mov_old + 1;		
		LET cStmt2 =  trim(cRemesadoramovbts)||','||trim(cRemesamovbts)||','||dFechamovbts||','||trim(NVL(cDomiciliomovbts,''))||','||trim(NVL(Cestadomovbts,''));
		INSERT INTO sac_paso_repremesadoras (linea)
		VALUES(cStmt2);
	IF iContador_mov_old = 1000 THEN
		COMMIT;
		LET iContador_mov_old = 0;
		BEGIN WORK;	
	END IF;		
	END FOREACH;
	COMMIT;

	LET cRutaArchivo = '/RESPALDOS/';
	LET cNombreArchivo = 'Reporte_de_remesadoras_bts'||'.csv';
	
	LET cSQL1 = 'echo "UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNombreArchivo)||' delimiter '||' SELECT linea FROM bdisac	:"informix".sac_paso_repremesadoras ORDER BY secuencial" >'||TRIM(cRutaArchivo)||'Ejecuta_archivo_remesas.sql';
	SYSTEM cSQL1;

	LET cSQL='dbaccess bdisac '||TRIM(cRutaArchivo)||'Ejecuta_archivo_remesas.sql';
	SYSTEM cSQL;	
	
		DROP TABLE tmp_bts_rowid;
		DROP TABLE tmp_sac_bts_qryi;
		DROP TABLE tmp_sac_bts_payi;
		DROP TABLE tmp_sac_movimientoshistorialbts;
	
	RETURN vsCodRetorno, vsMensaje;
	
	
END;
END PROCEDURE;
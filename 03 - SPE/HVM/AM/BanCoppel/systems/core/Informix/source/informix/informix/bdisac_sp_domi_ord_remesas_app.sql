CREATE PROCEDURE "informix".sp_domi_ord_remesas_app()
RETURNING VARCHAR(5) AS vsCodRetorno, 
		  VARCHAR(200) AS vsMensaje;
		  
DEFINE viSqlError 		  INTEGER;
DEFINE vsCodRetorno       VARCHAR (5);
DEFINE vsMensaje          VARCHAR (200);

DEFINE iContador_movim		INTEGER;  
DEFINE iContador_mov		INTEGER;  
DEFINE iContador_movold		INTEGER;  
		  
DEFINE cRemesadoraapp		  CHAR (20);
DEFINE cRemesamovimapp		  CHAR (20);
DEFINE dFechamovimapp		  DATE;
DEFINE cFoliomovimapp	      CHAR (16);
DEFINE cDomiciliomovimapp	  CHAR (100);	
DEFINE Cestadomovimapp		  CHAR (40);


DEFINE cRemesadoramovapp	  CHAR (20);
DEFINE cRemesamovapp		  CHAR (20);
DEFINE dFechamovapp			  DATE;
DEFINE cDomiciliomovapp		  CHAR (100);
DEFINE Cestadomovapp		  CHAR (40);

DEFINE cStmt1			  CHAR(200);
DEFINE cStmt2			  CHAR(200);

DEFINE cSQL1			  	  CHAR(500);
DEFINE cSQL				  	  CHAR(500);

DEFINE cNombreArchivo 	  	  CHAR(100);
DEFINE cRutaArchivo 	 	  CHAR(100);

LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET vsMensaje = 'PROCESO EXITOSO';

LET iContador_movim		 = '';  
LET iContador_mov		 = '';  
LET iContador_movold	 = ''; 

LET cRemesadoraapp	    = '';
LET cRemesamovimapp		= '';
LET dFechamovimapp		= '';
LET cFoliomovimapp	    = '';
LET cDomiciliomovimapp	= '';	
LET Cestadomovimapp		= '';


LET cRemesadoramovapp	= '';
LET cRemesamovapp		= '';
LET dFechamovapp		= '';
LET cDomiciliomovapp	= '';
LET Cestadomovapp		= '';



--SET DEBUG FILE TO "/tmp/ALAN/remesas/sp_domi_ord_remesas_app.out";
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
	
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_app_rowid') THEN
		DROP TABLE tmp_app_rowid;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_app_qryi') THEN
		DROP TABLE tmp_sac_app_qryi;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_app_payi') THEN
		DROP TABLE tmp_sac_app_payi;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sac_movimientoshistorialapp') THEN
		DROP TABLE tmp_sac_movimientoshistorialapp;
		END IF;		
		
	    SET ISOLATION TO DIRTY READ;
		
		------------------------APPRIZA--------------------------------------------------	
	
	------------------------sac_app_qryi--------------------------------------------------	
	
		SELECT{+INDEX( bdisac:"informix".sac_app_qryi idx_sac_app_qryi_rcode_fech )} MAX(rowid) AS id, unirefnum
		FROM sac_app_qryi WHERE fecha BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND txn_status = 'A' AND r_operacion = '00000' AND r_code = '0000'
		GROUP BY 2
		INTO TEMP tmp_app_rowid WITH NO LOG;	
	
	    SELECT{+INDEX( bdisac:"informix".sac_app_qryi idx_sac_app_qryi_rcode_fech )} a.unirefnum,trim(NVL(r_address_b,''))||' '||trim(NVL(r_zipcode_b,'')) AS domicilio,trim(NVL(r_statecode_b,'')) AS estado
		FROM sac_app_qryi a INNER JOIN tmp_app_rowid b ON a.rowid = b.id AND a.unirefnum = b.unirefnum  WHERE a.fecha BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND a.txn_status = 'A' AND a.r_operacion = '00000' AND a.r_code = '0000'
		INTO TEMP tmp_sac_app_qryi WITH NO LOG;
		
		
	------------------------sac_app_payi--------------------------------------------------
	
		SELECT{+INDEX( bdisac:"informix".sac_app_payi idx_sac_app_payi_old_rcode_fech )} a.unirefnum,b.domicilio,b.estado,a.refnum
		FROM sac_app_payi a INNER JOIN tmp_sac_app_qryi b ON a.unirefnum = b.unirefnum
		WHERE a.fecha BETWEEN EXTEND(MDY(3,1,2017), YEAR to SECOND)+0 UNITS HOUR+01 UNITS MINUTE AND EXTEND(MDY(5,31,2017), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE AND a.txn_status = 'A' AND a.r_operacion = '00000' AND a.r_code = '0000'
		INTO TEMP tmp_sac_app_payi WITH NO LOG;


		
	------------------------sac_movimientoshistorial--------------------------------------------------

		SELECT{+INDEX( bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe )} (CASE WHEN numcategoria = '07' AND numconvenio = '009' THEN 'APPRIZA'END)AS remesadora,a.referencia1,a.fecha_pago,a.folio_suc,b.domicilio,b.estado
		FROM sac_movimientoshistorial a INNER JOIN tmp_sac_app_payi b ON a.referencia1 = b.unirefnum AND a.folio_suc = b.refnum WHERE a.status_cancelado <> 'S' AND a.fecha_pago BETWEEN '03012017' AND '05312017' AND a.numcategoria = '07' AND a.numconvenio = '009'
		INTO TEMP tmp_sac_movimientoshistorialapp WITH NO LOG;

	------------------------sac_movimientoshistorial_old--------------------------------------------------	
	BEGIN WORK;		
	FOREACH	WITH HOLD
		SELECT{+INDEX( bdisac:"informix".sac_movimientoshistorial_old idxsac_movhis234_old )} (CASE WHEN numcategoria = '07' AND numconvenio = '009' THEN 'APPRIZA'END)AS remesadora,a.referencia1,a.fecha_pago,a.folio_suc,b.domicilio,b.estado
		INTO cRemesadoraapp,cRemesamovimapp,dFechamovimapp,cFoliomovimapp,cDomiciliomovimapp,Cestadomovimapp
		FROM sac_movimientoshistorial_old a INNER JOIN tmp_sac_app_payi b ON a.referencia1 = b.unirefnum AND a.folio_suc = b.refnum WHERE a.status_cancelado <> 'S' AND a.fecha_pago BETWEEN '03012017' AND '05312017' AND a.numcategoria = '07' AND a.numconvenio = '009'
	LET iContador_movim = iContador_movim + 1; 
		INSERT INTO tmp_sac_movimientoshistorialapp VALUES (cRemesadoraapp,cRemesamovimapp,dFechamovimapp,cFoliomovimapp,cDomiciliomovimapp,Cestadomovimapp);
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
		SELECT{+INDEX( bdicheq:"informix".sc_movhis idx_movhisnew4 )} b.remesadora,b.referencia1,b.fecha_pago,trim(b.domicilio),trim(b.estado)
		INTO cRemesadoramovapp,cRemesamovapp,dFechamovapp,cDomiciliomovapp,Cestadomovapp
		FROM bdicheq:sc_movhis a INNER JOIN tmp_sac_movimientoshistorialapp b ON a.folio_suc = b.folio_suc
		WHERE a.cancelad  <> 'S' AND a.transacc IN ('1325','1355') AND a.usuario <> 'sys_apz' AND a.sucursal <> '9764' AND a.fech_alt BETWEEN '03012017' AND '05312017' AND a.empresa = '001'
	LET iContador_mov = iContador_mov + 1; 	
		LET cStmt2 =  trim(cRemesadoramovapp)||','||trim(cRemesamovapp)||','||dFechamovapp||','||trim(NVL(cDomiciliomovapp,''))||','||trim(NVL(Cestadomovapp,''));
		INSERT INTO sac_paso_repremesadoras (linea)
		VALUES(cStmt2);
	IF 	iContador_mov = 1000 THEN 
		COMMIT;
		LET iContador_mov = 0;
		BEGIN WORK;
	END IF;			
	END FOREACH;
	COMMIT;	
		
		LET cRemesadoramovapp	    = '';
		LET cRemesamovapp			= '';	
		LET dFechamovapp	    	= '';
		LET cDomiciliomovapp   		= '';
		LET Cestadomovapp	   		= '';
		
		LET cStmt2					= '';
		
		
	------------------------sc_movhis_old--------------------------------------------------	
	BEGIN WORK;
	FOREACH	 WITH HOLD
		SELECT {+INDEX( bdicheq:"informix".sc_movhis_old movhis1 )} b.remesadora,b.referencia1,b.fecha_pago,trim(b.domicilio),trim(b.estado)
		INTO cRemesadoramovapp,cRemesamovapp,dFechamovapp,cDomiciliomovapp,Cestadomovapp
		FROM bdicheq:sc_movhis_old a INNER JOIN tmp_sac_movimientoshistorialapp b ON a.folio_suc = b.folio_suc
		WHERE a.cancelad  <> 'S' AND a.transacc IN ('1325','1355') AND a.usuario <> 'sys_apz' AND a.sucursal <> '9764' AND a.fech_alt BETWEEN '03012017' AND '05312017' AND a.empresa = '001'
	LET iContador_movold = iContador_movold + 1; 		
		LET cStmt2 =  trim(cRemesadoramovapp)||','||trim(cRemesamovapp)||','||dFechamovapp||','||trim(NVL(cDomiciliomovapp,''))||','||trim(NVL(Cestadomovapp,''));
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
	LET cNombreArchivo = 'Reporte_de_remesadoras_app'||'.csv';
	
	LET cSQL1 = 'echo "UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNombreArchivo)||' delimiter '||' SELECT linea FROM bdisac	:"informix".sac_paso_repremesadoras ORDER BY secuencial" >'||TRIM(cRutaArchivo)||'Ejecuta_archivo_remesas.sql';
	SYSTEM cSQL1;

	LET cSQL='dbaccess bdisac '||TRIM(cRutaArchivo)||'Ejecuta_archivo_remesas.sql';
	SYSTEM cSQL;
	
		DROP TABLE tmp_app_rowid;
		DROP TABLE tmp_sac_app_qryi;
		DROP TABLE tmp_sac_app_payi;
		DROP TABLE tmp_sac_movimientoshistorialapp;
	
	RETURN vsCodRetorno, vsMensaje;
	
	
END;
END PROCEDURE;
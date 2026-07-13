CREATE PROCEDURE "informix".sp_tef_generareplistnegra()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cStmt				CHAR(1000);
DEFINE dFecha_Ayer			DATE;
DEFINE cRutaArchDet			CHAR(100);
DEFINE cNombreArch          CHAR(30);
DEFINE cFecha_presentacion  CHAR(8);
DEFINE cTipo_registro       CHAR(4);
DEFINE cNum_secuencia       CHAR(7);
DEFINE vCod_operacion       CHAR(2);
DEFINE vCod_divisa          CHAR(2);
DEFINE cFecha_trans         CHAR(8);
DEFINE cBanco_presentador   CHAR(45);
DEFINE cBanco_receptor      CHAR(45);
DEFINE cImporte             CHAR(15);
DEFINE cUso_futuro_ccen     CHAR(16);
DEFINE cTipo_operacion      CHAR(2);
DEFINE cFecha_aplica        CHAR(8);
DEFINE cTipo_cta_ord        CHAR(2);
DEFINE cNum_cta_ord         CHAR(20);
DEFINE cNombre_ord          CHAR(40);
DEFINE cRfc_ord             CHAR(20);
DEFINE cTipo_cta_rec        CHAR(2);
DEFINE cNum_cta_rec         CHAR(20);
DEFINE cNombre_rec          CHAR(40);
DEFINE cRfc_rec             CHAR(18);
DEFINE cRef_servicio        CHAR(40);
DEFINE cNombre_titular_serv CHAR(40);
DEFINE cImporte_iva         CHAR(15);
DEFINE cRef_numerica        CHAR(7);
DEFINE cRef_leyenda         CHAR(40);
DEFINE vClave_rastreo       CHAR(40);
DEFINE cMotivo_dev          CHAR(40);
DEFINE cFecha_pres_ini      CHAR(8);
DEFINE cSol_confirmacion    CHAR(1);
DEFINE cUso_futuro_banco    CHAR(11);
DEFINE cRef_confirmacion    CHAR(30);
DEFINE cUso_futuro_cce      CHAR(1);
DEFINE cTasa_tiie_prom      CHAR(7);
DEFINE cDias_retraso        CHAR(3);
DEFINE cImp_tot_int         CHAR(15);
DEFINE vCve_status          CHAR(40);
DEFINE cFolio_suc           CHAR(20);
DEFINE cUser_insert         CHAR(8);
DEFINE cFecha_insert        CHAR(10);
DEFINE cTipo_cta            CHAR(20);
DEFINE iCuantos             INTEGER;
DEFINE cRutaArchivos        CHAR(50);
DEFINE vNombreArch          CHAR(30);
DEFINE vFechaPresentacion   CHAR(8);





--INICIALIZACION DE VARIABLES--
LET cCodRet				 = "00000";
LET cMensaje			 = 'PROCESO EXITOSO';
LET iSqlErr				 = 0;
LET cStmt				 = '';
LET dFecha_Ayer			 = DATE(1);
LET cNombreArch          = '';
LET cFecha_presentacion  = '';
LET cTipo_registro       = '';
LET cNum_secuencia       = '';
LET vCod_operacion       = '';
LET vCod_divisa          = '';
LET cFecha_trans         = '';
LET cBanco_presentador   = '';
LET cBanco_receptor      = '';
LET cImporte             = '';
LET cUso_futuro_ccen     = '';
LET cTipo_operacion      = '';
LET cFecha_aplica        = '';
LET cTipo_cta_ord        = '';
LET cNum_cta_ord         = '';
LET cNombre_ord          = '';
LET cRfc_ord             = '';
LET cTipo_cta_rec        = '';
LET cNum_cta_rec         = '';
LET cNombre_rec          = '';
LET cRfc_rec             = '';
LET cRef_servicio        = '';
LET cNombre_titular_serv = '';
LET cImporte_iva         = '';
LET cRef_numerica        = '';
LET cRef_leyenda         = '';
LET vClave_rastreo       = '';
LET cMotivo_dev          = '';
LET cFecha_pres_ini      = '';
LET cSol_confirmacion    = '';
LET cUso_futuro_banco    = '';
LET cRef_confirmacion    = '';
LET cUso_futuro_cce      = '';
LET cTasa_tiie_prom      = '';
LET cDias_retraso        = '';
LET cImp_tot_int         = '';
LET vCve_status          = '';
LET cFolio_suc           = '';
LET cUser_insert         = '';
LET cFecha_insert        = '';
LET cTipo_cta            = '';
LET iCuantos             = 0;
LET cRutaArchivos        = '';
LET vNombreArch          = '';
LET vFechaPresentacion   = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO  '/RESPALDOSNEW/depuraremesas/sp_generaarchivocobranzaservcpl.out';
	    --TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;	

		SELECT FIRST 1 Valor INTO cRutaArchivos FROM BdiTef:Tef_Parametros WHERE cod_param = '72';	
		
		SELECT MAX(fecha_insert) INTO dFecha_Ayer FROM bditef:tef_cce_archivos 
		WHERE nombre_arch LIKE '%S01137A2.A60%';
		 
		LET cRutaArchDet  =  TRIM(cRutaArchivos) || '/Reporte_tef_' || LPAD(DAY (dFecha_Ayer),2,'0') || LPAD(MONTH (dFecha_Ayer),2,'0') || YEAR(dFecha_Ayer)  || '.csv';
		
		LET vNombreArch = 'S01137A2.A60'|| LPAD(DAY(dFecha_Ayer),2,'0') || '98';
		LET vFechaPresentacion = YEAR(dFecha_Ayer)  || LPAD(MONTH (dFecha_Ayer),2,'0') || LPAD(DAY (dFecha_Ayer),2,'0');
		
		
		SELECT COUNT(*) INTO iCuantos FROM bditef:tef_cce_detalle a WHERE a.nombre_arch = TRIM(vNombreArch) AND a.fecha_presentacion = TRIM(vFechaPresentacion) AND a.cod_operacion='60';
				
		IF iCuantos	> 0 THEN
				
				LET cStmt =   'echo "' || TRIM('NOMBRE ARCHIVO') || ',' || TRIM('FECHA PRESENTACION') || ',' || TRIM('TIPO REGISTRO') || ',' || TRIM('NUMERO SECUENCIA') || ',' || TRIM('CODIGO OPERACION') || 
				',' || TRIM('DIVISA') || ',' || TRIM('FECHA TRANS') || ',' || TRIM('BANCO PRESENTADOR') || ',' || TRIM('BANCO RECEPTOR') || ',' || TRIM('IMPORTE') || ',' || TRIM('CAMPO USO FUTURO') || 
				',' || TRIM('TIPO OPERACION') || ',' || TRIM('FECHA APLICA') || ',' || TRIM('TIPO CTA ORD') || ',' || TRIM('NUM CTA ORD') || ',' || TRIM('NOMBRE ORD') || ',' || TRIM('RFC ORD') || 
				',' || TRIM('TIPO CTA REC') || ',' || TRIM('NUM CTA REC') || ',' || TRIM('NOMBRE REC') || ',' || TRIM('RFC REC') || ',' || TRIM('REF SERVICIO') || ',' || TRIM('NOMBRE TITULAR SERV') ||
				',' || TRIM('IMPORTE IVA') || ',' || TRIM('REF NUMERICA') || ',' || TRIM('REF LEYENDA') || ',' || TRIM('CLAVE RASTREO') || ',' || TRIM('MOTIVO DEVOLUCION') || ',' || TRIM('FECHA PRES INI') ||
				',' || TRIM('SOLICITUD CONFIRMACION') || ',' || TRIM('CAMPO USO FUTURO') || ',' || TRIM('TASA TIIE PROM') || ',' || TRIM('DIAS RETRASO') || ',' || TRIM('IMP TOT IN') ||
				',' || TRIM('ESTATUS') || ',' || TRIM('FOLIO SUC') || ',' || TRIM('USER INSERT') || ',' || TRIM('FECHA OPERACION') || ',' || TRIM('TIPO CTA') ||'" >> ' || cRutaArchDet;
				SYSTEM cStmt;
				FOREACH
					select a.nombre_arch,a.fecha_presentacion,a.tipo_registro as prueba,a.num_secuencia,a.cod_operacion,a.cod_divisa,a.fecha_trans,     
					b.descripcion,c.descripcion,a.importe / 100,a.uso_futuro_ccen,a.tipo_operacion,a.fecha_aplica,a.tipo_cta_ord,     
					a.num_cta_ord,a.nombre_ord,a.rfc_ord,a.tipo_cta_rec,a.num_cta_rec,a.nombre_rec,a.rfc_rec,a.ref_servicio,a.nombre_titular_serv,a.importe_iva,a.ref_numerica,     
					a.ref_leyenda,a.clave_rastreo,e.descripcion,a.fecha_pres_ini,a.solicitud_confirmacion,a.uso_futuro_banco,a.ref_confirmacion,a.uso_futuro_cce,     
					a.tasa_tiie_prom,a.dias_retraso,a.imp_tot_int,d.descripcion,a.folio_suc,a.user_insert,a.fecha_insert,a.tipo_cta
					INTO cNombreArch,cFecha_presentacion,cTipo_registro,cNum_secuencia,vCod_operacion,vCod_divisa,cFecha_trans,cBanco_presentador,cBanco_receptor,cImporte,
					cUso_futuro_ccen,cTipo_operacion,cFecha_aplica,cTipo_cta_ord,cNum_cta_ord,cNombre_ord,cRfc_ord,cTipo_cta_rec,cNum_cta_rec,cNombre_rec,
					cRfc_rec,cRef_servicio,cNombre_titular_serv,cImporte_iva,cRef_numerica,cRef_leyenda,vClave_rastreo,cMotivo_dev,cFecha_pres_ini,cSol_confirmacion,
					cUso_futuro_banco,cRef_confirmacion,cUso_futuro_cce,cTasa_tiie_prom,cDias_retraso,cImp_tot_int,vCve_status,cFolio_suc,cUser_insert,cFecha_insert,cTipo_cta   	
					from bditef:tef_cce_detalle a, bdinteg:si_bancos b, bdinteg:si_bancos c,bditef:tef_status_pago d,bditef:tef_cat_devoluciones e
					where a.nombre_arch = TRIM(vNombreArch)
					and a.fecha_presentacion = TRIM(vFechaPresentacion)
					and a.cod_operacion='60'
					and b.banco=a.banco_presentador
					and c.banco=a.banco_receptor
					and d.cve_status=a.cve_status
					and e.motivo_dev=a.motivo_dev
					order by 4 asc
					
					LET cStmt = 'echo "' || TRIM(NVL(replace(cNombreArch,',',''),'')) || ',' || TRIM(NVL(replace(cFecha_presentacion,',',''),'')) || ',' || TO_CHAR(replace(cTipo_registro,',','')) || ',' || TRIM(NVL(replace(cNum_secuencia,',',''),'')) || 
					',' || TRIM(NVL(replace(vCod_operacion,',',''),''))   || ',' || TRIM(NVL(replace(vCod_divisa,',',''),''))       || ',' || TRIM(NVL(replace(cFecha_trans,',',''),''))       || ',' || TRIM(NVL(replace(cBanco_presentador,',',''),''))  || ',' || TRIM(NVL(replace(cBanco_receptor,',',''),'')) ||
					',' || TRIM(NVL(replace(cImporte,',',''),''))         || ',' || TRIM(NVL(replace(cUso_futuro_ccen,',',''),''))  || ',' || TRIM(NVL(replace(cTipo_operacion,',',''),''))    || ',' || TRIM(NVL(replace(cFecha_aplica,',',''),''))       || ',' || TRIM(NVL(replace(cTipo_cta_ord,',',''),''))   || 
					',' || TRIM(NVL(replace(cNum_cta_ord,',',''),''))     || ',' || TRIM(NVL(replace(cNombre_ord,',',''),''))       || ',' || TRIM(NVL(replace(cRfc_ord,',',''),''))           || ',' || TRIM(NVL(replace(cTipo_cta_rec,',',''),''))       || ',' || TRIM(NVL(replace(cNum_cta_rec,',',''),''))    || 
					',' || TRIM(NVL(replace(cNombre_rec,',',''),''))      || ',' || TRIM(NVL(replace(cRfc_rec,',',''),''))          || ',' || TRIM(NVL(replace(cRef_servicio,',',''),''))      || ',' || TRIM(NVL(replace(cNombre_titular_serv,',',''),''))|| ',' || TRIM(NVL(replace(cImporte_iva,',',''),''))    || 
					',' || TRIM(NVL(replace(cRef_numerica,',',''),''))    || ',' || TRIM(NVL(replace(cRef_leyenda,',',''),''))      || ',' || TRIM(NVL(replace(vClave_rastreo,',',''),''))     || ',' || TRIM(NVL(replace(cMotivo_dev,',',''),''))         || ',' || TRIM(NVL(replace(cFecha_pres_ini,',',''),'')) || 
					',' || TRIM(NVL(replace(cSol_confirmacion,',',''),''))|| ',' || TRIM(NVL(replace(cUso_futuro_cce,',',''),''))   || ',' || TRIM(NVL(replace(cTasa_tiie_prom,',',''),''))    || ',' || TRIM(NVL(replace(cDias_retraso,',',''),''))       || ',' || TRIM(NVL(replace(cImp_tot_int,',',''),''))    || 
					',' || TRIM(NVL(replace(vCve_status,',',''),''))      || ',' || TRIM(NVL(replace(cFolio_suc,',',''),''))        || ',' || TRIM(NVL(replace(cUser_insert,',',''),''))       || ',' || TRIM(NVL(replace(cFecha_insert,',',''),''))       || ',' || TRIM(NVL(replace(cTipo_cta,',',''),''))       ||'" >> ' || cRutaArchDet;
					SYSTEM cStmt;
				
				END FOREACH;
					
		ELSE		
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo " 0 " >> ' || cRutaArchDet;
			SYSTEM cStmt;			
		END IF;			
				
		RETURN cCodRet, cMensaje;
	END;	
END PROCEDURE;
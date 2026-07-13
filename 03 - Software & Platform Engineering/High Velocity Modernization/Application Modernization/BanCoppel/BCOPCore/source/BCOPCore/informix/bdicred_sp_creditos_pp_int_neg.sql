CREATE PROCEDURE "informix".sp_creditos_pp_int_neg(pEmpresa VARCHAR(3))
									
RETURNING CHAR(6);

---DECLARACION DE VARIABLES
DEFINE iSqlErr 				INTEGER;
DEFINE isam_err 			INTEGER;
DEFINE error_info 			CHAR(80);
DEFINE cProceso         	CHAR(4);
DEFINE cCod_retBit      	CHAR(6);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeErr			CHAR(60);

DEFINE dFechaHoy			DATE;
DEFINE cNum_Credito			CHAR(20);
DEFINE cStatusCred			CHAR(2);
DEFINE iContador			INTEGER;
DEFINE cProducto			CHAR(4);
DEFINE cSucursal			CHAR(4);
DEFINE iTablaExiste 		INTEGER;

DEFINE d_sdo_retenido		DECIMAL(18,2);
DEFINE d_sdo_capital		DECIMAL(18,2);
DEFINE d_sdo_cap_insoluto	DECIMAL(18,2);
DEFINE d_sdo_no_exig		DECIMAL(18,2);
DEFINE d_int_tra_no_exig	DECIMAL(18,2);
DEFINE d_mto_venc_int		DECIMAL(18,2);
DEFINE d_mto_finan_vdo		DECIMAL(18,2);
DEFINE d_monto_nvo_ret 		DECIMAL(18,2);
DEFINE d_monto_int_nvo 		DECIMAL(18,2);
DEFINE d_monto_iva_nvo		DECIMAL(18,2);
DEFINE cFolio         		CHAR(16);

DEFINE cNom_Archivo			CHAR(50);
DEFINE cNom_Archivo_aux		CHAR(50);
DEFINE cRuta            	CHAR(100);
DEFINE cSQL             	CHAR(8204);
DEFINE cSQL1            	CHAR(6204);
DEFINE cSQL2            	CHAR(6204);
DEFINE cSQL3            	CHAR(100);



--SET DEBUG FILE TO "/informix/mahr/sp_creditos_pp_int_neg.out";
--TRACE ON;


---INICIALIZACION DE VARIABLES
LET iSqlErr 			= 0;
LET isam_err 			= 0;
LET error_info 			= '';
LET cProceso			= '0115';
LET cCod_retBit			= '000000';
LET cCodRet  			= '000000';
LET cMensajeErr			= '';

LET dFechaHoy			= date(1);
LET cNum_Credito		= '';
LET cStatusCred			= '';
LET iContador			= 0;
LET cProducto			= '';
LET cSucursal			= '';
LET iTablaExiste		= 0;

LET d_sdo_retenido		= 0;
LET d_sdo_capital		= 0;
LET d_sdo_cap_insoluto	= 0;
LET d_sdo_no_exig		= 0;
LET d_int_tra_no_exig	= 0;
LET d_mto_venc_int		= 0;
LET d_mto_finan_vdo		= 0;
LET d_monto_nvo_ret		= 0;
LET d_monto_int_nvo 	= 0;
LET d_monto_iva_nvo		= 0;
LET cFolio				= '';

LET cNom_Archivo		= '';
LET cNom_Archivo_aux    = '';
LET cRuta				= '';
LET cSQL             	= '';
LET cSQL1            	= '';
LET cSQL2            	= '';
LET cSQL3            	= '';


BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET cCodRet = iSqlErr;
	CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, "Error-"||isam_err||"-"||trim(error_info)||"-"||cNum_Credito, '02') Returning cCod_retBit;
	
	IF iTablaExiste = 1 THEN
		DROP TABLE bdicred:tmp_creditos_corregidos;
	END IF;
	
	RETURN cCodRet;
END EXCEPTION;

	-- Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Valida los datos de entrada
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet;
	END IF;

	-- Obtiene fecha 
	SELECT fecha_hoy, USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2) ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2) ||SUBSTR(CURRENT,18,2)
	  INTO dFechaHoy, cFolio
	  FROM bdicred:"informix".sd_fechas WHERE empresa = '001'; 

 	
	Create table bdicred:tmp_creditos_corregidos
	(
		num_credito 	CHAR(20),
		status_cred     CHAR(2),
		sdo_no_exig		DECIMAL(18,2),
		int_tra_no_exig DECIMAL(18,2),	
		mto_venc_int	DECIMAL(18,2),	
		mto_finan_vdo	DECIMAL(18,2)
	);
	LET iTablaExiste = 1;

	
	FOREACH WITH HOLD
		SELECT c.num_credito, c.status_cred, sdo_retenido  , sdo_capital  , sdo_cap_insoluto  , sdo_no_exig  , int_tra_no_exig  , mto_venc_int  , mto_finan_vdo  , c.sucursal
		  INTO cNum_Credito , cStatusCred  , d_sdo_retenido, d_sdo_capital, d_sdo_cap_insoluto, d_sdo_no_exig, d_int_tra_no_exig, d_mto_venc_int, d_mto_finan_vdo, cSucursal	
          FROM bdicred:sd_maesdoscrd d
          JOIN bdicred:sd_maecredcrd c on (d.num_credito = c.num_credito )
         WHERE sdo_cap_insoluto > 0 and (sdo_no_exig < 0 or int_tra_no_exig < 0 or mto_venc_int < 0 or mto_finan_vdo < 0)
		   AND  c.status_cred in ('AA','BA','BT')
           AND c.num_credito in ('770002818589','760005017958','760004988514','760005004675','760005020556','760005005599','770001923612','770002690970')


		LET d_monto_nvo_ret = 0;
		LET d_monto_int_nvo = 0;
		LET d_monto_iva_nvo = 0;
		
		IF d_sdo_no_exig < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_sdo_no_exig * -1);
			LET d_monto_int_nvo = d_monto_int_nvo + (d_sdo_no_exig * -1);
		END IF;
		IF d_mto_finan_vdo < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_mto_finan_vdo * -1);
			LET d_monto_iva_nvo = d_monto_iva_nvo + (d_mto_finan_vdo * -1);
		END IF;

		IF d_int_tra_no_exig < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_int_tra_no_exig * -1);
			LET d_monto_int_nvo = d_monto_int_nvo + (d_int_tra_no_exig * -1);
		END IF;
		IF d_mto_venc_int < 0 THEN
			LET d_monto_nvo_ret = d_monto_nvo_ret + (d_mto_venc_int * -1);
			LET d_monto_iva_nvo = d_monto_iva_nvo + (d_mto_venc_int * -1);
		END IF;
		
		-- INTERES
		SELECT count(*) INTO iContador FROM bdicred:sd_maeretenido WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8374');
		IF iContador > 0 THEN
		
			UPDATE bdicred:"informix".sd_maeretenido SET monto = monto + d_monto_int_nvo, estatus = 'R'
			 WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8374');
		
		ELSE
			INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
				VALUES('001',cNum_Credito,cFolio,dFechaHoy,CURRENT HOUR TO FRACTION(3),'8374',0,d_monto_int_nvo,user,'R','INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);
		END IF;
		
		-- IVA INTERES
		SELECT count(*) INTO iContador FROM bdicred:sd_maeretenido WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8375');
		IF iContador > 0 THEN
		
			UPDATE bdicred:"informix".sd_maeretenido SET monto = monto + d_monto_iva_nvo, estatus = 'R'
			 WHERE empresa = '001' AND num_credito = cNum_Credito AND transacc in ('8375');
		
		ELSE
			INSERT INTO bdicred:"informix".sd_maeretenido(empresa,num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
				VALUES('001',cNum_Credito,cFolio,dFechaHoy,CURRENT HOUR TO FRACTION(3),'8375',0,d_monto_iva_nvo,user,'R','IVA INTERES DIFERIDO PROGRAMA APOYO PP',cSucursal,0);						
		END IF;		
		

		-- Actualiza sdo retenido en la maesdos y limpia dato negativo.
		IF d_sdo_no_exig < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_sdo_no_exig * -1), sdo_no_exig = 0
			 WHERE num_credito = cNum_Credito;
		END IF;
		IF d_mto_finan_vdo < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_mto_finan_vdo * -1), mto_finan_vdo = 0
			 WHERE num_credito = cNum_Credito;
		END IF;

		IF d_int_tra_no_exig < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_int_tra_no_exig * -1), int_tra_no_exig = 0
			 WHERE num_credito = cNum_Credito;
		END IF;
		IF d_mto_venc_int < 0 THEN
			UPDATE bdicred:sd_maesdoscrd SET sdo_retenido = sdo_retenido + (d_mto_venc_int * -1), mto_venc_int = 0
			 WHERE num_credito = cNum_Credito;		
		END IF;
		
		
		Insert into bdicred:tmp_creditos_corregidos values (cNum_Credito, cStatusCred, d_sdo_no_exig, d_int_tra_no_exig, d_mto_venc_int, d_mto_finan_vdo);
 

	END FOREACH;

	-------
	
	SELECT count(*) INTO iContador FROM bdicred:tmp_creditos_corregidos;
	
	IF iContador > 0 THEN
	
		-- Genera archivo con informacion de creditos con lineas de credito reducidas.	
		LET cNom_Archivo_aux =  TRIM("Archivos_PP_Int_Beg_Corr_")||'Aux'||to_char(dFechaHoy,'%d%m%Y')||'.txt';
		LET cNom_Archivo =  TRIM("Archivos_PP_Int_Beg_Corr_")||to_char(dFechaHoy,'%d%m%Y')||'.txt';	
		LET cRuta = '/resplogifx/archivoscartera/';
		
		LET cSQL = '';
		LET cSQL = 'echo "num_credito'||'|'||'status_cred'||'|'||'sdo_no_exig'||'|'||'int_tra_no_exig'||'|'||'mto_venc_int'||'|'||'mto_finan_vdo'|| ' " >' || TRIM(cRuta) || cNom_Archivo;
		System cSQL;	

		
		LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNom_Archivo_aux); 
		LET cSQL2 = " SELECT * FROM bdicred:tmp_creditos_corregidos";
					
			
		LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_rep_pp_corr.sql';

		LET cSQL = trim(cSQL1) || rtrim(cSQL2) || trim(cSQL3);
		SYSTEM cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_rep_pp_corr.sql';
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_rep_pp_corr.sql';
		SYSTEM cSQL;

		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cNom_Archivo_aux || " >> " || TRIM(cRuta) || cNom_Archivo;
		SYSTEM cSql;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_rep_pp_corr.sql';
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || cNom_Archivo_aux;
		SYSTEM cSQL;	
					
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cNom_Archivo;
		System cSQL;				

	END IF;
		
	-------

	IF iTablaExiste = 1 THEN
		DROP TABLE bdicred:tmp_creditos_corregidos;
	END IF;
	LET iTablaExiste = 0;
				

	RETURN cCodRet;	
	
END
END PROCEDURE
DOCUMENT
'Procedimiento para corregir creditos de PP con inconsistencias en sus saldos: Int e Iva negativos 			';

CREATE PROCEDURE "informix".sp_rep_actreestructura()
RETURNING CHAR(5), CHAR(90);

DEFINE cCodRet				CHAR(5);
DEFINE cMenRet				CHAR(90);
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cEmpresa 			CHAR(3);
DEFINE cArchActReest		CHAR(30);
DEFINE cNumCredito			CHAR(15);
DEFINE cNumCreditoRees		CHAR(15);
DEFINE cProducto			CHAR(4);
DEFINE cProductoRees		CHAR(5);
DEFINE cNumCte				CHAR(15);
DEFINE cCommand				CHAR(1000);
DEFINE cRutaArchivo			CHAR(100);
DEFINE dFechaHoy			DATE;
DEFINE dFechaActReest		DATE;
DEFINE iSqlErr				INTEGER;
DEFINE iPlazo				INTEGER;
DEFINE iCountReg			INTEGER;
DEFINE dcSdoReest			DECIMAL(18,2);
DEFINE cPrimer_dia 		DATE;
DEFINE cUltimo_dia 		DATE;

LET iSqlErr 			= 0;
LET iPlazo				= 0;
LET dcSdoReest			= 0;
LET iCountReg			= 0;
LET cCodRet 			= '00000';
LET cMenRet				= 'PROCESO EXITOSO';
LET cDia				= '';
LET cMes				= '';
LET cAnio				= '';
LET dFechaHoy			= '';
LET dFechaActReest		= '';
LET cArchActReest		= 'ActReestructura_';
LET cRutaArchivo		= '/RESPALDOSNEW/'; --PRODUCCIÃN
--LET cRutaArchivo		= '/RESPALDOSNEW/gpe/'; -- DESARROLLO
LET cNumCredito			= '';
LET cNumCte				= '';
LET cProducto			= '';
LET cNumCreditoRees		= '';
LET cCommand			= '';
LET cPrimer_dia 		= ''; 
LET cUltimo_dia 		= '';
LET cEmpresa 			= '001';


BEGIN
		ON EXCEPTION SET iSqlErr
		
			drop table if exists temp_act_reestructura;
			
			IF iSqlErr = -668 THEN
				LET cCodRet = '00001';
				LET cMenRet = 'Proceso con terminancion -668.';
				
				RETURN cCodRet, cMenRet;
			ELIF iSqlErr != -668 THEN
				LET cCodRet = '00002';
				LET cMenRet = 'Error al ejecutar el proceso ' || iSqlErr;
				
				RETURN cCodRet, cMenRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/gpe/sp_rep_actreestructura.out";
		--TRACE ON;
		
		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy), pri_dia_mes - 1 units month, ult_dia_mes - 1 units month
		INTO dFechaHoy, cDia, cMes, cAnio, cPrimer_dia, cUltimo_dia
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = cEmpresa;
		
		--PARA PRUEBAS
		/*LET dFechaHoy = MDY('03','08','2021');
		LET cDia = DAY(dFechaHoy);
		LET cMes = MONTH(dFechaHoy);
		LET cAnio = YEAR(dFechaHoy);*/
		
		IF MONTH(dFechaHoy) < 10 THEN
			LET cMes = '0' || TRIM(cMes);
		END IF;
		
		IF DAY(dFechaHoy) < 10 THEN
			LET cDia = '0' || TRIM(cDia);
		END IF;
		
		LET cArchActReest = TRIM(cArchActReest) || cDia || cMes || cAnio || '.txt';
		
		--CREACIÃN TABLA TEMPORAL PARA ALMACENAR DATOS DE VALIDACIÃN
		IF NOT EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_act_reestructura' ) THEN
			CREATE TABLE  temp_act_reestructura      	
				(fecha		            DATE,  
				numcte         			CHAR(11),
				num_cred_origen		    CHAR(20),
				producto_origen		    CHAR(4),
				num_cred_rees           CHAR(20),
				producto_rees	        CHAR(5),
				plazo			       	INTEGER,        
				sdo_rees	            DECIMAL(18,2)
			)in dbs_cfd_06 extent size 88904 next size 53342;
		END IF;
		
		FOREACH
			SELECT numcte
			INTO cNumcte
			FROM bdicred:"informix".sd_programacion_reestructuras_aut
			WHERE fecha = dFechaHoy
			
			--NÃMERO DE CRÃDITO Y PRODUCTO ORIGEN
			SELECT num_credito, num_producto
			INTO cNumCredito, cProducto
			FROM bdicred:"informix".sd_maecred 
			WHERE numcte = cNumcte;
			
			SELECT COUNT(a.num_credito)
			INTO iCountReg
			FROM bdicred:"informix".sd_maecredcrd a
			INNER JOIN bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
			WHERE a.numcte = cNumcte AND a.num_producto in ('6011','8600')
			AND a.fecha_apertura between cPrimer_dia AND cUltimo_dia;
			
			IF iCountReg > 0 THEN
				--NÃMERO DE CRÃDITO Y PRODUCTO REESTRUCTURA.
				SELECT a.num_credito, a.num_producto, a.fecha_apertura, a.plazo, b.sdo_cap_insoluto
				INTO cNumCreditoRees, cProductoRees,dFechaActReest,iPlazo,dcSdoReest
				FROM bdicred:"informix".sd_maecredcrd a
				INNER JOIN bdicred:"informix".sd_maesdoscrd b on a.num_credito = b.num_credito
				WHERE a.numcte = cNumcte AND a.num_producto in ('6011','8600')
				AND a.fecha_apertura between cPrimer_dia AND cUltimo_dia;
				
				INSERT INTO temp_act_reestructura VALUES (dFechaActReest, cNumcte, cNumCredito, cProducto, cNumCreditoRees, cProductoRees, iPlazo, dcSdoReest); 
			END IF;
		END FOREACH;
		
		--GENERACIÃN ARCHIVO ActResstructura_DDMMAAAA.txt
		LET cCommand = 'echo "UNLOAD TO ' || TRIM(cRutaArchivo) || 'ActResstructura_' || cDia || cMes || cAnio || "_1.txt DELIMITER " || "'" || '|' || "'" || '" > ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'echo "SELECT * FROM temp_act_reestructura; " >> ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
			
		LET cCommand = 'chmod 777 ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'dbaccess bdicred ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = "sed 's/|$//g' " || TRIM(cRutaArchivo) || 'ActResstructura_' || cDia || cMes || cAnio || '_1.txt > ' || TRIM(cRutaArchivo) || TRIM(cArchActReest);
		SYSTEM TRIM(cCommand);
		
		--ELIMINACIÃN TABLA Y ARCHIVOS
		DROP TABLE temp_act_reestructura;
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'ActResstructura_' || cDia || cMes || cAnio || '_1.txt';
		SYSTEM TRIM(cCommand);
		
		LET cCommand = 'rm ' || TRIM(cRutaArchivo) || 'ejecuta_reporte_ActResstructura.sql;';
		SYSTEM TRIM(cCommand);
		
		EXECUTE PROCEDURE "informix".sp_rep_envioreestructura()
		INTO cCodRet, cMenRet;
		
		RETURN cCodRet, cMenRet;
	END
END PROCEDURE;
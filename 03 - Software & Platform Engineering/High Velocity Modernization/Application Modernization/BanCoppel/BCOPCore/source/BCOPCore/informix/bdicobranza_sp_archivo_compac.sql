CREATE PROCEDURE "informix".sp_archivo_compac(p_FechaIni DATE, p_FechaFin DATE)
RETURNING CHAR(6) AS cCod_Ret, CHAR(6) AS isam_cCodRet, CHAR(80) AS cMensajeRet;
/*______________________________________________________________________________________________________________________________________________________________________________________	
--Modificado por: Abrham Lopez L.
--Fecha: 08/12/2011
--Descripcion:Consulta para sacar convenios que se realizan el dÃ­a de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.
--Base de Datos: BDCOBRANZA
_______________________________________________________________________________________________________________________________________________________________________________________*/
 
 
    DEFINE cCodRet 			CHAR(6);
	DEFINE isam_cCodRet 	CHAR(6);
	DEFINE cMensaje 		CHAR(80);
	DEFINE sql_err 			INTEGER;
	DEFINE isam_err 		INTEGER;
	DEFINE var_rga 			CHAR(05);
	DEFINE cNombreArchivo 	CHAR(100);
	DEFINE cMesAnio 		CHAR(4);
	DEFINE cEmpresa 		CHAR(3);		
	DEFINE cSql 			CHAR(1024);
	DEFINE p_FechaIni1 		DATE;
	DEFINE vRuta            CHAR(50);
	DEFINE vproceso         CHAR(4);
	DEFINE cCodRet_2        CHAR(6);
	
--DeclaraciÃ³n de variables 
DEFINE vFeccom DATE;
DEFINE vOrig SMALLINT;
DEFINE vEfecom INTEGER;
DEFINE vImport INTEGER;
DEFINE vEmp_Cap INTEGER;
DEFINE vSuc_P CHAR(4);
DEFINE vSuc_C CHAR(4);
DEFINE vPlazo CHAR(2);
DEFINE cSql1 CHAR(6204);
DEFINE cSql2 CHAR(6204);	
DEFINE cCod_Ret CHAR(6);
DEFINE vTip_com CHAR(1);
DEFINE vCliente CHAR(20);
DEFINE vNum_Prod CHAR(4);
DEFINE vNum_Tar CHAR(20);
DEFINE vNum_Cred CHAR(20);
DEFINE cMensajeRet CHAR(125);
DEFINE i_partnum INTEGER;
DEFINE v_folio_ultimo_pago CHAR(16);
DEFINE v_codigo_fun CHAR(3);

-- InicializaciÃ³n de Variables --

-- SET DEBUG FILE TO "/ifxsif01/macf/sp_archivo_compac.out";
--TRACE ON;

LET vFeccom = DATE(1);
LET p_FechaIni1 = DATE(1);
LET vOrig = 0;
LET vEfecom = 0;
LET vImport = 0;
LET sql_err = 0;
LET isam_err = 0;
LET vEmp_Cap = 0;
LET vSuc_P = '';
LET vSuc_C = '';
LET cSql = '';
LET vRuta = '';
LET vPlazo = '';
LET cCod_Ret = '';
LET vTip_com = '';
LET cMesAnio = '';
LET cEmpresa = '';		
LET vCliente = '';	
LET vNum_Tar = '';
LET cMensaje = '';
LET vNum_Prod = '';
LET vNum_Cred = '';	
LET cMensajeRet = '';
LET vproceso = '0297';
LET isam_cCodRet = '';
LET cNombreArchivo = '';
LET cCodRet_2 = '000000';
LET i_partnum = 0;
LET v_folio_ultimo_pago = '';
LET v_codigo_fun = '';


BEGIN
	ON EXCEPTION SET sql_err, isam_err, cMensaje
    	LET cCod_Ret = sql_err;
    	LET isam_cCodRet = isam_err;
		
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_Ret, cMensaje, '02') returning cCodRet_2;	 
		RETURN cCod_Ret, isam_cCodRet, cMensaje;
   	END EXCEPTION;
 		
   	LET cCod_Ret = "000000";
   	LET isam_cCodRet = "000000";
   	LET cEmpresa = "001";
   	LET cMensaje = "PROCESO CONCLUIDO EXITOSAMENTE";
    
	--Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_Ret, 'Inicia sp_archivo_compac', '02') returning cCodRet_2;

    SELECT max(partnum) INTO i_partnum FROM sysmaster:systabnames;
	
	IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE partnum BETWEEN 1 AND i_partnum AND tabname = 'cb_paso_compac'  AND dbsname = 'bdicobranza') THEN
       	DROP TABLE cb_paso_compac;
    END IF;
   
   	CREATE TABLE cb_paso_compac
	(
		numcte            CHAR(20),
		suc_pago          CHAR(4),
		num_tarjeta       CHAR(16),
		num_credito       CHAR(20),
		fecha_compac      DATE,
		efectuo_compac    INTEGER,
		importe           INTEGER,
		plazo             CHAR(2),
		tipo_compac       CHAR(1),
    	origen            SMALLINT,
 		suc_convenio      CHAR(4),
    	empleado_captura  INTEGER,
    	num_producto      CHAR(4)	
	);

   	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO vRuta
    FROM bdicobranza:"informix".cb_param_campania
    WHERE empresa = cEmpresa AND tipo_campania = 1
    AND grupo_parametro = 'ARCHIVOS' AND num_parametro = 92;
    
	IF NVL (vRuta,'') = '' THEN     --Valida que exista la carpeta
        LET cCod_Ret = '104005';

        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCod_Ret;

        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_ret, 'Ruta incorrecta - sp_archivo_compac', '02') RETURNING cCodRet_2;
        RETURN cCod_Ret, isam_cCodRet, cMensajeRet;
    END IF;

   	LET cMesAnio = LPAD(TRIM(DAY(p_FechaIni::DATE)::CHAR(2)),2,'0')||LPAD(TRIM(MONTH(p_FechaIni::DATE)::CHAR(2)),2,'0');
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_ret, ' Obtiene inforcion de convenios revolventes TDC', '02') RETURNING cCodRet_2;
	
   	IF p_FechaIni = date(1) AND p_FechaFin = date(1) THEN
    	LET cCod_Ret = "000001";
    	LET cMensaje = "AMBAS FECHAS SON INVALIDAS";
   	ELSE
        IF p_FechaIni = date(1) THEN
    	    LET cCod_Ret = "000002";
    	    LET cMensaje = "FECHA INVALIDA";
        ELSE
            IF p_FechaIni != date(1) AND p_FechaFin != date(1) THEN
			--INSERT INTO bdicobranza:cb_paso_compac
				FOREACH WITH HOLD
					SELECT
					a.numcliente,
					--d.sucursal as Suc_Pago,
					b.num_tarjeta,
					b.num_credito,
					a.fecha_compac,
					a.efectuo_compac,
            	    a.importe::INTEGER,
					a.plazo,
					a.tipo_compac,
					a.origen,
					a.sucursal as Suc_Conv,
					a.empleado_captura,
					cr.num_producto
            	    INTO
				    vCliente, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod
            	    FROM bdicobranza:cb_compac a INNER JOIN bdicred:sd_maecred cr ON a.empresa = cr.empresa AND a.numcuenta = cr.num_credito  
            	    INNER JOIN bdicred:sd_tarjeta b ON a.empresa = b.empresa AND a.numcliente = b.numcte
													AND a.numcuenta = b.num_credito
													AND b.tipo_tarjeta = 'T'
													AND status_tar = 'A'
													AND b.secuencia = (SELECT max(tar.secuencia)
																	   FROM bdicred:sd_tarjeta tar
																	   WHERE tar.empresa = b.empresa 
																	   AND tar.numcte = b.numcte
																	   AND tar.num_credito = b.num_credito
																	   AND tar.tipo_tarjeta = 'T'
																	   AND tar.status_tar = 'A')
            	    /*INNER JOIN bdinteg:si_cliente c ON  a.numcliente = c.numcte
            	      LEFT JOIN bdicred:sd_movhis d ON a.empresa = d.empresa AND a.numcuenta = d.num_credito 
																		   AND codigo_fun in (SELECT
																							  cod_fun
																							  FROM bdicred:sd_conceptospagomanual
																							  WHERE codigo >= '')
																		   AND d.codigo_ref = 1
																		   AND d.secuencia IN (SELECT MAX(m.secuencia) 
																							   FROM bdicred:sd_movhis m 
																							   WHERE m.empresa = d.empresa --AND m.codigo_fun= "001" 
																							   AND m.codigo_fun IN (SELECT
																													cod_fun
																													FROM bdicred:sd_conceptospagomanual
																													WHERE codigo >= '')
																							   AND m.codigo_ref = 1 
																							   AND m.num_credito = d.num_credito) */
            	    WHERE a.empresa = cEmpresa 
				    AND a.origen <> 4
            	    AND a.fecha_compac >= p_FechaIni
					AND a.fecha_compac <= p_FechaFin

				    --GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ,11 , 12, 13;			
				    -- En lugar de buscar codigo_fun 001 y codigo_ref 1, usarÃ© la sd_conceptospagomanualcrd para obtener los pagos como normalmente se hace
				
				SELECT NVL(folio_ultimo_pago,'') INTO v_folio_ultimo_pago
                  FROM bdicred:sd_indicador_cred 
                 WHERE empresa = cEmpresa AND num_credito = vNum_Cred;
				
				SELECT limit 1 NVL(sucursal,'') INTO vSuc_P
				  FROM bdicred:sd_movhis
				 WHERE folio_suc = v_folio_ultimo_pago 
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual WHERE codigo >= '') 
				   AND codigo_ref = 1;
				  

				BEGIN;
				    INSERT INTO bdicobranza:cb_paso_compac
				    (numcte, suc_pago, num_tarjeta, num_credito, fecha_compac,	efectuo_compac, importe, plazo, tipo_compac, origen, suc_convenio, empleado_captura, num_producto)
				    VALUES(vCliente, vSuc_P, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod);
				COMMIT;
			 	    
			    END FOREACH;
				
				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_ret, 'Obtiene informacion de convenios revolventes TDC Histoirica', '02') RETURNING cCodRet_2;
				--Sacar convenios que se realizan el dÃ­a de hoy y hoy mismo el cliente realiza un pago estos convenios se califican hoy mismo y se van a la cb_compac_his.
				-- INSERT INTO bdicobranza:cb_paso_compac
				
				
				LET v_folio_ultimo_pago = '';
				--INSERT INTO bdicobranza:cb_paso_compac
				-- -- Se implementa Tercer foreach para complemento de tabla bdicobranza:cb_paso_compac
				FOREACH	WITH HOLD
					SELECT
					a.numcliente,
					--d.sucursal,
					'',
					a.numcuenta,
					a.fecha_compac,
					a.efectuo_compac,
                    a.importe::INTEGER,
					a.plazo,
					a.tipo_compac,
					a.origen,
					a.sucursal,
					a.empleado_captura,
					cr.num_producto
					INTO
				    vCliente, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod
					FROM bdicobranza:cb_compac a INNER JOIN bdicred:sd_maecredcrd cr ON  a.empresa = cr.empresa and a.numcuenta = cr.num_credito  
                    --INNER JOIN bdinteg:si_cliente c ON a.numcliente = c.numcte --LEFT JOIN bdicred:sd_movhiscrd d ON a.empresa = d.empresa AND a.numcuenta = d.num_credito AND codigo_fun=  "001" AND codigo_ref= 1 

					WHERE a.empresa = "001" 
					AND a.origen <> 4
					AND a.fecha_compac >=  p_FechaIni
					AND a.fecha_compac <=  p_FechaFin
					-- GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13;
					

                 SELECT NVL(folio_ultimo_pago,'') INTO v_folio_ultimo_pago
                  FROM bdicred:sd_indicador_cred_crd 
                 WHERE empresa = cEmpresa AND num_credito = vNum_Cred;
				
				SELECT limit 1 NVL(sucursal,'') INTO vSuc_P
				  FROM bdicred:sd_movhiscrd
				 WHERE folio_suc = v_folio_ultimo_pago 
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd WHERE num_producto = vNum_Prod) 
				   AND codigo_ref = 1;

					
					BEGIN;
					INSERT INTO bdicobranza:cb_paso_compac
				    (numcte, suc_pago, num_tarjeta, num_credito, fecha_compac,	efectuo_compac, importe, plazo, tipo_compac, origen, suc_convenio, empleado_captura, num_producto)
				    VALUES(vCliente, vSuc_P, vNum_Tar, vNum_Cred, vFeccom, vEfecom, vImport, vPlazo, vTip_com, vOrig, vSuc_C, vEmp_Cap, vNum_Prod);
					COMMIT;
				END FOREACH;

				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, vproceso, cCod_Ret, 'Obtiene informacion de convenios historicos de Plazo', '02') RETURNING cCodRet_2;

	
    	    END IF;
    	END IF;    
	END IF;

    let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba01.unl''' || ' DELIMITER ' || '''|'''  || 
                       ' SELECT * from bdicobranza:cb_paso_compac;'||
                       ' " > /resplogifx/archivoscartera/ArchivoCompAc.sql';     
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/ArchivoCompAc.sql';
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/prueba02.unl''' || ' DELIMITER ' || '''|'''  || 
                       '  SELECT count(*)::INTEGER, sum(importe::INTEGER) ' ||
                       '  FROM bdicobranza:cb_paso_compac ;'||
                       ' " > /resplogifx/archivoscartera/CifrasCompAc.sql';
     
             SYSTEM cSql;
             let cSql = '';
             let cSql = 'dbaccess bdinteg /resplogifx/archivoscartera/CifrasCompAc.sql';
             SYSTEM cSql;             
   

   LET cNombreArchivo = "";
   let cSql = '';
   LET cNombreArchivo = '/resplogifx/archivoscartera/CompromisosyAcuerdos' ||  cMesAnio ||  YEAR(p_FechaIni::DATE)|| '.txt';
   LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prueba01.unl > " || cNombreArchivo;
   SYSTEM cSql;

   LET cNombreArchivo = "";
   let cSql = '';
   LET cNombreArchivo = '/resplogifx/archivoscartera/CompromisosyAcuerdosCifras' || cMesAnio || YEAR(p_FechaIni::DATE) || '.txt';
   LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/prueba02.unl > " || cNombreArchivo;
   SYSTEM cSql;

   let cSql = '';
   LET cSql = "rm /resplogifx/archivoscartera/prueba01.unl /resplogifx/archivoscartera/prueba02.unl /resplogifx/archivoscartera/ArchivoCompAc.sql /resplogifx/archivoscartera/CifrasCompAc.sql ";
   SYSTEM cSql;

   EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCod_Ret,cMensaje,'03')
                      INTO cCodRet_2;
   
   RETURN cCod_Ret,isam_cCodRet,cMensaje;

	
END;	
END PROCEDURE;
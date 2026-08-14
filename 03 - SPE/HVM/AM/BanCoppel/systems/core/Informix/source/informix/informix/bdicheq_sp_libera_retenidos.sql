CREATE PROCEDURE "informix".sp_libera_retenidos()
RETURNING VARCHAR (5) AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;

/* DEFINICION DE VARIABLES */

	DEFINE vCommit  				VARCHAR(50);
	DEFINE vConteoRegistros 		INTEGER;
	DEFINE vIniciaTransaccion   	CHAR(1);
	
	DEFINE vCodigoRetornoArchivo	CHAR(5);
	DEFINE vMensajeArchivo			CHAR(160);
	
	DEFINE vNumtar          	VARCHAR(16);
	DEFINE vnumcta				VARCHAR(12);
	DEFINE vSecuencia			VARCHAR(16);
	DEFINE vFecha        		VARCHAR(25);
	
	DEFINE secu_ret 			VARCHAR(16);
	
	DEFINE v_sql         			CHAR(250);
	DEFINE vCodigoRetorno			CHAR(5);
	DEFINE vMensaje 				CHAR(160);
	DEFINE ERROR_INFO 				VARCHAR(80);
	DEFINE ISAM_ERR 				INTEGER;
	DEFINE SQLERR 					INTEGER;
	DEFINE vDia						VARCHAR(2);
	DEFINE vMes						VARCHAR(2);
	DEFINE vAnio					VARCHAR(4);
	DEFINE HORA_MINUTO_SEG_INICIAL  VARCHAR(14);
	DEFINE HORA_MINUTO_SEG_FINAL    VARCHAR(14);
	DEFINE vFechaInicial			VARCHAR(25);
	DEFINE vFechaFinal				VARCHAR(25);
	DEFINE vFechaUpdate 			VARCHAR(25);
	DEFINE vTrx						INTEGER;
	DEFINE vCD						VARCHAR(50);
	DEFINE vMonto					MONEY;
	DEFINE vTrx1					INTEGER;
	DEFINE vCD1						VARCHAR(50);
	DEFINE vMonto1					MONEY;
	DEFINE horainicioLibera         VARCHAR(23);
	DEFINE horafinLibera            VARCHAR(23);
	DEFINE vIntervalo 				INTEGER;
	DEFINE vNumintervalos           INTEGER;
	DEFINE vFlag					VARCHAR(2);
	DEFINE obtTime					INTEGER;
	DEFINE vTiempo					INTEGER;
	DEFINE NomdownRet				VARCHAR(100);
	DEFINE NomdownRet2				VARCHAR(100);
	
	DEFINE RUTA_UNLOAD 				VARCHAR(30);
	DEFINE vNombreScript 			CHAR(30);
	
	DEFINE nhoraini 				VARCHAR(25);
	DEFINE nhorafin					VARCHAR(25);
	

/* INICIALIZACION DE VARIABLES */

	LET vConteoRegistros = 0;
	LET vCommit	= '';
	LET vIniciaTransaccion = '';
	
	LET vCodigoRetornoArchivo='';
	LET vMensajeArchivo='';
	
	LET secu_ret = '';
	
	LET vNumtar = '';
	LET vnumcta = '';
	LET vSecuencia = '';
	LET vFecha = '';
	
	LET vCodigoRetorno = '';
	LET vMensaje = '';
	LET ERROR_INFO ='';
	LET ISAM_ERR = 0;
	LET SQLERR = 0;
	LET vDia ='';
	LET vMes = '';
	LET vAnio= '';
	LET HORA_MINUTO_SEG_INICIAL = '00:00:00.00000';
	LET HORA_MINUTO_SEG_FINAL = '00:59:59.99999';
	LET vFechaInicial='';
	LET vFechaFinal ='';
	LET vFechaUpdate='';
	LET vTrx = 0;
	LET vCD = '';
	LET vMonto = 0;
	LET vTrx1 = 0;
	LET vCD1 = '';
	LET vMonto1 = 0;
	LET horainicioLibera = '';
	LET horafinLibera = '';
	LET vIntervalo = 0;
	LET vNumintervalos = 0;
	LET vFlag = '';
	LET obtTime = 0;
	LET vTiempo = 0;
	LET NomdownRet = '';
	LET NomdownRet2 = '';
	LET v_sql = '';
	
	
	LET RUTA_UNLOAD = '/RESPALDOSNEW/';
	LET vNombreScript = 'aux.sql';



	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
			
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO||' '||vMensaje;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		

			--SET DEBUG FILE TO  "/home/c90296115/sp_libera_retenidos.err.out";
			---TRACE ON;

		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		--Obtiene datos tbl cntrl 
		SELECT intervalo,num_intervalos,flag
		INTO vIntervalo,vNumintervalos,vFlag
		FROM ctrl_retenidos_eglobal;
			
			IF(vIntervalo > vNumintervalos)THEN 
			
					UPDATE bdicheq:ctrl_retenidos_eglobal 
					SET intervalo=1,flag = 'F';
					LET vCodigoRetorno = '00000';
					LET vMensaje = 'Proceso exitoso ("Se alacanzo el # maximo de Intervalos")';
			
			ELIF (vIntervalo <= vNumintervalos AND vFlag = 'F' )THEN					
							
						UPDATE bdicheq:ctrl_retenidos_eglobal 
						SET flag = 'V';
						
						--Obtiene datos tbl cntrl 
						SELECT hora_inicio,hora_inicio + (tiempo * intervalo) UNITS MINUTE
						INTO horainicioLibera, horafinLibera
						FROM ctrl_retenidos_eglobal;
	
					
						--Obtiene datos para Insertar
						SELECT 
						'Retenido_Credito' AS tabname,  a.numtarjeta AS numtarjeta ,b.numcuenta AS numcta,a.monto AS monto,'i'||a.secuenciaextendida AS secuenciaextendida,a.fechahorainauth AS fechahorainauth
						FROM intercard:movimiento a,
						intercard:tarjetacuenta b,
						intercard:tarjeta c,
						intercard:productotarjeta d
						WHERE fechahorainauth BETWEEN horainicioLibera AND horafinLibera
						--WHERE (( a.fechahorainauth >= horainicioLibera AND a.fechahorainauth <= horafinLibera))
						AND a.codtran = "00"
						AND a.formato = "0200"
						AND a.codigoiso = "00"
						AND a.movreversado = "F"
						AND a.movconciliado = "F"
						AND b.numtarjeta = a.numtarjeta
						AND c.numtarjeta = a.numtarjeta
						AND d.codproductotarjeta = c.codproductotarjeta
						AND d.escredito = "V" 
						AND a.fechahoraoutauth-a.fechahorainauth >= "0 00:00:03.00000" 
						INTO TEMP temp_deb with no log;
						
						 CREATE INDEX "informix".idx_tmp_deb ON temp_deb(fechahorainauth,numtarjeta,numcta) ONLINE;
						 UPDATE STATISTICS MEDIUM FOR TABLE "informix".temp_deb; 
						
						SELECT
						'Retenido_Debito' AS tabname, a.numtarjeta AS numtarjeta ,b.numcuenta AS numcta,a.monto AS monto,'i'||a.secuenciaextendida AS secuenciaextendida,a.fechahorainauth AS fechahorainauth
						FROM
						intercard:movimiento a, intercard:tarjetacuenta b,
						intercard:tarjeta c, intercard:productotarjeta d
						WHERE fechahorainauth BETWEEN horainicioLibera AND horafinLibera
						--WHERE (( a.fechahorainauth >= horainicioLibera AND a.fechahorainauth <= horafinLibera))
						AND a.codtran = '00'
						AND a.formato = '0200'
						AND a.codigoiso = '00'
						AND a.movreversado = 'F'
						AND a.movconciliado = 'F'
						AND b.numtarjeta = a.numtarjeta
						AND c.numtarjeta = a.numtarjeta
						AND d.codproductotarjeta = c.codproductotarjeta
						AND d.escredito = 'F' 
						AND a.fechahoraoutauth-a.fechahorainauth >= '0 00:00:03.00000' 
						INTO TEMP temp_cred with no log;
						
							CREATE INDEX "informix".idx_tmp_cred ON temp_cred(fechahorainauth,numtarjeta,numcta) ONLINE;
							UPDATE STATISTICS MEDIUM FOR TABLE "informix".temp_cred; 
						
						--Fusiona las tab temp 
						SELECT * FROM temp_deb
						UNION ALL
						SELECT * FROM temp_cred
						INTO TEMP detalle_ret WITH NO LOG;
							
							CREATE INDEX "informix".tmp_detalle_ret ON detalle_ret(fechahorainauth,numtarjeta,numcta) ONLINE;
							UPDATE STATISTICS MEDIUM FOR TABLE "informix".detalle_ret; 
						
						-----Agrega a tabla de registro
						FOREACH secuencias WITH HOLD FOR
		
						SELECT tabname,numtarjeta, numcta,monto,secuenciaextendida,SUBSTR (fechahorainauth,1,19)
						INTO vCD,vNumtar,vNumcta,vMonto,vSecuencia,vFecha
						FROM detalle_ret
							
						INSERT INTO informix.retenidos_eglobal(consecutivo, tabname, numtar, numcta, monto, secuencia_ext, fechahorainauth, liberado, fecha_liberado, usuario) 
						VALUES(0, vCD, vNumtar, vNumcta, vMonto, vSecuencia, vFecha, 'F', '1996-02-12 00:00:00.0', 'Informix');	
						
						END FOREACH
						
								
		
						--Obtiene Folios a procesar debito
						select secuencia_ext as folio_suc
						from retenidos_eglobal
						where  secuencia_ext in (select secuenciaextendida from detalle_ret)
						and tabname in ('Retenido_Debito')
						into temp tmp_folios_deb with no log;
						
							CREATE INDEX "informix".idx_tmp_folios_deb ON tmp_folios_deb(secuencia_ext,tabname) ONLINE;
							UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_folios_deb;
						
						update bdicheq:sc_docret
						set dias_ret = 0
						where fecha_alta =vFechaUpdate---MM/DD/AAAA
						and cancelado = 'P'
						and folio_suc in( select folio_suc from tmp_folios_deb );
						
						
						EXECUTE  PROCEDURE  liberasalret_esp('001')
						INTO vCodigoRetornoArchivo;
						
						
							---------Insert para descarga cheques/deb
									FOREACH secuencias_unl WITH HOLD FOR
				
									SELECT folio_suc
									INTO secu_ret
									FROM tmp_folios_deb
										
									INSERT INTO informix.secuencias_ret(secuencia_ext) 
									VALUES(secu_ret);
								
									END FOREACH
						
						
						--Hace el update a fecha liberado y marca el flag de liberado
						UPDATE bdicheq:retenidos_eglobal SET fecha_liberado = current, liberado = 'V'
						WHERE secuencia_ext in (SELECT * FROM secuencias_ret)
						AND  tabname = 'Retenido_Debito';
						
						--Obtiene el nombre del archivo
							LET vDia = LPAD(DAY(CURRENT),2,'0');  
							LET vMes = LPAD(MONTH(CURRENT),2,'0');
							LET vAnio = year(CURRENT);
							LET nhoraini = SUBSTR(horainicioLibera,12,16);
							LET nhorafin = SUBSTR(horafinLibera,12,16);
						-------------------Descarga DEBITO
						LET NomdownRet = 'RET_DEB-'||vAnio||vDia||vMes||'-'||TRIM (nhoraini)||'-'||TRIM(nhorafin)||'-intervalo:'||vIntervalo;
						
						LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;'||
								  'UNLOAD TO '||RUTA_UNLOAD||NomdownRet||'.unl '||
								  'SELECT * FROM retenidos_eglobal WHERE '||
								  'secuencia_ext in (SELECT * FROM secuencias_ret);">'
								  ||RUTA_UNLOAD||vNombreScript; 
								  
						System v_sql;
						
						LET v_sql = '';
						------------EJECUTA Descarga
						LET v_sql = 'dbaccess bdicheq '||RUTA_UNLOAD||vNombreScript; 
						System v_sql; 	
						
						-- BORRADO DE SCRIPTS GENERADOS EN EL PROCESO
						LET v_sql = '';
						LET v_sql = 'rm '||RUTA_UNLOAD||vNombreScript;
						System v_sql;
						
						--Vacia la tab_secuencias_ext
						TRUNCATE bdicheq:secuencias_ret;
						
						--Obtiene Folios a procesar credito
						select secuencia_ext as folio_suc
						from retenidos_eglobal
						where  secuencia_ext in (select secuenciaextendida from detalle_ret)
						and tabname in ('Retenido_Credito')
						into temp tmp_folios_cred with no log;
						
							CREATE INDEX "informix".idx_tmp_folios_deb ON tmp_folios_cred(secuencia_ext,tabname) ONLINE;
							UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_folios_cred;
						
								---------Insert para descarga cred/deb
									FOREACH secuencias_unl WITH HOLD FOR
				
									SELECT folio_suc
									INTO secu_ret
									FROM tmp_folios_cred
										
									INSERT INTO informix.secuencias_ret(secuencia_ext) 
									VALUES(secu_ret);
								
									END FOREACH
						
								
						LET NomdownRet2 = 'RET_CRED-'||vAnio||vDia||vMes||'-'||TRIM (nhoraini)||'-'||TRIM(nhorafin)||'-intervalo:'||vIntervalo;
						-------------------Descarga CREDITO			
						LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;'||
								  'UNLOAD TO '||RUTA_UNLOAD||NomdownRet2||'.unl '||
								  'SELECT * FROM retenidos_eglobal WHERE '||
								  'secuencia_ext in (SELECT * FROM secuencias_ret);">'
								  ||RUTA_UNLOAD||vNombreScript; 
								  
						System v_sql;
						
						LET v_sql = '';
						------------EJECUTA Descarga
						LET v_sql = 'dbaccess bdicheq '||RUTA_UNLOAD||vNombreScript; 
						System v_sql; 

						-- BORRADO DE SCRIPTS GENERADOS EN EL PROCESO
						LET v_sql = '';
						LET v_sql = 'rm '||RUTA_UNLOAD||vNombreScript;
						System v_sql;
						
						
						--Hace que el flag del proceso se apague
						UPDATE bdicheq:ctrl_retenidos_eglobal 
						SET flag = 'F';
						
						--Ingresa la nueva fecha y el incremento del intervalo 
						UPDATE bdicheq:ctrl_retenidos_eglobal SET hora_inicio = horafinLibera, intervalo = vIntervalo +1;
						--Vaciar tab de paso
						TRUNCATE bdicheq:secuencias_ret;
						--VACIAR LA TAB's  TEMPORAL
						TRUNCATE TABLE tmp_folios_cred;
						TRUNCATE TABLE tmp_folios_deb;
						TRUNCATE TABLE detalle_ret;
						TRUNCATE bdicheq:secuencias_ret;
						
						LET vCodigoRetorno = '00000'||'# TRNXS liberadas: '||vTrx1||'FLAG EN STATUS:'||vFlag;
						LET vMensaje = 'Proceso exitoso';
			END IF; 
		
		RETURN vCodigoRetorno,vMensaje;
	END
END PROCEDURE
DOCUMENT
'Coordinacion de Operaciones y Servidores distribuidos LV 1 | Gerencia Mantenimiento I',
'Autor: Miguel Angel Lopez Galvan',
'RQI - 34 015  AutomatizaciÃ³n del procedimiento de liberaciÃ³n saldos retenidos cheques y descarga insumos credito.';

CREATE PROCEDURE "informix".movinver(pempresa CHAR(3))
RETURNING CHAR(5);
    
    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE vrow         INTEGER; 
    DEFINE vsucursal    CHAR(4);
    DEFINE vcuenta      CHAR(20);
    DEFINE vmonto       MONEY(14,2);
    DEFINE vdivisa      CHAR(2);
    DEFINE vstatus      CHAR(1);
    DEFINE vusuario     CHAR(8);
    DEFINE vtipo_mov    CHAR(1);
    DEFINE vfolio_suc   CHAR(16);
    DEFINE vtransacc    CHAR(4);
    DEFINE vreferencia  CHAR(40);
    DEFINE vfecha_hoy   DATE;
    DEFINE vtranret     CHAR(4);
    DEFINE vfechapli    DATE;
    DEFINE vsdodisp     MONEY(14,2);
    DEFINE vimpcar      MONEY(14,2);
    DEFINE v_size       SMALLINT;
    DEFINE vtransaccion INTEGER;
    DEFINE vexiste      SMALLINT;
    
    LET vcodret      = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = '';
    LET vrow         = 0;
    LET vsucursal    = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vdivisa      = '';
    LET vstatus      = '';
    LET vtipo_mov    = '';
    LET vfolio_suc   = '';
    LET vtransacc    = '';
    LET vreferencia  = '';
    LET vfecha_hoy   = '';
    LET vtranret     = '';
    LET vfechapli    = '';
    LET vsdodisp     = 0.00;
    LET vimpcar      = 0.00;
    LET vtransaccion = 0;
    LET v_size       = LENGTH(user);
    LET vusuario     = SUBSTR(user,v_size-7, v_size);
    LET vexiste      = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/movinver.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN vcodret;
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/movinver.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy 
      INTO vfecha_hoy 
      FROM sc_fechas 
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_movinver ix212_2)}
               a.rowid, a.sucursal, a.cuenta, a.tipo_mov, a.monto, a.divisa, a.transacc, a.referencia
          INTO vrow, vsucursal, vcuenta, vtipo_mov, vmonto, vdivisa, vtransacc, vreferencia
          FROM sc_movinver a, 
               sc_maechq b
         WHERE a.cuenta = b.cuenta
           AND a.procesado != 'S'
           AND b.status_cta in('1','3','4','5')
         ORDER BY a.referencia, a.transacc
        
        LET vcodret = '000';
        LET vstatus = '';
        LET vfolio_suc = current hour to fraction(3);
        LET vfolio_suc = vusuario||vfolio_suc[1,2]||vfolio_suc[4,5]||vfolio_suc[7,8]||vfolio_suc[10,11];
        
        SELECT status_cta 
          INTO vstatus 
          FROM sc_maechq
         WHERE cuenta = vcuenta;
        
        IF vstatus = '3' THEN
            UPDATE sc_maechq
               SET status_cta = '1'
             WHERE cuenta = vcuenta;
        END IF
        
        IF vtipo_mov = 'C' THEN
            CALL cargo_ref(pempresa, vsucursal, vusuario, vtransacc, "0000", vfolio_suc, vcuenta, 0, vmonto, vdivisa, vreferencia, "", "")
            RETURNING vcodret, vtranret, vfechapli, vsdodisp, vimpcar;
        ELIF vtipo_mov = 'A' THEN
            CALL abono_ref(pempresa, vsucursal, vusuario, vtransacc, "0000", vfolio_suc, vcuenta,0, vmonto, vmonto, 0, 0, 0, vdivisa, vreferencia, "", "")
            RETURNING vcodret;
        END IF;
        
        IF vstatus = '3' THEN
            UPDATE sc_maechq
               SET status_cta = '3'
             WHERE cuenta = vcuenta;
        END IF
        
        IF vcodret = '000' THEN
            UPDATE sc_movinver
               SET procesado = 'S',
                   codigo_retorno = vcodret,
                   fecha_proceso = vfecha_hoy
             WHERE rowid = vrow;
             
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                EXIT FOREACH;
            END IF;
        ELSE
            UPDATE sc_movinver
               SET procesado = 'N',
                   codigo_retorno = vcodret,
                   fecha_proceso = vfecha_hoy
             WHERE rowid = vrow;
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                EXIT FOREACH;
            END IF;
        END IF
    END FOREACH
    
    FOREACH 
        SELECT {+INDEX(sc_movinver ix212_2)}
               TRIM(cuenta), monto, transacc, TRIM(referencia)
          INTO vcuenta, vmonto, vtransacc, vreferencia
          FROM sc_movinver
         WHERE cuenta >= '10000005016'
           AND procesado <> 'S'
           AND codigo_retorno = '000'
           AND fecha_apli = vfecha_hoy
           AND (fecha_proceso is null or fecha_proceso = '')
           
        SELECT COUNT(*)
          INTO vexiste
          FROM sc_movdia
         WHERE cuenta = vcuenta
           AND transacc = vtransacc
           AND cancelad <> 'S'
           AND referencia = vreferencia
           AND monto_tot = vmonto;
           
        IF vexiste > 0 THEN
            UPDATE sc_movinver
               SET procesado = 'S',
                   fecha_proceso = vfecha_hoy
             WHERE cuenta = vcuenta
               AND transacc = vtransacc
               AND monto = vmonto
               AND referencia = vreferencia
               AND fecha_apli = vfecha_hoy;
        END IF;
        
        LET vcuenta     = '';
        LET vmonto      = 0.00;
        LET vtransacc   = '';
        LET vreferencia = '';
        LET vexiste     = 0;
    END FOREACH;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    LET vcodret = '000';
    
    RETURN vcodret;
    
    END
    
END PROCEDURE;
CREATE PROCEDURE "informix".sp_replica_manual_indicadores_ctes_bi(iIndicador INTEGER,dFechaIni DATE, dFechaFin DATE,cSucursal CHAR(4))
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE iEnTransaccion   SMALLINT;
DEFINE iNomErr			INTEGER;
DEFINE iNanErr			INTEGER;
DEFINE dFechaProceso	DATE;


--ASIGNACION DE VARIABLES
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO DE REPLICA MANUAL SE A GENERADO CORRECTAMENTE';
LET iEnTransaccion = 0;


 --SET DEBUG FILE TO "/informix/ALAN/MANTENIMIENTOREPLICAS/sp_replica_manual_bi.out";
 --TRACE ON;

BEGIN

	--MANEJO DEL ERROR
		ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
			IF iNomErr <> 0 THEN
			LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN
		
					ROLLBACK;
                END IF;
				
				RETURN vCodRet, cMensCodRet;
			END IF;
		END EXCEPTION;	
		
		IF NVL(dFechaIni,'') = '' OR  NVL(dFechaFin,'') = ''  THEN 		
			LET vCodRet = '000001';
			LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
			RETURN vCodRet, cMensCodRet;
		ELIF dFechaIni > dFechaFin THEN
			LET vCodRet = '000002';
			LET cMensCodRet = 'PARAMETROS INCORRECTOS, FECHA INCIAL MAYOR A FECHA FINAL';
			RETURN vCodRet, cMensCodRet;
		ELIF iIndicador = '' OR iIndicador IS NULL THEN
			LET vCodRet = '000003';
			LET cMensCodRet = 'PARAMETRO VACIO,PARAMETRO INCORRECTO';
			RETURN vCodRet, cMensCodRet;	
		ELIF iIndicador <> '2' AND  iIndicador <> '101' THEN
			LET vCodRet = '000004';
			LET cMensCodRet = 'PARAMETRO INCORRECTO';
			RETURN vCodRet, cMensCodRet;
		END IF;
		
		LET dFechaProceso = dFechaIni;
			
    IF  iIndicador = 2 THEN
			WHILE (dFechaProceso <= dFechaFin)
			BEGIN WORK;
			
				LET iEnTransaccion = 1;
				--IF EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det WHERE fecha = dFechaProceso) THEN --DESARROLLO
				IF EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det WHERE fecha = dFechaProceso) THEN  --PRODUCCION
					--DELETE FROM bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det
					DELETE FROM bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det
					WHERE fecha = dFechaProceso;
				END IF;				
			
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut,
				INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut, 
																altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
																telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
																telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
																telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep, fecha_insert)
				SELECT a.tipo_movto, a.fecha, a.sucursal, TRIM(b.nombre) AS nom_suc, a.ejecutivo, TRIM(c.nombre) AS nom_ejec ,a.altas_ctes,
					   a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
					   a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
					   a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
					   a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep, a.fecha_insert
				FROM si_indicadores_ctes_nvos_det a, si_sucursales b, si_ejecut c
				WHERE fecha = dFechaProceso
				AND a.ejecutivo = c.ejecutivo
				AND a.sucursal = b.sucursal;
		
			COMMIT WORK;
			LET iEnTransaccion = 0;			
				--END IF;
			LET dFechaProceso = dFechaProceso + 1 UNITS DAY; 
			END WHILE;
	ELSE
	
		IF cSucursal = '' THEN		
			IF  iIndicador = 101 THEN
				WHILE (dFechaProceso <= dFechaFin)
				BEGIN WORK;
				
					LET iEnTransaccion = 1;
					--IF EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko WHERE fecha_proceso = dFechaProceso) THEN --DESARROLLO
					IF EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko WHERE fecha_proceso = dFechaProceso) THEN  --PRODUCCION
						--DELETE FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko
						DELETE FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko
						WHERE fecha_proceso = dFechaProceso;
					END IF;				
				
					--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal, nombre_suc,cons_movimientos, cons_saldos, cons_edocta, user_insert,fecha_insert)
					INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal,nombre_suc,cons_movimientos, cons_saldos, cons_edocta, user_insert,fecha_insert)
					SELECT a.fecha_proceso, a.sucursal,b.nombre ,a.cons_movimientos, a.cons_saldos, a.cons_edocta,USER,CURRENT
					FROM si_indicadores_kiosko a,si_sucursales b
					WHERE fecha_proceso = dFechaProceso
					AND a.sucursal = b.sucursal;
						
				COMMIT WORK;
				LET iEnTransaccion = 0;			
				--END IF;
				LET dFechaProceso = dFechaProceso + 1 UNITS DAY;
				END WHILE;
			END IF;
		ELSE
			IF  iIndicador = 101 THEN
				WHILE (dFechaProceso <= dFechaFin)
				BEGIN WORK;
				
					LET iEnTransaccion = 1;
					--IF EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko WHERE fecha_proceso = dFechaProceso AND sucursal = cSucursal) THEN --DESARROLLO
					IF EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko WHERE fecha_proceso = dFechaProceso AND sucursal = cSucursal) THEN  --PRODUCCION
						--DELETE FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko
						DELETE FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko
						WHERE fecha_proceso = dFechaProceso AND sucursal = cSucursal;
					END IF;				
				
					--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal, nombre_suc,cons_movimientos, cons_saldos, cons_edocta, user_insert,fecha_insert)
					INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal,nombre_suc,cons_movimientos, cons_saldos, cons_edocta, user_insert,fecha_insert)
					SELECT a.fecha_proceso, a.sucursal,b.nombre ,a.cons_movimientos, a.cons_saldos, a.cons_edocta,USER,CURRENT
					FROM si_indicadores_kiosko a,si_sucursales b
					WHERE fecha_proceso = dFechaProceso AND a.sucursal = cSucursal
					AND a.sucursal = b.sucursal;
						
				COMMIT WORK;
				LET iEnTransaccion = 0;			
				--END IF;
				LET dFechaProceso = dFechaProceso + 1 UNITS DAY;
				END WHILE;
			END IF;
		END IF;	
	END IF;	
  RETURN vCodRet, cMensCodRet;		
END;
		
END PROCEDURE	
DOCUMENT
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:22/06/2015',
'VERSION:2010622',
'MODIFICO: Alan Humberto Zazueta Kuroda',
'DESCRIPCION: Se agrega un parametro de entrada para que replique por sucursal';

CREATE PROCEDURE "informix".sp_obten_datos_e_global_mov(p_tarjeta CHAR(20), p_secuenciaExtendida CHAR(20), p_debito CHAR(1), p_cuenta CHAR(20), p_empresa CHAR(3))

     RETURNING	DATETIME YEAR TO SECOND AS fechaMovimiento, CHAR(20) AS iso41, CHAR (20) AS iso37, CHAR(4) AS idReceptor, CHAR(6) AS horaMovimiento, money(16,2) AS resultado_monto_comision, CHAR(1) AS resultado_codigo, CHAR(7) AS secuencia;

	--definicion de variables--	    
	DEFINE resultado_fechaMovimiento    DATETIME YEAR TO SECOND;
    DEFINE resultado_iso41              CHAR(20);
    DEFINE resultado_iso37              CHAR(20);
    DEFINE resultado_idReceptor         CHAR(4);
    DEFINE resultado_horaMovimiento     CHAR(6);
	DEFINE resultado_monto_comision		money(16,2);
    DEFINE resultado_codigo             CHAR(1);
    DEFINE var_secuencia                CHAR(7);
    DEFINE var_fechaAut                 DATETIME YEAR TO SECOND;
	DEFINE var_fechaAnt					DATE;
	DEFINE var_fechapost				DATE;
	DEFINE tipo_producto				CHAR(2);
    DEFINE iSqlErr                      INTEGER;
     
     -- Inicialización de las variables.
    LET resultado_fechaMovimiento = null;
	LET resultado_iso41  = '';
    LET resultado_iso37  = '';
    LET resultado_idReceptor = '';
    LET resultado_horaMovimiento = '';
    LET resultado_monto_comision = '';
    LET resultado_codigo = '';
    LET var_secuencia = '';
	LET var_fechaAnt = null;
	LET var_fechapost = null;
	LET tipo_producto ='';
    LET var_fechaAut = null;
	
   --SET DEBUG FILE TO "../informix/BB/eglobal/sp_obten_datos_e_global_mov.out";
   --TRACE ON;

    SET ISOLATION TO DIRTY READ;

	BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_fechaMovimiento = '';
                LET resultado_iso41  = '';
                LET resultado_iso37  = '';
                LET resultado_idReceptor = '';
                LET resultado_horaMovimiento = '';
                LET resultado_monto_comision = '';
                LET resultado_codigo = '';
                LET var_secuencia = '';
				LET var_fechaAnt = '';
				LET var_fechapost = '';
                LET var_fechaAut = '';
            RETURN resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, resultado_codigo, var_secuencia;
            END IF;
        END EXCEPTION;
		
		/*Se busca la información en la tabla de movimiento*/
		SELECT DISTINCT fechahorainauth, idterminal, referencia, idreceptor, horalocaltransaccion, montosurcharge, secuencia
			INTO resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, 
				resultado_monto_comision, var_secuencia
		FROM intercard:movimiento
		WHERE numtarjeta = p_tarjeta
            AND secuenciaextendida LIKE (SUBSTRING (p_secuenciaExtendida FROM 1 FOR 8) || '_' || SUBSTRING(p_secuenciaExtendida FROM 10 FOR 15));
            					   
		SELECT DISTINCT codreversa
            INTO resultado_codigo
		FROM intercard:movimiento
		WHERE numtarjeta = p_tarjeta
            AND secuenciaorig = var_secuencia;            
		
		/*De no encontrar la información en las tabla anterior, se realiza la búsqueda sobre movimientohistorico*/
		IF (resultado_iso41 is null OR resultado_iso41 =='') THEN 
			SELECT DISTINCT fechahorainauth, idterminal, referencia, idreceptor, horalocaltransaccion, montosurcharge, secuencia
				INTO resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, 
					resultado_monto_comision, var_secuencia
			FROM intercard:movimientohistorico
			WHERE numtarjeta = p_tarjeta
				AND secuenciaextendida LIKE (SUBSTRING (p_secuenciaExtendida FROM 1 FOR 8) || '_' || SUBSTRING(p_secuenciaExtendida FROM 10 FOR 15));
            					   
            SELECT DISTINCT codreversa
				INTO resultado_codigo
            FROM intercard:movimientohistorico
            WHERE numtarjeta = p_tarjeta
				AND secuenciaorig = var_secuencia;            
		END IF;
		
        RETURN resultado_fechaMovimiento, resultado_iso41, resultado_iso37, resultado_idReceptor, resultado_horaMovimiento, resultado_monto_comision, resultado_codigo, var_secuencia;
    END 
END PROCEDURE
DOCUMENT
'Sp para generación de datos para archivos ATM´s para solicitar a Eglobal por sistema',
'Aclaraciones',
'AUTOR : Bernardo Beltrán Herrera',
'MODIFICADO POR : Víctor Jesús Mendoza Pérez',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Marzo/2013',
'FECHA MODIFICACIÓN: 06/Julio/2017',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_desasocia_ctapbn_emp( pEmpresa CHAR(3), prfc CHAR(15), pnumcte CHAR(10), pnumcta CHAR(30) )
RETURNING CHAR(6), CHAR(60), CHAR(1);

	/*Definicion de variables del proceso y manejo de errores*/
		DEFINE error_info 		CHAR(60);
		DEFINE vcodret    		CHAR(6);
		DEFINE vsqlerr    		INTEGER;
		DEFINE isam_err   		SMALLINT;
		DEFINE vstscta			CHAR(1);
		DEFINE vbcta			INT;
		--SET DEBUG FILE TO "/informix/ifg/sp_desasocia_ctapbn_emp.out";
		--TRACE ON;

		LET vcodret       	= '00000';
		LET error_info    	= 'Iniciando ejecucion';
		LET isam_err      	= 0;
		LET vsqlerr       	= 0;
		LET vstscta			= '';
		LET vbcta			= 0;




		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		/*Incia SP*/
		BEGIN
			--//Excepciones
			ON EXCEPTION SET vsqlerr, isam_err, error_info
				IF vsqlerr <> 0 THEN
					 LET vcodret = vsqlerr;
					 LET isam_err = isam_err;
					 LET error_info = error_info;
					 RETURN vcodret, error_info, vstscta;
				END IF;
			END EXCEPTION;
			
			--// Valida la informacion de entrada
		   IF pEmpresa       = "" OR
			  prfc      = "" OR
			  pnumcte      = "" OR
			  pnumcta       = "" THEN
						  LET vcodret = "00001";
						  LET error_info = 'ERROR PARAMETROS VACIOS'; 
						
			ELSE
						  SELECT COUNT(*) INTO vbcta FROM bdinteg:si_ctepf WHERE numcte =  pnumcte;
						  SELECT status_cta INTO vstscta FROM bdicheq:sc_maechq WHERE num_cte =  pnumcte AND cuenta = pnumcta;
						  IF (vbcta != 0) AND (vstscta = 1) THEN	
								UPDATE bdinteg:si_ctepf SET numeric1 = '', 
															numeric2 = '' 
											WHERE numcte =  pnumcte;
											
								UPDATE bdinteg:si_altamasivaempnet_det SET cod_empresa = '' 															
											WHERE cod_empresa =  pEmpresa
											  AND numcte = pnumcte
											  AND cuenta = pnumcta;				
												
								LET vcodret = '00000';
								LET error_info = 'PROCESO EJECUTADO EXITOSAMENTE';
						  ELSE 
								
								LET vcodret = "00002";
								LET error_info = 'NO SE ENCONTRARON DATOS';
						  END IF;
		   END IF;
	 RETURN vcodret,error_info,vstscta;
	    
    END;
    
END PROCEDURE;
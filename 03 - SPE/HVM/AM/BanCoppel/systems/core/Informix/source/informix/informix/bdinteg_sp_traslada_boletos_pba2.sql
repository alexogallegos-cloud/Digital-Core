CREATE PROCEDURE "informix".sp_traslada_boletos_pba2(p_cve_sorteo char(5), p_fecha_pase DATE)
RETURNING CHAR(5)  AS Codigo_retorno, 
          CHAR(80) AS Mensaje,
          CHAR(1)  AS Reverso,
          CHAR(25) AS StorePro;              
               
    DEFINE vsqlerr           INTEGER; 
    DEFINE v_codigo_retorno	CHAR(5);
    DEFINE v_mensaje	  	    CHAR(80);
    DEFINE v_reverso         CHAR(1);
    DEFINE v_store_pro       CHAR(25);
    DEFINE vrowid      INTEGER;
    DEFINE vd_valida   DATE;
    DEFINE vd_fecha2   DATE;
    DEFINE vd_fsorteo  DATE;
    DEFINE vc_numcte   CHAR(10);
    DEFINE vi_nociudadcoppel  INTEGER;
    DEFINE vi_nocoloniacoppel INTEGER;
    DEFINE vc_nomzonacoppel   CHAR(20);
    DEFINE vc_nomcuidad       CHAR(20);  
    DEFINE vc_nombre          CHAR(25);
    DEFINE vc_telef1          CHAR(10);
    DEFINE vc_telef2          CHAR(13);
    DEFINE vc_domicilio       CHAR(50);
    DEFINE vc_nomcalle        CHAR(20); 
    DEFINE vc_numextcalle     CHAR(10);
    DEFINE vc_nomcolonia      CHAR(20);
    DEFINE vc_nombre_cte   CHAR(45);
    DEFINE vc_cvesorteo    INTEGER;
	DEFINE v_foliosuc CHAR(16);
    DEFINE v_param		  CHAR(5);  -- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.

    SET debug file TO "/tmp/traslada_boletos.out";
    TRACE ON;

    LET v_codigo_retorno = "00000";
    LET v_mensaje = "Proceso Inicia Correctamente";
    LET v_reverso = '0';
    LET v_store_pro = 'sp_traslada_boletos';
    LET vrowid     = 0;
    LET vd_valida  = (p_fecha_pase - 1 units day);
    LET vd_fsorteo = (vd_valida - 1 units day);

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_traslada_boletos';
            RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
    END EXCEPTION;
	   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = p_cve_sorteo AND flag_sort = 2) THEN
					
				/*se agrega para optimizacion de busqueda*/
    
				-- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.
				SELECT valor 
				INTO v_param 
				FROM bdinteg:si_param
				WHERE cod_param = 118;
				
				SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
				INTO vc_cvesorteo
				FROM si_sorteo
				WHERE cve_sorteo = v_param;     -- FMV 21-Sep-10    
				
				IF NOT EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
								 FROM bdinteg:si_sorteo 
								WHERE cve_sorteo = v_param) THEN -- FMV 21-Sep-10 
					LET v_codigo_retorno = "00040";
					LET v_mensaje = "Se Genero Error en si_sorteo, No Existe Sorteo!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;   
				
				IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo
							 FROM bdinteg:si_sorteo
							WHERE cve_sorteo = v_param  -- FMV 21-Sep-10 
							  AND f_fin < vd_fsorteo) THEN                  
					LET v_codigo_retorno = "00042";
					LET v_mensaje = "Se Genero Error en si_sorteo, Sorteo No esta Vigente!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;
				
				--*********************************************************--
				-- Creado por: Francisco Martinez Viveros	
				--Fecha Creacion: 31/AGOSTO/2010
				--Fecha Modifica: 09/NOVIEMBRE/2010 
				--Objetivo: Traspasa los boletos generados diariamente y 
				--          los envia a la tabla historica con los datos del clte.    
				--*********************************************************--

				
				IF (p_fecha_pase is null) THEN
					LET v_codigo_retorno = "00030";
					LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				-- BGM 08-Nov-2010: se coloca en primera instancia el foreach para actualizar los datos del cliente 
				-- sobre la misma tabla si_boleto
				-- FOREACH 1 
				FOREACH cursor_actual WITH HOLD FOR              
					SELECT {+index (si_boleto idx_si_bol_clte)} fecha, numcte   --FMV 8-NOV-10: SE ADICIONA INDICE               
					INTO vd_fecha2, vc_numcte  
					FROM bdinteg:"informix".si_boleto 
					WHERE fecha = vd_valida 
					AND numcte > '0000000'

					BEGIN WORK;

					-- BGM 08-Nov-2010: se coloca query optimizado por Faviola Martínez.
					-- FMV 09-Nov-2010: Query filtrado por Faviola Martínez, con aquellos Clientes q no tienen datos completos.

					SELECT {+index (SI_CATCALLES idx_catcalles)}
							CAT.numerociudadcoppel,CAT.numerocoloniacoppel,CAT.nombrezonacoppel, 
							CIU.NOMBRECIUDAD, SCA.NOMBRECALLE, SE.nombre,tel1.telefono, tel2.telefono,
							dom.numeroextcalle, CAT.nombrezona    
					  INTO vi_nociudadcoppel, vi_nocoloniacoppel, vc_nomzonacoppel, vc_nomcuidad,
							vc_nomcalle, vc_nombre, vc_telef1, vc_telef2, vc_numextcalle,
							vc_nomcolonia
					FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
					LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
					LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
					LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
					LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado   = SE.ESTADO )
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1)
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2)
					WHERE DOM.NUMCTE = vc_numcte 
					-- AND DOM.SECUENCIA IN (SELECT MAX(SID.SECUENCIA) FROM BDINTEG:SI_DIRECCIONES_ACTUAL SID WHERE SID.NUMCTE = DOM.NUMCTE AND SID.TIPO_DIR = 1 ) 
					AND DOM.TIPO_DIR  = 1;
					
					--FMV: Se Adiciona validacion para los telefonos por si el dato en null
					IF (vc_telef1 IS NULL) OR (vc_telef1= '') THEN 
						LET vc_telef1 = '0';
					END IF;
					
					IF (vc_telef2 IS NULL) OR (vc_telef2= '') THEN 
						LET vc_telef2 = '0';
					END IF;
					
					LET vc_nombre_cte = (SELECT trim(nombre1)||' '||   
												trim(nombre2)||' '||    
												trim(apell_paterno)||' '|| 
												trim(apell_materno)                                            
												FROM bdinteg:si_cliente WHERE numcte = vc_numcte);    
												
					LET vc_domicilio =  trim(vc_nomcalle)||' '||
										trim(vc_numextcalle)||' '||                                                                      
										trim(vc_nomcolonia);
				
					-- BGM 08-Nov-2010: se hace el update sobre si_boleto en lugar de si_boleto_hist
					UPDATE bdinteg:"informix".si_boleto        --{+index (si_mensajes_enviar_his idx_msgs_envhis)}
					SET telefono1 = vc_telef1,
						telefono2 = vc_telef2,
						nombre    = vc_nombre_cte,
						ciudad    = vc_nomcuidad,
						domicilio = vc_domicilio,
						ent_fed = vc_nombre --SE AGREGA PARA GUARDARSE EN LA TABLA
					WHERE CURRENT OF cursor_actual;  
						
					COMMIT WORK;
				END FOREACH; 
				
				IF (v_reverso <> '0') THEN        
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				LET v_codigo_retorno = "00000";
				LET v_mensaje = "Proceso Pase de Boletos, Termino Correctamente!";
				LET v_reverso = '0';         
				LET v_store_pro = 'sp_traslada_boletos';    

				-- BGM 08-Nov-2010: se cambia de posición el FOREACH para que al final haga el traslado a si_boleto_hist, 
				-- pero sin borrar los datos de si_boleto porque los necesitará el sp_detalle_boletos

				FOREACH cursor_inserta WITH HOLD FOR
					SELECT  {+index (si_boleto idx_si_boleto)}numcte, foliosuc
						INTO vc_numcte, v_foliosuc
					--INTO vrowid            
					FROM bdinteg:"informix".si_boleto
					WHERE date(f_registro) = vd_valida 
					AND numcte <> ''
					
					BEGIN WORK;
					
					INSERT INTO --{+index (si_boleto_hist idx_si_boleto_hist)} 
					bdinteg:"informix".si_boleto_hist
					SELECT {+index (si_boleto idx_si_boleto)} *
					FROM bdinteg:"informix".si_boleto
					WHERE numcte = vc_numcte
					  AND foliosuc = v_foliosuc;                                                                 
				COMMIT WORK;                           
				END FOREACH;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "¡EL SORTEO NAVIDEÑO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	END IF;			
    
    END;   --begin        
    
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
    
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE MODIFICACIÓN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_replica_indicadores_ctes_bi(iIndicador INTEGER,dFechaProceso DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE iNomErr          INTEGER;
DEFINE iNanErr          INTEGER;
DEFINE iEnTransaccion   SMALLINT;
DEFINE cProceso			CHAR(100);
DEFINE cEvento			CHAR(100);

--DEFINE dFechaproceso    DATE;
DEFINE dFechahoy        DATETIME YEAR TO FRACTION;
DEFINE dFechafin        DATETIME YEAR TO FRACTION;
DEFINE dnregsCb         DECIMAL(18,0);
DEFINE dnregsStg        DECIMAL(18,0);
DEFINE dnregsDif        DECIMAL(18,0);
DEFINE dncontaCb        DECIMAL(18,0);
DEFINE dncontaStg       DECIMAL(18,0);
DEFINE dncontaDif       DECIMAL(18,0);


--ASIGNACION DE VARIABLES
LET cProceso = '';
LET cEvento = '';
LET dFechahoy = CURRENT::DATE;
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO DE REPLICA DE ESTADISTICAS SE A GENERADO CORRECTAMENTE';

--SET DEBUG FILE TO "/tmp/ALAN/MANTENIMIENTOREPLICAS/basededatos/bdinteg/sp/sp_replica_estadisticas_ctes_bi.out";
--TRACE ON;

BEGIN
     --Manejo del error
		ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
			LET cEvento = 'MANEJO DE EXCEPCIONES';
			IF iNomErr <> 0 THEN
				LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN

					ROLLBACK;

					SELECT DBINFO('utc_to_datetime',sh_curtime)
					INTO dFechafin
					FROM sysmaster:"informix".sysshmvals;
					--UPDATE bdibi@coppel_tcp:"informix".bi_controlprocesos
					UPDATE bdibi@stag_ids1170:"informix".bi_controlprocesos
					SET maxfecha_cargada = dFechaproceso, flagfinalizado = 'F', coderror = vCodRet, msgerror = cMensCodRet, fecha_cargafin = dFechafin
                    WHERE id_proc = iIndicador
                    AND fecha_carga = dFechaProceso;

			    END IF;

				INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, vCodret, cMensCodRet);

				RETURN vCodRet, cMensCodRet;
		    END IF;
		END EXCEPTION;

		LET cProceso = 'PRINCIPAL';
		LET cEvento = 'VALIDACION DE PARAMETROS';

		IF dFechaproceso IS NULL OR dFechaproceso = '' THEN
			LET vCodRet = '000001';
			LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
			RETURN vCodRet, cMensCodRet;
		ELIF iIndicador IS NULL OR  iIndicador ='' THEN
			LET vCodRet = '000002';
			LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
			RETURN vCodRet, cMensCodRet;
		ELIF iIndicador <> '2' AND iIndicador <> '101' THEN
			LET vCodRet = '000003';
			LET cMensCodRet = 'PARAMETRO INCORRECTO';	
			RETURN vCodRet, cMensCodRet;
		END IF;

		LET cEvento = 'OBTENCION DE FECHA-HORA DE INICIO DE REPLICA';
		SELECT DBINFO('utc_to_datetime',sh_curtime)
		INTO dFechahoy
		FROM sysmaster:"informix".sysshmvals;

		LET cEvento = 'GUARDA INFORMACION INICIAL EN bi_controlprocesos';
		
	IF iIndicador = 2 THEN
					
			--INSERT INTO bdibi@coppel_tcp:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
			INSERT INTO bdibi@stag_ids1170:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
	                                                           maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaproceso,iIndicador, 'bdinteg:sp_replica_estadisticas_ctes_bi', dFechahoy, NULL, NULL, 'F', NULL, NULL);
	

		BEGIN WORK;
			LET iEnTransaccion = 1;

			LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN si_indicadores_ctes_nvos_det';
			SELECT COUNT (*)
			INTO dnregsCb
			FROM bdinteg:"informix".si_indicadores_ctes_nvos_det
			WHERE fecha = dFechaproceso;

			LET cEvento = 'CALCULO DE TOTALES GLOBALES EN si_indicadores_ctes_nvos_det';
			SELECT COUNT (*)
			INTO dncontaCb
			FROM bdinteg:"informix".si_indicadores_ctes_nvos_det;

			LET cEvento = 'INSERCION DE REGISTROS EN LA TABLA bdibi:bi_indicadores_ctes_nvos_det';
			--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut,
			INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut,
																altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep,
																telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep,
																telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep,
																telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
			SELECT a.tipo_movto, a.fecha, a.sucursal, b.nom_suc, a.ejecutivo, b.nom_emp,
				   a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
				   a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
				   a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
				   a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep
			FROM  bdinteg:si_indicadores_ctes_nvos_det a , si_tmp_sucursal_ejecut b
			WHERE a.ejecutivo = b.ejecutivo
			AND a.sucursal = b.sucursal
			AND a.fecha = dFechaproceso;
	
			
			LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN bi_indicadores_ctes_nvos_det';
			SELECT COUNT (*)
			INTO dnregsStg
			--FROM bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det
			FROM bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det	
			WHERE fecha = dFechaproceso;

			LET dnregsDif = dnregsCb - dnregsStg;

			LET cEvento = 'CALCULO DE TOTALES GLOBALES EN bi_indicadores_ctes_nvos_det';
		    SELECT COUNT (*)
			INTO dncontaStg
			--FROM bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det;
			FROM bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det;

			LET dncontaDif = dncontaCb - dncontaStg;

			LET cEvento = 'GUARDA INFORMACION bi_cifras_control';
			--INSERT INTO bdibi@coppel_tcp:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
			INSERT INTO bdibi@stag_ids1170:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
	                                                            nconta_cb, nconta_stg, nconta_dif, import_cb, import_stg, import_dif, nombre_sp)
			VALUES (dFechaproceso,iIndicador, 'ESTADISTICAS DE CLIENTES', CURRENT::DATE, dnregsCb, dnregsStg, dnregsDif, dncontaCb, dncontaStg, dncontaDif, 0, 0, 0,'bdinteg:sp_replica_estadisticas_ctes_bi');

			LET cEvento = 'OBTENCION DE FECHA-HORA FINAL DE REPLICA';
			SELECT DBINFO('utc_to_datetime',sh_curtime)
			INTO dFechafin
			FROM sysmaster:"informix".sysshmvals;

			LET cEvento = 'GUARDA INFORMACION FINAL EN bi_controlprocesos';
			--UPDATE bdibi@coppel_tcp:"informix".bi_controlprocesos
			UPDATE bdibi@stag_ids1170:"informix".bi_controlprocesos
			SET maxfecha_cargada = dFechaproceso, flagfinalizado = 'V', coderror = vCodRet, msgerror = cMensCodRet, fecha_cargafin = dFechafin
            WHERE id_proc = iIndicador
            AND fecha_carga = dFechaProceso;

		COMMIT WORK;
		LET iEnTransaccion = 0;

	ELSE
		IF iIndicador = 101 THEN
		
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
				INSERT INTO bdibi@stag_ids1170:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
	                                                           maxfecha_cargada, flagfinalizado, coderror, msgerror)
				VALUES (dFechaproceso,iIndicador, 'bdinteg:sp_replica_estadisticas_ctes_bi', dFechahoy, NULL, NULL, 'F', NULL, NULL);
	

			BEGIN WORK;
				LET iEnTransaccion = 1;

				LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN si_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dnregsCb
				FROM bdinteg:"informix".si_indicadores_kiosko
				WHERE fecha_proceso = dFechaproceso;

				LET cEvento = 'CALCULO DE TOTALES GLOBALES EN si_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dncontaCb
				FROM bdinteg:"informix".si_indicadores_kiosko;

				LET cEvento = 'INSERCION DE REGISTROS EN LA TABLA bdibi:bi_indicadores_kiosko';
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal,nombre_suc ,cons_movimientos, cons_saldos, cons_edocta, user_insert)
				INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal,nombre_suc,cons_movimientos, cons_saldos, cons_edocta, user_insert)
				SELECT a.fecha_proceso, a.sucursal, b.nombre,a.cons_movimientos, a.cons_saldos, a.cons_edocta, USER
				FROM  bdinteg:si_indicadores_kiosko a,bdinteg:si_sucursales b
				WHERE fecha_proceso = dFechaproceso
				AND   a.sucursal = b.sucursal;
			

			
				LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN bi_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dnregsStg
				--FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko
				FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko	
				WHERE fecha_proceso = dFechaproceso;

				LET dnregsDif = dnregsCb - dnregsStg;

				LET cEvento = 'CALCULO DE TOTALES GLOBALES EN bi_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dncontaStg
				--FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko;
				FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko;

				LET dncontaDif = dncontaCb - dncontaStg;

				LET cEvento = 'GUARDA INFORMACION bi_cifras_control';
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
				INSERT INTO bdibi@stag_ids1170:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
	                                                            nconta_cb, nconta_stg, nconta_dif, import_cb, import_stg, import_dif, nombre_sp)
				VALUES (dFechaproceso, iIndicador, 'ESTADISTICAS DE CLIENTES', CURRENT::DATE, dnregsCb, dnregsStg, dnregsDif, dncontaCb, dncontaStg, dncontaDif, 0, 0, 0,'bdinteg:sp_replica_estadisticas_ctes_bi');

				LET cEvento = 'OBTENCION DE FECHA-HORA FINAL DE REPLICA';
				SELECT DBINFO('utc_to_datetime',sh_curtime)
				INTO dFechafin
				FROM sysmaster:"informix".sysshmvals;

				LET cEvento = 'GUARDA INFORMACION FINAL EN bi_controlprocesos';
				--UPDATE bdibi@coppel_tcp:"informix".bi_controlprocesos
				UPDATE bdibi@stag_ids1170:"informix".bi_controlprocesos
				SET maxfecha_cargada = dFechaproceso, flagfinalizado = 'V', coderror = vCodRet, msgerror = cMensCodRet, fecha_cargafin = dFechafin
				WHERE id_proc = iIndicador
				AND fecha_carga = dFechaProceso;

			COMMIT WORK;
				LET iEnTransaccion = 0;
		
		END IF;
	END IF;
				RETURN vCodRet, cMensCodRet;

END;

END PROCEDURE
DOCUMENT
'EQUIPO:AnÃ¡lisis y diseÃ±o de Mannto.4',
'FECHA:19/06/2015',
'VERSION:20150616',
'MODIFICO: Ingrid Pamela CÃ¡zarez Villegas',
'DESCRIPCION: Se realiza reporte de correos y telÃ©fonos capturatos en altas y mantenimiento de datos de clientes titulares';

CREATE PROCEDURE "informix".sp_traslada_boletos_pbai(p_cve_sorteo char(5), p_fecha_pase DATE)
RETURNING CHAR(5)  AS Codigo_retorno, 
          CHAR(80) AS Mensaje,
          CHAR(1)  AS Reverso,
          CHAR(25) AS StorePro;              
               
    DEFINE vsqlerr           INTEGER; 
    DEFINE v_codigo_retorno	CHAR(5);
    DEFINE v_mensaje	  	    CHAR(80);
    DEFINE v_reverso         CHAR(1);
    DEFINE v_store_pro       CHAR(25);
    DEFINE vrowid      INTEGER;
    DEFINE vd_valida   DATE;
    DEFINE vd_fecha2   DATE;
    DEFINE vd_fsorteo  DATE;
    DEFINE vc_numcte   CHAR(10);
    DEFINE vi_nociudadcoppel  INTEGER;
    DEFINE vi_nocoloniacoppel INTEGER;
    DEFINE vc_nomzonacoppel   CHAR(20);
    DEFINE vc_nomcuidad       CHAR(20);  
    DEFINE vc_nombre          CHAR(25);
    DEFINE vc_telef1          CHAR(10);
    DEFINE vc_telef2          CHAR(13);
    DEFINE vc_domicilio       CHAR(50);
    DEFINE vc_nomcalle        CHAR(20); 
    DEFINE vc_numextcalle     CHAR(10);
    DEFINE vc_nomcolonia      CHAR(20);
    DEFINE vc_nombre_cte   CHAR(45);
    DEFINE vc_cvesorteo    INTEGER;
	DEFINE v_foliosuc CHAR(16);
    DEFINE v_param		  CHAR(5);  -- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.

    --SET debug file TO "/tmp/traslada_boletos2.out";
    --TRACE ON;

    LET v_codigo_retorno = "00000";
    LET v_mensaje = "Proceso Inicia Correctamente";
    LET v_reverso = '0';
    LET v_store_pro = 'sp_traslada_boletos';
    LET vrowid     = 0;
    LET vd_valida  = (p_fecha_pase - 1 units day);
    LET vd_fsorteo = (vd_valida - 1 units day);

    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET LOCK MODE TO wait 3;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_traslada_boletos';
            RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
    END EXCEPTION;
	   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = p_cve_sorteo AND flag_sort = 2) THEN
					
				/*se agrega para optimizacion de busqueda*/
    
				-- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.
				SELECT valor 
				INTO v_param 
				FROM bdinteg:si_param
				WHERE cod_param = 118;
				
				SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
				INTO vc_cvesorteo
				FROM si_sorteo
				WHERE cve_sorteo = v_param;     -- FMV 21-Sep-10    
				
				IF NOT EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
								 FROM bdinteg:si_sorteo 
								WHERE cve_sorteo = v_param) THEN -- FMV 21-Sep-10 
					LET v_codigo_retorno = "00040";
					LET v_mensaje = "Se Genero Error en si_sorteo, No Existe Sorteo!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;   
				
				IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo
							 FROM bdinteg:si_sorteo
							WHERE cve_sorteo = v_param  -- FMV 21-Sep-10 
							  AND f_fin < vd_fsorteo) THEN                  
					LET v_codigo_retorno = "00042";
					LET v_mensaje = "Se Genero Error en si_sorteo, Sorteo No esta Vigente!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;
				
				--*********************************************************--
				-- Creado por: Francisco Martinez Viveros	
				--Fecha Creacion: 31/AGOSTO/2010
				--Fecha Modifica: 09/NOVIEMBRE/2010 
				--Objetivo: Traspasa los boletos generados diariamente y 
				--          los envia a la tabla historica con los datos del clte.    
				--*********************************************************--

				
				IF (p_fecha_pase is null) THEN
					LET v_codigo_retorno = "00030";
					LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				-- BGM 08-Nov-2010: se coloca en primera instancia el foreach para actualizar los datos del cliente 
				-- sobre la misma tabla si_boleto
				-- FOREACH 1 
				FOREACH cursor_actual WITH HOLD FOR              
					SELECT {+index (si_boleto idx_si_bol_clte)} fecha, numcte   --FMV 8-NOV-10: SE ADICIONA INDICE               
					INTO vd_fecha2, vc_numcte  
					FROM bdinteg:"informix".si_boleto 
					WHERE fecha = vd_valida 
					AND numcte > '0000000'

					BEGIN WORK;

					-- BGM 08-Nov-2010: se coloca query optimizado por Faviola Martínez.
					-- FMV 09-Nov-2010: Query filtrado por Faviola Martínez, con aquellos Clientes q no tienen datos completos.

					SELECT {+index (SI_CATCALLES idx_catcalles)}
							CAT.numerociudadcoppel,CAT.numerocoloniacoppel,CAT.nombrezonacoppel, 
							CIU.NOMBRECIUDAD, SCA.NOMBRECALLE, SE.nombre,tel1.telefono, tel2.telefono,
							dom.numeroextcalle, CAT.nombrezona    
					  INTO vi_nociudadcoppel, vi_nocoloniacoppel, vc_nomzonacoppel, vc_nomcuidad,
							vc_nomcalle, vc_nombre, vc_telef1, vc_telef2, vc_numextcalle,
							vc_nomcolonia
					FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
					LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
					LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
					LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
					LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado   = SE.ESTADO )
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1)
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2)
					WHERE DOM.NUMCTE = vc_numcte 
					-- AND DOM.SECUENCIA IN (SELECT MAX(SID.SECUENCIA) FROM BDINTEG:SI_DIRECCIONES_ACTUAL SID WHERE SID.NUMCTE = DOM.NUMCTE AND SID.TIPO_DIR = 1 ) 
					AND DOM.TIPO_DIR  = 1;
					
					--FMV: Se Adiciona validacion para los telefonos por si el dato en null
					IF (vc_telef1 IS NULL) OR (vc_telef1= '') THEN 
						LET vc_telef1 = '0';
					END IF;
					
					IF (vc_telef2 IS NULL) OR (vc_telef2= '') THEN 
						LET vc_telef2 = '0';
					END IF;
					
					LET vc_nombre_cte = (SELECT trim(nombre1)||' '||   
												trim(nombre2)||' '||    
												trim(apell_paterno)||' '|| 
												trim(apell_materno)                                            
												FROM bdinteg:si_cliente WHERE numcte = vc_numcte);    
												
					LET vc_domicilio =  trim(vc_nomcalle)||' '||
										trim(vc_numextcalle)||' '||                                                                      
										trim(vc_nomcolonia);
				
					-- BGM 08-Nov-2010: se hace el update sobre si_boleto en lugar de si_boleto_hist
					UPDATE bdinteg:"informix".si_boleto        --{+index (si_mensajes_enviar_his idx_msgs_envhis)}
					SET telefono1 = vc_telef1,
						telefono2 = vc_telef2,
						nombre    = vc_nombre_cte,
						ciudad    = vc_nomcuidad,
						domicilio = vc_domicilio,
						ent_fed = vc_nombre --SE AGREGA PARA GUARDARSE EN LA TABLA
					WHERE CURRENT OF cursor_actual;  
						
					COMMIT WORK;
				END FOREACH; 
				
				IF (v_reverso <> '0') THEN        
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				LET v_codigo_retorno = "00000";
				LET v_mensaje = "Proceso Pase de Boletos, Termino Correctamente!";
				LET v_reverso = '0';         
				LET v_store_pro = 'sp_traslada_boletos';    

				-- BGM 08-Nov-2010: se cambia de posición el FOREACH para que al final haga el traslado a si_boleto_hist, 
				-- pero sin borrar los datos de si_boleto porque los necesitará el sp_detalle_boletos

				FOREACH cursor_inserta WITH HOLD FOR
					SELECT  {+index (si_boleto idx_si_boleto)}numcte, foliosuc
						INTO vc_numcte, v_foliosuc
					--INTO vrowid            
					FROM bdinteg:"informix".si_boleto
					WHERE date(f_registro) = vd_valida 
					AND numcte <> ''
					
					BEGIN WORK;
					
					INSERT INTO --{+index (si_boleto_hist idx_si_boleto_hist)} 
					bdinteg:"informix".si_boleto_hist
					SELECT {+index (si_boleto idx_si_boleto)} *
					FROM bdinteg:"informix".si_boleto
					WHERE numcte = vc_numcte
					  AND foliosuc = v_foliosuc;                                                                 
				COMMIT WORK;                           
				END FOREACH;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "¡EL SORTEO NAVIDEÑO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	END IF;			
    
    END;   --begin        
    
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
    
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE MODIFICACIÓN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_dispersionlinea_bpi(pidempresa CHAR(3),pnumcte CHAR(9),pnombrearchivo CHAR(20),pSucursal CHAR(10),pUsuario CHAR(10),pTransaccionIva CHAR(5),pTransaccionCargo CHAR(5),pFolioSuc CHAR(20),pCuenta CHAR(20),pIvaDisp MONEY(14,2),pCargoDisp MONEY(14,2))
returning char(5);

--Realizó: Jose Ruben Lopez Hernadez
--Fecha: 26/03/2013
--Actividad:Se unifico la ejecucion de los sp de cargo de iva y de comision 
--BD:bdicheq.

    DEFINE vsqlerr          INTEGER;
    DEFINE vcodret          CHAR(5);
	DEFINE vcodret2         CHAR(5);
	DEFINE vcodret3         CHAR(5);
	DEFINE vcodret4         CHAR(5);
	DEFINE vcodret5         CHAR(5);
	DEFINE vcodret6         CHAR(5);
	DEFINE cFolio 			CHAR(16);
	DEFINE cMensaje 		CHAR(50);
	DEFINE cTransacCargo    CHAR(4);
	DEFINE dFechacargo      DATE;
	DEFINE mSaldoEje        MONEY(14,2);
	DEFINE mRedondeo        MONEY(18,5);
	DEFINE mDispLinea		MONEY;
	DEFINE mMontoTransIvaDisp	MONEY(16,2);
	DEFINE cProducto	 CHAR(4);
	DEFINE cTpoPersona	 CHAR(1);
	
	LET vsqlerr = 0;
    LET vcodret = "00000";
	LET vcodret2 = "00000";
	LET vcodret3="00000";
	LET vcodret4="00000";
	LET vcodret5="00000";
	LET vcodret6="00000";
	LET cFolio = '';
	LET cMensaje = " ";
	LET cTransacCargo='';
	LET dFechacargo='';
	LET mSaldoEje=0;
	LET mRedondeo=0;
	LET mDispLinea = 0.0;
	LET mMontoTransIvaDisp = 0;
	LET cProducto	 = "";
	LET cTpoPersona	 = "";
	
	--SET debug FILE TO "/tmp/sp_dispersionlinea_bpi_2.out";
	--Trace ON;
	

    BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
			INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,CURRENT);
            RETURN vcodret;
        END IF;
    END EXCEPTION;

	--SET debug FILE TO "/informix/moha/sp_dispersionlinea_bpi.out";
	--Trace ON;

	
    CALL "informix".sp_cargadividearchivonomina_bpi(pnombrearchivo)
		RETURNING vcodret, cFolio, cMensaje;

    IF 	vcodret <> "00000" THEN		
		LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_cargadividearchivonomina_bpi)';
	ELSE
		SELECT producto
		INTO cProducto
		FROM "informix".sc_maechq
		WHERE empresa = "001"
		AND cuenta = pCuenta;
		   
		SELECT tpper_valida
		INTO cTpoPersona
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = "001" 
		AND producto = cProducto;
		
		IF cTpoPersona IN ("2","4","5") AND cProducto <> "2600" THEN
			-- OBTIENE EL IVA
			SELECT valor
			INTO mMontoTransIvaDisp
			FROM bdinteg:"informix".si_param
			WHERE cod_param = 47
			AND empresa = "001";
			--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
			SELECT disp_linea
			INTO mDispLinea
			FROM "informix".sc_maecomtasserv_pm
			WHERE cuenta = pCuenta;
			
			IF mDispLinea IS NOT NULL THEN
				LET pCargoDisp = mDispLinea;
				LET pIvaDisp = pCargoDisp * mMontoTransIvaDisp;
				LET pTransaccionIva = "0260";
				LET pTransaccionCargo = "3255";
			END IF
		END IF
	
		IF pCargoDisp <> 0 THEN--bandera ejecutar los cargos					
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionIva,'',pFolioSuc,pCuenta,0,pIvaDisp,'01','','','')
					INTO vcodret4,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
					IF vcodret4="000" THEN
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionCargo,'',pFolioSuc,pCuenta,0,pCargoDisp,'01','','','')	
							INTO vcodret5,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
							IF vcodret5="000" THEN
								CALL bdicheq:"informix".sp_dispercionnomina_bpi() returning vcodret2;
								IF vcodret2 = "000" THEN 
									LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE CC';
								ELSE
									EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
									INTO vcodret6;	
									LET vcodret = vcodret2;
									LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
								END IF
							ELSE
								EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
								INTO vcodret6;	
								LET vcodret = vcodret5;
								LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref CARGO)';	
							END IF
					ELSE
						LET vcodret = vcodret4;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref IVA)';	
					END IF
		ELSE--No se ejecutan los cargos
			CALL "informix".sp_dispercionnomina_bpi() returning vcodret2;
					IF vcodret2 = "000" THEN 
						LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE SC';
					ELSE
						LET vcodret = vcodret2;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
					END IF

		END IF
	END IF;

	INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,current);
    RETURN vcodret;
    END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_get_indicadores_idbox(dFechaProceso DATE, cTipoRp CHAR(2),  iIdRp INTEGER)
			
		--DEFINICION DE VARIABLES
	DEFINE cCodRet          CHAR(6);
	DEFINE cMensaje      	CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	
	DEFINE iAltasTotal		INTEGER;
	DEFINE iTotIdb			INTEGER;
	DEFINE cSucursal		CHAR(5);
	DEFINE iNoRegistros		INTEGER;
	DEFINE cCodRetSp 		CHAR(5);
	DEFINE iCodRetSp 		INTEGER;
	DEFINE cFlag			CHAR(1);

	
	DEFINE cProceso			CHAR(100);
	DEFINE cEvento			CHAR(100);
	DEFINE bEnTransaccion	BOOLEAN;
	
	--ASIGNACION DE VARIABLES
	LET cCodRet 		= '000000';
	LET cMensaje 		= 'PROCESO EXITOSO';
	LET iSqlErr 		= 0;
	LET cCodRetSp       = '';
	LET iCodRetSp 		= 0;
	LET cSucursal = 	'';
	LET cFlag 				 = '';
	
	LET iAltasTotal		= 0;
	LET iTotIdb			= 0;
	LET iNoRegistros	= 0;


--SET DEBUG FILE TO '/tmp/ALAN/SOC/sp_get_indicadores_idbox_prueba.out';
--TRACE ON;

LET bEnTransaccion = 'f';
BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';
				END IF;
				
				UPDATE si_controlproc_indicadores
				SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
					maxfecha_cargada = '',
					flagfinalizado = 'F',
					coderror = cCodRet, 
					msgerror = cMensaje
				WHERE tipo = cTipoRp 
					AND  id_proc = iIdRp
					AND fecha_procesoIni = dFechaProceso 
					AND fecha_procesoFin = dFechaProceso;
					
				INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, cCodRet, cMensaje);				
			END IF;
		END EXCEPTION;
		
	LET cProceso = 'INDICADORES DE IDBOX';	
	LET cEvento = 'VALIDACION DE PARAMETROS';
	
	IF NVL(dFechaProceso,' ') = ' ' THEN
		LET cCodRet = '000001';
		LET cMensaje = 'FECHA INVALIDA';
	ELIF NVL(cTipoRp,' ') = ' ' THEN
		LET cCodRet = '000002';
		LET cMensaje = 'TIPO INDICADOR INVALIDO';
	ELIF NVL(iIdRp,0) = 0 THEN
		LET cCodRet = '000003';
		LET cMensaje = 'ID INDICADOR INVALIDO';
	ELIF NOT EXISTS (SELECT 1 FROM si_proc_indicadores WHERE  tipo = cTipoRp AND  identificador = iIdRp) THEN
		LET cCodRet = '000004';
		LET cMensaje = 'INDICADOR NO REGISTRADO EN SI_PROC_INDICADORES';	
	ELIF EXISTS (SELECT 1 FROM si_proc_indicadores WHERE estatus_proceso = 'I' AND tipo = cTipoRp AND  identificador = iIdRp) THEN
		LET cCodRet = '000005';
		LET cMensaje = 'INDICADOR INACTIVO';
	END IF;	
	
	
	LET cEvento = 'CONSULTA ESTATUS EN SI_CONTROLPROC_INDICADORES';
	SELECT flagfinalizado INTO  cFlag
	FROM  si_controlproc_indicadores 
	WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;

	IF NVL(cFlag,'') = '' THEN
		INSERT INTO si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
		VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );
	END IF;
	
	IF cCodRet::INTEGER = 0 THEN
		BEGIN WORK;
			LET bEnTransaccion = 't';
				
			IF NOT EXISTS(SELECT 1 FROM si_tmp_alta_ctes_titulares WHERE fecha_alta = dFechaproceso) THEN
				LET cEvento = 'GENERACION DE INFORMACION TEMPORAL DE CLIENTES TITULARES';
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				INSERT INTO si_tmp_alta_ctes_titulares
				SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, a.ejecutivo AS numemp, a.fecha_insert
				FROM bdinteg:"informix".si_cliente a INNER JOIN bdinteg:"informix".si_ctepf b
				ON a.numcte = b.numcte	
				WHERE a.fecha_insert = dFechaProceso
				AND a.tipo_cliente='1';
			END IF;
					
			LET cEvento = 'INSERCESION DE DATOS A LA TABLA si_indicadores_idbox ';		
	
		FOREACH 
			SELECT a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb
			INTO cSucursal,iAltasTotal,iTotIdb
            FROM si_sucursales a
            LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE si_tmp_alta_ctes_titulares EN UN RANGO DE FECHAS
							SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total, clientes.fecha_alta FROM  
                            (SELECT distinct (numcte), sucursal,fecha_alta 
                            FROM si_tmp_alta_ctes_titulares
							WHERE fecha_alta = dFechaProceso) clientes
							INNER JOIN
                        --OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
                            (SELECT numcte, sucursal 
                            FROM si_bitacora_ife
                            WHERE date(fecha) = dFechaProceso) bitacora
							ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
							GROUP BY clientes.sucursal,clientes.fecha_alta
					 ) b 	ON a.sucursal=b.sucursal
            LEFT JOIN(--OBTENIENDO ALTAS POR SUCURSAL
							SELECT sucursal, COUNT(DISTINCT (numcte)) AS total
							FROM si_tmp_alta_ctes_titulares
							WHERE fecha_alta = dFechaProceso
							GROUP BY sucursal
                     )C 	ON a.sucursal=C.sucursal
            WHERE a.sucursal IN (SELECT DISTINCT(sucursal) FROM si_bitacora_ife)
				
	
			IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_indicadores_idbox WHERE fecha_proceso = dFechaproceso AND sucursal = cSucursal) THEN
				LET cEvento = 'INSERCION DE INDICADORES EN SI_INDICADORES_IDBOX';
				INSERT INTO si_indicadores_idbox (fecha_proceso,sucursal,altas_total,total_idb,user_insert,fecha_insert)
				VALUES(dFechaProceso,cSucursal,iAltasTotal,iTotIdb,USER,(SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
			ELSE
				LET cEvento = 'ACTUALIZACION DE INDICADORES EN SI_INDICADORES_IDBOX';
				
				UPDATE bdinteg:si_indicadores_idbox
				SET sucursal = cSucursal, 
				altas_total = iAltasTotal, 
				total_idb = iTotIdb, 
				fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
				WHERE fecha_proceso = dFechaproceso AND sucursal = cSucursal;
			END IF;		
		END FOREACH;	

		COMMIT WORK;	

		LET bEnTransaccion = 'f';

	END IF;
	
		UPDATE si_controlproc_indicadores
		SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
			maxfecha_cargada = DECODE (cCodRet,'000000',dFechaProceso,NULL),
			flagfinalizado = DECODE (cCodRet,'000000','V','F'),
			coderror = cCodRet, 
			msgerror = cMensaje
		WHERE tipo = cTipoRp 
			AND  id_proc = iIdRp
			AND fecha_procesoIni = dFechaProceso 
			AND fecha_procesoFin = dFechaProceso;		
		
	END;
END PROCEDURE
DOCUMENT
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:28/10/2016',
'DESCRIPCION: SPL que consulta altas idbox de Reporte Procesos Sucursal',	
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_get_indicadores_correo_rep(dFechaProceso DATE, cTipoRp CHAR(2),  iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);
	
	DEFINE iValidos	INTEGER;
	DEFINE iInvalidos	INTEGER;
	DEFINE iSin_validar	INTEGER;		
	DEFINE cCorreo_elec CHAR(100);
	DEFINE iCantidad	INTEGER;
	DEFINE cSucursal	CHAR(4);
	DEFINE cUsuario		CHAR(8);
	
	DEFINE cFlag	CHAR(1);
	DEFINE bEnTransaccion	BOOLEAN;
	
	DEFINE cFechaProceso	CHAR(11);
		
	LET cCodRet = '000000';
	LET cMensaje = 'PROCESO EXITOSO';
	
	LET iValidos = 0;
	LET iInvalidos = 0;
	LET iSin_validar = 0;
	LET cCorreo_elec = '';
	LET iCantidad = 0;
	LET cSucursal = '';
	LET cUsuario = '';

	LET cFlag = '';
	LET bEnTransaccion = 'f';
	
	LET cFechaProceso = '';
	
	--SET DEBUG FILE TO '/informix/jagl/bdinteg/sp_get_indicadores_correo_rep.out';
	--TRACE ON;		
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';
				END IF;
				
				UPDATE si_controlproc_indicadores
				SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
					maxfecha_cargada = '',
					flagfinalizado = 'F',
					coderror = cCodRet, 
					msgerror = cMensaje
				WHERE tipo = cTipoRp 
					AND  id_proc = iIdRp
					AND fecha_procesoIni = dFechaProceso 
					AND fecha_procesoFin = dFechaProceso;
					
				INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, cCodRet, cMensaje);				
			END IF;
		END EXCEPTION;
		
		SELECT nombre_proceso 
		INTO cProceso
		FROM si_proc_indicadores
		WHERE tipo = cTipoRp AND identificador = iIdRp;
		
		--LET cProceso = 'INDICADORES DE CORREOS REPETIDOS';
		LET cEvento = 'VALIDACION DE PARAMETROS';
		
		IF NVL(dFechaProceso,' ') = ' ' THEN
			LET cCodRet = '000001';
			LET cMensaje = 'FECHA INVALIDA';
		ELIF NVL(cTipoRp,' ') = ' ' THEN
			LET cCodRet = '000002';
			LET cMensaje = 'TIPO INDICADOR INVALIDO';
		ELIF NVL(iIdRp,0) = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'ID INDICADOR INVALIDO';
		ELIF NOT EXISTS (SELECT 1 FROM si_proc_indicadores WHERE  tipo = cTipoRp AND  identificador = iIdRp) THEN
			LET cCodRet = '000004';
			LET cMensaje = 'INDICADOR NO REGISTRADO EN SI_PROC_INDICADORES';	
		ELIF EXISTS (SELECT 1 FROM si_proc_indicadores WHERE estatus_proceso = 'I' AND tipo = cTipoRp AND  identificador = iIdRp) THEN
			LET cCodRet = '000005';
			LET cMensaje = 'INDICADOR INACTIVO';
		END IF;
		
		LET cFechaProceso = (TO_CHAR(dFechaproceso, '%Y-%m-%d')) || '%';

		LET cEvento = 'CONSULTA ESTATUS EN SI_CONTROLPROC_INDICADORES';
		SELECT flagfinalizado INTO  cFlag
		FROM  si_controlproc_indicadores 
		WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;

		IF NVL(cFlag,'') = '' THEN
			INSERT INTO si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );
			
		END IF;

		IF cCodRet::INTEGER = 0 THEN
			BEGIN WORK;
			LET bEnTransaccion = 't';
						
				--IF NOT EXISTS (SELECT 1 FROM bdinteg:si_estadistica_correos WHERE fecha = dFechaProceso) THEN
					LET cEvento = 'VALIDACION DE TABLA TEMPORAL';
					
					IF NOT EXISTS(SELECT 1 FROM si_tmp_alta_ctes_titulares WHERE fecha_alta = dFechaproceso) THEN
						LET cEvento = 'GENERACION DE INFORMACION TEMPORAL';
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;	
						INSERT INTO si_tmp_alta_ctes_titulares
						SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
						FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
						WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaproceso 
						AND a.tipo_cliente='1';
					END IF;
				
					LET cEvento = 'OBTENCION DE INDICADORES DE SI_CORREOS';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					SELECT NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
					INTO iValidos, iInvalidos, iSin_validar
					FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} 
												CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) END AS validos,
												CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) END AS invalidos,
												CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) END AS sin_validar
										FROM bdinteg:"informix".si_correos a, bdinteg:si_tmp_alta_ctes_titulares b
										WHERE a.numcte=b.numcte
										AND a.status_correo='A'
										AND b.fecha_alta= dFechaproceso
										--AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = b.fecha_alta
										AND a.fecha_hora like cFechaProceso
										GROUP BY a.valido)));
										
					IF NOT EXISTS (SELECT 1 FROM bdinteg:si_estadistica_correos WHERE fecha = dFechaProceso) THEN
						LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS';
						INSERT INTO bdinteg:"informix".si_estadistica_correos(fecha, total, valido,invalido,sin_validar, user_insert, fecha_insert)
						VALUES(dFechaproceso, (NVL(iValidos,0)+ NVL(iInvalidos,0)+ NVL(iSin_validar,0)), NVL(iValidos,0), NVL(iInvalidos,0), NVL(iSin_validar,0), USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
					ELSE
						LET cEvento = 'ACTUALIZACION DE INDICADORES EN SI_ESTADISTICA_CORREOS';
						UPDATE bdinteg:si_estadistica_correos
						SET total = (NVL(iValidos,0)+ NVL(iInvalidos,0)+ NVL(iSin_validar,0)),
							valido = NVL(iValidos,0),
							invalido = NVL(iInvalidos,0),
							sin_validar = NVL(iSin_validar,0),
							fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
						WHERE fecha = dFechaProceso;
					END IF;
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					FOREACH 
						SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_ctetipcorrstat)} b.correo_elec, COUNT(*) AS cantidad, a.sucursal, a.numemp
						INTO cCorreo_elec, iCantidad, cSucursal, cUsuario
						FROM bdinteg:si_tmp_alta_ctes_titulares a, bdinteg:"informix".si_correos b
						WHERE a.numcte=b.numcte
						AND a.fecha_alta= dFechaproceso
						--AND b.fecha_hora::DATETIME YEAR TO FRACTION::DATE = a.fecha_alta
						AND b.fecha_hora like cFechaProceso
						AND b.status_correo='A'
						GROUP BY 1,3,4
						HAVING COUNT(*) > 1
						
						IF NOT EXISTS (SELECT 1 FROM bdinteg:si_estadistica_correos_repetidos WHERE correo_elec = cCorreo_elec AND fecha = dFechaProceso AND sucursal = cSucursal AND usuario = cUsuario) THEN
							LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_REPETIDOS';
							INSERT INTO bdinteg:"informix".si_estadistica_correos_repetidos(correo_elec, cantidad, sucursal, usuario, fecha, user_insert, fecha_insert)
							VALUES (cCorreo_elec, iCantidad, cSucursal, cUsuario, dFechaProceso, USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
						ELSE
							LET cEvento = 'ACTUALIZACION DE INDICADORES EN SI_ESTADISTICA_CORREOS_REPETIDOS';
							UPDATE bdinteg:si_estadistica_correos_repetidos
							SET cantidad = iCantidad,
								fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
							WHERE correo_elec = cCorreo_elec 
								AND fecha = dFechaProceso 
								AND sucursal = cSucursal 
								AND usuario = cUsuario;
						END IF;
					END FOREACH;
					
					/*SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_REPETIDOS';
					INSERT INTO bdinteg:"informix".si_estadistica_correos_repetidos(correo_elec, cantidad, sucursal, usuario, fecha, user_insert, fecha_insert)
					SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_ctetipcorrstat)} b.correo_elec, COUNT(*) AS cantidad, a.sucursal, a.user_insert, a.fecha_alta, USER, CURRENT
					FROM bdinteg:si_tmp_alta_ctes_titulares a, bdinteg:"informix".si_correos b
					WHERE a.numcte=b.numcte
					AND a.fecha_alta= dFechaproceso
					AND b.fecha_hora::DATETIME YEAR TO FRACTION::DATE = a.fecha_alta
					AND b.status_correo='A'
					GROUP BY 1,3,4,5
					HAVING COUNT(*) > 1;*/
				--END IF;

			COMMIT WORK;
			LET bEnTransaccion = 'f';
		END IF;

		UPDATE si_controlproc_indicadores
		SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
			maxfecha_cargada = DECODE (cCodRet,'000000',dFechaProceso,NULL),
			flagfinalizado = DECODE (cCodRet,'000000','V','F'),
			coderror = cCodRet, 
			msgerror = cMensaje
		WHERE tipo = cTipoRp 
			AND  id_proc = iIdRp
			AND fecha_procesoIni = dFechaProceso 
			AND fecha_procesoFin = dFechaProceso;
	END;
END PROCEDURE;
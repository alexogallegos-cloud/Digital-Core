CREATE PROCEDURE "informix".sp_get_actualizacion_bdiunica(dFechaProceso DATE, cTipoRp CHAR(2), iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);

	DEFINE iCorreopen	INTEGER;
	DEFINE iCorreoCap	INTEGER;
	DEFINE iPorcentCorreo INTEGER;
	DEFINE vcod_correoPen INTEGER;
	DEFINE iReplicaActiva	INTEGER;
	
	DEFINE cCodRetSP	CHAR(6);
	DEFINE cVarDataErrSP CHAR(100);
	
	DEFINE bEnTransaccion	BOOLEAN;
	DEFINE cFlag	CHAR(1);
	
	DEFINE cNumcte  CHAR(20);
    DEFINE cNumcteCoppel CHAR(20);
    DEFINE cSucursal CHAR(4);
    DEFINE dFecha_alta    	DATE;
    DEFINE cApell_paterno 	CHAR(26);
    DEFINE cApell_materno 	CHAR(26);
    DEFINE cNombre1       	CHAR(26);
    DEFINE cNombre2       	CHAR(26);
    DEFINE dFecha_nac     	DATE;
    DEFINE cEstado_civil  	CHAR(2);
    DEFINE cSexo          	CHAR(1);
    DEFINE cRfc           	CHAR(13);
    DEFINE cGrupo         	CHAR(3);
    DEFINE cSubgrupo      	CHAR(3);
    DEFINE cCalle         	CHAR(40);
    DEFINE cColonia       	CHAR(60);
    DEFINE cEstado        	CHAR(2);
    DEFINE cCiudad        	CHAR(3);
    DEFINE cMunicipio     	CHAR(5);
    DEFINE cCod_postal    	CHAR(5);
    DEFINE cNumeroextcalle	CHAR(10);
    DEFINE cNumerointcalle	CHAR(10);
    DEFINE cDepartamento  	CHAR(6);
    DEFINE smManzana       	SMALLINT;
    DEFINE smAndador       	SMALLINT;
    DEFINE smEtapa         	SMALLINT;
    DEFINE smLote          	SMALLINT;
    DEFINE smEdificio      	SMALLINT;
    DEFINE smEntrada       	SMALLINT;
    DEFINE cObservaciones 	CHAR(80);	
	   
    DEFINE cCorreo_elec  	CHAR(100);
    DEFINE cTipo_correo  	SMALLINT;
    DEFINE cStatus_correo	CHAR(1);
    DEFINE cValido       	CHAR(1);
	
    DEFINE cCasa      	VARCHAR(13);
    DEFINE cCelular   	VARCHAR(13);
    DEFINE cOficina   	VARCHAR(13);
    DEFINE cOtro      	VARCHAR(13);
    DEFINE cExtension 	CHAR(5);
    DEFINE cCarrier   	VARCHAR(30);
    DEFINE cStatus_tel	CHAR(1);
    DEFINE cCofetel   	CHAR(1);
    DEFINE cMovil_fijo	CHAR(1);
	
	DEFINE cFechaProceso	CHAR(11);
	
	LET cCodRet = '000000';
	LET cMensaje = 'PROCESO EXITOSO';
	
	
	LET bEnTransaccion = 'f';
	LET cFlag			= '';
	
	LET cFechaProceso = '';
	
	--SET DEBUG FILE TO '/informix/jagl/bdinteg/sp_get_actualizacion_bdiunica.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';					
				END IF;
				
				DROP TABLE IF EXISTS tmp_clientes;
				DROP TABLE IF EXISTS tmp_clientes_unica;
				DROP TABLE IF EXISTS tmp_correos_unica;
				DROP TABLE IF EXISTS tmp_telefonos_unica;
				
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
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		SELECT nombre_proceso 
		INTO cProceso
		FROM si_proc_indicadores
		WHERE tipo = cTipoRp AND identificador = iIdRp;
		
		LET cEvento = 'VALIDACION DE PARAMETROS RECIBIDOS';
		
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
		SELECT {+INDEX (bdinteg:si_controlproc_indicadores idx_controlproc_indicadores_01)} flagfinalizado INTO  cFlag
		FROM  si_controlproc_indicadores 
		WHERE id_proc = iIdRp AND tipo = cTipoRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;

		IF NVL(cFlag,'') = '' THEN
			INSERT INTO si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );			
		END IF;	
		
		IF cCodRet::INTEGER = 0 THEN
			BEGIN WORK;
			LET bEnTransaccion = 't';								
				
					
				LET cEvento = 'VALIDACION DE TABLA TEMPORAL CLIENTES TITULARES';
				DROP TABLE IF EXISTS tmp_clientes;
				
				SELECT DISTINCT b.numcte 
				FROM TABLE(MULTISET(SELECT    a.numcte
									FROM TABLE(MULTISET(SELECT  numcte
														FROM    bdinteg:"informix".si_cliente 
														WHERE   fecha_insert = dFechaProceso
														UNION ALL
														SELECT  numcte
														FROM    bdinteg:"informix".si_cte_huella
														WHERE   fecha_alta = dFechaProceso
														UNION ALL
														SELECT  numcte
														FROM    bdinteg:"informix".si_telefonos
														WHERE   (fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaProceso), DAY(dFechaProceso), YEAR(dFechaProceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaProceso), DAY(dFechaProceso), YEAR(dFechaProceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND) OR fecha_actualiza = dFechaProceso)
														UNION ALL
														SELECT  {+INDEX (bdinteg:si_direcciones_actual idx_diract_cte3)} numcte
														FROM    bdinteg:"informix".si_direcciones_actual
														WHERE   fecha_insert = dFechaProceso AND tipo_dir = 1
														UNION ALL
														SELECT  numcte
														FROM    bdinteg:"informix".si_correos
														--WHERE   fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaProceso
														WHERE   fecha_hora like cFechaProceso
														UNION ALL
														SELECT  numcte
														FROM    bdisolic:"informix".ss_solicitudes
														WHERE   fecha_insert = dFechaProceso
											  )) a
						  ))b
				INTO TEMP tmp_clientes WITH NO LOG;
					
				LET cEvento = 'VALIDACION DE TABLA TEMPORAL CLIENTES UNICA';
				DROP TABLE IF EXISTS tmp_clientes_unica;
				
				LET cEvento = 'GENERACION DE INFORMACION TEMPORAL CLIENTES UNICA';	
				SELECT	clie.numcte,cliente.numcte_ref as num_cte_coppel,cliente.sucursal,cliente.fecha_alta,cliente.apell_paterno,cliente.apell_materno,
						cliente.nombre1,cliente.nombre2,ctepf.fecha_nac,ctepf.estado_civil,ctepf.sexo,cliente.rfc,cliente.grupo,cliente.subgrupo,
						direccion.calle,direccion.colonia,direccion.estado,direccion.ciudad,direccion.municipio,direccion.cod_postal,direccion.numeroextcalle,direccion.numerointcalle,
						direccion.departamento,direccion.manzana,direccion.andador,direccion.etapa,direccion.lote,direccion.edificio,direccion.entrada,direccion.observaciones
				FROM 	bdinteg:tmp_clientes clie, bdinteg:"informix".si_cliente cliente, bdinteg:"informix".si_ctepf ctepf, bdinteg:"informix".si_direcciones_actual direccion
				WHERE 	clie.numcte = cliente.numcte
				AND		cliente.numcte = ctepf.numcte
				AND     cliente.numcte = direccion.numcte
				AND 	cliente.tipo_cliente = '1'
				AND		direccion.tipo_dir = '1'
				INTO TEMP tmp_clientes_unica WITH NO LOG;				
				
				
				LET cEvento = 'VALIDACION DE TABLA TEMPORAL CORREOS UNICA';
				DROP TABLE IF EXISTS tmp_correos_unica;
				
				LET cEvento = 'GENERACION DE INFORMACION TEMPORAL CORREOS UNICA';				
				SELECT	clie.numcte, cr.correo_elec, cr.tipo_correo, cr.status_correo, cr.valido
				FROM	bdinteg:tmp_clientes clie, bdinteg:"informix".si_correos cr
				WHERE	clie.numcte = cr.numcte
				AND     cr.status_correo = 'A'
				AND		cr.valido = '1'
				INTO TEMP tmp_correos_unica WITH NO LOG;

				
				
				LET cEvento = 'VALIDACION DE TABLA TEMPORAL TELEFONOS UNICA';
				DROP TABLE IF EXISTS tmp_telefonos_unica;
				
				LET cEvento = 'GENERACION DE INFORMACION TEMPORAL TELEFONOS UNICA';				
				SELECT  DISTINCT numcte, casa, celular, oficina, otro, extension, nom_carrier, status_tel, cofetel, movil_fijo
				FROM    TABLE(MULTISET(
									   SELECT  e.numcte, e.casa, e.celular, e.oficina, e.otro, e.extension, e.carrier,
											   (SELECT cr.nombre_carrier FROM bdinteg:"informix".si_carriers cr WHERE cr.cve_carrier = e.carrier) AS nom_carrier,
											   e.status_tel, e.cofetel, e.movil_fijo
									   FROM    (
												   SELECT   t.numcte, 
															MAX(DECODE (a.tipo_tel, 1, a.telefono)) AS casa, 
															MAX(DECODE (a.tipo_tel, 2, a.telefono)) AS celular, 
															MAX(DECODE (a.tipo_tel, 3, a.telefono)) AS oficina, 
															MAX(DECODE (a.tipo_tel, 4, a.telefono)) AS otro,
															(SELECT MAX(b.extension) FROM bdinteg:"informix".si_telefonos_actual b WHERE b.numcte = t.numcte AND b.tipo_tel = 4) AS extension,
															(SELECT MAX(d.carrier) FROM bdinteg:"informix".si_telefonos_actual d WHERE d.numcte =t.numcte) AS carrier,
															MAX(a.status_tel) AS status_tel,
															MAX(a.cofetel) AS cofetel,
															MAX(a.movil_fijo) AS movil_fijo
												   FROM     bdinteg:tmp_clientes t,
															bdinteg:"informix".si_telefonos_actual a                                            
												   WHERE    t.numcte = a.numcte
												   GROUP BY t.numcte 
											   ) e
									   ))
				INTO TEMP tmp_telefonos_unica WITH NO LOG;
				
				
				LET cEvento = 'ACTUALIZACION DE TABLA UNI_CLIENTE';
				FOREACH 
					SELECT	numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
							calle,colonia,estado,ciudad,municipio,cod_postal,numeroextcalle,numerointcalle, departamento,manzana,andador,etapa,lote,edificio,entrada,observaciones
					INTO 	cNumcte, cNumcteCoppel, cSucursal, dFecha_alta, cApell_paterno, cApell_materno, cNombre1, cNombre2, dFecha_nac, cEstado_civil, cSexo, cRfc, cGrupo, cSubgrupo,
							cCalle, cColonia, cEstado, cCiudad, cMunicipio, cCod_postal, cNumeroextcalle, cNumerointcalle, cDepartamento, smManzana, smAndador, smEtapa, smLote, smEdificio, smEntrada, cObservaciones
					FROM 	bdinteg:tmp_clientes_unica
					
					--IF EXISTS (SELECT numcte FROM bdiunica@coppelimg_tcp:uni_cliente WHERE numcte = cNumcte) THEN
					IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_cliente WHERE numcte = cNumcte) THEN
						--UPDATE bdiunica@coppelimg_tcp:uni_cliente
						UPDATE	bdiunica@stag_ids1170:"informix".uni_cliente
						SET		num_cte_coppel = cNumcteCoppel, sucursal = cSucursal, fecha_alta = dFecha_alta, apell_paterno = cApell_paterno, apell_materno = cApell_materno, nombre1 = cNombre1, nombre2 = cNombre2, fecha_nac = dFecha_nac, estado_civil = cEstado_civil, sexo = cSexo, rfc = cRfc, grupo = cGrupo, subgrupo = cSubgrupo,
								calle = cCalle, colonia = cColonia, estado = cEstado, ciudad = cCiudad, municipio = cMunicipio, cod_postal = cCod_postal, numeroextcalle = cNumeroextcalle, numerointcalle = cNumerointcalle, departamento = cDepartamento,manzana = smManzana, andador = smAndador, etapa = smEtapa, lote = smLote, edificio = smEdificio, entrada = smEntrada, observaciones = cObservaciones
						WHERE 	numcte = cNumcte;
					ELSE
						--INSERT INTO bdiunica@coppelimg_tcp:uni_cliente (numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
						INSERT INTO bdiunica@stag_ids1170:"informix".uni_cliente (numcte, num_cte_coppel,sucursal,fecha_alta,apell_paterno,apell_materno, nombre1,nombre2,fecha_nac,estado_civil,sexo,rfc,grupo,subgrupo,
									calle,colonia,estado,ciudad,municipio,cod_postal,numeroextcalle,numerointcalle, departamento,manzana,andador,etapa,lote,edificio,entrada,observaciones)
						VALUES (cNumcte, cNumcteCoppel, cSucursal, dFecha_alta, cApell_paterno, cApell_materno, cNombre1, cNombre2, dFecha_nac, cEstado_civil, cSexo, cRfc, cGrupo, cSubgrupo,
								cCalle, cColonia, cEstado, cCiudad, cMunicipio, cCod_postal, cNumeroextcalle, cNumerointcalle, cDepartamento, smManzana, smAndador, smEtapa, smLote, smEdificio, smEntrada, cObservaciones);
					END IF;
				END FOREACH;


				
				LET cEvento = 'ACTUALIZACION DE TABLA UNI_CORREO';
				FOREACH
					SELECT	numcte,correo_elec,tipo_correo,status_correo,valido 
					INTO	cNumcte, cCorreo_elec, cTipo_correo, cStatus_correo, cValido
					FROM	bdinteg:tmp_correos_unica
					
					--IF EXISTS (SELECT numcte FROM bdiunica@coppelimg_tcp:uni_correo WHERE numcte = cNumcte) THEN
					IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_correo WHERE numcte = cNumcte) THEN
						--UPDATE bdiunica@coppelimg_tcp:uni_correo
						UPDATE	bdiunica@stag_ids1170:"informix".uni_correo
						SET		correo_elec = cCorreo_elec, tipo_correo = cTipo_correo, status_correo = cStatus_correo, valido = cValido
						WHERE	numcte = cNumcte;					
					ELSE
						--INSERT INTO bdiunica@coppelimg_tcp:uni_correo (numcte,correo_elec,tipo_correo,status_correo,valido)
						INSERT INTO bdiunica@stag_ids1170:"informix".uni_correo (numcte,correo_elec,tipo_correo,status_correo,valido)
						VALUES (cNumcte, cCorreo_elec, cTipo_correo, cStatus_correo, cValido);
					END IF;
				END FOREACH;
				
				
				LET cEvento = 'ACTUALIZACION DE TABLA UNI_TELEFONOS';
				
				FOREACH
					SELECT	numcte, casa, celular, oficina, otro, extension, nom_carrier, status_tel, cofetel,movil_fijo 
					INTO	cNumcte, cCasa, cCelular, cOficina, cOtro, cExtension, cCarrier, cStatus_tel, cCofetel, cMovil_fijo
					FROM	bdinteg:tmp_telefonos_unica
					
					--IF EXISTS (SELECT numcte FROM bdiunica@coppelimg_tcp:uni_telefonos WHERE numcte = cNumcte) THEN
					IF EXISTS (SELECT numcte FROM bdiunica@stag_ids1170:"informix".uni_telefonos WHERE numcte = cNumcte) THEN
						--UPDATE bdiunica@coppelimg_tcp:uni_telefonos
						UPDATE	bdiunica@stag_ids1170:"informix".uni_telefonos
						SET		casa = cCasa, celular = cCelular, oficina = cOficina, otro = cOtro, extension = cExtension, carrier = cCarrier, status_tel = cStatus_tel, cofetel = cCofetel,movil_fijo = cMovil_fijo
						WHERE	numcte = cNumcte;
						
					ELSE
						--INSERT INTO bdiunica@coppelimg_tcp:uni_telefonos(numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo)
						INSERT INTO bdiunica@stag_ids1170:"informix".uni_telefonos(numcte, casa, celular, oficina, otro, extension, carrier, status_tel, cofetel,movil_fijo)
						VALUES (cNumcte, cCasa, cCelular, cOficina, cOtro, cExtension, cCarrier, cStatus_tel, cCofetel, cMovil_fijo);
					END IF;
				END FOREACH;			

			COMMIT WORK;
			LET bEnTransaccion = 'f';			
		END IF;
		
		DROP TABLE IF EXISTS tmp_clientes;
		DROP TABLE IF EXISTS tmp_clientes_unica;
		DROP TABLE IF EXISTS tmp_correos_unica;
		DROP TABLE IF EXISTS tmp_telefonos_unica;
		
		UPDATE si_controlproc_indicadores {+INDEX (bdinteg:si_controlproc_indicadores idx_controlproc_indicadores_01)}
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
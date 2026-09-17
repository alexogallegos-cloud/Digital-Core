CREATE PROCEDURE "informix".sp_refusiona_direcciones()
RETURNING CHAR(6);
	DEFINE cCodRet			CHAR(6);
	DEFINE i_SqlError		INTEGER;
	DEFINE i_iSamError		INTEGER;
	
	DEFINE cCliente_tit		CHAR(20);
	DEFINE cCliente_tras	CHAR(20);
	
	DEFINE iROWID			INTEGER;
	DEFINE iROWDIDAux		INTEGER;
	DEFINE iContador		INTEGER;
	DEFINE iContador2		INTEGER;
	DEFINE iMaxSecuencia	INTEGER;
	DEFINE iTrans_abierta	INTEGER;
	DEFINE iTotalReg		INTEGER;
	DEFINE iProcesados		INTEGER;
	DEFINE MAXTRANSACCION	INTEGER;
	DEFINE MAXTIPODIRECCION	INTEGER;
	DEFINE iTipoDireccion	INTEGER;
	
	DEFINE iNumColonia		INTEGER;
	DEFINE iNumColoniaAux	INTEGER;
	DEFINE iNumCalle		INTEGER;
	DEFINE iNumCalleAux		INTEGER;
	DEFINE iSecuencia		INTEGER;
	DEFINE iSecuenciaAux	INTEGER;
	DEFINE cTipoDir			CHAR(1);
	DEFINE cTipoDirAux		CHAR(1);
	DEFINE cCd				CHAR(3);
	DEFINE cCdAux			CHAR(3);
	DEFINE cMunicipio		CHAR(5);
	DEFINE cMunicipioAux	CHAR(5);
	DEFINE cCP				CHAR(5);
	DEFINE cCPAux			CHAR(5);
	DEFINE cNumExtCalle		CHAR(10);
	DEFINE cNumExtCalleAux	CHAR(10);
	DEFINE c_detalle_mov	CHAR(200);
	
	DEFINE dtFechaInsercion	DATETIME HOUR TO FRACTION;
	
	LET iTipoDireccion = 0;
	LET iContador = 0;
	LET iContador2 = 0;
	LET iMaxSecuencia = 0;
	LET cCliente_tit = '';
	LET cCliente_tras = '';
	LET cCodRet = '000000';
	LET MAXTRANSACCION = 500;
	LET MAXTIPODIRECCION = 3;
	LET iProcesados = 0;
	LET iTotalReg= 0;
	LET iTrans_abierta= 0;
	
	--SET DEBUG FILE TO "/informix/rmarquez/sp_refusiona_direcciones.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET i_SqlError,i_iSamError
			IF i_SqlError <> 0 THEN				
				IF iTrans_abierta = 1 THEN
					ROLLBACK WORK;
				END IF;
				
				LET cCodRet = i_SqlError;
				SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				
				LET c_detalle_mov=i_SqlError||'|'||i_iSamError;
				
				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES ("DIRECCIONES","si_direcciones",cCliente_tit,cCliente_tras,c_detalle_mov,dtFechaInsercion,USER,dtFechaInsercion::DATE);
				
				IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
					DROP TABLE tmpfusionados;
				END IF;	
				
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			DROP TABLE tmpfusionados;
		END IF;	
		
		SELECT DISTINCT a.cliente_tit, a.cliente_tras
		FROM TABLE(MULTISET(SELECT DISTINCT a.cliente_tit, a.cliente_tras
							FROM si_fusionaut a, si_cliente b, TABLE(MULTISET((SELECT DISTINCT numcte FROM si_fusdirecciones WHERE tipo_dir = 1))) c
							WHERE a.cliente_tit = b.numcte
							AND b.numcte = c.numcte
							AND a.estatus = 1
							AND b.tipo_cliente = '1'
							UNION ALL
							SELECT DISTINCT a.cliente_titular, a.cliente_traspasar
							FROM si_fusbitacora a, si_cliente b, TABLE(MULTISET((SELECT DISTINCT numcte FROM si_fusdirecciones WHERE tipo_dir = 1))) c
							WHERE a.cliente_titular = b.numcte
							AND b.numcte = c.numcte
							AND a.fusion = 'SI'
							AND b.tipo_cliente = '1' ))a
			 LEFT JOIN 
			 TABLE(MULTISET((SELECT DISTINCT numcte FROM si_direcciones WHERE tipo_dir = 1))) b
		ON a.cliente_tit = b.numcte
		WHERE b.numcte IS NULL
		INTO TEMP tmpfusionados WITH NO LOG;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			SELECT COUNT(*) INTO iTotalReg FROM tmpfusionados;
		END IF;	
				
		IF iTotalReg > 0 THEN		
			FOREACH WITH HOLD
				SELECT DISTINCT cliente_tit, cliente_tras
				INTO cCliente_tit, cCliente_tras
				FROM tmpfusionados
				
				LET iContador = 0;
				LET iContador2 = 0;			
				
				IF iProcesados = 0 THEN
					BEGIN WORK;
					LET iTrans_abierta = 1;
				END IF;				
				
				IF EXISTS (SELECT numcte FROM bdinteg:si_fusdirecciones WHERE numcte = cCliente_tras) THEN
				
					DELETE FROM bdinteg:si_direcciones_actual WHERE numcte in (cCliente_tit, cCliente_tras);
					
					SELECT NVL(MAX(secuencia),0) 
					INTO iMaxSecuencia 
					FROM bdinteg:si_fusdirecciones --MOD.
					WHERE numcte = cCliente_tras;
					IF iMaxSecuencia > 0 THEN
						FOREACH
							SELECT ROWID, ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal,secuencia,tipo_dir 
							INTO iROWID, cCd,cMunicipio,iNumColonia,iNumCalle,cNumExtCalle,cCP,iSecuencia,cTipoDir 
							FROM bdinteg:si_fusdirecciones
							WHERE numcte = cCliente_tras 
							ORDER BY secuencia,ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal
							
							IF iContador = 0 THEN						
								LET iNumColoniaAux = iNumColonia;
								LET iNumCalleAux = iNumCalle;
								LET iSecuenciaAux = iSecuencia;
								LET cTipoDirAux = cTipoDir;
								LET cCdAux = cCd;
								LET cMunicipioAux = cMunicipio;
								LET cCPAux = cCP;
								LET cNumExtCalleAux = cNumExtCalle;
								LET iROWDIDAux = iROWID;
								
								LET iContador = iContador + 1;
								
								INSERT INTO fusdirecciones(numcte,secuencia , tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
										estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
										puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert)
								SELECT cCliente_tit AS numcte, (SELECT NVL(MAX(secuencia),0)+1 FROM fusdirecciones WHERE numcte = cCliente_tit) , tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
										estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia,
										puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert
								FROM bdinteg:si_fusdirecciones
								WHERE numcte = cCliente_tras
								AND secuencia = iSecuenciaAux
								AND tipo_dir = cTipoDirAux
								AND ROWID = iROWDIDAux;
							ELSE
								LET iNumColoniaAux = iNumColonia;
								LET iNumCalleAux = iNumCalle;
								LET iSecuenciaAux = iSecuencia;
								LET cTipoDirAux = cTipoDir;
								LET cCdAux = cCd;
								LET cMunicipioAux = cMunicipio;
								LET cCPAux = cCP;
								LET cNumExtCalleAux = cNumExtCalle;
								LET iROWDIDAux = iROWID;
								--IF cCdAux = cCd AND cMunicipioAux = cMunicipio AND iNumColoniaAux = iNumColonia AND iNumCalleAux = iNumCalle AND cNumExtCalleAux = cNumExtCalle AND cCPAux = cCP AND cTipoDirAux <> cTipoDir THEN
									IF NOT EXISTS (SELECT ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal,secuencia,tipo_dir 
												   FROM bdinteg:fusdirecciones 
												   WHERE numcte = cCliente_tit AND ciudad = cCd AND municipio = cMunicipio AND numerocolonia = iNumColonia AND numerocalle = iNumCalle AND numeroextcalle = cNumExtCalle AND cod_postal = cCP AND tipo_dir = cTipoDir) THEN												  
										
										INSERT INTO fusdirecciones(numcte,secuencia , tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
											estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
											puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert)
										SELECT cCliente_tit AS numcte, (SELECT NVL(MAX(secuencia),0)+1 FROM fusdirecciones WHERE numcte = cCliente_tit) AS secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
											estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
											puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert
										FROM bdinteg:si_fusdirecciones
										WHERE numcte = cCliente_tras 
										AND secuencia = iSecuenciaAux
										AND tipo_dir = cTipoDirAux
										AND ROWID = iROWDIDAux;
										
										LET iContador2 = iContador2 + 1;
									END IF; --If exists domicilio
								--END IF;
								LET iContador = iContador + 1;
							END IF; --If contador
						END FOREACH; --Consulta domicilios cCliente_tras
						
						SELECT {+INDEX (bdinteg:fusdirecciones idxdircte)} NVL(MAX(secuencia),0) 
						INTO iMaxSecuencia FROM fusdirecciones 
						WHERE numcte = cCliente_tit;
						
						SET ISOLATION TO DIRTY READ;
						
						FOREACH
							SELECT ROWID, ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal,secuencia, tipo_dir 
							INTO iROWID,cCd,cMunicipio,iNumColonia,iNumCalle,cNumExtCalle,cCP,iSecuencia,cTipoDir 
							FROM bdinteg:si_fusdirecciones
							WHERE numcte = cCliente_tit 
							ORDER BY secuencia,ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal
							
							IF iContador=0 THEN
								LET iNumColoniaAux = iNumColonia;
								LET iNumCalleAux = iNumCalle;
								LET iSecuenciaAux = iSecuencia;
								LET cTipoDirAux = cTipoDir;
								LET cCdAux = cCd;
								LET cMunicipioAux = cMunicipio;
								LET cCPAux = cCP;
								LET cNumExtCalleAux = cNumExtCalle;
								LET iROWDIDAux = iROWID;
								
								LET iContador=iContador + 1;

								INSERT INTO fusdirecciones(numcte,secuencia , tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
											estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
											puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert)
								SELECT cCliente_tit AS numcte, (SELECT NVL(MAX(secuencia),0)+1 FROM fusdirecciones WHERE numcte = cCliente_tit) AS secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
											estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
											puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert
								FROM bdinteg:si_fusdirecciones
								WHERE numcte = cCliente_tit 
								AND secuencia = iSecuenciaAux
								AND tipo_dir = cTipoDirAux
								AND ROWID = iROWDIDAux;
							ELSE
								LET iNumColoniaAux = iNumColonia;
								LET iNumCalleAux = iNumCalle;
								LET iSecuenciaAux = iSecuencia;
								LET cTipoDirAux = cTipoDir;
								LET cCdAux = cCd;
								LET cMunicipioAux = cMunicipio;
								LET cCPAux = cCP;
								LET cNumExtCalleAux = cNumExtCalle;
								LET iROWDIDAux = iROWID;
								
								--IF cCdAux = cCd AND cMunicipioAux = cMunicipio AND iNumColoniaAux = iNumColonia AND iNumCalleAux = iNumCalle AND cNumExtCalleAux = cNumExtCalle AND cCPAux = cCP AND cTipoDirAux <> cTipoDir THEN
									IF NOT EXISTS (SELECT ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal,secuencia,tipo_dir 
												   FROM bdinteg:fusdirecciones 
												   WHERE numcte = cCliente_tit AND ciudad = cCd AND municipio = cMunicipio AND numerocolonia = iNumColonia AND numerocalle = iNumCalle AND numeroextcalle = cNumExtCalle AND cod_postal = cCP AND tipo_dir = cTipoDir) THEN
										INSERT INTO fusdirecciones(numcte,secuencia , tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
											estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
											puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert)
										SELECT cCliente_tit AS numcte, (SELECT NVL(MAX(secuencia),0)+1 FROM fusdirecciones WHERE numcte = cCliente_tit) AS secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
											estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
											puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert
										FROM bdinteg:si_fusdirecciones
										WHERE numcte = cCliente_tit 
										AND secuencia = iSecuenciaAux
										AND tipo_dir = cTipoDirAux
										AND ROWID = iROWDIDAux;

										LET iContador2 = iContador2 + 1;
									END IF;
								--END IF;
								LET iContador=iContador + 1;
							 END IF;
						END FOREACH;
						
						SET ISOLATION TO DIRTY READ;
						
						--Para considerar nuevos domicilios en si_direcciones que no se encuentren en si_fusdirecciones
						FOREACH
							SELECT ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal,secuencia, tipo_dir 
							INTO cCd,cMunicipio,iNumColonia,iNumCalle,cNumExtCalle,cCP,iSecuencia,cTipoDir 
							FROM bdinteg:si_direcciones
							WHERE numcte = cCliente_tit 
							ORDER BY secuencia,ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal
							
							IF NOT EXISTS (SELECT ciudad,municipio,numerocolonia,numerocalle,numeroextcalle,cod_postal,secuencia,tipo_dir 
										   FROM bdinteg:fusdirecciones 
										   WHERE numcte = cCliente_tit AND ciudad = cCd AND municipio = cMunicipio AND numerocolonia = iNumColonia AND numerocalle = iNumCalle AND numeroextcalle = cNumExtCalle AND cod_postal = cCP AND tipo_dir = cTipoDir) THEN
								INSERT INTO fusdirecciones(numcte,secuencia , tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
									estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
									puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert)
								SELECT cCliente_tit AS numcte, (SELECT NVL(MAX(secuencia),0)+1 FROM fusdirecciones WHERE numcte = cCliente_tit) AS secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
									estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
									puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert
								FROM bdinteg:si_direcciones
								WHERE numcte = cCliente_tit 
								AND secuencia = iSecuencia
								AND tipo_dir = cTipoDir;
							END IF;
						END FOREACH;
						
						DELETE FROM bdinteg:si_direcciones WHERE numcte = cCliente_tit;
						
						INSERT INTO bdinteg:si_direcciones(numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
						   estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle,
						   numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio,
						   entrada, observaciones, user_insert, fecha_insert)
						SELECT {+INDEX (bdinteg:fusdirecciones idxdircte)} numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
							   estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle,
							   numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio,
							   entrada, observaciones, user_insert, fecha_insert
						FROM fusdirecciones
						WHERE numcte = cCliente_tit;
					END IF;	--Maxima Secuencia
				END IF; --If exists cCliente_tras
				
				DELETE {+INDEX (bdinteg:fusdirecciones idxdircte)}
				FROM bdinteg:fusdirecciones
				WHERE numcte = cCliente_tit;				
				
				FOR iTipoDireccion = 1 TO MAXTIPODIRECCION
					INSERT INTO bdinteg:fusdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,
					estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,
					numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,
					entrada,observaciones,user_insert,fecha_insert)
					SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,estado_inegi,municipio_inegi,
						localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,
						etapa,lote,edificio,entrada,observaciones,user_insert,fecha_insert
					FROM bdinteg:si_direcciones
					WHERE numcte = cCliente_tit
					AND secuencia = (SELECT NVL(MAX(secuencia),0)
									  FROM bdinteg:si_direcciones
									  WHERE numcte = cCliente_tit
									  AND tipo_dir = iTipoDireccion::CHAR(1));
					
					SELECT NVL(MAX(secuencia),0)
					INTO iMaxSecuencia
					FROM bdinteg:si_direcciones
					WHERE numcte = cCliente_tit
					AND tipo_dir = iTipoDireccion::CHAR(1);
					
					DELETE FROM bdinteg:si_direcciones
					WHERE numcte = cCliente_tit
					AND secuencia = iMaxSecuencia AND tipo_dir = iTipoDireccion::CHAR(1);
				END FOR;
				
				INSERT INTO bdinteg:si_direcciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,
				estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,
					numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,
					entrada,observaciones,user_insert,fecha_insert)
				SELECT {+INDEX (bdinteg:fusdirecciones idxdircte)} numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,
					estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,
					numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,
					entrada,observaciones,user_insert,fecha_insert
				FROM fusdirecciones
				WHERE numcte = cCliente_tit;
				
				DELETE FROM bdinteg:fusdirecciones WHERE numcte = cCliente_tit;
				
				LET iProcesados = iProcesados + 1;
				
				IF iProcesados >= MAXTRANSACCION THEN
					LET iProcesados = 0;
					COMMIT WORK;
					LET iTrans_abierta = 0;
				END IF;
			END FOREACH;
			
			IF iProcesados < MAXTRANSACCION AND  iTotalReg > 0 THEN
				IF iProcesados > 0 THEN
					COMMIT WORK;
					LET iTrans_abierta = 0;
				END IF;
				LET iProcesados = 0;
			END IF;
		END IF;
		
		IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmpfusionados') THEN
			DROP TABLE tmpfusionados;
		END IF;	

		RETURN cCodRet;
	END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_actualizadireccioncofetel(cNumCte CHAR(20))
RETURNING CHAR(5);

DEFINE cCodRet     CHAR(5);
DEFINE cCodRet2    CHAR(5);
DEFINE iSqlErr     INTEGER;

-- Variables para la dirección
DEFINE cTipo_Dir CHAR(40);
DEFINE cCalle CHAR(40);
DEFINE cColonia CHAR(60);
DEFINE cEntreCalles CHAR(40);
DEFINE cPais CHAR(3);
DEFINE cEstado CHAR(2);
DEFINE cCiudad CHAR(3);
DEFINE cMunicipio CHAR(5);
DEFINE cCodPostal CHAR(5);
DEFINE cApartPostal CHAR(11);
DEFINE cTipoTel1  CHAR(1);
DEFINE cTelefono1 CHAR(13);
DEFINE cTipoTel2  CHAR(1);
DEFINE cTelefono2  CHAR(13);
DEFINE cTipoTel3  CHAR(1);
DEFINE cTelefono3  CHAR(13);
DEFINE cExtension CHAR(5);
DEFINE cEstadoInegi  CHAR(2);
DEFINE cMunicipioInegi CHAR(3);
DEFINE cLocalidadInegi  CHAR(4);
DEFINE sNumeroCiudad SMALLINT;
DEFINE cNumeroExtCalle  CHAR(10);
DEFINE cNumerIntCalle  CHAR(10);
DEFINE cDepartamento  CHAR(6);
DEFINE iNumeroCalle INTEGER;
DEFINE iNumeroColonia INTEGER;
DEFINE cPuntoCardinal  CHAR(1);
DEFINE cUnidadHabitac  CHAR(1);
DEFINE sManzana SMALLINT;
DEFINE sOtros  SMALLINT;
DEFINE sAndador SMALLINT;
DEFINE sEtapa SMALLINT;
DEFINE sLote  SMALLINT;
DEFINE sEdificio  SMALLINT;
DEFINE sEntrada  SMALLINT;
DEFINE cObservaciones CHAR(80);
DEFINE cUserInsert CHAR(8); 
DEFINE dFechaInsert DATE; 

-- Variables para dirección particular
DEFINE iSecuencia1P SMALLINT;
DEFINE cIndCofeteltel1P CHAR(1);
DEFINE cIndCofeteltel2P CHAR(1);
DEFINE cIndCofeteltel3P CHAR(1);
DEFINE cCofeteltel1P CHAR(1);
DEFINE cCofeteltel2P CHAR(1);
DEFINE cCofeteltel3P CHAR(1);
DEFINE sCambiaDireccionP SMALLINT;

-- Variables para dirección oficina
DEFINE iSecuencia2O SMALLINT;
DEFINE cIndCofeteltel1O CHAR(1);
DEFINE cIndCofeteltel2O CHAR(1);
DEFINE cIndCofeteltel3O CHAR(1);
DEFINE cCofeteltel1O CHAR(1);
DEFINE cCofeteltel2O CHAR(1);
DEFINE cCofeteltel3O CHAR(1);
DEFINE sCambiaDireccionO SMALLINT;
    
LET cCodRet = "000";
LET cCodRet2 = "000";
LET iSqlErr = 0;

-- Inicilización de variables para la dirección
LET cTipo_Dir = "";
LET cCalle = "";
LET cColonia = "";
LET cEntreCalles = "";
LET cPais = "";
LET cEstado = "";
LET cCiudad = "";
LET cMunicipio = "";
LET cCodPostal = "";
LET cApartPostal = "";
LET cTipoTel1 = "";
LET cTelefono1 = "";
LET cTipoTel2 = "";
LET cTelefono2 = "";
LET cTipoTel3 = "";
LET cTelefono3 = "";
LET cExtension = "";
LET cEstadoInegi = "";
LET cMunicipioInegi = "";
LET cLocalidadInegi = "";
LET sNumeroCiudad = 0;
LET cNumeroExtCalle = "";
LET cNumerIntCalle = "";
LET cDepartamento = "";
LET iNumeroCalle = 0;
LET iNumeroColonia = 0;
LET cPuntoCardinal = "";
LET cUnidadHabitac = "";
LET sManzana = 0;
LET sOtros  = 0;
LET sAndador  = 0;
LET sEtapa = 0;
LET sLote = 0;
LET sEdificio  = 0;
LET sEntrada = 0;
LET cObservaciones = "";
LET cUserInsert = "";
LET dFechaInsert = "01-01-1900"; 

-- Inicialización de variables para dirección particular
LET iSecuencia1P = 0;
LET cIndCofeteltel1P = "";
LET cIndCofeteltel2P = "";
LET cIndCofeteltel3P = "";
LET cCofeteltel1P = "";
LET cCofeteltel2P = "";
LET cCofeteltel3P = "";
LET sCambiaDireccionP = 0;

-- Inicialización de variables para dirección oficina
LET iSecuencia2O = 0;
LET cIndCofeteltel1O = "";
LET cIndCofeteltel2O = "";
LET cIndCofeteltel3O = "";
LET cCofeteltel1O = "";
LET cCofeteltel2O = "";
LET cCofeteltel3O = "";
LET sCambiaDireccionO = 0;

--- SET DEBUG FILE TO "/home/sysifx/frank/sp_actualizadireccioncofetel.out";
--- TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet=iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
	
	IF cNumCte <> "" THEN
		
		/* SELECT secuencia 
		INTO iSecuencia1P
		FROM si_direcciones_actual	
		WHERE numcte = cNumCte 
		AND tipo_dir = "1";
		
		SELECT secuencia
		INTO iSecuencia2O
		FROM si_direcciones_actual	
		WHERE numcte = cNumCte 
		AND tipo_dir = "2";
			
		IF iSecuencia1P <> 0 OR iSecuencia1P IS NOT NULL THEN */
		
        SELECT fecha_insert,secuencia 
        INTO dFechaInsert, iSecuencia1P
        FROM si_direcciones_actual 	
        WHERE numcte = cNumCte 
        AND tipo_dir = "1";
        
        --- IF dFechaInsert is not NULL OR dFechaInsert<> ''THEN
        IF iSecuencia1P <> 0 OR iSecuencia1P IS NOT NULL THEN
			
			IF dFechaInsert <= "12-31-2009" THEN
			
				SELECT dir.tipo_dir, dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal, 
                       /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
                       tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension,
                       dir.estado_inegi, dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad,
                       dir.numeroextcalle, dir.numerointcalle, dir.departamento, dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, 
                       dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones, dir.user_insert, dir.fecha_insert, 
                       dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3 
				INTO cTipo_dir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal, 
                     cTipoTel1, cTelefono1, cTipoTel2, cTelefono2, cTipoTel3, cTelefono3, cExtension, 
                     cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad,
					 cNumeroExtCalle, cNumerIntCalle, cDepartamento, iNumeroCalle, iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros,
					 sAndador, sEtapa, sLote, sEdificio, sEntrada, cObservaciones, cUserInsert, dFechaInsert, cIndCofeteltel1P, cIndCofeteltel2P, cIndCofeteltel3P
				FROM si_direcciones_actual dir
                LEFT OUTER JOIN si_telefonos_actual tel1 ON(tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
                LEFT OUTER JOIN si_telefonos_actual tel2 ON(tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
                LEFT OUTER JOIN si_telefonos_actual tel3 ON(tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
				WHERE dir.numcte = cNumCte
				AND dir.tipo_dir = '1';
				--- AND secuencia = iSecuencia1P;
				
				IF LENGTH(cTelefono1) > 10 OR LENGTH(cTelefono2) > 10 OR LENGTH(cTelefono3) > 10 THEN

					IF LENGTH(cTelefono1) = 13 THEN
						LET cTelefono1 = SUBSTRING(cTelefono1 FROM 4 FOR 13);
					ELIF LENGTH(cTelefono1) = 12 THEN
						LET cTelefono1 = SUBSTRING(cTelefono1 FROM 3 FOR 12);
					ELIF LENGTH(cTelefono1) = 11 THEN
						LET cTelefono1 = SUBSTRING(cTelefono1 FROM 2 FOR 11);
					END IF;

					IF LENGTH(cTelefono2) = 13 THEN
						LET cTelefono2 = SUBSTRING(cTelefono2 FROM 4 FOR 13);
					ELIF LENGTH(cTelefono2) = 12 THEN
						LET cTelefono2 = SUBSTRING(cTelefono2 FROM 3 FOR 12);
					ELIF LENGTH(cTelefono2) = 11 THEN
						LET cTelefono2 = SUBSTRING(cTelefono2 FROM 2 FOR 11);
					END IF;

					IF LENGTH(cTelefono3) = 13 THEN
						LET cTelefono3 = SUBSTRING(cTelefono3 FROM 4 FOR 13);
					ELIF LENGTH(cTelefono3) = 12 THEN
						LET cTelefono3 = SUBSTRING(cTelefono3 FROM 3 FOR 12);
					ELIF LENGTH(cTelefono3) = 11 THEN
						LET cTelefono3 = SUBSTRING(cTelefono3 FROM 2 FOR 11);
					END IF;

					EXECUTE PROCEDURE sp_validatelefono ('001', cTelefono1, cTelefono2, cTelefono3)
					INTO cCodRet2, cCofeteltel1P, cCofeteltel2P, cCofeteltel3P;

					IF cCodRet2 = "000" THEN
						IF cCofeteltel1P = 1 THEN
							LET cIndCofeteltel1P = 'V';
						END IF;

						IF cCofeteltel2P = 1 THEN
							LET cIndCofeteltel2P = 'V';
						END IF;

						IF cCofeteltel3P = 1 THEN
							LET cIndCofeteltel3P = 'V';
						END IF;
					END IF;
					
					SELECT MAX(secuencia)
					INTO iSecuencia1P
					FROM si_direcciones_actual	
					WHERE numcte = cNumCte; 

					INSERT INTO si_direcciones 
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, 
                      /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
                      estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
                      numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
                      user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
					VALUES 
                    ( cNumcte, iSecuencia1P + 1, cTipo_dir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal, 
                      /* cTipoTel1, cTelefono1, cTipoTel2, cTelefono2, cTipoTel3, cTelefono3, cExtension, */
                      cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad, cNumeroExtCalle, cNumerIntCalle, cDepartamento, iNumeroCalle, 
                      iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros, sAndador, sEtapa, sLote, sEdificio, sEntrada, cObservaciones, 
                      cUserInsert, dFechaInsert, cIndCofeteltel1P, cIndCofeteltel2P, cIndCofeteltel3P );
				
				ELIF LENGTH(cTelefono1) <= 10 OR LENGTH(cTelefono2) <= 10 OR LENGTH(cTelefono3) <= 10 THEN
			
					EXECUTE PROCEDURE sp_validatelefono ('001', cTelefono1, cTelefono2, cTelefono3)
					INTO cCodRet2, cCofeteltel1P, cCofeteltel2P, cCofeteltel3P;
					
					IF cCofeteltel1P = 1 THEN
						LET cCofeteltel1P = 'V';
					ELSE
						LET cCofeteltel1P = 'F';
					END IF;
					
					IF cCofeteltel2P = 1 THEN
						LET cCofeteltel2P = 'V';
					ELSE
						LET cCofeteltel2P = 'F';
					END IF;
					
					IF cCofeteltel3P = 1 THEN
						LET cCofeteltel3P = 'V';
					ELSE
						LET cCofeteltel3P = 'F';
					END IF;
					
					IF cCofeteltel1P <> cIndCofeteltel1P THEN
						LET sCambiaDireccionP = 1;
						LET cIndCofeteltel1P = cCofeteltel1P;
					END IF;
					
					IF cCofeteltel2P <> cIndCofeteltel2P THEN
						LET sCambiaDireccionP = 1;
						LET cIndCofeteltel2P = cCofeteltel2P;
					END IF;
					
					IF cCofeteltel3P <> cIndCofeteltel3P THEN
						LET sCambiaDireccionP = 1;
						LET cIndCofeteltel3P = cCofeteltel3P;
					END IF;
					
					IF sCambiaDireccionP = 1 THEN

						SELECT MAX(secuencia)
						INTO iSecuencia1P
						FROM si_direcciones_actual	
						WHERE numcte = cNumCte; 

						INSERT INTO si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, 
                          /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
                          estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
                          numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
                          user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
						VALUES 
                        ( cNumcte, iSecuencia1P + 1, cTipo_dir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal, 
                          /* cTipoTel1, cTelefono1, cTipoTel2, cTelefono2, cTipoTel3, cTelefono3, cExtension, */
                          cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad, cNumeroExtCalle, cNumerIntCalle, cDepartamento, iNumeroCalle, 
                          iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros, sAndador, sEtapa, sLote, sEdificio, sEntrada, cObservaciones, 
                          cUserInsert, dFechaInsert, cIndCofeteltel1P, cIndCofeteltel2P, cIndCofeteltel3P );

					END IF;
				
				END IF;
				
			END IF;	

		END IF;
		
        SELECT fecha_insert, secuencia 
        INTO dFechaInsert, iSecuencia2O
        FROM si_direcciones_actual 	
        WHERE numcte = cNumCte 
        --AND secuencia = iSecuencia2O
        AND tipo_dir = "2";
			
		IF iSecuencia2O <> 0 OR iSecuencia2O IS NOT NULL THEN	
		
			IF dFechaInsert <= "12-31-2009" THEN
			
				SELECT dir.tipo_dir, dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal, 
                       /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
                       tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension,
                       dir.estado_inegi, dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
                       dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, 
                       dir.entrada, dir.observaciones, dir.user_insert, dir.fecha_insert, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3 
				INTO cTipo_dir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal, 
                     cTipoTel1, cTelefono1, cTipoTel2, cTelefono2, cTipoTel3, cTelefono3, cExtension, 
                     cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad, cNumeroExtCalle, cNumerIntCalle, cDepartamento, 
                     iNumeroCalle, iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros, sAndador, sEtapa, sLote, sEdificio, 
                     sEntrada, cObservaciones, cUserInsert, dFechaInsert, cIndCofeteltel1O, cIndCofeteltel2O, cIndCofeteltel3O
				FROM si_direcciones_actual dir
                LEFT OUTER JOIN si_telefonos_actual tel1 ON(tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
                LEFT OUTER JOIN si_telefonos_actual tel2 ON(tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
                LEFT OUTER JOIN si_telefonos_actual tel3 ON(tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
				WHERE dir.numcte = cNumCte
				AND dir.tipo_dir = "2";
				--- AND secuencia = iSecuencia2O;
				
				IF LENGTH(cTelefono1) > 10 OR LENGTH(cTelefono2) > 10 OR LENGTH(cTelefono3) > 10 THEN

					IF LENGTH(cTelefono1) = 13 THEN
						LET cTelefono1 = SUBSTRING(cTelefono1 FROM 4 FOR 13);
					ELIF LENGTH(cTelefono1) = 12 THEN
						LET cTelefono1 = SUBSTRING(cTelefono1 FROM 3 FOR 12);
					ELIF LENGTH(cTelefono1) = 11 THEN
						LET cTelefono1 = SUBSTRING(cTelefono1 FROM 2 FOR 11);
					END IF;

					IF LENGTH(cTelefono2) = 13 THEN
						LET cTelefono2 = SUBSTRING(cTelefono2 FROM 4 FOR 13);
					ELIF LENGTH(cTelefono2) = 12 THEN
						LET cTelefono2 = SUBSTRING(cTelefono2 FROM 3 FOR 12);
					ELIF LENGTH(cTelefono2) = 11 THEN
						LET cTelefono2 = SUBSTRING(cTelefono2 FROM 2 FOR 11);
					END IF;

					IF LENGTH(cTelefono3) = 13 THEN
						LET cTelefono3 = SUBSTRING(cTelefono3 FROM 4 FOR 13);
					ELIF LENGTH(cTelefono3) = 12 THEN
						LET cTelefono3 = SUBSTRING(cTelefono3 FROM 3 FOR 12);
					ELIF LENGTH(cTelefono3) = 11 THEN
						LET cTelefono3 = SUBSTRING(cTelefono3 FROM 2 FOR 11);
					END IF;

					EXECUTE PROCEDURE sp_validatelefono ('001', cTelefono1, cTelefono2, cTelefono3)
					INTO cCodRet2, cCofeteltel1O, cCofeteltel2O, cCofeteltel3O;

					IF cCodRet2 = "000" THEN
						IF cCofeteltel1O = 1 THEN
							LET cIndCofeteltel1O = 'V';
						END IF;

						IF cCofeteltel2O = 1 THEN
							LET cIndCofeteltel2O = 'V';
						END IF;

						IF cCofeteltel3O = 1 THEN
							LET cIndCofeteltel3O = 'V';
						END IF;
					END IF;
					
					SELECT MAX(secuencia)
					INTO iSecuencia2O
					FROM si_direcciones_actual	
					WHERE numcte = cNumCte; 

					INSERT INTO si_direcciones 
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, 
                      /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
                      estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
                      numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
                      user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
					VALUES 
                    ( cNumcte, iSecuencia2O + 1, cTipo_dir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal, 
                      /* cTipoTel1, cTelefono1, cTipoTel2, cTelefono2, cTipoTel3, cTelefono3, cExtension, */
                      cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad, cNumeroExtCalle, cNumerIntCalle, cDepartamento, iNumeroCalle, 
                      iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros, sAndador, sEtapa, sLote, sEdificio, sEntrada, cObservaciones, 
                      cUserInsert, dFechaInsert, cIndCofeteltel1O, cIndCofeteltel2O, cIndCofeteltel3O );
				
				ELIF LENGTH(cTelefono1) <= 10 OR LENGTH(cTelefono2) <= 10 OR LENGTH(cTelefono3) <= 10 THEN
			
					EXECUTE PROCEDURE sp_validatelefono ('001', cTelefono1, cTelefono2, cTelefono3)
					INTO cCodRet2, cCofeteltel1O, cCofeteltel2O, cCofeteltel3O;
					
					IF cCofeteltel1O = 1 THEN
						LET cCofeteltel1O = 'V';
					ELSE
						LET cCofeteltel1O = 'F';
					END IF;
					
					IF cCofeteltel2O = 1 THEN
						LET cCofeteltel2O = 'V';
					ELSE
						LET cCofeteltel2O = 'F';
					END IF;
					
					IF cCofeteltel3O = 1 THEN
						LET cCofeteltel3O = 'V';
					ELSE
						LET cCofeteltel3O = 'F';
					END IF;
					
					IF cCofeteltel1O <> cIndCofeteltel1O THEN
						LET sCambiaDireccionO = 1;
						LET cIndCofeteltel1O = cCofeteltel1O;
					END IF;
					
					IF cCofeteltel2O <> cIndCofeteltel2O THEN
						LET sCambiaDireccionO = 1;
						LET cIndCofeteltel2O = cCofeteltel2O;
					END IF;
					
					IF cCofeteltel3O <> cIndCofeteltel3O THEN
						LET sCambiaDireccionO = 1;
						LET cIndCofeteltel3O = cCofeteltel3O;
					END IF;
					
					IF sCambiaDireccionO = 1 THEN

						SELECT MAX(secuencia)
						INTO iSecuencia2O
						FROM si_direcciones_actual	
						WHERE numcte = cNumCte; 

						INSERT INTO si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, 
                          /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
                          estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
                          numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
                          user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
						VALUES 
                        ( cNumcte, iSecuencia2O + 1, cTipo_dir, cCalle, cColonia, cEntreCalles, cPais, cEstado, cCiudad, cMunicipio, cCodPostal, cApartPostal, 
                          /* cTipoTel1, cTelefono1, cTipoTel2, cTelefono2, cTipoTel3, cTelefono3, cExtension, */
                          cEstadoInegi, cMunicipioInegi, cLocalidadInegi, sNumeroCiudad, cNumeroExtCalle, cNumerIntCalle, cDepartamento, iNumeroCalle, 
                          iNumeroColonia, cPuntoCardinal, cUnidadHabitac, sManzana, sOtros, sAndador, sEtapa, sLote, sEdificio, sEntrada, cObservaciones, 
                          cUserInsert, dFechaInsert, cIndCofeteltel1O, cIndCofeteltel2O, cIndCofeteltel3O );

					END IF;
				
				END IF;
				
			END IF;	
        
		END IF;
		
	END IF;
	
	RETURN cCodRet;
    
    END;
    
END PROCEDURE

DOCUMENT
"AutOR : Frank Gaxiola",
"FECHA : 06-04-2010",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cargacliente(pEmpresa char(3),pNumCredito CHAR(20),pNumCliente CHAR(10), pOpcion CHAR(1))

RETURNING CHAR(5) AS cCodRet,DATE AS fechaAlta ,CHAR(30) AS Nombre1,CHAR(30) AS Nombre2,
CHAR(30) AS ApellPaterno,CHAR(30) AS ApellMaterno,CHAR(30) AS RazonSocial,CHAR(1) AS Codidentifi,
CHAR(30) AS Numidentifi,CHAR(15) AS Rfc,DATE AS Fecha_nac,CHAR(1) AS ExisteCred;

--Declaracion de variables
DEFINE cCodRet        CHAR(5);
DEFINE iSqlErr        INTEGER;
DEFINE dfechaAlta     DATE;
DEFINE cNombre1       CHAR(30);
DEFINE cNombre2       CHAR(30);
DEFINE cApellPaterno  CHAR(30);
DEFINE cApellMaterno  CHAR(30);
DEFINE cRazonSocial   CHAR(30);
DEFINE cCodidentifi   CHAR(1);
DEFINE iNumidentifi   CHAR(30);
DEFINE cRfc           CHAR(15);
DEFINE dFecha_nac     DATE;
DEFINE cCliente       CHAR(10);
DEFINE iExiste		  INTEGER;
 
--Asignacion de variables
LET cCodRet           = '00001';
LET iSqlErr           = 0;
LET dfechaAlta        = '';
LET cNombre1          = '';
LET cNombre2          = '';
LET cApellPaterno     = '';
LET cApellMaterno     = '';
LET cRazonSocial      = '';
LET cCodidentifi      = '';
LET iNumidentifi      = '';
LET cRfc              = '';
LET dFecha_nac        = '';
LET cCliente          = '';
LET iExiste           = 0;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;		
			RETURN cCodRet,dfechaAlta,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cRazonSocial,cCodidentifi,iNumidentifi,cRfc,dFecha_nac,iExiste;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_CargaCliente.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF pOpcion = "1" THEN 
		IF pNumCliente != "" AND pEmpresa != "" THEN

			SELECT a.numcte,a.fecha_alta, a.nombre1, a.nombre2, a.apell_paterno,a.apell_materno, a.razon_social, b.codidentifi, b.numidentifi, a.rfc, b.fecha_nac 
			INTO cCliente,dfechaAlta,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cRazonSocial,cCodidentifi,iNumidentifi,cRfc,dFecha_nac
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b 
			WHERE a.numcte = pNumCliente 
			AND a.empresa = pEmpresa 
			AND b.empresa = a.empresa 
			AND b.numcte = a.numcte;

			LET cCodRet  = '00000';
			
			IF cCliente IS NULL THEN 
				LET cCodRet  = '00001';
			END IF;
			
			RETURN cCodRet,dfechaAlta,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cRazonSocial,cCodidentifi,iNumidentifi,cRfc,dFecha_nac,NVL(iExiste,'0');	
		ELSE
			LET cCodRet  = '00001';	
		END IF;
	
	
	ELIF pOpcion = "2" THEN 	
	
		SELECT 1 INTO iExiste
		FROM bdisolic:"informix".ss_solicitudes
		WHERE empresa = pempresa 
		AND num_solicitud = pNumCredito 
		AND numcte = pNumCliente;

		LET cCodRet  = '00000';
	
	    RETURN cCodRet,NVL(dfechaAlta,''),NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cRazonSocial,''),NVL(cCodidentifi,''),NVL(iNumidentifi,''),NVL(cRfc,''),NVL(dFecha_nac,''),NVL(iExiste,'0');
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Josue Zepeda',
'FECHA: 03/08/2012',
'BD: bdinteg',
'Objetivo: Carga los Datos del Cliente y verifica numero de credito';

CREATE PROCEDURE "informix".sp_depura_bitacorabpi_v2(fechmin CHAR(10), fechmax CHAR(10))
    RETURNING CHAR(5), integer, integer;  --Códigos de retorno

DEFINE cCodRet       CHAR(5);
DEFINE vid_operacion    CHAR (4);
DEFINE vtotregshist  integer;
DEFINE iSqlErr       integer;
DEFINE cont_borra    integer;
DEFINE cursor_borra  integer;

LET cCodRet        = '00000';
LET vid_operacion     = '0000';
LET vtotregshist   = 0;
LET iSqlErr        = 0;
LET cont_borra     = 0;
LET cursor_borra   = 0;

 --SET DEBUG FILE TO "/tmp/sp_depura_bitacorabpi_v2.out";
 --TRACE ON;

        SET LOCK MODE TO wait 5;
BEGIN

   ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet, vtotregshist, cont_borra;
                END IF;
    END EXCEPTION;

     SELECT  count(*) 
        INTO vtotregshist  
     FROM bdinteg:si_bpibitacora
     WHERE extend (fecha_oper, year to day) between fechmin and fechmax
     and NVL(id_operacion,'') <> '';
	
	FOREACH cursor_borra WITH HOLD FOR
		SELECT id_operacion
			INTO vid_operacion
			FROM bdinteg:si_bpibitacora
			WHERE extend (fecha_oper, year to day) between fechmin and fechmax
			and NVL(id_operacion,'') <> ''
   begin work;
		DELETE FROM bdinteg:si_bpibitacora
			WHERE CURRENT OF cursor_borra;
		commit work;
		

        LET cont_borra = cont_borra + 1;

    END FOREACH;

END;
RETURN cCodRet, vtotregshist, cont_borra;
END PROCEDURE



;
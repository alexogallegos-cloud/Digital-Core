CREATE PROCEDURE "informix".direcciones_pros_piloto(pEmpresa         CHAR(3),
											 pFuncion         CHAR(1),
											 pNumCte          CHAR(20),
											 pSecuencia       SMALLINT,
											 pTipoDir         CHAR(1),
											 pCalle           CHAR(40),
											 pColonia         CHAR(60),
											 pMunicipio       CHAR(5),
											 pEntre_Calles    CHAR(40),
											 pPais            CHAR(3),
											 pEntidad         CHAR(2),
											 pLocalidad       CHAR(3),
											 pCodPostal       CHAR(5),
											 pTipoTel1        CHAR(1),
											 pTelefono1       CHAR(13),
											 pTipoTel2        CHAR(1),
											 pTelefono2       CHAR(13),
											 pTipoTel3        CHAR(1),
											 pTelefono3       CHAR(13),
											 pExtension       CHAR(5),
											 pEstado_Inegi    CHAR(2),
											 pMunicipio_Inegi CHAR(3),
											 pLocalidad_Inegi CHAR(4),
											 pNoCiudad        SMALLINT,
											 pNoExt           CHAR(10),
											 pNoInt           CHAR(10),
											 pDepto           CHAR(6),
											 pNoCalle         INTEGER,
											 pNoColonia       INTEGER,
											 pPuntoCar        CHAR(1),
											 pUniHabi         CHAR(1),
											 pManz            SMALLINT,
											 pPOtros          SMALLINT,
											 pAndador         SMALLINT,
											 pEtapa           SMALLINT,
											 pLote            SMALLINT,
											 pEdif            SMALLINT,
											 pEntrada         SMALLINT,
											 pObserva         CHAR(80),
											 pUser_Insert     CHAR(8),
											 pFecha_Insert    DATE,
											 cSucursal        CHAR(4),
											 pCarrier         SMALLINT )
		RETURNING CHAR(5);

		DEFINE v_CodRet             CHAR(5);
		DEFINE v_CodRet2            CHAR(5);
		DEFINE v_CodRet3            CHAR(50);
		DEFINE v_SqlErr             INTEGER;
		DEFINE v_IsamErr            INTEGER;
		DEFINE v_DescErr            CHAR(50);
		DEFINE v_NumCte             CHAR(20);
		DEFINE pcoincide_dir        SMALLINT;
		DEFINE o_tipo_dir       	CHAR(1);
		DEFINE o_calle          	CHAR(40);
		DEFINE o_colonia        	CHAR(60);
		DEFINE o_entre_calles   	CHAR(40);
		DEFINE o_pais           	CHAR(3);
		DEFINE o_estado         	CHAR(2);
		DEFINE o_ciudad         	CHAR(3);
		DEFINE o_municipio      	CHAR(5);
		DEFINE o_cod_postal     	CHAR(5);
		DEFINE o_apart_postal   	CHAR(11);
		DEFINE o_telefono1      	CHAR(13);
		DEFINE o_telefono2      	CHAR(13);
		DEFINE o_telefono3      	CHAR(13);
		DEFINE o_extension      	CHAR(5);
		DEFINE o_estado_inegi   	CHAR(2);
		DEFINE o_municipio_inegi	CHAR(3);
		DEFINE o_localidad_inegi    CHAR(4);
		DEFINE o_numerociudad   	SMALLINT;
		DEFINE o_numeroextcalle 	CHAR(10);
		DEFINE o_numerointcalle 	CHAR(10);
		DEFINE o_departamento   	CHAR(6);
		DEFINE o_numerocalle    	INTEGER;
		DEFINE o_numerocolonia  	INTEGER;
		DEFINE o_puntocardinal  	CHAR(1);
		DEFINE o_unidadhabitac  	CHAR(1);
		DEFINE o_manzana        	SMALLINT;
		DEFINE o_otros          	SMALLINT;
		DEFINE o_andador        	SMALLINT;
		DEFINE o_etapa          	SMALLINT;
		DEFINE o_lote           	SMALLINT;
		DEFINE o_edificio       	SMALLINT;
		DEFINE o_entrada        	SMALLINT;
		DEFINE o_observaciones  	CHAR(80);
		DEFINE v_CodRetTel          CHAR(5);
		DEFINE vTipoTel             SMALLINT;
		DEFINE vCanal               SMALLINT;
		DEFINE cSituacionEsp        CHAR(1);  --- VARIABLE DE SITUACIÓN ESPECIAL
		DEFINE iCausa               INTEGER;  --- VARIABLE DE SITUACIÓN ESPECIAL
		DEFINE isecuencia  			INTEGER;  --- VARIABLE DE SITUACIÓN ESPECIAL
		
		LET v_CodRet          = '';
		LET v_CodRet2         = '';
		LET v_CodRet3         = '';
		LET v_SqlErr          = 0;
		LET v_IsamErr         = 0;
		LET v_DescErr         = '';
		LET v_NumCte          = '';
		LET pcoincide_dir     = 0;
		LET o_tipo_dir        = '';
		LET o_calle           = '';
		LET o_colonia         = '';
		LET o_entre_calles    = '';
		LET o_pais            = '';
		LET o_estado          = '';
		LET o_ciudad          = '';
		LET o_municipio       = '';
		LET o_cod_postal      = '';
		LET o_apart_postal    = '';
		LET o_telefono1       = '';
		LET o_telefono2       = '';
		LET o_telefono3       = '';
		LET o_extension       = '';
		LET o_estado_inegi    = '';
		LET o_municipio_inegi = '';
		LET o_localidad_inegi = '';
		LET o_numerociudad    = 0;
		LET o_numeroextcalle  = '';
		LET o_numerointcalle  = '';
		LET o_departamento    = '';
		LET o_numerocalle     = 0;
		LET o_numerocolonia   = 0;
		LET o_puntocardinal   = '';
		LET o_unidadhabitac   = '';
		LET o_manzana         = 0;
		LET o_otros           = 0;
		LET o_andador         = 0;
		LET o_etapa           = 0;
		LET o_lote            = 0;
		LET o_edificio        = 0;
		LET o_entrada         = 0;
		LET o_observaciones   = '';
		LET v_CodRetTel       = '';
		LET vTipoTel          = 0;
		LET vCanal            = 1;
		LET cSituacionEsp     = 'N'; --- VARIABLE DE SITUACIÓN ESPECIAL
		LET iCausa            = 0;   --- VARIABLE DE SITUACIÓN ESPECIAL
		LET isecuencia        = 0;   

		--SET DEBUG FILE TO "//respaldosbd/Pedro/1468/direcciones_pros_carrier.out";
		--TRACE ON;

		BEGIN

		ON EXCEPTION SET v_SqlErr, v_IsamErr, v_DescErr
			--SET DEBUG FILE TO "/tmp/direcciones_pros_carrier.err";
			--TRACE ON;
			IF v_SqlErr != 0 THEN
				LET v_CodRet = v_SqlErr;
				LET v_CodRet2 = v_IsamErr;
				LET v_CodRet3 = v_DescErr;
				RETURN v_CodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET v_CodRet = "000";
		LET pEntidad = CAST( LPAD (TRIM(pEntidad), 2 ,  "0") AS CHAR(2));

		SELECT numcte_pros 
		INTO v_NumCte 
		FROM 'informix'.pr_cliente
		WHERE numcte_pros = pNumCte;

		IF v_NumCte IS NULL THEN
			LET v_CodRet = "104";
			RETURN v_CodRet;
		END IF;

		--IF pFuncion = "C" THEN
			--DELETE FROM 'informix'.pr_direcciones
			--WHERE numcte_pros = pNumCte 
			--AND secuencia = pSecuencia;
			SELECT MAX(secuencia) 
			INTO isecuencia
			FROM 'informix'.pr_direcciones_actual
			WHERE numcte_pros = pNumCte
			AND tipo_dir = pTipoDir;
			
			IF NVL(isecuencia,0) >= pSecuencia THEN
				LET pSecuencia = isecuencia;
			END IF
		
			LET pFuncion = "A";
		--END IF;

		IF pFuncion = "A" THEN
			SELECT MAX(secuencia) 
			INTO pSecuencia
			FROM 'informix'.pr_direcciones
			WHERE numcte_pros = pNumCte;

				IF pSecuencia IS NULL THEN
					LET pSecuencia = 1;
				ELSE
					LET pSecuencia = pSecuencia + 1;
					LET cSituacionEsp = 'S';
				END IF;

				-- // SE AGREGA VALIDACIÓN PARA SI LA CLAVE DEL MUNICIPIO VIENE VACIO, LE ASIGNE  "00000".
				IF pMunicipio = "" OR pMunicipio IS NULL THEN
					LET pMunicipio = LPAD(TRIM(NVL(pMunicipio,"00000")),5,"0");
				END IF;
				LET pTipoDir =pTipoDir ;
				-- // VALIDA LA INFORMACION DE LA DIRECCION DEL CLIENTE
				SELECT tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
				puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones
				INTO o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, o_apart_postal,
				o_estado_inegi, o_municipio_inegi, o_localidad_inegi, o_numerociudad,o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, o_puntocardinal, o_unidadhabitac, o_manzana, o_otros, o_andador, o_etapa, o_lote, o_edificio, o_entrada, o_observaciones
				FROM 'informix'.pr_direcciones
				WHERE numcte_pros = pNumCte
				and secuencia = isecuencia
				AND tipo_dir = pTipoDir;

				IF ( o_tipo_dir IS NOT NULL 
					AND o_calle = pCalle 
					AND o_colonia = pColonia 
					AND o_entre_calles = pEntre_Calles 
					AND o_pais = pPais 
					AND o_estado = pEntidad  
					AND o_ciudad = pLocalidad  
					AND o_municipio = pMunicipio  
					AND o_cod_postal = pCodPostal 
					AND o_estado_inegi = pEstado_Inegi
					AND o_municipio_inegi = pMunicipio_Inegi
					AND o_localidad_inegi = pLocalidad_Inegi
					AND o_numerociudad = pNoCiudad
					AND o_numeroextcalle = pNoExt
					AND o_numerointcalle = pNoInt
					AND o_departamento = pDepto
					AND o_numerocalle = pNoCalle
					AND o_numerocolonia = pNoColonia
					AND o_puntocardinal = pPuntoCar
					AND o_unidadhabitac = pUniHabi
					AND o_manzana = pManz
					AND o_otros = pPOtros
					AND o_andador  = pAndador
					AND o_etapa = pEtapa
					AND o_lote = pLote
					AND o_edificio = pEdif
					AND o_entrada = pEntrada
					AND o_observaciones = pObserva ) THEN
					
					LET pcoincide_dir = 1;
				ELSE
					LET pcoincide_dir = 0;
				END IF;

				IF ( pcoincide_dir <= 0 ) THEN
				
					INSERT INTO 'informix'.pr_direcciones
					( numcte_pros, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
					estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
					VALUES
					( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
					pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );

					DELETE FROM 'informix'.pr_direcciones_actual
					WHERE numcte_pros = pNumCte 
					AND tipo_dir = pTipoDir;
				
					--- UPDATE STATISTICS MEDIUM FOR TABLE "informix".pr_direcciones_actual;
					-- // 1468-SE AGREGAN REGISTROS EN LA TABLA pr_direcciones_actual.
					INSERT INTO 'informix'.pr_direcciones_actual
					( numcte_pros, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
					estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
					VALUES
					( pNumCte, pSecuencia, pTipoDir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, "",
					pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt,pDepto, pNoCalle, pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros,pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert );
					
				END IF;

				-- // VALIDA LA INFORMACIÓN DE LOS TELEFONOS DEL CLIENTE
				SELECT telefono
				INTO o_telefono1
				FROM 'informix'.pr_telefonos
				WHERE numcte_pros = pNumCte
				AND tipo_tel = 1
				and fecha_hora =  (SELECT MAX(fecha_hora) FROM 'informix'.pr_telefonos WHERE numcte_pros = pNumCte AND tipo_tel = 1);

				IF o_telefono1 IS NULL THEN
					LET o_telefono1 = ' ';
				END IF;

				IF o_telefono1 <> pTelefono1 THEN
					IF cSucursal = '5002' THEN
						LET vCanal = 12;
					END IF;

					IF ( ( pTipoTel1 IS NOT NULL AND pTipoTel1 <> '' ) AND ( pTelefono1 IS NOT NULL AND pTelefono1 <> '' ) ) THEN
						LET vTipoTel = 1;
					CALL 'informix'.sp_registra_telefonos_pros(pEmpresa, pNumCte, pTelefono1, vTipoTel, '', 0, vCanal, pUser_Insert)
						RETURNING v_CodRetTel;
					END IF;
				END IF;

				SELECT telefono
				INTO o_telefono2
				FROM 'informix'.pr_telefonos
				WHERE numcte_pros = pNumCte
				AND tipo_tel = 2
				and fecha_hora =  (SELECT MAX(fecha_hora) FROM 'informix'.pr_telefonos WHERE numcte_pros = pNumCte AND tipo_tel = 2);

				IF o_telefono2 IS NULL THEN
					LET o_telefono2 = ' ';
				END IF;

				IF o_telefono2 <> pTelefono2 THEN
					IF cSucursal = '5002' THEN
						LET vCanal = 12;
					END IF;

					IF ( ( pTipoTel2 IS NOT NULL AND pTipoTel2 <> '' ) AND ( pTelefono2 IS NOT NULL AND pTelefono2 <> '' ) ) THEN
						LET vTipoTel = 2;
					CALL 'informix'.sp_registra_telefonos_pros(pEmpresa, pNumCte, pTelefono2, vTipoTel, '', pCarrier, vCanal, pUser_Insert)
						RETURNING v_CodRetTel;
					END IF;
				END IF;

				SELECT telefono, extension
				INTO o_telefono3, o_extension
				FROM 'informix'.pr_telefonos
				WHERE numcte_pros = pNumCte
				AND tipo_tel = 3
				AND fecha_hora =  (SELECT MAX(fecha_hora) FROM 'informix'.pr_telefonos WHERE numcte_pros = pNumCte AND tipo_tel = 3);

				IF o_telefono3 IS NULL THEN
					LET o_telefono3 = ' ';
				END IF;

				IF o_telefono3 <> pTelefono3 THEN
					IF cSucursal = '5002' THEN
						LET vCanal = 12;
					END IF;

					IF ( ( pTipoTel3 IS NOT NULL AND pTipoTel3 <> '' ) AND ( pTelefono3 IS NOT NULL AND pTelefono3 <> '' ) ) THEN
						LET vTipoTel = 3;
					CALL 'informix'.sp_registra_telefonos_pros(pEmpresa, pNumCte, pTelefono3, vTipoTel, pExtension, 0, vCanal, pUser_Insert)
						RETURNING v_CodRetTel;
					END IF;
				END IF;
			RETURN v_CodRet;
		END IF;
	END;
END PROCEDURE

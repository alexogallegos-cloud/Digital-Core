CREATE PROCEDURE "informix".sp_obtenerhomoclave_m(pNombre LVARCHAR)
	RETURNING CHAR(2) AS homoclave;

	DEFINE i INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE cNombreNumerico LVARCHAR;
	DEFINE iCodigoLetra SMALLINT;
	DEFINE bBoolValue BOOLEAN;
	DEFINE iSuma INTEGER;
	DEFINE iValor1 INTEGER;
	DEFINE iValor2 INTEGER;
	DEFINE iValor3 INTEGER;
	DEFINE iDiv1 INTEGER;
	DEFINE iDiv2 INTEGER;

	LET cCaracter = '';
	LET cNombreNumerico = '0';
	LET bBoolValue = 'f';
	LET iSuma = 0;
	LET iValor1 = 0;
	LET iValor2 = 0;
	LET iValor3 = 0;
	LET iDiv1 = 0;
	LET iDiv2 = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtenerhomoclave.out';
		--TRACE ON;

		FOR i = 1 TO LENGTH(TRIM(pNombre))
			LET cCaracter = UPPER(SUBSTR(TRIM(pNombre), i, 1));

			SELECT codigo_letra
			INTO iCodigoLetra
			FROM bdicnweb:"informix".letras_rfc_m
			WHERE UPPER(letra) = cCaracter;

			IF iCodigoLetra IS NULL THEN
				LET bBoolValue = 'f';
			ELSE
				LET cNombreNumerico = TRIM(cNombreNumerico)||iCodigoLetra;
				LET bBoolValue = 't';
			END IF;

			IF NOT bBoolValue THEN

				IF ASCII(cCaracter) = 209 THEN 
					LET cNombreNumerico = TRIM(cNombreNumerico)||40;
				ELIF ASCII(cCaracter) = 38 THEN 
					LET cNombreNumerico = TRIM(cNombreNumerico)||10;
				ELSE
					IF cCaracter = ' ' THEN
						LET cNombreNumerico = TRIM(cNombreNumerico)||'00';
					ELIF cCaracter::SMALLINT >= 0 AND cCaracter::SMALLINT <= 9 THEN
						LET cNombreNumerico = TRIM(cNombreNumerico)||LPAD(cCaracter, 2, '0');
					END IF;
				END IF;

			END IF;

		END FOR;

		FOR i = 1 TO LENGTH(TRIM(cNombreNumerico)) - 1
			LET iValor1 = SUBSTR(TRIM(cNombreNumerico), i, 2)::INTEGER;
			LET iValor2 = SUBSTR(TRIM(cNombreNumerico), (i + 1), 1)::INTEGER;
			LET iValor3 = iValor1 * iValor2;
			LET iSuma = iSuma + iValor3;
		END FOR;

		LET iDiv1 = MOD(iSuma, 1000);
		LET iDiv2 = MOD(iDiv1, 34);
		LET iDiv1 = (iDiv1 - iDiv2) / 34;

		SELECT digito
		INTO cCaracter
		FROM bdicnweb:"informix".homoclaves_rfc_m
		WHERE id_dverificador = (iDiv1 + 1);

		LET cNombreNumerico = cCaracter;

		SELECT digito
		INTO cCaracter
		FROM bdicnweb:"informix".homoclaves_rfc_m
		WHERE id_dverificador = (iDiv2 + 1);

		LET cNombreNumerico = TRIM(cNombreNumerico)||cCaracter;

		RETURN TRIM(cNombreNumerico);

	END;

END PROCEDURE
DOCUMENT "AUTOR: Daniel Reyes Guillen",
"FECHA: 24/06/2021",
"DESCRIPCION: Función que separa una cadena de acuerdo a un delimitador indicado";

CREATE PROCEDURE "informix".sp_obtienedigitoverificador_rfc_m(pRfc CHAR(13))
        RETURNING CHAR(1) AS digito_verificador;
        
        DEFINE cCaracter CHAR(1);
        DEFINE bBoolValue BOOLEAN;
        DEFINE i SMALLINT;
        DEFINE iCodigoLetra SMALLINT;
        DEFINE iOperacion INTEGER;
        DEFINE iModulo INTEGER;
        
        LET cCaracter = '';
        LET bBoolValue = 'f';
        LET iOperacion = 0;
        LET iModulo = 0;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN
        
                --SET DEBUG FILE TO '/tmp/mfinis/sp_obtienedigitoverificador_rfc_m.out';
               -- TRACE ON;
                
                FOR i = 1 TO LENGTH(TRIM(pRfc))
                        
                        LET cCaracter = SUBSTR(TRIM(pRfc), i, 1);
                        
                        SELECT codigo_letra
                        INTO iCodigoLetra
                        FROM bdicnweb:"informix".letras_codigoverificador_rfc_m
                        WHERE letra = cCaracter;
                        
                        IF iCodigoLetra IS NULL THEN
                                LET bBoolValue = 'f';
                        ELSE
                                LET bBoolValue = 't';
                        END IF;
                        
                        IF NOT bBoolValue THEN
                        
                                IF cCaracter = '' THEN
                                        LET iCodigoLetra = 24;
                                ELSE
                                        IF cCaracter = ' ' THEN
                                                LET iCodigoLetra = 37;
                                        ELSE
                                                IF cCaracter::INTEGER >= 0 AND cCaracter::INTEGER <= 9 AND ASCII(cCaracter) NOT IN (209) THEN
                                                        LET iCodigoLetra = cCaracter::INTEGER;
                                                ELSE
                                                        LET iCodigoLetra = 0;
                                                END IF;
                                        END IF;
                                END IF;
                        END IF;
                        
                        LET iOperacion = iOperacion + (iCodigoLetra * (14 - i));
                        
                END FOR;
                
                LET iModulo = ABS(MOD(iOperacion, 11));
                
                IF iModulo = 0 THEN
                        LET cCaracter = 0;
                ELIF iModulo > 0 THEN
                        LET iOperacion = 11 - iModulo;
						IF iOperacion = 10 THEN
							LET cCaracter = 'A';
						ELSE
							LET cCaracter = iOperacion;
						END IF;
                
                END IF;
                
                RETURN cCaracter;
                
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Daniel Reyes Guillen",
"FECHA: 24/06/2021",
"DESCRIPCION: Funcion que obtiene el digito verificador del rfc persona moral";

CREATE PROCEDURE "informix".sp_split_cadena_m(pCadena LVARCHAR, pDelimitador CHAR(1))
	RETURNING LVARCHAR AS palabra;
	
	DEFINE tPalabra LVARCHAR;
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE cPalabra LVARCHAR;
	
	LET tPalabra = '';
	LET iTamCad = LENGTH(TRIM(pCadena));
	LET cCaracter = '';
	LET cPalabra = '';
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres = 0;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_split_cadena.SQL';
		--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	BEGIN
	
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(pCadena), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			IF cCaracter = pDelimitador THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
	
				LET cPalabra = SUBSTR(TRIM(pCadena), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF cPalabra <> '' THEN
					RETURN cPalabra WITH RESUME;
				END IF;
			END IF;
			
		END LOOP;
		
		LET cPalabra = SUBSTR(TRIM(pCadena), iInicioCadena, iRecuperarCaracteres);
		IF cPalabra <> '' THEN
			RETURN cPalabra;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Daniel Reyes Guillen",
"FECHA: 24/16/2021",
"DESCRIPCION: Funcion que separa una cadena para el calculo del rfc";

CREATE PROCEDURE "informix".sp_consproddebcred(pEmpresa CHAR(3), pSistema SMALLINT, pNumCta CHAR(20), pNumTarjeta CHAR(20))
	RETURNING CHAR(5), CHAR(4), CHAR(40);

	-- *DEFINICION DE VARIABLES*
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cNumCuenta CHAR(20);

	-- *ASIGNACION DE VARIABLES*
	LET cCodRet = "000";
	LET iSqlErr = 0;
	LET cProducto = "";
	LET cDescProducto = "";
	LET cNumCuenta = "";

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cProducto, cDescProducto;
			END IF;
		END EXCEPTION;

	--	SET DEBUG FILE TO "/tmp/sp_ConsProdDebCred.out";
	--	TRACE ON;

		-- Valida Parametros de Entrada
		IF NVL(pEmpresa, "") = "" OR NVL(pSistema, 0) = 0 THEN
			LET cCodRet = "110";
			RETURN cCodRet, cProducto, cDescProducto;
		END IF

		IF pSistema = 1 then -- Sistema de Cheques
			IF NVL(pNumCta, "") <> "" THEN
				SELECT {+index (sc_maechq  idx_maechq1)}   --FMV 3-DIC-10
                 producto INTO cProducto
				FROM bdicheq:sc_maechq
				WHERE empresa = pEmpresa 
                  AND cuenta = pNumCta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT {+index (sc_maechq  ix174_3)}   --FMV 3-DIC-10
                nombre INTO cDescProducto
				FROM bdicheq:sc_producto
				WHERE empresa = pEmpresa 
                 AND producto = cProducto;
			ELIF NVL(pNumTarjeta, "") <> "" THEN
				SELECT {+index (sc_tarjeta  ix_tarjeta2)}   --FMV 3-DIC-10
                cuenta INTO cNumCuenta
				FROM bdicheq:sc_tarjeta
				WHERE empresa = pEmpresa 
                  AND num_tarjeta = pNumTarjeta;

				IF cNumCuenta IS NULL OR cNumCuenta = "" THEN
					LET cCodRet = "100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT {+index (sc_maechq idx_maechq1)}   --FMV 3-DIC-10
                producto INTO cProducto
				FROM bdicheq:sc_maechq
				WHERE empresa = pEmpresa 
                  AND cuenta = cNumCuenta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT {+index (sc_producto idx_producto1)}  --FMV 3-DIC-10
                nombre INTO cDescProducto
				FROM bdicheq:sc_producto
				WHERE empresa = pEmpresa 
                 AND producto = cProducto;
			ELSE
				LET cCodRet = "110";
				RETURN cCodRet, cProducto, cDescProducto;
			END IF;
		ELIF pSistema = 6 then -- Sistema de Credito
		--GMTTO3_PDRH.- 06-09-2018 INI: Se aÃ±ade con el fin de buscar en bdicred:sd_maecredcrd 
			IF NVL(pNumCta, "") <> "" THEN
			/*	SELECT {+index (sd_maecred maecred32)}  --FMV 3-DIC-10
                num_producto INTO cProducto
				FROM bdicred:sd_maecred
				WHERE empresa = pEmpresa 
                  AND num_credito = pNumCta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT {+index (sd_definicion 142_203)}  --FMV 3-DIC-10
                nombre_prod INTO cDescProducto
				FROM bdicred:sd_definicion
				WHERE empresa = pEmpresa 
                  AND num_producto = cProducto;*/

                SELECT num_producto INTO cProducto
				FROM bdicred:sd_maecred
				WHERE empresa = pEmpresa AND num_credito = pNumCta;

				IF cProducto IS NULL OR cProducto = "" THEN
                    SELECT num_producto INTO cProducto
                    FROM bdicred:sd_maecredcrd
                    WHERE empresa = pEmpresa AND num_credito = pNumCta;
                
                   IF cProducto IS NULL OR cProducto = "" THEN
					  LET cCodRet = "100";
					  RETURN cCodRet, cProducto, cDescProducto;
				   END IF;
                
                SELECT nombre_prod INTO cDescProducto
				FROM bdicred:sd_definicion
				WHERE empresa = pEmpresa AND num_producto = cProducto;
                
                END IF;
			--GMTTO3_PDRH.- 06-09-2018 FIN

			ELIF NVL(pNumTarjeta, "") <> "" THEN
				SELECT {+index (sd_tarjeta idx_tarjeta1)}  --FMV 3-DIC-10
                num_credito INTO cNumCuenta
				FROM bdicred:sd_tarjeta
				WHERE empresa = pEmpresa 
                  AND num_tarjeta = pNumTarjeta;

				IF cNumCuenta IS NULL OR cNumCuenta = "" THEN
					LET cCodRet = "100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT {+index (sd_maecred maecred32)}  --FMV 3-DIC-10
                num_producto INTO cProducto
				FROM bdicred:sd_maecred
				WHERE empresa = pEmpresa 
                  AND num_credito = cNumCuenta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT {+index (sd_definicion 142_203)}  --FMV 3-DIC-10
                nombre_prod INTO cDescProducto
				FROM bdicred:sd_definicion
				WHERE empresa = pEmpresa 
                  AND num_producto = cProducto;
			ELSE
				LET cCodRet = "110";
				RETURN cCodRet, cProducto, cDescProducto;
			END IF;
		END IF;
		RETURN cCodRet, cProducto, cDescProducto;
	END
END PROCEDURE
DOCUMENT
"DESCRIPCION: Consulta el Numero y Descripcion del Producto de la Cuenta o Tarjeta",
"AUTOR: Iris Arias Zazueta",
"FECHA: 08/11/2010",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_cnsif_movtranele_16agos21(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cTIPOABONO CHAR(1),cNUMCUENTA CHAR(20),dPERIODOI DATE, dPERIODOF DATE,pNumRegistro INTEGER,pRecuperacion INTEGER)

				returning CHAR(5)        AS Cod_Retorno,
						  CHAR(30)       AS DescripcionOperacion,
						  DATE           AS Fecha_Operacion,
						  DATE           AS Fecha_Aplicacion,
						  CHAR(20)       AS Procedencia,
						  CHAR(50)       AS Desc_Procedencia,
						  CHAR(20)       AS Cuenta_Origen,
                          CHAR(20)       AS Cuenta_Destino,
						  MONEY(19,2)    AS Importe,
						  CHAR(50)       AS Referencia_Pago,
						  CHAR(16)       AS Folio_Sucursal,
						  CHAR(81)       AS Bancorec_BancoPres,
						  CHAR(20)       AS Status,
						  CHAR(100)      AS Causa_Rechazo,
                          CHAR(2)        AS Tipo_Operacion;

DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE cDescripcionOperacion CHAR(30);
DEFINE dFechaOperacion       DATE;
DEFINE dFechaAplicacion      DATE;
DEFINE cProcedencia          CHAR(20);
DEFINE cDescProcedencia      CHAR(50);
DEFINE cCuentaOrigen         CHAR(20);
DEFINE cCuentaDestino		 CHAR(20);
DEFINE mImporte              MONEY(19,2);
DEFINE cReferenciaPago		 CHAR(50);
DEFINE cFolioSucursal		 CHAR(16);
DEFINE cBancoRecBancoPres    CHAR(81);
DEFINE cStatus               CHAR(20);
DEFINE cCausaRechazo         CHAR(100);
DEFINE cTipo_Oper            CHAR(2);

DEFINE cMesI                 CHAR(02);
DEFINE cDiaI				 CHAR(02);
DEFINE cMesF                 CHAR(02);
DEFINE cDiaF				 CHAR(02);
DEFINE vsImporte             CHAR(16);
DEFINE vsFechaTrans          CHAR(10);
DEFINE vsFechaAplic          CHAR(10);
DEFINE cBancoRec             CHAR(35);
DEFINE cBancoPres            CHAR(35);
DEFINE cNunTarjeta           CHAR(16);
DEFINE cSucursal             CHAR(04);
DEFINE cCveCausa             CHAR(01);
DEFINE iCont                 INTEGER;

--INICIALIZA VARIABLES
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;
LET cDescripcionOperacion    = '';
LET dFechaOperacion          = '';
LET dFechaAplicacion         = '';
LET cProcedencia             = '';
LET cDescProcedencia         = '';
LET cCuentaOrigen            = '';
LET cCuentaDestino           = '';
LET mImporte                 = 0;
LET cReferenciaPago          = '';
LET cFolioSucursal           = '';
LET cBancoRecBancoPres       = '';
LET cStatus                  = '';
LET cCausaRechazo            = '';
LET cTipo_Oper               ='';

LET cMesI           = '';
LET cDiaI		    = '';
LET cMesF           = '';
LET cDiaF		    = '';
LET vsImporte       = '';
LET vsFechaTrans    = '';
LET vsFechaAplic    = '';
LET cBancoRec       = '';
LET cBancoPres      = '';
LET cNunTarjeta     = '';
LET cSucursal       = '';
LET cCveCausa       = '';
LET iCont           = 0;



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
		END IF;
	END EXCEPTION;

	  --SET DEBUG FILE TO "/informix/VH/cnsiflib/sp_cnsif_movtranele.out";
	  --TRACE ON;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cTIPOABONO  = ''    OR
		cNUMCUENTA  = ''	THEN
		LET cCodRet = "00042";
		RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
    END IF

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
		RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
        END IF;
    END IF;   

	IF cTIPOABONO <> 'E' AND cTIPOABONO <> 'R' THEN
		LET cCodRet = "00044";
		RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
	END IF;


	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'05','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
               mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
	END IF;

	FOREACH
	SELECT FIRST 1 NVL(COUNT(cuenta),0) into iexiste FROM bdicheq:sc_maechq WHERE cuenta  = cNUMCUENTA
	UNION
	SELECT NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE cuenta_tf  = cNUMCUENTA
	ORDER BY 1 DESC
	END FOREACH;
	IF iexiste  = 0 THEN
		LET cCodRet = "00043";
		RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
	END IF;

    IF pNumRegistro=0 THEN
		DELETE {+INDEX (bdinteg:si_tempomovtranele idx_tempoctacte)} from si_tempomovtranele WHERE ejecutivosif= cID_USUARIOC;
        SET ISOLATION TO DIRTY READ;
		IF cTIPOABONO = 'E' THEN
			-- ENVIOS SPEI
				SET ISOLATION TO DIRTY READ;
				FOREACH
						SELECT  
						'TRANSFERENCIA SPEI'  AS Descripcion_Operacion,
						tbpa.dtfechavalor,
						tbpa.dtfechacaptura,
						SUBSTR(tbpa.vchrcuentaord,7,11),
						tbpa.vchrcuentabenef,
						tbpa.mnyimporte,
						tbpa.vchrclaverastreo,
						tbpa.chrfolioprom,
						DECODE(tbpa.chrestatusenvio,
					   'L','Liquidada',            'I','Intención Pago',
					   'M','por Devolver',         'A','Abonada',
					   'D','Devuelta',             'B','por Abonar',
					   'P','por Autorización',     'E','Enviada',
					   'X','por   Autreversar' ,   'R','Recibida',
					   'N', 'Pendiente Enviar',    'T','por Enviar',
					   'W','Cancelada SPEI',       'C','Cancelada',
					   'Q','Reenvio',              'K', 'Recibiendo',
					   'Otro') chrestatusenvio,
					   tbbn.vchrnombrecorto AS cesifbcod,
					   CASE
					   WHEN tbpa.intcvecausadev IS NULL THEN
						   ''
					   END AS intcvecausadev
				INTO
					cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cCuentaOrigen,cCuentaDestino,
					mImporte,cReferenciaPago,cFolioSucursal,cStatus,cBancoRecBancoPres,cCveCausa
				FROM  bdispei:tblpago tbpa
				LEFT JOIN bdispei:tblbanco tbbn ON tbpa.cvecesifbcodest = tbbn.cvecesif
				WHERE SUBSTR(vchrcuentaord,7,11) = cNUMCUENTA
				AND tbpa.chrsentidopago = cTIPOABONO
				AND tbpa.dtfechavalor BETWEEN dPERIODOI AND dPERIODOF
			UNION
				SELECT  'TRANSFERENCIA SPEI' AS Descripcion_Operacion,
						tbpa.dtfechavalor,
						tbpa.dtfechacaptura,
						SUBSTR(tbpa.vchrcuentaord,7,11),
						tbpa.vchrcuentabenef,
						tbpa.mnyimporte,
						tbpa.vchrclaverastreo,
						tbpa.chrfolioprom,
						DECODE(tbpa.chrestatusenvio,
					   'L','Liquidada',            'I','Intención Pago',
					   'M','por Devolver',         'A','Abonada',
					   'D','Devuelta',             'B','por Abonar',
					   'P','por Autorización',     'E','Enviada',
					   'X','por   Autreversar' ,   'R','Recibida',
					   'N', 'Pendiente Enviar',    'T','por Enviar',
					   'W','Cancelada SPEI',       'C','Cancelada',
					   'Q','Reenvio',              'K', 'Recibiendo',
					   'Otro') chrestatusenvio,
					   tbbn.vchrnombrecorto as cesifbcod,
					   CASE
					   WHEN tbpa.intcvecausadev IS NULL THEN
						   ''
					   END AS intcvecausadev
				FROM  bdispei:tblhistpago tbpa
				LEFT JOIN bdispei:tblbanco tbbn ON tbpa.cvecesifbcodest = tbbn.cvecesif
				WHERE SUBSTR(vchrcuentaord,7,11) = cNUMCUENTA
				AND tbpa.chrsentidopago = cTIPOABONO
				AND tbpa.dtfechavalor BETWEEN dPERIODOI AND dPERIODOF

				IF cCveCausa != '' THEN
					SELECT vchrdescripcion
					INTO cCausaRechazo
					FROM tblcausadev
					WHERE intcvecausadev = cCveCausa;
				END IF

				FOREACH
					   SELECT LIMIT 1 sucursal
						INTO cSucursal
						FROM  bdicheq:sc_movdia
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					/*UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old2
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old3
						WHERE folio_suc = cFolioSucursal AND empresa= '001'*/
				END FOREACH;


				SELECT procedencia,descripcion
				INTO cProcedencia,cDescProcedencia
				FROM bdinteg:si_procedencia
				WHERE sucursal = cSucursal
				AND  transacc ='';

				IF cDescProcedencia = '' THEN
				   LET cDescProcedencia = 'SUCURSAL';
				END IF;

				INSERT INTO si_tempomovtranele(cod_ret, descrip_oper, fecha_oper, fecha_aplica, procedencia, desc_procedencia, cuenta_origen, cuenta_destino, importe, referencia, folio, banco, status, causa_rechazo, tipo_oper,cuenta_cliente,ejecutivosif)
				VALUES(cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,'C',cNUMCUENTA,cID_USUARIOC);
			END FOREACH;

			SELECT num_tarjeta
			INTO cNunTarjeta
			FROM bdicheq:sc_tarjeta
			WHERE  cuenta = cNUMCUENTA AND status_tar='A' AND tipo_tarjeta='T';

			--TRATAMIENTOA dPERIODOI Y dPERIODOF
			IF MONTH(dPERIODOI) <10 THEN
				LET cMesI = '0' || MONTH(dPERIODOI);
			ELSE
				LET cMesI = MONTH(dPERIODOI);
			END IF

			IF DAY(dPERIODOI) <10 THEN
				LET cDiaI = '0' || DAY(dPERIODOI);
			ELSE
				LET cDiaI = DAY(dPERIODOI);
			END IF

			IF MONTH(dPERIODOF) <10 THEN
				LET cMesF = '0' || MONTH(dPERIODOF);
			ELSE
				LET cMesF = MONTH(dPERIODOF);
			END IF

			IF DAY(dPERIODOF) < 10 THEN
				LET cDiaF = '0' || DAY(dPERIODOF);
			ELSE
				LET cDiaF = DAY(dPERIODOF);
			END IF

			SET ISOLATION TO DIRTY READ;

			FOREACH
				SELECT {+INDEX (bditef:tef_status_pago 139_359)} 'ENVIOS TEF' AS Descripicon_Operacion,ccedet.fecha_trans,ccedet.fecha_aplica, cNUMCUENTA,ccedet.num_cta_rec ,
				ccedet.importe, ccedet.clave_rastreo,ccedet.folio_suc, siban.descripcion,siban1.descripcion, statp.descripcion, catr.descripcion
				INTO
				cDescripcionOperacion,vsFechaTrans,vsFechaAplic,cCuentaOrigen,cCuentaDestino,
				vsImporte,cReferenciaPago,cFolioSucursal,cBancoRec,cBancoPres,cStatus,cCausaRechazo
				FROM bditef:"informix".tef_cce_detalle AS ccedet,
				bdinteg:"informix".si_bancos AS siban,
				bdinteg:"informix".si_bancos AS siban1,
				bditef:"informix".tef_status_pago AS statp,
				bditef:"informix".tef_cat_rechazos AS catr
				WHERE ccedet.cod_operacion = '60'
				AND ccedet.fecha_trans BETWEEN (YEAR(dPERIODOI) ||  cMesI || cDiaI) AND (YEAR(dPERIODOF) ||  cMesF || cDiaF)
				AND ccedet.banco_receptor = siban.banco
				AND ccedet.banco_presentador = siban1.banco
				AND ccedet.cve_status = statp.cve_status
				AND ccedet.motivo_dev = catr.cve_rechazo
				AND ((SUBSTRING(ccedet.num_cta_ord FROM 9 FOR 11) = cNUMCUENTA) OR (SUBSTRING(ccedet.num_cta_ord FROM 5 FOR 16) = cNunTarjeta))
				ORDER  BY ccedet.fecha_trans, ccedet.importe

				LET cCodRet = "00000";
				LET dFechaOperacion = EXTEND(MDY(SUBSTRING(vsFechaTrans FROM 5 FOR 2),SUBSTRING(vsFechaTrans FROM 7 FOR 2),SUBSTRING(vsFechaTrans FROM 1 FOR 4)), YEAR TO SECOND);
				LET dFechaAplicacion = EXTEND(MDY(SUBSTRING(vsFechaAplic FROM 5 FOR 2),SUBSTRING(vsFechaAplic FROM 7 FOR 2),SUBSTRING(vsFechaAplic FROM 1 FOR 4)), YEAR TO SECOND);
				LET mImporte = round(vsImporte / 100, 2);
				LET cFolioSucursal = TRIM(cFolioSucursal);
				LET cBancoRecBancoPres = TRIM(cBancoRec) || "/" || TRIM(cBancoPres);

				FOREACH
					   SELECT LIMIT 1 sucursal
						INTO cSucursal
						FROM  bdicheq:sc_movdia
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					/*UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old2
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old3
						WHERE folio_suc = cFolioSucursal AND empresa= '001'*/
				END FOREACH;


				SELECT procedencia,descripcion
				INTO cProcedencia,cDescProcedencia
				FROM bdinteg:si_procedencia
				WHERE sucursal = cSucursal
				AND  transacc ='';

				IF cDescProcedencia = '' THEN
				   LET cDescProcedencia = 'SUCURSAL';
				END IF;

				INSERT INTO si_tempomovtranele(cod_ret, descrip_oper, fecha_oper, fecha_aplica, procedencia, desc_procedencia, cuenta_origen, cuenta_destino, importe, referencia, folio, banco, status, causa_rechazo, tipo_oper, cuenta_cliente,ejecutivosif)
				VALUES(cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,'C',cNUMCUENTA,cID_USUARIOC);
			END FOREACH

		ELSE
			SELECT num_tarjeta
			INTO cNunTarjeta
			FROM bdicheq:sc_tarjeta
			WHERE  cuenta = cNUMCUENTA AND status_tar='A' AND tipo_tarjeta='T';

			FOREACH
						SELECT  
						'TRANSFERENCIA SPEI'  AS Descripcion_Operacion,
						tbpa.dtfechavalor,
						tbpa.dtfechacaptura,
						tbpa.vchrcuentaord,
						cNUMCUENTA,
						tbpa.mnyimporte,
						tbpa.vchrclaverastreo,
						tbpa.chrfolioprom,
						DECODE(tbpa.chrestatusenvio,
					   'L','Liquidada',            'I','Intención Pago',
					   'M','por Devolver',         'A','Abonada',
					   'D','Devuelta',             'B','por Abonar',
					   'P','por Autorización',     'E','Enviada',
					   'X','por   Autreversar' ,   'R','Recibida',
					   'N', 'Pendiente Enviar',    'T','por Enviar',
					   'W','Cancelada SPEI',       'C','Cancelada',
					   'Q','Reenvio',              'K', 'Recibiendo',
					   'Otro') chrestatusenvio,
					   tbbn.vchrnombrecorto AS cesifbcod,
					   CASE
					   WHEN tbpa.intcvecausadev IS NULL THEN
						   ''
					   END AS intcvecausadev
				INTO
					cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cCuentaOrigen,cCuentaDestino,
					mImporte,cReferenciaPago,cFolioSucursal,cStatus,cBancoRecBancoPres,cCveCausa
				FROM  bdispei:tblpago tbpa
				LEFT JOIN bdispei:tblbanco tbbn ON tbpa.cvecesifbcoord = tbbn.cvecesif
				WHERE ((SUBSTR(vchrcuentabenef,7,11) = cNUMCUENTA) OR (vchrcuentabenef = cNunTarjeta))
				AND tbpa.chrsentidopago = cTIPOABONO
				AND tbpa.dtfechavalor BETWEEN dPERIODOI AND dPERIODOF
			UNION
				SELECT  'TRANSFERENCIA SPEI' AS Descripcion_Operacion,
						tbpa.dtfechavalor,
						tbpa.dtfechacaptura,
						tbpa.vchrcuentaord,
						cNUMCUENTA,
						tbpa.mnyimporte,
						tbpa.vchrclaverastreo,
						tbpa.chrfolioprom,
						DECODE(tbpa.chrestatusenvio,
					   'L','Liquidada',            'I','Intención Pago',
					   'M','por Devolver',         'A','Abonada',
					   'D','Devuelta',             'B','por Abonar',
					   'P','por Autorización',     'E','Enviada',
					   'X','por   Autreversar' ,   'R','Recibida',
					   'N', 'Pendiente Enviar',    'T','por Enviar',
					   'W','Cancelada SPEI',       'C','Cancelada',
					   'Q','Reenvio',              'K', 'Recibiendo',
					   'Otro') chrestatusenvio,
					   tbbn.vchrnombrecorto as cesifbcod,
					   CASE
					   WHEN tbpa.intcvecausadev IS NULL THEN
						   ''
					   END AS intcvecausadev
				FROM  bdispei:tblhistpago tbpa
				LEFT JOIN bdispei:tblbanco tbbn ON tbpa.cvecesifbcoord = tbbn.cvecesif
				WHERE ((SUBSTR(vchrcuentabenef,7,11) = cNUMCUENTA) OR ( vchrcuentabenef = cNunTarjeta))
				AND tbpa.chrsentidopago = cTIPOABONO
				AND tbpa.dtfechavalor BETWEEN dPERIODOI AND dPERIODOF

				IF cCveCausa != '' THEN
					SELECT vchrdescripcion
					INTO cCausaRechazo
					FROM tblcausadev
					WHERE intcvecausadev = cCveCausa;
				END IF

				FOREACH
					   SELECT LIMIT 1 sucursal
						INTO cSucursal
						FROM  bdicheq:sc_movdia
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					/*UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old2
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old3
						WHERE folio_suc = cFolioSucursal AND empresa= '001'*/
				END FOREACH;


				SELECT procedencia,descripcion
				INTO cProcedencia,cDescProcedencia
				FROM bdinteg:si_procedencia
				WHERE sucursal = cSucursal
				AND  transacc ='';

				IF cDescProcedencia = '' THEN
				   LET cDescProcedencia = 'SUCURSAL';
				END IF;

				INSERT INTO si_tempomovtranele(cod_ret, descrip_oper, fecha_oper, fecha_aplica, procedencia, desc_procedencia, cuenta_origen, cuenta_destino, importe, referencia, folio, banco, status, causa_rechazo,tipo_oper ,cuenta_cliente,ejecutivosif)
				VALUES(cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,'A',cNUMCUENTA,cID_USUARIOC);

			END FOREACH;

			SELECT num_tarjeta
			INTO cNunTarjeta
			FROM bdicheq:sc_tarjeta
			WHERE  cuenta = cNUMCUENTA AND status_tar='A' AND tipo_tarjeta='T';

			--TRATAMIENTOA dPERIODOI Y dPERIODOF
			IF MONTH(dPERIODOI) <10 THEN
				LET cMesI = '0' || MONTH(dPERIODOI);
			ELSE
				LET cMesI = MONTH(dPERIODOI);
			END IF

			IF DAY(dPERIODOI) <10 THEN
				LET cDiaI = '0' || DAY(dPERIODOI);
			ELSE
				LET cDiaI = DAY(dPERIODOI);
			END IF

			IF MONTH(dPERIODOF) <10 THEN
				LET cMesF = '0' || MONTH(dPERIODOF);
			ELSE
				LET cMesF = MONTH(dPERIODOF);
			END IF

			IF DAY(dPERIODOF) <10 THEN
				LET cDiaF = '0' || DAY(dPERIODOF);
			ELSE
				LET cDiaF = DAY(dPERIODOF);
			END IF

			SET ISOLATION TO DIRTY READ;

			FOREACH
				SELECT {+INDEX (bditef:tef_status_pago 139_359)} 'RECEPCION TEF' AS Descripicon_Operacion,ccedet.fecha_trans,ccedet.fecha_aplica, ccedet.num_cta_ord,cNUMCUENTA , ccedet.importe, ccedet.clave_rastreo,ccedet.folio_suc, siban.descripcion,
				siban1.descripcion, statp.descripcion, catr.descripcion
				INTO
					cDescripcionOperacion,vsFechaTrans,vsFechaAplic,cCuentaOrigen,cCuentaDestino,
					vsImporte,cReferenciaPago,cFolioSucursal,cBancoRec,cBancoPres,cStatus,cCausaRechazo
				FROM bditef:"informix".tef_cce_detalle AS ccedet,
				bdinteg:"informix".si_bancos AS siban,
				bdinteg:"informix".si_bancos AS siban1,
				bditef:"informix".tef_status_pago AS statp,
				bditef:"informix".tef_cat_rechazos AS catr
				WHERE ccedet.cod_operacion = '60'
				AND ccedet.fecha_trans BETWEEN (YEAR(dPERIODOI) ||  cMesI || cDiaI) AND (YEAR(dPERIODOF) ||  cMesF || cDiaF)
				AND ccedet.banco_receptor = siban.banco
				AND ccedet.banco_presentador = siban1.banco
				AND ccedet.cve_status = statp.cve_status
				AND ccedet.motivo_dev = catr.cve_rechazo
				AND ((SUBSTRING(ccedet.num_cta_rec FROM 9 FOR 11) = cNUMCUENTA) OR (SUBSTRING(ccedet.num_cta_rec FROM 5 FOR 16) = cNunTarjeta))
				ORDER BY ccedet.fecha_trans, ccedet.importe

				LET cCodRet = "00000";
				LET dFechaOperacion = EXTEND(MDY(SUBSTRING(vsFechaTrans FROM 5 FOR 2),SUBSTRING(vsFechaTrans FROM 7 FOR 2),SUBSTRING(vsFechaTrans FROM 1 FOR 4)), YEAR TO SECOND);
				LET dFechaAplicacion = EXTEND(MDY(SUBSTRING(vsFechaAplic FROM 5 FOR 2),SUBSTRING(vsFechaAplic FROM 7 FOR 2),SUBSTRING(vsFechaAplic FROM 1 FOR 4)), YEAR TO SECOND);
				LET mImporte = round(vsImporte / 100, 2);
				LET cFolioSucursal = TRIM(cFolioSucursal);
				LET cBancoRecBancoPres = TRIM(cBancoRec) || "/" || TRIM(cBancoPres);

				FOREACH
					   SELECT LIMIT 1 sucursal
						INTO cSucursal
						FROM  bdicheq:sc_movdia
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					/*UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old2
						WHERE folio_suc = cFolioSucursal AND empresa= '001'
					UNION
						SELECT sucursal
						FROM bdicheq:sc_movhis_old3
						WHERE folio_suc = cFolioSucursal AND empresa= '001'*/
				END FOREACH;


				SELECT procedencia,descripcion
				INTO cProcedencia,cDescProcedencia
				FROM bdinteg:si_procedencia
				WHERE sucursal = cSucursal
				AND  transacc = '';

				IF cDescProcedencia = '' THEN
				   LET cDescProcedencia = 'SUCURSAL';
				END IF;

				INSERT INTO si_tempomovtranele(cod_ret, descrip_oper, fecha_oper, fecha_aplica, procedencia, desc_procedencia, cuenta_origen, cuenta_destino, importe, referencia, folio, banco, status, causa_rechazo,tipo_oper ,cuenta_cliente,ejecutivosif)
				VALUES(cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,'A',cNUMCUENTA,cID_USUARIOC);

			END FOREACH
		END IF;

        SELECT NVL(COUNT(cod_ret),0) into iexiste FROM si_tempomovtranele WHERE cuenta_cliente = cNUMCUENTA AND ejecutivosif= cID_USUARIOC;
        IF iexiste  = 0 THEN 
            LET cCodRet = "00091";
            RETURN
            cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
        END IF;	
	END IF;

	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT {+INDEX (bdinteg:si_tempomovtranele idx_tempoctacte)} SKIP pNumRegistro FIRST pRecuperacion cod_ret, descrip_oper, fecha_oper, fecha_aplica, procedencia, desc_procedencia, cuenta_origen, cuenta_destino, importe, referencia,
		folio, banco, status, causa_rechazo, tipo_oper INTO cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
        mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper
		FROM si_tempomovtranele WHERE cuenta_cliente = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY fecha_oper DESC

		LET iCont=iCont+1;

		RETURN cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
        mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper WITH resume;
	END FOREACH;

	IF iCont = 0 THEN
		DELETE {+INDEX (bdinteg:si_tempomovtranele idx_tempoctacte)} from si_tempomovtranele WHERE ejecutivosif= cID_USUARIOC;
		LET cCodRet = '1001';
		RETURN
			cCodRet,cDescripcionOperacion,dFechaOperacion,dFechaAplicacion,cProcedencia,cDescProcedencia,cCuentaOrigen,cCuentaDestino,
            mImporte,cReferenciaPago,cFolioSucursal,cBancoRecBancoPres,cStatus,cCausaRechazo,cTipo_Oper;
	END IF;

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Movimientos de Cargos de la Transferencias Electrónicas que realiza un Cliente. ",
"El SP obtendrá la información  de la Base de Datos central de Informix, enviando como parámetro el Tipo Movimiento, Número de Cuenta, Periodo Del, Periodo Al.",
"FECHA : 13-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultaciudades(pEstado Char(2),pNumCiudad char(3),pNomCiudad char(30), pRegistros INTEGER)
RETURNING CHAR(6)  AS Codigo_Retorno,
          CHAR(80) AS Mensaje_Retorno,
		  CHAR(3)  AS Ciudad,
		  CHAR(30) AS Nombre;          
          
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);
DEFINE cComentario       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE vCont 			 INTEGER;
DEFINE iValor 			 INTEGER;
DEFINE cCiudad   		 CHAR(3); 
DEFINE cNombre     		 CHAR(30); 

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
   END IF;
END EXCEPTION;

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'Se realizÃ³ la consulta correctamente';
LET vCont 					 = 0;
LET iValor 					 = 0;
LET cCiudad                  = 0;
LET cNombre                  = '';

--Set debug file to '/home/sysifx/jesusm/sp_ConsultaCiudades.out';
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	  
IF pEstado IS NULL OR pEstado = "" THEN
    LET cCodRet                  = '000001';
	LET cMensajeRet              = 'El parÃ¡metro  numero de estado esta vaciÃ³';
	RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
END IF;

--obtencion del valor  para realizar la paginacion.
	SELECT valor::integer 
		INTO iValor
	FROM bdicobranza:cb_param 
	WHERE empresa = '001' 
	AND cod_param = '32';
--validacion de los parametros.
IF iValor IS NULL OR  iValor = "" THEN
    LET cCodRet                  = '000002';
	LET cMensajeRet              = 'Error al obtener el parÃ¡metro del mÃ¡ximo numero de registros';
	RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
END IF;
--se valida si el parametro numero de ciudad tiene informacion para ser consultado, y obtener la informacion de dicha ciudad
IF pNumCiudad <> '' THEN
	SELECT {+INDEX(si_ciduades  ix_2363)}  c.ciudad,c.nombre
		INTO cCiudad,cNombre
	FROM bdinteg:si_Ciudades c	
	INNER JOIN bdinteg: si_estados d ON ( d.pais='001' AND d.estado=pEstado and c.estado=d.estado)	
	WHERE c.pais ='001'	
	AND c.estado=c.estado
    AND c.ciudad=pNumCiudad; 
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
			
			SELECT {+INDEX(si_ciduades  ix_2363)}  c.ciudad,c.nombre
			INTO cCiudad,cNombre
			FROM bdinteg:si_Ciudades c	
			INNER JOIN bdinteg: si_estados d ON ( d.pais='001' AND d.estado=pEstado and c.estado=d.estado)	
			WHERE c.pais ='001'	
			AND c.estado=c.estado
			AND c.ciudad_coppel=pNumCiudad;
			
		LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN	
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
		END IF;
		
		RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
		
		END IF;
		
	RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
END IF;

--se obtienen los registros  indicados en el parametro obtenido con anterioridad que tengan similitud al la consulta
	FOREACH WITH HOLD
	
		SELECT {+INDEX(si_ciduades  ix_2363)} SKIP pRegistros FIRST iValor c.ciudad,c.nombre
			INTO cCiudad,cNombre
			FROM bdinteg:si_Ciudades c	
			INNER JOIN bdinteg: si_estados d ON ( d.pais='001' AND d.estado=pEstado and c.estado=d.estado)	
			WHERE c.pais ='001'	 
			AND c.estado=c.estado  
			AND c.ciudad=c.ciudad
			AND UPPER(TRIM(c.nombre)) LIKE CASE when pNomCiudad = '' THEN UPPER(c.nombre)   ELSE '%'||UPPER(TRIM(pNomCiudad))||'%' END 
			ORDER BY c.nombre	
			
			RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'') WITH RESUME;
	END FOREACH;
	
		LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet, cMensajeRet,NVL(cCiudad,''),NVL(cNombre,'');
		END IF;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para Obtener el listado de ciudades existentes para un estado especifico',
' y/o obtener coincidencias por descripcion de ciudad.',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 08/SEPTIEMBRE/2010',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_consultacoloniascp(pEstado Char(2),pNumCiudad char(3),pNumColonia INTEGER,pNomZona char(32), pRegistros INTEGER)
RETURNING CHAR(6)  AS Codigo_Retorno,
          CHAR(80) AS Mensaje_Retorno,
		  INTEGER  AS Colonia,
		  CHAR(32) AS Nombre,
		  INTEGER  AS Codigo_Postal,
		  CHAR(1) AS Unidad_Habitacional;          
          
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);
DEFINE cComentario       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE vCont 			 INTEGER;
DEFINE iValor 			 INTEGER;
DEFINE iColonia   		 INTEGER; 
DEFINE iCodigoPostal   	 INTEGER; 
DEFINE cNombre     		 CHAR(32); 
DEFINE cUniHab			 CHAR(1);

BEGIN


ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
   END IF;
END EXCEPTION;

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'Se realizÃ³ la consulta correctamente';
LET vCont 					 = 0;
LET iValor 					 = 0;
LET iColonia                  = 0;
LET iCodigoPostal             = 0;
LET cNombre                  = '';
LET cUniHab					  = '';

--Set debug file to '/tmp/sp_ConsultaColonias.out';
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF pEstado IS NULL OR pEstado = "" THEN
    LET cCodRet                  = '000001';
	LET cMensajeRet              = 'El parÃ¡metro  numero de estado esta vaciÃ³';
	RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
END IF;  
IF pNumCiudad IS NULL OR pNumCiudad = "" THEN
    LET cCodRet                  = '000002';
	LET cMensajeRet              = 'El parÃ¡metro  numero de ciudad esta vaciÃ³';
	RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
END IF;

--obtencion del valor  para realizar la paginacion.
	SELECT valor::integer 
		INTO iValor
	FROM bdicobranza:cb_param 
	WHERE empresa = '001' 
	AND cod_param = '32';
--validacion de los parametros.
IF iValor IS NULL OR  iValor = "" THEN
    LET cCodRet                  = '000002';
	LET cMensajeRet              = 'Error al obtener el parÃ¡metro del mÃ¡ximo numero de registros';
	RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
END IF;
--se valida si el parametro numero de colonia tiene informacion para ser consultado, y obtener la informacion de dicha colonia
IF pNumColonia > 0 THEN
	SELECT   {+ INDEX (bdinteg:si_catzonas idx_catzonass)}  z.numerocolonia,z.nombrezona,codigopostalzona, z.marcaunidadhabitacional
		INTO iColonia,cNombre,iCodigoPostal, cUniHab
	FROM bdinteg:si_catzonas z	
	INNER JOIN bdinteg: si_estados e ON ( e.estado=pEstado)	
	INNER JOIN bdinteg: si_ciudades c ON ( c.estado=e.estado AND c.ciudad=pNumCiudad)	
	INNER JOIN bdinteg:si_catciudades cat ON (c.ciudad_coppel = cat.numerociudad)   	
	--WHERE z.numerociudad = pNumCiudad 
	WHERE z.numerociudad = c.ciudad_coppel     
	AND z.numerocolonia = pNumColonia
	AND NVL(z.nombrezona,'') <> '';             
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
		
		SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonass)}  z.numerocolonia,z.nombrezona,codigopostalzona, z.marcaunidadhabitacional
        INTO iColonia, cNombre, iCodigoPostal, cUniHab
        FROM bdinteg:si_catzonas z
        INNER JOIN bdinteg: si_estados e ON ( e.estado=pEstado)   
        INNER JOIN bdinteg: si_ciudades c ON  c.estado=e.estado AND c.ciudad_coppel = pNumCiudad
        INNER JOIN bdinteg:si_catciudades cat ON (c.ciudad_coppel = cat.numerociudad)      
        WHERE z.numerociudad = c.ciudad_coppel    
        AND z.numerocolonia = pNumColonia
        AND NVL(z.nombrezona,'') <> '';  
		
		LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
		END IF;
		
		RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
		END IF;
		
	 RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
END IF;

--se obtienen los registros  indicados en el parametro obtenido con anterioridad que tengan similitud a la consulta
	FOREACH WITH HOLD
	
		SELECT  {+ INDEX (bdinteg:si_catzonas idx_catzonass)}  SKIP pRegistros FIRST iValor z.numerocolonia,z.nombrezona,z.codigopostalzona, z.marcaunidadhabitacional
			INTO iColonia,cNombre,iCodigoPostal, cUniHab
			FROM bdinteg:si_catzonas z				
			INNER JOIN bdinteg: si_estados e ON ( e.estado=pEstado)	
			INNER JOIN bdinteg: si_ciudades c ON ( c.estado=e.estado AND c.ciudad=pNumCiudad)	
			INNER JOIN bdinteg:si_catciudades cat ON (c.ciudad_coppel = cat.numerociudad)   	
			--WHERE z.numerociudad = pNumCiudad
			WHERE z.numerociudad = c.ciudad_coppel 
			AND z.numerocolonia = z.numerocolonia 
			AND UPPER(TRIM(nombrezona)) LIKE CASE when pNomZona = '' THEN UPPER(nombrezona)   ELSE '%'||UPPER(TRIM(pNomZona))||'%' END
			AND NVL(z.nombrezona,'') <> ''
			ORDER BY nombrezona	
			
			 RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0) , trim(cUniHab) WITH RESUME;
	END FOREACH;
	
		LET vCont = dbinfo("sqlca.sqlerrd2");
		IF vCont = 0 THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
		END IF;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para  Obtener el listado de colonias  y su respectivo codigo postal existentes para una ciudad y estado especifico',
'y/o obtener coincidencias por descripcion de colonia.',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 08/SEPTIEMBRE/2010',
'BD    : BDINTEG',
'MODIFICACION: Se agrega retorno de unidad habitacional, para indicar si la colonia cuenta con unidad habitacional ',
'MODIFICO: Abigail Vasavilbazo CaÃ±edo',
'VERSION:20110204.1246',
'2012/08/28. Validar que la colonia no venga en blanco, caso muy esporÃ¡dico. By: MACF';

CREATE PROCEDURE "informix".spregresahuellac( ptipo CHAR(1), pnumcte CHAR(20), pfechaini DATE, pfechafin DATE )
RETURNING INTEGER, char(20), SMALLINT, CHAR(1), CHAR(942), CHAR(942), CHAR(8), CHAR(4), DATE, CHAR(8), DATE, CHAR(1), char(20);

    define vcodret INTEGER;
    define vcodret2 INTEGER;
    define vcodret3 CHAR(40);
    define vexiste CHAR(1);
    define vsqlerr INTEGER;
    define visamerr INTEGER;
    define vinfoerr CHAR(40);

    define vcliente char(20);
    define vsecuencia smallint ;
    define vstatus char(1);
    define vmapad  char(942);
    define vmapai  char(942);
    define vusuario char(8);
    define vsucursal char(4);
    define vfechaalta date ;
    define vusuariocambio char(8);
    define vfechacambio date ;
    define vsexo char(1);
    define vclienteref char(20);
    define vfecha_hoy date;
    
    --- SET DEBUG FILE TO "/tmp/spregresahuellac.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr,visamerr,vinfoerr
        IF vsqlerr != 0 THEN
            --SET DEBUG FILE TO "/resplogifx/conciliachq/spregresahuellac.err";
            --TRACE ON;
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vinfoerr;
            RETURN vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref;
        END IF;
    END EXCEPTION;

    LET vcodret = 1;
    LET vcodret2 = 0;
    LET vcodret3 = '';
    LET vexiste = 0;

    LET vcliente = '';
    LET vsecuencia = 0;
    LET vstatus = '';
    LET vmapad = '';
    LET vmapai = '';
    LET vusuario = '';
    LET vsucursal = '';
    LET vfechaalta = '';
    LET vusuariocambio = '';
    LET vfechacambio = '';
    LET vsexo = '';
    LET vclienteref = '';

    set isolation to dirty read;

    /* Verifica recepcion correcta de datos */
    if ptipo is null or Trim(ptipo) = '' then
        let vcodret = 110;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    elif pfechaini is null  then
        let vcodret = 120;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    elif pfechafin is null  then
        let vcodret = 130;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    end if;
    
    create temp table tmp_huellas_ctes(
        numcte          char(20),
        secuencia       smallint,
        estado          char(1),
        dmapa           char(942),
        imapa           char(942),
        usuario         char(8),
        sucursal        char(4),
        fecha_alta      date,
        usuario_camb    char(8),
        fecha_camb      date,
        sexo            char(1),
        numcte_ref      char(20)   
    ) with no log;

--A PETICION DE BASE DE DATOS SE COMENTAN INDICES	
--begin;
    --create index idx_fecalta_tmp on tmp_huellas_ctes(fecha_alta) online;
--commit;
--begin;
    --create index idx_feccamb_tmp on tmp_huellas_ctes(fecha_camb) online;
--commit;
    --update statistics medium for table tmp_huellas_ctes(fecha_alta,fecha_camb) resolution 1.5;
    
    select fecha_hoy
      into vfecha_hoy
      from si_fechas
     where empresa = '001';
    
    -- // POR FECHA DE ALTA
    if ptipo = '1' then
        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue2)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''), 
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_alta > pfechaini
               and ch.fecha_alta <= vfecha_hoy

            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0') 
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert > pfechaini
               and sol.fecha_insert <= vfecha_hoy
            
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''), 
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);

            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0') 
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // INACTIVAS
    elif ptipo = '2' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue3)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_camb >= pfechaini 
               and ch.fecha_camb <= vfecha_hoy
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini
               and sol.fecha_insert <= vfecha_hoy
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // POR CLIENTE
    elif ptipo = '3' then

        foreach
            select nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = trim(pnumcte)
               and ch.estado = "A"
               
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
             
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // ENTRE FECHAS
    elif ptipo = '4' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue2)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_alta >= pfechaini 
               and ch.fecha_alta <= pfechafin
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini
               and sol.fecha_insert <= pfechafin
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
    -- // INACTIVAS ENTRE FECHAS
    elif ptipo = '5' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue3)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_camb >= pfechaini 
               and ch.fecha_camb <= pfechafin
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini 
               and sol.fecha_insert <= pfechafin
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    end if;
    
    --update statistics medium for table tmp_huellas_ctes;
  update statistics medium for table tmp_huellas_ctes FORCE;

    
    if ptipo in('1','3','4') then 
    
        foreach
            select numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref
              from tmp_huellas_ctes
             order by fecha_alta asc
            
            return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref with resume;
        end foreach;
        
    elif ptipo in('2','5') then 
    
        foreach
            select numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref
              from tmp_huellas_ctes
             order by fecha_camb asc
            
            return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref with resume;
        end foreach;
    
    end if;

    END;
    
END PROCEDURE

DOCUMENT
"DESCRIPCION: Consulta de huellas de cliente para replicacion ",
"AUTOR : Daniel Zambada ",
"MODIFICO : Daniel Zambada",
"FECHA : 21/01/2008",
"MODIFICO : Saul Ivanhoe",
"FECHA : 01/02/2008",
"BD    : bdinteg",
"VER   : 1.3",
"MODIFICO : JICS",
"FECHA : 14/Marzo/2011",
"BD    : bdinteg",
"VER   : 2.0";

CREATE PROCEDURE "informix".spregresahuellac_per( ptipo CHAR(1), pnumcte CHAR(20), pfechaini DATE, pfechafin DATE )
RETURNING INTEGER, char(20), SMALLINT, CHAR(1), CHAR(942), CHAR(942), CHAR(8), CHAR(4), DATE, CHAR(8), DATE, CHAR(1), char(20);

    define vcodret INTEGER;
    define vcodret2 INTEGER;
    define vcodret3 CHAR(40);
    define vexiste CHAR(1);
    define vsqlerr INTEGER;
    define visamerr INTEGER;
    define vinfoerr CHAR(40);

    define vcliente char(20);
    define vsecuencia smallint ;
    define vstatus char(1);
    define vmapad  char(942);
    define vmapai  char(942);
    define vusuario char(8);
    define vsucursal char(4);
    define vfechaalta date ;
    define vusuariocambio char(8);
    define vfechacambio date ;
    define vsexo char(1);
    define vclienteref char(20);
    define vfecha_hoy date;
    
    --- SET DEBUG FILE TO "/tmp/spregresahuellac.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr,visamerr,vinfoerr
        IF vsqlerr != 0 THEN
            --SET DEBUG FILE TO "/resplogifx/conciliachq/spregresahuellac.err";
            --TRACE ON;
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vinfoerr;
            RETURN vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref;
        END IF;
    END EXCEPTION;

    LET vcodret = 1;
    LET vcodret2 = 0;
    LET vcodret3 = '';
    LET vexiste = 0;

    LET vcliente = '';
    LET vsecuencia = 0;
    LET vstatus = '';
    LET vmapad = '';
    LET vmapai = '';
    LET vusuario = '';
    LET vsucursal = '';
    LET vfechaalta = '';
    LET vusuariocambio = '';
    LET vfechacambio = '';
    LET vsexo = '';
    LET vclienteref = '';

    set isolation to dirty read;

    /* Verifica recepcion correcta de datos */
    if ptipo is null or Trim(ptipo) = '' then
        let vcodret = 110;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    elif pfechaini is null  then
        let vcodret = 120;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    elif pfechafin is null  then
        let vcodret = 130;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    end if;
    
    create temp table tmp_huellas_ctes(
        numcte          char(20),
        secuencia       smallint,
        estado          char(1),
        dmapa           char(942),
        imapa           char(942),
        usuario         char(8),
        sucursal        char(4),
        fecha_alta      date,
        usuario_camb    char(8),
        fecha_camb      date,
        sexo            char(1),
        numcte_ref      char(20)   
    ) with no log;

--A PETICION DE BASE DE DATOS SE COMENTAN INDICES	
--begin;
    --create index idx_fecalta_tmp on tmp_huellas_ctes(fecha_alta) online;
--commit;
--begin;
    --create index idx_feccamb_tmp on tmp_huellas_ctes(fecha_camb) online;
--commit;
    --update statistics medium for table tmp_huellas_ctes(fecha_alta,fecha_camb) resolution 1.5;
    
    select fecha_hoy
      into vfecha_hoy
      from si_fechas
     where empresa = '001';
    
    -- // POR FECHA DE ALTA
    if ptipo = '1' then
        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue2)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''), 
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_alta > pfechaini
               and ch.fecha_alta <= vfecha_hoy

            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0') 
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert > pfechaini
               and sol.fecha_insert <= vfecha_hoy
            
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''), 
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);

            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0') 
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // INACTIVAS
    elif ptipo = '2' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue3)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_camb >= pfechaini 
               and ch.fecha_camb <= vfecha_hoy
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini
               and sol.fecha_insert <= vfecha_hoy
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // POR CLIENTE
    elif ptipo = '3' then

        foreach
            select nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = trim(pnumcte)
               and ch.estado = "A"
               
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
             
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // ENTRE FECHAS
    elif ptipo = '4' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue2)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_alta >= pfechaini 
               and ch.fecha_alta <= pfechafin
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini
               and sol.fecha_insert <= pfechafin
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
    -- // INACTIVAS ENTRE FECHAS
    elif ptipo = '5' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue3)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_camb >= pfechaini 
               and ch.fecha_camb <= pfechafin
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini 
               and sol.fecha_insert <= pfechafin
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    end if;
    
    --update statistics medium for table tmp_huellas_ctes;
  update statistics medium for table tmp_huellas_ctes FORCE;

    
    if ptipo in('1','3','4') then 
    
        foreach
            select numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref
              from tmp_huellas_ctes
             order by fecha_alta asc
            
            return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref with resume;
        end foreach;
        
    elif ptipo in('2','5') then 
    
        foreach
            select numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref
              from tmp_huellas_ctes
             order by fecha_camb asc
            
            return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref with resume;
        end foreach;
    
    end if;

    END;
    
END PROCEDURE

DOCUMENT
"DESCRIPCION: Consulta de huellas de cliente para replicacion ",
"AUTOR : Daniel Zambada ",
"MODIFICO : Daniel Zambada",
"FECHA : 21/01/2008",
"MODIFICO : Saul Ivanhoe",
"FECHA : 01/02/2008",
"BD    : bdinteg",
"VER   : 1.3",
"MODIFICO : JICS",
"FECHA : 14/Marzo/2011",
"BD    : bdinteg",
"VER   : 2.0";

CREATE PROCEDURE "informix".sp_consultapreasignacionhuella_web_442(cEmpresa CHAR(3), cNumCte CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR (5),  ---- Código de Retorno
	CHAR (20), ---- Número de Cliente
	SMALLINT,  ---- Secuencia
	CHAR (1),  ---- Status
	CHAR (8),  ---- User insert
	CHAR (8),  ---- Empleado
	CHAR (8),  ---- Usuario3
	CHAR (4),  ---- Sucursal
	DATE;      ---- Fecha insert

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet      CHAR (5);
	DEFINE cNumCliente  CHAR (20);
	DEFINE smSecuencia  SMALLINT;
	DEFINE cStatus      CHAR (1);
	DEFINE cUser_Insert CHAR (8);
	DEFINE cEmpleado    CHAR (8);
	DEFINE cUsuario3    CHAR (8);
	DEFINE cSucursal    CHAR (4);
	DEFINE dFecha_Insert  DATE;
	DEFINE smSecuenciaMax SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET cCodRet = "00000";
	LET cNumCliente = "";
	LET smSecuencia = 0;
	LET cStatus = "";
	LET cUser_Insert = "";
	LET cEmpleado = "";
	LET cUsuario3 = "";
	LET cSucursal = "";
	LET dFecha_Insert = "";
	LET smSecuenciaMax = 0;
	
	--SET DEBUG FILE TO "/informix/sp_consultapreasignacionhuella_web_442.out";
	--TRACE ON;
	BEGIN

		IF cNumCte IS NULL OR Trim(cNumCte) = "" THEN
			LET cCodRet = "00110";
			RETURN cCodRet, cNumCliente, smSecuencia, cStatus, cUser_Insert, cEmpleado, cUsuario3, cSucursal, dFecha_Insert;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF (SELECT count(numcte)  FROM bdinteg:si_cte_huella_dec_temp WHERE numcte = cNumCte) = 0 THEN
			LET cCodRet = "00001";
		END IF;

		SELECT MAX(secuencia)
		INTO smSecuenciaMax
		FROM bdinteg:si_cte_huella_dec_temp
		WHERE numcte = cNumCte;

		SELECT first 1 numcte, secuencia, status, user_insert, empleado, usuario3, sucursal, fecha_insert
		INTO cNumCliente, smSecuencia, cStatus, cUser_Insert, cEmpleado, cUsuario3, cSucursal, dFecha_Insert            
		FROM bdinteg:si_cte_huella_dec_temp
		WHERE numcte = cNumCte
		AND secuencia = smSecuenciaMax;

		RETURN NVL(cCodRet,"00001"), NVL(cNumCliente,""), NVL(smSecuencia,""), NVL(cStatus,""), NVL(cUser_Insert,""), NVL(cEmpleado,""), NVL(cUsuario3,""), NVL(cSucursal,""), dFecha_Insert;
	END;
END PROCEDURE;
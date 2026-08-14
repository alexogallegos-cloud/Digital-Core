CREATE PROCEDURE "informix".sp_consultaparamdigitalizacionlike(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodParamIni SMALLINT, pCodParamFin SMALLINT)
		RETURNING CHAR(5) AS codret,
				SMALLINT AS cCodParam,
				CHAR(100) AS cValor,
				CHAR(50) AS cDescripcion;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCodParam SMALLINT;
	DEFINE cValor    CHAR(100);
	DEFINE cDescripcion CHAR(50);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCodParam = '';
	LET cValor    	 = '';
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodParam, cValor, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparamdigitalizacionlike.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodParamIni = '' OR pCodParamFin = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodParam, cValor, cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,  cCodParam, cValor, cDescripcion;
		END IF;

		FOREACH EXECUTE PROCEDURE bdidigital:"informix".sp_dgconsultaparametrosdigitalizacionlike(cEmpresa, pCodParamIni, pCodParamFin)
		INTO cCodRetSp, cCodParam, cValor, cDescripcion
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
			ELIF iCodRetSp = 000002 THEN
				LET cCodRet = '00367';				RETURN cCodRet, cCodParam, cValor, cDescripcion;
			ELIF iCodRetSp = 000003 THEN
				LET cCodRet = '00368'; --LA CLAVE DE PARAMETRO FINAL NO ES POSITIVA
				RETURN cCodRet, cCodParam, cValor, cDescripcion;
			ELIF iCodRetSp = 000004 THEN
				LET cCodRet = '00369'; --LA CLAVE DE PARAMETRO INICIAL ES MAYOR QUE LA FINAL
				RETURN cCodRet, cCodParam, cValor, cDescripcion;
			END IF;
			
			RETURN cCodRet, cCodParam, cValor, cDescripcion WITH RESUME;
		END FOREACH
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodParam, cValor, cDescripcion WITH RESUME;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'Esparza Brenis Fernando Martin',
'FECHA: 25/07/2014',
'DESCRIPCION: Consulta parametros',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_eliminaimgpendenviardigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pMacAddress CHAR(15), pCtlprocesado CHAR(1))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_eliminaimgpendenviardigitalizacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMacAddress = '' OR pCtlprocesado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		DELETE bdidigital:dg_expediente_envio WHERE macaddress_local = pMacAddress	AND ctl_procesado = pCtlprocesado;

		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 21/08/2014',
'DESCRIPCION: elimina registros pendientes para poder hacer un reintento',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardacuentactemoral(pUsuario CHAR(8), pIdfuncion CHAR(10), pSucursal CHAR(4), pProducto CHAR(4), pNumCte CHAR(20), 	pNumCot CHAR(2), pClaseCta CHAR(1), pRegFirmas CHAR(1), 
				pTipoBca CHAR(3), pEjecutivo CHAR(8), pEnvioDirecc CHAR(1), pCuenta CHAR(20), pDireccEnvio SMALLINT, pCliente2 CHAR(20), pNombre CHAR(50), pInstcap CHAR(2), pCuentaCap CHAR(20), pInstInt CHAR(2), 
				pCuentaInt CHAR(20), pPlazo SMALLINT, pCobraISr CHAR(1), pProcedAperturaCta CHAR(2), pProcedMantenerCta CHAR(2), pMontoMensual CHAR(2), pDepositosCantidad CHAR(2), pDepositoMonto CHAR(2), 
				pRetirosCantidad CHAR(2), pRetirosMonto CHAR(2), pFormaApert CHAR(2), pMtoApertura MONEY(14,2))
				RETURNING CHAR(5) AS cCodigoRetorno,
								CHAR(20) AS cCuenta,
								CHAR(18) AS cCuentaClabe;
	
	-- VARIABLES --
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCtaClabe CHAR(18);
	DEFINE cCuenta CHAR(20);
	
	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = "";
	LET cCtaClabe = "";
	LET cCuenta = "";

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCuenta,cCtaClabe;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/prospescto/cuenta.out';
		--TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = '' OR
		   NVL(pSucursal, '') = '' OR
		   NVL(pProducto, '') = '' OR
		   NVL(pNumCte, '') = '' OR
		   NVL(pNumCot, '') = '' OR
		   NVL(pClaseCta, '') = '' OR
		   NVL(pTipoBca, '') = '' OR
		   NVL(pEjecutivo, '') = '' OR
		   NVL(pEnvioDirecc, '') = '' OR
		   NVL(pDireccEnvio, '') = '' OR
		   NVL(pProcedAperturaCta, '') = '' OR
		   NVL(pProcedMantenerCta, '') = '' OR
		   NVL(pMontoMensual, '') = '' OR
		   NVL(pDepositosCantidad, '') = '' OR
		   NVL(pDepositoMonto, '') = '' OR
		   NVL(pRetirosCantidad, '') = '' OR
		   NVL(pRetirosMonto, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta, cCtaClabe;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta, cCtaClabe;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".cuenta1('001', pUsuario, pSucursal, pProducto, pNumCte, pNumCot, pClaseCta, pRegFirmas, 
					pTipoBca, pEjecutivo, pEnvioDirecc, pCuenta, pDireccEnvio, pCliente2, pNombre, pInstcap, pCuentaCap, pInstInt, pCuentaInt, pPlazo,
					pCobraISr, pProcedAperturaCta, pProcedMantenerCta, pMontoMensual, pDepositosCantidad, pDepositoMonto, pRetirosCantidad, pRetirosMonto,
					pFormaApert, pMtoApertura)
		INTO cCodRetSp, cCuenta, cCtaClabe;
		
		IF cCodRetSp = '90001' THEN 
			LET cCodRet = '00016';	--EL PRODUCTO NO EXISTE FAVOR DE CONFIRMAR
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '90007' THEN
			LET cCodRet = '00336';	--ES NECESARIO CUENTA EJE
			RETURN cCodRet, cCuenta,cCtaClabe;
		ELIF cCodRetSp = '90002' THEN
			LET cCodRet = '00337';	--CLIENTE CON EL MAXIMO DE CUENTAS PERMITIDAS
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '90003' THEN
			LET cCodRet = '00338';	--CUENTA EJE YA TIENE CUENTA PROAC
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '90004' THEN
			LET cCodRet = '00339';	--CUENTA PROAC BLOQUEADA
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '90005' THEN
			LET cCodRet = '00340';	--LA CUENTA EJE YA TIENE REINSCRITA LA CUENTA PROAC
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '90006' THEN
			LET cCodRet = '00341';	--EL PRODUCTO NO ES PARTICIPANTE
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '310' THEN
			LET cCodRet = '00342';	--EL MONTO DE APERTURA ES MENOR AL MONTO MINIMO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '106' THEN
			LET cCodRet = '00006';	--DATOS DEL EJECUTIVO NO VALIDOS
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '011' THEN
			LET cCodRet = '00343';	--EL TIPO DE CUENTA NO ES VALIDO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '112' THEN
			LET cCodRet = '00299';	--NO EXISTE EL TIPO DE FIRMA
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '113' THEN
			LET cCodRet = '00344';	--EL TIPO DE DIRECCION NO ES VALIDO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '104' THEN
			LET cCodRet = '00320';	--EL CLIENTE NO ES UNA PERSONA FISICA
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '130' THEN
			LET cCodRet = '00319';	--NO HAY SECUENCIA CON EL NUMERO DE CLIENTE SELECCIONADO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '102' THEN
			LET cCodRet = '00345';	--EL REGIMEN DE FIRMA ES INCORRECTO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '105' THEN
			LET cCodRet = '00161';	--EL NÃMERO DE SUCURSAL ES INCORRECTO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '107' THEN
			LET cCodRet = '00112';	--ERROR EN CUENTA CLABE
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '103' THEN
			LET cCodRet = '00346';	--EL PRODUCTO NO TIENE UN INTERES
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '021' THEN
			LET cCodRet = '00313';	--TIPO DE CLIENTE NO PERMITIDO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '402' THEN 
			LET cCodRet = '00347';	--EL PERIODO DE APERTURA DE LA CUENTA ES INCORRECTO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '100' THEN 
			LET cCodRet = '00348';	--EL CAMPO DIVISA ES INCORRECTO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '905' THEN 
			LET cCodRet = '00349';	--EL DATO DE LA DIVISA ES INCORRECTO
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '405' THEN 
			LET cCodRet = '00350';	--EL NUMERO DE CUENTA YA EXISTE
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '170' THEN
			LET cCodRet = '00351'; --ERROR AL GENERAR EL NUMERO DE CUENTA
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '131' THEN
			LET cCodRet = '00352'; --LA CUENTA NO CONTIENE LA LONGITUD CORRECTA
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELIF cCodRetSp = '933' THEN
			LET cCodRet = '00353'; --PARÃMETRO DE SIGUIENTE NUMERO DE CUENTA INCORRECTO
			RETURN cCodRet, cCuenta, cCtaClabe;
		
		ELIF cCodRetSp <> '000' THEN 
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cCuenta, cCtaClabe;
		ELSE
			RETURN cCodRet, cCuenta, cCtaClabe;
		END IF;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Da de Alta una Cuenta',
'Fecha: 25/06/2014';

CREATE PROCEDURE "informix".sp_guardafirmantessif(pUsuario CHAR(8), pIdfuncion CHAR(10), pCuenta CHAR(20), pSecuencia SMALLINT, pNumcte CHAR(20), 
		pApellidos CHAR(30), pNombre CHAR(30), pRegFirma CHAR(1), pTipoFirma CHAR(1),pCombinacion CHAR(120), pParentesco CHAR(2))

    RETURNING CHAR(5) AS cCodigoRetorno;
	
	-- VARIABLES --
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(3);
	
	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = "";

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/prospescto/firmantes.out';
		--TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = '' OR NVL(pCuenta, '') = '' OR NVL(pSecuencia, '') = '' OR NVL(pNumcte, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".sp_firmantessif('001', pCuenta, pSecuencia, pNumcte, pApellidos, pNombre, pRegFirma, pTipoFirma,
		pCombinacion, pParentesco) INTO cCodRetSp;

		IF cCodRetSp <> '000' THEN 
			LET cCodRet = cCodRetSp;	
			RETURN cCodRet;
		ELSE
			RETURN cCodRet;
		END IF;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Registra los firmantes',
'Fecha: 24/06/2014';

CREATE PROCEDURE "informix".sp_guardainfocteprospecto(
										pUsuario CHAR(8), 
										pIdfuncion CHAR(10),
										pFuncion CHAR(1),
										pNumcte CHAR(20),
										pSucursal CHAR(4),
										pEjecutivo CHAR(8),
										pTp_persona CHAR (2),
										pTp_cliente CHAR(1),
										pPaterno CHAR (26),
										pMaterno CHAR (26),
										pNombre1 CHAR (26),
										pNombre2 CHAR (26),
										pRfc CHAR (13),
										pSector CHAR (2),
										pSegmento CHAR (3),
										pActividad_princ CHAR (3),
										pGrupo CHAR(3),
										pSubgrupo CHAR(3),
										pResidencia CHAR(1),
										pApell_casada CHAR(20),
										pNumcte_ref CHAR(20),
										pDistrito CHAR(2),
										pPuesto_ppes CHAR(1),
										pFamiliar_ppes CHAR(1),
										pActividad_esp CHAR(11),
										pFecha_nac DATE, -- Inician columnas de Ctepf
										pLugar_nac CHAR (2),
										pNacionalidad CHAR(3),
										pFm3 CHAR(18),
										pEstado_civil CHAR(1),
										pRegimen_mat CHAR(1),
										pProfesion CHAR (3),
										pSexo CHAR(1),
										pCurp CHAR(20),
										pCodidentif CHAR(2),
										pNumidentif CHAR(30),
										pNo_imss CHAR(12),
										pDependientes SMALLINT,
										pTutor CHAR(60),
										pEmail CHAR(60),
										pNom_conyuge CHAR(60),
										pSeguro_defunc CHAR(1),
										pEscolaridad CHAR(2),
										pHabita_en CHAR(20),
										pAnios_habita SMALLINT,
										pNombre_prop CHAR(60),
										pImphiporenta MONEY(14,2),
										pNumeroife CHAR(20),
										pNumerotutor CHAR(20),
										pNumeroconyuge CHAR(20),
										pEjecut_autoriza CHAR(8),
										pPromocion CHAR(2),
										pNumhabitantes CHAR (60) )
										RETURNING 
											CHAR(5) AS cCodigoRetorno, 
											CHAR(20) AS cNoCte;

	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(3);
	DEFINE	cFuncion 	CHAR(1);
	DEFINE	cNumcte 	CHAR(20);

	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cNumCte = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumCte;
			END IF;
		END EXCEPTION;
	
		-- SET DEBUG FILE TO '/tmp/mfinis/prospescto/sp_guardar.out';
		-- TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = ''  THEN -- OR NVL(pNumcte, '') = ''
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCte;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCte;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".ctefisico('001',pFuncion, pNumcte, pSucursal, pEjecutivo, pTp_persona, pTp_cliente, pPaterno, pMaterno, pNombre1, 
		pNombre2, pRfc, pSector, pSegmento, pActividad_princ,
		pGrupo, pSubgrupo, pResidencia, pApell_casada, pNumcte_ref, pDistrito, pPuesto_ppes, pFamiliar_ppes, pActividad_esp, pFecha_nac, pLugar_nac,
		pNacionalidad, pFm3, pEstado_civil, pRegimen_mat, pProfesion, pSexo, pCurp, pCodidentif, pNumidentif, pNo_imss, pDependientes, pTutor, pEmail,
		pNom_conyuge, pSeguro_defunc, pEscolaridad, pHabita_en, pAnios_habita, pNombre_prop, pImphiporenta, pNumeroife, pNumerotutor, pNumeroconyuge,
		pEjecut_autoriza, pPromocion, pNumhabitantes)
		INTO cCodRetSp, cNumCte;
		
		IF cCodRetSp = '118' THEN
			LET cCodRet = '00022'; -- 00022 El NUMERO DE CLIENTE NO EXISTE. 
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '104' THEN
			LET cCodRet = '00020'; -- 00020 EL TIPO DE PERSONA NO ES VALIDO.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '110' THEN
			LET cCodRet = '00003'; -- FALTAN PARAMETROS DE ENTRADA.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '120' THEN
			LET cCodRet = '00320'; -- EL CLIENTE NO ES UNA PERSONA FISICA.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '121' THEN
			LET cCodRet = '00293'; -- EL NÃMERO DE CLIENTE YA EXISTE.
			RETURN cCodRet, cNumCte;	
		ELIF cCodRetSp = '111' THEN
			LET cCodRet = '00161'; -- EL NÃMERO DE SUCURSAL ES INCORRECTO.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '112' THEN
			LET cCodRet = '00006'; -- DATOS DEL EJECUTIVO NO VALIDOS.
			RETURN cCodRet, cNumCte;	
		ELIF cCodRetSp = '106' THEN
			LET cCodRet = '00291'; --00291 EL RFC CAPTURADO YA ESTÃ ASIGNADO A OTRO CLIENTE
			RETURN cCodRet, cNumCte;	
		ELIF cCodRetSp = '113' THEN--*************************** 113 sector
			LET cCodRet = '00321'; -- EL SECTOR ES INCORRECTO.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '114' THEN--*************************** 114 segmento
			LET cCodRet = '00322'; -- EL SEGMENTO NO EXISTE.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '115' THEN--*************************** 115 grupo
			LET cCodRet = '00323'; -- EL GRUPO NO EXISTE.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '116' THEN--*************************** 116 subgrupo
			LET cCodRet = '00324'; -- EL SUBGRUPO NO EXISTE.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '125' THEN--*************************** 125  pActividad_esp
			LET cCodRet = '00325'; -- EL ACTIVIDAD ESPECIAL NO EXISTE.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '126' THEN--***************************  126	profesion
			LET cCodRet = '00326'; -- LA PROFESION SELECCIONADA NO EXISTE.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '135' THEN --***************************  escolaridad 1(primaria)
			LET cCodRet = '00327'; -- LA ESCOLARIDAD SELECCIONADA NO EXISTE. 
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '133' THEN--*************************** 133 codidentif (A B C D E F G H I J K O L M N)
			LET cCodRet = '00328'; -- EL CODIGO DE IDENTIFICACIÃN ES INCORRECTO
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '117' THEN--*************************** 117 habita_en
			LET cCodRet = '00329'; -- EL TIPO DE VIVIENDA ES INCORRECTO
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '144' THEN--*************************** 144 pTutor 
			LET cCodRet = '00330'; -- INGRESE A UN TUTOR.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp = '145' THEN--*************************** 145 pTutor
			LET cCodRet = '00331'; -- EL TUTOR NO EXISTE.
			RETURN cCodRet, cNumCte;
		ELIF cCodRetSp <> '000' THEN
			LET cCodRet = cCodRetSp; -- ERROR GENERICO.
			RETURN cCodRet, cNumCte;
		ELSE
			RETURN cCodRet, cNumCte;
		END IF;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Guarda Datos del cliente',
'Fecha: 11/06/2014';

CREATE PROCEDURE "informix".sp_guardainfotercerosctamec(pUsuario CHAR(8), pIdfuncion CHAR(10), pNumCte CHAR(20), pCuenta CHAR(20), pTipoRec CHAR(1), 
		pSecuencia SMALLINT, pTipoPer CHAR(2), pNumPer CHAR(2), pNombre CHAR(40), pNacion CHAR(40), pRfc CHAR(13), pFirma CHAR(25), pDomicilio CHAR(200))
    RETURNING CHAR(5) AS cCodigoRetorno;
	
	-- VARIABLES --
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(3);
	
	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = "";

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/prospescto/sp_ctamec_regisrecterc_CUENTA.out';
		--TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = '' OR NVL(pNumCte, '') = '' OR NVL(pCuenta, '') = '' OR NVL(pTipoRec, '') = ''
		OR NVL(pSecuencia, '') = '' OR NVL(pNombre, '') = '' OR NVL(pNacion, '') = '' OR NVL(pRfc, '') = '' OR NVL(pFirma, '') = ''
		OR NVL(pDomicilio, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".sp_ctamec_regisrecterc(pUsuario, pNumCte, pCuenta, pTipoRec, pSecuencia, pTipoPer, pNumPer, pNombre, 
			pNacion, pRfc, pFirma, pDomicilio)
		INTO cCodRetSp;

		IF cCodRetSp = '200' THEN 
			LET cCodRet = '00009';	--EL NUMERO DE CUENTA NO EXISTE 
			RETURN cCodRet;
		ELIF cCodRetSp = '260' THEN
			LET cCodRet = '00022';	--EL NUMERO DE CLIENTE NO EXISTE
			RETURN cCodRet;
		ELIF cCodRetSp <> '000' THEN 
			LET cCodRet = cCodRetSp;	
			RETURN cCodRet;
		ELSE
			RETURN cCodRet;
		END IF;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Registra los Terceros',
'Fecha: 24/06/2014';

CREATE PROCEDURE "informix".sp_guardasaldosbitacoracre(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCredito CHAR(20), pTipoOperacion SMALLINT)
		RETURNING CHAR(5) AS codret,
				INTEGER AS no_registros;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cTipoMovimiento CHAR(1);
	
	DEFINE cNumCliente CHAR(20);
	DEFINE cSucursal CHAR(4);
	DEFINE cStatusCred CHAR(2);
	DEFINE iPlazo INTEGER;
	DEFINE dFechaApertura DATE;
	DEFINE dFechaVencimiento DATE;
	DEFINE dTasaInteres DECIMAL(9,6);
	DEFINE dTasaMoratorios DECIMAL(9,6);
	DEFINE dSdoRetenido DECIMAL(18,2);
	DEFINE dSdoNoExig DECIMAL(18,2);
	DEFINE dSdoContabMora DECIMAL(18,2);
	DEFINE dSdoCapital DECIMAL(18,2);
	DEFINE dSdoCapInsoluto DECIMAL(18,2);
	DEFINE dSdoMtoVdo DECIMAL(18,2);
	DEFINE dMtoVdoTrasp DECIMAL(18,2);
	DEFINE dMtoFinanciado DECIMAL(18,2);
	DEFINE dMtoOtorgado DECIMAL(18,2);
	DEFINE dCapTrasnoVdo DECIMAL(18,2);
	DEFINE dMtoVdoInt DECIMAL(18,2);
	DEFINE dMtoVdoTrasInt DECIMAL(18,2);
	DEFINE dIntTraNoExig DECIMAL(18,2);
	DEFINE cDescTpoCart CHAR(60);
	DEFINE cCodTpoCred CHAR(2);
	DEFINE dPorcIva DECIMAL(5,3);
	DEFINE dMoratorio DECIMAL(18,2);
	DEFINE dIvaMoratorio DECIMAL(18,2);
	DEFINE dIvaIntVenc DECIMAL(18,2);
	DEFINE dInteresMes DECIMAL(18,2);
	DEFINE dIvaMes DECIMAL(18,2);
	DEFINE dTotalLiquidacion DECIMAL(18,2);
	DEFINE dIntMoraCope DECIMAL(18,2);
	DEFINE dIvaIntMoraCope DECIMAL(18,2);
	DEFINE dIntMoraBase DECIMAL(18,2);
	DEFINE dIvaIntMoraBase DECIMAL(18,2);
	DEFINE dIvaIntMoraCopeBase DECIMAL(18,2);
	DEFINE dCapitalTotal DECIMAL(18,2);
	DEFINE dInteresVigente DECIMAL(18,2);
	DEFINE dIvaInteresVigente DECIMAL(18,2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cTipoMovimiento = '';
	
	LET cNumCliente = '';
	LET cSucursal = '';
	LET cStatusCred = '';
	LET iPlazo = 0;
	LET dFechaApertura = NULL;
	LET dFechaVencimiento = NULL;
	LET dTasaInteres = NULL;
	LET dTasaMoratorios = NULL;
	LET dSdoRetenido = NULL;
	LET dSdoNoExig = NULL;
	LET dSdoContabMora = NULL;
	LET dSdoCapital = NULL;
	LET dSdoCapInsoluto = NULL;
	LET dSdoMtoVdo = NULL;
	LET dMtoVdoTrasp = NULL;
	LET dMtoFinanciado = NULL;
	LET dMtoOtorgado = NULL;
	LET dCapTrasnoVdo = NULL;
	LET dMtoVdoInt = NULL;
	LET dMtoVdoTrasInt = NULL;
	LET dIntTraNoExig = NULL;
	LET cDescTpoCart = '';
	LET cCodTpoCred = '';
	LET dPorcIva = NULL;
	LET dMoratorio = NULL;
	LET dIvaMoratorio = NULL;
	LET dIvaIntVenc = NULL;
	LET dInteresMes = NULL;
	LET dIvaMes = NULL;
	LET dTotalLiquidacion = NULL;
	LET dIntMoraCope = NULL;
	LET dIvaIntMoraCope = NULL;
	LET dIntMoraBase = NULL;
	LET dIvaIntMoraBase = NULL;
	LET dIvaIntMoraCopeBase = NULL;
	LET dCapitalTotal = NULL;
	LET dInteresVigente = NULL;
	LET dIvaInteresVigente = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_guardasaldosbitacoracre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCredito = '' OR pTipoOperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumCredito, '06', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		EXECUTE PROCEDURE bdicnweb:"informix".sp_consultamovtosnvasfuncre(pUsuario, pIdFuncion, pNumCredito)
		INTO cCodRet, cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, 
				dSdoNoExig, dSdoContabMora, dSdoCapital, dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, 
				dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, 
				dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, dCapitalTotal, dInteresVigente, dIvaInteresVigente;
				
		IF cCodRet::INTEGER <> 0 THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		
		-- Consulta de salos antes de la afectaciÃ³n
		IF pTipoOperacion = 1 THEN  -- Consulta de saldos antes de la aplicaciÃ³n
			LET cTipoMovimiento = 'A';
		ELIF pTipoOperacion = 2 THEN  -- Consulta de saldos antes de la aplicaciÃ³n
			LET cTipoMovimiento = 'D';
		END IF;
			
		-- InserciÃ³n en bitacora
		INSERT INTO "informix".sw_tr_bitacorasaldoscre(numcte, sucursal, statuscred, plazo, fechaapertura, fechavencimiento, tasainteres, tasamoratorios, sdoretenido, sdonoexig, sdocontabmora, sdocapital, 
								sdocapinsoluto, sdomtovdo, mtovdotrasp, mtofinanciado, mtootorgado, captrasnovdo, mtovdoint, mtovdotrasint, inttranoexig, desctpocart, codtpocred, 
								porciva, moratorio, ivamoratorio, ivaintvenc, interesmes, ivames, totalliquidacion, intmoracope, ivaintmoracope, intmorabase, ivaintmorabase, ivaintmoracopebase, 
								capitaltotal, interesvigente, ivainteresvigente, movimiento, usuario, cuenta)
		VALUES(cNumCliente, cSucursal, cStatusCred, iPlazo, dFechaApertura, dFechaVencimiento, dTasaInteres, dTasaMoratorios, dSdoRetenido, dSdoNoExig, dSdoContabMora, dSdoCapital, 
				dSdoCapInsoluto, dSdoMtoVdo, dMtoVdoTrasp, dMtoFinanciado, dMtoOtorgado, dCapTrasnoVdo, dMtoVdoInt, dMtoVdoTrasInt, dIntTraNoExig, cDescTpoCart, cCodTpoCred, 
				dPorcIva, dMoratorio, dIvaMoratorio, dIvaIntVenc, dInteresMes, dIvaMes, dTotalLiquidacion, dIntMoraCope, dIvaIntMoraCope, dIntMoraBase, dIvaIntMoraBase, dIvaIntMoraCopeBase, 
				dCapitalTotal, dInteresVigente, dIvaInteresVigente, cTipoMovimiento, pUsuario, pNumCredito);
				
		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		RETURN cCodRet, iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/09/2014',
'DESCRIPCION: Registra en bitacora los saldos de un credito antes/despues de que fueron afectados durante un ajuste de Ã©stos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insertadoctopendienteimgdigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pCliente CHAR(20), pCuenta CHAR(20),  pProducto CHAR(4), pCodDocto CHAR(4), pProdNombre CHAR(40),
			pSecuencia INTEGER, pCtlArchivoLocal CHAR(25), pCtlArchivoLocalRuta CHAR(150), pCtlImgEnviada CHAR(1), pCtlProcesado CHAR(1), pCtlLigado CHAR(1), 
			pMacaddressLocal CHAR(17), pDescrip2 CHAR(30), pFechaAlta DATE)
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_diginsertadoctopendienteimagen_INTER.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCliente = '' OR pCuenta = '' OR pProducto = '' OR pCodDocto = '' OR  pProdNombre = '' OR pCtlImgEnviada = '' 
			OR pCtlProcesado = '' OR pCtlLigado = '' OR pMacaddressLocal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".sp_diginsertadoctopendienteimagen(cEmpresa, pCliente, pCuenta , pProducto, pCodDocto, pProdNombre, pSecuencia, pCtlArchivoLocal,
			pCtlArchivoLocalRuta, pCtlImgEnviada, pCtlProcesado, pCtlLigado, pMacaddressLocal, pDescrip2, pUsuario, pFechaAlta)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 000006 THEN
			LET cCodRet = '00386';	--PARAMETRO COD_DOCTO NO VALIDO
		ELIF iCodRetSp = 000011 THEN
			LET cCodRet = '00387';	--PARAMETRO CTL_IMG_ENVIADA NO VALIDO
		ELIF iCodRetSp = 000013 THEN
			LET cCodRet = '00384';	--PARAMETRO CTL_PROCESADO NO VALIDO
		ELIF iCodRetSp = 000015 THEN
			LET cCodRet = '00385';	--PARAMETRO CTL_LIGADO NO VALIDO
		END IF;
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 08/08/2014',
'DESCRIPCION: Inserta en la tabla dg_expediente_envio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insertaregexpedientedigitalizacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pCliente CHAR(20), pCuenta CHAR(20), pProducto CHAR(4), pCodigoDocumento CHAR(4), pSecuencia SMALLINT, 
		pProductonombre CHAR(40), pDescrip2 CHAR(30))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_insertaregexpedientedigitalizacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCliente = '' OR pCuenta = '' OR pProducto = '' OR pCodigoDocumento = '' OR pSecuencia = '' OR pProductonombre  = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdidigital:"informix".inserta_reg_expediente(cEmpresa, pCliente, pCuenta, pProducto, pCodigoDocumento, pSecuencia, pProductonombre, pDescrip2, pUsuario)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ';
		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003';
		END IF;
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 11/08/2014',
'DESCRIPCION:   inserta registro en dg_expediente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtieneparametrochequeractamoral(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodParam SMALLINT)
                RETURNING CHAR(5) AS codret,
                                CHAR(60) AS valor;
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cMensaje CHAR(80);
        DEFINE cValor CHAR(60);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cMensaje = '';
        LET cValor = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cValor;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_obtieneparametrochequeractamoral.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCodParam IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cValor;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cValor;
                END IF;
                
                EXECUTE PROCEDURE bdicntchq:"informix".sp_obtieneparametrochequera(pCodParam)
                INTO cCodRetSp, cMensaje, cValor;
                
                LET iCodRetSp = cCodRetSp::INTEGER;
                IF iCodRetSp < 0 THEN
                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_obtieneparametrochequera';
                ELIF iCodRetSp = 1 THEN
                        LET cCodRet = '00003';
                ELIF iCodRetSp = 2 THEN
                        LET cCodRet = '00002';
                END IF;
                
                RETURN cCodRet, cValor;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 17/06/2014',
'DESCRIPCION: Obtiene parametros basicos para el sistema de chequeras',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validanumtelefono(pUsuario CHAR(8), pIdfuncion CHAR(10), pTelefonoCasa CHAR(10), pTelefonoCelular CHAR(10), 
pTelefonoOficina CHAR(10))
		RETURNING CHAR(5) AS cCodRet,
		CHAR(1) AS cValCasa, 
		CHAR(1) AS cValCelular, 
		CHAR(1) AS cValOficina;

	
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(3);
	DEFINE cTelCasa CHAR(1);
	DEFINE cTelCelular CHAR(1);
	DEFINE cTelOficina CHAR(1);
	
	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = "";
	LET cTelCasa = "";
	LET cTelCelular = "";
	LET cTelOficina = "";
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;
			END IF;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/prospescto/sp_validatelefono_prospecto.out';
		-- TRACE ON;
		
		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;
		ELIF NVL(pTelefonoCasa, '') = '' AND NVL(pTelefonoCelular, '') = '' AND NVL(pTelefonoOficina, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;	
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;
		END IF;

		EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono('001', pTelefonoCasa, pTelefonoCelular, pTelefonoOficina)
		INTO cCodRetSp, cTelCasa, cTelCelular, cTelOficina;
		IF cCodRetSp = '001' THEN
			LET cCodRet = '00318'; --NUMERO DE TELEFONO NO VALIDO
			RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;
		ELIF cCodRetSp <> '000' THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;
		ELSE
			RETURN cCodRet, cTelCasa, cTelCelular, cTelOficina;
		END IF;
	END;

END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Valida Telefonos Funcionalidad Prospecto',
'Fecha: 2014/06/09';

CREATE PROCEDURE "informix".sp_conspagomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
	RETURNING CHAR(5) AS codret,
			  INT AS id,
			  CHAR(1) AS status,
			  CHAR(20) AS cuenta,
			  CHAR(20) AS num_cte,
			  CHAR(15) AS resultado,
			  CHAR(6) AS codRetSp,
			  CHAR(100) AS motivo_rechazo,
			  CHAR(20) AS folio, 
			  MONEY(14,2) AS saldo,
			  MONEY(14,2) AS importe_pago,
			  CHAR(4) AS codigo_pago,
			  CHAR(50) AS concepto_pago,
			  CHAR(255) AS comentario;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE iExiste INT;
	DEFINE iIdRegistro INT;
	DEFINE cCuenta CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMotivoRechazo CHAR(100);
	DEFINE cFolio CHAR(20);
	DEFINE mSaldo money(14,2);
	DEFINE cTransacc CHAR(4);
	DEFINE cDescTransaccion CHAR(50);
	DEFINE mImportePago money(14,2);
	DEFINE cComentario CHAR(255);
	DEFINE cStatus CHAR(1);
	DEFINE iRegistros int;
	DEFINE cNumCliente char(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iIdRegistro = 0;
	LET cCuenta = '';
	LET cResultado = '';
	LET cCodRetSp = '';
	LET cMotivoRechazo = '';
	LET cFolio = '';
	LET mSaldo = null;
	LET cTransacc = '';
	LET cDescTransaccion = '';
	LET mImportePago = 0;
	LET cComentario = '';
	LET cStatus = '';
	LET iRegistros = 0;
	LET cNumCliente = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario;
		END EXCEPTION
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_conspagomasivocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario;
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*) 
		INTO iExiste
		FROM
			(SELECT lote
				FROM bdicnweb:"informix".sw_tr_cargamasiva_pago
				WHERE lote = pLote AND usuario = pUsuario
			UNION
				SELECT lote
				FROM bdicnweb:"informix".sw_tr_cargamasiva_pago_hist
			WHERE lote = pLote AND usuario = pUsuario);

		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario;
		END IF;
		
		UPDATE bdicnweb:sw_tr_cargamasiva_pago
		SET resultado = 'NO APLICADO',
			motivo_rechazo = 'ERROR POR VALIDACION'
		WHERE lote = pLote AND status = 'E' AND usuario = pUsuario;
		
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion id_registro, status, cuenta, numcte,        resultado,  codret_proceso, motivo_rechazo, folio, monto1, monto_importe, transaccion, descripcion1, descripcion2
			INTO iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario
			FROM
				(SELECT id_registro, status, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, folio, monto1, monto_importe, transaccion, descripcion1, descripcion2
				FROM bdicnweb:"informix".sw_tr_cargamasiva_pago
				WHERE lote = pLote AND usuario = pUsuario
				UNION
				SELECT id_registro, status, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, folio, monto1, monto_importe, transaccion, descripcion1, descripcion2
				FROM bdicnweb:"informix".sw_tr_cargamasiva_pago_hist
				WHERE lote = pLote AND usuario = pUsuario)
			ORDER BY id_registro
			
			-- Agregamos el numero de cliente
			IF cNumCliente IS NULL OR TRIM(cNumCliente) = '' THEN
				FOREACH
				SELECT numcte
				INTO cNumCliente
				FROM bdicred:"informix".sd_maecred
				WHERE num_credito = TRIM(cCuenta)
				UNION
				SELECT numcte
				FROM bdicred:"informix".sd_maecredcrd
				WHERE num_credito = TRIM(cCuenta)
				END FOREACH;
				
				UPDATE bdicnweb:"informix".sw_tr_cargamasiva_pago
				SET numcte = cNumCliente
				WHERE id_registro = iIdRegistro;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					UPDATE bdicnweb:"informix".sw_tr_cargamasiva_pago_hist
					SET numcte = cNumCliente
					WHERE id_registro = iIdRegistro;
				END IF;
					
			END IF;
			
			---Se actualiza monto si la transaccion es 27 o 28 (pago por condonacion)
			IF cTransacc IN ('27','28') AND mImportePago > 0  THEN
				UPDATE bdicnweb:sw_tr_cargamasiva_pago
				SET monto_importe = 0
				WHERE id_registro = iIdRegistro;
				LET mImportePago = 0;
			END IF;
			
			LET iRegistros =  iRegistros + 1;
			
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario with resume;
		END FOREACH;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdRegistro, cStatus, cCuenta, cNumCliente, cResultado, cCodRetSp, cMotivoRechazo, cFolio, mSaldo, mImportePago, cTransacc, cDescTransaccion, cComentario;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 06/11/2013",
"Descripcion: Consulta los registros cargados en la tabla masiva para PAGO masivo de crÃ©dito",
"Fecha de creaciÃ³n: 10/09/2014",
"Descripcion: Se agrega una actualizacion al importe a cero cuando el pago es por condonacion";

CREATE PROCEDURE "informix".sp_consulta_saldos_generalcre(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), pNumCredito CHAR(20))
			RETURNING CHAR(5)       AS codigo_retorno,
					  CHAR(20)      AS numero_credito,
					  CHAR(2)       AS codigo_tipcred,
					  DATE          AS fecha_origen,
					  DATE          AS fecha_prox_pago,
					  DECIMAL(18,2) AS pago_minimo,
					  DATE          AS fecha_ult_pago,
					  INTEGER       AS plazo,
					  INTEGER       AS pagos_realizados,
					  DECIMAL(18,2) AS linea_otorgada,
					  DECIMAL(9,6)  AS tasa_interes,
					  DECIMAL(9,6)  AS tasa_moratorios,
					  DECIMAL(14,2) AS monto_sbc,
					  DECIMAL(18,2) AS cap_vig,
					  DECIMAL(18,2) AS cap_trans,
					  DECIMAL(18,2) AS cap_vdo_exig,
					  DECIMAL(18,2) AS cap_vdo_no_exig,
					  DECIMAL(18,2) AS sdo_act_total_cap,
					  DECIMAL(18,2) AS int_vig,
					  DECIMAL(18,2) AS int_vdo,
					  DECIMAL(18,2) AS int_moratorios,
					  DECIMAL(18,2) AS int_mes,
					  DECIMAL(18,2) AS sdo_act_total_int,
					  DECIMAL(18,2) AS iva_int_vig,
					  DECIMAL(18,2) AS iva_int_vdo,
					  DECIMAL(18,2) AS iva_int_moratorios,
					  DECIMAL(18,2) AS iva_int_mes,
					  DECIMAL(18,2) AS sdo_act_total_iva,
					  DECIMAL(18,2) AS com_pend,
					  DECIMAL(18,2) AS iva_com,
					  DECIMAL(18,2) AS sdo_retenido,
					  DECIMAL(18,2) AS total_liquidacion,
					  DECIMAL(18,2) AS int_devengado,
					  DECIMAL(18,2) AS iva_int_devengado,
					  DECIMAL(18,2) AS linea_disponible,
					  DECIMAL(18,2) AS pagos_vdos,
					  CHAR(60)      AS desc_status_cred,
					  INTEGER       AS id_bloqueo_cred,
					  CHAR(60)      AS bloqueo_cta,
					  CHAR(3)       AS id_causa_bloqueo_cred,
					  CHAR(50)      AS causa_bloqueo_cta,
					  CHAR(1)       AS id_sit_esp_cte,
					  INTEGER       AS id_causa_esp_cte,
					  CHAR(75)      AS sit_esp_cte,
					  CHAR(1)       AS id_sit_esp_cred,
					  INTEGER       AS id_causa_esp_cred,
					  CHAR(75)      AS sit_esp_cred,
					  DECIMAL(18,2) AS mora_base,
					  DECIMAL(18,2) AS mora_copete,
					  DECIMAL(18,2) AS iva_mora_base,
					  DECIMAL(18,2) AS iva_mora_copete;


	DEFINE iSqlErr          INT;
	DEFINE cCodRet           CHAR(5);
	DEFINE vCodRet           CHAR(6);
	DEFINE cMensajeRet       CHAR(80);
	DEFINE pEmpresa          CHAR(3);
	DEFINE cEmpresa          CHAR(3);
	DEFINE cNumCte           CHAR(20);
	DEFINE cNumCredito       CHAR(20);
	DEFINE cCodTipCred       CHAR(2);
	DEFINE cNumTarjeta       CHAR(20);
	DEFINE cDescStatusCred   CHAR(60);
	DEFINE cSucursal         CHAR(4);
	DEFINE iIdUnidadProd     INTEGER;
	DEFINE cCodCaract2       CHAR(3);
	DEFINE dMontoFinanciado  DECIMAL(18,2);
	DEFINE dIvaSuc           DECIMAL(5,3);
	DEFINE dtFechaOrigen     DATE;
	DEFINE dtFechaProxPago   DATE;
	DEFINE dPagoMinimo       DECIMAL(18,2);
	DEFINE dtFechaUltPago    DATE;
	DEFINE iPlazo            INTEGER;
	DEFINE iPagosRealizados  INTEGER;
	DEFINE dLineaOtorgada    DECIMAL(18,2);
	DEFINE dTasaInteres      DECIMAL(9,6);
	DEFINE dTasaMoratorios   DECIMAL(9,6);
	DEFINE dMontoSBC         DECIMAL(14,2);
	DEFINE dCapVig           DECIMAL(18,2);
	DEFINE dCapTrans         DECIMAL(18,2);
	DEFINE dCapVdoExig       DECIMAL(18,2);
	DEFINE dCapVdoNoExig     DECIMAL(18,2);
	DEFINE dSdoActCap        DECIMAL(18,2);
	DEFINE dIntVig           DECIMAL(18,2);
	DEFINE dIntVdo           DECIMAL(18,2);
	DEFINE dIntMoratorio     DECIMAL(18,2);
	DEFINE dIntMoratorio_d   DECIMAL(18,2);
	DEFINE dIntMes           DECIMAL(18,2);
	DEFINE dSdoActInt        DECIMAL(18,2);
	DEFINE dIvaIntVig        DECIMAL(18,2);
	DEFINE dIvaIntVdo        DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  DECIMAL(18,2);
	DEFINE dIvaIntMes        DECIMAL(18,2);
	DEFINE dSdoActIvaInt     DECIMAL(18,2);
	DEFINE dComPend          DECIMAL(18,2);
	DEFINE dIvaCom           DECIMAL(18,2);
	DEFINE dSdoRetenido      DECIMAL(18,2);
	DEFINE dSdoTotalLiq      DECIMAL(18,2);
	DEFINE dtIvaFechaPag         DATE;
	DEFINE dtFechaCuota          DATE;
	DEFINE dIntDevengado         DECIMAL(18,2);
	DEFINE dIvaIntDevengado      DECIMAL(18,2);
	DEFINE dLineaDisponible      DECIMAL(18,2);
	DEFINE dPagosVdos            DECIMAL(18,2);
	DEFINE cDescBloqueoCta       CHAR(60);
	DEFINE cDescCausaBloqueoCta  CHAR(50);
	DEFINE cSitCte               CHAR(1);
	DEFINE cCausaCte             INTEGER;
	DEFINE cDescSitEspCte        CHAR(75);
	DEFINE cSitCred              CHAR(1);
	DEFINE cCausaCred            INTEGER;
	DEFINE cDescSitEspCred       CHAR(75);
	DEFINE dFactorComision       DECIMAL(18,2);
	DEFINE dtMesiversario        DATE;
	DEFINE dtFechaHoy            DATE;
	DEFINE cTipCred              CHAR(2);
	DEFINE cind_comision   CHAR(1);
	DEFINE ctran_comision  CHAR(4);
	DEFINE vRetCs_acum          DECIMAL(18,2);
	DEFINE dMoraBase		DECIMAL(18,2);
	DEFINE dMoraCopete		DECIMAL(18,2);
	DEFINE dIvaMoraBase		DECIMAL(18,2);
	DEFINE dIvaMoraCopete	DECIMAL(18,2);

	LET iSqlErr             = 0;
	LET cCodRet             = "00000";
	LET vCodRet             = "000000";
	LET cMensajeRet          = '';
	LET pEmpresa             = '001';
	LET cEmpresa             = '';
	LET cNumCte              = '';
	LET cNumCredito          = '';
	LET cCodTipCred          = '';
	LET cNumTarjeta          = '';
	LET cDescStatusCred      = '';
	LET cSucursal             = '';
	LET iIdUnidadProd         = 0;
	LET cCodCaract2           = '';
	LET dMontoFinanciado      = 0;
	LET dIvaSuc               = 0;
	LET dtFechaOrigen         = DATE(1);
	LET dtFechaProxPago       = DATE(1);
	LET dPagoMinimo           = 0;
	LET dtFechaUltPago        = DATE(1);
	LET iPlazo                = 0;
	LET iPagosRealizados      = 0;
	LET dLineaOtorgada        = 0;
	LET dTasaInteres          = 0;
	LET dTasaMoratorios       = 0;
	LET dMontoSBC             = 0;
	LET dCapVig               = 0;
	LET dCapTrans             = 0;
	LET dCapVdoExig           = 0;
	LET dCapVdoNoExig         = 0;
	LET dSdoActCap            = 0;
	LET dIntVig               = 0;
	LET dIntVdo               = 0;
	LET dIntMoratorio         = 0;
	LET dIntMoratorio_d       = 0;
	LET dIntMes               = 0;
	LET dSdoActInt            = 0;
	LET dIvaIntVig            = 0;
	LET dIvaIntVdo            = 0;
	LET dIvaIntMoratorio      = 0;
	LET dIvaIntMes            = 0;
	LET dSdoActIvaInt         = 0;
	LET dComPend              = 0;
	LET dIvaCom               = 0;
	LET dSdoRetenido          = 0;
	LET dSdoTotalLiq          = 0;
	LET dtIvaFechaPag         = DATE(1);
	LET dtFechaCuota          = DATE(1);
	LET dIntDevengado         = 0;
	LET dIvaIntDevengado      = 0;
	LET dLineaDisponible      = 0;
	LET dPagosVdos            = 0;
	LET cDescBloqueoCta       = '';
	LET cDescCausaBloqueoCta  = '';
	LET cSitCte               = '';
	LET cCausaCte             = 0;
	LET cDescSitEspCte        = '';
	LET cSitCred              = '';
	LET cCausaCred            = 0;
	LET cDescSitEspCred       = '';
	LET dFactorComision       = 0;
	LET dtMesiversario        = DATE(1);
	LET dtFechaHoy            = DATE(1);
	LET cTipCred              = '';
	LET cind_comision         = '';
	LET ctran_comision        = '';
	LET vRetCs_acum           = 0;
	LET dMoraBase             = NULL;
	LET dMoraCopete           = NULL;
	LET dIvaMoraBase          = NULL;
	LET dIvaMoraCopete        = NULL;


	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''), NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
						NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
						NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
						NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
						NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
						NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dIvaIntDevengado,0),
						NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''),
						NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''),
						NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''), 
						NVL(dMoraBase, 0), NVL(dMoraCopete, 0), NVL(dIvaMoraBase, 0), NVL(dIvaMoraCopete, 0);
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/mfinis/F3rmin/sp_consulta_saldos_generalcre.out";
		--TRACE ON;

		IF cID_USUARIOC = '' OR cID_FUNCIONC = '' OR (pEmpresa IS NULL AND pNumCredito IS NULL) THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''), NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
						NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
						NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
						NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
						NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
						NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dIvaIntDevengado,0),
						NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''),
						NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''),
						NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''), 
						NVL(dMoraBase, 0), NVL(dMoraCopete, 0), NVL(dIvaMoraBase, 0), NVL(dIvaMoraCopete, 0);
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC, cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''), NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
						NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
						NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
						NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
						NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
						NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dIvaIntDevengado,0),
						NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''),
						NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''),
						NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''), 
						NVL(dMoraBase, 0), NVL(dMoraCopete, 0), NVL(dIvaMoraBase, 0), NVL(dIvaMoraCopete, 0);
		END IF;

		EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general_mora(pEmpresa, pNumCredito)
		INTO vCodRet,
				cMensajeRet,
				cNumCredito,
				cCodTipCred,
				dtFechaOrigen,
				dtFechaProxPago,
				dPagoMinimo,
				dtFechaUltPago,
				iPlazo,
				iPagosRealizados,
				dLineaOtorgada,
				dTasaInteres,
				dTasaMoratorios,
				dMontoSBC,
				dCapVig,
				dCapTrans,
				dCapVdoExig,
				dCapVdoNoExig,
				dSdoActCap,
				dIntVig,
				dIntVdo,
				dIntMoratorio,
				dIntMes,
				dSdoActInt,
				dIvaIntVig,
				dIvaIntVdo,
				dIvaIntMoratorio,
				dIvaIntMes,
				dSdoActIvaInt,
				dComPend,
				dIvaCom,
				dSdoRetenido,
				dSdoTotalLiq,
				dIntDevengado,
				dIvaIntDevengado,
				dLineaDisponible,
				dPagosVdos,
				cDescStatusCred,
				iIdUnidadProd,
				cDescBloqueoCta,
				cCodCaract2,
				cDescCausaBloqueoCta,
				cSitCte,
				cCausaCte,
				cDescSitEspCte,
				cSitCred,
				cCausaCred,
				cDescSitEspCred, 
				dMoraBase, dMoraCopete, dIvaMoraBase, dIvaMoraCopete;

		IF vCodRet = '000000' THEN
		--      proceso correcto
			LET cCodRet = "00000";
			RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''), NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
						NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
						NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
						NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
						NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
						NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dIvaIntDevengado,0),
						NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''),
						NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''),
						NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''), 
						NVL(dMoraBase, 0), NVL(dMoraCopete, 0), NVL(dIvaMoraBase, 0), NVL(dIvaMoraCopete, 0);
		END IF;
		
		IF vCodRet = '000001' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''), NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
						NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
						NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
						NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
						NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
						NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dIvaIntDevengado,0),
						NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''),
						NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''),
						NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''), 
						NVL(dMoraBase, 0), NVL(dMoraCopete, 0), NVL(dIvaMoraBase, 0), NVL(dIvaMoraCopete, 0);
		END IF;
		
		IF vCodRet::INTEGER = 2 THEN
			LET cCodRet = '00373';
		END IF;
		
		RETURN cCodRet, cNumCredito, NVL(cCodTipCred,''), NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
						NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
						NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
						NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
						NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
						NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0), NVL(dIvaIntDevengado,0),
						NVL(dLineaDisponible,0), NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''),
						NVL(cCodCaract2,''), NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''),
						NVL(cSitCred,''), NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),''), 
						NVL(dMoraBase, 0), NVL(dMoraCopete, 0), NVL(dIvaMoraBase, 0), NVL(dIvaMoraCopete, 0);
	END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 10/07/2013",
"DESCRIPCION: Obtiene los saldos actuales de las cuentas de crédito";

CREATE PROCEDURE "informix".sp_consultabitacorapagos(cID_USUARIOC CHAR(8),
                                                     cID_FUNCIONC CHAR(10),
                                                     pFolio CHAR(16),
                                                     pIfecha DATE,
                                                     pFfecha DATE,
                                                         pRegistros INT,
                                                         pRecuperacion INT)
        RETURNING CHAR(5) AS codigo_retorno,
                  CHAR(20) AS Num_Credito,
                  CHAR(107) AS NombreCliente,
                  DECIMAL(18,2) AS saldo_actual,
                  DECIMAL(18,2) AS aplicacion,
                  DECIMAL(18,2) AS saldo_nuevo,
                  CHAR(4) AS transaccion,
                  CHAR(50) AS DescripcionTransacc,
                  CHAR(50) AS Descripcion_pago,
                  CHAR(16) AS Folio,
                  DECIMAL(18,2) AS Capital_vigente,
                  DECIMAL(18,2) AS Capital_transitorio,
                  DECIMAL(18,2) AS Capital_vencido,
                  DECIMAL(18,2) AS Capital_vencido_noexigible,
                  DECIMAL(18,2) AS Capital_total,
                  DECIMAL(18,2) AS Interes_vigente,
                  DECIMAL(18,2) AS Iva_interesvigente,
                  DECIMAL(18,2) AS Interes_vencido,
                  DECIMAL(18,2) AS Iva_interesvencido,
                  DECIMAL(18,2) AS Interes_moratorio,
                  DECIMAL(18,2) AS Iva_interesmoratorio,
                  DATE AS fecha_movimiento,
				  DECIMAL(16,2) AS InteresMoratorioBase,
                  DECIMAL(16,2) AS InteresMoratorioCopete,
                  DECIMAL(16,2) AS IvaInteresMoratorioBase,
				  DECIMAL(16,2) AS IvaInteresMoratorioCopete;

DEFINE iSqlErr          INT;
DEFINE cCodRet           CHAR(5);
DEFINE cMensajeRet       CHAR(80);
DEFINE iNoRegs INTEGER;
DEFINE iRegistro INTEGER;
DEFINE cSecuencia CHAR(1);
DEFINE cStatus CHAR(1);
DEFINE cEmpresa CHAR(3);
DEFINE cNum_Credito CHAR(20);
DEFINE dFecha_mov DATE;
DEFINE cNumcte CHAR(20);
DEFINE cSucursal CHAR(4);
DEFINE cNum_producto CHAR(4);
DEFINE cFolio CHAR(16);
DEFINE vConcepto_mov CHAR(50);
DEFINE vDescripcion_pago CHAR(50);
DEFINE vDescripcion_rev CHAR(50);
DEFINE mImporte_pagoA DECIMAL(18,2);
DEFINE mImporte_pagoP DECIMAL(18,2);
DEFINE mImporte_pagoN DECIMAL(18,2);
DEFINE cTransaccion CHAR(4);
DEFINE mCapital_vigente DECIMAL(18,2);
DEFINE mCapital_transitorio DECIMAL(18,2);
DEFINE mCapital_vencido DECIMAL(18,2);
DEFINE mCapital_vencido_noexigible DECIMAL(18,2);
DEFINE mCapital_total DECIMAL(18,2);
DEFINE mInteres_vigente DECIMAL(18,2);
DEFINE mIva_interesvigente DECIMAL(18,2);
DEFINE mInteres_vencido DECIMAL(18,2);
DEFINE mIva_interesvencido DECIMAL(18,2);
DEFINE mInteres_moratorio DECIMAL(18,2);
DEFINE mIva_interesmoratorio DECIMAL(18,2);
DEFINE cUsuario CHAR(8);
DEFINE vcNombreCliente CHAR(107);
DEFINE iRegsCred INTEGER;
DEFINE iRegsBitp INTEGER;
DEFINE cDescripcionTransacc CHAR(50);
DEFINE mInteresMoratorioBase MONEY(16,2);
DEFINE mInteresMoratorioCopete MONEY(16,2);
DEFINE mIvaInteresMoratorioBase MONEY(16,2);
DEFINE mIvaInteresMoratorioCopete MONEY(16,2);


LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cMensajeRet          = '';
LET iRegistro = 0;
LET cSecuencia = '';
LET cStatus = '';
LET cEmpresa = '';
LET cNum_Credito = '';
LET dFecha_mov = '';
LET cNumcte = '';
LET cSucursal = '';
LET cNum_producto = '';
LET cFolio = '';
LET vConcepto_mov = '';
LET vDescripcion_pago = '';
LET vDescripcion_rev = '';
LET mImporte_pagoA = 0;
LET mImporte_pagoP = 0;
LET mImporte_pagoN = 0;
LET cTransaccion = '';
LET mCapital_vigente = 0;
LET mCapital_transitorio = 0;
LET mCapital_vencido = 0;
LET mCapital_vencido_noexigible = 0;
LET mCapital_total = 0;
LET mInteres_vigente = 0;
LET mIva_interesvigente = 0;
LET mInteres_vencido = 0;
LET mIva_interesvencido = 0;
LET mInteres_moratorio = 0;
LET mIva_interesmoratorio = 0;
LET cUsuario = '';
LET vcNombreCliente = '';
LET iRegsCred = 0;
LET iRegsBitp = 0;
LET cDescripciontransacc = '';
LET iNoRegs = 0;
LET mInteresMoratorioBase = 0;
LET mInteresMoratorioCopete = 0;
LET mIvaInteresMoratorioBase = 0;
LET mIvaInteresMoratorioCopete = 0;


SET ISOLATION TO DIRTY READ;

BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
                                cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
								mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
                                mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
								mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete;
                END IF;
        END EXCEPTION;

        IF  cID_USUARIOC = '' OR cID_FUNCIONC = '' OR pIfecha = '' OR pFfecha = '' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
						cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
						mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
						mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
						mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC, cID_FUNCIONC) INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
						cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
						mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
						mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
						mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete;
        END IF;
--
        SELECT COUNT(*)
        INTO    iRegsCred
        FROM    bdicred:"informix".sd_bitacorapagos bpg
        WHERE   bpg.folio = (CASE WHEN NVL(pFolio,'') = '' THEN bpg.folio ELSE pFolio END)
          AND   bpg.fecha_mov BETWEEN pIfecha AND pFfecha;
--
        IF iRegsCred = 0 THEN
        --      EL REGISTRO QUE DESEA CONSULTAR NO EXISTE
			LET cCodRet = '00151';
			RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
					cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
					mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
					mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
					mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete;
        ELSE
			SELECT COUNT(*)
			INTO iRegsBitp
			FROM bdicred:"informix".sd_bitacorapagos bpg
			WHERE   bpg.folio = (CASE WHEN NVL(pFolio,'') = '' THEN bpg.folio ELSE pFolio END)
				AND     bpg.secuencia = "3"
				AND     bpg.fecha_mov BETWEEN pIfecha AND pFfecha;
				
			IF iRegsBitp = 0 THEN
			--      NO EXISTEN REGISTROS CON SECUENCIA IGUAL A 3
				LET cCodRet = '00155';
				RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
						cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
						mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
						mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
						mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete;
			ELSE
				SET ISOLATION TO DIRTY READ;
				FOREACH
						SELECT SKIP pRegistros FIRST pRecuperacion
								bpg.num_credito,
								TRIM(TRIM(TRIM(cte.nombre1)||" "||TRIM(cte.nombre2))||" "||TRIM(cte.apell_paterno)||" "||TRIM(cte.apell_materno))||TRIM(cte.razon_social) NomClte,
								bpg.numcte,
								bpg.folio,
								bpg.descripcion_pago,
								bpg.capital_vigente,
								bpg.transaccion,
								NVL(cpm.concepto,'NO EXISTE DESCRIPCION'),
								bpg.capital_vigente,
								bpg.capital_transitorio,
								bpg.capital_vencido,
								bpg.capital_vencido_noexigible,
								bpg.capital_total,
								bpg.interes_vigente,
								bpg.iva_interesvigente,
								bpg.interes_vencido,
								bpg.iva_interesvencido,
								bpg.interes_moratorio,
								bpg.iva_interesmoratorio,
								bpg.fecha_mov,
								bpg.interes_moratorio_base,
								bpg.interes_moratorio_copete,
								bpg.iva_interesmoratoriobase,
								bpg.iva_interesmoratoriocopete
						INTO
								cNum_Credito,
								vcNombreCliente,
								cNumcte,
								cFolio,
								vDescripcion_pago,
								mImporte_pagoN,
								cTransaccion,
								cDescripcionTransacc,
								mCapital_vigente,
								mCapital_transitorio,
								mCapital_vencido,
								mCapital_vencido_noexigible,
								mCapital_total,
								mInteres_vigente,
								mIva_interesvigente,
								mInteres_vencido,
								mIva_interesvencido,
								mInteres_moratorio,
								mIva_interesmoratorio,
								dFecha_mov,
								mInteresMoratorioBase,
								mInteresMoratorioCopete,
								mIvaInteresMoratorioBase, 
								mIvaInteresMoratorioCopete
						FROM bdicred:"informix".sd_bitacorapagos bpg
						LEFT OUTER JOIN bdinteg:"informix".si_cliente cte
						  ON (cte.numcte = bpg.numcte)
						LEFT OUTER JOIN bdicred:"informix".sd_conceptospagomanual cpm
						  ON (cpm.transacc = bpg.transaccion)
						WHERE   bpg.folio = (CASE WHEN NVL(pFolio,'') = '' THEN bpg.folio ELSE pFolio END)
						AND     bpg.secuencia = "3"
						AND     bpg.fecha_mov BETWEEN pIfecha AND pFfecha
--
					SELECT capital_vigente
					INTO mImporte_pagoA
					FROM bdicred:"informix".sd_bitacorapagos bpg
					WHERE   bpg.folio = cFolio
						AND     bpg.secuencia = "1";
--
					SELECT capital_vigente
					INTO mImporte_pagoP
					FROM bdicred:"informix".sd_bitacorapagos bpg
					WHERE   bpg.folio = CFolio
						AND     bpg.secuencia = "2";
                                
                                
                    LET iNoRegs = iNoRegs + 1;

                    RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
						cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
						mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
						mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
						mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete WITH RESUME;
						
				END FOREACH;
                        
				IF pRegistros > 0 AND iNoRegs = 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, cNum_Credito, vcNombreCliente, mImporte_pagoA, mImporte_pagoP, mImporte_pagoN, cTransaccion,
						cDescripcionTransacc, vDescripcion_pago, cFolio, mCapital_vigente, mCapital_transitorio, mCapital_vencido,
						mCapital_vencido_noexigible, mCapital_total, mInteres_vigente, mIva_interesvigente, mInteres_vencido,
						mIva_interesvencido, mInteres_moratorio, mIva_interesmoratorio, dFecha_mov,
						mInteresMoratorioBase, mInteresMoratorioCopete, mIvaInteresMoratorioBase, mIvaInteresMoratorioCopete;
				END IF;
                        
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 10/07/2013",
"DESCRIPCION: Consulta los movimientos para el reporte de pagos de cuentas de crédito";

CREATE PROCEDURE "informix".sp_criteriosgeneracionreportepagoscre(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoCampania SMALLINT, pGpoParametro CHAR(10), pNumParametro INTEGER)
		RETURNING CHAR(5) AS codret,
				SMALLINT AS tipo_campania, 
				CHAR(10) AS grupo_parametro,
				INTEGER AS num_parametro,
				CHAR(100) AS descripcion,
				CHAR(100) AS valor_alfabetico,
				DECIMAL(18,2) AS valor_numerico,
				DATE AS fecha_insert,
				CHAR(8) AS user_insert;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE sTipoCapania SMALLINT;
	DEFINE cGrupoParametro CHAR(10);
	DEFINE iNumParametro INTEGER;
	DEFINE cDescripcion CHAR(100);
	DEFINE cValorAlfabetico CHAR(100);
	DEFINE dValorNumerico DECIMAL(18,2);
	DEFINE dFechaInsert DATE;
	DEFINE cUserInsert CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET sTipoCapania = 0;
	LET cGrupoParametro = '';
	LET iNumParametro = 0;
	LET cDescripcion = '';
	LET cValorAlfabetico = '';
	LET dValorNumerico = NULL;
	LET dFechaInsert = NULL;
	LET cUserInsert = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sTipoCapania, cGrupoParametro, iNumParametro, cDescripcion, cValorAlfabetico, dValorNumerico, dFechaInsert, cUserInsert;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_criteriosgeneracionreportepagoscre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sTipoCapania, cGrupoParametro, iNumParametro, cDescripcion, cValorAlfabetico, dValorNumerico, dFechaInsert, cUserInsert;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sTipoCapania, cGrupoParametro, iNumParametro, cDescripcion, cValorAlfabetico, dValorNumerico, dFechaInsert, cUserInsert;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:"informix".sp_consulta_criteriosgeneracionreporte(cEmpresa, pTipoCampania, pGpoParametro, pNumParametro)
		INTO cCodRetSp, sTipoCapania, cGrupoParametro, iNumParametro, cDescripcion, cValorAlfabetico, dValorNumerico, dFechaInsert, cUserInsert
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consulta_criteriosgeneracionreporte';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, sTipoCapania, cGrupoParametro, iNumParametro, cDescripcion, cValorAlfabetico, dValorNumerico, dFechaInsert, cUserInsert;
			END IF;
			
			RETURN cCodRet, sTipoCapania, cGrupoParametro, iNumParametro, cDescripcion, cValorAlfabetico, dValorNumerico, dFechaInsert, cUserInsert WITH RESUME;
		
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 06/08/2014',
'DESCRIPCION: Consulta de productos de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtenertransaccionpagosmanualescre(cID_USUARIOC CHAR(8),
                                                                  cID_FUNCIONC CHAR(10),
                                                                  p_Codconcepto CHAR(2),
                                                                  p_Transaccion CHAR(4),
                                                                  p_CodFun CHAR(3),
																  pNumCredito CHAR(20),
																  pProducto CHAR(4))
        RETURNING CHAR(5)       AS CodRet,      --cod_ret
                  CHAR(2)       AS codigo_pago, --Codigo pago
                  CHAR(50)      AS descripcion, --descripcion
                  CHAR(4)       AS transaccion, --transaccion
                  CHAR(3)       AS codigo_fun;  --codigo_fun

DEFINE cCodRet          CHAR(5);
DEFINE iSqlErr          INT;
DEFINE v_cod_ret        CHAR(6);
DEFINE cCodigo          CHAR(2);
DEFINE cConcepto        CHAR(50);
DEFINE cTransaccion     CHAR(4);
DEFINE sCod_Fun         CHAR(3);


LET cCodRet             = "00000";
LET iSqlErr             = 0;
LET v_cod_ret            = '000000';
LET cCodigo              = "";
LET cConcepto            = "";
LET cTransaccion         = "";
LET sCod_Fun             = "";


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "/tmp/mfinis/F3rmin/sp_obtenertransaccionpagosmanualescap.out";
--TRACE ON;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,cCodigo,cConcepto,cTransaccion,sCod_Fun;
                END IF;
        END EXCEPTION;

        IF  cID_USUARIOC = '' OR cID_FUNCIONC = '' OR pNumCredito = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cConcepto, cTransaccion, sCod_Fun;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC, cID_FUNCIONC) INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cCodigo, cConcepto, cTransaccion, sCod_Fun;
        END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:"informix".sp_obtenertransaccionpagosmanuales(p_Codconcepto, p_Transaccion, p_CodFun, pNumCredito, pProducto)
                INTO v_cod_ret, cCodigo, cConcepto, cTransaccion, sCod_Fun

                IF v_cod_ret::INTEGER = 0 THEN
					LET cCodRet = "00000";
                ELSE
					IF v_cod_ret::INTEGER = 1 THEN
						LET cCodRet = '00091';
						RETURN cCodRet,cCodigo,cConcepto,cTransaccion,sCod_Fun;
					ELIF v_cod_ret::INTEGER = 2 THEN
						LET cCodRet = '00046';
						RETURN cCodRet,cCodigo,cConcepto,cTransaccion,sCod_Fun;
					ELIF v_cod_ret::INTEGER IN (3, 5, 6, 7) THEN
						LET cCodRet = '00021';
						RETURN cCodRet,cCodigo,cConcepto,cTransaccion,sCod_Fun;
					ELIF v_cod_ret::INTEGER = 4 THEN
						LET cCodRet = '00047';
						RETURN cCodRet,cCodigo,cConcepto,cTransaccion,sCod_Fun;
					END IF;
                END IF;

                RETURN cCodRet, cCodigo, cConcepto, cTransaccion, sCod_Fun WITH RESUME;

        END FOREACH;

	END;

END PROCEDURE
DOCUMENT  "AUTOR: Oscar Flores Conde",
"FECHA: 10/07/2013",
"DESCRIPCION: Consulta el catalogo de transacciones para los conceptos de pagos de credito";

CREATE PROCEDURE "informix".sp_reportemensualcondonacionescre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE,pArchDescarga CHAR(150))
        RETURNING CHAR(5) AS codret;
        
        DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iExiste INT;
		DEFINE iPid INTEGER;
		DEFINE cTmpTable CHAR(5000);
        DEFINE cCmd1 CHAR(6000);
        DEFINE cCmd2 CHAR(6000);
		DEFINE iNoRegistros INTEGER;
		DEFINE iIdxSecReg INTEGER;
		DEFINE cSecuencia CHAR(1);
		DEFINE cProducto CHAR(45);
		DEFINE cNumCredito CHAR(20); 
		DEFINE cFechaMov CHAR(10);
		DEFINE mInteresVencido MONEY(18,2);
		DEFINE mIvaInteresVencido MONEY(18,2);
		DEFINE mIvaInteresMoratorio MONEY(18,2);
		DEFINE mInteresMoratorioBase MONEY(18,2);
		DEFINE mInteresMoratorioCopete MONEY(18,2);
		DEFINE mIvaInteresMoratorioBase MONEY(18,2);
		DEFINE mIvaInteresMoratorioCopete MONEY(18,2);
		DEFINE mImportePago MONEY(18,2);
		DEFINE mCapitalVigente MONEY(18,2);
		DEFINE cSecuenciaData CHAR(1);
		DEFINE cProductoData CHAR(45);
		DEFINE cNumCreditoData CHAR(20); 
		DEFINE cFechaMovData CHAR(10);
		DEFINE mInteresVencidoData MONEY(18,2);
		DEFINE mIvaInteresVencidoData MONEY(18,2);
		DEFINE mIvaInteresMoratorioData MONEY(18,2);
		DEFINE mInteresMoratorioBaseData MONEY(18,2);
		DEFINE mInteresMoratorioCopeteData MONEY(18,2);
		DEFINE mIvaInteresMoratorioBaseData MONEY(18,2);
		DEFINE mIvaInteresMoratorioCopeteData MONEY(18,2);
		DEFINE mImportePagoData MONEY(18,2);
		DEFINE mCapitalVigenteData MONEY(18,2);
		DEFINE mInteresMoratorio MONEY(18,2);
       
        LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET iExiste = 0;
		LET iPid = DBINFO('sessionid');
		LET cTmpTable = '';
        LET cCmd1 = '';
        LET cCmd2 = '';
		LET iNoRegistros = 0;
		LET iIdxSecReg = 0;
		LET cSecuencia = '';
		LET cProducto = '';
		LET cNumCredito = '';
		LET cFechaMov = '';
		LET mInteresVencido = 0;
		LET mIvaInteresVencido = 0;
		LET mIvaInteresMoratorio = 0;
		LET mInteresMoratorioBase = 0;
		LET mInteresMoratorioCopete = 0;
		LET mIvaInteresMoratorioBase = 0;
		LET mIvaInteresMoratorioCopete = 0;
		LET mImportePago = 0;
		LET mCapitalVigente = 0;
		LET cSecuenciaData = '';
		LET cProductoData = '';
		LET cNumCreditoData = '';
		LET cFechaMovData = '';
		LET mInteresVencidoData = 0;
		LET mIvaInteresVencidoData = 0;
		LET mIvaInteresMoratorioData = 0;
		LET mInteresMoratorioBaseData = 0;
		LET mInteresMoratorioCopeteData = 0;
		LET mIvaInteresMoratorioBaseData = 0;
		LET mIvaInteresMoratorioCopeteData = 0;
		LET mImportePagoData = 0;
		LET mCapitalVigenteData = 0;
		LET mInteresMoratorio = 0;

        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_reportemensualcondonacionescre.out';
			--TRACE ON;
			
			IF pIdUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchDescarga = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet;
			END IF;
			
			---Se busca a los creditos que se les aplico pago por condonacion
			SET ISOLATION TO DIRTY READ;
			FOREACH	SELECT bp.secuencia,NVL(sdp.num_producto||' '||sdp.nombre_prod, '') AS producto, bp.num_credito, bp.fecha_mov, bp.interes_vencido, bp.iva_interesvencido, bp.iva_interesmoratorio,bp.interes_moratorio_base,interes_moratorio_copete,iva_interesmoratoriobase,iva_interesmoratoriocopete,bp.importe_pago,bp.capital_vigente
					INTO cSecuencia,cProducto,cNumCredito,cFechaMov,mInteresVencido,mIvaInteresVencido,mIvaInteresMoratorio,mInteresMoratorioBase,mInteresMoratorioCopete,mIvaInteresMoratorioBase,mIvaInteresMoratorioCopete,mImportePago,mCapitalVigente
					FROM bdicred:"informix".sd_bitacorapagos bp LEFT JOIN bdicred:"informix".sd_definicion sdp ON bp.num_producto = sdp.num_producto
					WHERE bp.fecha_mov BETWEEN pFechaInicio AND pFechaFin
					AND bp.transaccion IN (SELECT DISTINCT (a.transacc) 
											FROM bdicred:"informix".sd_conceptospagomanual a 
											WHERE a.codigo IN ('27', '28')
										   UNION ALL
										   SELECT DISTINCT (b.transacc) 
											FROM bdicred:"informix".sd_conceptospagomanualcrd b 
											WHERE b.codigo IN ('17', '18', '19', '20', '21', '22')
										   ) 
									
				LET iNoRegistros = iNoRegistros + DBINFO('sqlca.sqlerrd2');
				
				LET iIdxSecReg = iIdxSecReg + 1;
				
				IF iNoRegistros > 0 THEN
					IF iIdxSecReg <=3 THEN	
						IF cSecuencia::INTEGER = 1 THEN
							LET cProductoData = cProducto;
							LET cNumCreditoData = cNumCredito;
							LET cFechaMovData = cFechaMov;
						END IF;
						IF cSecuencia::INTEGER = 2 THEN
							LET mInteresVencidoData = mInteresVencido;
							LET mIvaInteresVencidoData = mIvaInteresVencido;
							LET mIvaInteresMoratorioData = mIvaInteresMoratorio;
							LET mInteresMoratorioBaseData = mInteresMoratorioBase;
							LET mInteresMoratorioCopeteData = mInteresMoratorioCopete;
							LET mIvaInteresMoratorioBaseData = mIvaInteresMoratorioBase;
							LET mIvaInteresMoratorioCopeteData = mIvaInteresMoratorioCopete;
							LET mInteresMoratorio = mInteresMoratorioBaseData + mInteresMoratorioCopeteData + mIvaInteresMoratorioBaseData + mIvaInteresMoratorioCopeteData;
						END IF;
						IF cSecuencia::INTEGER = 3 THEN
							LET mImportePagoData = mImportePago;
							LET mCapitalVigenteData = mCapitalVigente;
						END IF;
					END IF;
					
					IF iIdxSecReg = 3  THEN 
						---Inserta datos para reporte
						INSERT INTO bdicnweb:"informix".sw_tr_registrosreportepago(usuario_consulta, id_tabla_ses,producto,cuenta,fecha_ult_mov,
																				   mIntVencImpAplicado,mIvaIntVencImpAplicado,mIvaIntMoraImpAplicado,
																				   mIntMoraBaseImpAplicado,mIntMoraCopeteImpAplicado,mIvaIntMoraBaseImpAplicado,
																				   mIvaIntMoraCopeteImpAplicado,mImportePagoCondona,mCapVigSdoNuevo, mInteresMoratorio)
						VALUES(pIdUsuario,TO_CHAR(iPid),cProductoData,cNumCreditoData,cFechaMovData,mInteresVencidoData,mIvaInteresVencidoData,
							   mIvaInteresMoratorioData,mInteresMoratorioBaseData,mInteresMoratorioCopeteData,mIvaInteresMoratorioBaseData,
							   mIvaInteresMoratorioCopeteData,mImportePagoData,mCapitalVigenteData,mInteresMoratorio);										   
															   
						---Inicializacion de variables
						LET iIdxSecReg = 0;
						LET cSecuencia = '';
						LET cProducto = '';
						LET cNumCredito = '';
						LET cFechaMov = '';
						LET mInteresVencido = 0;
						LET mIvaInteresVencido = 0;
						LET mIvaInteresMoratorio = 0;
						LET mInteresMoratorioBase = 0;
						LET mInteresMoratorioCopete = 0;
						LET mIvaInteresMoratorioBase = 0;
						LET mIvaInteresMoratorioCopete = 0;
						LET mImportePago = 0;
						LET mCapitalVigente = 0;
						LET cSecuenciaData = '';
						LET cProductoData = '';
						LET cNumCreditoData = '';
						LET cFechaMovData = '';
						LET mInteresVencidoData = 0;
						LET mIvaInteresVencidoData = 0;
						LET mIvaInteresMoratorioData = 0;
						LET mInteresMoratorioBaseData = 0;
						LET mInteresMoratorioCopeteData = 0;
						LET mIvaInteresMoratorioBaseData = 0;
						LET mIvaInteresMoratorioCopeteData = 0;
						LET mImportePagoData = 0;
						LET mCapitalVigenteData = 0;
						LET mInteresMoratorio = 0;
					END IF;	

				END IF;	
			END FOREACH;			
		
			LET cCmd1 ="producto,cuenta,TO_CHAR(DATE(TO_DATE(fecha_ult_mov, '%m/%d/%Y')),'%d/%m/%Y') as fecha_mov, TRIM(NVL(TO_CHAR(mIntVencImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIntVencImpAplicado,";
			LET cCmd1 =""||TRIM(cCmd1)||"TRIM(NVL(TO_CHAR(mIvaIntVencImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIvaIntVencImpAplicado, TRIM(NVL(TO_CHAR(mIvaIntMoraImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIvaIntMoraImpAplicado,";
			LET cCmd1 =""||TRIM(cCmd1)||"TRIM(NVL(TO_CHAR(mInteresMoratorio, '- #,###,###,###,##&.&&'), '')) as mInteresMoratorio,TRIM(NVL(TO_CHAR(mCapVigSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mCapVigSdoNuevo,";
			LET cCmd1 =""||TRIM(cCmd1)||"TRIM(NVL(TO_CHAR(mImportePagoCondona, '- #,###,###,###,##&.&&'), '')) as mImportePagoCondona";    
			
			SYSTEM TRIM('/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||'  SELECT '||TRIM(cCmd1)||' FROM bdicnweb:sw_tr_registrosreportepago WHERE usuario_consulta = '||pIdUsuario||' AND id_tabla_ses = '||TRIM(TO_CHAR(iPid))||';" | /ifxsif01/bin/dbaccess > /dev/null 2>&1');
			
			-- EjecuciÃ³n del SP para la carga de los encabezados
			EXECUTE PROCEDURE bdicnweb:"informix".sp_obtieneencabezadomasivo(pIdFuncion, pArchDescarga) INTO cCodRetSp;
			IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
			END IF;
			
			--se eliminan los registros consultados
			DELETE bdicnweb:"informix".sw_tr_registrosreportepago 
			WHERE usuario_consulta = pIdUsuario AND id_tabla_ses = TO_CHAR(iPid);
		
			RETURN cCodRet;
        END;
END PROCEDURE
DOCUMENT "AUTOR: Rodolfo Conde Flores",
"FECHA: 09/09/2013",
"DESCRIPCION: Generacion del reporte mensual de pagos por condonaciones en SOCWEB",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_reportepagosreversoctasmasivocre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
        pArchDescarga CHAR(150), pLote int, pUsuarioC CHAR(8))
        RETURNING CHAR(5) AS codret;
        
        DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iExiste INT;
        DEFINE cCmd1 CHAR(6000);
        DEFINE cCmd2 CHAR(6000);
        DEFINE cCmd3 CHAR(6000);
        DEFINE cCmd4 CHAR(6000);
        DEFINE cUser CHAR(8);
        --- Variables para detalles de capitales
		DEFINE cReg              CHAR(3);
		DEFINE cSecuencia        CHAR(1);
		DEFINE cConcepto         CHAR(30);
		DEFINE cNumCredito       CHAR(20); 
		DEFINE cNombreCte        CHAR(104);
		DEFINE m_ImportePago     MONEY(18,2);
		DEFINE mCapVigente       MONEY(18,2);
		DEFINE mCapTransitorio   MONEY(18,2);
		DEFINE mCapVencido       MONEY(18,2);
		DEFINE mCapVdoNoExigible MONEY(18,2);
		DEFINE mCapitalTotal     MONEY(18,2);
		DEFINE mIntVigente       MONEY(18,2);
		DEFINE mIvaIntVigente    MONEY(18,2);
		DEFINE mInteresVencido   MONEY(18,2);
		DEFINE mIvaIntVencido    MONEY(18,2);
		DEFINE mIntMoraCopete    MONEY(18,2);
		DEFINE mIvaIntMoratorio  MONEY(18,2); 
		DEFINE dt_FechaMov       DATE;
		DEFINE cCodigo           CHAR(2);
		DEFINE cDescripcionpag   CHAR(50);
		DEFINE cFolioGrupo       CHAR(16);
		DEFINE cFolio            CHAR(16);
		DEFINE cUsuario          CHAR(8);
		DEFINE cSucursal         CHAR(45);
		DEFINE cDescRev          CHAR(50);
		DEFINE cCodProducto      CHAR(4);
		DEFINE c_DescriPago      CHAR(50);
		DEFINE cTransaccion      CHAR(4);
		DEFINE mIntMoratorio     MONEY(18,2);
		DEFINE mIntMoraBase      MONEY(18,2);
		DEFINE mIvaIntMoraBase   MONEY(18,2);
		DEFINE mIvaIntMoraCopete MONEY(18,2);
		DEFINE iLote			 INTEGER;
		DEFINE cReg1              CHAR(3);
		DEFINE cSecuencia1        CHAR(1);
		DEFINE cConcepto1         CHAR(30);
		DEFINE cNumCredito1       CHAR(20); 
		DEFINE cNombreCte1        CHAR(104);
		DEFINE mImportePago1     MONEY(18,2);
		DEFINE mCapVigente1       MONEY(18,2);
		DEFINE mCapTransitorio1   MONEY(18,2);
		DEFINE mCapVencido1       MONEY(18,2);
		DEFINE mCapVdoNoExigible1 MONEY(18,2);
		DEFINE mCapitalTotal1     MONEY(18,2);
		DEFINE mIntVigente1       MONEY(18,2);
		DEFINE mIvaIntVigente1    MONEY(18,2);
		DEFINE mInteresVencido1   MONEY(18,2);
		DEFINE mIvaIntVencido1    MONEY(18,2);
		DEFINE mIntMoraCopete1    MONEY(18,2);
		DEFINE mIvaIntMoratorio1  MONEY(18,2); 
		DEFINE dt_FechaMov1       DATE;
		DEFINE cCodigo1           CHAR(2);
		DEFINE cDescripcionpag1   CHAR(50);
		DEFINE cFolioGrupo1       CHAR(16);
		DEFINE cFolio1            CHAR(16);
		DEFINE cUsuario1          CHAR(8);
		DEFINE cSucursal1         CHAR(4);
		DEFINE cDescRev1          CHAR(50);
		DEFINE cCodProducto1      CHAR(4);
		DEFINE c_DescriPago1      CHAR(50);
		DEFINE cTransaccion1      CHAR(4);
		DEFINE mIntMoratorio1     MONEY(18,2);
		DEFINE mIntMoraBase1      MONEY(18,2);
		DEFINE mIvaIntMoraBase1   MONEY(18,2);
		DEFINE mIvaIntMoraCopete1 MONEY(18,2);
		DEFINE cReg2              CHAR(3);
		DEFINE cSecuencia2        CHAR(1);
		DEFINE cConcepto2         CHAR(30);
		DEFINE cNumCredito2       CHAR(20); 
		DEFINE cNombreCte2        CHAR(104);
		DEFINE mImportePago2     MONEY(18,2);
		DEFINE mCapVigente2       MONEY(18,2);
		DEFINE mCapTransitorio2   MONEY(18,2);
		DEFINE mCapVencido2       MONEY(18,2);
		DEFINE mCapVdoNoExigible2 MONEY(18,2);
		DEFINE mCapitalTotal2     MONEY(18,2);
		DEFINE mIntVigente2       MONEY(18,2);
		DEFINE mIvaIntVigente2    MONEY(18,2);
		DEFINE mInteresVencido2   MONEY(18,2);
		DEFINE mIvaIntVencido2    MONEY(18,2);
		DEFINE mIntMoraCopete2    MONEY(18,2);
		DEFINE mIvaIntMoratorio2  MONEY(18,2); 
		DEFINE dt_FechaMov2       DATE;
		DEFINE cCodigo2           CHAR(2);
		DEFINE cDescripcionpag2   CHAR(50);
		DEFINE cFolioGrupo2       CHAR(16);
		DEFINE cFolio2            CHAR(16);
		DEFINE cUsuario2          CHAR(8);
		DEFINE cSucursal2         CHAR(4);
		DEFINE cDescRev2          CHAR(50);
		DEFINE cCodProducto2      CHAR(4);
		DEFINE c_DescriPago2      CHAR(50);
		DEFINE cTransaccion2      CHAR(4);
		DEFINE mIntMoratorio2     MONEY(18,2);
		DEFINE mIntMoraBase2      MONEY(18,2);
		DEFINE mIvaIntMoraBase2   MONEY(18,2);
		DEFINE mIvaIntMoraCopete2 MONEY(18,2);
		DEFINE cReg3              CHAR(3);
		DEFINE cSecuencia3        CHAR(1);
		DEFINE cConcepto3         CHAR(30);
		DEFINE cNumCredito3       CHAR(20); 
		DEFINE cNombreCte3        CHAR(104);
		DEFINE mImportePago3     MONEY(18,2);
		DEFINE mCapVigente3       MONEY(18,2);
		DEFINE mCapTransitorio3   MONEY(18,2);
		DEFINE mCapVencido3       MONEY(18,2);
		DEFINE mCapVdoNoExigible3 MONEY(18,2);
		DEFINE mCapitalTotal3     MONEY(18,2);
		DEFINE mIntVigente3       MONEY(18,2);
		DEFINE mIvaIntVigente3    MONEY(18,2);
		DEFINE mInteresVencido3   MONEY(18,2);
		DEFINE mIvaIntVencido3    MONEY(18,2);
		DEFINE mIntMoraCopete3    MONEY(18,2);
		DEFINE mIvaIntMoratorio3  MONEY(18,2); 
		DEFINE dt_FechaMov3       DATE;
		DEFINE cCodigo3           CHAR(2);
		DEFINE cDescripcionpag3   CHAR(50);
		DEFINE cFolioGrupo3       CHAR(16);
		DEFINE cFolio3            CHAR(16);
		DEFINE cUsuario3          CHAR(8);
		DEFINE cSucursal3         CHAR(4);
		DEFINE cDescRev3          CHAR(50);
		DEFINE cCodProducto3      CHAR(4);
		DEFINE c_DescriPago3      CHAR(50);
		DEFINE cTransaccion3      CHAR(4);
		DEFINE mIntMoratorio3     MONEY(18,2);
		DEFINE mIntMoraBase3      MONEY(18,2);
		DEFINE mIvaIntMoraBase3   MONEY(18,2);
		DEFINE mIvaIntMoraCopete3 MONEY(18,2);
		DEFINE cTmpTable CHAR(5000);
        DEFINE iPid INTEGER;		
		DEFINE iNoRegistros INTEGER;
		DEFINE iNoRegistrosC INTEGER;
		DEFINE iTotalRegistros INTEGER;
		DEFINE iRegistrosRec INTEGER;
		DEFINE iRecuperacion INTEGER;
		DEFINE iIdxSecReg INTEGER;
		DEFINE cNumCte CHAR(20);
		DEFINE cProducto CHAR(45);
		DEFINE cEstatusCuenta CHAR(20);
		DEFINE cFechaUltMov CHAR(10);
		DEFINE cCodigoPago CHAR(5);
		DEFINE cConceptoPago CHAR(50);
		DEFINE cResultado CHAR(15);
		DEFINE cCodretProceso CHAR(6);
		DEFINE cMotivoRechazo CHAR(100);
		DEFINE cFechaAplicacion CHAR(10);
		DEFINE cFechaOperacion CHAR(10);
		DEFINE cComentario CHAR(255);
		
		---Inicializacion de variables
        LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET iExiste = 0;
        LET cCmd1 = '';
        LET cCmd2 = '';
        LET cCmd3 = '';
        LET cCmd4 = '';
        LET cUser = pIdUsuario;
		---Inicializacion de variables para capitales
		LET cReg              = '000';
		LET cSecuencia        = '';
		LET cConcepto         = '';
		LET cNumCredito       = '';
		LET cNombreCte        = '';
		LET m_ImportePago     = 0.0;
		LET mCapVigente       = 0.0;
		LET mCapTransitorio   = 0.0;
		LET mCapVencido       = 0.0;
		LET mCapVdoNoExigible = 0.0;
		LET mCapitalTotal     = 0.0;
		LET mIntVigente       = 0.0;
		LET mIvaIntVigente    = 0.0;
		LET mInteresVencido   = 0.0;
		LET mIvaIntVencido    = 0.0;
		LET mIntMoraCopete    = 0.0;
		LET mIvaIntMoratorio  = 0.0;
		LET dt_FechaMov       = '';
		LET cCodigo           = '';
		LET cDescripcionpag   = '';
		LET cFolioGrupo       = '';
		LET cFolio            = '';
		LET cUsuario          = '';
		LET cSucursal         = '';
		LET cDescRev          = '';
		LET cCodProducto      = '';
		LET c_DescriPago      = '';
		LET cTransaccion      = '';
		LET mIntMoratorio     = 0.0;
		LET mIntMoraBase      = 0.0; 
		LET mIvaIntMoraBase   = 0.0;
		LET mIvaIntMoraCopete = 0.0;
		LET iLote			  = 0;
		LET cReg1              = '000';
		LET cSecuencia1        = '';
		LET cConcepto1         = '';
		LET cNumCredito1       = '';
		LET cNombreCte1        = '';
		LET mImportePago1     = 0.0;
		LET mCapVigente1       = 0.0;
		LET mCapTransitorio1   = 0.0;
		LET mCapVencido1       = 0.0;
		LET mCapVdoNoExigible1 = 0.0;
		LET mCapitalTotal1     = 0.0;
		LET mIntVigente1       = 0.0;
		LET mIvaIntVigente1    = 0.0;
		LET mInteresVencido1   = 0.0;
		LET mIvaIntVencido1    = 0.0;
		LET mIntMoraCopete1    = 0.0;
		LET mIvaIntMoratorio1  = 0.0;
		LET dt_FechaMov1       = '';
		LET cCodigo1           = '';
		LET cDescripcionpag1   = '';
		LET cFolioGrupo1       = '';
		LET cFolio1            = '';
		LET cUsuario1          = '';
		LET cSucursal1         = '';
		LET cDescRev1          = '';
		LET cCodProducto1      = '';
		LET c_DescriPago1      = '';
		LET cTransaccion1      = '';
		LET mIntMoratorio1     = 0.0;
		LET mIntMoraBase1      = 0.0; 
		LET mIvaIntMoraBase1   = 0.0;
		LET mIvaIntMoraCopete1 = 0.0;
		LET cReg2              = '000';
		LET cSecuencia2        = '';
		LET cConcepto2         = '';
		LET cNumCredito2       = '';
		LET cNombreCte2        = '';
		LET mImportePago2     = 0.0;
		LET mCapVigente2       = 0.0;
		LET mCapTransitorio2   = 0.0;
		LET mCapVencido2       = 0.0;
		LET mCapVdoNoExigible2 = 0.0;
		LET mCapitalTotal2     = 0.0;
		LET mIntVigente2       = 0.0;
		LET mIvaIntVigente2    = 0.0;
		LET mInteresVencido2   = 0.0;
		LET mIvaIntVencido2    = 0.0;
		LET mIntMoraCopete2    = 0.0;
		LET mIvaIntMoratorio2  = 0.0;
		LET dt_FechaMov2       = '';
		LET cCodigo2           = '';
		LET cDescripcionpag2   = '';
		LET cFolioGrupo2       = '';
		LET cFolio2            = '';
		LET cUsuario2          = '';
		LET cSucursal2         = '';
		LET cDescRev2          = '';
		LET cCodProducto2      = '';
		LET c_DescriPago2      = '';
		LET cTransaccion2      = '';
		LET mIntMoratorio2     = 0.0;
		LET mIntMoraBase2      = 0.0; 
		LET mIvaIntMoraBase2   = 0.0;
		LET mIvaIntMoraCopete2 = 0.0;
		LET cReg3              = '000';
		LET cSecuencia3        = '';
		LET cConcepto3         = '';
		LET cNumCredito3       = '';
		LET cNombreCte3        = '';
		LET mImportePago3     = 0.0;
		LET mCapVigente3       = 0.0;
		LET mCapTransitorio3   = 0.0;
		LET mCapVencido3       = 0.0;
		LET mCapVdoNoExigible3 = 0.0;
		LET mCapitalTotal3     = 0.0;
		LET mIntVigente3       = 0.0;
		LET mIvaIntVigente3    = 0.0;
		LET mInteresVencido3   = 0.0;
		LET mIvaIntVencido3    = 0.0;
		LET mIntMoraCopete3    = 0.0;
		LET mIvaIntMoratorio3  = 0.0;
		LET dt_FechaMov3       = '';
		LET cCodigo3           = '';
		LET cDescripcionpag3   = '';
		LET cFolioGrupo3       = '';
		LET cFolio3            = '';
		LET cUsuario3          = '';
		LET cSucursal3         = '';
		LET cDescRev3          = '';
		LET cCodProducto3      = '';
		LET c_DescriPago3      = '';
		LET cTransaccion3      = '';
		LET mIntMoratorio3     = 0.0;
		LET mIntMoraBase3      = 0.0; 
		LET mIvaIntMoraBase3   = 0.0;
		LET mIvaIntMoraCopete3 = 0.0;
		LET cTmpTable = '';
        LET iPid = DBINFO('sessionid');
		LET iNoRegistros = 0;
		LET iNoRegistrosC = 0;
		LET iTotalRegistros = 0;
		LET iRegistrosRec = 0;
		LET iRecuperacion = 14;
		LET iIdxSecReg = 0;
		LET cNumCte = '';
		LET cProducto = '';
		LET cEstatusCuenta  = '';
		LET cFechaUltMov  = '';
		LET cCodigoPago  = '';
		LET cConceptoPago  = '';
		LET cResultado  = '';
		LET cCodretProceso  = '';
		LET cMotivoRechazo  = '';
		LET cFechaAplicacion  = '';
		LET cFechaOperacion  = '';
		LET cComentario  = '';
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_reportepagosreversoctasmasivocre.out';
			--TRACE ON;
			
			IF pIdUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchDescarga = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet;
			END IF;
			
			---Creacion de tabla temporal
			LET cTmpTable = "CREATE TEMP TABLE tmpcapitalescta_"||iPid||"(";
			LET cTmpTable = ""||TRIM(cTmpTable)||" idx SERIAL PRIMARY KEY,";
			LET cTmpTable = ""||TRIM(cTmpTable)||" cNumCredito CHAR(20),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" cFolioGrupo CHAR(20),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" cReg CHAR(3),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mImportePagoCondona MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVigSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVigImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVigSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapTransiSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapTransiImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapTransiSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVenSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVenImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVenSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVenNoExiSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVenNoExiImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mCapVenNoExiSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mTotCapSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mTotCapImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mTotCapSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntVigSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntVigImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntVigSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntVigSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntVigImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntVigSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntVencSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntVencImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntVencSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntVencSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntVencImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntVencSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntMoraBaseSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntMoraBaseImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntMoraBaseSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntMoraCopeteSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntMoraCopeteImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIntMoraCopeteSdoNuevo MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntMoraSdoAnterior MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntMoraImpAplicado MONEY (18,2),";
			LET cTmpTable = ""||TRIM(cTmpTable)||" mIvaIntMoraSdoNuevo MONEY(18,2))WITH NO LOG;";
			EXECUTE IMMEDIATE cTmpTable;
			
			WHILE 1=1	
				---Consulta detalles de capitales de pagos
				SET ISOLATION TO DIRTY READ;
				FOREACH	EXECUTE PROCEDURE bdicnweb:"informix".sp_consultareportepagoscre (pIdUsuario, pIdFuncionPadre, pFechaInicio, pFechaFin, 'S','','2','2','',iRegistrosRec,iRecuperacion)
					INTO cCodRetSp, cReg, cSecuencia,cConcepto,cNumCredito, cNombreCte, m_ImportePago, mCapVigente, mCapTransitorio, mCapVencido, mCapVdoNoExigible, mCapitalTotal,
							mIntVigente, mIvaIntVigente, mInteresVencido, mIvaIntVencido, mIntMoraBase, mIntMoraCopete, mIvaIntMoratorio, dt_FechaMov, cCodigo, cDescripcionpag, 
							cFolioGrupo, cFolio, cUsuario, cSucursal, cDescRev, cCodProducto, c_DescriPago, cTransaccion, mIntMoratorio, mIvaIntMoraBase,mIvaIntMoraCopete
					
					LET iNoRegistros = iNoRegistros + DBINFO('sqlca.sqlerrd2');
					
					LET iIdxSecReg = iIdxSecReg + 1;
					
					LET cCodRetSp = cCodRetSp::INTEGER;
					
					IF cCodRetSp = 0 THEN
						IF iIdxSecReg <=3 THEN	
							IF cSecuencia::INTEGER = 1 THEN
								LET cReg1 = cReg;
								LET mCapVigente1 = mCapVigente;
								LET mCapTransitorio1 = mCapTransitorio;
								LET mCapVencido1 = mCapVencido;
								LET mCapVdoNoExigible1 = mCapVdoNoExigible;
								LET mCapitalTotal1 = mCapitalTotal;
								LET mIntVigente1 = mIntVigente;
								LET mIvaIntVigente1 = mIvaIntVigente;
								LET mInteresVencido1 = mInteresVencido;
								LET mIvaIntVencido1 = mIvaIntVencido;
								LET mIntMoraBase1 = mIntMoraBase; 
								LET mIntMoraCopete1 = mIntMoraCopete;
								LET mIvaIntMoratorio1 = mIvaIntMoratorio;
							END IF;
							IF cSecuencia::INTEGER = 2 THEN
								LET cNumCredito2 = cNumCredito;
								LET cFolioGrupo2 = cFolioGrupo;
								LET mImportePago2 = m_ImportePago;
								LET mCapVigente2 = mCapVigente;
								LET mCapTransitorio2 = mCapTransitorio;
								LET mCapVencido2 = mCapVencido;
								LET mCapVdoNoExigible2 = mCapVdoNoExigible;
								LET mCapitalTotal2 = mCapitalTotal;
								LET mIntVigente2 = mIntVigente;
								LET mIvaIntVigente2 = mIvaIntVigente;
								LET mInteresVencido2 = mInteresVencido;
								LET mIvaIntVencido2 = mIvaIntVencido;
								LET mIntMoraBase2 = mIntMoraBase; 
								LET mIntMoraCopete2 = mIntMoraCopete;
								LET mIvaIntMoratorio2 = mIvaIntMoratorio;
							END IF;
							IF cSecuencia::INTEGER = 3 THEN
								LET mCapVigente3 = mCapVigente;
								LET mCapTransitorio3 = mCapTransitorio;
								LET mCapVencido3 = mCapVencido;
								LET mCapVdoNoExigible3 = mCapVdoNoExigible;
								LET mCapitalTotal3 = mCapitalTotal;
								LET mIntVigente3 = mIntVigente;
								LET mIvaIntVigente3 = mIvaIntVigente;
								LET mInteresVencido3 = mInteresVencido;
								LET mIvaIntVencido3 = mIvaIntVencido;
								LET mIntMoraBase3 = mIntMoraBase; 
								LET mIntMoraCopete3 = mIntMoraCopete;
								LET mIvaIntMoratorio3 = mIvaIntMoratorio;
							END IF;
						END IF;
						
						IF iIdxSecReg = 3  THEN 
							---Inserta a tabla temporal
							LET cTmpTable = "INSERT INTO tmpcapitalescta_"||iPid||" VALUES(";
							LET cTmpTable = ""||TRIM(cTmpTable)||" 0,";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||TRIM(cNumCredito2)||"',"; 
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||TRIM(cFolioGrupo2)||"',"; 
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||TRIM(cReg1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mImportePago2,NULL,0,mImportePago2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVigente1,NULL,0,mCapVigente1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVigente2,NULL,0,mCapVigente2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVigente3,NULL,0,mCapVigente3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapTransitorio1,NULL,0,mCapTransitorio1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapTransitorio2,NULL,0,mCapTransitorio2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapTransitorio3,NULL,0,mCapTransitorio3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVencido1,NULL,0,mCapVencido1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVencido2,NULL,0,mCapVencido2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVencido3,NULL,0,mCapVencido3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVdoNoExigible1,NULL,0,mCapVdoNoExigible1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVdoNoExigible2,NULL,0,mCapVdoNoExigible2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVdoNoExigible3,NULL,0,mCapVdoNoExigible3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapitalTotal1,NULL,0,mCapitalTotal1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapitalTotal2,NULL,0,mCapitalTotal2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapitalTotal3,NULL,0,mCapitalTotal3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntVigente1,NULL,0,mIntVigente1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntVigente2,NULL,0,mIntVigente2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntVigente3,NULL,0,mIntVigente3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVigente1,NULL,0,mIvaIntVigente1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVigente2,NULL,0,mIvaIntVigente2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVigente3,NULL,0,mIvaIntVigente3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mInteresVencido1,NULL,0,mInteresVencido1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mInteresVencido2,NULL,0,mInteresVencido2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mInteresVencido3,NULL,0,mInteresVencido3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVencido1,NULL,0,mIvaIntVencido1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVencido2,NULL,0,mIvaIntVencido2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVencido3,NULL,0,mIvaIntVencido3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraBase1,NULL,0,mIntMoraBase1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraBase2,NULL,0,mIntMoraBase2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraBase3,NULL,0,mIntMoraBase3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraCopete1,NULL,0,mIntMoraCopete1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraCopete2,NULL,0,mIntMoraCopete2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraCopete3,NULL,0,mIntMoraCopete3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntMoratorio1,NULL,0,mIvaIntMoratorio1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntMoratorio2,NULL,0,mIvaIntMoratorio2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntMoratorio3,NULL,0,mIvaIntMoratorio3)||"');";
							EXECUTE IMMEDIATE TRIM(cTmpTable);
							
							LET iLote = 0;							
							LET iIdxSecReg = 0;
							LET cReg1 = '000';
							LET mCapVigente1 = 0.0;
							LET mCapTransitorio1 = 0.0;
							LET mCapVencido1 = 0.0;
							LET mCapVdoNoExigible1 = 0.0;
							LET mCapitalTotal1 = 0.0;
							LET mIntVigente1 = 0.0;
							LET mIvaIntVigente1 = 0.0;
							LET mInteresVencido1 = 0.0;
							LET mIvaIntVencido1 = 0.0;
							LET mIntMoraBase1 = 0.0;
							LET mIntMoraCopete1 = 0.0;
							LET mIvaIntMoratorio1 = 0.0;							
							LET cNumCredito2 = ''; 
							LET cFolioGrupo2 = ''; 
							LET mImportePago2 = 0.0;
							LET mCapVigente2 = 0.0;
							LET mCapTransitorio2 = 0.0;
							LET mCapVencido2 = 0.0;
							LET mCapVdoNoExigible2 = 0.0;
							LET mCapitalTotal2 = 0.0;
							LET mIntVigente2 = 0.0;
							LET mIvaIntVigente2 = 0.0;
							LET mInteresVencido2 = 0.0;
							LET mIvaIntVencido2 = 0.0;
							LET mIntMoraBase2 = 0.0;
							LET mIntMoraCopete2 = 0.0;
							LET mIvaIntMoratorio2 = 0.0;							
							LET mCapVigente3 = 0.0;
							LET mCapTransitorio3 = 0.0;
							LET mCapVencido3 = 0.0;
							LET mCapVdoNoExigible3 = 0.0;
							LET mCapitalTotal3 = 0.0;
							LET mIntVigente3 = 0.0;
							LET mIvaIntVigente3 = 0.0;
							LET mInteresVencido3 = 0.0;
							LET mIvaIntVencido3 = 0.0;
							LET mIntMoraBase3 = 0.0;
							LET mIntMoraCopete3 = 0.0;
							LET mIvaIntMoratorio3 = 0.0;
						END IF;	
						
					ELSE
						 EXIT WHILE;
					END IF;
            
				END FOREACH;
				
				IF iNoRegistros = 0 THEN
                   EXIT WHILE;
                END IF;

				LET iRegistrosRec = iNoRegistros;
				
			END WHILE;
			--- Reinicio de variables
			LET iRegistrosRec = 0;
			LET iRecuperacion = 14;			
			LET iLote = 0;			
			LET iIdxSecReg = 0;
			LET cReg1 = '000';
			LET mImportePago2 = 0.0;
			LET mCapVigente1 = 0.0;
			LET mCapTransitorio1 = 0.0;
			LET mCapVencido1 = 0.0;
			LET mCapVdoNoExigible1 = 0.0;
			LET mCapitalTotal1 = 0.0;
			LET mIntVigente1 = 0.0;
			LET mIvaIntVigente1 = 0.0;
			LET mInteresVencido1 = 0.0;
			LET mIvaIntVencido1 = 0.0;
			LET mIntMoraBase1 = 0.0;
			LET mIntMoraCopete1 = 0.0;
			LET mIvaIntMoratorio1 = 0.0;			
			LET cNumCredito2 = ''; 
			LET cFolioGrupo2 = '';
			LET mCapVigente2 = 0.0;
			LET mCapTransitorio2 = 0.0;
			LET mCapVencido2 = 0.0;
			LET mCapVdoNoExigible2 = 0.0;
			LET mCapitalTotal2 = 0.0;
			LET mIntVigente2 = 0.0;
			LET mIvaIntVigente2 = 0.0;
			LET mInteresVencido2 = 0.0;
			LET mIvaIntVencido2 = 0.0;
			LET mIntMoraBase2 = 0.0;
			LET mIntMoraCopete2 = 0.0;
			LET mIvaIntMoratorio2 = 0.0;			
			LET mCapVigente3 = 0.0;
			LET mCapTransitorio3 = 0.0;
			LET mCapVencido3 = 0.0;
			LET mCapVdoNoExigible3 = 0.0;
			LET mCapitalTotal3 = 0.0;
			LET mIntVigente3 = 0.0;
			LET mIvaIntVigente3 = 0.0;
			LET mInteresVencido3 = 0.0;
			LET mIvaIntVencido3 = 0.0;
			LET mIntMoraBase3 = 0.0;
			LET mIntMoraCopete3 = 0.0;
			LET mIvaIntMoratorio3 = 0.0;
			
			WHILE 1=1	
				---Consulta detalles de capitales de condonacion
				SET ISOLATION TO DIRTY READ;
				FOREACH	EXECUTE PROCEDURE bdicnweb:"informix".sp_consultareportepagoscre (pIdUsuario, pIdFuncionPadre, pFechaInicio, pFechaFin, 'S','','2','4','',iRegistrosRec,iRecuperacion)
					INTO cCodRetSp, cReg, cSecuencia,cConcepto,cNumCredito, cNombreCte, m_ImportePago, mCapVigente, mCapTransitorio, mCapVencido, mCapVdoNoExigible, mCapitalTotal,
							mIntVigente, mIvaIntVigente, mInteresVencido, mIvaIntVencido, mIntMoraBase, mIntMoraCopete, mIvaIntMoratorio, dt_FechaMov, cCodigo, cDescripcionpag, 
							cFolioGrupo, cFolio, cUsuario, cSucursal, cDescRev, cCodProducto, c_DescriPago, cTransaccion, mIntMoratorio, mIvaIntMoraBase,mIvaIntMoraCopete
					
					LET iNoRegistrosC = iNoRegistrosC + DBINFO('sqlca.sqlerrd2');
					
					LET iIdxSecReg = iIdxSecReg + 1;
					
					LET cCodRetSp = cCodRetSp::INTEGER;
					
					IF cCodRetSp = 0 THEN
						IF iIdxSecReg <=3 THEN	
							IF cSecuencia::INTEGER = 1 THEN
								LET cReg1 = cReg;
								LET mCapVigente1 = mCapVigente;
								LET mCapTransitorio1 = mCapTransitorio;
								LET mCapVencido1 = mCapVencido;
								LET mCapVdoNoExigible1 = mCapVdoNoExigible;
								LET mCapitalTotal1 = mCapitalTotal;
								LET mIntVigente1 = mIntVigente;
								LET mIvaIntVigente1 = mIvaIntVigente;
								LET mInteresVencido1 = mInteresVencido;
								LET mIvaIntVencido1 = mIvaIntVencido;
								LET mIntMoraBase1 = mIntMoraBase; 
								LET mIntMoraCopete1 = mIntMoraCopete;
								LET mIvaIntMoratorio1 = mIvaIntMoratorio;
							END IF;
							IF cSecuencia::INTEGER = 2 THEN
								LET cNumCredito2 = cNumCredito; 
								LET cFolioGrupo2 = cFolioGrupo;
								LET mImportePago2 = m_ImportePago;
								LET mCapVigente2 = mCapVigente;
								LET mCapTransitorio2 = mCapTransitorio;
								LET mCapVencido2 = mCapVencido;
								LET mCapVdoNoExigible2 = mCapVdoNoExigible;
								LET mCapitalTotal2 = mCapitalTotal;
								LET mIntVigente2 = mIntVigente;
								LET mIvaIntVigente2 = mIvaIntVigente;
								LET mInteresVencido2 = mInteresVencido;
								LET mIvaIntVencido2 = mIvaIntVencido;
								LET mIntMoraBase2 = mIntMoraBase; 
								LET mIntMoraCopete2 = mIntMoraCopete;
								LET mIvaIntMoratorio2 = mIvaIntMoratorio;
							END IF;
							IF cSecuencia::INTEGER = 3 THEN
								LET mCapVigente3 = mCapVigente;
								LET mCapTransitorio3 = mCapTransitorio;
								LET mCapVencido3 = mCapVencido;
								LET mCapVdoNoExigible3 = mCapVdoNoExigible;
								LET mCapitalTotal3 = mCapitalTotal;
								LET mIntVigente3 = mIntVigente;
								LET mIvaIntVigente3 = mIvaIntVigente;
								LET mInteresVencido3 = mInteresVencido;
								LET mIvaIntVencido3 = mIvaIntVencido;
								LET mIntMoraBase3 = mIntMoraBase; 
								LET mIntMoraCopete3 = mIntMoraCopete;
								LET mIvaIntMoratorio3 = mIvaIntMoratorio;
							END IF;
						END IF;
						
						IF iIdxSecReg = 3  THEN 
							---Inserta a tabla temporal
							LET cTmpTable = "INSERT INTO tmpcapitalescta_"||iPid||" VALUES(";
							LET cTmpTable = ""||TRIM(cTmpTable)||" 0,";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||TRIM(cNumCredito2)||"',"; 
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||TRIM(cFolioGrupo2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||TRIM(cReg1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mImportePago2,NULL,0,mImportePago2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVigente1,NULL,0,mCapVigente1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVigente2,NULL,0,mCapVigente2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVigente3,NULL,0,mCapVigente3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapTransitorio1,NULL,0,mCapTransitorio1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapTransitorio2,NULL,0,mCapTransitorio2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapTransitorio3,NULL,0,mCapTransitorio3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVencido1,NULL,0,mCapVencido1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVencido2,NULL,0,mCapVencido2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVencido3,NULL,0,mCapVencido3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVdoNoExigible1,NULL,0,mCapVdoNoExigible1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVdoNoExigible2,NULL,0,mCapVdoNoExigible2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapVdoNoExigible3,NULL,0,mCapVdoNoExigible3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapitalTotal1,NULL,0,mCapitalTotal1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapitalTotal2,NULL,0,mCapitalTotal2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mCapitalTotal3,NULL,0,mCapitalTotal3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntVigente1,NULL,0,mIntVigente1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntVigente2,NULL,0,mIntVigente2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntVigente3,NULL,0,mIntVigente3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVigente1,NULL,0,mIvaIntVigente1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVigente2,NULL,0,mIvaIntVigente2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVigente3,NULL,0,mIvaIntVigente3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mInteresVencido1,NULL,0,mInteresVencido1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mInteresVencido2,NULL,0,mInteresVencido2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mInteresVencido3,NULL,0,mInteresVencido3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVencido1,NULL,0,mIvaIntVencido1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVencido2,NULL,0,mIvaIntVencido2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntVencido3,NULL,0,mIvaIntVencido3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraBase1,NULL,0,mIntMoraBase1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraBase2,NULL,0,mIntMoraBase2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraBase3,NULL,0,mIntMoraBase3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraCopete1,NULL,0,mIntMoraCopete1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraCopete2,NULL,0,mIntMoraCopete2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIntMoraCopete3,NULL,0,mIntMoraCopete3)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntMoratorio1,NULL,0,mIvaIntMoratorio1)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntMoratorio2,NULL,0,mIvaIntMoratorio2)||"',";
							LET cTmpTable = ""||TRIM(cTmpTable)||" '"||DECODE(mIvaIntMoratorio3,NULL,0,mIvaIntMoratorio3)||"');";
							EXECUTE IMMEDIATE TRIM(cTmpTable);
							
							---Reinicio de variables
							LET iLote = 0;
							LET iIdxSecReg = 0;
							LET cReg1 = '000';
							LET mImportePago2 = 0.0;
							LET mCapVigente1 = 0.0;
							LET mCapTransitorio1 = 0.0;
							LET mCapVencido1 = 0.0;
							LET mCapVdoNoExigible1 = 0.0;
							LET mCapitalTotal1 = 0.0;
							LET mIntVigente1 = 0.0;
							LET mIvaIntVigente1 = 0.0;
							LET mInteresVencido1 = 0.0;
							LET mIvaIntVencido1 = 0.0;
							LET mIntMoraBase1 = 0.0;
							LET mIntMoraCopete1 = 0.0;
							LET mIvaIntMoratorio1 = 0.0;							
							LET cNumCredito2 = ''; 
							LET cFolioGrupo2 = '';  
							LET mCapVigente2 = 0.0;
							LET mCapTransitorio2 = 0.0;
							LET mCapVencido2 = 0.0;
							LET mCapVdoNoExigible2 = 0.0;
							LET mCapitalTotal2 = 0.0;
							LET mIntVigente2 = 0.0;
							LET mIvaIntVigente2 = 0.0;
							LET mInteresVencido2 = 0.0;
							LET mIvaIntVencido2 = 0.0;
							LET mIntMoraBase2 = 0.0;
							LET mIntMoraCopete2 = 0.0;
							LET mIvaIntMoratorio2 = 0.0;							
							LET mCapVigente3 = 0.0;
							LET mCapTransitorio3 = 0.0;
							LET mCapVencido3 = 0.0;
							LET mCapVdoNoExigible3 = 0.0;
							LET mCapitalTotal3 = 0.0;
							LET mIntVigente3 = 0.0;
							LET mIvaIntVigente3 = 0.0;
							LET mInteresVencido3 = 0.0;
							LET mIvaIntVencido3 = 0.0;
							LET mIntMoraBase3 = 0.0;
							LET mIntMoraCopete3 = 0.0;
							LET mIvaIntMoratorio3 = 0.0;
						END IF;	
						
					ELSE
						 EXIT WHILE;
					END IF;
			   
				END FOREACH;
				
				IF iNoRegistrosC = 0 THEN
					  EXIT WHILE;
				   END IF;
				   
				LET iRegistrosRec = iNoRegistrosC;
				
		END WHILE;
			
		LET iTotalRegistros = iNoRegistros + iNoRegistrosC;
			
		--Construye filtros de la consulta
		IF pLote IS NOT NULL AND pUsuarioC = '' THEN
			LET cCmd2 = " AND tmp1.lote = "||pLote||"";
		END IF;
		IF pUsuarioC <> '' AND pLote IS NULL THEN
			LET cCmd2 = "AND tmp1.usuario = '"||pUsuarioC||"'";
		END IF;
		IF pLote IS NOT NULL AND pUsuarioC <> '' THEN
			LET cCmd2 = "AND tmp1.lote = "||pLote||" AND tmp1.usuario = '"||pUsuarioC||"'";
		END IF;
			
		---Revisa si existen datos
		LET cCmd1 = "SELECT COUNT (*)";
		LET cCmd1=""||TRIM(cCmd1)||" FROM (";
		LET cCmd1=""||TRIM(cCmd1)||"       SELECT a.id_registro, a.lote, b.folio_grupo, a.numcte, nvl(trim(trim(trim(c.nombre1)||' '||trim(nombre2))||' '||trim(trim(apell_paterno)||' '||trim(apell_materno))),'') as nombre, a.cuenta, nvl(trim(trim(e.sucursal)||' '||trim(nombre)), '') as sucursal, nvl(trim(trim(f.num_producto)||' '||trim(f.nombre_prod)), '') as producto, nvl(trim(g.descripcion), '') as status, nvl((select fecha_pago from bdicred:sd_bitacora_pagos aa where aa.num_credito = a.cuenta and aa.fecha_pago = (select max(bb.fecha_pago) from bdicred:sd_bitacora_pagos bb where bb.num_credito = aa.num_credito and bb.reverso = 'N') and aa.hora_pago = (select max(cc.hora_pago) from bdicred:sd_bitacora_pagos cc where cc.num_credito = aa.num_credito and fecha_pago = (select max(bb.fecha_pago) from bdicred:sd_bitacora_pagos bb where bb.num_credito = aa.num_credito and bb.reverso = 'N'))), '') as fecha_ult_mov, nvl(to_char(a.monto_importe, '#,###,###,###,##&.&&'), '') as monto_transaccion, trim(a.transaccion) as codigo_pago, trim(a.descripcion1) as concepto_pago, trim(a.resultado_reverso) as resultado, trim(a.codret_reverso) as codret, trim(a.comentario_reverso) as motivo_rechazo, trim(a.folio) as folio_operacion, nvl(to_char(date(a.fecha_reverso), '%d/%m/%Y'), '') as fecha_reverso, nvl(to_char(date(a.fecha_proceso), '%d/%m/%Y'), '') as fecha_operacion, nvl(to_char(h.saldo_ante_rev, '#,###,###,###,##&.&&'), '') saldo_ante_reverso, nvl(to_char(h.saldo_post_rev, '#,###,###,###,##&.&&'), '') saldo_post_reverso, trim(a.descripcion2) as comentario, a.usuario";
		LET cCmd1=""||TRIM(cCmd1)||"       FROM ((((((bdicnweb:sw_tr_cargamasiva_pago_hist a LEFT JOIN bdicnweb:sw_tr_totales_masivo b ON b.id_lote = a.lote and b.id_funcion = a.id_funcion)";
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdinteg:si_cliente c ON c.numcte = a.numcte)";
		LET cCmd1=""||TRIM(cCmd1)||"	   LEFT JOIN bdicred:sd_maecred d ON d.num_credito = a.cuenta)";
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdinteg:si_sucursales e ON e.sucursal = d.sucursal)"; 
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdicred:sd_definicion f ON f.num_producto = d.num_producto)";
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdicred:sd_tipocartera g ON g.status_cred = d.status_cred)";
		LET cCmd1=""||TRIM(cCmd1)||"	   LEFT JOIN bdicred:sd_bitacora_pagos h ON h.folio = a.folio AND h.reverso = 'S' ";
		LET cCmd1=""||TRIM(cCmd1)||"	   WHERE a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and DATE(a.fecha_carga) BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		LET cCmd1=""||TRIM(cCmd1)||" ) ";
		LET cCmd1=""||TRIM(cCmd1)||" AS tmp1 LEFT JOIN tmpcapitalescta_"||iPid||" AS tmp2 ON tmp1.cuenta = tmp2.cNumCredito AND tmp1.folio_grupo = tmp2.cFolioGrupo ";
		LET cCmd1=""||TRIM(cCmd1)||" WHERE (DATE(TO_DATE(tmp1.fecha_operacion, '%d/%m/%Y')) BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"') "||TRIM(cCmd2)||";";
		
		PREPARE lotesQry FROM TRIM(cCmd1);
		DECLARE lotesCur CURSOR FOR lotesQry;
		OPEN lotesCur;
		
		FETCH lotesCur INTO iExiste;
		
		CLOSE lotesCur;
		FREE lotesCur;
		FREE lotesQry;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00151';
			---Se elimina tabla temporal
			LET cTmpTable = "DROP TABLE tmpcapitalescta_"||iPid;
            EXECUTE IMMEDIATE cTmpTable;
			RETURN cCodRet;
		END IF;
		
		---Se realiza consulta con el complemento de los saldos
		LET cCmd1 = "SELECT ";
		LET cCmd1=""||TRIM(cCmd1)||" tmp1.lote, tmp1.folio_grupo, tmp1.numcte, tmp1.nombre, tmp1.cuenta , tmp2.cReg ,tmp2.mImportePagoCondona,tmp2.mCapVigSdoAnterior,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp2.mCapVigImpAplicado,tmp2.mCapVigSdoNuevo,tmp2.mCapTransiSdoAnterior,tmp2.mCapTransiImpAplicado,tmp2.mCapTransiSdoNuevo,tmp2.mCapVenSdoAnterior,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp2.mCapVenImpAplicado,tmp2.mCapVenSdoNuevo,tmp2.mCapVenNoExiSdoAnterior,tmp2.mCapVenNoExiImpAplicado,tmp2.mCapVenNoExiSdoNuevo,tmp2.mTotCapSdoAnterior,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp2.mTotCapImpAplicado,tmp2.mTotCapSdoNuevo,tmp2.mIntVigSdoAnterior,tmp2.mIntVigImpAplicado,tmp2.mIntVigSdoNuevo,tmp2.mIvaIntVigSdoAnterior,tmp2.mIvaIntVigImpAplicado,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp2.mIvaIntVigSdoNuevo,tmp2.mIntVencSdoAnterior,tmp2.mIntVencImpAplicado,tmp2.mIntVencSdoNuevo,tmp2.mIvaIntVencSdoAnterior,tmp2.mIvaIntVencImpAplicado,tmp2.mIvaIntVencSdoNuevo,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp2.mIntMoraBaseSdoAnterior,tmp2.mIntMoraBaseImpAplicado,tmp2.mIntMoraBaseSdoNuevo,tmp2.mIntMoraCopeteSdoAnterior,tmp2.mIntMoraCopeteImpAplicado,tmp2.mIntMoraCopeteSdoNuevo,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp2.mIvaIntMoraSdoAnterior,tmp2.mIvaIntMoraImpAplicado,tmp2.mIvaIntMoraSdoNuevo,tmp1.sucursal,TRIM(tmp1.producto),TRIM(tmp1.status),tmp1.fecha_ult_mov,tmp1.codigo_pago,";
		LET cCmd1=""||TRIM(cCmd1)||" tmp1.concepto_pago,TRIM(tmp1.resultado),tmp1.codret,tmp1.motivo_rechazo,tmp1.folio_operacion,tmp1.fecha_reverso,tmp1.fecha_operacion,TRIM(tmp1.comentario), tmp1.usuario";
		LET cCmd1=""||TRIM(cCmd1)||" FROM (";
		LET cCmd1=""||TRIM(cCmd1)||"       SELECT a.id_registro, a.lote, b.folio_grupo, a.numcte, nvl(trim(trim(trim(c.nombre1)||' '||trim(nombre2))||' '||trim(trim(apell_paterno)||' '||trim(apell_materno))),'') as nombre, a.cuenta, nvl(trim(trim(e.sucursal)||' '||trim(nombre)), '') as sucursal, nvl(trim(trim(f.num_producto)||' '||trim(f.nombre_prod)), '') as producto, nvl(trim(g.descripcion), '') as status, nvl((select fecha_pago from bdicred:sd_bitacora_pagos aa where aa.num_credito = a.cuenta and aa.fecha_pago = (select max(bb.fecha_pago) from bdicred:sd_bitacora_pagos bb where bb.num_credito = aa.num_credito and bb.reverso = 'N') and aa.hora_pago = (select max(cc.hora_pago) from bdicred:sd_bitacora_pagos cc where cc.num_credito = aa.num_credito and fecha_pago = (select max(bb.fecha_pago) from bdicred:sd_bitacora_pagos bb where bb.num_credito = aa.num_credito and bb.reverso = 'N'))), '') as fecha_ult_mov, nvl(to_char(a.monto_importe, '#,###,###,###,##&.&&'), '') as monto_transaccion, trim(a.transaccion) as codigo_pago, trim(a.descripcion1) as concepto_pago, trim(a.resultado_reverso) as resultado, trim(a.codret_reverso) as codret, trim(a.comentario_reverso) as motivo_rechazo, trim(a.folio) as folio_operacion, nvl(to_char(date(a.fecha_reverso), '%d/%m/%Y'), '') as fecha_reverso, nvl(to_char(date(a.fecha_proceso), '%d/%m/%Y'), '') as fecha_operacion, nvl(to_char(h.saldo_ante_rev, '#,###,###,###,##&.&&'), '') saldo_ante_reverso, nvl(to_char(h.saldo_post_rev, '#,###,###,###,##&.&&'), '') saldo_post_reverso, trim(a.descripcion2) as comentario, a.usuario";
		LET cCmd1=""||TRIM(cCmd1)||"       FROM ((((((bdicnweb:sw_tr_cargamasiva_pago_hist a LEFT JOIN bdicnweb:sw_tr_totales_masivo b ON b.id_lote = a.lote and b.id_funcion = a.id_funcion)";
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdinteg:si_cliente c ON c.numcte = a.numcte)";
		LET cCmd1=""||TRIM(cCmd1)||"	   LEFT JOIN bdicred:sd_maecred d ON d.num_credito = a.cuenta)";
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdinteg:si_sucursales e ON e.sucursal = d.sucursal)"; 
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdicred:sd_definicion f ON f.num_producto = d.num_producto)";
		LET cCmd1=""||TRIM(cCmd1)||"       LEFT JOIN bdicred:sd_tipocartera g ON g.status_cred = d.status_cred)";
		LET cCmd1=""||TRIM(cCmd1)||"	   LEFT JOIN bdicred:sd_bitacora_pagos h ON h.folio = a.folio AND h.reverso = 'S' ";
		LET cCmd1=""||TRIM(cCmd1)||"	   WHERE a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and DATE(a.fecha_carga) BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"' ORDER BY a.id_registro";
		LET cCmd1=""||TRIM(cCmd1)||" ) ";
		LET cCmd1=""||TRIM(cCmd1)||" AS tmp1 LEFT JOIN tmpcapitalescta_"||iPid||" AS tmp2 ON tmp1.cuenta = tmp2.cNumCredito AND tmp1.folio_grupo = tmp2.cFolioGrupo ";
		LET cCmd1=""||TRIM(cCmd1)||" WHERE (DATE(TO_DATE(tmp1.fecha_operacion, '%d/%m/%Y')) BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"') "||TRIM(cCmd2)||";";
		
		PREPARE stmtId FROM TRIM(cCmd1);
		DECLARE selectQryCur CURSOR FOR stmtId;
		OPEN selectQryCur;
		
		FETCH selectQryCur INTO iLote, cFolioGrupo, cNumCte, cNombreCte, cNumCredito,cReg,mImportePago2,mCapVigente1,mCapVigente2,mCapVigente3,mCapTransitorio1,mCapTransitorio2,
								mCapTransitorio3,mCapVencido1,mCapVencido2,mCapVencido3,mCapVdoNoExigible1,mCapVdoNoExigible2,mCapVdoNoExigible3,mCapitalTotal1,mCapitalTotal2,
								mCapitalTotal3,mIntVigente1,mIntVigente2,mIntVigente3,mIvaIntVigente1,mIvaIntVigente2,mIvaIntVigente3,mInteresVencido1,mInteresVencido2,
								mInteresVencido3,mIvaIntVencido1,mIvaIntVencido2,mIvaIntVencido3,mIntMoraBase1,mIntMoraBase2,mIntMoraBase3,mIntMoraCopete1,mIntMoraCopete2,
								mIntMoraCopete3,mIvaIntMoratorio1,mIvaIntMoratorio2,mIvaIntMoratorio3,cSucursal,cProducto,cEstatusCuenta,cFechaUltMov,cCodigoPago,cConceptoPago,
								cResultado,cCodretProceso,cMotivoRechazo,cFolio,cFechaAplicacion,cFechaOperacion,cComentario,cUser;
		WHILE(SQLCODE == 0)	

			INSERT INTO bdicnweb:"informix".sw_tr_registrosreportepago(usuario_consulta, id_tabla_ses, lote, folio_grupo, numcte, nombre_cte, cuenta, creg, mimportepagocondona, mcapvigsdoanterior, 
					mcapvigimpaplicado, mcapvigsdonuevo, mcaptransisdoanterior, mcaptransiimpaplicado, mcaptransisdonuevo, mcapvensdoanterior, mcapvenimpaplicado, mcapvensdonuevo, mcapvennoexisdoanterior,
					mcapvennoexiimpaplicado, mcapvennoexisdonuevo, mtotcapsdoanterior, mtotcapimpaplicado, mtotcapsdonuevo, mintvigsdoanterior, mintvigimpaplicado, mintvigsdonuevo, mivaintvigsdoanterior,
					mivaintvigimpaplicado, mivaintvigsdonuevo, mintvencsdoanterior, mintvencimpaplicado, mintvencsdonuevo, mivaintvencsdoanterior, mivaintvencimpaplicado, mivaintvencsdonuevo,
					mintmorabasesdoanterior, mintmorabaseimpaplicado, mintmorabasesdonuevo, mintmoracopetesdoanterior, mintmoracopeteimpaplicado, mintmoracopetesdonuevo, mivaintmorasdoanterior, 
					mivaintmoraimpaplicado, mivaintmorasdonuevo, sucursal, producto, estatus_cuenta, fecha_ult_mov, codigo_pago, concepto_pago, resultado, codret_proceso, motivo_rechazo, folio,
					fecha_aplicacion, fecha_operacion, comentario, usuario) 
			VALUES(pIdUsuario, TO_CHAR(iPid) ,iLote, cFolioGrupo, cNumCte, cNombreCte, cNumCredito,cReg,mImportePago2,mCapVigente1,mCapVigente2,mCapVigente3,mCapTransitorio1,mCapTransitorio2,
					mCapTransitorio3,mCapVencido1,mCapVencido2,mCapVencido3,mCapVdoNoExigible1,mCapVdoNoExigible2,mCapVdoNoExigible3,mCapitalTotal1,mCapitalTotal2,
					mCapitalTotal3,mIntVigente1,mIntVigente2,mIntVigente3,mIvaIntVigente1,mIvaIntVigente2,mIvaIntVigente3,mInteresVencido1,mInteresVencido2,
					mInteresVencido3,mIvaIntVencido1,mIvaIntVencido2,mIvaIntVencido3,mIntMoraBase1,mIntMoraBase2,mIntMoraBase3,mIntMoraCopete1,mIntMoraCopete2,
					mIntMoraCopete3,mIvaIntMoratorio1,mIvaIntMoratorio2,mIvaIntMoratorio3,cSucursal,cProducto,cEstatusCuenta,cFechaUltMov,cCodigoPago,cConceptoPago,
					cResultado,cCodretProceso,cMotivoRechazo,cFolio,cFechaAplicacion,cFechaOperacion,cComentario,cUser);

			FETCH selectQryCur INTO iLote, cFolioGrupo, cNumCte, cNombreCte, cNumCredito,cReg,mImportePago2,mCapVigente1,mCapVigente2,mCapVigente3,mCapTransitorio1,mCapTransitorio2,
								mCapTransitorio3,mCapVencido1,mCapVencido2,mCapVencido3,mCapVdoNoExigible1,mCapVdoNoExigible2,mCapVdoNoExigible3,mCapitalTotal1,mCapitalTotal2,
								mCapitalTotal3,mIntVigente1,mIntVigente2,mIntVigente3,mIvaIntVigente1,mIvaIntVigente2,mIvaIntVigente3,mInteresVencido1,mInteresVencido2,
								mInteresVencido3,mIvaIntVencido1,mIvaIntVencido2,mIvaIntVencido3,mIntMoraBase1,mIntMoraBase2,mIntMoraBase3,mIntMoraCopete1,mIntMoraCopete2,
								mIntMoraCopete3,mIvaIntMoratorio1,mIvaIntMoratorio2,mIvaIntMoratorio3,cSucursal,cProducto,cEstatusCuenta,cFechaUltMov,cCodigoPago,cConceptoPago,
								cResultado,cCodretProceso,cMotivoRechazo,cFolio,cFechaAplicacion,cFechaOperacion,cComentario,cUser;
									
									
		END WHILE;
		CLOSE selectQryCur;
		FREE selectQryCur;
		FREE stmtId;
		
		LET cCmd4 ="lote,folio_grupo, numcte, nombre_cte, cuenta, cReg, TRIM(NVL(TO_CHAR(mImportePagoCondona, '- #,###,###,###,##&.&&'), '')) as mImportePagoCondona,TRIM(NVL(TO_CHAR(mCapVigSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mCapVigSdoAnterior,TRIM(NVL(TO_CHAR(mCapVigImpAplicado, '- #,###,###,###,##&.&&'), '')) as mCapVigImpAplicado,TRIM(NVL(TO_CHAR(mCapVigSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mCapVigSdoNuevo,TRIM(NVL(TO_CHAR(mCapTransiSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mCapTransiSdoAnterior,TRIM(NVL(TO_CHAR(mCapTransiImpAplicado, '- #,###,###,###,##&.&&'), '')) as mCapTransiImpAplicado,";
		LET cCmd4 =""||TRIM(cCmd4)||"TRIM(NVL(TO_CHAR(mCapTransiSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mCapTransiSdoNuevo,TRIM(NVL(TO_CHAR(mCapVenSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mCapVenSdoAnterior,TRIM(NVL(TO_CHAR(mCapVenImpAplicado, '- #,###,###,###,##&.&&'), '')) as mCapVenImpAplicado,TRIM(NVL(TO_CHAR(mCapVenSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mCapVenSdoNuevo,TRIM(NVL(TO_CHAR(mCapVenNoExiSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mCapVenNoExiSdoAnterior,TRIM(NVL(TO_CHAR(mCapVenNoExiImpAplicado, '- #,###,###,###,##&.&&'), '')) as mCapVenNoExiImpAplicado,TRIM(NVL(TO_CHAR(mCapVenNoExiSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mCapVenNoExiSdoNuevo,TRIM(NVL(TO_CHAR(mTotCapSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mTotCapSdoAnterior,";
		LET cCmd4 =""||TRIM(cCmd4)||"TRIM(NVL(TO_CHAR(mTotCapImpAplicado, '- #,###,###,###,##&.&&'), '')) as mTotCapImpAplicado,TRIM(NVL(TO_CHAR(mTotCapSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mTotCapSdoNuevo,TRIM(NVL(TO_CHAR(mIntVigSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIntVigSdoAnterior,TRIM(NVL(TO_CHAR(mIntVigImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIntVigImpAplicado,TRIM(NVL(TO_CHAR(mIntVigSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIntVigSdoNuevo,TRIM(NVL(TO_CHAR(mIvaIntVigSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIvaIntVigSdoAnterior,TRIM(NVL(TO_CHAR(mIvaIntVigImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIvaIntVigImpAplicado,TRIM(NVL(TO_CHAR(mIvaIntVigSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIvaIntVigSdoNuevo,TRIM(NVL(TO_CHAR(mIntVencSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIntVencSdoAnterior,";
		LET cCmd4 =""||TRIM(cCmd4)||"TRIM(NVL(TO_CHAR(mIntVencImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIntVencImpAplicado,TRIM(NVL(TO_CHAR(mIntVencSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIntVencSdoNuevo,TRIM(NVL(TO_CHAR(mIvaIntVencSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIvaIntVencSdoAnterior,TRIM(NVL(TO_CHAR(mIvaIntVencImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIvaIntVencImpAplicado,TRIM(NVL(TO_CHAR(mIvaIntVencSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIvaIntVencSdoNuevo,TRIM(NVL(TO_CHAR(mIntMoraBaseSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIntMoraBaseSdoAnterior,TRIM(NVL(TO_CHAR(mIntMoraBaseImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIntMoraBaseImpAplicado,TRIM(NVL(TO_CHAR(mIntMoraBaseSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIntMoraBaseSdoNuevo,";
		LET cCmd4 =""||TRIM(cCmd4)||"TRIM(NVL(TO_CHAR(mIntMoraCopeteSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIntMoraCopeteSdoAnterior,TRIM(NVL(TO_CHAR(mIntMoraCopeteImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIntMoraCopeteImpAplicado,TRIM(NVL(TO_CHAR(mIntMoraCopeteSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIntMoraCopeteSdoNuevo,TRIM(NVL(TO_CHAR(mIvaIntMoraSdoAnterior, '- #,###,###,###,##&.&&'), '')) as mIvaIntMoraSdoAnterior,TRIM(NVL(TO_CHAR(mIvaIntMoraImpAplicado, '- #,###,###,###,##&.&&'), '')) as mIvaIntMoraImpAplicado,TRIM(NVL(TO_CHAR(mIvaIntMoraSdoNuevo, '- #,###,###,###,##&.&&'), '')) as mIvaIntMoraSdoNuevo,sucursal,producto,estatus_cuenta,";
		LET cCmd4 =""||TRIM(cCmd4)||"fecha_ult_mov,codigo_pago,concepto_pago,resultado,codret_proceso,motivo_rechazo,folio,fecha_aplicacion,fecha_operacion,comentario,usuario";
		
		SYSTEM TRIM('/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' SELECT '||TRIM(cCmd4)||' FROM bdicnweb:sw_tr_registrosreportepago WHERE usuario_consulta='||pIdUsuario||' AND id_tabla_ses ='||TRIM(TO_CHAR(iPid))||';" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1');
		
		-- EjecuciÃ³n del SP para la carga de los encabezados
		EXECUTE PROCEDURE bdicnweb:"informix".sp_obtieneencabezadomasivo(pIdFuncionPadre, pArchDescarga) INTO cCodRetSp;
		IF cCodRetSp::INTEGER < 0 THEN
				---Se elimina tabla temporal
				LET cTmpTable = "DROP TABLE tmpcapitalescta_"||iPid;
				EXECUTE IMMEDIATE cTmpTable;
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
		END IF;
		
		---Se elimina tabla temporal
		LET cTmpTable = "DROP TABLE tmpcapitalescta_"||iPid;
		EXECUTE IMMEDIATE cTmpTable;

		---Se eliminan los registros consultados
		DELETE bdicnweb:"informix".sw_tr_registrosreportepago 
		WHERE usuario_consulta = pIdUsuario AND id_tabla_ses = TO_CHAR(iPid);
	
		RETURN cCodRet;
		
        END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Generacion del reporte de las cuentas que fueron reversados en el pago masivo de la aplicacion CNWEB",
"FECHA: 15/01/2014",
"DESCRIPCION: Se agrega el procedimiento para agregar los encabezados al archivo final",
"FECHA: 10/09/2014",
"DESCRIPCION:Se agregan datos para visualizar saldos de capitales de pagos y condonaciones",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_consultahistoricotarjetas( psNumCuenta CHAR(12), psNumTarjeta CHAR(16), piTipoBusqueda SMALLINT, psEmpresa CHAR(3) )
	RETURNING
		CHAR(5) AS CodigoRetorno,
		CHAR(1) AS TipoCliente, CHAR(10) AS FechaStatusUltMod, CHAR(10) AS HoraStatusUltMod, CHAR(8) AS EmpleadoModifico, CHAR(100) AS NombreEmpMod,
		CHAR(10) AS FechaStatusAperturaCuenta, CHAR(4) AS SucursalAperturaCuenta, CHAR(8) AS EmpleadoAperturo, CHAR(100) AS NombreEmpAperturo,
		CHAR(10) AS FechaStatusEntrega,	CHAR(10) AS HoraStatusEntrega, CHAR(4) AS SucursalEntrega, CHAR(8) AS EmpleadoEntrega, CHAR(100) AS NombreEmpEntrego,
		CHAR(25) AS StatusTarjetaCancelada, CHAR(10) AS FechaStatusCancelada, CHAR(10) AS HoraStatusCancelada, SMALLINT AS Secuencia, CHAR(8) AS EmpleadoModificoCancelacion, CHAR(100) AS NombreEmpModCancelacion;

	--Declaración de variables.
	DEFINE sCodRet 		CHAR(5);	-- Código de retorno.
	DEFINE sSqlErr		INTEGER;	-- Código de error controlado por INFORMIX.

	--Datos generales de la tarjeta.
	DEFINE sTipo 	        	CHAR(1);	-- Tipo cliente tarjeta.
	DEFINE sFechaStatusUltMod	CHAR(10);	-- Fecha última modificación de la tarjeta.
	DEFINE sHoraStatusUltMod	CHAR(10);	-- Hora  última modificación de la tarjeta.
	DEFINE sEmpleadoModifico	CHAR(8);	-- Empleado que realizó la última modificación de la tarjeta.
	DEFINE sNombreEmpMod  		CHAR(100);	-- Nombre del empleado que realizó la última modificación de la tarjeta.

	--Datos de la apertura de la cuenta.
	DEFINE sFechaStatusAperturaCuenta	CHAR(10); 	-- Fecha de la apertura de la cuenta.
	DEFINE sSucursalAperturaCuenta 		CHAR(4);  	-- Número de la sucursal donde se realizó la apertura.
	DEFINE sEmpleadoAperturo 			CHAR(8);  	-- Empleado que realizó la apertura.
	DEFINE sNombreEmpAperturo 			CHAR(100);	-- Nombre del empleado que realizó la apertura.

	--Datos de la entrega  de la tarjeta.
	DEFINE sFechaStatusEntrega		CHAR(10); 	-- Fecha de entrega de tarjeta.
	DEFINE sHoraStatusEntrega		CHAR(10); 	-- Hora de entrega de tarjeta.
	DEFINE sSucursalEntrega			CHAR(4);	-- Número de la sucursal donde se realizó la entrega,
	DEFINE sEmpleadoEntrega			CHAR(8);	-- Empleado que realizó la entrega de la tarjeta.
	DEFINE sNombreEmpEntrego 		CHAR(100);	-- Nombre del empleado que realizó la entrega de la tarjeta.

	--Datos del histórico de la tarjeta.
	DEFINE sStatusTarjetaCancelada		CHAR(25);	-- Descripción del status de la tarjeta cancelada.
	DEFINE sFechaStatusCancelada 		CHAR(10);	-- Fecha de cancelación de la tarjeta.
	DEFINE sHoraStatusCancelada			CHAR(10);	-- Hora de cancelación de la tarjeta.
	DEFINE iSecuencia 					SMALLINT; 	-- Secuencia de la tarjeta.
	DEFINE sEmpleadoModificoCancelacion CHAR(8);  	-- Empleado que realizó la cancelación.
	DEFINE sNombreEmpModCancelacion		CHAR(100);	-- Nombre del empleado que realizó la cancelación.

	DEFINE sNumTarjeta      CHAR(16);
	DEFINE sNumCuenta		CHAR(12);

	--Asignación de valores a variables.
	LET sCodRet = '00000';
	LET sSqlErr = 0;

	LET sTipo = '';
	LET sFechaStatusUltMod = '';
	LET sHoraStatusUltMod = '';
	LET sEmpleadoModifico = '';
	LET sNombreEmpMod = '';

	LET sFechaStatusEntrega = '';
	LET sHoraStatusEntrega = '';
	LET sSucursalEntrega = '';
	LET sEmpleadoEntrega = '';
	LET sNombreEmpEntrego = '';

	LET sFechaStatusAperturaCuenta = '';
	LET sSucursalAperturaCuenta = '';
	LET sEmpleadoAperturo = '';
	LET sNombreEmpAperturo = '';

	LET sStatusTarjetaCancelada = '';
	LET sFechaStatusCancelada = '';
	LET sHoraStatusCancelada  = '';
	LET iSecuencia = 0;
	LET sEmpleadoModificoCancelacion = '';
	LET sNombreEmpModCancelacion = '';

	LET sNumTarjeta = '';
	LET sNumCuenta = '';

	--SET DEBUG FILE TO "/informix/VH/cnsif/sp_consultahistoricotarjetas.out";
	--TRACE ON;
	BEGIN

		ON EXCEPTION SET sSqlErr

	      IF sSqlErr <> 0 THEN

				LET sCodRet = sSqlErr;

				RETURN
					sCodRet,
					sTipo, sFechaStatusUltMod, sHoraStatusUltMod, sEmpleadoModifico, sNombreEmpMod,
					sFechaStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo, sNombreEmpAperturo,
					sFechaStatusEntrega, sHoraStatusEntrega, sSucursalEntrega, sEmpleadoEntrega, sNombreEmpEntrego,
					sStatusTarjetaCancelada, sFechaStatusCancelada, sHoraStatusCancelada, iSecuencia, sEmpleadoModificoCancelacion, sNombreEmpModCancelacion;

	      END IF;

		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_consultahistoricotarjetas.out";
		--TRACE ON;

		SET ISOLATION DIRTY READ;

		IF ( NVL( psNumTarjeta, '' ) <> '' AND NVL( psNumCuenta, '' ) <> '' AND
			( NVL( piTipoBusqueda, 0 ) > 0 AND NVL( piTipoBusqueda, 0 ) < 3 ) AND
			NVL( psEmpresa, '' ) <> '' ) THEN

			LET psNumTarjeta = TRIM( psNumTarjeta );
			LET psNumCuenta = TRIM( psNumCuenta );

			-- Opción para obtener los datos de una tarjeta de CRÉDITO.
			IF ( piTipoBusqueda = 1 ) THEN

				-- Se obtienen los datos para la sección de "DATOS GENERALES DE LA TARJETA".
				SELECT b.numtarjeta, b.titular, TO_CHAR( b.fechaultmodif, '%Y-%m-%d' ), SUBSTR( b.fechaultmodif, 12, 8 ), NVL( b.usuarioultmodif, '' )
					INTO sNumTarjeta, sTipo, sFechaStatusUltMod, sHoraStatusUltMod, sEmpleadoModifico
				FROM intercard:tarjetacuenta a
					LEFT OUTER JOIN intercard:tarjeta b ON ( a.numtarjeta = b.numtarjeta )
				WHERE a.numcuenta = psNumCuenta AND a.numtarjeta = psNumTarjeta;

				-- Se obtiene nombre de ejecutivo.
				SELECT ejecutivo, UPPER( nombre )
					INTO sEmpleadoModifico, sNombreEmpMod
				FROM bdinteg:si_ejecut
				WHERE ejecutivo = sEmpleadoModifico;

				IF( NVL( sEmpleadoModifico, '' ) = '' ) THEN

					LET sNumTarjeta = '';

				END IF;

				IF ( NVL( sNumTarjeta, '' ) <> '' ) THEN

					-- Se obtienen los datos para de la sección de "DATOS  DE  LA APERTURA  DE   LA  CUENTA".
					SELECT a.num_credito, TO_CHAR( a.fecha_apertura, '%Y-%m-%d' ), a.sucursal, b.ejecutivo_auto
						INTO sNumCuenta, sFechaStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo
					FROM bdicred:sd_maecred a
						LEFT OUTER JOIN bdisolic:ss_autorizacion b ON ( a.num_credito = b.num_solicitud AND a.empresa = b.empresa )
					WHERE b.empresa = psEmpresa AND b.num_solicitud = psNumCuenta
						AND b.status_solicitud = 'AP';

					-- Se obtiene nombre de ejecutivo.
					SELECT ejecutivo, UPPER( nombre )
						INTO sEmpleadoAperturo, sNombreEmpAperturo
					FROM bdinteg:si_ejecut
					WHERE ejecutivo = sEmpleadoAperturo;

					IF( NVL( sEmpleadoAperturo, '' ) = '' ) THEN

						LET sNumCuenta = '';

					END IF;

					IF ( NVL( sNumCuenta, '' ) <> '' ) THEN

						-- Se obtienen los datos para de la sección de "DATOS DE LA ENTREGA DE LA TARJETA".
						SELECT LIMIT 1 TRIM( a.numtarjeta ), SUBSTR( a.idterminal, 1, 4 ), NVL( SUBSTR( a.idterminal, 5, 8 ), '' ), TO_CHAR( a.fechahorainauth, '%Y-%m-%d' ),
								SUBSTR( a.fechahorainauth, 12, 8 )
							INTO sNumTarjeta, sSucursalEntrega, sEmpleadoEntrega, sFechaStatusEntrega, sHoraStatusEntrega
						FROM intercard:movimientohistorico a
						WHERE a.numtarjeta = psNumTarjeta -- Búsqueda por Tarjeta
							AND a.codtran = '95'
							AND a.prodind = '01' AND a.formato = '0200' AND a.codigoiso = '00';

						IF( NVL( sNumTarjeta, '' ) = '' ) THEN -- Si no hubo información en intercard:movimientohistorico, se consulta la intercard:movimiento.

							SELECT LIMIT 1 TRIM( a.numtarjeta ), SUBSTR( a.idterminal, 1, 4 ), NVL( SUBSTR( a.idterminal, 5, 8 ), '' ), TO_CHAR( a.fechahorainauth, '%Y-%m-%d' ),
									SUBSTR( a.fechahorainauth, 12, 8 )
								INTO sNumTarjeta, sSucursalEntrega, sEmpleadoEntrega, sFechaStatusEntrega, sHoraStatusEntrega
							FROM intercard:movimiento a
							WHERE a.numtarjeta = psNumTarjeta -- Búsqueda por Tarjeta
								AND a.codtran = '95'
								AND a.prodind = '01' AND a.formato = '0200' AND a.codigoiso = '00';

						END IF;

						-- Se obtiene la secuencia de la tarjeta.
						SELECT num_tarjeta, secuencia
							INTO sNumTarjeta, iSecuencia
						FROM bdicred:sd_tarjeta
						WHERE num_tarjeta = sNumTarjeta AND empresa = psEmpresa;

						-- Se obtiene nombre de ejecutivo.
						SELECT a.ejecutivo, UPPER( a.nombre )
							INTO sEmpleadoEntrega, sNombreEmpEntrego
						FROM bdinteg:si_ejecut a
						WHERE a.ejecutivo = sEmpleadoEntrega;

						IF( iSecuencia IS NULL OR
							NVL( sEmpleadoEntrega, '' ) = '' ) THEN

							LET sNumTarjeta = '';

						END IF;

						IF ( NVL( sNumTarjeta, '' ) <> '' ) THEN

							-- Se obtienen los datos para de la sección de "HISTÓRICO DE LA TARJETA".
							SELECT a.numtarjeta, UPPER( b.descstatustarjeta ), TO_CHAR( a.fechaultmodif, '%Y-%m-%d' ), SUBSTR( a.fechaultmodif, 12, 8 ), NVL( a.usuarioultmodif, '' )
								INTO sNumTarjeta, sStatusTarjetaCancelada, sFechaStatusCancelada, sHoraStatusCancelada, sEmpleadoModificoCancelacion
							FROM intercard:tarjeta a
								LEFT OUTER JOIN intercard:statustarjeta b ON ( a.codstatustarjeta = b.codstatustarjeta )
							WHERE a.numtarjeta = psNumTarjeta;

							-- Se obtiene el nombre del ejecutivo.
							SELECT ejecutivo, UPPER( nombre )
								INTO sEmpleadoModificoCancelacion, sNombreEmpModCancelacion
							FROM bdinteg:si_ejecut
							WHERE ejecutivo = sEmpleadoModificoCancelacion;

							IF( NVL( sNumTarjeta, '' ) = '' OR NVL( sEmpleadoModificoCancelacion, '' ) = '' ) THEN

								LET sStatusTarjetaCancelada = '';
								LET sFechaStatusCancelada = '';
								LET sHoraStatusCancelada = '';
								LET sEmpleadoModificoCancelacion = '';
								LET sNombreEmpModCancelacion = '';

							END IF;

						ELSE

							LET sCodRet = '00004';

						END IF;
					ELSE

						LET sCodRet = '00003';

					END IF;
				ELSE

					LET sCodRet = '00002';

				END IF;
			ELSE -- Opción para obtener los datos de una tarjeta de DÉBITO.

				-- Se obtienen los datos para de la sección de "DATOS GENERALES DE LA TARJETA".
				SELECT a.numtarjeta, a.titular, TO_CHAR( a.fechaultmodif, '%Y-%m-%d' ), SUBSTR( a.fechaultmodif, 12, 8 ), NVL( a.usuarioultmodif, '' )
					INTO sNumTarjeta, sTipo, sFechaStatusUltMod, sHoraStatusUltMod, sEmpleadoModifico
				FROM intercard:tarjeta a
					LEFT OUTER JOIN intercard:tarjetacuenta b ON ( a.numtarjeta = b.numtarjeta )
				WHERE b.numcuenta = psNumCuenta AND b.numtarjeta = psNumTarjeta;

				-- Se obtiene nombre del ejecutivo.
				SELECT ejecutivo, UPPER( nombre )
					INTO sEmpleadoModifico, sNombreEmpMod
				FROM bdinteg:si_ejecut
				WHERE ejecutivo = sEmpleadoModifico;

				-- Se valida la existencia del ejecutivo.
				IF ( NVL( sEmpleadoModifico, '' ) = '' ) THEN

					LET sNumTarjeta = '';

				END IF;

				IF ( NVL( sNumTarjeta, '' ) <> '' ) THEN

					-- Se obtienen los datos para de la sección de "DATOS  DE  LA APERTURA  DE  LA CUENTA".
					SELECT a.numtarjeta, TO_CHAR( c.fecha_alta, '%Y-%m-%d' ), b.sucursal, NVL( c.ejecutivo, '' )
						INTO sNumTarjeta, sFechaStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo
					FROM intercard:tarjetacuenta a
						JOIN bdicheq:sc_maechq b ON ( b.empresa = psEmpresa AND a.numcuenta = b.cuenta )
						JOIN bdicheq:sc_maenoc c ON ( c.empresa = psEmpresa AND a.numcuenta = c.cuenta )
					WHERE a.numcuenta = psNumCuenta AND a.numtarjeta = psNumTarjeta;

					-- Se obtienen nombre de empleado que aperturó la cuenta.
					SELECT ejecutivo, UPPER( nombre )
						INTO sEmpleadoAperturo, sNombreEmpAperturo
					FROM bdinteg:si_ejecut
					WHERE ejecutivo = sEmpleadoAperturo;

					IF ( NVL( sEmpleadoAperturo, '' ) = '' ) THEN

						LET sNumTarjeta = '';

					END IF;

					IF ( NVL( sNumTarjeta, '' ) <> '' ) THEN

						-- Se obtienen los datos para de la sección de "DATOS DE LA ENTREGA DE LA TARJETA".
						SELECT LIMIT 1 TRIM( a.numtarjeta ), SUBSTR( a.idterminal, 1, 4 ), NVL( SUBSTR( a.idterminal, 5, 8 ), '' ), TO_CHAR( a.fechahorainauth, '%Y-%m-%d' ),
								SUBSTR( a.fechahorainauth, 12, 8 )
							INTO sNumTarjeta, sSucursalEntrega, sEmpleadoEntrega, sFechaStatusEntrega, sHoraStatusEntrega
						FROM intercard:movimientohistorico a
						WHERE a.numtarjeta = psNumTarjeta -- Búsqueda por Tarjeta
							AND a.codtran = '95'
							AND a.prodind = '01' AND a.formato = '0200' AND a.codigoiso = '00';

						IF( NVL( sNumTarjeta, '' ) = '' ) THEN -- Si no hubo información en intercard:movimientohistorico, se consulta la intercard:movimiento.

							SELECT LIMIT 1 TRIM( a.numtarjeta ), SUBSTR( a.idterminal, 1, 4 ), NVL( SUBSTR( a.idterminal, 5, 8 ), '' ), TO_CHAR( a.fechahorainauth, '%Y-%m-%d' ),
									SUBSTR( a.fechahorainauth, 12, 8 )
								INTO sNumTarjeta, sSucursalEntrega, sEmpleadoEntrega, sFechaStatusEntrega, sHoraStatusEntrega
							FROM intercard:movimiento a
							WHERE a.numtarjeta = psNumTarjeta -- Búsqueda por Tarjeta
								AND a.codtran = '95'
								AND a.prodind = '01' AND a.formato = '0200' AND a.codigoiso = '00';

						END IF;

						-- Se obtiene la secuencia de la tarjeta.
						SELECT num_tarjeta, secuencia
							INTO sNumTarjeta, iSecuencia
						FROM bdicheq:sc_tarjeta
						WHERE num_tarjeta = sNumTarjeta AND empresa = psEmpresa;

						-- Se obtiene nombre de ejecutivo.
						SELECT ejecutivo, UPPER( nombre )
							INTO sEmpleadoEntrega, sNombreEmpEntrego
						FROM bdinteg:si_ejecut
						WHERE ejecutivo = sEmpleadoEntrega;

						IF( iSecuencia IS NULL OR
							NVL( sEmpleadoEntrega, '' ) = '' ) THEN

							LET sNumTarjeta = '';

						END IF;

						IF ( NVL( sNumTarjeta, '' ) <> '' ) THEN

							-- Se obtienen los datos para de la sección de "HISTÓRICO DE LA TARJETA".
							SELECT a.numtarjeta, UPPER( b.descstatustarjeta ), TO_CHAR( a.fechaultmodif, '%Y-%m-%d' ), SUBSTR( a.fechaultmodif, 12, 8 ), a.usuarioultmodif
								INTO sNumTarjeta, sStatusTarjetaCancelada, sFechaStatusCancelada, sHoraStatusCancelada, sEmpleadoModificoCancelacion
							FROM intercard:tarjeta a
								LEFT OUTER JOIN intercard:statustarjeta b ON ( a.codstatustarjeta = b.codstatustarjeta )
							WHERE a.numtarjeta = psNumTarjeta;

							SELECT ejecutivo, UPPER( nombre )
								INTO sEmpleadoModificoCancelacion, sNombreEmpModCancelacion
							FROM bdinteg:si_ejecut
							WHERE ejecutivo = sEmpleadoModificoCancelacion;

							IF( NVL( sNumTarjeta, '' ) = '' OR NVL( sEmpleadoModificoCancelacion, '' ) = '' ) THEN

								LET sStatusTarjetaCancelada = '';
								LET sFechaStatusCancelada = '';
								LET sHoraStatusCancelada = '';
								LET sEmpleadoModificoCancelacion = '';
								LET sNombreEmpModCancelacion = '';

							END IF;
						ELSE

							LET sCodRet = '00004';

						END IF;
					ELSE

						LET sCodRet = '00003';

					END IF;
				ELSE

					LET sCodRet = '00002';

				END IF;
			END IF;
		ELSE

			LET sCodRet = '00001';

		END IF;

		RETURN
			sCodRet,
			sTipo, sFechaStatusUltMod, sHoraStatusUltMod, sEmpleadoModifico, sNombreEmpMod,
			sFechaStatusAperturaCuenta, sSucursalAperturaCuenta, sEmpleadoAperturo, sNombreEmpAperturo,
			sFechaStatusEntrega, sHoraStatusEntrega, sSucursalEntrega, sEmpleadoEntrega, sNombreEmpEntrego,
			sStatusTarjetaCancelada, sFechaStatusCancelada, sHoraStatusCancelada, iSecuencia, sEmpleadoModificoCancelacion, sNombreEmpModCancelacion;

	END;
END PROCEDURE
DOCUMENT
'CREADO: 		Francisco Rodríguez Ibarra',
'FECHA: 		30 /Abril/ 2010',
'DESCRIPCIÓN: 	Consulta los datos de la Tarjeta, además que trae el histórico.',

'MODIFICÓ: 		Francisco Rodríguez Ibarra',
'FECHA:			19-Mayo-2010',
'MODIFICACIÓN: 	Se modificó SP para que obtener correctamente la secuencia.',

'MODIFICÓ: 		Arturo Méndez Cárdenas',
'FECHA: 		23/11/2010',
'MODIFICACIÓN: 	Obtener el valor de la hora en el segmento del HISTÓRICO DE LA TARJETA.',

'MODIFICÓ: 		Ulises Rodríguez Márquez',
'FECHA: 		28/12/2010',
'MODIFICACIÓN: 	Se optimizan las consultas de datos generales de tarjeta, apertura de cuenta,',
'				entrega de tarjeta e histórico de tarjeta. Costo total 375.',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		24/10/2012',
'MODIFICACIÓN: 	Se agrega búsqueda a tabla intercard:movimientohistorico_old.',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		23/01/2014',
'MODIFICACIÓN: 	Se elimina referencia a tabla intercard:movimientohistorico_old.'

;

CREATE PROCEDURE "informix".sp_sw_ro_consultanombreproducto(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente char(20), pNumCuenta CHAR(20), pSistemaCuenta CHAR(2))
		RETURNING CHAR(5) AS codret,
					CHAR(4) AS producto,
					CHAR(40) AS nombre_producto;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cProducto CHAR(4);
	DEFINE cNombreProducto CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cProducto = '';
	LET cNombreProducto = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cProducto, cNombreProducto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_consultanombreproducto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCuenta = '' OR pSistemaCuenta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cProducto, cNombreProducto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cProducto, cNombreProducto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF pSistemaCuenta = '01' THEN
			SELECT a.producto, b.nombre
			INTO cProducto, cNombreProducto
			FROM bdicheq:sc_maechq a left join bdicheq:sc_producto b on b.producto = a.producto
			WHERE a.cuenta = pNumCuenta AND a.num_cte = pNumCliente;
		ELIF pSistemaCuenta = '03' THEN
			SELECT a.cod_instrum, b.nombre
			INTO cProducto, cNombreProducto
			FROM bdinvers:sv_maeinv a left join bdinvers:sv_instrum b on b.cod_instrum = a.cod_instrum
			WHERE a.cuenta = pNumCuenta
				AND a.num_cte = pNumCliente
				AND secuencia = (SELECT MAX(secuencia) FROM bdinvers:sv_maeinv WHERE cuenta = a.cuenta);
		ELIF pSistemaCuenta = '06' THEN
			SELECT num_producto
			INTO cProducto
			FROM bdicred:sd_maecred a
			WHERE a.num_credito = pNumCuenta
				AND a.numcte = pNumCliente;
			
			IF cProducto IS NULL THEN
				SELECT num_producto
				INTO cProducto
				FROM bdicred:sd_maecredcrd a
				WHERE a.num_credito = pNumCuenta
					AND a.numcte = pNumCliente;
			END IF;
			
			IF cProducto IS NOT NULL THEN
				SELECT nombre_prod
				INTO cNombreProducto
				FROM bdicred:sd_definicion
				WHERE num_producto = cProducto;
			END IF;
		END IF;
		
		IF cNombreProducto IS NULL THEN
			LET cCodRet = '00016';
		END IF;
		
		RETURN cCodRet, cProducto, cNombreProducto;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/10/2014',
'DESCRIPCION: Consulta del nombre del producto y su clave',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_consultaoficio(pUsuario CHAR(8), pIdFuncion CHAR(10), pOficio CHAR(60))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_oficio,
				DATE AS fecha_oficio,
				DATE AS fecha_recepcion,
				CHAR(60) AS expediente,
				INTEGER AS tipo_oficio,
				INTEGER AS institucion1n,
				INTEGER AS institucion2n,
				CHAR(1) AS ind_terminado;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdOficio INTEGER;
	DEFINE dFechaOficio DATE;
	DEFINE dFechaRecepcion DATE;
	DEFINE cExpediente CHAR(60);
	DEFINE iTipoOficio INTEGER;
	DEFINE iInstitucion1n INTEGER;
	DEFINE iInstitucion2n INTEGER;
	DEFINE cIndTerminado CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdOficio = 0;
	LET dFechaOficio = NULL;
	LET dFechaRecepcion = NULL;
	LET cExpediente = '';
	LET iTipoOficio = 0;
	LET iInstitucion1n = 0;
	LET iInstitucion2n = 0;
	LET cIndTerminado = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdOficio, dFechaOficio, dFechaRecepcion, cExpediente, iTipoOficio, iInstitucion1n, iInstitucion2n, cIndTerminado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_consultaoficio.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pOficio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdOficio, dFechaOficio, dFechaRecepcion, cExpediente, iTipoOficio, iInstitucion1n, iInstitucion2n, cIndTerminado;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdOficio, dFechaOficio, dFechaRecepcion, cExpediente, iTipoOficio, iInstitucion1n, iInstitucion2n, cIndTerminado;
		END IF;
		
		-- BUSQUEDA DEL OFICIO
		SET ISOLATION TO DIRTY READ;
		
		SELECT max(id_oficio)
		INTO iIdOficio
		FROM bdicnweb:"informix".sw_ro_maeoficios
		WHERE oficio = pOficio;
		
		IF iIdOficio IS NULL THEN
			LET cCodRet = '00110';
			RETURN cCodRet, iIdOficio, dFechaOficio, dFechaRecepcion, cExpediente, iTipoOficio, iInstitucion1n, iInstitucion2n, cIndTerminado;
		END IF;
		
		-- SE OBTIENEN LOS DATOS DEL OFICIO
		SELECT fecha_oficio, fecha_recepcion, expediente, id_tipooficio, id_institucion1n, id_institucion2n, ind_terminado
		INTO dFechaOficio, dFechaRecepcion, cExpediente, iTipoOficio, iInstitucion1n, iInstitucion2n, cIndTerminado
		FROM bdicnweb:"informix".sw_ro_maeoficios
		WHERE id_oficio = iIdOficio;
		
		RETURN cCodRet, iIdOficio, dFechaOficio, dFechaRecepcion, cExpediente, iTipoOficio, iInstitucion1n, iInstitucion2n, cIndTerminado;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 25/08/2014',
'DESCRIPCION: Busqueda de un oficio existente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_guardatarjetaseleccionada(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdOficio INTEGER, pIdBusqueda INTEGER, pIdCliente INTEGER, pIdTarjeta INTEGER, pIndReportar CHAR(1))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_afectados;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_guardatarjetaseleccionada.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdOficio IS NULL OR pIdBusqueda IS NULL OR pIdCliente IS NULL OR pIdTarjeta IS NULL OR pIndReportar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pIndReportar NOT IN ('0', '1') THEN
			LET cCodRet = '00108';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF EXISTS (SELECT id_tarjeta 
		           FROM bdicnweb:"informix".v_sw_ro_tarjetasclientes 
				   WHERE id_tarjeta = pIdTarjeta 
						AND id_oficio = pIdOficio
						AND id_busqueda = pIdBusqueda
						AND id_resulcte = pIdCliente) THEN
			
			UPDATE bdicnweb:"informix".v_sw_ro_tarjetasclientes 
			SET ind_reportar = DECODE(pIndReportar, '1', 't', 'f')
			WHERE id_tarjeta = pIdTarjeta 
						AND id_oficio = pIdOficio
						AND id_busqueda = pIdBusqueda
						AND id_resulcte = pIdCliente;
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
			RETURN cCodRet, iNoRegistros;
		ELSE
			LET cCodRet = '00001';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 26/08/2014',
'DESCRIPCION: Actualiza un registro de una tarjeta con indicador para ser reportada o no - Respuesta a Oficios',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_facultadosseleccionados(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdOficio INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_rolfuncion,
				INTEGER AS id_facultado;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE idRolFuncion INTEGER;
	DEFINE idFacultado INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET idRolFuncion = 0;
	LET idFacultado = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, idRolFuncion, idFacultado;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_facultadosseleccionados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdOficio IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, idRolFuncion, idFacultado;
		END IF;
		
		-- VALIDACIÃN DE QUE EL NUMERO DE OFICIO QUE ESTA ENTRANDO COMO ARGUMENTO EN REALIDAD EXISTA
		IF NOT EXISTS (SELECT id_oficio FROM sw_ro_maeoficios WHERE id_oficio = pIdOficio) THEN
			LET cCodRet = '00110';
			RETURN cCodRet, idRolFuncion, idFacultado;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT a.id_rolfuncion, a.id_facultado
				INTO idRolFuncion, idFacultado
				FROM sw_ro_oficio_facultados a LEFT JOIN sw_ro_facultados b ON b.id_facultado = a.id_facultado
				WHERE a.id_oficio = pIdOficio
					AND a.status = '1'
				ORDER BY a.id_facultado, a.id_secuencia
				
				RETURN cCodRet, idRolFuncion, idFacultado WITH RESUME;
				
		END FOREACH;

		LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, idRolFuncion, idFacultado;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/09/2014',
'DESCRIPCION: Conslta los indices de los facultados insertados previamente para la respuesta del oficio',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_actualizasolicitudreporte(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdRegSolicitud INTEGER, pNombreArchivo CHAR(80))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idxRegSol;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE iIdx INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bInTransaction='f';
	LET iIdx = 0;
	
	 BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdx;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iIdx;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_actualizasolicitudreporte.out';
		--TRACE ON;
		
		---VALIDACION DE DATOS REQUERIDOS 
		IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSolicitud IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdx;
		END IF;
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdx;
		END IF;
		
		BEGIN WORK;
		
		SET LOCK MODE TO WAIT 3;
		UPDATE bdicnweb:sw_gs_registrosolicitud 
		SET nombre_reporte = pNombreArchivo
		WHERE id_registro_solicitud = pIdRegSolicitud;
		
		COMMIT;
		
		IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
			LET cCodRet = '00236';			ROLLBACK WORK;
			RETURN cCodRet, iIdx;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 1 THEN
			LET iIdx = pIdRegSolicitud;
		END IF;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iIdx;
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 16/07/2014',
'DESCRIPCION: Actualiza nombre de reporte de solicitud reporte en gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_busquedausuarioscat(pUsuario CHAR(8),pIdFuncion CHAR(10), pUsuarioBusqueda CHAR(8), pNombre CHAR(45), pStatus CHAR(1), pArea INTEGER, pJefe CHAR(1))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idArea,
			  CHAR(10) AS claveArea,
			  CHAR(50) AS descArea,
			  CHAR(8) AS idUsuario,
			  CHAR(45) AS nombreUsuario,
			  CHAR(1) AS status,
			  CHAR(1) AS isJefe;

	DEFINE cCodRet CHAR(5);
	DEFINE iIdArea INTEGER;
	DEFINE cClaveArea CHAR(10);
	DEFINE cDescArea CHAR(50);
	DEFINE cIdUsuario CHAR(8);
	DEFINE cNombreUsuario CHAR(45);
	DEFINE cStatus CHAR(1);
	DEFINE cIsJefe CHAR(1);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE bStatus BOOLEAN;
	DEFINE bJefe BOOLEAN;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cCmd2 CHAR(2500);
	
	LET cCodRet = '00000';
	LET iIdArea = 0;
	LET cClaveArea = '';
	LET cDescArea = '';
	LET cIdUsuario = '';
	LET cNombreUsuario = '';
	LET cStatus = '';
	LET cIsJefe = '';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET bStatus = NULL;
	LET bJefe = NULL;
	LET cCmd1 = '';
	LET cCmd2 = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdArea,cClaveArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_busquedausuarioscat.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdArea,cClaveArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdArea,cClaveArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe;
		END IF;
		
		--C0NSTRUCCION DE CONDICIONES
		IF pUsuarioBusqueda <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_usuario = '"|| TRIM(pUsuarioBusqueda) ||"'";
		END IF;
		
		IF pNombre <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.nombre = '"|| TRIM(pNombre) ||"'";
		END IF;
		
		IF pStatus <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.status  = '"|| TRIM(DECODE(pStatus,'0','f','1','t','f')) ||"'";
		END IF;
		
		IF pArea IS NOT NULL OR pArea<> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area  = '"|| pArea ||"'";
		END IF;
		
		IF pJefe <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.jefe_area  = '"|| TRIM(DECODE(pJefe,'0','f','1','t','f')) ||"'";
		END IF;
	
		LET cCmd1="SELECT a.id_area ,b.clave_area, b.descripcion_area, a.id_usuario, c.nombre, DECODE(a.status, 'f', '0', 't', '1', '0') AS status, DECODE(a.jefe_area, 'f', '0', 't', '1', '0') AS jefe";
		LET cCmd1=""||TRIM(cCmd1)||" FROM (bdicnweb:sw_gs_area_usuario a";
		LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area = b.id_area)";
		LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut c ON a.id_usuario= c.ejecutivo";
		LET cCmd1=""||TRIM(cCmd1)||"  WHERE a.id_usuario = a.id_usuario "||TRIM(cCmd2)||"";
		
		PREPARE stmtId FROM TRIM(cCmd1);
		DECLARE selectQryCur CURSOR FOR stmtId;
		OPEN selectQryCur;
		FETCH selectQryCur INTO iIdArea,cClaveArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe;
		WHILE(SQLCODE == 0)	
			RETURN cCodRet,iIdArea,cClaveArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe WITH RESUME;
					LET iNoRegistros = iNoRegistros + 1;
			FETCH selectQryCur INTO iIdArea,cClaveArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe;
		END WHILE;
		CLOSE selectQryCur;
		FREE selectQryCur;
		FREE stmtId;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cClaveArea,iIdArea,cDescArea,cIdUsuario,cNombreUsuario,cStatus,cIsJefe;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 08/07/2014',
'DESCRIPCION: busqueda de usuarios registrados en gestor de solicitudes en SOCWEB ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultaareasrespsol(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdSolicitud INTEGER,pTipoGestor CHAR(1),pOperacion INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_area,
				CHAR(10) AS clave_area,
				CHAR(50) AS descripcion_area,
				CHAR(1) AS status;
			  			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdArea INTEGER;
	DEFINE cClaveArea CHAR(10);
	DEFINE cDescripcionArea CHAR(50);
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdArea = 0;
	LET cClaveArea = '';
	LET cDescripcionArea = '';
	LET cStatus = '';
	
	 BEGIN
	 
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultaareasrespsol.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdSolicitud IS NULL OR pTipoGestor = '' OR pOperacion IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		IF pOperacion NOT IN (0,1) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		IF pTipoGestor='R' THEN
			IF pOperacion = 0 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.id_area, b.clave_area, b.descripcion_area,DECODE(b.status, 'f', '0', 't', '1', '0') as status
						INTO iIdArea, cClaveArea, cDescripcionArea, cStatus
						FROM bdicnweb:sw_gs_area_permisos a LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area=b.id_area
						WHERE a.ind_responsable = 't' AND a.id_solicitud = pIdSolicitud AND b.status = 't'
					RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
			IF pOperacion = 1 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT a.id_area, b.clave_area, b.descripcion_area,DECODE(b.status, 'f', '0', 't', '1', '0') as status
						INTO iIdArea, cClaveArea, cDescripcionArea, cStatus
						FROM bdicnweb:sw_gs_area_permisos a LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area=b.id_area
						WHERE a.ind_responsable = 't' AND b.status = 't'
					RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
		END IF;
		
		IF pTipoGestor='S' THEN
			IF pOperacion = 0 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.id_area, b.clave_area, b.descripcion_area, DECODE(b.status, 'f', '0', 't', '1', '0') as status
						INTO iIdArea, cClaveArea, cDescripcionArea, cStatus
						FROM bdicnweb:sw_gs_area_permisos a LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area=b.id_area
						WHERE a.ind_solicitante = 't' AND a.id_solicitud = pIdSolicitud AND b.status = 't'
					RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
			IF pOperacion = 1 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT a.id_area, b.clave_area, b.descripcion_area, DECODE(b.status, 'f', '0', 't', '1', '0') as status
						INTO iIdArea, cClaveArea, cDescripcionArea, cStatus
						FROM bdicnweb:sw_gs_area_permisos a LEFT JOIN bdicnweb:sw_gs_area b ON a.id_area=b.id_area
						WHERE a.ind_solicitante = 't' AND b.status = 't'
					RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
		END IF;	
		
		IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/05/2014',
'DESCRIPCION: Consulta registros de areas si son responsables o solicitantes dependiendo del filtro tipo de operacion',
'para hacer consulta por id de solicitud o no para grid gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultacatstatussolicitud(pUsuario CHAR(8),pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idStatusSolicitud,
			  CHAR(30) AS descStatusSolicitud;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdStatusSolicitud INTEGER;
	DEFINE cDescStatusSolicitud CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdStatusSolicitud = 0;
	LET cDescStatusSolicitud = '';
	LET iNoRegistros = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdStatusSolicitud,cDescStatusSolicitud;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultacatstatussolicitud.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdStatusSolicitud,cDescStatusSolicitud;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdStatusSolicitud,cDescStatusSolicitud;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			FOREACH SELECT id_status_solicitud, desc_status_solicitud    
					INTO iIdStatusSolicitud,cDescStatusSolicitud
					FROM bdicnweb:sw_gs_catstatussolicitud
				
				RETURN cCodRet,iIdStatusSolicitud,cDescStatusSolicitud WITH RESUME;
				LET iNoRegistros = iNoRegistros +  1;
			END FOREACH;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iIdStatusSolicitud,cDescStatusSolicitud;
		END IF;		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 02/06/2014',
'DESCRIPCION: Consulta catalogo de status de solicitud para gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultacifrassolicitudes(pUsuario CHAR(8),pIdFuncion CHAR(10), pTipoGestor CHAR(1), pOperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  INTEGER AS totalPendientes,
			  INTEGER AS totalCanceladas,
			  INTEGER AS totalRechazadas,
			  INTEGER AS totalExitosas,
			  INTEGER AS totalTodas;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalPendientes INTEGER;
	DEFINE iTotalCanceladas INTEGER;
	DEFINE iTotalRechazadas INTEGER;
	DEFINE iTotalExitosas INTEGER;
	DEFINE iTotalTodas INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotalPendientes = 0;
	LET iTotalCanceladas = 0;
	LET iTotalRechazadas = 0;
	LET iTotalExitosas = 0;
	LET iTotalTodas = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotalPendientes,iTotalCanceladas,iTotalRechazadas,iTotalExitosas,iTotalTodas;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultacifrassolicitudes.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pOperacion IS NULL OR pTipoGestor = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalPendientes,iTotalCanceladas,iTotalRechazadas,iTotalExitosas,iTotalTodas;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iTotalPendientes,iTotalCanceladas,iTotalRechazadas,iTotalExitosas,iTotalTodas;
		END IF;
		
		IF pOperacion NOT IN (0,1) THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iTotalPendientes,iTotalCanceladas,iTotalRechazadas,iTotalExitosas,iTotalTodas;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalPendientes,iTotalCanceladas,iTotalRechazadas,iTotalExitosas,iTotalTodas;
		END IF;
		
		IF pTipoGestor = 'S' THEN
			IF pOperacion = 0 THEN ---Hoy
					SELECT COUNT(*)
					INTO iTotalPendientes					
					FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=0 AND usuario_solicitante=pUsuario AND status='t' AND DATE(fecha_solicitud) =DATE(CURRENT);
				
					SELECT COUNT(*) 
					INTO iTotalCanceladas
					FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=1 AND usuario_solicitante=pUsuario AND status='t' AND DATE(fecha_cambio) =DATE(CURRENT);
				
					SELECT COUNT(*)
					INTO iTotalRechazadas
					FROM bdicnweb:sw_gs_registrosolicitud 
					WHERE id_status_solicitud=2 AND usuario_solicitante=pUsuario AND status='t' AND DATE(fecha_atencion) =DATE(CURRENT);
				
					SELECT COUNT(*) 
					INTO iTotalExitosas
					FROM bdicnweb:sw_gs_registrosolicitud 
					WHERE id_status_solicitud=3 AND usuario_solicitante=pUsuario AND status='t' AND DATE(fecha_atencion) =DATE(CURRENT);
				
					SELECT COUNT(*) 
					INTO iTotalTodas
					FROM bdicnweb:sw_gs_registrosolicitud 
					WHERE usuario_solicitante=pUsuario AND status='t' AND DATE(fecha_solicitud) =DATE(CURRENT);
			END IF;
			
			IF pOperacion = 1 THEN --- Historico		
					SELECT COUNT(*) 
					INTO iTotalPendientes
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=0 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=0 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalCanceladas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=1 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_cambio) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=1 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_cambio) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalRechazadas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=2 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=2 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalExitosas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=3 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=3 AND usuario_solicitante=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT));
				
					SELECT COUNT(*) 
					INTO iTotalTodas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE usuario_solicitante=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE usuario_solicitante=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT));	
			END IF;
		END IF;
		
		IF pTipoGestor = 'R' THEN
			IF pOperacion = 0 THEN ---Hoy
				SELECT COUNT(*)
					INTO iTotalPendientes					
					FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=0 AND usuario_responsable=pUsuario AND status='t' AND DATE(fecha_solicitud) =DATE(CURRENT);
				
					SELECT COUNT(*) 
					INTO iTotalCanceladas
					FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=1 AND usuario_responsable=pUsuario AND status='t' AND DATE(fecha_cambio) =DATE(CURRENT);
				
					SELECT COUNT(*)
					INTO iTotalRechazadas
					FROM bdicnweb:sw_gs_registrosolicitud 
					WHERE id_status_solicitud=2 AND usuario_responsable=pUsuario AND status='t' AND DATE(fecha_atencion) =DATE(CURRENT);
				
					SELECT COUNT(*) 
					INTO iTotalExitosas
					FROM bdicnweb:sw_gs_registrosolicitud 
					WHERE id_status_solicitud=3 AND usuario_responsable=pUsuario AND status='t' AND DATE(fecha_atencion) =DATE(CURRENT);
				
					SELECT COUNT(*) 
					INTO iTotalTodas
					FROM bdicnweb:sw_gs_registrosolicitud 
					WHERE usuario_responsable=pUsuario AND status='t' AND DATE(fecha_solicitud) =DATE(CURRENT);
			END IF;
			IF pOperacion = 1 THEN --- Historico
				SELECT COUNT(*) 
					INTO iTotalPendientes
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=0 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=0 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalCanceladas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=1 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_cambio) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=1 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_cambio) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalRechazadas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=2 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=2 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalExitosas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE id_status_solicitud=3 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE id_status_solicitud=3 AND usuario_responsable=pUsuario and status='t' AND DATE(fecha_atencion) < DATE(CURRENT) );
				
					SELECT COUNT(*) 
					INTO iTotalTodas
					FROM
					(SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud
					WHERE usuario_responsable=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT)
					UNION
					SELECT id_registro_solicitud FROM bdicnweb:sw_gs_registrosolicitud_hist
					WHERE usuario_responsable=pUsuario and status='t' AND DATE(fecha_solicitud) < DATE(CURRENT) );	
			END IF;
		END IF; 
		
		RETURN cCodRet,iTotalPendientes,iTotalCanceladas,iTotalRechazadas,iTotalExitosas,iTotalTodas;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 06/06/2014',
'DESCRIPCION: Consulta cifras de solicitudes para gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultacomentarios(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdRegSol INTEGER)
	RETURNING CHAR(5) AS codret,
			  CHAR(20) AS tipoGestor,
			  CHAR(200)AS comentario;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipoGestor CHAR(20);
	DEFINE cComentario CHAR(200);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipoGestor = '';
	LET cComentario= '';
	LET iNoRegistros = 0;
	
	 BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTipoGestor,cComentario;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultacomentarios.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdRegSol IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTipoGestor,cComentario;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTipoGestor,cComentario;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
			FOREACH SELECT tipo_gestor, comentario 
					INTO cTipoGestor,cComentario
					FROM bdicnweb:sw_gs_comentarios 
					WHERE id_registro_solicitud = pIdRegSol ORDER BY 1 ASC
				
				RETURN cCodRet,cTipoGestor,cComentario WITH RESUME;
				LET iNoRegistros = iNoRegistros +  1;
			END FOREACH;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTipoGestor,cComentario;
		END IF;		
				
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 02/06/2014',
'DESCRIPCION: Consulta comentario de registro de solicitud para gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultahistorialstatus(pUsuario CHAR(8),pIdFuncion CHAR(10),pFolioRegistro CHAR(20),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  DATE AS fechaCambio,
			  CHAR(8) AS horaCambio,
			  CHAR(50) AS descripcionAreaSol,
			  CHAR(8) AS numUsuarioSol,
			  CHAR(45) AS nombreUsuarioSol,
			  CHAR(50) AS descripcionAreaResp,
			  CHAR(8) AS numUsuarioResp,
			  CHAR(45) AS nombreUsuarioResp,
			  CHAR(30) AS descStatusSolicitud;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdRegistroSolicitud INTEGER;
	DEFINE dFechaCambio DATE;
    DEFINE dHoraCambio DATETIME HOUR TO SECOND;
    DEFINE cDescripcionAreaSol CHAR(50);
    DEFINE cNumUsuarioSol CHAR(8);
    DEFINE cNombreUsuarioSol CHAR(45);
    DEFINE cDescripcionAreaResp CHAR(50);
    DEFINE cNumUsuarioResp CHAR(8);
    DEFINE cNombreUsuarioResp CHAR(45);
    DEFINE descStatusSolicitud CHAR(30);
	DEFINE iNoRegistros INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdRegistroSolicitud = 0;
	LET dFechaCambio = NULL;
	LET dHoraCambio = NULL;  
	LET cDescripcionAreaSol = '';
	LET cNumUsuarioSol = ''; 
	LET cNombreUsuarioSol = '';
	LET cDescripcionAreaResp = '';
	LET cNumUsuarioResp = '';
	LET cNombreUsuarioResp = '';
	LET descStatusSolicitud = '';
	LET iNoRegistros = 0;
	
	 BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				   cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultahistorialstatus.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pFolioRegistro = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				   cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				   cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id_registro_solicitud, fecha_cambio, hora_cambio, descripcion_area_soli, ejecutivo_soli, nombre_soli,
				descripcion_area_resp, ejecutivo_resp, nombre_resp, desc_status_solicitud
				INTO iIdRegistroSolicitud,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				   cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud
				FROM 
				(SELECT  a.id_registro_solicitud, a.fecha_cambio, a.hora_cambio, e.descripcion_area AS descripcion_area_soli, g.ejecutivo AS ejecutivo_soli, g.nombre AS nombre_soli,
				d.descripcion_area AS descripcion_area_resp,f.ejecutivo AS ejecutivo_resp, f.nombre AS nombre_resp,b.desc_status_solicitud
				FROM ((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud) 
				LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)
				LEFT JOIN bdicnweb:sw_gs_area e ON a.id_area_solicitante=e.id_area)
				LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)
				LEFT JOIN bdinteg:si_ejecut g ON g.ejecutivo=a.usuario_solicitante
				WHERE a.folio_solicitud = pFolioRegistro
				UNION
				SELECT  a.id_registro_solicitud, a.fecha_cambio, a.hora_cambio, e.descripcion_area AS descripcion_area_soli, g.ejecutivo AS ejecutivo_soli, g.nombre AS nombre_soli,
				d.descripcion_area AS descripcion_area_resp,f.ejecutivo AS ejecutivo_resp, f.nombre AS nombre_resp,b.desc_status_solicitud
				FROM ((((bdicnweb:sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud) 
				LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)
				LEFT JOIN bdicnweb:sw_gs_area e ON a.id_area_solicitante=e.id_area)
				LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)
				LEFT JOIN bdinteg:si_ejecut g ON g.ejecutivo=a.usuario_solicitante
				WHERE a.folio_solicitud = pFolioRegistro)
				
				RETURN cCodRet,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				       cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud WITH RESUME;
				LET iNoRegistros = iNoRegistros +  1;
		
		END FOREACH;
		
		IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				       cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFechaCambio,dHoraCambio,cDescripcionAreaSol,cNumUsuarioSol,cNombreUsuarioSol,cDescripcionAreaResp,
				       cNumUsuarioResp,cNombreUsuarioResp,descStatusSolicitud;
		END IF;
		
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/05/2014',
'DESCRIPCION: Consulta historial de status solicitud para grid gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultamotivoscancelacion(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdSolicitud INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idMotivoCancelacion,
			  CHAR(10) AS claveMotivo,
			  CHAR(50) AS descripcionMotivo;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdMotivoCancelacion INTEGER;
	DEFINE cClaveMotivo CHAR(10);
	DEFINE cDescripcionMotivo CHAR(50);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdMotivoCancelacion = 0;
	LET cClaveMotivo = '';
	LET cDescripcionMotivo = '';
	LET iNoRegistros = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultamotivoscancelacion.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdSolicitud IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id_motivo_cancelacion, clave_motivo, descripcion_motivo
				INTO iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo
				FROM bdicnweb:sw_gs_motivos_cancelacion WHERE id_solicitud = pIdSolicitud AND status = 't'
			RETURN cCodRet,iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo WITH RESUME;
			LET iNoRegistros = iNoRegistros +  1;
		END FOREACH;
		
		IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo;
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00361';
			RETURN cCodRet,iIdMotivoCancelacion,cClaveMotivo,cDescripcionMotivo;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 03/06/2014',
'DESCRIPCION: Consulta registros motivos de cancelacion de solicitudes para gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultamtvoscancelacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_motivo_cancelacion,
			CHAR(2) AS sistema_cuenta,
			CHAR(30) AS desc_sistema_cta,
			INTEGER AS id_tipo_solicitud,
			CHAR(50) AS desc_tipo_solicitud,
			CHAR(10) AS clave_motivo,
			CHAR(50) AS descripcion_motivo,
			CHAR(1) AS status_motivo;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdMotivoCancelacion INTEGER;
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cDescSistemaCuenta CHAR(30);
	DEFINE iIdTipoSolicitud INTEGER;
	DEFINE cDescTipoSolicitud CHAR(50);
	DEFINE cClaveMotivo CHAR(10);
	DEFINE cDescMotivo CHAR(50);
	DEFINE cStatusMotivo CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdMotivoCancelacion = 0;
	LET cSistemaCuenta = '';
	LET cDescSistemaCuenta = '';
	LET iIdTipoSolicitud = 0;
	LET cDescTipoSolicitud = '';
	LET cClaveMotivo = '';
	LET cDescMotivo = '';
	LET cStatusMotivo = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultamtvoscancelacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT a.id_motivo_cancelacion, a.id_sistema_cuenta, b.descripcion_sistema_cuenta, c.descripcion_solicitud, a.clave_motivo, 
						a.descripcion_motivo, DECODE(a.status, 't', '1', 'f', '0', '0'), c.id_solicitud
				INTO iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo, iIdTipoSolicitud
				FROM bdicnweb:sw_gs_motivos_cancelacion a, bdicnweb:sw_gs_sistema_cuenta b, bdicnweb:sw_gs_solicitudes c
				WHERE b.id_sistema_cuenta = a.id_sistema_cuenta AND c.id_solicitud = a.id_solicitud
				ORDER by a.id_sistema_cuenta, a.id_motivo_cancelacion
		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdMotivoCancelacion, cSistemaCuenta, cDescSistemaCuenta, iIdTipoSolicitud, cDescTipoSolicitud, cClaveMotivo, cDescMotivo, cStatusMotivo;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/05/2014',
'DESCRIPCION: Consulta el catalogo de los motivos de cancelaciÃ³n para el gestor de solicitudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultareas(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_area,
				CHAR(10) AS clave_area,
				CHAR(50) AS descripcion_area,
				CHAR(1) AS status;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdArea INTEGER;
	DEFINE cClaveArea CHAR(10);
	DEFINE cDescripcionArea CHAR(50);
	DEFINE cStatus CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdArea = 0;
	LET cClaveArea = '';
	LET cDescripcionArea = '';
	LET cStatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultareas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT id_area, clave_area, descripcion_area, DECODE(status, 'f', '0', 't', '1', '0') as status
				INTO iIdArea, cClaveArea, cDescripcionArea, cStatus
				FROM bdicnweb:sw_gs_area
				
				LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdArea, cClaveArea, cDescripcionArea, cStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 06/05/2014',
'DESCRIPCION: Consulta el catalogo de areas para el gestor de solicitudes, SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultaregistrosolicitud(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdStatusSolicitud INTEGER,pTipoGestor CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idRegistroSolicitud,
			  DATE AS fechaSolicitud,
			  DATE AS fechaAtencion,
			  CHAR(20) AS folioSolicitud,
			  CHAR(2) AS idSistemaCuenta,
			  CHAR(10) AS idFuncionSolicitud,
			  CHAR(50) AS descripcionSolicitud,
			  CHAR(20) AS cliente, 
			  CHAR(20) AS cuenta,
			  CHAR(50) AS descripcionArea,
			  CHAR(8) AS numUsuario,
			  CHAR(45) AS nombre,
			  CHAR(50) AS descStatusSolicitud,
			  CHAR(50) AS descripcionMotivo,
			  INTEGER AS IdStatusSolicitud,
			  INTEGER AS idSolicitud,
			  CHAR(120) AS nombreCliente,
			  CHAR(8) AS numUsuario2,
			  CHAR(45) AS nombre2,
			  CHAR(50) AS descripcionArea2,
			  CHAR(16) AS folioTransaccion,
			  CHAR(5) AS codError,
			  CHAR(100) AS descError,
			  DECIMAL(16,2) AS importe,
			  CHAR(1) AS abreReporte,
			  CHAR(80) AS nombreReporte;
			  			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdRegistroSolicitud INTEGER;
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaAtencion DATE;
	DEFINE iFolioSolicitud CHAR(20);
	DEFINE cIdSistemaCuenta CHAR(2);
	DEFINE iIdFuncionSolicitud CHAR(10);
	DEFINE cDescripcionSolicitud CHAR(50);
	DEFINE cCliente CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cDescripcionArea CHAR(50);
	DEFINE cNumUsuario CHAR(8);
	DEFINE cNombre CHAR(45);
	DEFINE cDescStatusSolicitud CHAR(50);
	DEFINE cDescripcionMotivo CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdStatusSolicitud INTEGER;
	DEFINE iArea INTEGER;
	DEFINE iIdSolicitud INTEGER;
	DEFINE cCmd1 CHAR(5000);
	DEFINE cCmd2 CHAR(2500);
	DEFINE cNombreCliente CHAR(120);
	DEFINE cNumUsuario2 CHAR(8);
	DEFINE cNombre2 CHAR(45);
	DEFINE cDescripcionArea2 CHAR(50);
	DEFINE cFolioTransaccion CHAR(16);
	DEFINE cCodError CHAR(5);
	DEFINE cDescError CHAR(100);
	DEFINE dImporte DECIMAL(16,2);
	DEFINE bAbreReporte CHAR(1);
	DEFINE cNombreReporte CHAR(80);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdRegistroSolicitud = 0;
	LET dFechaSolicitud = NULL;
	LET dFechaAtencion = NULL;
	LET iFolioSolicitud = '';
	LET cIdSistemaCuenta = '';
	LET iIdFuncionSolicitud = '';
	LET cDescripcionSolicitud = '';
	LET cCliente = '';
	LET cCuenta = '';
	LET cDescripcionArea = '';
	LET cNumUsuario = '';
	LET cNombre = '';
	LET cDescStatusSolicitud = '';
	LET cDescripcionMotivo = '';
	LET iNoRegistros = 0;
	LET iIdStatusSolicitud = 0;
	LET iArea = 0;
	LET iIdSolicitud = 0;
	LET cCmd1 = '';
	LET cCmd2 = '';
	LET cNombreCliente = '';
	LET cNumUsuario2 = '';
	LET cNombre2 = '';
	LET cDescripcionArea2 = '';
	LET cFolioTransaccion = '';
	LET cCodError = '';
	LET cDescError = '';
	LET dImporte = 0;
	LET bAbreReporte = '';
	LET cNombreReporte = '';
	
	 BEGIN
	 
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,
				   cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultaregistrosolicitud.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdStatusSolicitud IS NULL OR pTipoGestor = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,
				   cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,
				   cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
		END IF;
		
		IF pIdStatusSolicitud NOT IN (0,1,2,3,4,5) THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,cNombre,cDescStatusSolicitud,
				   cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,
				   cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,
				   cNombre,cDescStatusSolicitud,cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,
				   cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
		END IF;
		
		IF pTipoGestor='S' THEN
			IF pIdStatusSolicitud IN(0,1,2,3) THEN
				LET cCmd2=" a.usuario_solicitante ="|| pUsuario ||" AND a.id_status_solicitud ="|| pIdStatusSolicitud ||" AND a.status='t' ORDER BY 1 DESC";
			END IF;
			IF pIdStatusSolicitud = 4 THEN
				LET cCmd2="a.usuario_solicitante ="|| pUsuario || " AND a.status='t' ORDER BY 1 DESC";
			END IF;
			IF pIdStatusSolicitud = 5 THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_solicitante ="|| iArea ||" AND a.status='t' ORDER BY 1 DESC";
			END IF;
			
			---Consulta
			LET cCmd1="SELECT SKIP "||pRegistros||" FIRST "||pRecuperacion||" a.id_registro_solicitud, a.fecha_solicitud, a.fecha_atencion, a.folio_solicitud, c.id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||" c.id_funcion,c.descripcion_solicitud, a.cliente, a.cuenta, d.descripcion_area,f.ejecutivo, f.nombre, b.desc_status_solicitud, e.descripcion_motivo,";
			LET cCmd1=""||TRIM(cCmd1)||" a.id_status_solicitud, a.id_solicitud, TRIM(''||TRIM(g.nombre1)||' '||TRIM(g.nombre2)||' '||TRIM(g.apell_paterno)||' '||TRIM(g.apell_materno)||'') as nombre_cliente, a.folio_transaccion,";
			LET cCmd1=""||TRIM(cCmd1)||" a.cod_error, a.desc_error, a.importe, DECODE(c.abre_reporte,'f','0','t','1','f') as abreReporte, a.nombre_reporte ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM (((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente ";
			LET cCmd1=""||TRIM(cCmd1)||" WHERE "||TRIM(cCmd2)||"";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
									iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
									iIdSolicitud,cNombreCliente,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			WHILE(SQLCODE == 0)	
				RETURN cCodRet,iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, LPAD(TRIM(iFolioSolicitud),13, '0'), cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
					   iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte WITH RESUME;
					   	LET iNoRegistros = iNoRegistros + 1;
				FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
									    iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
									    iIdSolicitud,cNombreCliente,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			END WHILE;
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,
				       cNombre,cDescStatusSolicitud,cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,
					   cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			END IF;
		
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				       iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,
				       cNombre,cDescStatusSolicitud,cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,
					   cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			END IF;
			
		END IF;
		
		IF pTipoGestor='R' THEN 
			IF pIdStatusSolicitud IN(0,1,2,3) THEN
				LET cCmd2="a.usuario_responsable ="|| pUsuario ||" AND a.id_status_solicitud ="|| pIdStatusSolicitud ||" AND a.status='t' ORDER BY 1 DESC";
			END IF;
			IF pIdStatusSolicitud = 4 THEN
				LET cCmd2="a.usuario_responsable ="|| pUsuario ||" AND a.status='t' ORDER BY 1 DESC";
			END IF;
			IF pIdStatusSolicitud = 5 THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_responsable ="|| iArea ||" AND a.status='t' ORDER BY 1 DESC";
			END IF;
			
			---Consulta
			LET cCmd1="SELECT SKIP "||pRegistros||" FIRST "||pRecuperacion||" a.id_registro_solicitud, a.fecha_solicitud, a.fecha_atencion, a.folio_solicitud, c.id_sistema_cuenta,";
			LET cCmd1=""||TRIM(cCmd1)||" c.id_funcion, c.descripcion_solicitud, a.cliente, a.cuenta, d.descripcion_area,f.ejecutivo, f.nombre, b.desc_status_solicitud, e.descripcion_motivo,";
            LET cCmd1=""||TRIM(cCmd1)||" a.id_status_solicitud, a.id_solicitud,TRIM(''||TRIM(g.nombre1)||' '||TRIM(g.nombre2)||' '||TRIM(g.apell_paterno)||' '||TRIM(g.apell_materno)||'') as nombre_cliente,h.ejecutivo, h.nombre, i.descripcion_area, a.folio_transaccion,";
			LET cCmd1=""||TRIM(cCmd1)||" a.cod_error, a.desc_error, a.importe, DECODE(c.abre_reporte,'f','0','t','1','f') as abreReporte, a.nombre_reporte ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM (((((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdinteg:si_ejecut h ON h.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||" LEFT JOIN bdicnweb:sw_gs_area i ON a.id_area_responsable=i.id_area";
			LET cCmd1=""||TRIM(cCmd1)||" WHERE "||TRIM(cCmd2)||"";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
									iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
									iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			WHILE(SQLCODE == 0)	
				RETURN cCodRet,iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, LPAD(TRIM(iFolioSolicitud),13, '0'), cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
					   iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte WITH RESUME;
					   	LET iNoRegistros = iNoRegistros + 1;
				FETCH selectQryCur INTO iIdRegistroSolicitud, dFechaSolicitud, dFechaAtencion, iFolioSolicitud, cIdSistemaCuenta,
									    iIdFuncionSolicitud,cDescripcionSolicitud, cCliente, cCuenta, cDescripcionArea,cNumUsuario, cNombre, cDescStatusSolicitud, cDescripcionMotivo,iIdStatusSolicitud,
									    iIdSolicitud,cNombreCliente,cNumUsuario2,cNombre2,cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			END WHILE;
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
					   iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,
				       cNombre,cDescStatusSolicitud,cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,
					   cNombre2,cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			END IF;
		
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iIdRegistroSolicitud,dFechaSolicitud,dFechaAtencion,iFolioSolicitud,cIdSistemaCuenta,
				       iIdFuncionSolicitud,cDescripcionSolicitud,cCliente,cCuenta,cDescripcionArea,cNumUsuario,
				       cNombre,cDescStatusSolicitud,cDescripcionMotivo,iIdStatusSolicitud,iIdSolicitud,cNombreCliente,cNumUsuario2,
					   cNombre2,cDescripcionArea2,cFolioTransaccion,cCodError,cDescError,dImporte,bAbreReporte,cNombreReporte;
			END IF;	
		END IF;	
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/05/2014',
'DESCRIPCION: Consulta registros de solicitud para grid gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultareintentossolicitud(pUsuario CHAR(8),pIdFuncion CHAR(10),pFolioRegistro CHAR(20))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS totalReintentos;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalReintentos INTEGER;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotalReintentos = 0;
	
	
	 BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotalReintentos;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultareintentossolicitud.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pFolioRegistro = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotalReintentos;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotalReintentos;
		END IF;
		
		
		SELECT MAX(num_reintentos)
		INTO iTotalReintentos
		FROM 
		(SELECT id_registro_solicitud, num_reintentos
			FROM bdicnweb:sw_gs_registrosolicitud
			WHERE folio_solicitud = pFolioRegistro
			UNION
			SELECT id_registro_solicitud, num_reintentos
			FROM bdicnweb:sw_gs_registrosolicitud_hist
			WHERE folio_solicitud = pFolioRegistro);
				
		RETURN cCodRet,iTotalReintentos;
		
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/06/2014',
'DESCRIPCION: Consulta total de reintentos de una solicitud para grid gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultasolicitudes(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_solicitud,
				CHAR(2) AS id_sistema_cuenta,
				CHAR(10) AS id_funcion,
				CHAR(30) AS sistema_cuenta,
				CHAR(50) AS descripcion_solicitud,
				CHAR(1) AS abreReporte;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdSolicitud INTEGER;
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cDescSistemaCuenta CHAR(30);
	DEFINE cDescSolicitud CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE cIdFuncion CHAR(10);
	DEFINE cAbreReporte CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdSolicitud = 0;
	LET cSistemaCuenta = '';
	LET cDescSistemaCuenta = '';
	LET cDescSolicitud = '';
	LET iNoRegistros = 0;
	LET cIdFuncion = '';
	LET cAbreReporte = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdSolicitud, cSistemaCuenta, cIdFuncion, cDescSistemaCuenta, cDescSolicitud, cAbreReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultasolicitudes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdSolicitud, cSistemaCuenta, cIdFuncion, cDescSistemaCuenta, cDescSolicitud, cAbreReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdSolicitud, cSistemaCuenta, cIdFuncion, cDescSistemaCuenta, cDescSolicitud, cAbreReporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT b.descripcion_sistema_cuenta, a.descripcion_solicitud, a.id_solicitud, a.id_sistema_cuenta, a.id_funcion, DECODE(a.abre_reporte,'f','0','t','1','f') AS abreReporte
			INTO cDescSistemaCuenta, cDescSolicitud, iIdSolicitud, cSistemaCuenta, cIdFuncion, cAbreReporte
			FROM bdicnweb:sw_gs_solicitudes a, bdicnweb:sw_gs_sistema_cuenta b
			WHERE b.id_sistema_cuenta = a.id_sistema_cuenta AND status = 't'
			
			RETURN cCodRet, iIdSolicitud, cSistemaCuenta, cIdFuncion, cDescSistemaCuenta, cDescSolicitud, cAbreReporte WITH RESUME;
			LET iNoRegistros = iNoRegistros +  1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdSolicitud, cSistemaCuenta, cIdFuncion, cDescSistemaCuenta, cDescSolicitud, cAbreReporte;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/05/2014',
'DESCRIPCION: Procedimiento que consulta el catalogo de los tipos de solicitudes para el gestor de solicitudes en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultasolicitudesarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdArea INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_solicitud,
				CHAR(1) AS es_responsable,
				CHAR(1) AS es_solicitante;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdSolicitud INTEGER;
	DEFINE cEsResponsable CHAR(1);
	DEFINE cEsSolicitante CHAR(1);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdSolicitud = 0;
	LET cEsResponsable = '';
	LET cEsSolicitante = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdSolicitud, cEsResponsable, cEsSolicitante;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultasolicitudesarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdArea IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdSolicitud, cEsResponsable, cEsSolicitante;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdSolicitud, cEsResponsable, cEsSolicitante;
		END IF;
		
		IF (SELECT COUNT(id_detalle_area) FROM bdicnweb:sw_gs_area_permisos WHERE id_area = pIdArea) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdSolicitud, cEsResponsable, cEsSolicitante;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT id_solicitud, DECODE(ind_responsable, 't', '1', 'f', '0', '0'), DECODE(ind_solicitante, 't', '1', 'f', '0', '0')
				INTO iIdSolicitud, cEsResponsable, cEsSolicitante
				FROM bdicnweb:sw_gs_area_permisos
				WHERE id_area = pIdArea
				
				RETURN cCodRet, iIdSolicitud, cEsResponsable, cEsSolicitante WITH RESUME;
				
		END FOREACH;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/05/2014',
'DESCRIPCION: Consulta los datos de una plantilla de permisos por area para el gestor de solicitudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultatipocuenta(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS sistema_cuenta,
			CHAR(30) AS desc_sistema_cuenta;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cDescSistemaCuenta CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET cSistemaCuenta = '';
	LET cDescSistemaCuenta = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSistemaCuenta, cDescSistemaCuenta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultatipocuenta.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSistemaCuenta, cDescSistemaCuenta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSistemaCuenta, cDescSistemaCuenta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT id_sistema_cuenta, descripcion_sistema_cuenta
				INTO cSistemaCuenta, cDescSistemaCuenta
				FROM bdicnweb:sw_gs_sistema_cuenta
				ORDER BY id_sistema_cuenta
				
			RETURN cCodRet, cSistemaCuenta, cDescSistemaCuenta WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cSistemaCuenta, cDescSistemaCuenta;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 08/05/2014',
'DESCRIPCION: Consulta el catalogo de sistemas cuenta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultatotregistrosolicitud(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdStatusSolicitud INTEGER,pTipoGestor CHAR(1))
	RETURNING CHAR(5) AS codret,
				INTEGER AS total;
			  			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iArea INTEGER;
	DEFINE cCmd1 CHAR(2500);
	DEFINE cCmd2 CHAR(2500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iArea =0;
	LET cCmd1 = '';
	LET cCmd2 = '';
	
	 BEGIN
	 
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultatotregistrosolicitud.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdStatusSolicitud IS NULL OR pTipoGestor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pIdStatusSolicitud NOT IN (0,1,2,3,4,5) THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pTipoGestor='S' THEN
			IF pIdStatusSolicitud IN(0,1,2,3) THEN
				LET cCmd2="usuario_solicitante ="|| pUsuario ||" AND id_status_solicitud ="|| pIdStatusSolicitud ||" AND status='t'";
			END IF;
			IF pIdStatusSolicitud = 4 THEN
				LET cCmd2="usuario_solicitante ="|| pUsuario ||" AND status='t'";
			END IF;
			IF pIdStatusSolicitud = 5 THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="id_area_solicitante ="|| iArea ||" AND status='t'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT COUNT(*) ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM bdicnweb:sw_gs_registrosolicitud";
			LET cCmd1=""||TRIM(cCmd1)||" WHERE "||TRIM(cCmd2)||"";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iNoRegistros;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			RETURN cCodRet,iNoRegistros;
			
		END IF;
		
		IF pTipoGestor='R' THEN
			IF pIdStatusSolicitud IN(0,1,2,3) THEN
				LET cCmd2="usuario_responsable ="|| pUsuario ||" AND id_status_solicitud ="|| pIdStatusSolicitud ||" AND status='t'";
			END IF;
			IF pIdStatusSolicitud = 4 THEN
				LET cCmd2="usuario_responsable ="|| pUsuario ||" AND status='t'";
			END IF;
			IF pIdStatusSolicitud = 5 THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="id_area_responsable ="|| iArea ||" AND status='t'";
			END IF;
		
			--- CONSULTA
			LET cCmd1="SELECT COUNT(*) ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM bdicnweb:sw_gs_registrosolicitud";
			LET cCmd1=""||TRIM(cCmd1)||" WHERE "||TRIM(cCmd2)||"";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iNoRegistros;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			RETURN cCodRet,iNoRegistros;
		
		END IF;	
	 END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/05/2014',
'DESCRIPCION: Consulta total de registros de solicitud para grid gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultausuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pUsuarioConsulta CHAR(8))
		RETURNING CHAR(5) AS codret,
				CHAR(8) AS usuario, 
				INTEGER AS id_area_usuario,
				CHAR(1) AS status, 
				INTEGER AS id_area,
				CHAR(50) AS decripcion_area,
				CHAR(1) AS ind_jefe_area;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cUsuario CHAR(8);
	DEFINE iIdAreaUsuario INTEGER;
	DEFINE cStatus CHAR(1);
	DEFINE cIdArea INTEGER; 
	DEFINE cDescArea CHAR(50);
	DEFINE cJefeArea CHAR(1);
	DEFINE iNoRegs INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cUsuario = '';
	LET iIdAreaUsuario = 0;
	LET cStatus = '';
	LET cIdArea = 0; 
	LET cDescArea = '';
	LET cJefeArea = '';
	LET iNoRegs = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cUsuario, iIdAreaUsuario, cStatus, cIdArea, cDescArea, cJefeArea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultausuarioarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pUsuarioConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cUsuario, iIdAreaUsuario, cStatus, cIdArea, cDescArea, cJefeArea;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, iIdAreaUsuario, cStatus, cIdArea, cDescArea, cJefeArea;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT a.id_area_usuario, 
			DECODE(a.status, 'f', '0', 't', '1', '0'), 
			b.id_area, 
			b.descripcion_area, 
			DECODE(a.jefe_area, 'f', '0', 't', '1', '0')
		INTO iIdAreaUsuario, cStatus, cIdArea, cDescArea, cJefeArea
		FROM bdicnweb:sw_gs_area_usuario a, bdicnweb:sw_gs_area b
		WHERE a.id_usuario = pUsuarioConsulta
			AND b.id_area = a.id_area;
			
		LET iNoRegs = DBINFO('sqlca.sqlerrd2');
		
		IF iNoRegs = 1 THEN
			LET cUsuario = pUsuarioConsulta;
			RETURN cCodRet, cUsuario, iIdAreaUsuario, cStatus, cIdArea, cDescArea, cJefeArea;
		ELIF iNoRegs = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cUsuario, iIdAreaUsuario, cStatus, cIdArea, cDescArea, cJefeArea;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/05/2014',
'DESCRIPCION: Consulta de los datos de alta de la relaciÃ³n de usuarios/areas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_consultausuariosrespsol(pUsuario CHAR(8),pIdFuncion CHAR(10),pIdArea INTEGER,pIdSolicitud INTEGER, pTipoGestor CHAR(1),pOperacion INTEGER, pMontoOperar DECIMAL(16,2), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  INTEGER AS idAreaUsuario,
			  CHAR(8) AS idUsuario,
			  CHAR(45) AS nombre,
			  INTEGER AS idArea;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdAreaUsuario INTEGER;
	DEFINE cIdUsuario CHAR(8);
	DEFINE cNombre CHAR(45);
	DEFINE iIdArea INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdAreaUsuario = 0;
	LET cIdUsuario = '';
	LET cNombre = '';
	LET iIdArea = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultausuariosrespsol.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pIdArea IS NULL OR pIdSolicitud IS NULL OR pTipoGestor = '' OR pOperacion IS NULL OR pMontoOperar IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END IF;
		
		IF pOperacion NOT IN (0,1) THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END IF;
		
		IF pTipoGestor='R' THEN
			IF pOperacion = 0 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.id_area_usuario, a.id_usuario, c.nombre, a.id_area 
						INTO iIdAreaUsuario, cIdUsuario, cNombre, iIdArea
						FROM (((bdicnweb:"informix".sw_gs_area_usuario a LEFT JOIN bdicnweb:"informix".sw_gs_area_solicitudes b ON a.id_area_usuario = b.id_area_usuario)
							  LEFT JOIN bdinteg:"informix".si_ejecut c ON a.id_usuario = c.ejecutivo)
							  LEFT JOIN bdicnweb:"informix".sw_gs_solicitudes d ON b.id_solicitud = d.id_solicitud)
							  LEFT JOIN bdinteg:"informix".si_seg_montos_autorizados e ON a.id_usuario = e.id_usuario 
						WHERE a.id_area = pIdArea AND b.ind_responsable = 't' AND a.status = 't' AND b.id_solicitud = pIdSolicitud
							AND (CASE TRIM(d.id_sistema_cuenta) WHEN '01' THEN --DEBITO
																	CASE TRIM(SUBSTR(d.descripcion_solicitud,0,3)) WHEN 'DEP' THEN e.monto_max_deb_abono
																												   WHEN 'BLO' THEN
																														CASE pMontoOperar WHEN 0 THEN pMontoOperar
																																		  ELSE e.monto_max_deb_cargo
																																		  END
																												   WHEN 'RET' THEN e.monto_max_deb_cargo
																												   WHEN 'REV' THEN e.monto_max_deb_reverso
																												   ELSE pMontoOperar 
																	END
															    WHEN '06' THEN --CREDITO
																	CASE TRIM(SUBSTR(d.descripcion_solicitud,0,3)) WHEN 'CAR' THEN e.monto_max_cred_cargo
																												   WHEN 'PAG' THEN e.monto_max_cred_abono
																												   WHEN 'REV' THEN e.monto_max_cred_reverso
																												   ELSE pMontoOperar 
																	END
															    ELSE pMontoOperar 
								END
							  ) >= pMontoOperar
					RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
			IF pOperacion = 1 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT a.id_area_usuario, a.id_usuario, c.nombre, a.id_area 
						INTO iIdAreaUsuario, cIdUsuario, cNombre, iIdArea
						FROM (bdicnweb:"informix".sw_gs_area_usuario a LEFT JOIN bdicnweb:"informix".sw_gs_area_solicitudes b ON a.id_area_usuario = b.id_area_usuario)
							  LEFT JOIN bdinteg:"informix".si_ejecut c ON a.id_usuario = c.ejecutivo
						WHERE a.id_area = pIdArea AND b.ind_responsable = 't' AND a.status = 't'
					RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
		END IF;
		
		IF pTipoGestor='S' THEN
			IF pOperacion = 0 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.id_area_usuario, a.id_usuario, c.nombre, a.id_area 
						INTO iIdAreaUsuario, cIdUsuario, cNombre, iIdArea
						FROM (((bdicnweb:"informix".sw_gs_area_usuario a LEFT JOIN bdicnweb:"informix".sw_gs_area_solicitudes b ON a.id_area_usuario = b.id_area_usuario)
							  LEFT JOIN bdinteg:"informix".si_ejecut c ON a.id_usuario = c.ejecutivo)
							  LEFT JOIN bdicnweb:"informix".sw_gs_solicitudes d ON b.id_solicitud = d.id_solicitud)
							  LEFT JOIN bdinteg:"informix".si_seg_montos_autorizados e ON a.id_usuario = e.id_usuario 
						WHERE a.id_area = pIdArea AND b.ind_solicitante = 't' AND a.status = 't' AND b.id_solicitud = pIdSolicitud
							AND (CASE TRIM(d.id_sistema_cuenta) WHEN '01' THEN --DEBITO
																	CASE TRIM(SUBSTR(d.descripcion_solicitud,0,3)) WHEN 'DEP' THEN e.monto_max_deb_abono
																												   WHEN 'BLO' THEN
																														CASE pMontoOperar WHEN 0 THEN pMontoOperar
																																		  ELSE e.monto_max_deb_cargo
																																		  END
																												   WHEN 'RET' THEN e.monto_max_deb_cargo
																												   WHEN 'REV' THEN e.monto_max_deb_reverso
																												   ELSE pMontoOperar 
																	END
															    WHEN '06' THEN --CREDITO
																	CASE TRIM(SUBSTR(d.descripcion_solicitud,0,3)) WHEN 'CAR' THEN e.monto_max_cred_cargo
																												   WHEN 'PAG' THEN e.monto_max_cred_abono
																												   WHEN 'REV' THEN e.monto_max_cred_reverso
																												   ELSE pMontoOperar 
																	END
															    ELSE pMontoOperar 
								END
							  ) >= pMontoOperar
					RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
			IF pOperacion = 1 THEN
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT a.id_area_usuario, a.id_usuario, c.nombre, a.id_area 
						INTO iIdAreaUsuario, cIdUsuario, cNombre, iIdArea
						FROM (bdicnweb:"informix".sw_gs_area_usuario a LEFT JOIN bdicnweb:"informix".sw_gs_area_solicitudes b ON a.id_area_usuario = b.id_area_usuario)
							  LEFT JOIN bdinteg:"informix".si_ejecut c ON a.id_usuario = c.ejecutivo
						WHERE a.id_area = pIdArea AND b.ind_solicitante = 't' AND a.status = 't'
					RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea WITH RESUME;
					LET iNoRegistros = iNoRegistros +  1;
				END FOREACH;
			END IF;
		END IF;
		
		IF pRegistros > 0 AND iNoRegistros = 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END IF;
		
		IF iNoRegistros = 0 THEN
			IF pOperacion = 0 THEN
				LET cCodRet = '00360'; -- NO SE ENCONTRARÃN USUARIOS CON MONTO AUTORIZADO A OPERAR
			ELSE
				LET cCodRet = '00017';
			END IF
			RETURN cCodRet,iIdAreaUsuario,cIdUsuario,cNombre,iIdArea;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 26/05/2014',
'DESCRIPCION: Consulta registros de usuarios si son responsables o solicitantes dependiendo del area',
'con filtro de operacion para realizar la busqueda por id solicitud o no para gestor de operaciones en SOCWEB',
'FECHA: 18/09/2014',
'DESCRIPCION: Se modifica la consulta para validar y obtener los montos correctos de la tabla bdinteg:si_seg_montos_autorizados',
'  			  a operar por funcionalidad',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_eliminareportesrepositorio(pDiasVigenciaReportes SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(80) AS nombre_archivo;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNombreReporte CHAR(80);
	DEFINE iIdRegistroSolicitud INTEGER;
	DEFINE iRegistrosEncontrados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombreReporte = '';
	LET iIdRegistroSolicitud = 0;
	LET iRegistrosEncontrados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_eliminareportesrepositorio.out';
		--TRACE ON;
		
		IF pDiasVigenciaReportes IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreReporte;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombreReporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion id_registro_solicitud, nombre_reporte
				INTO iIdRegistroSolicitud, cNombreReporte
				FROM bdicnweb:sw_gs_registrosolicitud_hist
				WHERE id_status_solicitud = 3
					AND nombre_reporte IS NOT NULL
					AND DATE(fecha_atencion) <= DATE(CURRENT) - pDiasVigenciaReportes
					
			IF SUBSTR(cNombreReporte, LENGTH(cNombreReporte) - 3, 4) IN ('.zip', '.pdf') THEN
				RETURN cCodRet, cNombreReporte WITH RESUME;
				LET iRegistrosEncontrados = iRegistrosEncontrados + 1;
			
				-- ACTUALIZACIÃN DEL REGISTRO
				UPDATE bdicnweb:sw_gs_registrosolicitud_hist
				SET nombre_reporte = 'EL REPORTE HA SIDO ELIMINADO POR CADUCIDAD'
				WHERE id_registro_solicitud = iIdRegistroSolicitud;
			END IF;
	
		END FOREACH;
		
		IF iRegistrosEncontrados = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNombreReporte;
		ELIF iRegistrosEncontrados = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombreReporte;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/08/2014',
'DESCRIPCION: Consulta los archivos que han pasado de los dÃ­as activos para los reportes y que serÃ¡n eliminados',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabamtvoscancelacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pIdMotivo INTEGER, pClaveMotivo CHAR(10), pSistemaCuenta CHAR(2), pIdSolicitud INTEGER, pDescripcionMotivo CHAR(50), pStatus CHAR(1), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_afectados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabamtvoscancelacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pSistemaCuenta = '' OR pIdSolicitud IS NULL OR pDescripcionMotivo = '' 
			OR pStatus = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DEL TIPO DE OPERACION
		IF pTipoOperacion NOT IN (1, 2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DEL SISTEMA CUENTA
		IF pSistemaCuenta NOT IN ('00', '01', '03', '06') THEN
			LET cCodRet = '00077';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoOperacion = 1 THEN -- ALTA DEL REGISTRO
			IF pClaveMotivo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
		ELIF pTipoOperacion = 2 THEN -- ACTUALIZACION DEL REGISTRO
			IF pIdMotivo IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF pTipoOperacion = 1 THEN
			IF NOT EXISTS (SELECT clave_motivo FROM bdicnweb:sw_gs_motivos_cancelacion WHERE clave_motivo = pClaveMotivo) THEN
				INSERT INTO bdicnweb:sw_gs_motivos_cancelacion(id_sistema_cuenta, id_solicitud, clave_motivo, descripcion_motivo, status, user_insert, ip_insert, mac_insert)
				VALUES(pSistemaCuenta, pIdSolicitud, pClaveMotivo, pDescripcionMotivo, DECODE(pStatus, '0', 'f', '1', 't', 'f'), pUsuario, pIpUsuario, pMacAddress);
				
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
				IF iNoRegistros = 0 THEN
					LET cCodRet = '00282';
				END IF;
				
				RETURN cCodRet, iNoRegistros;
			ELSE
				LET cCodRet = '00004';
				RETURN cCodRet, iNoRegistros;
			END IF;
		ELIF pTipoOperacion = 2 THEN
			IF NOT EXISTS (SELECT id_motivo_cancelacion FROM bdicnweb:sw_gs_motivos_cancelacion WHERE id_motivo_cancelacion = pIdMotivo) THEN
				LET cCodRet = '00001';
				RETURN cCodRet, iNoRegistros;
			ELSE
				UPDATE bdicnweb:sw_gs_motivos_cancelacion
				SET id_sistema_cuenta = pSistemaCuenta,
					id_solicitud = pIdSolicitud,
					descripcion_motivo = pDescripcionMotivo,
					status = DECODE(pStatus, '0', 'f', '1', 't', '0'),
					user_update = pUsuario,
					fecha_update = CURRENT,
					ip_update = pIpUsuario,
					mac_update = pMacAddress
				WHERE id_motivo_cancelacion = pIdMotivo;
				
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
				IF iNoRegistros = 0 THEN
					LET cCodRet = '00283';
				END IF;
				
				RETURN cCodRet, iNoRegistros;
			END IF;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 07/05/2014',
'DESCRIPCION: Guardado/ActualizaciÃ³n del catalogo de motivos de cancelaciÃ³n para el gestor de solicitudes.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pClaveArea CHAR(10), pDescripcion CHAR(50), pTipoOperacion SMALLINT, pStatus CHAR(1), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_area;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bActivo BOOLEAN;
	DEFINE iIdArea INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bActivo = 'f';
	LET iIdArea = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdArea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pClaveArea = '' OR pDescripcion = '' OR pTipoOperacion IS NULL OR pStatus = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdArea;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iIdArea;
		END IF;
		
		IF pStatus NOT IN ('0', '1') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, iIdArea;
		ELSE
			LET bActivo = DECODE(pStatus, '0', 'f', '1', 't', 'f');
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdArea;
		END IF;
		
		IF pTipoOperacion = 1 THEN -- ALTA
			IF NOT EXISTS (SELECT clave_area FROM bdicnweb:sw_gs_area WHERE clave_area = pClaveArea) THEN
				INSERT INTO bdicnweb:sw_gs_area(clave_area, descripcion_area, status, user_insert, ip_insert, mac_insert)
				VALUES(pClaveArea, pDescripcion, bActivo, pUsuario, pIpUsuario, pMacAddress);
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN -- NO SE REALIZO LA INSERCION
					LET cCodRet = '00282';
					RETURN cCodRet, iIdArea;
				END IF;
				
				SELECT id_area
				INTO iIdArea
				FROM bdicnweb:sw_gs_area
				WHERE clave_area = pClaveArea;
				
				RETURN cCodRet, iIdArea;
			ELSE -- EL REGISTRO YA EXISTE
				LET cCodRet = '00004';
				RETURN cCodRet, iIdArea;
			END IF;
		ELIF pTipoOperacion = 2 THEN -- ACTUALIZACION
		
			IF NOT EXISTS (SELECT clave_area FROM bdicnweb:sw_gs_area WHERE clave_area = pClaveArea) THEN
				LET cCodRet = '00001';
				RETURN cCodRet, iIdArea;
			ELSE -- EL REGISTRO YA EXISTE
				SELECT id_area
				INTO iIdArea
				FROM bdicnweb:sw_gs_area
				WHERE clave_area = pClaveArea;
				
				UPDATE bdicnweb:sw_gs_area
				SET descripcion_area = pDescripcion,
					status = bActivo,
					user_update = pUsuario,
					fecha_update = CURRENT,
					ip_update = pIpUsuario,
				    mac_update = pMacAddress
				WHERE id_area = iIdArea;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN -- NO SE ACTUALIZO REGISTRO ALGUNO
					LET cCodRet = '00283';
					RETURN cCodRet, iIdArea;
				END IF;
				
				RETURN cCodRet, iIdArea;
			END IF;
		
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/05/2014',
'DESCRIPCION: Guarda/Actualiza un area en el catalogo para el Gestor de solicitudes',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarsolicitudesarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdArea INTEGER, pTipoOperacion SMALLINT, pPermisosPlantilla CHAR(250), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValores CHAR(15);
	DEFINE cCadena CHAR(15);
	DEFINE iIdSolicitud INTEGER;
	DEFINE bEsResponsable BOOLEAN;
	DEFINE bEsSolicitante BOOLEAN;
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE iParams SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValores = '';
	LET cCadena = '';
	LET iIdSolicitud = 0;
	LET bEsResponsable = 'f';
	LET bEsSolicitante = 'f';
	LET iNoRegsProcesados = 0;
	LET iParams = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabarsolicitudesarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdArea IS NULL OR pTipoOperacion IS NULL OR pPermisosPlantilla = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion = 1 AND EXISTS (SELECT id_area FROM bdicnweb:sw_gs_area_permisos where id_area = pIdArea) THEN
			LET cCodRet = '00004';
			RETURN cCodRet, iNoRegsProcesados;
		ELIF pTipoOperacion = 2 AND NOT EXISTS (SELECT id_area FROM bdicnweb:sw_gs_area_permisos where id_area = pIdArea) THEN
			LET cCodRet = '00001';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pPermisosPlantilla, '|')
					INTO cCadenaValores
					
					LET iParams = 0;
					FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(cCadenaValores, ',')
						INTO cCadena
						
						IF iParams = 0 THEN
							LET iIdSolicitud = cCadena::INTEGER;
							LET iParams = iParams + 1;
						ELIF iParams = 1 THEN
							LET bEsResponsable = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							LET iParams = iParams + 1;
						ELIF iParams = 2 THEN
							LET bEsSolicitante = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					SET LOCK MODE TO WAIT 3;
					IF pTipoOperacion = 1 THEN -- INSERCIÃN DE LOS VALORES
						INSERT INTO bdicnweb:sw_gs_area_permisos(id_area, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert)
						VALUES (pIdArea, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress);
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					ELIF pTipoOperacion = 2 THEN -- ACTUALIZACIÃN, QUE PUEDE INCLUIR LA INSERCIÃN DE UN REGISTRO
						UPDATE bdicnweb:sw_gs_area_permisos
							SET ind_responsable = bEsResponsable,
								ind_solicitante = bEsSolicitante,
								user_update = pUsuario,
								fecha_update = CURRENT,
								ip_update = pIpUsuario,
								mac_update = pMacAddress
						WHERE id_area = pIdArea
							AND id_solicitud = iIdSolicitud;
							
						IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
							INSERT INTO bdicnweb:sw_gs_area_permisos(id_area, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert, user_update, ip_update, mac_update, fecha_update)
							VALUES (pIdArea, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress, pUsuario, pIpUsuario, pMacAddress, CURRENT);
						END IF;
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					END IF;
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/05/2014',
'DESCRIPCION: Inserta/actualiza los registros de detalles de una plantilla de permisos por area para el gestor de solicitudes en SOCWEB',
'La cadena de entrada para la variable pPermisosPlantilla son: idSolicitud,esResponsable,esSolicitante|idSolicitud,esResponsable,esSolicitante|...|idSolicitud,esResponsable,esSolicitante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarsolicitudusuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pIdAreaUsuario INTEGER, pPermisosUsuario CHAR(250), pIpUsuario CHAR(15), pMacAddress CHAR(12))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCadenaValores CHAR(15);
	DEFINE cCadena CHAR(15);
	DEFINE iIdSolicitud INTEGER;
	DEFINE bEsResponsable BOOLEAN;
	DEFINE bEsSolicitante BOOLEAN;
	DEFINE iNoRegsProcesados INTEGER;
	DEFINE iParams SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCadenaValores = '';
	LET cCadena = '';
	LET iIdSolicitud = 0;
	LET bEsResponsable = 'f';
	LET bEsSolicitante = 'f';
	LET iNoRegsProcesados = 0;
	LET iParams = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iNoRegsProcesados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_grabarsolicitudusuarioarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdAreaUsuario IS NULL OR pTipoOperacion IS NULL OR pPermisosUsuario = '' OR pIpUsuario = '' OR pMacAddress = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion NOT IN (1,2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		IF pTipoOperacion = 1 AND EXISTS (SELECT id_area_usuario FROM bdicnweb:sw_gs_area_solicitudes where id_area_usuario = pIdAreaUsuario) THEN
			LET cCodRet = '00004';
			RETURN cCodRet, iNoRegsProcesados;
		ELIF pTipoOperacion = 2 AND NOT EXISTS (SELECT id_area_usuario FROM bdicnweb:sw_gs_area_solicitudes where id_area_usuario = pIdAreaUsuario) THEN
			LET cCodRet = '00001';
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegsProcesados;
		END IF;
		
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(pPermisosUsuario, '|')
					INTO cCadenaValores
					
					LET iParams = 0;
					FOREACH EXECUTE PROCEDURE bdicnweb:sp_split_cadena(cCadenaValores, ',')
						INTO cCadena
						
						IF iParams = 0 THEN
							LET iIdSolicitud = cCadena::INTEGER;
							LET iParams = iParams + 1;
						ELIF iParams = 1 THEN
							LET bEsResponsable = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							LET iParams = iParams + 1;
						ELIF iParams = 2 THEN
							LET bEsSolicitante = DECODE(cCadena, '0', 'f', '1', 't', 'f');
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					SET LOCK MODE TO WAIT 3;
					IF pTipoOperacion = 1 THEN -- INSERCIÃN DE LOS VALORES
						INSERT INTO bdicnweb:sw_gs_area_solicitudes(id_area_usuario, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert)
						VALUES (pIdAreaUsuario, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress);
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					ELIF pTipoOperacion = 2 THEN -- ACTUALIZACIÃN, QUE PUEDE INCLUIR LA INSERCIÃN DE UN REGISTRO
						UPDATE bdicnweb:sw_gs_area_solicitudes
							SET ind_responsable = bEsResponsable,
								ind_solicitante = bEsSolicitante,
								user_update = pUsuario,
								fecha_update = CURRENT,
								ip_update = pIpUsuario,
								mac_update = pMacAddress
						WHERE id_area_usuario = pIdAreaUsuario
							AND id_solicitud = iIdSolicitud;
							
						IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
							INSERT INTO bdicnweb:sw_gs_area_solicitudes(id_area_usuario, id_solicitud, ind_responsable, ind_solicitante, user_insert, ip_insert, mac_insert, user_update, ip_update, mac_update, fecha_update)
							VALUES (pIdAreaUsuario, iIdSolicitud, bEsResponsable, bEsSolicitante, pUsuario, pIpUsuario, pMacAddress, pUsuario, pIpUsuario, pMacAddress, CURRENT);
						END IF;
						
						LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
					END IF;
					
			END FOREACH;
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegsProcesados;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 15/05/2014',
'DESCRIPCION: Inserta/actualiza los registros de detalles de permisos de un usuario para el gestor de solicitudes en SOCWEB',
'La cadena de entrada para la variable pPermisosUsuario son: idSolicitud,esResponsable,esSolicitante|idSolicitud,esResponsable,esSolicitante|...|idSolicitud,esResponsable,esSolicitante',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_registrocomentariosolicitud(pUsuario CHAR(8),	pIdFuncion CHAR(10), pIdReg INTEGER, pComentario CHAR(200), pTipoGestor CHAR(1))
	RETURNING CHAR(5) AS codret,
				INTEGER AS idxReg;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE iIdx INTEGER;
	DEFINE iConsecutivo INTEGER;
	DEFINE iFolio BIGINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bInTransaction='f';
	LET iIdx = 0;
	LET iConsecutivo = 0;
	LET iFolio = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdx;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-691)
			ROLLBACK;
			LET cCodRet = '00284';
			
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iIdx;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_registrocomentariosolicitud.out';
		--TRACE ON;
		
		---VALIDACION DE DATOS REQUERIDOS 
		IF pUsuario = '' OR pIdFuncion = '' OR pIdReg IS NULL OR pTipoGestor = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdx;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet, iIdx;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdx;
		END IF;
		
		-- CALCULAMOS CONSECUTIVO
		IF((SELECT MAX(consecutivo) FROM bdicnweb:sw_gs_comentarios WHERE id_registro_solicitud = pIdReg)IS NULL) THEN
			LET iConsecutivo=1;
		ELSE 
			SELECT MAX(consecutivo)
			INTO iConsecutivo
			FROM bdicnweb:sw_gs_comentarios WHERE id_registro_solicitud = pIdReg;	
			LET iConsecutivo=iConsecutivo+1;
		END IF	
		
		-- OBTENEMOS FOLIO DEL REGISTRO
		SET ISOLATION TO DIRTY READ;
		SELECT folio_solicitud 
		INTO iFolio 
		FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdReg;

		
		BEGIN WORK;

		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdicnweb:sw_gs_comentarios(id_registro_solicitud,folio_solicitud, tipo_gestor, consecutivo, comentario, usuario) 
		VALUES(pIdReg,iFolio, DECODE(pTipoGestor,'R','RESPONSABLE','S','SOLICITANTE'), iConsecutivo, pComentario, pUsuario);
		
		IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
			LET cCodRet = '00236';			ROLLBACK WORK;
			RETURN cCodRet, iIdx;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 1 THEN
			LET iIdx = DBINFO('sqlca.sqlerrd1');
		END IF;
		
		COMMIT;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iIdx;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 02/06/2014',
'DESCRIPCION: Inserta comentario de la solicitud al gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_totalregbusquedasolicitudes(pUsuario CHAR(8),pIdFuncion CHAR(10), pTipoGestor CHAR(1),pFechaDesde DATE, pFechaHasta DATE,
													  pTipoCta CHAR(2), pSolicitud INTEGER, pAreaResSol INTEGER, pUsuarioResSol CHAR(8), pStatus INTEGER,
													  pCliente CHAR(20),pCuenta CHAR(20),pIsArea CHAR(1))
	RETURNING CHAR(5) AS codret,
			  INTEGER AS total;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE iArea INTEGER;
	
	DEFINE cCmd1 CHAR(5000);
	DEFINE cCmd2 CHAR(2500);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	LET iNoRegistros = 0;
	
	LET iArea = 0;
	
	LET cCmd1 = '';
	LET cCmd2 = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_totalregbusquedasolicitudes.out';
		--TRACE ON;
		
		---VALIDACION DE CAMPOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoGestor = '' OR pFechaDesde = '' OR pFechaHasta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		IF pTipoGestor NOT IN ('S','R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
				
		IF pTipoGestor = 'S' THEN
			--- CONSTRUCCCION DE CONDICIONES
			IF pIsArea = 't' THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_solicitante = "||iArea||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			ELSE
				LET cCmd2="a.usuario_solicitante = "||pUsuario||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			END IF;
			
			IF pTipoCta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.id_sistema_cuenta = '"|| TRIM(pTipoCta) ||"'";
			END IF;
			
			IF pSolicitud IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_solicitud = "|| pSolicitud ||"";
			END IF;
			
			IF pAreaResSol IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area_responsable = "|| pAreaResSol ||"";
			END IF;
			
			IF pUsuarioResSol <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.usuario_responsable = '"|| TRIM(pUsuarioResSol) ||"'";
			END IF;
			
			IF pStatus IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_status_solicitud = "|| pStatus ||"";
			END IF;
			
			IF pCliente <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cliente = '"|| TRIM(pCliente) ||"'";
			END IF;
			
			IF pCuenta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cuenta = '"|| TRIM(pCuenta) ||"'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT COUNT(*) ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM ";
			LET cCmd1=""||TRIM(cCmd1)||" (SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||"";
			LET cCmd1=""||TRIM(cCmd1)||"  UNION ";
			LET cCmd1=""||TRIM(cCmd1)||"  SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_responsable=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_responsable)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||")";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iNoRegistros;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			RETURN cCodRet,iNoRegistros;
				
		END IF;
		
		IF pTipoGestor = 'R' THEN
			--- CONSTRUCCCION DE CONDICIONES
			IF pIsArea = 't' THEN
				---VERIFICAMOS A QUE AREA PERTENECE EL USUARIO
				SET ISOLATION TO DIRTY READ;
				SELECT id_area
				INTO iArea
				FROM bdicnweb:sw_gs_area_usuario
				WHERE id_usuario = pUsuario;
				LET cCmd2="a.id_area_responsable = "||iArea||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			ELSE
				LET cCmd2="a.usuario_responsable = "||pUsuario||" AND a.status = 't' AND (DATE(a.fecha_solicitud) BETWEEN '"||pFechaDesde||"' AND '"||pFechaHasta||"')";
			END IF;
			
			IF pTipoCta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND c.id_sistema_cuenta = '"|| TRIM(pTipoCta) ||"'";
			END IF;
			
			IF pSolicitud IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_solicitud = "|| pSolicitud ||"";
			END IF;
			
			IF pAreaResSol IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_area_solicitante = "|| pAreaResSol ||"";
			END IF;
			
			IF pUsuarioResSol <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.usuario_solicitante = '"|| TRIM(pUsuarioResSol) ||"'";
			END IF;
			
			IF pStatus IS NOT NULL THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.id_status_solicitud = "|| pStatus ||"";
			END IF;
			
			IF pCliente <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cliente = '"|| TRIM(pCliente) ||"'";
			END IF;
			
			IF pCuenta <> '' THEN
				LET cCmd2=""||TRIM(cCmd2)||" AND a.cuenta = '"|| TRIM(pCuenta) ||"'";
			END IF;
			
			--- CONSULTA
			LET cCmd1="SELECT COUNT(*) ";
			LET cCmd1=""||TRIM(cCmd1)||" FROM ";
			LET cCmd1=""||TRIM(cCmd1)||" (SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||"";
			LET cCmd1=""||TRIM(cCmd1)||"  UNION ";
			LET cCmd1=""||TRIM(cCmd1)||"  SELECT a.id_registro_solicitud";
			LET cCmd1=""||TRIM(cCmd1)||"  FROM (((((bdicnweb:sw_gs_registrosolicitud_hist a LEFT JOIN bdicnweb:sw_gs_catstatussolicitud b ON a.id_status_solicitud = b.id_status_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_solicitudes c ON a.id_solicitud=c.id_solicitud)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_area d ON a.id_area_solicitante=d.id_area)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdicnweb:sw_gs_motivos_cancelacion e ON a.id_motivo_cancelacion=e.id_motivo_cancelacion)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_ejecut f ON f.ejecutivo=a.usuario_solicitante)";
			LET cCmd1=""||TRIM(cCmd1)||"  LEFT JOIN bdinteg:si_cliente g ON g.numcte=a.cliente";
			LET cCmd1=""||TRIM(cCmd1)||"  WHERE "||TRIM(cCmd2)||")";
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			
			FETCH selectQryCur INTO iNoRegistros;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,iNoRegistros;
			END IF;
			
			RETURN cCodRet,iNoRegistros;
				
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 10/06/2014',
'DESCRIPCION: Obtiene el total de registros de busqueda de solicitudes para gestor de operaciones en SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_abono_ref(pUsuario     char(10),
                                         pIdFuncion   char(10),
                                         pTransacc    CHAR(4),
                                         pCuenta      CHAR(20),
                                         pDocto       INTEGER,
                                         pMto_tot     MONEY(14,2),
                                         pReferencia  CHAR(40))
        RETURNING CHAR(5) as codret,
                  CHAR(16) as Folio_usu;

DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE cUsuario       CHAR(8);
DEFINE cTransuc       CHAR(4);
DEFINE cFolio_suc     CHAR(16);
DEFINE mMto_firme     MONEY(14,2);
DEFINE mMto_sbc       MONEY(14,2);
DEFINE mMto_rem       MONEY(14,2);
DEFINE sDias_ret      SMALLINT;
DEFINE cDivisa        CHAR(2);
DEFINE cNum_tarjeta   CHAR(16);
DEFINE cUsuautoriza   CHAR(8);

DEFINE dHora          DATETIME HOUR TO SECOND;
DEFINE cHora          CHAR(6);

LET cCodRet = '00000';
LET iSqlErr = 0;

LET cEmpresa = '001';
LET cTransuc = "0000";
LET cFolio_suc = pUsuario;

LET mMto_firme = pMto_tot;
LET mMto_sbc = 0;
LET mMto_rem = 0;
LET sDias_ret = 0;
LET cDivisa = "01";
LET cNum_tarjeta = "";
LET cUsuautoriza = "";

LET cHora = CAST(SUBSTR(CURRENT,12,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,15,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,18,2) AS CHAR(2));
LET cFolio_suc = TRIM(cFolio_suc) || cHora;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFolio_suc;
                END IF;
        END EXCEPTION;

        IF  pDocto = ''
        THEN
                LET pDocto = 0;
        END IF;
        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR ptransacc = ''
         OR pCuenta = ''
---------OR pDocto = ''
         OR pMto_tot = 0
---------OR pReferencia = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cFolio_suc;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cFolio_suc;
        END IF;

	SET ISOLATION TO DIRTY READ;
        SELECT sucursal
          INTO cSucursal
          FROM bdinteg:"informix".si_ejecut
         WHERE ejecutivo = pUsuario;

        SELECT divisa
          INTO cDivisa
          FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
         WHERE mc.empresa = cEmpresa
           AND cuenta = pCuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        EXECUTE PROCEDURE bdicheq:"informix".abono_ref(cEmpresa,
                                                        cSucursal,
                                                        pUsuario,
                                                        pTransacc,
                                                        cTransuc,
                                                        cFolio_suc,
                                                        pCuenta,
                                                        pDocto,
                                                        pMto_tot,
                                                        mMto_firme,
                                                        mMto_sbc,
                                                        mMto_rem,
                                                        sDias_ret,
                                                        cDivisa,
                                                        pReferencia,
                                                        cNum_tarjeta,
                                                        cUsuautoriza)
                INTO cCodRet;

        IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '110' THEN
                LET cCodRet = '00003';
        END IF;
        IF cCodRet = '301' THEN
                LET cCodRet = '00389'; --  La cuenta esta bloqueada no permite realizar abonos. Favor de verificar
        END IF;

        RETURN cCodRet, cFolio_suc;

END;

END PROCEDURE
DOCUMENT 'MODIFICO: Rodolfo Conde Flores',
'FECHA: 13/10/2014',
'DESCRIPCION: Se anexa mapeo de codigos de retorno para la aplicaciÃ³n SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargo_ref(pUsuario     char(10),
                                         pIdFuncion   char(10),
                                         pTransacc    CHAR(4),
                                         pCuenta      CHAR(20),
                                         pCheque      INTEGER,
                                         pMto_tot     MONEY(14,2),
                                         pReferencia  CHAR(40))
        RETURNING CHAR(5) as codret,
                  CHAR(16) as Folio_usu;

DEFINE cCodRet CHAR(5);

DEFINE iSqlErr INT;

DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(4);
DEFINE cUsuario       CHAR(8);
DEFINE cTransuc       CHAR(4);
DEFINE cFolio_suc     CHAR(16);
DEFINE mMto_firme     MONEY(14,2);
DEFINE mMto_sbc       MONEY(14,2);
DEFINE mMto_rem       MONEY(14,2);
DEFINE sDias_ret      SMALLINT;
DEFINE cDivisa        CHAR(2);
DEFINE cNum_tarjeta   CHAR(16);
DEFINE cUsuautoriza   CHAR(8);

DEFINE dHora          DATETIME HOUR TO SECOND;
DEFINE cHora          CHAR(6);

DEFINE vTranret         CHAR(4);
DEFINE vFechoy          DATE;
DEFINE vSdodisp         MONEY(14,2);
DEFINE vMontoret        MONEY(14,2);

LET vTranret = "";
LET vFechoy = TODAY;
LET vSdodisp = 0;
LET vMontoret = 0;

LET cCodRet = '00000';
LET iSqlErr = 0;

LET cEmpresa = '001';
LET cTransuc = "0000";
LET cFolio_suc = pUsuario;

LET mMto_firme = pMto_tot;
LET mMto_sbc = 0;
LET mMto_rem = 0;
LET sDias_ret = 0;
LET cDivisa = "01";
LET cNum_tarjeta = "";
LET cUsuautoriza = "";

LET cHora = CAST(SUBSTR(CURRENT,12,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,15,2) AS CHAR(2)) ||
            CAST(SUBSTR(CURRENT,18,2) AS CHAR(2));
LET cFolio_suc = TRIM(cFolio_suc) || cHora;

SET ISOLATION TO DIRTY READ;

BEGIN

        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cFolio_suc;
                END IF;
        END EXCEPTION;

        IF  pCheque = ''
        THEN
                LET pCheque = 0;
        END IF;
        IF  pUsuario = ''
         OR pIdFuncion = ''
         OR ptransacc = ''
         OR pCuenta = ''
---------OR pCheque = ''
         OR pMto_tot = 0
---------OR pReferencia = ''
        THEN
                LET cCodRet = '00003';
                RETURN cCodRet, cFolio_suc;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,
                                                                        pIdFuncion)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, cFolio_suc;
        END IF;

        SELECT sucursal
          INTO cSucursal
          FROM bdinteg:"informix".si_ejecut
         WHERE ejecutivo = pUsuario;

        SELECT divisa
          INTO cDivisa
          FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
         WHERE mc.empresa = cEmpresa
           AND cuenta = pCuenta
           AND mc.empresa = pr.empresa
           AND mc.producto = pr.producto;

        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(cEmpresa,
                                                        cSucursal,
                                                        pUsuario,
                                                        pTransacc,
                                                        cTransuc,
                                                        cFolio_suc,
                                                        pCuenta,
                                                        pCheque,
                                                        pMto_tot,
                                                        cDivisa,
                                                        pReferencia,
                                                        cNum_tarjeta,
                                                        cUsuautoriza)
                INTO    cCodRet,
                        vTranret,
                        vFechoy,
                        vSdodisp,
                        vMontoret;

        IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '110' THEN
                LET cCodRet = '00003';
        END IF;
		IF cCodRet = '200' THEN
                LET cCodRet = '00390'; -- LA CUENTA NO PERMITE REALIZAR CARGOS. FAVOR DE VERIFICAR
        END IF;
		IF cCodRet = '400' THEN
                LET cCodRet = '00391'; -- LA CUENTA TIENE FONDOS INSUFICIENTES
        END IF;
		IF cCodRet = '300' THEN
                LET cCodRet = '00392'; -- LA CUENTA ESTA BLOQUEADA NO PERMITE REALIZAR CARGOS. FAVOR DE VERIFICAR
        END IF;

        RETURN cCodRet, cFolio_suc;

END;

END PROCEDURE
DOCUMENT 'MODIFICO: Rodolfo Conde Flores',
'FECHA: 13/10/2014',
'DESCRIPCION: Se anexa mapeo de codigos de retorno para la aplicaciÃ³n SOCWEB',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sw_ro_borraimagenes(pUsuarioC CHAR(8),
                                                                                pIdFuncionC CHAR(10), 
                                                                                pIdOficio INT,
                                                                                pIdBusqueda INT,
                                                                                pIdCte INT, 
                                                                                pNumCliente CHAR(20), 
                                                                                pTipoCuenta CHAR(2),
                                                                                pNumCuenta CHAR(20))
        RETURNING CHAR(5) AS codret,
                INT AS regs_borrados
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iNoRegistros INT;
        DEFINE cStatus CHAR(1);
        DEFINE cStatus2 CHAR(1);
		DEFINE cNumCtaAux CHAR(20);
		DEFINE iNoRegistrosAux INT;
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = -1;
		LET cNumCtaAux = '';
		LET iNoRegistrosAux = -1;
		
        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, iNoRegistros;
                        END IF;
                END EXCEPTION;
				
				--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_ro_borraimagenes.sql';
				--TRACE ON;
				
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pIdFuncionC) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iNoRegistros;
                END IF;
                --VALIDACION DE CAMPOS REQUERIDOS
                IF pUsuarioC = ''OR 
                        pIdFuncionC = ''OR 
                        pIdOficio = ''OR 
                        pIdBusqueda = ''OR 
                        pIdCte = ''OR 
                        pTipoCuenta = ''OR 
                        pNumCliente = ''OR 
                        pNumCuenta = '' 
                        then LET cCodRet = '00003';
                                RETURN cCodRet, iNoRegistros;
                END IF;
				
                IF pTipoCuenta NOT IN('01', '03', '06', '00') THEN
                        LET cCodRet = '00048'; -- El tipo de sistema busqueda es incorrecto
                        RETURN cCodRet, iNoRegistros;
                END IF;
				
				DELETE FROM sw_ro_cteexp
				WHERE id_oficio = pIdOficio
					AND id_busqueda = pIdBusqueda
					AND id_resulcte = pIdCte
					AND tipo_cuenta = pTipoCuenta
					AND numcte = pNumCliente
					AND cuenta = pNumCuenta;
						
                IF pNumCuenta = '99999999999' THEN
					UPDATE sw_ro_resulcte SET ind_expdig = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio 
							AND id_busqueda = pIdBusqueda 
							AND id_resulcte = pIdCte 
							AND certifica_imagenes = '1';
				   
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte 
							AND id_busqueda = pIdBusqueda 
							AND id_oficio = pIdOficio;              
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio 
							AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                ELSE
					-- Se actualiza en estatus en la tabla de cuentas
					UPDATE sw_ro_ctecta SET certifica_imagenes = '0' 
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio AND cuenta = pNumCuenta;
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' end
					INTO cStatus
					FROM sw_ro_ctecta
					WHERE id_oficio = pIdOficio AND id_busqueda = pIdBusqueda AND id_resulcte = pIdCte AND certifica_imagenes = '1';
					
					-- Se actualiza en estatus en la tabla de clientes
					UPDATE sw_ro_resulcte SET certifica_imagenes = cStatus
					WHERE id_resulcte = pIdCte AND id_busqueda = pIdBusqueda AND id_oficio = pIdOficio;             
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(certifica_imagenes) > 0 THEN '1' ELSE '0' END 
					INTO cStatus
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND certifica_imagenes = '1';
					
					SET ISOLATION TO DIRTY READ;
					SELECT CASE WHEN COUNT(ind_expdig) > 0 THEN '1' ELSE '0' end
					INTO cStatus2
					FROM sw_ro_resulcte
					WHERE id_oficio = pIdOficio AND ind_expdig = '1';
					LET cStatus = cStatus + cStatus2;
					IF cStatus > 0 THEN
							LET cStatus = '1';
					END IF;
					
					-- ActualizaciÃ³n en maeoficios
					UPDATE sw_ro_maeoficios
					SET certifica_imagenes = cStatus
					WHERE id_oficio = pIdOficio;
                END IF;
                LET iNoRegistros = dbinfo('sqlca.sqlerrd2');
                RETURN cCodRet, iNoRegistros;
        END
END PROCEDURE;
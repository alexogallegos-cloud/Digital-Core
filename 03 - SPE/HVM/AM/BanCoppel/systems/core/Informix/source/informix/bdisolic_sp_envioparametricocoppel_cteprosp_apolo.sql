CREATE PROCEDURE "informix".sp_envioparametricocoppel_cteprosp_apolo(p_Empresa CHAR(3), p_NumCte VARCHAR(20), p_NumSolicitud CHAR(20), pTipoCliente INTEGER)

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) AS CodigoRetorno,
	LVARCHAR(15000) AS TramaSalida;

	--DEFINICION DE VARIABLES--
	DEFINE sql_err			INTEGER;
	DEFINE vCodRet			CHAR(5);
	DEFINE cResidencia		CHAR(2);
	DEFINE iValor			MONEY(14,2);
	DEFINE cFecAnt			CHAR(10);
	DEFINE cNumSolSIC		CHAR(20);
	DEFINE iLogFinal		INTEGER;
	DEFINE v_Cadena			LVARCHAR(1000);
	DEFINE v_Cadena2		LVARCHAR(10000);
	DEFINE v_Cadena3		LVARCHAR(1000);

	DEFINE cEdoCiv 			CHAR(2);
	DEFINE cTimOcupacion    CHAR(2);
	DEFINE sClave       	SMALLINT;
	DEFINE cSubClave    	CHAR(5); --SubClave
	DEFINE iValorSeguridad	INTEGER; --Valor Seguridad
	DEFINE iVersion			INTEGER; --Version
	DEFINE sNumCd       	SMALLINT;
	DEFINE sNumCol   		SMALLINT;
	DEFINE cTipoCasa 		CHAR(1); --Tipo de casa
	DEFINE cGenero			CHAR(1); --Sexo
	DEFINE cEdoCivil		CHAR(1); --Estado Civil
	DEFINE cFecNac			CHAR(10);
	DEFINE cTiempReside 	CHAR(10);
	DEFINE sHabDom		    SMALLINT;
	DEFINE cEscolaridad 	CHAR(1); --Nivel de Escolaridad
	DEFINE sDependiente 	SMALLINT;
	DEFINE sNivIngreso  	SMALLINT;
	DEFINE cPuesto			CHAR(1); --Puesto
	DEFINE sOpcionPuesto 	SMALLINT;
	DEFINE sSubOpcioPuesto 	SMALLINT;
	DEFINE cTiempoDesc  	CHAR(10);
	DEFINE cTimEdoCiv   	CHAR(10);
	DEFINE cFecHoy      	CHAR(10);
	DEFINE sMesesAntiguedad SMALLINT;
	DEFINE sPeorPago		SMALLINT;
	DEFINE sNumSols			SMALLINT;
	DEFINE iCteBCPL			INTEGER; --CLienteBCPL
	DEFINE iNumCred			INT8; 	 --NumeroCredito
	DEFINE cInstitucion 	CHAR(2); --TipoConsulta
	--INC 27-03-2019
	DEFINE cFolioConsul 	CHAR(11); --Folio Consulta
	DEFINE cFechaSIC		CHAR(10);
	DEFINE iIngMensual  	INTEGER; --Ingreso Mensual
	DEFINE cResSIC      	LVARCHAR(10000); --Respuesta SIC
	DEFINE cVar01			CHAR(1); --Variable 1
	DEFINE cVar02			CHAR(1); --Variable 2
	DEFINE cVar03			CHAR(1); --Variable 3
	DEFINE cVar04			CHAR(1); --Variable 4
	DEFINE cVar05			CHAR(1); --Variable 5
	DEFINE iVar06			INTEGER; --Variable 6
	DEFINE iVar07			INTEGER; --Variable 7
	DEFINE iVar08			INTEGER; --Variable 8
	DEFINE iVar09			INTEGER; --Variable 9
	DEFINE iVar10			INTEGER; --Variable 10
	DEFINE dtFechSol		DATE;
	DEFINE iRenglonMinimo	INT8;
	--dsb-07/11/2012
	DEFINE iCiudadBanco INTEGER;
	DEFINE cFolioSucursal CHAR(4);

	DEFINE cNumCred			CHAR(12); 	 --DSB-22/12/2018

-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
    DEFINE vcasa,vcelular   CHAR(1);
    DEFINE vtipomovimiento  CHAR(1);
    DEFINE vnumsolicitudref CHAR(20);
    DEFINE ref1numerociudad, ref1numerocolonia, ref2numerociudad, ref2numerocolonia INTEGER;
-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
	--RQM 18 055-4y5 Generacion de OS Calle a Clientes Prospecto.pdf
	DEFINE iCiudad			INTEGER;
	DEFINE iColonia			INTEGER;
	DEFINE cSucursal		CHAR(4);
	DEFINE dFechaCaptura	DATE;
	DEFINE cCaracter		CHAR(1);
	DEFINE cYears			CHAR(2);
	DEFINE cIngresoMensualParam			CHAR(20);
	DEFINE mIngresoMensual				MONEY(17);
	DEFINE vcTiempoDeEstadoCivilYears	VARCHAR(80);
	DEFINE cYearsEdoCivilYears			CHAR(2);
	DEFINE vcTiempoDeEstadoCivilMonth   VARCHAR(80);
	DEFINE cEdoCivilMonth				CHAR(2);
	DEFINE cParentesco					CHAR(1);
	DEFINE sTipoTel						SMALLINT;
	DEFINE iIdEmpCob					INTEGER;
	DEFINE cNumCte						CHAR(9);
	DEFINE cCteTitular					CHAR(3);
	DEFINE cFlagProspecto				CHAR(1);
	DEFINE iCiudadReferencia1			INTEGER;
	DEFINE sNumCdCiudadReferencia1		SMALLINT;
	DEFINE sNumCdCiudadReferencia2		SMALLINT;
	DEFINE iCiudadReferencia2			INTEGER;
	DEFINE iNumCdCoppelCiudadReferencia2 INTEGER;
	DEFINE iVariable9					INTEGER;
	DEFINE iVariable10					INTEGER;
	DEFINE cRespPreg1					CHAR(1);
	DEFINE cRespPreg2					CHAR(1);
	DEFINE cRespPreg3					CHAR(1);
	DEFINE cRespPreg4					CHAR(1);
	DEFINE cRespPreg5					CHAR(1);
	DEFINE cRespPreg6					CHAR(1);
	DEFINE cRespPreg7					CHAR(1);
	DEFINE cRespPreg8					CHAR(1);
	DEFINE cRespPreg9					CHAR(1);
	DEFINE cResp2Preg9					CHAR(1);
	DEFINE cRespPreg10					CHAR(1);
	DEFINE cTipoSolicitud				CHAR(1);	
	DEFINE cDomicilioGeolocalizado		CHAR(1);	
	DEFINE iVariable16					INTEGER;
	DEFINE sCiclo						SMALLINT;
	DEFINE sElemento					SMALLINT;
	DEFINE iNumCdCoppel					INTEGER;
	DEFINE cPuntualidadconyoref1		CHAR(1);
	DEFINE cPuntualidadconyoref2		CHAR(1);
	DEFINE iNumHabDomTrabajan			INTEGER;
	DEFINE cYearsOcupacion				CHAR(2);
	DEFINE vcTiempoDeOcupacion			VARCHAR(80);
	DEFINE cNumCtePros					CHAR(10);
	DEFINE iVariable16Titular			INTEGER;
	DEFINE cNumCteProsTitular 			CHAR(10);
	DEFINE cRespPreg1Titular 			CHAR(1);
	DEFINE cRespPreg2Titular 			CHAR(1);
	DEFINE cRespPreg3Titular 			CHAR(1);
	DEFINE cRespPreg4Titular 			CHAR(1);
	DEFINE cRespPreg5Titular 			CHAR(1);
	DEFINE cRespPreg6Titular 			CHAR(1);
	DEFINE cRespPreg7Titular 			CHAR(1);
	DEFINE cRespPreg8Titular 			CHAR(1);
	DEFINE cRespPreg9Titular 			CHAR(1);
	DEFINE cResp2Preg9Titular 			CHAR(1);
	DEFINE cRespPreg10Titular 			CHAR(1);
	DEFINE cTipoSolicitudTitular		CHAR(1);
	DEFINE cDomicilioGeolocalizadoTitular	CHAR(1); 
	DEFINE dtFechaHoy					DATE;
--RQM 18 055-4y5 Generacion de OS Calle a Clientes Prospecto.pdf
--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 'DSB-03/02/2016 INICIO
	DEFINE cCasa 				CHAR(10);
	DEFINE iCalle 				INTEGER;
	DEFINE cRefCoppel1			CHAR(20);
	DEFINE cRefCoppel2			CHAR(20);
	DEFINE cCtePresentoIfe		CHAR(1);
	DEFINE cCtePresentoCompDom	CHAR(1);
	DEFINE sCiudadIfe			SMALLINT;
	DEFINE iColoniaIfe			INTEGER;
	DEFINE iCalleIfe			INTEGER;
	DEFINE cCasaIfe				CHAR(10);
	DEFINE cInteriorIfe			CHAR(10);
	DEFINE iNumSucursal			INTEGER;
	DEFINE iSecuencia			INTEGER;
	DEFINE cEnviaOs				CHAR(1);
	DEFINE dFechaHoy			DATE;
	DEFINE iSecRef1				INTEGER;
	DEFINE iSecMenor			INTEGER;
--IPCB 13sep2016
	DEFINE id_respuesta			INT8;

	DEFINE cGeoCli 		CHAR(20); --387 validar puntos de coordenada cte
	DEFINE cLatitud		CHAR(20); --387 validar puntos de coordenada cte
	DEFINE cLongitud	CHAR(20); --387 validar puntos de coordenada cte
	DEFINE cFLagDomAlta	CHAR(1); --387 validar domicilio cte
	DEFINE cFolioMovil  CHAR(20); --387 validar geolocalizacion
	DEFINE i			INTEGER;


	DEFINE cNumSolCoppel						CHAR(20);	
	DEFINE cCodRet								CHAR(6);	
	DEFINE num_producto_bco						CHAR(5); 	
	DEFINE status_solicitud_bco 				CHAR(3);	
	DEFINE monto_lc_bco 						INTEGER;	
	DEFINE fecha_resp_bco 						CHAR (11);	
	DEFINE cOrigenSolic							CHAR(1);	
	--VARIABLES A FUTURO RQM-598.1
	DEFINE cFlag_ProductoCoppel					CHAR(1); 
	DEFINE cFlag_MotosCoppel                    CHAR(1); 
	DEFINE cCtepresentoCompIng                  CHAR(1); 
	DEFINE iTelefonoClienteLada                 INTEGER; -- antes iCampoFuturo4 ahora se renombra iTelCasaLada  -38829-RQM 09 655 Reingenieria de clientes nuevos MX
    DEFINE iTelefonoCliente                     INTEGER; -- antes iCampoFuturo5 ahora se renombra iTelCasaNum  -38829-RQM 09 655 Reingenieria de clientes nuevos MX
    DEFINE iCelularClienteLada                  INTEGER; -- antes iCampoFuturo6 ahora se renombra iTelCelular  -38829-RQM 09 655 Reingenieria de clientes nuevos MX
    DEFINE iCelularCliente                      INTEGER; -- antes iCampoFuturo7 ahora se renombra iTelCelularNum  -38829-RQM 09 655 Reingenieria de clientes nuevos MX
	DEFINE iCampoFuturo8                        INTEGER;
	DEFINE iCampoFuturo9                        INTEGER;
	DEFINE iCampoFuturo10                       INTEGER;
	
	--
	DEFINE vContador0 INTEGER;
	DEFINE vContador1 INTEGER;
	DEFINE vContador2 INTEGER;
	DEFINE vContador3 INTEGER;
	DEFINE vContador4 INTEGER;
	DEFINE vContador5 INTEGER;
	DEFINE vContador6 INTEGER;
	DEFINE vContador7 INTEGER;
	DEFINE vContador8 INTEGER;
	DEFINE vContador9 INTEGER;
	DEFINE vContador10 INTEGER;
	DEFINE vContador11 INTEGER;
	DEFINE vContador12 INTEGER;
	DEFINE vContador13 INTEGER;
	DEFINE vContador14 INTEGER;
	DEFINE vContador15 INTEGER;
	DEFINE vContador16 INTEGER;
	DEFINE vContador17 INTEGER;
	DEFINE vContador18 INTEGER;
	DEFINE vContador19 INTEGER;
	DEFINE vContador20 INTEGER;
	DEFINE vContador21 INTEGER;
	
	DEFINE cCanalSol CHAR(1); -- Apolo
	DEFINE cEnvioParam char(1);
	DEFINE vTelCasa CHAR(10);
	DEFINE vTelCasaLada	CHAR(2);	
	DEFINE vTelCasaNum	CHAR(8);
	DEFINE vTelCelular	CHAR(10);
	DEFINE vTelCelularLada	CHAR(2);
	DEFINE vTelCelularNum	CHAR(8);

--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 FIN
	--INICIALIZACION DE VARIABLES--
	LET sql_err 	 	= 0;
	LET vCodRet 	 	= '00000';
	LET cResidencia  	= " ";
	LET ivalor		 	= 0;
	LET cFecAnt      	= " ";
	LET cNumSolSIC   	= " ";
	LET iLogFinal 	 	= 0;
	LET v_Cadena	 	= " ";
	LET v_Cadena2	 	= " ";
	LET v_Cadena3	 	= " ";
	LET cEdoCiv		 	= " ";
	LET cTimOcupacion 	= " ";
	LET sClave       	= 90;
	LET cSubClave    	=" ";
	LET iValorSeguridad = 0;
	LET iVersion	 	= 0;
	LET sNumCd       	= 0;
	LET sNumCol 	 	= 0;
	LET cTipoCasa 	 	= " ";
	LET cGenero		 	= " ";
	LET cEdoCivil	 	= " ";
	LET cFecNac		 	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET cTiempReside 	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET sHabDom      	= 0;
	LET cEscolaridad 	= " ";
	LET sDependiente 	= 0;
	LET sNivIngreso  	= 0;
	LET cPuesto		 	= "0";
	LET sOpcionPuesto 	= 0;
	LET sSubOpcioPuesto = 0;
	LET cTiempoDesc  	= TO_CHAR(CURRENT,'%Y-%m-%d');
	--LET cTimEdoCiv   	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET cTimEdoCiv = "1900-01-01"; --INC23426
	LET cFecHoy      	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET sMesesAntiguedad = -1;
	LET sPeorPago	 	= -1;
	LET sNumSols     	= -1;
	LET iCteBCPL     	= 0;
	LET iNumCred	 	= 0;
	LET cInstitucion 	= "NC";
	LET cFolioConsul 	= " ";
	LET cFechaSIC    	= TO_CHAR(CURRENT,'%Y-%m-%d');
	LET iIngMensual  	= 0;
	LET cResSIC      	= " ";
	LET cVar01		 	= " ";
	LET cVar02		 	= " ";
	LET cVar03		 	= " ";
	LET cVar04		 	= " ";
	LET cVar05		 	= " ";
	LET iVar06		 	= 0;
	LET iVar07		 	= 0;
	LET iVar08		 	= 0;
	LET iVar09		 	= 0;
	LET iVar10		 	= 0;
	LET dtFechSol		=DATE(1);
	LET iRenglonMinimo = 0;
	--dsb-07/11/2012
	LET iCiudadBanco = 0;
	LET cFolioSucursal = "";

-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
    LET vcasa            = " ";
    LET vcelular         = " ";
    LET vtipomovimiento  = " ";
    LET vnumsolicitudref = " ";
    LET ref1numerociudad = 0;
    LET ref1numerocolonia = 0;
    LET ref2numerociudad = 0;
    LET ref2numerocolonia = 0;
-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
	--RQM 18 055-4y5 Generacion de OS Calle a Clientes Prospecto.pdf
	LET iCiudad			= 0;
	LET iColonia	    = 0;
	LET cSucursal		= " ";
	LET dFechaCaptura   = DATE(1);
	LET	cCaracter		= " ";
	LET cYears			= " ";
	LET cIngresoMensualParam	= " ";
	LET mIngresoMensual 		= 0;
	LET vcTiempoDeEstadoCivilYears = " ";
	LET cYearsEdoCivilYears = " ";
	LET vcTiempoDeEstadoCivilMonth = " ";
	LET cEdoCivilMonth			= " ";
	LET cParentesco				= " ";
	LET sTipoTel				= 0;
	LET iIdEmpCob				= 0;
	LET cNumCte					= " ";
	LET cCteTitular				= " ";
	LET cFlagProspecto			= " ";
	LET iCiudadReferencia1		= 0;
	LET sNumCdCiudadReferencia1 = 0;
	LET sNumCdCiudadReferencia2	= 0;
	LET iCiudadReferencia2		= 0;
	LET iNumCdCoppelCiudadReferencia2	= 0;
	LET iVariable9				= 0;
	LET cRespPreg1				= " ";
	LET cRespPreg2				= " ";
	LET cRespPreg3				= " ";
	LET cRespPreg4				= " ";
	LET cRespPreg5				= " ";
	LET cRespPreg6				= " ";
	LET cRespPreg7				= " ";
	LET cRespPreg8				= " ";
	LET cRespPreg9				= " ";
	LET cResp2Preg9				= " ";
	LET cRespPreg10				= " ";
	LET cTipoSolicitud				= " ";
	LET cDomicilioGeolocalizado				= " ";
	LET iVariable16				= 0;
	LET sCiclo					= 0;
	LET sElemento				= 0;
	LET iNumCdCoppel			= 0;
	LET iNumHabDomTrabajan      = 0;
	LET cYearsOcupacion		= " ";
	LET vcTiempoDeOcupacion		= " ";
	LET cNumCteProsTitular 		= " ";
	LET cRespPreg1Titular 		= " ";
	LET cRespPreg2Titular 		= " ";
	LET cRespPreg3Titular 		= " ";
	LET cRespPreg4Titular 		= " ";
	LET cRespPreg5Titular 		= " ";
	LET cRespPreg6Titular 		= " ";
	LET cRespPreg7Titular 		= " ";
	LET cRespPreg8Titular 		= " ";
	LET cRespPreg9Titular 		= " ";
	LET cResp2Preg9Titular 		= " ";
	LET cRespPreg10Titular 		= " ";
	LET cTipoSolicitudTitular 		= " "; 
	LET cDomicilioGeolocalizadoTitular		= " ";
	LET iVariable16Titular		= 0;
	LET cPuntualidadconyoref1   = " ";
	LET cPuntualidadconyoref2   = " ";
	LET dtFechaHoy			    = DATE(1);

	--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 INICIO
	LET cCasa 				= " ";
	LET iCalle 				= 0;
	LET cRefCoppel1			= "0";
	LET cRefCoppel2			= "0";
	LET cCtePresentoIfe		= " ";
	LET cCtePresentoCompDom	= " ";
	LET sCiudadIfe			= 0;
	LET iColoniaIfe			= 0;
	LET iCalleIfe			= 0;
	LET cCasaIfe			= " ";
	LET cInteriorIfe		= " ";
--	LET cNumSucursal		= "0";
	LET iNumSucursal					= 0;
	LET iSecuencia			= 0;
	LET cEnviaOs			= "";
	LET dFechaHoy			= "01/01/1900";
	LET iSecRef1			= 0;
	LET iSecMenor			= 0;
--IPCB 13sep2016
	LET id_respuesta 		= 0;
	LET cGeoCli				= ""; --387 validar puntos de coordenada cte
	LET cFLagDomAlta 		= ""; --387 validar domicilio cte
	LET cFolioMovil 		= ""; --387 validar geolocalizacion
--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 FIN
	LET cNumCred			=''; --DSB-22/12/2018
	LET i					=0;


	LET cCodRet							= '000000';
	--RQM-598.1 INICIO
	LET num_producto_bco 				= '';
	LET status_solicitud_bco 			= '';
	LET monto_lc_bco 					= 0;
	LET cNumSolCoppel					= TRIM(NVL(p_NumSolicitud,'')); --RQM-598.1
	LET fecha_resp_bco 					= '1900-01-01';
	LET cOrigenSolic					= '0';
	LET cFlag_ProductoCoppel			= '1'; --DSB 2020/05/13
	LET cFlag_MotosCoppel 				= '';
	LET cCtepresentoCompIng 			= '';
	LET iTelefonoClienteLada		    = 0;
	LET iTelefonoCliente 			    = 0;
	LET iCelularClienteLada 			= 0;
	LET iCelularCliente 				= 0;
	LET iCampoFuturo8 					= 0;
	LET iCampoFuturo9 					= 0;
	LET iCampoFuturo10 					= 0;
	--RQM-598.1 FIN
	LET vContador0 = 0;
	LET vContador1 = 0;
	LET vContador2 = 0;
	LET vContador3 = 0;
	LET vContador4 = 0;
	LET vContador5 = 0;
	LET vContador6 = 0;
	LET vContador7 = 0;
	LET vContador8 = 0;
	LET vContador9 = 0;
	LET vContador10 = 0;
	LET vContador11 = 0;
	LET vContador12 = 0;
	LET vContador13 = 0;
	LET vContador14 = 0;
	LET vContador15 = 0;
	LET vContador16 = 0;
	LET vContador17 = 0;
	LET vContador18 = 0;
	LET vContador19 = 0;
	LET vContador20 = 0;
	LET vContador21 = 0;
	--INC 25 457 VARIABLE PARA VALIDACION DE ENVIO PARAMETRICO 4  16/07/2024
	LET cEnvioParam = " ";
	 --38829-RQM 09 655 Reingenieria de clientes nuevos MX
    LET vTelCasa = "";
	LET vTelCasaLada	= "";	
	LET vTelCasaNum	= "";
	LET vTelCelular	= "";
	LET vTelCelularLada	= "";
	LET vTelCelularNum	= "";

	LET cCanalSol = ''; -- Apolo

BEGIN


	
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN  vCodRet, 'NULL';
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/kevingarcia/sp_envioparametricocoppel_cteprosp_apolo.out";
	--TRACE ON;

	IF NVL(pTipoCliente,0) = 0 THEN
		LET vCodRet = '00001';
		RETURN  vCodRet, 'EL TIPO CLIENTE TIENE UN VALOR NULO';
	END IF;

	IF pTipoCliente NOT IN (1,2)  THEN
		LET vCodRet = '00002';
		RETURN  vCodRet, 'EL TIPO CLIENTE TIENE UN VALOR INCORRECTO';
	END IF;
	IF pTipoCliente = 1 THEN
		IF NVL(p_Empresa,'') = '' OR NVL(p_NumCte,'') = '' OR NVL(p_NumSolicitud,'') = '' THEN
			LET vCodRet = '00003';
			RETURN  vCodRet, 'AL SER CLIENTE TIPO 1 NINGUN PARAMETRO DEBE SER NULO';
		END IF;
			LET cSubClave = "0032";
			LET vContador0 = (SELECT count(numcte) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = p_NumCte);
			
			SELECT NVL(factor_techo, '1'), NVL(canal_sol, '')  --DSB 2020/05/13
				INTO cFlag_ProductoCoppel, cCanalSol
			FROM bdisolic:"informix".ss_solicitudes
			WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;
			 
			SELECT NVL(factor_piso,''),NVL(tasa_piso,'') -- DSB OM 747
				INTO cFlag_MotosCoppel,cCtepresentoCompIng
			FROM bdisolic:"informix".ss_solicitudes
			WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;
			
			IF(vContador0 > 0 ) THEN
				--NumeroCiudad y NumeroColonia
				--SELECT {+ INDEX (si_catzonas idx_catzonass)} a.numerociudadcoppel, a.numerocoloniacoppel
				SELECT a.numerociudadcoppel, a.numerocoloniacoppel
				INTO sNumCd, sNumCol
				FROM bdinteg:"informix".si_catzonas a
				WHERE a.numerociudad = (SELECT b.numerociudad FROM bdinteg:"informix".si_direcciones_actual b WHERE b.numcte = p_NumCte AND b.tipo_dir = 1)
				AND a.numerocolonia =(SELECT c.numerocolonia FROM bdinteg:"informix".si_direcciones_actual c WHERE c.numcte = p_NumCte and c.tipo_dir = 1);
			END IF;

			LET vContador1 = (SELECT count(numcte) FROM bdinteg:"informix".si_cliente WHERE numcte = p_NumCte);
			IF(vContador1 > 0 ) THEN
				--TipoDeCasa, Genero, EstadoCivil, FechaNacimiento,HabitantesEnDomicilio
				-- se reversa consulta 19/11/2020 jlmendoza
				SELECT ctepf.habita_en, ctepf.sexo, ctepf.estado_civil, TO_CHAR(ctepf.fecha_nac, '%Y-%m-%d'), CAST(cte.string2 AS SMALLINT)
				INTO cTipoCasa, cGenero, cEdoCivil, cFecNac, sHabDom
				FROM bdinteg:"informix".si_ctepf ctepf, bdinteg:"informix".si_cliente cte
				WHERE ctepf.numcte = p_NumCte AND cte.numcte = p_NumCte;

				--FechaEvaluacion
				SELECT TO_CHAR(fecha_hoy, '%Y-%m-%d') INTO cFecHoy FROM bdicred:"informix".sd_fechas WHERE empresa = p_Empresa;
			END IF;

			LET vContador3 = (SELECT count(num_solicitud) FROM bdisolic:"informix".ss_detalle_scoring WHERE num_solicitud = p_NumSolicitud);
			IF(vContador3 > 0) THEN
				--Tiempo de Residencia
				SELECT SUBSTR(descripcion,1,2)
				INTO cResidencia
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 6 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 6 AND num_solicitud = p_NumSolicitud);

				--RTV
				SELECT fecha_insert, sucursal
					INTO dtFechSol, cFolioSucursal
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

			--INC091121
			------------------------------------------------------------------------------------------------------------
			-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE OBTIENEN DE LA SUCURSAL DE LA SOLICITUD DEL CLIENTE
			------------------------------------------------------------------------------------------------------------
			IF NVL(sNumCd, 0) = 0 OR NVL(sNumCol, 0) = 0 THEN

				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END
				INTO iCiudadBanco
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cFolioSucursal;

				IF NVL(iCiudadBanco,0) <> 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
								   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sNumCd, sNumCol
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = iCiudadBanco;
				END IF;

				-----------------------------------------------------------------------------------------------
				-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE TOMARA EL PRIMER REGISTRO DEL CATALOGO
				-----------------------------------------------------------------------------------------------
				IF NVL(sNumCd, 0) = 0 OR NVL(sNumCol, 0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
								   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sNumCd, sNumCol
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL
					AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
				END IF;

			END IF;
			-- INC091121 	"SE AGREGA MODIFICACION"  TERMINA
			
			
				IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
					LET dtFechSol = dtFechSol -1 units DAY;
				END IF;

				LET cTiempReside = dtFechSol - cResidencia::INTEGER units YEAR;

				--Nivel de escolaridad
				SELECT elemento
				INTO cEscolaridad
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 21 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 21 AND num_solicitud = p_NumSolicitud);

				SELECT descripcion::INTEGER
				INTO sDependiente
				FROM bdisolic:ss_scoring_element 
				WHERE grupo = 11
				AND elemento =(
				SELECT CASE WHEN elemento = 22 THEN 21 ELSE elemento END FROM bdisolic:ss_detalle_scoring  WHERE num_solicitud = p_NumSolicitud
				AND grupo = 11);
				
				--TERMINA INC-21-12-2020
				--Tiempo de Ocupacion
				SELECT SUBSTR(descripcion,1,2)
				INTO cTimOcupacion
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 8 and elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 8 AND num_solicitud = p_NumSolicitud);

				IF cTimOcupacion = "No" THEN
					LET cTimOcupacion = "1900-01-01";
				ELSE
					SELECT fecha_insert
					INTO dtFechSol
					FROM bdisolic:"informix".ss_solicitudes
					WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
					--IF dtFechSol <> "1900-01-01" THEN --se corrige siguiente linea de acuerdo a PRORD
                    IF dtFechSol <> MDY(01,01,1900) THEN
						LET dtFechSol = dtFechSol -1 units DAY;
					END IF;
				END IF;

				LET cTiempoDesc = dtFechSol - NVL(cTimOcupacion,0)::INTEGER units YEAR;

				END IF;

				IF (cEdoCivil NOT IN ("S")) THEN --INC23426
						--TiempoDeEstadoCivil(Anios)
					SELECT SUBSTR(descripcion,1,2)
					INTO cEdoCiv
					FROM bdisolic:"informix".ss_scoring_element
					WHERE grupo = 4 and elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 4 AND num_solicitud = p_NumSolicitud);

					IF (TRIM(cEdoCiv) <> "0") THEN

						IF cEdoCiv = "No" THEN
							LET cTimEdoCiv = "1900-01-01";
						ELSE
							SELECT fecha_insert
							INTO dtFechSol
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

							LET cTimEdoCiv = TO_CHAR(bdicred:"informix".monthadd(dtFechSol,cEdoCiv::integer * -12),'%Y-%m-%d');
						END IF;
					ELSE
						--TiempoDeEstadoCivil(MESES)
						SELECT SUBSTR(descripcion,1,2)
						INTO cEdoCiv
						FROM bdisolic:"informix".ss_scoring_element
						WHERE grupo = 41 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 41 AND num_solicitud = p_NumSolicitud);

						IF (cEdoCiv <> "0") THEN

							SELECT fecha_insert
							INTO dtFechSol
							FROM bdisolic:"informix".ss_solicitudes
							WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

							LET cTimEdoCiv = TO_CHAR(bdicred:"informix".monthadd(dtFechSol,cEdoCiv::integer * -1),'%Y-%m-%d');

						END IF;
					END IF;
				END IF;
			END IF;

			LET vContador4 = (SELECT count(num_solicitud) FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = p_NumSolicitud);
			IF(vContador4 > 0) THEN
				--Ingreso Mensual
				--DSB-01/10/2013
				SELECT CAST(ingreso_mensual AS MONEY), tipo_movimiento, num_solicitud_ref
				INTO iValor, vtipomovimiento, vnumsolicitudref
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE num_solicitud = p_NumSolicitud;

				IF iValor > 250000 THEN
					--Actualizar el ingreso maximo a 250000
					UPDATE bdisolic:"informix".ss_resum_scor_fin SET ingreso_mensual = 250000 WHERE num_solicitud = p_NumSolicitud;
					LET iIngMensual = 250000::INTEGER;
				ELSE
					LET iIngMensual = iValor::INTEGER;
				END IF;
				--Nivel de ingreso
				SELECT valor::DECIMAL(14,2)
				INTO iValor
				FROM bdisolic:"informix".ss_param
				WHERE empresa = p_Empresa AND secuencia = 363;
				--RTV
				LET sNivIngreso = ((((NVL(iIngMensual::DECIMAL(14,2),0))+(iValor/2)))/iValor)::SMALLINT;

				IF sNivIngreso < 1 THEN
					LET sNivIngreso = 1;
				END IF;

			END IF;

			SELECT COUNT(num_celular) INTO iCampoFuturo10  
			FROM  bdiburo:"informix".br_cliente_aut
			WHERE num_cliente = p_NumCte and fecha_hora_aut =(SELECT MAX(fecha_hora_aut )FROM  bdiburo:"informix".br_cliente_aut WHERE num_cliente=p_NumCte); 


			IF (iCampoFuturo10 < 1)THEN
				LET iCampoFuturo10 =0;
			END IF;
		
			--LABR GRANDATA 190720200

            SELECT actividad, subactividad
            INTO sOpcionPuesto, sSubOpcioPuesto
            FROM bdisolic:"informix".ss_revision_determinacion					 
            WHERE empresa = p_Empresa
            AND num_solicitud = p_NumSolicitud;

-- JOM FIN / Se solicita por parte del area de credito tomar el valor de la tabla de determinacion, donde el valor es fijo en la solicitud y no cambia

			--NumeroCredito
			LET iNumCred = CAST(TRIM(p_NumSolicitud) AS INT8);

			LET vContador20 = (SELECT count(num_solicitud_sic) FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud);
			IF(vContador20 > 0) THEN
				--TipoConsulta
				--DSB-01/10/2013
				SELECT FIRST 1 num_solicitud_sic, institucion
				  INTO cNumSolSIC, cInstitucion
				  FROM bdisolic:"informix".ss_solicitudes_sic
				 WHERE numcte = p_NumCte
				   AND num_solicitud = p_NumSolicitud
				   AND fecha_insert = (SELECT MAX(fecha_insert)
										 FROM bdisolic:"informix".ss_solicitudes_sic
										WHERE numcte = p_NumCte
										  AND num_solicitud = p_NumSolicitud
										  AND fecha_sic IS NOT NULL)
				   AND fecha_sic IS NOT NULL;

				 LET p_NumSolicitud = cNumSolSIC;
			ELSE
				LET vContador7 = (SELECT count(numcte) FROM bdiburo:"informix".br_traslado WHERE numcte = p_NumCte);
				IF(vContador7 > 0) THEN
					SELECT institucion
					INTO cInstitucion
					FROM bdiburo:"informix".br_traslado
					WHERE numcte = p_NumCte AND rowid = (SELECT MAX(rowid) FROM bdiburo:"informix".br_traslado  WHERE numcte = p_NumCte);
				END IF;
			END IF;

			LET vContador8 = (SELECT count(num_cliente) FROM bdiburo:"informix".br_rs WHERE num_cliente = p_NumCte AND institucion = cInstitucion AND rs34 IS NOT NULL);
			IF(vContador8 > 0) THEN

				--Se modifica la forma de obtener la informacion del segmento rs. RTV - 2012/04/11
				SELECT MIN(rowid) INTO iRenglonMinimo FROM bdiburo:"informix".br_rs
				WHERE num_cliente = p_NumCte AND institucion = cInstitucion;

				--Meses de Antiguedad
				SELECT rs34, rs16
				INTO cFecAnt, sNumSols
				FROM bdiburo:"informix".br_rs
				WHERE num_cliente = p_NumCte AND institucion = cInstitucion AND rowid = iRenglonMinimo;

				SELECT CAST(((fecha_insert - cFecAnt)/30.42) AS INTEGER)
				INTO sMesesAntiguedad
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				--Peor Forma de Pago
				EXECUTE PROCEDURE bdisolic:"informix".sp_peorformapago(TRIM(p_NumCte), cInstitucion) INTO vCodRet, sPeorPago;

				--Se comenta ya que se esta obteniendo en una consulta previa. RTV - 2012/04/11
				--Numero de Solicitudes
			END IF;

			LET vContador9 = (SELECT count(num_solicitud) FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = p_NumSolicitud);
			IF(vContador9 > 0) THEN
				--ClienteBCPL
				SELECT CAST(numcte AS INTEGER)
				INTO iCteBCPL
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;
			END IF;

			LET vContador21 = (SELECT count(num_solicitud) FROM bdiburo:"informix".sb_regreso WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion);
			IF(vContador21 > 0) THEN
			
				LET vContador10 = (SELECT COUNT(num_solicitud) FROM bdisolic:ss_prospecteo_solicitudes where num_solicitud = p_NumSolicitud and canal_sol = 4);
				IF (vContador10 > 0) THEN
					--SELECT TRIM(REPLACE(regreso,'',' '))  --IPCB 03Agosto21 Se cambia linea de replace para que no corte tramas de autosolicitudes
					SELECT TRIM(regreso)
					INTO cResSIC
					FROM bdiburo:"informix".sb_regreso
					WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion;
				ELSE
				--RespuestaSIC
					SELECT TRIM(regreso)
					INTO cResSIC
					FROM bdiburo:"informix".sb_regreso
					WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion;
				END IF;
				--FolioConsulta
				EXECUTE PROCEDURE bdisolic:"informix".sp_instr(2,cResSIC,'ES05') INTO vCodRet, iLogFinal;

					----INC 27-03-2019
				--SELECT SUBSTR(regreso,(iLogFinal+13),9)
				SELECT SUBSTR(regreso,(iLogFinal+13),11)
				INTO cFolioConsul
				FROM bdiburo:"informix".sb_regreso
				WHERE institucion = cInstitucion AND num_solicitud = p_NumSolicitud;
				
            END IF;
			LET vContador11 = (SELECT COUNT(num_solicitud) FROM bdiburo:"informix".br_respuesta WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion);
            IF (vContador11 > 0) THEN
			--IPCB13sep2016 Se incluye la consulta del id de la respuesta para evitar duplicados.
					SELECT min(idrespuesta)
					INTO id_respuesta
					FROM bdiburo:"informix".br_respuesta
					WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion
					AND secuencia = 1;
					
				LET vContador12 = (SELECT COUNT(num_solicitud) FROM bdisolic:ss_prospecteo_solicitudes where num_solicitud = p_NumSolicitud and canal_sol = 4);	
				IF (vContador12 > 0) THEN
					--SELECT TRIM(REPLACE(regreso,'',' '))--IPCB 03Agosto21 Se cambia linea de replace para que no corte tramas de autosolicitudes
					--SELECT trim(REPLACE(regreso,'Ã','N'))::LVARCHAR(10000)
					SELECT TRIM(regreso)::LVARCHAR(10000)
					INTO cResSIC
					FROM bdiburo:"informix".br_respuesta
					WHERE idrespuesta = id_respuesta and num_solicitud = p_NumSolicitud AND institucion = cInstitucion
					AND secuencia = 1;
				ELSE
					--SELECT trim(REPLACE(regreso,'Ã','N'))::LVARCHAR(10000)
					SELECT trim(regreso)::LVARCHAR(10000)
					INTO cResSIC
					FROM bdiburo:"informix".br_respuesta
					WHERE idrespuesta = id_respuesta and num_solicitud = p_NumSolicitud AND institucion = cInstitucion
					AND secuencia = 1;
				END IF;
				SELECT envio_parametrico
				INTO cEnvioParam
				FROM bdisolic:"informix".ss_solicitudes
				where num_solicitud = cNumSolCoppel 
				and numcte = p_NumCte;			
			
				--Validacion si el envio parametrico se encuentra en 4			
					IF 	cEnvioParam = 4 then
						LET cResSIC =  bdiburo:"informix".sp_remplaza_n_long(cResSIC)::LVARCHAR(10000);
					ELSE
						LET cResSIC =  bdiburo:"informix".sp_remplaza_n(cResSIC)::LVARCHAR(10000);
					END IF;
                    --FolioConsulta
                    EXECUTE PROCEDURE bdisolic:"informix".sp_instr(2,cResSIC,'ES05') INTO vCodRet, iLogFinal;

					----INC 27-03-2019
                    --SELECT SUBSTR(regreso,(iLogFinal+13),9)
					SELECT SUBSTR(regreso,(iLogFinal+13),11)
                    INTO cFolioConsul
                    FROM bdiburo:"informix".br_respuesta
                    WHERE idrespuesta = id_respuesta and institucion = cInstitucion AND num_solicitud = p_NumSolicitud
                    AND secuencia = 1;
			END IF;

			LET vContador13 = (SELECT count(solicitud) FROM bdiburo:"informix".br_auditor WHERE institucion = cInstitucion and solicitud = p_NumSolicitud);
			IF(vContador13 > 0) THEN
				--FechaConsultaSIC
				SELECT TO_CHAR(fecha,'%Y-%m-%d')
				INTO cFechaSIC
				FROM bdiburo:"informix".br_auditor
				WHERE solicitud = p_NumSolicitud AND institucion = cInstitucion
				AND rowid = (SELECT MAX(rowid) FROM bdiburo:"informix".br_auditor WHERE solicitud = p_NumSolicitud AND institucion = cInstitucion);
			END IF;
-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
	-- Numero de habitantes en el domicilio que trabajan
		SELECT elemento
		  INTO iVar06
		  FROM bdisolic:"informix".ss_detalle_scoring
		 WHERE num_solicitud = p_NumSolicitud
		   AND grupo = 39;

		IF (iVar06 is null) THEN LET iVar06 = 0; END IF;

-- Telefono de casa
		SELECT first 1 cofetel,telefono
		  INTO vcasa,vTelCasa
		  FROM bdinteg:"informix".si_telefonos_actual
		 WHERE numcte = p_NumCte
		   AND tipo_tel = 1;

		IF (vcasa is null) THEN
			LET vcasa = 'F';
		END IF;

-- Telefono de trabajo
		SELECT first 1 cofetel,telefono
		  INTO vcelular,vTelCelular
		  FROM bdinteg:"informix".si_telefonos_actual
		 WHERE numcte = p_NumCte
		   AND tipo_tel = 2;

		IF (vcelular is null) THEN	LET vcelular = 'F';	END IF;

		IF   (vcasa = 'F' and vcelular = 'F') THEN
			LET cVar02 = '0';
		ELIF (vcasa = 'V' and vcelular = 'F') THEN
			LET cVar02 = '1';
		ELIF (vcasa = 'F' and vcelular = 'V') THEN
			LET cVar02 = '2';
		ELSE
			LET cVar02 = '3';
		END IF;

		IF (vtipomovimiento is null) THEN
			LET vtipomovimiento = " ";
		END IF;

		IF (vtipomovimiento = 'M') THEN
		-- Se cambia a la solicitud Bancoppel
			LET p_NumSolicitud = vnumsolicitudref;
		END IF;
--Obtener el Telefono de casa fijo lada 2 primero(iCampoFuturo4 ) 8 siguientes tel(iCampoFuturo5)
		--38829-RQM 09 655
		--consulta para obtener el tel de casa
		   
		IF (vTelCasa is null) OR NVL(vTelCasa,'') = '' THEN
	     LET iTelefonoClienteLada 				= 0;
	     LET iTelefonoCliente 					= 0;			
		ELSE
		 LET vTelCasaLada = SUBSTR(vTelCasa,1,2);
		 LET iTelefonoClienteLada = CAST(vTelCasaLada AS int);
		 LET vTelCasaNum = SUBSTR(vTelCasa,3,8);
		 LET iTelefonoCliente = CAST(vTelCasaNum AS int);	
		END IF;
		--Obtener el Telefono celular movil lada 2 primero(iCampoFuturo6 ) 8 siguientes tel(iCampoFuturo7)
		--38829-RQM 09 655
		--consulta para obtener el celular

		IF (vTelCelular is null) OR NVL(vTelCelular,'') = '' THEN
		 LET iCelularClienteLada					= 0;
	     LET iCelularCliente				= 0;			
		ELSE
		    LET vTelCelularLada=SUBSTR(vTelCelular,1,2);
			 LET iCelularClienteLada = CAST(vTelCelularLada AS int);
			LET vTelCelularNum=SUBSTR(vTelCelular,3,8);
			 LET iCelularCliente = CAST(vTelCelularNum AS int);
		END IF;
-- Referencia 1
		SELECT parentesco, numerociudad, numerocolonia
		  INTO cVar01, ref1numerociudad, ref1numerocolonia
		  FROM bdinteg:"informix".si_refclientes a
		  left join bdinteg:"informix".si_refdirecciones b
		  on a.numcte = b.numcte
		  and a.secuencia = b.secuencia
		 WHERE empresa  = p_Empresa
		   AND a.numcte = p_NumCte
		   --AND a.numcte = b.numcte
		   AND a.secuencia = (SELECT MIN(secuencia)
							  FROM bdinteg:"informix".si_refclientes
							 WHERE a.empresa = empresa
							   AND a.numcte = numcte
							   AND num_solicitud = p_NumSolicitud);
		   --AND a.secuencia = b.secuencia;

		IF (cVar01 is null) THEN
			SELECT parentesco
				INTO cVar01
			FROM bdinteg:"informix".si_refclientes a
			WHERE a.empresa  = p_Empresa
			AND a.numcte = p_NumCte
			AND a.secuencia = (SELECT MAX(secuencia)
							  FROM bdinteg:"informix".si_refclientes 
							 WHERE a.empresa = empresa
							   AND a.numcte = numcte);							
			
		END IF; 
		
		IF (cVar01 is null) THEN
			LET cVar01 = " ";
		END IF;

		SELECT first 1 numerociudadcoppel
		INTO ref1numerociudad
		FROM bdinteg:"informix".si_catzonas
		WHERE numerociudad  = ref1numerociudad
		  AND numerocolonia = ref1numerocolonia;

		IF NVL(ref1numerociudad, 0) = 0 THEN
			SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
			INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

			SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
			INTO ref1numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL AND numerociudad = iCiudadBanco;
		END IF;

		IF NVL(ref1numerociudad, 0) = 0 THEN
			LET ref1numerociudad = -99;
		END IF;

-- Referencia 2
		SELECT numerociudad, numerocolonia
		  INTO ref2numerociudad, ref2numerocolonia
		  FROM bdinteg:"informix".si_refclientes a
		  left join bdinteg:"informix".si_refdirecciones b
		  on a.numcte = b.numcte
		  and a.secuencia = b.secuencia
		 WHERE empresa  = p_Empresa
		   AND a.numcte = p_NumCte
		   -- AND a.numcte = b.numcte
		   AND a.secuencia = (SELECT MAX(secuencia)
							  FROM bdinteg:"informix".si_refclientes
							 WHERE a.empresa = empresa
							   AND a.numcte = numcte
							   AND num_solicitud = p_NumSolicitud);
		   -- AND a.secuencia = b.secuencia;

		SELECT first 1 numerociudadcoppel
		INTO ref2numerociudad
		FROM bdinteg:"informix".si_catzonas
		WHERE numerociudad  = ref2numerociudad
		  AND numerocolonia = ref2numerocolonia;

		IF NVL(ref2numerociudad, 0) = 0 THEN
			SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
			INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

			SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
			INTO ref2numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL AND numerociudad = iCiudadBanco;
		END IF;

		IF NVL(ref2numerociudad, 0) = 0 THEN
			LET ref2numerociudad = -99;
		END IF;

		SELECT numcte_pros, CAST(sucursal AS int)
		INTO cNumCteProsTitular, iVariable16Titular
		FROM bdiprospectos:"informix".pr_cliente
		WHERE numcte = p_NumCte;

		--TERMINA INC 27-03-2019
		LET iVar07 = ref1numerociudad;
		LET iVar08 = ref2numerociudad;
		--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 INICIO
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg:"informix".si_fechas
		WHERE empresa = p_Empresa;

		IF NVL(dFechaHoy,'01-01-1900') = '01-01-1900' THEN
			LET dFechaHoy = '01-01-1900';
		END IF;

		SELECT numeroextcalle
		INTO cCasa
		FROM bdinteg:"informix".si_direcciones_actual
		WHERE numcte = p_NumCte
		AND tipo_dir = 1
		AND secuencia = (SELECT MAX(secuencia)
						 FROM bdinteg:"informix".si_direcciones_actual
						 WHERE numcte = p_NumCte
						 AND tipo_dir = 1);

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCasa = " ";
		END IF;
		IF NVL(cCasa,'') = '' THEN
			LET cCasa = '';
		END IF;

		SELECT numerocalle
		INTO  iCalle
		FROM bdinteg:"informix".si_direcciones_actual
		WHERE numcte = p_NumCte
		AND tipo_dir = 1
		AND secuencia = (SELECT MAX(secuencia)
						 FROM bdinteg:"informix".si_direcciones_actual
						 WHERE numcte = p_NumCte
						 AND tipo_dir = 1);

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET iCalle = 0;
		END IF;
		IF NVL(iCalle,0) = 0 THEN
			LET iCalle = 0;
		END IF;

		SELECT MAX(secuencia)
		INTO iSecuencia
		FROM bdinteg:"informix".si_refclientes
		WHERE empresa = p_Empresa
		AND num_solicitud = p_NumSolicitud
		AND numcte = p_NumCte;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET iSecuencia = 0;
			LET cRefCoppel1 = "0";
			LET cRefCoppel2 = "0";
		END IF;
		IF  NVL(iSecuencia,0) = 0 THEN
			LET iSecuencia = 0;
			LET cRefCoppel1 = "0";
			LET cRefCoppel2 = "0";
		END IF;

		SELECT secuencia
		INTO iSecRef1
		FROM bdinteg:"informix".si_refclientes
		WHERE empresa = p_Empresa
		AND num_solicitud = p_NumSolicitud
		AND numcte = p_NumCte
		AND secuencia = iSecuencia -1;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET iSecRef1 = 0;
			LET cRefCoppel1 = "0";
			LET cRefCoppel2 = "0";
			LET iSecMenor = 0;
		END IF;
		IF  NVL(iSecRef1,0) = 0 THEN
			LET iSecRef1 = 0;
			LET cRefCoppel1 = "0";
			LET cRefCoppel2 = "0";
			LET iSecMenor = 0;
		ELIF iSecRef1 IS NOT NULL THEN
			LET iSecMenor = 1;
		END IF;

		IF iSecMenor = 0 THEN
			SELECT numcte_ref
			INTO cRefCoppel1
			FROM bdinteg:"informix".si_refclientes
			WHERE empresa = p_Empresa
			AND num_solicitud = p_NumSolicitud
			AND numcte = p_NumCte
			AND secuencia = iSecuencia;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cRefCoppel1 = "0";
			END IF;
			IF NVL(cRefCoppel1,'') = '' THEN
				LET cRefCoppel1 = "0";
			END IF;
		ELIF iSecMenor = 1 THEN
			SELECT numcte_ref
			INTO cRefCoppel1
			FROM bdinteg:"informix".si_refclientes
			WHERE empresa = p_Empresa
			AND num_solicitud = p_NumSolicitud
			AND numcte = p_NumCte
			AND secuencia = iSecuencia -1;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cRefCoppel1 = "0";
			END IF;
			IF NVL(cRefCoppel1,'') = '' THEN
				LET cRefCoppel1 = "0";
			END IF;


			SELECT numcte_ref
			INTO cRefCoppel2
			FROM bdinteg:"informix".si_refclientes
			WHERE empresa = p_Empresa
			AND num_solicitud = p_NumSolicitud
			AND numcte = p_NumCte
			AND secuencia = iSecuencia;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cRefCoppel2 = "0";
			END IF;

			IF NVL(cRefCoppel2,'') = '' THEN
				LET cRefCoppel2 = "0";
			END IF;
		END IF;

		SELECT codidentifi
		INTO cCtePresentoIfe
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = p_Empresa
		AND numcte = p_NumCte;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCtePresentoIfe = " ";
		END IF;

		IF cCtePresentoIfe = "A" THEN
			LET cCtePresentoIfe = "S";
		ELIF cCtePresentoIfe <> "A" THEN
			LET cCtePresentoIfe = "N";
		END IF;

		LET cCtePresentoCompDom = "S";

		SELECT flag_envia_os
		INTO cEnviaOs
		FROM bdinteg:"informix".si_ctes_manttodomife
		WHERE empresa = p_Empresa
		AND numcte = p_NumCte
		AND CAST(fecha_insert AS DATE) = dFechaHoy;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cEnviaOs = cEnviaOs::INT;
			LET cEnviaOs = 0;
		END IF;

		LET cEnviaOs = cEnviaOs::INT;

		IF cEnviaOs = 1 THEN

		-- CIB-16/05/2018 	"SE AGREGA MODIFICACION"  INICIA
		---------------------------------------------------------------------------------------------------
		-- SE OBTIENEN LAS ULTIMAS 2 DIRECCIONES DE CASA DEL CLIENTE PARA SOLO TOMAR LA PENULTIMA DIRECCION
		-- Y EN CASO DE QUE EL CLIENTE SOLO TENGA UNA DIRECCION DE CASA TOME ESE REGISTRO.
		---------------------------------------------------------------------------------------------------
			FOREACH
				SELECT FIRST 2 numerociudadcoppel,numerocoloniacoppel, numerocalle, numeroextcalle, numerointcalle
				INTO sCiudadIfe, iColoniaIfe, iCalleIfe, cCasaIfe, cInteriorIfe
				FROM TABLE ( MULTISET(

					SELECT NVL(cat.numerociudadcoppel,0) AS numerociudadcoppel,
						   NVL(cat.numerocoloniacoppel,0) AS numerocoloniacoppel,
						   NVL(sica.numerocalle,0) AS numerocalle,
						   NVL(dir.numeroextcalle," ") AS numeroextcalle,
						   NVL(dir.numerointcalle," ") AS numerointcalle,
						   dir.secuencia
					FROM bdinteg:"informix".si_direcciones dir
						LEFT JOIN bdinteg:"informix".si_ciudades ciu ON( ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado)
						LEFT JOIN bdinteg:"informix".si_estados edo ON edo.estado = dir.estado
						LEFT JOIN bdinteg:"informix".si_catzonas cat ON (cat.numerociudad = dir.numerociudad AND cat.numerocolonia = dir.numerocolonia)
						LEFT JOIN bdinteg:"informix".si_catcalles sica ON sica.numerocalle = dir.numerocalle
					WHERE dir.numcte = p_NumCte
					AND dir.tipo_dir = 1

				))ORDER BY secuencia DESC
			END FOREACH;

			------------------------------------------------------------------------------------------------------------
			-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE OBTIENEN DE LA SUCURSAL DE LA SOLICITUD DEL CLIENTE
			------------------------------------------------------------------------------------------------------------
			IF NVL(sCiudadIfe,0) = 0 OR NVL(iColoniaIfe,0) = 0 THEN
				SELECT sucursal
				INTO cFolioSucursal
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte
				AND num_solicitud = p_NumSolicitud;

				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END
				INTO iCiudadBanco
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cFolioSucursal;

				IF NVL(iCiudadBanco,0) <> 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
								   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sCiudadIfe, iColoniaIfe
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = iCiudadBanco;
				END IF;

				-----------------------------------------------------------------------------------------------
				-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE TOMARA EL PRIMER REGISTRO DEL CATALOGO
				-----------------------------------------------------------------------------------------------
				IF NVL(sCiudadIfe,0) = 0 OR NVL(iColoniaIfe,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
								   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sCiudadIfe, iColoniaIfe
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL
					AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
				END IF;

			END IF;
			-- CIB-16/05/2018 	"SE AGREGA MODIFICACION"  TERMINA

		ELIF cEnviaOs <> 1 THEN

		-- CIB-16/05/2018 	"SE AGREGA MODIFICACION 2"  INICIA
			SELECT cat.numerociudadcoppel, cat.numerocoloniacoppel
			INTO sCiudadIfe, iColoniaIfe
			FROM bdinteg:"informix".si_catzonas cat,
				 bdinteg:"informix".si_direcciones_actual dir,
				 bdinteg:"informix".si_ciudades ciu
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado
			AND cat.numerociudad = dir.numerociudad
			AND cat.numerocolonia = dir.numerocolonia;

			------------------------------------------------------------------------------------------------------------
			-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE OBTIENEN DE LA SUCURSAL DE LA SOLICITUD DEL CLIENTE
			------------------------------------------------------------------------------------------------------------
			IF NVL(sCiudadIfe,0) = 0 OR NVL(iColoniaIfe,0) = 0 THEN
				SELECT sucursal
				INTO cFolioSucursal
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte
				AND num_solicitud = p_NumSolicitud;

				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END
				INTO iCiudadBanco
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cFolioSucursal;

				IF NVL(iCiudadBanco,0) <> 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
								   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sCiudadIfe, iColoniaIfe
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudad = iCiudadBanco;
				END IF;

				-----------------------------------------------------------------------------------------------
				-- SI NO EXISTE CIUDAD O COLONIA COPPEL RELACIONADAS SE TOMARA EL PRIMER REGISTRO DEL CATALOGO
				-----------------------------------------------------------------------------------------------
				IF NVL(sCiudadIfe,0) = 0 OR NVL(iColoniaIfe,0) = 0 THEN
					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END,
								   CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sCiudadIfe, iColoniaIfe
					FROM bdinteg:"informix".si_catzonas
					WHERE numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL
					AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
				END IF;

			END IF;

			SELECT sica.numerocalle
			INTO iCalleIfe
			FROM bdinteg:"informix".si_catcalles sica,
				 bdinteg:"informix".si_direcciones_actual dir,
				 bdinteg:"informix".si_estados edo,
				 bdinteg:"informix".si_ciudades ciu
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND edo.estado = dir.estado
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado
			AND sica.numerocalle = dir.numerocalle;

			SELECT numeroextcalle, numerointcalle
			INTO cCasaIfe, cInteriorIfe
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte
			AND tipo_dir = 1;
			-- CIB-16/05/2018 	"SE AGREGA MODIFICACION 2"  TERMINA
		END IF;

        IF cInteriorIfe LIKE('%|%') THEN 
            LET cInteriorIfe= REPLACE(cInteriorIfe, '|', ' ');
        END IF;

		SELECT sucursal::INTEGER
		INTO iNumSucursal
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = p_Empresa
		AND numcte = p_NumCte;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET iNumSucursal = "0";
		END IF;

		LET cNumCred = LEFT(TRIM(p_NumSolicitud),12);

		--hsrr folio 387, IDUG 387
		SELECT folio,NVL(trim(substr(geolocalizacion,1,charindex(',',geolocalizacion)-1)), '') as latitud, NVL(trim(substr(geolocalizacion,charindex(',',geolocalizacion)+1,len(trim(geolocalizacion)))), '') as longitud ,domicilio_alta
		INTO cFolioMovil, cLatitud, cLongitud, cFLagDomAlta
		FROM bdinteg:"informix".si_solicitud_movil
		--WHERE num_tdc_coppel::INT8 = inumcred; --DSB-22/12/2018
		WHERE num_tdc_coppel = cNumCred;

		--IDUG 387 se valida la geolocalizacion para coppel
		IF TRIM(cFolioMovil) <> '' THEN
			LET cTipoSolicitudTitular = 'M';

			IF LEN(NVL(TRIM(cGeoCli),'')) > 10 AND (NVL(cFLagDomAlta,'') = 'S' ) THEN
				--IF (NOT EXISTS (SELECT id_ptf FROM bdinteg:"informix".si_ptf  WHERE TRIM(latitud)||","||TRIM(longitud) = TRIM(cGeoCli))) THEN --Domocilio Geolocalizado diferente al de sucursal
				--LET vContador19 = (SELECT count(id_ptf) FROM bdinteg:"informix".si_ptf  WHERE TRIM(latitud) = TRIM(cLatitud) and TRIM(longitud) = TRIM(cLongitud));
				LET vContador19 = (SELECT count(id_ptf) FROM bdinteg:"informix".si_ptf  WHERE latitud = TRIM(cLatitud) and longitud = TRIM(cLongitud));
				IF (vContador19 = 0) THEN --Domocilio Geolocalizado diferente al de sucursal
					LET cDomicilioGeolocalizadoTitular = 'S';
				ELSE
					LET cDomicilioGeolocalizadoTitular = 'N';
				END IF;

			ELSE
				LET cDomicilioGeolocalizadoTitular = 'N';
			END IF;

		END IF;


		-- RQM-598.1 INICIO
		-- IDENTIFICAR EL CANAL DE ORIGEN DE LA SOLICITUD
		EXECUTE PROCEDURE "informix".sp_obtienedatos_solbco(p_Empresa,cNumSolCoppel,p_NumCte)
		INTO cCodRet, num_producto_bco, status_solicitud_bco, monto_lc_bco,fecha_resp_bco,
			cOrigenSolic;
		

		--RQM-598.1
		--SE INICIALIZAN LOS CAMPOS CON VALOR POR DEFAULT
		--EN CASO DE ESTAR VACIOS O NULOS
		LET num_producto_bco = NVL(num_producto_bco,'');
		LET status_solicitud_bco = NVL(status_solicitud_bco,'');
		LET Monto_lc_bco = NVL(monto_lc_bco,0);
		LET fecha_resp_bco = NVL(fecha_resp_bco,'1900-01-01');
		LET cOrigenSolic = NVL(cCanalSol,'9'); --Apolo

		--RQM-598.1 FIN
	--INCICIA INC-21-12-2020
		IF NVL(cEscolaridad, '') = '' THEN
			LET cEscolaridad = "2";
		END IF;
		IF 	cEnvioParam = 4 then
			LET cCasa = bdiburo:"informix".sp_remplaza_n_long(cCasa);
			LET cCasaIfe = bdiburo:"informix".sp_remplaza_n_long(cCasaIfe);
			LET cInteriorIfe = bdiburo:"informix".sp_remplaza_n_long(cInteriorIfe);
		ELSE
			LET cCasa = bdiburo:"informix".sp_remplaza_n(cCasa);
			LET cCasaIfe = bdiburo:"informix".sp_remplaza_n(cCasaIfe);
			LET cInteriorIfe = bdiburo:"informix".sp_remplaza_n(cInteriorIfe);
		END IF;
		
		LET v_Cadena = sClave||"|"||TRIM(cSubClave)||"|"||NVL(iValorSeguridad,0)||"|"||NVL(iVersion,0)||"|"||NVL(sNumCd,0)||"|"||NVL(sNumCol,0)||"|"||NVL(cTipoCasa,'')||"|"||NVL(cGenero,'')
						 ||"|"||NVL(cEdoCivil,'')||"|"||NVL(cFecNac,'')||"|"||NVL(cTiempReside,'')||"|"||NVL(sHabDom,0)||"|"||cEscolaridad||'|'||NVL(sDependiente,0)
						 ||'|'||NVL(sNivIngreso,0)||'|'||NVL(cPuesto,'')||"|"||NVL(sOpcionPuesto,0)||"|"||NVL(sSubOpcioPuesto,0)||"|"||NVL(cTiempoDesc,'')||"|"||cTimEdoCiv
						 ||"|"||NVL(cFecHoy,'')||"|"||NVL(sMesesAntiguedad,0)||"|"||NVL(sPeorPago,0)||"|"||NVL(sNumSols,0)||"|"||NVL(iCteBCPL,0)||"|"||NVL(iNumCred,0)
						 ||"|"||NVL(cInstitucion,'')||"|"||NVL(cFolioConsul,'')||"|"||NVL(cFechaSIC,'')||"|"||NVL(iIngMensual,0);


		--TERMINA INC-21-12-2020
		--LET v_Cadena2 = NVL(cResSIC,'');--DSB20201124
		
		LET v_Cadena2 = NVL(TRIM(REPLACE(cResSIC,'|','')),''); --DSB20201124

		LET v_Cadena3 = cVar01||"|"||cVar02||"|"||cVar03||"|"||cVar04||"|"||cVar05||"|"||iVar06||"|"||iVar07||"|"||iVar08
				||"|"||iVar09||"|"||iVar10||"|"||NVL(cNumCteProsTitular,'')||"|"||NVL(cRespPreg1Titular,'')||"|"||NVL(cRespPreg2Titular,'')||"|"||NVL(cRespPreg3Titular,'')||"|"||NVL(cRespPreg4Titular,'')
				||"|"||NVL(cRespPreg5Titular,'')||"|"||NVL(cRespPreg6Titular,'')||"|"||NVL(cRespPreg7Titular,'')||"|"||NVL(cRespPreg8Titular,'')||"|"||NVL(cRespPreg9Titular,'')
				||"|"||NVL(cResp2Preg9Titular,'')||"|"||NVL(cRespPreg10Titular,'')||"|"||NVL(cTipoSolicitudTitular,'')||"|"||NVL(cDomicilioGeolocalizadoTitular,'') ||"|"||NVL(iVariable16Titular,0)
				||"|"|| TRIM(num_producto_bco) ||"|"|| TRIM(status_solicitud_bco) ||"|"|| monto_lc_bco ||"|"|| TRIM(fecha_resp_bco) ||"|"|| TRIM(cOrigenSolic)
				||"|"||NVL(TRIM(cCasa),'')||"|"||NVL(iCalle,0)||"|"||NVL(TRIM(cRefCoppel1),'')||"|"||NVL(TRIM(cRefCoppel2),'')||"|"||NVL(TRIM(cCtePresentoIfe),'')--DSB-03/02/2016 INICIO
				||"|"||NVL(TRIM(cCtePresentoCompDom),'')||"|"||NVL(sCiudadIfe,0)||"|"||NVL(iColoniaIfe,0)||"|"||NVL(iCalleIfe,0)||"|"||NVL(TRIM(cCasaIfe),'')
				||"|"||NVL(TRIM(cInteriorIfe),'')||"|"||NVL(iNumSucursal,0) --; --DSB-03/02/2016 FIN
				--CAMPOS A FUTURO RQM-598.1
				||"|"||cFlag_ProductoCoppel||"|"||cFlag_MotosCoppel||"|"||cCtepresentoCompIng||"|"||iTelefonoClienteLada||"|"||iTelefonoCliente
				||"|"|| iCelularClienteLada||"|"|| iCelularCliente||"|"|| iCampoFuturo8||"|"|| iCampoFuturo9||"|"|| iCampoFuturo10;
	END IF;

	RETURN  vCodRet,v_Cadena||"|"||v_Cadena2||"|"||v_Cadena3||"|";
END;
END PROCEDURE

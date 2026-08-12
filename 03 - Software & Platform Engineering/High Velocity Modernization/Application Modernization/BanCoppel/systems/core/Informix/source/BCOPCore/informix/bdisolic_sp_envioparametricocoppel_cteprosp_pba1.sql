CREATE PROCEDURE "informix".sp_envioparametricocoppel_cteprosp_pba1(p_Empresa CHAR(3), p_NumCte VARCHAR(20), p_NumSolicitud CHAR(20),pTipoCliente INTEGER)

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
	DEFINE cFolioConsul 	CHAR(9); --Folio Consulta
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
	--RQM 18 055-4y5 GeneraciÃ³n de OS Calle a Clientes Prospecto.pdf
	DEFINE iCiudad			INTEGER;
	DEFINE iColonia			INTEGER;
	DEFINE cSucursal		CHAR(4);
	DEFINE dFechaCaptura	DATE;
	DEFINE vcDescripcion	VARCHAR(80);
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
	DEFINE cTipoSolicitud				CHAR(1);	--DEFINE cVariable11	CHAR(1); hsrr 
	DEFINE cDomicilioGeolocalizado		CHAR(1);	--DEFINE cVariable12	CHAR(1); hsrr 
	DEFINE cVariable13					CHAR(1);
	DEFINE cVariable14					CHAR(1);
	DEFINE cVariable15					CHAR(1);
	DEFINE iVariable16					INTEGER;
	DEFINE iVariable17					INTEGER;
	DEFINE sCiclo						SMALLINT;
	DEFINE sElemento					SMALLINT;
	DEFINE iNumCdCoppel					INTEGER;
	DEFINE cPuntualidadconyoref1		CHAR(1);
	DEFINE cPuntualidadconyoref2		CHAR(1);
	DEFINE iNumHabDomTrabajan			INTEGER;
	DEFINE cYearsOcupacion				CHAR(2);
	DEFINE vcTiempoDeOcupacion			VARCHAR(80);
	DEFINE cNumCtePros					CHAR(10);
	DEFINE iVariable17Titular			INTEGER;
	DEFINE iVariable16Titular			INTEGER;
	DEFINE cVariable15Titular			CHAR(1);
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
	DEFINE cTipoSolicitudTitular		CHAR(1);	--cVariable11Titular	CHAR(1); hsrr
	DEFINE cDomicilioGeolocalizadoTitular	CHAR(1); --cVariable12	CHAR(1); hsrr
	DEFINE cVariable13Titular 			CHAR(1);
	DEFINE cVariable14Titular			CHAR(1);
	DEFINE sNumCdSucursal				SMALLINT;
	DEFINE dtFechaHoy					DATE;
--RQM 18 055-4y5 GeneraciÃ³n de OS Calle a Clientes Prospecto.pdf
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
	DEFINE cNumSucursal			CHAR(4);
	DEFINE iSecuencia			INTEGER;
	DEFINE cEnviaOs				CHAR(1);
	DEFINE dFechaHoy			DATE;
	DEFINE iSecRef1				INTEGER;
	DEFINE iSecMenor			INTEGER;
--IPCB 13sep2016
	DEFINE id_respuesta			INT8;
	
	--DEFINE scont		INT8;
	DEFINE cGeoCli 		CHAR(20); --387 validar puntos de coordenada cte
	DEFINE cFLagDomAlta	CHAR(1); --387 validar domicilio cte
	DEFINE cFolioMovil  CHAR(20); --387 validar geolocalizacion
	
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
	LET cTimEdoCiv   	= TO_CHAR(CURRENT,'%Y-%m-%d');
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
	--RQM 18 055-4y5 GeneraciÃ³n de OS Calle a Clientes Prospecto.pdf
	LET iCiudad			= 0;
	LET sNumCdSucursal	= 0;
	LET iColonia	    = 0;
	LET cSucursal		= " ";
	LET dFechaCaptura   = DATE(1);
	LET vcDescripcion	= " ";
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
	LET cVariable13				= " ";
	LET cVariable14				= " ";
	LET cVariable15				= " ";
	LET iVariable16				= 0;
	LET iVariable17				= 0;
	LET sCiclo					= 0;
	LET sElemento				= 0;
	LET iNumCdCoppel			= 0;
	LET iNumHabDomTrabajan      = 0;
	LET cYearsOcupacion		= " ";
	LET vcTiempoDeOcupacion		= " ";
	LET iVariable17Titular 		= " ";
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
	LET cTipoSolicitudTitular 		= " "; --cVariable11	CHAR(1); hsrr
	LET cDomicilioGeolocalizadoTitular		= " "; --cVariable12	CHAR(1); hsrr
	LET cVariable13Titular 		= " ";
	LET cVariable14Titular 		= " ";
	LET iVariable16Titular		= 0;
	LET cVariable15Titular		= " ";
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
	LET cNumSucursal		= "0";
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

BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN  vCodRet, 'NULL';
		END IF;
	END EXCEPTION;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

--	  SET DEBUG FILE TO "/pisa/pisabanco/sp_envioparametricocoppel_cteprosp.out";
--	  TRACE ON;

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
			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = p_NumCte) THEN
				--NumeroCiudad y NumeroColonia
				SELECT a.numerociudadcoppel, a.numerocoloniacoppel
				INTO sNumCd, sNumCol
				FROM bdinteg:"informix".si_catzonas a
				WHERE a.numerociudad = (SELECT b.numerociudad FROM bdinteg:"informix".si_direcciones_actual b WHERE b.numcte = p_NumCte AND b.tipo_dir = 1)
				AND a.numerocolonia =(SELECT c.numerocolonia FROM bdinteg:"informix".si_direcciones_actual c WHERE c.numcte = p_NumCte and c.tipo_dir = 1);
			END IF;

			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = p_NumCte) THEN
				--TipoDeCasa, Genero, EstadoCivil, FechaNacimiento,HabitantesEnDomicilio
				SELECT ctepf.habita_en, ctepf.sexo, ctepf.estado_civil, TO_CHAR(ctepf.fecha_nac, '%Y-%m-%d'), CAST(cte.string2 AS SMALLINT)
				INTO cTipoCasa, cGenero, cEdoCivil, cFecNac, sHabDom
				FROM bdinteg:"informix".si_ctepf ctepf, bdinteg:"informix".si_cliente cte
				WHERE ctepf.numcte = p_NumCte AND cte.numcte = p_NumCte;

				--FechaEvaluacion
				SELECT TO_CHAR(fecha_hoy, '%Y-%m-%d') INTO cFecHoy FROM bdicred:"informix".sd_fechas;
			END IF;

			IF EXISTS(SELECT num_solicitud FROM bdisolic:"informix".ss_detalle_scoring WHERE num_solicitud = p_NumSolicitud) THEN
				--Tiempo de Residencia
				SELECT SUBSTR(descripcion,1,2)
				INTO cResidencia
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 6 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 6 AND num_solicitud = p_NumSolicitud);

				--RTV
				SELECT fecha_insert, sucursal--dsb-07/11/2012
					INTO dtFechSol, cFolioSucursal
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;

				--dsb-07/11/2012
				IF NVL(sNumCd, 0) = 0 THEN
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
					INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
					INTO sNumCd FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
				END IF;
				IF NVL(sNumCol, 0) = 0 THEN
					SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad) = 'V' THEN ciudad::INTEGER ELSE 0 END
					INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

					SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerocoloniacoppel) = 'V' THEN numerocoloniacoppel::INTEGER ELSE 0 END
					INTO sNumCol FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerocoloniacoppel <> 0 AND numerocoloniacoppel IS NOT NULL;
				END IF;

				IF MONTH(dtFechSol) = 2 AND DAY (dtFechSol) = 29 THEN
					LET dtFechSol = dtFechSol -1 units DAY;
				END IF;

				LET cTiempReside = dtFechSol - cResidencia::INTEGER units YEAR;

				--Nivel de escolaridad
				SELECT elemento
				INTO cEscolaridad
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 21 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 21 AND num_solicitud = p_NumSolicitud);

				--Numero de dependientes
				SELECT descripcion::INTEGER
				INTO sDependiente
				FROM bdisolic:"informix".ss_scoring_element
				WHERE grupo = 11 AND elemento = (SELECT elemento FROM bdisolic:"informix".ss_detalle_scoring WHERE grupo = 11 AND num_solicitud = p_NumSolicitud);

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

				IF (cEdoCivil <> "S") THEN
					--TiempoDeEstadoCivil(AÃOS)
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

			IF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = p_NumSolicitud) THEN
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

			IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_ingresos WHERE numcte = p_NumCte) THEN
				--Opcion del Puesto, SubOpcion del Puesto
				SELECT claveopcionpuesto, clavesubopcionpuesto
				INTO sOpcionPuesto, sSubOpcioPuesto
				FROM bdinteg:"informix".si_ingresos
				WHERE empresa = p_Empresa
				AND numcte = p_NumCte AND tipo_ingreso = 'T'
				AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = p_NumCte AND tipo_ingreso = 'T');
			ELSE
				IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_bitacoraapertura WHERE numcte = p_NumCte) THEN
					SELECT id_act, id_subact
					INTO sOpcionPuesto, sSubOpcioPuesto
					FROM bdinteg:"informix".si_bitacoraapertura
					WHERE numcte = p_NumCte AND id_pregunta = 6
					AND id_secuencia = (SELECT MAX(id_secuencia) FROM bdinteg:"informix".si_bitacoraapertura WHERE numcte = p_NumCte);
				END IF;
			END IF;

			--NumeroCredito
			LET iNumCred = CAST(TRIM(p_NumSolicitud) AS INT8);

			IF EXISTS (SELECT num_solicitud_sic FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud) THEN
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
				IF EXISTS (SELECT numcte FROM bdiburo:"informix".br_traslado WHERE numcte = p_NumCte) THEN
					SELECT institucion
					INTO cInstitucion
					FROM bdiburo:"informix".br_traslado
					WHERE numcte = p_NumCte AND rowid = (SELECT MAX(rowid) FROM bdiburo:"informix".br_traslado  WHERE numcte = p_NumCte);
				END IF;
			END IF;

			IF EXISTS(SELECT num_cliente FROM bdiburo:"informix".br_rs WHERE num_cliente = p_NumCte AND institucion = cInstitucion AND rs34 IS NOT NULL) THEN

				--Se modifica la forma de obtener la informacion del segmento rs. RTV - 2012/04/11
				SELECT MIN(rowid) INTO iRenglonMinimo FROM bdiburo:"informix".br_rs
				WHERE num_cliente = p_NumCte AND institucion = cInstitucion;

				--Meses de AntigÃ¼edad
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

			IF EXISTS(SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = p_NumSolicitud) THEN
				--ClienteBCPL
				SELECT CAST(numcte AS INTEGER)
				INTO iCteBCPL
				FROM bdisolic:"informix".ss_solicitudes
				WHERE numcte = p_NumCte AND num_solicitud = p_NumSolicitud;
			END IF;

			IF EXISTS(SELECT num_solicitud FROM bdiburo:"informix".sb_regreso WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion) THEN
				--RespuestaSIC
				SELECT TRIM(regreso)
				INTO cResSIC
				FROM bdiburo:"informix".sb_regreso
				WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion;

				--FolioConsulta
				EXECUTE PROCEDURE bdisolic:"informix".sp_instr(2,cResSIC,'ES05') INTO vCodRet, iLogFinal;

				SELECT SUBSTR(regreso,(iLogFinal+13),9)
				INTO cFolioConsul
				FROM bdiburo:"informix".sb_regreso
				WHERE institucion = cInstitucion AND num_solicitud = p_NumSolicitud;
            ELIF EXISTS(SELECT 1 num_solicitud FROM bdiburo:"informix".br_respuesta WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion) THEN
			--IPCB13sep2016 Se incluye la consulta del id de la respuesta para evitar duplicados.				
					SELECT min(idrespuesta) 
					INTO id_respuesta
					FROM bdiburo:"informix".br_respuesta
					WHERE num_solicitud = p_NumSolicitud AND institucion = cInstitucion
					AND secuencia = 1;

                    SELECT TRIM(regreso)
                    INTO cResSIC
                    FROM bdiburo:"informix".br_respuesta
                    WHERE idrespuesta = id_respuesta and num_solicitud = p_NumSolicitud AND institucion = cInstitucion
                    AND secuencia = 1;

                    --FolioConsulta
                    EXECUTE PROCEDURE bdisolic:"informix".sp_instr(2,cResSIC,'ES05') INTO vCodRet, iLogFinal;

                    SELECT SUBSTR(regreso,(iLogFinal+13),9)
                    INTO cFolioConsul
                    FROM bdiburo:"informix".br_respuesta
                    WHERE idrespuesta = id_respuesta and institucion = cInstitucion AND num_solicitud = p_NumSolicitud
                    AND secuencia = 1;
			END IF;

			IF EXISTS (SELECT solicitud FROM bdiburo:"informix".br_auditor WHERE solicitud = p_NumSolicitud) THEN
				--FechaConsultaSIC
				SELECT TO_CHAR(fecha,'%Y-%m-%d')
				INTO cFechaSIC
				FROM bdiburo:"informix".br_auditor
				WHERE solicitud = p_NumSolicitud AND institucion = cInstitucion
				AND rowid = (SELECT MAX(rowid) FROM bdiburo:"informix".br_auditor WHERE solicitud = p_NumSolicitud AND institucion = cInstitucion);
			END IF;
-- JOM INI RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
	-- NÃºmero de habitantes en el domicilio que trabajan
		SELECT elemento
		  INTO iVar06
		  FROM bdisolic:"informix".ss_detalle_scoring
		 WHERE num_solicitud = p_NumSolicitud
		   AND grupo = 39;

		IF (iVar06 is null) THEN LET iVar06 = 0; END IF;

-- Telefono de casa
		SELECT first 1 cofetel
		  INTO vcasa
		  FROM bdinteg:"informix".si_telefonos_actual
		 WHERE numcte = p_NumCte
		   AND tipo_tel = 1;

		IF (vcasa is null) THEN
			LET vcasa = 'F';
		END IF;

-- Telefono de trabajo
		SELECT first 1 cofetel
		  INTO vcelular
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

-- Referencia 1
		SELECT parentesco, numerociudad, numerocolonia
		  INTO cVar01, ref1numerociudad, ref1numerocolonia
		  FROM bdinteg:"informix".si_refclientes a,
			   bdinteg:"informix".si_refdirecciones b
		 WHERE empresa  = p_Empresa
		   AND a.numcte = p_NumCte
		   AND a.numcte = b.numcte
		   AND a.secuencia = (SELECT MIN(secuencia)
							  FROM bdinteg:"informix".si_refclientes
							 WHERE a.empresa = empresa
							   AND a.numcte = numcte
							   AND num_solicitud = p_NumSolicitud)
		   AND a.secuencia = b.secuencia;

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
			INTO ref1numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
		END IF;

		IF NVL(ref1numerociudad, 0) = 0 THEN
			LET ref1numerociudad = -99;
		END IF;

-- Referencia 2
		SELECT numerociudad, numerocolonia
		  INTO ref2numerociudad, ref2numerocolonia
		  FROM bdinteg:"informix".si_refclientes a,
			   bdinteg:"informix".si_refdirecciones b
		 WHERE empresa  = p_Empresa
		   AND a.numcte = p_NumCte
		   AND a.numcte = b.numcte
		   AND a.secuencia = (SELECT MAX(secuencia)
							  FROM bdinteg:"informix".si_refclientes
							 WHERE a.empresa = empresa
							   AND a.numcte = numcte
							   AND num_solicitud = p_NumSolicitud)
		   AND a.secuencia = b.secuencia;

		SELECT first 1 numerociudadcoppel
		INTO ref2numerociudad
		FROM bdinteg:"informix".si_catzonas
		WHERE numerociudad  = ref2numerociudad
		  AND numerocolonia = ref2numerocolonia;

		IF NVL(ref2numerociudad, 0) = 0 THEN
			SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(ciudad)  = 'V' THEN ciudad::INTEGER ELSE 0 END
			INTO iCiudadBanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;

			SELECT FIRST 1 CASE WHEN bdinteg:"informix".sp_EsNumerico(numerociudadcoppel) = 'V' THEN numerociudadcoppel::INTEGER ELSE 0 END
			INTO ref2numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudad = iCiudadBanco AND numerociudadcoppel <> 0 AND numerociudadcoppel IS NOT NULL;
		END IF;

		IF NVL(ref2numerociudad, 0) = 0 THEN
			LET ref2numerociudad = -99;
		END IF;

		--Numero de cliente prospecto

		SELECT numcte_pros
		INTO cNumCteProsTitular
		FROM bdiprospectos:"informix".pr_cliente
		WHERE numcte = p_NumCte;

		LET iVar07 = ref1numerociudad;
		LET iVar08 = ref2numerociudad;
		--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 INICIO
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdinteg:"informix".si_fechas;

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
		-- CIB-16/05/2018 	"SE COMENTA BLOQUE DE CODIGO PRODUCTIVO"  INICIA
		/*
			SELECT ciu.ciudad_coppel
			INTO sCiudadIfe
			FROM bdinteg:"informix".si_ciudades ciu,
				bdinteg:"informix".si_estados edo,
				bdinteg:"informix".si_direcciones_actual dir
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND dir.secuencia = (SELECT MAX((secuencia) -1)
								 FROM bdinteg:"informix".si_direcciones_actual
								 WHERE numcte = p_NumCte
								 AND tipo_dir = 1)
			AND edo.estado = dir.estado
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				SELECT FIRST 1 cat.numerociudad
				INTO sCiudadIfe
				FROM bdinteg:"informix".si_catzonas cat,
					bdinteg:"informix".si_ciudades ciu,
					bdinteg:"informix".si_sucursales suc
				WHERE suc.empresa = p_Empresa
				AND suc.sucursal IN (SELECT sucursal
									 FROM bdinteg:"informix".si_cliente
									 WHERE empresa = p_Empresa
									 AND numcte = p_NumCte)
				AND ciu.ciudad = suc.ciudad
				AND ciu.estado = suc.estado
				AND cat.numerociudad = ciu.ciudad_coppel;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET sCiudadIfe = 0;
				END IF;
				IF NVL(sCiudadIfe,0) = 0 THEN
					LET sCiudadIfe = 0;
				END IF;
			END IF;

			SELECT cat.numerocoloniacoppel
			INTO iColoniaIfe
			FROM bdinteg:"informix".si_catzonas cat,
				 bdinteg:"informix".si_direcciones_actual dir,
				 bdinteg:"informix".si_ciudades ciu
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND dir.secuencia = (SELECT MAX((secuencia) -1)
								 FROM bdinteg:"informix".si_direcciones_actual
								 WHERE numcte = p_NumCte
								 AND tipo_dir = 1)
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado
			AND cat.numerociudad = ciu.ciudad_coppel
			AND cat.numerocolonia = dir.numerocolonia;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				SELECT FIRST 1 cat.numerocoloniacoppel
				INTO iColoniaIfe
				FROM bdinteg:"informix".si_catzonas cat,
					 bdinteg:"informix".si_ciudades ciu,
					 bdinteg:"informix".si_sucursales suc
				WHERE suc.empresa = p_Empresa
				AND suc.sucursal IN (SELECT sucursal
									 FROM bdinteg:"informix".si_cliente
									 WHERE empresa = p_Empresa
									 AND numcte = p_NumCte)
				AND ciu.ciudad = suc.ciudad
				AND ciu.estado = suc.estado
				AND cat.numerociudad = ciu.ciudad_coppel;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET iColoniaIfe = 0;
				END IF;
				IF NVL(iColoniaIfe,0) = 0 THEN
					LET iColoniaIfe = 0;
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
			AND dir.secuencia = (SELECT MAX((secuencia) -1)
								 FROM bdinteg:"informix".si_direcciones_actual
								 WHERE numcte = p_NumCte
								 AND tipo_dir = 1)
			AND edo.estado = dir.estado
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado
			AND sica.numerocalle = dir.numerocalle;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET iCalleIfe = 0;
			END IF;
			IF NVL(iCalleIfe,0) = 0 THEN
				LET iCalleIfe = 0;
			END IF;

			SELECT numeroextcalle
			INTO cCasaIfe
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte
			AND tipo_dir = 1
			AND secuencia = (SELECT MAX((secuencia) -1)
						     FROM bdinteg:"informix".si_direcciones_actual
						     WHERE numcte = p_NumCte
						     AND tipo_dir = 1);

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCasaIfe = " ";
			END IF;
			IF NVL(cCasaIfe,"") = "" THEN
				LET cCasaIfe = " ";
			END IF;

			SELECT numerointcalle
			INTO cInteriorIfe
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte
			AND tipo_dir = 1
			AND secuencia = (SELECT MAX((secuencia) -1)
						     FROM bdinteg:"informix".si_direcciones_actual
						     WHERE numcte = p_NumCte
						     AND tipo_dir = 1);

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cInteriorIfe = " ";
			END IF;
			IF NVL(cInteriorIfe,"") = "" THEN
				LET cInteriorIfe = " ";
			END IF;
		-- CIB-16/05/2018	"SE COMENTA BLOQUE DE CODIGO PRODUCTIVO"  TERMINA
		*/
		
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
			-- CIB-16/05/2018 	"SE COMENTA BLOQUE DE CODIGO 2 PRODUCTIVO"  INICIA
			/*
			SELECT ciu.ciudad_coppel
			INTO sCiudadIfe
			FROM bdinteg:"informix".si_ciudades ciu,
				 bdinteg:"informix".si_estados edo,
				 bdinteg:"informix".si_direcciones_actual dir
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND dir.secuencia = (SELECT MAX(secuencia)
								 FROM bdinteg:"informix".si_direcciones_actual
								 WHERE numcte = p_NumCte
								 AND tipo_dir = 1)
			AND edo.estado = dir.estado
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET sCiudadIfe = 0;
			END IF;
			IF NVL(sCiudadIfe,0) = 0 THEN
				LET sCiudadIfe = 0;
			END IF;

			SELECT cat.numerocoloniacoppel
			INTO iColoniaIfe
			FROM bdinteg:"informix".si_catzonas cat,
				bdinteg:"informix".si_direcciones_actual dir,
				bdinteg:"informix".si_ciudades ciu
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND dir.secuencia = (SELECT MAX(secuencia)
								 FROM bdinteg:"informix".si_direcciones_actual
								 WHERE numcte = p_NumCte
								 AND tipo_dir = 1)
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado
			AND cat.numerociudad = ciu.ciudad_coppel
			AND cat.numerocolonia = dir.numerocolonia;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET iColoniaIfe = 0;
			END IF;
			IF NVL(iColoniaIfe,0) = 0 THEN
				LET iColoniaIfe = 0;
			END IF;

			SELECT sica.numerocalle
			INTO iCalleIfe
			FROM bdinteg:"informix".si_catcalles sica,
				 bdinteg:"informix".si_direcciones_actual dir,
				 bdinteg:"informix".si_estados edo,
				 bdinteg:"informix".si_ciudades ciu
			WHERE dir.numcte = p_NumCte
			AND dir.tipo_dir = 1
			AND dir.secuencia = (SELECT MAX(secuencia)
								 FROM bdinteg:"informix".si_direcciones_actual
								 WHERE numcte = p_NumCte
								 AND tipo_dir = 1)
			AND edo.estado = dir.estado
			AND ciu.ciudad = dir.ciudad
			AND ciu.estado = dir.estado
			AND sica.numerocalle = dir.numerocalle;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET iCalleIfe = 0;
			END IF;
			IF NVL(iCalleIfe,0) = 0 THEN
				LET cCasaIfe = 0;
			END IF;

			SELECT numeroextcalle
			INTO cCasaIfe
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte
			AND tipo_dir = 1
			AND secuencia = (SELECT MAX(secuencia)
						     FROM bdinteg:"informix".si_direcciones_actual
						     WHERE numcte = p_NumCte
						     AND tipo_dir = 1);

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCasaIfe = " ";
			END IF;
			IF NVL(cCasaIfe,"") = "" THEN
				LET cCasaIfe = " ";
			END IF;

			SELECT  numerointcalle
			INTO  cInteriorIfe
			FROM bdinteg:"informix".si_direcciones_actual
			WHERE numcte = p_NumCte
			AND tipo_dir = 1
			AND secuencia = (SELECT MAX(secuencia)
						     FROM bdinteg:"informix".si_direcciones_actual
						     WHERE numcte = p_NumCte
						     AND tipo_dir = 1);

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cInteriorIfe = " ";
			END IF;
			IF NVL(cInteriorIfe,"") = "" THEN
				LET cInteriorIfe = " ";
			END IF;
			-- CIB-16/05/2018 	"SE COMENTA BLOQUE DE CODIGO 2 PRODUCTIVO"  TERMINA
		*/
		
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
		
		SELECT sucursal
		INTO cNumSucursal
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = p_Empresa
		AND numcte = p_NumCte;
 
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNumSucursal = "0";
		END IF;
		
		LET cNumCred = LEFT(TRIM(p_NumSolicitud),12);
		
		--hsrr folio 387, IDUG 387
		SELECT folio,NVL(geolocalizacion, ''),domicilio_alta 
		INTO cFolioMovil, cGeoCli, cFLagDomAlta 
		FROM bdinteg:"informix".si_solicitud_movil 
		--WHERE num_tdc_coppel::INT8 = inumcred; --DSB-22/12/2018
		WHERE num_tdc_coppel = cNumCred;
		
		--IDUG 387 se valida la geolocalizacion para coppel
		IF TRIM(cFolioMovil) <> '' THEN
			LET cTipoSolicitudTitular = 'M';
			
			IF LEN(NVL(TRIM(cGeoCli),'')) > 10 AND (NVL(cFLagDomAlta,'') = 'S' ) THEN
				IF (NOT EXISTS (SELECT id_ptf FROM bdinteg:"informix".si_ptf  WHERE TRIM(latitud)||","||TRIM(longitud) = TRIM(cGeoCli))) THEN --Domocilio Geolocalizado diferente al de sucursal
					LET cDomicilioGeolocalizadoTitular = 'S';
				ELSE
					LET cDomicilioGeolocalizadoTitular = 'N';
				END IF;
				
			ELSE
				LET cDomicilioGeolocalizadoTitular = 'N';
			END IF;

		END IF;
		
--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 FIN
		-- JOM FIN RQM 18 054 Envio de variables en la recalibracion del parametrico Coppel
		LET v_Cadena = sClave||"|"||TRIM(cSubClave)||"|"||NVL(iValorSeguridad,0)||"|"||NVL(iVersion,0)||"|"||NVL(sNumCd,0)||"|"||NVL(sNumCol,0)||"|"||NVL(cTipoCasa,'')||"|"||NVL(cGenero,'')
						 ||"|"||NVL(cEdoCivil,'')||"|"||NVL(cFecNac,'')||"|"||NVL(cTiempReside,'')||"|"||NVL(sHabDom,0)||"|"||NVL(cEscolaridad,'')||'|'||NVL(sDependiente,0)
						 ||'|'||NVL(sNivIngreso,0)||'|'||NVL(cPuesto,'')||"|"||NVL(sOpcionPuesto,0)||"|"||NVL(sSubOpcioPuesto,0)||"|"||NVL(cTiempoDesc,'')||"|"||NVL(cTimEdoCiv,'')
						 ||"|"||NVL(cFecHoy,'')||"|"||NVL(sMesesAntiguedad,0)||"|"||NVL(sPeorPago,0)||"|"||NVL(sNumSols,0)||"|"||NVL(iCteBCPL,0)||"|"||NVL(iNumCred,0)
						 ||"|"||NVL(cInstitucion,'')||"|"||NVL(cFolioConsul,'')||"|"||NVL(cFechaSIC,'')||"|"||NVL(iIngMensual,0);

		LET v_Cadena2 = NVL(cResSIC,'');

		LET v_Cadena3 = cVar01||"|"||cVar02||"|"||cVar03||"|"||cVar04||"|"||cVar05||"|"||iVar06||"|"||iVar07||"|"||iVar08
				||"|"||iVar09||"|"||iVar10||"|"||NVL(cNumCteProsTitular,'')||"|"||NVL(cRespPreg1Titular,'')||"|"||NVL(cRespPreg2Titular,'')||"|"||NVL(cRespPreg3Titular,'')||"|"||NVL(cRespPreg4Titular,'')
				||"|"||NVL(cRespPreg5Titular,'')||"|"||NVL(cRespPreg6Titular,'')||"|"||NVL(cRespPreg7Titular,'')||"|"||NVL(cRespPreg8Titular,'')||"|"||NVL(cRespPreg9Titular,'')
				||"|"||NVL(cResp2Preg9Titular,'')||"|"||NVL(cRespPreg10Titular,'')||"|"||NVL(cTipoSolicitudTitular,'')||"|"||NVL(cDomicilioGeolocalizadoTitular,'')||"|"||NVL(cVariable13Titular,'')
				||"|"||NVL(cVariable14Titular,'')||"|"||NVL(cVariable15Titular,'')||"|"||NVL(iVariable16Titular,0)||"|"||NVL(iVariable17Titular,0)

				||"|"||NVL(TRIM(cCasa),'')||"|"||NVL(iCalle,0)||"|"||NVL(TRIM(cRefCoppel1),'')||"|"||NVL(TRIM(cRefCoppel2),'')||"|"||NVL(TRIM(cCtePresentoIfe),'')--DSB-03/02/2016 INICIO
				||"|"||NVL(TRIM(cCtePresentoCompDom),'')||"|"||NVL(sCiudadIfe,0)||"|"||NVL(iColoniaIfe,0)||"|"||NVL(iCalleIfe,0)||"|"||NVL(TRIM(cCasaIfe),'')
				||"|"||NVL(TRIM(cInteriorIfe),'')||"|"||NVL(TRIM(cNumSucursal),''); --DSB-03/02/2016 FIN
	END IF;

	IF pTipoCliente = 2 THEN
		--CLIENTE PROSPECTO O TIPO 3
		IF NVL(p_Empresa,' ') = ' ' OR NVL(p_NumSolicitud,' ') = ' ' THEN
		LET vCodRet = '00004';
		RETURN  vCodRet, 'SI EL TIPO DE CLIENTE ES 2 NO PUEDEN SER NULOS LOS PARAMETROS DE EMPRESA Y SOLICITUD';
		END IF;
		IF NOT EXISTS(SELECT numcte_pros FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud) THEN
			LET vCodRet = '00005';
			RETURN vCodRet,'NUMERO DE CLIENTE PROSPECTO NO EXISTE';
		END IF;
		LET cSubClave = '0032';
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.NumeroCiudad,NumeroColonia
		--Obtener el numero de Ciudad y Colonia del Cliente Prospecto.
		SELECT  NVL(numerociudad,0),NVL(numerocolonia,0)
		INTO iCiudad,iColonia
		FROM bdiprospectos:"informix".pr_direcciones
		WHERE numcte_pros = p_NumSolicitud
		AND tipo_dir =1
		AND secuencia = (SELECT MAX(secuencia) FROM  bdiprospectos:"informix".pr_direcciones WHERE numcte_pros = p_NumSolicitud AND tipo_dir =1 );
		--Hacer la relacion del domicilio del cliente con el catalogo de coppel para ver si existe.
		SELECT numerociudadcoppel,numerocoloniacoppel
		INTO sNumCd,sNumCol
		FROM bdinteg:"informix".si_catzonas
		WHERE numerociudad = iCiudad AND numerocolonia = iColonia;
		--Validar si el cliente prospecto tiene la direccion relacionada con el catalago coppel:
		IF NVL(sNumCd,0) =0  OR NVL(sNumCol,0) = 0 THEN --VALIDACION TOMADA DE REFERENCIA DEL sp_os_generaos_prospecto.
			SELECT sucursal INTO cSucursal FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;

			SELECT ciudad INTO sNumCdSucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;
			---SE DICE QUE SE DEBE DE OBTENER LA PRIMERA CIUDAD COPPEL, Â¿SE REFIERE AL CODIGO DE CIUDAD MAS PEQUEÃO?.
			SELECT FIRST 1 numerociudadcoppel,numerocoloniacoppel INTO sNumCd,sNumCol FROM bdinteg:"informix".si_catzonas WHERE numerociudad = sNumCdSucursal;
		END IF;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.TipoDeCasa,Genero,EstadoCivil,FechaNacimiento

		--Datos de la persona fisica.
		SELECT 	habita_en,sexo,bdisolic:"informix".fn_mapea_estado_civil(estado_civil), TO_CHAR(fecha_nac,'%Y-%m-%d')
		INTO cTipoCasa,cGenero,cEdoCivil,cFecNac
		FROM bdiprospectos:"informix".pr_ctepf
		WHERE empresa = p_Empresa
		AND numcte_pros = p_NumSolicitud;
		--Obtener la fecha captura.
		SELECT fecha_insert INTO dFechaCaptura FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;
		--Validar si la fecha de nacimiento es correcta.
		IF cFecNac < '1900-01-01' AND cFecNac > TO_CHAR(dFechaCaptura,'%Y-%m-%d') THEN
			SELECT TO_CHAR(fecha_hoy,'%Y-%m-%d') INTO cFecNac FROM bdicred:"informix".sd_fechas;
		END IF;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.TiempoDeResidencia
		LET sElemento = 0;
		SELECT elemento INTO sElemento FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 6 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 6 AND num_solicitud = p_NumSolicitud);

		SELECT descripcion --NOTA: Obtener Ãºnicamente el nÃºmero de aÃ±os.
		INTO vcDescripcion
		FROM bdiprospectos:"informix".pr_scoring_element
		WHERE grupo = 6
		AND elemento = sElemento;

		--OBTENER SOLO LOS AÃOS DEL TIEMPO DE RESIDENCIA.
		LET vcDescripcion = vcDescripcion;
		LET sCiclo = 0;
		LET cCaracter = " ";
		IF NVL(vcDescripcion,' ') = ' ' THEN
			LET cYears = '0';
		ELSE
			FOR sCiclo = 1 TO LENGTH(vcDescripcion)
				LET cCaracter = SUBSTR(vcDescripcion,sCiclo,1);

				IF (cCaracter BETWEEN "0" AND "9") THEN
				   LET cYears = TRIM(cYears) || cCaracter;
				ELSE
					EXIT FOR;
				END IF;
			END FOR;
		END IF;
		IF NVL(cYears,"0") <> "0" THEN
			IF MONTH(dFechaCaptura) = 2 AND DAY (dFechaCaptura) = 29 THEN
					LET dFechaCaptura = dFechaCaptura -1 units DAY;
			END IF;
			LET cTiempReside = dFechaCaptura - cYears::INTEGER units YEAR;
		END IF;
		--VALIDACION;
		IF cTiempReside < cFecNac THEN
			SELECT TO_CHAR(fecha_hoy,'%Y-%m-%d') INTO cTiempReside FROM bdicred:"informix".sd_fechas;
		END IF;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL. HabitantesEnDomicilio
		SELECT string2 INTO sHabDom FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.NivelDeEscolaridad
		LET sElemento = 0;
		SELECT elemento INTO cEscolaridad FROM bdiprospectos:"informix".pr_detalle_scoring WHERE grupo = 21 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 21 AND num_solicitud = p_NumSolicitud);
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.NumDeDependientes
		LET sElemento = 0;
		--SELECT elemento INTO sElemento FROM bdiprospectos:"informix".pr_detalle_scoring WHERE grupo = 11 AND num_solicitud = p_NumSolicitud;
		FOREACH	WITH HOLD
        SELECT elemento INTO sElemento FROM bdiprospectos:"informix".pr_detalle_scoring WHERE grupo = 11 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 11 AND num_solicitud = p_NumSolicitud)
		END FOREACH;

		--SELECT descripcion::INTEGER INTO sDependiente FROM bdiprospectos:"informix".pr_scoring_element WHERE grupo = 11 AND elemento = sElemento;
        SELECT SUBSTR(TRIM(descripcion),0,2)::INTEGER INTO sDependiente FROM bdiprospectos:"informix".pr_scoring_element WHERE grupo = 11 AND elemento = sElemento;
		---CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.NivelDeIngreso
		SELECT valor INTO cIngresoMensualParam FROM bdisolic:"informix".ss_param WHERE secuencia = 363;

		--SELECT ingreso_mensual INTO mIngresoMensual FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = p_NumSolicitud;
		SELECT a.ingreso_mensual INTO mIngresoMensual FROM bdiprospectos:"informix".pr_ingresos a WHERE a.numcte_pros = p_NumSolicitud
		AND a.sec_ingreso = (select max(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos
							where numcte_pros = a.numcte_pros);
		--FORMULA

		--LET sNivIngreso = CAST(ROUND((mIngresoMensual + (cIngresoMensualParam/2)) / cIngresoMensualParam)AS SMALLINT);
		LET sNivIngreso = ((((NVL(mIngresoMensual::DECIMAL(14,2),0))+(cIngresoMensualParam/2)))/cIngresoMensualParam)::SMALLINT;

		IF sNivIngreso < 1 THEN
			LET sNivIngreso = 1;
		END IF;

		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.Puesto
		LET cPuesto = "0";
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.OpcionPuesto,SubOpcionPuesto
		SELECT claveopcionpuesto,clavesubopcionpuesto
		INTO sOpcionPuesto,sSubOpcioPuesto
		FROM bdiprospectos:"informix".pr_ingresos
		WHERE empresa = p_Empresa
		AND numcte_pros = p_NumSolicitud
		AND tipo_ingreso = "T"  ----se agrega la siguiente linea porductiva
        AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = p_NumSolicitud AND tipo_ingreso = 'T');

		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.TiempoDeOcupacion
		LET sElemento = 0;
		SELECT elemento INTO sElemento  FROM bdiprospectos:"informix".pr_detalle_scoring WHERE grupo = 8 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 8 AND num_solicitud = p_NumSolicitud);
		--Y CON EL ELEMENTO:
		SELECT descripcion INTO vcTiempoDeOcupacion FROM bdisolic:"informix".ss_scoring_element WHERE grupo = 8 AND elemento = sElemento;
		LET cCaracter = ' ';
		LET sCiclo    = 0;
		IF NVL(vcTiempoDeOcupacion,' ') = ' ' OR SUBSTR(vcTiempoDeOcupacion,1,2) = 'No'THEN
			LET cYearsOcupacion = '0';
		ELSE
			FOR sCiclo = 1 TO LENGTH(vcTiempoDeOcupacion)
				LET cCaracter = SUBSTR(vcTiempoDeOcupacion,sCiclo,1);

				IF (cCaracter BETWEEN "0" AND "9") THEN
				   LET cYearsOcupacion = TRIM(cYearsOcupacion) || cCaracter;
				ELSE
					EXIT FOR;
				END IF;
			END FOR;
		END IF;
		IF NVL(cYearsOcupacion,"0") <> "0" THEN
			IF MONTH(dFechaCaptura) = 2 AND DAY (dFechaCaptura) = 29 THEN
				LET dFechaCaptura = dFechaCaptura -1 units DAY;
			END IF;
			LET cTiempoDesc = dFechaCaptura - cYearsOcupacion::INTEGER UNITS YEAR;
		ELSE
			SELECT TO_CHAR(fecha_hoy,'%Y-%m-%d') INTO cTiempoDesc FROM bdicred:"informix".sd_fechas;
		END IF;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.dTiempoDeEstadoCivil.
		--TiempoDeEstadoCivil (aÃ±os).
		IF NVL(TRIM(cEdoCivil),"") <> "S" THEN
			LET sElemento = 0;
			SELECT elemento INTO sElemento FROM bdiprospectos:"informix".pr_detalle_scoring WHERE grupo = 4 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 4 AND num_solicitud = p_NumSolicitud);
			--Y CON EL ELEMENTO BUSCAR LA descripcion EN:
			SELECT descripcion--Tomando solo el nÃºmero de aÃ±os.
			INTO vcTiempoDeEstadoCivilYears
			FROM bdiprospectos:"informix".pr_scoring_element
			WHERE grupo = 4
			AND elemento = sElemento;
			--OBTENER SOLO LOS AÃOS DEL TIEMPO DEL ESTADO CIVIL DEL CLIENTE.
			--Se limpia variable de ciclo
			LET cCaracter = '';
			LET sCiclo    = 0;
			IF NVL(vcTiempoDeEstadoCivilYears,' ') = ' ' OR SUBSTR(vcTiempoDeEstadoCivilYears,1,2) = 'No'THEN
				LET cYearsEdoCivilYears = '0';
			ELSE
				FOR sCiclo = 1 TO LENGTH(vcTiempoDeEstadoCivilYears)
					LET cCaracter = SUBSTR(vcTiempoDeEstadoCivilYears,sCiclo,1);

					IF (cCaracter BETWEEN "0" AND "9") THEN
					   LET cYearsEdoCivilYears = TRIM(cYearsEdoCivilYears) || cCaracter;
					ELSE
						EXIT FOR;
					END IF;
				END FOR;
			END IF;
			--VALIDAR SI TIENE AÃOS EN SU ESTADO CIVIL EL CLIENTE.
			IF NVL(cYearsEdoCivilYears,"0") <> "0" THEN
				IF MONTH(dFechaCaptura) = 2 AND DAY (dFechaCaptura) = 29 THEN
					LET dFechaCaptura = dFechaCaptura -1 units DAY;
				END IF;
					LET cTimEdoCiv = dFechaCaptura - cYearsEdoCivilYears::INTEGER UNITS YEAR;

			ELSE
				--TiempoDeEstadoCivil (meses).
				LET sElemento = 0;
				SELECT elemento INTO sElemento FROM bdiprospectos:"informix".pr_detalle_scoring WHERE grupo = 41 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 41 AND num_solicitud = p_NumSolicitud);
				--Y CON EL ELEMENTO BUSCAR LA DESCRIPCION EN:
				SELECT descripcion --Tomando solo el nÃºmero de meses.
				INTO vcTiempoDeEstadoCivilMonth
				FROM bdiprospectos:"informix".pr_scoring_element
				WHERE grupo = 41
				AND elemento = sElemento;
				--OBTENER SOLO LOS MESES DEL TIEMPO DEL ESTADO CIVIL DEL CLIENTE.
				--Se limpia variable de ciclo
				LET cCaracter = ' ';
				LET sCiclo    = 0;
				IF NVL(vcTiempoDeEstadoCivilMonth,' ') = ' 'OR SUBSTR(vcTiempoDeEstadoCivilMonth,1,2) = 'No' THEN
					LET cEdoCivilMonth = '0';
				ELSE
					FOR sCiclo = 1 TO LENGTH(vcTiempoDeEstadoCivilMonth)
						LET cCaracter = SUBSTR(vcTiempoDeEstadoCivilMonth,sCiclo,1);

						IF (cCaracter BETWEEN "0" AND "9") THEN
						   LET cEdoCivilMonth = TRIM(cEdoCivilMonth) || cCaracter;
						ELSE
							EXIT FOR;
						END IF;
					END FOR;
				END IF;
				---VALIDAR SI TIENE MESES EN SU ESTADO CIVIL EL CLIENTE.
				IF NVL(cEdoCivilMonth,"0") <> "0" THEN
					LET cTimEdoCiv = TO_CHAR(bdicred:"informix".monthadd(dFechaCaptura,cEdoCivilMonth::integer * -1),'%Y-%m-%d');
				ELSE
					--SELECT TO_CHAR(fecha_hoy,'%Y-%m-%d') INTO cTimEdoCiv FROM bdicred:"informix".sd_fechas;
					LET cTimEdoCiv = "1900-01-01";
				END IF;
			END IF;
		ELSE
			LET cTimEdoCiv = "1900-01-01";
		END IF;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL se enviaran por default.
		SELECT TO_CHAR(fecha_hoy, '%Y-%m-%d') INTO cFecHoy FROM bdicred:"informix".sd_fechas; --Se optiene fecha hoy
		LET sMesesAntiguedad = -1;
		LET sPeorPago = -1;
		LET sNumSols = -1;
		LET iCteBCPL = 0;
		LET iNumCred = 0;
		LET cInstitucion = 'NC';
		LET cFolioConsul = '';
		LET cFechaSIC = cFecHoy;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.IngresoMensual.
		SELECT CAST(ingreso_mensual AS INTEGER)
		INTO iIngMensual
		FROM bdiprospectos:"informix".pr_ingresos
		WHERE numcte_pros = p_NumSolicitud  ----se agrega la siguiente linea porductiva
         AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = p_NumSolicitud AND tipo_ingreso = 'T');
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.RespuestaSIC.
		LET cResSIC = '';
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.tiporeferencia.
		SELECT parentesco
		INTO cParentesco
		FROM bdiprospectos:"informix".pr_refclientes
		WHERE numcte_pros = p_NumSolicitud
		AND secuencia = (SELECT MIN(secuencia)FROM bdiprospectos:"informix".pr_refclientes WHERE numcte_pros = p_NumSolicitud);
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.Tipotelefono
		SELECT tipo_tel
		INTO sTipoTel
		FROM bdiprospectos:"informix".pr_telefonos
		WHERE tipo_tel = 1 ---(telÃ©fono de casa)
		AND numcte_pros = p_NumSolicitud;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.flagprospecto
		--VALIDAR CON EL NUMERO DE CLIENTE PROSPECTO PARA
		--DETERMINAR SI ES PROSPECTO NORMAL O DE ORIGEN ALTA MASIVA.
		SELECT id_empcob,numcte INTO iIdEmpCob,cCteTitular FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;
		--VALIDAR CON EL NUMERO DE CLIENTE BANCO SI EXISTE SIGNIFICA
		--QUE ES TITULAR.
		IF NVL(cCteTitular," ") <> " " THEN --CLIENTE TITULAR.
			LET cFlagProspecto = "1";
		ELIF iIdEmpCob = 0 THEN ---CLIENTES PROSPECTOS SIN IDENTIFICACIÃN OFICIAL.
		  LET cFlagProspecto = "2";
		ELIF iIdEmpCob <> 0 THEN --CLIENTES PROSPECTOS SIN IDENTIFICACIÃN OFICIAL CON ORIGEN EN UNA SOLICITUD MASIVA.
		  LET cFlagProspecto = "3";
		END IF;
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.Puntualidadconyoref1
		SELECT NVL(puntualidad," ")
		INTO  cPuntualidadconyoref1
		FROM bdiprospectos:"informix".pr_refclientes
		WHERE numcte_pros = p_NumSolicitud
			AND secuencia = (SELECT MIN(secuencia)
										   FROM bdiprospectos:"informix".pr_refclientes
										   WHERE numcte_pros = p_NumSolicitud );
		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.Puntualidadconyoref2
		SELECT NVL(puntualidad," ")
		INTO cPuntualidadconyoref2
		FROM bdiprospectos:"informix".pr_refclientes
		WHERE numcte_pros = p_NumSolicitud AND parentesco <> 'E'
		AND secuencia = (SELECT MAX(secuencia)
						FROM bdiprospectos:"informix".pr_refclientes
						WHERE numcte_pros = p_NumSolicitud );

		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.numhabdomtrabajan
		--SELECT CAST(string2 AS INTEGER) INTO iNumHabDomTrabajan FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;
		--SELECT CAST( descripcion AS INTEGER ) INTO iNumHabDomTrabajan FROM "informix".ss_scoring_element WHERE elemento = (SELECT elemento FROM bdiprospectos: "informix".pr_detalle_scoring  WHERE grupo=39 AND num_solicitud = p_NumSolicitud   );
		SELECT descripcion
		INTO iNumHabDomTrabajan
		FROM "informix".ss_scoring_element
		WHERE grupo = 39 AND elemento = (SELECT elemento
										 FROM bdiprospectos: "informix".pr_detalle_scoring
										 WHERE grupo = 39 AND num_solicitud = p_NumSolicitud and rowid = (select max(rowid) FROM bdiprospectos:"informix".pr_detalle_scoring  WHERE grupo = 39 AND num_solicitud = p_NumSolicitud)
										);








		--CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.ciudadreferencia1
		--OBTENER LA CIUDAD COPPEL DEL CLIENTE PROSPECTO.
		SELECT numerociudad
		INTO sNumCdCiudadReferencia1
		FROM bdiprospectos:"informix".pr_refdirecciones
		WHERE numcte_pros = p_NumSolicitud
		AND secuencia = (SELECT MIN(secuencia)FROM bdiprospectos:"informix".pr_refclientes WHERE numcte_pros = p_NumSolicitud);

		--VALIDAR SI NO EXISTE LA CIUDAD DEL CLIENTE PROSPECTO EN EL CATALAGO DE ZONAS.
		IF EXISTS(SELECT numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudadcoppel = sNumCdCiudadReferencia1) THEN
			LET iCiudadReferencia1 = sNumCdCiudadReferencia1; --Se asigna el numero de la ciudad coppel a la variable del cte prospecto.
		ELSE
			--OBTENER LA SUCURSAL DEL CLIENTE NO SE ESPECIFICA, SE HIZO EL FILTRO POR EL NUMERO DE CLIENTE PROSPECTO, Â¿ES CORRECTO?.
			SELECT sucursal INTO cSucursal FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;

			SELECT ciudad INTO sNumCdCiudadReferencia1 FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;

			--SE DICE QUE SE DEBE DE OBTENER LA PRIMERA CIUDAD COPPEL, Â¿SE REFIERE AL CODIGO DE CIUDAD MAS PEQUEÃO?.
			SELECT LIMIT 1 numerociudadcoppel INTO iNumCdCoppel FROM bdinteg:"informix".si_catzonas WHERE numerociudad = sNumCdCiudadReferencia1;

			LET iCiudadReferencia1 = iNumCdCoppel; --Se asigna el numero de la Ciudad a la variable.

			--SE VALIDA SI NO CAE EN LOS DOS CASOS ANTERIORES PARA ASIGNARLE EL -99 POR DEFAULT.
			IF NVL(iNumCdCoppel,0) = 0 THEN
				LET iCiudadReferencia1 = -99; ---Se le asigna el valor por DEFAULT.
			END IF;
		END IF;
		---CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.--ciudadreferencia2.
		SELECT numerociudad
		INTO sNumCdCiudadReferencia2
		FROM bdiprospectos:"informix".pr_refdirecciones
		WHERE numcte_pros = p_NumSolicitud
		AND secuencia = (SELECT MIN(secuencia)+1 FROM bdiprospectos:"informix".pr_refclientes WHERE numcte_pros = p_NumSolicitud);

		LET iCiudadReferencia2 = sNumCdCiudadReferencia2;

		--VALIDAR SI NO EXISTE LA CIUDAD DEL CLIENTE PROSPECTO EN EL CATALAGO DE ZONAS.
		IF EXISTS(SELECT numerociudad FROM bdinteg:"informix".si_catzonas WHERE numerociudadcoppel = sNumCdCiudadReferencia2) THEN
			--OBTENER LA SUCURSAL DEL CLIENTE NO SE ESPECIFICA, SE HIZO EL FILTRO POR EL NUMERO DE CLIENTE PROSPECTO, Â¿ES CORRECTO?.
			SELECT sucursal INTO cSucursal FROM bdiprospectos:"informix".pr_cliente WHERE numcte_pros = p_NumSolicitud;

			SELECT ciudad INTO sNumCdCiudadReferencia2 FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal;

			--SE DICE QUE SE DEBE DE OBTENER LA PRIMERA CIUDAD COPPEL, Â¿SE REFIERE AL CODIGO DE CIUDAD MAS PEQUEÃO?.
			SELECT MIN(numerociudadcoppel) INTO iNumCdCoppelCiudadReferencia2 FROM bdinteg:"informix".si_catzonas WHERE numerociudad = sNumCdCiudadReferencia2;

			LET iCiudadReferencia2 = iNumCdCoppelCiudadReferencia2;

			--SE VALIDA SI NO CAE EN LOS DOS CASOS ANTERIORES PARA ASIGNARLE EL -99 POR DEFAULT.
			IF NVL(iNumCdCoppelCiudadReferencia2,0) = 0 THEN
				LET iCiudadReferencia2 = -99;
			END IF;
		END IF;

		---SE ACTUALIZA LA BANDERA DE QUE SE A ENVIADO LA INFORMACION A COPPEL.
		UPDATE bdiprospectos:"informix".pr_cliente
		SET envio_parametrico = 1
		WHERE numcte_pros = p_NumSolicitud
		AND envio_parametrico <> 4; --DSB 22/12/2018

		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas;


		--SI NO EXISTE EL REGISTRO DEL ESTATUS DE 'EC' (EVALUACION COPPEL) DE LA FECHA DE HOY SE INSERTA EL REGISTRO.
		IF NOT EXISTS (SELECT num_solicitud FROM bdiprospectos:"informix".pr_autorizacion WHERE num_solicitud = p_NumSolicitud AND status_solicitud = "EC" AND fecha_entrada = dtFechaHoy) THEN

			EXECUTE PROCEDURE bdiprospectos:"informix".sp_ctepr_actualizastatus('sistema',p_NumSolicitud,'EC','','')INTO vCodRet;

			IF vCodRet::INTEGER <> 0 THEN
				RETURN  vCodRet,"Error en la ejecucion del procedimiento bdiprospectos:sp_ctepr_actualizastatus.";
			END IF;
		END IF;
		--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 INICIO
		SELECT numeroextcalle
		INTO cCasa
		FROM bdiprospectos:"informix".pr_direcciones_actual
		WHERE numcte_pros = p_NumSolicitud
		AND tipo_dir = 1
		AND secuencia = (SELECT MAX(secuencia)
						 FROM bdiprospectos:"informix".pr_direcciones_actual
						 WHERE numcte_pros = p_NumSolicitud
						 AND tipo_dir = 1);
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCasa = "";
		END IF;

		SELECT numerocalle
		INTO iCalle
		FROM bdiprospectos:"informix".pr_direcciones_actual
		WHERE numcte_pros = p_NumSolicitud
		AND tipo_dir = 1
		AND secuencia = (SELECT MAX(secuencia)
						 FROM bdiprospectos:"informix".pr_direcciones_actual
						 WHERE numcte_pros = p_NumSolicitud
						 AND tipo_dir = 1);

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET iCalle = 0;
		END IF;

		SELECT MAX(secuencia)
		INTO iSecuencia
		FROM bdiprospectos:"informix".pr_refclientes
		WHERE empresa = p_Empresa
		AND numcte_pros = p_NumSolicitud;

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
		FROM bdiprospectos:"informix".pr_refclientes
		WHERE empresa = p_Empresa
		AND secuencia = iSecuencia -1
		AND numcte_pros = p_NumSolicitud;

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
			FROM bdiprospectos:"informix".pr_refclientes
			WHERE empresa = p_Empresa
			AND numcte_pros = p_NumSolicitud
			AND secuencia = iSecuencia;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cRefCoppel1 = "0";
			END IF;
			IF  NVL(cRefCoppel1,'') = '' THEN
				LET cRefCoppel1 = "0";
			END IF;
		ELIF iSecMenor = 1 THEN
			SELECT numcte_ref
			INTO cRefCoppel1
			FROM bdiprospectos:"informix".pr_refclientes
			WHERE empresa = p_Empresa
			AND numcte_pros = p_NumSolicitud
			AND secuencia = iSecuencia -1;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cRefCoppel1 = "0";
			END IF;
			IF  NVL(cRefCoppel1,'') = '' THEN
				LET cRefCoppel1 = "0";
			END IF;

			SELECT numcte_ref
			INTO cRefCoppel2
			FROM bdiprospectos:"informix".pr_refclientes
			WHERE empresa = p_Empresa
			AND numcte_pros = p_NumSolicitud
			AND secuencia = iSecuencia;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cRefCoppel2 = "0";
			END IF;
			IF  NVL(cRefCoppel2,'') = '' THEN
				LET cRefCoppel2 = "0";
			END IF;
		END IF;

		SELECT sucursal
		INTO cNumSucursal
		FROM bdiprospectos:"informix".pr_cliente
		WHERE empresa = p_Empresa
		AND numcte_pros = p_NumSolicitud;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNumSucursal = "0";
		END IF;

		LET cCtePresentoIfe		= " ";
		LET cCtePresentoCompDom	= " ";
		LET sCiudadIfe			= 0;
		LET iColoniaIfe			= 0;
		LET iCalleIfe			= 0;
		LET cCasaIfe			= "0";
		LET cInteriorIfe		= "0";
		--RQM 18 086 Modificaciones servicio Parametrico Coppel.pdf	 DSB-03/02/2016 INICIO
		/*CAMPOS PARA ENVIARSE EN LA TRAMA QUE SE ENVIARA A COPPEL.
		Variable 9,iVariable10,RespPreg1,cRespPreg2,cRespPreg3,cRespPreg4,cRespPreg5,cRespPreg6,cRespPreg7
		RespPreg8,RespPreg9,Resp2Preg9,RespPreg10,cTipoSolicitud,cDomicilioGeolocalizado,cVariable13,cVariable14,cVariable15,iVariable16*/
		LET iVariable9 = 0;
		LET iVariable10 = 0;
		LET cNumCtePros = p_NumSolicitud;
		LET cRespPreg1 = " ";
		LET cRespPreg2 = " ";
		LET cRespPreg3 = " ";
		LET cRespPreg4 = " ";
		LET cRespPreg5 = " ";
		LET cRespPreg6 = " ";
		LET cRespPreg7 = " ";
		LET cRespPreg8 = " ";
		LET cRespPreg9 = " ";
		LET cResp2Preg9 = " ";
		LET cRespPreg10 = " ";
		LET cTipoSolicitud = " ";
		LET cDomicilioGeolocalizado = " ";
		LET cVariable13 = " ";
		LET cVariable14 = " ";
		LET cVariable15 = " ";
		LET iVariable16 = 0;
		LET iVariable17 = 0;

		LET v_Cadena = sClave||"|"||TRIM(cSubClave)||"|"||NVL(iValorSeguridad,0)||"|"||NVL(iVersion,0)||"|"||NVL(sNumCd,0)||"|"||NVL(sNumCol,0)||"|"||NVL(cTipoCasa,'')||"|"||NVL(cGenero,'')
						 ||"|"||NVL(cEdoCivil,'')||"|"||NVL(cFecNac,'')||"|"||NVL(cTiempReside,'')||"|"||NVL(sHabDom,0)||"|"||NVL(cEscolaridad,'')||'|'||NVL(sDependiente,0)
						 ||"|"||NVL(sNivIngreso,0)||'|'||NVL(cPuesto,'')||"|"||NVL(sOpcionPuesto,0)||"|"||NVL(sSubOpcioPuesto,0)||"|"||NVL(cTiempoDesc,'')||"|"||NVL(cTimEdoCiv,'')
						 ||"|"||NVL(cFecHoy,'')||"|"||NVL(sMesesAntiguedad,0)||"|"||NVL(sPeorPago,0)||"|"||NVL(sNumSols,0)||"|"||NVL(iCteBCPL,0)||"|"||NVL(iNumCred,0)
						 ||"|"||NVL(cInstitucion,'')||"|"||TRIM(NVL(cFolioConsul,''))||"|"||NVL(cFechaSIC,'')||"|"||NVL(iIngMensual,0);

		LET v_Cadena2 = TRIM(NVL(cResSIC,''));

		LET v_Cadena3 = NVL(cParentesco,'')||"|"||NVL(sTipoTel,0)||"|"||NVL(cFlagProspecto,'')||"|"||NVL(cPuntualidadconyoref1,'')
				||"|"||NVL(cPuntualidadconyoref2,'')||"|"||NVL(iNumHabDomTrabajan,0)||"|"||NVL(iCiudadReferencia1,0)||"|"||NVL(iCiudadReferencia2,0)
				||"|"||NVL(iVariable9,0)||"|"||NVL(iVariable10,0)||"|"||NVL(cNumCtePros,'')||"|"||NVL(cRespPreg1,'')||"|"||NVL(cRespPreg2,'')
				||"|"||NVL(cRespPreg3,'')||"|"||NVL(cRespPreg4,'')||"|"||NVL(cRespPreg5,'')||"|"||NVL(cRespPreg6,'')||"|"||NVL(cRespPreg7,'')
				||"|"||NVL(cRespPreg8,'')||"|"||NVL(cRespPreg9,'')||"|"||NVL(cResp2Preg9,'')||"|"||NVL(cRespPreg10,'')||"|"||NVL(cTipoSolicitud,'')
				||"|"||NVL(cDomicilioGeolocalizado,'')||"|"||NVL(cVariable13,'')||"|"||NVL(cVariable14,'')||"|"||NVL(cVariable15,'')||"|"||NVL(iVariable16,0)||"|"||NVL(iVariable17,0)
				
        		||"|"||NVL(TRIM(cCasa),'')||"|"||NVL(iCalle,0)||"|"||NVL(TRIM(cRefCoppel1),'')||"|"||NVL(TRIM(cRefCoppel2),'')||"|"||NVL(TRIM(cCtePresentoIfe),'')--DSB-03/02/2016 INICIO
				||"|"||NVL(TRIM(cCtePresentoCompDom),'')||"|"||NVL(sCiudadIfe,0)||"|"||NVL(iColoniaIfe,0)||"|"||NVL(iCalleIfe,0)||"|"||NVL(TRIM(cCasaIfe),'')
				||"|"||NVL(TRIM(cInteriorIfe),'')||"|"||NVL(TRIM(cNumSucursal),''); --DSB-03/02/2016 FIN
		END IF;

	RETURN  vCodRet,v_Cadena||"|"||v_Cadena2||"|"||v_Cadena3||"|";
END;
END PROCEDURE

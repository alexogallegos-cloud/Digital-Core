CREATE PROCEDURE "informix".conscteeliminaadicional_web(pNumeroCuenta char(13),pTipo smallint)
	-- DATOS A REGRESAR 
	
	RETURNING
	char(5),	-- Codigo de retorno
	char(9),	-- Numero de Cliente
	char(26),	-- Apellido paterno
	char(26),	-- Apellido materno
	char(26),	-- Nombre 1
	char(26),	-- Nombre 2
	char(13),	-- RFC
	char(10),	--Fecha de Nacimiento
	char(20);	--Numero de tarjeta
	
	-- Declaracion de variables 
	DEFINE vCodRet		char(5);
	DEFINE vNumCte		char(20);
	DEFINE vApePat		char(26);
	DEFINE vApeMat		char(26);
	DEFINE vNombre1		char(26);
	DEFINE vNombre2		char(26);
	DEFINE vRFC		char(13);
	DEFINE vFechaNac	char(10);
	DEFINE vNumeroTarjeta	char(20);
	DEFINE vCantidad	smallint;
	
	-- Se Inicializan las Variables
	LET vCodRet  = "00000";
	LET vNumCte = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC = "";
	LET vFechaNac = "";
	LET vNumeroTarjeta = "33333333";
	LET vCantidad = 0;
	
	
--	SET DEBUG FILE TO '/tmp/zprueba.out';
--	TRACE ON;
BEGIN
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF ptipo=1 THEN --B aDICIONAL DE credito

			-- Se verifica que exista el numero de cuenta 
			IF(SELECT count(*) 
				FROM bdicred:sd_tarjeta 
				WHERE empresa = '001'
				AND num_credito = pnumerocuenta) > 0 THEN

				-- Ciclo para Obtner la cantidad de clientes y sus datos asociados a pnumerocuenta
				FOREACH

					SELECT numcte
					INTO vnumcte
					FROM bdicred:sd_tarjeta 
					WHERE empresa = '001'
					AND num_credito = pnumerocuenta
					AND tipo_tarjeta='A' 
					AND status_tar = 'A'

					SELECT num_tarjeta
					INTO vNumeroTarjeta
					FROM bdicred:sd_tarjeta a
					WHERE empresa = '001' 
                    and num_credito = pnumerocuenta
					AND secuencia = (SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE empresa = '001' and a.num_credito = num_credito AND numcte = vnumcte AND tipo_tarjeta='A' and status_tar = 'A');


					-- Se buscan los datos generales del cliente en si_cliente y si_ctepf
						SELECT cl.apell_paterno, cl.apell_materno, cl.nombre1, cl.nombre2, cl.rfc, pf.fecha_nac
						INTO vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac
						FROM  bdinteg:si_cliente AS cl, bdinteg:si_ctepf AS pf
						WHERE pf.numcte = vnumcte
						AND pf.numcte = cl.numcte
						AND cl.tpo_persona = '01';

						IF vApePat IS NULL OR  vNombre1 IS NULL THEN

							LET vCodRet="00259";
							LET vNumCte = "";
							LET vApePat = "";
							LET vApeMat = "";
							LET vNombre1 = "";
							LET vNombre2 = "";
							LET vRFC = "";
							LET vFechaNac = "";
							LET vNumeroTarjeta = "";
						ELSE

							LET vCodRet = "00000";
							LET vCantidad = vCantidad + 1;

						END IF;				

					RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta WITH RESUME;

				END FOREACH;

				IF vCantidad = 0 THEN

					LET vCodRet="00259";
					LET vNumCte = "";
					LET vApePat = "";
					LET vApeMat = "";
					LET vNombre1 = "";
					LET vNombre2 = "";
					LET vRFC = "";
					LET vFechaNac = "";
					LET vNumeroTarjeta = "";

					RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta;
				END IF

			ELSE	--LA CUENTA NO EXISTE

				LET Vcodret="00100";
				LET vNumCte = "";
				LET vApePat = "";
				LET vApeMat = "";
				LET vNombre1 = "";
				LET vNombre2 = "";
				LET vRFC = "";
				LET vFechaNac = "";
				LET vNumeroTarjeta = "";


			RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta;
		END IF;
--------------------------------------------------------------------------------------------------------------
	ELSE	--Buscar Datos de DICIONAL DE DEBITO

		IF(SELECT count(*)
			FROM bdicheq:sc_firmantes 
			WHERE empresa = '001'
			AND cuenta = pnumerocuenta) > 0 THEN

			-- Ciclo para Obtner la cantidad de clientes y sus datos asociados a pnumerocuenta
			FOREACH
				SELECT numcte
				INTO vnumcte
				FROM bdicheq:sc_firmantes
				WHERE empresa = '001'
				AND cuenta = pnumerocuenta
				AND secuencia != 1
				GROUP BY numcte

--				IF Vnumcte IS NOT NULL OR Vnumcte != "" THEN --Si la variable no es nula o vacia hace lo sig:

					--se buscan los datos generales del cliente en si_cliente y si_ctepf

					SELECT cl.apell_paterno, cl.apell_materno, cl.nombre1, cl.nombre2, cl.rfc, pf.fecha_nac
					INTO vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac
					FROM  bdinteg:si_cliente AS cl, bdinteg:si_ctepf AS pf
					WHERE pf.numcte = vnumcte
					AND pf.numcte = cl.numcte
					AND cl.tpo_persona = '01';
					
					--Se busca el numero de cliente en la tabla sc_tarjeta para ver si existe y de existir se toma el nÃÂÃÂºmero de tarjeta
					
					IF(SELECT count(*)
						FROM  bdicheq:sc_tarjeta
							WHERE   empresa = '001'
								AND numcte = vnumcte
								AND cuenta = pNumeroCuenta
								AND tipo_tarjeta ='A' 
								AND status_tar = 'A') > 0 THEN

						SELECT num_tarjeta 
                            INTO vNumeroTarjeta
							FROM  bdicheq:sc_tarjeta
								WHERE   empresa = '001'
									AND numcte = Vnumcte
									AND cuenta = pNumeroCuenta
									AND tipo_tarjeta ='A' 
									AND status_tar = 'A';
					
							
					ELSE

						LET vNumeroTarjeta = '100';		

					END IF;	

					IF vApePat IS NULL OR  vNombre1 IS NULL THEN

						LET vCodRet="00259";
						LET vNumCte = "";
						LET vApePat = "";
						LET vApeMat = "";
						LET vNombre1 = "";
						LET vNombre2 = "";
						LET vRFC = "";
						LET vFechaNac = "";
						LET vNumeroTarjeta = "";

					ELSE

						LET vCodRet = "00000";
						LET vCantidad = vCantidad + 1;

					END IF;

				RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta WITH RESUME;

			END FOREACH;

			IF vCantidad = 0 THEN

				LET vCodRet="00259";
				LET vNumCte = "";
				LET vApePat = "";
				LET vApeMat = "";
				LET vNombre1 = "";
				LET vNombre2 = "";
				LET vRFC = "";
				LET vFechaNac = "";
				LET vNumeroTarjeta = "";

				RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta;
			END IF

		ELSE	--LA CUENTA NO EXISTE

			LET Vcodret = "00100";
			LET vNumCte = "";
			LET vApePat = "";
			LET vApeMat = "";
			LET vNombre1 = "";
			LET vNombre2 = "";
			LET vRFC = "";
			LET vFechaNac = "";
			LET vNumeroTarjeta = "";

			RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta ;
		END IF

	END IF
END;		
END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 14/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdinteg,bdicred,bdmaecheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_consulta_saldos_cobranza_sucs_web(pEmpresa CHAR(3), pNumCuenta CHAR(20))
RETURNING   CHAR(5)     AS cod_ret,
			CHAR(21)	AS pago_minimo,
			CHAR(21)	AS saldo_total,
			CHAR(21)	AS pago_vencido1,
			CHAR(21)	AS pago_vencido2,
			CHAR(21)	AS pago_vencido3,
			CHAR(21)	AS pago_vencido4;
			
DEFINE cCodRet              CHAR(5);
DEFINE cCodRet2             CHAR(6);
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cNumProducto         CHAR (4);
DEFINE dpago_vencido1   	DECIMAL(18,2);
DEFINE dpago_vencido2   	DECIMAL(18,2);
DEFINE dpago_vencido3   	DECIMAL(18,2);
DEFINE dpago_vencido4   	DECIMAL(18,2);
DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPagoCSG	DATE;
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);
DEFINE ctpofamcred			CHAR(3); --AAME RQM 10 1177												 


-----------------------------------------------------------

-- Inicializacion de variables
LET cCodRet                 = "00000";
LET cCodRet2                 = "000000";
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET error_info              = "";
LET cNumProducto 			= '';
LET dpago_vencido1 			= 0;
LET dpago_vencido2 			= 0;
LET dpago_vencido3 			= 0;
LET dpago_vencido4 			= 0;
LET cMensajeRetornoCSG      = 'PROCESO EXITOSO';
LET cNumeroCreditoCSG		= '';
LET cCodigoTipcredCSG		= '';
LET dFechaOrigenCSG			= '';
LET dFechaProxPagoCSG		= '';
LET dPagoMinimoCSG			= 0	;
LET dFechaUltPagoCSG		= '';
LET iPlazoCSG				= 0;
LET iPagosRealizadosCSG		= 0;
LET dLineaOtorgadaCSG		= 0;
LET dTasaInteresCSG			= 0;
LET dTasaMoratoriosCSG		= 0;
LET dMontoSbcCSG			= 0;
LET dCapVigCSG				= 0;
LET dCapTransCSG			= 0;
LET dCapVdoExigCSG			= 0;
LET dCapVdoNoExigCSG		= 0;
LET dSdoActTotalCapCSG		= 0;
LET dIntVigCSG				= 0;
LET dIntVdoCSG				= 0;
LET dIntMoratoriosCSG		= 0;
LET dIntMesCSG				= 0;
LET dSdoActTotalIntCSG		= 0;
LET dIvaIntVigCSG			= 0;
LET dIvaIntVdoCSG			= 0;
LET dIvaIntMoratoriosCSG	= 0;
LET dIvaIntMesCSG			= 0;
LET dSdoActTotalIvaCSG		= 0;
LET dComPendCSG				= 0;
LET dIvaComCSG				= 0;
LET dSdoRetenidoCSG			= 0;
LET dTotalLiquidacionCSG	= 0;
LET dIntDevengadoCSG		= 0;
LET dIvaIntDevengadoCSG		= 0;
LET dLineaDisponibleCSG		= 0;
LET dPagosVdosCSG			= 0;
LET cDescStatusCredCSG		= '';
LET iIdBloqueoCredCSG		= 0;
LET cBloqueoCtaCSG			= '';
LET cIdCausaBloqueoCSG		= '';
LET cCausaBloqueoCtaCSG		= '';
LET cIdSitEspCteCSG			= '';
LET iIdCausaEspCteCSG		= 0;
LET cSitEspCteCSG			= '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG		= 0	;
LET cSitEspCredCSG			= '';
LET ctpofamcred				=''; --AAME RQM 10 1177 										   

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	BEGIN		

		ON EXCEPTION SET iSqlErr, iIsamErr, error_info		
			  LET cCodRet = iSqlErr;			   
			  RETURN TRIM(NVL(cCodRet," ")), NVL(dPagoMinimoCSG, 0), NVL(dTotalLiquidacionCSG, 0), NVL(dpago_vencido1, 0),
				    NVL(dpago_vencido2, 0), NVL(dpago_vencido3, 0), NVL(dpago_vencido4, 0);
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/587/sp_consulta_saldos_cobranza_sucs.out'; 
		--TRACE ON;

		IF pEmpresa <> "" AND pNumCuenta <> "" THEN
		
			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa, pNumCuenta)
			INTO cCodRet2, cMensajeRetornoCSG, cNumeroCreditoCSG, cCodigoTipcredCSG, dFechaOrigenCSG, dFechaProxPagoCSG,
			dPagoMinimoCSG, dFechaUltPagoCSG, iPlazoCSG, iPagosRealizadosCSG, dLineaOtorgadaCSG, dTasaInteresCSG, dTasaMoratoriosCSG,
			dMontoSbcCSG, dCapVigCSG, dCapTransCSG, dCapVdoExigCSG, dCapVdoNoExigCSG, dSdoActTotalCapCSG, dIntVigCSG, dIntVdoCSG, dIntMoratoriosCSG,
			dIntMesCSG, dSdoActTotalIntCSG, dIvaIntVigCSG, dIvaIntVdoCSG, dIvaIntMoratoriosCSG, dIvaIntMesCSG, dSdoActTotalIvaCSG, dComPendCSG,
			dIvaComCSG, dSdoRetenidoCSG, dTotalLiquidacionCSG, dIntDevengadoCSG, dIvaIntDevengadoCSG, dLineaDisponibleCSG, dPagosVdosCSG,
			cDescStatusCredCSG, iIdBloqueoCredCSG, cBloqueoCtaCSG, cIdCausaBloqueoCSG, cCausaBloqueoCtaCSG, cIdSitEspCteCSG,
			iIdCausaEspCteCSG, cSitEspCteCSG, cIdSitEspCredCSG, iIdCausaEspCredCSG, cSitEspCredCSG;
					 
			IF cCodRet2 = '000000' THEN
				LET cCodRet = SUBSTRING (cCodRet2 FROM 2 FOR 5);
				FOREACH		
					SELECT num_producto INTO cNumProducto
					FROM "informix".sd_maecred 
					WHERE empresa = pEmpresa AND num_credito = pNumCuenta
					UNION ALL
					SELECT num_producto				
					FROM "informix".sd_maecredcrd
					WHERE empresa = pEmpresa AND num_credito = pNumCuenta
				END FOREACH;
				--AAME RQM 10 1177 Para mostrar vencidos en caja para los nuevos prestamos
				SELECT familia INTO ctpofamcred FROM bdicred:sd_definicion WHERE num_producto = cNumProducto;
				
				IF cNumProducto IS NOT NULL THEN					
					--IF(TRIM(NVL(cNumProducto,"")) IN ('6001','8100','8500')) THEN  --AAME RQM 10 1177 Se agrega bandera de familia para mostrar vencidos en caja para los productos
					IF(TRIM(NVL(ctpofamcred,"")) IN ('001')) THEN
						SELECT
						  (CASE WHEN saldovencido1 <> 0 
						  THEN saldovencido1  + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 + sdo_intereses
						  ELSE 0 END) AS CUADRO1,
						  (CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 +
						interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 +
						sdo_intereses ELSE 0 END) AS CUADRO2,
						(CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 + interesmoratorio1 +
						interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 +
						interesmoratorio6 + sdo_intereses ELSE 0 END) AS CUADRO3,
						(CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 +
						saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 +
						interesmoratorio4 + interesmoratorio5 + interesmoratorio6 + sdo_intereses ELSE 0 END) AS CUADRO4
						INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
						FROM "informix".sd_sdos_cartera_linea 
						WHERE num_credito = pNumCuenta;
					 
					--ELIF (TRIM(NVL(cNumProducto,"")) IN ('6300','6800','7600','7700','9100','9300')) THEN 
					ELIF (TRIM(NVL(ctpofamcred,"")) IN ('002','003')) THEN 
						SELECT 
						  (CASE WHEN saldovencido1 <> 0 THEN saldovencido1 + interesmoratorio1	ELSE 0 END) AS CUADRO1,
						  (CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 ELSE 0 END) AS CUADRO2,
						  (CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 ELSE 0 END) AS CUADRO3,
						  (CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 + 
						  saldovencido1 + interesmoratorio1 + interesmoratorio2 + interesmoratorio3 + interesmoratorio4 + interesmoratorio5 + interesmoratorio6 ELSE 0 END) AS CUADRO4
						  INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
						  FROM "informix".sd_sdos_cartera_linea 
						  WHERE num_credito = pNumCuenta;
								
					--ELIF (TRIM(NVL(cNumProducto,"")) IN ('6011','8600')) THEN
					ELIF (TRIM(NVL(ctpofamcred,"")) IN ("")) THEN
						SELECT 
						(CASE WHEN saldovencido1 <> 0 THEN saldovencido1 ELSE 0 END) AS CUADRO1,
						(CASE WHEN saldovencido2 <> 0 THEN saldovencido2 + saldovencido1 ELSE 0 END) AS CUADRO2,
						(CASE WHEN saldovencido3 <> 0 THEN saldovencido3 + saldovencido2 + saldovencido1 ELSE 0 END) AS CUADRO3,
						(CASE WHEN saldovencido4 <> 0 THEN saldovencido6 + saldovencido5 + saldovencido4 + saldovencido3 + saldovencido2 + saldovencido1 ELSE 0 END) AS CUADRO4
						INTO dpago_vencido1,dpago_vencido2,dpago_vencido3,dpago_vencido4
						FROM "informix".sd_sdos_cartera_linea 
						WHERE num_credito = pNumCuenta;
							
					END IF;
				ELSE
					LET cCodRet = "00001";
				END IF;
			ELSE
				LET cCodRet = "00002";
			END IF;
		ELSE
			LET cCodRet = "00002";			
		END IF;
		
        IF dPagoMinimoCSG = 0 AND dTotalLiquidacionCSG = 0 THEN
		   LET dpago_vencido1 = 0;
		   LET dpago_vencido2 = 0;
		   LET dpago_vencido3 = 0;
		   LET dpago_vencido4 = 0;
		END IF;
		RETURN TRIM(NVL(cCodRet," ")), NVL(dPagoMinimoCSG, 0), NVL(dTotalLiquidacionCSG, 0), NVL(dpago_vencido1, 0),
				    NVL(dpago_vencido2, 0), NVL(dpago_vencido3, 0), NVL(dpago_vencido4, 0);
	END; 

END PROCEDURE
DOCUMENT
'Folio: 587',
'Autor:95572217 Omar Lerma',
'Fecha:19/07/2019',
'DESCRIPCION: Procedimineto que consulta el saldo vencido que presenta el cliente',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'BD: bdicred',
'Modifico: 97879606 Adrian Lizarraga',
'Fecha: 19/08/2019',
'DESCRIPCION: Se modifica la busqueda del producto con base al numero de credito',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'BD: bdicred',
'Modifico: 90034397 Brando Garcia',
'Fecha: 14/04/2020',
'DESCRIPCION: Se agregan productos [6800,8100,8500] a la validacion de saldo vencido.',
'Solicita: Marco Campos',
'Folio: 658',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_movimientos_pos_credito()
RETURNING CHAR(5)   AS cod_ret,
		  CHAR(100) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE SQL_ERR	INTEGER;
DEFINE ISAM_ERR	INTEGER;
DEFINE DATA_ERR	CHAR(95);
DEFINE ROWS_NUM INTEGER;

DEFINE dFechaIni	 DATE;
DEFINE dFechaFin 	 DATE;
DEFINE iSecuencia	 INTEGER;
DEFINE dFechaMov	 DATE;
DEFINE vcReferencia1 VARCHAR(40);
DEFINE cTransaccion	 CHAR(4);
DEFINE cDescripcion	 CHAR(50);
DEFINE cNaturaleza	 CHAR(1);
DEFINE dMonto		 DECIMAL(18,2);
DEFINE vcReferencia2 VARCHAR(23);
DEFINE vcRfc		 VARCHAR(20);
DEFINE cNumero		 CHAR(4);
DEFINE cNumCredito	 CHAR(20);
DEFINE cNomComercio	 CHAR(30);
DEFINE dtFechaTx	 DATETIME YEAR to FRACTION(5);
DEFINE cFolioSuc 	 CHAR(16);
DEFINE cEmpresa1	 CHAR(3);
DEFINE cEmpresa2	 CHAR(3);
DEFINE cCodFun		 CHAR(3);
DEFINE iCodRef		 INTEGER;
DEFINE cTransacSuc	 CHAR(4);

LET ROWS_NUM = 0;

LET iSecuencia	  = 0;
LET dFechaMov	  = TODAY;
LET vcReferencia1 = '';
LET cTransaccion  = '';
LET cDescripcion  = '';
LET cNaturaleza	  = '';
LET dMonto		  = 0;
LET vcReferencia2 = '';
LET vcRfc		  = '';
LET cNumero		  = '';
LET cNumCredito	  = '';
LET cNomComercio  = '';
LET dtFechaTx	  = CURRENT;
LET cFolioSuc 	  = '';
LET cEmpresa1	  = '';
LET cEmpresa2	  = '';
LET cCodFun		  = '';
LET iCodRef		  = 0;
LET cTransacSuc	  = '';

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, DATA_ERR
        IF ROWS_NUM <> 0 THEN
			COMMIT WORK;
		END IF
		
		IF SQL_ERR <> 0 OR ISAM_ERR <> 0 THEN
			RETURN SQL_ERR, ISAM_ERR||DATA_ERR;
		END IF
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/jepolanco/sp_movimientos_pos_credito.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy INTO dFechaFin FROM bdinteg:si_fechas;
	LET dFechaIni = dFechaFin - 15;
	
	BEGIN WORK;
		TRUNCATE TABLE bdicred:"informix".sd_movdescpos;
	COMMIT WORK;			
	
	FOREACH WITH HOLD
		SELECT {+AVOID_FULL(bdicred:"informix".sd_movhis)} secuencia, fecha_mov, referencia, monto, referencia23, rfc_comer, num_credito, folio_suc, empresa, codigo_fun, codigo_ref, transacc_suc
		INTO iSecuencia, dFechaMov, vcReferencia1, dMonto, vcReferencia2, vcRfc, cNumCredito, cFolioSuc, cEmpresa1, cCodFun, iCodRef, cTransacSuc
		FROM bdicred:"informix".sd_movhis
		WHERE transacc_suc IN ('6813','6830') AND fecha_mov BETWEEN dFechaIni AND dFechaFin
		UNION
		SELECT {+AVOID_FULL(bdicred:"informix".sd_movdia)} secuencia, fecha_mov, referencia, monto, referencia23, rfc_comer, num_credito, folio_suc, empresa, codigo_fun, codigo_ref, transacc_suc
		FROM bdicred:"informix".sd_movdia
		WHERE transacc_suc IN ('6813','6830') AND fecha_mov BETWEEN dFechaIni AND dFechaFin
		
		LET cCodFun = TRIM(cCodFun);

		SELECT {+INDEX(bdicred:"informix".sd_transfun inx_transfun)} transacc, empresa
		INTO cTransaccion, cEmpresa2
		FROM bdicred:"informix".sd_transfun
		WHERE empresa = cEmpresa1 AND TRIM(codigo_fun)||codigo_ref = cCodFun||iCodRef;
		
		SELECT descripcion, naturaleza, numero
		INTO cDescripcion, cNaturaleza, cNumero
		FROM bdinteg:"informix".si_transacc
		WHERE empresa = cEmpresa2 AND numero = cTransaccion;
		
		IF cTransacSuc = '6830' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion INTO cNomComercio, dtFechaTx
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cNumCredito AND folio_mov = cFolioSuc AND tipotransaccion325 = '01';
		ELIF cTransacSuc = '6813' THEN
			SELECT LIMIT 1 nomcomercio325, fechatransaccion INTO cNomComercio, dtFechaTx
			FROM bditarjeta:"informix".td_movimientos_conciliacion WHERE numcuenta = cNumCredito AND folio_mov = cFolioSuc AND tipotransaccion325 = '21';			
		END IF
		
		IF ROWS_NUM = 0 THEN
			BEGIN WORK;
		END IF
		
		IF iSecuencia IS NULL THEN
			LET iSecuencia = 0;
		END IF
		
		IF dFechaMov IS NULL THEN
			LET dFechaMov = dFechaFin;
		END IF
		
		IF cTransaccion IS NULL THEN
			LET cTransaccion = '';
		END IF
		
		IF dMonto IS NULL THEN
			LET dMonto = 0;
		END IF
		
		IF cNumero IS NULL THEN
			LET cNumero = '';
		END IF
		
		IF cNumCredito IS NULL THEN
			LET cNumCredito = '';
		END IF
		
		INSERT INTO bdicred:"informix".sd_movdescpos (secuencia, fecha_mov, referencia, transacc, descripcion, naturaleza, monto, referencia23, rfc_comer, numero, num_credito, nomcomercio325, fechatransaccion, folio_suc)
		VALUES (iSecuencia, dFechaMov, vcReferencia1, cTransaccion, cDescripcion, cNaturaleza, dMonto, vcReferencia2, vcRfc, cNumero, cNumCredito, cNomComercio, dtFechaTx, cFolioSuc);
		
		LET ROWS_NUM = ROWS_NUM + 1;
		IF ROWS_NUM = 1000 THEN
			COMMIT WORK;
			LET ROWS_NUM = 0;			
		END IF
	END FOREACH
	
	IF 	ROWS_NUM <> 0 THEN
		COMMIT WORK;
		LET ROWS_NUM = 0;
	END IF
	
	RETURN '00000', 'TERMINÃ CORRECTAMENTE';
	
END;
END PROCEDURE;
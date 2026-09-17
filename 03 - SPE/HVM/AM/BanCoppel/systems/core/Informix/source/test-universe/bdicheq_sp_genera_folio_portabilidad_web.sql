CREATE PROCEDURE "informix".sp_genera_folio_portabilidad_web(pEmpresa CHAR(3),pSucursal CHAR(4),pTipoOperacion CHAR(2),pIdentificador CHAR(1))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			CHAR(30) AS cFolio;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet 		CHAR(5);
DEFINE  cSucursal		CHAR(8);
DEFINE  cFolio			CHAR(30);
DEFINE  cCveSPEI		CHAR(5);
DEFINE  cHoraUno		CHAR(8);
DEFINE  cHora			CHAR(6);
DEFINE  cFecha			CHAR(8);
DEFINE  cFechaNormal	CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet 		= '00000';
LET cSucursal		= '';
LET cFolio			= '';
LET cCveSPEI		= '';
LET cHoraUno		= '';
LET cHora			= '';
LET cFecha			= '';
LET cFechaNormal	= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cFolio;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_genera_folio_portabilidad.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pTipoOperacion,'') <> '' AND NVL(pIdentificador,'') <> '' THEN
		SELECT fecha_hoy INTO cFechaNormal FROM bdicheq:"informix".sc_fechas
		WHERE empresa = pEmpresa;

		LET cFecha = TRIM(SUBSTR(cFechaNormal,7,4) || SUBSTR(cFechaNormal,1,2) || SUBSTR(cFechaNormal,4,2));

		SELECT FIRST 1 CURRENT HOUR TO SECOND INTO cHoraUno FROM "informix".systables;
		LET cHora =  REPLACE(cHoraUno,':','');

		SELECT cvecesif INTO cCveSPEI FROM bdinteg:"informix".si_bancos
		WHERE banco = '137';

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01289';
		END IF;

		SELECT clave_tipo INTO cFechaNormal
		FROM bdicheq:"informix".sc_portacec_tipo_operacion
		WHERE clave_tipo = pTipoOperacion;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01289';
		ELSE
			LET cSucursal = LPAD(pSucursal,8,"0");
			LET cFolio = TRIM(cFecha||cHora||cCveSPEI||pTipoOperacion||pIdentificador||cSucursal);
		END IF;

	ELSE
		LET cCodRet ='01288';
	END IF
	RETURN cCodRet,cFolio;
END;
END PROCEDURE
DOCUMENT
'000000 - Se genera el folio',
'001289 - No existe el banco o tipo operacion',
'001288 - Parametros incompletos',
'DESCRIPCION: Genera el folio de solicitud de portabilidad de nomina',
'AUTOR : Claudio Almodovar',
'Folio:1748',
'Solicita: Rodolfo GÃÂ³mez',
'FECHA : 31/08/2015',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_insertacondonacion_tdd_web(pEmpresa CHAR(3), pSucursal CHAR(4), pEmpleado CHAR(8),pNumCte CHAR(20))

RETURNING	CHAR(6) AS CodRet, DATE AS FechaReg, SMALLINT AS Consecutivo;
		
DEFINE 	cCodRet		 CHAR(6);
DEFINE	iSqlErr	 	 INTEGER;
DEFINE	iFlagCondona SMALLINT;
DEFINE	iConActual	 SMALLINT;
DEFINE  dFechaHoy	DATE;

LET	cCodRet		 = '00000';
LET iSqlErr		 = 0;
LET iFlagCondona = 0;
LET iConActual	 = 0;	
LET dFechaHoy	 = '';

-- SET DEBUG FILE TO '/tmp/sp_insertacondonacion_tdd.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,"",0;
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pEmpleado,'') = '' OR NVL(pNumCte,'') = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet,"",0;
	END IF;
	
	EXECUTE PROCEDURE "informix".sp_validacondonacion_tdd_web(pEmpresa,pSucursal) INTO cCodRet,iFlagCondona,iConActual;
	
	IF NVL(cCodRet,'') = '00000' THEN
	
		IF NVL(iFlagCondona,0) = 1 THEN
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM "informix".sc_fechas
			WHERE empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00004';
				RETURN cCodRet,"",0;
			END IF;
			
			LET iConActual = iConActual + 1;
			
			INSERT INTO "informix".sc_condonacomdeb (sucursal,empleado,numcte,fecha,consecutivo)
			VALUES (pSucursal,pEmpleado,TRIM(pNumCte),dFechaHoy,iConActual);
			
		ELSE
			LET cCodRet = '00002';			
		END IF;	
	
	ELSE 
		LET cCodRet = '00003';	
	END IF;
	
	RETURN cCodRet,dFechaHoy,iConActual;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR:	  	  ERNESTO AGUILERA',
'FECHA:		  11/02/2016',
'DESCRIPCION: Inserta una condonacion de tarjeta de debito a la tabla sc_condonacomdeb',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_reversacondonacion_tdd_web(pSucursal CHAR(4), pConsecutivo SMALLINT,pFecha DATE)

RETURNING	CHAR(6) AS CodRet;
		
DEFINE 	cCodRet		 CHAR(6);
DEFINE	iSqlErr	 	 INTEGER;

LET	cCodRet		 = '00000';
LET iSqlErr		 = 0;

-- SET DEBUG FILE TO '/tmp/sp_reversacondonacion_tdd.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	IF NVL(pSucursal,'') = '' OR NVL(pConsecutivo,'') = '' OR NVL(pFecha,'') = '' THEN
		LET cCodRet = '00001';
	ELSE
	
		DELETE FROM "informix".sc_condonacomdeb
		WHERE sucursal = pSucursal
		AND fecha = pFecha
		AND consecutivo = pConsecutivo;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00002';
		ELSE
			UPDATE "informix".sc_condonacomdeb
			SET consecutivo = consecutivo -1
			WHERE sucursal = pSucursal
			AND consecutivo > pConsecutivo;
		END IF;
	END IF;
	
	RETURN cCodRet;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR:	  	  ERNESTO AGUILERA',
'FECHA:		  11/02/2016',
'DESCRIPCION: Elimina el registro de la condonacion cuando se genera una reversion.',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_validacondonacion_tdd_web(pEmpresa CHAR(3),pSucursal CHAR(4))

RETURNING 	CHAR(6)		AS codigo_retorno,
			SMALLINT	AS sflag_condona,
			SMALLINT	AS sConsecActual;

	DEFINE cCodRet		CHAR(6);
	DEFINE iSqlErr		INTEGER;
	DEFINE sFlag_Cond	SMALLINT;
	DEFINE sCon_Actual	SMALLINT;
	DEFINE iValor		INTEGER;
	DEFINE dtPriDiaMes  DATE;
	DEFINE dtUltDiaMes  DATE;
	DEFINE iConsec		INTEGER;

	LET cCodRet			= '00000';
	LET iSqlErr			= 0;
	LET sFlag_Cond		= 0;
	LET sCon_Actual		= 0;
	LET iValor			= '';
	LET dtPriDiaMes		= '';
	LET dtUltDiaMes		= '';
	LET iConsec			= 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,'')),NVL(sFlag_Cond,0),NVL(sCon_Actual,0);
			END IF;
			
		END EXCEPTION; 	

		--SET DEBUG FILE TO "/respaldosbd/isarai/sp_validacondonacion_tdd.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF TRIM(NVL(pEmpresa,'')) = '' OR 	TRIM(NVL(pSucursal,'')) = '' THEN
		
			--PARAMETROS DE ENTRADA NULOS O VACIOS
			LET cCodRet = '00001';
						
		ELSE
					
			-- NUMERO DE LIMITE DE CONDONACIONES PERMITIDAS 
			SELECT valor::INTEGER INTO iValor FROM "informix".sc_param WHERE empresa = TRIM(NVL(pEmpresa,'')) AND codparam = 'LIMITECONDONA';
			
			--PERIODO DE FECHA PERMITIDO PARA LAS CONDONACIONES 
			SELECT pri_dia_mes,ult_dia_mes INTO dtPriDiaMes,dtUltDiaMes FROM "informix".sc_fechas 
			WHERE empresa = TRIM(NVL(pEmpresa,''));
			
			IF NVL(iValor,0) = 0 OR  NVL(dtPriDiaMes,'') = ''  OR NVL(dtUltDiaMes,'') = '' THEN
			
				--NO SE ENCONTRARON ALGUNOS PARAMETROS NECESARIOS PARA DEFINIR SI ES POSIBLE LA CONDONACION
				LET cCodRet = "00002";	
			
			ELSE
					
				--NUMERO DE CONDONACIONES QUE TIENE LA SUCURSAL CONSULTADA 
				SELECT MAX(consecutivo) INTO iConsec FROM "informix".sc_condonacomdeb 
				WHERE sucursal = TRIM(NVL(pSucursal,'')) AND fecha >= NVL(dtPriDiaMes,'') AND fecha <= NVL(dtUltDiaMes,'');
			
				IF NVL(iConsec,0) = 0 THEN
				
					IF NVL(iValor,0) <= 0 THEN
						--LIMITE DE CONDONACIONES POR MES ES <= 0
						LET sFlag_Cond = 0; --NO PROCEDE LA CONDONACION
						LET sCon_Actual = 0;  
					ELSE
						--LIMITE DE CONDONACIONES POR MES ES > 0
						LET sFlag_Cond = 1; --PROCEDE LA CONDONACION
						LET sCon_Actual = 0;
					END IF;
					
				ELIF NVL(iConsec,0) >= NVL(iValor,0) THEN
					--CONSECUTIVO OBTENIDO ES IGUAL O MAYOR AL LIMITE DE CONDONACIONES
					LET sFlag_Cond = 0;  -- 	NO PROCEDE LA CONDONACION
					LET sCon_Actual = NVL(iConsec,0);
					
				ELSE 
					--CONSECUTIVO OBTENIDO MENOR AL LIMITE DE CONDONACIONES
					LET sFlag_Cond = 1; --PROCEDE LA CONDONACION
					LET sCon_Actual = NVL(iConsec,0);
					
				END IF;
			
			END IF;
			
		END IF;
		
		RETURN TRIM(NVL(cCodRet,'')),NVL(sFlag_Cond,0),NVL(sCon_Actual,0);
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA SABER SI PROCEDE O NO UNA CONDONACION',
'VERSION: 20160208.1205',
'FECHA: 08/02/2016',
'BD: BDICHEQ',
'AUTOR: ISARAI BOJORQUEZ';

CREATE PROCEDURE "informix".sp_consultamovtoscortetienda_pba2( pTipo SMALLINT, 
                                                          pTienda SMALLINT, 
                                                          pTipoDeposito CHAR(1), 
                                                          pFechaParcialCoppel DATE, 
                                                          pFechaDeposito DATE, 
                                                          pFolioDeposito CHAR(16), 
                                                          pMontoDeposito INTEGER )
RETURNING INTEGER, INTEGER;

    --- #############################################################################################
    --- ## Modifico: Miguel Olivas                                                                 ##
    --- ## Fecha: 18/nov/2008                                                                      ##
    --- ## se modifica para que no haga la consulta a la tabla historica sc_movhis.                ##
    --- ##                                                                                         ##
    --- ## Modifico: Daniel Zambada                                                                ##
    --- ## Fecha: 21/nov/2008                                                                      ##
    --- ## se modifica para que valide  el retorno cuando no exista el registro con regreso 1 o 3. ##
    --- ##                                                                                         ##
    --- ## Modifico: Daniel Zambada                                                                ##
    --- ## Fecha: 21/may/2009                                                                      ##
    --- ## se modifica para que valide  el monto en la movdia por rango inferior  y superior.      ##
    --- #############################################################################################
    
    DEFINE vCodRet    CHAR(5);
    DEFINE vSqlErr    INTEGER;
    DEFINE vSucursal  CHAR(4);
    DEFINE vCSucursal CHAR(4);
    DEFINE vDeposito MONEY(14,2);
    
    LET vCodRet = '000';
    LET vSqlErr = 0;
    LET vSucursal = '0000';
    LET vCSucursal = '0000';
    LET vDeposito = pMontoDeposito/100;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vSqlErr <> 0 THEN
            LET vCodRet = vSqlErr;
            RETURN vCodRet,vSucursal;
        END IF;
    END EXCEPTION;
	--SET DEBUG FILE TO "/respaldosbd/cris/sp_consultamovtoscortetienda.out";
	--TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pTipo = 1 THEN
    
        IF EXISTS (SELECT {+INDEX(bdicheq:"informix".sc_consultamovtoscortetienda_new ind_sc_consultamovtoscortetienda_new_01)} 
					fechadeposito,foliodeposito,montodeposito 
					FROM "informix".sc_consultamovtoscortetienda_new 
					WHERE fechadeposito = pFechaDeposito 
					AND foliodeposito = pFolioDeposito 
					AND montodeposito = vDeposito 
					AND estado = 1) THEN
                      
            INSERT INTO bdicheq:"informix".sc_consultamovtoscortetienda_new(fechadeposito,foliodeposito,montodeposito,tienda,tipodeposito,fechaparcialcoppel,estado,fechamov)
            VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 2, CURRENT);

            LET vCodRet = '2';
            LET vSucursal = '0';
            
        ELSE
            
		/* ###############################################
		IF EXISTS (SELECT fech_alt, folio_suc, monto_tot 
				FROM sc_movdia 
				WHERE fech_alt = pFechaDeposito 
				AND folio_suc = pFolioDeposito 
				AND monto_tot = vDeposito) THEN 
		############################################### */
            
		IF EXISTS ( SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia7a)} 
					fech_alt, folio_suc, monto_tot 
					FROM "informix".sc_movdia 
					WHERE cuenta = '16000000012' 
					AND folio_suc = pFolioDeposito
					AND fech_alt = pFechaDeposito 
					AND monto_tot = vDeposito ) THEN 

				/* ################################
					SELECT nvl(sucursal,'') 
					INTO vCSucursal 
					FROM sc_movdia 
					WHERE fech_alt = pFechaDeposito 
					AND folio_suc = pFolioDeposito 
					AND monto_tot = vDeposito; 
				################################ */
			
				SELECT {+INDEX(bdicheq:"informix".sc_movdia idx_movdia7a)} 
				NVL(sucursal,'') 
				INTO vCSucursal 
				FROM "informix".sc_movdia 
				WHERE cuenta = '16000000012' 
				AND folio_suc = pFolioDeposito
				AND fech_alt = pFechaDeposito 
				AND monto_tot = vDeposito;                 
              

                INSERT INTO bdicheq:"informix".sc_consultamovtoscortetienda_new(fechadeposito,foliodeposito,montodeposito,tienda,tipodeposito,fechaparcialcoppel,estado,fechamov)
                VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 1, CURRENT);

                LET vCodRet = '1';
                LET vSucursal = vCSucursal;
                
            ELSE

			-- // Se modifica para que no haga la consulta a la tabla historica sc_movhis.
			/* ############################################################################################################
			IF EXISTS (SELECT fech_alt, folio_suc, monto_tot 
				FROM sc_movhis 
				WHERE fech_alt = pFechaDeposito 
				AND folio_suc = pFolioDeposito 
				AND monto_tot = vDeposito) THEN

				SELECT nvl(sucursal,'') 
				INTO vCSucursal 
				FROM sc_movhis 
				WHERE fech_alt = pFechaDeposito 
				AND folio_suc = pFolioDeposito 
				AND monto_tot = vDeposito;        

				INSERT INTO sc_consultamovtoscortetienda_new(fechadeposito, foliodeposito, montodeposito, tienda, tipodeposito, fechaparcialcoppel, estado, fechamov)
				VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 1, CURRENT);

				LET vCodRet = '1';
				LET vSucursal = vCSucursal;
			ELSE
			############################################################################################################ */
                
                INSERT INTO bdicheq:"informix".sc_consultamovtoscortetienda_new(fechadeposito,foliodeposito,montodeposito,tienda,tipodeposito,fechaparcialcoppel,estado,fechamov)
                VALUES(pFechaDeposito, pFolioDeposito, vDeposito, pTienda, pTipoDeposito, pFechaParcialCoppel, 3, CURRENT);
                
                /* ############################################################################
					IF pFechaDeposito::DATE < (select fecha_hoy::DATE from bdicheq:sc_fechas) THEN	     	
						LET vCodRet = '1';
					ELSE
						LET vCodRet = '3';
					END IF;
				############################################################################ */
                
                LET vCodRet = '3';
                LET vSucursal = '0';

               --- END IF; 
            END IF; 
        END IF;
    END IF;

    RETURN vCodRet, vSucursal;
    
    END;
    
END PROCEDURE

DOCUMENT
"Consulta Movimientos de Cortes de Tienda ",
"AUTOR: Saul Ivanhoe",
"FECHA: 26/Febrero/2008",
"BD   : bdicheq",
"VER  : 1.1",
"MODIFICACION: Se igualan consulta a la sc_movdia filtradas por fecha, monto,folio y monto para corregir incidencia en la confirmacicón de los retiros parciales.",
"MODIFICO: Cristian Valentina Aguilar",
"FECHA: 20/Abril/2012",
"BD   : bdicheq",
"VER  : 20120420.1756";

CREATE PROCEDURE "informix".sp_obt_cta_con_cel(p_NumCel CHAR(10))
RETURNING CHAR(5), CHAR(11);

	DEFINE vCodRet		CHAR(5);
	DEFINE vCta			CHAR(11);
	DEFINE iSqlErr      INTEGER;
    
	LET vCodRet 	= '00000';
	LET vCta 	= '';

SET LOCK MODE TO WAIT 10;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
                LET vCodRet = iSqlErr;
                LET vCta = '';
        END IF;
        RETURN vCodRet, vCta;
    END EXCEPTION;
	
	IF (p_NumCel = "" ) THEN
		LET vCodRet = '00001';
		LET vCta = 'FALTA PARAM';
		RETURN vCodRet, vCta; 
	END IF
	
	
	IF (SELECT COUNT(cuenta) FROM bdicheq:sc_cuenta_telefono WHERE  es_transfer = 'N' AND telefono=p_NumCel) = 1 THEN
			SELECT cuenta INTO vCta FROM bdicheq:sc_cuenta_telefono WHERE  es_transfer = 'N' AND telefono=p_NumCel;
		ELSE
			LET vCodRet = '00002';
			RETURN vCodRet, vCta; 
	END IF
	
END
RETURN vCodRet, vCta; 
END PROCEDURE;
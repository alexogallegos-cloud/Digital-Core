CREATE PROCEDURE "informix".sp_obtienecred_proyecciones(pProducto CHAR(4))
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(4)  AS NumeroProd,
			CHAR(40) AS DescripcionProd,
			DECIMAL(18,2) AS MontoMin,
			DECIMAL(18,2) AS MontoMax,
			INTEGER AS PlazoMin,
			INTEGER AS PlazoMax,
			DECIMAL(18,2) AS Tasa,
			CHAR(6) AS Comision;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5);
DEFINE iSqlErr      	INTEGER;
DEFINE cNumProducto		CHAR(7);
DEFINE cDescProducto	CHAR(40);
DEFINE dMontoMin	DECIMAL(18,2);
DEFINE dMontoMax	DECIMAL(18,2);
DEFINE dTasa		DECIMAL(18,2);
DEFINE iPlazoMin	INTEGER;
DEFINE iPlazoMax	INTEGER;
DEFINE dComision		DECIMAL(5,2);
DEFINE cCodComDispEfectivo	CHAR(4);
---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cNumProducto			= '';
LET cDescProducto			= '';
LET dMontoMin	= 0;
LET dTasa	= 0;
LET dMontoMax	= 0;
LET iPlazoMin	= 0;
LET iPlazoMax	= 0;
LET dComision	= 0;
LET cCodComDispEfectivo	='';



BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/sp_obtienetpoproducto.out';
--TRACE ON;

	FOREACH


	SELECT a.abrevia_prod, a.descrip_prod,b.monto_min_cred,b.monto_max_cred,b.plazo_min_cred,b.plazo_max_cred,c.valor
		INTO cNumProducto, cDescProducto, dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa
		FROM bdicred:"informix".sd_tipprod a , bdicred:"informix".sd_definicion b,
			 bdinteg:"informix".si_fechavalor c
		WHERE a.cod_prod IN('P','R')
		AND a.abrevia_prod= b.num_producto
		AND b.num_producto = CASE WHEN  NVL(pProducto,'') = '' THEN b.num_producto ELSE pProducto END
		AND c.tasa = b.cod_tasa_base
		AND c.fecha = (SELECT MAX(r.fecha)
					FROM bdinteg:"informix".si_fechavalor r
					WHERE r.tasa = b.cod_tasa_base
					AND r.fecha = r.fecha
					AND r.empresa = b.empresa)
		AND c.empresa = b.empresa
		--RQM 10 550 AAME 20150911 Se modifica para quitar la omisión de los productos de prestamo (7600,7700)
		--AND num_producto NOT IN ('7600','7700')
		--AND num_producto <> '6900'  --RQM 10 452 09-09-2013 AAME Se comenta la validación de diferente del producto "6900" para lo despliegue en el listado.
		ORDER BY abrevia_prod

		IF 	cNumProducto = "6400" THEN
			SELECT valor INTO dComision
			FROM   "informix".sd_param
			WHERE  cod_param = '040';
		END IF;
		--RQM 10 452 09-09-2013 AAME Se agrega validación para que cuando sea el producto "6900" tome el plazo minimo y maximo de la tabla sd_tasa_plazo.
		IF cNumProducto = "6900" THEN
			SELECT Min(plazo),Max(plazo)
			INTO iPlazoMin,iPlazoMax
			FROM bdicred:"informix".sd_tasa_plazo;
			
			LET dMontoMin=1000;
			
			--INC 09-02-2015 SE AGREGA FACTOR PARA OBTENER LA COMISION CORRECTA PARA CREDISOLUCION
			SELECT TRIM(valor)::CHAR(4)
			INTO cCodComDispEfectivo
			FROM bdicred:"informix".sd_param
			WHERE cod_param  = '334';
			-- OBTIENE EL FACTOR PARA LA COMISION DE LA DISPOSICION DE EFECTIVO
				SELECT apli_factor
				INTO dComision
				FROM bdicred:"informix".sd_tpcomis
				WHERE cod_comis = cCodComDispEfectivo;
			
		END IF;

		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision WITH RESUME;

	END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet, TRIM(cNumProducto), TRIM(cDescProducto),dMontoMin, dMontoMax, iPlazoMin, iPlazoMax,dTasa,dComision;
    END IF;

END
END PROCEDURE

DOCUMENT
'DESCRIPCION: Obtiene los productos de crédito que se usan para proyecciones ',
'AUTOR : Jesus Manuel Aguilar Heredia ',
'FECHA : 29/Enero/2013',
'BD    : BDICRED',
'Version: 20130129.1614';

CREATE PROCEDURE "informix".corta_linea(plinea char(1000), pcaracteres integer)
RETURNING 	NVARCHAR(255),INTEGER;


DEFINE v_caracter 	CHAR(1);
DEFINE v_pos_actual INTEGER;
DEFINE v_pos$ INTEGER;
DEFINE v_pos_blanco INTEGER;
DEFINE iBandera$ INTEGER;
DEFINE iBanderaEsp INTEGER;
DEFINE v_renglon	VARCHAR(255);
DEFINE v_palabra	VARCHAR(255);
DEFINE v_palabra2	VARCHAR(255);
LET v_caracter 		= "";
LET v_pos_actual 	= 1;
LET v_pos$ 	= 0;
LET v_pos_blanco 	= 1;
LET v_renglon		= "";
LET v_palabra	= "";
LET v_palabra2	= "";LET iBandera$	= 0;
LET iBanderaEsp	= 0;

--SET DEBUG FILE TO "/informix/jesus/corta_linea.out";
--TRACE ON;

---set pdqpriority 11;
 
BEGIN

	
	LET plinea = TRIM(plinea); 
	
	IF LENGTH(NVL(plinea,'')) = 0 THEN
		RETURN v_renglon,0 ;
	END IF
	IF SUBSTR(plinea,1,26) ='CARGO POR CREDISOLUCIONES' THEN 
		LET iBandera$ = 1;
	END IF;
	
	IF SUBSTR(plinea,len(plinea)-29,19) ='Folio de aclaración' THEN 	--RQI 22 268 JMAH	
		LET v_palabra2 = SUBSTR(plinea,len(plinea)-29,LEN(plinea));	
		LET plinea =SUBSTR(plinea,1,len(plinea)-30);
	END IF
	WHILE  v_pos_actual <= LENGTH(plinea)  
		
		
		----------OBTENGO EL CARACTER ACTUAL
		LET v_caracter = SUBSTR(plinea,v_pos_actual,1);
		
		IF v_caracter ='$' AND iBandera$ = 1 THEN
			LET  v_pos$ = v_pos$+1;
		END IF;
		IF v_caracter ='/ ' AND iBandera$ = 1 THEN
			LET  v_pos$ = v_pos$+1;
		END IF;

		IF (((v_caracter = "I" and  v_pos$ > 0 ) OR (iBanderaEsp =9) ) AND iBandera$ = 1)  THEN
			RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
			LET v_renglon		= "";
			LET v_palabra	= "";
			LET iBanderaEsp =0;
		END IF;
		
		LET v_palabra = v_palabra || v_caracter;
		
		----------OBTENGO LA POSICION DE LA ULTIMA PALABRA ENCONTRADA
		
		IF v_caracter = " " OR v_pos_actual = LENGTH(plinea) THEN
		
			IF LENGTH(TRIM(v_palabra)) > 0 THEN
				IF LENGTH(v_renglon || v_palabra) <= pcaracteres 
						AND v_pos_actual < LENGTH(plinea) THEN
						LET v_renglon = v_renglon || v_palabra;
				ELIF LENGTH(v_renglon || v_palabra) <= pcaracteres 
						AND v_pos_actual = LENGTH(plinea) THEN
						LET v_renglon = v_renglon || v_palabra;
						RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
						LET v_renglon = v_palabra;
				ELSE
						RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
						LET v_renglon = v_palabra;
                        if v_pos_actual >= LENGTH(plinea)  then
                          RETURN v_renglon,LENGTH(v_renglon) WITH RESUME;
                        end if;
				END IF
				LET iBanderaEsp = iBanderaEsp+1;
			END IF
			LET v_palabra = "";
		END IF;
		
		LET v_pos_actual = v_pos_actual + 1;

	END WHILE
	
	IF NVL(v_palabra2,'') <> '' THEN --RQI 22 268 JMAH
		 RETURN v_palabra2,LENGTH(v_palabra2) WITH RESUME; 
	END IF;
	
END
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".calc_iva_grav_pp(p_cEmpresa CHAR(3), p_cNumCredito CHAR(20), p_dTasaInt DECIMAL(9,6),
                                             p_dIvaSuc DECIMAL(5,3), p_dtFechaHoy DATE,p_dtIvaFechaPag DATE,
                                             p_dtFechaApert DATE,p_dtFechaCuota DATE,p_dIntNorm DECIMAL(18,2))

RETURNING
   CHAR(6)        AS Cod_Ret,
   DECIMAL(18,2)  AS IvaIntReal,
   CHAR(80)       AS Mens_Ret;

    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cErrorInfo       CHAR(80);
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensajeRet      CHAR(125);
    DEFINE l_diascalc       INTEGER;
    DEFINE l_dtFechaComp    DATE;
    DEFINE l_iDias          INTEGER;
    DEFINE l_dFactor1       DECIMAL(14,9);
    DEFINE l_dFactor2       DECIMAL(14,9);
    DEFINE l_dTasaReal      DECIMAL(14,9);
    DEFINE l_dFactorIntReal DECIMAL(14,9);
    DEFINE l_dIvaIntReal    DECIMAL(18,2);

    LET iSqlErr               = 0;
    LET iIsamErr              = 0;
    LET cErrorInfo            = "";
    LET cCodRet               = "000000";
    LET cMensajeRet           = "Proceso Exitoso";

    LET l_diascalc            = 0;
    LET l_dtFechaComp         = DATE(1);
    LET l_iDias               = 0;
    LET l_dFactor1            = 0;
    LET l_dFactor2            = 0;
    LET l_dTasaReal           = 0;
    LET l_dFactorIntReal      = 0;
    LET l_dIvaIntReal         = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
       RETURN cCodRet,l_dIvaIntReal,cMensajeRet;
       END IF;
    END EXCEPTION;

   -- SET DEBUG FILE TO "/pisa/cas/calc_iva_grav_pp.out";
   -- TRACE ON;

--    SET LOCK MODE TO WAIT 3;

    select valor
    into l_diascalc
    from bdicred:sd_param
    where cod_param='24'
    and empresa= p_cEmpresa;

    IF p_dtIvaFechaPag IS NULL THEN
        CALL bdicred:monthadd(p_dtFechaCuota,-1) RETURNING l_dtFechaComp;

          SELECT fecha_cuota
            INTO l_dtFechaComp
            FROM "informix".sd_amortiza_creditocrd
           WHERE empresa     = p_cEmpresa
             AND num_credito = p_cNumCredito
             AND fecha_cuota = l_dtFechaComp;

             IF l_dtFechaComp IS NULL THEN
                 LET l_dtFechaComp = p_dtFechaApert;
             END IF;
    ELSE
          LET l_dtFechaComp = p_dtIvaFechaPag;
    END IF;

    LET l_iDias    = p_dtFechaHoy - l_dtFechaComp;

    IF l_iDias > 0 THEN
        LET l_dFactor1 = NVL(p_dTasaInt,0)/(l_diascalc *100)* l_iDias;
        IF NVL(l_dFactor1,0) < 0 THEN
             LET cCodRet      = "000001";
             LET cMensajeRet  = "No es posible realizar los calculos con el valor obtenido para el factor 1";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        CALL bdicred:determina_udi_rango(p_cEmpresa,date(l_dtFechaComp-1),date(p_dtFechaHoy-1)) RETURNING cCodRet,l_dFactor2;

        IF NVL(l_dFactor2,0) < 0 THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "No es posible realizar los calculos con el valor obtenido para el factor 2";
          RETURN cCodRet,l_dIvaIntReal,TRIM(cMensajeRet);
        END IF;

        LET l_dTasaReal       = l_dFactor1 - l_dFactor2;
        IF l_dTasaReal< 0 THEN LET l_dTasaReal=0; END IF;
        IF l_dTasaReal = 0 THEN
		 LET l_dFactorIntReal = 0;
		ELSE
			LET l_dFactorIntReal  = (l_dTasaReal * p_dIvaSuc)/l_dFactor1;
		END IF;
--        LET p_dIntNorm        = g_dSdoInt;
        LET l_dIvaIntReal     = round(l_dFactorIntReal * p_dIntNorm,2);
    END IF;

    IF cCodRet <> "000000" THEN
      LET cCodRet = "000000";
    END IF;

        RETURN cCodRet,l_dIvaIntReal,cMensajeRet;

    END
END PROCEDURE;
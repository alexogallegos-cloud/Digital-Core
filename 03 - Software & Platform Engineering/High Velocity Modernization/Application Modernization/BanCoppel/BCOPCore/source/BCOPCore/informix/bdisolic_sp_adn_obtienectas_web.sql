CREATE PROCEDURE "informix".sp_adn_obtienectas_web(pEmpresa CHAR(3), pNumCte CHAR(20))

RETURNING CHAR(5) AS codigo_retorno, CHAR(20) AS cuentas;

DEFINE cCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE cCuenta	    CHAR(20);
DEFINE iMeses       INTEGER;
DEFINE iContador    INTEGER;
DEFINE dFechaValida	DATE;
DEFINE dFechaAlta	DATE;
DEFINE iPortabilidad	INTEGER;
DEFINE cCuentaNomDesp	CHAR(2);
DEFINE cProducto	CHAR(1300);
DEFINE cVarCodr     CHAR(5); 
DEFINE cVarCta      CHAR(20);
DEFINE cVarDisp     CHAR(2);
DEFINE cVarPrim     DATE;
DEFINE cVarUlt      DATE;

LET cCodRet			= "00000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cCuenta		= "";
LET iContador 	= 0;
LET iMeses 	    = 0;
LET iPortabilidad 	= 0;
LET dFechaValida 	= DATE(1);
LET dFechaAlta 	= DATE(1);
LET cCuentaNomDesp 	= "";
LET cProducto 	= "";

LET cVarCodr    = '';
LET cVarCta     = '';
LET cVarDisp    = '';
LET cVarPrim    = DATE(1);
LET cVarUlt     = DATE(1);

BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(8);
			RETURN NVL(cCodRet,''),'';
		END IF;
	END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/jesus/sp_adn_obtienectas.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = "" OR  TRIM(NVL(pNumCte,"")) = ""  THEN
		LET cCodRet  = "00001";
		RETURN NVL(cCodRet,''),'';
	END IF;
    
	FOREACH
	
		SELECT mae.cuenta, noc.fecha_alta, cp2.meses_alta,NVL(mae.proced_aperturacta,''),mae.producto
		INTO cCuenta, dFechaAlta, iMeses, cCuentaNomDesp, cProducto
		FROM bdicheq:"informix".sc_maechq mae
		INNER JOIN bdicheq:"informix".sc_maenoc noc ON (noc.cuenta = mae.cuenta)
		INNER JOIN "informix".ss_producto_credcap cp2 ON (cp2.num_producto = '7800' AND cp2.producto_cap = mae.producto)		
		WHERE mae.num_cte = pNumCte	
		AND mae.status_cta ='1'
		--AND NVL(mae.proced_mantenercta,'') ='02'
		--RQM 10 617-2
		IF cProducto NOT IN('1300','1700') then --validacion de portabilidad en tramite de otros bancos a bancoppel		
			IF NVL(cCuentaNomDesp,'') <> '02' THEN
				IF ( SELECT num_cte  FROM bdicheq:sc_portacec_solicitud where num_cte = pNumCte and  estatus_portabilidad ='1' and clave_sentido ='2' ) = 0 THEN					
					CONTINUE FOREACH;
				END IF;
			END IF;
		END IF;

		--validacion de portabilidad en tramite de bancoppel a otros bancos --RQM 10 617-2
		IF( SELECT num_cte  FROM bdicheq:sc_portacec_solicitud where num_cte = pNumcte and  estatus_portabilidad in('1','2') and clave_sentido ='1' and  substring(cta_ordenante from 7 for 11 )=cCuenta ) > 0 THEN					
			CONTINUE FOREACH;
		END IF;		

        --Valida DISPERSIONES POR CUENTA         -- RQM 10 1090
        IF cProducto IN ('1300','1700','1400','1900','2000') THEN
            EXECUTE PROCEDURE bdinteg:"informix".consultdispnom('001', cCuenta)											
            INTO cVarCodr, cVarCta, cVarDisp, cVarPrim, cVarUlt;
            IF cVarCodr = "00000" THEN
				IF (cVarPrim <= today - 90) AND (cVarUlt >= TODAY - 31)  THEN
					LET iContador = 1;
					RETURN NVL(cCodRet,''), cCuenta  WITH RESUME;
				ELSE
					CONTINUE FOREACH;
				END IF;
            ELSE
                CONTINUE FOREACH;
            END IF;
            
        CONTINUE FOREACH;    
        END IF    
        -- FIN EXEC SP CONSULTA DISPERSIONES

		/*IF iMeses > 0 THEN --RQM 10 617-2			Se comenta RQM 101090
			CALL bdicred:"informix".monthadd(today,-iMeses) RETURNING dFechaValida;	
			
			IF NOT (dFechaAlta <= dFechaValida ) THEN
				CONTINUE FOREACH;
			END IF;		
		END IF*/

        LET iContador = 1;

		RETURN NVL(cCodRet,''), cCuenta  WITH RESUME;				
		
	END  FOREACH;
 IF iContador = 0 THEN 
	RETURN '00002',''; -- No se encontraron cuentas validas
 END IF;

END
END PROCEDURE

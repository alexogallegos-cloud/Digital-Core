CREATE PROCEDURE "informix".sp_validacondonacion_tdd(pEmpresa CHAR(3),pSucursal CHAR(4))

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

	LET cCodRet			= '000000';
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
			LET cCodRet = '000001';
						
		ELSE
					
			-- NUMERO DE LIMITE DE CONDONACIONES PERMITIDAS 
			SELECT valor::INTEGER INTO iValor FROM "informix".sc_param WHERE empresa = TRIM(NVL(pEmpresa,'')) AND codparam = 'LIMITECONDONA';
			
			--PERIODO DE FECHA PERMITIDO PARA LAS CONDONACIONES 
			SELECT pri_dia_mes,ult_dia_mes INTO dtPriDiaMes,dtUltDiaMes FROM "informix".sc_fechas 
			WHERE empresa = TRIM(NVL(pEmpresa,''));
			
			IF NVL(iValor,0) = 0 OR  NVL(dtPriDiaMes,'') = ''  OR NVL(dtUltDiaMes,'') = '' THEN
			
				--NO SE ENCONTRARON ALGUNOS PARAMETROS NECESARIOS PARA DEFINIR SI ES POSIBLE LA CONDONACION
				LET cCodRet = "000002";	
			
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

CREATE PROCEDURE "informix".sp_cancela_solportab()
    --CODIGO RETORNO
    RETURNING CHAR(3);  
	
	DEFINE sql_err		INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE dtFechaHoy	DATE;
    DEFINE dtFechaVen	DATE;
	DEFINE vFechacal	CHAR(10);
	
	LET vcodret1 	= "000";
    LET sql_err  	= 0;
	LET dtFechaHoy  = DATE(1);
	LET dtFechaVen  = DATE(1);
	LET vFechacal 	= "";

BEGIN
	
	ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1;
        END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/vamilan/sp_cancela_solportab.out";
	--TRACE ON;
  
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = '001';

    LET dtFechaVen = dtFechaHoy - 6 UNITS DAY;     
    LET vFechacal = TO_CHAR(dtFechaVen, '%Y%m%d');  
    

	UPDATE {+ INDEX(sc_portacec_solicitud idx_sc_portacec_solicitud)} bdicheq:"informix".sc_portacec_solicitud set estatus_portabilidad=6, clave_sentido=0 , fecha_solca_portabilidad= TO_CHAR(dtFechaHoy, '%Y%m%d')
		WHERE fecha_solicitud < vFechacal and estatus_portabilidad=2 and clave_origen in (1, 2);
		
		
		
    RETURN vcodret1;

END;
END PROCEDURE
;
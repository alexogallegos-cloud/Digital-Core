CREATE PROCEDURE "informix".sp_validador24d(pfechaejecuta date) 
    RETURNING VARCHAR(5),VARCHAR(255);
	
	DEFINE cVarDataErr              VARCHAR(64);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iSamErr                  INTEGER;
    DEFINE vCodRet                  CHAR(5);
	DEFINE vdesc 					VARCHAR(255);
	DEFINE v_extracdia              INTEGER; 
    --VARIABLES CONTROL CICLO RECORRIDO DEL 
	--DEFINE v_tipo					CHAR(1);
	DEFINE v_porcentaje				FLOAT;
	DEFINE v_ultimodia              INTEGER;
	DEFINE v_dias_ret    			INTEGER;
	DEFINE v_rango					CHAR(5);
	
	LET vcodret = '00000';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
BEGIN
--Manejo del error
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
         SET DEBUG FILE TO "/informix/Cheques/sp_validador24d.err";
			IF iSqlErr <> 0 THEN
				LET vCodret=iSqlErr;
				RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
			END IF;
		END EXCEPTION;  
		
		--SET DEBUG FILE TO "/informix/Cheques/sp_validador24d.out";
        --TRACE ON;	 
									
-- // Valida la fecha del Movimiento
    IF (pfechaejecuta is null) or (pfechaejecuta = '') then
        LET vcodret = '00001'; -- Falta parametro Fecha de Operacion
        LET cVarDataErr = 'Falta parametro Fecha de Operacion';
        RETURN vcodret, cVarDataErr;
    END IF;
	
	
	-- GENERA LA EXTRACCION DE LA INFORMACION
	    LET v_ultimodia = day(pfechaejecuta);
	WHILE v_ultimodia > 0  
		
		IF NOT EXISTS (SELECT fecha FROM sc_fechvalr24d WHERE fecha = pfechaejecuta) THEN	
			INSERT INTO sc_valr24d
			SELECT {+INDEX("informix".sc_movhis idx_movhisnew4)} 
			a.fech_alt, a.transacc, sum (a.monto_tot) as montototal, count(a.transacc) as numerotransacciones
			FROM bdicheq:sc_movhis as a, bdinteg: si_transacc as b
			WHERE a.empresa= '001'
			AND a.fech_alt = pfechaejecuta
			AND a.cancelad <> 'S'
			AND a.transacc = b.numero
			AND b.regulatorios = '1'
			GROUP BY 1,2;
			--ORDER BY 2;
			
			
			INSERT INTO sc_fechvalr24d(fecha)
			VALUES (pfechaejecuta);
		END IF
						
	   LET v_ultimodia = v_ultimodia - 1;
	   LET pfechaejecuta = pfechaejecuta - 1 UNITS DAY;
	   
	END WHILE
	
	return vcodret, 'Exitoso';
		
END;	
END PROCEDURE;
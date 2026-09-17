CREATE PROCEDURE "informix".sp_elimina_referencias(pEmpresa CHAR(3),
														pNumSolicitudActual CHAR(20) ,
														pNumcte CHAR(20))

--RETORNOS-
RETURNING
CHAR(6)  AS codigo_ret;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;
DEFINE iBandera                 INTEGER;
DEFINE sSecuencia               INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodret                 = '000000'; --EJECUCION EXITOSA
LET iIsamErr                = 0;
LET iSql_err                = 0; 
LET iBandera                = 0;
LET sSecuencia				= 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/sysifx/Lerma/sp_elimina_referencias_debug.sql';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	 
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActual,'')= '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '000001'; 
		RETURN TRIM(cCodret);
	 END IF;
	 
	 DELETE FROM bdisolic:"informix".ss_refpersonales where  num_solicitud = pNumSolicitudActual;
	
	 SELECT COUNT(*) 
	 INTO iBandera
	 FROM bdinteg:"informix".si_refclientes 
	 WHERE numcte = pNumcte 
	 AND num_solicitud = pNumSolicitudActual 
	 AND empresa = pEmpresa; 
	 
	If iBandera > 0 THEN	
		FOREACH
		
			SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} secuencia
			INTO sSecuencia
			FROM bdinteg:"informix".si_refclientes 
			WHERE numcte = pNumcte 
			AND num_solicitud = pNumSolicitudActual 
					
			
			DELETE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} FROM bdinteg:"informix".si_refdirecciones WHERE secuencia = sSecuencia;
			
		END FOREACH;
		
		DELETE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FROM bdinteg:"informix".si_refclientes 
		WHERE numcte = pNumcte
		AND num_solicitud = pNumSolicitudActual 
		AND empresa = pEmpresa ;
		
	ELSE
		LET cCodret = '000002';  
	END IF;
	
	RETURN TRIM(cCodret) ;
	
END;
END PROCEDURE

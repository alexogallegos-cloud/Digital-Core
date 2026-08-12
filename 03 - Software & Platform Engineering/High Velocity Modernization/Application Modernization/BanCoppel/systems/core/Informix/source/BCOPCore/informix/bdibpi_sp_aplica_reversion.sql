CREATE PROCEDURE "informix".sp_aplica_reversion(pEmpresa char(3),pUsuario CHAR(8),pSolicitud CHAR(10),pNumCliente CHAR(9))
returning CHAR(5) as codRet;

--**************************************************************************************
-- Realizó: José Rubén López
-- Modificación: se encargara de reversar el cobro de las solicitudes en el proceso de asignacion individual por cancelacion del usuario.
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud: 28-08-2014

-- Realizó: José Rubén López
-- Modificación: se modifico la manera de como se obtiene el folio para reversar el cobro.
-- Solicitó: José de Jesus Nevarez
-- Fecha de Solicitud:30-09-2014
--**************************************************************************************
-- DECLARA VARIABLES
--**************************************************************************************
	DEFINE sql_err integer ;
	DEFINE cCodRet char(5);
	DEFINE cFolioSuc char(16);
	DEFINE cTipo char(1);
	DEFINE cSucursal char(4);
	DEFINE dFechaHoy  date;

	
--**************************************************************************************
-- INICIALIZA VARIABLES
--**************************************************************************************
	LET	cCodRet = '00000';
	LET cFolioSuc = '';
	LET	cTipo  = '';
	LET cSucursal = '';
	
	
	
	--SET DEBUG FILE TO "/home/sysifx/sp_aplica_reversion.out";
    --TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
	
	   ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cCodRet = sql_err;
				RETURN cCodRet;
		  END IF ;
	   END EXCEPTION ;
			
			--Se realiza un select para obtener la fecha actual
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicheq:"informix".sc_fechas;
			
			--se realiza un select para sacar la sucursal
			SELECT  tipo,sucursal
			INTO  cTipo,cSucursal
			FROM bdibpi:"informix".bpi_tokensolicitud 
			WHERE numcte=pNumCliente AND solicitud=pSolicitud;
			
			--se realiza un select para sacar el folio_suc
			
			SELECT folio_suc
			INTO cFolioSuc
			FROM bdicheq:"informix".sc_movdia
			WHERE cuenta IN ( SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = pNumCliente )
			AND fech_alt = dFechaHoy AND cancelad <> "S"
			AND transacc = '3006';
			
			IF (cFolioSuc IS NOT NULL OR cFolioSuc <> '') THEN
				IF TRIM(SUBSTRING(cFolioSuc FROM 1 FOR 8)) <> "SINCOMIS" THEN --Valida si se aplico cargo
					IF (cTipo= 2 OR cTipo = 4 OR cTipo=7) THEN
							--Realiza reversion 
							EXECUTE PROCEDURE bdicheq:"informix".reversion('001',
																  cSucursal,
																  pUsuario,
																  cFolioSuc,
																  'A' )
							INTO cCodRet ;	
							  
					END IF;
				END IF;
			END IF;

		RETURN cCodRet;

	END;
	
END PROCEDURE;
CREATE PROCEDURE "informix".sp_activacionlotesucursal (
	pEmpresa CHAR(3),
	pSucursal CHAR(4) )
RETURNING
	CHAR(5) AS  cCodRet,
	CHAR(50) AS cMensaje
	


	-----------------------------------------------------------------------------------------------------
	--	00000 =  
	--	00001 =  
	--	00002 =  

	-----------------------------------------------------------------------------------------------------

--- DECLARACIONES
DEFINE cCodRet 				CHAR(5);
DEFINE iSqlErr      		INTEGER;
DEFINE iSamErr      		INTEGER;
DEFINE cDesErr      		CHAR(60);

DEFINE cMensaje 			CHAR(50);
DEFINE cTipoTarjeta			CHAR(1);
DEFINE iNumLote				INT;
DEFINE iCantidadTarjetas	INT;
DEFINE iRangoInicial		INT;
DEFINE iRangoFinal			INT;
DEFINE cNumeroEmpleado		CHAR(9);

LET cMensaje = '';
LET cCodRet = '00000';
LET cNumeroEmpleado = '70000001';


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				let cCodRet = iSqlErr;
				RETURN cCodRet, 'Ocurrio un error';
			END IF ;
		END EXCEPTION ;
		
		--SET DEBUG FILE TO '/tmp/jbueno/sp_activacionlotesucursal.out';
		--TRACE ON;
		
		
		--Validar si hay folios pendientes de activar para la sucursal
		IF EXISTS(SELECT * FROM bditarjcop:"informix".enviostarcop  WHERE empresa = pEmpresa AND cvesucursal = pSucursal AND enviodisponible ='P' ) THEN
			--LET cMensaje = 'Se realiza la activaciÃ³n de los lotes a sucursal';
			FOREACH
				SELECT tipotarjeta,numenvio, cantidadrec,rangoini,rangofin 
				INTO cTipoTarjeta,iNumLote,iCantidadTarjetas,iRangoInicial,iRangoFinal
				FROM bditarjcop:"informix".enviostarcop  
				WHERE empresa = pEmpresa
				AND cvesucursal = pSucursal
				AND enviodisponible ='P'
				
				EXECUTE PROCEDURE bdiTarjCop:"informix".sp_RecibirLoteTarCop(pEmpresa,pSucursal,iNumLote,cTipoTarjeta,iCantidadTarjetas,iRangoInicial,iRangoFinal,cNumeroEmpleado)
				INTO cCodRet;
			END FOREACH;
			LET cMensaje ='Lotes activados correctamente';
		ELSE 
			LET cCodRet = '00002';
			LET  cMensaje ='No existen lotes por activar de esa sucursal';
		END IF;
		
		RETURN cCodRet,cMensaje;
		
	END;
END PROCEDURE;
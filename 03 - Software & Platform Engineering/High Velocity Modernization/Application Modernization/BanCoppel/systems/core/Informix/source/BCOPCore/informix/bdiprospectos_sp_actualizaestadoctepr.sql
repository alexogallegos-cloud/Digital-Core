CREATE PROCEDURE "informix".sp_actualizaestadoctepr(pTipoConsulta CHAR(1), pEmpresa CHAR(3), pNumCtePr CHAR(20), pNumCteBcpl CHAR(20), pEstado CHAR(20))
RETURNING CHAR(5);

--DECLARACION DE VARIABLES
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cCliente_pros CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = '00000';
LET cCliente_pros = '1';

BEGIN
	--CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/Pedro/1468//sp_actualizaestadoctepr.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--VALIDA PARAMETROS SI NO VIENEN VACIOS
	IF NVL(pTipoConsulta,'') <> '' AND NVL(pEmpresa,'') <> '' AND NVL(pNumCtePr,'') <> '' THEN
		
		IF pTipoConsulta = '1' THEN
			UPDATE 'informix'.pr_cliente SET estado = pEstado, numcte = pNumCteBcpl
			WHERE empresa = pEmpresa AND numcte_pros = pNumCtePr;
			
			--1468 SE ACTUALIZA EL NUEVO CAMPO CLIENTE_PROS DE LA TABLA SI_CLIENTE 
			IF EXISTS(select status_numcte_pros from bdiprospectos:pr_cliente where numcte = pNumCteBcpl AND status_numcte_pros IN ('AN','PC','RT','CN'))THEN
				let cCliente_pros = '0';
			END IF;
			
				UPDATE bdinteg:'informix'.si_cliente SET cliente_pros = cCliente_pros
				WHERE numcte = pNumCteBcpl;
				
		ELIF pTipoConsulta = '2' THEN
			UPDATE 'informix'.pr_cliente SET estado = pEstado
			WHERE empresa = pEmpresa AND numcte_pros = pNumCtePr;
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	
	RETURN cCodRet;
END;
END PROCEDURE

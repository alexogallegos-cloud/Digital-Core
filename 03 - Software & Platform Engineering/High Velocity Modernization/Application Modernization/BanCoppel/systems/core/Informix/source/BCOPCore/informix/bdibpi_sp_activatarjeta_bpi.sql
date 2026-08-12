CREATE PROCEDURE "informix".sp_activatarjeta_bpi(pEmpresa CHAR(3), pTipoConsulta CHAR(1), pNumCte char(15), pNumTarjeta CHAR(20), pEstatus CHAR(1))
RETURNING CHAR(5) as cCodRet;

DEFINE vsqlerr INTEGER;
DEFINE cCodRet CHAR(5);

LET vsqlerr = 0;
LET cCodRet = "00000";


BEGIN
	ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
		LET cCodRet = vsqlerr;
		RETURN cCodRet;
      END IF;
	END EXCEPTION;
   
	--SET DEBUG FILE TO "/informix/JoseDeJesus/sp_registra_evento_nuevo.out";
	--TRACE ON;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pTipoConsulta = 'D' THEN
		UPDATE bdicheq:'informix'.sc_tarjeta SET status_tar = pEstatus WHERE num_tarjeta = TRIM(pNumTarjeta) AND numcte = TRIM(pNumCte) and empresa = pEmpresa;
	ELIF pTipoConsulta = 'C' THEN
		UPDATE bdicred:'informix'.sd_tarjeta SET status_tar = pEstatus WHERE num_tarjeta = TRIM(pNumTarjeta) AND numcte = TRIM(pNumCte) and empresa = pEmpresa;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") <> 1 THEN
		LET cCodRet = '00001';
	END IF;
	
	RETURN cCodRet;
		
	
END;	
END PROCEDURE
DOCUMENT
'OBJETIVO: 	actualizar el estatus de la tarjeta de crédito o débito',
'AUTOR:		José de Jesús Nevarez',
'FECHA : 	20/07/2017',
'BD : 		bdibpi';

CREATE PROCEDURE "informix".sp_cambiarstatus_serv_bex(pNumCel CHAR(10),pNumCte CHAR(10),pNuevoStatus SMALLINT)
	RETURNING char (5);

--Define variables
define sql_err integer;
define cod_ret char (5);
define estatus_anterior smallint;

--Inicializa variables
LET sql_err = '';
LET cod_ret = '00000';
LET estatus_anterior = 0;


--	SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_cambiarstatus_serv_bex.out";
--	TRACE ON;

BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret;
   END EXCEPTION;

   IF(NVL(pNumcte,'')='' OR NVL(pNumCel,'')='' OR NVL(pNuevoStatus,'')='') THEN
		LET cod_ret = '00002';
		RETURN cod_ret;
	END IF;
		
   IF EXISTS(SELECT id_usuario FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumcte AND no_celular = pNumCel) THEN
			IF EXISTS(SELECT id_usuario FROM bdibpi:bpi_registro_bex WHERE num_cliente = pNumcte AND no_celular = pNumCel AND estatus_servicio = 3) THEN
					
					UPDATE bdibpi:bpi_registro_bex  SET estatus_servicio = pNuevoStatus  WHERE num_cliente = pNumcte AND no_celular=pNumCel AND estatus_servicio=3;
					
					DELETE FROM bdibpi:bpi_ctl_inicio_sesion_bex WHERE num_cliente = pNumcte AND no_celular=pNumCel;
					
					LET cod_ret = '00000'; 
			END IF		
	ELSE
		LET cod_ret = '00001'; -- El cliente No existe
	END IF;

	RETURN cod_ret;

END;

END PROCEDURE;
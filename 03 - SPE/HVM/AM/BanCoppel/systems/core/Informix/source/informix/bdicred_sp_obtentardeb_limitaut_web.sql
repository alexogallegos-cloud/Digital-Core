CREATE PROCEDURE "informix".sp_obtentardeb_limitaut_web(pEmpresa CHAR(3), pNumcte CHAR(20), pCuenta CHAR(20), pNumcred CHAR(20))

RETURNING CHAR(5)  AS codret,
          CHAR(20) AS tarjetadeb,
          DECIMAL(14,2)  AS lineaaut;

DEFINE vCodret char(5);
DEFINE vNumtar CHAR(20);
DEFINE vLimaut DECIMAL(14,2);
DEFINE vsqlerr INTEGER;

LET vCodret = '00000';
LET vNumtar = '';  
LET vLimaut = 0;
LET vsqlerr = 0;

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET vCodret= vsqlerr;
			RETURN vCodret,vNumtar,vLimaut;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/sp_obtentardeb_limitaut.out';
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pEmpresa is null or pEmpresa = '' then 
		LET  vCodret= '00110';  --parametros incompletos
		RETURN vCodret,vNumtar,vLimaut;
	END IF;

	--   SELECT num_tarjeta 
	--  INTO vNumtar 
	-- FROM bdicheq:sc_tarjeta
	-- WHERE numcte=pNumcte 
	-- AND p

	SELECT num_tarjeta
	INTO vNumtar 
	FROM bdicheq:sc_tarjeta 
	WHERE numcte = pNumcte --'000001042' 
	AND cuenta= pCuenta --'10000005237' 
	AND tipo_tarjeta='T' 
	AND status_tar= 'A';

	SELECT limite_aut
	INTO vLimaut 
	FROM bdicred:sd_tarjeta 
	WHERE  numcte= pNumcte --'057197440' 
	AND num_credito= pNumcred--'600458762249'
	AND status_tar ='A';

	RETURN vCodret,NVL(vNumtar,0),NVL(vLimaut,0);

END;
END PROCEDURE;
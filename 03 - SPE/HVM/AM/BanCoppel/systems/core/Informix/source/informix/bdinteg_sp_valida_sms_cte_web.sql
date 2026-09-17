CREATE PROCEDURE "informix".sp_valida_sms_cte_web( pNumCte CHAR(9))
 RETURNING CHAR(5) as CodRet ,
		   SMALLINT  as valido,
		   CHAR(13) as telefono;

DEFINE cCodret   CHAR(5);
DEFINE iSql_err  INTEGER;
DEFINE iValido   INTEGER;
DEFINE cTel      CHAR(13);

LET cCodret     = '00000';
LET iSql_err    = 0;
LET iValido     = 0;
LET cTel        = '';

BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR);
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret,iValido,cTel;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO '/informix/jesus/sp_valida_sms_cte.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    
	IF (SELECT COUNT(b.numcte)
		FROM bdinteg:"informix".si_telefonos_actual a
		LEFT JOIN bdinteg:"informix".si_bitsmstels b ON a.numcte=b.numcte AND a.telefono=b.telefono AND  b.bandera='t' AND  b.fecha::DATE = TODAY		
		WHERE a.numcte=pNumCte
		AND a.tipo_tel=2 AND a.status_tel='A'
		and fecha = (SELECT max(fecha) from bdinteg:"informix".si_bitsmstels c 
                        where c.numcte=a.numcte AND a.telefono=a.telefono 
                        AND  c.fecha::DATE = TODAY)
		) 
 > 0 THEN		
			LET iValido =1;
		
	END IF 
    
    SELECT  LIMIT 1 telefono
    INTO cTel
    FROM bdinteg:"informix".si_telefonos_actual a
    WHERE a.numcte=pNumCte
    AND a.tipo_tel=2 AND a.status_tel='A';
		
	RETURN cCodret,iValido, cTel;

END;
END PROCEDURE
DOCUMENT
'Autor:	JESUS MANUEL AGUILAR HEREDIA',
'FECHA:	30/SEP/2016',
'DESCRIPCION: se crea procedimiento para ser usado en el flujo de 2 credito.',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_valida_confirmacion_movil_web(pNumCte CHAR(9), pUsuario CHAR(8),pTelefono CHAR(10))
RETURNING CHAR(5) As cCodRet;

--Definicion de Variables 
DEFINE cCodRet			CHAR (5);
DEFINE cBandera         BOOLEAN;
DEFINE iSqlErr          INTEGER;
--Inicializacion de Variables

LET cCodRet      = '00000';
LET cBandera     = 'F';
LET iSqlErr      = 0;

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/Braulio/sp_valida_confirmacion_movil.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pTelefono,'') <> '' THEN

			SELECT bandera 
			INTO cBandera
			FROM bdinteg:"informix".si_bitsmstels
			WHERE numcte = pNumCte 
			AND telefono = pTelefono 
			AND ejecutivo = pUsuario
			AND fecha IN (SELECT MAX(FECHA) FROM bdinteg:"informix".si_bitsmstels 
						  WHERE numcte = pNumCte
						  AND telefono = pTelefono
						  AND ejecutivo = pUsuario);

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '01289';
				RETURN cCodRet;
			END IF;

			IF cBandera = 'F' THEN
				LET cCodRet = '01386';
			ELIF cBandera = 'T' THEN
				LET cCodRet = '00000';
			END IF;
	ELSE
		LET cCodRet = '00001';
	END IF; 

RETURN cCodRet;
END;
END PROCEDURE;
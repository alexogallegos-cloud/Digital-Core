CREATE PROCEDURE "informix".sp_infosms_cte( pNumCte CHAR(9))
RETURNING CHAR(5) as CodRet, CHAR(9) as NumCte, CHAR(10) as TelCel, CHAR(4) as CodSMS;


DEFINE cCodret   CHAR(5);
DEFINE iSql_err  INTEGER;
DEFINE sNumCte   CHAR(9);
DEFINE sTelCel   CHAR(10);
DEFINE sCodSMS   CHAR(4);

LET cCodret     = '00000';
LET iSql_err    = 0;
LET sNumCte     = '';
LET sTelCel     = '';
LET sCodSMS     = '';


BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR);
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret, sNumCte, sTelCel, sCodSMS;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT FIRST 1 a.numcte, a.telefono, b.digito_ver
          INTO sNumCte, sTelCel, sCodSMS
            FROM bdinteg:si_telefonos_actual a
                LEFT JOIN bdinteg:si_bitsmstels b
                    ON a.numcte=b.numcte AND a.telefono=b.telefono --AND (b.teclea_ejecut IS NULL OR b.bandera='t')
            WHERE a.numcte=pNumCte
                AND a.tipo_tel=2 AND a.status_tel='A'
                ORDER BY b.fecha DESC
    END FOREACH;

	RETURN cCodret, NVL(sNumCte,0), NVL(sTelCel,''), NVL(sCodSMS,'');

END;
END PROCEDURE;
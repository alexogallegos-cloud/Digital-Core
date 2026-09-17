CREATE PROCEDURE "informix".sp_recupera_saldo(pcel CHAR(10))
	RETURNING CHAR(5) as codret, CHAR(160) as saldo_disp;

	DEFINE vcodret CHAR(5);
	DEFINE vtermcta CHAR(4);
    DEFINE vcant INTEGER;

	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;

    define vcuenta CHAR(20);
    define vsdodisp DECIMAL(18,2);
	define vcadena CHAR(500);

    LET vcodret    = "00000";
    LET vcuenta    = "";
	LET vtermcta   = "";
    LET vsdodisp   =  "0.00";
	LET vcadena	   = "EL SALDO DE SU CUENTA BANCOPPEL, TERM.";

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
        IF iSqlErr <> 0 THEN
            LET vcodret = iSqlErr;
            RETURN vcodret,cInfoErr;
        END IF
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF LENGTH(pcel) <> 10 THEN
        LET vcodret = "00001";
        RETURN vcodret,'NUMERO TELEFONICO INVALIDO, VERIFIQUE.';
    END IF;

    
    --cuenta los NUMEROS DE CLIENTES relacionados al telefono consultado
    SELECT COUNT(DISTINCT(a.numcte)) INTO vcant 
		FROM bdinteg:si_telefonos_actual a, bdicheq:sc_maechq b	
		WHERE telefono=pcel AND a.numcte=b.num_cte 
		AND producto IN('2000','1300','1400','1200','9900','1600','1500','1700','9901','1900','2300','2500','2200','2800','2600','2700','2400','8000', '2900') --EXCEPTO '1100' y '1800', SE AGREGA PRODUCTO 2900
		AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3');
	

	IF vcant > 1 THEN 
        LET vcodret = "00002";
        RETURN vcodret,'';
    ELIF vcant < 1 THEN 
        LET vcodret = "00000";
        RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UNA CUENTA DE AHORRO.';
    END IF;


    --cuenta las CUENTAS ASOCIADAS al cliente y numero de telefono consultado
	SELECT COUNT(DISTINCT(b.cuenta)) INTO vcant 
		FROM bdinteg:si_telefonos_actual a, bdicheq:sc_maechq b	
		WHERE telefono=pcel AND a.numcte=b.num_cte 
		AND producto IN('2000','1300','1400','1200','9900','1600','1500','1700','9901','1900','2300','2500','2200','2800','2600','2700','2400','8000', '2900') --EXCEPTO '1100' y '1800', SE AGREGA PRODUCTO 2900
		AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3');
	

	IF vcant > 1 THEN 
		LET vcadena = "EL SALDO DE SUS CUENTAS BANCOPPEL, TERM.";
    END IF;
	
	--RQM 09 704. Se agrega el campo de saldo inmovilizado en el calculo de saldo disponible.DHG
	FOREACH SELECT SUBSTR(b.cuenta,8,4) as term_cuenta, SUM(sdo_actual - (NVL(sdo_retenido,0)+ NVL(sdo_cong,0) + NVL(imp_sbg_ccc,0) + NVL(saldo_sbc,0))) as saldo
		INTO vtermcta,vsdodisp
		FROM bdinteg:si_telefonos_actual a, bdicheq:sc_maechq b	
		WHERE telefono=pcel AND a.numcte=b.num_cte
		AND producto IN('2000','1300','1400','1200','9900','1600','1500','1700','9901','1900','2300','2500','2200','2800','2600','2700','2400','8000', '2900') --EXCEPTO '1100' y '1800', SE AGREGA PRODUCTO 2900
		AND tipo_tel='2' AND status_tel='A' AND status_cta IN ('1','3') GROUP BY term_cuenta

		LET vcadena = TRIM(vcadena) || " ***" || vtermcta || ": " || TO_CHAR(vsdodisp, "$<<<,<<<,<<<,<<&.&&") || ", ";

	END FOREACH;                    

	RETURN vcodret, SUBSTR(SUBSTR(vcadena,1,LEN(vcadena) -1),1,160);

	END;
END PROCEDURE

CREATE PROCEDURE "informix".sp_segundaautenticawu(cNumcte CHAR(20), cRfc CHAR(13), cLicencia CHAR(20), cPais2Id CHAR(4), cEdo2Id CHAR(30))

RETURNING
	CHAR(5)  AS cCodRet;

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr      INTEGER; 
DEFINE iIsamErr    	INTEGER; 
DEFINE cInfoErr 	CHAR(10); 

LET cCodRet = "00000";
	
SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;
	
--SET DEBUG FILE TO "/tmp/Anayeli.out";
--TRACE ON;

BEGIN
	--CONTROL DE ERRORES 'INFORMIX' NO CONTROLADOS
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
	
    IF cRfc = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas 
		   SET rfc = rfc 
		WHERE numcte = cNumcte;	
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET rfc = cRfc 
		WHERE numcte = cNumcte;
	END IF;
	
	IF cLicencia = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET licencia = licencia 
		WHERE numcte = cNumcte;
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET licencia = cLicencia
		WHERE numcte = cNumcte;
	END IF;
	
	IF cPais2Id = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas
		SET pais2id = pais2id 
		WHERE numcte = cNumcte;			
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET pais2id = cPais2Id
		WHERE numcte = cNumcte;
	END IF;
	
	IF cEdo2Id = "" THEN
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET estado2id = estado2id
		WHERE numcte = cNumcte;
	ELSE
		UPDATE bdisac:"informix".sac_cte_remesas 
		SET estado2id = cEdo2Id
		WHERE numcte = cNumcte;
	END IF;
	
	/*UPDATE bdisac:"informix".sac_cte_remesas 
	SET rfc = (CASE WHEN cRfc = "" THEN rfc ELSE cRfc END),
		licencia = (CASE WHEN cLicencia = "" THEN licencia ELSE cLicencia END),
		pais2id = (CASE WHEN cPais2Id = "" THEN pais2id ELSE cPais2Id END),
		estado2id = (CASE WHEN cEdo2Id = "" THEN estado2id ELSE cEdo2Id END)	
	WHERE numcte = cNumcte;*/
	
	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'Folio: 433 REQ. Base de datos para el alta de usuarios de remesas',
'Autor: 98243217 Marco Rivera ',
'Fecha: 21/08/2018',
'Descripcion: Actualiza datos de segunda autenticacion.',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

create procedure "informix".sp_verificaconvenio(cValorconv char(10))

    RETURNING char(5), char (120);

    --DEFINICION DE VARIABLES
    define cCodret          char (5);
    define cValordesc       char (120);
    define sestatus         char(1);
    define sestatusov       char(1);
    define sestatusvg       char(1);
    define remdesc          char(15);
    define remdescov        char(15);
    define remdescvg        char(5);


    --INICIALIZACION DE VARIABLES
    let cCodret         = "00000";
    let cValordesc      = "";
    let sestatus        = "";
    let sestatusov      = "";
    let sestatusvg      = "";
    let remdesc         = "";
    let remdescov       = "";
    let remdescvg       = "";


    begin
        -- BTS (30802,30803,30804)
        if cValorconv in ('30802','30803') then
            select statusconvenio
            into sestatus
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '004';
            
            if sestatus = 'I' then
                let cCodret = "00504";
                let cValordesc = "Por el momento, el servicio de BTS no esta operando, intentelo más tarde";
            end if;
        end if;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
		
		if cValorconv = '20067' then
            select statusconvenio
            into sestatus
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '009';
            
            if sestatus = 'I' then
                let cCodret = "00504";
                let cValordesc = "Por el momento, el servicio de APPRIZA PAY no esta operando, intentelo más tarde";
            end if;
        end if;

/*		
        -- WU, OV y VG (30401,30402,30403,30405)
        if cValorconv in ('30401','30402','30403','30405') then
            select statusconvenio
            into sestatus
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '006';  --WU

            select statusconvenio
            into sestatusov
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '007';  --OV
            
            select statusconvenio
            into sestatusvg
            from bdisac:sac_convenios
            where numcategoria = '07' and numconvenio = '008';  --VG

            if sestatus = 'I' then
                let remdesc = 'Western Union';
            end if;
            if sestatusov = 'I' then
                let remdescov = 'Orlandi Valuta';
            end if;
            if sestatusvg = 'I' then
                let remdescvg = 'Vigo';
            end if;
            
            if sestatus = 'I' or sestatusov = 'I' or sestatusvg = 'I' then
                let cCodret = "00504";
                let cValordesc = "Por el momento, el o los servicios " || trim(remdesc) || " " || trim(remdescov) || " " || trim(remdescvg) || " no esta(n) operando, intentelo más tarde.";
            end if;
           
        end if;
*/		
		
        return cCodret, cValordesc;
    end;

end procedure;
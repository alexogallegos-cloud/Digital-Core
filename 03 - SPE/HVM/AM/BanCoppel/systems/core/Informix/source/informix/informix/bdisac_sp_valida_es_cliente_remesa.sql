CREATE PROCEDURE "informix".sp_valida_es_cliente_remesa(pNoCte CHAR(9))
RETURNING CHAR(5) As codErr;

	-- Definicion de variables --
	DEFINE cCodErr CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCont INTEGER;					  

	-- Inicializacion de variables --
	LET cCodErr = '00000';
	LET iSqlErr = 0;
	LET iCont = 0;
	
	-- SET DEBUG FILE TO "/tmp/mario/trace.sql";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				RETURN NVL(cCodErr,'');
			END IF;
        END EXCEPTION;

	--Validar que los parametros de entrada no vengan vacios o nulos
	IF NVL(pNoCte,'') = ''  THEN
		LET cCodErr = '00002';
	ELSE
	
		SELECT COUNT(*) INTO iCont FROM "informix".sac_cte_remesas WHERE numcte = pNoCte;

		IF iCont <> 0 THEN
			LET cCodErr = '00000';
		ELSE
			LET cCodErr = '00001';
		END IF;
		
	END IF;
								
    RETURN NVL(cCodErr,'');
END;
END PROCEDURE
DOCUMENT
'FOLIO.........: Iniciativa: Cobro Remesas Canales',
'AUTOR.........: 95142134-Mario Gallardo',
'FECHA.........: 18-10-2021',
'MODIFICACION..: Se crea procedimiento almacenado para validar si el cliente se encuentra en bd remesas',
'SOLICITA......: Leonardo Henandez',
'BD............: bdisac';

CREATE PROCEDURE "informix".sp_calculadvtelmex(cNumTel CHAR(10))

	RETURNING CHAR(5) as CodRet,CHAR(2) as DV;
	
	DEFINE cCodRet          	CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr         	CHAR(100);
	DEFINE cMensaje				VARCHAR(200); 
	
	DEFINE NumTel				CHAR(10);
	DEFINE NumDV				INTEGER;
    DEFINE iContador			INTEGER;
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_calculadvtelmex.out';
	--TRACE ON; 
	
	LET cCodRet = '00000';
    LET iSqlErr = '';
	LET iIsamErr = 0;
    LET cInfoErr = '';
	LET cMensaje = ''; 
	
	LET NumTel = '';
	LET NumDV = 0;
	LET iContador = 0;
	
	BEGIN
	
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_calculadvtelmex");
									
				--LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD "||cCodRet||"|"||cNumTel;
	
				RETURN cCodRet,NumDV;
			END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		LET NumTel = cNumTel;
		
		IF NumTel <> '' OR NumTel IS NOT NULL THEN 
	
			LET iContador = substr(NumTel,1,1)::int * 1;
			LET iContador = iContador + substr(NumTel,2,1)::int * 3;
			LET iContador = iContador + substr(NumTel,3,1)::int * 7;
			LET iContador = iContador + substr(NumTel,4,1)::int * 1;
			LET iContador = iContador + substr(NumTel,5,1)::int * 3;
			LET iContador = iContador + substr(NumTel,6,1)::int * 7;
			LET iContador = iContador + substr(NumTel,7,1)::int * 1;
			LET iContador = iContador + substr(NumTel,8,1)::int * 3;
			LET iContador = iContador + substr(NumTel,9,1)::int * 7;
			LET iContador = iContador + substr(NumTel,10,1)::int * 1;
			LET iContador = iContador + 49;
			LET iContador = mod(iContador, 9);
	
			LET NumDV = iContador + 1;
			LET cCodRet = '00000';
	
		ELSE
		
			LET cCodRet = '00001';
		
		END IF;
		
		RETURN cCodRet,NumDV;
		
    END;
END PROCEDURE;
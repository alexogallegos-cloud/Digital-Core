CREATE PROCEDURE "informix".sp_verifica_telefono_cel( p_Numcte CHAR(20), p_Telefono CHAR(13), p_TipoTelefono SMALLINT, p_TipoEjecucion SMALLINT)

RETURNING CHAR(5), CHAR (20);

--DeclaraciÃ³n de variables

	DEFINE v_verificado			CHAR (1);
	DEFINE v_CodRet 			CHAR(5);
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);
	DEFINE v_numcte				CHAR (20);
	DEFINE v_sec				SMALLINT;

--InicializaciÃ³n de Variables

	LET v_CodRet 	 = '';
	LET v_verificado = 'F';
	LET v_numcte 	 = '';
	LET v_sec 		 = 0;
	
	--SET DEBUG FILE TO "/tmp/PAOLA/sp_verifica_telefono_cel.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET v_CodRet     = iSqlErr;
		END IF;
			RETURN v_CodRet, v_numcte;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF (p_Telefono = ''  AND p_TipoEjecucion = 2 ) OR (p_Telefono = '' AND p_Numcte = '' AND p_TipoEjecucion = 1 ) THEN
			LET v_CodRet = '00001';
			LET v_numcte ='';
			RETURN v_CodRet, v_numcte; 
		END IF;
		
		IF p_TipoEjecucion = 1 THEN
		
			SELECT MAX(verificado)
			  INTO v_verificado 
			  FROM bdinteg:"informix".si_telefonos 
			 WHERE numcte = p_Numcte 
			   AND telefono = p_Telefono 
			   AND tipo_tel = p_TipoTelefono
			   AND status_tel = 'A';

			IF (v_verificado = 'F') THEN
				LET v_CodRet = '00000';
			ELSE
				LET v_CodRet = '00001';
			END IF;
			
		RETURN v_CodRet, v_numcte;
			
		ELIF p_TipoEjecucion = 2 THEN
			
			SELECT MAX (numcte) 
			  INTO v_numcte 
			  FROM bdinteg:"informix".si_telefonos a 
			 WHERE telefono = p_Telefono
			   AND tipo_tel = p_TipoTelefono
			   AND status_tel = 'A'
			   AND secuencia = (SELECT MAX(secuencia) 
			                      FROM bdinteg:"informix".si_telefonos b 
							     WHERE b.telefono = a.telefono 
							       AND b.tipo_tel = a.tipo_tel 
								   AND b.status_tel = a.status_tel);
			
				IF (v_numcte <> '') THEN
					LET v_CodRet = '00000';
					RETURN v_CodRet, v_numcte; 
				ELSE
					LET v_CodRet = '00001';
					LET v_numcte ='';
					RETURN v_CodRet, v_numcte; 
				END IF;
		END IF;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Realiza la validaciÃ³n del telefono del cliente para saber si el tipo es F o V',
'AUTOR : Ever Fierro HernÃ¡ndez',
'FECHA : 29/10/2018',
'Folio : 480',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_limpia_si_ctessat_tmp()

RETURNING CHAR(5) AS CodRet;

DEFINE iSql_err 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(50);
DEFINE cCalle		CHAR(40);
DEFINE cNumext		CHAR(10);
DEFINE cNumint		CHAR(10);
DEFINE iContador 	INTEGER;

LET iSql_err		= 0;
LET cCodRet 		= '00000';
LET cNumcte			= '';
LET cCalle			= '';
LET cNumext			= '';
LET cNumint			= '';
LET iContador       = 0;

BEGIN

	ON EXCEPTION
		SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			ROLLBACK WORK;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/emm/sp_limpia_si_ctessat_tmp.out';
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	
	FOREACH WITH HOLD
	
		SELECT {+INDEX (si_ctessat_tmp idx_si_ctessat_tmp_numcte)}
			numcte,replace(calle,'|','') calle,replace(num_ext,'|','') num_ext,replace(num_int,'|','') num_int 
		INTO cNumcte,cCalle,cNumext,cNumint FROM "informix".si_ctessat_tmp
		
		LET iContador = iContador + 1;
	
		UPDATE "informix".si_ctessat_tmp SET calle=cCalle, num_int=cNumext, num_ext=cNumint WHERE numcte=cNumcte;
	
		IF( iContador = 500 ) THEN
            COMMIT WORK;
            LET iContador = 0;
			BEGIN WORK;
        END IF;
	
	END FOREACH;
	
	COMMIT WORK;	
	RETURN cCodRet;
	
END;
END PROCEDURE;
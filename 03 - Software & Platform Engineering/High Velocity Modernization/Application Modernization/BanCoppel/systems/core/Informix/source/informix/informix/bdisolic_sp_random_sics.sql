CREATE PROCEDURE "informix".sp_random_sics(p_smaximo INTEGER,p_CanalSol CHAR (2))
	RETURNING CHAR(5) as codret,INTEGER as numeroaleatorio, CHAR(2) as institucionsic;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;

	DEFINE v_dsemilla		DECIMAL(10) ;
	DEFINE v_ddecimal		DECIMAL(20,0);
	DEFINE v_ivalor			INTEGER;
	DEFINE v_ssegundo		INTEGER;
	DEFINE v_ireturn		INTEGER;
	DEFINE v_institucion	CHAR(2);
	DEFINE p_snumero		INTEGER;
	
	LET cCodRet				= '00000';
	LET iSqlErr				= 0;
	LET p_snumero			= 0;
	LET v_ireturn			= 0;
	LET v_institucion		= '';
	
	
	--************************************************
	--*Creado por Felix Ignacio Leyva Gamez          *
	--************************************************
	-- Modifico: Felix Ignacio Leyva Gamez
	-- Fecha: 17/01/2022
	-- Descripcion: Se clona proceso para retornar numero random de Javier Calderon 14/12/2008.
	--				Y se agrega la consulta a la institucion crediticia que se consultara.
	-- Peticion: RQM 09 606 - Consulta aleatoria a las SIC's cadena 2x1 - Originacion
	-- BD:bdisolic			   
	
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************
	
	BEGIN
	
		--CONTROL DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;	
			RETURN cCodRet,v_ireturn,v_institucion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '//ifxsif01/Felix/ConsultaAleatoria/sp_random_sics.out';
		--TRACE ON;
		
		--Validacion de parametros
	
		IF p_smaximo IS NULL OR p_smaximo ='' OR p_CanalSol IS NULL OR p_CanalSol ='' THEN
			LET cCodRet = '00001'; --PARAMETRO VACIO
			RETURN cCodRet,v_ireturn,v_institucion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- Obtener el valor aleatorio
		SELECT LIMIT 1 SUBSTRING (CURRENT FROM 18 FOR 2) 
		INTO v_ssegundo
		FROM "informix".ss_sic_dinamicas;
	
		LET p_snumero = p_snumero + v_ssegundo;
		LET v_ddecimal = (p_snumero * 1103515245) + 12345;
		
		LET v_dsemilla = (v_ddecimal - (p_smaximo * 12345678)) * TRUNC(v_ddecimal / (p_smaximo * 12345678));
	
		LET v_ivalor = MOD(TRUNC(v_dsemilla / 65536), 32768);
	
		LET v_ireturn = MOD(v_ivalor, p_smaximo);
	
		IF v_ireturn = 0 THEN
			LET v_ireturn = p_smaximo;
		END IF
		--LET v_ireturn = 5;
		--Consultar la Institucion segun el aleatorio
		SELECT {+INDEX("informix".ss_sic_dinamicas idx_ss_sic_dinamicas)} institucion INTO v_institucion  FROM "informix".ss_sic_dinamicas 
				WHERE v_ireturn BETWEEN min_inst AND max_inst
				AND canal_solic = p_CanalSol;
		
		IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
			LET cCodRet = '00002'; --SI LA CONSULTA NO RETORNA INFORMACION
			RETURN cCodRet,v_ireturn,v_institucion;
		END IF;
		
		RETURN cCodRet,v_ireturn,v_institucion;
		
	END;
	
END PROCEDURE;
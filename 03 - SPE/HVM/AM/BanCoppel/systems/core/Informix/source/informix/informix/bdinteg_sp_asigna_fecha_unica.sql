CREATE PROCEDURE "informix".sp_asigna_fecha_unica(f_inicio  CHAR(10))
RETURNING CHAR (5),INT; --código de error y #registros procesados
	
	-- Ismael Hernández, Alejandro Vázquez
	-- Objetivo: Se asigna fecha al campo f_unico_reg para que todos los usuarios registrados tengan fecha inicial
	-- Fecha: 23/11/2011

	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE registros INT;
    DEFINE numCte CHAR(9);
    DEFINE idStatus CHAR(4);
    DEFINE fRegistro DATETIME YEAR TO SECOND;
    DEFINE fMvto DATETIME YEAR TO SECOND;
    DEFINE fUnicoReg DATETIME YEAR TO SECOND;


	LET cCod_ret = '00000';
	LET registros = 0;

    LET numCte = '';
    LET idStatus = '';


	--SET DEBUG FILE TO "sp_asigna_fecha_unica_aw.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, registros;
		  END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT numcte,id_status,f_registro, fecha_movto, f_unico_reg 
            INTO numCte, idStatus, fRegistro, fMvto, fUnicoReg
            FROM bdinteg:si_bpiusuarios
            WHERE --numcte <> '' 
				id_status NOT IN ('0','99') 				
				AND ( year(f_registro) >= 2009 )
				AND (f_unico_reg is null or year(f_unico_reg) = 1900)				
			ORDER BY f_registro
			
            LET registros =  registros + 1;
				IF NVL(extend(fMvto, year to day),'1900-01-01') = '1900-01-01' THEN
					UPDATE bdinteg:si_bpiusuarios SET fecha_movto = fRegistro, f_unico_reg = fRegistro
					WHERE empresa='001' AND numcte = numCte AND id_status=idStatus AND f_registro=fRegistro;
				ELSE 
				   UPDATE bdinteg:si_bpiusuarios SET f_unico_reg = fMvto
				   WHERE empresa='001' AND numcte = numCte AND id_status=idStatus AND f_registro=fRegistro;
				END IF;
			
		END FOREACH;
        
		RETURN cCod_ret, registros;
		
	END;
END PROCEDURE;
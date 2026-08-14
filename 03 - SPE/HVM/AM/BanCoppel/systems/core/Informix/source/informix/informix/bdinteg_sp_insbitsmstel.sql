CREATE PROCEDURE "informix".sp_insbitsmstel(pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5), 
                                pdigito_ver CHAR(4), ptelefono CHAR(10), pteclea_ejecut CHAR(100), pbandera boolean)
RETURNING char(5) as codret 
DEFINE iSqlErr			INTEGER;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
        
        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, bandera, fecha) 
               VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pteclea_ejecut, pbandera, current);

		RETURN '00000';
	END
END PROCEDURE;
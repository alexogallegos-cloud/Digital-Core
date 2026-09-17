create procedure "informix".sp_genarchivoboletossort2009 (psNumEmpleado CHAR(8),pdcve_sorteo char (5), pdFechaBusqueda DATE,pdrepositorio CHAR(100))

RETURNING CHAR(5) AS CodRetorno;

	-- Realizo   :Alejandro Osuna
	--Solicito : Hector Casanova
	-- Proyecto :  Sorteo
	-- Actividad : Manda llamar los sp secundarios
	-- Fecha     :25 de  Novimebre  de 2009
	DEFINE visqlerr INTEGER;
	DEFINE vsCodRetorno CHAR (5);
	DEFINE vscodret CHAR(5);
	DEFINE vsCve_Sorteo CHAR (5);
	DEFINE vsMensajeRetorno CHAR (100);
	
	LET vsCodRetorno = '';
	LET vscodret = '';
	LET vsCve_Sorteo = '';
	LET vsMensajeRetorno = '';


	--SET DEBUG FILE TO "/tmp/sp_genarchivoboletossort2009.out";
	--TRACE ON;


	BEGIN
		ON EXCEPTION SET visqlerr --Control de errores.
			LET vsCodRetorno =  visqlerr ;
			RETURN vsCodRetorno;
		END EXCEPTION;
		
		IF (psNumEmpleado = '') or (psNumEmpleado is null) THEN
			LET vsCodRetorno =  '10001' ;
			RETURN vsCodRetorno;
		END IF;		
		IF (pdcve_sorteo = '') or (pdcve_sorteo is null) THEN
			LET vsCodRetorno =  '10002' ;
			RETURN vsCodRetorno;
		END IF;
		IF (pdFechaBusqueda is null) THEN
			LET vsCodRetorno =  '10003' ;
			RETURN vsCodRetorno;
		END IF;
		IF (pdrepositorio = '') or (pdrepositorio is null) THEN
			LET vsCodRetorno =  '10004' ;
			RETURN vsCodRetorno;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:sp_st_genarchbolparticipantes (psNumEmpleado,pdFechaBusqueda ) INTO vscodret, vsCve_Sorteo,vsMensajeRetorno;
		
		IF vscodret <> '00000' THEN
			LET vsCodRetorno =  vscodret ;
			RETURN vsCodRetorno;
		ELSE
			EXECUTE PROCEDURE bdinteg:sp_genarchivorepor(psNumEmpleado,pdcve_sorteo,pdFechaBusqueda,pdrepositorio ) INTO vscodret, vsCve_Sorteo,vsMensajeRetorno;
			IF vscodret <> '00000' THEN
				LET vsCodRetorno =  vscodret ;
				RETURN vsCodRetorno;
			END IF;			
		END IF;
		LET vsCodRetorno =  '00000' ;
		RETURN vsCodRetorno;
	END;
END PROCEDURE;
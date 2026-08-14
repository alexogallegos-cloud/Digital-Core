CREATE PROCEDURE "informix".sp_obten_referencia23_cheques(p_folioSuc CHAR(30), p_archivoInternacional CHAR(30), p_archivoNacional CHAR(30), p_empresa CHAR(3))
     RETURNING	CHAR(23) AS referencia23;

	--definicion de variables--	    
	DEFINE resultado_referencia23   	CHAR(23);
    DEFINE iSqlErr                   	INTEGER;
	DEFINE nacional				 		CHAR(30);
	DEFINE internacional		 		CHAR(30);
	DEFINE archivoTCD					CHAR(30);
	DEFINE archiTCD						CHAR(30);
		
	DEFINE cp_archivoNacional			CHAR(30);
    DEFINE fechai				     	CHAR(8);
	DEFINE fechan				     	CHAR(8);
     -- Inicialización de variables.
	LET resultado_referencia23  = '';
	LET fechai = '';
	LET fechan = '';
	LET nacional='';
	LET internacional='';
	LET	archivoTCD ='';
	LET archiTCD='';


	--SET DEBUG FILE TO "/informix/sp_obtenReferencia23.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_referencia23  = '';
                    RETURN resultado_referencia23;
                END IF;
        END EXCEPTION;

/*		Se modifica el formato de escritura de la fecha para realizar la busqueda en las tablas bditarjeta:td_movimientos_conciliacion y bditarjeta:td_movimientos_conciliacion_his de m%d%Y a d%m%Y|
 * 		INC  Sin referencia 23 en movimientos ingresados el mismo día en el cual se hace el cargo
		LET fechai =substring (p_archivoInternacional from 7 for 2)||substring (p_archivoInternacional from 5 for 2)||substring (p_archivoInternacional from 9 for 4);
		LET fechan =substring (p_archivoNacional from 7 for 2)||substring (p_archivoNacional from 5 for 2)||substring (p_archivoNacional from 9 for 4);*/
		LET fechai =substring (p_archivoInternacional from 5 for 2)||substring (p_archivoInternacional from 7 for 2)||substring (p_archivoInternacional from 9 for 4);
		LET fechan =substring (p_archivoNacional from 5 for 2)||substring (p_archivoNacional from 7 for 2)||substring (p_archivoNacional from 9 for 4);

		
		LET internacional ='BCPLVID_'||fechai||'.txt';
		LET nacional ='BCPLVND_'||fechan||'.txt';
		LET archivoTCD='BCPLTCD_'||fechan||'.txt';
		LET archiTCD ='TCD'||substring(p_archivoNacional from 4 for 9);
--		let pFolioSuc = p_folioSuc;
	 
		---Se añade la busqueda de referencia_23 sobre el la tabla bdicheq:sc_movdia | INC  Sin referencia 23 en movimientos ingresados el mismo día en el cual se hace el cargo
		SELECT limit 1 referencia_23
		INTO resultado_referencia23
	    FROM bdicheq:sc_movdia
        WHERE empresa=p_empresa
        AND folio_suc = p_folioSuc
		AND referencia_23 <>'';
		--- FIN Modificación
	
		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
		SELECT limit 1 referencia_23
		INTO resultado_referencia23
	    FROM bdicheq:sc_movhis
        WHERE empresa=p_empresa
		AND fech_alt>=today-90
        AND folio_suc = p_folioSuc
		AND referencia_23 <>'';
		END IF;
	
		
		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
		SELECT limit 1 referencia_23
		INTO resultado_referencia23
	    FROM bdicheq:sc_movhis_old
        WHERE empresa=p_empresa
		AND fech_alt>=today-90
        AND folio_suc = p_folioSuc
		AND referencia_23 <>'';
		END IF;
				
		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
			SELECT referencia23_325
	        INTO resultado_referencia23
	        FROM bditarjeta:td_movimientos_conciliacion 
            WHERE nombrearchivo = nacional
            AND folio_mov = p_folioSuc;
		END IF;
			
		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN			
			SELECT referencia23_325
	        INTO resultado_referencia23
	        FROM bditarjeta:td_movimientos_conciliacion 
            WHERE nombrearchivo = internacional
            AND folio_mov = p_folioSuc;
		 END IF;
		 
		 if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN			
			SELECT referencia23_325
	        INTO resultado_referencia23
	        FROM bditarjeta:td_movimientos_conciliacion 
            WHERE nombrearchivo = archivoTCD
            AND folio_mov = p_folioSuc;
		 END IF;

        if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
            SELECT referencia23_325
            INTO resultado_referencia23
            FROM bditarjeta:td_movimientos_conciliacion_his 
            WHERE nombrearchivo = nacional
            AND folio_mov = p_folioSuc;
        END IF;
	
		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
            SELECT referencia23_325
            INTO resultado_referencia23
            FROM bditarjeta:td_movimientos_conciliacion_his
            WHERE nombrearchivo = internacional
            AND folio_mov = p_folioSuc;
        END IF;
		
		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
            SELECT referencia23_325
            INTO resultado_referencia23
            FROM bditarjeta:td_movimientos_conciliacion_his
            WHERE nombrearchivo = archivoTCD
            AND folio_mov = p_folioSuc;
        END IF;
		
		
		if (resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
			SELECT referencia23
	        INTO resultado_referencia23
	        FROM bditarjeta:td_conposvnd 
            WHERE empresa = p_empresa
            AND archivo = p_archivoNacional
            AND folio_mov = p_folioSuc;
		END IF;	
		
		if (resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
			SELECT referencia23
	        INTO resultado_referencia23
	        FROM bditarjeta:td_conposvnd 
            WHERE empresa = p_empresa
            AND archivo = archiTCD
            AND folio_mov = p_folioSuc;
		END IF;	

		if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
            SELECT referencia23
            INTO resultado_referencia23
            FROM bditarjeta:td_conposvid 
            WHERE empresa = p_empresa
            AND archivo = p_archivoInternacional
            AND folio_mov = p_folioSuc;
        END IF;
		
				if(resultado_referencia23 IS NULL OR resultado_referencia23 == '') THEN
            SELECT referencia23
            INTO resultado_referencia23
            FROM bditarjeta:td_conposvid 
            WHERE empresa = p_empresa
            AND archivo = archiTCD
            AND folio_mov = p_folioSuc;
        END IF;
		
		

	RETURN resultado_referencia23;
	END 
END PROCEDURE;
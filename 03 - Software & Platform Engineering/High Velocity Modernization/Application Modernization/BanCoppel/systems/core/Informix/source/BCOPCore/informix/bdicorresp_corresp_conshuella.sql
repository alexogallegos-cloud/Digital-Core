CREATE PROCEDURE "informix".corresp_conshuella
(
pempresa	CHAR(3), -- TIPO DE EMPRESA
pc_costos	CHAR(4), -- CODIGO DE LA SUCURSAL 
pusuario	CHAR(8), -- NUMERO DE EJECUTIVO 
pnumtarjeta	CHAR(16), -- NUMERO DE TARJETA
pnumcuenta	CHAR(20) -- NUMERO DE LA CUENTA
)
RETURNING 
	CHAR(3),	-- CODIGO DE RETORNO
	CHAR(942),	-- MAPA DERECHO
	CHAR(942);  -- MAPA IZQUIERDO
    
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcodret1         CHAR(3);
    DEFINE vcodret2         CHAR(5);
	DEFINE vtransaccion     SMALLINT;
	DEFINE cMapaDer         CHAR(942);
	DEFINE cMapaIzq         CHAR(942);
	DEFINE cNumCte			CHAR(20);
    
    
    LET sql_err  = 0;
    LET isam_err = 0;
    LET vcodret1 = '000';
    LET vcodret2 = '000';
	LET vtransaccion    = 0;
	LET cMapaDer = "";
	LET cMapaIzq = "";
	LET cNumCte	 = "";
    

    
     --SET DEBUG FILE TO "/informix/moha/corresp_conshuella.out";
    --SET DEBUG FILE TO "/tmp/corresp_conshuella.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_conshuella.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN vcodret1, cMapaDer, cMapaIzq;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET pnumtarjeta = TRIM(pnumtarjeta);
    
    IF (pc_costos is null OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
	   (pnumcuenta = "" AND pnumtarjeta = '')  THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
        RETURN vcodret1, cMapaDer, cMapaIzq;
    END IF;
	
	IF pnumtarjeta <> "" THEN    
		-- // OBTIENE EL NUMERO DE CLIENTE PO MEDIO DE LA TARJETA
		FOREACH
			SELECT numcte
			INTO cNumCte
			FROM bdicheq: "informix".sc_tarjeta 
			WHERE num_tarjeta = pnumtarjeta
			AND status_tar = "A"
			UNION
			SELECT numcte 
			FROM bdicred: "informix".sd_tarjeta 
			WHERE num_tarjeta = pnumtarjeta
			AND status_tar = "A"
		END FOREACH
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "100";
			RETURN vcodret1, cMapaDer, cMapaIzq;
		END IF
	ELSE
		-- // OBTIENE EL NUMERO DE CLIENTE POR MEDIO DE LA CUENTA
		SELECT num_cte
		INTO cNumCte
		FROM bdicheq: "informix".sc_maechq 
		WHERE cuenta = pnumcuenta 
		AND status_cta = "1";
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "100";
			RETURN vcodret1, cMapaDer, cMapaIzq;
		END IF
	END IF

	EXECUTE PROCEDURE "informix".sp_conhuella("001", pc_costos, pusuario, cNumCte)
	INTO vcodret1, cMapaDer, cMapaIzq;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
        
    RETURN vcodret1, cMapaDer, cMapaIzq;

    END; 

END PROCEDURE;
CREATE PROCEDURE "informix".sp_tarcop( pNumCte     CHAR(20),  -- NO. CLIENTE
                                              PNumTarcoppel CHAR(20),
											  POption INTEGER )-- TARJETA COPPEL 
RETURNING   CHAR(5) AS cod_error,
            CHAR(20) AS num_tarjeta,
            CHAR (100) AS NOMBRE,
            DECIMAL(12,2) AS monto_solicitado;  -- CODIGO DE RETORNO
    
    DEFINE vcodret1 CHAR(5);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	DEFINE vTarjCop CHAR(20);
    DEFINE cNombre CHAR(100);
    DEFINE mSolicitado DECIMAL(12,2);
 
    
    LET vcodret1 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
	LET vTarjCop = '';
    LET cNombre = '';
    LET mSolicitado = '';
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            RETURN vcodret1, vTarjCop, cNombre, mSolicitado;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_graba_correos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pNumCte is null OR pNumCte = '') OR
       (PNumTarcoppel is null OR PNumTarcoppel = '') THEN
        LET vcodret1 = '00001';
        RETURN vcodret1, vTarjCop, cNombre, mSolicitado;
    END IF;

    SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre
    INTO cNombre
    FROM bdinteg:"informix".si_cliente 
    WHERE numcte = pNumCte;

    SELECT monto_solicitado
    INTO mSolicitado
    FROM bdisolic:"informix".ss_solicitudes
    WHERE numcte = pNumCte
    AND num_producto ='6500';

    IF ( POption = 1) THEN
        DELETE FROM bdinteg:"informix".si_conscoppel WHERE numcte = pNumCte;
		INSERT INTO bdinteg:"informix".si_conscoppel
		(empresa, numcte, numtarcoppel, fechahora)
		VALUES
		('001', pNumCte, PNumTarcoppel, CURRENT);
		
		SELECT numtarcoppel
		INTO vTarjCop
		FROM bdinteg:"informix".si_conscoppel
		WHERE numcte = pNumCte
        AND numtarcoppel = PNumTarcoppel;
		
		IF vTarjCop <> '' THEN
			LET vcodret1 = '00000';
		ELSE 
			LET vcodret1 = '00002';
		END IF;

	ELSE 

		SELECT numtarcoppel
		INTO vTarjCop
		FROM bdinteg:"informix".si_conscoppel
		WHERE numcte = pNumCte
        AND numtarcoppel = PNumTarcoppel;

        IF vTarjCop <> '' THEN
			LET vcodret1 = '00000';
		ELSE 
			LET vcodret1 = '00002';
		END IF;

	END IF;
    
    END; 

    RETURN vcodret1, vTarjCop, cNombre, mSolicitado;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_consultaclienteseindividual(
														  pEmpresa 		CHAR(3),
														  pNumCte 		CHAR(20),
														  pTipoBusqueda INTEGER -- 1.- Cliente, 2.- Cuentas, 3.- Situacion Especial
														  )

	RETURNING CHAR(6), 	-- cod retorno
			  CHAR(20),	-- num_cred
			  CHAR(20),	-- num_tarjeta
			  CHAR(1),	-- SE
			  SMALLINT,	-- Causa
			  CHAR(75),	-- Descripcion
              datetime year to second; -- fechaMod

	--Definicion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;

    DEFINE v_fecha_hoy      datetime year to second;

	DEFINE iEncontrado 		INTEGER;
	DEFINE v_NumCredConslt1	CHAR(20);
	DEFINE v_NumCredConslt2	CHAR(20);
	DEFINE v_NumCred		CHAR(20);
	DEFINE v_NumTarjeta		CHAR(20);
	DEFINE v_SE				CHAR(1);
	DEFINE v_Causa			SMALLINT;
	DEFINE v_Descripcion	CHAR(75);
    DEFINE v_fechaMod       datetime year to second;
    DEFINE v_fechaAlta      datetime year to second;

	--Inicializacion de variables
	LET v_NumCredConslt1	= "";
	LET v_NumCred			= "";
	LET v_NumTarjeta		= "";
	LET v_SE				= "";
	LET v_Causa				= 0;
	LET v_Descripcion		= "";
    LET v_fechaAlta         = "1900-01-01 00:00:00";
    LET v_fechaMod          = "1900-01-01 00:00:00";
	LET iEncontrado			= 0;

	LET v_codret = "000";
	LET v_sqlerr = 0;

	--18-02-2009
	--Realizo:
	--Abraham Ayala
	--Consultar todas las cuentas del cliente ya sea que tengan o no SE y Causa de la consulta individual

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr <> 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, v_fechaMod;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_ConsultaClienteSEIndividual.out';
	--trace on;

		--Seccion de codigo para validar que el SP reciba parametros
		IF pEmpresa IS NULL OR pEmpresa = '' OR pNumCte = '' OR pNumCte IS NULL THEN
			LET v_codret = '999';	--Faltan parametros
			RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, v_fechaMod;
		ELSE
			--Seccion del codigo para la busqueda de SE que marquen al cliente
			IF pTipoBusqueda = 1 THEN
				IF EXISTS (SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte)} situacion FROM bdisitesp:se_ctessitespcte WHERE empresa = pEmpresa AND numcte = pNumCte) THEN
                   SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte)} NVL(a.situacion,''), NVL(a.causa,''), NVL(b.descripcion,''), NVL(a.fchalta,'1900-01-01 00:00:00'), NVL(a.fchmodifica,'1900-01-01 00:00:00')
					         INTO v_SE, v_Causa, v_Descripcion, v_fechaAlta, v_fechaMod
                   FROM bdisitesp:se_ctessitespcte a LEFT JOIN bdisitesp:se_catsitesp b ON (a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
                   WHERE a.empresa = pEmpresa AND a.numcte = pNumCte;

                    IF v_fechaMod = "1900-01-01 00:00:00" THEN
                        RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, v_fechaAlta;
                    ELSE
                        RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, NVL(v_fechaMod, v_fechaAlta);
                    END IF;
				ELSE
                    IF EXISTS (SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte_his)} situacion FROM bdisitesp:se_ctessitespcte_his WHERE empresa = pEmpresa AND numcte = pNumCte) THEN
                        SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte_his)} fchmodifica
                        INTO v_fechaMod
                        FROM bdisitesp:se_ctessitespcte_his
                        WHERE empresa = pEmpresa AND numcte = pNumCte
                        AND idmovto = (SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte_his)} MAX(idmovto) FROM bdisitesp:se_ctessitespcte_his WHERE empresa = pEmpresa AND numcte = pNumCte);

                        RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, NVL(v_fechaMod, v_fechaAlta);
                    ELSE
                        RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, "", 0, "", DATE(1);
                    END IF;
				END IF;
			ELIF pTipoBusqueda = 2 THEN
				--Seccion del codigo para la busqueda de creditos que esten o no marcados con una SE
				FOREACH
					SELECT {+AVOID_FULL(bdicred:"informix".sd_maecred)} a.num_credito, MAX(b.num_tarjeta)
					INTO v_NumCredConslt1, v_NumTarjeta
					FROM bdicred:sd_maecred a, bdicred:sd_tarjeta b
					WHERE a.numcte = pNumCte AND a.empresa = pEmpresa AND a.empresa = b.empresa AND a.numcte = b.numcte AND
						  a.num_credito = b.num_credito GROUP BY 1

                    --LET v_NumCred           = "";
                    --LET v_NumTarjeta        = "";
                    LET v_SE                = "";
                    LET v_Causa             = 0;
                    LET v_Descripcion       = "";
					--Ciclo para verificar si el credito ya esta marcado con una SE
					IF EXISTS(SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcred)} numcred FROM bdisitesp:se_ctessitespcred WHERE empresa = pEmpresa AND numcte = pNumCte AND
							  numcred = v_NumCredConslt1) THEN
						--Obtenemos los datos de la cuenta ya marcada para devolverlos
                        SELECT NVL(a.situacion,''), NVL(a.causa,''), NVL(b.descripcion,''), NVL(a.fchalta,'1900-01-01 00:00:00'), NVL(a.fchmodifica,'1900-01-01 00:00:00')
						            INTO v_SE, v_Causa, v_Descripcion, v_fechaAlta, v_fechaMod
                        FROM bdisitesp:se_ctessitespcred a LEFT JOIN bdisitesp:se_catsitesp b ON (a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
                        WHERE a.empresa = pEmpresa AND a.numcte = pNumCte AND a.numcred = v_NumCredConslt1;

                        IF v_fechaMod = "1900-01-01 00:00:00" THEN
                            RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, v_fechaAlta WITH RESUME;
                        ELSE
                            RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, NVL(v_fechaMod, v_fechaAlta) WITH RESUME;
                        END IF;
					ELSE
                        IF EXISTS (SELECT {+AVOID_FULL(bdisitesp:se_ctessitespcred_his)} numcred FROM bdisitesp:se_ctessitespcred_his WHERE empresa = pEmpresa AND numcte = pNumCte AND
                              numcred = v_NumCredConslt1) THEN
                            SELECT {+AVOID_FULL(bdisitesp:se_ctessitespcred_his)} fchmodifica
                            INTO v_fechaMod
                            FROM bdisitesp:se_ctessitespcred_his
                            WHERE empresa = pEmpresa AND numcte = pNumCte AND numcred = v_NumCredConslt1
                            AND idmovto = (SELECT {+AVOID_FULL(bdisitesp:se_ctessitespcred_his)} MAX(idmovto) FROM bdisitesp:se_ctessitespcred_his WHERE empresa = pEmpresa AND numcte = pNumCte AND numcred = v_NumCredConslt1);

                            RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, NVL(v_fechaMod, v_fechaAlta) WITH RESUME;
                        ELSE
                            RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, " ", 0, " ", DATE(1) WITH RESUME;
                        END IF;
					END IF;
				END FOREACH;
				
			ELIF pTipoBusqueda = 3 THEN
			
				SELECT {+AVOID_FULL(bdisitesp:"informix"se_ctessitespcte)} NVL(a.situacion,''), NVL(a.causa,''), NVL(b.descripcion,'')
				  INTO v_SE, v_Causa, v_Descripcion
                FROM bdisitesp:"informix".se_ctessitespcte a LEFT JOIN bdisitesp:"informix".se_catsitesp b ON (a.empresa = b.empresa AND a.situacion = b.situacion AND a.causa = b.causa)
                  WHERE a.empresa = pEmpresa AND a.numcte = pNumCte;

				RETURN v_codret, v_NumCredConslt1, v_NumTarjeta, v_SE, v_Causa, v_Descripcion, v_fechaAlta;	
				
			END IF
		END IF;
	END;
END PROCEDURE;
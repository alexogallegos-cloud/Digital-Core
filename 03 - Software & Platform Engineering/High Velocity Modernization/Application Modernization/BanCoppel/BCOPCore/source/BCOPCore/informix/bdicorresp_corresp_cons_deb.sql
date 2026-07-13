CREATE PROCEDURE "informix".corresp_cons_deb
(
pc_costos CHAR(4),      --- SUCURSAL
pusuario CHAR(8),       --- USUARIO
pfolio CHAR(16),        --- FOLIO SUC
pcuenta CHAR(20),       --- CUENTA
pnum_tarjeta CHAR(16),  --- TARJETA
pfecha CHAR(8),            --- FECHA
preferencia CHAR(40)    --- REFERENCIA
)
RETURNING 
	CHAR(3),   		--- CODIGO DE RETORNO
	CHAR(4),   		--- TERMINACION TARJETA/CUENTA
	CHAR(53),  		--- NOMBRE CORTO DEL CLIENTE
	CHAR(16);  --- SALDO ACTUAL
    
    DEFINE sql_err          INTEGER;
    DEFINE ISam_err         INTEGER;
    DEFINE vcodret1         CHAR(3);
    DEFINE vcodret2         CHAR(5);
	DEFINE vtransaccion     SMALLINT;
	DEFINE vproceso         CHAR(1);
	
	DEFINE cTerminacion		CHAR(4);
	DEFINE cNombreCorto		CHAR(53);
	DEFINE cSdoActual		CHAR(16);
	DEFINE cStatusCta		CHAR(1);
	DEFINE cStatusTar		CHAR(1);
	DEFINE cTranConsSdo		CHAR(4);
	DEFINE cHora            DATETIME HOUR TO FRACTION;
	
	DEFINE cCodRetCS		CHAR(5);
	DEFINE cCuenta			CHAR(20);
	DEFINE cNumCte			CHAR(20);
	DEFINE cApellPat		CHAR(26);
	DEFINE cApellMat		CHAR(26);
	DEFINE cNombre1			CHAR(26);
	DEFINE cNombre2			CHAR(26);
	DEFINE cRazonSoc		CHAR(60);
	DEFINE cEdoCta			CHAR(1);
	DEFINE dSdoDisp			DECIMAL(14,2);
	DEFINE iSdoDisp			INT8;
	DEFINE mSdoRet			MONEY(14,2);
	DEFINE mSdoccc			MONEY(14,2);
	DEFINE dSdoDispccc		MONEY(14,2);
	DEFINE mSdoCta			MONEY(14,2);
	DEFINE cTipoLinea		CHAR(1);
	DEFINE cDescrip1		CHAR(40);
	DEFINE cDescrip2		CHAR(40);
	DEFINE mSdot1			MONEY(14,2);
	DEFINE mSdoCong			MONEY(14,2);
	DEFINE mImpChqSbc		MONEY(14,2);
	DEFINE cUsuBloq			CHAR(8);
	DEFINE dtFecBloq		DATE;
	DEFINE cNumTarjeta		CHAR(16);
	DEFINE cCtaClabe		CHAR(18);
	DEFINE cSucCta			CHAR(4);
	DEFINE dtFechaOperacion DATE;
     
    
    LET sql_err			= 0;
    LET ISam_err		= 0;
    LET vcodret1		= "000";
    LET vcodret2		= "000";
	LET vtransaccion	= 0;
	LET vproceso		= "0";
	
	LET cTerminacion	= "";
	LET cNombreCorto	= "";
	LET cSdoActual		= "";
	LET cStatusCta		= "";
	LET cStatusTar		= "";
	LET cTranConsSdo	= "";
	LET cHora        	= CURRENT HOUR TO FRACTION;
	
	LET cCodRetCS		= "000";
	LET cCuenta			= "";
	LET cNumCte			= "";
	LET cApellPat		= "";
	LET cApellMat		= "";
	LET cNombre1		= "";
	LET cNombre2		= "";
	LET cRazonSoc		= "";
	LET cEdoCta			= "";
	LET dSdoDisp		= 0.0;
	LET iSdoDisp		= 0;
	LET mSdoRet			= 0.0;
	LET mSdoccc			= 0.0;
	LET dSdoDispccc		= 0.0;
	LET mSdoCta			= 0.0;
	LET cTipoLinea		= "";
	LET cDescrip1		= "";
	LET cDescrip2		= "";
	LET mSdot1			= 0.0;
	LET mSdoCong		= 0.0;
	LET mImpChqSbc		= 0.0;
	LET cUsuBloq		= "";
	LET dtFecBloq		= DATE(1);
	LET cNumTarjeta		= "";
	LET cCtaClabe		= "";
	LET cSucCta			= "";
	LET dtFechaOperacion = TODAY;

    
    --SET DEBUG FILE TO "/informix/moha/corresp_cons_deb.out";
    --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, ISam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/corresp_cons_deb.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = ISam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            IF vproceso = '1' THEN
                LET vcodret1 = '000';
            ELSE
                LET vcodret1 = '999';
            END IF;
            RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
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
	
	-- OBTIENE LA TRANSACCION CORRESPONDIENTE A LA CONSULTA
	SELECT TRIM(valor)
	INTO cTranConsSdo
	FROM bdicheq: "informix".sc_param
	WHERE empresa = "001"
	AND codparam = "conssdobancefec";
    
	-- VALIDA LOS PARAMETROS DE ENTRADA
    IF (pc_costos IS NULL OR pc_costos = '' OR LENGTH(pc_costos) <> 4) OR
       (pusuario IS NULL OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio IS NULL OR pfolio = '' OR LENGTH(pfolio) <> 16) OR
	   (pcuenta IS NULL) OR
	   (pnum_tarjeta IS NULL) OR
	   (pcuenta = "" AND pnum_tarjeta = "" ) OR
       (pfecha IS NULL OR pfecha = '') OR
	   (preferencia IS NULL OR preferencia = "") THEN
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcodret1 = '110';
		RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
    END IF;
	
    ---RSV
	IF SUBSTR (pcuenta, 1, 2) = '11' THEN
	        IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = "100"; 
			RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
    END IF;
	---RSV
    
    -- // OBTIENE DATOS DE LA CUENTA DE CHEQUES
    IF pcuenta IS NULL OR pcuenta = '' THEN
		SELECT cuenta, status_tar
		INTO pcuenta, cStatusTar
		FROM bdicheq:"informix".sc_tarjeta
		WHERE empresa = "001"
		AND num_tarjeta = pnum_tarjeta;
		   
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "100";
			RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
		END IF
           
        IF cStatusTar <> 'A' THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = "009";
			RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
        END IF;
		
		LET cTerminacion = SUBSTR(pnum_tarjeta,13,4);
    END IF;
	
	-- // OBTIENE DATOS DE LA TARJETA DE CHEQUES
    IF pnum_tarjeta IS NULL OR pnum_tarjeta = '' THEN
		SELECT status_cta
		INTO cStatusCta
		FROM bdicheq:"informix".sc_maechq 
		WHERE empresa = '001' 
		AND cuenta = pcuenta;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			IF vtransaccion = 1 THEN
				ROLLBACK WORK;
				BEGIN WORK;
			ELSE
				ROLLBACK WORK;
			END IF;
			LET vcodret1 = "100";
			RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
		END IF
		
		IF cStatusCta NOT IN ('1','4','5') THEN
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcodret1 = "009";
			RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;
        END IF;
	
		SELECT num_tarjeta
		INTO pnum_tarjeta
		FROM bdicheq:"informix".sc_tarjeta
		WHERE empresa = '001'
		AND cuenta = pcuenta
		AND secuencia = (SELECT max(secuencia)
						FROM bdicheq:"informix".sc_tarjeta
						WHERE empresa = '001'
						AND cuenta = pcuenta)
		AND status_tar = 'A';
		   
        IF pnum_tarjeta IS NULL THEN
            LET pnum_tarjeta = '';
        END IF;
		
		LET cTerminacion = SUBSTR(pcuenta,8,4);
    END IF;

	
	--// OBTIENE LA SUCURSAL DE LA CUENTA
	SELECT sucursal
	INTO cSucCta
	FROM bdicheq:"informix".sc_maechq 
	WHERE empresa = '001' 
	AND cuenta = pcuenta;
	
	-- MANDA A EJECUTAR LA CONSULTA DE SALDOS DE DEBITO
	EXECUTE PROCEDURE bdicheq: "informix".cons_sdos1("001",pcuenta,"")
	INTO cCodRetCS,cCuenta,cNumCte,cApellPat,cApellMat,cNombre1,cNombre2,cRazonSoc,cEdoCta,dSdoDisp,mSdoRet,mSdoccc,dSdoDispccc,mSdoCta,
		cTipoLinea,cDescrip1,cDescrip2,mSdot1,mSdoCong,mImpChqSbc,cUsuBloq,dtFecBloq,cNumTarjeta,cCtaClabe;
	IF cCodRetCS::INTEGER <> 0 THEN
		IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
		LET vcodret1 = "999";
	ELSE
		LET cNombreCorto = TRIM(cNombre1) || " " || TRIM(cApellPat);
		--LET iSdoDisp = TRUNC(dSdoDisp);
		LET cSdoActual = REPLACE(dSdoDisp,".","");
		-- INSERTA EL REGISTRO DE LA CONSULTA
		INSERT INTO bdicheq: "informix".sc_movdia (num_serial, folio_suc, sucursal, usuario, fech_alt, fech_val, fech_hor, transacc, suc_cuen, producto, empresa, cuenta, causa_dev, num_cheq, monto_tot, firme, en_sbc, remesas, dias_ret, cancelad, edo_cta, sdo_cuenta, transacc_suc, referencia, tasa_aplicada, num_tarjeta, usuautoriza, referencia_23, fech_oper)
		VALUES(0, pfolio, pc_costos, pusuario, pfecha, pfecha, cHora, cTranConsSdo, cSucCta, SUBSTR(cDescrip1,1,4), "001", pcuenta, " ", 0, 0, 0, 0, 0, 0, "", "", mSdoCta, "", preferencia, 0, pnum_tarjeta, "", "", dtFechaOperacion);
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			COMMIT WORK;
		END IF;
	END IF
	
    RETURN vcodret1, cTerminacion, cNombreCorto, cSdoActual;

    END; 

END PROCEDURE;
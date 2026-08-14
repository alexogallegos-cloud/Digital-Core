CREATE PROCEDURE "informix".sp_validarbintarjetacopia(p_NumTarjeta CHAR(16))

	RETURNING
	CHAR(5) AS COD_RET,
    CHAR(6) AS BINS,
    CHAR(2) AS ID,
    CHAR(1) AS TIPTARJ,
	CHAR(25)	AS BANCO,
    CHAR(3) AS CLAVE;

	---DECLARACIONES
	DEFINE v_cod_ret   CHAR(5);
	DEFINE v_cod_ret2  CHAR(5);
	DEFINE iSqlErr     INTEGER;
	DEFINE iSamErr     INTEGER;
    
	DEFINE cBIN        CHAR(6);
    DEFINE cIdBco      CHAR(2);
    DEFINE cCredDeb    CHAR(1);
	DEFINE cBanco	   CHAR(25);
	DEFINE cCveBanco   CHAR(3);
    

	---INICIALIZACIONES
	LET v_cod_ret	= "00000";
	LET v_cod_ret2	= "00000";
    
	LET cBIN		= "";
    LET cIdBco      = "";
    LET cCredDeb    = "";
	LET cBanco		= "";
	LET cCveBanco	= "";

	--SET DEBUG FILE TO "/tmp/hass/sp_ValidarBINDeTarjetas.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
			END IF;
			RETURN v_cod_ret, cBIN, cIdBco, cCredDeb, cBanco, cCveBanco;
		END EXCEPTION;

		-- Valida que el numero no sea vacio o nulo
		IF (p_NumTarjeta IS NULL OR p_NumTarjeta = '') THEN
			LET v_cod_ret = "00055";
			RETURN v_cod_ret, cBIN, cIdBco, cCredDeb, cBanco, cCveBanco;
		END IF
        
        -- Verifica que el numero de tarjeta sea American Express
        IF LENGTH (p_NumTarjeta) = 15 THEN
            LET cBIN = SUBSTR(p_NumTarjeta,1,2);
            SELECT cod_param, valor INTO cBIN, cBanco FROM bdisac:sac_param WHERE cod_param = cBIN;
            IF NVL(cBanco, "") <> ""  AND NVL(cBIN, 0) = 37 THEN
                SELECT valor INTO cCveBanco FROM bdisac:sac_param WHERE cod_param = 38;
                LET cIdBco    = "";
                LET cCredDeb  = "c";
            ELSE
                LET v_cod_ret = "00055";
                LET cBanco = "Bin de la tarjeta invalido";
            END IF;
        ELSE
            -- Obtiene el BIN de los primeros 6 degitos del numero de tarjeta
            LET cBIN = SUBSTR(p_NumTarjeta,1,6);

            -- Obtiene clave y banco al que pertenece el BIN
            SELECT {INDEX (bdicheq:sc_bines i_bin_cd)} bin, id_bco, creditodebito, banco_prosa, cve_banco
            INTO cBIN, cIdBco, cCredDeb, cBanco, cCveBanco
            FROM bdicheq:sc_bines
            WHERE bin = cBIN and LOWER(creditodebito) = 'c';
            
            -- Valida que se halla obtenido la clave del banco y la descripcion
            IF NVL(cCveBanco, "") = "" OR NVL(cBanco, "") = "" Then
                LET v_cod_ret = "00055";
                LET cBanco = "Bin de la tarjeta invalido";
                RETURN v_cod_ret, cBIN, cIdBco, cCredDeb, cBanco, cCveBanco;
            END IF

            -- Valida que la tarjeta no sea Bancoppel
            IF TRIM(cCveBanco) = "137" THEN
                LET v_cod_ret = "00056";
                LET cBanco = "La tarjeta no puede ser Bancoppel";
                RETURN v_cod_ret, cBIN, cIdBco, cCredDeb, cBanco, cCveBanco;
            END IF
            
        END IF;
		RETURN v_cod_ret, cBIN, cIdBco, cCredDeb, cBanco, cCveBanco;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Adrian Lara',
'DESCRIPCION: Procedimiento que valida el bin de la tarjeta y obtiene la clave del banco.',
'FECHA: Septiembre 2010',
'VERSION: 20100930.1105';

CREATE PROCEDURE "informix".corrige_prov_31012011(pempresa CHAR(3))
    
    RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql             CHAR(200);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    
    LET vcodret	     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador    = -1;
    LET ven_transacc = 0;
    
    LET vsql         = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_prov_31012011.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcontador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_prov_31012011.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ctasxcorregir') THEN
        DROP TABLE "informix".ctasxcorregir;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcorregir
      (
        cuenta      char(20)    not null,
        monto       money(14,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxcorr ON "informix".ctasxcorregir(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ints_31012011.unl INSERT INTO ctasxcorregir" > /resplogifx/conciliachq/ctasxcorreg.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxcorreg.sql';
    --- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctasxcorreg.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcorregir;
    
    FOREACH WITH HOLD
        SELECT cuenta, monto
          INTO vcuenta, vmonto
          FROM ctasxcorregir
        
        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET ven_transacc = 1;
        END IF;
        
        UPDATE sc_sdodiarioc
           SET intprovnp31 = vmonto
         WHERE cuenta = vcuenta
           AND aniomes = '201101';
        
        LET vcontador = vcontador + 1;
        
        LET vcuenta = '';
        LET vmonto  = 0.00;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret, vcodret2, vcontador;

END PROCEDURE;
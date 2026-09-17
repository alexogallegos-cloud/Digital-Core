CREATE PROCEDURE "informix".sp_actualiza_instruccionvencimiento( pEmpresa CHAR(3), 
                                                                 pNumCta CHAR(20), 
                                                                 pCodInstrucc CHAR(2), 
                                                                 pFecha DATE )
RETURNING CHAR(5); 

    -------------------------------------------------------------------------------
    -- DOCUMENTACION
    -- Se agrega validacion para no permitir el cambio de instruccion en cuentas ligadas 1500 y 2500
    -- Modifico: Julian Alfonso Reyna Camargo
    -- Fecha: 08/04/2024                    
    -------------------------------------------------------------------------------

    -- // DEFINICION DE VARIABLES // 
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);	
    ---------------------------	
    DEFINE FechaIni DATE;
    DEFINE FechaVen DATE;
    DEFINE siUltimoDia SMALLINT;
	DEFINE pctacap CHAR(20);
	DEFINE vproducto CHAR(4);

    -- // INICIALIZACION DE VARIABLES // 
    LET iSqlErr = 0;
    LET cCodRet = '00000';
    LET FechaIni = '';
    LET FechaVen = '';
    LET siUltimoDia = 0;
	LET pctacap = ''; --Variable para Cuenta Ligada
	LET vproducto = ''; --Variable para Producto Ligado

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_instruccionvencimiento.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN -- // INICIO DEL PROCEDIMIENTO // 
    
    ON EXCEPTION SET iSqlErr -- // MANEJADOR DE ERRORES // 
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;	

    -- // Se valida que los parámetros de entrada no vengan vacíos // 
    IF pEmpresa IS NULL OR pEmpresa = '' OR pNumCta IS NULL OR pNumCta = '' OR pCodInstrucc IS NULL OR pCodInstrucc = '' OR pFecha IS NULL OR pFecha = '' THEN
        LET cCodRet = "102"; -- // Parámetro de entrada vacío // 
    ELSE
        -- // Se obtiene la Fecha de inicio del periodo y la fecha fin del periodo(vencimiento) // 
        SELECT a.inicio_periodo, a.fin_periodo
        INTO FechaIni, FechaVen
        FROM bdicheq:"informix".sc_tasa_variable a,
             bdicheq:"informix".sc_maechq b
        WHERE a.empresa = pEmpresa
        AND a.cuenta = pNumCta
        AND a.fin_periodo = (SELECT MAX(fin_periodo) 
                             FROM bdicheq:"informix".sc_tasa_variable 
                             WHERE empresa = pEmpresa
                             AND cuenta = pNumCta 
                             AND tipo_tasa = 'M') 		 
        AND a.tipo_tasa = 'M'
        AND b.empresa = a.empresa
        AND b.cuenta = a.cuenta
        AND b.status_cta NOT IN('2','6','7');
		--//INICIO Validacion para no permitir el cambio de instruccion en cuentas ligadas 1500 y 2500
		IF pCodInstrucc <> '02' THEN
			SELECT cuentadep
			INTO pctacap
			FROM sc_maeinstrucc
			WHERE cuenta = pNumCta;
			
			IF pctacap IS NULL THEN
				let cCodRet = "102";
				return cCodRet;
			END IF;
			
			SELECT producto
			into vproducto
			FROM bdicheq:sc_maechq
			WHERE empresa = pEmpresa
			AND cuenta = pctacap;
			
			IF vproducto IS NULL THEN
				let cCodRet = "103";
				return cCodRet;
			END IF;
			
			IF vproducto = "1500" THEN
				let cCodRet = "104";
				return cCodRet;
			END IF;
			
			IF pctacap = "2500" THEN
				let cCodRet = "104";
				return cCodRet;
			END IF;
		END IF;
		--//FIN Validacion para no permitir el cambio de instruccion en cuentas ligadas 1500 y 2500   
        -- // Se valida que se hayan obtenido fecha inicio y fecha fin del periodo // 
        IF FechaIni IS NULL OR FechaIni = '' OR FechaVen IS NULL OR FechaVen = '' THEN
            LET cCodRet = "100"; -- // No se encontró información // 
        ELSE
            -- // Se valida que la fecha sea mayor a la Fecha Inicio del Periodo y menor a la fecha de Vencimiento // 
            IF pFecha > FechaIni AND pFecha < FechaVen THEN
                -- // Se actualiza la Instruccion de Vencimiento mediante el numero de cuenta // 
                UPDATE bdicheq:"informix".sc_maeinstrucc
                   SET instrucc = pCodInstrucc
                 WHERE empresa = pEmpresa
                   AND cuenta = pNumCta;
            ELSE
                LET cCodRet = "101"; -- // La fecha no esta dentro del rango de Periodos // 
            END IF;
        END IF;
    END IF;

    RETURN cCodRet;			 	 

    END
    
END PROCEDURE;
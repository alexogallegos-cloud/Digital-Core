CREATE PROCEDURE "informix".sp_consulta_instruccinversioncreciente(pNumCta CHAR(20), pEmpresa CHAR(3))
-- // DATOS A REGRESAR // 
RETURNING CHAR(5),      -- Código de Retorno
          CHAR(104),    -- Nombre del cliente
          CHAR(20),     -- Tipo de persona
          CHAR(40),     -- Producto
          MONEY(14,2),  -- Capital
          DECIMAL(9,6), -- Taza Bruta Meta
          DATE,         -- Fecha de Apertura
          DATE,         -- Fecha Vencimiento
          CHAR(20),     -- Cuenta Referencia
          CHAR(45),     -- Promotor
          CHAR(1);      -- Estatus de la cuenta
          
    --------------------------------------------------------------------
    -- DOCUMENTACIÓN
    -- Consulta de Cambio de Instrucciones de Inversión Creciente
    -- (Información que se muestra en la pantalla)
    -- Realizó: Nancy Sevilla Camacho
    -- Fecha: 27/05/2011 
    -- Se agrega consulta de parametro producto inversion creciente
    -- para validar producto de la cuenta.
    -- Modifico: Felipe Urias
    -- Fecha: 23/06/2011                            
    --------------------------------------------------------------------

    -- // DEFINICION DE VARIABLES // 
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);	
    ---------------------------	
    DEFINE cNomCliente    CHAR(104);
    DEFINE cTipoPersona   CHAR(20);
    DEFINE cDescProducto      CHAR(40);
    DEFINE cProducto      CHAR(4);
    DEFINE mCapital       MONEY(14,2);
    DEFINE dTazaBruta     DECIMAL(9,6);
    DEFINE FechaAper      DATE;
    DEFINE FechaVen       DATE;
    DEFINE cCtaReferencia CHAR(20);
    DEFINE cPromotor      CHAR(45);
    DEFINE cEstatusCta    CHAR(1);
    DEFINE cProductoParam 	CHAR (60);

    -- // INICIALIZACION DE VARIABLES // 
    LET iSqlErr        = 0;
    LET cCodRet        = '00000';
    LET cNomCliente    = '';
    LET cTipoPersona   = '';
    LET cDescProducto      = '';
    LET cProducto      = '';
    LET mCapital       = 0;
    LET dTazaBruta     = 0;
    LET FechaAper      = '';
    LET FechaVen       = '';
    LET cCtaReferencia = '';
    LET cPromotor      = '';
    LET cEstatusCta    = '';

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_instruccinversioncreciente.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN -- // INICIO DEL PROCEDIMIENTO //
    
    ON EXCEPTION SET iSqlErr -- // MANEJADOR DE ERRORES //
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNomCliente, cTipoPersona, cDescProducto, mCapital, dTazaBruta, FechaAper, FechaVen, cCtaReferencia, cPromotor, cEstatusCta;   
        END IF;    
    END EXCEPTION;	

    IF pNumCta IS NULL OR pNumCta = '' OR pEmpresa IS NULL OR pEmpresa = '' THEN
        LET cCodRet = "102"; -- // Parámetro de entrada vacío //
    ELSE
        -- // Obtiene el Nombre del Cliente, Tipo de Persona (Fisica, Moral), Estatus de la Cuenta, el Capital y el Producto // 
        SELECT TRIM(b.nombre1) || ' ' || TRIM(b.nombre2) || ' ' || TRIM(b.apell_paterno) || ' ' || TRIM(b.apell_materno),
               c.descripcion, a.status_cta, a.imp_chq_rem, d.nombre, d.producto 
          INTO cNomCliente, cTipoPersona, cEstatusCta, mCapital, cDescProducto, cProducto 
          FROM bdicheq:"informix".sc_maechq a,
               bdinteg:"informix".si_cliente b,
               bdinteg:"informix".si_tipper c,
               bdicheq:"informix".sc_producto d
         WHERE a.cuenta = pNumCta
           AND a.num_cte = b.numcte
           AND a.status_cta NOT IN('2','6','7')
           AND b.tpo_persona = c.tpo_persona
           AND a.producto = d.producto;

        IF cNomCliente IS NULL OR cNomCliente = '' OR cTipoPersona IS NULL OR cTipoPersona = '' OR 
           cEstatusCta IS NULL OR cEstatusCta = '' OR mCapital IS NULL OR mCapital = '' OR 
           cDescProducto IS NULL OR cDescProducto  = '' OR cProducto IS NULL OR cProducto  = '' THEN
            LET cCodRet = "100"; -- // No se encontró información referente a los datos de la cuenta //
        ELSE
            -- // 23/06/2011   consulta de parametro producto inversion creciente // 
            SELECT TRIM(valor)
              INTO cProductoParam
              FROM bdicheq:"informix".sc_param 
             WHERE empresa = pEmpresa 
               AND codparam = 'PRODCREC'; 

            IF cProductoParam IS NULL OR cProductoParam ="" THEN
                LET cCodRet = "101";
            ELSE
                IF cProducto <> cProductoParam THEN
                    LET cCodRet = "104";
                ELSE
                    -- // Se obtiene Promotor, Fecha de Apertura y Fecha de Vencimiento //
                    SELECT a.nombre, b.fecha_alta, b.fecha_mod
                      INTO cPromotor, FechaAper, FechaVen
                      FROM bdinteg:"informix".si_ejecut a,
                           bdicheq:"informix".sc_maenoc b
                     WHERE b.empresa = pEmpresa
                       AND b.cuenta = pNumCta
                       AND b.ejecutivo = a.ejecutivo;

                    IF cPromotor IS NULL OR cPromotor = '' OR FechaAper IS NULL OR FechaAper = '' OR FechaVen IS NULL OR FechaVen = '' THEN
                        LET cCodRet = "101"; -- // No se encontró información //
                    ELSE
                        -- // Se obtiene la Cuenta de Referencia // 
                        SELECT cuentadep
                          INTO cCtaReferencia
                          FROM bdicheq:"informix".sc_maeinstrucc
                         WHERE empresa = pEmpresa
                           AND cuenta = pNumCta;

                        IF cCtaReferencia IS NULL OR cCtaReferencia = '' THEN
                            LET cCodRet = "103"; -- // No se encontró información //
                        ELSE
                            -- // Se obtiene el valor de la Taza Bruta Meta //
                            SELECT valor_tasa
                              INTO dTazaBruta
                              FROM bdicheq:"informix".sc_tasa_variable
                             WHERE empresa = pEmpresa
                               AND cuenta = pNumCta
                               AND tipo_tasa = 'P';

                            IF dTazaBruta IS NULL OR dTazaBruta = '' THEN
                                LET cCodRet = "101"; -- // No se encontró información //
                            END IF;
                        END IF;					
                    END IF;
                END IF;
            END IF;
        END IF;	
    END IF;

    RETURN cCodRet, cNomCliente, cTipoPersona, cDescProducto, mCapital, dTazaBruta, FechaAper, FechaVen, cCtaReferencia, cPromotor, cEstatusCta;

    END;
    
END PROCEDURE;
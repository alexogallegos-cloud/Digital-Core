CREATE PROCEDURE "informix".sp_eliminaadicional(pNumeroCuenta char(26), pNumeroCliente char(26),pTipo smallint)
        
	-- DATOS A REGRESAR

        RETURNING
        char(5);        -- Codigo de retorno

        -- Declaracion de variables

        DEFINE vCodRet          char(5);
        DEFINE vsecuencia       smallint;
        DEFINE vnumcte          char(26);
        DEFINE vContador        smallint;
        DEFINE vtipo            smallint;
        DEFINE vNumerocuenta    char(26);



        -- Se Inicializan las Variables

        LET vCodRet  = "00000";
        LET vsecuencia=0;
        LET vnumcte = "";
        LET vContador = 1;

        --SET DEBUG FILE TO '/tmp/SPEliminaAdicional2.OUT';
        --TRACE ON;

	BEGIN
        IF ptipo=1 THEN -- aDICIONAL DE credito

                 -- Se verifica que exista el número de cuenta
                	IF EXISTS (SELECT numcte
                        FROM bdicred:sd_tarjeta
                        WHERE numcte = pNumeroCliente AND num_credito = pNumeroCuenta
                        AND secuencia = (SELECT MAX(secuencia)
                                        FROM bdicred:sd_tarjeta
                                        WHERE numcte = pNumeroCliente AND tipo_tarjeta='A' AND num_credito = pNumeroCuenta)) THEN
                        SELECT MAX(secuencia)
                                INTO Vsecuencia
                                FROM bdicred:sd_tarjeta
                                WHERE numcte = pNumeroCliente AND num_credito = pNumeroCuenta  AND tipo_tarjeta='A' AND status_tar='A';

                        UPDATE bdicred:sd_tarjeta
                                SET status_tar = 'C'
                        WHERE numcte = pNumeroCliente
                                AND  num_credito = pNumeroCuenta
                                AND secuencia = vsecuencia;

                        LET vCodRet = "00000";
                        RETURN vCodRet ;

        ELSE  --Cliente NO EXISTE

                        LET vCodRet="259";
                        RETURN vCodRet ;

        END IF;
---------------------------------------------------------------------------
        ELSE    --Buscar Datos de DICIONAL DE DEBITO
        let vnumcte = pnumerocliente;
        LET vnumerocuenta = pnumerocuenta;
        let vtipo = ptipo;

                IF EXISTS (SELECT numcte
                        FROM bdicheq:sc_firmantes
                        WHERE numcte = pNumeroCliente
                                AND cuenta = pNumeroCuenta) THEN

                        DELETE FROM bdicheq:sc_firmantes
                                WHERE numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta;

                        IF EXISTS(SELECT secuencia
                                  FROM bdicheq:sc_firmantes
                                  WHERE cuenta = pNumeroCuenta
                                  AND secuencia <>1) THEN

                                UPDATE bdicheq:sc_firmantes SET secuencia = 2
                                WHERE cuenta = pNumeroCuenta
                                AND secuencia <>1;

                        END IF;

                        IF EXISTS (SELECT numcte
                                FROM  bdicheq:sc_tarjeta
                                WHERE  numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta
                                        AND tipo_tarjeta ='A' AND status_tar = 'A') THEN

                                SELECT MAX(secuencia) INTO vSecuencia
                                        FROM bdicheq:sc_tarjeta
                                        WHERE cuenta = pnumerocuenta
                                                AND numcte = pNumeroCliente
                                                AND tipo_tarjeta='A'
                                                AND status_tar = 'A';

                                UPDATE bdicheq:sc_tarjeta
                                    SET status_tar = 'C'
                                    WHERE numcte = pNumeroCliente
                                        AND cuenta = pNumeroCuenta
                                        AND tipo_tarjeta ='A'
                                        AND secuencia = vSecuencia;

                                LET vCodRet = "00000";
                                RETURN vCodRet ;

                        END IF;

                        LET vCodRet = "00000";
                        RETURN vCodRet ;

                ELSE  --Cliente cLIENTE nO EXISTE

                        LET Vcodret = "259";
                        RETURN vCodRet ;

                END IF ;

        END IF;
END;
END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 15/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdicheq,bdicred",
"VER   : 1.1";

CREATE PROCEDURE "informix".compone_interes_cierre(o_empresa CHAR(3))

RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret             CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE s_numcredito         VARCHAR(20);

DEFINE s_amorinteres        DECIMAL(14,2);

DEFINE sql_err              SMALLINT;
DEFINE isam_err             SMALLINT;
DEFINE error_info           CHAR(100);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;

LET s_numcredito = '';

       -- SET DEBUG FILE TO "/pisa/compone_interes_cierre.out";
       -- TRACE ON;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

    BEGIN
       ON EXCEPTION SET sql_err, isam_err, error_info
          SET DEBUG FILE TO "compone_interes_cierr.err";
       --   TRACE sql_err||" * "||isam_err||" * "||error_info;
          LET scod_ret = sql_err;
          RETURN scod_ret;
       END EXCEPTION;

       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

           FOREACH WITH HOLD

                select a.num_credito
                into s_numcredito
                from bdicred:sd_maecred a,
                     bdicred:sd_maesdos b
                where a.empresa = o_empresa
                and a.num_credito = b.num_credito
                and status_cred in  ('BA','AA')
--                and sucursal='0002'
                and
                (
                select count(*) 
                from bdicred:sd_amortiza_credito 
                where empresa = o_empresa
                and a.num_credito = num_credito
                and capital_status = '5' 
                and interes_debe - interes_pagado > 0
                and fecha_cuota< mdy('03','20','2009')) > 0

            
                 BEGIN WORK;

                    UPDATE bdicred:sd_amortiza_credito
                    SET campo_trabajo3=interes_debe-interes_pagado,
                        campo_trabajo4=iva_debe-iva_pagado,
                        interes_pagado=0,
                        iva_pagado=0,
                        interes_debe=0,
                        iva_debe=0
                    where empresa = o_empresa 
                    and num_credito=s_numcredito
                    and capital_status = '5' 
                    and interes_debe - interes_pagado > 0
                    and fecha_cuota< mdy('03','20','2009');


--                    select SUM(interes_debe-interes_pagado)
--                    into s_amorinteres
--                    from bdicred:sd_amortiza_credito 
--                    where empresa = o_empresa 
--                    and num_credito=s_numcredito
--                    and capital_status <> '5';
                    
--                    UPDATE bdicred:sd_maesdos
--                    SET int_tra_no_exig=s_amorinteres
--                    where empresa = o_empresa 
--                    and num_credito=s_numcredito; 

                  COMMIT WORK;


           END FOREACH;

END
	RETURN scod_ret;

END PROCEDURE;
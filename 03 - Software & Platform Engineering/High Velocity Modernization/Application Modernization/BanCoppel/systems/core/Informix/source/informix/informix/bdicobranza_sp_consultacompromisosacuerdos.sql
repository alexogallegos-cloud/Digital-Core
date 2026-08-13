CREATE PROCEDURE "informix".sp_consultacompromisosacuerdos( pEmpresa CHAR(3), pSucursal CHAR(4), pNumCte CHAR(20), pTipo CHAR(1) )
RETURNING CHAR(6), CHAR(20), CHAR(40), CHAR(2), INTEGER, DATE, SMALLINT, SMALLINT, CHAR(1), CHAR(1), CHAR(1), SMALLINT;

--------------------------------------------------------------
--ACTIVIDAD: Consulta la informacion de los convenios activos
--por determinado numero de cliente.
--------------------------------------------------------------

--Definicion de variables
DEFINE chrcodret        CHAR(6);
DEFINE chrnumcredito    CHAR(20);
DEFINE chrplazo         CHAR(2);
DEFINE chrnombreprod    CHAR(40);
DEFINE chrtipo          CHAR(1);
DEFINE chractivo        CHAR(1);
DEFINE chrflagcompac    CHAR(1);

DEFINE intimporte       INTEGER;
DEFINE intcodret        INTEGER;
DEFINE intempcaptura    INTEGER;
DEFINE intefectuo       INTEGER;

DEFINE intflag          SMALLINT;
DEFINE inttotalctas     SMALLINT;
DEFINE inttotalconv     SMALLINT;
DEFINE intorigen        SMALLINT;
DEFINE intdiasplazo     SMALLINT;
DEFINE intdiasfecha     SMALLINT;
DEFINE intactivo        SMALLINT;

DEFINE dtefecha         DATE;

--DEBUG FLAG
--SET debug file to "/pisa/pisabanco/pisa_ftes/cobranza/sp_consultacompromisosacuerdos.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET intcodret
   IF intcodret <> 0 THEN
      LET chrcodret = intcodret;
      RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
             inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen;
   END IF;
END EXCEPTION;

    set isolation to dirty read;
    set lock mode to wait 3;

--Inicializacion de variables
LET chrcodret        = '000';
LET chrnumcredito    = '';
LET chrplazo         = '';
LET chrnombreprod    = '';
LET chrtipo          = '';
LET chractivo        = '';
LET chrflagcompac    = '';
LET intimporte       = 0;
LET intcodret        = 0;
LET intflag          = 0;
LET inttotalctas     = 0;
LET inttotalconv     = 0;
LET intorigen        = 0;
LET intdiasplazo     = 0;
LET intdiasfecha     = 0;
LET intactivo        = 0;
LET dtefecha         = '01-01-1900';

IF EXISTS ( SELECT numcte FROM bdinteg:si_cliente WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

    IF pTipo = '1' THEN
        SELECT count(*) INTO inttotalctas
        FROM bdicred:sd_maecred
        WHERE empresa = pEmpresa AND status_cred <> 'CC' AND numcte = pNumCte;

        IF inttotalctas <> 0 THEN

            SELECT count(*) INTO inttotalconv FROM bdicobranza:cb_compac
            WHERE empresa = pEmpresa AND numcliente = pNumCte;

            FOREACH
                SELECT a.num_credito, b.nombre_prod INTO chrnumcredito, chrnombreprod
                FROM bdicred:sd_maecred a, bdicred:sd_definicion b
                WHERE a.empresa = b.empresa AND a.num_producto = b.num_producto
                AND a.empresa = pEmpresa AND status_cred <> 'CC' AND numcte = pNumCte
                GROUP BY a.num_credito, b.nombre_prod

                SELECT plazo, importe, fecha_compac, tipo_compac, activo, flag_pago, origen
                INTO chrplazo, intimporte, dtefecha, chrtipo, chractivo, chrflagcompac, intorigen
                FROM bdicobranza:cb_compac
                WHERE empresa = pEmpresa AND numcliente = pNumCte AND numcuenta = chrnumcredito;

                LET intactivo = 0;
                LET intdiasplazo = 0;
                LET intdiasfecha = 0;
                IF not chrplazo IS NULL THEN
                    LET intdiasplazo = NVL(chrplazo,0) * 7;
                    LET intdiasfecha = CURRENT::DATE - dtefecha;
                    LET intactivo = intdiasplazo;
                    LET intactivo = intdiasfecha;
                    LET intactivo = intdiasplazo + intdiasfecha;
                    LET intactivo = intdiasfecha;
                    LET intactivo = 0;
                    IF intdiasfecha <= intdiasplazo THEN
                        LET intactivo = 1;
                    END IF;
                END IF;



                IF intactivo = 1 THEN

                    SELECT plazo, importe, fecha_compac, tipo_compac, activo, flag_pago, origen
                    INTO chrplazo, intimporte, dtefecha, chrtipo, chractivo, chrflagcompac, intorigen
                    FROM bdicobranza:cb_compac
                    WHERE empresa = pEmpresa AND numcliente = pNumCte AND numcuenta = chrnumcredito;
                ELSE
                    LET chrplazo = '';
                    LET intimporte = 0;
                    LET dtefecha = '01-01-1900';
                    LET chrtipo = '';
                    LET chractivo = '';
                    LET chrflagcompac = '';
                    LET intorigen = 0;
                END IF;

                RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
                    inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen  WITH RESUME;

            END FOREACH;
        ELSE
            -- Cliente no tiene cuentas de credito
            LET chrcodret = '002';
            RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
                   inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen;
        END IF;

    ELIF pTipo = '2' THEN

        SELECT count(*) INTO inttotalctas
        FROM bdicred:sd_maecred
        WHERE empresa = pEmpresa AND status_cred <> 'CC' AND numcte = pNumCte;

        IF inttotalctas <> 0 THEN
            SELECT count(*) INTO inttotalconv FROM bdicobranza:cb_compac_his
            WHERE empresa = pEmpresa AND numcliente = pNumCte;

            FOREACH
                SELECT a.num_credito, b.nombre_prod INTO chrnumcredito, chrnombreprod
                FROM bdicred:sd_maecred a, bdicred:sd_definicion b
                WHERE a.empresa = b.empresa AND a.num_producto = b.num_producto AND a.empresa = pEmpresa
                AND status_cred <> 'CC' AND numcte = pNumCte
                GROUP BY a.num_credito, b.nombre_prod
                ORDER BY a.num_credito

                LET chrplazo = '';
                LET intimporte = 0;
                LET dtefecha = '01-01-1900';
                LET chrtipo = '';
                LET chractivo = '';
                LET chrflagcompac = '';
                LET intorigen = 0;


                IF EXISTS ( SELECT numcuenta FROM bdicobranza:cb_compac_his WHERE empresa = pEmpresa
                            AND numcliente = pNumCte AND numcuenta = chrnumcredito ) THEN
                    LET intflag = 1;

                    FOREACH
                        SELECT plazo, importe, fecha_compac, tipo_compac, activo, flag_pago, origen
                        INTO chrplazo, intimporte, dtefecha, chrtipo, chractivo, chrflagcompac, intorigen
                        FROM bdicobranza:cb_compac_his
                        WHERE empresa = pEmpresa AND numcliente = pNumCte AND numcuenta = chrnumcredito
                        ORDER BY fecha_compac

                        RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
                            inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen WITH RESUME;

                        LET chrplazo = '';
                        LET intimporte = 0;
                        LET dtefecha = '01-01-1900';
                        LET chrtipo = '';
                        LET chractivo = '';
                        LET chrflagcompac = '';
                        LET intorigen = 0;

                    END FOREACH;

                END IF;

            END FOREACH;

            IF intflag = 0 THEN
                -- Por si el cliente no tiene convenios en ninguno de sus creditos
                LET chrcodret = '003';
                LET chrnumcredito = '';
                LET chrnombreprod = '';
                RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
                    inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen;
            END IF;
        ELSE
            -- Cliente no tiene cuentas de credito
            LET chrcodret = '002';
            RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
                   inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen;
        END IF;
    END IF;
ELSE
    -- No existe numero de cliente
    LET chrcodret = '001';
    RETURN chrcodret, chrnumcredito, chrnombreprod, chrplazo, intimporte, dtefecha,
           inttotalctas, inttotalconv, chrtipo, chractivo, chrflagcompac, intorigen;
END IF;

END;

END PROCEDURE;
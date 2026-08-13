CREATE PROCEDURE "informix".sp_concilia_pago_credito_coppel_atm()
RETURNING CHAR(5);

    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vFechaHoy            DATE;
        DEFINE vFechaAnt                DATE;
    DEFINE vmonto               MONEY(14,2);
    --DEFINE vmonto_com         MONEY(14,2);
    --DEFINE vmonto_iva         MONEY(14,2);
    --DEFINE vcuantos           INTEGER;
    DEFINE vchar4               CHAR(4);
    DEFINE vdate                DATE;
    DEFINE vmoney               MONEY(14,2);
    DEFINE vcodret              char(5);
    DEFINE vIvaBase             DECIMAL(5,3);
    DEFINE vReferencia          CHAR(40);
    DEFINE vmonto_total         MONEY(14,2);
        DEFINE vfechaproc                       DATE;
        DEFINE vproceso                         CHAR(20);

    LET Sql_Err                         = 0;
    LET Isam_Err                        = 0;
    LET Desc_Err                        = '';
    LET vCodRet1                        = '000';
    LET vCodRet2                        = '';
    LET vCodRet3                        = '';
    LET vFechaHoy                       = '';
        LET vFechaAnt                   = '';
    LET vmonto                          = 0;
    --LET vmonto_com                    = 0;
    --LET vmonto_iva                    = 0;
    LET vReferencia                     = 'PAGO CREDITOS COPPEL ATM';
    LET vmonto_total                    = 0;
        LET vproceso                            = "conpagocrecoppelatm";

    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_concilia_pago_credito_coppel_atm.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_concilia_pago_credito_coppel_atm.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    -- // OBTINENE FECHAS DEL SISTEMA
    SELECT fecha_hoy, fecha_ant
      INTO vFechaHoy, vFechaAnt
      FROM sc_fechas
     WHERE empresa = '001';


        -- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
    select fecha
      into vfechaproc
      from sc_contproc
     where empresa = '001'
       and proceso = vproceso;

    if vfechaproc = vFechaHoy then
           let vcodret1 = '000';
       return vcodret1;
    end if;

        LET vFechaAnt = vfechaproc;


    SELECT valor
          INTO vIvaBase
      FROM bdinteg:si_param
     WHERE empresa = '001'
       AND cod_param = 47;

    IF vIvaBase IS NULL THEN
       LET vIvaBase = 0;
    END IF

        SELECT nvl(sum(monto_tot), 0)--, count(*)
          INTO vmonto--, vcuantos
          FROM sc_movdia
         WHERE cuenta = '99000000520'
          AND fech_alt = vFechaHoy
           AND transacc in('0533', '0534')
           AND cancelad <> 'S';

        LET vmonto_total = vmonto;
		
        /*
        LET vmonto_com = vcuantos * 2.49;
        LET vmonto_iva = vmonto_com * vIvaBase;
        LET vmonto_total = vmonto - vmonto_com - vmonto_iva;*/

        /*
        IF vmonto_total > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0535', '0000', '92536921231000', '99000000520', 0, vmonto_total, '01', vReferencia, ' ', ' ')
        INTO vcodret, vchar4, vdate, vmoney, vmoney;

        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0536', '0000', '92536921231000', '12000000017', 0, vmonto_total, vmonto_total, 0, 0, 0, '01', vReferencia, ' ', ' ')
            INTO vcodret;

            IF vcodret = '000' AND vmonto_com > 0 THEN
                                EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0537', '0000', '92536921231000', '99000000520', 0, vmonto_com, '01', vReferencia, ' ', ' ')
                                INTO vcodret, vchar4, vdate, vmoney, vmoney;

                                IF vcodret = '000' AND vmonto_iva > 0 THEN
                                        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0538', '0000', '92536921231000', '99000000520', 0, vmonto_iva, '01', vReferencia, ' ', ' ')
                                        INTO vcodret, vchar4, vdate, vmoney, vmoney;

                                -- // REGISTRA FINALIZACION DEL PROCESO
                                        update sc_contproc
                                        set fecha = vFechaHoy
                                        where empresa = '001'
                                        and proceso = vproceso;

                                END IF;
            END IF;
                END IF;
    END IF;
        */
-- SE MODIFICA ENVIO DE MONTO DE OPERACIONES PAGO DE CREDITO COPPEL EN ATMÂ´S SIN DESCUENTO DE COMISION

        IF vmonto_total > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0535', '0000', '92536921231000', '99000000520', 0, vmonto_total, '01', vReferencia, ' ', ' ')
        INTO vcodret, vchar4, vdate, vmoney, vmoney;

        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0536', '0000', '92536921231000', '12000000017', 0, vmonto_total, vmonto_total, 0, 0, 0, '01', vReferencia, ' ', ' ')
            INTO vcodret;

                                -- // REGISTRA FINALIZACION DEL PROCESO
                                        update sc_contproc
                                        set fecha = vFechaHoy
                                        where empresa = '001'
                                        and proceso = vproceso;

                END IF;
    END IF;

--
-- ****************************************************************************
-- *                 FIN DE PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    END;
    RETURN vCodRet1;

END PROCEDURE;
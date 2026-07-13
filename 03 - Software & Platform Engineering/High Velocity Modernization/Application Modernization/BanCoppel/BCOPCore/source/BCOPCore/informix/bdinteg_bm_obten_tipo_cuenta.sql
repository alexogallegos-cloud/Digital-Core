CREATE PROCEDURE "informix".bm_obten_tipo_cuenta( pSessionToken INTEGER ) --- Session Token
RETURNING CHAR(5)  AS vCodRet1,        --- Codigo de Retorno
          CHAR(2)  AS vStatus,         --- Status
          CHAR(25) AS vStatusDesc,     --- Descripcion del Status
          CHAR(10) AS vTipoCtaDebito,  --- Session Token
          CHAR(10) AS vTipoCtaCrebito; --- Informacion General
     
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vStatus          CHAR(2);
    DEFINE vStatusDesc      CHAR(25);
    DEFINE vTipoCtaDebito   CHAR(10);
    DEFINE vTipoCtaCrebito  CHAR(10);
    
    DEFINE vnumcte              CHAR(20);
    DEFINE vnumcel              CHAR(15);
    DEFINE vsecmax              INTEGER;
    DEFINE vid_oper             CHAR(4);
    DEFINE vexiste_debito       SMALLINT;
    DEFINE vexiste_credito      SMALLINT;
    DEFINE vexiste_credito_crd  SMALLINT;
    
    DEFINE vcodretcrd           CHAR(6);
    DEFINE vmensajecrd          CHAR(80);
    DEFINE vnumcredito          CHAR(20);
    DEFINE vnumctecrd           CHAR(20);
    DEFINE vnomprodcrd          CHAR(40);
    DEFINE vtarjetacrd          CHAR(20);
    DEFINE vclientecrd          CHAR(150);
    DEFINE vtransaccion         INTEGER;
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';
    LET vTipoCtaDebito  = '';
    LET vTipoCtaCrebito = '';
    
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vexiste_debito = 0;
    LET vexiste_credito = 0;
    LET vexiste_credito_crd = 0;
    
    LET vcodretcrd  = '';
    LET vmensajecrd = '';
    LET vnumcredito = '';
    LET vnumctecrd  = '';
    LET vnomprodcrd = '';
    LET vtarjetacrd = '';
    LET vclientecrd = '';
    LET vtransaccion = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_tipo_cuenta.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_tipo_cuenta.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF pSessionToken is null OR pSessionToken = 0 THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE MAXIMA SECUENCIA DEL CLIENTE EN LA BITACORA
    SELECT MAX(secuencia)
      INTO vsecmax
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken;
       
    IF vsecmax is null THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
    END IF;
    
    SELECT id_oper, numcte, numcel
      INTO vid_oper, vnumcte, vnumcel
      FROM bdinteg:"informix".si_bm_bitacora
     WHERE DATE(fech_oper) = CURRENT::DATE
       AND id_session = pSessionToken
       AND secuencia = vsecmax;
       
    IF vid_oper is null OR vid_oper = '' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
    END IF;
    
    IF vid_oper = '1001' THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
    END IF;
       
    IF vid_oper IN('1000', '1002', '1003', '1004', '1005') THEN
        -- // VALIDA SI EL CLIENTE TIENE CUENTAS DE DEBITO
        SELECT COUNT(*)
          INTO vexiste_debito
          FROM bdicheq:"informix".sc_maechq
         WHERE num_cte = vnumcte
           AND status_cta <> '2';
           
        IF vexiste_debito > 0 THEN
            LET vTipoCtaDebito  = 'DEBITO';
        END IF;
        
        -- // VALIDA SI EL CLIENTE TIENE CUENTAS DE CREDITO
		--IFRS Se modifica estatus por etapas
        SELECT COUNT(*)
          INTO vexiste_credito
          FROM bdicred:"informix".sd_maecred
         WHERE numcte = vnumcte
           AND status_cred IN ('AA','BA','BT', 'E1','E2','E3');
        
        SELECT COUNT(*)
          INTO vexiste_credito_crd
          FROM bdicred:"informix".sd_maecredcrd
         WHERE numcte = vnumcte
           AND status_cred IN ('AA','BA','BT','VP', 'E1','E2','E3');
           
        IF vexiste_credito > 0 OR vexiste_credito_crd > 0 THEN
            LET vTipoCtaCrebito = 'CREDITO';
        END IF;
    ELSE
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Usuario no firmado.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, vTipoCtaDebito, vTipoCtaCrebito;
    
    END;
    
END PROCEDURE;
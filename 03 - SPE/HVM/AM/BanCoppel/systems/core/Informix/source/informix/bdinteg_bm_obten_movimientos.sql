CREATE PROCEDURE "informix".bm_obten_movimientos( pSessionToken INTEGER,   --- Session Token
                                                  pCuenta       CHAR(16) ) --- Cuenta
RETURNING CHAR(5)  AS vCodRet1,        --- Codigo de Retorno
          CHAR(2)  AS vStatus,         --- Status
          CHAR(25) AS vStatusDesc,     --- Descripcion del Status
          
          CHAR(10) AS vFechaMov1,      --- Fecha Movimiento 1
          CHAR(5) AS vTipoMov1,        --- Tipo Movimiento 1
          DECIMAL(12,2) AS vMontoMov1, --- Monto Movimiento 1
          CHAR(10) AS vDescMov1,       --- Descripcion Movimiento 1
          
          CHAR(10) AS vFechaMov2,      --- Fecha Movimiento 2
          CHAR(5) AS vTipoMov2,        --- Tipo Movimiento 2
          DECIMAL(12,2) AS vMontoMov2, --- Monto Movimiento 2
          CHAR(10) AS vDescMov2,       --- Descripcion Movimiento 2
          
          CHAR(10) AS vFechaMov3,      --- Fecha Movimiento 3
          CHAR(5) AS vTipoMov3,        --- Tipo Movimiento 3
          DECIMAL(12,2) AS vMontoMov3, --- Monto Movimiento 3
          CHAR(10) AS vDescMov3,       --- Descripcion Movimiento 3
          
          CHAR(10) AS vFechaMov4,      --- Fecha Movimiento 4
          CHAR(5) AS vTipoMov4,        --- Tipo Movimiento 4
          DECIMAL(12,2) AS vMontoMov4, --- Monto Movimiento 4
          CHAR(10) AS vDescMov4,       --- Descripcion Movimiento 4
          
          CHAR(10) AS vFechaMov5,      --- Fecha Movimiento 5
          CHAR(5) AS vTipoMov5,        --- Tipo Movimiento 5
          DECIMAL(12,2) AS vMontoMov5, --- Monto Movimiento 5
          CHAR(10) AS vDescMov5,       --- Descripcion Movimiento 5
          
          CHAR(10) AS vFechaMov6,      --- Fecha Movimiento 6
          CHAR(5) AS vTipoMov6,        --- Tipo Movimiento 6
          DECIMAL(12,2) AS vMontoMov6, --- Monto Movimiento 6
          CHAR(10) AS vDescMov6,       --- Descripcion Movimiento 6
          
          CHAR(10) AS vFechaMov7,      --- Fecha Movimiento 7
          CHAR(5) AS vTipoMov7,        --- Tipo Movimiento 7
          DECIMAL(12,2) AS vMontoMov7, --- Monto Movimiento 7
          CHAR(10) AS vDescMov7,       --- Descripcion Movimiento 7
          
          CHAR(10) AS vFechaMov8,      --- Fecha Movimiento 8
          CHAR(5) AS vTipoMov8,        --- Tipo Movimiento 8
          DECIMAL(12,2) AS vMontoMov8, --- Monto Movimiento 8
          CHAR(10) AS vDescMov8,       --- Descripcion Movimiento 8
          
          CHAR(10) AS vFechaMov9,      --- Fecha Movimiento 9
          CHAR(5) AS vTipoMov9,        --- Tipo Movimiento 9
          DECIMAL(12,2) AS vMontoMov9, --- Monto Movimiento 9
          CHAR(10) AS vDescMov9,       --- Descripcion Movimiento 9
          
          CHAR(10) AS vFechaMov10,      --- Fecha Movimiento 10
          CHAR(5) AS vTipoMov10,        --- Tipo Movimiento 10
          DECIMAL(12,2) AS vMontoMov10, --- Monto Movimiento 10
          CHAR(10) AS vDescMov10;       --- Descripcion Movimiento 10

    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vStatus      CHAR(2);
    DEFINE vStatusDesc  CHAR(25);

    DEFINE vFechaMov1   CHAR(10);
    DEFINE vTipoMov1    CHAR(5);
    DEFINE vMontoMov1   DECIMAL(12,2);
    DEFINE vDescMov1    CHAR(10);
    
    DEFINE vFechaMov2   CHAR(10);
    DEFINE vTipoMov2    CHAR(5);
    DEFINE vMontoMov2   DECIMAL(12,2);
    DEFINE vDescMov2    CHAR(10);
    
    DEFINE vFechaMov3   CHAR(10);
    DEFINE vTipoMov3    CHAR(5);
    DEFINE vMontoMov3   DECIMAL(12,2);
    DEFINE vDescMov3    CHAR(10);
    
    DEFINE vFechaMov4   CHAR(10);
    DEFINE vTipoMov4    CHAR(5);
    DEFINE vMontoMov4   DECIMAL(12,2);
    DEFINE vDescMov4    CHAR(10);
    
    DEFINE vFechaMov5   CHAR(10);
    DEFINE vTipoMov5    CHAR(5);
    DEFINE vMontoMov5   DECIMAL(12,2);
    DEFINE vDescMov5    CHAR(10);
    
    DEFINE vFechaMov6   CHAR(10);
    DEFINE vTipoMov6    CHAR(5);
    DEFINE vMontoMov6   DECIMAL(12,2);
    DEFINE vDescMov6    CHAR(10);
    
    DEFINE vFechaMov7   CHAR(10);
    DEFINE vTipoMov7    CHAR(5);
    DEFINE vMontoMov7   DECIMAL(12,2);
    DEFINE vDescMov7    CHAR(10);
    
    DEFINE vFechaMov8   CHAR(10);
    DEFINE vTipoMov8    CHAR(5);
    DEFINE vMontoMov8   DECIMAL(12,2);
    DEFINE vDescMov8    CHAR(10);
    
    DEFINE vFechaMov9   CHAR(10);
    DEFINE vTipoMov9    CHAR(5);
    DEFINE vMontoMov9   DECIMAL(12,2);
    DEFINE vDescMov9    CHAR(10);
    
    DEFINE vFechaMov10  CHAR(10);
    DEFINE vTipoMov10   CHAR(5);
    DEFINE vMontoMov10  DECIMAL(12,2);
    DEFINE vDescMov10   CHAR(10);
    
    DEFINE vnumcte           CHAR(20);
    DEFINE vnumcel           CHAR(15);
    DEFINE vsecmax           INTEGER;
    DEFINE vid_oper          CHAR(4);
    DEFINE vfechconmovhis    DATE;
    DEFINE vfechconmovhisold DATE;
    DEFINE vcont             SMALLINT;
    DEFINE vfecha_alt        DATE;           
    DEFINE vserial           INTEGER;
    DEFINE vnaturaleza       CHAR(1);
    DEFINE vhora             CHAR(12);
    DEFINE vmonto            DECIMAL(12,2);
    DEFINE vreferencia       CHAR(50);
    DEFINE vtipo_mov         CHAR(5);
    
    DEFINE vcodret_mov      CHAR(5);
    DEFINE vfecha_mov       DATE;
    DEFINE vdesc_transacc   CHAR(40);
    DEFINE vmonto_transacc  MONEY(14,2);
    DEFINE vpagominimo      MONEY(14,2);
    DEFINE vsdodeudor       MONEY(14,2);
    DEFINE vintmora         DECIMAL(14,2);
    DEFINE vivaintmora      DECIMAL(14,2);
    DEFINE vdescripcion     CHAR(50);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfechaconv       CHAR(10);
    DEFINE vtransaccion     INTEGER;
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vStatus      = '00';
    LET vStatusDesc  = '';

    LET vFechaMov1   = '';
    LET vTipoMov1    = '';
    LET vMontoMov1   = 0.00;
    LET vDescMov1    = '';
    
    LET vFechaMov2   = '';
    LET vTipoMov2    = '';
    LET vMontoMov2   = 0.00;
    LET vDescMov2    = '';
    
    LET vFechaMov3   = '';
    LET vTipoMov3    = '';
    LET vMontoMov3   = 0.00;
    LET vDescMov3    = '';
    
    LET vFechaMov4   = '';
    LET vTipoMov4    = '';
    LET vMontoMov4   = 0.00;
    LET vDescMov4    = '';
    
    LET vFechaMov5   = '';
    LET vTipoMov5    = '';
    LET vMontoMov5   = 0.00;
    LET vDescMov5    = '';
    
    LET vFechaMov6   = '';
    LET vTipoMov6    = '';
    LET vMontoMov6   = 0.00;
    LET vDescMov6    = '';
    
    LET vFechaMov7   = '';
    LET vTipoMov7    = '';
    LET vMontoMov7   = 0.00;
    LET vDescMov7    = '';
    
    LET vFechaMov8   = '';
    LET vTipoMov8    = '';
    LET vMontoMov8   = 0.00;
    LET vDescMov8    = '';
    
    LET vFechaMov9   = '';
    LET vTipoMov9    = '';
    LET vMontoMov9   = 0.00;
    LET vDescMov9    = '';
    
    LET vFechaMov10  = '';
    LET vTipoMov10   = '';
    LET vMontoMov10  = 0.00;
    LET vDescMov10   = '';
    
    LET vnumcte = '';
    LET vnumcel = '';
    LET vsecmax = 0;
    LET vid_oper = '';
    LET vfechconmovhis = '';
    LET vfechconmovhisold = '';
    LET vcont = 0;
    LET vfecha_alt = '';
    LET vserial = 0;
    LET vnaturaleza = '';
    LET vmonto = 0.00;
    LET vreferencia = '';
    LET vtipo_mov = '';
    LET vhora = '';
    
    LET vcodret_mov     = '';
    LET vfecha_mov      = '';
    LET vdesc_transacc  = '';
    LET vmonto_transacc = 0.00;
    LET vpagominimo     = 0.00;
    LET vsdodeudor      = 0.00;
    LET vintmora        = 0.00;
    LET vivaintmora     = 0.00;
    LET vdescripcion    = '';
    LET vtransacc       = '';
    LET vfechaconv      = '';
    LET vtransaccion    = 0;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_movimientos.err";
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
            RETURN vCodRet1, vStatus, vStatusDesc, 
                   vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
                   vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
                   vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
                   vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
                   vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
                   vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
                   vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
                   vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
                   vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
                   vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
                
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/bm_obten_movimientos.out";
    --- TRACE ON;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    IF (pSessionToken is null OR pSessionToken = 0) OR
       (pCuenta is null OR pCuenta = '') THEN
        LET vCodRet1 = '11111';
        LET vStatus = '';
        LET vStatusDesc = 'Error en aplicativo.';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
               vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
               vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
               vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
               vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
               vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
               vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
               vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
               vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
               vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
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
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
               vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
               vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
               vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
               vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
               vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
               vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
               vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
               vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
               vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
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
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
               vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
               vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
               vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
               vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
               vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
               vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
               vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
               vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
               vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
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
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
               vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
               vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
               vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
               vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
               vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
               vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
               vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
               vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
               vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
    END IF;
    
    IF vid_oper IN('1000', '1002', '1003', '1004', '1005') THEN
    
        IF LENGTH(pCuenta) = 11 THEN
        
            SELECT valor
              INTO vfechconmovhis
              FROM bdicheq:"informix".sc_param
             WHERE empresa = '001'
               AND codparam = 'fechcon_movhis';
               
            SELECT valor
              INTO vfechconmovhisold
              FROM bdicheq:"informix".sc_param
             WHERE empresa = '001'
               AND codparam = 'FechIniCon_movhis_ol';
        
            LET vcont = 1;
            
            FOREACH
                SELECT mov.fech_alt, mov.num_serial, trx.naturaleza, mov.monto_tot, trx.descripcion
                  INTO vfecha_alt, vserial, vnaturaleza, vmonto, vreferencia
                  FROM bdicheq:"informix".sc_movdia mov,
                       bdinteg:"informix".si_transacc trx
                 WHERE mov.empresa = '001'
                   AND mov.cuenta = pCuenta
                   AND mov.cancelad <> 'S'
                   AND trx.numero = mov.transacc
                   AND trx.se_emite_edocta = 'S'
                UNION ALL
                SELECT mov.fech_alt, mov.num_serial, trx.naturaleza, mov.monto_tot, trx.descripcion
                  FROM bdicheq:"informix".sc_movhis mov,
                       bdinteg:"informix".si_transacc trx
                 WHERE mov.fech_alt >= vfechconmovhis
                   AND mov.cuenta = pCuenta
                   AND mov.cancelad <> 'S'
                   AND trx.numero = mov.transacc
                   AND trx.se_emite_edocta = 'S'
                UNION ALL
                SELECT mov.fech_alt, mov.num_serial, trx.naturaleza, mov.monto_tot, trx.descripcion
                  FROM bdicheq:"informix".sc_movhis_old mov,
                       bdinteg:"informix".si_transacc trx
                 WHERE mov.fech_alt >= vfechconmovhisold
                   AND mov.fech_alt < vfechconmovhis
                   AND mov.cuenta = pCuenta
                   AND mov.cancelad <> 'S'
                   AND trx.numero = mov.transacc
                   AND trx.se_emite_edocta = 'S'
                 ORDER BY mov.fech_alt DESC, mov.num_serial DESC
                 
                IF vnaturaleza = 'C' THEN
                    LET vtipo_mov = 'CARGO';
                ELIF vnaturaleza = 'A' THEN
                    LET vtipo_mov = 'ABONO';
                END IF;
                
                LET vfechaconv = TO_CHAR(vfecha_alt, '%d/%m/%Y');
                 
                IF vcont = 1 THEN
                    LET vFechaMov1   = vfechaconv;
                    LET vTipoMov1    = vtipo_mov;
                    LET vMontoMov1   = vmonto;
                    LET vDescMov1    = vreferencia;
                ELIF vcont = 2 THEN
                    LET vFechaMov2   = vfechaconv;
                    LET vTipoMov2    = vtipo_mov;
                    LET vMontoMov2   = vmonto;
                    LET vDescMov2    = vreferencia;
                ELIF vcont = 3 THEN
                    LET vFechaMov3   = vfechaconv;
                    LET vTipoMov3    = vtipo_mov;
                    LET vMontoMov3   = vmonto;
                    LET vDescMov3    = vreferencia;
                ELIF vcont = 4 THEN
                    LET vFechaMov4   = vfechaconv;
                    LET vTipoMov4    = vtipo_mov;
                    LET vMontoMov4   = vmonto;
                    LET vDescMov4    = vreferencia;
                ELIF vcont = 5 THEN
                    LET vFechaMov5   = vfechaconv;
                    LET vTipoMov5    = vtipo_mov;
                    LET vMontoMov5   = vmonto;
                    LET vDescMov5    = vreferencia;
                ELIF vcont = 6 THEN
                    LET vFechaMov6   = vfechaconv;
                    LET vTipoMov6    = vtipo_mov;
                    LET vMontoMov6   = vmonto;
                    LET vDescMov6    = vreferencia;
                ELIF vcont = 7 THEN
                    LET vFechaMov7   = vfechaconv;
                    LET vTipoMov7    = vtipo_mov;
                    LET vMontoMov7   = vmonto;
                    LET vDescMov7    = vreferencia;
                ELIF vcont = 8 THEN
                    LET vFechaMov8   = vfechaconv;
                    LET vTipoMov8    = vtipo_mov;
                    LET vMontoMov8   = vmonto;
                    LET vDescMov8    = vreferencia;
                ELIF vcont = 9 THEN
                    LET vFechaMov9   = vfechaconv;
                    LET vTipoMov9    = vtipo_mov;
                    LET vMontoMov9   = vmonto;
                    LET vDescMov9    = vreferencia;
                ELIF vcont = 10 THEN
                    LET vFechaMov10   = vfechaconv;
                    LET vTipoMov10    = vtipo_mov;
                    LET vMontoMov10   = vmonto;
                    LET vDescMov10    = vreferencia;
                END IF;
                
                LET vcont = vcont + 1;
                
                IF vcont > 10 THEN
                    EXIT FOREACH;
                END IF;
                
                LET vfecha_alt = '';
                LET vserial = 0;
                LET vnaturaleza = '';
                LET vmonto = 0.00;
                LET vreferencia = '';
                LET vtipo_mov = '';
            END FOREACH;
            
            -- // GENERA REGISTRO EN BITACORA COMO PASSWORD-USUARIO
            SELECT MAX(secuencia)
              INTO vsecmax
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND id_session = pSessionToken;
               
            LET vsecmax = vsecmax + 1;
       
            INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
            VALUES(pSessionToken, current, vnumcte, vsecmax, '1004', vnumcel, null, null);
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                LET vCodRet1 = '11111';
                LET vStatus = '';
                LET vStatusDesc = 'Error en aplicativo.';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vCodRet1, vStatus, vStatusDesc, 
                       vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
                       vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
                       vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
                       vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
                       vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
                       vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
                       vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
                       vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
                       vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
                       vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
            END IF;
            
        ELSE
            
            IF LENGTH(pCuenta) = 16 THEN  
            
                SELECT num_credito
                  INTO pCuenta
                  FROM bdicred:sd_tarjeta
                 WHERE num_tarjeta = pCuenta
                   AND status_tar = 'A'
                   AND tipo_tarjeta = 'T';
                
                LET vcont = 1;
            
                FOREACH
                    EXECUTE PROCEDURE bdicred:"informix".consultmovs('001', pCuenta, 10)
                    INTO vcodret_mov, vfecha_mov, vdesc_transacc, vmonto_transacc, vpagominimo, vsdodeudor, vintmora, vivaintmora
                    
                    LET vfecha_alt = vfecha_mov;
                    LET vtransacc = SUBSTR(vdesc_transacc,1,4);
                    
                    SELECT naturaleza, descripcion
                      INTO vnaturaleza, vdescripcion
                      FROM bdinteg:"informix".si_transacc
                     WHERE numero = vtransacc;
                    
                    IF vnaturaleza = 'C' THEN
                        LET vtipo_mov = 'CARGO';
                        IF vmonto_transacc < 0.00 THEN
                            LET vmonto_transacc = vmonto_transacc * -1;
                        END IF;
                    ELIF vnaturaleza = 'A' THEN
                        LET vtipo_mov = 'ABONO';
                    END IF;
                    
                    LET vmonto = vmonto_transacc;
                    LET vfechaconv = TO_CHAR(vfecha_alt, '%d/%m/%Y');
                     
                    IF vcont = 1 THEN
                        LET vFechaMov1   = vfechaconv;
                        LET vTipoMov1    = vtipo_mov;
                        LET vMontoMov1   = vmonto;
                        LET vDescMov1    = TRIM(vdescripcion);
                    ELIF vcont = 2 THEN
                        LET vFechaMov2   = vfechaconv;
                        LET vTipoMov2    = vtipo_mov;
                        LET vMontoMov2   = vmonto;
                        LET vDescMov2    = TRIM(vdescripcion);
                    ELIF vcont = 3 THEN
                        LET vFechaMov3   = vfechaconv;
                        LET vTipoMov3    = vtipo_mov;
                        LET vMontoMov3   = vmonto;
                        LET vDescMov3    = TRIM(vdescripcion);
                    ELIF vcont = 4 THEN
                        LET vFechaMov4   = vfechaconv;
                        LET vTipoMov4    = vtipo_mov;
                        LET vMontoMov4   = vmonto;
                        LET vDescMov4    = TRIM(vdescripcion);
                    ELIF vcont = 5 THEN
                        LET vFechaMov5   = vfechaconv;
                        LET vTipoMov5    = vtipo_mov;
                        LET vMontoMov5   = vmonto;
                        LET vDescMov5    = TRIM(vdescripcion);
                    ELIF vcont = 6 THEN
                        LET vFechaMov6   = vfechaconv;
                        LET vTipoMov6    = vtipo_mov;
                        LET vMontoMov6   = vmonto;
                        LET vDescMov6    = TRIM(vdescripcion);
                    ELIF vcont = 7 THEN
                        LET vFechaMov7   = vfechaconv;
                        LET vTipoMov7    = vtipo_mov;
                        LET vMontoMov7   = vmonto;
                        LET vDescMov7    = TRIM(vdescripcion);
                    ELIF vcont = 8 THEN
                        LET vFechaMov8   = vfechaconv;
                        LET vTipoMov8    = vtipo_mov;
                        LET vMontoMov8   = vmonto;
                        LET vDescMov8    = TRIM(vdescripcion);
                    ELIF vcont = 9 THEN
                        LET vFechaMov9   = vfechaconv;
                        LET vTipoMov9    = vtipo_mov;
                        LET vMontoMov9   = vmonto;
                        LET vDescMov9    = TRIM(vdescripcion);
                    ELIF vcont = 10 THEN
                        LET vFechaMov10   = vfechaconv;
                        LET vTipoMov10    = vtipo_mov;
                        LET vMontoMov10   = vmonto;
                        LET vDescMov10    = TRIM(vdescripcion);
                    END IF;
                    
                    LET vcont = vcont + 1;
                    
                    IF vcont > 10 THEN
                        EXIT FOREACH;
                    END IF;
                    
                    LET vfecha_alt = '';
                    LET vhora = '';
                    LET vnaturaleza = '';
                    LET vmonto = 0;
                    LET vreferencia = '';
                    LET vtipo_mov = '';
                    LET vcodret_mov     = '';
                    LET vfecha_mov      = '';
                    LET vdesc_transacc  = '';
                    LET vmonto_transacc = 0.00;
                    LET vpagominimo     = 0.00;
                    LET vsdodeudor      = 0.00;
                    LET vintmora        = 0.00;
                    LET vivaintmora     = 0.00;
                    LET vdescripcion    = '';
                END FOREACH;
                
            ELSE
            
                LET vcont = 1;
            
                FOREACH
                    EXECUTE PROCEDURE bdicred:"informix".sp_consultmovscrd('001', pCuenta, 10)
                    INTO vcodret_mov, vfecha_mov, vdesc_transacc, vmonto_transacc, vpagominimo, vsdodeudor, vintmora, vivaintmora
                    
                    LET vfecha_alt = vfecha_mov;
                    LET vtransacc = SUBSTR(vdesc_transacc,1,4);
                    
                    SELECT naturaleza, descripcion
                      INTO vnaturaleza, vdescripcion
                      FROM bdinteg:"informix".si_transacc
                     WHERE numero = vtransacc;
                    
                    IF vnaturaleza = 'C' THEN
                        LET vtipo_mov = 'CARGO';
                        IF vmonto_transacc < 0.00 THEN
                            LET vmonto_transacc = vmonto_transacc * -1;
                        END IF;
                    ELIF vnaturaleza = 'A' THEN
                        LET vtipo_mov = 'ABONO';
                    END IF;
                    
                    LET vmonto = vmonto_transacc;
                    LET vfechaconv = TO_CHAR(vfecha_alt, '%d/%m/%Y');
                     
                    IF vcont = 1 THEN
                        LET vFechaMov1   = vfechaconv;
                        LET vTipoMov1    = vtipo_mov;
                        LET vMontoMov1   = vmonto;
                        LET vDescMov1    = TRIM(vdescripcion);
                    ELIF vcont = 2 THEN
                        LET vFechaMov2   = vfechaconv;
                        LET vTipoMov2    = vtipo_mov;
                        LET vMontoMov2   = vmonto;
                        LET vDescMov2    = TRIM(vdescripcion);
                    ELIF vcont = 3 THEN
                        LET vFechaMov3   = vfechaconv;
                        LET vTipoMov3    = vtipo_mov;
                        LET vMontoMov3   = vmonto;
                        LET vDescMov3    = TRIM(vdescripcion);
                    ELIF vcont = 4 THEN
                        LET vFechaMov4   = vfechaconv;
                        LET vTipoMov4    = vtipo_mov;
                        LET vMontoMov4   = vmonto;
                        LET vDescMov4    = TRIM(vdescripcion);
                    ELIF vcont = 5 THEN
                        LET vFechaMov5   = vfechaconv;
                        LET vTipoMov5    = vtipo_mov;
                        LET vMontoMov5   = vmonto;
                        LET vDescMov5    = TRIM(vdescripcion);
                    ELIF vcont = 6 THEN
                        LET vFechaMov6   = vfechaconv;
                        LET vTipoMov6    = vtipo_mov;
                        LET vMontoMov6   = vmonto;
                        LET vDescMov6    = TRIM(vdescripcion);
                    ELIF vcont = 7 THEN
                        LET vFechaMov7   = vfechaconv;
                        LET vTipoMov7    = vtipo_mov;
                        LET vMontoMov7   = vmonto;
                        LET vDescMov7    = TRIM(vdescripcion);
                    ELIF vcont = 8 THEN
                        LET vFechaMov8   = vfechaconv;
                        LET vTipoMov8    = vtipo_mov;
                        LET vMontoMov8   = vmonto;
                        LET vDescMov8    = TRIM(vdescripcion);
                    ELIF vcont = 9 THEN
                        LET vFechaMov9   = vfechaconv;
                        LET vTipoMov9    = vtipo_mov;
                        LET vMontoMov9   = vmonto;
                        LET vDescMov9    = TRIM(vdescripcion);
                    ELIF vcont = 10 THEN
                        LET vFechaMov10   = vfechaconv;
                        LET vTipoMov10    = vtipo_mov;
                        LET vMontoMov10   = vmonto;
                        LET vDescMov10    = TRIM(vdescripcion);
                    END IF;
                    
                    LET vcont = vcont + 1;
                    
                    IF vcont > 10 THEN
                        EXIT FOREACH;
                    END IF;
                    
                    LET vfecha_alt = '';
                    LET vhora = '';
                    LET vnaturaleza = '';
                    LET vmonto = 0;
                    LET vreferencia = '';
                    LET vtipo_mov = '';
                    LET vcodret_mov     = '';
                    LET vfecha_mov      = '';
                    LET vdesc_transacc  = '';
                    LET vmonto_transacc = 0.00;
                    LET vpagominimo     = 0.00;
                    LET vsdodeudor      = 0.00;
                    LET vintmora        = 0.00;
                    LET vivaintmora     = 0.00;
                    LET vdescripcion    = '';
                END FOREACH;
            
            END IF;
            
            -- // GENERA REGISTRO EN BITACORA COMO PASSWORD-USUARIO
            SELECT MAX(secuencia)
              INTO vsecmax
              FROM bdinteg:"informix".si_bm_bitacora
             WHERE DATE(fech_oper) = CURRENT::DATE
               AND id_session = pSessionToken;
               
            LET vsecmax = vsecmax + 1;
            
            INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
            VALUES(pSessionToken, current, vnumcte, vsecmax, '1005', vnumcel, null, null);
            
            IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                LET vCodRet1 = '11111';
                LET vStatus = '';
                LET vStatusDesc = 'Error en aplicativo.';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vCodRet1, vStatus, vStatusDesc, 
                       vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
                       vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
                       vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
                       vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
                       vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
                       vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
                       vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
                       vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
                       vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
                       vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
            END IF;
            
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
        RETURN vCodRet1, vStatus, vStatusDesc, 
               vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
               vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
               vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
               vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
               vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
               vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
               vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
               vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
               vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
               vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
    
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;

    RETURN vCodRet1, vStatus, vStatusDesc, 
           vFechaMov1, vTipoMov1, vMontoMov1, vDescMov1,
           vFechaMov2, vTipoMov2, vMontoMov2, vDescMov2,
           vFechaMov3, vTipoMov3, vMontoMov3, vDescMov3,
           vFechaMov4, vTipoMov4, vMontoMov4, vDescMov4,
           vFechaMov5, vTipoMov5, vMontoMov5, vDescMov5,
           vFechaMov6, vTipoMov6, vMontoMov6, vDescMov6,
           vFechaMov7, vTipoMov7, vMontoMov7, vDescMov7,
           vFechaMov8, vTipoMov8, vMontoMov8, vDescMov8,
           vFechaMov9, vTipoMov9, vMontoMov9, vDescMov9,
           vFechaMov10, vTipoMov10, vMontoMov10, vDescMov10;
           
    END;

END PROCEDURE;
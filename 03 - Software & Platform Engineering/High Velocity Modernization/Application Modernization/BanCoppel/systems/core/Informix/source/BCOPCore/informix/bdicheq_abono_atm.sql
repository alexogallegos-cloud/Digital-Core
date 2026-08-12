CREATE PROCEDURE "informix".abono_atm( pc_costos CHAR(4),        --- SUCURSAL
                                       pcta_tar  CHAR(20),       --- CUENTA / TARJETA
                                       pmto_tot  DECIMAL(14,2) ) --- MONTO
RETURNING CHAR(5),  --- CODIGO DE RETORNO
		  CHAR(16), --- FOLIO
          CHAR(9),  --- NO. BOLETO INICIAL SORTEO MILLONARIO
          CHAR(9);  --- NO. BOLETO FINAL SORTEO MILLONARIO

    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE viDescErr    CHAR(50);
    DEFINE viEnTransac  SMALLINT;
    DEFINE vcCuenta     CHAR(20);
    DEFINE vcTarjeta    CHAR(16);
    DEFINE vcTransac    CHAR(4);
    DEFINE vcHora       CHAR(15);
    DEFINE vcFolio      CHAR(16);
    DEFINE vcCodRetAbo  CHAR(5);
    DEFINE vcBoletoIni  CHAR(9);
    DEFINE vcBoletoFin  CHAR(9);
    DEFINE vind_dispon  CHAR(1);
    
    LET vcCodRet1   = '00000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET viDescErr   = 0;
    LET viEnTransac = 0;
    LET vcCuenta    = '';
    LET vcTarjeta   = '';
    LET vcTransac   = '';
    LET vcHora      = '';
    LET vcFolio     = '';
    LET vcCodRetAbo = '';
    LET vcBoletoIni = '000000000';
    LET vcBoletoFin = '000000000';
    LET vind_dispon = '0';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/abono_atm.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, viDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/abono_atm.err';
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = viDescErr;
            IF viEnTransac = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            LET vcCodRet1 = '00999';
            LET vcFolio = '';
            RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET viEnTransac = 1;
    END EXCEPTION WITH resume;

    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
    
    -- // VALIDA PARAMETROS RECIBIDOS
    IF ( pc_costos is null OR pc_costos = '' )  OR
       ( pcta_tar is null OR pcta_tar = '' )    OR
       ( pmto_tot is null OR pmto_tot <= 0.00 ) THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00110';
        LET vcFolio = '';
        RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
    END IF;
    
    SELECT ind_disponible
      INTO vind_dispon
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
     
    IF vind_dispon = '0' THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00004';
        LET vcFolio = '';
        RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
    END IF;
    
    -- // VALIDA QUE EXISTA LA CUENTA / TARJETA
    IF LENGTH(pcta_tar) = 11 THEN
        SELECT cuenta
          INTO vcCuenta
          FROM bdicheq:sc_maechq
         WHERE empresa = '001'
           AND cuenta = pcta_tar;
           
        IF ( vcCuenta is not null OR vcCuenta <> '' ) THEN
            LET vcCuenta = pcta_tar;
            LET vcTarjeta = '';
        ELSE
            IF viEnTransac = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcCodRet1 = '00100';
            LET vcFolio = '';
            RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
        END IF;
    ELIF LENGTH(pcta_tar) = 16 THEN
        SELECT mae.cuenta
          INTO vcCuenta
          FROM bdicheq:sc_tarjeta tar,
               bdicheq:sc_maechq mae
         WHERE tar.empresa = '001'
           AND tar.num_tarjeta = pcta_tar
           AND tar.status_tar = 'A'
           AND mae.empresa = tar.empresa
           AND mae.cuenta = tar.cuenta;
           
        IF ( vcCuenta is not null OR vcCuenta <> '' ) THEN
            LET vcCuenta = vcCuenta;
            LET vcTarjeta = pcta_tar;
        ELSE
            IF viEnTransac = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            LET vcCodRet1 = '00100';
            LET vcFolio = '';
            RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
        END IF;
    ELSE
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00100';
        LET vcFolio = '';
        RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
    END IF;
    
    -- // OBTIENE TRANSACCION DE DEPOSITO
    SELECT valor
      INTO vcTransac
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = "TransaccDepCajero";
       
    IF vcTransac is null OR vcTransac = '' THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00110';
        LET vcFolio = '';
        RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
    END IF;
    
    -- // ARMA FOLIO DE OPERACION PARA EL DEPOSITO
    LET vcHora = CURRENT HOUR TO FRACTION;
    LET vcFolio = "recicatm"||vcHora[1,2]||vcHora[4,5]||vcHora[7,8]||vcHora[10,11];
    
    -- // APLICA OPERACION DE DEPOSITO EN LA CUENTA DE CAPTACION
    EXECUTE PROCEDURE bdicheq:abono_ref( '001', pc_costos, 'informix', vcTransac, "0000", vcFolio, vcCuenta, 0, pmto_tot, pmto_tot, 0, 0, 0, '01', '', vcTarjeta, '' ) 
    INTO vcCodRetAbo;
    
    -- // VALIDA EL RESULTADO DE LA OPERACION DE DEPOSITO EN LA CUENTA DE CAPTACION
    IF vcCodRetAbo <> '000' THEN
        IF ( vcCodRetAbo = '110' OR vcCodRetAbo = '106' OR vcCodRetAbo = '420' OR vcCodRetAbo = '552' OR 
             vcCodRetAbo = '959' OR vcCodRetAbo = '956' OR vcCodRetAbo = '401' OR vcCodRetAbo = '549' ) THEN
            LET vcCodRet1 = '00110';
        ELIF vcCodRetAbo = '100' THEN
            LET vcCodRet1 = '00100';
        ELIF vcCodRetAbo = '200' THEN
            LET vcCodRet1 = '00200';
        ELIF vcCodRetAbo = '951' THEN
            LET vcCodRet1 = '00951';
        ELIF vcCodRetAbo = '301' THEN
            LET vcCodRet1 = '00302';
        ELSE 
            LET vcCodRet1 = '00999';
        END IF;  
        
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        LET vcFolio = '';
        RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
    END IF;
    
    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vcCodRet1, vcFolio, vcBoletoIni, vcBoletoFin;
    
END PROCEDURE;
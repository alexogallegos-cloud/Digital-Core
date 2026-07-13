CREATE PROCEDURE "informix".sp_ingresos_pros_web( pTipoOperacion CHAR(1),
                                               pEmpresa CHAR(3),
                                               pNumeroCliente CHAR(20),
                                               pSecuencia SMALLINT,
                                               pTipoIngreso CHAR(1),
                                               pNombreEmpresa CHAR(60),
                                               pPuesto CHAR(3),
                                               pAntiguedad DECIMAL(4,2),
                                               pNombreDepto CHAR(40),
                                               pJefeInmediato CHAR(60),
                                               pIngresosMensuales MONEY(14,2),
                                               pUsuarioInserta CHAR(8),
                                               pFechaInserta DATE,
                                               pPuestoEsp CHAR(2),
                                               pClavePuesto INTEGER,
                                               pClaveOpcionPuesto INTEGER,
                                               pClaveSubopcionPuesto INTEGER,
                                               pSisCotiza INTEGER,
                                               pNumEmpLab INTEGER,
                                               pTipoIngresoExt INTEGER,
                                               pPeriosidad INTEGER )
RETURNING CHAR(5);
    
    DEFINE vcodret CHAR(5);
    DEFINE iSecuencia INTEGER;
    DEFINE iSqlErr INTEGER;
    
    LET vcodret = '00000';
    LET iSecuencia  = 0;

    --- SET debug FILE TO '/pisa/pisabanco/sp_ingresos_pros.out';
    --SET debug FILE TO '/pisa/pisabanco/sp_ingresos_pros.out';
    --TRACE ON;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vcodret = iSqlErr;
            RETURN vCodret;
        END IF;
    END EXCEPTION

    IF pClaveOpcionPuesto is null THEN
        LET pClaveOpcionPuesto = 0;
    END IF;
    
    IF pClaveSubopcionPuesto is null THEN
        LET pClaveSubopcionPuesto = 0;
    END IF;
    
    IF pClavePuesto = 0 THEN
        LET pPuesto = '4';
        LET pPuestoEsp = '0';
    END IF;
    
    IF pClavePuesto = 1 THEN
        IF pClaveOpcionPuesto = 5 THEN
            IF pClaveSubOpcionPuesto = 2 THEN
                LET pPuesto = '7';
                LET pPuestoEsp = '0';
            ELSE
                LET pPuesto = '5';
                LET pPuestoEsp = '9';
            END IF;
        END IF;

        IF pClaveOpcionPuesto = 1 OR pClaveOpcionPuesto = 2 OR pClaveOpcionPuesto = 3 OR pClaveOpcionPuesto = 4 OR 
           pClaveOpcionPuesto = 6 OR pClaveOpcionPuesto = 7 OR pClaveOpcionPuesto = 8 OR pClaveOpcionPuesto = 10 THEN
            LET pPuesto = '5';
            LET pPuestoEsp = '9';
        END IF;

        IF pClaveOpcionPuesto = 9 THEN
            LET pPuesto = '3';
            LET pPuestoEsp = '8';
        END IF;
    END IF;
    
    IF pClavePuesto = 2 THEN
        IF pClaveOpcionPuesto = 5 THEN
            IF pClaveSubOpcionPuesto = 2 THEN
                LET pPuesto = '7';
                LET pPuestoEsp = '0';
            ELSE
                LET pPuesto = '6';
                LET pPuestoEsp = '33';
            END IF;
        END IF;
    
        IF pClaveOpcionPuesto =1  OR pClaveOpcionPuesto = 2 OR pClaveOpcionPuesto = 3 OR pClaveOpcionPuesto = 4 OR pClaveOpcionPuesto = 6 OR pClaveOpcionPuesto = 7 OR pClaveOpcionPuesto = 8 OR pClaveOpcionPuesto = 10  THEN
            LET pPuesto = '6';
            LET pPuestoEsp = '33';
        END IF;

        IF pClaveOpcionPuesto = 9 THEN
            LET pPuesto = '3';
            LET pPuestoEsp = '8';
        END IF;
    END IF;
    
    IF pClavePuesto = 3 THEN
        LET pPuesto = '1';
        LET pPuestoEsp = '0';
    END IF;
    
    IF pClavePuesto = 4 THEN
        LET pPuesto = '1';
        LET pPuestoEsp = '0';
    END IF;
    
    IF pClavePuesto = 5 THEN
        LET pPuesto = '1';
        LET pPuestoEsp = '0';
    END IF;
    
    IF pTipoIngreso = 'E' THEN
        LET pNombreEmpresa = '';
    END IF
    
    -- 
    IF pTipoOperacion = 'A' THEN 
        SELECT MAX(sec_ingreso)
          INTO iSecuencia
          FROM pr_ingresos
         WHERE empresa = pEmpresa 
           AND numcte_pros = pNumeroCliente;

        IF iSecuencia IS NULL THEN
            LET iSecuencia = 1;
        ELSE
            LET iSecuencia = iSecuencia + 1;
        END IF

        INSERT INTO pr_ingresos 
        ( empresa, numcte_pros, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad,
          nombre_depto, jefe_inmediato, ingreso_mensual, user_insert, fecha_insert, clavepuesto,
          claveopcionpuesto, clavesubopcionpuesto, sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext )
        VALUES 
        ( pEmpresa, pNumeroCliente, iSecuencia, pTipoIngreso, pNombreEmpresa, pPuesto, pPuestoEsp, pAntiguedad,
          pNombreDepto, pJefeInmediato, pIngresosMensuales, pUsuarioInserta, pFechaInserta, pClavePuesto,
          pClaveOpcionPuesto, pClaveSubOpcionPuesto, pSisCotiza, pNumEmpLab, pPeriosidad, pTipoIngresoExt );
          
    -- 
    ELIF pTipoOperacion = 'C' THEN 
        IF pSecuencia = 0 THEN
            SELECT MAX(sec_ingreso)
              INTO iSecuencia
              FROM pr_ingresos
             WHERE empresa = pEmpresa 
               AND numcte_pros = pNumeroCliente;

            IF iSecuencia IS NULL THEN
                LET iSecuencia = 1;
            ELSE
                LET iSecuencia = iSecuencia + 1;
            END IF

            IF NOT EXISTS ( SELECT numcte_pros 
                              FROM pr_ingresos 
                             WHERE empresa = pEmpresa 
                               AND numcte_pros = pNumeroCliente 
                               AND sec_ingreso = iSecuencia ) THEN
                INSERT INTO pr_ingresos 
                ( empresa, numcte_pros, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, puesto_esp, antiguedad,
                  nombre_depto, jefe_inmediato, ingreso_mensual, user_insert, fecha_insert, clavepuesto,
                  claveopcionpuesto, clavesubopcionpuesto, sis_cotiza, num_emp_lab, periosidad, tipo_ingreso_ext )
                VALUES 
                ( pEmpresa, pNumeroCliente, iSecuencia, pTipoIngreso, pNombreEmpresa, pPuesto, pPuestoEsp, pAntiguedad,
                  pNombreDepto, pJefeInmediato, pIngresosMensuales, pUsuarioInserta, pFechaInserta, pClavePuesto,
                  pClaveOpcionPuesto, pClaveSubOpcionPuesto, pSisCotiza, pNumEmpLab, pPeriosidad, pTipoIngresoExt );
            ELSE
                LET vcodret = '00400';  --Secuencia invalida
            END IF
        ELSE
            UPDATE pr_ingresos
               SET empresa = pEmpresa, 
                   numcte_pros = pNumeroCliente, 
                   sec_ingreso = pSecuencia, 
                   tipo_ingreso = pTipoIngreso, 
                   nombre_empresa = pNombreEmpresa,
                   puesto = pPuesto, 
                   puesto_esp = pPuestoEsp, 
                   antiguedad = pAntiguedad, 
                   nombre_depto = pNombreDepto, 
                   jefe_inmediato = pJefeInmediato,
                   ingreso_mensual = pIngresosMensuales, 
                   user_insert = pUsuarioInserta, 
                   fecha_insert = pFechaInserta, 
                   clavepuesto = pClavePuesto,
                   claveopcionpuesto = pClaveOpcionPuesto, 
                   clavesubopcionpuesto = pClaveSubOpcionPuesto, 
                   sis_cotiza = pSisCotiza,
                   num_emp_lab = pNumEmpLab, 
                   periosidad = pPeriosidad, 
                   tipo_ingreso_ext = pTipoIngresoExt
             WHERE numcte_pros = pNumeroCliente 
               AND sec_ingreso = pSecuencia 
               AND tipo_ingreso = pTipoIngreso;
        END IF
    ELSE
        LET vcodret = '00200'; --Tipo de operacion incorrecta
    END IF
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;
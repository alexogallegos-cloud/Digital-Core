CREATE PROCEDURE "informix".coninvsr_anual( pEmpresa CHAR(3), pEjercicio SMALLINT)    
RETURNING VARCHAR(5),  -- CodigoRetorno
          VARCHAR(64), -- DescripcionError
          INTEGER;     -- Cantidad de registros aÃ±
    
    -- ***********************************************************************************************
    -- coninvsr_anual
    -- Version              1.0.0
    -- Obejtivo:            Obtener en tabla sc_retenisr la
    --                      informacion del periodo indicado referente a retenciones de isr
    -- Supuestos:           Ninguno
    -- Valores de Entrada:  pEmpresa            Clave de la Empresa
    --                      pEjercicio          Ejercicio Fiscal
    -- Valores de Regreso:  Codigo
    --                      Descripcion de retorno
    --                      cantidad de registros
    -- Creado por:          Alejandro Rueda Sanchez
    -- ModIFicado por:
    -- Ultima ModIFicacion: Febrero-2008
    --                      CreaciÃ³PL
    -- Ultima modificacion: Mayo 2009
    --                      Se agrego el calculo de ajuste_inflacion, ajuste_deflasion, 
    --                      interes_nominal_total, interes_nominal_exento, interes_nominal_gravado
    -- Modificado por : Alejandro Osuna
    -- *************************************************************************************************

    DEFINE cVarDataErr                      VARCHAR(64);
    DEFINE iSqlErr                          INTEGER;
    DEFINE iSamErr                          INTEGER;
    DEFINE vCodRet                          CHAR(5);
    DEFINE vcuantos                         INTEGER;
    
    DEFINE vcuenta                          CHAR(20);
    DEFINE vcliente                         CHAR(20);
    DEFINE vsecuencia                       SMALLINT;
    DEFINE vmaxsec                          SMALLINT;
    DEFINE vcapital                         DECIMAL(18,6);
    DEFINE vintereses                       DECIMAL(18,6);
    DEFINE visr                             DECIMAL(18,6);
    DEFINE vtasa                            DECIMAL(9,6);
    DEFINE vfecha_alta                      DATE;
    DEFINE vfecha_venc                      DATE;
    DEFINE vsdopromedio                     DECIMAL(18,6);
    DEFINE vtasaperiodo                     DECIMAL(9,6);
    DEFINE vtasaperiodoacum                 DECIMAL(9,6);
    DEFINE vinpcini                         DECIMAL(9,6);
    DEFINE vinpcfin                         DECIMAL(9,6);
    DEFINE vajuste_inflacion                DECIMAL(12,6);
    DEFINE vajuste_inflacion_acum           DECIMAL(12,6);
    DEFINE vperdida                         DECIMAL(18,6);
    DEFINE vperdida_acum                    DECIMAL(18,6);
    DEFINE vdiasanio                        SMALLINT;
    DEFINE vdiasinver                       SMALLINT;
    DEFINE vmesini                          SMALLINT;
    DEFINE vmesfin                          SMALLINT;
    DEFINE vsdoprom1                        DECIMAL(18,6);
    DEFINE vsdoprom2                        DECIMAL(18,6);
    DEFINE vsdoprom3                        DECIMAL(18,6);
    DEFINE vsdoprom4                        DECIMAL(18,6);
    DEFINE vsdoprom5                        DECIMAL(18,6);
    DEFINE vsdoprom6                        DECIMAL(18,6);
    DEFINE vsdoprom7                        DECIMAL(18,6);
    DEFINE vsdoprom8                        DECIMAL(18,6);
    DEFINE vsdoprom9                        DECIMAL(18,6);
    DEFINE vsdoprom10                       DECIMAL(18,6);
    DEFINE vsdoprom11                       DECIMAL(18,6);
    DEFINE vsdoprom12                       DECIMAL(18,6);
    DEFINE vmincta                          CHAR(20); 
    DEFINE vmaxcta                          CHAR(20); 
    DEFINE vinteres_pagado                  DECIMAL(18,6);
    DEFINE vinteres_pagado_acum             DECIMAL(18,6);
    DEFINE vinteres_nominal_total           DECIMAL(18,6);
    DEFINE vinteres_nominal_total_acum      DECIMAL(18,6);
    DEFINE vreten_interes                   DECIMAL(18,6);
    DEFINE vreten_interes_acum              DECIMAL(18,6);
    DEFINE vinteres_nominal_exento          DECIMAL(18,6);
    DEFINE vinteres_nominal_exento_acum     DECIMAL(18,6);
    DEFINE vinteres_nominal_gravado         DECIMAL(18,6);
    DEFINE vinteres_nominal_gravado_acum    DECIMAL(18,6);
    DEFINE vveces                           SMALLINT;
    
    LET cVarDataErr = '';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET vCodRet = '000';
    LET vcuantos = 0;
    
    LET vcuenta = '';
    LET vcliente = '';
    LET vsecuencia = 0;
    LET vcapital = 0;
    LET vintereses = 0;
    LET visr = 0;
    LET vtasa = 0;
    LET vfecha_alta = '';
    LET vfecha_venc = '';
    LET vsdopromedio = 0;
    LET vtasaperiodo  = 0;
    LET vtasaperiodoacum = 0;
    LET vinpcini = 0;
    LET vinpcfin = 0;
    LET vajuste_inflacion = 0;
    LET vajuste_inflacion_acum = 0;
    LET vperdida = 0;
    LET vperdida_acum = 0;
    LET vdiasanio = 360;
    LET vdiasinver = 0;
    LET vmesini = 0;
    LET vmesfin = 0;
    LET vsdoprom1 = 0.0;
    LET vsdoprom2 = 0.0;
    LET vsdoprom3 = 0.0;
    LET vsdoprom4 = 0.0;
    LET vsdoprom5 = 0.0;
    LET vsdoprom6 = 0.0;
    LET vsdoprom7 = 0.0;
    LET vsdoprom8 = 0.0;
    LET vsdoprom9 = 0.0;
    LET vsdoprom10 = 0.0;
    LET vsdoprom11 = 0.0;
    LET vsdoprom12 = 0.0;
    LET vmincta = '';
    LET vmaxcta = '';
    LET vinteres_pagado = 0;
    LET vinteres_pagado_acum = 0;
    LET vinteres_nominal_total = 0;
    LET vinteres_nominal_total_acum = 0;
    LET vreten_interes = 0;
    LET vreten_interes_acum = 0;
    LET vinteres_nominal_exento = 0;
    LET vinteres_nominal_exento_acum = 0;
    LET vinteres_nominal_gravado = 0;
    LET vinteres_nominal_gravado_acum = 0;
    LET vveces = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET vCodret=iSqlErr;
            RETURN vCodret, cVarDataErr, NULL;
        END IF;
    END EXCEPTION;

    -- set debug file to "./coninvsr_anual.out";
    -- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Trae las cuentas de inversiones
    FOREACH
        SELECT UNIQUE cuenta, num_cte
          INTO vcuenta, vcliente
          FROM bdinvers:sv_maeinv
         WHERE fecha_venc BETWEEN ('01/01/' || pEjercicio) AND ('12/31/' || pEjercicio)
           --AND cuenta = '30002670379'
           
        FOREACH
            SELECT secuencia, capital, intereses, isr, tasa, fecha_alta, fecha_venc
              INTO vsecuencia, vcapital, vintereses, visr, vtasa, vfecha_alta, vfecha_venc
              FROM bdinvers:sv_maeinv
             WHERE empresa = pEmpresa
               AND cuenta = vcuenta
               AND fecha_venc BETWEEN ('01/01/' || pEjercicio) AND ('12/31/' || pEjercicio)
             ORDER BY secuencia
             
            LET vveces = vveces + 1;
               
            LET vdiasinver = (vfecha_venc - vfecha_alta);
            LET vsdopromedio = vcapital;
            LET vtasaperiodo = (((vtasa / 100) / vdiasanio) * vdiasinver);
            LET vtasaperiodoacum = vtasaperiodoacum + vtasaperiodo;
            
            -- // Coloca en el mes, el saldo promedio
            LET vmesini = MONTH(vfecha_alta);
            LET vmesfin = MONTH(vfecha_venc);
            
            IF YEAR(vfecha_alta)||LPAD(MONTH(vfecha_alta), 2, 0) >= pEjercicio||'01' THEN
                WHILE vmesini <= vmesfin
                    -- // Coloca en el mes, el saldo promedio
                    IF vmesini = 1 THEN
                        LET vsdoprom1 = vsdopromedio;
                    ELIF vmesini = 2 THEN
                        LET vsdoprom2 = vsdopromedio;
                    ELIF vmesini = 3 THEN
                        LET vsdoprom3 = vsdopromedio;
                    ELIF vmesini = 4 THEN
                        LET vsdoprom4 = vsdopromedio;
                    ELIF vmesini = 5 THEN
                        LET vsdoprom5 = vsdopromedio;
                    ELIF vmesini = 6 THEN
                        LET vsdoprom6 = vsdopromedio;
                    ELIF vmesini = 7 THEN
                        LET vsdoprom7 = vsdopromedio;
                    ELIF vmesini = 8 THEN
                        LET vsdoprom8 = vsdopromedio;
                    ELIF vmesini = 9 THEN
                        LET vsdoprom9 = vsdopromedio;
                    ELIF vmesini = 10 THEN
                        LET vsdoprom10 = vsdopromedio;
                    ELIF vmesini = 11 THEN
                        LET vsdoprom11 = vsdopromedio;
                    ELIF vmesini = 12 THEN
                        LET vsdoprom12 = vsdopromedio;
                    END IF
                    
                    LET vmesini = vmesini + 1;
                END WHILE
            ELSE
                LET vmesini = 1;
                
                WHILE vmesini <= vmesfin
                    -- // Coloca en el mes, el saldo promedio
                    IF vmesini = 1 THEN
                        LET vsdoprom1 = vsdopromedio;
                    ELIF vmesini = 2 THEN
                        LET vsdoprom2 = vsdopromedio;
                    ELIF vmesini = 3 THEN
                        LET vsdoprom3 = vsdopromedio;
                    ELIF vmesini = 4 THEN
                        LET vsdoprom4 = vsdopromedio;
                    ELIF vmesini = 5 THEN
                        LET vsdoprom5 = vsdopromedio;
                    ELIF vmesini = 6 THEN
                        LET vsdoprom6 = vsdopromedio;
                    ELIF vmesini = 7 THEN
                        LET vsdoprom7 = vsdopromedio;
                    ELIF vmesini = 8 THEN
                        LET vsdoprom8 = vsdopromedio;
                    ELIF vmesini = 9 THEN
                        LET vsdoprom9 = vsdopromedio;
                    ELIF vmesini = 10 THEN
                        LET vsdoprom10 = vsdopromedio;
                    ELIF vmesini = 11 THEN
                        LET vsdoprom11 = vsdopromedio;
                    ELIF vmesini = 12 THEN
                        LET vsdoprom12 = vsdopromedio;
                    END IF
                    
                    LET vmesini = vmesini + 1;
                END WHILE
            END IF;
            
            -- // INTERESES PAGADOS
            SELECT NVL(SUM(monto_tot), 0.00)
              INTO vinteres_pagado
              FROM bdinvers:sv_movhis
             WHERE empresa = '001'
               AND cuenta = vcuenta
               AND fech_alt BETWEEN ('0101' || pEjercicio) AND ('1231' || pEjercicio)
               AND fech_alt BETWEEN (vfecha_alta + 1 UNITS DAY) AND vfecha_venc 
               AND cancelad <> 'S'
               AND transacc = '0517';   

            LET vinteres_pagado_acum = vinteres_pagado_acum + vinteres_pagado;
                
            -- // ISR COBRADO
            SELECT NVL(SUM(monto_tot), 0.00)
              INTO vreten_interes
              FROM bdinvers:sv_movhis
             WHERE empresa = '001'
               AND cuenta = vcuenta
               AND fech_alt BETWEEN ('0101' || pEjercicio) AND ('1231' || pEjercicio)
               AND fech_alt BETWEEN (vfecha_alta + 1 UNITS DAY) AND vfecha_venc
               AND cancelad <> 'S'
               AND transacc = '0516'; 
               
            LET vreten_interes_acum = vreten_interes_acum + vreten_interes;
               
            -- // Ajuste por inflacion
            SELECT preciocontable
              INTO vinpcini
              FROM bdirepaut:sp_preciocontable
             WHERE moneda = '94'
               AND fecha = vfecha_alta - 1 UNITS DAY;

            SELECT preciocontable
              INTO vinpcfin
              FROM bdirepaut:sp_preciocontable
             WHERE moneda = '94'
               AND fecha = vfecha_venc; 

            -- // 2.1. Ajuste por inflacion
            LET vajuste_inflacion = (vinpcfin / vinpcini) - 1;
            
            --- IF vajuste_inflacion < 0 THEN
            ---     LET vajuste_inflacion = 0;
            --- END IF;
            
            LET vajuste_inflacion_acum = vajuste_inflacion_acum + vajuste_inflacion;
            
            -- // Interes Nominal Total
            LET vinteres_nominal_total = vinteres_pagado;
            LET vinteres_nominal_total_acum = vinteres_nominal_total_acum + vinteres_nominal_total;
                
            -- // INTERES NOMINAL EXCENTO
            IF vajuste_inflacion > 0 THEN
                LET vinteres_nominal_exento = vsdopromedio * vajuste_inflacion;
            ELSE
                LET vinteres_nominal_exento = 0.000000;
            END IF;
            
            LET vinteres_nominal_exento_acum = vinteres_nominal_exento_acum + vinteres_nominal_exento;
            
            LET vinteres_nominal_gravado = vinteres_nominal_total - vinteres_nominal_exento;
            
            IF vinteres_nominal_gravado < 0 THEN
                --- LET vperdida = vinteres_nominal_gravado * -1;
                LET vperdida = vinteres_nominal_gravado;
                LET vinteres_nominal_gravado = 0;
            ELSE
                LET vperdida = vinteres_nominal_gravado;
                LET vinteres_nominal_gravado = vinteres_nominal_gravado;
            END IF;
            
            LET vinteres_nominal_gravado_acum = vinteres_nominal_gravado_acum + vinteres_nominal_gravado;
            LET vperdida_acum = vperdida_acum + vperdida;
            
            LET vsecuencia = 0;
            LET vcapital = 0;
            LET vintereses = 0;
            LET visr = 0;
            LET vtasa = 0;
            LET vfecha_alta = '';
            LET vfecha_venc = '';
            LET vsdopromedio = 0;
            LET vtasaperiodo = 0;
            LET vinpcini = 0;
            LET vinpcfin = 0;
            LET vajuste_inflacion = 0;
            LET vperdida = 0;
            LET vdiasinver = 0;
            LET vmesini = 0;
            LET vmesfin = 0;
            LET vinteres_pagado = 0;
            LET vinteres_nominal_total = 0;
            LET vreten_interes = 0;
            LET vinteres_nominal_exento = 0;
            LET vinteres_nominal_gravado = 0;
        END FOREACH;
        
        LET vtasaperiodoacum = vtasaperiodoacum / vveces;
        LET vajuste_inflacion_acum = vajuste_inflacion_acum / vveces;
        
        IF vinteres_nominal_exento_acum > vinteres_nominal_total_acum THEN
            LET vinteres_nominal_gravado_acum = 0;
            --- LET vperdida_acum = vinteres_nominal_exento_acum - vinteres_nominal_total_acum;
            LET vperdida_acum = vperdida_acum;
        ELSE
            LET vperdida_acum = 0;
            LET vinteres_nominal_gravado_acum = vinteres_nominal_total_acum - vinteres_nominal_exento_acum;
        END IF;
        
        IF vperdida_acum < 0 THEN
            LET vperdida_acum = vperdida_acum * -1;
        END IF;
            
        IF vinteres_pagado_acum is null OR vinteres_pagado_acum < 0 THEN 
            LET vinteres_pagado_acum = 0.00;
        END IF;
        
        IF vinteres_nominal_exento_acum is null OR vinteres_nominal_exento_acum < 0 THEN 
            LET vinteres_nominal_exento_acum = 0.00;
        END IF;
        
        IF vinteres_nominal_gravado_acum is null OR vinteres_nominal_gravado_acum < 0 THEN 
            LET vinteres_nominal_gravado_acum = 0.00;
        END IF;
        
        IF vreten_interes_acum is null OR vreten_interes_acum < 0 THEN 
            LET vreten_interes_acum = 0.00;
        END IF;
        
        IF vinteres_nominal_total_acum is null OR vinteres_nominal_total_acum < 0 THEN 
            LET vinteres_nominal_total_acum = 0.00;
        END IF;
        
        IF vajuste_inflacion_acum is null OR vajuste_inflacion_acum < 0 THEN
            LET vajuste_inflacion_acum = 0.00;
        END IF;
        
        -- // SE GRABAN LOS DATOS TOTALES:
        INSERT INTO sc_retenisr
        (empresa, ejercicio, num_cte, cuenta, interes_pagado, interes_exento, interes_real, reten_interes,
         sdo_prom1, sdo_prom2, sdo_prom3, sdo_prom4, sdo_prom5, sdo_prom6, sdo_prom7, sdo_prom8, sdo_prom9, sdo_prom10, sdo_prom11, sdo_prom12,
         tasa_prom, perdida, ajuste_inflacion, ajuste_deflasion, interes_nominal_total, interes_nominal_exento, interes_nominal_gravado)
        VALUES 
        (pEmpresa, pEjercicio, vcliente, vcuenta, vinteres_pagado_acum, vinteres_nominal_exento_acum, vinteres_nominal_gravado_acum, vreten_interes_acum, 
         vsdoprom1, vsdoprom2, vsdoprom3, vsdoprom4, vsdoprom5, vsdoprom6, vsdoprom7, vsdoprom8, vsdoprom9, vsdoprom10, vsdoprom11, vsdoprom12, 
         vtasaperiodoacum, vperdida_acum, vajuste_inflacion_acum, 0.000000, vinteres_nominal_total_acum, vinteres_nominal_exento_acum, vinteres_nominal_gravado_acum);
             
        LET vcuantos = vcuantos + 1;
        LET vveces = 0;
        
        LET vcuenta = '';
        LET vcliente = '';
        LET vtasaperiodoacum = 0;
        LET vajuste_inflacion_acum = 0;
        LET vperdida_acum = 0;
        LET vsdoprom1 = 0.0;
        LET vsdoprom2 = 0.0;
        LET vsdoprom3 = 0.0;
        LET vsdoprom4 = 0.0;
        LET vsdoprom5 = 0.0;
        LET vsdoprom6 = 0.0;
        LET vsdoprom7 = 0.0;
        LET vsdoprom8 = 0.0;
        LET vsdoprom9 = 0.0;
        LET vsdoprom10 = 0.0;
        LET vsdoprom11 = 0.0;
        LET vsdoprom12 = 0.0;
        LET vinteres_pagado_acum = 0;
        LET vinteres_nominal_total_acum = 0;
        LET vreten_interes_acum = 0;
        LET vinteres_nominal_exento_acum = 0;
        LET vinteres_nominal_gravado_acum = 0;
    END FOREACH;
    
    RETURN '000', '', vcuantos;
    
    END;
    
END PROCEDURE 

DOCUMENT "Version: 1.00.000";

create procedure "informix".cons_dir_cte( pcliente char(20), pnum_regs smallint)
RETURNING char(5);

    DEFINE v_codret         char(5);
    DEFINE v_calle		    char(130);
    DEFINE v_numext	    	char(12);
    DEFINE v_numint       	char(12);
    DEFINE v_depto	      	char(6);
    DEFINE v_colonia       	char(65);
    DEFINE v_estado	   	    char(20);
    DEFINE v_obs	   	    char(80);   
    DEFINE v_entrecalles   	char(40);   
    DEFINE v_cp	   	        char(5);   
    DEFINE v_tel1   	    char(13);   
    DEFINE v_tel2   	    char(13);   
    DEFINE v_tel3   	    char(13);   
    DEFINE v_contador       smallint;
    DEFINE v_municipio	    char(50);	
    DEFINE sql_err,isam_err int;   

    LET v_codret     = "000";

    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN  v_codret;
        end if;
    end exception;

    -- set debug file to "/tmp/cons_dir_cte.out";
    -- trace on;
    
    -- // Valida la informacion de entrada
    IF pcliente is null then  
        LET v_codret = 110; 
        RETURN  v_codret;
    END IF;

    -- // Inicializar variables
    let v_contador = 0;
    
    -- // obtener registros de direcciones completas del cliente
    FOREACH
        select cal.nombrecalle as calle, dir.numeroextcalle, dir.numerointcalle, zon.nombrezona as colonia, dir.cod_postal, mun.nombre as municipio, edo.nombre as edo
          into v_calle, v_numext, v_numint, v_colonia, v_cp, v_municipio, v_estado	
          from bdinteg:si_direcciones_actual dir
          left outer join bdinteg:si_estados edo on ( edo.estado = dir.estado )
          left outer join bdinteg:si_catzonas zon on ( zon.numerociudad = dir.numerociudad and zon.numerocolonia = dir.numerocolonia )
          left outer join bdinteg:si_catcalles cal on ( cal.numerocalle = dir.numerocalle )
          left outer join bdinteg:si_municipios mun on ( mun.estado = dir.estado  and  mun.ciudad = dir.ciudad )
         where dir.numcte = pcliente

        LET v_contador = v_contador + 1;

        IF v_contador < pnum_regs THEN
            CONTINUE FOREACH;
        END IF;    

        INSERT INTO bdicheq:sc_direcTemp(calle, numext, numint, colonia, cp, municipio, estado)
        VALUES(v_calle, v_numext, v_numint, v_colonia, v_cp, v_municipio, v_estado);
    END FOREACH; 
    
    RETURN v_codret;

    END; 
    
END PROCEDURE;
CREATE PROCEDURE "informix".conisr_anual( pEmpresa CHAR(3), pEjercicio SMALLINT )
RETURNING VARCHAR(5),  -- CodigoRetorno
          VARCHAR(64), -- DescripcionError
          INTEGER,     -- Cantidad de registros
          INTEGER;     -- Cantidad de registros
    
    DEFINE cVarDataErr      VARCHAR(64);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE vCodRet          CHAR(5);
    DEFINE vcuantos         INTEGER;
    DEFINE vcuantos2        INTEGER;

    DEFINE vdiasanio        SMALLINT;
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vconmovhis       CHAR(10);
    DEFINE vconmovhisold    CHAR(10);
    DEFINE vcuenta          CHAR(20);
    DEFINE vcliente         CHAR(20);
    DEFINE vproducto		CHAR(4);
    DEFINE vacumsdopos      DECIMAL(18,6);
    DEFINE vdiasdopos       SMALLINT;
    DEFINE vfechaini        DATE;
    DEFINE vfechafin        DATE;
    DEFINE vtasa            CHAR(8);
    DEFINE vfechamax        CHAR(10);
    DEFINE vsaldoprom       DECIMAL(18,6);
    DEFINE vsdoprom1        DECIMAL(18,6);
    DEFINE vsdoprom2        DECIMAL(18,6);
    DEFINE vsdoprom3        DECIMAL(18,6);
    DEFINE vsdoprom4        DECIMAL(18,6);
    DEFINE vsdoprom5        DECIMAL(18,6);
    DEFINE vsdoprom6        DECIMAL(18,6);
    DEFINE vsdoprom7        DECIMAL(18,6);
    DEFINE vsdoprom8        DECIMAL(18,6);
    DEFINE vsdoprom9        DECIMAL(18,6);
    DEFINE vsdoprom10       DECIMAL(18,6);
    DEFINE vsdoprom11       DECIMAL(18,6);
    DEFINE vsdoprom12       DECIMAL(18,6);
    DEFINE vmes             CHAR(2);
    DEFINE vtotintpag       DECIMAL(18,6);
    DEFINE vtotintpagacum   DECIMAL(18,6);
    DEFINE vtasaprom        DECIMAL(9,6);
    DEFINE vtasapromedio    DECIMAL(9,6);
    DEFINE vtasapromanual   DECIMAL(9,6);
    DEFINE vinpc_ini        DECIMAL(9,6);
    DEFINE vinpc_fin        DECIMAL(9,6);
    DEFINE vajustexinf      DECIMAL(12,6);
    DEFINE vajustexinfacum  DECIMAL(12,6);
    DEFINE vintnomgrab	    DECIMAL(18,6);
    DEFINE vintnomgrabacum  DECIMAL(18,6);
    DEFINE vintnomext	    DECIMAL(18,6);
    DEFINE vintnomextacum   DECIMAL(18,6);
    DEFINE vperdida         DECIMAL(18,6);
    DEFINE vperdidacum      DECIMAL(18,6);
    DEFINE visretenido      DECIMAL(18,6);
    DEFINE vtotisrcobrado   DECIMAL(18,6);
    DEFINE vmeses           SMALLINT;
    DEFINE vctamin          CHAR(20);
    DEFINE vctamax          CHAR(20);
    DEFINE vfecha1          CHAR(10);
    DEFINE vfecha2          CHAR(10);
    DEFINE vfecha3          CHAR(10);
    DEFINE vfecha4          CHAR(10);

    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET vCodRet = '000';
    LET vcuantos = 0;
    LET vcuantos2 = 0;

    LET vdiasanio = 360;
    LET vmincta = '';
    LET vmaxcta = '';
    LET vconmovhis = '';
    LET vconmovhisold = '';
    LET vcuenta = '';
    LET vcliente = '';
    LET vproducto = '';
    LET vacumsdopos = 0;
    LET vdiasdopos = 0;
    LET vfechaini = '';
    LET vfechafin = '';
    LET vtasa = '';
    LET vfechamax = '';
    LET vsaldoprom = 0;
    LET vsdoprom1 = 0;
    LET vsdoprom2 = 0;
    LET vsdoprom3 = 0;
    LET vsdoprom4 = 0;
    LET vsdoprom5 = 0;
    LET vsdoprom6 = 0;
    LET vsdoprom7 = 0;
    LET vsdoprom8 = 0;
    LET vsdoprom9 = 0;
    LET vsdoprom10 = 0;
    LET vsdoprom11 = 0;
    LET vsdoprom12 = 0;
    LET vmes = '';
    LET vtotintpag = 0;
    LET vtotintpagacum = 0;
    LET vtasaprom = 0;
    LET vtasapromedio = 0;
    LET vtasapromanual = 0;
    LET vinpc_ini = 0;
    LET vinpc_fin = 0;
    LET vajustexinf = 0;
    LET vajustexinfacum = 0;
    LET vintnomgrab = 0;
    LET vintnomgrabacum = 0;
    LET vintnomext = 0;
    LET vintnomextacum = 0;
    LET vperdida = 0;
    LET vperdidacum = 0;
    LET visretenido = 0;
    LET vtotisrcobrado = 0;
    LET vmeses = 0;
    LET vctamin = '';
    LET vctamax = '';
    LET vfecha1 = '01/02/'||pEjercicio;
    LET vfecha2 = '12/31/'||pEjercicio;
    LET vfecha3 = '01/02/'||pEjercicio;
    LET vfecha4 = '01/01/'||pEjercicio + 1;

    BEGIN

    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET vCodret = iSqlErr;
            RETURN vCodret, cVarDataErr, NULL, NULL;
        END IF;
    END EXCEPTION;

    -- set debug file to "./conisr_anual.out";
    -- trace on;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Elimina los calculos anteriores para el periodo seleccionado
    TRUNCATE TABLE sc_retenisr;

	
    SELECT valor
      INTO vconmovhis
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vconmovhisold
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    -- // TABLAS DE TODAS LAS CUENTAS QUE TUVIERION PAGO DE INTERESES
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentasconints') THEN
        DROP TABLE cuentasconints;        
    END IF;
    
    CREATE TABLE cuentasconints( cuenta CHAR(20) NOT NULL ) IN dbssc_sdodiarioc03 
    EXTENT SIZE 1000000 NEXT SIZE 100000 LOCK MODE ROW;
    
    INSERT INTO cuentasconints
    SELECT {+INDEX(sc_movhis idx_movhisnew6)} cuenta
      FROM sc_movhis
     WHERE fech_alt BETWEEN vfecha1 AND vfecha2
	 --cuenta IN('10000006136','11000071279')
       AND fech_alt >= vconmovhis
       AND cancelad <> 'S'
       AND transacc = '3276';
       
    INSERT INTO cuentasconints
    SELECT {+INDEX(sc_movhis_old idx_movhisnew6_old)} cuenta
      FROM sc_movhis_old
     WHERE fech_alt BETWEEN vfecha1 AND vfecha2
	 --cuenta IN('10000006136','11000071279')
       AND fech_alt >= vconmovhisold
       AND fech_alt < vconmovhis
       AND cancelad <> 'S'
       AND transacc = '3276';
       
    CREATE INDEX idx_cuentaconint ON cuentasconints(cuenta) IN datos01_idx ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE cuentasconints;
	
    -- // TABLA DE CUENTAS UNICAS
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentasconintereses') THEN
        DROP TABLE cuentasconintereses;        
    END IF;
    
	
	select {+AVOID_FULL(bdicheq:sc_maehis)} DISTINCT  cuenta 
	From bdicheq:sc_maehis
	where year ( fechaini) = pEjercicio
	and dia_sdo_pos = 0 and empresa = '001'
	INTO TEMP tmp_sc_maehis;
	
    CREATE TABLE cuentasconintereses( cuenta CHAR(20) NOT NULL ) IN dbssc_sdodiarioc03
    EXTENT SIZE 100000 NEXT SIZE 10000 LOCK MODE ROW;	

    
    INSERT INTO cuentasconintereses
    SELECT UNIQUE cuenta
      FROM cuentasconints
	  WHERE CUENTA NOT IN(SELECT CUENTA FROM tmp_sc_maehis);
	  
	  
	  
	--WHERE cuenta not in('12000000068','12000000092','12000000211','12000000238','12000000246','12000000254',
	--'12000000327','12000000335','12000000424','12000000475','12000000521',
	--'12000000637','22000000071','22000000080','22000000098','22000000144',
	--'22000000322','22000000390','22000000543','22000000594','22000000713','22000001019');--SE AGREGAN ESTAS CUENTAS POR QUE EN ALGUNOS MESES NO TIENEN cum_sdo_pos, dia_sdo_pos 


	DROP TABLE tmp_sc_maehis;
  
    
    CREATE INDEX idx_cuentaconinteres ON cuentasconintereses(cuenta) in datos01_idx ONLINE;
   UPDATE STATISTICS MEDIUM FOR TABLE cuentasconintereses;
   
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vctamin, vctamax
      FROM cuentasconintereses;
    
    -- // Trae las cuentas de Cheques
    FOREACH
        SELECT cuenta
          INTO vcuenta
          FROM cuentasconintereses
         WHERE cuenta not in(select cuenta from sc_retenisr)
    
        -- // Calculos mensuales
        FOREACH
            SELECT {+INDEX(sc_maehis idx_maehis2)}
                   fechaini, fechafin, tasabruta, acum_sdo_pos, dia_sdo_pos, totintpag, totisrcobrado, num_cte, producto
              INTO vfechaini, vfechafin, vtasaprom, vacumsdopos, vdiasdopos, vtotintpag, visretenido, vcliente, vproducto
              FROM sc_maehis
             WHERE empresa = pEmpresa
               AND cuenta = vcuenta
               AND aniomes is not null
               AND fechafin BETWEEN vfecha3 AND vfecha4
             ORDER BY fechafin
             
            LET vsaldoprom = vacumsdopos / vdiasdopos;
             
            IF vfechafin >= vconmovhis THEN
                SELECT {+INDEX(sc_movhis idx_movhisnew4)} SUM(monto_tot)
                  INTO vtotintpag
                  FROM sc_movhis
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND ( fech_alt = vfechafin OR fech_alt = vfechafin - 1 units day OR fech_alt = vfechafin - 2 units day )
                   AND fech_alt >= vfecha1
                   AND fech_alt <= vfecha2
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                SELECT {+INDEX(sc_movhis idx_movhisnew4)} SUM(monto_tot)
                  INTO visretenido
                  FROM sc_movhis
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND ( fech_alt = vfechafin OR fech_alt = vfechafin - 1 units day OR fech_alt = vfechafin - 2 units day )
                   AND fech_alt >= vfecha1
                   AND fech_alt <= vfecha2
                   AND cancelad <> 'S'
                   AND transacc = '3277';
            ELIF vfechafin >= vconmovhisold AND vfechafin < vconmovhis THEN
                SELECT {+INDEX(sc_movhis_old movhis1)} SUM(monto_tot)
                  INTO vtotintpag
                  FROM sc_movhis_old
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND ( fech_alt = vfechafin OR fech_alt = vfechafin - 1 units day OR fech_alt = vfechafin - 2 units day )
                   AND fech_alt >= vfecha1
                   AND fech_alt <= vfecha2
                   AND cancelad <> 'S'
                   AND transacc = '3276';
                   
                SELECT {+INDEX(sc_movhis_old movhis1)} SUM(monto_tot)
                  INTO visretenido
                  FROM sc_movhis_old
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND ( fech_alt = vfechafin OR fech_alt = vfechafin - 1 units day OR fech_alt = vfechafin - 2 units day )
                   AND fech_alt >= vfecha1
                   AND fech_alt <= vfecha2
                   AND cancelad <> 'S'
                   AND transacc = '3277';
            END IF;
            
            IF vtotintpag is null THEN
                LET vtotintpag = 0.00;
            END IF;
            
            LET vtotintpagacum = vtotintpagacum + vtotintpag;
            
            IF visretenido is null THEN
                LET visretenido = 0.00;
            END IF;

            LET vtotisrcobrado = vtotisrcobrado + visretenido;

            LET vmeses = vmeses + 1;

            LET vmes = LPAD(MONTH(vfechafin), 2, '0');

            -- // Coloca en el mes, el saldo promedio
            IF   vmes = '01' THEN
                LET vsdoprom1 = vsaldoprom;
            ELIF vmes = '02' THEN
                LET vsdoprom2 = vsaldoprom;
            ELIF vmes = '03' THEN
                LET vsdoprom3 = vsaldoprom;
            ELIF vmes = '04' THEN
                LET vsdoprom4 = vsaldoprom;
            ELIF vmes = '05' THEN
                LET vsdoprom5 = vsaldoprom;
            ELIF vmes = '06' THEN
                LET vsdoprom6 = vsaldoprom;
            ELIF vmes = '07' THEN
                LET vsdoprom7 = vsaldoprom;
            ELIF vmes = '08' THEN
                LET vsdoprom8 = vsaldoprom;
            ELIF vmes = '09' THEN
                LET vsdoprom9 = vsaldoprom;
            ELIF vmes = '10' THEN
                LET vsdoprom10 = vsaldoprom;
            ELIF vmes = '11' THEN
                LET vsdoprom11 = vsaldoprom;
            ELIF vmes = '12' THEN
                LET vsdoprom12 = vsaldoprom;
            END IF;

            IF (vtasaprom is null) and (vproducto <> '1100') THEN
                SELECT tasa
                  INTO vtasa
                  FROM sc_producto
                 WHERE empresa = pEmpresa
                   AND producto = vproducto;

                SELECT MAX(fecha)
                  INTO vfechamax
                  FROM bdinteg:si_fechavalor
                 WHERE empresa = pEmpresa
                   AND tasa = vtasa
                   AND fecha <= vfechafin;

                SELECT NVL(valor, 0)
                  INTO vtasaprom
                  FROM bdinteg:si_fechavalor
                 WHERE empresa = pEmpresa
                   AND tasa = vtasa
                   AND fecha = vfechamax;
            END IF;

            -- // Calcula la tasa
            IF vtasaprom > 0.9 THEN
                LET vtasapromedio = (((vtasaprom / 100) / vdiasanio) * vdiasdopos);
            ELSE
                LET vtasapromedio = ((vtasaprom / vdiasanio) * vdiasdopos);
            END IF;

            LET vtasapromanual = vtasapromanual + vtasapromedio;

            SELECT preciocontable
              INTO vinpc_ini
              FROM bdirepaut:sp_preciocontable
             WHERE moneda = '94'
               AND fecha = vfechaini - 1 UNITS DAY;

            SELECT preciocontable
              INTO vinpc_fin
              FROM bdirepaut:sp_preciocontable
             WHERE moneda = '94'
               AND fecha = vfechafin;

            -- // FACTOR DE AJUSTE POR INFLACION
            LET vajustexinf = (vinpc_fin / vinpc_ini) - 1;

            --- IF vajustexinf < 0 THEN
            ---     LET vajustexinf = 0;
            --- END IF;

            LET vajustexinfacum = vajustexinfacum + vajustexinf;

            -- // INTERES NOMINAL EXCENTO
            IF vajustexinf > 0 THEN
                LET vintnomext = vsaldoprom * vajustexinf;
            ELSE
                LET vintnomext = 0.00;
            END IF;

            LET vintnomextacum = vintnomextacum + vintnomext;

            LET vintnomgrab = vtotintpag - vintnomext;

            IF vintnomgrab < 0 THEN
                --- LET vperdida = vintnomgrab * -1;
                LET vperdida = vintnomgrab;
                LET vintnomgrab = 0;
            ELSE
                LET vperdida = vintnomgrab;
                LET vintnomgrab = vintnomgrab;
            END IF;

            LET vintnomgrabacum = vintnomgrabacum + vintnomgrab;
            LET vperdidacum = vperdidacum + vperdida;

            LET vmes = '';
            LET vtotintpag = 0.00;
            LET visretenido  = 0.00;
            LET vtasaprom = 0;
            LET vacumsdopos = 0.00;
            LET vdiasdopos = 0;
            LET vfechaini = '';
            LET vfechafin = '';
            LET vsaldoprom = 0.00;
            LET vproducto = '';
            LET vtasa = '';
            LET vfechamax = '';
            LET vtasapromedio = 0;
            LET vinpc_ini = 0;
            LET vinpc_fin = 0;
            LET vajustexinf = 0;
            LET vintnomext = 0;
            LET vintnomgrab = 0;
            LET vperdida = 0;
        END FOREACH;

        IF vtotintpagacum > 0 THEN
            LET vtasapromanual = vtasapromanual / vmeses;
            LET vajustexinfacum = vajustexinfacum / vmeses;

            IF vintnomextacum > vtotintpagacum THEN
                LET vintnomgrabacum = 0;
                --- LET vperdidacum = vintnomextacum - vtotintpagacum;
                LET vperdidacum = vperdidacum;
            ELSE
                LET vintnomgrabacum = vtotintpagacum - vintnomextacum;
                LET vperdidacum = 0;
            END IF;

            IF vperdidacum < 0 THEN
                LET vperdidacum = vperdidacum * -1;
            END IF;

            IF vtotintpagacum is null OR vtotintpagacum < 0 THEN
                LET vtotintpagacum = 0.00;
            END IF;

            IF vintnomextacum is null OR vintnomextacum < 0 THEN
                LET vintnomextacum = 0.00;
            END IF;

            IF vintnomgrabacum is null OR vintnomgrabacum < 0 THEN
                LET vintnomgrabacum = 0.00;
            END IF;

            IF vtotisrcobrado is null OR vtotisrcobrado < 0 THEN
                LET vtotisrcobrado = 0.00;
            END IF;

            IF vajustexinfacum is null OR vajustexinfacum < 0 THEN
                LET vajustexinfacum = 0.00;
            END IF;

            INSERT INTO sc_retenisr
            (empresa, ejercicio, num_cte, cuenta, interes_pagado, interes_exento, interes_real, reten_interes,
             sdo_prom1, sdo_prom2, sdo_prom3, sdo_prom4, sdo_prom5, sdo_prom6, sdo_prom7, sdo_prom8, sdo_prom9, sdo_prom10, sdo_prom11, sdo_prom12,
             tasa_prom, perdida, ajuste_inflacion, ajuste_deflasion, interes_nominal_total, interes_nominal_exento, interes_nominal_gravado)
            VALUES
            (pEmpresa, pEjercicio, vcliente, vcuenta, vtotintpagacum, vintnomextacum, vintnomgrabacum, vtotisrcobrado,
             vsdoprom1, vsdoprom2, vsdoprom3, vsdoprom4, vsdoprom5, vsdoprom6, vsdoprom7, vsdoprom8, vsdoprom9, vsdoprom10, vsdoprom11, vsdoprom12,
             vtasapromanual, vperdidacum, vajustexinfacum, 0.000000, vtotintpagacum, vintnomextacum, vintnomgrabacum);
        END IF;

        LET vcuantos = vcuantos + 1;

        LET vcuenta  = '';
        LET vcliente = '';
        LET vproducto = '';
        LET vsdoprom1  = 0.0;
        LET vsdoprom2  = 0.0;
        LET vsdoprom3  = 0.0;
        LET vsdoprom4  = 0.0;
        LET vsdoprom5  = 0.0;
        LET vsdoprom6  = 0.0;
        LET vsdoprom7  = 0.0;
        LET vsdoprom8  = 0.0;
        LET vsdoprom9  = 0.0;
        LET vsdoprom10 = 0.0;
        LET vsdoprom11 = 0.0;
        LET vsdoprom12 = 0.0;
        LET vtotintpagacum  = 0.00;
        LET vintnomextacum  = 0.00;
        LET vintnomgrabacum = 0.00;
        LET vtotisrcobrado = 0.00;
        LET vtasapromanual = 0;
        LET vperdidacum = 0;
        LET vajustexinfacum = 0;
        LET vmeses = 0;
    END FOREACH;

    EXECUTE PROCEDURE coninvsr_anual(pEmpresa, pEjercicio)
   INTO vCodret, cVarDataErr, vcuantos2;

    RETURN vCodret, '', vcuantos, vcuantos2;

    END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_consultamovtosdiarioscta (pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicio CHAR(10), pFechaFin CHAR(10))

RETURNING  CHAR(5), INT8, DATE, VARCHAR(55), VARCHAR(40), CHAR(16), MONEY(14,2), MONEY(14,2), CHAR(1);

    DEFINE cCodRet 			CHAR(5);
    DEFINE iSqlErr			INTEGER;
    DEFINE cNumSerial		INT8;
    DEFINE iContador		INT8;
    DEFINE cFechAlt			DATE;
    DEFINE cTransaccion		VARCHAR(55);
    DEFINE cReferencia		VARCHAR(40);
    DEFINE cNumTarjeta		CHAR(16);
    DEFINE cNaturaleza		CHAR(1);
    DEFINE mMontoTot		MONEY(14,2);
    DEFINE cSdoCuenta		MONEY(14,2);
    DEFINE vconsmovhis      CHAR(10);
    DEFINE vconsmovhisold   CHAR(10);

    LET cCodRet 			= '00000';
    LET iSqlErr				= 0;
    LET cNumSerial			= 0;
    LET cFechAlt			= '01-01-1900';
    LET cTransaccion		= '';
    LET cReferencia			= '';
    LET cNumTarjeta			= '';
    LET mMontoTot			= '0.00';
    LET cSdoCuenta			= '0.00';
    LET cNaturaleza			= '';
    LET iContador			= 0;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet= iSqlErr;
            RETURN cCodRet,cNumSerial,cFechAlt,cTransaccion,cReferencia,cNumTarjeta,mMontoTot,cSdoCuenta,cNaturaleza;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/tmp/Antonio/sp_ConsultaMovtosDiariosCta.out";
    -- TRACE ON;

    IF pCuenta = '' OR  pEmpresa = '' OR pFechaInicio = '' OR pFechaFin = '' THEN
        LET cCodRet= '00001';
        RETURN cCodRet,cNumSerial,cFechAlt,cTransaccion,cReferencia,cNumTarjeta,mMontoTot,cSdoCuenta,cNaturaleza;
    END IF;
    
    SELECT valor
      INTO vconsmovhis
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vconsmovhisold
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    FOREACH 
        SELECT md.num_serial, md.fech_alt, TRIM(md.transacc)||' '||TRIM(tr.descripcion) AS transaccion,
               NVL(md.referencia,' ') referencia, NVL(md.num_tarjeta,' ') num_tarjeta, md.monto_tot, md.sdo_cuenta, tr.naturaleza
          INTO cNumSerial, cFechAlt, cTransaccion, cReferencia, cNumTarjeta, mMontoTot, cSdoCuenta, cNaturaleza
          FROM sc_movdia md, 
               bdinteg:si_transacc tr 
         WHERE md.empresa = pEmpresa 
           AND md.cuenta = pCuenta
           AND md.fech_alt BETWEEN pFechaInicio AND pFechaFin 
           AND md.cancelad <> 'S' 
           AND tr.empresa = md.empresa
           AND tr.numero = md.transacc
           AND tr.se_emite_edocta = 'S' 
           
        UNION ALL

        SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               mm.num_serial, mm.fech_alt, TRIM(mm.transacc)||' '||TRIM(tr.descripcion) AS transaccion,
               NVL(mm.referencia,' '), NVL(mm.num_tarjeta,' '), mm.monto_tot, mm.sdo_cuenta, tr.naturaleza 
          FROM sc_movhis mm, 
               bdinteg:si_transacc tr 
         WHERE mm.empresa = pEmpresa 
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaInicio AND pFechaFin 
           AND mm.fech_alt >= vconsmovhis
           AND mm.cancelad <> 'S' 
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc 
           AND tr.se_emite_edocta = 'S' 
           
        UNION ALL

        SELECT {+INDEX(bdicheq:sc_movhis_old movhis1)}
               mm.num_serial, mm.fech_alt, TRIM(mm.transacc)||' '||TRIM(tr.descripcion) AS transaccion,
               NVL(mm.referencia,' '), NVL(mm.num_tarjeta,' '), mm.monto_tot, mm.sdo_cuenta, tr.naturaleza 
          FROM sc_movhis_old mm, 
               bdinteg:si_transacc tr 
         WHERE mm.empresa = pEmpresa 
           AND mm.cuenta = pCuenta
           AND mm.fech_alt BETWEEN pFechaInicio AND pFechaFin 
           AND mm.fech_alt >= vconsmovhisold
           AND mm.fech_alt < vconsmovhis
           AND mm.cancelad <> 'S' 
           AND mm.transacc = tr.numero
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc 
           AND tr.se_emite_edocta = 'S' 
           
         ORDER BY 2 DESC, 1 DESC  

        LET iContador = iContador + 1;
        
        RETURN cCodRet,cNumSerial,cFechAlt,cTransaccion,cReferencia,cNumTarjeta,mMontoTot,cSdoCuenta,cNaturaleza WITH RESUME;
    END FOREACH;

    IF iContador = 0 THEN
        LET cCodRet = '00002';
        RETURN cCodRet,cNumSerial,cFechAlt,cTransaccion,cReferencia,cNumTarjeta,mMontoTot,cSdoCuenta,cNaturaleza WITH RESUME;
    END IF;

    END
    
END PROCEDURE

Document
'DESCRIPCION: Procedimiento que consulta la información de los movimientos históricos y diarios, con el fin de ',
'traer las transacciones realizadas dentro de un periodo.', 
'AUTOR: Antonio Bastidas',
'FECHA: 06/01/2010',
'VERSION: 20100106.1237',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_generaredoctaejedetalle(pEmpresa char(3), 
                                                       pCuenta CHAR(20), 
                                                       pFechaInicial DATE, 
                                                       pFechaFinal DATE)

RETURNING CHAR(5) AS CodRet, 
          CHAR(100) AS Descripcion, 
          MONEY(14,2) AS SaldoCuenta, 
          DATE AS FechaAlt, 
          MONEY(14,2) AS Deposito, 
          MONEY(14,2) AS Retiro;

    -- Elaborado por : Jose Almeida
    -- Fecha: 17-06-2009
    -- Obtener los detalles de los movimientos de las cuentas eje.
    -- Se modifico 20-07-2009
    -- Por José Almeida
    -- Se le sumó un dia a la variable vmesAnt.
    -- Modificó: Lorenzo Ibarra Garcia
    -- Fecha:03-08-2009
    -- *Se eliminó el parámetro de la fecha del mesiversario para que esta ya no se calcule internamente y se le mande la fecha de inicio
    --  y fin para traer los movimientos en ese rango.
    -- *Se eliminó el IF EXISTS que indicaba si existen movimientos ya que se sabrá con un contador de movimientos para saber si estos los hubo.
    -- *Se eliminó el parámetro de salida FechaEmisión.
    -- *Se eliminó la validación de si la cuenta existe en la tabla sc_maechq  y en la sc_maehis.

    DEFINE vSqlErr INTEGER;
    DEFINE vdescripcion CHAR(180);
    DEFINE vsdocuenta MONEY(14,2);
    DEFINE vfechealt DATE;
    DEFINE vdeposito MONEY(14,2);
    DEFINE vretiro MONEY(14,2);
    DEFINE vmesAnt DATE;
    DEFINE vcodret CHAR(5);
    DEFINE vcodRetspCortSig CHAR(6);
    DEFINE vreferencia CHAR(40);
    DEFINE vsucursal CHAR(50);
    DEFINE iTotalMovimientos INTEGER;
    DEFINE cFech_param      CHAR(10);
    DEFINE cFech_param_ini  CHAR(10);
    DEFINE vnum_serial INTEGER;

    LET vSqlErr = 0;
    LET vsucursal = "";
    LET vreferencia = "";
    LET vcodret = '000';
    LET vmesAnt = "";
    LET vdescripcion = "";
    LET vsdocuenta = 0;
    LET vfechealt = "";
    LET vdeposito = 0;
    LET vretiro = 0;
    LET vcodRetspCortSig = 0;    
    LET iTotalMovimientos = 0;

    -- set debug file to "/tmp/sp_generaredoctaejedetalle.out";
    -- trace on;

    BEGIN

    ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "./sp_generaredoctaejedetalle.err";
        TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    IF (pEmpresa IS NULL OR pCuenta IS NULL OR pFechaInicial IS NULL OR pFechaFinal IS NULL) THEN
        LET vcodret = '001'; -- // al menos un parametro es null
        RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
    ELSE
        SELECT valor
          INTO cFech_param
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'fechcon_movhis';
           
        SELECT valor
          INTO cFech_param_ini
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'FechIniCon_movhis_ol';
           
        FOREACH
            SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                   mov.num_serial, si.descripcion, mov.sdo_cuenta, mov.fech_alt, mov.referencia,
                   CASE WHEN si.naturaleza = 'C' THEN mov.monto_tot ELSE 0 END AS RETIRO,
                   CASE WHEN si.naturaleza IN ('A','R') THEN mov.monto_tot ELSE 0 END AS DEPOSITO,
                   CASE WHEN si.numero IN ('0202','0223') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||mov.fech_hor ELSE '' END AS Sucursal
              INTO vnum_serial, vdescripcion, vsdocuenta, vfechealt, vreferencia, vretiro, vdeposito, vsucursal
              FROM bdicheq:sc_movhis mov, 
                   bdinteg:si_transacc si, 
             OUTER bdinteg:si_sucursales su
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = pCuenta
               AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
               AND mov.fech_alt >= cFech_param
               AND mov.cancelad <> "S"
               AND mov.transacc = si.numero
               AND si.empresa = mov.empresa
               AND si.numero = mov.transacc
               AND si.se_emite_edocta = "S"
               AND si.naturaleza IN ('C', 'R', 'A')
               AND su.sucursal = mov.sucursal 
               AND su.empresa = mov.empresa
            UNION ALL
            SELECT {+INDEX(bdicheq:sc_movhis_old movhis1)}
                   mov.num_serial, si.descripcion, mov.sdo_cuenta, mov.fech_alt, mov.referencia,
                   CASE WHEN si.naturaleza = 'C' THEN mov.monto_tot ELSE 0  END AS RETIRO,
                   CASE WHEN si.naturaleza IN ('A','R') THEN mov.monto_tot ELSE 0 END  AS DEPOSITO,
                   CASE WHEN si.numero IN ('0202','0223') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||mov.fech_hor ELSE '' END AS Sucursal
              FROM bdicheq:sc_movhis_old mov, 
                   bdinteg:si_transacc si, 
             OUTER bdinteg:si_sucursales su
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = pCuenta
               AND mov.fech_alt BETWEEN pFechaInicial AND pFechaFinal
               AND mov.fech_alt >= cFech_param_ini
               AND mov.fech_alt < cFech_param
               AND mov.cancelad <> "S"
               AND mov.transacc = si.numero
               AND si.empresa = mov.empresa
               AND si.numero = mov.transacc
               AND si.se_emite_edocta = "S"
               AND si.naturaleza IN ('C', 'R', 'A')
               AND su.sucursal = mov.sucursal
               AND su.empresa = mov.empresa
             ORDER BY mov.fech_alt DESC, mov.num_serial DESC

            -- // sumar movimiento al contador
            LET iTotalMovimientos = iTotalMovimientos + 1;                            
            LET vdescripcion = NVL(TRIM(vdescripcion),'')||' '||NVL(TRIM(vsucursal),'')||' '||NVL(TRIM(vreferencia),'');
            
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro WITH RESUME;            
        END FOREACH;

        -- // preguntar sino hubo movimientos
        IF iTotalMovimientos = 0 THEN
            LET vcodret = '002';                
            LET vdescripcion = ' ';
            LET vsdocuenta = null;
            LET vfechealt = null;
            LET vdeposito = null;
            LET vretiro = null;
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
        END IF; 
        
    END IF;
    
    END;
    
END PROCEDURE;
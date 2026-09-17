CREATE PROCEDURE "informix".sp_prdcto_nvos_corresponsales(pEmpresa CHAR(3))
RETURNING CHAR(5);

    -- DECLARACIONES
    DEFINE fecha_anio       CHAR(4);
    DEFINE fecha_mes        CHAR(2);
    DEFINE primer_dia       DATE;
    DEFINE ultimo_dia       DATE;
    DEFINE fecha_aniomes    CHAR(6);
    DEFINE iCodRet          CHAR(5);
    DEFINE vexiste          INTEGER;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(200);
    DEFINE vsql2            CHAR(500);
    DEFINE vstmt2           CHAR(200);
    DEFINE dFech_alt        DATE;
    DEFINE cNum_tarjeta     CHAR(16);
    DEFINE cCuenta          CHAR(11);
    DEFINE cNaturaleza      CHAR(1);
    DEFINE cTransacc        CHAR(20);
    DEFINE cFolio_suc       CHAR(11);
    DEFINE iMonto_tot       DECIMAL(10, 2);
    DEFINE cNum_credito     CHAR(12);
    DEFINE iContador        INTEGER;
    DEFINE iComienza        SMALLINT;
    DEFINE iTransacc        SMALLINT;
    

    -- INICIALIZACIONES
    LET fecha_anio    = '';
    LET fecha_mes     = '';
    LET primer_dia    = '';
    LET ultimo_dia    = '';
    LET fecha_aniomes = '';
    LET iCodRet       = '00000';
    LET vexiste       = 0;
    LET vsql          = '';
    LET vstmt         = '';
    LET vsql2         = '';
    LET vstmt2        = '';
    LET dFech_alt     = '';
    LET cNum_tarjeta  = '';
    LET cCuenta       = '';
    LET cNaturaleza   = '';
    LET cTransacc     = '';
    LET cFolio_suc    = '';
    LET iMonto_tot    = 0.00;
    LET cNum_credito  = '';
    LET iContador     = 0;
    LET iComienza     = -1;
    LET iTransacc     = 0;

  BEGIN
      
    -- SET DEBUG FILE TO "/RESPALDOSNEW/Edbert_Bajo/SPs/sp_prdto_nvos_corresponsales/sp_prdcto_nvos_corresponsales.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- Extraer primer dia, ultimo dia y aniomes
    SELECT pri_dia_mes
    INTO primer_dia
    FROM sc_fechas
    WHERE empresa = pEmpresa;

    LET ultimo_dia = primer_dia - 1 UNITS DAY;
    LET primer_dia = primer_dia - 1 UNITS MONTH;
    LET fecha_anio = YEAR(primer_dia);
    LET fecha_mes  = MONTH(primer_dia);

    -- Hacer que fecha mes siempre tenga 2 digitos
    IF fecha_mes NOT IN ('10', '11', '12') THEN
      LET fecha_mes = '0' || fecha_mes;
    END IF;

    LET fecha_aniomes = fecha_anio || fecha_mes;

    -- Se limpia la tabla donde se guardan los registros a descargar
    TRUNCATE TABLE sc_mvtos_nvos_corresponsales;

    -- Se itera para descargar los registros de productos corresponsales captacion
    FOREACH WITH HOLD
      SELECT mov.fech_alt, mov.num_tarjeta, mov.cuenta, trx.naturaleza, mov.transacc, mov.folio_suc, mov.monto_tot
        INTO dFech_alt, cNum_tarjeta, cCuenta, cNaturaleza, cTransacc, cFolio_suc, iMonto_tot
        FROM sc_movhis mov,
             bdinteg:si_transacc trx
        WHERE mov.fech_alt BETWEEN primer_dia AND ultimo_dia
          AND mov.transacc IN ('0401', '0402', '0403', '0404', '0405', '0406', '0407')
          AND mov.cancelad <> 'S'
          AND mov.transacc = trx.numero

      -- ABRE LA TRANSACCION
      IF  (iComienza = -1) THEN
          LET iComienza = 0;
          LET iTransacc = 1;
          BEGIN WORK;
      END IF;

      -- Se insertan los valores de las variables en la tabla para el reporte
      INSERT INTO sc_mvtos_nvos_corresponsales 
      (fech_alt, num_tarjeta, cuenta, naturaleza, transacc, folio_suc, monto_tot)
      VALUES
      (dFech_alt, cNum_tarjeta, cCuenta, cNaturaleza, cTransacc, cFolio_suc, iMonto_tot);

      -- Se aumenta la variable contador en 1
      LET iContador = iContador + 1;

      -- Valida si contador es mayor o igual a mil
      IF (iContador >= 1000) THEN
        LET iContador = 0;
        COMMIT WORK;
        BEGIN WORK;
      END IF;

    END FOREACH;

    -- Se cierra la transaccion
    IF  iTransacc = 1 THEN
        LET iTransacc = 0;
        COMMIT WORK;
    END IF;

    -- Se crea archivo con una consulta dentro para que la pueda ejecutar el SISTEMA
    LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/movtos_nuevos_corresp_captacion_'||fecha_aniomes||'.unl SELECT * FROM sc_mvtos_nvos_corresponsales;" > /resplogifx/conciliachq/prdctonvoscorresponsales.sql';
    SYSTEM vsql;

    -- Se crea una consulta para que el SISTEMA ejecute el archivo creado
    LET vstmt = 'dbaccess bdicheq /resplogifx/conciliachq/prdctonvoscorresponsales.sql';
    SYSTEM vstmt;

    -- Se limpia la tabla donde se guardan los registros a descargar
    TRUNCATE TABLE sc_mvtos_nvos_corresponsales_cred;

    -- Se resetea el contador
    LET iContador = 0;

    -- Se resetea la transaccion
    LET iComienza = -1;

    -- Se itera para obtener los registros de productos corresponsales credito
    FOREACH WITH HOLD
      SELECT mov.fecha_mov, mov.nro_tarjeta, mov.num_credito, trx.naturaleza, mov.transacc_suc, mov.folio_suc, mov.monto
        INTO dFech_alt, cNum_tarjeta, cNum_credito, cNaturaleza, cTransacc, cFolio_suc, iMonto_tot
        FROM bdicred:sd_movhis mov,
             bdinteg:si_transacc trx
        WHERE mov.fecha_mov between primer_dia AND ultimo_dia
          AND ( ( mov.transacc_suc = '8104' AND mov.codigo_fun = '068' AND mov.codigo_ref = 1 ) OR
              ( mov.transacc_suc = '8105' AND mov.codigo_fun = '002' AND mov.codigo_ref = 109 ) OR
              ( mov.transacc_suc = '8106' ) OR
              ( mov.transacc_suc = '8112' ) )
          AND mov.reversado = 'N'
          AND mov.transacc_suc = trx.numero

      -- ABRE LA TRANSACCION
      IF  (iComienza = -1) THEN
          LET iComienza = 0;
          LET iTransacc = 1;
          BEGIN WORK;
      END IF;

      -- Se insertan los valores de las variables en la tabla para el reporte
      INSERT INTO sc_mvtos_nvos_corresponsales_cred 
      (fech_alt, num_tarjeta, num_credito, naturaleza, transacc, folio_suc, monto_tot)
      VALUES
      (dFech_alt, cNum_tarjeta, cNum_credito, cNaturaleza, cTransacc, cFolio_suc, iMonto_tot);

      -- Se aumenta la variable contador en 1
      LET iContador = iContador + 1;

      -- Valida si contador es mayor o igual a mil
      IF (iContador >= 1000) THEN
        LET iContador = 0;
        COMMIT WORK;
        BEGIN WORK;
      END IF;

    END FOREACH;

    -- Se cierra la transaccion
    IF  iTransacc = 1 THEN
        LET iTransacc = 0;
        COMMIT WORK;
    END IF;

    -- Se crea archivo con una consulta dentro para que la pueda ejecutar el SISTEMA
    LET vsql2 = 'echo "unload to /resplogifx/conciliachq/movtos_nuevos_corresp_credito_'||fecha_aniomes||'.unl SELECT * FROM sc_mvtos_nvos_corresponsales_cred;" > /resplogifx/conciliachq/prdctonvoscorresponsales2.sql';
    SYSTEM vsql2;

    -- Se crea una consulta para que el SISTEMA ejecute el archivo creado
    LET vstmt2 = 'dbaccess bdicheq /resplogifx/conciliachq/prdctonvoscorresponsales2.sql';
    SYSTEM vstmt2;

  END;

  RETURN iCodRet;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para generar archivos de corresponsales de captacion y credito',
'BD: bdicheq', 
'AUTOR: Edbert Alan Bajo Ruiz ',
'FECHA: Marzo 2025';

create procedure "informix".sp_cargo_val(pcuenta char(20))
returning char(5);
    
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vfecha_hoy       date;
    define vfecha_ant       date;
    define vfecha_proceso   date;
    define vstatus_cta      char(1);
    define vretiros         money(14,2);
    define vabonos          money(14,2);
    define vsdoactual       money(14,2);
    define vsdoinicial      money(14,2);
    define vsdoretenido     money(14,2);
    define vsdodisp         money(14,2);
    define vsdocalculado    money(14,2);
    define vdiferencia      money(14,2);
    define vreferencia      char(40);
    define vcuantos         smallint;
    define vproducto        char(4);
    define vcodretblq       char(5);
    define vclaveblq        char(5);
    define vstatus          char(1);
    
    let vcodret         = '00000';
    let vcodret2        = '';
    let vcodret3        = '';
    let vsqlerr         = 0;
    let visamerr        = 0;
    let vdescerr        = '';
    let vfecha_hoy      = '';
    let vfecha_ant      = '';
    let vfecha_proceso  = '';
    let vstatus_cta     = '';
    let vretiros 		= 0.00;
    let vabonos         = 0.00;
    let vsdoactual      = 0.00;
    let vsdoinicial     = 0.00;
    let vsdoretenido    = 0.00;
    let vsdodisp        = 0.00;
    let vsdocalculado   = 0.00;
    let vdiferencia     = 0.00;
    let vreferencia     = '';
    let vcuantos        = 0;
    let vproducto       = '';
    let vcodretblq      = '';
    let vclaveblq       = '';
    let vstatus         = '';
    
    begin
    
    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "/resplogifx/conciliachq/sp_cargo_val.err";
        trace on;
        if vsqlerr <> 0 then
            let vcodret  = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            return vcodret;
        end if
    end exception;
    
    --- set debug file to "/resplogifx/conciliachq/sp_cargo_val.out";
    --- trace on;
    
    --- set isolation to cursor stability;
    set isolation to dirty read;
    set lock mode to wait 3;

    --let vcodret = '00000';
    --return vcodret;	
    
    -- // VALIDA EL PARAMETRO DE ENTRADA
    if pcuenta = '' then
        let vcodret = '110';
        return vcodret;
    end if;
	
    -- // VALIDA CUENTAS EXCLUIDAS
    if pcuenta in('16000000080','16000000322','16000000012','99010000020', '16000000063') or 
       pcuenta in('10014594944','10029763610','10096982955','10101302909','10112587964','10121425535','10152230708','10290633686','10331870680',
                  '10349349235','13005759646','10426086994','10426817026','10430000557','10441560350','10442816048','10449170151','10449445150', '12000000823',
                  '12000002591', '16000000160', '16000000250', '22000002384', '99000000287', '99000000295', '99000000309', '99000000325', '99000000376',
                  '99000000449', '99000000457', '99000000465', '99000000473', '99000000481', '99000000490', '99000000520', '99010000030', '99010000048', 
                  '99010000056', '99010000064', '99010000080', '99010000110', '27000000138', '16000001531', '27000000103', '27000000111', '27000000146',
                  '27000000162', '27000000154', '27000000170','12000000114') then
        let vcodret = '00000';
        return vcodret;
    end if;

    -- // OBTIENE LAS FECHAS DEL SISTEMA
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant
      from sc_fechas
     where empresa = '001';
    
    -- // OBTIENE DATOS DE LA CUENTA
    select sdo_dia_ant, sdo_actual, sdo_retenido, status_cta, fecha_proceso, producto 
      into vsdoinicial, vsdoactual, vsdoretenido, vstatus_cta, vfecha_proceso, vproducto
      from sc_maechq
     where cuenta = pcuenta;
    
    /* ----------------------------
    if vproducto = '2900' then
        let vcodret = '00000';
        return vcodret;
    end if;	
    ---------------------------- */
	
	    -- // VALIDA CUENTAS ESPECIAL	
	if pcuenta = '10057557465' then
		insert into sc_cuentas_retiro 
            ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
            values
            ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
        let vcodret = '00000';
        return vcodret;	
	end if;
    
    -- // VALIDA LOS ESTATUS DE LA CUENTA
    if vstatus_cta IN('2','6') then
        let vcodret = '00000';
        return vcodret;
    end if; 
    
    if vstatus_cta in('1','3','5') then
        if vfecha_proceso is null or vfecha_proceso = "" then
            let vfecha_hoy = vfecha_hoy;
        else
            let vfecha_hoy = vfecha_proceso;
        end if;
    end if;
    
    -- // VALIDA ESTATUS DE LA CUENTA EN TABLA DE CONTROL
    select nvl(estatus,'')
      into vstatus
      from sc_cuentas_retiro
     where cuenta = pcuenta
       and fecha = vfecha_hoy;
       
    if vstatus = 'A' then
        let vcodret = '110';
        return vcodret;
    elif vstatus = 'R' then
        let vcodret = '00000';
        return vcodret;
    end if;
    
    -- // VALIDA QUE LA CUENTA NO ESTE INACTIVA
    select nvl(count(*),0)
      into vcuantos
      from sc_movdia
     where transacc in('0415','0416','3232')
       and cancelad <> 'S'
       and cuenta = pcuenta;
    
    if vcuantos > 0 then
        let vcodret = '00000';
        return vcodret;
    end if;   
    
    -- // OBTIENE EL MONTO DE CARGOS
    select nvl(sum(mov.monto_tot),0) 
      into vretiros
      from sc_movdia mov, 
           bdinteg:si_transacc trx
     where mov.cuenta = pcuenta
       and trx.naturaleza = 'C'
       and trx.se_contabiliza = 'S'
    ---and trx.se_emite_edocta = 'S'
       and mov.transacc = trx.numero
       and trx.sistema = '01'
       and mov.fech_alt = vfecha_hoy
       and mov.cancelad <> 'S'
       and mov.transacc <> '0232';
    
    -- // OBTIENE EL MONTO DE DEPOSITOS
    select nvl(sum(mov.monto_tot),0) 
      into vabonos
      from sc_movdia mov, 
           bdinteg:si_transacc trx
     where mov.cuenta = pcuenta
       and trx.naturaleza = 'A'
       and trx.se_contabiliza = 'S'
    ---and trx.se_emite_edocta = 'S'
       and mov.transacc = trx.numero
       and trx.sistema = '01'
       and mov.fech_alt = vfecha_hoy
       and mov.cancelad <> 'S';   
    
    -- // REALIZA LA CONCILIACION DE SALDOS DE LA CUENTA
    --- let vsdodisp = vsdoactual - vsdoretenido;
    let vsdodisp = vsdoactual;
    let vsdocalculado = vsdoinicial + vabonos - vretiros;
    
    if pcuenta in('22000001574', '99010000030') then
        let vdiferencia = vsdodisp - vsdocalculado;
        
        if vdiferencia < 0.00 then
            let vdiferencia = vdiferencia * -1;
        end if;
        
        if vdiferencia > 100000.00 then
            let vcodret = '110';
            
            insert into sc_cuentas_retiro 
            ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
            values
            ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
            
            execute procedure bloqueo_cta( '001', pcuenta, 0.00, '09', 3, vfecha_hoy, 'informix', '', '09', 'L', '02', 'C' )
            into vcodretblq, vclaveblq;
        else
            let vcodret = '00000';
        end if;
    else
        if vsdocalculado <> vsdodisp then
            let vcodret = '110';
            
            insert into sc_cuentas_retiro 
            ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
            values
            ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
            
            execute procedure bloqueo_cta( '001', pcuenta, 0.00, '09', 3, vfecha_hoy, 'informix', '', '09', 'L', '02', 'C' )
            into vcodretblq, vclaveblq;
        else
            let vcodret = '00000';
        end if;
    end if;
    
    -- // VALIDA DEPOSITOS SPEI
    select nvl(referencia,''), nvl(count(*),0)
      into vreferencia, vcuantos
      from sc_movdia
     where transacc = '0273'
       and cancelad <> 'S'
       and cuenta = pcuenta
     group by 1
    having count(*) > 1;
    
    if vcuantos > 1 then
        let vcodret = '110';
        
        insert into sc_cuentas_retiro 
        ( cuenta, fecha, saldo_inicial, abonos, retiros, saldo_calculado, saldo_actual, estatus, usuario )
        values
        ( pcuenta, vfecha_hoy, vsdoinicial, vabonos, vretiros, vsdocalculado, vsdodisp, 'A', '' );
        
        execute procedure bloqueo_cta( '001', pcuenta, 0.00, '09', 3, vfecha_hoy, 'informix', '', '09', 'L', '02', 'C' )
        into vcodretblq, vclaveblq;
    end if;
    
    return vcodret;
    
    end;
    
end procedure;
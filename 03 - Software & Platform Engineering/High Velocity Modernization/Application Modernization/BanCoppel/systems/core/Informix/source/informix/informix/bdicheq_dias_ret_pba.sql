create procedure "informix".dias_ret_pba(pempresa char(3), pdiaslib smallint)
RETURNING char(5);

    -- ******************************************************
    --                      dias_ret
    -- Version              1.0.0
    -- Obejtivo:            Liberacion documentos retenidos
    -- Creado por:
    -- ModIFicacion por:    Bancoppel
    -- Ultima ModIFicacion: 26 NOV 2009
    -- ******************************************************

    DEFINE vcuenta,vcta_cheques,vnum_cte                    char (20);
    DEFINE vreferencia,desc_err,vcodret3                    char(40);
    DEFINE vdias_ret                                        smallint;
    DEFINE sql_err,isam_err,vrowid                          integer;
    DEFINE vcodret,vcodret1,vcodret2                        char (5);
    DEFINE vplaza                                           char(3);
    DEFINE vsuccta,vsucursal                                char(4);
    DEFINE vusuario                                         char(8);
    DEFINE vfecha_alta,vfechoy                              date;
    DEFINE vfecha                                           date;
    DEFINE vcancelado                                       char(1);
    DEFINE vproducto,vtrandepsbc,vtranret,
           vtranlibsbc,vtranlibsbcTC,vtransuc,
           vtrancancta,vtrancanprov,vtrancapchq             char(4);
    DEFINE vsdo_actual,vmonto,vimpliberar,
           vimpmaxlib,vsdo_retenido,
           vcapital,vsdodisp,vmontoret,
           vtotcanc,vintprov                                money(14,2);
    DEFINE vfolsuc                                          char(16);
    DEFINE vdocto,vsolbcos                                  integer;
    DEFINE horax                                            datetime hour to fraction(3);
    DEFINE vcero                                            smallint;
    DEFINE vsecuencia,vdias_ori,vdifdias                    smallint;
    DEFINE vexiste, vabierto, vstatus                        char(1);
    DEFINE vmoneda,vsiglas,vsistema                         char(2);
    DEFINE vmensaje                                         char(80);
    DEFINE vnum_tarjeta                                     char(16);
    DEFINE vmaxsec                                          smallint;
    DEFINE vreferencia2                                     char(40);
    DEFINE vmonto1,vmonto2,vmonto3,
           vmonto4,vmonto5,vmonto6,
           vmonto7,vmonto8,vmonto9                          Money(14,2);
    DEFINE wSecuenciaPago                                   smallint;
    DEFINE vnum_credito                                     char(20);
    DEFINE vfechalta                                        date;
    DEFINE vcolateral                                       CHAR(1);
    DEFINE vstatus_cta                                      CHAR(1);
    DEFINE vmotivo                                          CHAR(2);
    DEFINE vtranlibctadev, vtranlibsbcA, vtranlibctadevA    CHAR(4);
    DEFINE vtranlibsbcTCA                                   CHAR(4);
    DEFINE vrowid1                                          int;
    DEFINE vrefnew                                          char(20);
    DEFINE vcvebconew                                       char(3);
    DEFINE vcomienza                                        INTEGER;
    DEFINE vexistechq                                       INTEGER;
    DEFINE vexistecta                                       CHAR(20);

    let pempresa = "001";
    let vabierto = "0";
    let vtransuc = "0000";
    let vdocto   = 0;
    let vcodret  = "000";
    let vcero    = 0;
    let vcuenta = "";
    let vcta_cheques = "";
    let vnum_cte = "";
    let vreferencia = "";
    let vdias_ret = 0;
    let vcodret1 = "";
    let vplaza  = "";
    let vsuccta = "";
    let vsucursal = "";
    let vusuario = "";
    let vfecha_alta = "";
    let vfechoy = "";
    let vfecha = "";
    let vcancelado = "";
    let vproducto = "";
    let vtrandepsbc = "";
    let vtranret = "";
    let vtranlibsbc = "";
    let vtranlibsbcTC = "";
    let vtranlibctadev = "";
    let vtransuc = "";
    let vtrancancta = "";
    let vtrancanprov = "";
    let vtrancapchq  = "";
    let vsdo_actual = 0;
    let vmonto = 0;
    let vimpliberar = 0;
    let vimpmaxlib = 0;
    let vsdo_retenido = 0;
    let vcapital = 0;
    let vsdodisp = 0;
    let vmontoret = 0;
    let vtotcanc = 0;
    let vintprov  = 0;
    let vfolsuc  = "";
    let vdocto = 0;
    let vsolbcos = 0;
    let horax  = "";
    let vsecuencia = 0;
    let vdias_ori = 0;
    let vdifdias = 0;
    let vexiste = "";
    let vabierto = "";
    let vstatus = "";
    let vmoneda = "";
    let vsiglas = "";
    let vsistema = "";
    let vmensaje = "";
    let vnum_tarjeta  = "";
    let vmaxsec = 0;
    let vreferencia2 = "";
    let wSecuenciaPago = 0;
    let vnum_credito = "";
    LET vcolateral   = "";
    LET vstatus_cta  = "";
    LET vmotivo      = "";
    let vtranlibsbcA = ""; 
    LET vtranlibctadevA = ""; 
    LET vtranlibsbcTCA= ""; 
    let vrowid = 0;
    let vrowid1 = 0;
    LET vrefnew = "";
    LET vcvebconew = "";
    LET vcomienza = -1;
    LET vexistechq = 0;
    LET vexistecta = '';

    --- set debug file to "/tmp/dias_ret.out";
    --- trace on;
    
    begin

    on exception set sql_err, isam_err, desc_err
        set debug file to "/tmp/dias_ret.err";
        trace on;
        if sql_err <> 0 then
            let vcodret = sql_err;
            let vcodret2 = isam_err;
            let vcodret3 = desc_err;
            if vabierto = "1" then
                rollback work;
            end if;
            return vcodret;
        end if;
    end exception;

    set isolation to dirty read;
    set lock mode to wait 16;

    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      into vfecha 
      from sc_fechas 
     where empresa = pempresa;

    -- // Valida no se halla realizado liberacion
    select {+ INDEX(sc_contproc idx_contproc2)} rowid, "1"
      into vrowid1, vexiste
      from sc_contproc
     where empresa = pempresa 
       and proceso = "docret" 
       and fecha = vfecha; 
       
    if vexiste = "1" then
        let vcodret = "971";
        return vcodret;
    end if

    select ejecutivo 
      into vusuario
      from bdinteg:si_ejecut
     where ejecutivo = user;

    select valor 
      into vtranlibsbc
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibsbc";

    let vtranlibsbcA = vtranlibsbc; 

    select valor 
      into vtranlibctadev
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibctadev";

    LET vtranlibctadevA = vtranlibctadev; 

    select valor 
      into vtranlibsbcTC
      from bdicred:sd_param
     where empresa = pempresa 
       and cod_param = "83";

    LET vtranlibsbcTCA = vtranlibsbcTC; 

    if weekday(vfecha) = 0 or weekday(vfecha) = 6 then
        update {+INDEX(sc_contproc idx_contproc2)} sc_contproc
           set fecha = vfecha
         where empresa = pempresa 
           and proceso = "docret"; 
           
        let vcodret = "000";
        return vcodret;
    end if

    select {+INDEX(bdinteg:si_feriado idx_feriado)} "1" 
      into vexiste
      from bdinteg:si_feriado
     where fecha = vfecha 
       and empresa = pempresa;
       
    if vexiste = "1" then
        update {+INDEX(sc_contproc idx_contproc2)} sc_contproc
           set fecha = vfecha
         where empresa = pempresa 
           and proceso = "docret";  
        
        let vcodret = "000";
        return vcodret;
    end if

    FOREACH WITH HOLD
        select {+INDEX(sc_docret idx_docret3)}
               rowid,cuenta,dias_ret,monto,folio_suc,cancelado,referencia,sucursal,num_chq,dias_ori,transacc,siglas, fecha_alta, banco, numcuenta
          into vrowid,vcuenta,vdias_ret,vmonto,vfolsuc,vcancelado,vreferencia,vsucursal,vdocto,vdias_ori,vtrandepsbc,vsiglas, vfechalta, vcvebconew, vrefnew
          from sc_docret
         where siglas in ('SC', 'SD')
           and fecha_alta < vfecha
           and cancelado = "T" 
           and transacc in('0250', '6250')
         order by siglas, dias_ret
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET vabierto = "1";
        END IF;

        LET vtranlibsbc    = vtranlibsbcA; 
        LET vtranlibctadev = vtranlibctadevA; 
        LET vtranlibsbcTC  = vtranlibsbcTCA; 
        
        --- LET vrefnew = vreferencia[6,25]; -- Se agrega para extraer los 20 digitos y no hacerlo en la consulta
        --- LET vrefnew = vrefnew;
        
        --- LET vrefnew = SUBSTR(vrefnew,10,11);
        --- LET vrefnew = vrefnew;
        
        --- LET vcvebconew = vreferencia[1,3]; -- Se agrega para extraer los 3 digitos de clave banco y no en la consulta
        --- LET vcvebconew = vcvebconew;

        -- // Valida si los Cheques a Liberar Fueron Presentados
        SELECT {+INDEX(bditef:cce_cheques_det cheques_det2)} 
               COUNT(*) 
          INTO vexistechq
          FROM bditef:cce_cheques_det
         WHERE empresa = pempresa
           AND cvebanco = vcvebconew
           AND numcuenta = vrefnew
           AND numcheque = vdocto
           AND fechapresenta <= vfecha
           AND monto = vmonto
           AND fecha_alta <= vfecha
           AND presentado = "1";

        IF vexistechq = 0 THEN
            continue foreach;
        END IF;

        let vdias_ret = vdias_ret - pdiaslib;
        let vdifdias = vdias_ori - vdias_ret;
        
        if vdias_ret < 1 then
            let vimpliberar = vmonto;
            let vstatus = "L";
        else
            let vimpliberar = 0;
        end if
        
        if vimpliberar > 0 then
        
            if vsiglas = "SC" then -- // Captacion

                select mc.sucursal, mc.producto, sdo_actual, mc.colateral, mc.status_cta, mc.motivo
                  into vsuccta, vproducto, vsdo_actual, vcolateral, vstatus_cta, vmotivo
                  from sc_maechq mc,
                       sc_producto pr
                 where mc.empresa = pempresa 
                   and mc.cuenta = vcuenta
                   and pr.empresa = mc.empresa 
                   and pr.producto = mc.producto;
                   
                /* ###########################
                select max(secuencia) 
                  into vmaxsec
                  from sc_tarjeta
                 where empresa = pempresa 
                   and cuenta = vcuenta 
                   and tipo_tarjeta = "T";
                   
                select num_tarjeta 
                  into vnum_tarjeta
                  from sc_tarjeta
                 where empresa = pempresa 
                   and cuenta = vcuenta 
                   and secuencia = vmaxsec;
                ########################### */

                -- // Para el caso de doctos devueltos en cuentas especiales, cambia la transaccion 
                IF vcolateral = "S" AND vstatus_cta = "3" AND vmotivo = "99" THEN 
                    /* ##########################################################################
                    IF EXISTS (SELECT {+INDEX(bditef:cce_cheques_dev idx_chqdev)} cta_deposito 
                                 FROM bditef:cce_cheques_dev
                                WHERE numcheque = vdocto
                                  AND lpad(trim(numcuenta),20,"0") = vreferencia[6,25]
                                  AND monto = vmonto
                                  AND fechapresenta >= vfechalta
                                  AND empresa = pempresa
                                  AND cvebanco = vreferencia[1,3]) THEN
                                  
                                  
                        LET vtranlibsbc = vtranlibctadev;
                    END IF
                    ########################################################################## */
                    
                    SELECT {+INDEX(bditef:cce_cheques_dev idx_chqdev)}
                           cta_deposito
                      INTO vexistecta
                      FROM bditef:cce_cheques_dev
                     WHERE numcheque = vdocto
                       AND numcuenta = vrefnew
                       AND monto = vmonto
                       AND fechapresenta >= vfechalta
                       AND empresa = pempresa
                       AND cvebanco = vcvebconew;
                       
                    IF vexistecta is not null OR vexistecta <> '' THEN
                        LET vtranlibsbc = vtranlibctadev;
                    END IF
                END IF

                insert into sc_movdia values 
                ( 0, vfolsuc, vsucursal, vusuario, vfecha, vfecha, current hour to fraction(3), vtranlibsbc, vsuccta, vproducto, pempresa, 
                  vcuenta, " ", vdocto, vimpliberar, vimpliberar, vcero, vcero, vcero, " ", " ", vsdo_actual, vtransuc, vreferencia, vcero, '', '');
                        
                update sc_maechq
                   set imp_chq_sbc = imp_chq_sbc - vimpliberar,
                       sdo_actual = sdo_actual + vimpliberar
                 where empresa = pempresa 
                   and cuenta = vcuenta;

                call cobintcomsbg(pempresa, vcuenta, vfolsuc, vusuario, vsucursal)
                returning vcodret1;
                
                IF vcodret1 = "000" THEN
                    update sc_docret
                       set cancelado = vstatus,
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                    where rowid = vrowid;
                --A.S.H.
                ELSE
                    update sc_docret
                       set cancelado = "A",
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                    where rowid = vrowid;
                --A.S.H. 
                END IF

            elif vsiglas = "SD" then -- // Credito

                -- // Ejecuta SPL Libera SBC Principalsbc
                -- // Requiere Datos del Banco y No de Cheque
                Select descripcion[1,19] 
                  Into vreferencia2
                  from bdinteg:si_bancos
                 Where banco = vreferencia[1,3];
                 
                If vreferencia2 Is NUll Then
                    Let vreferencia2 = "PAGO TDC S.B.C "||lpad(vdocto,7,'0');
                Else
                    Let vreferencia = vreferencia2;
                    Let vreferencia2 = vreferencia[1,15]||" "||lpad(vdocto,7,'0');
                End If
                
                -- // Valida la Sec de Pago para agregar al Folio la Secuencia
                SELECT num_credito 
                  INTO vnum_credito
                  FROM bdicred:sd_tarjeta
                 WHERE num_tarjeta = vcuenta;

                SELECT MAX(secuencia)
                  INTO wSecuenciaPago
                  FROM bdicred:sd_secpago
                 WHERE empresa = pEmpresa
                   AND num_credito = vnum_credito;
                   
                let vfolsuc = vfolsuc;
                
                IF (wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN
                    LET wSecuenciaPago = 1;
                ELSE
                    LET wSecuenciaPago = wSecuenciaPago + 1;
                END IF;

                LET vfolsuc = vfolsuc[1,14]||lpad(wSecuenciaPago::varchar(2),2,"0");
                
                call bdicred:principalrefer(pEmpresa, vcuenta, "01", vcuenta, vusuario, vsucursal, vfolsuc, vtranlibsbcTC, 0, vmonto, vreferencia2) 
                returning vcodret1, vmonto1, vmonto2, vmonto3, vmonto4, vmonto5, vmonto6, vmonto7, vmonto8, vmonto9;

                If vcodret1 = "000" Then
                    update sc_docret
                       set cancelado = vstatus,
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                    where rowid = vrowid;
                End if

            else

                select {+INDEX(bdinvers:sv_instrum idx_instrum)}
                       mv.sucursal, mv.cod_instrum, capital, plaza, secuencia, sdo_retenido, sdo_mes_ant, num_cte, moneda, capital
                  into vsuccta, vproducto, vsdo_actual, vplaza, vsecuencia, vsdo_retenido, vintprov, vnum_cte, vmoneda, vcapital
                  from bdinvers:sv_maeinv mv,
                       bdinvers:sv_instrum pr
                 where mv.empresa = pempresa 
                   and mv.cuenta = vcuenta 
                   and pr.cod_instrum = mv.cod_instrum
                   and pr.empresa = mv.empresa
                   and status_cta <> "4";
                   
                insert into bdinvers:sv_movdia values 
                ( pempresa, 0, vfolsuc, vplaza, vsucursal, vusuario, vfecha, current hour to fraction(3), vtranlibsbc, vsuccta, 
                  vcuenta, vsecuencia, vproducto, vcero, vimpliberar, vimpliberar, vcero, vcero, " ", vsdo_actual, vtransuc );

                update bdinvers:sv_maeinv
                   set sdo_retenido = sdo_retenido - vimpliberar
                 where empresa = pempresa 
                   and cuenta = vcuenta 
                   and secuencia = vsecuencia;
                   
                if vsdo_retenido = vimpliberar then
                    select valor 
                      into vtrancancta
                      from bdinvers:sv_param
                     where codparam = "trancancta" 
                       and empresa = pempresa;
                       
                    select valor 
                      into vtrancanprov
                      from bdinvers:sv_param
                     where codparam = "trancanprov" 
                       and empresa = pempresa;
                       
                    select importe, cta_cheques, sistema
                      into vtotcanc, vcta_cheques, vsistema
                      from bdinvers:sv_maeinstrucc
                     where empresa = pempresa 
                       and cuenta = vcuenta 
                       and cap_int = "C" 
                       and aplicado = "N";
                       
                    if vtotcanc is null then
                        let vtotcanc = 0;
                    end if
                    
                    if vtotcanc > 0 then
                        let vreferencia = "CANCELACION DE CERTIFICADO " || vcuenta || " POR DEVOLUCION DE CHEQUE";
                                      
                        select valor 
                          into vtrancapchq
                          from bdinvers:sv_param
                         where codparam = "trancapchq" 
                           and empresa = pempresa;
                           
                        if vsistema = "01" then
                            call abono_ref(pempresa,vsucursal,vusuario,vtrancapchq,"0000",vfolsuc,vcta_cheques,0,vtotcanc,vtotcanc,0,0,0,vmoneda,vreferencia) 
                            returning vcodret;
                        end if
                        
                        if vcodret <> "000" or vsistema <> "01" then
                            call bdibanco:sbsp_graba_solchq(pempresa,vnum_cte,vusuario,vtotcanc,vcuenta) 
                            returning vcodret,vmensaje,vsolbcos;
                        end if
                        
                        insert into bdinvers:sv_movdia values 
                        ( pempresa, 0, vfolsuc, vplaza, vsucursal, vusuario, vfecha, current hour to fraction(3), vtrancancta, 
                          vsuccta, vcuenta, vsecuencia, vproducto, 0, vtotcanc, vtotcanc, 0, 0, " ", vcapital, "0000");
                    end if
                    
                    if vintprov > 0 then
                        insert into bdinvers:sv_movdia values 
                        ( pempresa, 0, vfolsuc, vplaza, vsucursal, vusuario, vfecha, current hour to fraction(3), vtrancanprov,
                          vsuccta, vcuenta, vsecuencia, vproducto, 0, vintprov, vintprov, 0, 0, " ", vcapital, "0000" );
                    end if
                    
                    -- // Actualiza el Maestro de Inversiones
                    update bdinvers:sv_maeinv
                       set status_cta   = "2",
                           fec_cancelac = vfecha,
                           modificado   = vusuario,
                           fecha_mod    = vfecha
                     where empresa = pempresa 
                       and cuenta = vcuenta 
                       and secuencia = vsecuencia;
                       
                    update sc_docret
                       set cancelado = vstatus,
                           dias_ret = dias_ret - pdiaslib,
                           monto = monto - vimpliberar
                     where rowid = vrowid;
                end if
            end if

        else

            UPDATE sc_docret
               SET dias_ret = dias_ret - pdiaslib
            WHERE rowid = vrowid;

        end if
        
        IF vabierto = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
    end foreach
    
    update {+INDEX(sc_contproc idx_contproc2)} sc_contproc
       set fecha = vfecha
     where empresa = pempresa 
       and proceso = "docret"; 

    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
       
    return vcodret;

    end;

end procedure;
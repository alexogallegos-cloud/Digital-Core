CREATE procedure "informix".devotrobco2( pempresa char(3),
                                        psucursal char(4),
                                        pusuario char(8),
                                        ptransaccion char(4),
                                        pfolio char(16),
                                        pcuenta char(20),
                                        pnro_docto integer,
                                        pcausa_dev char(2),
                                        pimporte money(14,2),
                                        pbanco char(4),
                                        pmoneda char(2))
RETURNING char(5);

    -- ***************************************************************************
    -- devotrobco
    -- Version              1.0.0
    -- Obejtivo:            Devolucion otros bancos (compensacion CECOBAN)
    -- Creado por:
    -- ModIFicacion por:    AlejANDro Rueda Sanchez
    -- Ultima ModIFicacion: Septiembre-2008
    -- ModIFicacion por:    Bancoppel
    -- Ultima ModIFicacion: Diciembre 2009
    -- ***************************************************************************

    DEFINE vcodret                  char(5);
    DEFINE vcodret1                 char(5);
    DEFINE vfecha_hoy               date;
    DEFINE vstatus_cta              char(1);
    DEFINE vproducto                char(4);
    DEFINE sql_err                  integer;
    DEFINE vsdodisp,vmontoret       money(14,2);
    DEFINE vreferencia              char(40);
    DEFINE vrefer                   char(40);
    DEFINE btipoctarel              char(1);
    DEFINE vcta_col                 char(20);
    DEFINE vfechapresenta           date;
    DEFINE vexiste                  smallint;
    DEFINE vnumcuenta               char(20);
    DEFINE vnum_cte                 char(20);
    DEFINE vcve_banco               char(3);
    DEFINE vcuenta                  char(20);
    DEFINE vmonto                   money(14,2);
    DEFINE vfolsuc                  char(16);
    DEFINE vsucursal                char(4);
    DEFINE vdocto                   integer;
    DEFINE vsiglas                  char(2);
    DEFINE vrowid                   integer;
    define vfecha                   date;
    define vsuccta                  char(4);
    define vsigue                   char(1);
    define vfechaalta               date;
    DEFINE vtranlibsbc              char(4);     
    DEFINE vcero                    smallint;    
    DEFINE vsdo_actual              money(14,2); 
    DEFINE vtransuc                 char(4);     
    DEFINE v_trans_libprop          char(4);     
    define vusuario                 char(8);     
    Define vimpliberar              money(14,2); 
    Define vnum_tarjeta             char(16);    
    DEFINE vstatus_ctaCol           char(1);     
    DEFINE vsucctaCol               char(4);     
    DEFINE vnum_cteCol              char(20);    
    DEFINE vproductoCol             char(4);     
    DEFINE vsdo_actualCol           money(14,2); 
	DEFINE vcuenta_cheque           char(20); 
	DEFINE vfecha_ultimo_cheque     date; 
	define vfecha_operacion         date;
	

    LET vfechapresenta = " ";
    LET vexiste = 0;
    LET vnumcuenta = " ";
    LET vnum_cte = " ";
    LET vcve_banco = " ";
    LET vrefer = " ";
    LET vcuenta = " ";
    LET vsigue = "0";
    LET vfechaalta = " ";
    let vtranlibsbc = "";      
    let vcero    = 0;          
    let vsdo_actual = 0;       
    let vtransuc = "0000";     
    let vtransuc = "";         
    LET v_trans_libprop = "";  
    let vnum_tarjeta  = "";    
    LET vstatus_ctaCol = " ";  
    LET vsucctaCol     = " ";  
    LET vnum_cteCol    = " ";  
    LET vproductoCol   = " ";  
    LET vsdo_actualCol = 0;    
	LET vcuenta_cheque  = ""; 
	LET vfecha_ultimo_cheque = date(1); 
    LET vcodret = "000";
	LET vfecha_operacion = TODAY;

     --set debug file to "/informix/moha/devotrobco2.out";
     --trace on;
	
    begin
    
    on exception set sql_err
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            RETURN vcodret;
        END IF;
    END exception;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      into vfecha 
      from sc_fechas 
     where empresa = pempresa;

    IF psucursal = " " OR pusuario = " " OR pfolio = " " OR pcuenta = " " OR pimporte  = 0 OR pbanco = " " THEN
        LET vcodret = "110";
        RETURN vcodret;
    END IF;

    -- // Valida que Exista la Cuenta de Cheques
    SELECT status_cta, sucursal, num_cte, producto,sdo_actual
      INTO vstatus_cta, vsuccta, vnum_cte, vproducto, vsdo_actual
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta;

    IF vstatus_cta is null THEN
        LET vcodret = "100";
        RETURN vcodret;
    END IF;

    -- //Valida que la Cuenta no Este Cancelada
    IF vstatus_cta IN("2","6","7","8") THEN
        LET vcodret = "200";
        RETURN vcodret;
    END IF;

    -- // Obtener la transaccion de Abono de traspaso entre cuentas propias
    select valor
      into v_trans_libprop
      from bdicheq:sc_param
     where empresa = pempresa
       and codparam = "CGOSBCPROPIO";

    -- // Verifica si el tipo de cuenta es relacionada...
    SELECT {+INDEX(sc_colateral idx_colat1)}
           col.cta_col
      INTO vcta_col
      FROM sc_maechq mae, sc_colateral col
     WHERE mae.empresa = pempresa
       AND mae.cuenta = pcuenta
       AND mae.colateral = 'S'
       AND mae.status_cta = 3
       AND mae.motivo = '99'
       AND col.empresa = mae.empresa
       AND col.cuenta = mae.cuenta;

    IF vcta_col IS Not Null OR vcta_col <> "" THEN
        LET btipoctarel = "1";
    ELSE
        LET btipoctarel = "0";
    END IF;

    -- // Libera el documento, si es que esta retenido
    FOREACH
        Select /*rowid,*/ cuenta,monto,folio_suc,referencia,sucursal,num_chq,siglas,fecha_alta,numcuenta
          into /*vrowid,*/ vcuenta,vmonto,vfolsuc,vreferencia,vsucursal,vdocto,vsiglas,vfechaalta,vcuenta_cheque
          FROM sc_docret_sbc		--MOHA
         WHERE empresa = pempresa
           AND cuenta = pcuenta
           AND banco = pbanco
           AND num_chq = pnro_docto
           AND monto_ori = pimporte
           AND cancelado = "T"

        LET vrefer = vreferencia;

        -- // Valida si existe el registro en cheques devueltos
        let vexiste = 0;
        
        SELECT {+INDEX(bditef:cce_cheques_dev idx_chqdev)} 
               count(*) 
          INTO vexiste
          FROM bditef:cce_cheques_dev
         WHERE numcheque = pnro_docto
           AND numcuenta::INT8 = vcuenta_cheque::INT8
           AND monto = pimporte
           AND fechapresenta >= vfechaalta
           AND empresa = pempresa
           AND cvebanco = pbanco;

        IF  (vexiste > 0) THEN
            LET vsigue = "0";
            LET vcodret = "802"; -- // Se agrega codigo de retorno para indicar que SI EXISTE
        ELSE
            IF  vcuenta <> " " or vcuenta is not null or vcuenta <> "" THEN
                LET vsigue = "1";
            ELSE
                LET vsigue = "0";
                LET vcodret = "802"; -- // Se agrega codigo de retorno
            END IF;
            
            IF vsigue = "1" THEN 
			
                -- // Obtiene la fecha del ï¿½ltimo cheque --MOHA
                SELECT {+INDEX(bditef:cce_cheques_det idx_chqdet)}
                       MAX(fechapresenta)
                  INTO vfecha_ultimo_cheque
                  FROM bditef:cce_cheques_det
                 WHERE numcheque = pnro_docto
                   AND numcuenta::INT8 = vcuenta_cheque::INT8
                   AND monto = pimporte
                   AND presentado = "1"
                   AND fechapresenta <= vfecha;			

                -- // Valida si los Cheques a Liberar Fueron Presentados --MOHA
                SELECT {+INDEX(bditef:cce_cheques_det idx_chqdet)} 
                       fechapresenta, cvebanco, numcuenta
                  INTO vfechapresenta, vcve_banco, vnumcuenta
                  FROM bditef:cce_cheques_det
                 WHERE numcheque = pnro_docto
                   AND numcuenta::INT8 = vcuenta_cheque::INT8
                   AND monto = pimporte
                   AND presentado = "1"
                   AND fechapresenta = vfecha_ultimo_cheque;

                IF  (vnumcuenta is null) THEN
                    LET vsigue = "0";
                    LET vcodret = "802"; -- // Se agrega codigo de retorno para indicar que NO esta presentado 
                END IF;

                IF  vfechapresenta = " " or vfechapresenta is null THEN
                    let vfechapresenta = vfecha;
                END IF;

                IF btipoctarel <> "1" THEN
                    CALL diasretcta2(pempresa,pcuenta,pimporte,pnro_docto,pbanco, pusuario, "D") 
                    RETURNing vcodret;
                ELSE
                    -- // Obtiene la informacion de CuentaColateral
                    SELECT status_cta, sucursal, num_cte, producto,sdo_actual
                      INTO vstatus_ctaCol, vsucctaCol, vnum_cteCol, vproductoCol, vsdo_actualCol
                      FROM sc_maechq
                     WHERE empresa = pempresa
                       AND cuenta = vcta_col;

                    LET v_trans_libprop =  v_trans_libprop; 
                    LET vusuario = pusuario ; 	            
                    LET vimpliberar = pimporte;
                    LET pcuenta = vcta_col;
                    
                    insert into sc_movdia 
                    values(0, vfolsuc, vsucursal, vusuario, vfecha, vfecha, current hour to fraction(3),
                           v_trans_libprop, vsucctaCol, vproductoCol, pempresa, vcta_col, " ", pnro_docto,
                           vimpliberar, vimpliberar, vcero, vcero, vcero, " ", " ", vsdo_actualCol,
                           vtransuc, vrefer, vcero, vnum_tarjeta, "", "", vfecha_operacion);
                    
                    UPDATE sc_maechq 
                       SET sdo_actual = (sdo_actual - vimpliberar)
                     WHERE cuenta = pcuenta 
                       AND empresa = pempresa;

                END IF;
                
            ELSE
                LET vcodret = "802";
            END IF;
            
        END IF;
        
        EXIT FOREACH;
        
    END FOREACH;

    --- IF vcuenta <> " " or vcuenta is not null or vcuenta <> "" THEN
    IF vsigue = "1" THEN

        LET vreferencia = "CHQ. DEV. "||pnro_docto||" BANCO "||pbanco;
        
        IF btipoctarel <> "1" THEN
            { ********************************************************************
            -- // Aplica el cargo del importe SBC...
            CALL cargo_ref(pempresa,vsucursal,pusuario,ptransaccion,"0000",pfolio,
                           pcuenta,pnro_docto,pimporte,pmoneda,vreferencia,"","")
            RETURNING vcodret,ptransaccion,vfecha_hoy,vsdodisp,vmontoret;
            ********************************************************************* }
            
            -- // Inserta transacciï¿½n el el movdia
            insert into sc_movdia 
            values(0, pfolio, vsucursal, pusuario, vfecha, vfecha, current hour to fraction(3),
                   ptransaccion, vsuccta, vproducto, pempresa, pcuenta, pcausa_dev, pnro_docto,
                   pimporte, vcero, vcero, vcero, vcero, " ", vstatus_cta, vsdo_actual,
                   vtransuc, vrefer, vcero, vnum_tarjeta, "", "", vfecha_operacion);
        END IF;

        IF vcodret = "000" THEN
            CALL gencomtran(pempresa,pcuenta,ptransaccion,pfolio,pimporte,vsucursal,pusuario) 
            RETURNING vcodret;
            
            update sc_maechq
               set chq_dev_obco = chq_dev_obco + 1
             WHERE cuenta = pcuenta 
               AND empresa = pempresa;
               
            CALL cobintcomsbg(pempresa,pcuenta,pfolio,pusuario,vsucursal)
            RETURNING vcodret1;
        END IF;

        IF (vexiste = 0) THEN -- // Valida que no exista en bditef:cce_cheques_dev
            INSERT INTO bditef:cce_cheques_dev 
            values(pempresa, vcve_banco, vnumcuenta, pnro_docto,vfechapresenta, vnum_cte, 
                   pcuenta, pimporte, vsucursal, pcausa_dev, "000", pusuario, vfecha);
        END IF;
    ELSE
        LET vcodret = "802";
    END IF; 
    
    RETURN vcodret;
    
    END;
    
END procedure;
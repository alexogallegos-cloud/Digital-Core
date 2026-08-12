create procedure "informix".cons_dev_coppel_pba(
            pempresa    char(3),
            pfechadevo  char(10),
            pcuenta1    char(20),
            pcuenta2    char(20),
            ptrandev    char(4),
            ptrancom    char(4),
            ptraniva    char(4))
            RETURNING 
            char(5),        -- codret
            char(45),       -- sucursal
            char(100),      -- banco
            char(7),        -- nro cheque
            decimal(16,2),  -- importe
            decimal(8,2),   -- comision
            decimal(8,2),   -- iva
			char(45);       -- Motivodev
			

   DEFINE v_codret      char(5);
   DEFINE v_sucursal    char(45);   
   DEFINE v_banco       char(100);
   DEFINE v_numcheque   char(7);
   DEFINE v_importe     decimal(16,2);
   DEFINE v_com         decimal(8,2);   
   DEFINE v_iva         decimal(8,2);   
   DEFINE v_folio       char(16);   
   DEFINE v_motivodev   char(45);  
   DEFINE v_fechapaso   date;
    
   DEFINE sql_err,isam_err  int;   


-- v1.2 se usa el spl proporcionado por bancoppel
-- Grupo PISA - Eduardo Espinosa Ene 10


-- v1.1 se cambia el parametro pfechadevo de date
-- a char(10) por que crystal marca error en fechas
-- del 2010 usando spls como la fuente de datos
-- Grupo PISA - Eduardo Espinosa Ene 10


-- arma los datos para el reporte de las 
-- devoluciones cuenta coppel colateral
-- Grupo PISA - Eduardo Espinosa Sep 08
-- v1 version inicial



BEGIN
   on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
            v_importe,v_com,v_iva,v_motivodev;
            end if;
   end exception;


-- ****************************************************************************
-- cons_dev_coppel JYDG
-- ****************************************************************************


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    let v_codret        = "000";
    let v_sucursal      = " ";      
    let v_banco         = " ";
    let v_numcheque     = " ";        
    let v_importe       = 0;
    let v_com           = 0;   
    let v_iva           = 0;    
    let v_fechapaso     = pfechadevo;
	


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa    is null or
            pfechadevo  is null or
            pcuenta1    is null or
            pcuenta2    is null or
            ptrandev    is null or
            ptrancom    is null or
            ptraniva    is null then
    
        -- datos de entrada incompletos     
        LET v_codret = 110; 
        
        RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
                v_importe,v_com,v_iva,v_motivodev;
    END IF;


    
      


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************


    FOREACH

        -- consulta principal

        SELECT  c.sucursal || " " || s.nombre,
                c.cvebanco || ' ' || b.descripcion,
                c.numcheque,c.monto, c.motivo || ' ' || cdev.descripcion
        INTO    v_sucursal,v_banco,v_numcheque,v_importe, v_motivodev                 
        FROM    cce_cheques_dev c, bdinteg:si_bancos b,
                bdinteg:si_sucursales s, bdinteg:si_coddevcam cdev
        WHERE   c.empresa = pempresa
                and c.fecha_alta    = v_fechapaso 
                and c.cvebanco      = b.banco
                and c.sucursal      = s.sucursal
				and cdev.codigo     = c.motivo 
                and c.cta_deposito  = pcuenta2 --pcuenta1 lalo dic08
                order by 1

        let v_folio			="";

        -- las devoluciones quedan registradas en la cta2                
        -- buscar el folio de la dev en sc_movdia

      
        select  folio_suc
        into    v_folio
        from    bdicheq:sc_movdia
        where   empresa     = pempresa
        and     cuenta      = pcuenta2
        and     fech_alt    = v_fechapaso
        and     monto_tot   = v_importe
        and     num_cheq    = v_numcheque
        and     transacc    = ptrandev;
        
        
        IF v_folio <> ""  THEN
        
            -- importe de la comision
            select  monto_tot
            into    v_com
            from    bdicheq:sc_movdia
            where   empresa     = pempresa
            and     folio_suc   = v_folio
            and     transacc    = ptrancom;
            
            -- importe del iva
            select  monto_tot
            into    v_iva
            from    bdicheq:sc_movdia
            where   empresa     = pempresa
            and     folio_suc   = v_folio
            and     transacc    = ptraniva;   
        
        ELSE
        
            -- buscar el folio de la dev en sc_movhis
            
            select  folio_suc
            into    v_folio
            from    bdicheq:sc_movhis
            where   empresa     = pempresa
            and     cuenta      = pcuenta2
            and     fech_alt    = v_fechapaso
            and     monto_tot   = v_importe
            and     num_cheq    = v_numcheque
            and     transacc    = ptrandev;
        
        
            IF v_folio <> ""  THEN
            
                -- importe de la comision
                select  monto_tot
                into    v_com
                from    bdicheq:sc_movhis
                where   empresa     = pempresa
                and     folio_suc   = v_folio
                and     transacc    = ptrancom;
                
                -- importe del iva
                select  monto_tot
                into    v_iva
                from    bdicheq:sc_movhis
                where   empresa     = pempresa
                and     folio_suc   = v_folio
                and     transacc    = ptraniva;   
            
            END IF;    
            
        END IF; 


        RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
                v_importe,v_com,v_iva, v_motivodev
                WITH RESUME;

    END FOREACH     

END;    
END PROCEDURE
DOCUMENT
'MODIFICO :César Valdéz Figueroa',
'DESCRIPCION:  Este Procediemiento se modifico agregando un retorno de un campo  mas, el campo es motivo ',
'  			   de devolucion el cual lo conforma el motivo y la descripcion del motivo.',
'FECHA : SEPTIEMBRE de 2009',
'BD    : BDITEF',
'VERSION: 20090918.1037';

create procedure "informix".cons_presenta_pba(
            pempresa char(3),
            pfechapre char(10))
            RETURNING 
            char(5),char(100),char(11),char(7),
            decimal(16,2),char(45), char(20),
            char(100),char(1);

   DEFINE v_codret      char(5);
   DEFINE v_banco       char(100);
   DEFINE v_cuenta      char(11);
   DEFINE v_numcheque   char(7);
   DEFINE v_monto       decimal(16,2);
   DEFINE v_sucursal    char(45);
   DEFINE v_ctadeposito char(20);
   DEFINE v_nombrecte   char(100);
   DEFINE v_presentado  char(1);
   DEFINE v_numcte      char(20);
   DEFINE v_rfc         char(1);
   DEFINE v_curp        char(1);
   DEFINE v_fechapaso   date;

   DEFINE sql_err,isam_err  int;   

   DEFINE v_transacc    char(4);
   
   DEFINE v_trancheques char(4);
   DEFINE v_trancredito char(4);

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET v_fechapaso = pfechapre;


-- Permite ver los cheques presentados
-- Grupo PISA - Eduardo Espinosa Dic 07

-- v1.1 se agrega el manejo de SBC para TC LALO Ago 08



BEGIN
   on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
        let v_codret = sql_err;
    RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
        v_monto,v_sucursal,v_ctadeposito,
        v_nombrecte,v_presentado;
      end if;
   end exception;

set lock mode to wait 5;

   	--SET DEBUG FILE TO '/informix/cons_presenta.out';
	--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa is null or
            pfechapre is null then
    
        -- datos de entrada incompletos     
        LET v_codret = 110; 
        
        RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
                v_monto,v_sucursal,v_ctadeposito,
                v_nombrecte,v_presentado;
    END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    
    let v_banco         = " ";
    let v_cuenta        = " ";
    let v_numcheque     = " ";        
    let v_monto         = 0;
    let v_sucursal      = " ";   
    let v_ctadeposito   = " ";        
    let v_nombrecte     = " ";
    let v_presentado    = " ";


    -- obtener transacciones 
    -- cheques
    
    select  {+INDEX(bdinteg:si_transacc idx_transacc1)} numero
    into    v_trancheques
    from    bdinteg:si_transacc
    where   empresa = pempresa
	and     numero > "0000"
    and     abreviatura = "DEPLOCALREGCC";
    
    IF v_trancheques is null THEN
        -- no existe el cliente
        LET v_codret = 193; 
        RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
                v_monto,v_sucursal,v_ctadeposito,
                v_nombrecte,v_presentado;
    END IF;        
   
    -- credito
    select  {+INDEX(bdinteg:si_transacc idx_transacc1)} numero
    into    v_trancredito
    from    bdinteg:si_transacc
    where   empresa = pempresa
	and     numero > "0000"
    and     abreviatura = "PAGOTCSBC";
    
    IF v_trancredito is null THEN
        -- no existe el cliente
        LET v_codret = 194; 
        RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
                v_monto,v_sucursal,v_ctadeposito,
                v_nombrecte,v_presentado;
    END IF;  





-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH

        -- consulta principal

        SELECT  unique c.cvebanco || ' ' || b.descripcion,
                c.numcuenta,c.numcheque,c.monto,
                d.sucursal || " " || s.nombre, d.cuenta,
                c.presentado,d.transacc
        INTO    v_banco,v_cuenta,v_numcheque,v_monto,v_sucursal,
                v_ctadeposito,v_presentado, v_transacc                   
        FROM    cce_cheques_det c, bdinteg:si_bancos b,
                bdicheq:sc_docret_sbc d, bdinteg:si_sucursales s   --MOHA
        WHERE   c.empresa = pempresa
                and c.fechapresenta = v_fechapaso 
                and c.cvebanco = b.banco
                and d.numcuenta::INT8 = c.numcuenta::INT8
                and d.num_chq = c.numcheque::INTEGER
                and d.fecha_alta=c.fecha_alta
                and d.monto_ori=c.monto
                and d.sucursal=s.sucursal
                and d.transacc in 
                (select transacc from bditef:cce_mapeo_cecoban)
	                
                
        -- obtener el nro de cliente segun transaccion sc_docret
      
        -- de cheques 0250
        IF v_transacc = v_trancheques THEN
            select  num_cte
            into    v_numcte
            from    bdicheq:sc_maechq
            where   empresa = pempresa
            and     cuenta = v_ctadeposito;
        END IF;
        
        
        -- de credito 6250
        IF v_transacc = v_trancredito THEN
            select  numcte
            into    v_numcte
            from    bdicred:sd_tarjeta
            where   empresa     = pempresa
            and     num_tarjeta = v_ctadeposito;
        END IF;    
      
        

        IF v_numcte is null or v_numcte = "" THEN
            -- no existe el cliente
            LET v_codret = 195; 
            RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
                    v_monto,v_sucursal,v_ctadeposito,
                    v_nombrecte,v_presentado;
        END IF;


        -- obtener el nombre o razon social del cliente
        
        call consnomcte(pempresa,v_numcte)
              returning v_codret,v_nombrecte,v_rfc,v_curp;      
 

        RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
            v_monto,v_sucursal,v_ctadeposito,
            trim(v_numcte) || " " || v_nombrecte,v_presentado
        WITH RESUME;

    END FOREACH     

END;    
END PROCEDURE;
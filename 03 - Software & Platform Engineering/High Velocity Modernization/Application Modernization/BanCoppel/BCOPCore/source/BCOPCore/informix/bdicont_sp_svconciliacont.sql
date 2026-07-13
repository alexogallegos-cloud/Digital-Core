CREATE PROCEDURE "informix".sp_svconciliacont(
                pempresa    char(3),
                pfecha      date,
                pusuario    char(8))
                RETURNING 
                char(5),        -- codret
                varchar(40);    -- mensaje

    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE vcodret      char(5);
    DEFINE vmsg         varchar(40);  
    
    DEFINE vsistema     char(2);
    DEFINE vtotmonto    money(22,2);
    DEFINE vsucursal    char(4);
    DEFINE vtransacc    char(4);
    DEFINE vproducto    char(4);
    DEFINE vsecuencia   integer;
    DEFINE vmoneda      char(2);
    DEFINE vnuminvers   char(20);
    
    DEFINE vcmayor,vc1,vc2,vc3, 
           vc4,vcsector char(10);
    DEFINE vamayor,va1,va2,va3, 
           va4,vasector char(10);

    DEFINE vexiste      char(1);
  
    

--set debug file to "/pisa/pisabanco/pisa_ftes/laloinver/conta.txt";
--trace on;    
    
   
BEGIN

    -- v1.1 se agrego una tabla temporal para recuperar el 
    -- unique del nro inversion LALO dic08

    -- v1 version inicial LALO oct08

    ON EXCEPTION SET sql_err,isam_err
    IF sql_err <> 0 OR isam_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret,vmsg;
    END IF;
    END EXCEPTION;


    -- Valida la informacion de entrada

    IF  pempresa IS NULL THEN
        LET vcodret = 110;
        LET vmsg    = "DATOS ENTRADA INCOMPLETOS";
        RETURN vcodret,vmsg;
    END IF;


    -- valores iniciales
    
    LET vcodret     = "000";
    LET vmsg        = "";
    LET vtotmonto   = 0;


    -- sistema
    SELECT  sistema
    INTO    vsistema
    FROM    bdinteg:si_sistema
    WHERE   siglas="SV";
    
    
    IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
        LET vcodret = 120;
        LET vmsg    = "SI_SISTEMA INVERSIONES NO EXISTE";
        RETURN vcodret,vmsg;
    END IF    



    -- limpiar los datos del dia
    delete from bdicont:co_conciliamovs
    where   empresa     = pempresa
    and     sistema     = vsistema
    and     fecha       = pfecha;
    
    
    
    -- crear temportal
    select unique cuenta,plazo 
    from bdinvers:sv_maeinv 
    into temp tempinvers;
       
    
    FOREACH -- MOVIMIENTOS Y TRANSACCIONES DEL SV_MOVDIA
    
        SELECT  sum(hist.monto_tot),hist.sucursal,hist.transacc,
                hist.cod_instrum,pt.secuencia,i.moneda,ma.cuenta
        INTO    vtotmonto,vsucursal,vtransacc,
                vproducto,vsecuencia,vmoneda,vnuminvers    
        FROM    bdinvers:sv_movhis hist,tempinvers ma,
                bdinvers:sv_plazotasa pt,bdinvers:sv_instrum i,
                bdinteg:si_transacc sitran
        WHERE   hist.empresa    =  pempresa
        AND     hist.cuenta     =  ma.cuenta
        AND     hist.fech_alt   = pfecha
        AND     (hist.plaza=pt.plaza and ma.plazo between pt.plazo_min and pt.plazo_max)
        AND     hist.cancelad   <> "S"
        AND     hist.cod_instrum = i.cod_instrum
        AND     sitran.empresa = pempresa        
        AND     sitran.numero   = hist.transacc
        AND     sitran.sistema  = vsistema
        AND     sitran.se_contabiliza="S"
        GROUP BY 2,3,4,5,6,7
        ORDER BY 2,3

        
        -- obtener las ctas contables 
        
        SELECT  c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,
                c_ccssssub,c_sector,
                a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,
                a_ccssssub,a_sector
        INTO    vcmayor,vc1,vc2,vc3,
                vc4,vcsector,
                vamayor,va1,va2,va3,
                va4,vasector                
        FROM    bdinteg:si_prodtran
        WHERE   empresa      = pempresa
        AND     producto     = vproducto
        AND     sistema      = vsistema
        AND     transaccion  = vtransacc
        AND     secuencia    = vsecuencia;


        IF dbinfo("sqlca.sqlerrd2") <> 0 THEN 
        
            -- verificar si existe
            -- el registro con D
            
            SELECT      "1"
            INTO        vexiste
            FROM        bdicont:co_conciliamovs
            WHERE       empresa     = pempresa
            AND         sistema     = vsistema
            AND         fecha       = pfecha
            AND         transac     = vtransacc
            AND         ccmayor     = vcmayor
            AND         ccsub       = vc1
            AND         ccsubsub    = vc2
            AND         ccssubsub   = vc3
            AND         ccsssubsub  = vc4
            AND         sector      = vcsector
            AND         sucursal    = vsucursal
            AND         moneda      = vmoneda
            AND         naturaleza  = "D"
            AND         producto    = vproducto;
            
            
            IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
            
                -- grabar el registro en la tabla de conta DEBITO
                INSERT INTO bdicont:co_conciliamovs (empresa,sistema,fecha,
                            transac,ccmayor,ccsub,ccsubsub,ccssubsub,
                            ccsssubsub,sector,sucursal,moneda,naturaleza,
                            producto,monto,usuario_alta,fecha_alta) 
                VALUES      (pempresa,vsistema,pfecha,vtransacc,vcmayor,
                            vc1,vc2,vc3,vc4,
                            vcsector,vsucursal,vmoneda,'D',vproducto,
                            vtotmonto,pusuario,today);
                            
            ELSE
            
                -- sumar
                
                UPDATE      bdicont:co_conciliamovs
                SET         monto = monto + vtotmonto
                WHERE       empresa     = pempresa
                AND         sistema     = vsistema
                AND         fecha       = pfecha
                AND         transac     = vtransacc
                AND         ccmayor     = vcmayor
                AND         ccsub       = vc1
                AND         ccsubsub    = vc2
                AND         ccssubsub   = vc3
                AND         ccsssubsub  = vc4
                AND         sector      = vcsector
                AND         sucursal    = vsucursal
                AND         moneda      = vmoneda
                AND         naturaleza  = "D"
                AND         producto    = vproducto;  
                              
            END IF
                            

            -- verificar si existe
            -- el registro con C
            
            SELECT      "1"
            INTO        vexiste
            FROM        bdicont:co_conciliamovs
            WHERE       empresa     = pempresa
            AND         sistema     = vsistema
            AND         fecha       = pfecha
            AND         transac     = vtransacc
            AND         ccmayor     = vamayor
            AND         ccsub       = va1
            AND         ccsubsub    = va2
            AND         ccssubsub   = va3
            AND         ccsssubsub  = va4
            AND         sector      = vasector
            AND         sucursal    = vsucursal
            AND         moneda      = vmoneda
            AND         naturaleza  = "C"
            AND         producto    = vproducto;
            
            
            IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
        
                -- grabar el registro en la tabla de conta CREDITO
                INSERT INTO bdicont:co_conciliamovs (empresa,sistema,fecha,
                            transac,ccmayor,ccsub,ccsubsub,ccssubsub,
                            ccsssubsub,sector,sucursal,moneda,naturaleza,
                            producto,monto,usuario_alta,fecha_alta) 
                VALUES      (pempresa,vsistema,pfecha,vtransacc,vamayor,
                            va1,va2,va3,va4,
                            vasector,vsucursal,vmoneda,'C',vproducto,
                            vtotmonto,pusuario,today);  
            
            ELSE
            
                -- sumar
            
                UPDATE      bdicont:co_conciliamovs
                SET         monto = monto + vtotmonto
                WHERE       empresa     = pempresa
                AND         sistema     = vsistema
                AND         fecha       = pfecha
                AND         transac     = vtransacc
                AND         ccmayor     = vamayor
                AND         ccsub       = va1
                AND         ccsubsub    = va2
                AND         ccssubsub   = va3
                AND         ccsssubsub  = va4
                AND         sector      = vasector
                AND         sucursal    = vsucursal
                AND         moneda      = vmoneda
                AND         naturaleza  = "C"
                AND         producto    = vproducto;  
                              
            END IF            
        
        ELSE
        
            LET vmsg ="ALGUNA CTA EN SI_PRODTRAN NO EXISTE";
            
        END IF       
    
    
    END FOREACH -- MOVIMIENTOS Y TRANSACCIONES DEL SV_MOVDIA

    IF  vtotmonto = 0 THEN 
        LET vcodret = "130";
        LET vmsg    = "NO EXISTEN MOVIMIENTOS PARA ESTE DIA";    
        RETURN vcodret,vmsg;
    END IF   
    
    DROP TABLE tempinvers;

RETURN vcodret,vmsg;
END;
END PROCEDURE;
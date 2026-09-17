create procedure "informix".abono_cta (pempresa    char(3),
                            pcuenta     char(20),
                            pnrocheque  integer,
                            pimporte    decimal(16,2),
                            pmoneda     char(2),
                            pusuario    char(8))
       returning    char(5),
                    char(35);   --msg 


    -- v1.0 version inicial
    -- abona el monto del cheque por reverso cod 47
    -- abono el monto por devolucion forzada
    -- abono el monto por validacion imagenes
    -- eduardo espinosa oct09

                    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vmsg         char(35);
    define vfecha       date; 
    
    define vsucursal    char(4);   
    define vfolio       char(16);
    define vtran_abono  char(4);

	define vreferencia      char(40);
    
    let vcodret     = "000";
    let vmsg        = "";
    
    
    
--set debug file to "/pisa/pisabanco/pisa_ftes/cecoban/abono_cta.txt";
--trace on;
        
begin
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vmsg;
        end if
    end exception;
    

    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null 
        or pnrocheque = "" or pnrocheque < 1 then
            let vcodret = "100";
            let vmsg    = "datos de entrada incompletos";
            return vcodret,vmsg;
    end if



    -- cargar todos los parametros valores y transacciones
    
    select  fecha_hoy
    into    vfecha
    from    bdicheq:sc_fechas;

    -- sucursal de la cta
    
    select  sucursal
    into    vsucursal
    from    bdicheq:sc_maechq
    where   cuenta  = pcuenta;
    
    if dbinfo("sqlca.sqlerrd2") = 0 then
            let vcodret = "101";
            let vmsg = "no existe la cuenta";
            return vcodret,vmsg;
    end if          

    
    -- tran abono normal
    
    select  valor
    into    vtran_abono
    from    cce_param, bdinteg:si_transacc
    where   valor = numero
    and     cod_param=12;
    
    if dbinfo("sqlca.sqlerrd2") = 0 then
            let vcodret = "102";
            let vmsg = "tran abono no existe";
            return vcodret,vmsg;
    end if  

    let vfolio = trim(pusuario)||to_char(current,"%H%M%S"); 
    let vreferencia = "Abono por Devolucion Cheque No.: " || pnrocheque;
    
    EXECUTE PROCEDURE bdicheq:abono_ref(pempresa, vsucursal, 
                pusuario,vtran_abono, '0000', vfolio,
                pcuenta, pnrocheque,pimporte, pimporte,
                0,0,0,pmoneda, vreferencia,
                '', pusuario)
            INTO vcodret; 
    
    if trim(vcodret) = "000" then
        let vmsg    = "abono procesado satisfactoriamente";
    end if
    
    return vcodret,vmsg;      
    
end

END PROCEDURE;
create procedure "informix".stat_cheque (
                    pempresa    char(3),
                    pcuenta     char(20),
                    pnrocheque  integer)
       returning    char(5),    --codret
                    char(2);    --motdevol

    -- v1.0 validacion extra cuando el cheque no ha sido
    -- aplicado pero ya esta en la base de datos
    -- lalo jun10
                    
    -- v1.0 version inicial
    -- eduardo espinosa oct09
    -- devuelve el status de la cuenta/cheque

                    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vmotdevol    char(2);
    define vcuenta      char(20);
    define vstatuscta   char(1);
    define vmotivo      char(2);
    define vchequestat  char(1); 
    define vcargo       char(1);
    
    let vcodret     = "000";
    let vmotdevol   = "00";
    let vcargo      = "S";

    
    
--set debug file to "/pisa/liberoltp/pisa_ftes/cecoban/stat_cheque.txt";
--trace on;
        
begin
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vmotdevol;
        end if
    end exception;

    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null 
        or pnrocheque = "" or pnrocheque < 1 then
            let vcodret = "100";
            return vcodret,vmotdevol;
    end if



    -- MOTIVO 02 No tiene cuenta con nosotros el librador
    -- Valida que Exista la Cuenta de Cheques 
    -- o que si la cuenta esta cancelada (status_cta="2")
    
    select  cuenta, status_cta,motivo
    into    vcuenta, vstatuscta, vmotivo
    from    bdicheq:sc_maechq
    where   cuenta = pcuenta;
    
    
    if dbinfo("sqlca.sqlerrd2") = 0 or vstatuscta = "2" then
    
            let vmotdevol   = "02";
            return vcodret,vmotdevol;
            
    else
    
        -- cta bloqueada pero acepta cargos
        if  vstatuscta = "3" then
            select  cargo 
            into    vcargo
            from    bdicheq:sc_bloqueo
            where   codigo = vmotivo;

            if vcargo = "N" then
                let vmotdevol   = "09"; -- cta bloqueada
                return vcodret,vmotdevol;
            end if
        end if        


        
        -- cuenta bloqueada no hacer nada
        -- validar los status del cheque
        
        if vcargo = "S" then
        
            select  estado
            into    vchequestat
            from    bdicheq:sc_contch
            where   empresa = pempresa
            and     cuenta  = pcuenta
            and     numero  = pnrocheque;

            -- no encontro registros
            -- La numeración del cheque no corresponde 
            
            if dbinfo("sqlca.sqlerrd2") = 0 then 
                let vmotdevol   = "51";       
            end if

            -- activo (cheque para intentar cargarle)
            if vchequestat = "A" or vchequestat = "U" then
                -- cta OK  
            end if

            -- ya pagado
            if vchequestat = "P" or vchequestat = "M" then
                let vmotdevol   = "16";
            end if 
            
            -- presentado por camara
            if vchequestat = "N"  then
                let vmotdevol   = "18";
            end if             

            -- revocado
            if vchequestat = "R"  then
                let vmotdevol   = "08";
            end if                

            -- cancelado
            -- CHEQUE EXTRAVIADO
            if vchequestat = "C"  then
                let vmotdevol   = "52";
            end if 

            -- incompleto
            if vchequestat = "I"  then
                let vmotdevol   = "51";
            end if 

            -- destruido
            if vchequestat = "D"   then
                let vmotdevol   = "23";
            end if 
            
            -- bloqueado orden jud
            -- TENEMOS ORDEN JUDICIAL DE NO PAGAR
            if vchequestat = "J"  then
                let vmotdevol   = "07";
            end if 

            -- bloqueado autoridades
            if vchequestat = "B"  then
                let vmotdevol   = "09";
            end if 
            
            
            -- validacion extra 
            
            if exists (select c_cuenta from cce_propios_det
                        where c_cuenta = pcuenta 
                        and c_cheque = pnrocheque
				and status = '01') then
                        
                let vmotdevol   = "16";
            end if 
            
            

        end if --validar los status del cheque


                
    end if    --cuenta, sdo_actual
 

    return vcodret,vmotdevol;    
    
end

END PROCEDURE;
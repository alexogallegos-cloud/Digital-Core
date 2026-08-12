create procedure "informix".act_datos_firma(
                       pempresa     char(3),
                       pcliente     char(20),
                       pcuenta      char(20), 
                       pcod_docto   char(4),
                       psecuencia   smallint,
                       pdescrip2    char(30),
                       puser_modif  char(8))
                       RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_fecha date;
   DEFINE sql_err,isam_err int;   



-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fecha     = today;



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;




-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa        is null or
        pcliente        is null or
        pcuenta         is null or
        pcod_docto      is null or
        psecuencia      is null or
        puser_modif     is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

   
    
-- ****************************************************************************
-- insertar registro en dg_expediente
-- ****************************************************************************

    update          bdidigital@coppelimg_tcp:dg_expediente
    set             descrip2        = pdescrip2,
                    usuario_modif   = puser_modif,
                    fecha_alta      = v_fecha
    -----where      empresa     = pempresa                          
    where           cliente     = pcliente
    and             cuenta      = pcuenta
    and             cod_docto   = pcod_docto
    and             secuencia   = psecuencia;

END;    

RETURN v_codret;

END PROCEDURE;
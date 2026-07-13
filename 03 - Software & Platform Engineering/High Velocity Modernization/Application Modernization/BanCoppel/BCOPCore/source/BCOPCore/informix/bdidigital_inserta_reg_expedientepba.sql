create procedure "informix".inserta_reg_expedientepba(
                       pempresa     char(3),
                       pcliente     char(20),
                       pcuenta      char(20),
                       pproducto    char(4), 
                       pcod_docto   char(4),
                       psecuencia   smallint,
                       pprod_nombre char(40),
                       pdescrip2    char(30),
                       puser_insert char(8))
                       RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_fecha date;
   DEFINE v_existe char(1);
   DEFINE sql_err,isam_err int;   



-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fecha     = today;
   LET v_existe    = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

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
        pproducto       is null or
        pcod_docto      is null or
        psecuencia      is null or
        pprod_nombre    is null or 
        puser_insert    is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

   
    
-- ****************************************************************************
-- insertar registro en dg_expediente
-- ****************************************************************************
    select 1 
    into v_existe 
    from bdidigital@coppelimg_crx:dg_expediente
    where empresa = pempresa
    and cliente = pcliente
    and cuenta = pcuenta
    and producto = pproducto
    and cod_docto = pcod_docto
    and secuencia = psecuencia
    and prod_nombre = pprod_nombre
    and descrip2 = pdescrip2;

    IF  v_existe = '1' THEN 
    RETURN v_codret; 
    END IF;

    insert into     bdidigital@coppelimg_crx:dg_expediente 
                    (empresa,cliente,cuenta,
                    producto,cod_docto,secuencia,prod_nombre,descrip2,
                    usuario_alta,fecha_alta) 
    values          (pempresa,pcliente,pcuenta,pproducto,pcod_docto,
                    psecuencia,pprod_nombre,pdescrip2,puser_insert,
                    v_fecha);

END;    

RETURN v_codret;

END PROCEDURE;
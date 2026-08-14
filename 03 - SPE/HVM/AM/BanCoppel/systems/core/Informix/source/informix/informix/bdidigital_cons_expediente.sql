create procedure "informix".cons_expediente(pempresa char(3),
                pcliente    char(20),
                pnum_regs   smallint)
            RETURNING 
            char(5),char(20),char(40),char(4),date,
            char(3),char(30),char(35),char(30),
            char(1),smallint;


   DEFINE v_codret          char(5);
   DEFINE v_cuenta          char(20);
   DEFINE v_prod_nombre     char(40);
   DEFINE v_cod_docto       char(4);
   DEFINE v_fecha_alta      date;
   DEFINE v_cod_grupo       char(3);
   DEFINE v_descrip_gpo     char(30);
   DEFINE v_descrip_docto   char(35);
   DEFINE v_descrip2        char(30);
   DEFINE v_multi_img       char(1);   
   DEFINE v_secuencia       smallint;
   DEFINE v_contador        smallint;
   DEFINE sql_err,isam_err  int;   


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        LET v_codret            = "000";
        let v_cuenta            = " ";
        let v_prod_nombre       = " ";
        let v_cod_docto         = " ";        
        let v_fecha_alta        = today;
        let v_cod_grupo         = " ";
        let v_descrip_gpo       = " ";
        let v_descrip_docto     = " ";
        let v_descrip2          = " ";
        let v_multi_img         = " ";
        let v_secuencia         = 0;
        let v_contador          = 0;

        


--set debug file to "/pisa/pisabanco/pisa_ftes/cons_expediente.txt";
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,
            v_cod_grupo, v_descrip_gpo,v_descrip_docto,v_descrip2,
            v_multi_img,v_secuencia;
      end if;
   end exception;




-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null or
        pcliente is null or
        pnum_regs is null then
    
       -- datos de entrada incompletos     
       
       let v_codret = 110; 
       RETURN v_codret,v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,
          v_cod_grupo,v_descrip_gpo,v_descrip_docto,v_descrip2,
          v_multi_img,v_secuencia;
    END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    
 

-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH

        
        SELECT  exp.cuenta,exp.producto || ' ' || exp.prod_nombre,
                exp.cod_docto,exp.fecha_alta,gd.cod_grupo,
                gd.descripcion,td.descripcion,td.multi_imagen,
                exp.secuencia,nvl(exp.descrip2," ")
        INTO    v_cuenta,v_prod_nombre,v_cod_docto,v_fecha_alta,
                v_cod_grupo,v_descrip_gpo,v_descrip_docto,
                v_multi_img,v_secuencia,v_descrip2
        FROM    bdidigital@coppelimg_tcp:dg_expediente exp,
                bdidigital@coppelimg_tcp:dg_grupodocto gd,
                bdidigital@coppelimg_tcp:dg_tipodocumento td
        WHERE   exp.cod_docto       = td.cod_docto 
                and td.cod_grupo    = gd.cod_grupo 
                -- and exp.empresa     = pempresa
                and exp.cliente     = pcliente 
                and exp.descrip2    <> 'firma_borra_da'
        ORDER BY 4,1,3


        let v_contador = v_contador +1;

        IF v_contador < pnum_regs then
                CONTINUE FOREACH;
        END IF; 
                
                   


        RETURN  v_codret,v_cuenta,v_prod_nombre,v_cod_docto,
            v_fecha_alta,v_cod_grupo,v_descrip_gpo,
            v_descrip_docto,v_descrip2,v_multi_img,
            v_secuencia 
            WITH resume;

    END FOREACH     

END;    
END PROCEDURE;
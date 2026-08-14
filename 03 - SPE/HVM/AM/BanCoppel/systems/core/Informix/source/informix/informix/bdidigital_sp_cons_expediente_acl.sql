CREATE PROCEDURE "informix".sp_cons_expediente_acl (pempresa char(3), pcliente char(20), pcuenta_csuac char(10), pnum_regs smallint)
            
	RETURNING CHAR(4) AS codDocto, CHAR(35) AS descripcion, CHAR(2) AS secuencia, CHAR(45) AS nombreEmpleado, CHAR(30) AS anversoReverso, DATE AS fechaAlta;
		
-- ****************************************************************************
-- Definición de Variables 
-- ****************************************************************************
   DEFINE v_codret          CHAR(5);
   DEFINE v_cod_docto		CHAR(4) ;
   DEFINE v_descripcion		CHAR(35);
   DEFINE v_secuencia		CHAR(2) ;
   DEFINE v_nombre			CHAR(45);
   DEFINE v_descrip2		CHAR(30);
   DEFINE v_fecha_alta		DATE;
   DEFINE sql_err,isam_err  int; 
   DEFINE v_contador        smallint;
    
-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
   LET v_codret         = "000";
   LET v_cod_docto		= "";
   LET v_descripcion	= "";
   LET v_secuencia		= 0;
   LET v_nombre			= "";
   LET v_descrip2		= "";
   LET v_fecha_alta		= "";
   LET v_contador       = 0;
    
--set debug file to "/pisa/SD/cons_expediente.txt";
--trace on;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_cod_docto	, v_descripcion, v_secuencia, v_nombre, v_descrip2, v_fecha_alta;
      end if;
   end exception;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa 		is null or
        pcliente 		is null or
		pcuenta_csuac 	is null or 
        pnum_regs 		is null then
    
       -- Datos de entrada incompletos     
       
       let v_codret = 110; 
       RETURN 	v_cod_docto	, v_descripcion, v_secuencia, v_nombre, v_descrip2, v_fecha_alta;
    END IF;


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH

        
        SELECT  td.cod_docto, td.descripcion, exp.secuencia, se.nombre, nvl(exp.descrip2," "), exp.fecha_alta
        INTO    v_cod_docto, v_descripcion, v_secuencia, v_nombre, v_descrip2, v_fecha_alta
        FROM    bdidigital@coppelimg_tcp:dg_expediente exp,			
                bdidigital@coppelimg_tcp:dg_grupodocto gd,			
                bdidigital@coppelimg_tcp:dg_tipodocumento td,
				bdinteg:si_ejecut se 
        WHERE   td.usuario_modif 	= se.ejecutivo
				and exp.cod_docto   = td.cod_docto 
                and td.cod_grupo    = gd.cod_grupo 
                -- and exp.empresa     = pempresa
                and exp.cliente     = pcliente
				and exp.cuenta		= pcuenta_csuac
                and exp.descrip2    <> 'firma_borra_da'
        ORDER BY 4,1,3

        let v_contador = v_contador +1;

        IF v_contador < pnum_regs then
                CONTINUE FOREACH;
        END IF; 
                
        RETURN  v_cod_docto, v_descripcion, v_secuencia, v_nombre, v_descrip2, v_fecha_alta 
				WITH resume;

    END FOREACH     

END;    
END PROCEDURE;
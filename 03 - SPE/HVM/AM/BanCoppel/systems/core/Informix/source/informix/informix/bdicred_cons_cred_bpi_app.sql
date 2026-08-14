create procedure "informix".cons_cred_bpi_app(pempresa char(3),
                                     pnum_cte char(20),
                                     pmoneda char(2))
   returning char(5),char(20),char(20), char(2),char(20),char(1),char(40),char(1);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_numcte,v_cuenta, v_numtarjeta char(20);
   define v_status_tar char(1);
   define v_status_cred char(2);
   define v_nombre_prod char(40);
   define v_secuencia integer;
   DEFINE vstatus_serv CHAR(1);
   define iCont		integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_cuenta      = null;
   let v_numcte = " ";
   let v_numtarjeta = " ";
   let v_status_tar = ' ';
   let v_status_cred = " ";
   let v_nombre_prod = " ";
   LET vstatus_serv	= "";
   let iCont =0;
   
   -- *****************************************************************************************************        
   -- Obejtivo:            Consulta de Estados de Cuenta Electronicos
   -- Creado por:			Autor desconocido
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2014/03/24    
   -- Razón:				Se agrega parámetro de salida del status del servicio
   --						de emisión de estados de cuenta CFDI
   -- *****************************************************************************************************
   -- Obejtivo:            Mostrar mas de 1 tarjeta en bpi (VISA y PLATINO)
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2015/01/12    
   -- Razón:				Se agrega FOREACH para recorrer todas las posibles cuentas de credito de un cliente.
   --						
   -- *****************************************************************************************************

--set debug file to "/home/informix/bibiana/cons_cre_bpi.out";
--trace on;

LET v_numcte = pnum_cte;

begin
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv;
      end if
   end exception;


       SET ISOLATION DIRTY READ ;
       set lock mode to wait 3;
		--Se agrega FOREACH para consultar mas de 1 tarjeta de credito.
	   FOREACH
       SELECT mc.num_credito, 
              mc.status_cred, 
              tr.num_tarjeta, tr.status_tar, 
              TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod) AS nombre_prod
        into v_cuenta, 
             v_status_cred, 
             v_numtarjeta, 
             v_status_tar, 
             v_nombre_prod
       FROM bdicred:"informix".sd_maecred mc
       join bdicred:"informix".sd_tarjeta tr on (tr.empresa = pempresa and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT','E1','E2','E3') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = pempresa and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
       join bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
       WHERE mc.numcte = pnum_cte
	   --Se busca para saber si tiene activo el servicio de estados de cuenta CFDI
	  SELECT status_serv_elec
	  INTO vstatus_serv
	  FROM bdiedoelec:"informix".edelec_alta_serv
	  WHERE cuenta = v_cuenta;
		
		LET iCont = iCont + 1;
		IF(iCont < 10 ) THEN
			return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"") WITH RESUME;
		END IF;	
    END FOREACH;
    
	IF ( iCont = 0 ) THEN
        LET cod_ret = '101'; --- Cliente No tiene cuentas
        RETURN cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"");
    END IF  

end
end procedure;
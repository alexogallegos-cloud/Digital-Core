CREATE PROCEDURE "informix".img_sol_rec_clientes(pempresa char(3))
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cliente char(9);
   DEFINE v_cod_docto char(4);
   DEFINE v_secuencia smallint;
   DEFINE sql_err,isam_err int; 
   define v_cuenta char(20);
   define v_producto char(04);
   define v_tipo_cliente char(01);
   --define v_contador smallint;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cliente     = "";
   LET v_cod_docto    = "";
   LET v_secuencia = 0;
   let v_cuenta = "";
   let v_producto = "";
   let v_tipo_cliente = "";
   --let v_contador = 0;


BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec_2';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

--------------------RGH

	

        FOREACH WITH HOLD

	    SELECT numcte, tipo_cliente
            INTO v_cliente, v_tipo_cliente
            FROM bdidigital@coppelimg_tcp:tmp_cliente 
            WHERE tipo_cliente <> '5'
	

            BEGIN WORK;

            FOREACH WITH HOLD
                SELECT cod_docto,secuencia, cuenta, producto
                INTO v_cod_docto, v_secuencia, v_cuenta, v_producto
                FROM bdidigital@coppelimg_tcp:dg_expediente 
                WHERE cliente = v_cliente
                --WHERE empresa = pempresa

		 --BEGIN WORK;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img
                    WHERE empresa = pempresa
                    AND cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    AND secuencia = v_secuencia;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente
                    --WHERE empresa = pempresa
                    WHERE cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    and cuenta = v_cuenta
                    AND producto = v_producto
                    AND secuencia = v_secuencia;
	            
		--COMMIT WORK;

            END FOREACH;

            update bdidigital@coppelimg_tcp:tmp_cliente
            set tipo_cliente = '5'
            where numcte = v_cliente;

            if (v_tipo_cliente = '1') then
                update bdinteg:si_cliente 
                set tipo_cliente = '2'
                where numcte = v_cliente;
            end if;

		COMMIT WORK;

		--LET v_contador = v_contador + 1;
	
		--IF (v_contador <= 100) THEN
			--CONTINUE FOREACH;
		--ELSE 
			--LET v_codret = '000';
			--RETURN v_codret;
		--END IF;
	

	    END FOREACH;


	

END;    

RETURN v_codret;

END PROCEDURE;
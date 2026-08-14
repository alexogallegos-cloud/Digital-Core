CREATE PROCEDURE "informix".cons_dev_suc_web2(pempresa CHAR(3), psucursal CHAR(4), pfechapre DATE, pnum_regs SMALLINT)
	RETURNING CHAR(5), CHAR(45), CHAR(20), CHAR(11), CHAR(16), CHAR(20), CHAR(100), CHAR(50), CHAR(13);


   DEFINE v_codret      CHAR(5);
   DEFINE v_banco		CHAR(45);
   DEFINE v_cuenta      CHAR(20);
   DEFINE v_numcheque   CHAR(11);
   DEFINE v_monto       CHAR(16);
   DEFINE v_ctadeposito CHAR(20);
   DEFINE v_cliente     CHAR(20);
   DEFINE v_motdevol    CHAR(50);
   DEFINE v_contador    SMALLINT;
   DEFINE v_nombrecte   CHAR(100);
   DEFINE v_rfc         CHAR(1);
   DEFINE v_curp  		CHAR(1);
   DEFINE sql_err,isam_err  INT; 

   DEFINE v_codret2 CHAR(5);
   DEFINE vtel1   CHAR(13);
   DEFINE vtel2   CHAR(13);   


  --SET debug file to "cons_suc.out";
  --trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "00000";
   LET v_codret2    = "00001";


BEGIN
   ON EXCEPTION SET sql_err,isam_err
       IF sql_err <> 0 or isam_err <> 0 THEN
			LET v_codret = sql_err;
			RETURN  v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_ctadeposito, v_cliente || ' ' || v_nombrecte, v_motdevol, vtel1;
       END IF;
   END EXCEPTION;


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  pempresa is null or
	 	psucursal is null or
		pnum_regs is null then
	
		   -- datos de entrada incompletos	   
		LET v_codret = '00110'; 
		RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
			v_monto,v_ctadeposito,
			v_cliente || ' ' || v_nombrecte,
			v_motdevol, vtel1;
	END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    
        LET v_banco       = " ";
        LET v_cuenta      = " ";
        LET v_numcheque   = " ";        
        LET v_monto       = 0;
        LET v_ctadeposito = " ";        
        LET v_motdevol    = " ";
        LET v_contador    = 0;


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

	FOREACH

		-- consulta principal
		
		SELECT 	c.cvebanco || ' ' || b.descripcion,c.numcuenta, c.numcheque,c.numcte,c.cta_deposito,c.monto, c.motivo || ' ' || dev.descripcion
			INTO	v_banco,v_cuenta,v_numcheque,v_cliente, v_ctadeposito,v_monto,v_motdevol
		FROM	cce_cheques_dev c, bdinteg:si_bancos b,
			bdinteg:si_coddevcam dev
		WHERE	c.empresa = pempresa
			and c.fechapresenta = pfechapre
			and c.sucursal = psucursal	
			and c.cvebanco = b.banco
			and c.motivo = dev.codigo

		-- obtener el nombre o razon social del cliente
		
		call consnomcte(pempresa,v_cliente)
              		returning v_codret,v_nombrecte,v_rfc,v_curp;	

--------------------------------------------------------------------------------------------------------------------------					
		-- obtener el telefono del cliente

		call cons_tels_web(v_cliente)
              		returning v_codret2,vtel1,vtel2;
--------------------------------------------------------------------------------------------------------------------------			

		LET v_contador = v_contador +1;
        
        IF v_codret = '000' then
        LET v_codret = '00000';
        END IF;  

        IF v_codret = '800' then
        LET v_codret = '00001';
        END IF;     

		IF v_contador < pnum_regs then
			CONTINUE FOREACH;
		END IF;    


		RETURN  v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_ctadeposito, trim(v_cliente) || ' ' || v_nombrecte, v_motdevol, vtel1
			WITH resume;

	END FOREACH		

	IF v_contador = 0 THEN
		
		LET v_codret = '00001';
		LET v_banco  = " ";
        LET v_cuenta = " ";
        LET v_numcheque = " ";        
        LET v_monto  = 0;
        LET v_ctadeposito = " ";        
        LET v_cliente = " ";
		LET v_nombrecte = "";
        LET v_motdevol = 0;
		LET vtel1 = " ";
		
		RETURN v_codret,v_banco,v_cuenta,v_numcheque, v_monto,v_ctadeposito, trim(v_cliente) || ' ' || v_nombrecte, v_motdevol, vtel1 WITH resume;		
	END IF;
	
END;    
END PROCEDURE;
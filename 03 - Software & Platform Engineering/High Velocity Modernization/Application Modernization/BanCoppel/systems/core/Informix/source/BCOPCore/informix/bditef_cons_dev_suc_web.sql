create procedure "informix".cons_dev_suc_web(pempresa char(3),
		       	psucursal  	char(4),
		       	pfechapre 	date,
		       	pnum_regs 	smallint)
			RETURNING 
			char(5),char(45),char(20),char(11),
			char(16),char(20),char(100),
			char(50);


   DEFINE v_codret          	char(5);
   DEFINE v_banco		char(45);
   DEFINE v_cuenta	    	char(20);
   DEFINE v_numcheque       	char(11);
   DEFINE v_monto	      	char(16);
   DEFINE v_ctadeposito       	char(20);
   DEFINE v_cliente     	char(20);
   DEFINE v_motdevol	   	char(50);
   DEFINE v_contador        	smallint;
   DEFINE v_nombrecte		char(100);
   DEFINE v_rfc  		char(1);
   DEFINE v_curp  		char(1);
   DEFINE sql_err,isam_err  int;   


  --SET debug file to "cons_suc.out";
  --trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "00000";



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
	let v_codret = sql_err;
	RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
		v_monto,v_ctadeposito,
		v_cliente || ' ' || v_nombrecte,
		v_motdevol;
      end if;
   end exception;




-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  	pempresa is null or
	 	psucursal is null or
		pnum_regs is null then
	
		   -- datos de entrada incompletos	   
		LET v_codret = '00110'; 
		RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
			v_monto,v_ctadeposito,
			v_cliente || ' ' || v_nombrecte,
			v_motdevol;
	END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    
        let v_banco		= " ";
        let v_cuenta   		= " ";
        let v_numcheque     	= " ";        
        let v_monto	    	= 0;
        let v_ctadeposito     	= " ";        
        let v_motdevol     	= " ";
        let v_contador      	= 0;



-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

	FOREACH

		-- consulta principal
		
		SELECT 	c.cvebanco || ' ' || b.descripcion,c.numcuenta,
			c.numcheque,c.numcte,c.cta_deposito,c.monto,
			c.motivo || ' ' || dev.descripcion
		INTO	v_banco,v_cuenta,v_numcheque,v_cliente,
			v_ctadeposito,v_monto,v_motdevol
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


		RETURN  v_codret,v_banco,v_cuenta,v_numcheque,
			v_monto,v_ctadeposito,
			trim(v_cliente) || ' ' || v_nombrecte,
			v_motdevol
			WITH resume;

	END FOREACH		

END;    
END PROCEDURE;
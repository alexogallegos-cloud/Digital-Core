CREATE PROCEDURE "informix".cons_img_nula1(pempresa       CHAR(3),
                                          pcvebanco   	 CHAR(3),
                                          pnumcuenta   	 CHAR(20),
                                          pnumcheque   	 CHAR(7),
                                          plado_ft       CHAR(1),
                                          pfechapresenta CHAR(10))
RETURNING CHAR(5);  

    DEFINE v_codret CHAR(5);
    DEFINE sql_err,isam_err INT;   
    --DEFINE v_existe CHAR(1);
	DEFINE iimagen  INT;

    -- // Inicializa variables
    LET v_codret    = "000";
    --LET v_existe    = "0";
	LET iimagen     = "0";
    
    -- // Valida la informacion de entrada
    IF pempresa    	  IS NULL OR
       pcvebanco      IS NULL OR
       pnumcuenta     IS NULL OR
       pnumcheque     IS NULL OR
       plado_ft       IS NULL OR
       pfechapresenta IS NULL THEN
        LET v_codret = 110; -- // datos de entrada incompletos
        RETURN v_codret; 
    END IF;
	
	--SET DEBUG FILE TO "/tmp/Guicho/cons_img_nula1.out";
	--TRACE ON;
    
    BEGIN

		ON EXCEPTION SET sql_err,isam_err
			if sql_err <> 0 OR isam_err <> 0 THEN
				let v_codret = sql_err;
				RETURN v_codret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
		/*
		select length(imagen::lvarchar) 
		INTO iimagen
		from "informix".cce_cheques_img
		 where empresa = pempresa
		   and cvebanco = pcvebanco
		   and numcuenta = pnumcuenta
		   and numcheque = pnumcheque
		   and lado_ft = plado_ft
		   and fechapresenta = pfechapresenta;

        IF iimagen IS NULL OR iimagen = '' THEN
            LET v_codret = 130; 
            RETURN v_codret;                 
        END IF;
		*/

		SELECT COUNT(*)
		INTO iimagen
		FROM "informix".cce_cheques_img
		WHERE empresa = pempresa
		AND cvebanco = pcvebanco
		AND numcuenta = pnumcuenta
		AND numcheque = pnumcheque
		AND fechapresenta = pfechapresenta
		--AND imagen IS NULL OR length(imagen::lvarchar) =0;
		AND (imagen IS NULL OR length(imagen::lvarchar) =0);

		IF iimagen > 0 THEN
			LET v_codret = 130; 
			RETURN v_codret;  
        END IF;	
    
    END;    

    RETURN v_codret;

END PROCEDURE
DOCUMENT
'FECHA: 30/11/2017',
'AUTOR: Jesus Ivan Garcia Guicho.',
'FOLIO: 1856',
'SUSTENTO: INC 24 066 Cheque en blanco.pdf.',
'SOLICITA: Cutberto Gonzalez Perez.',
'DESCRIPCION: Se modifica nombre del SP para ponerlo en pruebas en piloto.',
'BD: bditef';

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
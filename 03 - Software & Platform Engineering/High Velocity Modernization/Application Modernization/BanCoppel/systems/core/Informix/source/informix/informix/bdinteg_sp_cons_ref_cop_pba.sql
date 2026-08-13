CREATE PROCEDURE "informix".sp_cons_ref_cop_pba(p_empresa char(3), p_sucursal char(4), p_usuario char(8), p_numcte char(20), p_referencia char(20),p_apellpat char(20),
											p_apellmat char(20),p_nom1 char(20),p_nom2 char(20), p_rfc char(13))
            RETURNING 
            char(5),char(1);

   DEFINE v_codret          char(5);
   DEFINE v_referencia		char(20);
   DEFINE v_apellpat		char(20);
   DEFINE v_apellmat		char(20);
   DEFINE v_nom1			char(20);
   DEFINE v_nom2			char(20);
   DEFINE v_rfc				char(13);
   DEFINE v_result			char(1);
   DEFINE sql_err,isam_err  int;
   DEFINE v_cuantos			int;
 
 -- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        let v_codret            = "000";
        let v_referencia        = " ";        
        let v_apellpat          = " ";
		let v_apellmat          = " ";
        let v_nom1         		= " ";
        let v_nom2          	= " ";
		let v_rfc				= " ";
		let v_result			= " ";

--set debug file to "/tmp/sp_cons_ref_cop.txt";
--trace on;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
		 let v_result = '1';
         RETURN v_codret,v_result;
      end if;
   end exception;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  p_empresa is null or
        p_referencia is null or 
		p_apellpat is null or
		p_nom1 is null or		
		p_rfc is null
		then
       -- datos de entrada incompletos     
       let v_codret = 110; 
	   let v_result = '1';
       RETURN v_codret,v_result;
    END IF;

-- ****************************************************************************
-- Consultar datos
-- ****************************************************************************

	SELECT COUNT(numcte) INTO v_cuantos FROM bdinteg:si_cliente WHERE numcte_ref = p_referencia;

	IF v_cuantos <= 1 THEN

		IF EXISTS (SELECT numcte_ref FROM bdinteg:si_cliente WHERE numcte_ref = p_referencia) THEN
			SELECT numcte_ref, rfc, nombre1, nombre2, apell_paterno, apell_materno
			INTO v_referencia, v_rfc, v_nom1, v_nom2, v_apellpat, v_apellmat
			FROM bdinteg:si_cliente
			WHERE numcte_ref = p_referencia;
			IF 	TRIM(p_referencia) = TRIM(v_referencia)
				AND TRIM(p_rfc) = TRIM(v_rfc)
				AND TRIM(p_nom1) = TRIM(v_nom1)
				AND TRIM(p_nom2) = TRIM(v_nom2)
				AND TRIM(p_apellpat) = TRIM(v_apellpat)
				AND	TRIM(p_apellmat) = TRIM(v_apellmat)
			THEN
				LET v_codret = '000';
                        LET v_result = '0';
			ELSE
				LET v_codret = '000';
				LET v_result = '1';
				INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
					VALUES(p_empresa,p_numcte,p_referencia,p_rfc,p_sucursal, p_usuario,p_apellpat,p_apellmat,p_nom1,p_nom2, CURRENT);
			END IF;
		ELSE
				LET v_codret = '000';
				LET v_result = '0';	
		END IF;
	
	ELSE
		LET v_codret = '000';
		LET v_result = '1';
		INSERT INTO bdinteg:si_bitacora_refcop(empresa, numcte, numcte_ref, rfc, sucursal, usuario, apell_paterno, apell_materno, nombre1, nombre2, fecha_insert)
			VALUES(p_empresa,p_numcte,p_referencia,p_rfc,p_sucursal, p_usuario,p_apellpat,p_apellmat,p_nom1,p_nom2, CURRENT);
	END IF;		
	
	RETURN v_codret,v_result;

END;    
END PROCEDURE;
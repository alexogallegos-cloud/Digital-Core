create procedure "informix".ins_img_det(
                       pempresa         char(3),
                       pcvebanco   		char(3),
                       pnumcuenta   	char(20),
                       pnumcheque   	char(7),
                       plado_ft         char(1),
                       pfechapresenta   char(10),
                       pimagen_formato 	char(3),
                       pimagen_tam		integer, 
                       puser_insert     char(8),
                       pfecha_insert    char(10))
                       RETURNING char(5);  

   DEFINE v_codret char(5);
   DEFINE sql_err,isam_err int;   
   DEFINE v_existe char(1);
   DEFINE v_fechapre char(10);
   

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_existe    = "0";
   

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  pempresa    	is null or
		pcvebanco       is null or
		pnumcuenta      is null or
		pnumcheque      is null or
        plado_ft        is null or
		pfechapresenta  is null or
		pimagen_formato is null or
		pimagen_tam     is null or
	    puser_insert    is null or 
        pfecha_insert   is null THEN
	
	   -- datos de entrada incompletos
	   
	   LET v_codret = 110; 
	   RETURN v_codret; 
	END IF;

BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;
   
--    SET debug file to "/resplogifx/conciliachq/ins_img_det.out";
--    TRACE ON;

-- ****************************************************************************
-- insertar registro en cce_cheques_img 
-- ****************************************************************************

-- ASH 17/12/2019

		call cal_fechapre(pempresa,pcvebanco,lpad(trim(pnumcuenta),20,"0"), pnumcheque, pfecha_insert)
			 returning v_codret,v_fechapre;
			 
		IF v_fechapre IS NULL OR v_fechapre = " " THEN
			LET v_fechapre = pfechapresenta;
		END IF;
			 
-- ASH 17/12/2019
        -- validacion no exista el registro
        
        select  "1"
        into    v_existe
        from    cce_cheques_img
        where   empresa = pempresa
        and     cvebanco = pcvebanco
        and     numcuenta = pnumcuenta
        and     numcheque = pnumcheque
        and     lado_ft = plado_ft
        and     fechapresenta = v_fechapre;
        
        IF dbinfo("sqlca.sqlerrd2") = 0 THEN
            insert into cce_cheques_img (empresa,cvebanco,numcuenta,
                        numcheque,lado_ft,fechapresenta,imagen_formato,
                        imagen_tam,usuario_alta,fecha_alta) 
        	values (pempresa,pcvebanco,pnumcuenta,pnumcheque,
        		    plado_ft,v_fechapre,pimagen_formato,pimagen_tam,
                    puser_insert,pfecha_insert);
        END IF;                
END;    

RETURN v_codret;

END PROCEDURE;
CREATE PROCEDURE "informix".ins_img_det_web(
                       pempresa         CHAR(3),
                       pcvebanco   	    CHAR(3),
                       pnumcuenta   	CHAR(20),
                       pnumcheque   	CHAR(7),
                       plado_ft         CHAR(1),
                       pfechapresenta   CHAR(10),
                       pimagen_formato 	CHAR(3),
                       pimagen_tam	    INTEGER, 
                       puser_insert     CHAR(8),
                       pfecha_insert    CHAR(10))
					   
	RETURNING CHAR(5);  

	DEFINE v_codret CHAR(5);
	DEFINE sql_err,isam_err INT;   
	DEFINE v_existe CHAR(1);
	DEFINE v_fechapre CHAR(10);						  
   
	--set debug file to "/tmp/ins_img_det.out";
	--trace on;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "00000";
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
	   
	   LET v_codret = "00110"; 
	   RETURN v_codret; 
	END IF;

BEGIN

	ON EXCEPTION SET sql_err,isam_err
		IF sql_err <> 0 OR isam_err <> 0 THEN
			LET v_codret = sql_err;
			RETURN v_codret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 
-- ****************************************************************************
-- insertar registro en cce_cheques_img 
-- ****************************************************************************

-- ASH 17/12/2019

	CALL cal_fechapre(pempresa,pcvebanco,lpad(trim(pnumcuenta),20,"0"), pnumcheque, today)
		RETURNING v_codret,v_fechapre;
		LET v_codret = '00'||v_codret;
		 
	IF v_fechapre IS NULL OR v_fechapre = " " THEN
		LET v_fechapre = today;
	END IF;
		 
-- ASH 17/12/2019
	-- validacion no exista el registro
	
	SELECT  "1"
	INTO   v_existe
	FROM   cce_cheques_img
	WHERE  empresa = pempresa
	AND    cvebanco = pcvebanco
	AND    numcuenta = pnumcuenta
	AND    numcheque = pnumcheque
	AND    lado_ft = plado_ft
	AND    fechapresenta = v_fechapre;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		INSERT INTO cce_cheques_img (empresa,cvebanco,numcuenta,
					numcheque,lado_ft,fechapresenta,imagen_formato,
					imagen_tam,usuario_alta,fecha_alta) 
		VALUES (pempresa,pcvebanco,pnumcuenta,pnumcheque,
				plado_ft,v_fechapre,pimagen_formato,pimagen_tam,
				puser_insert,today);
	END IF;                 
END;
RETURN v_codret;
END PROCEDURE;
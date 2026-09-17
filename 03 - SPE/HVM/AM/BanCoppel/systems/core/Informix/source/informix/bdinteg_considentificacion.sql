CREATE PROCEDURE "informix".considentificacion(p_numcte char(10))
   RETURNING CHAR(5), CHAR(20), CHAR(20);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_tipoIdent		CHAR(50);
   DEFINE v_noIdent			CHAR(50);

   LET v_tipoIdent = "";
   LET v_noIdent   = "";
	

	--SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
	--TRACE ON;
BEGIN	
	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_tipoIdent, v_noIdent;
	END EXCEPTION;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";


	
	

	SELECT tipo_ident, num_ident
	INTO v_tipoIdent,v_noIdent 
	FROM "informix".si_bitmant_huellarostro
    	WHERE numcte = trim(p_numcte) AND  fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:"informix".si_bitmant_huellarostro WHERE NUMCTE = trim(p_numcte));
    	
    
    
    IF trim(v_noIdent) is null then
		let cod_ret = "104";
		RETURN  cod_ret,trim(v_tipoIdent), trim(v_noIdent);
    end if

    RETURN  cod_ret,trim(v_tipoIdent), trim(v_noIdent);
END
END PROCEDURE

DOCUMENT
'SPL Extrae tipo y numero de identificacion ingresados en manhuella',
"MODIFICO : CRISTIAN IBARRA",
"FECHA : 27/Febrero/2021",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sps_obt_numcte_status(pEmpresa char(3), pIdUsuario char(20), pUsuario char(50), pIndicador CHAR(1))
                      returning char(5),char(20),smallint;

	-- Creador: Moises Soriano	
	-- Objetivo: Obtener el número y estatus del cliente,
	-- Se clona sp_obt_numcte_status, se agrega parametro de entrada
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 11/04/2016
					
					  
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_id_status smallint ;
   define v_num_cte char (20);
   define pNumCte char (20);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_id_status = 0;
   let v_num_cte = "";
   
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obt_numcte_status.out";
	--TRACE ON;

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_num_cte, v_id_status;
      end if
   end exception;

SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   

   IF pIndicador = '' AND pIdUsuario <> '' THEN
      LET  pIndicador = '1';
   END IF;

  IF pIdUsuario <> '' THEN
		IF pIndicador = '1' THEN  -- pIdUsuario = id_usuario
			SELECT numcliente INTO pNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
		ELIF pIndicador = '2' THEN -- pIdUsuario = numcliente
			LET pNumCte = pIdUsuario;
		END IF;
	
        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

             SELECT numcte,id_status INTO v_num_cte, v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte;
			 LET v_num_cte = pNumCte;
             LET cod_ret = '000';

        ELSE

            LET cod_ret = '001';

        END IF ;

  ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT numcte,id_status INTO v_num_cte,v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;

             LET cod_ret = '000';

        ELSE

            LET cod_ret = '002';

        END IF ;

  END IF ;
  
  RETURN cod_ret, v_num_cte, v_id_status;

END

END PROCEDURE ;
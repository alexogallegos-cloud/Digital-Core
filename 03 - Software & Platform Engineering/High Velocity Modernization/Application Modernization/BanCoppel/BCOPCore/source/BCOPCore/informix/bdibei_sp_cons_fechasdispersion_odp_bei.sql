CREATE PROCEDURE "informix".sp_cons_fechasdispersion_odp_bei(pNumCte CHAR(9), pIdOperacion CHAR(4), pRegInical INTEGER)
 returning char(5), CHAR(10);


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE sFecha CHAR(10);
    LET cod_ret  = "00000";
    LET sFecha = '';


	--SET debug FILE TO "/home/informix/BereniceOut/sp_cons_fechasdispersion_odp_bei.out";
    --Trace ON;
	
--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LAS FECHAS EN QUE SE REALIZARON DISPERSIONES DE ORDENES DE PAGO INDIVIDUAL
-- AUTOR : Jesus Ferruzca Luna
-- FECHA :27/03/2015
-- BD: bdibei
-- SOLICITO :
-- MODIFICACION: SE MODIFICA PARA QUE TAMBIEN CONSIDERE LOS REIGISTROS DE LA BEI_BITACORA_HISTORIAL (DE AYER PARA ATRAS) Y
--					YA QUE AHORA EN LA BEI_BITACORA SE TIENE LO DEL DIA ACTUAL.
-- MODIFICA: Berenice Noriega Guevara - G3 - CoordinaciÃ³n internet
-- FECHA: 09 Octubre 2019 
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret, sFecha;
      END IF ;
   END EXCEPTION ;


	IF NVL(pIdOperacion,0) == 0 THEN
	 	  LET cod_ret = '001';
          RETURN cod_ret, sFecha;
	END IF;
     SET LOCK MODE TO WAIT 4;

--**************************************************************************************************************
--CONSULTA DE FECHAS
--**************************************************************************************************************
        FOREACH

            SELECT SKIP pRegInical FIRST 10 
			distinct bt.lafecha_oper
            INTO   
			sFecha
            From   
			(
			select to_char(fecha_oper,'%m/%d/%Y') as lafecha_oper
			from bdibei:"informix".bei_bitacora
            Where  id_operacion = pIdOperacion
            And    num_cliente = pNumCte
			UNION 
			select to_char(fecha_oper,'%m/%d/%Y') as lafecha_oper
			from bdibei:"informix".bei_bitacora_historial
            Where  id_operacion = pIdOperacion
            And    num_cliente = pNumCte
			)bt
			
			ORDER BY lafecha_oper DESC
			
			RETURN cod_ret, sFecha WITH RESUME;

        END FOREACH;

END
END PROCEDURE;
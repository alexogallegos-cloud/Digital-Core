CREATE PROCEDURE "informix".sp_consultadatosusrl ()
returning CHAR (5), CHAR (3);
	--*************************************************************--
	--**	Elaboró: F.R.G.                                      **--
	--**	Actividad: Consulta Parámetros de bdisac:sac_param   **--
	--**	Solicito: Código Test                                **--
	--**	Fecha: 26/10/10                                      **--
	--**    Detalle: Este SP hace una consulta a la tabla de     **--
	--**             parametros bdisac:sac_param para obtener    **--
	--**             el valor del mensaje de loggeo de BCP a BTS.**--
	--**             Si algún parámetro es incorrecto o no       **--
	--**             encontrado en la consulta, manda un código  **--
	--**             de error = 99999.                           **--
        --**                                                         **--
	--*************************************************************--

	DEFINE sql_err			INTEGER;
	DEFINE cod_err			CHAR(5);
	DEFINE agcode		        CHAR(3);
	
	DEFINE vparametro1		INTEGER;
	
	LET cod_err			= "00000";
	LET vparametro1                 = 87005;
	
-----------------------------------------------------------------------------------------
	--	SET DEBUG FILE TO "/ids10_1uc5/tmp/bts/sp_consultadatosusrl.out";
	--	TRACE ON;
-----------------------------------------------------------------------------------------

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, agcode;
      END IF;
END EXCEPTION;


    SELECT valor
	INTO agcode 
    FROM BDISAC:sac_param
    WHERE 
    	cod_param = vparametro1;
    
    IF agcode is null
    	THEN
        	LET cod_err = '99999';
    END IF;

    	RETURN cod_err, agcode;
   END;
END PROCEDURE;
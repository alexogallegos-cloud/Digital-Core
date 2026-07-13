CREATE PROCEDURE "informix".sp_consultadatosencabezado ()
returning CHAR (5), CHAR (15), CHAR(15), CHAR(15), CHAR (15), CHAR (15), CHAR (80), CHAR (1);

	--************************************************************--
	--**	Elaboró: F.R.G.                                     **--
	--**	Actividad: Consulta Parámetros de bdisac:sac_param  **--
	--**	Solicito: Código Test                               **--
	--**	Fecha: 26/10/10                                     **--
	--**    Detalle: Este SP hace una consulta a la tabla de    **--
	--**             parametros bdisac:sac_param                **--
	--**             Para obtener los valores de conexion entre **--
	--**             Central Bancoppel y BTS.                   **--
	--**             Si algún parámetro es incorrecto o no      **--
	--**             encontrado en la consulta, manda un código **--
	--**             de error = 9999n.                          **--
        --**                                                        **--
	--**                                                        **--
	--************************************************************--

	DEFINE sql_err			INTEGER;
	DEFINE cod_err			CHAR(5);
	DEFINE ip_origen		CHAR(15);
	DEFINE ip_destino		CHAR(15);
	DEFINE dominio		        CHAR(15);
	DEFINE usrname		        CHAR(15);
	DEFINE psswrd		        CHAR(15);
	DEFINE num_reintentos		CHAR(1);
	
	DEFINE vparametro1		INTEGER;
	DEFINE vparametro2		INTEGER;
	DEFINE vparametro3		INTEGER;
	DEFINE vparametro4		INTEGER;
	DEFINE vparametro5		INTEGER;
	DEFINE vparametro6		INTEGER;
	DEFINE ssn_id                   CHAR(80);

	LET cod_err			= "00000";
	LET vparametro1                 = 87000;
	LET vparametro2                 = 87001;
	LET vparametro3                 = 87002;
	LET vparametro4                 = 87003;
	LET vparametro5                 = 87004;
	LET vparametro6                 = 87009;
	LET ssn_id                      = "Sin Id";
	
----------------------------------------------------------------------------------
--	SET DEBUG FILE TO "/ids10_1uc5/tmp/bts/sp_consultadatosencabezado.out";
--	TRACE ON;
----------------------------------------------------------------------------------

 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err, ip_origen, ip_destino, dominio, usrname, psswrd, ssn_id, num_reintentos;
      END IF;
END EXCEPTION;


    SELECT valor
	INTO ip_origen 
    FROM BDISAC:sac_param
    WHERE 
    	cod_param = vparametro1;
    
    IF ip_origen is null
    	THEN
        	LET cod_err = '99999';
    END IF;
    	        
    SELECT valor
	INTO ip_destino 
    FROM BDISAC:sac_param
    WHERE 
    	cod_param = vparametro2;
    IF ip_destino is null
    	THEN
        	LET cod_err = '99999';
    END IF;

    SELECT valor
	INTO dominio 
    FROM BDISAC:sac_param
    WHERE 
    	cod_param = vparametro3;
    
    IF dominio = '' or dominio is null
    	THEN
        	LET cod_err = '99998';
    END IF;

    SELECT valor
	INTO usrname 
    FROM BDISAC:sac_param
    WHERE 
    	cod_param = vparametro4;
    
    IF usrname = '' or usrname is null
    	THEN
        	LET cod_err = '99997';
    END IF;

    SELECT valor
	INTO psswrd 
    FROM BDISAC:sac_param
    WHERE 
    	cod_param = vparametro5;
    
    IF psswrd = '' or psswrd is null
    	THEN
        	LET cod_err = '99996';
    END IF;

	SELECT 
		session_id
		into ssn_id
	from
		sac_bts_encabezado;
	
	IF ssn_id = '' or ssn_id is null
    		THEN
        	LET cod_err = '99995';
    	END IF;
	
	SELECT 
		valor
		into num_reintentos
	from
		BDISAC:sac_param
		where cod_param = vparametro6;
	
	IF num_reintentos = '' or num_reintentos is null
    		THEN
        	LET cod_err = '99994';
    	END IF;
    	
    	RETURN cod_err, ip_origen, ip_destino, dominio, usrname, psswrd, ssn_id, num_reintentos;

    	END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_calculo_scpropietario(pempresa CHAR(3),csolicitud CHAR (20),vgrupo_sol CHAR(1),v_tpsol CHAR(1),v_respsic CHAR(1),v_meses SMALLINT,cProducto CHAR(20)) 
returning integer;
		
DEFINE scod_ret                	CHAR(5);
DEFINE vsqlerr                 	INTEGER;
DEFINE p_cod_ret               	CHAR(6);	
DEFINE vAntiguedad				CHAR(1); 
DEFINE v_scp_min,iPlazo			integer; 
DEFINE v_valor_2s,v_lineaban  	DECIMAL(14,2);
DEFINE v_cuantos 				SMALLINT;
DEFINE v_capacidad_pago  		MONEY(14,2);  
DEFINE vMensaje  				VARCHAR(255);

LET scod_ret                	= "000";
LET vsqlerr                 	= 0;
LET p_cod_ret               	= "000000";
LET vAntiguedad 				= "0";
LET v_scp_min  					= 0; 
LET v_valor_2s   				= 0;
LET v_cuantos    				= 0;  
LET v_lineaban   				= 0; 
LET v_capacidad_pago 			= 0; 
LET iPlazo 						= 0;
LET vMensaje 					="";
BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET scod_ret=vsqlerr;
		  RETURN scod_ret;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;			
	
	--Extrae Valor de Parametro
	SELECT valor
	  INTO v_cuantos
	  FROM bdisolic:"informix".ss_param
	 WHERE empresa = pempresa
	   AND secuencia = 300;

	IF (v_meses <= v_cuantos) THEN
		LET vAntiguedad = "1";
	END IF;				   		   
-- se les asigno vAntiguedad = "0" a los clientes con 1 mes de antiguedad // lalo 28jun07
	IF (v_meses = 1)  THEN
		LET vAntiguedad = "0";
	END IF;				   
			
	EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(pempresa,csolicitud,vAntiguedad)
	INTO p_cod_ret, v_lineaban,v_capacidad_pago,iPlazo;
			
	EXECUTE PROCEDURE bdisolic:"informix".calulavariables_modelo2(pempresa,csolicitud,v_lineaban,v_capacidad_pago)
	INTO p_cod_ret, vMensaje;

	IF p_cod_ret <> '000' then
		LET p_cod_ret= '00007'; -- ocurrio un error al calcular las variables del modelo2
        RETURN ;
    ELSE
        LET p_cod_ret= "000000";
    END IF;
			
	EXECUTE PROCEDURE bdisolic:"informix".calculo_parametrico(csolicitud) INTO v_valor_2s;
    
	IF  v_valor_2s IS NULL THEN
        LET  v_valor_2s= 0; -- No se localizaron puntos a sumar para la secciÃ³n 2
    END IF;
			
return v_valor_2s;

end;
end procedure;
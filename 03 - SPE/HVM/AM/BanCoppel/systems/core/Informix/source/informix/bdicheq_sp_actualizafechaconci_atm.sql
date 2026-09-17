CREATE PROCEDURE "informix".sp_actualizafechaconci_atm()

RETURNING 	CHAR(5) as codret, 
			CHAR(50) as seguros_atm,
			CHAR (50) as donativos_atm;

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
-- Variables 
	DEFINE vcod_ret 	CHAR(5);
	DEFINE vcod_ret2	CHAR(10);
	DEFINE vcod_ret3	CHAR(10);
	DEFINE vsqlerr		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE desc_err		CHAR(50);
--
	DEFINE p_empresa     	CHAR(3);
	DEFINE p_proceso1   	CHAR(20);
	DEFINE p_proceso2   	CHAR(20);
	DEFINE p_fecha_hoy   	DATE ;
	DEFINE p_fecha_proc1   	DATE ;
	DEFINE p_fecha_proc2   	DATE ;
--
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET vcod_ret	= "0000";
	LET vcod_ret2	= " ";
	LET vcod_ret3	= " ";
	LET vsqlerr		= 0;
	LET isam_err	=0;
	LET desc_err	= " ";
	--
	LET p_empresa		='001';
	LET p_proceso1		= 'concisegatm';
	LET p_proceso2		='concidonativos';
	LET p_fecha_hoy		='';
	LET p_fecha_proc1	='';
	LET p_fecha_proc2	='';
--  
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
	
	
	ON EXCEPTION SET vsqlerr, isam_err, desc_err
	
		SET DEBUG FILE TO "/RESPALDOSNEW/sp_actualizafechaconci_atm.err";
		TRACE ON;
		
	IF vsqlerr <> 0 THEN 
		LET vcod_ret	= vsqlerr;
        LET vcod_ret2	= isam_err;
        LET vcod_ret3	= desc_err;
	RETURN vcod_ret,vcod_ret2,vcod_ret3;	
	END IF
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--	SET DEBUG FILE TO "/RESPALDOSNEW/sp_actualizafechaconci_atm.out";
	--	TRACE ON;
--
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	
--SE OBTIENEN FECHA DEL DIA CORRIENTE
	SELECT fecha_hoy 
		INTO p_fecha_hoy
	FROM bdicheq:sc_fechas;

--SE OBTIENEN FECHA DEL PRIMER PROCESO 

	SELECT  fecha
		INTO p_fecha_proc1
	FROM bdicheq:sc_contproc 
	WHERE	proceso	= p_proceso1
	AND		empresa	= p_empresa;
-- SE EVALUA SI ES NECESSARIO ACTUALIZAR LAS FECHAS DE LOS PROCESOS INVOLUCRADOS
	
	IF p_fecha_proc1 <> p_fecha_hoy THEN 
	
		UPDATE bdicheq:sc_contproc
			SET FECHA = p_fecha_hoy
		WHERE	proceso	= p_proceso1
		AND		empresa	= p_empresa;
		LET vcod_ret2='0000';
		
		ELSE

			IF p_fecha_proc1 = p_fecha_hoy THEN
			
			LET vcod_ret2 =SUBSTR(p_fecha_proc1,7,4)||'-'||SUBSTR(p_fecha_proc1,1,2)||'-'||SUBSTR(p_fecha_proc1,4,2);
			LET p_fecha_proc1 = '';
			END IF;
	END IF;

--SE OBTIENEN FECHA DEL SEGUNDO PROCESO 

	SELECT  fecha
		INTO p_fecha_proc2
	FROM bdicheq:sc_contproc 
	WHERE	proceso	= p_proceso2
	AND		empresa	= p_empresa;	

-- SE EVALUA SI ES NECESSARIO ACTUALIZAR LAS FECHAS DE LOS PROCESOS INVOLUCRADOS
	
	IF p_fecha_proc2 <> p_fecha_hoy THEN 
		
		UPDATE bdicheq:sc_contproc
			SET FECHA = p_fecha_hoy
		WHERE	proceso	= p_proceso2
		AND		empresa	= p_empresa;
		LET vcod_ret3='0000';
		
		ELSE
		
			IF p_fecha_proc2 = p_fecha_hoy THEN
		
			LET vcod_ret3 =SUBSTR(p_fecha_proc2,7,4)||'-'||SUBSTR(p_fecha_proc2,1,2)||'-'||SUBSTR(p_fecha_proc2,4,2);
			LET p_fecha_proc2 = '';
			END IF;
	END IF;

--
-- ****************************************************************************
-- *                 FIN DE PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	RETURN vcod_ret, vcod_ret2, vcod_ret3;
END
END PROCEDURE;
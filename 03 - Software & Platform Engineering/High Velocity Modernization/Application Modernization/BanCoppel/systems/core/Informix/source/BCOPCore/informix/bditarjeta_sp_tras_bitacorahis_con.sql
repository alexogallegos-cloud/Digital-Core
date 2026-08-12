CREATE PROCEDURE "informix".sp_tras_bitacorahis_con(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	DEFINE  iNumReg          INTEGER;
	
	--SET DEBUG FILE TO "/tmp/manuel/tras.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Error en sp_tras_bitacorahis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Manuel Osuna Valencia 
-- fecha : 19/10/2011
-- Funcion: Traspaso de Informacion de bitacora a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRASNFERENCIA DE BITACORA A HISTORICOS';
   LET iValor = 0;
   LET iNumReg = 0;
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '402';
	
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '00000';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		SELECT fecha_hoy - iValor units day INTO dFechaFin   FROM bdinteg:"informix".si_fechas;				
		
		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_his(consecutivo,elemento,fecha_hora,actividad,cve_usuario)
		SELECT consecutivo,elemento,fecha_hora,actividad,cve_usuario
		FROM bditarjeta:"informix".td_bitacora_conciliacion
		WHERE date(fecha_hora) <= dFechaFin;
						
		LET iNumReg =dbinfo("sqlca.sqlerrd2");
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('46','Exito en Traspaso de  Bitacora a Historico (sp_tras_bitacorahis_con) ' || iNumReg  || ' ' || 'Registros Transferidos',cNumEmpl) INTO P_COD_RET;
				
		DELETE FROM bditarjeta:"informix".td_bitacora_conciliacion	WHERE date(fecha_hora) <= dFechaFin;	   

	
	END IF;
     
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE;
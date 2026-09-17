CREATE PROCEDURE "informix".sp_actualiza_lincred_central_masivo(P_empresa CHAR(3), P_num_credito CHAR(20), Pmonto DECIMAL(18,2) , Ptipo CHAR(1),Pstatus CHAR(1),Pusuario CHAR(20))
              
RETURNING CHAR(6),
          VARCHAR(80);  
--Héctor Manuel Bojórquez Ruelas
--08  DE Junio DE 2011
--actualiza la linea de credito central y genera un movimiento en la movdia, así como tambien genera un registro del crédito en sd_bitacora_aumlincred y en  sd_autorizacion_aumlincred
--Folio 1258-BitácoraIncrementoLinCred

		  
--Roque Enrique Solis Campaña 
--20  DE DICIEMBRE DE 2008
--actualiza la linea de credito central y genera un movimiento en la movdia 
--19 DE FEBRERO DE 2009
--El movimiento se genera con la cantidad la diferencia del monto actual y el monto nuevo


--Modificación	  
--Juan Daniel Lazalde Centeno
--12  DE FEBRERO DE 2014
--Identificar si el usuario, que esta realizando la operación esta registrado en la tabla bdicred:sd_perfiles_cac_aumlincred y ponga en el campo roigen = "S" Sucursal 
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret 		CHAR(6);
DEFINE cCod_ret 		CHAR(6);
DEFINE vsqlerr 			INTEGER;

DEFINE c_num_producto 	CHAR(4);
DEFINE c_divisa 		CHAR(2);
DEFINE c_sucursal 		CHAR(4);
DEFINE d_fecha_hoy 		DATE;
DEFINE c_transacc_suc 	CHAR(4);
DEFINE c_folio_suc 		VARCHAR(20);
DEFINE p_cod_ret 		VARCHAR(10);
DEFINE p_mensaje 		VARCHAR(80);
DEFINE d_hora           DATETIME HOUR TO SECOND;
DEFINE cDif			    CHAR (1);
DEFINE mMontoanterior   DECIMAL(18,2);
DEFINE cNum_cte         CHAR(20);
DEFINE cNombre_cte      CHAR(100);
DEFINE mMontoMov        DECIMAL(18,2);
DEFINE mMontoDif        DECIMAL(18,2);
DEFINE v_nombre_usuario CHAR(100);
DEFINE cNumCte          CHAR(20);
DEFINE cGradoRiesgo     CHAR(2);
DEFINE dMontoReserva    DECIMAL(18,2);
DEFINE valorsm			DECIMAL(18,2);
DEFINE smblinsug		DECIMAL(18,2);
DEFINE cCalifBuro       CHAR(1);
DEFINE cMotivoRechazo   CHAR(255);
DEFINE cCompromiso      DECIMAL(14,2);
DEFINE iReg             INTEGER;
DEFINE cOrigen          CHAR(1);


-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************

LET scod_ret		 = "000000";
LET cCod_ret		 = "000000";
LET vsqlerr			 = 0;
LET c_num_producto	 ="";
LET c_divisa		 ="";
LET c_sucursal		 ="";
LET d_fecha_hoy		 = DATE(1);
LET c_transacc_suc	 ="";
LET c_folio_suc		 ="";
LET p_cod_ret		 ="";
LET p_mensaje		 =""; 	
LET d_hora           = CURRENT HOUR TO SECOND;
LET cDif			 ="";
LET mMontoanterior	 = 0;
LET cNum_cte		 ="";
LET cNombre_cte		 ="";
LET mMontoMov 	     = 0;
LET mMontoDif        = 0;
LET v_nombre_usuario = "";
LET cNumCte          = "";
LET cGradoRiesgo     = "";
LET dMontoReserva    = 0;
LET valorsm			 = 0;
LET smblinsug	     = 0;
LET cCalifBuro       = ""; 
LET cMotivoRechazo   = "";
LET cCompromiso      = 0;
LET cOrigen          = "";

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
    ON EXCEPTION SET vsqlerr
       IF vsqlerr != 0 THEN
          LET scod_ret=vsqlerr;
		  ROLLBACK WORK;
          RETURN scod_ret, p_mensaje ;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/hectorb/actualiza_lincred.out";
	--TRACE ON;

    -- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT monto_otorgado
    INTO mMontoanterior
    FROM "informix".sd_maesdos 
    where num_credito=P_num_credito;

	IF (mMontoanterior is not null) THEN
	   
--	   EXECUTE PROCEDURE bdicred:"informix".sp_consultacredito_central( P_empresa, P_num_credito) INTO p_cod_ret, p_mensaje, cNum_cte,cNombre_cte,mMontoanterior ;
        
		UPDATE "informix".sd_maesdos
		SET monto_otorgado=Pmonto
		WHERE empresa=P_empresa AND num_credito=P_num_credito;
		
		SELECT num_producto, sucursal , divisa, numcte 
		INTO   c_num_producto, c_sucursal, c_divisa, cNum_cte
		FROM   "informix".sd_maecred
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito;

		--Obtener la fecha del dia	
		SELECT fecha_hoy
		INTO   d_fecha_hoy
		FROM   "informix".sd_fechas
		WHERE  empresa = P_empresa;
        
		-- obtener el valor del salario minimo de la zona C
		SELECT valor 
		INTO valorsm
		FROM "informix".sd_param 
		WHERE empresa   = P_empresa 
		AND cod_param = '013';
		
		
		SELECT grado_riesgo,NVL(reserva_calificacion,0.00)
		INTO cGradoRiesgo, dMontoReserva
		FROM "informix".sd_hist_reserva
		WHERE  empresa     = P_empresa
		AND    num_credito = P_num_credito
		AND   fecha_cierre = (SELECT  MAX(fecha_cierre)
                    FROM "informix".sd_hist_reserva
                    WHERE  empresa     = P_empresa
                    AND    num_credito = P_num_credito);
		
		
	    LET  c_transacc_suc  = '0000';
		LET  c_folio_suc = 'Act LineaCredito';
        
        IF mMontoanterior < Pmonto THEN
		    LET cDif = '1';
            LET mMontoDif = Pmonto-mMontoanterior;
		ELSE
		    LET cDif = '2';
            LET mMontoDif = mMontoanterior-Pmonto;
		END IF;

		EXECUTE PROCEDURE "informix".GENMOV( P_empresa, P_num_credito
                                 , c_num_producto , cDif
                                 ,'008' , d_fecha_hoy
                                 , mMontoDif , c_folio_suc
                                 , c_sucursal, c_divisa
                                 , c_transacc_suc
                                 ) INTO p_cod_ret, p_mensaje;

		IF p_cod_ret::INTEGER > 0 THEN
			LET scod_ret= '000002'; 
			LET p_mensaje="Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	   	
			RETURN scod_ret, p_mensaje;   
		END IF;

		LET smblinsug = Pmonto / (30.42 * valorsm);
				
		---Obtiene la  calificacion buro para actualizar el campo  califica_buro de la tabla sd_bitacora_aumlincred
		EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(P_empresa, cNum_cte, P_num_credito) 
		INTO  cCod_ret, 	    -- Codigo de Retorno
              cCalifBuro,	    -- Calificacion 1 Aprobado, 0 Rechazado
		      cCompromiso,      -- Compromisos > 0 si Calificacion es 1
		      cMotivoRechazo;   -- Descripcion de Creditos Motivo de Rechazo
		
		
		--Lazalde: Validar si el usuario existe en sd_perfiles_cac_aumlincred para identificar a que origen "SUCURSAL ó CENTRAL" se esta realizando el incremento de linea de crédito
		IF EXISTS(SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred where empresa = P_empresa AND ejecutivo = Pusuario) THEN
			LET cOrigen = 'S';
		ELSE
			LET cOrigen = 'C';
		END IF
		
		
		INSERT INTO "informix".sd_bitacora_aumlincred
		(empresa, num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,
		smb_lincred,grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert)
		VALUES (P_empresa,P_num_credito,cNum_cte,'6001','AP','',d_fecha_hoy,d_hora,c_sucursal,mMontoanterior,Pmonto,smblinsug,
		cGradoRiesgo,dMontoReserva,cCalifBuro,'1',Ptipo, Pusuario,'0000',cOrigen,Pusuario,d_fecha_hoy);

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000004";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;
		

		INSERT INTO "informix".sd_autorizacion_aumlincred 
		(empresa, num_solicitud, status,causa_status,user_insert,fecha_status,fecha_insert, revision_cac)     		
		VALUES(P_empresa,P_num_credito,'AP','',Pusuario,d_fecha_hoy,d_fecha_hoy,0);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET scod_ret = "000005";
			LET p_mensaje = "Ocurrio un error al guardar la información en la bitacora de autorización de aumento de linea de crédito";
			RETURN scod_ret, p_mensaje;   
		END IF;

	ELSE
       LET scod_ret= '000001'; 
       LET p_mensaje="No es posible realizar la actualizacion";	   
	END IF
	

    RETURN scod_ret, p_mensaje;   
          
END;
END PROCEDURE;
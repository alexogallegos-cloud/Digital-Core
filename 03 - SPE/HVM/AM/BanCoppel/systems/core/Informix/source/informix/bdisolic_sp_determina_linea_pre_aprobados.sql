CREATE PROCEDURE "informix".sp_determina_linea_pre_aprobados(cNumSolicitud CHAR(12),iOpcion SMALLINT)
RETURNING  CHAR(6) As Retorno,
           CHAR(12) As Numero_Solicitud,
		   CHAR(12) As Aumento_Preaprobado
		 
DEFINE iSqlErr  	INTEGER;
DEFINE cCodRet  	CHAR(6);
DEFINE cSql			CHAR(1000);
DEFINE cLineaCredito DECIMAL(12,2);
DEFINE cLineaUdis DECIMAL(12,2);
DEFINE cEstatus_sol CHAR(5);
DEFINE cMonto_Aut DECIMAL(12,2);
DEFINE cRegional CHAR(3);
DEFINE iValidaMop99 INTEGER;
DEFINE cCliente CHAR(20);
DEFINE iTipoRes INTEGER;
DEFINE cProducto CHAR(4);
DEFINE cCanal VARCHAR(4);




LET iSqlErr			= 0;
LET cCodRet 		= '000000';
LET cSql 			= '';
LET cLineaCredito  = 0;
LET cLineaUdis     = 0;
LET cEstatus_sol   = '';
LET cMonto_Aut     = 0;
LET cRegional      ='';
LET iValidaMop99   = 0;
LET cCliente = '';
LET iTipoRes = 0;
LET cProducto = '';
LET cCanal = '0';


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret,cNumSolicitud,cLineaCredito;
		END IF;
	END EXCEPTION;

	 --SET DEBUG FILE TO "/informix/mc/sp_aumento_pre_aprobados.out";
	 --TRACE ON;
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  TRIM(NVL(cNumSolicitud,'')) != '' THEN
			
			--Bloque para validar MOP99
			SELECT numcte, num_producto,status_solicitud,monto_autorizado,regional INTO cCliente, cProducto, cEstatus_sol,cMonto_Aut, cRegional
			FROM bdisolic:ss_solicitudes 
			WHERE num_solicitud = cNumSolicitud;
			
			IF cProducto <> '6800' THEN
				SELECT COUNT(1) INTO iValidaMop99 FROM bdiburo:br_tl WHERE num_cliente = cCliente AND tl26 = '99';
				
				SELECT tipo_respuesta INTO iTipoRes FROM bdicred:catalogo_errores_buro_oc WHERE numsol = cNumSolicitud;
				
				IF iValidaMop99 > 0 THEN
				  EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol('001', 'sistema',cNumSolicitud, 'RT','', 'Rechazado por MOP 99')
				  INTO cCodRet;
				  LET cLineaCredito = 0;
				  LET cCodRet = '000005'; --Valida que la solicitud del cliente este rechazada por buro MOP 99
				  RETURN cCodret,cNumSolicitud,cLineaCredito;
				END IF;

			  --Bloque para validar RT
			   IF cEstatus_sol = 'RT' THEN
				LET cLineaCredito = 0;
				LET cCodRet = '000006'; --Se valida que la solicitud tenga rechazo por RT
				RETURN cCodret,cNumSolicitud,cLineaCredito;
			   END IF;
			  --Fin Bloque para validar RT
			END IF;

		  
		  IF cRegional = 'APP' THEN
		    SELECT linea_final  INTO cLineaCredito FROM bdisolic:"informix".ss_revision_determinacion
	        WHERE num_solicitud = cNumSolicitud; -- 6800 -- 2 -- cLineaCredito -- 0
			IF cLineaCredito IS NULL OR cLineaCredito = 0 OR iTipoRes = 2 THEN
		       LET cLineaCredito = cMonto_Aut;
		    END IF;
		       IF cLineaCredito > cMonto_Aut THEN
		          UPDATE bdisolic:"informix".ss_solicitudes SET monto_autorizado = cLineaCredito,monto_solicitado = cLineaCredito
	              WHERE  num_solicitud = cNumSolicitud;
		       END IF;
		           IF cEstatus_sol = 'BC' THEN
		               EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol('001', 'sistema',cNumSolicitud, 'AT','ASP', 'Autorizada')
			           INTO cCodRet;
		           END IF;
			   UPDATE bdisolic:"informix".ss_revision_determinacion SET linea_credito = cLineaCredito,linea_final = cLineaCredito,
			   estatus_sol='AT',causa_rechazo = 'Autorizada'
	           WHERE  num_solicitud = cNumSolicitud;
		  	RETURN cCodret,cNumSolicitud,cLineaCredito;
		  END IF;
		  
		  IF cEstatus_sol <> 'BC' AND iOpcion = 0 THEN -- SI ESTATUS ES AT ENTRA POR AQUI
	
	        SELECT linea_final INTO cLineaCredito FROM bdisolic:"informix".ss_revision_determinacion
	        WHERE num_solicitud = cNumSolicitud;
		
		    SELECT valor  INTO cLineaUdis FROM bdicred:"informix".sd_pre_aprobados_param
	        WHERE codparam = 11;
			
			IF  cLineaUdis >= cLineaCredito OR cLineaCredito IS NULL THEN
			    LET cLineaCredito = cLineaUdis;
				LET cCodRet = '000003'; -- Se agrego este codigo para validar que no aparezca el mensaje que tiene buen comportamiento
			END IF;
			
	        UPDATE bdisolic:"informix".ss_solicitudes SET monto_autorizado = cLineaCredito,monto_solicitado = cLineaCredito
	        WHERE  num_solicitud = cNumSolicitud;
			 
		   ELIF cEstatus_sol = 'BC' AND iOpcion = 1 THEN
		   
		    EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol('001', 'sistema',cNumSolicitud, 'AT','ASP', 'Autorizada')
			INTO cCodRet;
			LET cLineaCredito = cMonto_Aut;
			LET cCodRet = '000011';
		   ELSE
			   LET cLineaCredito = cMonto_Aut;
			   LET cCodRet = '000010';
		   END IF;			 
	ELSE
		LET cCodret = '000004'; -- 000003
	END IF;
	
    IF cLineaCredito IS NULL OR cLineaCredito = 0 OR iTipoRes = 2 THEN
	   LET cLineaCredito = cMonto_Aut;
    END IF;
	
	IF iTipoRes = 2 AND cProducto = '6001' THEN
		LET cCodRet = '000000';
	END IF;
	
	UPDATE bdisolic:"informix".ss_revision_determinacion SET  linea_credito = cLineaCredito,linea_final = cLineaCredito,
	estatus_sol='AT',causa_rechazo = 'Autorizada' WHERE  num_solicitud = cNumSolicitud;
	
	IF iOpcion = 1 THEN --Si es la ultima vez que se manda llamar el SP en el flujo
	-- SI la fecha_sic es NULL se cambia por el valor dafault
		update bdisolic:"informix".ss_solicitudes_sic 
		set fecha_sic = Date(1) 
		Where 
		numcte = cCliente
		AND num_solicitud = cNumSolicitud 
		AND fecha_sic IS NULL;
	END IF;	
	
	RETURN cCodret,cNumSolicitud,cLineaCredito;	
END;
END PROCEDURE

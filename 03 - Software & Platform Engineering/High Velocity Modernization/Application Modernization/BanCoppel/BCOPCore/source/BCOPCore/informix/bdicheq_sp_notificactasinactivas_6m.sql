CREATE PROCEDURE "informix".sp_notificactasinactivas_6m( pEmpresa char(3) )
RETURNING CHAR(5);
       
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
	DEFINE vSp_CodRet       CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vFechaHoy        DATE;
	DEFINE vDiasInformada6m INTEGER;
    DEFINE vCuenta          CHAR(20);
    DEFINE vNumCliente      CHAR(20);
    DEFINE vStatusCta       CHAR(1);
    DEFINE vProducto        CHAR(4);
    DEFINE vSdoActual       DECIMAL(18,2);
    DEFINE vFechaUltimoDep  DATE;
    DEFINE vFechaUltimoRet  DATE;
    DEFINE vFechaAlta       DATE;
    DEFINE vDiasSinTransacc INTEGER; 	
	DEFINE vTermCta         CHAR(20);
	DEFINE vDi6m 			INTEGER;
	DEFINE vUltFech			DATE;
	DEFINE vDescProd        CHAR(40);
	DEFINE vIdProd          CHAR(4);
	
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '00000';
	LET vSp_CodRet   = '00000';
    LET vCodRet2     = '00000';
    LET vCodRet3     = '';
    LET vEnTransacc  = 0;
    LET vFechaHoy         = '';
	LET vDiasInformada6m  = 0;
    LET vCuenta           = '';   
    LET vNumCliente       = '';
    LET vStatusCta        = '';
    LET vProducto         = '';
    LET vSdoActual        = 0.00;
    LET vFechaUltimoDep   = '';
    LET vFechaUltimoRet   = '';
    LET vFechaAlta        = '';
    LET vDiasSinTransacc  = 0;
    LET vTermCta = '';
	Let vDi6m = 0;
	LET vUltFech = '';
	LET vDescProd        = '';
	LET vIdProd  		 = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_notificactasinactivas_6m.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
           RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    ---SET DEBUG FILE TO "/resplogifx/conciliachq/sp_notificactasinactivas_6m.out";
    ---TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
	 
    -- // OBTIENE EL NUMERO DE DÃAS INICIALES PARA NOTIFICAR ESTATUS DE CUENTA
    SELECT valor::INT
      INTO vDiasInformada6m
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaInformada6';
	   Let vDi6m = vDiasInformada6m;
	   	   
	--TABLE QUE TIENE LOS CLIENTES CON ESTATUS FALLECIDOS. 
	
	CREATE TEMP TABLE tmp_fallecido( num_cte char(20))
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX idx_tmp_fallecido ON tmp_fallecido(num_cte) USING BTREE;
	
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_fallecido;
				
	INSERT INTO tmp_fallecido
	SELECT DISTINCT(numcte)  
	  FROM bdisitesp:se_ctessitespcte 
	 WHERE situacion = 'F' AND causa  IN('42','43');
	   
	----------------------------------------------------------------------------------------------------------------
	
	--VALIDA EL NUMERO DE DÃAS DE INACTIVIDAD DE LA CUENTA PARA ENVIO DE NOTIFICACIÃN 6M
	
	 FOREACH WITH HOLD		   
		SELECT CASE WHEN fecultdep > fecultret THEN fecultdep
					WHEN fecultret > fecultdep THEN fecultret 
					WHEN fecultret = fecultdep THEN fecultdep 
					WHEN fecultdep = fecultret THEN fecultret
					WHEN fecultdep IS NULL AND fecultret IS NOT NULL THEN fecultret
					WHEN fecultret IS NULL AND fecultdep IS NOT NULL THEN fecultdep END vUltFech,
			   mae.cuenta, mae.num_cte, mae.status_cta, mae.producto, mae.sdo_actual, mae.fecultdep, mae.fecultret , noc.fecha_alta 
          INTO vUltFech, vCuenta, vNumCliente, vStatusCta, vProducto, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc
         WHERE mae.status_cta IN('1','4')
		   AND ( mae.producto <> '1100' AND mae.producto NOT LIKE '99%' )
           AND ( ( ( vFechaHoy - mae.fecultdep ) = vDiasInformada6m ) OR ( ( vFechaHoy - mae.fecultret ) = vDiasInformada6m ) ) 
		   AND mae.cuenta = noc.cuenta 
		   AND mae.sdo_actual > 0.00 
		   AND mae.fecha_proceso = vFechaHoy
		   AND mae.num_cte NOT IN(SELECT DISTINCT(num_cte) FROM tmp_fallecido) 

		 SELECT PD.nombre, PD.producto
		  INTO vDescProd, vIdProd
		  FROM bdicheq:sc_producto PD
		  WHERE PD.producto = vProducto;
		  
	  BEGIN WORK;                
        LET vDiasSinTransacc = vFechaHoy - vUltFech;
		
		IF (vDiasSinTransacc == vDi6m) THEN
		
		LET vTermCta = TRIM(SUBSTR(vCuenta,8,4));
			      
			---- REALIZA LA NOTIFICACION MENDIANTE SMS
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CTAS_INACS','CTAS_INACS2',vNumCliente,'','','2',vTermCta,'','','','','','','','','','','',0,0,0,0,0,'','') ---- NotificaciÃ³n de SMS 2a 6m (916 DÃ­as)  
			INTO vSp_CodRet; 

			---- REALIZA LA NOTIFICACION MENDIANTE CORREO ELECTRONICO			  
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CTAS_INAC','CTAS_INAC2',vNumCliente,'','','2',vTermCta,'180','','',TRIM(vDescProd),'','','','','','','',0,0,0,0,0,CURRENT,'') ----  NotificaciÃ³n de Email 2a 6m (916 DÃ­as)
			INTO vSp_CodRet;

			INSERT INTO bdicheq:control_ctas_6m 
			(cuenta, num_cte, fecultdep, fecultret,ultimafech, param)
			VALUES
			(vCuenta,vNumCliente, vFechaUltimoDep, vFechaUltimoRet , vUltFech, vDiasSinTransacc);
					
		END IF;	

		
        COMMIT WORK;
    END FOREACH;
	
	DROP TABLE tmp_fallecido; 
    
    END;
		
    RETURN vCodRet1;
     
END PROCEDURE;
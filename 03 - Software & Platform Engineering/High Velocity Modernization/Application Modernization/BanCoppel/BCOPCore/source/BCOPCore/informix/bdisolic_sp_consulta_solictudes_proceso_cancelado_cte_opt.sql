CREATE PROCEDURE "informix".sp_consulta_solictudes_proceso_cancelado_cte_opt(pNumCte CHAR(20), pSucursal CHAR(4))
RETURNING CHAR(5)  AS cCodRet,
		  CHAR(30)   AS cNumSolicitud,
          CHAR(2)   AS cStatusSol ,
		  CHAR(4) As cNumProd,
		  CHAR(1) As cTpSolicitud;

    -- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************

	DEFINE cCodRet 			CHAR(5);	
	DEFINE cNumSolicitud  	CHAR(30);
	DEFINE cStatusSol  		CHAR(2);
	DEFINE cNumProd  		CHAR(4);
	DEFINE cTpSolicitud  	CHAR(1);
	DEFINE TP_CLIENTE  	INTEGER;
	DEFINE iSqlErr  		INTEGER;
	DEFINE dtFechahoy       DATE;
	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************
	LET iSqlErr				= 0;
	LET cCodRet				='00000';
	LET cNumSolicitud		='';
	LET cStatusSol			='';
	LET cNumProd			='';
	LET cTpSolicitud		='';
	LET TP_CLIENTE		=0;
	LET dtFechahoy          = DATE(1);
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;				
			RETURN cCodRet,cNumSolicitud,cStatusSol,cNumProd,cTpSolicitud;	
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
    
	--SET DEBUG FILE TO "/home/sysifx/sp_consulta_solictudes_proceso_cancelado_cte_opt.out";
	--TRACE ON;
	
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************
	
		SELECT fecha_hoy INTO dtFechahoy
		FROM bdinteg:"informix".si_fechas;
		
		SELECT tipo_cliente INTO TP_CLIENTE 
		FROM bdinteg: "informix".si_cliente 
		WHERE numcte=pNumCte;
		/*
		IF TP_CLIENTE=1 THEN 
			FOREACH
				SELECT num_solicitud,status_solicitud, num_producto, tipo_solicitud 
				INTO cNumSolicitud,cStatusSol, cNumprod, cTpSolicitud
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa = "001" AND numcte = pNumCte  
				AND sucursal=pSucursal
				AND status_solicitud IN ("EA","EE","CC","OA","OS","BC","ST","CE","MC","EC","PA","IN")
				AND fecha_insert=dtFechahoy
					
				RETURN cCodRet,cNumSolicitud,cStatusSol,cNumProd,cTpSolicitud WITH RESUME;
			END FOREACH;
		ELSE*/
		IF TP_CLIENTE=2 THEN 
			FOREACH
				SELECT num_solicitud,status_solicitud, num_producto, tipo_solicitud 
				INTO cNumSolicitud,cStatusSol, cNumprod, cTpSolicitud
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa = "001" AND numcte = pNumCte  
				AND sucursal=pSucursal
				AND status_solicitud IN ("EA","EE","CC","OA","OS","BC","ST","CE","MC","EC","PA","IN","AT")
				AND fecha_insert=dtFechahoy
					
				RETURN cCodRet,cNumSolicitud,cStatusSol,cNumProd,cTpSolicitud WITH RESUME;
			END FOREACH;
		END IF;
		--END IF;
	END;
END PROCEDURE

CREATE PROCEDURE "informix".sp_consulta_causas(pEmpresa CHAR(3), pStatus_solicitud CHAR(5) , pTipo char(1))
RETURNING
	CHAR(5)     AS Retorno ,           -- Codigo de Retorno	
	CHAR(100)   AS Descripcin_Causa,   -- Descripción de la causa de solicitud
	CHAR(60)    AS Descripcion_Status; -- Descripcion del Status de la Solicitud
	

	-- DEFINICION DE VARIABLES
	DEFINE cValRetorno      CHAR(5);
	DEFINE iSqlErr          INTEGER;
	DEFINE	vlRetorno	CHAR(5);           		 -- Codigo de Retorno
	DEFINE	vlCausa_solicitud 	CHAR(60);	 -- Descripcion del Status de la Solicitud
	DEFINE	vlDescripcin_Causa		CHAR(100);   -- Descripción de la causa de solicitud
	
	DEFINE vCantReg         SMALLINT;	
	DEFINE vCantReg2        SMALLINT;

	--INICIALIZACION DE VARIABLES
	LET cValRetorno      = "00000";
	---LET cValRetorno2     = "00000";
	
	LET	vlRetorno	='';
	LET	vlDescripcin_Causa		='';
	LET	vlCausa_solicitud		='';
	
	LET  vCantReg         = 0;
	LET  vCantReg2        = 0;
	
	
--	SET DEBUG FILE TO "/tmp/sp_consulta_rechazos_os.out";
--	TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','';
			END IF;
		END EXCEPTION;
		
		IF NVL(pEmpresa,'') = '' THEN
			LET cValRetorno = '00001';
			RETURN  	vlRetorno,	vlCausa_solicitud,vlDescripcin_Causa;			
		ELSE		  
			FOREACH
				select causa_solicitud,  descripcion
				  into vlCausa_solicitud, vlDescripcin_Causa
				 from bdisolic:ss_causas_sol 
                 where empresa = pEmpresa 
				   and status_solicitud =pStatus_solicitud
				   and tipo_auto =pTipo 
				 order by orden_reporte
				  
				  RETURN  vlRetorno,vlCausa_solicitud,	vlDescripcin_Causa	
					WITH RESUME;
			END FOREACH;				
	  END IF;		
	END
END PROCEDURE

CREATE PROCEDURE "informix".sp_consultarestadoprogramaciondetallada_ofi(cCVE_CLIENTE CHAR(10), cDESC_PROGRAMACION CHAR(20), nNUM_Consecutivo INT)
RETURNING
    CHAR(6),        -- Codigo Retorno
    CHAR(120),      -- Descripcion Error
	CHAR(65); 		-- Descripcion estatus rechazo
	
--##############################################################################
--## Procedimiento       : sp_ConsultarEstadoProgramacionDetallada_ofi
--## Version             : 1.0
--## Objetivo            : Obtener la descripcion de estado rechazado de un pago programado
--## Valores Entrada     :  cCVE_CLIENTE	--> clave del cliente
--## 			   cDESC_PROGRAMACION --> descripcion de la programacion
--## 			   nNUM_Consecutivo --> consecutivo de la programacion
--## Valores Retorno     : cCodRet -->   Código de Retorno.
--##                       	 cVarDataErr   -->  Descricpion del Error
--##                       	 cDescEstado --> Descripcion del estado del pago programado
--## Creado por          : Ing. Guillermo Santos
--## Fecha creacion      : Mayo de 2009
--##############################################################################	
	
--//Variables Locales
DEFINE cVarDataErr          VARCHAR(120);
DEFINE iSqlErr              INTEGER;
DEFINE iSamErr              INTEGER;
DEFINE cCodRet              CHAR(5);
DEFINE cDescEstado          VARCHAR(65);
DEFINE cCVE_PagoProg		CHAR(10);
DEFINE cCVE_Rechazo			CHAR(5);
DEFINE cDesc_Retorno		CHAR(50);
DEFINE cDesc_Rechazo		CHAR(50);

	--SET LOCK MODE TO WAIT 10;
BEGIN
	ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, cCodRet)
               INTO cCodRet, cVarDataErr;
        END IF;
        RETURN cCodRet, cVarDataErr, NULL;
    END EXCEPTION; 
	
	SET LOCK MODE TO WAIT 10;
	SET ISOLATION TO DIRTY READ;
	SELECT cod_ret, desc_mensaje
	  INTO cCodRet, cVarDataErr
	  FROM  BDIPROG:PP_MENSAJES
	 WHERE cve_mensaje = "00";
	
	LET cCVE_PagoProg = '';
	LET cCVE_Rechazo = '';
	LET cDescEstado = '';
	
	LET cDesc_Retorno = '';
	LET cDesc_Rechazo = '';
	
	SET LOCK MODE TO WAIT 10;
	SET ISOLATION TO DIRTY READ;
	SELECT cve_pagoprog INTO cCVE_PagoProg
	  FROM bdiprog:pp_pagoprog 
     WHERE trim(num_cte)=trim(cCVE_CLIENTE) 
	   and upper(trim(descripcion))=upper(trim(cDESC_PROGRAMACION));

	IF (cCVE_PagoProg is not null And cCVE_PagoProg <> '') THEN
		SET LOCK MODE TO WAIT 10;
		SET ISOLATION TO DIRTY READ;
		SELECT cve_rechazo INTO cCVE_Rechazo
		  FROM bdiprog:pp_pagospend 
		 WHERE trim(cve_pagoprog) = trim(cCVE_PagoProg) 
		   and consecutivo = nNUM_Consecutivo;
		   
		IF (cCVE_Rechazo is not null And cCVE_Rechazo <> '') THEN
			SET LOCK MODE TO WAIT 10;
			SET ISOLATION TO DIRTY READ;
			
			SELECT descripcion INTO cDesc_Rechazo
			  FROM pp_tprechazo 
			 WHERE trim(cve_rechazo) = trim(cCVE_Rechazo);
			 
			SET LOCK MODE TO WAIT 10;
			SET ISOLATION TO DIRTY READ;
			 
			SELECT descripcion INTO cDesc_Retorno
			  FROM bdinteg:si_codret 
			 WHERE trim(codigo_retorno)=trim(cCVE_Rechazo)
			   And sistema='01';
			 
			IF (cDesc_Retorno is not null And cDesc_Retorno <> '') THEN
				LET cDescEstado =  cDesc_Retorno;
			ELSE
				LET cDescEstado =  cDesc_Rechazo;
			END IF			
		ELSE
		END IF
	ELSE
	END IF

	RETURN cCodRet, cVarDataErr, cDescEstado;
END;
END PROCEDURE;
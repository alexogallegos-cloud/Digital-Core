CREATE PROCEDURE "informix".sp_consulta_sac_reportedomiciliacion_totales( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE, pSucursal CHAR(4))
	RETURNING CHAR(5) AS codret,INTEGER AS totRegistros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reportedomiciliacion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF nvl(pSucursal,'') ='' THEN

	    SELECT COUNT (*) as numfilas
		INTO iTotales
		FROM bdisac:sac_reportediariodomi_seg
		WHERE fecha_pago BETWEEN pFecha_inicial AND pFecha_final;

		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
				
		ELSE 
		
		SELECT COUNT (*) as numfilas
		INTO iTotales
		FROM bdisac:sac_reportediariodomi_seg
		WHERE fecha_pago BETWEEN pFecha_inicial AND pFecha_final AND sucursal_alta=pSucursal;

		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
		

		END IF;

	END;		

END PROCEDURE;
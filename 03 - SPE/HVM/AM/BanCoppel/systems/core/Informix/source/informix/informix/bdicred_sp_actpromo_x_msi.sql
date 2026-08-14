CREATE PROCEDURE "informix".sp_actpromo_x_msi(pFechaCort DATE)
--EXECUTE PROCEDURE "informix".sp_actpromo_x_msi(MDY('03','20','2023'));
RETURNING CHAR(5) AS CodigoRetorno;

	---DECLARACIONES
    DEFINE iSqlErr					INTEGER;
    DEFINE iIsamErr					INTEGER;
    DEFINE cErrorInfo				VARCHAR(80);
    DEFINE cCodRet					CHAR(5);
	DEFINE vNumCred					CHAR(20);
	DEFINE vFolioMov				CHAR(16);
	DEFINE vNumCte					CHAR(20);
	DEFINE vNumTarjeta				CHAR(20);
	DEFINE vNumMsi					CHAR(20);
	DEFINE vFechaCompra				DATE;
	DEFINE vDetCompra				VARCHAR(40);
	DEFINE vComercio				CHAR(19);
	DEFINE vMtoCompra				DECIMAL(19,2);
	DEFINE contador_commit			INTEGER;
	DEFINE val_trans_Commit			INTEGER;
	DEFINE vBanderaMsi				CHAR(1);
		
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET cErrorInfo					= '';
	LET cCodRet						= '00000';
	LET vNumCred					= '';
	LET vFolioMov					= '';
	LET vNumCte 					= '';
	LET vNumTarjeta					= '';
	LET vNumMsi						= '';
	LET vFechaCompra				= DATE(1);
	LET vDetCompra					= '';
	LET vComercio					= '';
	LET vMtoCompra					= 0.0;
	LET contador_commit 			= 0;	
	LET val_trans_Commit 			= 0;
	LET vBanderaMsi					= '';
	
	
-- Autor: David Ulises Cuenca Montesinos
-- Modificacion: Store Procedure para actualizar informacion de compras a meses sin intereses


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			IF (contador_commit <> 0) THEN
				rollback work;
			END IF;  
			RETURN TRIM(cCodRet);			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/ulises/ModifProcMsiEdc/sps/sp_actpromo_x_msi.out";
	--TRACE ON;

	--LET pFechaCort = MDY('03','20','2023'); -- PRUEBAS
	
	-- Obtiene creditos activos de meses sin intereses
	SELECT folio_movto, num_credito, num_cte, num_tarjeta, num_sol_prestamo, num_pro_prestamo, status, banderact_msi
	FROM bdicred:sd_promocion_credito WHERE num_pro_prestamo = '8900' AND status = 2
	AND fecha <= pFechaCort
	INTO TEMP creds_msi WITH NO LOG;
	
	FOREACH WITH HOLD
	
		SELECT 	pc.num_credito, pc.folio_movto,	pc.num_cte,	pc.num_tarjeta,	pc.num_sol_prestamo,	imov.fechahorainauth,	imov.infreceptor,	imov.idretailer,	imov.monto,	pc.banderact_msi
		  INTO 	vNumCred, 		vFolioMov, 		vNumCte, 	vNumTarjeta, 	vNumMsi, 				vFechaCompra, 			vDetCompra, 		vComercio, 			vMtoCompra,	vBanderaMsi
		FROM intercard:movimiento imov
		INNER JOIN creds_msi pc ON imov.numtarjeta = pc.num_tarjeta
		WHERE imov.secuenciaextendida = SUBSTR(pc.folio_movto,2,15)
			UNION ALL
		SELECT pc.num_credito, pc.folio_movto,	pc.num_cte,	pc.num_tarjeta,	pc.num_sol_prestamo,	imov.fechahorainauth,	imov.infreceptor,	imov.idretailer,	imov.monto,	pc.banderact_msi
		FROM intercard:movimientohistorico imov
		INNER JOIN creds_msi pc ON imov.numtarjeta = pc.num_tarjeta
		WHERE imov.secuenciaextendida = SUBSTR(pc.folio_movto,2,15)
		
		--Valida si el credito ya se actualizo con datos de la compra.
		IF NVL(vBanderaMsi,'') = '1' THEN
			CONTINUE FOREACH;
		ELSE 
			UPDATE "informix".sd_promocion_credito 
				SET fecha_compra_msi = NVL(vFechaCompra,DATE(1)), detalle_compra_msi = NVL(vDetCompra,''), comercio_msi = NVL(vComercio,''), mto_compra_msi = NVL(vMtoCompra,''), banderact_msi = '1'
				WHERE num_sol_prestamo = vNumMsi AND num_pro_prestamo = '8900' AND status = 2;
			
			LET contador_commit = contador_commit + 1;
		END IF;
		
		-- Realiza COMMIT por cada mil registros
		IF contador_commit >= 1000 THEN
			BEGIN WORK;
			LET contador_commit = 0; 
			COMMIT WORK;
		END IF;
		
		LET vBanderaMsi = '';
	
	END FOREACH;
	
	BEGIN; UPDATE STATISTICS MEDIUM FOR TABLE sd_promocion_credito; COMMIT;
   
	RETURN cCodRet;
		
	END;
END PROCEDURE;
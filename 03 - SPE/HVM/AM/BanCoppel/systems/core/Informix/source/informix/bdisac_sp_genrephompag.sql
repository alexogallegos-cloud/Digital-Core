CREATE PROCEDURE  "informix".sp_genrephompag (pNumRep CHAR(1))

RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	--GENERAR REPOTE DE HOMOLOGACION DE PAGOS--
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCategoria 		CHAR(2);
	DEFINE cConvenio 		CHAR(3);
	DEFINE cNombreServicio 	CHAR(50);
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE iImporte_Pago 	INTEGER;
	DEFINE iCuenta_Pago 	INTEGER;
	DEFINE cStmt 			CHAR (250);
 
	--SET DEBUG FILE TO '/informix/HMLG/sp_genrephompag.out';
	--TRACE ON;
		
	LET iCodRet = "00000";
	LET cRutaArch = '';
	LET iSqlErr = 0;
	LET cCategoria = '';
	LET cConvenio = '';
	LET cNombreServicio='';
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET iImporte_Pago = 0;
	LET iCuenta_Pago = 0;
	LET cStmt = '';
	LET iMensaje = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			RETURN iCodRet,iMensaje;
		END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:sac_fechas
		WHERE empresa = "001";
		
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
		SELECT TRIM(ruta_archivo)|| TRIM(titulo_archivo)
		INTO cRutaArch
		FROM bdisac:"informix".sac_catrephompag
		WHERE numrephompag = pNumRep;
		
		LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
		LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
		LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);
		
		LET cStmt = 'rm -f ' || cRutaArch;
		SYSTEM cStmt;
		
		IF pNumRep = "1" THEN 
			LET cStmt = 'echo "' || "COPPEL EN BANCOPPEL"  || '" >> ' || cRutaArch;
			SYSTEM cStmt; 
		ELIF pNumRep = "2" THEN 
			LET cStmt = 'echo "' || "BANCOPPEL EN COPPEL"  || '" >> ' || cRutaArch;
			SYSTEM cStmt;  
		END IF;
		
		LET cStmt = 'echo "' || "PROVEEDOR" || "," ||"MES"|| "," || "PAGOS" || "," || "MONTO" || '" >> ' || cRutaArch;
        SYSTEM cStmt; 
		
		IF cMes <> "01" then
			LET cMes = Month(dFecha_Hoy - 1 units month);
		ELSE
			LET cMes = Month(dFecha_Hoy - 1 units month);
			LET cAnio = Year(dFecha_Hoy)-1;
		END IF;
		
		FOREACH
			
			SELECT sc.numcategoria,sc.numconvenio,sc.descripcion
			INTO cCategoria,cConvenio,cNombreServicio
			FROM bdisac:"informix".sac_servicios_cpl sc 
				LEFT JOIN bdisac:"informix".sac_convenios a 
					ON sc.numcategoria = a.numcategoria  
					AND sc.numconvenio = a.numconvenio
			WHERE sc.numrephompag = pNumRep
            AND a.statusconvenio != 'I'
			ORDER BY sc.descripcion
			
			
			IF cCategoria IS NOT NULL OR cConvenio IS NOT NULL THEN
			
			
			
				IF pNumRep = "1" THEN 
					--"COPPEL EN BANCOPPEL"
					SELECT COUNT(*),NVL(SUM(importe_pago),0)
					INTO iCuenta_Pago,iImporte_Pago
					FROM bdisac:"informix".sac_movimientoshistorial 
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND MONTH(fecha_pago) = cMEs
					AND YEAR(fecha_pago) = cAnio
					AND status_cancelado <> 'S'
					AND id_sucursal <> '9764';
					
				ELIF pNumRep = "2" THEN 
					--"BANCOPPEL EN COPPEL"
					SELECT COUNT(*),NVL(SUM(importe_pago),0)
					INTO iCuenta_Pago,iImporte_Pago
					FROM bdisac:"informix".sac_movimientoshistorial 
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND MONTH(fecha_pago) = cMEs
					AND YEAR(fecha_pago) = cAnio
					AND status_cancelado <> 'S'
					AND id_sucursal = '9764';
					
				END IF;
				
				
				LET cStmt = 'echo "' || trim(cNombreServicio) || "," || cMEs || "," || iCuenta_Pago || "," || iImporte_Pago ||'" >> ' || cRutaArch;
				SYSTEM cStmt;
				
				IF pNumRep = "1" THEN
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso COPPEL EN BANCOPPEL";
				ELIF pNumRep = "2" THEN 
					LET iCodRet = "00000";
					LET iMensaje =  "Proceso Exitoso BANCOPPEL EN COPPEL";	
				END IF;
				
			ELSE 
				
				
				IF pNumRep = "1" THEN
					LET iCodRet = "00001";				
					LET iMensaje =  "Proceso NO Exitoso COPPEL EN BANCOPPEL";
				ELIF pNumRep = "2" THEN 
					LET iCodRet = "00001";
					LET iMensaje =  "Proceso NO Exitoso BANCOPPEL EN COPPEL";	
				END IF;
				
				
				LET cStmt = 'rm -f ' || cRutaArch;
				SYSTEM cStmt;
			END IF;
			
		END FOREACH;
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_obtiene_productos_monitor(pEmpresa CHAR(3),pNumCliente CHAR(10))
RETURNING 
			CHAR(5), 
			CHAR(4), 
			CHAR(40),
			CHAR(20),
			DATE,
			DATE;
	--02-07-2013
	--Realizo: Jose Ruben Lopez
	--Se trae los productos con los que cuenta el cliente
	--Solicito:Jorge Nuñez
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE cNumProducto   	  CHAR(4);
DEFINE cNombreProd        CHAR(40);
DEFINE cNumCredito        CHAR(20);
DEFINE dtFechaApertura     DATE; -- VALOR CLIENTE DESDE
DEFINE dtFechaPrimerComp   DATE;
DEFINE dtFechaPrimerDisp   DATE;
DEFINE dtPrimerConsumo     DATE; -- VALOR PRIMER CONSUMO
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);

LET cCod_Ret = '00000';
LET cNumProducto = '';
LET cNombreProd = '';
LET cNumCredito='';
LET dtFechaApertura='';
LET dtPrimerConsumo='';
LET dtFechaPrimerComp='';
LET dtFechaPrimerDisp='';
--set debug file to "/tmp/sp_replicaparm_ruben.out";
--Trace on;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret,NVL(cNumProducto,''), NVL(cNombreProd,''),NVL (cNumCredito,''),NVL (dtFechaApertura,''),NVL (dtPrimerConsumo,'');
    END EXCEPTION;
	ON EXCEPTION IN(-958) -- si la tabla temporal ya existe la borra
		DROP TABLE tTempProd;
		CREATE TEMP TABLE tTempProd(
								num_producto 	CHAR(4),
								nombre_prod 	CHAR(40),
								num_credito 	CHAR(20),
								fecha_apertura 	DATE, --CLIENTE DESDE
								primer_consumo  DATE  --PRIMER CONSUMO
								)with no log;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pNumCliente ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		RETURN cCod_Ret,NVL(cNumProducto,''), NVL(cNombreProd,''),NVL (cNumCredito,''),NVL (dtFechaApertura,''),NVL (dtPrimerConsumo,'');
	END IF;
	IF pEmpresa ='' THEN
		LET cCod_Ret = '00001'; -- parametro en blanco.
		RETURN cCod_Ret,NVL(cNumProducto,''), NVL(cNombreProd,''),NVL (cNumCredito,''),NVL (dtFechaApertura,''),NVL (dtPrimerConsumo,'');
	END IF
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tTempProd' ) THEN
        DROP TABLE tTempProd;
	END IF;
	
	CREATE TEMP TABLE tTempProd(
							num_producto 	CHAR(4),
							nombre_prod 	CHAR(40),
							num_credito 	CHAR(20),
							fecha_apertura 	DATE, --CLIENTE DESDE
							primer_consumo  DATE  --PRIMER CONSUMO
							)with no log;
   
	FOREACH
		SELECT m.num_producto,d.nombre_prod,m.num_credito,m.fecha_apertura 
		INTO cNumProducto,cNombreProd,cNumCredito,dtFechaApertura 
		FROM bdicred:"informix".sd_maecredcrd m 
		INNER JOIN bdicred:"informix".sd_definicion AS d ON (m.num_producto = d.num_producto)
		WHERE m.numcte = pNumCliente AND m.empresa=pEmpresa
		
		IF cNumCredito != '' THEN
			INSERT INTO tTempProd(num_producto,nombre_prod,num_credito,fecha_apertura,primer_consumo) 
			VALUES(cNumProducto,cNombreProd,cNumCredito,dtFechaApertura,dtFechaApertura);
		END IF;
		
		LET cNumProducto = '';
		LET cNombreProd = '';
		LET cNumCredito='';
		LET dtFechaApertura='';
	END FOREACH;	
	FOREACH
		SELECT m.num_producto,d.nombre_prod,m.num_credito,m.fecha_apertura 
		INTO cNumProducto,cNombreProd,cNumCredito,dtFechaApertura 
		FROM bdicred:"informix".sd_maecred m 
		INNER JOIN bdicred:"informix".sd_definicion AS d ON (m.num_producto = d.num_producto)
		WHERE numcte = pNumCliente AND m.empresa=pEmpresa
		
		FOREACH
			SELECT f_primer_compra,f_primer_disp
			INTO dtFechaPrimerComp,dtFechaPrimerDisp
			FROM bdicred:"informix".sd_indicador_cred
			WHERE num_credito=cNumCredito
			
			IF NVL(dtFechaPrimerComp, DATE(1)) >= NVL(dtFechaPrimerDisp, DATE (1)) THEN
				LET dtPrimerConsumo = dtFechaPrimerDisp;
			ELSE
				LET dtPrimerConsumo = dtFechaPrimerComp;
			END IF;
			
		END FOREACH
			IF cNumCredito != '' THEN
				INSERT INTO tTempProd(num_producto,nombre_prod,num_credito,fecha_apertura,primer_consumo) 
				VALUES(cNumProducto,cNombreProd,cNumCredito,dtFechaApertura,dtPrimerConsumo); 
			END IF;
		LET cNumProducto = '';
		LET cNombreProd = '';
		LET cNumCredito='';
	END FOREACH

	
   --RETORNA VALORES
    FOREACH
		SELECT num_producto, nombre_prod, num_credito,fecha_apertura,primer_consumo
		INTO cNumProducto,cNombreProd,cNumCredito,dtFechaApertura,dtPrimerConsumo
		FROM tTempProd

        RETURN cCod_Ret,NVL(cNumProducto,''), NVL(cNombreProd,''),NVL (cNumCredito,''),NVL (dtFechaApertura,DATE(1)),NVL (dtPrimerConsumo,DATE(1)) WITH RESUME;
    END FOREACH;

    DROP TABLE tTempProd;
   
END;
END PROCEDURE;
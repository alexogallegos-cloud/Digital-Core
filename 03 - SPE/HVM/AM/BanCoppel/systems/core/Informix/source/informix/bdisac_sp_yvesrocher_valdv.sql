CREATE PROCEDURE  "informix".sp_yvesrocher_valdv(pNumReferencia CHAR(17))
RETURNING CHAR(5) AS CodigoRetorno;


--DEFINICION DE LAS VARIABLES
DEFINE iCodRet      	CHAR(5); 
DEFINE iSqlErr      	INTEGER; 
DEFINE iSuma        	INTEGER; 
DEFINE iAux         	INTEGER; 
DEFINE iDig_ver     	INTEGER; 
DEFINE iResiduo     	INTEGER; 
DEFINE i            	INTEGER; 
DEFINE iMulti       	INTEGER;
DEFINE cCadena	    	CHAR(30); 
DEFINE iAux2        	INTEGER; 
DEFINE iDig_ver_cap 	INTEGER; 
DEFINE cNumReferencia   CHAR(16);

--INICIALIZACION DE LAS VARIABLES
LET iCodRet		= '00000';
LET iSqlErr		= 0;
LET iSuma		= 0;
LET iAux		= 0;
LET iDig_ver	= 0;
LET iResiduo	= 0;
LET i			= 16;
LET iMulti		= 2;
LET cCadena		= '';
LET iAux2		= 0;
LET iDig_ver_cap	= 0;
LET cNumReferencia	= '';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET iCodRet = iSqlErr;
		  RETURN iCodRet;
	   END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_yvesrocher_valdv.out';
--	TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(pNumReferencia) = '' THEN
		LET iCodRet = '00001';	
	ELSE
		IF LENGTH(TRIM(pNumReferencia)) <> 17 THEN
			LET iCodRet = '00002';			
		ELSE
			LET iDig_ver_cap = SUBSTR(pNumReferencia,17,1);
			LET cNumReferencia = SUBSTR(pNumReferencia,1,16);
			
			WHILE i <> 0
				LET iAux = SUBSTR(cNumReferencia,i,1);
				LET iAux2 = iMulti * iAux;
				LET cCadena = TRIM(cCadena)||iAux2;
					
					IF iMulti = 2 THEN 
						LET iMulti = 1; 
					ELSE
						IF iMulti = 1 THEN 
							LET iMulti = 2; 
						END IF; 
					END IF;
					
				LET i = i - 1;
				LET iAux = 0;	
				LET iAux2 = 0;			
			END WHILE;
			
			LET i = LENGTH(cCadena);
			
			WHILE i <> 0
				LET iAux = SUBSTR(cCadena,i,1);
				LET iSuma = iSuma + iAux;
				LET i = i - 1;
				LET iAux = 0;				
			END WHILE;
			
			LET iResiduo = MOD(iSuma,10);
			
			IF iResiduo = 0 THEN 
				IF iResiduo <> iDig_ver_cap THEN LET iCodRet = '00109'; END IF;
			ELSE
				LET iDig_ver = 10 - iResiduo;
				IF iDig_ver <> iDig_ver_cap THEN LET iCodRet = '00109'; END IF;
			END IF;
		END IF;		
	END IF;	
	RETURN iCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1454',
'Autor: Vazquez Herrera Hugo Guadalupe  ',
'Fecha: 07/08/2014',
'Descripción: Se crea un procedimiento en central para validar el digito verificador para YVES ROCHER',
'Sustento: RQM 10 498 PgsRef_YVES ROCHER.doc',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE  "informix".sp_prefijos_cvecobrem (pNumCategoria CHAR(2),pNumConvenio CHAR(3))

RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	--GENERAR REPOTE PREFIJOS CLAVE DE COBRO DE REMESAS--
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE iServicio		CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE dFecha_Pago		DATE;
	DEFINE iCuenta_Pago 	INTEGER;
	DEFINE cStmt 			VARCHAR (255);
	DEFINE i				INTEGER;
	DEFINE cPrefijo			CHAR(4);


	--SET DEBUG FILE TO '/informix/HMLG/sp_prefijos_cvecobrem.out';
	--TRACE ON;
		
	LET iCodRet = '00000';
	LET cRutaArch = '';
	LET iServicio = '';
	LET iSqlErr = 0;
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET dFecha_Pago = MDY('01','01','1900');
	LET iCuenta_Pago = 0;
	LET cStmt = '';
	LET iMensaje = '';
	LET i = 0;
	LET cPrefijo = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = '00001';
			LET iMensaje = "Proceso NO Exitoso Error BD. " || iSqlErr || ' ' || iServicio;
			
			SYSTEM 'rm -f /home/systelmex/temp';
			SYSTEM 'rm -f /home/systelmex/prefijo';
			SYSTEM 'rm -f /home/systelmex/informacion';  
			SYSTEM 'rm -f /home/systelmex/temp1';
			SYSTEM 'rm -f /home/systelmex/prefijo1';
			SYSTEM 'rm -f /home/systelmex/informacion1';
			SYSTEM 'rm -f /home/systelmex/temp3';
			SYSTEM 'rm -f /home/systelmex/prefijo3';
			SYSTEM 'rm -f /home/systelmex/informacion3';
			
			drop table if exists t1pccr;
			drop table if exists t2pccr;
			drop table if exists t3pccr;
			
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
		
		
		IF pNumConvenio = '004' THEN
			LET cRutaArch = '/home/systelmex/Prefcvecobrem_BTS_DDMMAAAA.csv';
			LET iServicio = 'BTS';
		ELIF pNumConvenio = '009' THEN
			LET cRutaArch = '/home/systelmex/Prefcvecobrem_Apriza_DDMMAAAA.csv';
			LET iServicio = 'Apriza';
		ELSE
			LET iCodRet = '00001';
			LET iMensaje = 'Proceso NO Exitoso, Input no valido: ' || pNumCategoria || '-' ||pNumConvenio;
		END IF;
		
		
		IF iCodRet = '00000' THEN
			
			LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
			LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
			LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);
		
			LET cStmt = 'rm -f ' || cRutaArch;
			SYSTEM cStmt;
		
			SYSTEM 'rm -f /home/systelmex/temp';
			SYSTEM 'rm -f /home/systelmex/prefijo';
			SYSTEM 'rm -f /home/systelmex/informacion';  
			SYSTEM 'rm -f /home/systelmex/temp1';
			SYSTEM 'rm -f /home/systelmex/prefijo1';
			SYSTEM 'rm -f /home/systelmex/informacion1';
			SYSTEM 'rm -f /home/systelmex/temp3';
			SYSTEM 'rm -f /home/systelmex/prefijo3';
			SYSTEM 'rm -f /home/systelmex/informacion3';
			drop table if exists t1pccr;
			drop table if exists t2pccr;
			drop table if exists t3pccr;
			
		
			LET cStmt = 'echo "' || "PREFIJOS CLAVE DE COBRO DE REMESAS "  || iServicio || '" >> ' || cRutaArch;
			SYSTEM cStmt; 
	
			--FIJA EL MES QUE LE CORRESPONDE AL REPORTE PARA LAS BUSQUEDAS
			IF cMes <> "01" then
				LET cMes = Month(dFecha_Hoy - 1 units month);
			ELSE
				LET cMes = Month(dFecha_Hoy - 1 units month);
				LET cAnio = Year(dFecha_Hoy)-1;
			END IF;
		
			--Extrae a una tabla temporal t1 los datos nedesarios para el reporte segun el mes 
		
			SELECT SUBSTR(referencia1,1,4) prefijo, fecha_pago, COUNT(*) AS operaciones FROM bdisac:sac_movimientoshistorial
				WHERE numcategoria = pNumCategoria
				AND numconvenio = pNumConvenio
				AND status_cancelado <> 'S'
				AND MONTH(fecha_pago) = cMes
				AND YEAR(fecha_pago) = cAnio
				GROUP BY 1,2
				ORDER BY fecha_pago,prefijo
				INTO temp t1pccr WITH NO LOG;
		
			--Obtiene los prefijos del mes y los envia a una tabla temporal t2
			SELECT UNIQUE prefijo 
			FROM bdisac:t1pccr 
			ORDER BY 1 
			INTO TEMP t2pccr  WITH NO LOG;
			--Obtiene las fechas del mes y los envia a una tabla temporal t3
			SELECT UNIQUE fecha_pago 
			FROM bdisac:t1pccr  
			ORDER BY 1 
			INTO TEMP t3pccr  WITH NO LOG;
		
			SYSTEM 'echo "Fecha," > /home/systelmex/temp';
			SYSTEM 'echo "," > /home/systelmex/temp1';
			
			FOREACH
		
				SELECT PREFIJO
				INTO cPrefijo
				FROM t2pccr  ORDER BY 1
			
				--Acomoda titulos [Prefijo 1,Prefijo2,....PrefijoN]
				SYSTEM 'echo "Prefijo ' || i+1 || '," > /home/systelmex/prefijo1';
				SYSTEM 'paste -d "\0" /home/systelmex/temp1 /home/systelmex/prefijo1 > /home/systelmex/informacion1';
				SYSTEM 'cp /home/systelmex/informacion1 /home/systelmex/temp1';
			
				--Acomoda Prefijos
				SYSTEM 'echo "' || cPrefijo || '," > /home/systelmex/prefijo';
				SYSTEM 'paste -d "\0" /home/systelmex/temp /home/systelmex/prefijo > /home/systelmex/informacion';
				SYSTEM 'cp /home/systelmex/informacion /home/systelmex/temp';
									
				let i = i + 1;

			END FOREACH;
		
			SYSTEM 'tail -n +1 /home/systelmex/informacion1 >> ' || cRutaArch;
			SYSTEM 'tail -n +1 /home/systelmex/informacion >> ' || cRutaArch;
			
			FOREACH
			
				SELECT fecha_pago 
				INTO dFecha_Pago
				FROM t3pccr  ORDER BY 1
			
				LET cDia = LPAD(DAY(dFecha_Pago::DATE), 2, '0');
				LET cMEs = LPAD(MONTH(dFecha_Pago::DATE), 2, '0');
				LET cAnio = LPAD(YEAR(dFecha_Pago::DATE), 4, '0');
			
				SYSTEM 'echo "' || cDia || '/' || cMes || '/' || cAnio || '," > /home/systelmex/temp3';
			
				FOREACH
			
					SELECT t2pccr.prefijo, NVL(t1pccr.operaciones,0) as Cuenta_Pago
					INTO cPrefijo, iCuenta_Pago
					FROM OUTER t1pccr , t2pccr 
					WHERE t1pccr.prefijo = t2pccr.prefijo
					AND t1pccr.fecha_pago = dFecha_Pago
					ORDER BY 1
				
					SYSTEM 'echo "' || iCuenta_Pago || '," > /home/systelmex/prefijo3';
					SYSTEM 'paste -d "\0" /home/systelmex/temp3 /home/systelmex/prefijo3 > /home/systelmex/informacion3';
					SYSTEM 'cp /home/systelmex/informacion3 /home/systelmex/temp3';
				
				END FOREACH;
			
				SYSTEM 'tail -n +1 /home/systelmex/informacion3 >> ' || cRutaArch;
		
			END FOREACH;
		
			SYSTEM 'rm -f /home/systelmex/temp';
			SYSTEM 'rm -f /home/systelmex/prefijo';
			SYSTEM 'rm -f /home/systelmex/informacion';
			SYSTEM 'rm -f /home/systelmex/temp1';
			SYSTEM 'rm -f /home/systelmex/prefijo1';
			SYSTEM 'rm -f /home/systelmex/informacion1';
			SYSTEM 'rm -f /home/systelmex/temp3';
			SYSTEM 'rm -f /home/systelmex/prefijo3';
			SYSTEM 'rm -f /home/systelmex/informacion3';
			drop table t1pccr;
			drop table t2pccr;
			drop table t3pccr;
		
			LET iMensaje = 'Proceso Exitoso ' || iServicio;
			LET iCodRet ='00000';
		
		END IF;
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;
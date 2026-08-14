CREATE PROCEDURE "informix".sp_repormovhistbts()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cRutaArchDet			CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cStmt2				CHAR(250);
DEFINE dFecha_Hoy			DATE;
DEFINE dFecha_Ayer			DATE;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cStatus				CHAR(1);

DEFINE cFoliosuc        	CHAR(16);
--DEFINE dMonto           	DECIMAL(16,2);
DEFINE cSucursal			CHAR(4);
DEFINE cUsuario				CHAR(8);
DEFINE cFech_val			CHAR(10);DEFINE dFech_hor     		DateTime Hour To Second;DEFINE cTransacc     		CHAR(4);
DEFINE cCuenta       		CHAR(20);
DEFINE dMonto_tot    	    DECIMAL(16,2);
DEFINE cCancelad			CHAR(1);
DEFINE cReferencia   		CHAR(40);
DEFINE cDescripcionSPJ	 	CHAR(100);	

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET cMensaje				= 'PROCESO EXITOSO';
LET iSqlErr					= 0;
LET cRutaArchDet			= ''; 							 
LET cStmt					= '';
LET cStmt2					='';
LET dFecha_Hoy				= DATE(1);
LET dFecha_Ayer				= DATE(1);
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cStatus  			    = '0';
LET cDescripcionSPJ	 		= 'Genera reporte de movimientos historicos de BTS';


--INICIALIZACION DE VARIABLES REPORTE
LET cFoliosuc = '';       	
LET cSucursal = '';		
LET cUsuario  = '';			
LET cFech_val =	'';LET cTransacc = '';     	
LET cCuenta   = '';    	
LET dMonto_tot = 0;    	
LET cCancelad = '';		
LET cReferencia = '';   	
 
	/*SET DEBUG FILE TO  '/informix/yuri/bts/sp_repormovhistbts.out';
	TRACE ON;*/

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM bdicheq:"informix".sc_fechas
		WHERE empresa = "001";			
		
		LET dFecha_Ayer = dFecha_Hoy - 1;		

		LET cDia = LPAD(DAY(dFecha_Ayer::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Ayer::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Ayer ::DATE),4,'0');	
		 
		IF	cMes = '01' AND cDia = '01' THEN
			LET dFecha_Ayer = dFecha_Ayer-1;
			LET cDia = LPAD(DAY(dFecha_Ayer::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Ayer::DATE), 2, '0');
			
		ELSE
			IF	cMes = '12' AND cDia = '25' THEN
				LET dFecha_Ayer = dFecha_Ayer-1;
				LET cDia = LPAD(DAY(dFecha_Ayer::DATE), 2, '0');
				LET cMes = LPAD(MONTH(dFecha_Ayer::DATE), 2, '0');
			END IF;
		END IF;		
	
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_REPMOVBTS' and fecha_proceso = dFecha_Hoy) THEN							
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_REPMOVBTS', dFecha_Hoy, '0', 'informix', 'sp_repormovhistbts', cDescripcionSPJ);
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='IND_REPMOVBTS' and fecha_proceso = dFecha_Hoy;					
		END IF;
		
		IF cStatus = '0' THEN
		
			SELECT valor 
			INTO cRutaArchDet
			FROM bdisac:sac_param
			WHERE cod_param = '110';				
									
							--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArchDet = REPLACE(cRutaArchDet,'aaaa',cAnio);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'mm',cMes);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'dd',cDia);																
			
			LET cStmt =  'echo "' || RPAD('Reporte de Movimientos BTS',28,' ')|| '" >> '|| cRutaArchDet;
			SYSTEM cStmt;	
			
			LET cStmt =  'echo "' || RPAD('FOLIO_SUC',16,' ')  || '|' || RPAD('SUCURSAL',8, ' ') || '|' || RPAD('USUARIO',8, ' ')  || '|' || RPAD('FECH_VAL',10, ' ')  || '|' || RPAD('FECH_HOR',8, ' ') || '|' || RPAD('TRANSACC',8, ' ') || '|' || RPAD('CUENTA',13, ' ') || '|' || RPAD('MONTO_TOT',14, ' ') || '|' || RPAD('CANCELADO',9, ' ') || '|' || 'REFERENCIA' || '" >> '|| cRutaArchDet;
			SYSTEM cStmt;
			
			--BTS
			FOREACH
				SELECT  folio_suc, sucursal, usuario,
				LPAD(DAY(fech_val), 2, "0") || "/" || LPAD(MONTH(fech_val), 2, "0")|| "/" || YEAR(fech_val), 
				fech_hor, transacc, cuenta,  monto_tot, cancelad, referencia
				into cFoliosuc, cSucursal, cUsuario, cFech_val, dFech_hor, cTransacc, cCuenta, dMonto_tot, cCancelad, cReferencia
				FROM bdicheq:"informix".sc_movhis
				where empresa = '001' AND fech_alt =  dFecha_Ayer AND transacc in ('1110','1140','1170')
				order by fech_hor 	
				
				LET cStmt =  'echo "' || RPAD(cFoliosuc,16,' ')  || '|' || RPAD(cSucursal,8, ' ') || '|' || RPAD(cUsuario,8, ' ')  || '|' || RPAD(cFech_val,10, ' ')  || '|' || RPAD(dFech_hor,8, ' ') || '|' || RPAD(cTransacc,8, ' ') || '|' || RPAD(cCuenta,13, ' ') || '|' || RPAD(dMonto_tot,14, ' ') || '|' || RPAD(cCancelad,9, ' ') || '|' || cReferencia || '" >> '|| cRutaArchDet;
				SYSTEM cStmt;							
				
			END FOREACH				
															
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo "' || '" >> ' ||cRutaArchDet;
			SYSTEM cStmt;							
							
		END IF;		
		--ACTUALIZA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_REPMOVBTS', dFecha_Hoy, '1', 'informix', 'sp_repormovhistbts', cDescripcionSPJ);				
		RETURN cCodRet, cMensaje; 

	END;
END PROCEDURE;
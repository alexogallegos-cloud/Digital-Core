CREATE PROCEDURE "informix".sp_cons_sobrantes_caja_aud(pTipo 	 		  INTEGER,
								                       pCodigo   		  CHAR(4),
													   pEmpresa  		  CHAR(3),
													   pSucursal 		  CHAR(4),
													   pUsuario  		  CHAR(8),
													   pFechIni  		  CHAR(10),
													   pFechFin  		  CHAR(10),
													   pSkip     		  INTEGER,
													   pLimite 	 		  INTEGER,
													   pFecha_Rep 		  CHAR(10),
													   pImporte   		  CHAR(21),
													   pFecha_Eliminacion CHAR(10),
													   pNum_Transaccion   CHAR(4),
													   pOperador          CHAR(8),
													   pLinea			  INTEGER)
										  
	RETURNING CHAR(5) 	AS CodRet,
			  CHAR(10) 	AS Fecha,
			  CHAR(8) 	AS Usuario,
			  CHAR(45) 	AS Nombre,
			  CHAR(21) 	AS Importe,
			  CHAR(10) 	AS Fecha_de_Eliminacion,
			  CHAR(4) 	AS Transaccion,
			  CHAR(4) 	AS Sucursal,
			  CHAR(16)	AS Saldo,
			  CHAR(4) 	AS Trans_Suc,
			  INTEGER  	AS TotRows;
			  
--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE cFecha 			CHAR(10);
DEFINE cUsuario			CHAR(8);
DEFINE cNombreUsu		CHAR(45);
DEFINE cImporte			CHAR(21);
DEFINE cFechaElimina 	CHAR(10);
DEFINE cTransaccion 	CHAR(4);
DEFINE cSucursal		CHAR(4);
DEFINE cTransSuc		CHAR(4);
DEFINE cNombre			CHAR(45);
DEFINE cEjecutivo		CHAR(8);
DEFINE cFechaInicio		CHAR(10);
DEFINE cFechaFin		CHAR(10);
DEFINE cAnio 	 		CHAR(4);
DEFINE cMes 			CHAR(2);
DEFINE cDia 			CHAR(2);
DEFINE iDiasConsulta	INTEGER;
DEFINE iTotalRows		INTEGER;
DEFINE dFechaIni 		DATE;
DEFINE dFechaFin		DATE;
DEFINE dFechaHoy		DATE;
DEFINE dFecha_Rep       DATE;

DEFINE vEmpresa 		CHAR(3);
DEFINE vSucursal 		CHAR(4);
DEFINE vUsuario 		CHAR(8);
DEFINE vCodigo 			CHAR(4);
DEFINE cCodigo 			CHAR(4);
DEFINE vFechIni 		DATE;
DEFINE vFechFin 		DATE;


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cFecha 			= '';
LET cUsuario		= '';
LET cNombreUsu 		= '';
LET cImporte 		= '';
LET cFechaElimina 	= '';
LET cTransaccion 	= '';
LET cSucursal 		= '';
LET cTransSuc 		= '';
LET cNombre 		= '';
LET cEjecutivo 		= '';
LET cAnio  			= '';
LET cMes  			= '';
LET cDia 			= '';
LET cFechaInicio	= '';
LET cFechaFin		= '';
LET iDiasConsulta 	= 0;
LET dFechaIni 		= DATE(1);
LET dFechaFin 		= DATE(1);
LET dFechaHoy 		= DATE(1);
LET iTotalRows 		= 0;
LET dFecha_Rep      = DATE(1);
--LET cuenta 		= '';

--SET DEBUG FILE TO "/informix/VJMP/sp_sobrantes"||"_"||""||pTipo||""||".out"; 
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','','','','','','',iTotalRows;
			
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	LET cAnio = SUBSTRING(pFechIni FROM 1 FOR 4);
	LET cMes = SUBSTRING(pFechIni FROM 6 FOR 2) ;
	LET cDia = SUBSTRING(pFechIni FROM 9 FOR 2);
	LET dFechaIni = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
			
	LET cAnio = SUBSTRING(pFechFin FROM 1 FOR 4);
	LET cMes =  SUBSTRING(pFechFin FROM 6 FOR 2) ;
	LET cDia = SUBSTRING(pFechFin FROM 9 FOR 2);
	LET dFechaFin = DATE(TRIM(cMes||'/'||cDia||'/'||cAnio));
			
	IF pTipo = 1 THEN
	
		IF (pEmpresa IS NULL OR NVL(pEmpresa,'') = '') OR (pUsuario IS NULL OR NVL(pUsuario,'') = '') OR
			(pCodigo IS NULL OR NVL(pCodigo,'') = '') OR (pSucursal IS NULL OR NVL(pSucursal,'') = '') THEN
			LET cCodRet = '00001';
		ELSE
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;
		
			LET iDiasConsulta = (dFechaHoy - 1) - dFechaIni;
		
			IF (iDiasConsulta > 365) OR (dFechaIni >= dFechaHoy OR dFechaFin >= dFechaHoy) THEN 
				--Sobrepasa el año de consulta o esta consultando la fecha hoy 
				LET cCodRet = '00002';
			END IF;	
		END IF;
		RETURN cCodRet,'','','','','','','','','',iTotalRows;
		
	ELIF pTipo = 2 THEN	 
	
		IF (pEmpresa IS NULL OR NVL(pEmpresa,'') = '') OR (pUsuario IS NULL OR NVL(pUsuario,'') = '') OR
			(pFechIni IS NULL OR NVL(pFechIni,'') = '') OR (pFechFin IS NULL OR NVL(pFechFin,'') = '') OR
			(pCodigo IS NULL OR NVL(pCodigo,'') = '') OR (pSucursal IS NULL OR NVL(pSucursal,'') = '') OR
			(pFecha_Rep IS NULL OR NVL(pFecha_Rep,'') = '') OR (pImporte IS NULL OR NVL(pImporte,'') = '') OR
			(pFecha_Eliminacion IS NULL OR NVL(pFecha_Eliminacion,'') = '') OR (pNum_Transaccion IS NULL OR NVL(pNum_Transaccion,'') = '') OR 
			(pOperador IS NULL OR NVL(pOperador,'') = '') OR (pLinea IS NULL OR NVL (pLinea, '') = '') THEN
			LET cCodRet = '00003';
		ELSE
			--PROCESO NUEVO INSERTADO PARA GUARDAR REGISTRO POR REGISTRO
			SELECT TRIM(nombre)
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pOperador;
			
			/*VJMP*/
			LET pNum_Transaccion = LPAD(TRIM(pNum_Transaccion), 4,'0');
			IF pNum_Transaccion = '0019' THEN
				LET pFecha_Eliminacion = DATE(1);
			END IF;
			 /*VJMP*/
			LET cMes  = SUBSTRING(pFecha_Rep FROM 1 FOR 2);
			LET cDia  = SUBSTRING(SUBSTRING(pFecha_Rep FROM 4 FOR 4) FROM 1 FOR 2);
			LET cAnio = SUBSTRING(pFecha_Rep FROM 7 FOR 10);		
			LET dFecha_Rep = DATE(cMes||'/'||cDia||'/'||cAnio);
			IF NOT EXISTS (SELECT cod_transacc FROM bdinteg:"informix".si_rptcaja_aud WHERE cod_transacc = pNum_Transaccion AND fecha = dFecha_Rep AND monto = pImporte AND sucursal = pSucursal AND usuario = pOperador AND fecha_eliminacion = pFecha_Eliminacion) THEN
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (folio_oper,empresa,usuario,cod_transacc,sucursal,fecha,nombre_usuario,monto,fecha_eliminacion,transacc_suc,fecha_insert)
				VALUES (pUsuario,pEmpresa,pOperador,pNum_Transaccion,pSucursal,dFecha_Rep,cNombre,pImporte,pFecha_Eliminacion,pNum_Transaccion,today);
			END IF;
		END IF;	
		RETURN cCodRet,'','','','','','','','','',iTotalRows;
		
	ELIF pTipo = 3 THEN
		
		IF (pEmpresa IS NULL OR NVL(pEmpresa,'') = '') OR (pUsuario IS NULL OR NVL(pUsuario,'') = '') OR
			(pFechIni IS NULL OR NVL(pFechIni,'') = '') OR (pFechFin IS NULL OR NVL(pFechFin,'') = '') OR
			(pCodigo IS NULL OR NVL(pCodigo,'') = '') OR (pSucursal IS NULL OR NVL(pSucursal,'') = '') THEN
			LET cCodRet = '00004';
		ELSE
			/*VJMP*/
			LET vEmpresa = pEmpresa;
			LET	vSucursal = pSucursal;
			LET	vUsuario = pUsuario;
			LET	vCodigo = pCodigo;
			LET vFechIni = dfechaini;
			LET vFechFin = dfechafin;
			 /*VJMP*/
			SELECT COUNT(*)
			INTO iTotalRows
			FROM bdinteg:"informix".si_rptcaja_aud
			WHERE empresa = vEmpresa
				AND sucursal = vSucursal
				AND cod_transacc in (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = vCodigo)
				AND fecha BETWEEN vFechIni  AND vFechFin;
			
			FOREACH
				SELECT SKIP pSkip LIMIT  pLimite 
				usuario,transaccion,sucursal,fecha,monto,transacc_suc,nombre_usuario,transacc_suc,--fecha_eliminacion
					Case 
						When fecha_eliminacion = date(1) Then
							null
					Else
						fecha_eliminacion
					End as fecha_eliminacion
				INTO cUsuario,cCodigo,cSucursal,cFecha,cImporte,cTransaccion,cNombreUsu,cTransSuc,cFechaElimina
				FROM bdinteg:"informix".si_rptcaja_aud
				WHERE empresa = vEmpresa
				AND sucursal = vSucursal
				AND cod_transacc in (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = vCodigo)
				AND fecha BETWEEN vFechIni  AND vFechFin
				
				RETURN cCodRet,cFecha,cUsuario,cNombreUsu,cImporte,REPLACE(TRIM(cFechaElimina),'-','/'),LPAD(TRIM(cTransaccion),4,'0'),cSucursal,cImporte,LPAD(TRIM(cTransSuc),4,'0'),iTotalRows WITH RESUME;
			END FOREACH;
		
			LET pSkip = pSkip + pLimite ;
		
		END IF;	
		RETURN cCodRet,'','','','','','','','','',iTotalRows;
	ELSE
		LET cCodRet = '00005';
		RETURN cCodRet,'','','','','','','','','',iTotalRows;
	END IF;	
END;
END PROCEDURE
DOCUMENT
'FOLIO : 1556',
'AUTOR : Eduardo Lopez Cuevas ',
'FECHA :29-10-2013 ',
'DESCRIPCION: Se crea nuevo sp para obtener los datos del reporte de sobrantes de caja ',
'SUSTENTO: RQM 12 023 Consulta de Transacciones V5.pdf ',
'SOLICITA: Norberto Corona',
'BD: bdinteg',
'FOLIO : 1587',
'AUTOR : 95594213',
'FECHA :21-02-2014 ',
'MODIFICACION: Se Modifica sp para insertar datos en la tabla si_rptcaja_aud y obtener los datos del reporte de sobrantes de caja ',
'SUSTENTO: DMP 1587 ',
'SOLICITA: Norberto Corona',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actvalcel(pNumCte CHAR(9))
	RETURNING 	CHAR(5) 	 AS cCodRet;
				
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cSitEsp 		CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET cCodRet 	 = "00000";
LET cSitEsp 	 = "00000";

--SET DEBUG FILE TO '/tmp/sp_valtel_ctedupout.SQL';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;			
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    
 
    --IF EXISTS (SELECT * FROM si_telefonos WHERE numcte=pNumCte and tipo_tel=2) THEN
       update si_telefonos set verificado='V', fecha_actualiza=current WHERE numcte=pNumCte and tipo_tel=2 and status_tel='A';
    --END IF;

RETURN cCodRet; 
END;
END PROCEDURE;
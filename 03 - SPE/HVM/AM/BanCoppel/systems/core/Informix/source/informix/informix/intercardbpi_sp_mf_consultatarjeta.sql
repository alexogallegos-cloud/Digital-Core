create procedure "informix".sp_mf_consultatarjeta(pnumTarj varchar(16), p_NumReg INT8)
RETURNING 
 CHAR(5)						AS CodRetorno
,VARCHAR(2) 					AS CodigoIso
,VARCHAR(1) 					AS Ubi
,VARCHAR(16) 					AS NumTarjeta
,MONEY(19,4) 					AS Monto
,VARCHAR(40) 					AS InfReceptor
,VARCHAR(5) 					AS FechaLocalTransaccion
,VARCHAR(8) 					AS HoraLocalTransaccion
,DATETIME YEAR TO FRACTION 		AS FechaHoraInAuth
,VARCHAR(70) 					AS Motivo
,VARCHAR(1) 					AS MovReversado
,VARCHAR(4) 					AS CodGiroNeg
,VARCHAR(7) 					AS Secuencia
,VARCHAR(12) 					AS Referencia
,VARCHAR(2) 					AS CVVValido
,VARCHAR(1) 					AS MovConciliado
,VARCHAR(2) 					AS MetodoCaptura
,MONEY(14,2) 					AS MontoCashBack
,VARCHAR(2) 					AS CodTran
,MONEY(19,4) 					AS MontoComision
,CHAR(13)						AS NumeroCuenta
,CHAR(104)						AS NombreCte
,CHAR(3)						AS StatusTarjeta;


-- Definicion de variables para el control de  errores
DEFINE  SQL_ERR      		INTEGER;
DEFINE  ISAM_ERR     		INTEGER;
DEFINE  ERROR_INFO   		VARCHAR(80);
DEFINE  P_COD_RET   		VARCHAR(6);

-- Definicion de variables de retornmo
DEFINE v_sCodigoIso 			VARCHAR(2);
DEFINE v_sUbi 					VARCHAR(1);
DEFINE v_sNumTarjeta 			VARCHAR(16);
DEFINE v_mMonto 				MONEY(19,4);
DEFINE v_sInfReceptor 			VARCHAR(40);
DEFINE v_sFechaLocalTransaccion VARCHAR(5);
DEFINE v_sHoraLocalTransaccion 	VARCHAR(8);
DEFINE v_dtFechaHoraInAuth 		DATETIME YEAR TO FRACTION;
DEFINE v_sMotivo 				VARCHAR(70);
DEFINE v_sMovReversado 			VARCHAR(1);
DEFINE v_sCodGiroNeg 			VARCHAR(4);
DEFINE v_sSecuencia 			VARCHAR(7);
DEFINE v_sReferencia 			VARCHAR(12);
DEFINE v_sCVVValido 			VARCHAR(2);
DEFINE v_sMovConciliado 		VARCHAR(1);
DEFINE v_sMetodoCaptura 		VARCHAR(2);
DEFINE v_mMontoCashBack 		MONEY(14,2);
DEFINE v_sCodTran 				VARCHAR(2);
DEFINE v_mMontoComision 		MONEY(19,4);

-- Definicion de variables usables
DEFINE v_iLimiteReg				SMALLINT;
DEFINE v_sProdInd				VARCHAR(2);
DEFINE v_sFormato				VARCHAR(4);
DEFINE iTotalNumReg				INT8;
DEFINE iValorSalto				INT8;
DEFINE sNombreCte				VARCHAR(106);
DEFINE sStatusTarjeta			VARCHAR(3);
DEFINE sNumCuenta				VARCHAR(13);
	
	
LET P_COD_RET = "00000";
-- Inicializacion de variables
LET v_sCodigoIso 				= "";
LET v_sUbi 						= "";
LET v_sNumTarjeta 				= "";
LET v_mMonto 					= 0.0;
LET v_sInfReceptor 				= "";
LET v_sFechaLocalTransaccion 	= "";
LET v_sHoraLocalTransaccion 	= "";
LET v_dtFechaHoraInAuth 		= MDY(1,1,1900);
LET v_sMotivo 					= "";
LET v_sMovReversado 			= "";
LET v_sCodGiroNeg 				= "";
LET v_sSecuencia 				= "";
LET v_sReferencia 				= "";
LET v_sCVVValido 				= "";
LET v_sMovConciliado 			= "";
LET v_sMetodoCaptura 			= "";
LET v_mMontoCashBack 			= 0.0;
LET v_sCodTran 					= "";
LET v_mMontoComision 			= 0.0;

LET v_iLimiteReg 				= 100;
LET v_sProdInd					= "";
LET v_sFormato					= "";
LET iTotalNumReg				= 0;
LET iValorSalto					= 0;
LET sNombreCte					= "";
LET sStatusTarjeta				= "";
LET sNumCuenta					= "";
	
	BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR
        LET P_COD_RET    = SQL_ERR;
        RETURN P_COD_RET,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/has/sp_mf_ConsultaTarjeta.out";
	--TRACE ON;
	
	--- OBTENER EL STATUS DE LA TARJETA Y ELNOMBRE DEL CLIENTE
	SELECT nombre,codstatustarjeta
	INTO sNombreCte,sStatusTarjeta
	FROM  intercard:tarjeta
	WHERE numtarjeta = pnumTarj;
	
	-- OBTENER LA CUENTA DE LA TARJETA
	SELECT numcuenta
	INTO sNumCuenta
	FROM  intercard:tarjetacuenta 
	WHERE numtarjeta = pnumTarj;
	
	--- OBTIENE EL TOTAL DE REGISTROS DE LA TABLA
	SELECT {+INDEX(intercard:movimiento idx_movimientonew1a)} COUNT(*)::INT8
	INTO iTotalNumReg
	FROM intercard:movimiento 
	WHERE NumTarjeta = pnumTarj;
	
	--- VALIDA QUE EXISTAN REGISTROS
	IF iTotalNumReg <= 0 OR iTotalNumReg IS NULL THEN
		RETURN "00001",NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	IF p_NumReg <= 0 OR p_NumReg IS NULL THEN
		RETURN "00002",NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET iValorSalto = iTotalNumReg - p_NumReg;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	
	FOREACH WITH HOLD 
		SELECT MetodoCaptura,CodigoISO,NumTarjeta,Monto,InfReceptor,FechaLocalTransaccion,FechaHoraInAuth,HoraLocalTransaccion,Motivo
			,MovReversado,CodGiroNeg,Secuencia,Referencia,CVVValido,movConciliado,MontoCashBack,ProdInd,Formato,CodTran,MontoComision
		INTO  v_sMetodoCaptura,v_sCodigoIso,v_sNumTarjeta,v_mMonto,v_sInfReceptor,v_sFechaLocalTransaccion,v_dtFechaHoraInAuth,v_sHoraLocalTransaccion,
		v_sMotivo,v_sMovReversado,v_sCodGiroNeg,v_sSecuencia,v_sReferencia,v_sCVVValido,v_sMovConciliado,v_mMontoCashBack,v_sProdInd,v_sFormato,v_sCodTran,	v_mMontoComision
		FROM
			TABLE(
			MULTISET(SELECT SKIP iValorSalto FIRST p_NumReg b.MetodoCaptura AS MetodoCaptura, b.CodigoISO AS CodigoISO
			, b.NumTarjeta AS NumTarjeta, b.Monto AS Monto, b.InfReceptor AS InfReceptor 
			,SUBSTRING(b.FechaLocalTransaccion FROM 1 FOR 2) || "/" || SUBSTRING(b.FechaLocalTransaccion FROM 3 FOR 2) AS FechaLocalTransaccion
			,b.FechaHoraInAuth AS FechaHoraInAuth
			, SUBSTRING(b.HoraLocalTransaccion FROM 1 FOR 2) || ":" || SUBSTRING(b.HoraLocalTransaccion FROM 3 FOR 2)|| ":" || SUBSTRING(b.HoraLocalTransaccion FROM 5 FOR 2) AS HoraLocalTransaccion
			,b.Motivo AS Motivo, b.MovReversado AS MovReversado, b.CodGiroNeg AS CodGiroNeg , b.Secuencia AS Secuencia, b.Referencia AS Referencia
			, b.CVVValido AS CVVValido, b.movConciliado AS movConciliado, b.MontoCashBack AS MontoCashBack, b.ProdInd AS ProdInd, b.Formato AS Formato
			, b.CodTran AS CodTran, b.MontoComision AS MontoComision
			FROM intercard:movimiento b
			WHERE b.NumTarjeta = pnumTarj)
			)
		ORDER BY fechahorainauth DESC
		
		--- VALIDACIONES PARA OBTENER LA UBICACION
		IF (v_sProdInd = '01' AND v_sFormato = '0200' AND v_sCodTran = '94') OR (v_sProdInd = '01' AND v_sFormato = '0200' AND v_sCodTran = '95') 
					OR (v_sProdInd = '01' AND v_sFormato = '0200' AND v_sCodTran = '85') THEN
			LET v_sUbi = '3';
		ELIF (v_sProdInd = '01') THEN
			LET v_sUbi = '1';
		ELSE
			LET v_sUbi = '2';
		END IF;
		
		RETURN P_COD_RET,NVL(v_sCodigoIso,''),NVL(v_sUbi,''),NVL(v_sNumTarjeta,''),NVL(v_mMonto,'0'),NVL(v_sInfReceptor,'')
			,NVL(v_sFechaLocalTransaccion,''),NVL(v_sHoraLocalTransaccion,''),NVL(v_dtFechaHoraInAuth,'1900-01-01 00:00:00'),NVL(v_sMotivo,'')
			,NVL(v_sMovReversado,''),NVL(v_sCodGiroNeg,''),NVL(v_sSecuencia,''),NVL(v_sReferencia,''),NVL(v_sCVVValido,''),NVL(v_sMovConciliado,'')
			,NVL(v_sMetodoCaptura,''),NVL(v_mMontoCashBack,'0'),NVL(v_sCodTran,''),NVL(v_mMontoComision,'0')
			,NVL(sNumCuenta,''),NVL(sNombreCte,''),NVL(sStatusTarjeta,'')
		WITH RESUME;
	END FOREACH
	
	END
	
	 --======================================================================     
	 -- AUTOR : Nevarez Peinado Jose de Jesus.                             
	 -- FECHA : 2 Septiembre 2009.                                              
	 -- VERSION: 20090902.                                                  
	 -- BD: Intercard.                                                     
	 -- DESCRIPCION: CONSULTA LOS ULTIMOS n MOVIMIENTOS DE UNA CUENTA.
 --======================================================================
	
	END PROCEDURE;
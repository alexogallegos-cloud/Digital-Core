create procedure "informix".sp_mf_consultagironegocio(p_dtfecha_ini DATETIME YEAR TO FRACTION, p_dtfecha_final DATETIME YEAR TO FRACTION, p_sCodGiroNeg VARCHAR(4), p_ValorInicial INT8)
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
,INT8							AS TotalRegistros
,INT8							AS PosicionInicial;


		  
-- Definicion de variables para el control de  errores
DEFINE v_cod_ret            	CHAR(5);
DEFINE iSqlErr              	INTEGER;
DEFINE iSamErr              	INTEGER;

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

DEFINE v_cadenaejem 		CHAR(10);

-- Definicion de variables usables
DEFINE v_iLimiteReg				SMALLINT;
DEFINE v_sProdInd				VARCHAR(2);
DEFINE v_sFormato				VARCHAR(4);
DEFINE iTotalNumReg				INT8;
DEFINE iResiduo					INT8;
DEFINE iValorBloque				INT8;
DEFINE iValorSalto				INT8;

-- Inicializacion de variables para el control de  errores
LET v_cod_ret 					= '00000';
LET iSqlErr						= 0;
LET iSamErr						= 0;

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
LET iResiduo					= 0;
LET iValorBloque				= 0;
LET iValorSalto					= 0;

BEGIN
	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/sp_mf_ConsultaGiroNegocio.out";
	---TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--- OBTIENE EL TOTAL DE REGISTROS DE LA TABLA
	SELECT {+INDEX(intercard:movimiento idx_fechahorainauth)} COUNT(*)::INTEGER
	INTO iTotalNumReg
	FROM intercard:movimiento 
	WHERE fechahorainauth BETWEEN p_dtfecha_ini AND p_dtfecha_final AND codgironeg = p_sCodGiroNeg;
	
	--- VALIDA QUE EXISTAN REGISTROS
	IF iTotalNumReg <= 0 OR iTotalNumReg IS NULL THEN
		RETURN "00001",NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	--- OBTIENE EL BLOQUE DE LA TABLA DE PARAMETROS
	SELECT VALOR::INT8
	INTO iValorBloque
	FROM intercard: param_fraudes
	WHERE cod_param = "01";
	
	--- VALIDA QUE EL BLOQUE EXISTA Y QUE SEA MAYOR A 1
	IF iValorBloque < 2 OR iValorBloque IS NULL THEN
		RETURN "00002",NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	--- VALIDA PARA EL CASO EN QUE EL VALOR INICIAL SEA -1 LO CUAL INDICA QUE ES LA PRIMERA VEZ QUE SE EJECUTA Y SE BUSCA OBTENER ELSOBRANTE DE LOS BLOQUES DE REGISTROS
	IF p_ValorInicial = -1 THEN
		SELECT MOD(iTotalNumReg,iValorBloque)
		INTO iResiduo 
		FROM bdinteg:si_fechas;
		
		IF iResiduo > 0 THEN
			LET iValorBloque = iResiduo;
		END IF
		
		LET p_ValorInicial = iTotalNumReg - iResiduo;
	END IF
	
	LET iValorSalto = p_ValorInicial;
	
	LET v_cadenaejem =  p_sCodGiroNeg;
	
	--- INICIA CICLO PARA REALIZAR LA CONSULTA ATRAVES DE LA FECHAS, LOS MONTOS EL VALOR INICIAL Y EL BLOQUE DE REGISTROS
	FOREACH
		SELECT MetodoCaptura,CodigoISO,NumTarjeta,Monto,InfReceptor,FechaLocalTransaccion,FechaHoraInAuth,HoraLocalTransaccion,Motivo
			,MovReversado,CodGiroNeg,Secuencia,Referencia,CVVValido,movConciliado,MontoCashBack,ProdInd,Formato,CodTran,MontoComision
		INTO  v_sMetodoCaptura,v_sCodigoIso,v_sNumTarjeta,v_mMonto,v_sInfReceptor,v_sFechaLocalTransaccion,v_dtFechaHoraInAuth,v_sHoraLocalTransaccion,
		v_sMotivo,v_sMovReversado,v_sCodGiroNeg,v_sSecuencia,v_sReferencia,v_sCVVValido,v_sMovConciliado,v_mMontoCashBack,v_sProdInd,v_sFormato,v_sCodTran,	v_mMontoComision
		FROM
			TABLE(
			MULTISET(SELECT SKIP iValorSalto FIRST iValorBloque b.MetodoCaptura AS MetodoCaptura, b.CodigoISO AS CodigoISO
			, b.NumTarjeta AS NumTarjeta, b.Monto AS Monto, b.InfReceptor AS InfReceptor 
			,SUBSTRING(b.FechaLocalTransaccion FROM 1 FOR 2) || "/" || SUBSTRING(b.FechaLocalTransaccion FROM 3 FOR 2) AS FechaLocalTransaccion
			,b.FechaHoraInAuth AS FechaHoraInAuth
			, SUBSTRING(b.HoraLocalTransaccion FROM 1 FOR 2) || ":" || SUBSTRING(b.HoraLocalTransaccion FROM 3 FOR 2)|| ":" || SUBSTRING(b.HoraLocalTransaccion FROM 5 FOR 2) AS HoraLocalTransaccion
			,b.Motivo AS Motivo, b.MovReversado AS MovReversado, b.CodGiroNeg AS CodGiroNeg , b.Secuencia AS Secuencia, b.Referencia AS Referencia
			, b.CVVValido AS CVVValido, b.movConciliado AS movConciliado, b.MontoCashBack AS MontoCashBack, b.ProdInd AS ProdInd, b.Formato AS Formato
			, b.CodTran AS CodTran, b.MontoComision AS MontoComision
			FROM intercard:movimiento b 
			WHERE fechahorainauth BETWEEN p_dtfecha_ini AND p_dtfecha_final AND b.codgironeg = p_sCodGiroNeg )
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
		
		RETURN v_cod_ret,NVL(v_sCodigoIso,''),NVL(v_sUbi,''),NVL(v_sNumTarjeta,''),NVL(v_mMonto,'0'),NVL(v_sInfReceptor,'')
			,NVL(v_sFechaLocalTransaccion,''),NVL(v_sHoraLocalTransaccion,''),NVL(v_dtFechaHoraInAuth,'1900-01-01 00:00:00'),NVL(v_sMotivo,'')
			,NVL(v_sMovReversado,''),NVL(v_sCodGiroNeg,''),NVL(v_sSecuencia,''),NVL(v_sReferencia,''),NVL(v_sCVVValido,''),NVL(v_sMovConciliado,'')
			,NVL(v_sMetodoCaptura,''),NVL(v_mMontoCashBack,'0'),NVL(v_sCodTran,''),NVL(v_mMontoComision,'0') ,iTotalNumReg, p_ValorInicial 
		WITH RESUME;
	END FOREACH;
	
END;
--##############################################################################
--## Procedimiento   : sp_mf_ConsultaGiroNegocio
--## Base de datos   : intercard
--## Version         : 2.0
--## Creado por      : Mohamed Carreón 
--## Fecha creacion  : 1 Septiembre del 2009
--##Descripcion :  
--##############################################################################
END PROCEDURE;
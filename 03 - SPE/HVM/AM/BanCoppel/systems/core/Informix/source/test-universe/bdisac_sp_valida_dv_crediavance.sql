CREATE PROCEDURE "informix".sp_valida_dv_crediavance
(
	  pNumRef CHAR (18), pImporte CHAR (9)
)
	
RETURNING CHAR(5)  AS cCod_ret;


DEFINE cCod_ret CHAR(5);
DEFINE vFecha_Hoy VARCHAR (11);
DEFINE iAnioActual  INT;
DEFINE iMesActual  INT;
DEFINE iDiaActual  INT;
DEFINE iSumFechAct INT;
DEFINE cImporte char(9);
DEFINE iMult INT;
DEFINE iMul INT;
DEFINE dSumaImport DEC(6,2);
DEFINE dSumRef DEC(6,2);
DEFINE iLongCadImp INT;
DEFINE iLongRef INT;
DEFINE iIteracImp INT;
DEFINE iIteracRef INT;
DEFINE iImporteCond INT;
DEFINE dResulRef DEC(6,2);
DEFINE cRef CHAR(18);
Define iRemRef INT;
DEFINE iDigVerifRef INT;
DEFINE iImpCondTram INT;
DEFINE iFechaConden INT;
DEFINE iSqlErr INTEGER;


LET cCod_ret='00000';	--Iniciamos en exitoso cambiara de acuerdo a las validaciones agregadas.
LET vFecha_Hoy = '';
LET iAnioActual  = 0;
LET iMesActual =0;
LET iDiaActual =0;
LET iSumFechAct = 0;
LET cImporte = '';
LET iMult = 1;
LET iMul = 1;
LET dSumaImport = 0.0;
LET dSumRef = 0.0;
LET iLongCadImp = 0;
LET iImporteCond = 0;
LET dResulRef = 0.0;
LET cRef  = '';
LET iIteracImp =0;
LET iIteracRef = 0;
LET iLongRef = 0;
LET iRemRef = 0;
LET iDigVerifRef = 0;
LET iImpCondTram = 0;
LET iFechaConden =0;
LET iSqlErr = 0;


	BEGIN
	
	-- Errores de Informix
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCod_ret = iSqlErr;
			RETURN cCod_ret;	
		END IF;
	END EXCEPTION;
	 
	SET ISOLATION TO DIRTY READ;		
	SET LOCK MODE TO WAIT 3;
	
		--SET DEBUG FILE TO '/informix/alex/sp_ejecucion.out';
		--TRACE ON;
	
	
		--Validamos parametro
		IF  LENGTH(TRIM(pNumRef)) <> 18 OR TRIM(pNumRef) = '' OR pNumRef::int8 = 0 THEN
			LET cCod_ret = '00001';		
		ELSE	 

			SELECT fecha_hoy INTO vFecha_Hoy FROM bdisac:"informix".sac_fechas;		

			
			--Validamos la vigencia.
			LET iDiaActual = CAST(TRIM(SUBSTR(vFecha_Hoy,4,2))-1 AS INT);
			LET iMesActual = CAST(TRIM(SUBSTR(vFecha_Hoy,1,2)) -1 AS INT) * 31;
			LET iAnioActual = CAST(TRIM(SUBSTR(vFecha_Hoy,7,4)) -2013 AS INT) * 372;
			LET	iSumFechAct = iDiaActual + iMesActual + iAnioActual ;
			LET iFechaConden = TRIM(SUBSTR(pNumRef,11,4));
			
			IF iSumFechAct > iFechaConden THEN
				LET cCod_ret ='00139';
				RETURN cCod_ret;
			END IF;
		
			-- validamos importe condensado	
			IF pImporte <> '' OR pImporte ::DECIMAL(8,2) <> 0.00 THEN
				let cImporte =  REPLACE(pImporte,'.','');
				let iLongCadImp = LENGTH(TRIM(cImporte));
				--Realizamos la multiplicacion del importe
				FOR  iIteracImp= 1 TO iLongCadImp 
					IF iMult = 1 THEN  
							let dSumaImport = (CAST(SUBSTR(cImporte,iLongCadImp,1)*7  + dSumaImport AS INT)) ;  
							let iMult = 2;      
							let iLongCadImp=iLongCadImp-1;  
						
						ELIF iMult = 2  THEN 
							let dSumaImport= (CAST(SUBSTR(cImporte,iLongCadImp,1)*3 + dSumaImport AS INT));   
							let iMult = 3;
							let iLongCadImp=iLongCadImp-1;
						
						ELIF iMult = 3  THEN 
							let dSumaImport= (CAST(SUBSTR(cImporte,iLongCadImp,1)*1 +dSumaImport AS INT));
							let iMult = 1;   
							let iLongCadImp=iLongCadImp-1;  
					END IF;
				END FOR;
				LET iImporteCond = MOD(dSumaImport,10);
				lET iImpCondTram = SUBSTR(pNumRef,15,1);
				-- Validamos importe condensado
				IF iImporteCond <> iImpCondTram THEN
					let cCod_ret = '00108'; 
					RETURN cCod_ret;
				END IF;
			
			END IF;			
					
				--validamos digito verificador
				let  cRef = SUBSTR(pNumRef,1,16);
				let iLongRef = LENGTH( cRef);
				
				FOR  iIteracRef= 1 TO iLongRef 
					IF iMul = 1 THEN  
						IF iIteracRef = 1 THEN 
							Let dSumRef = 2 * 11; 
						ELSE
							let dSumRef = (CAST(SUBSTR( cRef,iLongRef,1) * 11  + dSumRef AS INT)) ; 
						END IF;						
							let iMul = 2;      
							let iLongRef=iLongRef-1;  
					ELIF iMul = 2  THEN 
						let dSumRef= (CAST(SUBSTR( cRef,iLongRef,1)*13 + dSumRef AS INT)); 
						let iMul = 3;
						let iLongRef=iLongRef-1;
						
					ELIF iMul = 3 THEN 
						let dSumRef= (CAST(SUBSTR( cRef,iLongRef,1)*17 + dSumRef AS INT));   
						let iMul = 4;
						let iLongRef=iLongRef-1;
						
					ELIF iMul = 4  THEN 
						let dSumRef= (CAST(SUBSTR( cRef,iLongRef,1)*19 + dSumRef AS INT));   
						let iMul = 5;
						let iLongRef=iLongRef-1;
					
					ELIF iMul = 5  THEN 
						let dSumRef= (CAST(SUBSTR( cRef,iLongRef,1)*23 +dSumRef AS INT)); 
						let iMul = 1;     
						let iLongRef=iLongRef-1; 
					END IF;								
				END FOR;
				--	Dividimos el resultado/10, despues quitamos en punto decimal y 	tomamos los dos dijitos que estaba depues del punto
				-- y comporamos si es diferente al digito verificador de la referencia.
				LET iRemRef = MOD (dSumRef,97)+1;
                LET iDigVerifRef =SUBSTR(pNumRef,17,2) ;
				
				IF iRemRef  <>  iDigVerifRef THEN
					Let cCod_ret = '00091';						
				END IF; 											
		END IF; 
			RETURN cCod_ret;			
	END
END PROCEDURE
DOCUMENT
'AUTOR: Viridiana Paredes Romero',
'FOLIO: 68-PgsRefCrediAvance',
'DESCRIPCION: Se crea sp_crediavance_dv para validar el digito verificador de crediavance',
'FECHA: 25/07/2016',
'VERSION:20160801.1054',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_app_valmonto(pEmpresa CHAR(3), pNombre1 CHAR(40), pNombre2 CHAR(40), pApellPat CHAR(40), pApellMat CHAR(40), pFechaNac CHAR(8), pFechaHoy CHAR(10), pMontoPaga CHAR(20),pSucursal CHAR(4))

	RETURNING 
	CHAR(6) AS CodRet; --Codigo de retorno
	
	
	 --DEFINICION DE VARIABLES--
    DEFINE sql_err      	INT;
    DEFINE cCodRet      	CHAR(6);
	DEFINE cAnio			CHAR(4);
	DEFINE cDia				CHAR(2);
	DEFINE cMes             CHAR(2);
	DEFINE cAnioFecHoy		CHAR(4);
	DEFINE cImpPagoMes		DECIMAL(8,2);
	DEFINE cPrimDiaMes		DATE;	
	DEFINE cMaxDiario		DECIMAL(8,2);
	DEFINE cMaxMes			DECIMAL(8,2);
	DEFINE iMaxOperaciones	INTEGER;
	DEFINE cMaxSuc	        MONEY(16,2); 
	DEFINE cImpPago			DECIMAL(8,2);
	DEFINE iCont			INTEGER;
	DEFINE iNumOperHist		INTEGER;
	DEFINE iNumOper			INTEGER;	
	DEFINE iNumTotalOper	INTEGER;
	DEFINE cImpDia			DECIMAL(8,2);
	DEFINE cImpMes			DECIMAL(8,2);
	
	--INICIALIZACION DE VARIABLES--
    LET sql_err 		= 0;
    LET cCodRet 		= '000000';
	LET cAnio			= '';
	LET cDia			= '';
	LET cMes            = '';
	LET cAnioFecHoy		= '';
	LET cImpPagoMes     = 0.00;
	LET cPrimDiaMes		= '';	
	LET cMaxDiario		= 0.00;
	LET cMaxMes			= 0.00;
	LET iMaxOperaciones = 0;
	LET cMaxSuc       = 0.00;
	LET cImpPago        = 0.00;
	LET iCont			= 1;
	LET	iNumOperHist	= 0;
	LET iNumOper		= 0;	
	LET iNumTotalOper	= 0;
	LET cImpDia			= 0.00;
	LET cImpMes			= 0.00;
	
	--SET DEBUG FILE TO "/informix/adrian/sp_app_valmonto.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Valida Parametros 
		IF NVL(pEmpresa,'') = '' OR NVL(pNombre1,'') = '' OR NVL(pApellPat,'') = '' OR NVL(pFechaNac,'') = '' OR NVL(pFechaHoy,'')='' OR NVL(pMontoPaga,'')='' THEN
			LET cCodRet =   '00001'; --Faltan parámetros
			RETURN cCodRet;
		END IF;
		
	-- validar los primeros 4 caracteres correspondan al año es decir que sea mayor al año 1900 hasta el año actual, aaaammdd.
		LET cAnio = SUBSTR(pFechaNac,1,4);
		LET cDia = SUBSTR(pFechaNac,7,2);
		LET cMes = SUBSTR(pFechaNac,5,2);
		
			IF YEAR(pFechaHoy)<= YEAR(CURRENT) THEN
				LET cAnioFecHoy= YEAR(pFechaHoy); --Año actual
			END IF;  
			
			IF cAnio BETWEEN 1900 AND cAnioFecHoy AND cMes BETWEEN 01 AND 12 AND cDia BETWEEN 01 AND 31 THEN
				SELECT pri_dia_mes 
				INTO cPrimDiaMes
				FROM 'informix'.sac_fechas; 
				
				--maximo acumulado diario
				SELECT valor 
				INTO cMaxDiario
				FROM 'informix'.sac_param 
				WHERE cod_param = 87100
				AND empresa = '001';
				
				--maximo acumulado por mes
				SELECT valor 
				INTO cMaxMes
				FROM 'informix'.sac_param 
				WHERE cod_param = 87101
				AND empresa = '001';
				
				--maximo de operaciones mensuales
				SELECT valor 
				INTO iMaxOperaciones
				FROM 'informix'.sac_param 
				WHERE cod_param = 87099
				AND empresa = '001';
				
				--monto limite por sucursal
				SELECT NVL(monto_limite,0.00)
				INTO cMaxSuc
				FROM bdisac:"informix".sac_app_limitesuc
				WHERE sucursal = pSucursal;				
				
				IF cMaxSuc IS NULL OR cMaxSuc = '' THEN
					LET cMaxSuc = 0;
				END IF;
				
				--Obtiene total movimiento diario
				SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
				INTO cImpDia, iNumOper
				FROM  'informix'.sac_movimientos AS a
				INNER JOIN 'informix'.sac_app_payi AS b ON (b.nnumber = a.id_sucursal AND b.unirefnum = a.referencia1 AND b.refnum = a.folio_suc)
				WHERE a.numcategoria = '07' 
				AND a.numconvenio = '009' 
				AND a.status_cancelado = 'N' 
				AND b.firstname = pNombre1
				AND b.middlename = pNombre2 
				AND b.lastname= pApellPat 
				AND b.mommaidenname= pApellMat
				AND b.dateofbirth = pFechaNac;

				--Obtiene total movimiento del mes
				SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
				INTO cImpMes, iNumOperHist
				FROM  'informix'.sac_movimientoshistorial AS a
				INNER JOIN 'informix'.sac_app_payi AS b ON (b.nnumber = a.id_sucursal AND b.unirefnum = a.referencia1 AND b.refnum = a.folio_suc)
				WHERE a.numcategoria = '07' 
				AND a.numconvenio = '009' 
				AND a.status_cancelado = 'N' 
				AND a.fecha_pago BETWEEN cPrimDiaMes AND TODAY
				AND b.firstname = pNombre1
				AND b.middlename = pNombre2 
				AND b.lastname= pApellPat 
				AND b.mommaidenname= pApellMat
				AND b.dateofbirth = pFechaNac;
				
				LET cImpPago = cImpDia + pMontoPaga;
				LET cImpPagoMes = cImpMes + cImpPago;
				LET iNumTotalOper = iNumOperHist + iNumOper;
				
				IF cMaxSuc > 0 AND (cImpPago > cMaxSuc) THEN  --valida monto diario por sucursal
					LET cCodRet= '000003';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOper, cImpDia, 'APP_SUC');				
				ELIF cImpPago > cMaxDiario THEN  --valida monto diario					
					LET cCodRet= '000003';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumOper, cImpDia, 'APP_DIA');				
				ELIF iNumTotalOper >= iMaxOperaciones THEN --valida numero de operaciones mensuales
					LET cCodRet= '000004';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumTotalOper, cImpMes + cImpDia, 'APP_OPE');
				ELIF cImpPagoMes > cMaxMes THEN --valida acumulado mensual
					LET cCodRet= '000004';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_app (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, pNombre1, pNombre2, pApellPat, pApellMat, pFechaNac, pSucursal, pMontoPaga, iNumTotalOper, cImpMes + cImpDia, 'APP_MEN');
				END IF;
				
			ELSE 
				LET cCodRet= '000002';
			END IF;
		RETURN cCodRet;
		
	END 
END PROCEDURE
DOCUMENT
'Obtiene el monto diario y mensual para cobros Appriza',
'AUTOR : Pedro G Jimenez Guzman',
'FECHA : 13-abril-2016',
'BD    : BDISAC';

CREATE PROCEDURE "informix".sp_validamontoremesabts(p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8), p_cMontoAPagar CHAR(20),p_sucursal  CHAR(4))
    RETURNING
    CHAR(5);

    --Definicion de Variables
    DEFINE cCodRet      			CHAR(5);
	DEFINE iSqlErr					INTEGER;
	DEFINE cMontoMaximo 			CHAR(10);
	DEFINE mImporte_pago			MONEY(14,2);
	DEFINE mSuma					MONEY(14,2);
	DEFINE mSumaHist                MONEY(14,2);
	DEFINE mTotal					MONEY(14,2);
	DEFINE mMontoMaxMensual			CHAR(10);
	DEFINE iNumOperaciones          INTEGER;
	DEFINE dPri_dia_mes		 		DATE;
	DEFINE cPrim_dia_mes			CHAR(10);
	DEFINE iNumOperHist				INTEGER;
	DEFINE iNumOper					INTEGER;
	DEFINE acumulado				INTEGER;
	DEFINE numOper					INTEGER;
	DEFINE mSumaMensual				MONEY(16,2);
	DEFINE mTotalMesnual			MONEY(16,2);
	DEFINE mMontoLimite               MONEY(16,2); 
	
	
	-- Inicializa variables
    LET cCodRet 				= "00000";
	LET iSqlErr 				= 0;
	LET cMontoMaximo			= "";
	LET mImporte_pago			= 0; 
	LET mSuma					= 0;
	LET mSumaHist				= 0;
	LET mTotal					= 0;
	LET mMontoMaxMensual		= 0;
    LET iNumOperaciones         = 0;
	LET dPri_dia_mes			= DATE(1);
	LET cPrim_dia_mes			= '';
	LET	iNumOperHist			= 0;
	LET iNumOper				= 0;
	LET acumulado				= 0;
	LET numOper					= 0;
	LET mSumaMensual			= 0;
	LET mTotalMesnual			= 0;
	LET mMontoLimite			= 0;
	
	--SET DEBUG FILE TO '/informix/yuri/limite/sp_validamontoremesabts.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
	
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cMontoAPagar,"") <> "" THEN
				
		SELECT Valor 
		INTO cMontoMaximo
		FROM "informix".sac_param
		WHERE empresa = p_cEmpresa
		AND cod_param = 87010;  ---valor para el monto diario
		
	    --FOLIO: EPG - 01/06/2016
		SELECT valor 
		INTO mMontoMaxMensual
		FROM "informix".sac_param 
		WHERE empresa = p_cEmpresa
		AND cod_param = 87021; --- valor para el monto mensual
		
		SELECT valor 
		INTO iNumOperaciones
		FROM "informix".sac_param 
		WHERE empresa = p_cEmpresa
		AND cod_param = 87022; --- valor para el numer operaciones mensuales
		
		SELECT pri_dia_mes
		INTO dPri_dia_mes
		FROM bdisac:"informix".sac_fechas;	
		

		LET cPrim_dia_mes = SUBSTRING (dPri_dia_mes FROM 7 FOR 4)||SUBSTRING (dPri_dia_mes FROM 1 FOR 2)||SUBSTRING (dPri_dia_mes FROM 4 FOR 2);
		
		SELECT NVL(monto_limite,0.00)
		INTO mMontoLimite
		FROM bdisac:"informix".sac_bts_limitesuc
		WHERE sucursal = p_sucursal;
		
		IF mMontoLimite IS NULL OR mMontoLimite = '' THEN
		   LET mMontoLimite = 0;
		END IF;
		
		IF NVL(cMontoMaximo,"") <> "" THEN
		
		SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
		  INTO mSumaHist, iNumOperHist
		  FROM bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_bts_payi b
		 WHERE a.referencia1 = b.confirmation_nm
		   AND a.folio_suc = b.bank_ref_nm
		   AND a.status_cancelado <> 'S'
		   AND b.r_first_name = p_cNombre1
		   AND b.r_middle_name = NVL(p_cNombre2,"")
		   AND b.r_last_name = p_cApellidoPaterno
		   AND b.r_mother_m_name = NVL(p_cApellidoMaterno,"")
		   AND b.r_fecha_nac = p_cFechaNacimiento
		   AND SUBSTRING(b.agent_dt FROM 1 FOR 8) BETWEEN cPrim_dia_mes AND p_cFechaHoy
		   AND b.opcode = 1100;
	    
		SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
		  INTO mSuma, iNumOper
		  FROM bdisac:"informix".sac_movimientos a, bdisac:"informix".sac_bts_payi b
		 WHERE a.referencia1 = b.confirmation_nm
		   AND a.folio_suc = b.bank_ref_nm
		   AND a.status_cancelado <> 'S'
		   AND b.r_first_name = p_cNombre1
		   AND b.r_middle_name = NVL(p_cNombre2,"")
		   AND b.r_last_name = p_cApellidoPaterno
		   AND b.r_mother_m_name = NVL(p_cApellidoMaterno,"")
		   AND b.r_fecha_nac = p_cFechaNacimiento
		   AND b.agent_dt = p_cFechaHoy
		   AND b.opcode = 1100;

   	    LET numOper = iNumOper + iNumOperHist;	
		LET mTotal = mSuma + CAST(p_cMontoAPagar AS MONEY(14,2));
		LET mTotalMesnual = mSuma + CAST(p_cMontoAPagar AS MONEY(14,2)) + mSumaHist;

			IF mMontoLimite > 0 AND (mTotal > CAST (mMontoLimite AS MONEY(14,2))) THEN--Valida acumulado diario por sucursal
				LET cCodRet = "00001";
				INSERT INTO bdisac:"informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
				VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOper, mSuma, 'BTS_SUC');				
			ELIF mTotal > CAST(cMontoMaximo AS MONEY(14,2)) THEN --Valida acumulado diario
				LET cCodRet = "00001";
				INSERT INTO bdisac:"informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
				VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOper, mSuma, 'BTS_DIA');				
			ELIF numOper >= iNumOperaciones THEN --Valida numero de operaciones mensual
				LET cCodRet = "00001";
				INSERT INTO bdisac:"informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
				VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, numOper, mSuma + mSumaHist, 'BTS_OPE');				
			ELIF mTotalMesnual > CAST(mMontoMaxMensual AS MONEY(14,2)) THEN --Valida acumulado mensual
				LET cCodRet = "00001";		
				INSERT INTO bdisac:"informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
				VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, numOper, mSuma + mSumaHist, 'BTS_MEN');				
			END IF;
			
		ELSE
			LET cCodRet = "00002";
		END IF;	
	ELSE
		LET cCodRet = "00003";
	END IF;
		
	RETURN cCodRet;	
    END;
END PROCEDURE
 DOCUMENT
 'AUTOR: Urias Rocha Felipe de Jesus',
 'DESCRIPCION: valida si a un Cliente se le permite Cobrar una envio BTS dependiendo de un monto maximo por dia.',
 'FECHA: 20120417',
 'BD:   bdisac',
 'MODIFICACION',
 'AUTOR: Jose Angel Lopez Adams',
 'DESCRIPCION: Se modifica SP para que la sumatoria de montos pagados se haga sin necesidad de un FOREACH, utilizando un JOIN entre las tablas sac_movimientos y sac_bts_payi',
 'SOLICITA: Jaime Gonzalez Prado',
 'FECHA: 20140509';

CREATE PROCEDURE "informix".sp_validamontoremesawu
(
	p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40),  p_cApellidoPaterno CHAR(40),p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(10), p_cEstado CHAR(2),p_mMontoAPagar CHAR(20), p_cSucursal CHAR(4)
)

RETURNING CHAR(5) AS cod_ret;

    --Definicion de Variables
    DEFINE	cCodRet      			CHAR(5);
	DEFINE	iSqlErr					INTEGER;
	DEFINE	cFronterizo				CHAR(1);
	DEFINE	cEstadoFronterizo		CHAR(100);
	DEFINE	cMontoMaximo			CHAR(20);
	DEFINE	mMontoDia				MONEY(16,2); -- FOLIO: 1508 --12/11/2015	
	DEFINE	mMontoMes				MONEY(16,2); -- FOLIO: 1508 --12/11/2015	
	DEFINE  cEstado                 CHAR(2);		
	DEFINE  mMontoMaxMensual		MONEY(16,2); -- FOLIO: 1508 -- 02/11/2015
	DEFINE  dPri_dia_mes			DATE; 	    -- FOLIO: 1508 -- 02/11/2015
	DEFINE	mTotalDiario			MONEY(16,2);	
	DEFINE	mTotalMensual			MONEY(16,2);	    
	DEFINE  cPrim_dia_mes			CHAR(10);
    DEFINE  iContadorMes            INTEGER;
    DEFINE  cMontoLim               MONEY(16,2); 
    DEFINE iNumOperaciones          INTEGER;
	DEFINE iContadorDiario 	        INTEGER;
	DEFINE iTotalOperaciones		INTEGER;
	
	-- Inicializa variables
    LET cCodRet 					= "00000";
	LET iSqlErr	 					= 0;
	LET cFronterizo					= "0";
	LET	cEstadoFronterizo			= "";
	LET	cMontoMaximo				= "";
	LET	mMontoDia					= 0.00;
	LET	mMontoMes					= 0.00;		
	LET cEstado                     = "";
	LET mMontoMaxMensual			= 0.00;
	LET dPri_dia_mes				= DATE(1);	
	LET	mTotalDiario				= 0.00;	
	LET mTotalMensual				= 0.00;
	LET cPrim_dia_mes				= '';
    LET iContadorMes                = 0;
    LET cMontoLim                   = 0.00;
    LET iNumOperaciones             = 0;
	LET iContadorDiario          	= 0;
	LET iTotalOperaciones			= 0;
	
	
	--SET DEBUG FILE TO '/informix/adrian/sp_validamontoremesawu.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cEstado,"") <> "" AND NVL(p_mMontoAPagar,"") <> "" THEN			
						
			SELECT Valor
			INTO cEstadoFronterizo
			FROM bdisac:"informix".sac_param
			WHERE empresa = p_cEmpresa
			AND cod_param = 87084;
			
			SELECT estado
			INTO cEstado
			FROM bdinteg:"informix".si_sucursales 
			where sucursal = p_cSucursal;
			
			IF TRIM(cEstadoFronterizo) LIKE '%' || cEstado || '%' THEN
				LET cFronterizo = "1";
			END IF;
						
			IF cFronterizo = "1" THEN
				SELECT Valor
				INTO cMontoMaximo
				FROM bdisac:"informix".sac_param
				WHERE empresa = p_cEmpresa
				AND cod_param = 87082;
				
			ELSE
				SELECT Valor
				INTO cMontoMaximo
				FROM bdisac:"informix".sac_param
				WHERE empresa = p_cEmpresa
				AND cod_param = 87083;
			END IF;

            -- Saca el monto limite x sucursal (locales)
            SELECT NVL(monto_limite,0.00)
            INTO cMontoLim
            FROM bdisac:"informix".sac_wu_limxsuc
            WHERE sucursal = p_cSucursal;

			IF cMontoLim IS NULL OR cMontoLim = '' THEN
				 LET cMontoLim = 0;
			END IF;
			
			SELECT valor 
			INTO mMontoMaxMensual
			FROM "informix".sac_param 
			WHERE empresa = p_cEmpresa
			AND cod_param = 87094;

			SELECT valor 
			INTO iNumOperaciones
			FROM "informix".sac_param 
			WHERE empresa = p_cEmpresa
			AND cod_param = 87096; --- valor para el nÃºmero operaciones mensuales
			
			SELECT pri_dia_mes
			INTO dPri_dia_mes
			FROM bdinteg:"informix".si_fechas;
		
			LET cPrim_dia_mes = SUBSTRING (dPri_dia_mes FROM 7 FOR 4)||'-'||
			SUBSTRING (dPri_dia_mes FROM 1 FOR 2)||'-'||SUBSTRING (dPri_dia_mes FROM 4 FOR 2);
			
			SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
			  INTO mMontoMes, iContadorMes
			  FROM bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_wu_pay b
			 WHERE a.referencia1 = b.mtcn
			   AND a.folio_suc = b.foreign_rs_refnum_rq
			   AND a.status_cancelado <> 'S'
			   AND b.benef_nombre1 = p_cNombre1
			   AND b.benef_nombre2 = NVL(p_cNombre2,"")
			   AND b.benef_appaterno = p_cApellidoPaterno
			   AND b.benef_apmaterno = NVL(p_cApellidoMaterno,"")
			   AND b.benef_fecha_nac = p_cFechaNacimiento
			   AND SUBSTRING(fecha_hora_rp FROM 1 FOR 10) BETWEEN cPrim_dia_mes AND p_cFechaHoy
			   AND retcode = '00000'
			   AND conf_pago = 'P';	
			
			SELECT NVL(SUM(a.importe_pago),0), count(*) as num_operaciones
			  INTO mMontoDia, iContadorDiario
			  FROM bdisac:"informix".sac_movimientos a, bdisac:"informix".sac_wu_pay b
			 WHERE a.referencia1 = b.mtcn
			   AND a.folio_suc = b.foreign_rs_refnum_rq
			   AND a.status_cancelado <> 'S'
			   AND b.benef_nombre1 = p_cNombre1
			   AND b.benef_nombre2 = NVL(p_cNombre2,"")
			   AND b.benef_appaterno = p_cApellidoPaterno
			   AND b.benef_apmaterno = NVL(p_cApellidoMaterno,"")
			   AND b.benef_fecha_nac = p_cFechaNacimiento
			   AND SUBSTRING(fecha_hora_rp FROM 1 FOR 10) = p_cFechaHoy
			   AND retcode = '00000'
			   AND conf_pago = 'P';
			   
			    LET iTotalOperaciones = iContadorMes + iContadorDiario;
				LET mTotalDiario = mMontoDia + CAST(p_mMontoAPagar AS MONEY(14,2));
			    LET mTotalMensual = mMontoMes + mMontoDia + CAST(p_mMontoAPagar AS MONEY(14,2));			   
			   
				IF cMontoLim > 0 AND (mTotalDiario > cMontoLim) THEN --Valida acumulado diario por sucursal
					LET cCodRet = "00001";
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iContadorDiario, mMontoDia, 'WU_SUC');					
				ELIF mTotalDiario > CAST(cMontoMaximo AS MONEY(14,2)) THEN
					LET cCodRet = "00001";
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iContadorDiario, mMontoDia, 'WU_DIA');
				ELIF iTotalOperaciones >= iNumOperaciones THEN --Valida numero de operaciones mensual
					LET cCodRet = "00004";
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iTotalOperaciones, mMontoMes + mMontoDia, 'WU_OPE');
				ELIF mTotalMensual > CAST(mMontoMaxMensual AS MONEY(14,2)) THEN --Valida acumulado mensual
					LET cCodRet = "00004";
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iTotalOperaciones, mMontoMes + mMontoDia, 'WU_MEN');
				END IF;			
		ELSE   
		   LET cCodRet = "00002";
		   RETURN cCodRet;
		END IF;					
		
		RETURN cCodRet;		
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Christian Echavarria',
'DESCRIPCION: valida si a un Cliente se le permite Cobrar una envio WU dependiendo de un monto maximo por dia.',
'FECHA: 25/Jul/2013',
'BD:   bdisac',
'MODIFICA: 96273763 - Antonio Cebreros PÃ?Â©rez.',
'DESCRIPCION: Se agrega validaciÃ?Â³n de monto mÃ?Â¡ximo por mes, esto posterior a la validaciÃ?Â³n de monto mÃ?Â¡ximo por dÃ?Â­a.',
'FOLIO: 230202 - 1508 - MttoRemWUyOVoVFrontNte',
'FECHA: 02/11/2015';

CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal_pbahtm(cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(8) AS usuario,
CHAR(16) AS folio_suc,
CHAR(40) AS nomconvenio,
CHAR(20) AS referencia1,
CHAR(20) AS referencia2,
MONEY(16,2) AS importe_pago,
MONEY(16,2) AS importe_comision_convenio,
MONEY(16,2) AS iva_comision_convenio,
MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte,
CHAR(1) AS forma_pago,
CHAR(12) AS cuenta_cargo,
CHAR(40) AS region;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cUsuario                 CHAR(8);
DEFINE cFolioSuc                CHAR(16);
DEFINE cNumcategoria            CHAR(2);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE cReferencia1             CHAR(20);
DEFINE cReferencia2             CHAR(20);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE cFormaPago               CHAR(1);
DEFINE cCuentaCargo             CHAR(12);
DEFINE cRegion                  CHAR(40);

--SET DEBUG FILE TO "/home/informix/exi.out";
--TRACE ON;


--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cUsuario              = "";
LET cFolioSuc             = "";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cNomConvenio          = "";
LET cReferencia1          = "";
LET cReferencia2          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET cFormaPago            = "";
LET cCuentaCargo          = "";
LET cRegion               = "";

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
        END IF;

    END EXCEPTION;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
        LET cCodRet = "00001";
        RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
    ELSE
        IF cConvenio = "00000" THEN   -- Todos los convenios y una sucursal
            SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
            b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
            --INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, deImportePago, deImpComisionConvenio, deIVAComisionConvenio, deImpComisionCte, deIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
            FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
            WHERE b.fecha_pago::DATE  >= dFechaIni
            AND b.fecha_pago::DATE  <= dFechaFin
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND b.id_sucursal = cSucursal
            AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
            AND c.sucursal = b.id_sucursal
            AND d.plaza = c.plaza
            AND e.regional = d.regional
            INTO TEMP tmp_movs WITH NO LOG;
            --ORDER BY 3, 2 ASC
            FOREACH
                SELECT usuario, folio_suc, nomconvenio, referencia1, referencia2, importe_pago, importe_comision_convenio, iva_comision_convenio,
                    importe_comision_cte, iva_comision_cte, forma_pago, cuenta_cargo, nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:tmp_movs ORDER BY folio_suc, nomconvenio

                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
            DROP TABLE bdisac:tmp_movs;
        ELSE   --Un convenio y una sucursal
            FOREACH
                SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago::DATE >= dFechaIni
                AND b.fecha_pago::DATE  <= dFechaFin
                AND b.numcategoria = cNumcategoria
                AND b.numconvenio = cNumconvenio
                AND a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio
                AND b.id_sucursal = cSucursal
                AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
                AND c.sucursal = b.id_sucursal
                AND d.plaza = c.plaza
                AND e.regional = d.regional

                ORDER BY 3  ASC
                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
        END IF;
    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal_pbahtm(cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE,stipo smallint)
-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(8) AS usuario,
CHAR(16) AS folio_suc,
CHAR(40) AS nomconvenio,
CHAR(40) AS referencia1,
CHAR(40) AS referencia2,
MONEY(16,2) AS importe_pago,
MONEY(16,2) AS importe_comision_convenio,
MONEY(16,2) AS iva_comision_convenio,
MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte,
CHAR(1) AS forma_pago,
CHAR(12) AS cuenta_cargo,
CHAR(40) AS region;


-- DEFINICION DE VARIABLES
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cUsuario CHAR(8);
DEFINE cFolioSuc CHAR(16);
DEFINE cNumcategoria CHAR(2);
DEFINE cNumconvenio CHAR(3);
DEFINE cNomconvenio CHAR(40);
DEFINE cReferencia1 CHAR(40);
DEFINE cReferencia2 CHAR(40);
DEFINE mImpComisionConvenio MONEY(16,2);
DEFINE mIVAComisionConvenio MONEY(16,2);
DEFINE mImpComisionCte MONEY(16,2);
DEFINE mIVAComisionCte MONEY(16,2);
DEFINE mImportePago MONEY(16,2);
DEFINE cFormaPago CHAR(1);
DEFINE cCuentaCargo CHAR(12);
DEFINE cRegion CHAR(40);

--SET DEBUG FILE TO "/respaldosbb/mario/sp_sacreportedetalletransaccionsucursal.out";
--TRACE ON;


--INICIALIZACION DE VARIABLES--
LET cCodRet = "00000";
LET cUsuario = "";
LET cFolioSuc = "";
LET cNumcategoria = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cNomConvenio = "";
LET cReferencia1 = "";
LET cReferencia2 = "";
LET mImportePago = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte = 0;
LET mIVAComisionCte = 0;
LET cFormaPago = "";
LET cCuentaCargo = "";
LET cRegion = "";

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
        END IF;
    END EXCEPTION;

		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
        LET cCodRet = "00001";
        RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
    ELSE
        IF cConvenio = "00000" THEN   -- Todos los convenios y una sucursal
            SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
            b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
            --INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, deImportePago, deImpComisionConvenio, deIVAComisionConvenio, deImpComisionCte, deIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
            FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d,  bdinteg:si_regional e
            WHERE b.fecha_pago::DATE  >= dFechaIni
            AND b.fecha_pago::DATE  <= dFechaFin
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND b.id_sucursal = cSucursal
            AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
            AND c.sucursal = b.id_sucursal
            AND d.plaza = c.plaza
            AND e.regional = d.regional
            INTO TEMP tmp_movs WITH NO LOG;
            --ORDER BY 3, 2 ASC
            FOREACH
                SELECT usuario, folio_suc, nomconvenio, referencia1, referencia2, importe_pago, importe_comision_convenio, iva_comision_convenio,
                    importe_comision_cte, iva_comision_cte, forma_pago, cuenta_cargo, nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:tmp_movs ORDER BY folio_suc, nomconvenio

                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
            DROP TABLE bdisac:tmp_movs;
        ELSE   --Un convenio y una sucursal
            FOREACH
                SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago::DATE >= dFechaIni
                AND b.fecha_pago::DATE  <= dFechaFin
                AND b.numcategoria = cNumcategoria
                AND b.numconvenio = cNumconvenio
                AND a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio
                AND b.id_sucursal = cSucursal
                AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
                AND c.sucursal = b.id_sucursal
                AND d.plaza = c.plaza
                AND e.regional = d.regional

                ORDER BY 3  ASC
                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
        END IF;
    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio:1570',
'Autor:95142134 Mario Gallardo',
'Fecha:24/01/2014',
'Modificación: Se modifica referencia1 y referencia2 a 40 carcateres.',
'Sustento: RQI 62 064-Reingeniería_PagoServicios -  (Pagina 2 a 36)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtienelineabase_bpi(pCaptura CHAR(20), pImporte CHAR(20), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno, CHAR(20)  AS Leyenda, CHAR(20) AS LineaBase;

--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE i			INTEGER;
DEFINE iP			INTEGER;
DEFINE cP 			INTEGER;
DEFINE iResultado 	INTEGER;
DEFINE iMod     	INTEGER;
DEFINE iPotencia    INTEGER;
DEFINE iPot			INTEGER;
DEFINE iCadenaA_2 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2     CHAR(5);
DEFINE cDigV        CHAR(2);
DEFINE k 			CHAR(1);
DEFINE cCadena 		CHAR(20);
DEFINE cLetra 		CHAR(1);
DEFINE cLlave       CHAR(100);
DEFINE cConcepto    CHAR(2);
DEFINE cCadenaB     CHAR(5);
DEFINE cCadenaA 	CHAR(10);
DEFINE cK		 	NUMERIC;
DEFINE nSuma        NUMERIC;
DEFINE nCociente  	NUMERIC;
DEFINE dFecha_Hoy 	DATE;
DEFINE cLeyenda     CHAR(20);
DEFINE cLlaveGDF 	CHAR(5);

--Inicializacion de Variables
LET iSqlErr 	= 0;
LET cCodRet 	= '00000';
LET cCodRet2    = '';
LET i       	= 0;
LET cK      	= '0';
LET nSuma   	= '0';
LET cCadena 	= '';
LET nCociente	= '0';
LET dFecha_Hoy	= DATE(1);
LET iMod		= 0;
LET cLetra		= '';
LET cP 			= 0;
LET k			= '';
LET iResultado  = 0;
LET iPot 		= 0;
LET cCadenaA  	= '';
LET iCadenaA_2  = 0;
LET cCadenaB 	= '';
LET cDigV 		= '';
LET cLlave 		= '';
LET cConcepto 	= '';
LET iP 			= 0;
LET cLeyenda    = '';
LET cLlaveGDF	= '';

-- SET DEBUG FILE TO '/home/informix/bibiana/sp_obtienelineabase_bpi.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, cLeyenda, cCadena;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF (TRIM(NVL(pCaptura,'')) = '' OR LENGTH(TRIM(pCaptura)) <> 20) OR TRIM(NVL(pImporte,'')) = '' OR TRIM(NVL(pLlaveGDF,'')) = '' THEN
		LET cCodRet = '00002';
	ELSE
		
		LET cConcepto = pCaptura[1,2];
		
		EXECUTE PROCEDURE bdisac:"informix".sp_consultaconceptogdf(cConcepto) INTO cCodRet2, cLeyenda;
			
		IF cCodRet2 <> '00000' THEN
			LET cCodRet = cCodRet2;
		ELSE			
			--LET cLlave = 38001979;
			-- 12357113
			SELECT valor 
			INTO cLlave
			FROM bdisac:"informix".sac_param 
			WHERE cod_param = pLlaveGDF;
			
			LET cCadenaB = UPPER(pCaptura[14,18]);
			
			FOR i = 1 TO 5

				IF i = 1 THEN 
					LET  k = cCadenaB[1,1]; 
					LET iP = 4;
				ELIF i = 2 THEN 
					LET  k = cCadenaB[2,2];
					LET iP = 3;
				ELIF i = 3 THEN 
					LET  k = cCadenaB[3,3];
					LET iP = 2;
				ELIF i = 4 THEN 
					LET  k = cCadenaB[4,4];
					LET iP = 1;
				ELIF i = 5 THEN 
					LET  k = cCadenaB[5,5];
					LET iP = 0;
				END IF;

				IF k IS NOT NULL THEN

					SELECT valor 
					INTO cP 
					FROM bdisac:"informix".sac_base30
					WHERE letra = k;
					LET iPotencia = cP * POW(30,iP);
					LET nSuma = nSuma + iPotencia;
					
				END IF;				
			END FOR;
		   
			LET iResultado = nSuma - TRIM(cLlave)::INTEGER;
			LET iResultado = TRUNC(iResultado - pImporte::INTEGER); 
			LET iMod = POW(30,5);
			
			IF iResultado < 0 THEN
				LET iPot = iResultado + iMod;
			ELSE
				LET iPot = MOD(iResultado,iMod);
			END IF;
			
			-- Valida que la llave enviada sea del aÃÂ±o anterior (2014) 
			IF pLlaveGDF = '87042' THEN 
			
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF;
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF;
				
			END IF;
			--	Valida que la llave enviada sea del aÃÂ±o 2015 
			
			IF pLlaveGDF = '87034' THEN				
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF;
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF; 
				
				IF iPot < 0 THEN
					LET iPot = iPot + iMod;
				END IF; 
				
			END IF;
			
			
			LET iCadenaA_2 = iPot;
			FOR iP = 1 TO 5
				LET	iMod = MOD (iCadenaA_2,30);
				LET nCociente = iCadenaA_2 / 30 ;
				IF nCociente = '0' THEN
					EXIT FOR;
				END IF;
				LET iCadenaA_2 = nCociente;
				
				SELECT letra 
				INTO cLetra 
				FROM bdisac:"informix".sac_base30 
				WHERE valor = iMod;
				
				LET cCadenaA = cLetra || cCadenaA;
				
			END FOR;
			
			LET cLlaveGDF = pLlaveGDF::char(5);
			
			LET cCadena = TRIM(TRIM(pCaptura[1,13]) || TRIM(cCadenaA) || TRIM(pCaptura[19,20]));
			IF (cLlaveGDF<>'87042') THEN
											
				EXECUTE PROCEDURE bdisac:"informix".sp_validalimpago(cCadena) INTO cCodRet2;
				
				IF cCodRet2 = '00000' THEN
					
					EXECUTE PROCEDURE bdisac:"informix".sp_validadvgdf(cCadena) INTO cCodRet2;
					
					IF cCodRet2 = '00000' THEN
						LET cCodRet = '00000';
					ELSE
						LET cCodRet = cCodRet2;
					END IF;
				ELSE
					IF cCodRet2 == '00003' THEN
						LET cCodRet = '00403';
					ELSE
						LET cCodRet = cCodRet2;
					END IF;
				END IF;
			END IF;
			
		END IF;
	END IF;
	
	RETURN cCodRet, cLeyenda, cCadena;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para la validaciÃÂ³n del DÃÂ­gito Verificador para el Impuesto de GDF.',
'AUTOR : MartÃÂ­n Eduardo Miranda',
'FECHA : 12 de Diciembre 2012',
'VERSION: 20121212.12',
'BD: bdisac',
'MODIFICACION : 11/02/2013',
'MODIFICO :Felipe Urias  ',
'DESCRIPCION: se agrega como retorno la leyenda de conceptos de sac_catconceptosgdf',
'MODIFICACION : 09/05/2013',
'MODIFICO : Ing. Cruz  ',
'DESCRIPCION: Nuevo valor de retorno: lÃÂ­nea base.',
'MODIFICACION : 30/10/2013',
'MODIFICO : Ing. Cruz  ',
'DESCRIPCION: ValidaciÃÂ³n de fecha lÃÂ­mite de pago.',
'Folio: 1448',
'Autor: 95734511 - L.S.C. JosÃÂ© Magdiel MartÃÂ­nez',
'Fecha: 09-04-2014',
'ModificaciÃÂ³n: Se aÃÂ±ade un nuevo parÃÂ¡metro quen contiene la llave de decodificaciÃÂ³n de la linea base.',
'Sustento: Reimpresion GDF',
'Se modifica el SP agregando la validaciÃÂ³n de la llave que se envÃÂ­a, esto para poder reimprimir los comprobantes',
'Bibiana Gaxiola Verdugo',
'13/01/2015';

CREATE PROCEDURE "informix".sp_remesaswu_pld(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(80);
	DEFINE cStatus				CHAR(1);	
	DEFINE cDescripcionSPJWU	 CHAR(100);	
	DEFINE cDescripcionSPJOV	 CHAR(100);	
	DEFINE cDescripcionSPJVG	 CHAR(100);	
	DEFINE cCodRetSP			 CHAR(5);
			
	LET cCodRet  =   "00000";
	LET cMensaje = 'PROCESO EXITOSO';	
	LET cStatus						= '0';	
	LET cDescripcionSPJWU	  = 'Inserta datos de Remesas Western Union para sistema de PLD';
	LET cDescripcionSPJOV = 'Inserta datos de Remesas Orlandi Valuta para sistema de PLD';
	LET cDescripcionSPJVG = 'Inserta datos de Remesas Vigo para sistema de PLD';
	LET cCodRetSP = "00000";
	
	--SET DEBUG FILE TO  '/informix/adrian/sp_remesaswu_pld.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesaswu_pld");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;				
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE WU";
				RETURN cCodRet, cMensaje;			
			END IF;	
			
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_WU' and fecha_proceso = FechaFin) THEN									
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_WU', FechaFin, '0', 'informix', 'sp_remesaswu_pld_wu', cDescripcionSPJWU);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_WU' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN						
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='WUN' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','WUN',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE WU EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;			
			IF cStatus = '0' THEN
				--WU
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_wu('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;				
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_WU', FechaFin, '1', 'informix', 'sp_remesaswu_pld_wu', cDescripcionSPJWU);
			END IF;	
			LET cStatus = '0';
			
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE OVA";
				RETURN cCodRet, cMensaje;			
			END IF;	
			
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_OV' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_OV', FechaFin, '0', 'informix', 'sp_remesaswu_pld_ov', cDescripcionSPJOV);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_OV' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN						
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='OVA' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','OVA',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE OVA EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;				
			IF cStatus = '0' THEN					
				--OV
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_ov('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;			
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_OV', FechaFin, '1', 'informix', 'sp_remesaswu_pld_ov', cDescripcionSPJOV);			
			END IF;
			LET cStatus = '0';			
			
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE VG";
				RETURN cCodRet, cMensaje;			
			END IF;	
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_V' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_V', FechaFin, '0', 'informix', 'sp_remesaswu_pld_vg', cDescripcionSPJVG);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_V' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN					
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='VIG' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','VIG',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE VG EN TABLA DE PLD";							
							RETURN cCodRet, cMensaje;			
						END IF;		
					END IF;
				END IF;			
			END IF;			
			IF cStatus = '0' THEN			
				--VG
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_vg('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_V', FechaFin, '1', 'informix', 'sp_remesaswu_pld_vg', cDescripcionSPJVG);	
			END IF;
		END IF;			
		
		RETURN cCodRet, cMensaje;

	END;
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE WU";
				RETURN cCodRet, cMensaje;			
			END IF;	
END PROCEDURE;
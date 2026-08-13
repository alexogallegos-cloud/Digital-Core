CREATE PROCEDURE "informix".sp_tef_obtcodbanco(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
CHAR(3)		    AS Codigo_banco, 
VARCHAR(40)		AS Descripcion;	  
	
---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);
DEFINE cBanco			CHAR(3);
DEFINE cDescripcion			VARCHAR(40);	
DEFINE iContador			INTEGER;	

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cBanco			= '';
LET cDescripcion		= '';
LET iContador		= 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, '', '';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obtcodbanco.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(ptipo,0) NOT IN (1,2,3) OR (NVL(pCuenta,"") = "" AND  NVL(ptipo,0) IN (0,2,3)) THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametro Invalido, Verifique...';
    END IF;
	
	IF ptipo = 1 THEN --créditos hipotecarios crédito automotriz, hipotecario ó personal		
		FOREACH 
			SELECT banco,descripcion
				INTO cBanco , cDescripcion
			FROM bdinteg:"informix".si_bancos
			WHERE banco <> '137'			
			AND flg_tef_r = '1'
			
			LET iContador= iContador+1;
			
			RETURN cCodRet, cMensajeRet, cBanco, TRIM(cDescripcion) WITH RESUME;
		END FOREACH;
		
	ELIF ptipo = 2 THEN --Tarjeta de débito
		--Selección de Num. Tarjeta de Débito
		SELECT cve_banco,banco_prosa
			INTO cBanco , cDescripcion
		FROM bdicheq:"informix".sc_bines
		WHERE bin = SUBSTR(pCuenta, 1,6);		
		
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco,descripcion
			INTO cBanco , cDescripcion
		FROM bdinteg:"informix".si_bancos
		WHERE banco = SUBSTR(pCuenta,1,3)
		AND flg_tef_r = '1';				
	END IF;				
	
	IF iContador = 0 AND ptipo = 1  THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'NO EXISTE INFORMACION, VERIFIQUE...';
		RETURN cCodRet, cMensajeRet, cBanco, cDescripcion;
	ELIF iContador = 0 AND ptipo <> 1  THEN
		RETURN cCodRet, cMensajeRet, cBanco, TRIM(cDescripcion);
	END IF;
	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso obtiene los codigos de banco para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'DESCRIPCION: Se modifica procedimiento ya que regresaba dos veces el banco "021-HSBC MEXICO, S.A."', 
'AUTOR: Armando Morales Barraza',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120710.1021';

CREATE PROCEDURE "informix".sp_tef_obtinforpt(pClaveRastreo CHAR(30))
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
DATE 			AS fecha_trans,
CHAR(30)		AS clave_rastreo,
CHAR(10) 		AS importe_tef,
DATE 			AS fecha_programacion,
CHAR(45)		AS nombre_usuario,
CHAR(16)		AS folio_suc,
CHAR(30)		AS nombre_cte_ord,
CHAR(20)		AS numcte_ord,
CHAR(20)		AS num_cta_ord,
CHAR(30)		AS tipo_cta_ord_desc,
CHAR(5)			AS comision_tef,
CHAR(5)			AS iva_tef ,
CHAR(30)		AS nombre_ben,
CHAR(30)		AS tipo_cta_ben,
CHAR(20)		AS num_cuenta_tarj_ben,
CHAR(15)		AS rfc_ben,
CHAR(50)		AS concepto_pago,
CHAR(7)			AS ref_num,
CHAR(8)			AS hora_trans;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);	
	
DEFINE dtFecha_trans		DATE;
DEFINE cClave_rastreo 		CHAR(30);
DEFINE cImporte_tef 		CHAR(10) ;
DEFINE dtFecha_programacion DATE;
DEFINE cNombre_usuario 		CHAR(45);
DEFINE cFolio_suc 			CHAR(16);
DEFINE cNombre_cte_ord		CHAR(30);
DEFINE cNumcte_ord 			CHAR(20);
DEFINE cNum_cta_ord 		CHAR(20);
DEFINE cTipo_cta_ord 		CHAR(2);
DEFINE cTipo_cta_ord_desc	CHAR(30);
DEFINE cComision_tef 		CHAR(5);
DEFINE cIva_tef 			CHAR(5)	;
DEFINE cNombre_ben 			CHAR(30);
DEFINE cTipo_cta_ben 		CHAR(2);
DEFINE cTipo_cta_ben_des 	CHAR(30);
DEFINE cNum_cuenta_tarj_ben CHAR(20);
DEFINE cRfc_ben 			CHAR(15);
DEFINE cConcepto_pago 		CHAR(50);
DEFINE cRef_num 			CHAR(7)	;  
DEFINE cUsuario 			CHAR(8)	;  
DEFINE cHoraTrans 			CHAR(8)	;  
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
	
LET dtFecha_trans		 = "";
LET cClave_rastreo 		 = "";
LET cImporte_tef 		 = "";
LET dtFecha_programacion = "";
LET cNombre_usuario 	 = "";
LET cFolio_suc 			 = "";
LET cNombre_cte_ord		 = "";
LET cNumcte_ord 		 = "";
LET cNum_cta_ord 		 = "";
LET cTipo_cta_ord 		 = "";
LET cTipo_cta_ord_desc 	 = "";
LET cComision_tef 		 = "";
LET cIva_tef 			 = "";
LET cNombre_ben 		 = "";
LET cTipo_cta_ben 		 = "";
LET cTipo_cta_ben_des 	 = "";
LET cNum_cuenta_tarj_ben = "";
LET cRfc_ben 			 = "";
LET cConcepto_pago 		 = "";
LET cRef_num 			 = "";
LET cUsuario 			 = "";
LET cHoraTrans 			 = "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, ''	,'' ,'','','' ,'','','','' ,'','','','','','','','','','';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obtinforpt.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF NVL(pClaveRastreo,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	ELSE	
		
		IF EXISTS (SELECT  clave_rastreo FROM bditef:"informix".tef_operaciones	WHERE clave_rastreo = pClaveRastreo) THEN
			SELECT  fecha_trans, clave_rastreo, importe_tef,fecha_programacion,  folio_suc,nombre_cte_ord,
			num_cta_ord, tipo_cta_ord, comision_tef,iva_tef , nombre_ben,tipo_cta_ben, num_cuenta_tarj_ben,rfc_ben,
			concepto_pago, ref_num, user_insert,SUBSTR(hora_insert,1,2)||":"||SUBSTR(hora_insert,3,2)||":"||SUBSTR(hora_insert,5,2)
			INTO dtFecha_trans	,cClave_rastreo ,cImporte_tef,dtFecha_programacion,cFolio_suc,cNombre_cte_ord,
			cNum_cta_ord ,cTipo_cta_ord,cComision_tef,cIva_tef,cNombre_ben,cTipo_cta_ben,cNum_cuenta_tarj_ben,cRfc_ben,
			cConcepto_pago,cRef_num,cUsuario,cHoraTrans
			FROM bditef:"informix".tef_operaciones
			WHERE clave_rastreo = pClaveRastreo;
			
			
			SELECT num_cte
				INTO cNumcte_ord
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = '001'
			AND cuenta = cNum_cta_ord;
			
			SELECT descripcion
				INTO cTipo_cta_ben_des
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_cta_ben;
			
			SELECT descripcion
				INTO cTipo_cta_ord_desc
			FROM bditef:"informix".tef_tipo_cta
			WHERE tipo_cta = cTipo_cta_ord;
			
			SELECT nombre
			INTO cNombre_usuario
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cUsuario;
			
		ELSE
			LET cCodRet = '000002';
			LET cMensajeRet = 'NO EXISTE INFORMACION, VERIFIQUE';
		END IF;		
    END IF;
	IF NVL(cRfc_ben,"") = "" THEN
		LET cRfc_ben ="NO DISPONIBLE";
	END IF;	
	
	RETURN cCodRet, cMensajeRet, dtFecha_trans	,cClave_rastreo ,cImporte_tef,dtFecha_programacion,cNombre_usuario ,cFolio_suc,cNombre_cte_ord,cNumcte_ord 	,cNum_cta_ord ,cTipo_cta_ord_desc,
		cComision_tef,cIva_tef,cNombre_ben,cTipo_cta_ben_des,cNum_cuenta_tarj_ben,cRfc_ben,cConcepto_pago,cRef_num,cHoraTrans;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener la informacion para visualizar el reporte de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120625.1021';

CREATE PROCEDURE "informix".sp_tef_obttipocta()
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret,
VARCHAR(2)		AS tipo_cuenta, 
VARCHAR(20)		AS descripcion_cuenta;
	
---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cMensajeRet			VARCHAR(80);
DEFINE cTipo_cta			CHAR(2);
DEFINE cDescripcion			VARCHAR(20);
	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'PROCESO EXITOSO';
LET cTipo_cta			= '';
LET cDescripcion		= '';
	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet), '', '';
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_obttipocta.out';
	--TRACE ON;

	FOREACH 
		 SELECT tipo_cta, descripcion
		 INTO cTipo_cta, cDescripcion
		 FROM bditef:"informix".tef_tipo_cta
		 ORDER BY tipo_cta
		 
		 RETURN cCodRet, TRIM(cMensajeRet), cTipo_cta, TRIM(cDescripcion) WITH RESUME;
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2")= 0 THEN
	 LET cCodRet = '000001';
	 LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
	 RETURN cCodRet, TRIM(cMensajeRet), cTipo_cta, TRIM(cDescripcion) ;
	END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que obtiene los tipos de cuentas para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_reversoperacion(pfecha DATE,
												  pSucursal CHAR(4),
												  pEjecutivo CHAR(8),
												  pFolioSuc VARCHAR(16))  
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(100) 	AS desc_ret;  

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			VARCHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodretRev			CHAR(5);
DEFINE cMensajeRet			VARCHAR(100);

DEFINE cFolioSuc			VARCHAR(16);
DEFINE cNumCtaOrd			VARCHAR(20);
DEFINE cReferencia			VARCHAR(40);
DEFINE cImporte			    CHAR(10);
DEFINE cReversado			CHAR(2);

DEFINE cCodretVal   CHAR(5);
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);	
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cCodretRev			= '00000';
LET cMensajeRet			= 'PROCESO EXITOSO';

LET cFolioSuc			= '';
LET cNumCtaOrd			= '';
LET cReferencia			= '';
LET cImporte			= '';
LET cReversado			= '';

LET cCodretVal   = "";
LET cTpo_Proc    = "";
LET cFech_Proc   = "";
LET cCve_Proc    = "";
LET cDescripcion = "";
LET cEstatus     = "";

	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_reversoperacion.out';
	--TRACE ON;

	-- VALIDA QUE LOS parámetros NO VENGAN VACIOS
    IF NVL(pfecha,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pFolioSuc,"") = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta uno o mas parámetros';
	ELSE
		IF pfecha::DATE <> (SELECT fecha_hoy FROM  bdicheq:"informix".sc_fechas) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Fecha invalida, verifique...';
		ELSE
			IF EXISTS (SELECT folio_suc FROM bditef:"informix".tef_operaciones
					   WHERE fecha_trans = pfecha AND folio_suc = pFolioSuc
						AND sucursal = pSucursal AND user_insert = pEjecutivo ) THEN
						
				SELECT  DECODE(cve_status,"PE","N","05","S","")	
					INTO cReversado
				FROM bditef:"informix".tef_operaciones
				WHERE fecha_trans = pfecha
				AND folio_suc = pFolioSuc
				AND sucursal = pSucursal
				AND user_insert = pEjecutivo;
				
				IF cReversado = "S" THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'Folio proporcionado ya fue reversado, verifique...';
				ELIF cReversado = "" THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'Folio se encuentra en estatus invalido, verifique...';
				ELSE
					EXECUTE PROCEDURE  bditef:"informix".sp_tef_validahorario(CURRENT HOUR TO SECOND)
						INTO cCodRet, cMensajeRet;
					IF CAST(cCodRet AS INTEGER) <> 0 THEN --SE VALIDA QUE EL HORARIO SE ENCUENTRE EN EL RANGO PERMITIDO
						LET cCodRet = "000002";
						LET cMensajeRet = cMensajeRet;	
					ELSE										
						EXECUTE PROCEDURE bditef:"informix".sp_tef_validarchcod60('', "GENARCH_60.01") 
						INTO cCodretVal, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;		
						
						IF cCodretVal::integer <> 0 THEN					
							LET cCodRet = '000003';
							LET cMensajeRet = 'No es posible registrar la operación TEF. El proceso de generación de archivo ya ha iniciado.';							
						ELSE							
							EXECUTE PROCEDURE bdicheq:"informix".reversion_sif('001',pSucursal,pEjecutivo,pFolioSuc,'A') INTO cCodretRev;
							
							IF cCodretRev::INTEGER <> 0 THEN
								LET cCodRet = '000006';
								LET cMensajeRet = 'Ocurrio un error al realizar la reversion, verifique...';							
							END IF
						END IF
					END IF
				END IF
				
			ELSE
				LET cCodRet = '000007';
				LET cMensajeRet = 'no se encontro informacion, verifique...';
			END IF			
		END IF
    END IF;	

	RETURN cCodRet, cMensajeRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para reversar la informacion de alta operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120626.1021',
'DESCRIPCION: Se cambia el nombre al llamado del procedimiento "reversion" por "reversion_sif"', 
'AUTOR: Armando Morales Barraza',
'BASE DE DATOS: bditef',
'FECHA: Julio 2012',
'VERSION: 20120717.0921';

CREATE PROCEDURE "informix".sp_tef_validahorario(pHorario DATETIME HOUR TO MINUTE)
RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(100) 	AS desc_ret;  
	
---DECLARACIONES
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(100);
DEFINE cCodRet      CHAR(6);
DEFINE cMensajeRet  VARCHAR(100);
DEFINE dtHorarioMax DATETIME HOUR TO MINUTE;

---INICIALIZACIONES
LET iSqlErr			= 0;
LET iIsamErr		= 0;
LET cErrorInfo		= '';
LET cCodRet			= '000000';
LET cMensajeRet		= 'PROCESO EXITOSO';
LET dtHorarioMax	= '';

	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(cMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_tef_validahorario.out';
	--TRACE ON;	
	--se obtiene la hora maxima permitida
	 IF NVL(pHorario,"") = ""  THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'PARAMETRO INVALIDO, VERIFIQUE...';
     END IF;
	 
	SELECT valor INTO  dtHorarioMax FROM  bditef:"informix".tef_parametros
	WHERE cod_param = '11';	
	
	IF pHorario >= dtHorarioMax THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'No es posible registrar la operación TEF. El horario excede del tiempo máximo establecido.';
	END IF;

	RETURN cCodRet, TRIM(cMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza la validación del horario permitido para operaciones TEF en central', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021';

CREATE PROCEDURE "informix".sp_tef_validarchcod60(pTpo_Proc CHAR(1), pCve_Proceso CHAR(20))

RETURNING CHAR(5), CHAR(1), CHAR(10), CHAR(20), CHAR(60), CHAR(1);

---Declaración de Variables
DEFINE cCodret   CHAR(5);
DEFINE sql_err   INTEGER;
DEFINE cTpo_Proc CHAR(1); 
DEFINE cFech_Proc CHAR(10);
DEFINE cCve_Proc CHAR(20);
DEFINE cDescripcion CHAR(60);
DEFINE cEstatus CHAR(1);
DEFINE cFecha_hoy CHAR(10);

---Inicialización de Variables
LET cCodret = '00000';
LET sql_err = 0;
LET cTpo_Proc = "";
LET cFech_Proc = DATE(1);
LET cCve_Proc = "";
LET cDescripcion = "";
LET cEstatus = "";
LET cFecha_hoy = DATE(1);
	   

    -- SET DEBUG FILE TO "/respaldosbd/hectorb/sp_tef_validarchcod60.out";
    -- TRACE ON;	   
	   


BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodret = sql_err;
			RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;
		END IF;
	END EXCEPTION;
	
	IF pTpo_Proc <> "" OR pCve_Proceso <> "" THEN
		IF pTpo_Proc <> "" AND pCve_Proceso <> "" THEN
			LET cCodret = "00001";
			RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;
		ELSE
			SELECT fecha_hoy
			INTO cFecha_hoy
			FROM bdicheq:"informix".sc_fechas;
			
			
			IF pTpo_Proc <> "" THEN
				FOREACH
					SELECT tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus
					INTO cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus
					FROM bditef:"informix".tef_procesos
					WHERE tipo_proceso = pTpo_Proc
					
					LET cCodret = "00003";	
					RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus WITH RESUME;
				END FOREACH
			ELIF pCve_Proceso <> "" THEN
				FOREACH
					SELECT tipo_proceso, fecha_proceso, cve_proceso, descripcion, estatus
					INTO cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus
					FROM bditef:"informix".tef_procesos
					WHERE  fecha_proceso = cFecha_hoy
					AND cve_proceso = pCve_Proceso
					
					LET cCodret = "00002";
					RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus WITH RESUME;
				END FOREACH

			END IF;
		END IF;	
	END IF;
	
     
	RETURN cCodret, cTpo_Proc, cFech_Proc, cCve_Proc, cDescripcion, cEstatus;

END;

END PROCEDURE
DOCUMENT
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION: Validar si incio o no la generación del Archivo Código 60',
'FECHA : 28/06/2012',
'BD    : bditef';

CREATE PROCEDURE "informix".sp_tef_validarecepcion(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret;

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodRet1				CHAR(6);
DEFINE vMensajeRet			VARCHAR(80);
DEFINE sBandera			    SMALLINT;
DEFINE cBanco 				CHAR(3);

---INICIALIZACIONES
LET iSqlErr					= 0;
LET iIsamErr				= 0;
LET cErrorInfo				= '';
LET cCodRet					= '000000';
LET cCodRet1				= '000000';
LET vMensajeRet				= 'PROCESO EXITOSO';
LET sBandera		    	= 0;
LET cBanco					= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(vMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/vlv/sp_tef_validarecepcion.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF (NVL(pCuenta,"") = "" OR NVL(ptipo,0) NOT IN (2,3)) THEN
		LET cCodRet = '000001';
		LET vMensajeRet = 'Parámetros inválidos';
    END IF;

    IF ptipo = 2 THEN --Tarjeta de débito	
			IF NOT EXISTS (SELECT banco	
							FROM bdinteg:"informix".si_bancos
							WHERE banco = (SELECT cve_banco	
							   			FROM bdicheq:"informix".sc_bines 
										WHERE bin = SUBSTR(pCuenta, 1,6) AND UPPER(creditodebito) = 'D')
 							AND flg_tef_r = '1') THEN
				LET sBandera=1;				
			END IF;	
	
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco 
		INTO cBanco 
		FROM bdinteg:"informix".si_bancos WHERE banco = SUBSTR(pCuenta,1,3)	AND flg_tef_r = '1';
		
		IF TRIM(NVL(cBanco, '')) = '' THEN		
			LET sBandera=1;
		ELIF TRIM(NVL(cBanco, '')) = '137' THEN
			LET sBandera=2;	
		END IF;	
		
	END IF;
	
	IF sBandera = 1 THEN	
		LET cCodRet = '000002';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","099")
									INTO cCodRet1,vMensajeRet;	
	ELIF sBandera = 2 THEN
		LET cCodRet = '000003';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","573")
									INTO cCodRet1,vMensajeRet;	
	END IF;			
    
	RETURN cCodRet, TRIM(vMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que valida que la cuenta sea valida para recepcion de operaciones TEF en central',
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'MODIFICO: Valentin Lopez Valenzuela.',
'DESCRIPCION: Se agrego una validación para no permitir realizar transferencia de envio de fondos a BANCOPPEL. (ptipo = 3) ',
'BASE DE DATOS: bditef',
'FECHA: Agosto 2012',
'VERSION: 20120809.1544';

create procedure "informix".stat_cheque (
                    pempresa    char(3),
                    pcuenta     char(20),
                    pnrocheque  integer)
       returning    char(5),    --codret
                    char(2);    --motdevol

    -- v1.0 validacion extra cuando el cheque no ha sido
    -- aplicado pero ya esta en la base de datos
    -- lalo jun10
                    
    -- v1.0 version inicial
    -- eduardo espinosa oct09
    -- devuelve el status de la cuenta/cheque

                    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vmotdevol    char(2);
    define vcuenta      char(20);
    define vstatuscta   char(1);
    define vmotivo      char(2);
    define vchequestat  char(1); 
    define vcargo       char(1);
    
    let vcodret     = "000";
    let vmotdevol   = "00";
    let vcargo      = "S";

    
    
--set debug file to "/pisa/liberoltp/pisa_ftes/cecoban/stat_cheque.txt";
--trace on;
        
begin
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vmotdevol;
        end if
    end exception;

    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null 
        or pnrocheque = "" or pnrocheque < 1 then
            let vcodret = "100";
            return vcodret,vmotdevol;
    end if



    -- MOTIVO 02 No tiene cuenta con nosotros el librador
    -- Valida que Exista la Cuenta de Cheques 
    -- o que si la cuenta esta cancelada (status_cta="2")
    
    select  cuenta, status_cta,motivo
    into    vcuenta, vstatuscta, vmotivo
    from    bdicheq:sc_maechq
    where   cuenta = pcuenta;
    
    
    if dbinfo("sqlca.sqlerrd2") = 0 or vstatuscta = "2" then
    
            let vmotdevol   = "02";
            return vcodret,vmotdevol;
            
    else
    
        -- cta bloqueada pero acepta cargos
        if  vstatuscta = "3" then
            select  cargo 
            into    vcargo
            from    bdicheq:sc_bloqueo
            where   codigo = vmotivo;

            if vcargo = "N" then
                let vmotdevol   = "09"; -- cta bloqueada
                return vcodret,vmotdevol;
            end if
        end if        


        
        -- cuenta bloqueada no hacer nada
        -- validar los status del cheque
        
        if vcargo = "S" then
        
            select  estado
            into    vchequestat
            from    bdicheq:sc_contch
            where   empresa = pempresa
            and     cuenta  = pcuenta
            and     numero  = pnrocheque;

            -- no encontro registros
            -- La numeración del cheque no corresponde 
            
            if dbinfo("sqlca.sqlerrd2") = 0 then 
                let vmotdevol   = "51";       
            end if

            -- activo (cheque para intentar cargarle)
            if vchequestat = "A" or vchequestat = "U" then
                -- cta OK  
            end if

            -- ya pagado
            if vchequestat = "P" or vchequestat = "M" then
                let vmotdevol   = "16";
            end if 
            
            -- presentado por camara
            if vchequestat = "N"  then
                let vmotdevol   = "18";
            end if             

            -- revocado
            if vchequestat = "R"  then
                let vmotdevol   = "08";
            end if                

            -- cancelado
            -- CHEQUE EXTRAVIADO
            if vchequestat = "C"  then
                let vmotdevol   = "52";
            end if 

            -- incompleto
            if vchequestat = "I"  then
                let vmotdevol   = "51";
            end if 

            -- destruido
            if vchequestat = "D"   then
                let vmotdevol   = "23";
            end if 
            
            -- bloqueado orden jud
            -- TENEMOS ORDEN JUDICIAL DE NO PAGAR
            if vchequestat = "J"  then
                let vmotdevol   = "07";
            end if 

            -- bloqueado autoridades
            if vchequestat = "B"  then
                let vmotdevol   = "09";
            end if 
            
            
            -- validacion extra 
            
            if exists (select c_cuenta from cce_propios_det
                        where c_cuenta = pcuenta 
                        and c_cheque = pnrocheque
				and status = '01') then
                        
                let vmotdevol   = "16";
            end if 
            
            

        end if --validar los status del cheque


                
    end if    --cuenta, sdo_actual
 

    return vcodret,vmotdevol;    
    
end

END PROCEDURE;
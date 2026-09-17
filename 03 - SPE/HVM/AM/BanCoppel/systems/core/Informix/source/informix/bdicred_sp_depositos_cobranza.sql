CREATE PROCEDURE "informix".sp_depositos_cobranza(pFecha DATE)

RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr           INTEGER;
DEFINE cCodRet           CHAR(5);
DEFINE cNum_Empleado  	 CHAR(8);
DEFINE dFecha_Deposito   DATE;
DEFINE cSucursal         CHAR(4);
DEFINE cProducto         CHAR(40);
DEFINE cNum_Cte          CHAR(20);
DEFINE cNum_Credito      CHAR(20);
DEFINE dMonto_Deposito   DECIMAL(18,2);
DEFINE dSaldo_Anterior   DECIMAL(18,2);
DEFINE dSaldo_Actual     DECIMAL(18,2);
DEFINE cEstatus_Cred_Ant CHAR(60);
DEFINE cEstatus_Cred_Act CHAR(60);
DEFINE cFolio_Suc        CHAR(16);
DEFINE cReversado        CHAR(1);
DEFINE cNombreArchivo    CHAR(50);
DEFINE cRuta             CHAR(100);
DEFINE cSql              CHAR(1000);
DEFINE dFecha_Encurso    DATE;
DEFINE cDia	   		     CHAR(2);
DEFINE cMes			     CHAR(2);
DEFINE cAnio		     CHAR(4);
DEFINE cFecha_Deposito   CHAR(10);
DEFINE iInfo             INTEGER;

--Inicializacion de Variables
LET iSqlErr           = 0;
LET cCodRet           = '00000';
LET cNum_Empleado     = '';
LET dFecha_Deposito   = DATE(1);
LET cSucursal         = '';
LET cProducto         = '';
LET cNum_Cte          = '';
LET cNum_Credito      = '';
LET dMonto_Deposito   = 0;
LET dSaldo_Anterior   = 0;
LET dSaldo_Actual     = 0;
LET cEstatus_Cred_Ant = '';
LET cEstatus_Cred_Act = '';
LET cFolio_Suc        = '';
LET cReversado        = '';
LET cNombreArchivo    = '';
LET cRuta             = '';
LET cSql              = '';
LET dFecha_Encurso    = DATE(1);
LET cDia              = '';
LET cMes              = '';
LET cAnio             = '';
LET cFecha_Deposito   = '';

--SET DEBUG FILE TO '/informix/sp_depositos_cobranza.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet; 
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	IF (pFecha IS NULL OR NVL (pFecha, '') = '') THEN
		LET cCodRet = '00001'; --Parametro vacio
	ELSE
		SELECT fecha_hoy 
		INTO dFecha_Encurso
		FROM bdicred:"informix".sd_fechas;

		IF pFecha = dFecha_Encurso THEN
			LET cMes  = SUBSTRING(pFecha FROM 1 FOR 2);
			LET cDia  = SUBSTRING(SUBSTRING(pFecha FROM 4 FOR 4) FROM 1 FOR 2);
			LET cAnio = SUBSTRING(pFecha FROM 7 FOR 10);		

			--IF cDia <> '01' THEN
				--LET cCodRet = '00003'; --Se intenta generar en dia Incorrecto
			--ELSE
				LET cNombreArchivo = 'Depositos_recibidos_personalcobranza' || cDia  || cMes || cAnio || '.txt';
				SELECT TRIM(valor)
				INTO cRuta
				FROM bdicred:"informix".sd_param
				WHERE cod_param = '089';

				IF NVL(cRuta, '' ) <> '' THEN
					LET pFecha = pFecha -1 UNITS MONTH; --aaaa/mm/dd 

					LET cSql   = 'rm -f ' || TRIM(cRuta) ||  TRIM(cNombreArchivo);
					SYSTEM cSql;

					FOREACH
						SELECT num_empleado, fecha_deposito, sucursal, producto, num_cte, num_credito, monto_deposito, saldo_anterior, saldo_actual, status_cred_actual
						INTO cNum_Empleado, dFecha_Deposito, cSucursal, cProducto, cNum_Cte, cNum_Credito, dMonto_Deposito, dSaldo_Anterior, dSaldo_Actual, cEstatus_Cred_Act
						FROM bdicred:"informix".sd_depositos_cobranza
						WHERE MONTH(fecha_deposito) = MONTH(pFecha)					

						LET cFecha_Deposito = dFecha_Deposito;
						LET cMes  = SUBSTRING(cFecha_Deposito FROM 1 FOR 2);
						LET cDia  = SUBSTRING(SUBSTRING(cFecha_Deposito FROM 4 FOR 4) FROM 1 FOR 2);
						LET cAnio = SUBSTRING(cFecha_Deposito FROM 7 FOR 10);		
						LET cFecha_Deposito = cDia||'-'||cMes ||'-'||cAnio;

						LET cSql = '';
						LET cSql = 'echo "' || NVL(cNum_Empleado, '') || '|' || NVL(cFecha_Deposito, '') || '|' || NVL(cSucursal, '')  || '|' || NVL(TRIM(cProducto), '') || '|' || NVL(TRIM(cNum_Cte), '') || '|' || NVL(TRIM(cNum_Credito), '') || '|' || NVL(dMonto_Deposito, 0) || '|' || NVL(dSaldo_Anterior, 0) || '|' || NVL(dSaldo_Actual, 0) || '|' || NVL(TRIM(cEstatus_Cred_Act), '') || '" >> ' || TRIM(cRuta) || TRIM(cNombreArchivo);
						SYSTEM cSql;
					END FOREACH;

					LET iInfo = DBINFO("sqlca.sqlerrd2"); 
					IF (iInfo = 0) THEN
						LET cCodRet = '00005'; --No hay informacion en la tabla
					END IF;
				ELSE
					LET cCodRet = '00004';				END IF;	
			--END IF;
		ELSE 
			LET cCodRet = '00002';		END IF;
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1580',
'AUTOR : 95594213',
'FECHA : 27/01/2014',
'MODIFICACIÓN: Se crea sp_depósitos_cobranza para generar archivo .txt ',
'SUSTENTO: RQM_09-338_Depósito_personal_cobranzav3.1.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_inversa_moras()

RETURNING CHAR(6);


--Declaracion de variables
DEFINE vi_cod_ref          INTEGER;
DEFINE vc_status_cred      CHAR(2);
DEFINE vc_sucursal       char(4);
DEFINE vc_odRetAux      char(6);
define vc_MensajeRet    char (80);


DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE vproceso				CHAR(4);
DEFINE dFechaHoy            DATE;
DEFINE dFechaPrim           DATE;
DEFINE dFechaUlt            DATE;
DEFINE dFechaPrev           DATE;
DEFINE dFechaProx           DATE;
DEFINE dFechaAux            DATE;
DEFINE cRCodRet             CHAR(6);
DEFINE cRMens_Ret           CHAR(80);
DEFINE pempresa             CHAR(3);
DEFINE vfecha_mov 			DATE;
DEFINE vnum_credito			CHAR(20);
DEFINE vmonto 				MONEY;
DEFINE vfolio_suc			CHAR(30);

DEFINE Vserial	integer;

define  v_Cod_Ret 			CHAR(5);
define 	v_mensaje_Retorno 	CHAR(80);
define  v_Num_Credito 		CHAR(20);
define 	v_Cuenta_eje 		CHAR(20);
define 	v_Producto 			CHAR(40);
define 	v_Num_Cliente 		CHAR(20);
define 	v_Nom_Cliente 		CHAR(150);
define 	v_Pago_Efectivo 	DECIMAL(18,2);
define 	v_Pago_Cuenta 		DECIMAL(18,2);
define 	v_Monto_Operacion 	DECIMAL(18,2);
define 	v_Saldo_Actual 		DECIMAL(18,2);
define		sqlUnload		char(2000);


--sET DEBUG FILE TO "/tmp/sp_inversa_moras.out";
--tRACE ON;

--Inicialización de variables
LET vi_cod_ref      =0;
LET vc_status_cred  ="";
let vc_sucursal     ="";
let vc_odRetAux     ="";
let vc_MensajeRet   ="";
let dFechaHoy       =DATE(1);



LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '9999';
LET pempresa                = '001';
LET vfecha_mov 			=DATE(1);
LET vnum_credito		="";
LET vmonto 				=0;
LET vfolio_suc			="";
let sqlUnload ="";

LET v_Cod_Ret ="";
LET	v_mensaje_Retorno ="";
LET v_Num_Credito ="";
LET v_Cuenta_eje ="";
LET v_Producto ="";
LET v_Num_Cliente ="";
LET v_Nom_Cliente ="";
LET v_Pago_Efectivo =0;
LET v_Pago_Cuenta =0;
LET v_Monto_Operacion =0;
LET v_Saldo_Actual =0;
let Vserial = 0;
let cRMens_Ret= "";
let cRCodRet = '00000';


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;        
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


        FOREACH WITH HOLD
		  SELECT fecha_mov, num_credito, monto, folio_suc, cod_ref, status, sucursal
            into vfecha_mov, vnum_credito,vmonto, vfolio_suc, vi_cod_ref, vc_status_cred, vc_sucursal
		    FROM bdicred:"informix".sd_ajuste_pagos
			WHERE procesado='F'
			  

             IF vi_cod_ref = 2 THEN 
                LET vi_cod_ref = 50; --FMV 4-JUN-14  DEVOLUCION DE INTERES DE MORAS
             END IF;
             IF vi_cod_ref = 3 THEN 
                LET vi_cod_ref = 51; --FMV 4-JUN-14  DEVOLUCION DE IVA DE MORAS
             END IF;

            CALL "informix".genmovcrd('001',
                                      vnum_credito, 
                                     '6300' ,
                                      vi_cod_ref,
				                      "023",  -- FMV codigo_fun de prestamo personal
                                      today ,
                                      vmonto,
                                      vfolio_suc,
									  vc_sucursal, 
                                      '001', 
                                      "0000",'','')
                    RETURNING vc_odRetAux,vc_MensajeRet;

			
			IF vc_odRetAux = '00000' THEN
			  BEGIN WORK;
				UPDATE bdicred:"informix".sd_ajuste_pagos
				  SET procesado='V'
				WHERE num_credito = vnum_credito
				  AND cod_ref = vi_cod_ref; 
			   COMMIT work;
			ELSE
              CONTINUE FOREACH;
			
		        
			END IF;
		END FOREACH;
    
	RETURN cCod_ret;
END;
END PROCEDURE;
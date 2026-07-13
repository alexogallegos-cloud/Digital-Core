CREATE PROCEDURE "informix".sp_abona_cheques()

RETURNING CHAR(6);


--Declaracion de variables
DEFINE vi_cod_ref          INTEGER;
DEFINE vc_status_cred      CHAR(2);
DEFINE vc_sucursal       char(4);
DEFINE vc_odRetAux      char(5);
define vc_MensajeRet    char (80);
define vc_cuenta_cap  CHAR(20);
DEFINE vc_cod_ref CHAR(10);

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
DEFINE vfolio_suc2			CHAR(30);

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
define		vBContinua		CHAR(1);
define		sqlUnload		char(2000);


--sET DEBUG FILE TO "/tmp/sp_abona_cheques.out";
--tRACE ON;

--Inicialización de variables
LET vi_cod_ref          =0;
LET vc_status_cred     ="";
let vc_sucursal         ="";
let vc_odRetAux     ="";
let vc_MensajeRet   ="";
let vc_cuenta_cap  ="";
LET vc_cod_ref ="";
let dFechaHoy       = mdy('06','03','2014');

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
LET vfolio_suc2	="";
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
        --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cRCodRet;
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
           


                 SELECT num_cta
                   INTO vc_cuenta_cap
                  FROM bdicred:"informix".sd_ctascarg
                  WHERE NUM_CREDITO = vnum_credito;

             IF vi_cod_ref = 2 THEN 
                LET vc_cod_ref = 'Interes';
             END IF;
             IF vi_cod_ref = 3 THEN 
                LET vc_cod_ref = 'IVA Mora';
             END IF;

              CALL bdicheq:abono_ref ('001', vc_sucursal, 'informix', '0242', '0000', vfolio_suc, vc_cuenta_cap, 0, vmonto, vmonto, 0, 0, 0, '01', 'Devolucion Moratorios '||LPAD(TRIM(vc_cod_ref),12,'0'), '', 'cobroapp')
              RETURNING vc_odRetAux;

			let vfolio_suc2 = '';
			IF vc_odRetAux = '00000' THEN
			   begiN work;
				Update bdicred:"informix".sd_ajuste_pagos
				  set procesado='V'
				where --secuencia = vserial
                               fecha_mov = dFechaHoy
				  and num_credito =  vnum_credito; --and monto = vmonto
--			      and folio_suc= vfolio_suc;
			   COMMIT work;
			ELSE
 
                        CONTINUE FOREACH;
			   LET vBContinua = 'F';
		          --end if;
			END IF;
		END FOREACH;

        

 
	RETURN cCod_ret;

END;
END PROCEDURE;
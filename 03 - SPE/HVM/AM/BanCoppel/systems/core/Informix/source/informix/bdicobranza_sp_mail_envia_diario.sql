create procedure "informix".sp_mail_envia_diario()

returning VARCHAR(6);

define pempresa char (3);
DEFINE cProceso  char(4);
DEFINE cCod_ret  smallint;
DEFINE cMensaje  char (100);
DEFINE vfecha	date;
define pparam	smallint;


DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);

LET SQL_ERR       	    =0;
LET ISAM_ERR      	    =0;
LET ERROR_INFO			='';
LET P_COD_RET			='';
LET P_MENSAJE			='';

let vfecha				= date(1);
let pparam				= 0;
  

BEGIN

    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
            RETURNING P_COD_RET;
        RETURN P_COD_RET;
    END exception;
	
-- SET DEBUG FILE TO "inserta_mensaje.out";
-- TRACE ON;
  let pempresa = '001';
  let P_COD_RET = '111111';
  let cCod_ret = '';
  let cMensaje = '';
  let cProceso = '2031';
  
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
    RETURNING P_COD_RET;
	
	select fecha_hoy into vfecha from bdicred:sd_fechas; 
--let vfecha = mdy('08','17','2014');

	select valor_numerico into pparam from cb_param_campania 
	where tipo_campania = 1 and grupo_parametro = 'EMAIL' and num_parametro = 2 ;
	
--	call bdicobranza:"informix".sp_mail_compsinadeudo('001',today) RETURNING P_COD_RET;
	call bdicobranza:"informix".sp_mail_compsinadeudo('001',today) RETURNING P_COD_RET, P_MENSAJE;	let P_COD_RET = '000000'; 
--	call bdicobranza:"informix".sp_mail_compconadeudo('001',today) RETURNING P_COD_RET;
	call bdicobranza:"informix".sp_mail_compconadeudo('001',today) RETURNING P_COD_RET, P_MENSAJE;	let P_COD_RET = '000000'; 
--	call bdicobranza:"informix".sp_mail_compfracionado('001',today) RETURNING P_COD_RET;
	call bdicobranza:"informix".sp_mail_compfracionado('001',today) RETURNING P_COD_RET, P_MENSAJE;	let P_COD_RET = '000000'; 
--	call bdicobranza:"informix".sp_mail_compsincumplir('001',today) RETURNING P_COD_RET;
	call bdicobranza:"informix".sp_mail_compsincumplir('001',today) RETURNING P_COD_RET, P_MENSAJE;	let P_COD_RET = '000000'; 
--	call bdicobranza:"informix".sp_mail_prestamopmora('001') RETURNING P_COD_RET;
--	call bdicobranza:"informix".sp_mail_prestamopmora('001') RETURNING P_COD_RET, P_MENSAJE;--se saca de este sp
	let P_COD_RET = '000000';
    call bdicobranza:"informix".sp_mail_prestamopautorizacion('001',2)RETURNING P_COD_RET, P_MENSAJE;	let P_COD_RET = '000000';
	call bdicobranza:"informix".sp_sms_reestructura_aper()RETURNING P_COD_RET, P_MENSAJE;	let P_COD_RET = '000000';	
    if weekday(today) = 2 then
        call bdicobranza:"informix".sp_mail_prestamoppreventiva('001',7) RETURNING P_COD_RET, P_MENSAJE;
--        call bdicobranza:"informix".sp_mail_prestamoppreventiva('001',7) RETURNING P_COD_RET;
        let P_COD_RET = '000000';
	end if;
	if (day(vfecha) = pparam) then 
    	call bdicobranza:"informix".sp_sms_pagominimotc() RETURNING P_COD_RET, P_MENSAJE;
--    	call bdicobranza:"informix".sp_sms_pagominimotc() RETURNING P_COD_RET;
        let P_COD_RET = '000000';	
    end if;
	call bdicred:"informix".sp_rep_estadisticas_tdc_latinia() RETURNING P_COD_RET, P_MENSAJE;
	if (day(vfecha) = 23) then 
    	call bdicred:"informix".sp_cat_aumlincred_latinia() RETURNING P_COD_RET;
	end if;
	
	------DEMOGRAFICA
	CALL bdicobranza:"informix".sp_catpromo_prestamo_aut()RETURNING P_COD_RET;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
end
RETURN P_COD_RET;
END PROCEDURE;
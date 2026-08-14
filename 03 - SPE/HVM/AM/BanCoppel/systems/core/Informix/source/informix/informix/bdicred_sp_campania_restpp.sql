CREATE PROCEDURE "informix".sp_campania_restpp()
-- execute procedure "informix".sp_campania_restpp();
returning 
char (06),
VARCHAR(80);

------------------------------------------------------------------------------------
--David Ulises Cuenca Montesinos
--2020-09-30
--INVITACION REESTRUCTURA PRESTAMO PERSONAL 

----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte			char(20);
define vnumcredito		char(20);
define vnumtarjeta		char(20);
define vimporte			decimal(18,2);
define vFechaHoyR		date;
define vvalor_numerico	integer;

---DECLARACIONES
DEFINE cNumCta			CHAR(20);
DEFINE dCapMtoCuota		DECIMAL(18,2);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cCel				CHAR(13);
DEFINE cEstado			CHAR(2);
DEFINE cCiudad			CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE cNumCarrier		CHAR(3);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cNomEstado 		CHAR(20);
DEFINE cNomCiudad 		CHAR(20);
DEFINE iPagoVenc 		INTEGER;
DEFINE vSdoTotal1  		DECIMAL(18,2);
DEFINE vMtoVencido1  	DECIMAL(18,2);
DEFINE vMensualidad 	DECIMAL(18,2);
DEFINE vSdoTotal2   	DECIMAL(18,2);
DEFINE vMtoVencido2 	DECIMAL(18,2);
DEFINE vsaldo_total 	DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
DEFINE vpago 			DECIMAL(18,2);
DEFINE Vfecha_apertura 	DATE;
DEFINE iCel 			SMALLINT;
DEFINE vdia_pago 		smallint;
DEFINE vpago_minimo  	DECIMAL(18,2);
DEFINE vpago_vencido 	DECIMAL(18,2);

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE COD_RET					VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE vproceso					CHAR (4);
DEFINE cMensaje					CHAR(80);
define vcontador				INTEGER;
--define vcount				  integer;
define iCount_INV_RPP			integer; --A.L.L.
define vvalor					smallint;
define i						integer;
define num						smallint;
define cNumProducto				char(04);
define iCuentasProcesadas		INTEGER;
define iCuentasExcluidasXCel	INTEGER;
define iCuentasSinPagoMin		INTEGER;
DEFINE p_fecha_antiguedad		date;
DEFINE pagos_realizados			INTEGER;

---INICIALIZACIONES
LET cNumCta				= '';
LET dCapMtoCuota		= 0;
LET	cDiasAnticipados	= 0;
LET cCel				= '';
LET cEstado				= '';
LET cCiudad				= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cTipoRed			= '';
LET cCodRet2			= '';
LET cNumCarrier			= '';
LET cSituacion			= '';
LET iCausa				= 0;
LET cNomEstado 			= '';
LET cNomCiudad 			= '';
LET iPagoVenc 			= 0;
LET vSdoTotal1 			= 0;
LET vMtoVencido1		= 0;
LET vMensualidad 		= 0;
LET vSdoTotal2 			= 0;
LET vMtoVencido2 		= 0;
LET vsaldo_total 		= 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo 	= 0;
LET vpago_minimo_total 	= 0;
let vpago 				= 0;
LET iCel 				= 0;
LET vdia_pago 			= 0;
let vpago_minimo 		= 0;

let vnumcte 			= '';
let vnumcredito 		= '';
let vnumtarjeta 		= '';
let vimporte			=0;
let vFechaHoyR			= '';

let SQL_ERR				= 0;
let ISAM_ERR			= 0;
let ERROR_INFO			= '';
let P_COD_RET			= '000000';
let COD_RET				= '000000';
let P_MENSAJE  			= 'El proceso de INV_RPP termino correctamente.';
let vproceso			= '0114';
let cMensaje			= '';
let vpago_vencido 		= 0;
let vvalor_numerico		= 0;
LET vcontador 			= 0;
--let vcount 		= 0;
let iCount_INV_RPP 		= 0;
let i 					= 0;
let num 				= 0;
let cNumProducto 		= '';
let iCuentasProcesadas  = 0;
let iCuentasExcluidasXCel = 0;
let iCuentasSinPagoMin 	= 0;
LET p_fecha_antiguedad 	= date(1);
LET pagos_realizados 	= 0;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = 'Error al ejecutar el proceso.';
		CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, cMensaje, '02') RETURNING COD_RET;	
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;


  --Set debug file to 'sp_sms_pagominimotc.out';
  --trace on;
    CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	--LET p_fecha_antiguedad =  ADD_MONTHS (today, -6);
	--Se obtiene fecha hoy para calular seis meses atras
	SELECT fecha_hoy - 6 units month INTO vFechaHoyR from sd_fechas where empresa = '001';
	
	
	--se envia mail y sms
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
	
    set isolation to dirty read;

	FOREACH WITH HOLD
	
		SELECT a.numcte, a.num_credito,a.num_producto
			INTO vnumcte, vnumcredito, cNumProducto
			FROM bdicred:sd_maecredcrd a
		INNER JOIN bdicred:sd_maesdoscrd b ON b.num_credito = a.num_credito AND (b.mto_fin_ven_trasp BETWEEN 3 AND 7) AND b.sdo_cap_insoluto >= 2000  
		WHERE a.fecha_apertura <= vFechaHoyR
			
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
		-- Se obtiene total de pagos realizados
		select count(*) INTO pagos_realizados from sd_amortiza_creditocrd 
		where empresa = '001' and num_credito = vnumcredito and capital_status = 5;
		
		if (pagos_realizados >=4) then
		
		SELECT limit 1 d.telefono
		    INTO cCel
			FROM bdinteg:"informix".si_telefonos_actual d
			WHERE d.numcte = vnumcte
		    AND d.tipo_tel = '2' and status_tel = 'A' and d.cofetel ='V';
			
			LET iCount_INV_RPP = iCount_INV_RPP + 1;
			
			IF cCel IS NULL OR cCel = '' THEN 
               LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
               CONTINUE foreach; 
			   
            END IF;
		
			call bdimnsj:"informix".sp_registra_evento (2, 'INV_RPP' , vnumcte, vnumcredito,vnumtarjeta, 2,
                                    '','','','','','',0,0,0,0, '', '') RETURNING COD_RET;
			--call "informix".sp_inserta_info_rep_envios ('001','SMS',18, vnumcredito, vnumcte, cNumProducto, today, cCel, '','','') returning P_COD_RET;
                        LET vcontador = vcontador + 1 ;
			
		end if;
	END FOREACH;
	
/*	if (vcontador >= 1) then 
		LET i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
			insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
			select  2, 'INV_RPP',numcte,current,apell_paterno,100
			from bdinteg:si_cliente
			where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
		end for
	end if;
	
	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('INV_RPP',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING COD_RET;*/
	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaÃÂ±as INV_RPP : ' || iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados : ' || iCount_INV_RPP;
       CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING COD_RET;
    end if;

	CALL bdicred:"informix".sp_inserta_bitacora('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

    RETURN P_COD_RET,P_MENSAJE;

end;
end procedure;
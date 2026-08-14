CREATE PROCEDURE "informix".sp_mail_reestructu_mora(pempresa char (3), pfechacorte date)
returning --VARCHAR(6);
CHAR(06)  AS codigo_retorno,
CHAR(80)  AS mensaje_retorno;

 
DEFINE pnumcredito   char(20);
DEFINE pnumcte       char(20);
DEFINE pmail         char (60);
DEFINE pmesvencido   smallint;
DEFINE pfechahoy     datetime year to second;
DEFINE pmtofin       DECIMAL(18,2);
define fa            date;  
define vnumtarjeta	 char(20);
define pparam        smallint;
 
DEFINE cProceso             char(4);
DEFINE cCod_ret             CHAR(6);
DEFINE cMensaje             char (150);
DEFINE SQL_ERR              INTEGER;
DEFINE ISAM_ERR             INTEGER; 
DEFINE ERROR_INFO           VARCHAR(80);
DEFINE P_COD_RET            VARCHAR(6);
DEFINE P_MENSAJE            VARCHAR(80);
DEFINE vsaldo_total         DECIMAL(18,2); 
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_vencido        DECIMAL(18,2);
define vapell_paterno       char(30);
--define vcount			integer;
define iCount_REST_MORA1    integer; --A.L.L.
define iCount_REST_MORA2    integer; --A.L.L.
define vvalor               smallint;
define i                    integer;
define num                  smallint;
DEFINE iCuentasProcesadas   integer;
DEFINE iCuentasExcluidasXMail integer;
DEFINE iCuentasExcluidasXMail_REST_MORA1 integer;
DEFINE iCuentasExcluidasXMail_REST_MORA2 integer;
DEFINE sCampana			smallint; --ALL
DEFINE iCuentasProcesadas_REST_MORA1  INTEGER;
DEFINE iCuentasProcesadas_REST_MORA2  INTEGER;
  
let pnumcte             = '';
let pnumcredito         = '';
let pmail               = '';
LET vnumtarjeta         = '';
let pfechahoy           = DATE(1);
let pmesvencido         = 0;
let pmtofin             = 0;
let fa                  = DATE(1);  
let vsaldo_total        = 0;
let v_sdo_venc_int_mora = 0;
let vpago_minimo_total  = 0;
let v_pago_min_sin_vdo  = 0;
let vpago_vencido       = 0;
--  let P_COD_RET = '111111';
let P_COD_RET           = "000000";
let P_MENSAJE           = 'El proceso de la campaña EMAIL MORAS REESTRUCTURAS se realizó correctamente.';
let cCod_ret            = '000000';
let cMensaje            = '';
--let P_MENSAJE           = '';
let cproceso            = '8001';
let SQL_ERR             = 0;
let ISAM_ERR            = 0;
let ERROR_INFO          = '';
let pparam              = 0;
let vapell_paterno      = '';
--  let vcount = 0;
let iCount_REST_MORA1   = 0; --A.L.L.
let iCount_REST_MORA2   = 0; --A.L.L.
let i   = 0;
LET num = 0;
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXMail_REST_MORA1 = 0;
let iCuentasExcluidasXMail_REST_MORA2 = 0;
let sCampana		  = 0; --ALL
let iCuentasProcesadas_REST_MORA1 = 0;
let iCuentasProcesadas_REST_MORA2 = 0;

BEGIN
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '02') RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        RETURN P_COD_RET,P_MENSAJE;
--        RETURN P_COD_RET;
    END exception;
--SET DEBUG FILE TO "sp_mail_reestructu_mora.out";
--TRACE ON;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso , cCod_ret, cMensaje, '01') RETURNING P_COD_RET;

     if P_COD_RET != '000000' then
--        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	Select Fecha_Hoy
		Into pfechahoy
	From bdicred:sd_fechas
	Where empresa = pempresa ;

/*	SELECT valor_numerico into pparam
	FROM cb_param_campania
	WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;*/
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

/*if (pparam = 0) then
	if (ppagosvencidos = 0) then
		delete from bdicobranza:cb_mail_cliente where empresa = pempresa and fecha_insert = pfechahoy and tipo_mensaje = 4 and pagos_vencidos > 0;
	end if;
	if (ppagosvencidos > 0) then
		delete from bdicobranza:cb_mail_cliente where empresa = pempresa and  fecha_insert = pfechahoy and tipo_mensaje = 4 and pagos_vencidos = ppagosvencidos;
	end if;
end if;*/
 
    --valida parametros
    IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
  
        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
 
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '02') RETURNING P_COD_RET;
        LET P_COD_RET = cCod_Ret;
        LET P_MENSAJE = cMensaje;
        RETURN P_COD_RET,P_MENSAJE;
    END IF;
/*
    IF NVL (ppagosvencidos, '') = '' THEN
        LET cCod_Ret= '101010';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

         CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        LET P_COD_RET = cCod_Ret;
        LET P_MENSAJE = cMensaje;
        RETURN P_COD_RET,P_MENSAJE;
    END IF;*/
--let   pfechacorte = '06-18-2010';--'05-18-2012';	
	set isolation to dirty read;
	
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
--	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,fecha1,fecha2)
		select  1, 'REST_MORA1',numcte,current,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
--	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,fecha1,fecha2)
		select  1, 'REST_MORA2',numcte,current,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
		let num = num + 10;
	end for
		
	foreach
/*		SELECT  a.num_credito, a.numcte, d.mto_fin_ven_trasp,d.monto_financiado, max(c.fecha_cuota)--,a.fecha_apertura
		INTO  pnumcredito, pnumcte, pmesvencido,pmtofin, fa
		FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd d, bdicred:sd_amortiza_creditocrd C 	
		WHERE d.empresa = a.empresa
            and d.num_credito = a.num_credito
            AND c.empresa = a.empresa
            and c.num_credito = a.num_credito
            AND a.status_cred in ('BT','VP','BA')
            and (( d.mto_fin_ven_trasp = ppagosvencidos) or  ( 0= ppagosvencidos ) )
			and d.mto_fin_ven_trasp between 1 and 2			
            and c.capital_status in (2,7,3)
			and c.fecha_cuota + 1 units day = date(pfechacorte)
			and a.num_producto = '6011'
			and a.campo_trab3 <> 'BAJA'
        group by a.num_credito, a.numcte, d.mto_fin_ven_trasp,d.monto_financiado*/

		SELECT  a.num_credito, a.numcte, b.mto_fin_ven_trasp
		INTO  pnumcredito, pnumcte, pmesvencido
		FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
		WHERE a.empresa = pempresa
            and a.num_credito >= ''
            AND b.empresa = a.empresa
            and b.num_credito = a.num_credito
            AND c.empresa = a.empresa
            and c.num_credito = a.num_credito
            AND a.status_cred in ('BT','VP','BA','E1','E2','E3') 
			AND (b.monto_vencido + b.mto_venc_trasp) > 0
			and b.mto_fin_ven_trasp in (1,2)
			and a.num_producto = '6011'
			and a.campo_trab3 <> 'BAJA'
            and c.dia_corte = day(pfechacorte)

/*		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;
*/		
        let iCuentasProcesadas = iCuentasProcesadas + 1;
        let pmail = '';
		select limit 1 cte.correo_elec into pmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
							and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
		where empresa  = '001' and numcte = pnumcte and status_correo ='A');	
		
/*        if pmail is null or pmail = '' then 
            let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
            CONTINUE foreach;
        end if;*/

/*		select 	(car.sdo_cap_insoluto + car.sdo_intereses + car.interes_iva + car.moratorio ),
			 (car.monto_vencido + car.mto_venc_trasp + car.moratorio + car.interes_iva) ,
			 (car.monto_financiado + car.interes_iva + car.moratorio), car.monto_financiado, 
			 car.monto_vencido + car.mto_venc_trasp
			 into  vsaldo_total, v_sdo_venc_int_mora,vpago_minimo_total,
				v_pago_min_sin_vdo,vpago_vencido 
			 from  bdicred:"informix".sd_sdos_cartera_linea car
			 where car.num_credito = pnumcredito;*/
		
		let vnumtarjeta = '';

--    if (pmail <> '') then   
/*		if (pparam = 0) then
            call "informix".sp_mail_inserta_cliente (pempresa,4,pnumcte,pnumcredito, pmail,pmtofin,0,pmesvencido,0,null,null,null,
                                                    0,0,vpago_vencido,v_pago_min_sin_vdo,v_sdo_venc_int_mora)
              RETURNING P_COD_RET; 
		end if;*/
		
		if (pmesvencido = 1)then
            let iCuentasProcesadas_REST_MORA1 = iCuentasProcesadas_REST_MORA1 + 1;

            if pmail is null or pmail = '' then 
                let iCuentasExcluidasXMail_REST_MORA1 = iCuentasExcluidasXMail_REST_MORA1 + 1;
                CONTINUE foreach;
            end if;
		--A.L.L.
            LET iCount_REST_MORA1 = iCount_REST_MORA1 +1;
			let sCampana = 1013;
            call bdimnsj:"informix".sp_registra_evento (1, 'REST_MORA1' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',0,0,0,0,0, today, '') RETURNING P_COD_RET; 
--							vapell_paterno,'','','','',0,0,0,0,0, today, '')RETURNING P_COD_RET;
		end if;
		
		if (pmesvencido = 2)then
            let iCuentasProcesadas_REST_MORA2 = iCuentasProcesadas_REST_MORA2 + 1;

            if pmail is null or pmail = '' then 
                let iCuentasExcluidasXMail_REST_MORA2 = iCuentasExcluidasXMail_REST_MORA2 + 1;
                CONTINUE foreach;
            end if;
		--A.L.L.
            LET iCount_REST_MORA2 = iCount_REST_MORA2 +1;
			let sCampana = 1014;
            call bdimnsj:"informix".sp_registra_evento (1, 'REST_MORA2' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',0,0,0,0,0, today, '') RETURNING P_COD_RET;        
--							vapell_paterno,'','','','',0,0,0,0,0, today, '')RETURNING P_COD_RET; 
		end if;
		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',sCampana, pnumcredito, pnumcte, '6011', today,pmail, '','','') returning P_COD_RET;
		let sCampana = 0;
--	end if;	
    end foreach

	--A.L.L.
--	IF iCount_REST_MORA1 > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MORA1',iCount_REST_MORA1,iCuentasExcluidasXMail_REST_MORA1) RETURNING P_COD_RET;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MORA1',iCuentasProcesadas_REST_MORA1,iCuentasExcluidasXMail_REST_MORA1) RETURNING P_COD_RET;
--	END IF;
	--A.L.L.
--	IF iCount_REST_MORA2 > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MORA2',iCount_REST_MORA2,iCuentasExcluidasXMail_REST_MORA2) RETURNING P_COD_RET;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MORA2',iCuentasProcesadas_REST_MORA2,iCuentasExcluidasXMail_REST_MORA2) RETURNING P_COD_RET;
--	END IF;

--Genera cifras de control
    if iCuentasProcesadas > 0 or iCuentasExcluidasXMail > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña REST_MORA1 y 2 : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA 1: ' ||iCount_REST_MORA1;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'EMAILs enviados MORA 2: ' ||iCount_REST_MORA2;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail_REST_MORA1 + iCuentasExcluidasXMail_REST_MORA2;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;

--       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
--       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control


  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '03')
   RETURNING P_COD_RET;

     if P_COD_RET != '000000' then
--        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.

end
--  RETURN P_COD_RET;
END PROCEDURE;
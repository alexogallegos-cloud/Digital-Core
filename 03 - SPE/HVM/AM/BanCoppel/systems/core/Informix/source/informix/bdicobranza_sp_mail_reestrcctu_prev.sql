CREATE PROCEDURE "informix".sp_mail_reestrcctu_prev(pempresa char (3), pfechacorte date )
returning 
VARCHAR(6),
VARCHAR(80);

DEFINE vnumcte       char (20);
DEFINE vnumcredito   char(20);
DEFINE vmail         char (60);
DEFINE vfechapago DATE;
DEFINE vnumtarjeta	 CHAR(20);
DEFINE pfechahoy     DATE;
 
DEFINE cProceso  char(4);
DEFINE cCod_ret  CHAR(6);
DEFINE cMensaje  char (100);
DEFINE P_MENSAJE          VARCHAR(80);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE COD_RET          VARCHAR(6);
define pparam smallint;
DEFINE vpago_minimo_total decimal (18,2);
DEFINE vsaldo_total decimal (18,2);
DEFINE vpago_vencido decimal (18,2);
DEFINE v_pago_min_sin_vdo decimal (18,2);
DEFINE v_sdo_venc_int_mora decimal (18,2);
define vapell_paterno char(30);
--define vcount integer;
define iCount_REST_PREV integer;
define vvalor smallint;
define i integer;
define num smallint;
define vvcCod_ret CHAR(6);
DEFINE iCuentasProcesadas   integer;
DEFINE iCuentasExcluidasXMail integer;

let vnumcte       = '';
let vnumcredito   = '';
let vmail         = '';
let vfechapago =DATE(1);
LET vnumtarjeta	  = '';
let pfechahoy  =DATE(1);
let vpago_minimo_total 	=0;
let vsaldo_total		=0;
let vpago_vencido 		=0;
let v_pago_min_sin_vdo 	=0;
let v_sdo_venc_int_mora =0;
let vapell_paterno = '';
  let P_COD_RET = '000000';
  let COD_RET = '000000';
  let cCod_ret = '000000';
  let cMensaje = '';
  let P_MENSAJE  = 'El proceso de la campaña REST_PREV se realizó correctamente.';
  let cproceso = '8000';
  let SQL_ERR   =0;
  let ISAM_ERR  =0;
  let ERROR_INFO  = '';
  let pparam =0;
--  let vcount = 0;
  LET iCount_REST_PREV = 0;
  LET i = 0;
  LET num = 0;
  LET vvcCod_ret = '';
  LET iCuentasProcesadas      = 0;
  LET iCuentasExcluidasXMail  = 0;
 
BEGIN
     ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = 'Error al ejecutar el proceso.';
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '02') RETURNING COD_RET;
        RETURN P_COD_RET,P_MENSAJE;
    END exception;
		
--SET DEBUG FILE TO "/respaldos/Ricardo/campanas/sp_mail_reestrcctu_prev.out";
--TRACE ON;

	Select Fecha_Hoy
    Into pfechahoy
	From bdicred:sd_fechas
	Where empresa = pempresa ;

	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;
	    
	--if (pparam = 0) then
    --delete from bdicobranza:cb_mail_cliente where empresa = pempresa and fecha_insert = pfechahoy and tipo_mensaje = 4 and pagos_vencidos = 0;
	--end if;
	
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso , cCod_ret, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

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
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01') RETURNING COD_RET;
        Return cCod_Ret,cMensaje;
    END IF;
 
-- Se valida día de ejecución para que calcule las fechas de próximo pago de las Reestructuras y se genere información
	if ((day(pfechacorte) >= 27 and day(pfechacorte) <= 31)) then
		let pfechacorte = pfechacorte + 1 units month;
		let pfechacorte = mdy(MONTH(pfechacorte),2,year(pfechacorte));
    elif (day(pfechacorte) >= 1 and day(pfechacorte) <= 2) then
		let pfechacorte = mdy(MONTH(pfechacorte),2,year(pfechacorte));
	elif (day(pfechacorte) >= 14 and day(pfechacorte) <= 17) then
		let pfechacorte = mdy(MONTH(pfechacorte),17,year(pfechacorte));
    else
        let P_COD_RET = '999999';
        let P_MENSAJE = 'Los días de ejecución de esta opción son los días 14 y 27 de cada mes.';
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')  RETURNING vvcCod_ret;   
        RETURN P_COD_RET,P_MENSAJE;
	end if
-- Se valida día de ejecución para que calcule las fechas de próximo pago de las Reestructuras y se genere información

    select length(valor) into vvalor
	  from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
	
	set isolation to dirty read;
		
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
          insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
          select  1, 'REST_PREV',numcte,1,current,apell_paterno,0,current,current
          from bdinteg:si_cliente
          where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
				
		let num = num + 10;
	end for

		foreach
	 		SELECT d.numcte, d.num_credito, b.prox_fecha_pago
				INTO vnumcte, vnumcredito, vfechapago
			FROM bdicred:sd_maecredcrd d, bdicred:sd_maesdoscrd a, bdicred:sd_maecredanexocrd b
			WHERE	d.empresa = a.empresa
				AND d.num_credito = a.num_credito
				and d.empresa = b.empresa
				and d.num_credito = b.num_credito
				and d.num_producto = '6011'
                AND d.status_cred IN ('AA','E1')
				AND (a.monto_vencido + a.mto_venc_trasp) = 0
                AND a.mto_fin_ven_trasp = 0
				AND d.campo_trab3 <> 'BAJA'
				and b.prox_fecha_pago = pfechacorte 
				
			let iCuentasProcesadas = iCuentasProcesadas + 1;

/*			select  apell_paterno into vapell_paterno
			from bdinteg:si_cliente where empresa = '001' and numcte = vnumcte ;*/
			
			select limit 1 cte.correo_elec into vmail 
			from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = vnumcte and cte.status_correo ='A'
			and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = vnumcte and status_correo ='A');

			if vmail is null or vmail = '' then 
				let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
				CONTINUE foreach;
			end if;
				
			let vnumtarjeta = '';
				
			--CALCULO DE PAGO_MIN_SIN_VDO--MENSUALIDAD
/*				SELECT ((nvl(capital_debe,0) - nvl(capital_pagado,0)) + (nvl(interes_debe,0) - nvl(interes_pagado,0)) +
						(nvl(iva_debe,0) - nvl(iva_pagado,0))) Pago_Sin_Vdo 
						INTO v_pago_min_sin_vdo
				FROM bdicred:sd_maecredcrd cr,bdicred:sd_amortiza_creditocrd a
				WHERE a.empresa = cr.empresa
					AND a.num_credito = cr.num_credito
					AND a.capital_status =1
					AND a.num_credito = vnumcredito;*/
				 
			
				--CALCULO DE PAGO MINIMO
/*				SELECT  ( a.monto_financiado +
					a.int_tra_no_exig + -- INt Vencido
					a.mto_venc_int  +-- Iva INt Vencido
					a.sdo_no_exig  +--Int. Vigente
					a.mto_finan_vdo + -- Iva Int. Vigente
					round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2) )  Pago_minimo INTO vpago_minimo_total
				FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
				WHERE cr.empresa = s.empresa
					AND cr.sucursal = s.sucursal
					AND a.empresa = cr.empresa
					AND a.num_credito = cr.num_credito
					AND a.num_credito = vnumcredito;*/
	
				--CALCULO DE SALDO TOTAL
/*				SELECT (a.sdo_cap_insoluto     + 
                  round(NVL(a.sdo_intereses,0) * (1+ s.iva),2) +  --tipo de IVA
                  a.int_tra_no_exig + a.mto_venc_int + a.sdo_no_exig + a.mto_finan_vdo +   --INtVencido + Iva INtVencido + IntVigente + Iva IntVigente
                  round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2)) sdo_total INTO vsaldo_total
				FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
				WHERE cr.empresa = s.empresa
					AND cr.sucursal = s.sucursal
					AND a.empresa = cr.empresa
					AND a.num_credito = cr.num_credito
					AND a.num_credito = vnumcredito;*/
			
				--CALCULO DE SDO_VENC_INT_MORA
/*				SELECT ((a.monto_vencido + a.mto_venc_trasp) + int_tra_no_exig + mto_venc_int  +   --INtVencido + IvaINtVencido +
					a.sdo_no_exig + a.mto_finan_vdo + 
					round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2) ) Sdo_Vencido_Int_mora  
					, (a.monto_vencido + a.mto_venc_trasp)
					INTO v_sdo_venc_int_mora , vpago_vencido -- IntVigente + IvaIntVigente + PagoExigible
				FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
				WHERE cr.empresa = s.empresa
					AND cr.sucursal = s.sucursal
					AND a.empresa = cr.empresa
					AND a.num_credito = cr.num_credito
					AND a.num_credito = vnumcredito;*/
					
--        if (vmail <> '') then
            /*--ALL if (pparam = 0) then
                call "informix".sp_mail_inserta_cliente (pempresa,4,vnumcte,vnumcredito, vmail,0,0,0,0,vfechapago,null,null,0,0,
                                                    vpago_vencido,v_pago_min_sin_vdo,v_sdo_venc_int_mora) RETURNING P_COD_RET;  
            end if; --ALL */
            --A.L.L.
            LET iCount_REST_PREV = iCount_REST_PREV +1;

            call bdimnsj:"informix".sp_registra_evento (1, 'REST_PREV' , vnumcte, vnumcredito,vnumtarjeta, 2,
                                '','','','','',0,0,0,0,0, vfechapago, today) RETURNING COD_RET;
--                                vapell_paterno,'','','','',0,0,0,0,0, vfechapago, today) RETURNING COD_RET;
			call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1015, vnumcredito, vnumcte, '6011', today,vmail, '','','') returning P_COD_RET;
--        end if;	
	end foreach

--	IF iCount_REST_PREV > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_PREV',iCount_REST_PREV,iCuentasExcluidasXMail) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_PREV',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
--	END IF;

	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
          insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
          select  1, 'REST_PREV',numcte,1,current,apell_paterno,0,current,current
          from bdinteg:si_cliente
          where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
				
		let num = num + 10;
	end for
	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña REST_PREV : ' || iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados PREVENTIVA : ' || iCount_REST_PREV;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' || iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '03') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

  RETURN P_COD_RET,P_MENSAJE;

end
END PROCEDURE;
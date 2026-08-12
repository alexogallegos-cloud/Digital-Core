create procedure "informix".sp_mail_compfracionado(pempresa char(3),pfechacorte date)
returning
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pfechacompac  DATE;
DEFINE pimporte      DECIMAL(18,2);
DEFINE pfechapago    DATE;
DEFINE pflagpago     SMALLINT;
DEFINE pfechahoy     date;
DEFINE pfechaarmada date; 
define vnumtarjeta char(20);

DEFINE cProceso  char(4);
DEFINE cCod_ret  char(6);
DEFINE cMensaje  char (100);   
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
define pparam smallint;
DEFINE v_sdo_venc_int_mora 	 DECIMAL(18,2);
DEFINE vpago_min_sin_venc	 DECIMAL(18,2);
DEFINE vpago_venc 			 DECIMAL(18,2);
DEFINE vsaldo_total 		 DECIMAL(18,2);
DEFINE vpago_min 			 DECIMAL(18,2);
define vapell_paterno 		char(30);
--define vcount				integer;
define iCount_COMPAC_FRA    integer; --A.L.L.
	define vvalor smallint;
define i integer;
define num smallint;
DEFINE iCuentasProcesadas   integer;
DEFINE iCuentasExcluidasXMail integer;
DEFINE cnumproducto			CHAR(04);
DEFINE cCodRet 		char(06);


LET pnumcredito	= '';
LET pnumcte		= '';
LET pemail		= '';
LET pfechacompac	= DATE(1);
LET pimporte 	= 0;
LET pfechapago	= DATE(1);
LET pflagpago	= 0;
LET pfechahoy 	= DATE(1);
LET vnumtarjeta	= '';
LET pfechaarmada	= DATE(1);

--	let P_COD_RET = '111111';
	let cCod_ret = '';
    let cMensaje = '';
	let cproceso = '2025';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
--	let P_MENSAJE          = '';
	let pparam 	= 0;
	LET v_sdo_venc_int_mora   =0;
	LET vpago_min_sin_venc	  =0;
	LET vpago_venc 			  =0;
	LET vsaldo_total 		  =0;
	LET vpago_min 			  =0;
	let vapell_paterno = '';
--	let vcount			= 0;
	let iCount_COMPAC_FRA = 0; --A.L.L.L
	let i = 0;
		LET num = 0;
	let iCuentasProcesadas  = 0;
	let iCuentasExcluidasXMail = 0;
	let cnumproducto = '';
	let cCodRet 		= '';
	let P_COD_RET   = '000000';
	let P_MENSAJE   ='El proceso de las campañas EMAIL TDC COMP FRACC. se realizó correctamente.';

--SET DEBUG FILE TO "sp_mail_compfracionado.out";
--TRACE ON;

BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;

    	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '02') RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    	RETURN P_COD_RET,P_MENSAJE;
    END exception;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
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

		let P_COD_RET = cCod_ret;
        let P_MENSAJE = cMensaje;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING cCod_Ret;
        RETURN P_COD_RET,P_MENSAJE;


	END IF;
	IF NVL (pfechacorte, '') = '' THEN
        LET cCod_Ret= '104008';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
       IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

		let P_COD_RET = cCod_ret;
        let P_MENSAJE = cMensaje;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING cCod_Ret;
        RETURN P_COD_RET,P_MENSAJE;
	END IF;

    Select Fecha_Hoy
        Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa;

    --delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 3 and  pagos_vencidos = 3;

	let pfechaarmada = date (pfechacorte) -  1 units day;
--let pfechaarmada = '03-31-2012';--'10-18-2011';
    

	
	set isolation to dirty read;
	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;	
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;		

	let i = 0;
		LET num = 0;
	FOR i in (1 to vvalor)
	set isolation to dirty read;
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'COMPAC_FRA',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			let num = num + 10;
	end for
		
	foreach 
	SELECT a.num_credito, a.numcte, d.fecha_compac, d.imp_pagado, d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcredito, pnumcte, pfechacompac, pimporte, pfechapago, pflagpago, cnumproducto
    FROM bdicred:sd_maecred a,  bdicobranza:cb_compac_his d, bdicred:sd_maesdos c
    WHERE  a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '6001' and a.num_credito = c.num_credito
		and a.status_cred in ('BT','BA','E1','E2','E3') 
		AND (c.monto_vencido + c.mto_venc_trasp) > 0
        AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 0 
        and nvl(d.imp_pagado,0) > 0
        and d.importe > d.imp_pagado

	let iCuentasProcesadas = iCuentasProcesadas + 1;
	
/*	select  apell_paterno into vapell_paterno
	from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;*/
	
	select limit 1 cte.correo_elec into pemail 
	from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
							and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
	where empresa  = '001' and numcte = pnumcte and status_correo ='A');

	if pemail is null or pemail = '' then 
       let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
       continue foreach; 
    end if;

{	select (cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
		,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) /*MtoVencido1*/,
		cl.mensualidad_actual   ,
		cl.monto_vencido + cl.mto_venc_trasp  
			into vsaldo_total, 
				v_sdo_venc_int_mora,
				vpago_min_sin_venc	,
				vpago_venc 
		from bdicred:sd_sdos_cartera_linea cl
		where cl.num_credito = pnumcredito;
		let vpago_min = vpago_min_sin_venc + v_sdo_venc_int_mora;}
		
--A.L.L		
	/*	select  est.estado||'-'||est.siglas, cid.numerociudad||'-'||cid.inicialciudad
			into vNumIniciudad, vEstadoSiglas 	
				from bdinteg:si_direcciones_actual act  
				inner join bdinteg:si_estados est on est.estado = act.estado
				inner join bdinteg:si_catciudades cid on cid.ciudad = act.numerociudad 
				where act.numcte = vnumcte
				and act.tipo_dir = 1;
	*/	
--	if (pemail <> '') then	
		select LIMIT 1 t.num_tarjeta into vnumtarjeta
		from bdicred:sd_tarjeta t
		where t.empresa = '001'
		and t.num_credito = pnumcredito
		and t.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = '001'
                    and tar.num_credito = pnumcredito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and t.tipo_tarjeta ='T'  and t.status_tar = 'A';
		
		let pimporte = round(pimporte)	+1;	
/*		if (pparam = 0)then	
			call "informix".sp_mail_inserta_cliente (pempresa,1001, pnumcte, pnumcredito, pemail,0,0,3,pimporte,pfechacompac,
													pfechapago,null,0,pflagpago,vpago_venc,vpago_min_sin_venc,v_sdo_venc_int_mora)
			returning P_COD_RET;
		end if;		*/
		--A.L.L.
		LET iCount_COMPAC_FRA = iCount_COMPAC_FRA +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'COMPAC_FRA' , pnumcte, pnumcredito,vnumtarjeta, 2,
							'','','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;
--							vapell_paterno,'','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;

		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1001, pnumcredito, pnumcte, cNumProducto, today,pemail, '','',pimporte) returning P_COD_RET;

--	end if;
	
	let P_COD_RET = '000000';
	end foreach

	--A.L.L.
--	IF iCount_COMPAC_FRA > 0 THEN
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('COMPAC_FRA',iCount_COMPAC_FRA,iCuentasExcluidasXMail) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('COMPAC_FRA',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
--	END IF;
	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña COMPAC_FRA : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_COMPAC_FRA;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
		
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;

        if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

end
    RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE;
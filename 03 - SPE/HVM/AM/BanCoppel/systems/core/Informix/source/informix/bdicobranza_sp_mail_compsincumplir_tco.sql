CREATE PROCEDURE "informix".sp_mail_compsincumplir_tco(pempresa char(3),pfechacorte date)
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;
------------------------------------------------------------------------------------------------------------------------------
--Abrham Lopez Lopez
--2016-05-16
--execute procedure "informix".sp_mail_compsincumplir_tco('001','05-15-2016');
------------------------------------------------------------------------------------------------------------------------------
DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pfechacompac  DATE;
DEFINE pimporte      DECIMAL(18,2);
DEFINE pfechapago    DATE;
DEFINE pflagpago     SMALLINT;
DEFINE pfechahoy     date;
DEFINE cProceso  char(4);
DEFINE cCod_ret  char(6);
DEFINE cMensaje  char (100);
DEFINE pfechaarmada date; 
define vnumtarjeta char(20);
define pparam smallint;
DEFINE v_sdo_venc_int_mora 	 DECIMAL(18,2);
DEFINE vpago_min_sin_venc	 DECIMAL(18,2);
DEFINE vpago_venc 			 DECIMAL(18,2);
DEFINE vsaldo_total 		 DECIMAL(18,2);
DEFINE vpago_min 			 DECIMAL(18,2);

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
define vapell_paterno 		char(30);
define vapell_materno		char(30);
define vnombre1				char(30);
define vnombre2				char(30);
define vmSuma1 				 DECIMAL(18,2);
define vmSuma2 				 DECIMAL(18,2);
define vmSumaPagos			 DECIMAL(18,2);
DEFINE cCel				CHAR(13);  
DEFINE iCel 			SMALLINT;
define cNumProducto		char(4);
define vvalor_numerico	integer;
define vcontador 		 smallint;
define vmaxfecha 		date;
define iCount_TCO_COMSIN integer; 
define iCount_TCO_COPACS integer; 
define vvalor smallint;
define i integer;
define num smallint;
define vNumIniciudad 	char(8); 
define vEstadoSiglas	char(10); 
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
DEFINE iCuentasExcluidasXCel integer;

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
let vmaxfecha		= date(1);
let iCount_TCO_COMSIN = 0; 
let iCount_TCO_COPACS = 0;

	let cCod_ret = '000000';
    let cMensaje = '';
	let cproceso = '0037';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let pparam ='';
	LET v_sdo_venc_int_mora   =0;
	LET vpago_min_sin_venc	  =0;
	LET vpago_venc 			  =0;
	LET vsaldo_total 		  =0;
	LET vpago_min 			  =0;
	let vapell_paterno = '';
	let vapell_materno	= '';
	let vnombre1		= '';
	let vnombre2		= '';
	let vmSuma1 			 =0;
	let vmSuma2 			 =0;
	let vmSumaPagos			 =0; 
	LET cCel = ''; LET iCel = 0;
	let cNumProducto = '';
	let vvalor_numerico = 0;
	let vcontador = 0;
	let i = 0;
	LET num = 0;
	let vNumIniciudad	='';
	let vEstadoSiglas	='';
	let iCuentasProcesadas      = 0;
	let iCuentasExcluidasXMail  = 0;
	let iCuentasExcluidasXCel  = 0;
	let P_COD_RET   = '000000';
	let P_MENSAJE   ='El proceso de las campañas XX TCO COMP ACT Y SIN CUMPL se realizó correctamente.';

BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
     	RETURN P_COD_RET,P_MENSAJE;
     END exception;
-- SET DEBUG FILE TO 'sp_mail_compsincumplir.out';
-- TRACE ON;	

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	--valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

		let P_COD_RET = cCod_ret;
        let P_MENSAJE = cMensaje;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING cCod_ret;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;
	IF NVL (pfechacorte, '') = '' THEN
        LET cCod_ret= '104008';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_ret;
	
       IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

		let P_COD_RET = cCod_ret;
        let P_MENSAJE = cMensaje;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING cCod_ret;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

    Select Fecha_Hoy
        Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa;
	
	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;	
		
			select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

    --delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 3 and pagos_vencidos= 4;
     
	let pfechaarmada = date (pfechacorte) -  1 units day;
	--let pfechaarmada = '05-13-2016';
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TCO_COMSIN',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			
		let num = num + 10;
	end for
		
	foreach with hold
	/*SELECT a.num_credito, a.numcte, d.fecha_compac, d.importe, d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcredito, pnumcte, pfechacompac, pimporte, pfechapago, pflagpago, cNumProducto
    FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d, bdinteg:si_correos b
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '8100' and a.status_cred in ('BT','BA')
        AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 0 
        and nvl(d.imp_pagado,0) = 0*/ 
		
	select a.num_credito, a.numcte, d.fecha_compac, d.importe, d.fecha_insert, d.flag_pago, a.num_producto
        into pnumcredito, pnumcte, pfechacompac, pimporte, pfechapago, pflagpago, cNumProducto
    from bdicred:sd_maecred a 
	inner join bdicobranza:cb_compac_his d on (a.empresa = d.empresa  and a.num_credito =d.numcuenta)
	inner join bdicred:sd_maesdos c on (a.num_credito =c .num_credito)
    where a.num_producto = '8100' 
		and a.status_cred in ('BT','BA','E1','E2','E3')
		and (c.monto_vencido + c.mto_venc_trasp) > 0
        and d.fecha_insert = pfechaarmada
		and d.flag_pago = 0 
        and nvl(d.imp_pagado,0) = 0 	

	let iCuentasProcesadas = iCuentasProcesadas + 1;
	
	select limit 1 cte.correo_elec into pemail 
	from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
							and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
	where empresa  = '001' and numcte = pnumcte and status_correo ='A');

	if pemail is null or pemail = '' then 
       let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
       continue foreach; 
    end if;
		
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
		
		let pimporte = round(pimporte)	+ 1;	
	
		BEGIN WORK;
	
		let iCount_TCO_COMSIN = iCount_TCO_COMSIN +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'TCO_COMSIN' , pnumcte, pnumcredito,vnumtarjeta, 2,
							vapell_paterno,'','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;
		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1029, pnumcredito, pnumcte, cNumProducto, today,pemail, '','',pimporte) returning P_COD_RET;

		COMMIT WORK;	

	end foreach	

        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_COMSIN',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;

	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCO_COMSIN : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TCO_COMSIN: ' ||iCount_TCO_COMSIN;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

	
	let pnumcredito = ''; let pnumcte = ''; let pimporte = 0; let pfechacompac = date(1); let pfechapago = date(1); let vapell_paterno = '';
	let vapell_materno	= '';	let vnombre1		= '';	let vnombre2		= '';
	
	select valor_numerico into vvalor_numerico
	from bdicobranza:cb_param_campania	where tipo_campania = 51 and grupo_parametro = 'LATINIA'and num_parametro =15;

	let iCuentasProcesadas = 0;

				
	foreach WITH HOLD
	SELECT limit vvalor_numerico a.num_credito, a.numcte, d.importe,d.fecha_compac, (date(d.fecha_insert) + (d.plazo * 7)), a.num_producto
        INTO pnumcredito, pnumcte, pimporte, pfechacompac, pfechapago, cNumProducto
		FROM bdicred:sd_maecred a, bdicobranza:cb_compac d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '8100'
         AND (date(d.fecha_insert) + (d.plazo * 7)) - 2 units day =  date(pfechacorte)
		 AND activo = 1
		 
	let iCuentasProcesadas = iCuentasProcesadas + 1;
  	
	SELECT limit 1 NVL(d.telefono,'')	INTO cCel
	FROM bdinteg:"informix".si_telefonos_actual d          
	WHERE d.numcte= pnumcte	AND d.tipo_tel = 2	and status_tel = 'A' and cofetel ='V';

	if cCel is null or cCel = '' then 
       let iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
       continue foreach; 
    end if;
		
	LET iCel = LENGTH(cCel) + 1 - 10;  
			
			IF ( LENGTH(cCel) > 10 ) THEN
				LET cCel = SUBSTR(cCel,iCel,10);
			ELIF ( LENGTH(cCel) < 10 ) THEN
					LET cCel ='';
			END IF;
		
		select limit 1 mto_fin_ven_trasp into vpago_venc 
		from bdicred:sd_maesdos where empresa = '001' and num_credito = pnumcredito;
		
		-- SUMA DE LOS PAGOS DEL DÍA ACTUAL (sc_movdia) POR VENTANILLA, INTERNET y CHEQUES.
		/*SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0)  INTO vmSuma1 
		FROM bdicred:sd_movdia 
		WHERE empresa = '001' and num_credito = pnumcredito and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
			and reversado = 'N';*/ 	
		-- SUMA DE LOS PAGOS DE LOS DÍAS ANTERIORES (sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO vmSuma2 
		FROM bdicred:sd_movhis 
		WHERE empresa = '001' and num_credito = pnumcredito and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
			and fecha_mov >= pfechacompac and fecha_mov < pfechahoy and reversado = 'N';	
		
		--LET vmSumaPagos = vmSuma1 + vmSuma2;
		LET vmSumaPagos = vmSuma2;
		
		if (vmSumaPagos < pimporte) then			
				
		BEGIN WORK;

			LET iCount_TCO_COPACS = iCount_TCO_COPACS +1;
			call bdimnsj:"informix".sp_registra_evento (2, 'TCO_COPACS' , pnumcte, pnumcredito,'', 2,
							vapell_paterno,'','','','',pimporte,0,0,0,0, pfechapago, '')RETURNING P_COD_RET;
			call "informix".sp_inserta_info_rep_envios (pempresa,'SMS',27, pnumcredito, pnumcte, cNumProducto, today, cCel, '','',pimporte) returning P_COD_RET;

			let vcontador = vcontador + 1;
		COMMIT WORK;
		end if;

	if (vcontador = vvalor_numerico) then	exit FOREACH; end if;
	end foreach	
	if (vcontador >= 1) then 
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  2, 'TCO_COPACS',numcte,2,current,apell_paterno,100,pfechacorte,''
		from bdinteg:si_cliente
        where numcte in (select valor from bdicobranza:cb_param where cod_param in (57));
	end if;

        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_COPACS',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING P_COD_RET;

	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCO_COPACS : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TCO_COPACS: ' ||iCount_TCO_COPACS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
		
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
	
	if P_COD_RET != '000000' then
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

end
RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE;
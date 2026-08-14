CREATE PROCEDURE "informix".sp_mail_compsincumplir(pempresa char(3),pfechacorte date)
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
--define vcount 			integer;
define iCount_COMPAC_SIN integer; --A.L.L.
define iCount_TC_COMPACS integer; 
define vvalor smallint;
define i integer;
define num smallint;
define vNumIniciudad 	char(8); --A.L.L
define vEstadoSiglas	char(10); --A.L.L
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
--let vcount = 0;
let iCount_COMPAC_SIN = 0; --A.L.L.
let iCount_TC_COMPACS = 0;


--	let P_COD_RET = '111111';
	let cCod_ret = '000000';
    let cMensaje = '';
	let cproceso = '2026';
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
	let P_MENSAJE   ='El proceso de las campañas XX TDC COMP ACT Y SIN CUMPL se realizó correctamente.';



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
--       let P_COD_RET = cCodRet;
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
	--let pfechaarmada = '04-13-2012';--'03-21-2012';
	set isolation to dirty read;
	
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'COMPAC_SIN',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			
		let num = num + 10;
	end for
		
	foreach 
	SELECT a.num_credito, a.numcte, d.fecha_compac, d.importe, d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcredito, pnumcte, pfechacompac, pimporte, pfechapago, pflagpago, cNumProducto
    FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d, bdicred:sd_maesdos c
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_credito = c.num_credito and a.num_producto = '6001' 
		and a.status_cred in ('BT','BA','E1','E2','E3') 
		AND (c.monto_vencido + c.mto_venc_trasp) > 0
        AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 0 
        and nvl(d.imp_pagado,0) = 0 

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

--		select (cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) --SdoTotal1
--		,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) ,---MtoVencido1
/*		cl.mensualidad_actual   ,
		cl.monto_vencido + cl.mto_venc_trasp  
			into vsaldo_total, 
				v_sdo_venc_int_mora,
				vpago_min_sin_venc	,
				vpago_venc 
		from bdicred:sd_sdos_cartera_linea cl
		where cl.num_credito = pnumcredito;
		let vpago_min = vpago_min_sin_venc + v_sdo_venc_int_mora;*/
	
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
		
		let pimporte = round(pimporte)	+ 1;	
	
		--A.L.L.
		let iCount_COMPAC_SIN = iCount_COMPAC_SIN +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'COMPAC_SIN' , pnumcte, pnumcredito,vnumtarjeta, 2,
							vapell_paterno,'','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;
		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1003, pnumcredito, pnumcte, cNumProducto, today,pemail, '','',pimporte) returning P_COD_RET;
--	end if;
	
--    let P_COD_RET = '000000';
	end foreach	--call  "informix".sp_inserta_mensaje('001',3,0,4) RETURNING P_COD_RET;
    /*        
	SELECT count(*) into vcount
	FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.status_cred in ('BT','BA') 
        AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 0 
        and nvl(d.imp_pagado,0) = 0
		and a.numcte in 
		(select numcte
		from  bdinteg:si_correos   where  empresa ='001' and status_correo ='A'
		and secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and status_correo ='A' and numcte = a.numcte)); 
	*/
	--A.L.L.
--	IF iCount_COMPAC_SIN > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('COMPAC_SIN',iCount_COMPAC_SIN,iCuentasExcluidasXMail) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('COMPAC_SIN',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
--	END IF;
	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña COMPAC_SIN : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados COMPAC_SIN: ' ||iCount_COMPAC_SIN;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control


--    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '03')
--    RETURNING P_COD_RET;
	-------------------------------------------------------------------------------------------------------	

--	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, 'Inicio convenio sms', '02')
--    RETURNING P_COD_RET;
	
	let pnumcredito = ''; let pnumcte = ''; let pimporte = 0; let pfechacompac = date(1); let pfechapago = date(1); let vapell_paterno = '';
	let vapell_materno	= '';	let vnombre1		= '';	let vnombre2		= '';
	
	select valor_numerico into vvalor_numerico
	from bdicobranza:cb_param_campania	where tipo_campania = 51 and grupo_parametro = 'LATINIA'and num_parametro =15;

	let iCuentasProcesadas = 0;

	set isolation to dirty read;
			
	foreach WITH HOLD
	SELECT limit vvalor_numerico a.num_credito, a.numcte, d.importe,d.fecha_compac, (date(d.fecha_insert) + (d.plazo * 7)), a.num_producto
        INTO pnumcredito, pnumcte, pimporte, pfechacompac, pfechapago, cNumProducto
		FROM bdicred:sd_maecred a, bdicobranza:cb_compac d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '6001'
         AND (date(d.fecha_insert) + (d.plazo * 7)) - 2 units day =  date(pfechacorte) -- 2 units day
		 AND activo = 1
		 
	let iCuentasProcesadas = iCuentasProcesadas + 1;
  	
	SELECT limit 1 NVL(d.telefono,'')	INTO cCel
	FROM bdinteg:"informix".si_telefonos_actual d          
	WHERE d.numcte= pnumcte	AND d.tipo_tel = 2	and status_tel = 'A' and cofetel ='V';

	if cCel is null or cCel = '' then 
       let iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
       continue foreach; 
    end if;
		
--	if (cCel <> '') then
	LET iCel = LENGTH(cCel) + 1 - 10;  
			
--		IF cCel <> '' then
			IF ( LENGTH(cCel) > 10 ) THEN
				LET cCel = SUBSTR(cCel,iCel,10);
			ELIF ( LENGTH(cCel) < 10 ) THEN
					LET cCel ='';
			END IF;
--		END IF;
		
/*		select  limit 1 apell_paterno , apell_materno,nombre1,nombre2 
			into vapell_paterno,vapell_materno,vnombre1,vnombre2 
		from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;*/
		
		select limit 1 mto_fin_ven_trasp into vpago_venc 
		from bdicred:sd_maesdos where empresa = '001' and num_credito = pnumcredito;
		
		-- SUMA DE LOS PAGOS DEL DÍA ACTUAL (sc_movdia) POR VENTANILLA, INTERNET y CHEQUES.
		SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0)  INTO vmSuma1 
		FROM bdicred:sd_movdia 
		WHERE empresa = '001' and num_credito = pnumcredito and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
			and reversado = 'N'; 	
		-- SUMA DE LOS PAGOS DE LOS DÍAS ANTERIORES (sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO vmSuma2 
		FROM bdicred:sd_movhis 
		WHERE empresa = '001' and num_credito = pnumcredito and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
			and fecha_mov >= pfechacompac and fecha_mov < pfechahoy and reversado = 'N';	
		
		LET vmSumaPagos = vmSuma1 + vmSuma2;
		
		if (vmSumaPagos < pimporte) then			
				
--		if (cCel <> '') then	
		BEGIN WORK;
			--A.L.L.
			LET iCount_TC_COMPACS = iCount_TC_COMPACS +1;
			call bdimnsj:"informix".sp_registra_evento (2, 'TC_COMPACS' , pnumcte, pnumcredito,'', 2,
							vapell_paterno,'','','','',pimporte,0,0,0,0, pfechapago, '')RETURNING P_COD_RET;
			call "informix".sp_inserta_info_rep_envios (pempresa,'SMS',15, pnumcredito, pnumcte, cNumProducto, today, cCel, '','',pimporte) returning P_COD_RET;

/*			if P_COD_RET = '00000' then
			INSERT INTO bdicobranza:"informix".cb_info_administrativa(
		            empresa,num_campania,producto,fecha_ejecucion,cliente, credito, cuenta,tarjeta,ciudad, 
					estado, apell_paterno,apell_materno,nombre1,nombre2, t_celular, sdo_total, pago_min,
					fecha_pago,sdo_venc_int_mora,pago_venc,pago_min_sin_vdo,situacion,causa,pago_vencido,pago_req_sms, ciudad, estado) 
			VALUES('001',15,cNumProducto,pfechacorte,pnumcte, pnumcredito,'', '','', 
			    '', vapell_paterno,vapell_materno,vnombre1,vnombre2 , cCel, 0,0,
                '',0,vpago_venc,0, '', 0,0,0, vNumIniciudad, vEstadoSiglas);
			end if;*/
			let vcontador = vcontador + 1;
		COMMIT WORK;
--		end if;
		end if;
--	end if;
--    let P_COD_RET = '000000';
	if (vcontador = vvalor_numerico) then	exit FOREACH; end if;
	end foreach	
	if (vcontador >= 1) then 
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  2, 'TC_COMPACS',numcte,2,current,apell_paterno,100,pfechacorte,''
		from bdinteg:si_cliente
        where numcte in (select valor from bdicobranza:cb_param where cod_param in (57));
	end if;
	/*
	let vcount = 0;
	SELECT count(*) INTO vcount
	FROM bdicred:sd_maecred a, bdicobranza:cb_compac d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta 
        AND (date(d.fecha_insert) + (d.plazo * 7)) - 2 units day =  date(pfechacorte) - 2 units day
		AND activo = 1
		and a.numcte in 
			(select numcte 
			FROM bdinteg:si_telefonos_actual
			where tipo_tel= '2' and status_tel = 'A' and cofetel ='V' and numcte = a.numcte
			and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
				where empresa  = '001' and status_tel = 'A' and numcte = a.numcte)); 
	*/
	--A.L.L.
--	IF iCount_TC_COMPACS > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_COMPACS',iCount_TC_COMPACS,iCuentasExcluidasXCel) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_COMPACS',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING P_COD_RET;
--	END IF;
	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_COMPAC : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_COMPACS: ' ||iCount_TC_COMPACS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
	
--    let P_COD_RET = '000000';  	
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
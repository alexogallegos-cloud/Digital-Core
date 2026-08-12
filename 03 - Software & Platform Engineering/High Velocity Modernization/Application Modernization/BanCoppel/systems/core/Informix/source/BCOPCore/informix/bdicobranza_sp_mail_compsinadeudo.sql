CREATE PROCEDURE "informix".sp_mail_compsinadeudo(pempresa char (3), pfechacorte date)
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

--execute procedure "informix".sp_mail_compsinadeudo('001',today)
DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pfechacompac  DATE;
DEFINE pimporte      DECIMAL(18,2);
DEFINE pfechapago    DATE;
DEFINE pflagpago     SMALLINT;
--DEFINE pfechaact     date;
--DEFINE pfechaant     date;
DEFINE pfechahoy     date;
DEFINE vnumtarjeta 	 CHAR(20);
define pparam		 smallint;
DEFINE v_sdo_venc_int_mora 	 DECIMAL(18,2);
DEFINE vpago_min_sin_venc	 DECIMAL(18,2);
DEFINE vpago_venc 			 DECIMAL(18,2);
DEFINE vsaldo_total 		 DECIMAL(18,2);
DEFINE vpago_min 			 DECIMAL(18,2);

DEFINE cProceso  char(4);
DEFINE cCod_ret  char (06);
DEFINE cMensaje  char (100); 

---DEFINE pdia      date; 
DEFINE pfechaarmada date; 

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
define vapell_paterno 		char(30);
--define vcount			  integer;
define iCount_COMPAC_PAG  integer; --A.L.L.
define vvalor smallint;
define i integer;
define num smallint;
define iCuentasProcesadas  integer;
define iCuentasExcluidasXMail integer;
define cNumProducto 	char(04);
define cCodRet 		char(06);


LET vnumtarjeta = '';
let pparam =0;
let P_COD_RET   = '000000';
let P_MENSAJE   ='El proceso de las campañas EMAIL TDC COMP SIN ADEUDO se realizó correctamente.';
LET v_sdo_venc_int_mora   =0;
LET vpago_min_sin_venc	  =0;
LET vpago_venc 			  =0;
LET vsaldo_total 		  =0;
LET vpago_min 			  =0;
let vapell_paterno = '';
--let  vcount = 0;
let iCount_COMPAC_PAG = 0; --A.L.L.
let i = 0;
LET num = 0;		
let iCuentasProcesadas  = 0;
let iCuentasExcluidasXMail = 0;
let cNumProducto = '';
--    let P_COD_RET = '111111';
let cCod_ret = '';
let cMensaje = '';
let cproceso = '2023';
--	let P_MENSAJE = '';
let cCodRet 	= '';


--SET DEBUG FILE TO "comp_sinaduedo.out";
--TRACE ON;
BEGIN 
  
ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;

        LET P_COD_RET = SQL_ERR;
--    RETURN P_COD_RET;
       RETURN P_COD_RET,P_MENSAJE;
END exception;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
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
        LET cCod_Ret= '104008';        
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

    Select Fecha_Hoy
        Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa ;
	
	set isolation to dirty read;
	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;	
		
			select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
--    delete from bdicobranza:cb_mail_cliente where tipo_mensaje = 3 and fecha_insert = pfechahoy and pagos_vencidos=1;
  	let pfechaarmada = date (pfechacorte) -  1 units day;

	
	set isolation to dirty read;
	
	let i = 0;
		LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'COMPAC_PAG',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			let num = num + 10;
	end for
		
	foreach 
	
    SELECT a.numcte,a.num_credito, d.importe, d.fecha_compac,d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcte,pnumcredito, pimporte, pfechacompac,  pfechapago, pflagpago, cNumProducto
    FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d, bdicred:sd_maesdos c
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '6001' and c.num_credito = a.num_credito
		AND a.status_cred IN ('AA','E1') 
		AND (c.monto_vencido + c.mto_venc_trasp) = 0
	    AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 1 
		AND nvl(d.imp_pagado,0) > 0
		and d.importe <= d.imp_pagado
		
	--A.L.L.	
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

{		select (cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
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

--	if (pemail <> '') then
--		if (pparam = 0)then	
--			call "informix".sp_mail_inserta_cliente (pempresa,1000, pnumcte, pnumcredito, pemail,0,0,1,pimporte,pfechacompac,--A.L.L. se cambia 3 por 1000
--													pfechapago,null,0,pflagpago,vpago_venc,vpago_min_sin_venc,v_sdo_venc_int_mora)
--			returning P_COD_RET;
--		end if;
		--A.L.L.
		let iCount_COMPAC_PAG = iCount_COMPAC_PAG +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'COMPAC_PAG' , pnumcte, pnumcredito,vnumtarjeta, 2,
							'','','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;

		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1000, pnumcredito, pnumcte, cNumProducto, today,pemail, '','',pimporte) returning P_COD_RET;

--	end if;
	
	
	end foreach
	/*
	SELECT count(*) into vcount
	FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.status_cred ='AA' 
	    AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 1 
		AND nvl(d.imp_pagado,0) > 0
		and d.importe <= d.imp_pagado
		 and a.numcte in 
		(select numcte
		from  bdinteg:si_correos   where  empresa ='001' and status_correo ='A'
		and secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and status_correo ='A' and numcte = a.numcte));
	*/
	--A.L.L.
--	IF iCount_COMPAC_PAG > 0 THEN
--	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('COMPAC_PAG',iCount_COMPAC_PAG,iCuentasExcluidasXMail) RETURNING P_COD_RET;
	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('COMPAC_PAG',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
--    END IF;
	
--	let P_COD_RET = '000000';  	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña COMPAC_PAG : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_COMPAC_PAG;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
	

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

end
--RETURN P_COD_RET;
  RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE;
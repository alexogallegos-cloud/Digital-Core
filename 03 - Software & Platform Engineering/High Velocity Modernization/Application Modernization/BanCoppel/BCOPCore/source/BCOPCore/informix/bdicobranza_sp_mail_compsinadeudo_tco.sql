CREATE PROCEDURE "informix".sp_mail_compsinadeudo_tco(pempresa char (3), pfechacorte date)
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

--execute procedure "informix".sp_mail_compsinadeudo_tco('001',today)
DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pfechacompac  DATE;
DEFINE pimporte      DECIMAL(18,2);
DEFINE pfechapago    DATE;
DEFINE pflagpago     SMALLINT;
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

DEFINE pfechaarmada date; 

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
define vapell_paterno 		char(30);
define iCount_TCO_COMPAG  integer; 
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
let iCount_TCO_COMPAG = 0; 
let i = 0;
LET num = 0;		
let iCuentasProcesadas  = 0;
let iCuentasExcluidasXMail = 0;
let cNumProducto = '';
let cCod_ret = '';
let cMensaje = '';
let cproceso = '0015';
let cCodRet 	= '';


--SET DEBUG FILE TO "/informix/ALL/TCOro/comp_sinaduedo.out";
--TRACE ON;
BEGIN 
  
ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;

        LET P_COD_RET = SQL_ERR;
       RETURN P_COD_RET,P_MENSAJE;
END exception;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
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
		
  	let pfechaarmada = date (pfechacorte) -  1 units day;

	set isolation to dirty read;
	
	let i = 0;
		LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TCO_COMPAG',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			let num = num + 10;
	end for
		
	foreach 
	
    SELECT a.numcte,a.num_credito, d.importe, d.fecha_compac,d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcte,pnumcredito, pimporte, pfechacompac,  pfechapago, pflagpago, cNumProducto
    FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '8100' and a.status_cred ='AA'
	    AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 1 
		AND nvl(d.imp_pagado,0) > 0
		and d.importe <= d.imp_pagado
			
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

		let iCount_TCO_COMPAG = iCount_TCO_COMPAG +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'TCO_COMPAG' , pnumcte, pnumcredito,vnumtarjeta, 2,
							'','','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;

		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1026, pnumcredito, pnumcte, cNumProducto, today,pemail, '','',pimporte) returning P_COD_RET;
	
	end foreach

	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_COMPAG',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCO_COMPAG : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_TCO_COMPAG;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
	

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

end
  RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE;
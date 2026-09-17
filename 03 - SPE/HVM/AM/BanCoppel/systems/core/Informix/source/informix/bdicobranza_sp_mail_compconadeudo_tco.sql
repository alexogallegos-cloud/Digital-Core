CREATE PROCEDURE "informix".sp_mail_compconadeudo_tco(pempresa char(3),pfechacorte date)
returning
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;
-----------------------------------------------------------------------------------
--Abrham Lopez Lopez
--2016-05-12
--execute procedure "informix".sp_mail_compconadeudo_tco('001', '05-10-2016');


DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pfechacompac  DATE;
DEFINE pimporte      DECIMAL(18,2);
DEFINE pfechapago    DATE;
DEFINE pflagpago     SMALLINT;
DEFINE pfechahoy     date;
DEFINE vnumtarjeta		 CHAR(20);

DEFINE cProceso  char(4);
DEFINE cCod_ret  char(6);
DEFINE cMensaje  char (100);
DEFINE pfechaarmada date; 

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
define  pparam  			Smallint;
DEFINE v_sdo_venc_int_mora 	 DECIMAL(18,2);
DEFINE vpago_min_sin_venc	 DECIMAL(18,2);
DEFINE vpago_venc 			 DECIMAL(18,2);
DEFINE vsaldo_total 		 DECIMAL(18,2);
DEFINE vpago_min 			 DECIMAL(18,2);
define vapell_paterno 		char(30);
--define vcount				integer;
define iCount_TCO_COMADE    integer; --A.L.L.
	define vvalor smallint;
define i integer;
define num smallint;
DEFINE iCuentasProcesadas   integer;
DEFINE iCuentasExcluidasXMail integer;
DEFINE cnumproducto	char(04);

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
let pparam = 0;

	let cCod_ret = '000000';
    let cMensaje = '';
	let cproceso = '0036';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let pparam  		   = 0;
	LET v_sdo_venc_int_mora   =0;
	LET vpago_min_sin_venc	  =0;
	LET vpago_venc 			  =0;
	LET vsaldo_total 		  =0;
	LET vpago_min 			  =0;
	let vapell_paterno = '';
--	let vcount				=0;
	let iCount_TCO_COMADE   = 0; --A.L.L.
	let i = 0;
	LET num = 0;
	let iCuentasProcesadas  = 0;
	let iCuentasExcluidasXMail = 0;
	let P_COD_RET   = '000000';
	let P_MENSAJE   ='El proceso de las campañas EMAIL TCO COMP CON ADEUDO se realizó correctamente.';
	let cnumproducto = '';


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

--SET DEBUG FILE TO 'sp_mail_compconadeudo.out';
--TRACE ON;

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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '02') RETURNING cCod_ret;
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

	let pfechaarmada = date (pfechacorte) -  1 units day;
	--let pfechaarmada = '05-10-2016';--'01-12-2012'; --prueba

		
	set isolation to dirty read;
	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;	
		
			select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

	set isolation to dirty read;
	
	let i = 0;
		LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TCO_COMADE',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
				let num = num + 10;
	end for
		
	foreach 
    SELECT a.num_credito, a.numcte,  d.fecha_compac, d.importe, d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcredito, pnumcte,  pfechacompac, pimporte, pfechapago, pflagpago, cnumproducto
    FROM bdicred:sd_maecred a,  bdicobranza:cb_compac_his d, bdicred:sd_maesdos c
     WHERE  a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '8100' and a.num_credito =c.num_credito
	    and a.status_cred in ('BT','BA','E1','E2','E3')
		AND (c.monto_vencido + c.mto_venc_trasp) > 0
        AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 1 
        AND nvl(d.imp_pagado,0) > 0
		and d.importe > d.imp_pagado  

	let iCuentasProcesadas = iCuentasProcesadas + 1;
	
	select limit 1 cte.correo_elec into pemail 
	from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
							and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
	where empresa  = '001' and numcte = pnumcte and status_correo ='A');
	
	 if pemail is null or pemail = '' then 
            let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
            CONTINUE foreach; 
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
		
		let pimporte = round(pimporte)	+1;

		LET iCount_TCO_COMADE = iCount_TCO_COMADE +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'TCO_COMADE' , pnumcte, pnumcredito,vnumtarjeta, 2,
							vapell_paterno,'','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;
		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1028, pnumcredito, pnumcte, cNumProducto, today, pemail, '','',pimporte) returning P_COD_RET;

	let P_COD_RET = '000000';
	end foreach
    let P_COD_RET = '000000';  	

	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_COMADE',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCO_COMADE : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_TCO_COMADE;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
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
CREATE PROCEDURE "informix".sp_mail_reestructu_mora_baja(pempresa char (3), pfechacorte date)
returning 
--VARCHAR(6);
CHAR(06)  AS codigo_retorno,
CHAR(80)  AS mensaje_retorno;

DEFINE pnumcredito  char(20);
DEFINE pnumcte      char(20);
DEFINE pmail        char (60);
DEFINE pmesvencido  smallint;
DEFINE pfechahoy    datetime year to second;
define vnumtarjeta  char(20);
define pparam       smallint;
 
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
DEFINE vapell_paterno       char(30);
--define vcount			integer;
DEFINE iCount_RESB_MORAS    integer; --A.L.L.
DEFINE iCount_RESTB_MORA2   integer; --A.L.L.
DEFINE vvalor               smallint;
DEFINE i                    integer;
DEFINE num                  smallint;
DEFINE iCuentasProcesadas   integer;
DEFINE iCuentasExcluidasXMail integer;
  
  
let pnumcte             = '';
let pnumcredito         = '';
let pmail               = '';
LET vnumtarjeta         = '';
let pfechahoy           = DATE(1);
let pmesvencido         = 0;
let vsaldo_total 		= 0;
let v_sdo_venc_int_mora = 0;
let vpago_minimo_total  = 0;
let v_pago_min_sin_vdo  = 0;
let vpago_vencido       = 0;
--  let P_COD_RET = '111111';
let P_COD_RET           = "000000";
let P_MENSAJE           = 'El proceso de la campaña EMAIL MORA REESTRUCTURAS BAJA se realizó correctamente.';
let cCod_ret            = '000000';
let cMensaje            = '';
let cproceso            = '2044';
let SQL_ERR             = 0;
let ISAM_ERR            = 0;
let ERROR_INFO          = '';
let pparam              = 0;
let vapell_paterno      = '';
--  let vcount = 0;
let iCount_RESB_MORAS   = 0; --A.L.L.
let iCount_RESTB_MORA2  = 0; --A.L.L.
let i   = 0;
LET num = 0;
let iCuentasProcesadas  = 0;
let iCuentasExcluidasXMail = 0;

BEGIN
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '02') RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        RETURN P_COD_RET,P_MENSAJE;
    END exception ;

--SET DEBUG FILE TO "sp_mail_reestructu_mora_baja.out";
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
		and num_parametro = 1;
*/		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
/*
    if (pparam = 0) then
        if (ppagosvencidos = 0) then
            delete from bdicobranza:cb_mail_cliente where empresa = pempresa and fecha_insert = pfechahoy and tipo_mensaje = 4 and pagos_vencidos > 0;
        end if;
        if (ppagosvencidos > 0) then
            delete from bdicobranza:cb_mail_cliente where empresa = pempresa and  fecha_insert = pfechahoy and tipo_mensaje = 4 and pagos_vencidos = ppagosvencidos;
        end if;
    end if;
 */
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
        LET cCod_Ret= '101010';        
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01') RETURNING P_COD_RET;
        RETURN P_COD_RET,P_MENSAJE;
    END IF;*/
--let   pfechacorte = '06-18-2010';--'05-18-2012';	
	set isolation to dirty read;
	
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,fecha1,fecha2)
		select  1, 'RESB_MORAS',numcte,current,1,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
/*	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'RESTB_MORA2',numcte,1,current,apell_paterno,0,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));*/
		let num = num + 10;
	end for
		
	foreach
		SELECT  a.num_credito, a.numcte, b.mto_fin_ven_trasp
		INTO  pnumcredito, pnumcte, pmesvencido
		FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
		WHERE a.empresa = pempresa
            and b.num_credito >= ''
            AND b.empresa = a.empresa
            and b.num_credito = a.num_credito
            AND c.empresa = a.empresa
            and c.num_credito = a.num_credito
            AND a.status_cred in ('BT','VP','BA','E1','E2','E2') 
			AND (b.monto_vencido + b.mto_venc_trasp) > 0
			and b.mto_fin_ven_trasp >= 1	
			and a.num_producto = '6011'
			and a.campo_trab3 = 'BAJA'
            and c.dia_corte = day(pfechacorte)

        let iCuentasProcesadas = iCuentasProcesadas + 1;

        let pmail = '';

		select limit 1 cte.correo_elec into pmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
							and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
		where empresa  = '001' and numcte = pnumcte and status_correo ='A');	

        if pmail is null or pmail = '' then 
            let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
            CONTINUE foreach; 
        end if;

/*		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;
		
		select 	(car.sdo_cap_insoluto + car.sdo_intereses + car.interes_iva + car.moratorio ),
			 (car.monto_vencido + car.mto_venc_trasp + car.moratorio + car.interes_iva) ,
			 (car.monto_financiado + car.interes_iva + car.moratorio), car.monto_financiado, 
			 car.monto_vencido + car.mto_venc_trasp
			 into  vsaldo_total, v_sdo_venc_int_mora,vpago_minimo_total,
				v_pago_min_sin_vdo,vpago_vencido 
			 from  bdicred:"informix".sd_sdos_cartera_linea car
			 where car.num_credito = pnumcredito;
*/		
		let vnumtarjeta = '';

--        if (pmail <> '') then   
/*                if (pparam = 0) then
                call "informix".sp_mail_inserta_cliente (pempresa,4,pnumcte,pnumcredito, pmail,0,0,pmesvencido,0,null,null,null,
                                                        0,0,vpago_vencido,v_pago_min_sin_vdo,v_sdo_venc_int_mora)
                  RETURNING P_COD_RET; 
                end if;*/

                --A.L.L.
                LET iCount_RESB_MORAS = iCount_RESB_MORAS +1;
                call bdimnsj:"informix".sp_registra_evento (1, 'RESB_MORAS' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                    pmesvencido,'','','','',0,0,0,0,0, today, '')RETURNING P_COD_RET; 
--    	end if;	
    end foreach

	--A.L.L.
	IF iCount_RESB_MORAS > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('RESB_MORAS',iCount_RESB_MORAS) RETURNING P_COD_RET;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('RESB_MORAS',iCount_RESB_MORAS,null) RETURNING P_COD_RET;
	END IF;

--Genera cifras de control
    if iCuentasProcesadas > 0 or iCuentasExcluidasXMail > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña RESB_MORAS : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_RESB_MORAS;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
--       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
--       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '03') RETURNING P_COD_RET;

     if P_COD_RET != '000000' then
--        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.

end
--  RETURN P_COD_RET;
END PROCEDURE;
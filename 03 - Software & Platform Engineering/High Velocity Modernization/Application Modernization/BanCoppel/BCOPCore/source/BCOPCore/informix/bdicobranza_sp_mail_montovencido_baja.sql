CREATE PROCEDURE "informix".sp_mail_montovencido_baja(pempresa char (3))
returning --VARCHAR(6);
CHAR(06)  AS codigo_retorno,
CHAR(80)  AS mensaje_retorno;

DEFINE pnumcredito        char(20);
DEFINE pnumcte            char(20);
DEFINE pmail              char(60);
DEFINE pmesvencido        smallint;
DEFINE pfechahoy          DATE;
DEFINE pmtofin            DECIMAL(18,2);
DEFINE vexiste            CHAR(20);
DEFINE vnum               CHAR(20);
define vnumtarjeta        char(20);
define vvencido           DECIMAL(18,2);
 
DEFINE cProceso           char(4);
DEFINE cCod_ret           CHAR(6);
DEFINE cMensaje           char (150);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);

--tabla historica
define  ctipo_mensaje    	SMALLINT;
define  cfecha_insert    	DATE;
define  cnumcte          	CHAR(20);
define  cnum_credito     	CHAR(20);
define  cemail           	CHAR(60);
define  cpago_minimo     	DECIMAL(18,2);
define  csaldo_total     	DECIMAL(18,2);
define  cpagos_vencidos  	DECIMAL(18,2);
define  cmonto_convenio  	DECIMAL(18,2);

define  mtoVencido			DECIMAL(18,2);
define  mtoInteres			DECIMAL(18,2); 
define  mtoMoratorio		DECIMAL(18,2);
define  vltasa_moratorios  	DECIMAL(9,6);
define  pparam  			Smallint;
define  vpago_venc  		DECIMAL(18,2);
define  vpago_min_sin_venc 	DECIMAL(18,2);   
define  v_sdo_venc_int_mora DECIMAL(18,2);


define  cfecha_convenio  	DATE;
define  cfecha_compac    	DATE;
define  cfecha_primercons	DATE;
define  cestatus         	CHAR(2);
define  cenviado         	SMALLINT;
define  ccumplio_compac  	SMALLINT;
DEFINE iCel                 CHAR(13);
DEFINE cCel                 CHAR(13);
DEFINE cNomEstado			CHAR(2);
DEFINE cNomCiudad			CHAR(3);
DEFINE cNumCarrier		 CHAR(3);
DEFINE cNombre1			 CHAR(26);
DEFINE cNombre2	 		 CHAR(26);
DEFINE cApellPat	 	 CHAR(26);
DEFINE cApellMat		 CHAR(26);
DEFINE cSituacion		 CHAR(1);
DEFINE iCausa			 INTEGER;
DEFINE cTipoRed			 CHAR(10);
DEFINE cCodRet2			 CHAR(6);
DEFINE vsaldo_total		 DECIMAL(18,2);
DEFINE vmonto_vencido    DECIMAL(18,2);
DEFINE vapell_paterno	 char(30);
DEFINE vfecha_ant		 date;
DEFINE vcount 			 integer;
DEFINE vvalor            smallint;
DEFINE i                 integer;
DEFINE num               smallint;
DEFINE iCount_TCB_MORAS	 integer;
DEFINE iCount_TCB_MORA2	 integer;
DEFINE iCount_TCB_MORA3	 integer;
DEFINE iCount_TCB_MORA4	 integer;
DEFINE iCount_TCB_MORA5	 integer;
DEFINE iCuentasProcesadas     integer;
DEFINE iCuentasExcluidasXMail integer;
DEFINE iCuentasExcluidasXSdosVencidos integer;
DEFINE dFechaCarLinea   date;

let P_COD_RET   = '000000';
let cCod_ret    = '000000';
let cMensaje    = '';
let cproceso    = '2041';
let SQL_ERR		=0;
let ISAM_ERR	=0;
let ERROR_INFO	= '';
let P_MENSAJE   = 'El proceso de las campañas EMAIL MORAS TDC BAJA se realizó correctamente.';
let pnumcredito = '';
let pnumcte     = '';
let pmail       = '';
let pmesvencido =0;
let pfechahoy   = DATE(1);
let pmtofin     =0;  
let vexiste     = '';
let vnum 		= '';
let vnumtarjeta = '';
let vvencido	=0;
  
let  ctipo_mensaje    	=0;
let  cfecha_insert    	= DATE(1);
let  cnumcte          	= '';
let  cnum_credito     	= '';
let  cemail           	= '';
let  cpago_minimo     	=0;
let  csaldo_total     	=0;
let  cpagos_vencidos  	=0;
let  cmonto_convenio  	=0;
let  cfecha_convenio  	= DATE(1);
let  cfecha_compac    	= DATE(1);
let  cfecha_primercons	= DATE(1);
let  cestatus         	= '';
let  cenviado         	=0;
let  ccumplio_compac  	=0;
let iCel				= '';
let cCel				= '';
let cNomEstado			= '';
let cNomCiudad			= '';
let cNumCarrier         = '';
let cNombre1            = ''; 
let cNombre2            = '';
let cApellPat           = '';
let cApellMat           = '';
let cSituacion          = '';
let iCausa              = 0;
let cTipoRed            = '';
let cCodRet2            = '';
let  vpago_venc  		= 0;
let  vpago_min_sin_venc = 0;
let  v_sdo_venc_int_mora= 0;
let vmonto_vencido      = 0;

let mtoVencido          = 0;
let mtoInteres          = 0; 
let mtoMoratorio        = 0;
let vltasa_moratorios   = 0;
let pparam              = 0;
let vapell_paterno      = '';
let vfecha_ant          = date(1);
let vcount              = 0;
let i                   = 0;
let num                 = 0;
let iCount_TCB_MORAS	= 0;
let iCount_TCB_MORA2	= 0;
let iCount_TCB_MORA3	= 0;
let iCount_TCB_MORA4	= 0;
let iCount_TCB_MORA5	= 0;
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXSdosVencidos = 0;
let dFechaCarLinea = date(1);

BEGIN
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '02')
         RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        RETURN P_COD_RET,P_MENSAJE;
    END exception;
--SET DEBUG FILE TO 'moras.out';
--TRACE ON;
	Select Fecha_Hoy , fecha_ant
      Into pfechahoy ,vfecha_ant
	  From bdicred:sd_fechas
	  Where empresa = pempresa ;
	  
--let pfechahoy = mdy('10','27','2014');
--let vfecha_ant = mdy('10','26','2014');

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
--	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1,fecha1,fecha2)
--		select  1, 'TCB_MORAS',numcte,1,current,apell_paterno,100,current,current
		select  1, 'TCB_MORAS',numcte,current,2,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));

	let num = num + 10;
	end for

	delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos <= 5;
	
/*	if	(pparam = 0)	then
		if (ppagosvencidos = 0) then
		  delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos < 30;
	    end if;
		if (ppagosvencidos > 0) then
			delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos = ppagosvencidos;
		end if;
	end if;*/

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso , cCod_ret, cMensaje, '01')RETURNING P_COD_RET;

    --valida parametros
    IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        LET cMensaje ='Falta Parametro de Empresa';
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        let P_COD_RET = cCod_Ret;
        let P_MENSAJE  = cMensaje;
        RETURN P_COD_RET,P_MENSAJE;
    END IF;


{		select a.num_credito, a.numcte,  cl.mto_venc_trasp, cl.interes_iva, cl.moratorio, cl.num_tarjeta,a.tasa_moratorios,
		(cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
		,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) /*MtoVencido1*/,
		cl.mensualidad_actual   ,
		cl.monto_vencido + cl.mto_venc_trasp  , cl.mto_fin_ven_trasp,cl.monto_vencido
			into pnumcredito, pnumcte, mtoVencido, mtoInteres, mtoMoratorio, vnumtarjeta, vltasa_moratorios,
				 vsaldo_total, 
				v_sdo_venc_int_mora,
				vpago_min_sin_venc	,
				vpago_venc ,pmesvencido,vmonto_vencido
		FROM bdicred:sd_maecred a,
			 bdicred:sd_sdos_cartera_linea cl,
			 bdicred:sd_maesdos c
		WHERE a.empresa = pempresa
        and a.num_credito >= ''
		and cl.fecha = vfecha_ant
        and cl.num_credito = a.num_credito
		and c.empresa = pempresa
		and c.num_credito = a.num_credito
		and a.status_cred in ('BT','BA','E1','E2','E3') 
		and a.campo_trab3 = 'BAJA' }

	FOREACH
        select a.num_credito, a.numcte, a.tasa_moratorios
          into pnumcredito, pnumcte, vltasa_moratorios
        FROM bdicred:sd_maecred a
		JOIN bdicred:sd_maesdos c ON (a.num_credito = c.num_credito)
        WHERE a.empresa = pempresa
          and a.num_credito >= ''
		  and a.num_producto = '6001'
          and a.status_cred in ('BT','BA','E1','E2','E3')
		  and (c.monto_vencido + c.mto_venc_trasp) > 0
          and a.campo_trab3 = 'BAJA'
        
        let pmail = '';
        let iCuentasProcesadas = iCuentasProcesadas + 1;

    	select cl.fecha,cl.mto_venc_trasp + cl.monto_vencido, cl.interes_iva, cl.moratorio, cl.num_tarjeta,
		(cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
		,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) /*MtoVencido1*/,
		cl.mensualidad_actual   ,
		cl.monto_vencido + cl.mto_venc_trasp  , cl.mto_fin_ven_trasp,cl.monto_vencido
			into dFechaCarLinea,mtoVencido, mtoInteres, mtoMoratorio, vnumtarjeta, 
				 vsaldo_total, v_sdo_venc_int_mora, vpago_min_sin_venc, vpago_venc, pmesvencido, vmonto_vencido
		FROM bdicred:sd_sdos_cartera_linea cl
		WHERE cl.num_credito = pnumcredito;

        if dFechaCarLinea is null or dFechaCarLinea = '' then 
           let iCuentasExcluidasXSdosVencidos = iCuentasExcluidasXSdosVencidos + 1;
           continue foreach; 
        end if;

		select limit 1 cte.correo_elec into pmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
		and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = pnumcte and status_correo ='A');	

        if pmail is null or pmail = '' then 
           let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
           continue foreach; 
        end if;

/*		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;*/

--        if (pmail <> '') then	  
            let pmtofin = (((mtoVencido *  vltasa_moratorios)/36000) * 17.25) + mtoVencido + mtoInteres + mtoMoratorio;
            let pmtofin = (round(pmtofin)+1); --  + vmonto_vencido;
/*            if (pparam = 0) then 
                call "informix".sp_mail_inserta_cliente (pempresa,1,pnumcte,pnumcredito, pmail,pmtofin,vsaldo_total,pmesvencido,0,null,null,null,0,0,
                                                        vpago_venc,vpago_min_sin_venc,v_sdo_venc_int_mora	)
                RETURNING P_COD_RET;   
            end if;*/

--            if (pmesvencido >= 1)then
                let iCount_TCB_MORAS	  = iCount_TCB_MORAS + 1;
                call bdimnsj:"informix".sp_registra_evento (1, 'TCB_MORAS' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                pmesvencido,'','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
--            end if;
--        end if;
    end foreach
	
    if iCount_TCB_MORAS > 0 then
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCB_MORAS',iCount_TCB_MORAS) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCB_MORAS',iCount_TCB_MORAS,null) RETURNING P_COD_RET;
    end if;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCB_MORAS : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORAS: ' ||iCount_TCB_MORAS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = '    Cuentas excluidas por error saldos vencidos : ' ||iCuentasExcluidasXSdosVencidos;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;

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
	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
END PROCEDURE;
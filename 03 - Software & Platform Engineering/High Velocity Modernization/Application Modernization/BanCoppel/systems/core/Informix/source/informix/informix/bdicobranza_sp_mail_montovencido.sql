CREATE PROCEDURE "informix".sp_mail_montovencido(pempresa char (3))
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

--    execute procedure "informix".sp_mail_montovencido('001',0)
 
DEFINE pnumcredito  char(20);
DEFINE pnumcte      char(20);
DEFINE pmail        char (60);
DEFINE pmesvencido  smallint;
DEFINE pfechahoy    DATE;
DEFINE pmtofin      DECIMAL(18,2);
DEFINE vexiste      CHAR(20);
DEFINE vnum         CHAR(20);
define vnumtarjeta  char(20);
define vvencido 	DECIMAL(18,2);
 
DEFINE cProceso     char(4);
DEFINE cCod_ret     CHAR(6);
DEFINE cMensaje     char (100);
DEFINE SQL_ERR      INTEGER;
DEFINE ISAM_ERR     INTEGER;
DEFINE ERROR_INFO   VARCHAR(80);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(80);

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
define  vpago_min_sin_venc  DECIMAL(18,2);   
define  v_sdo_venc_int_mora DECIMAL(18,2);


define  cfecha_convenio  	DATE;
define  cfecha_compac    	DATE;
define  cfecha_primercons	DATE;
define  cestatus         	CHAR(2);
define  cenviado         	SMALLINT;
define  ccumplio_compac  	SMALLINT;
DEFINE iCel				CHAR(13);
DEFINE cCel				CHAR(13);
DEFINE cNomEstado		CHAR(2);
DEFINE cNomCiudad		CHAR(3);
DEFINE cNumCarrier		CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE vsaldo_total		DECIMAL(18,2);
define vmonto_vencido   DECIMAL(18,2);
define vapell_paterno	char(30);
define vfecha_ant		date;
define vcount 			integer;
define vvalor           smallint;
define i                integer;
define num              smallint;
define iCount_TC_MORA1	integer;
define iCount_TC_MORA2	integer;
define iCount_TC_MORA3	integer;
define iCount_TC_MORA4	integer;
define iCount_TC_MORA5	integer;
DEFINE iCuentasProcesadas     integer;
--DEFINE iCuentasExcluidasXMail integer;
DEFINE iCuentasExcluidasXMail_TC_MORA1 integer;
DEFINE iCuentasExcluidasXMail_TC_MORA2 integer;
DEFINE iCuentasExcluidasXMail_TC_MORA3 integer;
DEFINE iCuentasExcluidasXMail_TC_MORA4 integer;
DEFINE iCuentasExcluidasXMail_TC_MORA5 integer;
DEFINE iCuentasExcluidasXSdosVencidos integer;
DEFINE dFechaCarLinea   date;
DEFINE iOtrasExclusiones integer;
DEFINE sCampana			smallint;
DEFINE cNumProducto		char(04);
DEFINE iCuentasProcesadas_TC_MORA1  integer;
DEFINE iCuentasProcesadas_TC_MORA2  integer;
DEFINE iCuentasProcesadas_TC_MORA3  integer;
DEFINE iCuentasProcesadas_TC_MORA4  integer;
DEFINE iCuentasProcesadas_TC_MORA5  integer;

let P_COD_RET   = '000000';
let P_MENSAJE   ='El proceso de las campañas EMAIL MORAS TDC se realizó correctamente.';
let cCod_ret    = '000000';
let cMensaje    = '';
let cproceso    = '2020';
let SQL_ERR		=0;
let ISAM_ERR	=0;
let ERROR_INFO	= '';
let pnumcredito   = '';
let pnumcte       = '';
let pmail         = '';
let pmesvencido   =0;
let pfechahoy     = DATE(1);
let pmtofin       =0;  
let vexiste       = '';
let vnum 		  = '';
let vnumtarjeta   = '';
let vvencido	  =0;
  
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
let cNumCarrier		= '';
let cNombre1		= ''; 
let cNombre2		= '';
let cApellPat		= '';
let cApellMat		= '';
let cSituacion		= '';
let iCausa			=0;
let cTipoRed		= '';
let cCodRet2		= '';
let  vpago_venc  		=0;
let  vpago_min_sin_venc 	=0;
let  v_sdo_venc_int_mora 	=0;
let vmonto_vencido =0;

let mtoVencido	=0;
let mtoInteres	=0; 
let mtoMoratorio	=0;
let vltasa_moratorios = 0;
let pparam = 0;
let vapell_paterno = '';
let vfecha_ant = date(1);
let vcount = 0;
let i = 0;
LET num = 0;
let iCount_TC_MORA1	  = 0;
let iCount_TC_MORA2	  = 0;
let iCount_TC_MORA3	  = 0;
let iCount_TC_MORA4	  = 0;
let iCount_TC_MORA5	  = 0;
let iCuentasProcesadas      = 0;
--let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXMail_TC_MORA1  = 0;
let iCuentasExcluidasXMail_TC_MORA2  = 0;
let iCuentasExcluidasXMail_TC_MORA3  = 0;
let iCuentasExcluidasXMail_TC_MORA4  = 0;
let iCuentasExcluidasXMail_TC_MORA5  = 0;
let iCuentasExcluidasXSdosVencidos = 0;
let dFechaCarLinea = date(1);
let iOtrasExclusiones = 0;
let sCampana		  = 0;
let cNumProducto 	  = '';
let iCuentasProcesadas_TC_MORA1 = 0;
let iCuentasProcesadas_TC_MORA2 = 0;
let iCuentasProcesadas_TC_MORA3 = 0;
let iCuentasProcesadas_TC_MORA4 = 0;
let iCuentasProcesadas_TC_MORA5 = 0;


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

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso , cCod_ret, cMensaje, '01')RETURNING P_COD_RET;

     if P_COD_RET != '000000' then
--        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	Select Fecha_Hoy , fecha_ant
      Into pfechahoy ,vfecha_ant
	  From bdicred:sd_fechas
	  Where empresa = pempresa ;

--let pfechahoy = mdy('02','23','2015');
--let vfecha_ant = mdy('02','22','2015');

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
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,importe1,fecha1,fecha2)
		select  1, 'TC_MORA1',numcte,current,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,importe1,fecha1,fecha2)
		select  1, 'TC_MORA2',numcte,current,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,importe1,fecha1,fecha2)
		select  1, 'TC_MORA3',numcte,current,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,importe1,fecha1,fecha2)
		select  1, 'TC_MORA4',numcte,current,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,importe1,fecha1,fecha2)
		select  1, 'TC_MORA5',numcte,current,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        let num = num + 10;
	end for

--	delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos <= 5;

/*	if	(pparam = 0) then
		if (ppagosvencidos = 0) then
		  delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos < 30;
	    end if;
		if (ppagosvencidos > 0) then
			delete from bdicobranza:cb_mail_cliente where fecha_insert = pfechahoy and tipo_mensaje = 1 and pagos_vencidos = ppagosvencidos;
		end if;
	end if;*/
  

    --valida parametros
    IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        LET cMensaje ='Falta Parametro de Empresa';
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        LET P_COD_RET= '104002';
        LET P_MENSAJE ='Falta Parametro de Empresa';
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
		and c.num_credito = a.num_credito
		and a.status_cred in ('BT','BA','E1','E2','E3')
		and (c.monto_vencido + c.mto_venc_trasp) > 0
		and a.campo_trab3 <> 'BAJA' }

	Foreach
		select a.num_credito, a.numcte, a.tasa_moratorios, a.num_producto
		  into pnumcredito, pnumcte, mtoVencido, cNumProducto
		FROM bdicred:sd_maecred a
        inner join bdicred:sd_maesdos b on b.empresa=a.empresa and b.num_credito=a.num_credito and b.mto_fin_ven_trasp between 1 and 5
		WHERE a.empresa = pempresa
        and a.num_credito >= ''
		and a.num_producto = '6001'
		and a.status_cred in ('BT','BA','E1','E2','E3')
		and (b.monto_vencido + b.mto_venc_trasp) > 0
		and a.campo_trab3 <> 'BAJA'

        let pmail = '';
        let iCuentasProcesadas = iCuentasProcesadas + 1;

		select cl.fecha, cl.mto_venc_trasp + cl.monto_vencido, cl.interes_iva, cl.moratorio, cl.num_tarjeta,
            (cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
            ,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) /*MtoVencido1*/,
            cl.mensualidad_actual   ,
            cl.monto_vencido + cl.mto_venc_trasp  , cl.mto_fin_ven_trasp,cl.monto_vencido
			into dFechaCarLinea, mtoVencido, mtoInteres, mtoMoratorio, vnumtarjeta, 
				 vsaldo_total, v_sdo_venc_int_mora, vpago_min_sin_venc, vpago_venc ,pmesvencido,vmonto_vencido
		FROM bdicred:sd_sdos_cartera_linea cl
		WHERE cl.num_credito = pnumcredito;
		
        if dFechaCarLinea is null or dFechaCarLinea = '' then 
           let iCuentasExcluidasXSdosVencidos = iCuentasExcluidasXSdosVencidos + 1;
--           continue foreach; 
        end if;

		select limit 1 cte.correo_elec into pmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
		and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = pnumcte and status_correo ='A');	

/*        if pmail is null or pmail = '' then 
           let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
           continue foreach; 
        end if;*/

/*		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;*/
	
--        if (pmail <> '') then	  
            let pmtofin = (((mtoVencido *  vltasa_moratorios)/36000) * 17.25) + mtoVencido + mtoInteres + mtoMoratorio;
            let pmtofin = (round(pmtofin)+1); -- + vmonto_vencido;
            --if (pparam = 0) then    A.L.L. Se elimina condicion
                --call "informix".sp_mail_inserta_cliente (pempresa,1,pnumcte,pnumcredito, pmail,pmtofin,vsaldo_total,pmesvencido,0,null,null,null,0,0,
                                                       -- vpago_venc,vpago_min_sin_venc,v_sdo_venc_int_mora	)
                --RETURNING P_COD_RET;		
            --end if;

            if (pmesvencido = 1) then
                let iCuentasProcesadas_TC_MORA1 = iCuentasProcesadas_TC_MORA1 + 1;

                if pmail is null or pmail = '' then 
                   let iCuentasExcluidasXMail_TC_MORA1 = iCuentasExcluidasXMail_TC_MORA1 + 1;
                   continue foreach; 
                end if;
                let iCount_TC_MORA1	  = iCount_TC_MORA1 + 1;
                let sCampana = 1004;
                call bdimnsj:"informix".sp_registra_evento (1, 'TC_MORA1' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
            elif (pmesvencido = 2) then
                let iCuentasProcesadas_TC_MORA2 = iCuentasProcesadas_TC_MORA2 + 1;

                if pmail is null or pmail = '' then 
                   let iCuentasExcluidasXMail_TC_MORA2 = iCuentasExcluidasXMail_TC_MORA2 + 1;
                   continue foreach; 
                end if;
                let iCount_TC_MORA2	  = iCount_TC_MORA2 + 1;
                let sCampana = 1005;
                call bdimnsj:"informix".sp_registra_evento (1, 'TC_MORA2' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
            elif (pmesvencido = 3) then
                let iCuentasProcesadas_TC_MORA3 = iCuentasProcesadas_TC_MORA3 + 1;

                if pmail is null or pmail = '' then 
                   let iCuentasExcluidasXMail_TC_MORA3 = iCuentasExcluidasXMail_TC_MORA3 + 1;
                   continue foreach; 
                end if;
                let iCount_TC_MORA3	  = iCount_TC_MORA3 + 1;
                let sCampana = 1006;
                call bdimnsj:"informix".sp_registra_evento (1, 'TC_MORA3' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
            elif (pmesvencido = 4) then
                let iCuentasProcesadas_TC_MORA4 = iCuentasProcesadas_TC_MORA4 + 1;

                if pmail is null or pmail = '' then 
                   let iCuentasExcluidasXMail_TC_MORA4 = iCuentasExcluidasXMail_TC_MORA4 + 1;
                   continue foreach; 
                end if;
                let iCount_TC_MORA4	  = iCount_TC_MORA4 + 1;
                let sCampana = 1007;
                call bdimnsj:"informix".sp_registra_evento (1, 'TC_MORA4' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',0,0,0,0,0, today, '' )RETURNING P_COD_RET;
            elif (pmesvencido = 5) then
                let iCuentasProcesadas_TC_MORA5 = iCuentasProcesadas_TC_MORA5 + 1;

                if pmail is null or pmail = '' then 
                   let iCuentasExcluidasXMail_TC_MORA5 = iCuentasExcluidasXMail_TC_MORA5 + 1;
                   continue foreach; 
                end if;
                let iCount_TC_MORA5	  = iCount_TC_MORA5 + 1;
                let sCampana = 1008;
                call bdimnsj:"informix".sp_registra_evento (1, 'TC_MORA5' , pnumcte, pnumcredito,vnumtarjeta, 2,
                                '','','','','',0,0,0,0,0, today, '' )RETURNING P_COD_RET;
            else
                let iOtrasExclusiones = iOtrasExclusiones + 1;
				let sCampana = 0;
            end if;
			
			if sCampana > 0 then
				call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',sCampana, pnumcredito, pnumcte, cNumProducto, today,pmail, '','',pmtofin) returning P_COD_RET;
			end if;										
--        end if;
    end foreach

--    if iCount_TC_MORA1 > 0 then
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA1',iCount_TC_MORA1,iCuentasExcluidasXMail_TC_MORA1) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA1',iCuentasProcesadas_TC_MORA1,iCuentasExcluidasXMail_TC_MORA1) RETURNING P_COD_RET;
--    end if;

--    if iCount_TC_MORA2 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA2',iCount_TC_MORA2,iCuentasExcluidasXMail_TC_MORA2) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA2',iCuentasProcesadas_TC_MORA2,iCuentasExcluidasXMail_TC_MORA2) RETURNING P_COD_RET;
--	end if;

--    if iCount_TC_MORA3 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA3',iCount_TC_MORA3,iCuentasExcluidasXMail_TC_MORA3) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA3',iCuentasProcesadas_TC_MORA3,iCuentasExcluidasXMail_TC_MORA3) RETURNING P_COD_RET;
--	end if;

--    if iCount_TC_MORA4 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA4',iCount_TC_MORA4,iCuentasExcluidasXMail_TC_MORA4) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA4',iCuentasProcesadas_TC_MORA4,iCuentasExcluidasXMail_TC_MORA4) RETURNING P_COD_RET;
--	end if;

--    if iCount_TC_MORA5 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA5',iCount_TC_MORA5,iCuentasExcluidasXMail_TC_MORA5) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_MORA5',iCuentasProcesadas_TC_MORA5,iCuentasExcluidasXMail_TC_MORA5) RETURNING P_COD_RET;
--	end if;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_MORAS : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA1: ' ||iCount_TC_MORA1;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'EMAILs enviados MORA2: ' ||iCount_TC_MORA2;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA3: ' ||iCount_TC_MORA3;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'EMAILs enviados MORA4: ' ||iCount_TC_MORA4;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA5: ' ||iCount_TC_MORA5;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = '    Cuentas excluidas por error saldos vencidos : ' ||iCuentasExcluidasXSdosVencidos;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail_TC_MORA1 + iCuentasExcluidasXMail_TC_MORA2 + iCuentasExcluidasXMail_TC_MORA3 + iCuentasExcluidasXMail_TC_MORA4 + iCuentasExcluidasXMail_TC_MORA5;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Otras exclusiones : ' ||iOtrasExclusiones;
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
CREATE PROCEDURE "informix".sp_mail_montovencido_pln(pempresa char (3))
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(150)  AS mensaje_retorno;

--EXECUTE PROCEDURE "informix".sp_mail_montovencido_pln("001");

DEFINE cnumcredito   char(20);
DEFINE pnumcte         char(20);
DEFINE pmail         char (60);
DEFINE pmesvencido   smallint;
DEFINE dfechahoy     DATE;
DEFINE pmtofin        DECIMAL(18,2);
DEFINE vexiste       CHAR(20);
DEFINE vnum CHAR(20);
define vnumtarjeta char(20);
define vvencido 	DECIMAL(18,2);
 
DEFINE cProceso  char(4);
DEFINE cCod_ret  CHAR(6);
DEFINE cMensaje  char (100);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(150);

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


DEFINE  cfecha_convenio  	DATE;
DEFINE  cfecha_compac    	DATE;
DEFINE  cfecha_primercons	DATE;
DEFINE  cestatus         	CHAR(2);
DEFINE  cenviado         	SMALLINT;
DEFINE  ccumplio_compac  	SMALLINT;
DEFINE iCel				CHAR(13);
DEFINE cCel				CHAR(13);
DEFINE cNomEstado			CHAR(2);
DEFINE cNomCiudad			CHAR(3);
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
DEFINE vmonto_vencido   DECIMAL(18,2);
DEFINE vapell_paterno	char(30);
DEFINE dfecha_ant		date;
DEFINE vcount 			integer;
DEFINE vvalor           smallint;
DEFINE i                integer;
DEFINE num              smallint;
DEFINE iCount_TCP_MORA1	 integer;
DEFINE iCount_TCP_MORA2	 integer;
DEFINE iCount_TCP_MORA3	 integer;
DEFINE iCount_TCP_MORA4	 integer;
DEFINE iCount_TCP_MORA5	 integer;
DEFINE iCount_TCP_MORA1S	 integer;
DEFINE iCount_TCP_MORA2S	 integer;
DEFINE iCuentasProcesadas     integer;
DEFINE iCuentasExcluidasXMail integer;
DEFINE iCuentasExcluidasXSdosVencidos integer;
DEFINE dFechaCarLinea       date;
DEFINE iOtrasExclusiones    integer;



let P_COD_RET   = '000000';
let cCod_ret    = '';
let cMensaje    = '';
let cproceso    = '0301';
let SQL_ERR		= 0;
let ISAM_ERR	= 0;
let ERROR_INFO	= '';
let P_MENSAJE	= 'El proceso de las campañas MORAS tarjeta platino se realizó correctamente.';
let cnumcredito = '';
let pnumcte     = '';
let pmail       = '';
let pmesvencido =0;
let dfechahoy   = DATE(1);
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
let dfecha_ant = date(1);
let vcount = 0;
let i = 0;
		LET num = 0;
let iCount_TCP_MORA1	  = 0;
let iCount_TCP_MORA2	  = 0;
let iCount_TCP_MORA3	  = 0;
let iCount_TCP_MORA4	  = 0;
let iCount_TCP_MORA5	  = 0;
let iCount_TCP_MORA1S	  = 0;
let iCount_TCP_MORA2S	  = 0;
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXSdosVencidos = 0;
let dFechaCarLinea = date(1);
let iOtrasExclusiones = 0;


--SET DEBUG FILE TO 'sp_mail_montovencido_pln.out';
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

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, cMensaje, '01') RETURNING cCod_ret;

    if cCod_ret != '000000' then
       let P_COD_RET = cCod_ret;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	Select Fecha_Hoy , fecha_ant
      Into dfechahoy ,dfecha_ant
	  From bdicred:sd_fechas
	  Where empresa = pempresa ;
	  

--let dfechahoy = mdy('09','21','2014');
--let dfecha_ant = mdy('09','20','2014');

	set isolation to dirty read;
	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1; 
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

/*	delete from bdicobranza:cb_mail_cliente where fecha_insert = dfechahoy and tipo_mensaje = 1 and pagos_vencidos <= 5;
	
	if	(pparam = 0)	then
		if (ppagosvencidos = 0) then
		  delete from bdicobranza:cb_mail_cliente where fecha_insert = dfechahoy and tipo_mensaje = 1 and pagos_vencidos < 30;
	    end if;
		if (ppagosvencidos > 0) then
			delete from bdicobranza:cb_mail_cliente where fecha_insert = dfechahoy and tipo_mensaje = 1 and pagos_vencidos = ppagosvencidos;
		end if;
	end if;*/
    
    --valida parametros
    IF NVL (pempresa, '') = '' THEN
        LET P_COD_RET= '104002';
        LET P_MENSAJE ='Falta Parametro de Empresa';
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, P_MENSAJE, '01');
        RETURN P_COD_RET,P_MENSAJE;
    END IF;

{		select a.num_credito, a.numcte,  cl.mto_venc_trasp, cl.interes_iva, cl.moratorio, cl.num_tarjeta,a.tasa_moratorios,
		(cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
		,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) /*MtoVencido1*/,
		cl.mensualidad_actual   ,
		cl.monto_vencido + cl.mto_venc_trasp  , cl.mto_fin_ven_trasp,cl.monto_vencido
			into cnumcredito, pnumcte, mtoVencido, mtoInteres, mtoMoratorio, vnumtarjeta, vltasa_moratorios,
				 vsaldo_total, 
				v_sdo_venc_int_mora,
				vpago_min_sin_venc	,
				vpago_venc ,pmesvencido,vmonto_vencido
		FROM bdicred:sd_maecred a,
			 bdicred:sd_sdos_cartera_linea cl,
			 bdicred:sd_maesdos c
		WHERE a.num_producto = '7000'
		and a.num_credito = cl.num_credito
		and c.empresa = a.empresa
		and c.num_credito = a.num_credito
		and a.status_cred in ('BT','BA') OR (a.status_cred in ('E1','E2','E3') and c.act > 0)
--		and a.campo_trab3 <> 'BAJA'
		and cl.fecha = dfecha_ant }


	Foreach
		SELECT a.num_credito, a.numcte, a.tasa_moratorios
          INTO cnumcredito, pnumcte, vltasa_moratorios
		  FROM bdicred:sd_maecred a,
			   bdicred:sd_maesdos c
		 WHERE a.empresa = pempresa
		   AND a.num_credito >= ''
           AND a.num_producto = '7000'
		   and c.num_credito = a.num_credito
		   AND a.status_cred IN ('BT','BA','E1','E2','E3')
		   AND (c.monto_vencido + c.mto_venc_trasp) > 0

		let pmail = '';
        let iCuentasProcesadas = iCuentasProcesadas + 1;

		SELECT cl.fecha, cl.num_credito, cl.mto_venc_trasp + cl.monto_vencido, cl.interes_iva, cl.moratorio, cl.num_tarjeta,
            (cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) /*SdoTotal1*/
            ,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) /*MtoVencido1*/,
            cl.mensualidad_actual, cl.monto_vencido + cl.mto_venc_trasp  , cl.mto_fin_ven_trasp,cl.monto_vencido
		INTO dFechaCarLinea, cnumcredito, mtoVencido, mtoInteres, mtoMoratorio, vnumtarjeta, 
			 vsaldo_total, v_sdo_venc_int_mora, vpago_min_sin_venc, vpago_venc ,pmesvencido,vmonto_vencido
		FROM bdicred:sd_sdos_cartera_linea cl
		WHERE cl.fecha = dfecha_ant
		AND cl.num_credito = cnumcredito;

		IF dFechaCarLinea IS NULL OR dFechaCarLinea = '' THEN
            LET iCuentasExcluidasXSdosVencidos = iCuentasExcluidasXSdosVencidos + 1;
    		CONTINUE foreach;
		END IF;

/*		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = pnumcte ;*/
		
	  
		select limit 1 cte.correo_elec into pmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
		and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = pnumcte and status_correo ='A');

		if pmail is null or pmail = '' then 
           let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
           continue foreach; 
        end if;
	
	--if (pmail <> '') then	  
		let pmtofin = (((mtoVencido *  vltasa_moratorios)/36000) * 17.25) + mtoVencido + mtoInteres + mtoMoratorio;
	    let pmtofin = (round(pmtofin)+1); -- + vmonto_vencido;
/*	    if (pparam = 0) then 
			call "informix".sp_mail_inserta_cliente (pempresa,1,pnumcte,cnumcredito, pmail,pmtofin,vsaldo_total,pmesvencido,0,null,null,null,0,0,
													vpago_venc,vpago_min_sin_venc,v_sdo_venc_int_mora	)
            RETURNING P_COD_RET;   
		end if;*/

		if (pmesvencido = 1)then
            let iCount_TCP_MORA1	  = iCount_TCP_MORA1 + 1;
			call bdimnsj:"informix".sp_registra_evento (1, 'TCP_MORA1' , pnumcte, cnumcredito,vnumtarjeta, 2,
							'','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
            if day(dfechahoy) >= 19 and day(dfechahoy) < 26 then
                let iCount_TCP_MORA1S	  = iCount_TCP_MORA1S + 1;
                call bdimnsj:"informix".sp_registra_evento (2, 'TCP_MORA1S' , cNumCte, cnumcredito,vnumtarjeta, 2,
                                '',0,0,'','',pmtofin,0,0,0,0, '', '')RETURNING P_COD_RET;
            end if;
		elif (pmesvencido = 2)then
            let iCount_TCP_MORA2	  = iCount_TCP_MORA2 + 1;
			call bdimnsj:"informix".sp_registra_evento (1, 'TCP_MORA2' , pnumcte, cnumcredito,vnumtarjeta, 2,
							'','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
            if day(dfechahoy) >= 19 and day(dfechahoy) < 26 then
                let iCount_TCP_MORA2S	  = iCount_TCP_MORA2S + 1;
                call bdimnsj:"informix".sp_registra_evento (2, 'TCP_MORA2S' , cNumCte, cnumcredito,vnumtarjeta, 2,
                                '',0,0,'','',pmtofin,0,0,0,0, '', '')RETURNING P_COD_RET;
            end if;
		elif (pmesvencido = 3)then
            let iCount_TCP_MORA3	  = iCount_TCP_MORA3 + 1;
			call bdimnsj:"informix".sp_registra_evento (1, 'TCP_MORA3' , pnumcte, cnumcredito,vnumtarjeta, 2,
							'','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
		elif (pmesvencido = 4)then
            let iCount_TCP_MORA4	  = iCount_TCP_MORA4 + 1;
			call bdimnsj:"informix".sp_registra_evento (1, 'TCP_MORA4' , pnumcte, cnumcredito,vnumtarjeta, 2,
							'','','','','',0,0,0,0,0, today, '' )RETURNING P_COD_RET;
		elif (pmesvencido >= 5)then
            let iCount_TCP_MORA5	  = iCount_TCP_MORA5 + 1;
			call bdimnsj:"informix".sp_registra_evento (1, 'TCP_MORA5' , pnumcte, cnumcredito,vnumtarjeta, 2,
							'','','','','',pmtofin,0,0,0,0, today, '' )RETURNING P_COD_RET;
		ELSE
    		let iOtrasExclusiones = iOtrasExclusiones + 1;
		end if;	
    end foreach

    if iCount_TCP_MORA1 > 0 then
--      CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA1',iCount_TCP_MORA1) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA1',iCount_TCP_MORA1,null) RETURNING P_COD_RET;
    end if;

    if iCount_TCP_MORA2 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA2',iCount_TCP_MORA2) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA2',iCount_TCP_MORA2,null) RETURNING P_COD_RET;
	end if;

    if iCount_TCP_MORA3 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA3',iCount_TCP_MORA3) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA3',iCount_TCP_MORA3,null) RETURNING P_COD_RET;
	end if;

    if iCount_TCP_MORA4 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA4',iCount_TCP_MORA4) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA4',iCount_TCP_MORA4,null) RETURNING P_COD_RET;
	end if;

    if iCount_TCP_MORA5 > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA5',iCount_TCP_MORA5) RETURNING P_COD_RET;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_MORA5',iCount_TCP_MORA5,null) RETURNING P_COD_RET;
	end if;

	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCP_MORAS : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA1 : ' ||iCount_TCP_MORA1;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'EMAILs enviados MORA2 : ' ||iCount_TCP_MORA2;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA3 : ' ||iCount_TCP_MORA3;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'EMAILs enviados MORA4 : ' ||iCount_TCP_MORA4;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORA5 : ' ||iCount_TCP_MORA5;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       if day(dfechahoy) >= 19 and day(dfechahoy) < 26 then
           let cMensaje = 'SMSs enviados MORA1 : ' ||iCount_TCP_MORA1S;
           let cMensaje = trim(cMensaje) ||'    SMSs enviados MORA2 : ' ||iCount_TCP_MORA2S;
           CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       end if;
       let cMensaje = 'Cuentas excluidas por error saldos vencidos : ' ||iCuentasExcluidasXSdosVencidos;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Otras exclusiones : ' ||iOtrasExclusiones;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
	
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA1',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA2',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA3',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA4',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA5',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        if day(dfechahoy) >= 19 and day(dfechahoy) < 26 then
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA1S',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'TCP_MORA2S',numcte,'',current,'',100,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
        end if;
        let num = num + 10;
	end for

  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, cMensaje, '03') RETURNING cCod_ret;

    if cCod_ret != '000000' then
       let P_COD_RET = cCod_ret;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.

end
--  RETURN P_COD_RET;
END PROCEDURE;
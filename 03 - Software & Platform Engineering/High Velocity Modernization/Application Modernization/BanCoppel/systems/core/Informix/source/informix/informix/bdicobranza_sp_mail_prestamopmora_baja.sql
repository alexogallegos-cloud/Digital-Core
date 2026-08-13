CREATE PROCEDURE "informix".sp_mail_prestamopmora_baja(pempresa char(3) )
RETURNING 	
--CHAR(5)  AS codigo_retorno;			
CHAR(06)  AS codigo_retorno,
CHAR(150)  AS mensaje_retorno;

--   execute PROCEDURE "informix".sp_mail_prestamopmora_baja('001')		
---DECLARACIONES
DEFINE cCodRet        	CHAR(6); 
DEFINE iSqlErr      	INTEGER;
DEFINE dtFechaHoy		DATE;
DEFINE dtFechaAnt		DATE;
DEFINE cNumCte			CHAR(20);
DEFINE cNumCred			CHAR(20);
DEFINE cNumCta			CHAR(20);
DEFINE dCapMtoCuota		DECIMAL(18,2);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cCel				CHAR(13);
DEFINE cEstado			CHAR(2);
DEFINE cCiudad			CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE cNumCarrier		CHAR(3);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cNomEstado       CHAR(20);
DEFINE cNomCiudad       CHAR(20);
DEFINE iPagoVenc        INTEGER;
DEFINE vSdoTotal1       DECIMAL(18,2);
DEFINE vMtoVencido1     DECIMAL(18,2);
DEFINE vMensualidad     DECIMAL(18,2);
DEFINE vSdoTotal2       DECIMAL(18,2);
DEFINE vMtoVencido2     DECIMAL(18,2);
DEFINE vsaldo_total     DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
--NUEVO
DEFINE vtarjeta     char(20);
DEFINE vdia_pago    smallint;
DEFINE vmail        char(100);
DEFINE iCel         SMALLINT;
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    CHAR(80);
DEFINE cMensaje     VARCHAR(150);
DEFINE vproceso		CHAR (4);
define vnumtarjeta  char(20);
define  vvencido    DECIMAL(18,2);
define pparam       smallint;
define cProceso     char(4);
define vpago_vencido DECIMAL(18,2);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
DEFINE vfecha  			date;
define vregistrostotal	integer;
define vmora			smallint;
define vcontador		integer;
define vpri_dia_mes		date;
define vapell_paterno 	char(30);
define vPagoVenc		char(15);
define vnumprod			char(4);
define vcount			integer;
define vvalor           smallint;
define i                integer;
define num              smallint;
define iCount_PPB_MORAS1S integer;
define iCount_PPB_MORAS2S integer;
define iCount_CRE_MORA1S integer;
define iCount_CRE_MORA2S integer;
--define iCount_PP_MORA1 integer;
--define iCount_PP_ULTAVPA integer;
--define iCount_CRE_MORA1 integer;
--define iCount_CRE_ULTAVP integer;
define iCount_PPB_MORAS     integer;
define vCampoBaja           char(10);
DEFINE iCuentasProcesadas6300 INTEGER;
DEFINE iCuentasExcluidasXSdosVencidos   INTEGER;
DEFINE iCuentasExcluidasXMail           INTEGER;
DEFINE dFechaCarLinea       DATE;


---INICIALIZACIONES
let cProceso            = '2042';
LET iSqlErr             = 0;
LET cCodRet             = "000000";
LET P_COD_RET            = "000000";
LET P_MENSAJE           ='El proceso de las campañas EMAIL PP MORAS BAJA se realizó correctamente.';
LET dtFechaHoy			= '';
LET dtFechaAnt			= '';
LET cNumCte				= '';
LET cNumCta				= '';
LET cNumCred			= '';
LET dCapMtoCuota		= 0;
LET	cDiasAnticipados	= 0;
LET cCel				= '';
LET cEstado				= '';
LET cCiudad				= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cTipoRed			= '';
LET cCodRet2			= '';
LET cNumCarrier			= '';
LET cSituacion			= '';
LET iCausa				= 0;
LET cNomEstado          = '';
LET cNomCiudad          = '';
LET iPagoVenc           = 0;
LET vSdoTotal1          = 0;
LET vMtoVencido1        = 0;
LET vMensualidad        = 0;
LET vSdoTotal2          = 0;
LET vMtoVencido2        = 0;
LET vsaldo_total        = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
LET vtarjeta    = '';
LET vdia_pago   = 0;
LET vmail       = '';
LET iCel        = 0;
LET vproceso	='2042';
LET cMensaje    = 'PROCESO EXITOSO';
let vnumtarjeta = '';
let vvencido    = 0;
LET pparam      = 0;
let vpago_vencido = 0;
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vfecha  		= date(1);
let vregistrostotal	=0;
let vmora 			= 0;
let vcontador 		= 0;
let vpri_dia_mes    = date(1);
let vapell_paterno  = '';
let vPagoVenc 		='';
let vnumprod		= '';
let vcount          =0;
let i               = 0;
LET num             = 0;
let iCount_PPB_MORAS1S = 0;
let iCount_PPB_MORAS2S = 0;
let iCount_CRE_MORA1S = 0;
let iCount_CRE_MORA2S = 0;
let iCount_PPB_MORAS = 0;
let vCampoBaja              = '';
let iCuentasProcesadas6300  = 0;
let iCuentasExcluidasXSdosVencidos = 0;
let iCuentasExcluidasXMail  = 0;
let dFechaCarLinea          = date(1);

--  SET DEBUG FILE TO 'sp_mail_prestamopmora_baja.out';
--  TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    LET P_COD_RET= iSqlErr;
    LET P_MENSAJE = 'Error al ejecutar el proceso.';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02') RETURNING cCodRet; 
    RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01')RETURNING cCodRet; 

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SELECT fecha_hoy,fecha_ant
	INTO dtFechaHoy,dtFechaAnt
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';	
	let vpri_dia_mes = mdy(month(dtFechaHoy),day(1),year(dtFechaHoy));
--temporal solo para pruebas
--let dtFechaHoy = today;
--let dtFechaAnt = today-1;
--temporal solo para pruebas
	DELETE FROM bdicobranza:cb_info_administrativa WHERE producto = '6300' and fecha_ejecucion <= today and num_campania = 14;
	if (pparam = 0) then
	DELETE FROM  bdicobranza:cb_mail_cliente WHERE fecha_insert = dtFechaHoy and tipo_mensaje = 5 and  pagos_vencidos < 3;
	end if;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	SELECT valor_numerico into pparam
	FROM cb_param_campania
	WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
{		SELECT  NVL(car.numcte,''), NVL(car.num_credito,''), NVL(b.num_cta,''), car.mto_fin_ven_trasp 
			,d.dia_corte, --cte.correo_elec, 
			(car.sdo_cap_insoluto + car.sdo_intereses + car.interes_iva + car.moratorio ),
			 (car.monto_vencido + car.mto_venc_trasp + car.moratorio + car.interes_iva) ,
			 (car.monto_financiado + car.interes_iva + car.moratorio), car.monto_financiado, 
			 car.monto_vencido + car.mto_venc_trasp,car.num_producto
		INTO cNumCte, cNumCred, cNumCta, iPagoVenc,  vdia_pago, 
			vsaldo_total, v_sdo_venc_int_mora,vpago_minimo_total,
			v_pago_min_sin_vdo,vpago_vencido ,vnumprod
		FROM bdicred:"informix".sd_sdos_cartera_linea car,
			 bdicred:"informix".sd_ctascarg b,
			 bdicred:sd_maecredanexocrd d 
		WHERE car.fecha = dtFechaHoy
        AND car.num_credito >= ''
        AND b.empresa= pempresa
		AND b.naturaleza= 'A'
        AND b.num_credito = car.num_credito
        AND d.empresa= b.empresa
		AND d.num_credito = car.num_credito
		AND car.num_credito = c.num_credito
		AND car.monto_vencido + car.mto_venc_trasp > 0
		AND car.num_producto in ('6300'/*,'6400'*/)
		AND car.status_cred IN ('BT','BA','VP','E1','E2','E3')
		--and car.mto_fin_ven_trasp in (1,2,3)
		AND d.dia_corte =  day(dtFechaHoy)}

	FOREACH 	
		SELECT NVL(a.numcte,''), NVL(a.num_credito,''), NVL(b.num_cta,''), e.mto_fin_ven_trasp ,d.dia_corte, a.num_producto
		INTO cNumCte, cNumCred, cNumCta, iPagoVenc, vdia_pago, vnumprod
		FROM bdicred:sd_maecredcrd a,
             bdicred:sd_ctascarg b,
			 bdicred:sd_maecredanexocrd d,
			 bdicred:sd_maesdoscrd e
		WHERE a.empresa     = pempresa
		AND a.num_credito   >= ''
		AND b.empresa       = a.empresa
		AND b.naturaleza    = 'A'
		AND b.num_credito   = a.num_credito
		AND d.empresa       = a.empresa
		AND d.num_credito   = a.num_credito
		AND e.empresa       = a.empresa
		AND e.num_credito   = a.num_credito
		AND e.monto_vencido + e.mto_venc_trasp > 0
		AND a.num_producto = '6300'
		AND a.status_cred IN ('BT','BA','E1','E2','E3')
        AND a.campo_trab3 = 'BAJA'
		AND d.dia_corte >= case when dtFechaAnt - 1 units day in (select fecha from bdinteg:si_feriado where empresa = pempresa and laborable = 'N')  then day(dtFechaAnt - 1 units day) else day(dtFechaAnt) end
		AND d.dia_corte < case when month(dtFechaAnt) <> month(dtFechaHoy) then 32 else day(dtFechaHoy) end
		
		--A.L.L.
/*		SELECT campo_trab3 
		INTO vCampoBaja
		FROM bdicred:sd_maecredcrd
		WHERE empresa = '001' and num_credito = cNumCred;
		
		IF vCampoBaja <> 'BAJA' THEN
		CONTINUE foreach;
		END IF;*/

        LET iCuentasProcesadas6300 = iCuentasProcesadas6300 + 1;

		SELECT  car.fecha,
			(car.sdo_cap_insoluto + car.sdo_intereses + car.interes_iva + car.moratorio ),
			 (car.monto_vencido + car.mto_venc_trasp + car.moratorio + car.interes_iva) ,
			 (car.monto_financiado + car.interes_iva + car.moratorio), car.monto_financiado, 
			 car.monto_vencido + car.mto_venc_trasp
		INTO  dFechaCarLinea,
			vsaldo_total, v_sdo_venc_int_mora, vpago_minimo_total,
			v_pago_min_sin_vdo,vpago_vencido 
		FROM bdicred:sd_sdos_cartera_linea car
		WHERE car.num_credito = cNumCred;

		IF dFechaCarLinea IS NULL OR dFechaCarLinea = '' THEN
           LET iCuentasExcluidasXSdosVencidos = iCuentasExcluidasXSdosVencidos + 1;
    		CONTINUE foreach;
		END IF;

		let vmail = '';
		select limit 1 correo_elec into vmail 
		from  bdinteg:si_correos   where  empresa ='001' and numcte = cNumCte and status_correo ='A'
		and secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = cNumCte and status_correo ='A');
		
        IF vmail IS NULL OR vmail = '' THEN 
            LET iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
            CONTINUE FOREACH; 
        END IF;


		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = cNumCte ;
		
		let vnumtarjeta = '';
/*		if (iPagoVenc = 1) then let vPagoVenc = 'primer'; end if;
		if (iPagoVenc = 2) then let vPagoVenc = 'segundo'; end if;
		if (iPagoVenc = 3) then let vPagoVenc = 'tercer'; end if;
		if (iPagoVenc = 4) then let vPagoVenc = 'cuarto'; end if;
		if (iPagoVenc = 5) then let vPagoVenc = 'quinto'; end if;
		if (iPagoVenc = 6) then let vPagoVenc = 'sexto'; end if;
		if (iPagoVenc = 7) then let vPagoVenc = 'septimo'; end if;
		if (iPagoVenc = 8) then let vPagoVenc = 'octavo'; end if;
		if (iPagoVenc = 9) then let vPagoVenc = 'noveno'; end if;
		if (iPagoVenc = 10) then let vPagoVenc = 'decimo'; end if;
		if (iPagoVenc = 11) then let vPagoVenc = 'onceavo'; end if;
		if (iPagoVenc = 12) then let vPagoVenc = 'doceavo'; end if;*/

--		if ( nvl(vmail,'') <> '') then
--		if	(vnumprod = '6300') then
--			if (iPagoVenc IN (1,2,3)) THEN
--			if (iPagoVenc > 0) THEN
/*				if(pparam = 0)  then
					call "informix".sp_mail_inserta_cliente (pempresa,5, cNumCte, cNumCred, vmail,vpago_minimo_total,vsaldo_total,
														iPagoVenc,0,vdia_pago,null,null,0,0,vpago_vencido,v_pago_min_sin_vdo,v_sdo_venc_int_mora)
														returning cCodRet;
				end if;*/
                let iCount_PPB_MORAS = iCount_PPB_MORAS + 1;
				call bdimnsj:"informix".sp_registra_evento (1, 'PPB_MORAS' , cNumCte, cNumCred,vnumtarjeta, 2,
							vapell_paterno,iPagoVenc,'','','',0,0,0,0,0, today, '')RETURNING cCodRet;
--			end if;
--		end if;	
--		end if;	
			--	let vcontador = vcontador + 1;  
	END FOREACH;
	
	if iCount_PPB_MORAS > 0 then
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PPB_MORAS',iCount_PPB_MORAS) RETURNING cCodRet;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PPB_MORAS',iCount_PPB_MORAS,null) RETURNING cCodRet;
    end if;

	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
        if EXISTS(select cliente from bdimnsj:mnsjr_trx_batch where id_mensaje='PPB_MORAS' and date(fecha_hora_registro) = today) then
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,string2,importe1,fecha1,fecha2)
            select  1, 'PPB_MORA1',numcte,current,apell_paterno,'primer',0,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57); end if;
    end for

	let i = 0;
	LET num = 0;

--Genera cifras de control
    if iCuentasProcesadas6300 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campañas EMAILs MORAS BAJA PP : ' ||iCuentasProcesadas6300;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados MORAS PP : ' ||iCount_PPB_MORAS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error saldos vencidos : ' ||iCuentasExcluidasXSdosVencidos;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error mail : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03') RETURNING cCodRet; 

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
	 
END
END PROCEDURE;
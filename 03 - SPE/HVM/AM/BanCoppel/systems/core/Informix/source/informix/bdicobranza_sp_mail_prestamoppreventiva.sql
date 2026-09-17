CREATE PROCEDURE "informix".sp_mail_prestamoppreventiva(pempresa char(3),Pcampana smallint)
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(150)  AS mensaje_retorno;
			
---DECLARACIONES
DEFINE cCodRet        	CHAR(6); 
DEFINE iSqlErr      	INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE dtFechaHoy		DATE;
DEFINE cNumCte			CHAR(20);
DEFINE cNumCred			CHAR(20);
DEFINE cNumCta			CHAR(20);
DEFINE P_COD_RET      	CHAR(06);
DEFINE P_MENSAJE        CHAR(150);
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
define vpago            DECIMAL(18,2);
define vpago_vencido    DECIMAL(18,2);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
--NUEVO
DEFINE vtarjeta         char(20);
DEFINE vdia_pago        smallint;
DEFINE vmail            char(100);
DEFINE Vfecha_apertura  DATE;
--DEFINE Vcount smallint;
DEFINE iCount_PP_PAGCOMS    integer; --A.L.L.
DEFINE iCount_PPD_PAGCOMS 	INTEGER;
DEFINE iCount_CRE_PAGS      integer; --A.L.L.
DEFINE iCount_PP_PREVENT    integer; --A.L.L.
DEFINE iCount_CRE_PREVEN    integer; --A.L.L.
DEFINE iCount_PPD_PREVENT 	INTEGER;
DEFINE VFECHA_PROX_PAGO     DATE;
DEFINE iCel             SMALLINT;
DEFINE cMensaje         VARCHAR(150);
DEFINE vproceso			CHAR (4);
define vnumtarjeta      char(20) ;
define vfechapago       date;
define pparam           smallint;
--DEFINE cproceso         CHAR(4);
define vregistrostotal	integer;
define vcontador		integer;
define vpri_dia_mes     date;
define vapell_paterno   char(30);
define vnumprod			char(4);
define vvalor			smallint;
define i    integer;
define x    integer;
define num  smallint;
DEFINE iCuentasProcesadas6300           INTEGER;
DEFINE iCuentasProcesadas6800			INTEGER;
DEFINE iCuentasProcesadas6400           INTEGER;
DEFINE iCuentasExcluidasXCel            INTEGER;
DEFINE iCuentasExcluidasXCel6800 		INTEGER;
DEFINE iCuentasExcluidasXMail6300           INTEGER;
DEFINE iCuentasExcluidasXMail6400           INTEGER;
DEFINE iCuentasExcluidasXMail6800 			INTEGER;

--let cproceso ='0062';

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "000000";
LET P_COD_RET           = "000000";
LET P_MENSAJE           ='El proceso de las campañas SMSs PP PREVENTIVAS se realizó correctamente.';
LET dtFechaHoy			= '';
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
LET cNomEstado      = '';
LET cNomCiudad      = '';
LET iPagoVenc       = 0;
LET vSdoTotal1      = 0;
LET vMtoVencido1    = 0;
LET vMensualidad    = 0;
LET vSdoTotal2      = 0;
LET vMtoVencido2    = 0;
LET vsaldo_total    = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
LET vtarjeta    = '';
LET vdia_pago   = 0;
LET vmail       = '';
--LET vcount = 0;
LET iCount_PP_PAGCOMS   = 0; --A.L.L.
LET iCount_PPD_PAGCOMS 	= 0;
LET iCount_CRE_PAGS     = 0; --A.L.L.
LET iCount_PP_PREVENT   = 0; --A.L.L.
LET iCount_CRE_PREVEN   = 0; --A.L.L.
LET iCount_PPD_PREVENT 	= 0;
let vpago   = 0;
LET iCel    = 0;
LET vproceso	='2029';
LET cMensaje    = '';
let vnumtarjeta = '';
let vfechapago  = date(1);
let pparam      = 0;
let vpago_vencido   = 0;
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vregistrostotal	=0;
let vcontador       = 0;
let vpri_dia_mes    = date(1);
let vapell_paterno  = '';
let vnumprod        = '';
let vvalor          = 0;
LET num             = 0;
let iCuentasExcluidasXCel            = 0;
LET iCuentasExcluidasXCel6800		 = 0;
let iCuentasExcluidasXMail6300       = 0;
let iCuentasExcluidasXMail6400       = 0;
LET iCuentasExcluidasXMail6800 		 = 0;
let iCuentasProcesadas6300           = 0;
LET iCuentasProcesadas6800			 = 0;
let iCuentasProcesadas6400           = 0;


BEGIN

ON EXCEPTION SET iSqlErr
--ON EXCEPTION SET iSqlErr, isam_err, error_info
    LET cCodRet= iSqlErr;
    LET P_COD_RET= iSqlErr;
    LET P_MENSAJE = 'Error al ejecutar el proceso.';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02')RETURNING cCodRet; 
    RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_mail_prestamoppreventiva.out';
--TRACE ON;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01')RETURNING cCodRet; 

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SELECT NVL(fecha_hoy ,''),pri_dia_mes
	INTO dtFechaHoy,vpri_dia_mes
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';	

--temporal solo para pruebas
--let dtFechaHoy = mdy('02','16','2016');
--let vpri_dia_mes = mdy('02','01','2016');
--temporal solo para pruebas
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
	
	--if (Pcampana = 5) then 	 DELETE FROM bdicobranza:cb_info_administrativa WHERE producto = '6300' and fecha_ejecucion <= dtFechaHoy and num_campania = 13; end if;
	--if (Pcampana = 7 and pparam = 0) then  DELETE FROM  bdicobranza:cb_mail_cliente WHERE fecha_insert = dtFechaHoy and tipo_mensaje = 5 and  pagos_vencidos = 0; end if;
	
/*	if (Pcampana = 7) then
		
		FOR i in (1 to vvalor)
			insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,string2,importe1,fecha1,fecha2)
				select  1, 'PP_PREVENT',numcte,current,'MESIVERSARIO',apell_paterno,0,current,current
				from bdinteg:si_cliente
				where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				
				let num = num + 10;
		end for
	end if;*/
	
/* --Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	select valor_numerico 
		into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 10;
*/	-- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)	
	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
	where id_mensaje = 'PP_PAGCOMS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	select nvl(count(*),0) into vtotal2
	from bdimnsj:mnsjr_trx_batch
	where id_mensaje = 'PP_PAGCOMS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	let vtotal = vtotal1 + vtotal2;
	
	---- consulta para saber cuantos registros faltan por buscar al mes	
	let vregistrostotal = vvalor_numerico - vtotal;

	if (day(dtFechaHoy) = 1 ) then 
		let vregistrostotal = vvalor_numerico;
	end if;

---tabla temporal movhiscrd
	select num_credito,monto
		from bdicred:sd_movhiscrd 
		where empresa = pempresa
--			and fecha_mov > date(dtFechaHoy) - 1 units month + 5 units day
--			and fecha_mov > bdicred:monthadd(dtFechaHoy, - 1) + 5 units day
			and fecha_mov >= bdicred:monthadd(dtFechaHoy, - 1) + 6 units day
			and fecha_mov <=  dtFechaHoy 
			and num_credito >= ''
			and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd where num_producto in('6300','7600','7700','6400','6800')) --A.L.L. se ingresan los productos 7600 y 7700
			and codigo_ref = 1
			and reversado = 'N' 
		into temp movcrd with no log; 

    CREATE INDEX credito_movcrd ON movcrd(num_credito);
    UPDATE STATISTICS MEDIUM FOR TABLE movcrd;

--if (Pcampana = 5 and vtotal < vvalor_numerico) then		--Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
if (Pcampana = 5) then		
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
--		select  2, 'PP_PAGCOMS',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
		select  2, 'PP_PAGCOMS',numcte,current,day(dtFechaHoy),0,'',0
		from bdinteg:si_cliente
		where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for

	FOREACH		
		SELECT NVL(a.numcte,''), NVL(a.num_credito,''), NVL(b.num_cta,''),
				f.mto_fin_ven_trasp,d.dia_corte,d.prox_fecha_pago, f.monto_vencido + f.mto_venc_trasp,
            ( f.monto_financiado +
				f.int_tra_no_exig + -- INt Vencido
				f.mto_venc_int  +-- Iva INt Vencido
				f.sdo_no_exig  +--Int. Vigente
				f.mto_finan_vdo + -- Iva Int. Vigente
				round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ suc.iva),2) ) Pago_minimo, 
			(f.sdo_cap_insoluto     + 
                 round(NVL(f.sdo_intereses,0) * (1+ suc.iva),2) +  --tipo de IVA
                 f.int_tra_no_exig + f.mto_venc_int + f.sdo_no_exig + f.mto_finan_vdo +   --INtVencido + Iva INtVencido + IntVigente + Iva IntVigente
                 round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ suc.iva),2)) sdo_total, a.num_producto
		INTO cNumCte, cNumCred, cNumCta, iPagoVenc, vdia_pago, vfechapago, vpago_vencido, vpago_minimo_total, vsaldo_total, vnumprod
		FROM bdicred:"informix".sd_maecredcrd a, 
			bdicred:"informix".sd_ctascarg b,
			bdicred:"informix".sd_maesdoscrd f,
			bdinteg:si_sucursales suc,
			bdicred:sd_maecredanexocrd d
		WHERE a.empresa         = pempresa 
            AND a.num_credito   >= ''
            AND b.empresa       = a.empresa 
			AND b.naturaleza    = 'A'
            AND b.num_credito   = a.num_credito
			AND f.empresa       = a.empresa 
            AND f.num_credito   = a.num_credito
			AND suc.empresa     = a.empresa   
			AND suc.sucursal    = a.sucursal
			AND d.empresa       = a.empresa   
            AND d.num_credito   = a.num_credito
			AND a.num_producto in ('6300','7600','7700','6800') --A.L.L. se ingresan los productos 7600 y 7700
			--AND a.num_producto  = '6300'
			AND a.status_cred IN ('AA','E1')
			AND a.campo_trab3 <> 'BAJA'
			AND d.prox_fecha_pago = date(dtFechaHoy) + 5 units day
			AND f.mto_fin_ven_trasp = 0
			AND f.monto_vencido + f.mto_venc_trasp = 0
			AND f.sdo_capital    > 0
			--ORDER BY a.num_producto ASC

		IF (vnumprod IN ('6300','7600','7700')) THEN
			let iCuentasProcesadas6300 = iCuentasProcesadas6300 + 1;
		ELIF (vnumprod = '6800') THEN
			LET iCuentasProcesadas6800 = iCuentasProcesadas6800 + 1;
		END IF;

				--CALCULO DE PAGO_MIN_SIN_VDO--MENSUALIDAD
		let v_pago_min_sin_vdo = 0;
        let cCel = '';

		SELECT limit 1 NVL(d.telefono,'')
		INTO cCel
		FROM bdinteg:"informix".si_telefonos_actual d          
		WHERE d.numcte= cNumCte
		AND d.tipo_tel = 2
		AND status_tel = 'A'
		AND cofetel ='V';

		if cCel is null or cCel = '' then 
			IF (vnumprod IN ('6300','7600','7700')) THEN
				LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
			ELIF (vnumprod = '6800') THEN
				LET iCuentasExcluidasXCel6800 = iCuentasExcluidasXCel6800 + 1;
			END IF;
			CONTINUE foreach; 
		end if;

		select sum (monto) into vpago
		from movcrd
		where num_credito = cNumCred;
			
		if (vpago is null or vpago = 0) then  let vpago = 0; end if;		  
			
				--CALCULO DE PAGO MINIMO
/*			SELECT  ( a.monto_financiado +
				a.int_tra_no_exig + -- INt Vencido
				a.mto_venc_int  +-- Iva INt Vencido
				a.sdo_no_exig  +--Int. Vigente
				a.mto_finan_vdo + -- Iva Int. Vigente
				round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2) )  Pago_minimo INTO vpago_minimo_total
			FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
			WHERE cr.empresa = s.empresa
				AND cr.sucursal = s.sucursal
				AND a.empresa = cr.empresa
				AND a.num_credito = cr.num_credito
				AND a.num_credito = cNumCred;*/
	
				--CALCULO DE SALDO TOTAL
/*			SELECT (a.sdo_cap_insoluto     + 
                 round(NVL(a.sdo_intereses,0) * (1+ s.iva),2) +  --tipo de IVA
                 a.int_tra_no_exig + a.mto_venc_int + a.sdo_no_exig + a.mto_finan_vdo +   --INtVencido + Iva INtVencido + IntVigente + Iva IntVigente
                 round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2)) sdo_total INTO vsaldo_total
			FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
			WHERE cr.empresa = s.empresa
				AND cr.sucursal = s.sucursal
				AND a.empresa = cr.empresa
				AND a.num_credito = cr.num_credito
				AND a.num_credito = cNumCred;*/
			
				--CALCULO DE SDO_VENC_INT_MORA
			let v_sdo_venc_int_mora = 0;
		
			SELECT limit 1 e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
				INTO cNomEstado, cNomCiudad  --cEstado, cCiudad
			FROM bdinteg:"informix".si_direcciones_actual d, 
				bdinteg:"informix".si_estados e, 
				bdinteg:"informix".si_ciudades c 
			WHERE d.numcte= cNumCte
				AND d.tipo_dir= '1'
				AND d.estado = e.estado
				AND d.ciudad = c.ciudad
				AND c.estado = e.estado;
			 
--			if (cCel <> '') then
				LET iCel = LENGTH(cCel) + 1 - 10;
				--IF cCel <> '' then
					IF ( LENGTH(cCel) > 10 ) THEN
					LET cCel = SUBSTR(cCel,iCel,10);
					ELIF ( LENGTH(cCel) < 10 ) THEN
						LET cCel ='';
					END IF;
				--END IF;	
	
				SELECT limit 1 NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
					INTO cNombre1, cNombre2, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente
				WHERE numcte= cNumCte;		
		
				SELECT {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
					INTO cSituacion, iCausa
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = cNumCte;
			
				IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
				IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
			
--				IF cCel <> '' then
--                    if (cNumCred is not null) then
--                    if (vpago < v_pago_min_sin_vdo) then 
                /*        INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
                            nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
                            causa,situacion,pago_vencido  ,   pago_req_sms  )
                        VALUES (pempresa, 13, '6300', dtFechaHoy, cNumCte, cNumCred, cNumCta, vtarjeta, cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, vsaldo_total, 
                            vpago_minimo_total, vfechapago, v_sdo_venc_int_mora, iPagoVenc, v_pago_min_sin_vdo, iCausa,cSituacion,vpago_vencido,vpago_minimo_total );			
                */        
						--A.L.L.
					IF (vnumprod IN ('6300','7600','7700')) THEN
                        LET iCount_PP_PAGCOMS = iCount_PP_PAGCOMS +1;
                        call bdimnsj:"informix".sp_registra_evento (2, 'PP_PAGCOMS' , cNumCte, cNumCred,vnumtarjeta, 2,
                                day(vfechapago),'','','','',0,0,0,0,0, '', '')RETURNING P_COD_RET;
--                                cApellPat,day(vfechapago),month(vfechapago),'','',vpago_minimo_total,0,0,0,0, '', '')RETURNING P_COD_RET;

                        let vcontador = vcontador + 1;  
					ELIF (vnumprod = '6800') THEN
						LET iCount_PPD_PAGCOMS = iCount_PPD_PAGCOMS +1;

						CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','PPD_PAGCOMS',cNumcte,cNumCred,vnumtarjeta,'2',
											DAY(vfechapago),'','','','','','','','','','','',0,0,0,0,0,'','') RETURNING cCodRet;
					END IF;
--                    end if;
--				end if;
--			end if;
--		if (vcontador = vregistrostotal) then	exit FOREACH; end if; -- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	END FOREACH;
end if;

if (vcontador >= 1) then 
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
--		select  2, 'PP_PAGCOMS',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
		select  2, 'PP_PAGCOMS',numcte,current,day(dtFechaHoy),0,'',0
    	  from bdinteg:si_cliente
		 where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
		let num = num + 10;
		end for
end if;

--	IF iCount_PP_PAGCOMS > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_PAGCOMS',iCount_PP_PAGCOMS,iCuentasExcluidasXCel) RETURNING cCodRet;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_PAGCOMS',iCuentasProcesadas6300,iCuentasExcluidasXCel) RETURNING cCodRet;
--	END IF;

--Genera cifras de control
    if iCuentasProcesadas6300 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs RECOR. PAGO PP : ' ||iCuentasProcesadas6300;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados PP : ' ||iCount_PP_PAGCOMS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;

    IF iCuentasProcesadas6800 > 0 THEN
	   LET cMensaje = '';
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs RECOR. PAGO PPD : ' ||iCuentasProcesadas6800;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados PPD : ' ||iCount_PPD_PAGCOMS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	   LET cMensaje = '';
       let cMensaje = 'Cuentas excluidas por error celular PPD: ' ||iCuentasExcluidasXCel6800;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    END IF;
--Genera cifras de control

let iCuentasExcluidasXCel            = 0;
LET iCuentasExcluidasXCel6800		 = 0;
let iCuentasExcluidasXMail6300       = 0;
let iCuentasExcluidasXMail6400       = 0;
let iCuentasProcesadas6300           = 0;
LET iCuentasProcesadas6800			 = 0;
let iCuentasProcesadas6400           = 0;

--	let vcount= 0;
	----------------------------------------------CREDINOMINA----SMS---------------------------------------------------
if (Pcampana = 5 ) then
/*	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
		select  2, 'CRE_PAGS',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
		from bdinteg:si_cliente
		where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for*/

    let vcontador = 0 ;
	FOREACH		
		SELECT  NVL(a.numcte,''), NVL(a.num_credito,''), NVL(b.num_cta,''),
				f.mto_fin_ven_trasp,d.dia_corte,d.prox_fecha_pago, f.monto_vencido + f.mto_venc_trasp,
            (f.sdo_cap_insoluto     + 
                 round(NVL(f.sdo_intereses,0) * (1+ suc.iva),2) +  --tipo de IVA
                 f.int_tra_no_exig + f.mto_venc_int + f.sdo_no_exig + f.mto_finan_vdo +   --INtVencido + Iva INtVencido + IntVigente + Iva IntVigente
                 round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ suc.iva),2)) sdo_total
		INTO cNumCte, cNumCred, cNumCta, iPagoVenc, vdia_pago, vfechapago, vpago_vencido, vsaldo_total
		FROM bdicred:"informix".sd_maecredcrd a, 
			bdicred:"informix".sd_ctascarg b,
			bdicred:"informix".sd_maesdoscrd f,
			bdinteg:si_sucursales suc,
			bdicred:sd_maecredanexocrd d
		WHERE a.empresa         = pempresa
            AND a.num_credito   >= ''
            AND b.empresa       = a.empresa 
			AND b.naturaleza    = 'A'
            AND b.num_credito   = a.num_credito
			AND f.empresa       = a.empresa 
            AND f.num_credito   = a.num_credito
			AND d.empresa       = a.empresa   
            AND d.num_credito   = a.num_credito
			AND a.sucursal      = suc.sucursal
			AND a.num_producto  = '6400'
			AND a.status_cred IN ('AA','E1')
			AND a.campo_trab3 <> 'BAJA'
			AND d.prox_fecha_pago = date(dtFechaHoy) + 5 units day
			AND f.mto_fin_ven_trasp = 0
			AND f.monto_vencido + f.mto_venc_trasp = 0
			AND f.sdo_capital   > 0

        let iCuentasProcesadas6400 = iCuentasProcesadas6400 + 1;

        if iCuentasProcesadas6400 = 1 then
            let i = 0;
            LET num = 0;
            FOR i in (1 to vvalor)
                insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
                select  2, 'CRE_PAGS',numcte,current,day(dtFechaHoy),0,0,0
--                select  2, 'CRE_PAGS',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
                from bdinteg:si_cliente
                where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
                    let num = num + 10;
            end for
        end if;

--CALCULO DE PAGO_MIN_SIN_VDO--MENSUALIDAD
		let v_pago_min_sin_vdo = 0;
		let cCel = '';

		SELECT limit 1 NVL(d.telefono,'')
				INTO cCel
		FROM bdinteg:"informix".si_telefonos_actual d          
		WHERE d.numcte= cNumCte
				AND d.tipo_tel = 2
				and status_tel = 'A'
				and cofetel ='V';

        if cCel is null or cCel = '' then 
            LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
            CONTINUE foreach; 
        end if;

		select sum (monto) into vpago
		from movcrd
		where num_credito = cNumCred;
			
		if (vpago is null or vpago = 0) then  let vpago = 0; end if;		  
			
				--CALCULO DE PAGO MINIMO
		let  vpago_minimo_total = 0;
	
				--CALCULO DE SALDO TOTAL
/*		SELECT (a.sdo_cap_insoluto     + 
                 round(NVL(a.sdo_intereses,0) * (1+ s.iva),2) +  --tipo de IVA
                 a.int_tra_no_exig + a.mto_venc_int + a.sdo_no_exig + a.mto_finan_vdo +   --INtVencido + Iva INtVencido + IntVigente + Iva IntVigente
                 round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2)) sdo_total INTO vsaldo_total
		FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
		WHERE cr.empresa = s.empresa
				AND cr.sucursal = s.sucursal
				AND a.empresa = cr.empresa
				AND a.num_credito = cr.num_credito
				AND a.num_credito = cNumCred;*/
			
				--CALCULO DE SDO_VENC_INT_MORA
		let  v_sdo_venc_int_mora = 0;
	
		SELECT limit 1 e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
				INTO cNomEstado, cNomCiudad  --cEstado, cCiudad
		FROM bdinteg:"informix".si_direcciones_actual d, 
				bdinteg:"informix".si_estados e, 
				bdinteg:"informix".si_ciudades c 
		WHERE d.numcte= cNumCte
				AND d.tipo_dir= '1'
				AND d.estado = e.estado
				AND d.ciudad = c.ciudad
				AND c.estado = e.estado;
			 
--			if (cCel <> '') then
				LET iCel = LENGTH(cCel) + 1 - 10;
				--IF cCel <> '' then
					IF ( LENGTH(cCel) > 10 ) THEN
					LET cCel = SUBSTR(cCel,iCel,10);
					ELIF ( LENGTH(cCel) < 10 ) THEN
						LET cCel ='';
					END IF;
				--END IF;	
				
				SELECT limit 1 NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
					INTO cNombre1, cNombre2, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente
				WHERE numcte= cNumCte;		
		
				SELECT {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
					INTO cSituacion, iCausa
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = cNumCte;
			
				IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
				IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
			
--				IF cCel <> '' then
--                    if (cNumCred is not null) then
                /*        INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
                            nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
                            causa,situacion,pago_vencido  ,   pago_req_sms  )
                        VALUES (pempresa, 17, '6400', today, cNumCte, cNumCred, cNumCta, vtarjeta, cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, vsaldo_total, 
                            vpago_minimo_total, vfechapago, v_sdo_venc_int_mora, iPagoVenc, v_pago_min_sin_vdo, iCausa,cSituacion,vpago_vencido,vpago_minimo_total );			
                */        
						--A.L.L.
                        LET iCount_CRE_PAGS = iCount_CRE_PAGS +1;
                        call bdimnsj:"informix".sp_registra_evento (2, 'CRE_PAGS' , cNumCte, cNumCred,vnumtarjeta, 2,
                                day(vfechapago),'','','','',0,0,0,0,0, '', '')RETURNING P_COD_RET;
--                                cApellPat,day(vfechapago),'','','',0,0,0,0,0, '', '')RETURNING P_COD_RET;
                        let vcontador = vcontador + 1 ;
--    				end if;
--				end if;
--			end if;

	END FOREACH;
end if;

if (vcontador >= 1) then 
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
		select  2, 'CRE_PAGS',numcte,current,day(dtFechaHoy),0,0,0
--		select  2, 'CRE_PAGS',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				let num = num + 10;
	end for
end if;

	IF iCount_CRE_PAGS > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_PAGS',iCount_CRE_PAGS) RETURNING cCodRet;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_PAGS',iCount_CRE_PAGS,null) RETURNING cCodRet;
	END IF;

--Genera cifras de control
    if iCuentasProcesadas6300 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs RECOR. PAGO CREDINO. : ' ||iCuentasProcesadas6400;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados CREDINO. : ' ||iCount_CRE_PAGS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

let iCuentasExcluidasXCel            = 0;
let iCuentasExcluidasXMail6300       = 0;
let iCuentasExcluidasXMail6400       = 0;
let iCuentasProcesadas6300           = 0;
let iCuentasProcesadas6400           = 0;

if (Pcampana = 7) then
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
		select  2, 'PP_PREVENT',numcte,current,'MESIVERSARIO','','',0
--		select  2, 'PP_PREVENT',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
		from bdinteg:si_cliente
		where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);

		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
		select  2, 'CRE_PREVEN',numcte,current,'MESIVERSARIO','','',0
--		select  2, 'CRE_PREVEN',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
		from bdinteg:si_cliente
		where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);

		let num = num + 10;
	end for

	FOREACH				
		
		SELECT a.numcte,a.num_credito, f.mto_fin_ven_trasp, a.fecha_apertura,d.prox_fecha_pago,a.num_producto,
            f.monto_vencido + f.mto_venc_trasp
		INTO cNumCte, cNumCred, iPagoVenc, Vfecha_apertura, VFECHA_PROX_PAGO, vnumprod, vpago_vencido
		FROM bdicred:"informix".sd_maecredcrd a, 
		     bdicred:"informix".sd_maesdoscrd f,
		     bdicred:sd_maecredanexocrd d
		WHERE a.empresa     = pempresa
        AND a.num_credito   >= ''
        AND f.empresa       = a.empresa	
        AND f.num_credito   = a.num_credito
        AND d.empresa       = a.empresa   
        AND d.num_credito   = a.num_credito
		AND a.num_producto in ('6300','7600','7700','6400','6800') --A.L.L. se ingresan los productos 7600 y 7700
		--AND a.num_producto in ('6300','6400')
		AND a.campo_trab3 <> 'BAJA'
		AND f.mto_fin_ven_trasp = 0
		AND f.monto_vencido + f.mto_venc_trasp = 0
		AND d.prox_fecha_pago BETWEEN date(dtFechaHoy) + 2 units day AND date(dtFechaHoy)+ 8 units day
		
		let vnumtarjeta ='';
		let vmail ='';

        --if vnumprod = '6300' then
		if vnumprod in ('6300','7600','7700') then --A.L.L. se ingresan los productos 7600 y 7700
            let iCuentasProcesadas6300 = iCuentasProcesadas6300 + 1;
        elif vnumprod = '6400' then
            let iCuentasProcesadas6400 = iCuentasProcesadas6400 + 1;
		ELIF vnumprod = '6800' THEN
			LET iCuentasProcesadas6800 = iCuentasProcesadas6800 + 1;
        end if;

		select limit 1 cte.correo_elec into vmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = cNumCte and cte.status_correo ='A'
		and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = cNumCte and status_correo ='A');	

        if vmail is null or vmail = '' then
           --if vnumprod = '6300' then
		   if vnumprod in ('6300','7600','7700') then --A.L.L. se ingresan los productos 7600 y 7700
              LET iCuentasExcluidasXMail6300 = iCuentasExcluidasXMail6300 + 1;
           elif vnumprod = '6400' then
              LET iCuentasExcluidasXMail6400 = iCuentasExcluidasXMail6400 + 1;
		   ELIF vnumprod = '6800' THEN
              LET iCuentasExcluidasXMail6800 = iCuentasExcluidasXMail6800 + 1;
           end if;
           CONTINUE foreach; 
        end if;
/*
		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = cNumCte ;*/
		
			--CALCULO DE PAGO_MIN_SIN_VDO--MENSUALIDAD
		let v_pago_min_sin_vdo = 0;
			
				--CALCULO DE PAGO MINIMO
/*		SELECT  ( a.monto_financiado +
			a.int_tra_no_exig + -- INt Vencido
			a.mto_venc_int  +-- Iva INt Vencido
			a.sdo_no_exig  +--Int. Vigente
			a.mto_finan_vdo + -- Iva Int. Vigente
			round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2) )  Pago_minimo INTO vpago_minimo_total
		FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
		WHERE cr.empresa = s.empresa
			AND cr.sucursal = s.sucursal
			AND a.empresa = cr.empresa
			AND a.num_credito = cr.num_credito
			AND a.num_credito = cNumCred;*/

				--CALCULO DE SALDO TOTAL
/*		SELECT (a.sdo_cap_insoluto     + 
            round(NVL(a.sdo_intereses,0) * (1+ s.iva),2) +  --tipo de IVA
            a.int_tra_no_exig + a.mto_venc_int + a.sdo_no_exig + a.mto_finan_vdo +   --INtVencido + Iva INtVencido + IntVigente + Iva IntVigente
            round((a.sdo_moratorio + a.sdo_contab_mora) * (1+ s.iva),2)) sdo_total INTO vsaldo_total
		FROM BDICRED:sd_maesdoscrd a , bdinteg:si_sucursales s,bdicred:sd_maecredcrd cr
		WHERE cr.empresa = s.empresa
			AND cr.sucursal = s.sucursal
			AND a.empresa = cr.empresa
			AND a.num_credito = cr.num_credito
			AND a.num_credito = cNumCred;*/
			
				--CALCULO DE SDO_VENC_INT_MORA
		let v_sdo_venc_int_mora = 0;
				
/*		SELECT a.monto_vencido + a.mto_venc_trasp
		INTO  vpago_vencido -- IntVigente + IvaIntVigente + PagoExigible
		FROM BDICRED:sd_maesdoscrd a ,bdicred:sd_maecredcrd cr
		WHERE  a.empresa = cr.empresa
			AND a.num_credito = cr.num_credito
			AND a.num_credito = cNumCred;*/
			
--		if (vmail <> '') then			
--			if (cNumCred is not null) then
                --if (vnumprod = '6300') then
				if vnumprod in ('6300','7600','7700') then --A.L.L. se ingresan los productos 7600 y 7700
                    /* --ALLif (pparam = 0) then
                        call "informix".sp_mail_inserta_cliente (pempresa,5, cNumCte, cNumCred, vmail,0,0,iPagoVenc,0,
                                                                Vfecha_apertura,null,null,0,0,vpago_vencido,v_pago_min_sin_vdo,v_sdo_venc_int_mora)
                        returning cCodRet; 
                    end if;--ALL*/
                    --A.L.L.
                    LET iCount_PP_PREVENT = iCount_PP_PREVENT +1;
                    call bdimnsj:"informix".sp_registra_evento (1, 'PP_PREVENT' , cNumCte, cNumCred,vnumtarjeta, 2,
                                'MESIVERSARIO','','','','',0,0,0,0,0, today, '')RETURNING cCodRet;
--                                'MESIVERSARIO',vapell_paterno,'','','',0,0,0,0,0, today, '')RETURNING cCodRet;
					call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1011, cNumCred, cNumCte, vnumprod, today,vmail, '','','') returning P_COD_RET;
                end if;
                if (vnumprod = '6400') then
                    /* --ALL if (pparam = 0) then
                        call "informix".sp_mail_inserta_cliente (pempresa,6, cNumCte, cNumCred, vmail,0,0,iPagoVenc,0,
                                                                Vfecha_apertura,null,null,0,0,vpago_vencido,v_pago_min_sin_vdo,v_sdo_venc_int_mora)
                        returning cCodRet; 
                    end if; --ALL*/
                    --A.L.L.
                    LET iCount_CRE_PREVEN = iCount_CRE_PREVEN +1;
                    call bdimnsj:"informix".sp_registra_evento (1, 'CRE_PREVEN' , cNumCte, cNumCred,vnumtarjeta, 2,
                                'MESIVERSARIO','','','','',0,0,0,0,0, today, '')RETURNING cCodRet;
--                                'MESIVERSARIO',vapell_paterno,'','','',0,0,0,0,0, today, '')RETURNING cCodRet;
					call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1012, cNumCred, cNumCte, vnumprod, today,vmail, '','','') returning P_COD_RET;
                end if;
				IF (vnumprod = '6800') THEN
                    LET iCount_PPD_PREVENT = iCount_PPD_PREVENT +1;

					CALL bdimnsj:"informix".sp_registra_evento('1','COBRA_MAIL','PPD_PREVENT',cNumcte,cNumCred,vnumtarjeta,'2',
								'MESIVERSARIO','','','','','','','','','','','',0,0,0,0,0,TODAY,'') RETURNING cCodRet;
                END IF;
--			end if;	
--		end if;
	END FOREACH;
end if;

if iCount_PP_PREVENT > 0 or iCount_CRE_PREVEN > 0 then
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
        if iCount_PP_PREVENT > 0 then
            insert into  bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,fecha1)
            select  2, 'PP_PREVENT',numcte,current,'MESIVERSARIO','',current
--            select  2, 'PP_PREVENT',numcte,current,'MESIVERSARIO',apell_paterno,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
        end if;

        if iCount_CRE_PREVEN > 0  then
            insert into  bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,fecha1)
--            select  2, 'CRE_PREVEN',numcte,current,'MESIVERSARIO',apell_paterno,current
            select  2, 'CRE_PREVEN',numcte,current,'MESIVERSARIO','',current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
        end if;
		let num = num + 10;
	end for
end if;

		--A.L.L.
	IF iCount_PP_PREVENT > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_PREVENT',iCount_PP_PREVENT) RETURNING cCodRet;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_PREVENT',iCount_PP_PREVENT,null) RETURNING cCodRet;
	END IF;

		--A.L.L.
	IF iCount_CRE_PREVEN > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_PREVEN',iCount_CRE_PREVEN) RETURNING cCodRet;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_PREVEN',iCount_CRE_PREVEN,null) RETURNING cCodRet;
	END IF;

--Genera cifras de control
    if iCuentasProcesadas6300 > 0 or iCuentasProcesadas6400 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña EMAILs RECOR. PAGO PP. : ' ||iCuentasProcesadas6300;
       let cMensaje = trim(cMensaje) ||'    TOTAL Cuentas procesadas campaña EMAILs RECOR. PAGO CREDINO. : ' ||iCuentasProcesadas6400;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'EMAILs enviados PP. : ' ||iCount_PP_PREVENT;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados CREDINO. : ' ||iCount_CRE_PREVEN;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email PP: ' ||iCuentasExcluidasXMail6300;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email CREDINO. : ' ||iCuentasExcluidasXMail6400;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;

    IF iCuentasProcesadas6800 > 0 THEN
	   LET cMensaje = '';
       let cMensaje = 'TOTAL Cuentas procesadas campaña EMAILs REC OR. PAGO PPD. : ' ||iCuentasProcesadas6800;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	   LET cMensaje = '';
       let cMensaje = 'EMAILs enviados PPD. : ' ||iCount_PPD_PREVENT;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	   LET cMensaje = '';
       let cMensaje = 'Cuentas excluidas por error email PPD : ' ||iCuentasExcluidasXMail6800;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    END IF;
--Genera cifras de control

/*
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			-- CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
			RETURN cCodRet;
    END IF;*/

    DROP TABLE movcrd;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03') RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
 
END
END PROCEDURE;
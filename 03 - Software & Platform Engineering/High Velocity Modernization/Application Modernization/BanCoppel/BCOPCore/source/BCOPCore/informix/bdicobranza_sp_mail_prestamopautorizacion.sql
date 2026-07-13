CREATE PROCEDURE "informix".sp_mail_prestamopautorizacion(pempresa char(3),Pcampana smallint )
--  execute  PROCEDURE "informix".sp_mail_prestamopautorizacion('001',2)
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(80)  AS mensaje_retorno;			
			
---DECLARACIONES
DEFINE cCodRet        	CHAR(6); 
DEFINE iSqlErr      	INTEGER;
DEFINE dtFechaHoy		DATE;
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
define pparam smallint;
DEFINE cNomEstado CHAR(20);
DEFINE cNomCiudad CHAR(20);
DEFINE iPagoVenc INTEGER;
DEFINE vSdoTotal1  DECIMAL(18,2);
DEFINE vMtoVencido1  DECIMAL(18,2);
DEFINE vMensualidad DECIMAL(18,2);
DEFINE vSdoTotal2   DECIMAL(18,2);
DEFINE vMtoVencido2 DECIMAL(18,2);
DEFINE vsaldo_total DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
--NUEVO
DEFINE vtarjeta char(20);
DEFINE vdia_pago smallint;
DEFINE vmail char(100);
DEFINE Vfecha_apertura DATE;
DEFINE VFECHA_PROX_PAGO DATE;
DEFINE Vmonto_otorgado DECIMAL(18,2);
DEFINE iCel SMALLINT;
DEFINE P_COD_RET        VARCHAR(6);
DEFINE P_MENSAJE        CHAR(80);
DEFINE cMensaje              VARCHAR(150);
DEFINE vproceso				  CHAR (4);
define vproxpago	date;
define vnumtarjeta char(20);
--define vdiapago char(2);
define vdiapago date;
DEFINE cproceso         CHAR(4);
define vpago_vencido  DECIMAL(18,2);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
define vfecha			date;
define vregistrostotal	integer;
define vcontador 		integer;
define vpri_dia_mes date;
define vapell_paterno	char(30);
define vnumprod 		char(4);
--define vcount			integer;
define iCount_CRE_APERTS integer;
define iCount_PP_APERTUS integer;
define iCount_PP_AUTORIZ integer;
define iCount_CRE_AUTORI integer;
define vvalor smallint;
define i integer;
define num smallint;
--define cNumProducto char(4);
DEFINE iCuentasProcesadas6300    INTEGER;
DEFINE iCuentasExcluidasXCel     INTEGER;
DEFINE iCuentasExcluidasXCel_CRE_APERTS   INTEGER;
DEFINE iCuentasProcesadas6400    INTEGER;
DEFINE iCuentasExcluidasXMail    INTEGER;


--SET DEBUG FILE TO 'prestamoautorizacion.out';
--TRACE ON;
---INICIALIZACIONES
let cproceso ='061';
LET iSqlErr             = 0;
LET cCodRet             = "000000";
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
LET cNomEstado = '';
LET cNomCiudad = '';
LET iPagoVenc = 0; 
LET vSdoTotal1 = 0;   
LET vMtoVencido1 = 0;
LET vMensualidad = 0;
LET vSdoTotal2 = 0;
LET vMtoVencido2 = 0;
LET vsaldo_total = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
LET vtarjeta = '';
LET vdia_pago = 0;
LET vmail = '';
--LET vcount = 0;
LET iCount_CRE_APERTS = 0;
LET iCount_PP_APERTUS = 0;
LET iCount_PP_AUTORIZ = 0;
LET iCount_CRE_AUTORI = 0;
LET Vmonto_otorgado = 0;
LET iCel = 0;
LET pparam = 0;
LET vproceso	='2027';
LET cMensaje    = 'PROCESO EXITOSO';
let vproxpago = date(1);
let vnumtarjeta = '';
--let vdiapago = '';
let vdiapago= date(1);
let vpago_vencido = 0;
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vfecha 			= date(1);
let vregistrostotal =0;
let vcontador = 0;
let vpri_dia_mes = date(1);
let vapell_paterno = '';
let vnumprod = '';
--let vcount = 0;
let i = 0;
LET num = 0;
LET P_COD_RET             = "000000";
LET P_MENSAJE          ='El proceso de las campañas APERTURAS se realizó correctamente.';
--LET cNumProducto '';
let iCuentasProcesadas6300           = 0;
let iCuentasExcluidasXCel            = 0;
let iCuentasExcluidasXCel_CRE_APERTS = 0;
let iCuentasProcesadas6400           = 0;
let iCuentasExcluidasXMail           = 0;


BEGIN
ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    LET P_COD_RET= iSqlErr;
    LET P_MENSAJE = 'Error al ejecutar el proceso.';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02') RETURNING cCodRet; 
    RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;
--SET DEBUG FILE TO 'prestamoaper.out';
--TRACE ON;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '01') RETURNING cCodRet; 
	   
     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SELECT NVL(fecha_ant ,'')
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';	
	let vpri_dia_mes = mdy(month(dtFechaHoy),day(1),year(dtFechaHoy));

--temporal solo para pruebas	
--let dtFechaHoy = mdy('01','16','2016');
--temporal solo para pruebas	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	set isolation to dirty read;
	SELECT valor_numerico into pparam
	FROM cb_param_campania
	WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;
		
		select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
	
	if (Pcampana = 1) then
	  DELETE FROM bdicobranza:cb_info_administrativa WHERE producto = '6300' and fecha_ejecucion <= today and num_campania = 12; end if;
	if (Pcampana = 2 and pparam = 0) then
	  DELETE FROM bdicobranza:cb_mail_cliente WHERE fecha_insert = dtFechaHoy and tipo_mensaje = 5 and  pagos_vencidos = 10; 
	  DELETE FROM bdicobranza:cb_mail_cliente WHERE fecha_insert = dtFechaHoy and tipo_mensaje = 6 and  pagos_vencidos = -1;end if;
	
/* Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	select valor_numerico 
		into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 9;*/ 

	let vfecha = date(dtFechaHoy) + 1 units day;
	
	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
	where id_mensaje = 'PP_APERTUS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	select nvl(count(*),0) into vtotal2
	from bdimnsj:mnsjr_trx_batch
	where id_mensaje = 'PP_APERTUS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	let vtotal = vtotal1 + vtotal2;
		
	---- consulta para saber cuantos registros faltan por buscar al mes	
	let vregistrostotal = vvalor_numerico - vtotal;
	
	if (day(vfecha) = 1 ) then 
		let vregistrostotal = vvalor_numerico;
	end if;
if (Pcampana = 1 ) then	
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,importe1)
		select  2, 'PP_APERTUS',numcte,current,apell_paterno,day(dtFechaHoy),100
		from bdinteg:si_cliente
		where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for

--	if (vtotal < vvalor_numerico) then  -- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	FOREACH		
    	SELECT NVL(a.numcte,''), NVL(a.num_credito,''), a.num_producto, NVL(b.num_cta,''),
    			f.mto_fin_ven_trasp,d.dia_corte
    	INTo cNumCte, cNumCred, vnumprod, cNumCta, iPagoVenc, vdiapago
    	FROM bdicred:"informix".sd_maecredcrd a, 
			bdicred:"informix".sd_ctascarg b,
    		bdicred:"informix".sd_maesdoscrd f,
			bdicred:sd_maecredanexocrd d
    	WHERE a.empresa = b.empresa	AND a.num_credito = b.num_credito
			AND f.empresa = a.empresa	AND f.num_credito = a.num_credito
			and d.empresa = a.empresa   and d.num_credito = a.num_credito
			AND b.naturaleza= 'A'
			AND a.num_producto in ('6300','7600','7700') --A.L.L. se ingresan los productos 7600 y 7700 
			--AND a.num_producto = '6300'
			and a.fecha_apertura = date(dtFechaHoy) 
			/*and a.num_credito in (select num_credito 
    						from bdicred:sd_movhiscrd
    						where empresa = '001'
    						and num_credito = a.num_credito 
    						and codigo_fun = '001'
    						and codigo_ref = 3
    						and monto <> 0)*/
							
		 let iCuentasProcesadas6300 = iCuentasProcesadas6300 + 1; ----A.L.L. --2015-07-02
		
		SELECT limit 1 capital_mto_cuota into vMensualidad
		FROM bdicred:sd_amortiza_creditocrd 
		WHERE empresa = '001'
            AND num_credito = cNumCred
			and fecha_cuota = (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd  
																where num_credito = cNumCred)	;	
							
		let vnumtarjeta = '';					
				
    	SELECT limit 1 e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
			INTO  cNomEstado, cNomCiudad --cEstado, cCiudad
    	FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
    	WHERE d.numcte= cNumCte
			AND d.tipo_dir= '1'
			AND d.estado = e.estado
			AND d.ciudad = c.ciudad
			AND c.estado = e.estado;
			  
		SELECT limit 1 d.telefono
			INTO cCel
		FROM bdinteg:"informix".si_telefonos_actual d
		WHERE d.numcte= cNumCte
			AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;
--A.L.L. --2015-07-02
		if cCel is null or cCel = '' then 
            LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
            CONTINUE foreach; 
        end if;
			  
	--	if (cCel <> '') then	
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
    		 
    	/*	IF cCel <> '' then
			if (cNumCred is not null) then
				INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
    						nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
							sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
    						causa,situacion,pago_vencido,pago_req_sms )
    			VALUES (pempresa, 12, vnumprod/*A.L.L.'6300'*//*, today, cNumCte, cNumCred, cNumCta, vtarjeta, cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, 
						vsaldo_total, vpago_minimo_total, vdiapago, v_sdo_venc_int_mora, 0/*iPagoVenc*//*, v_pago_min_sin_vdo, iCausa,cSituacion,vpago_vencido,vMensualidad ); */
    			LET iCount_PP_APERTUS = iCount_PP_APERTUS + 1;
				call bdimnsj:"informix".sp_registra_evento (2, 'PP_APERTUS' , cNumCte, cNumCred,vnumtarjeta, 2,
							cApellPat,day(vdiapago),'','','',vMensualidad,0,0,0,0, '', '')RETURNING P_COD_RET;

				let vcontador = vcontador + 1;
			--end if;
			--end if;
    	--end if;		
--		if (vcontador = vregistrostotal) then	exit FOREACH; end if; -- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	END FOREACH;	
	if (vcontador >= 1) then 
		let i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
			insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,importe1)
			select  2, 'PP_APERTUS',numcte,current,apell_paterno,day(dtFechaHoy),100
			from bdinteg:si_cliente
			where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				let num = num + 10;
		end for
	end if;
	--end if;  -- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)

    if iCount_PP_APERTUS > 0 then 
--		CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_APERTUS',iCount_PP_APERTUS) RETURNING cCodRet;
		CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_APERTUS',iCuentasProcesadas6300,iCuentasExcluidasXCel) RETURNING cCodRet;
    end if;

--A.L.L. --2015-07-02
--Genera cifras de control
    if iCuentasProcesadas6300 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs APERTUS PP : ' ||iCuentasProcesadas6300;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados PP : ' ||iCount_PP_APERTUS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

--A.L.L. --2015-07-02
--	let iCuentasExcluidasXCel            = 0;
	let iCuentasProcesadas6300           = 0;
	let iCuentasProcesadas6400           = 0;

	-----------------------------------------------CREDINOMINA----------------------------------------------
    LET vcontador = 0; let vdiapago= date(1);LET cNombre1	= '';LET cNombre2	= '';LET cApellPat	= '';LET cApellMat			= '';
    LET cNumCte	= '';LET cNumCta	= '';LET cNumCred	= '';LET iPagoVenc = 0; LET iCel = 0;
    LET vMensualidad = 0;LET cSituacion	= '';LET iCausa	= 0;LET cNomEstado = '';LET cNomCiudad = '';LET cCel = '';
--let vcount = 0;

   	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,importe1)
	select  2, 'CRE_APERTS',numcte,current,apell_paterno,day(dtFechaHoy),100
	from bdinteg:si_cliente
       where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
		let num = num + 10;
	end for

	FOREACH		
    	SELECT NVL(a.numcte,''), NVL(a.num_credito,''), NVL(b.num_cta,''),
    			f.mto_fin_ven_trasp,d.dia_corte
    	INTo cNumCte, cNumCred, cNumCta, iPagoVenc, vdiapago
    	FROM bdicred:"informix".sd_maecredcrd a, 
			bdicred:"informix".sd_ctascarg b,
    		bdicred:"informix".sd_maesdoscrd f,
			bdicred:sd_maecredanexocrd d
    	WHERE a.empresa = b.empresa	AND a.num_credito = b.num_credito
			AND f.empresa = a.empresa	AND f.num_credito = a.num_credito
			and d.empresa = a.empresa   and d.num_credito = a.num_credito
			AND b.naturaleza= 'A'
			AND a.num_producto = '6400'
			and a.fecha_apertura = date(dtFechaHoy) 
			/*and a.num_credito in (select num_credito 
    						from bdicred:sd_movhiscrd
    						where empresa = '001'
    						and num_credito = a.num_credito 
    						and codigo_fun = '001'
    						and codigo_ref = 3
    						and monto <> 0)*/
							
		--A.L.L. --2015-07-02					
		let iCuentasProcesadas6400 = iCuentasProcesadas6400 + 1;					
		
		SELECT limit 1 capital_mto_cuota into vMensualidad
		FROM bdicred:sd_amortiza_creditocrd 
		WHERE empresa = '001'
            AND num_credito = cNumCred
			and fecha_cuota = (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd  
																where num_credito = cNumCred)	;	
							
		let vnumtarjeta = '';					
				
    	SELECT limit 1 e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
			INTO  cNomEstado, cNomCiudad --cEstado, cCiudad
    	FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
    	WHERE d.numcte= cNumCte
			AND d.tipo_dir= '1'
			AND d.estado = e.estado
			AND d.ciudad = c.ciudad
			AND c.estado = e.estado;
			  
		SELECT limit 1 d.telefono
			INTO cCel
		FROM bdinteg:"informix".si_telefonos_actual d
		WHERE d.numcte= cNumCte
			AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ; 
			
		--A.L.L. --2015-07-02		
		if cCel is null or cCel = '' then 
            LET iCuentasExcluidasXCel_CRE_APERTS = iCuentasExcluidasXCel_CRE_APERTS + 1;
            CONTINUE foreach; 
        end if;
			  
	--	if (cCel <> '') then	
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
    	
		--A.L.L. --2015-07-02
    	/*	IF cCel <> '' then
			if (cNumCred is not null) then
				INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
    						nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
							sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
    						causa,situacion,pago_vencido,pago_req_sms )
    			VALUES (pempresa, 16, '6400', today, cNumCte, cNumCred, '', '', cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, 
						0, 0, vdiapago, 0, 0, 0, iCausa,cSituacion,0,vMensualidad ); */
    			LET iCount_CRE_APERTS = iCount_CRE_APERTS + 1;
    			call bdimnsj:"informix".sp_registra_evento (2, 'CRE_APERTS' , cNumCte, cNumCred,vnumtarjeta, 2,
							cApellPat,day(vdiapago),'','','',vMensualidad,0,0,0,0, '', '')RETURNING P_COD_RET;
							
				let vcontador = vcontador + 1;
			--end if;
			--end if;
    	--end if;		

	END FOREACH;	
	if (vcontador >= 1) then 
    	let i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,importe1)
		select  2, 'CRE_APERTS',numcte,current,apell_paterno,day(dtFechaHoy),100
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				let num = num + 10;
		end for
	end if;
end if;

if (Pcampana = 1 ) then	
    if iCount_CRE_APERTS > 0 then 
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_APERTS',iCount_CRE_APERTS) RETURNING cCodRet;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_APERTS',iCount_CRE_APERTS,null) RETURNING cCodRet;
    end if;

--		let vcount =0;

--Genera cifras de control
    if iCuentasProcesadas6400 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs CRE APERTS. : ' ||iCuentasProcesadas6400;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados CRE APERTS. : ' ||iCount_CRE_APERTS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel_CRE_APERTS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
end if;
	
	--A.L.L. --2015-07-02
--	let iCuentasExcluidasXCel            = 0;
	let iCuentasProcesadas6300           = 0;
	let iCuentasProcesadas6400           = 0;


if (Pcampana = 2) then
    let i = 0;
    LET num = 0;
    FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'PP_AUTORIZ',numcte,current,apell_paterno,0,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
                let num = num + 10;
    end for

	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1,fecha1,fecha2)
	select  1, 'CRE_AUTORI',numcte,current,apell_paterno,0,current,current
	from bdinteg:si_cliente
       where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
		let num = num + 10;
	end for

	FOREACH				
		SELECT a.numcte,a.num_credito,a.fecha_apertura,d.dia_corte, f.monto_otorgado,d.prox_fecha_pago,a.num_producto 
		INTO cNumCte, cNumCred, Vfecha_apertura,VFECHA_PROX_PAGO,Vmonto_otorgado,vproxpago ,vnumprod
		FROM bdicred:"informix".sd_maecredcrd a, 
		     bdicred:"informix".sd_maesdoscrd f,
		     bdicred:sd_maecredanexocrd d
		WHERE  f.empresa = a.empresa	AND f.num_credito = a.num_credito
        and d.empresa = a.empresa   and d.num_credito = a.num_credito
		and a.num_producto in ('6300','7600','7700','6400')	--A.L.L. se ingresan los productos 7600 y 7700 
		--and a.num_producto in ('6300','6400')
		and a.fecha_apertura = date(dtFechaHoy)
		
--		let iCuentasProcesadas6300 = iCuentasProcesadas6300 + 1; ----A.L.L. --2015-07-02
		
		let vnumtarjeta = '';	
		select  apell_paterno into vapell_paterno
		from bdinteg:si_cliente where empresa = '001' and numcte = cNumCte ;
		
		select limit 1 cte.correo_elec into vmail 
		from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = cNumCte and cte.status_correo ='A'
		and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = cNumCte and status_correo ='A');
		
		----A.L.L. --2015-07-02
/*		IF vmail IS NULL OR vmail = '' THEN 
            LET iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
            CONTINUE FOREACH; 
        END IF;*/
				
		--if (vmail <> '') then
			--if (cNumCred is not null) then
			if(vnumprod IN ('6300','7600','7700')) then --A.L.L. se ingresan los productos 7600 y 7700 
                let iCuentasProcesadas6300 = iCuentasProcesadas6300 + 1; 

                IF vmail IS NULL OR vmail = '' THEN 
                    LET iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
                    CONTINUE FOREACH; 
                END IF;

				if (pparam = 0) then
					call "informix".sp_mail_inserta_cliente (pempresa,5, cNumCte, cNumCred, vmail,0,Vmonto_otorgado,10,0,Vfecha_apertura,null,null,0,0,0,0,0)
					returning cCodRet;			
				end if;
                LET iCount_PP_AUTORIZ = iCount_PP_AUTORIZ + 1;
				call bdimnsj:"informix".sp_registra_evento (1, 'PP_AUTORIZ' , cNumCte, cNumCred,vnumtarjeta, 2,
							vapell_paterno,'','','','',0,0,0,0,0, vproxpago, today)RETURNING cCodRet;
			end if;
			--end if;
			if(vnumprod = '6400') then
                let iCuentasProcesadas6400 = iCuentasProcesadas6400 + 1;

				if (pparam = 0) then
					call "informix".sp_mail_inserta_cliente (pempresa,6, cNumCte, cNumCred, vmail,0,Vmonto_otorgado,-1,0,Vfecha_apertura,null,null,0,0,0,0,0)
					returning cCodRet;			
				end if;
                LET iCount_CRE_AUTORI = iCount_CRE_AUTORI + 1;
				call bdimnsj:"informix".sp_registra_evento (1, 'CRE_AUTORI' , cNumCte, cNumCred,vnumtarjeta, 2,
							vapell_paterno,'','','','',0,0,0,0,0, vproxpago, today)RETURNING cCodRet;
			end if;
		--end if;
		
	END FOREACH;

end if;

        if iCount_PP_AUTORIZ > 0 then
            let i = 0;
            LET num = 0;
            FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'PP_AUTORIZ',numcte,current,apell_paterno,0,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
                let num = num + 10;
            end for
        end if;
        if iCount_CRE_AUTORI > 0 then
            let i = 0;
            LET num = 0;
            FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1,fecha1,fecha2)
            select  1, 'CRE_AUTORI',numcte,current,apell_paterno,0,current,current
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
                let num = num + 10;
            end for
        end if

if (Pcampana = 2) then
--    if iCount_PP_AUTORIZ > 0 then
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_AUTORIZ',iCount_PP_AUTORIZ,iCuentasExcluidasXMail) RETURNING cCodRet;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('PP_AUTORIZ',iCuentasProcesadas6300,iCuentasExcluidasXMail) RETURNING cCodRet;
--    end if;

    if iCount_CRE_AUTORI > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_AUTORI',iCount_CRE_AUTORI) RETURNING cCodRet;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('CRE_AUTORI',iCount_CRE_AUTORI,null) RETURNING cCodRet;
	end if;
	
--Genera cifras de control
    if iCuentasProcesadas6300 > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs PP AUTORIZ. : ' ||iCuentasProcesadas6300 + iCuentasProcesadas6400;
       let cMensaje = trim(cMensaje) ||'    Email enviados PP AUTORIZ. : ' ||iCount_PP_AUTORIZ;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	   let cMensaje = 'Email enviados CRE AUTORI. : ' ||iCount_CRE_AUTORI;
       let cMensaje = 'Cuentas excluidas por error mail : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

/*	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet;
    END IF;	*/
end if;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03') RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
	 
END
END PROCEDURE;
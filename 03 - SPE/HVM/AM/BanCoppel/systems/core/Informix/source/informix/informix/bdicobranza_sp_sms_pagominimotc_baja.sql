CREATE PROCEDURE "informix".sp_sms_pagominimotc_baja()
returning char (6);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--2012-05-09
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1

--  execute procedure "informix".sp_sms_pagominimotc_baja();
----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte		char(20);
define vnumcredito	char(20);
define vnumtarjeta	char(20);
define vimporte		decimal(18,2);
define vfecha		date;
define vvalor_numerico	integer;

---DECLARACIONES
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
define vpago DECIMAL(18,2);
DEFINE Vfecha_apertura DATE;
DEFINE iCel SMALLINT;
DEFINE vdia_pago smallint;
define vpago_minimo  DECIMAL(18,2);
define vpago_vencido DECIMAL(18,2);


---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(6);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(80);
define vcontador			  INTEGER;
--define vcount				  integer;
define iCount_TCB_PAGMIS 	  integer; --A.L.L.
define vvalor 				  smallint;
define i 					  integer;
define num 					  smallint;

---INICIALIZACIONES
LET cNumCta				= '';
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
let vpago = 0;
LET iCel = 0;
LET vdia_pago = 0;
let vpago_minimo = 0;

let vnumcte = '';
let vnumcredito = '';
let vnumtarjeta = '';
let vimporte	=0;
let vfecha		= date(1);

let SQL_ERR		= 0;
let ISAM_ERR	= 0;
let ERROR_INFO	= '';
let P_COD_RET	= '000000';
let P_MENSAJE	= 'PROCESO EXITOSO';
let vproceso	= '2045';
let cMensaje	= '';
let vpago_vencido = 0;
let vvalor_numerico	= 0;
LET vcontador 	= 0;
--let vcount 		= 0;
let iCount_TCB_PAGMIS = 0;
let i = 0;
		LET num = 0;


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02')RETURNING P_COD_RET;	
        RETURN P_COD_RET;
    END EXCEPTION;


  --Set debug file to 'sp_sms_pagominimotc.out';
  --trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING 	P_COD_RET;
		
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
	
	DELETE FROM bdicobranza:cb_info_administrativa WHERE empresa ='001' and fecha_ejecucion <= vfecha and num_campania = 18; 
		
	let vfecha = vfecha - 1 units month;
	let vfecha = mdy(month(vfecha),day(21),year(vfecha));
--let vfecha = '01-01-2010';--'05-08-2012';	

	select valor_numerico 
		into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 4;
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
			
    set isolation to dirty read;

	FOREACH
	
		SELECT a.numcte, a.num_credito
			INTO vnumcte, vnumcredito
		FROM bdicred:sd_maecred a,/*bdicred:sd_sdos_cartera_linea b,*/
                bdicred:sd_maecredanexo m,
				bdicred:sd_maesdos c
		WHERE a.empresa = '001'
			AND m.empresa = a.empresa AND m.num_credito = a.num_credito 
			AND a.num_producto = '6001'
			and a.num_credito = c.num_credito
            and a.status_cred in('AA','E1')
			and (c.monto_vencido + c.mto_venc_trasp) = 0
			and a.campo_trab3 = 'BAJA'
            and m.fecha_ult_pago <= today
            and m.fecha_ult_pago >= vfecha
			
			-- si el pago minimo es matoy a lo k dio el c
		select f.mto_fin_ven_trasp,f.monto_financiado into iPagoVenc,vpago_minimo
		from bdicred:"informix".sd_maesdos f
		where f.empresa = '001' AND f.num_credito = vnumcredito;
		
		if (vpago_minimo > 0	) then		
			SELECT limit 1 e.nombre, c.nombre 
				INTO  cNomEstado, cNomCiudad  
			FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
			WHERE d.numcte= vnumcte
				AND d.tipo_dir= '1'
				AND d.estado = e.estado
				AND d.ciudad = c.ciudad
				AND c.estado = e.estado;
			
			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
				and t.num_credito = vnumcredito
				and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
					and tar.num_credito = vnumcredito
					and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
				and t.tipo_tarjeta ='T'  and t.status_tar = 'A';  
		
			SELECT limit 1 d.telefono
		    INTO cCel
			FROM bdinteg:"informix".si_telefonos_actual d
			WHERE d.numcte= vnumcte
		    AND d.tipo_tel= '2' and status_tel = 'A' and d.cofetel ='V' ;
			 
			if (cCel <> '') then
		    LET iCel = LENGTH(cCel) + 1 - 10;
    
		    IF cCel <> '' then
				IF ( LENGTH(cCel) > 10 ) THEN
			       LET cCel = SUBSTR(cCel,iCel,10);
				ELIF ( LENGTH(cCel) < 10 ) THEN
                    LET cCel ='';
			    END IF;			
			END IF;
		
			SELECT limit 1 NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
			INTO cNombre1, cNombre2, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
			WHERE numcte= vnumcte;		
		
			SELECT  {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
				INTO cSituacion, iCausa
			FROM bdisitesp:"informix".se_ctessitespcte
			WHERE numcte = vnumcte;
			
			IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
			IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
			
			if (cCel <> '') then
				if (vnumcredito is not null) then
				INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
						nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
						sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
						causa,situacion,pago_vencido ,pago_req_sms)
				VALUES ('001', 18, '6001', today, vnumcte, vnumcredito, cNumCta, vnumtarjeta, cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, 
				vsaldo_total, vpago_minimo, vdia_pago, v_sdo_venc_int_mora, iPagoVenc, v_pago_min_sin_vdo, 
				iCausa,cSituacion,vpago_vencido ,vpago_minimo);
				--A.L.L.
				LET iCount_TCB_PAGMIS = iCount_TCB_PAGMIS +1;
				call bdimnsj:"informix".sp_registra_evento (2, 'TCB_PAGMIS' , vnumcte, vnumcredito,vnumtarjeta, 2,
							cApellPat,'','','','',vpago_minimo,0,0,0,0, '', '')RETURNING P_COD_RET;
				LET vcontador = vcontador + 1 ;
				end if;
			end if;
			end if;
		end if;
		if (vcontador = vvalor_numerico) then exit FOREACH; end if;
	END FOREACH
	
	if (vcontador >= 1) then 
	let i = 0;
		LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
		select  2, 'TCB_PAGMIS',numcte,current,apell_paterno,100
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for
	end if;
				

	--A.L.L.
	IF iCount_TCB_PAGMIS > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCB_PAGMIS',iCount_TCB_PAGMIS) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCB_PAGMIS',iCount_TCB_PAGMIS,null) RETURNING P_COD_RET;
	END IF;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03')RETURNING 	P_COD_RET;
    RETURN P_COD_RET;

end;
end procedure;
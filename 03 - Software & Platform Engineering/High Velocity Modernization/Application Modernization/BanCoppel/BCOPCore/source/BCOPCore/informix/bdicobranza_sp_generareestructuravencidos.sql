CREATE PROCEDURE "informix".sp_generareestructuravencidos()
--execute procedure "informix".sp_generareestructuravencidos();
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(80)  AS mensaje_retorno;			
			
---DECLARACIONES
DEFINE cCodRet        	CHAR(06); 
DEFINE P_COD_RET      	CHAR(06);
DEFINE iSqlErr      	INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cMensaje 		CHAR(150);
DEFINE P_MENSAJE        CHAR(80);
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
DEFINE cproceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
DEFINE vvcCod_ret       CHAR(5);
DEFINE iCel SMALLINT;
DEFINE vpago_vencido	DECIMAL(18,2);
DEFINE vvalor_numerico	INTEGER; DEFINE vtotal1 INTEGER; DEFINE vtotal INTEGER; DEFINE vregistrostotal INTEGER; DEFINE vmora SMALLINT;
define vcontador integer;
DEFINE vpri_dia_mes DATE; 
--define vcount integer;
define vvalor smallint;
define i integer;
define num smallint;
define iCount_REST_MOR1S integer;
define iCount_REST_MOR2S integer;
DEFINE sCampana			smallint; --ALL
DEFINE iCuentasProcesadas   INTEGER;
DEFINE iCuentasExcluidasXCel INTEGER;
DEFINE iCuentasExcluidasXCel_REST_MOR1S INTEGER;
DEFINE iCuentasExcluidasXCel_REST_MOR2S INTEGER;
DEFINE iCuentasProcesadas_REST_MOR1S    INTEGER;
DEFINE iCuentasProcesadas_REST_MOR2S    INTEGER;

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCod_ret      	 = '000000';
LET vvcCod_ret = '';
LET cCodRet             = "000000";
LET P_COD_RET             = "000000";
LET cMensaje      	 = '';
LET P_MENSAJE      	 = 'El proceso de las campañas REST_MORAS se realizó correctamente.';
LET isam_err	  	 = 0;
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
LET cproceso      = '0059';
let iCel = 0;
let vpago_vencido = 0;
let vvalor_numerico	= 0; let vtotal1 = 0; let vtotal = 0; let vregistrostotal = 0; let vmora = 0;
let vcontador = 0;
let vpri_dia_mes = date(1);
--let vcount = 0;
let i = 0;
		LET num = 0;
let iCount_REST_MOR1S = 0;
let iCount_REST_MOR2S = 0;
let sCampana		  = 0; --ALL
let iCuentasProcesadas = 0;
let iCuentasExcluidasXCel = 0;
let iCuentasExcluidasXCel_REST_MOR1S = 0;
let iCuentasExcluidasXCel_REST_MOR2S = 0;
let iCuentasProcesadas_REST_MOR1S = 0;
let iCuentasProcesadas_REST_MOR2S = 0;


BEGIN
ON EXCEPTION SET iSqlErr, isam_err, error_info
	LET P_COD_RET= iSqlErr;
--	LET cMensaje = error_info;
    LET P_MENSAJE = 'Error al ejecutar el proceso.';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, cMensaje, '02')  RETURNING cCodRet;   
	RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/ALL/sp_generareestructuravencidos.out';
--TRACE ON;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, cMensaje, '01')  RETURNING cCodRet;   

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;
	
	SELECT valor_numerico
	INTO cDiasAnticipados
	FROM bdicobranza:"informix".cb_param_campania
	WHERE tipo_campania = 3
	AND num_parametro=  1;	
	
	SELECT NVL(fecha_hoy ,''),pri_dia_mes
	INTO dtFechaHoy,vpri_dia_mes
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	--DELETE bdicobranza:"informix".cb_info_administrativa WHERE empresa = '001' and num_campania = 11 and fecha_ejecucion <= dtFechaHoy;
	
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
	
FOREACH 
	select valor_numerico / 2 
	into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro in (5,6)
	let vmora = vmora + 1;

   	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
          insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
          select  2, 'REST_MOR'||vmora||'S',numcte,current,apell_paterno,100
            from bdinteg:si_cliente
           where numcte in (select  substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			
		let num = num + 10;
	end for

	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
	where id_mensaje = 'REST_MOR'||vmora||'S' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	---- consulta para saber cuantos registros faltan por buscar al mes	
	let vregistrostotal = vvalor_numerico - vtotal1;

	if (day(dtFechaHoy) = 3 ) then 
		let vregistrostotal = vvalor_numerico;
	end if;
	
if 	(vmora <= 2 ) then
	
	FOREACH 				
		SELECT NVL(a.numcte,''), NVL(a.num_credito,''), NVL(b.num_cta,''), f.mto_fin_ven_trasp, 
            (f.sdo_capital + f.monto_vencido + f.mto_venc_trasp + f.cap_tras_no_venci) + round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ suc.iva),2)  SdoTotal1,
            (f.monto_vencido + f.mto_venc_trasp) + round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ .16),2) MtoVencido1,
            (f.monto_financiado - f.monto_vencido - f.mto_venc_trasp) Mensualidad ,
			f.monto_vencido + f.mto_venc_trasp
		INTO	 cNumCte, cNumCred, cNumCta, iPagoVenc, vSdoTotal1, vMtoVencido1, vMensualidad, vpago_vencido
		FROM bdicred:"informix".sd_maecredcrd a, 
		     bdicred:"informix".sd_ctascarg b,
		     bdicred:"informix".sd_maesdoscrd f,
		     bdinteg:si_sucursales suc
		WHERE a.empresa = b.empresa
			AND a.num_credito = b.num_credito
			AND f.empresa = a.empresa
			AND f.num_credito = a.num_credito
			AND f.mto_fin_ven_trasp = vmora
			AND a.status_cred IN ('BT', 'BA', 'VP', 'E1', 'E2', 'E3')
			AND (f.monto_vencido + f.mto_venc_trasp) > 0
			AND b.naturaleza= 'A'
			AND a.num_producto = '6011'
			AND a.sucursal = suc.sucursal
			AND a.campo_trab3 <> 'BAJA'
			
			let iCuentasProcesadas = iCuentasProcesadas + 1;
			    
		SELECT (sum(interes_debe - interes_pagado) + sum(iva_debe - iva_pagado)) Saldo_Total ,               
               (sum(interes_debe - interes_pagado) +sum(iva_debe - iva_pagado)) Monto_Vencido
			INTO vSdoTotal2, vMtoVencido2
        FROM bdicred:sd_amortiza_creditocrd am,  bdicred:sd_maecredcrd cr,  bdinteg:si_sucursales suc
		WHERE am.empresa = cr.empresa
			AND cr.empresa = suc.empresa
			AND am.num_credito = cr.num_credito
			AND am.num_credito = cNumCred
			AND cr.sucursal = suc.sucursal
			AND am.capital_status in ('2','7','6');	
		
         LET vsaldo_total=  nvl(vSdoTotal1, 0) + nvl(vSdoTotal2, 0);  --Saldo Total
         LET v_sdo_venc_int_mora = nvl(vMtoVencido1, 0) + nvl(vMtoVencido2, 0); --Vencido
         LET v_pago_min_sin_vdo =  nvl(vMensualidad, 0);   --Mensualidad
         LET vpago_minimo_total = nvl(v_pago_min_sin_vdo,0) + nvl(v_sdo_venc_int_mora, 0);  --- Pago minimo   

		
		SELECT  e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
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
		--ALL
/*		IF cCel IS NULL OR cCel = '' THEN 
            LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
            CONTINUE FOREACH; 
        END IF;*/

		--IF Nvl(cCel,'') <> '' then
			LET iCel = LENGTH(cCel) + 1 - 10;
			--IF cCel <> '' then
				IF ( LENGTH(cCel) > 10 ) THEN
					LET cCel = SUBSTR(cCel,iCel,10);
				ELIF ( LENGTH(cCel) < 10 ) THEN
                    LET cCel ='';
				END IF;
			--END IF;
    
			SELECT NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
			INTO cNombre1, cNombre2, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
			WHERE numcte= cNumCte;		
		
			SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 nvl(situacion, ''),  nvl(causa, 0)
			INTO   cSituacion, iCausa
			FROM bdisitesp:"informix".se_ctessitespcte
			WHERE numcte = cNumCte;
		 
		/*	if nvl(cCel,'') <>'' then
				INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
							nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
							situacion, causa,pago_vencido,pago_req_sms)
				VALUES ( '001', 11, '6011', dtFechaHoy, cNumCte, cNumCred, cNumCta, '', cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, vsaldo_total, 
						vpago_minimo_total, '', v_sdo_venc_int_mora, iPagoVenc, v_pago_min_sin_vdo, cSituacion, iCausa,vpago_vencido,vpago_minimo_total);
		*/
				if (vmora = 1) then
                    let iCuentasProcesadas_REST_MOR1S = iCuentasProcesadas_REST_MOR1S + 1;

                    IF cCel IS NULL OR cCel = '' THEN 
                        LET iCuentasExcluidasXCel_REST_MOR1S = iCuentasExcluidasXCel_REST_MOR1S + 1;
                        CONTINUE FOREACH; 
                    END IF;

                    let iCount_REST_MOR1S	= iCount_REST_MOR1S +1;
					let sCampana = 11;
                end if;
                if (vmora = 2) then
                    let iCuentasProcesadas_REST_MOR2S = iCuentasProcesadas_REST_MOR2S + 1;

                    IF cCel IS NULL OR cCel = '' THEN 
                        LET iCuentasExcluidasXCel_REST_MOR2S = iCuentasExcluidasXCel_REST_MOR2S + 1;
                        CONTINUE FOREACH; 
                    END IF;

                    let iCount_REST_MOR2S	= iCount_REST_MOR2S +1;	
					let sCampana = 20;
                end if;

				call bdimnsj:"informix".sp_registra_evento (2, 'REST_MOR'||vmora||'S' , cNumCte, cNumCred,'', 2,
							cApellPat, '','','','',vpago_minimo_total,0,0,0,0, '', '')RETURNING cCodRet;
					
			let vcontador = vcontador + 1;
			
			call "informix".sp_inserta_info_rep_envios ('001','SMS',sCampana, cNumCred, cNumCte, '6011', today,cCel,cSituacion,iCausa,vpago_minimo_total) returning P_COD_RET;
			let sCampana = 0;
			--end if;
		--END IF;
--		if (vcontador = vregistrostotal) then	exit FOREACH; end if; -- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	END FOREACH;
	
	if (vcontador >= 1) then 
    	let i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
            select  2, 'REST_MOR'||vmora||'S',numcte,current,apell_paterno,100
            from bdinteg:si_cliente
            where numcte in (select  substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				
			let num = num + 10;
		end for
	end if;
end if;
	let vvalor_numerico	= 0; let vtotal1 = 0; let vtotal = 0; let vregistrostotal = 0; let vcontador = 0;
	
END FOREACH;


--    if iCount_REST_MOR1S > 0 then
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MOR1S',iCount_REST_MOR1S,iCuentasExcluidasXCel_REST_MOR1S) RETURNING cCodRet;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MOR1S',iCuentasProcesadas_REST_MOR1S,iCuentasExcluidasXCel_REST_MOR1S) RETURNING cCodRet;
--    end if;

--    if iCount_REST_MOR2S > 0 then
--    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MOR2S',iCount_REST_MOR2S,iCuentasExcluidasXCel_REST_MOR2S) RETURNING cCodRet;
    	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_MOR2S',iCuentasProcesadas_REST_MOR2S,iCuentasExcluidasXCel_REST_MOR2S) RETURNING cCodRet;
--    end if;

--Genera cifras de control
	if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campañas SMS MOR1S : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    SMS enviados SMS MORA 1 REST : ' ||iCount_REST_MOR1S;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'SMS enviados SMS MORA 2 REST : ' ||iCount_REST_MOR2S;
	   let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel_REST_MOR1S + iCuentasExcluidasXCel_REST_MOR2S;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
	end if;
--Genera cifras de control

/*	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
		RETURN cCodRet;
    END IF;
*/	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCod_ret, cMensaje, '03')  RETURNING cCodRet;   

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;
	
	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente. 
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Se realiza procedimiento para la obtencion de la informacion de campaña 17 de la tabla cb_info_administrativa',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 10/05/2011',
'BD    : BDICOBRANZA',
'Version: 20110526.1305',
'20110922 Agregar cálculos de Saldos y Vencidos. Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_ivr_genarch_edocta(pEmpresa CHAR(3))

RETURNING CHAR(12);
/*__________________________________________________________________________________________________________________________________________________________________________
--'Creado por: Abrham López L.'
--'Fecha: 24/11/2011.'
--'Descripción: Proceso para la generación del archivo ivr para llamadas robotizadas para encuetas del estado de cuenta.'
--'Base de Datos: BDICOBRANZA.'
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- Modificado por: Abrham López L., fecha 04-04-2013. Se realiza homologación de sp para buscar los estados de cuenta en la instancia de PLD
*/
--DECLARACION DE VARIABLES.
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE cruta                CHAR(100);
DEFINE vproceso				CHAR(30);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE vEmpresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE pFecha               DATE;
DEFINE vTotalctecd          INTEGER;
DEFINE vNum_credito 		CHAR(20);
DEFINE vNombre1 			CHAR(26);
DEFINE vNombre2 			CHAR(26);
DEFINE vApellido1 			CHAR(26);
DEFINE vApellido2 			CHAR(26);
DEFINE vTelcasa 			CHAR(13);
DEFINE vTelcelular  		CHAR(13);
DEFINE vMoras 				INTEGER;
DEFINE vCiudad_coppel		SMALLINT;
DEFINE vNombreciudad 		VARCHAR(60,1);
DEFINE vRegioncobranza 		CHAR(30);
DEFINE vMonto 				DECIMAL(18,2);
DEFINE vAntiguedadcte		DATE;
DEFINE vMaxfechaemision     DATE;
DEFINE vNomciudadcop        VARCHAR(120,1);
DEFINE vNumciudadcop        SMALLINT;
DEFINE vNomregion           CHAR(30);
DEFINE vCampania            SMALLINT;
DEFINE vNumProducto         CHAR(4);
DEFINE sPaso                SMALLINT;
DEFINE vpri_dia_mes         DATE;

DEFINE cnomarchitemp		CHAR(100);
DEFINE cnomarchitem         CHAR(100);
DEFINE cCadena				CHAR(2500);
DEFINE vNom_ciudad          CHAR(30);

--SET DEBUG FILE TO "/resplogifx/archivoscartera/IVR_EDOCTA.out";
--TRACE ON;

--INICIALIZACION DE VARIABLES.
LET sql_err                 = "";
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '3002';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET vEmpresa                = "";
LET cdelimitador            = "";
LET vTotalctecd				= 0;
LET vNum_credito 			= "";
LET vNombre1 				= "";
LET vNombre2 				= "";
LET vApellido1 				= "";
LET vApellido2 				= "";
LET vTelcasa 				= "";
LET vTelcelular 			= "";
LET vMoras 					= "";
LET vCiudad_coppel			= "";
LET vNombreciudad 			= "";
LET vRegioncobranza 		= "";
LET vMonto 					= 0;
LET vAntiguedadcte			= '01-01-1900';
LET vMaxfechaemision        = '01-01-1900';
LET vNomciudadcop           = "";
LET vNumciudadcop           = 0;
LET vNomregion              = "";
LET vCampania               = 0; 
LET vNumProducto            = "";
LET sPaso                   = 0;
LET cnomarchitemp			= "";
LET cnomarchitem            = "";
LET cCadena   				= "";
LET vNom_ciudad				= "";
LET vpri_dia_mes            = '01-01-1900';
 
--INICIA PROCESO
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;
	
--SE INSERTA EN BITACORA CUANDO INICIA EL PROCESO.
	CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');

--DIRECTIVA PARA LECTURA DE TABLAS BLOQUEADAS.
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SACAR FECHA DEL DIA DE HOY.
	Select Fecha_Hoy, pri_dia_mes
         Into pFecha, vpri_dia_mes
		From bdicred:sd_fechas
		Where empresa = pEmpresa;
	
	LET vMaxfechaemision = date(vpri_dia_mes) - 1 units day;
	
	LET vMaxfechaemision = mdy(month(vMaxfechaemision),20,year(vMaxfechaemision)); 

--SACAMOS LA EMPRESA.
    SELECT empresa
		INTO vEmpresa
		FROM bdinteg:si_empresas
		WHERE empresa = pEmpresa;
--VALIDACION QUE EXISTA LA EMPRESA.
	IF NVL (vEmpresa, '') = '' THEN
        LET cCod_Ret= '104002';
		SELECT descripcion
            INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

		CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
			RETURN cCod_ret;
    END IF;

--OBTENER CARACTER DELIMITADOR.
    SELECT trim(valor_alfabetico)
        INTO cdelimitador
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pEmpresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 2;
--VALIDA QUE EXISTA EL CARACTER DELIMITADOR.
    IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
		SELECT descripcion
			INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

		IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

		CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
			RETURN cCod_ret;
    END IF;

--OBTENER LA RUTA DEL ARCHIVO.
	SELECT TRIM(valor_alfabetico)
		INTO cruta
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pEmpresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 36;
--VALIDA QUE EXISTA LA RUTA.
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
		SELECT descripcion
			INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

		IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
            RETURN cCod_ret;
    END IF;

--OBTIENE EL NOMBRE DEL ARCHIVO.
    SELECT TRIM(valor_alfabetico)
        INTO cnombre
		FROM bdicobranza:cb_param_campania
		WHERE empresa = pEmpresa
		AND tipo_campania = 1
		AND grupo_parametro = 'ARCHIVOS'
		AND num_parametro = 48;		
--VALIDA QUE EXISTA PARAMETRO DE NOMBRE DE ARCHIVO.
	IF NVL(cnombre,'') = '' THEN
        LET cCod_Ret= '104006';
		SELECT descripcion
			INTO cMensaje
			FROM cb_errores
			WHERE origen = 3
			AND codigo_error = cCod_Ret;

		IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;

		CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '01');
			RETURN cCod_ret;
    END IF;
	
	--SELECCIONAMOS EL NUMERO DE CAMPAÑA
		select id_campania 
			into vCampania
			from bdicobranza:cb_campanias
			where empresa = pEmpresa 
			and id_campania = 20;
			
--BORRAMOS LA TABLA DONDE SE INSERTARON LOS DATOS PARA FORMAR EL ARCHIVO SI ESTA EXISTE.		
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname = 'cb_temp_ivr_edocta';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_temp_ivr_edocta;
            END IF; 

--CREAMOS TABLA DONDE INSERTAREMOS LOS DATOS PARA FORMAR ARCHIVO.
    create table bdicobranza:cb_temp_ivr_edocta (
			cliente          CHAR(20),
			num_credito      CHAR(20),
			nombre1          CHAR(26),
			nombre2          CHAR(26),
			apellido1        CHAR(26),
			apellido2        CHAR(26),
			telcasa          CHAR(13),
			telcelular       CHAR(13),
			mora             INTEGER,
			ciudad_coppel    SMALLINT,
			nombreciudad     VARCHAR(60,1),
			regioncobranzas  CHAR(30),
			monto_otorgado   DECIMAL(18,2),
			fecha_insert     DATE,
			primary key (cliente, num_credito) 
			);
			
	--SACAMOS LA MAXIMA FECHA DE EMISION DEL ESTADO DE CUENTA DE TC.		
	--	select limit 1 max(fecha_emision)
	--	 into vMaxfechaemision
	--	 from bdicred@pld_tcp:sd_encabezado_edocta;
		
	--SE HACE EL COUNT DE CLIENTES, DE LOS CUALES SACAREMOS EL 10%
		SELECT  direccion_del, COUNT(fecha_emision) total_porciudad, num_producto
				FROM bdicred@pld_tcp:sd_encabezado_edocta
				WHERE fecha_emision = vMaxfechaemision
				and num_credito not in (select num_credito from bdicobranza:cb_ivr_edocta)
				AND num_producto = '6001'
		GROUP BY direccion_del, num_producto
		INTO temp sd_total_cte_porciudad;
		
		LET cnomarchitemp =  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
		LET cnomarchitem =  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';

	--SELECCIONAMOS EL 10% DE CLIENTES POR CIUDAD.
		FOREACH	WITH HOLD
		
			SELECT round(nvl(nvl(a.total_porciudad,0) * (.10), 0)), b.numerociudad,trim(b.nombreciudad), c.nombre_region
				INTO vTotalctecd, vNumciudadcop, vNom_ciudad, vNomregion
				FROM sd_total_cte_porciudad a, bdinteg:si_catciudades b, bdinteg:si_regiones c
					WHERE a.direccion_del = b.nombreciudad
					AND a.num_producto = '6001'--vNumProducto
					AND b.numero_region = c.numero_region	
			GROUP BY total_porciudad, b.numerociudad,b.nombreciudad, c.nombre_region
	--END FOREACH;			
	--VALIDACION PARA QUE SI EL 10% DE CLIENTES ES IGUAL A CERO YA NO SIGA.
            IF nvl(vTotalctecd,0) <= 0 THEN
			CONTINUE foreach;
			END IF
						
			LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchitemp) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
			
			LET cSQL2 = " select  LIMIT "||vTotalctecd	
						|| " a.numcte, a.num_credito, trim(c.nombre1)nombre, trim(c.nombre2)nombre2, trim (c.apell_paterno)apellido1, trim (c.apell_materno)apellido2, "
						|| " 	trim(substr(tel1.telefono,length(tel1.telefono)-9,10)) as telcasa, "
						|| " 	trim(substr(tel2.telefono,length(tel2.telefono)-9,10)) as telcelular, "
						|| " 	b.mto_fin_ven_trasp::integer No_Vencidos," ||vNumciudadcop|| ", '"||trim(vNom_ciudad)||"', '"||trim(vNomregion)||"', b.monto_otorgado, a.fecha_apertura "
					--	|| " 	b.mto_fin_ven_trasp::integer No_Vencidos,b.monto_otorgado, a.fecha_apertura "
						|| " 	from bdicred:sd_maecred a "
						|| " 	join bdicred:sd_maesdos b on (a.empresa = b.empresa and a.num_credito = b.num_credito) "
						|| " 	join bdicred:sd_maecredanexo d on (a.empresa = d.empresa and a.num_credito = d.num_credito) "
						|| " 	join bdinteg:si_cliente c on (a.numcte = c.numcte)"
						|| " 	join bdinteg:si_direcciones_actual dir  on (a.numcte = dir.numcte )"
						|| " 	join bdinteg:si_telefonos tel1 on (tel1.numcte = dir.numcte and tel1.tipo_tel = 1 and "
						|| " 		tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = dir.numcte and tipo_tel = 1)) and (nvl(tel1.telefono,'')<> '') "
						|| " 	join bdinteg:si_telefonos tel2 on (tel2.numcte = dir.numcte and tel2.tipo_tel = 2 and "
						|| " 		tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = dir.numcte and tipo_tel = 2)) and (nvl(tel2.telefono,'') <> '') "
						|| " 	where a.status_cred in ('AA','BT','BA','E1','E2','E3') "
						|| " 	and a.fecha_apertura < '"||vMaxfechaemision||"' "   
						|| " 	and dir.tipo_dir = 1 "
						|| " 	and dir.numerociudad = "||vNumciudadcop||" ";

				LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchIVRedocta1.sql';

				LET cSQL = trim(cSQL1) ||RTRIM(cSQL2) || trim(cSQL3);
				System cSQL;

				LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchIVRedocta1.sql';
				System cSQL;

				LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchIVRedocta1.sql';
				System cSQL;

			 --BORRA EL ULTIMO CARACTER DELIMITADOR Y PASA EL ARCHIVO YA SIN EL DELIMITADOR FINAL A OTRO ARCHIVO.
				LET cSQl = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchitemp) || " >> " || TRIM(cRuta) || TRIM(cnomarchitem);
				SYSTEM cSQL;
				
				--Borra el archivo de control.
				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchIVRedocta1.sql';
				SYSTEM cSQL;

				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cruta) || cnomarchitemp;
				SYSTEM cSQL;  
		--END IF;
	END FOREACH; 
	IF DBINFO("sqlca.sqlerrd2") > 0 --A.L.L
	THEN
--TOMAMOS EL ARCHIVO PARA INSERTARLO EN LA TABLA
	LET cCadena = 'echo " load from '|| SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cnomarchitem,1,
	LENGTH(cnomarchitem))  || ' insert into bdicobranza:cb_temp_ivr_edocta " >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'carga_EDOCTA.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
    let cCadena = 'dbaccess bdicobranza ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'carga_EDOCTA.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));	
	
--BORRA EL ARCHIVO DE CONTROL.
    let cCadena = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'carga_EDOCTA.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
	
	let cCadena = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cnomarchitem;    System SUBSTR(cCadena,1,LENGTH(cCadena));
	
	
-------------------------------------------------SE GENERA EL ARCHIVO FINAL PARA CAMPAÑA IVR EDOCTA------------------------------------------------------------------------------	

--VALIDAR QUE EXISTE EL ARCHIVO.
	LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
	LET cnomarchivo =  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = " select  cliente, num_credito, nombre1, nombre2, apellido1, apellido2, telcasa, telcelular, mora, ciudad_coppel, trim(nombreciudad), trim(regioncobranzas), monto_otorgado, fecha_insert "
                    || " from bdicobranza:cb_temp_ivr_edocta " ;

    LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchIVRedocta2.sql';

	LET cSQL = trim(cSQL1) ||RTRIM(cSQL2) || trim(cSQL3);
    System cSQL;

	LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchIVRedocta2.sql';
	System cSQL;

	LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchIVRedocta2.sql';
	System cSQL;

 --BORRA EL ULTIMO CARACTER DELIMITADOR Y PASA EL ARCHIVO YA SIN EL DELIMITADOR FINAL A OTRO ARCHIVO.
	LET cSQl = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
	SYSTEM cSQL;

--BORRA EL ARCHIVO DE CONTROL.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchIVRedocta2.sql';
	SYSTEM cSQL;

	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
--INSERTAMOS EN LA TABLA LOS NUMEROS DE CREDITO TOMADOS EN ESTA GENERACION DE CAMPAÑA PARA NO TOMARLOS EN CUENTA DE NUEVO EN LA SIGUIENTE VUELTA.
	INSERT INTO bdicobranza:"informix".cb_ivr_edocta(empresa, num_credito, campania, fecha_insert)
	select vEmpresa, num_credito, vCampania, today
	FROM bdicobranza:cb_temp_ivr_edocta;
	
	
--SE INSERTA EN BITACORA  CUANDO FINALIZA EL PROCESO
	CALL bdicobranza:"informix".inserta_bitacora_cob(pEmpresa, vproceso, cCod_ret, cMensaje, '03');
	end if
	RETURN cCod_ret;

END;
END PROCEDURE;
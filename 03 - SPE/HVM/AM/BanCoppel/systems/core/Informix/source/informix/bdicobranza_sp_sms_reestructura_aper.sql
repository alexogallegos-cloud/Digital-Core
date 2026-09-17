CREATE PROCEDURE "informix".sp_sms_reestructura_aper()

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
DEFINE vdia_pago date;
DEFINE vmail char(100);
DEFINE Vfecha_apertura DATE;
DEFINE iCount_REST_APES     integer;
DEFINE iCuentasProcesadas   integer;
DEFINE iCuentasExcluidasXCel integer;
DEFINE VFECHA_PROX_PAGO DATE;
DEFINE Vmonto_otorgado DECIMAL(18,2);
DEFINE iCel SMALLINT;
define vproxpago	date;
define vnumtarjeta char(20);
define vdiapago date;
define vvalor_numerico	INTEGER;
define vtotal1			INTEGER;
define vtotal2			INTEGER;
define vtotal			INTEGER;
define vfecha			date;
define vregistrostotal	integer;

DEFINE cproceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
--DEFINE vvcCod_ret       CHAR(5);
DEFINE vcontador 		INTEGER;
DEFINE vpri_dia_mes		DATE;
define vvalor smallint;
define i integer;
define num smallint;
DEFINE cMensaje              VARCHAR(150);
DEFINE P_COD_RET        VARCHAR(6);
DEFINE P_MENSAJE        CHAR(80);
DEFINE cEmpresa         CHAR(03);


---INICIALIZACIONES
LET cCod_ret      	 = '000000';
--LET vvcCod_ret = '';
LET cproceso      = '2036';

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
LET vdia_pago = date(1);
LET vmail = '';
LET iCount_REST_APES = 0;
LET iCuentasProcesadas = 0;
LET iCuentasExcluidasXCel = 0;
LET Vmonto_otorgado = 0;
LET iCel = 0;
let vproxpago = date(1);
let vnumtarjeta = '';
let vdiapago = date(1);
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vfecha			= date(1);
let vregistrostotal	=0;
LET vcontador = 0;
LET vpri_dia_mes = DATE(1);
LET i = 0;
LET num = 0;
LET cMensaje    = '';
LET P_COD_RET   = "000000";
LET P_MENSAJE   ='El proceso de las campañas APERTURAS REE se realizó correctamente.';
LET cEmpresa = '001';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    LET P_COD_RET= iSqlErr;
    LET cMensaje = 'Error al ejecutar el proceso ';
    LET P_MENSAJE = 'Error al ejecutar el proceso ';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '02')  RETURNING cCodRet;
    RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;

--  SET DEBUG FILE TO 'apertura.out';
--  TRACE ON;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '01')  RETURNING cCodRet;   

	SELECT NVL(fecha_ant ,'')
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = cEmpresa;	
	let vpri_dia_mes = mdy(month(dtFechaHoy),day(1),year(dtFechaHoy));

--temporal solo para pruebas	
	--let dtFechaHoy =today;
--temporal solo para pruebas	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	DELETE FROM bdicobranza:cb_info_administrativa 
	WHERE empresa =cEmpresa and producto = '6011' and fecha_ejecucion <= today and num_campania = 17; 
		
	let vfecha = date(dtFechaHoy) + 1 units day;
	select valor_numerico 
	into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 7;
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
	where id_mensaje ='REST_APES' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	select nvl(count(*),0) into vtotal2
	from bdimnsj:mnsjr_trx_batch
	where id_mensaje ='REST_APES' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	let vtotal = vtotal1 + vtotal2;
	---- consulta para saber cuantos registros faltan por buscar al mes	
	let vregistrostotal = vvalor_numerico - vtotal;
		
	if (day(vfecha) = 1 ) then 
		let vregistrostotal = vvalor_numerico;
	end if;
	
if (vtotal < vvalor_numerico )then 			
	FOREACH		
    	SELECT  NVL(a.numcte,''), NVL(a.num_credito,''), NVL(b.num_cta,''),
    		d.dia_corte/*::char(2)*/,d.prox_fecha_pago
    		INTO	 cNumCte, cNumCred, cNumCta,  vdiapago,vdia_pago
    	FROM bdicred:"informix".sd_maecredcrd a, 
			bdicred:"informix".sd_ctascarg b,
    		bdicred:sd_maecredanexocrd d
    	WHERE a.empresa = b.empresa	AND a.num_credito = b.num_credito
			and d.empresa = a.empresa   and d.num_credito = a.num_credito
			AND b.naturaleza= 'A'
			AND a.num_producto = '6011'
			and a.fecha_apertura = date(dtFechaHoy) 

        let iCuentasProcesadas = iCuentasProcesadas + 1;

		let vnumtarjeta = '';					
								 
    	SELECT e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
    	INTO cNomEstado, cNomCiudad --cEstado, cCiudad
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

		if cCel is null or cCel = '' then 
			LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
			CONTINUE foreach; 
		end if;

--		if (cCel <> '') then
			LET iCel = LENGTH(cCel) + 1 - 10;
    	  
			IF cCel <> '' then
				IF ( LENGTH(cCel) > 10 ) THEN
      			   LET cCel = SUBSTR(cCel,iCel,10);
				ELIF ( LENGTH(cCel) < 10 ) THEN
                    LET cCel ='';
      			END IF;
    		END IF;
    
    		SELECT NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
    		INTO cNombre1, cNombre2, cApellPat, cApellMat
    		FROM bdinteg:"informix".si_cliente
    		WHERE numcte= cNumCte;		
    		
    		SELECT {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
    			INTO cSituacion, iCausa
    		FROM bdisitesp:"informix".se_ctessitespcte
    	 	WHERE numcte = cNumCte;
    		 
     		IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
    		IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
    		 
--    		if (nvl(cCel,'') <>'' ) then
    			INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
    						nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
    						causa,situacion )
    			VALUES (cEmpresa, 17, '6011', today, cNumCte, cNumCred, cNumCta, vnumtarjeta, cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, vsaldo_total, 
    						vpago_minimo_total, vdiapago, v_sdo_venc_int_mora, 0, v_pago_min_sin_vdo, iCausa,cSituacion );
				
				call bdimnsj:"informix".sp_registra_evento (2, 'REST_APES' , cNumCte, cNumCred,vnumtarjeta, 2,
							cApellPat, day(vdiapago)::char(2),'','','',0,0,0,0,0, '', '')RETURNING cCodRet;
				
				LET vcontador = vcontador + 1;
                LET iCount_REST_APES = iCount_REST_APES + 1;
--    		end if;
--    	end if;	
		if (vcontador = vregistrostotal) then	exit FOREACH; end if;
	END FOREACH;
end if;	
	if (vcontador >= 1) then 
    	let i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2)
            select  2, 'REST_APES',numcte,current,apell_paterno,day(today)::char(2)
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
            let num = num + 10;
        end for
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_APES',iCount_REST_APES) RETURNING cCodRet;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('REST_APES',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING cCodRet;
	end if;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00001';  --No hay informacion
--		RETURN P_COD_RET,P_MENSAJE;
    END IF;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs REST_APES : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados REST_APES : ' ||iCount_REST_APES;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error mail : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCod_ret, cMensaje, '03')  RETURNING cCodRet;   
	
	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.	 
END
END PROCEDURE;
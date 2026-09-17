CREATE PROCEDURE "informix".sp_generafechpagoreestructura_baja()
       RETURNING char(6), char(150);
--DECLARACION DE VARIABLES	   
DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE cempresa			CHAR(3);
DEFINE cMensaje 		CHAR(150);
DEFINE cNumcte          CHAR(20);
DEFINE cNumCredito      CHAR(20);
DEFINE cNumProducto		CHAR(4);
DEFINE cPagos_vencidos  DECIMAL(18,2);
DEFINE dFecha_hoy       DATE;
DEFINE dFechaHoy        DATE;
DEFINE dFechaPago       DATE;
DEFINE cCelular         CHAR(13);
DEFINE cCuenta          CHAR(20);
DEFINE cInstruccion     SMALLINT;
DEFINE csituacion       CHAR(1);
DEFINE ccausa			SMALLINT;
DEFINE cccCod_ret       CHAR(5);
DEFINE dFechaApertura   DATE;
DEFINE cnombre1         CHAR(26);
DEFINE cnombre2         CHAR(26);
DEFINE cApellMaterno    CHAR(26);
DEFINE cApellPater		CHAR(26);
DEFINE cTipored         CHAR(10);
DEFINE cNum_carrier_cat CHAR(3);
DEFINE cciudad          CHAR(20);
DEFINE cestado          CHAR(20);
DEFINE cNomEstado       CHAR(20);
DEFINE cNomCiudad       CHAR(20);
DEFINE cproceso         CHAR(4);
DEFINE vvcCod_ret       CHAR(6);
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
define vnumtarjeta		char(20);
define vfechapago		date;
DEFINE iCel             SMALLINT;
define vpago_vencido	DECIMAL(18,2);
define vvalor_numerico  integer;
define vcontador        integer;
--define vcount 	integer;
--define iCount_REST_PAGS integer;
define iCount_RESTB_PAGS integer;
define vvalor   smallint;
define i        integer;
define num      smallint;
DEFINE iCuentasProcesadas      INTEGER;
DEFINE iCuentasExcluidasXCel   INTEGER;

DEFINE vSucursal		CHAR(4);
DEFINE vIVA				DECIMAL(5,3);
DEFINE vMtoFinVenTrasp	DECIMAL(18,2);
DEFINE vSdoCap			DECIMAL(18,2);	
DEFINE vMtoVencido		DECIMAL(18,2);
DEFINE vMtoVencTrasp	DECIMAL(18,2);
DEFINE vCapTrasNoVenc	DECIMAL(18,2);
DEFINE vSdoMora			DECIMAL(18,2);
DEFINE vSdoContaMora	DECIMAL(18,2);
DEFINE vMtoFinan		DECIMAL(18,2);
DEFINE vNumCteMail		CHAR(20);


--INICIALIZACION DE VARIABLES
LET cempresa         = '001';
LET cCod_ret      	 = '000000';
LET sql_err       	 = 0;
LET isam_err	  	 = 0;
--LET cMensaje      	 = 'PROCESO EXITOSO';
LET cMensaje      	 = 'El proceso de la campaña PAGO COMPL REEST BAJA se ejecutó correctamente.';
LET cNumcte       	 = '';
LET cNumCredito   	 = '';
LET cNumProducto  	 = '';
LET cPagos_vencidos  = 0;
LET cCelular      	 = '';
LET cCuenta			 = '';
LET csituacion		 = '';
LET ccausa			 = 0;
LET cccCod_ret    	 = '';
LET cnombre1      	 = '';
LET cnombre2      	 = '';
LET cApellMaterno 	 = '';
LET cApellPater	  	 = '';
LET cTipored      	 = '';
LET cNum_carrier_cat = '';
LET cciudad          = '';
LET cestado          = '';
LET cNomEstado       = '';
LET cNomCiudad       = '';
LET cproceso         = '2040';
LET vvcCod_ret       = '';
LET dFechaPago       = DATE(1);
LET iPagoVenc        = 0; 
LET vSdoTotal1       = 0;
LET vMtoVencido1     = 0;
LET vMensualidad     = 0;
LET vSdoTotal2       = 0;
LET vMtoVencido2     = 0;
LET vsaldo_total     = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
let vnumtarjeta	= '';
let vfechapago	= date(1);
let iCel        = 0;
let vpago_vencido   = 0;
let vvalor_numerico = 0;
let vcontador       = 0;
--let vcount = 0;
--let iCount_REST_PAGS = 0;
let iCount_RESTB_PAGS = 0;
let i   = 0;
LET num = 0;
LET iCuentasProcesadas      = 0;
LET iCuentasExcluidasXCel   = 0;

LET vSucursal		= '';
LET vIVA			= 0;
LET vMtoFinVenTrasp	= 0;
LET vSdoCap			= 0;
LET vMtoVencido		= 0;
LET vMtoVencTrasp	= 0;
LET vCapTrasNoVenc	= 0;
LET vSdoMora		= 0;
LET vSdoContaMora	= 0;
LET vMtoFinan		= 0;
LET vNumCteMail		= '';


--SET DEBUG FILE TO 'sp_generafechpagoreestructura_baja.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
	    LET cCod_ret = sql_err;
--	    LET cMensaje = error_info;
        LET cMensaje      	 = 'Error al ejecutar el proceso.';
	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING vvcCod_ret;
         RETURN cCod_ret, cMensaje;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING vvcCod_ret;   

	if vvcCod_ret != '000000' then
        let cCod_ret = vvcCod_ret;
        let cMensaje  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN cCod_ret,cMensaje;
    end if;

 --Se obtiene fecha hoy		
    SELECT fecha_hoy 
    INTO dFecha_hoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';

--temporal solo para pruebas
--let dFecha_hoy=today;
--temporal solo para pruebas
-- Se calcula fecha de consulta para que el foreach se posicione 5 días antes del corte de las Reestructuras que son los días 02 y 17 de cada mes 
    if day(dFecha_hoy) >= 1 and day(dFecha_hoy) <= 2 then  
       let dFechaHoy = mdy(month(dFecha_hoy),2,year(dFecha_hoy));
    elif day(dFecha_hoy) >= 27 and day(dFecha_hoy) <= 31 then  
       let dFechaHoy = mdy(month(dFecha_hoy),2,year(dFecha_hoy)) + 1 units month;
    elif day(dFecha_hoy) >= 14 and day(dFecha_hoy) <= 17 then  
       let dFechaHoy = mdy(month(dFecha_hoy),17,year(dFecha_hoy));
    else
       let cCod_ret = '999999';
       let cMensaje = 'Hoy no es día de ejecución del proceso PAGO COMPL REEST BAJA.';
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, cProceso, cCod_ret, cMensaje, '02')  RETURNING vvcCod_ret;   
       RETURN cCod_ret, cMensaje;
     end if;
-- Se calcula fecha de consulta para que el foreach se posicione 5 días antes del corte de las Reestructuras que son los días 02 y 17 de cada mes 
	BEGIN;
		DELETE bdicobranza:"informix".cb_info_administrativa WHERE num_campania = 9 and fecha_ejecucion <= dFecha_hoy;
	COMMIT;

	select valor_numerico
	into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 8;
	let vvalor_numerico = vvalor_numerico /2;
	
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
	
	SELECT a.fecha_apertura, a.numcte, a.num_credito, a.num_producto, a.sucursal
	FROM bdicred:"informix".sd_maecredcrd a
	WHERE a.num_producto  	= '6011' 
	AND a.campo_trab3 		= 'BAJA' 
	AND a.status_cred IN ('BT','BA','AA','VP','E1','E2','E3')
	INTO TEMP cred_rees_vig WITH NO LOG;
	
    FOREACH
		--Se obtienen los creditos con reestructura otorgada
/*		SELECT  a.fecha_apertura, a.numcte, a.num_credito, a.num_producto,b.num_cta, f.mto_fin_ven_trasp,
           (f.sdo_capital + f.monto_vencido + f.mto_venc_trasp + f.cap_tras_no_venci) + round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ suc.iva),2)  SdoTotal1,
           (f.monto_vencido + f.mto_venc_trasp) + round((f.sdo_moratorio + f.sdo_contab_mora) * (1+ .16),2) MtoVencido1,
           (f.monto_financiado - f.monto_vencido - f.mto_venc_trasp) Mensualidad ,ax.prox_fecha_pago,
		    f.monto_vencido + f.mto_venc_trasp
		INTO  dFechaApertura, cNumCte, cNumCredito, cNumProducto, cCuenta, iPagoVenc, vSdoTotal1, vMtoVencido1, vMensualidad,vfechapago,
			vpago_vencido
		FROM bdicred:"informix".sd_maecredcrd a, bdicred:"informix".sd_ctascarg b,
		     bdicred:"informix".sd_maesdoscrd f, bdinteg:"informix".si_sucursales suc, bdicred:"informix".sd_maecredanexocrd ax 
		WHERE a.empresa         = cempresa
			AND a.num_credito   >= ''
			AND b.empresa       = a.empresa
			AND b.naturaleza    = 'A'    
			AND b.num_credito   = a.num_credito
			AND f.empresa       = a.empresa 
			AND f.num_credito   = a.num_credito
			AND suc.empresa     = a.empresa 
			AND suc.sucursal    = a.sucursal
			AND ax.empresa      = a.empresa  
			AND ax.num_credito  = a.num_credito
			AND a.status_cred IN ('BT','BA','AA','VP','E1','E2','E3')
			AND a.num_producto  = '6011' 
			AND a.campo_trab3   = 'BAJA'*/
--			AND ax.prox_fecha_pago - 5 units day = date(dFecha_hoy)
/*			AND ax.prox_fecha_pago= date(dFechaHoy)
*/
		SELECT 	fecha_apertura, numcte, 	num_credito, 	num_producto, sucursal
			into dFechaApertura, cNumCte, 	cNumCredito,	cNumProducto, vSucursal
		FROM cred_rees_vig
		
		SELECT suc.iva into vIVA 
		FROM bdinteg:"informix".si_sucursales suc WHERE suc.sucursal = vSucursal;
		
		SELECT ax.prox_fecha_pago INTO vfechapago 
		FROM bdicred:"informix".sd_maecredanexocrd ax
		WHERE ax.num_credito = cNumCredito
		AND ax.prox_fecha_pago= date(dFechaHoy);
		
		SELECT f.mto_fin_ven_trasp, f.sdo_capital, f.monto_vencido, f.mto_venc_trasp, f.cap_tras_no_venci, f.sdo_moratorio, f.sdo_contab_mora, f.monto_financiado
			into iPagoVenc,			vSdoCap,		vMtoVencido,	vMtoVencTrasp,		vCapTrasNoVenc,		vSdoMora,		vSdoContaMora,		vMtoFinan
		FROM bdicred:"informix".sd_maesdoscrd f WHERE f.num_credito = cNumCredito;
		
		SELECT b.num_cta into cCuenta 
		FROM bdicred:"informix".sd_ctascarg b
		WHERE b.num_credito = cNumCredito
		AND b.naturaleza    = 'A';
		
		LET vSdoTotal1 = (NVL(vSdoCap,0) + NVL(vMtoVencido,0) + NVL(vMtoVencTrasp,0) + NVL(vCapTrasNoVenc,0)) + round((NVL(vSdoMora,0) + NVL(vSdoContaMora,0)) * (1+ vIVA),2);
		LET vMtoVencido1 = (NVL(vMtoVencido,0) + NVL(vMtoVencTrasp,0)) + round((NVL(vSdoMora,0) + NVL(vSdoContaMora,0)) * (1+ .16),2);
		LET vMensualidad = (NVL(vMtoFinan,0) - NVL(vMtoVencido,0) - NVL(vMtoVencTrasp,0));
		LET vpago_vencido = NVL(vMtoVencido,0) + NVL(vMtoVencTrasp,0);

		let iCuentasProcesadas = iCuentasProcesadas + 1;

/*		select LIMIT 1 t.num_tarjeta into vnumtarjeta
		from bdicred:sd_tarjeta t
		where t.empresa = '001'
			and t.num_credito = cNumCredito
			and t.secuencia = (select max(tar.secuencia)
                   from bdicred:sd_tarjeta tar
                   where tar.empresa = '001'
                   and tar.num_credito = cNumCredito
                   and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A'; 

		SELECT (sum(interes_debe - interes_pagado) + sum(iva_debe - iva_pagado)) Saldo_Total ,               
            (sum(interes_debe - interes_pagado) +sum(iva_debe - iva_pagado)) Monto_Vencido
		INTO vSdoTotal2, vMtoVencido2
        FROM bdicred:sd_amortiza_creditocrd am,  bdicred:sd_maecredcrd cr,  bdinteg:si_sucursales suc
        WHERE am.empresa = cr.empresa
			AND cr.empresa = suc.empresa
			AND am.num_credito = cr.num_credito
			AND am.num_credito = cNumCredito
    		AND cr.sucursal = suc.sucursal
			AND am.capital_status in ('2','7');	*/
		
        LET vsaldo_total=  nvl(vSdoTotal1, 0) + nvl(vSdoTotal2, 0);  --Saldo Total
        LET v_sdo_venc_int_mora = nvl(vMtoVencido1, 0) + nvl(vMtoVencido2, 0); --Vencido
        LET v_pago_min_sin_vdo =  nvl(vMensualidad, 0);   --Mensualidad
        LET vpago_minimo_total = nvl(v_pago_min_sin_vdo,0) + nvl(v_sdo_venc_int_mora, 0);  --- Pago minimo  

 
		--Se obtienen los datos del cliente, Nombre, estado, ciudad y telefono
/*		SELECT a.apell_paterno,a.apell_materno,a.nombre1,a.nombre2, e.nombre, c.nombre --b.estado,b.ciudad 
		INTO cApellPater,cApellMaterno,cNombre1,cNombre2, cNomEstado, cNomCiudad --cEstado,cCiudad
		FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_direcciones_actual b,
			bdinteg:"informix".si_estados e, bdinteg:"informix".si_ciudades c
		WHERE a.numcte= b.numcte
			AND b.numcte=cNumCte
			AND b.tipo_dir=1
			AND b.estado = e.estado
			AND b.ciudad = c.ciudad
			AND c.estado = e.estado;*/

		SELECT limit 1 d.telefono
		INTO cCelular
		FROM bdinteg:"informix".si_telefonos_actual d
		WHERE d.numcte= cNumCte
		    AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;

        if cCelular is null or cCelular = '' then 
            let iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
            CONTINUE foreach; 
        end if;

		IF DAY(dFechaApertura) >= 3 AND DAY(dFechaApertura) <=16  THEN
			CALL bdicred:"informix".monthadd(dFecha_hoy,-1) RETURNING dFechaPago;
			LET dFechaPago= MDY(month(dFechaPago),2,year(dFechaPago));
		ELSE 
			IF DAY(dFechaApertura) >= 17 OR DAY(dFechaApertura) <=2 THEN
				CALL bdicred:"informix".monthadd(dFecha_hoy,-1) RETURNING dFechaPago;
				LET dFechaPago= MDY(month(dFechaPago),17,year(dFechaPago));
			END IF;
 		END IF;   
					--END IF;									
		LET csituacion =null;
		LET ccausa= null;
						
/*		SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 nvl(situacion, ''),  nvl(causa, 0)
		INTO   csituacion, ccausa
		FROM bdisitesp:"informix".se_ctessitespcte
		WHERE numcte = cNumCte;*/
						
--		IF Nvl(cCelular,'') <> '' then
			LET iCel = LENGTH(cCelular) + 1 - 10;
--			IF cCelular <> '' then
				IF ( LENGTH(cCelular) > 10 ) THEN
					LET cCelular = SUBSTR(cCelular,iCel,10);
				ELIF ( LENGTH(cCelular) < 10 ) THEN
					LET cCelular ='';
				END IF;
--			END IF;
			
--			IF cCelular <> '' then
/*				INSERT INTO bdicobranza:"informix".cb_info_administrativa(empresa,num_campania,producto,fecha_ejecucion,cliente, credito, cuenta,tarjeta,ciudad, estado, 
                   apell_paterno,apell_materno,nombre1,nombre2, t_celular, sdo_total,pago_min,fecha_pago,sdo_venc_int_mora,pago_venc,pago_min_sin_vdo,situacion,causa,pago_vencido,pago_req_sms)
				VALUES(cempresa,9,cNumProducto,dFecha_hoy,cNumCte, cNumCredito,cCuenta, '', cNomCiudad, cNomEstado, cApellPater,cApellMaterno,cNombre1,cNombre2, cCelular,
                   vsaldo_total, vpago_minimo_total, dFechaPago, v_sdo_venc_int_mora, iPagoVenc, v_pago_min_sin_vdo, nvl(csituacion, ''),nvl(ccausa, 0),vpago_vencido,vpago_minimo_total);*/
				--A.L.L.
				LET iCount_RESTB_PAGS = iCount_RESTB_PAGS +1;
				call bdimnsj:"informix".sp_registra_evento (2, 'RESTB_PAGS' , cNumCte, cNumCredito,vnumtarjeta, 2,
							day(dFechaPago)::char(2), month(dFechaPago)::char(2),'','','',vpago_minimo_total,0,0,0,0, '', '')RETURNING vvcCod_ret;
--							cApellPater, day(dFechaPago)::char(2),month(dFechaPago)::char(2),'','',vpago_minimo_total,0,0,0,0, '', '')RETURNING vvcCod_ret;
							
				let vcontador = vcontador + 1;
--			end if;
--		END IF;	
	if (vcontador = vvalor_numerico) then	exit FOREACH; end if;
	END FOREACH;  
	
	select valor from bdicobranza:cb_param where empresa = '001' and cod_param = 57 
	INTO TEMP envio_mail_sms WITH NO LOG;
	
	if (vcontador >= 1) then 
	let i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
		insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
--		select  2, 'RESTB_PAGS',numcte,current,apell_paterno,day(dFecha_hoy)::char(2),day(dFecha_hoy)::char(2),100
		select  2, 'RESTB_PAGS',numcte,current,day(dFecha_hoy)::char(2),month(dFecha_hoy)::char(2),'',100
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from envio_mail_sms);
			let num = num + 10;
		end for
	end if;
	--A.L.L.
	IF iCount_RESTB_PAGS > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('RESTB_PAGS',iCount_RESTB_PAGS) RETURNING vvcCod_ret;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('RESTB_PAGS',iCount_RESTB_PAGS,null) RETURNING vvcCod_ret;
	END IF;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs RECOR. PAGO REESTR. BAJA : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados REESTR. : ' ||iCount_RESTB_PAGS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING vvcCod_ret;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING vvcCod_ret;
    end if;
--Genera cifras de control

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, cProceso, cCod_ret, cMensaje, '03')  RETURNING vvcCod_ret;   

	if vvcCod_ret != '000000' then
        let cCod_ret = vvcCod_ret;
        let cMensaje  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN cCod_ret,cMensaje;
    end if;

    LET cMensaje = 'El proceso de la campaña PAGO COMPL REEST BAJA se ejecutó correctamente.';

    RETURN cCod_ret, cMensaje;

	END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Se realiza procedimiento para obtener la informacion que corresponda a la campaña 9 según condiciones especificas y almacena en la tabla cb_info_administrativa',
'AUTOR : Maria Elena Angulo Aispuro ',
'FECHA : 02/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110602.1733',
'20110922 Ajustar longitud de telefono, obtención de descripción ciudad y estado. Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_migra_tablas_cobranza_pba()
       RETURNING CHAR(6), CHAR(80);

-- execute procedure "informix".sp_migra_tablas_cobranza();

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cMensaje 		    CHAR(200);
define P_MENSAJE			CHAR(80);
DEFINE cCod_ret             CHAR(6);

----------------------------------------------------------------------
DEFINE vproceso				CHAR(4);
DEFINE Vempresa				CHAR(3);
DEFINE Vnum_campana			SMALLINT;
DEFINE vcliente             CHAR(20);
DEFINE vcredito             CHAR(20);
DEFINE Vproducto			CHAR(4);
DEFINE VfechaEnvio			DATE;
DEFINE vciudad              CHAR(10);
DEFINE vestado              CHAR(10);
DEFINE vt_celular           CHAR(13);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cApellMat			CHAR(26);
DEFINE vMora				SMALLINT;
DEFINE vsdo_venc_int_mora   DEC(18,2);
DEFINE vpago_min            DEC(18,2);
DEFINE vpago_min_sin_vdo    DEC(18,2); 
DEFINE vpago_venc           DEC(18,2); 
DEFINE vpago_req_sms		DEC(18,2);
DEFINE vCosto				DEC(18,2);
DEFINE vResultadoEntrega	CHAR(15);
DEFINE vPagoDia1			DEC(18,2);
DEFINE vPagoDia2			DEC(18,2);
DEFINE vPagoDia3			DEC(18,2);
DEFINE vPagoDia4			DEC(18,2);
DEFINE vPagoDia5			DEC(18,2);
DEFINE vPagoNdias			DEC(18,2);
DEFINE vEstatusResultado	CHAR(02);
DEFINE vFechaCambioEstatus  DATE;
DEFINE vResultadoMora		SMALLINT;
DEFINE vFechaApertura		DATE;
DEFINE vFechaPrimerConsumo  DATE;
DEFINE vLineaCredito		DEC(18,2);
DEFINE vTipoTransaccion		CHAR(30);
DEFINE vMontoTransaccion	DEC(18,2);
DEFINE vPorcentaje_uso      DEC(18,2);
DEFINE vCorreoElec			CHAR(100);
DEFINE vPagoReqEmail		DEC(18,2);
DEFINE vCount				CHAR(1);

DEFINE iCuentasProcesadas   INTEGER; 
DEFINE iCuentasInsertadas   INTEGER; 
DEFINE iCuentasEliminadas   INTEGER; 

DEFINE c_sucursal			CHAR(4);
DEFINE d_fecha_insert		DATE;
DEFINE c_usuario			CHAR(8);
DEFINE d_pago_min			DECIMAL(14,2);
DEFINE d_saldo_vencido		DECIMAL(14,2);
DEFINE d_pago_realizado		DECIMAL(14,2);
DEFINE d_pct_cump_pm		DECIMAL(5,2);
DEFINE d_pct_cump_sv		DECIMAL(5,2);
DEFINE c_folio_suc			CHAR(16);
DEFINE c_reversado			CHAR(1);
DEFINE dt_hora_mov			DATETIME YEAR to SECOND;
DEFINE c_transacc_suc		CHAR(4);
DEFINE c_codigo_fun			CHAR(3);

DEFINE v_transaccion		CHAR(7);
DEFINE v_ip					CHAR(20);
DEFINE v_fecha				DATE;
DEFINE v_hora				DATETIME HOUR to FRACTION(3);
DEFINE v_numcte				CHAR(20);
DEFINE v_ejecutivo			CHAR(8);
DEFINE v_apellido_pat		CHAR(26);
DEFINE v_apellido_mat		CHAR(26);
DEFINE v_pri_nombre			CHAR(26);
DEFINE v_seg_nombre			CHAR(26);
DEFINE v_codigo_retorno		CHAR(6);
--DEFINE vtoday				DATE;
DEFINE dtFecha_hoy          DATE;
DEFINE dtFecha_mes_anterior DATE;
DEFINE iCuentasInsertadas_2 INTEGER;

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET vcliente         	= '';
LET vcredito        	= '';
LET Vproducto 			= '';
LET VfechaEnvio 		= DATE(1);
LET vciudad          = '';
LET vestado          = '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET vMora				= 0;
LET vCosto				= 0;
LET vResultadoEntrega	= '';
LET vPagoDia1			= 0;
LET vPagoDia2			= 0;
LET vPagoDia3			= 0;
LET vPagoDia4			= 0;
LET vPagoDia5			= 0;
LET vPagoNdias			= 0;
LET vEstatusResultado	= '';
LET vFechaCambioEstatus = DATE(1);
LET vResultadoMora		= 0;
LET vFechaApertura		= DATE(1);
LET vFechaPrimerConsumo = DATE(1);
LET vLineaCredito		= 0;
LET vTipoTransaccion	= '';
LET vMontoTransaccion	= 0;
LET vPorcentaje_uso		= 0;
LET vCorreoElec			= '';
LET vPagoReqEmail		= 0;
LET vpago_req_sms		= 0;
LET vCount 				= '1';

LET iCuentasProcesadas  = 0;
LET iCuentasInsertadas  = 0;
LET iCuentasEliminadas  = 0;

LET c_sucursal			= '';
LET d_fecha_insert		= DATE(1);
LET c_usuario			= '';
LET d_pago_min			= 0;
LET d_saldo_vencido		= 0;
LET d_pago_realizado	= 0;
LET d_pct_cump_pm		= 0;
LET d_pct_cump_sv		= 0;
LET c_folio_suc			= '';
LET c_reversado			= '';
LET dt_hora_mov			= DATE(1);
LET c_transacc_suc		= '';
LET c_codigo_fun		= '';

LET v_transaccion		= '';
LET v_ip				= '';
LET v_fecha				= DATE(1);
LET v_hora				= DATE(1);
LET v_numcte			= '';
LET v_ejecutivo			= '';
LET v_apellido_pat		= '';
LET v_apellido_mat		= '';
LET v_pri_nombre		= '';
LET v_seg_nombre		= '';
LET v_codigo_retorno	= '';
--LET vtoday				= today;

LET dtFecha_hoy          = DATE(1);
LET dtFecha_mes_anterior = DATE(1);
LET iCuentasInsertadas_2 = 0;
---------------------------------------

SET DEBUG FILE TO '/DBA/INC/20240604/sp_migra_tablas_cobranza_tr.out';
TRACE ON;

	LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = '';
	LET P_MENSAJE     = 'El proceso de migracion de tablas de cobranza se realizó correctamente.';
	LET vproceso	  = '0119';
 

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET P_MENSAJE = error_info;
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret; 
		LET cCod_ret = sql_err;
		RETURN cCod_ret, P_MENSAJE;
	END EXCEPTION;

--------------------------------------------------------------------------

	CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 

	--se obtiene la informacion
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
-----------------------------------SE OBTIENE EL NUMERO DE LA TABLA A TRABAJAR----------------------------------------
	SELECT TRIM(valor) 
	INTO vCount 
	FROM "informix".cb_param 
	WHERE empresa = '001'
	AND cod_param = '86';

	IF vCount IS NULL OR vCount = '' THEN	
		LET cCod_ret = '000010';
		LET P_MENSAJE = 'NO SE ENCUENTRA EL VALOR DEL NUMERO DE LA TABLA A TRABAJAR';
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret;
		LET cCod_ret = '000010';
		RETURN cCod_ret, P_MENSAJE;	
	ELIF vCount < '1' or vCount > '4' THEN
		LET cCod_ret = '000020';
		LET P_MENSAJE = 'EL VALOR DEL NUMERO DE LA TABLA A TRABAJAR NO ES VALIDO';
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret;
		LET cCod_ret = '000020';
		RETURN cCod_ret, P_MENSAJE;	
	end if;

	SELECT fecha_hoy into dtFecha_hoy 
      FROM bdinteg:si_fechas
     WHERE empresa = '001';	  
	  
	LET dtFecha_mes_anterior = dtFecha_hoy - 1 units month;
	
	IF vCount = '1' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
		SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
			nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
			resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
			fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso 
		FROM "informix".cb_rep_resultado_sms
		WHERE empresa = '001'
		INTO TEMP cb_sms WITH NO LOG;
		
		CREATE INDEX idx_cb_sms ON cb_sms(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_sms; 

		FOREACH WITH HOLD
		
			SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
				nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
				resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
				fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso 
			INTO Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1,
				cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto,
				vResultadoEntrega, vPagoDia1,vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
				vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso
			FROM "informix".cb_sms
			WHERE empresa = '001'

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;
				INSERT INTO "informix".cb_rep_resultado_sms_hist (
					empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
					nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
					resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
					fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso)
				VALUES(Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1,
					cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto,
					vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
					vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;

-----------------------------------Borramos los clientes de la tabla cb_rep_resultado_sms----------------------	
				DELETE 
				FROM "informix".cb_rep_resultado_sms 
				WHERE empresa = Vempresa 
				AND num_campana = Vnum_campana 
				AND num_credito = vcredito 
				AND fecha_envio = VfechaEnvio;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas +1;
				
			COMMIT WORK;
			
		LET Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1 = '', 0, '', '', '', DATE(1), '', '', '', '';
		LET cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto = '', '', '', 0, 0, 0, 0, 0, 0, 0;
		LET vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora = '', 0, 0, 0, 0, 0, 0, '', DATE(1), 0;
		LET vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso = DATE(1), DATE(1), 0, '', 0, 0;
			
		END FOREACH;
		
	DROP TABLE cb_sms;
	
-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       LET cMensaje = 'TOTAL cuentas PROCESADAS SMSs : ' || iCuentasProcesadas;
	       LET cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS SMSs a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL cuentas ELIMINADAS SMSs : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;
		
-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '2';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';

	END IF;
	
	IF vCount = '2' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
			nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
			resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
			fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso
		FROM "informix".cb_rep_resultado_mail
		WHERE empresa = '001'
		INTO TEMP cb_mail WITH NO LOG;
		
		CREATE INDEX idx_cb_mail ON cb_mail(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_mail; 

		FOREACH WITH HOLD
		
			SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
				nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
				resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
				fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso
			INTO Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1,
				cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vPagoReqEmail, vCosto,
				vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
				vFechaApertura,	vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso
			FROM "informix".cb_mail
			WHERE empresa = '001'
			
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;

-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;
			
				INSERT INTO "informix".cb_rep_resultado_mail_hist(
					empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
					nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
					resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
					fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso)
				VALUES(Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1,
					cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vPagoReqEmail, vCosto,
					vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
					vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
			
-----------------------------------Borramos los clientes de la tabla cb_rep_resultado_mail----------------------	
				DELETE 
				FROM "informix".cb_rep_resultado_mail 
				WHERE empresa = Vempresa 
				AND num_campana = Vnum_campana 
				AND num_credito = vcredito
				AND fecha_envio = VfechaEnvio;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			COMMIT WORK;
			
		LET Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1 = '', 0, '', '', '', DATE(1), '', '', '', '';
		LET cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto = '', '', '', 0, 0, 0, 0, 0, 0, 0;
		LET vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora = '', 0, 0, 0, 0, 0, 0, '', DATE(1), 0;
		LET vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso = DATE(1), DATE(1), 0, '', 0, 0;
			
		END FOREACH;

	DROP TABLE cb_mail;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS MAILs : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS MAILs a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS MAILs : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '3';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	IF vCount = '3' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT a.empresa, a.sucursal, a.fecha_insert, a.usuario, a.num_credito,
			a.pago_min, a.saldo_vencido, a.pago_realizado, a.pct_cump_pm, a.pct_cump_sv,
			a.folio_suc, a.reversado, a.hora_mov, a.transacc_suc, a.codigo_fun 
		FROM "informix".cb_evaluacion_objetiva a, bdicred:sd_maecred b
		WHERE a.num_credito = b.num_credito and a.empresa = '001'
		AND a.folio_suc not in( select folio_suc 
                                  from "informix".cb_evaluacion_objetiva_his 
								 where fecha_insert between dtFecha_mes_anterior and dtFecha_hoy 
                        )
		INTO TEMP cb_objetiva WITH NO LOG;
		
		CREATE INDEX idx_cb_objetiva ON cb_objetiva(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_objetiva; 

		FOREACH WITH HOLD
		
			SELECT empresa, sucursal, fecha_insert, usuario, num_credito,
				pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
				folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
			INTO Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
				d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,   
				c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun    
			FROM "informix".cb_objetiva
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_evaluacion_objetiva_his(
					empresa, sucursal, fecha_insert, usuario, num_credito,
					pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
					folio_suc, reversado, hora_mov, transacc_suc, codigo_fun) 
				VALUES(Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
					d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,
					c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
				
-----------------------------------Borramos los clientes de la tabla cb_evaluacion_objetiva----------------------	
				/*DELETE 
				FROM "informix".cb_evaluacion_objetiva 
				WHERE empresa = Vempresa 
				AND sucursal = c_sucursal
				AND fecha_insert = d_fecha_insert
				AND num_credito = vcredito
				AND folio_suc = c_folio_suc;
          
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;
        */ 
			COMMIT WORK;
			
		LET Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito = '', '', DATE(1), '', '';
		LET d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv = 0, 0, 0, 0, 0;
		LET c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun = '', '', DATE(1), '', '';
			
			
		END FOREACH;
		
		-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS OBJETIVAS : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS OBJETIVAS a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       --let cMensaje = 'TOTAL cuentas ELIMINADAS OBJETIVAS : ' || iCuentasEliminadas;
	       --CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		--LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		--LET vCount = '4';
		
		
		------------------------------------- RQM 09 486-2 EVAL OBJ PLAZO  INI
		SELECT a.empresa, a.sucursal, a.fecha_insert, a.usuario, a.num_credito,
			a.pago_min, a.saldo_vencido, a.pago_realizado, a.pct_cump_pm, a.pct_cump_sv,
			a.folio_suc, a.reversado, a.hora_mov, a.transacc_suc, a.codigo_fun 
		FROM "informix".cb_evaluacion_objetiva a, bdicred:sd_maecredcrd b
		WHERE a.num_credito = b.num_credito and a.empresa = '001'
		AND a.folio_suc not in( SELECT folio_suc 
                                  FROM "informix".cb_evaluacion_objetiva_his 
							     WHERE fecha_insert between dtFecha_mes_anterior and dtFecha_hoy 
                            )
		INTO TEMP cb_objetiva_crd WITH NO LOG;
		
		CREATE INDEX idx_cb_objetiva_crd ON cb_objetiva_crd(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_objetiva_crd; 

		
		FOREACH WITH HOLD
		
			SELECT empresa, sucursal, fecha_insert, usuario, num_credito,
				pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
				folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
			INTO Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
				d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,   
				c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun    
			FROM "informix".cb_objetiva_crd
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_evaluacion_objetiva_crd_diaria_his(
					empresa, sucursal, fecha_insert, usuario, num_credito,
					pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
					folio_suc, reversado, hora_mov, transacc_suc, codigo_fun) 
				VALUES(Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
					d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,
					c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas_2 = iCuentasInsertadas_2 + 1;
				

			COMMIT WORK;
			
		    LET Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito = '', '', DATE(1), '', '';
		    LET d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv = 0, 0, 0, 0, 0;
		    LET c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun = '', '', DATE(1), '', '';
			
			
		END FOREACH;
		------------------------------------------------- RQM 09 486-2 EVAL OBJ PLAZO FIN

		--if iCuentasInsertadas >0 then
		if iCuentasInsertadas >0 AND iCuentasInsertadas_2 > 0 then
		   TRUNCATE "informix".cb_evaluacion_objetiva; 
		end if;
		
	DROP TABLE cb_objetiva;
	DROP TABLE cb_objetiva_crd;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 or iCuentasInsertadas_2 > 0 THEN
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL Ctas. PROCESADAS EVAL OBJ. CRD : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL Ctas. INSERTADAS EVAL OBJ CRD a histórica : ' || iCuentasInsertadas_2;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;

	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET iCuentasInsertadas_2 = 0;
		LET vCount = '4';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	

	IF vCount = '4' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT '001' empresa, transaccion, ip, fecha, hora, num_credito,
			numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
			seg_nombre, codigo_retorno 
		FROM "informix".cb_bitacora_predictivo
		INTO TEMP cb_predictivo WITH NO LOG;
		
		CREATE INDEX idx_cb_predictivo ON cb_predictivo(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_predictivo; 

		FOREACH WITH HOLD 
		
			SELECT transaccion, ip, fecha, hora, num_credito,
				numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
				seg_nombre, codigo_retorno 
			INTO v_transaccion, v_ip, v_fecha, v_hora, vcredito,
				v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre,
				v_seg_nombre, v_codigo_retorno
			FROM "informix".cb_predictivo
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_bitacora_predictivo_his(
					transaccion, ip, fecha, hora, num_credito,
					numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
					seg_nombre, codigo_retorno) 
				VALUES(v_transaccion, v_ip, v_fecha, v_hora, vcredito,
					v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre,
					v_seg_nombre, v_codigo_retorno);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
				
-----------------------------------Borramos los clientes de la tabla cb_bitacora_predictivo----------------------	
				DELETE 
				FROM "informix".cb_bitacora_predictivo 
				WHERE transaccion = v_transaccion 
				AND fecha = v_fecha
				AND hora = v_hora
				AND num_credito = vcredito;
				--AND numcte = v_numcte;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			COMMIT WORK;
			
		LET v_transaccion, v_ip, v_fecha, v_hora, vcredito = '', '', DATE(1), DATE(1), '';
		LET v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre = '', '', '', '', '';
		LET v_seg_nombre, v_codigo_retorno = '', '';
				
		END FOREACH;
		
	DROP TABLE cb_predictivo;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS BITACORA PREDICTIVO : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS BITACORA PREDICTIVO a histórica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;		   
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS BITACORA PREDICTIVO : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '1';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_sms;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_sms_hist;
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_mail;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_mail_hist;
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_evaluacion_objetiva;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_evaluacion_objetiva_his;
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_bitacora_predictivo;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_bitacora_predictivo_his;

-------INICIALIZACION DEL VALOR PARA LA PROXIMA EJECUCION DE LA MIGRACION DE LAS TABLAS DE COBRANZA-------------------
/*	IF cCod_ret = '000000' THEN
		UPDATE "informix".cb_param 
		SET valor = '1'
		WHERE empresa = '001'
		AND cod_param = '86';
	END IF;*/

	CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '03') RETURNING cCod_ret; 
	
	RETURN cCod_ret, P_MENSAJE;

	END
END PROCEDURE
DOCUMENT
'MODIFICACION: CARLOS VALENZUELA',
'FECHA: 2015/08/21',
'DESCRIPCION: PROCESO QUE HACE LA MIGRACION ',
'DE LAS TABLAS DE COBRANZA - DE LA DIARIO A LA HISTORICA',
'BD: BDICOBRANZA';

CREATE PROCEDURE "informix".sp_migra_tablas_cobranza()
       RETURNING CHAR(6), CHAR(80);

-- execute procedure "informix".sp_migra_tablas_cobranza();

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cMensaje 		    CHAR(200);
define P_MENSAJE			CHAR(80);
DEFINE cCod_ret             CHAR(6);

----------------------------------------------------------------------
DEFINE vproceso				CHAR(4);
DEFINE Vempresa				CHAR(3);
DEFINE Vnum_campana			SMALLINT;
DEFINE vcliente             CHAR(20);
DEFINE vcredito             CHAR(20);
DEFINE Vproducto			CHAR(4);
DEFINE VfechaEnvio			DATE;
DEFINE vciudad              CHAR(10);
DEFINE vestado              CHAR(10);
DEFINE vt_celular           CHAR(13);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cApellMat			CHAR(26);
DEFINE vMora				SMALLINT;
DEFINE vsdo_venc_int_mora   DEC(18,2);
DEFINE vpago_min            DEC(18,2);
DEFINE vpago_min_sin_vdo    DEC(18,2); 
DEFINE vpago_venc           DEC(18,2); 
DEFINE vpago_req_sms		DEC(18,2);
DEFINE vCosto				DEC(18,2);
DEFINE vResultadoEntrega	CHAR(15);
DEFINE vPagoDia1			DEC(18,2);
DEFINE vPagoDia2			DEC(18,2);
DEFINE vPagoDia3			DEC(18,2);
DEFINE vPagoDia4			DEC(18,2);
DEFINE vPagoDia5			DEC(18,2);
DEFINE vPagoNdias			DEC(18,2);
DEFINE vEstatusResultado	CHAR(02);
DEFINE vFechaCambioEstatus  DATE;
DEFINE vResultadoMora		SMALLINT;
DEFINE vFechaApertura		DATE;
DEFINE vFechaPrimerConsumo  DATE;
DEFINE vLineaCredito		DEC(18,2);
DEFINE vTipoTransaccion		CHAR(30);
DEFINE vMontoTransaccion	DEC(18,2);
DEFINE vPorcentaje_uso      DEC(18,2);
DEFINE vCorreoElec			CHAR(100);
DEFINE vPagoReqEmail		DEC(18,2);
DEFINE vCount				CHAR(1);

DEFINE iCuentasProcesadas   INTEGER; 
DEFINE iCuentasInsertadas   INTEGER; 
DEFINE iCuentasEliminadas   INTEGER; 

DEFINE c_sucursal			CHAR(4);
DEFINE d_fecha_insert		DATE;
DEFINE c_usuario			CHAR(8);
DEFINE d_pago_min			DECIMAL(14,2);
DEFINE d_saldo_vencido		DECIMAL(14,2);
DEFINE d_pago_realizado		DECIMAL(14,2);
DEFINE d_pct_cump_pm		DECIMAL(5,2);
DEFINE d_pct_cump_sv		DECIMAL(5,2);
DEFINE c_folio_suc			CHAR(16);
DEFINE c_reversado			CHAR(1);
DEFINE dt_hora_mov			DATETIME YEAR to SECOND;
DEFINE c_transacc_suc		CHAR(4);
DEFINE c_codigo_fun			CHAR(3);

DEFINE v_transaccion		CHAR(7);
DEFINE v_ip					CHAR(20);
DEFINE v_fecha				DATE;
DEFINE v_hora				DATETIME HOUR to FRACTION(3);
DEFINE v_numcte				CHAR(20);
DEFINE v_ejecutivo			CHAR(8);
DEFINE v_apellido_pat		CHAR(26);
DEFINE v_apellido_mat		CHAR(26);
DEFINE v_pri_nombre			CHAR(26);
DEFINE v_seg_nombre			CHAR(26);
DEFINE v_codigo_retorno		CHAR(6);
--DEFINE vtoday				DATE;
DEFINE dtFecha_hoy          DATE;
DEFINE dtFecha_mes_anterior DATE;
DEFINE iCuentasInsertadas_2 INTEGER;
DEFINE v_transaccion_2		CHAR(7);
DEFINE v_fecha_2			DATE;
DEFINE v_hora_2				DATETIME HOUR to FRACTION(3);

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET vcliente         	= '';
LET vcredito        	= '';
LET Vproducto 			= '';
LET VfechaEnvio 		= DATE(1);
LET vciudad          = '';
LET vestado          = '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET vMora				= 0;
LET vCosto				= 0;
LET vResultadoEntrega	= '';
LET vPagoDia1			= 0;
LET vPagoDia2			= 0;
LET vPagoDia3			= 0;
LET vPagoDia4			= 0;
LET vPagoDia5			= 0;
LET vPagoNdias			= 0;
LET vEstatusResultado	= '';
LET vFechaCambioEstatus = DATE(1);
LET vResultadoMora		= 0;
LET vFechaApertura		= DATE(1);
LET vFechaPrimerConsumo = DATE(1);
LET vLineaCredito		= 0;
LET vTipoTransaccion	= '';
LET vMontoTransaccion	= 0;
LET vPorcentaje_uso		= 0;
LET vCorreoElec			= '';
LET vPagoReqEmail		= 0;
LET vpago_req_sms		= 0;
LET vCount 				= '1';

LET iCuentasProcesadas  = 0;
LET iCuentasInsertadas  = 0;
LET iCuentasEliminadas  = 0;

LET c_sucursal			= '';
LET d_fecha_insert		= DATE(1);
LET c_usuario			= '';
LET d_pago_min			= 0;
LET d_saldo_vencido		= 0;
LET d_pago_realizado	= 0;
LET d_pct_cump_pm		= 0;
LET d_pct_cump_sv		= 0;
LET c_folio_suc			= '';
LET c_reversado			= '';
LET dt_hora_mov			= DATE(1);
LET c_transacc_suc		= '';
LET c_codigo_fun		= '';

LET v_transaccion		= '';
LET v_ip				= '';
LET v_fecha				= DATE(1);
LET v_hora				= DATE(1);
LET v_numcte			= '';
LET v_ejecutivo			= '';
LET v_apellido_pat		= '';
LET v_apellido_mat		= '';
LET v_pri_nombre		= '';
LET v_seg_nombre		= '';
LET v_codigo_retorno	= '';
--LET vtoday				= today;

LET dtFecha_hoy          = DATE(1);
LET dtFecha_mes_anterior = DATE(1);
LET iCuentasInsertadas_2 = 0;
LET v_transaccion_2		= '';
LET v_fecha_2				= DATE(1);
LET v_hora_2				= DATE(1);
---------------------------------------

--SET DEBUG FILE TO '/aplicacion/Carlos/sp_migra_tablas_cobranza.out';
--SET DEBUG FILE TO '/informix/sp_migra_tablas_cobranza.out';
--TRACE ON;

	LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = '';
	--LET P_MENSAJE     = 'El proceso de migracion de tablas de cobranza se realizÃ³ correctamente.';
	LET P_MENSAJE       = 'Proceso migracion tablas de cobranza se realizÃ³ correctamente.';
	LET vproceso	  = '0119';
 

	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET P_MENSAJE = error_info;
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret; 
		LET cCod_ret = sql_err;
		RETURN cCod_ret, P_MENSAJE;
	END EXCEPTION;

--------------------------------------------------------------------------

	CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 

	--se obtiene la informacion
	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;
	
-----------------------------------SE OBTIENE EL NUMERO DE LA TABLA A TRABAJAR----------------------------------------
	SELECT TRIM(valor) 
	INTO vCount 
	FROM "informix".cb_param 
	WHERE empresa = '001'
	AND cod_param = '86';

	IF vCount IS NULL OR vCount = '' THEN	
		LET cCod_ret = '000010';
		LET P_MENSAJE = 'NO SE ENCUENTRA EL VALOR DEL NUMERO DE LA TABLA A TRABAJAR';
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret;
		LET cCod_ret = '000010';
		RETURN cCod_ret, P_MENSAJE;	
	ELIF vCount < '1' or vCount > '4' THEN
		LET cCod_ret = '000020';
		LET P_MENSAJE = 'EL VALOR DEL NUMERO DE LA TABLA A TRABAJAR NO ES VALIDO';
		CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, P_MENSAJE, '02')RETURNING cCod_ret;
		LET cCod_ret = '000020';
		RETURN cCod_ret, P_MENSAJE;	
	end if;

	SELECT fecha_hoy into dtFecha_hoy 
      FROM bdinteg:si_fechas
     WHERE empresa = '001';	  
	  
	LET dtFecha_mes_anterior = dtFecha_hoy - 1 units month;
	
	IF vCount = '1' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
		SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
			nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
			resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
			fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso 
		FROM "informix".cb_rep_resultado_sms
		WHERE empresa = '001'
		INTO TEMP cb_sms WITH NO LOG;
		
		CREATE INDEX idx_cb_sms ON cb_sms(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_sms; 

		FOREACH WITH HOLD
		
			SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
				nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
				resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
				fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso 
			INTO Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1,
				cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto,
				vResultadoEntrega, vPagoDia1,vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
				vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso
			FROM "informix".cb_sms
			WHERE empresa = '001'

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;
				INSERT INTO "informix".cb_rep_resultado_sms_hist (
					empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, num_celular, nombre1,
					nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_sms, costo,
					resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
					fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso)
				VALUES(Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1,
					cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto,
					vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
					vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;

-----------------------------------Borramos los clientes de la tabla cb_rep_resultado_sms----------------------	
				DELETE 
				FROM "informix".cb_rep_resultado_sms 
				WHERE empresa = Vempresa 
				AND num_campana = Vnum_campana 
				AND num_credito = vcredito 
				AND fecha_envio = VfechaEnvio;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas +1;
				
			COMMIT WORK;
			
		LET Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vt_celular, cNombre1 = '', 0, '', '', '', DATE(1), '', '', '', '';
		LET cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto = '', '', '', 0, 0, 0, 0, 0, 0, 0;
		LET vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora = '', 0, 0, 0, 0, 0, 0, '', DATE(1), 0;
		LET vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso = DATE(1), DATE(1), 0, '', 0, 0;
			
		END FOREACH;
		
	DROP TABLE cb_sms;
	
-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       LET cMensaje = 'TOTAL cuentas PROCESADAS SMSs : ' || iCuentasProcesadas;
	       LET cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS SMSs a histÃ³rica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL cuentas ELIMINADAS SMSs : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;
		
-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '2';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';

	END IF;
	
	IF vCount = '2' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
			nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
			resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
			fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso
		FROM "informix".cb_rep_resultado_mail
		WHERE empresa = '001'
		INTO TEMP cb_mail WITH NO LOG;
		
		CREATE INDEX idx_cb_mail ON cb_mail(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_mail; 

		FOREACH WITH HOLD
		
			SELECT empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
				nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
				resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
				fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso
			INTO Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1,
				cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vPagoReqEmail, vCosto,
				vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
				vFechaApertura,	vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso
			FROM "informix".cb_mail
			WHERE empresa = '001'
			
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;

-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;
			
				INSERT INTO "informix".cb_rep_resultado_mail_hist(
					empresa, num_campana, num_credito, numcte, num_producto, fecha_envio, ciudad, estado, correo_elec, nombre1,
					nombre2, apell_paterno, apell_materno, mora, sdo_venc_int_mora, pago_min, pago_min_sin_vdo, pago_ven, pago_req_email, costo,
					resultado_entrega, pago_dia1, pago_dia2, pago_dia3, pago_dia4, pago_dia5, pago_ndias, estatus_resultado, fecha_cambio_estatus, resultado_mora,
					fecha_apertura, fecha_primer_consumo, linea_credito, tipo_transaccion, monto_transaccion, porcentaje_uso)
				VALUES(Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1,
					cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vPagoReqEmail, vCosto,
					vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora,
					vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
			
-----------------------------------Borramos los clientes de la tabla cb_rep_resultado_mail----------------------	
				DELETE 
				FROM "informix".cb_rep_resultado_mail 
				WHERE empresa = Vempresa 
				AND num_campana = Vnum_campana 
				AND num_credito = vcredito
				AND fecha_envio = VfechaEnvio;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			COMMIT WORK;
			
		LET Vempresa, Vnum_campana, vcredito, vcliente, Vproducto, VfechaEnvio, vciudad, vestado, vCorreoElec, cNombre1 = '', 0, '', '', '', DATE(1), '', '', '', '';
		LET cNombre2, cApellPat, cApellMat, vMora, vsdo_venc_int_mora, vpago_min, vpago_min_sin_vdo, vpago_venc, vpago_req_sms, vCosto = '', '', '', 0, 0, 0, 0, 0, 0, 0;
		LET vResultadoEntrega, vPagoDia1, vPagoDia2, vPagoDia3, vPagoDia4, vPagoDia5, vPagoNdias, vEstatusResultado, vFechaCambioEstatus, vResultadoMora = '', 0, 0, 0, 0, 0, 0, '', DATE(1), 0;
		LET vFechaApertura, vFechaPrimerConsumo, vLineaCredito, vTipoTransaccion, vMontoTransaccion, vPorcentaje_uso = DATE(1), DATE(1), 0, '', 0, 0;
			
		END FOREACH;

	DROP TABLE cb_mail;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS MAILs : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS MAILs a historica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS MAILs : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '3';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	IF vCount = '3' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT a.empresa, a.sucursal, a.fecha_insert, a.usuario, a.num_credito,
			a.pago_min, a.saldo_vencido, a.pago_realizado, a.pct_cump_pm, a.pct_cump_sv,
			a.folio_suc, a.reversado, a.hora_mov, a.transacc_suc, a.codigo_fun 
		FROM "informix".cb_evaluacion_objetiva a, bdicred:sd_maecred b
		WHERE a.num_credito = b.num_credito and a.empresa = '001'
		AND a.folio_suc not in( select folio_suc 
                                  from "informix".cb_evaluacion_objetiva_his 
								 where fecha_insert between dtFecha_mes_anterior and dtFecha_hoy 
                        )
		INTO TEMP cb_objetiva WITH NO LOG;
		
		CREATE INDEX idx_cb_objetiva ON cb_objetiva(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_objetiva; 

		FOREACH WITH HOLD
		
			SELECT empresa, sucursal, fecha_insert, usuario, num_credito,
				pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
				folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
			INTO Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
				d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,   
				c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun    
			FROM "informix".cb_objetiva
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_evaluacion_objetiva_his(
					empresa, sucursal, fecha_insert, usuario, num_credito,
					pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
					folio_suc, reversado, hora_mov, transacc_suc, codigo_fun) 
				VALUES(Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
					d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,
					c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas = iCuentasInsertadas + 1;
				
-----------------------------------Borramos los clientes de la tabla cb_evaluacion_objetiva----------------------	
				/*DELETE 
				FROM "informix".cb_evaluacion_objetiva 
				WHERE empresa = Vempresa 
				AND sucursal = c_sucursal
				AND fecha_insert = d_fecha_insert
				AND num_credito = vcredito
				AND folio_suc = c_folio_suc;
          
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;
        */ 
			COMMIT WORK;
			
		LET Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito = '', '', DATE(1), '', '';
		LET d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv = 0, 0, 0, 0, 0;
		LET c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun = '', '', DATE(1), '', '';
			
			
		END FOREACH;
		
		-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS OBJETIVAS : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS OBJETIVAS a historica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
		   LET cMensaje = '';
	       --let cMensaje = 'TOTAL cuentas ELIMINADAS OBJETIVAS : ' || iCuentasEliminadas;
	       --CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		--LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		--LET vCount = '4';
		
		
		------------------------------------- RQM 09 486-2 EVAL OBJ PLAZO  INI
		SELECT a.empresa, a.sucursal, a.fecha_insert, a.usuario, a.num_credito,
			a.pago_min, a.saldo_vencido, a.pago_realizado, a.pct_cump_pm, a.pct_cump_sv,
			a.folio_suc, a.reversado, a.hora_mov, a.transacc_suc, a.codigo_fun 
		FROM "informix".cb_evaluacion_objetiva a, bdicred:sd_maecredcrd b
		WHERE a.num_credito = b.num_credito and a.empresa = '001'
		AND a.folio_suc not in( SELECT folio_suc 
                                  FROM "informix".cb_evaluacion_objetiva_his 
							     WHERE fecha_insert between dtFecha_mes_anterior and dtFecha_hoy 
                            )
		INTO TEMP cb_objetiva_crd WITH NO LOG;
		
		CREATE INDEX idx_cb_objetiva_crd ON cb_objetiva_crd(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_objetiva_crd; 

		
		FOREACH WITH HOLD
		
			SELECT empresa, sucursal, fecha_insert, usuario, num_credito,
				pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
				folio_suc, reversado, hora_mov, transacc_suc, codigo_fun 
			INTO Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
				d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,   
				c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun    
			FROM "informix".cb_objetiva_crd
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
			BEGIN WORK;

				INSERT INTO "informix".cb_evaluacion_objetiva_crd_diaria_his(
					empresa, sucursal, fecha_insert, usuario, num_credito,
					pago_min, saldo_vencido, pago_realizado, pct_cump_pm, pct_cump_sv,
					folio_suc, reversado, hora_mov, transacc_suc, codigo_fun) 
				VALUES(Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito,
					d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv,
					c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				LET iCuentasInsertadas_2 = iCuentasInsertadas_2 + 1;
				

			COMMIT WORK;
			
		    LET Vempresa, c_sucursal, d_fecha_insert, c_usuario, vcredito = '', '', DATE(1), '', '';
		    LET d_pago_min, d_saldo_vencido, d_pago_realizado, d_pct_cump_pm, d_pct_cump_sv = 0, 0, 0, 0, 0;
		    LET c_folio_suc, c_reversado, dt_hora_mov, c_transacc_suc, c_codigo_fun = '', '', DATE(1), '', '';
			
			
		END FOREACH;
		------------------------------------------------- RQM 09 486-2 EVAL OBJ PLAZO FIN

		--if iCuentasInsertadas >0 then
		if iCuentasInsertadas >0 AND iCuentasInsertadas_2 > 0 then
		   TRUNCATE "informix".cb_evaluacion_objetiva; 
		end if;
		
	DROP TABLE cb_objetiva;
	DROP TABLE cb_objetiva_crd;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 or iCuentasInsertadas_2 > 0 THEN
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL Ctas. PROCESADAS EVAL OBJ. CRD : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL Ctas. INSERTADAS EVAL OBJ CRD a historica : ' || iCuentasInsertadas_2;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;

	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET iCuentasInsertadas_2 = 0;
		LET vCount = '4';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	

	IF vCount = '4' THEN
-----------------------------------Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------------
		SELECT '001' empresa, transaccion, ip, fecha, hora, num_credito,
			numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
			seg_nombre, codigo_retorno 
		FROM "informix".cb_bitacora_predictivo
		WHERE nvl(transaccion,'') <> '' and fecha <= today
		group by 1,2,3,4,5,6,7,8,9,10,11,12,13
		INTO TEMP cb_predictivo_temp WITH NO LOG;
		
		CREATE INDEX idx_cb_predictivo ON cb_predictivo_temp(empresa);
		UPDATE STATISTICS MEDIUM FOR TABLE cb_predictivo_temp; 

		FOREACH WITH HOLD 
		
			SELECT transaccion, ip, fecha, hora, num_credito,
				numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
				seg_nombre, codigo_retorno 
			INTO v_transaccion, v_ip, v_fecha, v_hora, vcredito,
				v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre,
				v_seg_nombre, v_codigo_retorno
			--FROM "informix".cb_predictivo
			FROM cb_predictivo_temp
			WHERE empresa = '001'
		
-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS PROCESADAS--------------------------------------
			LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
-----------------------------------SE INCERTAN DATOS GENERADOS--------------------------------------------------------
            SELECT nvl(transaccion,''), fecha, hora INTO v_transaccion_2, v_fecha_2, v_hora_2
              FROM "informix".cb_bitacora_predictivo_his
             WHERE transaccion = v_transaccion AND fecha = v_fecha AND hora = v_hora;
             
 		    IF (v_transaccion_2 = '' or v_transaccion_2 is null) THEN
			   BEGIN WORK;

					INSERT INTO "informix".cb_bitacora_predictivo_his(
						transaccion, ip, fecha, hora, num_credito,
						numcte, ejecutivo, apellido_pat, apellido_mat, pri_nombre,
						seg_nombre, codigo_retorno) 
					VALUES(v_transaccion, v_ip, v_fecha, v_hora, vcredito,
						v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre,
						v_seg_nombre, v_codigo_retorno);

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS INSERTADAS--------------------------------------
				    LET iCuentasInsertadas = iCuentasInsertadas + 1;
-----------------------------------Borramos los clientes de la tabla cb_bitacora_predictivo----------------------	
				DELETE 
				FROM "informix".cb_bitacora_predictivo 
				WHERE transaccion = v_transaccion 
				AND fecha = v_fecha
				AND hora = v_hora;
				--AND num_credito = vcredito;
				--AND numcte = v_numcte;

-----------------------------------VARIABLE PARA EL CONTEO DE CUENTAS ELIMINADAS--------------------------------------
				LET iCuentasEliminadas = iCuentasEliminadas + 1;

			   COMMIT WORK;
            END IF;							
			
		LET v_transaccion, v_ip, v_fecha, v_hora, vcredito = '', '', DATE(1), DATE(1), '';
		LET v_numcte, v_ejecutivo, v_apellido_pat, v_apellido_mat, v_pri_nombre = '', '', '', '', '';
		LET v_seg_nombre, v_codigo_retorno = '', '';
				
		END FOREACH;
		
	DROP TABLE cb_predictivo_temp;

-----------------------------------Genera cifras de control-----------------------------------------------------------
	    IF iCuentasProcesadas > 0 THEN
	       let cMensaje = 'TOTAL cuentas PROCESADAS BITACORA PREDICTIVO : ' || iCuentasProcesadas;
	       let cMensaje = TRIM(cMensaje) ||'   TOTAL cuentas INSERTADAS BITACORA PREDICTIVO a Historica : ' || iCuentasInsertadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;		   
		   LET cMensaje = '';
	       let cMensaje = 'TOTAL cuentas ELIMINADAS BITACORA PREDICTIVO : ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, TRIM(cMensaje), '02') RETURNING cCod_ret;
	    END IF;

-----------------------------------INICIALIZACION DE VARIABLES DE CONTEO----------------------------------------------
		LET cMensaje = '';
		LET iCuentasProcesadas = 0;
		LET iCuentasInsertadas = 0;
		LET iCuentasEliminadas = 0;
		LET vCount = '1';
		
		UPDATE "informix".cb_param 
        SET valor = vCount
		WHERE empresa = '001'
		AND cod_param = '86';
		
	END IF;
	
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_sms;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_sms_hist;
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_mail;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_rep_resultado_mail_hist;
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_evaluacion_objetiva;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_evaluacion_objetiva_his;
	
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_bitacora_predictivo;
	UPDATE STATISTICS LOW FOR TABLE "informix".cb_bitacora_predictivo_his;

-------INICIALIZACION DEL VALOR PARA LA PROXIMA EJECUCION DE LA MIGRACION DE LAS TABLAS DE COBRANZA-------------------
/*	IF cCod_ret = '000000' THEN
		UPDATE "informix".cb_param 
		SET valor = '1'
		WHERE empresa = '001'
		AND cod_param = '86';
	END IF;*/

	CALL "informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '03') RETURNING cCod_ret; 
	
	RETURN cCod_ret, P_MENSAJE;

	END
END PROCEDURE
DOCUMENT
'MODIFICACION: CARLOS VALENZUELA',
'FECHA: 2015/08/21',
'DESCRIPCION: PROCESO QUE HACE LA MIGRACION ',
'DE LAS TABLAS DE COBRANZA - DE LA DIARIO A LA HISTORICA',
'BD: BDICOBRANZA';

CREATE PROCEDURE "informix".sp_actualiza_catdirectoriocte(pTipo_Cobranza char(1), pFecha date)
RETURNING
CHAR(06), 
CHAR(150);


-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-- Modificado por: MACF 23/01/2013.
-- ModificaciÃÂ³n: obteber datos de saldos.
-- Modificado por: JAHJ 24/06/2025.
-- Modificacion: Mejora en punto de recuperacion.

DEFINE cCodRet      char(6);
DEFINE viSqlErr     integer;
DEFINE error_info   char(80);
DEFINE isam_err     integer;
DEFINE cMensaje     char(150);
DEFINE cNumCte      char(20);
DEFINE cEmpresa     char(3);
DEFINE cSitEsp      char(1);
DEFINE iCausa       smallint;
DEFINE cNumCredito  char(20);
DEFINE cPagoMinimo  char(20);
DEFINE cCiudad      char(3);
DEFINE cEstado      char(2);
DEFINE dSaldoTotal  decimal (18,2);
DEFINE cApell_Paterno char(26);
DEFINE cApell_Materno char(26);
DEFINE cNombre1     char(26);
DEFINE cNombre2     char(26);
DEFINE cProceso     char(30);
DEFINE cExito       char(6);
DEFINE vvcCod_ret   char(6);
define c_codret0    char(5);
define c_codretOK    char(5);
DEFINE dFechaProc, vfechaultpago, vproxfchpago	DATE;
DEFINE vnum_rows,vnumpagos    integer;
DEFINE vtarjeta     CHAR(20);
DEFINE vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto, vPagoMinimo decimal (18,2);
DEFINE vmontofinanciado, vsdomoratorio, vmontopagos, vinteresiva, vmoras, vpagounamora            decimal (18,2); 
DEFINE vmontootorgado, vsdo_intereses, vmensualidad_act                              decimal (18,2);
define vfecha_ant date;
DEFINE vday			INTEGER;
DEFINE vnum_prod	CHAR(4);
DEFINE vbandera		CHAR(1);
DEFINE vetapa_proceso CHAR(1);

LET viSqlErr = 0;
LET isam_err = 0;
LET cMensaje = 'PROCESO EXITOSO';
LET cEmpresa = '001';
LET cNumCte = '';
LET cSitEsp = '';
LET iCausa = 0;
LET cNumCredito = '';
LET cPagoMinimo = '0';
LET dSaldoTotal = 0.00;
LET cApell_Paterno = null;
LET cApell_Materno = null;
LET cNombre1 = null;
LET cNombre2 = null;
LET cProceso = '0050';
LET cExito   = '000000';
LET vvcCod_ret = '';
LET cCodRet = '000000';
let c_codret0 = "000000"; --A.L.L. Se declara con 000000 ya que estaba vacia y marcaba error.
let c_codretOK = '00000';
let cCiudad = null;
let cEstado = null;
LET dFechaProc = pFecha;
LET vnum_rows = 0;
LET vtarjeta = ''; 
LET vsdo_capital = 0; LET vmonto_vencido = 0; LET vmtovenctrasp = 0; LET vcaptrasnovenci = 0; LET vsdocapinsoluto = 0;
LET vmontofinanciado = 0; LET vsdomoratorio = null; LET vinteresiva = null; LET vmoras = 0; LET vpagounamora = 0;
LET vmontootorgado = 0; LET vsdo_intereses = 0; LET vmensualidad_act = 0; LET vPagoMinimo = 0;
LET vfecha_ant = DATE(1);
LET vfechaultpago = DATE(1);
LET vnumpagos = 0;
LET vmontopagos = 0;
LET vday = 0;
LET vnum_prod = '';
LET vbandera = '';
LET vetapa_proceso = '0';

BEGIN
    ON EXCEPTION SET viSqlErr, isam_err, error_info
        LET cCodRet = viSqlErr;
        LET cMensaje = error_info;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '02')
            RETURNING vvcCod_ret;

        RETURN cCodRet,cMensaje;
    END EXCEPTION;

--    SET DEBUG FILE TO "sp_actualiza_catdirectoriocte.out";
--    TRACE ON;

	SELECT valor into vetapa_proceso 
		FROM bdicobranza:cb_param
		WHERE cod_param = '100';

	IF vetapa_proceso = 0 THEN
		

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '01')
				RETURNING vvcCod_ret;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	--select fecha_hoy into vfecha_ant from bdicred:sd_fechas where empresa = '001';

		IF pTipo_Cobranza = 'A' THEN
			SELECT MAX(fecha_insert) INTO dFechaProc
				FROM bdicobranza:cb_cat_directorio_cte
				WHERE empresa = cEmpresa
				AND tipo_cobranza = pTipo_Cobranza
				AND fecha_insert <= pFecha;

			LET vday = DAY(dFechaProc);

			FOREACH WITH HOLD
				SELECT valor_alfabetico INTO vnum_prod
				FROM "informix".cb_param_campania 
				WHERE empresa = cEmpresa AND tipo_campania = 61
				AND grupo_parametro = pTipo_Cobranza
				AND valor_numerico = vday

				IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

				SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = cEmpresa AND valor = vnum_prod;

				IF vbandera IS NULL THEN LET vbandera = ''; END IF;

				IF vbandera = 'N' OR vbandera = '' THEN
					LET vbandera = '';
					CONTINUE FOREACH;
				END IF;

				SELECT MAX(fecha_insert) INTO dFechaProc
					FROM bdicobranza:cb_cat_directorio_cte
					WHERE empresa = cEmpresa
					AND tipo_cobranza = pTipo_Cobranza
					AND fecha_insert <= pFecha
					AND num_producto = vnum_prod;

				SELECT '001' empresa, cat.numcte, cat.num_credito, cte.apell_paterno,cte.apell_materno, cte.nombre1, cte.nombre2
				FROM bdicobranza:cb_cat_directorio_cte cat
				INNER JOIN bdinteg:si_cliente cte ON cte.numcte = cat.numcte
				WHERE cat.empresa = '001'
				  AND cat.tipo_cobranza = pTipo_Cobranza
				  AND cat.fecha_insert = dFechaProc
				  AND cat.num_producto = vnum_prod
				  INTO TEMP cuentas_aprocesar WITH NO LOG;

				CREATE INDEX idx_creditotmp ON cuentas_aprocesar(num_credito) ONLINE;
				UPDATE STATISTICS MEDIUM FOR TABLE cuentas_aprocesar;

				FOREACH with hold
					SELECT numcte,  num_credito,  apell_paterno,  apell_materno,  nombre1,  nombre2
					INTO cNumCte, cNumCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2
					FROM cuentas_aprocesar
					WHERE num_credito > ''

					SELECT {+ INDEX (bdinteg:si_direcciones inx_puntocardinales)} FIRST 1 d.ciudad, d.estado
					INTO cCiudad, cEstado
					FROM bdinteg:si_direcciones_actual d
					WHERE d.numcte = cNumCte
					AND d.tipo_dir = '1';

					IF cCiudad IS NULL THEN LET cCiudad = ''; END IF;
					IF cEstado IS NULL THEN LET cEstado = ''; END IF;

					SELECT first 1 num_pagos_h, monto_pagos_h INTO vnumpagos, vmontopagos
					FROM bdicred:sd_indicador_cred 
					WHERE empresa = '001' and num_credito = cNumCredito;

					IF vnumpagos IS NULL THEN LET vnumpagos = 0; END IF;
					IF vmontopagos IS NULL THEN LET vmontopagos = 0; END IF;

					LET vPagoMinimo = vmonto_vencido + vmtovenctrasp + vsdomoratorio + vinteresiva + vmensualidad_act;

					SELECT FIRST 1 num_tarjeta, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, sdo_cap_insoluto, monto_financiado, moratorio,
						 interes_iva, mto_fin_ven_trasp, fecha_ult_pago, pago_una_mora, monto_otorgado, prox_fecha_pago, sdo_intereses, mensualidad_actual
					into vtarjeta, vsdo_capital, vmonto_vencido, vmtovenctrasp, vcaptrasnovenci, vsdocapinsoluto, vmontofinanciado, vsdomoratorio, 
						 vinteresiva, vmoras, vfechaultpago, vpagounamora, vmontootorgado, vproxfchpago, vsdo_intereses, vmensualidad_act 
					from bdicred:sd_sdos_cartera_linea
					where num_credito = cNumCredito;

					BEGIN WORK;
						UPDATE bdicobranza:cb_cat_directorio_cte
						  SET /*situacion = cSitEsp, causa = iCausa,  pago_minimo = cPagoMinimo,*/ estado = cEstado,
									ciudad = cCiudad, /*saldo_total =  dSaldoTotal,*/ 
							  monto_vencido = vmonto_vencido, moratorio = vsdomoratorio, fecha_ult_pago = vfechaultpago, 
							  pago_una_mora = vpagounamora, num_pagos = vnumpagos , monto_pagos = vmontopagos,
							  interes_iva = vinteresiva, mto_venc_trasp = vmtovenctrasp, pagomin_total = vPagoMinimo    
						  WHERE empresa = cEmpresa
						  AND tipo_cobranza = pTipo_Cobranza
						  AND fecha_insert = dFechaProc
						  AND numcte = cNumCte
						  AND num_producto = vnum_prod;
					COMMIT WORK;
				END FOREACH;

				DROP TABLE cuentas_aprocesar;
			END FOREACH;

			CALL bdicobranza:"informix".sp_cat_obtenerpuntualidad() returning c_codret0;
		ELIF pTipo_Cobranza = 'P' THEN
			SELECT MAX(fecha_insert) INTO dFechaProc
				FROM bdicobranza:cb_cat_directorio_cte
				WHERE empresa = cEmpresa
				AND tipo_cobranza = pTipo_Cobranza
				AND fecha_insert <= pFecha;

			SELECT cat.numcte, cat.num_credito, cte.apell_paterno,cte.apell_materno, cte.nombre1, cte.nombre2
			FROM bdicobranza:cb_cat_directorio_cte cat
			INNER JOIN bdinteg:si_cliente cte ON cte.numcte = cat.numcte
			WHERE cat.empresa = '001'
			  AND cat.tipo_cobranza = pTipo_Cobranza
			  AND cat.fecha_insert = dFechaProc
			  AND cat.nombre1 is null
			  INTO TEMP cuentas_aprocesar WITH NO LOG;

			CREATE INDEX idx_creditotmp ON cuentas_aprocesar(num_credito) ONLINE;
			UPDATE STATISTICS MEDIUM FOR TABLE cuentas_aprocesar;

			FOREACH with hold
				SELECT numcte,  num_credito,  apell_paterno,  apell_materno,  nombre1,  nombre2
					INTO cNumCte, cNumCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2
					FROM cuentas_aprocesar
					WHERE num_credito > ''

				SELECT {+ INDEX (bdinteg:si_direcciones inx_puntocardinales)} FIRST 1 d.ciudad, d.estado
					INTO cCiudad, cEstado
					FROM bdinteg:si_direcciones_actual d
					WHERE d.numcte = cNumCte
					AND d.tipo_dir = '1';

				IF cCiudad IS NULL THEN LET cCiudad = ''; END IF;
				IF cEstado IS NULL THEN LET cEstado = ''; END IF;
				
				SELECT first 1 num_pagos_h, monto_pagos_h INTO vnumpagos, vmontopagos
				FROM bdicred:sd_indicador_cred 
				WHERE empresa = '001' and num_credito = cNumCredito;
				IF vnumpagos IS NULL THEN LET vnumpagos = 0; END IF;
				IF vmontopagos IS NULL THEN LET vmontopagos = 0; END IF;
				LET vPagoMinimo = vmonto_vencido + vmtovenctrasp + vsdomoratorio + vinteresiva + vmensualidad_act;

				BEGIN WORK;
					UPDATE bdicobranza:cb_cat_directorio_cte
					  SET /*situacion = cSitEsp, causa = iCausa,  pago_minimo = cPagoMinimo,*/ estado = cEstado,
								ciudad = cCiudad, /*saldo_total =  dSaldoTotal,*/ apell_paterno = cApell_Paterno, apell_materno = cApell_Materno,
								nombre1 = cNombre1, nombre2 = cNombre2,
						  num_pagos = vnumpagos , monto_pagos = vmontopagos
					  WHERE empresa = cEmpresa
					  AND tipo_cobranza = pTipo_Cobranza
					  AND fecha_insert = dFechaProc
					  AND numcte = cNumCte;
				COMMIT WORK;		     
			END FOREACH;

			DROP TABLE cuentas_aprocesar;
		END IF;

		LET vetapa_proceso = '1';
		
		BEGIN WORK; -- El proceso termina ok, por lo que se marca el punto de recuperacion en 1  ahj
			UPDATE bdicobranza:cb_param
			SET  valor = vetapa_proceso
			WHERE empresa = cEmpresa AND cod_param = '100' AND valor = '0';
		COMMIT WORK;

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000001', 'Etapa 0 correcta','02' )  RETURNING vvcCod_ret;

	END IF;	


	-- Evalua la salida del proceso 0 y pasa al nivel 1  no carga nin sp
	IF vetapa_proceso = 1 THEN

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000001', ' Inicia sp_cat_cargeneracion 01','02' )  RETURNING vvcCod_ret;

		BEGIN WORK; -- El proceso termina ok, por lo que se marca el punto de recuperacion en 0  ahj
			UPDATE bdicobranza:cb_param
					set descripcion = 'Proceso CAT directorio cte' ||' '|| to_char(dFechaProc,'%d/%m/%Y')
			WHERE empresa = cEmpresa AND cod_param = '100';
		COMMIT WORK;

		CALL bdicobranza:sp_cat_cargeneracion(cEmpresa,dFechaProc,pTipo_Cobranza) RETURNING vvcCod_ret;			-- se ejecuta el sp
			
		IF vvcCod_ret = '000000' THEN
		
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000002', ' Termina sp_cat_cargeneracion 01' ,'02' ) RETURNING vvcCod_ret;
			LET vetapa_proceso = '2';

			BEGIN WORK; -- El proceso termina ok, se termina la etapa 1 ahj
				UPDATE bdicobranza:cb_param
					SET  valor = vetapa_proceso
				WHERE empresa = cEmpresa AND cod_param = '100' and valor = '1';
			COMMIT WORK;
			
		ELSE 
			LET cCodRet = vvcCod_ret;
			LET cMensaje = 'Error en Etapa 1';
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,vvcCod_ret,cMensaje,'02' ) RETURNING vvcCod_ret;
			RETURN cCodRet,cMensaje;
		END IF;

	END IF;


	IF vetapa_proceso = 2 THEN

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000002', ' Inicia sp_cat_cartelefonos 02','02' )  RETURNING vvcCod_ret;

		CALL bdicobranza:sp_cat_cartelefonos(cEmpresa,dFechaProc, pTipo_Cobranza,'AC') RETURNING vvcCod_ret;  -- se ejecuta el sp
			
		IF vvcCod_ret = '000000' THEN
		
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000002', ' Termina sp_cat_cartelefonos 02' ,'02' ) RETURNING vvcCod_ret;
			LET vetapa_proceso = '3';

			BEGIN WORK; -- El proceso termina ok, se termina la etapa 2 ahj
				UPDATE bdicobranza:cb_param
					SET  valor = vetapa_proceso
				WHERE empresa = cEmpresa AND cod_param = '100' and valor = '2';
			COMMIT WORK;
			
		ELSE 
			LET cCodRet = vvcCod_ret;
			LET cMensaje = 'Error en Etapa 2';
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,vvcCod_ret,cMensaje,'02' ) RETURNING vvcCod_ret;
			RETURN cCodRet,cMensaje;
		END IF;

	END IF;

	IF vetapa_proceso = 3 THEN

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000003', ' Inicia sp_cat_carproductos 03','02' )  RETURNING vvcCod_ret;

		CALL bdicobranza:sp_cat_carproductos(cEmpresa,dFechaProc, pTipo_Cobranza) RETURNING vvcCod_ret;  -- se ejecuta el sp
			
		IF vvcCod_ret = '000000' THEN
		
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,'000003', ' Termina sp_cat_cartelefonos 03' ,'02' ) RETURNING vvcCod_ret;
			LET vetapa_proceso = '0';

			BEGIN WORK; -- El proceso termina ok, se termina la etapa 3 ahj
				UPDATE bdicobranza:cb_param
					SET  valor = vetapa_proceso
				WHERE empresa = cEmpresa AND cod_param = '100' and valor = '3';
			COMMIT WORK;
			
		ELSE 
			LET cCodRet = vvcCod_ret;
			LET cMensaje = 'Error en Etapa 3';
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso,vvcCod_ret,cMensaje,'02' ) RETURNING vvcCod_ret;
			RETURN cCodRet,cMensaje;
		END IF;

	END IF;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '03') RETURNING vvcCod_ret;

    RETURN cCodRet,cMensaje;

END;
END PROCEDURE
DOCUMENT 
'MODIFICACION: Validar si existe informacion que tenga que actualizarse. Que se actualice de la fecha que se esta pasando como param. hacia atras.',
'AUTOR : Marco A. Campos ',
'FECHA : 2012-02-13',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_cartelefonos(pEmpresa         CHAR(3),                                                   
                                                pFechaGenCartera DATE,
                                                pTipoCobranza    CHAR(1), 
                                                pStatusTel       CHAR(2))
RETURNING CHAR(6) AS COD_RET;

-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica proceso para que tome en cuenta tambien el tipo de cobranza R
-----------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham López López
-- Fecha: Marzo 2013
-- Modificacion: Se modifica proceso para que no meta caracteres no numericos en telefono y extension.
-- execute procedure sp_cat_cartelefonos('001','02-20-2015','A','01');

-- DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje 		    CHAR(80);
DEFINE cRuta                CHAR(100);
DEFINE cNomArchivo          CHAR(100);
DEFINE cNomArchivoAux       CHAR(100);
DEFINE cNomArchivoEjecSql   CHAR(100);
DEFINE iTipoTelefono        SMALLINT;
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(100);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cEmpresa             CHAR(3);
DEFINE cDelimitador         CHAR(1);
DEFINE cTipoCampania        CHAR(1);
DEFINE cCodRetIB            CHAR(6);
DEFINE cFechaCorte          DATE; --CHAR(8);
DEFINE vproceso				CHAR(30);
DEFINE iParamNombreArch     INTEGER;
DEFINE vday					INTEGER;
DEFINE vnum_prod			CHAR(4);
DEFINE vbandera				CHAR(1);
DEFINE vContTrab			INTEGER;
DEFINE vmax_fechacierre 	DATE;

-- INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cCodRet                 = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET cRuta                   = "";
LET cNomArchivo             = "";
LET cNomArchivoAux          = "";
LET cNomArchivoEjecSql      = "";
LET iTipoTelefono           = 0;
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cEmpresa                = "000";
LET cDelimitador            = "";
LET cTipoCampania           = "";
LET cCodRetIB               = "000000";
LET vproceso				= '0019';
LET iParamNombreArch        = 0;
LET vday 					= 0;
LET vnum_prod 				= '';
LET vbandera 				= '';
LET vContTrab 				= 0;
LET vmax_fechacierre 		= DATE(1);

-- SET DEBUG FILE TO "/aplicacion/resplogifx/archivoscartera/sp_ctbcpl_gen_arctelefonos.out";
-- TRACE ON;

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, error_info
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensaje = error_info;
            EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    -- DIRECTIVA PARA TENER LECTURA DE TABLAS AUNQUE ESTEN BLOQEUADAS
    SET ISOLATION TO DIRTY READ;
    -- DIRECTIVA PARA QUE EXISTA UNA ESPERA DE TRES SEGUNDOS AL ACCESO 
    SET LOCK MODE TO WAIT 3;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,"","","01")
             INTO cCodRetIB;
    
    -- VALIDA LOS PARAMETROS DE ENTRADA   
    IF NVL(pEmpresa,"") = "" OR NVL(pTipoCobranza,"") = "" OR NVL(pFechaGenCartera,"")= "" OR NVL(pStatusTel,"") = "" THEN
        LET cCodRet = "104001";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                INTO cCodRetIB;
        RETURN cCodRet;
    END IF
    
    SELECT empresa
        INTO cEmpresa
        FROM bdinteg:si_empresas
        WHERE empresa = pEmpresa;

    IF NVL(cEmpresa,'') = '' THEN
        LET cCodRet = "104002";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 
        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    SELECT tipo_cobranza
        INTO cTipoCampania
        FROM bdicobranza:cb_cat_campania
        WHERE empresa     = pEmpresa
        AND tipo_cobranza = pTipoCobranza   
        AND modulo_cob    = 3;

    IF NVL(cTipoCampania,'') = '' THEN
        LET cCodRet = "104003";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
             INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
    
    -- OBTIENE EL CARACTER SEPARADOR
    SELECT TRIM(valor_alfabetico)
        INTO cDelimitador
        FROM bdicobranza:cb_param_campania 
        WHERE empresa       = pEmpresa 
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = 2;
    
    -- VALIDA QUE EXISTA EL CARACTER
    IF NVL(cDelimitador,"") = "" THEN
        LET cCodRet = "104004";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- OBTIENE LA RUTA DESTINO DEL ARCHIVO
    SELECT TRIM(valor_alfabetico)
        INTO cRuta
        FROM bdicobranza:cb_param_campania 
        WHERE empresa = pEmpresa
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = 3;
    
    -- VALIDA QUE EXISTA LA CARPETA
    IF NVL(cRuta,"") = "" THEN
        LET cCodRet = "104005";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF

    -- OBTIENE EL NOMBRE DEL ARCHIVO
    IF pTipoCobranza = 'A' THEN
		SELECT MAX(fecha_insert) INTO vmax_fechacierre
			FROM bdicobranza:"informix".cb_cat_directorio_cte
			WHERE empresa = pEmpresa AND  tipo_cobranza = pTipoCobranza;

		LET vday = DAY(vmax_fechacierre);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = pEmpresa AND tipo_campania = 61
			AND grupo_parametro = pTipoCobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pEmpresa AND valor = vnum_prod;

			IF vbandera IS NULL THEN LET vbandera = ''; END IF;
			
			IF vbandera = 'S' THEN
				LET vContTrab = vContTrab + 1;
			END IF;
		END FOREACH;

		IF vContTrab = 0 THEN
			EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,"","","03")
					INTO cCodRetIB;
			RETURN cCodRet;
		END IF;

		IF vnum_prod = "6001" THEN
			LET iParamNombreArch = 44;
		ELIF vnum_prod = "8100" OR vnum_prod = "8500" THEN
			LET iParamNombreArch = 43;
		END IF;
    ELIF pTipoCobranza = 'P' THEN
		LET iParamNombreArch = 44;
	ELSE
        LET iParamNombreArch = 45;   -- pTipoCobranza = 'R' OR pTipoCobranza = 'E'
    END IF;

    SELECT TRIM(valor_alfabetico)  INTO cNomArchivo
        FROM bdicobranza:cb_param_campania 
        WHERE empresa       = pEmpresa 
        AND tipo_campania   = 1 
        AND grupo_parametro = "ARCHIVOS" 
        AND num_parametro   = iParamNombreArch;
    
    -- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
    IF NVL(cNomArchivo,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen     = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF

    LET cFechaGenArchivo = to_char(pFechaGenCartera,'20%m%Y');  ---A.L.L Se modifica para que ponga siempre el dia 20
    LET cFechaCorte = pFechaGenCartera;

    LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '.txt';
    LET cNomArchivoEjecSql = 'Ejec_GenArchTel_' || pTipoCobranza || '.sql';
    

    LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";

    IF (pTipoCobranza = 'A' or pTipoCobranza = 'P') THEN   --Genera query segun el tipo de cobranza
  
			LET cSQL2 = " SELECT tel.numcte, tel.tipo_tel, TRIM(rpad(nvl(case when bdinteg:val_num(tel.telefono) then replace(replace(replace(tel.telefono,'.',''),'-',''),',','') else '0' end,' '),13,' ')) as telefono, rpad(nvl(case when bdinteg:val_num(tel.extension) then replace(replace(replace(tel.extension,'.',''),'-',''),',','') else '0' end,' '),5,' ')as extension, (to_char(dir.fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte "
                || " FROM bdinteg:si_telefonos_actual tel, bdicobranza:cb_cat_directorio_cte dir, bdicred:sd_maecredanexo d  "
                || " WHERE dir.empresa  = tel.empresa  "
                || " AND dir.numcte  = tel.numcte "
                || " AND d.empresa = dir.empresa "
                || " AND d.num_credito = dir.num_credito "
                || " AND  tel.empresa = '" || pEmpresa || "'  "
				|| " AND tel.tipo_tel in (1,2,3) "
                || " AND dir.tipo_cobranza = '" || pTipoCobranza || "' "
                || " AND dir.fecha_insert = '" || cFechaCorte || "' "                
                || " and dir.tipo_logica > '0'"
                || " AND dir.status_cliente <> 'NT' "
				|| " AND dir.canal = '' "
				|| " and tel.cofetel= 'V' ";
--		IF pTipoCobranza = 'A' THEN
--			LET cSQL2 = " " || TRIM(cSQL2) || " and dir.num_producto = '" ||vnum_prod|| "';";
--		END IF;
    ELSE
        
		LET cSQL2 = " SELECT tel.numcte, tel.tipo_tel, TRIM(rpad(nvl(case when bdinteg:val_num(tel.telefono) then replace(replace(replace(tel.telefono,'.',''),'-',''),',','') else '0' end,' '),13,' ')) as telefono, rpad(nvl(case when bdinteg:val_num(tel.extension) then replace(replace(replace(tel.extension,'.',''),'-',''),',','') else '0' end,' '),5,' ')as extension, (to_char(dir.fecha_insert,'%Y-%m-')|| d.dia_corte ) fechacorte "
                || " FROM bdinteg:si_telefonos_actual tel, bdicobranza:cb_cat_directorio_cte dir, bdicred:sd_maecredanexocrd d  "
                || " WHERE dir.empresa  = tel.empresa  "
                || " AND dir.numcte  = tel.numcte "
                || " AND d.empresa = dir.empresa "
                || " AND d.num_credito = dir.num_credito "
				|| " AND tel.tipo_tel in (1,2,3) "
                || " AND  tel.empresa = '" || pEmpresa || "'  "
                || " AND dir.tipo_cobranza = '" || pTipoCobranza || "' "
                || " AND dir.fecha_insert = '" || cFechaCorte || "' "                
                || " and dir.tipo_logica > '0'"                
                || " AND dir.status_cliente <> 'NT' " 
				|| " AND dir.canal = '' " 
				|| " and tel.cofetel= 'V' ";
    END IF;

    LET cSQL3 = ' " > '|| TRIM(cRuta) || cNomArchivoEjecSql;
    
    LET cSQL1 = TRIM(cSQL1);
    LET cSQL3 = TRIM(cSQL3);

    LET cSQL = cSQL1 || cSQL2 || cSQL3;

    -- Verifica que no este vacia la consulta.
    IF ( cSQL <> '' ) THEN 
        SYSTEM cSQL;
        -- Permiso para la creacion de archivo.
        LET cSQL = '' ;
        LET cSQL = 'chmod 666 ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        LET cSQL = '' ;
        LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || cNomArchivoEjecSql ;
        SYSTEM cSQL;

        LET cSql = cSql;
        LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
        SYSTEM cSql;
	
	  -- Quitar compresión de archivo debido a que el cifrado lo comprime. MACF 2014/08/12
		--A.L.L.SE COMPRIME EL ARCHIVO	
		--LET cSql = "gzip " || trim(cRuta) || trim(cNomArchivo); 
		--system cSql;

        -- Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRuta) || cNomArchivoEjecSql || '  ' || TRIM(cRuta) || TRIM(cNomArchivoAux);
        SYSTEM cSQL;

        -- Operacion exitosa "Archivo Generado".
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,"","","03")
                INTO cCodRetIB;
        RETURN cCodRet;

    END IF;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para generar el archivo de Teléfonos del cliente', 
'AUTOR: Enrique Lizárraga Lugo ',
'VERSION: 20101109.1545';


CREATE PROCEDURE "informix".inserta_bitacora_cob(vempresa CHAR(3),
                                            vproceso CHAR(4), cCod_ret CHAR(5), cMensaje CHAR(80), t_eje CHAR(2))
--declaracion de variables
----------------------------------------------------------------------------------------------
     DEFINE sql_err 			        INTEGER;
     DEFINE isam_err 		        INTEGER;
     DEFINE error_info		        CHAR(80);
     DEFINE vdia						DATE;
     DEFINE vhora					CHAR(8);

     LET sql_err       = 0;
	   LET isam_err      = 0;
	   LET error_info    = '';
	                          
	BEGIN

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

    IF (t_eje = '01') THEN

            INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES(vempresa, vproceso, today, '000000', 'PROCESO INICIALIZADO', user, vdia, vhora);
	    
    ELIF (t_eje = '02') THEN

        INSERT INTO cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES(vempresa, vproceso, today, cCod_ret, cMensaje, user, vdia, vhora);
    
    ELIF (t_eje = '03') THEN

        INSERT INTO bdicobranza:cb_bitacora(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
        VALUES(vempresa, vproceso, today, '000000', 'PROCESO FINALIZADO', user, vdia,  vhora);

    END IF;

	END;
END PROCEDURE;
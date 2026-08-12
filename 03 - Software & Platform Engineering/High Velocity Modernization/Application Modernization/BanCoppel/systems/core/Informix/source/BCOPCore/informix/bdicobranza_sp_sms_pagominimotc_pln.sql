CREATE PROCEDURE "informix".sp_sms_pagominimotc_pln()
-- execute procedure "informix".sp_sms_pagominimotc_pln();
returning 
char (06),
VARCHAR(150);

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--2012-05-09
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1

-- execute procedure "informix".sp_sms_pagominimotc();
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
DEFINE dPagoMinimo_total   DECIMAL(18,2);
define vpago            DECIMAL(18,2);
DEFINE Vfecha_apertura  DATE;
DEFINE iCel             SMALLINT;
DEFINE vdia_pago        smallint;
DEFINE dPagoMinimo     DECIMAL(18,2);
DEFINE vpago_vencido    DECIMAL(18,2);


---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(6);
DEFINE COD_RET              VARCHAR(6);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(150);
define vcontador			  INTEGER;
--define vcount				  integer;
define iCount_TCP_PAGMIS 	  integer; --A.L.L.
define vvalor 				  smallint;
define i 					  integer;
define num 					  smallint;
DEFINE iCuentasProcesadas     integer;
DEFINE iCuentasExcluidasXSMS  integer;
DEFINE iCuentasPagoCompleto   integer;
DEFINE iCuentasExcluidasXCel  integer;
DEFINE iCuentasExcluidasXPagoMin  integer;
DEFINE dFechaCarLinea         date;
DEFINE vempresa               Char(3);
DEFINE dIntVdo                DECIMAL(18,2);
DEFINE dIntMoratorio          DECIMAL(18,2);
DEFINE dIvaIntVdo             DECIMAL(18,2);
DEFINE dPagosVdos             DECIMAL(18,2);
DEFINE dIvaIntMoratorio       DECIMAL(18,2);
DEFINE dIntMes                DECIMAL(18,2);
DEFINE dIvaIntMes             DECIMAL(18,2);
DEFINE dIntVig                DECIMAL(18,2);
DEFINE IvaIntVig              DECIMAL(18,2);

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
LET v_pago_min_sin_vdo  = 0;
LET dPagoMinimo_total  = 0;
let vpago               = 0;
LET iCel                = 0;
LET vdia_pago           = 0;
let dPagoMinimo        = 0;
let vnumcte             = '';
let vnumcredito         = '';
let vnumtarjeta         = '';
let vimporte            =0;
let vfecha              = date(1);
let SQL_ERR             = 0;
let ISAM_ERR            = 0;
let ERROR_INFO          = '';
let P_COD_RET           = '000000';
let COD_RET             = '000000';
let P_MENSAJE           = 'El proceso de la campaña SMS pago completo platino se realizó correctamente.';
let vproceso            = '0302';
let cMensaje            = '';
let vpago_vencido       = 0;
let vvalor_numerico     = 0;
LET vcontador           = 0;
let iCount_TCP_PAGMIS  = 0;
let i                   = 0;
let num                 = 0;
let iCuentasProcesadas    = 0;
let iCuentasExcluidasXSMS = 0;
let iCuentasPagoCompleto  = 0;
let iCuentasExcluidasXCel = 0;
let iCuentasExcluidasXPagoMin = 0;
let dFechaCarLinea      = date(1);
let vempresa            = '001';
let dIntVdo             = 0;
let dIntMoratorio       = 0;
let dIvaIntVdo          = 0;
let dPagosVdos          = 0;
let dIvaIntMoratorio    = 0;
let dIntMes             = 0;
let dIvaIntMes          = 0;
let dIntVig             = 0;    
let IvaIntVig           = 0;

--  SET DEBUG FILE TO 'sp_sms_pagominimotc_pln.out';
--  TRACE ON;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
--        LET P_MENSAJE = ERROR_INFO;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02') RETURNING COD_RET;	
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;
  
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
	
--	DELETE FROM bdicobranza:cb_info_administrativa WHERE empresa ='001' and fecha_ejecucion <= vfecha and num_campania = 18; 

--temporal solo para pruebas
	--let vfecha = mdy('02','13','2016');
--temporal solo para pruebas
		
	let vfecha = vfecha - 1 units month;
	let vfecha = mdy(month(vfecha),day(18),year(vfecha));
--let vfecha = '01-01-2010';--'05-08-2012';	

/* Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	select valor_numerico 
		into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 4;*/
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

    set isolation to dirty read;

	FOREACH
	
		SELECT a.numcte, a.num_credito
			INTO vnumcte, vnumcredito
		FROM bdicred:sd_maecred a,/*bdicred:sd_sdos_cartera_linea b,*/
                bdicred:sd_maecredanexo m
		WHERE a.empresa = vempresa
		  AND m.empresa = a.empresa 
          AND m.num_credito = a.num_credito 
		  AND a.num_producto = '7000'
--            and a.status_cred in('AA')
--		  AND a.campo_trab3 <> 'BAJA'
          AND m.fecha_ult_pago >= vfecha
          AND m.fecha_ult_pago <= today
			
		LET iCuentasProcesadas = iCuentasProcesadas + 1;
			
/*		select f.mto_fin_ven_trasp,f.monto_financiado into iPagoVenc,dPagoMinimo
		from bdicred:"informix".sd_maesdos f
		where f.empresa = '001' AND f.num_credito = vnumcredito;
*/

        CALL  bdicred:"informix".sp_obtener_pagomin(vempresa,vnumcredito) RETURNING COD_RET,cMensaje,dPagoMinimo,dIntVdo,dIntMoratorio,
                dIvaIntVdo,dPagosVdos,dIvaIntMoratorio,dIntMes,dIvaIntMes,dIntVig,IvaIntVig;

        if COD_RET != '000000' then
    		LET iCuentasExcluidasXPagoMin    = iCuentasExcluidasXPagoMin    + 1;
            CONTINUE foreach;
        end if;

		if (dPagoMinimo > 0	) then		
/*			SELECT limit 1 e.nombre, c.nombre 
				INTO  cNomEstado, cNomCiudad  
			FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
			WHERE d.numcte= vnumcte
				AND d.tipo_dir= '1'
				AND d.estado = e.estado
				AND d.ciudad = c.ciudad
				AND c.estado = e.estado;*/
			
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
		    AND d.tipo_tel= '2' and status_tel = 'A'; /* and d.cofetel ='V' ;*/--RQM 09 598"
			
			IF cCel IS NULL OR cCel = '' THEN 
               LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
               CONTINUE foreach; 
            END IF;
			 
--			if (cCel <> '') then
		    LET iCel = LENGTH(cCel) + 1 - 10;
    
--		    IF cCel <> '' then
				IF ( LENGTH(cCel) > 10 ) THEN
			       LET cCel = SUBSTR(cCel,iCel,10);
				ELIF ( LENGTH(cCel) < 10 ) THEN
                    LET cCel ='';
			    END IF;			
--			END IF;
		
/*			SELECT limit 1 NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
			INTO cNombre1, cNombre2, cApellPat, cApellMat
			FROM bdinteg:"informix".si_cliente
			WHERE numcte= vnumcte;		

			SELECT  {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
				INTO cSituacion, iCausa
			FROM bdisitesp:"informix".se_ctessitespcte
			WHERE numcte = vnumcte;
			
			IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
			IF iCausa IS NULL THEN LET iCausa = 0; END IF; */
			
--			if (cCel <> '') then
/*				if (vnumcredito is not null) then
                    INSERT INTO bdicobranza:"informix".cb_info_administrativa (empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
                            nombre1, nombre2, apell_paterno, apell_materno, t_celular, 
                            sdo_total, pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, 
                            causa,situacion,pago_vencido ,pago_req_sms)
                    VALUES ('001', 18, '7000', today, vnumcte, vnumcredito, cNumCta, vnumtarjeta, cNomCiudad, cNomEstado, cNombre1, cNombre2, cApellPat, cApellMat, cCel, 
                    vsaldo_total, dPagoMinimo, vdia_pago, v_sdo_venc_int_mora, iPagoVenc, v_pago_min_sin_vdo, 
                    iCausa,cSituacion,vpago_vencido ,dPagoMinimo);
				ELSE
                    LET iOtrasExclusiones = iOtrasExclusiones + 1;
                END IF;                    
*/				
				--A.L.L.
				LET iCount_TCP_PAGMIS = iCount_TCP_PAGMIS + 1;
				call bdimnsj:"informix".sp_registra_evento (2, 'TCP_PAGMIS' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',dPagoMinimo,0,0,0,0, '', '') RETURNING COD_RET;
				LET vcontador = vcontador + 1 ;
--			end if;
--			end if;
			--end if;
        else
            LET iCuentasPagoCompleto = iCuentasPagoCompleto + 1;
    		CONTINUE foreach;
		end if;
        let dPagoMinimo = 0;
--		if (vcontador = vvalor_numerico) then exit FOREACH; end if; -- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	END FOREACH
	
	if (vcontador >= 1) then 
        let i = 0;
        LET num = 0;
        FOR i in (1 to vvalor)
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
            select  2, 'TCP_PAGMIS',numcte,current,'',100
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
                let num = num + 10;
        end for
	end if;

	--A.L.L.
--	IF iCount_TCP_PAGMIS > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_PAGMIS',iCount_TCP_PAGMIS,iCuentasExcluidasXCel) RETURNING COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_PAGMIS',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING COD_RET;
--	END IF;
	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña SMSs PAGO COMPLETO : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados PAGO MINIMO COMPL. PLATINO : ' ||iCount_TCP_PAGMIS;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas error pago mínimo : ' ||iCuentasExcluidasXPagoMin;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por pago completo : ' ||iCuentasPagoCompleto;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING COD_RET;

     if COD_RET != '000000' then
        let P_COD_RET = COD_RET;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

    RETURN P_COD_RET,P_MENSAJE;

end;
end procedure;
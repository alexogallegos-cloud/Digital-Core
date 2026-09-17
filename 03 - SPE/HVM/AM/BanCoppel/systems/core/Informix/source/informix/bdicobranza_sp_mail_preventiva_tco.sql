CREATE PROCEDURE "informix".sp_mail_preventiva_tco(pempresa char(3))
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(150)  AS mensaje_retorno;
-------------------------------------------------------------------------------------------------------------
--   execute PROCEDURE "informix".sp_mail_preventiva_tco('001');
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
DEFINE cMensajePagoMin  CHAR(150);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cEmail			CHAR(60);
DEFINE cApellPat		CHAR(26);
DEFINE vnumprod			char(4);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
--NUEVO
DEFINE vmail            CHAR(100);
DEFINE Vfecha_apertura  DATE;
--DEFINE Vcount smallint;
define vcontador		INTEGER;
DEFINE iCount_TCO_PREVEN INTEGER; --A.L.L.
DEFINE cMensaje         VARCHAR(150);
define vnumtarjeta      CHAR(20) ;
DEFINE vproceso         CHAR(4);
define vpri_dia_mes     DATE;
define vvalor			SMALLINT;
define i    			INTEGER;
define x    			INTEGER;
define num  			SMALLINT;
DEFINE iCuentasProcesadas        INTEGER;
DEFINE iCuentasExcluidasXMail    INTEGER;
DEFINE iCuentasExcluidasXPagoMin INTEGER;
DEFINE iCuentasPagoCompleto   	 INTEGER;
DEFINE dPagoNoGeneraInt     DECIMAL(18,2);
DEFINE dPagoMinimo          DECIMAL(18,2);
DEFINE dSdoCapInsoluto		DECIMAL(18,2);
DEFINE dSdoRetenido			DECIMAL(18,2);
DEFINE dIntVdo				DECIMAL(18,2);
DEFINE dIntMoratorio		DECIMAL(18,2);
DEFINE dIvaIntVdo			DECIMAL(18,2);
DEFINE dPagosVdos			DECIMAL(18,2);
DEFINE dIvaIntMoratorio		DECIMAL(18,2);
DEFINE dIntMes				DECIMAL(18,2);
DEFINE dIvaIntMes			DECIMAL(18,2);
DEFINE dIntVig				DECIMAL(18,2);
DEFINE dIvaIntVig			DECIMAL(18,2);
DEFINE dMontoIntIva			DECIMAL(18,2);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "000000";
LET P_COD_RET           = "000000";
LET P_MENSAJE           ='El proceso de las campañas EMAILs PREVENTIVAS ORO se realizó correctamente.';
LET cMensajePagoMin		= '';
LET dtFechaHoy			= '';
LET cNumCte				= '';
LET cNumCta				= '';
LET cNumCred			= '';
LET	cDiasAnticipados	= 0;
LET cEmail				= '';
LET cApellPat			= '';
LET vnumprod        	= '';
LET vmail               = '';
LET vcontador           = 0;
LET iCount_TCO_PREVEN    = 0; --A.L.L.
LET vproceso            ='0305';
LET cMensaje            = '';
LET vnumtarjeta         = '';
LET vvalor_numerico     = 0;
LET vtotal1             = 0;
LET vtotal2             = 0;
LET vtotal              = 0;
LET vpri_dia_mes        = date(1);
LET vvalor              = 0;
LET num                 = 0;
LET iCuentasExcluidasXMail      = 0;
LET iCuentasExcluidasXPagoMin   = 0;
LET iCuentasPagoCompleto        = 0;
LET iCuentasExcluidasXMail      = 0;
LET iCuentasProcesadas          = 0;
LET dPagoMinimo        = 0;
LET dPagoNoGeneraInt   = 0;
LET dPagoMinimo        = 0;
LET dSdoCapInsoluto		= 0;
LET dSdoRetenido		= 0;
LET dIntVdo				= 0;
LET dIntMoratorio		= 0;
LET dIvaIntVdo			= 0;
LET dPagosVdos			= 0;
LET dIvaIntMoratorio	= 0;
LET dIntMes				= 0;
LET dIvaIntMes			= 0;
LET dIntVig				= 0;
LET dIvaIntVig			= 0;
LET dMontoIntIva		= 0;



BEGIN

ON EXCEPTION SET iSqlErr
--ON EXCEPTION SET iSqlErr, isam_err, error_info
    LET cCodRet= iSqlErr;
    LET P_COD_RET= iSqlErr;
    LET P_MENSAJE = 'Error al ejecutar el proceso.';
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '02')RETURNING cCodRet; 
    RETURN P_COD_RET,P_MENSAJE;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_mail_preventiva_tc.out';
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
--let dtFechaHoy = mdy('09','30','2014');
--let vpri_dia_mes = mdy('09','01','2014');
--temporal solo para pruebas
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
		
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
	
/* --Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)
	select valor_numerico 
		into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 10;
*/	-- Se elimina a petición del usuario solicitado por correo el 21/Jul/2014 (fecha modificación 31/Jul/2014)	

	FOREACH	

		SELECT a.numcte, a.num_credito, b.sdo_cap_insoluto, b.sdo_retenido, a.num_producto
		  INTO cNumCte, cNumCred, dSdoCapInsoluto, dSdoRetenido, vnumprod
		  FROM bdicred:"informix".sd_maecred a
        INNER JOIN bdicred:sd_maesdos b ON b.empresa=a.empresa AND b.num_credito=a.num_credito AND b.monto_financiado>0
		 WHERE a.empresa      = pempresa 
           AND a.num_credito >= ''
           AND a.num_producto = '8100'
	
        let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		SELECT TRIM(apell_paterno)
		  INTO cApellPat
		  FROM bdinteg:"informix".si_cliente
		 WHERE numcte= cNumCte;		

--Obtiene pago para no generar intereses actualizado con pagos
		CALL bdicred:"informix".sp_consulta_saldocortemin(pempresa,cNumCred,0) RETURNING P_COD_RET, dPagoNoGeneraInt;
		IF P_COD_RET != '00000' THEN RETURN P_COD_RET,cMensajePagoMin;	END IF;

--Obtiene pago mínimo al corte actualizado con pagos
		CALL bdicred:"informix".sp_consulta_saldocortemin(pempresa,cNumCred,4) RETURNING P_COD_RET, dPagoMinimo;
		IF P_COD_RET != '00000' THEN RETURN P_COD_RET,cMensajePagoMin;	END IF;
			
        if (dPagoNoGeneraInt is null or dPagoNoGeneraInt ='') or (dPagoMinimo is null or dPagoMinimo = '')then
    		LET iCuentasExcluidasXPagoMin    = iCuentasExcluidasXPagoMin    + 1;
            CONTINUE foreach;
        end if;
	
		if dPagoMinimo > 0	then	
            let cEmail = '';
            select limit 1 cte.correo_elec into cEmail 
            from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = cNumCte and cte.status_correo ='A'
                                and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
            where empresa  = '001' and numcte = cNumCte and status_correo ='A');	

            if cEmail is null or cEmail = '' then 
                LET iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
                CONTINUE foreach; 
            end if;
			
            LET iCount_TCO_PREVEN = iCount_TCO_PREVEN + 1;
            call bdimnsj:"informix".sp_registra_evento (1, 'TCO_PREVEN' , cNumCte, cNumCred,vnumtarjeta, 2,
                           cApellPat,'','','','',dPagoMinimo,dPagoNoGeneraInt, '','', '', '', '')RETURNING P_COD_RET;
			call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1018, cNumCred, cNumCte, vnumprod, today, cEmail, '','','') returning P_COD_RET;
            LET vcontador = vcontador + 1 ;
		end if;

		let dPagoMinimo = 0;
	END FOREACH;
	
	if (vcontador >= 1) then 
		let i = 0;
		LET num = 0;
		FOR i in (1 to vvalor)
			insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,string2,string3,importe1)
	--		select  2, 'TCO_PREVEN',numcte,current,apell_paterno,day(dtFechaHoy),month(dtFechaHoy),100
			select  2, 'TCO_PREVEN',numcte,current,'',0,'',0
			  from bdinteg:si_cliente
			 where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
			end for
	end if;

    CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_PREVEN',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING cCodRet;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña EMAILs PREVENTIVA TC ORO : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_TCO_PREVEN;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas error pago mínimo : ' ||iCuentasExcluidasXPagoMin; 
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
	   CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

/*
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			-- CALL bdicobranza:"informix".inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03');
			RETURN cCodRet;
    END IF;*/

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCodRet, cMensaje, '03') RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
 
END
END PROCEDURE;
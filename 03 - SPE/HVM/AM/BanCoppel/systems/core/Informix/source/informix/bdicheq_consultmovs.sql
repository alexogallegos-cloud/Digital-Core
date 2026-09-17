CREATE PROCEDURE "informix".consultmovs( pempresa char(3), pcuenta char(20), psecuencia smallint )
returning char(5),date,char(40),money(14,2),money(14,2),money(14,2), char(200);
    
    define vtransacc        char(40);
    define vfecha           date;
    define vmonto           money(14,2);
    define vsdoactual       money(14,2);
    define vsdodisp         money(14,2);
    define vserial          integer;
    define vconta           smallint;
    define vciclo           smallint;
    define vcodret          char(5);
    define vsqlerr          integer;
    define vnaturaleza      char(1);
    define vultmovto        smallint;
    define cFech_param      CHAR(10);
    define cFech_param_ini  CHAR(10);
	define vdescripcion     CHAR(200);
	define vConceptospei1	CHAR(40);
	define vConceptospei2   CHAR(33);
	define dFechaVal		DATE;
	define vConceptospei3	CHAR(32);
	define vConceptospei4   CHAR(28);
	define vConceptospei5	CHAR(52);
	define vConceptospei6	CHAR(13);
	define cReferen         CHAR(40);
	define cTransacc		CHAR(4);
	define cConcepto        CHAR(50);
	define cReferencia      CHAR(40);
    define cFechaTrn		CHAR(10);
    define vTipoCta		    CHAR(9);
	define vLeyOutBeneficiario		CHAR(41);

    let vcodret    		= "000";
    let vtransacc  		= " ";
    let vfecha     		= " ";
    let vmonto     		= 0;
    let vsdoactual 		= 0;
    let vsdodisp   		= 0;
    let vciclo     		= 0;
    let vultmovto  		= 5;
	let vConceptospei1	= "";
	let vConceptospei2	= "";
	let dFechaVal		= "";
	let vConceptospei3	= "";
	let vConceptospei4	= "";
	let vConceptospei5	= "";
	let vConceptospei6	= "";
	let cReferen		= "";
	let cTransacc		="";
	let cConcepto		="";
	let cReferencia		="";
	let vdescripcion	="";
	let cFechaTrn		="";
    let vTipoCta		= "";
	let vLeyOutBeneficiario = '(Dato no verificado por esta institucion)';

	--Set Debug File To '/home/c90301007/Traza/consultmovs_MODF.out';
    --Trace On;

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
        end if;
    end exception;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	-- RQM 09 704. Se agrega el campo saldo_sbc para que sea considerado en el calculo del saldo disponible.
    select mc.sdo_actual, (mc.sdo_actual - mc.sdo_retenido - mc.sdo_cong - mc.saldo_sbc)
      into vsdoactual, vsdodisp
      from sc_maechq mc
     where mc.cuenta = pcuenta;
       
    if vsdoactual is null then
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = "100";
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp, vdescripcion;
    end if;
    
    -- Extrae los ultimos 5 movimientos
    foreach
        select md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||trim(tr.descripcion), tr.naturaleza,  md.referencia
          into vfecha, vserial, vmonto, vtransacc, vnaturaleza, cReferen
          from sc_movdia md,
               bdinteg:si_transacc tr
         where md.cuenta = pcuenta 
           and md.cancelad <> "S" 
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
		   and tr.sistema = "01"
         order by fech_alt desc, num_serial desc

		  IF trim(substr(vtransacc,1,4)) = '0274' THEN

			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                       NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				  FROM bdispei:tblpago pgo 
				 INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
				 WHERE vchrclaverastreo = cReferen
				   AND dtfechavalor = vfecha
				   AND intcvetipopago <> 0;
            ELSE
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                       NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				  FROM bdispei:tblpago pgo 
				 INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
				 WHERE vchrclaverastreo = cReferen
				   AND dtfechavalor = vfecha
				   AND intcvetipopago <> 0;
            END IF;

            LET cFechaTrn = TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4)) = 18 THEN
               LET vTipoCta = '|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4)) = 16 THEN
			   LET vTipoCta = '|DEBITO: ';
            ELSE
               LET vTipoCta = '|CELULAR: ';
            END IF;
			
			LET vConceptospei1 = TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen = vConceptospei1;
			
			LET vdescripcion = "";
			
			LET vConceptospei2 = 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion = TRIM(vConceptospei2);
			
			LET vConceptospei3 = '|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4 = vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5 = '|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6 = '|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto = '|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha = '';
			LET vfecha = dFechaVal;
			
		END IF;
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp , vdescripcion with resume;
    end foreach;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    foreach
        select {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               md.fech_alt, md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza, md.referencia
          into vfecha,dFechaVal,vserial,vmonto,vtransacc,vnaturaleza,cReferen
          from sc_movhis md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
		   and tr.sistema = "01"
        union all
        select {+INDEX(bdicheq:sc_movhis_old movhis1)}
               md.fech_alt, md.fech_val, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza, md.referencia
          from sc_movhis_old md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param_ini
           and md.fech_alt < cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
		   and tr.sistema = "01"
         order by md.fech_alt desc, md.num_serial desc
		 
		 
		---  INFORMACION PARA OPERACIONES SPEI
		let vdescripcion = "";
		let cTransacc = SUBSTR(TRIM(vtransacc),1,4);
		 
		IF cTransacc = '0273' THEN
			SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                   NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
			  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
			  FROM bdispei:tblhistpago pgo 
             INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcoord = bco.cvecesif AND bco.intindice = bco.intindice )
			 WHERE vchrclaverastreo = cReferen
			   AND dtfechavalor = dFechaVal
			   AND intcvetipopago <> 0;

			LET cFechaTrn = TO_CHAR(vfecha, '%d/%m/%Y');

            IF LENGTH(TRIM(vConceptospei4)) = 18 THEN
               LET vTipoCta = '|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4)) = 16 THEN
			   LET vTipoCta = '|DEBITO: ';
            ELSE
               LET vTipoCta = '|CELULAR: ';
            END IF;
            
			LET vConceptospei1 = SUBSTR(TRIM(vtransacc),5,11) || ' ' || cReferen;
			LET cReferencia = vConceptospei1;
			
			LET vdescripcion = "";
			
			LET vConceptospei2 = 'BANCO ORIGEN: ' || TRIM(vConceptospei2);
			LET vdescripcion = TRIM(vConceptospei2);
			
			LET vConceptospei3 = '|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4 = vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5 = '|ORDENANTE: ' || TRIM(vConceptospei5);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei5);
			
			LET vConceptospei6 = '|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto = '|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha = '';
			LET vfecha = dFechaVal;
		END IF;

	    IF cTransacc = '0274' THEN
			IF SUBSTR(cReferen,1, 9) = 'BANCOPPEL' THEN
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                       NVL(vchrconceptopago,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				  FROM bdispei:tblhistpago pgo 
				 INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
				 WHERE vchrclaverastreo = cReferen
				   AND dtfechavalor = dFechaVal
				   AND intcvetipopago <> 0;
            ELSE
                SELECT {+INDEX(bdispei:tblbanco xak1tblbanco2)}
                       NVL(vchrconceptopago2,''), NVL(vchrnombrecorto,''), NVL(vchrcuentaord,''), NVL(vchrnombreord,''), NVL(intrefnumerica,'')
                  INTO cConcepto, vConceptospei2, vConceptospei4, vConceptospei5, vConceptospei6
				  FROM bdispei:tblhistpago pgo 
				 INNER JOIN bdispei:tblbanco bco ON ( pgo.cvecesifbcodest = bco.cvecesif AND bco.intindice = bco.intindice )
				 WHERE vchrclaverastreo = cReferen
				   AND dtfechavalor = dFechaVal
				   AND intcvetipopago <> 0;
            END IF;

            LET cFechaTrn = TO_CHAR(vfecha, '%d/%m/%Y');
  
            IF LENGTH(TRIM(vConceptospei4)) = 18 THEN
               LET vTipoCta = '|CLABE: ';
            ELIF  LENGTH(TRIM(vConceptospei4)) = 16 THEN
			   LET vTipoCta = '|DEBITO: ';
            ELSE
               LET vTipoCta = '|CELULAR: ';
            END IF;
			
			LET vConceptospei1 = TRIM(vdescripcion) || ' ' || cReferen;
			LET cReferen = vConceptospei1;
			
			LET vdescripcion = "";
			
			LET vConceptospei2 = 'BANCO DESTINO: ' || TRIM(vConceptospei2);
			LET vdescripcion = TRIM(vConceptospei2);
			
			LET vConceptospei3 = '|FECHA TRANSFERENCIA: ' || cFechaTrn;
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei3);
			
			LET vConceptospei4 = vTipoCta || TRIM(vConceptospei4);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei4);
			
			LET vConceptospei5 = '|BENEFICIARIO: ' || TRIM(vConceptospei5);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei5) || vLeyOutBeneficiario;
			
			LET vConceptospei6 = '|REF: ' || TRIM(vConceptospei6);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(vConceptospei6);
			
			LET cConcepto = '|CONCEPTO: ' || SUBSTR(cConcepto,1,40);
			LET vdescripcion = TRIM(vdescripcion) || TRIM(cConcepto);
			
			LET vfecha = '';
			LET vfecha = dFechaVal;
		END IF;
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;

        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp , NVL(vdescripcion,'|||||') with resume;
    end foreach;
    
    end;
    
end procedure
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdicheq',
'FECHA :        09-06-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.1';

CREATE PROCEDURE "informix".sp_desbloqueo_diainhabil(pempresa  CHAR(3))
RETURNING CHAR(6), CHAR(6);

    DEFINE cod_ret      		CHAR(6);
	DEFINE v_clave      		CHAR(6);
	DEFINE vfecha				DATE;
	DEFINE v_fecha_pre			DATE;
	DEFINE vfecha_cuota			DATE;
	DEFINE vnum_credito			CHAR(20);
	DEFINE vcapital_mto_cuota	DECIMAL(18,2);
	DEFINE vsdo_actual 			DECIMAL(18,2);
	DEFINE vstatus_cta			CHAR(1);
	DEFINE vcuenta				CHAR(20);
	--DEFINE vnum_credito 		CHAR(20);
	DEFINE vnum_tarjeta 		CHAR(20);

	DEFINE vnum_cte             CHAR(20);
	DEFINE vapell_pat           CHAR(26);
    DEFINE vapell_mat           CHAR(26);
    DEFINE vnombre1             CHAR(26);
    DEFINE vnombre2             CHAR(26);
	DEFINE vrazon_soc           CHAR(60);
	DEFINE vedo_cta             CHAR(1);
	DEFINE vsdo_disp            MONEY(14,2);
	DEFINE vsdo_ret             MONEY(14,2);
	DEFINE vsdo_ccc             MONEY(14,2);
	DEFINE vsdo_disp_ccc        MONEY(14,2);
	DEFINE vsdo_cta             MONEY(14,2);
	DEFINE vtipo_linea          CHAR(1);
	DEFINE vdescrip1            CHAR(40);
    DEFINE vdescrip2            CHAR(40);
	DEFINE vsdo_t1              MONEY(14,2);
	DEFINE vsdo_cong            MONEY(14,2);
	DEFINE vimp_chq_sbc         MONEY(14,2);
	DEFINE vusubloq             CHAR(8);
	DEFINE vfecbloq             DATE;
	DEFINE vcta_clabe           CHAR(18);
	DEFINE vclave				CHAR(5);
    DEFINE vc_numcredito        CHAR(20);
    DEFINE vc_kmpo_trabjo       CHAR(20); 
	DEFINE vc_motivo            CHAR(2);
	DEFINE vmonto_desbloq       MONEY(14,2);
	DEFINE vc_tipo_mov          CHAR(1);
	DEFINE vcproceso    		CHAR(15);
    DEFINE vcproceso_M1 		CHAR(15);
    DEFINE v_exist_proc 		INTEGER;
	
	DEFINE credcontproc   CHAR(1);
	DEFINE intecontproc	  CHAR(1);
	DEFINE cMensaje				CHAR(125);
	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);
	
    

	LET cod_ret 			= "000000";
	LET v_clave 			= "0000";
	LET vfecha				= DATE(1);
	LET v_fecha_pre			= DATE(1);
	LET vfecha_cuota		= DATE(1);
	LET vnum_credito		= '';
	LET vsdo_actual     	= 0;
	LET vcapital_mto_cuota  = 0;
	LET vstatus_cta			= '';
	LET vcuenta				= '';
	LET vnum_tarjeta		= '';

	LET vnum_cte            = '';
	LET vapell_pat          = '';
    LET vapell_mat          = '';
    LET vnombre1            = '';
    LET vnombre2            = '';
	LET vrazon_soc          = '';
	LET vedo_cta            = '';
	LET vsdo_disp           = 0;
	LET vsdo_ret            = 0;
	LET vsdo_ccc            = 0;
	LET vsdo_disp_ccc       = 0;
	LET vsdo_cta            = 0;
	LET vtipo_linea         = '';
	LET vdescrip1           = '';
    LET vdescrip2           = '';
	LET vsdo_t1             = 0;
	LET vsdo_cong           = 0;
	LET vimp_chq_sbc        = 0;
	LET vusubloq            = '';
	LET vfecbloq            = DATE(1);
	LET vcta_clabe          = '';
	LET vclave				= '00001';
    LET vc_numcredito       = '';
    LET vc_kmpo_trabjo      = ''; 
	LET vc_motivo           = '';
	LET vmonto_desbloq      = 0;
	LET vc_tipo_mov         = '';
	--LET vcproceso    		= '';
    --LET vcproceso_M1 		= '';
	LET vcproceso			= 'DesbDiaInh';
    LET vcproceso_M1		= 'DesbDiaInh_M1';
    LET v_exist_proc 		= 0;
	
	LET credcontproc	= " ";
	LET intecontproc	= " ";
	LET cMensaje			= "Se realizo el Proceso correctamente";
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	
	
    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	-- Fecha Creacion: 30/Ago/2012
    -- Fecha Modifica: 6/Nov/2012
    -- Fecha Remodifica: 14/mar/2013
	-- Objetivo: Desbloquea saldo de cuentas de captacion 
    --          que tienen comprometido cargo por Credinomina
    --          y que su cuota de pago fue previamente bloqueada 
    --          por el Sp sp_bloqueo_diainhabil of bdicheq
	--*********************************************************--

	
	--SET DEBUG FILE TO "/tmp/sp_desbloqueo_disinhabil.out";
	--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	    IF iSqlErr != 0 THEN
			LET cod_ret     = iSqlErr;
		    LET cMensaje = cErrorInfo;
	    END IF;
			UPDATE bdicred:"informix".sd_contproc
				SET status_proc = "C",
					hora_fin    = CURRENT,
					cod_ret     = cod_ret,
					mensaje     = cMensaje
			WHERE empresa     = pempresa
			AND proceso     = vcproceso
			AND fecha       = vfecha;

			UPDATE bdinteg:sx_contproc
				SET status_proc = "C",
					hora_fin    = CURRENT,
					codret      = cod_ret
			WHERE empresa     = pempresa
				AND proceso     = vcproceso
				AND fecha       = vfecha;

		RETURN cod_ret, v_clave;

	END EXCEPTION;

	IF pempresa = "" THEN
		LET cod_ret = 111111;
		return cod_ret, v_clave;
    END IF;

	SELECT fecha_hoy 
		INTO vfecha
    FROM bdicred:sd_fechas
	WHERE empresa = '001';
	 
    
    /*SELECT COUNT(status_proc) 
        INTO v_exist_proc
    FROM bdinteg:sx_contproc
    WHERE fecha= vfecha 
    and proceso = vcproceso_M1;

    IF v_exist_proc>0 THEN
    --FMV 14MAR13 Bitacoras de ejecucion del proceso
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
           VALUES ('001','DesbDiaInh',vfecha,'06','I','informix',CURRENT,CURRENT,'000');
        
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
           VALUES ('001','DesbDiaInh',vfecha,'I','informix',CURRENT,CURRENT,'000','DesbCtaDiaInh');
    ELSE
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
           VALUES ('001',vcproceso_M1,vfecha,'06','I','informix',CURRENT,CURRENT,'000');
        
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
           VALUES ('001',vcproceso_M1,vfecha,'I','informix',CURRENT,CURRENT,'000','DesbCtaDiaInh_M1');
    END IF;*/
	
	-- *******************************************************
	-- *         INSERTA PARA EJECUCION DE PROCESO           *
	-- *******************************************************
	-- INI CAS

		SELECT status_proc 
			INTO intecontproc
		FROM bdinteg:sx_contproc
		WHERE fecha= vfecha 
		AND proceso = vcproceso;
		
		SELECT status_proc  
			INTO credcontproc
		FROM bdicred:sd_contproc
		WHERE fecha= vfecha 
		AND proceso = vcproceso;

		IF (intecontproc = 'I') THEN
			LET cMensaje="EXISTE UN PROCESO PREVIO EN EJECUCION";
			RETURN cod_ret,v_clave;
		END IF;	 

		IF (intecontproc IS NULL) THEN
			INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
			VALUES ('001',vcproceso,vfecha,'06','I','informix',CURRENT,CURRENT,'000');
		ELSE 
			UPDATE bdinteg:sx_contproc 
				SET hora_ini=CURRENT,status_proc='I'
			WHERE fecha= vfecha 
			AND proceso =vcproceso;
		END IF;

		IF (credcontproc IS NULL) THEN
			INSERT INTO  bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
			VALUES ('001',vcproceso,vfecha,'I','informix',CURRENT,CURRENT,'000','DesbCtaDiaInh');
		ELSE
			UPDATE bdicred:sd_contproc 
				SET hora_inicio=CURRENT,status_proc='I' ,mensaje = 'DesbCtaDiaInh'
			WHERE fecha= vfecha 
			AND proceso =vcproceso;
		END IF;
			
	--FIN CAS


	FOREACH WITH HOLD                                   

		SELECT cta.num_cta, amor.fecha_cuota, amor.capital_mto_cuota, amor.campo_trabajo4,
			cheq.sdo_actual, cheq.status_cta, amor.num_credito 
	    INTO vcuenta, vfecha_cuota, vcapital_mto_cuota, vc_kmpo_trabjo,
            vsdo_actual, vstatus_cta, vc_numcredito
		FROM bdicred:sd_maecredcrd a,
            bdicred:sd_amortiza_creditocrd amor, 
            bdicred:sd_ctascarg cta,
            bdicheq:sc_maechq cheq
		WHERE a.empresa = amor.empresa
			AND a.num_credito = amor.num_credito
			AND a.empresa = cta.empresa
			AND a.num_credito = cta.num_credito
			AND cta.empresa = cheq.empresa
			AND cta.num_cta = cheq.cuenta
			AND a.num_producto = '6400'
			AND fecha_cuota = vfecha
			AND capital_status = '1'  --FMV por que ya existe cuota con factura en fecha de exigibilidad
			AND campo_trabajo4 = 'B'
		  
		  /*(SELECT max(fecha_cuota)
                               FROM bdicred:sd_amortiza_creditocrd
                              WHERE num_credito = a.num_credito
                                AND capital_status = '1'  --FMV por que ya existe cuota con factura en fecha de exigibilidad
                                AND campo_trabajo4 = 'B') --FMV Solo desbloqueo de cuota que fue bloqueda, no todos*/
   
		ON EXCEPTION IN (-284)
		END EXCEPTION;
			
		SELECT num_tarjeta  
			INTO vnum_tarjeta
		FROM bdicheq:sc_tarjeta
	 	WHERE cuenta = vcuenta
			AND secuencia = (SELECT max(tar.secuencia)
                            FROM bdicheq:sc_tarjeta tar
                            WHERE tar.empresa = pempresa
								AND tar.cuenta = vcuenta
								AND tar.tipo_tarjeta ='T')
								--AND tar.status_tar = 'A')  FMV 6nov12: No debe buscar estatus de tarjeta activa
			AND tipo_tarjeta ='T' ;
			--AND status_tar = 'A';   FMV 6nov12: No debe buscar estatus de tarjeta activa

		CALL  "informix".cons_sdos1('001',vcuenta,vnum_tarjeta)RETURNING cod_ret,vcuenta,
																vnum_cte,vapell_pat,vapell_mat,
																vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_disp,
																vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea,
																vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,
																vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe;


		IF (vfecha_cuota = vfecha) THEN
			--IF (vedo_cta = '4') THEN  fmv 17oct12  

			SELECT tipo_mov, importe
				INTO vc_tipo_mov, vmonto_desbloq            
	        FROM bdicheq:sc_histbloq
	        WHERE empresa = pempresa
				AND cuenta = vcuenta
				AND motivo = '20'    -- FMV 31-OCT-2012: Motivo de bloqueo por credinomina en captacion
				AND fecha >= (vfecha - 7 units day)  --> FMV 1-NOV-12: Rango de dias en los q se hizo el bloqueo mas reciente
				AND folio_suc !='';

			--- validar saldos para desbloqueo
			IF (vmonto_desbloq <= vsdo_cong AND vc_kmpo_trabjo = vc_tipo_mov) THEN
				CALL  "informix".bloqueo_cta('001',
											vcuenta ,
											vmonto_desbloq,  -- monto a desbloquear
											'00',                -- motivo del bloqueo (para desbloqueo siempre debes enviar .00.)
											0,                   -- tipo de bloqueo (como estas desbloqueANDo debe ir un cero)
											vfecha_cuota,        -- fecha de desbloqueo
											'informix',          -- usuario
											'CRNOM',             -- clave generada (como un tipo de folio para el desbloqueo)
											'',                  -- area que solicita el bloqueo (utilizado por la aplicacion del SIF para bloquear cuentas)
											'',                  -- codigo del area que solicita el bloqueo (utilizado por la aplicacion del SIF para bloquear cuentas)
											'',                  -- tipo del bloqueo (utilizado por la aplicacion del SIF para bloquear cuentas)
											'')                  -- codigo del tipo de bloqueo (utilizado por la aplicacion del SIF para bloquear cuentas)
											RETURNING cod_ret, v_clave;
				IF cod_ret = '000' then
					BEGIN WORK;
						UPDATE bdicred:sd_amortiza_creditocrd
							SET campo_trabajo4 = 'D'
	                    WHERE empresa = pempresa
							AND num_credito = vc_numcredito
            	            AND fecha_cuota = vfecha_cuota;             
					COMMIT WORK;	   
               	END IF;
			END IF;
		--	END IF;  fmv17oct12
		END IF;
	END FOREACH;
	
	UPDATE bdinteg:sx_contproc
		SET status_proc = "F", hora_fin = CURRENT, codret = cod_ret
	WHERE empresa   = pempresa
	AND proceso     = vcproceso
	AND fecha       = vfecha;
	
	UPDATE bdicred:"informix".sd_contproc
	SET status_proc = "F",
		hora_fin    = CURRENT,
		cod_ret     = cod_ret,
		mensaje     = cMensaje
	WHERE empresa   = pempresa
	AND proceso     = vcproceso
	AND fecha       = vfecha;

	RETURN cod_ret, v_clave;
	
END
END PROCEDURE;
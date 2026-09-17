CREATE PROCEDURE "informix".sp_consulta_cuentas_credito(pEmpresa CHAR(3), pNumCte CHAR(20),pUltreg SMALLINT)
RETURNING CHAR(6) AS cCodRet,
		  CHAR(20) AS cCuenta,
		  CHAR(20) AS cNumCredito,
		  CHAR(2) AS cStatus,
		  DATE AS dtFechaProxPago,
		  DECIMAL(18,2) AS dPagoMinimo,
		  DECIMAL(18,2) AS dSdoActCap,
		  CHAR(4) AS cProducto;		

    DEFINE iSqlErr INTEGER;
    DEFINE iIsamErr INTEGER;
    DEFINE cCodRet CHAR(6);
    DEFINE cNumCredito CHAR(20);
    DEFINE cStatus CHAR(2);
    DEFINE cCuenta CHAR(20);
    DEFINE cProducto CHAR(4);
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);
    DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE vvcodigo_retorno CHAR(6);
    DEFINE vvmensaje_retorno CHAR(80);
    DEFINE dIntVig DECIMAL(18,2);			
    DEFINE cTipCred CHAR(2);				
    DEFINE sConreg SMALLINT;
    DEFINE cConsulto CHAR(1);
    DEFINE cCodigo_retorno CHAR(6);
    DEFINE cMensaje_retorno CHAR(80);
    DEFINE cNumero_credito CHAR(20);
    DEFINE cCodigo_tipcred CHAR(2);
    DEFINE dtFecha_origen DATE;
    DEFINE dtFecha_prox_pago DATE;
    DEFINE dPago_minimo DECIMAL(18,2);
    DEFINE dtFecha_ult_pago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPagos_realizados INTEGER;
    DEFINE dLinea_otorgada DECIMAL(18,2);
    DEFINE dTasa_interes DECIMAL(9,2);
    DEFINE dTasa_moratorios DECIMAL(9,2);
    DEFINE dMonto_sbc DECIMAL(14,2);
    DEFINE dCap_vig DECIMAL(18,2);
    DEFINE dCap_trans DECIMAL(18,2);
    DEFINE dCap_vdo_exig DECIMAL(18,2);
    DEFINE dCap_vdo_no_exig DECIMAL(18,2);
    DEFINE dSdo_act_total_cap DECIMAL(18,2);
    DEFINE dInt_vig DECIMAL(18,2);
    DEFINE dInt_vdo DECIMAL(18,2);
    DEFINE dInt_moratorios DECIMAL(18,2);
    DEFINE dInt_mes DECIMAL(18,2);
    DEFINE dSdo_act_total_int DECIMAL(18,2);
    DEFINE dIva_int_vig DECIMAL(18,2);
    DEFINE dIva_int_vdo DECIMAL(18,2);
    DEFINE dIva_int_moratorios DECIMAL(18,2);
    DEFINE dIva_int_mes DECIMAL(18,2);
    DEFINE dSdo_act_total_iva DECIMAL(18,2);
    DEFINE dCom_pend DECIMAL(18,2);
    DEFINE dIva_com DECIMAL(18,2);
    DEFINE dSdo_retenido DECIMAL(18,2);
    DEFINE dTotal_liquidacion DECIMAL(18,2);
    DEFINE dInt_devengado DECIMAL(18,2);
    DEFINE dIva_int_devengado DECIMAL(18,2);
    DEFINE dLinea_disponible DECIMAL(18,2);
    DEFINE dPagos_vdos DECIMAL(18,2);
    DEFINE cDesc_status_cred CHAR(60);
    DEFINE iId_bloqueo_cred INTEGER;
    DEFINE cBloqueo_cta CHAR(60);
    DEFINE cId_causa_bloqueo_cred CHAR(3);
    DEFINE cCausa_bloqueo_cta CHAR(50);
    DEFINE cId_sit_esp_cte CHAR(1);
    DEFINE iId_causa_esp_cte INTEGER;
    DEFINE cSit_esp_cte CHAR(75);
    DEFINE cId_sit_esp_cred CHAR(1);
    DEFINE iId_causa_esp_cred INTEGER;
    DEFINE cSit_esp_cred CHAR(75);
    
    LET iSqlErr = 0;
    LET iIsamErr = 0;
    LET cCodRet = '000000';
    LET cNumCredito = '';
    LET cStatus = '';
    LET cCuenta = '';
    LET cProducto = '';
    LET dtFechaProxPago = DATE(1);
    LET dPagoMinimo = 0;
    LET dSdoActCap = 0;
    LET dIntVdo = 0;
    LET dIntMoratorio = 0;
    LET dIntMes = 0;
    LET dIvaIntVig = 0;
    LET dIvaIntVdo = 0;
    LET dIvaIntMoratorio = 0;
    LET dIvaIntMes = 0;
    LET dPagosVdos = 0;
    LET vvcodigo_retorno = '';
    LET vvmensaje_retorno = '';
    LET dIntVig = 0;
    LET cTipCred = '';
    LET sConreg = 0;
    LET cConsulto = '0';
    LET cCodigo_retorno = '';
    LET cMensaje_retorno = '';
    LET cNumero_credito = '';
    LET cCodigo_tipcred = '';
    LET dtFecha_origen = DATE(1);
    LET dtFecha_prox_pago = DATE(1);
    LET dPago_minimo = 0;
    LET dtFecha_ult_pago = DATE(1);
    LET iPlazo = 0;
    LET iPagos_realizados = 0;
    LET dLinea_otorgada = 0;
    LET dTasa_interes = 0;
    LET dTasa_moratorios = 0;
    LET dMonto_sbc = 0;
    LET dCap_vig = 0;
    LET dCap_trans = 0;
    LET dCap_vdo_exig = 0;
    LET dCap_vdo_no_exig = 0;
    LET dSdo_act_total_cap = 0;
    LET dInt_vig = 0;
    LET dInt_vdo = 0;
    LET dInt_moratorios = 0;
    LET dInt_mes = 0;
    LET dSdo_act_total_int = 0;
    LET dIva_int_vig = 0;
    LET dIva_int_vdo = 0;
    LET dIva_int_moratorios = 0;
    LET dIva_int_mes = 0;
    LET dSdo_act_total_iva = 0;
    LET dCom_pend = 0;
    LET dIva_com = 0;
    LET dSdo_retenido = 0;
    LET dTotal_liquidacion = 0;
    LET dInt_devengado = 0;
    LET dIva_int_devengado = 0;
    LET dLinea_disponible = 0;
    LET dPagos_vdos = 0;
    LET cDesc_status_cred = '';
    LET iId_bloqueo_cred = 0;
    LET cBloqueo_cta = '';
    LET cId_causa_bloqueo_cred = '';
    LET cCausa_bloqueo_cta = '';
    LET cId_sit_esp_cte = '';
    LET iId_causa_esp_cte = 0;
    LET cSit_esp_cte = '';
    LET cId_sit_esp_cred = '';
    LET iId_causa_esp_cred = 0;
    LET cSit_esp_cred = '';
    
    BEGIN
    
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,cNumCredito, cStatus, NVL(dtFechaProxPago,DATE(1)),NVL(dPagoMinimo,0),NVL(dSdoActCap,0),cProducto;
		END IF;
	END EXCEPTION;
    
	--- SET DEBUG FILE TO '/respaldosbd/mario/trace.sql';
	--- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
	IF NVL(pEmpresa,'') = '' OR  NVL(pNumCte,'') = '' THEN
	   LET cCodRet= '000001';
	ELSE
		FOREACH
			SELECT {+INDEX(bdicheq:sc_maechq maecheques)}
                   cuenta 
              INTO cCuenta 
              FROM bdicheq:"informix".sc_maechq 
			 WHERE num_cte = pNumCte 
               AND status_cta = 1 
			UNION
			SELECT DISTINCT cuenta_tf  
              FROM bditransfer:"informix".tf_maecte 
             WHERE numcte = pNumCte 
               AND status_cta = '1' 
             ORDER BY cuenta ASC
			
			LET sConreg = sConreg + 1;	
            
			IF sConreg <= pUltreg THEN 					
				CONTINUE FOREACH;
			END IF;	
            
			LET cNumCredito = '';
			LET cTipCred = '';
			LET cStatus = '';
			LET cProducto = '';
			LET dtFechaProxPago = DATE(1);
			LET dPagoMinimo = 0;
			LET dSdoActCap = 0;			

			FOREACH 			
				SELECT {+INDEX(bdicred:"informix".sd_ctascarg idx_sd_ctascarg2)}
                       num_credito AS credito 
                  INTO cNumCredito 
                  FROM bdicred:"informix".sd_ctascarg 
                 WHERE num_cta = cCuenta 
                   AND naturaleza = 'A'
				UNION 
				SELECT num_solicitud AS credito 
                  FROM bdisolic:"informix".ss_adn_solicitudcuenta 
                 WHERE empresa = pEmpresa
                   AND numcte = pNumCte
                   AND cuenta_nomina = cCuenta 
                   AND movil_cuenta = movil_cuenta
				UNION 
				SELECT {+INDEX(bdisolic:"informix".ss_sol_nomina pk_ss_sol_nomina)}
                       num_solicitud AS credito 
                  FROM bdisolic:"informix".ss_sol_nomina 
                 WHERE empresa = pEmpresa
                   AND num_solicitud = num_solicitud
                   AND numcte = pNumCte
                   AND cuenta = cCuenta 
				 ORDER BY credito ASC
                
				IF NVL(cNumCredito,'') <> '' THEN
					SELECT b.cod_prod,a.num_producto, a.status_cred
					  INTO cTipCred,cProducto, cStatus
					  FROM bdicred:"informix".sd_maecred a,
                           bdicred:"informix".sd_tipprod b
					 WHERE a.empresa = pEmpresa
					   AND a.num_credito = cNumCredito
					   AND a.numcte = pNumCte  
					   AND b.empresa = a.empresa
					   AND b.abrevia_prod = a.num_producto 
					   AND a.status_cred IN ("AA","BA","BT","E1","E2","E3");
                    
					IF cTipCred IS NULL OR NVL(cTipCred,'') = '' THEN
						SELECT b.cod_prod,a.num_producto, a.status_cred
						  INTO cTipCred,cProducto, cStatus
						  FROM bdicred:"informix".sd_maecredcrd a, 
                               bdicred:"informix".sd_tipprod b
						 WHERE a.empresa = pEmpresa 
						   AND a.num_credito = cNumCredito
                           AND b.empresa = a.empresa 
                           AND b.abrevia_prod = a.num_producto 
					       AND a.status_cred IN ("AA","BA","BT","VP","E1","E2","E3");
                        
						IF cTipCred IS NULL  OR NVL(cTipCred,'') = '' THEN
							LET cNumCredito = '';
							LET cStatus = '';
							LET dtFechaProxPago = DATE(1);
							LET dPagoMinimo = 0;
							LET dSdoActCap = 0;
							LET cProducto = '';		
							LET cCodRet = '000002';
						END IF;
					END IF;
                    
					IF cCodRet = '000000' THEN				
						IF cTipCred = 'T' THEN
							SELECT prox_fecha_pago
							  INTO dtFechaProxPago
							  FROM bdicred:"informix".sd_maecredanexo
							 WHERE num_credito = cNumCredito
							   AND empresa = pEmpresa;
						ELIF cTipCred  in ('P','R') THEN
							SELECT prox_fecha_pago
							  INTO dtFechaProxPago
							  FROM bdicred:"informix".sd_maecredanexocrd
							 WHERE num_credito = cNumCredito
							   AND empresa = pEmpresa;
						END IF;
						
						CALL bdicred:"informix".sp_obtener_pagomin(pEmpresa,cNumCredito) 
						RETURNING vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo,dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
						
						CALL bdicred:"informix".sp_consulta_saldos_general(pEmpresa, cNumCredito)
						RETURNING  cCodigo_retorno ,cMensaje_retorno, cNumero_credito, cCodigo_tipcred, dtFecha_origen, dtFecha_prox_pago, dPago_minimo, dtFecha_ult_pago, iPlazo, iPagos_realizados, dLinea_otorgada, dTasa_interes, dTasa_moratorios, dMonto_sbc, dCap_vig, dCap_trans, dCap_vdo_exig, dCap_vdo_no_exig, dSdo_act_total_cap, dInt_vig, dInt_vdo, dInt_moratorios, dInt_mes, dSdo_act_total_int, dIva_int_vig, dIva_int_vdo, dIva_int_moratorios, dIva_int_mes, dSdo_act_total_iva, dCom_pend, dIva_com, dSdo_retenido, dTotal_liquidacion, dInt_devengado, dIva_int_devengado, dLinea_disponible, dPagos_vdos, cDesc_status_cred, iId_bloqueo_cred, cBloqueo_cta, cId_causa_bloqueo_cred, cCausa_bloqueo_cta, cId_sit_esp_cte, iId_causa_esp_cte, cSit_esp_cte, cId_sit_esp_cred, iId_causa_esp_cred, cSit_esp_cred;
						
						LET dSdoActCap = dTotal_liquidacion;
						
						IF NVL(dSdoActCap,0) = 0 THEN
							LET cNumCredito = '';
							LET cStatus = '';
							LET dtFechaProxPago = DATE(1);
							LET dPagoMinimo = 0;
							LET dSdoActCap = 0;
							LET cProducto = '';								
							CONTINUE FOREACH;
						ELSE
							RETURN cCodRet,cCuenta,cNumCredito,cStatus, NVL(dtFechaProxPago,DATE(1)),NVL(dPagoMinimo,0),NVL(dSdoActCap,0),cProducto WITH RESUME;										
							LET cConsulto = '1';
						END IF;
					ELSE
						LET cCodRet = '000000';
					END IF;	
				END IF;				
			END FOREACH;
			
			IF cConsulto = '0' THEN
				RETURN cCodRet,cCuenta,cNumCredito,cStatus, NVL(dtFechaProxPago,DATE(1)),NVL(dPagoMinimo,0),NVL(dSdoActCap,0),cProducto WITH RESUME;						
			END IF;
            
			LET cConsulto = '0';
		END FOREACH;
        
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000003';
		END IF;
	END IF;
    
	IF cCodRet <> '000000' AND  cCodRet <> '000002' THEN
		RETURN cCodRet,cCuenta,cNumCredito,cStatus, NVL(dtFechaProxPago,DATE(1)),NVL(dPagoMinimo,0),NVL(dSdoActCap,0),cProducto;
	END IF;
    
    END;
    
END PROCEDURE
DOCUMENT
'Se realiza adaptaciÃ³n para obtener el Estatus de CrÃ©dito',
'Autor : 97879606 - AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'Fecha : 26/12/2017',
'Folio : 350',
'BD    : bdicheq',
---------------------------------------------------------------------------
'Se realiza procedimiento para obtener los saldos ',
'generales del crÃ©dito contemplando las cuentas transfer',
'AUTOR : 97877352-Rubio Lugo Jesus Alberto',
'FECHA : 01/12/2017',
'Folio : 350',
'BD    : bdicheq',
---------------------------------------------------------------------------
'Se realiza procedimiento para obtener los saldos ',
'generales del crÃ©dito',
'AUTOR : 97247642- Alexis Ibarra',
'FECHA : 14/03/2017',
'Folio : 180',
'BD    : bdicheq';

CREATE PROCEDURE "informix".sp_ctessincaptacion(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vdesccodret      CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfechahoy        DATE; 
    DEFINE vfecha_inicial   DATE;
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vmincred         CHAR(20);
    DEFINE vmaxcred         CHAR(20);
    DEFINE vfecha           CHAR(8);
    DEFINE vsql             CHAR(500);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vfecha_alta      DATE;
    DEFINE vapell_paterno   CHAR(26);
    DEFINE vapell_materno   CHAR(26);
    DEFINE vnombre          CHAR(52);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vtelefono1       CHAR(13);
    DEFINE vtelefono2       CHAR(13);
    DEFINE vtelefono3       CHAR(13);
    DEFINE vextension	    CHAR(5);
    
    LET vcodret1        = "000";
    LET vcodret2        = "000";
    LET vdesccodret     = " ";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vfechahoy       = "";
    LET vfecha_inicial  = "";
    LET vmincta         = '';
    LET vmaxcta         = '';
    LET vmincred        = '';
    LET vmaxcred        = '';
    LET vfecha          = '';
    LET vsql            = '';
    
    LET vnumcte         = "";
    LET vfecha_alta     = "";
    LET vapell_paterno  = "";
    LET vapell_materno  = "";
    LET vnombre         = "";
    LET vsexo           = "";
    LET vtelefono1      = "";
    LET vtelefono2      = "";
    LET vtelefono3      = "";
    LET vextension      = "";

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vdesccodret, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "/tmp/sp_ctessincaptacion.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene la fecha del dia de hoy
    SELECT fecha_hoy
      INTO vfechahoy
      FROM bdinteg:si_fechas
     WHERE empresa = pempresa;
     
    IF LPAD(DAY(vfechahoy), 2, '0') IN('01','02','03','04','05','06','07') THEN
    
        TRUNCATE TABLE bdicheq:sc_ctessincaptacion;
        
        SELECT MIN(num_credito), MAX(num_credito)
          INTO vmincred, vmaxcred
          FROM bdicred:sd_maecred;
        
        SELECT UNIQUE numcte
          FROM bdicred:sd_maecred a,
		       bdicred:sd_maesdos b
         WHERE a.empresa = pempresa
		   AND a.num_credito = b.num_credito
           AND a.num_credito BETWEEN vmincred AND vmaxcred
           AND a.num_credito NOT IN(SELECT credito_externo FROM bdicred:sd_maecredcrd)
           AND a.status_cred IN ('AA','E1')
		   AND (b.monto_vencido + b.mto_venc_trasp) = 0
          INTO TEMP tmp_ctes_cred WITH NO LOG;
        CREATE INDEX idx_ctescred ON tmp_ctes_cred(numcte) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_cred;
        
        SELECT MIN(cuenta), MAX(cuenta)
          INTO vmincta, vmaxcta
          FROM sc_maechq;
          
        SELECT UNIQUE num_cte
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND status_cta <> '2'
           AND producto <> '2000'
          INTO TEMP tmp_ctes_chq WITH NO LOG;
        CREATE INDEX idx_cteschq ON tmp_ctes_chq(num_cte) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_chq;
        
        SELECT numcte
          FROM tmp_ctes_cred
         WHERE numcte NOT IN(SELECT num_cte FROM tmp_ctes_chq)
          INTO TEMP tmp_ctessinchq WITH NO LOG;
        CREATE INDEX idx_ctessinchq ON tmp_ctessinchq(numcte) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctessinchq;
        
        FOREACH WITH HOLD
            SELECT ctes.numcte
              INTO vnumcte
              FROM bdinteg:si_cliente ctes,
                   tmp_ctessinchq tmp
             WHERE ctes.numcte = tmp.numcte 
               AND TRUNC((vfechahoy - ctes.fecha_alta) / 30) = 6
            
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
            
            -- // Obtiene los datos personales del cliente
            SELECT cte.fecha_alta, TRIM(cte.apell_paterno), TRIM(cte.apell_materno), TRIM(cte.nombre1)||' '||TRIM(cte.nombre2),
                   pf.sexo, tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension
              INTO vfecha_alta, vapell_paterno, vapell_materno, vnombre,vsexo, vtelefono1, vtelefono2, vtelefono3, vextension
              FROM bdinteg:si_cliente cte
              left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1)
			  left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
			  left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3)
			  LEFT OUTER JOIN bdinteg:si_ctepf pf ON (pf.numcte = cte.numcte)
             WHERE cte.numcte = vnumcte;
               
            -- // Inserta datos en tabla sc_ctessincaptacion
            INSERT INTO sc_ctessincaptacion 
            ( numcte, fecha_alta, apell_paterno, apell_materno, nombre, sexo, telefono1, telefono2, telefono3, extension ) 
            VALUES 
            ( vnumcte, vfecha_alta, vapell_paterno, vapell_materno, vnombre, vsexo, vtelefono1, vtelefono2, vtelefono3, vextension );
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 5000 THEN
                LET vcontador3 = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE sc_ctessincaptacion;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vnumcte         = "";
            LET vfecha_alta     = "";
            LET vapell_paterno  = "";
            LET vapell_materno  = "";
            LET vnombre         = "";
            LET vsexo           = "";
            LET vtelefono1      = "";
            LET vtelefono2      = "";
            LET vtelefono3      = "";
            LET vextension      = "";
            
        END FOREACH;
        
        IF ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
        
        LET vfecha = TO_CHAR(vfechahoy, '%d%m%Y');
        
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/ctessincaptacion_'||vfecha||'.txt'||
                   ' SELECT numcte, fecha_alta, apell_paterno, apell_materno, nombre, sexo, telefono1, telefono2, telefono3, extension'||
                   ' FROM sc_ctessincaptacion;" > /resplogifx/conciliachq/ctessinchq.sql';
        SYSTEM vsql;
        LET vsql = '';
        --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/ctessinchq.sql"; 
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctessinchq.sql"; 
        SYSTEM vsql;
        LET vsql = '';
        
        LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";
        
    ELSE
        
        LET vcodret1 = "908";
        
        SELECT descripcion
          INTO vdesccodret
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
          
        RETURN vcodret1, vcodret2, vdesccodret, vcontador1;
        
    END IF;

    RETURN vcodret1, vcodret2, vdesccodret, vcontador1;
    
    END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_notificar_depositos_portabilidad()
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet		CHAR(6);
DEFINE  cCodRetInt	CHAR(6);
DEFINE  iSqlErr		INTEGER;
DEFINE cNumcte 		CHAR(20);
DEFINE cNumcta 		CHAR(20);
DEFINE cIdPlantillaPush CHAR(11);
DEFINE cIdMsjPush 		CHAR(10);
--INICIALIZACION DE VARIABLES--
LET cNumcta		= '';
LET cNumcte 	= '';
LET cCodRet 		= '00000';
LET cCodRetInt 		= '00000';
LET iSqlErr			= 0;
LET cIdPlantillaPush = 'BEX_PPNSPEI';
LET cIdMsjPush = 'PNS_BEX';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = '11111';
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/Aastorga/portabilidad/sp_notificar_depositos_portabilidad.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --Se requiere un ciclo que recupere la informacion que se requiere para la notificacion
    FOREACH
		SELECT "XXXXXXX"||substring(solicitud.cta_receptora from 14 for 4), 
		solicitud.num_cte
		INTO cNumcta, cNumcte   
		FROM bdicheq:"informix".sc_movdia d 
		INNER JOIN bdicheq:"informix".sc_portacec_solicitud solicitud
			ON substring(solicitud.cta_receptora from 7 for 11) = TRIM(d.cuenta)
		WHERE solicitud.sucursal = "5011"
			AND d.transacc = "0273"
			AND d.fech_alt > DATE(TODAY - 1 UNITS DAY)
			AND d.referencia LIKE "%NNNN%"
			AND solicitud.clave_sentido = '2'
			AND solicitud.estatus_portabilidad = '1'
			

		--RASTREO DE INFO PARA ENVIO DE PUSH
		EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,cIdMsjPush, cIdPlantillaPush,cNumcte, cNumcta,'', '1', cNumcta, '', '', '', '', '', '', '', '', '', '', '', 0, 0, 0, 0, 0,current,current)
		INTO cCodRetInt;
		
		--RETURN cCodRet WITH RESUME;
	END FOREACH;
END;
RETURN cCodRet;
END PROCEDURE
DOCUMENT
'00000 - Exitoso',
'11111 - ocurrio un problema.',
'DESCRIPCION: Notifica la conclusion de su solicitud de portabilidad a los', 
' clientes que la solicitaron desde la app.',
'AUTOR : Arturo Astorga',
'Folio:Fabrica - Iniciativa Portabilidad de nomina',
'Solicita: Arturo Astorga',
'FECHA : 16/12/2021',

'MODIFICO :Arturo Astorga',
'DESCRIPCION:  Se modifica el componente para que envie notificaciones sms.',
'FECHA : 17/03/2022',

'MODIFICO :Arturo Astorga',
'DESCRIPCION:  Se modifica el componente para que maneje los parametros alternos de contacto.',
'FECHA : 08/04/2022',

'MODIFICO :Arturo Astorga',
'DESCRIPCION:  Se modifica el componente se quita el campo fech_hor  y agrega cIdMsjPush = PNS_BEX.',
'FECHA : 12/05/2022',

'MODIFICO :Arturo Astorga',
'DESCRIPCION:  Se modifica el componente se quitan notificaciones sms y email.',
'FECHA : 01/06/2022',
'BD: bdicheq';

CREATE PROCEDURE "informix".crea_maehis_especial(eEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pDias INTEGER)
RETURNING CHAR(5);
     
    DEFINE vgtrans_pag_int          CHAR(4);     
    DEFINE vgtransisr               CHAR(4);    
    DEFINE CodRet	                CHAR(5);
    DEFINE CodRet2                  CHAR(5);
    DEFINE CodRet3	                CHAR(50);
    DEFINE sql_err                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE desc_err                 CHAR(50);
    DEFINE vsdo_mes_ant             DECIMAL(14,2);
    DEFINE vtotdepositos            DECIMAL(14,2);
    DEFINE vtotretiros              DECIMAL(14,2);
    DEFINE vtotcomcobrada           DECIMAL(14,2);
    DEFINE vtotcombonif             DECIMAL(14,2);
    DEFINE vtotivacobrado           DECIMAL(14,2);
    DEFINE vtotivabonif             DECIMAL(14,2);
    DEFINE vtotintpag               DECIMAL(14,2);
    DEFINE vtotisrcobrado           DECIMAL(14,2);
    DEFINE vcuenta_clabe            CHAR(20);
    DEFINE vsucursal                CHAR(4);
    DEFINE vproducto                CHAR(4);
    DEFINE vnum_cte	                CHAR(20);
    DEFINE vstatus_cta              CHAR(1);
    DEFINE vmotivo                  CHAR(2);
    DEFINE vfec_cancelac            DATE;
    DEFINE vsdo_retenido            DECIMAL(16,2);
    DEFINE vsdo_cong                DECIMAL(16,2);
    DEFINE vsdo_actual              DECIMAL(16,2);
    DEFINE venvio_direcc            CHAR(1);
    DEFINE vdirecc_envio            SMALLINT;
    DEFINE vacum_sdo_pos            DECIMAL(18,2);
    DEFINE vdia_sdo_pos             SMALLINT;
    DEFINE vacum_sdo_int            DECIMAL(18,2);
    DEFINE vdias_acum_int           SMALLINT;
    DEFINE vret_mes_ant             DECIMAL(16,2);
    DEFINE vcong_mes_ant            DECIMAL(16,2);
    DEFINE vlim_sbg_ccc             DECIMAL(16,2);
    DEFINE vimp_sbg_ccc             DECIMAL(16,2);
    DEFINE vimp_chq_sbg             DECIMAL(16,2);
    DEFINE vsaldo_sbc               DECIMAL(16,2);
    DEFINE vint_acum                DECIMAL(18,2);
    DEFINE visr_acum                DECIMAL(18,2);
    DEFINE vfechafin                DATE;
    DEFINE vfechaini                DATE;
    DEFINE vmonto_tot               DECIMAL(16,2);
    DEFINE vtransacc                CHAR(4);
    DEFINE vnaturaleza              CHAR(1);
    DEFINE vtipo_tran               CHAR(2);
    DEFINE vfechainimovhis          CHAR(10);
    DEFINE vfechainimovhisold       CHAR(10);
    DEFINE vtran_efec               CHAR(4);
    DEFINE vtotretirosefec          DECIMAL(18,2);
    DEFINE vtototroscargos          DECIMAL(18,2);
    DEFINE vtrandepotrobco          CHAR(4);
    DEFINE vtrandevotrobco          CHAR(4);
	DEFINE vtasaiva                 DECIMAL(6,3);
	DEFINE vmonto                   DECIMAL(16,2);
	DEFINE eDiaSdoPos               INTEGER;
	DEFINE vsql                     CHAR(500);
	DEFINE eCuenta                  CHAR (20);
	DEFINE v_c_vcomienza            SMALLINT;
	DEFINE ven_transacc             SMALLINT;
	DEFINE v_c_vcontador            INTEGER; 
	
    LET   vgtrans_pag_int           = '3276';     
    LET   vgtransisr                = '3277';
	LET   vsql                      = '';
	LET   v_c_vcomienza             = -1;
	LET   ven_transacc              = 0 ;
	LET   v_c_vcontador             = 0 ;
	
	BEGIN
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/tmp/crea_maehis_especial.err";
        TRACE ON;
        LET CodRet = sql_err;
        LET CodRet2 = isam_err;
        LET CodRet3 = desc_err;
		IF ven_transacc = 1 THEN 
		   ROLLBACK WORK;
        END IF;
        RETURN CodRet;
    END EXCEPTION;
	
    --- SET DEBUG FILE TO "/RESPALDOSNEW/rsv/cdfi/crea_maehis_especial.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    LET CodRet     = '000';
    LET vtran_efec = '';
    LET vfechaini  = pFechaIni;
    LET vfechafin  = pFechaFin;
    LET eDiaSdoPos = pDias;

    -- // CALCULA EL INICIO DEL PERIODO
    SELECT valor 
      INTO vtasaiva
      FROM bdinteg:si_param
     WHERE empresa = Eempresa and cod_param = 47;
      
    CREATE TABLE ctasxprocc( cuenta char(20) );
	CREATE INDEX idx_ctasxprocc ON ctasxprocc(cuenta) ONLINE; 
	UPDATE STATISTICS MEDIUM FOR TABLE ctasxprocc;
	
	LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_sc_maehis.txt INSERT INTO ctasxprocc" > /resplogifx/conciliachq/ctas_maehis.sql';
    SYSTEM vsql;
    LET vsql = '';
       
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctas_maehis.sql'; 
    SYSTEM vsql;
    LET vsql = '';

	FOREACH WITH HOLD
	        SELECT cuenta  
	          INTO eCuenta
	          FROM ctasxprocc
			
		    IF (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;
	        
            -- // OBTIENE INFORMACIÃN GENERAL DE LA CUENTA
            SELECT mc.cuenta_clabe, mc.sucursal, mc.producto, mc.num_cte,
                   mc.status_cta, mc.motivo, mc.fec_cancelac, mc.sdo_retenido, mc.sdo_cong,
                   mc.sdo_actual, mn.envio_direcc, mc.direcc_envio, mn.sdo_mes_ant,
                   mn.acum_sdo_pos, mn.dia_sdo_pos, mn.acum_sdo_int, mn.dias_acum_int,
                   mn.ret_mes_ant, mn.cong_mes_ant, mc.lim_sbg_ccc, mc.imp_sbg_ccc,
                   mc.imp_chq_sbg, mc.saldo_sbc, mn.int_acum, mn.isr_acum
              INTO vcuenta_clabe, vsucursal, vproducto, vnum_cte,
                   vstatus_cta, vmotivo, vfec_cancelac, vsdo_retenido, vsdo_cong,
                   vsdo_actual, venvio_direcc, vdirecc_envio, vsdo_mes_ant,
                   vacum_sdo_pos, vdia_sdo_pos, vacum_sdo_int, vdias_acum_int,
                   vret_mes_ant, vcong_mes_ant, vlim_sbg_ccc, vimp_sbg_ccc,
                   vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum
              FROM sc_maechq mc,
                   sc_maenoc mn,
                   sc_producto pr
             WHERE mc.empresa = eEmpresa
               AND mc.cuenta = eCuenta
               AND mn.empresa = mc.empresa
               AND mn.cuenta = mc.cuenta
               AND pr.empresa = mn.empresa
               AND pr.producto = mc.producto;
            
            -- // INICIALIZA VARIABLES DE SALDOS
            LET vtotdepositos   = 0;
            LET vtotretiros     = 0;
            LET vtotintpag      = 0;
            LET vtotcomcobrada  = 0;
            LET vtotcombonif    = 0;
            LET vtotivacobrado  = 0;
            LET vtotivabonif    = 0;
            LET vtotisrcobrado  = 0;
            LET vtotretirosefec = 0;
            LET vtototroscargos = 0;
	        LET vmonto          = 0;
    
            -- // OBTIENE FECHAS DE CONSULTAS EN HISTORICOS
            SELECT valor
              INTO vfechainimovhis
              FROM sc_param
             WHERE empresa = eEmpresa
               AND codparam = 'fechcon_movhis';
               
            SELECT valor
              INTO vfechainimovhisold
              FROM sc_param
             WHERE empresa = eEmpresa
               AND codparam = 'FechIniCon_movhis_ol';
               
            SELECT valor
              INTO vtrandepotrobco
              FROM sc_param
             WHERE empresa = eEmpresa
               AND codparam = 'trandepobco';
               
            SELECT valor
              INTO vtrandevotrobco
              FROM sc_param
             WHERE empresa = eEmpresa
               AND codparam = 'trandevobco';
            
            -- // OBTIENE CARGOS Y ABONOS DEL HISTORICO
            FOREACH           
                SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
                  INTO vmonto_tot, vtransacc, vnaturaleza, vtipo_tran, vtran_efec
                  FROM sc_movhis mv
                 INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S' AND tr.sistema = '01')
                  LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
                 WHERE mv.empresa = eEmpresa
                   AND mv.cuenta = eCuenta
                   AND mv.fech_alt BETWEEN vfechaini AND vfechafin
                   AND mv.fech_alt >= vfechainimovhis
                   AND mv.cancelad <> 'S'
                   AND mv.transacc = tr.numero
                UNION ALL
                SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
                  FROM sc_movhis_old mv
                 INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S' AND tr.sistema = '01')
                  LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
                 WHERE mv.empresa = eEmpresa
                   AND mv.cuenta = eCuenta
                   AND mv.fech_alt BETWEEN vfechaini AND vfechafin
                   AND mv.fech_alt >= vfechainimovhisold
                   AND mv.fech_alt < vfechainimovhis
                   AND mv.cancelad <> 'S'
                   AND mv.transacc = tr.numero
                   
                -- // ABONOS
                IF vnaturaleza = 'A' THEN 
                    IF (vtransacc <> vgtrans_pag_int AND vtransacc <> vtrandepotrobco) THEN -- TOTAL DEPOSITOS
                        LET vtotdepositos = vtotdepositos + vmonto_tot;
                    END IF;
            
                    IF vtipo_tran in('01','05','09') THEN -- TOTAL COMISIONES BONIFICADAS
                        LET vtotcombonif = vtotcombonif + vmonto_tot;
                    END IF;
            
                    IF vtipo_tran in('02','04','06','08') THEN -- TOTAL IVA BONIFICADO
                        LET vtotivabonif = vtotivabonif + vmonto_tot;
                    END IF;
                -- // CARGOS
                ELIF vnaturaleza = 'C' THEN 
                    IF (vtipo_tran IN('00','30') AND vtransacc <> vgtransisr AND vtransacc <> vtrandevotrobco) THEN -- TOTAL RETIROS
                        LET vtotretiros = vtotretiros + vmonto_tot;
                        LET vtototroscargos = vtototroscargos + vmonto_tot;
                    END IF;
                    
                    IF vtran_efec = vtransacc THEN
                        LET vtotretirosefec = vtotretirosefec + vmonto_tot;
                    END IF;
            
                    IF vtipo_tran in('01','31') THEN -- TOTAL COMISIONES COBRADAS
	        		    IF vtransacc in('0890', '0892', '0893', '0895') THEN
	        			   LET vmonto = vmonto_tot / (1 + vtasaiva);
	        			   LET vtotcomcobrada = vtotcomcobrada + vmonto;
	        			   LET vtotivacobrado = vtotivacobrado + (vmonto_tot - vmonto);
	        			ELSE   
	        			   LET vtotcomcobrada = vtotcomcobrada + vmonto_tot;
	        			END IF;   
                    END IF;
            
                    IF vtipo_tran in('02','32') THEN -- TOTAL IVA COBRADO
                        LET vtotivacobrado = vtotivacobrado + vmonto_tot;
                    END IF;
                END IF;
                 
                IF vtransacc = vgtrans_pag_int THEN -- TOTAL PAGO DE INTERESES
                    LET vtotintpag = vtotintpag + vmonto_tot;
                END IF;
            
                IF vtransacc = vgtransisr THEN -- TOTAL ISR COBRADO
                    LET vtotisrcobrado = vtotisrcobrado + vmonto_tot;
                END IF;
            END FOREACH;
            
            IF vtotdepositos IS NULL THEN -- DEPOSITOS
                LET vtotdepositos = 0;
            END IF;
            
            IF vtotretiros is null OR vtotretiros < 0 THEN -- RETIROS
                LET vtotretiros = 0;
            END IF;
            
            IF vtotcomcobrada IS NULL THEN -- COMISIONES COBRADAS
                LET vtotcomcobrada = 0;
            END IF;
            
            IF vtotcombonif IS NULL THEN -- COMISIONES BONIFICADAS
                LET vtotcombonif = 0;
            END IF;
            
            LET vtotcomcobrada = vtotcomcobrada - vtotcombonif; -- COMISION TOTAL
            
            IF vtotivacobrado IS NULL THEN -- IVA COBRADO
                LET vtotivacobrado = 0;
            END IF;
            
            IF vtotivabonif IS NULL THEN -- IVA BONIFICADO
                LET vtotivabonif = 0;
            END IF;
            
            LET vtotivacobrado = vtotivacobrado - vtotivabonif;  -- IVA TOTAL
            
            IF vtotintpag IS NULL THEN -- INTERESES
                LET vtotintpag = 0;
            END IF;
            
            IF vtotisrcobrado IS NULL THEN -- ISR
                LET vtotisrcobrado = 0;
            END IF;
            
            IF vtotretirosefec IS NULL THEN
                LET vtotretirosefec = 0;
            END IF;
            
            LET vtototroscargos = vtototroscargos - vtotretirosefec;
            
            IF vtototroscargos is null OR vtototroscargos < 0 THEN
                LET vtototroscargos = 0;
            END IF;

            /* #########################################################################################################################
                -- // INSERTA REGISTRO HISTORICO
                INSERT INTO sc_maehis VALUES
                (eEmpresa, vaniomes, eCuenta, vfechaini, vfechafin, vcuenta_clabe, vgnum_tarjeta, vsucursal, vproducto, 
                 vnum_cte, vstatus_cta, vmotivo, vfec_cancelac, vsdo_retenido, vsdo_cong, vsdo_actual, venvio_direcc, vdirecc_envio,
                 vsdo_mes_ant, eAcumSdoPos, eDiaSdoPos, vacum_sdo_int, vdias_acum_int, vtasa_bruta, vret_mes_ant, vcong_mes_ant,
                 vlim_sbg_ccc, vimp_sbg_ccc, vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum, vtotdepositos, vtotretiros, vtotintpag,
                 vtotcomcobrada, vtotivacobrado, vtotisrcobrado, vtotretirosefec, vtototroscargos, vgat, vgat_real);
            ######################################################################################################################### */

            UPDATE sc_maehis
	           SET fechaini     = vfechaini,
	               dia_sdo_pos  = eDiaSdoPos,
	               totdepositos = vtotdepositos,
	        	   totretiros   = vtotretiros,
	        	   totintpag    = vtotintpag,
	        	   totcomcobrada  = vtotcomcobrada,
	        	   totivacobrado  = vtotivacobrado,
	        	   totisrcobrado  = vtotisrcobrado,
	        	   totretirosefec = vtotretirosefec,
	        	   tototroscargos = vtototroscargos
	         WHERE cuenta  = eCuenta
			   AND fechafin = pFechaFin;
            
			UPDATE sc_maehis_factelect
			   SET fechaini     = vfechaini,
			       totretiros   = vtotretiros,
				   totdepositos = vtotdepositos
			 WHERE cuenta  = eCuenta
	           AND fechafin = pFechaFin; 		
			
			LET v_c_vcontador = v_c_vcontador + 1;
            
			IF (v_c_vcontador >= 1000) THEN
                LET v_c_vcontador = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF; 	
	END FOREACH;
	
	IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	 

	DROP TABLE ctasxprocc; 
	
    RETURN CodRet;
    
    END;
    
END PROCEDURE;
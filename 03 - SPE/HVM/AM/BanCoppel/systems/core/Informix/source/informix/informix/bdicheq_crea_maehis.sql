CREATE PROCEDURE "informix".crea_maehis(eEmpresa    CHAR(3),
                                        eCuenta     CHAR(20),
                                        eFechaPago  DATE,
                                        eFechaAlta  DATE,
                                        eAcumSdoPos DECIMAL(14,2),
                                        eDiaSdoPos  DECIMAL(14,2))
RETURNING CHAR(5);
    
    -- ***************************************************************
    -- crea_maehis
    -- Version              1.0.0
    -- Obejtivo:            Crea registro de saldos al fin de mes
    --                      y que permiten generar estados de cuenta..
    -- ***************************************************************

    DEFINE GLOBAL vgtrans_pag_int   CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgtransisr        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgnum_tarjeta     CHAR(20)    DEFAULT " ";
    
    DEFINE CodRet	                CHAR(5);
    DEFINE CodRet2                  CHAR(5);
    DEFINE CodRet3	                CHAR(50);
    DEFINE CodRetObtenerGat         CHAR(5);
    DEFINE sql_err                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE desc_err                 CHAR(50);
    DEFINE vsdo_mes_ant             DECIMAL(14,2);
    DEFINE vcuantos                 SMALLINT;
    DEFINE vtotdepositos            DECIMAL(14,2);
    DEFINE vtotretiros              DECIMAL(14,2);
    DEFINE vtotcomcobrada           DECIMAL(14,2);
    DEFINE vtotcombonif             DECIMAL(14,2);
    DEFINE vtotivacobrado           DECIMAL(14,2);
    DEFINE vtotivabonif             DECIMAL(14,2);
    DEFINE vtotintpag               DECIMAL(14,2);
    DEFINE vtotisrcobrado           DECIMAL(14,2);
    DEFINE vmesfecha                SMALLINT;
    DEFINE vdia                     CHAR(2);
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
    DEFINE vmaxsecuencia            SMALLINT;
    DEFINE vnum_tarjeta             CHAR(20);
    DEFINE vfechafin                DATE;
    DEFINE vfechaini                DATE;
    DEFINE vaniomes                 CHAR(6);
    DEFINE vtasa_bruta              DECIMAL(9,6);
    DEFINE vmonto_tot               DECIMAL(16,2);
    DEFINE vtransacc                CHAR(4);
    DEFINE vnaturaleza              CHAR(1);
    DEFINE vtipo_tran               CHAR(2);
    DEFINE vfechainimovhis          CHAR(10);
    DEFINE vfechainimovhisold       CHAR(10);
    DEFINE vultfechafin             DATE;
    DEFINE vdifdias                 INTEGER;
    DEFINE vtran_efec               CHAR(4);
    DEFINE vtotretirosefec          DECIMAL(18,2);
    DEFINE vtototroscargos          DECIMAL(18,2);
    DEFINE vgat                     DECIMAL(9,6);
    DEFINE vtrandepotrobco          CHAR(4);
    DEFINE vtrandevotrobco          CHAR(4);
    DEFINE vtasa_gat                DECIMAL(9,6);
    DEFINE vgat_real                DECIMAL(9,6);
	DEFINE vtasaiva                 DECIMAL(6,3);
	DEFINE vmonto                   DECIMAL(16,2);

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/crea_maehis.err";
        TRACE ON;
        LET CodRet = sql_err;
        LET CodRet2 = isam_err;
        LET CodRet3 = desc_err;
        RETURN CodRet;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/crea_maehis.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    LET CodRet     = '000';
    LET CodRetObtenerGat = '';
    LET vmesfecha  = 0;
    LET vtran_efec = '';
    LET vfechafin  = eFechaPago;
    LET vdia       = DAY(eFechaAlta);

    -- // CALCULA EL INICIO DEL PERIODO
    CALL sp_mes_siguiente(eFechaPago, -1, vdia)
    RETURNING CodRet, vfechaini, eDiaSdoPos;

    IF vdia = '01' OR vdia = '1' THEN
        LET vfechaini = vfechaini + 1 UNITS MONTH;
    END IF;
    
    IF vdia = '31' AND (lpad(month(vfechaini), 2, '0') = '02' OR 
                        lpad(month(vfechaini), 2, '0') = '04' OR
                        lpad(month(vfechaini), 2, '0') = '06' OR 
                        lpad(month(vfechaini), 2, '0') = '09' OR
                        lpad(month(vfechaini), 2, '0') = '11') THEN
        LET vfechaini = vfechaini + 1 UNITS DAY;
    END IF;
	
    SELECT valor 
      INTO vtasaiva
      FROM bdinteg:si_param
     WHERE empresa = Eempresa 
       AND cod_param = 47;
    
    SELECT fechafin
      INTO vultfechafin
      FROM sc_maehis
     WHERE empresa = Eempresa
       AND cuenta = eCuenta
       AND aniomes = ( SELECT MAX(aniomes)
                         FROM sc_maehis
                        WHERE empresa = Eempresa
                          AND cuenta = eCuenta);
                          
    IF vultfechafin is null THEN
        LET vultfechafin = '01/01/2007';
    END IF;
                          
    IF vultfechafin = vfechaini THEN
        LET vfechaini = vfechaini + 1 UNITS DAY;
    END IF;
    
    LET eDiaSdoPos = (vfechafin - vfechaini) + 1;

    SELECT CASE WHEN SUBSTR( MAX( aniomes ) + 1, 5 ) > 12 THEN
               ( SELECT SUBSTR( SUBSTR( MAX(aniomes), 1, 4 ) + 1, 1, 4 ) || '01'
                   FROM sc_maehis
                  WHERE empresa = Eempresa
                    AND cuenta = eCuenta )
           ELSE
               ( SELECT SUBSTR( MAX(aniomes) + 1, 1, 6 )
                  FROM sc_maehis
                 WHERE empresa = Eempresa
                   AND cuenta = eCuenta )
           END
      INTO vaniomes
      FROM sc_maehis
     WHERE empresa = Eempresa
       AND cuenta = eCuenta;

    IF vaniomes is null or vaniomes = '' THEN
        LET vaniomes = YEAR(eFechaAlta)||LPAD(MONTH(eFechaAlta  ),2,'0');
    END IF;

    -- // OBTIENE INFORMACIï¿½N GENERAL DE LA CUENTA
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
    LET vgat            = 0;
    LET vgat_real       = 0;
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
        SELECT --- {+INDEX(sc_movhis idx_movhisnew4)}
               mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
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
        SELECT --- {+INDEX(sc_movhis_old movhis1)}
               mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
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

    -- // OBTIENE CARGOS Y ABONOS DEL DIA
    FOREACH
        SELECT md.monto_tot, md.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
          INTO vmonto_tot, vtransacc, vnaturaleza, vtipo_tran, vtran_efec
          FROM sc_movdia md
         INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = md.empresa AND tr.numero = md.transacc AND tr.se_emite_edocta = 'S' AND tr.sistema = '01')
          LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = md.transacc)
         WHERE md.empresa = eEmpresa
           AND md.cuenta = eCuenta
           AND md.fech_alt BETWEEN vfechaini AND vfechafin
           AND md.cancelad <> 'S'
        
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
            IF (vtipo_tran in('00','30') AND vtransacc <> vgtransisr AND vtransacc <> vtrandevotrobco) THEN -- TOTAL RETIROS
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

    -- // OBTIENE LA TASA
    LET vtasa_bruta = 0;
    LET vcuantos = 0;

    SELECT NVL(SUM(md.tasa_aplicada), 0), COUNT(*)
      INTO vtasa_bruta, vcuantos
      FROM sc_movdia md
     WHERE md.empresa = eEmpresa
       AND md.cuenta = eCuenta
       AND md.cancelad <> 'S'
       AND md.transacc = vgtrans_pag_int;

    IF vcuantos > 0 THEN
        LET vtasa_bruta = vtasa_bruta / vcuantos;
    END IF;
    
    IF vtasa_bruta is null OR vtasa_bruta = '' THEN
        LET vtasa_bruta = 0;
    END IF;
    
    -- // EXTRAE SALDO DEL MES ANTERIOR
    SELECT sdo_actual
      INTO vsdo_mes_ant
      FROM sc_maehis
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta
       AND aniomes = (SELECT MAX(aniomes)
                        FROM sc_maehis
                       WHERE empresa = eEmpresa
                         AND cuenta = eCuenta);

    IF vsdo_mes_ant is null THEN
        LET vsdo_mes_ant = 0;
    END IF;
    
    LET vdifdias = vfechaini - vultfechafin;
    
    IF vdifdias > 31 THEN
        LET vaniomes = YEAR(vfechaini)||LPAD(MONTH(vfechaini),2,'0');
        LET vsdo_mes_ant = vsdo_actual - vtotdepositos + vtotretiros + vtotcomcobrada + vtotivacobrado - vtotintpag + vtotisrcobrado;
    END IF;      
        
    EXECUTE PROCEDURE sp_obtener_gat(vproducto, eCuenta, vfechafin, eEmpresa)
                    INTO CodRetObtenerGat, vgat, vgat_real;

    -- // INSERTA REGISTRO HISTORICO
    INSERT INTO sc_maehis VALUES
    (eEmpresa, vaniomes, eCuenta, vfechaini, vfechafin, vcuenta_clabe, vgnum_tarjeta, vsucursal, vproducto, 
     vnum_cte, vstatus_cta, vmotivo, vfec_cancelac, vsdo_retenido, vsdo_cong, vsdo_actual, venvio_direcc, vdirecc_envio,
     vsdo_mes_ant, eAcumSdoPos, eDiaSdoPos, vacum_sdo_int, vdias_acum_int, vtasa_bruta, vret_mes_ant, vcong_mes_ant,
     vlim_sbg_ccc, vimp_sbg_ccc, vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum, vtotdepositos, vtotretiros, vtotintpag,
     vtotcomcobrada, vtotivacobrado, vtotisrcobrado, vtotretirosefec, vtototroscargos, vgat, vgat_real);

    SET LOCK MODE TO WAIT 2;
    
    -- // LIMPIA TARJETA EN EL MESANIVERSARIO
    UPDATE sc_tarjeta
       SET disp_mes = 0
     WHERE numcte = vnum_cte
       AND cuenta = eCuenta
       AND num_tarjeta = vgnum_tarjeta;

    -- // LIMPIA CARGOS Y ABONOS EN EL MAESTRO DE CHEQUES
    UPDATE sc_maechq
       SET num_cgos_mes = 0,
           imp_cgos_mes = 0,
           num_abonos_mes = 0,
           imp_abonos_mes = 0
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    RETURN CodRet;
    
END PROCEDURE

DOCUMENT

'DESCRIPCION: Programa que se encarga de crear los datos para la tabla',
'             sc_maehis esta tabla contiene los saldos de la cuenta',
'             al momento del corte',
'LLAMADO POR: SPL calcula_int y creciente_diario',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".crea_maehisqra( eEmpresa    CHAR(3),
                                            eCuenta     CHAR(20),
                                            eFechaPago  DATE,
                                            eFechaAlta  DATE,
                                            eAcumSdoPos DECIMAL(14,2),
                                            eDiaSdoPos  DECIMAL(14,2) )

RETURNING CHAR(5);
    
    --//VARIABLES GLOBALES
    DEFINE GLOBAL vgratrans_pag_int   CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgratransisr        CHAR(4)     DEFAULT " ";
    DEFINE GLOBAL vgranum_tarjeta     CHAR(20)    DEFAULT " ";
    
    DEFINE CodRet	                CHAR(5);
    DEFINE CodRet2                  CHAR(5);
    DEFINE CodRet3	                CHAR(50);
    DEFINE CodRetObtenerGat        CHAR(5);
    DEFINE sql_err                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE desc_err                 CHAR(50);
    DEFINE vsdo_mes_ant             DECIMAL(14,2);
    DEFINE vcuantos                 SMALLINT;
    DEFINE vtotdepositos            DECIMAL(14,2);
    DEFINE vtotretiros              DECIMAL(14,2);
    DEFINE vtotcomcobrada           DECIMAL(14,2);
    DEFINE vtotcombonif             DECIMAL(14,2);
    DEFINE vtotivacobrado           DECIMAL(14,2);
    DEFINE vtotivabonif             DECIMAL(14,2);
    DEFINE vtotintpag               DECIMAL(14,2);
    DEFINE vtotisrcobrado           DECIMAL(14,2);
    DEFINE vmesfecha                SMALLINT;
    DEFINE vdia                     CHAR(2);
    DEFINE vcuenta_clabe            CHAR(20);
    DEFINE vsucursal                CHAR(4);
    DEFINE vproducto                CHAR(4);
    DEFINE vnum_cte	                CHAR(20);
    DEFINE vstatus_cta              CHAR(1);
    DEFINE vmotivo                  CHAR(2);
    DEFINE vfec_cancelac            DATE;
    DEFINE vsdo_retenido            DECIMAL(14,2);
    DEFINE vsdo_cong                DECIMAL(14,2);
    DEFINE vsdo_actual              DECIMAL(14,2);
    DEFINE venvio_direcc            CHAR(1);
    DEFINE vdirecc_envio            SMALLINT;
    DEFINE vacum_sdo_pos            DECIMAL(14,2);
    DEFINE vdia_sdo_pos             SMALLINT;
    DEFINE vacum_sdo_int            DECIMAL(14,2);
    DEFINE vdias_acum_int           SMALLINT;
    DEFINE vret_mes_ant             DECIMAL(14,2);
    DEFINE vcong_mes_ant            DECIMAL(14,2);
    DEFINE vlim_sbg_ccc             DECIMAL(14,2);
    DEFINE vimp_sbg_ccc             DECIMAL(14,2);
    DEFINE vimp_chq_sbg             DECIMAL(14,2);
    DEFINE vsaldo_sbc               DECIMAL(14,2);
    DEFINE vint_acum                DECIMAL(14,2);
    DEFINE visr_acum                DECIMAL(14,2);
    DEFINE vmaxsecuencia            SMALLINT;
    DEFINE vnum_tarjeta             CHAR(20);
    DEFINE vfechafin                DATE;
    DEFINE vfechaini                DATE;
    DEFINE vaniomes                 CHAR(6);
    DEFINE vtasa_bruta              DECIMAL(9,6);
    DEFINE vmonto_tot               DECIMAL(14,2);
    DEFINE vtransacc                CHAR(4);
    DEFINE vnaturaleza              CHAR(1);
    DEFINE vtipo_tran               CHAR(2);
    DEFINE vfechainimovhis          CHAR(10);
    DEFINE vfechainimovhisold       CHAR(10);
    DEFINE vultfechafin             DATE;
    DEFINE vdifdias                 INTEGER;
    DEFINE vtran_efec               CHAR(4);
    DEFINE vtotretirosefec          DECIMAL(18,2);
    DEFINE vtototroscargos          DECIMAL(18,2);
    DEFINE vgat                     DECIMAL(9,6);
    DEFINE vgat_real                DECIMAL(9,6);
    DEFINE vtasaiva                 DECIMAL(6,3);
	DEFINE vmonto                   DECIMAL(16,2);
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/tmp/crea_maehisqra.err";
        TRACE ON;
        LET CodRet = sql_err;
        LET CodRet2 = isam_err;
        LET CodRet3 = desc_err;
        RETURN CodRet;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/crea_maehisqra.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    LET CodRet     = '000';
    LET CodRetObtenerGat = '';
    LET vmesfecha  = 0;
    LET vtran_efec = '';
    LET vfechafin  = eFechaPago;
    LET vdia       = DAY(eFechaAlta);

    -- // CALCULA EL INICIO DEL PERIODO
    CALL sp_mes_siguiente(eFechaPago, -1, vdia)
    RETURNING CodRet, vfechaini, eDiaSdoPos;

    /* #######################################
    IF eDiaSdoPos < 0 THEN
        LET eDiaSdoPos = eDiaSdoPos * -1;
        LET eDiaSdoPos = eDiaSdoPos + 1;
    END IF;
    ####################################### */

    IF vdia = '01' OR vdia = '1'THEN
        LET vfechaini = vfechaini + 1 UNITS MONTH;
    END IF;
    
    IF vdia = '31' AND (lpad(month(vfechaini), 2, '0') = '02' OR 
                        lpad(month(vfechaini), 2, '0') = '04' OR
                        lpad(month(vfechaini), 2, '0') = '06' OR 
                        lpad(month(vfechaini), 2, '0') = '09' OR
                        lpad(month(vfechaini), 2, '0') = '11') THEN
        LET vfechaini = vfechaini + 1 UNITS DAY;
    END IF;
	
	 SELECT valor into vtasaiva
      FROM bdinteg:si_param
     WHERE empresa = Eempresa and cod_param = 47;

    
    LET eDiaSdoPos = (vfechafin - vfechaini) + 1;

    SELECT CASE WHEN SUBSTR(MAX(aniomes) + 1,  5) > 12 THEN
               (SELECT SUBSTR(SUBSTR(MAX(aniomes),1,4)+1,1,4) || '01'
                  FROM sc_maehis
                 WHERE empresa = Eempresa
                   AND cuenta = eCuenta)
           ELSE
               (SELECT SUBSTR(MAX(aniomes) + 1,1,6)
                  FROM sc_maehis
                 WHERE empresa = Eempresa
                   AND cuenta = eCuenta)
           END
      INTO vaniomes
      FROM sc_maehis
     WHERE empresa = Eempresa
       AND cuenta = eCuenta;

    IF vaniomes is null or vaniomes = '' THEN
        LET vaniomes = YEAR(eFechaAlta  ) || LPAD(MONTH(eFechaAlta  ), 2, '0');
    END IF;

    -- // OBTIENE INFORMACIÃN GENERAL DE LA CUENTA
    SELECT cuenta_clabe, sucursal, mc.producto, mc.num_cte,
           status_cta, motivo, fec_cancelac, sdo_retenido, sdo_cong,
           sdo_actual, envio_direcc, direcc_envio, sdo_mes_ant,
           acum_sdo_pos, dia_sdo_pos, acum_sdo_int, dias_acum_int,
           ret_mes_ant, cong_mes_ant, lim_sbg_ccc, imp_sbg_ccc,
           imp_chq_sbg, saldo_sbc, int_acum, isr_acum
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
    LET vgat            = 0;
    LET vgat_real       = 0;
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
            IF vtransacc <> vgratrans_pag_int THEN -- TOTAL DEPOSITOS
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
            IF vtipo_tran in('00','30') THEN -- TOTAL RETIROS
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

        IF vtransacc = vgratrans_pag_int THEN -- TOTAL PAGO DE INTERESES
            LET vtotintpag = vtotintpag + vmonto_tot;
        END IF;

        IF vtransacc = vgratransisr THEN -- TOTAL ISR COBRADO
            LET vtotisrcobrado = vtotisrcobrado + vmonto_tot;
        END IF;
    END FOREACH;

    -- // OBTIENE CARGOS Y ABONOS DEL DIA
    FOREACH
        SELECT md.monto_tot, md.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
          INTO vmonto_tot, vtransacc, vnaturaleza, vtipo_tran, vtran_efec
          FROM sc_movdia md
         INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = md.empresa AND tr.numero = md.transacc AND tr.se_emite_edocta = 'S' AND tr.sistema = '01')
          LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = md.transacc)
         WHERE md.empresa = eEmpresa
           AND md.cuenta = eCuenta
           AND md.fech_alt BETWEEN vfechaini AND vfechafin
           AND md.cancelad <> 'S'
        
        -- // ABONOS
        IF vnaturaleza = 'A' THEN 
            IF vtransacc <> vgratrans_pag_int THEN -- TOTAL DEPOSITOS
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
            IF vtipo_tran in('00','30') THEN -- TOTAL RETIROS
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

        IF vtransacc = vgratrans_pag_int THEN -- TOTAL PAGO DE INTERESES
            LET vtotintpag = vtotintpag + vmonto_tot;
        END IF;

        IF vtransacc = vgratransisr THEN -- TOTAL ISR COBRADO
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

    LET vtotcomcobrada = vtotcomcobrada - vtotcombonif;

    IF vtotivacobrado IS NULL THEN -- IVA COBRADO
        LET vtotivacobrado = 0;
    END IF;

    IF vtotivabonif IS NULL THEN -- IVA BONIFICADO
        LET vtotivabonif = 0;
    END IF;

    LET vtotivacobrado = vtotivacobrado - vtotivabonif;

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

    -- // OBTIENE LA TASA
    LET vtasa_bruta = 0;
    LET vcuantos = 0;

    SELECT NVL(SUM(md.tasa_aplicada),0), COUNT(*)
      INTO vtasa_bruta, vcuantos
      FROM sc_movdia md
     WHERE md.empresa = eEmpresa
       AND md.cuenta = eCuenta
       AND md.cancelad <> 'S'
       AND md.transacc = vgratrans_pag_int;

    IF vcuantos > 0 THEN
        LET vtasa_bruta = vtasa_bruta / vcuantos;
    END IF;
    
    IF vtasa_bruta is null OR vtasa_bruta = '' THEN
        LET vtasa_bruta = 0;
    END IF;
    
    -- // EXTRAE SALDO DEL MES ANTERIOR
    SELECT sdo_actual, NVL(fechafin, '01/01/2008')
      INTO vsdo_mes_ant, vultfechafin
      FROM sc_maehis
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta
       AND aniomes = (SELECT MAX(aniomes)
                        FROM sc_maehis
                       WHERE empresa = eEmpresa
                         AND cuenta = eCuenta);

    IF vsdo_mes_ant is null OR vsdo_mes_ant = '' THEN
        LET vsdo_mes_ant = 0;
    END IF;
    
    LET vdifdias = vfechaini - vultfechafin;
    
    IF vdifdias > 31 THEN
        LET vaniomes = YEAR(vfechaini)||LPAD(MONTH(vfechaini),2,'0');
    END IF;     
        
    EXECUTE PROCEDURE sp_obtener_gat(vproducto, eCuenta, vfechafin, eEmpresa)
                    INTO CodRetObtenerGat, vgat, vgat_real;

    -- // INSERTA REGISTRO HISTORICO
    INSERT INTO sc_maehis VALUES
    ( eEmpresa, vaniomes, eCuenta, vfechaini, vfechafin, vcuenta_clabe, vgranum_tarjeta, vsucursal, vproducto, vnum_cte,
      vstatus_cta, vmotivo, vfec_cancelac, vsdo_retenido, vsdo_cong, vsdo_actual, venvio_direcc, vdirecc_envio,
      vsdo_mes_ant, eAcumSdoPos, eDiaSdoPos, vacum_sdo_int, vdias_acum_int, vtasa_bruta, vret_mes_ant, vcong_mes_ant,
      vlim_sbg_ccc, vimp_sbg_ccc, vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum, vtotdepositos, vtotretiros, vtotintpag,
      vtotcomcobrada, vtotivacobrado, vtotisrcobrado, vtotretirosefec, vtototroscargos, vgat, vgat_real );

    SET LOCK MODE TO WAIT 2;
    
    -- // LIMPIA TARJETA EN EL MESANIVERSARIO
    UPDATE sc_tarjeta
       SET disp_mes = 0
     WHERE numcte = vnum_cte
       AND cuenta  = eCuenta
       AND num_tarjeta = vgranum_tarjeta;

    -- // LIMPIA CARGOS Y ABONOS EN EL MAESTRO DE CHEQUES
    UPDATE sc_maechq
       SET num_cgos_mes   = 0,
           imp_cgos_mes   = 0,
           num_abonos_mes = 0,
           imp_abonos_mes = 0
     WHERE empresa = eEmpresa
       AND cuenta  = eCuenta;
       
    

    RETURN CodRet;

END PROCEDURE

DOCUMENT

'DESCRIPCION: Programa que se encarga de crear los datos para la tabla',
'             sc_maehis esta tabla contiene los saldos de la cuenta',
'             al momento del corte',
'EJECUTADO O LLAMADO POR: SPL calcula_int y creciente_diario los',
'                         cuales pertencen al proceso de cierre diario',
'AUTOR : Antonio Ruiz Mtz.',
'FECHA : 30/Agosto/2007',
'VERSION: 1.00.001',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_ws_coppel_bcpl_tar_cont2( pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pcTipoEje CHAR(1),
											  pcNumCteNumTar CHAR(20) )

RETURNING
CHAR(5) AS CodigoError,
CHAR(4) AS CodRet,
CHAR(40) AS Descripcion,
CHAR(3) AS Registros;

	--VARIABLES DE RETORNO
	DEFINE ccCodRetorno 			CHAR(5);
	DEFINE cCodRet					CHAR(4);
	DEFINE mensaje					CHAR(100);
	DEFINE cFecha_proceso 			CHAR(8);
	DEFINE cHora_proceso 			CHAR(6);
	DEFINE cOpcode 					CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(100);
	DEFINE cNombre_proceso			CHAR(17);
	DEFINE cCadena_ent				CHAR(100);

	DEFINE cCodigoError 			CHAR(5);
	DEFINE cDescripcion 			CHAR(40);
	DEFINE cClienteBancoppel 		CHAR(20);
	DEFINE cClienteCoppel 			CHAR(20);
	DEFINE cNumTarjeta 				CHAR(20);
	DEFINE cFechaAsignacion 		CHAR(20);
	DEFINE cEstatusTarjeta 			CHAR(1);
	DEFINE cIndicadorTarjeta 		CHAR(1);
	DEFINE cNumTarjetas				CHAR(20);

	--VARIABLES DE CONTROL DE ERRORES
	DEFINE	iSqlErr 				INTEGER;
	DEFINE	iIsamErr				INTEGER;
	DEFINE	vErrorInfo				VARCHAR(80);
	DEFINE  iIsamError 				INTEGER;
	DEFINE  cRegistros 				CHAR(3);
	DEFINE  cReturnProc				CHAR(3);
	DEFINE  cCtBanco				CHAR(20);

	---INICIALIZAR VARIABLES
	LET ccCodRetorno  				= '00000';
	LET cCodRet 					= '0000';
	LET mensaje 					= 'Consulta Exitosa';
	LET cFecha_proceso 				= TRIM(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	LET cHora_proceso				= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cOpcode 					= '0000';
	LET cDescr_completa_mensaje 	= 'Consulta Exitosa.';
	LET cNombre_proceso				= 'sp_ws_coppel_bcpl_tar_cont2';
	LET cCadena_ent 				= TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));

	LET iIsamError = 0;

	LET cCodigoError 		= "00000";
	LET cDescripcion 		= "CONSULTA EXITOSA";
	LET cClienteCoppel 		= "";
	LET cClienteBancoppel 	= "";
	LET cNumTarjeta 		= "";
	LET cFechaAsignacion 	= "";
	LET cEstatusTarjeta 	= "";
	LET cIndicadorTarjeta 	= "";
	LET iSqlErr 			= 0;
	LET cRegistros 	 		= "0";
	LET cReturnProc			= "";
	LET cNumTarjetas 		= "";
	LET cCtBanco			= "";
	
	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/577/LiberacionIncidenciaWs/sp_ws_coppel_bcpl_tar_cont2.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				IF iSqlErr = '-1213' THEN

					LET cCodRet = '0001';
					LET cOpcode = cCodRet;

					SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
					INTO cOpcode,mensaje,cDescr_completa_mensaje
					FROM bdisac:"informix".sac_ws_catmensajes
					WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
					INTO ccCodRetorno;

					IF cOpcode IS NULL THEN
						LET cOpcode = cCodRet;
						LET mensaje = 'Codigo no registrado en catalogo.';
						LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
					END IF;
				ELSE

					LET cCodRet = iSqlErr;
					LET cOpcode = cCodRet;
					LET mensaje = '';
					LET cDescr_completa_mensaje = '';

					--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
					INTO ccCodRetorno;
				END IF;

				LET cDescr_completa_mensaje = TRIM( cDescr_completa_mensaje );

				INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
				VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);

				DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
				DROP TABLE IF EXISTS tmp_si_tarjetas_cont;

				RETURN cCodRet, cOpcode, SUBSTR( cDescr_completa_mensaje, 1, 40 ), cRegistros;
			END IF;
		END EXCEPTION;

		-- VALIDACION DE PARAMETROS
		IF  NVL(pcAgent_cd,'?') <> 'TDA' OR NVL(pcAgent_trans_type_code,'?') <> 'BCPL_TAR2' OR NVL(pcUsuario,'?')= '?'
			 OR NVL(pcPassword,'?')= '?' OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?'
			 OR NVL(pcIp_origen,'')= '' OR NVL(pcSession_id,'')=''
			 OR NVL(pcTipoEje,'?')= '?' OR NVL(pcNumCteNumTar,'?')= '?'
			 OR LENGTH( TRIM( pcNumCteNumTar ) ) <= 1 THEN

			LET cCodRet ='9996';
		ELSE

			EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code, pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id)
			INTO cCodRet, mensaje;
			
			IF cCodRet = '0000' THEN
				IF( pcTipoEje IN( 1, 2 ) AND pcNumCteNumTar != '' ) THEN
					
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					
					DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
					DROP TABLE IF EXISTS tmp_si_tarjetas_cont;
					
					LET pcNumCteNumTar = TRIM( pcNumCteNumTar );
					
					IF TRIM( NVL(pcTipoEje, "") ) = "1" THEN

						select nvl(numcte,'')
						  into cCtBanco
						  FROM bdinteg:"informix".si_cliente 
						 where numcte_ref = pcNumCteNumTar;
						 
						select num_tarjeta numtarjeta, numcte
						  from bdicheq:"informix".sc_tarjeta
						 where status_tar = 'A'
						   and numcte = cCtBanco
						INTO TEMP tmp_si_clientetarjetas_cont with no log;
						  
						 
						/*
						SELECT b.numtarjeta, {+INDEX (bdinteg:"informix".idx_numcte_ref)} a.numcte
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicheq:"informix".sc_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE a.numcte_ref = pcNumCteNumTar
						AND c.status_tar = 'A'
						AND a.empresa = '001'
						INTO TEMP tmp_si_clientetarjetas_cont with no log; */

					ELSE


						select num_tarjeta numtarjeta,  numcte
						  from bdicheq:"informix".sc_tarjeta
						 where num_tarjeta = pcNumCteNumTar
						INTO TEMP tmp_si_clientetarjetas_cont with no log;

						/*
						SELECT {+INDEX (intercard:tarjeta idx_tarjeta1)} b.numtarjeta, a.numcte
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicheq:"informix".sc_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE b.numtarjeta = pcNumCteNumTar
						AND a.empresa = '001'
						INTO TEMP tmp_si_clientetarjetas_cont with no log; */

					END IF;
					
					CREATE TEMP TABLE tmp_si_tarjetas_cont(numtarj VARCHAR(16)) WITH NO LOG;
					
					SELECT FIRST 1 numcte
					INTO cCtBanco
					FROM tmp_si_clientetarjetas_cont;
					
					FOREACH
						EXECUTE PROCEDURE bditrapres:"informix".sp_consulta_tarjetas_dep(cCtBanco) INTO cReturnProc,cNumTarjetas
						INSERT INTO tmp_si_tarjetas_cont(numtarj)VALUES(cNumTarjetas);
					END FOREACH;
					
					SELECT TO_CHAR( COUNT(*), '&&&' )
					INTO cRegistros
					FROM tmp_si_clientetarjetas_cont a JOIN tmp_si_tarjetas_cont c
					ON a.numtarjeta = c.numtarj;
					
					
					INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
					VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescripcion, cClienteBancoppel, cClienteCoppel, cRegistros, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
					
					DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
					DROP TABLE IF EXISTS tmp_si_tarjetas_cont;
					
					RETURN cCodigoError, cCodRet, cDescripcion, cRegistros;
					
				END IF;
			END IF;
		END IF;
		
		IF cCodRet <> '0000' THEN
			--Se obtienen los mensajes de error asi como el codigo del mensaje
			SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
			INTO cOpcode,mensaje,cDescr_completa_mensaje
			FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
			
			--En caso de que no exista el codigo del mensaje se les asigna otros valores
			IF cOpcode IS NULL THEN
				LET cOpcode = cCodRet;
				LET mensaje = 'Codigo no registrado en catalogo.';
				LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
			INTO ccCodRetorno;
			
			LET cDescr_completa_mensaje = TRIM( cDescr_completa_mensaje );
			
			INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
			VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescr_completa_mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
			
			DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
			DROP TABLE IF EXISTS tmp_si_tarjetas_cont;
			
			RETURN cCodRet, cOpcode, SUBSTR( cDescr_completa_mensaje, 1, 40 ), '000';
			
		END IF;
	END;
END PROCEDURE
;
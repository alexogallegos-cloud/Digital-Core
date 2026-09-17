CREATE PROCEDURE "informix".modifica_maehis(pempresa CHAR(3))
RETURNING CHAR(5);

    DEFINE CodRet	                CHAR(5);
    DEFINE sql_err                  INTEGER;
	DEFINE vcuenta                  CHAR (20);
    DEFINE vtotdepositos            DECIMAL(14,2);
    DEFINE vtotretiros              DECIMAL(14,2);
    DEFINE vtotcomcobrada           DECIMAL(14,2);
    DEFINE vtotcombonif             DECIMAL(14,2);
    DEFINE vtotivacobrado           DECIMAL(14,2);
    DEFINE vtotivabonif             DECIMAL(14,2);
    DEFINE vtotintpag               DECIMAL(14,2);
    DEFINE vtotisrcobrado           DECIMAL(14,2);
	DEFINE vfechafin                DATE;
    DEFINE vfechaini                DATE;
    DEFINE vaniomes                 CHAR(6);
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
	DEFINE vgtrans_pag_int          CHAR(4);
	DEFINE vgtransisr               CHAR(4);
	DEFINE vcontador1               INTEGER;
    DEFINE vempieza                 SMALLINT;
	DEFINE ven_transacc             SMALLINT;

    ON EXCEPTION 
        SET sql_err
        LET CodRet = sql_err;
        RETURN CodRet;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/modifica_maehis.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;

    LET CodRet     = '000';
    LET vtran_efec = '';
 
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
	LET vgtrans_pag_int = "3276";
	LET vgtransisr      = "3277";
	LET vcontador1   = 0;
    LET vempieza     = -1;
    LET ven_transacc = 0; 
        
    -- // OBTIENE FECHAS DE CONSULTAS EN HISTORICOS
    SELECT valor
      INTO vfechainimovhis
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechainimovhisold
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT valor
      INTO vtrandepotrobco
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'trandepobco';
       
    SELECT valor
      INTO vtrandevotrobco
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'trandevobco';
    

	FOREACH WITH HOLD
	    SELECT modi.cuenta, modi.aniomes, maehis.fechaini, maehis.fechafin
		  INTO vcuenta, vaniomes, vfechaini, vfechafin
		  FROM cuentas_maehis modi, sc_maehis maehis
         WHERE modi.cuenta = maehis.cuenta
           AND modi.aniomes = maehis.aniomes		 
	
	    IF vempieza = -1 THEN
           LET vempieza = 0;
           LET ven_transacc = 1; 
           BEGIN WORK;
        END IF;
	
        -- // OBTIENE CARGOS Y ABONOS DEL HISTORICO
        FOREACH           
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              INTO vmonto_tot, vtransacc, vnaturaleza, vtipo_tran, vtran_efec
              FROM sc_movhis mv
              INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pEmpresa
               AND mv.cuenta = vCuenta
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc = tr.numero
            UNION ALL
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              FROM sc_movhis_old mv
              INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = pempresa
               AND mv.cuenta = vCuenta
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
                  LET vtotcomcobrada = vtotcomcobrada + vmonto_tot;
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

        -- // MODIFICA REGISTRO HISTORICO
        UPDATE sc_maehis SET totdepositos = vtotdepositos, 
		                     totretiros = vtotretiros,
                             totintpag = vtotintpag,
							 totcomcobrada = vtotcomcobrada,
                             totivacobrado = vtotivacobrado,
                             totisrcobrado = vtotisrcobrado, 
							 totretirosefec = vtotretirosefec,
							 tototroscargos = vtototroscargos
		 WHERE cuenta = vcuenta
           AND aniomes = vaniomes;
		
        LET vcontador1 = vcontador1 + 1;

        COMMIT WORK;
        BEGIN WORK;		
		   
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
    
    END FOREACH;

    IF ven_transacc = 1 THEN
       COMMIT WORK;
       LET ven_transacc = 0;
    END IF;	

    RETURN CodRet;

END PROCEDURE

;
CREATE PROCEDURE "informix".sp_dskrga_arch_transfer()
RETURNING CHAR(5);
    
	DEFINE vcodret1             CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
    DEFINE desc_err             CHAR(50);
	DEFINE vsql                 CHAR(1500);
    DEFINE vstmt                CHAR(200);
	DEFINE vfecha_hoy       	DATE;
    DEFINE vfecha_valor         DATE;
    DEFINE vfecha_ini           DATE;
    DEFINE vfecha_fin           DATE;
    DEFINE vfecha_des           CHAR(8);
    DEFINE vnumcte              CHAR(20);
    DEFINE vcuenta              CHAR(20);
    DEFINE vtelefono            CHAR(13);
    DEFINE vfecha_alta          DATE;
    DEFINE vfecha_canc          DATE;
    DEFINE vpoblacion_estado    CHAR(100);
	
	DEFINE vestado             CHAR(50);
	DEFINE vasigna_nip           CHAR(2);
	
    DEFINE vtransacc            CHAR(50);
    DEFINE vmonto               DECIMAL(16,2);
    DEFINE vcta_destino         CHAR(18);
    DEFINE vstatus_transacc     CHAR(28);
    DEFINE vexiste              SMALLINT;
	
	DEFINE vfech_alt            DATE;
    
    LET vcodret1            = '000';
    LET vcodret2            = '';
    LET vcodret3            = '';
    LET sql_err	            = 0 ;
    LET isam_err            = 0 ;
    LET desc_err            = '';
	LET vsql                = '';
    LET vstmt               = '';
    LET vfecha_hoy          = '';
    LET vfecha_valor        = '';
    LET vfecha_ini          = '';
    LET vfecha_fin          = '';
    LET vfecha_des          = '';
    LET vnumcte             = '';
    LET vcuenta             = '';
    LET vtelefono           = '';
    LET vfecha_alta         = '';
    LET vfecha_canc         = '';
    LET vpoblacion_estado   = '';
	LET vestado             = '';
	LET vasigna_nip         = '';
	
    LET vtransacc           = '';
    LET vmonto              = 0.00;
    LET vcta_destino        = '';
    LET vstatus_transacc    = '';
    LET vexiste             = 0;
	LET vfech_alt           = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_dskrga_arch_transfer.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
     END EXCEPTION;
    
	 --SET DEBUG FILE TO "/informix/vamilan/sp_dskrga_arch_transfer.out";
	-- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdinteg:si_fechas
     WHERE empresa = '001';
     
    SELECT valor
      INTO vfecha_valor
      FROM tf_param_transfer
     WHERE codigo = '900';
     
    LET vfecha_ini = vfecha_valor;
    LET vfecha_fin = vfecha_valor + 6 UNITS DAY;
    LET vfecha_des = TO_CHAR(vfecha_hoy,'%Y%m%d');
    
    TRUNCATE TABLE tf_arch_user;
    TRUNCATE TABLE tf_arch_trxs;
    
    -- // REGISTROS DE tf_user_transfer
    FOREACH
      SELECT maec.numcte_tf, maec.cuenta_tf, maec.telefono, maec.fec_alta, maec.fec_cancelac, ass.asigna_nip 
          INTO vnumcte, vcuenta, vtelefono, vfecha_alta, vfecha_canc, vasigna_nip   
      FROM tf_maecte maec
	      LEFT OUTER JOIN tf_assign_nip ass ON (ass.cuenta = maec.cuenta_tf)
          WHERE cuenta_tf >= '80000000000'
          AND maec.fec_alta BETWEEN vfecha_ini AND vfecha_fin  		 
		                           
                                   
        SELECT COUNT(*)
          INTO vexiste
          FROM tf_direcciones
         WHERE numcte_tf = vnumcte
           AND cuenta_tf = vcuenta;
           
        IF vexiste > 0 THEN
		  -- TRIM por si encuentra espacios vacios
          SELECT FIRST 1 TRIM(colonia)||' '||TRIM(municipio), TRIM(estado)       
              INTO vpoblacion_estado, vestado
          FROM tf_direcciones
               WHERE numcte_tf = vnumcte
               AND cuenta_tf = vcuenta;
        ELSE
            LET vpoblacion_estado = '';
		END IF;
        
		IF TRIM(NVL(vasigna_nip,'')) = '' THEN
			LET vasigna_nip = "00";
		END IF
		
        INSERT INTO tf_arch_user VALUES
		(vnumcte, vcuenta, vtelefono, vpoblacion_estado, vfecha_alta, vfecha_canc, vfecha_hoy, vestado, vasigna_nip);
        
        LET vnumcte = '';
        LET vcuenta = '';
        LET vtelefono = '';
        LET vfecha_alta = '';
        LET vfecha_canc = '';
        LET vpoblacion_estado = '';
		LET vestado = '';
		LET vasigna_nip = '';
    END FOREACH;
    
    -- // REGISTROS DE tf_retire_customer
    FOREACH
 
	SELECT ma.numcte_tf, ma.cuenta_tf, ma.telefono, ma.fec_alta, ma.fec_cancelac, ass.asigna_nip 
           INTO vnumcte, vcuenta, vtelefono, vfecha_alta, vfecha_canc, vasigna_nip   
        FROM tf_maecte ma 
	   	  LEFT OUTER JOIN tf_assign_nip ass ON ( ass.cuenta = ma.cuenta_tf )	
          WHERE cuenta_tf >= '80000000000'
          AND ma.fec_cancelac BETWEEN vfecha_ini AND vfecha_fin
                                                      
        SELECT COUNT(*)
          INTO vexiste
          FROM tf_direcciones
         WHERE numcte_tf = vnumcte
           AND cuenta_tf = vcuenta;
           
        IF vexiste > 0 THEN
         SELECT FIRST 1 TRIM(colonia)||' '||TRIM(municipio), TRIM(estado)       
             INTO vpoblacion_estado, vestado
          FROM tf_direcciones
             WHERE numcte_tf = vnumcte
             AND cuenta_tf = vcuenta;
        ELSE
            LET vpoblacion_estado = '';
		END IF;
        
		
		IF TRIM(NVL(vasigna_nip,'')) = '' THEN
			LET vasigna_nip = "00";
		END IF
		
        INSERT INTO tf_arch_user VALUES
        (vnumcte, vcuenta, vtelefono, vpoblacion_estado, vfecha_alta, vfecha_canc, vfecha_hoy, vestado, vasigna_nip);
		        
        LET vnumcte = '';
        LET vcuenta = '';
        LET vtelefono = '';
        LET vfecha_alta = '';
        LET vfecha_canc = '';
        LET vpoblacion_estado = '';
		LET vestado = '';
		LET vasigna_nip = '';
		
    END FOREACH;
    
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/arch_user_transfer_'||vfecha_des||'.txt '||
               'SELECT UNIQUE numcte, cuenta, telefono, fecha_alta, fecha_canc, poblacion, estado, asigna_nip FROM tf_arch_user ORDER BY numcte, cuenta;"> /resplogifx/conciliachq/archtrf1.sql';

      SYSTEM vsql;
      LET vstmt = "/ifxsif01/bin/dbaccess bditransfer /resplogifx/conciliachq/archtrf1.sql";
	  SYSTEM vstmt;
    
    -- // REGISTROS DE TRANSACCIONES MONETARIAS
    FOREACH
	 SELECT mae.numcte, trn.cuenta, mae.telefono, TRIM(trx.descripcion), trn.monto, trn.id_cuenta_destino, TRIM(sta.descripcion), trn.fech_alt 
          INTO vnumcte, vcuenta, vtelefono, vtransacc, vmonto, vcta_destino, vstatus_transacc, vfech_alt
          FROM tf_all_transaction trn
          LEFT OUTER JOIN tf_maecte mae ON ( mae.cuenta_tf = trn.cuenta )
          LEFT OUTER JOIN tf_cat_transac_mps trx ON ( trx.transac = trn.transacc AND trx.tipo_transaccion = 'M' )
          LEFT OUTER JOIN tf_cat_status_transac sta ON ( sta.estatus_transac = trn.estatus_transac )
         WHERE trn.fech_alt BETWEEN vfecha_ini AND vfecha_fin  
                                                
        INSERT INTO tf_arch_trxs VALUES
        ( vnumcte, vcuenta, vtelefono, vtransacc, vmonto, vcta_destino, vstatus_transacc, vfecha_hoy, vfech_alt);
        
        LET vnumcte = '';
        LET vcuenta = '';
        LET vtelefono = '';
        LET vtransacc = '';
        LET vmonto = 0.00;
        LET vcta_destino = '';
        LET vstatus_transacc = '';
        LET vfech_alt = ''; 
		 
    END FOREACH;
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/arch_trxs_transfer_'||vfecha_des||'.txt '||
               'SELECT numcte, cuenta, telefono, transacc, monto, cta_destino, status_trx, fech_alt FROM tf_arch_trxs ORDER BY numcte, cuenta;"> /resplogifx/conciliachq/archtrf2.sql';
    
    SYSTEM vsql;
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bditransfer /resplogifx/conciliachq/archtrf2.sql";

	
	
    SYSTEM vstmt;
    
    -- // ACTUALIZA EL VALOR DE LA FECHA DE INICIO PARA LA PROXIMA GENERACION DE ARCHIVOS
    UPDATE tf_param_transfer 
       SET valor = vfecha_hoy
     WHERE codigo = '900';
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;
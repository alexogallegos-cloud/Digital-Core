CREATE PROCEDURE "informix".sp_generaredoctaejedetalle_factelect_pag( pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE )
RETURNING CHAR(5)     AS CodRet, 
          CHAR(180)   AS Descripcion, 
          MONEY(14,2) AS SaldoCuenta, 
          DATE        AS FechaAlt, 
          MONEY(14,2) AS Deposito, 
          MONEY(14,2) AS Retiro;
    
    DEFINE GLOBAL vidreg		INTEGER  DEFAULT 0;
	DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE vSqlErr              INTEGER;
    DEFINE vIsamErr             INTEGER;
    DEFINE vDescErr             CHAR(50);
    DEFINE vsucursal            CHAR(80);
    DEFINE vdescripcion         CHAR(180);
    DEFINE vfechealt            DATE;
    DEFINE vsdocuenta           MONEY(18,2);
    DEFINE vdeposito            MONEY(18,2);
    DEFINE vretiro              MONEY(18,2);
	DEFINE v_capital            MONEY(18,2);
	DEFINE v_intereses          MONEY(18,2);
	DEFINE v_isr                MONEY(18,2);
    DEFINE iTotalMovimientos    INTEGER;
    DEFINE vnum_serial          INTEGER;
	DEFINE vfolio_suc			CHAR(16);
	DEFINE vtransacc	       	CHAR(04);
	DEFINE dFechaEmision        DATE;
    DEFINE vnlinea              INTEGER;
	DEFINE vcortSig             CHAR(255);
    DEFINE vcontador1            INTEGER;
	

    LET vcodret           = '000';
    LET vcodret2          = '';
    LET vcodret3          = '';
    LET vSqlErr           = 0;            
    LET vIsamErr          = 0;            
    LET vDescErr          = '';            
    LET vsucursal         = "";
    LET vdescripcion      = "";   
    LET vfechealt         = "";
    LET vsdocuenta        = 0;
    LET vdeposito         = 0;
    LET vretiro           = 0;
    LET iTotalMovimientos = 0;
    LET vnum_serial       = 0;
	LET v_capital         = 0;
	LET v_intereses       = 0;
	LET v_isr             = 0;
	LET vtransacc		  = "";
	LET dFechaEmision     = "";
    LET vnlinea 	      = 0;                              
    LET vcortSig          = "";    
    LET vcontador1        = 0;		
    
    BEGIN
    
    ON EXCEPTION SET vSqlErr, vIsamErr, vDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaejedetalle_factelect_pag.err";
   		TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret  = vSqlErr;
            LET vcodret2 = vIsamErr;
            LET vcodret3 = vDescErr;
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
        END IF;
    END EXCEPTION;
    
	--SET DEBUG FILE TO "/RESPALDOSNEW/pagare/sp_generaredoctaejedetalle_factelect_pag.out";
	--TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--VALIDA PARAMETROS DE ENTRADA
    IF ( pEmpresa IS NULL OR pCuenta IS NULL OR pFechaInicial IS NULL OR pFechaFinal IS NULL ) THEN
        LET vcodret = '001'; 
        RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
    END IF;
    
	--FECHA EMISION 
	SELECT fecha_ant
    INTO   dFechaEmision
    FROM   bdicheq:sc_fechas
    WHERE  empresa = pEmpresa;
  
    --DETALLE DE LOS MOVIMIENTOS  
    FOREACH WITH HOLD

            SELECT mov.num_serial,
                   CASE WHEN trx.numero = "0274" AND mov.transacc = "0331" THEN (SELECT descripcion FROM bdinteg: si_transacc WHERE numero = "0331") ELSE trx.descripcion END AS DESCRIPCION,
                   mov.sdo_cuenta, mov.fech_alt,
                   CASE WHEN trx.naturaleza = 'C' THEN mov.monto_tot ELSE 0 END AS RETIRO,
                   CASE WHEN trx.naturaleza IN ('A','R') THEN mov.monto_tot ELSE 0 END AS DEPOSITO,
                   CASE WHEN trx.numero IN ('0202','0223','0250') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||''||' - '|| NVL(TRIM(mov.fech_hor::CHAR(12)),'') ELSE '' END  AS Sucursal,    --Se agrego el nombre del estado en estas transacciones.
                   mov.transacc,mov.folio_suc
            INTO   vnum_serial, vdescripcion, vsdocuenta, vfechealt, vretiro, vdeposito, vsucursal,vtransacc,vfolio_suc           
		    FROM   bdinvers:sv_movhis mov,
                   bdinteg:si_transacc trx,
                   bdinteg:si_sucursales su		
            WHERE  mov.empresa  = '001'  
			AND    mov.cuenta  = pCuenta
            AND    mov.fech_alt = pFechaInicial
            AND    mov.transacc IN ('0500','0518')
            AND    mov.cancelad <> "S"
            AND    mov.transacc = trx.numero
            AND    trx.empresa  = mov.empresa
            AND    trx.numero   = mov.transacc
            AND    trx.se_emite_edocta = "S"
            AND    trx.naturaleza IN ('C','A')
			AND    trx.sistema = '03'
            AND    su.sucursal = mov.sucursal
            AND    su.empresa  = mov.empresa			
			UNION ALL 
		    SELECT mov.num_serial,
                   CASE WHEN trx.numero = "0274" AND mov.transacc = "0331" THEN (SELECT descripcion FROM bdinteg: si_transacc WHERE numero = "0331") ELSE trx.descripcion END AS DESCRIPCION,
                   mov.sdo_cuenta, mov.fech_alt,
                   CASE WHEN trx.naturaleza = 'C' THEN mov.monto_tot ELSE 0 END AS RETIRO,
                   CASE WHEN trx.naturaleza IN ('A','R') THEN mov.monto_tot ELSE 0 END AS DEPOSITO,
                   CASE WHEN trx.numero IN ('0202','0223','0250') THEN mov.sucursal||' - '||NVL(TRIM(su.nombre),'')||' - '||''||' - '|| NVL(TRIM(mov.fech_hor::CHAR(12)),'') ELSE '' END  AS Sucursal,    --Se agrego el nombre del estado en estas transacciones.
                   mov.transacc,mov.folio_suc
            FROM   bdinvers:sv_movhis mov,
                   bdinteg:si_transacc trx,
                   bdinteg:si_sucursales su		
            WHERE  mov.empresa  = '001'
            AND    mov.cuenta  = pCuenta			
            AND    mov.fech_alt = pFechaFinal
            AND    mov.transacc IN ('0517','0516','0507','0509','0504','0505')
            AND    mov.cancelad <> "S"
            AND    mov.transacc = trx.numero
            AND    trx.empresa  = mov.empresa
            AND    trx.numero   = mov.transacc
            AND    trx.se_emite_edocta = "S"
            AND    trx.naturaleza IN ('C','A')
			AND    trx.sistema = '03'
            AND    su.sucursal = mov.sucursal
            AND    su.empresa  = mov.empresa
            ORDER  BY mov.fech_alt ASC, mov.num_serial ASC  
				
			
			
			SELECT capital,   intereses,   isr 
			INTO   v_capital, v_intereses, v_isr     
			FROM   bdinvers:sv_maeinv
			WHERE  cuenta = pCuenta
			AND    status_cta <> 1
			AND    fecha_alta = pFechaInicial           
			AND    fecha_venc = pFechaFinal;
			            
            -- // sumar movimiento al contador
            LET iTotalMovimientos = iTotalMovimientos + 1; 
                  
			LET vnlinea = 1;
			
			IF  vtransacc = '0500' OR vtransacc = '0518' THEN 
			    LET vcortSig = 'DEPOSITO APERTURA PAGARE';
				INSERT INTO bdinvers:sv_detalle_edocta_factelect_pag
				(idreg, fecha_emision, num_cuenta_pag, secuencia, nlinea,  fechamov,  descripcion, retiro,  deposito,  saldo)
				VALUES
				(vidreg,dFechaEmision, pCuenta,        '1',       vnlinea, vfechealt, vcortSig,    vretiro, vdeposito, vdeposito);
					 
			ELIF vtransacc = '0517' THEN 
                 LET vcortSig = 'ABONO DE INTERESES PAGARE';
				INSERT INTO bdinvers:sv_detalle_edocta_factelect_pag
				(idreg, fecha_emision, num_cuenta_pag, secuencia, nlinea,  fechamov,  descripcion, retiro,  deposito,  saldo)
				VALUES
				(vidreg,dFechaEmision, pCuenta,        '2',       vnlinea, vfechealt, vcortSig,    vretiro, vdeposito, (vdeposito + v_capital));
				
		    ELIF vtransacc = '0516' THEN 
			     LET vcortSig = 'RETENCION DE ISR PAGARE';
				 INSERT INTO bdinvers:sv_detalle_edocta_factelect_pag
				(idreg, fecha_emision, num_cuenta_pag, secuencia, nlinea,  fechamov,  descripcion, retiro,  deposito,  saldo)
				VALUES
				(vidreg,dFechaEmision, pCuenta,        '3',       vnlinea, vfechealt, vcortSig,    vretiro, vdeposito, ((v_capital + v_intereses ) - v_isr)) ;
				 
		    ELIF vtransacc = '0507' OR vtransacc = '0509' THEN
			     LET vcortSig = 'TRASP. CAPITAL DE PAGARE'; 
				 INSERT INTO bdinvers:sv_detalle_edocta_factelect_pag
				 (idreg, fecha_emision, num_cuenta_pag, secuencia, nlinea,  fechamov,  descripcion, retiro,  deposito,  saldo)
				 VALUES
				 (vidreg,dFechaEmision, pCuenta,        '4',       vnlinea, vfechealt, vcortSig,    vretiro, vdeposito, (v_intereses - v_isr));
				 
		    ELIF vtransacc = '0504' OR vtransacc = '0505' THEN
				 LET vcortSig = 'TRASP. INTERESES DE PAGARE';
				 INSERT INTO bdinvers:sv_detalle_edocta_factelect_pag
				(idreg, fecha_emision, num_cuenta_pag,  secuencia, nlinea,  fechamov, descripcion, retiro,  deposito,  saldo)
				 VALUES
				(vidreg,dFechaEmision, pCuenta,         '5',       vnlinea, vfechealt, vcortSig,   vretiro, vdeposito, (vretiro - vretiro));
				 
			END IF;
			        				
			LET vcontador1 = vcontador1 + 1;
			   
			IF  (vcontador1 >= 1000) THEN 
                LET vcontador1 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
				
			RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro WITH RESUME;
        END FOREACH;
                 
        -- // preguntar sino hubo movimientos
        IF iTotalMovimientos = 0 THEN
            LET vcodret = '002';                
            LET vdescripcion = ' ';
            LET vsdocuenta = null;
            LET vfechealt = null;
            LET vdeposito = null;
            LET vretiro = null;
            RETURN vcodret, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro;
        END IF; 
    END;
    
END PROCEDURE;
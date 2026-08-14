CREATE PROCEDURE "informix".sp_concilia_donativos_becalos()
RETURNING CHAR(3);

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(80);
    DEFINE vcodret4     CHAR(5);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(80);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcomienza    SMALLINT;
    DEFINE iTransacc    SMALLINT;
    DEFINE vsql         CHAR(1200);
    DEFINE vstmt        CHAR(300);
    DEFINE vexiste      SMALLINT;
    DEFINE dFechaHoy    DATE;
    DEFINE dFechaAnt    DATE;
    DEFINE dFecha       DATE;
    DEFINE cFolio       CHAR(16);
    DEFINE cTransac     CHAR(4);
    DEFINE cCuenta      CHAR(20);
    DEFINE mMonto       DECIMAL(14,2);
	DEFINE mMonto_spei  DECIMAL(14,2);
    DEFINE cTransac2    CHAR(4);
    DEFINE cCuenta2     CHAR(20);
    DEFINE mMonto2      DECIMAL(14,2);
	DEFINE vfecha2      CHAR(8);
	DEFINE vnombrearchivo CHAR(100);
	DEFINE pempresa     CHAR(3);
    
    -- // VARIABLES PARA TRANSFERENCIA SPEI
    DEFINE cSucursalSPEI CHAR(4);
    DEFINE cFolioSucursalSPEI CHAR(16);
    DEFINE iBancoDestinoSPEI INTEGER;
    DEFINE dFechaCapturaSPEI DATE;
    DEFINE iTipoPagoSPEI INTEGER;
    DEFINE iTipoOperacionSPEI INTEGER;
    DEFINE mImporteOperacionSPEI MONEY(18,2);
    DEFINE cNombreOrdenSPEI CHAR(40);
    DEFINE cCuentaOrdenSPEI CHAR(20);
	DEFINE cCuentaOrden 	CHAR(20);
    DEFINE cRFCOrdenSPEI CHAR(18);
    DEFINE cNombreBeneficiarioSPEI CHAR(40);
    DEFINE cCuentaBeneficiarioSPEI CHAR(20);
    DEFINE cRFCBeneficiarioSPEI CHAR(18);
    DEFINE mImporteIVASPEI MONEY(18,2);
    DEFINE dReferenciaNumero DECIMAL(7,0);
    DEFINE cReferenciaCobranza1SPEI CHAR(40);
    DEFINE cConceptoPagoSPEI CHAR(210);
    DEFINE cClavePagoSPEI CHAR(10);
    DEFINE cNombreBeneficiario2SPEI CHAR(40);
    DEFINE cCuentaBeneficiario2SPEI CHAR(20);
    DEFINE cRFCBeneficiario2SPEI CHAR(18);
    DEFINE cConceptoPago2SPEI CHAR(40);
    DEFINE cTransaccionSPEI CHAR(4);
    DEFINE iTipoCuentaOrdenSPEI INTEGER;
    DEFINE iTipoCuentaBeneficiarioSPEI INTEGER;
    DEFINE iSerialFolioSPEI INTEGER;
    DEFINE cCodRetSp CHAR(5);
    DEFINE cMensajeError CHAR(100);
    DEFINE cCveRastreo CHAR(30);
    
    -- // VARIABLES CARGO EN CUENTA 
    DEFINE cCodRetCgo CHAR(5);
    DEFINE cTrxCgo CHAR(4);
    DEFINE dFechaCgo DATE;
    DEFINE mSdoDispCgo DECIMAL(14,2);
    DEFINE mMontoCgo DECIMAL(14,2);
    
	DEFINE vfechaproc DATE;
	DEFINE vproceso CHAR(20);	
             ---- Sftk Mar2024             
    DEFINE vtrxs_0450 CHAR(4);    
    DEFINE vtrxs_0453 CHAR(4);
    DEFINE vcancela   CHAR(1);
    LET vtrxs_0450  = "0450";
    LET vtrxs_0453  = "0453";
    LET vcancela    = "S";
	    ---- Sftk Mar2024 
    LET vcodret1    = '000';
    LET vcodret2    = '';
    LET vcodret3    = '';
    LET vcodret4    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vcontador1  = 0;
    LET vcontador2  = 0;
    LET vcomienza   = -1;
    LET iTransacc   = 0;
    LET vsql        = '';
    LET vstmt       = '';
    LET vexiste     = 0;
    LET dFechaHoy   = '';
    LET dFechaAnt   = '';
    LET dFecha      = '';
    LET cFolio      = '';
    LET cTransac    = '';
    LET cCuenta     = '';
    LET mMonto      = 0.00;
    LET cTransac2   = '';
    LET cCuenta2    = '';
    LET mMonto2     = 0.00;
	LET mMonto_spei = 0.00;
	LET pEmpresa    = '001';
    
    -- // VARIABLES PARA TRANSFERENCIA SPEI
    LET cSucursalSPEI = '';
    LET cFolioSucursalSPEI = '';
    LET iBancoDestinoSPEI = 0;
    LET dFechaCapturaSPEI = NULL;
    LET iTipoPagoSPEI = 0;
    LET iTipoOperacionSPEI = 0;
    LET mImporteOperacionSPEI = 0.0;
    LET cNombreOrdenSPEI = '';
    LET cCuentaOrdenSPEI = '';
    LET cRFCOrdenSPEI = '';
    LET cNombreBeneficiarioSPEI = '';
    LET cCuentaBeneficiarioSPEI = '';
    LET cRFCBeneficiarioSPEI = '';
    LET mImporteIVASPEI = 0.0;
    LET dReferenciaNumero = 0.0;
    LET cReferenciaCobranza1SPEI = '';
    LET cConceptoPagoSPEI = '';
    LET cClavePagoSPEI = '';
    LET cNombreBeneficiario2SPEI = '';
    LET cCuentaBeneficiario2SPEI = '';
    LET cRFCBeneficiario2SPEI = '';
    LET cConceptoPago2SPEI = '';
    LET cTransaccionSPEI = '';
    LET iTipoCuentaOrdenSPEI = 0;
    LET iTipoCuentaBeneficiarioSPEI = 0;
    LET iSerialFolioSPEI = 0;
    LET cCodRetSp = '';
    LET cMensajeError = '';
    LET cCveRastreo = '';
    
    -- // VARIABLES CARGO EN CUENTA
    LET cCodRetCgo = '';
    LET cTrxCgo = '';
    LET dFechaCgo = '';
    LET mSdoDispCgo = 0.00;
    LET mMontoCgo = 0.00;
	
	LET vnombrearchivo = '';
	LET vproceso  = "concidonativos";
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/RESPALDOSNEW/sp_concilia_donativos_becalos.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
   -- SET DEBUG FILE TO "/RESPALDOSNEW/mbucio/sp_concilia_donativos_becalos.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO dFechaHoy, dFechaAnt
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
	LET vfecha2 = TO_CHAR(dFechaAnt, '%d%m%Y');
	
	-- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
    select fecha
      into vfechaproc
      from sc_contproc
     where empresa = pempresa
       and proceso = vproceso;

    if vfechaproc = dFechaHoy then
	   let vcodret1 = '000';
       return vcodret1;
    end if;

	LET dFechaAnt = vfechaproc;
	
    -- // TRANSACCIONES 0450
    --- Sftk Mar2024
   /* select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0450';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0450;        
    end if;
    */
    drop table if exists "informix".sc_trxs_0450; --- Sftk Mar2024

    create table "informix".sc_trxs_0450(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0450_folio on "informix".sc_trxs_0450(folio) online;
    update statistics medium for table sc_trxs_0450;
     
     --- Sftk Mar2014
     INSERT INTO "informix".sc_trxs_0450 
     select fech_alt, folio_suc, transacc, cuenta, monto_tot 
       from sc_movhis
      where transacc = vtrxs_0450
        and fech_alt >= dFechaAnt
        and cancelad <> vcancela;
       --- Sftk Mar2014

    --- Sftk Mar 2024
    /*FOREACH 
        select fech_alt, folio_suc, transacc, cuenta, monto_tot   --- JRGC1 83
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_movhis
         where transacc = "0450"
           and fech_alt >= dFechaAnt
           and cancelad <> "S"
           
        INSERT INTO sc_trxs_0450 VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH; */

    
           
    
    -- // TRANSACCIONES 0453
    --- Sftk Mar2024
   /* select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0453';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0453;        
    end if;*/

    drop table if exists "informix".sc_trxs_0453; --- Sftk Mar2024
    
    create table "informix".sc_trxs_0453(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0453_folio on "informix".sc_trxs_0453(folio) online;
    update statistics medium for table sc_trxs_0453;
      
      --- Sftk Mar2014
     INSERT INTO "informix".sc_trxs_0453 
     select fech_alt, folio_suc, transacc, cuenta, monto_tot 
       from sc_movhis
      where transacc = vtrxs_0453
        and fech_alt >= dFechaAnt
        and cancelad <> vcancela;
       --- Sftk Mar2014
    
    --- Sftk Mar 2024
    /*FOREACH 
        select fech_alt, folio_suc, transacc, cuenta, monto_tot   --- JRGC1 91
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_movhis
         where transacc = "0453"
           and fech_alt >= dFechaAnt
           and cancelad <> "S"
           
        INSERT INTO sc_trxs_0453 VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH;*/


    
    -- // TRANSACCIONES 0450 NO CONCILIADAS

    --- Sftk Mar 2024
    /*select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0450_nc';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0450_nc;        
    end if;*/

    drop table if exists "informix".sc_trxs_0450_nc; --- Sftk Mar2024
    
    create table "informix".sc_trxs_0450_nc(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0450_nc_folio on "informix".sc_trxs_0450_nc(folio) online;
    update statistics medium for table sc_trxs_0450_nc;
    
     insert into "informix".sc_trxs_0450_nc 
     select {+INDEX sc_trxs_0450 idx_trxs_0450_folio} fecha, folio, transac, cuenta, monto 
       from sc_trxs_0450
      where folio not in(select {+INDEX sc_trxs_0453 idx_trxs_0453_folio} folio from sc_trxs_0453);
      --- Sftk Mar2014

   /* FOREACH     --- Sftk Mar2024
        select fecha, folio, transac, cuenta, monto 
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_trxs_0450
         where folio not in(select folio from sc_trxs_0453)
           
        INSERT INTO sc_trxs_0450_nc VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH; */

    
    -- // TRANSACCIONES 0453 NO CONCILIADAS
    --- Sftk Mar2014
    /*select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0453_nc';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0453_nc;        
    end if;*/
     
    drop table if exists "informix".sc_trxs_0453_nc;    --- Sftk Mar2014
    
    create table "informix".sc_trxs_0453_nc(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0453_nc_folio on "informix".sc_trxs_0453_nc(folio) online;
    update statistics medium for table sc_trxs_0453_nc;

     insert into sc_trxs_0453_nc 
     select {+INDEX sc_trxs_0453 idx_trxs_0453_folio} fecha, folio, transac, cuenta, monto
       from sc_trxs_0453
      where folio not in(select {+INDEX sc_trxs_0450 idx_trxs_0450_folio} folio from sc_trxs_0450);
    
    --- Sftk Mar2014
    /*FOREACH 
        select fecha, folio, transac, cuenta, monto
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_trxs_0453
         where folio not in(select folio from sc_trxs_0450)
           
        INSERT INTO sc_trxs_0453_nc VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH;*/
      
    -- // TRANSACCIONES CONCILIADAS
    --- Sftk Mar2014

    /*select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_conci_becalos';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_conci_becalos;        
    end if;*/

    drop table if exists "informix".sc_trxs_conci_becalos;  --- Sftk Mar2014
    
    create table "informix".sc_trxs_conci_becalos(
        fecha    date,
        transac  char(4),
        folio    char(16),
        cuenta   char(20),
        monto    decimal(14,2),
        transac2 char(4),
        cuenta2  char(20),
        monto2   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_conci_becalos_folio on "informix".sc_trxs_conci_becalos(folio) online;
    update statistics medium for table sc_trxs_conci_becalos;

    INSERT INTO sc_trxs_conci_becalos
    select a.fecha, a.transac, a.folio, a.cuenta, a.monto, b.transac, b.cuenta, b.monto
     from sc_trxs_0450 a,
          sc_trxs_0453 b
    where a.folio = b.folio;

   INSERT INTO sc_trxs_conci_becalos
   SELECT fecha, transac, folio, cuenta, monto, " ", " ", 0.00
     FROM sc_trxs_0450_nc;

   INSERT INTO sc_trxs_conci_becalos
   SELECT fecha, transac, folio, cuenta, monto, " ", " ", 0.00
     FROM sc_trxs_0453_nc;
	
	SELECT SUM(monto2)
		INTO mMonto_spei
     FROM sc_trxs_conci_becalos
	WHERE transac2 = '0453';
    --- Sftk Mar2014
    
    --- Sftk Mar2014
    /*FOREACH 
        select a.fecha, a.transac, a.folio, a.cuenta, a.monto, b.transac, b.cuenta, b.monto
          into dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2
          from sc_trxs_0450 a,
               sc_trxs_0453 b
         where a.folio = b.folio
           
        INSERT INTO sc_trxs_conci_becalos VALUES(dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2);
    END FOREACH;
	
	
    FOREACH
        SELECT fecha, transac, folio, cuenta, monto, " ", " ", 0.00
          INTO dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2
          FROM sc_trxs_0450_nc
          
        INSERT INTO sc_trxs_conci_becalos VALUES(dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2);
    END FOREACH;
    
    FOREACH
        SELECT fecha, transac, folio, cuenta, monto, " ", " ", 0.00
          INTO dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2
          FROM sc_trxs_0453_nc
          
        INSERT INTO sc_trxs_conci_becalos VALUES(dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2);
    END FOREACH;*/

    
	
	LET vnombrearchivo = 'conchedonaciones_becalos_'||vfecha2||'.txt';
	
	LET vsql = '';
	LET vsql = 'echo "transaccion|cuenta|folio|fecha|monto|transaccion|cuenta|folio|fecha|monto">/RESPALDOSNEW/HEADERSconchedonaciones_becalos.txt';
	system vsql;
	
	LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/CONTENIDOconchedonaciones_becalos_'||vfecha2||'.txt '||
			   'SELECT transac, cuenta, folio, fecha, monto, transac2, cuenta2, folio, fecha, monto2 '||
               'FROM sc_trxs_conci_becalos '||
              'ORDER BY fecha, folio;" > /RESPALDOSNEW/conchedonaciones.sql';
    SYSTEM vsql;
    LET vsql = '';
        
    LET vstmt = '';
	LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/conchedonaciones.sql";
    --LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/conchedonaciones.sql"; --REVISAR PERMISOS
    SYSTEM vstmt;
    LET vstmt = '';
	
	LET vsql ='';
	LET vsql = "sed 's/|$//g' /RESPALDOSNEW/HEADERSconchedonaciones_becalos.txt >>/RESPALDOSNEW/"||vnombrearchivo;
	system vsql;
	
	LET vsql ='';
	LET vsql = "sed 's/|$//g' /RESPALDOSNEW/CONTENIDOconchedonaciones_becalos_"||vfecha2||".txt  >>/RESPALDOSNEW/"||vnombrearchivo;
	system vsql;
	
	LET vsql ='';
	LET vsql ="rm /RESPALDOSNEW/HEADERSconchedonaciones_becalos.txt";
	system vsql;
	
	LET vsql ='';
	LET vsql ="rm /RESPALDOSNEW/CONTENIDOconchedonaciones_becalos_"||vfecha2||".txt";
	system vsql;	
		

		
	-- Borrar tablas e indices
	
	drop index "informix".idx_trxs_0450_folio;
	drop table "informix".sc_trxs_0450;
	drop index "informix".idx_trxs_0453_folio;
	drop table "informix".sc_trxs_0453;
	drop index "informix".idx_trxs_0450_nc_folio;
	drop table "informix".sc_trxs_0450_nc;
	drop index "informix".idx_trxs_0453_nc_folio;
	drop table "informix".sc_trxs_0453_nc;
	drop index "informix".idx_trxs_conci_becalos_folio;
	drop table "informix".sc_trxs_conci_becalos;

	IF mMonto_spei > 0 THEN
      
    -- // TRANSFERENCIA SPEI
		LET cCuentaOrden = '99000000473';
		LET cCuentaOrdenSPEI = '137180990000004734';
		LET cNombreOrdenSPEI = 'BANCOPPEL S.A.';
		LET cRFCOrdenSPEI = 'BSI070527HDF';
		LET cSucursalSPEI = '9250';
		LET iBancoDestinoSPEI = 40014;
		LET dFechaCapturaSPEI = CURRENT;
		LET iTipoPagoSPEI = 1;
		LET iTipoOperacionSPEI = 0;
		LET mImporteOperacionSPEI = mMonto_spei;
		LET cNombreBeneficiarioSPEI = 'BECALOS';
		LET cCuentaBeneficiarioSPEI = '014180655019849759';
		LET cRFCBeneficiarioSPEI = 'BEC061030Q4A';
		LET mImporteIVASPEI = 0.0;
		LET dReferenciaNumero = 0;
		LET cReferenciaCobranza1SPEI = '';
		LET cConceptoPagoSPEI = 'TRANSFERENCIA DONATIVOS';
		LET cClavePagoSPEI = '';
		LET cNombreBeneficiario2SPEI = '';
		LET cCuentaBeneficiario2SPEI = '';
		LET cRFCBeneficiario2SPEI = '';
		LET cConceptoPago2SPEI = 'TRANSFERENCIA DONATIVOS';
		LET cTransaccionSPEI = '0274';
		LET iTipoCuentaOrdenSPEI = 40;
		LET iTipoCuentaBeneficiarioSPEI = 40;
    
		EXECUTE PROCEDURE bdispei:sp_obtfoliosuc("informix") 
		INTO cCodRetSp, iSerialFolioSPEI, cFolioSucursalSPEI;
    
		IF cCodRetSp = '000' THEN
            -- // REALIZA EL CARGO A LA CUENTA DE CHEQUES
			EXECUTE PROCEDURE cargo_ref(pempresa, cSucursalSPEI, "informix", cTransaccionSPEI, '0000', cFolioSucursalSPEI, cCuentaOrden, 0, mImporteOperacionSPEI, '01', cCveRastreo, '', "informix")
			INTO cCodRetCgo, cTrxCgo, dFechaCgo, mSdoDispCgo, mMontoCgo;
            
			IF cCodRetCgo <> '000' THEN
				LET vcodret1 = cCodRetCgo; 
				RETURN vcodret1;
			END IF;
				
			-- // EJECUTA LA TRANSFERENCIA SPEI
			EXECUTE PROCEDURE bdispei:sp_regordenpagospei_pp( pempresa, "informix", cSucursalSPEI, cFolioSucursalSPEI, iBancoDestinoSPEI, dFechaCapturaSPEI, iTipoPagoSPEI, 
															iTipoOperacionSPEI, mImporteOperacionSPEI, cNombreOrdenSPEI, cCuentaOrdenSPEI, cRFCOrdenSPEI, cNombreBeneficiarioSPEI, 
															cCuentaBeneficiarioSPEI, cRFCBeneficiarioSPEI, mImporteIVASPEI, dReferenciaNumero, cReferenciaCobranza1SPEI, 
															cConceptoPagoSPEI, cClavePagoSPEI, cNombreBeneficiario2SPEI, cCuentaBeneficiario2SPEI, cRFCBeneficiario2SPEI,
															cConceptoPago2SPEI, cTransaccionSPEI, iTipoCuentaOrdenSPEI, iTipoCuentaBeneficiarioSPEI )
			INTO cCodRetSp, cMensajeError, cCveRastreo;
        
			IF cCodRetSp <> '000' THEN
				LET vcodret1 = cCodRetSp; 
				RETURN vcodret1;
			END IF;
			
			UPDATE bdicheq:sc_movdia SET referencia = cCveRastreo
			 WHERE folio_suc = cFolioSucursalSPEI; 
			
		ELSE
			LET vcodret1 = cCodRetSp;
			RETURN vcodret1;
		END IF;
	END IF;
	
	-- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = dFechaHoy
     where empresa = pempresa
       and proceso = vproceso;

    END;
    
    RETURN vcodret1;
    
END PROCEDURE;
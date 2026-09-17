CREATE PROCEDURE "informix".sp_reporte_concilia_seguros()
RETURNING CHAR(5);

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
    DEFINE vsql         CHAR(1900);
	DEFINE vsqlike      CHAR(1900);
    DEFINE vstmt        CHAR(300);
	DEFINE vstmtike     CHAR(300);
    DEFINE vexiste      SMALLINT;
    DEFINE dFechaHoy    DATE;
    DEFINE vfecha_hoy DATE;
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
	DEFINE vnombrearchivoike CHAR(100);
	DEFINE vnombrearchivospei CHAR(100);
	DEFINE pEmpresa		CHAR(3);
    DEFINE vfecharep_inistatike        DATETIME YEAR TO FRACTION(5);
    DEFINE vfecharep_finstatike        DATETIME YEAR TO FRACTION(5);  
    
     
    -- // VARIABLES CARGO EN CUENTA 
    DEFINE cCodRetCgo CHAR(5);
    DEFINE cTrxCgo CHAR(4);
    DEFINE dFechaCgo DATE;
    DEFINE mSdoDispCgo DECIMAL(14,2);
    DEFINE mMontoCgo DECIMAL(14,2);
    
	DEFINE vfechaproc DATE;
	DEFINE vproceso CHAR(20);
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
	LET vsqlike     = '';
	LET vstmtike    = '';
    LET vstmt       = '';
    LET vexiste     = 0;
    LET dFechaHoy   = '';
    LET dFechaAnt   = '';
	LET vfecha_hoy  = '';
    LET dFecha      = '';
    LET cFolio      = '';
    LET cTransac    = '';
    LET cCuenta     = '';
    LET mMonto      = 0.00;
    LET cTransac2   = '';
    LET cCuenta2    = '';
    LET mMonto2     = 0.00;
	LET mMonto_spei = 0.00;
	LET pEmpresa	= '001';
    
    
    -- // VARIABLES CARGO EN CUENTA
    LET cCodRetCgo = '';
    LET cTrxCgo = '';
    LET dFechaCgo = '';
    LET mSdoDispCgo = 0.00;
    LET mMontoCgo = 0.00;
	
	LET vnombrearchivo = '';
	LET vnombrearchivospei = '';
	
	LET vproceso  = "concirepsegatm";
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/RESPALDOSNEW/sp_concilia_seguros.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/c94796696/sp_concilia_seguros.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO dFechaHoy, dFechaAnt
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
	LET vfecha2 = TO_CHAR(dFechaAnt, '%d%m%Y');

	let vfecharep_inistatike = dFechaHoy;
	let vfecharep_inistatike= SUBSTRING(vfecharep_inistatike FROM  1 FOR 10) || ' 00:00:00';


	let vfecharep_finstatike = dFechaHoy;
	let vfecharep_finstatike = SUBSTRING(vfecharep_inistatike FROM  1 FOR 10) || ' 23:59:59';
	
	-- // EJECUTA LA TRANSFERENCIA SPEI
	/*		EXECUTE PROCEDURE sp_concilia_seguro_atm()
			INTO vcodret4;
        
			IF vcodret4 <> '000' THEN
				LET vcodret1 = vcodret4; 
				RETURN vcodret1;
			END IF;
	*/
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
	
    -- // TRANSACCIONES 0394
    select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0394';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0394;        
    end if;
    
    create table "informix".sc_trxs_0394(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0394_folio on "informix".sc_trxs_0394(folio) online;
    update statistics medium for table sc_trxs_0394;
    
    FOREACH 
        select fech_alt, folio_suc, transacc, cuenta, monto_tot 
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_movhis
         where transacc = "0394"
           and fech_alt >= dFechaAnt
           and cancelad <> "S"
           
        INSERT INTO sc_trxs_0394 VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH;
    
    -- // TRANSACCIONES 0393
    select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0393';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0393;        
    end if;
    
    create table "informix".sc_trxs_0393(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0393_folio on "informix".sc_trxs_0393(folio) online;
    update statistics medium for table sc_trxs_0393;
    
    FOREACH 
        select fech_alt, folio_suc, transacc, cuenta, monto_tot 
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_movhis
         where transacc = "0393"
           and fech_alt >= dFechaAnt
           and cancelad <> "S"
           
        INSERT INTO sc_trxs_0393 VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH;
    
    -- // TRANSACCIONES 0394 NO CONCILIADAS
    select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0394_nc';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0394_nc;        
    end if;
    
    create table "informix".sc_trxs_0394_nc(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0394_nc_folio on "informix".sc_trxs_0394_nc(folio) online;
    update statistics medium for table sc_trxs_0394_nc;
    
    FOREACH 
        select fecha, folio, transac, cuenta, monto 
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_trxs_0394
         where folio not in(select folio from sc_trxs_0393)
           
        INSERT INTO sc_trxs_0394_nc VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH;
    
    -- // TRANSACCIONES 0393 NO CONCILIADAS
    select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_0393_nc';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_0393_nc;        
    end if;
    
    create table "informix".sc_trxs_0393_nc(
        fecha   date,
        folio   char(16),
        transac char(4),
        cuenta  char(20),
        monto   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_0393_nc_folio on "informix".sc_trxs_0393_nc(folio) online;
    update statistics medium for table sc_trxs_0393_nc;
    
    FOREACH 
        select fecha, folio, transac, cuenta, monto
          into dFecha, cFolio, cTransac, cCuenta, mMonto
          from sc_trxs_0393
         where folio not in(select folio from sc_trxs_0394)
           
        INSERT INTO sc_trxs_0393_nc VALUES(dFecha, cFolio, cTransac, cCuenta, mMonto);
    END FOREACH;
      
    -- // TRANSACCIONES CONCILIADAS
    select count(*) 
      into vexiste
      from sysmaster:systabnames 
     where partnum > 0 
       and tabname = 'sc_trxs_conci_seguro';
    
    if vexiste > 0 then
        drop table "informix".sc_trxs_conci_seguro;        
    end if;
    
    create table "informix".sc_trxs_conci_seguro(
        fecha    date,
        transac  char(4),
        folio    char(16),
        cuenta   char(20),
        monto    decimal(14,2),
        transac2 char(4),
        cuenta2  char(20),
        monto2   decimal(14,2) 
    ) extent size 32 next size 32 lock mode row;
    
    create index "informix".idx_trxs_conci_seguro_folio on "informix".sc_trxs_conci_seguro(folio) online;
    update statistics medium for table sc_trxs_conci_seguro;
    
    FOREACH 
        select a.fecha, a.transac, a.folio, a.cuenta, a.monto, b.transac, b.cuenta, b.monto
          into dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2
          from sc_trxs_0394 a,
               sc_trxs_0393 b
         where a.folio = b.folio
           
        INSERT INTO sc_trxs_conci_seguro VALUES(dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2);
    END FOREACH;
	
	
    FOREACH
        SELECT fecha, transac, folio, cuenta, monto, " ", " ", 0.00
          INTO dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2
          FROM sc_trxs_0394_nc
          
        INSERT INTO sc_trxs_conci_seguro VALUES(dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2);
    END FOREACH;
    
    FOREACH
        SELECT fecha, transac, folio, cuenta, monto, " ", " ", 0.00
          INTO dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2
          FROM sc_trxs_0393_nc
          
        INSERT INTO sc_trxs_conci_seguro VALUES(dFecha, cTransac, cFolio, cCuenta, mMonto, cTransac2, cCuenta2, mMonto2);
    END FOREACH;
	
	/*SELECT SUM(monto2)
		INTO mMonto_spei
     FROM sc_trxs_conci_seguro
	WHERE transac2 = '0393';*/
	
	
	/*REPORTE CONCILIACION */
	
	
	LET vnombrearchivo = 'concheseguros_'||vfecha2||'.txt';
	
	LET vsql = '';
	LET vsql = 'echo "transaccion|cuenta|folio|fecha|monto|transaccion|cuenta|folio|fecha|monto">/RESPALDOSNEW/HEADERSconcheseguros.txt';
	system vsql;
	
	LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/CONTENIDOconcheseguros'||vfecha2||'.txt '||
			   'SELECT transac, cuenta, folio, fecha, monto, transac2, cuenta2, folio, fecha, monto2 '||
               'FROM sc_trxs_conci_seguro '||
               'ORDER BY folio;" > /RESPALDOSNEW/concheseguros.sql';
    SYSTEM vsql;
    LET vsql = '';
        
    LET vstmt = '';
	LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/concheseguros.sql";
    SYSTEM vstmt;
    LET vstmt = '';
	
	LET vsql ='';
	LET vsql = "sed 's/|$//g' /RESPALDOSNEW/HEADERSconcheseguros.txt >>/RESPALDOSNEW/"||vnombrearchivo;
	system vsql;
	
	LET vsql ='';
	LET vsql = "sed 's/|$//g' /RESPALDOSNEW/CONTENIDOconcheseguros"||vfecha2||".txt  >>/RESPALDOSNEW/"||vnombrearchivo;
	system vsql;
	
	LET vsql ='';
	LET vsql ="rm /RESPALDOSNEW/HEADERSconcheseguros.txt";
	system vsql;
	
	LET vsql ='';
	LET vsql ="rm /RESPALDOSNEW/CONTENIDOconcheseguros"||vfecha2||".txt";
	system vsql;
	
	
	
		/*REPORTE CONCILIACION IKE*/
		
		
	
	LET vnombrearchivoike = 'BANCOPPEL_ATM_'||vfecha2||'.txt';
	
	LET vsqlike = '';
	LET vsqlike = 'echo "Fecha_transaccion|nombre1|nombre2|apell_paterno|apell_materno|hora_transaccion|monto_retiro|id_atm|tarjeta|folio">/RESPALDOSNEW/HEADERSreporte_ike.txt';
	system vsqlike;
	LET vsqlike = '';

	
		
	  LET vsqlike = 'echo "SET ISOLATION TO DIRTY READ; '||
             'UNLOAD TO /RESPALDOSNEW/CONTENIDOreporteike'||vfecha2||'.txt '||
			 'select a.fecha,TRIM(c.nombre1),TRIM(c.nombre2),TRIM(c.apell_paterno),TRIM(c.apell_materno),SUBSTR (e.fech_hor,1,8),a.monto,a.numcajero,SUBSTR (a.numtarjeta,13,16) as tarjeta, e.folio_suc '||
			 'from intercard:conciliacion_atm_stat06 as a , bdicheq:sc_tarjeta as b , bdinteg:si_cliente as c, sc_movhis as e '||
			 'where  fechaconciliacion between '''||vfecharep_inistatike||''' and '''||vfecharep_finstatike||''''||
			 'and comision_usolinea >"0" '||
			 'and compania in (''VDE'',''MDE'') '||
			 'and archivoorigen =''IST'' '||
			 'and indicadordereversa <> ''REVERSAL'' '||
			 'and b.numcte=c.numcte  '||
			 'and a.numcuenta=b.cuenta '||
			 'and a.numcuenta = e.cuenta '||
			 'and a.arpc = e.folio_suc '||
			 'and b.empresa=''001'' '||
			 'and e.fech_alt  >= '||dFechaAnt||' '||
			 'and e.cuenta <> ''99000000490'' '||
			 'and a.numtarjeta=b.num_tarjeta '||
			 'and e.transacc=''0394'' '||
			 'and a.comision_usolinea = e.monto_tot '||
			 'ORDER by e.fech_hor;"> /RESPALDOSNEW/reporte_bancoppel_ike.sql';
	 
	 
	  
	SYSTEM vsqlike;
    LET vsqlike = '';
        
    LET vstmtike = '';
	LET vstmtike = "dbaccess bdicheq /RESPALDOSNEW/reporte_bancoppel_ike.sql";
    --LET vstmtike = "/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/reporte_bancoppel_ike.sql"; 
    SYSTEM vstmtike;
    LET vstmtike = '';
	
	LET vsqlike ='';
	LET vsqlike = "sed 's/|$//g' /RESPALDOSNEW/HEADERSreporte_ike.txt >>/RESPALDOSNEW/"||vnombrearchivoike;
	system vsqlike;
	
	LET vsqlike ='';
	LET vsqlike = "sed 's/|$//g' /RESPALDOSNEW/CONTENIDOreporteike"||vfecha2||".txt  >>/RESPALDOSNEW/"||vnombrearchivoike;
	system vsqlike;
	
	LET vsqlike ='';
	LET vsqlike ="rm /RESPALDOSNEW/HEADERSreporte_ike.txt";
	system vsqlike;
	
	LET vsqlike ='';
	LET vsqlike ="rm /RESPALDOSNEW/CONTENIDOreporteike"||vfecha2||".txt";
	system vsqlike;
				  
			

		/*REPORTE SPEI IKE*/	

	LET vnombrearchivospei = 'ReporteSPEIseguro_'||vfecha2||'.txt';
	
	LET vsql = '';
	LET vsql = 'echo "fecha|hora|transaccion|referencia|monto|folio_suc">/RESPALDOSNEW/HEADERSspeiseguros.txt';
	system vsql;
	
	LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               'UNLOAD TO /RESPALDOSNEW/CONTENIDOspeiseguros'||vfecha2||'.txt '||
			   'SELECT fech_oper, SUBSTR (fech_hor,1,8), transacc, referencia, monto_tot, folio_suc '||
               'FROM sc_movdia '||
			   'WHERE cuenta = ''99000000490'' '||
			   'AND transacc = ''0274''; " > /RESPALDOSNEW/speiseguros.sql';
	
	SYSTEM vsql;
    LET vsql = '';
        
    LET vstmt = '';
	LET vstmt = "dbaccess bdicheq /RESPALDOSNEW/speiseguros.sql";
    SYSTEM vstmt;
    LET vstmt = '';
	
	LET vsql ='';
	LET vsql = "sed 's/|$//g' /RESPALDOSNEW/HEADERSspeiseguros.txt >>/RESPALDOSNEW/"||vnombrearchivospei;
	system vsql;
	
	LET vsql ='';
	LET vsql = "sed 's/|$//g' /RESPALDOSNEW/CONTENIDOspeiseguros"||vfecha2||".txt  >>/RESPALDOSNEW/"||vnombrearchivospei;
	system vsql;
	
	LET vsql ='';
	LET vsql ="rm /RESPALDOSNEW/HEADERSspeiseguros.txt";
	system vsql;
	
	LET vsql ='';
	LET vsql ="rm /RESPALDOSNEW/CONTENIDOspeiseguros"||vfecha2||".txt";
	system vsql;
	


 /* %%%%%%%%%%%%%%%%%%%%%%%% */		
	
	
	-- Borrar tablas e indices
	
	drop index "informix".idx_trxs_0394_folio;
	drop table "informix".sc_trxs_0394;
	drop index "informix".idx_trxs_0393_folio;
	drop table "informix".sc_trxs_0393;
	drop index "informix".idx_trxs_0394_nc_folio;
	drop table "informix".sc_trxs_0394_nc;
	drop index "informix".idx_trxs_0393_nc_folio;
	drop table "informix".sc_trxs_0393_nc;
	drop index "informix".idx_trxs_conci_seguro_folio;
	drop table "informix".sc_trxs_conci_seguro;
	
	-- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = dFechaHoy
     where empresa = pempresa
       and proceso = vproceso;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;
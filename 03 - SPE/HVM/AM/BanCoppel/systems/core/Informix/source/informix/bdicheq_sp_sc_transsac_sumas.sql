CREATE PROCEDURE "informix".sp_sc_transsac_sumas()
	RETURNING CHAR(5)	AS codigo_retorno,
			  CHAR(80)	AS mensaje_retorno;

	---DECLARACIONES   
	DEFINE cCodRet				CHAR(5); 
	DEFINE cMensajeRet			CHAR(80);	
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);
	DEFINE iNoRegsProcesados 	INTEGER;
	DEFINE cEmpresa 			CHAR(3);
	
	DEFINE dFechaAlt			DATE;
	DEFINE cTransacc			CHAR(4);
	DEFINE cProducto			CHAR(4);
	DEFINE cDescripcion			CHAR(50);
	DEFINE iNumRegistros		INTEGER;
	DEFINE mMontoSumado			MONEY(18,2);
	DEFINE cCuentaCargo			CHAR(30);
	DEFINE cCuentaAbono			CHAR(30);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cMensajeRet			= 'PROCESO EJECUTADO CORRECTAMENTE';
	LET iNoRegsProcesados   = 0;
	LET cEmpresa 			= '001';
	
	LET dFechaAlt		= '';
	LET cTransacc		= '';
	LET cProducto		= '';
	LET cDescripcion	= '';
	LET iNumRegistros	= 0;
	LET mMontoSumado	= 0;
	LET cCuentaCargo	= '';
	LET cCuentaAbono	= '';
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;
				RETURN cCodRet, cMensajeRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sc_transsac_sumas.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT mhis.fech_alt
				,mhis.transacc
				,mhis.producto
				,trans.descripcion
				,COUNT(mhis.producto) AS numeroRegistros
				,SUM(monto_tot) AS montoSumado
				,(TRIM(ptran.c_ccmayor) || TRIM(ptran.c_ccsub) || TRIM(ptran.c_ccsubsub) || TRIM(ptran.c_ccsssub) || TRIM(ptran.c_ccssssub) || TRIM(ptran.c_sector)) AS cuentaCargo
				,(TRIM(ptran.a_ccmayor) || TRIM(ptran.a_ccsub) || TRIM(ptran.a_ccsubsub) || TRIM(ptran.a_ccsssub) || TRIM(ptran.a_ccssssub) || TRIM(ptran.a_sector)) AS cuentaAbono
				INTO dFechaAlt, cTransacc, cProducto, cDescripcion, iNumRegistros, mMontoSumado, cCuentaCargo, cCuentaAbono
			FROM bdicheq:"informix".sc_movhis AS mhis
			INNER JOIN bdinteg: "informix".si_transacc AS trans ON mhis.transacc = trans.numero
			INNER JOIN bdinteg: "informix".si_prodtran AS ptran ON mhis.transacc = ptran.transaccion
				AND mhis.producto = ptran.producto 
			WHERE mhis.fech_alt = (SELECT fecha_ant FROM bdicheq:"informix".sc_fechas WHERE empresa = cEmpresa)
				AND mhis.cancelad != 'S'
				AND trans.sistema = '01'
				AND trans.se_contabiliza = 'S'
				AND ptran.sistema = '01'
			GROUP BY mhis.fech_alt,mhis.transacc,mhis.producto,trans.descripcion,cuentaCargo,cuentaAbono
			
			INSERT INTO bdicheq:"informix".sc_transsac_sumas(fecha_alt, transaccion, producto, descripcion, numero_registros, monto_sumado, cuenta_cargo, cuenta_abono) 
			VALUES(dFechaAlt, cTransacc, cProducto, cDescripcion, iNumRegistros, mMontoSumado, cCuentaCargo, cCuentaAbono);
	
			LET iNoRegsProcesados = iNoRegsProcesados + DBINFO('sqlca.sqlerrd2');
						
		END FOREACH;		
  
		RETURN cCodRet, cMensajeRet;
		
	END
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 12/09/2019',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: SumarizaciÃ³n de Transacciones', 
'DESCRIPCION: SPL para Control-M encargado de realizar inserciÃ³n de datos de tabla sc_movhis a tabla sc_transsac_sumas por fecha_hoy de sc_fechas',
'BD: bdicheq';

CREATE PROCEDURE "informix".sdos_diarios()
RETURNING CHAR(5);

    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;  
    DEFINE visamerr     INTEGER;  
    DEFINE vdescerr     CHAR(50);
    DEFINE vsql         CHAR(600);
    DEFINE vfecha       DATE; 
    DEFINE vaniomes     CHAR(6);
    DEFINE vdia         CHAR(2);
    DEFINE vcodret4     CHAR(5);
    DEFINE vfecha_hoy   DATE;
    DEFINE vexiste      SMALLINT;
    DEFINE vstatus      CHAR(1);

    LET vcodret  = "000";
    LET vcodret2 = "";
    LET vcodret3 = "";
    LET vsqlerr  = 0;
    LET visamerr = 0;
    LET vdescerr = '';
    LET vsql     = '';
    LET vfecha   = '';
    LET vaniomes = '';
    LET vdia     = '';
    LET vcodret4 = '';
    LET vfecha_hoy = '';
    LET vexiste  = 0;
    LET vstatus  = '2';

    --- SET DEBUG FILE TO "sdos_diarios.out";
    --- TRACE ON;  

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "sdos_diarios.err";
        TRACE ON; 
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;

    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha
      FROM sc_fechas
     WHERE empresa = "001";

    LET vdia = SUBSTR(vfecha,4,2);
    LET vdia = vdia;
    
    LET vaniomes = SUBSTR(vfecha,7,4) || SUBSTR(vfecha,1,2);
    LET vaniomes = vaniomes;
    
    SELECT COUNT(*)
      INTO vexiste
      FROM sysmaster:systabnames 
     WHERE partnum > 0 
       AND tabname = 'sc_ctas_canc';
       
    IF vexiste > 0 THEN
        DROP TABLE "informix".sc_ctas_canc;
    END IF;

    CREATE TABLE "informix".sc_ctas_canc( cuenta char(20) )
    EXTENT SIZE 500 NEXT SIZE 250 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctas_canc ON "informix".sc_ctas_canc(cuenta) ONLINE;
    
    INSERT INTO sc_ctas_canc
    SELECT {+INDEX(sc_maechq idx_sc_maechq2)} cuenta 
      FROM sc_maechq
     WHERE status_cta = '2'
       AND fec_cancelac = vfecha_hoy;
       
    UPDATE STATISTICS HIGH FOR TABLE sc_ctas_canc;
    
    
    IF LPAD(vdia,2,'0') = '01' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig1, sdo.intprovnp1, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ELIF LPAD(vdia,2,'0') = '02' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig2, sdo.intprovnp2, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '03' THEN
      
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig3, sdo.intprovnp3, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '04' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig4, sdo.intprovnp4, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '05' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig5, sdo.intprovnp5, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '06' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig6, sdo.intprovnp6, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '07' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig7, sdo.intprovnp7, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        
        LET vsql = "";
        
    ElIf LPAD(vdia,2,'0') = '08' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig8, sdo.intprovnp8, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '09' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig9, sdo.intprovnp9, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '10' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig10, sdo.intprovnp10, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;      
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '11' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig11, sdo.intprovnp11, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '12' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig12, sdo.intprovnp12, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '13' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig13, sdo.intprovnp13, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '14' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig14, sdo.intprovnp14, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '15' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig15, sdo.intprovnp15, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '16' THEN
         
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig16, sdo.intprovnp16, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '17' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig17, sdo.intprovnp17, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '18' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig18, sdo.intprovnp18, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '19' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig19, sdo.intprovnp19, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '20' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig20, sdo.intprovnp20, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '21' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig21, sdo.intprovnp21, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '22' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig22, sdo.intprovnp22, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";
        
    ElIf LPAD(vdia,2,'0') = '23' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig23, sdo.intprovnp23, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '24' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig24, sdo.intprovnp24, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '25' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig25, sdo.intprovnp25, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '26' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig26, sdo.intprovnp26, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '27' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig27, sdo.intprovnp27, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '28' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig28, sdo.intprovnp28, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '29' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig29, sdo.intprovnp29, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '30' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig30, sdo.intprovnp30, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '31' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/sc_sdocierre.unl '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.num_cte, noc.ejecutivo, noc.fecha_alta, fech.fecha_ant, sdo.capvig31, sdo.intprovnp31, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, sc_maechq mae, sc_maenoc noc, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta '||
                   'AND sdo.aniomes = '''||vaniomes||''' '||
                   'AND (mae.status_cta <> '''||vstatus||''' OR (mae.cuenta IN(SELECT cuenta FROM sc_ctas_canc))) '||
                   'AND noc.cuenta = mae.cuenta '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        
        LET vsql = "";

    ELSE

        LET vcodret = '200';  -- // FECHA INVALIDA

    END IF;

    END;

    RETURN vcodret;

END PROCEDURE;
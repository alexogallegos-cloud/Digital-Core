CREATE PROCEDURE "informix".sdos_diarios_inv()
RETURNING CHAR(5);

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;  
    DEFINE visamerr         INTEGER;  
    DEFINE vdescerr         VARCHAR(50);  
    DEFINE vsql             LVARCHAR(700);
    DEFINE vfecha           VARCHAR(10);
    DEFINE vdia             VARCHAR(2);
    DEFINE vmes             VARCHAR(2);
    DEFINE vanio            VARCHAR(4);
    DEFINE vaniomes         VARCHAR(6);
    DEFINE vfechades        VARCHAR(8);
	DEFINE vEmpresa			VARCHAR(3);
	DEFINE vdiavalor        VARCHAR(2);
	DEFINE vcv_dia          VARCHAR(10);
	DEFINE vipa_dia			VARCHAR(11);
	
	DEFINE dFecha 			DATE;
	DEFINE vSucursal 		VARCHAR(4);
	DEFINE vCuenta 			VARCHAR(20);
	DEFINE vNum_cte 		VARCHAR(20);
	DEFINE dFech_cap 		DATE;
	DEFINE ddCapital 		DECIMAL(18,2);
	DEFINE ddInteres 		DECIMAL(18,2);
	DEFINE iSecuencia       INTEGER;
	
	--DEFINE vcomienza        SMALLINT;
	--DEFINE ven_transacc     SMALLINT;
	--DEFINE vcontador        INTEGER;
	DEFINE RUTA_UNLOAD_RESPALDOS 	VARCHAR(80);
	DEFINE NOMBRE_ARCHIVO_UNIVERSO 	VARCHAR(100);
	DEFINE RUTA_UNLOAD 				VARCHAR(80);
	DEFINE RUTA_ORIGEN 				VARCHAR(80);
	DEFINE SCRIPT_EJECUCION_UNIVERSO VARCHAR(50);
	DEFINE PREFIJO_ARCHIVO_INSERT 	VARCHAR(12);
	DEFINE CONTADOR_TRANSACCIONES 	INTEGER;
	DEFINE cRutaInformix 			VARCHAR(100);
	DEFINE vRutadbload 				VARCHAR (21);

    LET vcodret  = '000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET vsqlerr  = 0;
    LET visamerr = 0;
    LET vdescerr = '';
    LET vsql     = '';
    LET vfecha   = '';
    LET vdia     = '';
    LET vmes     = '';
    LET vanio    = '';
    LET vaniomes = '';
    LET vfechades = '';
	LET vEmpresa = '001';
	LET vdiavalor = '';
	LET vcv_dia = '';
    LET vipa_dia ='';
	
	
	LET dFecha = '';
	LET vSucursal = '';
	LET vCuenta = '';
	LET vNum_cte = '';
	LET dFech_cap = '';
	LET ddCapital = 0.00;
	LET ddInteres = 0.00;
	LET iSecuencia = 0;
	
    --LET vcomienza    = -1;
	--LET ven_transacc = 0;
	--LET vcontador    = 0;
	LET RUTA_UNLOAD_RESPALDOS ='';
	LET NOMBRE_ARCHIVO_UNIVERSO = 'file_sv_provdia_sv_maeinv';
	LET RUTA_UNLOAD = '/resplogifx/conciliachq/';
	LET RUTA_ORIGEN = '/resplogifx/conciliachq/';
	LET SCRIPT_EJECUCION_UNIVERSO = 'script_sv_provdia_sv_maeinv.sql';
	LET PREFIJO_ARCHIVO_INSERT = 'insert_provdia_sv_maeinv';
	LET CONTADOR_TRANSACCIONES = 1000;
	LET cRutaInformix = '/ifxsif01/bin/';
	LET vRutadbload = '/ifxsif01/bin/dbload';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 2;
		
		
	--SET DEBUG FILE TO "/resplogifx/conciliachq/SPL_CONCILIAINV/sdos_diarios_inv.out";
    --TRACE ON;  

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
		
		SELECT fecha_ant
		  INTO vfecha
		  FROM bdinvers:sv_fechas
		 WHERE empresa = '001';
		 
		--LET vfecha = '09/30/2025';

		--LET vdiavalor  = (SELECT DAY(fecha_ant - 4) FROM bdinvers:sv_fechas WHERE empresa = '001');
		LET vdiavalor  = (SELECT DAY(fecha_ant) FROM bdinvers:sv_fechas WHERE empresa = '001');
		LET vdia  = SUBSTR(vfecha,4,2);
		LET vdia  = vdia;
		LET vmes  = SUBSTR(vfecha,1,2);
		LET vanio = SUBSTR(vfecha,7,4);
		
		LET vmes  = vmes;
		LET vanio = vanio;
		LET vaniomes = vanio||vmes;
		LET vfechades = vmes||vdia||vanio;
		
		LET vcv_dia ='a.cv_dia'||vdiavalor;
		LET vipa_dia ='a.ipa_dia'||vdiavalor;

        /*LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/SPL_CONCILIAINV/sdoarchinv_'||vfechades||'.unl'||
                   ' select a.sucursal,a.cuenta,c.num_cte,b.fecha_ant,a.cv_dia1,a.ipa_dia1,a.secuencia'||
                   ' from sv_provdia a, sv_fechas b, sv_maeinv c'||
                   ' where a.empresa = b.empresa and a.aniomes = '||vaniomes||' and a.cuenta = c.cuenta'||
                   ' and a.secuencia = c.secuencia and a.cv_dia1 is not null and a.ipa_dia1 is not null'||
                   ' and c.fecha_venc > b.fecha_ant order by cuenta;" > /resplogifx/conciliachq/SPL_CONCILIAINV/sdosinv.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/SPL_CONCILIAINV/sdosinv.sql";
        SYSTEM vsql;
        LET vsql = "";*/
		
		
		--UNLOAD PARA GENERAR ARCHIVO sdoarchinv_mmddyyyy
		--INICIO
		LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/sdoarchinv_'||vfechades||'.unl'||
                   ' select a.sucursal,a.cuenta,c.num_cte,(select fecha_ant from bdinvers:sv_fechas'||
                    ' where empresa= \"'||vEmpresa||'\")'||
					',a.cv_dia'||vdiavalor||',a.ipa_dia'||vdiavalor||',a.secuencia'||
                   ' from bdinvers:sv_provdia a, bdinvers:sv_maeinv c'||
                   ' where a.aniomes = \"'||vaniomes||'\"'||
				   ' and a.cuenta = c.cuenta and a.secuencia = c.secuencia'||
					' and '||vcv_dia ||' is not null '||
					' and '||vipa_dia||' is not null '||
					' and c.fecha_venc > \"'||vfecha||'\"'||' order by cuenta;" > /resplogifx/conciliachq/sdosinv.sql';
					
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/sdosinv.sql";
        SYSTEM vsql;
		LET vsql = "rm /resplogifx/conciliachq/sdosinv.sql";
        SYSTEM vsql;
        LET vsql = "";
		--FIN
		
		
        /*INSERT INTO sv_sdosdiarios
        SELECT b.fecha_ant, a.sucursal, a.cuenta, c.num_cte, b.fecha_ant, a.cv_dia1, a.ipa_dia1, a.secuencia
          FROM sv_provdia a, 
               sv_fechas b, 
               sv_maeinv c
         WHERE a.empresa = b.empresa 
           AND a.aniomes = vaniomes 
           AND a.cuenta = c.cuenta
           AND a.secuencia = c.secuencia 
           AND a.cv_dia1 is not null 
           AND a.ipa_dia1 is not null
           AND c.fecha_venc > b.fecha_ant 
         ORDER BY cuenta;*/
		 
		LET vcv_dia = vcv_dia;
		LET vipa_dia = vipa_dia;
		LET vfecha = vfecha;
		

		  
		--Insert a tabla bdinvers:sv_sdosdiarios
		--INICIO
		LET vsql	= '';
		LET vsql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD||NOMBRE_ARCHIVO_UNIVERSO||'.unl'||
			' SELECT (select fecha_ant  from bdinvers:sv_fechas'||
                    ' where empresa= \"'||vEmpresa||'\")'||
			' ,a.sucursal, a.cuenta, c.num_cte,'||
			'(select fecha_ant from bdinvers:sv_fechas'||
            ' where empresa= \"'||vEmpresa||'\")'||	
			',a.cv_dia'||vdiavalor||',a.ipa_dia'||vdiavalor||',a.secuencia'||
			' from bdinvers:sv_provdia a, bdinvers:sv_maeinv c'||
                   ' where a.aniomes = \"'||vaniomes||'\"'||
				   ' and a.cuenta = c.cuenta and a.secuencia = c.secuencia'||
					' and '||vcv_dia ||' is not null '||
					' and '||vipa_dia||' is not null '||
					' and c.fecha_venc > \"'||vfecha||'\"'||' order by cuenta;" > '||RUTA_ORIGEN||SCRIPT_EJECUCION_UNIVERSO;
		SYSTEM vsql;    
		
		LET vsql = '';
		LET vsql = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_UNIVERSO;
		SYSTEM vsql;
		
		LET vsql   =   '';
		--LET vsql   = TRIM(cRutaInformix)||'dbaccess bdicheq '||RUTA_ORIGEN||SCRIPT_EJECUCION_UNIVERSO;
		LET vsql   = TRIM(cRutaInformix)||'dbaccess bdinvers '||RUTA_ORIGEN||SCRIPT_EJECUCION_UNIVERSO;
		SYSTEM vsql;

		LET vsql = ''; 
		LET vsql = "echo "||'"'|| "file '"||RUTA_UNLOAD||NOMBRE_ARCHIVO_UNIVERSO||'.unl'|| "' delimiter '|' "|| '8'||                          
						  "; INSERT INTO sv_sdosdiarios" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO_INSERT||'registros.txt';
		SYSTEM vsql;
		
		
		--INSERT CON DBLOAD
		--Se ejecuta el dbload en bdinvers con cortes cada 1000 registros
		LET vsql = '';
		LET vsql = vRutadbload||" -d bdinvers -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO_INSERT||"registros.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO_INSERT||"err_insert.log -n "||CONTADOR_TRANSACCIONES||" -r";
		
		SYSTEM vsql;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vsql = '';
		LET vsql = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_UNIVERSO||'*';
		SYSTEM vsql;
		
		 LET vsql = '';
		LET vsql = ' rm -f '||RUTA_UNLOAD||NOMBRE_ARCHIVO_UNIVERSO||'*';
		SYSTEM vsql;
		
		LET vsql = '';
		LET vsql = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO_INSERT||'*';
		SYSTEM vsql;
		--FIN
   
    END;

    RETURN vcodret;

END PROCEDURE;
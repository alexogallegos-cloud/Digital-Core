CREATE PROCEDURE "informix".sp_rep_sol_grupo6()

RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--19-09-2012
-- execute PROCEDURE "informix".sp_rep_sol_grupo6();


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
define sPaso smallint;
define pfechacorte  date;
define vfecha  date;
define vlNumInsert smallint;

--Structura
    DEFINE Vnum_credito       	  	char(20);
	DEFINE Vnumcte					char(20);
	DEFINE Vestatus					char (2);
	DEFINE Vpago_vencido        	decimal(18,2);
	DEFINE Vsaldo_fin_mes			decimal(18,2);
	DEFINE Vcapital_vigente			decimal(18,2);
	DEFINE Vcapital_transitorio		decimal(18,2);
	DEFINE Vsaldo_vencido_exigible	decimal(18,2);
	DEFINE Vsaldo_vencido_no_exigible	decimal(18,2);
	DEFINE Vpago_min_req			decimal(18,2);
	DEFINE Vmonto_apertura    		decimal(18,2); 
	DEFINE Vfecha_apertura      	date;
	DEFINE Vemail					char(60);
	DEFINE Vtelcasa 				char(13);
	DEFINE Vtelcel 					char(13);
	DEFINE Vteltrab 				char(13);
	DEFINE Vext 					char(5);
	DEFINE Vsucursal				char(4);
	DEFINE Vnum_cd_coppel 			smallint;
	DEFINE Vnom_cd_coppel 			char(32);
	DEFINE Vhit 					char(6);
	DEFINE Vficiencia 				decimal(5,2);
	DEFINE Vmeses_historia		 	smallint;

	


--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2087';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		   			 = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";
let sPaso = 0;
let pfechacorte = date(1);
let vfecha = date(1);
let vlNumInsert = 0;

-----VARIABLES
	LET Vnum_credito       	  	= "";
	LET Vnumcte					= "";
	LET Vestatus				= "";
	LET Vpago_vencido        	= 0;
	LET Vsaldo_fin_mes			= 0;
	LET Vcapital_vigente		= 0;
	LET Vcapital_transitorio	= 0;
	LET Vsaldo_vencido_exigible	= 0;
	LET Vsaldo_vencido_no_exigible 	= 0;
	LET Vpago_min_req			= 0;
	LET Vmonto_apertura    		= 0;
	LET Vfecha_apertura      	= date(1);
	LET Vemail					= "";
	LET Vtelcasa 				= "";
	LET Vtelcel 				= "";
	LET Vteltrab 				= "";
	LET Vext 					= "";
	LET Vsucursal				= "";
	LET Vnum_cd_coppel 			= 0;
	LET Vnom_cd_coppel 			= "";
	LET Vhit 					= "";
	LET Vficiencia 				= 0;
	LET Vmeses_historia		 	= 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02')RETURNING cCod_ret;
        RETURN sql_err;
	END EXCEPTION;
--SET DEBUG FILE TO "grupo6.out";
--TRACE ON;
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret;
	
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 26;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	-------------------------------GENERA TABLA-------------------------------------
		
	--DROP TABLE sd_rep_grup6;
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_rep_grup6';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_rep_grup6;
            END IF;

    CREATE TABLE "informix".sd_rep_grup6
    ( numcte	char(20),
	 num_credito char(20),
	 estatus	char (2),
	 pago_vencido       decimal(18,2),
	 saldo_fin_mes	decimal(18,2),
	 capital_vigente	decimal(18,2),
	 capital_transitorio decimal(18,2),
	 saldo_vencido_exigible	decimal(18,2),
	 saldo_vencido_no_exigible	decimal(18,2),
	 pago_min_req		decimal(18,2),
	 monto_apertura    decimal(18,2),
	 fecha_apertura     date,
	 email		char(60) DEFAULT '' ,
	 telcasa 	char(13) DEFAULT '' ,
	 telcel 	char(13) DEFAULT ''	,
	 teltrab 	char(13) DEFAULT '' ,
	 ext 		char(5)  DEFAULT '' ,
	 sucursal	char(4),
	 num_cd_coppel smallint DEFAULT 0,
	 nom_cd_coppel char(32) DEFAULT '',
	 hit 	char(6),
	 eficiencia decimal(5,2),
	 meses_historia smallint);
	
	
	--------------------INSERTAR EN TABLA-----------------------------------
	select fecha_hoy  into pfechacorte
	from bdicred:sd_fechas where empresa = '001';
	
	select max(fecha) into vfecha
	from bdicred:sd_maesdoscont where empresa = '001';
----------------------------------------------------------------------------------------------------
	set isolation to dirty read;
	select num_solicitud ,evalua_cc, situacion_pago,meses_historia
	from bdisolic:ss_resum_scor_fin
	where empresa ='001'
		and grupo = '6'
	into temp solicitudes6 with no log;
 --IFRS Se contemplan los nuevos estatus de crédito por etapas
FOREACH

	select  sol.num_solicitud,a.numcte,a.status_cred,b.mto_fin_ven_trasp,con.sdo_cap_insoluto, 
		b.sdo_capital , b.monto_vencido ,b.mto_venc_trasp, b.cap_tras_no_venci,
		b.monto_otorgado,a.fecha_apertura,
	DECODE ( NVL(sol.evalua_cc,''),'','No Hit','X','No Hit','Hit'),nvl(sol.situacion_pago,0)  ,nvl(sol.meses_historia,0)
	into Vnum_credito , Vnumcte,Vestatus,Vpago_vencido,Vsaldo_fin_mes , 
		Vcapital_vigente,Vcapital_transitorio, Vsaldo_vencido_exigible,Vsaldo_vencido_no_exigible,
		Vmonto_apertura, Vfecha_apertura,	Vhit, Vficiencia, Vmeses_historia
	from --join bdisolic:ss_solicitudes sol on (sol.empresa= scor.empresa and sol.num_solicitud = scor.num_solicitud and sol.status_solicitud = 'AP')
		bdicred:sd_maecred a,solicitudes6 sol, bdicred:sd_maesdos b,  bdicred:sd_maesdoscont con
	where a.empresa= '001'
		and a.num_credito = sol.num_solicitud
		and a.empresa=b.empresa   and  a.num_credito=b.num_credito 
		and a.status_cred in ('AA','BT','BA','E1','E2','E3')
		and con.fecha = vfecha 
		and a.empresa = con.empresa and a.num_credito = con.num_credito  
	
	select limit 1 sucursal  into Vsucursal
	from bdisolic:ss_solicitudes where  empresa = '001'  and    num_solicitud  = Vnum_credito;
	
	SELECT limit 1 ci.numerociudadcoppel, ci.nombreciudadcoppel
		INTO Vnum_cd_coppel , Vnom_cd_coppel
	FROM bdinteg:si_direcciones_actual dir 
	LEFT JOIN bdinteg:si_catciudades ci ON ( ci.numerociudad =dir.numerociudad  )
	WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;

	select limit 1 sdo_pagar into Vpago_min_req from bdicred@pld_tcp:sd_encabezado2_edocta   
	where fecha_emision = (select max(fecha_emision)  from bdicred@pld_tcp:sd_encabezado2_edocta 
							where num_credito = Vnum_credito)
	and num_credito = Vnum_credito;
		
	select limit 1 correo_elec
	INTO Vemail
	from bdinteg:si_correos	where numcte = Vnumcte	AND status_correo = 'A';

	select LIMIT 1 telefono
		into Vtelcasa 
	from bdinteg:si_telefonos_actual 
	where empresa = '001' and numcte= Vnumcte and tipo_tel = 1 and cofetel ='V' AND status_tel = 'A'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = Vnumcte and tipo_tel = 1 and cofetel ='V');
	
	select LIMIT 1 telefono
		into Vtelcel 
	from bdinteg:si_telefonos_actual 
	where empresa = '001' and numcte= Vnumcte and tipo_tel = 2 and cofetel ='V' AND status_tel = 'A'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = Vnumcte and tipo_tel = 2 and cofetel ='V');
												 
	select LIMIT 1 telefono,extension
		into Vteltrab ,Vext 
	from bdinteg:si_telefonos_actual 
	where empresa = '001' and numcte= Vnumcte and tipo_tel = 3 and cofetel ='V' AND status_tel = 'A'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = Vnumcte and tipo_tel = 3 and cofetel ='V');

	LET vlNumInsert = vlNumInsert + 1;
	IF vlNumInsert = 5000 then 
       LET vlNumInsert = 1;
       update statistics medium for table "informix".sd_rep_grup6;
    END IF;
			
	INSERT INTO "informix".sd_rep_grup6 
    VALUES
	(  Vnumcte,Vnum_credito ,Vestatus, Vpago_vencido , Vsaldo_fin_mes , Vcapital_vigente,
	 Vcapital_transitorio, Vsaldo_vencido_exigible,Vsaldo_vencido_no_exigible, Vpago_min_req, Vmonto_apertura, Vfecha_apertura , Vemail,
	 Vtelcasa , Vtelcel 	, Vteltrab 	, Vext , Vsucursal	, Vnum_cd_coppel ,
	 Vnom_cd_coppel , Vhit, Vficiencia , Vmeses_historia);
	
		
	LET Vnum_credito       	  	= "";	LET Vnumcte					= "";	LET Vestatus				= "";
	LET Vpago_vencido        	= 0;	LET Vsaldo_fin_mes        	= 0;	LET Vcapital_vigente		= 0;
	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;	LET Vpago_min_req			= 0;
	LET Vmonto_apertura    		= 0;	LET Vfecha_apertura      	= date(1);	LET Vemail					= "";
	LET Vtelcasa 				= "";	LET Vtelcel 				= "";	LET Vteltrab 				= "";
	LET Vext 					= "";	LET Vsucursal				= "";	LET Vnum_cd_coppel 			= 0;
	LET Vnom_cd_coppel 			= "";	LET Vhit 					= "";	LET Vficiencia 				= 0;
	LET Vmeses_historia		 	= 0;
	
			   
END FOREACH;
	---------------------------------------GENERAR ARCHIVO------------------------------------------------------------------
		--let cruta = '/informix/Elizabeth/';
	let cnombre = 'Rep_grupo6_saldos_';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	
	LET cSql='';
	LET csql = 'echo "numcte'||';'||'num_credito'||';'||'estatus'||';'||'pago_vencido'||';'||'saldo_fin_mes'||';'||
				 'capital_vigente'||';'||'capital_transitorio'||';'||'saldo_vencido_exigible'||';'||'pago_min_req'||';'||
				 'monto_apertura'||';'||'fecha_apertura'||';'||'email'||';'||'telcasa'||';'||'telcel'||';'||'teltrab'||';'||
				 'ext'||';'||'sucursal'||';'||'num_cd_coppel'||';'||'nom_cd_coppel'||';'||'hit'||';'||'eficiencia'||';'||'meses_historia'||
				 '" >'||TRIM(cruta)|| cnomarchivo;			 
	SYSTEM csql;  
	
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from sd_rep_grup6 ";
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_grupo.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_grupo.sql';
    System cSQL;

    let cSQL = 'dbaccess bdisolic ' || TRIM(cRuta) || 'Ejecuta_grupo.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_grupo.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;  

	DROP TABLE "informix".sd_rep_grup6;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03')RETURNING cCod_ret;
	
	RETURN cCod_ret;
	
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_carga_ctes_credisoluciones(pEmpresa CHAR(3))
RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;


DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dtFechaIni        DATE;
DEFINE dtFechaFin  		 DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);
DEFINE cNumCred         CHAR(20);


--SET DEBUG FILE TO "/informix/jesus/inccat/sp_carga_ctes_credisoluciones.out";
--TRACE ON;

LET vproceso        = '3402';
LET cCod_RetIB      = '000000';
LET dtFechaIni       = DATE(0); 
LET dtFechaFin       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cParamNomArch     = 'Credisolucion201703';LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cNumCred        = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;



    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
	END IF;

 

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        
        RETURN cCodRet, cMensajeRet;
    END IF;
	
	
	---se crea temporal para realizar limpieza de las promociones que se van a insertar.
	SELECT num_credito	
	FROM  "informix".sd_prospectos
	WHERE num_promo = 7
	INTO TEMP limpieza WITH NO LOG;
	
	
	FOREACH WITH HOLD
		SELECT num_credito	
		INTO cNumCred
		FROM  "informix".limpieza
		
		BEGIN WORK;
			INSERT INTO sd_prospectos_hist
			SELECT TODAY,* 	
			FROM  "informix".sd_prospectos
			WHERE num_promo = 7
			AND num_credito = cNumCred;
			
			DELETE FROM  "informix".sd_prospectos
			WHERE num_promo = 7
			and num_credito = cNumCred;
		COMMIT WORK;
		
	END FOREACH
	
	--se carga el archivo con los clientes de las nuevas promociones
	
	SELECT LIMIT 1 fechaini_promo, fechafin_promo
		INTO dtFechaIni, dtFechaFin
	FROM "informix".sd_promocion    
	WHERE empresa = '001'
	AND num_producto = '6001'
	AND num_promo = 7;
   
	
    LET cNomArchivo = trim(cParamNomArch) ||'.txt';
    LET cNomArchEjecSql = 'Carga_credisol.sql';
    TRUNCATE TABLE bdicred:sd_ctes_behavior;
	UPDATE STATISTICS MEDIUM FOR TABLE  bdicred:sd_ctes_behavior;
    -- Realiza carga de archivo.
    LET cSQL = '';
    LET cSQL = ' echo " CREATE TEMP TABLE cred_prospectos (num_credito CHAR(20),numcte CHAR(20)) with no log; '
            || ' LOAD FROM ' || TRIM(cRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO cred_prospectos; '
            || ' INSERT INTO bdicred:sd_prospectos ( empresa, num_producto, num_promo, numcte, num_credito, fecha_ini, fecha_fin) '
            || ' SELECT  ''001'',''6900'',7,numcte , num_credito  ,''' || dtFechaIni || ''',''' || dtFechaFin || ''' FROM cred_prospectos;  ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

	
	

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    UPDATE STATISTICS MEDIUM FOR TABLE  bdicred:sd_prospectos;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para carga de archivo de creditos candidatos para validarse bajo perfil de segundo producto', 
'AUTOR: JESUS AGUILAR  ',
'FECHA: octubre  2016',
'VERSION: 20151012.1433',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_mc_consexpediente (pEmpresa CHAR(3), pCliente CHAR(20))

RETURNING CHAR(5),    -- Codigo de Retorno
           CHAR (40); --descripcion
		  
--DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE iContador		SMALLINT;
DEFINE cDescripcion		CHAR(80);

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cDescripcion        = '';
LET iContador           = 0;


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;          
          RETURN cCodRet,NVL(cErrorInfo,'');	 
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jesus/inccat/sp_mc_consexpediente.out";
	--TRACE ON;
		
	IF  NVL(pCliente,'') = '' THEN
		LET cCodRet	= '00001';
		RETURN cCodRet,'Error de parametros';
	END IF;
	
	
	FOREACH WITH HOLD

		SELECT DISTINCT tipo.descripcion 
		INTO cDescripcion
		FROM bdidigital@coppelimg_tcp:dg_tipodocumento AS tipo 
		LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS EXP ON (tipo.cod_docto = EXP.cod_docto)
		WHERE EXP.cliente = pCliente 
		AND tipo.cod_grupo IN('001','002','003') 
		AND  EXP.fecha_alta IN(SELECT MAX(Exp2.fecha_alta) 
							FROM bdidigital@coppelimg_tcp:dg_tipodocumento  AS tipo2 
							LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS exp2 	ON (tipo2.cod_docto = exp2.cod_docto)
							WHERE Exp2.cliente = EXP.cliente  
							AND tipo2.cod_grupo = tipo.cod_grupo) 
		
		LET iContador = 1;
		
		RETURN cCodRet,NVL(cDescripcion,'') WITH RESUME;
	
	END FOREACH;
	FOREACH WITH HOLD
		SELECT DISTINCT tipo.descripcion 
		INTO cDescripcion
		FROM bdidigital@coppelimg_tcp:dg_tipodocumento AS tipo
		LEFT OUTER JOIN bdidigital@coppelimg_tcp:dg_expediente AS EXP ON (tipo.cod_docto = EXP.cod_docto) 
		WHERE EXP.cliente = pCliente 
		AND tipo.cod_grupo in('006','007') 
		AND exp.fecha_alta > today -90 units DAY 
		LET iContador = 1;
		RETURN cCodRet,NVL(cDescripcion,'')WITH RESUME;
		
	END FOREACH;
	IF iContador = 0 THEN
		LET cCodRet='00002';
		LET cDescripcion='No existe informacion';
		RETURN cCodRet,NVL(cDescripcion,'');
	END IF
   
END;
END PROCEDURE
DOCUMENT    
'DESCRIPCION: Procedimiento para  obtencion de documentos digitalizados en mesa de control para formato de autorizacion de solicitud', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA:27 Febrero 2017',
'VERSION: 20170227.1028',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_reporte_concentrado_6900(p_empresa char(3), pfechacorte   DATE)
    RETURNING CHAR(6)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje;         

--Proceso para la generación del reporte concentrado de Credisoluciones RQM 10 412 
--Modificado: Febrero 2015

DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_retIB			CHAR(6);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cProceso             CHAR(4);
DEFINE cFechaCorte          DATE; --CHAR(8);

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET cCod_retIB              = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET cruta                   = "";
LET cnombre					= "Credisol_Con_";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnomarchivoEjecSql      = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cProceso                = '0085';

--SET DEBUG FILE TO "/informix/mahr/sp_reporte_concentrado_6900.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;       
        CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR, '02') Returning cCod_retIB;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'INICIA CREACION REPORTE', '02') Returning cCod_RetIB;

	--Obtener ruta del archivo
    SELECT TRIM(valor)  INTO cruta
      FROM bdicred:sd_param WHERE empresa = p_empresa
       AND cod_param = '033';

    LET cFechaGenArchivo =  to_char(pfechacorte,'%d%m%Y');
    LET cFechaCorte = pfechacorte;

	--Validar que existe el archivo	
	LET cnomarchivo1 = trim(cnombre)||cFechaGenArchivo||'_Aux_'||'.txt ';
    LET cnomarchivo =  trim(cnombre)||cFechaGenArchivo||'.txt ';
    LET cnomarchivoEjecSql = 'Exec_Rep_Con_6900' || '.sql';

    LET cSQL='';
    LET cSQL = 'echo "Num Promocion'||'|'||'Nombre Promocion'||'|'||'Tasa Interes'||'|'||'Contratos'||'|'||'Monto'||'|'||'Plazo'||
               '|'||'Capital insoluto'||'|'||'Intereses por Pagar'||'|'||'IVA por Pagar'||'|'||'Intereses Cargados Acum'||'|'||'IVA Cargados'|| ' " >' || TRIM(cruta) || TRIM(cnomarchivo)||'';
    SYSTEM cSQL;

    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1);
    LET cSQL2 = " SELECT num_promo, nombre_promo, crd.tasa_interes, COUNT(a.nombre_promo) Contratos, SUM(dos.monto_otorgado) monto_otorgado, a.plazo, "
        || " SUM(dos.sdo_capital) cap_insoluto, sum( (select nvl(sum(am11.interes_debe),0) from bdicred:sd_amortiza_creditocrd am11 where a.empresa = am11.empresa "
        || " and a.num_sol_prestamo = am11.num_credito and am11.capital_status!= 5)) int_x_pagar, "
        || " sum( (select nvl(sum(am12.iva_debe),0) from bdicred:sd_amortiza_creditocrd am12 where a.empresa = am12.empresa and a.num_sol_prestamo = am12.num_credito "
        || " and am12.capital_status!= 5)) iva_x_pagar, "
        || " sum( (select nvl(sum(am51.interes_pagado),0) from bdicred:sd_amortiza_creditocrd am51 where a.empresa = am51.empresa and a.num_sol_prestamo = am51.num_credito " 
        || " and am51.capital_status = 5)) int_cargados, sum( (select nvl(sum(am52.iva_pagado),0) from bdicred:sd_amortiza_creditocrd am52 where a.empresa = am52.empresa " 
        || " and a.num_sol_prestamo = am52.num_credito and am52.capital_status = 5)) iva_cargados "
        || " FROM bdicred:sd_promocion_credito a JOIN bdicred:sd_maecredcrd crd "
        || " ON (a.empresa = crd.empresa AND a.num_sol_prestamo = crd.num_credito AND a.num_pro_prestamo = '6900' AND a.empresa = '001') "
        || " JOIN bdicred:sd_maesdoscrd dos ON (a.empresa = dos.empresa AND a.num_sol_prestamo = dos.num_credito) "
        || " WHERE a.status in (0,2,6,7) "
        || " AND a.num_sol_prestamo != '' AND dos.num_credito != '' AND crd.num_credito != '' "
        || " GROUP BY 1,2,3,6 "
        || " ORDER BY num_promo, tasa_interes, plazo ASC; ";

    LET cSQL3 = '">'||TRIM(cRuta)|| cnomarchivoEjecSql;
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)|| cnomarchivoEjecSql;
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || cnomarchivoEjecSql;
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/|$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoejecsql || ' ' || TRIM(cruta) || cnomarchivo1;
    SYSTEM cSQL;

    LET cCod_Ret = '000000';
    LET cMensaje = 'PROCESO EXITOSO';

    CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA CREACION REPORTE', '02') Returning cCod_RetIB;


    RETURN cCod_Ret, cMensaje;

 END;   --begin        

END PROCEDURE;
CREATE PROCEDURE "informix".sp_rep_incrtrimestral (pEmpresa CHAR(3),pFecha DATE )
RETURNING CHAR(5), -- Codigo de Retorno
CHAR(80);   -- Mensaje de retorno;   

		  
	---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);
DEFINE iContador		INTEGER;
DEFINE iContador2		INTEGER;


DEFINE	cNumcte	CHAR(20);  
DEFINE	cNumCred	CHAR(20);  
DEFINE	dtFechaStatus	DATE; 
DEFINE	dtFechaStatus2	DATE; 
DEFINE	dtFechaInc	DATE; 
DEFINE	cGrupo	CHAR(1);
DEFINE	cStatusSol	CHAR(2);
DEFINE	cGradoRiesgo	CHAR(2);
DEFINE	dMontoIni	DECIMAL(18,2);  
DEFINE	dMontoSug	DECIMAL(18,2);  
DEFINE	dMaxPorc	DECIMAL(18,2);  
DEFINE	dPromPorc	DECIMAL(18,2);  
DEFINE	iIncrPrev	SMALLINT;  

DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;
DEFINE  vFechaAper	DATE;
DEFINE  vCausa		CHAR(5);


DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(500);
DEFINE cRuta 			CHAR(80);

--SET DEBUG FILE TO "/informix/jesus/sp_rep_incrtrimestral.out";
--TRACE ON;
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET iContador			=  0;
LET iContador2			=  0;

LET	cNumcte	= '';
LET	cNumCred	= '';
LET	dtFechaStatus	= DATE(1);
LET	dtFechaStatus2	= DATE(1);
LET	dtFechaInc	= DATE(1);
LET	cGrupo	= '';
LET	cStatusSol	= '';
LET	cGradoRiesgo	= '';
LET	dMontoIni	=  0;
LET	dMontoSug	=  0; 
LET	dMaxPorc	=  0;
LET	dPromPorc	=  0; 
LET	iIncrPrev	=  0;  

LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET  vFechaAper	 = DATE(1);
LET  vCausa		 = '';

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet;
	
       END IF;
    END EXCEPTION;


			
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETROS DE ENTRADA INVALIDOS';
		RETURN cCodRet,cMensajeRet;	
	END IF;
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	-- OBTIENE LA FECHA DEL DIA
	
	--obtener fecha de fin de mes  del periodo solicitado
	LET dtFechaFinMes = mdy(month(pFecha),01,YEAR(pFecha)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(pFecha),01,YEAR(pFecha)), - 3);
	
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Incrementos_Linea_')||TO_CHAR(pFecha,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Incrementos_Linea_aux')||TO_CHAR(pFecha,'%m%y')|| '.txt';
	
	FOREACH WITH HOLD	
		SELECT a.numcte, b.num_solicitud , fecha_apertura,
			(SELECT MAX(fecha_status)
			FROM bdicred:"informix".sd_bitacora_aumlincred aux
			WHERE aux.numcte  = a.numcte
			AND aux.empresa = a.empresa
			AND aux.status = 'AP'),
			b.grupo ,a.fecha_insert ,a.status,CASE WHEN a.status = 'RT' THEN a.causa_status WHEN a.status = 'CN' THEN a.causa_status ELSE '' END,
			a.fecha_status,a.lincred_actual,a.lincred_sugerida ,a.num_inc_prev ,a.grado_riesgo, a.may_porc_uso6,prom_porc_uso12
		INTO cNumcte,cNumCred,vFechaAper,dtFechaStatus,cGrupo,dtFechaInc,cStatusSol,vCausa,dtFechaStatus2,dMontoIni,dMontoSug,iIncrPrev,cGradoRiesgo,dMaxPorc,dPromPorc
		FROM sd_bitacora_aumlincred a,
		bdisolic:ss_resum_scor_fin  b, sd_maecred c
		WHERE a.num_solicitud = b.num_solicitud
		AND a.num_solicitud = c.num_credito
		AND fecha_insert between dTFechaSD and dtFechaFinMes
    	
 
		LET cConsulta = TRIM(NVL(cNumcte,''))||'|'|| TRIM(NVL(cNumCred,''))||'|'||NVL(vFechaAper,'')||'|'||NVL(dtFechaStatus,'')||'|'|| TRIM(NVL(cGrupo,''))||'|'||NVL(dtFechaInc,'')||'|'||NVL(cStatusSol,'')||'|'||TRIM(NVL(vCausa,''))||'|'||NVL(dtFechaStatus2,'')||'|'|| NVL(dMontoIni,0)||'|'||NVL(dMontoSug,0)||'|'||NVL(iIncrPrev,0)||'|'||NVL(dMaxPorc,0)||'|'||NVL(dPromPorc,0)||'|'||NVL(cGradoRiesgo,'');
		
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;						
	
		LET iContador2	=  1; 
    END FOREACH;
     
   IF iContador2  > 0 THEN 	
      
	---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Número de Cliente'||'|'||'Número de Crédito'||'|'||'Fecha de apertura'||'|'||'Fecha de último Incremento'||'|'||'Grupo de Originación'||'|'||'Fecha de Proceso'||'|'||'Estatus'||'|'||'Motivo de Estatus'||'|'||'Fecha cambio de Estatus'||'|'||'Monto de la Línea Inicial'||'|'||'Monto de la Línea Sugerida'||'|'||'Número de Incrementos previos'||'|'||'Máximo porcentaje de utilización de los últimos 12 meses'||'|'||'Promedio del porcentaje de utilización de los últimos 12 meses'||'|'||'Grado de Riesgo'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;

	
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   	
	     
   RETURN cCodRet,cMensajeRet;
   
   ELSE
    LET cCodRet			= '00000';
	LET cMensajeRet			= 'No se encontro información';
	RETURN cCodRet,cMensajeRet;
   END IF;
   
END;
END PROCEDURE
DOCUMENT    
'DESCRIPCION: Procedimiento para extraer informacion trimestral de los incrementos, RQM 09 407-2', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 20 abril 2016',
'VERSION: 20160420.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_genera_archivo_carteralinea_adlm(pEmpresa char(3), pServicio char(1))

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

--Creado por: Abrham Lopez L. 05/08/2011. Proceso para la generaciÃÂ³n del archivo de Cartera en Linea
-- Modificado por: MAHR Octubre 2011. Se agregan al proceso productos de colocaciÃÂ²n ademÃÂ s de la Tarjeta de CrÃÂ¨dito PrÃÂ¨stamo Personal y Reestructura.
--      Servicios: 1.- Tarjeta de Credito, 2.- Prestamo Personal y Reestructura 3.- AMBOS.
-- Modificado por MAHR. Mayo 2012. Se crea sp sp_genera_carteraenlinea_tab, que genera los saldos de la cartera vencida y la almacena en la tabla:
--		sd_sdos_cartera_linea y desde dicha tabla se genera el archivo de Cartera en linea.


--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cEmpresa             CHAR(3);
DEFINE cCod_ret				CHAR(6);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivoAuxRPp    CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnomarchivoNvo		CHAR(100);
DEFINE cSQL                 CHAR(8204);
DEFINE cSQL1                CHAR(6204);
DEFINE cSQL2                CHAR(6204);
DEFINE cSQL3                CHAR(100);
DEFINE pFecha               DATE;
DEFINE vnomProceso			CHAR(20);
DEFINE cMensajeRet          CHAR(125);
--DEFINE credcontproc 	    char(1);
--DEFINE intecontproc 	    char(1);
DEFINE cProceso             CHAR(4);
DEFINE cCod_retBit          CHAR(6);

--SET DEBUG FILE TO "/informix/mahr/sp_genera_archivo_carteralinea.out";
--TRACE ON;

--InicializaciÃÂ³n de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cEmpresa                = "";
LET cCod_Ret                = "000000";
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivoAuxRPp       = "";
LET cnomarchivo1			= "";
LET cnomarchivoNvo			= "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cMensajeRet				= 'PROCESO EXITOSO';
LET vnomProceso             = "";
--LET credcontproc            = "";
--LET intecontproc            = "";
LET cProceso                = '0024';
LET cCod_retBit             = '000000';


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;            
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;       

        /*UPDATE bdicred:"informix".sd_contproc SET status_proc = "C",  hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = "Cobranza en Linea Sin Generar"
            WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha   = pFecha; 
        UPDATE bdinteg:"informix".sx_contproc SET status_proc = "C", hora_fin = CURRENT, codret  = cCod_ret
            WHERE empresa = pEmpresa AND proceso   = vnomProceso  AND fecha   = pFecha; */
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '01') RETURNING cCod_retBit;       
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pServicio = '1' OR pServicio = '3' THEN  
            LET vnomProceso = 'CarteraLinea';   -- Proceso para TDC // TDC Y Prest Y Reest
    ELIF pServicio = '2' THEN  
        LET vnomProceso = 'CarteraLinea_CP';   -- Ejecuta Prestamo Personal y Reestructura
    ELSE        -- No ejecute nada si el servicio es diferente a 1,2 o 3
        LET cCod_Ret=  '102002';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;       
        RETURN cCod_Ret,cMensajeRet;
    END IF;  

    LET pfecha = date(1);

    -- Obtener la fecha del dia de hoy
    SELECT fecha_ant INTO pFecha
        FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa; 

    IF pFecha IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF

    -- *******************************************************
    --  INSERTA BITACORA PARA EJECUCION DE PROCESO           *
    -- *******************************************************
    /* Se elimina la bitacora ya que cuando por error se ejecuta la cartera en linea despues del cambio de fecha, al dia posterior no permite
       la ejecucion del proceso por que indica que ya fue ejecuta, cuando no se ha ejecutado ese dia. Se agrega la bitacora en cobranza para su registro.

    SELECT status_proc INTO intecontproc FROM bdinteg:"informix".sx_contproc WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pfecha;
    IF (intecontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;
    SELECT status_proc INTO credcontproc FROM bdicred:"informix".sd_contproc WHERE empresa = pEmpresa  AND proceso = vnomProceso AND fecha = pFecha;
    IF (credcontproc = 'F') THEN
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCod_Ret,cMensajeRet;
    END IF;

    IF (intecontproc IS NULL) THEN
        INSERT INTO bdinteg:"informix".sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
            VALUES ('001',vnomProceso,pFecha,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF (credcontproc IS NULL) THEN
        INSERT INTO bdicred:"informix".sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
            VALUES ('001',vnomProceso,pFecha,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    END IF;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'I' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdicred:"informix".sd_contproc SET status_proc = 'I', mensaje = 'Iniciamos' WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    */

    -- *******************************************************
    --  FIN BITACORA                                         *
    -- *******************************************************

	-- Validacion de parÃÂ¡metros de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCod_Ret= '104001';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3  AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
	END IF;

	--ValidaciÃÂ³n de la empresa
    SELECT empresa INTO cEmpresa
        FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa;
    IF NVL (cEmpresa, '') = '' OR cEmpresa IS NULL THEN
        LET cCod_Ret= '104002';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = cCod_Ret;
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

	--Obtener ruta del archivo
    SELECT TRIM(valor_alfabetico) INTO cruta
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 34;  
            
                --Valida que exista la carpeta
    IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
                AND codigo_error = cCod_Ret;

        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

    --Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico) INTO cnombre
        FROM bdicobranza:"informix".cb_param_campania
        WHERE empresa = pEmpresa
            AND tipo_campania = 1
            AND grupo_parametro = 'ARCHIVOS'
            AND num_parametro = 35;
    IF NVL (cnombre,'') = '' THEN
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = '104006';
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

           -- Ejecuta la creacion de la informacion en la tabla sd_sdos_cartera_linea
   
	--    CALL bdicred:"informix".sp_genera_carteraenlinea_tab(pEmpresa, pServicio) RETURNING  cCod_Ret,  cMensajeRet; 

    IF cCod_Ret <> '000000' THEN
        SELECT descripcion INTO cMensajeRet
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3 AND codigo_error = '105009';
        IF cMensajeRet IS NULL THEN
            LET cMensajeRet = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '02') RETURNING cCod_retBit;
        RETURN cCod_Ret,cMensajeRet;
    END IF;

                        --Validar que existe el archivo
    LET cnomarchivo		=  trim(cnombre)||'Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo1	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'.txt';
	LET cnomarchivoNvo	=  trim(cnombre)||to_char(pFecha,'%d%m%Y')||'_nuevo'||'.txt';

        --              Obtiene la consulta de la Cartera de Tarjeta de Credito                                     -
        --------------------------------------------------------------------------------------------------------------
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       - 
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

    IF pServicio = '1' OR pServicio = '3' THEN

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo); 

        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, " 
            || " (sdo_capital +  monto_vencido + mto_venc_trasp + cap_tras_no_venci + moratorio + interes_iva ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + moratorio + interes_iva) sdo_venc_tot, mensualidad_actual, "
            || " mto_fin_ven_trasp::INTEGER no_vencidos, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10) "
            || " FROM bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6001','8100') "; 

        LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';

        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivo || " >> " || TRIM(cRuta) || cnomarchivoNvo; --cnomarchivo1;
        SYSTEM cSql;

        --Borra el archivo de control.
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchCARTERAlinea.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo;
        SYSTEM cSQL;

    END IF;

	  -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
		LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
		System cSQL;
	
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
		LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
		System cSQL;
		
	
    IF pServicio = '2' OR pServicio = '3' THEN
            
        LET cnomarchivoAuxRPp =  trim(cnombre)||'R_PP_Aux'||to_char(pFecha,'%d%m%Y')||'.txt';
        -- cnomarchivo1 Contiene la consulta de Tarjeta de Credito...

        LET cSQL  = ""; 
        LET cSQL1 = "";
        LET cSQL2 = "";
        LET cSQL3 = "";

        --              Obtiene la consulta de la Cartera de Reestructura y Prestamo Personal                       -
        -- -------------------------------------------------------------------------------------------------------- -
        -- Cliente |Credito | Tarjeta | Int Moratorio | Sdo Tot Liquidacion | Sdo Vencido Tot | Mens Actual |       -
        -- No Vencidos | Status Cred | Fech Ult Pago | Pago 1 Mora | Tipo Prod | Cuenta Eje( N/A TDC) |             -

        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivoAuxRPp); 
        --AAME RQM 10 393 20150624 Se solicita contemplar los dos nuevos productos de prestamo personal (7600,7700)
        LET cSQL2 = " SELECT numcte, num_credito, num_tarjeta, moratorio, "
            || " (sdo_cap_insoluto + sdo_intereses + interes_iva + moratorio ) sdo_tot_liquid, "
            || " (monto_vencido + mto_venc_trasp + interes_iva + moratorio - iva_int_trasp) sdo_venc_tot, mensualidad_actual, " 
            || " mto_fin_ven_trasp::INTEGER no_vencidos, status_cred, fecha_ult_pago, pago_una_mora, num_producto, num_cta cuenta_eje, "
			|| " to_char(fecha_apertura,'%d/%m/%Y') fecha_apertura, antiguedad, monto_otorgado, mto_fin_ven_trasp::INTEGER vencidos_ant, novencidos1, novencidos2, novencidos3, novencidos4, "
			|| " novencidos5, novencidos6, bcscore::INTEGER bc_score, scoreprop::INTEGER score_prop, ficoscore::INTEGER fico_score, bhscore::INTEGER bhscore, "
			|| " grupo, sucursal, SUBSTR(lpad(nvl(trim(celular),''),13,'0'),-10) "
            || " from bdicred:sd_sdos_cartera_linea "
            || " WHERE num_producto IN ('6011','6300','6400','7600','7700') ";

        LET cSQL3 = '">'||TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';

        LET cSQL = trim(cSQL1) ||cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || cnomarchivoAuxRPp || " >> " || TRIM(cRuta) || cnomarchivoNvo;		SYSTEM cSql;

        --Borra el archivo de control.
    	LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'Ejec_GenCARTLinea_Reest_PP.sql';
        SYSTEM cSQL;

        LET cSQL = '' ;
    	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivoAuxRPp;
        SYSTEM cSQL;

    END IF;          
   
   -- ADLM: SE AGREGA ARCHIVO CON CAMPOS NUEVOS SOLICITADOS EN EL RQM 09 463
	LET cSQL = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13 -d '|' " || TRIM(cruta) || trim(cnomarchivoNvo) || ' >' || TRIM(cruta) || trim(cnomarchivo1);
    System cSQL;
	
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivoNvo;
	LET cSQL='chmod 777 '|| TRIM(cRuta) || cnomarchivo1;
    System cSQL;
	
	
    --                  Fin consultas | & | Concluye datos en bitacora                                          -
  
    LET cCod_Ret = "000";
    LET cMensajeRet = "PROCESO CONCLUIDO";

    /*UPDATE bdicred:"informix".sd_contproc SET status_proc = 'F', hora_fin = CURRENT, cod_ret = cCod_ret, mensaje = cMensajeRet
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha = pFecha;
    UPDATE bdinteg:"informix".sx_contproc SET status_proc = 'F', hora_fin = CURRENT, codret = cCod_ret
     WHERE empresa = pEmpresa AND proceso = vnomProceso AND fecha  = pFecha; */

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensajeRet, '03') RETURNING cCod_retBit;
    RETURN cCod_ret,cMensajeRet;

END;

END PROCEDURE;
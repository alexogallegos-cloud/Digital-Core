CREATE PROCEDURE "informix".sp_compac_genera_reporte(pEmpresa CHAR(3), pTipoReporte INTEGER, pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  CHAR(80) AS Nombre_archivo; 
---DECLARACIONES
DEFINE cCodRet        	  CHAR(6); 
DEFINE cMensajeRet        CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cNombreArchivo	  CHAR(80);
DEFINE iNumArchivo		  INTEGER;
DEFINE cTipoArchivo	      CHAR(80);
DEFINE cConsulta		  CHAR(2200);
DEFINE cConsulta2		  CHAR(500);
DEFINE cConsulta3		  CHAR(500);
DEFINE cSql		 		  CHAR(3000);
DEFINE cParam1		      CHAR(20);
DEFINE cParam2		      CHAR(20);
DEFINE cParam3		      CHAR(20);
DEFINE cRuta		      CHAR(80);
DEFINE cTabla		      CHAR(1);
DEFINE dtFecha		      DATE;

DEFINE vvCodRet       	  CHAR(5);  
DEFINE vvMensajeRet       CHAR(80);
DEFINE vvNombreArchivo	  CHAR(80);
DEFINE dtFechaIni         DATE;
DEFINE dtFechaFin         DATE;
DEFINE cArch_medidor_compac	  CHAR(15);
DEFINE cRandomId           CHAR(30);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo			= 0;
LET cNombreArchivo		= "reporte";
LET cTipoArchivo     	= "";
LET cConsulta			= "";
LET cConsulta2			= "";
LET cConsulta3			= "";
LET cParam1				= "";
LET cParam2				= "";
LET cParam3				= "";
LET cRuta				= "";
LET cTabla				= "N";
LET dtFecha				= DATE(1);
LET vvCodRet        = ''; 
LET vvMensajeRet    = '';
LET vvNombreArchivo	= '';
LET dtFechaIni    = DATE(1);
LET dtFechaFin    = DATE(1);
LET cArch_medidor_compac	= '_indsconvs_';
LET cRandomId     = '';
       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
	LET cMensajeRet = cErrorInfo;
	IF cTabla="S" THEN
		-- DROP TABLE cb_med_pagomin_rep;
	END IF;
    RETURN cCodRet, cMensajeRet,"";
END EXCEPTION;

  --SET DEBUG FILE TO '/respaldosbd/has/sp_compac_genera_reporte.out';
  --TRACE ON;

  SELECT substr(current year to day ,1,4)||
         substr(current year to day ,6,2)||
         substr(current year to day ,9,2)|| '_' ||
         substr(current hour to second ,1,2)||
         substr(current hour to second ,4,2)||
         substr(current hour to second ,7,2)||
         dbinfo('sessionid')
    INTO cRandomId
    FROM systables where tabid=1; 

IF NVL(pEmpresa,"") = "" OR  NVL(pTipoReporte,"") = "" OR  NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" THEN
	LET cCodRet= "000001";
	LET cMensajeRet = "Parametro no valido para realizar la consulta";
	RETURN cCodRet, cMensajeRet,"";
END IF;

--se obtiene la ruta donde se almacenara el archivo generado.
	SELECT  TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicobranza:"informix".cb_param_campania
	WHERE tipo_campania = 11  
	AND  grupo_parametro = 'RUTAS'
	AND num_parametro =1;
	
IF NVL(cRuta,"") = "" THEN
	LET cCodRet= "000002";
	LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
	RETURN cCodRet, cMensajeRet,"";
END IF;	
		SELECT fecha_hoy   
		INTO dtFecha 
		FROM bdicred:"informix".sd_fechas
		WHERE empresa=pEmpresa;

	--LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha);

 IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_med_pagomin_rep'  AND dbsname = 'bdicred') THEN
        DROP TABLE "informix".sd_med_pagomin_rep;
 END IF;

 IF pTipoReporte = 2 THEN

  LET cNombreArchivo= TRIM(cNombreArchivo)|| TRIM(cArch_medidor_compac) || TRIM(cRandomId);
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
	  FOREACH WITH HOLD 
  	  SELECT num_archivo,tipo_archivo,query,param1,param2,param3
  		INTO iNumArchivo,cTipoArchivo,cConsulta,cParam1,cParam2,cParam3		
  		FROM  bdicobranza:"informix".cb_param_archivos 
  		WHERE num_archivo = pTipoReporte
 
      IF cParam1 IN ('001','1','2') THEN
				LET cConsulta= replace( cConsulta , 'Param1' , "'"||TRIM(cParam1)||"'");
			END IF;
			
			IF cParam2 = 'Fecha Inicio' THEN
				LET cParam2 = pFechaIni;
				LET cConsulta= replace( cConsulta , 'Param2' , "'"||TRIM(cParam2)||"'");
			END IF;
			
			IF cParam3 = 'Fecha Fin' THEN
				LET cParam3 = pFechaFin;
				LET cConsulta= replace( cConsulta , 'Param3' , "'"||TRIM(cParam3)||"'");
			END IF;
	
		  LET dtFechaIni = pFechaIni;
		  LET dtFechaFin = pFechaFin;
		
  		--begin;
  		--  INSERT INTO "informix".sd_temp_pagomin_sdovenc(fecha, num_archivo, fecha_ini, fecha_fin) --TEST MACF
      --  VALUES(today, pTipoReporte, dtFechaIni, dtFechaFin);                                     --TEST MACF 
      --commit;
 
      IF  cTabla="N" THEN 
				CREATE TABLE "informix".sd_med_pagomin_rep(
				  SUCURSAL   CHAR(20),
				  NUMERO_CONVENIO	CHAR(20),
				  IMPORTE_CONVENIADO CHAR(20),
				  IMPORTE_PAGADO	CHAR(20),
				  CUMPLIMIENTO CHAR(20)
        );
				LET cTabla="S";
			END IF;
			
			LET cConsulta2 = 'INSERT INTO "informix".sd_med_pagomin_rep (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)';
			IF cParam1 = '1' THEN
				INSERT INTO "informix".sd_med_pagomin_rep (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
				VALUES("COMPROMISOS","","","","");
			ELIF cParam1 = '2' THEN
				INSERT INTO "informix".sd_med_pagomin_rep (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
				VALUES("ACUERDOS","","","","");
			END IF;
			LET cConsulta3 = 'SELECT SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO FROM  "informix".sd_med_pagomin_rep';
			INSERT INTO "informix".sd_med_pagomin_rep (SUCURSAL,NUMERO_CONVENIO,IMPORTE_CONVENIADO,IMPORTE_PAGADO,CUMPLIMIENTO)
			VALUES("SUCURSAL","NUMERO DE CONVENIO","IMPORTE CONVENIADO","IMPORTE PAGADO","CUMPLIMIENTO");
 
      -- Primero descargar archivo
		  LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl'|| ' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query31.sql';
			SYSTEM TRIM(cSql);
		
		  LET cSql = '';
			LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query31.sql';
			SYSTEM TRIM(cSql);
		
		  LET cSql = "chmod 777 " || TRIM(cRuta) || 'query31.sql';
      SYSTEM TRIM(cSql); 
		
		  LET cSql = '';
			LET cSql = 'echo "LOAD FROM ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl'|| ' '||TRIM(cConsulta2)||'" > '|| TRIM(cRuta) ||'query41.sql';
			SYSTEM TRIM(cSql);

      LET cSql = '';
			LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query41.sql';
			SYSTEM TRIM(cSql);
      
      LET cSql = "chmod 777 " || TRIM(cRuta) || 'query41.sql';
      SYSTEM TRIM(cSql);
 
      END FOREACH;
 
 ELIF pTipoReporte = 3 THEN

      --LET cNombreArchivo= TRIM(cNombreArchivo)|| TRIM(cArch_medidor_compac) || LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha);
   		LET dtFechaIni = pFechaIni;
	   	LET dtFechaFin = pFechaFin;
		
  	--begin;
  	--	  INSERT INTO "informix".sd_temp_pagomin_sdovenc(fecha, num_archivo, fecha_ini, fecha_fin)    --TEST MACF 
    --   VALUES(today, pTipoReporte, dtFechaIni, dtFechaFin);                                        --TEST MACF
    -- commit;
 
      CALL "informix".sp_compac_pagomin_sdovenc(pEmpresa, dtFechaIni, dtFechaFin) Returning vvCodRet, vvMensajeRet, vvNombreArchivo;  
      
      --LET cNombreArchivo= TRIM(vvNombreArchivo)||'.txt';
      LET cNombreArchivo= TRIM(vvNombreArchivo);
                      
      if vvCodRet <> '00000' then
          LET cCodRet = '000997'; 
          LET cMensajeRet = 'Error en call sp_compac_pagomin_sdovenc.';
          RETURN cCodRet, trim(cMensajeRet),cNombreArchivo;
      else    
          RETURN cCodRet, cMensajeRet,cNombreArchivo;
      end if;
 
 END IF;

   	
		LET cConsulta3 =' '||TRIM(cConsulta3);
		LET cSql = '';
		--LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''|''' || ' ' ||TRIM(cConsulta3)||'" > '|| TRIM(cRuta) ||'query2.sql';
		-- LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''	'''|| ' ' ||TRIM(cConsulta3)||'" > '|| TRIM(cRuta) ||'query1926.sql';		
		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.txt '|| TRIM(cConsulta3)||'" > '|| TRIM(cRuta) ||'query1926.sql';
    SYSTEM TRIM(cSql);
		
		LET cSql = '';
		LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query1926.sql';
		SYSTEM TRIM(cSql);
	
    --LET cSql = "rm " ||TRIM(cRuta)||'query2013.sql';
    --SYSTEM TRIM(cSql);
    
    --2013-01-24 para evitar que envíe error -668
    LET cSql = "chmod 777 " || TRIM(cRuta) || 'query1926.sql';
    SYSTEM TRIM(cSql); 
	  
		IF cTabla="S" THEN
			DROP TABLE "informix".sd_med_pagomin_rep;
		END IF;
		-- LET cNombreArchivo= TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo);
		LET cNombreArchivo= TRIM(cNombreArchivo)||'.txt';
		
		LET cSql = '';
    LET cSql = "gzip  " ||trim(cRuta)|| trim(cNombreArchivo);
    SYSTEM trim(cSql);
    
    LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
		
		
		RETURN cCodRet, cMensajeRet,cNombreArchivo;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la generacion de archivos de los tipos de reportes para estadistica de convenios',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 05/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110404.0850',
'Se modifica para que use el tabulador como separador en la generación del archivo',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 20/04/2011',
'BD    : BDICOBRANZA',
'Version: 20110420.1250',
'2012-05-16 Si existe borrar la tabla "informix".cb_med_pagomin_rep al inicio del proceso. Autor: Marco A. Campos',
'AUTOR : Mohamed Carreón',
'FECHA : 23/08/2012',
'BD    : BDICRED',
'Version: 20120823.1703',
'Se modifica para migrar el sp a la bd bdicred y para cambiar de nombre las columnas y agregar 1 coumna nueva esto para el archivo tipo 3.';

CREATE PROCEDURE "informix".sp_corresp_movtoscred(pEmpresa  CHAR(3),
                                                  pEjecutivo   CHAR(8),
                                                  pFecha   DATE,
                                                  pFolioSuc    CHAR(16))

RETURNING CHAR(6)		AS retorno,
          CHAR(100)		AS mensaje_ret,
          CHAR(20)		AS num_credito,
          CHAR(16)		AS folio_suc,
          DECIMAL(18,2)	AS monto,
          VARCHAR(250)	AS referencia,
          CHAR(16)		AS num_tarjeta,
          CHAR(104)		AS titular_cta,
          CHAR(20)		AS num_cte,
          CHAR(1)		AS reversado;

    DEFINE iSqlErr      	    INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo           CHAR(80);
    DEFINE cCodRet              CHAR(6);

    DEFINE cMensajeRet    	  	CHAR(100);
    DEFINE cNumCredito          CHAR(20);
    DEFINE cFolioSuc            CHAR(16);
    DEFINE dMonto               DECIMAL(18,2);

    DEFINE cReferencia          VARCHAR(250);
    DEFINE cNumTarjeta          CHAR(16);      
    DEFINE cNombreCte           CHAR(104);
    DEFINE cNumcte              CHAR(20);

    DEFINE cReversado           CHAR(1);
    DEFINE dtFechaIni           DATE;
    DEFINE dtFechaHoy           DATE;
    DEFINE iSecuenciaMov        INTEGER;

    DEFINE iPagina              SMALLINT;
    DEFINE iNumRegPag   		SMALLINT;

    LET iSqlErr			= 0;
    LET iIsamErr        = 0;
    LET cErrorInfo      = "";
    LET cCodRet         = "000000";

    LET cMensajeRet     = "Proceso realizado correctamente.";
    LET cNumCredito = "";
    LET cFolioSuc = "";
    LET dMonto = 0;

    LET cReferencia = "";
    LET cNumTarjeta = "";
    LET cNombreCte = "";
    LET cNumcte = "";

    LET cReversado = "";
    LET dtFechaIni = "";
    LET dtFechaHoy = "";
    LET iSecuenciaMov   = 0;

    LET iPagina = 1;
    LET iNumRegPag  = 0;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet= iSqlErr;
        LET cMensajeRet= cErrorInfo;
        RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
    END EXCEPTION;

--set debug file to "/informix/VILLELA/sp_corresp_movtoscred.out";
--trace on;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF NVL(pEmpresa, "") = "" OR NVL(pFecha,"") = "" OR NVL(pFolioSuc,"") = "" THEN
        LET cCodRet = "000001";
        LET cMensajeRet = "Los datos de entrada no se han proporcionado correctamente.";
        RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
    END IF;

    IF NOT EXISTS(SELECT empresa FROM bdinteg:si_empresas WHERE empresa = pEmpresa) THEN
        LET cCodRet = "000002";
        LET cMensajeRet = "La empresa indicada no existe en el catálogo de empresas";
        RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
    END IF;

    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;

    LET dtFechaIni = dtFechaHoy - 90 UNITS DAY;

    IF pFecha < dtFechaIni OR pFecha > dtFechaHoy THEN
        LET cCodRet = "000003";
        LET cMensajeRet = "La fecha recibida no se encuentra dentro del rango permitido.";
        RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
    END IF;

    SELECT pagina, count(num_cuenta)
      INTO iPagina, iNumRegPag
      FROM bdicred:"informix".sd_movtos_corresponsal
     WHERE empresa = pEmpresa
       AND ejecutivo = pEjecutivo
       AND fecha_insert = dtFechaHoy
       AND pagina = (SELECT MAX(pagina) 
                       FROM bdicred:"informix".sd_movtos_corresponsal
                      WHERE empresa = pEmpresa
                        AND ejecutivo = pEjecutivo
                        AND fecha_insert = dtFechaHoy)
     group by pagina; 


    IF nvl(iPagina,0) = 0  THEN
        LET iPagina = 1;
    END IF;

    IF pFecha =  dtFechaHoy THEN

        SELECT d.num_credito, d.folio_suc, d.monto, d.referencia, tar.num_tarjeta,
               trim(c.nombre1) || " " || trim(c.nombre2)||" "|| trim(c.apell_paterno)||" "|| trim(c.apell_materno),
               m.numcte, d.reversado
        INTO cNumCredito, cFolioSuc, dMonto, cReferencia, cNumTarjeta, cNombreCte, cNumcte, cReversado
          FROM     bdicred:"informix".sd_movdia d,
                   bdicred:"informix".sd_maecred m,
                   bdicred:"informix".sd_tarjeta tar,
                   bdinteg:"informix".si_cliente c
         WHERE d.empresa = m.empresa
           AND d.num_credito = m.num_credito
           AND m.empresa = c.empresa
           AND m.numcte = c.numcte
           AND d.transacc_suc = "6282"
           AND d.fecha_mov  = pFecha
           AND d.folio_suc = pFolioSuc
           AND d.codigo_fun = 700
           AND d.codigo_ref = 1
           AND tar.empresa = m.empresa
           AND tar.num_credito = m.num_credito
           AND tar.tipo_tarjeta = 'T'
           AND tar.status_tar = 'A';

        LET iNumRegPag = nvl(iNumRegPag,0) + 1;

        IF nvl(iNumRegPag,0) > 30 THEN
            LET iPagina = iPagina + 1;
            LET  iNumRegPag = 0;
        END IF;
        
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000004";
            LET cMensajeRet = "No existen movimientos para los criterios proporcionados.";
            RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
        ELSE
            INSERT INTO bdicred:"informix".sd_movtos_corresponsal 
            ( empresa, ejecutivo, num_cuenta, folio, monto, referencia, num_tarjeta, titular, numcte, reversado, pagina, fecha_insert)
            VALUES 
            (pEmpresa, pEjecutivo, cNumCredito, cFolioSuc, dMonto, cReferencia, cNumTarjeta, cNombreCte, cNumcte, cReversado, iPagina, dtFechaHoy);

            RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
        END IF;
        
    ELIF pFecha <  dtFechaHoy THEN

        SELECT h.num_credito, h.folio_suc, h.monto, h.referencia, tar.num_tarjeta,
               trim(cl.nombre1) || " " || trim(cl.nombre2)||" "|| trim(cl.apell_paterno)||" "|| trim(cl.apell_materno),
               mc.numcte, h.reversado
          INTO cNumCredito, cFolioSuc, dMonto, cReferencia, cNumTarjeta, cNombreCte, cNumcte, cReversado
          FROM bdicred:"informix".sd_movhis h,
               bdicred:"informix".sd_maecred mc,
               bdicred:"informix".sd_tarjeta tar,
               bdinteg:"informix".si_cliente cl
         WHERE h.empresa = mc.empresa
           AND h.num_credito = mc.num_credito
           AND h.empresa = cl.empresa
           AND mc.numcte = cl.numcte
           AND h.transacc_suc = "6282"
           AND h.fecha_mov = pFecha
           AND h.folio_suc = pFolioSuc
           AND h.codigo_fun=700
           AND h.codigo_ref =1
           AND tar.empresa = mc.empresa
           AND tar.num_credito = mc.num_credito
           AND tar.tipo_tarjeta = 'T'
           AND tar.status_tar = 'A';

        LET iNumRegPag = nvl(iNumRegPag,0) + 1;

        IF iNumRegPag > 30 THEN
            LET iPagina = iPagina + 1;
            LET  iNumRegPag = 0;
        END IF;
        
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = "000004";
            LET cMensajeRet = "No existen movimientos para los criterios proporcionados.";
            RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
        ELSE
            INSERT INTO bdicred:"informix".sd_movtos_corresponsal 
            ( empresa, ejecutivo, num_cuenta, folio, monto, referencia, num_tarjeta, titular, numcte, reversado, pagina, fecha_insert)
            VALUES 
            ( pEmpresa, pEjecutivo, cNumCredito, cFolioSuc, dMonto, cReferencia, cNumTarjeta, cNombreCte, cNumcte, cReversado, iPagina, dtFechaHoy);
            
            RETURN cCodRet,cMensajeRet,NVL(cNumCredito,""),NVL(cFolioSuc,""),NVL(dMonto,0),NVL(cReferencia,""),NVL(cNumTarjeta,""),NVL(cNombreCte,""),NVL(cNumcte,""),NVL(cReversado,"");
        END IF;
    END IF;    
    
    END
    
END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que obtiene los movimientos de pagos y depósitos realizados en corresponsal para cuentas de crédito. ",
"Base de datos: bdicred",
"Autor: Viridiana Osobampo A.",
"Fecha: 20-Abr-2011";

CREATE PROCEDURE "informix".sp_convsyvencido_sucursal(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE)
RETURNING CHAR(5)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;
 
---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cSucursal        CHAR(4);
DEFINE cNumcte          CHAR(20);
DEFINE dFecha_Mov       DATE;
DEFINE dFecha_Reg       DATE;
DEFINE iNumctes_vencido INTEGER;
DEFINE iCantidad        INTEGER;
DEFINE dFecha_Compac    DATE; 
DEFINE dFecha_ini       DATE;
DEFINE dFecha_fin       DATE;
DEFINE dFecha_ini_2     DATE;
DEFINE dFecha_fin_2     DATE;
DEFINE dFecha_temp      DATE;
DEFINE cFechaIni        CHAR(10);
DEFINE cFechaFin        CHAR(10);
              
---INICIALIZACIONES
LET cCodRet             = "00000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cSucursal           = '';
LET cNumcte             = '';
LET dFecha_Mov           = DATE(1);
LET dFecha_Reg          = DATE(1);
LET iNumctes_vencido    = 0;
LET iCantidad           = 0;
LET dFecha_Compac       = DATE(1);
LET dFecha_ini          = DATE(1);
LET dFecha_fin          = DATE(1);
LET dFecha_ini_2        = DATE(1);
LET dFecha_fin_2        = DATE(1);
LET dFecha_temp         = DATE(1);
LET cFechaIni           = ''; 
LET cFechaFin           = '';


BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
  	  LET cMensajeRet = cErrorInfo;
    	     	
      RETURN cCodRet, cMensajeRet;
  END EXCEPTION;

--  SET DEBUG FILE TO 'sp_rep_convenios_sif.trc';
--  TRACE ON;
  
  truncate "informix".sd_vencidos_fecha;
  
  
  
  LET dFecha_ini = pFechaIni;
  LET dFecha_fin = pFechaFin;
  
--  LET dFecha_temp = dFecha_ini + 1 UNITS MONTH;
  
  LET dFecha_ini_2 = mdy(month(dFecha_ini),1,year(dFecha_ini));  
  LET dFecha_fin_2 = (mdy(month(dFecha_ini_2),1,year(dFecha_ini_2)) + 1 UNITS MONTH) - 1 UNITS DAY;
--temporal solo para pruebas
--RETURN cCodRet, cMensajeRet;
--temporal solo para pruebas
  IF NVL(pEmpresa,"") = "" OR  NVL(dFecha_ini,"") = "" OR  NVL(dFecha_fin,"") = "" THEN
  	LET cCodRet= "000001";
  	LET cMensajeRet = "Parametro no valido para realizar la consulta";
  	RETURN cCodRet, cMensajeRet;
  END IF;

		--SELECT fecha_hoy  INTO dtFecha 
		--  FROM bdicred:sd_fechas
		-- WHERE empresa = pEmpresa;
		 
  LET cFechaIni = year(dFecha_ini) || '/' || lpad(month(dFecha_ini),2,0) || '/' || lpad(day(dFecha_ini),2,0);
  LET cFechaFin = year(dFecha_fin) || '/' || lpad(month(dFecha_fin),2,0) || '/' || lpad(day(dFecha_fin),2,0);

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  ---------------- Clientes con vencido por sucursal
  FOREACH with hold
        SELECT {+INDEX(bdicobranza:"informix".cb_compac_bit_realiza idx_compacbitrealiza_fh)} 
                 sucursal, 
                 numcliente, 
                 DATE(fh_movimiento) 
          INTO cSucursal, cNumcte, dFecha_Mov         
          FROM bdicobranza:cb_compac_bit_realiza
         WHERE fh_movimiento BETWEEN TO_DATE(cFechaIni, "%Y/%m/%d") AND TO_DATE(cFechaFin, "%Y/%m/%d")
         GROUP BY 1,2,3
      
         BEGIN;
          INSERT INTO "informix".sd_vencidos_fecha(sucursal, numcliente, fh_movimiento, cantidad)
            VALUES (cSucursal, cNumcte, dFecha_Mov,1);
         COMMIT; 
    END FOREACH;
  
    
  FOREACH WITH HOLD
      SELECT sucursal, fh_movimiento, sum(cantidad)
        INTO cSucursal, dFecha_Reg, iNumctes_vencido  
        FROM "informix".sd_vencidos_fecha
       WHERE sucursal || fh_movimiento not in (select sucursal || fecha_reg 
                                                   from "informix".sd_vencidos_suc where fecha_reg between dFecha_ini and dFecha_fin) 
       GROUP BY fh_movimiento, sucursal 
      
      BEGIN WORK;
         INSERT INTO "informix".sd_vencidos_suc (sucursal, fecha_reg, numctes_vencido)
          VALUES(cSucursal, dFecha_Reg, iNumctes_vencido);   
      COMMIT WORK;
      
  END FOREACH;      

  ---------------- Convenios creados por sucursal
  FOREACH WITH HOLD  
      SELECT a.sucursal, a.fecha_compac, count(*) as cantidad
        INTO cSucursal, dFecha_Compac, iCantidad 
        FROM bdicobranza:cb_compac_his a  
       WHERE a.fecha_compac between dFecha_ini and dFecha_fin
         AND a.origen = 2
         and a.sucursal || a.fecha_compac not in(select sucursal || fecha from "informix".sd_convenios_sucursal where fecha = a.fecha_compac and sucursal = a.sucursal)
        GROUP BY 1,2

        BEGIN;
            INSERT INTO "informix".sd_convenios_sucursal(sucursal, fecha, cantidad)
            VALUES(cSucursal, dFecha_Compac, iCantidad);
        COMMIT;

  END FOREACH;
      
      LET iCantidad = 0;
      LET cSucursal = '';
      LET dFecha_Compac = date(1);
      
      -- Agregar lo que se encuentre en cb_compac.
      FOREACH WITH HOLD
        SELECT a.sucursal, a.fecha_compac, COUNT(*)
          INTO cSucursal, dFecha_Compac, iCantidad 
          FROM bdicobranza:cb_compac a
         WHERE a.empresa = pEmpresa AND activo = '1' 
           AND a.fecha_compac BETWEEN dFecha_ini AND dFecha_fin
           AND a.origen = 2
          GROUP BY 1,2

        IF EXISTS (SELECT sucursal FROM "informix".sd_convenios_sucursal WHERE sucursal = cSucursal AND fecha = dFecha_Compac) THEN
           BEGIN;
              UPDATE "informix".sd_convenios_sucursal SET cantidad = cantidad + iCantidad WHERE sucursal = cSucursal AND fecha = dFecha_Compac; 
           COMMIT;
        ELSE
            BEGIN;
              INSERT INTO "informix".sd_convenios_sucursal(sucursal, fecha, cantidad) VALUES(cSucursal, dFecha_Compac, iCantidad);
            COMMIT;
        END IF;
      
      END FOREACH;
    
		RETURN cCodRet, cMensajeRet;
		
END
END PROCEDURE
;
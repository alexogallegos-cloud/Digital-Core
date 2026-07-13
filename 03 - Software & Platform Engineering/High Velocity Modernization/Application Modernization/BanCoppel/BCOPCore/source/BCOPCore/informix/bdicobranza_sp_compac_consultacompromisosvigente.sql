CREATE PROCEDURE "informix".sp_compac_consultacompromisosvigente( pEmpresa CHAR(3), pNumCuenta CHAR(20))
RETURNING CHAR(5)       AS Codigo_Retorno,
          CHAR(80)      AS Mensaje_Retorno,
          DATE          AS Fecha_Convenio,
          DATE          AS Fecha_Vencimiento,
          DECIMAL(14,2) AS Importe,
          CHAR (3)      AS Origen;
--------------------------------------------------------------
--ACTIVIDAD: Consulta la informacion de los convenios activos
--por determinado numero de cliente.
--------------------------------------------------------------
--definicion de variables
DEFINE cCodRet             CHAR(5); 
DEFINE cActivo             CHAR(1); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr      	   INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE dtFechaConvenio     DATE;
DEFINE dtFechaVencimiento  DATE;
DEFINE dImporte      	   DECIMAL(14,2);
DEFINE cOrigen 			   CHAR(3);
DEFINE iTotalctas 	   	   INTEGER;
DEFINE iPlazo 	  		   INTEGER;
DEFINE iDiasplazo 	   	   INTEGER;
DEFINE iOrigen		 	   INTEGER;
DEFINE iCont		 	   INTEGER;
DEFINE dtFechaHoy		   DATE;
--inicializacion de variables	  
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '00000';
LET cActivo                  = '0';
LET cMensajeRet              = 'Se realizó la consulta correctamente';	  
LET dtFechaConvenio          = DATE(1);	  
LET dtFechaVencimiento       = DATE(1);	
LET dImporte                 = 0;  
LET iPlazo                   = 0;  
LET cOrigen                  = '';
LET iTotalctas               = 0;
LET iDiasplazo               = 0;
LET iOrigen           		 = 0;
LET iCont           		 = 0;
LET dtFechaHoy				 = DATE(1);

--Set debug file to '/home/sysifx/jesusm/sp_debug.out';
--trace on;	

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
          RETURN  cCodRet,cMensajeRet,dtFechaConvenio,dtFechaVencimiento,dImporte,cOrigen;
       END IF;
    END EXCEPTION;

    IF pEmpresa IS NULL OR TRIM(pEmpresa) = ""  THEN
        LET cCodRet                  = '00001';
        LET cMensajeRet              = 'El parametro Empresa no es valido';
        RETURN  cCodRet,cMensajeRet,NVL(dtFechaConvenio,DATE(1)),NVL(dtFechaVencimiento,DATE(1)),NVL(dImporte,0),NVL(cOrigen,'');		
    END IF;

    IF pNumCuenta IS NULL OR TRIM(pNumCuenta) = ""  THEN
        LET cCodRet                  = '00002';
        LET cMensajeRet              = 'El  parametro Numero de cuenta no es valido';
        RETURN  cCodRet,cMensajeRet,NVL(dtFechaConvenio,DATE(1)),NVL(dtFechaVencimiento,DATE(1)),NVL(dImporte,0),NVL(cOrigen,'');		
    END IF;
	
	SELECT fecha_hoy
	  INTO dtFechaHoy
	  FROM bdicred:"informix".sd_fechas
	 WHERE empresa = pEmpresa;

--validar si el numero de credito existe
	SELECT COUNT(num_credito) 
	  INTO iTotalctas
	  FROM bdicred:sd_maecred
	 WHERE empresa = pEmpresa 
	   AND status_cred <> 'CC' 
	   AND num_credito = pNumCuenta;
	   
	 --valida si esxiste en crd
	if (iTotalctas = 0)then
	SELECT COUNT(num_credito) 
	  INTO iTotalctas
	  FROM bdicred:sd_maecredcrd
	 WHERE empresa = pEmpresa 
	   AND status_cred <> 'CC' 
	   AND num_credito = pNumCuenta;
	 end if;

	IF iTotalctas <> 0 THEN
                 --validar si tiene un compromiso vigente
                SELECT {+INDEX(bdicobranza:cb_compac idx_compac1)} limit 1 activo,plazo, importe, fecha_compac, origen
                  INTO cActivo, iPlazo, dImporte, dtFechaConvenio, iOrigen
                  FROM bdicobranza:cb_compac 
                 WHERE empresa = pEmpresa 
                   AND numcuenta = pNumCuenta
                   AND activo <> '0';

                    LET iCont = dbinfo("sqlca.sqlerrd2");

                    IF iCont = 0 THEN
                        -- Cliente no tiene cuentas con convenios de pago vigentes para ese credito
                        LET cCodRet = '00003';
                        LET cMensajeRet = 'El Numero de Crédito no tiene convenios vigentes';	  
                        RETURN  cCodRet,cMensajeRet,NVL(dtFechaConvenio,DATE(1)),NVL(dtFechaVencimiento,DATE(1)),NVL(dImporte,0),NVL(cOrigen,'');	 
                    END IF;

                    LET iDiasplazo = 0;
                    LET iDiasplazo = NVL(iPlazo,0) * 7;                  
                    LET dtFechaVencimiento = dtFechaConvenio + iDiasplazo ; 

					IF dtFechaVencimiento < dtFechaHoy THEN
						LET cCodRet = '00005';
						LET cMensajeRet = 'El Numero de Crédito no tiene convenios vigentes';	  
                        RETURN  cCodRet,cMensajeRet,NVL(dtFechaConvenio,DATE(1)),NVL(dtFechaVencimiento,DATE(1)),NVL(dImporte,0),NVL(cOrigen,'');	 
					END IF;

                    IF iOrigen = '1' THEN
                        LET cOrigen = 'COB';
                    ELIF iOrigen = '2' THEN
                        LET cOrigen = 'SUC';
                    ELIF iOrigen = '3' THEN
                        LET cOrigen = 'CAT';
                    END IF;

                    RETURN  cCodRet,cMensajeRet,NVL(dtFechaConvenio,DATE(1)),NVL(dtFechaVencimiento,DATE(1)),NVL(dImporte,0),NVL(cOrigen,'');	
	
    ELSE
	-- Cliente no tiene cuentas de credito
		LET cCodRet = '00004';
		LET cMensajeRet = 'El numero de crédito no existe'; 
		RETURN  cCodRet,cMensajeRet,NVL(dtFechaConvenio,DATE(1)),NVL(dtFechaVencimiento,DATE(1)),NVL(dImporte,0),NVL(cOrigen,''); 
    END IF;  	
END;
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para validar si el numero de crédito tiene un convenio vigente, y de ser asi mostrar la informacion del convenio',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 17/08/2010',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_consultarcompromisosacuerdos(pEmpresa      CHAR(3), 
                                                                        pNumDivision  INTEGER, 
                                                                        pNumRegion    INTEGER, 
                                                                        pNumSucursal  CHAR(4), 
                                                                        pFechaInicio  CHAR(10), 
                                                                        pFechaFin     CHAR(10),
                                                                        pUsuario      CHAR(8),
																		pTipoEjecucion SMALLINT)
RETURNING CHAR(6)        AS COD_RET,
          CHAR(80)       AS DESCRIPCION,
          VARCHAR(100)   AS DIVISION,
          CHAR(30)       AS REGION,
          CHAR(4)        AS SUCURSAL,
          INTEGER        AS NUM_RDOS_COMP,
          DECIMAL(18,2)  AS IMP_NEG_COMP,
          DECIMAL(18,2)  AS IMP_REC_COMP,
          DECIMAL(8,2)   AS PORC_CUMP_COMP,
          INTEGER        AS NUM_RDOS_ACUE,
          DECIMAL(18,2)  AS IMP_NEG_ACUE,
          DECIMAL(18,2)  AS IMP_REC_ACUE,
          DECIMAL(8,2)   AS PORC_CUMP_ACUE,
          DATE           AS FECHA_ACUE_COMP;
    
---DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE iNRows               INTEGER;

DEFINE iDivision            INTEGER;
DEFINE cNomDivision         VARCHAR(100);
DEFINE iRegion              INTEGER;
DEFINE cNomRegion           CHAR(30);
DEFINE cSucursal            CHAR(4);
DEFINE iNum_Rdos            INTEGER;
DEFINE dImp_Neg             DECIMAL(18,2);
DEFINE dImp_Rec             DECIMAL(18,2);
DEFINE dPorc_Cump           DECIMAL(8,2);

DEFINE iNum_Rdos_Comp       INTEGER;
DEFINE dImp_Neg_Comp        DECIMAL(18,2);
DEFINE dImp_Rec_Comp        DECIMAL(18,2);
DEFINE dPorc_Cump_Comp      DECIMAL(8,2);
DEFINE iNum_Rdos_Acue       INTEGER;
DEFINE dImp_Neg_Acue        DECIMAL(18,2);
DEFINE dImp_Rec_Acue        DECIMAL(18,2);
DEFINE dPorc_Cump_Acue      DECIMAL(8,2);
DEFINE dFechaAcueComp       DATE;
DEFINE cUsuario             CHAR(8);
DEFINE iNumSesion           INTEGER;
DEFINE iId_sesion           INTEGER;
DEFINE iRegistros           INTEGER;
DEFINE iContador            INTEGER;

DEFINE cNombreArchivo	  CHAR(80);
DEFINE cSql           CHAR(1024);
DEFINE cRuta		      CHAR(80);   
DEFINE cConsulta		  CHAR(2200);
DEFINE cTabla		      CHAR(1); 
DEFINE cFechaAcueComp	  CHAR(10); 

    
---INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cErrorInfo              = "";
LET cCodRet                 = "000000";
LET cMensajeRet             = "PROCESO EXISTOSO";
LET iNRows                  = 0;

LET iDivision               = 0;
LET cNomDivision            = "";
LET iRegion                 = 0;
LET cNomRegion              = "";
LET cSucursal               = "";
LET iNum_Rdos               = 0;
LET dImp_Neg                = 0.0;
LET dImp_Rec                = 0.0;
LET dPorc_Cump              = 0.0;

LET iNum_Rdos_Comp          = 0;
LET dImp_Neg_Comp           = 0.0;
LET dImp_Rec_Comp           = 0.0;
LET dPorc_Cump_Comp         = 0.0;
LET iNum_Rdos_Acue          = 0;
LET dImp_Neg_Acue           = 0.0;
LET dImp_Rec_Acue           = 0.0;
LET dPorc_Cump_Acue         = 0.0;
LET dFechaAcueComp          = DATE(1);
LET cUsuario                = "";  
LET iNumSesion              = 0;
LET iId_sesion              = 0;
LET iRegistros              = 0;
LET iContador               = 0;
LET cNombreArchivo          = "";
LET cSql             		= "";
LET cRuta					= "";
LET cConsulta               = "";
LET cTabla					= "N";
LET cFechaAcueComp          = "";
    
BEGIN
    
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet = iSqlErr;
      LET cMensajeRet = cErrorInfo;


        DELETE FROM bdicobranza:"informix".cb_consulta_acue_comp WHERE usuario =  pUsuario;

        IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'tmeacuerdos' AND tabid > 99 AND tabtype="T") THEN
            DROP  TABLE tmeacuerdos;
        END IF;

        IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'tmeacuerdosaompromisos2' AND tabid > 99 AND tabtype="T") THEN
            DROP  TABLE tmeacuerdosaompromisos2;
        END IF;

        IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'tmeacuerdosaompromisos3' AND tabid > 99 AND tabtype="T") THEN
            DROP  TABLE tmeacuerdosaompromisos3;
        END IF;
		IF cTabla="S" THEN
			DROP TABLE TME_ENCABEZADOSEXCEL;
		END IF;
        RETURN cCodRet, cMensajeRet, iDivision, iRegion, cSucursal, iNum_Rdos_Comp, dImp_Neg_Comp, dImp_Rec_Comp, dPorc_Cump_Comp, iNum_Rdos_Acue, dImp_Neg_Acue, dImp_Rec_Acue, dPorc_Cump_Acue, dFechaAcueComp;
  END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_ConsultarCompromisosAcuerdos.out";
--TRACE ON;

-- REALIZA VALIDACIONES GENERALES
IF (NVL(pEmpresa,"") = "") OR (pNumDivision IS NULL) OR (pNumRegion IS NULL) OR (pNumSucursal IS NULL) OR (NVL(pFechaInicio,"") = "") 
	OR (NVL(pFechaFin,"") = "") OR (NVL(pUsuario,"") = "") 	OR (pTipoEjecucion NOT IN (1,2)) THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "PARAMETRO INVALIDO";
    RETURN cCodRet, cMensajeRet, iDivision, iRegion, cSucursal, iNum_Rdos_Comp, dImp_Neg_Comp, dImp_Rec_Comp, dPorc_Cump_Comp, iNum_Rdos_Acue, dImp_Neg_Acue, dImp_Rec_Acue, dPorc_Cump_Acue, dFechaAcueComp;		
END IF;
    
-- BORRA LAS TABLAS TEMPORALES SI EXISTEN
IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'tmeacuerdos' AND tabid > 99 AND tabtype="T") THEN
    DROP  TABLE tmeacuerdos;
END IF

IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'tmeacuerdosaompromisos2' AND tabid > 99 AND tabtype="T") THEN
    DROP  TABLE tmeacuerdosaompromisos2;
END IF

IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'tmeacuerdosaompromisos3' AND tabid > 99 AND tabtype="T") THEN
    DROP  TABLE tmeacuerdosaompromisos3;
END IF

SELECT DBINFO('sessionid')
  INTO iNumSesion
  FROM "informix".systables
 WHERE tabname = 'systables';
 
--se obtiene el numero de registros a retornar en la consulta
SELECT NVL(valor_numerico,0)::INTEGER
INTO iRegistros
FROM "informix".cb_param_campania
WHERE empresa = '001'
AND tipo_campania = 21 
AND grupo_parametro = 'ESTADCOYAC'
AND num_parametro = 1;
 
IF NVL(iRegistros,0) = 0 THEN
	LET cCodRet= "000003";
	LET cMensajeRet = "No se pudo obtener el numero de registros a retornar";
	RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, '';		
END IF;	 
 
 --se obtiene la ruta donde se almacenara el archivo generado.
	SELECT  TRIM(valor_alfabetico) 
	INTO cRuta
	FROM "informix".cb_param_campania
	WHERE tipo_campania = 11  
	AND  grupo_parametro = 'RUTAS'
	AND num_parametro =1;
	
IF NVL(cRuta,"") = "" THEN
	LET cCodRet= "000004";
	LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
	RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, '';		
END IF;	
----------------------------------------------------    CONSULTA DE COMPROMISOS   ----------------------------------------------------
INSERT INTO bdicobranza:"informix".cb_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp,
                                                          imp_rec_comp, porc_cump_comp, usuario, id_sesion )
     SELECT reg.division, par.descripcion, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2), 
            SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(18,2), pUsuario, iNumSesion
       FROM bdicobranza:"informix".cb_compac_his ch, 
            bdinteg:"informix".si_ciudades ciu, 
            bdinteg:"informix".si_catciudades cat,
            bdinteg:"informix".si_regiones reg,
            bdinteg:"informix".si_sucursales suc,
            bdicobranza:"informix".cb_param_campania par
      WHERE suc.estado  = ciu.estado
        AND suc.ciudad  = ciu.ciudad
        AND ch.sucursal = suc.sucursal
        AND cat.numerociudad  = ciu.ciudad_coppel
        AND cat.numero_region = reg.numero_region
        AND ch.tipo_compac = "1" 
        AND ch.empresa = pEmpresa
        AND ch.fecha_insert >= pFechaInicio
        AND ch.fecha_insert <= pFechaFin
        AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
        AND par.num_parametro = reg.division
        AND par.grupo_parametro = "DIVISIONES"
        AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
        AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)
   GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion;

----------------------------------------------------    CONSULTA DE ACUERDOS   ----------------------------------------------------
	SELECT reg.division AS division, par.descripcion AS nom_division, cat.numero_region AS region, reg.nombre_region AS nom_region, ch.sucursal AS sucursal,
	       ch.fecha_insert AS fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue,SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,
	       SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(18,2) AS porc_cump_acue,
	       pUsuario AS usuario, iNumSesion AS id_sesion 
	  FROM bdicobranza:"informix".cb_compac_his ch, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catciudades cat,
	       bdinteg:"informix".si_regiones reg, bdinteg:"informix".si_sucursales suc,  bdicobranza:"informix".cb_param_campania par
	 WHERE suc.estado = ciu.estado
	   AND suc.ciudad = ciu.ciudad
	   AND ch.sucursal = suc.sucursal
	   AND cat.numerociudad = ciu.ciudad_coppel
	   AND cat.numero_region = reg.numero_region
	   AND ch.tipo_compac = "2" 
	   AND ch.empresa = pEmpresa
	   AND ch.fecha_insert >= pFechaInicio
	   AND ch.fecha_insert <= pFechaFin
	   AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
       AND par.num_parametro = reg.division
	   AND par.grupo_parametro = "DIVISIONES"
	   AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
	   AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)  
  GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion 
      INTO TEMP tmeacuerdos WITH NO LOG;
	
    
    SELECT t1.division, t2.region, t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue,
		   t2.porc_cump_acue , t1.usuario , t1.id_sesion
      FROM bdicobranza:"informix".cb_consulta_acue_comp t1, bdicobranza:tmeacuerdos t2
     WHERE t1.division = t2.division 
       AND t1.region   = t2.region 
       AND t1.sucursal = t2.sucursal 
       AND t1.fecha_acuecomp = t2.fecha
	   AND t1.usuario   =  pUsuario
	   AND t1.id_sesion = iNumSesion
      INTO TEMP tmeacuerdosaompromisos2 WITH NO LOG;
    
FOREACH 
    SELECT division, region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue  
      INTO iDivision, iRegion, cSucursal, dFechaAcueComp, iNum_Rdos, dImp_Neg, dImp_Rec, dPorc_Cump
      FROM tmeacuerdosaompromisos2
     WHERE usuario  = pUsuario
       AND id_sesion = iNumSesion

    UPDATE bdicobranza:"informix".cb_consulta_acue_comp
       SET num_rdos_acue = iNum_Rdos, imp_neg_acue = dImp_Neg, imp_rec_acue = dImp_Rec, porc_cump_acue = dPorc_Cump
     WHERE division = iDivision 
       AND region = iRegion 
       AND sucursal = cSucursal 
       AND fecha_acuecomp = dFechaAcueComp
       AND usuario  = pUsuario
       AND id_sesion =  iNumSesion;
END FOREACH

           SELECT t2.division, t2.nom_division, t2.region, t2.nom_region, t2. sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue,  
                   t2.imp_rec_acue, t2.porc_cump_acue, t1.division as division2, t2.usuario, t2.id_sesion
            FROM bdicobranza:"informix".cb_consulta_acue_comp t1
RIGHT OUTER JOIN bdicobranza:tmeacuerdos t2 ON (t1.division = t2.division AND t1.region = t2.region AND t1.sucursal = t2.sucursal 
                                                AND t1.fecha_acuecomp = t2.fecha AND t1.usuario = t2.usuario AND t1.id_sesion = t2.id_sesion)
           WHERE  t2.usuario = pUsuario
             AND t2.id_sesion = iNumSesion
            INTO TEMP tmeacuerdosaompromisos3 WITH NO LOG;
            
    INSERT INTO bdicobranza:"informix".cb_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion)
         SELECT division, nom_division, region, nom_region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion
           FROM tmeacuerdosaompromisos3 
          WHERE division2 IS NULL
	        AND usuario   =  pUsuario
	        AND id_sesion = iNumSesion;
			
			
			

DROP  TABLE tmeacuerdos;
DROP  TABLE tmeacuerdosaompromisos2;
DROP  TABLE tmeacuerdosaompromisos3;
--se agrega la tabla temporal
	IF pTipoEjecucion = 2 THEN 	
		CREATE TABLE TME_ENCABEZADOSEXCEL(
					fecha_acuecomp CHAR(10),
					sucursal   CHAR(10),
					num_rdos_comp	CHAR(20),
					imp_neg_comp CHAR(20),
					imp_rec_comp	CHAR(20),
					porc_cump_comp CHAR(20),
					num_rdos_acue CHAR(20),
					imp_neg_acue CHAR(20),
					imp_rec_acue CHAR(20),
					porc_cump_acue CHAR(20)			
					);
		LET cTabla="S";
		--se agrega encabezado para el archivo excel
		INSERT INTO TME_ENCABEZADOSEXCEL (fecha_acuecomp,sucursal,num_rdos_comp,imp_neg_comp,imp_rec_comp, porc_cump_comp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue)
		VALUES("","COMPROMISOS","","","","","ACUERDOS","","","");
		INSERT INTO TME_ENCABEZADOSEXCEL (fecha_acuecomp,sucursal,num_rdos_comp,imp_neg_comp,imp_rec_comp, porc_cump_comp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue)
		VALUES("FECHA","SUCURSAL","No. REALIZADOS","IMPTE. NEGOCIADO","IMPTE. RECUPERADO","% CUMPLIMIENTO","No. REALIZADOS","IMPTE. NEGOCIADO","IMPTE. RECUPERADO","% CUMPLIMIENTO");

	END IF;

-- BARRE LA TABLA DE TRABAJO PARA OBTENER LOS RESULTADOS
FOREACH
    SELECT id_sesion, usuario, nom_division, nom_region, sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp, imp_rec_comp, porc_cump_comp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue
      INTO iId_sesion, cUsuario, cNomDivision,cNomRegion,cSucursal, dFechaAcueComp,iNum_Rdos_Comp,dImp_Neg_Comp,dImp_Rec_Comp,dPorc_Cump_Comp,iNum_Rdos_Acue,dImp_Neg_Acue,dImp_Rec_Acue,dPorc_Cump_Acue
      FROM bdicobranza:"informix".cb_consulta_acue_comp
     WHERE usuario   = pUsuario
       AND id_sesion = iNumSesion
  ORDER BY fecha_acuecomp,sucursal
	LET iContador = iContador + 1; 
    IF pTipoEjecucion =1 AND  iContador <=  iRegistros THEN 
	    RETURN cCodRet, cMensajeRet, NVL(cNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
	    NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(dFechaAcueComp,MDY(1,1,1900)) WITH RESUME;
    END IF;	
	
	IF pTipoEjecucion = 2 THEN 
		LET cFechaAcueComp=DAY(dFechaAcueComp)||'-'||MONTH(dFechaAcueComp)||'-'||YEAR(dFechaAcueComp);	
		INSERT INTO TME_ENCABEZADOSEXCEL
		(fecha_acuecomp,sucursal,num_rdos_comp,imp_neg_comp,imp_rec_comp, porc_cump_comp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue)
		VALUES(cFechaAcueComp,cSucursal,iNum_Rdos_Comp,dImp_Neg_Comp,dImp_Rec_Comp,dPorc_Cump_Comp,iNum_Rdos_Acue,dImp_Neg_Acue,dImp_Rec_Acue,dPorc_Cump_Acue);	
		LET cFechaAcueComp="";	
	END IF;
END FOREACH
    
LET iNRows = dbinfo("sqlca.sqlerrd2");
IF iNRows = 0 THEN
    LET cCodRet = "000002";
    LET cMensajeRet = "NO EXISTEN DATOS PARA ESTA CONSULTA";
    RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, MDY(1,1,1900);
ELSE
	DELETE FROM bdicobranza:"informix".cb_consulta_acue_comp  WHERE usuario  = pUsuario   AND id_sesion = iId_sesion;
END IF

IF pTipoEjecucion = 2 THEN 
	LET cNombreArchivo= TRIM(pUsuario)||iNumSesion||DAY(CURRENT) || LPAD(TRIM(MONTH(CURRENT)::CHAR(2)),2,'0') || YEAR(CURRENT);
	LET cConsulta = "SELECT fecha_acuecomp,sucursal, num_rdos_comp, imp_neg_comp,imp_rec_comp, porc_cump_comp, num_rdos_acue, imp_neg_acue, imp_rec_acue,porc_cump_acue FROM TME_ENCABEZADOSEXCEL";
	
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
   	SYSTEM TRIM(cSql);
	
	LET cSql = '';
	LET cSql = "dbaccess bdicobranza " ||TRIM(cRuta)||'query1.sql';
	SYSTEM cSql;
	LET cSql = '';
	LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
	SYSTEM cSql; 
	
	IF cTabla="S" THEN
			DROP TABLE TME_ENCABEZADOSEXCEL;
	END IF;
	LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';
	RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, '';		
END IF;
  
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento principal para la obtención de los datos de compromisos y convenios.', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 20100827.1152',
'MODIFICACION: Se modifico para que muestre los datos ordenados por Fecha y Sucursal.Tambien se agrego la validacion',
' del tipo de consulta, REGION ,DIVISION O SUCURSAL, ya que por sucursal se mostraran agrupados por fecha, y region y division agrupada por sucursal', 
'AUTOR: Guadalupe Payan, Abigail Vasavilbazo Cañedo ',
'FECHA: Septiembre 2010',
'VERSION: 20101018.1117',
'MODIFICACION: Se modificó para que se pueda trabajar con el aplicativo en varias sesiones al mismo tiempo sin marcar ningun error',
'y se agrega la opcion para generar un archivo excel con la informacion de la consulta, y que solo regrese un cierto numero de registros de muestra',
'AUTOR: Héctor Manuel Bojórquez Ruelas,Jesús Manuel Aguilar Heredia',
'FECHA: Junio 2011',
'VERSION: 20110630.1010',
'MODIFICACION: Se modifica para que se guarde la fecha a formato dd-mm-yyyy en la generacion del archivo',
'AUTOR: Jesús Manuel Aguilar Heredia',
'FECHA: Julio 2011',
'VERSION: 20110708.0949';

CREATE PROCEDURE "informix".sp_consultarsucursales(pEmpresa CHAR(3) ,pRegion SMALLINT ,pSucursal CHAR(4))
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(4) AS SUCURSAL,
	CHAR(40) AS NOMSUCURSAL; 
	
--Muestra las sucursales dependiendo del numero de sucursal, si no se envia el numero de sucursal se realiza por numero de region.  
	
	--DECLARACIONES
    DEFINE iSqlErr         INTEGER;
    DEFINE cCodRet         CHAR(6);
    DEFINE cMensajeRet     CHAR(40);
    DEFINE nrows           INTEGER;
	DEFINE cNomSucursal    CHAR(40);
	DEFINE cNumSuc         CHAR(4);

	---INICIALIZACIONES
    LET iSqlErr            = 0;
    LET cCodRet            = "000000";
    LET cMensajeRet        = "";
    LET nrows              = 0;
	LET cNomSucursal       = "";
	LET cNumSuc            = "0000";
	
BEGIN

    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet, cMensajeRet,cNomSucursal;
       END IF;
    END EXCEPTION;

   --SET ISOLATION TO DIRTY READ;
   --SET LOCK MODE TO WAIT 3;

	---SET DEBUG FILE TO "/dbexportb/vlv/sp_ConsultarSucursales.out";
	---TRACE ON;
	
	IF pSucursal <> "" THEN

		SELECT sucursal, nombre  
		INTO cNumSuc, cNomSucursal 
		FROM bdinteg:si_sucursales WHERE sucursal = pSucursal;

		IF cNumSuc = "0000" OR cNumSuc IS NULL THEN
			Let cCodRet = '000001';
			Let cNumSuc = pSucursal;
			Let cNomSucursal = 'No se Encuentra la Sucursal Requerida';
		END IF;

		RETURN cCodRet,cNumSuc,cNomSucursal;
		
	ELSE

		FOREACH
			SELECT suc.sucursal,suc.nombre
			INTO cNumSuc, cNomSucursal 
			FROM bdinteg: si_ciudades ciu, 
				 bdinteg: si_catciudades cat, 
				 bdinteg: si_regiones reg,
				 bdinteg: si_sucursales suc
			WHERE suc.estado = ciu.estado
			  AND suc.ciudad = ciu.ciudad
			  AND cat.numerociudad = ciu.ciudad_coppel
			  AND cat.numero_region = reg.numero_region
			  AND reg.numero_region = DECODE(pRegion,0,reg.numero_region,pRegion)
			  AND suc.tpo_sucursal = 'S'
			order by suc.sucursal
		    
			RETURN cCodRet,cNumSuc,cNomSucursal WITH RESUME;
            
		END FOREACH

			IF cNumSuc = '0000' THEN
				Let cCodRet = '000002';
				Let cNomSucursal = 'No Existen Sucursales Para la Region';
				RETURN cCodRet,cNumSuc,cNomSucursal WITH RESUME;  ---PRUEBA
			END IF	

	END IF;	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una Consulta con la Informacion de las Sucursales de una Determinada Division', 
'AUTOR: Valentín López',
'FECHA: Agosto 2010',
'VERSION: 201008.0924';

CREATE PROCEDURE "informix".sp_cat_consulta_generales(pEmpresa      CHAR(3),
                                                      pTpoCobranza  CHAR(1),
                                                      pCliente      CHAR(20))

RETURNING CHAR(6)                      AS codigo_respuesta,
          CHAR(20)                     AS num_cliente,
          CHAR(53)                     AS nombre,
          CHAR(26)                     AS apellido_paterno,
          CHAR(26)                     AS apellido_materno,
          CHAR(1)                      AS sexo,
          DATE                         AS fecha_nacimiento,
          CHAR(2)                      AS estado_civil,
          CHAR(300)                    AS domicilio_casa,
          CHAR(300)                    AS domicilio_trabajo,
          CHAR(1)                      AS sit_especial,
          SMALLINT                     AS causa,
          CHAR(1)                      AS puntualidad,
          SMALLINT                     AS eficiencia,
          SMALLINT                     AS calificacion,
          INTEGER                      AS ingreso_mensual_cte,
          CHAR(53)                     AS nombre_referencia,
          CHAR(26)                     AS apellido_paterno_referencia1,
          CHAR(26)                     AS apellido_materno_referencia1,
          CHAR(1)                      AS sexo_referencia,
          CHAR(2)                      AS estado_civil_referencia,          
          DATE                         AS fecha_alta_cte,          
          SMALLINT                     AS llamada_programada,
          DATETIME YEAR TO FRACTION    AS fecha_hora_programada,
          SMALLINT                     AS tpo_cte,
          SMALLINT                     AS tpo_logica, 
          CHAR(1)                      AS tpo_cobranza,
          CHAR(8)                      AS empleado_trabajo_ult_vez,
          DATETIME YEAR TO FRACTION    AS fecha_ult_contacto,
          CHAR(1)                      AS status_cte_en_cob_tel,
          DATE                         AS fecha_insercion,
          DATE                         AS fecha_generacion,
          SMALLINT                     AS num_cd_coppel_cte,
          SMALLINT                     AS num_edo_copel_cte,
          SMALLINT                     AS prioridad,          
          INTEGER                      AS keys;

DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6); 

DEFINE cEmpresa           CHAR(3);
DEFINE cNumCte            CHAR(20);
DEFINE cEjecutivo         CHAR(8);
DEFINE cNombre1           CHAR(26);
DEFINE cNombre2           CHAR(26);
DEFINE cNombre            CHAR(53);
DEFINE cApellPat          CHAR(26);
DEFINE cApellMat          CHAR(26);
DEFINE cSexo              CHAR(1);
DEFINE dtFechaNac         DATE;
DEFINE cEdoCivil          CHAR(2);
DEFINE cHabitaEn          CHAR(2);
DEFINE cDomicilioCasa     CHAR(300);
DEFINE cDomicilioTrabajo  CHAR(300);
DEFINE dtFechaAlta        DATE;
DEFINE sTpoCte            SMALLINT;
DEFINE cPuntualidad       CHAR(1);
DEFINE sEficiencia        SMALLINT;
DEFINE sCalif             SMALLINT;
DEFINE cNumProducto       CHAR(4);
DEFINE cNumCred           CHAR(20);
DEFINE mIngresoMens       MONEY(14,2);
DEFINE mParamIngMens      MONEY(14,2);
DEFINE sIngresoMens       SMALLINT;
DEFINE cNumCteRef         CHAR(20);
DEFINE cNombreRef         CHAR(53);
DEFINE cNombreAux         CHAR(104);
DEFINE cNumCteRefCoppel   CHAR(20);
DEFINE cNombre1Ref        CHAR(26);
DEFINE cNombre2Ref        CHAR(26);
DEFINE cApellPatRef       CHAR(26);
DEFINE cApellMatRef       CHAR(26);
DEFINE cSexoRef           CHAR(1);
DEFINE cEdoCivilRef       CHAR(2);
DEFINE iBanBusqueda       INTEGER;
DEFINE sCodResultado      SMALLINT;
DEFINE dtFechaLlamar      DATETIME YEAR TO DAY;
DEFINE dtHoraLlamar       DATETIME HOUR TO FRACTION;
DEFINE dtFechaHoraLlamar  DATETIME YEAR TO FRACTION;
DEFINE sTpoLogica         SMALLINT;
DEFINE cTpoCob            CHAR(1);
DEFINE dtFechaLlamada     DATETIME YEAR TO FRACTION;
DEFINE cStatusCteCobTel   CHAR(1);
DEFINE dtFechaInsert      DATE;
DEFINE dtFechaGeneracion  DATE;
DEFINE sNumCdCoppel       SMALLINT;
DEFINE sNumEdoCoppel      SMALLINT;
DEFINE sPrioridad         SMALLINT;
DEFINE cStatusCte         CHAR(2);
DEFINE iKeys              INTEGER;
DEFINE cFechaHora         CHAR(50);
DEFINE Vcreditoexterno    CHAR(20);
DEFINE vnumproducto       CHAR(4);


DEFINE cSitCte         CHAR(1);
DEFINE sCausaCte       SMALLINT; 
DEFINE cMensaje_ret    CHAR(80);
DEFINE cNumCredito     CHAR(20);
DEFINE cCodTipCred     CHAR(2);
DEFINE dtFecha         DATE;
DEFINE dMonto          DECIMAL(18,2);
DEFINE iPlazo          INTEGER;
DEFINE dTasa           DECIMAL(9,6);
DEFINE dMonto_sbc      DECIMAL(14,2);  
DEFINE cDescEstatus    CHAR(60);
DEFINE cCausaBloqCred  CHAR(3);
DEFINE cCausaBloqCta   CHAR(50);
DEFINE cIdSitEsp       CHAR(1);
DEFINE cSisEspCte      CHAR(75);
DEFINE dtFechaHoraAux  DATETIME YEAR TO FRACTION;

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";

LET cEmpresa           = "";
LET cNumCte            = "";
LET cEjecutivo         = "";
LET cNombre1           = "";
LET cNombre2           = "";
LET cNombre            = "";
LET cApellPat          = "";
LET cApellMat          = "";
LET cSexo              = "";
LET dtFechaNac         = DATE(1);
LET cEdoCivil          = "";
LET cHabitaEn          = "";
LET cDomicilioCasa     = "";
LET cDomicilioTrabajo  = "";
LET dtFechaAlta        = DATE(1);
LET sTpoCte            = 0;
LET cPuntualidad       = "";
LET sEficiencia        = 0;
LET sCalif             = 0;
LET cNumProducto       = "6001";
LET cNumCred           = "";
LET mIngresoMens       = 0;
LET mParamIngMens      = 0;
LET sIngresoMens       = 0;
LET cNumCteRef         = "";
LET cNombreRef         = "";
LET cNombreAux         = "";
LET cNumCteRefCoppel   = "";
LET cNombre1Ref        = "";
LET cNombre2Ref        = "";
LET cApellPatRef       = "";
LET cApellMatRef       = "";
LET cSexoRef           = "";
LET cEdoCivilRef       = "";
LET iBanBusqueda       = 0;
LET sCodResultado      = 0;
LET dtFechaLlamar      = DATE(1);
LET dtHoraLlamar       = DATE(1);
LET dtFechaHoraLlamar  = DATE(1);
LET sTpoLogica         = 0;
LET cTpoCob            = "";
LET dtFechaLlamada     = DATE(1);
LET cStatusCteCobTel   = "0";
LET dtFechaInsert      = DATE(1);
LET dtFechaGeneracion  = DATE(1);
LET sNumCdCoppel       = 0;
LET sNumEdoCoppel      = 0;
LET sPrioridad         = 0;
LET cStatusCte         = "";
LET iKeys              = 0;
LET cFechaHora         = "";


LET cSitCte             = "";
LET sCausaCte           = 0;
LET cMensaje_ret        = "";
LET cNumCredito         = "";
LET cCodTipCred         = "";
LET dtFecha             = DATE(1);
LET dMonto              = 0;
LET iPlazo              = 0;
LET dTasa               = 0;
LET dMonto_sbc          = 0;
LET cDescEstatus        = "";
LET cCausaBloqCred      = "";
LET cCausaBloqCta       = "";
LET cIdSitEsp           = "";
LET cSisEspCte          = "";
LET dtFechaHoraAux      = DATE(1);

BEGIN
 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/Elizabeth/r.out";
 --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- Se validan los parámetros de ejecución
 SELECT empresa
   INTO cEmpresa
   FROM bdinteg:"informix".si_empresas
  WHERE empresa= pEmpresa;

 IF cEmpresa IS NULL THEN
    LET cCodRet = "101001";
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
 END IF;

SELECT {+INDEX(bdisolic:ss_param idx_ss_param)} NVL(valor,0) * 1
  INTO mParamIngMens
  FROM bdisolic:ss_param
 WHERE secuencia = 303 
   AND empresa   = cEmpresa;

IF NVL(mParamIngMens,0) = 0 THEN
    LET cCodRet = "101002";
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
END IF;

SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno, fecha_insert --fecha_alta
  INTO cNumCte, cNombre1, cNombre2, cApellPat, cApellMat, dtFechaAlta
  FROM bdinteg:"informix".si_cliente
 WHERE numcte  = pCliente;
   ---AND empresa = cEmpresa;

 IF cNumCte IS NULL THEN
   LET cCodRet = "101003";
      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 
 END IF;

 LET cNombre = TRIM(TRIM(NVL(cNombre1,""))||" "||TRIM(NVL(cNombre2,"")));

SELECT sexo, fecha_nac, estado_civil, habita_en
  INTO cSexo, dtFechaNac, cEdoCivil, cHabitaEn
  FROM bdinteg:"informix".si_ctepf 
 WHERE numcte = cNumCte;

   SELECT {+INDEX(bdinteg:si_direcciones inx_puntocardinales)} REPLACE(TRIM(NVL(edo.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(ciu.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(zon.nombrezonacoppel," ")),',',';')||","||
          REPLACE(TRIM(NVL(cal.nombrecalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numeroextcalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numerointcalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(zon.rumbozona,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.observaciones,"")),',',';')||","||
          REPLACE(TRIM(NVL(cHabitaEn,"")),',',';'),
          ciu.ciudad_coppel,
          cdc.numeroestado
 INTO cDomicilioCasa, sNumCdCoppel, sNumEdoCoppel
     FROM bdinteg:si_direcciones_actual dir
LEFT JOIN bdinteg:si_estados     edo ON(edo.pais = "001" AND edo.estado = dir.estado)
LEFT JOIN bdinteg:si_ciudades    ciu ON(ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
LEFT JOIN bdinteg:si_catzonas    zon ON(zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
LEFT JOIN bdinteg:si_catcalles   cal ON(cal.numerocalle  = dir.numerocalle)
LEFT JOIN bdinteg:si_catciudades cdc ON(cdc.numerociudad = dir.numerociudad)
    WHERE dir.numcte    = cNumCte
      AND dir.tipo_dir  = '1';
      /*AND dir.secuencia = (SELECT {+INDEX(bdinteg:si_direccion_actual idx_diract_ctepo)} b.secuencia
                             FROM bdinteg:"informix".si_direcciones_actual b
                            WHERE b.numcte   = dir.numcte
                              AND b.tipo_dir = dir.tipo_dir);*/

   SELECT {+INDEX(bdinteg:si_direcciones inx_puntocardinales)} ""||","||
          REPLACE(TRIM(NVL(edo.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(ciu.nombre,"")),',',';')||","||
          REPLACE(TRIM(NVL(zon.nombrezonacoppel,"")),',',';')||","||
          REPLACE(TRIM(NVL(cal.nombrecalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numeroextcalle,"")),',',';')||","||
          REPLACE(TRIM(NVL(dir.numerointcalle,"")),',',';')
     INTO cDomicilioTrabajo
     FROM bdinteg:si_direcciones_actual dir
LEFT JOIN bdinteg:si_estados   edo ON(edo.estado = dir.estado AND edo.pais = "001")
LEFT JOIN bdinteg:si_ciudades  ciu ON(ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
LEFT JOIN bdinteg:si_catzonas  zon ON(zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
LEFT JOIN bdinteg:si_catcalles cal ON(cal.numerocalle = dir.numerocalle)
    WHERE dir.numcte    = cNumCte
      AND dir.tipo_dir  = '2';
      /*AND dir.secuencia = (SELECT {+INDEX(bdinteg:si_direccion_actual idx_diract_ctepo)} b.secuencia
                             FROM bdinteg:"informix".si_direcciones_actual b
                            WHERE b.numcte   = dir.numcte
                              AND b.tipo_dir = dir.tipo_dir);*/

SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio)} a.num_credito, a.puntualidad, a.eficiencia, a.calificacion,
       a.tipo_logica, fecha_insert,
       prioridad, status_cliente, keys 
  INTO cNumCred, cPuntualidad, sEficiencia, sCalif,
       sTpoLogica, dtFechaInsert,
       sPrioridad, cStatusCte, iKeys
  FROM "informix".cb_cat_directorio_cte a
 WHERE a.numcte        = cNumCte
   AND a.tipo_cobranza = pTpoCobranza
   AND a.fecha_insert  = (SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio)} MAX(fecha_insert)
                            FROM "informix".cb_cat_directorio_cte b
                           WHERE b.numcte        = a.numcte
                             AND b.tipo_cobranza = a.tipo_cobranza
                             AND b.fecha_insert  = b.fecha_insert
                             AND b.empresa       = a.empresa)
   AND a.empresa       = cEmpresa;

LET cTpoCob = pTpoCobranza;
LET dtFechaGeneracion = dtFechaInsert;

SELECT ingreso_mensual 
  INTO mIngresoMens
  FROM bdisolic:ss_resum_scor_fin
 WHERE empresa       = cEmpresa
   AND num_solicitud = cNumCred;

   LET sIngresoMens = NVL(mIngresoMens,0) / mParamIngMens;
   
   --seleciona el tipo de producto
   
	select num_producto into vnumproducto
	from bdicred:sd_maecredcrd
	where empresa = cEmpresa and num_credito = cNumCred;

	--si producto es  60011
	if (vnumproducto = 6011) then
	SELECT credito_externo into vcreditoexterno 
	from bdicred:sd_maecredcrd
	where num_credito = cNumCred;
	let cNumCred = Vcreditoexterno;
	end if;
	
IF EXISTS (SELECT {+INDEX(cb_telefonos idx_cons_telefono)} numcte 
             FROM "informix".cb_telefonos
            WHERE numcte         = cNumCte
              AND telefono       = telefono
              AND empresa        = cEmpresa
              AND tipo_telefono  = 4) THEN

    SELECT LIMIT 1 nombre_ref
      INTO cNombreAux
      FROM bdisolic:ss_refpersonales
     WHERE empresa       = cEmpresa
       AND num_solicitud = cNumCred  
       AND numcte        = cNumCte
       AND numcte_ref    = 'R1';

      LET cNombreRef   = SUBSTR(cNombreAux,1,20);
      LET cApellPatRef = SUBSTR(cNombreAux,21,40);
      LET cApellMatRef = SUBSTR(cNombreAux,41,60);
      LET cSexoRef     = "D";
      LET cEdoCivilRef = "D";
END IF;

-- Se obtiene la situación y causa del cliente
SELECT {+INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx5)} a.situacion, a.causa
  INTO cSitCte, sCausaCte
  FROM bdisitesp:"informix".se_ctessitespcte a
 WHERE a.idmovto=(SELECT {+INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx5)} MAX(aux.idmovto)
                   FROM bdisitesp:"informix".se_ctessitespcte aux
		  WHERE aux.idmovto = aux.idmovto
		    AND a.empresa   = aux.empresa
		    AND a.numcte    = aux.numcte)
  AND a.empresa   = cEmpresa
  AND a.numcte    = cNumCte;

/*
SELECT {+INDEX(cb_cat_resultado_llamada idx_cb_cat_resultado_llamada), +INDEX(cb_cat_tipo_resultado idx_cat_tipo_resultado)} DECODE(r.genera_llamada,"S",1,0),a.fecha_llamar_despues, a.hora_llamar_despues, a.ejecutivo,
       DECODE(r.tipo_llamada,"C",a.fh_movimiento,dtFechaHoraAux)
  INTO sCodResultado, dtFechaLlamar, dtHoraLlamar, cEjecutivo,
       dtFechaLlamada
  FROM bdicobranza:"informix".cb_cat_resultado_llamada a,
       bdicobranza:"informix".cb_cat_tipo_resultado r
 WHERE a.empresa          = cEmpresa
   AND a.tipo_campania    = pTpoCobranza
   AND a.numcte           = cNumCte
   AND a.id_llamada  = (SELECT  {+INDEX(cb_cat_resultado_llamada idx_cb_cat_resultado_llamada)} MAX(id_llamada)
                             FROM bdicobranza:"informix".cb_cat_resultado_llamada b
                            WHERE b.empresa          = a.empresa
                              AND b.tipo_campania    = a.tipo_campania
                              AND b.numcte           = a.numcte
                              ) ---fmj Nov 16 AND b.codigo_resultado = a.codigo_resultado 
   AND r.codigo_resultado = a.codigo_resultado;
*/

    LET sCodResultado = 1;
    IF NVL(sCodResultado,0) = 1 THEN
        LET dtFechaHoraLlamar = NVL(dtFechaLlamar,DATE(1))||" "||NVL(dtHoraLlamar,DATE(1)); 
    END IF;
       


      RETURN cCodRet, NVL(cNumCte,""),NVL(cNombre,""), NVL(cApellPat,""), NVL(cApellMat,""), NVL(cSexo,""), NVL(dtFechaNac,DATE(1)),
             NVL(cEdoCivil,""), NVL(cDomicilioCasa,""), NVL(cDomicilioTrabajo,""), NVL(cSitCte,""),NVL(sCausaCte,0),NVL(cPuntualidad,""), NVL(sEficiencia,0),
             NVL(sCalif,0), NVL(sIngresoMens,0), NVL(cNombreRef,""), NVL(cApellPatRef,""), NVL(cApellMatRef,""),
             NVL(cSexoRef,""), NVL(cEdoCivilRef,""), NVL(dtFechaAlta,DATE(1)), NVL(sCodResultado,0), NVL(dtFechaHoraLlamar,DATE(1)),
             NVL(sTpoCte,0), NVL(sTpoLogica,0), NVL(cTpoCob,""), NVL(cEjecutivo,""), NVL(dtFechaLlamada,DATE(1)), NVL(cStatusCteCobTel,""),
             NVL(dtFechaInsert,DATE(1)), NVL(dtFechaGeneracion,DATE(1)), NVL(sNumCdCoppel,0), NVL(sNumEdoCoppel,0), NVL(sPrioridad,0), NVL(iKeys,"0"); 

END
END PROCEDURE
DOCUMENT
'Función para consultar los datos generales del cte',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 29/SEPT/2010',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_carga_resultado_cat( pNomArch CHAR(30))
RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE cMensaje                     CHAR(80);

DEFINE cCadena                      CHAR(500);
DEFINE vPath                        CHAR(50);

------------------------------------------------------------
-- Creado: Maria Elizabeth anzures
-- Fecha: 01 agosto 2011
-- Crear en BDICOBRANZA

LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';
LET cCadena   = '';
LET vPath     = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
          LET cMensaje = error_info;
			    RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

  --SET DEBUG FILE TO "/home/informix/Elizabeth/importa.out";
  --TRACE ON;
	
            select valor_alfabetico into vPath 
            from bdicobranza:cb_param_campania
            where empresa = '001'
            and tipo_campania = 1
            and grupo_parametro = 'ARCHIVOS'
            and num_parametro = 29;

          LET cCadena = 'echo "load from ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(pNomArch,1,
		  LENGTH(pNomArch))  || ' insert into bdicobranza:cb_registro_llamadas" >' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_llamadas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
		  
		
  


RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;
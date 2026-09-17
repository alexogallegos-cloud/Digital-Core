CREATE PROCEDURE "informix".sp_obtinfototregion(pFechaApli CHAR(7))
   RETURNING CHAR(6),INTEGER, CHAR(30), INTEGER, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER,CHAR(60),CHAR(60),CHAR(60),
   CHAR(60),CHAR(60),CHAR(60);

-- ***************************************************************************
-- DEFINE variables
-- ***************************************************************************
   DEFINE cCodRet              CHAR(6);
   DEFINE iSql_err              INTEGER;
   DEFINE cCod_ret2             CHAR(6);
   DEFINE iTotReg               INTEGER;
   DEFINE cDescReg              CHAR(30);
   DEFINE iPerAlta              INTEGER;
   DEFINE iPerOperando          INTEGER;
   DEFINE iPerOperCert          INTEGER;
   DEFINE iPerOperNoCert        INTEGER;
   DEFINE iPerTotOperNoCert3060 INTEGER;
   DEFINE iPerTotOperNoCert60   INTEGER;
   DEFINE dDia_primero          DATE;
   DEFINE dDia_fin              DATE;
   DEFINE cRutaPC    	        CHAR(60);
   DEFINE cRutaServer  	     	CHAR(60);
   DEFINE cUser	             	CHAR(60);
   DEFINE cPass	                CHAR(60);
   DEFINE cIP		            CHAR(60);
   DEFINE cSql		            CHAR(600);
   DEFINE cNom		            CHAR(60);
   DEFINE cMes		            CHAR(2);
   DEFINE cAnio		            CHAR(4);
   DEFINE cStatus	            CHAR(20);
   DEFINE iAprobados		    INTEGER;
   DEFINE iNoPresentados	    INTEGER;   
   DEFINE iReprobados		    INTEGER;
   DEFINE iRegion			    INTEGER;
   DEFINE iSuma				    INTEGER;
   
  
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cCodRet              ="000000";
   LET iSql_err              =0;
   LET cCod_ret2             ="000000";
   LET iTotReg               =0;
   LET cDescReg              ="";
   LET iPerAlta              =0;
   LET iPerOperando          =0;
   LET iPerOperCert          =0;
   LET iPerOperNoCert        =0;
   LET iPerTotOperNoCert3060 =0;
   LET iPerTotOperNoCert60   =0;
   LET dDia_primero          ="";
   LET dDia_fin              ="";
   LET cRutaPC    	         ="";
   LET cRutaServer  	     ="";
   LET cUser	             ="";
   LET cPass	             ="";
   LET cIP		             ="";
   LET cSql		             ="";
   LET cNom		             ="";
   LET cMes		             ="";
   LET cAnio	             ="";
   LET cStatus	             ="";
   LET iAprobados	         =0;
   LET iReprobados           =0;
   LET iNoPresentados        =0;
   LET iRegion			     =0;
   LET iSuma			     =0;
   
   
--SET DEBUG FILE TO "/respaldosbd/sp_obtinfototregion.out";
--TRACE ON;

BEGIN
   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
			--Valida si existe la tabla temporal.
			IF EXISTS (SELECT dbsname, tabname FROM sysmaster:"informix".systabnames  WHERE tabname = 'raw_obtinfototregion') THEN
				DROP TABLE bdicheq:"informix".raw_obtinfototregion;
			END IF;
			IF EXISTS (SELECT dbsname, tabname FROM sysmaster:"informix".systabnames  WHERE tabname = 'raw_resultadoregion') THEN
				DROP TABLE bdicheq:"informix".raw_resultadoregion;
			END IF;
            LET cCodRet = iSql_err;
            RETURN cCodRet,iTotReg,cDescReg,iPerAlta,iPerOperando,iPerOperCert,iPerOperNoCert,iPerTotOperNoCert3060,iPerTotOperNoCert60,		cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
      END IF
   END EXCEPTION;
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	
	IF pFechaApli IS NULL OR pFechaApli = '' THEN
		LET cCodRet = '000001';  --Faltan parametros para su ejecucion.
		RETURN cCodRet,iTotReg,cDescReg,iPerAlta,iPerOperando,iPerOperCert,iPerOperNoCert,iPerTotOperNoCert3060,iPerTotOperNoCert60,		cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
	END IF;

	LET cMes = SUBSTR(pFechaApli, 1, 2);
	LET cAnio = SUBSTR(pFechaApli, 4, 7);
    EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes, cAnio)
    INTO cCod_ret2, dDia_primero, dDia_fin;
        
    IF cCod_Ret2 <> '000000' THEN
            LET cCodRet = '000002'; --Error al ejecutar procedimiento
            RETURN cCodRet,iTotReg,cDescReg,iPerAlta,iPerOperando,iPerOperCert,iPerOperNoCert,iPerTotOperNoCert3060,iPerTotOperNoCert60,		cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
    END IF;
	
	--Valida si existe la tabla temporal.
	IF EXISTS (SELECT dbsname, tabname FROM sysmaster:"informix".systabnames  WHERE tabname = 'raw_obtinfototregion') THEN
		DROP TABLE bdicheq:"informix".raw_obtinfototregion;
	END IF;
	IF EXISTS (SELECT dbsname, tabname FROM sysmaster:"informix".systabnames  WHERE tabname = 'raw_resultadoregion') THEN
		DROP TABLE bdicheq:"informix".raw_resultadoregion;
	END IF;
	
	--Crea la tabla temporal
	CREATE RAW TABLE bdicheq:"informix".raw_obtinfototregion(
	totreg 					INTEGER,	
	descreg 				CHAR(30), 
	peralta 				INTEGER,
	peroperando 			INTEGER,
	peropercert 			INTEGER,
	peropernocert 			INTEGER,
	pertotopernocert3060 	INTEGER,
	pertotopernocert60 		INTEGER);
	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:"informix".raw_obtinfototregion;
	
	CREATE RAW TABLE bdicheq:"informix".raw_resultadoregion
	(usuario					CHAR(10),
	status						CHAR(20));
	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:"informix".raw_resultadoregion;
	
	--Consulta parametros de conexion server pc
	SELECT valor INTO cRutaPC FROM bdicheq:"informix".sc_param WHERE codparam = 'rutarepexcel';
	SELECT valor INTO cRutaServer FROM bdicheq:"informix".sc_param WHERE codparam = 'NomRutaDestino';
	SELECT valor INTO cUser FROM bdicheq:"informix".sc_param WHERE codparam = 'NomUserEncrip';
	SELECT valor INTO cPass FROM bdicheq:"informix".sc_param WHERE codparam = 'NomPassEncrip';
	SELECT valor INTO cIP FROM bdicheq:"informix".sc_param WHERE codparam = 'NomIpServer';
	LET cNom= "inf_corresp_"||cMes||cAnio||"_3.txt";
    
    FOREACH --consulta de total de corresponsales y nombre de region 
    SELECT COUNT(region),region,nombreregion
    INTO iTotReg,iRegion,cDescReg
    FROM bdicheq:"informix".sc_corresponsal 
    GROUP BY region,nombreregion
		
    --personal dado de alta en el mes
    SELECT COUNT(emp) 
    INTO iPerAlta
    FROM bdicheq:"informix".sc_corresponsal
    WHERE fechaalta BETWEEN dDia_primero AND dDia_fin
    AND region= iRegion;

	--personal certificado operando en el mes y personal no certificado operando en el mes
	INSERT INTO bdicheq:"informix".raw_resultadoregion (usuario,status)
	SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew3} a.usuario,b.estatus 
		FROM bdicheq:"informix".sc_movhis AS a
		INNER JOIN bdicheq:"informix".sc_corresponsal AS b ON (a.usuario = b.emp)
		WHERE a.transacc= '0282'
		AND a.empresa= '001'
		AND a.cuenta= a.cuenta
		AND a.fech_alt BETWEEN dDia_primero AND dDia_fin
		AND a.usuario = b.emp
		AND b.region = iRegion
		GROUP BY a.transacc,a.usuario,b.estatus;
	
	INSERT INTO bdicheq:"informix".raw_resultadoregion (usuario,status)
	SELECT {+INDEX(bdicred:"informix".sd_movhis inx_movhis5)} a.usuario,b.estatus
		FROM bdicred:"informix".sd_movhis AS a 
		INNER JOIN bdicheq:"informix".sc_corresponsal AS b ON (a.usuario = b.emp)
		WHERE  a.codigo_fun = '700'
		AND  a.codigo_ref = 1
		AND fecha_mov BETWEEN dDia_primero AND dDia_fin
		AND a.usuario = b.emp
		AND a.transacc_suc= '6282'
		AND b.region = iRegion
		GROUP BY a.codigo_fun,a.codigo_ref,a.usuario,b.estatus;
	
	FOREACH
		SELECT COUNT(DISTINCT usuario),status 
		INTO iSuma,cStatus
		FROM bdicheq:"informix".raw_resultadoregion 
		GROUP BY status
	
		IF UPPER(cStatus) = 'APROBADO' THEN
			LET iAprobados = iSuma;
		ELIF UPPER(cStatus) = 'REPROBADO' THEN
			LET iReprobados = iSuma;
		--dsb 05/10/2011
		--ELSE
		--	LET iNoPresentados =  iSuma;
		ELIF UPPER(cStatus) = 'NO HA PRESENTADO' THEN
			LET iNoPresentados = iNoPresentados + iSuma;
		END IF;
	END FOREACH;	
	
	LET iPerOperando = iAprobados + iReprobados + iNoPresentados;
	LET iPerOperCert = iAprobados;
	LET iPerOperNoCert = iReprobados + iNoPresentados;
	LET iAprobados	          =0;
	LET iReprobados           =0;
	LET iNoPresentados        =0;
	DELETE FROM bdicheq:'informix'.raw_resultadoregion;
	
	
	--personal no cerificado mas de 60 dias anteriores al ultimo dia del mes
	INSERT INTO bdicheq:"informix".raw_resultadoregion (usuario,status)
	SELECT {+INDEX(sc_movhis idx_movhisnew3} a.usuario,b.estatus 
		FROM bdicheq:"informix".sc_movhis AS a
		INNER JOIN bdicheq:"informix".sc_corresponsal AS b ON (a.usuario = b.emp)
		WHERE a.transacc= '0282'
		AND a.empresa= '001'
		AND a.cuenta= a.cuenta
		AND a.fech_alt < dDia_fin - 60
		AND a.usuario = b.emp
		AND b.region = iRegion
		AND UPPER(b.estatus) <> 'APROBADO'
		GROUP BY a.transacc,a.usuario,b.estatus;
	
	INSERT INTO bdicheq:"informix".raw_resultadoregion (usuario,status)
	SELECT {+INDEX(sd_movhis inx_movhis5)} a.usuario,b.estatus
		FROM bdicred:"informix".sd_movhis AS a 
		INNER JOIN bdicheq:"informix".sc_corresponsal AS b ON (a.usuario = b.emp)
		WHERE  a.codigo_fun = '700'
		AND  a.codigo_ref = 1
		AND fecha_mov < dDia_fin - 60
		AND a.usuario = b.emp
		AND a.transacc_suc= '6282'
		AND b.region = iRegion
		AND UPPER(b.estatus) <> 'APROBADO'
		GROUP BY a.codigo_fun,a.codigo_ref,a.usuario,b.estatus;
	
	FOREACH
		SELECT COUNT(DISTINCT usuario),status 
		INTO iSuma,cStatus
		FROM bdicheq:"informix".raw_resultadoregion 
		GROUP BY status
	
		IF UPPER(cStatus) = 'APROBADO' THEN
			LET iAprobados = iSuma;
		ELIF UPPER(cStatus) = 'REPROBADO' THEN
			LET iReprobados = iSuma;
		--dsb 05/10/2011
		--ELSE
		--	LET iNoPresentados =  iSuma;
		ELIF UPPER(cStatus) = 'NO HA PRESENTADO' THEN
			LET iNoPresentados = iNoPresentados + iSuma;
		END IF;
	END FOREACH;
	
	LET iPerTotOperNoCert60 = iAprobados + iReprobados + iNoPresentados;
	LET iAprobados	          =0;
	LET iReprobados           =0;
	LET iNoPresentados        =0;
	DELETE FROM bdicheq:'informix'.raw_resultadoregion;
		
	
	--personal no cerificado que inicio sus operaciones entre 30 y 60 dias anteriores al ultimo dia del mes
	INSERT INTO bdicheq:"informix".raw_resultadoregion (usuario,status)
	SELECT {+INDEX(sc_movhis idx_movhisnew3} a.usuario,b.estatus 
		FROM bdicheq:"informix".sc_movhis AS a
		INNER JOIN bdicheq:"informix".sc_corresponsal AS b ON (a.usuario = b.emp)
		WHERE a.transacc= '0282'
		AND a.empresa= '001'
		AND a.cuenta= a.cuenta
		--AND a.fech_alt BETWEEN dDia_fin - 60 AND dDia_fin - 30
		AND a.usuario = b.emp
		AND b.region = iRegion
		AND UPPER(b.estatus) <> 'APROBADO'
		GROUP BY a.transacc,a.usuario,b.estatus
        HAVING MIN(a.fech_alt) <= dDia_fin - 30;
	
	INSERT INTO bdicheq:"informix".raw_resultadoregion (usuario,status)
	SELECT {+INDEX(sd_movhis inx_movhis5)} a.usuario,b.estatus
		FROM bdicred:"informix".sd_movhis AS a 
		INNER JOIN bdicheq:"informix".sc_corresponsal AS b ON (a.usuario = b.emp)
		WHERE  a.codigo_fun = '700'
		AND  a.codigo_ref = 1
		--AND fecha_mov BETWEEN dDia_fin - 60 AND dDia_fin - 30
		AND a.usuario = b.emp
		AND a.transacc_suc= '6282'
		AND b.region = iRegion
		AND UPPER(b.estatus) <> 'APROBADO'
		GROUP BY a.codigo_fun,a.codigo_ref,a.usuario,b.estatus
        HAVING MIN(fecha_mov) <= dDia_fin - 30;
	
	FOREACH
		SELECT COUNT(DISTINCT usuario),status 
		INTO iSuma,cStatus
		FROM bdicheq:"informix".raw_resultadoregion 
		GROUP BY status
	
		IF UPPER(cStatus) = 'APROBADO' THEN
			LET iAprobados = iSuma;
		ELIF UPPER(cStatus) = 'REPROBADO' THEN
			LET iReprobados = iSuma;
		--dsb 05/10/2011
		--ELSE
		--	LET iNoPresentados =  iSuma;
		ELIF UPPER(cStatus) = 'NO HA PRESENTADO' THEN
			LET iNoPresentados = iNoPresentados + iSuma;
		END IF;
	END FOREACH;	
	
	LET iPerTotOperNoCert3060 = iAprobados + iReprobados + iNoPresentados - iPerTotOperNoCert60;
	LET iAprobados	          =0;
	LET iReprobados           =0;
	LET iNoPresentados        =0;
	DELETE FROM bdicheq:'informix'.raw_resultadoregion;
	
		--Almacena la informacion para generar el archivo.
		INSERT INTO bdicheq:"informix".raw_obtinfototregion
			(totreg,descreg,peralta,peroperando,peropercert,peropernocert,pertotopernocert3060,pertotopernocert60)
		VALUES
			(iTotReg,cDescReg,iPerAlta,iPerOperando,iPerOperCert,iPerOperNoCert,iPerTotOperNoCert3060,iPerTotOperNoCert60);
					
    END FOREACH 
	
	IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
		LET cSql = '';
		LET  cSql = 'echo "UNLOAD TO ' || ( TRIM(cRutaServer) || "queryarchivo.unl") ||
					" SELECT 'totreg','descreg','peralta','peroperando','peropercert','peropernocert', "||  
					" 'pertotopernocert3060','pertotopernocert60' FROM bdicheq:'informix'.sc_fechas WHERE empresa = '001'" ||
					' UNION ALL '||
					' SELECT totreg::CHAR(10),descreg::CHAR(30),peralta::CHAR(10),peroperando::CHAR(10),peropercert::CHAR(10), ' ||
					' peropernocert::CHAR(10),pertotopernocert3060::CHAR(10),pertotopernocert60::CHAR(10) FROM ' ||
					' bdicheq:"informix".raw_obtinfototregion;" > ' || TRIM(cRutaServer) || 'query.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "dbaccess bdicheq " || TRIM(cRutaServer) ||"query.sql ";
		SYSTEM cSql;
		
		-- Le quita el ultimo | al archivo 
		LET cSql = "sed 's/|$//g' " || ( TRIM(cRutaServer) || "queryarchivo.unl") || " > "	|| ( TRIM(cRutaServer) || TRIM(cNom));
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = "rm -rf " || TRIM(cRutaServer) ||"query*";
		SYSTEM cSql;
	ELSE
		LET cCodRet = '000003';
		DROP TABLE bdicheq:"informix".raw_obtinfototregion;
		DROP TABLE bdicheq:"informix".raw_resultadoregion;
		RETURN cCodRet,iTotReg,cDescReg,iPerAlta,iPerOperando,iPerOperCert,iPerOperNoCert,iPerTotOperNoCert3060,iPerTotOperNoCert60,TRIM(cRutaPC) ,TRIM(cRutaServer),TRIM(cUser),TRIM(cPass),TRIM(cIP),TRIM(cNom);
	END IF;	
	
		DROP TABLE bdicheq:"informix".raw_obtinfototregion;
		DROP TABLE bdicheq:"informix".raw_resultadoregion;
		
	RETURN cCodRet,iTotReg,cDescReg,iPerAlta,iPerOperando,iPerOperCert,iPerOperNoCert,iPerTotOperNoCert3060,iPerTotOperNoCert60,TRIM(cRutaPC) ,TRIM(cRutaServer),TRIM(cUser),TRIM(cPass),TRIM(cIP),TRIM(cNom);
END
END PROCEDURE
DOCUMENT
'AUTOR: Roberto Aguilar',
'FECHA: 22 de Julio del 2011',
'DESCRIPCION: Se genera el reporte en archivo de totales por region.',
'VERSION: 20110722.1548',
'BD: BDICHEQ',
'MODIFICO: Roberto Aguilar Pozos',
'FECHA: 18 de Agosto del 2011',
'MODIFICACION: Se corrigue codigo de referencia',
'VERSION: 20110818.0350',
'MODIFICO: Roberto Aguilar Pozos',
'FECHA: 31 de Agosto del 2011',
'MODIFICACION: Se corrige la omision del campo peralta y el error en el calculo del campo pertotopernocert3060',
'VERSION: 20110831.1755',
'MODIFICO: Victor Hugo Nuñez',
'FECHA: 05 de Octubre del 2011',
'MODIFICACION: correccion para que se tome el estatus No ha Presentado indistintamente de mayusculas y minusculas ',
'VERSION: 20111005.1208';

CREATE PROCEDURE "informix".sp_obtinfosinaprovevalu60(pFechaApli CHAR(7))
   RETURNING CHAR(6),CHAR(10), CHAR(92), INTEGER , CHAR(30), CHAR(10), CHAR(10), CHAR(10),CHAR(20), SMALLINT,CHAR(60),CHAR(60),CHAR(60),
   CHAR(60),CHAR(60),CHAR(60);

-- ***************************************************************************
-- DEFINE variables
-- ***************************************************************************
   DEFINE cCodRet              	CHAR(6);
   DEFINE iSql_err              INTEGER;
   DEFINE cSql_err2             CHAR(6);
   DEFINE cEmp                  CHAR(10);
   DEFINE cNombre               CHAR(92);
   DEFINE iNumPuesto            INTEGER;
   DEFINE cNombrePuesto         CHAR(30);
   DEFINE cCentro               CHAR(10);
   DEFINE cPerfil_corresponsal  CHAR(10);
   DEFINE cOperacion            CHAR(10);
   DEFINE cEstatus              CHAR(20);
   --dsb 27/10/2011
   --DEFINE cCancelado            CHAR(1);
   DEFINE cReversado            CHAR(1);
   DEFINE dDia_primero          DATE;
   DEFINE dDia_fin              DATE;
   DEFINE dDia_limite           DATE;
   DEFINE dFecha_bdicheq        DATE;
   DEFINE dFecha_bdicred        DATE;
   DEFINE dFecha_menor          DATE;
   DEFINE siDiasnocertificado   SMALLINT;
   DEFINE cMes                  CHAR(2);
   DEFINE cAnio                 CHAR(4);
   DEFINE cRutaPC    	        CHAR(60);
   DEFINE cRutaServer  	     	CHAR(60);
   DEFINE cUser	             	CHAR(60);
   DEFINE cPass	                CHAR(60);
   DEFINE cIP		            CHAR(60);
   DEFINE cSql		            CHAR(600);
   DEFINE cNom		            CHAR(60);
   DEFINE iSecuencia            INTEGER;
   DEFINE iSerial               INTEGER;
   DEFINE cCodigoFun			CHAR(3);
   DEFINE iCodRef				INTEGER;
   DEFINE iInfo                 SMALLINT;

   
   
  
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cCodRet             = "000000";
   LET iSql_err             = 0;
   LET cSql_err2            = "000000";
   LET cEmp                 = "00000000";
   LET cNombre              = "";
   LET iNumPuesto           = 0;
   LET cNombrePuesto        = "";
   LET cCentro              = "";
   LET cPerfil_corresponsal = "";
   LET cOperacion           = "";
   LET cEstatus             = "";
   --dsb 27/10/2011
   --LET cCancelado           = "";
   LET cReversado           = "";
   LET dDia_primero         = "";
   LET dDia_fin             = "";
   LET dDia_limite          = "";
   LET dFecha_bdicheq       = "";
   LET dFecha_bdicred       = "";
   LET dFecha_menor         = "";
   LET siDiasnocertificado  = 0;
   LET cSQL                 ="";
   LET cRutaPC    	        ="";
   LET cRutaServer  	    ="";
   LET cUser	            ="";
   LET cPass	            ="";
   LET cIP		            ="";
   LET cNom		            ="";
   LET cMes		            ="";
   LET cAnio	            ="";
   LET iSecuencia           =0;
   LET iSerial              =0;
   LET iCodRef				= 0;
   LET cCodigoFun           ='';
   LET iInfo                =0;

   --SET DEBUG FILE TO "/tmp/Josue/sp_obtinfosinaprovevalu60.out";
   --TRACE ON;
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;
BEGIN
   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
            
			IF EXISTS (SELECT dbsname, tabname FROM sysmaster:"informix".systabnames  WHERE tabname = 'raw_obtinfosinaprovevalu60') THEN
				DROP TABLE bdicheq:"informix".raw_obtinfosinaprovevalu60;
			END IF;
			
			LET cCodRet = iSql_err;
            RETURN cCodRet,cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal, cOperacion, cEstatus,siDiasnocertificado,cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
      END IF
   END EXCEPTION;
   
    SELECT codigo_fun, codigo_ref 
        INTO cCodigoFun,iCodRef
        FROM bdicred:"informix".sd_transfun 
        WHERE transacc = '6282';
        IF pFechaApli IS NULL OR pFechaApli = '' THEN
            LET cCodRet = '000001';  --Faltan parametros para su ejecucion.
		RETURN cCodRet,cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal, cOperacion, cEstatus,siDiasnocertificado,cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
     END IF;
   
    LET cMes = SUBSTR(pFechaApli, 1, 2);
	LET cAnio = SUBSTR(pFechaApli, 4, 7);
    EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio(cMes, cAnio)
    INTO cSql_err2, dDia_primero, dDia_fin;
    LET dDia_limite = dDia_fin - 60;
    
    IF cSql_err2 <> '000000' THEN
            LET cCodRet = '000002'; --Error al ejecutar procedimiento
            RETURN cCodRet,cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal, cOperacion, cEstatus,siDiasnocertificado,cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
    END IF
	
	--Valida si existe la tabla temporal.
	IF EXISTS (SELECT dbsname, tabname FROM sysmaster:"informix".systabnames  WHERE tabname = 'raw_obtinfosinaprovevalu60') THEN
		DROP TABLE bdicheq:"informix".raw_obtinfosinaprovevalu60;
	END IF;
	
	--Crea tabla temporal
	CREATE RAW TABLE bdicheq:"informix".raw_obtinfosinaprovevalu60(
	Emp					CHAR(10), 
	Nombre					CHAR(92),
	NumPuesto				INTEGER, 
	NombrePuesto			CHAR(30), 
	Centro					CHAR(10), 
	Perfil_corresponsal	CHAR(10), 
	Operacion				CHAR(10), 
	Estatus				CHAR(20), 
	Diasnocertificado 	SMALLINT);
	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:"informix".raw_obtinfosinaprovevalu60;
		
	--obtiene parametros para conexion server pc
	SELECT valor INTO cRutaPC FROM bdicheq:"informix".sc_param WHERE empresa= '001' AND codparam = 'rutarepexcel';
	SELECT valor INTO cRutaServer FROM bdicheq:"informix".sc_param WHERE empresa= '001' AND codparam = 'NomRutaDestino';
	SELECT valor INTO cUser FROM bdicheq:"informix".sc_param WHERE empresa= '001' AND codparam = 'NomUserEncrip';
	SELECT valor INTO cPass FROM bdicheq:"informix".sc_param WHERE empresa= '001' AND codparam = 'NomPassEncrip';
	SELECT valor INTO cIP FROM bdicheq:"informix".sc_param WHERE empresa= '001' AND codparam = 'NomIpServer';
	LET cNom= "inf_corresp_"||cMes||cAnio||"_5.txt";
	
    FOREACH 
		--Consulta los corresponsales
        SELECT emp,trim(nombre) || " " || trim(appaterno) || " " || trim(apmaterno), nopuesto, puesto, 
		centro, perfilcorresponsal, estatus
        INTO cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal, cEstatus
		--dsb 05/10/2011
		--FROM bdicheq:"informix".sc_corresponsal WHERE estatus IN ("Reprobado", "No ha presentado") AND fechaalta < dDia_limite
        FROM bdicheq:"informix".sc_corresponsal WHERE UPPER(estatus) IN ("REPROBADO", "NO HA PRESENTADO") 
		AND fechaalta < dDia_limite
            LET dFecha_menor='';
            LET dFecha_bdiCheq='';
            LET dFecha_bdicred='';
			--Consulta si el corresponsal tiene movimiento de cheques
            FOREACH
            SELECT {+INDEX(bdicheq:"informix".sc_movhis idx_movhisnew3)} LIMIT 1 cancelad,num_serial,fech_alt
			--dsb 27/10/2011
			--INTO cCancelado, iSerial, dFecha_bdiCheq
			INTO cOperacion, iSerial, dFecha_bdiCheq
			FROM bdicheq:"informix".sc_movhis 
			WHERE transacc= '0282'
            AND fech_alt  < dDia_limite
			AND usuario = cEmp
			ORDER BY 2
            END FOREACH
            IF dFecha_bdiCheq IS NOT NULL THEN
                LET dFecha_menor= dFecha_bdiCheq;
            ELSE
                LET dFecha_menor= dDia_limite;
            END IF
			--07/11/2011
			--Convierte el campo vacio en N para que sea considerado como movimiento de captura 
			IF cOperacion = '' THEN
				LET cOperacion = 'N';
			END IF
			--Consulta si el corresponsal tiene movimiento de credito
            FOREACH
			SELECT {+INDEX(bdicred:"informix".sd_movhis inx_movhis5)} LIMIT 1 reversado,secuencia,fecha_mov
			INTO cReversado, iSecuencia,  dFecha_bdicred
			FROM bdicred:"informix".sd_movhis 
			WHERE  codigo_fun = cCodigoFun
			AND  codigo_ref = iCodRef
			AND fecha_mov <  dFecha_menor
			AND usuario = cEmp
			ORDER BY 2
            END FOREACH

            IF dFecha_bdicred  IS NOT NULL THEN --hay fecha de bdicred
                IF dFecha_bdicred  < dFecha_Menor THEN --el de capt es menor
                    LET dFecha_Menor = dFecha_bdicred;
					--dsb 27/10/2011
					--LET cCancelado = cReversado;
                    LET cOperacion = cReversado;
                END IF;
            ELSE --No hay movtos credito
                IF dFecha_Menor= dDia_limite THEN  --Si no hubo movtos de cheques
                    CONTINUE ForEach;
                END IF
            END IF;
            LET iInfo=1;
            LET siDiasnocertificado = dDia_fin - dFecha_menor;
			--Almacena la informacion para generar el archivo
            INSERT INTO bdicheq:"informix".raw_obtinfosinaprovevalu60 
                (Emp,Nombre,NumPuesto,NombrePuesto,Centro,Perfil_corresponsal,Operacion,Estatus,Diasnocertificado) 
            VALUES
				--dsb 27/10/2011
				--(cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal, cOperacion, cEstatus, siDiasnocertificado);
                (cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal,
				CASE cOperacion WHEN 'S' THEN 'Reverso' WHEN 'N' THEN 'Captura' ELSE 'Ninguna' END, 
				cEstatus, siDiasnocertificado);
    END FOREACH 

	--IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
    IF iInfo = 1 THEN
		LET cSql = '';
		LET  cSql = 'echo "UNLOAD TO ' || ( TRIM(cRutaServer) || "queryarchivo.unl") ||
					" SELECT 'empleado','nombre','numpuesto','puesto','centro','perfilcorresponsal', "||  
					" 'operacion','estatus','diasnocertificado' FROM bdicheq:'informix'.sc_fechas WHERE empresa = '001'" ||
					' UNION ALL '||
					' SELECT emp::CHAR(10),nombre::CHAR(92),numpuesto::CHAR(10),NombrePuesto::CHAR(30),Centro::CHAR(10), ' ||
					' Perfil_corresponsal::CHAR(10),operacion::CHAR(10),Estatus::CHAR(20),diasnocertificado::CHAR(10) '||
					' FROM bdicheq:"informix".raw_obtinfosinaprovevalu60;" > ' || TRIM(cRutaServer) || 'query.sql';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "dbaccess bdicheq " || TRIM(cRutaServer) ||"query.sql ";
		SYSTEM cSql;
		
		-- Le quita el ultimo | al archivo 
		LET cSql = "sed 's/|$//g' " || ( TRIM(cRutaServer) || "queryarchivo.unl") || " > "	|| ( TRIM(cRutaServer) || TRIM(cNom));
		SYSTEM cSql;		
		
		LET cSql = '';
		LET cSql = "rm -rf " || TRIM(cRutaServer) ||"query*";
		SYSTEM cSql;
	ELSE
		LET cCodRet = '000003';
	END IF;
	DROP TABLE bdicheq:"informix".raw_obtinfosinaprovevalu60;
	RETURN cCodRet,cEmp, cNombre,iNumPuesto, cNombrePuesto, cCentro, cPerfil_corresponsal, cOperacion, cEstatus, siDiasnocertificado,cRutaPC,cRutaServer,cUser,cPass,cIP,cNom;
END
END PROCEDURE
DOCUMENT
'AUTOR: Roberto Aguilar',
'FECHA: 22 de Julio del 2011',
'DESCRIPCION: Se genera el reporte en archivo de totales por region.',
'VERSION: 20110722.1549',
'BD: BDICHEQ',
'MODIFICO: Roberto Aguilar Pozos',
'FECHA: 31 de Agosto del 2011',
'MODIFICACION: Se corrige validacion de reporte sin datos y se reinician las variables de fechas para corregir validacion de corresponsales',
'VERSION: 20110831.1755',
'MODIFICO: Victor Hugo Nuñez',
'FECHA: 05 de Octubre del 2011',
'MODIFICACION: Se corrigio filtro para que el valor estatus sea indistinto si es en mayusculas o minusculas',
'VERSION: 20111005.0930',
'MODIFICO: Victor Hugo Nuñez',
'FECHA: 27 de Octubre del 2011',
'MODIFICACION: Se valida correctamente el campo operacion',
'VERSION: 20111027.1050',
'MODIFICO: Victor Hugo Nuñez',
'FECHA: 07 de Noviembre del 2011',
'MODIFICACION: Se valida correctamente el campo operacion de la tabla sc_movhis',
'VERSION: 20111027.1050';

CREATE PROCEDURE "informix".sp_obtienemovtosdiarios( pEmpresa  CHAR(3),
                                                     pCuenta   CHAR(20),
                                                     pFechaIni DATE,
                                                     pFechaFin DATE)
RETURNING CHAR(6)      AS cCodRet,
          INTEGER      AS Serial,
		  DATE         AS FechaAlt,
		  VARCHAR(55)  AS Transsac,
		  CHAR(4)	   AS CodigoSucursal,
		  CHAR(40)	   AS NombreSucursal,
		  CHAR(40)     AS Referencia,
		  CHAR(16)     AS NumTarjeta,
		  MONEY(14,02) AS Monto, 
		  MONEY(14,02) AS SaldoCta,
		  CHAR(1)      AS Naturaleza;
		  
    DEFINE cCodRet             CHAR(6);
    DEFINE iSql_Err            INTEGER;
    DEFINE iSam_Err            INTEGER;
    DEFINE sNumSerial          INTEGER;
    DEFINE dFechaAlt           DATE;
    DEFINE vTransacc		   VARCHAR(55);
	DEFINE cCodSuc			   CHAR(4);
    DEFINE cSucursal		   CHAR(40);
	DEFINE cReferencia         CHAR(40);
    DEFINE cNumTarjeta		   CHAR(16);
    DEFINE mMonto			   MONEY(14,02);
    DEFINE mSaldoCta		   MONEY(14,02);
    DEFINE cNaturaleza 		   CHAR(1);
    DEFINE dFechaCierre        DATE;
    DEFINE iCont               INTEGER;
    DEFINE vfechaconmovhis     CHAR(10);
    DEFINE vfechaconmovhisold  CHAR(10);

    LET cCodRet      = '000000';
    LET iSql_Err     = '000000';
    LET iSam_Err     = '000000';
    LET sNumSerial   = 0;
    LET dFechaAlt    = '01-01-2000';
    LET vTransacc    = '';
	LET cCodSuc		 ='0000';
	LET cSucursal	 = '';	
    LET cReferencia  = '';
    LET cNumTarjeta  = ''; 
    LET mMonto       = 0; 
    LET mSaldoCta    = 0;
    LET cNaturaleza  = '';
    LET dFechaCierre = NULL;
    LET iCont        = 0;
    LET vfechaconmovhis = '';
    LET vfechaconmovhisold = '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    ---SET DEBUG FILE TO "/home/sysifx/vlv/sp_obtienemovtosdiarios.out";
    ---TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal, cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
        END IF;
    END EXCEPTION;

    IF pEmpresa IS NULL OR pEmpresa = '' OR pCuenta IS NULL OR pCuenta = '' OR pFechaIni IS NULL OR pFechaIni = '' OR pFechaFin IS NULL OR pFechaFin = '' THEN
        LET cCodRet = '110';  --Faltan parametros para su ejecucion.
        RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal, cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
    END IF

    IF pFechaIni > pFechaFin THEN
        LET cCodRet = '120';  --Fecha inicio no deve ser mayor a fecha fin
        RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal ,cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
    END IF

    SELECT (fechafin + DAY(1))
      INTO dFechaCierre
      FROM bdicheq:"informix".sc_maehis 
     WHERE cuenta = pCuenta
       AND aniomes = (SELECT MAX(aniomes) FROM bdicheq:"informix".sc_maehis WHERE empresa = pEmpresa AND cuenta = pCuenta);

    IF dFechaCierre IS NOT NULL THEN
        LET pFechaIni = dFechaCierre;
    END IF
    
    SELECT valor
      INTO vfechaconmovhis
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO vfechaconmovhisold
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    FOREACH --- Se consultan los movimientos que se registraron en determienadas fechas de la cuenta.
        SELECT md.num_serial, md.fech_alt, TRIM(md.transacc)||' '||trim(tr.descripcion) transaccion, TRIM(md.sucursal), TRIM(suc.nombre) sucursal, 
               nvl(md.referencia,' ') referencia, nvl(md.num_tarjeta,' ') num_tarjeta, md.monto_tot, md.sdo_cuenta, tr.naturaleza  
          INTO sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal ,cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza
          FROM bdicheq:"informix".sc_movdia md,
               bdinteg:"informix".si_transacc tr,
			   bdinteg: "informix".si_sucursales suc	
         WHERE md.empresa = pEmpresa
           AND md.cuenta = pCuenta
           AND md.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND md.cancelad NOT IN('S','V') 
           AND tr.empresa = md.empresa
           AND tr.numero = md.transacc
		   AND md.sucursal = suc.sucursal
           AND tr.se_emite_edocta = 'S' 
        UNION ALL 
        SELECT mm.num_serial, mm.fech_alt, TRIM(mm.transacc)||' '||trim(tr.descripcion),TRIM(mm.sucursal),TRIM(suc.nombre) sucursal, 
               nvl(mm.referencia,' '), nvl(mm.num_tarjeta,' '), mm.monto_tot, mm.sdo_cuenta, tr.naturaleza  
          FROM bdicheq:"informix".sc_movhis mm, 
               bdinteg:"informix".si_transacc tr,
			   bdinteg:"informix".si_sucursales suc
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt >= vfechaconmovhis
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.cancelad NOT IN('S','V') 
           AND mm.transacc = tr.numero 
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
		   AND mm.sucursal = suc.sucursal
           AND tr.se_emite_edocta = 'S'
        UNION ALL 
        SELECT mm.num_serial, mm.fech_alt, TRIM(mm.transacc)||' '||trim(tr.descripcion),TRIM(mm.sucursal),TRIM(suc.nombre) sucursal, 
               nvl(mm.referencia,' '), nvl(mm.num_tarjeta,' '), mm.monto_tot, mm.sdo_cuenta, tr.naturaleza  
          FROM bdicheq:"informix".sc_movhis_old mm, 
               bdinteg:"informix".si_transacc tr,
			   bdinteg:"informix".si_sucursales suc
         WHERE mm.empresa = pEmpresa
           AND mm.cuenta = pCuenta
           AND mm.fech_alt >= vfechaconmovhisold
           AND mm.fech_alt < vfechaconmovhis
           AND mm.fech_alt BETWEEN pFechaIni AND pFechaFin
           AND mm.cancelad NOT IN('S','V') 
           AND mm.transacc = tr.numero 
           AND tr.empresa = mm.empresa
           AND tr.numero = mm.transacc
		   AND mm.sucursal = suc.sucursal
           AND tr.se_emite_edocta = 'S'
         ORDER BY 2 DESC, 1 DESC		 

        LET iCont = 1;

        RETURN cCodRet, sNumSerial, dFechaAlt ,vTransacc,cCodSuc , cSucursal, cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza WITH RESUME;
    END FOREACH;

    IF iCont = 0 THEN
        LET cCodRet = '000002'; -- No se encuentran registros.
        RETURN cCodRet, sNumSerial ,dFechaAlt ,vTransacc ,cCodSuc ,cSucursal ,cReferencia ,cNumTarjeta ,mMonto ,mSaldoCta ,cNaturaleza;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'MODIFICO: Valentin Lopez Valenzuela',
'FECHA: 07 de Julio del 2011',
'DESCRIPCION: Consulta los movimientos de las cuentas en un rango de fechas determinado.',
'VERSION: 20110707.1146',
'BD: BDICHEQ',
'MODIFICO: Armando Morales',
'FECHA: 30 de Enero del 2012',
'DESCRIPCION: Se agrega consulta de sucursales y numero de sucursal',
'VERSION: 20120130.1146',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".reversa_pos_dup()

  RETURNING CHAR(5), INTEGER;

    -- // DECLARACION DE VARIABLES

    DEFINE vcodret     		CHAR(5);
    DEFINE sql_err     		INTEGER;
    DEFINE vcontador		INTEGER;
    DEFINE vcuantos  		INTEGER;

    DEFINE vcuenta		    CHAR(20);
	DEFINE vfolio_suc       CHAR(16);
	DEFINE vimporte         MONEY(14,2);
	DEFINE vsdo_actual      MONEY(14,2);
	DEFINE vimp_chq_sbg     MONEY(14,2);
	DEFINE vsaldo           MONEY(14,2);
	DEFINE vsbg             MONEY(14,2);
	
        -- // INICIALIZACION DE VARIABLES

    LET vcodret	  = "000";
    LET sql_err	  = 0;
    LET vcontador = -1;
    LET vcuantos  = 0;

    BEGIN

    ON EXCEPTION
	SET sql_err
	IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
        RETURN vcodret, vcuantos;
	END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "./reversa_pos_dup.out";
    -- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     -- ********************* FOREACH PRINCIPAL ***********************

    FOREACH WITH HOLD
	  SELECT cuenta, folio_suc, importe
        INTO vcuenta, vfolio_suc, vimporte	
	    FROM bdicheq:mov_reversar_pos  
	
      IF (vcontador = -1) THEN
         BEGIN WORK;
         LET vcontador = 0;
      END IF;

	  UPDATE bdicheq:sc_movdia SET cancelad = "S"
	   WHERE cuenta = vcuenta
	     AND folio_suc = vfolio_suc;
		 
	  SELECT sdo_actual, imp_chq_sbg
        INTO vsdo_actual, vimp_chq_sbg	  
	    FROM bdicheq:sc_maechq
	   WHERE cuenta = vcuenta;
	   
	  LET vsaldo = 0;
      LET vsbg   = 0;
	  
	  IF vimp_chq_sbg > 0 THEN
         LET vsaldo = (vsdo_actual + vimporte) - vimp_chq_sbg;
	 	 LET vsbg = 0;
 	  ELSE
		 LET vsaldo = vsdo_actual + vimporte;
	  END IF;
	  
	  UPDATE bdicheq:sc_maechq 
	     SET sdo_actual = vsaldo, imp_chq_sbg = vsbg
	   WHERE cuenta = vcuenta;
            		 
	  LET vcontador = vcontador + 1;

      IF (vcontador >= 5000) THEN
         LET vcuantos = vcuantos + vcontador;
	     LET vcontador = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

    END FOREACH;

    -- ************************* FOREACH PRINCIPAL *************************

    LET vcuantos = vcuantos + vcontador;

    IF (vcontador > 0) THEN
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vcuantos;

END PROCEDURE;
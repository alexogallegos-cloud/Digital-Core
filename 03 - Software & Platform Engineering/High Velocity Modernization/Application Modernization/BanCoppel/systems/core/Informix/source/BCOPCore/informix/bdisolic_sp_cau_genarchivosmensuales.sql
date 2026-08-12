CREATE PROCEDURE "informix".sp_cau_genarchivosmensuales(pdFecha DATE, piIdArchivo INTEGER)
RETURNING CHAR(5) AS codret, CHAR(100) AS mensajeret;


--DeclaraciON de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE cErrorInfo VARCHAR(80);
DEFINE iIsamErr	INTEGER;
DEFINE vcRepositorio CHAR(50);
DEFINE vcNombreArchivo CHAR(13);
DEFINE vcCONsulta CHAR(7500);
DEFINE vFecha DATE;
DEFINE vcCONsultaBM CHAR(1700);
DEFINE vcVariables CHAR(1000);
DEFINE vcCONsultaTelCasaUB CHAR(1700);
DEFINE vcCONsultaTelCasaUC CHAR(1700);
DEFINE viTipo INT;
DEFINE vnumcte CHAR(20);
DEFINE Vnum_sol char(20);
DEFINE Dfecha_insert DATE;
DEFINE Vuser_insert CHAR(30);
DEFINE Vsucursal CHAR(4);
DEFINE vcSeparador  CHAR(1); 

DEFINE viAltaSolMixta_nuevo INT;
DEFINE viAltaSolMixta_Banco INT;
DEFINE viAltaSolMixta1 INT;
DEFINE viAltaSolMixta2 INT;
DEFINE viAltaSolUnica_nuevo INT;
DEFINE viAltaSolUnica_Banco INT;
DEFINE viBuroCredVigente INT;
DEFINE viBuroCredNva INT;
DEFINE viCirculoCredVigente INT;
DEFINE viCirculoCredNva INT;
DEFINE viOSCalleMixta INT;
DEFINE viOSCalleUnica INT;
DEFINE viAsignaciONTarjTitular INT;
DEFINE viAsignacionTarjTitular_nuevo INT;
DEFINE viAsignaciONTarjAdiciONal INT;
DEFINE viAsignacionTarjAdicional_nuevo INT;
DEFINE viReposiciONTarj INT;
DEFINE viReposicionTarj_nuevo INT;
DEFINE viTotalesAO INT;
DEFINE viTotalesSIC INT;
DEFINE viTotales INT;
DEFINE viTotalesMctrol INT;
DEFINE viCONtador INT;
DEFINE Vexiste INT;
DEFINE viCONtadorMix INT;
--InicilizANDo variables
LET vcCodRet = '00000';
LET vcMensajeRet = 'PROCESO EXITOSO';
LET viSqlErr = '';
LET cErrorInfo = '';
LET iIsamErr = 0;
LET vcRepositorio = '';
LET vcNombreArchivo = '';
LET vcCONsulta = '';
LET vFecha = DATE(1);
LET vcCONsultaBM = "";
LET vcVariables = "";
LET vcCONsultaTelCasaUB = "";
LET vcCONsultaTelCasaUC = ""; 
LET viTipo = 2;
LET vcSeparador  = '|';
LET viCONtadorMix =0;

LET viAltaSolMixta_nuevo = 0;
LET viAltaSolUnica_nuevo = 0;
LET viAltaSolMixta_Banco = 0;
LET viAltaSolUnica_Banco = 0;
LET viBuroCredVigente = 0;
LET viBuroCredNva = 0;
LET viCirculoCredVigente = 0;
LET viCirculoCredNva = 0;
LET viOSCalleMixta = 0;
LET viOSCalleUnica = 0;
LET viAsignaciONTarjTitular = 0;
LET viAsignacionTarjTitular_nuevo = 0;
LET viAsignaciONTarjAdiciONal = 0;
LET viAsignacionTarjAdicional_nuevo = 0;
LET viReposiciONTarj = 0;
LET viReposicionTarj_nuevo = 0;
LET viTotalesAO = 0;
LET viTotalesSIC = 0;
LET viTotales = 0;
LET viTotalesMctrol = 0;
LET viCONtador = 0;
LET Vnum_sol ='';
LET Vexiste = 0;


--SET DEBUG FILE TO "/tmp/Mensual/Reporte/sp_cau_genarchivosmensuales.out";
--TRACE ON;
--SET DEBUG FILE TO "/informix/c92962301/M/sp_cau_genarchivosmensual.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr, iIsamErr, cErrorInfo
	IF (viSqlErr <> 0) THEN
		LET vcCodRet = viSqlErr;
		LET vcMensajeRet = cErrorInfo;
		--Eliminar tablas temporales
	--	DROP TABLE tmp_BCCC;
	--	DROP TABLE tmp_OSCalle;
		RETURN vcCodRet, vcMensajeRet;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--select fecha_hoy into pdFecha from bdinteg:si_fechas;  --se modifico para pruebas



--LET vcRepositorio ='/informix/M';
LET vcRepositorio ='/resplogifx/archivoscartera';

	IF((piIdArchivo = 1)OR(piIdArchivo = 0)) THEN
		-- a)REP_CP_aamm.xls
		
		LET vcNombreArchivo = 'REP_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2);
		
		
		--Alta Solicitud Única Y mixtas
	
	SELECT  SUM(acumulado) INTO viAltaSolMixta_nuevo  FROM acumulado_mensual WHERE id_rpt = 1  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));
	
	SELECT  SUM(acumulado) INTO viAltaSolUnica_nuevo  FROM acumulado_mensual WHERE id_rpt = 2  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));

	SELECT  SUM(acumulado) INTO viAltaSolMixta_Banco  FROM acumulado_mensual WHERE id_rpt = 3  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));

	SELECT  SUM(acumulado) INTO viAltaSolUnica_Banco  FROM acumulado_mensual WHERE id_rpt = 4  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	
			
	--Buro de credito y circulo de credito
       
	SELECT  SUM(acumulado) INTO viBuroCredVigente  FROM acumulado_mensual WHERE id_rpt = 5  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	
       
    SELECT  SUM(acumulado) INTO viBuroCredNva  FROM acumulado_mensual WHERE id_rpt = 6  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       
	
	--		   SELECT count(num_solicitud_coppel) INTO viCirculoCredVigente from tmp_BCCC WHERE institucion ='CC' AND tipo ='V';
	--           SELECT count(num_solicitud_coppel) INTO viCirculoCredNva from tmp_BCCC WHERE institucion ='CC' AND tipo ='N';		

	-- Orden de Supervisión Calle

	SELECT  SUM(acumulado) INTO viOSCalleMixta  FROM acumulado_mensual WHERE id_rpt = 7  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       
		
	SELECT  SUM(acumulado) INTO viOSCalleUnica  FROM acumulado_mensual WHERE id_rpt = 8  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       			
				
	--Asignación de Tarjeta Titular
		
	SELECT  SUM(acumulado) INTO viAsignacionTarjTitular_nuevo  FROM acumulado_mensual WHERE id_rpt = 9  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       				
		
	SELECT  SUM(acumulado) INTO viAsignacionTarjTitular  FROM acumulado_mensual WHERE id_rpt = 10  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       					
	
	--Asignación de Tarjeta Adicional
	
	SELECT  SUM(acumulado) INTO viAsignacionTarjAdicional_nuevo  FROM acumulado_mensual WHERE id_rpt = 11  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       						
	
	SELECT  SUM(acumulado) INTO viAsignacionTarjAdicional  FROM acumulado_mensual WHERE id_rpt = 12  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       						
	
	--Reposicion de Tarjetas
			
	SELECT  SUM(acumulado) INTO viReposicionTarj_nuevo  FROM acumulado_mensual WHERE id_rpt = 13  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       							
		
	SELECT  SUM(acumulado) INTO viReposicionTarj  FROM acumulado_mensual WHERE id_rpt = 14  AND month(fecha) = month(NVL(pdFecha,''))  AND year(fecha) =  year(NVL(pdFecha,''));	       							
	
		--Mesa de Control OA
		SELECT COUNT(a.num_solicitud) INTO  viTotalesAO
		FROM bdisolic:'informix'.ss_solicitudes AS a
		INNER JOIN bdisolic:'informix'.ss_autorizacion_especial AS b
		ON a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud
		WHERE b.status_ant ='OA' AND b.status_nvo = 'EE' and a.num_producto = '6500'
		AND month(b.fecha_modif) = month(NVL(pdFecha,''))  AND year(b.fecha_modif) =  year(NVL(pdFecha,'')); 
		
		--Mesa de Control SIC
		FOREACH 
		SELECT COUNT(a.solicitud)
		INTO viTotales
		FROM bdiburo:'informix'.br_auditor AS a
		WHERE a.solicitud like '6500%'
		AND month(a.fecha) = month(NVL(pdFecha,''))  AND year(a.fecha) =  year(NVL(pdFecha,''))
		group by a.solicitud
			if (viTotales) > 1 then
			LET viTotalesSIC = viTotalesSIC + 1;
			end if;
		END FOREACH;
		
		--Mesa de Control TOTALES
		SELECT  COUNT (a.num_solicitud) INTO viTotalesMctrol
		FROM bdisolic:'informix'.ss_solicitudes AS a
		INNER JOIN bdisolic:'informix'.ss_autorizacion_especial AS b
		ON a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud
		WHERE a.num_producto = '6500'
		AND month(b.fecha_modif) = month(NVL(pdFecha,''))  AND year(b.fecha_modif) =  year(NVL(pdFecha,'')); 
		
		
		--Eliminar tablas temporales
		--DROP TABLE tmp_BCCC;
		--DROP TABLE tmp_OSCalle;
				
		LET vcConsulta = " SELECT ' '||'|'||' '||'|'||' '||'|'||' Total '||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT 'Alta de solicitud'||'|'||'Promotor Clientes Nuevos'||'|'||'Mixta'||'|'|| " || NVL(viAltaSolMixta_nuevo,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Única'||'|'|| " || viAltaSolUnica_nuevo || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT 'Alta de solicitud'||'|'||'Promotor BanCoppel'||'|'||'Mixta'||'|'|| " || NVL(viAltaSolMixta_Banco,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Única'||'|'|| " || viAltaSolUnica_Banco || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "				
				|| " SELECT 'Buró de Crédito'||'|'||' '||'|'||'Vigente'||'|'|| " || NVL(viBuroCredVigente,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Nueva'||'|'|| " || viBuroCredNva || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "				
				|| " SELECT 'Circulo de Crédito'||'|'||' '||'|'||'Vigente'||'|'|| " || NVL(viCirculoCredVigente,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Nueva'||'|'|| " || viCirculoCredNva || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "				
				|| " SELECT 'Orden de supervisión calle'||'|'||' '||'|'||'Mixta'||'|'|| " || NVL(viOSCalleMixta,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Única'||'|'|| " || viOSCalleUnica || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "				
				|| " UNION ALL "
				|| " SELECT 'Asignación de Tarjeta Titular '||'|'||' '||'|'||'Promotor Clientes Nuevos '||'|'|| " || NVL(viAsignacionTarjTitular_nuevo,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas"
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Promotor BanCoppel '||'|'|| " || NVL(viAsignacionTarjTitular,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas"
				|| " UNION ALL "
				|| " SELECT 'Asignación de Tarjeta Adicional '||'|'||' '||'|'||'Promotor Clientes Nuevos '||'|'|| " || NVL(viAsignacionTarjAdicional_nuevo,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas"
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Promotor BanCoppel '||'|'|| " || NVL(viAsignacionTarjAdicional,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas"
				|| " UNION ALL "
				|| " SELECT 'Reposición de Tarjetas'||'|'||' '||'|'||'Promotor Clientes Nuevos '||'|'|| " || NVL(viReposicionTarj_nuevo,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Promotor BanCoppel '||'|'|| " || NVL(viReposicionTarj,'') || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "				
				|| " SELECT 'Mesa De Control'||'|'||' '||'|'||'Relanzamiento AO '||'|'|| " || viTotalesAO || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Relanzamiento SIC '||'|'|| " || viTotalesSIC || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas "
				|| " UNION ALL "
				|| " SELECT ' '||'|'||' '||'|'||'Solicitudes Atendidas '||'|'|| " || viTotalesMctrol || " ||'|' "
				|| " FROM bdinteg:'informix'.si_fechas ;";
 	    		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta, vcNombreArchivo, vcRepositorio, viTipo) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	
	RETURN vcCodRet, vcMensajeRet;
	

END
END PROCEDURE

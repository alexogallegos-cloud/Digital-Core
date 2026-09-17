CREATE PROCEDURE "informix".sp_cau_genarchivosdiarios(pdFecha DATE, piIdArchivo INTEGER)
RETURNING CHAR(5) AS codret, CHAR(100) AS mensajeret;

--Declaracion de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE vcRepositorio CHAR(50);
DEFINE vcNombreArchivo1 CHAR(17);
DEFINE vcNombreArchivo2 CHAR(17);
DEFINE vcNombreArchivo3 CHAR(17);
DEFINE vcNombreArchivo4 CHAR(17);
DEFINE vcNombreArchivo5 CHAR(17);
DEFINE vcNombreArchivo6 CHAR(17);
DEFINE vcNombreArchivo7 CHAR(17);
DEFINE vcConsulta1 CHAR(6000);
DEFINE vcConsulta2 CHAR(6000);
DEFINE vcConsulta3 CHAR(6000);
DEFINE vcConsulta4 CHAR(6000);
DEFINE vcConsulta5 CHAR(6000);
DEFINE vcConsulta6 CHAR(6000);
DEFINE vcConsulta7 CHAR(6000);
--DEFINE pdFecha DATE;

--Inicilizando variables
LET vcCodRet = '00000';
LET vcMensajeRet = 'PROCESO EXITOSO';
LET viSqlErr = '';
LET vcRepositorio = '';
LET vcNombreArchivo1 = '';
LET vcNombreArchivo2 = '';
LET vcNombreArchivo3 = '';
LET vcNombreArchivo4 = '';
LET vcNombreArchivo5 = '';
LET vcNombreArchivo6 = '';
LET vcNombreArchivo7 = '';

LET vcConsulta1 = '';
LET vcConsulta2 = '';
LET vcConsulta3 = '';
LET vcConsulta4 = '';
LET vcConsulta5 = '';
LET vcConsulta6 = '';
LET vcConsulta7 = '';
--LET pdFecha = DATE(1);

--SET DEBUG FILE TO "/dbexport/sp_cau_genarchivosdiarios.out";
--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_cau_genarchivosdiarios.out";
--TRACE ON;



BEGIN

ON EXCEPTION SET viSqlErr
	IF (viSqlErr <> 0) THEN
		LET vcCodRet = viSqlErr;
		RETURN vcCodRet, vcMensajeRet;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;


--SELECT valor INTO vcRepositorio FROM bdisolic:'informix'.ss_param WHERE secuencia = '101';
--LET vcRepositorio ='/informix/D';
--LET vcRepositorio ='/informix/c92962301/archivos';
LET vcRepositorio ='/resplogifx/archivoscartera';


	IF((piIdArchivo = 1)OR(piIdArchivo = 0)) THEN
		-- a)Sol_CP_aammdd.txt
		--Diario solicitudes Unicas Coppel
		LET vcNombreArchivo1 = 'Sol_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);
		
		LET vcConsulta1 = "SELECT 'num_solicitud_coppel|num_solicitud_bancoppel|numcte|fecha_alta_solicitud|tipo|tipo_prom' "
|| "FROM bdinteg:'informix'.si_fechas "
|| "UNION ALL "
|| "SELECT TRIM(res.num_solicitud)||'|'||TRIM(res.num_solicitud_ref)||'|'||TRIM(NVL(numcte,''))||'|'|| "
|| "NVL(a.fecha_insert,'')||'|'||tipo_movimiento||'|'||(case puesto WHEN '008' then 'N' else 'B' end) "
|| "FROM bdisolic:ss_solicitudes a "
|| "inner join bdinteg:si_ejecut b on a.empresa = b.empresa and a.user_insert = b.ejecutivo "
|| "inner join bdisolic:ss_resum_scor_fin res on a.empresa = res.empresa and a.num_solicitud = res.num_solicitud "
|| "where a.empresa ='001' and num_producto ='6500' and status_solicitud NOT IN('PC','AN') "
|| "AND a.fecha_insert = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
|| "and tipo_movimiento ='U' "
|| "UNION ALL "
||"SELECT TRIM(res.num_solicitud)||'|'||TRIM(res.num_solicitud_ref)||'|'||TRIM(NVL(a.numcte,''))||'|'|| "
|| "NVL(a.fecha_insert,'')||'|'||tipo_movimiento||'|'||(case puesto WHEN '008' then 'N' else 'B' end) "
|| "from bdisolic:ss_solicitudes a "
|| "inner join bdinteg:si_ejecut c on a.empresa = c.empresa and a.user_insert = c.ejecutivo "
|| "inner join bdisolic:ss_resum_scor_fin res on a.empresa = res.empresa and a.num_solicitud = res.num_solicitud "
|| "where a.empresa ='001' "
|| " and a.num_producto ='6500' "
|| "and a.status_solicitud NOT IN('PC','AN') "
|| "AND a.fecha_insert = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
|| "and tipo_movimiento ='M';";
		
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta1, vcNombreArchivo1, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_mensual(1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		
	END IF;
	
	IF ((piIdArchivo = 2)OR(piIdArchivo = 0)) THEN
		-- b)SIC_CP_aammdd.txt
		LET vcNombreArchivo2 = 'SIC_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);
		LET vcConsulta2 = "select 'num_solicitud_coppel|num_solicitud_sic|fecha_insert|fecha_respuesta|institucion|Tipo|relanzamiento|' "
						|| " from bdinteg:'informix'.si_fechas "
						|| "UNION ALL  "
						|| "select TRIM(NVL(a.num_solicitud,''))||'|'|| "
						|| "(case when a.num_solicitud <> a.num_solicitud_sic then TRIM(NVL(a.num_solicitud_sic,''))  else '' end)  ||'|'|| "
						|| "NVL(a.fecha_insert,'') ||'|'|| NVL(a.fecha_sic,'') ||'|'|| NVL(a.institucion,'') ||'|'|| "
						|| "(case a.num_solicitud when a.num_solicitud_sic then 'N' else 'V' end) ||'|'|| "
						|| "(case ejecutivo_auto when 'sistema' then ' ' else 'MC' end) ||'|' "
						|| "from bdisolic:'informix'.ss_solicitudes_sic a "
						|| "inner join bdisolic:'informix'.ss_solicitudes b "
						|| "on a.empresa = b.empresa "
						|| "and a.numcte = b.numcte "
						|| "and a.fecha_insert = b.fecha_insert "
						|| "and a.num_solicitud = b.num_solicitud "
						|| "inner join bdisolic:'informix'.ss_autorizacion c on a.num_solicitud = c.num_solicitud and c.status_solicitud = b.status_solicitud "
						|| "where a.empresa = '001' and a.fecha_insert = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'))  "
						|| "and b.num_producto = '6500' and b.tipo_solicitud = 'C' "
						|| "and b.status_solicitud not in('PC','AN') "
						|| "and a.institucion in('CC','BC'); ";
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta2, vcNombreArchivo2, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_mensual(2) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	
	IF ((piIdArchivo = 4)OR(piIdArchivo = 0)) THEN
		-- d) OS_CP_aammdd.txt
		--Diario solicitudes Unicas Coppel
	LET vcNombreArchivo4 = 'OS_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);	
		
		
LET vcConsulta4 = "SELECT 'num_solicitud_coppel|Num_solicitud_bancoppel|fecha_os|folio|Tipo|relanzamiento|' "
|| "FROM bdinteg:'informix'.si_fechas "
|| "UNION ALL "
--UNICAS COPPEL
||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  DISTINCT(a.num_solicitud)  ||'|'|| "
||"'' ||'|'|| " 
||"NVL(fecha_respuesta,'') ||'|'|| NVL(a.secuenciaos,'') ||'|U|'|| "
||"(case c.ejecutivo_auto when 'sistema' then 'S' else 'MC' end) ||'|' "
||"from bdisolic:'informix'.ss_solicitud_os a "
||"inner join bdisolic:ss_osclientesupervisar b on a.empresa = b.empresa and a.num_solicitud = b.num_solicitud "
||"and fecha_respuesta = fecharespuesta "
||"inner join bdisolic:ss_autorizacion c on a.empresa = c.empresa and a.num_solicitud = c.num_solicitud "
||"where a.num_solicitud like '6500%' "
||"and fecha_respuesta =mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
||"and c.status_solicitud ='OS' "
||"and status ='D' "
||"UNION ALL "
||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  DISTINCT(a.num_solicitud)  ||'|'|| "
||"'' ||'|'|| " 
||"NVL(fecha_respuesta,'') ||'|'|| NVL(a.secuenciaos,'') ||'|U|'|| "
||"(case c.ejecutivo_auto when 'sistema' then 'S' else 'MC' end) ||'|' "
||"from bdisolic:'informix'.ss_solicitud_os a "
||"inner join bdisolic:ss_osclientesupervisar b on a.empresa = b.empresa and a.num_solicitud = b.num_solicitud "
||"and fecha_respuesta = fecharespuesta "
||"inner join bdisolic:ss_autorizacion c on a.empresa = c.empresa and a.num_solicitud = c.num_solicitud "
||"where a.num_solicitud like '6500%' "
||"and fecha_respuesta =mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
||"and c.status_solicitud ='OS' "
||"and status <>'D' "
||"UNION ALL " 
||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  DISTINCT(a.num_solicitud)  ||'|'|| "
||"'' ||'|'|| " 
||"NVL(fecha_respuesta,'') ||'|'|| NVL(a.secuenciaos,'') ||'|M|'|| "
||"(case c.ejecutivo_auto when 'sistema' then 'S' else 'MC' end) ||'|' "
||"from bdisolic:'informix'.ss_solicitud_os a "
||"inner join bdisolic:ss_solicitudes b on a.num_solicitud = b.num_solicitud "
||"inner join bdisolic:ss_solicitudes b2 on b.numcte = b2.numcte and b.fecha_insert=b2.fecha_insert "
||"inner join bdisolic:ss_autorizacion c on a.empresa = c.empresa and a.num_solicitud = c.num_solicitud "
||"left join bdisolic:ss_osclientesupervisar d on a.empresa = d.empresa and a.num_solicitud = d.num_solicitud "
||"and fecha_respuesta = fecharespuesta "
||"where a.empresa ='001' "
||"AND b.num_producto ='6500' and b2.num_producto in ('6001','6600') "
||"and b.status_solicitud not in('PC','AN') "
||"and b2.status_solicitud not in('PC','AN') "
||"and fecha_respuesta =mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
||"and c.status_solicitud ='OS' "
||"and status ='D' "
||"and d.num_solicitud is null "
||"UNION ALL "
||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  DISTINCT(a.num_solicitud)  ||'|'|| "
||"'' ||'|'|| " 
||"NVL(fecha_respuesta,'') ||'|'|| NVL(a.secuenciaos,'') ||'|M|'|| "
||"(case c.ejecutivo_auto when 'sistema' then 'S' else 'MC' end) ||'|' "
||"from bdisolic:'informix'.ss_solicitud_os a "
||"inner join bdisolic:ss_solicitudes b on a.num_solicitud = b.num_solicitud "
||"inner join bdisolic:ss_solicitudes b2 on b.numcte = b2.numcte and b.fecha_insert=b2.fecha_insert "
||"inner join bdisolic:ss_autorizacion c on a.empresa = c.empresa and a.num_solicitud = c.num_solicitud "
||"left join bdisolic:ss_osclientesupervisar d on a.empresa = d.empresa and a.num_solicitud = d.num_solicitud "
||"and fecha_respuesta = fecharespuesta "
||"where a.empresa ='001' "
||"AND b.num_producto ='6500' and b2.num_producto in ('6001','6600') "
||"and b.status_solicitud not in('PC','AN') "
||"and b2.status_solicitud not in('PC','AN') "
||"and fecha_respuesta =mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
||"and c.status_solicitud ='OS' "
||"and status <>'D' "
||"and d.num_solicitud is null;";

		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta4, vcNombreArchivo4, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_mensual(4) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	IF ((piIdArchivo = 5)OR(piIdArchivo = 0)) THEN
		-- e) AsigTit_CP_aammdd.txt
		--Diario tarjetas Coppel titulares asignadas
		LET vcNombreArchivo5 = 'AsigTit_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);
		LET vcConsulta5 =   "SELECT 'num_solicitud_coppel|numcte_coppel|fecha_asignacion|tipo_prom' "
						|| "FROM bdinteg:'informix'.si_fechas "
						|| "UNION ALL "
						|| "select {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)} TRIM(NVL(a.num_solicitud,'')) ||'|'|| TRIM(NVL(b.numctecoppel,''))||'|'|| NVL(b.fechamov,'') ||'|'||(case puesto WHEN '008' then 'N' else 'B' end) "
						|| "from bdisolic:'informix'.ss_solicitudes as a inner join bdinteg:'informix'.si_adiccoppel as b "
						|| "on a.numcte = b.numcte and a.empresa = b.empresa "
						|| "inner join bdinteg:si_ejecut c on b.empresa = c.empresa and b.user_insert = c.ejecutivo "
						|| "where a.empresa = '001' and b.fechamov = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) " -- Parametro un día menos del día actual
						|| "and a.num_producto = '6500' and a.status_solicitud = 'AP' and b.tipotar = '1' and secuencia = '1'; ";
						
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta5, vcNombreArchivo5, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_mensual(5) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	IF ((piIdArchivo = 6)OR(piIdArchivo = 0)) THEN
		-- f) Adi_CP_aammdd.txt
		--Diario tarjetas Coppel adicionales asignadas
		LET vcNombreArchivo6 = 'Adi_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);
		LET vcConsulta6 =   "SELECT 'numcte|numcte_adi|numtarcoppel_adi|fechamov|tipo_prom' "
						|| "FROM bdinteg:'informix'.si_fechas "
						|| "UNION ALL "			
						|| "select TRIM(NVL(a.numcte,'')) ||'|'|| TRIM(NVL(b.numcte,'')) ||'|'|| TRIM(NVL(b.numtarcoppel,'')) ||'|'|| NVL(b.fechamov,'') ||'|'||(case puesto WHEN '008' then 'N' else 'B' end) "
						|| "from bdinteg:'informix'.si_adiccoppel as a "
						|| "inner join  bdinteg:'informix'.si_adiccoppel as b "
						|| "on a.empresa = b.empresa and a.numctecoppel = b.numctecoppel and a.numctecoppel = b.numtarcoppel "
						|| "inner join bdinteg:si_ejecut c on b.empresa = c.empresa and b.user_insert = c.ejecutivo "
						|| "where b.fechamov  = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) " -- Parametro un día menos del día actual
						|| "and b.tipotar = '2'"
						|| "and a.tipotar = '1' ;";
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta6, vcNombreArchivo6, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_mensual(6) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	IF ((piIdArchivo = 7)OR(piIdArchivo = 0)) THEN
		-- g) Rep_CP_aammdd.txt
		LET vcNombreArchivo7 = 'Rep_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);
		LET vcConsulta7 =   "SELECT 'numcte|numcte_adi|numtarcoppel_rep|fechamov|tipocte|tipo_prom' "
						|| "FROM bdinteg:'informix'.si_fechas "
						|| "UNION ALL "
						|| "select {+INDEX(bdinteg:'informix'.si_adiccoppel idx_adiccoppel_generaarchivosdiarios)} (case tipotar when 1 then TRIM(NVL(numcte,'')) else '' end) ||'|'|| "
						|| "(case tipotar when 2 then TRIM(NVL(numcte,'')) else '' end)||'|'||TRIM(NVL(numtarjeta,''))||'|'|| "
						|| "b.fechamov||'|'||(case tipotar when 1 then 'T' else 'A' end)||'|'||(case puesto WHEN '008' then 'N' else 'B' end) "
						|| "from bditarjcop:'informix'.tarjetasrepotarcop a  "
						|| "inner join bdinteg:'informix'.si_adiccoppel b on a.numcliente = b.numtarcoppel  "
						|| "inner join bdinteg:si_ejecut c on b.empresa = c.empresa and b.user_insert = c.ejecutivo "
						|| "where estatustarjeta ='R' and b.fechamov = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'))"
						|| "and b.empresa = '001';";
			
		
			EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta7, vcNombreArchivo7, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_mensual(7) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	IF ((piIdArchivo = 3)OR(piIdArchivo = 0)) THEN
		-- c)ST_CP_aammdd.txt
		LET vcNombreArchivo3 = 'ST_CP_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2) || SUBSTRING(pdFecha FROM 4 FOR 2);
			
		
		LET vcConsulta3 = "SELECT 'num_solicitud_coppel|Num_solicitud_bancoppel|fecha_ST|secuenciaostel|Tipo|Resultadotelefonocasa|Causatelefonocasa|Resultadotelefonoref|Causatelefonoref|Resultadotelefonotrab|Causatelefonotrab|Resultadotelefonocelular|causatelefonocelular|' "
		||"FROM bdinteg:'informix'.si_fechas "
		||"UNION ALL "
		--UNICAS BANCOPPEL
		||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  "
		||" '|'||TRIM(NVL(a.num_solicitud,''))||'|'|| "
		||"TRIM(NVL(a.fecha_insert,''))||'|'||  TRIM(NVL(c.secuenciaostel,''))||'|U|'|| "
		||"TRIM(NVL(d.resultadotelefonocasa,''))||'|'||TRIM(NVL(d.causatelefonocasa,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonoref,''))||'|'||TRIM(NVL(d.causatelefonoref,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonotrab,''))||'|'||TRIM(NVL(d.causatelefonotrab,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonocelular,''))||'|'||TRIM(NVL(d.causatelefonocelular,''))||'|' "
		||"FROM bdisolic:'informix'.ss_solicitudes a "
		||"INNER join bdisolic:'informix'.ss_solicitudes a2 on  a.numcte = a2.numcte "
		||"INNER JOIN bdisolic:'informix'.ss_ostelrefsolicitud b on a.num_solicitud = b.num_solicitud "
		||"INNER JOIN bdisolic:'informix'.ss_osclientesupervisartel c ON c.secuenciaostel = b.secuenciaostel "
		||"LEFT JOIN bdisolic:'informix'.ss_cau_resultado_paso d ON d.secuencia = c.secuenciaostel "
		||"WHERE "
		||"a.empresa = '001' "
		||"AND c.enviada=1 "
		||"AND a.fecha_insert = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
		||"and a.fecha_insert=a2.fecha_insert "
		--and a.numcte = '005029235'
		||"AND a.num_producto in ('6001','6600') and a.numcte NOT IN "
		||"(select numcte from bdisolic:'informix'.ss_solicitudes "
		||"where num_producto ='6500' "
		||"and numcte = a.numcte and fecha_insert = a.fecha_insert) "
		||"group by a.numcte,a.num_solicitud,b.num_solicitud, c.secuenciaostel,d.resultadotelefonocasa,d.causatelefonocasa,d.resultadotelefonoref,d.causatelefonoref, "
		||"d.resultadotelefonotrab,d.causatelefonotrab,d.resultadotelefonocelular,d.causatelefonocelular,d.fechahorainicio,a.fecha_insert "
		||"UNION ALL "
		--UNICAS DE COPPEL
		||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  "
		||"TRIM(NVL(a.num_solicitud,'')) "
		||"||'||'|| "
		||"TRIM(NVL(a.fecha_insert,''))||'|'||  TRIM(NVL(c.secuenciaostel,''))||'|U|'|| "
		||"TRIM(NVL(d.resultadotelefonocasa,''))||'|'||TRIM(NVL(d.causatelefonocasa,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonoref,''))||'|'||TRIM(NVL(d.causatelefonoref,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonotrab,''))||'|'||TRIM(NVL(d.causatelefonotrab,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonocelular,''))||'|'||TRIM(NVL(d.causatelefonocelular,''))||'|' "
		||"FROM bdisolic:'informix'.ss_solicitudes a "
		||"INNER join bdisolic:'informix'.ss_solicitudes a2 on  a.numcte = a2.numcte "
		||"INNER JOIN bdisolic:'informix'.ss_ostelrefsolicitud b on a.num_solicitud = b.num_solicitud "
		||"INNER JOIN bdisolic:'informix'.ss_osclientesupervisartel c ON c.secuenciaostel = b.secuenciaostel "
		||"LEFT JOIN bdisolic:'informix'.ss_cau_resultado_paso d ON d.secuencia = c.secuenciaostel "
		||"WHERE a.empresa = '001' "
		||"AND c.enviada=1 "
		||"AND a.fecha_insert = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
		||"AND a.fecha_insert=a2.fecha_insert "
		--AND a.numcte = '005029235'
		||"AND a.num_producto ='6500' AND a.numcte NOT IN "
		||"(SELECT numcte FROM bdisolic:'informix'.ss_solicitudes "
		||"WHERE num_producto IN ('6001','6600' ) "
		||"AND numcte = a.numcte AND fecha_insert = a.fecha_insert) "
		||"GROUP BY a.numcte,a.num_solicitud,b.num_solicitud, c.secuenciaostel,d.resultadotelefonocasa,d.causatelefonocasa,d.resultadotelefonoref,d.causatelefonoref, "
		||"d.resultadotelefonotrab,d.causatelefonotrab,d.resultadotelefonocelular,d.causatelefonocelular,d.fechahorainicio,a.fecha_insert "
		||"UNION ALL "
		--MIXTAS PARA FORMAR EL ARCHIVO
		||"SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  "
		||"TRIM(NVL(a.num_solicitud,'')) "
		||"||'|'|| TRIM(NVL(a2.num_solicitud,'')) "
		||"||'|'||  TRIM(NVL(a.fecha_insert,''))||'|'||  TRIM(NVL(c.secuenciaostel,''))||'|M|'|| "
		||"TRIM(NVL(d.resultadotelefonocasa,''))||'|'||TRIM(NVL(d.causatelefonocasa,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonoref,''))||'|'||TRIM(NVL(d.causatelefonoref,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonotrab,''))||'|'||TRIM(NVL(d.causatelefonotrab,''))||'|'|| "
		||"TRIM(NVL(d.resultadotelefonocelular,''))||'|'||TRIM(NVL(d.causatelefonocelular,''))||'|' "
		||"FROM bdisolic:'informix'.ss_solicitudes a "
		||"INNER JOIN bdisolic:'informix'.ss_solicitudes a2 on  a.numcte = a2.numcte "
		||"INNER JOIN bdisolic:'informix'.ss_ostelrefsolicitud b on a.num_solicitud = b.num_solicitud "
		||"INNER JOIN bdisolic:'informix'.ss_osclientesupervisartel c ON c.secuenciaostel = b.secuenciaostel "
		||"LEFT JOIN bdisolic:'informix'.ss_cau_resultado_paso d ON d.secuencia = c.secuenciaostel "
		||"WHERE a.empresa = '001' "
		||"AND c.enviada=1 "
		||"AND a.fecha_insert = mdy(month('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),day('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"'),year('" || LPAD(month(pdFecha),2,"0") || "-" || LPAD(day(pdFecha),2,"0") ||"-" || LPAD(year(pdFecha),4,"0") ||"')) "
		||"and a.fecha_insert=a2.fecha_insert "
		--and a.numcte = '005029259'
		--||"AND a.num_producto ='6500' and a.numcte in "
		--||"(select numcte from bdisolic:ss_solicitudes "
		--||"where num_producto in ('6001','6600') "
		--||"AND numcte = a.numcte and fecha_insert = a.fecha_insert) "
		||"AND a.num_producto ='6500' and a2.num_producto in ('6001','6600') "
		||"group by a.numcte,a.num_solicitud,a2.num_solicitud,b.num_solicitud, c.secuenciaostel,d.resultadotelefonocasa,d.causatelefonocasa,d.resultadotelefonoref,d.causatelefonoref, "
		||"d.resultadotelefonotrab,d.causatelefonotrab,d.resultadotelefonocelular,d.causatelefonocelular,d.fechahorainicio,a.fecha_insert ;";
 
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta3, vcNombreArchivo3, vcRepositorio, 1) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
	END IF;

	
	RETURN vcCodRet, vcMensajeRet;
	

END
END PROCEDURE

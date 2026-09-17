CREATE PROCEDURE "informix".sp_cau_genreportesmensuales(pdFecha DATE, piIdArchivo INTEGER)
RETURNING CHAR(5) AS codret, CHAR(100) AS mensajeret;


--Declaracion de variables
DEFINE vcCodRet CHAR(5);
DEFINE vcMensajeRet CHAR(100);
DEFINE viSqlErr INTEGER;
DEFINE cErrorInfo VARCHAR(80);
DEFINE iIsamErr	INTEGER;
DEFINE vcRepositorio CHAR(50);
DEFINE vcNombreArchivo CHAR(13);
DEFINE vcConsulta CHAR(7500);
DEFINE vFecha DATE;
DEFINE vcConsultaBM CHAR(1700);
DEFINE vcVariables CHAR(1000);
DEFINE vcConsultaTelCasaUB CHAR(1700);
DEFINE vcConsultaTelCasaUC CHAR(1700);
DEFINE viTipo INT;

--Declaracion de variables para calculos
--Telefono Casa
DEFINE iTelCasaMixta DECIMAL(18,2);
DEFINE mTelCasaMixtaPorc DECIMAL(18,2);
DEFINE iTelCasaUnicaB INT;
DEFINE mTelCasaUnicaBPorc DECIMAL(18,2);
DEFINE iTelCasaUnicaC INT;
DEFINE mTelCasaUnicaCPorc DECIMAL(18,2);
DEFINE iTelCasaTotalGeneral DECIMAL(18,2);
--Telefono ref
DEFINE iTelRefMixta INT;
DEFINE mTelRefMixtaPorc DECIMAL(18,2);
DEFINE iTelRefUnicaB INT;
DEFINE mTelRefUnicaBPorc DECIMAL(18,2);
DEFINE iTelRefUnicaC INT;
DEFINE mTelRefUnicaCPorc DECIMAL(18,2);
DEFINE iTelRefTotalGeneral INT;
 --Telefono trabajo
DEFINE iTelTrabMixta INT;
DEFINE mTelTrabMixtaPorc DECIMAL(18,2);
DEFINE iTelTrabUnicaB INT;
DEFINE mTelTrabUnicaBPorc DECIMAL(18,2);
DEFINE iTelTrabUnicaC INT;
DEFINE mTelTrabUnicaCPorc DECIMAL(18,2);
DEFINE iTelTrabTotalGeneral INT;
--Telefono celular
DEFINE iTelCelMixta INT;
DEFINE mTelCelMixtaPorc DECIMAL(18,2);
DEFINE iTelCelUnicaB INT;
DEFINE mTelCelUnicaBPorc DECIMAL(18,2);
DEFINE iTelCelUnicaC INT;
DEFINE mTelCelUnicaCPorc DECIMAL(18,2);
DEFINE iTelCelTotalGeneral INT;
--Total Llamadas
DEFINE iTotalMixta INT;
DEFINE mTotalMixtaPorc DECIMAL(18,2);
DEFINE iTotalUnicaB INT;
DEFINE mTotalUnicaBPorc DECIMAL(18,2);
DEFINE iTotalUnicaC INT;
DEFINE mTotalUnicaCPorc DECIMAL(18,2);
DEFINE iTotalTotalGeneral INT;

--Total Llamadas prom
DEFINE iPromMixta INT;
DEFINE mPromMixtaPorc DECIMAL(18,2);
DEFINE iPromUnicaB INT;
DEFINE mPromUnicaBPorc DECIMAL(18,2);
DEFINE iPromUnicaC INT;
DEFINE mPromUnicaCPorc DECIMAL(18,2);
DEFINE iPromTotalGeneral INT; 
--Total Aplicar
DEFINE mTAplicarUnicaB DECIMAL(18,2);
DEFINE mTAplicarUnicaBPorc DECIMAL(18,2);
DEFINE mTAplicarUnicaC DECIMAL(18,2);
DEFINE mTAplicarUnicaCPorc DECIMAL(18,2);
DEFINE iTAplicarTotalGeneral INT;

--Inicilizando variables
LET vcCodRet = '00000';
LET vcMensajeRet = 'PROCESO EXITOSO';
LET viSqlErr = '';
LET cErrorInfo = '';
LET iIsamErr = 0;
LET vcRepositorio = '';
LET vcNombreArchivo = '';
LET vcConsulta = '';
LET vFecha = DATE(1);
LET vcConsultaBM = "";
LET vcVariables = "";
LET vcConsultaTelCasaUB = "";
LET vcConsultaTelCasaUC = ""; 
LET viTipo = 2;

--Mixtas
LET iTelCasaMixta = 0;
LET mTelCasaMixtaPorc = 0;
LET iTelCasaUnicaB = 0;
LET mTelCasaUnicaBPorc = 0;
LET iTelCasaUnicaC = 0;
LET mTelCasaUnicaCPorc = 0;
LET iTelCasaTotalGeneral = 0;
--Ref
LET iTelRefMixta = 0;
LET mTelRefMixtaPorc = 0;
LET iTelRefUnicaB = 0;
LET mTelRefUnicaBPorc = 0;
LET iTelRefUnicaC = 0;
LET mTelRefUnicaCPorc = 0;
LET iTelRefTotalGeneral = 0;
--Trabajo
LET iTelTrabMixta = 0;
LET mTelTrabMixtaPorc = 0;
LET iTelTrabUnicaB = 0;
LET mTelTrabUnicaBPorc = 0;
LET iTelTrabUnicaC = 0;
LET mTelTrabUnicaCPorc = 0;
LET iTelTrabTotalGeneral = 0;
--Celular
LET iTelCelMixta = 0;
LET mTelCelMixtaPorc = 0;
LET iTelCelUnicaB = 0;
LET mTelCelUnicaBPorc = 0;
LET iTelCelUnicaC = 0;
LET mTelCelUnicaCPorc = 0;
LET iTelCelTotalGeneral = 0;
--Total
LET iTotalMixta = 0;
LET mTotalMixtaPorc = 0;
LET iTotalUnicaB = 0;
LET mTotalUnicaBPorc = 0;
LET iTotalUnicaC = 0;
LET mTotalUnicaCPorc = 0;
LET iTotalTotalGeneral = 0;
--Total Llamadas prom
LET iPromMixta = 0;
LET mPromMixtaPorc = 0;
LET iPromUnicaB = 0;
LET mPromUnicaBPorc = 0;
LET iPromUnicaC = 0;
LET mPromUnicaCPorc = 0;
LET iPromTotalGeneral = 0; 
--Total Aplicar
LET mTAplicarUnicaB = 0;
LET mTAplicarUnicaBPorc = 0;
LET mTAplicarUnicaC = 0;
LET mTAplicarUnicaCPorc = 0;
LET iTAplicarTotalGeneral = 0;


--SET DEBUG FILE TO "/tmp/Mensual/Reporte/sp_cau_genreportesmensuales.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr, iIsamErr, cErrorInfo
	IF (viSqlErr <> 0) THEN
		LET vcCodRet = viSqlErr;
		LET vcMensajeRet = cErrorInfo;
		DROP TABLE "informix".tmp_Mixtas;
        DROP TABLE "informix".tmp_UnicaBancoppel;
		DROP TABLE "informix".tmp_UnicaCoppel;
		RETURN vcCodRet, vcMensajeRet;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

LET vcRepositorio ='/resplogifx/archivoscartera';



	IF((piIdArchivo = 1)OR(piIdArchivo = 0)) THEN
		-- a)REP_ST_aamm.txt
		
		LET vcNombreArchivo = 'REP_ST_' || SUBSTRING(pdFecha FROM 9 FOR 2) || SUBSTRING(pdFecha FROM 1 FOR 2);
		
		--Llenar las mixtas en una temporal para las consultas
				SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)}  a.secuenciaostel AS sec, d.resultadotelefonocasa,
				d.causatelefonocasa,d.resultadotelefonoref,d.causatelefonoref,d.resultadotelefonotrab,d.causatelefonotrab,d.resultadotelefonocelular,
				d.causatelefonocelular,d.fechahorainicio
				FROM bdisolic:'informix'.ss_ostelrefsolicitud a
				INNER JOIN bdisolic:'informix'.ss_solicitudes b on b.num_solicitud = a.num_solicitud
				INNER JOIN bdisolic:'informix'.ss_solicitudes b2 on b.numcte = b2.numcte and b.fecha_insert = b2.fecha_insert
				INNER JOIN bdisolic:'informix'.ss_osclientesupervisartel c	ON c.secuenciaostel = a.secuenciaostel
				INNER JOIN bdisolic:'informix'.ss_cau_resultado_paso d ON d.secuencia = a.secuenciaostel
				WHERE 
				(b.num_producto= 6500 AND b2.num_producto in (6001,6600) )
				AND c.enviada = 1 and b.empresa = b2.empresa
				AND month(b.fecha_insert) = month(NVL(pdFecha,''))  AND year(b.fecha_insert) =  year(NVL(pdFecha,'')) 
				GROUP BY a.secuenciaostel, d.resultadotelefonocasa, causatelefonocasa, d.resultadotelefonoref,d.causatelefonoref,d.resultadotelefonotrab,
				d.causatelefonotrab,d.resultadotelefonocelular,
				d.causatelefonocelular,d.fechahorainicio				
				INTO TEMP tmp_Mixtas WITH NO LOG;
		
		--Llenar las Unicas Bancoppel
		SELECT 		sec,resultadotelefonocasa,causatelefonocasa,resultadotelefonoref,causatelefonoref,resultadotelefonotrab,causatelefonotrab,
					resultadotelefonocelular,causatelefonocelular
					FROM table (MULTISET(
					SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)} COUNT(a.secuenciaostel) Contador, a.secuenciaostel as sec FROM bdisolic:'informix'.ss_ostelrefsolicitud a
					INNER JOIN bdisolic:'informix'.ss_solicitudes b on b.num_solicitud = a.num_solicitud
					INNER JOIN bdisolic:'informix'.ss_osclientesupervisartel c
					ON c.secuenciaostel = a.secuenciaostel
					WHERE (b.num_producto = 6001 or b.num_producto = 6600) AND a.secuenciaostel NOT IN
					(
						SELECT secuenciaostel FROM bdisolic:'informix'.ss_ostelrefsolicitud a
						INNER JOIN bdisolic:'informix'.ss_solicitudes b ON b.num_solicitud = a.num_solicitud
						WHERE b.num_producto = 6500
					)
					AND c.enviada = 1
					AND month(b.fecha_insert) = month(NVL(pdFecha,''))  AND year(b.fecha_insert) =  year(NVL(pdFecha,'')) 
					GROUP BY a.secuenciaostel
					--HAVING COUNT(a.secuenciaostel) = 2
					))  d 
					INNER JOIN bdisolic:'informix'.ss_cau_resultado_paso e
					ON e.secuencia = d.sec
					INTO TEMP tmp_UnicaBancoppel WITH NO LOG;
		
		--Llenar las Unicas Coppel
		SELECT 		sec,resultadotelefonocasa,causatelefonocasa,resultadotelefonoref,causatelefonoref,resultadotelefonotrab,causatelefonotrab,
					resultadotelefonocelular,causatelefonocelular
					FROM table (MULTISET(
					SELECT {+INDEX(bdisolic:'informix'.ss_solicitudes idx_ss_solicitudes2)} COUNT(a.secuenciaostel) Contador, a.secuenciaostel as sec FROM bdisolic:'informix'.ss_ostelrefsolicitud a
					INNER JOIN bdisolic:'informix'.ss_solicitudes b on b.num_solicitud = a.num_solicitud
					INNER JOIN bdisolic:'informix'.ss_osclientesupervisartel c
					ON c.secuenciaostel = a.secuenciaostel
					WHERE (b.num_producto = 6500) AND a.secuenciaostel NOT IN
					(
						SELECT secuenciaostel FROM bdisolic:'informix'.ss_ostelrefsolicitud a
						INNER JOIN bdisolic:'informix'.ss_solicitudes b ON b.num_solicitud = a.num_solicitud
						WHERE (b.num_producto = 6001 or b.num_producto = 6600)
					)
					AND c.enviada = 1
					AND month(b.fecha_insert) = month(NVL(pdFecha,''))  AND year(b.fecha_insert) =  year(NVL(pdFecha,'')) 
					GROUP BY a.secuenciaostel
					--HAVING COUNT(a.secuenciaostel) = 2
					))  d 
					INNER JOIN bdisolic:'informix'.ss_cau_resultado_paso e
					ON e.secuencia = d.sec
					INTO TEMP tmp_UnicaCoppel WITH NO LOG;		
				
		--Telefono Casa Mixtas						
		SELECT COUNT (sec) INTO iTelCasaMixta FROM tmp_Mixtas 
		WHERE resultadotelefonoCasa <> 'I' AND causatelefonoCasa = 0;
		
		--Telefono Casa - Unica Bancoppel
		SELECT COUNT(sec) INTO iTelCasaUnicaB FROM tmp_UnicaBancoppel 
		WHERE resultadotelefonocasa <> 'I' and causatelefonocasa = 0;
												
		
		--Telefono Casa Unica Coppel
		SELECT COUNT(sec) INTO iTelCasaUnicaC FROM tmp_UnicaCoppel
		WHERE resultadotelefonocasa <> 'I' and causatelefonocasa = 0;
				
		-- Telefono Ref - Mixtas
		SELECT COUNT (sec) INTO iTelRefMixta FROM tmp_Mixtas
		WHERE resultadotelefonoref <> 'I' AND causatelefonoref = 0;
		
		-- Telefono Ref - Unica Bancoppel
		SELECT COUNT(sec) INTO iTelRefUnicaB FROM tmp_UnicaBancoppel
		WHERE resultadotelefonoref <> 'I' and causatelefonoref = 0;
		
		--Telefono Ref Unica Coppel
		SELECT COUNT(sec) INTO iTelRefUnicaC FROM tmp_UnicaCoppel
		WHERE resultadotelefonoref <> 'I' and causatelefonoref = 0;
		
		--Telefono Trabajo Mixtas						
		SELECT COUNT (sec) INTO iTelTrabMixta FROM tmp_Mixtas 
		WHERE resultadotelefonoTrab <> 'I' AND causatelefonoTrab = 0;
		
		--Telefono Trabajo - Unica Bancoppel
		SELECT COUNT(sec) INTO iTelTrabUnicaB FROM tmp_UnicaBancoppel 
		WHERE resultadotelefonotrab <> 'I' and causatelefonotrab = 0;
		
		--Telefono Trabajo Unica Coppel
		SELECT COUNT(sec) INTO iTelTrabUnicaC FROM tmp_UnicaCoppel
		WHERE resultadotelefonotrab <> 'I' and causatelefonotrab = 0;
		
		--Telefono Celular Mixtas						
		SELECT COUNT (sec) INTO iTelCelMixta FROM tmp_Mixtas 
		WHERE resultadotelefonocelular <> 'I' AND causatelefonocelular = 0;
		
		--Telefono Celular - Unica Bancoppel
		SELECT COUNT(sec) INTO iTelCelUnicaB FROM tmp_UnicaBancoppel 
		WHERE resultadotelefonocelular <> 'I' and causatelefonocelular = 0;
		
		--Telefono Celular Unica Coppel
		SELECT COUNT(sec) INTO iTelCelUnicaC FROM tmp_UnicaCoppel
		WHERE resultadotelefonocelular <> 'I' and causatelefonocelular = 0;
		
		
		--Calculos para llamadas Tel Casa
		LET iTelCasaTotalGeneral = NVL(iTelCasaMixta,0) + NVL(iTelCasaUnicaB,0) + NVL(iTelCasaUnicaC,0);
		
		IF iTelCasaMixta = 0 THEN
			LET mTelCasaMixtaPorc = 0;
		ELSE
			LET mTelCasaMixtaPorc = (NVL(iTelCasaMixta,0) / NVL(iTelCasaTotalGeneral,0)) * 100;
		END IF
			
		IF iTelCasaUnicaB = 0 THEN
			LET mTelCasaUnicaBPorc = 0;
		ELSE
			LET mTelCasaUnicaBPorc = (NVL(iTelCasaUnicaB,0) / NVL(iTelCasaTotalGeneral,0)) * 100;
		END IF
		
		IF iTelCasaUnicaC = 0 THEN
			LET mTelCasaUnicaCPorc = 0;
		ELSE
			LET mTelCasaUnicaCPorc = (NVL(iTelCasaUnicaC,0) / NVL(iTelCasaTotalGeneral,0)) * 100;
		END IF
		
		--Calculos para llamadas Tel Ref
		LET iTelRefTotalGeneral = iTelRefMixta + iTelRefUnicaB + iTelRefUnicaC;
		
		SELECT limit 1 CASE WHEN iTelRefMixta = 0 THEN 0 ELSE (iTelRefMixta / iTelRefTotalGeneral) * 100 END INTO mTelRefMixtaPorc
		FROM bdinteg:'informix'.si_fechas; 		
		
		SELECT limit 1 CASE WHEN iTelRefUnicaB = 0 THEN 0 ELSE (iTelRefUnicaB / iTelRefTotalGeneral) * 100 END INTO mTelRefUnicaBPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTelRefUnicaC = 0 THEN 0 ELSE (iTelRefUnicaC / iTelRefTotalGeneral) * 100 END INTO mTelRefUnicaCPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		--Calculos para llamadas Tel Trabajo
		LET iTelTrabTotalGeneral = iTelTrabMixta + iTelTrabUnicaB + iTelTrabUnicaC;
		
		SELECT limit 1 CASE WHEN iTelTrabMixta = 0 THEN 0 ELSE (iTelTrabMixta / iTelTrabTotalGeneral) * 100 END INTO mTelTrabMixtaPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTelTrabUnicaB = 0 THEN 0 ELSE (iTelTrabUnicaB / iTelTrabTotalGeneral) * 100 END INTO mTelTrabUnicaBPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTelTrabUnicaC = 0 THEN 0 ELSE (iTelTrabUnicaC / iTelTrabTotalGeneral) * 100 END INTO mTelTrabUnicaCPorc
		FROM bdinteg:'informix'.si_fechas; 
				
		--Calculos para llamadas Tel Celular
		LET iTelCelTotalGeneral = iTelCelMixta + iTelCelUnicaB + iTelCelUnicaC;
		
		SELECT limit 1 CASE WHEN iTelCelMixta = 0 THEN 0 ELSE (iTelCelMixta / iTelCelTotalGeneral) * 100 END INTO mTelCelMixtaPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTelCelUnicaB = 0 THEN 0 ELSE (iTelCelUnicaB / iTelCelTotalGeneral) * 100 END INTO mTelCelUnicaBPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTelCelUnicaC = 0 THEN 0 ELSE (iTelCelUnicaC / iTelCelTotalGeneral) * 100 END INTO mTelCelUnicaCPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		
		--Calculos de Total de Llamadas
		LET iTotalMixta = iTelCasaMixta + iTelRefMixta + iTelTrabMixta + iTelCelMixta;
		LET iTotalUnicaB = iTelCasaUnicaB + iTelRefUnicaB + iTelTrabUnicaB + iTelCelUnicaB;
		LET iTotalUnicaC = iTelCasaUnicaC + iTelRefUnicaC + iTelTrabUnicaC + iTelCelUnicaC;
		LET iTotalTotalGeneral = iTotalMixta + iTotalUnicaB + iTotalUnicaC;
		
		SELECT limit 1 CASE WHEN iTotalMixta = 0 THEN 0 ELSE (iTotalMixta / iTotalTotalGeneral) * 100 END INTO mTotalMixtaPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTotalUnicaB = 0 THEN 0 ELSE (iTotalUnicaB / iTotalTotalGeneral) * 100 END INTO mTotalUnicaBPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN iTotalUnicaC = 0 THEN 0 ELSE (iTotalUnicaC / iTotalTotalGeneral) * 100 END INTO mTotalUnicaCPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		
		--Calculos Total Llamadas promedio
		LET iPromMixta = ROUND(iTotalMixta / 4);
		LET mPromMixtaPorc = mTotalMixtaPorc; --Queda igual que el Total Mixta Porcentaje
		LET iPromUnicaB = ROUND(iTotalUnicaB / 4);
		LET mPromUnicaBPorc = mTotalUnicaBPorc; --Queda igual que el Total Unica Bancoppel Porcentaje
		LET iPromUnicaC = ROUND(iTotalUnicaC / 4);
		LET mPromUnicaCPorc = mTotalUnicaCPorc; --Queda igual que el Total Unica Coppel Porcentaje
		LET iPromTotalGeneral = ROUND(iTotalTotalGeneral / 4); 
		
		--Total Aplicar
		LET mTAplicarUnicaB = ROUND((iTotalMixta * 0.5) + iTotalUnicaB);
		
		SELECT limit 1 CASE WHEN mTAplicarUnicaB = 0 THEN 0 ELSE  (mTAplicarUnicaB / iTotalTotalGeneral) * 100 END INTO mTAplicarUnicaBPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		SELECT limit 1 CASE WHEN mTAplicarUnicaB = 0 THEN 0 ELSE  (mTAplicarUnicaB / iTotalTotalGeneral) * 100 END INTO mTAplicarUnicaBPorc
		FROM bdinteg:'informix'.si_fechas; 
				
		LET mTAplicarUnicaC = CAST( ((iTotalMixta * 0.5) + iTotalUnicaC) AS DECIMAL(18,0));
		
		SELECT limit 1 CASE WHEN mTAplicarUnicaC = 0 THEN 0 ELSE  (mTAplicarUnicaC / iTotalTotalGeneral) * 100 END INTO mTAplicarUnicaCPorc
		FROM bdinteg:'informix'.si_fechas; 
		
		LET iTAplicarTotalGeneral = iTotalTotalGeneral; 
		
		--Eliminar tablas temporales
		DROP TABLE tmp_Mixtas;
		DROP TABLE tmp_UnicaBancoppel;
		DROP TABLE tmp_UnicaCoppel;
 
	    LET vcConsulta = " SELECT  ' '||'|'||' '||'|'||'BANCOPPEL'||'|'||'  '||'|'||'   '||'|' ||' COPPEL  '||'|' ||'   '||'|' "
							|| "FROM bdinteg:'informix'.si_fechas "
							|| "UNION ALL "
							|| "SELECT 'CONCEPTO'||'|'||'MIXTA'||'|'||'MIXTA %'||'|'||'UNICA'||'|'||'UNICA %'||'|'||'UNICA'||'|'||'UNICA %'||'|'||'TOTAL GENERAL'||'|' "
							|| "FROM bdinteg:'informix'.si_fechas "
							|| "UNION ALL "
							||" SELECT  'Teléfono casa '||'|'|| " || NVL(iTelCasaMixta,'') || " ||'|'|| " || NVL(mTelCasaMixtaPorc,'') || " || ' %'||'|'|| " || NVL(iTelCasaUnicaB,'') || "||'|' || " || NVL(mTelCasaUnicaBPorc,'') ||" ||' %'||'|' || " || NVL(iTelCasaUnicaC,'') || "||'|' || " || NVL(mTelCasaUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iTelCasaTotalGeneral,'') || "  ||'|' "
							||" FROM bdinteg:'informix'.si_fechas "
							||" UNION ALL "
							||" SELECT  'Teléfono ref '||'|'|| " || NVL(iTelRefMixta,'') || " ||'|'|| " || NVL(mTelRefMixtaPorc,'') || " || '  %'||'|'|| " || NVL(iTelRefUnicaB,'') || "||'|' || " || NVL(mTelRefUnicaBPorc,'') ||" ||' %'||'|' || " || NVL(iTelRefUnicaC,'') || "||'|' || " || NVL(mTelRefUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iTelRefTotalGeneral,'') || "  ||'|' "
							||" FROM bdinteg:'informix'.si_fechas "
							||" UNION ALL "
							||" SELECT 'Teléfono trabajo '||'|'|| " || NVL(iTelTrabMixta,'') || " ||'|'|| " || NVL(mTelTrabMixtaPorc,'') || " || ' %'||'|'|| " || NVL(iTelTrabUnicaB,'') || "||'|' || " || NVL(mTelTrabUnicaBPorc,'') ||" ||' %'||'|' || " || NVL(iTelTrabUnicaC,'') || "||'|' || " || NVL(mTelTrabUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iTelTrabTotalGeneral,'') || "  ||'|' "
							||" FROM bdinteg:'informix'.si_fechas "
							||" UNION ALL "
							||" SELECT  'Teléfono celular '||'|'|| " || NVL(iTelCelMixta,'') || " ||'|'|| " || NVL(mTelCelMixtaPorc,'') || " || ' %'||'|'|| " || NVL(iTelCelUnicaB,'') || "||'|' || " || NVL(mTelCelUnicaBPorc,'') ||" ||' %'||'|' || " || NVL(iTelCelUnicaC,'') || "||'|' || " || NVL(mTelCelUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iTelCelTotalGeneral,'') || "  ||'|' "
							||" FROM bdinteg:'informix'.si_fechas"
							||" UNION ALL "
							||" SELECT  'Total llamadas '||'|'|| " || NVL(iTotalMixta,'') || " ||'|'|| " || NVL(mTotalMixtaPorc,'') || " || ' %'||'|'|| " || NVL(iTotalUnicaB,'') || "||'|' || " || NVL(mTotalUnicaBPorc,'') ||" ||' %'||'|' || " || NVL(iTotalUnicaC,'') || "||'|' || " || NVL(mTotalUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iTotalTotalGeneral,'') || "  ||'|' "
							||" FROM bdinteg:'informix'.si_fechas"
							||" UNION ALL "
							||" SELECT 'Total llamadas prom'||'|'|| " || NVL(iPromMixta,'') || " ||'|'|| " || NVL(mPromMixtaPorc,'') || " || ' %'||'|'|| " || NVL(iPromUnicaB,'') || "||'|' || " || ROUND(NVL(mPromUnicaBPorc,'')) ||" ||' %'||'|' || " || NVL(iPromUnicaC,'') || "||'|' || " || NVL(mPromUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iPromTotalGeneral,'') || "  ||'|' "
							||" FROM bdinteg:'informix'.si_fechas"
							||" UNION ALL "
							||" SELECT 'Total llamadas a Aplicar a Bancoppel y Coppel'||'|'|| ' ' ||'|'|| ' '||'|'|| " || NVL(mTAplicarUnicaB,'') || "||'|' || " || ROUND(NVL(mTAplicarUnicaBPorc,'')) ||" ||' %'||'|' || " || NVL(mTAplicarUnicaC,'') || "||'|' || " || NVL(mTAplicarUnicaCPorc,'') || " ||' %'||'|' || " || NVL(iTAplicarTotalGeneral,'') || "  ||'|' "
						    ||" FROM bdinteg:'informix'.si_fechas ;"; 
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_cau_descargaarchivo(vcConsulta, vcNombreArchivo, vcRepositorio, viTipo) INTO vcCodRet, vcMensajeRet;
		
		IF (vcCodRet<>'00000') THEN
			RETURN vcCodRet, vcMensajeRet;
		END IF;
		
	END IF;
	

	RETURN vcCodRet, vcMensajeRet;
	
END
END PROCEDURE

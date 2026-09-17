CREATE PROCEDURE "informix".sp_rep_pp_auto_no_utilizado(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

-- Septiembre 2012. MAHR Reporte de Creditos de Prestamo Personal autorizados, no utlizados.

DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaLimSolic   DATE;
DEFINE dtFechaFin       DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(2500);
DEFINE cSQL1            CHAR(500);
DEFINE cSQL2            CHAR(1500);
DEFINE cSQL3            CHAR(500);
DEFINE sDiasVig         SMALLINT;
DEFINE sDiasVige        SMALLINT;
DEFINE cNum_dia         CHAR(2);
DEFINE cNum_mes         CHAR(2);
DEFINE cNum_anio        CHAR(4);
DEFINE cNum_cte         CHAR(20);
DEFINE cNum_cred        CHAR(20);
DEFINE cNumTel          CHAR(13);
DEFINE vRegistrosLimit	INTEGER;
DEFINE vTot_Registros   INTEGER;
DEFINE viPrioridad      INTEGER;
DEFINE sPaso			SMALLINT;
DEFINE cdelimitador         CHAR(1);

--SET DEBUG FILE TO "/informix/gpe/sp_rep_pp_auto_no_utilizado.out";
--TRACE ON;

LET vproceso        = '0062';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET dFechaLimSolic  = DATE(0); 
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArch        = '';
LET cNomArch1       = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cSQL3           = '';
LET sDiasVig        = 0;
LET sDiasVige       = 0;
LET cNum_dia        = '';
LET cNum_mes        = '';
LET cNum_anio       = '';
LET cNum_cte        = '';
LET cNum_cred       = '';
LET cNumTel         = '';
LET vRegistrosLimit = 0;
LET vTot_Registros  = 0;
LET sPaso           = 0;
LET viPrioridad     = 0;
LET cdelimitador            = "";

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;

        SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tmp_rep_pp1';
        IF NVL(sPaso,0) > 0 THEN
            DROP TABLE tmp_rep_pp1;
        END IF;
        RETURN cCodRet, cMensajeRet;

    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;
	
                   
				   -- Fecha limite de solicitudes activadas
    SELECT fecha_hoy - 30 units day INTO dFechaLimSolic FROM bdicred:sd_fechas WHERE empresa = pEmpresa;

    LET dtFechaFin = mdy(month(dFechaHoy),'01',year(dFechaHoy)) - 1 units day;
    LET cNum_dia = lpad(day(dFechaHoy),2,'0');
    LET cNum_mes =  lpad(month(dFechaHoy),2,'0');
    LET cNum_anio = lpad(year(dFechaHoy),4,'0');
    LET cNum_anio = substr(year(dFechaHoy),3,2);

	LET sPaso = 0;
    SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'tmp_rep_pp2';
    IF NVL(sPaso,0) > 0 THEN
        DROP TABLE tmp_rep_pp2;
    END IF;

    -- Elimina registros en tablas de consultas previas
    DELETE FROM bdinteg:si_telefonos_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT';
    DELETE FROM bdinteg:si_clientes_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT';

	SELECT TRIM(valor_alfabetico) INTO cdelimitador 
		FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa AND tipo_campania = 61 
	AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;
	
    SELECT valor_numerico INTO vRegistrosLimit  -- Parametro de No de registros limite
        FROM bdicred:sd_param_campania WHERE tipo_campania = 50 AND grupo_parametro = 'CAT_PROMOS' AND num_parametro = 1;
	IF vRegistrosLimit = 0 THEN
        LET cCodRet = '104001';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;
	
	SELECT valor_numerico INTO sDiasVige  -- Parametro de No de días vigentes a consultar
        FROM bdicred:sd_param_campania WHERE tipo_campania = 50 AND grupo_parametro = 'CAT_PROMOS' AND num_parametro = 4;
	IF sDiasVige = 0 THEN
        LET cCodRet = '104001';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor_alfabetico INTO cRutaArch      -- Ruta destino del archivo
        FROM bdicred:sd_param_campania WHERE tipo_campania = 50 AND grupo_parametro = 'CAT_PROMOS' AND num_parametro = 2;
	IF NVL (cRutaArch,'') = '' THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT valor_alfabetico INTO cNomArchivo    -- Nombre de Archivo
        FROM bdicred:sd_param_campania WHERE tipo_campania = 63 AND num_parametro = 338;
	IF NVL (cNomArchivo,'') = '' THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

	SELECT NVL(dias_vigencia, 0) INTO sDiasVig  -- Dias de vigencia de solicitud de Prestamo Personal autorizado. En este se cancela
        FROM bdisolic:"informix".ss_vigencia_sol_productos WHERE empresa = pEmpresa AND status_solicitud = 'AT' AND num_producto = '6300';
    LET sDiasVig = sDiasVig - 1;
	IF sDiasVig = 0 THEN
        LET cCodRet = '104001';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;


    INSERT INTO bdinteg:"informix".si_clientes_nvo_layout_cat
        SELECT 'PPAUTNOUT', 'PPS' prom, 9 tip_log, dFechaHoy fhhoy, sol.num_solicitud, sol.sucursal, sol.numcte, '0' tarj, 0 statusprom, 0 prioridad, 
            cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2,
            ctf.sexo,
			--CASE WHEN ctf.sexo = 'F' THEN 'FEMENINO' ELSE 'MASCULINO' END sexo,
            ctf.estado_civil,
			--(CASE WHEN ctf.estado_civil = 'C' THEN 'CASADO' WHEN ctf.estado_civil = 'D' THEN 'DIVORCIADO'
             --WHEN ctf.estado_civil = 'S' THEN 'SOLTERO' WHEN ctf.estado_civil = 'U' THEN 'UNION LIBRE'
             --WHEN ctf.estado_civil = 'V' THEN 'VIUDO' END) estado_civil,  --ctf.email, 
			nvl( trim(replace(corr.correo_elec,'|','')), '') correo, es.nombre, cat.municipiozona, 
            aut.fecha_insert, date(aut.fecha_insert + sDiasVig units day) fechlimit
            FROM bdisolic:ss_solicitudes sol
            JOIN bdinteg:si_cliente cte ON (sol.empresa = cte.empresa AND sol.numcte = cte.numcte)
            JOIN bdinteg:si_ctepf ctf ON (sol.numcte = ctf.numcte)
            JOIN bdinteg:si_direcciones_actual dir1 ON (sol.numcte = dir1.numcte AND dir1.tipo_dir = '1')
            JOIN bdinteg:si_estados es on (es.estado=dir1.estado  ) 
			--JOIN bdisolic:ss_circulo_edos est ON ( dir1.estado = est.clave )
            JOIN bdinteg:si_catzonas cat ON ( dir1.numerociudad = cat.numerociudad AND dir1.numerocolonia = cat.numerocolonia )
            JOIN bdisolic:ss_autorizacion aut ON (aut.empresa = pEmpresa AND sol.num_solicitud = aut.num_solicitud AND aut.status_solicitud = 'AT' 
                                      AND aut.fecha_entrada <= dFechaHoy  AND aut.rowid = (select max(t.rowid) from bdisolic:ss_autorizacion t 
                                      where t.empresa = pEmpresa and t.num_solicitud = sol.num_solicitud and t.status_solicitud = 'AT' ) )
            LEFT OUTER JOIN bdinteg:si_correos corr ON ( sol.numcte = corr.numcte AND corr.status_correo = 'A'
                 AND corr.secuencia = (Select max(secuencia) from bdinteg:si_correos Where sol.numcte = numcte and status_correo = 'A'))
            WHERE sol.empresa = pEmpresa 
            AND sol.num_solicitud NOT IN (select num_credito FROM bdicred:sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = sol.num_solicitud)
            AND sol.status_solicitud = 'AT'
            AND sol.num_producto in ('6300','7600','7700')
            AND sol.fecha_insert <= dFechaHoy 
            AND date(aut.fecha_insert) >=  dFechaHoy - sDiasVige units day;

    INSERT INTO bdinteg:"informix".si_telefonos_nvo_layout_cat
        SELECT 'PPAUTNOUT', rep_pp.num_credito_solic, rep_pp.numcte, tel.tipo_tel::CHAR, decode(tel.tipo_tel,1,'F',2,'M','F') tipo_red, 
                substr(tel.telefono,length(tel.telefono)-9,10) telefono_original, substr(tel.telefono,length(tel.telefono)-9,10) telefono_Reconstruido, 
                NVL(tel.carrier,''), NVL(tel.extension, '')
        FROM bdinteg:si_clientes_nvo_layout_cat rep_pp JOIN bdinteg:si_telefonos_actual tel ON ( rep_pp.numcte = tel.numcte )
        WHERE rep_pp.grupo_archivos = 'PPAUTNOUT' AND tel.status_tel = 'A' AND tel.cofetel = 'V' AND trim(tel.telefono) <> ''
        AND tel.tipo_tel IN (1,2,3);

    -- Obtiene los telefonos de referencia casa. (Tipo 4 = Casa Referencia)
    INSERT INTO bdinteg:si_telefonos_nvo_layout_cat
        SELECT 'PPAUTNOUT', cte.num_credito_solic, cte.numcte, '4', 'F', refdir.telefono1, telefono1,0,''  ---INTO cNum_cred, cNum_cte
		FROM bdinteg:si_clientes_nvo_layout_cat cte
        JOIN bdinteg:si_refdirecciones refdir ON (cte.numcte = refdir.numcte)
		WHERE cte.grupo_archivos = 'PPAUTNOUT' AND refdir.tipo_dir = '1' AND refdir.tipo_telef1 = 'P' AND refdir.ind_cofeteltel1 = 'V'
		AND trim(refdir.telefono1) <> ''
        AND secuencia = (Select max(secuencia) from bdinteg:si_refdirecciones where numcte = cte.numcte and tipo_dir = '1'
		AND tipo_telef1 = 'P' and ind_cofeteltel1 = 'V')
        GROUP BY cte.num_credito_solic, cte.numcte, refdir.telefono1 ;

    -- Elimina registros de clientes de los que no se obtuvieron telefonos.
    DELETE FROM bdinteg:"informix".si_clientes_nvo_layout_cat 
        WHERE grupo_archivos = 'PPAUTNOUT' 
        AND numcte NOT IN (Select numcte From bdinteg:"informix".si_telefonos_nvo_layout_cat where grupo_archivos = 'PPAUTNOUT' group by numcte);

    IF ( SELECT COUNT(*) FROM bdinteg:si_clientes_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT' ) = 0 THEN 
        LET cMensajeRet = 'SIN INFORMACION';
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;    
    END IF

    -- Actualiza el orden de prioridad de acuerdo a la fecha de vigencia de la solicitud
    LET viPrioridad = 1;
    FOREACH
        SELECT numcte, num_credito_solic INTO cNum_cte, cNum_cred 
        FROM bdinteg:"informix".si_clientes_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT'
        ORDER BY fecha_autorizacion DESC

        UPDATE bdinteg:"informix".si_clientes_nvo_layout_cat SET prioridad = viPrioridad 
            WHERE grupo_archivos = 'PPAUTNOUT' AND numcte = cNum_cte AND num_credito_solic = cNum_cred;
        
        LET viPrioridad = viPrioridad + 1;
    END FOREACH;
			
			CREATE TABLE "informix".tmp_rep_pp1 ( 
            tipo_promocion CHAR(3),     tipo_logica SMALLINT,           num_solicitud CHAR(20),
            numcte CHAR(20),            prioridad SERIAL,               nombre1 CHAR(50),
            sexo CHAR(10),                  estado_civil CHAR(12),      correo CHAR(60),
            estado CHAR(30),            fecha_autorizacion DATE,        fecha_lim_recoger DATE,
			telefono1 CHAR(13), 		telefono2 CHAR(13), 			telefono3 CHAR(13), 		telefono4 CHAR(13), extension CHAR(05));
            create index "informix".inx_tmp_rep_pp1 on tmp_rep_pp1(numcte);
            create index "informix".inx2_tmp_rep_pp1 on tmp_rep_pp1(fecha_lim_recoger);	

			INSERT INTO "informix".tmp_rep_pp1
			SELECT rep_pp.tipo_promocion, rep_pp.tipo_logica, rep_pp.num_credito_solic, rep_pp.numcte,
			rep_pp.prioridad, trim(rep_pp.apell_paterno)||' '||trim(rep_pp.apell_materno)||' '||trim(rep_pp.nombre1)||' '||trim(rep_pp.nombre2) as nombre, rep_pp.sexo, rep_pp.estado_civil, 
			rep_pp.correo, rep_pp.estado, rep_pp.fecha_autorizacion,
			rep_pp.fecha_vigencia, tel1.telefono as telefono1, tel2.telefono as telefono2, tel3.telefono as telefono3, tel4.telefono as telefono4, tel3.extension as extension
			FROM bdinteg:si_clientes_nvo_layout_cat rep_pp
			LEFT JOIN bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte= rep_pp.numcte and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                            and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = rep_pp.numcte and tipo_tel = 1 and cofetel ='V') )
			LEFT JOIN bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001' and tel2.numcte= rep_pp.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = rep_pp.numcte and tipo_tel = 2 and cofetel ='V'))
			LEFT JOIN bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001' and tel3.numcte= rep_pp.numcte and tel3.tipo_tel = 3 and tel3.cofetel ='V'
                            and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = rep_pp.numcte and tipo_tel = 3 and cofetel ='V'))
			LEFT JOIN bdinteg:si_telefonos_actual tel4  on (tel4.empresa = '001' and tel4.numcte= rep_pp.numcte and tel4.tipo_tel = 4 and tel3.cofetel ='V'
                            and tel4.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
                                                 where numcte = rep_pp.numcte and tipo_tel = 4 and cofetel ='V'))
			WHERE rep_pp.grupo_archivos = 'PPAUTNOUT';
	
	--Elimina
	update tmp_rep_pp1 
		set telefono4 = nvl(substr(telefono4,length(telefono4)-9,10),''),
			telefono1 = nvl(substr(telefono1,length(telefono1)-9,10),''), 
			telefono2 = nvl(substr(telefono2,length(telefono2)-9,10),''),
			telefono3 = nvl(substr(telefono3,length(telefono3)-9,10),'');
	
	delete from tmp_rep_pp1  where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' 
		and nvl(telefono4,'')='';

	update tmp_rep_pp1 set telefono2 = ''
	where nvl(telefono1,'')= nvl(telefono2,'');

	update tmp_rep_pp1 set telefono3 = ''
	where nvl(telefono3,'')= nvl(telefono2,'') or nvl(telefono3,'')= nvl(telefono1,'');

	update tmp_rep_pp1 set telefono4 = ''
	where nvl(telefono1,'')= nvl(telefono4,'') or nvl(telefono2,'')= nvl(telefono4,'') or nvl(telefono3,'')= nvl(telefono4,''); 
	
	update tmp_rep_pp1 
		set telefono4 = nvl(telefono4,'') ,
			telefono1 = nvl(telefono1,''), 
			telefono2 = nvl(telefono2,''),
			telefono3 = nvl(telefono3,''); 
			
update tmp_rep_pp1 
		set telefono4 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then 
									SUBSTR(telefono4,1,2) else SUBSTR(telefono4,1,3) end 
						   AND a.serie = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then SUBSTR(telefono4,3,4) else SUBSTR(telefono4,4,3) end 
						   AND (SUBSTR(telefono4,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono4,7,4)*1)*1 <= a.numeracion_final ),'')||telefono4 ,
			telefono1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono1,1,2) else SUBSTR(telefono1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then SUBSTR(telefono1,3,4) else SUBSTR(telefono1,4,3) end 
						   AND (SUBSTR(telefono1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono1 ,		 
			telefono2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono2 ,1,2) else SUBSTR(telefono2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then SUBSTR(telefono2 ,3,4) else SUBSTR(telefono2,4,3) end 
						   AND (SUBSTR(telefono2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono2 ,
			telefono3 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then 
									SUBSTR(telefono3,1,2) else SUBSTR(telefono3,1,3) end 
						   AND a.serie = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then SUBSTR(telefono3,3,4) else SUBSTR(telefono3,4,3) end 
						   AND (SUBSTR(telefono3,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono3,7,4)*1)*1 <= a.numeracion_final ),'')||telefono3; 
			
		update tmp_rep_pp1 
		set telefono4 = decode(telefono4,'',null, telefono4),
			telefono1 = decode(telefono1,'',null, telefono1), 
			telefono2 = decode(telefono2,'',null, telefono2),
			telefono3 = decode(telefono3,'',null, telefono3);								
			
    -- Obtiene el numero total de registros generados
    SELECT count(*) INTO vTot_Registros FROM bdinteg:"informix".si_clientes_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT';

	INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total)
	VALUES('001', dFechaHoy , 'PP_AUT_NOUTIL', vTot_Registros);	
    --- GENER ARCHIVO DEL REPORTE CON DATOS DE LOS CLIENTES
    IF vTot_Registros > vRegistrosLimit THEN
	
        LET cNomArch1 =  TRIM(cNomArchivo) || '_Aux_tot_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArch  =  TRIM(cNomArchivo)|| vTot_Registros || '_'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArchEjecSql = 'Rep_PP_autnoutil_tot.sql';
    ELSE
		LET cNomArch1 =  TRIM(cNomArchivo) || '_Aux_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArch  =  TRIM(cNomArchivo) || '_' || vTot_Registros || '_'|| TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArchEjecSql = 'Rep_PP_autnoutil_tot.sql';
    END IF;

    LET cSQL = '';
	LET cSQL = ' echo "Tipo_Promocion'|| cdelimitador ||'Tipo_Logica'|| cdelimitador ||'Numero_de_Credito'|| cdelimitador ||'Numero_de_Cliente'|| cdelimitador ||
	'Prioridad'|| cdelimitador ||'Nombre'|| cdelimitador ||'Sexo'|| cdelimitador ||'Estado_Civil'|| cdelimitador ||'Email'|| cdelimitador ||'Estado'|| cdelimitador ||
	'Fecha_autorizacion'|| cdelimitador ||'Fecha_limite_para_recoger_PP'|| cdelimitador ||'Tel_const_tipo_1'|| cdelimitador ||'Tel_const_tipo_2'|| cdelimitador ||
	'Tel_const_tipo_3'|| cdelimitador ||'Tel_const_tipo_4'|| cdelimitador ||'Extension'|| cdelimitador ||'"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = ''; 
    LET cSQL2 = ' SELECT tipo_promocion,tipo_logica,num_solicitud,numcte,prioridad,nombre1,sexo,estado_civil,correo, '||
   ' estado,fecha_autorizacion,fecha_lim_recoger,'||   
		' telefono1,telefono2,telefono3,telefono4,extension  '||
		' from tmp_rep_pp1 '||
		' order by prioridad ';
             
    LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL = 'chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;


    /*-- GENERA ARCHIVO DEL REPORTE CON TELEFONOS DE LOS CLIENTES
    LET cNomArch1 = '';     LET cNomArch = '';      LET cNomArchEjecSql = '';

    IF vTot_Registros > vRegistrosLimit THEN
        LET cNomArch1 =  TRIM(cNomArchivo) || '_Tel_Aux_tot_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArch  =  TRIM(cNomArchivo) || '_total_telefonos_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArchEjecSql = 'Rep_PP_telef_autnoutil_tot.sql';
    ELSE
        LET cNomArch1 =  TRIM(cNomArchivo) || '_tel_Aux_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArch  =  TRIM(cNomArchivo) || '_Telefonos_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArchEjecSql = 'Rep_PP_telef_autnoutil_tot.sql';
    END IF;


	LET cSQL = '';
	LET cSQL = ' echo "Numero Credito;Numero Cliente;Tipo Telefono;Tipo Red;Telefono Original;Telefono Construido;Carrier;Extension; "> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

    LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''';''' ;

    LET cSQL2 = ''; 
    LET cSQL2 = " SELECT num_credito, numcte, tipotelefono, tipored, telefono_orig, telefono_reconst, carrier, extension "
                || " FROM bdinteg:si_telefonos_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT' "
                || " ORDER BY numcte ";

    LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = cSQL;
    LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;*/


    /*--- GENERA ARCHIVO CON DATOS DE LOS CLIENTES CON REGISTROS LIMITADOS.
    IF vTot_Registros > vRegistrosLimit THEN

        CREATE TABLE "informix".tmp_rep_pp2 ( 
            tipo_promocion CHAR(3),     tipo_logica SMALLINT,           fecha DATE,                 num_solicitud CHAR(20),
            sucursal CHAR(04),          numcte CHAR(20),                ult_4dig CHAR(4),           status SMALLINT,
            prioridad SERIAL,           apell_paterno CHAR(26),         apell_materno CHAR(26),     nombre1 CHAR(26),
            nombre2 CHAR(26),           sexo CHAR(10),                  estado_civil CHAR(12),      correo CHAR(60),
            estado CHAR(30),            municipio CHAR(30),             fecha_autorizacion DATE,    fecha_lim_recoger DATE  );
            create index "informix".inx_tmp_rep_pp2 on tmp_rep_pp2(numcte);
            create index "informix".inx2_tmp_rep_pp2 on tmp_rep_pp2(fecha_lim_recoger);

        SELECT LIMIT vRegistrosLimit tipo_promocion, tipo_logica, fecha, num_credito_solic, sucursal, numcte, num_tarjeta, statusprom,
                0 prioridad, apell_paterno, apell_materno, nombre1, nombre2, sexo, estado_civil, correo, estado, municipio, fecha_autorizacion,
                fecha_vigencia FROM bdinteg:si_clientes_nvo_layout_cat WHERE grupo_archivos = 'PPAUTNOUT' ORDER BY fecha_autorizacion
                INTO temp temp_tab with no log;

        INSERT INTO tmp_rep_pp2 SELECT * FROM temp_tab;
                
        -- Obtiene el numero total de registros generados
        SELECT count(*) INTO vTot_Registros FROM tmp_rep_pp2;

        LET cNomArch1 = '';     LET cNomArch  =  '';        LET cNomArchEjecSql = '';
        LET cNomArch1 =  TRIM(cNomArchivo) || '_Aux_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArch  =  TRIM(cNomArchivo) || '_' || vTot_Registros || '_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArchEjecSql = 'Rep_PP_autnoutil.sql';

        LET cSQL = '';
        LET cSQL = ' echo "Tipo Promocion;Tipo Logica;Fecha Insercion;Numero de Credito;Sucursal;Numero de Cliente;Numero Tarjeta;Status Prom;Prioridad;Apellido Paterno;Apellido Materno;Primer Nombre;Segundo Nombre;Sexo;Estado Civil;Email;Estado;Municipio;Fecha autorizacion;Fecha limite para recoger PP;"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
        SYSTEM cSQL;

        LET cSQL1 = '';
        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''';''' ;

        LET cSQL2 = ''; 
        LET cSQL2 = " SELECT * FROM tmp_rep_pp2 order by prioridad ";

        LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL = 'chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
        SYSTEM cSQL;

        LET cSQL = '';
        LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
        SYSTEM cSQL;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
        SYSTEM cSQL;

        -- GENERA ARCHIVO DEL REPORTE CON TELEFONOS DE LOS CLIENTES. REPORTE CON REGISTROS LIMITE.
        LET cNomArch1 = '';     LET cNomArch = '';      LET cNomArchEjecSql = '';
        LET cNomArch1 =  TRIM(cNomArchivo) || '_tel_Aux_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArch  =  TRIM(cNomArchivo) || '_Telefonos_' || TRIM(cNum_dia) || TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
        LET cNomArchEjecSql = 'Rep_PP_telef_autnoutil.sql';

        LET cSQL = '';
        LET cSQL = ' echo "Numero Credito;Numero Cliente;Tipo Telefono;Tipo Red;Telefono Original;Telefono Construido;Carrier;Extension; "> ' || TRIM(cRutaArch) || TRIM(cNomArch);
        SYSTEM cSQL;

        LET cSQL1 = '';
        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''';''' ;

        LET cSQL2 = ''; 
        LET cSQL2 = " SELECT tel.num_credito, tel.numcte, tel.tipotelefono, tel.tipored, tel.telefono_orig, tel.telefono_reconst, "
                    || " tel.carrier, tel.extension FROM bdinteg:si_telefonos_nvo_layout_cat tel, tmp_rep_pp2 rep " 
                    || " WHERE tel.numcte = rep.numcte AND tel.grupo_archivos = 'PPAUTNOUT' " ;

        LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;

        LET cSQL='chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
        SYSTEM cSQL;

        LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
        SYSTEM cSQL;

        LET cSQL = cSQL;
        LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
        SYSTEM cSQL;

        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
        SYSTEM cSQL;
*/
        DROP TABLE tmp_rep_pp1;
		--DROP TABLE tmp_rep_pp2;

    --END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;
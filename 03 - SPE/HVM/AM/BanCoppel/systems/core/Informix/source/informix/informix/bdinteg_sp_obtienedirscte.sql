CREATE PROCEDURE "informix".sp_obtienedirscte(pcliente CHAR(20), pnum_regs SMALLINT)
RETURNING   CHAR(5)   AS CodRet,
            CHAR(2)   AS Secuencia,
            CHAR(50)  AS Calle,
            CHAR(10)  AS NumExtCalle,
            CHAR(10)  AS NumIntCalle,
            CHAR(10)  AS Departamento,
            CHAR(30)  AS Colonia,
            CHAR(60)  AS Ciudad,
            CHAR(30)  AS Estado,
            CHAR(5)   AS CodigoPostal,
            CHAR(40)  AS Observaciones,
            CHAR(100) AS EntreCalles,
            CHAR(13)  AS Telefono1,
            CHAR(13)  AS Telefono2,
            CHAR(13)  AS Telefono3,
            CHAR(10)  AS Extencion,
            CHAR(10)  AS TipoDir,
            CHAR(10)  AS FechasCap;
    
    DEFINE v_codret       CHAR(5);
    DEFINE cSecuencia     CHAR(2);
    DEFINE v_calle		  CHAR(30);
    DEFINE v_numext	      CHAR(10);
    DEFINE v_numint       CHAR(10);
    DEFINE v_depto	      CHAR(6);
    DEFINE v_colonia      CHAR(30);
    DEFINE v_ciudad	      CHAR(60);
    DEFINE v_estado	   	  CHAR(30);
    DEFINE v_obs	   	  CHAR(80);   
    DEFINE v_entrecalles  CHAR(40);   
    DEFINE v_cp	   	      CHAR(5);   
    DEFINE v_tel1   	  CHAR(13);   
    DEFINE v_tel2   	  CHAR(13);   
    DEFINE v_tel3   	  CHAR(13);   
    DEFINE v_ext 	  	  CHAR(10);
    DEFINE v_tpdir 	  	  CHAR(1);
    DEFINE v_tipodir  	  CHAR(10);
    DEFINE v_fechacap  	  CHAR(10);
    DEFINE v_contador     SMALLINT;
    DEFINE sql_err, isam_err  INT;   
    
    -- ****************************************************************************
    -- Inicializar variables
    -- ****************************************************************************
    LET v_codret       = "000";
    LET cSecuencia     = "";
    LET v_calle		   = "";
    LET v_numext	   = "";
    LET v_numint       = "";
    LET v_depto	       = "";
    LET v_colonia      = "";
    LET v_ciudad	   = "";
    LET v_estado	   = "";
    LET v_obs	   	   = ""; 
    LET v_entrecalles  = "";
    LET v_cp	   	   = "";
    LET v_tel1   	   = "";
    LET v_tel2   	   = "";
    LET v_tel3   	   = "";
    LET v_ext 	  	   = "";
    LET v_tpdir 	   = "";
    LET v_tipodir  	   = "";
    LET v_fechacap     = "";
    LET v_contador     = 0;
    
    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;
    
    -- SET DEBUG FILE TO "/home/sysifx/vlv/sp_obtienedirscte.out";
    -- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET sql_err,isam_err
        IF sql_err <> 0 OR isam_err <> 0 THEN
            LET v_codret = sql_err;
            RETURN v_codret, TRIM(cSecuencia), TRIM(v_calle) ,TRIM(v_numext), TRIM(v_numint), TRIM(v_depto),
                   TRIM(v_colonia), TRIM(v_ciudad), TRIM(v_estado), TRIM(v_cp), TRIM(v_obs), TRIM(v_entrecalles),
                   TRIM(v_tel1), TRIM(v_tel2), TRIM(v_tel3), TRIM(v_ext), TRIM(v_tipodir), TRIM(v_fechacap);
        END IF;
    END EXCEPTION;

    -- ****************************************************************************
    -- Valida la informacion de entrada
    -- ****************************************************************************
    IF pcliente IS NULL THEN
        -- Datos de entrada incompletos	   
        LET v_codret = 110; 
        RETURN v_codret, TRIM(cSecuencia), TRIM(v_calle) ,TRIM(v_numext), TRIM(v_numint), TRIM(v_depto),
               TRIM(v_colonia), TRIM(v_ciudad), TRIM(v_estado), TRIM(v_cp), TRIM(v_obs), TRIM(v_entrecalles),
               TRIM(v_tel1), TRIM(v_tel2), TRIM(v_tel3), TRIM(v_ext), TRIM(v_tipodir), TRIM(v_fechacap);
    END IF;

    --Inicializa contador
    LET v_contador      = 0;
    
    -- ****************************************************************************
    -- Obtener registros
    -- ****************************************************************************
    FOREACH
        -- Consulta las direcciones completas del cliente
        SELECT dir.secuencia, cal.nombrecalle AS calle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zon.nombrezona AS colonia,
               NVL(cds.nombre," ") AS cd, edo.nombre AS edo, dir.cod_postal, dir.observaciones,dir.entre_calles, 
               tel1.telefono, tel2.telefono, tel3.telefono ,tel3.extension, 
               DECODE(dir.tipo_dir,'1','Particular','2','Oficina'), dir.fecha_insert
          INTO cSecuencia, v_calle,v_numext,v_numint,v_depto,v_colonia,
               v_ciudad,v_estado,v_cp,v_obs,v_entrecalles,v_tel1,v_tel2,v_tel3,v_ext,v_tipodir,v_fechacap
          FROM bdinteg:"informix".si_direcciones dir
          LEFT OUTER JOIN bdinteg:"informix".si_estados   edo ON (edo.estado=dir.estado)
          LEFT OUTER JOIN bdinteg:"informix".si_ciudades  cds ON (cds.ciudad=dir.ciudad AND cds.estado = dir.estado AND cds.pais = 1)
          LEFT OUTER JOIN bdinteg:"informix".si_catzonas  zon ON (zon.numerociudad=dir.numerociudad AND zon.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:"informix".si_catcalles cal ON (cal.numerocalle=dir.numerocalle)
          LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON (tel1.numcte = dir.numcte AND tel1.tipo_tel = 1)
          LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON (tel2.numcte = dir.numcte AND tel2.tipo_tel = 2)
          LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON (tel3.numcte = dir.numcte AND tel3.tipo_tel = 3)
         WHERE dir.numcte = pcliente
         ORDER BY dir.secuencia
            
        LET v_contador = v_contador + 1;
            
        IF v_contador < pnum_regs THEN
            CONTINUE FOREACH;
        END IF;    
            
        LET cSecuencia = LPAD(TRIM(cSecuencia::CHAR(2)), 2, '0');
        
        RETURN v_codret, TRIM(cSecuencia), TRIM(v_calle) ,TRIM(v_numext), TRIM(v_numint), TRIM(v_depto),
               TRIM(v_colonia), TRIM(v_ciudad), TRIM(v_estado), TRIM(v_cp), TRIM(v_obs), TRIM(v_entrecalles),
               TRIM(v_tel1), TRIM(v_tel2), TRIM(v_tel3), TRIM(v_ext), TRIM(v_tipodir), TRIM(v_fechacap) WITH RESUME;
    END FOREACH		
    
    END;    
    
END PROCEDURE
    
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 13 de Junio del 2011',
'DESCRIPCION: Consulta todas la direcciones del cliente.',
'VERSION: 20110613.1146',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_st_genarchbolparticipantes (psNumEmpleado CHAR(8),pdFechaBusqueda DATE)
RETURNING CHAR(5) AS CodRetorno, CHAR (5) AS Clave_Sorteo, CHAR (100) AS Mensaje; 
 
--DECLARACION
DEFINE vsCodRetorno CHAR (5);
DEFINE vsMensajeRetorno CHAR (100);

DEFINE dtFechaActual DATE;
DEFINE viContSorteos INTEGER;  ------

DEFINE vsRepositorio CHAR (100);
DEFINE vsCve_Sorteo CHAR (5);
DEFINE viGenera_Reporte INTEGER;
DEFINE vsPeriodo_Reporte CHAR (3);
DEFINE vsExento_Empleado CHAR (1);

DEFINE vsNombre CHAR (45);
DEFINE vsDomicilio CHAR (50);


DEFINE vsNumCte CHAR (9);

DEFINE vsFlagGenerarReporte CHAR(1);


DEFINE vsFlagEsEmpleado CHAR (5);
DEFINE vsArchTemporal CHAR (15);
DEFINE vsNomArchivo CHAR (30);
DEFINE vsSQL CHAR (1100);
DEFINE vsSQL1 CHAR (200);
DEFINE vsSQL2 CHAR (700);
DEFINE vsSQL3 CHAR (200);

DEFINE vdfFechaAunxIni DATE;
DEFINE vdfFechaAunxFin DATE;
DEFINE vdfFechaReporte DATE;


DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE visqlerr INTEGER;
--variables a utilizar para cambiar el select de los datos del cliente
DEFINE vsnumerocalle_1	CHAR(4);
DEFINE vsnumerociudad_1	CHAR(2);
DEFINE numerocolonia_1	CHAR(4);
DEFINE vsTelefono CHAR (13);
DEFINE vsnumeroextcalle_1 char(10);
DEFINE vsnombrecalle_1	CHAR(30);
DEFINE vsnombrezona_1 CHAR(32);
DEFINE vsfoliosuc char(16);
DEFINE vstransacc_suc CHAR(4);
DEFINE vsciclo CHAR(1);
DEFINE vssucursal CHAR(4);

LET vsnumerocalle_1 = '';
LET vsnumerociudad_1 = '';
LET numerocolonia_1 = '';
LET vsnumeroextcalle_1 = '';
LET vsnombrecalle_1 = '';
LET vsnombrezona_1 = '';
LET vsfoliosuc = '';
LET vstransacc_suc = '';
LET vsciclo = 'N';
LET vssucursal = '';

--INICIALIZACION

LET vsCodRetorno = '';
LET vsMensajeRetorno = '';
LET dtFechaActual = CURRENT;
LET viContSorteos = 0;

LET vsRepositorio = '';
LET vsCve_Sorteo = '';
LET viGenera_Reporte = 0;
LET vsPeriodo_Reporte = '';
LET vsExento_Empleado = '';

LET vsNombre = '';
LET vsDomicilio = '';
LET vsTelefono = '';

LET vsNumCte = '';

LET vsFlagGenerarReporte = '';


LET vsFlagEsEmpleado = '';
LET vsArchTemporal = '';
LET vsNomArchivo = '';
LET vsSQL = '';
LET vsSQL1 = '';
LET vsSQL2 = '';
LET vsSQL3 = '';

LET vdfFechaAunxIni = CURRENT;
LET vdfFechaAunxFin = CURRENT;
LET vdfFechaReporte = CURRENT;

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

LET visqlerr = 0;

    BEGIN

    ON EXCEPTION SET visqlerr --Control de errores.

        -- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;
        
        LET vsMensajeRetorno = 'ERROR NO CONTROLADO: ' || visqlerr ;
        RETURN visqlerr, '00000', vsMensajeRetorno;
        
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sorteo/SorteoTrace.out";
	--TRACE ON;
	
	LET vsCodRetorno = '00000';
    
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
    
	IF NOT EXISTS (SELECT Ejecutivo FROM BdInteg:Si_Ejecut WHERE Ejecutivo = TRIM(psNumEmpleado)) THEN -- Valida que exista el empleado en al si_ejecut
		LET vsCodRetorno = '00001';
		LET vsMensajeRetorno = 'EMPLEADO NO REGISTRADO EN LA SI_EJECUT';
	ELIF NOT EXISTS (SELECT Fecha_Hoy FROM BdiCheq:Sc_Fechas) THEN -- Valida que exista el parametro de la fecha actual.
		LET vsCodRetorno = '00002';
		LET vsMensajeRetorno = 'NO EXISTE LA FECHA HOY EN LA SC_FECHAS';
	END IF;

	IF (vsCodRetorno = '00000') THEN 

		--SET LOCK MODE TO WAIT 3;
		--SET ISOLATION TO DIRTY READ;
		--SELECT LIMIT 1 Fecha_Hoy INTO dtFechaActual FROM BdiCheq:Sc_Fechas;
		LET vdfFechaReporte = pdFechaBusqueda;
		LET pdFechaBusqueda = pdFechaBusqueda + 1;
		LET dtFechaActual = pdFechaBusqueda;
		LET vdfFechaAunxIni = dtFechaActual;
		LET vdfFechaAunxFin = dtFechaActual;
        
		FOREACH 
			SELECT NVL(Cve_Sorteo, ''), NVL(Genera_Reporte, 0), NVL(Periodo_Reporte, ''), NVL(Exento_Empleado, 'T'), NVL(RutaReporte, '/')
			INTO vsCve_Sorteo, viGenera_Reporte, vsPeriodo_Reporte, vsExento_Empleado, vsRepositorio
			FROM BdInteg:Si_Sorteo 
			WHERE vdfFechaAunxIni BETWEEN NVL(F_Ini, vdfFechaAunxIni) AND NVL(F_Fin, vdfFechaAunxFin)
			
			
			LET vdfFechaAunxIni = dtFechaActual;
			LET vdfFechaAunxFin = dtFechaActual;
		
			LET vsFlagGenerarReporte = 'F';
			
			IF (viGenera_Reporte <> 1 ) THEN --VALIDA SI NO SE GENERA EL REPORTE PARA EL SORTEO
				LET vsFlagGenerarReporte = 'F';
				LET vsCodRetorno = '00003';
				LET vsMensajeRetorno = 'EL SORTENO NO TIENE PROGRAMADO LA GENERACION DE REPORTES';
			ELIF (vsPeriodo_Reporte = '001') THEN --DIARIO
				LET vsFlagGenerarReporte = 'T';
				LET vdfFechaAunxIni = vdfFechaAunxIni -1 UNITS DAY;
				LET vdfFechaAunxFin = vdfFechaAunxFin -1 UNITS DAY;
			ELIF (vsPeriodo_Reporte = '002') THEN --SEMANAL
				IF (WEEKDAY(dtFechaActual) = 1) THEN --VALIDA QUE EL DIA SE LUNES PARA GENERAR EL REPORTE
					LET vsFlagGenerarReporte = 'T';
					LET vdfFechaAunxIni = vdfFechaAunxIni -7 UNITS DAY;
					LET vdfFechaAunxFin = vdfFechaAunxFin -1 UNITS DAY;
				END IF;
			ELIF (vsPeriodo_Reporte = '003') THEN --QUINCENAL
				IF ( (DAY (dtFechaActual) = 1) OR (DAY (dtFechaActual) = 16) ) THEN --ES DIA 1 O 16 PARA GENERAR EL REPORTE
					LET vsFlagGenerarReporte = 'T';
					IF (DAY (dtFechaActual) = 1) THEN --SI ES DIA PRIMERO
					
						LET vdfFechaAunxIni = vdfFechaAunxIni -1 UNITS DAY;
						LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/16/' || YEAR (vdfFechaAunxIni);
						LET vdfFechaAunxFin = vdfFechaAunxFin -1 UNITS DAY;
					ELSE -- SI ES DIA 16
						LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/01/' || YEAR (vdfFechaAunxIni);
						LET vdfFechaAunxFin = vdfFechaAunxFin -1 UNITS DAY;
					END IF;
				END IF;
			ELIF (vsPeriodo_Reporte = '004') THEN --MENSUAL
				IF (DAY (dtFechaActual) = 2)  THEN --ES DIA 2 PARA GENERAR EL REPORTE
					LET vsFlagGenerarReporte = 'T';
					
					LET vdfFechaAunxIni = vdfFechaAunxIni -1 UNITS MONTH;
					
					LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/01/' || YEAR (vdfFechaAunxIni);
					LET vdfFechaAunxFin = vdfFechaAunxFin -2 UNITS DAY;
				END IF;
			ELIF (vsPeriodo_Reporte = '005') THEN --BIMESTRAL
				IF (DAY (dtFechaActual) = 2) AND (MONTH (dtFechaActual) IN (1,3,5,7,9,11) )  THEN --ES DIA 2 PARA GENERAR EL REPORTE Y KE EL MES CORRESPONDA CON LOS BIMESTRES DEL AÑO
					LET vsFlagGenerarReporte = 'T';
					
					LET vdfFechaAunxIni = vdfFechaAunxIni -2 UNITS MONTH;
					
					LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/01/' || YEAR (vdfFechaAunxIni);
					LET vdfFechaAunxFin = vdfFechaAunxFin -2 UNITS DAY;
				END IF;
			ELIF (vsPeriodo_Reporte = '006')THEN --TRIMESTRAL
				IF (DAY (dtFechaActual) = 2) AND (MONTH (dtFechaActual) IN (1,4,7,10) )  THEN --ES DIA 2 PARA GENERAR EL REPORTE Y KE EL MES CORRESPONDA CON LOS TRIMESTRES DEL AÑO
					LET vsFlagGenerarReporte = 'T';
					
					LET vdfFechaAunxIni = vdfFechaAunxIni -3 UNITS MONTH;
					
					LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/01/' || YEAR (vdfFechaAunxIni);
					LET vdfFechaAunxFin = vdfFechaAunxFin -2 UNITS DAY;
				END IF;
			ELIF (vsPeriodo_Reporte = '007') THEN --SEMESTRAL
				IF (DAY (dtFechaActual) = 2) AND (MONTH (dtFechaActual) IN (1,7) )  THEN --ES DIA 2 PARA GENERAR EL REPORTE Y KE EL MES CORRESPONDA CON LOS SEMESTRES DEL AÑO
					LET vsFlagGenerarReporte = 'T';
					
					LET vdfFechaAunxIni = vdfFechaAunxIni -6 UNITS MONTH;
					
					LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/01/' || YEAR (vdfFechaAunxIni);
					LET vdfFechaAunxFin = vdfFechaAunxFin -2 UNITS DAY;
				END IF;
			ELIF (vsPeriodo_Reporte = '008') THEN --ANUAL
				IF (DAY (dtFechaActual) = 2) AND (MONTH (dtFechaActual) = 1 )  THEN --ES DIA 2 PARA GENERAR EL REPORTE Y KE EL MES CORRESPONDA A ENERO DE CADA AÑO.	
					LET vsFlagGenerarReporte = 'T';
					LET vdfFechaAunxIni = vdfFechaAunxIni -1 UNITS YEAR;
					
					LET vdfFechaAunxIni = MONTH (vdfFechaAunxIni) || '/01/' || YEAR (vdfFechaAunxIni);
					LET vdfFechaAunxFin = vdfFechaAunxFin -2 UNITS DAY;
				END IF;
			ELSE 
				LET vsFlagGenerarReporte = 'F';
				LET vsCodRetorno = '00004';
				LET vsMensajeRetorno = 'EL PERIODO DE REPORTE NO CORRESPONDE CON EL ESTANDAR';
			END IF;
			
			IF (vsFlagGenerarReporte = 'T') THEN --VALIDA SI LA GENERACION DEL REPORTE ESTA PROGRAMADA
		
				
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				LET vsCve_Sorteo = '00001';
				
				--traspaso de los registros de boletos al historico de boletos
				INSERT INTO bdinteg:si_boleto_hist (cve_sorteo, boleto, f_registro, numcte, estado, sucursal, area, caja, tipomov, 
														foliosuc, importe, telefono, nombre, domicilio, fecha, origen, secuencia) 
				SELECT cve_sorteo, boleto, f_registro, numcte, estado, sucursal, area, caja, tipomov, 		
							foliosuc, importe, telefono, nombre, domicilio, fecha, origen, secuencia
				FROM BdInteg:Si_Boleto 
				WHERE Cve_Sorteo = vsCve_Sorteo 
				AND boleto > 35000000
	--			AND fecha = CURRENT                              
			 	--AND f_registro  = CURRENT; 
	--			AND NumCte is not null 
	--			AND Estado is not null 
				AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;

				DELETE FROM bdinteg:si_boleto
				WHERE Cve_Sorteo = vsCve_Sorteo                
			        AND boleto > 35000000                              
			-- 	AND f_registro  = CURRENT;                      
			--	AND NumCte is not null 
			--	AND Estado is not null 
				AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin; 
				
				FOREACH WITH HOLD 
					SELECT UNIQUE NumCte 
					INTO vsNumCte 
					FROM bdinteg:si_boleto_hist 
					WHERE Cve_Sorteo = vsCve_Sorteo 
					AND boleto > 35000000        
					AND f_registro  is not null
				--	AND NumCte is not null
					AND Estado <> 101
					AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin 
					
					--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
					IF (vsFlagEnTransaccion = 'F') THEN 
						 BEGIN WORK;
						 LET vsFlagEnTransaccion = 'V';
					END IF;
					
					LET vsFlagEsEmpleado = '00001';
					--REALIZAR LA DISCRIMINACION DE EMPLEADOS COPPEL-  
					EXECUTE PROCEDURE BdInteg:ValidarClienteEmpleado( 1, vsNumCte) INTO vsFlagEsEmpleado ;
					IF vsFlagEsEmpleado < 0 THEN
						LET vsFlagEsEmpleado = '000';
					END IF;
					
					IF (vsFlagEsEmpleado = '000') THEN --VALIDA SI ES EMPLEADO COPPEL-BANCOPPEL
						UPDATE bdinteg:si_boleto_hist 
						SET Estado = 101 
						WHERE Cve_Sorteo = vsCve_Sorteo
						AND boleto > 35000000        
						AND f_registro is not null 
						AND NumCte = vsNumCte 
						AND Estado <> 101 
						AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;
					ELSE --ES CLIENTE VALIDO   -ACTUALIZA LOS DATOS DEL CLIENTE
					
					--Se valida que la trsaccion no este reversada
					
					FOREACH
						SELECT UNIQUE foliosuc,sucursal
						INTO vsfoliosuc,vssucursal
						FROM bdinteg:si_boleto_hist 
						WHERE Cve_Sorteo = vsCve_Sorteo
						AND boleto > 35000000    
						AND f_registro  is not null 
						AND NumCte = vsNumCte
						AND Estado <> 101 
						AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin
						
						
						--Para debito
						IF EXISTS (SELECT empresa,cuenta,fech_alt,cancelad,transacc,folio_suc 
									FROM bdicheq:sc_movdia
									WHERE empresa is not null
									AND cuenta is not null
									AND cancelad = 'S'
									AND fech_alt is not null
									AND transacc is not null
									AND folio_suc  = vsfoliosuc) THEN
								UPDATE bdinteg:si_boleto_hist 
								SET Estado = 101 
								WHERE Cve_Sorteo = vsCve_Sorteo
								AND boleto > 35000000    
								AND f_registro  is not null
								AND foliosuc  = vsfoliosuc
								AND NumCte = vsNumCte 
								AND Estado <> 101 
								AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;
								LET vsciclo = 'S';
						ELSE
							IF EXISTS (SELECT empresa,folio_suc FROM bdicheq:sc_movdia
										WHERE empresa = '001'
										AND folio_suc  = vsfoliosuc 
										AND cancelad = 'S') THEN
								UPDATE bdinteg:si_boleto_hist 
								SET Estado = 101 
								WHERE Cve_Sorteo = vsCve_Sorteo
								AND boleto > 35000000
								AND f_registro  is not null
								AND foliosuc  = vsfoliosuc
								AND NumCte = vsNumCte 
								AND Estado <> 101 
								AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;
								LET vsciclo = 'S';
							END IF;	
						END IF;
						IF vsciclo <> 'S' THEN

							IF EXISTS(select folio_suc from bdicred:sd_movdia
								where folio_suc = vsfoliosuc
								and sucursal = vssucursal 
								and reversado = 'S') THEN
								UPDATE bdinteg:si_boleto_hist 
								SET Estado = 101 
								WHERE Cve_Sorteo = vsCve_Sorteo
								AND boleto > 35000000    
								AND f_registro is not null
								AND foliosuc  = vsfoliosuc
								AND NumCte = vsNumCte 
								AND Estado <> 101 
								AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;
								
							ELSE
								IF EXISTS(select folio_suc,codigo_fun,codigo_ref from bdicred:sd_movdia 
												where folio_suc = vsfoliosuc 
										--		AND codigo_fun is not null
										--		AND codigo_ref is not null
												and reversado = 'S') THEN
									UPDATE bdinteg:si_boleto_hist 
									SET Estado = 101 
									WHERE Cve_Sorteo = vsCve_Sorteo
									AND boleto > 35000000    
									AND f_registro  is not null
									AND foliosuc  = vsfoliosuc
									AND NumCte = vsNumCte 
									AND Estado <> 101 
									AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;
								END IF;
							END IF;	
						END IF;
						LET vsciclo = 'N';
					END FOREACH;


						--se separo la consulta anterior para indexarla
						--Se forma el nombre
						SELECT LIMIT 1 NVL((TRIM(cte.Nombre1) || ' ' || TRIM(cte.Nombre2) || ' ' || TRIM(cte.Apell_Paterno) || ' ' || TRIM(cte.Apell_Materno)), '' )AS Nombre 
						INTO  vsNombre
						FROM bdinteg:si_cliente cte  
						where numcte = vsNumCte;
						
						--se obtiene el teleforno y los datos necesarios para formar la direccion
                        SELECT LIMIT 1 NVL(dir.NumeroCalle,''),
                                        NVL(dir.NumeroCiudad,''),
                                        NVL(dir.NumeroColonia,'') ,
                                        NVL(tel.Telefono,''),
                                        NVL(dir.NumeroExtcalle,'')
                        INTO vsnumerocalle_1,vsnumerociudad_1,numerocolonia_1,vsTelefono,vsnumeroextcalle_1											
                        FROM BdInteg:si_direcciones_actual dir
                        LEFT OUTER JOIN bdinteg:si_telefonos_actual tel ON (tel.numcte = dir.numcte AND tel.tipo_tel = 1)
                        WHERE dir.numcte = vsNumCte
                        AND dir.Tipo_Dir = '1';
						/*
                        AND  dir.Secuencia = (SELECT NVL (MAX(Secuencia),0)
																	FROM BdInteg:si_Direcciones 
																	WHERE NumCte = vsNumCte 
																	AND  Tipo_Dir = '1' 
																	and secuencia is not null 
																	and telefono1 is not null)
                        AND dir.telefono1 is not null;
                        */
						
						LET vsnumerocalle_1 = trim(vsnumerocalle_1);
						LET vsnumerociudad_1 = trim(vsnumerociudad_1);
						LET numerocolonia_1 = trim(numerocolonia_1);
						LET vsTelefono = trim(vsTelefono);
						LET vsnumeroextcalle_1 = trim(vsnumeroextcalle_1);
						
						--se extrae en nombre de la calle
						SELECT {+ INDEX(bdinteg:si_catcalles idx_catcalles) } LIMIT 1 NVL(TRIM(NombreCalle),'') 
						INTO vsnombrecalle_1
						FROM bdinteg:si_catcalles 
						WHERE numerocalle = vsnumerocalle_1;

						--se extrae el nombre de la zona
						SELECT {+ INDEX(bdinteg:si_catzonas idx_catzonass)} LIMIT 1 NVL(TRIM(NombreZona),'')
						INTO vsnombrezona_1
						FROM bdinteg:si_catzonas
						WHERE numerociudad = vsnumerociudad_1
						AND numerocolonia = numerocolonia_1;
						
						--se forma la direccion
						LET vsDomicilio = TRIM(vsnombrezona_1) ||  ' ' || trim(vsnombrecalle_1) || ' ' || trim(vsnumeroextcalle_1);
						
						IF (LENGTH (TRIM (vsTelefono) ) > 10 ) THEN 
							LET vsTelefono = SUBSTRING (TRIM (vsTelefono) FROM 4 FOR 10 );
						END IF;
						
						UPDATE {+ INDEX(bdinteg:si_boleto_hist si_boleto_hist_index1)} bdinteg:si_boleto_hist 
						SET Nombre = vsNombre, Domicilio = vsDomicilio, Telefono = vsTelefono  
						WHERE Cve_Sorteo = vsCve_Sorteo 
						AND boleto > 35000000    
						AND f_registro  is not null
						AND NumCte = vsNumCte 
						AND Estado IS NOT NULL 
						AND Fecha BETWEEN vdfFechaAunxIni AND vdfFechaAunxFin;
					END IF;
					
					--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
					IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
						COMMIT WORK;
						LET vsFlagEnTransaccion = 'F';
						LET viContadorRegistros = 0;
						CONTINUE FOREACH;
					END IF;
					 
				END FOREACH;
				
				-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
				IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
					COMMIT WORK;
					LET vsFlagEnTransaccion = 'F';
				END IF;
			END IF;
			
			--RETURN vsCodRetorno, vsCve_Sorteo, vsMensajeRetorno WITH RESUME;
			
		END FOREACH;
		
	ELSE
    
	END IF;
    
	LET vsMensajeRetorno = 'PROCESAMIENTO DE BOLETOS FINALIZADA CON FECHA  ' || vdfFechaReporte ;
	RETURN vsCodRetorno, vsCve_Sorteo, vsMensajeRetorno;
    END
 
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Descripcion: Generar archivo de boletos asignados para Coppel',
'Fecha: 2009/10/05',
'Version: 20091005.1016',
'BD: BdInteg',

'AUTOR: Hector Juan Casanova Edeza',
'Descripcion: Se modifico el esquema de BD y se renombro la tabla si_admin por si_sorteo',
'Fecha: 2009/10/07',
'Version: 20091007.1226',
'BD: BdInteg',

'AUTOR: Hector Juan Casanova Edeza',
'Descripcion: Se modifico el esquema de BD, se agrego el campo RutaReporte para indicar la ruta de generacion del archivo.',
'Fecha: 2009/10/08',
'Version: 20091008.1100',
'BD: BdInteg',

'AUTOR: Alejandro Osuna',
'Descripcion: Se modifico el Sp para que el campo FolioSuc solo se manden los ultimos 8 caracteres a peticion de Ismael Hernandez.',
'Fecha: 2009/11/04',
'Version: 20091104.1730',
'BD: BdInteg',

'AUTOR: Hector Juan Casanova Edeza',
'Descripcion: Se modifico el nmombre del archivo final del reporte a peticion de Ismael Hernandez.',
'Fecha: 2009/11/04',
'Version: 20091104.1730',
'BD: BdInteg',

'AUTOR: Alejandro Osuna Iza',
'Descripcion: se indexo los Select, update y dalete, se agrego el traspaso de datos de la tabla',
' de si_boleto a la si_boleto_hist, se trabajara con la historica y se borran los datos de la original del reporte a peticion de Ismael Hernandez.',
'Fecha: 2009/11/10',
'Version: 20091110.1922',
'BD: BdInteg',

'AUTOR: Alejandro Osuna Iza',
'Descripcion: se realizo la busqueda de transaccciones reversadas y se puso el estado 101, se partio el sp, quedando la generacion del archivo en otro sp',
'Fecha: 2009/11/11',
'Version: 20091111.1800',
'BD: BdInteg',

'AUTOR: Fabio Torres Esquer',
'Descripcion: se optimiza SPL',
'Fecha: 2009/11/25',
'Version: 20091125.1822',
'BD: BdInteg';

CREATE PROCEDURE "informix".sp_validapass_bei(pEmpresa CHAR(3), pNumCte CHAR(20))
RETURNING CHAR(5),CHAR(50),CHAR(50), CHAR(50),CHAR(50), CHAR(50), CHAR(26), CHAR(13), CHAR(13), DATE, DATE ;
    
    DEFINE cCod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE cUsuario, cPass, cPass1, cPass2, cPass3 CHAR(50);
    DEFINE cNombre CHAR(26);
    DEFINE cTelefono1, cTelefono2 CHAR(13);
    DEFINE dFecha_constitucion, dFecha_actual DATE;
    
    LET cCod_ret       = "000";
    LET cUsuario = "";
    LET cPass = "";
    LET cPass1 = "";
    LET cPass2 = "";
    LET cPass3 = "";
    LET cNombre = "";
    LET cTelefono1 = "";
    LET cTelefono2 = "";
    LET  dFecha_constitucion = '01-01-1900';
    LET  dFecha_actual = CURRENT ;
    
    --Realizó: Manuel Ramos Figueroa
    --Fecha: 05/08/2011
    --Actividad: Obtiene informacion del cliente de BEI
    
    BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret, cUsuario, cPass, cPass1, cPass2, cPass3, cNombre, cTelefono1, cTelefono2,  dFecha_constitucion, dFecha_actual;
        END IF
    END EXCEPTION;
    
    SET LOCK MODE TO WAIT ;
    SET ISOLATION DIRTY READ ;
    
    IF EXISTS ( SELECT num_cliente FROM bdinteg:"informix".si_bpiusuariospm  WHERE empresa = pEmpresa AND num_cliente = pNumCte ) THEN
        SELECT LIMIT 1 usuario, pass, pass1, pass2, pass3 
          INTO cUsuario, cPass, cPass1, cPass2, cPass3 
          FROM bdinteg:"informix".si_bpiusuariospm 
         WHERE empresa = pEmpresa 
           AND num_cliente = pNumCte;
        
        SELECT LIMIT 1 nombre_corto, fecha_constitct 
          INTO cNombre, dFecha_constitucion 
          FROM bdinteg:"informix".si_ctepm
         WHERE empresa = pEmpresa
           AND numcte =  pNumCte;
        /*
        SELECT LIMIT 1 telefono1, telefono2 
          INTO cTelefono1, cTelefono2 
          FROM bdinteg:"informix".si_direcciones_actual 
         WHERE numcte = pNumCte;
        */
        
        SELECT telefono
          INTO cTelefono1
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 1;
           
        SELECT telefono
          INTO cTelefono2
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = 2;
    ELSE
        LET cCod_ret = '001';
    END IF;
    
    RETURN cCod_ret, NVL(cUsuario,''),NVL(cPass,''), NVL(cPass1,''), NVL(cPass2,''), NVL(cPass3,''), 
           cNombre, NVL(cTelefono1,''), NVL(cTelefono2,''),  dFecha_constitucion, dFecha_actual;
    
    END
    
END PROCEDURE;
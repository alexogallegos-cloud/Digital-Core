CREATE PROCEDURE "informix".sp_mc_gen_rep()
RETURNING CHAR (5), CHAR (50), CHAR(500);

/*
#####################################################################################
#   Creado por: Juan Fco. Ponce Damian												#
#   Fecha: 06/02/2013																#
#   Descripcion: Genera la información para el reporte trimestral de visa			#
#####################################################################################
#   modificado por: Juan Fco. Ponce Damian											#
#   Fecha: 22/02/2013																#
#   Modificación: Se modifico la extraccion de la fecha del parametro y se integro  #
#   una validacion para procesar un día anterior a la fecha actual de si_fechas		#
#####################################################################################
#   modificado por: Juan Fco. Ponce Damian											#
#   Fecha: 24/07/2013																#
#   Modificación: Se modifico la lógica del reporte, para que se ejecute el proceso #
#   de fin de trimestre los dias 4 de cada primer mes posterior al cierre del mismo.#
#####################################################################################
#   modificado por: Juan Fco. Ponce Damian											#
#   Fecha: 06/01/2014																#
#   Modificación: Se agrego condición para que cuando sea el ultimo trimestre del   #
#   año, se tenga una rango fijo en el proceso de fin de trimestre.					#
#####################################################################################
#   Modificado por: Adriana del C. Camargo B.                                       #
#   Fecha: 16/02/2015																#
#   Modificación: Se modifica para que se ejecute con el Producto MasterCard        #
#                                                                                   #
#####################################################################################
*/

-- variables de Fecha

DEFINE dFechaHoy		DATE;
DEFINE dFechaHoy2		DATE;
DEFINE imes				INTEGER;
DEFINE imes2			INTEGER;
DEFINE imesant			INTEGER;
DEFINE cTrimestre       CHAR(5);
DEFINE cTrimestre2      CHAR(5);
DEFINE imesdia          CHAR(4);
DEFINE imesdia2         CHAR(4);
DEFINE ifin_mes			CHAR(4);
DEFINE ifin_trimestre	CHAR(4);

DEFINE cFecha1 			CHAR(50);
DEFINE dFecha1			DATETIME year to fraction(5);
DEFINE cFecha2			CHAR(50);
DEFINE dFecha2			DATETIME year to fraction(5);
DEFINE cUltimo_dia		CHAR(2);
-- Variables para manejo de errores

DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(100);
DEFINE cCodret          CHAR(5);

DEFINE cVarDataErr1     CHAR(100);
DEFINE cCodret1         CHAR(5);
DEFINE cCodret2         CHAR(100);
DEFINE cError           CHAR(50);
DEFINE iContErr          INTEGER;

DEFINE cAnio            INTEGER;
DEFINE vNum_ofi         INTEGER;

DEFINE vsFlag CHAR (1);


  ON EXCEPTION SET iSqlErr

		LET cVarDataErr = 'ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
		LET cError='sp_mc_gen_rep';
		LET cCodret = iSqlErr;

        --INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,
		--                                              estatus_actualizacion,dias_pendientes,ultimo_error)
		--VALUES ( 'sp_mc_gen_rep',iMes,dFechaHoy,'', 0 ,cVarDataErr);

		RETURN cCodret, cError, cVarDataErr;

  END EXCEPTION;

--Set debug file to "sp_mc_gen_rep.out";
--trace on;

LET cFecha1 = '';
LET cFecha2 = '';
LET ifin_trimestre='0';
LET iContErr = 0 ;

LET vsFlag = 'V';

LET cCodret = '00000';
LET cVarDataErr = '';
LET cCodret1 = '00000';
LET cCodret2 = '';
LET cVarDataErr1 = '';
LET cError='PROCESO EXITOSO';

SELECT ultima_actualizacion INTO dFechaHoy FROM bdireports:rpt_param_reportevisa WHERE nom_tabla = 'rpt_mc_vol_dia';

SELECT fecha_hoy INTO dFechaHoy2 FROM bdinteg:si_fechas WHERE empresa='001';

WHILE (vsFlag == 'V')

LET imesdia = trim(MONTH(dFechaHoy)||DAY(dFechaHoy));
LET imesdia2 = trim(MONTH(dFechaHoy2)||DAY(dFechaHoy2));
LET imes = MONTH(dFechaHoy);
LET imesant = imes ;
LET imes2 = MONTH(dFechaHoy2);
LET cAnio = YEAR(dFechaHoy);

IF NOT EXISTS (SELECT ultima_actualizacion
                 FROM bdireports:rpt_param_reportevisa
				WHERE nom_tabla = 'rpt_mc_vol_dia'
				  AND ultima_actualizacion < dFechaHoy2 ) THEN
   IF (iContErr > 1) THEN
		LET cVarDataErr1 = 'OCURRIERON '|| iContErr || ' ERRORES INTERNOS EN EL PROCESO ('|| cCodret2||')';
		LET cError = 'sp_mc_gen_rep';
		RETURN cCodret1,cError,cVarDataErr1;
	ELSE
		LET cCodret1='00000';
		LET cError='si_fechas';
		LET cVarDataErr1='Se proceso la ultima fecha trabajada';

		--UPDATE bdireports:rpt_param_reportevisa
		 --  SET estatus_actualizacion = 'V',
		   --    dias_pendientes = 0,
			 --  ultimo_mes = imes,
		       --ultima_actualizacion = dFechaHoy
		--WHERE nom_tabla = 'rpt_mc_vol_dia';

	END IF;
	RETURN cCodret1,cError,cVarDataErr1;
END IF

--obtiene el Trimestre y el ultimo día del mes.
IF 	(imes = 1) THEN
		LET cTrimestre = cAnio || '1';
		LET ifin_mes = '131';
		LET ifin_trimestre='13';
		LET cTrimestre2 = (cAnio-1) || '4';
ELIF(imes = 2) THEN
		LET cTrimestre = cAnio || '1';
		--((year % 4 == 0 and not year % 100 == 0) or year % 400 == 0) ? (true) : (false)
		IF ((( mod(cAnio,4) = 0 ) AND (mod(cAnio,100) <> 0)) OR mod(cAnio,400) =0 ) THEN
			LET ifin_mes = '229'; --año bisiesto
		ELSE
			LET ifin_mes = '228';
		END IF;
ELIF(imes = 3) THEN
		LET cTrimestre = cAnio || '1';
		LET ifin_mes = '331';
ELIF(imes = 4) THEN
		LET cTrimestre = cAnio || '2';
		LET ifin_mes = '430';
		LET ifin_trimestre='43'; -- marca ejecucion del día del primer trimestre
		LET cTrimestre2 = cAnio || '1';
ELIF(imes = 5) THEN
		LET cTrimestre = cAnio || '2';
		LET ifin_mes = '531';
ELIF(imes = 6) THEN
		LET cTrimestre = cAnio || '2';
		LET ifin_mes = '630';
ELIF(imes = 7) THEN
		LET cTrimestre = cAnio || '3';
		LET ifin_mes = '731';
		LET ifin_trimestre='73';		LET cTrimestre2 = cAnio || '2';
ELIF(imes = 8) THEN
		LET cTrimestre = cAnio || '3';
		LET ifin_mes = '831';
ELIF(imes = 9) THEN
		LET cTrimestre = cAnio || '3';
		LET ifin_mes = '930';
ELIF(imes = 10) THEN
		LET cTrimestre = cAnio || '4';
		LET ifin_mes = '1031';
		LET ifin_trimestre='103'; -- marca ejecucion del día del tercer trimestre
		LET cTrimestre2 = cAnio || '3';
ELIF(imes = 11) THEN
		LET cTrimestre = cAnio || '4';
		LET ifin_mes = '1130';
ELIF(imes = 12) THEN
		LET cTrimestre = cAnio || '4';
		LET ifin_mes = '1231';
END IF

IF	( 10 = (SELECT count(nombrearchivo)
              FROM bditarjeta:td_archivos_conciliacion
			 WHERE ((fecha_archivo = dFechaHoy
	 	     --AND archivo_origen IN ('VID','VIC','VND','VNC','TCD','TCC','CCP','CCD') )
               AND archivo_origen IN ('VND','VNC','MCC','MCD', 'TMC', 'TMD') )
			    OR (fecha_archivo = (dFechaHoy-1) AND archivo_origen IN ('TMD','TMC') )) AND proceso = 'T') ) THEN
	--se incrementa el día de trabajo para débito.
	EXECUTE PROCEDURE "informix".sp_mc_cal_dia_D(dFechaHoy,cTrimestre,imes) INTO cCodret,cVarDataErr;
		IF (cCodret = '-1' ) THEN
			LET iContErr = iContErr + 1;
			LET cCodret1='00001';
			LET cCodret2 = cCodret1 || ', ' || cCodret2;
			LET cError = ' FALLO sp_mc_cal_dia_D';
			LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
		END IF
	--se incrementa el día de trabajo para crédito.
	EXECUTE PROCEDURE "informix".sp_mc_cal_dia_C(dFechaHoy,cTrimestre,imes) INTO cCodret,cVarDataErr;
		IF (cCodret = '-1' ) THEN
			LET iContErr = iContErr + 1;
			LET cCodret1='00002';
			LET cCodret2 = cCodret1 || ', ' || cCodret2;
			LET cError = ' FALLO sp_mc_cal_dia_C';
			LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
		END IF

		IF ( imesdia = ifin_mes ) THEN
		-- No es fin de trimestre pero si es fin de mes!!, se hace el acumulado del mes.

			EXECUTE PROCEDURE "informix".sp_mc_cal_men_C(cTrimestre,imes) INTO cCodret,cVarDataErr;
				IF (cCodret = '-1' ) THEN
					LET iContErr = iContErr + 1;
					LET cCodret1='00021';
					LET cCodret2 = cCodret1 || ', ' || cCodret2;
					LET cError = ' FALLO sp_mc_cal_men_C';
					LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
				END IF
			EXECUTE PROCEDURE "informix".sp_mc_cal_men_D(cTrimestre,imes) INTO cCodret,cVarDataErr;
				IF (cCodret = '-1' ) THEN
					LET iContErr = iContErr + 1;
					LET cCodret1='00022';
					LET cCodret2 = cCodret1 || ', ' || cCodret2;
					LET cError = ' FALLO sp_mc_cal_men_D';
					LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
				END IF
		ELIF (imesdia = ifin_trimestre and (0 = (select count(trimestre) from bdireports:rpt_miembroprincipal
			  where trimestre = cTrimestre2))) THEN
		--Se calcula información de fin de trimestre, por ser el día 4 del mes siguiente al cierre del mismo!!.
			IF (substr(cTrimestre2,5,1) = '1' or substr(cTrimestre2,5,1) = '4' ) THEN
				LET cUltimo_dia = '31';
			ELSE
				LET cUltimo_dia = '30';
			END IF;

			IF ( substr(cTrimestre2,5,1) = '4' ) THEN

				LET dFecha1 = (cAnio-1)||'-10-01 00:00:00.0';
				LET dFecha2 = (cAnio-1)||'-12-31 23:59:59.0';
				LET imes= 13 ;
			ELSE

				LET cFecha1 = cAnio || '-' || (imes-3) || '-' || '01' || ' 00:00:00.0';
				LET dFecha1 = CAST (cFecha1 AS DATETIME year to fraction(5));
				LET cFecha2 = cAnio || '-' || (imes-1) || '-' || cUltimo_dia || ' 23:59:59.0';
				LET dFecha2 = CAST (cFecha2 AS DATETIME year to fraction(5));
			END IF

			EXECUTE PROCEDURE "informix".sp_mc_cal_men_C(dFecha1,dFecha2,cTrimestre2,(imes-1)) INTO cCodret,cVarDataErr;
				IF (cCodret = '-1' ) THEN
					LET iContErr = iContErr + 1;
					LET cCodret1='00033';
					LET cCodret2 = cCodret1 || ', ' || cCodret2;
					LET cError = ' FALLO sp_mc_cal_men_C';
					LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
				END IF
			EXECUTE PROCEDURE "informix".sp_mc_cal_men_D(dFecha1,dFecha2,cTrimestre2,(imes-1)) INTO cCodret,cVarDataErr;
				IF (cCodret = '-1' ) THEN
					LET iContErr = iContErr + 1;
					LET cCodret1='00034';
					LET cCodret2 = cCodret1 || ', ' || cCodret2;
					LET cError = ' FALLO sp_generareportevisaelectron';
					LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
				END IF

		-- Obtiene el número de oficinas (sucursales)
			select count(a.sucursal) INTO vNum_ofi
			from bdinteg:si_sucursales a, intercard:sucursal b
			where empresa='001' AND a.sucursal =substr (b.clave_sucursal,2,4)  AND b.enoperacion <> 'F';

			---INSERT INTO bdireports:rpt_miembroprincipal(linea_ident,trimestre,num_identi,cod_pais,num_ofi,num_map,num_sucmap,num_atmplus,num_atmvisa,seg_rrcpcvisaemp,seg_rrcpc,prog_visaprem,
			---					ser_conse,mes1_porcpar,mes2_porcpar,mes3_porcpar,mes1_porcparcom,mes2_porcparcom,mes3_porcparcom)
			--VALUES('MI',cTrimestre2,'10061189','484',vNum_ofi,0,0,0,0,0,0,0,0,100,100,100,0,0,0);
		END IF
	LET imes=imesant;
	LET dFechaHoy = DATE(dFechaHoy) + 1 ;
	--UPDATE bdireports:rpt_param_reportevisa SET ultima_actualizacion = dFechaHoy , ultimo_mes = imes
	--WHERE nom_tabla = 'rpt_mc_vol_dia';
--Ejecución extraordinaria por ser día 4, no tener todos los dias completos pero si el trimestre
ELIF ((imesdia2 = '14' or imesdia2 = '44' or imesdia2 = '74' or imesdia2 = '104') ---and
	 ---(0 = (select count(trimestre) from bdireports:rpt_miembroprincipal where trimestre = cTrimestre2))
	 and  (dFechaHoy > (dFechaHoy2-4) )	) THEN

	IF (substr(cTrimestre2,5,1) = '1' or substr(cTrimestre2,5,1) = '4' ) THEN
		LET cUltimo_dia = '31';
	ELSE
		LET cUltimo_dia = '30';
	END IF;

	IF ( substr(cTrimestre2,5,1) = '4' ) THEN
		LET dFecha1 = (cAnio-1)||'-10-01 00:00:00.0';
		LET dFecha2 = (cAnio-1)||'-12-31 23:59:59.0';
		LET imes2 = 13 ;
	ELSE
		LET cFecha1 = cAnio || '-' || (imes2-3) || '-' || '01' || ' 00:00:00.0';
		LET dFecha1 = CAST (cFecha1 AS DATETIME year to fraction(5));
		LET cFecha2 = cAnio || '-' || (imes2-1) || '-' || cUltimo_dia || ' 23:59:59.0';
		LET dFecha2 = CAST (cFecha2 AS DATETIME year to fraction(5));
	END IF

	EXECUTE PROCEDURE "informix".sp_mc_cal_men_C(dFecha1,dFecha2,cTrimestre2,(imes2-1)) INTO cCodret,cVarDataErr;
		IF (cCodret = '-1' ) THEN
			LET iContErr = iContErr + 1;
			LET cCodret1='00033';
			LET cCodret2 = cCodret1 || ', ' || cCodret2;
			LET cError = ' FALLO sp_mc_cal_men_C';
			LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
		END IF
	EXECUTE PROCEDURE "informix".sp_mc_cal_men_D(dFecha1,dFecha2,cTrimestre2,(imes2-1)) INTO cCodret,cVarDataErr;
		IF (cCodret = '-1' ) THEN
			LET iContErr = iContErr + 1;
			LET cCodret1='00034';
			LET cCodret2 = cCodret1 || ', ' || cCodret2;
			LET cError = ' FALLO sp_mc_cal_men_D';
			LET cVarDataErr1 = cVarDataErr||cVarDataErr1;
		END IF

	-- Obtiene el número de oficinas (sucursales)
	select count(a.sucursal) INTO vNum_ofi
	from bdinteg:si_sucursales a, intercard:sucursal b
	where empresa='001' AND a.sucursal =substr (b.clave_sucursal,2,4)  AND b.enoperacion <> 'F';

	----##INSERT INTO bdireports:rpt_miembroprincipal(linea_ident,trimestre,num_identi,cod_pais,num_ofi,num_map,num_sucmap,num_atmplus,num_atmvisa,seg_rrcpcvisaemp,seg_rrcpc,prog_visaprem,
	--##					ser_conse,mes1_porcpar,mes2_porcpar,mes3_porcpar,mes1_porcparcom,mes2_porcparcom,mes3_porcparcom)
	--##VALUES('MI',cTrimestre2,'10061189','484',vNum_ofi,0,0,0,0,0,0,0,0,100,100,100,0,0,0);

	LET cCodret1='00041';
	LET cError='td_archivos_conciliacion';
	LET cVarDataErr1='EJECUCION EXTRAORDINARIA POR DIA 4to, PERO AUN CON ARCHIVOS PENDIENTES DE CONCILIAR DEL '||dFechaHoy;
	RETURN cCodret1,cError,cVarDataErr1;

ELSE
	LET iContErr = iContErr + 1;
	LET cCodret1='00041';
	LET cCodret2 = cCodret1 || ', ' || cCodret2;
	LET cError='td_archivos_conciliacion';
	LET cVarDataErr1='EL DÍA A PROCESAR FUE '||dFechaHoy||' AUN CON ARCHIVOS PENDIENTES DE CONCILIAR';

	--UPDATE bdireports:rpt_param_reportevisa
	 --  SET estatus_actualizacion = 'P',
	   --    ultimo_error = cVarDataErr1,
	     --  dias_pendientes = (today - dFechaHoy)-1
     --WHERE nom_tabla = 'rpt_mc_vol_dia';

	LET vsFlag = 'F';
END IF;

END WHILE;

IF (iContErr > 1) THEN
	LET cVarDataErr1 = 'OCURRIERON '|| iContErr || ' ERRORES INTERNOS EN EL PROCESO ('|| cCodret2||')';
	LET cError = 'sp_mc_gen_rep';
END IF;

RETURN cCodret1,cError,cVarDataErr1;

END PROCEDURE;
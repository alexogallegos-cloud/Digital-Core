CREATE PROCEDURE "informix".sp_ope_catalogomotivos2(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS codigo,
				  CHAR(35) AS descripcion;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodigo CHAR(2);
	DEFINE cDescripcion CHAR(35);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCodigo = '';
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_catalogomotivos2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultadevcam()
			INTO cCodRetSp, cCodigo, cDescripcion
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultadevcam';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCodigo, cDescripcion;
			ELSE
				RETURN cCodRet, cCodigo, cDescripcion WITH RESUME;
			END IF;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: spl CLON que consulta el catalogo motivos de devoluciÃ³n',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_datosdiahoy_cod47_2(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  DATE AS dFechaHoy,
				  CHAR(3) AS cNoBanco,
				  CHAR(1) AS cProcesado,
				  DATE AS dFechaHabilAnt;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNoBanco CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE iNombrePro INTEGER;
	DEFINE cProcesado CHAR(1);
	DEFINE dFechaHabilAnt DATE;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = '';
	LET dFecha = null;
	LET cNoBanco = '';
	LET cNombreArchivo = '';
	LET iNombrePro = 0;
	LET dFechaHabilAnt = null;
	LET cProcesado = 'f';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_datosdiahoy_cod47_2.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD

		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		--obtiene la fecha Habil del dia.
		SELECT {+INDEX (bdinteg:'informix'.si_fechas idx_si_fechas_fecha_hoy)} fecha_hoy INTO dFecha FROM bdinteg:'informix'.si_fechas;

		--calcula fecha de devolucion habil anterior
		EXECUTE PROCEDURE bditef:'informix'.cal_habil_ant(dFecha)
		INTO cCodRetSp, dFechaHabilAnt;

		IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½?N DEL SP bditef:cal_habil_ant';
		ELIF cCodRetSp::INTEGER = 110 THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		--consulta numero banco propio
		SELECT valor INTO cNoBanco FROM bdinteg:si_param WHERE empresa = '001' and cod_param='5';

		--valida si ya fue procesada una eliminaciÃ³n el dÃ­a de hoy
		LET cNombreArchivo = 'ELI_'||TO_CHAR(DATE(dFecha), '%d%m%Y')||'_MN';
		SELECT COUNT(nombrearchivo)
		INTO iNombrePro
		FROM bditef:cce_encabezado
		WHERE nombrearchivo = cNombreArchivo;

		IF iNombrePro <> 0 THEN
			LET cProcesado= 't';
		END IF;

		RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA:17/03/2016 ',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:SPL CLON Generador de Archivos',
'DESCRIPCION:SPL CLON Obtiene la fecha actual, cadigo de banco propio y validacion de archivo ya procesado.',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_consultaparametrosgenerales2(pUsuario CHAR(8), pIdFuncion CHAR(10), pWhere CHAR(15), pIdParametro CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(100);
	DEFINE cQuery CHAR(500);
	DEFINE sIdFuncion CHAR(10);
	DEFINE sNombreBase CHAR(12);
	DEFINE sNmbreTabla CHAR(40);
	DEFINE sCampo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor = '';
	LET cQuery = '';
	LET sIdFuncion = '';
	LET sNombreBase = '';
	LET sNmbreTabla = '';
	LET sCampo = '';


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparametrosgenerales2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pWhere = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor;
		END IF;

			IF pWhere <> '' THEN
				
				IF pIdParametro = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cValor;
				END IF;
				
				SELECT id_funcion, nombre_base, nombre_tabla, nombre_campo
				INTO  sIdFuncion, sNombreBase, sNmbreTabla, sCampo
				FROM bdicnweb:"informix".sw_parametros_generales 
				WHERE id_funcion = pIdFuncion 
				AND id_parametro = pIdParametro;

				IF NVL(sIdFuncion,'') = '' OR NVL(sNombreBase,'') = '' OR NVL(sNmbreTabla,'') = '' OR NVL(sCampo,'') = '' THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;			
				END IF;
			
				LET cQuery = "SELECT" || " "||TRIM(sCampo) || " " ||"FROM" || " " || TRIM(sNombreBase) || ":" ||"'informix'."||TRIM(sNmbreTabla)|| " " ||
				"WHERE" || " " || TRIM(pWhere) || " " ||"=" || " '" || TRIM(pIdParametro) ||"';";
				
				PREPARE countQry FROM TRIM(cQuery);
				DECLARE countcur CURSOR FOR countQry;
				OPEN countcur;
				FETCH countcur INTO cValor;
				IF (SQLCODE = 100) THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;
				END IF;
				WHILE(SQLCODE = 0)
					RETURN cCodRet, cValor WITH RESUME;
					FETCH countcur INTO cValor;
				END WHILE
				CLOSE countcur;
				FREE countcur;
				FREE countQry;
				
			END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 08/07/2015',
'DESCRIPCION: SPL Clon que realiza la consulta de algun parametro de acuerdo a los datos insertados.',
'Donde: pWhere se refiere al nombre del campo a comparar y pIdParametro al valor del parametro a comparar.',
'FUNCIONALIDAD: Envï¿½o/Recepciï¿½n Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_cam_pro_ctasb3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE)
RETURNING CHAR(5)   AS codret,
          DATE      AS fecha_hoy,
		  DATE      AS fecha_ant,
		  DATE      AS prox_fecha,
          INTEGER   AS total_registros,
          CHAR(1)   AS status,
		  CHAR(1)   AS error_proceso,
		  CHAR(5)   AS error;

  --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
    DEFINE dFechaHoy                DATE;
	DEFINE dFechaAnt                DATE; 
	DEFINE dProxFecha               DATE; 
    DEFINE iTotalRegistros          INTEGER;
    DEFINE cStatus                  CHAR(1);
	DEFINE cErrorProceso            CHAR(1);
	DEFINE cError                   CHAR(5);
 
    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet                     = '00000';
    LET iSqlErr                     = 0;
    LET dFechaHoy                   = '';
	LET dFechaAnt                   = '';
	LET dProxFecha                  = ''; 
    LET iTotalRegistros             = 0;
    LET cStatus                     = '';
	LET cErrorProceso               = '';
	LET cError                      = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
        END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
        END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_pro_ctasb3.out';
		--TRACE ON;
 
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
        IF pBandera = '1' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
			INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
            
        ELIF  pBandera = '2' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_procesacargoscuenta(pUsuario, pIdFuncion, pIdConsulta, pFecha)
            INTO cCodRet,iTotalRegistros;

        ELIF  pBandera = '3' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_verificastatuscargocta(pUsuario, pIdFuncion)
			INTO cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;	
        END IF;


        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
        END IF;

        RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
    END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 07/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAMARA PROCESO MANUAL CARGO DE CUENTA',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 CARGO CUENTA';

CREATE PROCEDURE "informix".sp_cam_conctlprocb3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE,  pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING   CHAR(5)     AS codret,
                CHAR(20)    AS proceso,
			    CHAR(10)    AS status,
			    CHAR(8)     AS ejecutivo,
			    DATETIME HOUR TO SECOND AS hora_ini,
			    DATETIME HOUR TO SECOND AS hora_fin,
			    CHAR(5)     AS codret_sp,
                CHAR(20)    AS cuenta,
    			INTEGER     AS cheque,
                INTEGER     AS num_registros,
                DATE        AS fecha_hoy,
			    DATE        AS fecha_ant,
			    DATE        AS prox_fecha;	



  --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet        CHAR(5);
	DEFINE iSqlErr        INTEGER;
    DEFINE cProceso       CHAR(20);
    DEFINE cStatus        CHAR(10);
	DEFINE cEjecutivo     CHAR(8);
	DEFINE dHoraIni       DATETIME HOUR TO SECOND; 
	DEFINE dHoraFin       DATETIME HOUR TO SECOND;
	DEFINE cCodretSp      CHAR(5);
    DEFINE cCuenta        CHAR(20);
	DEFINE iCheque        INTEGER;
    DEFINE iNumRegistros  INTEGER;
    DEFINE dFechaHoy      DATE;
	DEFINE dFechaAnt      DATE; 
	DEFINE dProxFecha     DATE;  
    


    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet     = '00000';
    LET iSqlErr     = 0;
    LET cProceso    = '';
	LET cEjecutivo  = '';
	LET dHoraIni    = ''; 
	LET dHoraFin    = '';
	LET cCodretSp   = '';
	LET cStatus     = '';
    LET cCuenta     = '';
	LET iCheque     = 0;
    LET iNumRegistros = 0;
    LET dFechaHoy   = '';
	LET dFechaAnt   = '';
	LET dProxFecha  = ''; 

     BEGIN
        ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha;
        END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha;
        END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_conctlprocb3.out';
		--TRACE ON;
 
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF pBandera = '1' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetalleaplicacioncargoscta(pUsuario, pIdFuncion, pFecha)
            INTO cCodRet, cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp;

        ELIF pBandera = '2' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequesprocnocturno(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
                INTO cCodRet, cCuenta, iCheque, cProceso, dHoraIni, cCodretSp
                RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha WITH RESUME;
            END FOREACH

        ELIF pBandera = '3' THEN
            
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequesprocnocturno_totales(pUsuario, pIdFuncion , pFecha)
            INTO cCodRet, iNumRegistros;
            
        ELIF pBandera = '4' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
            INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
        END IF;    

        IF pBandera <> '2' THEN
        RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha;
        END IF;



    END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 07/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAMARAS CARGADO DE CUENTA ',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 CARGADO DE PROCESO NOCTURNO';


CREATE PROCEDURE "informix".auditor(pempresa char(3),w_fecha date)



   define dusuario              char(8);

   define dcontrol_poliza       integer;

   define dfecha_captura        date;

   define dsecuencia            integer;

   define dempresa              char(3);

   define dccmayor              char(10);

   define dccsub                char(10);

   define dccsubsub             char(10);

   define dccssubsub            char(10);

   define dccsssubsub           char(10);

   define dsector               char(10);

   define dciudad               char(3);

   define dsucursal             char(4);

   define dnro_auxiliar         char(12);

   define dnaturaleza           char(1);

   define dmonto                money(18,2);

   define ddescripcion_det      char(30);

   define dfecha_valida         date;

   define dmoneda               char(2);

   define dvalor_cambio         money(12,7);

   define dvalor_div_cambio     money(12,7);

   define dmca_aplic            char(1);

   define dpoliza_usuario       char(8);

   define dtipo_mov             char(1);

   define dccosto_orig          char(4);



   define cod_ret    	        char(3);

   define v_user                char(8);

   define v_sucursal            char(4);

   define v_perfil              smallint;

   define v_userini             char(8);

   define v_userfin             char(8);

   define v_regini              char(3);

   define v_regfin              char(3);

   define v_sucini              char(4);

   define v_sucfin              char(4);

   define v_monto               money(18,2);



   define v_tipo_cuenta         char(1);

   define v_auxiliar            char(1);

   define v_nivel               smallint;

   define v_regional            char(3);

   define v_region              integer;

   define i                     integer;

   define contador              integer;

   define conta                 integer;

   define nreg                  integer;

   define v_origen              char(1);

   define v_moneda              char(2);

   define v_creditos            money(18,2);

   define v_debitos             money(18,2);

   define v_cuenta              char(1);

   define inserta               char(2);

   define v_mc1                 smallint;

   define v_mc2                 smallint;

   define lv_ano                smallint;

   define lv_mes                smallint;

   define lv_dia                smallint;

   define band_existe           smallint;

   define wfecha1               date;

--   set debug file to "/pisa/auditor.out";
--   trace on;

   let dusuario = " ";

   let dcontrol_poliza = 0;

   let dfecha_captura = w_fecha;

   let dsecuencia = 0;

   let dempresa = pempresa;

   let dccmayor = " ";

   let dccsub = " ";

   let dccsubsub = " ";

   let dccssubsub = " ";

   let dccsssubsub = " ";

   let dsector = " ";

   let dnro_auxiliar = " ";

   let dccosto_orig = "";

   let cod_ret = "000";





   select mescierre1,mescierre2

   into   v_mc1,      v_mc2

   from   co_param

   where empresa = pempresa;



   delete from co_auditerr

   where empresa = pempresa;



   {if weekday(w_fecha) = 1 then

      let wfecha1 = w_fecha - 2 units day;

   else

      let wfecha1 = w_fecha;

   end if}



   begin work;

   --set isolation to dirty read;
   --set lock mode to wait;
   
   lock table co_detpol in exclusive mode;


   foreach

      select

         usuario,

         control_poliza,

         moneda,

         sum(monto)

      into

         dusuario,

         dcontrol_poliza,

         dmoneda,

         v_debitos

      from

         co_detpol

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         naturaleza = "D"

      and

         empresa = pempresa

      group by

         usuario,

         control_poliza,

         moneda

      order by

         usuario,

         control_poliza,

         moneda



      select

         sum(monto)

      into

         v_creditos

      from

         co_detpol

      where

         usuario = dusuario

      and

         control_poliza = dcontrol_poliza

      and

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         moneda = dmoneda

      and

         naturaleza = "C"

      and

         empresa = pempresa;



      if (v_creditos is null) then

         let v_creditos = 0;

     end if



      if (v_debitos is null) then

         let v_debitos = 0;

      end if
      if (v_debitos <> v_creditos) then
         let cod_ret = "106";
         insert into
         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

         dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if

   end foreach

   commit work;



   begin work;

      set isolation to dirty read;

      update co_detpol

      set nro_auxiliar = " "

         where (nro_auxiliar = "0" or nro_auxiliar = "000000000"

                or nro_auxiliar = "999999999" or nro_auxiliar = "000000000000"

                or nro_auxiliar = "999999999999") and

                fecha_captura   = w_fecha and

                empresa         = pempresa;

   commit work;



   foreach

      select

         empresa,

         usuario,

         control_poliza,

         fecha_captura,

         moneda

      into

         dempresa,

         dusuario,

         dcontrol_poliza,

         dfecha_captura,

         dmoneda

      from

         co_poliza

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         empresa = pempresa



      select

         count(*)

      into

         i

      from

         co_detpol

      where

         usuario = dusuario

      and

         control_poliza = dcontrol_poliza

      and

         fecha_captura = dfecha_captura

      and

         moneda = dmoneda

      and

         empresa = pempresa;



      if i = 0 or i is null then

         delete from

            co_poliza

         where

            usuario = dusuario

         and

            control_poliza = dcontrol_poliza

         and

            fecha_captura = dfecha_captura

         and

            moneda = dmoneda;

      end if

   end foreach



   begin work;

   set isolation to dirty read;

   foreach

      select

         usuario,

         control_poliza,

         fecha_captura,

         naturaleza,

         moneda,

         sum(monto)

      into

         dusuario,

         dcontrol_poliza,

         dfecha_captura,

         dnaturaleza,

         dmoneda,

         v_monto

      from

         co_detpol

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         empresa = pempresa

      group by

         usuario,

         control_poliza,

         fecha_captura,

         naturaleza,

         moneda



      select

         count(*)

      into

         i

      from

         co_poliza

      where

         usuario = dusuario

      and

         control_poliza = dcontrol_poliza

      and

        fecha_captura = dfecha_captura

      and

        moneda = dmoneda;



      if i = 0 or i is null then

         insert into

            co_poliza

         values

            (pempresa,

             dusuario,

             dcontrol_poliza,

             dfecha_captura,

             v_monto,

             v_monto,

             v_monto,

             dmoneda,

             "Encabezado creado por auditor");

      end if

   end foreach

   commit work;



   let contador = 0;

   let conta = 0;



   begin work;

   set isolation to dirty read;

   select

      count(*)

   into

      conta

   from

      co_detpol

   where

      fecha_captura = w_fecha

      --fecha_captura between wfecha1 and w_fecha

   and

      empresa = pempresa;



   if (conta is null) then

      let conta = 0;

   end if



   let contador = contador + conta;

   select valor_cambio

   into v_moneda

   from co_param

   where empresa = pempresa;



   let nreg = 0;



   foreach

      select

         "D",

         *

      into

         v_origen,

         dusuario,

         dcontrol_poliza,

         dfecha_captura,

         dsecuencia,

         dempresa,

         dccmayor,

         dccsub,

         dccsubsub,

         dccssubsub,

         dccsssubsub,

         dsector,

         dciudad,

         dsucursal,

         dnro_auxiliar,

         dnaturaleza,

         dmonto,

         ddescripcion_det,

         dfecha_valida,

         dmoneda,

         dvalor_cambio,

         dvalor_div_cambio,

         dmca_aplic,

         dpoliza_usuario,

         dtipo_mov,

         dccosto_orig

      from

         co_detpol

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         empresa = pempresa

      LET band_existe = 0;

      {if month(dfecha_captura) != month(dfecha_valida) then

         if (month(dfecha_valida) = v_mc1 or

             month(dfecha_valida) = v_mc2) then

            let lv_ano = year(dfecha_valida);

            let lv_mes = month(dfecha_valida);

            let lv_dia = diasmes(lv_ano,lv_mes);

            if lv_dia != day(dfecha_valida) then

               let cod_ret = "135";

               insert into

               co_auditerr

               values

               (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,

                dccmayor,dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,

                dnro_auxiliar,cod_ret);

            end if

         end if

      end if}



      select

         tipo_cuenta,

         auxiliar

      into

         v_tipo_cuenta,

         v_auxiliar

      from

         bdinteg:si_catalog

      where

         empresa    = dempresa    and

	 ccmayor    = dccmayor    and

	 ccsub      = dccsub      and

	 ccsubsub   = dccsubsub   and

	 ccssubsub  = dccssubsub  and

	 ccsssubsub = dccsssubsub and

	 sector     = dsector;



      if (v_tipo_cuenta is null) then

	 let cod_ret = "100";       {Cuenta contable no existe}

         let band_existe = 1;

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

         dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if

     if band_existe <> 1 then

   	{ Valida que la cuenta no sea de encabezado ni totalizadora }

      if (v_tipo_cuenta = "E" or v_tipo_cuenta = "T") then

         let cod_ret = "101";

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

         dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if



      if (v_auxiliar = "N") then

         if (dnro_auxiliar <> " ") then

            let cod_ret = "118";

            insert into

            co_auditerr

            values

            (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

             dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

         end if

      else

         select

            numero

         into

            v_auxiliar

         from

            co_auxiliar

         where

            empresa = dempresa

         and

            numero = dnro_auxiliar;



         if (v_auxiliar is null) then

            let cod_ret = "102";

            insert into

            co_auditerr

            values

            (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

             dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

         end if

      end if



      select

         sucursal

      into

         v_sucursal

      from

         bdinteg:si_sucursales

      where

         empresa = dempresa

      and sucursal = dsucursal;



      if (v_sucursal is null) then

         let cod_ret = "103";

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

          dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if



      let v_region = 0;

      select count(*)

      into v_region

      from bdinteg:si_regional

      where empresa = dempresa

      and   regional = dciudad;



      if v_region <= 0 then

         let cod_ret = "105";

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

          dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if



      let v_nivel = 0;

      if dccsssubsub > "00" then

         let v_nivel = 4;

      end if

      if dccssubsub > "00" then

         let v_nivel = 3;

      end if

      if dccsubsub > "00" then

         let v_nivel = 2;

      end if

      if dccsub > "00" then

         let v_nivel = 1;

      end if



      for i = 1 to v_nivel

	  if i = 4 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   dccsub     and

                bdinteg:si_catalog.ccsubsub   =   dccsubsub  and

                bdinteg:si_catalog.ccssubsub  =   dccssubsub and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T") then

                   if dccmayor <> "7000" then

                      let cod_ret = "113";

                      insert into

                      co_auditerr

                      values

                      (dusuario,dcontrol_poliza,dfecha_captura,

                      dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                      dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                   end if

                end if

             end if

          end if

          if i = 3 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   dccsub     and

                bdinteg:si_catalog.ccsubsub   =   dccsubsub  and

                bdinteg:si_catalog.ccssubsub  =   "00"       and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T") then

                   if dccmayor <> "7000" then

                      let cod_ret = "113";

                      insert into

                      co_auditerr

                      values

                      (dusuario,dcontrol_poliza,dfecha_captura,

                      dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                      dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                   end if

                end if

             end if

          end if

          if i = 2 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   dccsub     and

                bdinteg:si_catalog.ccsubsub   =   "00"       and

                bdinteg:si_catalog.ccssubsub  =   "00"       and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T") then

                 if dccmayor <> "7000" then

                   let cod_ret = "113";

                   insert into

                   co_auditerr

                   values

                   (dusuario,dcontrol_poliza,dfecha_captura,

                    dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                    dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                  end if

                end if

             end if

          end if

	  if i = 1 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   "00"       and

                bdinteg:si_catalog.ccsubsub   =   "00"       and

                bdinteg:si_catalog.ccssubsub  =   "00"       and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T"

                   and dccmayor[3,4] = "00"

                   and dccmayor[1] <> 5

                   and dccmayor[1] <> 6) then

                   if dccmayor <> "7000" then

                   let cod_ret = "113";

                   insert into

                   co_auditerr

                   values

                   (dusuario,dcontrol_poliza,dfecha_captura,

                    dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                    dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                   end if

                end if

             end if

         end if

      end for

     end if

   end foreach

   commit work;



end procedure;
CREATE PROCEDURE "informix".sp_archivo_respuesta_bc(pEmpresa CHAR(3),pFechaHoyAumlincred DATE)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;           
          
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
--DEFINE iParamRuta        CHAR(3);
DEFINE iParamNombre		 CHAR(3);
DEFINE cSql              CHAR(2024);
DEFINE var_rga           CHAR(05);
DEFINE cRuta			 CHAR(100);
DEFINE cNombre           CHAR(100);
DEFINE p_FechaHoy		 DATE;
DEFINE vFechaIni		 DATE;
DEFINE cNum_cte          CHAR(20);
DEFINE cNumcred          CHAR(20);
DEFINE vproceso	         CHAR(4); 
DEFINE cCodRetC			 CHAR(6);
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "Se realizó la consulta correctamente";
--LET iParamRuta      	 = "021";
LET cRuta				 = "";
LET cNombre			     = "";
LET p_FechaHoy			 = DATE(1);
LET vFechaIni			 = DATE(1);
LET vproceso		     = "4000";
LET cCodRetC			 = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
  	  EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensajeRet,"02") INTO cCodRet;  -- ALEX
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO 'sp_archivo_respuesta_bc.out';
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- upd 17062025
	EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'','',"01") INTO cCodRetC;
-- obtener la ruta donde se almacenara el archivo de respuesta de buro de credito
SELECT valor 
  INTO cRuta
  FROM bdiburo:br_param 
 WHERE cod_param = 14;

IF NVL(cRuta,"") = "" THEN
    LET cCodRet     = '000012';
    LET cMensajeRet  = 'Error al obtener la ruta para extraer el archivo';
	EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensajeRet,"02") INTO cCodRet;  -- ALEX
    RETURN cCodRet, cMensajeRet;
END IF;

  let cSql = 'echo " unload to '''|| '/resplogifx/burodecredito/br_respuesta_bc' || lpad(day(pFechaHoyAumlincred),2,'0') || lpad(month(pFechaHoyAumlincred),2,'0') || year(pFechaHoyAumlincred) ||'.txt'''||" delimiter '|' "||
             ' select * from bdiburo:br_respuesta_bc; ' ||
             ' " > /resplogifx/burodecredito/resp_br_respuesta_bc.sql';
  system cSql;

  let cSql = 'dbaccess bdiburo /resplogifx/burodecredito/resp_br_respuesta_bc.sql';
  system cSql;

  let cSql = "rm /resplogifx/burodecredito/resp_br_respuesta_bc.sql";
  system cSql;

truncate table bdiburo:"informix".br_respuesta_bc;

UPDATE STATISTICS MEDIUM FOR TABLE bdiburo:"informix".br_respuesta_bc;

FOREACH WITH HOLD
   -- modificar esta condicion para hacerlo por mes	
	SELECT nombre_archivo
	  INTO cNombre
	  FROM bdicred:sd_envios_solicitudes
	 WHERE fecha_recepcion IS NULL

	--- BORRAR  LA TABLA DE TEMPORAL DE TRABAJO EN CASO DE QUE EXISTA
	IF EXISTS (SELECT tabname FROM SYSTABLES WHERE tabname = 'busca_archivo') THEN	
		DROP TABLE "informix".busca_archivo;
	END IF

	--- CREAR LA TABLA DE TRABAJO
	CREATE TABLE "informix".busca_archivo
	( archivo CHAR(50));	

	IF EXISTS (SELECT tabname FROM SYSTABLES WHERE tabname = 'sb_regreso_temp') THEN	
		DROP TABLE "informix".sb_regreso_temp;
	END IF

    --Tabla temporal para cargar la información del archivo de respuesta de Burò de Crèdito
    CREATE TABLE "informix".sb_regreso_temp
    ( regreso	CHAR(10100)) in dbs_info07 extent size 198624 next size 60588 ;

	UPDATE STATISTICS MEDIUM FOR TABLE "informix".sb_regreso_temp;

	--- CORRER EL COMANDO LS PARA OBTENER LOS NOMBRES QUE EXISTEN EN LAS CARPETAS Y METERLOS EN EL ARCHIVO buscar.unl
	LET cSql = "";
	LET cSql = 'ls ' || TRIM(cRuta) || ' > ' || TRIM(cRuta) || 'buscar.unl';
	SYSTEM cSql;

	--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
	LET cSql = "";
	LET cSql = 'echo "LOAD FROM ' || TRIM(cRuta) || 'buscar.unl' || ' INSERT INTO busca_archivo" > '|| TRIM(cRuta) || 'Ejecuta_BuscarArchivo.sql';
	SYSTEM cSql;	

	--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
	LET cSql = "";
	LET cSql = 'dbaccess bdiburo ' || TRIM(cRuta) || 'Ejecuta_BuscarArchivo.sql';
	SYSTEM cSql;	

	LET cSql = "";
	LET cSQL = "rm -f " ||TRIM(cRuta)||'Ejecuta_BuscarArchivo.sql';		
	SYSTEM cSql; 
	
	LET cSql = "";
	LET cSQL = "rm -f " ||TRIM(cRuta)||'buscar.unl';		
	SYSTEM cSql; 
			
	IF EXISTS (SELECT archivo FROM "informix".busca_archivo where archivo = TRIM(cNombre)) THEN
			-- para cargar  el archivo insertandolo en la  tabla bdiburo:br_respuesta_bc
			-- delete from bdiburo:br_respuesta_bc;
            EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'','Inicia carga de consulta_bc en sb_regreso_temp',"02") INTO cCodRetC;   

			/*****  upd 17062025  ********/
			LET cSql = '';		
			LET cSql = ' echo "FILE '|| trim(cRuta) || TRIM(cnombre) || ' DELIMITER '''||'|'||''' 1; INSERT INTO sb_regreso_temp; " > '|| trim(cRuta) ||'db_qry_load.sql';
			system cSql;							

			LET cSql = '';	
			LET cSql = 'dbload -d bdiburo -c '|| trim(cRuta) ||'db_qry_load.sql -l '|| trim(cRuta) ||'db_qry_load.log -e 200000 -n 1000 -r';
			system cSql;
			
			LET cSql = '';
			/*****  upd 17062025  ********/
/*  codigo anterior						  
			LET cSql = "";
			LET cSql = 'echo "load from ' || TRIM(cRuta)||TRIM(cNombre)|| ' INSERT INTO sb_regreso_temp " > '|| TRIM(cRuta)||'archivoinsert.sql';
			SYSTEM cSql;	  
			LET cSql = '';
			LET cSql = "dbaccess bdiburo " ||TRIM(cRuta)||'archivoinsert.sql';
		    SYSTEM cSql;
			--falta borrar los temporales
			LET cSql = '';
			LET cSQL = "rm " ||TRIM(cRuta)||'archivoinsert.sql';		
	        SYSTEM cSql; 
*/
			
			EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'','Termina ok carga consulta_bc en sb_regreso_temp',"02") INTO cCodRetC;   
 
			IF (select count(*) from sb_regreso_temp) > 0 THEN
				LET cCodRet = "000000";
				LET cSql    = "";

				--Se carga la informacion del archivo de respuesta de Buro de Credito a la tabla de respuestas
				INSERT INTO bdiburo:br_respuesta_bc
				SELECT 'BC',
				(SELECT numcte FROM bdicred:sd_maecred WHERE empresa='001' AND num_credito=substr(regreso,7,12)),
				CASE WHEN substr(regreso,1,1) = 'I' THEN substr(regreso,7,12) ELSE substr(regreso,9,12) END CASE,
				pFechaHoyAumlincred,substr(regreso,1),cNombre
				FROM sb_regreso_temp;

				--update a sd_envios_solicitudes  
				UPDATE bdicred:sd_envios_solicitudes 
				   SET fecha_recepcion  = today,
					   num_solicitud    = (select count(*) from sb_regreso_temp)
				 WHERE institucion      = institucion
				   AND nombre_archivo   = cNombre;

				DROP TABLE busca_archivo;
				DROP TABLE sb_regreso_temp;

				EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'','Termina ok carga br_respuesta_bc ',"02") INTO cCodRetC;   

			ELSE
				LET cCodRet = "400111";
				LET cSql    = "No existe informacion en tabla sb_regreso_temp, favor de verificar";
				EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'','Error en carga br_respuesta hacia sb_regreso_temp',"02") INTO cCodRet;  
		   END IF;

	ELSE
			DROP TABLE "informix".busca_archivo;
			DROP TABLE "informix".sb_regreso_temp;
--rss Se elimina por si tiene que procesar varios archivos y si alguno no existe, no se pare el proceso
			LET cCodRet     = "000015";
		    LET cMensajeRet = "No se encontro el archivo en la ruta indicada";
			EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'',cMensajeRet,"02") INTO cCodRet;   
			RETURN cCodRet, cMensajeRet;

	END IF	
END FOREACH;

	/*****  upd 17062025  ********/
	LET cSql = '';
	LET cSql = "rm -f "||trim(cRuta)||'db_qry_load.sql ';
	SYSTEM cSql;
	LET cSql = '';
	LET cSql = "rm -f "||trim(cRuta)||'db_qry_load.log ';
	SYSTEM cSql;
	/*****  upd 17062025  ********/
    IF cNombre IS NULL OR cNombre = '' THEN
        LET cCodRet     = "000001";
		LET cMensajeRet = "No se tiene archivo de respuesta a procesar";
        EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensajeRet,"02") INTO cCodRet;  
		RETURN cCodRet, cMensajeRet;
		
	END IF

	EXECUTE PROCEDURE bdicobranza:sp_inserta_bitacora_cob(pEmpresa,vproceso,'','',"03") INTO cCodRetC;
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para  cargar a la tabla',
'bdiburo:br_respuesta_bc la informacion que se recibe de BC',
'el cual se encuentra en la ruta /resplogifx/recepcionburo/',
'ademas de actualizar la tabla sd_envios_solicitudes la fecha',
'de recepción',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 17/JUNIO/2010',
'BD    : BDIBURO';

CREATE PROCEDURE "informix".sp_acivarserviciobpi_apolo(psTipo CHAR(1), psEmpresa CHAR(3), psNumCte CHAR(20), psStatus SMALLINT,
                                               psFolio CHAR(12), psSucursal CHAR(4), psNomEmpleado CHAR(60), psIp CHAR(15), 
                                               pTipoServicio SMALLINT)
RETURNING CHAR(5),CHAR(6);

--Declaracion de variables
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
--DEFINE vsMensaje CHAR(250);
DEFINE vsMensaje CHAR(6);
--DEFINE vdFecha  DATE;
DEFINE vsNumCliente CHAR(9); 
DEFINE cantidad SMALLINT;
DEFINE vsFolioSucEnc CHAR(55);
DEFINE FolioClaro CHAR(13); --INCFOLREP17082022
DEFINE folioAlterno CHAR(12);
DEFINE vsFolioAlternoEnc CHAR(55);
DEFINE i INTEGER;
DEFINE vsCodRetFolioDup CHAR(5);
DEFINE ccodretma CHAR(5);
--Asignacion de variables
LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vsMensaje = '';
--LET vdFecha = '01-01-1900';
LET vsNumCliente = ''; 
LET vsFolioSucEnc = ''; 
LET FolioClaro = ''; --INCFOLREP17082022
LET folioAlterno = '';
LET vsFolioAlternoEnc = '';
LET i = 0;
LET vsCodRetFolioDup = '00000';
LET ccodretma = '';


--SET DEBUG FILE TO "/tmp/sp_acivarserviciobpitest"||TRIM(psNumCte)||".out";
--TRACE ON;


IF NVL(psTipo, '') = '' OR NVL(psEmpresa, '') = '' OR NVL(psNumCte, '') = '' OR  psStatus IS NULL OR NVL(psSucursal, '') = '' OR
   NVL(psNomEmpleado, '') = '' OR  NVL(psIp, '') = ''OR pTipoServicio IS NULL THEN --Valida que  no sean nulo o espacio en blanco
   LET vsCodRet = '00003';
END IF;

--Inicio del procedimiento


BEGIN
	ON EXCEPTION SET viSqlErr --Manejador de Errores
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet,vsMensaje;
        END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
    --AFORE
	IF psNumCte <> '' AND psSucursal <> '' AND psNomEmpleado <> '' THEN
        EXECUTE PROCEDURE bdinteg:"informix".sp_inserta_msjafore(psNumCte,'',psSucursal, substring(psNomEmpleado FROM 1 FOR 8))
        INTO ccodretma;
    END IF;
    --AFORE

    IF vsCodRet = '00000' THEN		
        IF psTipo = '1' THEN
            IF psFolio <>'' AND length(psFolio) = 12 THEN		
                EXECUTE PROCEDURE bdinteg:"informix".sp_valida_folio_dubplicado(psFolio) INTO vsCodRetFolioDup,FolioClaro ,vsFolioSucEnc; -- Encripta folio contrato   
                IF (vsCodRetFolioDup = '00002') THEN--Folio Duplicado
                    LET i = 0; 
                    WHILE i <= 1
                        EXECUTE FUNCTION bdinteg:"informix".sp_genera_folioactivacion_bpi() INTO vsCodRet, folioAlterno;
                        IF (vsCodRet = '00000' )  THEN
                            EXECUTE PROCEDURE bdinteg:"informix".sp_valida_folio_dubplicado(folioAlterno) INTO vsCodRetFolioDup,folioAlterno ,vsFolioAlternoEnc; -- Encripta folio contrato
                            IF (vsCodRetFolioDup = '00000' )THEN
                                LET i = 2;
                                INSERT INTO bdinteg:"informix".si_bpiusuarios(empresa, numcte, id_status, folio_contrato, f_status, suc_registro, num_empleado, fecha_movto, servicio, f_unico_reg)
                                VALUES(psEmpresa, psNumCte, psStatus, vsFolioAlternoEnc, CURRENT, psSucursal, psNomEmpleado, CURRENT, '2', CURRENT);
                                    
                                SELECT count(*), numcte  into cantidad, vsNumCliente FROM bdinteg:"informix".si_bpiusuarios_folioalterno WHERE empresa = psEmpresa AND numcte = psNumCte group by numcte;
                                IF(cantidad>0)THEN
                                    UPDATE bdinteg:"informix".si_bpiusuarios_folioalterno SET folio_contrato_suc = vsFolioSucEnc, folio_contrato_alterno = vsFolioAlternoEnc WHERE empresa = psEmpresa AND numcte = psNumCte;
                                ELSE
                                    INSERT INTO bdinteg:"informix".si_bpiusuarios_folioalterno(empresa, numcte, folio_contrato_suc, folio_contrato_alterno)
                                    VALUES(psEmpresa, psNumCte, vsFolioSucEnc, vsFolioAlternoEnc);
                                END IF;
                            ELSE
                                LET i = 1;
                            END IF;
                        END IF;
                    END WHILE;    
                ELSE                 
                    INSERT INTO bdinteg:"informix".si_bpiusuarios(empresa, numcte, id_status, folio_contrato, f_status, suc_registro, num_empleado, fecha_movto, servicio, f_unico_reg)
                    VALUES(psEmpresa, psNumCte, psStatus, vsFolioSucEnc, CURRENT, psSucursal, psNomEmpleado, CURRENT, '2', CURRENT);                
                END IF;   
            ELSE
                LET vsCodRet = '00002';
            END IF; 
        ELSE
            LET vsCodRet = '00001';
        END IF;
    END IF;

    RETURN vsCodRet,vsMensaje;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se genera copia depurada para flujo clientes nuevos APOLO ONBOARDING ' ,
'AUTOR:Oscar Marquez ',   
'FECHA DE CREACION: 12/06/2025',
'FOLIO: APOLO',
'BD: BDINTEG';

CREATE PROCEDURE "informix".califica_scoring_cjunk_apolo( o_empresa       CHAR(3),
													o_numsol   	 	CHAR(20),
													o_referencia1   CHAR(20),
													o_referencia2   CHAR(20),
													o_ingreso       MONEY(14,2),
													o_tpingreso	  	INTEGER,
													o_periodicidad  INTEGER, 
													o_conyuge       CHAR(20),
													o_nombreref_1   CHAR(104),
													o_nombreref_2   CHAR(104),
													o_parentesco_1  CHAR(2),
													o_parentesco_2  CHAR(2),
													o_telefono_1    CHAR(13),
													o_telefono_2    CHAR(13),
													o_importe_sol   DECIMAL (18,2))

	RETURNING CHAR(5) AS retorno,
			  CHAR(2) AS estatus_sol;
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	-- Autor:  Francisco Javier Peraza.
	-- Descripcion: Se crea copia de procedimiento califica_scoring_cjunk y se adapta para el canal apolo
	-- Fecha: 26-03-2024
	------------------------------------------------------------------------------------											   
	-- *********************************************************************
	-- *                        DEFINICION DE VARIABLES                    *
	-- *********************************************************************
	
	DEFINE scod_ret                	CHAR(5);
	DEFINE p_cod_ret               	CHAR(6);
	DEFINE vsqlerr                 	INTEGER;
	DEFINE v_valor                 	DECIMAL(14,2);
	DEFINE v_valor_1s              	DECIMAL(14,2);
	DEFINE v_valor_2s              	DECIMAL(14,2);
	DEFINE v_valor_im              	DECIMAL(14,2);
	DEFINE v_valor_ex              	DECIMAL(14,2);
	DEFINE v_paso                  	CHAR(1);
	DEFINE v_seccion               	SMALLINT;
	DEFINE v_grupo                 	SMALLINT;
	DEFINE v_tpsol                 	CHAR(1);
	DEFINE v_hoy                   	DATE;
	DEFINE v_cliente               	CHAR(20);
	DEFINE vCompromisos            	DECIMAL(14,2);
	DEFINE vMensaje                	VARCHAR(255);
	DEFINE vedocivil               	CHAR(1);
	DEFINE vTpCiudad               	CHAR(2);
	DEFINE vCiudadCte              	CHAR(3);
	DEFINE vEstadoCte              	CHAR(2);
	DEFINE v_Porcentaje            	DECIMAL(10,7);
	DEFINE v_Antiguedad            	INTEGER;
	DEFINE v_Seccion_Cd            	SMALLINT;
	DEFINE v_Grupo_Cd              	SMALLINT;
	DEFINE v_Elemento_Cd           	SMALLINT;
	DEFINE v_Valor_Cd              	DECIMAL(14,2);
	DEFINE v_SalarioMinimoCoppel   	SMALLINT;
	DEFINE v_Elemento_smc          	SMALLINT;
	DEFINE v_Valor_smc             	DECIMAL(14,2);
	DEFINE v_NumSalariosMinimos    	INTEGER;
	DEFINE v_CiudadCoppelCte       	SMALLINT;
	DEFINE v_ValorCdCoppel         	CHAR(1);
	DEFINE V_Diferencial           	DECIMAL(14,2);
	DEFINE v_FechaAntiguedad       	DATE;
	DEFINE v_anios                 	DECIMAL(14,2);
	DEFINE v_SituacionPagoCoppel   	DECIMAL(5,2);
	DEFINE v_EficienciaCoppel      	SMALLINT;
	DEFINE v_cuantos               	SMALLINT;
	DEFINE v_meses_hist	           	SMALLINT;
	DEFINE v_meses    	           	SMALLINT;
	DEFINE v_meses_hist_inter      	SMALLINT;
	DEFINE orden_consul            	CHAR(1);
	DEFINE status_consul           	CHAR(2);
	DEFINE v_habita_en             	CHAR(2);
	DEFINE v_profesion             	CHAR(3);
	DEFINE v_habitdomi				CHAR(3);
	DEFINE v_mod_parame       		CHAR(1);
	DEFINE v_sucursal         		CHAR(4);
	DEFINE v_VigenciaCC            	SMALLINT;
	DEFINE sNum_producto           	CHAR(4);
	DEFINE cExiste                 	CHAR(20);
	DEFINE cActualiza              	CHAR(1);
	DEFINE cRegreso                	CHAR(4005);
	DEFINE dFecha_Cons             	DATE;
	DEFINE cStatusSol              	CHAR(2);
	DEFINE cEnvio                  	CHAR(1);
	DEFINE cCausa_sol              	CHAR(3);
	DEFINE mRango_max				MONEY(14,2);
	DEFINE iAct						SMALLINT;
	DEFINE iSubAct					SMALLINT;
	DEFINE vRiesgo					SMALLINT;
	DEFINE vRiesgoBco              	SMALLINT;
	DEFINE vRiesgoCop              	SMALLINT;
	DEFINE iSecuencia				SMALLINT;
	DEFINE cSinFamiliar				CHAR(1);
	DEFINE cSucursal 				CHAR(4);
	DEFINE cApellPaterno 			CHAR(26);
	DEFINE cApellMaterno 			CHAR(26);
	DEFINE cNombre1 				CHAR(26);
	DEFINE cNombre2 				CHAR(26);
	DEFINE cRfc 					CHAR(13);
	DEFINE dtFechaNac 				DATE;
	DEFINE cCurp 					CHAR(20);
	DEFINE cSexo 					CHAR(1);
	DEFINE cEstadoCivil 			CHAR(2);
	DEFINE cNacionalidad 			CHAR(3);
	DEFINE cNoFm 					CHAR(18);
	DEFINE cCodigoIden 				CHAR(2);
	DEFINE cNumIdentif 				CHAR(30);
	DEFINE cPersDomicilio 			CHAR(2);
	DEFINE cEmail 					CHAR(60);
	DEFINE cParentesco 				CHAR(2);
	DEFINE cApellCasada 			CHAR(26);
	DEFINE cNumcteRef 				CHAR(20);
	DEFINE cNumCteBanco 			CHAR(20);
	DEFINE cUsuario 				CHAR(8);
	DEFINE dtFecha 					DATE;
	DEFINE cCodret    				CHAR(5);
	DEFINE cCodret2    				CHAR(5);
	DEFINE ptipogrupo 				CHAR(2); 
	DEFINE phit 					CHAR(6);
	DEFINE iSecuencia2   			INTEGER;
	DEFINE iContadorRef   			INTEGER;
	DEFINE iSecuenciaMax  			INTEGER;
	DEFINE iDiasVigencia  			INTEGER;
	DEFINE iEnvio  					INTEGER;
	DEFINE cOrigenSol  				CHAR(1);
	DEFINE cEjecutaScoring2  		CHAR(1);
	DEFINE cNumSolSIC  				CHAR(20);
	DEFINE cConsultaSic  			CHAR(2);
	DEFINE dtFechaSic 				DATE;
	DEFINE cSitEsp 					CHAR (1);
	DEFINE iCausaSitEsp 			SMALLINT;
	DEFINE iBanderaSitEsp 			SMALLINT;
	DEFINE cNomcte  				CHAR(104);
	DEFINE iEdadcte 				SMALLINT;
	DEFINE iBanderaCoppel 			SMALLINT;
	-- Se agrega validacion para filtrar clientes "Z" 
	DEFINE v_puntualidad     		CHAR(02); 
	-- Se agrega validacion para filtrar clientes "Z" FIN 
	--- habita en Correccion Grupo 6 FMJ INI 
	DEFINE vElementohabita_en 		SMALLINT; 
	---habita en Correccion Grupo 6 FMJ FIN 
	DEFINE cTicket				   	CHAR(20); 
	DEFINE cEdo_proceso			   	CHAR(4); 
	DEFINE cNum_men				   	CHAR(3); 
	DEFINE cEmpresa				   	CHAR(4); 
    --APR Rechazo RGC parametrizado
    DEFINE v_rechazo                CHAR(1);
    DEFINE iNumRefs                SMALLINT;
    DEFINE cNumSolicitud           CHAR(20);
    DEFINE cNombreRef           CHAR(104);
	DEFINE cTipoSol				   	CHAR(1);
	DEFINE cTipoMov				   	CHAR(1);
    -- Valida preguntas de parametrico que esten completas en sucursal
    DEFINE sNumGpos, sNumPregSol    SMALLINT;
    DEFINE	vlClienteRef			CHAR(20);
	DEFINE	vlNombre				CHAR(104);	
	DEFINE  vsituacion_especial    CHAR(1);
	DEFINE	vcausa_situacion		SMALLINT;
	DEFINE 	o_vencidomuebles INTEGER;
	DEFINE 	o_vencidoropa    INTEGER;
	DEFINE 	o_vencidoprestamos INTEGER;
	DEFINE 	o_abonomuebles	 INTEGER;
	DEFINE 	o_abonoprestamos INTEGER;
	DEFINE 	o_abonoropa      INTEGER;
	DEFINE 	o_saldomuebles   INTEGER;
	DEFINE 	o_saldoropa      INTEGER;
	DEFINE 	o_saldoprestamos INTEGER;
    DEFINE 	o_ultimacompra   DATE;
	DEFINE	vValidaSPTienda	 CHAR(1);
	DEFINE  cStatus         CHAR(2);
	DEFINE  cStatusSol2         CHAR(2);
	DEFINE  iProdMC          INTEGER;
    DEFINE  iElemento_g3    SMALLINT;
    DEFINE  iElemento_g4    SMALLINT;
	DEFINE institucion_sic      CHAR(2);
	DEFINE entra_cc 			integer;	
	DEFINE vevalua_cc 			CHAR(01);
	DEFINE v_bcs_min,v_bcs_max  INTEGER;
	-- VALIDACION IFE
    DEFINE B_ife            char(01);
    DEFINE B_valida_ife     char(01);
    DEFINE dMontoMin     DECIMAL(14,2);
	DEFINE cTelCel		CHAR(10) ;
	-- validacion de status de cliente grupo coppel
	DEFINE cActivo CHAR(1);
	DEFINE cBandera CHAR(1);
	-- Nuevas variables para bitacora determinacion
    DEFINE dFechaNac     DATE;
	DEFINE cSexoBitDet   CHAR(1);
    DEFINE cEscolaridad  CHAR(2);
    DEFINE cRFC_Cte      CHAR(13);
    DEFINE cDescSitEsp   VARCHAR(50);
    DEFINE sReestructCte SMALLINT;
	DEFINE vfecha_sol	DATE;
	DEFINE vAct_Sub		VARCHAR (50);
	DEFINE dlinea_min_prod      DECIMAL(18,2);
	DEFINE scod_ret_bit  CHAR(5);
	DEFINE vescolaridad_des VARCHAR(50);
	DEFINE Flag_bitacora 	SMALLINT;
    DEFINE cCuentaPP SMALLINT;
	DEFINE cTelefono1               CHAR(13);
	DEFINE cTelefono2               CHAR(13);
	DEFINE cTelefono3               CHAR(13);
	--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
	DEFINE ccausaRT    CHAR(4);
	DEFINE flag_rt_rcb SMALLINT;
    DEFINE cCanal            integer; 
	define cStatusPrev        CHAR(2); 
    define iMotivoOs         integer;
    define iBanderaFaltaOSTEL integer;
    define cTipoMovto         CHAR(1); 
    define iFlagForzarEnvioMC smallint;
    define v_hereda_status    CHAR(2);    
    define VNuevoStatus CHAR(2); 
    DEFINE vMensajeStatus         CHAR(80);
	DEFINE cfamilia  		CHAR(3);
	DEFINE ctipo_nomina		CHAR(1);
	DEFINE es_internet              INTEGER;
	DEFINE wBegin               CHAR (1);
	DEFINE aun_prospecteo       CHAR (1);
	DEFINE fgst_prosp			CHAR(1);
	DEFINE cFlujo_cc CHAR(1);
	DEFINE tipo_acceso_bc CHAR (03);
	DEFINE usu_orden2   CHAR(10);
	DEFINE pass_orden2  CHAR(8);
	DEFINE cCanalSol	CHAR (2);
	DEFINE vfechaServ DATE;
	DEFINE 	o_vencidoaire 		  INTEGER;   						
	DEFINE 	o_abonoaire    		  INTEGER;
	DEFINE 	o_saldoaire 		  INTEGER;
	DEFINE 	o_vencidoafiliados	  INTEGER;
	DEFINE 	o_abonoafiliados 	  INTEGER;
	DEFINE 	o_saldoafiliados      INTEGER;
	DEFINE 	o_vencidoreestructura INTEGER;	
	DEFINE 	o_abonoreestructura   INTEGER;
	DEFINE 	o_saldoreestructura   INTEGER;					
	DEFINE  iScorePuntualidad     INTEGER;							
	DEFINE  cPuntualidadZ		  CHAR(3);					
	DEFINE cCalifica    CHAR(1);	
    DEFINE dCompromisos DECIMAL(14,2);
	DEFINE cCodReRub      CHAR(6);
	DEFINE vMsg_Reasig    VARCHAR(100);
	DEFINE v_Reasig_rubro CHAR (1);
	DEFINE vFechaSolCoppel		CHAR(19);
	DEFINE vFechaSolBanco		CHAR(19);
	DEFINE  sStatCNIncomAux		SMALLINT;
	DEFINE VNumSolRef          CHAR(20);
	DEFINE VNumSolRefMixta     CHAR(20);
	DEFINE VTiempo			   INTEGER;
	DEFINE VTiempoSol          INTEGER;
	DEFINE VfechaSolA		   DATETIME YEAR TO SECOND;
	DEFINE VfechaSolN		   DATETIME YEAR TO SECOND;
	DEFINE VHoraSol            INTEGER;
	DEFINE VHoraSolA           INTEGER;
	DEFINE VNumPrestamo        CHAR(20);
	DEFINE VHoraSolP           INTEGER;
	DEFINE VfechaSolP		   DATETIME YEAR TO SECOND;								
	DEFINE vConsAleat			INTEGER;	
	DEFINE vflagvig 			INTEGER;	
	DEFINE vFalloSIC			INTEGER;	
    DEFINE cStatusTramaPeticionBC   CHAR(1); 
    DEFINE cStatusRespuestaBC   CHAR(3);
	
	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************
    
	--SET DEBUG FILE TO "/pruebas/califica_scoring_cjunk_apolo"||TRIM(o_numsol)||".out";
    --TRACE ON;

	LET scod_ret                = "00000";
	LET p_cod_ret               = "000000";
	LET vsqlerr                 = 0;
	LET v_valor                 = 0;
	LET v_valor_1s              = 0;
	LET v_valor_2s              = 0;
	LET v_valor_im              = 0;
	LET v_valor_ex              = 0;
	LET v_paso                  = "";
	LET v_seccion               = 0;
	LET v_grupo                 = 0;
	LET v_tpsol                 = "";
	LET v_Porcentaje            = 0;
	LET v_Antiguedad            = 0;
	LET v_Seccion_Cd            = 0;
	LET v_Grupo_Cd              = 0;
	LET v_Elemento_Cd           = 0;
	LET v_Valor_Cd              = 0;
	LET v_SalarioMinimoCoppel   = 0;
	LET v_Elemento_smc          = 0;
	LET v_Valor_smc             = 0;
	LET v_NumSalariosMinimos    = 0;
	LET v_CiudadCoppelCte       =0;
	LET v_ValorCdCoppel         = "";
	LET v_Diferencial           =0;
	LET v_anios                 =0;
	LET v_SituacionPagoCoppel   = 0;
	LET v_EficienciaCoppel      = 0;
	LET v_cuantos               = 0;
	LET v_meses_hist            =0;
	LET v_meses                 =0;
	LET v_meses_hist_inter      =0;
	LET orden_consul            ='0';
	LET status_consul           ='00';
	LET v_VigenciaCC            =0;
	LET sNum_producto           = '';
	LET cExiste                 = "";
	LET cActualiza              = "";
	LET vMensaje                = "";
	LET cRegreso                = "";
	LET dFecha_Cons             = DATE(1);
	LET cStatusSol              = "";
	LET cEnvio                  = "0";
	LET v_habita_en             ="";
	LET v_profesion             ="";
	LET v_habitdomi             ="";
	LET v_mod_parame            ="";
	LET v_sucursal              ="";
	LET cCausa_sol              = "";
	LET mRango_max				= 0;
	LET iAct					= 0;
	LET iSubAct					= 0;
	LET vRiesgo					= 0;
	Let vRiesgoBco          	= 0;
	Let vRiesgoCop          	= 0;
	LET iSecuencia				= 0;
	LET cSinFamiliar			= "0";
	LET cSucursal  				= "";
	LET cApellPaterno  			= "";
	LET cApellMaterno  			= "";
	LET cNombre1  				= "";
	LET cNombre2  				= "";
	LET cRfc  					= "";
	LET dtFechaNac 				= DATE(1);
	LET cCurp  					= "";
	LET cSexo  					= "";
	LET cEstadoCivil  			= "";
	LET cNacionalidad  			= "";
	LET cNoFm  					= "";
	LET cCodigoIden  			= "";
	LET cNumIdentif  			= "";
	LET cPersDomicilio  		= "";
	LET cEmail  				= "";
	LET cParentesco  			= "";
	LET cApellCasada  			= "";
	LET cNumcteRef  			= "";
	LET cNumCteBanco 			= "";
	LET cUsuario  				= "";
	LET dtFecha 				= DATE(1);
	LET iSecuencia2 			= 0;
	LET iContadorRef 			= 0;
	LET iSecuenciaMax 			= 0;
	LET iDiasVigencia 			= 7;
	LET iEnvio 					= 0;
	LET cOrigenSol 				= '1';
	LET cEjecutaScoring2 		= '0';
	LET cNumSolSIC 				= '';
	LET cTipoMov = '';
	LET cConsultaSic 			= '';
	LET vElementohabita_en 		= 0; 
	LET dtFechaSic 				= DATE(1);
	LET cCodret 				= "";
	LET cCodret2 				= "";
	LET ptipogrupo 			    = "";
	LET phit					= "";
	LET cSitEsp 				= "" ;
	LET iCausaSitEsp 			= 0;
	LET iBanderaSitEsp 			= 0;
	LET cNomcte    				= "";
	LET cSexo      				= "";
	LET iEdadcte   				= 0;
	LET iBanderaCoppel   		= 0;
	LET v_puntualidad  			= ""; 
	LET cEdo_proceso	   		=""; 
	LET cNum_men		   		=""; 
	LET cEmpresa		   		=""; 
	LET cTicket			   		=""; 
	LET v_cliente		   		=""; 
    LET v_rechazo               ="";
    LET cNumSolicitud	="";
    LET cNombreRef	="";
    LET iNumRefs               =0;
    LET sNumGpos = 0;
    LET sNumPregSol = 0;
    LET vlClienteRef  ='';
	LET vlNombre	='';
	LET o_vencidomuebles =0;
	LET o_vencidoropa    =0;
	LET o_vencidoprestamos =0;
	LET o_abonomuebles	 =0;
	LET o_abonoprestamos =0;
	LET o_abonoropa      =0;
	LET o_saldomuebles   =0;
	LET o_saldoropa      =0;
	LET o_saldoprestamos =0;
    LET o_ultimacompra   = date(1);
	LET vsituacion_especial = '';
	LET	vValidaSPTienda = '';
	LET cStatus ='';
	LET cStatusSol2 ='';
	LET iProdMC			 =0;
    LET iElemento_g3 = 0;
    LET iElemento_g4 = 0;
	LET institucion_sic ='BC';
	LET entra_cc   = 0;
	LET vevalua_cc  = '';
	LET v_bcs_min = 0;
	LET v_bcs_max = 0;
    LET B_ife = '';
    LET B_valida_ife = '';
    LET dMontoMin = 0;
	LET cTelCel		 = '';
	LET cActivo = '';
	LET cBandera = '';
    LET dFechaNac       = date(1);
	LET cSexoBitDet     = "";
    LET cEscolaridad    = '';
    LET cRFC_Cte        = '';
    LET cDescSitEsp     = '';
    LET sReestructCte   = 0;
	LET vcausa_situacion = 0;
	LET vfecha_sol		= date (1);
	LET dlinea_min_prod = 0;
	LET scod_ret_bit    = "0";
	LET vAct_Sub 		= "";
	LET vescolaridad_des = "";
	LET Flag_bitacora   = 0;
    LET cCuentaPP = 0; 
	LET cTelefono1              = "";
	LET cTelefono2				= "";
	LET cTelefono3				= "";
	LET ccausaRT 	= "";
	LET flag_rt_rcb = 0;
    LET cCanal                    = 99;
	let cStatusPrev       =''; 
    let iMotivoOs     =0;
    let iBanderaFaltaOSTEL =0;
    let cTipoMovto=''; 
    let iFlagForzarEnvioMC =0;  
    let v_hereda_status='';
    let VNuevoStatus='';
    LET vMensajeStatus="";
    LET wBegin = "N";
	LET cfamilia = ""; 
	LET ctipo_nomina = "";
	LET es_internet  = 0;
	LET aun_prospecteo = '';
	LET fgst_prosp = '';
	LET cFlujo_cc = '0';
	LET usu_orden2 = '';
	LET pass_orden2 ='';
    LET cCanalSol	='';
	LET o_vencidoaire             =0;
	LET o_abonoaire               =0;
	LET o_saldoaire               =0;
	LET o_vencidoafiliados        =0;
	LET o_abonoafiliados 	      =0;
	LET o_saldoafiliados          =0;
	LET o_vencidoreestructura     =0;
	LET o_abonoreestructura   	  =0;
	LET o_saldoreestructura  	  =0;
	LET iScorePuntualidad   	  =0;
	LET cPuntualidadZ 			  ="";
	LET sStatCNIncomAux				 = 0;
	LET cCalifica    = "";
    LET dCompromisos = 0;
	LET cCodReRub      = "";
	LET vMsg_Reasig    = "";
	LET v_Reasig_rubro = "";								
	LET vFechaSolCoppel		= "";
	LET vFechaSolBanco		= "";
	LET vConsAleat				 = 0;	
	LET vflagvig				 = 0;	
	LET vFalloSIC				 = 0;						  
	LET VNumSolRef         ='';
	LET VNumSolRefMixta    ='';
	LET VTiempo			   =0;
	LET VTiempoSol         =0;
	LET VfechaSolA	   	   = CURRENT;
	LET VfechaSolN		   = CURRENT;
	LET VHoraSol           =0;
	LET VHoraSolA          =0;
    LET VNumPrestamo       ='';
	LET VHoraSolP          =0;
	LET VfechaSolP		   = CURRENT;
    LET cStatusTramaPeticionBC = "";
    LET cStatusRespuestaBC = "";
	
	SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sdfechas)} fecha_hoy INTO v_hoy FROM bdicred:"informix".sd_fechas WHERE empresa = o_empresa;
	
	--RQI 21 246  Originacion de solicitudes 24 x 7 INI
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;

	IF v_hoy < vfechaServ THEN
		LET v_hoy = vfechaServ;
	END IF;
	--RQI 21 246  Originacion de solicitudes 24 x 7 FIN
	
	
	-- ****************************************************************************
	-- *                        CONTROL DE ERRORES                                *
	-- ****************************************************************************
	BEGIN
		ON EXCEPTION SET vsqlerr
		   IF vsqlerr != 0 THEN
			  LET scod_ret=vsqlerr;
			  RETURN scod_ret, cStatusSol2;
		   END IF;
		END EXCEPTION;

   /*ON EXCEPTION IN (-535)
    LET wBegin = "S";
      --ROLLBACK WORK;
      --COMMIT WORK;
      BEGIN WORK;
      COMMIT WORK;
   END EXCEPTION WITH RESUME;*/

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- ****************************************************************************
		-- *                        PROGRAMA PRINCIPAL                                *
		-- ****************************************************************************
 		-- ********************************  

		SELECT VALOR
		INTO VTiempo
		FROM "informix".SS_PARAM 
		WHERE SECUENCIA = '402';

        -- Inserta registro de solicitud para tabla de revision de la cnbv
        IF NOT EXISTS (select num_solicitud from bdisolic:"informix".ss_revision_determinacion where num_solicitud = o_numsol ) THEN			
            INSERT INTO {AVOID_FULL("informix".ss_revision_determinacion)} bdisolic:"informix".ss_revision_determinacion 
			(empresa, num_solicitud) VALUES(o_empresa, o_numsol); -- mahr-cnbv
        END IF;

			
		-- *****************************************************  
		-- VALIDA SI EL SOLICITANTE ES EMPLEADO DE GRUPO COPPEL * 
		-- *****************************************************  
		
		SELECT 
		sol.numcte,sol.tipo_solicitud, sol.num_producto,sol.sucursal,sol.status_solicitud,sol.fecha_insert,canal_sol
		INTO v_cliente,v_tpsol, sNum_producto,v_sucursal,cStatusSol2,vfecha_sol,cCanalSol
		FROM "informix".ss_solicitudes sol 
		WHERE sol.empresa = o_empresa
			AND sol.num_solicitud = o_numsol;
		
		SELECT rechazo_RGC, monto_min_cred, familia, tipo_nomina
		INTO v_rechazo,dlinea_min_prod,cfamilia, ctipo_nomina
		FROM bdicred:"informix".sd_definicion
		WHERE empresa = o_empresa
			AND num_producto = sNum_producto;

		IF cfamilia IN ('001','002','003','004') AND sNum_producto NOT IN('6400','8500','7000','8100','7800') THEN

			IF cfamilia IN ('001','002','003') AND sNum_producto NOT IN('6400','8500','7000','8100','7800') THEN
				LET cTipoSol = 'C';
			ELSE
				LET cTipoSol = 'T';
			END IF;

			/*TRAE LA SOLICITUD ASOCIADA*/
			SELECT num_solicitud , DATE(FECHA_HORA) , CAST(REPLACE(SUBSTR(FECHA_HORA,11,16),':','')AS INTEGER)
				INTO cNumSolicitud , VfechaSolA , VHoraSolA
				FROM "informix".ss_solicitudes
				WHERE empresa = o_empresa
				AND numcte  =v_cliente
				AND tipo_solicitud = cTipoSol
				AND fecha_insert = v_hoy
				AND fecha_hora = (SELECT MAX(fecha_hora)				
							FROM "informix".ss_solicitudes
							WHERE empresa = o_empresa
							AND numcte  =v_cliente
							AND tipo_solicitud = cTipoSol
							AND fecha_insert = v_hoy);
			
		    /*FECHA Y HORA DE LA SOLICITUD QUE SE ESTA EJECUTANDO*/
			SELECT DATE(FECHA_HORA), CAST(REPLACE(SUBSTR(FECHA_HORA,11,16),':','')AS INTEGER)
				INTO VfechaSolN ,  VHoraSol
				FROM BDISOLIC:SS_SOLICITUDES
				WHERE EMPRESA = o_empresa
				AND NUM_SOLICITUD = o_numsol 
				AND NUMCTE = v_cliente;

			IF NVL(cNumSolicitud,'') = '' THEN
			
				LET cNumSolicitud ='';
				LET cTipoMov ='U';
				
			END IF;

			IF  cNumSolicitud IS NOT NULL 
				AND VfechaSolA = VfechaSolN THEN 
				
				LET VTiempoSol = VHoraSol - VHoraSolA;
	
				IF VTiempoSol <= VTiempo THEN 

					LET cTipoMov ='M';
					LET cNumSolicitud  = cNumSolicitud;	
					
					/*Actualiza la Referencia y Tipo para la primer solicitud*/
					UPDATE "informix".ss_resum_scor_fin
					SET tipo_movimiento = cTipoMov,
						num_solicitud_ref  = o_numsol 
					WHERE empresa = o_empresa
					AND num_solicitud = cNumSolicitud;
				ELSE 

					LET cTipoMov ='U';
					LET cNumSolicitud  = '';			
				END IF;
				
			END IF;
			
			UPDATE "informix".ss_resum_scor_fin
			SET ingreso_mensual = o_ingreso,
			tp_ingreso = o_tpingreso,
			periodo_ingreso = o_periodicidad,
			tipo_movimiento = cTipoMov,
			num_solicitud_ref  = cNumSolicitud
			WHERE empresa = o_empresa
			AND num_solicitud = o_numsol;
		
		END IF;
		
		call bdisolic:"informix".sp_obtienegrupo (o_numsol)RETURNING cCodret2,ptipogrupo,phit;

		let cCodRet2 = '000';
		-- ********************************
		-- Actualiza Ingresos del Cliente *
		-- ********************************
			
		UPDATE "informix".ss_resum_scor_fin
		SET ingreso_mensual = o_ingreso,
		  tp_ingreso = o_tpingreso,
		  periodo_ingreso = o_periodicidad,
		  tipo_movimiento = cTipoMov,
		  num_solicitud_ref  = cNumSolicitud 
		WHERE empresa = o_empresa
		AND num_solicitud = o_numsol;

		SELECT nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 1),0),
		  nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 2),0),
		  nvl((select telefono from bdinteg:"informix".si_telefonos_actual where a.numcte = numcte and tipo_tel = 3),0)
		  into cTelefono1,cTelefono2,cTelefono3
		FROM bdinteg:"informix".si_cliente a
		WHERE numcte = v_cliente;

        UPDATE bdisolic:"informix".ss_revision_determinacion SET ingreso_mensual = o_ingreso, numcte = v_cliente, num_producto = sNum_producto,
		 telefono_domicilio = cTelefono1,telefono_celular = cTelefono2, telefono_trabajo = cTelefono3,
		 telefono_ref1 = o_telefono_1, telefono_ref2 = o_telefono_2
         WHERE empresa = o_empresa AND num_solicitud = o_numsol;

		IF NOT o_nombreref_1 IS NULL AND LENGTH(o_nombreref_1) > 0 THEN
			INSERT INTO  "informix".ss_refpersonales
					(empresa, num_solicitud, numcte, numcte_ref, tipo_relacion,
					 nombre_ref, parentesco, telefono_ref)
			VALUES  (o_empresa, o_numsol, v_cliente, o_referencia1, "01",
					o_nombreref_1 , o_parentesco_1, o_telefono_1);
		END IF
		
		IF NOT o_nombreref_2 IS NULL AND LENGTH(o_nombreref_2) > 0 THEN
			INSERT INTO  "informix".ss_refpersonales
					(empresa, num_solicitud, numcte, numcte_ref, tipo_relacion,
						nombre_ref, parentesco, telefono_ref)
			VALUES  (o_empresa, o_numsol, v_cliente, o_referencia2, "01",
						o_nombreref_2 , o_parentesco_2, o_telefono_2);
		END IF

		-- Registro que identificara el numero de cliente asignado al conyuge
		IF NOT o_conyuge IS NULL AND LENGTH(o_conyuge) > 0 THEN
			INSERT INTO  "informix".ss_refpersonales
					(empresa, num_solicitud, numcte, numcte_ref, parentesco)
			VALUES  (o_empresa, o_numsol, v_cliente, o_conyuge, "E");
		END IF

        SELECT situacion_pago,       meses_historia,    origen,      puntualidad ,  
		       situacion_credito,   causa,   vencidoropa, vencidomuebles ,    
			   vencidoprestamos,     abonomensualropa,  abonomensualmuebles,   
			   abonomensualprestamos,saldoropa,         saldomuebles, saldoprestamos, 
			   fecha_ultima_compra, vencidototalaire, abonomensualaire, saldototalaire, vencidototalafiliados,
			   abonomensualafiliados, saldototalafiliados, vencidototalreestructura, abonomensualreestructura, saldototalreestructura, scorepuntualidad
		  INTO v_SituacionPagoCoppel,v_meses,           cOrigenSol,  v_puntualidad ,
		       vsituacion_especial,  vcausa_situacion,  o_vencidoropa,o_vencidomuebles,
			   o_vencidoprestamos ,	 o_abonoropa ,		o_abonomuebles,
			   o_abonoprestamos ,   o_saldoropa ,		o_saldomuebles ,o_saldoprestamos ,
			   o_ultimacompra, o_vencidoaire, o_abonoaire, o_saldoaire, o_vencidoafiliados,
			   o_abonoafiliados, o_saldoafiliados, o_vencidoreestructura, o_abonoreestructura, o_saldoreestructura, iScorePuntualidad
          FROM "informix".ss_resum_scor_fin WHERE empresa=o_empresa AND num_solicitud=o_numsol;
		  
		
        --- Valida que no exista 2 solicitudes en proceso de PP
        SELECT count(*)
        INTO cCuentaPP
		FROM bdisolic:"informix".ss_solicitudes 
		where empresa = o_empresa 
        AND numcte = v_cliente
   	    AND num_producto in (SELECT num_producto FROM bdicred:sd_definicion WHERE familia IN ('002','003') AND num_producto NOT IN ('6400','7800'))
		AND status_solicitud IN ('AT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','PA')
		and num_solicitud <> o_numsol
		AND fecha_insert = today;			 

		--Se contempla condicion por familia descartando los productos que no apliquen
		IF (cCuentaPP >= 1) AND (cfamilia IN ('002','003') AND sNum_producto NOT IN ('6400','7800')) THEN
            LET cCausa_sol = 'PPD';
            LET cStatusSol = 'RT';
            LET vMensaje='Mas de un tramite de prestamo personal por dia';
				
            EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;

            IF p_cod_ret <> '000000' THEN
                LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                RETURN scod_ret, cStatusSol2;
            END If;
            RETURN scod_ret, cStatusSol2;
        END IF;
            
		-- Extrae bandera de validacaion de IFE
		SELECT nvl(valor,'')
		  INTO B_valida_ife
		  FROM "informix".ss_param
	  	 WHERE empresa = o_empresa
		   AND secuencia = 376;

        IF (B_valida_ife = '1') THEN
            SELECT NVL(CASE WHEN UPPER(resultado) = 'VERDADERO' THEN '1' ELSE '0' END,'1')
              INTO B_ife
              FROM bdinteg:"informix".si_bitacora_ife 
             WHERE numcte = v_cliente AND fecha = (SELECT MAX(fecha) FROM bdinteg:si_bitacora_ife WHERE numcte = v_cliente);

            IF ( B_ife <> '1') THEN
                LET cCausa_sol = "RDO";
                LET cStatusSol = 'RT';
                LET vMensaje='Rechazado por estar fuera de politicas';

                EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;

                IF p_cod_ret <> '000000' THEN
                    LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                    RETURN scod_ret, cStatusSol2;
                END If;

                RETURN scod_ret, cStatusSol2;
            END IF;   
        END IF;   

        --- FIN validacion rechazo por IFE

        ----------------------------------------------------------------------------------------------------------
        --- Inicio validacion Tiempo Estado Civil INCORRECTO para Casados, Union Libre y Solteros.

        SELECT NVL(det3.elemento,-1), NVL(det4.elemento,-1) INTO iElemento_g3, iElemento_g4 
          FROM bdisolic:ss_detalle_scoring det3, bdisolic:ss_detalle_scoring det4
         WHERE det3.empresa = o_empresa AND det3.seccion = 2 AND det3.grupo = 3 AND det4.empresa = o_empresa AND det4.seccion = 2 AND det4.grupo = 4 
           AND det3.num_solicitud = det4.num_solicitud AND det3.num_solicitud = o_numsol; 

        -- Valida a SOLTEROS cuyo tiempo edo civil, es diferente a no aplica.
        IF iElemento_g3 = 1 THEN -- AND iElemento_g4 != 76 THEN
            UPDATE bdisolic:ss_detalle_scoring SET elemento = 76 WHERE empresa = o_empresa AND seccion = 2 and num_solicitud = o_numsol and grupo = 4;
            UPDATE bdisolic:ss_detalle_scoring SET elemento = 12 WHERE empresa = o_empresa AND seccion = 2 and num_solicitud = o_numsol and grupo = 41;

        -- Valida a CASADOS o UNION LIBRE, su valor en tiempo edo civil, sea diferente a NO APLICA ==> SE CANCELA solicitud
        ELIF iElemento_g3 in (6,7) AND iElemento_g4 = 76 THEN
            LET cCausa_sol = 'CTI';
            LET cStatusSol = 'CN';
            LET vMensaje='Cancelacion por Tiempo Edo Civil incorrecto en parametrico';

            EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje ) INTO p_cod_ret;

            IF p_cod_ret <> '000000' THEN
                LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
                RETURN scod_ret, cStatusSol2;
            END If;
            RETURN scod_ret, cStatusSol2;
        END IF;

        ----------------------------------------------------------------------------------------------------------
		-- ********************************
		-- Inserta Referencias Personales *
		-- ********************************		
		SELECT num_parametrico
		INTO v_mod_parame
		FROM "informix".ss_control_parametricos
		WHERE empresa = o_empresa
			AND num_producto = sNum_producto
			AND sucursal = v_sucursal;

		IF v_mod_parame IS NULL THEN
			LET scod_ret= '00136'; -- no se tiene dato de que modelo aplicar para calificar el dato
			RETURN scod_ret, cStatusSol2;
		END IF;

		UPDATE "informix".ss_solicitudes
		SET tipo_calculo=v_mod_parame,
		   monto_solicitado = o_importe_sol
		WHERE empresa = o_empresa
			AND num_solicitud = o_numsol;
			
		-- ********************************
		--   Actualiza Datos del Cliente  *
		-- ********************************

		SELECT MAX(NVL((CASE WHEN a.grupo=7 THEN elementobase END),"")),
			   MAX(NVL((CASE WHEN a.grupo=22 THEN elementobase END),""))
		INTO v_profesion,v_habitdomi
		FROM "informix".ss_detalle_scoring a,
			 "informix".ss_scoring_element b
		WHERE a.empresa=b.empresa
			AND a.empresa=o_empresa
			AND a.num_solicitud=o_numsol
			AND a.grupo=b.grupo
			AND a.elemento=b.elemento
			AND activa=1
			AND a.grupo IN (7,22);

		IF v_habitdomi IS NOT NULL OR v_habitdomi<>"" THEN
			UPDATE bdinteg:"informix".si_cliente
			SET string2=v_habitdomi
			WHERE numcte=v_cliente;
		END IF;
		
		SELECT estado_civil,TRIM(habita_en),TRIM(profesion), DECODE ( TRIM(habita_en), 'P' ,5,'R',8,'F',7,'H',9,'G',6,'D',10), NVL(sexo,"I"), fecha_nac, escolaridad
		INTO vedocivil,v_habita_en,v_profesion, vElementohabita_en,cSexo, dFechaNac, cEscolaridad
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = o_empresa
			AND numcte = v_cliente;
					
		SELECT descripcion 	INTO vescolaridad_des FROM bdinteg:si_escolaridad_am WHERE elemento = cEscolaridad;	
		LET cSexoBitDet = cSexo;
		UPDATE "informix".ss_detalle_scoring
		SET elemento = vElementohabita_en
		WHERE empresa =  o_empresa
			AND seccion = 2
			AND grupo =5
			AND num_solicitud = o_numsol;					

		-- **************************************************************************
		-- Incorpora Grupo 20 (Ingresos de Cliente) de acuerdo a dato del cliente   *
		-- **************************************************************************
		
		-- Extrae Valor de Parametro
		SELECT valor
		INTO v_SalarioMinimoCoppel
		FROM "informix".ss_param
		WHERE empresa = o_empresa
			AND secuencia = 303;

		IF v_SalarioMinimoCoppel IS NULL THEN
			LET v_SalarioMinimoCoppel= 0;
		END IF;
		-- Se calcula el numero de Salarios Minimos Coppel que el cliente percibe.
		IF v_SalarioMinimoCoppel >= 0 Then
			LET v_NumSalariosMinimos= ROUND((o_ingreso / v_SalarioMinimoCoppel),2);
		ELSE
			LET v_NumSalariosMinimos= 0;
		END IF;
		-- Actualiza el numero de salarios minimos que corresponden al ingreso mensual del cliente
		UPDATE "informix".ss_resum_scor_fin
		SET smbc = v_NumSalariosMinimos
		WHERE empresa = o_empresa
			AND num_solicitud = o_numsol;

		SELECT {+INDEX("informix".ss_scoring_element idx_ss_scoring_element)} MAX(rango_maximo)
		INTO mRango_max
		FROM "informix".ss_scoring_element
		WHERE empresa = o_empresa
			AND grupo = 20
			AND seccion = 2
			AND tpo_persona = '01';

		IF v_NumSalariosMinimos > mRango_max THEN
			LET v_NumSalariosMinimos = mRango_max;
		END IF;
		
		--se agrega validacion para identificar si el cliente presenta una ocupacion de riesgo. que se validara posteriormente
		SELECT claveopcionpuesto,clavesubopcionpuesto,sec_ingreso
		INTO iAct,iSubAct,iSecuencia
		FROM bdinteg:"informix".si_ingresos a
		WHERE a.numcte = v_cliente
			AND a.tipo_ingreso='T'
			AND a.sec_ingreso= (SELECT MAX (sec_ingreso)
								FROM bdinteg:"informix".si_ingresos b
								WHERE b.numcte=a.numcte
									AND b.tipo_ingreso='T');
									
		--se actualiza la maxima secuencia del cliente en la tabla si_ingresos.
		UPDATE bdinteg:"informix".si_ingresos
		SET ingreso_mensual = o_ingreso
		WHERE empresa = o_empresa
			AND numcte = v_cliente
			AND tipo_ingreso='T'
			AND sec_ingreso= iSecuencia;


		SELECT descrip INTO  vAct_Sub FROM bdinteg:"informix".si_actsubact	WHERE id_act= iAct AND   id_subact= iSubAct;

		UPDATE bdisolic:"informix".ss_revision_determinacion 
		   SET saldoropa = o_saldoropa, saldomuebles = o_saldomuebles, saldoprestamo = o_saldoprestamos, vencidoropa = o_vencidoropa,
			   vencidomuebles = o_vencidomuebles, vencidoprestamos = o_vencidoprestamos, abonomensualropa = o_abonoropa, 
			   abonomensualmuebles = o_abonomuebles, abonomensualprestamos = o_abonoprestamos,  fecha_nacimiento = dFechaNac, profesion = v_profesion,
			   sexo = cSexoBitDet, escolaridad = cEscolaridad, edo_civil = vedocivil, rfc = cRFC_Cte,actividad = iAct, subactividad = iSubAct, actividad_descrip = vAct_Sub,
			   vencidototalaire = o_vencidoaire, abonomensualaire = o_abonoaire, saldototalaire = o_saldoaire, vencidototalafiliados = o_vencidoafiliados, abonomensualafiliados = o_abonoafiliados,
			   saldototalafiliados = o_saldoafiliados, vencidototalreestructura = o_vencidoreestructura, abonomensualreestructura = o_abonoreestructura, saldototalreestructura = o_saldoreestructura, scorepuntualidad = iScorePuntualidad
		WHERE empresa = o_empresa AND num_solicitud = o_numsol;

		--	se validan las actividad del cliente que se obtuvo previamente
		SELECT altoriesgocred,altoriesgocredcp,situacion_especial,causa_situacion 
		  INTO vRiesgoBco,vRiesgoCop,cSitEsp,iCausaSitEsp 
		  FROM bdinteg:"informix".si_actsubact
		 WHERE id_act= iAct
		   AND   id_subact= iSubAct;
		
		IF vRiesgo IS NULL THEN
			LET vRiesgo = 0;
		END IF;
		
		IF vRiesgoBco IS NULL THEN
			LET vRiesgoBco = 0;
		END IF;
		
		IF vRiesgoCop IS NULL THEN
			LET vRiesgoCop = 0;
		END IF;

		IF (v_tpsol = 'C' AND vRiesgoCop = 1) OR (v_tpsol <> 'C' AND vRiesgoBco = 1) THEN
			LET vRiesgo = 1;
		END IF;
		
		IF NVL(cSitEsp,"") <> "" AND  v_tpsol = "C" THEN
			IF iBanderaSitEsp = 0 THEN
				UPDATE "informix".ss_resum_scor_fin
				SET situacion_especial = cSitEsp,
					causa_situacion = iCausaSitEsp
				WHERE empresa = o_empresa
					AND num_solicitud = o_numsol;
					LET iBanderaSitEsp =1;
			END IF;
		END IF;	
					  			
		IF sNum_producto <>'6500' THEN	 					
            IF v_habita_en = 'H' THEN
                LET cCausa_sol = "REV";
                LET vMensaje = 'Rechazado por estar fuera de politicas';
            END IF;        
		
            IF (v_habita_en = 'H' OR v_habita_en = 'D') AND v_tpsol = "C" THEN --situacion_especial P causa 28
                    IF iBanderaSitEsp = 0 THEN
                        UPDATE "informix".ss_resum_scor_fin
                        SET situacion_especial = "P",
                            causa_situacion = 28
                        WHERE empresa = o_empresa
                            AND num_solicitud = o_numsol;
                            LET iBanderaSitEsp =1;
                    END IF;
            END IF;
        ELIF (v_habita_en = 'D') AND v_tpsol = "C" THEN --situacion_especial P causa 28
			IF iBanderaSitEsp = 0 THEN
				UPDATE "informix".ss_resum_scor_fin
				SET situacion_especial = "P",
					causa_situacion = 28
				WHERE empresa = o_empresa
					AND num_solicitud = o_numsol;
					LET iBanderaSitEsp =1;
			END IF;
        END IF;
		
		-- Se toma el parametro PUNTUALIDAD PARA RECHAZAR CON EFP (EFICIENCIA FUERA DE POLITICAS
	   SELECT valor
	   INTO cPuntualidadZ
	   FROM bdisolic:"informix".ss_param
	   WHERE secuencia= 46;
   
		-- Se agrega validacion para filtrar clientes "Z" INI 
		--	Se sustituye causa RDO por subcausas para reflejarse en el arbol de solicitudes RQM 04 469
		IF (v_puntualidad = cPuntualidadZ) THEN 
		   LET cCausa_sol = "EFP"; 
		   LET vMensaje='Eficiencia Fuera de Politicas'; 	
		ELIF v_profesion='6' THEN
		   LET cCausa_sol = "PDE";
		   LET vMensaje='Profesion desempleado';
		ELIF vRiesgo = 1 THEN
		   LET cCausa_sol = "ADR";
		   LET vMensaje='Actividad de Riesgo';
		ELIF v_cuantos IS NULL OR v_cuantos = 0 AND v_mod_parame ='1' AND v_tpsol <> "C" THEN --se quita rechazo para producto coppel
		   LET cCausa_sol = "RS2";
		   LET vMensaje='Puntos acumulados en Scoring fueron insuficientes para su Aprobacion';
		ELIF vValidaSPTienda = 'F' THEN --se quita rechazo para producto coppel
		   LET cCausa_sol = "ACC";
		   LET vMensaje='Atraso en Cuenta Coppel';   
		END IF;
		
		IF ((v_cuantos IS NULL OR v_cuantos = 0) AND v_mod_parame ='1') OR v_habita_en='H' OR v_profesion='6' OR vRiesgo =1 OR cSinFamiliar = "1" 
			  OR v_puntualidad = "Z" OR vValidaSPTienda = 'F' THEN 
			  
			LET cStatusSol = 'RT';

			EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
				(o_empresa, 'SISTEMA',o_numsol, cStatusSol,cCausa_sol, vMensaje )
			INTO p_cod_ret;

			-- Obtiene datos para almacenar en la bitacora de la solicitud
			SELECT {+INDEX (bdicred:"informix".sd_causas_cte_coppel)}
			s.situacion_especial, s.causa_situacion, c.descripcion
			INTO vsituacion_especial,  vcausa_situacion, cDescSitEsp
			FROM bdisolic:"informix".ss_resum_scor_fin s, bdicred:sd_causas_cte_coppel c
			WHERE s.empresa = c.empresa and s.situacion_especial = c.situacion and s.causa_situacion = c.causa
			AND s.empresa = o_empresa AND s.num_solicitud = o_numsol;

			-- Obtiene le numero de reestructuras que ha tenido el cliente
			SELECT nvl(count(a.numcte),0) INTO sReestructCte FROM bdicred:sd_maecredcrd a, bdicred:sd_maecredanexocrd b WHERE a.empresa = b.empresa 
			AND a.num_credito = b.num_credito AND a.num_producto = '6011' AND a.numcte = v_cliente AND a.status_cred = 'FF' AND b.fecha_proceso <= v_hoy;

			EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, v_cliente)
			INTO cCodRet, cNomcte, iEdadcte;

			UPDATE bdisolic:"informix".ss_revision_determinacion SET edad = iEdadcte, escolaridad_descrip = vescolaridad_des,situacion_especial = vsituacion_especial, causa_sit_esp = vcausa_situacion, 
			descripcion_siesp = cDescSitEsp, num_reest_cte = sReestructCte, fecha_sol = vfecha_sol, linea_min_prod = dlinea_min_prod
			WHERE empresa = o_empresa AND num_solicitud = o_numsol;
			IF p_cod_ret <> '000000' then
				LET scod_ret= '00004'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
				RETURN scod_ret, cStatusSol2;
			END If;

			UPDATE "informix".ss_autorizacion
			SET revision_cac = 3
			WHERE empresa = o_empresa
				AND num_solicitud = o_numsol
				AND status_solicitud = 'RT'
				AND fecha_entrada = DATE(CURRENT);

			RETURN scod_ret, cStatusSol2;
		END IF;																 
		
		--Sacar el valor de la vigencia
		SELECT valor INTO iDiasVigencia FROM "informix".ss_param WHERE empresa = o_empresa AND secuencia = 362;
		--Validar si existe una solicitud previa que aun estÃ© vigente
		SELECT num_solicitud_sic,institucion
			INTO cNumSolSIC, status_consul
			FROM "informix".ss_solicitudes_sic
			WHERE ROWID = (SELECT MAX(rowid)
						   FROM "informix".ss_solicitudes_sic
						   WHERE numcte= v_cliente
							AND fecha_sic >= v_hoy - iDiasVigencia
							AND fecha_sic IS NOT NULL);
			
		IF cNumSolSIC IS NULL THEN  --Valida que no hay sol vigente, por lo que asigna la SIC en base al Aleatorio
			--Consulta si tiene solicitud base
			SELECT num_solicitud_sic, institucion
			INTO cNumSolSIC, cConsultaSic
				FROM "informix".ss_solicitudes_sic
				WHERE ROWID = (SELECT MAX(rowid)
						FROM "informix".ss_solicitudes_sic
						WHERE numcte= v_cliente
							AND  fecha_sic IS NULL
							AND fecha_insert >= v_hoy - iDiasVigencia);
			
			IF cNumSolSIC IS NULL THEN --Valida que no tiene solicitud base, por lo que asigna la SIC en base al Aleatorio
				
				--Obtener el numero aleatorio
				EXECUTE PROCEDURE "informix".sp_random_sics(100,cCanalSol) INTO scod_ret,vConsAleat,status_consul;
				IF scod_ret <> '00000' THEN
						RETURN scod_ret, cStatusSol2; -- ocurrio un error al ejecutar el  procedimiento sp_random_sics
				END IF;

				--Seleccionar la instituciÃ³n en base al numero aleatorio
				SELECT institucion INTO status_consul  FROM "informix".ss_sic_dinamicas 
				WHERE vConsAleat BETWEEN min_inst AND max_inst
				AND canal_solic = cCanalSol;
			ELSE
				LET status_consul = cConsultaSic;
				LET cConsultaSic = '';
				LET cNumSolSIC = '';
			END IF;
		END IF;
									   
		IF status_consul = 'CC' THEN
			LET cflujo_cc = '1';
		END IF;

		LET vMensaje= 'En consulta '|| status_consul ;
		
		--Se agrega consulta para la obtencion de los productos validos para heredar la informacion de referencias de la solicitud contemplando los nuevos productos de prestamo(7600,7700)
		
		IF sNum_producto IN ('6001', '6300','6500','7600','7700','6800','7100') THEN
		--se valida que no existan referencias para el numero de solicitud coppel
			SELECT COUNT (num_solicitud)
			INTO iNumRefs
			FROM bdinteg:"informix".si_refclientes a
			WHERE a.empresa = '001'
			AND a.numcte = v_cliente
			AND num_solicitud = o_numsol ;
			
			IF iNumRefs < 2 THEN 
				 IF iNumRefs = 1 THEN
					LET iContadorRef = iContadorRef+1;
				 END IF;
			
				EXECUTE PROCEDURE "informix".sp_obtienesolicitudherencia
				(o_empresa ,o_numsol,v_cliente)
				INTO cCodret, cNumSolicitud;					
			
				--Se obtiene la ultima referencia del cliente, en caso de que tramite banco y coppel , la ultima referencia es de banco
				FOREACH	WITH HOLD
					SELECT sucursal,apell_paterno,apell_materno,nombre1,
						nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,
						pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert, fecha_insert
					INTO cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,
						dtFechaNac,cCurp,cSexo,cEstadoCivil,cNacionalidad,cNoFm,cCodigoIden,cNumIdentif ,cPersDomicilio,
						cEmail ,cParentesco,cApellCasada,cNumcteRef ,cNumCteBanco,cUsuario ,dtFecha
					FROM bdinteg:"informix".si_refclientes a
					WHERE a.empresa = '001'
					AND a.numcte = v_cliente	
					AND num_solicitud = cNumSolicitud
					ORDER BY secuencia ASC
					
					LET iContadorRef = iContadorRef+1;
					
					IF iContadorRef > 2 THEN
						EXIT FOREACH;
					END IF;
					
					EXECUTE PROCEDURE bdinteg:"informix".sp_refclientes_cjunk
						(o_empresa,"A",o_numsol,v_cliente,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,
						dtFechaNac,cCurp,cSexo,cEstadoCivil,cNacionalidad,cNoFm,cCodigoIden,cNumIdentif ,cPersDomicilio,
						cEmail ,cParentesco,cApellCasada,cNumcteRef ,cNumCteBanco,cUsuario ,dtFecha,0 )
					INTO cCodret,iSecuencia2;

					LET cSucursal  		= "";
					LET cApellPaterno  	= "";
					LET cApellMaterno  	= "";
					LET cNombre1  		= "";
					LET cNombre2  		= "";
					LET cRfc  			= "";	
					LET dtFechaNac 		= DATE(1);
					LET cCurp  			= "";
					LET cSexo  			= "";
					LET cEstadoCivil  	= "";
					LET cNacionalidad  	= "";
					LET cNoFm  			= "";
					LET cCodigoIden  	= "";
					LET cNumIdentif  	= "";
					LET cPersDomicilio  = "";
					LET cEmail  		= "";
					LET cParentesco  	= "";
					LET cApellCasada  	= "";
					LET cNumcteRef  	= "";
					LET cNumCteBanco 	= "";
					LET cUsuario  		= "";
					LET dtFecha 		= DATE(1);

				END FOREACH;
			END IF;
		END IF;

		EXECUTE PROCEDURE "informix".sp_actualiza_status_sol
		(o_empresa, 'sistema',o_numsol, status_consul,cCausa_sol, vMensaje )
		INTO scod_ret;
		
		--obtiene la edad del cliente --para validar si se consulta a las SICs
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(o_empresa, v_cliente)
		INTO cCodRet, cNomcte, iEdadcte;

		IF  NVL(iEdadcte,0) < 18 THEN
			LET iBanderaCoppel = 1;
		END IF;

		IF iBanderaCoppel = 0 AND sNum_producto <> "7800" THEN --JMAH Solicitudes de Anticipo  no pasan a Buro:
			
			------obtencion del parametro de dias de vigencia de consultas SIC --JMAH
			SELECT valor
			INTO iDiasVigencia
			FROM "informix".ss_param
			WHERE empresa = o_empresa
				AND secuencia = 362;

			IF NVL(iDiasVigencia,0) = 0 THEN
				LET iDiasVigencia = 0; ---para minimo cumplir lo que viene en el RQM
			END IF;
			
			-- Consulta a las SICs.
			IF cflujo_cc = '1' THEN 
				LET institucion_sic = status_consul;
			ELSE
				SELECT status_solicitud
				INTO institucion_sic
				FROM bdisolic:"informix".ss_status_sol 
				WHERE empresa = o_empresa 
				AND tipo_auto = '1';
			END IF;
			
			-- RECHAZO POR CREDITO BLOQUEADO RCB --se extrae el nuevo campo causa_rt, para validar los rechazos			
			IF cCanalSol = '9' THEN

				SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
				INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT
				FROM "informix".ss_solicitudes_sic
				WHERE ROWID = (SELECT MAX(rowid)
							   FROM "informix".ss_solicitudes_sic
							   WHERE numcte= v_cliente
								AND fecha_sic >= v_hoy 
								AND fecha_sic IS NOT NULL	
								AND institucion = status_consul);

			ELSE 
			
				SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
				INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT
				FROM "informix".ss_solicitudes_sic
				WHERE ROWID = (SELECT MAX(rowid)
							   FROM "informix".ss_solicitudes_sic
							   WHERE numcte= v_cliente
								AND fecha_sic >= v_hoy - iDiasVigencia
								AND fecha_sic IS NOT NULL
								AND institucion = status_consul);
				
			END IF;		

			IF cNumSolSIC IS NULL THEN 
					SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
						INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT
					FROM "informix".ss_solicitudes_sic
					WHERE ROWID = (SELECT MAX(rowid)
					FROM "informix".ss_solicitudes_sic
					WHERE numcte= v_cliente
					AND  fecha_sic IS NULL
					AND institucion = status_consul);
			ELSE
				Let vflagvig = 1;
			END IF;

			--IPCB 15jul15-- Para grupo 3 y 5 se determina si fueron a FICO
			--IPCB Octubre2015 RQM 09 384-3 FICO SCORE--Incluir grupos 1,A,2, Hit. Para determinar si fueron a FICO --Se incluyen en el cgrupo
			IF ptipogrupo in ('1','2','3','5','A','8') AND v_tpsol IN ( 'T','P') AND cNumSolSIC is not null AND cflujo_cc = '0' THEN 
				
				SELECT count(*) INTO entra_cc
				  FROM bdisolic:ss_autorizacion
				 WHERE empresa = o_empresa
				   AND num_solicitud = cNumSolSIC
				   AND status_solicitud = 'CC';
				 
				IF ( entra_cc > 0 ) THEN
					LET entra_cc = 2;
				ELSE
					SELECT nvl(evalua_cc,'') INTO vevalua_cc
					FROM bdisolic:ss_resum_scor_fin
					WHERE empresa = o_empresa
					AND num_solicitud = cNumSolSIC;		
				
					IF ( vevalua_cc = '0' ) THEN--IPCB   FICO SCORE
						SELECT NVL(sc01::INTEGER,0)
						INTO v_valor_1s
						FROM bdiburo:"informix".br_sc a
						WHERE a.rowid = (SELECT MAX(b.rowid) FROM bdiburo:"informix".br_sc b WHERE institucion = 'BC' AND b.num_cliente= v_cliente AND sc00 <> "004" )
						AND institucion = 'BC'
						AND num_cliente = v_cliente
						AND sc00 <> "004";   							
					
						SELECT unique NVL(bc_scoremin,0), NVL(bc_scoremax,0)
						  INTO v_bcs_min,v_bcs_max
						  FROM bdisolic:ss_scoring_modelo2
						 WHERE tp_solicitud IN ( 'T','P')
						   AND tp_solicitud = v_tpsol
						   AND grupo = ptipogrupo
						   AND num_producto =sNum_producto
						   AND grupo in ('1','2','3','5','A','8')
						   AND fc_score_max > 0
						   AND status_sol = 'RT';									
					   
						IF ( v_valor_1s >= v_bcs_min and v_valor_1s <= v_bcs_max ) THEN
							LET entra_cc = 1;
						END IF;
					END IF;
				END IF;
			END IF;		
					
			IF ( cNumSolSIC IS NULL ) THEN
			
				-- RECHAZO POR CREDITO BLOQUEADO RCB
				IF cNumSolSIC IS NOT NULL AND ccausaRT = 'CCB' THEN
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'CN', 'CCB', 'CANCELADO POR CREDITO BLOQUEADO') INTO p_cod_ret;
					
					UPDATE "informix".ss_solicitudes_sic SET causa_rt =ccausaRT 
					WHERE numcte = v_cliente AND num_Solicitud_sic = cNumSolSIC AND num_Solicitud = o_numsol;
					
					IF p_cod_ret <> '000000' THEN
						LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
						LET Flag_bitacora = 1;
					ELSE 
						LET flag_rt_rcb =1;
					END IF;		
				END IF;
			ELSE
				IF dtFechaSic IS NULL THEN
					IF fgst_prosp <> 'F' AND cCanalSol <> 4 THEN	 --IPCB 04sep20, no inserta para 0 - 6500
						INSERT INTO "informix".ss_solicitudes_sic
							(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic,consul_aleatoria,flagvig,FalloSIC)
						VALUES(o_empresa,v_cliente,o_numsol,cNumSolSIC,cConsultaSic,v_hoy,NULL,vConsAleat,vflagvig,vFalloSIC);
					END IF;
				ELSE				
					IF ccausaRT = 'CCB' THEN
						EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa, 'sistema',o_numsol, 'CN', 'CCB', 'CANCELADO POR CREDITO BLOQUEADO') INTO p_cod_ret;
						IF p_cod_ret <> '000000' THEN
							LET scod_ret= '00003'; -- ocurrio un error al ejecutar el  procedimiento sp_actualiza_status_sol
							LET Flag_bitacora = 1;
						ELSE 
							LET flag_rt_rcb =1;	
						END IF;		 
					END IF;

					IF  Flag_bitacora <> 1  THEN	
						IF ( cOrigenSol = '1')  THEN
							IF cCanalSol = 9 THEN
								-------------------------------------------------------------------------------------------------------------
								-----------------------Enviar solicitudes banco a consulta coppel    ----------------------------------------
								-------------------------------------------------------------------------------------------------------------

								EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk2(o_empresa, v_cliente,o_numsol)
								INTO p_cod_ret, cCalifica, dCompromisos, vMensaje;

								------------------------------REEVALUACION-------------------------------------------------------------
								IF cCalifica = 'X' THEN

								  -- Realiza la reevaluacion del modelo si es No Hit y cumple con las condiciones de variables BC_# se cambia Hit
									EXECUTE PROCEDURE bdisolic:"informix".sp_reevalua_rubro_sols(o_empresa, o_numsol, vMensaje) INTO cCodReRub, vMsg_Reasig, v_Reasig_rubro;
					
									IF v_Reasig_rubro = '1' THEN    -- Si se realiza cambio de rubro se cambian datos
										LET cCalifica = '0';
										LET vMensaje = vMsg_Reasig;
									END IF;

									LET cCalifica = cCalifica;
									  
								END IF;

								-----------------------------FIN REEVALUACION-------------------------------------------------------------									
								IF dtFechaSic IS NOT NULL THEN	
									 IF cCalifica = '0'  THEN
									 
									  --SI ES SOLICITUD BANCO CON BUEN COMPORTAMIENTO ENTONCES ACTUALIZA EL ESTATUS A EC
									   EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (o_empresa,'sistema',o_numsol,'EC','','Solicitud enviada a Evaluacion Coppel')
									   INTO p_cod_ret;

									   --SI LA SOLICITUD NO ES MIXTA Y ES BANCO SE ACTUALIZA EL PARAMETRICO 1 PARA QUE SE LA LLEVE EL DEMONIO
									   UPDATE bdisolic: "informix".ss_solicitudes SET envio_parametrico = '1' WHERE num_solicitud = o_numsol AND empresa = o_empresa AND envio_parametrico IS NULL;                     
	
									 END IF;	
								END IF ;								
								-------------------------------------------------------------------------------------------------------------
								--------------------------------Fin del envio solicitudes banco a consulta coppel----------------------------
								-------------------------------------------------------------------------------------------------------------	
							END IF;
						END IF;
					END IF;
					LET scod_ret = '00000';
				END IF;
			END IF;
		END IF;
		
		-- Obtiene datos para almacenar en la bitacora de la solicitud
		SELECT {+INDEX (bdicred:"informix".sd_causas_cte_coppel)}
		s.situacion_especial, s.causa_situacion, c.descripcion
		  INTO vsituacion_especial,  vcausa_situacion, cDescSitEsp
		  FROM bdisolic:"informix".ss_resum_scor_fin s, bdicred:sd_causas_cte_coppel c
		 WHERE s.empresa = c.empresa and s.situacion_especial = c.situacion and s.causa_situacion = c.causa
		   AND s.empresa = o_empresa AND s.num_solicitud = o_numsol;

		-- Obtiene le numero de reestructuras que ha tenido el cliente
		UPDATE bdisolic:"informix".ss_revision_determinacion SET edad = iEdadcte, escolaridad_descrip = vescolaridad_des,situacion_especial = vsituacion_especial, causa_sit_esp = vcausa_situacion, 
			   descripcion_siesp = cDescSitEsp, num_reest_cte = sReestructCte, fecha_sol = vfecha_sol, linea_min_prod = dlinea_min_prod
		 WHERE empresa = o_empresa AND num_solicitud = o_numsol;
	END
	
	
	LET cStatusSol2 = "";
	
	SELECT 
	sol.status_solicitud
	INTO cStatusSol2
	FROM "informix".ss_solicitudes sol 
	WHERE sol.empresa = o_empresa
	AND sol.num_solicitud = o_numsol;

    SELECT status INTO cStatusTramaPeticionBC
    FROM BDIBURO:"informix".br_traslado
    WHERE num_solicitud = o_numsol;

    IF NVL(cStatusTramaPeticionBC,"") = "4" THEN
        LET cStatusSol2 =  "RT";
    END IF;

    SELECT SUBSTR(regreso,0,3) INTO cStatusRespuestaBC
    FROM BDIBURO:"informix".br_respuesta 
    WHERE num_solicitud = o_numsol
    AND secuencia = 1;

    IF NVL(cStatusRespuestaBC,"") = "" OR NVL(cStatusRespuestaBC,"") = "ERR" THEN
        LET cStatusSol2 =  "RT";
    END IF;


	/*COMMIT WORK;
	IF wbegin = 'N' THEN
	    BEGIN WORK;
	END IF;*/
	
	RETURN scod_ret, cStatusSol2;
END PROCEDURE
DOCUMENT
'----------------------------------------------------------------------------',
'Modifico    : Francisco Javier Peraza Rangel',
'Fecha       : 26/03/2024',
'BD          : Bdisolic',
'DESCRIPCION : Se crea copia de procedimiento califica_scoring_cjunk y se adapta para el canal apolo ',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".graba_sol_precalificada(v_empresa   CHAR(3),
				         v_numsol    CHAR(20),
				         v_numcte    CHAR(20),
     				         v_sucursal  CHAR(4),
     				         v_tpsol     CHAR(1),
     				         v_producto  CHAR(4),
     				         v_ejecutivo CHAR(8),
							 v_subProducto CHAR(4))


RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE v_hoy	    DATE;
--APR 20180605
DEFINE ncliente_pros	CHAR(1);
DEFINE sStatus_numctepros CHAR(2);
--FJPR
DEFINE csucursal   CHAR(4);
-- RQI 21 246  OriginaciÃ³n de solicitudes 24 x 7  
DEFINE vfechaServ DATE;		
--APOLO
DEFINE cUser_insert CHAR(10);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_hoy        =" ";
--APR 20180605
LET ncliente_pros = '';
LET sStatus_numctepros = '';
LET cUser_insert = '';

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
	INSERT INTO ax_paso values ("graba_sol", sql_err);
      RETURN scod_ret;
   END EXCEPTION;

    --Set debug file to '/pisa/pisabanco/graba_sol_precalificada.out';
    --trace on;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	SELECT fecha_hoy INTO v_hoy FROM bdicred:sd_fechas;
	
	-- RQI 21 246  OriginaciÃ³n de solicitudes 24 x 7	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;
	
	IF v_hoy < vfechaServ THEN
		LET v_hoy = vfechaServ;
	END IF;

	-- ***************************************************
	-- Adiciona Registro en Tabla Maestra de Solicitudes *
	-- ***************************************************
	INSERT INTO ss_solicitudes
	 (empresa, num_solicitud, numcte, sucursal, tipo_solicitud,
	  status_solicitud, num_producto, user_insert, fecha_insert)
	VALUES
	 (v_empresa, v_numsol, v_numcte, v_sucursal, v_tpsol,
	  "PC", v_producto, v_ejecutivo, v_hoy);

	-- ****************************************************************
	-- Adiciona Registro en Tabla valores informativos de la solicitud*
	-- ****************************************************************
	INSERT INTO ss_anexosol
	 (empresa, num_solicitud, fecha_sol, ejecutivo_sol, user_insert,
	  fecha_insert,cod_linea)
	VALUES
	 (v_empresa, v_numsol, v_hoy, v_ejecutivo, v_ejecutivo, v_hoy,v_subProducto );

	
	-- *********************************************************
	-- Adiciona Registro en Tabla Autorizaciones de Solicitudes*
	-- *********************************************************

/*	INSERT INTO ss_autorizacion 
	 (empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario,
	  fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES
	 (v_empresa, v_ejecutivo, v_numsol, "PC", 
	  "Solicitud Pre-Calificada  por sistema", 
          v_hoy, v_hoy, v_ejecutivo, v_hoy);*/

		  
	IF EXISTS(SELECT a.numcte
	FROM bdisolic:'informix'.ss_solicitudes a
	JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
	JOIN bdiprospectos:'informix'.pr_autorizacion c ON b.numcte_pros = c.num_solicitud
	WHERE a.num_solicitud = v_numsol
	and c.status_solicitud = 'PC') THEN

		SELECT b.status_numcte_pros INTO sStatus_numctepros
		FROM bdisolic:'informix'.ss_solicitudes a
		JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
		AND a.num_solicitud = v_numsol;

		IF sStatus_numctepros NOT IN ('CM','RT','CN') THEN
			IF (SELECT COUNT(num_solicitud) FROM bdisolic: ss_autorizacion where num_solicitud = v_numsol AND status_solicitud = 'PC') > 1 THEN
				LET ncliente_pros = '1';
			ELSE
				IF (EXISTS(SELECT num_solicitud FROM bdisolic: ss_autorizacion where num_solicitud = v_numsol AND status_solicitud = 'OA'))
					AND ('PC' in ('EE','OS')) THEN
					LET ncliente_pros = '1';
				ELSE
					LET ncliente_pros = '2';
				END IF;
			END IF;
		END IF;
		
	END IF

	INSERT INTO ss_autorizacion 
	 (empresa, ejecutivo_auto, num_solicitud, status_solicitud, cliente_pros, comentario,
	  fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES
	 (v_empresa, v_ejecutivo, v_numsol, "PC", ncliente_pros, 
	  "Solicitud Pre-Calificada  por sistema", 
          v_hoy, v_hoy, v_ejecutivo, v_hoy);
	IF ncliente_pros IN ('1','2') THEN
	
		SELECT sucursal INTO csucursal FROM bdiprospectos:pr_cliente WHERE numcte = v_numcte;
		IF csucursal = '0800' THEN
		
			UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '3'
			WHERE numcte = v_numcte AND num_solicitud = v_numsol;
		
		ELSE
			UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '5'
			WHERE numcte = v_numcte AND num_solicitud = v_numsol;
		
		END IF;	
		
	ELIF ncliente_pros = '' THEN
	
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '1'
		WHERE numcte = v_numcte AND num_solicitud = v_numsol;
	
	END IF;
	
	SELECT user_insert INTO cUser_insert FROM bdinteg:si_cliente WHERE numcte = v_numcte;

	IF cUser_insert = 'sysapolo' THEN		
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '9'
		WHERE numcte = v_numcte AND num_solicitud = v_numsol;
	END IF;
	
END
	RETURN scod_ret;
END PROCEDURE
;
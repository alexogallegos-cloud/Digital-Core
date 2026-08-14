CREATE PROCEDURE "informix".sp_burofisicas_depura()
  RETURNING 
  CHAR(6) AS cCodRet, CHAR(50) AS cMensajeRet; 
 
 DEFINE cCodRet        CHAR(6);
 DEFINE cMensajeRet	   CHAR(50);
 DEFINE iSqlErr        INTEGER;
 DEFINE iIsamErr       INTEGER;
 
 DEFINE vEmpresa       CHAR(3);
 DEFINE vnum_credito   CHAR(20);
 DEFINE cProceso       CHAR(4);
 DEFINE cCod_ret_2     CHAR(6);
 DEFINE vfecha_hoy     DATE;
 DEFINE vfecha_ini     DATE;
 DEFINE vfecha_fin     DATE;
 DEFINE iExisteIndice  INTEGER;
 DEFINE vfecha_reporte CHAR(8);
 DEFINE vano           char(4);
 DEFINE vmes           char(2);
 DEFINE vdia           char(2);
 
 LET vEmpresa           = '001';
 LET cCodRet            = '000000';
 LET cMensajeRet		= 'PROCESO EXITOSO';
 LET iIsamErr           = 0;
 LET iSqlErr            = 0;
 
 LET vnum_credito       = '';
 LET cProceso           = '0122';
 LET cCod_ret_2         = '';
 LET vfecha_hoy         = DATE(1);
 LET vfecha_ini         = DATE(1);
 LET vfecha_fin         = DATE(1);
 LET iExisteIndice  = 0;
 LET vfecha_reporte = '';
 LET vano           = '';
 LET vmes           = '';
 LET vdia           = '';
 
 BEGIN
 
    ON EXCEPTION SET iSqlErr, iIsamErr
	   
	   IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensajeRet = trim(cCodRet) || ' Error en el proceso: ' || trim(vnum_credito);
			CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensajeRet, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensajeRet);
        END IF;
    				
    	RETURN cCodRet,cMensajeRet;
    END EXCEPTION;
   
   --SET DEBUG FILE TO "/ifxsif01/macf/sp_burofisicas_depura.out";
   --TRACE ON;
 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING cCod_ret_2; 
	
	SELECT substr(registro,35,8) INTO vfecha_reporte 
	  FROM bdiburo:br_burofisicas WHERE numreg = 1;
	
	LET vfecha_hoy = SUBSTR(vfecha_reporte,3,2) || '/' || SUBSTR(vfecha_reporte,1,2) || '/' || SUBSTR(vfecha_reporte,5,4);
	--LET vfecha_hoy = MDY(10,31,2020);  --SOLO TEST
	--LET vfecha_reporte = '31102020';  --SOLO TEST
	
	SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofis_desc_statuscred';
     
     IF iExisteIndice <= 0 THEN
        create index "informix".idx_burofis_desc_statuscred on
         "informix".br_burofisicas_describe(fecha_reporte,status_cred) in datos01_idx online;
		 update statistics medium for table "informix".br_burofisicas_describe;
     END IF; 
	 LET iExisteIndice = 0;
	 
	 SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofisicas_base_numcred';
     
	 IF iExisteIndice <= 0 THEN
	    create index "informix".idx_burofisicas_base_numcred on
        "informix".br_burofisicas_base(num_credito, fecha_reporte) in datos01_idx online;
		update statistics medium for table "informix".br_burofisicas_base;
	 END IF;
	 
	-- DEPURA 1
	-- DEPURA br_burofisicas_base (Estatus CV,FC,FF,FI)
    FOREACH WITH HOLD
		 
		 SELECT num_credito INTO vnum_credito
		   FROM bdiburo:br_burofisicas_base 
		   WHERE num_credito in(
                  SELECT num_credito FROM bdiburo:br_burofisicas_describe
                   WHERE fecha_reporte = vfecha_reporte 
				     AND status_cred in('CV','FC','FF','FI')
           )
		 
		   begin;  
		      DELETE bdiburo:br_burofisicas_base 
		      WHERE num_credito = vnum_credito AND fecha_reporte = vfecha_hoy;
		   commit;
		  
    
    END FOREACH;
	
	LET iExisteIndice = 0;
	
	SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofis_desc_fecha_cveobs';
     
     IF iExisteIndice <= 0 THEN
        create index "informix".idx_burofis_desc_fecha_cveobs on
         "informix".br_burofisicas_describe(fecha_reporte,clave_obs) in datos01_idx online;
		 update statistics medium for table "informix".br_burofisicas_describe;
     END IF; 
	 LET iExisteIndice = 0;
	
	
	--DEPURA 3
	SELECT num_credito 
	  FROM bdiburo:br_burofisicas_describe
	 WHERE fecha_reporte = vfecha_reporte
	   AND status_cred in('CV','FC','FF','FI')
	 INTO temp creditos_describe WITH NO LOG;
	
	-- DEPURA br_burofisicas_describe
	FOREACH WITH HOLD
		SELECT num_credito INTO vnum_credito
		FROM creditos_describe
	
		begin;  
		   DELETE bdiburo:br_burofisicas_describe
		    WHERE num_credito = vnum_credito AND fecha_reporte = vfecha_reporte;
		commit;

	END FOREACH;	
	
	--DEPURA 4
	--- BORRAR LOS REGISTROS CON CLAVE OBSERV LS de br_burofisicas_describe (Clave obs LS)
	SELECT num_credito
      FROM bdiburo:br_burofisicas_describe 
     WHERE fecha_reporte = vfecha_reporte and clave_obs = 'LS'
	 INTO temp creditos_describe_2 WITH NO LOG;
	
	
	FOREACH WITH HOLD
		SELECT num_credito INTO vnum_credito
		FROM creditos_describe_2
	
		begin;  
		   DELETE bdiburo:br_burofisicas_describe
		   WHERE num_credito = vnum_credito AND fecha_reporte = vfecha_reporte  and clave_obs = 'LS';
		commit;

	END FOREACH;	
	
	
   SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofis_desc_statuscred';
     
     IF iExisteIndice > 0 THEN
        DROP INDEX "informix".idx_burofis_desc_statuscred;
	 END IF;
     LET iExisteIndice = 0;
	 
	 SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofisicas_base_numcred';
	 
	 IF iExisteIndice > 0 THEN
        DROP INDEX "informix".idx_burofisicas_base_numcred;
		update statistics medium for table "informix".br_burofisicas_base;
	 END IF;
	 
	 SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofis_desc_fecha_cveobs';
     
     IF iExisteIndice > 0 THEN
        DROP INDEX "informix".idx_burofis_desc_fecha_cveobs;
		update statistics medium for table "informix".br_burofisicas_describe;
     END IF; 
	 
	 
	 drop table creditos_describe;
	 drop table creditos_describe_2;
	 
  CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING cCod_ret_2; 
    
  
  RETURN cCodRet,cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'Fecha: 20201204',
'Descripción: Proceso para depurar cuentas con estatus: CV,FF,FC y FI',
'  así como las que tuvieron clave de observ. LS en la última cinta enviada a las SICs',
'Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_burofisicas_depura_cnr()
  RETURNING 
  CHAR(6) AS cCodRet, CHAR(50) AS cMensajeRet; 
 
 DEFINE cCodRet        CHAR(6);
 DEFINE cMensajeRet	   CHAR(50);
 DEFINE iSqlErr        INTEGER;
 DEFINE iIsamErr       INTEGER;
 
 DEFINE vEmpresa       CHAR(3);
 DEFINE vnum_credito   CHAR(20);
 DEFINE cProceso       CHAR(4);
 DEFINE cCod_ret_2     CHAR(6);
 DEFINE vfecha_hoy     DATE;
 DEFINE vfecha_ini     DATE;
 DEFINE vfecha_fin     DATE;
 DEFINE iExisteIndice  INTEGER;
 DEFINE vfecha_reporte CHAR(8);
 DEFINE vano           char(4);
 DEFINE vmes           char(2);
 DEFINE vdia           char(2);
 
 LET vEmpresa           = '001';
 LET cCodRet            = '000000';
 LET cMensajeRet		= 'PROCESO EXITOSO';
 LET iIsamErr           = 0;
 LET iSqlErr            = 0;
 
 LET vnum_credito       = '';
 LET cProceso           = '0123';
 LET cCod_ret_2         = '';
 LET vfecha_hoy         = DATE(1);
 LET vfecha_ini         = DATE(1);
 LET vfecha_fin         = DATE(1);
 LET iExisteIndice  = 0;
 LET vfecha_reporte = '';
 LET vano           = '';
 LET vmes           = '';
 LET vdia           = '';
 
 BEGIN
 
    ON EXCEPTION SET iSqlErr, iIsamErr
	   
	   IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensajeRet = trim(cCodRet) || ' Error en el proceso: ' || trim(vnum_credito);
			CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensajeRet, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensajeRet);
        END IF;
    				
    	RETURN cCodRet,cMensajeRet;
    END EXCEPTION;
   
   --SET DEBUG FILE TO "/ifxsif01/macf/sp_burofisicas_depura.out";
   --TRACE ON;
 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING cCod_ret_2; 
	
	SELECT substr(registro,35,8) INTO vfecha_reporte 
	  FROM bdiburo:br_burofisicas_cnr WHERE numreg = 1;
	
	LET vfecha_hoy = SUBSTR(vfecha_reporte,3,2) || '/' || SUBSTR(vfecha_reporte,1,2) || '/' || SUBSTR(vfecha_reporte,5,4);
	--LET vfecha_hoy = MDY(7,31,2020);  --SOLO TEST
	--LET vfecha_reporte = '31072020';  --SOLO TEST
	
	SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofis_desc_cnr_statuscred';
     
     IF iExisteIndice <= 0 THEN
        create index "informix".idx_burofis_desc_cnr_statuscred on
         "informix".br_burofisicas_describe_cnr(fecha_reporte,status_cred) in datos01_idx online;
		 update statistics medium for table "informix".br_burofisicas_describe_cnr;
     END IF; 
	 LET iExisteIndice = 0;
	 
	 SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofisicas_cnr_base_numcred';
     
	 IF iExisteIndice <= 0 THEN
	    create index "informix".idx_burofisicas_cnr_base_numcred on
        "informix".br_burofisicas_cnr_base(num_credito, fecha_reporte) in datos01_idx online;
		update statistics medium for table "informix".br_burofisicas_cnr_base;
	 END IF;
	 
	-- DEPURA 1
	-- DEPURA br_burofisicas_base (Estatus CV,FC,FF,FI)
    FOREACH WITH HOLD
		 
		 SELECT num_credito INTO vnum_credito
		   FROM bdiburo:br_burofisicas_cnr_base 
		   WHERE num_credito in(
                  SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr
                   WHERE fecha_reporte = vfecha_reporte 
				     AND status_cred in('CV','FF','FI')
           )
		 
		   begin;  
		      DELETE bdiburo:br_burofisicas_cnr_base 
		      WHERE num_credito = vnum_credito AND fecha_reporte = vfecha_hoy;
		   commit;
		  
    
    END FOREACH;
	
	LET iExisteIndice = 0;
	
	--DEPURA 2
	SELECT num_credito 
	  FROM bdiburo:br_burofisicas_describe_cnr
	 WHERE fecha_reporte = vfecha_reporte
	   AND status_cred in('CV','FF','FI')
	 INTO temp creditos_describe_cnr WITH NO LOG;
	
	-- DEPURA br_burofisicas_describe_cnr
	FOREACH WITH HOLD
		SELECT num_credito INTO vnum_credito
		FROM creditos_describe_cnr
	
		begin;  
		   DELETE bdiburo:br_burofisicas_describe_cnr
		    WHERE num_credito = vnum_credito AND fecha_reporte = vfecha_reporte;
		commit;

	END FOREACH;	

	SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofis_desc_cnr_statuscred';
	 
     IF iExisteIndice > 0 THEN
        DROP INDEX  "informix".idx_burofis_desc_cnr_statuscred;
		update statistics medium for table "informix".br_burofisicas_describe_cnr;
	 END IF;
     LET iExisteIndice = 0;
	 
	 SELECT count(*) into iExisteIndice 
      FROM sysindices 
     WHERE idxname = 'idx_burofisicas_cnr_base_numcred';
	 
	 IF iExisteIndice > 0 THEN
        DROP INDEX "informix".idx_burofisicas_cnr_base_numcred;
		update statistics medium for table "informix".br_burofisicas_cnr_base;
	 END IF;
	 
	 drop table creditos_describe_cnr;
	 
  CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING cCod_ret_2; 
    
  
  RETURN cCodRet,cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'Fecha: 20201202',
'Descripción: Proceso para depurar cuentas con estatus: CV,FF,FC y FI',
'Autor: Marco A. Campos';

CREATE PROCEDURE "informix".procesoreenviodemonio(pInstitucion CHAR(2))
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cInstitucion CHAR(2);
	DEFINE cNumCte CHAR(9);
	DEFINE cNumSolicitud CHAR(12);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cInstitucion = '';
	LET cNumCte = '';
	LET cNumSolicitud = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/RESPALDOS/ipcb/Mejoras_Demonio/procesoreenvioDemonio_modif.out';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		FOREACH SELECT a.institucion, a.numcte, a.num_solicitud
				INTO cInstitucion, cNumCte, cNumSolicitud
				FROM "informix".br_traslado a 
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON (b.empresa = '001' AND b.num_solicitud = a.num_solicitud 
																	AND b.status_solicitud = a.institucion AND b.fecha_insert = a.fecha_insert)
				WHERE a.institucion = pInstitucion 
				AND a.num_solicitud NOT IN (SELECT UNIQUE(num_solicitud) FROM "informix".br_respuesta_aprocesar 
											WHERE institucion = pInstitucion  AND num_solicitud = a.num_solicitud)
				AND a.status in(1)
				AND a.fecha_insert = today

				UPDATE "informix".br_traslado
				SET status = 0
				WHERE institucion = cInstitucion 
				AND num_solicitud = cNumSolicitud
				AND status in(1);

		END FOREACH;

		RETURN cCodRet;
	END;
END PROCEDURE

DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 12/05/2016',
'MODULO: DEMONIO',
'ACTIVIDAD: CREACION',
'FUNCIONALIDAD: REENVIO DE SOLICITUDES',
'DESCRIPCION:SPL que actualiza solicitudes para que sean reenviadas por el demonio.',
'BD: bdiburo',
'**********************************************************************************',
'AUTOR: Carlos Valenzuela',
'FECHA: 29/08/2016',
'MODULO: DEMONIO',
'ACTIVIDAD: CAMBIO',
'DESCRIPCION: Se optimiza el SPL ya que se detecto que tenia una bÃÂºsqueda secuencial',
'cuando realizaba la consulta a la tabla br_respuesta_aprocesar, para erradicar esto',
'se creo un indice y se le agrego una condiciÃÂ³n a dicha consulta utilizando el campo num_solicitud.',
'BD: bdiburo';

CREATE PROCEDURE "informix".burocred_cc(pempresa CHAR(3),psucursal CHAR(4),pusuario CHAR(8),pSolicitud CHAR(20),pMontoSol MONEY(14,2))
RETURNING  CHAR(05) AS codret;

--EXECUTE PROCEDURE burocred('001','0142','prueba','',1500.00);

---------------DECLARACION DE VARIABLES
	DEFINE vregistro CHAR(255);
	DEFINE vregistro1 CHAR(255);
    DEFINE vregistro2 CHAR(255);
	DEFINE vcliente CHAR(20);
	DEFINE vlen INTEGER;
	DEFINE vpos CHAR(2);
	DEFINE vpo1 CHAR(5);
	DEFINE vdia CHAR(2);
	DEFINE vmes CHAR(2);
	DEFINE vanio CHAR(4);
	-- Variables para ver si se va a Buro o no --
	DEFINE vf1mes DATE;
	DEFINE vstatus CHAR(2);
	DEFINE vcodret CHAR(5);
	DEFINE vecampo1 CHAR(4);
	DEFINE vecampo2 CHAR(2);
	DEFINE vecampo3 CHAR(25);
	DEFINE vecampo4 CHAR(3);
	DEFINE vecampo5 CHAR(2);
	DEFINE vecampo6 CHAR(4);
	DEFINE vecampo7 CHAR(10);
	DEFINE vecampo8 CHAR(8);
	DEFINE vecampo9 CHAR(1);
	DEFINE vecampo10 CHAR(2);
	DEFINE vecampo11 CHAR(2);
	DEFINE vecampo12 CHAR(9);
	DEFINE vecampo13 CHAR(2);
	DEFINE vecampo14 CHAR(2);
	DEFINE vecampo15 CHAR(1);
	DEFINE vecampo16 CHAR(4);
	DEFINE vecampo17 CHAR(7);
	DEFINE vexiste INTEGER;
	DEFINE vcodini INTEGER;
	DEFINE vcodfin INTEGER;
	-- Datos del Cliente --
	DEFINE vdcampo1 CHAR(2);
	DEFINE vdcampo2 CHAR(26);
	DEFINE vdcampo3 CHAR(26);
	DEFINE vdcampo4 CHAR(26);
	DEFINE vdcampo5 CHAR(26);
	DEFINE vdcampo6 CHAR(10);
	DEFINE vdcampo7 CHAR(13);
	DEFINE vdcampo8 CHAR(2);
	DEFINE vdcampo9 CHAR(1);
	DEFINE vdcampo10 CHAR(1);
	DEFINE vdcampo11 CHAR(1);
	DEFINE vdcampo12 CHAR(2);
	DEFINE vscampo1 CHAR(2);
	DEFINE vscampo2 CHAR(40);
	DEFINE vscampo3 CHAR(40);
	DEFINE vscampo4 CHAR(40);
	DEFINE vscampo5 CHAR(40);
	DEFINE vscampo6 CHAR(40);
	DEFINE vscampo7 CHAR(4);
	DEFINE vscampo8 CHAR(5);
	DEFINE vscampo8a INTEGER;
	DEFINE vscampo9 CHAR(1);
	DEFINE vexiste1 SMALLINT;
	DEFINE vquita CHAR(40);
	DEFINE vespacio CHAR(1);
	DEFINE vmanzana SMALLINT;
	DEFINE vandador SMALLINT;
	DEFINE vlote SMALLINT;
	DEFINE vedificio SMALLINT;
	DEFINE ventrada SMALLINT;
	DEFINE vsecuencia SMALLINT;
	DEFINE vcomentario CHAR(80);
	DEFINE vhora datetime HOUR TO fraction(3);
	DEFINE vfecha DATE;
	DEFINE status_1      CHAR(2);  ---cambio CAS
	DEFINE status_2      CHAR(2);  ---cambio CAS
	DEFINE producto_sol  CHAR(20);
	DEFINE siglas_producto  CHAR(2);
	DEFINE cResultado  CHAR(6);
	DEFINE cMensajeRes  CHAR(8);
	DEFINE iSql_err      INTEGER;
	
    DEFINE vnumerocalle INTEGER;
	DEFINE iFlag2credito         SMALLINT;
	
	DEFINE valida_hit CHAR(1);
    DEFINE wBegin       CHAR(1);
	DEFINE pInstitucion CHAR (2);

---------------INICIALIZACION DE VARIABLES
    LET pInstitucion = 'CC';
	LET vhora = extend(CURRENT,HOUR TO fraction(3));
	LET vregistro ="";
	LET vregistro1="";
	LET vregistro2="";
	LET vcliente ="";
	LET vlen =0;
	LET vpos="";
	LET vdia="";
	LET vmes="";
	LET vanio="";
	LET vf1mes="";
	LET vstatus="";
	LET vcodret="000";
    LET status_1="00";
    LET status_2="00";
    LET producto_sol = "";
    LET siglas_producto = "";
	LET cResultado = "";
	LET cMensajeRes = "";
	LET iSql_err        = 0 ;
	LET vpo1 = "";
	LET vecampo1 = "";
	LET vecampo2 = "";
	LET vecampo3 = "";
	LET vecampo4 = "";
	LET vecampo5 = "";
	LET vecampo6 = "";
	LET vecampo7 = "";
	LET vecampo8 = "";
	LET vecampo9 = "";
	LET vecampo10 = "";
	LET vecampo11 = "";
	LET vecampo12 = "";
	LET vecampo13 = "";
	LET vecampo14 = "";
	LET vecampo15 = "";
	LET vecampo16 = "";
	LET vecampo17 = "";
	LET vexiste = 0;
	LET vcodini = 0;
	LET vcodfin = 0;
	LET vdcampo1 = "";
	LET vdcampo2 = "";
	LET vdcampo3 = "";
	LET vdcampo4 = "";
	LET vdcampo5 = "";
	LET vdcampo6 = "";
	LET vdcampo7 = "";
	LET vdcampo8 = "";
	LET vdcampo9 = "";
	LET vdcampo10 = "";
	LET vdcampo11 = "";
	LET vdcampo12 = "";
	LET vscampo1 = "";
	LET vscampo2 = "";
	LET vscampo3 = "";
	LET vscampo4 = "";
	LET vscampo5 = "";
	LET vscampo6 = "";
	LET vscampo7 = "";
	LET vscampo8 = "";
	LET vscampo8a = 0;
	LET vscampo9 = "";
	LET vexiste1 = 0;
	LET vquita = "";
	LET vespacio = "";
	LET vmanzana = 0;
	LET vandador = 0;
	LET vlote = 0;
	LET vedificio = 0;
	LET ventrada = 0;
	LET vsecuencia = 0;
	LET vcomentario = "";

    LET vnumerocalle = 0;
	LET iFlag2credito = 0;
	
	LET valida_hit ="";
	LET wBegin = "N";

BEGIN
	--CONTROL DE ERRORES--
	/*ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET vcodret = iSql_err;		
			RETURN vcodret;
		END IF;
	END EXCEPTION;
	
	 ON EXCEPTION IN (-535)
      LET wBegin = "S";
     -- ROLLBACK WORK;
	 commit work;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;*/
--SET DEBUG FILE TO '/informix/jesus/burocred.out';
--TRACE ON;
--SET DEBUG FILE TO '/RESPALDOS/ipcb/pruebas/burocred_pam.out';   TRACE ON;
--begin work;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
   /*SET DEBUG FILE TO '/informix/Fperaza/NuevosCambios/Carg/trace/burocred_'||trim(pSolicitud)||'.out';
	TRACE ON;*/
	
	SELECT fecha_hoy 
	INTO vfecha 
	FROM bdicred:"informix".sd_fechas;
	
	SELECT numcte,num_producto
		INTO vcliente,producto_sol
		FROM bdisolic:"informix".ss_solicitudes
		WHERE empresa = "001" 
		AND num_solicitud = pSolicitud;
	
   -- Declaracion de Constantes para Generacion de Registros desea ver que significa cada campo
   -- Favor de consultar el manual -->
	LET vecampo1="INTL";
	LET vecampo2="11";
--- COLOCACION DE NUMERO DE SOLICITUD
	LET vecampo3 =pSolicitud||"     ";
	LET vecampo4="001";
	LET vecampo5="MX";
	LET vecampo6="0000";
	LET vecampo7    = "";
	LET vecampo8    = "";
	LET vecampo9="I";
	LET vecampo10="";	LET vecampo11="MX";
	LET vecampo12="0"; --monto solicitado
	LET vecampo13="SP";
	LET vecampo14="03";	LET vecampo15=" ";
	LET vecampo16="    ";
	LET vecampo17="0000000";
	LET vexiste=0;
	LET vcomentario = "";
-- Consulta las siglas correspondientes al producto solicitado
       SELECT codigo
         INTO siglas_producto
         FROM "informix".br_tltco
        WHERE num_producto = producto_sol;

        LET vecampo10 = siglas_producto;
		
			--Usuario Circulo
			SELECT TRIM(valor) INTO vecampo7
		    FROM "informix".br_param
		    WHERE cod_param = 1;
			
			--Password Circulo
			SELECT TRIM(valor) INTO vecampo8
			FROM "informix".br_param
			WHERE cod_param = 2;		
			--FJPR SE INSERTA TRAMA HACIA CC
			
			--Numero de producto
			SELECT TRIM(valor) INTO vecampo4
			FROM bdiburo:br_param
			WHERE cod_param = 152;    
		
		
  LET vecampo12=LPAD(round(pMontoSol,0),9,"0");
  LET vregistro= vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||
	     vecampo6||vecampo7||vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
	     vecampo14||vecampo15||vecampo16||vecampo17;
	-- Datos del Cliente --
	LET vdcampo1="PN"; --Identificador de cadena--
	LET vdcampo2=""; --Apellido Paterno PN--
	LET vdcampo3=""; --Apellido Materno 00--
	LET vdcampo4=""; --Primer Nombre 02--
	LET vdcampo5=""; --Segundo Nombre 03--
	LET vdcampo6=""; --Fecha de Nacimiento 04--
	LET vdcampo7=""; --RFC 05--
	LET vdcampo8="MX"; --Nacionalidad MX o EX 08--
	LET vdcampo9=""; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
	LET vdcampo10=""; --Estado Civil 11 --
	LET vdcampo11=""; --Sexo 12--
	LET vdcampo12=""; --Dependiente 17--
	-- Direccion del Cliente --
	LET vscampo1="PA"; --Identificador de cadena--
	LET vscampo2=""; --Direccion Linea 1 PA--
	LET vscampo3=""; --Direccion Linea 2 00--
	LET vscampo4=""; --Colonia o Poblacion 01--
	LET vscampo5=""; --Delegacion o Municipio 02--
	LET vscampo6=""; --Nombre Ciudad 03--
	LET vscampo7=""; --Estado 04--
	LET vscampo8=""; --Codigo Postal 05--
	LET vscampo9=""; --Tipo de Domicilio 10--

	SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1),
  	        TRIM(nombre2),fecha_nac, CASE WHEN LENGTH(trim(rfc_alterno)) = 13 THEN rfc_alterno ELSE rfc END, TRIM(habita_en),
  	         TRIM(estado_civil),TRIM(sexo), NVL(dependientes,"0")
		    INTO vdcampo2,vdcampo3,vdcampo4,
                        vdcampo5,vdcampo6,vdcampo7,vdcampo9,
                        vdcampo10,vdcampo11,vdcampo12
		    FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b
		    WHERE a.numcte = b.numcte  AND b.numcte = vcliente;

	  -- Cambia las ÃÆÃ¢â¬Ë de los Nombres y Apellidos --
         IF vdcampo2 IS NULL THEN LET vdcampo2 = ""; LET vcomentario = "Apellido paterno nulo"; END IF;
         IF vdcampo3 IS NULL THEN LET vdcampo3 = "NO PROPORCIONADO"; END IF;
         IF vdcampo4 IS NULL THEN LET vdcampo4 = ""; LET vcomentario = TRIM(vcomentario)||" Sin nombre"; END IF;
         IF vdcampo5 IS NULL THEN LET vdcampo5 = ""; END IF;
         IF vdcampo6 IS NULL THEN LET vdcampo6 = ""; END IF;
         IF vdcampo7 IS NULL THEN LET vdcampo7 = ""; END IF;
         IF vdcampo9 IS NULL THEN LET vdcampo9 = ""; END IF;
         IF vdcampo10 IS NULL THEN LET vdcampo10 = ""; END IF;
         IF vdcampo11 IS NULL THEN LET vdcampo11 = ""; END IF;
         IF vdcampo12 IS NULL THEN LET vdcampo12 = "0"; END IF;
         LET vexiste = LENGTH(vdcampo2);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo2[1,1]="~" OR vdcampo2[1,1]=" " OR vdcampo2[1,1]="." OR
           vdcampo2[1,1]="-"  THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo2[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo2[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo2 = vdcampo2[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo2 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo3);
     --- CAMBIO DE APELLIDO MATERNO
         IF vexiste = 0 THEN
            LET vdcampo3 = "NO PROPORCIONADO";
            LET vexiste = LENGTH(vdcampo3);
         END IF
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo3[1,1]="~" OR vdcampo3[1,1]=" " OR vdcampo3[1,1]="." OR
            vdcampo3[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo3[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo3[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo3 = vdcampo3[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo3 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo4);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio = " ";
         WHILE vexiste1 < vexiste
           IF vdcampo4[1,1]="~" OR vdcampo4[1,1]=" "  OR vdcampo4[1,1]="." OR
            vdcampo4[1,1]="-" THEN
              LET vespacio = "F";
           ELSE
             IF vespacio = "F" THEN
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo4[1,1];
               END IF
               LET vespacio ="";
             ELSE
               IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo4[1,1];
               END IF
             END IF
           END IF;
           LET vdcampo4 = vdcampo4[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo4 = TRIM(vquita);
         LET vexiste = LENGTH(vdcampo5);
         LET vexiste1 = 0;
         LET vquita = "";
         LET vespacio =" ";
         WHILE vexiste1 < vexiste
           IF vdcampo5[1,1]="~" OR vdcampo5[1,1]=" " OR vdcampo5[1,1]="." OR
            vdcampo5[1,1]="-" THEN
              LET vespacio ="F";
           ELSE
            IF vespacio = "F" THEN
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||" "||vdcampo5[1,1];
               END IF
	       LET vespacio ="";
            ELSE
               IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "ÃâÃÂ¥" THEN
                 LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
               ELSE
                 LET vquita = TRIM(vquita)||vdcampo5[1,1];
               END IF
            END IF
           END IF;
           LET vdcampo5 = vdcampo5[2,26];
           LET vexiste1 = vexiste1 + 1;
         END WHILE;
         LET vdcampo5 = TRIM(vquita);
         IF vdcampo9 ="P" OR vdcampo9 ="G" THEN
	       	   LET vdcampo9="1";
	 ELSE
	   IF vdcampo9 ="R" THEN 
	    LET vdcampo9="2";
	   ELSE
	     IF vdcampo9 ="F"  OR vdcampo9 = "H" THEN 
	       LET vdcampo9="3";
	     ELSE
	      LET vdcampo9="";
	     END IF
	   END IF
	 END IF
         IF vdcampo10 ="D" THEN
	       	   LET vdcampo10="D";
	 ELSE
	   IF vdcampo10 ="U" THEN
	    LET vdcampo10="F";
	   ELSE
	     IF vdcampo10 ="C" THEN
	       LET vdcampo10="M";
	     ELSE
	      IF vdcampo10 ="S" THEN
	         LET vdcampo10="S";
	      ELSE
	         IF vdcampo10 ="V" THEN
		    LET vdcampo10="W";
	         END IF
	      END IF
	     END IF
	   END IF
	 END IF
	-- Carga los datos de la Direccion del Cliente --
    --SELECT MAX(secuencia) INTO vsecuencia
    --  FROM bdinteg:"informix".si_direcciones
	--           WHERE  numcte=vcliente AND tipo_dir='1';

      SELECT TRIM(f.nombrecalle),
           REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
           TRIM(g.nombrezona), 
       TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
           manzana,andador,lote,edificio,entrada,codini,codfin, nvl(a.numerocalle,0)
       INTO   vscampo2, vscampo3, vscampo4,
              vscampo6, vscampo7,vscampo8,vscampo9,
              vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin, vnumerocalle
       FROM  bdinteg:"informix".si_direcciones_actual as a,
                 bdisolic:"informix".ss_circulo_edos as c,
                 bdinteg:"informix".si_catcalles f,
                 bdinteg:"informix".si_catzonas g
       WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
         AND c.clave = a.estado 
         AND g.numerociudad = a.numerociudad
         AND g.numerocolonia = a.numerocolonia
         AND f.numerocalle = a.numerocalle;	
	
		IF (vscampo2 is null or vnumerocalle = 0) and (SELECT COUNT(num_solicitud) 					
				FROM bdisolic:"informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  num_solicitud = pSolicitud
				AND status <> '3' ) > 0 THEN				
				
                SELECT TRIM(a.calle),
                REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
                TRIM(g.nombrezona), 
                TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
                manzana,andador,lote,edificio,entrada,codini,codfin 
                INTO   vscampo2, vscampo3, vscampo4,
                vscampo6, vscampo7,vscampo8,vscampo9,
                vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin
                FROM  bdinteg:"informix".si_direcciones_actual as a,
                     bdisolic:"informix".ss_circulo_edos as c,					 
                     bdinteg:"informix".si_catzonas g
                WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
                AND c.clave = a.estado 
                AND g.numerociudad = a.numerociudad
                AND g.numerocolonia = a.numerocolonia;								
		END IF;		
	
	   	
       IF vscampo2 IS NULL THEN LET vscampo2 = "";  LET vcomentario = TRIM(vcomentario)||" Sin calle "; END IF;
       IF vscampo3 IS NULL THEN LET vscampo3 = ""; END IF;
       IF vscampo4 IS NULL THEN LET vscampo4 = ""; END IF;
       IF vscampo5 IS NULL THEN LET vscampo5 = ""; END IF;
       IF vscampo6 IS NULL THEN LET vscampo6 = ""; LET vcomentario = TRIM(vcomentario)||" Sin localidad "; END IF;
       IF vscampo7 IS NULL THEN LET vscampo7 = ""; LET vcomentario = TRIM(vcomentario)||" Sin estado "; END IF;
       IF vscampo8 IS NULL THEN LET vscampo8 = ""; LET vcomentario = TRIM(vcomentario)||" Sin codigo postal "; END IF;
       IF vscampo9 IS NULL THEN LET vscampo9 = ""; END IF;
       LET vscampo2 = TRIM(vscampo2)||" "||TRIM(vscampo3);
       LET vexiste = LENGTH(vscampo2);
       IF vexiste < 26 THEN
         LET vscampo3 = "";
         IF vmanzana > 0 THEN
           LET vscampo3 ="mza "||vmanzana;
         END IF
         IF vandador > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"AND "||vandador;
         END IF
         IF vlote > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"lt "||vlote;
         END IF
         IF vedificio > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ed "||vedificio;
         END IF
         IF ventrada > 0 THEN
           LET vscampo3 =TRIM(vscampo3)||"ent "||ventrada;
         END IF
       LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
       END IF
       LET vscampo2 = TRIM(vscampo2);
       LET vexiste = LENGTH(vscampo2);
       LET vexiste1 = 0;
       LET vquita = "";
       LET vespacio = " ";
       WHILE vexiste1 < vexiste
        IF vscampo2[1,1]="~" OR vscampo2[1,1]=" " OR vscampo2[1,1]="." OR
         vscampo2[1,1]="-" THEN
           LET vespacio = "F";
        ELSE
          IF vespacio = "F" THEN
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "ÃâÃÂ¥" THEN
              LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
            ELSE
              LET vquita = TRIM(vquita)||" "||vscampo2[1,1];
            END IF
            LET vespacio = "";
          ELSE
            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "ÃâÃÂ¥" THEN
              LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
            ELSE
              LET vquita = TRIM(vquita)||vscampo2[1,1];
            END IF
          END IF
        END IF;
        LET vscampo2 = vscampo2[2,26];
        LET vexiste1 = vexiste1 + 1;
       END WHILE;
       LET vscampo2 = TRIM(vquita);
       IF vscampo9 ="1" THEN
	   LET vscampo9="H";
       ELSE
         IF vscampo9 ="2" THEN
           LET vscampo9="B";
         ELSE
           LET vscampo9="H";
         END IF
       END IF

    LET vregistro=TRIM(vregistro)||vdcampo1;
    LET vlen=LENGTH(vdcampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||vpos||vdcampo2;
    LET vlen=LENGTH(vdcampo3);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"00"||vpos||vdcampo3;
    LET vlen=LENGTH(vdcampo4);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"02"||vpos||vdcampo4;
    LET vlen=LENGTH(vdcampo5);
    LET vpos=LPAD(vlen,2,"0");
    IF vlen  > 0 THEN
      LET vregistro=TRIM(vregistro)||"03"||vpos||vdcampo5;
    END IF

    LET vlen=LENGTH(vdcampo6);
    IF vlen  > 0 THEN
    LET vdia=vdcampo6[4,5];
    LET vdia=LPAD(vdia,2,"0");
    LET vmes=vdcampo6[1,2];
    LET vmes=LPAD(vmes,2,"0");
    LET vanio=vdcampo6[7,10];
    LET vdcampo6=vdia||vmes||vanio;
    LET vlen=LENGTH(vdcampo6);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"04"||vpos||vdcampo6;
    END IF;
    LET vlen=LENGTH(vdcampo7);
    IF vlen  > 0 THEN
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"05"||vpos||vdcampo7;
    END IF;
    LET vlen=LENGTH(vdcampo8);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"08"||vpos||vdcampo8;
 --- Este es el campo correspondiente a la residencia
    IF vdcampo9 = "1" OR vdcampo9 = "2" OR vdcampo9 = "3" THEN
     LET vlen=LENGTH(vdcampo9);
     LET vpos=LPAD(vlen,2,"0");
     LET vregistro=TRIM(vregistro)||"09"||vpos||vdcampo9;
    END IF
    LET vlen =LENGTH(vdcampo10);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"11"||vpos||vdcampo10;
    END IF
    LET vlen=LENGTH(vdcampo11);
    IF vlen  > 0 THEN
      LET vpos=LPAD(vlen,2,"0");
      LET vregistro=TRIM(vregistro)||"12"||vpos||vdcampo11;
    END IF
    IF TRIM(vdcampo12) != "0" THEN
       IF LENGTH(TRIM(vdcampo12)) < 2 THEN
         LET vdcampo12 = "0"||TRIM(vdcampo12);
       END IF
       LET vlen=LENGTH(vdcampo12);
       LET vpos=LPAD(vlen,2,"0");
       LET vregistro=TRIM(vregistro)||"17"||vpos||vdcampo12;
    ELSE
       LET vregistro=TRIM(vregistro)||"170201";
    END IF
    LET vregistro=TRIM(vregistro)||vscampo1;
    LET vlen=LENGTH(vscampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro1=vpos||vscampo2;
    LET vscampo3 = "";
    LET vexiste = LENGTH(vscampo3);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo3[1,1]="~" OR vscampo3[1,1]=" " OR vscampo3[1,1]="." OR
      vscampo3[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "ÃâÃÂ¥" THEN
           LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
        ELSE
           LET vquita = TRIM(vquita)||" "||vscampo3[1,1];
        END IF
	LET vespacio = "";
      ELSE
        IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "ÃâÃÂ¥" THEN
	   LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
        ELSE
	   LET vquita = TRIM(vquita)||vscampo3[1,1];
        END IF
      END IF
     END IF;
     LET vscampo3 = vscampo3[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo3 = TRIM(vquita);
    LET vlen=LENGTH(vscampo3);
    LET vpos=LPAD(vlen,2,"0");
    --LET vregistro1='00'||vpos|| vscampo3;
    LET vexiste = LENGTH(vscampo4);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo4[1,1]="~" OR vscampo4[1,1]=" " OR vscampo4[1,1]="." OR
      vscampo4[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "ÃâÃÂ¥" THEN
	  LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo4[1,1];
        END IF
        LET vespacio = "";
      ELSE
        IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "ÃâÃÂ¥" THEN
	  LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo4[1,1];
        END IF
      END IF
     END IF;
     LET vscampo4 = vscampo4[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo4= TRIM(vquita);
    LET vlen=LENGTH(vscampo4);
    LET vpos= LPAD(vlen,2,"0");
    IF vlen > 0 THEN
    LET vregistro1= TRIM(vregistro1)||"01"||vpos|| vscampo4;
    END IF
{    LET vexiste = LENGTH(vscampo5);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo5[1,1]="~" OR vscampo5[1,1]=" " OR vscampo5[1,1]="." THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "ÃâÃÂ¥" THEN
	  LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë ";
	  LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo5[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "ÃâÃÂ¥" THEN
	  LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
        ELSE
	  LET vquita = TRIM(vquita)||vscmpo5[1,1];
        END IF
      END IF
     END IF;
     LET vscampo5 = vscampo5[2,26];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo5 = TRIM(vquita);
    LET vlen= LENGTH(vscampo5);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||'02'||vpos||vscampo5;
}
    LET vexiste = LENGTH(vscampo6);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo6[1,1]="~" OR vscampo6[1,1]=" " OR vscampo6[1,1]="." OR
      vscampo6[1,1]="-" THEN
       LET vespacio = "F";
       LET vexiste1 = vexiste1 + 1;
       LET vscampo6 = vscampo6[2,26];
     ELSE
      IF vespacio = "F" THEN
        IF vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 22;
            LET vscampo6 = vscampo6[23,26];
        ELSE
          IF vscampo6[1,12] = "MUNICIPIO DE"  THEN
	    LET vquita = TRIM(vquita);
            LET vexiste1 = vexiste1 + 12;
            LET vscampo6 = vscampo6[13,26];
          ELSE
           IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "ÃâÃÂ¥" THEN
	     LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
           ELSE
	     LET vquita = TRIM(vquita)||" "||vscampo6[1,1];
           END IF
	   LET vespacio = "";
           LET vexiste1 = vexiste1 + 1;
           LET vscampo6 = vscampo6[2,26];
          END IF;
        END IF;
      ELSE
        IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "ÃâÃÂ¥" THEN
	  LET vquita = TRIM(vquita)||"ÃÆÃ¢â¬Ë";
        ELSE
	  LET vquita = TRIM(vquita)||vscampo6[1,1];
        END IF
        LET vexiste1 = vexiste1 + 1;
        LET vscampo6 = vscampo6[2,26];
      END IF
     END IF;
    END WHILE;
    LET vscampo6 = TRIM(vquita);
    LET vlen= LENGTH(vscampo6);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||"03"||vpos||vscampo6;
    LET vexiste = LENGTH(vscampo7);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
     IF vscampo7[1,1]="~" OR vscampo7[1,1]=" " OR vscampo7[1,1]="." OR
      vscampo7[1,1]="-" THEN
       LET vespacio = "F";
     ELSE
      IF vespacio = "F" THEN
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "ÃâÃÂ¥" THEN
	  LET vquita = TRIM(vquita)||" ÃÆÃ¢â¬Ë";
          LET vespacio = "";
        ELSE
	  LET vquita = TRIM(vquita)||" "||vscampo7[1,1];
	  LET vespacio = "";
        END IF
      ELSE
        IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "ÃâÃÂ¥" THEN
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        ELSE
	   LET vquita = TRIM(vquita)||vscampo7[1,1];
        END IF
      END IF
     END IF;
     LET vscampo7 = vscampo7[2,4];
     LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo7 = TRIM(vquita);
    LET vlen= LENGTH(vscampo7);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro1= TRIM(vregistro1)||"04"||vpos||vscampo7;
{    IF vscampo8[1,1] = 1 OR vscampo8[1,1] = 2 OR vscampo8[1,1] = 3 OR vscampo8[1,1] = 4 OR vscampo8[1,1] = 5 OR vscampo8[1,1] = 6 OR
     vscampo8[1,1] = 7 OR vscampo8[1,1] = 8 OR vscampo8[1,1] = 9  THEN
      LET vscampo8a = vscampo8[1,1] * 10000;
    ELSE
      LET vscampo8a = 0;
    END IF
    IF vscampo8[2,2] = 1 OR vscampo8[2,2] = 2 OR vscampo8[2,2] = 3 OR vscampo8[2,2] = 4 OR vscampo8[2,2] = 5 OR vscampo8[2,2] = 6 OR
     vscampo8[2,2] = 7 OR vscampo8[2,2] = 8 OR vscampo8[2,2] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[2,2] * 1000;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[3,3] = 1 OR vscampo8[3,3] = 2 OR vscampo8[3,3] = 3 OR vscampo8[3,3] = 4 OR vscampo8[3,3] = 5 OR vscampo8[3,3] = 6 OR
     vscampo8[3,3] = 7 OR vscampo8[3,3] = 8 OR vscampo8[3,3] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[3,3] * 100;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[4,4] = 1 OR vscampo8[4,4] = 2 OR vscampo8[4,4] = 3 OR vscampo8[4,4] = 4 OR vscampo8[4,4] = 5 OR vscampo8[4,4] = 6 OR
     vscampo8[4,4] = 7 OR vscampo8[4,4] = 8 OR vscampo8[4,4] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[4,4] * 10;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[5,5] = 1 OR vscampo8[5,5] = 2 OR vscampo8[5,5] = 3 OR vscampo8[5,5] = 4 OR vscampo8[5,5] = 5 OR vscampo8[5,5] = 6 OR
     vscampo8[5,5] = 7 OR vscampo8[5,5] = 8 OR vscampo8[5,5] = 9  THEN
      LET vscampo8a = vscampo8a + vscampo8[5,5] ;
    ELSE
      LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8a < vcodini OR vscampo8a > vcodfin THEN
       LET vscampo8 = LPAD(round(vcodini),5,"0");
    END IF }
    LET vlen= LENGTH(vscampo8);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro2='05'||vpos||vscampo8;
    LET vlen= LENGTH(vscampo9);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro2=TRIM(vregistro2)||'10'||vpos||vscampo9;
    -- Marca el FIN de Trailer -->
   LET vlen= LENGTH(vregistro)+LENGTH(vregistro1)+LENGTH(vregistro2);
   LET vlen= TRUNC(vlen + 15);
   LET vpo1= LPAD(vlen,5,'0');
   LET vregistro2=TRIM(vregistro2)||'ES05'||vpo1||'0002**';
   
   
   INSERT INTO "informix".br_respaldo_cc VALUES(vcliente,pSolicitud,'CC','0',vfecha);
      
  --IF pentraCC = 1 THEN -- Se valida si se ocupa hacer respaldo o no
  IF   (select count(*)
		   FROM "informix".br_traslado
		  WHERE institucion = pInstitucion
			AND numcte = vcliente) > 0 THEN  
	
   --Respaldo br_traslado
	INSERT INTO "informix".br_traslado_hist(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
		 SELECT institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert
		   FROM "informix".br_traslado
		  WHERE institucion = CASE WHEN pInstitucion = "" THEN institucion  ELSE pInstitucion END
			AND numcte = vcliente;

	--Respaldo br_respuesta
	INSERT INTO "informix".br_respuesta_hist(idrespuesta,institucion,numcte,num_solicitud,fecha_insert,secuencia,regreso) 
            SELECT idrespuesta,institucion,numcte,num_solicitud,fecha_insert,secuencia,regreso
			   FROM "informix".br_respuesta
			  --WHERE institucion = CASE WHEN pInstitucion = "" THEN institucion  ELSE pInstitucion END
			  WHERE institucion = 'CC'  
			    AND num_solicitud IN (SELECT num_solicitud
                                        FROM "informix".br_traslado
		                               --WHERE institucion = CASE WHEN pInstitucion = "" THEN institucion  ELSE pInstitucion END 
		                               WHERE institucion = 'CC'  
                           AND numcte = vcliente);		
										 
	-- Respaldo br_respuesta_aprocesar									 
	INSERT INTO "informix".br_respuesta_aprocesar_hist(idrespuesta,institucion,numcte,num_solicitud,fecha_insert,status)
            SELECT idrespuesta,institucion,numcte,num_solicitud,fecha_insert,status
			   FROM "informix".br_respuesta_aprocesar
			  --WHERE institucion = CASE WHEN pInstitucion = "" THEN institucion  ELSE pInstitucion END
			  WHERE institucion = 'CC' 
			    AND num_solicitud IN (SELECT num_solicitud
                                        FROM "informix".br_traslado
		                               --WHERE institucion = CASE WHEN pInstitucion = "" THEN institucion  ELSE pInstitucion END
		                               WHERE institucion = 'CC'
			                             AND numcte = vcliente);	
	
		DELETE FROM "informix".br_traslado WHERE num_solicitud = pSolicitud AND institucion = 'CC';
		DELETE FROM "informix".sb_regreso WHERE num_solicitud = pSolicitud AND institucion = 'CC';

	--IPCB Mayo2016 Reingenieria de Demonios.
		DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = 'CC' AND  num_solicitud = pSolicitud;   
		DELETE FROM "informix".br_respuesta WHERE institucion = 'CC' AND num_solicitud = pSolicitud;
		
		--DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = 'CC' AND num_solicitud = pSolicitud;

	   			  
   END IF;
   
	--IF LENGTH(NVL(vcomentario,"")) = 0 THEN
	-- Se inserta trama que consume CC por producto 026 FJPR
	 INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
	  VALUES('CC',vcliente,pSolicitud,vregistro,vregistro1,vregistro2,0,vfecha);
		
    --ELSE
	 -- Se inserta trama que consume CC por producto 026 FJPR
	-- INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
	  --VALUES('CC',vcliente,pSolicitud,vregistro,vregistro1,vregistro2,3,vfecha);
	  
	 --INSERT INTO "informix".br_auditor VALUES(status_2,pSolicitud,vfecha,vhora,vcomentario);
  -- END IF;
	  
--FIN CAS CAMBIO DE ORDEN DE CONSULTA BURO Y CIRCULO
   --LET vexiste1 = 0;
   --LET vexiste = 10;

	--COMMIT WORK;
	/*IF wbegin = 'S' THEN
	    BEGIN WORK;
	END IF;*/
RETURN vcodret;

END;
END PROCEDURE
DOCUMENT

' Autor: Viridiana Osobampo' ,
' ModificaciÃÆÃÂ³n: Se valida el dato de tipo de vivienda del cliente en base a los' ,
'               nuevos valores asignados por la migaciÃÆÃÂ³n de catÃÆÃÂ¡logos, anteriormente' ,
'               ese dato contenÃÆÃÂ­a valores numÃÆÃÂ©ricos y cambio el identificador a letra.' ,
' Fecha de nodificaciÃÆÃÂ³n: 05-11-2009' ,
' Proyecto: Alta ÃÆÃÂ¡nica para liberaciÃÆÃÂ³n de paso 2.' ,
'----------------------------------------------------------------------------------' ,
' Autor: Viridiana Osobampo' ,
' ModificaciÃÆÃÂ³n: Se insertan datos a los campos creados en la tabla br_traslado' ,
' Fecha de nodificaciÃÆÃÂ³n: 17-03-2009' ,
' Proyecto: Caja Unica.' ,
'----------------------------------------------------------------------------------' ,
'  ModificÃÆÃÂ³:  Viridiana Osobampo',
 'ModificaciÃÆÃÂ³n: Se obtienen las siglas que corresponden al producto solicitado por ' ,
'                el cliente, mismas que se incluyen en la cadena de informaciÃÆÃÂ³n ' ,
'                enviada a las instituciones crediticias. ' ,
'  Fecha modificaciÃÆÃÂ³n: 14-09-2009.' ,
'  PeticiÃÆÃÂ³n: RQM 10 108 PrÃÆÃÂ©stamo Personal.' ,
'----------------------------------------------------------------------------------' ,
' ModificÃÆÃÂ³: JesÃÆÃÂºs Manuel Aguilar Heredia' ,
' ModificaciÃÆÃÂ³n: Se modifica para que cuando se recibe la sucursal en "0000" consulte la tabla sd_maecred de la base de datos bdicred, para obtener la informaciÃÆÃÂ³n de la solicitud' ,
' Fecha modificaciÃÆÃÂ³n: 01-11-2011.' ,
'PeticiÃÆÃÂ³n: Solicitud de Incremento de LÃÆÃÂ­nea de CrÃÆÃÂ©dito ' ,
'Version 1.00.000' ,
'MODIFICACION: se cambia para que reciba el parametro psucursal en 0001 al igual que el sp ins_consulta_buro que le manda esta cadena.' ,
'----------------------------------------------------------------------------------' ,
'AUTOR: Armando Morales' ,
'FECHA: Junio 2012' ,
'VERSION: 20120612.1010' ,
'BD    : BDIBURO' ,
'----------------------------------------------------------------------------------' ,
'Autor: JosuÃÆÃÂ© Remberto Zazueta Acosta' ,
'ModificaciÃÆÃÂ³n: Se borra cÃÆÃÂ³digo comentado,se agregan informix y bd a las tablas que no tenÃÆÃÂ­an,Se implementan reglas', 'de informix' ,
'Fecha de modificaciÃÆÃÂ³n: 02/Octubre/2012' ,
'BD : bdicred' ,
'----------------------------------------------------------------------------------' ,
'Autor: Marco Antonio Valenzuela LeÃÆÃÂ³n' ,
'ModificaciÃÆÃÂ³n: Se cambia en la parte donde se almacena el RFC para que guarde como primera opciÃÆÃÂ³n el campo rfc_alterno sino trae informaciÃÆÃÂ³n que guarde con el campo rfc como anteriormente lo hacÃÆÃÂ­a' ,
'Fecha de modificaciÃÆÃÂ³n: 22/Marzo/2013' ,
'Version: 20130322.1547' ,
'BD : bdiburo' ,
'----------------------------------------------------------------------------------' ,
'MODIFICO: CARLOS OCHOA VALENZUELA' ,
'DESCRIPCION: SE MODIFICAN VALIDACIONES PARA TRABAJAR CON SOLICITUDES DE INCREMENTO DE LINEA, YA QUE ANTERIORMENTE SE TRABAJABA SOLO CON SOLICITUDES DE CRÃÆÃ¢â¬Â°DITO' ,
'FECHA: MAYO-2013' ;

CREATE PROCEDURE "informix".actualizarregistroburo( pInstitucion char(2),pnum_solicitud char(20), pStatus char(1), pComentario char(80))

RETURNING char(6);


DEFINE cCodRet     CHAR(6);
DEFINE iSqlErr int;

LET iSqlErr = 0;
LET cCodRet = "000000";

SET ISOLATION TO dirty read;
SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET iSqlErr
       if iSqlErr <> 0 then
         LET cCodRet = iSqlErr;
          RETURN cCodRet;
       end if
    END EXCEPTION;
    
    UPDATE bdiburo:br_traslado SET status = pStatus, fecha_insert=today WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
    DELETE bdiburo:sb_regreso WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
--IPCB Mayo2016 Reingenieria de Demonios.
    DELETE FROM bdiburo:br_respuesta WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;
    DELETE FROM bdiburo:br_respuesta_aprocesar WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud;   
    DELETE FROM bdiburo:br_respuesta_aprocesar_aux WHERE institucion = pInstitucion AND num_solicitud = pnum_solicitud; 	
--IPCB Mayo2016 Reingenieria de Demonios.
    UPDATE bdiburo:br_auditor SET comentario = pComentario   WHERE institucion = pInstitucion AND solicitud = pnum_solicitud;

    RETURN cCodRet;

END

END PROCEDURE;
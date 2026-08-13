CREATE PROCEDURE "informix".sp_validacodprodlineacred (chempresa char (3))
returning char (5),char(50);

DEFINE iSqlErr          		INTEGER;
DEFINE iIsamErr         		INTEGER;
DEFINE cInfoErr					CHAR(100);
DEFINE cCodret          		CHAR(5);
DEFINE cMensRet         		CHAR(50);
DEFINE cEmpresa          		CHAR(3);
DEFINE vnum_tarjeta				CHAR (16);
DEFINE vcodproductotarjeta    	CHAR(3);
DEFINE vmaesdos_otorgado		DECIMAL(18,2);
DEFINE vsegcodproductotarjeta   CHAR(3);
DEFINE vseglimite_min           DECIMAL(19,4);
DEFINE vseglimite_max           DECIMAL(19,4);
DEFINE vmarca                   CHAR(2);
DEFINE vbin                     CHAR(6);
DEFINE vsubbin                  CHAR(2); --Nueva variable
DEFINE vsegbin                  CHAR(6);
DEFINE icommit					INTEGER;
DEFINE vFechaCarga              DATE;
DEFINE vFechaCargaVal           CHAR(25);

  --Set debug file to "/informix/LDBZ/sp_validacodprodlineacred.out";
  --trace on;
 
 -- Base de Datos: intercard
	-- Fecha de modificacion: 14 de Marzo de 2023
	-- Autor: Luis Daniel Bautista Zamora 
	-- Comentario: Se agregan validaciones para evitar extraer registros dobles en consulta con lÃ­mites de crÃ©ditos iguales debido a nuevo producto infinite.
	-- Se implementa uso de tabla temporal para filtrar informacion y disminuir los altos costos de ejecucion.

LET cInfoErr 				= '';
LET cCodret 				= '00000';
LET cMensRet 				= 'Ejecucion sp_validacodprodlineacred exitosa.';
LET cEmpresa 				= chempresa;
LET vnum_tarjeta			= '';
LET vcodproductotarjeta    	= '';
LET vmaesdos_otorgado 		= 0;
LET vsegcodproductotarjeta  ='';
LET vseglimite_min          = 0;
LET vseglimite_max          = 0;
LET vmarca                  = '';
LET vbin                    = '';
LET vsubbin                 = '';  --Se incializa variable
LET vsegbin                 = '';
LET icommit 				= 0;
LET vFechaCarga             = CURRENT;


	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
					--Set debug file to "/RESPALDOSNEW/sp_validacodprodlineacred_exception.out";
					--trace on;
				RETURN cCodret,cMensRet;
			END IF;
		END EXCEPTION;

		
		DROP TABLE IF EXISTS tmp_tarjcodproducto;
		DROP TABLE IF EXISTS tmp_tarjeta;
/*-----------------------------------------------------------------------------------------------------------------
			PROCESO DE DESCARGA DE REGISTROS CON AUMENTO EN LINEA DE CREDITO DEL MES ANTERIOR (T-1):
-----------------------------------------------------------------------------------------------------------------*/

		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT   MAX(fecha_ejecucion)    
			INTO vFechaCarga
		FROM intercard:bitacoraprocesosejec
		WHERE idproceso='VALIDACODPRODTAR'
		AND estatus='TERMINADO';
	
		
		LET  vFechaCargaVal =  YEAR(vFechaCarga)||'-'||LPAD(MONTH(vFechaCarga),2, '0')||'-'||LPAD(DAY(vFechaCarga),2,'0')|| ' ' ||'00:00:00.00000';
		
		/*---------------------------------------------------------------------
		CARGA DE LA INFORMACION DE LA TABLA tarjeta a tmp_tarjeta
		----------------------------------------------------------------------*/
		SELECT numtarjeta,codstatustarjeta,codproductotarjeta,fechaasignacion,codstatusasignada FROM tarjeta
		WHERE  fechaasignacion >= vFechaCargaVal
		AND codstatustarjeta in ('ACT','INA')
		AND codstatusasignada = 'SIA'
		AND fechaexp >= vFechaCargaVal
		
		--AND substr(numtarjeta,1,6)= '426807'
		INTO TEMP tmp_tarjeta WITH NO LOG;
-------------------------------------------------------------------------------------------------------
		SELECT  
		t.numtarjeta,t.codproductotarjeta,sdm.num_credito,sdm.monto_otorgado,bi.bin--,bi.marca RQI 13 722
	    FROM tmp_tarjeta t
		INNER JOIN bdicred:sd_tarjeta sdt
		ON t.numtarjeta=sdt.num_tarjeta
		INNER JOIN bdicred:sd_maesdos sdm
		ON sdt.num_credito=sdm.num_credito
        INNER JOIN intercard:bines bi
		ON substr(t.numtarjeta,1,6)=bi.bin
		WHERE sdt.empresa='001'
		INTO TEMP tmp_tarjcodproducto with no log;


--{+ INDEX (intercard:"informix".tarjeta idx_tarjeta1) } RQI 13 722
		--{+ INDEX (intercard:"informix".tarjeta idx_tbl_tjta_codstatustarjeta) }
		--{+ INDEX (intercard:"informix".tarjeta idx_tbl_tjta_codstatusasignada) }	
		
/*-----------------------------------------------------------------------------------------------------------------
			PROCESO DE VALIDACION DE LINEAS DE CREDITO:
-----------------------------------------------------------------------------------------------------------------*/
		FOREACH WITH HOLD
			SELECT numtarjeta,codproductotarjeta,monto_otorgado/*,marca*/,bin,SUBSTR (numtarjeta,7,2)
				INTO vnum_tarjeta,vcodproductotarjeta,vmaesdos_otorgado/*,vmarca*/,vbin,vsubbin
			FROM tmp_tarjcodproducto
			
			SELECT 
			--{+AVOID_FULL (intercard:binproducto)}  RQI 13 722
			--{+ INDEX (intercard:"informix".segmentoproducto idx_sgmtoprod) } RQI 13 722
			DISTINCT sp.codproductotarjeta,limite_min,limite_max,bi.bin
				INTO vsegcodproductotarjeta,vseglimite_min,vseglimite_max,vsegbin
			FROM intercard:segmentoproducto sp
            INNER JOIN intercard:binproducto bp
            ON sp.codproductotarjeta=bp.codproductotarjeta
            INNER JOIN intercard:bines bi 
            ON bp.bin=bi.bin
            INNER JOIN tmp_tarjcodproducto tmp
            ON  SUBSTR (vnum_tarjeta,7,2)=(select pi.producto 
                from intercard:tipotarjeta tt
                join intercard:productoimagen pi
                on tt.clave = pi.clave
                where tt.bin = '426807'
                and pi.producto= vsubbin)
			WHERE tipo_producto='C'
			--AND sp.codproductotarjeta=001
			--AND bi.marca='VS'
			AND bi.bin= '426807'
            and SUBSTR (vnum_tarjeta,7,2)=bp.producto
			AND limite_min <= vmaesdos_otorgado
			AND limite_max >= vmaesdos_otorgado;
			--GROUP BY 1,2,3;
			---------------------------------------------------------------------------------------------------------------------------
			
			
			----------------------------------------------------------------------------------------------------------------------------
			BEGIN WORK;
				if icommit = 1000
					then
						COMMIT WORK;
						LET icommit = 0;
						CONTINUE FOREACH;
					else
				end if;
				
			IF vcodproductotarjeta!=vsegcodproductotarjeta and vbin=vsegbin THEN
						UPDATE intercard:tarjeta set codproductotarjeta=vsegcodproductotarjeta
						WHERE numtarjeta=vnum_tarjeta;
	    					LET icommit = icommit+1;
			END IF
			
				
			/*IF vmarca='VS' THEN 
					IF vcodproductotarjeta!=vsegcodproductotarjeta THEN
						UPDATE intercard:tarjeta set codproductotarjeta=vsegcodproductotarjeta
						WHERE numtarjeta=vnum_tarjeta;
					END IF
			ELSE IF vmarca='MC' THEN
					IF vcodproductotarjeta!=vsegcodproductotarjeta THEN
						UPDATE intercard:tarjeta set codproductotarjeta=vsegcodproductotarjeta
						WHERE numtarjeta=vnum_tarjeta;
					END IF
			END IF;*/
				
			COMMIT WORK;				
			
			
					
		END FOREACH;
		
		BEGIN;
		INSERT INTO intercard:bitacoraprocesosejec (idproceso,fecha_ejecucion,fechahora_ultejecucion,estatus,descripcion,usuario)
			VALUES ('VALIDACODPRODTAR',CURRENT,CURRENT,'TERMINADO','Proceso que valida codigo de producto de las tarjetas asignadas','informix');
		COMMIT;

		

		RETURN cCodret,cMensRet;

    END;
END PROCEDURE
--'BD: intercard'
--'AUTOR: Edgar Ivan Cisneros Yescas'
--'Proyecto: RQI 10 1017 Actualizacion de producto INTERCARD'
--'Fecha: 2018/05/04'
--''
--'AUTOR: Marcos Gerardo Ayala Ponce'
--'Proyecto: RQI 13 722 - OptimizaciÃÂ³n sp_validacodprodlineacred
--'Fecha: 2020/07/14'
--'BD: intercard - JOB 630'
;

CREATE PROCEDURE "informix".sp_carga_info_conciliacion_dep(vArchivoDBLOAD CHAR(100), RUTA CHAR(100))

	RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	-- Define Var Init Var Control 
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE vNombreCompTXT		VARCHAR(100);
	DEFINE vNombreCompLog		VARCHAR(100);
	DEFINE vNombreEjecucionLog  VARCHAR(100);
	DEFINE nomArch              VARCHAR(100);
	DEFINE nomRut		    	VARCHAR(100);
	
	-- Define Var EXCEPTION
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Init Var Control
	LET nomRut = TRIM(RUTA);
	LET nomArch = vArchivoDBLOAD;
	LET vIntervaloCommit = 1000;
	LET vExecuteSQL	='';
	LET vNombreCompTXT = TRIM(nomRut) || "/dbload_archivo_conciliacion_stat06_dep.txt";
	LET vNombreCompLog = TRIM(nomRut) || "/dbload_archivo_conciliacion_stat06_dep.log";
	LET vNombreEjecucionLog = TRIM(nomRut) || "/dbload_archivo_conciliacion_stat06_dep_rep.log";
	
	-- Init Var Exception
	LET vCodigoRetorno = '00000';
	LET vMensaje = '';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	BEGIN 
		-- Flujo de Excepciones
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
					
			SET DEBUG FILE TO RUTA || "carga_.err.out";
			TRACE ON;
			
			IF ( SQLERR <> 0 ) THEN
				LET vCodigoRetorno = SQLERR;
				LET vMensaje = ERROR_INFO;                
				RETURN vCodigoRetorno, vMensaje;
			END IF;
					
		END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Termina Flujo de Exepciones 			
		
		-- Comienza Load de archivo 
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(nomRut) || '/' || TRIM(nomArch)|| "' delimiter '"|| '|' ||"' "|| '39'||
					"; INSERT INTO "|| 'conciliacion_atm_stat06_depositadores' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
		LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vIntervaloCommit ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL; 
		
		LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';

		RETURN vCodigoRetorno, vMensaje;
	END;
END PROCEDURE;
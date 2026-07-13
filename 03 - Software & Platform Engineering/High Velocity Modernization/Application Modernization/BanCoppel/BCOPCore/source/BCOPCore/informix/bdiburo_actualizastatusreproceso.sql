CREATE PROCEDURE "informix".actualizastatusreproceso(pInstitucion CHAR(2), pNumSolicitud CHAR (20))
	RETURNING CHAR(5) AS codret;

	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/actualizastatusreproceso.out';
		--TRACE ON;
		
		IF pInstitucion = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00002';
			RETURN cCodRet;
		END IF;
	
		UPDATE bdiburo:'informix'.br_traslado
			   SET status = 0
			   WHERE institucion = pInstitucion AND num_solicitud = pNumSolicitud;
		
		DELETE FROM bdiburo:"informix".br_traslado_reproceso
			   WHERE institucion = pInstitucion AND num_solicitud = pNumSolicitud;
			   
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;		
		RETURN cCodRet;
	END;	
END PROCEDURE	

DOCUMENT 'AUTOR: M.D.S. Sandra Cano',
'FECHA: 26/03/2016',
'MODULO: DEMONIO',
'FUNCIONALIDAD: REPROCESO DE SOLICITUDES',
'DESCRIPCION:SPL que actualiza solicitudes para que sean reprocesadas por el demonio. Es ejecutado por el trigger tggreproceso',
'BD: bdiburo';

CREATE PROCEDURE "informix".sp_cons_envios_error(pInstitucion CHAR(2), pFechaInicio CHAR(10), pFechaFin CHAR(10), pRecuperacion INTEGER, pRegistros INTEGER, pPaginado INTEGER )
RETURNING CHAR(5) AS codret,
			DATE AS fecha,
			CHAR (800) AS descripcion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFecha DATE;
	DEFINE cDescripcion CHAR (800);
	DEFINE iNoRegistros INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	--LET dFecha = '';
	--LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/RESPALDOS/ipcb/tasf/sp_cons_envios_error.out';
		--TRACE ON;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			LET dFecha = '';
			LET cDescripcion = '';
			RETURN cCodRet, dFecha, cDescripcion;
		END IF;
		
		--TRACE 'Fecha Inicio'|| pFechaInicio;
		
		--TRACE 'Fecha Fin'|| pFechaFin;
		
		if pPaginado = 0 THEN
			FOREACH SELECT fecha_insert, trim(envio)||trim(envio1)||trim(envio2) descrip
						INTO dFecha, cDescripcion
						FROM bdiburo:"informix".br_traslado 
						WHERE fecha_insert >=  pFechaInicio AND fecha_insert <= pFechaFin and status = 3
						
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, dFecha, cDescripcion WITH RESUME;		
			END FOREACH;		
		ELIF pPaginado = 1 THEN
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion  fecha_insert, trim(envio)||trim(envio1)||trim(envio2) descrip
						INTO dFecha, cDescripcion
						FROM bdiburo:"informix".br_traslado 
						WHERE fecha_insert >=  pFechaInicio AND fecha_insert <= pFechaFin and status = 3
						
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, dFecha, cDescripcion WITH RESUME;		
			END FOREACH;
		END IF;	
		
		--IF iNoRegistros = 0 AND pRegistros = 0 THEN
		--		LET cCodRet = '00017';
		--		RETURN cCodRet, dFecha, cDescripcion;
		--ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
		--	LET cCodRet = '1001';
		--	RETURN cCodRet, dFecha, cDescripcion;
		--END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Julio Martinez',
'FECHA:17/05/2016',
'MODULO: Demonio  ',
'FUNCIONALIDAD: Consulta tramas de Envio',
'DESCRIPCION: Consulta de las tramas de envio.',
'BD: bdiburo';

CREATE PROCEDURE "informix".ins_buro_credito_aumlincred( pInstitucion CHAR(2),pempresa CHAR(3), 
pnum_solicitud CHAR(20), pnum_cliente CHAR(20),pfecha DATE, pfecha_hoy DATE, pcadena CHAR(250), pitem_cadena INT, ppaso VARCHAR(10), pRelanzar SMALLINT)
RETURNING CHAR(1); -- Bandera si continua o espera a Buró
--------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Modificación: Se crea espejo  de proceso productivo, mismo que sera usado para incrementos de lineas de credito.
-- Fecha de Creacion: 27-10-2011.
-- Proyecto: Incrementos de linea 
--------------------------------------------------------------------------------
DEFINE mIngresoMensual MONEY(14,2);
DEFINE dCompromisos DECIMAL(14,2);
DEFINE vMensaje     VARCHAR(255);
DEFINE cCalifica    CHAR(1);
DEFINE sql_err      INT;
DEFINE cod_ret      CHAR(6);
DEFINE s_regreso    CHAR(1);
DEFINE iMontoBuro   INT;
DEFINE usuario_cir  VARCHAR(50);
DEFINE passwd_cir   VARCHAR(50);
DEFINE usuario_bur  VARCHAR(50);
DEFINE passwd_bur   VARCHAR(50);
DEFINE usu_orden1   CHAR(10);
DEFINE usu_orden2   CHAR(10);
DEFINE pass_orden1  CHAR(8);
DEFINE pass_orden2  CHAR(8);
DEFINE status_1      CHAR(2);
DEFINE status_2      CHAR(2);
DEFINE mensaje_orden VARCHAR(255,1);
DEFINE Relanzar SMALLINT;
DEFINE csolicitud    CHAR(20);
DEFINE corigen       CHAR(1);
DEFINE cEnvio        CHAR(1);
DEFINE v_mod_parame  CHAR(1);
DEFINE tipo_acceso_bc CHAR (03);
DEFINE dtFechaInsert DATE;
DEFINE cCodRetResp CHAR (6);
DEFINE cMensajeResp CHAR (20);
--set debug file to "/pisa/cas/ins_buro_credito_aumlincred.unl";
--trace on;
LET s_regreso = '0';
LET status_1='00';
LET status_2='00';
LET Relanzar=pRelanzar;
LET csolicitud = "";
LET corigen    = "";
LET cEnvio     = "0";
LET v_mod_parame="";
LET tipo_acceso_bc = "";
LET dtFechaInsert = DATE(1);
LET cCodRetResp = "";
LET cMensajeResp = "";
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---clave de circulo
SELECT valor
INTO usuario_cir  
FROM bdiburo:"informix".br_param
WHERE cod_param=1;

SELECT valor
INTO passwd_cir 
FROM bdiburo:"informix".br_param
WHERE cod_param=2;

---clave de buro
SELECT valor
INTO usuario_bur
FROM bdiburo:"informix".br_param
WHERE cod_param=124;

SELECT valor
INTO passwd_bur  
FROM bdiburo:"informix".br_param
WHERE cod_param=125;

--ini CAS se adapta para hacer un cambio de orden entre buro y circulo.
SELECT status_solicitud
INTO status_1
FROM bdisolic:"informix".ss_status_sol 
WHERE empresa=pempresa 
AND tipo_auto='1';

SELECT status_solicitud
INTO status_2
FROM bdisolic:"informix".ss_status_sol 
WHERE empresa=pempresa 
AND tipo_auto='2';

IF status_1='BC' THEN
	LET usu_orden1=usuario_bur;
	LET usu_orden2=usuario_cir;
	LET pass_orden1=passwd_bur;
	LET pass_orden2=passwd_cir;
ELSE
	LET usu_orden1=usuario_cir;
	LET usu_orden2=usuario_bur;
	LET pass_orden1=passwd_cir;
	LET pass_orden2=passwd_bur;
END IF;
--ini CAS se adapta para hacer un cambio de orden entre buro y circulo.
BEGIN
    ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
          INSERT INTO "informix".br_cadena_error_bc VALUES (pInstitucion,pnum_cliente,pfecha, sql_err,ppaso,
          pitem_cadena,SUBSTR(pcadena,1,pitem_cadena + 10),pfecha_hoy);
          RETURN '9';
       END IF
    END EXCEPTION;

--SET DEBUG FILE TO "ins_buro_credito.out";
--TRACE ON;

SELECT MAX(fecha_insert)
INTO dtFechaInsert
FROM bdicred:"informix".sd_bitacora_aumlincred 
WHERE  empresa = '001' 
AND num_solicitud = pnum_solicitud;


    IF pRelanzar = 0 AND pInstitucion = status_1 THEN

        SELECT NVL(ingreso_mensual,0) INTO mIngresoMensual
        FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = pnum_solicitud;

        SELECT valor::INT  INTO iMontoBuro  FROM bdisolic:"informix".ss_param WHERE secuencia = '326';

        IF NVL(mIngresoMensual,0) >= iMontoBuro AND pInstitucion = status_1 THEN  		
-- Se obtienen las solicitudes que el cliente tiene en espera de ser calificada con la respuesta de Buró y/o Círculo
-- de crédito y se evalúa cada una respecto al producto de crédito que se trate y continúa su flujo una solicitud 
-- independiente de la otra. 
   FOREACH
            SELECT num_solicitud,TRIM(tipo_calculo)
              INTO csolicitud,v_mod_parame
              FROM bdisolic:"informix".ss_solicitudes
             WHERE empresa = pEmpresa
                 AND num_solicitud = pnum_solicitud
               AND status_solicitud = "AP"
             ORDER BY num_producto

                    EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pempresa, pnum_cliente,csolicitud)
                       INTO cod_ret, cCalifica, dCompromisos, vMensaje;
                     

                IF cod_ret <> "000" THEN
                    RETURN '9';
                END IF 	
/*		
		IF  (cCalifica = 'X' AND v_mod_parame in('1','2')) THEN
            
                    IF s_regreso = '0' THEN

                        IF (status_2='BC') THEN
                            SELECT trim(valor) INTO tipo_acceso_bc
                              FROM bdiburo:"informix".br_param
                              WHERE cod_param = 126;                            

                            INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
                            SELECT status_2, pnum_cliente,csolicitud,  SUBSTR(envio,1,31)||tipo_acceso_bc||SUBSTR(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(SUBSTR(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
                            num_solicitud = pnum_solicitud;
                        ELSE
                            INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
                            SELECT status_2, pnum_cliente,csolicitud,  SUBSTR(envio,1,31)||'001'||SUBSTR(envio,35,6)||trim(usu_orden2)||trim(pass_orden2)||trim(SUBSTR(envio,59,1000)), envio1, envio2, '0',pfecha_hoy FROM br_traslado WHERE institucion = status_1 AND
                            num_solicitud = pnum_solicitud;
                        END IF;
                       
                        IF csolicitud = pnum_solicitud THEN
                            LET s_regreso = '1';
                        ELSE
                            LET s_regreso = '0';
                        END IF;            
						UPDATE bdicred:"informix".sd_bitacora_aumlincred 
							SET status          = status_2,
							causa_status 	= "",
							fecha_status    = today,
							hora_status     = CURRENT
						WHERE fecha_insert  = dtFechaInsert
						AND numcte          = pnum_cliente
						AND num_solicitud   = pnum_solicitud
						AND empresa         = pEmpresa;			

						INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
						VALUES(pEmpresa, pnum_solicitud, status_2, "", USER, pfecha, pfecha, 0);

						UPDATE bdicred:"informix".sd_solicitudes_aumlincred_sucursal 
							SET institucion     = status_2,
								status 			= status_2,
								fecha_envio     = today,
								fecha_respuesta = NULL
						WHERE numcte          = pnum_cliente
						AND num_credito   = pnum_solicitud
						AND empresa         = pEmpresa
						AND (fecha_respuesta >= TODAY - 7 or fecha_respuesta IS NULL);		
					ELSE
						UPDATE bdicred:"informix".sd_solicitudes_aumlincred_sucursal 
							SET fecha_respuesta = TODAY
						WHERE numcte  = pnum_cliente
						AND num_credito = pnum_solicitud
						AND empresa = pempresa
						AND fecha_respuesta IS NULL;						
					END IF
        END IF
*/
     END FOREACH
-- fin caja unica
	END IF
    ELIF pRelanzar = 1 AND pInstitucion = status_1 THEN
            CALL bdiburo:"informix".burocred (pempresa, "0000", "CC", pnum_solicitud, 0)
            RETURNING cod_ret;              
            LET s_regreso = '1';
    ELSE
        IF pRelanzar = 1 AND pInstitucion = status_2 THEN
            DELETE FROM "informix".br_traslado WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
            DELETE FROM "informix".sb_regreso WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
--IPCB Mayo2016 Reingenieria de Demonios.
            DELETE FROM "informix".br_respuesta WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;
            DELETE FROM "informix".br_respuesta_aprocesar WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;   
            DELETE FROM "informix".br_respuesta_aprocesar_aux WHERE institucion = status_2 AND num_solicitud = pnum_solicitud;   			
--IPCB Mayo2016 Reingenieria de Demonios.
            --ini cas
               DELETE FROM bdiburo:"informix".br_cr WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_hi WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_hr WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_iq WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_pa WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_pe WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_pn WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_rs WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_sc WHERE institucion = status_2 AND num_cliente= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_tl WHERE institucion = status_2 AND num_cliente= pnum_cliente;
			   
			 	   
			   DELETE FROM bdiburo:"informix".br_cr_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_hi_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_hr_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_iq_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_pa_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_pe_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_pn_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_rs_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_sc_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
               DELETE FROM bdiburo:"informix".br_tl_bc WHERE institucion = status_2 AND numcte= pnum_cliente;
			   
            --fin cas
           

            INSERT INTO "informix".br_traslado (institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
            SELECT status_2, pnum_cliente,num_solicitud,  trim(SUBSTR(envio,1,40))||trim(usu_orden2)||trim(pass_orden2)||trim(SUBSTR(envio,59,1000)), envio1, envio2, '0',pfecha_hoy 
			FROM br_traslado WHERE institucion = status_1 AND  num_solicitud = pnum_solicitud;  

			UPDATE bdicred:"informix".sd_bitacora_aumlincred 
				SET status      = status_2,
				causa_status 	= "",
				fecha_status    = today,
				hora_status     = CURRENT
			WHERE fecha_insert  = dtFechaInsert
			AND numcte          = pnum_cliente
			AND num_solicitud   = pnum_solicitud
			AND empresa         = pEmpresa;					
			
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
			VALUES(pEmpresa, pnum_solicitud, status_2, "", USER, pfecha, pfecha, 0);
			
			UPDATE bdicred:"informix".sd_solicitudes_aumlincred_sucursal 
				SET institucion     = status_2,
					status 			= status_2,
					fecha_envio     = today,
					fecha_respuesta = null
			WHERE numcte          = pnum_cliente
			AND num_credito   = pnum_solicitud
			AND empresa         = pEmpresa
			AND (fecha_respuesta >= TODAY - 7 or fecha_respuesta IS NULL);	
            LET s_regreso = '1';
        END IF
    END IF

RETURN s_regreso;
END;
END PROCEDURE document "Version 1.00.000";

create procedure "informix".sp_rep_numsol_bc()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);

DEFINE v_ultimo_mes       DATE;
DEFINE v_primero_mes        DATE;
DEFINE vano                 CHAR(04);
DEFINE vmes                 CHAR(02);
DEFINE vdia                 CHAR(02);
DEFINE vfecha_reporte        CHAR(08); 

DEFINE vsql                 CHAR(1500);

DEFINE cruta                CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE vtipo                CHAR(4);
DEFINE vdescripcion         CHAR(40);
DEFINE vtotal               INTEGER;
DEFINE total 			INTEGER;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET cruta                   = "";
LET cnomarchivo             = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;

--SET DEBUG FILE TO "sp_rep_numsol_bc.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

select pri_dia_mes -1, pri_dia_mes -  1 units month
into v_ultimo_mes,v_primero_mes
from bdicred:sd_fechas
where empresa = '001';

--temporal para pruebas
   --let v_ultimo_mes = mdy('07','31','2014');
   --let v_primero_mes  = mdy('07','01','2014');
--temporal para pruebas

   let vano = year(v_ultimo_mes);
   let vmes = lpad(month(v_ultimo_mes),2,"0");
   let vdia = lpad(day(v_ultimo_mes),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

select valor
INTO cruta
from bdiburo:br_param
where cod_param = 139;

select valor||vfecha_reporte||'.txt'
INTO cnomarchivo
from bdiburo:br_param
where cod_param = 140;


SELECT unique a.num_solicitud,a.numcte,a.fecha_insert,fecha_hora,status_solicitud,b.num_solicitud_sic
FROM bdisolic:ss_solicitudes a inner join bdisolic:ss_solicitudes_sic b
  on a.numcte = b.numcte
 and a.num_solicitud = b.num_solicitud 
 and b.fecha_insert >= v_primero_mes  and b.fecha_insert <= v_ultimo_mes
WHERE a.fecha_insert >= v_primero_mes and a.fecha_insert <= v_ultimo_mes
into temp sol_sics with no log;  

begin;
CREATE INDEX idx_sol_sics ON sol_sics(num_solicitud_sic) ONLINE;
commit;

select case when substr (num_solicitud,1,2) = '60' then substr (num_solicitud,1,2)||'01'
            else  substr (num_solicitud,1,2)||'00' end tipo, count(*) tot_consultas
from bdiburo:sb_regreso
where num_solicitud in (select num_solicitud_sic from sol_sics )--where substr(num_solicitud_sic,1,2) in('60','63','64','70'))
and substr (regreso,1,4) = 'INTL'
group by 1
into temp numero_solicitudes_previo with no log; 

--IPCB Mayo2016 Reingenieria de Demonios.
insert into  numero_solicitudes_previo
select case when substr (num_solicitud,1,2) = '60' then substr (num_solicitud,1,2)||'01'
            else  substr (num_solicitud,1,2)||'00' end tipo, count(*) tot_consultas
from bdiburo:br_respuesta
where num_solicitud in (select num_solicitud_sic from sol_sics )--where substr(num_solicitud_sic,1,2) in('60','63','64','70'))
and secuencia = 1 
and substr (regreso,1,4) = 'INTL'
group by 1;

select tipo,sum( tot_consultas) tot_consultas
from numero_solicitudes_previo
group by 1
into temp numero_solicitudes with no log; 
--IPCB Mayo2016 Reingenieria de Demonios.

  --Ejecuta para poner Titulo al archivo.
  LET vsql='';
   LET vsql = 'echo "             REPORTE DE SOLICITUDES DE CRÉDITO" >'||TRIM(cruta)|| cnomarchivo;
  SYSTEM vsql; 

    --Ejecuta para poner periodo.
	LET vsql='';
        LET vsql = 'echo "PERIODO: '||v_primero_mes||' al '||v_ultimo_mes||'" >> '||TRIM(cruta)|| cnomarchivo;
   SYSTEM vsql; 
  --Ejecuta para poner encabezados.
	LET vsql='';
                LET vsql = 'echo "CLAVE'||' '||'             PRODUCTO                 '||' '||'# DE CONSULTAS'||'" >>'||TRIM(cruta)|| cnomarchivo;
   SYSTEM vsql; 

 let total =0;
foreach with hold
  select tipo,descrip_prod,tot_consultas 
INTO vtipo,vdescripcion,vtotal
    from numero_solicitudes a inner join bdicred:sd_tipprod b
      on abrevia_prod = tipo

	LET vsql='';
    LET vsql = 'echo "  '||vtipo||'    '||vdescripcion||vtotal||'" >> '||TRIM(cruta)|| cnomarchivo;	
  system vsql;

 let total = total +vtotal;
end foreach

 --Ejecuta para poner total de solicitudes
	LET vsql='';
        LET vsql = 'echo "			                   TOTAL   '||total||'" >> '||TRIM(cruta)|| cnomarchivo;
   SYSTEM vsql; 

LET cCodRet     = "000000";
LET cMensajeRet = "Reporte de solicitudes a BC "||vfecha_reporte|| " Ok.";

	RETURN cCodRet, cMensajeRet; 

END;
end procedure;
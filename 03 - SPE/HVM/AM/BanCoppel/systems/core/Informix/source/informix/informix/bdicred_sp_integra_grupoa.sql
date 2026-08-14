CREATE PROCEDURE "informix".sp_integra_grupoa(cEmpresa CHAR(3), p_producto CHAR(4))
    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,              
              CHAR(25) AS StorePro;              

DEFINE vsqlerr          INTEGER; 
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

DEFINE v_codigo_retorno	CHAR(5);
DEFINE v_mensaje	  	CHAR(80);
DEFINE v_store_pro      CHAR(25);

DEFINE dtFechaHoy       DATE;
DEFINE dtFechaProx      DATE;
DEFINE dtFechaFinMes    DATE;

DEFINE vc_crdcontproc 	CHAR(1);
DEFINE vc_intcontproc 	CHAR(1);
DEFINE vc_status_prev 	CHAR(1);
DEFINE vc_tipoproceso   CHAR(20);

DEFINE vc_numcte        CHAR(20); 
DEFINE vc_statuscred    CHAR(2);

DEFINE vc_numproducto   CHAR (4);
DEFINE vd_mautorizado   DECIMAL(18,2);

DEFINE vc_numcred_dist  CHAR(20);

DEFINE vd_porce_uso     DECIMAL(5,2);
DEFINE vi_histo_efic    INTEGER;
DEFINE vf_fecha_status  DATE;

DEFINE vc_motivo        CHAR(50); 
DEFINE vrowid           INTEGER;
DEFINE vi_rowid         INTEGER;
DEFINE vc_productos     CHAR(30);
--DEFINE vs_DiaEjecTdc    SMALLINT;

LET vc_intcontproc  = '';
LET vc_crdcontproc  = '';
LET vc_status_prev  = '';

LET vc_numcred_dist = '';
LET vc_numcte       = ''; 
LET vc_statuscred   = '';
LET vc_numproducto  = '';
LET vd_mautorizado  =  0; 
LET vc_motivo       = ''; 

LET vd_porce_uso    = 0;
LET vi_histo_efic   = 0;
LET vf_fecha_status = DATE(1);

LET v_codigo_retorno = "00000";
LET v_mensaje       = "Proceso Inicia Correctamente";
LET v_store_pro     = 'sp_integra_grupoa';
LET vc_tipoproceso  = 'IntegraGpoA_' || p_producto;
LET vrowid          = 0;
LET vi_rowid        = 0 ;
LET vc_productos    = '';
--LET vs_DiaEjecTdc   = 0;

--SET DEBUG FILE TO "/informix/mahr/sp_integra_grupoa_" ||p_producto ||".out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr ,iIsamErr,cErrorInfo         
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = vsqlerr;
            LET v_mensaje = cErrorInfo;
            LET v_store_pro = 'sp_integra_grupoa';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
        END IF;
    END EXCEPTION;


    --**********************************************************************************************--
	-- Creado por: Francisco Martínez Viveros	
	--Fecha Creacion: 27/JUNIO/2012 // Fecha Modifica: 12/NOVIEMBRE/2012, 25/ENERO/2013, 31/ENERO/2013
	--Objetivo: Integrar y filtrar a los Clientes con uno o mas productos de credito de la tabla sd_grupo_credito, en ambos productos debe estar vigente.
    --          si no esta vigente, se manda al historico solo el q no cumpla con grupo A y el resto de los productos se eliminan de Cliente y Creditos.
    --**********************************************************************************************--
  
    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = cEmpresa;

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc
     WHERE fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE INTEGRACION GRUPO_A: "||p_producto||", YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_integra_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_crdcontproc='F') THEN
        LET v_codigo_retorno = "00032";
        LET v_mensaje="PROCESO DE INTEGRACION GRUPO_A: "||p_producto||", YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_integra_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    IF (vc_intcontproc IS NULL) THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
               VALUES ('001',vc_tipoproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;  
    IF (vc_crdcontproc IS NULL) THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
               VALUES ('001',vc_tipoproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Integrando GrupoA - Inicia');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA' WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    END IF;

    -- Obtiene fecha de ejecución para TDC, ya que para este producto (6001), solo se ejecuta una vez al mes.
    -- SELECT valor::smallint INTO vs_DiaEjecTdc FROM "informix".sd_param WHERE empresa = '001' AND cod_param = '58';

    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_grupo_cliente;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_grupo_credito;

    FOREACH cursor_inserta WITH HOLD FOR
        --  SELECT distinct(num_credito), numcte, status_cred
        SELECT rowid, num_credito, numcte, status_cred, monto_autorizado, num_producto, porcentaje_uso, num_historia_efic, fecha_status
          INTO vi_rowid, vc_numcred_dist, vc_numcte,  vc_statuscred, vd_mautorizado, vc_numproducto, vd_porce_uso, vi_histo_efic, vf_fecha_status
          FROM bdicred:"informix".sd_grupo_credito
         WHERE empresa = cEmpresa
           AND numcte <> '' AND num_credito <> ''
           AND fecha_status = dtFechaHoy
           AND status_cred != 'FF'
           AND num_producto = p_producto

        IF vc_statuscred IN ('AA','E1') THEN
            IF NOT EXISTS (SELECT numcte FROM bdicred:sd_grupo_cliente WHERE empresa = cEmpresa AND numcte = vc_numcte) THEN
                BEGIN WORK;
                    INSERT INTO bdicred:sd_grupo_cliente (empresa, numcte, grupo, user_insert, fecha_insert)
                         VALUES (cEmpresa, vc_numcte, 'A', 'Informix', dtFechaHoy);
                COMMIT WORK;
                CONTINUE FOREACH;
            END IF;  --IF NOT EXISTS
        END IF;	   

        IF  vc_statuscred NOT IN ('AA','FF','E1')  THEN  -- Para que no procese los liquidados. Elimina del gpo si el credito no es vigente.
            SELECT descripcion INTO vc_motivo
              FROM bdicred:sd_grupo_motivo 
             WHERE empresa = cEmpresa
               AND num_codigo <> ''
               AND estatus = vc_statuscred;

            BEGIN WORK;
                INSERT INTO bdicred:"informix".sd_grupo_credito_his (empresa , num_producto, num_credito, numcte, fecha_status, grupo, tipo, status_cliente,                                                
                                        status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert, motivo)
                     SELECT cEmpresa, vc_numproducto, vc_numcred_dist, vc_numcte, vf_fecha_status, 'A', 9, 'A', vc_statuscred, vd_mautorizado,
                            vd_porce_uso, vi_histo_efic, 'Informix', dtFechaHoy, vc_motivo
                       FROM bdicred:sd_grupo_credito 
                      WHERE rowid = vi_rowid;
                 
                DELETE FROM bdicred:sd_grupo_cliente WHERE empresa = cEmpresa AND numcte  = vc_numcte;      
                DELETE FROM bdicred:sd_grupo_credito WHERE CURRENT OF cursor_inserta; 

            COMMIT WORK;    
            CONTINUE FOREACH;                                         
        END IF; --  IF vc_statuscred NOT IN ('AA','BA')               
    END FOREACH;


    --FMV 4ene2013: Se adiciona depuracion para los creditos ya liquidados FF. Esta validacion se hace por separado, ya que ese cambio de estatus a FF
    --              no elimina al cliente del grupo A, solo se conserva el historico
    FOREACH curso_ins WITH HOLD FOR
        SELECT rowid, num_credito, numcte  INTO vrowid, vc_numcred_dist, vc_numcte
          FROM bdicred:"informix".sd_grupo_credito
         WHERE empresa = cEmpresa
           AND num_credito <> ''
           AND status_cred = 'FF'
           AND num_producto = p_producto

        IF (Select count(numcte) From bdicred:"informix".sd_grupo_credito where empresa = cEmpresa and numcte = vc_numcte and status_cred in ('AA','E1')) = 0 THEN
                -- Si el cliente ya no posee ningun otro credito activo o vigente, se elimina del grupo A.
            BEGIN WORK;
                INSERT INTO bdicred:"informix".sd_grupo_credito_his (empresa, num_producto, num_credito, numcte, fecha_status, grupo, tipo, status_cliente,
                                    status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert, motivo)
                     SELECT empresa, num_producto, num_credito, numcte, fecha_status, 'A', 9, 'A', status_cred, monto_autorizado, porcentaje_uso, 
                                    num_historia_efic, 'Informix', dtFechaHoy, 'Liquidacion Credito'
                       FROM bdicred:"informix".sd_grupo_credito
                      WHERE rowid = vrowid;

                DELETE FROM bdicred:sd_grupo_cliente WHERE empresa = cEmpresa AND numcte = vc_numcte;      
                DELETE FROM bdicred:sd_grupo_credito WHERE CURRENT OF curso_ins; 
            COMMIT WORK;    


        ELSE    -- Si el cliente posee otros creditos, a parte del que tiene estatus liquidado, continua el Grupo A y se manda al historico el credito
            BEGIN WORK;
                INSERT INTO bdicred:"informix".sd_grupo_credito_his (empresa, num_producto, num_credito, numcte, fecha_status, grupo, tipo, status_cliente,
                                    status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert, motivo)
                     SELECT empresa, num_producto, num_credito, numcte, fecha_status, 'A', 9, 'A', status_cred, monto_autorizado, porcentaje_uso, 
                                    num_historia_efic, 'Informix', dtFechaHoy, 'Liquidacion de Prestamo'
                       FROM bdicred:"informix".sd_grupo_credito
                      WHERE rowid = vrowid;

                DELETE FROM bdicred:"informix".sd_grupo_credito WHERE CURRENT OF curso_ins;
            COMMIT WORK;

        END IF;
    END FOREACH; --  FOREACH curso_ins WITH HOLD FOR

    -- Se agrega validación para eliminar los clientes que hayan sido eliminados del grupo, a causa de otros creditos NO vigentes.
    LET vrowid = 0;
    LET vc_numcred_dist = '';
    LET vc_numcte = '';

    FOREACH cursor_cte_del WITH HOLD FOR
        SELECT rowid, num_credito, numcte  
          INTO vrowid, vc_numcred_dist, vc_numcte
          FROM bdicred:"informix".sd_grupo_credito
         WHERE empresa = cEmpresa AND numcte <> '' AND num_credito <> ''
           AND num_producto = p_producto
           AND numcte NOT IN (select numcte from bdicred:sd_grupo_cliente)

        BEGIN WORK;
            INSERT INTO bdicred:"informix".sd_grupo_credito_his (empresa, num_producto, num_credito, numcte, fecha_status, grupo, tipo, status_cliente,
                                                    status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert, motivo)
                 SELECT empresa, num_producto, num_credito, numcte, fecha_status, 'A', 9, 'A', status_cred, monto_autorizado, porcentaje_uso, 
                        num_historia_efic, 'Informix', dtFechaHoy, 'Impago Vencido.'
                   FROM bdicred:"informix".sd_grupo_credito
                  WHERE rowid = vrowid;

            DELETE FROM bdicred:sd_grupo_cliente WHERE empresa = cEmpresa AND numcte = vc_numcte;      
            DELETE FROM bdicred:sd_grupo_credito WHERE CURRENT OF cursor_cte_del; 
        COMMIT WORK;              

    END FOREACH;

    IF v_codigo_retorno = "00000" THEN           
        LET v_mensaje        = "Proceso Integracion GrupoA, Termino Correctamente";
        LET v_store_pro      = 'sp_integra_grupoa';
        LET vc_intcontproc   = 'F';
        LET vc_crdcontproc   = 'F';

        UPDATE bdinteg:sx_contproc
           SET status_proc = vc_intcontproc
         WHERE empresa = cEmpresa
           AND fecha   = dtFechaHoy 
           AND proceso = vc_tipoproceso;
 
        UPDATE bdicred:sd_contproc
           SET status_proc = vc_crdcontproc, mensaje = 'Integracion Grupo A:'||p_producto||', Termino Correctamente!'
         WHERE empresa = cEmpresa
           AND fecha = dtFechaHoy
           AND proceso = vc_tipoproceso;
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin    
END PROCEDURE;
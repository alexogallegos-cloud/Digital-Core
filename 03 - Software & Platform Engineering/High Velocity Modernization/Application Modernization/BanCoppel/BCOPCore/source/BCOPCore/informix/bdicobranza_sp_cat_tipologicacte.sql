CREATE PROCEDURE "informix".sp_cat_tipologicacte(pEmpresa char(3), ptipo_cobranza char(1))
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE cCod_ret                 CHAR(6);
DEFINE vvccod_ret               CHAR(6);
DEFINE sql_err 			        INTEGER;
DEFINE isam_err 		        INTEGER;
DEFINE error_info		        CHAR(150);
DEFINE cMensaje 		        CHAR(150);
DEFINE vlNumInsert              INTEGER;
DEFINE vnumcte                  CHAR(20);
DEFINE vpago_venc               INTEGER;
DEFINE vsituacionespecial       CHAR(1);  
DEFINE vcausasitesp             SMALLINT;
DEFINE vcodigo_retorno          CHAR(6);
DEFINE vmensaje_retorno         CHAR(80);
DEFINE vnumero_credito          CHAR(20);
DEFINE vcodigo_tipcred          CHAR(2);        
DEFINE vfecha_origen            DATE;
DEFINE vfecha_prox_pago         DATE;
DEFINE vpago_minimo             DECIMAL(18,2);
DEFINE vfecha_ult_pago          DATE;
DEFINE vplazo                   INTEGER;
DEFINE vpagos_realizados        INTEGER;
DEFINE vlinea_otorgada          DECIMAL(18,2);
DEFINE vtasa_interes            DECIMAL(9,6);
DEFINE vtasa_moratorios         DECIMAL(9,6);
DEFINE vmonto_sbc               DECIMAL(14,2);
DEFINE vcap_vig                 DECIMAL(18,2);
DEFINE vcap_trans               DECIMAL(18,2);
DEFINE vcap_vdo_exig            DECIMAL(18,2);
DEFINE vcap_vdo_no_exig         DECIMAL(18,2);
DEFINE vsdo_act_total_cap       DECIMAL(18,2);
DEFINE vint_vig                 DECIMAL(18,2);
DEFINE vint_vdo                 DECIMAL(18,2);
DEFINE vint_moratorios          DECIMAL(18,2);
DEFINE vint_mes                 DECIMAL(18,2);
DEFINE vsdo_act_total_int       DECIMAL(18,2);
DEFINE viva_int_vig             DECIMAL(18,2);
DEFINE viva_int_vdo             DECIMAL(18,2);
DEFINE viva_int_moratorios      DECIMAL(18,2);
DEFINE viva_int_mes             DECIMAL(18,2);
DEFINE vsdo_act_total_iva       DECIMAL(18,2);
DEFINE vcom_pend                DECIMAL(18,2);
DEFINE viva_com                 DECIMAL(18,2);
DEFINE vsdo_retenido            DECIMAL(18,2);
DEFINE vtotal_liquidacion       DECIMAL(18,2);
DEFINE vint_devengado           DECIMAL(18,2);
DEFINE viva_int_devengado       DECIMAL(18,2);
DEFINE vlinea_disponible        DECIMAL(18,2);
DEFINE vpagos_vdos              DECIMAL(18,2);
DEFINE vdesc_status_cred        CHAR(60);
DEFINE vid_bloqueo_cred         INTEGER;
DEFINE vbloqueo_cta             CHAR(60);
DEFINE vid_causa_bloqueo_cred   CHAR(3);
DEFINE vcausa_bloqueo_cta       CHAR(50);
DEFINE vid_sit_esp_cte          CHAR(1);
DEFINE vid_causa_esp_cte        INTEGER;
DEFINE vsit_esp_cte             CHAR(75);
DEFINE vid_sit_esp_cred         CHAR(1);
DEFINE vid_causa_esp_cred       INTEGER;
DEFINE vsit_esp_cred            CHAR(75);
DEFINE monto_venc1              DECIMAL(18,2);
DEFINE monto_venc2              DECIMAL(18,2);
DEFINE monto_venc3              DECIMAL(18,2);
DEFINE vfecha_insert            DATE;
DEFINE  vlTipoLogica            SMALLINT;
DEFINE  vlSituacion             CHAR(1);
DEFINE cProceso                 CHAR(4);
DEFINE vexistenum				char(20);
define vfecha					date;

--SET DEBUG FILE TO '/tmp/sp_calcula_cobranza_administrativa_pbaaaa.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
      LET cProceso      = '0006';

------------------------------------------------------------
-----------------------------------------------------------

    BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;

            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;

----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
        --se obtiene la informacion
		SET ISOLATION TO dirty READ;

	select max(fecha_insert) into vfecha
	from bdicobranza:cb_cat_directorio_cte
	where empresa = pempresa
	and tipo_cobranza = ptipo_cobranza;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
  if (ptipo_cobranza in ('A','P')) THEN
  
   
  
FOREACH

  SELECT a.numcte, a.pago_venc, a.fecha_insert, b.monto_financiado
    INTO vnumcte, vpago_venc, vfecha_insert, vpago_minimo
    FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maesdos b
    WHERE a.empresa = b.empresa
    and fecha_insert = vfecha
    AND a.tipo_cobranza = ptipo_cobranza
    AND b.num_credito = a.num_credito
    AND a.fecha_insert = vfecha
    
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
   SELECT a.situacion, a.causa
   INTO vsituacionespecial, vcausasitesp
   FROM bdisitesp:"informix".se_ctessitespcte a
   WHERE a.idmovto=(SELECT MAX(aux.idmovto)
                      FROM bdisitesp:"informix".se_ctessitespcte aux
                     WHERE aux.idmovto = aux.idmovto
                       AND a.empresa   = aux.empresa
                       AND a.numcte    = aux.numcte)
     AND a.empresa   = pEmpresa
     AND a.numcte    = vnumcte;

    let vlTipoLogica = 0;
    SELECT limit 1 tipo_logica INTO vlTipoLogica 
      FROM cb_cat_logicas
     WHERE tipo_cobranza =ptipo_cobranza
       AND num_vencidos =vpago_venc
       AND monto_vencido_menor <=vpago_minimo;
    
    IF vlTipoLogica >0 THEN 
      LET vlSituacion = '';
      IF NOT EXISTS ( SELECT  situacion FROM  cb_cat_situacion_esp
                  WHERE  tipo_cobranza = ptipo_cobranza and SITUACION =  nvl(vsituacionespecial,'') )   THEN          
      IF vlSituacion = '' THEN
        UPDATE bdicobranza:cb_cat_directorio_cte 
           SET tipo_logica= vlTipoLogica
        where empresa= pEmpresa 
           and tipo_cobranza= ptipo_cobranza 
           and numcte= vnumcte 
           and fecha_insert= vfecha_insert;
      --ELSE 
      END IF;
    END IF;
    END IF;


END FOREACH;

ELSE

FOREACH	
	SELECT a.numcte, a.pago_venc, a.fecha_insert, b.monto_financiado
    INTO vnumcte, vpago_venc, vfecha_insert, vpago_minimo
    FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maesdoscrd b
    WHERE a.empresa = b.empresa
    AND a.tipo_cobranza = ptipo_cobranza
    AND b.num_credito = a.num_credito
	AND a.fecha_insert = vfecha
	


    let vlTipoLogica = 0;
    SELECT limit 1 tipo_logica INTO vlTipoLogica 
      FROM cb_cat_logicas
     WHERE tipo_cobranza = ptipo_cobranza
       AND num_vencidos = vpago_venc
       AND monto_vencido_menor <= vpago_minimo;
    
    IF vlTipoLogica > 0 THEN 
     
        UPDATE bdicobranza:cb_cat_directorio_cte 
           SET tipo_logica= vlTipoLogica
        where empresa= pEmpresa 
           and tipo_cobranza= ptipo_cobranza 
           and numcte= vnumcte 
           and fecha_insert= vfecha_insert;
     END IF;
     


END FOREACH;

END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCod_ret, cMensaje, '03')
        RETURNING vvcCod_ret;

		RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;
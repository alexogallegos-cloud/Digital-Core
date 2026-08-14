CREATE PROCEDURE "informix".sp_cat_gen_nr_prev(pfechacorte date)
RETURNING char(6), char(150);

--variables
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE cExito                       CHAR(6);
DEFINE cProceso                     CHAR(30);
DEFINE vlCodigo                     CHAR(5);
DEFINE vlDecCodigo                  CHAR(80);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vnum_credito                 CHAR(20);
DEFINE vdia							DATE;
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vinstruccion                 CHAR(1);
DEFINE pFecha                       DATE; 
DEFINE vmto_fin_ven_trasp			SMALLINT;
DEFINE vlFechaBorra                 DATE;
DEFINE cNum_producto                CHAR(4);
DEFINE cNum_ProdCampa               CHAR(4);
DEFINE cCod_retIB                   CHAR(6);


--SET DEBUG FILE TO '/tmp/sp_datos_admin_auronix.out';
--TRACE ON;

LET cCod_ret      = '000000';
LET sql_err       = 0;
LET cMensaje      = '';
LET vnumcte       = '';
LET vnum_credito  = '';
LET cProceso      = '0031';
LET cExito        = '000000';
LET vempresa      = '001';
LET cNum_ProdCampa = '';
             
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
	    LET cMensaje = error_info;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
                        RETURNING cCod_retIB;

		RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
                    RETURNING cCod_retIB;

-----------Si existe se elimina  los datos en tabla-------------------------------

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;

    SELECT Fecha_Hoy INTO pFecha
        FROM bdinteg:si_fechas
        WHERE empresa = vempresa;
        
----------------------------------- DATOS CLIENTE--------------------------------------------

    SET ISOLATION TO dirty READ;
    FOREACH     -- Ejecuta para cada producto perteneciente a la campaña Cobranza = E : '6011', '6300','6400'
        SELECT valor_numerico::integer INTO cNum_ProdCampa
            FROM bdicobranza:cb_param_campania WHERE empresa = vempresa AND tipo_campania = 1
            AND grupo_parametro = 'TIPOCOBCAT' AND valor_alfabetico = 'E'

        FOREACH
            SELECT d.numcte, d.num_credito, a.mto_fin_ven_trasp, d.num_producto
                       INTO vnumcte, vnum_credito, vmto_fin_ven_trasp, cNum_producto
            FROM bdicred:sd_maecredcrd d, bdicred:sd_maesdoscrd a, bdicred:sd_maecredanexocrd c
            WHERE	d.empresa = a.empresa
                AND d.num_credito = a.num_credito	
                AND d.empresa = c.empresa
                AND d.num_credito = c.num_credito
            	AND d.status_cred IN ( 'AA', 'VP','E1')
				AND (a.monto_vencido + a.mto_venc_trasp) = 0
    			AND d.num_producto = cNum_ProdCampa -- IN ( '6011', '6300','6400')
                AND a.sdo_cap_insoluto > 0
                AND a.mto_fin_ven_trasp = 0
    			AND c.prox_fecha_pago  >  date(pfechacorte) and 
                c.prox_fecha_pago <= date(pfechacorte) +7				
		
            IF NOT EXISTS (SELECT d.numcte, d.num_credito
                		FROM bdicobranza:cb_cat_directorio_cte d
                    	WHERE d.numcte = vnumcte
                        --AND d.num_credito = vnum_credito
                        AND fecha_insert = pfecha AND tipo_cobranza = 'E') THEN

                INSERT INTO bdicobranza:cb_cat_directorio_cte 
                            (empresa, tipo_cobranza, numcte, fecha_insert, num_credito, puntualidad, eficiencia, calificacion, pago_venc, prioridad,
                                tipo_logica, num_vuelta, usuario_insert, status_cliente, tipo_movto, num_producto)
                            VALUES(vempresa, 'E', vnumcte, pFecha, vnum_credito, '0', 0, 0, vmto_fin_ven_trasp,0 , 0, 0, user, 'AC', 0, cNum_producto);
            END IF;
        END FOREACH;
    END FOREACH;
	
	CALL bdicobranza:sp_inserta_bitacora_cob (vempresa,cProceso,'000000', 'INICIA PROCESO TIPO LOGICA','02' )
                RETURNING cCod_retIB;
    call bdicobranza:sp_cat_tipologicacte(vempresa,'E') returning vlCodigo, vlDecCodigo ;

    CALL bdicobranza:sp_inserta_bitacora_cob (vempresa,cProceso,vlCodigo, 'FINALIZA PROCESO TIPO LOGICA','02' )
                RETURNING cCod_retIB;
 /*  
 CALL inserta_bitacora_cob (vempresa,cProceso,'000000', 'INICIA PROCESO PRIORIDAD','02' );
    call bdicobranza:sp_cat_prioridadcte('P') returning vlCodigo, vlDecCodigo;
    CALL inserta_bitacora_cob (vempresa,cProceso,vlCodigo, 'FINALIZA PROCESO PRIORIDAD','02' );*/

    IF cCod_ret =cExito THEN

        CALL bdicobranza:sp_carga_telefonos('E') RETURNING vlCodigo, cMensaje;

        CALL bdicobranza:sp_inserta_bitacora_cob (vempresa,cProceso,'', '','03' )
                RETURNING cCod_retIB;
    ELSE
        CALL bdicobranza:sp_inserta_bitacora_cob (vempresa,cProceso,cCod_ret, cMensaje,'02' )
                RETURNING cCod_retIB;
    END IF;
    
    RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;
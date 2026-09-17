CREATE PROCEDURE "informix".sp_cat_traspasodirectorio_cte(ccfecha_insert DATE, vtipo_cobranza CHAR(1), vparametro SMALLINT)
       RETURNING  CHAR(6), CHAR(150);

--1 SE CREA FECHA
--0 SE PASA FECHA


--Modificado por: Enrique LizÃ¡rraga Lugo. 1/Feb/2011. Se agregan nuevos campos y variables para la tabla cb_cat_directorio_cte_his
--FechaUltModificacion: 20110221 MACF. Agregar dos nuevo campos (pago_minimo, saldo_total) a la tabla cb_cat_directorio_cte_his. 
--Fecha de Modificacion: Enero/2012. MAHR. Se agrega num_producto a la insercion de la tabla cb_cat_directorio_cte_his.
-- Modificado por: MAHR Abril 2012. Se cambia a sp_inserta_bitacora_cob para la correcta insercion a la bitacora.


--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 				    INTEGER;
DEFINE isam_err 			    INTEGER;
DEFINE error_info			    CHAR(150);
DEFINE cCod_ret         	    CHAR(6);
DEFINE cCod_RetIB               CHAR(6);
DEFINE cMensaje				    CHAR(150);
DEFINE vempresa 				CHAR(3);
DEFINE vnumcte           	    CHAR(20);
DEFINE vfecha_insert			DATE;
DEFINE vnum_credito 			CHAR(20);
DEFINE vpuntualidad 			CHAR(1);
DEFINE veficiencia				SMALLINT;
DEFINE vcalificacion			SMALLINT;
DEFINE vpago_venc				INTEGER;
DEFINE vprioridad 				SMALLINT;
DEFINE vtipo_logica        		SMALLINT;
DEFINE vkeys               		INTEGER;
DEFINE vnum_vuelta       	    SMALLINT;
DEFINE vusuario_insert   	    CHAR(8);
DEFINE vstatus_cliente   	    CHAR(2);
DEFINE vtipo_movto         		INTEGER;
DEFINE vcodigo_resultado 	    SMALLINT;
DEFINE vfecha_ultimo_contacto	DATETIME YEAR TO SECOND;
DEFINE cProceso          	    CHAR(4);
DEFINE vrowid            	    INTEGER;
DEFINE vpagominimo              DECIMAL(18,2);
DEFINE vsaldototal              DECIMAL(18,2);
DEFINE vfech                    DATE;
DEFINE cfecha_insert            DATE;
DEFINE vnumproducto             CHAR(4);
define vcall_c					smallint;
DEFINE vtipo_cobranza_aux 		CHAR(1);

--SET DEBUG FILE TO "transpaso.out";
--TRACE ON;

LET cCod_ret      = '000000';
LET sql_err       = 0;
LET cMensaje      = 'PROCESO EXITOSO';
LET vempresa      = '001';
LET cProceso      = '0004';
LET vpagominimo   = 0.00;
LET vsaldototal   = 0.00;
LET vfech         = DATE(1);
LET cfecha_insert = DATE(1);
LET vnumproducto  = '';
LET cCod_RetIB    = '';
let vcall_c		  =0;
LET vtipo_cobranza_aux = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    IF vparametro = 1 THEN
        IF vtipo_cobranza = 'O' THEN
            LET vtipo_cobranza_aux = 'A';
        ELSE
            LET vtipo_cobranza_aux = vtipo_cobranza;
        END IF;

        SELECT MAX(fecha_insert) INTO cfecha_insert 
            FROM bdicobranza:cb_cat_directorio_cte
			WHERE tipo_cobranza = vtipo_cobranza_aux;
		
		LET cfecha_insert = cfecha_insert - 1 UNITS MONTH;
				 
    ELIF vparametro = 2 THEN	
--        LET cfecha_insert = vfech - 1 UNITS MONTH;
        LET cfecha_insert = ccfecha_insert - 3 UNITS MONTH;
    ELIF vparametro = 0 THEN	
        LET cfecha_insert = ccfecha_insert;
    END IF;

    IF vtipo_cobranza IN('A', 'P') THEN
    
        SET ISOLATION TO dirty READ;
        FOREACH cursor_borra WITH HOLD FOR

            SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio2)} rowid, numcte, fecha_insert, num_credito, puntualidad, eficiencia, 
                calificacion, pago_venc, prioridad, tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, 
                codigo_resultado, fecha_ultimo_contacto, pago_minimo, saldo_total, num_producto, call_c
                INTO vrowid, vnumcte, vfecha_insert, vnum_credito, vpuntualidad, veficiencia, vcalificacion, vpago_venc, vprioridad, 
                vtipo_logica, vkeys, vnum_vuelta, vusuario_insert, vstatus_cliente, vtipo_movto, vcodigo_resultado, vfecha_ultimo_contacto, 
                vpagominimo, vsaldototal, vnumproducto, vcall_c
                FROM bdicobranza:cb_cat_directorio_cte
--                WHERE empresa = vempresa
                WHERE tipo_cobranza = vtipo_cobranza
                AND fecha_insert >= date(1) 
                AND fecha_insert <= cfecha_insert  
	   
            INSERT INTO "informix".cb_cat_directorio_cte_his(empresa, tipo_cobranza, numcte, fecha_insert, num_credito, puntualidad, 
            eficiencia, calificacion, pago_venc, prioridad, tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, 
            codigo_resultado, fecha_ultimo_contacto, fecha_modificacion, usuario_modifica, pago_minimo, saldo_total, num_producto, call_c) 
            VALUES(vempresa, vtipo_cobranza, vnumcte, vfecha_insert, vnum_credito, vpuntualidad, veficiencia, vcalificacion, vpago_venc, 
            vprioridad, vtipo_logica, vkeys, vnum_vuelta, vusuario_insert, vstatus_cliente, vtipo_movto, vcodigo_resultado, 
            vfecha_ultimo_contacto, TODAY, USER, vpagominimo, vsaldototal, vnumproducto, vcall_c);

            BEGIN WORK;
                DELETE FROM bdicobranza:cb_cat_directorio_cte
                WHERE CURRENT OF cursor_borra;                                                                             
            COMMIT WORK;
        END FOREACH;

    ELIF vtipo_cobranza IN('O') THEN
    
        SET ISOLATION TO dirty READ;
        FOREACH cursor_borra WITH HOLD FOR

            SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio2)} rowid, numcte, fecha_insert, num_credito, puntualidad, eficiencia, 
                calificacion, pago_venc, prioridad, tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, 
                codigo_resultado, fecha_ultimo_contacto, pago_minimo, saldo_total, num_producto, call_c
                INTO vrowid, vnumcte, vfecha_insert, vnum_credito, vpuntualidad, veficiencia, vcalificacion, vpago_venc, vprioridad, 
                vtipo_logica, vkeys, vnum_vuelta, vusuario_insert, vstatus_cliente, vtipo_movto, vcodigo_resultado, vfecha_ultimo_contacto, 
                vpagominimo, vsaldototal, vnumproducto, vcall_c
                FROM bdicobranza:cb_cat_directorio_cte
                WHERE tipo_cobranza = 'A'
                AND fecha_insert >= date(1) 
                AND fecha_insert <= cfecha_insert 
                AND num_producto in ('8100','7000','8500')
                
            INSERT INTO "informix".cb_cat_directorio_cte_his(empresa, tipo_cobranza, numcte, fecha_insert, num_credito, puntualidad, 
            eficiencia, calificacion, pago_venc, prioridad, tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, 
            codigo_resultado, fecha_ultimo_contacto, fecha_modificacion, usuario_modifica, pago_minimo, saldo_total, num_producto) 
            VALUES(vempresa, vtipo_cobranza_aux, vnumcte, vfecha_insert, vnum_credito, vpuntualidad, veficiencia, vcalificacion, vpago_venc, 
            vprioridad, vtipo_logica, vkeys, vnum_vuelta, vusuario_insert, vstatus_cliente, vtipo_movto, vcodigo_resultado, 
            vfecha_ultimo_contacto, TODAY, USER, vpagominimo, vsaldototal, vnumproducto);

            BEGIN WORK;
                DELETE FROM bdicobranza:cb_cat_directorio_cte
                WHERE CURRENT OF cursor_borra;                                                                             
            COMMIT WORK;
        END FOREACH;

    ELIF vtipo_cobranza IN('R', 'E') THEN

        SET ISOLATION TO dirty READ;
        FOREACH cursor_borra WITH HOLD FOR

            SELECT {+INDEX (cb_cat_directorio_cte idx_cat_directorio2)} dir.rowid, dir.numcte, dir.fecha_insert, dir.num_credito, 
                dir.puntualidad, dir.eficiencia, dir.calificacion, dir.pago_venc, dir.prioridad, dir.tipo_logica, dir.keys, 
                dir.num_vuelta, dir.usuario_insert, dir.status_cliente, dir.tipo_movto, dir.codigo_resultado, dir.fecha_ultimo_contacto, 
                dir.pago_minimo, dir.saldo_total, dir.num_producto, dir.tipo_cobranza
                INTO vrowid, vnumcte, vfecha_insert, vnum_credito, vpuntualidad, veficiencia, vcalificacion, vpago_venc, vprioridad, 
                    vtipo_logica, vkeys, vnum_vuelta, vusuario_insert, vstatus_cliente, vtipo_movto, vcodigo_resultado, 
                    vfecha_ultimo_contacto, vpagominimo, vsaldototal, vnumproducto, vtipo_cobranza
                FROM bdicobranza:cb_cat_directorio_cte dir
                WHERE dir.tipo_cobranza in ('E','R')
                  AND dir.fecha_insert > date(1) 
                  AND dir.fecha_insert <= cfecha_insert  
   
            INSERT INTO "informix".cb_cat_directorio_cte_his(empresa, tipo_cobranza, numcte, fecha_insert, num_credito, puntualidad, 
            eficiencia, calificacion, pago_venc, prioridad, tipo_logica, keys, num_vuelta, usuario_insert, status_cliente, tipo_movto, 
            codigo_resultado, fecha_ultimo_contacto, fecha_modificacion, usuario_modifica, pago_minimo, saldo_total, num_producto) 
            VALUES(vempresa, vtipo_cobranza, vnumcte, vfecha_insert, vnum_credito, vpuntualidad, veficiencia, vcalificacion, vpago_venc, 
            vprioridad, vtipo_logica, vkeys, vnum_vuelta, vusuario_insert, vstatus_cliente, vtipo_movto, vcodigo_resultado, 
            vfecha_ultimo_contacto, TODAY, USER, vpagominimo, vsaldototal, vnumproducto);

            BEGIN WORK;
                DELETE FROM bdicobranza:cb_cat_directorio_cte
                WHERE CURRENT OF cursor_borra;                                                                             
            COMMIT WORK;
        END FOREACH;
    END IF;

	UPDATE statistics medium FOR TABLE bdicobranza:cb_cat_directorio_cte;
	UPDATE statistics medium FOR TABLE bdicobranza:cb_cat_directorio_cte_his;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03') Returning cCod_RetIB;
            
    RETURN cCod_ret, cMensaje;

END;

END PROCEDURE;
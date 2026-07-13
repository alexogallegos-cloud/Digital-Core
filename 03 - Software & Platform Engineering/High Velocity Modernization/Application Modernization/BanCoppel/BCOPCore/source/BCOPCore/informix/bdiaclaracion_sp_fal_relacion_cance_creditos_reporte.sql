CREATE PROCEDURE "informix".sp_fal_relacion_cance_creditos_reporte(p_estatus INTEGER , p_fechaInicial DATE ,p_fechaFinal DATE)

     RETURNING          INTEGER AS registro,
                        CHAR(22) AS tipo_movimiento,
                        CHAR(15)  AS foliocsuac ,
                        CHAR(35)  AS concepto ,
                        CHAR(20)  AS numeroCuenta , 
                        CHAR(60)  AS nombrecliente ,
                        MONEY  AS saldo ,
                        MONEY  AS capitalvigente , 
                        MONEY  AS capitaltransitorio , 
                        MONEY  AS capitalvencido , 
                        MONEY  AS capitalvencidonoexigible , 
                        MONEY  AS capitaltotal , 
                        MONEY  AS interesvigente  , 
                        MONEY  AS ivainteresvigente , 
                        MONEY  AS interesvencido ,
                        MONEY  AS ivainteresvencido , 
                        MONEY  AS interesmoratoriobase , 
                        MONEY  AS interesmoratoriocopete ,
                        MONEY  AS ivainteresmoratorio , 
                        DATE   AS  fechaaplicacion , 
                        INTEGER  AS usuarioanalista , 
                        CHAR(60) AS nombreempleado,
                        CHAR (10) AS numeroTransac,
                        CHAR (255) AS descripcionTransac;

    --definicion de variables--
    DEFINE resp_registro INTEGER;
    DEFINE resp_tipo_movimiento CHAR(22);
    DEFINE resp_folio_csuac CHAR(15);
    DEFINE resp_concepto CHAR(35);
    DEFINE resp_num_cuenta_titular CHAR(20);
    DEFINE resp_nombreCliente CHAR(60);
    DEFINE resp_saldo MONEY;
    DEFINE resp_capital_vigente MONEY;
    DEFINE resp_capital_transitorio MONEY;
    DEFINE resp_capital_vencido MONEY;
    DEFINE resp_capital_vencido_no_exigible MONEY; 
    DEFINE resp_capital_total MONEY;
    DEFINE resp_interes_vigente MONEY ;
    DEFINE resp_iva_interes_vigente MONEY ;
    DEFINE resp_interes_vencido MONEY ;
    DEFINE resp_iva_interes_vencido MONEY ;
    DEFINE resp_interes_moratorio_base MONEY ;
    DEFINE resp_interes_moratorio_copete MONEY;
    DEFINE resp_iva_interes_moratorio MONEY;
    DEFINE resp_fecha_aplicacion DATE;
    DEFINE resp_fky_usuario_analista INTEGER;
    DEFINE resp_nombre CHAR(60);
    DEFINE resp_numeroTransac CHAR(10);
    DEFINE resp_descripcionTransac CHAR(255);
    DEFINE iSqlErr INTEGER;


                LET resp_registro = 0;
                LET resp_tipo_movimiento = '';
                LET resp_folio_csuac = '';
                LET resp_concepto = '';
                LET resp_num_cuenta_titular = '';
                LET resp_nombre  = '';
                LET resp_saldo = 0 ;
                LET resp_capital_vigente = 0 ;
                LET resp_capital_transitorio = 0 ;
                LET resp_capital_vencido = 0 ;
                LET resp_capital_vencido_no_exigible = 0 ; 
                LET resp_capital_total = 0 ;
                LET resp_interes_vigente = 0 ;
                LET resp_iva_interes_vigente = 0 ;
                LET resp_interes_vencido = 0 ;
                LET resp_iva_interes_vencido = 0 ;
                LET resp_interes_moratorio_base = 0 ;
                LET resp_interes_moratorio_copete = 0 ;
                LET resp_iva_interes_moratorio = 0 ;
                LET resp_fecha_aplicacion = '';
                LET resp_fky_usuario_analista = 0;
                LET resp_nombre = '';
                LET resp_nombreCliente = '';
                LET resp_numeroTransac = '';
                LET resp_descripcionTransac = '';

    SET ISOLATION TO DIRTY READ;
            
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resp_registro = iSqlErr;
                LET resp_tipo_movimiento = '';
                LET resp_folio_csuac = '';
                LET resp_concepto = '';
                LET resp_num_cuenta_titular = '';
                LET resp_nombre  = '';
                LET resp_saldo = 0 ;
                LET resp_capital_vigente = 0 ;
                LET resp_capital_transitorio = 0 ;
                LET resp_capital_vencido = 0 ;
                LET resp_capital_vencido_no_exigible = 0 ; 
                LET resp_capital_total = 0 ;
                LET resp_interes_vigente = 0 ;
                LET resp_iva_interes_vigente = 0 ;
                LET resp_interes_vencido = 0 ;
                LET resp_iva_interes_vencido = 0 ;
                LET resp_interes_moratorio_base = 0 ;
                LET resp_interes_moratorio_copete = 0 ;
                LET resp_iva_interes_moratorio = 0 ;
                LET resp_fecha_aplicacion = null;
                LET resp_fky_usuario_analista = 0;
                LET resp_nombre = '';
                LET resp_nombreCliente = '';
                LET resp_numeroTransac = '';
                LET resp_descripcionTransac = '';
                RETURN resp_registro, resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                                resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                                resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                                resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre, resp_numeroTransac, resp_descripcionTransac;
            END IF;
        END EXCEPTION;
            



            LET resp_registro = 0;

            IF p_estatus=0 THEN
            
                FOREACH fal_cursor FOR
                                SELECT  (CASE WHEN tipo_movimiento_credito = 1 THEN 'Saldo Anterior'
                                         WHEN tipo_movimiento_credito = 2 THEN 'Aplicación Cancelación'
                                         WHEN tipo_movimiento_credito = 3 THEN 'Saldo Nuevo'
                                         END ) AS tipo_movimiento, sal.folio_csuac  ,sal.concepto ,sal.num_cuenta_titular ,
                                         TRIM(cte.nombre1) || ' '  || 
                                         TRIM(cte.nombre2) || ' '  ||  
                                        TRIM(cte.apell_paterno) || ' ' ||  
                                        TRIM(cte.apell_materno)|| ' ' as nombre,
                                         sal.saldo , sal.capital_vigente , sal.capital_transitorio , sal.capital_vencido , sal.capital_vencido_no_exigible , sal.capital_total , 
                                         sal.interes_vigente, sal.iva_interes_vigente , sal.interes_vencido , sal.iva_interes_vencido , sal.interes_moratorio_base , 
                                         sal.interes_moratorio_copete , sal.iva_interes_moratorio , sal.fecha_aplicacion , soli.fky_usuario_analista , (SELECT usu.nombre FROM acl_usuario usu WHERE soli.fky_usuario_analista = usu.pky_usuario) as nombre
                                    INTO resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                                    resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                                    resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                                    resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre

                                FROM fal_saldo_anterior sal , acl_tipo_producto pr ,bdinteg:"informix".si_cliente cte , fal_solicitud soli
                                WHERE sal.fky_tipo_producto = pr.pky_tipo_producto
                                AND  cte.numcte = sal.numero_cliente
                                AND soli.folio_csuac =  sal.folio_csuac
                                AND soli.fky_estatus_general <> 1
                                AND sal.fky_tipo_tramite = 2
                                AND soli.fecha_ingreso BETWEEN p_fechaInicial AND p_fechaFinal
                                ORDER BY sal.folio_csuac, tipo_movimiento_credito
                IF resp_tipo_movimiento = 'Saldo Anterior' THEN 
                  LET resp_registro = resp_registro + 1;
                END IF

                FOREACH fal_cuenta FOR                   
                            select first 1 transac.numero as referencia, tran.descripcion
                            into resp_numeroTransac, resp_descripcionTransac
                            from bdicred:"informix".sd_movdia as his
                            inner join bdicred:"informix".sd_transfun as tran on his.codigo_fun = tran.codigo_fun and his.codigo_ref= tran.codigo_ref
                            inner join bdinteg:"informix".si_transacc as transac on transac.numero = his.transacc_suc
                            where num_credito=resp_num_cuenta_titular
                            and transac.se_emite_edocta = 'S'
                            order by his.secuencia desc
 
             
                            IF resp_numeroTransac IS NULL AND resp_descripcionTransac IS  NULL THEN 
                                FOREACH fal_cuenta_his FOR
                                    select first 1 transac.numero as referencia, tran.descripcion, transac.descripcion
                                    into resp_numeroTransac, resp_descripcionTransac
                                    from bdicred:"informix".sd_movhis as his
                                    inner join bdicred:"informix".sd_transfun as tran on his.codigo_fun = tran.codigo_fun and his.codigo_ref= tran.codigo_ref
                                    inner join bdinteg:"informix".si_transacc as transac on transac.numero = his. transacc_suc
                                    where num_credito=resp_num_cuenta_titular
                                    and transac.se_emite_edocta = 'S'
                                    order by his.secuencia desc
                                END FOREACH;
                            END IF
                END FOREACH;
                
                
                
                RETURN  resp_registro, resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                                    resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                                    resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                                    resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre, resp_numeroTransac, resp_descripcionTransac WITH RESUME;
            END FOREACH;
            

        ELIF p_estatus=2 OR p_estatus=3 THEN 
        
            FOREACH fal_cursor FOR
                               SELECT  (CASE WHEN tipo_movimiento_credito = 1 THEN 'Saldo Anterior'
                               WHEN tipo_movimiento_credito = 2 THEN 'Aplicación Cancelación'
                               WHEN tipo_movimiento_credito = 3 THEN 'Saldo Nuevo'
                               END ) AS tipo_movimiento, sal.folio_csuac  ,sal.concepto ,sal.num_cuenta_titular ,
                               TRIM(cte.nombre1) || ' '  || 
                               TRIM(cte.nombre2) || ' ' ||  
                               TRIM(cte.apell_paterno) || ' ' ||  
                               TRIM(cte.apell_materno)|| ' ' as nombre, 
                               sal.saldo , sal.capital_vigente , sal.capital_transitorio , sal.capital_vencido , sal.capital_vencido_no_exigible , sal.capital_total , 
                               sal.interes_vigente, sal.iva_interes_vigente , sal.interes_vencido , sal.iva_interes_vencido , sal.interes_moratorio_base , 
                               sal.interes_moratorio_copete , sal.iva_interes_moratorio , sal.fecha_aplicacion , soli.fky_usuario_analista , (SELECT usu.nombre FROM acl_usuario usu WHERE soli.fky_usuario_analista = usu.pky_usuario) as nombre
                               INTO resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                               resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                               resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                               resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre
                               FROM fal_saldo_anterior sal , acl_tipo_producto pr ,bdinteg:"informix".si_cliente cte , fal_solicitud soli 
                               WHERE sal.fky_tipo_producto = pr.pky_tipo_producto
                               AND soli.fky_estatus_general=p_estatus
                               AND  cte.numcte = sal.numero_cliente
                               AND soli.folio_csuac =  sal.folio_csuac
                               AND sal.fky_tipo_tramite = 2
                               AND soli.fecha_ingreso BETWEEN p_fechaInicial AND p_fechaFinal
                               ORDER BY sal.folio_csuac, tipo_movimiento_credito
                IF resp_tipo_movimiento = 'Saldo Anterior' THEN 
                  LET resp_registro = resp_registro + 1;
                END IF

                FOREACH fal_cuenta FOR                   
                            select first 1 transac.numero as referencia, tran.descripcion
                            into resp_numeroTransac, resp_descripcionTransac
                            from bdicred:"informix".sd_movdia as his
                            inner join bdicred:"informix".sd_transfun as tran on his.codigo_fun = tran.codigo_fun and his.codigo_ref= tran.codigo_ref
                            inner join bdinteg:"informix".si_transacc as transac on transac.numero = his.transacc_suc
                            where num_credito=resp_num_cuenta_titular
                            and transac.se_emite_edocta = 'S'
                            order by his.secuencia desc
 
                            IF resp_numeroTransac IS NULL AND resp_descripcionTransac IS  NULL THEN 
                                FOREACH fal_cuenta_his FOR
                                    select first 1 transac.numero as referencia, tran.descripcion, transac.descripcion
                                    into resp_numeroTransac, resp_descripcionTransac
                                    from bdicred:"informix".sd_movhis as his
                                    inner join bdicred:"informix".sd_transfun as tran on his.codigo_fun = tran.codigo_fun and his.codigo_ref= tran.codigo_ref
                                    inner join bdinteg:"informix".si_transacc as transac on transac.numero = his.transacc_suc
                                    where num_credito=resp_num_cuenta_titular
                                    and transac.se_emite_edocta = 'S'
                                    order by his.secuencia desc
                                END FOREACH;
                            END IF
                END FOREACH;

                RETURN  resp_registro, resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                                    resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                                    resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                                    resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre, resp_numeroTransac, resp_descripcionTransac WITH RESUME;
            END FOREACH;
        
        ELIF p_estatus=1 THEN

               FOREACH fal_cursor FOR
                               SELECT  (CASE WHEN tipo_movimiento_credito = 1 THEN 'Saldo Anterior'
                               WHEN tipo_movimiento_credito = 2 THEN 'Aplicación Cancelación'
                               WHEN tipo_movimiento_credito = 3 THEN 'Saldo Nuevo'
                               END ) AS tipo_movimiento, sal.folio_csuac  ,sal.concepto ,sal.num_cuenta_titular ,
                               TRIM(cte.nombre1) || ' '  || 
                               TRIM(cte.nombre2) || ' ' ||  
                               TRIM(cte.apell_paterno) || ' ' ||  
                               TRIM(cte.apell_materno) || ' ' as nombre, 
                               sal.saldo , sal.capital_vigente , sal.capital_transitorio , sal.capital_vencido , sal.capital_vencido_no_exigible , sal.capital_total , 
                               sal.interes_vigente, sal.iva_interes_vigente , sal.interes_vencido , sal.iva_interes_vencido , sal.interes_moratorio_base , 
                               sal.interes_moratorio_copete , sal.iva_interes_moratorio , sal.fecha_aplicacion , soli.fky_usuario_analista , (SELECT usu.nombre FROM acl_usuario usu WHERE soli.fky_usuario_analista = usu.pky_usuario) as nombre
                               INTO resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                               resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                               resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                               resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre
                               FROM fal_saldo_anterior sal , acl_tipo_producto pr ,bdinteg:"informix".si_cliente cte , fal_solicitud soli , fal_control_tramite tra
                               WHERE sal.fky_tipo_producto = pr.pky_tipo_producto
                               AND sal.num_cuenta_titular = tra.cuenta_cliente_fallecido
                               AND tra.fky_tipo_tramite = 2
                               AND tra.exitoso=1
                               AND  cte.numcte = sal.numero_cliente
                               AND soli.folio_csuac =  sal.folio_csuac
                               AND sal.fky_tipo_tramite = 2
                               AND soli.fky_estatus_general <> 1
                               AND soli.fecha_ingreso BETWEEN p_fechaInicial AND p_fechaFinal
                               ORDER BY sal.folio_csuac, tipo_movimiento_credito
                IF resp_tipo_movimiento = 'Saldo Anterior' THEN 
                  LET resp_registro = resp_registro + 1;
                END IF



                FOREACH fal_cuenta FOR                   
                            select first 1 transac.numero as referencia, tran.descripcion
                            into resp_numeroTransac, resp_descripcionTransac
                            from bdicred:"informix".sd_movdia as his
                            inner join bdicred:"informix".sd_transfun as tran on his.codigo_fun = tran.codigo_fun and his.codigo_ref= tran.codigo_ref
                            inner join bdinteg:"informix".si_transacc as transac on transac.numero = his.transacc_suc
                            where num_credito=resp_num_cuenta_titular
                            and transac.se_emite_edocta = 'S'
                            order by his.secuencia desc
 
                            IF resp_numeroTransac IS NULL AND resp_descripcionTransac IS  NULL THEN 
                                FOREACH fal_cuenta_his FOR
                                    select first 1 transac.numero as referencia, tran.descripcion, transac.descripcion
                                    into resp_numeroTransac, resp_descripcionTransac
                                    from bdicred:"informix".sd_movhis as his
                                    inner join bdicred:"informix".sd_transfun as tran on his.codigo_fun = tran.codigo_fun and his.codigo_ref= tran.codigo_ref
                                    inner join bdinteg:"informix".si_transacc as transac on transac.numero = his.transacc_suc
                                    where num_credito=resp_num_cuenta_titular
                                    and transac.se_emite_edocta = 'S'
                                    order by his.secuencia desc
                                END FOREACH;
                            END IF
                END FOREACH;

                RETURN  resp_registro, resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                                    resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                                    resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                                    resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre, resp_numeroTransac, resp_descripcionTransac WITH RESUME;
            END FOREACH;

        
        ELSE
                LET resp_registro = 0;
                LET resp_tipo_movimiento = '';
                LET resp_folio_csuac = '';
                LET resp_concepto = '';
                LET resp_num_cuenta_titular = '';
                LET resp_nombre  = '';
                LET resp_saldo = 0 ;
                LET resp_capital_vigente = 0 ;
                LET resp_capital_transitorio = 0 ;
                LET resp_capital_vencido = 0 ;
                LET resp_capital_vencido_no_exigible = 0 ; 
                LET resp_capital_total = 0 ;
                LET resp_interes_vigente = 0 ;
                LET resp_iva_interes_vigente = 0 ;
                LET resp_interes_vencido = 0 ;
                LET resp_iva_interes_vencido = 0 ;
                LET resp_interes_moratorio_base = 0 ;
                LET resp_interes_moratorio_copete = 0 ;
                LET resp_iva_interes_moratorio = 0 ;
                LET resp_fecha_aplicacion = null;
                LET resp_fky_usuario_analista = 0;
                LET resp_nombre = '';
                LET resp_nombreCliente = '';
                LET resp_numeroTransac = '';
                LET resp_descripcionTransac = '';
                RETURN resp_registro, resp_tipo_movimiento, resp_folio_csuac,resp_concepto,resp_num_cuenta_titular,resp_nombreCliente,resp_saldo,
                                resp_capital_vigente,resp_capital_transitorio,resp_capital_vencido,resp_capital_vencido_no_exigible,
                                resp_capital_total,resp_interes_vigente,resp_iva_interes_vigente,resp_interes_vencido,resp_iva_interes_vencido,
                                resp_interes_moratorio_base,resp_interes_moratorio_copete,resp_iva_interes_moratorio,resp_fecha_aplicacion,resp_fky_usuario_analista,resp_nombre, resp_numeroTransac, resp_descripcionTransac;

        END IF
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_rep_baja_clientes_fallecidos(fechaIni DATE, fechaFin DATE) 

    RETURNING  
        INTEGER AS registro,
        CHAR(11) AS folio_csuac,
        CHAR (9) AS num_cliente,
        CHAR (30) AS nombre1,
        CHAR (30) AS nombre2,
        CHAR (30) AS apellido_pat,
        CHAR (30) AS apellido_mat,
        DATE AS fecha_cierre,
        INTEGER AS error;

        DEFINE resultado_registro   INTEGER;
        DEFINE resultado_folio_csuac CHAR (11);
        DEFINE resultado_num_cliente CHAR (9);
        DEFINE resultado_nombre1 CHAR (30);
        DEFINE resultado_nombre2 CHAR (30);
        DEFINE resultado_apellido_pat CHAR (30);
        DEFINE resultado_apellido_mat CHAR (30);
        DEFINE resultado_fecha_cierre DATE;
        DEFINE error INTEGER;
        DEFINE iSqlErr INTEGER;

         -- Inicialización de las variables.
        LET resultado_registro = 0;
        LET resultado_folio_csuac = '';
        LET resultado_num_cliente = '';
        LET resultado_apellido_pat ='';
        LET resultado_apellido_mat ='';
        LET resultado_nombre1 ='';
        LET resultado_nombre2 ='';
        LET resultado_fecha_cierre ='';
        LET error = 0;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_registro = 0;
                LET resultado_folio_csuac = '';
                LET resultado_num_cliente = '';
                LET resultado_apellido_pat ='';
                LET resultado_apellido_mat ='';
                LET resultado_nombre1 ='';
                LET resultado_nombre2 ='';
                LET resultado_fecha_cierre ='';
                LET error = 1;
                RETURN resultado_registro,resultado_folio_csuac,resultado_num_cliente,resultado_apellido_pat,resultado_apellido_mat,resultado_nombre1 ,resultado_nombre2,resultado_fecha_cierre,error;
            END IF;
        END EXCEPTION;

      --  IF p_estatus = 0 THEN 

            FOREACH fal_cursor FOR
                    SELECT fal.folio_csuac, fal.num_cliente, fal.fecha_cierre, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno
                    INTO resultado_folio_csuac, resultado_num_cliente, resultado_fecha_cierre, resultado_nombre1, resultado_nombre2, resultado_apellido_pat, resultado_apellido_mat
                    FROM fal_solicitud fal
                    INNER JOIN bdinteg:"informix".si_cliente cte ON fal.num_cliente = cte.numcte
                    WHERE fal.fky_estatus_general = 3
                    AND fal.fecha_ingreso BETWEEN fechaIni and fechaFin
                    LET resultado_registro = resultado_registro + 1;
                    RETURN resultado_registro,resultado_folio_csuac,resultado_num_cliente,resultado_apellido_pat,resultado_apellido_mat,resultado_nombre1 ,resultado_nombre2,resultado_fecha_cierre,error
                    WITH resume;
             END FOREACH;   
      /**   ELIF p_estatus = 2 OR p_estatus=3 THEN 

            FOREACH fal_cursor FOR
                    SELECT fal.folio_csuac, fal.num_cliente, fal.fecha_cierre, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno
                    INTO resultado_folio_csuac, resultado_num_cliente, resultado_fecha_cierre, resultado_nombre1, resultado_nombre2, resultado_apellido_pat, resultado_apellido_mat
                    FROM fal_solicitud fal
                    INNER JOIN bdinteg:si_cliente cte ON fal.num_cliente = cte.numcte
                    WHERE fal.fky_estatus_general = p_estatus
                    AND fal.fecha_ingreso BETWEEN fechaIni and fechaFin

                    LET resultado_registro = resultado_registro + 1;
                    RETURN resultado_registro,resultado_folio_csuac,resultado_num_cliente,resultado_apellido_pat,resultado_apellido_mat,resultado_nombre1 ,resultado_nombre2,resultado_fecha_cierre,error
                    WITH resume;
             END FOREACH;            

         ELIF p_estatus = 1 THEN 

            FOREACH fal_cursor FOR
                    SELECT fal.folio_csuac, fal.num_cliente, fal.fecha_cierre, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno
                    INTO resultado_folio_csuac, resultado_num_cliente, resultado_fecha_cierre, resultado_nombre1, resultado_nombre2, resultado_apellido_pat, resultado_apellido_mat
                    FROM fal_solicitud fal
                    INNER JOIN bdinteg:si_cliente cte ON fal.num_cliente = cte.numcte
                    WHERE (SELECT count(*) FROM  fal_control_tramite tra WHERE tra.exitoso=1 AND tra.fky_solicitud = fal.pky_solicitud) >= 1
                    AND fal.fky_estatus_general <> 1
                    AND fal.fecha_ingreso BETWEEN fechaIni and fechaFin
                    LET resultado_registro = resultado_registro + 1;
                    RETURN resultado_registro,resultado_folio_csuac,resultado_num_cliente,resultado_apellido_pat,resultado_apellido_mat,resultado_nombre1 ,resultado_nombre2,resultado_fecha_cierre,error
                    WITH resume;
             END FOREACH;    
         

         ELSE

                LET resultado_registro = 0;
                LET resultado_folio_csuac = '';
                LET resultado_num_cliente = '';
                LET resultado_apellido_pat ='';
                LET resultado_apellido_mat ='';
                LET resultado_nombre1 ='';
                LET resultado_nombre2 ='';
                LET resultado_fecha_cierre ='';
                LET error = 1;
                RETURN resultado_registro,resultado_folio_csuac,resultado_num_cliente,resultado_apellido_pat,resultado_apellido_mat,resultado_nombre1 ,resultado_nombre2,resultado_fecha_cierre,error;

         
         END IF**/
   END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_beneficiarios_pagares_por_cuenta (p_numeroCuenta CHAR(20) )

     RETURNING  CHAR(20)    AS numeroCliente,
                        CHAR(30)    AS numeroCuenta, 
                        CHAR(30)    AS estatus,  
                        CHAR(100)   AS motivo,  
                        MONEY(16)   AS porcentaje,
                        CHAR(6)       AS numeroProducto,
                       CHAR(30)     AS apellidoP,
                         CHAR(30)   AS apellidoM,
                        CHAR(30)    AS nombre1,
                        CHAR(30)    AS nombre2,
                        CHAR(30)     AS descripcionEstatus;


    --definicion de variables--     
    DEFINE resultado_numeroCliente        CHAR(20);
    DEFINE resultado_numeroCuenta         CHAR(30);
    DEFINE resultado_estatus              CHAR(30);
    DEFINE resultado_motivo               CHAR(100);
    DEFINE resultado_porcentaje           MONEY(16);
    DEFINE resultado_porc_bene            MONEY(16);
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_apellidoPat         CHAR(30);
    DEFINE resultado_apellidoMat         CHAR(30);
    DEFINE resultado_nombre1         CHAR(30);
    DEFINE resultado_nombre2         CHAR(30);
    DEFINE resultado_descripcion_estatus CHAR(30);

    DEFINE iSqlErr                        INTEGER;
    
     -- Inicialización de las variables.
    LET resultado_apellidoPat ='';
    LET resultado_apellidoMat ='';
    LET resultado_nombre1 ='';
    LET resultado_nombre2 ='';
    LET resultado_numeroCliente ='';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_porcentaje = 0;
    LET resultado_numeroProducto ='';
    LET resultado_porc_bene = '';
    LET resultado_descripcion_estatus = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroCliente = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_porcentaje = 0;
                LET resultado_numeroProducto ='';
                LET resultado_descripcion_estatus = '';
                RETURN resultado_numeroCliente , resultado_numeroCuenta , resultado_estatus , resultado_motivo , resultado_porcentaje,resultado_numeroProducto ,resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2, resultado_descripcion_estatus;
            END IF;
        END EXCEPTION;

        FOREACH
                SELECT cte.numcte  as numero_cliente, 
                -- NVL(bene.porcentaje,0)
                CASE
                    WHEN bene.porcentaje IS NULL THEN 0
                    ELSE bene.porcentaje 
                END
                    INTO resultado_numeroCliente, resultado_porc_bene
                 FROM  bdinteg:"informix".si_cliente cte 
                LEFT OUTER JOIN  bdinvers:"informix".sv_benefic bene ON (cte.numcte = bene.numcte)
                WHERE bene.cuenta  = p_numeroCuenta

        
        
            SELECT FIRST  1 qc.cuenta as numero_cuenta ,
                CASE
                    WHEN stc.pky_estatus_cuenta IS NULL THEN 0
                    ELSE stc.pky_estatus_cuenta
                END as estatus,
                --NVL(stc.pky_estatus_cuenta, '') as estatus,
                CASE
                    WHEN mot.descripcion IS NULL THEN ''
                    ELSE mot.descripcion 
                END as motivo,
                --NVL(mot.descripcion,'') as motivo,
                bene.porcentaje as porcentaje,
                pr.producto,
                cte.apell_paterno,
                cte.apell_materno,
                cte.nombre1,
                cte.nombre2,
                CASE
                    WHEN stc.descripcion IS NULL THEN ''
                    ELSE stc.descripcion 
                END
                --NVL(stc.descripcion, '') as desc_estatus
            INTO resultado_numeroCuenta , resultado_estatus , resultado_motivo , resultado_porcentaje ,resultado_numeroProducto , resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2, resultado_descripcion_estatus
            FROM  bdinteg:"informix".si_cliente cte 
            
                LEFT OUTER JOIN bdinvers:"informix".sv_benefic bene ON (cte.numcte = bene.numcte)                            
                LEFT OUTER JOIN bdicheq:"informix".sc_maechq qc ON (qc.num_cte = cte.numcte) 
                LEFT OUTER JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                LEFT OUTER JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                LEFT OUTER JOIN bdicheq:"informix".sc_bloqueo mot ON mot.codigo = qc.motivo

                WHERE bene.cuenta  = p_numeroCuenta
                AND  cte.numcte = resultado_numeroCliente
                AND pr.producto IN (1300, 1400, 1700, 1900, 2000, 2500)
                AND qc.status_cta IN (1,4,5)
                group by numero_cuenta,  estatus ,  stc.descripcion,porcentaje ,pr.producto , cte.apell_paterno,cte.apell_materno, cte.nombre1,cte.nombre2, mot.descripcion;

                IF resultado_numeroCuenta = '' OR resultado_numeroCuenta IS NULL THEN
                   LET resultado_numeroCliente = resultado_numeroCliente;
                   LET resultado_numeroCuenta = p_numeroCuenta;
                   LET resultado_porcentaje = resultado_porc_bene;
                   LET resultado_descripcion_estatus = '';
                END IF
               

        RETURN resultado_numeroCliente, resultado_numeroCuenta, resultado_estatus,resultado_motivo , resultado_porcentaje , resultado_numeroProducto , resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2 , resultado_descripcion_estatus
        WITH RESUME;
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_obtener_beneficiario_por_cuentas (p_numeroCuenta CHAR(20), p_numeroCuentaBeneficiario CHAR(20), p_tipoTramite INT )

     RETURNING          CHAR(20)    AS numeroCliente,
                        CHAR(30)    AS numeroCuenta, 
                        CHAR(30)    AS estatus,  
                        CHAR(100)   AS motivo,  
                        MONEY(16)   AS porcentaje,
                        CHAR(6)     AS numeroProducto,
                        CHAR(30)    AS apellidoP,
                        CHAR(30)    AS apellidoM,
                        CHAR(30)    AS nombre1,
                        CHAR(30)    AS nombre2;


    --definicion de variables--     
    DEFINE resultado_numeroCliente        CHAR(20);
    DEFINE resultado_numeroCuenta         CHAR(30);
    DEFINE resultado_estatus              CHAR(30);
    DEFINE resultado_motivo               CHAR(100);
    DEFINE resultado_porcentaje           MONEY(16);
    DEFINE resultado_numeroProducto       CHAR(6);
    DEFINE resultado_apellidoPat          CHAR(30);
    DEFINE resultado_apellidoMat          CHAR(30);
    DEFINE resultado_nombre1              CHAR(30);
    DEFINE resultado_nombre2              CHAR(30);
    DEFINE iSqlErr                        INTEGER;
    
     -- InicializaciÃ³n de las variables.
    LET resultado_apellidoPat ='';
    LET resultado_apellidoMat ='';
    LET resultado_nombre1 ='';
    LET resultado_nombre2 ='';
    LET resultado_numeroCliente ='';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_porcentaje = 0;
    LET resultado_numeroProducto ='';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroCliente = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_porcentaje = 0;
                LET resultado_numeroProducto ='';
                RETURN resultado_numeroCliente , resultado_numeroCuenta , resultado_estatus , resultado_motivo , resultado_porcentaje,resultado_numeroProducto ,resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2;
            END IF;
        END EXCEPTION;

            --Validar tipo tramite 1=DEBITO, 3=PAGARE, 4=INVERSION, NULL= CONSULTAR LISTADO DE CAPTACIÓN
            IF (p_tipoTramite = 1 OR  p_tipoTramite = 4) AND p_numeroCuentaBeneficiario IS NOT NULL THEN
                SELECT FIRST 1 bene.numcte  as numero_cliente, 
                             cte.apell_paterno as apellidoPat, 
                             cte.apell_materno as apellidoMat, 
                             cte.nombre1 as nombre1, 
                             cte.nombre2 as nombre2, 
                             bene.porcentaje as porcentaje,
                             qc.cuenta as numero_cuenta,
                             qc.status_cta as estatus,
                             stc.descripcion as motivo,
                             pr.producto as numeroProducto
                INTO resultado_numeroCliente, resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2, resultado_porcentaje,
                     resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_numeroProducto
                FROM bdicheq:"informix".sc_maechq qc
                    INNER JOIN bdicheq:"informix".sc_beneficiario bene ON bene.numcte=qc.num_cte
                    LEFT JOIN  bdinteg:"informix".si_cliente cte  ON cte.numcte = bene.numcte
                    LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto )
                    LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                    LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )                
                    WHERE qc.cuenta = p_numeroCuentaBeneficiario --Cuenta del beneficiario en tabla bdicheq:sc_maechq qc
                    AND bene.cuenta = p_numeroCuenta;

                RETURN resultado_numeroCliente, resultado_numeroCuenta, resultado_estatus,resultado_motivo , resultado_porcentaje , resultado_numeroProducto , resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2 ;    
 
           ELIF (p_tipoTramite = 3) AND p_numeroCuentaBeneficiario IS NOT NULL THEN
                SELECT FIRST 1 
                             bene.numcte  as numero_cliente, 
                             cte.apell_paterno as apellidoPat, 
                             cte.apell_materno as apellidoMat, 
                             cte.nombre1 as nombre1, 
                             cte.nombre2 as nombre2, 
                             bene.porcentaje as porcentaje,
                             qc.cuenta as numero_cuenta,
                             qc.status_cta as estatus,
                             stc.descripcion as motivo,
                             pr.producto as numeroProducto
                INTO resultado_numeroCliente, resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2, resultado_porcentaje,
                     resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_numeroProducto
                FROM  bdinteg:"informix".si_cliente cte 
                    LEFT OUTER JOIN bdinvers:"informix".sv_benefic bene ON (cte.numcte = bene.numcte)                            
                    LEFT OUTER JOIN bdicheq:"informix".sc_maechq qc ON (qc.num_cte = cte.numcte) 
                    LEFT OUTER JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                    LEFT OUTER JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                    WHERE qc.cuenta = p_numeroCuentaBeneficiario 
                    AND bene.cuenta = p_numeroCuenta;
                                            
                  RETURN resultado_numeroCliente, resultado_numeroCuenta, resultado_estatus,resultado_motivo , resultado_porcentaje , resultado_numeroProducto , resultado_apellidoPat,resultado_apellidoMat,resultado_nombre1 ,resultado_nombre2 ;    
            
            END IF;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_liquidacion_cuenta_pagare_cambio_inst(p_idSolicitud INTEGER, p_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario char(8))

    RETURNING CHAR(6) as codigoRetorno,
            CHAR(250) as mensajeRetorno,
            CHAR(20) AS cuentaBeneficiario,
            CHAR(20) as cuentaClienteFallecido,
            CHAR(100) as nombreBeneficiario;

    -- DEFINICION DE VARIABLES DE RETORNO
    DEFINE codigoRetorno            CHAR(6);
    DEFINE mensajeRetorno           CHAR(250);
    DEFINE cuentaBeneficiario       CHAR(20);
    DEFINE cuentaClienteFallecido   CHAR(20);
    DEFINE nombreBeneficiario       CHAR(100);

    DEFINE resultado_pky_control_tramite INTEGER;

    DEFINE resultado_num_cliente            CHAR(9);
    DEFINE resultado_folio_csuac            CHAR(12);
    DEFINE resultado_fky_usuario_analista   INTEGER;
    DEFINE resultado_num_sucursal           CHAR(5);

    DEFINE resultado_cta_cheques    CHAR(20);

    DEFINE p_empresa    CHAR(3);
    DEFINE p_ejecutivo  CHAR(3);

    DEFINE resultado_sp_cambia_instrucc CHAR(5);

    DEFINE resultado_asign_usuario INTEGER;
    DEFINE resultado_asign_num_empleado CHAR(9);

    DEFINE resultado_asign_usuario_2 INTEGER;

    DEFINE resultado_nume_cliente CHAR(9);
    DEFINE resultado_nombreBeneficiario CHAR(100);

    DEFINE resultado_fecha_vencimiento  DATE;

    DEFINE resultado_cuenta_estatus CHAR(1);
    DEFINE resultado_cuenta_motivo CHAR(2);

    -- DESBLOQUEO DE CUENTA
    DEFINE codret_blqcta CHAR(6);
    DEFINE menret_blqcta CHAR(250);

    DEFINE resultado_pky_usuario INTEGER;

    DEFINE resultado_saldo_cong MONEY;
    DEFINE resultado_pky_permiso INTEGER;

    --------------------------------------------------------
    LET codigoRetorno = '';
    LET mensajeRetorno = '';
    LET cuentaBeneficiario = '';
    LET cuentaClienteFallecido = '';

    LET resultado_pky_control_tramite = 0;

    LET resultado_num_cliente = '';
    LET resultado_folio_csuac = '';
    LET resultado_fky_usuario_analista = 0;
    LET resultado_num_sucursal = '';

    LET resultado_cta_cheques = '';

    LET resultado_sp_cambia_instrucc = '';

    -- CONSTANTES
    LET p_empresa = '001';
    LET p_ejecutivo = '1';

      LET resultado_asign_usuario = 0;
    LET resultado_asign_num_empleado = '';
    LET resultado_asign_usuario_2 = 0;

    LET resultado_nume_cliente = '';
    LET resultado_nombreBeneficiario = '';

    LET resultado_fecha_vencimiento = DATE(1);

    LET resultado_cuenta_estatus = '';
    LET resultado_cuenta_motivo = '';
    LET resultado_saldo_cong  = 0;
    -- LOG
    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/cambioInstruccionPagare_"||p_idSolicitud||"_"||TRIM(p_cta_beneficiario)||"_34.out";
    --TRACE ON;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
      -- OBTENER EL PKY DEL USUARIO
      SELECT pky_usuario
      INTO resultado_pky_usuario
      FROM acl_usuario WHERE num_empleado = p_usuario;

      IF(resultado_pky_usuario) IS NULL THEN
        LET resultado_pky_usuario = 0;    -- EN CASO DE QUE NO SE ENCUENTRE EL USUARIO EN LA BASE DE DATOS DE ACLARACIONES
      END IF

      -- OBTENER NOMBRE DE BENEFICIARIO
      SELECT nombre_cliente
      INTO resultado_nombreBeneficiario
      FROM  fal_beneficiario
      WHERE  pky_cuenta_beneficiario = p_cta_beneficiario
      AND pky_cuenta_cliente_fallecido = p_cta_cliente;

        -- SE OBTIENE INFORMACION DE LA SOLICITUD
        SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal
        INTO resultado_num_cliente, resultado_folio_csuac,resultado_fky_usuario_analista,resultado_num_sucursal
        FROM fal_solicitud
        WHERE pky_solicitud = p_idSolicitud;

        -- SE OBTIENE INFORMACION DE LA TABLA DE CONTROL TRAMITE
        SELECT pky_control_tramite,fecha_vencimiento_pagare
        INTO resultado_pky_control_tramite,resultado_fecha_vencimiento
        FROM fal_control_tramite
        WHERE fky_solicitud = p_idSolicitud
        AND tramite = 1
        AND exitoso = 0
        AND fky_tipo_tramite = 3
        AND cuenta_cliente_fallecido = p_cta_cliente
        AND cuenta_beneficiario = p_cta_beneficiario;

        -- SE OBTIENE INFORMACION DEL PAGARE
        SELECT inv.cta_cheques
        INTO resultado_cta_cheques
        FROM bdinvers:"informix".sv_maeinv inv
        WHERE inv.status_cta = '1' -- ACTIVO
        AND inv.cuenta = p_cta_cliente;

        -- SE EJECUTA EL SP DE CAMBIO DE INSTRUCCION
        -- procedure "informix".cambinstrucc(pempresa    char(3),
        --                                 pcuenta     char(20),
        --                                 pinstcap    char(2),
        --                                 pinstint    char(2),
        --                                 pctacap     char(20),
        --                                 pctaint     char(20),
        --                                 pfechavenc  date,
        --                                pusuariomod char(8),
        --                                 pejecuta    char(1))

        -- VERIFICA SI EN ALGUN MOMENTO SE REALIZO EL BLOQUEO POR FALLECIMIENTO
        -- SE NECESITA DESBLOQUEAR LA CUENTA PARA REALIZAR EL CAMBIO DE INSTRUCCION
        -- EN ALGUN OTRO CASO SE MANDA A CENTRAL
      SELECT status_cta, motivo
      INTO resultado_cuenta_estatus,resultado_cuenta_motivo
      FROM bdicheq:"informix".sc_maechq
      WHERE cuenta = resultado_cta_cheques;

      IF p_cta_cliente IS NULL THEN
        LET p_cta_cliente = '';
      END IF
      IF p_cta_beneficiario IS NULL THEN
        LET p_cta_beneficiario = '';
      END IF
      IF p_usuario IS NULL THEN
        LET p_usuario = '';
      END IF


      IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usuario) = '' THEN

        LET codigoRetorno = '000001';
        LET mensajeRetorno  = 'Su folio se ha enviado a área interna.';
        LET cuentaBeneficiario = p_cta_beneficiario;
        LET cuentaClienteFallecido = p_cta_cliente;
        LET nombreBeneficiario = resultado_nombreBeneficiario;

        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: Parámetros incorrectos.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

        RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

      END IF

      IF resultado_cuenta_estatus = '3' THEN

        IF resultado_cuenta_motivo = '04' THEN
            SELECT sdo_cong INTO resultado_saldo_cong FROM bdicheq:sc_maechq WHERE cuenta=resultado_cta_cheques;

            CALL bdicheq:"informix".bloqueo_cta(p_empresa,resultado_cta_cheques, resultado_saldo_cong, '00',0,today,p_usuario,'4469','07','A','12','Z') RETURNING codret_blqcta,menret_blqcta;

                  IF TRIM(codret_blqcta) = '000' THEN

                       -- SE REALIZO CORRECTAMENTE EL DESBLOQUEO PARA REALIZAR EL CAMBIO DE INSTRUCCION
                      CALL bdinvers:"informix".cambinstrucc(p_empresa, p_cta_cliente,'02','02',resultado_cta_cheques,resultado_cta_cheques,resultado_fecha_vencimiento,p_usuario,p_ejecutivo)
                RETURNING resultado_sp_cambia_instrucc;

                IF TRIM(resultado_sp_cambia_instrucc) = '000' THEN

                        -- SE ACTUALIZA EL CONTROL PARA EL CRON DE LIQUIDACION DE PAGARES
                        UPDATE fal_control_tramite
                        SET cambio_instruccion_pagare = 1, tramite_fecha_vencimiento = 1, fky_estatus_corporativo = 10, fky_estatus_sucursal = 6
                        WHERE pky_control_tramite = resultado_pky_control_tramite;

                        -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE
                        CALL bdicheq:"informix".bloqueo_cta(p_empresa,TRIM(resultado_cta_cheques), resultado_saldo_cong, '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                        RETURNING codret_blqcta,menret_blqcta;

                        LET codigoRetorno   = '000000';
                        LET mensajeRetorno  = 'Su folio se ha enviado a área interna.';
                        LET cuentaBeneficiario = p_cta_beneficiario;
                        LET cuentaClienteFallecido = p_cta_cliente;
                        LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: En espera de fecha de vencimiento.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                        RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

                    ELSE

                        -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE
                        CALL bdicheq:"informix".bloqueo_cta(p_empresa,TRIM(resultado_cta_cheques), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                RETURNING codret_blqcta,menret_blqcta;

                          LET codigoRetorno = resultado_sp_cambia_instrucc;
                        LET mensajeRetorno  = 'Su folio se ha enviado a área interna.';
                        LET cuentaBeneficiario = p_cta_beneficiario;
                        LET cuentaClienteFallecido = p_cta_cliente;
                        LET nombreBeneficiario = resultado_nombreBeneficiario;

                        UPDATE fal_control_tramite
                        SET cambio_instruccion_pagare = 0, tramite_fecha_vencimiento = 0
                        WHERE pky_control_tramite = resultado_pky_control_tramite;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: No se pudo realizar el cambio de instrucción.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                        RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

                    END IF

                  END IF

        END IF

      ELSE

        CALL bdinvers:"informix".cambinstrucc(p_empresa, p_cta_cliente,'02','02',resultado_cta_cheques,resultado_cta_cheques,resultado_fecha_vencimiento,p_usuario,p_ejecutivo)
        RETURNING resultado_sp_cambia_instrucc;
            --------------------------------------------
            -- DEFINIR PARAMETROS DE RETORNO PARA EL CONTROL
            -- SI SE REALIZO CORRECTAMENTE EL CAMBIO DE INSTRUCCION
            IF resultado_sp_cambia_instrucc = '000' THEN

                -- SE ACTUALIZA EL CONTROL PARA EL CRON DE LIQUIDACION DE PAGARES
                UPDATE fal_control_tramite
                SET cambio_instruccion_pagare = 1, tramite_fecha_vencimiento = 1, fky_estatus_corporativo = 10, fky_estatus_sucursal = 6
                WHERE pky_control_tramite = resultado_pky_control_tramite;

                LET codigoRetorno   = '000000';
                LET mensajeRetorno  = 'Su folio se ha enviado a área interna.';
                LET cuentaBeneficiario = p_cta_beneficiario;
                LET cuentaClienteFallecido = p_cta_cliente;
                LET nombreBeneficiario = resultado_nombreBeneficiario;

          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: En espera de fecha de vencimiento.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
                RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

            ELSE

                  LET codigoRetorno = resultado_sp_cambia_instrucc;
                LET mensajeRetorno  = 'Se ha enviado a central.';
                LET cuentaBeneficiario = p_cta_beneficiario;
                LET cuentaClienteFallecido = p_cta_cliente;
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                UPDATE fal_control_tramite
                SET cambio_instruccion_pagare = 0, tramite_fecha_vencimiento = 0
                WHERE pky_control_tramite = resultado_pky_control_tramite;

          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: No se pudo realizar el cambio de instrucción.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

            END IF

      END IF

        -- SE ASIGNA ANALISTA
          -- SE ASIGNA UN ANALISTA PARA LA SOLICITUD
        -- VALIDA SI YA SE HA ASIGNADO A UN ANALISTA
      IF resultado_fky_usuario_analista IS NULL THEN

        LET resultado_pky_permiso = (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO');

        -- PRIMERO SE VERIFICA QUE HAYA USUARIOS CON LOS PERMISOS DEL TABLARO Y TABLERO AE
        -- select first 1 distinct(au.num_empleado), au.pky_usuario
        SELECT count(*)
        INTO resultado_asign_usuario
        FROM acl_usuario au
        INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
        INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
        INNER JOIN acl_permiso ap on app.fky_id_permiso = ap.pky_id_permiso
        -- WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO');
        WHERE app.fky_id_permiso = resultado_pky_permiso;

        -- IF resultado_asign_usuario IS NULL THEN
        IF resultado_asign_usuario = 0 THEN
            -- SE REGRESA CODIGO DE RETORNO
                LET codigoRetorno   = '000005';
              LET mensajeRetorno    = 'Su folio se ha enviado a área interna';
              LET cuentaBeneficiario = p_cta_beneficiario;
              LET cuentaClienteFallecido = p_cta_cliente;
              LET nombreBeneficiario = resultado_nombreBeneficiario;

          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: No hay analistas con los permisos requeridos.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

          RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

        ELSE
          -- QUERY PARA OBTENER EL USUARIO QUE NO TENGA ASIGNADA UNA SOLICITUD
          select first 1 au.pky_usuario as pky_usuario
          INTO resultado_asign_usuario_2
          FROM acl_usuario au
          INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
          INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
          INNER JOIN acl_permiso ap on app.fky_id_permiso = ap.pky_id_permiso
          -- WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO')
          WHERE app.fky_id_permiso = resultado_pky_permiso
          AND au.pky_usuario not in
          (SELECT au.pky_usuario
            FROM acl_usuario au
            INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
            INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
            INNER JOIN fal_solicitud fs on fs.fky_usuario_analista = au.pky_usuario
            --WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO'));
            WHERE app.fky_id_permiso = resultado_pky_permiso);

          -- SE VALIDA SI NO SE OBTIENE ALGUN USUARIO QUE NO TENGA ASIGNADA UNA SOLICITUD
          IF resultado_asign_usuario_2 IS NULL THEN
            -- SE OBTIENE EL NUMERO MAXIMO DE SOLICITUDES PARA REALIZAR LA ASIGNACION DE SOLICITUDES CON EL MENOR Y MISMO NUMERO DE CONTEO
            FOREACH
              SELECT first 1 au.pky_usuario
              INTO resultado_asign_usuario_2
              FROM acl_usuario au
              INNER JOIN fal_solicitud fs ON fs.fky_usuario_analista = au.pky_usuario
              INNER JOIN acl_perfil_usuario apu ON apu.fky_usuario = au.pky_usuario
              INNER JOIN acl_perfil_permiso app ON app.fky_id_perfil = apu.fky_id_perfil
              --WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO')
              WHERE app.fky_id_permiso = resultado_pky_permiso
              GROUP BY au.pky_usuario
              ORDER BY count(*) ASC
            END FOREACH;

            -- SE REALIZA LA ASIGNACION AL ANALISTA QUE NO TIENE ASIGNACION DE SOLICITUD
            UPDATE fal_solicitud SET fky_usuario_analista = resultado_asign_usuario_2
            WHERE pky_solicitud = p_idSolicitud;

            UPDATE fal_control_tramite SET fky_estatus_corporativo = 2, fky_estatus_sucursal = 2
            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

            -- SE REALIZA LA ASIGNACION DE SOLICITUD
            LET codigoRetorno = '000008';
            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
            LET cuentaBeneficiario = p_cta_beneficiario;
            LET cuentaClienteFallecido = p_cta_cliente;
            LET nombreBeneficiario = resultado_nombreBeneficiario;

            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: Se asignó un analista.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

            RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;

          ELSE
            -- SE REALIZA LA ASIGNACION AL ANALISTA QUE NO TIENE ASIGNACION DE SOLICITUD
            UPDATE fal_solicitud SET fky_usuario_analista = resultado_asign_usuario_2
            WHERE pky_solicitud = p_idSolicitud;

            UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
            where pky_control_tramite = resultado_pky_control_tramite_cuenta;

            -- SE REALIZA ASIGANCION DE SOLICITUD
            LET codigoRetorno       = '000008';                       -- CODIGO DEFINIDO
            LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';   -- SE REALIZO LA ASIGNACION DE ANALISTA
            LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO
            LET cuentaClienteFallecido = p_cta_cliente;
            LET nombreBeneficiario = resultado_nombreBeneficiario;

            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: Se asignó un analista.',current,resultado_folio_csuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

            RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario;


          END IF

        END IF

      END IF

    END

END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_valida_cierre_folio(p_idSolicitud INTEGER)

	RETURNING CHAR(6) as codigoRetorno,
            CHAR(250) as mensajeRetorno;

    DEFINE resultado_cod_ret CHAR(6);
    DEFINE resultado_msg_ret CHAR(250);
    DEFINE resultado_conteo_total 		INTEGER;
    DEFINE resultado_conteo_exitoso		INTEGER;
    DEFINE resultado_conteo_credito		INTEGER;
    DEFINE pEmpresa CHAR(3);
    DEFINE pTipoProceso SMALLINT;
    DEFINE resultado_num_cliente CHAR(9);
    DEFINE resultado_num_empleado CHAR(9);

    DEFINE cCodret  CHAR(6);
    DEFINE cMensajeRet CHAR(80);

    LET cCodret = '000000';
    LET cMensajeRet = 'Mensaje Exitoso';
    LET pEmpresa = '001';
    LET resultado_cod_ret = '';
   	LET resultado_msg_ret = '';
   	LET resultado_conteo_total = 0;
   	LET resultado_conteo_exitoso = 0;
   	LET pTipoProceso = 4;

    -- LOG
    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/validaCierreFolio_"||p_idSolicitud||"_34.out";
  	--TRACE ON;
  	SET ISOLATION TO DIRTY READ;
  	SET LOCK MODE TO WAIT 3;

    BEGIN

    	SELECT count(fky_solicitud) as conteoTotal
		INTO resultado_conteo_total
		FROM fal_control_tramite
		WHERE fky_tipo_tramite not in (5)
		AND fky_solicitud = p_idSolicitud;

		SELECT count(fky_solicitud) as conteoExitoso
		INTO resultado_conteo_exitoso
		FROM fal_control_tramite
		WHERE fky_tipo_tramite not in (5)
		AND fky_solicitud = p_idSolicitud
		AND exitoso = 1 and fecha_cancelacion is not null;

		SELECT num_cliente,num_empleado
		INTO resultado_num_cliente,resultado_num_empleado
		FROM fal_solicitud
		WHERE pky_solicitud = p_idSolicitud;

		-- REALIZA EN CONTEO DE CUENTAS CON CREDITO SIN TARJETA 
        -- NUMERO PRODUCTO: 8100
        SELECT count(fky_tipo_tramite) as conteoCuentasCredito
        INTO resultado_conteo_credito
        FROM fal_control_tramite
        WHERE fky_solicitud = p_idSolicitud 
        AND descripcion_detalle = 'CREDITO S/TARJETA';

		IF resultado_conteo_total = resultado_conteo_exitoso THEN

			-- SE CIERRA EL FOLIO
			UPDATE fal_solicitud
			SET fky_estatus_general = 3, fecha_cierre = today
			WHERE pky_solicitud = p_idSolicitud;

			--SE MANDA MARCAJE DE CLIENTE FALLECIDO F42
            --SE comenta porque se solicito que el marcaje F42 fuera al digitalizar el ultimo documento del cliente fallecido
			--CALL bdisitesp:"informix".sp_marcajesitesp(pEmpresa,  pTipoProceso, resultado_num_cliente, resultado_num_empleado)
			--RETURNING cCodret, cMensajeRet;

			LET resultado_cod_ret = '000000';
			LET resultado_msg_ret = 'Cierre de folio.';

			RETURN resultado_cod_ret,resultado_msg_ret;

		END IF

		LET resultado_cod_ret = '000001';
		LET resultado_msg_ret = 'Sin cierre de folio.';

		RETURN resultado_cod_ret,resultado_msg_ret;

    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cancelacion_cuenta_credito(p_idSolicitud INTEGER, p_numero_credito CHAR(20), p_Promotor CHAR(8), p_Supervisor CHAR(8), p_Sucursal CHAR(10),pky_resolucion INTEGER,cancelacion_manual INTEGER)
  RETURNING CHAR(6) as codigoRetorno, 
      CHAR(250) as mensajeRetorno,
      CHAR(20) as numeroCredito,
      CHAR(16) as numeroTarjeta;

-- 0) DEFINICION DE VARIABLES DE RETORNO
DEFINE codigoRetorno        CHAR(6);
DEFINE mensajeRetorno       CHAR(250);  
DEFINE numeroCredito  CHAR(20);
DEFINE numeroTarjeta  CHAR(16);

DEFINE resultado_numero_cliente       CHAR(9);
DEFINE resultado_foliocsuac           CHAR(12);
DEFINE resultado_fky_usuario_analista INTEGER;

-- 00) QUERY DE CONTROL
DEFINE resultado_pky_control_tramite_cuenta   INTEGER;
DEFINE resultado_num_cta_cliente              CHAR(20); 
DEFINE resultado_num_cta_beneficiario         CHAR(20);
DEFINE resultado_porcentaje_bene              DECIMAL(9,6);
DEFINE resultado_tramite                      INTEGER;
DEFINE resultado_tipo_producto_ctrl           INTEGER;
DEFINE resultado_exitoso                      INTEGER;
DEFINE resultado_tipo_cancelacion             INTEGER;
DEFINE resultado_fecha_vencimiento            DATE;
DEFINE resultado_monto_original               MONEY(14,2);
DEFINE resultado_monto_pagare                 MONEY(14,2);
DEFINE resultado_cargo_bandera                MONEY(14,2);
DEFINE resultado_estatus_corporativo            INTEGER;
DEFINE resultado_estatus_sucursal               INTEGER;

-- 1) DEFINICION DE VARIABLES DE SP DE CONSULTA DE SALDOS
-- call bdicred:"informix".sp_consulta_saldos_general
DEFINE numero_credito CHAR(20);
DEFINE codigo_tipcred CHAR(2);
DEFINE fecha_origen DATE;
DEFINE fecha_prox_pago DATE;
DEFINE pago_minimo DECIMAL(18,2);
DEFINE fecha_ult_pago DATE;
DEFINE plazo INTEGER;
DEFINE pagos_realizados INTEGER;
DEFINE linea_otorgada DECIMAL(18,2);
DEFINE tasa_interes DECIMAL(9,6);
DEFINE tasa_moratorios DECIMAL(9,6);
DEFINE monto_sbc DECIMAL(14,2);
DEFINE cap_vig DECIMAL(18,2);
DEFINE cap_trans DECIMAL(18,2);
DEFINE cap_vdo_exig DECIMAL(18,2);
DEFINE cap_vdo_no_exig DECIMAL(18,2);
DEFINE sdo_act_total_cap DECIMAL(18,2);
DEFINE int_vig DECIMAL(18,2);
DEFINE int_vdo DECIMAL(18,2);
DEFINE int_moratorios DECIMAL(18,2);
DEFINE int_mes DECIMAL(18,2);
DEFINE sdo_act_total_int DECIMAL(18,2);
DEFINE iva_int_vig DECIMAL(18,2);
DEFINE iva_int_vdo DECIMAL(18,2);
DEFINE iva_int_moratorios DECIMAL(18,2);
DEFINE iva_int_mes DECIMAL(18,2);
DEFINE sdo_act_total_iva DECIMAL(18,2);
DEFINE com_pend DECIMAL(18,2);
DEFINE iva_com DECIMAL(18,2);
DEFINE sdo_retenido DECIMAL(18,2);
DEFINE total_liquidacion DECIMAL(18,2);
DEFINE int_devengado DECIMAL(18,2);
DEFINE iva_int_devengado DECIMAL (18,2);
DEFINE linea_disponible DECIMAL(18,2);
DEFINE pagos_vdos DECIMAL(18,2);
DEFINE desc_status_cred CHAR(60);
DEFINE id_bloqueo_cred INTEGER;
DEFINE bloqueo_cta CHAR(60);
DEFINE id_causa_bloqueo_cred CHAR(3);
DEFINE causa_bloqueo_cta CHAR(50);
DEFINE id_sit_esp_cte CHAR(1);
DEFINE id_causa_esp_cte INTEGER;
DEFINE sit_esp_cte CHAR(75);
DEFINE id_sit_esp_cred CHAR(1);
DEFINE id_causa_esp_cred INTEGER;
DEFINE sit_esp_cred CHAR(75);

-- 2) OBTENER ACCION POR REGLA DE NEGOCIO
DEFINE resultado_accion         INTEGER;
DEFINE resultado_num_empleado   CHAR(8);
DEFINE resultado_num_suc        CHAR(4);

-- 3) 
DEFINE resultado_tipo_producto INTEGER;
DEFINE v_numero_documentos_digitalizados_fallecido INTEGER;
DEFINE v_numero_documentos_necesarios_fallecido   INTEGER;

-- 4) SP CONDONACION DE CREDITO
DEFINE p_trans_condona_credito CHAR(4);
DEFINE p_remanente MONEY(14,2);         -- Remanente
DEFINE p_interesMoraCobrado MONEY(14,2);    -- Interes Moratorio Cobrado
DEFINE p_InterersVencidoCobrado MONEY(14,2);  -- Interes Vencido Cobrado
DEFINE p_CapitaVencidoCobrado MONEY(14,2);    -- Capital Vencido Cobrado
DEFINE p_InterersVigenteCobrado MONEY(14,2);  -- Interes Vigente Cobrado
DEFINE p_CaptalvigenteCobrado MONEY(14,2);    -- Capital Vigente Cobrado
DEFINE p_ImpuestoCobrado MONEY(14,2);       -- Impuesto Cobrado
DEFINE p_ComisionesCobradas MONEY(14,2);    -- Comisiones Cobradas
DEFINE p_SeguroCobrado MONEY(14,2);       -- Seguro Cobrado 

-- 5) SP CANCELAR CREDITO sp_cancelarcredito
DEFINE cancelarCodigoRet CHAR(6);
DEFINE cancelarMensajeRet CHAR(80);

-- CONSTANTES
DEFINE p_Empresa      CHAR(3);
DEFINE p_Ejecutivo      CHAR(20);
DEFINE p_Motivo       CHAR(2);  
DEFINE p_TipoCancelacion  CHAR(4);

DEFINE resultado_pky_rango_importe  INTEGER;
DEFINE resultado_rango_inferior      MONEY;
DEFINE resultado_accion_cumple INTEGER;
DEFINE resultado_accion_no_cumple INTEGER;
DEFINE resultado_accion_procede INTEGER;
DEFINE resultado_accion_no_procede INTEGER;

-- SE GENERA EL FOLIO SUC
DEFINE p_fecha_folio  CHAR(10);
DEFINE p_FolioSUC     CHAR(16);

-- VARIABLES PARA DESBLOQUEO DE CREDITO
DEFINE codigoRetornoDesbloqueo CHAR(6);
DEFINE mensajeRetornoDesbloqueo CHAR(80);

DEFINE resultado_saldoCred MONEY(14,2);
DEFINE resultado_secuencia INTEGER;
DEFINE resultado_numero_tarjeta   CHAR(20);

-- VARIABLES PARA EL RETORNO DEL SP sp_cargo_abono_aclara
DEFINE cargoAbonoCodRetorno CHAR(5);
DEFINE cargoAbonoMenRetorno CHAR(80);

DEFINE resultado_pky_usuario INTEGER;
DEFINE desc_corporativo CHAR(40);
DEFINE desc_sucursal CHAR(40);
DEFINE desc_campo_saldo_anterior CHAR(40);
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
LET desc_corporativo = 'CANCELACION FALLECIDO CORPORATIVO';
LET desc_sucursal = 'CANCELACION FALLECIDO AUTOMATICO';
LET desc_campo_saldo_anterior = '';

-- 00) QUERY DE CONTROL
LET resultado_pky_control_tramite_cuenta  = 0;
LET resultado_num_cta_cliente             = '';
LET resultado_num_cta_beneficiario        = '';
LET resultado_porcentaje_bene             = 0;
LET resultado_tramite                     = 0;
LET resultado_exitoso                     = 0;
LET resultado_tipo_cancelacion            = 0;
LET resultado_fecha_vencimiento           = DATE(1);
LET resultado_monto_original              = 0;
LET resultado_monto_pagare                = 0;
LET resultado_cargo_bandera         = 0;
LET resultado_estatus_corporativo   = 0;
LET resultado_estatus_sucursal      = 0;

-- 0) DEFINICION DE VARIABLES DE ENTORNO
LET codigoRetorno = '';
LET mensajeRetorno  = '';  

LET resultado_numero_cliente = '';
LET resultado_foliocsuac = '';

-- 2) OBTENER ACCION POR REGLA DE NEGOCIO
LET resultado_accion = 0;
LET resultado_num_empleado = '';
LET resultado_num_suc = '';

LET resultado_pky_rango_importe = 0;
LET resultado_rango_inferior = 0;
LET resultado_accion_cumple = 0;
LET resultado_accion_no_cumple = 0;
LET resultado_accion_procede = 0;
LET resultado_accion_no_procede = 0;

LET numeroCredito = '';
LET numeroTarjeta = '';

LET v_numero_documentos_necesarios_fallecido = 0;
LET v_numero_documentos_digitalizados_fallecido = 0;

-- CONSTANTES
LET p_Empresa = '001';
LET p_Ejecutivo = '001';
LET p_Motivo = '2'; -- Fallecimiento > bdicred:sd_cat_cancred
LET p_TipoCancelacion = '2';

LET resultado_saldoCred = 0;
LET resultado_numero_tarjeta = '';

-- SE COMENTA PARA ENTREGA 1 DIC
--SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/sp_fal_cancelacion_cuenta_credito"||p_numero_credito||".out"; 
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
  
  IF (cancelacion_manual = 0) THEN 
    
    SELECT num_cliente,folio_csuac,fky_usuario_analista
    INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista
    FROM fal_solicitud
    WHERE pky_solicitud = p_idSolicitud;

    -- VALIDACION DE PARAMETROS DE ENTRADA  
    IF p_numero_credito IS NULL THEN
      LET p_numero_credito = '';
    END IF
    IF p_Promotor IS NULL THEN
      LET p_Promotor = '';
    END IF
    IF p_Supervisor IS NULL THEN
      LET p_Supervisor = '';
    END IF
    IF p_Sucursal IS NULL THEN
      LET p_Sucursal = '';
    END IF

    IF TRIM(p_numero_credito) = '' OR TRIM(p_Promotor) = '' OR TRIM(p_Supervisor) = '' OR TRIM(p_Sucursal) = '' THEN 
      LET codigoRetorno = '000001';
      LET mensajeRetorno = 'Información incompleta.';
      LET numeroCredito = resultado_num_cta_cliente;
      LET numeroTarjeta = resultado_num_cta_beneficiario;

      RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

    END IF

    -- OBTENER EL PKY DEL USUARIO
    SELECT pky_usuario
    INTO resultado_pky_usuario
    FROM acl_usuario WHERE num_empleado = p_Promotor;

    IF(resultado_pky_usuario) IS NULL THEN
      LET resultado_pky_usuario = 0;
    END IF

    -- 00) QUERY DE CONTROL
    SELECT pky_control_tramite, 
    cuenta_cliente_fallecido, 
              cuenta_beneficiario, 
              monto_porcentaje, 
              tramite, 
              exitoso, 
              fky_tipo_tramite,
              fky_tipo_producto,
              fecha_vencimiento_pagare,
              monto_original,
              monto_calculado,
              monto_cargo
            INTO resultado_pky_control_tramite_cuenta, 
              resultado_num_cta_cliente, 
              resultado_num_cta_beneficiario, 
              resultado_porcentaje_bene, 
              resultado_tramite, 
              resultado_exitoso, 
              resultado_tipo_cancelacion,
              resultado_tipo_producto_ctrl,
              resultado_fecha_vencimiento,
              resultado_monto_original,
              resultado_monto_pagare,
              resultado_cargo_bandera
            FROM fal_control_tramite
            WHERE fky_solicitud = p_idSolicitud
            AND tramite = 1
            AND exitoso = 0
            AND fky_tipo_tramite = 2
            AND cuenta_cliente_fallecido = p_numero_credito
            --AND (case when fky_estatus_corporativo is null then 0 end) not in (3,4,9,11);
            --AND nvl(fky_estatus_corporativo,0) not in (3,4,9,11);
            AND (fky_estatus_corporativo is null or fky_estatus_corporativo not in (3,4,9,11));

            IF resultado_pky_control_tramite_cuenta IS NULL THEN

                SELECT pky_control_tramite, 
                cuenta_cliente_fallecido, 
                cuenta_beneficiario, 
                monto_porcentaje, 
                tramite, 
                exitoso, 
                fky_tipo_tramite,
                fky_tipo_producto,
                fecha_vencimiento_pagare,
                monto_original,
                monto_calculado,
                monto_cargo,
                fky_estatus_corporativo,
                fky_estatus_sucursal
                INTO resultado_pky_control_tramite_cuenta, 
                resultado_num_cta_cliente, 
                resultado_num_cta_beneficiario, 
                resultado_porcentaje_bene, 
                resultado_tramite, 
                resultado_exitoso, 
                resultado_tipo_cancelacion,
                resultado_tipo_producto_ctrl,
                resultado_fecha_vencimiento,
                resultado_monto_original,
                resultado_monto_pagare,
                resultado_cargo_bandera,
                resultado_estatus_corporativo,
                resultado_estatus_sucursal
                FROM fal_control_tramite
                WHERE fky_solicitud = p_idSolicitud
                AND tramite = 1
                AND exitoso = 0
                AND fky_tipo_tramite = 2
                AND cuenta_cliente_fallecido = p_numero_credito;

                LET codigoRetorno = '000004';
                LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                LET numeroCredito = resultado_num_cta_cliente;
                LET numeroTarjeta = resultado_num_cta_beneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta se encuentra en estatus. Corp: ' || resultado_estatus_corporativo || ' / Suc: ' || resultado_estatus_sucursal ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;
            END IF

            SELECT count(*)
            INTO v_numero_documentos_digitalizados_fallecido
            FROM fal_control_digitaliza_doc FCDD
            WHERE FCDD.cuenta_cliente_fallecido = resultado_numero_cliente AND FCDD.cuenta_beneficiario = resultado_numero_cliente
            AND FCDD.inconsistencia = 0;

            SELECT count(*) 
            INTO v_numero_documentos_necesarios_fallecido
            FROM fal_grupo_documento GD 
            INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
            WHERE GD.fky_grupo_documento in (1,2);

            -- LET v_numero_documentos_digitalizados_fallecido = 1;
            -- LET v_numero_documentos_necesarios_fallecido = 1;

            -- EN CASO DE SER CREDITO ORO TIPO PRODUCTO = 41, NUMERO PRODUCTO = 8100
            -- SE REALIZA EL CAMBIO DE ESTATUS PARA ANALISIS Y SE REALIZA LA ASIGNACION DE ANALISTA
            IF resultado_num_cta_cliente = resultado_num_cta_beneficiario THEN

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'La cuenta no tiene tarjeta, se asignará un analista.',sysdate,resultado_foliocsuac,'CANCELACION CREDITO SIN TARJETA',resultado_pky_usuario,p_Promotor);              

                CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;
                LET codigoRetorno = '000004';
                LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                LET numeroCredito = resultado_num_cta_cliente;
                LET numeroTarjeta = 'Sin Tarjeta';

                RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

            END IF

            

            --EN CASO DE NO CONTAR CON LA DOCUMENTACION COMPLETA  
            IF v_numero_documentos_digitalizados_fallecido < v_numero_documentos_necesarios_fallecido AND v_numero_documentos_digitalizados_fallecido != 0 THEN

                LET codigoRetorno = '000004';
                LET mensajeRetorno = 'Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso.';
                LET numeroCredito = resultado_num_cta_cliente;
                LET numeroTarjeta = resultado_num_cta_beneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La documentación del cliente fallecido está incompleta. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

            END IF

            -- OBTENER LA TARJETA DEL CREDITO / SE OBTIENE LA ULTIMA DE LA SECUENCIA AUNQUE NO ESTE ACTIVA
            SELECT first 1 max(tj.secuencia) as secuencia,tj.num_tarjeta
            INTO resultado_secuencia,resultado_numero_tarjeta
            FROM bdicred:sd_maecred cr
            LEFT JOIN bdicred:sd_tarjeta tj ON  (cr.num_credito = tj.num_credito)
            where cr.num_credito = p_numero_credito
            group by tj.num_tarjeta;

            -- SE DESBLOQUEA LA CUENTA DE CREDITO PARA PROCESO DE CANCELACION
            CALL bdicred:"informix".sp_desbloqueocuenta(p_Empresa, p_numero_credito, p_Supervisor,1)
            RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;
            -- PRUEBA DE EJECUCION
            --LET codigoRetornoDesbloqueo = '000001';
            --LET mensajeRetornoDesbloqueo = 'PruebaEJECUCION';

            IF codigoRetornoDesbloqueo = '000000' THEN -- 1 VALIDACION DEL DESBLOQUEO DE CUENTA

              -- 1) SP - CONSULTA DE SALDOS
              CALL bdicred:"informix".sp_consulta_saldos_general('001', p_numero_credito)
              RETURNING 
              codigoRetorno,mensajeRetorno,numero_credito,codigo_tipcred,fecha_origen,fecha_prox_pago,pago_minimo,fecha_ult_pago,plazo,pagos_realizados,linea_otorgada,tasa_interes,tasa_moratorios,monto_sbc,cap_vig,cap_trans,cap_vdo_exig,
              cap_vdo_no_exig,sdo_act_total_cap,int_vig,int_vdo,int_moratorios,int_mes,sdo_act_total_int,iva_int_vig,iva_int_vdo,iva_int_moratorios,iva_int_mes,sdo_act_total_iva,com_pend,iva_com,sdo_retenido,total_liquidacion,int_devengado,
              iva_int_devengado,linea_disponible,pagos_vdos,desc_status_cred,id_bloqueo_cred,bloqueo_cta,id_causa_bloqueo_cred,causa_bloqueo_cta,id_sit_esp_cte,id_causa_esp_cte,sit_esp_cte,id_sit_esp_cred,id_causa_esp_cred,sit_esp_cred;
              -- PRUEBA DE EJECUCION
              --LET codigoRetorno = '000001';

              IF TRIM(codigoRetorno) = '000000' THEN  -- 2 VALIDAR SI LA CONSULTA DE SALDOS FUE CORRECTA

                -- A CONTINUACION SE VERIFICA QUE ACCION TOMAR DE ACUERDO A LA REGLA DE NEGOCIO
                -- 2) OBTENER ACCION POR REGLA DE NEGOCIO


                IF total_liquidacion < 1 THEN

                  LET resultado_rango_inferior = 1;

                ELSE

                  SELECT frimp.pky_rango_importe,frimp.rango_inferior
                  INTO resultado_pky_rango_importe,resultado_rango_inferior
                  FROM fal_solicitud fsol
                  INNER JOIN fal_cat_evento ceve ON ceve.pky_evento = fsol.fky_evento AND ceve.fky_origen_evento = fsol.fky_origen_evento      
                  INNER JOIN fal_regla_negocio frn ON frn.fky_evento = ceve.pky_evento AND frn.fky_origen_evento = ceve.fky_origen_evento
                  INNER JOIN fal_rango_importe frimp ON frimp.fky_regla_negocio = frn.pky_regla_negocio
                  WHERE frimp.rango_inferior <= total_liquidacion AND frimp.rango_mayor >= total_liquidacion
                  AND fsol.pky_solicitud = p_idSolicitud      
                  AND frn.activo = 1;

                  -- SE OBTIENEN LAS ACCIONES A REALIZAR POR EL RANGO IMPORTE
                  SELECT frimpacc.cumple,frimpacc.no_cumple,frimpacc.procede,frimpacc.no_procede
                  INTO resultado_accion_cumple, resultado_accion_no_cumple, resultado_accion_procede, resultado_accion_no_procede
                  FROM fal_rango_importe_accion frimpacc
                  WHERE frimpacc.fky_rango_importe = resultado_pky_rango_importe;

                END IF
                -- SE AGREGA LA REGLA DE NEGOCIO PARA LA CANCELACION DE CREDITO DE MANERA AUTOMATICA
                IF (resultado_accion_cumple = 1 and pky_resolucion = 0) or pky_resolucion != 0 THEN -- 3 SE REALIZA LA CANCELACION DE MANERA AUTOMATICA

                  IF pky_resolucion = 0 THEN
                      --LET pky_resolucion = null;
                      LET desc_campo_saldo_anterior = desc_sucursal;
                  ELSE
                      LET desc_campo_saldo_anterior = desc_corporativo;
                  END IF

                  -- SE OBTIENE EL TIPO DE PRODUCTO
                  SELECT tp.pky_tipo_producto
                  INTO resultado_tipo_producto
                  FROM bdicred:sd_maecred sm, acl_tipo_producto tp
                  WHERE sm.num_producto = tp.producto
                  AND num_credito = p_numero_credito;

                  -- Se genera el folioSuc
                  LET p_fecha_folio = substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2);
                  
                  --SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
                  --INTO p_fecha_folio
                  --FROM systables WHERE tabid=1;

                  LET p_FolioSUC = trim(p_fecha_folio) || lpad(substr(resultado_foliocsuac,2,10),10,0);

                  IF resultado_cargo_bandera IS NULL THEN -- 4 VALIDACION DE CARGO NULL
                    -- SE VALIDA PARA EVITAR ENVIAR DE NUEVO LA CONDONACION DE CREDITO Y LA INSERCION DE LA INFORMACION DE CREDITO
                    -- Se insertan los datos en la tabla fal_saldo_anterior para el reporte

                   IF pky_resolucion = 0 THEN

                      INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                      capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                      interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                      fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                      VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION AUTOMATICO', resultado_numero_cliente, sdo_act_total_cap, 
                      cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                      p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO AUTOMATICO', resultado_tipo_producto, 'CANCELACION FALLECIDO AUTOMATICO',total_liquidacion,2);


                   ELSE

                      INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                      capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                      interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                      fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                      VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION CORPORATIVO', resultado_numero_cliente, sdo_act_total_cap, 
                      cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                      p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO CORPORATIVO', resultado_tipo_producto, 'CANCELACION FALLECIDO CORPORATIVO',total_liquidacion,2);

                   END IF


                    IF sdo_act_total_cap = 0 THEN --VALIDACION DE CUENTA EN 0 KJMM

                      CALL bdicred:"informix".sp_cancelarcredito (p_Empresa, p_numero_credito, '2', p_Promotor, p_Supervisor, '2', p_Sucursal )
                      RETURNING cancelarCodigoRet, cancelarMensajeRet;

                      -- PRUEBA DE FLUJO
                      --LET cancelarCodigoRet = '00002';
                      IF TRIM(cancelarCodigoRet) = '00000' THEN -- 13 VALIDACION DE CANCELACION DE CREDITO
                        -- SE CANCELO DE MANERA CORRECTA
                        UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 6, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap,descripcion_detalle='CANCELADA'
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                        -- SE CONSULTA EL SALDO UNA VEZ CANCELADO EL CREDITO
                        CALL bdicred:"informix".sp_consulta_saldos_general('001', p_numero_credito)
                        RETURNING 
                          codigoRetorno,mensajeRetorno,numero_credito,codigo_tipcred,fecha_origen,fecha_prox_pago,pago_minimo,fecha_ult_pago,plazo,pagos_realizados,linea_otorgada,tasa_interes,tasa_moratorios,monto_sbc,cap_vig,cap_trans,cap_vdo_exig,
                          cap_vdo_no_exig,sdo_act_total_cap,int_vig,int_vdo,int_moratorios,int_mes,sdo_act_total_int,iva_int_vig,iva_int_vdo,iva_int_moratorios,iva_int_mes,sdo_act_total_iva,com_pend,iva_com,sdo_retenido,total_liquidacion,int_devengado,
                          iva_int_devengado,linea_disponible,pagos_vdos,desc_status_cred,id_bloqueo_cred,bloqueo_cta,id_causa_bloqueo_cred, causa_bloqueo_cta,id_sit_esp_cte,id_causa_esp_cte,sit_esp_cte,id_sit_esp_cred,id_causa_esp_cred,sit_esp_cred;

                        IF TRIM(codigoRetorno) = '000000' THEN -- 14 VALIDACION DE CONSULTA DE SALDOS
                          -- SE INSERTA LA CONSULTA DEL SALDO DEL CREDITO CANCELADO

                          IF pky_resolucion = 0 THEN

                             INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                             capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                             interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                             fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                             VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION AUTOMATICO', resultado_numero_cliente, sdo_act_total_cap, 
                             cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                             p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO AUTOMATICO', resultado_tipo_producto, 'CANCELACION FALLECIDO AUTOMATICO',total_liquidacion,3);

                          ELSE

                             INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                             capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                             interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                             fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                             VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION CORPORATIVO', resultado_numero_cliente, sdo_act_total_cap, 
                             cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                             p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO CORPORATIVO', resultado_tipo_producto, 'CANCELACION FALLECIDO CORPORATIVO',total_liquidacion,3);

                          END IF


                          LET codigoRetorno = '000000';
                          LET mensajeRetorno = 'Crï¿½dito cancelado con éxito.';
                          LET numeroCredito = resultado_num_cta_cliente;
                          LET numeroTarjeta = resultado_num_cta_beneficiario;

                          -- 
                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta se ha cancelado correctamente. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                          RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          ELSE -- 14 VALIDACION DE CONSULTA DE SALDOS
                          -- OCURRIO UN ERROR EN LA CONSULTA DE SALDOS PARA INSERTAR EL REGISTRO DE SALDO DESPUES DE LA CANCELACION DE LA CUENTA                  
                          -- SE BLOQUE LA CUENTA DE CREDITO
                          CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                          RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                          IF codigoRetornoDesbloqueo = '000000' THEN -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                            CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                            RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            LET codigoRetorno = '000001';
                            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetornoDesbloqueo ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          ELSE  -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                            CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                            RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            LET codigoRetorno = codigoRetornoDesbloqueo;
                            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetornoDesbloqueo ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          END IF -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                        END IF -- 14 VALIDACION DE CONSULTA DE SALDOS


                      ELSE  -- 13 VALIDACION DE CANCELACION DE CREDITO
                        CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                        RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                        IF codigoRetornoDesbloqueo = '000000' THEN -- 16 VALIDACION DE BLOQUEO DE CREDITO

                          CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                          RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          LET codigoRetorno = '000002';
                          LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                          LET numeroCredito = resultado_num_cta_cliente;
                          LET numeroTarjeta = resultado_num_cta_beneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realiz´o la cancelación del crédito con desbloqueo. Cod: ' || codigoRetornoDesbloqueo || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                          RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        ELSE  -- 16 VALIDACION DE BLOQUEO DE CREDITO

                          CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                          RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          LET codigoRetorno = codigoRetornoDesbloqueo;
                          LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                          LET numeroCredito = resultado_num_cta_cliente;
                          LET numeroTarjeta = resultado_num_cta_beneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito con desbloqueo. Cod: ' || codigoRetornoDesbloqueo || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                          RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        END IF -- 16 VALIDACION DE BLOQUEO DE CREDITO

                      END IF -- 13 VALIDACION DE CANCELACION DE CREDITO
                    END IF --VALIDACION CUENTA EN 0 KJMM



                    IF sdo_act_total_cap < 0 THEN -- 5 VALIDAR QUE EL SALDO ES MENOR A CERO PARA EL TRASPASO 7727

                      CALL bdicred:"informix".sp_cargo_abono_aclara(p_Empresa,p_numero_credito, resultado_numero_tarjeta, (sdo_act_total_cap * -1), p_Promotor, TRIM(p_Sucursal), '7727', 1, p_FolioSUC)
                      RETURNING cargoAbonoCodRetorno,cargoAbonoMenRetorno;

                      IF TRIM(cargoAbonoCodRetorno) = '000' THEN -- 6 VALIDACION PARA CONDONACION EXITOSA              
                        -- SE PROSIGUE A CANCELAR EL CREDITO
                        UPDATE fal_control_tramite SET monto_cargo = sdo_act_total_cap, monto_original = sdo_act_total_cap, fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        CALL bdicred:"informix".sp_cancelarcredito (p_Empresa, p_numero_credito, '2', p_Promotor, p_Supervisor, '2', p_Sucursal )
                        RETURNING cancelarCodigoRet, cancelarMensajeRet;

                        -- PRUEBA DE FLUJO
                        --LET cancelarCodigoRet = '00002';
                        IF TRIM(cancelarCodigoRet) = '00000' THEN -- 9 VALIDACION DE CANCELACION DE CREDITO
                          -- SE CANCELO DE MANERA CORRECTA
                          IF pky_resolucion = 0 THEN
                            UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 6, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap,descripcion_detalle='CANCELADA'
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                          ELSE
                            UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 7, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap,descripcion_detalle='CANCELADA'
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                          END IF
                          -- SE CONSULTA EL SALDO UNA VEZ CANCELADO EL CREDITO
                          CALL bdicred:"informix".sp_consulta_saldos_general('001', p_numero_credito)
                          RETURNING 
                            codigoRetorno,mensajeRetorno,numero_credito,codigo_tipcred,fecha_origen,fecha_prox_pago,pago_minimo,fecha_ult_pago,plazo,pagos_realizados,linea_otorgada,tasa_interes,tasa_moratorios,monto_sbc,cap_vig,cap_trans,cap_vdo_exig,
                            cap_vdo_no_exig,sdo_act_total_cap,int_vig,int_vdo,int_moratorios,int_mes,sdo_act_total_int,iva_int_vig,iva_int_vdo,iva_int_moratorios,iva_int_mes,sdo_act_total_iva,com_pend,iva_com,sdo_retenido,total_liquidacion,int_devengado,
                            iva_int_devengado,linea_disponible,pagos_vdos,desc_status_cred,id_bloqueo_cred,bloqueo_cta,id_causa_bloqueo_cred, causa_bloqueo_cta,id_sit_esp_cte,id_causa_esp_cte,sit_esp_cte,id_sit_esp_cred,id_causa_esp_cred,sit_esp_cred;

                          IF TRIM(codigoRetorno) = '000000' THEN -- 10 VALIDACION DE CONSULTA DE SALDOS
                            -- SE INSERTA LA CONSULTA DEL SALDO DEL CREDITO CANCELADO

                          IF pky_resolucion = 0 THEN

                            INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                            capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                            interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                            fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento, total_liquidacion,tipo_movimiento_credito) 
                            VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION AUTOMATICO', resultado_numero_cliente, sdo_act_total_cap, 
                            cap_vig, cap_vdo_exig, cap_trans, cap_vdo_no_exig, sdo_act_total_cap, int_vig, iva_int_vig, int_vdo, iva_int_vdo, int_moratorios, monto_sbc, iva_int_moratorios, sysdate, 
                            p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO AUTOMATICO', resultado_tipo_producto, 'CANCELACION FALLECIDO AUTOMATICO',total_liquidacion,3);

                          ELSE

                             INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                             capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                             interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                             fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                             VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION CORPORATIVO', resultado_numero_cliente, sdo_act_total_cap, 
                             cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                             p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO CORPORATIVO', resultado_tipo_producto, 'CANCELACION FALLECIDO CORPORATIVO',total_liquidacion,3);

                          END IF


                            LET codigoRetorno = '000000';
                            LET mensajeRetorno = 'Crédito cancelado con éxito.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta se ha cancelado correctamente. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          ELSE -- 10 VALIDACION DE CONSULTA DE SALDOS
                            -- OCURRIO UN ERROR EN LA CONSULTA DE SALDOS PARA INSERTAR EL REGISTRO DE SALDO DESPUES DE LA CANCELACION DE LA CUENTA                  
                            -- SE BLOQUE LA CUENTA DE CREDITO
                            CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                            RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                            IF codigoRetornoDesbloqueo = '000000' THEN -- 11 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                              CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                              RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                              LET codigoRetorno = '000001';
                              LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                              LET numeroCredito = resultado_num_cta_cliente;
                              LET numeroTarjeta = resultado_num_cta_beneficiario;

                              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta con desbloqueo. La liquidación de recursos se hará en Central. Cod: ' || codigoRetorno ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                              RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            ELSE  -- 11 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                              CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                              RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                              LET codigoRetorno = codigoRetornoDesbloqueo;
                              LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                              LET numeroCredito = resultado_num_cta_cliente;
                              LET numeroTarjeta = resultado_num_cta_beneficiario;

                              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetorno ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                              RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            END IF -- 11 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                          END IF -- 10 VALIDACION DE CONSULTA DE SALDOS

                        ELSE  -- 9 VALIDACION DE CANCELACION DE CREDITO
                          CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                          RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                          IF codigoRetornoDesbloqueo = '000000' THEN -- 12 VALIDACION DE BLOQUEO DE CREDITO

                            CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                            RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            LET codigoRetorno = '000002';
                            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito con desbloqueo. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          ELSE  -- 12 VALIDACION DE BLOQUEO DE CREDITO

                            CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                            RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            LET codigoRetorno = codigoRetornoDesbloqueo;
                            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          END IF -- 12 VALIDACION DE BLOQUEO DE CREDITO

                        END IF -- 9 VALIDACION DE CANCELACION DE CREDITO

                      ELSE -- 6 VALIDACION PARA CONDONACION EXITOSA 
                        -- NO SE REALIZO LA CONDONACION

                        CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                        RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        LET codigoRetorno = cargoAbonoCodRetorno;
                        LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                        LET numeroCredito = resultado_num_cta_cliente;
                        LET numeroTarjeta = resultado_num_cta_beneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se pudo condonar el crédito. Cod: ' || codigoRetorno ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                      END IF -- 6 VALIDACION PARA CONDONACION EXITOSA

                    END IF -- 5 VALIDAR QUE EL SALDO ES MENOR A CERO PARA EL TRASPASO 7727

                    IF sdo_act_total_cap > 0 THEN -- 7 VALIDAR QUE EL SALDO ES MENOR A CERO PARA LA CONDONACION
                      -- SE REALIZA LA CONDONACION 
                      -- ACTUALIZACION 11/ABRIL/2018 SE SOLICITA TOMAR EL CAMPO total_liquidacion PARA CASOS DE CONDONACION
                      -- CALL bdicred:"informix".principalrefer(p_Empresa,p_numero_credito,1,NULL,p_Promotor,TRIM(p_Sucursal),p_FolioSUC,'7796',0,total_liquidacion,'Condonaciï¿½n Fallecidos')
                      -- RETURNING codigoRetorno,p_remanente,p_interesMoraCobrado,p_InterersVencidoCobrado,p_CapitaVencidoCobrado,p_InterersVigenteCobrado,p_CaptalvigenteCobrado,p_ImpuestoCobrado,p_ComisionesCobradas,p_SeguroCobrado;                              

                      -- CALL bdicred:"informix".sp_cargo_abono_aclara(p_Empresa,p_numero_credito, resultado_numero_tarjeta, (sdo_act_total_cap * -1), p_Promotor, TRIM(p_Sucursal), '7727', 1, "Traspaso Saldo Fallecido")

                      CALL bdicred:"informix".sp_cargo_abono_aclara(p_Empresa,p_numero_credito,resultado_numero_tarjeta,total_liquidacion,p_Promotor,TRIM(p_Sucursal),'7796',0,p_FolioSUC)
                      RETURNING cargoAbonoCodRetorno,cargoAbonoMenRetorno;
                  

                      IF TRIM(cargoAbonoCodRetorno) = '000' THEN -- 8 VALIDACION PARA CONDONACION EXITOSA
                        -- SE PROSIGUE A CANCELAR LA CUENTA
                        UPDATE fal_control_tramite SET monto_cargo = sdo_act_total_cap, monto_original = sdo_act_total_cap,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        CALL bdicred:"informix".sp_cancelarcredito (p_Empresa, p_numero_credito, '2', p_Promotor, p_Supervisor, '2', p_Sucursal )
                        RETURNING cancelarCodigoRet, cancelarMensajeRet;

                        -- PRUEBA DE FLUJO
                        --LET cancelarCodigoRet = '00002';
                        IF TRIM(cancelarCodigoRet) = '00000' THEN -- 13 VALIDACION DE CANCELACION DE CREDITO
                          -- SE CANCELO DE MANERA CORRECTA
                          IF pky_resolucion = 0 THEN
                            UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 6, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap,descripcion_detalle='CANCELADA'
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                          ELSE
                            UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 7, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap,descripcion_detalle='CANCELADA'
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                          END IF


                          -- SE CONSULTA EL SALDO UNA VEZ CANCELADO EL CREDITO
                          CALL bdicred:"informix".sp_consulta_saldos_general('001', p_numero_credito)
                          RETURNING 
                            codigoRetorno,mensajeRetorno,numero_credito,codigo_tipcred,fecha_origen,fecha_prox_pago,pago_minimo,fecha_ult_pago,plazo,pagos_realizados,linea_otorgada,tasa_interes,tasa_moratorios,monto_sbc,cap_vig,cap_trans,cap_vdo_exig,
                            cap_vdo_no_exig,sdo_act_total_cap,int_vig,int_vdo,int_moratorios,int_mes,sdo_act_total_int,iva_int_vig,iva_int_vdo,iva_int_moratorios,iva_int_mes,sdo_act_total_iva,com_pend,iva_com,sdo_retenido,total_liquidacion,int_devengado,
                            iva_int_devengado,linea_disponible,pagos_vdos,desc_status_cred,id_bloqueo_cred,bloqueo_cta,id_causa_bloqueo_cred, causa_bloqueo_cta,id_sit_esp_cte,id_causa_esp_cte,sit_esp_cte,id_sit_esp_cred,id_causa_esp_cred,sit_esp_cred;

                          IF TRIM(codigoRetorno) = '000000' THEN -- 14 VALIDACION DE CONSULTA DE SALDOS
                            -- SE INSERTA LA CONSULTA DEL SALDO DEL CREDITO CANCELADO


                          IF pky_resolucion = 0 THEN

                            INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                            capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                            interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                            fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion, tipo_movimiento_credito) 
                            VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION AUTOMATICO', resultado_numero_cliente, sdo_act_total_cap, 
                            cap_vig, cap_vdo_exig, cap_trans, cap_vdo_no_exig, sdo_act_total_cap, int_vig, iva_int_vig, int_vdo, iva_int_vdo, int_moratorios, monto_sbc, iva_int_moratorios, sysdate, 
                            p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO AUTOMATICO', resultado_tipo_producto, 'CANCELACION FALLECIDO AUTOMATICO',total_liquidacion,3);

                          ELSE

                             INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                             capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                             interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                             fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                             VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION CORPORATIVO', resultado_numero_cliente, sdo_act_total_cap, 
                             cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                             p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO CORPORATIVO', resultado_tipo_producto, 'CANCELACION FALLECIDO CORPORATIVO',total_liquidacion,3);

                          END IF


                            LET codigoRetorno = '000000';
                            LET mensajeRetorno = 'Crédito cancelado correctamente.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta se ha cancelado correctamente. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          ELSE -- 14 VALIDACION DE CONSULTA DE SALDOS
                            -- OCURRIO UN ERROR EN LA CONSULTA DE SALDOS PARA INSERTAR EL REGISTRO DE SALDO DESPUES DE LA CANCELACION DE LA CUENTA                  
                            -- SE BLOQUE LA CUENTA DE CREDITO
                            CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                            RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                            IF codigoRetornoDesbloqueo = '000000' THEN -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                              CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                              RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                              LET codigoRetorno = '000005';
                              LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                              LET numeroCredito = resultado_num_cta_cliente;
                              LET numeroTarjeta = resultado_num_cta_beneficiario;

                              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetorno ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                              RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            ELSE  -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                              CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                              RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                              LET codigoRetorno = codigoRetornoDesbloqueo;
                              LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                              LET numeroCredito = resultado_num_cta_cliente;
                              LET numeroTarjeta = resultado_num_cta_beneficiario;

                              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetorno ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                              RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            END IF -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                          END IF -- 14 VALIDACION DE CONSULTA DE SALDOS

                        ELSE  -- 13 VALIDACION DE CANCELACION DE CREDITO
                          CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                          RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                          IF codigoRetornoDesbloqueo = '000000' THEN -- 16 VALIDACION DE BLOQUEO DE CREDITO

                            CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                            RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            LET codigoRetorno = '000005';
                            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito con desbloqueo. Cod: ' || codigoRetornoDesbloqueo || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          ELSE  -- 16 VALIDACION DE BLOQUEO DE CREDITO

                            CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                            RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                            LET codigoRetorno = codigoRetornoDesbloqueo;
                            LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                            LET numeroCredito = resultado_num_cta_cliente;
                            LET numeroTarjeta = resultado_num_cta_beneficiario;

                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito. Cod: ' || codigoRetornoDesbloqueo || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                            RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          END IF -- 16 VALIDACION DE BLOQUEO DE CREDITO

                        END IF -- 13 VALIDACION DE CANCELACION DE CREDITO
          --------------------

                      ELSE -- 8 VALIDACION PARA CONDONACION EXITOSA

                        CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                        RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        -- NO SE REALIZO LA CONDONACION
                        LET codigoRetorno = "000009";
                        LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                        LET numeroCredito = resultado_num_cta_cliente;
                        LET numeroTarjeta = resultado_num_cta_beneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se pudo condonar el crédito. Cod: ' || codigoRetorno ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                      END IF -- 8 VALIDACION PARA CONDONACION EXITOSA

                    END IF -- 7 VALIDAR QUE EL SALDO ES MENOR A CERO PARA EL TRASPASO 

                  ELSE  -- 4 VALIDACION DE CARGO NULL
          ----------------------------          
                    CALL bdicred:"informix".sp_cancelarcredito (p_Empresa, p_numero_credito, '2', p_Promotor, p_Supervisor, '2', p_Sucursal )
                    RETURNING cancelarCodigoRet, cancelarMensajeRet;

                    -- PRUEBA DE FLUJO
                    --LET cancelarCodigoRet = '00002';
                    IF TRIM(cancelarCodigoRet) = '00000' THEN -- 13 VALIDACION DE CANCELACION DE CREDITO
                      -- SE CANCELO DE MANERA CORRECTA
                      IF pky_resolucion = 0 THEN
                        UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 6, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null,descripcion_detalle='CANCELADA'
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                      ELSE
                        UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 7, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null,descripcion_detalle='CANCELADA'
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                      END IF
                      -- SE CONSULTA EL SALDO UNA VEZ CANCELADO EL CREDITO
                      CALL bdicred:"informix".sp_consulta_saldos_general('001', p_numero_credito)
                      RETURNING 
                        codigoRetorno,mensajeRetorno,numero_credito,codigo_tipcred,fecha_origen,fecha_prox_pago,pago_minimo,fecha_ult_pago,plazo,pagos_realizados,linea_otorgada,tasa_interes,tasa_moratorios,monto_sbc,cap_vig,cap_trans,cap_vdo_exig,
                        cap_vdo_no_exig,sdo_act_total_cap,int_vig,int_vdo,int_moratorios,int_mes,sdo_act_total_int,iva_int_vig,iva_int_vdo,iva_int_moratorios,iva_int_mes,sdo_act_total_iva,com_pend,iva_com,sdo_retenido,total_liquidacion,int_devengado,
                        iva_int_devengado,linea_disponible,pagos_vdos,desc_status_cred,id_bloqueo_cred,bloqueo_cta,id_causa_bloqueo_cred, causa_bloqueo_cta,id_sit_esp_cte,id_causa_esp_cte,sit_esp_cte,id_sit_esp_cred,id_causa_esp_cred,sit_esp_cred;

                      IF TRIM(codigoRetorno) = '000000' THEN -- 14 VALIDACION DE CONSULTA DE SALDOS
                        -- SE INSERTA LA CONSULTA DEL SALDO DEL CREDITO CANCELADO


                          IF pky_resolucion = 0 THEN

                              INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                              capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                              interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                              fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion, tipo_movimiento_credito) 
                              VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION AUTOMATICO', resultado_numero_cliente, sdo_act_total_cap, 
                              cap_vig, cap_vdo_exig, cap_trans, cap_vdo_no_exig, sdo_act_total_cap, int_vig, iva_int_vig, int_vdo, iva_int_vdo, int_moratorios, monto_sbc, iva_int_moratorios, sysdate, 
                              p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO AUTOMATICO', resultado_tipo_producto, 'CANCELACION FALLECIDO AUTOMATICO',total_liquidacion,3);

                          ELSE

                             INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                             capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                             interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                             fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento,total_liquidacion,tipo_movimiento_credito) 
                             VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION CORPORATIVO', resultado_numero_cliente, sdo_act_total_cap, 
                             cap_vig,cap_vdo_exig,cap_trans,cap_vdo_no_exig,sdo_act_total_cap,int_vig,iva_int_vig,int_vdo,iva_int_vdo,int_moratorios,monto_sbc,iva_int_moratorios,sysdate, 
                             p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO CORPORATIVO', resultado_tipo_producto, 'CANCELACION FALLECIDO CORPORATIVO',total_liquidacion,3);

                          END IF



                        LET codigoRetorno = '000000';
                        LET mensajeRetorno = 'Crédito cancelado con éxito.';
                        LET numeroCredito = resultado_num_cta_cliente;
                        LET numeroTarjeta = resultado_num_cta_beneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta se ha cancelado correctamente. Cod: ' || cancelarCodigoRet || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                      ELSE -- 14 VALIDACION DE CONSULTA DE SALDOS
                        -- OCURRIO UN ERROR EN LA CONSULTA DE SALDOS PARA INSERTAR EL REGISTRO DE SALDO DESPUES DE LA CANCELACION DE LA CUENTA                  
                        -- SE BLOQUE LA CUENTA DE CREDITO
                        CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                        RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                        IF codigoRetornoDesbloqueo = '000000' THEN -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                          CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                          RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          LET codigoRetorno = '000001';
                          LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                          LET numeroCredito = resultado_num_cta_cliente;
                          LET numeroTarjeta = resultado_num_cta_beneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetornoDesbloqueo ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                          RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        ELSE  -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                          CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                          RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                          LET codigoRetorno = codigoRetornoDesbloqueo;
                          LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                          LET numeroCredito = resultado_num_cta_cliente;
                          LET numeroTarjeta = resultado_num_cta_beneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetornoDesbloqueo ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                          RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        END IF -- 15 VALIDACION PARA BLOQUEAR LA CUENTA DE CREDITO

                      END IF -- 14 VALIDACION DE CONSULTA DE SALDOS

                    ELSE  -- 13 VALIDACION DE CANCELACION DE CREDITO
                      CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                      RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                      IF codigoRetornoDesbloqueo = '000000' THEN -- 16 VALIDACION DE BLOQUEO DE CREDITO

                        CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                        RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        LET codigoRetorno = '000002';
                        LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
                        LET numeroCredito = resultado_num_cta_cliente;
                        LET numeroTarjeta = resultado_num_cta_beneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito con desbloqueo. Cod: ' || codigoRetornoDesbloqueo || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                      ELSE  -- 16 VALIDACION DE BLOQUEO DE CREDITO

                        CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta, codigoRetorno)
                        RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                        LET codigoRetorno = codigoRetornoDesbloqueo;
                        LET mensajeRetorno = 'Su folio se ha enviado a area interna.';
                        LET numeroCredito = resultado_num_cta_cliente;
                        LET numeroTarjeta = resultado_num_cta_beneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: No se realizó la cancelación del crédito con desbloqueo. Cod: ' || codigoRetornoDesbloqueo || ' Respuesta: ' || cancelarMensajeRet,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                      END IF -- 16 VALIDACION DE BLOQUEO DE CREDITO

                    END IF -- 13 VALIDACION DE CANCELACION DE CREDITO
          ----------------------------

                  END IF -- 4 VALIDACION DE CARGO NULL

                ELSE -- 3 SE REALIZA LA CANCELACION DE MANERA AUTOMATICA
                  -- SE MANDA A CENTRAL
                  CALL bdicred:"informix".sp_bloqueocuenta(p_Empresa, p_numero_credito, 3, '04', p_Supervisor, 1)
                        RETURNING codigoRetornoDesbloqueo,mensajeRetornoDesbloqueo;

                  CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta,codigoRetorno)
                  RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;
                  LET codigoRetorno = '000006';
                  LET numeroTarjeta = resultado_num_cta_beneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: Se asignó analista por regla de negocio.',sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                  RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                END IF -- 3 SE REALIZA LA CANCELACION DE MANERA AUTOMATICA

              ELSE -- 2 VALIDAR SI LA CONSULTA DE SALDOS FUE CORRECTA


                CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta,codigoRetorno)
                RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

                LET codigoRetorno = '000007';
                LET numeroTarjeta = resultado_num_cta_beneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error Cancelación: Ocurrió un error en la consulta de saldos de la cuenta. La liquidación de recursos se hará en Central. Cod: ' || codigoRetornoDesbloqueo ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

                RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

              END IF -- 2 VALIDAR SI LA CONSULTA DE SALDOS FUE CORRECTA

            ELSE  -- 1 VALIDACION DEL DESBLOQUEO DE CUENTA


              CALL sp_fal_asignar_analista_credito(resultado_fky_usuario_analista,p_idSolicitud, p_numero_credito, resultado_numero_tarjeta,resultado_pky_control_tramite_cuenta,codigoRetorno)
              RETURNING codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

              LET codigoRetorno = '000008';
              LET numeroTarjeta = resultado_num_cta_beneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error Cancelación: No se puedo desbloquear el crédito. Cod: ' || codigoRetornoDesbloqueo ,sysdate,resultado_foliocsuac,'CANCELACION CREDITO',resultado_pky_usuario,p_Promotor);

              RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

            END IF -- 1 VALIDACION DEL DESBLOQUEO DE CUENTA
         
         ELSE IF (cancelacion_manual = 1) THEN --VALIDACION PARA APLICACION DE CANCELACION MANUAL
                        
                        CALL bdicred:"informix".sp_cancelarcredito (p_Empresa, p_numero_credito, '2', p_Promotor, p_Supervisor, '2', p_Sucursal )
                        RETURNING cancelarCodigoRet, cancelarMensajeRet;

                        -- PRUEBA DE FLUJO
                        --LET cancelarCodigoRet = '00002';
                        IF TRIM(cancelarCodigoRet) = '00000' THEN -- 13 VALIDACION DE CANCELACION DE CREDITO
                          -- SE CANCELO DE MANERA CORRECTA
                          UPDATE fal_control_tramite SET exitoso = 1,fecha_cancelacion = sysdate, fky_estatus_corporativo = 7, fky_estatus_sucursal = 3,fky_fal_cat_resolucion = null, monto_cargo = sdo_act_total_cap,descripcion_detalle='CANCELADA'
                          WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;


                          -- SE CONSULTA EL SALDO UNA VEZ CANCELADO EL CREDITO
                          CALL bdicred:"informix".sp_consulta_saldos_general('001', p_numero_credito)
                          RETURNING 
                            codigoRetorno,mensajeRetorno,numero_credito,codigo_tipcred,fecha_origen,fecha_prox_pago,pago_minimo,fecha_ult_pago,plazo,pagos_realizados,linea_otorgada,tasa_interes,tasa_moratorios,monto_sbc,cap_vig,cap_trans,cap_vdo_exig,
                            cap_vdo_no_exig,sdo_act_total_cap,int_vig,int_vdo,int_moratorios,int_mes,sdo_act_total_int,iva_int_vig,iva_int_vdo,iva_int_moratorios,iva_int_mes,sdo_act_total_iva,com_pend,iva_com,sdo_retenido,total_liquidacion,int_devengado,
                            iva_int_devengado,linea_disponible,pagos_vdos,desc_status_cred,id_bloqueo_cred,bloqueo_cta,id_causa_bloqueo_cred, causa_bloqueo_cta,id_sit_esp_cte,id_causa_esp_cte,sit_esp_cte,id_sit_esp_cred,id_causa_esp_cred,sit_esp_cred;

                          IF TRIM(codigoRetorno) = '000000' THEN -- 14 VALIDACION DE CONSULTA DE SALDOS
                            -- SE INSERTA LA CONSULTA DEL SALDO DEL CREDITO CANCELADO
                            INSERT INTO fal_saldo_anterior (pky_saldo_anterior, num_cuenta_titular, folio_csuac, concepto, numero_cliente, saldo, capital_vigente, capital_vencido, 
                            capital_transitorio, capital_vencido_no_exigible, capital_total, interes_vigente, iva_interes_vigente, interes_vencido, iva_interes_vencido, 
                            interes_moratorio_base, interes_moratorio_copete, iva_interes_moratorio, fecha_aplicacion, fky_numero_empleado, fky_numero_usuario, 
                            fky_tipo_tramite, estatus_cuenta, motivo_estatus, fky_tipo_producto, descripcion_movimiento, total_liquidacion,tipo_movimiento_credito) 
                            VALUES(SALDO_ANTERIOR_SEQ.NEXTVAL, p_numero_credito, resultado_foliocsuac, 'SALDO CANCELACION AUTOMATICO', resultado_numero_cliente, sdo_act_total_cap, 
                            cap_vig, cap_vdo_exig, cap_trans, cap_vdo_no_exig, sdo_act_total_cap, int_vig, iva_int_vig, int_vdo, iva_int_vdo, int_moratorios, monto_sbc, iva_int_moratorios, sysdate, 
                            p_Promotor, p_Supervisor, 2, '', 'CANCELACION FALLECIDO AUTOMATICO', resultado_tipo_producto, 'CANCELACION FALLECIDO AUTOMATICO',total_liquidacion,3);
                            END IF;
                       END IF;    
          
                       RETURN codigoRetorno,mensajeRetorno,p_numero_credito,'';
         
         END IF;    END IF;
END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_vencimiento_pagare(p_tipo_tramite INTEGER)
	RETURNING CHAR(6) as codigoRetorno,
			CHAR(100) as mensajeRetorno;

	-- DEFINICION DE VARIABLES
	DEFINE codigoRetorno	CHAR(6);
	DEFINE mensajeRetorno	CHAR(100);

	DEFINE resultado_pky_control_tramite INTEGER;
	DEFINE resultado_fecha_vencimiento_pagare DATE;
    DEFINE resultado_cuenta_pagare CHAR(20);
    DEFINE resultado_aplicado CHAR(1);
    DEFINE resultado_inst_evento CHAR(2);
    DEFINE resultado_conteo_proceso INTEGER;
    DEFINE resultado_conteo INTEGER;
    DEFINE resultado_fky_solicitud INTEGER;
    DEFINE resultado_numero_cliente       CHAR(9);
    DEFINE resultado_foliocsuac           CHAR(12);
    DEFINE resultado_fky_usuario_analista INTEGER;
    DEFINE resultado_num_sucursal CHAR(10);
    DEFINE resultado_secuencia SMALLINT;
    DEFINE resultado_montoActualVencimiento MONEY(16);
    DEFINE resultado_num_cta_beneficiario         CHAR(20);
    DEFINE resultado_nombreBeneficiario CHAR(100);
    DEFINE resultado_representante_legal INTEGER;
    DEFINE resultado_num_empleado CHAR(9);
    DEFINE resultado_cta_cheques CHAR(20);
    DEFINE resultado_cargos_mes MONEY(16);


    DEFINE tipoAccion           CHAR(1);
    DEFINE cuentaBeneficiario   CHAR(20);
    DEFINE cuentaClienteFallecido CHAR(20);
    DEFINE codigoRetornoCancelacion CHAR(6);
    DEFINE mensajeRetornoCancelacion CHAR(250);
    DEFINE nombreBeneficiario CHAR(100);

    DEFINE resultado_porcentaje INTEGER;

	DEFINE iSqlErr	INTEGER;
    LET resultado_fky_usuario_analista = 0;
    LET resultado_fecha_vencimiento_pagare = DATE(0);

	-- INICIALIZACION DE VARIABLES
	LET codigoRetorno = '000';
	LET mensajeRetorno = 'Ejecucion completa de validacion de fecha de vencimiento de pagare.';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		FOREACH

			SELECT pky_control_tramite, fecha_vencimiento_pagare, cuenta_cliente_fallecido,cuenta_beneficiario, fky_solicitud, monto_porcentaje
			INTO resultado_pky_control_tramite, resultado_fecha_vencimiento_pagare, resultado_cuenta_pagare,resultado_num_cta_beneficiario, resultado_fky_solicitud, resultado_porcentaje
			FROM fal_control_tramite
			WHERE fecha_vencimiento_pagare = today
			AND fky_tipo_tramite = 3
			AND cambio_instruccion_pagare = 1
			AND tramite_fecha_vencimiento = 1
			AND liquida_pagare is null

            -- VALIDACION DE TRASPASO DE FONDOS A LA CUENTA EJE
            SELECT first 1 inst_vento, aplicado, cta_cheques
            INTO resultado_inst_evento,resultado_aplicado, resultado_cta_cheques
            FROM bdinvers:"informix".sv_maeinstrucc
            WHERE cuenta = resultado_cuenta_pagare;

            IF resultado_aplicado = 'S' AND resultado_inst_evento = '02' THEN
                select count(procesado)
                into resultado_conteo_proceso
                from bdicheq:"informix".sc_movinver
                where referencia = resultado_cuenta_pagare;

                select count(procesado)
                into resultado_conteo
                from bdicheq:"informix".sc_movinver
                where referencia = resultado_cuenta_pagare
                AND procesado = 'S';

                IF resultado_conteo_proceso = resultado_conteo THEN                                         -- SE ACTUALIZA EL ESTATUS PARA PODER REALIZAR LA LIQUIDACION
                     -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
                    SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal, num_empleado
                    INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista,resultado_num_sucursal, resultado_num_empleado
                    FROM fal_solicitud
                    WHERE pky_solicitud = resultado_fky_solicitud;

                    SELECT nombre_cliente, representante_legal
                    INTO resultado_nombreBeneficiario, resultado_representante_legal
                    FROM  fal_beneficiario
                    WHERE  pky_cuenta_beneficiario = resultado_num_cta_beneficiario
                    AND pky_cuenta_cliente_fallecido = resultado_cuenta_pagare;
                    -- SE CONSULTA EL NUEVO MONTO DESPUES DEL CIERRE

                    SELECT first 1 max(secuencia), (mav.capital+mav.intereses-mav.isr) as saldo_vencimiento
                    INTO resultado_secuencia,resultado_montoActualVencimiento
                    FROM bdinvers:"informix".sv_maeinv mav
                    WHERE cuenta = resultado_cuenta_pagare
                    AND status_cta = 1
                    group by saldo_vencimiento;

                    -- OBTENER LOS IMPUESTOS DE CARGOS DE MES
                    SELECT imp_cgos_mes
                    INTO resultado_cargos_mes
                    FROM bdicheq:"informix".sc_maechq
                    WHERE cuenta = resultado_cta_cheques;

                    LET resultado_montoActualVencimiento = resultado_montoActualVencimiento - resultado_cargos_mes;


                    -- DEFINIR EL MONTO POR DEFECTO CUANDO SOLO HAY UN BENEFICIARIO
                    IF resultado_porcentaje = 100 THEN
                        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2, fky_estatus_sucursal = 2,liquida_pagare = 1, tramite_fecha_vencimiento = 0, cambio_instruccion_pagare = 0,
                                descripcion_detalle = 'MONTO_PAGARE', monto_original = resultado_montoActualVencimiento,monto_calculado = 0, monto_calculado = resultado_montoActualVencimiento
                        WHERE cuenta_cliente_fallecido = resultado_cuenta_pagare;
                    ELSE

                        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2, fky_estatus_sucursal = 2,liquida_pagare = 1, tramite_fecha_vencimiento = 0, cambio_instruccion_pagare = 0,
                            descripcion_detalle = 'MONTO_PAGARE', monto_original = resultado_montoActualVencimiento,monto_calculado = 0
                        WHERE cuenta_cliente_fallecido = resultado_cuenta_pagare;

                    END IF

                    -- ACTUALIZA EL VALOR PARA PRODER PREDICTAMINAR EN CORPORATIVO
                    UPDATE fal_saldo_anterior SET concepto = 'LIQUIDACION', saldo = resultado_montoActualVencimiento
                    WHERE num_cuenta_titular = resultado_cuenta_pagare;

                    -- ASIGNAR ANALISTA
                    CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,resultado_fky_solicitud, resultado_cuenta_pagare, resultado_num_cta_beneficiario, resultado_num_empleado,resultado_nombreBeneficiario,resultado_pky_control_tramite)
                    RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                END IF

            END IF

		END FOREACH;

		RETURN codigoRetorno,mensajeRetorno;
	END;

END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion',
'SP de fecha de vencimiento pagare',
'SP que realiza el cambio de estatus para poder realizar la liquidacion de pagare';

CREATE PROCEDURE "informix".sp_fal_liquidacion_cuenta_pagare(p_idSolicitud INTEGER, p_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario CHAR(8), p_procede INTEGER, pky_resolucion INTEGER)
  RETURNING CHAR(6) as codigoRetorno,
    CHAR(100) as mensajeRetorno,
    CHAR(20) as cuentaBeneficiario,
    CHAR(20) as cuentaClienteFallecido,
    CHAR(100) as nombreBeneficiario,
    CHAR(6) as codigoRetornoCancelacion,
    CHAR(250) as mensajeRetornoCancelacion;

  -- DEFINICION DE VARIABLES
  DEFINE codigoRetorno CHAR(6);
  DEFINE mensajeRetorno CHAR(100);
  DEFINE cuentaBeneficiario CHAR(20);
  DEFINE cuentaClienteFallecido CHAR(20);
  DEFINE nombreBeneficiario CHAR(100);
  DEFINE codigoRetornoCancelacion CHAR(6);
  DEFINE mensajeRetornoCancelacion CHAR(250);

  DEFINE resultado_nombreBeneficiario CHAR(100);
  -- OBTENCION DE INFORMACION DE SOLICITUD
  DEFINE resultado_numero_cliente CHAR(9);
  DEFINE resultado_foliocsuac           CHAR(12);
  DEFINE resultado_fky_usuario_analista INTEGER;
  DEFINE resultado_num_sucursal CHAR(10);

  -- 2) QUERY DE CONTROL
  DEFINE resultado_pky_control_tramite_cuenta   INTEGER;
  DEFINE resultado_num_cta_cliente              CHAR(20); 
  DEFINE resultado_num_cta_beneficiario         CHAR(20);
  DEFINE resultado_porcentaje_bene              DECIMAL(9,6);
  DEFINE resultado_tramite                      INTEGER;
  DEFINE resultado_exitoso                      INTEGER;
  DEFINE resultado_tipo_cancelacion             INTEGER;
  --DEFINE resultado_fecha_vencimiento            DATE;
  DEFINE resultado_monto_original               MONEY(14,2);
  DEFINE resultado_monto_pagare                 MONEY(14,2);
  DEFINE resultado_liquidacion_pagare       INTEGER;

  -- 3) DOCUMENTOS DIGITALIZADOS
  DEFINE v_numero_documentos_necesarios_beneficiario     INTEGER;
  DEFINE v_numero_documentos_digitalizados_beneficiario  INTEGER;  

  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  DEFINE monto_pago_bene            MONEY(14,2);

  -- 9) DEFINICION DE REGLA DE NEGOCIO
  DEFINE resultado_pky_rango_importe  INTEGER;
  DEFINE resultado_rango_inferior      MONEY;
  DEFINE resultado_accion_cumple INTEGER;
  DEFINE resultado_accion_no_cumple INTEGER;
  DEFINE resultado_accion_procede INTEGER;
  DEFINE resultado_accion_no_procede INTEGER;

  -- CONSTANTES
  DEFINE p_Empresa    CHAR(3);
  DEFINE p_Ejecutivo  CHAR(20);
  DEFINE p_tran_aplica_cargo CHAR(4);    
  DEFINE p_tran_aplica_abono CHAR(4);    

  DEFINE resultado_cta_cheques  CHAR(20);
  DEFINE resultado_motivo CHAR(2);

  -- DESBLOQUEO DE CUENTA
  DEFINE codret_blqcta CHAR(6);
  DEFINE menret_blqcta CHAR(250);

  DEFINE codret_blqcta_importe CHAR(6);
  DEFINE menret_blqcta_importe CHAR(250);


  DEFINE resultado_estatus_cta_chq_pagare  CHAR(1);
  DEFINE resultado_motivo_cta_chq_pagare CHAR(2);
  DEFINE resultado_saldo_cta_chq_pagare MONEY (14,2);

  DEFINE resultado_estatus_cuenta_beneficiario CHAR(1);
  DEFINE resultado_estatus_cuenta_cliente_fallecido CHAR(2);

  DEFINE p_fecha_folio  CHAR(10);
  DEFINE p_FolioSUC     CHAR(16);

  DEFINE num_tarjeta_cliente      CHAR(20);
  DEFINE num_tarjeta_beneficiario CHAR(20);

  DEFINE resultado_saldo_congelado MONEY;
  -- cargo_ref
  DEFINE codret_cargo_ref      CHAR(6);
  DEFINE tranret_cargo_ref     CHAR(4);
  DEFINE fechoy_cargo_ref      DATE;
  DEFINE sdodisp_cargo_ref     MONEY(14,2);
  DEFINE montoret_cargo_ref    MONEY(14,2);  

  DEFINE motivo_cancelacion_debito CHAR(2);

  DEFINE vcodret_abono  CHAR(6);

  DEFINE cod_resp_cancelacion_debito CHAR(6);
  DEFINE msj_resp_cancelacion_debito CHAR(250);

  DEFINE resultado_descripcion_estatus_cuenta CHAR(50);
  DEFINE monto_a_buscar_regla_negocio MONEY(14,2);
  DEFINE resultado_nombre_accion_procede CHAR(20);

  DEFINE v_numero_documentos_digitalizados_fallecido INTEGER;
  DEFINE v_numero_documentos_necesarios_fallecido   INTEGER;
  DEFINE resultado_cargo_bandera INTEGER;
  DEFINE resultado_cuenta_abonar CHAR(20);
  DEFINE resultado_representante_legal INTEGER;
  DEFINE resultado_descripcion_detalle          CHAR(100);
  DEFINE resultado_aplicado INTEGER;
  DEFINE resultado_pky_usuario INTEGER;

  DEFINE resultado_cuenta_eje CHAR(20);

  DEFINE resultado_tipo_lugar_deceso INTEGER;

  LET resultado_cuenta_eje = '';
  LET resultado_representante_legal = 0;
  
  LET codret_blqcta = '';
  LET menret_blqcta = '';

  LET resultado_estatus_cta_chq_pagare = '';
  LET resultado_motivo_cta_chq_pagare = '';
  LET resultado_saldo_cta_chq_pagare = 0;

  LET resultado_estatus_cuenta_beneficiario = '';

  LET p_fecha_folio = '';
  LET p_FolioSUC = '';
  LET num_tarjeta_cliente = '';
  LET num_tarjeta_beneficiario = '';

  -- CONSTANTES
  LET p_Empresa   = '001';
  LET p_Ejecutivo = '001';
  LET p_tran_aplica_cargo = '0409';
  LET p_tran_aplica_abono = '0408';

  LET motivo_cancelacion_debito = '04';

  LET codigoRetorno = '';
  LET mensajeRetorno = '';
  LET cuentaBeneficiario = '';
  LET cuentaClienteFallecido = '';
  LET nombreBeneficiario = '';

  LET resultado_nombreBeneficiario = '';

  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  LET resultado_numero_cliente = '';
  LET resultado_foliocsuac = '';

  -- 2) QUERY DE CONTROL
  LET resultado_pky_control_tramite_cuenta  = 0;
  LET resultado_num_cta_cliente             = '';
  LET resultado_num_cta_beneficiario        = '';
  LET resultado_porcentaje_bene             = 0;
  LET resultado_tramite                     = 0;
  LET resultado_exitoso                     = 0;
  LET resultado_tipo_cancelacion            = 0;
  --LET resultado_fecha_vencimiento           = DATE(1);
  LET resultado_monto_original              = 0;
  LET resultado_monto_pagare                = 0;
  LET resultado_liquidacion_pagare      = 0;

  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  LET v_numero_documentos_necesarios_beneficiario    = 0;
  LET v_numero_documentos_digitalizados_beneficiario = 0;

  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  LET monto_pago_bene = 0;

  -- 9) REGISTRO DE VARIABLES PARA REGLA DE NEGOCIO
  LET resultado_pky_rango_importe = 0;
  LET resultado_rango_inferior = 0;
  LET resultado_accion_cumple = 0;
  LET resultado_accion_no_cumple = 0;
  LET resultado_accion_procede = 0;
  LET resultado_accion_no_procede = 0;

  LET resultado_cta_cheques = '';

  -- CONDICIONES PARA REALIZAR LA LIQUIDACION DE LAS CUENTAS DE PAGARE
  -- 1 SE DEBE CONSIDERAR LA FECHA DE VENCIMIENTO (CRON)
  -- 2 SE REALIZA LA CONSULTA DE LA CANTIDAD A ABONAR AL BENEFICIARIO
  -- 3 SE REALIZAN CARGOS BLOQUEADOS A LA CUENTA DEL CLIENTE FALLECIDO

  --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/liquidacionCuentaPagareCorporativo_"||p_idSolicitud||"_"||TRIM(p_cta_cliente)||TRIM(p_cta_beneficiario)||"_34.out"; 
  --TRACE ON;
  --SET ISOLATION TO DIRTY READ;
  --SET LOCK MODE TO WAIT 3;

  BEGIN

  -- OBTENER EL PKY DEL USUARIO
  SELECT pky_usuario
  INTO resultado_pky_usuario
  FROM acl_usuario WHERE num_empleado = p_usuario;

  IF(resultado_pky_usuario) IS NULL THEN
    LET resultado_pky_usuario = 0;
  END IF

  -- OBTENER INFORMACION DE LA CUENTA EJE
  SELECT first 1 cta_cheques
  INTO resultado_cuenta_eje
  FROM bdinvers:"informix".sv_maeinstrucc
  WHERE cuenta = p_cta_cliente;

  -- OBTENER NOMBRE DE BENEFICIARIO
  SELECT nombre_cliente
  INTO resultado_nombreBeneficiario
  FROM  fal_beneficiario
  WHERE  pky_cuenta_beneficiario = p_cta_beneficiario
  AND pky_cuenta_cliente_fallecido = p_cta_cliente;

  -- OBTENER INFORMACION DE LA SOLICITUD
  SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal
  INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista,resultado_num_sucursal
  FROM fal_solicitud
  WHERE pky_solicitud = p_idSolicitud;

  -- OBTENER INFORMACION DE LA TABLA DE CONTROL (fal_control_tramite)
  SELECT pky_control_tramite, 
    cuenta_cliente_fallecido, 
    cuenta_beneficiario, 
    monto_porcentaje, 
    tramite, 
    exitoso, 
    fky_tipo_tramite,
    --fecha_vencimiento_pagare,
    monto_original,
    monto_calculado,
    liquida_pagare
  INTO resultado_pky_control_tramite_cuenta, 
    resultado_num_cta_cliente, 
    resultado_num_cta_beneficiario, 
    resultado_porcentaje_bene, 
    resultado_tramite, 
    resultado_exitoso, 
    resultado_tipo_cancelacion,
    --resultado_fecha_vencimiento,
    resultado_monto_original,
    resultado_monto_pagare,
    resultado_liquidacion_pagare
  FROM fal_control_tramite
  WHERE fky_solicitud = p_idSolicitud
  AND tramite = 1
  AND exitoso = 0
  AND fky_tipo_tramite = 3
  AND cuenta_cliente_fallecido = p_cta_cliente
  AND cuenta_beneficiario = p_cta_beneficiario
  AND liquida_pagare = 1;

  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL BENEFICIARIO
  SELECT count(*)
  INTO v_numero_documentos_digitalizados_beneficiario
  FROM fal_control_digitaliza_doc FCDD
  WHERE FCDD.cuenta_cliente_fallecido = resultado_num_cta_cliente AND FCDD.cuenta_beneficiario = resultado_num_cta_beneficiario
  AND FCDD.inconsistencia = 0;

  SELECT count(*) 
  INTO v_numero_documentos_necesarios_beneficiario
  FROM fal_cat_tipo_beneficiario CTB
  INNER JOIN fal_beneficiario_gpo_doc BGD ON CTB.pky_tipo_beneficiario = BGD.fky_tipo_beneficiario
  INNER JOIN fal_cat_grupo_documento CGD ON BGD.fky_grupo_documento = CGD.pky_grupo_documento
  INNER JOIN fal_grupo_documento GD ON CGD.pky_grupo_documento = GD.fky_grupo_documento
  INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
  INNER JOIN fal_beneficiario B ON CTB.pky_tipo_beneficiario = B.fky_tipo_beneficiario
  AND B.pky_cuenta_cliente_fallecido = resultado_num_cta_cliente AND B.pky_cuenta_beneficiario = resultado_num_cta_beneficiario;

  -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL BENEFICIARIO, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
  -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL CF, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
  SELECT status_cta 
  INTO resultado_estatus_cuenta_beneficiario
  FROM bdicheq:"informix".sc_maechq 
  WHERE cuenta = p_cta_beneficiario;

  SELECT status_cta,motivo,sdo_cong
  INTO resultado_estatus_cuenta_cliente_fallecido,resultado_motivo,resultado_saldo_congelado
  FROM bdicheq:"informix".sc_maechq 
  WHERE cuenta = resultado_cuenta_eje;

  -- OBTENER EL ESTATUS DE LA CUENTA
  SELECT descripcion
  INTO resultado_descripcion_estatus_cuenta
  FROM fal_cat_estatus_cuenta
  WHERE pky_estatus_cuenta = resultado_estatus_cuenta_cliente_fallecido;

    -- VALIDACION DE PARAMETROS DE ENTRADA
  IF p_cta_cliente IS NULL THEN
    LET p_cta_cliente = '';
  END IF
  IF p_cta_beneficiario IS NULL THEN
    LET p_cta_beneficiario = '';
  END IF
  IF p_usuario IS NULL THEN
    LET p_usuario = '';
  END IF



  IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usuario) = '' THEN

    LET codigoRetorno = '000001';
    LET mensajeRetorno = 'Su folio se ha enviado a área interna.';
    LET cuentaBeneficiario = p_cta_beneficiario;
    LET cuentaClienteFallecido = p_cta_cliente;
    LET nombreBeneficiario = '';
    LET codigoRetornoCancelacion = '0';
    LET mensajeRetornoCancelacion = '';

    INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
    VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: Parámetros incorrectos.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);      

    RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;
  END IF

    
  IF TRIM(resultado_estatus_cuenta_beneficiario) not in (1,4,5) THEN
    LET codigoRetorno       = '000007';
    LET mensajeRetorno      = 'El estatus de la cuenta del beneficiario es ' || resultado_descripcion_estatus_cuenta;
    LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
    LET cuentaClienteFallecido = resultado_num_cta_cliente;
    LET codigoRetornoCancelacion = '0';
    LET mensajeRetornoCancelacion = '';
    LET nombreBeneficiario = resultado_nombreBeneficiario;
     
    RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
  END IF

  -- 4) SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL BENEFICIARIO CUENTA CON TODA LA DOCUMENTACION
  IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN
    -- ACCIONES EN CASO DE CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
    -- PASOS A SEGUIR:
    -- A) SE REALIZA EL CARGO A LA CUENTA DEL PAGARE (VALIDAR CON CLIENTE)
    -- B) SE REALIZA EL ABONO A LA CUENTA DE CHEQUES RELACIONADO AL PAGARE
    -- C) DE BLOQUE/DESBLOQUEA LA CUENTA EJE
    -- D) 
    -- 5) CONSULTA DEL SALDO DE LA CUENTA

    -- 8) OBTENER EL MONTO PARA EL BENEFICIARIO
    LET monto_pago_bene = resultado_monto_pagare;    
    LET monto_a_buscar_regla_negocio = monto_pago_bene;
    -- SI POR ALGUNA RAZON EL MONTO ES CERO
    IF monto_pago_bene < 1 AND monto_pago_bene > 0 THEN
      LET monto_a_buscar_regla_negocio = 1;
    END IF

    -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
    /*
    SELECT frimp.pky_rango_importe,frimp.rango_inferior
    INTO resultado_pky_rango_importe,resultado_rango_inferior
    FROM fal_solicitud fsol
    INNER JOIN fal_cat_evento ceve ON ceve.pky_evento = fsol.fky_evento AND ceve.fky_origen_evento = fsol.fky_origen_evento      
    INNER JOIN fal_regla_negocio frn ON frn.fky_evento = ceve.pky_evento AND frn.fky_origen_evento = ceve.fky_origen_evento
    INNER JOIN fal_rango_importe frimp ON frimp.fky_regla_negocio = frn.pky_regla_negocio
    WHERE frimp.rango_inferior <= monto_a_buscar_regla_negocio AND frimp.rango_mayor >= monto_a_buscar_regla_negocio
    AND fsol.pky_solicitud = p_idSolicitud      
    AND frn.activo = 1;
    */ 
    -- SE OBTIENEN LAS ACCIONES A REALIZAR POR EL RANGO IMPORTE
    /*
    SELECT frimpacc.cumple,frimpacc.no_cumple,frimpacc.procede,frimpacc.no_procede
    INTO resultado_accion_cumple, resultado_accion_no_cumple, resultado_accion_procede, resultado_accion_no_procede
    FROM fal_rango_importe_accion frimpacc
    WHERE frimpacc.fky_rango_importe = resultado_pky_rango_importe; 
    */

    LET monto_a_buscar_regla_negocio = monto_pago_bene;

    -- FLUJO PARA PROCEDENTE
    IF p_procede = 1 THEN -- VALIDACION DE PROCEDE
      -- SE OBTIENE LA ACCION PARA LA ACCION DE PROCEDE
      SELECT nombre 
      INTO resultado_nombre_accion_procede
      FROM fal_cat_accion
      WHERE pky_accion = resultado_accion_procede;

      --IF TRIM(resultado_nombre_accion_procede) = 'APLICACION_MANUAL' OR TRIM(resultado_nombre_accion_procede) = 'APLICACION_AUTOMATICA' THEN -- VALIDACION PARA PROCESO MANUAL DE LA REGLA

        -- SE REALIZA LA LIQUIDACION AL BENEFICIARIO
        -- SE REALIZA LA VALIDACION DE TENER EL BLOQUEO DE CUENTA POR FALLECIMIENTO
        SELECT count(*)
        INTO v_numero_documentos_digitalizados_fallecido
        FROM fal_control_digitaliza_doc FCDD
        WHERE FCDD.cuenta_cliente_fallecido = resultado_numero_cliente AND FCDD.cuenta_beneficiario = resultado_numero_cliente
        AND FCDD.inconsistencia = 0;

        -- SE VALIDA EL TIPO DE LUGAR DE FALLECIMIENTO.
        -- SI ES EN EL EXTRANJERO SE AÑADE UN DOCUMENTO.
        SELECT fky_lugar_deceso
        INTO resultado_tipo_lugar_deceso
        FROM fal_aviso 
        WHERE fky_solicitud = p_idSolicitud;

        IF  resultado_tipo_lugar_deceso = 2 THEN
          -- SE REALIZA LA CONSULTA POR EL DOCUMENTO ADICIONAL DE LA APOSTILLA
          SELECT count(*)
          INTO v_numero_documentos_necesarios_fallecido
          FROM fal_grupo_documento GD
          INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
          WHERE GD.fky_grupo_documento in (1,2,3);
        ELSE
        
          SELECT count(*)
          INTO v_numero_documentos_necesarios_fallecido
          FROM fal_grupo_documento GD
          INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
          WHERE GD.fky_grupo_documento in (1,2);

        END IF

        IF v_numero_documentos_digitalizados_fallecido < v_numero_documentos_necesarios_fallecido AND v_numero_documentos_digitalizados_fallecido != 0 THEN -- VALIDACION DE DOCUMENTACION DE CLIENTE FALLECIDO

          LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
          LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';      
          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
          LET cuentaClienteFallecido = resultado_num_cta_cliente;
          LET codigoRetornoCancelacion = '0';
          LET mensajeRetornoCancelacion = '';
          LET nombreBeneficiario = resultado_nombreBeneficiario;

          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: La documentación del cliente fallecido no está completa.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
          RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

        END IF -- VALIDACION DE DOCUMENTACION DE CLIENTE FALLECIDO

        IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN -- VALIDACION DE DOCUMENTACION BENEFICIARIO COMPLETA

          LET monto_pago_bene = resultado_monto_pagare;

          IF monto_pago_bene = 0 THEN -- EL SALDO A LIQUIDAR ES 0
            UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = today, tramite_aplicado = 1
            WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

            UPDATE fal_control_tramite SET exitoso = 1, monto_cargo = monto_pago_bene
            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta; 

            -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
            CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
            RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

            IF cod_resp_cancelacion_debito = '069' THEN -- CANCELACION EXITOSA DE LA CUENTA
                -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
              UPDATE fal_control_tramite SET fecha_cancelacion = today, fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3
              WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

              -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
              LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';      
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
              LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente, la cuenta del cliente fallecido se ha cancelado. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
              RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

            ELSE -- CANCELACION EXITOSA DE LA CUENTA
                -- NO SE REALIZA LA CANCELACION DE LA CUENTA

              UPDATE fal_control_tramite SET fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3
              WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

              LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';      
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
              LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
              RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

            END IF -- CANCELACION EXITOSA DE LA CUENTA

          END IF -- EL SALDO A LIQUIDAR ES 0
 
          IF resultado_estatus_cuenta_cliente_fallecido = 3 AND resultado_motivo = '00' AND resultado_saldo_congelado > 0 THEN -- EN CASO DE TENER MONTO BLOQUEADO

            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje), resultado_saldo_congelado, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )              
            RETURNING codret_blqcta,menret_blqcta;

            IF trim(codret_blqcta) != '000' THEN -- VALIDACION DE DESBLOQUEO POR MONTO SATISFACTORIO

              CALL sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
              RETURNING codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;      

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo Error liquidación: No se ha desbloqueado por monto.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

              RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

            END IF -- VALIDACION DE DESBLOQUEO POR MONTO SATISFACTORIO

          END IF -- EN CASO DE TENER MONTO BLOQUEADO


          IF resultado_estatus_cuenta_cliente_fallecido = 3 AND resultado_motivo = '04' THEN -- VALIDACION DE CUENTA BLOQUEADA POR FALLECIMIENTO

            --------------------------------------------------------------------------
            ------- SP POR DEFINIR ---------------------------------------------------
            -- [bdicheq:"informix".bloqueo_cta]
            -- EMPRESA,CUENTA,MONTO,COD BLOQUEO,OPC BLOQUEO,FECHA,USUARIO,CLAVE,AREA,COD AREA,TIPO BLOQUEO
            -- PRUEBA DE FLUJO
            --######################################################################################################################################
            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
            RETURNING codret_blqcta,menret_blqcta;
            --######################################################################################################################################              

            IF TRIM(codret_blqcta) != '000' THEN  -- VALIDACION DE DESBLOQUEO DE CUENTA 
              LET codigoRetorno       = codret_blqcta;
              LET mensajeRetorno      = 'No se pudo activar la cuenta del cliente fallecido.' || codret_blqcta;
              LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = '0';
              LET mensajeRetornoCancelacion = '';
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
              CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
              RETURNING codret_blqcta,menret_blqcta;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo activar la cuenta del cliente fallecido.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

              RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

            END IF -- VALIDACION DE DESBLOQUEO DE CUENTA 
          END IF -- VALIDACION DE CUENTA BLOQUEADA POR FALLECIMIENTO

          -- 10.2 SE GENERA EL FOLIO SUC
          SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
          INTO p_fecha_folio
          FROM systables WHERE tabid=1;

          LET p_FolioSUC = trim(p_fecha_folio) || lpad(resultado_foliocsuac,10,0);

          -- 10.3 SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
          LET num_tarjeta_cliente = (
            -- select nvl(st.num_tarjeta, '')
            SELECT
              case when st.num_tarjeta is null then ''
              else st.num_tarjeta
              end
            from bdicheq:"informix".sc_tarjeta  st
            where st.cuenta = resultado_cuenta_eje
            and secuencia = (
              select max(secuencia)
              from bdicheq:sc_tarjeta  st
              where st.cuenta = resultado_cuenta_eje
            )
          );

          -- VERIFICA SI YA SE HIZO EL CARGO AL CLIENTE - 
          SELECT cargo
          INTO resultado_cargo_bandera
          FROM fal_control_tramite
          WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta; 
          -- VALIDAR SI LA CUENTA TIENE REPRESENTANTE LEGAL
          LET resultado_cuenta_abonar = resultado_num_cta_beneficiario;
          IF resultado_representante_legal = 1 THEN
            LET resultado_cuenta_abonar = TRIM(resultado_descripcion_detalle);
          END IF

          IF resultado_cargo_bandera != 1 THEN -- VALIDACION EN 0 DEL CARGO AL CLIENTE
            -- EL CARGO AL CLIENTE NO SE HA REALIZADO
            -- 10.4 SE EJECUTA EL SP DE CARGO DE MONTO AL CLIENTE
            -- PRUEBA DE FLUJO
            --#######################################################################################################################################################################################################################3
            CALL bdicheq:"informix".cargo_ref(p_Empresa, resultado_num_sucursal, p_usuario , p_tran_aplica_cargo, '0000', p_FolioSUC, resultado_cuenta_eje, 0, monto_pago_bene, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
            RETURNING codret_cargo_ref, tranret_cargo_ref, fechoy_cargo_ref, sdodisp_cargo_ref, montoret_cargo_ref;
            --#######################################################################################################################################################################################################################3
            -- ASIGANCION POR PRUEBA DE FLUJO
            --LET codret_cargo_ref = '001';
            IF codret_cargo_ref = '000' THEN -- 10.5 VALIDACION DE LA EJECUCION DEL SP DE CARGO
              -- ACTUALIZA TABLA DE CONTROL
              UPDATE fal_control_tramite SET cargo_monto = monto_pago_bene, cargo = 1
              WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

              -- SI SE REALIZO CORRECTAMENTE EL CARGO AL CLIENTE
              LET num_tarjeta_beneficiario = (
                --select nvl(st.num_tarjeta, '')
                select 
                  case when st.num_tarjeta is null then ''
                  else st.num_tarjeta
                  end
                from bdicheq:"informix".sc_tarjeta  st
                where st.cuenta = resultado_num_cta_beneficiario
                and secuencia = (
                  select max(secuencia)
                  from bdicheq:sc_tarjeta  st
                  where st.cuenta = resultado_num_cta_beneficiario
                )
              );
              -- SE REALIZA EL ABONO AL BENEFICIARIO 
              -- PRUEBA DE FLUJO
              --############################################################################################################################################################################################################################################################
              CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
              --CALL bdicheq:"informix".abono_ref(dEmpresa, '9250', user, dtranaplicaabono, '0000', dFolioSuacSUC, '00000000', 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
              RETURNING vcodret_abono;
              --############################################################################################################################################################################################################################################################
              -- ASIGANCION POR PRUEBA DE FLUJO
              -- LET vcodret_abono = '001';
              IF vcodret_abono = '000' THEN -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

                -- ACTUALIZA LA TABLA DE BENEFICIARIOS
                UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = today, tramite_aplicado = 1
                WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

                --UPDATE fal_control_tramite SET exitoso = 1, monto_cargo = monto_pago_bene
                --WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                
                -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                --CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
                --RETURNING codret_blqcta,menret_blqcta;

                -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                IF cod_resp_cancelacion_debito = '069' THEN 

                  -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                  UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = today, tramite_aplicado = 1
                  WHERE  pky_cuenta_cliente_fallecido = resultado_num_cta_cliente;

                  update fal_control_tramite SET fecha_cancelacion = today, fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3
                  where cuenta_cliente_fallecido = resultado_num_cta_cliente;

                  -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                  LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                  LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.';      
                  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                  LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente, la cuenta del cliente fallecido se ha cancelado. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
                  RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

                ELSE

                  -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                  update fal_control_tramite SET exitoso = 1
                  where pky_control_tramite = resultado_pky_control_tramite_cuenta;

                  UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = today, tramite_aplicado = 1
                  WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

                  CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_cuenta_eje), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                  RETURNING codret_blqcta,menret_blqcta;

                  LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                  LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.';      
                  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                  LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
                  RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;
                END IF

              ELSE -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

                -- SI NO SE PUDO REALIZAR             
                LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';                    
                LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                -- SE REALIZA EL ABONO AL CLIENTE POR AL CARGO QUE NO PUEDO PASAR AL BENEFICIARIO
                --CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_num_cta_cliente, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
                --RETURNING vcodret_abono;
                --LET codigoRetorno = vcodret_abono;
            
                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_cuenta_eje), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                RETURNING codret_blqcta,menret_blqcta;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo abonar a la cuenta del beneficiario. Cod: ' || vcodret_abono || '/' || codret_blqcta || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          

                RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

              END IF -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

            ELSE -- 10.5 VALIDACION DE LA EJECUCION DEL SP DE CARGO

              UPDATE fal_control_tramite SET cargo = 0
              WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
              -- CUANDO NO SE REALIZO EL CARGO AL CLIENTE\-- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
              CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_cuenta_eje), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
              RETURNING codret_blqcta,menret_blqcta;

              LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';      
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido =  resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = '0';
              LET mensajeRetornoCancelacion = '';
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo realizar el cargo al cliente. Cod: ' || codigoRetorno || '/' || codret_blqcta || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          
      
              RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

            END IF -- 10.5 VALIDACION DE LA EJECUCION DEL SP DE CARGO


          ELSE -- VALIDACION EN 0 DEL CARGO AL CLIENTE

            -- VALIDAR SI SE PUDO HACER EL ABONO AL BENEFICIARIO
            SELECT aplicado
            INTO resultado_aplicado
            FROM fal_beneficiario 
            WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

            IF resultado_aplicado != 1 THEN

              -- EL CARGO YA SE HIZO AL CLIENTE SE PROCEDE A ABONAR AL BENEFICIARIO
              CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)          
              --CALL bdicheq:"informix".abono_ref(dEmpresa, '9250', user, dtranaplicaabono, '0000', dFolioSuacSUC, '00000000', 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
              RETURNING vcodret_abono;
              --LET vcodret_abono = '0022';
              -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

              IF vcodret_abono != '000' THEN          
                -- SI NO SE PUDO REALIZAR             
                LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';                    
                LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                LET codigoRetorno   = '000017';
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO            
                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_cuenta_eje), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                RETURNING codret_blqcta,menret_blqcta;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo abonar a la cuenta del beneficiario. Cod: ' || vcodret_abono || '/' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          
      
                RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;
            
              ELSE                             

                -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO
                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_cuenta_eje), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                RETURNING codret_blqcta,menret_blqcta;              

                -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;
                LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';      
                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                LET mensajeRetornoCancelacion = '0';
                LET nombreBeneficiario = resultado_nombreBeneficiario;
                
                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || '/' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          
      
                RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;
                  
              END IF

            END IF -- AQUI TERMINA

          END IF -- VALIDACION EN 0 DEL CARGO AL CLIENTE

        ELSE -- VALIDACION DE DOCUMENTACION COMPLETA

          LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO
          LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';      
          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
          LET cuentaClienteFallecido = resultado_num_cta_cliente;
          LET codigoRetornoCancelacion = '0';
          LET mensajeRetornoCancelacion = '';
          LET nombreBeneficiario = resultado_nombreBeneficiario;

          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: La documentación del beneficiario está incompleta. Cod: ' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
          RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

        END IF -- VALIDACION DE DOCUMENTACION BENEFICIARIO COMPLETA ----------------------------------------
      
      --ELSE

      --  LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
      -- LET mensajeRetorno      = 'Su folio se ha enviado a área interna.';      
      --  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      --  LET cuentaClienteFallecido = resultado_num_cta_cliente;
      --  LET codigoRetornoCancelacion = '0';
      --  LET mensajeRetornoCancelacion = '';
      --  LET nombreBeneficiario = resultado_nombreBeneficiario;

      --  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      --  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: La cuenta se encuentra en proceso interno.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
      --  RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

      --END IF -- VALIDACION PARA PROCESO MANUAL DE LA REGLA

    ELSE -- CUANDO ES NO PROCEDENTE

      -- SE ESTABLECE EL ESTATUS: 
      UPDATE fal_control_tramite SET fecha_cancelacion = today, fky_estatus_corporativo = 9 , fky_estatus_sucursal = 5, predictamen = 0
      WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta; 

      -- NO PROCEDE ()
      LET codigoRetorno       = '000018';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Predictamen no procedente.';      
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: Se asignó un predictamen no procedente.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

      
      RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

    END IF -- VALIDACION DE PROCEDE

    
  ELSE

      LET codigoRetorno       = '000002';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso.';      
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: La documentación del beneficiario está incompleta. Cod: ' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
      RETURN codigoRetorno,mensajeRetorno,cuentaBeneficiario,cuentaClienteFallecido,nombreBeneficiario,codigoRetornoCancelacion,mensajeRetornoCancelacion;

    END IF -- 1 VALIDACION DE DOCUMENTOS
  
  END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cons_servicios(p_numCliente CHAR(10))
     RETURNING  CHAR(200) AS servicio,
                CHAR(40) AS estatus;

    DEFINE r_servicio   CHAR(200);
    DEFINE r_estatus    CHAR(40);
    DEFINE iSqlErr      INTEGER;

    LET r_servicio= '';
    LET r_estatus   = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET r_servicio= '';
                    LET r_estatus= '';
            RETURN r_servicio , r_estatus;
            END IF;
        END EXCEPTION;

        FOREACH

            -- INFORMACION ACERCA DE DOMICILIACION
            SELECT  au.rfc AS rfc,  es.descripcion AS estatus
            INTO r_servicio, r_estatus
            FROM bdidomi:"informix".dom_autorizaciones au
            INNER JOIN bdidomi:"informix".dom_cat_estatusaut es ON au.cve_estatus=es.cve_estatus
            WHERE au.num_cte=p_numCliente
            and es.descripcion='Activo'

          RETURN  r_servicio , r_estatus  WITH RESUME;
    END FOREACH;
    
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cons_servicios_1(p_numCliente CHAR(10))
     RETURNING  CHAR(200) AS servicio,
                CHAR(40) AS estatus;

    DEFINE r_servicio   CHAR(200);
    DEFINE r_estatus    CHAR(40);
    DEFINE iSqlErr      INTEGER;

    LET r_servicio= '';
    LET r_estatus   = '';

    SET ISOLATION TO DIRTY READ;
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET r_servicio= '';
                    LET r_estatus= '';
            RETURN r_servicio , r_estatus;
            END IF;
        END EXCEPTION;

        FOREACH
            
            -- TOKEN
            SELECT case when (case when tks.ns_token is null then '' end) = '' then 'Token' else 'Token ' || tks.ns_token end, desc_status 
            INTO r_servicio, r_estatus
            FROM bdibpi:bpi_tokensolicitud AS tks
            LEFT JOIN bdibpi:"informix".tkn_nseries tk ON tks.ns_token = tk.ns_token
            INNER JOIN bdinteg:"informix".si_bpistatus stk ON tks.id_status = stk.id_status
            WHERE tks.numcte=TRIM(p_numCliente)


        RETURN  r_servicio , r_estatus  WITH RESUME;
    END FOREACH;
    
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cons_servicios_2(p_numCliente CHAR(10))
     RETURNING  CHAR(200) AS servicio,
                CHAR(40) AS estatus;

    DEFINE r_servicio   CHAR(200);
    DEFINE r_estatus    CHAR(40);
    DEFINE iSqlErr      INTEGER;

    LET r_servicio= '';
    LET r_estatus   = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET r_servicio= '';
                    LET r_estatus= '';
            RETURN r_servicio , r_estatus;
            END IF;
        END EXCEPTION;

        FOREACH
            -- BANCA ELECTRONICA
            select 'Banca por internet' as Servicio, st.desc_status
            INTO r_servicio, r_estatus
            FROM bdinteg:"informix".si_bpiusuarios usr
            inner join bdinteg:"informix".si_bpistatus st on st.id_status = usr.id_status
            where usr.numcte=p_numCliente

          RETURN  r_servicio , r_estatus  WITH RESUME;
    END FOREACH;
    
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cons_servicios_3(p_numCliente CHAR(10))
     RETURNING  CHAR(200) AS servicio,
                CHAR(40) AS estatus;

    DEFINE r_servicio   CHAR(200);
    DEFINE r_estatus    CHAR(40);
    DEFINE iSqlErr      INTEGER;

    LET r_servicio= '';
    LET r_estatus   = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET r_servicio= '';
                    LET r_estatus= '';
            RETURN r_servicio , r_estatus;
            END IF;
        END EXCEPTION;

        FOREACH

            --  PORTABILIDAD DE NOMINA
            SELECT 'Portabilidad de nomina' as Servicio, s.descripcion
            INTO r_servicio, r_estatus
            FROM bdicheq:"informix".sc_portabilidadnomina p
            INNER JOIN  bdicheq:"informix".sc_portaestatus s  ON p.estatus = s.estatus
            WHERE p.cliente=p_numCliente
            -- and s.descripcion = 'ACTIVO'

          RETURN  r_servicio , r_estatus  WITH RESUME;
    END FOREACH;
    
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cons_servicios_4(p_numCliente CHAR(10))
     RETURNING  CHAR(200) AS servicio,
                CHAR(40) AS estatus;

    DEFINE r_servicio   CHAR(200);
    DEFINE r_estatus    CHAR(40);
    DEFINE iSqlErr      INTEGER;
    DEFINE r_fecha_ingreso  DATE;


    LET r_servicio= '';
    LET r_estatus   = '';

    SET ISOLATION TO DIRTY READ;
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET r_servicio= '';
                    LET r_estatus= '';
            RETURN r_servicio , r_estatus;
            END IF;
        END EXCEPTION;

        -- OBTENER INFORMACION DE LA SOLICITUD
        SELECT fecha_ingreso 
        INTO r_fecha_ingreso
        FROM fal_solicitud
        WHERE num_cliente = TRIM(p_numCliente);

        FOREACH
            -- PAGOS
            SELECT pr.concepto, es.descripcion  
            INTO r_servicio, r_estatus
            FROM  bdiprog:pp_pagoprog pr
            INNER JOIN bdiprog:"informix".pp_estados es ON es.cve_estado =  pr.cve_estado
            WHERE pr.num_cte=p_numCliente
            and es.descripcion = 'Activo'
            RETURN  r_servicio , r_estatus  WITH RESUME;
        END FOREACH;
        if r_fecha_ingreso is not null THEN
            FOREACH
                SELECT pr.concepto, es.descripcion  
                INTO r_servicio, r_estatus
                FROM  bdiprog:pp_pagoprog pr
                INNER JOIN bdiprog:"informix".pp_estados es ON es.cve_estado =  pr.cve_estado
                WHERE pr.num_cte=p_numCliente
                --and es.descripcion = 'Cancelado'
                and pr.fecha_cancela <= today 
                and pr.fecha_cancela >= r_fecha_ingreso
                RETURN  r_servicio , r_estatus  WITH RESUME;
            END FOREACH;
        end if;
    
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_reinicia_secuencia_folio()

  RETURNING	  CHAR (1) AS ret; 
  DEFINE ret		CHAR(1);
  LET ret	= '1';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
			
	BEGIN
    
    ALTER SEQUENCE "informix".solicitud_consecutivo_seq restart with 1;
    RETURN  ret;
		
  END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_asignar_analista_credito(resultado_fky_usuario_analista INTEGER,p_idSolicitud INTEGER, p_numeroCredito CHAR(20), p_numeroTarjeta char(8),resultado_pky_control_tramite_cuenta INTEGER, p_codigoAdjunto CHAR(6))
  RETURNING CHAR(6) as codigoRetorno, 
            CHAR(250) as mensajeRetorno,
            CHAR(20) as numeroCredito,
            CHAR(16) as numeroTarjeta;

  DEFINE codigoRetorno        CHAR(6);
  DEFINE mensajeRetorno       CHAR(250);  
  DEFINE numeroCredito        CHAR(20);
  DEFINE numeroTarjeta        CHAR(16);

  DEFINE resultado_asign_num_empleado CHAR(9);
  -- RESULTADO ASIGNACION ANALISTA
  DEFINE resultado_asign_usuario INTEGER;
  DEFINE resultado_asign_usuario_2 INTEGER;

  DEFINE resultado_num_analistas INTEGER;

  LET codigoRetorno            = '';
  LET mensajeRetorno           = '';  
  LET numeroCredito            = '';
  LET numeroTarjeta            = '';

  LET resultado_asign_usuario = 0;
  LET resultado_asign_usuario_2 = 0;
  LET resultado_num_analistas = 0;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

BEGIN

--VALIDACION DE ASIGNACION DE USUARIO ANALISTA
  IF resultado_fky_usuario_analista = 0 OR resultado_fky_usuario_analista IS NULL THEN
  -- PRIMERO SE VERIFICA QUE HAYA USUARIOS CON LOS PERMISOS DEL TABLARO Y TABLERO AE
    --select first 1 distinct(au.num_empleado), au.pky_usuario
    SELECT count(*)
    --INTO resultado_asign_num_empleado,resultado_asign_usuario
    INTO resultado_num_analistas
    FROM acl_usuario au
    INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
    INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
    INNER JOIN acl_permiso ap on app.fky_id_permiso = ap.pky_id_permiso
    WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO')
    AND au.activo = 1;

    --a) VALIDACION USUARIO ANALISTA
    IF resultado_num_analistas = 0 THEN
      --SE REGRESA CODIGO DE RETORNO
      LET codigoRetorno       = '000009';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'No hay analistas con los permisos requeridos.';      
      LET numeroCredito       = p_numeroCredito;
      LET numeroTarjeta       = p_numeroTarjeta;
        
      RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;
    
    ELSE --resultado_asign_usuario IS NULL THEN
      -- QUERY PARA OBTENER EL USUARIO QUE NO TENGA ASIGNADA UNA SOLICITUD
      SELECT FIRST 1 au.pky_usuario as pky_usuario
      INTO resultado_asign_usuario_2
      FROM acl_usuario au
      INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
      INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
      INNER JOIN acl_permiso ap on app.fky_id_permiso = ap.pky_id_permiso
      WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO')
      AND au.activo = 1
      AND au.pky_usuario not in 
        (SELECT au.pky_usuario
        FROM acl_usuario au
        INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
        INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
        INNER JOIN fal_solicitud fs on fs.fky_usuario_analista = au.pky_usuario
        WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO'));
        --b) VALIDACION ASIGNACION DE USUARIO
      IF resultado_asign_usuario_2 IS NULL THEN
        --SE OBTIENE EL NUMERO MAXIMO DE SOLICITUDES PARA REALIZAR LA ASIGNACION DE SOLICITUDES CON EL MENOR Y MISMO NUMERO DE CONTEO     
        FOREACH
          SELECT first 1 au.pky_usuario
          INTO resultado_asign_usuario_2
          FROM acl_usuario au
          INNER JOIN fal_solicitud fs on fs.fky_usuario_analista = au.pky_usuario
          INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
          INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
          WHERE app.fky_id_permiso in (select pky_id_permiso from acl_permiso WHERE nombre = 'FAL_TABLERO')
          AND au.activo = 1
          GROUP by au.pky_usuario
          ORDER BY count(*) ASC 
        END FOREACH;  

        -- SE REALIZA LA ASIGNACION AL ANALISTA QUE NO TIENE ASIGNACION DE SOLICITUD
        UPDATE fal_solicitud SET fky_usuario_analista = resultado_asign_usuario_2
        WHERE pky_solicitud = p_idSolicitud;

        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
        where pky_control_tramite = resultado_pky_control_tramite_cuenta;

        -- SE REALIZA ASIGANCION DE SOLICITUD
        LET codigoRetorno       = p_codigoAdjunto;                       -- CODIGO DEFINIDO
        LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';   -- SE REALIZO LA ASIGNACION DE ANALISTA      
        LET numeroCredito       = p_numeroCredito;
        LET numeroTarjeta       = p_numeroTarjeta;
        
        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

      ELSE --resultado_asign_usuario_2 IS NULL
        -- SE REALIZA LA ASIGNACION AL ANALISTA QUE NO TIENE ASIGNACION DE SOLICITUD
        UPDATE fal_solicitud SET fky_usuario_analista = resultado_asign_usuario_2
        WHERE pky_solicitud = p_idSolicitud;

        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
        where pky_control_tramite = resultado_pky_control_tramite_cuenta;

        -- SE REALIZA ASIGANCION DE SOLICITUD
        LET codigoRetorno       = p_codigoAdjunto;                       -- CODIGO DEFINIDO
        LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';   -- SE REALIZO LA ASIGNACION DE ANALISTA      
        LET numeroCredito       = p_numeroCredito;
        LET numeroTarjeta       = p_numeroTarjeta;

        RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;
                
      END IF  --FIN b) VALIDACION ASIGNACION DE USUARIO
    END IF --FIN a) VALIDACION USUARIO ANALISTA

  ELSE 
    
    UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
    where pky_control_tramite = resultado_pky_control_tramite_cuenta;

    -- SE REALIZA ASIGANCION DE SOLICITUD
    LET codigoRetorno       = p_codigoAdjunto;                       -- CODIGO DEFINIDO
    LET mensajeRetorno      = 'La liquidación de recursos se hará en Central. Usuario ya asignado.';   -- SE REALIZO LA ASIGNACION DE ANALISTA      
    LET numeroCredito       = p_numeroCredito;
    LET numeroTarjeta       = p_numeroTarjeta;
        
    RETURN codigoRetorno,mensajeRetorno,numeroCredito,numeroTarjeta;

  END IF -- FIN VALIDA SI YA SE HA ASIGNADO A UN ANALISTA

END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista INTEGER,p_idSolicitud INTEGER, resultado_num_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario char(8),resultado_nombreBeneficiario CHAR(100),resultado_pky_control_tramite_cuenta INTEGER)
  RETURNING CHAR(6) as codigoRetorno, 
            CHAR(250) as mensajeRetorno, 
            CHAR(1) as tipoAccion, 
            CHAR(20) AS cuentaBeneficiario,
            CHAR(20) as cuentaClienteFallecido,
            CHAR(6) as codigoRetornoCancelacion,
            CHAR(250) as mensajeRetornoCancelacion,
            CHAR(100) as nombreBeneficiario;

  DEFINE codigoRetorno        CHAR(6);
  DEFINE mensajeRetorno       CHAR(250);  
  DEFINE tipoAccion           CHAR(1);
  DEFINE cuentaBeneficiario   CHAR(20);
  DEFINE cuentaClienteFallecido CHAR(20);
  DEFINE codigoRetornoCancelacion CHAR(6);
  DEFINE mensajeRetornoCancelacion CHAR(250);
  DEFINE nombreBeneficiario CHAR(100);

  DEFINE resultado_asign_num_empleado CHAR(9);
  -- RESULTADO ASIGNACION ANALISTA
  DEFINE resultado_asign_usuario INTEGER;
  DEFINE resultado_asign_usuario_2 INTEGER;
  DEFINE resultado_estatus_corporativo INTEGER;
  DEFINE resultado_doctos_corporativo INTEGER;
  
  DEFINE resultado_id_permiso INTEGER;

  LET codigoRetorno            = '';
  LET mensajeRetorno           = '';  
  LET tipoAccion               = '';
  LET cuentaBeneficiario       = '';
  LET cuentaClienteFallecido   = '';
  LET codigoRetornoCancelacion = '';
  LET mensajeRetornoCancelacion= '';
  LET nombreBeneficiario       = '';

  LET resultado_asign_usuario=0;
  LET resultado_asign_usuario_2=0;

  --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/liquidacionAsignarAnalista_"||p_idSolicitud||"_"||TRIM(p_cta_beneficiario)||"_34_TEST.out"; 
  --TRACE ON;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
   
  BEGIN

        SELECT fky_estatus_corporativo,control_doctos_corporativo
        INTO resultado_estatus_corporativo, resultado_doctos_corporativo
        FROM fal_control_tramite
        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
		
		SELECT pky_id_permiso 
		INTO resultado_id_permiso
		FROM acl_permiso 
		WHERE nombre = 'FAL_TABLERO';


        --VALIDACIÓN DE ASIGNACIÓN DE USUARIO ANALISTA
        IF resultado_fky_usuario_analista = 0 OR resultado_fky_usuario_analista IS NULL  THEN
          -- PRIMERO SE VERIFICA QUE HAYA USUARIOS CON LOS PERMISOS DEL TABLARO Y TABLERO AE
          select first 1 distinct(au.num_empleado), au.pky_usuario
          INTO resultado_asign_num_empleado,resultado_asign_usuario
          FROM acl_usuario au
          INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
          INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
          INNER JOIN acl_permiso ap on app.fky_id_permiso = ap.pky_id_permiso
          WHERE app.fky_id_permiso = resultado_id_permiso AND au.activo = 1;

            --a) VALIDACION USUARIO ANALISTA
            IF resultado_asign_usuario IS NULL THEN
              --SE REGRESA CODIGO DE RETORNO
              LET codigoRetorno       = '000009';                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'No hay analistas con los permisos requeridos.';      
              LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = '';
              LET mensajeRetornoCancelacion = '';            
              LET nombreBeneficiario = resultado_nombreBeneficiario;
        
              RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            ELSE --resultado_asign_usuario IS NULL THEN
              -- QUERY PARA OBTENER EL USUARIO QUE NO TENGA ASIGNADA UNA SOLICITUD
              SELECT FIRST 1 au.pky_usuario as pky_usuario
              INTO resultado_asign_usuario_2
              FROM acl_usuario au
              INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
              INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
              INNER JOIN acl_permiso ap on app.fky_id_permiso = ap.pky_id_permiso
              WHERE app.fky_id_permiso = resultado_id_permiso
              AND au.pky_usuario not in 
              (SELECT au.pky_usuario
              FROM acl_usuario au
              INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
              INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
              INNER JOIN fal_solicitud fs on fs.fky_usuario_analista = au.pky_usuario
              WHERE app.fky_id_permiso = resultado_id_permiso 
              AND au.activo = 1);
             --b) VALIDACION ASIGNACIÓN DE USUARIO
              IF resultado_asign_usuario_2 IS NULL THEN
                --SE OBTIENE EL NUMERO MAXIMO DE SOLICITUDES PARA REALIZAR LA ASIGNACION DE SOLICITUDES CON EL MENOR Y MISMO NUMERO DE CONTEO     
                  FOREACH
                    SELECT first 1 au.pky_usuario
                    INTO resultado_asign_usuario_2
                    FROM acl_usuario au
                    INNER JOIN fal_solicitud fs on fs.fky_usuario_analista = au.pky_usuario
                    INNER JOIN acl_perfil_usuario apu on apu.fky_usuario = au.pky_usuario
                    INNER JOIN acl_perfil_permiso app on app.fky_id_perfil = apu.fky_id_perfil
                    WHERE app.fky_id_permiso = resultado_id_permiso AND au.activo = 1
                    GROUP by au.pky_usuario
                    ORDER BY count(*) ASC 
                  END FOREACH;  

                  -- SE REALIZA LA ASIGNACION AL ANALISTA QUE NO TIENE ASIGNACION DE SOLICITUD
                  UPDATE fal_solicitud SET fky_usuario_analista = resultado_asign_usuario_2
                  WHERE pky_solicitud = p_idSolicitud;

                  -- VALIDAR EL CAMBIO DE ESTATUS POR DOCUMENTACION INCONSISTENTE, RECHAZO DE AREA EXTERNA, RESPUESTA DE AREA EXTERNA
                  -- 1) VALIDAR EL TIPO INVERSION

                  IF resultado_pky_control_tramite_cuenta = 0 AND resultado_estatus_corporativo <> 6 AND resultado_estatus_corporativo <> 4 AND resultado_estatus_corporativo <> 5 AND resultado_estatus_corporativo <> 11 AND resultado_doctos_corporativo <> 0 THEN
                      
                    UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2 
                    WHERE cuenta_cliente_fallecido = resultado_num_cta_cliente
                    AND fky_tipo_tramite = 4;

                  ELSE

                    IF resultado_estatus_corporativo  = 8 AND resultado_doctos_corporativo = 0 THEN

                      UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
                      where pky_control_tramite = resultado_pky_control_tramite_cuenta;

                    ELSE

                      IF resultado_estatus_corporativo <> 4 AND resultado_estatus_corporativo <> 5 AND resultado_estatus_corporativo <> 11 AND resultado_doctos_corporativo <> 0 AND resultado_estatus_corporativo <> 6 THEN
                        
                        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
                        where pky_control_tramite = resultado_pky_control_tramite_cuenta;

                      END IF
                    END IF
                  END IF
                  -- SE REALIZA ASIGANCION DE SOLICITUD
                  LET codigoRetorno       = '000008';                       -- CODIGO DEFINIDO
                  LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';   -- SE REALIZO LA ASIGNACION DE ANALISTA      
                  LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                  LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente; 
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;
          
                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;                 
              ELSE --resultado_asign_usuario_2 IS NULL
                -- SE REALIZA LA ASIGNACION AL ANALISTA QUE NO TIENE ASIGNACION DE SOLICITUD
                UPDATE fal_solicitud SET fky_usuario_analista = resultado_asign_usuario_2
                WHERE pky_solicitud = p_idSolicitud;

                  IF resultado_pky_control_tramite_cuenta = 0 AND resultado_estatus_corporativo <> 6 AND resultado_estatus_corporativo <> 4 AND resultado_estatus_corporativo <> 5 AND resultado_estatus_corporativo <> 11 AND resultado_doctos_corporativo <> 0 THEN
                    UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2 
                    WHERE cuenta_cliente_fallecido = resultado_num_cta_cliente
                    AND fky_tipo_tramite = 4;

                  ELSE

                    IF resultado_estatus_corporativo  = 8 AND resultado_doctos_corporativo = 0 THEN

                      UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
                      where pky_control_tramite = resultado_pky_control_tramite_cuenta;

                    ELSE

                      IF resultado_estatus_corporativo <> 4 AND resultado_estatus_corporativo <> 5 AND resultado_estatus_corporativo <> 11 AND resultado_doctos_corporativo <> 0 AND resultado_estatus_corporativo <> 6 THEN
                        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
                        where pky_control_tramite = resultado_pky_control_tramite_cuenta;
                      END IF
                    END IF
                  END IF

                -- SE REALIZA ASIGANCION DE SOLICITUD
                LET codigoRetorno       = '000008';                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';   -- SE REALIZO LA ASIGNACION DE ANALISTA      
                LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido = resultado_num_cta_cliente; 
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;
          
                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
              END IF  --FIN b) VALIDACION ASIGNACIÓN DE USUARIO
            END IF --FIN a) VALIDACION USUARIO ANALISTA

            ELSE 
                  IF resultado_pky_control_tramite_cuenta = 0 AND resultado_estatus_corporativo <> 6 AND resultado_estatus_corporativo <> 4 AND resultado_estatus_corporativo <> 5 AND resultado_estatus_corporativo <> 11 AND resultado_doctos_corporativo <> 0 THEN
                    UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2 
                    WHERE cuenta_cliente_fallecido = resultado_num_cta_cliente
                    AND fky_tipo_tramite = 4;
                  ELSE

                    IF resultado_estatus_corporativo  = 8 AND resultado_doctos_corporativo = 0 THEN

                      UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
                      where pky_control_tramite = resultado_pky_control_tramite_cuenta;

                    ELSE


                      IF resultado_estatus_corporativo <> 4 AND resultado_estatus_corporativo <> 5 AND resultado_estatus_corporativo <> 11 AND resultado_doctos_corporativo <> 0 AND resultado_estatus_corporativo <> 6 THEN
                        UPDATE fal_control_tramite SET fky_estatus_corporativo = 2 , fky_estatus_sucursal = 2
                        where pky_control_tramite = resultado_pky_control_tramite_cuenta;
                      END IF
                    END IF
                  END IF

                -- SE REALIZA ASIGANCION DE SOLICITUD
                LET codigoRetorno       = '000008';                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'La liquidación de recursos se hará en Central. Usuario ya asignado';   -- SE REALIZO LA ASIGNACION DE ANALISTA      
                LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                LET cuentaBeneficiario  = p_cta_beneficiario;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido = resultado_num_cta_cliente; 
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
        END IF -- FIN VALIDA SI YA SE HA ASIGNADO A UN ANALISTA

END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_traspaso_cuentas_inversion(p_usuario char(8), p_cta_cliente char(20), p_idSolicitud INTEGER, monto_original MONEY, monto_original_ctrl_tramite MONEY)

    --VARIABLES DE RETORNO
    RETURNING CHAR(6)   AS codigo_retorno,
              CHAR(250) AS mensaje_retorno;

    -- DEFINICION DE VARIABLES DE RETORNO
    DEFINE codigo_retorno            CHAR(6);
    DEFINE mensaje_retorno           CHAR(250);
    DEFINE cuenta_cliente_fallecido   CHAR(20);
    DEFINE resultado_cuenta_eje     CHAR(20);

    -- ESTATUS DE CUENTA FALLECIDO
    DEFINE resultado_cuenta_estatus CHAR(2);
    DEFINE resultado_cuenta_motivo CHAR(2);
    DEFINE resultado_cuenta_eje_estatus CHAR(2);
    DEFINE resultado_cuenta_eje_motivo CHAR(2);

    --SALDO
    DEFINE saldo_cuenta_inv MONEY;
    DEFINE saldo_cuenta MONEY;
    DEFINE saldo_congelado MONEY;

    -- SE GENERA EL FOLIO SUC
    DEFINE p_fecha_folio  CHAR(10);
    DEFINE p_FolioSUC     CHAR(16);

    --INFORMACIÓN DE SOLICITUD
    DEFINE resultado_foliocsuac CHAR(12);
    DEFINE fky_usuario_analista INTEGER;
    DEFINE resultado_num_sucursal CHAR(10);

    -- CONSTANTES
    DEFINE p_Empresa    CHAR(3);
    DEFINE p_Ejecutivo  CHAR(20);
    DEFINE p_tran_aplica_cargo CHAR(4);    
    DEFINE p_tran_aplica_abono CHAR(4);    

    -- bdicheq:"informix".cargo_red
    DEFINE codret_cargo_ref      CHAR(6);
    DEFINE tranret_cargo_ref     CHAR(4);
    DEFINE fechoy_cargo_ref      DATE;
    DEFINE sdodisp_cargo_ref     MONEY(14,2);
    DEFINE montoret_cargo_ref    MONEY(14,2);  

    -- bdicheq:"informix".abono_ref
    DEFINE vcodret_abono  CHAR(6);
    DEFINE vcodret_abono_inv  CHAR(6);

    DEFINE codigoRetorno        CHAR(6);
    DEFINE mensajeRetorno       CHAR(250);  
    DEFINE tipoAccion           CHAR(1);
    DEFINE cuentaBeneficiario   CHAR(20);
    DEFINE cuentaClienteFallecido CHAR(20);
    DEFINE codigoRetornoCancelacion CHAR(6);
    DEFINE mensajeRetornoCancelacion CHAR(250);
    DEFINE nombreBeneficiario CHAR(100);
      
    -- bdicheq:"informix".bloqueo_cta
    DEFINE codret_blqcta CHAR(6);
    DEFINE menret_blqcta CHAR(250);
    DEFINE codret_blqcta_eje CHAR(6);
    DEFINE menret_blqcta_eje CHAR(250);

    --bloqueo por monto
    DEFINE codret_blqcta_monto CHAR(6);
    DEFINE menret_blqcta_monto CHAR(250);
    DEFINE existe_saldo_congelado INTEGER;

    --ctrl tramite de inversion para cuando el cargo ya se realizo
    --DEFINE monto_original_ctrl_tramite    MONEY(14,2);
    DEFINE cambio_instruccion_pagare SMALLINT;
    DEFINE liquida_pagare SMALLINT;


    LET codigo_retorno   = '000001';
    LET mensaje_retorno  = 'Información incompleta';
    LET cuenta_cliente_fallecido = p_cta_cliente;
    LET resultado_cuenta_eje = '';
    LET resultado_cuenta_estatus = '';
    LET resultado_cuenta_motivo = '';
    LET resultado_cuenta_eje_estatus = '';
    LET resultado_cuenta_eje_motivo = '';
    LET saldo_cuenta_inv = 0;
    LET saldo_cuenta = 0;
    LET resultado_foliocsuac = '';
    LET existe_saldo_congelado = 0;



    -- CONSTANTES
    LET p_Empresa   = '001';
    LET p_Ejecutivo = '001';
    LET p_tran_aplica_cargo = '0409';
    LET p_tran_aplica_abono = '0408';

    -- DEFINICION DE VARIABLES DE RETORNO
    LET codigoRetorno       = '';
    LET mensajeRetorno      = '';  
    LET tipoAccion          = '';
    LET cuentaBeneficiario  = '';
    LET cuentaClienteFallecido = '';
    LET codigoRetornoCancelacion = '0';
    LET mensajeRetornoCancelacion = '';
    LET nombreBeneficiario = '';

    LET fky_usuario_analista = 0;
    LET cambio_instruccion_pagare = 0;
    LET liquida_pagare = 0;

    --LOG
    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/traspasoInversionTETdsfsdf_"||trim(p_cta_cliente)||"_34.out"; 
    --TRACE ON;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN 

        IF p_cta_cliente IS NULL THEN
          LET p_cta_cliente = '';
        END IF
        IF p_usuario IS NULL THEN
          LET p_usuario = '';
        END IF

        IF p_cta_cliente IS NULL OR TRIM(p_cta_cliente) = '' OR TRIM(p_usuario) = '' THEN

            LET codigo_retorno   = '000001';
            LET mensaje_retorno  = 'Información incompleta';
            LET cuenta_cliente_fallecido = p_cta_cliente;
            LET resultado_cuenta_eje = '';
            RETURN codigo_retorno,mensaje_retorno;

        END IF

             LET saldo_cuenta = monto_original;

        --0) CONSULTAR ID DE SOLICITUD
             SELECT folio_csuac,fky_usuario_analista, num_sucursal
             INTO resultado_foliocsuac, fky_usuario_analista, resultado_num_sucursal
             FROM fal_solicitud
             WHERE pky_solicitud = p_idSolicitud;


        --1) CONSULTAR CUENTA EJE DE LA CUENTA DE INVERSIÓN
            SELECT cuentadep
            INTO resultado_cuenta_eje
            FROM bdicheq:"informix".sc_maechq qc 
            LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta ) 
            WHERE qc.cuenta = p_cta_cliente;
          
           --CONGELAR MONTO 
            SELECT sdo_cong
            INTO saldo_congelado
            FROM bdicheq:"informix".sc_maechq qc 
            WHERE qc.cuenta=TRIM(resultado_cuenta_eje);

            IF saldo_congelado != 0 THEN
                LET existe_saldo_congelado = 1;
            END IF

            
        --3)CONSULTAR SALDO DE INVERSIÓN

           SELECT sdo_actual
           INTO saldo_cuenta_inv
           FROM bdicheq:"informix".sc_maechq qc 
           LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta ) 
           WHERE qc.cuenta=p_cta_cliente;


        --DESBLOQUEO DE LA CUENTA EJE Y CUENTA DE INVERSIÓN
           --LET codret_blqcta = '000';
           IF existe_saldo_congelado = 1 THEN 
              CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje), saldo_cuenta, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )              
              RETURNING codret_blqcta_eje,menret_blqcta_eje;
           ELSE 
              CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
              RETURNING codret_blqcta_eje,menret_blqcta_eje;        
           END IF

           IF TRIM(codret_blqcta_eje) !='000'  THEN

              LET codigo_retorno   = '000004';
              LET mensaje_retorno  = 'No se desbloqueo alguna de las cuentas.';
              LET cuenta_cliente_fallecido = p_cta_cliente;
              LET resultado_cuenta_eje = resultado_cuenta_eje;
              RETURN codigo_retorno,mensaje_retorno;
           END IF

           --SI EL SALDO DE LA CUENTA DE INVERSIÓN ESTA EN 0 ENTONCES NO SE HACE EL DESBLOQUEO DE LA CUENTA
           IF saldo_cuenta_inv != 0 THEN
            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,p_cta_cliente,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
            RETURNING codret_blqcta,menret_blqcta;    


            IF TRIM(codret_blqcta) != '000' THEN

               LET codigo_retorno   = '000004';
               LET mensaje_retorno  = 'No se desbloqueo alguna de las cuentas.';
               LET cuenta_cliente_fallecido = p_cta_cliente;
               LET resultado_cuenta_eje = resultado_cuenta_eje;
               RETURN codigo_retorno,mensaje_retorno;
            END IF
          END IF


               --LET saldo_cuenta_inv = 10000;
               /*IF saldo_cuenta_inv = 0 THEN

                  -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa,p_cta_cliente,'0','04',3,today,p_usuario,'','11','S','12','Z')
                  RETURNING codret_blqcta,menret_blqcta;    

                     IF existe_saldo_congelado = 1 THEN 
                        CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                        RETURNING codret_blqcta_monto, menret_blqcta_monto;       
                     ELSE 
                        CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                        RETURNING codret_blqcta_eje,menret_blqcta_eje;        
                     END IF

                  LET codigo_retorno   = '000000';
                  LET mensaje_retorno  = 'La cuenta de inversión no cuenta con saldo suficiente para hacer un cargo. Se manda a cancelar';
                  LET cuenta_cliente_fallecido = p_cta_cliente;
                  LET resultado_cuenta_eje = resultado_cuenta_eje;
                  RETURN codigo_retorno,mensaje_retorno;
                    
               END IF

                    --3.1 EN CASO DE QUE EL MONTO DE INVERSIÓN SEA MAYOR A 0 */
                  
                    --Se genera el folioSuc
                    --SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
                    --INTO p_fecha_folio
                    --FROM systables WHERE tabid=1;

                    LET p_fecha_folio = substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2);

                    LET p_FolioSUC = trim(p_fecha_folio) || lpad(resultado_foliocsuac,10,0);
                    
                    SELECT LIMIT  1 
                        case when cambio_instruccion_pagare is null then 0
                        else cambio_instruccion_pagare
                        end,
                        --nvl(cambio_instruccion_pagare,0),
                        case when liquida_pagare is null then 0
                        else liquida_pagare
                        end
                        --nvl(liquida_pagare,0)
                    INTO cambio_instruccion_pagare,liquida_pagare
                    FROM  fal_control_tramite WHERE cuenta_cliente_fallecido = p_cta_cliente;

                    --Validar si existe un cargo previamente realizado
                    IF saldo_cuenta_inv = 0 and cambio_instruccion_pagare != 1 and liquida_pagare != 1 THEN
                      --1) CONSULTAR MONTO ORIGINAL DE CONTROL TRAMITE DE LA CUENTA DE INVERSION
                       -- SELECT limit 1 monto_original 
                       -- INTO monto_original_ctrl_tramite 
                       -- FROM fal_control_tramite 
                       -- WHERE cuenta_cliente_fallecido = p_cta_cliente;

                        let saldo_cuenta_inv = monto_original_ctrl_tramite;

                    ELSE
                    --CARGO
                        CALL bdicheq:"informix".cargo_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_cargo, '0000', p_FolioSUC, p_cta_cliente, 0, saldo_cuenta_inv, '01', resultado_foliocsuac, '', p_Ejecutivo)
                        RETURNING codret_cargo_ref, tranret_cargo_ref, fechoy_cargo_ref, sdodisp_cargo_ref, montoret_cargo_ref;

                        --LET codret_cargo_ref = '000';

                        --VALIDACION DE LA EJECUCION DEL SP DE CARGO
                        IF TRIM(codret_cargo_ref) != '000' THEN

                            -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                            IF existe_saldo_congelado = 1 THEN 
                               CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                               RETURNING codret_blqcta_monto, menret_blqcta_monto;       
                            ELSE 
                               CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                               RETURNING codret_blqcta_eje,menret_blqcta_eje;        
                            END IF

                            LET codigo_retorno   = '000005';
                            LET mensaje_retorno  = 'No se hizo el cargo a la cuenta eje: '||codret_cargo_ref||'.';
                            LET cuenta_cliente_fallecido = p_cta_cliente;
                            LET resultado_cuenta_eje = resultado_cuenta_eje;
                            RETURN codigo_retorno,mensaje_retorno;
                        END IF
                        
/**
                          SELECT status_cta, motivo
                          INTO resultado_cuenta_estatus,resultado_cuenta_motivo
                          FROM bdicheq:sc_maechq 
                          WHERE cuenta = p_cta_cliente;

                          IF resultado_cuenta_estatus = 2 THEN
                             UPDATE fal_control_tramite SET fecha_cancelacion = today, fky_estatus_corporativo = 6 , fky_estatus_sucursal = 3
                             WHERE cuenta_cliente_fallecido = p_cta_cliente 
                             AND fky_tipo_tramite = 4; 
                          END IF

**/
                    END IF

                    --ABONO 
                    --CALL bdicheq:"informix".abono_ref('001', '5007', '92891667', '0408', '0000', '170414F111217001', '10036083501', 0, 10354.86, 10354.86, 0, 0, 0, '01', 'F1112170002', '', '001')
                    CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_eje, 0, saldo_cuenta_inv, saldo_cuenta_inv, 0, 0, 0, '01', resultado_folioCsuac, '', p_Ejecutivo)
                    RETURNING vcodret_abono;
 
                    --LET vcodret_abono = '000';
                    -- VALIDACION NO SE PUDO HACER EL ABONO AL BENEFICIARIO
                    IF TRIM(vcodret_abono) != '000' THEN  

                        -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE  

                        IF existe_saldo_congelado = 1 THEN 
                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                           RETURNING codret_blqcta_monto, menret_blqcta_monto;       
                        ELSE 
                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                           RETURNING codret_blqcta_eje,menret_blqcta_eje;        
                        END IF

                        LET codigo_retorno   = '000006';
                        LET mensaje_retorno  = 'No se realiza el abono a la cuenta eje ' ||resultado_cuenta_eje;
                        LET cuenta_cliente_fallecido = p_cta_cliente;
                        LET resultado_cuenta_eje = resultado_cuenta_eje;
                        RETURN codigo_retorno,mensaje_retorno;

                    END IF
/**
                        LET codigo_retorno   = '000000';
                        LET mensaje_retorno  = '';
                        LET cuenta_cliente_fallecido = p_cta_cliente;
                        LET resultado_cuenta_eje = resultado_cuenta_eje;
 **/

                       --SE HACE EL ABONO

                        --SI EL SALDO DE LA CUENTA EJE ES MAYOR A 0 ENTONCES SE HACE EL BLOQUEO POR MONTO
                        IF saldo_cuenta > 0 AND existe_saldo_congelado = 0 THEN

                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                            RETURNING codret_blqcta_monto, menret_blqcta_monto;       
                           
                           --LET codret_blqcta_monto = '000';
                           IF codret_blqcta_monto != '000' THEN  
                            
                            -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                                LET codigo_retorno   = codret_blqcta_monto;
                                LET mensaje_retorno  = 'No se realiza el bloqueo por monto a la cuenta eje.';
                                LET cuenta_cliente_fallecido = p_cta_cliente;
                                LET resultado_cuenta_eje = resultado_cuenta_eje;
                                RETURN codigo_retorno,mensaje_retorno;

                           END IF
                        
                        --EN CASO DE QUE EL MONTO SEA MENOR A 0, SE ENVIA A CORPORATIVO
                        ELIF saldo_cuenta < 0 THEN 
                            -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 

                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;  

                            LET codigo_retorno   = '000007';
                            LET mensaje_retorno  = 'Monto de cuenta eje menor a 0.';
                            LET cuenta_cliente_fallecido = p_cta_cliente;
                            LET resultado_cuenta_eje = resultado_cuenta_eje;
                            RETURN codigo_retorno,mensaje_retorno;
                            
                        END IF


                        -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                        IF existe_saldo_congelado = 1 THEN 
                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                           RETURNING codret_blqcta_monto, menret_blqcta_monto;       
                        ELSE 
                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                           RETURNING codret_blqcta_eje,menret_blqcta_eje;        
                        END IF
                        LET codigo_retorno   = '000000';
                        LET mensaje_retorno  = 'Ejecución completa.';
                        LET cuenta_cliente_fallecido = p_cta_cliente;
                        LET resultado_cuenta_eje = resultado_cuenta_eje;
                        RETURN codigo_retorno,mensaje_retorno;
                        

                        
        
    END 
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_liquidacion_cuenta_inversion_corporativo(p_idSolicitud INTEGER, p_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario char(8), p_procede INTEGER, pky_resolucion INTEGER)

  RETURNING CHAR(6) as codigoRetorno,
            CHAR(250) as mensajeRetorno,
            CHAR(1) as tipoAccion,
            CHAR(20) AS cuentaBeneficiario,
            CHAR(20) as cuentaClienteFallecido,
            CHAR(6) as codigoRetornoCancelacion,
            CHAR(250) as mensajeRetornoCancelacion,
            CHAR(100) as nombreBeneficiario;


  -- 0) DEFINICION VARIABLES DE RETORNO
  DEFINE codigoRetorno        CHAR(6);
  DEFINE mensajeRetorno       CHAR(250);
  DEFINE tipoAccion           CHAR(1);
  DEFINE cuentaBeneficiario   CHAR(20);
  DEFINE cuentaClienteFallecido CHAR(20);
  DEFINE codigoRetornoCancelacion CHAR(6);
  DEFINE mensajeRetornoCancelacion CHAR(250);
  DEFINE nombreBeneficiario CHAR(100);
  DEFINE monto_a_buscar_regla_negocio   MONEY(14,2);
  DEFINE resultado_nombre_accion_procede CHAR(20);
  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  DEFINE resultado_numero_cliente       CHAR(9);
  DEFINE resultado_foliocsuac           CHAR(12);
  DEFINE resultado_fky_usuario_analista INTEGER;
  DEFINE resultado_num_sucursal CHAR(10);
  DEFINE resultado_pky_resolucion INTEGER;

  -- 2) QUERY DE CONTROL
  DEFINE resultado_pky_control_tramite_cuenta   INTEGER;
  DEFINE resultado_num_cta_cliente              CHAR(20);
  DEFINE resultado_num_cta_beneficiario         CHAR(20);
  DEFINE resultado_porcentaje_bene              DECIMAL(9,6);
  DEFINE resultado_tramite                      INTEGER;
  DEFINE resultado_exitoso                      INTEGER;
  DEFINE resultado_tipo_cancelacion             INTEGER;
  --DEFINE resultado_fecha_vencimiento            DATE;
  DEFINE resultado_monto_original               MONEY(14,2);
  DEFINE resultado_monto_inversion                 MONEY(14,2);
  DEFINE resultado_descripcion_detalle          CHAR(100);
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  DEFINE v_numero_documentos_necesarios_beneficiario     INTEGER;
  DEFINE v_numero_documentos_digitalizados_beneficiario  INTEGER;

  DEFINE v_numero_documentos_necesarios_fallecido     INTEGER;
  DEFINE v_numero_documentos_digitalizados_fallecido  INTEGER;

  DEFINE resultado_estatus_cuenta_beneficiario  CHAR(1);
  DEFINE resultado_estatus_cuenta_cliente_fallecido CHAR(1);
  DEFINE resultado_estatus_cuenta_eje CHAR(1);
  DEFINE resultado_motivo CHAR(2);
  DEFINE resultado_motivo_eje CHAR(2);
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  DEFINE monto_pago_bene            MONEY(14,2);
  DEFINE saldo_cuenta_eje           MONEY(14,2);
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  DEFINE resultado_accion         INTEGER;
  DEFINE resultado_num_empleado   CHAR(8);
  DEFINE resultado_num_suc        CHAR(4);
  DEFINE resultado_pky_rango_importe  INTEGER;
  DEFINE resultado_rango_inferior      MONEY;
  -- bdicheq:"informix".bloqueo_cta
  DEFINE codret_blqcta CHAR(6);
  DEFINE menret_blqcta CHAR(250);

  DEFINE codret_blqcta_eje CHAR(6);
  DEFINE menret_blqcta_eje CHAR(250);

  -- bdicheq:"informix".cargo_red
  DEFINE codret_cargo_ref      CHAR(6);
  DEFINE tranret_cargo_ref     CHAR(4);
  DEFINE fechoy_cargo_ref      DATE;
  DEFINE sdodisp_cargo_ref     MONEY(14,2);
  DEFINE montoret_cargo_ref    MONEY(14,2);
  -- bdicheq:"informix".abono_ref
  DEFINE vcodret_abono  CHAR(6);
  -- 10.2 SE GENERA EL FOLIO SUC
  DEFINE p_fecha_folio  CHAR(10);
  DEFINE p_FolioSUC     CHAR(16);
  -- 10.3 SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  DEFINE num_tarjeta_cliente      CHAR(20);
  DEFINE num_tarjeta_beneficiario CHAR(20);
  -- VALIDACION DE BANDERA DE CARGO
  DEFINE resultado_cargo_bandera INTEGER;
  -- CONSTANTES
  DEFINE p_Empresa    CHAR(3);
  DEFINE p_Motivo     INTEGER;
  DEFINE p_Ejecutivo  CHAR(20);
  DEFINE p_tran_aplica_cargo CHAR(4);
  DEFINE p_tran_aplica_abono CHAR(4);

  DEFINE resultado_accion_cumple INTEGER;
  DEFINE resultado_accion_no_cumple INTEGER;
  DEFINE resultado_accion_procede INTEGER;
  DEFINE resultado_accion_no_procede INTEGER;

  DEFINE resultado_aplicado INTEGER;
  DEFINE motivo_cancelacion_debito CHAR(2);

  DEFINE cod_resp_cancelacion_debito CHAR(6);
  DEFINE msj_resp_cancelacion_debito CHAR(250);

  DEFINE resultado_asign_usuario INTEGER;
  DEFINE resultado_asign_num_empleado CHAR(9);

  DEFINE resultado_asign_usuario_2 INTEGER;
  DEFINE resultado_asign_num_empleado_2 CHAR(9);

  DEFINE resultado_nume_cliente CHAR(9);
  DEFINE resultado_nombreBeneficiario CHAR(100);
  DEFINE resultado_representante_legal INTEGER;

  DEFINE resultado_cuenta_abonar CHAR(20);

  DEFINE cargo_inversion  INTEGER;
  DEFINE abono_cuenta_eje INTEGER;
  DEFINE contar_cuentas_exito INTEGER;

  -- DEFINICION DE VARIABLES DE RETORNO
  DEFINE codigo_retorno_traspaso            CHAR(6);
  DEFINE mensaje_retorno_traspaso          CHAR(250);

  DEFINE resultado_cuenta_eje     CHAR(20);
  DEFINE cuenta_inv_cancelada     INTEGER;

  DEFINE saldo_congelado MONEY;
  DEFINE existe_saldo_congelado INTEGER;

  DEFINE resultado_pky_usuario INTEGER;

  DEFINE resultado_tipo_lugar_deceso INTEGER;


  LET resultado_pky_resolucion = pky_resolucion;

  LET existe_saldo_congelado = 0;
  LET saldo_congelado = 0;

  -- 0) DEFINICION DE VARIABLES DE RETORNO
  LET codigoRetorno       = '';
  LET mensajeRetorno      = '';
  LET tipoAccion          = '';
  LET cuentaBeneficiario  = '';
  LET cuentaClienteFallecido = '';

  LET codigo_retorno_traspaso   = '';
  LET mensaje_retorno_traspaso  = '';


  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  LET resultado_numero_cliente = '';
  LET resultado_foliocsuac = '';

  -- 2) QUERY DE CONTROL
  LET resultado_pky_control_tramite_cuenta  = 0;
  LET resultado_num_cta_cliente             = '';
  LET resultado_num_cta_beneficiario        = '';
  LET resultado_porcentaje_bene             = 0;
  LET resultado_tramite                     = 0;
  LET resultado_exitoso                     = 0;
  LET resultado_tipo_cancelacion            = 0;
  --LET resultado_fecha_vencimiento           = DATE(1);
  LET resultado_monto_original              = 0;
  LET resultado_monto_inversion                = 0;
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  LET v_numero_documentos_necesarios_beneficiario    = 0;
  LET v_numero_documentos_digitalizados_beneficiario = 0;

  LET v_numero_documentos_necesarios_fallecido    = 0;
  LET v_numero_documentos_digitalizados_fallecido = 0;

  LET resultado_estatus_cuenta_beneficiario = '';
  LET resultado_estatus_cuenta_cliente_fallecido = '';
  LET resultado_estatus_cuenta_eje = '';
  LET resultado_motivo = '';
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  LET monto_pago_bene           = 0;
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  LET resultado_accion = 0;
  LET resultado_num_empleado = '';
  LET resultado_num_suc = '';
  LET resultado_pky_rango_importe = 0;
  LET resultado_rango_inferior = 0;
  -- 10.3) SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  LET num_tarjeta_cliente = '';
  LET num_tarjeta_beneficiario = '';
  -- VALIDACION DE BANDERA DE CARGO
  LET resultado_cargo_bandera = 0;

  -- CONSTANTES
  LET p_Empresa   = '001';
  LET p_Ejecutivo = '001';
  LET p_Motivo    = 5;
  LET p_tran_aplica_cargo = '0409';
  LET p_tran_aplica_abono = '0408';

  LET resultado_accion_cumple = 0;
  LET resultado_accion_no_cumple = 0;
  LET resultado_accion_procede = 0;
  LET resultado_accion_no_procede = 0;
  LET resultado_aplicado = 0;

  LET motivo_cancelacion_debito = '04';

  LET resultado_asign_usuario = 0;
  LET resultado_asign_num_empleado = '';
  LET resultado_asign_usuario_2 = 0;
  LET resultado_asign_num_empleado_2 = '';

  LET resultado_nume_cliente = '';
  LET resultado_nombreBeneficiario = '';

  LET resultado_cuenta_eje = '';
  LET resultado_fky_usuario_analista = 0;
  LET cuenta_inv_cancelada = 0;
  LET mensajeRetornoCancelacion = '';
  LET codigoRetornoCancelacion = '0';

  --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/liquidacionCuentaInversionCorpo_"||p_idSolicitud||"_"||TRIM(p_cta_beneficiario)||"_34.out";
  --TRACE ON;
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  BEGIN

    -- OBTENER EL PKY DEL USUARIO
    SELECT pky_usuario
    INTO resultado_pky_usuario
    FROM acl_usuario WHERE num_empleado = p_usuario;

    IF(resultado_pky_usuario) IS NULL THEN
      LET resultado_pky_usuario = 0;    -- EN CASO DE QUE NO SE ENCUENTRE EL USUARIO EN LA BASE DE DATOS DE ACLARACIONES
    END IF

    -- OBTENCION DE INFORMACION DE LA SOLICITUD
    SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal
    INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista,resultado_num_sucursal
    FROM fal_solicitud
    WHERE pky_solicitud = p_idSolicitud;

    -- OBTENER NOMBRE BENEFICIARIO, BANDERA DE REPRESENTANTE LEGAL
    SELECT nombre_cliente, representante_legal
    INTO resultado_nombreBeneficiario, resultado_representante_legal
    FROM  fal_beneficiario
    WHERE  pky_cuenta_beneficiario = p_cta_beneficiario
    AND pky_cuenta_cliente_fallecido = p_cta_cliente;

    -- OBTENCION DEL REGISTRO DE LA TABLA DE CONTROL (fal_control_tramite_)
    SELECT pky_control_tramite,
          cuenta_cliente_fallecido,
          cuenta_beneficiario,
          monto_porcentaje,
          tramite,
          exitoso,
          fky_tipo_tramite,
          --fecha_vencimiento_pagare,
          monto_original,
          monto_calculado,
          descripcion_detalle,
          cambio_instruccion_pagare as cargo,
          liquida_pagare as abono
    INTO resultado_pky_control_tramite_cuenta,
          resultado_num_cta_cliente,
          resultado_num_cta_beneficiario,
          resultado_porcentaje_bene,
          resultado_tramite,
          resultado_exitoso,
          resultado_tipo_cancelacion,
          --resultado_fecha_vencimiento,
          resultado_monto_original,
          resultado_monto_inversion,
          resultado_descripcion_detalle,
          cargo_inversion,
          abono_cuenta_eje
    FROM fal_control_tramite
    WHERE fky_solicitud = p_idSolicitud
    AND tramite = 1
    AND exitoso = 0
    AND fky_tipo_tramite = 4-- INVERSION
    AND cuenta_cliente_fallecido = p_cta_cliente
    AND cuenta_beneficiario = p_cta_beneficiario;



    -- FLUJO PARA PROCEDENTE
    IF p_procede = 1 THEN -- VALIDACION DE PROCEDE

    --CONSULTAR CUENTA EJE DE LA CUENTA DE INVERSI
    SELECT FIRST 1 cuentadep
    INTO resultado_cuenta_eje
    FROM bdicheq:"informix".sc_maechq qc
    LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )
    WHERE qc.cuenta = p_cta_cliente;

    --CONSULTA DE MONTO CONGEADO Y MONTO ORIGINAL DE LA CUENTA EJE
    SELECT sdo_cong
    INTO saldo_congelado
    FROM bdicheq:"informix".sc_maechq qc
    WHERE qc.cuenta=resultado_cuenta_eje;

    SELECT LIMIT 1 monto_original -
    (SELECT sum(monto_cargo) FROM fal_control_tramite where cuenta_cliente_fallecido=resultado_cuenta_eje) AS monto_original
    INTO saldo_cuenta_eje
    FROM fal_control_tramite where cuenta_cliente_fallecido=resultado_cuenta_eje;



    LET nombreBeneficiario = resultado_nombreBeneficiario;

    -- VALIDACION DE PARAMETROS DE ENTRADA
    IF p_cta_cliente IS NULL THEN
      LET p_cta_cliente = '';
    END IF
    IF p_cta_beneficiario IS NULL THEN
      LET p_cta_beneficiario = '';
    END IF
    IF p_usuario IS NULL THEN
      LET p_usuario = '';
    END IF

    IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usuario) = '' THEN
      LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Informaciï¿½n incompleta.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = '';                             -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = '';
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = '';

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: Parï¿½metros incorrectos.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

    END IF

    IF TRIM(resultado_cuenta_eje) IS NULL OR  TRIM(resultado_cuenta_eje) = ''  THEN
      LET codigoRetorno       = '000003';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Su folio se ha enviado a ï¿½rea interna.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = p_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      -- p_cta_cliente
      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: No se encontrï¿½ la cuenta eje de la inversiï¿½n. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF

    -- NUMERO DE DOCUMENTOS DIGITALIZADOS DEL BENEFICIARIO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_beneficiario
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_num_cta_cliente AND FCDD.cuenta_beneficiario = resultado_num_cta_beneficiario
    AND FCDD.inconsistencia = 0;

    SELECT count(*)
    INTO v_numero_documentos_necesarios_beneficiario
    FROM fal_cat_tipo_beneficiario CTB
    INNER JOIN fal_beneficiario_gpo_doc BGD ON CTB.pky_tipo_beneficiario = BGD.fky_tipo_beneficiario
    INNER JOIN fal_cat_grupo_documento CGD ON BGD.fky_grupo_documento = CGD.pky_grupo_documento
    INNER JOIN fal_grupo_documento GD ON CGD.pky_grupo_documento = GD.fky_grupo_documento
    INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
    INNER JOIN fal_beneficiario B ON CTB.pky_tipo_beneficiario = B.fky_tipo_beneficiario
    AND B.pky_cuenta_cliente_fallecido = resultado_num_cta_cliente AND B.pky_cuenta_beneficiario = resultado_num_cta_beneficiario;


    -- NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE FALLECIDO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_fallecido
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_numero_cliente AND FCDD.cuenta_beneficiario = resultado_numero_cliente
    AND FCDD.inconsistencia = 0;

    -- SE VALIDA EL TIPO DE LUGAR DE FALLECIMIENTO.
    -- SI ES EN EL EXTRANJERO SE Aï¿½ADE UN DOCUMENTO.
    SELECT fky_lugar_deceso
    INTO resultado_tipo_lugar_deceso
    FROM fal_aviso 
    WHERE fky_solicitud = p_idSolicitud;

    IF  resultado_tipo_lugar_deceso = 2 THEN
      -- SE REALIZA LA CONSULTA POR EL DOCUMENTO ADICIONAL DE LA APOSTILLA
      SELECT count(*)
      INTO v_numero_documentos_necesarios_fallecido
      FROM fal_grupo_documento GD
      INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
      WHERE GD.fky_grupo_documento in (1,2,3);
    ELSE
        
      SELECT count(*)
      INTO v_numero_documentos_necesarios_fallecido
      FROM fal_grupo_documento GD
      INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
      WHERE GD.fky_grupo_documento in (1,2);

    END IF



    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL BENEFICIARIO, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL CF, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
    SELECT status_cta
    INTO resultado_estatus_cuenta_beneficiario
    FROM bdicheq:"informix".sc_maechq
    WHERE cuenta = p_cta_beneficiario;

    SELECT status_cta, motivo
    INTO resultado_estatus_cuenta_cliente_fallecido,resultado_motivo
    FROM bdicheq:"informix".sc_maechq
    WHERE cuenta = p_cta_cliente;

    SELECT status_cta, motivo
    INTO resultado_estatus_cuenta_eje,resultado_motivo_eje
    FROM bdicheq:"informix".sc_maechq
    WHERE cuenta = resultado_cuenta_eje;

   --LET resultado_pky_control_tramite_cuenta = null;
   --VALIDACIï¿½N DE PROCESO DE LA CUENTA
   IF resultado_pky_control_tramite_cuenta = 0 OR resultado_pky_control_tramite_cuenta IS NULL THEN -- VALIDACION DE PROCESO DE CUENTA

      LET codigoRetorno       = '000009';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'La cuenta ya se ha procesado.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = p_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
   END IF

    --PRUEBA
    --LET resultado_estatus_cuenta_eje=3;
    --LET resultado_motivo_eje ='04';
    --LET resultado_estatus_cuenta_cliente_fallecido=2;
    --LET resultado_motivo ='02';

    --SI LA CUENTA YA FUE CANCELADA SE PONE LA BANDERA DE CANCELACIï¿½N
    IF (resultado_estatus_cuenta_cliente_fallecido = 2) THEN
        LET cuenta_inv_cancelada = 1;
    END IF

    IF cuenta_inv_cancelada = 0 AND (resultado_estatus_cuenta_cliente_fallecido <> 3 OR resultado_motivo <> '04') THEN

      LET codigoRetorno       = '000002';
      LET mensajeRetorno      = 'Su folio se ha enviado a ï¿½rea interna.';
      LET tipoAccion          = '0';
      LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: El estatus de la cuenta de inversiï¿½n no estï¿½ bloqueada por fallecimiento. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

    END IF

    IF ((resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04') OR (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '00'))   THEN
        --VALIDAR TRASPASO DE CUENTAS DE N A CUENTA EJE
        IF (cargo_inversion IS NULL OR cargo_inversion = 0) AND (abono_cuenta_eje IS NULL OR abono_cuenta_eje = 0) THEN

            --MANDAR LLAMAR EL SP DE TRASPASO DE CUENTAS
            CALL sp_fal_traspaso_cuentas_inversion(p_usuario, p_cta_cliente, p_idSolicitud, saldo_cuenta_eje, resultado_monto_original)
            RETURNING codigo_retorno_traspaso, mensaje_retorno_traspaso;
            --LET codigo_retorno_traspaso = '000000';
            IF codigo_retorno_traspaso!='000000' THEN

                LET codigoRetorno       = codigo_retorno_traspaso;
                LET mensajeRetorno      = mensaje_retorno_traspaso;
                LET tipoAccion          = '0';
                LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n:' || mensaje_retorno_traspaso || ' CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            ELSE


                UPDATE fal_control_tramite SET cambio_instruccion_pagare = 1, liquida_pagare = 1, fecha_cancelacion = today
                WHERE cuenta_cliente_fallecido = p_cta_cliente
                AND fky_tipo_tramite = 4;

                --CONSULTA SALDO CONGELADO EN CASO DE QUE SE HAYA REALIZADO EL TRASPASO
                SELECT sdo_cong
                INTO saldo_congelado
                FROM bdicheq:sc_maechq qc
                WHERE qc.cuenta=resultado_cuenta_eje;

                LET cuenta_inv_cancelada = 1;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidaciï¿½n:' || mensaje_retorno_traspaso || ' CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

            END IF
        END IF

    ELSE --ESTATUS DE CUENTA EJE O CUENTA INVERSIï¿½N NO ACTIVA

                 LET codigoRetorno       = '000002';
                 LET mensajeRetorno      = 'El estatus de la cuenta de inversiï¿½n no estï¿½ bloqueada por fallecimiento.';
                 LET tipoAccion          = '0';
                 LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                 LET cuentaClienteFallecido = resultado_num_cta_cliente;
                 LET codigoRetornoCancelacion = '0';
                 LET mensajeRetornoCancelacion = '';
                 LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: El estatus de la cuenta de inversiï¿½n no estï¿½ bloqueada por fallecimiento. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                 RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF --FIN VALIDAR QUE EL ESTATUS DE LA CUENTA EJE Y LA CUENTA DE INVERSIN ESTEN BLOQUEADAS POR MOTIVO DE FALLECIMIENTO

   --LET resultado_estatus_cuenta_beneficiario = 9;
   --VALIDACIN DE ESTATUS DE LA CUENTA DEL BENEFICIARIO
    IF TRIM(resultado_estatus_cuenta_beneficiario) not in (1,4,5) THEN
      LET codigoRetorno       = '000002';
      LET mensajeRetorno      = 'El estatus de la cuenta del beneficiario no es ACTIVA.';
      LET tipoAccion          = '0';
      LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: El estatus de la cuenta del beneficiario no es ACTIVA. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF

    IF saldo_congelado > 0 THEN
       LET existe_saldo_congelado = 1;
    END IF

    -- SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL CLIENTE FALLECIDO CUENTA CON TODA LA DOCUMENTACION
    IF v_numero_documentos_necesarios_fallecido = v_numero_documentos_digitalizados_fallecido AND v_numero_documentos_digitalizados_fallecido != 0 THEN

            -- SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL BENEFICIARIO CUENTA CON TODA LA DOCUMENTACION
            IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN

              --LET monto_pago_bene = 0;
              LET monto_pago_bene = resultado_monto_inversion;
              LET monto_a_buscar_regla_negocio = monto_pago_bene;
              -- SI POR ALGUNA RAZON EL MONTO ES CERO
              IF monto_pago_bene < 1 THEN
                LET monto_a_buscar_regla_negocio = 1;
              END IF

              -- SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
              SELECT frimp.pky_rango_importe,frimp.rango_inferior
              INTO resultado_pky_rango_importe,resultado_rango_inferior
              FROM fal_solicitud fsol
              INNER JOIN fal_cat_evento ceve ON ceve.pky_evento = fsol.fky_evento AND ceve.fky_origen_evento = fsol.fky_origen_evento
              INNER JOIN fal_regla_negocio frn ON frn.fky_evento = ceve.pky_evento AND frn.fky_origen_evento = ceve.fky_origen_evento
              INNER JOIN fal_rango_importe frimp ON frimp.fky_regla_negocio = frn.pky_regla_negocio
              WHERE frimp.rango_inferior <= monto_a_buscar_regla_negocio AND frimp.rango_mayor >= monto_a_buscar_regla_negocio
              AND fsol.pky_solicitud = p_idSolicitud
              AND frn.activo = 1;

              -- SE OBTIENEN LAS ACCIONES A REALIZAR POR EL RANGO IMPORTE
              SELECT frimpacc.cumple,frimpacc.no_cumple,frimpacc.procede,frimpacc.no_procede
              INTO resultado_accion_cumple, resultado_accion_no_cumple, resultado_accion_procede, resultado_accion_no_procede
              FROM fal_rango_importe_accion frimpacc
              WHERE frimpacc.fky_rango_importe = resultado_pky_rango_importe;

              LET monto_a_buscar_regla_negocio = monto_pago_bene;

                -- SE OBTIENE LA ACCION PARA LA ACCION DE PROCEDE
                SELECT nombre
                INTO resultado_nombre_accion_procede
                FROM fal_cat_accion
                WHERE pky_accion = resultado_accion_procede;

                  --PRUEBA
                  --LET resultado_monto_inversion = 100;
                  IF TRIM(resultado_nombre_accion_procede) = 'APLICACION_MANUAL' OR TRIM(resultado_nombre_accion_procede) = 'APLICACION_AUTOMATICA' THEN -- VALIDACION PARA PROCESO MANUAL DE LA REGLA

                      LET monto_pago_bene = resultado_monto_inversion;

                      --DESBLOQUEAR LAS CUENTAS PARA HACER EL CARGO Y EL ABONO AL BENEFICIARIO

                        IF existe_saldo_congelado = 1 THEN
                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;
                        ELSE
                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;
                        END IF

                       --PRUEBA
                       --LET codret_blqcta = '000';
                       --LET codret_blqcta_eje = '000';
                       --VALIDACIN EN CASO DE QUE NO SE PUEDAN ACTIVAR LAS CUENTAS DEL CLIENTE FALLECIDO (EJE E INVERSIN)
                      IF (TRIM(codret_blqcta_eje) !='000')  THEN

                          LET codigoRetorno       = codret_blqcta_eje;                  -- CODIGO DEFINIDO
                          LET mensajeRetorno      = 'No se pudo activar la cuenta del cliente.';
                          LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                          LET cuentaClienteFallecido = resultado_num_cta_cliente;
                          LET codigoRetornoCancelacion = '0';
                          LET mensajeRetornoCancelacion = '';
                          LET nombreBeneficiario = resultado_nombreBeneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: No se pudo activar la cuenta del cliente. La liquidaciï¿½n de recursos se harï¿½ en Central. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                          RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                      END IF --VALIDAR CODIGOS DE RETORNO

                        --DESPUES DE ACTIVAR LA CUENTA EJE
                        -- SE GENERA EL FOLIO SUC
                        SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
                        INTO p_fecha_folio
                        FROM systables WHERE tabid=1;
                        LET p_FolioSUC = trim(p_fecha_folio) || lpad(resultado_foliocsuac,10,0);

                        --OBTENER NUMERO DE TARJETA DE LA CUENTA EJE
                        LET num_tarjeta_cliente = (
                          --select nvl(st.num_tarjeta, '')
                          select case when st.num_tarjeta is null then ''
                          else st.num_tarjeta
                          end
                          from bdicheq:"informix".sc_tarjeta  st
                          where st.cuenta = resultado_cuenta_eje
                          and secuencia = (
                            select max(secuencia)
                            from bdicheq:sc_tarjeta  st
                            where st.cuenta = resultado_cuenta_eje
                          )
                        );

                        -- VERIFICA SI YA SE HIZO EL CARGO AL CLIENTE -
                        SELECT cargo
                        INTO resultado_cargo_bandera
                        FROM fal_control_tramite
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        -- VALIDAR SI LA CUENTA TIENE REPRESENTANTE LEGAL
                        LET resultado_cuenta_abonar = resultado_num_cta_beneficiario;
                        IF resultado_representante_legal = 1 THEN
                          LET resultado_cuenta_abonar = TRIM(resultado_descripcion_detalle);
                        END IF
                        --PRUEBA
                        --LET resultado_cargo_bandera = 1;
                        IF resultado_cargo_bandera != 1 THEN -- VALIDACION EN 0 DEL CARGO AL CLIENTE
                          -- EL CARGO AL CLIENTE NO SE HA REALIZADO
                          -- SE EJECUTA EL SP DE CARGO DE MONTO AL CLIENTE
                            CALL bdicheq:"informix".cargo_ref(p_Empresa, resultado_num_sucursal, p_usuario , p_tran_aplica_cargo, '0000', p_FolioSUC, resultado_cuenta_eje, 0, monto_pago_bene, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
                            RETURNING codret_cargo_ref, tranret_cargo_ref, fechoy_cargo_ref, sdodisp_cargo_ref, montoret_cargo_ref;

                             --LET codret_cargo_ref = '000';
                             -- VALIDACION DE LA EJECUCION DEL SP DE CARGO
                             IF TRIM(codret_cargo_ref) != '000' THEN

                                UPDATE fal_control_tramite SET cargo = 0
                                WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                                -- CUANDO NO SE REALIZO EL CARGO AL CLIENTE\-- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE
                                IF existe_saldo_congelado = 1 THEN
                                   CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                   RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                   CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje),'0','04',3,today,p_usuario,'','11','S','12','Z')
                                   RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF

                                LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = 'No se pudo realizar el cargo a la cuenta eje.';
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;

                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: No se pudo realizar el cargo a la cuenta eje. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                             END IF

                            -- ACTUALIZA TABLA DE CONTROL
                            UPDATE fal_control_tramite SET cargo_monto = monto_pago_bene, cargo = 1
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        END IF --VALIDACION DE CARGO AL CLIENTE


                        -- VALIDAR SI SE PUDO HACER EL ABONO AL BENEFICIARIO
                        SELECT aplicado
                        INTO resultado_aplicado
                        FROM fal_beneficiario
                        WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta
                        AND tramite_aplicado=1;

                        IF resultado_aplicado != 1 OR resultado_aplicado IS NULL THEN --VALIDACIN ABONO AL BENEFICIARIO

                            -- SI SE REALIZO CORRECTAMENTE EL CARGO AL CLIENTE
                            LET num_tarjeta_beneficiario = (
                              --select nvl(st.num_tarjeta, '')
                              select case when st.num_tarjeta is null then ''
                              else st.num_tarjeta
                              end
                              from bdicheq:"informix".sc_tarjeta  st
                              where st.cuenta = resultado_num_cta_beneficiario
                              and secuencia = (
                                select max(secuencia)
                                from bdicheq:"informix".sc_tarjeta  st
                                where st.cuenta = resultado_num_cta_beneficiario
                              )
                            );

                            --############################################################################################################################################################################################################################################################
                            CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
                            RETURNING vcodret_abono;
                            --############################################################################################################################################################################################################################################################
                            IF vcodret_abono != '000' THEN

                                --BLOQUEAR CUENTAS DEL CLIENTE
                                IF existe_saldo_congelado = 1 THEN
                                      CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                      RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                      CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje),'0','04',3,today,p_usuario,'','11','S','12','Z')
                                      RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF

                                LET codigoRetorno       = vcodret_abono;                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = 'No se realizï¿½ el abono al beneficiario.';
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;

                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: No se pudo abonar a la cuenta del beneficiario. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                            ELSE

                                UPDATE fal_control_tramite SET cargo_monto = monto_pago_bene, cargo = 1, exitoso = 1, monto_cargo = monto_pago_bene, fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3, predictamen = 1, fky_fal_cat_resolucion = pky_resolucion, tramita_analisis = 1
                                WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                                -- ACTUALIZA LA TABLA DE BENEFICIARIOS
                                UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = today, tramite_aplicado = 1
                                WHERE fky_control_tramite = resultado_pky_control_tramite_cuenta;

                                --BLOQUEAR CUENTAS DEL CLIENTE
                                IF existe_saldo_congelado = 1 THEN
                                      CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                      RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                      CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje),'0','04',3,today,p_usuario,'','11','S','12','Z')
                                      RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF

                                LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = 'Liquidaciï¿½n a beneficiario exitosa.';
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;

                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidaciï¿½n a beneficiario exitosa. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                            END IF -- VALIDACIN MARCA UN ERROR EN EL ABONO AL BENEFICIARIO

                        ELSE
                                --BLOQUEAR CUENTAS DEL CLIENTE
                                IF existe_saldo_congelado = 1 THEN
                                      CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                      RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                      CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje),'0','04',3,today,p_usuario,'','11','S','12','Z')
                                      RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF

                                LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = 'Beneficiario ya liquidado.';
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;

                        END IF --VALIDACIN ABONO AL BENEFICIARIO


                        SELECT COUNT(*)
                        INTO contar_cuentas_exito
                        FROM fal_control_tramite
                        WHERE cuenta_cliente_fallecido = resultado_num_cta_cliente
                        AND exitoso = 0;

                        SELECT sdo_cong
                        INTO saldo_cuenta_eje
                        FROM bdicheq:"informix".sc_maechq qc
                        WHERE qc.cuenta=resultado_cuenta_eje;

                        --LET contar_cuentas_exito = 1;
                        --VALIDA SI YA NO HAY CUENTAS DE BENEFICIARIOS POR LIQUIDAR PARA PODER CANCELAR LA CUENTA DE LIQUIDACIN
                        IF contar_cuentas_exito = 0 or contar_cuentas_exito IS NULL AND saldo_cuenta_eje = 0 THEN
                            -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                            CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                            RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                            IF cod_resp_cancelacion_debito = '069' THEN --VALIDACION CANCELACION EJE
                                                                -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                               UPDATE fal_control_tramite SET fecha_cancelacion = today
                               WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                               AND fky_tipo_tramite = 1;

                               -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                               LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                               LET mensajeRetorno      = 'La baja del cliente se realizï¿½ con ï¿½xito. Cuenta inversiï¿½n y eje canceladas.';
                               LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                               LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                               LET cuentaClienteFallecido = resultado_num_cta_cliente;
                               LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                               LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                               LET nombreBeneficiario = resultado_nombreBeneficiario;

                               INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                               VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelaciï¿½n: La cuenta eje se ha cancelado exitosamente.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
                               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                            ELSE--VALIDACION CANCELACION EJE

                                IF existe_saldo_congelado = 1 THEN
                                    CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                    RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                    CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                    RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF


                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelaciï¿½n cuenta eje: Cod:'||cod_resp_cancelacion_debito || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                            END IF--VALIDACION CANCELACION EJE
                        ELSE
                              RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                        END IF--VALIDACION CUENTAS EJE EXITOSAS


                  ELSE

                        LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
                        LET mensajeRetorno      = 'La cuenta se encuentra en proceso interno: ' || resultado_nombre_accion_procede;
                        LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
                        LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                        LET cuentaClienteFallecido = resultado_num_cta_cliente;
                        LET codigoRetornoCancelacion = '0';
                        LET mensajeRetornoCancelacion = '';
                        LET nombreBeneficiario = resultado_nombreBeneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidaciï¿½n: La cuenta se encuentra en proceso interno. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                        RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                  END IF -- VALIDACION PARA PROCESO MANUAL DE LA REGLA

            ELSE --SI NO TIENE LOS DOCUMENTOS COMPLETOS


              -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
              UPDATE fal_control_tramite SET fky_estatus_corporativo = 8 , fky_estatus_sucursal = 4
              where pky_control_tramite = resultado_pky_control_tramite_cuenta;

            -- ACCIONES EN CASO DE NO CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
              LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'La documentaciï¿½n del beneficiario estï¿½ incompleta.';
              LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = '0';
              LET mensajeRetornoCancelacion = '';
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error Liquidaciï¿½n: La documentaciï¿½n del beneficiario estï¿½ incompleta. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

              RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            END IF --VALIDACION DE DOCUMENTACION BENEFICIARIO


    ELSE --SI NO TIENE LOS DOCUMENTOS COMPLETOS CF
      -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
      UPDATE fal_control_tramite SET fky_estatus_corporativo = 8 , fky_estatus_sucursal = 4
      where pky_control_tramite = resultado_pky_control_tramite_cuenta;

    -- ACCIONES EN CASO DE NO CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
      LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'La documentaciï¿½n del cliente fallecido no estï¿½ completa.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidaciï¿½n: La documentaciï¿½n del cliente fallecido no estï¿½ completa. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF --VALIDACION DE DOCUMENTACION

  ELSE -- VALIDACION DE PROCEDE


      -- NO PROCEDE ()
      LET codigoRetorno       = '000018';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Predictamen como no procedente.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidaciï¿½n: Predictamen como no procedente.' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);


      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

  END IF --FIN FLUJO PARA PROCEDENTE

  END

END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_obten_datos_cliente_solicitud(p_sNumeroCliente CHAR(20))

     RETURNING DATE AS fechaNacimiento, DATE AS fechaUltimoMovimiento, 
     CHAR(50) AS estado, CHAR(10) AS cod_postal, CHAR(15) AS numero_exterior,  CHAR(50) AS calle, 
     CHAR(50) AS colonia, CHAR(50) AS municipio, INTEGER AS numeroBeneficiarios ;


    --definicion de variables--     
    DEFINE resultado_fechaNacimiento           DATE;
    DEFINE resultado_fechaUltimoMovimiento     DATE;
    DEFINE resultado_numeroBeneficiarios       INTEGER;
    DEFINE resultado_numeroProducto            CHAR(6);
    DEFINE resultado_nombreProducto            CHAR(60);
    DEFINE resultado_numeroCuenta              CHAR(30);
    DEFINE resultado_numeroTarjeta             CHAR(30);
    DEFINE resultado_fechaUltimoMovPorCuenta   DATE;

    -- CAPTACION
    DEFINE resultado_fechaUltimoMovPorCuentaCaptaHis DATE;
    DEFINE resultado_fechaUltimoMovPorCuentaCaptaDia DATE;
    DEFINE resultado_fechaUltimoMovPorCuentaCredHis  DATE;
    DEFINE resultado_fechaUltimoMovPorCuentaCredDia  DATE;

    DEFINE resultado_fechaUltimoMovCap DATE;
    DEFINE resultado_fechaUltimoMovCred DATE;

    DEFINE resultado_fechaUltimoMovAux         DATE;
    DEFINE cantidadBeneCuenta                  INTEGER;
    DEFINE cantidadBeneSum                     INTEGER;
    DEFINE solicitudPky                        INTEGER;

    --definicion de variables--
    DEFINE resultado_estado                 CHAR(50);
    DEFINE resultado_cod_postal             CHAR(10);
    DEFINE resultado_numero_exterior        CHAR(15);
    DEFINE resultado_calle                  CHAR(50);
    DEFINE resultado_colonia                CHAR(50);
    DEFINE resultado_municipio              CHAR(50);

    DEFINE iSqlErr                             INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_fechaNacimiento ='';
    LET resultado_fechaUltimoMovimiento = '';
    LET resultado_numeroBeneficiarios = 0;

    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';
    LET resultado_fechaultimomovaux = NULL;
    LET resultado_fechaUltimoMovPorCuenta = '';
    LET resultado_fechaUltimoMovAux = date(1);


    LET resultado_estado = '';
    LET resultado_cod_postal = '';
    LET resultado_numero_exterior = '';
    LET resultado_calle = '';
    LET resultado_colonia = '';
    LET resultado_municipio = '';


    LET cantidadBeneCuenta = 0;
    LET cantidadBeneSum    = 0;
    LET solicitudPky       = 0;
 

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN


        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_fechaNacimiento ='';
                LET resultado_fechaUltimoMovimiento = '';
                LET resultado_numeroBeneficiarios = 0;
                RETURN resultado_fechaNacimiento,resultado_fechaUltimoMovimiento, resultado_estado, resultado_cod_postal, resultado_numero_exterior, resultado_calle, resultado_colonia, resultado_municipio, resultado_numeroBeneficiarios;
            END IF;
        END EXCEPTION;



        /*obtenemos el numero de beneficiarios*/
        LET solicitudPky=(select pky_solicitud from fal_solicitud where num_cliente= trim(p_sNumeroCliente));
            select (COUNT(distinct(cuenta_beneficiario)))   FETCH INTO  resultado_numeroBeneficiarios
            from fal_control_tramite where fky_solicitud=solicitudPky and fky_tipo_tramite not in (2,5); 

        -- OBTENER LA FECHA DEL ULTIMO MOVIMIENTO DEL CLIENTE (PRODUCTOS CAPTACION)
        -- MOVDIA
        Select first 1 max(mv.fech_alt)
        INTO resultado_fechaUltimoMovPorCuentaCaptaDia
        FROM bdicheq:"informix".sc_movdia mv
        INNER JOIN bdicheq:"informix".sc_maechq me on mv.cuenta = me.cuenta 
        WHERE me.num_cte = p_sNumeroCliente;

        -- MOVHIS
        Select first 1 max(mv.fech_alt)
        INTO resultado_fechaUltimoMovPorCuentaCaptaHis
        FROM bdicheq:"informix".sc_movdia mv
        INNER JOIN bdicheq:"informix".sc_maechq me on mv.cuenta = me.cuenta 
        WHERE me.num_cte = p_sNumeroCliente;

        -- OBTENER LA FECHA DEL ULTIMO MOVIMIENTO DEL CLIENTE (PRODUCTOS CREDITO)
        -- MOVDIA
        select first 1 max(mv.fecha_mov)
        INTO resultado_fechaUltimoMovPorCuentaCredDia
        FROM bdicred:"informix".sd_movdia mv
        INNER JOIN bdicred:"informix".sd_maecred me ON mv.num_credito = me.num_credito
        WHERE numcte = p_sNumeroCliente;

        -- MOVHIS
        SELECT first 1 max(fecha_mov)
        INTO resultado_fechaUltimoMovPorCuentaCredHis
        FROM bdicred:"informix".sd_movhis mv
        INNER JOIN bdicred:"informix".sd_maecred me ON mv.num_credito = me.num_credito
        WHERE numcte = p_sNumeroCliente;

        -- DEFINIR LA FECHA MAXIMA
        IF resultado_fechaUltimoMovPorCuentaCaptaDia < resultado_fechaUltimoMovPorCuentaCaptaHis OR resultado_fechaUltimoMovPorCuentaCaptaDia IS NULL AND resultado_fechaUltimoMovPorCuentaCaptaHis IS NOT NULL THEN
            LET resultado_fechaUltimoMovCap = resultado_fechaUltimoMovPorCuentaCaptaHis;
        ELSE
            LET resultado_fechaUltimoMovCap = resultado_fechaUltimoMovPorCuentaCaptaDia;
        END IF

        IF resultado_fechaUltimoMovPorCuentaCredDia < resultado_fechaUltimoMovPorCuentaCredHis OR resultado_fechaUltimoMovPorCuentaCredDia IS NULL AND resultado_fechaUltimoMovPorCuentaCredHis IS NOT NULL THEN
            LET resultado_fechaUltimoMovCred = resultado_fechaUltimoMovPorCuentaCredHis;
        ELSE
            LET resultado_fechaUltimoMovCred = resultado_fechaUltimoMovPorCuentaCredDia;
        END IF

        
        LET resultado_fechaUltimoMovAux = resultado_fechaUltimoMovCred;


        --IF resultado_fechaUltimoMovPorCuentaCaptaDia > resultado_fechaUltimoMovPorCuentaCaptaHis OR  resultado_fechaUltimoMovPorCuentaCaptaDia IS NULL THEN 
            --LET resultado_fechaUltimoMovCap = resultado_fechaUltimoMovPorCuentaCaptaDia;
        --END IF

        --IF resultado_fechaUltimoMovPorCuentaCredDia > resultado_fechaUltimoMovPorCuentaCredHis OR resultado_fechaUltimoMovPorCuentaCredDia IS NULL THEN
            
        --END IF


        --IF resultado_fechaUltimoMovCap > resultado_fechaUltimoMovCred OR resultado_fechaUltimoMovCap IS NULL THEN 
            --LET resultado_fechaUltimoMovAux = resultado_fechaUltimoMovCap;
        --ELSE
            --LET resultado_fechaUltimoMovAux = resultado_fechaUltimoMovCred;
        --END IF


        --Obtener el último movimiento por cuenta del cliente fallecido, debito/crédito
        --FOREACH 
          

            --SELECT tra.cuenta_cliente_fallecido 
            --INTO resultado_numeroCuenta
            --FROM fal_control_tramite tra
            --INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud 
            --WHERE sol.num_cliente = p_sNumeroCliente
            --AND tra.fky_tipo_tramite IN (1,4)
            --GROUP BY tra.cuenta_cliente_fallecido

            /**
            SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
            INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
            FROM TABLE( FUNCTION sp_fal_busca_producto_deb_cheq_cliente(p_sNumeroCliente, 0) )
            AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto)**/

                --Consultar cantidad de beneficiarios
                /*SELECT COUNT(*) as cantidadBene
                INTO cantidadBeneCuenta
                FROM bdicheq:sc_beneficiario bene 
                WHERE bene.cuenta  = resultado_numeroCuenta;

                LET cantidadBeneSum = cantidadBeneSum + cantidadBeneCuenta;*/
      

       
                --Consultar ultimo movimiento de la cuenta
                --FOREACH orden_cursor FOR
                    
                    -- SELECT first 1 fech_alt 
                    --SELECT first 1 distinct(fech_alt)
                    --INTO resultado_fechaUltimoMovPorCuentaCaptaHis
                    --FROM bdicheq:"informix".sc_movdia
                    --WHERE cuenta = resultado_numeroCuenta
                    -- UNION ALL 
                    --SELECT fech_alt 
                    --INTO resultado_fechaUltimoMovPorCuentaCaptaDia
                    --FROM bdicheq:"informix".sc_movhis
                    --WHERE cuenta = resultado_numeroCuenta
                    --ORDER BY fech_alt DESC

                    --IF resultado_fechaUltimoMovPorCuenta > resultado_fechaUltimoMovAux OR  resultado_fechaUltimoMovAux IS NULL THEN 
                      --LET resultado_fechaUltimoMovAux = resultado_fechaUltimoMovPorCuenta;
                    --END IF
                --END FOREACH;
        --END FOREACH;


        --FOREACH 

            --SELECT tra.cuenta_cliente_fallecido 
            --INTO resultado_numeroCuenta
            --FROM fal_control_tramite tra
            --INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud 
            --WHERE sol.num_cliente = p_sNumeroCliente
            --AND tra.fky_tipo_tramite = 3
            --GROUP BY tra.cuenta_cliente_fallecido
          
/***
            SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
            INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
            FROM TABLE( FUNCTION sp_fal_busca_pagares_cliente(p_sNumeroCliente) )
            AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto)**/

            --Consultar cantidad de beneficiarios
            /*SELECT COUNT(*)
            INTO cantidadBeneCuenta
            FROM bdinvers:sv_benefic bene 
            WHERE bene.cuenta  = resultado_numeroCuenta;

            LET cantidadBeneSum = cantidadBeneSum + cantidadBeneCuenta;*/

                  --Consultar cantidad de beneficiarios
          
                /*SELECT COUNT(*) as cantidadBene
                INTO cantidadBeneCuenta
                FROM bdicheq:sc_beneficiario bene 
                WHERE bene.cuenta  = resultado_numeroCuenta;

                LET cantidadBeneSum = cantidadBeneSum + cantidadBeneCuenta;*/
       


                --Consultar ultimo movimiento de la cuenta
                --FOREACH orden_cursor FOR
                    
                    --SELECT first 1 fech_alt 
                    --INTO resultado_fechaUltimoMovPorCuenta
                    --FROM bdicheq:"informix".sc_movdia
                    --WHERE cuenta = resultado_numeroCuenta
                    --UNION ALL 
                    --SELECT fech_alt 
                    --FROM bdicheq:"informix".sc_movhis
                    --WHERE cuenta = resultado_numeroCuenta
                    --ORDER BY fech_alt DESC

                    --IF resultado_fechaUltimoMovPorCuenta > resultado_fechaUltimoMovAux OR  resultado_fechaUltimoMovAux IS NULL THEN 
                       --LET resultado_fechaUltimoMovAux = resultado_fechaUltimoMovPorCuenta;
                    --END IF
                --END FOREACH;
        --END FOREACH;


        --FOREACH 

            --SELECT tra.cuenta_cliente_fallecido 
            --INTO resultado_numeroCuenta
            --FROM fal_control_tramite tra
            --INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud 
            --WHERE sol.num_cliente = p_sNumeroCliente
            --AND tra.fky_tipo_tramite = 2
            --GROUP BY tra.cuenta_cliente_fallecido
          /***
            SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
            INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
            FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(p_sNumeroCliente, 0) )
            AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto)**/

                --Consultar ultimo movimiento de la cuenta
                --FOREACH orden_cursor FOR
                    
                    
                    --SELECT first 1 fecha_mov 
                    --INTO resultado_fechaUltimoMovPorCuenta
                    --FROM bdicred:"informix".sd_movdia
                    --WHERE num_credito = resultado_numeroCuenta
                    --UNION ALL 
                    --SELECT fecha_mov 
                    --FROM bdicred:"informix".sd_movhis
                    --WHERE num_credito = resultado_numeroCuenta
                    --ORDER BY fecha_mov DESC

                    --IF resultado_fechaUltimoMovPorCuenta > resultado_fechaUltimoMovAux OR  resultado_fechaUltimoMovAux IS NULL THEN 
                       --LET resultado_fechaUltimoMovAux = resultado_fechaUltimoMovPorCuenta;
                    --END IF
                --END FOREACH;
        --END FOREACH;

        --Consultar Fecha de Nacimiento
        select fecha_nac 
        INTO  resultado_fechaNacimiento 
        from bdinteg:"informix".si_ctepf 
        where numcte  = p_sNumeroCliente;

        LET resultado_fechaUltimoMovimiento = resultado_fechaUltimoMovAux;
       


        SELECT
                 --NVL(Trim(edo.nombre), ' ') as estado, 
                 case when edo.nombre is null then ' ' end as estado,
                 --NVL(sd.cod_postal,' '),
                 case when sd.cod_postal is null then ' ' end as cp,
                 --NVL(numeroextcalle, ' ') as numero_exterior, 
                 case when numeroextcalle is null then ' ' end as numero_exterior,
                 --NVL(Trim(ct.nombrecalle), ' ') as calle,
                 case when ct.nombrecalle is null then ' ' end as calle,
                 --NVL(Trim(sz.nombrezona), ' ') as colonia,  
                 case when sz.nombrezona is null then ' ' end as colonia,
                 --NVL(Trim(sz.municipiozona), ' ') as municipio
                 case when sz.municipiozona is null then ' ' end as municipio
                INTO resultado_estado,resultado_cod_postal,resultado_numero_exterior, resultado_calle,resultado_colonia,resultado_municipio
                FROM bdinteg:"informix".si_cliente sc
                 Left Outer Join bdinteg:"informix".si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:"informix".si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:"informix".si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:"informix".si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
            where sc.NUMCTE = p_sNumeroCliente;

        RETURN resultado_fechaNacimiento,resultado_fechaUltimoMovimiento, resultado_estado, resultado_cod_postal, resultado_numero_exterior, resultado_calle, resultado_colonia, resultado_municipio, resultado_numeroBeneficiarios;


    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_liquidacion_debito_corporativo(p_idSolicitud INTEGER, p_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario char(8), p_procede INTEGER, pky_resolucion INTEGER)
  RETURNING CHAR(6) as codigoRetorno, 
            CHAR(250) as mensajeRetorno, 
            CHAR(1) as tipoAccion, 
            CHAR(20) AS cuentaBeneficiario,
            CHAR(20) as cuentaClienteFallecido,
            CHAR(6) as codigoRetornoCancelacion,
            CHAR(250) as mensajeRetornoCancelacion,
            CHAR(100) as nombreBeneficiario;
  -- 0) DEFINICION VARIABLES DE RETORNO
  DEFINE codigoRetorno        CHAR(6);
  DEFINE mensajeRetorno       CHAR(250);  
  DEFINE tipoAccion           CHAR(1);
  DEFINE cuentaBeneficiario   CHAR(20);
  DEFINE cuentaClienteFallecido CHAR(20);
  DEFINE codigoRetornoCancelacion CHAR(6);
  DEFINE mensajeRetornoCancelacion CHAR(250);
  DEFINE nombreBeneficiario CHAR(100);
  DEFINE iSqlErr          INTEGER;
  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  DEFINE resultado_numero_cliente       CHAR(9);
  DEFINE resultado_foliocsuac           CHAR(12);
  DEFINE resultado_fky_usuario_analista INTEGER;
  DEFINE resultado_num_sucursal CHAR(10);
  -- 2) QUERY DE CONTROL
  DEFINE resultado_pky_control_tramite_cuenta   INTEGER;
  DEFINE resultado_num_cta_cliente              CHAR(20); 
  DEFINE resultado_num_cta_beneficiario         CHAR(20);
  DEFINE resultado_porcentaje_bene              DECIMAL(9,6);
  DEFINE resultado_tramite                      INTEGER;
  DEFINE resultado_exitoso                      INTEGER;
  DEFINE resultado_tipo_cancelacion             INTEGER;
  --DEFINE resultado_fecha_vencimiento            DATE;
  DEFINE resultado_monto_original               MONEY(14,2);
  DEFINE resultado_monto_pagare                 MONEY(14,2);
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE FALLECIDO
  DEFINE v_numero_documentos_digitalizados_fallecido INTEGER;
  DEFINE v_numero_documentos_necesarios_fallecido   INTEGER;

  -- 4) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  DEFINE v_numero_documentos_necesarios_beneficiario     INTEGER;
  DEFINE v_numero_documentos_digitalizados_beneficiario  INTEGER;  

  DEFINE resultado_estatus_cuenta_beneficiario  CHAR(1);
  DEFINE resultado_estatus_cuenta_cliente_fallecido CHAR(1);
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  DEFINE monto_pago_bene            MONEY(14,2);
  DEFINE nuevo_monto_congelado            MONEY(14,2);
  DEFINE monto_congelado            SMALLINT;  
  DEFINE monto_a_buscar_regla_negocio            MONEY(14,2);
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  DEFINE resultado_accion         INTEGER;
  DEFINE resultado_num_empleado   CHAR(8);
  DEFINE resultado_num_suc        CHAR(4);
  DEFINE resultado_pky_rango_importe  INTEGER;
  DEFINE resultado_rango_inferior      MONEY;
  -- bdicheq:"informix".bloqueo_cta
  DEFINE codret_blqcta CHAR(6);
  DEFINE menret_blqcta CHAR(250);
  -- bdicheq:"informix".cargo_red
  DEFINE codret_cargo_ref      CHAR(6);
  DEFINE tranret_cargo_ref     CHAR(4);
  DEFINE fechoy_cargo_ref      DATE;
  DEFINE sdodisp_cargo_ref     MONEY(14,2);
  DEFINE montoret_cargo_ref    MONEY(14,2);  
  -- bdicheq:"informix".abono_ref
  DEFINE vcodret_abono  CHAR(6);
  -- 10.2 SE GENERA EL FOLIO SUC
  DEFINE p_fecha_folio  CHAR(10);
  DEFINE p_FolioSUC     CHAR(16);
  -- 10.3 SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  DEFINE num_tarjeta_cliente      CHAR(20);
  DEFINE num_tarjeta_beneficiario CHAR(20);
  -- VALIDACION DE BANDERA DE CARGO
  DEFINE resultado_cargo_bandera INTEGER;
  -- CONSTANTES
  DEFINE p_Empresa    CHAR(3);
  DEFINE p_Motivo     INTEGER;
  DEFINE p_Ejecutivo  CHAR(20);
  DEFINE p_tran_aplica_cargo CHAR(4);    
  DEFINE p_tran_aplica_abono CHAR(4);    

  DEFINE resultado_accion_cumple INTEGER;
  DEFINE resultado_accion_no_cumple INTEGER;
  DEFINE resultado_accion_procede INTEGER;
  DEFINE resultado_accion_no_procede INTEGER;

  DEFINE resultado_aplicado INTEGER;
  DEFINE motivo_cancelacion_debito CHAR(2);

  DEFINE cod_resp_cancelacion_debito CHAR(6);
  DEFINE msj_resp_cancelacion_debito CHAR(250);

  DEFINE resultado_asign_usuario INTEGER;
  DEFINE resultado_asign_num_empleado CHAR(9);

  DEFINE resultado_asign_usuario_2 INTEGER;
  DEFINE resultado_asign_num_empleado_2 CHAR(9);

  DEFINE resultado_nume_cliente CHAR(9);
  DEFINE resultado_nombreBeneficiario CHAR(100);

  DEFINE resultado_nombre_accion_procede CHAR(20);

  DEFINE resultado_descripcion_estatus_cuenta CHAR(50);

  DEFINE resultado_motivo CHAR(2);

  DEFINE resultado_cuenta_abonar CHAR(20);

  DEFINE resultado_descripcion_detalle          CHAR(100);
  DEFINE resultado_representante_legal INTEGER;
  DEFINE resultado_saldo_congelado MONEY;

  DEFINE resultado_pky_usuario INTEGER;

  DEFINE resultado_conteo_beneficiarios INTEGER;
  DEFINE resultado_conteo_beneficiarios_exitosos INTEGER;
  DEFINE monto_saldo_debito MONEY(16);
  DEFINE resultado_tipo_lugar_deceso INTEGER;
  ---------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------
  -- 0) DEFINICION DE VARIABLES DE RETORNO
  LET codigoRetorno       = '';
  LET mensajeRetorno      = '';  
  LET tipoAccion          = '';
  LET cuentaBeneficiario  = '';
  LET cuentaClienteFallecido = '';
  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  LET resultado_numero_cliente = '';
  LET resultado_foliocsuac = '';

  -- 2) QUERY DE CONTROL
  LET resultado_pky_control_tramite_cuenta  = 0;
  LET resultado_num_cta_cliente             = '';
  LET resultado_num_cta_beneficiario        = '';
  LET resultado_porcentaje_bene             = 0;
  LET resultado_tramite                     = 0;
  LET resultado_exitoso                     = 0;
  LET resultado_tipo_cancelacion            = 0;
  --LET resultado_fecha_vencimiento           = DATE(1);
  LET resultado_monto_original              = 0;
  LET resultado_monto_pagare                = 0;
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  LET v_numero_documentos_necesarios_beneficiario    = 0;
  LET v_numero_documentos_digitalizados_beneficiario = 0;

  LET resultado_estatus_cuenta_beneficiario = '';
  LET resultado_estatus_cuenta_cliente_fallecido = '';
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  LET monto_pago_bene           = 0;
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  LET resultado_accion = 0;
  LET resultado_num_empleado = '';
  LET resultado_num_suc = '';
  LET resultado_pky_rango_importe = 0;
  LET resultado_rango_inferior = 0;
  -- 10.3) SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  LET num_tarjeta_cliente = '';
  LET num_tarjeta_beneficiario = '';
  -- VALIDACION DE BANDERA DE CARGO
  LET resultado_cargo_bandera = 0;
  LET monto_congelado = '0';
  LET nuevo_monto_congelado = '0';
  -- CONSTANTES
  LET p_Empresa   = '001';
  LET p_Ejecutivo = '001';
  LET p_Motivo    = 5;
  LET p_tran_aplica_cargo = '0409';
  LET p_tran_aplica_abono = '0408';

  LET resultado_accion_cumple = 0;
  LET resultado_accion_no_cumple = 0;
  LET resultado_accion_procede = 0;
  LET resultado_accion_no_procede = 0;
  LET resultado_aplicado = 0;

  LET motivo_cancelacion_debito = '04';

  LET resultado_asign_usuario = 0;
  LET resultado_asign_num_empleado = '';
  LET resultado_asign_usuario_2 = 0;
  LET resultado_asign_num_empleado_2 = '';

  LET resultado_nume_cliente = '';
  LET resultado_nombreBeneficiario = '';

  LET codret_blqcta = '';
  LET cod_resp_cancelacion_debito = '';
  LET msj_resp_cancelacion_debito = '';
  LET menret_blqcta = '';


  --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/liquidacionCuentaDebitoCorp_"||p_idSolicitud||"_"||TRIM(p_cta_beneficiario)||"_34.out"; 
  --TRACE ON;
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  BEGIN


    --Instrucciones para el manejo de excepciones
    ON EXCEPTION
        SET iSqlErr
            IF iSqlErr <> 0 THEN

                    LET codigoRetorno       = iSqlErr;                       -- CODIGO DEFINIDO
                    LET mensajeRetorno      = 'Ocurrió un error al intentar liquidar al beneficiario.';      
                    LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                    LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                    LET cuentaClienteFallecido = p_cta_cliente;
                    LET codigoRetornoCancelacion = '';
                    LET mensajeRetornoCancelacion = '';
                    LET nombreBeneficiario = '';

                    RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              END IF;
    END EXCEPTION;


    -- OBTENER EL PKY DEL USUARIO
    SELECT pky_usuario
    INTO resultado_pky_usuario
    FROM acl_usuario WHERE num_empleado = p_usuario;

    IF(resultado_pky_usuario) IS NULL THEN
      LET resultado_pky_usuario = 0;
    END IF

    -- OBTENER NOMBRE BENEFICIARIO, BANDERA DE REPRESENTANTE LEGAL
    SELECT nombre_cliente,representante_legal
    INTO resultado_nombreBeneficiario,resultado_representante_legal
    FROM  fal_beneficiario
    WHERE  pky_cuenta_beneficiario = p_cta_beneficiario
    AND pky_cuenta_cliente_fallecido = p_cta_cliente;

    -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
    SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal
    INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista,resultado_num_sucursal
    FROM fal_solicitud
    WHERE pky_solicitud = p_idSolicitud;

    -- 2) OBTENCION DEL REGISTRO DE LA TABLA DE CONTROL (fal_control_tramite_)
    SELECT pky_control_tramite, 
          cuenta_cliente_fallecido, 
          cuenta_beneficiario, 
          monto_porcentaje, 
          tramite, 
          exitoso, 
          fky_tipo_tramite,
          --fecha_vencimiento_pagare,
          monto_original,
          monto_calculado,
          descripcion_detalle
    INTO resultado_pky_control_tramite_cuenta, 
          resultado_num_cta_cliente, 
          resultado_num_cta_beneficiario, 
          resultado_porcentaje_bene, 
          resultado_tramite, 
          resultado_exitoso, 
          resultado_tipo_cancelacion,
          --resultado_fecha_vencimiento,
          resultado_monto_original,
          resultado_monto_pagare,
          resultado_descripcion_detalle
    FROM fal_control_tramite
    WHERE fky_solicitud = p_idSolicitud
    AND tramite = 1
    AND exitoso = 0
    AND fky_tipo_tramite = 1 -- DEBITO
    AND cuenta_cliente_fallecido = p_cta_cliente
    AND cuenta_beneficiario = p_cta_beneficiario;

    -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL BENEFICIARIO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_beneficiario
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_num_cta_cliente AND FCDD.cuenta_beneficiario = resultado_num_cta_beneficiario
    AND FCDD.inconsistencia = 0;

    SELECT count(*) 
    INTO v_numero_documentos_necesarios_beneficiario
    FROM fal_cat_tipo_beneficiario CTB
    INNER JOIN fal_beneficiario_gpo_doc BGD ON CTB.pky_tipo_beneficiario = BGD.fky_tipo_beneficiario
    INNER JOIN fal_cat_grupo_documento CGD ON BGD.fky_grupo_documento = CGD.pky_grupo_documento
    INNER JOIN fal_grupo_documento GD ON CGD.pky_grupo_documento = GD.fky_grupo_documento
    INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
    INNER JOIN fal_beneficiario B ON CTB.pky_tipo_beneficiario = B.fky_tipo_beneficiario
    AND B.pky_cuenta_cliente_fallecido = resultado_num_cta_cliente AND B.pky_cuenta_beneficiario = resultado_num_cta_beneficiario;

    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL BENEFICIARIO, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL CF, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
    SELECT status_cta 
    INTO resultado_estatus_cuenta_beneficiario
    FROM bdicheq:sc_maechq 
    WHERE cuenta = p_cta_beneficiario;

    -- OBTENER EL ESTATUS DE LA CUENTA
    SELECT descripcion
    INTO resultado_descripcion_estatus_cuenta
    FROM fal_cat_estatus_cuenta
    WHERE pky_estatus_cuenta = resultado_estatus_cuenta_cliente_fallecido;

    SELECT status_cta,motivo,sdo_cong
      INTO resultado_estatus_cuenta_cliente_fallecido,resultado_motivo,resultado_saldo_congelado
      FROM bdicheq:sc_maechq 
      WHERE cuenta = p_cta_cliente;

    --LIMPIAR VARIABLES QUE SE MODIFICAN DESDE APLICATIVO
   -- UPDATE fal_control_tramite SET predictamen = 0, fky_fal_cat_resolucion = NULL
   -- WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

    -- VALIDACION DE PARAMETROS DE ENTRADA
    IF p_cta_cliente IS NULL THEN 
      LET p_cta_cliente = '';
    END IF
    IF p_cta_beneficiario IS NULL THEN
      LET p_cta_beneficiario = '';
    END IF
    IF p_usuario IS NULL THEN
      LET p_usuario = '';
    END IF

    IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usuario) = '' THEN
      LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Error liquidación: Parámetros incorrectos.';      
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = '';                             -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = '';
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;
      
      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: Parámetros incorrectos.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);      
    
      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
        
    END IF
    
    IF TRIM(resultado_estatus_cuenta_beneficiario) not in (1,4,5) THEN
      LET codigoRetorno       = '000007';
      LET mensajeRetorno      = 'El estatus de la cuenta del beneficiario no es VALIDA.';
      LET tipoAccion          = '1';
      LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      -- HISTORICO DE LA SOLICITUD
        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: El estatus de la cuenta del beneficiario no es ACTIVA: ' || resultado_estatus_cuenta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF
    
    
    --VALIDACIÓN DE ESTATUS DEL CLIENTE FALLECIDO
    IF TRIM(resultado_estatus_cuenta_cliente_fallecido) != '3' AND TRIM(resultado_motivo) != '04' THEN
         IF TRIM(resultado_estatus_cuenta_cliente_fallecido) != '3' AND TRIM(resultado_motivo) != '00' THEN

            LET codigoRetorno       = '000007';
            LET mensajeRetorno      = 'El estatus de la cuenta del cliente no esta bloqueada por fallecimiento.';
            LET tipoAccion          = '0';
            LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
            LET cuentaClienteFallecido = resultado_num_cta_cliente;
            LET codigoRetornoCancelacion = '0';
            LET mensajeRetornoCancelacion = '';
            LET nombreBeneficiario = resultado_nombreBeneficiario;

            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: El estatus de la cuenta del cliente no esta bloqueada por fallecimiento.' || resultado_estatus_cuenta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

            RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;        
         END IF
    END IF
          

    LET v_numero_documentos_necesarios_beneficiario = 1;
    LET v_numero_documentos_digitalizados_beneficiario = 1;
    -- 4) SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL BENEFICIARIO CUENTA CON TODA LA DOCUMENTACION
    IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN -- 1 VALIDACION DE DOCUMENTOS
    -- ACCIONES EN CASO DE CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
      -- 5) CONSULTA DEL SALDO DE LA CUENTA DEL CLIENTE

      -- 8) OBTENER EL MONTO PARA EL BENEFICIARIO
      -- LET monto_pago_bene = resultado_monto_pagare;

      SELECT COUNT(*) 
      INTO resultado_conteo_beneficiarios
      FROM fal_control_tramite
      WHERE cuenta_cliente_fallecido = p_cta_cliente;

      -- CALCULO DE TOTAL DE BENEFICIARIOS EXITOSOS

      SELECT COUNT(*)
      INTO resultado_conteo_beneficiarios_exitosos
      FROM fal_control_tramite
      WHERE cuenta_cliente_fallecido = p_cta_cliente
      AND exitoso = 1;

      IF resultado_conteo_beneficiarios - resultado_conteo_beneficiarios_exitosos != 1 THEN
          LET monto_pago_bene = resultado_monto_pagare;
      ELSE
          -- VALIDACION DE ULTIMO BENEFICIARIO
        CALL "informix".sp_fal_obtener_saldo_debito(p_cta_cliente,p_usuario)
        RETURNING monto_saldo_debito;

        LET monto_pago_bene = monto_saldo_debito;

      END IF

      SELECT status_cta,motivo,sdo_cong
      INTO resultado_estatus_cuenta_cliente_fallecido,resultado_motivo,resultado_saldo_congelado
      FROM bdicheq:sc_maechq 
      WHERE cuenta = p_cta_cliente;


      LET monto_a_buscar_regla_negocio = monto_pago_bene;
      -- SI POR ALGUNA RAZON EL MONTO ES CERO
      IF monto_pago_bene < 1 AND monto_pago_bene >= 0 THEN
        LET monto_a_buscar_regla_negocio = 1;
      END IF

      -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
      SELECT frimp.pky_rango_importe,frimp.rango_inferior
      INTO resultado_pky_rango_importe,resultado_rango_inferior
      FROM fal_solicitud fsol
      INNER JOIN fal_cat_evento ceve ON ceve.pky_evento = fsol.fky_evento AND ceve.fky_origen_evento = fsol.fky_origen_evento      
      INNER JOIN fal_regla_negocio frn ON frn.fky_evento = ceve.pky_evento AND frn.fky_origen_evento = ceve.fky_origen_evento
      INNER JOIN fal_rango_importe frimp ON frimp.fky_regla_negocio = frn.pky_regla_negocio
      WHERE frimp.rango_inferior <= monto_a_buscar_regla_negocio AND frimp.rango_mayor >= monto_a_buscar_regla_negocio
      AND fsol.pky_solicitud = p_idSolicitud      
      AND frn.activo = 1;
      
      -- SE OBTIENEN LAS ACCIONES A REALIZAR POR EL RANGO IMPORTE
      SELECT frimpacc.cumple,frimpacc.no_cumple,frimpacc.procede,frimpacc.no_procede
      INTO resultado_accion_cumple, resultado_accion_no_cumple, resultado_accion_procede, resultado_accion_no_procede
      FROM fal_rango_importe_accion frimpacc
      WHERE frimpacc.fky_rango_importe = resultado_pky_rango_importe;

      LET monto_a_buscar_regla_negocio = monto_pago_bene;

      -- FLUJO PARA PROCEDENTE
      IF p_procede = 1 THEN -- VALIDACION DE PROCEDE

        -- SE OBTIENE LA ACCION PARA LA ACCION DE PROCEDE
        SELECT nombre 
        INTO resultado_nombre_accion_procede
        FROM fal_cat_accion
        WHERE pky_accion = resultado_accion_procede;

        IF TRIM(resultado_nombre_accion_procede) = 'APLICACION_MANUAL' OR TRIM(resultado_nombre_accion_procede) = 'APLICACION_AUTOMATICA' THEN -- VALIDACION PARA PROCESO MANUAL DE LA REGLA
          -- SE REALIZA LA LIQUIDACION AL BENEFICIARIO
          -- SE REALIZA LA VALIDACION DE TENER EL BLOQUEO DE CUENTA POR FALLECIMIENTO
          SELECT count(*)
          INTO v_numero_documentos_digitalizados_fallecido
          FROM fal_control_digitaliza_doc FCDD
          WHERE FCDD.cuenta_cliente_fallecido = resultado_numero_cliente AND FCDD.cuenta_beneficiario = resultado_numero_cliente
          AND FCDD.inconsistencia = 0;

          -- SE VALIDA EL TIPO DE LUGAR DE FALLECIMIENTO.
          -- SI ES EN EL EXTRANJERO SE AÑADE UN DOCUMENTO.
          SELECT fky_lugar_deceso
          INTO resultado_tipo_lugar_deceso
          FROM fal_aviso 
          WHERE fky_solicitud = p_idSolicitud;

          IF  resultado_tipo_lugar_deceso = 2 THEN
          -- SE REALIZA LA CONSULTA POR EL DOCUMENTO ADICIONAL DE LA APOSTILLA
            SELECT count(*)
            INTO v_numero_documentos_necesarios_fallecido
            FROM fal_grupo_documento GD
            INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
            WHERE GD.fky_grupo_documento in (1,2,3);
          ELSE
        
            SELECT count(*)
            INTO v_numero_documentos_necesarios_fallecido
            FROM fal_grupo_documento GD
            INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
            WHERE GD.fky_grupo_documento in (1,2);

          END IF

          IF v_numero_documentos_digitalizados_fallecido < v_numero_documentos_necesarios_fallecido AND v_numero_documentos_digitalizados_fallecido != 0 THEN

            LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
            LET mensajeRetorno      = 'Error liquidación: La documentación del cliente fallecido no está completa.';      
            LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
            LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
            LET cuentaClienteFallecido = resultado_num_cta_cliente;
            LET codigoRetornoCancelacion = '0';
            LET mensajeRetornoCancelacion = '';
            LET nombreBeneficiario = resultado_nombreBeneficiario;
      
            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: La documentación del cliente fallecido no está completa.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

            RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

          END IF


          IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN -- VALIDACION DE DOCUMENTACION COMPLETA
                      
            -- LET monto_pago_bene = resultado_monto_pagare;
            
            IF monto_pago_bene = 0 THEN -- EL SALDO A LIQUIDAR ES 0

              UPDATE fal_control_tramite SET exitoso=1, monto_cargo = monto_pago_bene, fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3, predictamen = 1, fky_fal_cat_resolucion = pky_resolucion, tramita_analisis = 1
              WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

              -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
              CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_num_cta_cliente),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
              RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

              UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = sysdate, tramite_aplicado = 1
              WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

              IF cod_resp_cancelacion_debito = '069' THEN -- CANCELACION EXITOSA DE LA CUENTA
                -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                WHERE cuenta_cliente_fallecido = p_cta_cliente;

                update fal_control_tramite SET fky_estatus_corporativo = 7, fky_estatus_sucursal=3
                where cuenta_cliente_fallecido = p_cta_cliente
                AND fky_estatus_corporativo=2
                AND fky_estatus_sucursal=2;

                -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente, la cuenta del cliente fallecido se ha cancelado.';      
                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente, la cuenta del cliente fallecido se ha cancelado. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              ELSE -- CANCELACION EXITOSA DE LA CUENTA
                -- NO SE REALIZA LA CANCELACION DE LA CUENTA
                -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
                RETURNING codret_blqcta,menret_blqcta;

                LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente. No se cancela la cuenta';      
                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              END IF -- CANCELACION EXITOSA DE LA CUENTA

            END IF -- EL SALDO A LIQUIDAR ES 0

            IF resultado_estatus_cuenta_cliente_fallecido = 3 AND resultado_motivo = '00' AND resultado_saldo_congelado != 0 THEN -- EN CASO DE TENER MONTO BLOQUEADO

              CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(p_cta_cliente), resultado_saldo_congelado, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )              
              RETURNING codret_blqcta,menret_blqcta;

              IF trim(codret_blqcta) != '000' THEN -- VALIDACION DE DESBLOQUEO POR MONTO SATISFACTORIO

                -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(p_cta_cliente), resultado_saldo_congelado, '04', 3, today, p_usuario, '', '07', 'A', '12', 'Z')
                RETURNING codret_blqcta,menret_blqcta;

                LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'Corporativo Error liquidación: No se ha desbloqueado por monto';      
                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = '';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo Error liquidación: No se ha desbloqueado por monto.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              END IF -- VALIDACION DE DESBLOQUEO POR MONTO SATISFACTORIO

            END IF -- EN CASO DE TENER MONTO BLOQUEADO

            IF resultado_estatus_cuenta_cliente_fallecido = 3 AND resultado_motivo = '04' THEN -- VALIDACION DE CUENTA BLOQUEADA POR FALLECIMIENTO

                    /****
                       -- TIENE SALDO CONGELADO ?? Y ESTA EN ESTATUS DE BLOQUEO POR FALLECIMIENTO ??
                     ***/  

                   IF resultado_saldo_congelado != 0 THEN --DESBLOQUEO POR MONTO

                       LET monto_congelado = '1'; -- BANDERA DE DESBLOQUEO POR MONTO, SIRVE PARA POSTERIORMENTE BLOQUEAR POR MONTO EN CASO DE TENER RESTANTE SALDO A CONGELAR

                       CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(p_cta_cliente), resultado_saldo_congelado, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )              
                       RETURNING codret_blqcta,menret_blqcta;


                           IF trim(codret_blqcta) != '000' THEN -- VALIDACION DE DESBLOQUEO POR MONTO NO SATISFACTORIO

                               -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                               CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(p_cta_cliente), resultado_saldo_congelado, '04', 3, today, p_usuario, '', '07', 'A', '12', 'Z')
                               RETURNING codret_blqcta,menret_blqcta;

                               LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO
                               LET mensajeRetorno      = 'Corporativo Error liquidación: No se ha desbloqueado por monto';      
                               LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                               LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                               LET cuentaClienteFallecido = resultado_num_cta_cliente;
                               LET codigoRetornoCancelacion = '';
                               LET mensajeRetornoCancelacion = '';
                               LET nombreBeneficiario = resultado_nombreBeneficiario;

                               INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                               VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo Error liquidación: No se ha desbloqueado por monto.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                         END IF -- VALIDACION DE DESBLOQUEO POR MONTO NO SATISFACTORIO
                   ELSE    --DESBLOQUEO NORMAL 


                   --######################################################################################################################################
                     CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_num_cta_cliente,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
                     RETURNING codret_blqcta,menret_blqcta;
                   --######################################################################################################################################              


                   END IF
                

              IF TRIM(codret_blqcta) != '000' THEN  -- VALIDACION DE DESBLOQUEO DE CUENTA 
                LET codigoRetorno       = codret_blqcta;
                LET mensajeRetorno      = 'Error liquidación: No se pudo activar la cuenta del cliente fallecido.';
                LET tipoAccion          = '2';
                LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                LET cuentaClienteFallecido = resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo activar la cuenta del cliente fallecido.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

                -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
                RETURNING codret_blqcta,menret_blqcta;

                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              END IF -- VALIDACION DE DESBLOQUEO DE CUENTA 
            END IF

            -- 10.2 SE GENERA EL FOLIO SUC
            SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
            INTO p_fecha_folio
            FROM systables WHERE tabid=1;

            LET p_FolioSUC = trim(p_fecha_folio) || lpad(resultado_foliocsuac,10,0);

            -- 10.3 SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
            LET num_tarjeta_cliente = (
              --select nvl(st.num_tarjeta, '')
              select case when st.num_tarjeta is null then ''
              else st.num_tarjeta
              end
              from bdicheq:sc_tarjeta  st
              where st.cuenta = resultado_num_cta_cliente
              and secuencia = (
                select max(secuencia)
                from bdicheq:sc_tarjeta  st
                where st.cuenta = resultado_num_cta_cliente
              )
            );

            -- VERIFICA SI YA SE HIZO EL CARGO AL CLIENTE - 
            SELECT cargo
            INTO resultado_cargo_bandera
            FROM fal_control_tramite
            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta; 
            -- VALIDAR SI LA CUENTA TIENE REPRESENTANTE LEGAL
            LET resultado_cuenta_abonar = resultado_num_cta_beneficiario;
            IF resultado_representante_legal = 1 THEN
              LET resultado_cuenta_abonar = TRIM(resultado_descripcion_detalle);
            END IF

            IF resultado_cargo_bandera != 1 THEN -- VALIDACION EN 0 DEL CARGO AL CLIENTE
              -- EL CARGO AL CLIENTE NO SE HA REALIZADO
              -- 10.4 SE EJECUTA EL SP DE CARGO DE MONTO AL CLIENTE
              -- PRUEBA DE FLUJO

              --######### CAGO A LA CUENTA LUIS
              --#######################################################################################################################################################################################################################3
              CALL bdicheq:"informix".cargo_ref(p_Empresa, resultado_num_sucursal, p_usuario , p_tran_aplica_cargo, '0000', p_FolioSUC, resultado_num_cta_cliente, 0, monto_pago_bene, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
              RETURNING codret_cargo_ref, tranret_cargo_ref, fechoy_cargo_ref, sdodisp_cargo_ref, montoret_cargo_ref;
              --#######################################################################################################################################################################################################################3
              -- ASIGANCION POR PRUEBA DE FLUJO
              --LET codret_cargo_ref = '001';

              IF codret_cargo_ref = '000' THEN -- 10.5 VALIDACION DE LA EJECUCION DEL SP DE CARGO
                -- ACTUALIZA TABLA DE CONTROL
                UPDATE fal_control_tramite SET cargo_monto = monto_pago_bene, cargo = 1
                WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
                -- SI SE REALIZO CORRECTAMENTE EL CARGO AL CLIENTE
                LET num_tarjeta_beneficiario = (
                  --select nvl(st.num_tarjeta, '')
                  select case when st.num_tarjeta is null then ''
                  else st.num_tarjeta
                  end
                  from bdicheq:sc_tarjeta  st
                  where st.cuenta = resultado_num_cta_beneficiario
                  and secuencia = (
                    select max(secuencia)
                    from bdicheq:sc_tarjeta  st
                    where st.cuenta = resultado_num_cta_beneficiario
                  )
                );
                -- SE REALIZA EL ABONO AL BENEFICIARIO 
                -- PRUEBA DE FLUJO
                --############################################################################################################################################################################################################################################################
                CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
                --CALL bdicheq:"informix".abono_ref(dEmpresa, '9250', user, dtranaplicaabono, '0000', dFolioSuacSUC, '00000000', 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
                RETURNING vcodret_abono;
                --############################################################################################################################################################################################################################################################
                -- ASIGANCION POR PRUEBA DE FLUJO
                -- LET vcodret_abono = '001';
                IF vcodret_abono = '000' THEN -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

                  -- ACTUALIZA LA TABLA DE BENEFICIARIOS
                  UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = sysdate, tramite_aplicado = 1
                  WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

                  --ACTUALIZA CONTROL TRAMITE
                  UPDATE fal_control_tramite SET exitoso=1, monto_cargo = monto_pago_bene, fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3, predictamen = 1, fky_fal_cat_resolucion = pky_resolucion, tramita_analisis = 1
                  WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;
           
                  -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                  
                    IF monto_congelado = '1' THEN -- HUBO DESBLOQUE POR MONTO ?
                            LET nuevo_monto_congelado = (resultado_saldo_congelado - monto_pago_bene); -- VALIDAMOS EL NUEVO SALDO CONGELADO DEBIDO A LA AFECTACION QUE HUBO EN LA CUENTA
                            IF nuevo_monto_congelado !=0 AND nuevo_monto_congelado > 0  THEN -- AUN RESTA SALDO CONGELADO??
                                --BLOQUEO POR MONTO
                                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' ) -- BLOQUEO POR MONTO (NUEVO SALDO CONGELADO)             
                                RETURNING codret_blqcta,menret_blqcta;
                            ELSE
                                --BLOQUEO NORMAL
                                CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
                                RETURNING codret_blqcta,menret_blqcta;
                            END IF
                    END IF
                  -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_num_cta_cliente),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                  IF cod_resp_cancelacion_debito = '069' THEN 

                    -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                    update fal_control_tramite SET fecha_cancelacion = sysdate
                    where cuenta_cliente_fallecido = p_cta_cliente;

                    update fal_control_tramite SET fky_estatus_corporativo = 7, fky_estatus_sucursal=3
                    where cuenta_cliente_fallecido = p_cta_cliente
                    AND fky_estatus_corporativo=2
                    AND fky_estatus_sucursal=2;


                    -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                    LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                    LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito.';      
                    LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                    LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                    LET cuentaClienteFallecido = resultado_num_cta_cliente;
                    LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                    LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                    LET nombreBeneficiario = resultado_nombreBeneficiario;

                    INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                    VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente, la cuenta del cliente fallecido se ha cancelado. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
                    RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                  ELSE

                    -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                    CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
                    RETURNING codret_blqcta,menret_blqcta;

                    
                    LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                    LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.';      
                    LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                    LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                    LET cuentaClienteFallecido = resultado_num_cta_cliente;
                    LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                    LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                    LET nombreBeneficiario = resultado_nombreBeneficiario;

                    INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                    VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || ' Respuesta: ' || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
                    RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                  END IF

                ELSE -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

                  -- SI NO SE PUDO REALIZAR             
                  LET mensajeRetorno      = 'No se pudo abonar a la cuenta del beneficiario.';                    
                  LET tipoAccion          = '2';
                  LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                  LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  -- SE REALIZA EL ABONO AL CLIENTE POR AL CARGO QUE NO PUEDO PASAR AL BENEFICIARIO
                  --CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_num_cta_cliente, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
                  --RETURNING vcodret_abono;
                  --LET codigoRetorno = vcodret_abono;
            
                  CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                  RETURNING codret_blqcta,menret_blqcta;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo abonar a la cuenta del beneficiario. Cod: ' || vcodret_abono || '/' || codret_blqcta || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          

                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                END IF -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

              ELSE -- 10.5 VALIDACION DE LA EJECUCION DEL SP DE CARGO

                UPDATE fal_control_tramite SET cargo = 0
                WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                -- CUANDO NO SE REALIZO EL CARGO AL CLIENTE\-- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                IF resultado_saldo_congelado > 0 THEN
                     -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                     CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_num_cta_cliente), resultado_saldo_congelado, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                     RETURNING codret_blqcta,menret_blqcta;
                ELSE
                     -- CUANDO NO SE REALIZO EL CARGO AL CLIENTE\-- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE 
                     CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )              
                     RETURNING codret_blqcta,menret_blqcta;
                END IF



                LET codigoRetorno       = codret_cargo_ref;                       -- CODIGO DEFINIDO
                LET mensajeRetorno      = 'No se pudo realizar el cargo al cliente.';      
                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                LET codigoRetornoCancelacion = '0';
                LET mensajeRetornoCancelacion = '';
                LET nombreBeneficiario = resultado_nombreBeneficiario;

                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo realizar el cargo al cliente. Cod: ' || codigoRetorno || '/' || codret_blqcta || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          
      
                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              END IF -- 10.5 VALIDACION DE LA EJECUCION DEL SP DE CARGO


            ELSE -- VALIDACION EN 0 DEL CARGO AL CLIENTE

              -- VALIDAR SI SE PUDO HACER EL ABONO AL BENEFICIARIO
              SELECT aplicado
              INTO resultado_aplicado
              FROM fal_beneficiario 
              WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta
              AND tramite_aplicado=1;

              IF resultado_aplicado != 1 OR resultado_aplicado IS NULL THEN

                -- EL CARGO YA SE HIZO AL CLIENTE SE PROCEDE A ABONAR AL BENEFICIARIO
                CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)          
                --CALL bdicheq:"informix".abono_ref(dEmpresa, '9250', user, dtranaplicaabono, '0000', dFolioSuacSUC, '00000000', 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
                RETURNING vcodret_abono;
                --LET vcodret_abono = '0022';
                -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO

                IF vcodret_abono != '000' THEN          
                  -- SI NO SE PUDO REALIZAR             
                  LET mensajeRetorno      = 'No se pudo abonar a la cuenta del beneficiario.';                    
                  LET tipoAccion          = '2';
                  LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                  LET codigoRetorno   = vcodret_abono;
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO            
                  CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                  RETURNING codret_blqcta,menret_blqcta;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: No se pudo abonar a la cuenta del beneficiario. Cod: ' || vcodret_abono || '/' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          
      
                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            
                ELSE                             

                  -- ACTUALIZA LA TABLA DE BENEFICIARIOS
                  UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = sysdate, tramite_aplicado = 1
                  WHERE  fky_control_tramite = resultado_pky_control_tramite_cuenta;

                  UPDATE fal_control_tramite SET exitoso=1, monto_cargo = monto_pago_bene, fky_estatus_corporativo = 7 , fky_estatus_sucursal = 3, predictamen = 1, fky_fal_cat_resolucion = pky_resolucion, tramita_analisis = 1
                  WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                  -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO
                  CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                  RETURNING codret_blqcta,menret_blqcta;              

                  -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_num_cta_cliente),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                  LET codigoRetorno       = '000017';                       -- CODIGO DEFINIDO
                  LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.';      
                  LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                  LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                  LET nombreBeneficiario = resultado_nombreBeneficiario;


                  IF cod_resp_cancelacion_debito != '069' THEN
                        LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.';

                        
                        -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO            
                        CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                        RETURNING codret_blqcta,menret_blqcta;
                            
                  ELSE
                    -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                    UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                    WHERE cuenta_cliente_fallecido = p_cta_cliente;

                    update fal_control_tramite SET fky_estatus_corporativo = 7, fky_estatus_sucursal=3
                    where cuenta_cliente_fallecido = p_cta_cliente
                    AND fky_estatus_corporativo=2
                    AND fky_estatus_sucursal=2;


                  END IF

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || '/' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          
      
                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                

                END IF
              ELSE --SI YA SE HIZO EL CARGO Y EL ABONO

                  -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO
                  CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                  RETURNING codret_blqcta,menret_blqcta;              

                  -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_num_cta_cliente),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                  LET codigoRetorno       = cod_resp_cancelacion_debito;                       -- CODIGO DEFINIDO
                  LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.';      
                  LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                  LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                  LET nombreBeneficiario = resultado_nombreBeneficiario;


                  IF cod_resp_cancelacion_debito != '069' THEN
                        LET mensajeRetorno      = 'Liquidación: La cuenta se ha procesado correctamente.' || msj_resp_cancelacion_debito;

                        
                        -- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE FALLECIDO            
                        CALL bdicheq:"informix".bloqueo_cta('001',TRIM(resultado_num_cta_cliente), '0', '04', 3, today, p_usuario, '', '11', 'S', '12', 'Z' )
                        RETURNING codret_blqcta,menret_blqcta;
                            
                  ELSE

                    -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                    UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                    WHERE cuenta_cliente_fallecido = p_cta_cliente;

                    update fal_control_tramite SET fky_estatus_corporativo = 7, fky_estatus_sucursal=3
                    where cuenta_cliente_fallecido = p_cta_cliente
                    AND fky_estatus_corporativo=2
                    AND fky_estatus_sucursal=2;

                  END IF

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Liquidación: La cuenta se ha procesado correctamente. Cod: ' || cod_resp_cancelacion_debito || '/' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);          

                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

              END IF -- AQUI TERMINA VALIDACION DE ABONO

            END IF -- VALIDACION EN 0 DEL CARGO AL CLIENTE

          ELSE -- VALIDACION DE DOCUMENTACION COMPLETA

            LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO
            LET mensajeRetorno      = ' La documentación del beneficiario está incompleta.';      
            LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
            LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
            LET cuentaClienteFallecido = resultado_num_cta_cliente;
            LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
            LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
            LET nombreBeneficiario = resultado_nombreBeneficiario;

            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: La documentación del beneficiario está incompleta. Cod: ' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
            RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
          
          END IF -- VALIDACION DE DOCUMENTACION COMPLETA

        ELSE

          LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
          LET mensajeRetorno      = 'La cuenta se encuentra en proceso interno.';      
          LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
          LET cuentaClienteFallecido = resultado_num_cta_cliente;
          LET codigoRetornoCancelacion = '0';
          LET mensajeRetornoCancelacion = '';
          LET nombreBeneficiario = resultado_nombreBeneficiario;

          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: La cuenta se encuentra en proceso interno. ',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
          RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
        
        END IF -- VALIDACION PARA PROCESO MANUAL DE LA REGLA

      ELSE -- VALIDACION DE PROCEDE

        -- SE ESTABLECE EL ESTATUS: 
        UPDATE fal_control_tramite SET fky_estatus_corporativo = 9 , fky_estatus_sucursal = 5, predictamen = 0, fky_fal_cat_resolucion = pky_resolucion, tramite = 1
        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta; 

        -- NO PROCEDE ()
        LET codigoRetorno       = '000018';                       -- CODIGO DEFINIDO
        LET mensajeRetorno      = 'NO PROCEDENTE.';      
        LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
        LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
        LET cuentaClienteFallecido = resultado_num_cta_cliente;
        LET codigoRetornoCancelacion = '0';
        LET mensajeRetornoCancelacion = '';
        LET nombreBeneficiario = resultado_nombreBeneficiario;

        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: Se asignó un predictamen no procedente.',current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
        RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
      
      END IF -- VALIDACION DE PROCEDE

    ELSE

      LET codigoRetorno       = codret_blqcta;                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Error liquidación: La documentación del beneficiario está incompleta.';      
      LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
      LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Corporativo - Error liquidación: La documentación del beneficiario está incompleta. Cod: ' || codret_blqcta || '/' || codigoRetorno || ' Respuesta: ' || menret_blqcta,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);
      
      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

    END IF -- 1 VALIDACION DE DOCUMENTOS
  END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_liquidacion_cuenta_inversion(p_idSolicitud INTEGER, p_cta_cliente CHAR(20), p_cta_beneficiario CHAR(20), p_usuario char(8))

  RETURNING CHAR(6) as codigoRetorno,
            CHAR(250) as mensajeRetorno,
            CHAR(1) as tipoAccion,
            CHAR(20) AS cuentaBeneficiario,
            CHAR(20) as cuentaClienteFallecido,
            CHAR(6) as codigoRetornoCancelacion,
            CHAR(250) as mensajeRetornoCancelacion,
            CHAR(100) as nombreBeneficiario;


  -- 0) DEFINICION VARIABLES DE RETORNO
  DEFINE codigoRetorno        CHAR(6);
  DEFINE mensajeRetorno       CHAR(250);
  DEFINE tipoAccion           CHAR(1);
  DEFINE cuentaBeneficiario   CHAR(20);
  DEFINE cuentaClienteFallecido CHAR(20);
  DEFINE codigoRetornoCancelacion CHAR(6);
  DEFINE mensajeRetornoCancelacion CHAR(250);
  DEFINE nombreBeneficiario CHAR(100);

  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  DEFINE resultado_numero_cliente       CHAR(9);
  DEFINE resultado_foliocsuac           CHAR(12);
  DEFINE resultado_fky_usuario_analista INTEGER;
  DEFINE resultado_num_sucursal CHAR(10);

  -- 2) QUERY DE CONTROL
  DEFINE resultado_pky_control_tramite_cuenta   INTEGER;
  DEFINE resultado_num_cta_cliente              CHAR(20);
  DEFINE resultado_num_cta_beneficiario         CHAR(20);
  DEFINE resultado_porcentaje_bene              DECIMAL(9,6);
  DEFINE resultado_tramite                      INTEGER;
  DEFINE resultado_exitoso                      INTEGER;
  DEFINE resultado_tipo_cancelacion             INTEGER;
  --DEFINE resultado_fecha_vencimiento            DATE;
  DEFINE resultado_monto_original               MONEY(14,2);
  DEFINE resultado_monto_cargo					MONEY(14,2);
  DEFINE resultado_monto_inversion                 MONEY(14,2);
  DEFINE resultado_descripcion_detalle          CHAR(100);
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  DEFINE v_numero_documentos_necesarios_beneficiario     INTEGER;
  DEFINE v_numero_documentos_digitalizados_beneficiario  INTEGER;

  DEFINE v_numero_documentos_necesarios_fallecido     INTEGER;
  DEFINE v_numero_documentos_digitalizados_fallecido  INTEGER;

  DEFINE resultado_estatus_cuenta_beneficiario  CHAR(1);
  DEFINE resultado_estatus_cuenta_cliente_fallecido CHAR(1);
  DEFINE resultado_estatus_cuenta_eje CHAR(1);
  DEFINE resultado_motivo CHAR(2);
  DEFINE resultado_motivo_eje CHAR(2);
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  DEFINE monto_pago_bene            MONEY(14,2);
  DEFINE saldo_cuenta_eje           MONEY(14,2);
  DEFINE saldo_actual           MONEY(14,2);
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  DEFINE resultado_accion         INTEGER;
  DEFINE resultado_num_empleado   CHAR(8);
  DEFINE resultado_num_suc        CHAR(4);
  DEFINE resultado_pky_rango_importe  INTEGER;
  DEFINE resultado_rango_inferior      MONEY;
  -- bdicheq:"informix".bloqueo_cta
  DEFINE codret_blqcta CHAR(6);
  DEFINE menret_blqcta CHAR(250);

  DEFINE codret_blqcta_eje CHAR(6);
  DEFINE menret_blqcta_eje CHAR(250);

  -- bdicheq:"informix".cargo_red
  DEFINE codret_cargo_ref      CHAR(6);
  DEFINE tranret_cargo_ref     CHAR(4);
  DEFINE fechoy_cargo_ref      DATE;
  DEFINE sdodisp_cargo_ref     MONEY(14,2);
  DEFINE montoret_cargo_ref    MONEY(14,2);
  -- bdicheq:"informix".abono_ref
  DEFINE vcodret_abono  CHAR(6);
  -- 10.2 SE GENERA EL FOLIO SUC
  DEFINE p_fecha_folio  CHAR(10);
  DEFINE p_FolioSUC     CHAR(16);
  -- 10.3 SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  DEFINE num_tarjeta_cliente      CHAR(20);
  DEFINE num_tarjeta_beneficiario CHAR(20);
  -- VALIDACION DE BANDERA DE CARGO
  DEFINE resultado_cargo_bandera INTEGER;
  -- VALIDACION DE BANDERA DE ABONO
  DEFINE resultado_abono_bandera INTEGER;
  -- CONSTANTES
  DEFINE p_Empresa    CHAR(3);
  DEFINE p_Motivo     INTEGER;
  DEFINE p_Ejecutivo  CHAR(20);
  DEFINE p_tran_aplica_cargo CHAR(4);
  DEFINE p_tran_aplica_abono CHAR(4);

  DEFINE resultado_accion_cumple INTEGER;
  DEFINE resultado_accion_no_cumple INTEGER;
  DEFINE resultado_accion_procede INTEGER;
  DEFINE resultado_accion_no_procede INTEGER;

  DEFINE resultado_aplicado INTEGER;
  DEFINE motivo_cancelacion_debito CHAR(2);

  DEFINE cod_resp_cancelacion_debito CHAR(6);
  DEFINE msj_resp_cancelacion_debito CHAR(250);

  DEFINE resultado_asign_usuario INTEGER;
  DEFINE resultado_asign_num_empleado CHAR(9);

  DEFINE resultado_asign_usuario_2 INTEGER;
  DEFINE resultado_asign_num_empleado_2 CHAR(9);

  DEFINE resultado_nume_cliente CHAR(9);
  DEFINE resultado_nombreBeneficiario CHAR(100);
  DEFINE resultado_representante_legal INTEGER;

  DEFINE resultado_cuenta_abonar CHAR(20);

  DEFINE cargo_inversion  INTEGER;
  DEFINE abono_cuenta_eje INTEGER;
  DEFINE contar_cuentas_exito INTEGER;

  -- DEFINICION DE VARIABLES DE RETORNO
  DEFINE codigo_retorno_traspaso            CHAR(6);
  DEFINE mensaje_retorno_traspaso          CHAR(250);

  DEFINE resultado_cuenta_eje     CHAR(20);
  DEFINE cuenta_inv_cancelada     INTEGER;
  DEFINE saldo_congelado MONEY;
  DEFINE existe_saldo_congelado INTEGER;
  DEFINE resultado_pky_usuario INTEGER;

  DEFINE resultado_tipo_lugar_deceso INTEGER;
  DEFINE resultado_secuencia INTEGER;

  LET existe_saldo_congelado = 0;
  LET saldo_congelado = 0;

  -- 0) DEFINICION DE VARIABLES DE RETORNO
  LET codigoRetorno       = '';
  LET mensajeRetorno      = '';
  LET tipoAccion          = '';
  LET cuentaBeneficiario  = '';
  LET cuentaClienteFallecido = '';

  LET codigo_retorno_traspaso   = '';
  LET mensaje_retorno_traspaso  = '';


  -- 1) OBTENCION DE INFORMACION DE LA SOLICITUD
  LET resultado_numero_cliente = '';
  LET resultado_foliocsuac = '';

  -- 2) QUERY DE CONTROL
  LET resultado_pky_control_tramite_cuenta  = 0;
  LET resultado_num_cta_cliente             = '';
  LET resultado_num_cta_beneficiario        = '';
  LET resultado_porcentaje_bene             = 0;
  LET resultado_tramite                     = 0;
  LET resultado_exitoso                     = 0;
  LET resultado_tipo_cancelacion            = 0;
  --LET resultado_fecha_vencimiento           = DATE(1);
  LET resultado_monto_original              = 0;
  LET resultado_monto_cargo					= 0;
  LET resultado_monto_inversion                = 0;
  -- 3) NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE
  LET v_numero_documentos_necesarios_beneficiario    = 0;
  LET v_numero_documentos_digitalizados_beneficiario = 0;

  LET v_numero_documentos_necesarios_fallecido    = 0;
  LET v_numero_documentos_digitalizados_fallecido = 0;

  LET resultado_estatus_cuenta_beneficiario = '';
  LET resultado_estatus_cuenta_cliente_fallecido = '';
  LET resultado_estatus_cuenta_eje = '';
  LET resultado_motivo = '';
  -- 8) CALCULO DE PORCENTAJE Y MONTO A PAGAR AL BENEFICIARIO
  LET monto_pago_bene           = 0;
  -- 9) SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
  LET resultado_accion = 0;
  LET resultado_num_empleado = '';
  LET resultado_num_suc = '';
  LET resultado_pky_rango_importe = 0;
  LET resultado_rango_inferior = 0;
  -- 10.3) SE OBTIENE EL NUMERO DE TARJETA PARA REALIZAR EL CARGO A CLIENTE
  LET num_tarjeta_cliente = '';
  LET num_tarjeta_beneficiario = '';
  -- VALIDACION DE BANDERA DE CARGO
  LET resultado_cargo_bandera = 0;

  -- CONSTANTES
  LET p_Empresa   = '001';
  LET p_Ejecutivo = '001';
  LET p_Motivo    = 5;
  LET p_tran_aplica_cargo = '0409';
  LET p_tran_aplica_abono = '0408';

  LET resultado_accion_cumple = 0;
  LET resultado_accion_no_cumple = 0;
  LET resultado_accion_procede = 0;
  LET resultado_accion_no_procede = 0;
  LET resultado_aplicado = 0;

  LET motivo_cancelacion_debito = '04';

  LET resultado_asign_usuario = 0;
  LET resultado_asign_num_empleado = '';
  LET resultado_asign_usuario_2 = 0;
  LET resultado_asign_num_empleado_2 = '';

  LET resultado_nume_cliente = '';
  LET resultado_nombreBeneficiario = '';

  LET resultado_cuenta_eje = '';
  LET resultado_fky_usuario_analista = 0;
  LET cuenta_inv_cancelada = 0;
  LET resultado_pky_usuario = 0;
  LET saldo_actual = 0;
  LET nombreBeneficiario='';
  LET mensajeRetornoCancelacion = '';
  LET codigoRetornoCancelacion = '0';    

  -- SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/liquidacionCuentaInversion_"||p_idSolicitud||"_"||TRIM(p_cta_beneficiario)||"_34.out";
  -- TRACE ON;
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

  BEGIN

      -- OBTENER EL PKY DEL USUARIO
    SELECT pky_usuario
    INTO resultado_pky_usuario
    FROM acl_usuario WHERE num_empleado = p_usuario;

    IF(resultado_pky_usuario) IS NULL THEN
      LET resultado_pky_usuario = 0;
    END IF


    -- VALIDACION DE PARAMETROS DE ENTRADA
    IF p_cta_cliente IS NULL THEN
      LET p_cta_cliente = '';
    END IF
    IF p_cta_beneficiario IS NULL THEN
      LET p_cta_beneficiario = '';
    END IF
    IF p_usuario IS NULL THEN
      LET p_usuario = '';
    END IF

    IF p_idSolicitud is null OR TRIM(p_cta_cliente) = '' OR TRIM(p_cta_beneficiario) = '' OR TRIM(p_usuario) = '' THEN
      LET codigoRetorno       = '000001';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Información incompleta.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = '';                             -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = '';
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = '';

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: Parametros incorrectos.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

    END IF

    -- OBTENCION DE INFORMACION DE LA SOLICITUD
    SELECT num_cliente,folio_csuac,fky_usuario_analista,num_sucursal
    INTO resultado_numero_cliente, resultado_foliocsuac,resultado_fky_usuario_analista,resultado_num_sucursal
    FROM fal_solicitud
    WHERE pky_solicitud = p_idSolicitud;

    -- OBTENER NOMBRE BENEFICIARIO, BANDERA DE REPRESENTANTE LEGAL
    SELECT nombre_cliente, representante_legal
    INTO resultado_nombreBeneficiario, resultado_representante_legal
    FROM  fal_beneficiario
    WHERE  pky_cuenta_beneficiario = p_cta_beneficiario
    AND pky_cuenta_cliente_fallecido = p_cta_cliente;

        -- OBTENCION DEL REGISTRO DE LA TABLA DE CONTROL (fal_control_tramite_)
    SELECT pky_control_tramite,
          cuenta_cliente_fallecido,
          cuenta_beneficiario,
          monto_porcentaje,
          tramite,
          exitoso,
          fky_tipo_tramite,
          --fecha_vencimiento_pagare,
          monto_original,
          monto_calculado,
          descripcion_detalle,
          cambio_instruccion_pagare as cargo,
          liquida_pagare as abono
    INTO resultado_pky_control_tramite_cuenta,
          resultado_num_cta_cliente,
          resultado_num_cta_beneficiario,
          resultado_porcentaje_bene,
          resultado_tramite,
          resultado_exitoso,
          resultado_tipo_cancelacion,
          --resultado_fecha_vencimiento,
          resultado_monto_original,
          resultado_monto_inversion,
          resultado_descripcion_detalle,
          cargo_inversion,
          abono_cuenta_eje
    FROM fal_control_tramite
    WHERE fky_solicitud = p_idSolicitud
    AND tramite = 1
    AND exitoso = 0
    AND fky_tipo_tramite = 4-- INVERSION
    AND cuenta_cliente_fallecido = p_cta_cliente
    AND cuenta_beneficiario = p_cta_beneficiario;

    --CONSULTAR CUENTA EJE DE LA CUENTA DE INVERSIï¿½N
    SELECT FIRST 1 cuentadep
    INTO resultado_cuenta_eje
    FROM bdicheq:"informix".sc_maechq qc
    LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )
    WHERE qc.cuenta = p_cta_cliente;


    --CONGELAR MONTO
    SELECT sdo_cong, sdo_actual
    INTO saldo_congelado, saldo_actual
    FROM bdicheq:"informix".sc_maechq qc
    WHERE qc.cuenta=resultado_cuenta_eje;

	SELECT sum(monto_cargo) 
	INTO resultado_monto_cargo
	FROM fal_control_tramite 
	where cuenta_cliente_fallecido=resultado_cuenta_eje;
	
    SELECT LIMIT 1 monto_original - resultado_monto_cargo
	AS monto_original
    INTO saldo_cuenta_eje
    FROM fal_control_tramite where cuenta_cliente_fallecido=resultado_cuenta_eje;



    IF TRIM(resultado_cuenta_eje) IS NULL OR  TRIM(resultado_cuenta_eje) = ''  THEN

      CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
      RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

      LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = mensajeRetorno;
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = p_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: No se encontró la cuenta eje de la inversión. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF

    -- NUMERO DE DOCUMENTOS DIGITALIZADOS DEL BENEFICIARIO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_beneficiario
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_num_cta_cliente AND FCDD.cuenta_beneficiario = resultado_num_cta_beneficiario
    AND FCDD.inconsistencia = 0;

    SELECT count(*)
    INTO v_numero_documentos_necesarios_beneficiario
    FROM fal_cat_tipo_beneficiario CTB
    INNER JOIN fal_beneficiario_gpo_doc BGD ON CTB.pky_tipo_beneficiario = BGD.fky_tipo_beneficiario
    INNER JOIN fal_cat_grupo_documento CGD ON BGD.fky_grupo_documento = CGD.pky_grupo_documento
    INNER JOIN fal_grupo_documento GD ON CGD.pky_grupo_documento = GD.fky_grupo_documento
    INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
    INNER JOIN fal_beneficiario B ON CTB.pky_tipo_beneficiario = B.fky_tipo_beneficiario
    AND B.pky_cuenta_cliente_fallecido = resultado_num_cta_cliente AND B.pky_cuenta_beneficiario = resultado_num_cta_beneficiario;


    -- NUMERO DE DOCUMENTOS DIGITALIZADOS DEL CLIENTE FALLECIDO
    SELECT count(*)
    INTO v_numero_documentos_digitalizados_fallecido
    FROM fal_control_digitaliza_doc FCDD
    WHERE FCDD.cuenta_cliente_fallecido = resultado_numero_cliente AND FCDD.cuenta_beneficiario = resultado_numero_cliente
    AND FCDD.inconsistencia = 0;

    -- SE VALIDA EL TIPO DE LUGAR DE FALLECIMIENTO.
    -- SI ES EN EL EXTRANJERO SE Aï¿½ADE UN DOCUMENTO.
    SELECT fky_lugar_deceso
    INTO resultado_tipo_lugar_deceso
    FROM fal_aviso 
    WHERE fky_solicitud = p_idSolicitud;

    IF  resultado_tipo_lugar_deceso = 2 THEN
      -- SE REALIZA LA CONSULTA POR EL DOCUMENTO ADICIONAL DE LA APOSTILLA
      SELECT count(*)
      INTO v_numero_documentos_necesarios_fallecido
      FROM fal_grupo_documento GD
      INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
      WHERE GD.fky_grupo_documento in (1,2,3);
    ELSE
        
      SELECT count(*)
      INTO v_numero_documentos_necesarios_fallecido
      FROM fal_grupo_documento GD
      INNER JOIN fal_cat_tipo_documento CTD ON GD.fky_tipo_documento = CTD.pky_tipo_documento
      WHERE GD.fky_grupo_documento in (1,2);

    END IF

    --DESCOMENTAR PARA PRUEBAS DE DESARROLLO*****************************************************************************************************
        --LET v_numero_documentos_digitalizados_fallecido=1;
        --LET v_numero_documentos_necesarios_fallecido=1;
        --LET v_numero_documentos_digitalizados_beneficiario=1;
        --LET v_numero_documentos_necesarios_beneficiario=1;
    --DESCOMENTAR PARA PRUEBAS DE DESARROLLO*****************************************************************************************************




    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL BENEFICIARIO, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
    -- ANTES DE REALIZAR LA LIQUIDACION SE VERIFICA EL ESTADO DE LA CUENTA DEL CF, DEBE ESTAR ACTIVA PARA REALIZAR LA TRANSACCION
        SELECT status_cta
        INTO resultado_estatus_cuenta_beneficiario
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = p_cta_beneficiario;

        SELECT status_cta, motivo
        INTO resultado_estatus_cuenta_cliente_fallecido,resultado_motivo
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = p_cta_cliente;

        SELECT status_cta, motivo
        INTO resultado_estatus_cuenta_eje,resultado_motivo_eje
        FROM bdicheq:"informix".sc_maechq
        WHERE cuenta = resultado_cuenta_eje;

       --LET resultado_pky_control_tramite_cuenta = null;
       --VALIDACIï¿½N DE PROCESO DE LA CUENTA
       IF resultado_pky_control_tramite_cuenta = 0 OR resultado_pky_control_tramite_cuenta IS NULL THEN -- VALIDACION DE PROCESO DE CUENTA

          LET codigoRetorno       = '000009';                       -- CODIGO DEFINIDO
          LET mensajeRetorno      = 'La cuenta ya se ha procesado.';
          LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
          LET cuentaClienteFallecido = p_cta_cliente;
          LET codigoRetornoCancelacion = '0';
          LET mensajeRetornoCancelacion = '';
          LET nombreBeneficiario = resultado_nombreBeneficiario;

          RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
       END IF

    -- SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL CLIENTE FALLECIDO CUENTA CON TODA LA DOCUMENTACION
    IF v_numero_documentos_necesarios_fallecido = v_numero_documentos_digitalizados_fallecido AND v_numero_documentos_digitalizados_fallecido != 0 THEN

            -- SE VERIFICA QUE SE PUEDA TRAMITAR EL PAGO, SI EL BENEFICIARIO CUENTA CON TODA LA DOCUMENTACION
       IF v_numero_documentos_necesarios_beneficiario = v_numero_documentos_digitalizados_beneficiario AND v_numero_documentos_digitalizados_beneficiario != 0 THEN
        --LET resultado_estatus_cuenta_eje=3;
        --LET resultado_motivo_eje ='04';
        --LET resultado_estatus_cuenta_cliente_fallecido=3;
        --LET resultado_motivo ='04';

        --SI LA CUENTA YA FUE CANCELADA SE PONE LA BANDERA DE CANCELACIï¿½N
        IF (resultado_estatus_cuenta_cliente_fallecido = 2) THEN
            LET cuenta_inv_cancelada = 1;
        END IF

        IF cuenta_inv_cancelada = 0 AND (resultado_estatus_cuenta_cliente_fallecido <> 3 OR resultado_motivo <> '04') THEN
               CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
               RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                  LET codigoRetorno       = codigoRetorno;
                  LET mensajeRetorno      = mensajeRetorno;
                  LET tipoAccion          = '0';
                  LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: El estatus de la cuenta de inversión no está bloqueada por fallecimiento. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);


               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
        END IF

        IF (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04')   THEN
            --VALIDAR TRASPASO DE CUENTAS DE INVERSIï¿½N A CUENTA EJE

            IF (cargo_inversion IS NULL OR cargo_inversion = 0) AND (abono_cuenta_eje IS NULL OR abono_cuenta_eje = 0) THEN
                --MANDAR LLAMAR EL SP DE TRASPASO DE CUENTAS
                CALL sp_fal_traspaso_cuentas_inversion(p_usuario, p_cta_cliente, p_idSolicitud, saldo_cuenta_eje, resultado_monto_original)
                RETURNING codigo_retorno_traspaso, mensaje_retorno_traspaso;
                    --LET codigo_retorno_traspaso = '000000';
                    IF codigo_retorno_traspaso!='000000' THEN

                        CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, '', p_usuario,'',0)
                        RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                        LET codigoRetorno       = codigoRetorno;
                        LET mensajeRetorno      = mensajeRetorno;
                        LET tipoAccion          = '0';
                        LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                        LET cuentaClienteFallecido = resultado_num_cta_cliente;
                        LET codigoRetornoCancelacion = '0';
                        LET mensajeRetornoCancelacion = '';
                        LET nombreBeneficiario = resultado_nombreBeneficiario;

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación:' || mensaje_retorno_traspaso || ' CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                        RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                    ELSE

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Traspaso de cuentas de inversión exitoso.', current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                        UPDATE fal_control_tramite SET cambio_instruccion_pagare = 1, liquida_pagare = 1, fecha_cancelacion = today
                        WHERE cuenta_cliente_fallecido = p_cta_cliente
                        AND fky_tipo_tramite = 4;

                        --CONGELAR MONTO
                        SELECT sdo_cong
                        INTO saldo_congelado
                        FROM bdicheq:"informix".sc_maechq qc
                        WHERE qc.cuenta=resultado_cuenta_eje;
                        LET cuenta_inv_cancelada = 1;
                    END IF
            END IF

            ELSE --IF (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04')

                         CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                         RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
                         LET codigoRetorno       = codigoRetorno;
                         LET mensajeRetorno      = mensajeRetorno;
                         LET tipoAccion          = '0';
                         LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
                         LET cuentaClienteFallecido = resultado_num_cta_cliente;
                         LET codigoRetornoCancelacion = '0';
                         LET mensajeRetornoCancelacion = '';
                         LET nombreBeneficiario = resultado_nombreBeneficiario;

                         INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                         VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: El estatus de la cuenta de eje no está bloqueada por fallecimiento. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                         RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            END IF --FIN IF (resultado_estatus_cuenta_eje = 3 AND resultado_motivo_eje = '04')


            --LET resultado_estatus_cuenta_beneficiario = 9;
            --VALIDACIï¿½N DE ESTATUS DE LA CUENTA DEL BENEFICIARIO
             IF TRIM(resultado_estatus_cuenta_beneficiario) not in (1,4,5) THEN
               LET codigoRetorno       = '000002';
               LET mensajeRetorno      = 'Estatus cuenta beneficiario NO ACTIVA.';
               LET tipoAccion          = '0';
               LET cuentaBeneficiario  = resultado_num_cta_beneficiario;
               LET cuentaClienteFallecido = resultado_num_cta_cliente;
               LET codigoRetornoCancelacion = '0';
               LET mensajeRetornoCancelacion = '';
               LET nombreBeneficiario = resultado_nombreBeneficiario;

               INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
               VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: El estatus de la cuenta del beneficiario no es ACTIVA. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACION',resultado_pky_usuario,p_usuario);

               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
             END IF

             IF saldo_congelado > 0 THEN
                LET existe_saldo_congelado = 1;
             END IF




              --LET monto_pago_bene = 0;
              LET monto_pago_bene = resultado_monto_inversion;


              -- SE OBTIENE LA ACCION DE ACUERDO AL MONTO POR PAGAR DE LA REGLA DE NEGOCIO
              SELECT frimp.pky_rango_importe,frimp.rango_inferior
              INTO resultado_pky_rango_importe,resultado_rango_inferior
              FROM fal_solicitud fsol
              INNER JOIN fal_cat_evento ceve ON ceve.pky_evento = fsol.fky_evento AND ceve.fky_origen_evento = fsol.fky_origen_evento
              INNER JOIN fal_regla_negocio frn ON frn.fky_evento = ceve.pky_evento AND frn.fky_origen_evento = ceve.fky_origen_evento
              INNER JOIN fal_rango_importe frimp ON frimp.fky_regla_negocio = frn.pky_regla_negocio
              WHERE frimp.rango_inferior <= monto_pago_bene AND frimp.rango_mayor >= monto_pago_bene
              AND fsol.pky_solicitud = p_idSolicitud
              AND frn.activo = 1;

              -- SE OBTIENEN LAS ACCIONES A REALIZAR POR EL RANGO IMPORTE
              SELECT frimpacc.cumple,frimpacc.no_cumple,frimpacc.procede,frimpacc.no_procede
              INTO resultado_accion_cumple, resultado_accion_no_cumple, resultado_accion_procede, resultado_accion_no_procede
              FROM fal_rango_importe_accion frimpacc
              WHERE frimpacc.fky_rango_importe = resultado_pky_rango_importe;

              -- VALIDACION PARA LA LIQUIDACION A MONTOS MENORES A 1
              IF monto_pago_bene < 1 AND monto_pago_bene > 0 THEN
                LET resultado_rango_inferior = 1;
              END IF

              -- VALIDACION SI ES ACCION NO ES AUTOMATICA
              -- AUTOMATICO CUANDO EL RANGO ES MENOR
              --LET resultado_rango_inferior = 1; -- FLUJO AUTOMATICO
              IF resultado_accion_cumple != 1 THEN
                 IF existe_saldo_congelado = 1 THEN -- CORRESPONDE A BLOQUEO POR MONTO
                    CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 3, today, p_usuario, '', '07', 'A', '12', 'Z')
                    RETURNING codret_blqcta_eje, menret_blqcta_eje;
                 ELSE
                    CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                    RETURNING codret_blqcta_eje,menret_blqcta_eje;
                 END IF

                  CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                  RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                  LET codigoRetorno       = codigoRetorno;                  -- CODIGO DEFINIDO
                  LET mensajeRetorno      =  mensajeRetorno;
                  LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                  LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                  LET cuentaClienteFallecido = resultado_num_cta_cliente;
                  LET codigoRetornoCancelacion = '0';
                  LET mensajeRetornoCancelacion = '';
                  LET nombreBeneficiario = resultado_nombreBeneficiario;

                  INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                  VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación: La cuenta se va a central por regla de negocio.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                  RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
              END IF

                        --DESBLOQUEAR LAS CUENTAS PARA HACER EL CARGO Y EL ABONO AL BENEFICIARIO
                        IF existe_saldo_congelado = 1 THEN
                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '00', 0, today, p_usuario, '4469', '07', 'A', '12', 'Z' )
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;
                        ELSE
                            CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,0,'00',0,today,p_usuario,'4469','07','A','12','Z' )
                            RETURNING codret_blqcta_eje,menret_blqcta_eje;
                        END IF


                       --LET codret_blqcta = '000';
                       --LET codret_blqcta_eje = '000';
                       --VALIDACIï¿½N EN CASO DE QUE NO SE PUEDAN ACTIVAR LAS CUENTAS DEL CLIENTE FALLECIDO (EJE E INVERSIï¿½N)
                       IF (TRIM(codret_blqcta_eje) !='000')  THEN
                          CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                          RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                          LET codigoRetorno       = codret_blqcta_eje;                  -- CODIGO DEFINIDO
                          LET mensajeRetorno      = 'La liquidación de recursos se hará en Central. ';
                          LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                          LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                          LET cuentaClienteFallecido = resultado_num_cta_cliente;
                          LET codigoRetornoCancelacion = '0';
                          LET mensajeRetornoCancelacion = '';
                          LET nombreBeneficiario = resultado_nombreBeneficiario;

                          INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                          VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error de liquidación: Ocurrió un error con el desbloqueo de la cuenta eje.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                          RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                       END IF --VALIDAR CODIGOS DE RETORNO


                       --DESPUES DE ACTIVAR LA CUENTA EJE

                        -- SE GENERA EL FOLIO SUC
                        SELECT substr((current HOUR TO SECOND),1,2) || substr((current HOUR TO SECOND),4,2) || substr((current HOUR TO SECOND),7,2)
                        INTO p_fecha_folio
                        FROM systables WHERE tabid=1;
                        LET p_FolioSUC = trim(p_fecha_folio) || lpad(resultado_foliocsuac,10,0);

                        --OBTENER NUMERO DE TARJETA DE LA CUENTA EJE
						select max(secuencia)
						into resultado_secuencia
                        from bdicheq:sc_tarjeta  st
                        where st.cuenta = resultado_cuenta_eje;
						
                        LET num_tarjeta_cliente = (
                          --select nvl(st.num_tarjeta, '')
                          select case when st.num_tarjeta is null then ''
                          else st.num_tarjeta
                          end
                          from bdicheq:sc_tarjeta  st
                          where st.cuenta = resultado_cuenta_eje
                          and secuencia = resultado_secuencia
                        );

                        -- VERIFICA SI YA SE HIZO EL CARGO AL CLIENTE -
                        SELECT cargo, exitoso
                        INTO resultado_cargo_bandera, resultado_abono_bandera
                        FROM fal_control_tramite
                        WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        -- VALIDAR SI LA CUENTA TIENE REPRESENTANTE LEGAL
                        LET resultado_cuenta_abonar = resultado_num_cta_beneficiario;
                        IF resultado_representante_legal = 1 THEN
                          LET resultado_cuenta_abonar = TRIM(resultado_descripcion_detalle);
                        END IF



                        IF resultado_cargo_bandera != 1 THEN -- VALIDACION EN 0 DEL CARGO AL CLIENTE
                          -- EL CARGO AL CLIENTE NO SE HA REALIZADO
                          -- SE EJECUTA EL SP DE CARGO DE MONTO AL CLIENTE
                            CALL bdicheq:"informix".cargo_ref(p_Empresa, resultado_num_sucursal, p_usuario , p_tran_aplica_cargo, '0000', p_FolioSUC, resultado_cuenta_eje, 0, monto_pago_bene, '01', resultado_folioCsuac, num_tarjeta_cliente, p_Ejecutivo)
                            RETURNING codret_cargo_ref, tranret_cargo_ref, fechoy_cargo_ref, sdodisp_cargo_ref, montoret_cargo_ref;

                             --LET codret_cargo_ref = '000';
                             -- VALIDACION DE LA EJECUCION DEL SP DE CARGO
                             IF codret_cargo_ref != '000' THEN

                                UPDATE fal_control_tramite SET cargo = 0
                                WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                                -- CUANDO NO SE REALIZO EL CARGO AL CLIENTE\-- SE BLOQUEA DE NUEVO LA CUENTA DEL CLIENTE

                                IF existe_saldo_congelado = 1 THEN
                                   CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                   RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                ELSE
                                   CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                   RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                END IF

                                CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                                RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;


                                LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = mensajeRetorno;
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;


                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud, 'Error liquidación: No se pudo realizar el cargo al cliente. Cod: ' || codret_cargo_ref || 'Respuesta:' || tranret_cargo_ref ,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                             END IF

                            -- ACTUALIZA TABLA DE CONTROL
                            UPDATE fal_control_tramite SET cargo_monto = monto_pago_bene, cargo = 1
                            WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                        END IF --VALIDACION DE CARGO AL CLIENTE


                       IF resultado_abono_bandera!=1 THEN

                        -- SI SE REALIZO CORRECTAMENTE EL CARGO AL CLIENTE
						select max(secuencia)
							into resultado_secuencia
                            from bdicheq:"informix".sc_tarjeta  st
                            where st.cuenta = resultado_num_cta_beneficiario;
							
                        LET num_tarjeta_beneficiario = (
                          --select nvl(st.num_tarjeta, '')
                          select case when st.num_tarjeta is null then ''
                          else st.num_tarjeta
                          end
                          from bdicheq:"informix".sc_tarjeta  st
                          where st.cuenta = resultado_num_cta_beneficiario
                          and secuencia = resultado_secuencia                          
                        );

                        --############################################################################################################################################################################################################################################################
                        CALL bdicheq:"informix".abono_ref(p_Empresa, resultado_num_sucursal, p_usuario, p_tran_aplica_abono, '0000', p_FolioSUC, resultado_cuenta_abonar, 0, monto_pago_bene, monto_pago_bene, 0, 0, 0, '01', resultado_folioCsuac, num_tarjeta_beneficiario, p_Ejecutivo)
                        RETURNING vcodret_abono;
                        --############################################################################################################################################################################################################################################################
                            --LET vcodret_abono = '000';
                            -- VALIDACION SI SE PUDO HACER EL ABONO AL BENEFICIARIO
                            IF vcodret_abono = '000' THEN
                               -- ACTUALIZA LA TABLA DE BENEFICIARIOS

                               UPDATE fal_control_tramite SET exitoso = 1, monto_cargo = monto_pago_bene, fky_estatus_corporativo = 6 , fky_estatus_sucursal = 3, tramite_analisis = 1
                               WHERE pky_control_tramite = resultado_pky_control_tramite_cuenta;

                               UPDATE fal_beneficiario  SET aplicado = 1, monto_aplicado = monto_pago_bene, fecha_tramite = sysdate, tramite_aplicado = 1
                               WHERE fky_control_tramite = resultado_pky_control_tramite_cuenta;



                               IF existe_saldo_congelado = 1 THEN
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                  RETURNING codret_blqcta_eje, menret_blqcta_eje;
                               ELSE
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                  RETURNING codret_blqcta_eje,menret_blqcta_eje;
                               END IF


                                            --VALIDAR SI SE LIQUIDARON LOS BENEFICIARIOS DE LA CUENTA EJE
                                            SELECT COUNT(*)
                                            INTO contar_cuentas_exito
                                            FROM fal_control_tramite
                                            WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                                            AND exitoso = 0
                                            AND fecha_cancelacion IS NULL;

                                                IF contar_cuentas_exito = 0 OR contar_cuentas_exito IS NULL THEN --VALIDACION CUENTAS EJE EXITOSAS
                                                  -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                                                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                                                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                                                  IF cod_resp_cancelacion_debito = '069' THEN --VALIDACION CANCELACION EJE
                                                                -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                                                    UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                                                    WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                                                    AND fky_tipo_tramite = 1;

                                                    -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                                                      LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                                      LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';
                                                      LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                                      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                                      LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                                      LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                                      LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                                      LET nombreBeneficiario = resultado_nombreBeneficiario;

                                                      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                                      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta eje se ha cancelado exitosamente.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                                      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                                  ELSE--VALIDACION CANCELACION EJE

                                                      LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                                      LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';
                                                      LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                                      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                                      LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                                      LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                                      LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                                      LET nombreBeneficiario = resultado_nombreBeneficiario;
                                                    
                                                    /***
                                                        IF existe_saldo_congelado = 1 THEN
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                                           RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                                        ELSE
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                                           RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                                        END IF
                                                    **/

                                                      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                                      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación cuenta eje: Cod:'||cod_resp_cancelacion_debito || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                                      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                                  END IF--VALIDACION CANCELACION EJE
                                              END IF--VALIDACION CUENTAS EJE EXITOSAS


                                                                                    -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                               LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                               LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';
                               LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                               LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                               LET cuentaClienteFallecido = resultado_num_cta_cliente;
                               LET codigoRetornoCancelacion = '';
                               LET mensajeRetornoCancelacion = '';
                               LET nombreBeneficiario = resultado_nombreBeneficiario;

                               INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                               VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Liquidación a la cuenta de beneficiario exitosa: Bloqueo cuenta eje:'||menret_blqcta_eje,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;


                            ELSE --IF vcodret_abono = '000'

                                CALL "informix".sp_fal_liquidacion_asignar_analista(resultado_fky_usuario_analista,p_idSolicitud, p_cta_cliente, p_cta_beneficiario, p_usuario,resultado_nombreBeneficiario,resultado_pky_control_tramite_cuenta)
                                RETURNING codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                LET codigoRetorno       = codigoRetorno;                       -- CODIGO DEFINIDO
                                LET mensajeRetorno      = mensajeRetorno;
                                LET tipoAccion          = '2';                            -- ACCION POR REGLA DE NEGOCIO
                                LET cuentaBeneficiario  = resultado_num_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                LET cuentaClienteFallecido =  resultado_num_cta_cliente;
                                LET codigoRetornoCancelacion = '0';
                                LET mensajeRetornoCancelacion = '';
                                LET nombreBeneficiario = resultado_nombreBeneficiario;

                                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud, 'Error liquidación: No se pudo abonar a la cuenta del beneficiario. Cod: ' || vcodret_abono ,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

                                RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                            END IF -- FIN VALIDACIï¿½N ABONO DE CLIENTE
                      ELSE -- VALIDACIï¿½N SI YA SE HIZO EL ABONO ANTERIORMENTE


                               IF existe_saldo_congelado = 1 THEN
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                  RETURNING codret_blqcta_eje, menret_blqcta_eje;
                               ELSE
                                  CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                  RETURNING codret_blqcta_eje,menret_blqcta_eje;
                               END IF

                               --VALIDAR SI SE LIQUIDARON LOS BENEFICIARIOS DE LA CUENTA EJE
                               SELECT COUNT(*)
                               INTO contar_cuentas_exito
                               FROM fal_control_tramite
                               WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                               AND exitoso = 0
                               AND fecha_cancelacion IS NULL;

                               IF contar_cuentas_exito = 0 OR contar_cuentas_exito IS NULL THEN --VALIDACION CUENTAS EJE EXITOSAS
                               -- VALIDA SI SE PUEDE CANCELAR LA CUENTA:
                                  CALL sp_fal_cancelacion_cuenta_debito( p_Empresa, TRIM(resultado_cuenta_eje),motivo_cancelacion_debito, p_usuario, TRIM(resultado_num_sucursal))
                                  RETURNING cod_resp_cancelacion_debito, msj_resp_cancelacion_debito;

                                  IF cod_resp_cancelacion_debito = '069' THEN --VALIDACION CANCELACION EJE
                                  -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
                                     UPDATE fal_control_tramite SET fecha_cancelacion = sysdate
                                     WHERE cuenta_cliente_fallecido = resultado_cuenta_eje
                                     AND fky_tipo_tramite = 1;

                                     -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                                     LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                     LET mensajeRetorno      = 'La Baja del Cliente se realizó con éxito. La liquidación de recursos se hará en Central.';
                                     LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                     LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                     LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                     LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                     LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                     LET nombreBeneficiario = resultado_nombreBeneficiario;

                                     INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                     VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación: La cuenta eje se ha cancelado exitosamente.',current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                     RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                  ELSE--VALIDACION CANCELACION EJE
                                    LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                                    LET mensajeRetorno      = 'La liquidación de recursos se hará en Central.';
                                    LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                                    LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                                    LET cuentaClienteFallecido = resultado_num_cta_cliente;
                                    LET codigoRetornoCancelacion = cod_resp_cancelacion_debito;
                                    LET mensajeRetornoCancelacion = msj_resp_cancelacion_debito;
                                    LET nombreBeneficiario = resultado_nombreBeneficiario;

                                                    /***
                                                        IF existe_saldo_congelado = 1 THEN
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa, TRIM(resultado_cuenta_eje), saldo_cuenta_eje, '04', 1, today, p_usuario, '', '07', 'A', '12', 'Z')
                                                           RETURNING codret_blqcta_eje, menret_blqcta_eje;
                                                        ELSE
                                                           CALL bdicheq:"informix".bloqueo_cta(p_Empresa,resultado_cuenta_eje,'0','04',3,today,p_usuario,'','11','S','12','Z')
                                                           RETURNING codret_blqcta_eje,menret_blqcta_eje;
                                                        END IF
                                                    **/

                                      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                                      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación cuenta eje: Cod:'||cod_resp_cancelacion_debito || msj_resp_cancelacion_debito,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);
                                      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;

                                  END IF--VALIDACION CANCELACION EJE
                                END IF--VALIDACION CUENTAS EJE EXITOSAS


                               -- SI SE PUDO REALIZAR LA CANCELACION DE LA CUENTA
                               LET codigoRetorno       = '000000';                       -- CODIGO DEFINIDO
                               LET mensajeRetorno      = 'Esta cuenta ya fue liquidada.';
                               LET tipoAccion          = '1';                            -- ACCION POR REGLA DE NEGOCIO
                               LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
                               LET cuentaClienteFallecido = resultado_num_cta_cliente;
                               LET codigoRetornoCancelacion = '';
                               LET mensajeRetornoCancelacion = '';
                               LET nombreBeneficiario = resultado_nombreBeneficiario;

                               RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;


                      END IF -- FIN VALIDACIï¿½N SI YA SE HIZO EL ABONO ANTERIORMENTE

            ELSE --SI NO TIENE LOS DOCUMENTOS COMPLETOS
              -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
              UPDATE fal_control_tramite SET fky_estatus_corporativo = 8 , fky_estatus_sucursal = 4
              where pky_control_tramite = resultado_pky_control_tramite_cuenta;

            -- ACCIONES EN CASO DE NO CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
              LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
              LET mensajeRetorno      = 'Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso.';
              LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
              LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
              LET cuentaClienteFallecido = resultado_num_cta_cliente;
              LET codigoRetornoCancelacion = '0';
              LET mensajeRetornoCancelacion = '';
              LET nombreBeneficiario = resultado_nombreBeneficiario;

              INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
              VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error Liquidación: La documentación del beneficiario está incompleta. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);

              RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
            END IF --VALIDACION DE DOCUMENTACION BENEFICIARIO


    ELSE --SI NO TIENE LOS DOCUMENTOS COMPLETOS CF
      -- SE ACTUALIZA LA FECHA DE CANCELACION, ESTATUS CORP, ESTATUS SUC, ESTATUS GENERAL
      UPDATE fal_control_tramite SET fky_estatus_corporativo = 8 , fky_estatus_sucursal = 4
      where pky_control_tramite = resultado_pky_control_tramite_cuenta;

    -- ACCIONES EN CASO DE NO CUMPLIR CON LA CONDICION DE DOCUMENTACION COMPLETA DEL BENEFICIARIO
      LET codigoRetorno       = '000006';                       -- CODIGO DEFINIDO
      LET mensajeRetorno      = 'Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso.';
      LET tipoAccion          = '0';                            -- ACCION POR REGLA DE NEGOCIO
      LET cuentaBeneficiario  = p_cta_beneficiario ;            -- CUENTA BENEFICIARIO
      LET cuentaClienteFallecido = resultado_num_cta_cliente;
      LET codigoRetornoCancelacion = '0';
      LET mensajeRetornoCancelacion = '';
      LET nombreBeneficiario = resultado_nombreBeneficiario;

      INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
      VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Error liquidación: Se tendrá un plazo de 30 días para digitalizar, de lo contrario se cancelará el proceso. CF: ' || p_cta_cliente || ' CB: ' || p_cta_beneficiario,current,resultado_foliocsuac,'LIQUIDACIÓN',resultado_pky_usuario,p_usuario);


      RETURN codigoRetorno,mensajeRetorno,tipoAccion,cuentaBeneficiario,cuentaClienteFallecido,codigoRetornoCancelacion,mensajeRetornoCancelacion,nombreBeneficiario;
    END IF --VALIDACION DE DOCUMENTACION

  END

END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_actualiza_estatus_cuenta(p_cuenta CHAR(20),p_cliente CHAR(9),p_producto INT, p_tipo INT)

    RETURNING CHAR(100) AS estatus_cta;

    DEFINE iSqlErr            INTEGER;

    DEFINE estatus_cuenta     CHAR(100);
    DEFINE movito_bloqueo     CHAR(80);  
    DEFINE res_status_cta     CHAR(50);
    DEFINE codigo_estatus_cta INT;
    DEFINE producto_debito    INT;
    DEFINE producto_credito   INT;
    DEFINE secuenciaMax       CHAR(4);
    

    LET res_status_cta = '';
    LET estatus_cuenta      = '';
    LET codigo_estatus_cta = '0';
    
    LET movito_bloqueo      = '';
    LET producto_credito    = '1';
    LET producto_debito     = '2';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    BEGIN -- inciando estrutura de SP

        --Instrucciones para el manejo de excepciones
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET estatus_cuenta = '';
                RETURN  'Error: '||iSqlErr; --RETURNING
            END IF;
        END EXCEPTION;
        
--        SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_fal_actualiza_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
--        TRACE ON;

        IF(p_tipo=1) THEN

            IF(p_producto = producto_credito) THEN -- La cuenta de entrada es de tipo ¿CREDITO? (1)

                --Consulta el estatus de la cuenta de Credito. (Tipo bloqueo y Motivo bloqueo)
                SELECT 
                --nvl(tc.descripcion,''),
                case when tc.descripcion is null then ''
                else tc.descripcion
                end,
                --nvl(cb.causa_bloq,'')
                case when cb.causa_bloq is null then ''
                else cb.causa_bloq
                end
                INTO res_status_cta,movito_bloqueo
                FROM bdicred:"informix".sd_maecred mcrd
                RIGHT JOIN bdicred:"informix".sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
                LEFT JOIN bdicred:"informix".sd_causa_bloqueo cb ON cb.cod_causa = mcrd.Cod_caract_2
                WHERE mcrd.numcte = p_cliente
                AND num_credito = p_cuenta;

                --Actualizando la cuenta del cliente CREDITO
                UPDATE fal_saldo_anterior SET estatus_cuenta = res_status_cta,motivo_estatus = movito_bloqueo 
                WHERE num_cuenta_titular = p_cuenta AND numero_cliente = p_cliente;

                --Asignación de información de salida
                LET estatus_cuenta = res_status_cta||'*'||movito_bloqueo;


            END IF;

            IF (p_producto = producto_debito) THEN  
            
                --Consulta el estatus de la cuenta de Debito. (Tipo bloqueo y Motivo bloqueo)
                SELECT 
                --nvl(mst.descripcion,''),
                case when mst.descripcion is null then ''
                else mst.descripcion
                end,
                --nvl(cb.descripcion,'') 
                case when cb.descripcion is null then ''
                else cb.descripcion
                end
                INTO res_status_cta,movito_bloqueo
                FROM bdicheq:"informix".sc_maechq mchq
                RIGHT JOIN bdicheq:"informix".sc_mae_estatus mst ON mst.cod_estatus=mchq.status_cta 
                LEFT JOIN  bdicheq:"informix".sc_bloqueo cb ON cb.codigo=mchq.motivo
                WHERE mchq.num_cte = p_cliente
                AND mchq.cuenta = p_cuenta;

                --Actualizando la cuenta del cliente DEBITO
                UPDATE fal_saldo_anterior SET estatus_cuenta = res_status_cta,motivo_estatus = movito_bloqueo 
                WHERE num_cuenta_titular = p_cuenta AND numero_cliente = p_cliente;

                --Asignación de información de salida

                LET  estatus_cuenta = res_status_cta||'*'||movito_bloqueo;


            END IF;
          RETURN estatus_cuenta;
        END IF;

        IF(p_tipo=2) THEN
            
            --LET estatus_cuenta = '2';
            -- Buscando en DEBITO x cuenta
            SELECT FIRST 1 mchq.status_cta
            INTO codigo_estatus_cta
            FROM bdicheq:sc_maechq mchq
            RIGHT JOIN bdicheq:"informix".sc_mae_estatus mst ON mst.cod_estatus=mchq.status_cta
            LEFT OUTER JOIN bdicheq:"informix".sc_maechq qc ON (qc.num_cte = mchq.num_cte) 
            LEFT OUTER JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
            LEFT JOIN  bdicheq:"informix".sc_bloqueo cb ON cb.codigo=mchq.motivo
            WHERE mchq.cuenta = p_cuenta
            AND pr.producto IN (1300, 1400, 1700, 1900, 2000, 2500);

             LET estatus_cuenta = codigo_estatus_cta;

            IF (codigo_estatus_cta <>'0' AND (codigo_estatus_cta = '1' OR codigo_estatus_cta='4' OR codigo_estatus_cta='5')) THEN
                LET estatus_cuenta = 'CUENTA_VALIDA';
            ELSE
                LET estatus_cuenta = 'CUENTA_NO_VALIDA';
            END IF;

                RETURN  estatus_cuenta;
        END IF;
        
    
        

    END


END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Descripción	: 	Sp que actualiza los estatus de las cuentas en bdiaclaracion:fal_saldo_anterior',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Enero/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_direccion_cte(p_sNumeroCliente CHAR(20))

     RETURNING CHAR(3) AS codigo, CHAR(100) AS calle,  CHAR(100) AS colonia, 
     CHAR(100) AS municipio, CHAR(100) AS estado, CHAR(100) AS ciudad,  CHAR(10) AS cp ;


    --definicion de variables--     
    DEFINE resultado_codigo                    CHAR(3);
    DEFINE resultado_calle                     CHAR(100);
    DEFINE resultado_colonia                   CHAR(100);
    DEFINE resultado_municipio                 CHAR(100);
    DEFINE resultado_estado                    CHAR(100);
    DEFINE resultado_ciudad                    CHAR(100);
    DEFINE resultado_cp                        CHAR(10);

    DEFINE iSqlErr                             INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_codigo ='';
    LET resultado_calle = '';
    LET resultado_colonia ='';
    LET resultado_municipio = '';
    LET resultado_estado = '';
    LET resultado_ciudad = '';
    LET resultado_cp = '';



    SET ISOLATION TO DIRTY READ;
            
    BEGIN


        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_codigo = '001';
                LET resultado_calle = '';
                LET resultado_colonia ='';
                LET resultado_municipio = '';
                LET resultado_estado = '';
                LET resultado_ciudad = '';
                LET resultado_cp = '';
                RETURN resultado_codigo, resultado_calle, resultado_colonia, resultado_municipio, resultado_estado, resultado_ciudad, resultado_cp;
            END IF;
        END EXCEPTION;


        LET resultado_codigo ='000';
        SELECT first 1 
        --NVL(Trim(ct.nombrecalle), ' ') as calle, 
        case when ct.nombrecalle is null then ' ' else ct.nombrecalle end as calle,
        --NVL(Trim(sz.nombrezona), ' ') as colonia,  
        case when sz.nombrezona is null then ' ' else sz.nombrezona end as colonia,
        --NVL(Trim(sz.municipiozona), ' ') as municipio, 
        case when sz.municipiozona is null then ' ' else sz.municipiozona end as municipio,
        --NVL(Trim(edo.nombre), ' ') as estado, 
        case when edo.nombre is null then ' ' else edo.nombre end as estado,
        --NVL(ciu.nombre,' ') as ciudad, 
        case when ciu.nombre is null then ' ' else ciu.nombre end as ciudad,
        --NVL(sd.cod_postal,' ')
        case when sd.cod_postal is null then ' ' else sd.cod_postal end
        INTO resultado_calle, resultado_colonia, resultado_municipio, resultado_estado, resultado_ciudad, resultado_cp
        FROM bdinteg:"informix".si_cliente sc
                 Left Outer Join bdinteg:"informix".si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:"informix".si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:"informix".si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:"informix".si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:"informix".si_ciudades  ciu on ciu.ciudad = sd.numerociudad
        where sc.NUMCTE = p_sNumeroCliente;

        RETURN resultado_codigo, resultado_calle, resultado_colonia, resultado_municipio, resultado_estado, resultado_ciudad, resultado_cp;


    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_busca_nombre_core(p_empleado CHAR(10))

RETURNING  CHAR(80) AS nombre_empleado;
 
DEFINE resultado_nombre_empleado  CHAR(120);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
           
    SELECT nombre 
    INTO resultado_nombre_empleado
    FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = p_empleado;

    return resultado_nombre_empleado;
END

END PROCEDURE 
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_saldos_deb_cre_cliente(p_sNumeroCliente CHAR(9))

    RETURNING  CHAR(20) AS sumaSaldoCredito, CHAR(20) AS sumaSaldoDebito;

    --definicion de variables--     
    DEFINE saldoCredito MONEY(18,2);
    DEFINE saldoDebito  MONEY(18,2);
    DEFINE sumSaldoCredito MONEY(18,2);
    DEFINE sumSaldoDebito  MONEY(18,2);
    DEFINE sumSaldoCreditoChar CHAR(20);
    DEFINE sumSaldoDebitoChar  CHAR(20);

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);

    DEFINE iSqlErr      INTEGER;


    DEFINE resultado_codigo_retorno CHAR(10);
    DEFINE resultado_mensaje_retorno CHAR(10);
    DEFINE resultado_numero_credito CHAR(10);
    DEFINE resultado_codigo_tipcred CHAR(10);
    DEFINE resultado_fecha_origen CHAR(10);
    DEFINE resultado_fecha_prox_pago CHAR(10);
    DEFINE resultado_pago_minimo CHAR(10);
    DEFINE resultado_fecha_ult_pago CHAR(10);
    DEFINE resultado_plazo CHAR(10);
    DEFINE resultado_pagos_realizados CHAR(10);
    DEFINE resultado_linea_otorgada CHAR(10);
    DEFINE resultado_tasa_interes CHAR(10);
    DEFINE resultado_tasa_moratorios CHAR(10);
    DEFINE resultado_monto_sbc CHAR(10);
    DEFINE resultado_cap_vig CHAR(10);
    DEFINE resultado_cap_trans CHAR(10);
    DEFINE resultado_cap_vdo_exig CHAR(10);
    DEFINE resultado_cap_vdo_no_exig CHAR(10); 
    DEFINE resultado_sdo_act_total_cap MONEY;
    DEFINE resultado_int_vig CHAR(10);
    DEFINE resultado_int_vdo CHAR(10);
    DEFINE resultado_int_moratorios CHAR(10);
    DEFINE resultado_int_mes CHAR(10); 
    DEFINE resultado_sdo_act_total_int CHAR(10);
    DEFINE resultado_iva_int_vig CHAR(10);
    DEFINE resultado_iva_int_vdo CHAR(10);
    DEFINE resultado_iva_int_moratorios CHAR(10);
    DEFINE resultado_iva_int_mes CHAR(10);
    DEFINE resultado_sdo_act_total_iva CHAR(10);
    DEFINE resultado_com_pend CHAR(10);
    DEFINE resultado_iva_com CHAR(10);
    DEFINE resultado_sdo_retenido CHAR(10);
    DEFINE resultado_total_liquidacion CHAR(10);
    DEFINE resultado_int_devengado CHAR(10);
    DEFINE resultado_iva_int_devengado CHAR(10);
    DEFINE resultado_linea_disponible CHAR(10);
    DEFINE resultado_pagos_vdos CHAR(10);
    DEFINE resultado_desc_status_cred CHAR(10);
    DEFINE resultado_id_bloqueo_cred CHAR(10);
    DEFINE resultado_bloqueo_cta CHAR(10);
    DEFINE resultado_id_causa_bloqueo_cred CHAR(10);
    DEFINE resultado_causa_bloqueo_cta CHAR(10);
    DEFINE resultado_id_sit_esp_cte CHAR(10);
    DEFINE resultado_id_causa_esp_cte CHAR(10); 
    DEFINE resultado_sit_esp_cte CHAR(10);
    DEFINE resultado_id_sit_esp_cred CHAR(10);
    DEFINE resultado_id_causa_esp_cred CHAR(10);
    DEFINE resultado_sit_esp_cred CHAR(10);
    
     -- Inicializacion de las variables.
    LET saldoCredito = 0;
    LET saldoDebito  = 0;
    LET sumSaldoCredito = 0;
    LET sumSaldoDebito = 0;

    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';

    --SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/consultacatsaldos.out"; 
    --TRACE ON;
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET saldoCredito = 0;
                LET saldoDebito  = 0;
                LET sumSaldoCredito = 0;
                LET sumSaldoDebito = 0;
                RETURN sumSaldoCredito,sumSaldoDebito;
            END IF;
        END EXCEPTION;

        ---FOREACH PARA OBTENER SALDO DE CREDITOS
        
/**
            SELECT SUM(monto_calculado) 
            INTO resultado_sdo_act_total_cap
            FROM fal_control_tramite tra
            INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud
            WHERE num_cliente = p_sNumeroCliente
            AND fky_tipo_tramite = 2;
**/

            SELECT SUM(saldo) 
            INTO resultado_sdo_act_total_cap
            FROM fal_saldo_anterior 
            WHERE numero_cliente = p_sNumeroCliente
            AND tipo_movimiento_credito=1
            AND fky_tipo_tramite=2;


            IF resultado_sdo_act_total_cap IS NULL THEN
                FOREACH
                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(p_sNumeroCliente, 0) )
                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto)

                    SELECT codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
                                                    tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, sdo_act_total_int, 
                                                    iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, 
                                                    pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, 
                                                    id_causa_esp_cred, sit_esp_cred 
                    INTO resultado_codigo_retorno, resultado_mensaje_retorno, resultado_numero_credito, resultado_codigo_tipcred, resultado_fecha_origen, resultado_fecha_prox_pago, resultado_pago_minimo, resultado_fecha_ult_pago, resultado_plazo, resultado_pagos_realizados, resultado_linea_otorgada, 
                                                    resultado_tasa_interes, resultado_tasa_moratorios, resultado_monto_sbc, resultado_cap_vig, resultado_cap_trans, resultado_cap_vdo_exig, resultado_cap_vdo_no_exig, resultado_sdo_act_total_cap, resultado_int_vig, resultado_int_vdo, resultado_int_moratorios, resultado_int_mes, resultado_sdo_act_total_int, 
                                                    resultado_iva_int_vig, resultado_iva_int_vdo, resultado_iva_int_moratorios, resultado_iva_int_mes, resultado_sdo_act_total_iva, resultado_com_pend, resultado_iva_com, resultado_sdo_retenido, resultado_total_liquidacion, resultado_int_devengado, resultado_iva_int_devengado, resultado_linea_disponible, 
                                                    resultado_pagos_vdos, resultado_desc_status_cred, resultado_id_bloqueo_cred, resultado_bloqueo_cta, resultado_id_causa_bloqueo_cred, resultado_causa_bloqueo_cta, resultado_id_sit_esp_cte, resultado_id_causa_esp_cte, resultado_sit_esp_cte, resultado_id_sit_esp_cred, 
                                                    resultado_id_causa_esp_cred, resultado_sit_esp_cred 
                    FROM TABLE( FUNCTION  bdicred:sp_consulta_saldos_general('001',resultado_numeroCuenta) )
                                           AS a(codigo_retorno, mensaje_retorno, numero_credito, codigo_tipcred, fecha_origen, fecha_prox_pago, pago_minimo, fecha_ult_pago, plazo, pagos_realizados, linea_otorgada, 
                                                    tasa_interes, tasa_moratorios, monto_sbc, cap_vig, cap_trans, cap_vdo_exig, cap_vdo_no_exig, sdo_act_total_cap, int_vig, int_vdo, int_moratorios, int_mes, sdo_act_total_int, 
                                                    iva_int_vig, iva_int_vdo, iva_int_moratorios, iva_int_mes, sdo_act_total_iva, com_pend, iva_com, sdo_retenido, total_liquidacion, int_devengado, iva_int_devengado, linea_disponible, 
                                                    pagos_vdos, desc_status_cred, id_bloqueo_cred, bloqueo_cta, id_causa_bloqueo_cred, causa_bloqueo_cta, id_sit_esp_cte, id_causa_esp_cte, sit_esp_cte, id_sit_esp_cred, 
                                                    id_causa_esp_cred, sit_esp_cred );
                 END FOREACH;
            END IF                      
            LET sumSaldoCredito = sumSaldoCredito + resultado_sdo_act_total_cap;

 
        


        --FOREACH PARA OBTENER SALDOS DE PAGARES Y DEBITO
         SELECT SUM(monto_calculado) 
         INTO saldoDebito
         FROM fal_control_tramite tra
         INNER JOIN fal_solicitud sol ON sol.pky_solicitud = tra.fky_solicitud
         WHERE num_cliente = p_sNumeroCliente
         AND fky_tipo_tramite IN(1,3, 4);


         IF saldoDebito IS NULL THEN
            FOREACH 
                SELECT sdo_actual
                INTO saldoDebito
                FROM bdicheq:"informix".sc_maechq qc 
                WHERE num_cte = p_sNumeroCliente
                LET sumSaldoDebito = sumSaldoDebito + saldoDebito;
            END FOREACH;

            FOREACH 
                SELECT FIRST 1 capital
                INTO saldoDebito
                FROM bdinvers:"informix".sv_maeinv 
                WHERE num_cte=p_sNumeroCliente
                AND status_cta = 1
                LET sumSaldoDebito = sumSaldoDebito + saldoDebito;
            END FOREACH;
         END IF

            LET sumSaldoCreditoChar = REPLACE(TO_CHAR(sumSaldoCredito), '$', '');
            LET sumSaldoDebitoChar = REPLACE(TO_CHAR(sumSaldoDebito), '$', '');
            RETURN 
                --NVL(sumSaldoCreditoChar, '0'), 
                case when sumSaldoCreditoChar is null then '0' else sumSaldoCreditoChar end,
                --NVL(sumSaldoDebitoChar, '0');
                case when sumSaldoDebitoChar is null then '0' else sumSaldoDebitoChar end;

    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_creditos_cat (fechaInicial CHAR(10), fechaFinal CHAR(10), origenEvento INTEGER, tipoEvento INTEGER, folioCsuac CHAR(20),  usuarioAnalista INTEGER, numCliente CHAR(9), estatusCorporativo INTEGER)
    RETURNING           CHAR(12)    AS folioCSUAC,
                        CHAR(20)    AS saldoCaptacion,
                        CHAR(20)    AS saldoCredito,
                        CHAR(200)   AS asignado,
                        CHAR(200)   AS origen,
                        CHAR(200)   AS evento,
                        CHAR (9)    AS numeroCliente,
                        CHAR(100)   AS estatusGeneral,
                        CHAR (20)   AS pkySolicitud;
--CHAR (1150) AS cadena_query                        
   --RETURNING           CHAR(1150)    AS Cadena_query;

    DEFINE resultado_cadena_concatenada  CHAR(1150);
    DEFINE query char (850);
    DEFINE pky_solicitud                    CHAR (20);
    DEFINE iSqlErr                          INTEGER;
    DEFINE resultado_folioCSUAC             CHAR(12);
    DEFINE resultado_saldoCaptacion         CHAR(20);
    DEFINE resultado_saldoCredito           CHAR(20);
    DEFINE resultado_asignado               CHAR(200);
    DEFINE resultado_origen                 CHAR(200);
    DEFINE resultado_evento                 CHAR(200);
    DEFINE resultado_numeroCliente          CHAR(9);
    DEFINE resultado_estatusGeneral         CHAR(100);
    DEFINE resultado_fkySolicitud           CHAR(20);
    DEFINE resultado_cuenta_cliente_fallecido  CHAR(20);
    DEFINE resultado_numeroProducto         CHAR(6);
    DEFINE resultado_nombreProducto         CHAR(60);
    DEFINE resultado_numeroCuenta           CHAR(30);
    DEFINE resultado_numeroTarjeta          CHAR(30);
    

    

    LET resultado_folioCSUAC        = '';
    LET resultado_saldoCaptacion    = '0';
    LET resultado_saldoCredito      = '0';
    LET resultado_asignado          = '';
    LET resultado_origen            = '';
    LET resultado_evento            = '';
    LET resultado_numeroCliente     = '';
    LET resultado_estatusGeneral    = '';
    LET resultado_fkySolicitud      = '';
    LET resultado_cuenta_cliente_fallecido = '';
    LET resultado_numeroProducto = '';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_numeroTarjeta = '';
    LET resultado_cadena_concatenada = '';
    LET query = 'SELECT pky_solicitud, TRIM(num_cliente), folio_csuac, (select nombre from fal_cat_evento where pky_evento = fky_evento) as evento,  (select nombre from fal_cat_origen_evento where pky_origen_evento = fky_origen_evento) as origen , (select nombre from fal_cat_estatus_general where pky_estatus_general = fky_estatus_general) as estatus_general, (select nombre from acl_usuario where pky_usuario=fky_usuario_analista) as analista  FROM fal_solicitud WHERE fky_estatus_general NOT IN(1)';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN 
            ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_cadena_concatenada = '';
                    LET resultado_folioCSUAC        = '';
                    LET resultado_saldoCaptacion    = '';
                    LET resultado_saldoCredito      = '';
                    LET resultado_asignado          = '';
                    LET resultado_origen            = '';
                    LET resultado_evento            = '';
                    LET resultado_numeroCliente     = '';
                    LET resultado_estatusGeneral    = '';
                    LET resultado_fkySolicitud      = '';
                    RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud;
                    --return resultado_cadena_concatenada;
                END IF;
            END EXCEPTION;
            
             LET fechaInicial        = CASE WHEN length(case when fechaInicial is null then '' else fechaInicial end)>0 THEN fechaInicial ELSE NULL END;
             --LET fechaInicial        = CASE WHEN length(NVL(fechaInicial,''))>0 THEN fechaInicial ELSE NULL END;
             LET fechaFinal          = CASE WHEN length(case when fechaFinal is null then '' else fechaFinal end)>0 THEN fechaFinal ELSE NULL END;
             --LET fechaFinal          = CASE WHEN length(NVL(fechaFinal,''))>0 THEN fechaFinal ELSE NULL END;
             LET origenEvento        = CASE WHEN (case when origenEvento is null then 0 else origenEvento end)>0 THEN origenEvento ELSE NULL END;
             --LET origenEvento        = CASE WHEN NVL(origenEvento, 0)>0 THEN origenEvento ELSE NULL END;
             LET tipoEvento          = CASE WHEN (case when tipoEvento is null then 0 else tipoEvento end)>0 THEN tipoEvento ELSE NULL END;
             --LET tipoEvento          = CASE WHEN NVL(tipoEvento, 0)>0 THEN tipoEvento ELSE NULL END;
             LET folioCsuac          = CASE WHEN length(case when folioCsuac is null then '' else folioCsuac end)>0 THEN folioCsuac ELSE NULL END;
             --LET folioCsuac          = CASE WHEN length(NVL(folioCsuac,''))>0 THEN folioCsuac ELSE NULL END;
             LET usuarioAnalista     = CASE WHEN (case when usuarioAnalista is null then 0 else usuarioAnalista end)>0 THEN usuarioAnalista ELSE NULL END;
             --LET usuarioAnalista     = CASE WHEN NVL(usuarioAnalista, 0)>0 THEN usuarioAnalista ELSE NULL END;
             LET numCliente          = CASE WHEN length(case when numCliente is null then '' else numCliente end)>0 THEN numCliente ELSE NULL END;
             --LET numCliente          = CASE WHEN length(NVL(numCliente, ''))>0 THEN numCliente ELSE NULL END;
             LET estatusCorporativo  = CASE WHEN (case when estatusCorporativo is null then 0 else estatusCorporativo end)>0 THEN estatusCorporativo ELSE NULL END;
             --LET estatusCorporativo  = CASE WHEN NVL(estatusCorporativo, 0)>0 THEN estatusCorporativo ELSE NULL END;

             
             
             IF fechaInicial IS NOT NULL AND fechaFinal IS NOT NULL THEN
                LET resultado_cadena_concatenada = "AND fecha_ingreso BETWEEN TO_DATE ('" || fechaInicial || "' ,'%d/%m/%Y') AND TO_DATE('" ||  fechaFinal || "','%d/%m/%Y') " ||resultado_cadena_concatenada;
             END IF;

             IF origenEvento IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_origen_evento = ' || origenEvento || ' ' ||resultado_cadena_concatenada;
             END IF;             

             IF tipoEvento IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_evento = ' || tipoEvento || ' ' ||resultado_cadena_concatenada;
             END IF;

             IF folioCsuac IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND folio_csuac = "' || TRIM (folioCsuac) || '" ' ||resultado_cadena_concatenada;
             END IF;

             IF usuarioAnalista IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND fky_usuario_analista = ' || usuarioAnalista || ' ' ||resultado_cadena_concatenada;
             END IF;
             
             --IF estatusCorporativo IS NOT NULL THEN
                --LET resultado_cadena_concatenada = ' AND fky_estatus_corporativo = ' || estatusCorporativo || ' ' ||resultado_cadena_concatenada;
             --END IF;
             
             IF numCliente IS NOT NULL THEN
                LET resultado_cadena_concatenada = ' AND num_cliente = "' || TRIM(numCliente) || '" ' ||resultado_cadena_concatenada;
             END IF;
            
             LET resultado_cadena_concatenada = TRIM (query) || ' '|| TRIM (resultado_cadena_concatenada);
             
             PREPARE stmt_id FROM resultado_cadena_concatenada;
             DECLARE cust_cur cursor FOR stmt_id;

             OPEN cust_cur;
               
                WHILE (1 = 1)
                    FETCH cust_cur INTO resultado_fkySolicitud, resultado_numeroCliente, resultado_folioCSUAC, resultado_evento, resultado_origen, resultado_estatusGeneral, resultado_asignado;
                    IF (SQLCODE != 100) THEN
                               IF estatusCorporativo > 1 THEN
                                   SELECT cuenta_cliente_fallecido 
                                   INTO resultado_cuenta_cliente_fallecido
                                   FROM fal_control_tramite 
                                   WHERE fky_estatus_corporativo = estatusCorporativo
                                   AND fky_solicitud = resultado_fkySolicitud
                                   AND fky_tipo_tramite = 2;
                                   IF resultado_cuenta_cliente_fallecido IS NOT NULL THEN
                                        CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                        returning resultado_saldoCaptacion, resultado_saldoCredito;
                                        RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                   END IF
                            --ESTATUS DE NOTIFICACIÓN
                            ELIF estatusCorporativo = 1 THEN
                                SELECT cuenta_cliente_fallecido 
                                INTO resultado_cuenta_cliente_fallecido
                                FROM fal_control_tramite 
                                WHERE fky_solicitud = resultado_fkySolicitud
                                AND fky_tipo_tramite = 2;
                                IF resultado_cuenta_cliente_fallecido IS NULL THEN
                                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(resultado_numeroCliente, 0) )
                                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto);
                                    IF (resultado_numeroproducto IS NOT NULL AND resultado_numeroproducto <> '' ) THEN
                                         CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                             returning resultado_saldoCaptacion, resultado_saldoCredito;
                                         RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                    END IF
                            END IF
                            ELSE
                               SELECT cuenta_cliente_fallecido 
                               INTO resultado_cuenta_cliente_fallecido
                               FROM fal_control_tramite 
                               WHERE fky_solicitud = resultado_fkySolicitud
                               AND fky_tipo_tramite = 2;
                               IF resultado_cuenta_cliente_fallecido IS NOT NULL THEN
                                    CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                    returning resultado_saldoCaptacion, resultado_saldoCredito;
                                    RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                               ELSE
                                    SELECT numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto
                                    INTO resultado_numeroProducto, resultado_nombreProducto, resultado_numeroCuenta, resultado_numeroTarjeta
                                    FROM TABLE( FUNCTION sp_fal_busca_producto_cred_cliente(resultado_numeroCliente, 0) )
                                    AS a(numeroProducto, nombreProducto, cuentaProducto, tarjetaProducto);
                                    IF (resultado_numeroproducto IS NOT NULL AND resultado_numeroproducto <> '' ) THEN
                                         CALL sp_fal_saldos_deb_cre_cliente(resultado_numeroCliente)
                                         returning resultado_saldoCaptacion, resultado_saldoCredito;
                                         RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
                                    END IF
                               END IF
                            END IF
                     ELSE
                            EXIT;
                     END IF
                END WHILE
             CLOSE cust_cur;
             FREE cust_cur;
             FREE stmt_id ;
 --      RETURN resultado_folioCSUAC , resultado_saldoCaptacion , resultado_saldoCredito , resultado_asignado , resultado_origen, resultado_evento, resultado_numeroCliente, resultado_estatusGeneral, resultado_fkySolicitud WITH RESUME;
      --return resultado_cadena_concatenada;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_cancelacion_cuentas_manual(

pSucursal CHAR(4),
pCuenta CHAR(20),
pPromotor CHAR(8),
pSupervisor CHAR(8),
pky_resolucion INTEGER,
p_idSolicitud INTEGER,
pEmpresa CHAR(3),
pMotivo CHAR(2),
pTipoCuenta INTEGER)

  RETURNING CHAR(6) as codigoRetorno, CHAR(250) as mensajeRetorno;


DEFINE codigoRetorno        CHAR(6);
DEFINE mensajeRetorno       CHAR(250);
DEFINE tipoCuentaCredito    INTEGER;
DEFINE cancelacionManual    INTEGER;
DEFINE resultado_pky_usuario INTEGER;
DEFINE resultado_foliocsuac CHAR (11);

DEFINE iSqlErr              INTEGER;

--Variables de retorno Credito

DEFINE codigoRetornoCrd CHAR(6);
DEFINE mensajeRetornoCrd CHAR(250);
DEFINE numeroCredito CHAR(20);
DEFINE numeroTarjeta CHAR(16);

DEFINE codigoRetornoDeb CHAR(6);
DEFINE mensajeRetornoDeb CHAR(250);


--Obteniendo pky de cuenta de crédito
LET tipoCuentaCredito = (SELECT pky_tipo_tramite from fal_cat_tipo_tramite where nombre ='Crédito');
LET resultado_pky_usuario = (SELECT pky_usuario FROM acl_usuario where usuario= pPromotor);
LET cancelacionManual ='1';
LET resultado_foliocsuac = (select folio_csuac from fal_solicitud WHERE pky_solicitud = p_idSolicitud);

--SET DEBUG FILE TO "/home/rtechno/logSPFallecidos/sp_fal_cancelacion_cuentas_manual"||p_idSolicitud||".out"; 
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
BEGIN

 ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                
                RETURN  iSqlErr,'Error SQL'; --RETURNING
            END IF;
 END EXCEPTION;

    -- VALIDACIÓN DE CANCELACIÓN PARA CREDITO

    IF (pTipoCuenta = tipoCuentaCredito) THEN 
        
            CALL sp_fal_cancelacion_cuenta_credito(p_idSolicitud,pCuenta,pPromotor,pSupervisor,pSucursal,pky_resolucion,'1')
            RETURNING codigoRetornoCrd,mensajeRetornoCrd,numeroCredito,numeroTarjeta;

            IF(codigoRetornoCrd = '000000') THEN 
                
                INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' se ha cancelado exitosamente.',today,resultado_foliocsuac,'CANCELACION MANUAL CREDITO EXITOSA',resultado_pky_usuario,pPromotor);
                
                UPDATE fal_control_tramite SET fecha_cancelacion = CURRENT WHERE cuenta_cliente_fallecido = pCuenta;

                LET codigoRetorno = '000000';
                LET mensajeRetorno = 'Se ha cancelado exitosamente la cuenta.';
                
                ELSE IF (codigoRetornoCrd <> '000000') THEN 

                    INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                    VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' no se ha cancelado.',today,resultado_foliocsuac,'CANCELACION MANUAL CREDITO NO EXITOSA',resultado_pky_usuario,pPromotor);
                    
                LET codigoRetorno = '000001';
                LET mensajeRetorno = 'No se cancelo exitosamente la cuenta.';    
                END IF;

                RETURN codigoRetorno,mensajeRetorno;
            END IF;

        ELSE IF (pTipoCuenta <> tipoCuentaCredito) THEN
      
                CALL "informix".sp_fal_cancelacion_cuenta_debito( pEmpresa,pCuenta, pMotivo,pPromotor,pSucursal)
                RETURNING codigoRetornoDeb,mensajeRetornoDeb;

                    IF(codigoRetornoDeb = '069') THEN
                
                            INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                            VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' se ha cancelado exitosamente.',today,resultado_foliocsuac,'CANCELACION MANUAL EXITOSA',resultado_pky_usuario,pPromotor);

                            UPDATE fal_control_tramite SET fecha_cancelacion = CURRENT WHERE cuenta_cliente_fallecido = pCuenta;

                            LET codigoRetorno = '000000';
                            LET mensajeRetorno = 'Se ha cancelado exitosamente la cuenta.';
                
                
                     ELSE IF (codigoRetornoDeb <> '069') THEN 

                        INSERT INTO fal_historico_solicitud (pky_historico_solicitud,fky_solicitud,descripcion,fecha_hora,folio_csuac,accion_realizo,fky_usuario,numero_empleado)
                        VALUES (FAL_HISTORICO_SOLICITUD_SEQ.nextval,p_idSolicitud,'Cancelación manual: La cuenta '||pCuenta||' no se ha cancelado.',today,resultado_foliocsuac,'CANCELACION MANUAL NO EXITOSA',resultado_pky_usuario,pPromotor);
                        
                        LET codigoRetorno = '000001';
                        LET mensajeRetorno = 'No se cancelo exitosamente la cuenta.';

                      END IF;                  END IF; -- Cancelacion correcta de debito.
            RETURN codigoRetorno,mensajeRetorno;        END IF;    END IF;END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_buscarclientespornumero (p_sNumeroCliente CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
    DEFINE resultado_primerNombre		CHAR(30);
    DEFINE resultado_segundoNombre		CHAR(30);
    DEFINE resultado_numerotransfer     CHAR(30);

    DEFINE iSqlErr                      INTEGER;

     	-- Inicializacion de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';

                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

	SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE p_sNumeroCliente = numcte and tipo_cliente=1;


   IF ( resultado_primerNombre IS NULL) THEN

      SELECT bditransfer:tf_maecte.numcte
      INTO resultado_numerotransfer
         FROM bditransfer:tf_maecte
        WHERE bditransfer:tf_maecte.numcte_tf = p_sNumeroCliente;

     SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE resultado_numerotransfer = numcte and tipo_cliente=1;


    END IF;



   RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;



	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_buscarclientesportelefonotransfer (p_sNumeroTelefonoTransfer CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE telefono_Transfer		CHAR(30);
	DEFINE iSqlErr                     	INTEGER;

    -- Inicialización de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
	LET telefono_Transfer = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

            SELECT numcte
            INTO resultado_numeroCliente
            FROM bditransfer:tf_maecte
            WHERE empresa = '001'
              AND telefono = p_sNumeroTelefonoTransfer;



		IF ( resultado_numeroCliente IS NULL ) THEN
           let resultado_numeroCliente = '';
        ELSE
            SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
              INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
              FROM bdinteg:si_cliente
             WHERE numcte = resultado_numeroCliente
             AND tipo_cliente=1;
{
            IF ( resultado_numeroCliente IS NULL ) THEN

				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';

            END IF;
}
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'Creación		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH
   
            SELECT DISTINCT qc.producto as numeroProducto, 
                        pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )                
                        WHERE qc.num_cte = p_sNumeroCliente
                        AND qc.status_cta not in (2)
/*
                    SELECT monto_original
                    INTO v_monto_original
                    FROM fal_control_tramite fct
                    WHERE fct.cuenta_cliente_fallecido = qc. cuenta
                    AND tramite = 1;

                    IF v_monto_original <> NULL THEN
                        LET 
                    ELSE
                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;
                    END IF*/
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;
        
        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido_1(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH

                SELECT DISTINCT qc.producto as numeroProducto, 
                pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )
                        INNER JOIN bdicheq:"informix".sc_maechq cd ON cd.cuenta = mae.cuentadep
                        INNER JOIN fal_control_tramite con ON con.cuenta_cliente_fallecido = qc.cuenta
                        WHERE qc.num_cte = p_sNumeroCliente 
                        AND cd.status_cta not in( 2)
                        AND qc.status_cta = 2
                        AND pr.producto = '1100'


                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;

        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_mueve_aclaraciones_historico_pendiente()

RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE v_pky_aclaracion CHAR(20);
DEFINE icontador        INTEGER;
DEFINE v_folio_csuac    VARCHAR(11);
DEFINE v_sol_eglobal    INTEGER;
DEFINE v_res_eglobal    INTEGER;
DEFINE v_fecha_limit    DATE;
DEFINE vsql	        	char(3000);
Define cCadena 			CHAR(1000);
DEFINE respuesta_repetida_e_global	INTEGER;
DEFINE solicitud_faltante_e_global	INTEGER;
DEFINE cRuta CHAR(100);
DEFINE horaActual     datetime year to fraction;
DEFINE horafinal     datetime year to fraction;
DEFINE v_pky_movimiento CHAR(20);
DEFINE v_pky_movimiento2 CHAR(20);
DEFINE v_pky_bitacora CHAR(20);
DEFINE v_resul_mov INTEGER;

LET v_resul_mov = NULL;
LET scod_ret  = "00000";
LET vsqlerr = 0;
LET icontador=1;
		--SET DEBUG FILE TO "/ifxsif01/reydavid/mover.out";
		--TRACE ON;
		
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_2') THEN
			DROP TABLE "informix".temp_mov_2;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_bitacora') THEN
			DROP TABLE "informix".temp_bitacora;
		END IF;
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov') THEN
			DROP TABLE "informix".temp_mov;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_3') THEN
			DROP TABLE "informix".temp_mov_3;
		END IF;

	CREATE /*TEMP*/ table temp_mov(
		pky_movimiento    integer,
		fky_padre integer);
---	CREATE /*TEMP*/ table temp_mov_2(
--		pky_movimiento    integer);
--	CREATE /*TEMP*/ table temp_mov_3(
--		pky_movimiento   integer,
--		fky_padre integer);
	CREATE /*TEMP*/ table temp_bitacora(
		pky_bitacora   integer);

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
	   LET scod_ret=vsqlerr;
	   ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;


			INSERT INTO temp_bitacora		
			select pky_bitacora from "informix".acl_sistema_bitacora_his;
----------------
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc; 
			--fky_padre is not null;
			INSERT INTO temp_mov
			SELECT pky_movimiento,fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc;
			--fky_padre is null;
			
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion is null and folio_csuac is null and fechahora <= (select last_day(add_months(((today) - 1 units year),-(month(today)))) from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc;
		
FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara 
		BEGIN WORK;	
			INSERT INTO "informix".acl_documento_his 
			select * from "informix".acl_documento WHERE fky_aclaracion =v_pky_aclaracion and folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara
		BEGIN WORK;	
        		 --********************Eliminacion de historico en entrada bitacora
			delete from "informix".acl_entrada_bitacora WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_documento WHERE  fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_recuperacion_saldos WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de solicitud E-GALOBAL
			--********************Eliminacion de historico de control de aclaraciones via telefonica
			delete from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de regulatorio 27
			delete from "informix".acl_regulatorio27 WHERE folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov where fky_padre is not null --order by pky_movimiento desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			UPDATE "informix".acl_movimiento SET fky_padre = NULL WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov order by fky_padre desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			delete from "informix".acl_movimiento WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD		
			select pky_solicitud_e_global
			into v_sol_eglobal
			from temp_solic
		BEGIN WORK;	
			--********************Eliminacion de historico de Solicitud E-GALOBAL
			delete from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global = v_sol_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD		
			select pky_respuesta_e_global
			into v_res_eglobal
			from temp_respues
		BEGIN WORK;	
    	--********************Eliminacion de historico de respuesta E-GALOBAL
			delete from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global = v_res_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion
			into v_pky_aclaracion
			from temp_aclara
		BEGIN WORK;	
		---********* Se elimina la informacion principal de aclaraciones********
			delete from "informix".acl_aclaracion WHERE  pky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;
			
FOREACH WITH HOLD
			select pky_bitacora
			into v_pky_bitacora
			from temp_bitacora
		BEGIN WORK;		
			--------------------Elimina historico del bitacora del sistema----------------------
			delete from "informix".acl_sistema_bitacora WHERE pky_bitacora = v_pky_bitacora;
		COMMIT WORK;
END FOREACH;

RETURN scod_ret;
END
END PROCEDURE;
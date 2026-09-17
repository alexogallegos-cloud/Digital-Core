CREATE PROCEDURE "informix".sp_consultabitacora_moves_admin(
    pIdAdmin CHAR(4),
    pRangoConsulta CHAR(1), -- si se selecciona alguna opción de fechas en los radio button/// ESTE ES EL BUENO////
    pFechaInicial DATE, -- fecha inicio calendario
    pFechaFinal DATE, -- fecha final calendario
    pPaginacion INTEGER)
  
    RETURNING CHAR(5),
    INTEGER,
    DATETIME year to second,
    CHAR(4),
    CHAR(9),
    CHAR(15),
    INTEGER,
    INTEGER,
    CHAR(10),
    CHAR(12),
    CHAR(12),
    CHAR(9),
    INTEGER,
    CHAR(50),
    CHAR(50),
    CHAR(50),
    CHAR(50),
    CHAR(50),
    CHAR(50),
    INTEGER;
  
	-- ****************************************************************************************************
	-- DESCRIPCION: Obtener la bitacora de las operaciones realizadas por el usuario Administradior
	-- AUTOR : Maritza Torres
	-- FECHA : 04/05/2018

	-- FECHA LIBERACIÓN PRODUCCIÓN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


--** Declaración de variables: algunas retornables **
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);	
--** Declaración de variables: manejar filtro por periodo seleccionado
	DEFINE vfecha_periodo_base DATE;
    DEFINE vfecha_periodo_inicio DATE;
    DEFINE vfecha_periodo_fin DATE;
    DEFINE vfecha_format CHAR(8);		
--** Declaración de variables: para almacenar los valores de retorno
    DEFINE vid_bitacora_admin INTEGER;
	DEFINE vfecha_oper DATETIME year to second;
    DEFINE vfecha_aplic DATE;
    DEFINE vnum_cliente CHAR(9);
    DEFINE vip_usuario CHAR(15);
    DEFINE vid_admin INTEGER;
    DEFINE vid_operador INTEGER;
    DEFINE vcuenta_origen CHAR(12);
    DEFINE vdestino CHAR(12);
    DEFINE vtoken CHAR(9);
    DEFINE vid_cat_oper INTEGER;
    DEFINE vnombre_corto CHAR(50);
    DEFINE vcgenerico1 CHAR(50);
    DEFINE vcgenerico2 CHAR(50);
    DEFINE vcgenerico3 CHAR(50);
    DEFINE vcgenerico4 CHAR(50);
    DEFINE vcgenerico5 CHAR(50);
    DEFINE vid_operacion CHAR(4);	
--**variable para la paginacion
    DEFINE vnum_reg_xpag INTEGER;
    DEFINE vtotal_registros INTEGER;

--**
    LET cod_ret = '00000'; -- Consulta exitosa
	LET vfecha_periodo_base = EXTEND(MDY(MONTH(TODAY),DAY(TODAY),YEAR(TODAY)));
    LET vfecha_periodo_inicio = TODAY;
    LET vfecha_periodo_fin = TODAY;
    LET vfecha_format = '%d/%m/%Y';
    LET vid_bitacora_admin = 0;
    LET vfecha_oper = CURRENT;
    LET vcuenta_origen = '';
    LET vdestino = '';
    LET vnum_cliente = '';
    LET vip_usuario = '';
    LET vid_admin = 0;
    LET vid_operador = 0;
    LET vfecha_aplic = TODAY;
    LET vtoken = '';
    LET vid_cat_oper =0;
    LET vnombre_corto ='';
    LET vcgenerico1 = '';
    LET vcgenerico2 = '';
    LET vcgenerico3 = '';
    LET vcgenerico4 = '';
    LET vcgenerico5 = '';
    LET vid_operacion = '';
    LET vtotal_registros = 0;
    LET vnum_reg_xpag = 10;
    LET pPaginacion = pPaginacion * vnum_reg_xpag;

BEGIN
     ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
        LET cod_ret = sql_err;
        RETURN
          cod_ret,
          NVL(vid_bitacora_admin, 0),
          NVL(vfecha_oper, SYSDATE),
          NVL(vid_operacion, ''),
          NVL(vnum_cliente, ''),
          NVL(vip_usuario, ''),                                                                                                                                                                                                                                                                
          NVL(vid_admin, 0),
          NVL(vid_operador, 0), 
          NVL(vfecha_aplic, ''),
          NVL(vcuenta_origen, ''),
          NVL(vdestino, ''),
          NVL(vtoken, ''),
          NVL(vid_cat_oper, 0),
          NVL(vnombre_corto, ''),
          NVL(vcgenerico1, ''),
          NVL(vcgenerico2, ''),
          NVL(vcgenerico3, ''),
          NVL(vcgenerico4, ''),
          NVL(vcgenerico5, ''),
          NVL(vtotal_registros, 0);
      END IF;
    END EXCEPTION;

	

--**Validacion de parametros
    IF (pIdAdmin IS NULL OR pRangoConsulta IS NULL) THEN
		LET cod_ret = '00100'; -- Parametros incorrectos
		 RETURN
            cod_ret,
            NVL(vid_bitacora_admin, 0),
            NVL(vfecha_oper, SYSDATE),
            NVL(vid_operacion, ''),
            NVL(vnum_cliente, ''),
            NVL(vip_usuario, ''),                                                                                                                                                                                                                                                                
            NVL(vid_admin , 0),
            NVL(vid_operador, 0), 
            NVL(vfecha_aplic, ''),
            NVL(vcuenta_origen, ''),
            NVL(vdestino, ''),
            NVL(vtoken, ''),
            NVL(vid_cat_oper, 0),
            NVL(vnombre_corto, ''),
            NVL(vcgenerico1, ''),
            NVL(vcgenerico2, ''),
            NVL(vcgenerico3, ''),
            NVL(vcgenerico4, ''),
            NVL(vcgenerico5, ''),
            NVL(vtotal_registros, 0);
    END IF;

	--**Para no considerar filas fantasmas
    SET ISOLATION TO DIRTY READ;
	--**Para esperar 3 segundos para ver si el lock es removido y no mandar error por default si el proceso encuentra un lock
  	SET LOCK MODE TO WAIT 3;

--**Condicionales para obtener la fecha inicial y final para la consulta
    -- Hoy
    IF (pRangoConsulta = '1') THEN
        LET vfecha_periodo_inicio = TODAY;
        LET vfecha_periodo_fin = TODAY;
    -- Ultimos 3 días
    ELIF (pRangoConsulta = '2') THEN
        LET vfecha_periodo_inicio = EXTEND(MDY(MONTH(TODAY),DAY(TODAY),YEAR(TODAY))-3);
        LET vfecha_periodo_fin = TODAY;
    -- Ultimos 7 días
    ELIF (pRangoConsulta = '3') THEN
        LET vfecha_periodo_inicio = EXTEND(MDY(MONTH(TODAY),DAY(TODAY),YEAR(TODAY))-7);
        LET vfecha_periodo_fin = TODAY;
    -- Ultimos 30 días
    ELIF (pRangoConsulta = '4') THEN
        LET vfecha_periodo_inicio =  EXTEND(MDY(MONTH(TODAY),DAY(TODAY),YEAR(TODAY))-30);
        LET vfecha_periodo_fin = TODAY;
    ELIF (pRangoConsulta = '') THEN
        LET vfecha_periodo_inicio =  pFechaInicial;
        LET vfecha_periodo_fin = pFechaFinal;
    END IF;

--------------------------------------------------------------------------------back dates---------------------------------------------------------------------------

        SELECT
            NVL(COUNT(id_bitacora_admin), 0)
            INTO
            vtotal_registros
        FROM bdibei:"informix".bei_bitacora_admin
            WHERE id_admin = pIdAdmin
            AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vid_bitacora_admin, 0),
              NVL(vfecha_oper, SYSDATE),
              NVL(vid_operacion, ''),
              NVL(vnum_cliente, ''),
              NVL(vip_usuario, ''),                                                                                                                                                                                                                                                                
              NVL(vid_admin , 0),
              NVL(vid_operador, 0), 
              NVL(vfecha_aplic, ''),
              NVL(vcuenta_origen, ''),
              NVL(vdestino, ''),
              NVL(vtoken, ''),
              NVL(vid_cat_oper, 0),
              NVL(vnombre_corto, ''),
              NVL(vcgenerico1, ''),
              NVL(vcgenerico2, ''),
              NVL(vcgenerico3, ''),
              NVL(vcgenerico4, ''),
              NVL(vcgenerico5, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                t1.id_bitacora_admin,
                t1.fecha_oper,
                t1.id_operacion,
                t1.num_cliente,
                t1.ipusuario,
                t1.id_admin,
                t1.id_operador,
                t1.fecha_aplic,
                t1.cuenta_origen,
                t1.destino,
                t1.token,
                t2.id_cat_oper,
                t2.nombre_corto,
                t1.cgenerico1,
                t1.cgenerico2,
                t1.cgenerico3,
                t1.cgenerico4,
                t1.cgenerico5
              INTO
                vid_bitacora_admin,
                vfecha_oper,
                vid_operacion,
                vnum_cliente,
                vip_usuario,                                                                                                                                                                                                                                                                
                vid_admin,
                vid_operador, 
                vfecha_aplic,
                vcuenta_origen,
                vdestino,
                vtoken,
                vid_cat_oper,
                vnombre_corto,
                vcgenerico1,
                vcgenerico2,
                vcgenerico3,
                vcgenerico4,
                vcgenerico5
              FROM bdibei:"informix".bei_bitacora_admin t1
              INNER JOIN bdibei:bei_cat_operaciones t2 on t1.id_operacion=t2.id_cat_oper
                WHERE t1.id_admin = pIdAdmin
                AND t1.fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
                ORDER BY t1.fecha_oper DESC

            RETURN   
                cod_ret,
                NVL(vid_bitacora_admin, 0),
                NVL(vfecha_oper, SYSDATE),
                NVL(vid_operacion, ''),
                NVL(vnum_cliente, ''),
                NVL(vip_usuario, ''),                                                                                                                                                                                                                                                                
                NVL(vid_admin , 0),
                NVL(vid_operador, 0), 
                NVL(vfecha_aplic, ''),
                NVL(vcuenta_origen, ''),
                NVL(vdestino, ''),
                NVL(vtoken, ''),
                NVL(vid_cat_oper, 0),
                NVL(vnombre_corto, ''),
                NVL(vcgenerico1, ''),
                NVL(vcgenerico2, ''), 
                NVL(vcgenerico3, ''),
                NVL(vcgenerico4, ''),
                NVL(vcgenerico5, ''),
                NVL(vtotal_registros, 0)
                WITH RESUME;
          END FOREACH;   

END	
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consultabitacora_emp(
  idUsuario CHAR(4),
  pIdOperacion CHAR(4),
  pIdOperacionFch CHAR(4),
  pcvePago CHAR(4),
  pTipoConsulta CHAR(1),
  pFechaConsulta CHAR(10),
  pPaginacion INT)

  RETURNING CHAR(5) AS CodRet,
  DATETIME year to second AS FechaOper,
  CHAR(10) AS FechaApli,
  CHAR(12) AS CtaOrigen,
  CHAR(20) AS CtaDesti,
  CHAR(16) AS Monto,
  CHAR(16) AS SecTrans,
  CHAR(100) AS Cgen1,
  CHAR(200) AS Cgen2,
  CHAR(60) AS Cgen3,
  CHAR(60) AS Cgen4,
  CHAR(60) AS Cgen5,
  CHAR(100) AS Cgen6,
  CHAR(100) AS Referencia,
  CHAR(16) AS Folio,
  CHAR(4) AS IDoperacion,
  INT AS TotalRenglones;

-- ****************************************************************************************************
-- DESCRIPCION: Obtener el detalle de las operaciones para reimpresion de comprobante
-- AUTOR : Lili PV
-- FECHA : 28/Sept/2017
-- BD: bdibei
-- FECHA DE LIBERACIÃN:
-- ****************************************************************************************************


    -- *** declaracion de variables ***
    -- variables para el manejo de errores
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR (5);

    -- variables para manejar el filtro por periodo seleccionado
    DEFINE vfecha_periodo_base DATE;
    DEFINE vfecha_periodo_inicio DATE;
    DEFINE vfecha_periodo_fin DATE;
    DEFINE vfecha_format CHAR(8);

    -- variables para almacenar los valores de retorno
    DEFINE vfecha_oper DATETIME year to second;
    DEFINE vfecha_apli DATE;
    DEFINE vcuenta_origen CHAR(12);
    DEFINE vdestino CHAR(20);
    DEFINE vmonto CHAR(16);
    DEFINE vsec_transaccion CHAR(16);
    DEFINE vcgenerico1 CHAR(100);
    DEFINE vcgenerico2 CHAR(200);
    DEFINE vcgenerico3 CHAR(60);
    DEFINE vcgenerico4 CHAR(60);
    DEFINE vcgenerico5 CHAR(60);
    DEFINE vcgenerico6 CHAR(100);
    DEFINE vreferencia CHAR(100);
    DEFINE vfolio CHAR(16);
    DEFINE vid_operacion CHAR(4);

    -- variable para la paginacion
    DEFINE vnum_reg_xpag INTEGER;
    DEFINE vtotal_registros INTEGER;

    -- *** inicializacion de variables ***
    LET cod_ret = '00000'; -- Consulta exitosa

    LET vfecha_periodo_base =  EXTEND(MDY(MONTH(TODAY),1,YEAR(TODAY)));
    LET vfecha_periodo_inicio = TODAY;
    LET vfecha_periodo_fin = TODAY;
    LET vfecha_format = '%d/%m/%Y';

    LET vfecha_oper = CURRENT;
    LET vfecha_apli = '';
    LET vcuenta_origen = '';
    LET vdestino = '';
    LET vmonto = '0.00';
    LET vsec_transaccion = '';
    LET vcgenerico1 = '';
    LET vcgenerico2 = '';
    LET vcgenerico3 = '';
    LET vcgenerico4 = '';
    LET vcgenerico5 = '';
    LET vcgenerico6 = '';
    LET vreferencia = '';
    LET vfolio = '';
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
          NVL(vfecha_oper, CURRENT),
          NVL(vfecha_apli, ''),
          NVL(vcuenta_origen, ''),
          NVL(vdestino, ''),
          NVL(vmonto, '0.00'),
          NVL(vsec_transaccion, ''),
          NVL(vcgenerico1, ''),
          NVL(vcgenerico2, ''),
          NVL(vcgenerico3, ''),
          NVL(vcgenerico4, ''),
          NVL(vcgenerico5, ''),
          NVL(vcgenerico6, ''),
          NVL(vreferencia, ''),
          NVL(vfolio, ''),
          NVL(vid_operacion, ''),
          NVL(vtotal_registros, 0);
      END IF;
    END EXCEPTION;

    -- Validacion de parametros
    IF (idUsuario IS NULL OR pIdOperacion IS NULL OR pTipoConsulta IS NULL) THEN
		LET cod_ret = '00100'; -- Parametros incorrectos
		 RETURN
          cod_ret,
          NVL(vfecha_oper, CURRENT),
          NVL(vfecha_apli, ''),
          NVL(vcuenta_origen, ''),
          NVL(vdestino, ''),
          NVL(vmonto, '0.00'),
          NVL(vsec_transaccion, ''),
          NVL(vcgenerico1, ''),
          NVL(vcgenerico2, ''),
          NVL(vcgenerico3, ''),
          NVL(vcgenerico4, ''),
          NVL(vcgenerico5, ''),
          NVL(vcgenerico6, ''),
          NVL(vreferencia, ''),
          NVL(vfolio, ''),
          NVL(vid_operacion, ''),
          NVL(vtotal_registros, 0);
    END IF;


    -- Para no considerar filas fantasmas
    SET ISOLATION TO DIRTY READ;
    -- Para esperar 3 segundos para ver si el lock es removido y no mandar error por default si el proceso encuentra un lock
  	SET LOCK MODE TO WAIT 3;

    -- Condicionales para obtener la fecha inicial y final para la consulta
    -- Si el periodo es dia
    IF (pTipoConsulta = '1') THEN
        LET vfecha_periodo_inicio = TO_DATE(pFechaConsulta, vfecha_format);
        LET vfecha_periodo_fin = TO_DATE(pFechaConsulta, vfecha_format);
    -- Si el periodo es mes actual
    ELIF (pTipoConsulta = '2') THEN
        LET vfecha_periodo_inicio = vfecha_periodo_base;
        LET vfecha_periodo_fin = TODAY;
    -- Si el periodo es mes anterior
    ELIF (pTipoConsulta = '3') THEN
        LET vfecha_periodo_inicio = ADD_MONTHS(vfecha_periodo_base, -1);
        LET vfecha_periodo_fin = TODAY;
    -- Si el periodo es 2 meses anteriores
    ELIF (pTipoConsulta = '4') THEN
        LET vfecha_periodo_inicio = ADD_MONTHS(vfecha_periodo_base, -2);
        LET vfecha_periodo_fin = TODAY;
    -- Si el periodo es 3 meses anteriores
    ELIF (pTipoConsulta = '5') THEN
        LET vfecha_periodo_inicio = ADD_MONTHS(vfecha_periodo_base, -3);
        LET vfecha_periodo_fin = TODAY;
    END IF;

      -- Condicionales para obtener las operaciones por id de operacion
      -- Inicio IF pIdOperacion
      IF (pIdOperacion = '1008') THEN -- Si la operacion es: Transferencia entre cuentas propias
          SELECT
            NVL(COUNT(id_operacion), 0)
          INTO
            vtotal_registros
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion, pIdOperacionFch)
              AND cgenerico2 != 'RC'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, CURRENT),
              NVL(vfecha_apli, ''),
              NVL(vcuenta_origen, ''),
              NVL(vdestino, ''),
              NVL(vmonto, '0.00'),
              NVL(vsec_transaccion, ''),
              NVL(vcgenerico1, ''),
              NVL(vcgenerico2, ''),
              NVL(vcgenerico3, ''),
              NVL(vcgenerico4, ''),
              NVL(vcgenerico5, ''),
              NVL(vcgenerico6, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                fecha_oper,
                fecha_aplic,
                cuenta_origen,
                destino,
                monto_oper,
                sec_transaccion,
                cgenerico1,
                cgenerico2,
                id_operacion
              INTO
                vfecha_oper,
                vfecha_apli,
                vcuenta_origen,
                vdestino,
                vmonto,
                vsec_transaccion,
                vcgenerico5,
                vreferencia,
                vid_operacion
              FROM bdibei:"informix".bei_bitacora
                WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion, pIdOperacionFch)
                        AND cgenerico2 != 'RC'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, CURRENT),
                  NVL(TO_CHAR(vfecha_apli, '%d/%m/%Y'), ''),
                  NVL(vcuenta_origen, ''),
                  NVL(vdestino, ''),
                  NVL(TO_CHAR(vmonto, '#############.&&'), '0.00'),
                  NVL(vsec_transaccion, ''),
                  NVL(vcgenerico1, ''),
                  NVL(vcgenerico2, ''),
                  NVL(vcgenerico3, ''),
                  NVL(vcgenerico4, ''),
                  NVL(vcgenerico5, ''),
                  NVL(vcgenerico6, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      ELIF (pIdOperacion = '1016') THEN -- Si la operacion es: Transferencia a terceros
          SELECT
            NVL(COUNT(id_operacion), 0)
          INTO
            vtotal_registros
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion)
              AND cgenerico2 != 'RC'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, CURRENT),
              NVL(vfecha_apli, ''),
              NVL(vcuenta_origen, ''),
              NVL(vdestino, ''),
              NVL(vmonto, '0.00'),
              NVL(vsec_transaccion, ''),
              NVL(vcgenerico1, ''),
              NVL(vcgenerico2, ''),
              NVL(vcgenerico3, ''),
              NVL(vcgenerico4, ''),
              NVL(vcgenerico5, ''),
              NVL(vcgenerico6, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                fecha_oper,
                fecha_aplic,
                cuenta_origen,
                destino,
                monto_oper,
                sec_transaccion,
                cgenerico3,
                cgenerico1,
                cgenerico2,
                id_operacion
              INTO
                vfecha_oper,
                vfecha_apli,
                vcuenta_origen,
                vdestino,
                vmonto,
                vsec_transaccion,
                vcgenerico1,
                vcgenerico5,
                vreferencia,
                vid_operacion
              FROM bdibei:"informix".bei_bitacora
                WHERE id_usuario = idUsuario
                AND id_operacion IN (pIdOperacion)
                AND cgenerico2 != 'RC'
                AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, CURRENT),
                  NVL(TO_CHAR(vfecha_apli, '%d/%m/%Y'), ''),
                  NVL(vcuenta_origen, ''),
                  NVL(vdestino, ''),
                  NVL(TO_CHAR(vmonto, '#############.&&'), '0.00'),
                  NVL(vsec_transaccion, ''),
                  NVL(vcgenerico1, ''),
                  NVL(vcgenerico2, ''),
                  NVL(vcgenerico3, ''),
                  NVL(vcgenerico4, ''),
                  NVL(vcgenerico5, ''),
                  NVL(vcgenerico6, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      ELIF (pIdOperacion = '1015') THEN -- Si la operacion es: Transferencia SPEI
          SELECT
            NVL(COUNT(id_operacion), 0)
          INTO
            vtotal_registros
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion, pIdOperacionFch)
              AND cgenerico5 != 'RC'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, CURRENT),
              NVL(vfecha_apli, ''),
              NVL(vcuenta_origen, ''),
              NVL(vdestino, ''),
              NVL(vmonto, '0.00'),
              NVL(vsec_transaccion, ''),
              NVL(vcgenerico1, ''),
              NVL(vcgenerico2, ''),
              NVL(vcgenerico3, ''),
              NVL(vcgenerico4, ''),
              NVL(vcgenerico5, ''),
              NVL(vcgenerico6, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                fecha_oper,
                fecha_aplic,
                cuenta_origen,
                cgenerico2,
                monto_oper,
                sec_transaccion,
                cgenerico7,
                cgenerico5,
                cgenerico6,
                cgenerico9,
                cgenerico3,
                cgenerico8,
                cgenerico1,
                id_operacion
              INTO
                vfecha_oper,
                vfecha_apli,
                vcuenta_origen,
                vdestino,
                vmonto,
                vsec_transaccion,
                vcgenerico1,
                vcgenerico3,
                vcgenerico4,
                vcgenerico5,
                vcgenerico6,
                vreferencia,
                vfolio,
                vid_operacion
              FROM bdibei:"informix".bei_bitacora
                WHERE id_usuario = idUsuario
                AND id_operacion IN (pIdOperacion, pIdOperacionFch)
                AND cgenerico5 != 'RC'
                AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, CURRENT),
                  NVL(TO_CHAR(vfecha_apli, '%d/%m/%Y'), ''),
                  NVL(vcuenta_origen, ''),
                  NVL(vdestino, ''),
                  NVL(TO_CHAR(vmonto, '#############.&&'), '0.00'),
                  NVL(vsec_transaccion, ''),
                  NVL(vcgenerico1, ''),
                  NVL(vcgenerico2, ''),
                  NVL(vcgenerico3, ''),
                  NVL(vcgenerico4, ''),
                  NVL(vcgenerico5, ''),
                  NVL(vcgenerico6, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      ELIF (pIdOperacion = '310') THEN -- Si la operacion es: Pago de servicios
          SELECT
            NVL(COUNT(id_operacion), 0)
          INTO
            vtotal_registros
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              --AND id_operacion IN (pcvePago, pIdOperacionFch)
              AND id_operacion IN ('1020', '2020', '1021', '2021', '1022', '2022')
              AND cgenerico3 != 'RC'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, CURRENT),
              NVL(vfecha_apli, ''),
              NVL(vcuenta_origen, ''),
              NVL(vdestino, ''),
              NVL(vmonto, '0.00'),
              NVL(vsec_transaccion, ''),
              NVL(vcgenerico1, ''),
              NVL(vcgenerico2, ''),
              NVL(vcgenerico3, ''),
              NVL(vcgenerico4, ''),
              NVL(vcgenerico5, ''),
              NVL(vcgenerico6, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                fecha_oper,
                fecha_aplic,
                cuenta_origen,
                destino,
                monto_oper,
                sec_transaccion,
                cgenerico1,
                cgenerico3,
                id_operacion,
                cgenerico4
              INTO
                vfecha_oper,
                vfecha_apli,
                vcuenta_origen,
                vdestino,
                vmonto,
                vsec_transaccion,
                vcgenerico5,
                vreferencia,
                vid_operacion,
                vcgenerico1
              FROM bdibei:"informix".bei_bitacora
                WHERE id_usuario = idUsuario
                --AND id_operacion IN (pcvePago, pIdOperacionFch)
                AND id_operacion IN ('1020', '2020', '1021', '2021', '1022', '2022')
                AND cgenerico3 != 'RC'
                AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, CURRENT),
                  NVL(TO_CHAR(vfecha_apli, '%d/%m/%Y'), ''),
                  NVL(vcuenta_origen, ''),
                  NVL(vdestino, ''),
                  NVL(TO_CHAR(vmonto, '#############.&&'), '0.00'),
                  NVL(vsec_transaccion, ''),
                  NVL(vcgenerico1, ''),
                  NVL(vcgenerico2, ''),
                  NVL(vcgenerico3, ''),
                  NVL(vcgenerico4, ''),
                  NVL(vcgenerico5, ''),
                  NVL(vcgenerico6, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      END IF;  -- Fin IF pIdOperacion

END -- Fin cuerpo del sp
END PROCEDURE;
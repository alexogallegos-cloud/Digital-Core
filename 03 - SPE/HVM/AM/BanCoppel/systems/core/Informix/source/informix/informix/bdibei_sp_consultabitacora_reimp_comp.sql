CREATE PROCEDURE "informix".sp_consultabitacora_reimp_comp(
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
  CHAR(40) AS Cgen1,
  CHAR(40) AS Cgen2,
  CHAR(40) AS Cgen3,
  CHAR(40) AS Cgen4,
  CHAR(40) AS Cgen5,
  CHAR(40) AS Cgen6,
  CHAR(40) AS Cgen7,
  CHAR(40) AS Cgen8,
  CHAR(40) AS Cgen9,
  CHAR(40) AS Cgen10,
  CHAR(40) AS Referencia,
  CHAR(16) AS Folio,
  CHAR(4) AS IDoperacion,
  INT AS TotalRenglones;

-- ****************************************************************************************************
-- DESCRIPCION: Obtener el detalle de las operaciones para reimpresion de comprobante
-- AUTOR : Lili PV
-- FECHA : 28/Sept/2017
-- Modificacion: 23/Jul/2018 (Cambio de tamaño de valores de retorno para campos genericos)
-- BD: bdibei
-- FECHA DE LIBERACIÓN:
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
    DEFINE vcgenerico1 CHAR(40); --CHAR(100);
    DEFINE vcgenerico2 CHAR(40); --CHAR(200);
    DEFINE vcgenerico3 CHAR(40); --CHAR(60);
    DEFINE vcgenerico4 CHAR(40); --CHAR(60);
    DEFINE vcgenerico5 CHAR(40); --CHAR(60);
    DEFINE vcgenerico6 CHAR(40); --CHAR(100);
    DEFINE vcgenerico7 CHAR(40); --CHAR(100);
    DEFINE vcgenerico8 CHAR(40); --CHAR(100);
    DEFINE vcgenerico9 CHAR(40); --CHAR(100);
    DEFINE vcgenerico10 CHAR(40); --CHAR(100);
    DEFINE vreferencia CHAR(40); --CHAR(100);
    DEFINE vfolio CHAR(16);
    DEFINE vid_operacion CHAR(4);

    -- variable para la paginacion
    DEFINE vnum_reg_xpag SMALLINT;
    DEFINE vtotal_registros SMALLINT;
    DEFINE vtotal_registros1 SMALLINT;
    DEFINE vtotal_registros2 SMALLINT;

	
 --SET DEBUG FILE TO "/informix/aw/bdibei/datos.out";
 --TRACE ON;
 
 
 
    -- *** inicializacion de variables ***
    LET cod_ret = '00000'; -- Consulta exitosa

    -- LET vfecha_periodo_base = CAST(TO_CHAR(YEAR(TODAY)) || '-' || TO_CHAR(MONTH(TODAY)) || '-' || '01' AS DATE);
	LET vfecha_periodo_base = EXTEND(MDY(MONTH(TODAY),1,YEAR(TODAY)));
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
    LET vcgenerico7 = '';
    LET vcgenerico8 = '';
    LET vcgenerico9 = '';
    LET vcgenerico10 = '';
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
          NVL(vfecha_oper, SYSDATE),
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
          NVL(vcgenerico7, ''),
          NVL(vcgenerico8, ''),
          NVL(vcgenerico9, ''),
          NVL(vcgenerico10, ''),
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
          NVL(vfecha_oper, SYSDATE),
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
          NVL(vcgenerico7, ''),
          NVL(vcgenerico8, ''),
          NVL(vcgenerico9, ''),
          NVL(vcgenerico10, ''),
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
          SELECT COUNT(id_operacion) INTO  vtotal_registros1
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion, pIdOperacionFch)
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
			  
		  SELECT COUNT(id_operacion) INTO vtotal_registros2
          FROM bdibei:"informix".bei_bitacora_historial
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion, pIdOperacionFch)
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
		  
		  LET vtotal_registros= vtotal_registros1 + vtotal_registros2;
		  
         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, SYSDATE),
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
              NVL(vcgenerico7, ''),
              NVL(vcgenerico8, ''),
              NVL(vcgenerico9, ''),
              NVL(vcgenerico10, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                btc.fecha_oper,
                btc.fecha_aplic,
                btc.cuenta_origen,
                btc.destino,
                btc.monto_oper,
                btc.sec_transaccion,
                btc.cgenerico1,
                btc.cgenerico2,
                btc.id_operacion
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
              FROM 
				(
					SELECT fecha_oper, fecha_aplic, cuenta_origen, destino, monto_oper,sec_transaccion,cgenerico1,cgenerico2,id_operacion
					FROM bdibei:"informix".bei_bitacora
					WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion, pIdOperacionFch)
                        AND NVL(id_operacion, '') != '1051'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
					UNION
					SELECT fecha_oper, fecha_aplic, cuenta_origen, destino, monto_oper,sec_transaccion,cgenerico1,cgenerico2,id_operacion
					FROM bdibei:"informix".bei_bitacora_historial
					WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion, pIdOperacionFch)
                        AND NVL(id_operacion, '') != '1051'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
				) btc		
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, SYSDATE),
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
                  NVL(vcgenerico7, ''),
                  NVL(vcgenerico8, ''),
                  NVL(vcgenerico9, ''),
                  NVL(vcgenerico10, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      ELIF (pIdOperacion = '1016') THEN -- Si la operacion es: Transferencia a terceros
          
		  SELECT COUNT(id_operacion) INTO  vtotal_registros1
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion)
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
			  
		  SELECT COUNT(id_operacion) INTO vtotal_registros2
          FROM bdibei:"informix".bei_bitacora_historial
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion)
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
		  
		  LET vtotal_registros= vtotal_registros1 + vtotal_registros2;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, SYSDATE),
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
              NVL(vcgenerico7, ''),
              NVL(vcgenerico8, ''),
              NVL(vcgenerico9, ''),
              NVL(vcgenerico10, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
				SELECT SKIP pPaginacion FIRST vnum_reg_xpag 
                btc.fecha_oper,
                btc.fecha_aplic,
                btc.cuenta_origen,
                btc.destino,
                btc.monto_oper,
                btc.sec_transaccion,
                btc.cgenerico3,
                btc.cgenerico1,
                btc.cgenerico2,
                btc.id_operacion
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
			  FROM 
				(
					SELECT fecha_oper, fecha_aplic, cuenta_origen, destino, monto_oper,sec_transaccion, cgenerico3, cgenerico1, cgenerico2, id_operacion
					FROM bdibei:"informix".bei_bitacora
					WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion)
                        AND NVL(id_operacion, '') != '1051'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
					UNION
					SELECT fecha_oper, fecha_aplic, cuenta_origen, destino, monto_oper,sec_transaccion, cgenerico3, cgenerico1, cgenerico2, id_operacion
					FROM bdibei:"informix".bei_bitacora_historial
					WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion)
                        AND NVL(id_operacion, '') != '1051'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
				) btc	 
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, SYSDATE),
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
                  NVL(vcgenerico7, ''),
                  NVL(vcgenerico8, ''),
                  NVL(vcgenerico9, ''),
                  NVL(vcgenerico10, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      ELIF (pIdOperacion = '1015') THEN -- Si la operacion es: Transferencia SPEI
	  
          SELECT COUNT(id_operacion) INTO  vtotal_registros1
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion, pIdOperacionFch)
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
			  
		  SELECT COUNT(id_operacion) INTO vtotal_registros2
          FROM bdibei:"informix".bei_bitacora_historial
              WHERE id_usuario = idUsuario
              AND id_operacion IN (pIdOperacion, pIdOperacionFch)
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
		  
		  LET vtotal_registros= vtotal_registros1 + vtotal_registros2;

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, SYSDATE),
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
              NVL(vcgenerico7, ''),
              NVL(vcgenerico8, ''),
              NVL(vcgenerico9, ''),
              NVL(vcgenerico10, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                btc.fecha_oper,
                btc.fecha_aplic,
                btc.cuenta_origen,
                btc.cgenerico2,
                btc.monto_oper,
                btc.sec_transaccion,
                btc.cgenerico7,
                btc.cgenerico5,
                btc.cgenerico6,
                btc.cgenerico9,
                btc.cgenerico3,
                btc.cgenerico8,
                btc.cgenerico1,
                btc.id_operacion
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
			  FROM 
				(
					SELECT fecha_oper, fecha_aplic, cuenta_origen, cgenerico2, monto_oper, sec_transaccion,
							cgenerico7, cgenerico5, cgenerico6, cgenerico9, cgenerico3, cgenerico8, cgenerico1, id_operacion
					FROM bdibei:"informix".bei_bitacora
					WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion, pIdOperacionFch)
                        AND NVL(id_operacion, '') != '1051'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
					UNION
					SELECT fecha_oper, fecha_aplic, cuenta_origen, cgenerico2, monto_oper, sec_transaccion,
						cgenerico7, cgenerico5, cgenerico6, cgenerico9, cgenerico3, cgenerico8, cgenerico1, id_operacion
					FROM bdibei:"informix".bei_bitacora_historial
					WHERE id_usuario = idUsuario
                        AND id_operacion IN (pIdOperacion, pIdOperacionFch)
                        AND NVL(id_operacion, '') != '1051'
                        AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
				) btc	
                ORDER BY fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, SYSDATE),
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
                  NVL(vcgenerico7, ''),
                  NVL(vcgenerico8, ''),
                  NVL(vcgenerico9, ''),
                  NVL(vcgenerico10, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      ELIF (pIdOperacion = '310') THEN -- Si la operacion es: Pago de servicios
		  SELECT COUNT(id_operacion) INTO  vtotal_registros1
          FROM bdibei:"informix".bei_bitacora
              WHERE id_usuario = idUsuario
              AND id_operacion IN ('1020', '2020', '1021', '2021', '1022', '2022', '1026')
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
			  
		  SELECT COUNT(id_operacion) INTO vtotal_registros2
          FROM bdibei:"informix".bei_bitacora_historial
              WHERE id_usuario = idUsuario
              AND id_operacion IN ('1020', '2020', '1021', '2021', '1022', '2022', '1026')
              AND NVL(id_operacion, '') != '1051'
              AND fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin;
		  
		  LET vtotal_registros= vtotal_registros1 + vtotal_registros2;		 

         IF (vtotal_registros = 0) THEN
            LET cod_ret = '00001'; -- No se encontraron datos
            RETURN
              cod_ret,
              NVL(vfecha_oper, SYSDATE),
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
              NVL(vcgenerico7, ''),
              NVL(vcgenerico8, ''),
              NVL(vcgenerico9, ''),
              NVL(vcgenerico10, ''),
              NVL(vreferencia, ''),
              NVL(vfolio, ''),
              NVL(vid_operacion, ''),
              NVL(vtotal_registros, 0);
         END IF;

          FOREACH
              SELECT SKIP pPaginacion FIRST vnum_reg_xpag
                btc.fecha_oper,
                btc.fecha_aplic,
                btc.cuenta_origen,
                btc.destino,
                btc.monto_oper,
                btc.sec_transaccion,
                btc.cgenerico1,
                btc.cgenerico3,
                btc.id_operacion,
                btc.cgenerico4,
                btc.cgenerico5,
                btc.cgenerico2,
                btc.cgenerico7,
                btc.cgenerico6,
                btc.gen2,
                btc.gen3,
                btc.gen4,
                btc.gen5
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
                vcgenerico1,
                vcgenerico2,
                vcgenerico3,
                vcgenerico4,
                vcgenerico6,
                vcgenerico7,
                vcgenerico8,
                vcgenerico9,
                vcgenerico10
			  FROM 
				(
					SELECT t1.fecha_oper, t1.fecha_aplic, t1.cuenta_origen, t1.destino, t1.monto_oper,
						t1.sec_transaccion, t1.cgenerico1, t1.cgenerico3, t1.id_operacion,
						t1.cgenerico4, t1.cgenerico5, t1.cgenerico2, t1.cgenerico7, t1.cgenerico6,
						t2.gen2, t2.gen3, t2.gen4, t2.gen5					
					FROM bdibei:"informix".bei_bitacora t1
					LEFT JOIN bdisac:sac_bitacoragdf t2 on t1.cgenerico2 = t2.gen1
					WHERE t1.id_usuario = idUsuario
					AND t1.id_operacion IN ('1020', '2020', '1021', '2021', '1022', '2022', '1026')
					AND NVL(t1.id_operacion, '') != '1051'
					AND t1.fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
					UNION
					SELECT r1.fecha_oper, r1.fecha_aplic, r1.cuenta_origen, r1.destino, r1.monto_oper,
						r1.sec_transaccion, r1.cgenerico1, r1.cgenerico3, r1.id_operacion,
						r1.cgenerico4, r1.cgenerico5, r1.cgenerico2, r1.cgenerico7, r1.cgenerico6,
						r2.gen2, r2.gen3, r2.gen4, r2.gen5					
					FROM bdibei:"informix".bei_bitacora_historial r1
					LEFT JOIN bdisac:sac_bitacoragdf r2 on r1.cgenerico2 = r2.gen1
					WHERE r1.id_usuario = idUsuario
					AND r1.id_operacion IN ('1020', '2020', '1021', '2021', '1022', '2022', '1026')
					AND NVL(r1.id_operacion, '') != '1051'
					AND r1.fecha_oper::DATE BETWEEN vfecha_periodo_inicio AND vfecha_periodo_fin
				) btc		
                ORDER BY btc.fecha_oper DESC

              RETURN cod_ret,
                  NVL(vfecha_oper, SYSDATE),
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
                  NVL(vcgenerico7, ''),
                  NVL(vcgenerico8, ''),
                  NVL(vcgenerico9, ''),
                  NVL(vcgenerico10, ''),
                  NVL(vreferencia, ''),
                  NVL(vfolio, ''),
                  NVL(vid_operacion, ''),
                  NVL(vtotal_registros, 0)
                  WITH RESUME;
          END FOREACH;
      END IF;  -- Fin IF pIdOperacion

END -- Fin cuerpo del sp
END PROCEDURE;
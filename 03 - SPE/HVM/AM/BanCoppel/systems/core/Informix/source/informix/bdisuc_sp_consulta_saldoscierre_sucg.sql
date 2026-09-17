CREATE PROCEDURE "informix".sp_consulta_saldoscierre_sucg(consultar_por CHAR(1), vclave_cg CHAR(4),vclave_suc CHAR(4), vfecha_inicial DATE, vfecha_final DATE)

RETURNING CHAR(5), CHAR(100), DATE, CHAR(4), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2),
DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE msj CHAR(100);
DEFINE vfecha DATE;
DEFINE vclave CHAR(4);
DEFINE vcantidad_1 DECIMAL(18,2);
DEFINE vcantidad_2 DECIMAL(18,2);
DEFINE vcantidad_3 DECIMAL(18,2);
DEFINE vcantidad_4 DECIMAL(18,2);
DEFINE vcantidad_5 DECIMAL(18,2);
DEFINE vcantidad_6 DECIMAL(18,2);
DEFINE vcantidad_8 DECIMAL(18,2);
DEFINE vcantidad_9 DECIMAL(18,2);
DEFINE vcantidad_10 DECIMAL(18,2);
DEFINE vcantidad_11 DECIMAL(18,2);
DEFINE vcantidad_12 DECIMAL(18,2);
DEFINE vcantidad_13 DECIMAL(18,2);
DEFINE vcantidad_14 DECIMAL(18,2);
DEFINE vcantidad_15 DECIMAL(18,2);
DEFINE vcantidad_16 DECIMAL(18,2);
DEFINE vcantidad_17 DECIMAL(18,2);
DEFINE vcantidad_18 DECIMAL(18,2);
DEFINE vsaldo_total_b DECIMAL(18,2);
DEFINE vsaldo_total_m DECIMAL(18,2);
DEFINE vsaldo_total DECIMAL(18,2);

LET cod_ret = '00000';
LET msj = 'Operación exitosa';
LET vfecha = '';
LET vclave = '';
LET vcantidad_1 = 0;
LET vcantidad_2 = 0;
LET vcantidad_3 = 0;
LET vcantidad_4 = 0;
LET vcantidad_5 = 0;
LET vcantidad_6 = 0;
LET vcantidad_8 = 0;
LET vcantidad_9 = 0;
LET vcantidad_10 = 0;
LET vcantidad_11 = 0;
LET vcantidad_12 = 0;
LET vcantidad_13 = 0;
LET vcantidad_14 = 0;
LET vcantidad_15 = 0;
LET vcantidad_16 = 0;
LET vcantidad_17 = 0;
LET vcantidad_18 = 0;
LET vsaldo_total_b = 0;
LET vsaldo_total_m = 0;
LET vsaldo_total = 0;

--SET DEBUG FILE TO '/informix/cfflores/sp_consulta_saldoscierre_sucg.out';
--TRACE ON;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;
        LET msj = ERROR_INFO;
        RETURN cod_ret, msj, vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6, vcantidad_8,
        vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13, vcantidad_14, vcantidad_15, vcantidad_16, vcantidad_17,
        vcantidad_18, vsaldo_total_b, vsaldo_total_m, vsaldo_total;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

    IF consultar_por = '1' THEN --Validación para consultar por Caja General
		IF vclave_cg = '0000' THEN --Validación para consultar por TODAS las cajas generales
			FOREACH
				SELECT {+INDEX(bdisuc:"informix".ss_cajageneral_hist idx01ss_cajageneral_hist)} fecha, cod_proveedor,
                cantidad_1 * denominacion_1, cantidad_2 * denominacion_2, cantidad_3 * denominacion_3,
				cantidad_4 * denominacion_4, cantidad_5 * denominacion_5, cantidad_6 * denominacion_6,
				cantidad_8 * denominacion_8, cantidad_9 * denominacion_9, cantidad_10 * denominacion_10,
                cantidad_11 * denominacion_11, cantidad_12 * denominacion_12, cantidad_13 * denominacion_13,
                cantidad_14 * denominacion_14, cantidad_15 * denominacion_15, (saldo_total - cantidad_7) AS total_b,
				cantidad_7 AS total_m, saldo_total
				INTO vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
					vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
					vcantidad_14, vcantidad_15, vsaldo_total_b, vsaldo_total_m, vsaldo_total
				FROM bdisuc:ss_cajageneral_hist
				WHERE empresa= '001' AND (fecha BETWEEN vfecha_inicial AND vfecha_final)
                ORDER BY fecha, cod_proveedor
				
				RETURN cod_ret, msj, vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5,
					vcantidad_6, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
                    vcantidad_14, vcantidad_15, vcantidad_16, vcantidad_17, vcantidad_18, vsaldo_total_b, vsaldo_total_m,
                    vsaldo_total WITH RESUME;
			END FOREACH;
		ELSE --Validación para consultar por UNA caja general en especifico
			FOREACH
				SELECT {+INDEX(bdisuc:"informix".ss_cajageneral_hist idx01ss_cajageneral_hist)} fecha, cod_proveedor,
                cantidad_1 * denominacion_1, cantidad_2 * denominacion_2, cantidad_3 * denominacion_3,
                cantidad_4 * denominacion_4, cantidad_5 * denominacion_5, cantidad_6 * denominacion_6,
				cantidad_8 * denominacion_8, cantidad_9 * denominacion_9, cantidad_10 * denominacion_10,
                cantidad_11 * denominacion_11, cantidad_12 * denominacion_12, cantidad_13 * denominacion_13,
                cantidad_14 * denominacion_14, cantidad_15 * denominacion_15, (saldo_total - cantidad_7) AS total_b,
				cantidad_7 AS total_m, saldo_total
				INTO vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
					vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
					vcantidad_14, vcantidad_15, vsaldo_total_b, vsaldo_total_m, vsaldo_total
				FROM bdisuc:ss_cajageneral_hist
				WHERE empresa= '001' AND (fecha BETWEEN vfecha_inicial AND vfecha_final) AND cod_proveedor = vclave_cg
                ORDER BY fecha
				
				RETURN cod_ret, msj, vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5,
					vcantidad_6, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
                    vcantidad_14, vcantidad_15, vcantidad_16, vcantidad_17, vcantidad_18, vsaldo_total_b, vsaldo_total_m,
                    vsaldo_total WITH RESUME;
			END FOREACH;
		END IF;

   ELSE --Validación para consultar por Sucursal
		IF vclave_suc = '0000' THEN --------Validación para consultar por TODAS las sucursales
			IF vclave_cg = '0000' THEN -----de TODAS las Cajas Generales
				FOREACH
					SELECT {+INDEX(bdisuc:"informix".ss_saldossuc idx_saldossuc_sucfech)} fecha, sucursal,
					cantidad_1 * denominacion_1, cantidad_2 * denominacion_2, cantidad_3 * denominacion_3,
					cantidad_4 * denominacion_4, cantidad_5 * denominacion_5, cantidad_6 * denominacion_6,
					cantidad_8 * denominacion_8, cantidad_9 * denominacion_9, cantidad_10 * denominacion_10,
					cantidad_11 * denominacion_11, cantidad_12 * denominacion_12, cantidad_13 * denominacion_13,
					cantidad_14 * denominacion_14, cantidad_15 * denominacion_15, (saldo_total - cantidad_7) AS total_b,
					cantidad_7 AS total_m, saldo_total
					INTO vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
						vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
						vcantidad_14, vcantidad_15, vsaldo_total_b, vsaldo_total_m, vsaldo_total
					FROM bdisuc:ss_saldossuc
					WHERE sucursal < '8000' 
                    AND sucursal IN (SELECT suc.sucursal FROM bdinteg:si_sucursales suc WHERE suc.tpo_sucursal = 'S')
					AND (fecha BETWEEN vfecha_inicial AND vfecha_final)
					ORDER BY fecha, sucursal

					RETURN cod_ret, msj, vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5,
						vcantidad_6, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
						vcantidad_14, vcantidad_15, vcantidad_16, vcantidad_17, vcantidad_18, vsaldo_total_b, vsaldo_total_m,
						vsaldo_total WITH RESUME;
				END FOREACH;
			ELSE -------Validación para consultar por TODAS las sucursales de UNA Caja General en especifico
				FOREACH
					SELECT {+INDEX(bdisuc:"informix".ss_saldossuc idx_saldossuc_sucfech)} fecha, sucursal,
					cantidad_1 * denominacion_1, cantidad_2 * denominacion_2, cantidad_3 * denominacion_3,
					cantidad_4 * denominacion_4, cantidad_5 * denominacion_5, cantidad_6 * denominacion_6,
					cantidad_8 * denominacion_8, cantidad_9 * denominacion_9, cantidad_10 * denominacion_10,
					cantidad_11 * denominacion_11, cantidad_12 * denominacion_12, cantidad_13 * denominacion_13,
					cantidad_14 * denominacion_14, cantidad_15 * denominacion_15, (saldo_total - cantidad_7) AS total_b,
					cantidad_7 AS total_m, saldo_total
					INTO vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
						vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
						vcantidad_14, vcantidad_15, vsaldo_total_b, vsaldo_total_m, vsaldo_total
					FROM bdisuc:ss_saldossuc
					WHERE sucursal < '8000' 
                    AND (fecha BETWEEN vfecha_inicial AND vfecha_final)
					AND sucursal in (SELECT S.sucursal
									 FROM bdinteg:si_sucursales S, bdisuc:ss_proveedores P
									 WHERE P.plaza = S.plaza_cajagen
									 AND P.cod_proveedor = vclave_cg
									 AND tpo_sucursal = 'S')
					ORDER BY fecha, sucursal
					
					RETURN cod_ret, msj, vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5,
						vcantidad_6, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
						vcantidad_14, vcantidad_15, vcantidad_16, vcantidad_17, vcantidad_18, vsaldo_total_b, vsaldo_total_m,
						vsaldo_total WITH RESUME;
				END FOREACH;
			END IF;
		ELSE --Validación para consultar por UNA sucursal en especifico
			FOREACH
				SELECT {+INDEX(bdisuc:"informix".ss_saldossuc idx_saldossuc_sucfech)} fecha, sucursal,
				cantidad_1 * denominacion_1, cantidad_2 * denominacion_2, cantidad_3 * denominacion_3,
				cantidad_4 * denominacion_4, cantidad_5 * denominacion_5, cantidad_6 * denominacion_6,
				cantidad_8 * denominacion_8, cantidad_9 * denominacion_9, cantidad_10 * denominacion_10,
				cantidad_11 * denominacion_11, cantidad_12 * denominacion_12, cantidad_13 * denominacion_13,
				cantidad_14 * denominacion_14, cantidad_15 * denominacion_15, (saldo_total - cantidad_7) AS total_b,
				cantidad_7 AS total_m, saldo_total
				INTO vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5, vcantidad_6,
					vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
					vcantidad_14, vcantidad_15, vsaldo_total_b, vsaldo_total_m, vsaldo_total
				FROM bdisuc:ss_saldossuc
				WHERE sucursal = vclave_suc 
                AND (fecha BETWEEN vfecha_inicial AND vfecha_final)
				ORDER BY fecha
				
				RETURN cod_ret, msj, vfecha, vclave, vcantidad_1, vcantidad_2, vcantidad_3, vcantidad_4, vcantidad_5,
					vcantidad_6, vcantidad_8, vcantidad_9, vcantidad_10, vcantidad_11, vcantidad_12, vcantidad_13,
					vcantidad_14, vcantidad_15, vcantidad_16, vcantidad_17, vcantidad_18, vsaldo_total_b, vsaldo_total_m, vsaldo_total WITH RESUME;
			END FOREACH;
		END IF;
        
    END IF;

END;

END PROCEDURE;
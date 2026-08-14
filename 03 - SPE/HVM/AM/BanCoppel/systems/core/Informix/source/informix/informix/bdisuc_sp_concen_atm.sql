CREATE PROCEDURE "informix".sp_concen_atm(
	pempresa CHAR(3),
	psucursal CHAR(4),
	pcajeroprincipal CHAR(8),
	pfolio_suc char(16),
	ptransaccion char(4),
	pdivisa CHAR(2),
	pmonto_dot money(14,2),
	pfecha date,
	pdeno1 CHAR(18),
	pdeno2 CHAR(18),
	pdeno3 CHAR(18),
	pdeno4 CHAR(18),
	pdeno5 CHAR(18),
	pdeno6 CHAR(18),
	pdeno7 CHAR(18),
	pdeno8 CHAR(18),
	pdeno9 CHAR(18),
	pdeno10 CHAR(18),
	pdeno11 CHAR(18),
	pdeno12 CHAR(18),
	pdeno13 CHAR(18),
	pdeno14 CHAR(18),
	pdeno15 CHAR(18),
	pcant1 float(8),
	pcant2 float(8),
	pcant3 float(8),
	pcant4 float(8),
	pcant5 float(8),
	pcant6 float(8),
	pcant7 float(8),
	pcant8 float(8),
	pcant9 float(8),
	pcant10 float(8),
	pcant11 float(8),
	pcant12 float(8),
	pcant13 float(8),
	pcant14 float(8),
	pcant15 float(8),
	pfolio char(16))

RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vprocedencia CHAR(4);
DEFINE vnum integer;
DEFINE vmonto money(14,2);

LET vcodret = "000";
LET vfolio = "";
LET vproveedor = "";
LEt vplaza = "";
LET vprocedencia = "";
LET vhora = substr(current,12,5);
LET vnum = 0;

SET ISOLATION TO COMMITTED READ;
SET LOCK MODE TO WAIT 3;

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_concen_atm.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio = '' then
   LET vcodret = "110";
ELSE

	SELECT FIRST 1 o.folio_oper,o.monto
      into vfolio, vmonto
      FROM bdisuc:ss_operaciones o, bdisuc:ss_mae_entradasalida m
     WHERE o.folio_oper = m.folio_oper
       AND o.fecha_operacion = pfecha
       AND o.sucursal = psucursal
       AND o.cod_trans = ptransaccion
       AND o.reversado = 0
       AND m.folio_servicio = pfolio;

    IF vmonto > 0 THEN
      LET vcodret = "109";
      RETURN vcodret,vfolio;
    END IF

    SELECT plaza_cajagen into vplaza
    FROM   bdinteg:si_sucursales
    WHERE  sucursal = psucursal;

    SELECT cod_proveedor into vproveedor
    FROM   bdisuc:ss_proveedores
    WHERE  plaza = vplaza;

    SELECT valor
      INTO vnum
      FROM bdisuc:"informix".ss_param_cajagen
     WHERE codigo = '0005';

    UPDATE bdisuc:"informix".ss_param_cajagen
       SET valor = valor + 1
     WHERE  codigo = '0005';   

	LET vfolio = LPAD(ROUND(vnum),8,"0");

    SELECT sucursal 
	  INTO vprocedencia
	  FROM bdisuc:ss_atms_sucursal 
	 WHERE cod_atm = psucursal;

    INSERT INTO bdisuc:ss_mae_entradasalida
           (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,
            fecha_solicitud,hora_solicitud,usuario_solicitud,
            fecha_envio,hora_envio,usuario_envio,
            status,monto,folio_servicio)
    VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,
            pfecha,vhora,pcajeroprincipal,
            pfecha,vhora,pcajeroprincipal,
            '14',pmonto_dot,pfolio);

    INSERT INTO bdisuc:ss_operaciones
	  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,procedencia,monto,
           denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
           denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
           denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
           cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
           cantidad_13,cantidad_14,cantidad_15)
    VALUES
          (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,vprocedencia,pmonto_dot,
           pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
	   pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
	   pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

   UPDATE bdisuc:ss_atm set cantidad_1 = cantidad_1 - pcant1,cantidad_2 = cantidad_2 - pcant2,cantidad_3 = cantidad_3 - pcant3,
                     cantidad_4 = cantidad_4 - pcant4,cantidad_5 = cantidad_5 - pcant5,cantidad_6 = cantidad_6 - pcant6,
                     cantidad_7 = cantidad_7 - pcant7,cantidad_8 = cantidad_8 - pcant8,cantidad_9 = cantidad_9 - pcant9,
                     cantidad_10 = cantidad_10 - pcant10,cantidad_11 = cantidad_11 - pcant11,cantidad_12 = cantidad_12 - pcant12,
                     cantidad_13 = cantidad_13 - pcant13,cantidad_14 = cantidad_14 - pcant14,cantidad_15 = cantidad_15 - pcant15,
                     saldo_anterior = saldo_total,saldo_total =  saldo_total - pmonto_dot
   WHERE  cod_atm = psucursal; 
                     

END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_soldot_atm(
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
	pcant15 float(8))

RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora CHAR(5);
DEFINE vproveedor CHAR(4);
DEFINE vplaza CHAR (3);
DEFINE vnum INTEGER;
DEFINE iContador INTEGER;

LET vcodret = "000";
LET vproveedor = "";
LET vplaza = "";
LET vhora = substr(current,12,5);
LET vfolio = "";
LET vnum = 0;
LET iContador = 0;

--SET debug file to "/tmp/sp_soldot_atm.out";
--trace on;

SET ISOLATION TO COMMITTED READ;
SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET vsqlerr,visamerr
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            RETURN vcodret,vfolio;
        END IF;
    END EXCEPTION;

    -- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR
        pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' OR pcajeroprincipal = ''
        OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = ''
        OR pmonto_dot = 0 THEN
            
            LET vcodret = "110";

    ELSE
        SELECT plaza_cajagen 
          INTO vplaza
          FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = psucursal
		   AND empresa = pempresa;

        SELECT cod_proveedor 
        INTO vproveedor
        FROM   bdisuc:"informix".ss_proveedores
        WHERE  plaza = vplaza;

        --IF EXISTS (SELECT cod_proveedor FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = vproveedor) THEN
		SELECT COUNT(*) INTO iContador FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = vproveedor;
		IF iContador > 0 THEN
            SELECT valor
            INTO vnum
            FROM   bdisuc:"informix".ss_param_cajagen
            WHERE  codigo = '0005';

            UPDATE bdisuc:"informix".ss_param_cajagen
            SET    valor = valor + 1
            WHERE  codigo = '0005';
			
			LET vfolio = LPAD(ROUND(vnum),8,"0");

            INSERT INTO bdisuc:"informix".ss_mae_entradasalida
               (empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,fecha_solicitud,hora_solicitud,usuario_solicitud,
                status,monto)
            VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,pfecha,vhora,pcajeroprincipal,'12',pmonto_dot);

            INSERT INTO bdisuc:"informix".ss_operaciones
              (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
               denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
               denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
               denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
               cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
               cantidad_13,cantidad_14,cantidad_15)
            VALUES
              (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dot,
               pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
               pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
               pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

       ELSE
            LET vcodret = "105";
            return vcodret,vfolio;

       END IF;
    END IF;

    RETURN vcodret,vfolio;
END;

END PROCEDURE;
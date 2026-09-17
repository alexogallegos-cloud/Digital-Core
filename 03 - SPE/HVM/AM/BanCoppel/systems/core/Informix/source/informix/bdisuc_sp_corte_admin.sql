CREATE PROCEDURE "informix".sp_corte_admin(
	pempresa CHAR(3),
	psucursal CHAR(4),
	pcajeroprincipal CHAR(8),
	pfolio_suc CHAR(16),
	ptransaccion CHAR(4),
	pdivisa CHAR(2),
	pmonto MONEY(14,2),
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
	pcant1 FLOAT(8),
	pcant2 FLOAT(8),
	pcant3 FLOAT(8),
	pcant4 FLOAT(8),
	pcant5 FLOAT(8),
	pcant6 FLOAT(8),
	pcant7 FLOAT(8),
	pcant8 FLOAT(8),
	pcant9 FLOAT(8),
	pcant10 FLOAT(8),
	pcant11 FLOAT(8),
	pcant12 FLOAT(8),
	pcant13 FLOAT(8),
	pcant14 FLOAT(8),
	pcant15 FLOAT(8))

RETURNING CHAR(5),CHAR(8);

DEFINE vsqlerr,visamerr INTEGER;
DEFINE vcodret CHAR(5);
DEFINE vfolio CHAR(8);
DEFINE vproveedor CHAR(4);
DEFINE vplaza CHAR(3);
DEFINE vprocedencia CHAR(4);
DEFINE vnum INTEGER;
DEFINE iContador INTEGER;

LET vcodret = "000";
LET vproveedor = "";
LEt vplaza = "";
LET vprocedencia = "";
LET vnum = 0;
LET vfolio = "";
LET iContador = 0;

SET ISOLATION TO COMMITTED READ;
SET LOCK MODE TO WAIT 3;

BEGIN
    ON EXCEPTION SET vsqlerr,visamerr
       IF vsqlerr != 0 THEN
          LET vcodret=vsqlerr;
          RETURN vcodret,vfolio;
       END IF;
    END EXCEPTION;

    --SET debug file to "/tmp/sp_corte_admin.out";
    --trace on;

    --- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' 
        OR pcajeroprincipal = '' OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = '' OR pmonto = 0 THEN
        LET vcodret = "110";
    ELSE
        SELECT plaza_cajagen 
        INTO vplaza
        FROM   bdinteg:"informix".si_sucursales
        WHERE  sucursal = psucursal
		 and empresa = pempresa;

        SELECT cod_proveedor 
        INTO vproveedor
        FROM bdisuc:"informix".ss_proveedores
        WHERE plaza = vplaza;

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

			SELECT sucursal 
			  INTO vprocedencia
			  FROM bdisuc:ss_atms_sucursal 
			 WHERE cod_atm = psucursal;

			IF vprocedencia ="" OR vprocedencia IS NULL THEN
				LET vprocedencia = psucursal;
			END IF

            INSERT INTO bdisuc:"informix".ss_operaciones(empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,
                                               procedencia,monto,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
                                               denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
                                               denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
                                               cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
                                               cantidad_13,cantidad_14,cantidad_15)
            VALUES(pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,vprocedencia,pmonto,pdeno1,pdeno2,pdeno3,
                   pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,
                   pcant5,pcant6,pcant7,pcant8,pcant9,pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);

            UPDATE bdisuc:"informix".ss_atm 
               SET cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2, cantidad_3 = cantidad_3 - pcant3, 
                   cantidad_4 = cantidad_4 - pcant4, cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6,
                   saldo_anterior = saldo_total, saldo_total =  saldo_total - pmonto
             WHERE cod_atm = psucursal;

			--IF EXISTS(SELECT sucursal FROM bdisuc:ss_saldossuc WHERE empresa= pempresa and sucursal= psucursal and fecha = pfecha) THEN
			LET iContador = 0;
			SELECT sucursal INTO iContador FROM bdisuc:ss_saldossuc WHERE empresa= pempresa and sucursal= psucursal and fecha = pfecha;		
			IF iContador > 0 THEN
			
			UPDATE bdisuc:"informix".ss_saldossuc
			   SET (saldo_total,cajero_principal,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7) = 
                  ((SELECT saldo_total,pcajeroprincipal,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7 
				      FROM bdisuc:ss_atm 
					  WHERE cod_atm = psucursal))
			 WHERE empresa= pempresa 
               AND sucursal= psucursal 
		       AND fecha = pfecha;

			ELSE
				INSERT INTO bdisuc:"informix".ss_saldossuc
				     SELECT empresa,cod_atm,divisa,saldo_total,pfecha,pcajeroprincipal,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
							denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,     
						    denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,
							cantidad_9,cantidad_10,cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15
						FROM bdisuc:ss_atm 
						WHERE cod_atm= psucursal;
			END IF

        ELSE
            LET vcodret = "105";
            RETURN vcodret,vfolio;
        END IF;
    END IF;
    RETURN vcodret,vfolio;
END;
END PROCEDURE;
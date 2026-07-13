CREATE PROCEDURE "informix".sp_solic_con_terc( pempresa CHAR(3), 
		pcodigo_proveedor CHAR(4),
		psucursal_mae_entradasalida CHAR(4),
		psucursal_operaciones CHAR(4),
		pcajeroprincipal CHAR(8), 
        pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pprocedencia CHAR(4),
		pmonto_dot money(14,2),
		pmonto_mae_entradasalida MONEY(14,2),
		pmonto_operaciones MONEY(14,2),
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
        pfolio char(08) )
		
RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
--DEFINE vprocedencia CHAR(4);
DEFINE vnum integer;
DEFINE vmonto money(14,2);

LET vcodret = "000";
LET vfolio = "";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;

--SET LOCK MODE TO WAIT 3;

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_solicitud_concen_cg.out";
--TRACE ON;

--SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal_mae_entradasalida = '0' or psucursal_mae_entradasalida = '' or
   psucursal_operaciones = '0' or psucursal_operaciones = '' or pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or 
   pcajeroprincipal = '' or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dot = 0 or pfolio = '' then
   LET vcodret = "110";
ELSE

-----TRAE EL VALOR DEL FOLIO
    SELECT valor
      INTO vnum
      FROM bdisuc:"informix".ss_param_cajagen
     WHERE codigo = '0005';
----ACTUALIXA VALOR DEL FOLIO A + 1
    UPDATE bdisuc:"informix".ss_param_cajagen
       SET valor = valor + 1
     WHERE  codigo = '0005';   

	LET vfolio = LPAD(ROUND(vnum),8,"0");

    INSERT INTO bdisuc:ss_operaciones
	  (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,procedencia,monto,
           denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,denominacion_7,
           cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,
		   cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15)
	VALUES	   
	(pempresa,ptransaccion,pfecha,psucursal_operaciones,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pprocedencia,pmonto_dot,
           pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
	       pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);
	
	IF ptransaccion = '0003' THEN
		INSERT INTO bdisuc:ss_mae_entradasalida
			(empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,
             fecha_envio,hora_envio,usuario_envio,status,monto)
		VALUES (pempresa,pcodigo_proveedor,vfolio,psucursal_mae_entradasalida,pfolio_suc,
				pfecha,vhora,pcajeroprincipal,'04',pmonto_dot);
		
		UPDATE bdisuc:ss_cajageneral set cantidad_1 = cantidad_1 + pcant1,cantidad_2 = cantidad_2 + pcant2,cantidad_3 = cantidad_3 + pcant3,
							cantidad_4 = cantidad_4 + pcant4,cantidad_5 = cantidad_5 + pcant5,cantidad_6 = cantidad_6 + pcant6,
							cantidad_7 = cantidad_7 + pcant7,saldo_total =  saldo_total + pmonto_dot
		WHERE  cod_proveedor = pcodigo_proveedor; 
		
	ELIF ptransaccion = '0004' THEN
	
		INSERT INTO bdisuc:ss_mae_entradasalida
			(empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,
             fecha_envio,hora_envio,usuario_envio,status,monto)
		VALUES (pempresa,pcodigo_proveedor,vfolio,psucursal_mae_entradasalida,pfolio_suc,
				pfecha,vhora,pcajeroprincipal,'09',pmonto_dot);
		
		UPDATE bdisuc:ss_cajageneral set cantidad_1 = cantidad_1 - pcant1,cantidad_2 = cantidad_2 - pcant2,cantidad_3 = cantidad_3 - pcant3,
							cantidad_4 = cantidad_4 - pcant4,cantidad_5 = cantidad_5 - pcant5,cantidad_6 = cantidad_6 - pcant6,
							cantidad_7 = cantidad_7 - pcant7,saldo_total =  saldo_total - pmonto_dot
		WHERE  cod_proveedor = pcodigo_proveedor; 
	END IF;

END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;
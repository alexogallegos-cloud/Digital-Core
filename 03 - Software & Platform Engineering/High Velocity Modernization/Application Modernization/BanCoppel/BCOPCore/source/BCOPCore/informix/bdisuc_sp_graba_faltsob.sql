CREATE PROCEDURE "informix".sp_graba_faltsob(pempresa CHAR(3),
		psucursal         CHAR(4),
		pcajeroprincipal  CHAR(8),
        pfolio_suc        CHAR(16),
  		ptransaccion      CHAR(4),
		pdivisa           CHAR(2),
		pmonto_dif        money(14,2), --diferencia del monto solicitado
        pfecha            DATE,
		pdeno1  		  CHAR(18),
		pdeno2  		  CHAR(18),
		pdeno3  		  CHAR(18),
		pdeno4  		  CHAR(18),
        pdeno5  		  CHAR(18),
		pdeno6  		  CHAR(18),
		pdeno7  		  CHAR(18),
		pdeno8  		  CHAR(18),
		pdeno9     		  CHAR(18),
		pdeno10 		  CHAR(18),
        pdeno11 		  CHAR(18),
		pdeno12 		  CHAR(18),
		pdeno13 		  CHAR(18),
		pdeno14 		  CHAR(18),
		pdeno15 		  CHAR(18),
		pdeno16			  CHAR(18),
		pdeno17			  CHAR(18),
		pdeno18			  CHAR(18),
		pcant1  		  FLOAT(8),
		pcant2  		  FLOAT(8),
		pcant3  		  FLOAT(8),
		pcant4  		  FLOAT(8),
		pcant5  		  FLOAT(8),
		pcant6  		  FLOAT(8),
		pcant7  		  FLOAT(8),
		pcant8  		  FLOAT(8),
		pcant9  		  FLOAT(8),
        pcant10 		  FLOAT(8),
		pcant11 		  FLOAT(8),
		pcant12 		  FLOAT(8),
		pcant13 		  FLOAT(8),
		pcant14 		  FLOAT(8),
		pcant15 		  FLOAT(8),
		pcant16 		  FLOAT(8),
		pcant17 		  FLOAT(8),
		pcant18 		  FLOAT(8),
        pfolio  		  CHAR(16), --Folio del servicio 
		ptipo			  CHAR(2), -- F=Faltante, S=Sobrante
		pmonto_recibido   money(14,2), --monto recibido
		pmonto_dot1  money(14,2)) -- monto solicitado
		
RETURNING CHAR(5),CHAR(8),CHAR(50);

DEFINE vcodret			   CHAR(5);
DEFINE vfolio   		   CHAR(8);
DEFINE vsqlerr             INTEGER;
DEFINE visamerr            INTEGER;
DEFINE  ERROR_INFO         VARCHAR(80);
DEFINE vmensaje			   CHAR(50);
DEFINE vhora  			   CHAR(5);
DEFINE vproveedor 		   CHAR(4);
DEFINE vnum    			   INTEGER;
DEFINE vtipo			   CHAR(2);
DEFINE vmontom			   money(14,2);

LET vcodret = "000";
LET vfolio = "";
LET vproveedor = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vtipo = ptipo;
LET vmontom=0;
LET ERROR_INFO="";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
	  LET vmensaje= ERROR_INFO;
      RETURN vcodret,vfolio, vmensaje;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto_dif = 0 or pfolio = '' or pfolio = '0' or  pmonto_recibido=0 or pmonto_dot1=0  then
   LET vcodret = "110";
   LET vmensaje='Parámetros Incompletos';
   
ELSE

		
	SELECT p.cod_proveedor
		INTO vproveedor
    FROM bdisuc:ss_proveedores p, bdinteg:si_sucursales s
    WHERE p.plaza = s.plaza_cajagen
    AND s.empresa = pempresa
	AND s.sucursal = psucursal;

    IF EXISTS (select cod_proveedor from ss_proveedores where cod_proveedor = vproveedor) THEN

		select valor into vnum
		from   ss_param_cajagen
		where  codigo = '0005';

		update ss_param_cajagen
		set    valor = valor + 1
		where  codigo = '0005';

		let vfolio = lpad(vnum,8,"0");
		
		IF pcant7= 0 THEN
			LET vmontom= (100*pcant8) + (50*pcant9) + (20*pcant10) + (10*pcant11) + (5*pcant12) + (2*pcant13) + (1*pcant14) + (0.50*pcant15) + (0.20*pcant16) + (0.10*pcant17) + (0.05*pcant18);  --Cantidad total de morralla
		else
			LET vmontom=pcant7;
		END IF;
	
		INSERT INTO bdisuc:"informix".ss_operaciones
			(empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,
			denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
			denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
			denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
			cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
			cantidad_13,cantidad_14,cantidad_15,denominacion_16, denominacion_17, denominacion_18, cantidad_16,
			cantidad_17, cantidad_18)
		VALUES
			(pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto_dif,
			pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno11,pdeno12,pdeno13,pdeno14,
			pdeno15,pdeno16,pdeno17,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,vmontom,pcant8,pcant11,
			pcant12,pcant13,pcant14,pcant15,pcant16,pcant17,pdeno9,pdeno10,pdeno18,pcant9,pcant10,pcant18);
	   
		INSERT INTO bdisuc:"informix".ss_mae_entradasalida
			(empresa,cod_proveedor,folio_oper,sucursal,folio_sucursal,
			fecha_solicitud,hora_solicitud,usuario_solicitud,
			fecha_envio,hora_envio,usuario_envio,
			status,monto,folio_servicio)
		VALUES (pempresa,vproveedor,vfolio,psucursal,pfolio_suc,
			pfecha,vhora,pcajeroprincipal,
			pfecha,vhora,pcajeroprincipal,
			'06',pmonto_dif,pfolio);
				
		INSERT INTO bdisuc:"informix".ss_diferenciadot_suc
		    (empresa,sucursal,cod_proveedor, num_folio, transs, mnto_solicitado,mnto_suc,monto_diferencia,fecha_dif )
		VALUES (pempresa,psucursal,vproveedor, vfolio, ptransaccion,pmonto_dot1,pmonto_recibido, pmonto_dif,pfecha);
		
			IF vtipo = 'F' THEN  --Faltante de panamericano 
			
				update "informix".ss_cajageneral
				set saldo_total = saldo_total + pmonto_dif, cantidad_1 = cantidad_1 + pcant1, cantidad_2 = cantidad_2 + pcant2, cantidad_3 = cantidad_3 + pcant3,
				cantidad_4 = cantidad_4 + pcant4, cantidad_5 = cantidad_5 + pcant5, cantidad_6 = cantidad_6 + pcant6, cantidad_7 = cantidad_7 + vmontom,
				cantidad_8 = cantidad_8 + pcant8, cantidad_9 = cantidad_9 + pcant11, cantidad_10 = cantidad_10 + pcant12, cantidad_11 = cantidad_11 + pcant13,
				cantidad_12 = cantidad_12 + pcant14, cantidad_13 = cantidad_13 + pcant15, cantidad_14 = cantidad_14 + pcant16, cantidad_15 = cantidad_15 + pcant17,
				cantidad_16= cantidad_16  + pcant9, cantidad_17= cantidad_17 + pcant10, cantidad_18= cantidad_18 + pcant18
				where cod_proveedor = vproveedor;
			else               --Sobrante de panamericano
				update "informix".ss_cajageneral
				set saldo_total = saldo_total - pmonto_dif, cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2, cantidad_3 = cantidad_3 - pcant3,
				cantidad_4 = cantidad_4 - pcant4, cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6, cantidad_7 = cantidad_7 - vmontom,
				cantidad_8 = cantidad_8 - pcant8, cantidad_9 = cantidad_9 - pcant11, cantidad_10 = cantidad_10 - pcant12, cantidad_11 = cantidad_11 - pcant13,
				cantidad_12 = cantidad_12 - pcant14, cantidad_13 = cantidad_13 - pcant15, cantidad_14 = cantidad_14 - pcant16, cantidad_15 = cantidad_15 - pcant17,
				cantidad_16= cantidad_16 - pcant9, cantidad_17= cantidad_17 - pcant10, cantidad_18= cantidad_18 - pcant18
				where cod_proveedor = vproveedor;
				
			END IF;
			
			LET vmensaje= 'Proceso Realizado Correctamente'; 
		
	END IF;	
END IF;

RETURN vcodret,vfolio, vmensaje;
END;
END PROCEDURE;
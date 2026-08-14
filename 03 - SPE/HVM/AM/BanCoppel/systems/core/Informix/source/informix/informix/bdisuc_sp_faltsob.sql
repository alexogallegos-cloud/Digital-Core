CREATE PROCEDURE "informix".sp_faltsob(pempresa CHAR(3),
		psucursal CHAR(4),
		pcajeroprincipal CHAR(8),
                pfolio_suc char(16),
  		ptransaccion char(4),
		pdivisa CHAR(2),
		pmonto money(14,2),
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
                poperacion smallint)

RETURNING CHAR(5),char(8);

DEFINE vcodret CHAR(5);
DEFINE vfolio char(8);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vhora char(5);
DEFINE vproveedor char(4);
DEFINE vplaza char(3);
DEFINE vnum char(8);

LET vcodret = "000";
LET vproveedor = "";
LEt vplaza = "";
LET vhora = substr(current,12,5);
LET vnum = 0;
LET vfolio = "";
BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vfolio;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_faltsob.out";
--trace on;

--- Verifica recepcion correcta de datos
IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   pdivisa = '0' or pdivisa = ''  or pcajeroprincipal = '0' or pcajeroprincipal = ''
   or pfolio_suc = '0' or pfolio_suc = '' or ptransaccion = '0' or ptransaccion = ''
   or pmonto = 0 then
   LET vcodret = "110";
ELSE

    select plaza_cajagen into vplaza
    from   bdinteg:si_sucursales
    where  sucursal = psucursal;

    select cod_proveedor into vproveedor
    from   ss_proveedores
    where  plaza = vplaza;

    IF EXISTS (select cod_proveedor from ss_proveedores where cod_proveedor = vproveedor) THEN
       IF poperacion != 0 AND poperacion != 1 THEN
          LET vcodret = "106";       
       ELSE 

        SELECT valor
	      INTO vnum
	      FROM bdisuc:"informix".ss_param_cajagen
	     WHERE  codigo = '0005';

	    UPDATE bdisuc:"informix".ss_param_cajagen
	       SET  valor = valor + 1
	     WHERE  codigo = '0005';
				
		   LET vfolio = LPAD(ROUND(vnum),8,"0");
       
          INSERT INTO ss_operaciones
                     (empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,monto,procedencia,
                      denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
                      denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
                      denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
                      cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
                      cantidad_13,cantidad_14,cantidad_15)
          VALUES
                 (pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,pmonto,psucursal,
                  pdeno1,pdeno2,pdeno3,pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,
	          pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,pcant5,pcant6,pcant7,pcant8,pcant9,
	          pcant10,pcant11,pcant12,pcant13,pcant14,pcant15);
         
           IF poperacion = 1 THEN    
              UPDATE ss_atm set cantidad_1 = cantidad_1 + pcant1, cantidad_2 = cantidad_2 + pcant2, 
                                        cantidad_3 = cantidad_3 + pcant3, cantidad_4 = cantidad_4 + pcant4,
                                        cantidad_5 = cantidad_5 + pcant5, cantidad_6 = cantidad_6 + pcant6,
                                        saldo_anterior = saldo_total,
                                        saldo_total =  saldo_total + pmonto
                                          
              WHERE  cod_atm = psucursal;
 
           ELSE
              UPDATE ss_atm set cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2,
                                        cantidad_3 = cantidad_3 - pcant3, cantidad_4 = cantidad_4 - pcant4,
                                        cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6,
                                        saldo_anterior = saldo_total,
                                        saldo_total =  saldo_total - pmonto
              WHERE  cod_atm = psucursal;
 

           END IF; 

       END IF; 
    ELSE

   let vcodret = "105";
   return vcodret,vfolio;

   END IF;
END IF;

RETURN vcodret,vfolio;
END;
END PROCEDURE;
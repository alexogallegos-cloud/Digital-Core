CREATE PROCEDURE "informix".sp_replicatransacciones()
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           Date;
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

--**************************************************************
-- By Manuel Osuna Valencia (Transaccion por Producto,Empresa)--*
-- Debug del Procedure                                        --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                       --*
 --TRACE ON;                                                  --*
--**************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

	--Sacar la Fecha del Ultimo Corte
	select fecha_ant into dFecha  from bdmis:mi_fechas;

	DELETE FROM bdmis:mi_tmptranspos;

	--Pasar Informacion al Historial
		INSERT INTO bdmis:mi_usoproductohis(producto,num_transacc,tot_transacc,importe,fecha)
		SELECT producto,num_transacc,tot_transacc,importe,fecha FROM bdmis:mi_usoproducto;

		INSERT INTO  bdmis:mi_atmtranshis(clavebanco,num_producto,num_trans,fecha,nombre,total,saldo)
		SELECT clavebanco,num_producto,num_trans,fecha,nombre,total,saldo FROM bdmis:mi_atmtrans;

		INSERT INTO bdmis:mi_postranshis(tipo,referencia,num_trans,num_producto,total,saldo,fecha) 
		SELECT tipo,referencia,num_producto,num_trans,fecha,total,saldo FROM bdmis:mi_postrans;

		DELETE FROM bdmis:mi_usoproducto;
		DELETE FROM bdmis:mi_postrans;
		DELETE FROM bdmis:mi_atmtrans;

    --## Credito #############################################################################
    --Transacciones de Todos los Productos en (mi_usuproducto)
		INSERT INTO bdmis:mi_usoproducto(producto,num_transacc,tot_transacc,importe,fecha)
		SELECT num_producto,transacc_suc,count(*) ,sum(monto),fecha_mov
		FROM bdicred:sd_movhis
		WHERE transacc_suc in (select numero from bdmis:mi_medio where sistema ='06')
		AND fecha_mov = dFecha AND reversado <> "S"
		GROUP BY num_producto,transacc_suc,fecha_mov;
	--Transacciones Por Empresa (Atm)
		INSERT INTO  bdmis:mi_atmtrans(clavebanco,num_producto,num_trans,fecha,nombre,total,saldo)
		SELECT a.referencia[17,21],a.num_producto,a.transacc_suc,a.fecha_mov,b.nombre,count(*),sum(a.monto)
		FROM bdicred:sd_movhis a,bdmis:mi_bancoatm b
		WHERE a.empresa = '001' and a.transacc_suc = 6800 and trim(a.referencia[17,21]) = b.clavebanco and a.fecha_mov = dFecha
		AND reversado <> "S"
		GROUP BY a.referencia[17,21],a.num_producto,a.transacc_suc,a.fecha_mov,b.nombre;
    --Transacciones por Empresa (Pos)
		INSERT INTO bdmis:mi_tmptranspos(referencia,num_producto,num_trans,fecha,total,saldo)
		SELECT a.referencia[18,40],a.num_producto,a.transacc_suc,a.fecha_mov,count(*),sum(monto)
		FROM bdicred:sd_movhis a
		WHERE a.empresa = '001' and a.transacc_suc = 6830 and a.fecha_mov = dFecha
		AND reversado <> "S"
		GROUP BY a.referencia[18,40],a.num_producto,a.transacc_suc,a.fecha_mov;
	--Transacciones por Empresa con Mayor Numero de Transacciones (Tipo = 1)
		INSERT INTO bdmis:mi_postrans (tipo,referencia,num_trans,num_producto,total,saldo,fecha)
		SELECT * FROM TABLE (MULTISET (SELECT limit 30 '1',referencia,num_trans,num_producto,
		total,saldo,fecha  FROM bdmis:mi_tmptranspos ORDER BY total desc));
	--Transacciones por Empresa con Mayor Saldo en sus Transacciones (Tipo = 2)
		INSERT INTO bdmis:mi_postrans (tipo,referencia,num_trans,num_producto,total,saldo,fecha)
		SELECT * FROM TABLE (MULTISET (SELECT limit 30 '2',referencia,num_trans,num_producto,
		total,saldo,fecha  FROM bdmis:mi_tmptranspos ORDER BY saldo desc));

		DELETE FROM bdmis:mi_tmptranspos;

	--#### Cheques ##########################################################################
	--Transacciones de Todos los Productos en (mi_usuproducto)
		INSERT INTO bdmis:mi_usoproducto(producto,num_transacc,tot_transacc,importe,fecha)
		SELECT producto,transacc,count(*) ,sum(monto_tot),fech_val
		FROM bdicheq:sc_movhis
		WHERE transacc in (select numero from bdmis:mi_medio where sistema ='01')
		AND fech_val = dFecha
		GROUP BY producto,transacc,fech_val;
	--Transacciones Por Empresa (Atm)
		INSERT INTO  bdmis:mi_atmtrans(clavebanco,num_producto,num_trans,fecha,nombre,total,saldo)
		SELECT a.referencia[1,4],a.producto,a.transacc ,a.fech_val,b.nombre,count(*),sum(a.monto_tot)
		FROM bdicheq:sc_movhis a, bdmis:mi_bancoatm b
		WHERE a.transacc = 0800 AND a.referencia[1,4] = b.clavebanco
		AND a.fech_val = dFecha
		GROUP BY a.referencia[1,4],a.producto,a.transacc ,a.fech_val,b.nombre;
	--Transacciones por Empresa (Pos)
        INSERT INTO bdmis:mi_tmptranspos(referencia,num_producto,num_trans,fecha,total,saldo)
		SELECT trim(substring(a.referencia from 1 for (length( trim(a.referencia))-7))),
        a.producto,a.transacc,a.fech_val,count(*),sum(a.monto_tot)
		FROM bdicheq:sc_movhis a
		WHERE a.empresa = '001' and a.transacc  = 0830 and a.fech_val = dFecha
		GROUP BY  1,2,3,4;
	--Transacciones por Empresa con Mayor Numero de Transacciones (Tipo = 1)
		INSERT INTO bdmis:mi_postrans (tipo,referencia,num_trans,num_producto,total,saldo,fecha)
		SELECT * FROM TABLE (MULTISET (SELECT limit 30 '1',referencia,num_trans,num_producto,
		total,saldo,fecha  FROM bdmis:mi_tmptranspos ORDER BY total desc));
	--Transacciones por Empresa con Mayor Saldo en sus Transacciones (Tipo = 2)
		INSERT INTO bdmis:mi_postrans (tipo,referencia,num_trans,num_producto,total,saldo,fecha)
		SELECT * FROM TABLE (MULTISET (SELECT limit 30 '2',referencia,num_trans,num_producto,
		total,saldo,fecha  FROM bdmis:mi_tmptranspos ORDER BY saldo desc));

   RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;
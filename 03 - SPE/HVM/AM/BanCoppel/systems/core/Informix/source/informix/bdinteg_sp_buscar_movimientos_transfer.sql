CREATE PROCEDURE "informix".sp_buscar_movimientos_transfer(p_sNumeroCuenta CHAR(30), p_sTelefonoTransfer CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, p_sTarjeta CHAR(30), transacciones lvarchar,  p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento, DATETIME HOUR to FRACTION(3) AS horaMovimiento , money(16,2) AS monto, CHAR(5) AS claveTipo, CHAR(40) AS tipo, CHAR (20) AS folioSuc, CHAR (4) AS Sucursal;

	-- Definicion de variables	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto	            money(16,2);
	DEFINE resultado_horaMovimiento	    DATETIME HOUR to FRACTION(3);
    DEFINE resultado_claveTipo       CHAR(5);
  	DEFINE resultado_tipo   	    CHAR(40);
    DEFINE resultado_folioSuc       CHAR (20); 
	DEFINE transaccioness 			LIST(CHAR(4) NOT NULL);
    DEFINE resultado_Sucursal       CHAR (4); 
   
         DEFINE iSqlErr                      INTEGER;
     
     -- InicializaciÃ?Â³n de las variables.
	LET resultado_fechaMovimiento 		= '';
	LET resultado_monto 			= '';
	LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
  	LET resultado_claveTipo 		= '';
	LET resultado_tipo 			= '';
    LET resultado_folioSuc    = '';
	LET transaccioness			= 'LIST{' || transacciones || '}';
    LET resultado_Sucursal      ='9747';

      SET ISOLATION TO DIRTY READ;       
		BEGIN

            ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_fechaMovimiento 		= '';
                LET resultado_monto 			= '';
                LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
                LET resultado_claveTipo 		= '';
                LET resultado_tipo 			= '';
                LET resultado_folioSuc    = '';
                LET resultado_Sucursal      ='';

                 RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc, resultado_Sucursal;
            END IF;
        END EXCEPTION;

IF (p_sNumeroCuenta IS NULL) THEN
IF (p_sTelefonoTransfer IS NULL) THEN

 LET resultado_fechaMovimiento 		= '';
                LET resultado_monto 			= '';
                LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
                LET resultado_claveTipo 		= '';
                LET resultado_tipo 			= '';
                LET resultado_folioSuc    = '';
                LET resultado_Sucursal      ='';

                 RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc, resultado_Sucursal;

END IF;
END IF;

/*------  SE COMENTA TEMPORALMENTE, DEBIDO A QUE EL USUARIO REPORTA QUE EN BÚSQUEDAS DE MOVIMIENTOS PARA EL PRODUCTO TRANSFER, DEVUELVE MÁS MOVIMIETOS DE LOS DADOS DE ALTA, POR LO QUE SE SUSPENDEN LAS BÚSQUEDAS DE LA BASE DE DATOS BDITRANSFER.
IF (p_sNumeroCuenta IS NULL) THEN

 FOREACH

	      SELECT SKIP p_skip DISTINCT bditransfer:tf_all_transaction.fech_alt, bditransfer:tf_all_transaction.fech_hor_ini, bditransfer:tf_all_transaction.monto,
	   bdicheq:sc_producto.producto, bdicheq:sc_producto.nombre, bditransfer:tf_all_transaction.id_transacc_mps 
       INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc  	
	FROM bditransfer:tf_maecte
	LEFT JOIN bditransfer:tf_all_transaction ON (bditransfer:tf_maecte.cuenta_tf = bditransfer:tf_all_transaction.cuenta)
	LEFT JOIN bdicheq:sc_producto ON (bditransfer:tf_maecte.producto = bdicheq:sc_producto.producto)
	
	WHERE bditransfer:tf_maecte.telefono = p_sTelefonoTransfer
	--AND  bditransfer:tf_maecte.cuenta_tf = p_sNumeroCuenta
 	AND bditransfer:tf_all_transaction.fech_alt BETWEEN p_sFechaInicial AND p_sFechaFinal 
	--AND bditransfer:tf_all_transaction.transacc IN transaccioness
	AND bditransfer:tf_all_transaction.transacc IN ('0004','0005','0009','0013','0014','0020','0031','0034','0042')


	  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc, resultado_Sucursal  WITH RESUME;

END FOREACH;    

END IF;



IF (p_sTelefonoTransfer IS NULL) THEN


      FOREACH

	      SELECT SKIP p_skip DISTINCT bditransfer:tf_all_transaction.fech_alt, bditransfer:tf_all_transaction.fech_hor_ini, bditransfer:tf_all_transaction.monto,
	   bdicheq:sc_producto.producto, bdicheq:sc_producto.nombre, bditransfer:tf_all_transaction.id_transacc_mps 
       INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc  	
	FROM bditransfer:tf_maecte
	LEFT JOIN bditransfer:tf_all_transaction ON (bditransfer:tf_maecte.cuenta_tf = bditransfer:tf_all_transaction.cuenta)
	LEFT JOIN bdicheq:sc_producto ON (bditransfer:tf_maecte.producto = bdicheq:sc_producto.producto)
	
	--WHERE bditransfer:tf_maecte.telefono = p_sTelefonoTransfer
	WHERE  bditransfer:tf_maecte.cuenta_tf = p_sNumeroCuenta
 	AND bditransfer:tf_all_transaction.fech_alt BETWEEN p_sFechaInicial AND p_sFechaFinal 
	--AND bditransfer:tf_all_transaction.transacc IN transaccioness
	AND bditransfer:tf_all_transaction.transacc in ('0004','0005','0009','0013','0014','0020','0031','0034','0042')


	  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc, resultado_Sucursal  WITH RESUME;

END FOREACH; 

END IF;



IF (p_sTarjeta IS NULL) THEN

      FOREACH

	      SELECT SKIP p_skip DISTINCT bditransfer:tf_all_transaction.fech_alt, bditransfer:tf_all_transaction.fech_hor_ini, bditransfer:tf_all_transaction.monto,
	   bdicheq:sc_producto.producto, bdicheq:sc_producto.nombre, bditransfer:tf_all_transaction.id_transacc_mps 
       INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc  	
	FROM bditransfer:tf_maecte
	LEFT JOIN bditransfer:tf_all_transaction ON (bditransfer:tf_maecte.cuenta_tf = bditransfer:tf_all_transaction.cuenta)
	LEFT JOIN bdicheq:sc_producto ON (bditransfer:tf_maecte.producto = bdicheq:sc_producto.producto)
	
	WHERE bditransfer:tf_maecte.telefono = p_sTelefonoTransfer
	AND  bditransfer:tf_maecte.cuenta_tf = p_sNumeroCuenta
 	AND bditransfer:tf_all_transaction.fech_alt BETWEEN p_sFechaInicial AND p_sFechaFinal  
	--AND bditransfer:tf_all_transaction.transacc IN transaccioness
	AND bditransfer:tf_all_transaction.transacc in ('0004','0005','0009','0013','0014','0020','0031','0034','0042')

	  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc, resultado_Sucursal  WITH RESUME;

END FOREACH;    



ELSE


      FOREACH

	      SELECT SKIP p_skip DISTINCT bditransfer:tf_all_transaction.fech_alt, bditransfer:tf_all_transaction.fech_hor_ini, bditransfer:tf_all_transaction.monto,
	   bdicheq:sc_producto.producto, bdicheq:sc_producto.nombre, bditransfer:tf_all_transaction.id_transacc_mps 
       INTO resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc  	
	FROM bditransfer:tf_maecte
	LEFT JOIN bditransfer:tf_all_transaction ON (bditransfer:tf_maecte.cuenta_tf = bditransfer:tf_all_transaction.cuenta)
	LEFT JOIN bdicheq:sc_producto ON (bditransfer:tf_maecte.producto = bdicheq:sc_producto.producto)
	
	WHERE bditransfer:tf_maecte.telefono = p_sTelefonoTransfer
	AND  bditransfer:tf_maecte.cuenta_tf = p_sNumeroCuenta
 	AND bditransfer:tf_all_transaction.fech_alt BETWEEN p_sFechaInicial AND p_sFechaFinal
	--AND bditransfer:tf_all_transaction.transacc IN transaccioness
	AND bditransfer:tf_all_transaction.transacc in ('0004','0005','0009','0013','0014','0020','0031','0034','0042')



	  RETURN resultado_fechaMovimiento, resultado_horaMovimiento, resultado_monto, resultado_claveTipo, resultado_tipo, resultado_folioSuc, resultado_Sucursal  WITH RESUME;

END FOREACH;    
END IF;

*/
END
END PROCEDURE;
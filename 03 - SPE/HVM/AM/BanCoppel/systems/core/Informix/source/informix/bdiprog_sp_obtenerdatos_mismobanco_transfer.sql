CREATE PROCEDURE "informix".sp_obtenerdatos_mismobanco_transfer(pEmpresa char(3), pCuenta char(16))
 returning char (5), char (42), char (104);


 --Creado: Javier Chavez
 --Solicitó: Mauricio León
 --Fecha:12/05/09.
 --Actividad: Retorna el nombre del cliente, el número del producto y su descripción
 --------------------------------------------------------------------------------------------------------
 --Modificó: Mauricio León
 --Fecha: 22/06/2009
 --Actividad: Se agrega búsqueda por índice empresa-producto
 ---------------------------------------------------------------------------------------------------------
 --Modificó: Mauricio León
 --Fecha: 13/09/2011
 --Actividad: Se agrega campo razon social para personas morales
 ---------------------------------------------------------------------------------------------------------
 --Modificó: Héctor Moreno
 --Fecha: 24/11/2016
 --Actividad: Se modifica para que consulte la cuenta transfer en la tabla tf_maecte

 DEFINE Cod_ret char (5);
 DEFINE sql_err Integer;
 DEFINE vNombre1 char (26);
 DEFINE vNombre2 char (26);
 DEFINE vApell_pat char (26);
 DEFINE vApell_mat char (26);
 DEFINE vProd char (4);
 DEFINE vProdNom char (40);
 DEFINE vNomCompleto char (104);
 DEFINE vProducto char (42);
 DEFINE vRazonSocial char (60);

 LET Cod_ret = "";
 LET vNombre1 = "";
 LET vNombre2 = "";
 LET vApell_pat = "";
 LET vApell_mat = "";
 LET vProd = "";
 LET vProdNom = "";
 LET vRazonSocial = "";
 
SET LOCK MODE TO WAIT 10;

 BEGIN
 ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
		LET Cod_ret = sql_err;
		return Cod_ret,vProducto,vNomCompleto;
	END IF;
 END EXCEPTION;
 
   --SET DEBUG FILE TO "/home/sysifx/hector/sp_obtenerdatos_mismobanco_transfer.out";
   --TRACE ON;
	
   IF (pCuenta <> "") THEN
		IF(LENGTH(pCuenta) = 11) THEN
				SELECT a.producto, a.nombre, c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
		INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
					FROM bdicheq:"informix".sc_producto a
					INNER JOIN  bditransfer:"informix".tf_maecte b ON b.producto = a.producto
					INNER JOIN bdinteg:"informix".si_cliente c ON b.numcte = c.numcte
					WHERE b.empresa = pEmpresa AND b.cuenta_tf = pCuenta;
					
					IF (vProd = "" OR vProd IS NULL) THEN
						LET Cod_ret = "002"; --no se encontraron los datos
					ELSE
						LET Cod_ret = "000";
					END IF;
		ELIF (LENGTH(pCuenta)=16) THEN
		SELECT a.producto, a.nombre, c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
			INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
					FROM bdicheq:"informix".sc_producto a
					INNER JOIN bdicheq:"informix".sc_tarjeta b on b.prodtarjeta = a.producto
					INNER JOIN bdinteg:"informix".si_cliente c on b.numcte = c.numcte
					INNER JOIN bditransfer:"informix".tf_maecte d ON c.numcte=d.numcte
					WHERE b.empresa = pEmpresa AND b.num_tarjeta = pCuenta;
					

					IF (vProd = "" OR vProd IS NULL) THEN
						LET Cod_ret = "002"; --no se encontraron los datos
					ELSE
						LET Cod_ret = "000";
					END IF;
		ELIF (LENGTH(pCuenta)=10) THEN
					SELECT a.producto, a.nombre, c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
						INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
					FROM bdicheq:"informix".sc_producto a
					INNER JOIN bditransfer:"informix".tf_maecte b ON b.producto = a.producto
					INNER JOIN bdinteg:"informix".si_cliente c ON b.numcte = c.numcte
					INNER JOIN bdicheq:sc_cuenta_telefono ct ON ct.telefono = b.telefono and ct.num_cte = b.numcte
					WHERE b.empresa = pEmpresa AND b.telefono = pCuenta;

					IF (vProd = "" OR vProd IS NULL) THEN
						LET Cod_ret = "002"; --no se encontraron los datos
					ELSE
						LET Cod_ret = "000";
					END IF;
		END IF;

	ELSE
		LET Cod_ret = "001";	END IF;
	LET vProducto = vProd || " " || vProdNom;
	LET vNomCompleto = TRIM(vNombre1)|| " " ||TRIM(vNombre2) || " " || TRIM(vApell_pat)|| " " ||TRIM(vApell_mat);
    IF TRIM(NVL(vNomCompleto,'')) = '' THEN
        LET vNomCompleto = vRazonSocial;
    END IF;


 return Cod_ret,vProducto,vNomCompleto;

 END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_obtenerdatos_mismobanco_credito(pEmpresa char(3), pCuenta char(16),tipoOp int)
 returning char (5), char (42), char (104);

 --Creado: Manuel Ramos
 --Fecha:13/06/06.
 --Actividad: Retorna el nombre del cliente, el número del producto y su descripción
 --
 --Creado: Alfonso Cruz
 --Fecha:24/10/13.
 --Actividad: Modificación de parámetros de entrada, se agrega el tipoOp para identificar si es alta, edición ó eliminación
 -- SE AGREGA CAMBIO EN LA OBTENCIÓN DEL PRODUCTO DE LA TARJETA
 
 -- Se modifica la forma en que se extrae el producto de la tarjeta, ligandolo a la tabla sd_maecred
 -- 10/12/2013
 -- Bibiana Gaxiola Verdugo.
 
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
 LET vNomCompleto = "";
 LET vProducto = "";
 
--SET DEBUG FILE TO '/home/informix/bibiana/sp_obtenerdatos_mismobanco_credito.out';
--TRACE ON;
 
 BEGIN
 ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
		LET Cod_ret = sql_err;
		return Cod_ret,vProducto,vNomCompleto;
	END IF;
 END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
   IF (pCuenta <> "") THEN
		IF (LENGTH(pCuenta)=16) THEN
			IF(tipoOp==1) THEN
				SELECT d.num_producto,e.nombre_prod,c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
				INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
				FROM intercard:"informix".tarjeta a
				--INNER JOIN bdicred:"informix".sd_tarjeta b on b.num_tarjeta = a.numtarjeta
				--INNER JOIN bdicred:"informix".sd_definicion d on b.prodtarjeta = d.num_producto
				--INNER JOIN bdinteg:"informix".si_cliente c on b.numcte = c.numcte
				INNER JOIN bdicred:"informix".sd_tarjeta b on b.num_tarjeta = a.numtarjeta 
				INNER JOIN bdinteg:"informix".si_cliente c on b.numcte = c.numcte
				INNER JOIN bdicred:"informix".sd_maecred d on b.num_credito = d.num_credito
				INNER JOIN bdicred:"informix".sd_definicion e on d.num_producto = e.num_producto 
				WHERE b.empresa = pEmpresa AND b.num_tarjeta = pCuenta AND a.codstatustarjeta = 'ACT';
			ELIF(tipoOp IN (2,3)) THEN
				SELECT d.num_producto,e.nombre_prod,c.nombre1,c.nombre2,c.apell_paterno,c.apell_materno,c.razon_social
				INTO vProd,vProdNom,vNombre1,vNombre2,vApell_pat,vApell_mat,vRazonSocial
				FROM intercard:"informix".tarjeta a
				INNER JOIN bdicred:"informix".sd_tarjeta b on b.num_tarjeta = a.numtarjeta 
				INNER JOIN bdinteg:"informix".si_cliente c on b.numcte = c.numcte
				INNER JOIN bdicred:"informix".sd_maecred d on b.num_credito = d.num_credito
				INNER JOIN bdicred:"informix".sd_definicion e on d.num_producto = e.num_producto 
				WHERE b.empresa = pEmpresa AND b.num_tarjeta = pCuenta;
			END IF;
			
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
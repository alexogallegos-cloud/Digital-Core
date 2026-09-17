CREATE PROCEDURE "informix".sp_productos_validos(pPago CHAR(4))
RETURNING CHAR(4),CHAR(50);

	/*
	'AUTOR: Ing. Cruz',
	'Proyecto: ECI, ARABELA',
	'Folio: 1313',
	'Solicito: Jose de Jesus Nevarez',
	'Descripcion: SP PARA LA LECTURA DE PARAMETROS DE PRODUCTOS DE CUENTAS PARAMETRIZANDO EL ID_OPER',
	'Fecha: 28/05/2012',
	*/
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(4);
	DEFINE sql_err INTEGER ;
	DEFINE vProducto CHAR(4);
	DEFINE vProductos CHAR(50);

	LET vCod_Ret   ='0000';
	LET sql_err    = 0;
	LET vProducto  ='';
	LET vProductos = '';



	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,NVL(vProductos,'');
		  END IF ;
		END EXCEPTION ;
		
			FOREACH
				SELECT producto
				INTO vProducto
				FROM bdibpi:"informix".bpi_pprod
				WHERE id_oper = pPago
				ORDER BY id_oper
					
				LET vProductos=TRIM(vProductos)||TRIM(NVL(vProducto,''));
			
			END FOREACH;	
			
			RETURN NVL(vCod_Ret,'0000'),NVL(TRIM(vProductos),'');
		END;
END PROCEDURE;
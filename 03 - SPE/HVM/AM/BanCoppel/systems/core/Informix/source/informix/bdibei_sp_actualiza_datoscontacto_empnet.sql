CREATE PROCEDURE "informix".sp_actualiza_datoscontacto_empnet(
                                           pIdCliente  CHAR(9),
                                           pIdUsuario INTEGER,
                                           pRepresentanteLegal CHAR(100),
                                           pTelFijo CHAR(15),
										   pTelCel CHAR(15),
										   pEmail CHAR(35),
                                           pEmailAlternativo CHAR(35),
                                           pPagInternet CHAR(35)
)
RETURNING CHAR (5);

	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
  	
    LET vCod_ret = '00000';
        

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCod_ret = sql_err;
				RETURN vCod_ret;
			END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        

		IF NVL(pIdCliente,'') =='' OR NVL(pIdUsuario,'') =='' OR NVL(pRepresentanteLegal,'') ==''  OR NVL(pTelFijo,'') =='' OR NVL(pTelCel,'') =='' OR NVL(pEmail,'') =='' THEN
            LET vCod_ret = '00001'; -- Datos incompletos
            RETURN vCod_ret;
        END IF;
        
        IF EXISTS (SELECT 1 FROM bdibei:"informix".bei_datos_empnet  WHERE id_cliente = pIdCliente AND  id_usuario = pIdUsuario) THEN
            UPDATE bdibei:"informix".bei_datos_empnet SET representante_legal = pRepresentanteLegal, 
            tel_fijo = pTelFijo,tel_celular= pTelCel, correo = pEmail, correo_alternativo = pEmailAlternativo,
             pagina_internet = pPagInternet, fecha_actualizacion = CURRENT YEAR TO SECOND
            WHERE id_cliente= pIdCliente AND  id_usuario = pIdUsuario;
          
           
            
        ELSE          
            INSERT INTO bdibei:"informix".bei_datos_empnet(id_cliente,id_usuario,representante_legal,tel_fijo,tel_celular,correo,correo_alternativo,pagina_internet,fecha_registro)
            VALUES (pIdCliente,pIdUsuario,pRepresentanteLegal, pTelFijo,pTelCel,pEmail,pEmailAlternativo,pPagInternet,CURRENT YEAR TO SECOND);
           
        END IF;

		RETURN vCod_ret;
	END;
END PROCEDURE;
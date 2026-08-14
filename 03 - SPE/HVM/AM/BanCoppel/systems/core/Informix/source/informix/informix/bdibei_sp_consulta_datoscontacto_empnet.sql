CREATE PROCEDURE "informix".sp_consulta_datoscontacto_empnet( pIdCliente  CHAR(9), pIdUsuario INTEGER)
   returning  CHAR(5), CHAR(100),CHAR(15),CHAR(15),CHAR(35),CHAR(35),CHAR(35);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;
    
    DEFINE sIdUsuario INTEGER;
    DEFINE sRepresentanteLegal CHAR(100);
    DEFINE sTelFijo CHAR(15);
    DEFINE sTelCel CHAR(15);
    DEFINE sEmail CHAR(35);
    DEFINE sEmailAlternativo CHAR(35);
    DEFINE sPagInternet CHAR(35);

    LET cod_ret  = "00000";
   	LET sIdUsuario = 0;
    LET sRepresentanteLegal = '';
    LET sTelFijo = '';
    LET sTelCel ='';
    LET sEmail ='';
    LET sEmailAlternativo ='';
    LET sPagInternet = '';
	

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sRepresentanteLegal, sTelFijo, sTelCel, sEmail, sEmailAlternativo, sPagInternet;
      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
        
        IF NVL(pIdCliente,'') =='' THEN
            LET cod_ret = '00001'; 
            RETURN cod_ret,sRepresentanteLegal, sTelFijo, sTelCel, sEmail, sEmailAlternativo, sPagInternet;
        END IF;

        IF NVL(pIdUsuario,'') =='' OR (pIdUsuario==0) THEN
            SELECT FIRST 1 id_usuario, representante_legal, tel_fijo, tel_celular, correo, correo_alternativo, pagina_internet
            INTO sIdUsuario, sRepresentanteLegal, sTelFijo, sTelCel, sEmail, sEmailAlternativo, sPagInternet
            FROM bdibei:"informix".bei_datos_empnet 
            WHERE id_cliente= pIdCliente;
            
        ELSE
            SELECT id_usuario, representante_legal, tel_fijo, tel_celular, correo, correo_alternativo, pagina_internet
            INTO sIdUsuario, sRepresentanteLegal, sTelFijo, sTelCel, sEmail, sEmailAlternativo, sPagInternet
            FROM bdibei:"informix".bei_datos_empnet 
            WHERE id_cliente= pIdCliente AND id_usuario = pIdUsuario ;
        END IF;

   		IF(sIdUsuario IS NULL) OR (sIdUsuario==0) THEN
			LET cod_ret = '00002';  
		END IF;


  RETURN cod_ret,sRepresentanteLegal, sTelFijo, sTelCel, sEmail, sEmailAlternativo, sPagInternet;

END
END PROCEDURE;
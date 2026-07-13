CREATE PROCEDURE "informix".sp_reset_usuario_bei(pIdUsuario INTEGER)
   returning char(5);


   DEFINE cCod_ret char(5);
   DEFINE sql_err integer;
   DEFINE vnum_cliente char(9);



	DEFINE sPass                   	CHAR(50);
   	DEFINE sFpass                   	DATE;
   	DEFINE sPass1                    CHAR(50);
   	DEFINE sFpass1                  	DATE;
   	DEFINE sPass2                    CHAR(50);
   	DEFINE sFpass2                  	DATE;
   	DEFINE sPass3                    CHAR(50);
   	DEFINE sFpass3                  	DATE;

   LET cCod_ret       = "00000";
   LET vnum_cliente   ="000000000";

	--****************************************************************************************************
	-- DESCRIPCION: Realiza Reset Usuario
	-- AUTOR : Irving Guzman Salas - SOLSER
	-- FECHA : 24/05/2013
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	--
	-- MODIFICACIÓN: Se actualiza para que borre el registro de Avatar.
	-- MODIFICO:Berenice Noriega Guevara - BanCoppel
	-- SOLICITO: Alejandro Vazquez - BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	
	--***************************************************************************************************
	


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	    IF NVL(pIdUsuario,'') =='' THEN
	 	  LET cCod_ret = '00001'; -- No contiene Dato ID de Usuario
       RETURN cCod_ret;
	END IF;


	 IF EXISTS (SELECT id_usuario FROM "informix".bei_usuario
   				WHERE id_usuario=pIdUsuario) THEN


	DELETE "informix".bei_datos_usuario WHERE id_usuario=pIdUsuario;

	--Borrar Avatar------------------------------------------------------------------------------

	SELECT num_cliente INTO vnum_cliente FROM "informix".bei_usuario WHERE id_usuario=pIdUsuario;
	EXECUTE PROCEDURE "informix".sp_reset_avatar_bei(vnum_cliente, pIdUsuario) into cCod_ret;

	---------------------------------------------------------------------------------------------

	SELECT pass,f_pass,pass1,f_pass1,pass2,f_pass2,pass3,f_pass3
    	INTO sPass,sFpass,sPass1,sFpass1,sPass2,sFpass2,sPass3,sFpass3
    	FROM bei_usuario
    	WHERE id_usuario=pIdUsuario;


    	LET sPass3=sPass2;
    	LET sFpass3=sFpass2;

    	LET sPass2=sPass1;
    	LET sFpass2=sFpass1;

    	LET sPass1=sPass;
    	LET sFpass1=sFpass;

    	LET sPass='';

    	    UPDATE "informix".bei_usuario
    	    SET
    	    usuario_bei='RESETUSUARIO'||pIdUsuario,
    	    pass=NULL,
    	    f_pass=CURRENT YEAR TO DAY ,
    	    pass1=sPass1,
    	    f_pass1=sFpass1,
    	    pass2=sPass2,
    	    f_pass2=sFpass2,
    	    pass3=sPass3,
    	    f_pass3=sFpass3
			WHERE id_usuario=pIdUsuario;
    ELSE
     	LET cCod_ret       = "00002";
	END IF

    RETURN cCod_ret;

END

END PROCEDURE ;
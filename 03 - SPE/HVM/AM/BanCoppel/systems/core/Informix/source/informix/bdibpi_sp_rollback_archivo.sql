CREATE PROCEDURE "informix".sp_rollback_archivo(pNombreArch char(17),
												pNumEmp char(10),
												pIdEmpresa CHAR(3))
 RETURNING char(5);

 	--****************************************************************************************************
	-- DESCRIPCION: APLICA ROLLABACK A LA TABLA DISPERSARCHIVO PARA ELIMINAR REGISTRO, EN CASO DE ALGUN ERROR EN LA DISPERSION
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 07/10/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio León
	--****************************************************************************************************

   --Declaración de variabled
   DEFINE vCodRet char(5);
   DEFINE sql_err integer;


   --asigacion de valores a variables
   LET vCodRet='00000';

 --set debug file to "/tmp/manuel/sp_rollback_archivo.out";
 --trace on;

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet;
      END IF ;
   END EXCEPTION ;

   SET LOCK MODE TO WAIT 3;

   DELETE bdibpi:"informix".bpi_dispersarchivo WHERE id_empresa=pIdEmpresa AND nombre_archivo=pNombreArch;
   RETURN vCodRet;
   END;
 END PROCEDURE
;
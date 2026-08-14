CREATE PROCEDURE "informix".sp_validarpermisousuariocac(p_Ejecutivo CHAR(8))
RETURNING
	CHAR(5); ---cod_ret

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	---INICIALIZACIONES
	LET v_cod_ret = '00000';

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret;
    END EXCEPTION;

	
	---SET DEBUG FILE TO "/tmp/has/sp_validarpermisousuariocac.out";
	---TRACE ON;

	IF p_Ejecutivo = "" OR p_Ejecutivo IS NULL THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret;
	END IF
	
	IF NOT EXISTS(SELECT ejecutivo FROM bdinteg: si_perfil_ejecut WHERE ejecutivo = p_Ejecutivo AND sistema = "06")  THEN
		LET v_cod_ret = "00002";
		RETURN v_cod_ret;
	END IF
	
	IF NOT EXISTS(SELECT empleado FROM bdicred: sd_super_cancred WHERE empleado = p_Ejecutivo AND status = 1 AND aplicativo = "CCONCAC.EXE") THEN
		LET v_cod_ret = "00003";
		RETURN v_cod_ret;
	END IF
	

	RETURN v_cod_ret;
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para validar los permisos de usuarios',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_marca1()
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cuenta char(20);
   DEFINE sql_err,isam_err int; 

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cuenta    = "";



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

        FOREACH WITH HOLD
            SELECT num_credito
            INTO v_cuenta
            FROM paso_cred_marca1

            BEGIN WORK;

            update bdicred:sd_encabezado_edocta set insertos = '100000000000000' where fecha_emision = today - 3 and num_credito = v_cuenta;

            COMMIT WORK;

        END FOREACH;
END;    

RETURN v_codret;

END PROCEDURE;
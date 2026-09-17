CREATE PROCEDURE "informix".sp_depura_movdiacrd()

RETURNING char(6),char(100);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(100);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE cnumcredito  char(20);
    DEFINE ccontador    integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    DEFINE pmovtos      integer;
    DEFINE vrowid       integer;
    DEFINE vnumcredito  CHAR(20);
    DEFINE dFechaMov	date;    
    DEFINE iContador    integer;
	DEFINE isecuencia   integer;
	DEFINE icuentas		integer;

  BEGIN



    ON EXCEPTION SET sql_err,isam_err,cMensaje
	  IF sql_err != 0 THEN
		  LET cCodRet = sql_err;
		  LET cMensaje="Error informix "||trim(vnumcredito);
		  DROP TABLE paso_movcrd;
		  RETURN cCodRet,cMensaje;
	  END IF;

   END EXCEPTION;

   let vrowid  = 0;
   LET ccontador=0;
   LET cMensaje="Proceso Exitoso";
   LET cCodRet='000000';
   let pmovtos = 0;
   LET vnumcredito     = "";
   LET dFechaMov = date(1);
   LET iContador = 0;
   LET isecuencia = 0;
   LET icuentas = 0;

-- SET DEBUG FILE TO "/pisa/cas/sp_mueve_movdiacrd.out";
-- TRACE ON;

   --LET cCodRet='000';

   set isolation to dirty read;
   set lock mode to wait 3;

    SELECT num_credito,fecha_mov, secuencia
      FROM bdicred:sd_movdiacrd
     WHERE empresa = '001'
       AND fecha_mov < today
      INTO temp paso_movcrd WITH NO LOG;

--      CREATE INDEX inx_paso_movcrd ON paso_movcrd(num_credito);
      UPDATE STATISTICS MEDIUM FOR TABLE paso_movcrd;


       FOREACH WITH HOLD 
            SELECT num_credito, fecha_mov, secuencia
             INTO vnumcredito, dFechaMov, isecuencia
             FROM paso_movcrd

			 LET iContador = iContador + 1;

			 SELECT count(*) into icuentas FROM bdicred:sd_movhiscrd
                     WHERE empresa = '001'
					 AND fecha_mov = dFechaMov
                     AND num_credito = vnumcredito
					 AND secuencia = isecuencia;

					 

					 IF icuentas  > 0 THEN 

						 BEGIN WORK;  
						  DELETE FROM bdicred:sd_movdiacrd
						   WHERE empresa = '001'
							 AND fecha_mov = dFechaMov
							 AND num_credito = vnumcredito
							 AND secuencia = isecuencia;
							COMMIT WORK;

						CONTINUE FOREACH;
					 END IF

               BEGIN WORK;
                  INSERT INTO bdicred:sd_movhiscrd
                  SELECT * FROM bdicred:sd_movdiacrd 
                   WHERE empresa = '001'
					 AND fecha_mov = dFechaMov
                     AND num_credito = vnumcredito
					 AND secuencia = isecuencia;


                  DELETE FROM bdicred:sd_movdiacrd                
                   WHERE empresa = '001'
					 AND fecha_mov = dFechaMov
                     AND num_credito = vnumcredito
					 AND secuencia = isecuencia;

               COMMIT WORK;

       END FOREACH;

	   DROP TABLE paso_movcrd;

	   LET cMensaje = trim(cMensaje) || '. Cuentas depuradascrd -> ' || iContador;

	   RETURN cCodRet,cMensaje;
	  
  END;

END PROCEDURE;
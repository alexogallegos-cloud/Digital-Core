CREATE PROCEDURE "informix".borra_ctasduplicadas()
RETURNING CHAR(5) as codRet;

DEFINE vcodret      CHAR(5);
DEFINE vcodret2     CHAR(5);
DEFINE vcodret3     CHAR(50);
DEFINE vsqlerr      INT;
DEFINE visamerr     INT;
DEFINE vdescerr     CHAR(50);
DEFINE vContador	INT;
DEFINE vCommit		INT;
DEFINE vCuantos		INT;
DEFINE vExiste 		INT;
DEFINE vCuenta 		CHAR(20);
DEFINE iContador    INT;

LET vcodret     = '00000';
LET vcodret2    = '';
LET vcodret3    = '';
LET vsqlerr     = 0;
LET visamerr    = 0;
LET vContador	= 0;
LET vCommit		= 1000;
LET vCuantos	= 0;
LET vExiste 	= 0;
LET vCuenta 	= '';
LET iContador   = 0;

BEGIN

	ON EXCEPTION SET vsqlerr, visamerr, vdescerr
	SET DEBUG FILE TO "/RESPALDOSNEW/borra_ctasduplicadas.err";
	TRACE ON;

	IF vsqlerr <> 0 THEN
		LET vcodret  = vsqlerr;
		LET vcodret2 = visamerr;
		LET vcodret3 = vdescerr;
		RETURN vcodret;
	END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/RESPALDOSNEW/borra_ctasduplicadas.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

		BEGIN WORK; 
       	FOREACH WITH HOLD	   
			SELECT {+INDEX (sc_ctasinformadas idx_sc_ctasinformadas_comp)} count(*)
			INTO vExiste 
			FROM bdicheq:sc_ctasinformadas
			WHERE fecha_marc = '03022024'

			IF vExiste > 0 THEN

				DELETE {+INDEX (sc_ctasinformadas idx_sc_ctasinformadas_comp)} FROM bdicheq:sc_ctasinformadas 
				WHERE cuenta NOT IN (SELECT {+INDEX (sc_ctasinformadas idx_sc_ctasinformadas_comp)} 
									 DISTINCT (cuenta) FROM sc_ctasinformadas WHERE cuenta = '10119921177')
				AND fecha_marc = '03022024';

				LET iContador = iContador + 1;

				IF iContador = 1000 THEN
					COMMIT;
					LET iContador = 0;
					BEGIN WORK;      
				END IF;
			ELSE
				LET vcodret = '00000';
			END IF;
				  
       END FOREACH;
       COMMIT;
	
	LET vCuantos = vCuantos + vContador;

	IF vContador > 0 THEN
		COMMIT WORK;
	END IF;

	LET vcodret = '00000';
	RETURN vcodret;
	END;
END PROCEDURE;
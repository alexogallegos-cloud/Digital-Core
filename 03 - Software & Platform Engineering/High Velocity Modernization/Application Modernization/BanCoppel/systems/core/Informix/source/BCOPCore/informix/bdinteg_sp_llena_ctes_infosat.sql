CREATE PROCEDURE  "informix".sp_llena_ctes_infosat()
       returning CHAR(5)  AS Cod_Retorno;

DEFINE vcodret     CHAR(5);
DEFINE vsqlerr     INTEGER;
DEFINE ultcte      CHAR(9);
DEFINE iContador   INTEGER;
DEFINE sCommit     SMALLINT;
DEFINE sEmpresa    CHAR(3);
DEFINE sNumcte     CHAR(20); 


BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

LET vcodret="00000";
LET ultcte='';
LET iContador = 0;
LET sCommit = 0;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "/informix/OMC/sp_llena_ctes_infosat.out";
--TRACE ON;

            --Obteniendo el ultimo cliente generado con la info para el SAT
			  SELECT valor INTO ultcte
			  FROM si_param WHERE empresa='001' AND cod_param='139';	
			  
            --Obteniendo los registros de clientes ordenados
            SET ISOLATION TO DIRTY READ;
            FOREACH WITH HOLD
                SELECT LIMIT 1000000  empresa, numcte
				INTO sEmpresa, sNumcte
                FROM bdinteg:si_cliente
                WHERE empresa='001' AND tpo_persona='01'
                AND tipo_cliente='1' AND numcte >ultcte ORDER BY numcte
                

            --Llenando la tabla de control
                
                IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iContador = 0;
					LET sCommit = -1;
                END IF;
                
                INSERT INTO si_ctessat(empresa, numcte,estatus_proc)
                VALUES(sEmpresa, sNumcte, 0);

				LET iContador = iContador  + 1;	
				
                --Ejecutar un commit cada 10000 registros.
                IF (iContador >= 10000) THEN
                    COMMIT WORK;	
                    LET iContador = 0;				
                    BEGIN WORK;
                END IF;	
			END FOREACH;

            IF sCommit = -1 THEN
            	COMMIT WORK;                
            END IF;
            LET sCommit = 0;
			
END;
return vcodret;   
END PROCEDURE;
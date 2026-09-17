CREATE PROCEDURE "informix".sp_actualizarfc_prospectos()
RETURNING CHAR(5) as codret, CHAR(5) as codret2, CHAR(5) as mensaje;

DEFINE vcodret1         char(5); 
DEFINE vcodret2         char(5);
DEFINE vcodret3         char(50);
DEFINE sql_err          integer;
DEFINE isam_err         integer;
DEFINE desc_err         char(50);
DEFINE vnumcte          char(10);
DEFINE vrfc_calculado   char(13);
DEFINE vcomienza        smallint;
DEFINE ven_transacc     smallint;
DEFINE vcontador1       integer;

LET vcodret1            ='00000';
LET vcodret2            ='0000';
LET vcodret3            ='PROCESO CONCLUIDO SATISFACTORIAMENTE';
LET sql_err             =0;
LET isam_err            =0;
LET desc_err            ='';
LET vcomienza           =-1;
LET ven_transacc        = 0;  
LET vnumcte             ='';
LET vrfc_calculado      ='';
LET vcontador1          =0;



BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/arch_sp_actualizarfc.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;

            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD
        select  numcte, rfc_calculado INTO vnumcte,  vrfc_calculado from bdinteg:resultadosrfc_prospectos where rfc_duplicado=0
    
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        UPDATE bdiprospectos:pr_cliente set rfc=vrfc_calculado where numcte_pros=vnumcte;

        LET vcontador1 = vcontador1 + 1;
        

        IF (vcontador1 >= 5000) THEN
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
     END FOREACH;

     IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
     END IF;

END;
RETURN vcodret1, vcodret2, vcodret3; 
END PROCEDURE;
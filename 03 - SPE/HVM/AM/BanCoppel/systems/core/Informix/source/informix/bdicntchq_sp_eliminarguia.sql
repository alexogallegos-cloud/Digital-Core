CREATE PROCEDURE "informix".sp_eliminarguia(
pguia1 char(20),
pguiaf char(20))
RETURNING CHAR(5);
--DECLARACION DE VARIABLES

DEFINE vc_CodRet    CHAR(5);
DEFINE vi_sqlerr        INTEGER;
DEFINE vi_ac        INT8;
DEFINE vi_fi        INT8;
DEFINE vi_si        INT8;
DEFINE vi_re        INT8;
DEFINE vi_gr        INT8;
DEFINE vi_total        INTEGER;
DEFINE vi_total2        INTEGER;
DEFINE vi_id        INTEGER;
DEFINE vi_in        INT8;
DEFINE INI          INTEGER;
--INICIALIZACION DE VARIABLES
LET vc_CodRet="00000";
LET vi_ac="0";
LET vi_fi="0";
LET vi_si="0";
LET vi_re="0";
LET vi_gr ="0";
LET vi_total="0";
LET vi_total2="0";
LET vi_id="0";
LET vi_in="0";
LET INI="0";

--  SET DEBUG FILE TO "/tmp/sp_eliminaguias.out";
--  TRACE ON;

BEGIN

   ON EXCEPTION SET vi_SqlErr
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            RETURN vc_CodRet;
        END IF;
   END EXCEPTION;
   
    LET vi_total=(pguiaf +1 )  - pguia1;
    LET vi_total2=vi_total;


    FOR INI=1 TO vi_total
        select guia_inicial,guia_final,guia_actual,guia_siguiente,guia_restante,guia_restante_gral,id INTO vi_in,vi_fi,vi_ac,vi_si,vi_re,vi_gr,vi_id from sq_guias WHERE guia_activo=1;
        if vi_total2<>0 then
            if vi_in=vi_ac then
                update sq_guias set guia_actual=0,guia_siguiente=0, guia_restante=0,guia_restante_gral=0,guia_activo=0 WHERE id=vi_id;
                update sq_guias set guia_activo=1,guia_restante_gral=vi_gr WHERE id=vi_id -1;
            elif vi_ac=0 and vi_si=0 and vi_re=0 then
                update sq_guias set guia_activo=1 WHERE id=vi_id-1;
                update sq_guias set guia_activo=0 WHERE id=vi_id;
                update sq_guias set guia_actual=guia_actual - vi_total,guia_siguiente=guia_siguiente - vi_total, guia_restante=guia_restante + vi_total,guia_restante_gral=vi_gr WHERE guia_activo=1;
                update sq_guias set guia_restante_gral=0 where guia_activo=0;
                exit for;
            else
                if vi_si=0 then
                    update sq_guias set guia_actual=guia_actual - 1,guia_siguiente=guia_actual, guia_restante=vi_fi - vi_ac,guia_restante_gral=guia_restante_gral + 1 WHERE guia_activo=1 and id=vi_id;
                else
                    update sq_guias set guia_actual=guia_actual - 1,guia_siguiente=guia_siguiente - 1, guia_restante=vi_fi - vi_ac,guia_restante_gral=guia_restante_gral + 1 WHERE guia_activo=1 and id=vi_id;
                end if;    
            end if;
                    --update sq_guias set guia_restante=vi_fi - vi_ac WHERE guia_activo=1 and id=vi_id;
        end if;
        LET vi_total2=vi_total2 - 1;
        RETURN vc_CodRet WITH RESUME;
    END FOR	
    delete from sq_bitacora_guias where no_guia>=pguia1 and no_guia<=pguiaf;
    select guia_inicial,guia_final,guia_actual,guia_siguiente,guia_restante,guia_restante_gral,id INTO vi_in,vi_fi,vi_ac,vi_si,vi_re,vi_gr,vi_id from sq_guias WHERE guia_activo=1;
    if vi_fi=vi_ac then
        update sq_guias set guia_activo=0,guia_restante_gral=0 where id=vi_id;
        update sq_guias set guia_activo=1,guia_restante_gral=vi_gr  where id=vi_id + 1;
    else
        update sq_guias set guia_restante=vi_fi - vi_ac WHERE guia_activo=1 and id=vi_id;
    end if;
    select count(*) into INI from sq_guias WHERE guia_activo=1;
    if INI=0 then
        select first 1 id into vi_id from sq_guias WHERE guia_activo=0;
        update sq_guias set guia_activo=1 where id=vi_id;
    end if;
END;
END PROCEDURE;
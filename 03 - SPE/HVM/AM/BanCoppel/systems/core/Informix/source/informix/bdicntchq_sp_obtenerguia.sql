CREATE PROCEDURE "informix".sp_obtenerguia(
pcliente char(20),
pcuenta  char(20),
ptipo    char(2),
pconsec  char(10))
RETURNING CHAR(5),INT8, INT8,INT8,INTEGER;
--DECLARACION DE VARIABLES
DEFINE v_siguiente    INT8;
DEFINE v_final    INT8;
DEFINE v_restan  INT8;
DEFINE v_actual  INT8;
DEFINE v_id  INTEGER;
DEFINE vc_CodRet    CHAR(5);
DEFINE vi_sqlerr        INTEGER;
DEFINE v_cant        INT8;
DEFINE v_cant2        INT8;
DEFINE v_idact        INTEGER;
DEFINE v_gi        INT8;
DEFINE v_gf        INT8;
DEFINE v_guia_gral        INTEGER;
DEFINE v_guia_gral2        INTEGER;
DEFINE v_res                INTEGER;
DEFINE v_ga                INTEGER;
DEFINE v_CG                INTEGER;
DEFINE v_II                INTEGER;
DEFINE v_GT                INT8;
DEFINE v_GT2                INT8;
--INICIALIZACION DE VARIABLES
LET v_siguiente = "0";
LET v_final = "0";
LET v_restan = "0";
LET vc_CodRet="00000";
LET v_cant="0";
LET v_cant2="0";
LET v_idact="0";
LET v_actual="0";
LET v_guia_gral="0";
LET v_guia_gral2="0";
LET v_gi="0";
LET v_gf="0";
LET v_res="0";
LET v_ga="0";
LET v_CG ="0";
LET v_II="0";
LET v_GT="0";
LET v_GT2="0";

  --SET DEBUG FILE TO "/tmp/sp_guias.out";
  --TRACE ON;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet,v_actual,v_siguiente, v_final,v_guia_gral2;
    END IF;
  END EXCEPTION;


 SELECT nvl(guia_restante_gral, 0) INTO v_res from sq_guias where guia_activo=1 AND guia_actual<>0;

 IF v_res=0 THEN
    LET vc_CodRet = "00001";
    RETURN vc_CodRet,0,0, 0,0;
 END IF;
 SELECT nvl(id, 0) INTO v_idact from sq_guias where guia_activo=1;
 --SELECT nvl(MAX(guia_restante), 0) INTO v_cant from sq_guias where id=v_idact;
 SELECT nvl(guia_restante_gral, 0),nvl(guia_actual, 0) INTO v_cant,v_cant2 from sq_guias where id=v_idact;

 IF v_cant>=1 THEN   
    if v_cant2=0 then
        SELECT nvl(MAX(guia_inicial), 0) + 1 into v_siguiente from sq_guias where guia_activo=1 and id=v_idact;
        update sq_guias set guia_actual=v_siguiente - 1 where guia_activo=1 and id=v_idact;
        update sq_guias set guia_siguiente=v_siguiente where guia_activo=1 and id=v_idact;
        SELECT nvl(MAX(guia_final), 0) into v_restan from sq_guias where guia_activo=1 and id=v_idact;
        update sq_guias set guia_restante=v_restan - (v_siguiente-1) where guia_activo=1 and id=v_idact;

    else
        SELECT nvl(MAX(guia_siguiente), 0) + 1 into v_siguiente from sq_guias where guia_activo=1 and id=v_idact;
        update sq_guias set guia_actual=v_siguiente - 1 where guia_activo=1 and id=v_idact;
        update sq_guias set guia_siguiente=v_siguiente where guia_activo=1 and id=v_idact;
        SELECT nvl(MAX(guia_restante), 0) - 1 into v_restan from sq_guias where guia_activo=1 and id=v_idact;
        update sq_guias set guia_restante=v_restan where guia_activo=1 and id=v_idact;
    end if
  ELSE
    SELECT nvl(MAX(guia_inicial), 0) + 1 into v_siguiente from sq_guias where guia_activo=1 and id=v_idact;
    update sq_guias set guia_actual=v_siguiente - 1 where guia_activo=1 and id=v_idact;
    update sq_guias set guia_siguiente=v_siguiente where guia_activo=1 and id=v_idact;
    SELECT nvl(MAX(guia_final), 0) into v_restan from sq_guias where guia_activo=1 and id=v_idact;
    update sq_guias set guia_restante=v_restan - (v_siguiente-1) where guia_activo=1 and id=v_idact;

  END IF;
  select guia_actual,guia_restante,id into v_actual,v_final,v_id from sq_guias where guia_activo=1 and id=v_idact;
  SELECT nvl(guia_restante_gral, 0) INTO v_guia_gral from sq_guias where guia_activo=1;
  select nvl(sum(guia_inicial),0),nvl(sum(guia_final),0) into v_gi,v_gf from sq_guias where guia_activo=0 and guia_siguiente=0;

  update sq_guias set guia_restante_gral=(v_final + 1) + (v_gf - v_gi) where guia_activo=1 and id=v_idact;
  LET v_guia_gral2=(v_final + 1) + (v_gf - v_gi);



  if v_final=0 then
    update sq_guias set guia_activo=0 where guia_activo=1 and id=v_id;
    update sq_guias set guia_activo=1,guia_restante_gral=v_guia_gral2 where id=v_id+1;
    SELECT nvl(guia_inicial,0) into v_siguiente from sq_guias where guia_activo=1 and id=v_idact+1;
    if v_siguiente is null then
        let v_siguiente=0;
    end if;
    update sq_guias set guia_siguiente=v_siguiente where id=v_id;
    update sq_guias set guia_restante_gral=0 where id=v_id;
  end if;
    delete from sq_bitacora_guias where no_guia=v_actual;
    if v_actual is null then
        LET vc_CodRet = "00001";
        RETURN vc_CodRet,0,0, 0,0;
    end if;
    insert into sq_bitacora_guias(no_guia,cuenta,num_cte,fecha_asigna,tipo_envio)values(v_actual,pcuenta,pcliente,current,ptipo);
    select COUNT(*) into v_CG  from sq_guias where guia_activo=0; 
    select first 1 id into v_idact from sq_guias;  

for v_II=1 to v_CG + 1
    select guia_inicial,guia_final,guia_actual,guia_activo into v_gi,v_gf,v_final,v_ga from sq_guias where id=v_idact;
        if v_final="0" then
            LET v_GT=(v_gf - v_gi); 
        else
            LET v_GT=(v_gf - v_final);
        end if;    
        LET v_idact=v_idact+1;
        LET v_GT2=v_GT2 + v_GT;
end for

    LET v_guia_gral2=v_GT2;
    update sq_guias set guia_restante_gral=v_guia_gral2 where guia_activo=1;
    update sq_maechqra set status='E' where cuenta=pcuenta and consec=pconsec;
    update sq_envios set no_guia=v_final, resp_msg='E'  where num_cuenta=pcuenta and folio_chequera=pconsec;
    RETURN vc_CodRet,v_actual,v_siguiente, v_final,v_guia_gral2 WITH RESUME;
   

END;
END PROCEDURE;
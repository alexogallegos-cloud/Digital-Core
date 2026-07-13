CREATE PROCEDURE "informix".sp_obtenerdoctos(pNumeroCliente CHAR(20), inicia  smallint,pnum_regs  smallint)
RETURNING CHAR(5), CHAR(4), CHAR(35), CHAR(20), SMALLINT, CHAR(10),CHAR(50);
--DECLARACION DE VARIABLES
DEFINE vc_CodRet    CHAR(5);
DEFINE vc_CodDocto  CHAR(4);
DEFINE vc_DesDocto  CHAR(35);
DEFINE vc_Cuenta    CHAR(20);
DEFINE vs_Secuencia SMALLINT;
DEFINE vs_Fecha     DATE;
DEFINE vs_descrip   CHAR(50);
DEFINE vi_SqlErr    INTEGER;
DEFINE v_contador        smallint;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vc_CodDocto = "";
LET vc_DesDocto = "";
LET vc_Cuenta = "";
LET vi_SqlErr = 0;
LET vs_Secuencia = 0;
LET vs_Fecha=today;
LET vs_descrip="";
LET v_contador= 0;

  --SET DEBUG FILE TO "/tmp/sp_obtenerdoctos.out";
  --TRACE ON;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia,vs_Fecha,vs_descrip;
    END IF;
  END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   FOREACH
        SELECT exp.cod_docto, exp.cuenta, exp.secuencia,docto.descripcion,exp.fecha_alta,exp.descrip2
        INTO vc_CodDocto, vc_Cuenta, vs_Secuencia, vc_DesDocto,vs_Fecha,vs_descrip
        FROM bdidigital@coppelimg_tcp:dg_expediente exp,
        bdidigital@coppelimg_tcp:dg_tipodocumento docto,bdidigital@coppelimg_tcp:dg_grupodocto gd
        WHERE cliente = pNumeroCliente 
        -- WHERE cliente = pNumeroCliente and exp.empresa='001'
        and exp.cod_docto=docto.cod_docto
        and docto.cod_grupo= gd.cod_grupo
		and gd.cod_grupo 
        NOT IN (select MAX(cod_grupo) 
        from bdidigital@coppelimg_tcp:dg_tipodocumento 
        where cod_docto IN ('0133')) 
        and gd.cod_grupo 
        NOT IN (select MAX(cod_grupo) 
        from bdidigital@coppelimg_tcp:dg_tipodocumento 
        where cod_docto IN ('0201')) 
        and gd.cod_grupo 
        NOT IN (select MAX(cod_grupo) 
        from bdidigital@coppelimg_tcp:dg_tipodocumento 
        where cod_docto IN ('0938')) 
		UNION
        SELECT exp.cod_docto, exp.cuenta, exp.secuencia,docto.descripcion,exp.fecha_alta,exp.descrip2
        FROM bdidigital@coppelimg_tcp:dg_expediente exp,
        bdidigital@coppelimg_tcp:dg_tipodocumento docto,bdidigital@coppelimg_tcp:dg_grupodocto gd
        WHERE cliente = pNumeroCliente
        and exp.cod_docto=docto.cod_docto
        and docto.cod_grupo= gd.cod_grupo

        let v_contador = v_contador +1;
        
            IF v_contador > pnum_regs then
                    CONTINUE FOREACH;
            END IF; 
     if v_contador>inicia then      
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia,vs_Fecha,vs_descrip WITH RESUME;    
     end if
    END FOREACH;
    
    if v_contador=0 then
        LET vc_CodRet = "00100";
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia,vs_Fecha,vs_descrip;
    END IF;
END;
END PROCEDURE;
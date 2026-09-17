CREATE PROCEDURE "informix".sp_obtenerdoctos_2(pNumeroCliente CHAR(20), inicia  smallint, pnum_regs  smallint, pcod_docto CHAR(4))
RETURNING CHAR(5), CHAR(4), CHAR(35), CHAR(20), SMALLINT;
--DECLARACION DE VARIABLES
DEFINE vc_CodRet    CHAR(5);
DEFINE vc_CodDocto  CHAR(4);
DEFINE vc_DesDocto  CHAR(35);
DEFINE vc_Cuenta    CHAR(20);
DEFINE vs_Secuencia SMALLINT;
DEFINE vi_SqlErr    INTEGER;
DEFINE v_contador        smallint;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vc_CodDocto = "";
LET vc_DesDocto = "";
LET vc_Cuenta = "";
LET vi_SqlErr = 0;
LET vs_Secuencia = 0;
LET v_contador= 0;

--  SET DEBUG FILE TO "/tmp/sp_obtenerdoctos_2.out";
--  TRACE ON;

BEGIN

  ON EXCEPTION SET vi_SqlErr
    IF vi_SqlErr <> 0 THEN
        LET vc_CodRet = vi_SqlErr;
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia;
    END IF;
  END EXCEPTION;


    FOREACH
        SELECT exp.cod_docto, exp.cuenta, exp.secuencia,docto.descripcion
        INTO vc_CodDocto, vc_Cuenta, vs_Secuencia, vc_DesDocto
        FROM bdidigital@coppelimg_tcp:dg_expediente exp,
        bdidigital@coppelimg_tcp:dg_tipodocumento docto
        -- WHERE exp.empresa='001' AND cliente = pNumeroCliente
        WHERE cliente = pNumeroCliente
        and exp.cod_docto = pcod_docto 
        and exp.cod_docto = docto.cod_docto
        ORDER BY exp.cod_docto, exp.secuencia
	
        let v_contador = v_contador +1;
        
        IF v_contador > pnum_regs then
            EXIT FOREACH;
        END IF; 
        if v_contador > inicia then      
            RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia WITH RESUME;    
        end if

    END FOREACH;
    
    if v_contador=0 and inicia = 0 then
        LET vc_CodRet = "00100";
        RETURN vc_CodRet, vc_CodDocto, vc_DesDocto, vc_Cuenta, vs_Secuencia;
    END IF;
END;
END PROCEDURE;
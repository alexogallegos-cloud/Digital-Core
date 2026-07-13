CREATE PROCEDURE "informix".sp_monitor_ckpt()
RETURNING  CHAR(5),
CHAR(150);

--##Definicion De Variables
DEFINE sql_err int;
DEFINE vintvl int;
DEFINE vclock_time char(20);
DEFINE vcp_time char(10);
DEFINE venviado char(1);
DEFINE existe int;
DEFINE mensaje varchar(50);
DEFINE cod_ret char(5);
DEFINE cod_ret2 char(5);
DEFINE vtchkp varchar(150);
DEFINE vcaller varchar(20);

--##Inicializa Variables
LET cod_ret="000";
LET mensaje="";
LET vcaller="";
BEGIN

ON EXCEPTION SET sql_err
   IF sql_err <> 0 then
          RETURN cod_ret, mensaje;
   END IF
END EXCEPTION;
--  SET DEBUG FILE TO "/DBA/SH/monAGA/ckpt/sp_minitor_ckpt.OUT";
--  TRACE ON;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT  MAX(intvl)
INTO    vintvl
FROM    sysmaster:syscheckpoint;


SELECT  dbinfo("utc_to_datetime",clock_time),ROUND(cp_time,2),caller
INTO    vclock_time, vcp_time, vcaller
FROM    sysmaster:syscheckpoint
WHERE   intvl = vintvl;

LET vtchkp = 'OLTP:'|| vcaller || ' ALTO: ';
LET vtchkp =TRIM(vtchkp)||' ' || vclock_time || ' ' || vcp_time;

SELECT  count(intvl)
INTO    existe
FROM    bdimnsj:tblckpt
WHERE   intvl = vintvl;

IF (existe = 0 and vcp_time >= 10)
THEN
        INSERT INTO tblckpt (intvl,clock_time,cp_time,enviado) VALUES (vintvl,vclock_time,vcp_time,"S");
        LET mensaje="Se Inserto con exito";
		EXECUTE PROCEDURE "informix".sp_registra_evento_prod('2','MON_SMS','ALERT_SM','GRUPO_SMS_BD', '','', '1','','','','',vtchkp,'','','','','','','',1,0,0,0,0,'','') INTO cod_ret2;
---        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','MON_SMS','ALERT_SM','000000000','','','1','','','','',vtchkp,'','','','','','','5521302575',1,0,0,0,0,'','') INTO cod_ret2;
        LET mensaje="Se Envio con exito";
ELSE
        LET mensaje="No Inserto";
END IF;
RETURN cod_ret,mensaje;
END;
END PROCEDURE;
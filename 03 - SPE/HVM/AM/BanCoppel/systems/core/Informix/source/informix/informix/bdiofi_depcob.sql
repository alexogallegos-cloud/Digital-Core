CREATE PROCEDURE "informix".depcob(pEmpresa CHAR (3), v_usuario  CHAR(8))

RETURNING char(5),       -- codigo de retorno
          money(14,2),   -- Monto de Cobranza 
          money(14,2),   -- Monto de Cobranza 
          char(9)        -- Usuario Deposito 

define sqlerr   smallint;
define isamerr  smallint;
define cod_ret  char(5);
define vuser    char(9);

define m_abosuc  money(14,2);   -- Total abonos (pagos)     MN
define m_tot     money(14,2);   -- Total abonos (pagos)     MN
define vfecha    date;

ON EXCEPTION SET sqlerr, isamerr
   let m_abosuc = 0;
   let m_tot = 0;
   let vuser = " ";
   LET cod_ret = sqlerr;
   SET DEBUG FILE TO "c_totcomp.err";
   TRACE sqlerr || " * " || isamerr || " * ";
   return cod_ret,m_abosuc,m_tot,vuser;

END EXCEPTION;





set isolation to dirty read;
let cod_ret  = "000";
let m_abosuc = 0;
let m_tot = 0;
let vuser = " ";

  SELECT fecha_hoy INTO vfecha
  FROM bdicred:sd_fechas;


  SELECT sum(importetransac) into  m_abosuc
  FROM   so_transacmov
  WHERE  transaccionid = 1613
  AND    status <> 5
  AND    usuarioid = v_usuario
  AND    fecha = vfecha;

  if m_abosuc is null then let m_abosuc = 0; end if
  
  LET m_tot = m_abosuc;
 
  SELECT trim(ejecutivo) || dig_ver INTO vuser
  FROM   bdinteg:si_ejecut
  WHERE  ejecutivo = v_usuario;

  IF vuser IS NULL THEN
     LET vuser = "";
     LET cod_ret = "120";
     return cod_ret,m_abosuc,m_tot,vuser;
  END IF
 
  return cod_ret,m_abosuc,m_tot,vuser;


END PROCEDURE;
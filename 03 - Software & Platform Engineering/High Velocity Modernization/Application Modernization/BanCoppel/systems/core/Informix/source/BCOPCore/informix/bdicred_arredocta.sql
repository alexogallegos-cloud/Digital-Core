CREATE PROCEDURE "informix".arredocta()
RETURNING CHAR(5);  
 
DEFINE sql_err    SMALLINT;
DEFINE isam_err   SMALLINT;
DEFINE error_info CHAR(40);
DEFINE cod_ret    CHAR(5);
DEFINE vCred      CHAR(20);
DEFINE vCapVig    DECIMAL(14,2);
DEFINE vCapIns    DECIMAL(14,2);
DEFINE vTrans     DECIMAL(14,2);
DEFINE vTabla     DECIMAL(14,2);
DEFINE vTrasp     DECIMAL(14,2);
DEFINE vCapTrasNo DECIMAL(14,2);
DEFINE vIntTrasNo DECIMAL(14,2);
DEFINE vBegin     CHAR(1);
DEFINE vPagado    DECIMAL(14,2);
DEFINE vFecha     DATE;
DEFINE vMinimo    DECIMAL(14,2);
DEFINE vTabasco   SMALLINT;
DEFINE vVencto    DATE;
DEFINE vCalc      CHAR(1);
DEFINE vAnt       CHAR(1);
DEFINE vdosAnt    CHAR(1);
DEFINE vPagos     MONEY(14,2);
DEFINE vCve       CHAR(51);
define v_nivel_eficiencia char (02);
define vEfiAnt char (02);
DEFINE vclcobra CHAR(51);
DEFINE vcodret CHAR(3);



-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF
      RETURN cod_ret;
   END EXCEPTION;

--    set debug file to "amortizaba.out";
--    trace on;
-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret    = "000";
LET vcodret = "000";
LET vBegin     = "?";
let v_nivel_eficiencia = "00";

-- Repara Credito en estatus vencido traspasado
FOREACH trasp WITH HOLD FOR
      SELECT a.num_credito, a.fecha_vencto,
             round(("03202008"-fecha_vencto)/30,-0)  , substr(c.cl_cobra,51)  ,
             nvl((select sum(monto) from sd_movhis f
                   where f.empresa ="001"
                     and f.num_credito = a.num_credito
                     and fecha_mov between "02212008" and "03202008"
                     and codigo_fun in ("033", "334")
                     and codigo_ref = 8),0),
	     cl_cobra,
         nvl((select substr(g.cl_cobra,51) from sd_encabezado_edocta g where g.fecha_emision = "01202008" and g.num_credito = a.num_credito),0),
         nvl((select substr(g.cl_cobra,1,2) from sd_encabezado_edocta g where g.fecha_emision = "02202008" and g.num_credito = a.num_credito),"00")
       INTO vCred, vVencto, vCalc, vAnt, vPagos, vCve, vdosAnt, vEfiAnt
       FROM sd_maecredanexo a, sd_maecred b, sd_encabezado_edocta c
     WHERE (Not a.fecha_vencto Is Null)
        AND (a.empresa=b.empresa)
        AND (a.num_credito=b.num_credito)
        AND (b.status_cred="BT")
        AND (c.fecha_emision="02202008")
        AND (c.num_credito=a.num_credito)
        AND (round(("03202008"-fecha_vencto)/30,-0)-substr(cl_cobra,51)>0)
        AND nvl((select sum(monto) from sd_movhis f
                   where f.empresa ="001"
                     and f.num_credito = a.num_credito
                     and fecha_mov between "02212008" and "03202008"
                     and codigo_fun in ("033", "334")
                     and codigo_ref = 8),0) = 0 
        --and a.num_credito = '600000005675'
        --and a.num_credito = '600000022795'


	BEGIN WORK;
	LET vBegin ="S";

    if vdosAnt = vAnt then let vAnt = vAnt + 1; end if;

	IF vAnt = "0" THEN
	   LET vCalc = "0";
	ELSE
	   LET vAnt = vAnt + 1;
	END IF

    let vCalc = vAnt;
    

	IF vCalc = 1 THEN
		LET vAnt =  1;
	ELIF vCalc = 2 THEN
		LET vAnt =  2;
	ELIF vCalc = 3 OR vCalc = 4 THEN
		LET vAnt =  3;
	ELIF vCalc >= 5 THEN
		LET vAnt =  4;
	END IF;



	if vCalc = 0 or vCalc = 1 or vCalc = 2 then
		let v_nivel_eficiencia = "01";
    elif vCalc = 3 then
		let v_nivel_eficiencia = "02";
	elif vCalc = 4 then
		let v_nivel_eficiencia = "03";
    elif vCalc = 5 or vCalc = 6 then
		let v_nivel_eficiencia = "04";
	elif vCalc > 6 then
		let v_nivel_eficiencia = "05";
	end if;

    if vEfiAnt = "05" then let v_nivel_eficiencia = "05"; end if;



         LET vclcobra = "";
         EXECUTE PROCEDURE cobranza("001",vCred,"03202008")
                 INTO vcodret,vclcobra;



	UPDATE sd_encabezado_edocta 
--	   SET cl_cobra = v_nivel_eficiencia || SUBSTR(vCve,3,50) || vAnt
	   SET cl_cobra = v_nivel_eficiencia || SUBSTR(vclcobra,3,50) || vAnt
	 where fecha_emision ="03202008"
	   and num_credito = "X" || vCred;

     COMMIT WORK;
     LET vBegin ="N";




END FOREACH

RETURN cod_ret;

END PROCEDURE
;
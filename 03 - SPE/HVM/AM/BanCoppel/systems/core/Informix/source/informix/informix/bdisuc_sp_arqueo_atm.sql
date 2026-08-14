CREATE PROCEDURE "informix".sp_arqueo_atm(pempresa CHAR(3), pcod_atm CHAR(4), pfecha CHAR(8))
RETURNING CHAR(5),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2);

	DEFINE vcodret           CHAR(5);
	DEFINE vsqlerr,visamerr  INTEGER;

	DEFINE vsaldo_ant		     MONEY(14,2);
	DEFINE ventradas		     MONEY(14,2);
	DEFINE vsubtotal		     MONEY(14,2);
	DEFINE vsalidas		         MONEY(14,2);
	DEFINE vsaldo_fin_dia	     MONEY(14,2);
    DEFINE vfecha                DATE;

	LET vsaldo_ant = 0;		
	LET ventradas = 0;		
	LET vsubtotal = 0;		
	LET vsalidas = 0;		    
	LET vsaldo_fin_dia = 0;	
	LET vcodret = '000';
	LET vfecha = MDY(SUBSTR(pfecha,1,2),SUBSTR(pfecha,3,2),SUBSTR(pfecha,5,4)) ;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 

BEGIN
    ON EXCEPTION SET vsqlerr,visamerr
       IF vsqlerr != 0 THEN
          LET vcodret=vsqlerr;
          RETURN vcodret,vsaldo_ant,ventradas,vsubtotal,vsalidas,vsaldo_fin_dia;
       END IF;
    END EXCEPTION;

    --SET debug file to "/tmp/sp_arqueo_atm.out";
    --trace on;

	SELECT nvl(saldo_anterior,0),nvl(saldo_total,0)
	  INTO vsaldo_ant,vsaldo_fin_dia
	  FROM bdisuc:ss_atm 
	 WHERE cod_atm = pcod_atm;

	IF vsaldo_ant IS NULL OR vsaldo_ant = '' THEN
		LET vsaldo_ant = 0;
	END IF

	SELECT nvl(sum(monto),0)
	  INTO ventradas
	  FROM bdisuc:ss_operaciones
     WHERE cod_trans in ('0037','0039','0042')
	   AND fecha_operacion = vfecha
       AND sucursal = pcod_atm
	  AND reversado NOT IN ('1','SI');

	SELECT nvl(sum(monto),0)
	  INTO vsalidas
	  FROM bdisuc:ss_operaciones
     WHERE cod_trans in ('0038','0040','0041','0043')
	   AND fecha_operacion = vfecha
       AND sucursal = pcod_atm
	  AND reversado NOT IN ('1','SI');

	LET vsubtotal = ventradas ;

    RETURN vcodret,vsaldo_ant,ventradas,vsubtotal,vsalidas,vsaldo_fin_dia;
END
END PROCEDURE;
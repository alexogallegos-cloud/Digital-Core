CREATE PROCEDURE "informix".crea_plazoniv(ax_montosol MONEY(18,2),
			       ax_montomen MONEY(18,2),
			       ax_tasa     MONEY(18,8))
RETURNING DECIMAL(18,2), INTEGER;

DEFINE V_FACTOR DECIMAL(18,2);
DEFINE V_ELEVADO DECIMAL(18,8);
DEFINE ax_valor CHAR(30);
DEFINE ax_cf DECIMAL(12,8);
DEFINE vsqlerr integer;
DEFINE lerr integer;

LET lerr = 0;
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET lerr = vsqlerr;
      LET V_FACTOR = 0;
      RETURN V_FACTOR,lerr;
   END IF;
END EXCEPTION;

LET V_FACTOR = 0;

let ax_montosol = ax_montosol;
let ax_montomen = ax_montomen;
let ax_tasa = ax_tasa;




    LET ax_cf = 12;
    LET ax_tasa = ((ax_tasa / 100) / (ax_cf)) ;
    LET V_ELEVADO = ax_tasa;
    LET V_FACTOR = (LOGN((ax_montomen) / ( ax_tasa * (-ax_montosol)+ax_montomen))) / (LOGN(1+ ax_tasa));

    LET V_FACTOR = ROUND(V_FACTOR);

	RETURN V_FACTOR, lerr;

END

END PROCEDURE;
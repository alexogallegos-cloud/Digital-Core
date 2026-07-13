create procedure "informix".metodo_frances()
returning char;


DEFINE capital MONEY(14,2);
DEFINE tasa    DECIMAL(6,4);
DEFINE plazo   INTEGER;
DEFINE monto   CHAR(20);

LET capital =50000;
LET tasa    =0.09;
LET plazo =12;
LET monto = 0;

	LET monto = capital/(1-POW((1+tasa),plazo))/tasa;



return monto;

end procedure;
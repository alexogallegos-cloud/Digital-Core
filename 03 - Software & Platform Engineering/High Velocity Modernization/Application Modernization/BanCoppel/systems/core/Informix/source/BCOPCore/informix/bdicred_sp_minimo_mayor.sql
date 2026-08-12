create procedure "informix".sp_minimo_mayor(empresa char(3))  returning char(6);

define vNumcredito char(20);
define pcodret char(6);
DEFINE vsqlerr           INTEGER;
DEFINE monto	DECIMAL(14,2);
begin

ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET pcodret = vsqlerr;
      RETURN pcodret;
   END IF;
END EXCEPTION;

let pcodret = '000000';

    ForEach
    Select num_credito
    Into vNumCredito
    From sd_maesdoshist
    Where sdo_cap_insoluto < monto_financiado
    and monto_financiado > 0
    and sdo_cap_insoluto > 0
    and fecha = '08-20-2007'

        Update sd_maesdos     Set monto_financiado =
           (
            case when monto_financiado / 12 > sdo_cap_insoluto then
               sdo_cap_insoluto /12
            else
               monto_financiado / 12
            end ),

        sdo_trab4 =
            (
             case when monto_financiado / 12 > sdo_cap_insoluto then
               sdo_cap_insoluto /12
            else
               monto_financiado / 12
            end )
        Where num_credito = vNumCredito;

        Update sd_maesdosHist Set monto_financiado =
            (
            case when monto_financiado / 12 > sdo_cap_insoluto then
               sdo_cap_insoluto /12
            else
               monto_financiado / 12
            end ),
        sdo_trab4 =
            (
            case when monto_financiado / 12 > sdo_cap_insoluto then
               sdo_cap_insoluto /12
            else
               monto_financiado / 12
            end )
        Where num_credito = vNumCredito
        And fecha = '08-20-2007';

	SELECT monto_financiado INTO monto
	  FROM sd_maesdos
	 WHERE num_credito = vNumCredito
	   AND empresa ="001";

	UPDATE sd_encabezado2_edocta SET sdo_pagar = monto
	 WHERE fecha_emision = "08/20/2007"
	   AND num_credito = vNumCredito;


    End ForEach;
    RETURN pcodret;
end;
end procedure;
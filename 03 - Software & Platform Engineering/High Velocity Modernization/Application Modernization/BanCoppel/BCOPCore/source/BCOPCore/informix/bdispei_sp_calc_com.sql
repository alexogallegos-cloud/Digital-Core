create procedure "informix".sp_calc_com(
			--->p_sucursal char(3),
			p_sucursal char(4),
			p_importe money(16,2),
			p_hora_local datetime hour to second) 
returning 
			char(5),
			money(14,2),
			money(14,2);
{
MODIFICACION: Daniel Chirinos Lopez
              M-19/sep/2006
              - Se modifico las lineas que direccionaban a bdicent por bdinteg
              - Se modifico la sucursal de char(3) a char(4)
}

define v_comision money(14,2); 
define v_ivacom money(14,2);
define v_iva decimal(5,2);
define sql_err integer;
define v_codret char(5);

let v_comision=0;
let v_iva=0;
let v_ivacom = 0;
let v_codret="000";

begin
on exception set sql_err
   if sql_err <>  0 then
      let v_codret = sql_err;
      return v_codret, v_comision, v_ivacom;
   end if
end exception;
	
	select iva into v_iva 
	--->from bdicent:si_sucursales
	from bdinteg:si_sucursales
	--->where bdicent:si_sucursales.sucursal=p_sucursal;
	where bdinteg:si_sucursales.sucursal=p_sucursal;
		
	if v_iva is null then
		let v_codret = '004'; --No existe iva parametrizado para la sucursal
	end if;

	-- Cobro de comision de SPEI
	-- Obtener el importe y transaccion de la comision a cobrar
	SELECT mnycomision INTO v_comision FROM tblcomision 
		WHERE mnymontomin <= p_importe AND mnymontomax >= p_importe
		AND tmhoramin <= p_hora_local AND tmhoramax >= p_hora_local;

	LET v_ivacom = v_comision * v_iva;
	
	IF p_sucursal IN ('5003','5008','5007','5011','8501') THEN
       LET v_iva = 0;
       LET v_comision = 0;
	   LET v_ivacom = 0;
    END IF


return v_codret, v_comision, v_ivacom;
end
end procedure;
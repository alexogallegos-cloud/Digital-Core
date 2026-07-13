create procedure "informix".ingresos (pTipoOperacion char(1),
				pEmpresa char(3),
				pNumeroCliente char(20),
				pSecuencia smallint,
				pTipoIngreso char(1),
				pNombreEmpresa char(60),
				pNombrePuesto char(3),
				pAntiguedad char(2),
				pNombreDepto char(20),
				pJefeInmediato char(60),
				pIngresosMensuales money(14,2),
				pUsuarioInserta char(8),
				pFechaInserta date,
				pPuestoEsp char (2))
				returning char(5);


define vcodret char(5);
define iSecuencia integer;


let vcodret = "000";
let iSecuencia  = 0;



let pTipoOperacion = pTipoOperacion;
let pNombrePuesto = pnombrePuesto;
let pPuestoEsp = pPuestoEsp;
let pNumeroCliente = pNumeroCliente;
let pSecuencia = pSecuencia;

{    if pTipoOperacion = "C" then
       select max(secuencia) into iSecuencia
       from   si_ingresos
       where  numcte = pnumcte;
       if iSecuencia is null then
          let pTipoOperacion = "A"; 
       end if
    end if
}

begin

	if pTipoOperacion != 'A' and pTipoOperacion != 'C' then
			   let vcodret = "200";
			   return vcodret;
        end if

	IF pTipoOperacion = 'A' OR pTipoOperacion = 'C' THEN

		IF pTipoOperacion='A' THEN
			SELECT  MAX(sec_ingreso) INTO iSecuencia
			FROM si_ingresos
			WHERE empresa=pEmpresa AND numcte=pNumeroCliente;

				IF iSecuencia IS NULL THEN
					let iSecuencia = 1;
				ELSE
					let iSecuencia = iSecuencia + 1;
				END IF;


				INSERT INTO si_ingresos (empresa, numcte, sec_ingreso, tipo_ingreso, nombre_empresa, puesto, antiguedad, nombre_depto, jefe_inmediato, ingreso_mensual,puesto_esp, user_insert, fecha_insert)
					VALUES(pEmpresa, pNumeroCliente, iSecuencia, pTipoIngreso, pNombreEmpresa,
					       pNombrePuesto, pAntiguedad, pNombreDepto, pJefeInmediato, pIngresosMensuales,pPuestoEsp,
					       pUsuarioInserta, pFechaInserta);
		ELSE
                     

			UPDATE si_ingresos
					SET    empresa=pEmpresa, numcte=pNumeroCliente,
					       sec_ingreso=pSecuencia, tipo_ingreso=pTipoIngreso, nombre_empresa=pNombreEmpresa, puesto=pNombrePuesto,
					       antiguedad=pAntiguedad, nombre_depto=pNombreDepto, jefe_inmediato=pJefeInmediato, ingreso_mensual=pIngresosMensuales, puesto_esp = pPuestoEsp,
					       user_insert=pUsuarioInserta, fecha_insert=pFechaInserta
					WHERE numcte=pNumeroCliente  AND sec_ingreso=pSecuencia;
			END IF;
		END IF;



   return vcodret;

end;

end procedure;
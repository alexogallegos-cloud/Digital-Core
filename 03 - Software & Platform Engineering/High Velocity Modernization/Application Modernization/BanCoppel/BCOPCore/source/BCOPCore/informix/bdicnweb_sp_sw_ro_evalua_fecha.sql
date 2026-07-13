CREATE PROCEDURE "informix".sp_sw_ro_evalua_fecha(pFechaEvaluar char(10))
	returning date as fecha_valida;

	define dFechaEvaluada date;
	define cFecha char(10);
	define iMes smallint;
	define iAnio integer;
	define iMAxDia smallint;

	let dFechaEvaluada = null;
	let cFecha = '';
	let iMes = 0;
	let iAnio = 0;
	let iMAxDia = 0;

	begin

		on exception in (-1206, -1263)
			let cFecha = TO_CHAR(pFechaEvaluar);

			let iMes = substr(cFecha, 1, 2);

			let iAnio = substr(cFecha, 7, 4);

			if iMes < 9 then
				let cFecha = '0' || iMes;

				else
				let cFecha = iMes;
			end if;

			let cFecha = trim(cFecha)||'-01-'||iAnio;
			let dFechaEvaluada = date(trim(cFecha));
			let iMaxDia = day(last_day(dFechaEvaluada));

			let cFecha = to_char(dFechaEvaluada);
			if iMAxDia < 10 then
				let cFecha = substr(cFecha,1,2)||trim('-0'||iMAxDia)||'-'||substr(cFecha,7,4);
			else
				let cFecha = substr(cFecha,1,2)||trim('-'||iMAxDia)||'-'||substr(cFecha,7,4);
			end if;

			let dFechaEvaluada = date(trim(cFecha));
			return dFechaEvaluada;
		end exception;

		select date(pFechaEvaluar)
		into dFechaEvaluada
		from systables
		where tabid = 1;

		return dFechaEvaluada;

	end;

end procedure;
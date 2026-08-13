CREATE PROCEDURE "informix".sp_bloqueo_temporal_tarjetas (pdfecha date, psstatus char(3))

returning 	varchar(5) as codigo,
			varchar(50) as mensaje_respuesta;
			
define  vdfechac date;
define  sql_err          integer;
define  isam_err         integer;
define  error_info       varchar(80);
define  p_cod_ret        varchar(6);
define  p_mensaje        varchar(80);
define  vdfechafin       date;	
	
--  Variables para control de contadores
define  vsflagentransaccion 	char(1);
define 	vicontadorregistros 	integer;
define  vicontadorregistros2 	integer;

define vsnumtarjeta char(16);

define vnumtarjeta            	CHAR(16);
define vcodstatustarjeta    CHAR(3);
define vnumcliente         	CHAR(13);
define vtitular            	CHAR(1);
define vtabla              	CHAR(50);
define vcampo              	CHAR(50);
define vvaloranterior      	CHAR(50);
define vvalornuevo         	CHAR(50);
define vfechacambio        	DATETIME YEAR to FRACTION(5);
define vusuariocambio      	CHAR(10);
define videntificadorcambio	CHAR(1);
define vdescripcioncambio  	CHAR(30);
define vmaxnumregistros integer;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

--SET DEBUG FILE TO '/respaldos/sp_bloqueo_temporal_tarjetas.out';
--TRACE ON;
	
let	vsflagentransaccion = 'F';
let	vicontadorregistros = 0;
let vicontadorregistros2 = 0;
let p_cod_ret = '00000';
let p_mensaje = 'Proceso Exitoso';
let vmaxnumregistros=5000;
	
		SET ISOLATION TO DIRTY READ;
		FOREACH cursor1 WITH HOLD
		    for
			Select tt_numtarjeta
				into vsnumtarjeta
			from "informix".tt_temporal_tarjetas
		
			let vnumtarjeta        = '';
			let vcodstatustarjeta  = '';
			let vnumcliente        = '';
			let vtitular           = '';
			let vtabla             = '';
			let vcampo             = '';
			let vvaloranterior     = '';
			let vvalornuevo        = '';
			let vfechacambio       = today;
			let vusuariocambio     = '';
			let videntificadorcambio = '';
			let vdescripcioncambio = '';
			let vcodstatustarjeta = '';
			
			if(vsflagentransaccion = 'F') then
			begin work;
	                let vsflagentransaccion = 'V';
			end if;

			select codstatustarjeta, numtarjeta, numcliente, titular
			into vcodstatustarjeta, vnumtarjeta, vnumcliente, vtitular
			from intercard:tarjeta where numtarjeta = vsnumtarjeta and
			     numtarjeta is not null and numcliente is not null and titular is not null;
				
		    IF vcodstatustarjeta = 'ACT' THEN
				update "informix".tarjeta
					set codstatustarjeta = psstatus
					where numtarjeta  = vsnumtarjeta;
					let vicontadorregistros = vicontadorregistros + 1;			
			END IF;
			
			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
			
          if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table intercard:"informix".tt_temporal_tarjetas;      
				let vsflagentransaccion = 'F';
		   end if;
		
	RETURN 	P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;
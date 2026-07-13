CREATE PROCEDURE "informix".sp_concorresponsales(
psArchivoOrigen CHAR(3),
pdFecha DATE
)

RETURNING	CHAR(4) AS idterminal,
			DATETIME YEAR TO FRACTION(5) AS fechamov, 
			MONEY(16,6) AS monto,
			MONEY(16,6) AS comision, 
			MONEY(16,6) AS comisioniva,
			MONEY(16,6) AS idtpooperacion;

--****************************************************************************************************
-- DESCRIPCION: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 04/22/2010
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--****************************************************************************************************
--DECLARA VARIABLES
DEFINE vsarchivoorigen		CHAR(3);
DEFINE vsidterminal			CHAR(4);
DEFINE vdfechamov			DATETIME YEAR TO FRACTION(5);
DEFINE vmmonto				MONEY(16,6);
DEFINE vmcomision			MONEY(16,6);
DEFINE vmcomisioniva		MONEY(16,6);
DEFIne vmidtpooperacion     MONEY(16,6);

DEFINE viSqlErr				INTEGER;

--INICIA VARIABLES
LET vsarchivoorigen = '';
LET vsidterminal = '';
LET vdfechamov = CURRENT;
LET vmmonto = 0.0;
LET vmcomision = 0.0;
LET vmcomisioniva = 0.0;
LET vmidtpooperacion = 0.0;

LET viSqlErr = 0;

--SET DEBUG FILE TO "/home/sysifx/conciliacion/corresponsales/sp_concorresponsales.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
	END IF;
END EXCEPTION ;

SET ISOLATION TO DIRTY READ ;
SET LOCK MODE TO WAIT 3;
--Verifica si el parametro archivo origen fue proporcionado en blanco o nulo.
IF(psArchivoOrigen = "") OR (psArchivoOrigen IS NULL)THEN
	--El campo archivo origen esta en blanco o nulo.
	LET vsarchivoorigen = '001';
	RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
--Verifica si el parametro fecha fue proporcionado en blanco o nulo.
ELIF(pdFecha = "") OR (pdFecha IS NULL)THEN
	--El campo fecha esta en blanco o nulo.
	LET vsarchivoorigen = '002';
	RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
ELSE
	--Se formatea el parametro fecha para realizar la consulta
	LET pdFecha = MDY(MONTH(pdFecha), DAY(pdFecha), YEAR(pdFecha)) -1 UNITS DAY;
	--Verifica si el archivoorigen proporcionado corresponde al archivo comisiones interrredes.
	IF((psArchivoOrigen = 'ACI') OR (psArchivoOrigen = 'ACC') OR (psArchivoOrigen = 'ACT'))THEN
		FOREACH
		SELECT idterminal, fechamov, monto, comision, comisioniva, idtpooperacion
		INTO   vsidterminal, vdfechamov, vmmonto, vmcomision, vmcomisioniva, vmidtpooperacion
		FROM   intercard:"informix".conarchcomisiones
		WHERE  archivoorigen = psArchivoOrigen AND fechamov::DATE = pdFecha ORDER BY keyx ASC
		RETURN  NVL(vsidterminal,''), 
				NVL(vdfechamov,CURRENT),
				NVL(vmmonto,0.0), 
				NVL(vmcomision,0.0), 
				NVL(vmcomisioniva ,0.0), 
				NVL(vmidtpooperacion,0.0)
		WITH RESUME;
		END FOREACH
	END IF;
END IF;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Descripcion: Consulta de administracion de corresponsales, obtiene informacion de tabla conarchcomisiones.',
'Fecha: 04/22/2010',
'Version: 20100422.1025',
'BD: Intercard',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que tome en cuenta las TRANSFERENCIAS DE PRESTAMOS.',
'Fecha: 31/05/2011',
'VERSION: 20110531.1747';,
'',
'Modifico:  L.I.A. Ricardo Reséndiz Martínez'
'Modificacion: SE modifica retorno para agregar campo de que almacena los tipos de identificadores de las operaciones por nuevo archivo de corresponsales.',
'Solicito: Jose Luis Puebla Salinas'
'Fecha: 14/10/2015',
'VERSION: 20151014.1747'; */                                                      ;

CREATE PROCEDURE "informix".sp_initeverydays()
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
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
    
	--  Variables para datos de primary key
	define  vconsecutivo		integer;
	define 	varchivoorigen  	CHAR(3);
    --  define 	vfechacarga      	DATETIME YEAR to FRACTION(3);
    define 	vfechacarga      	DATETIME YEAR to FRACTION(5);
    define 	vnombrearchivo   	CHAR(23);
	define  vperiododepuracion  integer;
	define  vmaxnumregistros integer;
	define  vsecuencia  varchar (7);
	define  vnumtarjeta  varchar (16);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		
 -- SET DEBUG FILE TO "/informix/HomeInformix/rrm/init.out";
 -- TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vconsecutivo = 0;
	let 	varchivoorigen = '';
    ---let 	vfechacarga = current;
    let 	vfechacarga = sysdate;
    let 	vnombrearchivo = '';
	let     vperiododepuracion =0;
	let     vsecuencia='';
	let     vnumtarjeta='';
	let     vfechalocaltransaccion='';
	let     vhoralocaltransaccion='';
	let    vmaxnumregistros=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';

	set isolation to dirty read;
	select 	periododepuracion, maxnumregistros
					into vperiododepuracion , vmaxnumregistros
			from intercard:"informix".parametros;
			
	let  vfechacarga = vfechacarga - vperiododepuracion UNITS DAY;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select 	{+INDEX (movimiento idx_fechahorainauth)} secuencia, numtarjeta, fechalocaltransaccion, horalocaltransaccion
					into vsecuencia, vnumtarjeta, vfechalocaltransaccion, vhoralocaltransaccion
			from intercard:"informix".movimiento
		    where fechahorainauth < vfechacarga 
			
			if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
		--  Inserta datos en la tabla historica
		insert into "informix".MovimientoHistorico 
		select * 
--		insert into intercard:"informix".MovimientoHistorico (secuencia, codigoiso, codgironeg, codigocentral, numtarjeta, enlinea, enviado, prodind, formato, codtran, tipoctaorigen, tipoctadestino, fechaexptarj, fechamov, horamov, codreversa, moneda, referencia, monto, infreceptor, idreceptor, idterminal, montorealrevfzda, secuenciaorig, pinvalido, cvvvalido, preautorizacion, movreversado, fechaapliccentral, esnacional, pais, metodocaptura, motivo, draftcaptura, prosaauth, authhost, hostauth, authprosa, cobrocomision, montocomision, movconciliado, fechalocaltransaccion, horalocaltransaccion, fechacaptura, trancajeropropio, fechahorainauth, comisionenlinea, codigoretcomision, seccomision, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual, permitecomisionpendiente, generocomisionpendiente, movduranteactsaldos, montosurcharge, secsurcharge, montocashback, secuenciacashback, secuenciacomcashback, montocomcashback, cvv2valido, transaccionorigen, tipotransaccionposdigitada, tokens63in, trancajeroconvenio, codigoisorev, fechahoraoutauth, fechahorabcentral, fechahoraacentral, fechahorainauthj, idretailer, tipotransaccionpos, secuenciaextendida, surcharge, arqcrecibido, arqccalculado, arqcrc)
--		select secuencia, codigoiso, codgironeg, codigocentral, numtarjeta, enlinea, enviado, prodind, formato, codtran, tipoctaorigen, tipoctadestino, fechaexptarj, fechamov, horamov, codreversa, moneda, referencia, monto, infreceptor, idreceptor, idterminal, montorealrevfzda, secuenciaorig, pinvalido, cvvvalido, preautorizacion, movreversado, fechaapliccentral, esnacional, pais, metodocaptura, motivo, draftcaptura, prosaauth, authhost, hostauth, authprosa, cobrocomision, montocomision, movconciliado, fechalocaltransaccion, horalocaltransaccion, fechacaptura, trancajeropropio, fechahorainauth, comisionenlinea, codigoretcomision, seccomision, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual, permitecomisionpendiente, generocomisionpendiente, movduranteactsaldos, montosurcharge, secsurcharge, montocashback, secuenciacashback, secuenciacomcashback, montocomcashback, cvv2valido, transaccionorigen, tipotransaccionposdigitada, tokens63in, trancajeroconvenio, codigoisorev, fechahoraoutauth, fechahorabcentral, fechahoraacentral, fechahorainauthj, idretailer, tipotransaccionpos, secuenciaextendida, surcharge, arqcrecibido, arqccalculado, arqcrc
		from "informix".movimiento	  
		where fechahorainauth < vfechacarga AND
		secuencia = vsecuencia AND
		numtarjeta = vnumtarjeta AND
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
			
			--  Borra registro de la Tabla de Movimientos	
			delete from "informix".movimiento 
		where fechahorainauth < vfechacarga AND
		secuencia = vsecuencia AND
		numtarjeta = vnumtarjeta AND
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
				
			let vicontadorregistros = vicontadorregistros + 1;
--			let vicontadorregistros2 = vicontadorregistros2 + 1;

--			if (vicontadorregistros2 = 100000) then 
--				update statistics medium for table intercard:"informix".movimiento;           
--			let vicontadorregistros2 = 0;
--			end if;

			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table "informix".movimiento;      
				let vsflagentransaccion = 'F';
		end if;
		
			let p_cod_ret = '00000';
	        let p_mensaje = 'Proceso initeverydays Exitoso';
		
		EXECUTE PROCEDURE "informix".sp_movimientobpihistorico() INTO P_COD_RET,P_MENSAJE;
				return 	P_COD_RET,P_MENSAJE;	
	--END IF;
	
	--END IF;

END;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_sorteo_sat (
		pdfecha date
		)

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);

--Definición de Variables de Error para central
DEFINE vsCodRet2 			VARCHAR(5);
DEFINE vsPbandera		 	VARCHAR(1);



--Definición de Variables de datos archivo
DEFINE viconsecutivo		integer;
DEFINE vsperiodo			varchar(4);
DEFINE vstporeg				varchar(2);
DEFINE vsemisor				varchar(4);
DEFINE vsfecha				varchar(6);
DEFINE vstarjeta			varchar(16);
DEFINE vsmonto				varchar(12);
DEFINE vmmonto			money;
DEFINE vssecuencia			varchar(6);
DEFINE vssecuencia2		varchar(7);
DEFINE vsreferencia			varchar(12);
DEFINE vsmontopremio		varchar(12);
DEFINE vmmontopremio	money;
DEFINE vsbin				varchar(6);
DEFINE vsproducto			Varchar(1);


	
--Definicion de variables de validaciones
DEFINE vsesreferencia			varchar(1);
DEFINE vsesmonto			varchar(1);
DEFINE vsessecuencia		varchar(1);
DEFINE vsesmontopremio		varchar(1);


--Definicion variables recuperadas de Intercard
DEFINE vssecintercard		varchar(7);
DEFINE vssecextendidainter	varchar(15);
DEFINE vmmontointercard		money;
DEFINE vdFechatransaccion 	DATETIME YEAR TO FRACTION(5);
DEFINE vsrefintercard		varchar(12);
DEFINE vsstatustarjeta		varchar(3);
DEFINE vsnumerocuenta		varchar(13);
DEFINE vsreferencia23_325 	varchar(23);

DEFINE vsfoliosuc    		varchar(16);

DEFINE vsencontrado 		Char(1);

--Definición de datos centrales
DEFINE vsretcentral			varchar(5);
DEFINE vsordenabono			varchar(16);
DEFINE vscoddevolucion		varchar(1);

DEFINE vdfechahoyinte		date;


--Definicion de variable de validacion
DEFINE vsvalidacion			varchar(1);
DEFINE vsErrorIntegridad	varchar(20);
DEFINE vsobservacion		varchar(40);

--Definición de bandera de ciclo
DEFINE vsFlagEnTransaccion 	varchar(1);
DEFINE viContadorRegistros 	integer;

--Para las transacciones a ser utilizadas
DEFINE vstranaplica		 	varchar(4);

-- Para retorno de Principal de Credito
DEFINE 	g_Remanente		money;
DEFINE  g_IntMoraCob   	money;
DEFINE  g_IntVencCob	money;
DEFINE  g_CapVencCob    money;
DEFINE  g_IntVigCob		money;
DEFINE  g_CapVigCob		money;
DEFINE  g_Impuesto		money;
DEFINE  g_Comision		money;
DEFINE	g_Seguro		money;

-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;

--SET DEBUG FILE TO '/informix/HomeInformix/gami/sat/sp_sorteo_sat.out';
--TRACE ON;

-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';

--Definición de Variables de Error para central
LET vsCodRet2 = '';
LET vsPbandera = '';

--Inicialización de Variables de datos archivo
LET 	viconsecutivo = 0;
LET 	vsperiodo = '';
LET 	vstporeg = '';
LET 	vsemisor = '';
LET 	vsfecha = '';
LET 	vstarjeta = '';
LET 	vsmonto = '';
LET 	vmmonto	= 0;
LET vssecuencia	= '';
LET vssecuencia2 = '';
LET vsreferencia = '';
LET vsmontopremio = '';
LET vmmontopremio = 0;
LET vsbin = '';
LET vsproducto = '';
	
--Inicilaizacion de variables de validacion

LET vsesreferencia	= '';
LET vsesmonto = '';
LET vsessecuencia = '';
LET vsesmontopremio = '';


--Inicializacion variables recuperadas de Intercard
LET vssecintercard = '';
LET vssecextendidainter = '';
LET vmmontointercard = 0;
LET vdFechatransaccion 	= CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsrefintercard = '';
LET vsstatustarjeta = '';
LET vsnumerocuenta = '';
LET vsreferencia23_325 = '';

LET vsfoliosuc = '';

LET vsencontrado = '';
--Inicialización de datos centrales
LET vsretcentral = '';
LET vsordenabono = '';
LET vscoddevolucion = '';


--Inicialización de variable de validacion
LET vsvalidacion = '';
LET vsErrorIntegridad = '';
LET vsobservacion = '';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

--Para las transacciones a ser utilizadas
LET vstranaplica  = '';

-- Inicializacion de variables de retorno de credito
LET  g_Remanente 	= 0.00;
LET  g_IntMoraCob 	= 0.00;
LET  g_IntVencCob 	= 0.00;
LET  g_CapVencCob  	= 0.00;
LET  g_IntVigCob	= 0.00;
LET  g_CapVigCob 	= 0.00;
LET  g_Impuesto		= 0.00;
LET  g_Comision 	= 0.00;
LET	 g_Seguro  		= 0.00;

-- Para generacion de archivo

LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;
	
	if pdfecha = vdfechahoyinte then
			EXECUTE PROCEDURE "informix".sp_carga_sorteosat ()
				into vsCodRet, vsMensaje_Respuesta;
				
				if vsCodRet <> '00000' then
					RETURN 	vsCodRet, 
					NVL(vsMensaje_Respuesta,'');
				else
					FOREACH WITH HOLD
					
						Select consecutivo, periodofiscal, tporeg, banemisor, fechatransaccion, numtarjeta, montoarchivo, secuenciaarchivo, numrefarchivo, montopremio
							into viconsecutivo, vsperiodo, vstporeg, vsemisor, vsfecha, vstarjeta, vsmonto, vssecuencia, vsreferencia, vsmontopremio 
						from Bditarjeta:"informix".tb_sorteo_sat
							where 	validaciones = 'V' and 
									periodofiscal = '2017' -- Actualizar periodo para ejecucion 
						
						IF (vsFlagEnTransaccion = 'F') THEN 
							BEGIN WORK;
							LET vsFlagEnTransaccion = 'V';
						END IF;

						EXECUTE PROCEDURE Bditarjeta:"informix".sp_valida_sorteosat (viconsecutivo,vstarjeta,vsmonto,vssecuencia,vsreferencia,vsmontopremio)
							into vsCodRet, vsMensaje_Respuesta, vsvalidacion;
						
							if vsCodRet <> '00000' and vsvalidacion = 'F' then
								RETURN 	vsCodRet, 
								NVL(vsMensaje_Respuesta,'');
							else					
								
								LET vstranaplica = (CASE 	
														WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D')	THEN '0326'
														WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') THEN '7860'
													END);
								
								EXECUTE PROCEDURE "informix".sp_busmovint_sat( vstarjeta, vssecuencia) 
								into vsCodRet, vssecintercard, vssecextendidainter, vmmontointercard, vdFechatransaccion, vsrefintercard,vsnumerocuenta ,vsstatustarjeta, vsreferencia23_325; 	

								let  vsfoliosuc	= 'i'||vssecextendidainter;
									
								if vsCodRet = '00000' then 
								
									update Bditarjeta:"informix".tb_sorteo_sat
										set
											secuenciaintercard = vssecintercard,
											secextendidainter = vssecextendidainter,
											montointercard = vmmontointercard,
											fchtransacintercard = vdFechatransaccion,
											numrefintercard = vsrefintercard,
											numcuenta = vsnumerocuenta,
											estatustarjeta = vsstatustarjeta,
											referencia23_325 = vsreferencia23_325,
											ordenabono = LPAD (vsfoliosuc,23,' '),
											tranaplica = vstranaplica
										where
											consecutivo = viconsecutivo;
											
										
											
										EXECUTE PROCEDURE "informix".sp_busmovdev_sat ( vstarjeta, vssecuencia )
										into vsCodRet, vsencontrado;
										
										if (vsCodRet = '00001'  and vsencontrado = 'V') then 
										
												update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Movimiento fue devuelto'
												where
													consecutivo = viconsecutivo;
											
											LET vsvalidacion = 'F';
											
										elif (vsCodRet = '00000'  and vsencontrado = 'F') then
										
												update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'V',
													observacion = 'Movimiento aplica'
												where
													consecutivo = viconsecutivo;
											
											LET vsvalidacion = 'V';
										end if;
										
										
										/*if vmmontointercard <> ((vsmontopremio::MONEY)/100) then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Transaccion con montos diferentes'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;*/

										if  ((vsmontopremio::MONEY)/100) > 10000 then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Monto premio mayor a $10,000.00'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;

										if  ((vsmontopremio::MONEY)/100) = 0 then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Monto premio deber ser mayor $0.01'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;

										
										if vsstatustarjeta <> 'ACT' then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'P',
													observacion = 'Tarjeta tiene estatus <> Activo'
											where
												consecutivo = viconsecutivo;
									
										LET vsvalidacion = 'P';		
									
										end if;
									if vsvalidacion in ('P','V') then 
										-- Se agrega proceso para la recuperacion de la direccción del Cliente premiado 
										EXECUTE PROCEDURE "informix".sp_busEdoPob_sat ( vstarjeta, viconsecutivo )
											into vsCodRet, vsencontrado;	
									end if;
							else
								
									update Bditarjeta:"informix".tb_sorteo_sat
										set
											secuenciaintercard = 	'000000',
											secextendidainter = 	'000000000000000',
											montointercard = 		0.0,
											fchtransacintercard = 	CAST('1900-10-10 12:00:00' AS DATETIME YEAR TO FRACTION(5)),
											numrefintercard = '0000000000000',
											numcuenta = '00000000000',
											estatustarjeta = 'NOE',
											ordenabono = '00000000000000000000000',
											tranaplica = '0000',
											validaciones = 'F',
											observacion = 'Transaccion no encontrada',
											referencia23_325 = '00000000000000000000000'
										where
											consecutivo = viconsecutivo;
																										
									LET vsvalidacion = 'F';
								end if;
								
								COMMIT WORK;   
								BEGIN WORK;
								
								if (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D') and
									vsvalidacion in ('P','V')) then

									execute procedure Bdicheq:"informix".abono_ref(
																			'001',						-- empresa
																			'9290',						-- sucursal
																			'informix', 				-- usuario
																			vstranaplica,				-- transaccion aplica
																			'0000', 					-- trasaccion sucursal
																			vsfoliosuc, 				-- Folio suc
																			vsnumerocuenta, 			-- numero de cuenta
																			'0', 						-- numero de documento
																			((vsmonto::MONEY)/100),		-- monto total
																			((vsmonto::MONEY)/100),		-- monto firme
																			0,							-- monto sbc
																			0,							-- monto remesa
																			0,							-- Dias retenido
																			'01',						-- divisa
																			'Premio Hacienda Buen Fin',	-- Referencia
																			' ',						-- numero de tarjeta
																			' ' 						-- usuario autoriza
																			)
										into vsCodRet;
											
									if 	vsCodRet = '000'	then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '0'
											where
												consecutivo = viconsecutivo;
									else
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
									end if;
									
								elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') and
									vsvalidacion in ('P','V'))  then
								
									
									EXECUTE PROCEDURE Bdicred:"informix".principal(
																					'001',							-- Empresa
																					vsnumerocuenta,					-- Numero de credito
																					1,								-- Tipo de pago
																					((vsmontopremio::MONEY)/100),	-- Monto
																					'informix',						-- Usuario
																					'9290',							-- Sucursal
																					vsfoliosuc,						-- Folio_suc
																					vstranaplica					-- Transaccion aplica
																					)
										into vsCodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
									
									
									if 	vsCodRet = '000'	then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '0'
											where
												consecutivo = viconsecutivo;
									else
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
									end if;
								
								elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D') and
									vsvalidacion in ('F'))  then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = 'NP',
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
												
								elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') and
									vsvalidacion in ('F'))  then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = 'NP',
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
									
								end if;
								
							end if;

						LET viContadorRegistros = viContadorRegistros + 1;

						--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
						IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
							COMMIT WORK;
							--BEGIN WORK;
							LET vsFlagEnTransaccion = 'F';
							LET viContadorRegistros = 0;
							CONTINUE FOREACH;
						END IF;
					END FOREACH;
					
					IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
						COMMIT WORK;
						LET vsFlagEnTransaccion = 'F';
					END IF;
				
					LET  vsMensaje_Respuesta = 'Etapa 1 Completa';
				end if;
	else
			LET	vsCodRet = '00001';
			LET	vsMensaje_Respuesta = 'Existe discrepancia en Fechas integral con ejecucion de proceso';
	end if;

				
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat
		where periodofiscal = '2017';  -- Actualizar periodo para ejecucion
		
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;
	
	
			
				
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/EntregaSAT2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Para generar comando de descarga de datos -- Actualizar periodo para ejecucion
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||year(fchtransacintercard), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion,codpostal,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where periodofiscal = ''"'||'2017'||'"'';">/resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/EntregaSAT2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/EntregaSAT2017.txt';
	system vsql;
		
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo EntregaSAT2017.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');

END 

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT',
'Fecha: 2013/11/20',
'Version: 20131112.1600',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT con generacion de archivo de entrega al SAT',
'Fecha: 2013/11/26',
'Version: 20131126.1030',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se optimizo el proceso para busqueda optimizar forma de determinar la transaccion a ser aplicada',
'Fecha: 2013/11/26',
'Version: 20131126.1130',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego spl el cual pemitira validar que el movimiento no se haya devuelto',
'Fecha: 2013/11/29',
'Version: 20131129.1820',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego validaciones de monto premio',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta',
'',
'Modifica: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrega al proceso SPL el cual se encargara de recuperar los datos de estado y poblacion',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta',
'',
'Modifica: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin 2015',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se actualiza proceso para el sorteo de 2015',
'Fecha: 2015/11/20',
'Version: 20151120.1300',
'BD: bditarjeta',
'',
'Modifica: Giovanny A. Mora Izquierdo',
'Proyecto: Sorteo de SAT del Buen Fin 2016',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se actualiza proceso para el sorteo de 2016',
'Fecha: 2016/12/20',
'Version: 20161220.1400',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_busmovdev_sat_complemento_2017(
		psNumtarjeta CHAR(16), 	-- Numero de tarjeta 
		psSecuencia CHAR(6) -- Secuencia de autorizacion
	)

RETURNING 
	CHAR(5) AS Retorno,
	CHAR(1) AS encontrado;
	
	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE ERROR*/
	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsErrorActividad CHAR(250);
	
	/*VARIABLES DE BUSQUEDA*/
	DEFINE vsNumtarjeta CHAR(16);
	DEFINE vsSecuenciaorig CHAR(6);

	/*VARIABLES DEL MOVIMIENTO ORIGINAL*/
	DEFINE vsEncontrado CHAR(1);
	
	BEGIN
		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;

				RETURN vssqlerr, 
					NVL(vsEncontrado,''); 
				END EXCEPTION;

	--SET DEBUG FILE TO '/informix/HomeInformix/rrm/sp_busmovdev_sat.out';
	--TRACE ON;

	
	/*INICIALIZACION DE VARIABLES*/
	-- Variables de error
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsErrorActividad = '';
	
	/*VARIABLES DE BUSQUEDA*/
	LET vsNumtarjeta = '';
	LET vsSecuenciaorig = '';

	
	-- Variables de retorno de intercard
	LET vsEncontrado = '';
	
		
		---##################################
		---#####SORTEO DEVOLUCIONES SAT######
		---##################################

		
		

		SET LOCK MODE TO WAIT 3;
		set isolation to dirty read;
		SELECT numtarjeta, secuenciaautarchivo
				INTO vsNumtarjeta, vsSecuenciaorig
			FROM    bditarjeta:"informix".td_devolucionespos 
				WHERE 
					numtarjeta = psNumtarjeta and
					secuenciaautarchivo = psSecuencia and
					fecha >= '11/17/2017' and --Se pone estas fechas como rango para validar devoluciones
                    encontrado = 'V' and
					estado  = 'A' and
					aplicado = 'V';
		
						
		IF ( (vsNumtarjeta IS NOT NULL) OR ( TRIM (vsNumtarjeta) <> '')) and ( (vsSecuenciaorig IS not NULL) OR ( TRIM (vsSecuenciaorig) <> ''))  THEN
			/*NO EXISTE EL MOVIMIENTO DE DEVOLUCION*/
			LET vssqlerr = '00001';
			LET vsEncontrado = 'V';
		else
		    LET vssqlerr = '00000';
			LET vsEncontrado = 'F';
			
		END IF;
		


	/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
				RETURN vssqlerr, 
					NVL(vsEncontrado,'');
					
	END

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: BUSCA EL MOVIMIENTO ORIGINAL EN LAS DEVOLUCIONES PARA QUE MARQUE REGISTRO EN CASO DE QUE EST FUERA DEVUELTO',
'Fecha: 2013/11/29',
'Version: 20131129.1710',
'BD: bditarjeta',
'',
'Modifica: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin 2014',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: BUSCA EL MOVIMIENTO ORIGINAL EN LAS DEVOLUCIONES PARA QUE MARQUE REGISTRO EN CASO DE QUE ESTE FUERA DEVUELTO POSTERIOR AL SORTEO',
'Fecha: 2014/11/12',
'Version: 20131112.1815',
'BD: bditarjeta',
'',
'Modifica: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin 2015',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: BUSCA EL MOVIMIENTO ORIGINAL EN LAS DEVOLUCIONES PARA QUE MARQUE REGISTRO EN CASO DE QUE ESTE FUERA DEVUELTO POSTERIOR AL SORTEO 2015',
'Fecha: 2015/11/20',
'Version: 20151120.1800',
'BD: bditarjeta',
'',
'Modifica: Giovanny A. Mora Izquierdo',
'Proyecto: Sorteo de SAT del Buen Fin 2016',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: BUSCA EL MOVIMIENTO ORIGINAL EN LAS DEVOLUCIONES PARA QUE MARQUE REGISTRO EN CASO DE QUE ESTE FUERA DEVUELTO POSTERIOR AL SORTEO 2016',
'Fecha: 2016/12/20',
'Version: 20161220.1830',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_busmovint_sat_complemento_2017(
		psNumtarjeta CHAR(16), 	-- Numero de tarjeta 
		psSecuencia CHAR(6), -- SEcuencia de autorizacion
		psmonto		varchar(12)
	)

RETURNING 
	CHAR(5) AS Retorno,
	CHAR(7) AS secuencia,
	CHAR(15) AS secuencia_extendida,
	MONEY AS montointercard,
	DATETIME YEAR TO FRACTION(5) AS fechatransaccion,
	CHAR(12) AS numrefintercard,
	CHAR(13) AS numcuenta,
	CHAR(13) AS statustarjeta,
	CHAR(23) AS referencia23_325;

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE ERROR*/
	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsErrorActividad CHAR(250);

	/*VARIABLES DEL MOVIMIENTO ORIGINAL*/
	DEFINE vsNumtarjeta CHAR(16);
	DEFINE vsSecuenciaorig CHAR(7);
	DEFINE vsSecuencia_extendida CHAR(15);
	DEFINE vmMontointercard MONEY;
	DEFINE vdFechatransaccion DATETIME YEAR TO FRACTION(5);
	DEFINE vsnumrefintercard CHAR(16);
	DEFINE vsnumcuenta CHAR(13);
	DEFINE vsstatustarjeta CHAR(3);
	DEFINE vsreferencia23_325 char(23);

	-- Datos de entrada 
	DEFINE vsSecuencia CHAR(7);
	DEFINE vmmontoarchivo money;
	
	BEGIN
		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;

				RETURN vssqlerr, 
					NVL(vsSecuenciaorig,''), 
					NVL(vsSecuencia_extendida,''), 
					NVL(vmMontointercard,0),
					NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(vsnumrefintercard,''), 
					NVL(vsnumcuenta,''), 
					NVL(vsstatustarjeta,''),
					NVL(vsreferencia23_325,'');
				END EXCEPTION;

	--	SET DEBUG FILE TO '/informix/HomeInformix/rrm/sp_busmovint_sat.out';
	--	TRACE ON;

	
	/*INICIALIZACION DE VARIABLES*/
	-- Variables de error
	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsErrorActividad = '';
	
	-- Variables de retorno de intercard
	LET vsNumtarjeta = '';
	LET vsSecuenciaorig = '';
	LET vsSecuencia_extendida = '';
	LET vmMontointercard = 0;
	LET vdFechatransaccion = CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
	LET vsnumrefintercard = '';
	LET vsnumcuenta = '';
	LET vsstatustarjeta = '';

	-- Variables de entrada 
	LET vsSecuencia = '';
	LET vmmontoarchivo = 0;
	LET vmmontoarchivo = (psmonto/100);
	
		---#####################
		---#####SORTEO SAT######
		---#####################

		LET vsSecuencia = "1"||psSecuencia;
		

		SET LOCK MODE TO WAIT 3;
		set isolation to dirty read;
		SELECT   mv.numtarjeta, mv.secuencia, mv.secuenciaextendida, (NVL(mv.monto,0)),	mv.fechahorainauth, mv.referencia, cta.numcuenta, tjt.codstatustarjeta, NVL(cnc.referencia23_325,'')
				INTO vsNumtarjeta,vsSecuenciaorig, vsSecuencia_extendida, vmMontointercard,	vdFechatransaccion, vsnumrefintercard,	vsnumcuenta, vsstatustarjeta, vsreferencia23_325
			FROM    intercard:"informix".movimiento mv, bditarjeta:"informix".td_movimientos_conciliacion cnc, intercard:tarjetacuenta cta, intercard:tarjeta tjt
				WHERE 
					mv.numtarjeta = psNumtarjeta and
					mv.secuencia = vsSecuencia and
					cnc.numtarjeta = mv.numtarjeta and
					cnc.secuencia = mv.secuencia and
					cnc.tipo_conciliacion NOT IN (3 ,4 ,6 ) and
					cnc.tipo_conciliacion < 10 and
					mv.monto = (cnc.monto325 / 100) and --Se agrego ya que hay un duplicado en la vista
					mv.monto = vmmontoarchivo and --Se agrego ya que hay un duplicado en la vista
					tjt.numtarjeta = cta.numtarjeta and
					cta.numtarjeta = mv.numtarjeta and
					mv.numtarjeta = tjt.numtarjeta and
					mv.fechahorainauth >= '2017-11-17 00:00:00.0' and
				    mv.fechahorainauth <= '2017-11-21 00:00:00.0' and
 					mv.prodind = '02' and
					mv.codigoiso = '00'  and
					mv.movreversado = 'F' and
					mv.formato != '0420' and
					mv.esnacional = 'V'  and
					cnc.movconciliado IN ('P' ,'V' ) and
					mv.tipotransaccionposdigitada != 'CA' and
					mv.monto >= 250.0000 and
 					mv.numtarjeta LIKE '4%'; 	
						
		IF ( (vsNumtarjeta IS NULL) OR ( TRIM (vsNumtarjeta) = '')) THEN		
			/*NO EXISTE EL MOVIMIENTO ORIGINAL*/
			LET vssqlerr = '00400';
			LET vsErrorActividad = 'NO EXISTE EL MOVIMIENTO COMPLEMENTO';			
		END IF;
		
	/*RETORNO DEL PROCEDIMIENTO ALMACENADO*/
				RETURN vssqlerr, 
					NVL(vsSecuenciaorig,''), 
					NVL(vsSecuencia_extendida,''), 
					NVL(vmMontointercard,0),
					NVL(vdFechatransaccion,CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5))), 
					NVL(vsnumrefintercard,''), 
					NVL(vsnumcuenta,''), 
					NVL(vsstatustarjeta,''),
					NVL(vsreferencia23_325,''); 
				
	END

	
END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: OBTIENE EL MOVIMIENTO ORIGINAL y DATOS GENERALES DE CUENTA',
'Fecha: 2013/11/08',
'Version: 20131108.1920',
'BD: bditarjeta',
'',
'MODIFICA: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin 2014',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: OBTIENE EL MOVIMIENTO ORIGINAL y DATOS GENERALES DE CUENTA y se recuepara el numero de referencia 23_325',
'Fecha: 2014/11/12',
'Version: 20141112.1730',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_valida_sorteosat_complemento_2017  
(
piconsecutivo		integer,
pstarjeta			char(16),
psmonto				char(12),
pssecuencia			char(6),
psreferencia		char(12),
psmontopremio 		char(12)
)

RETURNING 
			VARCHAR (5) AS viCodRet, 
			VARCHAR(250) AS vsMensaje_Respuesta,
			VARCHAR(1) AS vsvalidacion;

--DefiniciÃ³n de Variables de retorno
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);	
DEFINE  vsvalidacion		varchar(1);		
			
-- Variables de trabajo
DEFINE	vstarjeta			char(16);
DEFINE 	vsmonto				char(12);
DEFINE	vssecuencia			char(6);
DEFINE	vsreferencia		char(12);
DEFINE 	vsmontopremio 		char(12);

DEFINE vsErrorIntegridad   	char(40);
DEFINE vsobservacion 		char(250);

DEFINE 	vsestarjeta			char(1);
DEFINE 	vsesmonto 			char(1);
DEFINE 	vsessecuencia 		char(1);
DEFINE 	vsesreferencia 		char(1);
DEFINE 	vsesmontopremio 	char(1);


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vsCodRet = viCodigo;
				RETURN 	vsCodRet, 
						vsMensaje_Respuesta,
						vsvalidacion;

	END EXCEPTION;
	
--SET DEBUG FILE TO '/informix/HomeInformix/rrm/sp_valida_sorteosat.out';
--TRACE ON;


--Inicializa de Variables de Error
LET vicodigo = 0;
LET vsCodRet = '00000';
LET vsMensaje_Respuesta = 'PROCESO DE VALIDACION CORRECTO';
			
--Inicializa las Variables de trabajo 
LET	vstarjeta = pstarjeta;
LET	vsmonto = psmonto;
LET	vssecuencia	= pssecuencia;
LET	vsreferencia = psreferencia;
LET vsmontopremio = psmontopremio;

LET vsErrorIntegridad = '';
LET vsobservacion = '';

LET vsestarjeta = '';
LET	vsesmonto = '';
LET	vsessecuencia = '';
LET	vsesreferencia = '';
LET vsesmontopremio = '';

	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vstarjeta) INTO vsestarjeta;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vsmonto) INTO vsesmonto;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vssecuencia) INTO vsessecuencia ;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico (vsreferencia) INTO vsesreferencia ;
	EXECUTE PROCEDURE bditarjeta:"informix".sp_esnumerico(vsmontopremio) INTO vsesmontopremio;
		
	IF LENGTH(vstarjeta)!=16 THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'TamaÃ±o incorrecto de tarjeta';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: DEBE SER IGUAL A 16 CARACTERES';
	ELIF (vsestarjeta = 'F') THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Tarjeta no debe tener letras';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF TRIM(NVL(vstarjeta,''))= '' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Num. Tarjeta no debe ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE ESTAR VACIO';
	ELIF vstarjeta = '0000000000000000' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Num. Tarjeta no debe ser igual a ceros';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE TENER SOLO CEROS';
	ELIF substr(vstarjeta,1,1) = '5' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Num. Tarjeta No autorizada para el premio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD numtarjeta: MASTERCARD NO PARTICIPA';
	ELIF LENGTH(vssecuencia)!=6 THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Longuitud de secuencia incorrecto';
			LET vsobservacion = 'ERROR DE INTEGRIDAD secuencia: DEBE SER IGUAL A 6 CARACTERES';
	ELIF TRIM(NVL(vssecuencia,''))='' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'La secuencia no debe ser vacia';
			LET vsobservacion = 'ERROR DE INTEGRIDAD secuencia: NO DEBE ESTAR VACIO';
	ELIF vssecuencia = '000000' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'La secuencia no debe ser ceros';
			LET vsobservacion = 'ERROR DE INTEGRIDAD secuencia: NO DEBE TENER SOLO CEROS';
	ELIF TRIM(NVL(vsreferencia,''))='' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'La secuencia no debe ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD referencia: NO DEBE ESTAR VACIO';
	ELIF vssecuencia = '000000' THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Secuencia no debe ser igual a ceros';
			LET vsobservacion = 'ERROR DE INTEGRIDAD referencia: NO DEBE TENER SOLO CEROS';
	ELIF (vsmonto = 0) THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Monto debe ser mayor a cero';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';
	ELIF (vsesmonto = 'F') THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Valor de monto debe ser numerico';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF (TRIM(vsmonto)='')	THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Valor de monto no debe ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	/*ELIF (vsmontopremio = 0) THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Monto premio debe ser mayor a 0';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER DIFERENTE DE CERO';*/
	ELIF (vsesmontopremio = 'F') THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Monto premio debe ser numerico';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELIF (TRIM(vsmontopremio)='')	THEN
			LET vsCodRet = '00001';
			LET vsvalidacion = 'F';
			LET vsErrorIntegridad = 'Monto premio no puedes ser vacio';
			LET vsobservacion = 'ERROR DE INTEGRIDAD monto: EL IMPORTE DE TRANSACCION DEBE SER NUMERICO';
	ELSE
			LET vsCodRet = '00000';
			LET vsvalidacion = 'V';
			LET vsErrorIntegridad = 'Validacion Correcta';
	END IF;
	
	LET vsMensaje_Respuesta = vsErrorIntegridad;
	
	UPDATE Bditarjeta:"informix".tb_sorteo_sat
		SET 	validaciones = 	vsvalidacion, 
				observacion = 	vsErrorIntegridad
		WHERE consecutivo = piconsecutivo;
		
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,''),
			vsvalidacion;

END

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso de validacion de registro proceso de sorteo SAT',
'Fecha: 2013/11/20',
'Version: 20131112.1730',
'BD: bditarjeta',
'',
'MODIFICA: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso de validacion de registro para identificar tarjetas  MASTERCARD y excluirlas del proceso',
'Fecha: 2013/11/20',
'Version: 20131112.1730',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_sorteo_sat_complemento_2017 (pdfecha date )

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);

--Definición de Variables de Error para central
DEFINE vsCodRet2 			VARCHAR(5);
DEFINE vsPbandera		 	VARCHAR(1);



--Definición de Variables de datos archivo
DEFINE viconsecutivo		integer;
DEFINE vsperiodo			varchar(4);
DEFINE vstporeg				varchar(2);
DEFINE vsemisor				varchar(4);
DEFINE vsfecha				varchar(6);
DEFINE vstarjeta			varchar(16);
DEFINE vsmonto				varchar(12);
DEFINE vmmonto			money;
DEFINE vssecuencia			varchar(6);
DEFINE vssecuencia2		varchar(7);
DEFINE vsreferencia			varchar(12);
DEFINE vsmontopremio		varchar(12);
DEFINE vmmontopremio	money;
DEFINE vsbin				varchar(6);
DEFINE vsproducto			Varchar(1);


	
--Definicion de variables de validaciones
DEFINE vsesreferencia			varchar(1);
DEFINE vsesmonto			varchar(1);
DEFINE vsessecuencia		varchar(1);
DEFINE vsesmontopremio		varchar(1);


--Definicion variables recuperadas de Intercard
DEFINE vssecintercard		varchar(7);
DEFINE vssecextendidainter	varchar(15);
DEFINE vmmontointercard		money;
DEFINE vdFechatransaccion 	DATETIME YEAR TO FRACTION(5);
DEFINE vsrefintercard		varchar(12);
DEFINE vsstatustarjeta		varchar(3);
DEFINE vsnumerocuenta		varchar(13);
DEFINE vsreferencia23_325 	varchar(23);

DEFINE vsfoliosuc    		varchar(16);

DEFINE vsencontrado 		Char(1);

--Definición de datos centrales
DEFINE vsretcentral			varchar(5);
DEFINE vsordenabono			varchar(16);
DEFINE vscoddevolucion		varchar(1);

DEFINE vdfechahoyinte		date;


--Definicion de variable de validacion
DEFINE vsvalidacion			varchar(1);
DEFINE vsErrorIntegridad	varchar(20);
DEFINE vsobservacion		varchar(40);

--Definición de bandera de ciclo
DEFINE vsFlagEnTransaccion 	varchar(1);
DEFINE viContadorRegistros 	integer;

--Para las transacciones a ser utilizadas
DEFINE vstranaplica		 	varchar(4);

-- Para retorno de Principal de Credito
DEFINE 	g_Remanente		money;
DEFINE  g_IntMoraCob   	money;
DEFINE  g_IntVencCob	money;
DEFINE  g_CapVencCob    money;
DEFINE  g_IntVigCob		money;
DEFINE  g_CapVigCob		money;
DEFINE  g_Impuesto		money;
DEFINE  g_Comision		money;
DEFINE	g_Seguro		money;

-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
    
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;


-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';

--Definición de Variables de Error para central
LET vsCodRet2 = '';
LET vsPbandera = '';

--Inicialización de Variables de datos archivo
LET 	viconsecutivo = 0;
LET 	vsperiodo = '';
LET 	vstporeg = '';
LET 	vsemisor = '';
LET 	vsfecha = '';
LET 	vstarjeta = '';
LET 	vsmonto = '';
LET 	vmmonto	= 0;
LET vssecuencia	= '';
LET vssecuencia2 = '';
LET vsreferencia = '';
LET vsmontopremio = '';
LET vmmontopremio = 0;
LET vsbin = '';
LET vsproducto = '';
	
--Inicilaizacion de variables de validacion

LET vsesreferencia	= '';
LET vsesmonto = '';
LET vsessecuencia = '';
LET vsesmontopremio = '';


--Inicializacion variables recuperadas de Intercard
LET vssecintercard = '';
LET vssecextendidainter = '';
LET vmmontointercard = 0;
LET vdFechatransaccion 	= CAST('1900-01-01 12:00:00' AS DATETIME YEAR TO FRACTION(5));
LET vsrefintercard = '';
LET vsstatustarjeta = '';
LET vsnumerocuenta = '';
LET vsreferencia23_325 = '';

LET vsfoliosuc = '';

LET vsencontrado = '';
--Inicialización de datos centrales
LET vsretcentral = '';
LET vsordenabono = '';
LET vscoddevolucion = '';


--Inicialización de variable de validacion
LET vsvalidacion = '';
LET vsErrorIntegridad = '';
LET vsobservacion = '';

LET vsFlagEnTransaccion = 'F';
LET viContadorRegistros = 0;

--Para las transacciones a ser utilizadas
LET vstranaplica  = '';

-- Inicializacion de variables de retorno de credito
LET  g_Remanente 	= 0.00;
LET  g_IntMoraCob 	= 0.00;
LET  g_IntVencCob 	= 0.00;
LET  g_CapVencCob  	= 0.00;
LET  g_IntVigCob	= 0.00;
LET  g_CapVigCob 	= 0.00;
LET  g_Impuesto		= 0.00;
LET  g_Comision 	= 0.00;
LET	 g_Seguro  		= 0.00;

-- Para generacion de archivo

LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

    
    --SET DEBUG FILE TO '/informix/argoz/buenfin/sp_sorteo_sat.out';
    --TRACE ON;
    --TRACE PROCEDURE;
    
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;
	
	if pdfecha = vdfechahoyinte then
			/*EXECUTE PROCEDURE "informix".sp_carga_sorteosat ()  --La Carga ya fue previamente ejecutada correctamente
				into vsCodRet, vsMensaje_Respuesta;
				
				if vsCodRet <> '00000' then
					RETURN 	vsCodRet, 
					NVL(vsMensaje_Respuesta,'');
				else*/
					FOREACH WITH HOLD
					
						Select consecutivo, periodofiscal, tporeg, banemisor, fechatransaccion, numtarjeta, montoarchivo, secuenciaarchivo, numrefarchivo, montopremio
							into viconsecutivo, vsperiodo, vstporeg, vsemisor, vsfecha, vstarjeta, vsmonto, vssecuencia, vsreferencia, vsmontopremio 
						from Bditarjeta:"informix".tb_sorteo_sat
							where 	validaciones = 'V' and 
									periodofiscal = '2017' and -- Actualizar periodo para ejecucion 
									consecutivo >=  2242685 and 
									montopremio <> '000000000000' and
									numtarjeta in (/*'4268070253643862',*/'4268070256432750','4268070256689458','4268070256887367',
									'4268070257289209','4268070257706442','4268070259418277','4268070260945433','4268070261552303','4268070262450184','4268070263007298','4268070263264600',
									'4268070263988075','4268070264764186','4268070265079113','4268070265299208','4268070265418980','4268070265726838','4268070267229625','4268070267524025',
									'4268070268014034','4268070268244177','4268070268503143','4268070269003846','4268070269491538','4268070270579651','4268070271800718','4268070272257645',
									'4268070273871048','4268070274299306','4268070274346578','4268070274679218','4268070275735357','4268070277943918','4268070278215415','4268070278641503',
									'4268070278766870','4268070279112447','4268070279402848','4268070279710885','4268070279820403','4268070280415672','4268070281101461','4268070281502049',
									'4268070281613093','4268070282161910','4268070282835448','4268070283252098','4268070284081298','4268070284859370','4268070286838414','4268070287524583',
									'4268070287588992','4268070287687091','4268070287905360','4268070288084611','4268070288283981','4268070288441548','4268070288788302','4268070288798509',
									'4268070289506729','4268070291048579')
						
						IF (vsFlagEnTransaccion = 'F') THEN 
							BEGIN WORK;
							LET vsFlagEnTransaccion = 'V';
						END IF;

						EXECUTE PROCEDURE Bditarjeta:"informix".sp_valida_sorteosat_complemento_2017(viconsecutivo,vstarjeta,vsmonto,vssecuencia,vsreferencia,vsmontopremio)
							into vsCodRet, vsMensaje_Respuesta, vsvalidacion;
						
							if vsCodRet <> '00000' and vsvalidacion = 'F' then
								RETURN 	vsCodRet, 
								NVL(vsMensaje_Respuesta,'');
							else					
								
								LET vstranaplica = (CASE 	
														WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D')	THEN '0326'
														WHEN TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') THEN '7860'
													END);
								
								EXECUTE PROCEDURE "informix".sp_busmovint_sat_complemento_2017( vstarjeta, vssecuencia, vsmonto) 
								into vsCodRet, vssecintercard, vssecextendidainter, vmmontointercard, vdFechatransaccion, vsrefintercard,vsnumerocuenta ,vsstatustarjeta, vsreferencia23_325; 	

								let  vsfoliosuc	= 'i'||vssecextendidainter;
									
								if vsCodRet = '00000' then 
								
									update Bditarjeta:"informix".tb_sorteo_sat
										set
											secuenciaintercard = vssecintercard,
											secextendidainter = vssecextendidainter,
											montointercard = vmmontointercard,
											fchtransacintercard = vdFechatransaccion,
											numrefintercard = vsrefintercard,
											numcuenta = vsnumerocuenta,
											estatustarjeta = vsstatustarjeta,
											referencia23_325 = vsreferencia23_325,
											ordenabono = LPAD (vsfoliosuc,23,' '),
											tranaplica = vstranaplica
										where
											consecutivo = viconsecutivo;
											
										
											
										EXECUTE PROCEDURE "informix".sp_busmovdev_sat_complemento_2017 ( vstarjeta, vssecuencia )
										into vsCodRet, vsencontrado;
										
										if (vsCodRet = '00001'  and vsencontrado = 'V') then 
										
												update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Movimiento fue devuelto'
												where
													consecutivo = viconsecutivo;
											
											LET vsvalidacion = 'F';
											
										elif (vsCodRet = '00000'  and vsencontrado = 'F') then
										
												update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'V',
													observacion = 'Movimiento aplica'
												where
													consecutivo = viconsecutivo;
											
											LET vsvalidacion = 'V';
										end if;
										
										
										/*if vmmontointercard <> ((vsmontopremio::MONEY)/100) then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Transaccion con montos diferentes'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;*/

										if  ((vsmontopremio::MONEY)/100) > 10000 then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Monto premio mayor a $10,000.00'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;

										if  ((vsmontopremio::MONEY)/100) = 0 then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'F',
													observacion = 'Monto premio deber ser mayor $0.01'
												where
											consecutivo = viconsecutivo;
									
											LET vsvalidacion = 'F';
										end if;

										
										if vsstatustarjeta <> 'ACT' then
											update Bditarjeta:"informix".tb_sorteo_sat
												set
													validaciones = 'P',
													observacion = 'Tarjeta tiene estatus <> Activo'
											where
												consecutivo = viconsecutivo;
									
										LET vsvalidacion = 'P';		
									
										end if;
									if vsvalidacion in ('P','V') then 
										-- Se agrega proceso para la recuperacion de la direccción del Cliente premiado 
										EXECUTE PROCEDURE "informix".sp_busEdoPob_sat ( vstarjeta, viconsecutivo )
											into vsCodRet, vsencontrado;	
									end if;
							else
								
									update Bditarjeta:"informix".tb_sorteo_sat
										set
											secuenciaintercard = 	'000000',
											secextendidainter = 	'000000000000000',
											montointercard = 		0.0,
											fchtransacintercard = 	CAST('1900-10-10 12:00:00' AS DATETIME YEAR TO FRACTION(5)),
											numrefintercard = '0000000000000',
											numcuenta = '00000000000',
											estatustarjeta = 'NOE',
											ordenabono = '00000000000000000000000',
											tranaplica = '0000',
											validaciones = 'F',
											observacion = 'Transaccion no encontrada',
											referencia23_325 = '00000000000000000000000'
										where
											consecutivo = viconsecutivo;
																										
									LET vsvalidacion = 'F';
								end if;
								
								COMMIT WORK;   
								BEGIN WORK;
								
								if (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D') and
									vsvalidacion in ('P','V')) then

									execute procedure Bdicheq:"informix".abono_ref(
																			'001',						-- empresa
																			'9290',						-- sucursal
																			'informix', 				-- usuario
																			vstranaplica,				-- transaccion aplica
																			'0000', 					-- trasaccion sucursal
																			vsfoliosuc, 				-- Folio suc
																			vsnumerocuenta, 			-- numero de cuenta
																			'0', 						-- numero de documento
																			((vsmonto::MONEY)/100),		-- monto total
																			((vsmonto::MONEY)/100),		-- monto firme
																			0,							-- monto sbc
																			0,							-- monto remesa
																			0,							-- Dias retenido
																			'01',						-- divisa
																			'Premio Hacienda Buen Fin',	-- Referencia
																			' ',						-- numero de tarjeta
																			' ' 						-- usuario autoriza
																			)
										into vsCodRet;
											
									if 	vsCodRet = '000'	then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '0'
											where
												consecutivo = viconsecutivo;
									else
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
									end if;
									
								elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') and
									vsvalidacion in ('P','V'))  then
								
									
									EXECUTE PROCEDURE Bdicred:"informix".principal(
																					'001',							-- Empresa
																					vsnumerocuenta,					-- Numero de credito
																					1,								-- Tipo de pago
																					((vsmontopremio::MONEY)/100),	-- Monto
																					'informix',						-- Usuario
																					'9290',							-- Sucursal
																					vsfoliosuc,						-- Folio_suc
																					vstranaplica					-- Transaccion aplica
																					)
										into vsCodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
									
									
									if 	vsCodRet = '000'	then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '0'
											where
												consecutivo = viconsecutivo;
									else
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = vsCodRet,
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
									end if;
								
								elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'D') and
									vsvalidacion in ('F'))  then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = 'NP',
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
												
								elif (TRIM(SUBSTR(vstarjeta, 1,6)) in (select bin from Intercard:"informix".bines where creditodebito = 'C') and
									vsvalidacion in ('F'))  then
										update Bditarjeta:"informix".tb_sorteo_sat
											set
												retcentral = 'NP',
												codigodevolucion = '1'
											where
												consecutivo = viconsecutivo;
									
								end if;
								
							end if;

						LET viContadorRegistros = viContadorRegistros + 1;

						--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
						IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
							COMMIT WORK;
							--BEGIN WORK;
							LET vsFlagEnTransaccion = 'F';
							LET viContadorRegistros = 0;
							CONTINUE FOREACH;
						END IF;
					END FOREACH;
					
					IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
						COMMIT WORK;
						LET vsFlagEnTransaccion = 'F';
					END IF;
				
					LET  vsMensaje_Respuesta = 'Etapa 1 Completa';
				/*end if;*/
	else
			LET	vsCodRet = '00001';
			LET	vsMensaje_Respuesta = 'Existe discrepancia en Fechas integral con ejecucion de proceso';
	end if;

				
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat
		where periodofiscal = '2017';  -- Actualizar periodo para ejecucion
		
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;
	
	
			
				
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/EntregaSAT2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Para generar comando de descarga de datos -- Actualizar periodo para ejecucion
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||year(fchtransacintercard), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion,codpostal,estado,poblacion from bditarjeta:"informix".tb_sorteo_sat where periodofiscal = ''"'||'2017'||'"'';">/resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/EntregaSAT2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/EntregaSAT2017.txt';
	system vsql;
		
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo EntregaSAT2017.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');

END 

END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT',
'Fecha: 2013/11/20',
'Version: 20131112.1600',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Proceso principal de proceso sorteo SAT con generacion de archivo de entrega al SAT',
'Fecha: 2013/11/26',
'Version: 20131126.1030',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se optimizo el proceso para busqueda optimizar forma de determinar la transaccion a ser aplicada',
'Fecha: 2013/11/26',
'Version: 20131126.1130',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego spl el cual pemitira validar que el movimiento no se haya devuelto',
'Fecha: 2013/11/29',
'Version: 20131129.1820',
'BD: bditarjeta',
'',
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego validaciones de monto premio',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta',
'',
'Modifica: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrega al proceso SPL el cual se encargara de recuperar los datos de estado y poblacion',
'Fecha: 2013/12/02',
'Version: 20131202.1730',
'BD: bditarjeta',
'',
'Modifica: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin 2015',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se actualiza proceso para el sorteo de 2015',
'Fecha: 2015/11/20',
'Version: 20151120.1300',
'BD: bditarjeta',
'',
'Modifica: Giovanny A. Mora Izquierdo',
'Proyecto: Sorteo de SAT del Buen Fin 2016',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se actualiza proceso para el sorteo de 2016',
'Fecha: 2016/12/20',
'Version: 20161220.1400',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_sorteo_sat2_600091693165(
		pdfecha date
		)

RETURNING 
			VARCHAR (5) AS CodRet, 
			VARCHAR(250) AS Mensaje_Respuesta;

--Definición de Variables de Error
DEFINE vicodigo 			integer;
DEFINE vsCodRet 			VARCHAR(5);
DEFINE vsMensaje_Respuesta 	VARCHAR(250);


--Definición de datos centrales

DEFINE vdfechahoyinte		date;



-- Para retorno de Principal de Credito
DEFINE 	g_Remanente		money;
DEFINE  g_IntMoraCob   	money;
DEFINE  g_IntVencCob	money;
DEFINE  g_CapVencCob    money;
DEFINE  g_IntVigCob		money;
DEFINE  g_CapVigCob		money;
DEFINE  g_Impuesto		money;
DEFINE  g_Comision		money;
DEFINE	g_Seguro		money;

-- Para generacion de archivo

DEFINE 	vsql			char (1150);
DEFINE  vsfecencabezado   char(10);
DEFINE  vicontador 		integer;
DEFINE  vscontador		char(10);
DEFINE  viincremento	integer;
DEFINE  vicontador2		integer;


BEGIN
	ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				RETURN 	vsCodRet, 
						vsMensaje_Respuesta;

	END EXCEPTION;

--SET DEBUG FILE TO '/informix/HomeInformix/rrm/sp_sorteo_sat2.out';
--TRACE ON;

-- Inicialización de variables
LET 	vicodigo = 0;
LET		vsCodRet = '00000';
LET		vsMensaje_Respuesta = 'PROCESO TERMINADO SATISFACTORIAMENTE';



-- Inicializacion de variables de retorno de credito
LET  g_Remanente 	= 0.00;
LET  g_IntMoraCob 	= 0.00;
LET  g_IntVencCob 	= 0.00;
LET  g_CapVencCob  	= 0.00;
LET  g_IntVigCob	= 0.00;
LET  g_CapVigCob 	= 0.00;
LET  g_Impuesto		= 0.00;
LET  g_Comision 	= 0.00;
LET	 g_Seguro  		= 0.00;

-- Para generacion de archivo

LET 	vsql	= '';
LET     vsfecencabezado = '';
LET 	vicontador = 0;
LET 	vscontador = '';
LET  	viincremento = 0;
LET		vicontador2 = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	Select fecha_hoy into vdfechahoyinte from Bdinteg:"informix".si_fechas;

	if vdfechahoyinte = pdfecha then 
			
			EXECUTE PROCEDURE Bdicred:"informix".principal(	'001','600091693165',1,	3470.00 ,	'informix',	'9290',	'i112015141725531',	'7860')
				into vsCodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
			
			if vsCodRet = '000' then 
				update bditarjeta:"informix".tb_sorteo_sat
					set codigodevolucion = '0',
						observacion = 'Movimiento aplica',
						retcentral = vsCodRet,
						validaciones = 'V'
				where consecutivo = 2242685;
			else 
				update bditarjeta:"informix".tb_sorteo_sat
					set codigodevolucion = '1',
						observacion = 'NO APLICADO POR CREDITO',
						retcentral = vsCodRet
				where consecutivo = 2242685;
			end if;
	
	else
	
		let vsCodRet = '00001';
		LET  vsMensaje_Respuesta = 'Fechas diferentes en integral';
		
		RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');
		
	end if; 
	
			
	 			
	let vsfecencabezado = day(vdfechahoyinte)||'/'||month(vdfechahoyinte)||'/'||year(vdfechahoyinte);
				
	set isolation to dirty read;
	select count(*) into vicontador from Bditarjeta:tb_sorteo_sat;
		
	let vscontador = vicontador::char(10);
		
	LET viincremento = Length(vscontador);
		
	For vicontador2 = viincremento  TO 9 STEP 1
			LET vscontador = '0'||vscontador;
	end for;

	
	
	
	-- Primera linea del archivo
	let vsql = 'echo "00|1|SAT           |FECHA|'||vsfecencabezado||'|" >> /resplogifx/Bancoppel_SAT1_C2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	--   #########################################  Todas las no premiadas ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones =''"'||'F'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1_C2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	--   #########################################  Todas las premiadas excluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montoarchivo,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'V'||'"'' and numtarjeta <> ''"'||'4268070225475773'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agregando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1_C2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';

		--   #########################################  Todas las premiadas excluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montoarchivo,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'P'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1_C2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	--   #########################################  Todas las premiadas incluyendo especial  ####################################################################
	-- Para generar comando de descarga de datos			
	let vsql = '';
	let vsql = 	'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/SAT_BuenFin.unl '||
				'select  tporeg,banemisor,day(fchtransacintercard)||month(fchtransacintercard)||SUBSTR(year(fchtransacintercard),3,2), numtarjeta,'||
				'montoarchivo,secuenciaarchivo,numrefarchivo,montopremio,ordenabono,codigodevolucion from bditarjeta:"informix".tb_sorteo_sat where validaciones = ''"'||'V'||'"'' and numtarjeta = ''"'||'4268070225475773'||'"'';"> /resplogifx/SAT_BuenFin.sql';
			
	system vsql;
	-- Ejecución del comando anterior
	let vsql = '';
	let vsql = '';
	system vsql;
	let vsql= "dbaccess bditarjeta /resplogifx/SAT_BuenFin.sql";
	system vsql;
	-- Borrando sentencia de ejecucion
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.sql';
	system vsql;
	let vsql = '';
	-- Agragando descarga a archivo final 
	let vsql = 'cat /resplogifx/SAT_BuenFin.unl >> /resplogifx/Bancoppel_SAT1_C2017.txt';
	system vsql;
	let vsql = '';
	let vsql = '';
	system vsql;
	-- Se le agrega espacido 
	let vsql = '';
	let vsql ='rm /resplogifx/SAT_BuenFin.unl';
	system vsql;
	let vsql = '';
	
	
	-- Agregando pie de archivo
	let vsql = 'echo "99|'||vscontador||'|" >> /resplogifx/Bancoppel_SAT1_C2017.txt';
	system vsql;
		
	LET  vsMensaje_Respuesta = 'Proceso completo se genero archivo Bancoppel_SAT1_C2017.txt';

	
	RETURN 	vsCodRet, 
			NVL(vsMensaje_Respuesta,'');


END
END PROCEDURE
DOCUMENT
'AUTOR: Ricardo Resendiz Martinez',
'Proyecto: Sorteo de SAT del Buen Fin',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Complemento de descarga por transacciones probables por el estatus de la tarjeta para ser incluidas en archivo y aplicacion de transaccion devuelta',
'Fecha: 2013/12/18',
'Version: 20131218.1400',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_reproceso_mensual_personalizadas(pFecha DATE)
    RETURNING VARCHAR(5) AS CodRetorno, VARCHAR(60) AS DescRetorno;

    /*VARIABLES PARA RETORNO*/
    DEFINE CodRetorno               	 VARCHAR(5);
    DEFINE DescRetorno              	 VARCHAR(60);

    /*VARIABLES PARA CONTROL DE ERRORES*/
    DEFINE viSqlErr                 	 INTEGER;
    DEFINE viSamErr                      INTEGER;

    /*VARIABLES PARA EL CONTROL DE CONTADORES*/
    DEFINE  vsflagentransaccion     	 CHAR(1);
    DEFINE 	vicontadorregistros 		 INTEGER;
    DEFINE  vicontadorregistros2 		 INTEGER;

    /*VARIABLES PARA OPERACIÃÂN DE FECHAS*/
    DEFINE vfecha_hoy               	 DATE;
    DEFINE vultimo_dia_mes_ante_anterior DATE;
    DEFINE vprimer_dia_mes_ante_anterior DATE; 
    DEFINE vultimo_dia_mes_anterior      DATE;
    DEFINE vprimer_dia_mes_anterior      DATE;
    DEFINE vultimo_dia_mes_actual 		 DATE;
    DEFINE vprimer_dia_mes_actual	     DATE;

    DEFINE vultimo_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_ante_anterior_hora DATETIME YEAR TO FRACTION(5);
    DEFINE vultimo_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_anterior_hora      DATETIME YEAR TO FRACTION(5);
    DEFINE vultimo_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
    DEFINE vprimer_dia_mes_hora_actual 	      DATETIME YEAR TO FRACTION(5);
    DEFINE vPeriodoActual 			          VARCHAR(6);
    DEFINE vPeriodoAnterior			          VARCHAR(6);
    DEFINE vPeriodoAnteAnterior		          VARCHAR(6);
    DEFINE v_ultimo_Periodo			          VARCHAR(6);
    DEFINE vsql                               char(1150);

    /*VARIABLES PARA FUNCIONALIDAD DE QUERY */
    DEFINE  vsucursal               	INTEGER;
    DEFINE  vdiseno                		INTEGER;
    DEFINE  vtotal                  	INTEGER;
    define  vmaxnumregistros        	INTEGER;
	


    
   /* SET DEBUG FILE TO "/informix/yuliette/sp_reproceso_mensual_personalizadas.out";
    TRACE ON;*/
    

    /*INICIALIZACION VARIABLES*/

    LET 	CodRetorno = '00000';
    LET 	DescRetorno = 'Ejecucion de proceso exitosa.';
    LET     viSqlErr = 0;
    LET 	viSamErr = 0;
    LET 	vsflagentransaccion = 'F';
    LET		vicontadorregistros = 0;
    LET     vicontadorregistros2 = 0;
    LET  	vsucursal = 0;
    LET  	vdiseno    = 0;
    LET  	vtotal     = 0;
    LET     vmaxnumregistros=0;

    LET     vPeriodoActual = '';
    LET     vPeriodoAnterior = '';
    LET     vPeriodoAnteAnterior = '';
    LET     v_ultimo_Periodo = '';  

    
/*OBTENER FECHA PERIODO A REPROCESAR*/
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
let vfecha_hoy = pFecha;

    /*OBTENER EL ULTIMO DÃÂA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃÂN*/  
    LET vultimo_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_ante_anterior_hora = SUBSTRING(vultimo_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
        
        
    /*OBTENER EL PRIMER DÃÂA DEL MES PREVIO AL ANTERIOR A LA EJECUCIÃÂN*/
    LET vprimer_dia_mes_ante_anterior = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_ante_anterior_hora = extend(extend(vfecha_hoy - 2 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_ante_anterior_hora= SUBSTRING(vprimer_dia_mes_ante_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÃÂA DEL MES ANTERIOR A LA EJECUCIÃÂN*/  
    LET vultimo_dia_mes_anterior = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_anterior_hora = SUBSTRING(vultimo_dia_mes_anterior_hora FROM  1 FOR 10) || ' 23:59:59'; 
         
    /*OBTENER EL PRIMER DÃÂA DEL MES ANTERIOR A LA EJECUCIÃÂN*/
    LET vprimer_dia_mes_anterior = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY); 
    LET vprimer_dia_mes_anterior_hora = extend(extend(vfecha_hoy - 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY);
    LET vprimer_dia_mes_anterior_hora= SUBSTRING(vprimer_dia_mes_anterior_hora FROM  1 FOR 10) || ' 00:00:00'; 

    /*OBTENER EL ULTIMO DÃÂA DEL MES ACTUAL*/ 
    LET vultimo_dia_mes_actual = extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY; 
    LET vultimo_dia_mes_hora_actual= extend(extend(vfecha_hoy + 1 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 1 units DAY;
    LET vultimo_dia_mes_hora_actual= SUBSTRING(vultimo_dia_mes_hora_actual FROM  1 FOR 10) || ' 23:59:59'; 

    /*OBTENER EL PRIMER DÃÂA DEL MES ACTUAL*/ 
    LET vprimer_dia_mes_actual = extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY; 
    LET vprimer_dia_mes_hora_actual= extend(extend(vfecha_hoy -0 units MONTH,YEAR TO MONTH)||"-01",YEAR TO DAY) - 0 units DAY;
    LET vprimer_dia_mes_hora_actual = SUBSTRING(vprimer_dia_mes_hora_actual FROM  1 FOR 10) || ' 00:00:00'; 

    --Periodo a ejecutar debe ser el periodo del mes anterior al mes actual
    LET vPeriodoActual       =  YEAR(vfecha_hoy)|| LPAD(MONTH(vfecha_hoy),2,0);
    LET vPeriodoAnterior     =  YEAR(vprimer_dia_mes_anterior)|| LPAD(MONTH(vprimer_dia_mes_anterior),2,0);
    LET vPeriodoAnteAnterior =  YEAR(vprimer_dia_mes_ante_anterior)|| LPAD(MONTH(vprimer_dia_mes_ante_anterior),2,0);
	
	

BEGIN

	ON EXCEPTION
		SET viSqlErr, viSamErr

       
        LET vsql = '';
        LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta_15.unl';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f /ifxsif01/_reportes/mensual_pers/script_suc_tipo_tarjeta_15.sql';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f err_carga_15.log';
        SYSTEM vsql;
        
        LET vsql = '';
        LET vsql = ' rm -f reg_stock_vta_15.txt';
        SYSTEM vsql;
        
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		RETURN CodRetorno, DescRetorno;
	END EXCEPTION;
	
	
	
	        /*Elimina el Periodo a Reprocesar*/		
        
		DELETE from "informix".rpt_stock_venta_tp
			WHERE clave_tipotarjeta = '15' 
		AND periodo = vPeriodoAnterior;	
		
	
	
	--Ingresa los registros para las sucursales con existencias de los tipos de tarjetas 15
    LET vsql  = '';
    LET vsql  = 'echo "UNLOAD TO /RESPALDOS/suc_tipo_tarjeta_15.unl ' ||
        " SELECT '"||vPeriodoAnterior||"', tpo.clave_tipotarjeta , suc.clave_sucursal, suc.nombre_sucursal, img.id_diseno, img.descripcion_diseno, 0, 0, 0, 0, 0, 0" ||
        ' FROM intercard:"informix".sucursal_tipotarjeta tpo, intercard:"informix".cat_imagenespredisenadas img, intercard:"informix".sucursal suc ' ||
        ' where tpo.clave_tipotarjeta  = "15" and ' ||
        ' tpo.clave_sucursal = suc.clave_sucursal and  ' ||
        ' (tpo.existencia > 0 or tpo.solicitadas > 0) and img.activa = "1" ' ||
        ' order by tpo.clave_sucursal, img.id_diseno; ' ||
        ' "> /resplogifx/script_suc_tipo_tarjeta_15.sql';
    SYSTEM vsql;
                
    LET vsql = '';
    LET vsql = ' dbaccess bditarjeta /resplogifx/script_suc_tipo_tarjeta_15.sql';
    SYSTEM vsql;
        
    LET vsql = '';
    LET vsql = "echo "||'"'|| "file '"||'/RESPALDOS/'||
                          'suc_tipo_tarjeta_15.unl' || "' delimiter '|' "|| '12'||
                          "; INSERT INTO rpt_stock_venta_tp" || ";"||'"'||' > reg_stock_vta_15.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "dbload -d bditarjeta -c reg_stock_vta_15.txt -l err_carga_15.log -n 1000 -k";
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = ' rm -f /RESPALDOS/suc_tipo_tarjeta_15.unl';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f /resplogifx/script_suc_tipo_tarjeta_15.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f err_carga_15.log';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = ' rm -f reg_stock_vta_15.txt';
    SYSTEM vsql;
    
            
	--*** PROCEDIMIENTO PARA LLENADO DE REPORTE DE TARJETAS TIPO 15 PERSONALIZAS ***
	--Descarga de Asignaciones de Tarjetas 
    select  (year(tjt.fechaasignacion)|| LPAD(month(tjt.fechaasignacion),2,0)) as periodo, lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
       det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as asignacion
       from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
            intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
       where lte.numerolote = det.numlote and
            tjt.numerolote = det.numlote and
            tjt.numerolote = lte.numerolote and
            flt.numerolote = lte.numerolote and
            lte.clave_sucursal = suc.clave_sucursal and
            tjt.numtarjeta = det.numtarjeta and
            img.id_diseno = det.id_diseno and
            lte.clave_tipotarjeta = '15' and
            tjt.fechaasignacion  >= vprimer_dia_mes_anterior_hora and -- MAYO  05/05/2018
            tjt.fechaasignacion  <= vultimo_dia_mes_anterior_hora     -- JUNIO
            group by 1,2,3,4,5
            order by 1,2,3,4,5
    into temp tt_asignacion_15 with no log;
	
	---CreaciÃÂ³n de ÃÂ­ndices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_asignacion_15_periodo
        ON "informix".tt_asignacion_15(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_15_sucursal
        ON "informix".tt_asignacion_15(sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_asignacion_15_imagen
        ON "informix".tt_asignacion_15(imagen) ONLINE;
        
	--IntegraciÃÂ³n de Registros de AsignaciÃÂ³n de Tarjetas a Estructura rpt_stock_venta_tp
    update rpt_stock_venta_tp inv
    set inv.asignacion = (
    select asg.asignacion from tt_asignacion_15 asg
    where inv.periodo = asg.periodo and
          inv.clave_sucursal = asg.sucursal and
          inv.id_diseno = asg.imagen)
          where inv.periodo = (
                    select asg.periodo from tt_asignacion_15 asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
                inv.clave_sucursal = (select asg.sucursal from tt_asignacion_15 asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
                inv.id_diseno = (select asg.imagen from tt_asignacion_15 asg
                        where inv.periodo = asg.periodo and
                              inv.clave_sucursal = asg.sucursal and
                              inv.id_diseno = asg.imagen) and
        inv.clave_tipotarjeta = '15' and
	    inv.periodo = vPeriodoAnterior;
			  
    --8) Descarga de Reposiciones de Tarjetas (que fueron sustituciÃÂ³n)
	--Se busca primero las tarjetas que corresponden a reposiciones

    select (year(tjt.fechaasignacion)|| LPAD(month(tjt.fechaasignacion),2,0)) as periodo, lte.clave_sucursal as clave_sucursal, suc.nombre_sucursal as nombre_sucursal, 
       det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as reposicion
       from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
            intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
       where lte.numerolote = det.numlote and
            tjt.numerolote = det.numlote and
            tjt.numerolote = lte.numerolote and
            flt.numerolote = lte.numerolote and
            lte.clave_sucursal = suc.clave_sucursal and            
            tjt.numtarjeta = det.numtarjeta and
            img.id_diseno = det.id_diseno and
            lte.clave_tipotarjeta = '15' and
            tjt.numtarjeta in(
            select tjt1.numtarjetasustituta
             from intercard:"informix".tarjeta tjt1
             where tjt1.numtarjetasustituta is not null and
                   tjt1.fechaasignacion  >= vprimer_dia_mes_anterior_hora and
	               tjt1.fechaasignacion  <= vultimo_dia_mes_anterior_hora and
                   tjt1.numtarjetasustituta in(
                                   select tjt.numtarjeta
                                   from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, 
								        intercard:"informix".cat_imagenespredisenadas img, intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt
                                   where lte.numerolote = det.numlote and
                                         tjt.numerolote = det.numlote and
										 tjt.numerolote = lte.numerolote and
										 flt.numerolote = lte.numerolote and
										 lte.clave_sucursal = suc.clave_sucursal and            
										 tjt.numtarjeta = det.numtarjeta and
										 img.id_diseno = det.id_diseno and
										 lte.clave_tipotarjeta = '15'))
						 
        group by 1,2,3,4,5
        order by 1,2,3,4,5
        into temp tt_reposicion_15 with no log;
	
    ---CreaciÃÂ³n de ÃÂ­ndices en periodo, sucursal e imagen.
    CREATE INDEX "informix".idx_tt_reposicion_15_periodo
        ON "informix".tt_reposicion_15(periodo) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_15_cve_sucursal
        ON "informix".tt_reposicion_15(clave_sucursal) ONLINE;
    CREATE INDEX "informix".idx_tt_reposicion_15_imagen
        ON "informix".tt_reposicion_15(imagen) ONLINE;
    
	--9) IntegraciÃÂ³n de Registros de Reposicion de Tarjetas a Estructura Base

    update rpt_stock_venta_tp inv
    set inv.reposicion = (
    select rep.reposicion from tt_reposicion_15 rep
           where inv.periodo = rep.periodo and
                 inv.clave_sucursal = rep.clave_sucursal and
                 inv.id_diseno = rep.imagen and
		         inv.clave_tipotarjeta = '15')
    where inv.periodo = (
                    select rep.periodo from tt_reposicion_15 rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                    inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion_15 rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                    inv.id_diseno = (select rep.imagen from tt_reposicion_15 rep
                        where inv.periodo = rep.periodo and
                              inv.clave_sucursal = rep.clave_sucursal and
                              inv.id_diseno = rep.imagen) and
                    inv.clave_tipotarjeta = '15'and
	             inv.periodo = vPeriodoAnterior;
	
    --Creamos una copia de rpt_stock_venta_tp para actualizacion de reposiciones / asignaciones para el tipo tarjeta y periodo requerido

    select * from rpt_stock_venta_tp
	         where periodo = vPeriodoAnterior and
			       clave_tipotarjeta = '15'
    into temp tt_reposicion_asignacion_15 with no log;	

    
    CREATE INDEX "informix".idx_tt_repo_asignacion_15_cve_sucursal
        ON "informix".tt_reposicion_asignacion_15(clave_sucursal) ONLINE;
        CREATE INDEX "informix".idx_tt_repo_asignacion_15_id_diseno
        ON "informix".tt_reposicion_asignacion_15(id_diseno) ONLINE;
    CREATE INDEX "informix".idx_tt_repo_asignacion_15_cve_tipotarjeta
        ON "informix".tt_reposicion_asignacion_15(clave_tipotarjeta) ONLINE;
    
	--Ajuste de Registros de Reposicion  = Asignacion = Asignacion - Reposicion

    update rpt_stock_venta_tp inv
    set inv.asignacion = 
                (select rep.asignacion - rep.reposicion  from tt_reposicion_asignacion_15 rep
                 where inv.periodo = rep.periodo and
                       inv.clave_sucursal = rep.clave_sucursal and
                       inv.id_diseno = rep.id_diseno and
                       inv.clave_tipotarjeta = rep.clave_tipotarjeta and
                       inv.clave_tipotarjeta = '15')    
    where inv.periodo = (select rep.periodo from tt_reposicion_asignacion_15 rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '15' ) and
          inv.clave_sucursal = (select rep.clave_sucursal from tt_reposicion_asignacion_15 rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '15') and
          inv.id_diseno = (select rep.id_diseno from tt_reposicion_asignacion_15 rep
                         where inv.periodo = rep.periodo and
                               inv.clave_sucursal = rep.clave_sucursal and
                               inv.id_diseno = rep.id_diseno and
                               rep.clave_tipotarjeta = '15') and
          inv.clave_tipotarjeta = '15' and
		  inv.periodo = vPeriodoAnterior;
		  
        -- Descarga de Ventas de Tarjetas Personalizadas
        select  (year(sol.fechasolicitud)|| LPAD(month(sol.fechasolicitud),2,0)) as periodo, lte.clave_sucursal as sucursal, suc.nombre_sucursal as nombre_sucursal, 
                det.id_diseno as imagen, img.descripcion_diseno as descripcion, count(distinct(det.numtarjeta)) as venta
        from intercard:"informix".lote lte, intercard:"informix".detalle_maquila det, intercard:"informix".sucursal suc, intercard:"informix".cat_imagenespredisenadas img,
             intercard:"informix".tarjeta tjt, intercard:"informix".flujolote flt, intercard:"informix".solicitudtarjeta sol
        where sol.idsolicitud = det.idsolicitud and
              lte.numerolote = det.numlote and
              tjt.numerolote = det.numlote and
              tjt.numerolote = lte.numerolote and
              flt.numerolote = lte.numerolote and
              lte.clave_sucursal = suc.clave_sucursal and
              tjt.numtarjeta = det.numtarjeta and
              img.id_diseno = det.id_diseno and
			  sol.fechasolicitud >= vprimer_dia_mes_anterior_hora and
			  sol.fechasolicitud <= vultimo_dia_mes_anterior_hora and
              lte.clave_tipotarjeta = '15'
              group by 1,2,3,4,5
              order by 1,2,3,4,5
        into temp tt_venta_15 with no log;

        CREATE INDEX "informix".idx_tt_venta_15_periodo
            ON "informix".tt_venta_15(periodo) ONLINE;
        CREATE INDEX "informix".idx_tt_venta_15_sucursal
            ON "informix".tt_venta_15(sucursal) ONLINE;
        CREATE INDEX "informix".idx_tt_venta_15_imagen
            ON "informix".tt_venta_15(imagen) ONLINE;

        -- Ajuste de Registros de Reposicion  = Asignacion = Asignacion - Reposicion
		update rpt_stock_venta_tp inv
		set inv.venta = 
		   (select vta.venta from tt_venta_15 vta
			where inv.periodo = vta.periodo and
				  inv.clave_sucursal = vta.sucursal and
				  inv.id_diseno = vta.imagen)    
		where inv.periodo = (select vta.periodo from tt_venta_15 vta
								where inv.periodo = vta.periodo and
									  inv.clave_sucursal = vta.sucursal and
									  inv.id_diseno = vta.imagen) and
			  inv.clave_sucursal = (select vta.sucursal from tt_venta_15 vta
								where inv.periodo = vta.periodo and
									  inv.clave_sucursal = vta.sucursal and
									  inv.id_diseno = vta.imagen) and
			  inv.id_diseno = (select vta.imagen from tt_venta_15 vta
								where inv.periodo = vta.periodo and
									  inv.clave_sucursal = vta.sucursal and
									  inv.id_diseno = vta.imagen) and
		inv.clave_tipotarjeta = '15' and
		inv.periodo = vPeriodoAnterior;
		
	SET pdqpriority 0;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".rpt_stock_venta_tp;  
	 		
		let vsql = ''; 	   
	    let vsql = 'echo "Periodo|TipoTarjeta|Sucursal|Nombre de Sucursal|Imagen|Nombre de la Imagen|Venta|Asignacion|Reposicion">/RESPALDOS/REPpersonalizada_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
		let vsql=  'echo "UNLOAD TO /RESPALDOS/REPpersonalizada.unl select periodo,clave_tipotarjeta,clave_sucursal,nombre_sucursal,id_diseno,descripcion_diseno,venta,asignacion,reposicion from rpt_stock_venta_tp where clave_tipotarjeta = 15 and periodo = ' 
					|| vPeriodoAnterior || ';">/RESPALDOS/REPpersonalizada.sql'; 
		system vsql;
		let vsql ='';
		let vsql= 'chmod 777 /RESPALDOS/REPpersonalizada.sql';
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess bditarjeta /RESPALDOS/REPpersonalizada.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm /RESPALDOS/REPpersonalizada.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' /RESPALDOS/REPpersonalizada.unl >>/RESPALDOS/REPpersonalizada_"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
		system vsql;
		let vsql ='rm /RESPALDOS/REPpersonalizada.unl';
		system vsql;
													 
		RETURN CodRetorno, DescRetorno;
END;
END PROCEDURE

--****************************************************************************************************
--DESCRIPCION: REPORTES MENSUALES STOCK TARJETAS PERSONALIZADAS:
--AUTOR :  YULIETTE PEREZ LOPEZ
--FECHA : 01/08/2018
--BD: BDITARJETA
--****************************************************************************************************
;

CREATE PROCEDURE "informix".sp_guardabitacora_mc(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;

	/*
    *****************************************************************************************************
     -- DESCRIPCION:  GUARDA BITACORA  -------------------------------------------------------------------
	-- AUTOR : Victoria QuiÃ±ones  -----------------------------------------------------------------------
	-- FECHA : 01/06/2018  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
	-- SISTEMA : Conciliacion de MasterCard - Oxxo  --------------------------------
	*****************************************************************************************************
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsFechaHora DATETIME YEAR TO FRACTION(5);

	/*INICIALIZACION DE VARIABLES*/

	LET visqlerr = 0;
	LET vssqlerr = '00000';
	LET vsFechaHora = CURRENT;

	BEGIN

		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

		
		--SET DEBUG FILE TO '/informix/LVRQ/CNC_MC_OXXO/DEBUG/TraceGUARDABITACORA.txt';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;


		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_mc (elemento, fecha_hora, actividad, cve_usuario)
		VALUES (psElemento,vsFechaHora,psActividad,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;


	END

END PROCEDURE
DOCUMENT
'AUTOR: Victoria QuiÃ±ones',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA BITACORA.',
'Fecha: 2011/07/01',
'Version: 20110701.1616',
'BD: bditarjeta';

CREATE PROCEDURE "informix".sp_nombre_archivo_mc ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_OXXO			CHAR (35);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
			

			
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;

			  
				DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc;

			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/ifxsif01/LVRQ/debug/nombre_archivo_mc.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_OXXO				= '';
				LET vListArchivo			= 'listado_archivos.txt';
				LET vArchiBat				= 'ls_bat.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
			-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
				DELETE FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc;
				
				SELECT rep_aix
				INTO vRUTA_OXXO
				FROM BdiTarjeta:"informix".td_archivo_origentmp_mc
				WHERE archivo_origen='MCO';
				 
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "ls '|| vRUTA_OXXO || '| grep BCPL.T464.D " > ' || vRUTA_OXXO||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL ='';
				LET vExecuteSQL= 'chmod 777 ' || vRUTA_OXXO||'/'||vArchiBat;
				system vExecuteSQL;
				
				
				LET vExecuteSQL = ''; 
                LET vExecuteSQL =  vRUTA_OXXO||'/'||vArchiBat ||'>'|| vRUTA_OXXO||'/'||vListArchivo; 
				SYSTEM vExecuteSQL; 
				 
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm '||vRUTA_OXXO||'/'||vArchiBat;
				system vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_OXXO) || '/' || TRIM(vListArchivo) ||
								 ' INSERT INTO BdiTarjeta:td_cga_nombre_archivo_mc;" > ' || TRIM(vRUTA_OXXO) ||  '/load_nombre_archivo.sql';
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_OXXO) ||  '/load_nombre_archivo.sql';
				SYSTEM vExecuteSQL;
			
				LET vExecuteSQL = '';
				LET vExecuteSQL = 'rm '||vRUTA_OXXO||'/'||vListArchivo;
				system vExecuteSQL;
			
				 
				 
			FOREACH cursor_archivo FOR	
			
				SELECT nom_archivo_mc
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_cga_nombre_archivo_mc
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,12,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,5,2)||'/'||SUBSTR(dsFechaArchivo,1,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				
				--TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
				
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_mc(nombrearchivo, archivo_origen, fecha_archivo, num_registros325, monto325,
							fecha_proceso, fecha_hora_transferencia, fecha_hora_ini_proceso, fecha_hora_carga_archivo, fecha_hora_carga_tabla,
							fecha_hora_ini_concilia_reg, fecha_hora_fin_concilia_reg, fecha_hora_fin_proceso, fecha_hora_gen_conadmin, transferencia,
							carga, conadmin, traspaso_historico, num_cargo, monto_cargo, num_abono, monto_abono, proceso) 
				VALUES( vsNombreArchivo, 'MCO', dsFechaArchivo, 0, 0, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
						'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', '', 'F', 0, 0, 0, 0, 'P');
				

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
		
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE;
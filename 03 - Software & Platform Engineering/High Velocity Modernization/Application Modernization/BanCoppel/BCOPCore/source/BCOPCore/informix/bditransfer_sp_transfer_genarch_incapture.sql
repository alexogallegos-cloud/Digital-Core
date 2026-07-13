create procedure "informix".sp_transfer_genarch_incapture (psfechahoy date)
returning
			varchar(6),varchar(80);
			
define  sql_err          		integer;
define  isam_err         		integer;
define  error_info       		varchar(80);

define  p_cod_ret        		char(5);
define  p_mensaje        		char(80);
define  vdfechahoy 		 		date;
define  vsflagentransaccion  	char(1);

define  vsprefijo_archivo 		char(30);
define  vsrep_aix         		char(50);
define  vicontador        		integer;
define  vscontador        		char(6);
define  vscontador1        		char(6);
define  vicontadorregistros 	integer;
define  vicontadorcaracteres	integer;
define  vdfechasistema 			datetime year to fraction (5);

define vsnombrearchivo 			char(50);
define viconsecutivo 			integer;
define a 						integer;
define vsheader					char(35);
define vstrailer        		char(41);
define vscnc					char(1);
define vsdelimitador            char(15);
define vmsumatransacciones      money (7,2);
define vssumatransacciones      char(9);
define vilonguitudmonto         integer;

-- Para generacion de ARchivo

define vssql					char(1200);
define vssql1					char(100);




begin
   on exception set sql_err, isam_err, error_info
		set debug file to "/resplogifx/sp_transfer_genarch_incapture1.out";
		trace on;
   
		let p_cod_ret  = sql_err;
		let p_mensaje  = error_info;
      return p_cod_ret, p_mensaje;
   end exception;


   
--set debug file to "/tmp/ivan/rich/sp_transfer_genarch_incapture.out";
--trace on;

let p_cod_ret = '00000';
let p_mensaje = 'Proceso exitoso';

let vdfechahoy = '01/01/1900';

let  vsprefijo_archivo  = '';
let  vsrep_aix          = '';
let  vicontador         = 0;
let  vscontador         = '';
let  vscontador1        = '';
let  vsflagentransaccion = 'F';
let  vicontadorregistros = 0;
let  vicontadorcaracteres = 0;
let  vsnombrearchivo = '';
let  viconsecutivo = 0;
let  a = 0;
let  vdfechasistema 	= current;
let  vsheader = '';
let  vstrailer ='';
let  vscnc = '';
let  vmsumatransacciones = 0.0;
let  vssumatransacciones = '';
let  vilonguitudmonto   = 0;

let  vssql = '';
let  vssql1 = '';
let  vsdelimitador = 'DELIMITER '||'"'||','||'"';


set isolation to dirty read;
select fecha_hoy into vdfechahoy from Bdinteg:"informix".si_fechas
where empresa = '001';

if psfechahoy <> vdfechahoy then 
	let p_cod_ret = '00001';
	let p_mensaje = 'Existen discrepancias entre la fechas integral y ejecución';
	
	return  p_cod_ret,
			p_mensaje;
end if;

set isolation to dirty read;
select valor into vscnc from Bditarjeta:"informix".td_param_conciliacion_concreing
where codigo = '001';

if vscnc = 'V' then 
	let p_cod_ret = '00002';
	let p_mensaje = 'El proceso de CNC esta ejecucion, no se puede procesar';
	
	return  p_cod_ret,
			p_mensaje;
end if;

-- recuperando prefijo de archivo y ruta de almacenamiento 



set isolation to dirty read;
select prefijo_archivo, rep_aix 
	into vsprefijo_archivo, vsrep_aix
	from Bditransfer:"informix".tf_catarchivo_transfer
		where tipo_layout = 51;
		


set isolation to dirty read;
select count(consecutivo) , sum((monto::money)/100)
	into vicontador, vmsumatransacciones
	from Bditransfer:"informix".tf_incapture
		where 	status_envio = 'P' and
				archivo_origen in ('TCD', 'VID' ,'VND' ,'MCD');
				
if vmsumatransacciones is null then 
	let vmsumatransacciones = 0.0;
end if;

-- Arma Nombre del archivo 
let vsnombrearchivo = trim(vsprefijo_archivo)||lpad(day(vdfechahoy),2,'0')||lpad(month(vdfechahoy),2,'0')||year(vdfechahoy)||'_1.txt';
-- Arma el contador para el uso en el encabezado del archivo
let vscontador1 = cast(vicontador as char(6));
let vicontadorcaracteres = length (vscontador1);
-- Pasa valor de contador a cadena 
let vscontador = cast(vicontador as char(6));
-- Complementa la cadena para armar el numero de transacciones a reportar en el archivo 
FOR  a = vicontadorcaracteres  TO 5 STEP 1
				LET vscontador = '0'||vscontador;
END FOR;


let vssumatransacciones = cast(vmsumatransacciones as char(9));
let vssumatransacciones = replace(replace(vssumatransacciones,'.',''),'$','');
let vilonguitudmonto    = length(vssumatransacciones);

let a = 0;

for a = vilonguitudmonto to 8 step 1
	let vssumatransacciones = '0'||vssumatransacciones;
end for;

let vsheader = '0000137 00000003        '||vscontador||'01';
let vstrailer = '        7'||vscontador||vssumatransacciones||'000000000000000';


if vicontador > 0 then 

	--################################ PROCESO PARA GENERAR ARCHIVO ###############################################
	-- Para generar el encabezado del archivo y grabarlo en el archivo final 
	let vsnombrearchivo= vsnombrearchivo;
	let vsdelimitador= vsdelimitador;
	let vssql = '';
	let vssql = '';
	--let vssql = 'echo "0,000008,201409261415" >/home/systrans/incomming/'||trim(vsnombrearchivo)||'';
	let vssql = 'echo "'||trim(vsheader)||'" > "'||trim(vsrep_aix)||trim(vsnombrearchivo)||'"';
	SYSTEM vssql;
	-- Genera comando para ejecurtar descarga
	let vssql = '';
	let vssql = '';  						--''"'||'1'||'"''
	let vssql = 'echo "UNLOAD TO '||trim(vsrep_aix)||'tfincapture.unl  select trim(id_banco)||''"'||' 3'||'"''||''"'||'5804'||'"''||trim(cuenta)||trim(secuencia)||trim(monto)||trim(id_negocio)||trim(referencia_batch)||trim(limite_piso)||trim(dias_ajuste)||trim(fecha_alta)||inf_comercio||poblacion||tpo_batch||califica||secuencia_txn||reservado1||referencia_23||num_busca||monto_dlr||monto_dev||reservado3||pais||tpo_negocio||cargos_parc||rembolso||monedero_elect||cve_esp||reservado4||moneda_liq||moneda_txn||fecha_conv||tpo_cambio||mensual||id_transp||rfc from Bditransfer:tf_incapture where status_envio = ''"'||'P'||'"'' and archivo_origen in (''"'||'TCD'||'"'', ''"'||'VID'||'"'' ,''"'||'VND'||'"'' ,''"'||'MCD'||'"'');" >'||trim(vsrep_aix)||'descargasincapture.sql'; 
	--let vssql = 'echo "UNLOAD TO '||trim(vsrep_aix)||'tfsvaincoming.unl  DELIMITER ''","'' select trim(tpo_id),Trim(cuenta),trim(nvo_monto),trim(comentario) from Bditransfer:"informix".tf_sva_incoming where status_envio =''"'||'P'||'"'' and fecha_proceso <= ''"'||vdfechahoy||'"'';" >'||trim(vsrep_aix)||'descargasvaincomming.sql'; 
	SYSTEM vssql;
	-- Ejecuta comando para genera archivo 
	let vssql = '';
	let vssql = '';
	--let vssql = 'dbaccess bditransfer '||trim(vsrep_aix)||'descargasincapture.sql';    -- Desarrollo
	let vssql = '/ifxsif01/bin/dbaccess bditransfer '||trim(vsrep_aix)||'descargasincapture.sql';  -- Producción
	system vssql;
	-- Borra archivo del comando que genero el archivo 
	let vssql = '';
	let vssql = '';
	--let vssql = 'rm '||trim(vsrep_aix)||'descargasincapture.sql';   -- Desarrollo
	let vssql = '/usr/bin/rm '||trim(vsrep_aix)||'descargasincapture.sql';   -- Producción 
	system vssql;

	-- Concatena archivo con encabezado con el archivo generado por la descarga 
	let vssql ='';
	let vssql =''; 
	--let vssql = "sed 's/|$//g' " ||TRIM(vsrep_aix)||TRIM('tfincapture.unl') || " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);  -- Desarrollo
	let vssql = "/usr/bin/sed 's/|$//g' " ||TRIM(vsrep_aix)||TRIM('tfincapture.unl') || " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);   -- Producción
	system vssql;

	-- Borra archivo de la descarga
	let vssql ='';
	let vssql ='';
	--let vssql = 'rm '||trim(vsrep_aix)||'tfincapture.unl';       -- Desarrollo
    let vssql = '/usr/bin/rm '||trim(vsrep_aix)||'tfincapture.unl';  -- Produccion
	system vssql;
	-- Permisos al archivo 
	let vssql = '';
	let vssql = '';
	--let vssql = 'chmod 777 ' || TRIM(vsrep_aix) ||  TRIM (vsnombrearchivo);   -- Desarrollo
	let vssql = '/usr/bin/chmod 777 ' || TRIM(vsrep_aix) ||  TRIM (vsnombrearchivo);  -- Producción
	system vssql;

	-- Crea archivo con el trailer
	let vssql = '';
	let vssql = '';
	let vssql = 'echo "'||vstrailer||'" > '||trim(vsrep_aix)||'finarchivo.txt';
	--let vssql = 'echo "'||trim(vsheader)||'" > "'||trim(vsrep_aix)||trim(vsnombrearchivo)||'"';
	SYSTEM vssql;


	-- Agrega archivo de trailer al archivo definitivo 
	let vssql ='';
	let vssql =''; 
	--let vssql = "sed 's/|$//g' " ||TRIM(vsrep_aix)||'finarchivo.txt'|| " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);   --Desarrollo
	let vssql = "/usr/bin/sed 's/|$//g' " ||TRIM(vsrep_aix)||'finarchivo.txt'|| " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);   -- Producción
	--let vssql = "sed 's/|$//g' " ||TRIM(vsrep_aix)||TRIM('tfincapture.unl') || " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);
	system vssql;

	-- Borra archivo del trailer
	let vssql ='';
	let vssql ='';
	--let vssql = 'rm '||trim(vsrep_aix)||'finarchivo.txt';  -- Desarrollo
	let vssql = '/usr/bin/rm '||trim(vsrep_aix)||'finarchivo.txt';  -- Producción
	system vssql;


	let vsflagentransaccion = 'F';		
	set isolation to dirty read;
	foreach cusor1 with hold for
		
			select consecutivo into viconsecutivo
				from bditransfer:"informix".tf_incapture 
				where 	status_envio = 'P' and
					archivo_origen in ('TCD', 'VID' ,'VND' ,'MCD')

			if (vsflagentransaccion = 'F') then 
				begin work;
				let vsflagentransaccion = 'V';
			end if;
				
			update Bditransfer:"informix".tf_incapture
				set status_envio = 'V', 
					nombre_archivo_envio = vsnombrearchivo
				where status_envio = 'P' and
					  consecutivo = viconsecutivo;
			
			let vicontadorregistros = vicontadorregistros + 1;
			let p_mensaje = 'terminar transaccion';	--termina el bloque de registros por transaccion
			
			if (vicontadorregistros = 1000) then --verifica si alcanzo el maximo de transacciones por bloque
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;
		end foreach;
		let p_mensaje = 'terminar transaccion';	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;	


	let vicontadorregistros = 0;
	let vsflagentransaccion = 'F';
	set isolation to dirty read;
		
		foreach cusor1 with hold for
			
			select consecutivo into viconsecutivo
				from bditransfer:"informix".tf_incapture 
				where 	status_envio = 'P' and
						archivo_origen not in ('TCD', 'VID' ,'VND' ,'MCD')

			if (vsflagentransaccion = 'F') then 
				begin work;
				let vsflagentransaccion = 'V';
			end if;
					
			update Bditransfer:"informix".tf_incapture
				set status_envio = 'I', 
					nombre_archivo_envio = 'No se envia por no cumplir con reglas'
				where status_envio = 'P' and
					  consecutivo = viconsecutivo;
				
			let vicontadorregistros = vicontadorregistros + 1;
			let p_mensaje = 'terminar transaccion';	--termina el bloque de registros por transaccion
				
			if (vicontadorregistros = 1000) then --verifica si alcanzo el maximo de transacciones por bloque
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;
		end foreach;
		
	let p_mensaje = 'terminar transaccion';	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then --verifica si existe un bloque de transaccion pendiente
		commit work;
		let vsflagentransaccion = 'F';
	end if;		

else
	--- #######################Genera archivo con Encabezado y Pie de pagina Vacio ##########################
	-- Para generar el encabezado del archivo y grabarlo en el archivo final 
	let vsnombrearchivo= vsnombrearchivo;
	let vsdelimitador= vsdelimitador;
	let vssql = '';
	let vssql = '';
	--let vssql = 'echo "0,000008,201409261415" >/home/systrans/incomming/'||trim(vsnombrearchivo)||'';
	let vssql = 'echo "'||trim(vsheader)||'" > "'||trim(vsrep_aix)||trim(vsnombrearchivo)||'"';
	SYSTEM vssql;
	
		-- Crea archivo con el trailer
	let vssql = '';
	let vssql = '';
	let vssql = 'echo "'||vstrailer||'" > '||trim(vsrep_aix)||'finarchivo.txt';
	--let vssql = 'echo "'||trim(vsheader)||'" > "'||trim(vsrep_aix)||trim(vsnombrearchivo)||'"';
	SYSTEM vssql;


	-- Agrega archivo de trailer al archivo definitivo 
	let vssql ='';
	let vssql =''; 
	--let vssql = "sed 's/|$//g' " ||TRIM(vsrep_aix)||'finarchivo.txt'|| " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);  -- Desarrollo
	let vssql = "/usr/bin/sed 's/|$//g' " ||TRIM(vsrep_aix)||'finarchivo.txt'|| " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);  -- Producción
	--let vssql = "sed 's/|$//g' " ||TRIM(vsrep_aix)||TRIM('tfincapture.unl') || " >> " ||TRIM(vsrep_aix) ||TRIM(vsnombrearchivo);
	system vssql;

	-- Borra archivo del trailer
	let vssql ='';
	let vssql ='';
	--let vssql = 'rm '||trim(vsrep_aix)||'finarchivo.txt';  -- Desarrollo
	let vssql = '/usr/bin/rm '||trim(vsrep_aix)||'finarchivo.txt';  -- Producción
	system vssql;

	
	let p_cod_ret = '00003';
	let p_mensaje = 'No hay registros se genero archivo con encabezado';
	
	return  p_cod_ret,
			p_mensaje;
	
	end if;	


let p_cod_ret = '00000';
let p_mensaje = 'Marcado de registros a ser descargados exitoso';
	
return  p_cod_ret,
		p_mensaje;

end
	
end procedure
DOCUMENT
'AUTOR: Ricardo Reséndiz Martinez',
'Proyecto: Integracion de Transfer',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Proceso para el marcado de los registros con el nombre del archivo con el cual van a ser enviados y el estatus de envio y generacion del archivo',
'Fecha: 2014/09/26',
'Version: 20140926.1230',
'BD: bditransfer',
'',
'MODIFICO: Ricardo Reséndiz Martinez',
'Proyecto: Integracion de Transfer',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se movio proceso de descarga para que el proceso descargara los pendientes y posterior a esto realizara el marcaje',
'Fecha: 2014/10/13',
'Version: 20141013.1030',
'BD: bditransfer',
'',
'MODIFICO: Ricardo Reséndiz Martinez',
'Proyecto: Integracion de Transfer',
'Solicito: Jose Luis Puebla Salinas',
'Descripcion: Se agregan comandos para procesos de descarga de registros en ambiente productivo',
'Fecha: 2015/01/27',
'Version: 20150127.1920',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_transfer_fechaemision(pEmpresa char(3), dFechaEmision date)
RETURNING CHAR(5);
   
    DEFINE vcSql                    CHAR(600);
    DEFINE vcStmt                   CHAR(250);
    --DEFINE vNombre_cte              CHAR(150);
    DEFINE vcodret                  CHAR(5);
    --DEFINE vCP                      CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    --DEFINE vRFC_Cliente             CHAR(13);
    --DEFINE vSucursal_num            CHAR(4);
    DEFINE vdescripcion             CHAR(180);
    --DEFINE vDireccion_cte           CHAR(200);
    DEFINE vSucursal_nombre         CHAR(40);
    DEFINE vexiste_genedoctaeje     CHAR(3);
    --DEFINE vClabe                   CHAR(60);
    --DEFINE vCurp                    CHAR(60);
    DEFINE vcortSig                 CHAR(255);
    --DEFINE vDireccion_col           CHAR(120);
    DEFINE vDireccion_del           CHAR(120);
    DEFINE vEdo_cd                  CHAR(120);
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vErrorInfo               CHAR(80);
    DEFINE vaniomes                 CHAR(6);
    DEFINE vcodretDet               CHAR(6);
    DEFINE vcodretEnc               CHAR(6);
    DEFINE vmin_aniomes             CHAR(6);
    DEFINE vmax_aniomes             CHAR(6);
    --DEFINE vcuenta                  CHAR(20);
    --DEFINE vNum_cte                 CHAR(20);
    DEFINE vmin_cta                 CHAR(20);
    DEFINE vmax_cta                 CHAR(20);
    DEFINE vMensajeProducto         CHAR(255);
    DEFINE vPiePagina               CHAR(255);
   
    DEFINE bInicia                  BOOLEAN;
   
    DEFINE iIsamErr                 SMALLINT;
    --DEFINE viDias                   SMALLINT;
   
    DEFINE vsdocuenta               MONEY(14,2);
    DEFINE vdeposito                MONEY(14,2);
    DEFINE vretiro                  MONEY(14,2);
   
    DEFINE vTasaBruta               DECIMAL(9, 6);
    DEFINE vGAT                     DECIMAL(9, 6);
    DEFINE vIvaOtrosCargos          DECIMAL(18,2);
    --DEFINE vSaldoCorte              DECIMAL(18,2);
    --DEFINE vSaldoPromedio           DECIMAL(18,2);
    DEFINE vInteresesNetos          DECIMAL(18,2);
    --DEFINE vSaldoAnterior           DECIMAL(18,2);
    --DEFINE vDepositos               DECIMAL(18,2);
    DEFINE vInteresesPagados        DECIMAL(18,2);
    --DEFINE vRetiros                 DECIMAL(18,2);
    DEFINE vOtrosCargos             DECIMAL(18,2);
    DEFINE vRetencionIsr            DECIMAL(18,2);
    DEFINE vTotRetirosEfec          DECIMAL(18,2);
    DEFINE vTotOtrosCargos          DECIMAL(18,2);
   
    DEFINE vcortSig2                INTEGER;
    DEFINE vsecuencia               INTEGER;
    DEFINE vnlinea                  INTEGER;
    DEFINE vidreg                   INTEGER;
    DEFINE vsqlerr                  INTEGER;
    DEFINE visamerr                 INTEGER;
   
    DEFINE vultejec                 DATE;
    DEFINE vfecha_hoy               DATE;
    DEFINE vfecha_ant               DATE;
    DEFINE vfechaAlta               DATE;
    DEFINE vfechealt                DATE;
    DEFINE vFecha_emision           DATE;
    --DEFINE vFechaAltaEnc            DATE;
    --DEFINE vFechaInicio             DATE;
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
    --DEFINE dFechaEmision            DATE;
   
    DEFINE vsql                     CHAR(500);
    DEFINE vfecha                   CHAR(8);
    DEFINE vfechaproc               DATE;
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
    DEFINE vestado             CHAR(50);
    DEFINE vciudad             VARCHAR(60); 
    DEFINE vtelefono         CHAR(14);
    DEFINE vgerente         CHAR(40);
    DEFINE cNumProducto        CHAR(4);
    DEFINE vmensaje            CHAR(255);
     
    DEFINE vfechafin         DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vnumcte            CHAR(20);
    DEFINE vnumctetf        CHAR(20);
    DEFINE vnombre_completo CHAR(150);
    DEFINE vdireccion          CHAR(200);
    DEFINE vzona               CHAR(120);
    DEFINE vnomsuc             CHAR(40);
    --DEFINE vciudad ya esta declarado arriba
    --DEFINE vestado 
    --DEFINE vMensajeProducto     CHAR(255);   ya esta definida arriba
    DEFINE vrfc                CHAR(13);
    DEFINE vrfc_alterno        CHAR(13);
    DEFINE vcp                CHAR(5);
    DEFINE vclabe            CHAR(60);
    DEFINE vcurp            CHAR(60);
    DEFINE valta_cte        DATE;
    DEFINE vfechaini        DATE;
    DEFINE vsucursal        CHAR(4);
    DEFINE vsdoant            DECIMAL(18,2);
    DEFINE vtotdep            DECIMAL(18,2);
    DEFINE vtotret            DECIMAL(18,2);
    DEFINE vsdoact            DECIMAL(18,2);
    DEFINE vsdoprom            DECIMAL(18,2);
    DEFINE vdias             SMALLINT;
    DEFINE cMensajeProducto CHAR(255); 
    DEFINE vedosuc             CHAR(4);
    DEFINE vcdsuc             VARCHAR(60);  --
    DEFINE vtel             CHAR(14);
    --DEFINE vgerente         CHAR(40);
    DEFINE vdescrip         CHAR(180);
    DEFINE vmonto              MONEY(14,2);
    DEFINE vmontoRet          MONEY(14,2);
    DEFINE vmontodep          MONEY(14,2);
    DEFINE vsdoactual          MONEY(14,2);
    --DEFINE vcortSig           
    --DEFINE vfechealt
    DEFINE vcuantos          INTEGER;
    DEFINE vcuantos2          INTEGER; 
    DEFINE vconreg             smallint;
    DEFINE viva               MONEY(14,2);
    DEFINE vcomisiones          MONEY(14,2);
    DEFINE votrocargos        MONEY(14,2);
    DEFINE vretiefect       MONEY(14,2);
   
    LET vaniomes = "";                             
    LET vcodretDet = "";                       
    LET vcodretEnC = "";                         
    LET cErrorInfo="";                         
    LET vErrorInfo= "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                             
    LET vcortSig = "";                         
    LET vsecuencia = 0;
    LET vnlinea =0;                                
    LET vidreg = 0;                            
    LET vultejec = '';                  
    LET vsqlerr = 0;                           
    LET vdeposito = 0;
    LET vretiro = 0;                               
    LET vfechealt = "";                        
    LET vsdocuenta = 0;
    --LET vdescrip = "";                                                  
    LET vcuenta = "";                                  
    LET vcodret = "00000";
    LET vfecha_hoy = "";                           
    LET vfecha_ant = "";                                                                                         
    LET bInicia = "F";                         
    LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";             
    --LET vNum_cte = "";                         
    LET vNum_Tarjeta = "";
    --LET vNombre_cte = "";                          
    --LET vDireccion_cte = "";                   
    --LET vDireccion_col = "";
    LET vDireccion_del = "";                       
    LET vEdo_cd = "";                          
    LET vSucursal_nombre = "";                     
    --LET vSucursal_num  = "";                   
    LET vrfc = "";
    LET vrfc_alterno ="";
    LET vCP = "";                                  
    LET vClabe = "";
    LET vCurp = "";                                                        
    --LET vFechaInicio = "";                    
    --LET vSaldoAnterior = 0;
    --LET vDepositos = 0;                            
    LET vInteresesPagados = 0;                 
    --LET vRetiros = 0;
    LET vOtrosCargos = 0;                          
    LET vIvaOtrosCargos = 0;                   
    --LET vSaldoCorte = 0;
    --LET vSaldoPromedio = 0;                        
    LET vRetencionIsr = 0;   
    LET vTotRetirosEfec = 0;
    LET vTotOtrosCargos = 0;
    LET vInteresesNetos = 0;
    --LET viDias = 0;                                
    LET vTasaBruta = 0;    
    LET vGAT = 0;   
    LET vfechaFinal = "";                          
    LET vcSql = "";                            
    LET vcStmt = "";        
    LET vmin_cta = '';                             
    LET vmax_cta = '';
    LET dFechaInicioMovimientos = '01-01-1900';    
    LET dFechaFinMovimientos = '01-01-1900';   
    --LET dFechaEmision = '01-01-1900'; 
    LET vMensajeProducto = '';
    LET vPiePagina = "";
    --LET vruta_descarga = ''; 
    LET vsql = '';
    LET vfecha = '';
    LET vfechaproc = '';
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
    LET vestado             = "";
    LET vciudad             = "";
    LET vtel             = "";
    LET vgerente             = "";
    LET cNumProducto        = "";
    LET vmensaje             = '';
    LET vdescrip = "";    
    LET vmonto         = 0;
    LET vmontoRet     = 0;
    LET vmontodep     = 0;
    LET vsdoactual     = 0;
    LET vcdsuc        = "";
    LET vcuantos            = 0;
    LET vcuantos2            = 0;
    LET vnumctetf             = "";
    LET vnumcte             = "";
    LET viva                   = 0;
    LET vcomisiones            = 0;
    LET votrocargos            = 0;
    LET vretiefect            = 0;
    
     --SET DEBUG FILE TO "/informix/1170/german/sp_generaredoctaeje_factelect_transfer_fechaemision.out";
     --TRACE ON;

    BEGIN
   
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "./sp_generaredoctaeje_factelect_transfer_fechaemision.err";
            TRACE ON;
           
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
           
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
           
           
            RETURN vcodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pEmpresa IS NULL  THEN
        LET vcodret = '00001';
        RETURN vcodret;
    END IF;
   
    -- // Obtener la fecha de ayer y hoy
    SELECT pri_dia_mes - 1 units day, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
      -- // Armar la fecha de emision
        --LET dFechaEmision = vfecha_ant;
        --LET dFechaEmision = '06-30-2016';
   
     select count(*)
     into vconreg
     from bditransfer:tf_resumen_edocta
     where periodo_fin = dFechaEmision;
   
     
       if vconreg = 0 then
          let vcodret = "00969"; -- NO EXISTE INFORMACION TRANSFER DEL PERIODO SOLICITADO
          return vcodret;
      
       else
   
   

            FOREACH WITH HOLD
             
            SELECT tf.periodo_fin, tf.cuenta, /*tf.numcte,*/  TRIM(NVL(TRIM(tf.nombre), "")||' '||NVL(TRIM(tf.ape_paterno), "")||' '||NVL(TRIM(tf.ape_materno), "")),
            TRIM(NVL(TRIM(tf.calle), "")||' '||NVL(TRIM(tf.no_ext), "")||' '||NVL(TRIM(tf.no_int), "")), tf.colonia/*nombrezona de si_catzonas */, tf.municipio, tf.ent_federativa,
            /*tf.rfc,*/ tf.cod_postal, tf.clabe , tf.curp, tf.fecha_apert, /*<--FECHA DE ALTA DEL CTE*/ tf.periodo_ini, LPAD (TRIM(tf.sucursal),4,'0')/*tf.sucursal*/, tf.saldo_ini, tf.abonos_sum,
            tf.cargos_sum, tf.saldo_fin, tf.saldo_prom,  tf.diasperiodo,  (tf.sv_tici - tf.at_tisi) as iva,tf.monto_efectivo, tf.comisiones_sum,
            ( tf.cargos_sum - tf.monto_efectivo) as otrocargo
            into vfechafin, vcuenta, /*vnumcte, /*vtarjeta,*/ vnombre_completo,
            vdireccion, vzona, vciudad, vestado,
            /*vrfc,*/ vcp, vclabe, vcurp, valta_cte, vfechaini,  vsucursal, vsdoant, vtotdep,
            vtotret, vsdoact, vsdoprom, vdias, viva, vretiefect, vcomisiones, votrocargos
            from bditransfer:tf_resumen_edocta tf , bditransfer:tf_maecte mae
            where tf.periodo_fin =  dFechaEmision
            and tf.integridad = 'V'
            and tf.cuenta = mae.cuenta_tf
           
                    select rfc, numcte, numcte_tf            
                into vrfc, vnumcte, vnumctetf
                from bditransfer:tf_maecte
                where cuenta_tf = vcuenta;
                --and status_cta ='1';-- se agrega validacion de status cuenta
           
                    IF vnumcte IS NOT null THEN
                   
                    select rfc, rfc_alterno 
                    into  vrfc, vrfc_alterno
                    from bdinteg:si_cliente
                    where numcte = vnumcte;
                           
                            IF vrfc_alterno IS NOT null THEN
                               
                                LET vrfc = vrfc_alterno;
                           
                            END IF
                           
                    END IF
           
            BEGIN WORK;
            LET bInicia = "T";
           
            /*
            LET vsucursal = '5001';
           
            select nombre
            into vnomsuc
            from bdinteg:si_sucursales 
            where sucursal =vsucursal;
            */
           
            /*
            FOREACH
                EXECUTE PROCEDURE bdicobranza:sp_obtenerposicion (vnomsuc, ",")
                into vcuantos , vcuantos2
               
                exit FOREACH;
               
            end FOREACH
            */
                   
            --select substr ( nombre, 1, vcuantos - 1), estado,  ciudad, telefono1, gerente
           
            LET vsucursal = '5001';
           
            select nombre, estado,  ciudad, telefono1, gerente
            into   vnomsuc, vedosuc, vcdsuc , vtel, vgerente
            from bdinteg:si_sucursales
            where sucursal = vsucursal;
           
            select nombre
            into vcdsuc
            from bdinteg:si_ciudades
            where estado = vedosuc 
            and ciudad = vcdsuc;  
           
            select siglas
            into vedosuc
            from bdinteg:si_estados
            where estado = vedosuc;
           
           
           
            SELECT LIMIT 1
                       TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto
                  INTO vMensajeProducto
                  FROM bdicheq:sc_producto AS ap
                 WHERE ap.empresa = '001'
                   AND ap.producto = '8000';
             
              -- mensaje para sc_piepagina_edocta_factelect
              SELECT LIMIT 1 mensaje
              INTO vPiePagina
              FROM bdicheq:sc_mensajes_producto
             WHERE producto = '8000'
             and secuencia = '1';
             
             
             
                -- se obtiene el numero de tarjeta
           
                select tar.num_tarjeta
                into vNum_Tarjeta
                from bdicheq:sc_tarjeta tar
                where tar.cuenta = vcuenta
                  and tar.status_tar = 'A';
              -- *********** TERMINA PARTE DE TRANSFER ****** --
                     
               
                -- // Ejecutar el store para llenar el encabezado
                SELECT NVL(MAX(idreg), 0) + 1
                  INTO vidreg
                  FROM bdicheq:sc_encabezado_edocta_factelect;

             
                -- // Hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado_factelect fue satisfactorio
               
                IF ( vrfc IS NULL OR vnombre_completo IS NULL OR vfechaini IS NULL OR vfechafin IS NULL ) THEN
                    LET vcodret = '00001';
                    RETURN vcodret;
                END IF;
               
                  IF trim(vcodret) = '00000' THEN
        --        IF trim(vcodretEnc) = '000' THEN
               
                    INSERT INTO bdicheq:sc_encabezado_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta,
                     sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vnumctetf, nvl (vNum_Tarjeta,''), vnombre_completo, vdireccion, vzona,/*vDireccion_col,*/ vciudad, vestado, ' ',
                     vnomsuc, vrfc, vcp, ' ', vclabe, vcurp, valta_cte,  vfechaini, vMensajeProducto, '000000000000000', vfechafin, vsucursal, vcdsuc, vedosuc, vtel, vgerente);
                   
                    INSERT INTO bdicheq:sc_encabezado2_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                     otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsdoant, vtotdep, '0', vtotret,
                     vcomisiones, viva, vsdoact, vsdoprom, '0', '0', vdias, '0');

                    LET vsecuencia = 1;
                    LET vnlinea = 1;
                   
                    INSERT INTO bdicheq:sc_piepagina_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                   
                        FOREACH WITH HOLD -- PARA INSERTAR LAS TABLAS
                           
                           
                            select  nlinea, mensaje, secuencia
                            into  vnlinea, vmensaje, vsecuencia
                            from bdicheq:sc_mensajes_producto
                            where producto = '8000'
                            and secuencia in ('2','3','4','5','6','7','8')
                           
                           
                            IF vsecuencia = 2 THEN LET vsecuencia = 1;
                                ELIF vsecuencia = 3 THEN LET vsecuencia = 2;
                                ELIF vsecuencia = 4 THEN LET vsecuencia = 3;
                                ELIF vsecuencia = 5 THEN LET vsecuencia = 4;
                                ELIF vsecuencia = 6 THEN LET vsecuencia = 5;
                                ELIF vsecuencia = 7 THEN LET vsecuencia = 6;
                                ELIF vsecuencia = 8 THEN LET vsecuencia = 7;
                            END IF
                           
                                                                   
                            INSERT INTO bdicheq:sc_mensajes_edocta_factelect
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);

                       
                        END FOREACH --TERMINA FOREACH
                   
                    INSERT INTO bdicheq:sc_grafica_fe
                    (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsdoant, vsdoact, vretiefect, vtotdep, '0', vcomisiones, viva, votrocargos, '0');
               
                -- // Si el resultado NO fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuciÃ³n
                ELSE
               
                   ROLLBACK WORK;
                   
                    LET bInicia = "F";
                   
                    LET vcodret = '00003';
                             
                   
                    RETURN vcodret;
                   
                END IF;

                -- // Ejecutar store para el detalle
                LET vsecuencia = 0;
                LET vmontodep = 0;
                LET vmontoRet = 0;
                LET vsdoactual = vsdoact;

                FOREACH
                        SELECT TRIM(NVL(TRIM(det.desc_mov1), "")||' '||NVL(TRIM(det.desc_mov2), "")||' '||NVL(TRIM(det.desc_mov3), "")), det.monto, det.fecha_mov   
                        INTO  vdescrip,/* vdesc2, vdesc3,*/ vmonto, vfechealt
                        FROM bditransfer:tf_detalle_edocta  det
                        where det.cuenta = vcuenta
                        and det.periodo_fin = vfechafin
                        ORDER BY fecha_mov desc , orden_mov::integer desc
                   
                        IF vmonto < 0 THEN
                            LET vmontoRet = vmonto;
                            LET vmontodep = 0;
                            LET vmontoRet = vmontoRet * -1;
                        ELSE
                            LET vmontodep = vmonto;
                            LET vmontoRet = 0;
                        END IF
                       
                               
                        LET vsdoactual = vsdoactual - vmontodep + vmontoRet;
                             
           
                        LET vsecuencia = vsecuencia + 1;
                        LET vnlinea = 0;
                       
                        -- // Cortar los detalles en lineas
                        FOREACH
                            EXECUTE PROCEDURE bdicred:corta_linea(vdescrip, 40)
                            INTO vcortSig, vcortsig2

                            LET vnlinea = vnlinea + 1;

                            IF vnlinea > 1 THEN
                           
                            LET vfechealt = '01-01-1900';
                               
                            INSERT INTO bdicheq:sc_detalle_edocta_factelect
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, '0.00', '0.00', '0.00');                   
                       
                            ELSE
                       
                            INSERT INTO bdicheq:sc_detalle_edocta_factelect
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vmontoRet, vmontodep, vsdoactual);
                           
                            END IF;
                           
                        END FOREACH;
                   
                   
                END FOREACH;
               
                COMMIT WORK;
                LET bInicia = "F";       
            END FOREACH;
           
                RETURN vcodret;
        END IF;
   
    END;
   
END PROCEDURE;
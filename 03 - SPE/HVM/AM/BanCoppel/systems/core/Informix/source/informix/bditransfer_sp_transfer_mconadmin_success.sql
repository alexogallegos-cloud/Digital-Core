create procedure "informix".sp_transfer_mconadmin_success (
					pdfechaini   date,
					pdfechafin   date,
					pstransacc   char(5),
					psnaturaleza char(1)
					)
returning 	
				char (5) 	as codret, 
				char (150) 	as mensaje_respuesta,
				char  (5) 	as transacc_file,
				char  (20) 	as fecha_alt_file,
				char  (15) 	as folio_suc_file,
				money  		as monto_file, 
				char (1)    as conciliado,
				char(20)    as referencia_mps,   ----  NEW 
				char(20)	as cuenta_cargo_chq , 
				char(5)		as transacc_cargo_chq ,
				char(15)	as folio_suc_cargo_chq ,
				money    	as monto_cargo_chq,
				date		as fecha_alt_cargo,
				char(50)	as referencia_cargo,
				char(20)	as rccontable_cargo,  
				char(20)	as racontable_cargo,
				char(20)    as cuenta_abono_chq,
				char (5)	as transacc_abono_chq,
				char (15)	as folio_suc_abono_chq,
				date		as fecha_alt_abono, 
				money		as monto_abono_chq,
				char(50)	as referencia_abono,
				char(20)	as rccontable_abono,
				char(20)	as racontable_abono;
				
				

				
-- Definicion de retorno
define 	vscodret 				char(5);
define  vsmensaje_respuesta     char(150);

define	vstransacc_file			char  (5) ; 
define	vsfecha_alt_file		char  (20); 
define	vsfolio_suc_file		char  (15); 
define	vmmonto_file		 	money; 
define  vsconciliado            char (1);
define  vsid_mps_file           char (20); -- new
define	vscuenta_cargo_chq  	char(20); 
define	vstransacc_cargo_chq 	char(5); 
define	vsfolio_suc_cargo_chq 	char(15); 
define	vmmonto_cargo_chq		money; 
define	vdfecha_alt_cargo		date; 
define	vsreferencia_cargo		char(50); 
define	vsrccontable_cargo	  	char(20); 
define	vsracontable_cargo		char(20); 
define	vscuenta_abono_chq		char(20); 
define	vstransacc_abono_chq	char (5); 
define	vsfolio_suc_abono_chq	char (15); 
define	vdfecha_alt_abono		date; 
define	vmmonto_abono_chq		money; 
define	vsreferencia_abono		char(50); 
define	vsrccontable_abono		char(20); 
define	vsracontable_abono		char(20); 

define  visqlerr				integer;


			
begin
	on exception set visqlerr
		
		let vscodret = vsCodRet;
		
		return 	TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vstransacc_file, '')),			
				TRIM(NVL(vsfecha_alt_file, '')),		
				TRIM(NVL(vsfolio_suc_file, '')),			
				NVL(vmmonto_file,0),  
				TRIM(NVL(vsconciliado, '')),
				TRIM(NVL(vsid_mps_file,'')), --- NEW 
				TRIM(NVL(vscuenta_cargo_chq, '')),	  	
				TRIM(NVL(vstransacc_cargo_chq, '')),	 	
				TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
				NVL(vmmonto_cargo_chq, 0),			
				vdfecha_alt_cargo,		
				TRIM(NVL(vsreferencia_cargo, '')),			
				TRIM(NVL(vsrccontable_cargo, '')),		  	
				TRIM(NVL(vsracontable_cargo, '')),			
				TRIM(NVL(vscuenta_abono_chq, '')),			
				TRIM(NVL(vstransacc_abono_chq, '')),		
				TRIM(NVL(vsfolio_suc_abono_chq, '')),		
				vdfecha_alt_abono,			
				NVL(vmmonto_abono_chq, 0),			
				TRIM(NVL(vsreferencia_abono, '')),			
				TRIM(NVL(vsrccontable_abono, '')),			
				TRIM(NVL(vsracontable_abono, ''));
				
	end exception;
	
--set debug file to "/informix/HomeInformix/rrm/sp_transfer_mconadmin_success.out";
--trace on;

-- Inicializacion de retorno
Let vscodret = '00000';
let vsmensaje_respuesta = '';
let	vstransacc_file		= '';
let	vsfecha_alt_file	= '';
let	vsfolio_suc_file	= '';
let	vmmonto_file		= 0;
let vsconciliado        = '';
let vsid_mps_file       = ''; -- NEW 
let	vscuenta_cargo_chq  = ' ';
let	vstransacc_cargo_chq = ' ';
let	vsfolio_suc_cargo_chq 	= ' ';
let	vmmonto_cargo_chq	= 0;
let	vdfecha_alt_cargo	= '01/01/1900';
let	vsreferencia_cargo	= ' ';
let	vsrccontable_cargo	= ' ';
let	vsracontable_cargo	= ' ';
let	vscuenta_abono_chq	= ' ';
let	vstransacc_abono_chq = ' ';
let	vsfolio_suc_abono_chq	= ' ';
let	vdfecha_alt_abono	= '01/01/1900';
let	vmmonto_abono_chq	= ' ';
let	vsreferencia_abono	= ' ';
let	vsrccontable_abono	= ' ';
let	vsracontable_abono	= ' ';

if  pdfechaini > pdfechafin  then
		Let vscodret = '00001';
		let vsmensaje_respuesta = 'Fecha Inicial no puede ser mayor a la Final';
		return
			TRIM(NVL(vscodret, '')), 
			TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
			TRIM(NVL(vstransacc_file, '')),			
			TRIM(NVL(vsfecha_alt_file, '')),		
			TRIM(NVL(vsfolio_suc_file, '')),			
			NVL(vmmonto_file,0),
			TRIM(NVL(vsconciliado, '')),
            TRIM(NVL(vsid_mps_file,'')), --- NEW 			
			TRIM(NVL(vscuenta_cargo_chq, '')),	  	
			TRIM(NVL(vstransacc_cargo_chq, '')),	 	
			TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
			NVL(vmmonto_cargo_chq, 0),			
			vdfecha_alt_cargo,		
			TRIM(NVL(vsreferencia_cargo, '')),			
			TRIM(NVL(vsrccontable_cargo, '')),		  	
			TRIM(NVL(vsracontable_cargo, '')),			
			TRIM(NVL(vscuenta_abono_chq, '')),			
			TRIM(NVL(vstransacc_abono_chq, '')),		
			TRIM(NVL(vsfolio_suc_abono_chq, '')),		
			vdfecha_alt_abono,			
			NVL(vmmonto_abono_chq, 0),			
			TRIM(NVL(vsreferencia_abono, '')),			
			TRIM(NVL(vsrccontable_abono, '')),			
			TRIM(NVL(vsracontable_abono, ''));
end if;

if ((pstransacc = '' or pstransacc is null) and
	(psnaturaleza = '' or psnaturaleza is null ) ) then
		
		foreach cusor1 with hold for --- here 
		
			select 	transacc_file, fecha_alt_file ||' '||substr(fech_hor_file, 12,8), folio_suc_file , monto_file , conciliado , id_mps_file /*NEW*/, cuenta_cargo_chq , transacc_cargo_chq , folio_suc_cargo_chq , monto_cargo_chq , fecha_alt_cargo, 
					referencia_cargo, rccontable_cargo, racontable_cargo, cuenta_abono_chq , transacc_abono_chq , folio_suc_abono_chq , fecha_alt_abono, monto_abono_chq , referencia_abono, rccontable_abono, racontable_abono  
				into
					vstransacc_file, vsfecha_alt_file, vsfolio_suc_file, vmmonto_file, vsconciliado,vsid_mps_file/*NEW*/,vscuenta_cargo_chq, vstransacc_cargo_chq, vsfolio_suc_cargo_chq, vmmonto_cargo_chq, vdfecha_alt_cargo, 
					vsreferencia_cargo,	vsrccontable_cargo, vsracontable_cargo, vscuenta_abono_chq, vstransacc_abono_chq, vsfolio_suc_abono_chq, vdfecha_alt_abono,	vmmonto_abono_chq, vsreferencia_abono,	vsrccontable_abono, vsracontable_abono
				from Bditransfer:tf_conciliacionadmiva_transfer
					where 	fecha_alt_file between pdfechaini and pdfechafin 
							
					
			
				RETURN 
						TRIM(NVL(vscodret, '')), 
						TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
						TRIM(NVL(vstransacc_file, '')),			
						TRIM(NVL(vsfecha_alt_file, '')),		
						TRIM(NVL(vsfolio_suc_file, '')),			
						NVL(vmmonto_file,0),
						TRIM(NVL(vsconciliado, '')),
						TRIM(NVL(vsid_mps_file,'')), --- NEW 
						TRIM(NVL(vscuenta_cargo_chq, '')),	  	
						TRIM(NVL(vstransacc_cargo_chq, '')),	 	
						TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
						NVL(vmmonto_cargo_chq, 0),			
						vdfecha_alt_cargo,		
						TRIM(NVL(vsreferencia_cargo, '')),			
						TRIM(NVL(vsrccontable_cargo, '')),		  	
						TRIM(NVL(vsracontable_cargo, '')),			
						TRIM(NVL(vscuenta_abono_chq, '')),			
						TRIM(NVL(vstransacc_abono_chq, '')),		
						TRIM(NVL(vsfolio_suc_abono_chq, '')),		
						vdfecha_alt_abono,			
						NVL(vmmonto_abono_chq, 0),			
						TRIM(NVL(vsreferencia_abono, '')),			
						TRIM(NVL(vsrccontable_abono, '')),			
						TRIM(NVL(vsracontable_abono, ''))	
					WITH RESUME;

			
			
		end foreach;

	
end if;


set isolation to dirty read;

if  psnaturaleza = 'C' then  -- Para recuperar cargos

		foreach cusor1 with hold for
		
			select 	transacc_file, fecha_alt_file ||' '||substr(fech_hor_file, 12,8), folio_suc_file , monto_file , conciliado,id_mps_file /*NEW*/, cuenta_cargo_chq , transacc_cargo_chq , folio_suc_cargo_chq , monto_cargo_chq , fecha_alt_cargo, 
					referencia_cargo, rccontable_cargo, racontable_cargo, cuenta_abono_chq , transacc_abono_chq , folio_suc_abono_chq , fecha_alt_abono, monto_abono_chq , referencia_abono, rccontable_abono, racontable_abono  
				into
					vstransacc_file, vsfecha_alt_file, vsfolio_suc_file, vmmonto_file, vsconciliado,vsid_mps_file /*NEW*/, vscuenta_cargo_chq, vstransacc_cargo_chq, vsfolio_suc_cargo_chq, vmmonto_cargo_chq, vdfecha_alt_cargo, 
					vsreferencia_cargo,	vsrccontable_cargo, vsracontable_cargo, vscuenta_abono_chq, vstransacc_abono_chq, vsfolio_suc_abono_chq, vdfecha_alt_abono,	vmmonto_abono_chq, vsreferencia_abono,	vsrccontable_abono, vsracontable_abono
				from Bditransfer:tf_conciliacionadmiva_transfer
					where 	fecha_alt_file between pdfechaini and pdfechafin 
							and transacc_cargo_chq = trim(pstransacc)
					
			
				RETURN 
						TRIM(NVL(vscodret, '')), 
						TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
						TRIM(NVL(vstransacc_file, '')),			
						TRIM(NVL(vsfecha_alt_file, '')),		
						TRIM(NVL(vsfolio_suc_file, '')),			
						NVL(vmmonto_file,0),
						TRIM(NVL(vsconciliado, '')),
						TRIM(NVL(vsid_mps_file,'')),  --- NEW 
						TRIM(NVL(vscuenta_cargo_chq, '')),	  	
						TRIM(NVL(vstransacc_cargo_chq, '')),	 	
						TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
						NVL(vmmonto_cargo_chq, 0),			
						vdfecha_alt_cargo,		
						TRIM(NVL(vsreferencia_cargo, '')),			
						TRIM(NVL(vsrccontable_cargo, '')),		  	
						TRIM(NVL(vsracontable_cargo, '')),			
						TRIM(NVL(vscuenta_abono_chq, '')),			
						TRIM(NVL(vstransacc_abono_chq, '')),		
						TRIM(NVL(vsfolio_suc_abono_chq, '')),		
						vdfecha_alt_abono,			
						NVL(vmmonto_abono_chq, 0),			
						TRIM(NVL(vsreferencia_abono, '')),			
						TRIM(NVL(vsrccontable_abono, '')),			
						TRIM(NVL(vsracontable_abono, ''))	
					WITH RESUME;

			
			
		end foreach;

elif psnaturaleza = 'A'  then  -- Para transacciones de Abono

		foreach cusor1 with hold for
		
		select 	transacc_file, fecha_alt_file ||' '||substr(fech_hor_file, 12,8), folio_suc_file , monto_file , conciliado, id_mps_file /*new*/,cuenta_cargo_chq , transacc_cargo_chq , folio_suc_cargo_chq , monto_cargo_chq , fecha_alt_cargo, 
					referencia_cargo, rccontable_cargo, racontable_cargo, cuenta_abono_chq , transacc_abono_chq , folio_suc_abono_chq , fecha_alt_abono, monto_abono_chq , referencia_abono, rccontable_abono, racontable_abono  
				into
					vstransacc_file, vsfecha_alt_file, vsfolio_suc_file, vmmonto_file, vsconciliado,vsid_mps_file /*new*/, vscuenta_cargo_chq, vstransacc_cargo_chq, vsfolio_suc_cargo_chq, vmmonto_cargo_chq, vdfecha_alt_cargo, 
					vsreferencia_cargo,	vsrccontable_cargo, vsracontable_cargo, vscuenta_abono_chq, vstransacc_abono_chq, vsfolio_suc_abono_chq, vdfecha_alt_abono,	vmmonto_abono_chq, vsreferencia_abono,	vsrccontable_abono, vsracontable_abono
				from Bditransfer:tf_conciliacionadmiva_transfer
					where 	fecha_alt_file between pdfechaini and pdfechafin
							and transacc_abono_chq = trim(pstransacc)
							
				RETURN 
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vstransacc_file, '')),			
					TRIM(NVL(vsfecha_alt_file, '')),		
					TRIM(NVL(vsfolio_suc_file, '')),			
					NVL(vmmonto_file,0),
					TRIM(NVL(vsconciliado, '')),
					TRIM(NVL(vsid_mps_file,'')), --- NEW 
					TRIM(NVL(vscuenta_cargo_chq, '')),	  	
					TRIM(NVL(vstransacc_cargo_chq, '')),	 	
					TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
					NVL(vmmonto_cargo_chq, 0),			
					vdfecha_alt_cargo,		
					TRIM(NVL(vsreferencia_cargo, '')),			
					TRIM(NVL(vsrccontable_cargo, '')),		  	
					TRIM(NVL(vsracontable_cargo, '')),			
					TRIM(NVL(vscuenta_abono_chq, '')),			
					TRIM(NVL(vstransacc_abono_chq, '')),		
					TRIM(NVL(vsfolio_suc_abono_chq, '')),		
					vdfecha_alt_abono,			
					NVL(vmmonto_abono_chq, 0),			
					TRIM(NVL(vsreferencia_abono, '')),			
					TRIM(NVL(vsrccontable_abono, '')),			
					TRIM(NVL(vsracontable_abono, ''))
				WITH RESUME;
			
		end foreach;
end if;


end
end procedure
DOCUMENT
'AUTOR: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: RQM 06 481 - Reportes ConciliaciÃ³n Transfer',
'Solicito: Operaciones TRANSFER',
'Descripcion: Recuperar el operaciones de las transacciones que soliciten para llenado de GRID',
'Fecha: 2016/07/07',
'Version: 20160707.1100',
'BD: Bditransfer',
'AUTOR: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06 557 NÃM DE REF REPORTE DE CONCILIACIÃN TRANSFER',
'Solicito: Operaciones TRANSFER',
'Descripcion: Recuperar el campo id_mps_file(num ref) de las transacciones para llenado de GRID',
'Fecha: 2017/01/23',
'Version: 20170123.1200',
'BD: Bditransfer';

create procedure "informix".sp_transfer_mconadmin_success2 (
					pdfechaini   date,
					pdfechafin   date,
					pstransacc   char(5),
					psnaturaleza char(1),
					pRegistros integer, 
					pRecuperacion integer
					)
returning 	
				char (5) 	as codret, 
				char (150) 	as mensaje_respuesta,
				char  (5) 	as transacc_file,
				char  (20) 	as fecha_alt_file,
				char  (15) 	as folio_suc_file,
				money  		as monto_file, 
				char (1)    as conciliado,
				char(20)    as referencia_mps,   ----  NEW 
				char(20)	as cuenta_cargo_chq , 
				char(5)		as transacc_cargo_chq ,
				char(15)	as folio_suc_cargo_chq ,
				money    	as monto_cargo_chq,
				date		as fecha_alt_cargo,
				char(50)	as referencia_cargo,
				char(20)	as rccontable_cargo,  
				char(20)	as racontable_cargo,
				char(20)    as cuenta_abono_chq,
				char (5)	as transacc_abono_chq,
				char (15)	as folio_suc_abono_chq,
				date		as fecha_alt_abono, 
				money		as monto_abono_chq,
				char(50)	as referencia_abono,
				char(20)	as rccontable_abono,
				char(20)	as racontable_abono;
				
				

				
-- Definicion de retorno
define 	vscodret 				char(5);
define  vsmensaje_respuesta     char(150);

define	vstransacc_file			char  (5) ; 
define	vsfecha_alt_file		char  (20); 
define	vsfolio_suc_file		char  (15); 
define	vmmonto_file		 	money; 
define  vsconciliado            char (1);
define  vsid_mps_file           char (20); -- new
define	vscuenta_cargo_chq  	char(20); 
define	vstransacc_cargo_chq 	char(5); 
define	vsfolio_suc_cargo_chq 	char(15); 
define	vmmonto_cargo_chq		money; 
define	vdfecha_alt_cargo		date; 
define	vsreferencia_cargo		char(50); 
define	vsrccontable_cargo	  	char(20); 
define	vsracontable_cargo		char(20); 
define	vscuenta_abono_chq		char(20); 
define	vstransacc_abono_chq	char (5); 
define	vsfolio_suc_abono_chq	char (15); 
define	vdfecha_alt_abono		date; 
define	vmmonto_abono_chq		money; 
define	vsreferencia_abono		char(50); 
define	vsrccontable_abono		char(20); 
define	vsracontable_abono		char(20); 

define  visqlerr				integer;


			
begin
	on exception set visqlerr
		
		let vscodret = vsCodRet;
		
		return 	TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vstransacc_file, '')),			
				TRIM(NVL(vsfecha_alt_file, '')),		
				TRIM(NVL(vsfolio_suc_file, '')),			
				NVL(vmmonto_file,0),  
				TRIM(NVL(vsconciliado, '')),
				TRIM(NVL(vsid_mps_file,'')), --- NEW 
				TRIM(NVL(vscuenta_cargo_chq, '')),	  	
				TRIM(NVL(vstransacc_cargo_chq, '')),	 	
				TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
				NVL(vmmonto_cargo_chq, 0),			
				vdfecha_alt_cargo,		
				TRIM(NVL(vsreferencia_cargo, '')),			
				TRIM(NVL(vsrccontable_cargo, '')),		  	
				TRIM(NVL(vsracontable_cargo, '')),			
				TRIM(NVL(vscuenta_abono_chq, '')),			
				TRIM(NVL(vstransacc_abono_chq, '')),		
				TRIM(NVL(vsfolio_suc_abono_chq, '')),		
				vdfecha_alt_abono,			
				NVL(vmmonto_abono_chq, 0),			
				TRIM(NVL(vsreferencia_abono, '')),			
				TRIM(NVL(vsrccontable_abono, '')),			
				TRIM(NVL(vsracontable_abono, ''));
				
	end exception;
	
--set debug file to "/informix/HomeInformix/rrm/sp_transfer_mconadmin_success2.out";
--trace on;

-- Inicializacion de retorno
Let vscodret = '00000';
let vsmensaje_respuesta = '';
let	vstransacc_file		= '';
let	vsfecha_alt_file	= '';
let	vsfolio_suc_file	= '';
let	vmmonto_file		= 0;
let vsconciliado        = '';
let vsid_mps_file       = ''; -- NEW 
let	vscuenta_cargo_chq  = ' ';
let	vstransacc_cargo_chq = ' ';
let	vsfolio_suc_cargo_chq 	= ' ';
let	vmmonto_cargo_chq	= 0;
let	vdfecha_alt_cargo	= '01/01/1900';
let	vsreferencia_cargo	= ' ';
let	vsrccontable_cargo	= ' ';
let	vsracontable_cargo	= ' ';
let	vscuenta_abono_chq	= ' ';
let	vstransacc_abono_chq = ' ';
let	vsfolio_suc_abono_chq	= ' ';
let	vdfecha_alt_abono	= '01/01/1900';
let	vmmonto_abono_chq	= ' ';
let	vsreferencia_abono	= ' ';
let	vsrccontable_abono	= ' ';
let	vsracontable_abono	= ' ';

if  pdfechaini > pdfechafin  then
		Let vscodret = '00001';
		let vsmensaje_respuesta = 'Fecha Inicial no puede ser mayor a la Final';
		return
			TRIM(NVL(vscodret, '')), 
			TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
			TRIM(NVL(vstransacc_file, '')),			
			TRIM(NVL(vsfecha_alt_file, '')),		
			TRIM(NVL(vsfolio_suc_file, '')),			
			NVL(vmmonto_file,0),
			TRIM(NVL(vsconciliado, '')),
            TRIM(NVL(vsid_mps_file,'')), --- NEW 			
			TRIM(NVL(vscuenta_cargo_chq, '')),	  	
			TRIM(NVL(vstransacc_cargo_chq, '')),	 	
			TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
			NVL(vmmonto_cargo_chq, 0),			
			vdfecha_alt_cargo,		
			TRIM(NVL(vsreferencia_cargo, '')),			
			TRIM(NVL(vsrccontable_cargo, '')),		  	
			TRIM(NVL(vsracontable_cargo, '')),			
			TRIM(NVL(vscuenta_abono_chq, '')),			
			TRIM(NVL(vstransacc_abono_chq, '')),		
			TRIM(NVL(vsfolio_suc_abono_chq, '')),		
			vdfecha_alt_abono,			
			NVL(vmmonto_abono_chq, 0),			
			TRIM(NVL(vsreferencia_abono, '')),			
			TRIM(NVL(vsrccontable_abono, '')),			
			TRIM(NVL(vsracontable_abono, ''));
end if;

if ((pstransacc = '' or pstransacc is null) and
	(psnaturaleza = '' or psnaturaleza is null ) ) then
		
		foreach cusor1 with hold for --- here 
		
			select SKIP pRegistros FIRST pRecuperacion transacc_file, fecha_alt_file ||' '||substr(fech_hor_file, 12,8), folio_suc_file , monto_file , conciliado , id_mps_file /*NEW*/, cuenta_cargo_chq , transacc_cargo_chq , folio_suc_cargo_chq , monto_cargo_chq , fecha_alt_cargo, 
					referencia_cargo, rccontable_cargo, racontable_cargo, cuenta_abono_chq , transacc_abono_chq , folio_suc_abono_chq , fecha_alt_abono, monto_abono_chq , referencia_abono, rccontable_abono, racontable_abono  
				into
					vstransacc_file, vsfecha_alt_file, vsfolio_suc_file, vmmonto_file, vsconciliado,vsid_mps_file/*NEW*/,vscuenta_cargo_chq, vstransacc_cargo_chq, vsfolio_suc_cargo_chq, vmmonto_cargo_chq, vdfecha_alt_cargo, 
					vsreferencia_cargo,	vsrccontable_cargo, vsracontable_cargo, vscuenta_abono_chq, vstransacc_abono_chq, vsfolio_suc_abono_chq, vdfecha_alt_abono,	vmmonto_abono_chq, vsreferencia_abono,	vsrccontable_abono, vsracontable_abono
				from Bditransfer:tf_conciliacionadmiva_transfer
					where 	fecha_alt_file between pdfechaini and pdfechafin 
							
					
			
				RETURN 
						TRIM(NVL(vscodret, '')), 
						TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
						TRIM(NVL(vstransacc_file, '')),			
						TRIM(NVL(vsfecha_alt_file, '')),		
						TRIM(NVL(vsfolio_suc_file, '')),			
						NVL(vmmonto_file,0),
						TRIM(NVL(vsconciliado, '')),
						TRIM(NVL(vsid_mps_file,'')), --- NEW 
						TRIM(NVL(vscuenta_cargo_chq, '')),	  	
						TRIM(NVL(vstransacc_cargo_chq, '')),	 	
						TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
						NVL(vmmonto_cargo_chq, 0),			
						vdfecha_alt_cargo,		
						TRIM(NVL(vsreferencia_cargo, '')),			
						TRIM(NVL(vsrccontable_cargo, '')),		  	
						TRIM(NVL(vsracontable_cargo, '')),			
						TRIM(NVL(vscuenta_abono_chq, '')),			
						TRIM(NVL(vstransacc_abono_chq, '')),		
						TRIM(NVL(vsfolio_suc_abono_chq, '')),		
						vdfecha_alt_abono,			
						NVL(vmmonto_abono_chq, 0),			
						TRIM(NVL(vsreferencia_abono, '')),			
						TRIM(NVL(vsrccontable_abono, '')),			
						TRIM(NVL(vsracontable_abono, ''))	
					WITH RESUME;

			
			
		end foreach;

	
end if;


set isolation to dirty read;

if  psnaturaleza = 'C' then  -- Para recuperar cargos

		foreach cusor1 with hold for
		
			select SKIP pRegistros FIRST pRecuperacion transacc_file, fecha_alt_file ||' '||substr(fech_hor_file, 12,8), folio_suc_file , monto_file , conciliado,id_mps_file /*NEW*/, cuenta_cargo_chq , transacc_cargo_chq , folio_suc_cargo_chq , monto_cargo_chq , fecha_alt_cargo, 
					referencia_cargo, rccontable_cargo, racontable_cargo, cuenta_abono_chq , transacc_abono_chq , folio_suc_abono_chq , fecha_alt_abono, monto_abono_chq , referencia_abono, rccontable_abono, racontable_abono  
				into
					vstransacc_file, vsfecha_alt_file, vsfolio_suc_file, vmmonto_file, vsconciliado,vsid_mps_file /*NEW*/, vscuenta_cargo_chq, vstransacc_cargo_chq, vsfolio_suc_cargo_chq, vmmonto_cargo_chq, vdfecha_alt_cargo, 
					vsreferencia_cargo,	vsrccontable_cargo, vsracontable_cargo, vscuenta_abono_chq, vstransacc_abono_chq, vsfolio_suc_abono_chq, vdfecha_alt_abono,	vmmonto_abono_chq, vsreferencia_abono,	vsrccontable_abono, vsracontable_abono
				from Bditransfer:tf_conciliacionadmiva_transfer
					where 	fecha_alt_file between pdfechaini and pdfechafin 
							and transacc_cargo_chq = trim(pstransacc)
					
			
				RETURN 
						TRIM(NVL(vscodret, '')), 
						TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
						TRIM(NVL(vstransacc_file, '')),			
						TRIM(NVL(vsfecha_alt_file, '')),		
						TRIM(NVL(vsfolio_suc_file, '')),			
						NVL(vmmonto_file,0),
						TRIM(NVL(vsconciliado, '')),
						TRIM(NVL(vsid_mps_file,'')),  --- NEW 
						TRIM(NVL(vscuenta_cargo_chq, '')),	  	
						TRIM(NVL(vstransacc_cargo_chq, '')),	 	
						TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
						NVL(vmmonto_cargo_chq, 0),			
						vdfecha_alt_cargo,		
						TRIM(NVL(vsreferencia_cargo, '')),			
						TRIM(NVL(vsrccontable_cargo, '')),		  	
						TRIM(NVL(vsracontable_cargo, '')),			
						TRIM(NVL(vscuenta_abono_chq, '')),			
						TRIM(NVL(vstransacc_abono_chq, '')),		
						TRIM(NVL(vsfolio_suc_abono_chq, '')),		
						vdfecha_alt_abono,			
						NVL(vmmonto_abono_chq, 0),			
						TRIM(NVL(vsreferencia_abono, '')),			
						TRIM(NVL(vsrccontable_abono, '')),			
						TRIM(NVL(vsracontable_abono, ''))	
					WITH RESUME;

			
			
		end foreach;

elif psnaturaleza = 'A'  then  -- Para transacciones de Abono

		foreach cusor1 with hold for
		
		select SKIP pRegistros FIRST pRecuperacion transacc_file, fecha_alt_file ||' '||substr(fech_hor_file, 12,8), folio_suc_file , monto_file , conciliado, id_mps_file /*new*/,cuenta_cargo_chq , transacc_cargo_chq , folio_suc_cargo_chq , monto_cargo_chq , fecha_alt_cargo, 
					referencia_cargo, rccontable_cargo, racontable_cargo, cuenta_abono_chq , transacc_abono_chq , folio_suc_abono_chq , fecha_alt_abono, monto_abono_chq , referencia_abono, rccontable_abono, racontable_abono  
				into
					vstransacc_file, vsfecha_alt_file, vsfolio_suc_file, vmmonto_file, vsconciliado,vsid_mps_file /*new*/, vscuenta_cargo_chq, vstransacc_cargo_chq, vsfolio_suc_cargo_chq, vmmonto_cargo_chq, vdfecha_alt_cargo, 
					vsreferencia_cargo,	vsrccontable_cargo, vsracontable_cargo, vscuenta_abono_chq, vstransacc_abono_chq, vsfolio_suc_abono_chq, vdfecha_alt_abono,	vmmonto_abono_chq, vsreferencia_abono,	vsrccontable_abono, vsracontable_abono
				from Bditransfer:tf_conciliacionadmiva_transfer
					where 	fecha_alt_file between pdfechaini and pdfechafin
							and transacc_abono_chq = trim(pstransacc)
							
				RETURN 
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vstransacc_file, '')),			
					TRIM(NVL(vsfecha_alt_file, '')),		
					TRIM(NVL(vsfolio_suc_file, '')),			
					NVL(vmmonto_file,0),
					TRIM(NVL(vsconciliado, '')),
					TRIM(NVL(vsid_mps_file,'')), --- NEW 
					TRIM(NVL(vscuenta_cargo_chq, '')),	  	
					TRIM(NVL(vstransacc_cargo_chq, '')),	 	
					TRIM(NVL(vsfolio_suc_cargo_chq, '')),	 	
					NVL(vmmonto_cargo_chq, 0),			
					vdfecha_alt_cargo,		
					TRIM(NVL(vsreferencia_cargo, '')),			
					TRIM(NVL(vsrccontable_cargo, '')),		  	
					TRIM(NVL(vsracontable_cargo, '')),			
					TRIM(NVL(vscuenta_abono_chq, '')),			
					TRIM(NVL(vstransacc_abono_chq, '')),		
					TRIM(NVL(vsfolio_suc_abono_chq, '')),		
					vdfecha_alt_abono,			
					NVL(vmmonto_abono_chq, 0),			
					TRIM(NVL(vsreferencia_abono, '')),			
					TRIM(NVL(vsrccontable_abono, '')),			
					TRIM(NVL(vsracontable_abono, ''))
				WITH RESUME;
			
		end foreach;
end if;


end
end procedure
DOCUMENT
'AUTOR: L.I.A. Ricardo ResÃ©ndiz MartÃ­nez',
'Proyecto: RQM 06 481 - Reportes ConciliaciÃ³n Transfer',
'Solicito: Operaciones TRANSFER',
'Descripcion: Recuperar el operaciones de las transacciones que soliciten para llenado de GRID',
'Fecha: 2016/07/07',
'Version: 20160707.1100',
'BD: Bditransfer',
'AUTOR: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06 557 NÃM DE REF REPORTE DE CONCILIACIÃN TRANSFER',
'Solicito: Operaciones TRANSFER',
'Descripcion: Recuperar el campo id_mps_file(num ref) de las transacciones para llenado de GRID',
'Fecha: 2017/01/23',
'Version: 20170123.1200',
'BD: Bditransfer',
'AUTOR: L. Montserrat LeÃ³n Amador',
'DESCRIPCION: Se realiza la clonaciÃ³n del spl para agregar el tratado de paginaciÃ³n.',
'FECHA: 22/06/2017',
'BD: Bditransfer';

CREATE PROCEDURE "informix".sp_actualizanumctetitular_web(pEmpresa CHAR(3), pRFC CHAR(13), pNumCte CHAR(20))
--DATOS A REGRESAR--
RETURNING 	CHAR(6) AS CodigoRetorno,
			CHAR(1) AS BanCteTransfer;

--DEFINICION DE VARIABLES--
DEFINE cCodRet CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cNumCtetf CHAR(20);
DEFINE cBanCtetf CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet = '00000';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cNumCtetf = '';
LET cBanCtetf = '0';

--SET DEBUG FILE TO "/informix/IrisA/sp_actualizanumctetitular.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanCtetf;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa, '') <> '' AND NVL(pRFC, '') <> '' AND NVL(pNumCte, '') <> '' THEN

		SELECT numcte_tf 
		INTO cNumCtetf
		FROM "informix".tf_maecte 
		WHERE empresa = pEmpresa AND rfc = pRFC;

		IF NVL(cNumCtetf, '') <> '' THEN

			LET cBanCtetf = '1';

			UPDATE "informix".tf_maecte 
			SET numcte = pNumCte
			WHERE empresa = pEmpresa AND numcte_tf = cNumCtetf;

		END IF;

	END IF;

	RETURN cCodRet, cBanCtetf;

END;
END PROCEDURE;
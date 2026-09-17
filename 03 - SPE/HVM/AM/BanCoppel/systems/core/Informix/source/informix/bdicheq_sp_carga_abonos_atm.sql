CREATE PROCEDURE "informix".sp_carga_abonos_atm()
RETURNING 	char (5) AS COD_RET,
			char(150) AS MENSAJE;
			  
---variables de control de errores
 
DEFINE	iSqlErr 		INTEGER;
DEFINE	iIsamErr		INTEGER;
DEFINE	vErrorInfo		VARCHAR(80);
DEFINE  CVarDataErr      CHAR(150);
DEFINE  CCodret          CHAR(5);
DEFINE  CMENSAJE		 CHAR(150);

DEFINE	vpaso			INTEGER;	   

DEFINE psucursal	char(4);
DEFINE vano	varchar (4);
DEFINE vmes	varchar (2);
DEFINE vdia varchar (2);
DEFINE pusuario		char(8);
DEFINE pserial		integer;
DEFINE ptransacc	char(4);
DEFINE pfolio_suc	char(16);
DEFINE pcuenta		char(20);     
DEFINE pmto_tot		decimal(16,2);
DEFINE preferencia	char(30);
DEFINE pnum_tarjeta	char(16);
DEFINE vcodret		char(5);
DEFINE vcodret2		char(5);
DEFINE vsqlerr		integer;
DEFINE visamerr		integer;
DEFINE v_hora		CHAR(15);
DEFINE v_fecha		date;
DEFINE v_hora2		char(8);
DEFINE vexiste		smallint;
DEFINE vfecha_hoy	DATE;
DEFINE vamd varchar (8);
DEFINE vsruta_procesos		varchar (50);
DEFINE vsnomarchivodebito	varchar (30);
DEFINE vsnomarchivocredito	varchar (30);

DEFINE vsql 			CHAR (2500);
LET vcodret = "000";
LET v_hora = current hour to second;


BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				LET CCodret = iSqlErr;
				LET CMENSAJE = vErrorInfo;			
				RETURN cCodret, 'iIsamErr: '|| iIsamErr  || ' EN PASO: ' || vpaso|| ' ERR_DES ' || CMENSAJE ;
			END IF;
		END EXCEPTION;

--Set debug file to "/respaldos/sp_aplica_abonos_atm.out";
--trace on;

	---INICIALIZANDO VARIABLES
	
	LET vfecha_hoy ='';
	LET vano ='';
	LET vmes ='';
	LET vdia ='';
	LET vsruta_procesos='/respaldos';
    LET vsnomarchivodebito='repaclaracionesdebito_';
	LET vsnomarchivocredito='repaclaracionescredito_';

	/*----------CALCULA LA FECHA DEL REPORTE----------------*/
    let vpaso= 12;	

	SET ISOLATION TO DIRTY READ;  --1
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy INTO vfecha_hoy FROM  bdinteg:"informix".si_fechas; 
	
    let vpaso= 2;
	let vano = YEAR(vfecha_hoy);
	let vmes = LPAD(MONTH(vfecha_hoy), 2,"0");
	let vdia = LPAD(DAY (vfecha_hoy),2,"0");
	let vamd = vano||vmes||vdia;

	let vpaso= 21;
	
	-- Asignando permisos al archivo repaclaracionesdebito_AAAAMMDD.txt
	
	let vsql = '';
	let vsql = 'chmod 777 '|| TRIM(vsruta_procesos) || '/' || TRIM(vsnomarchivodebito)||TRIM(vamd)||'.txt';
	system vsql;

	let vpaso= 22;
		
/*	---Asignando permisos al archivo repaclaracionescredito_AAAAMMDD.txt
	let vsql = '';
	let vsql = 'chmod 777 '|| TRIM(vsruta_procesos) || '/' || TRIM(vsnomarchivocredito)||TRIM(vamd)||'.txt';
	system vsql; */
	
	let vpaso= 23;
			
--- Se crea copia del archivo repaclaracionesdebito_AAAAMMDD.txt con columna 1 en ceros para carga  

	let vsql = '';
	let vsql = 'sed '||"'s/6210|/0|/g'"||' '||TRIM(vsruta_procesos)||'/'||TRIM(vsnomarchivodebito)||TRIM(vamd)||'.txt'||' > '|| TRIM(vsruta_procesos) || '/' || TRIM(vsnomarchivodebito)||TRIM(vamd)||'carga.txt';
	system vsql;

	let vpaso= 24;

/*-- Se crea copia del archivo repaclaracionescredito_AAAAMMDD.txt con columna 1 en ceros para carga  

	let vsql = '';
	let vsql = 'sed '||"'s/6210|/0|/g'"||' '||TRIM(vsruta_procesos)||'/'||TRIM(vsnomarchivocredito)||TRIM(vamd)||'.txt'||' > '|| TRIM(vsruta_procesos) || '/' || TRIM(vsnomarchivocredito)||TRIM(vamd)||'carga.txt';
	system vsql; */

let vpaso= 25;			

-- Se crea el comando para cargar la copia del archivo repaclaracionesdebito_AAAAMMDD.txt a la tabla sc_abonos_atm	

	let vsql = '';
	let vsql = 'echo "LOAD FROM '|| TRIM(vsruta_procesos) || '/' || TRIM(vsnomarchivodebito)||TRIM(vamd)||'carga.txt'|| " " || " DELIMITER " || "'|'"||' INSERT INTO bdicheq:sc_abonos_atm" > ' || TRIM(vsruta_procesos) ||  '/load_archivodebito.sql';
	system vsql; 

	let vpaso= 26;		

--Carga la copia del archivo repaclaracionesdebito_AAAAMMDDcarga.txt a la tabla sc_abonos_atm

			let vsql = '';
			let vsql = 'dbaccess bdicheq ' || trim(vsruta_procesos) ||  '/load_archivodebito.sql';
			system vsql;

/*	let vpaso= 26;	

-Carga la copia del archivo repaclaracionescredito_AAAAMMDDcarga.txt a la tabla sc_abonos_atm	

	let vsql = '';
	let vsql = 'echo "LOAD FROM '|| TRIM(vsruta_procesos) || '/' || TRIM(vsnomarchivocredito)||TRIM(vamd)||'carga.txt'|| " " || " DELIMITER " || "'|'"||' INSERT INTO bdicheq:sc_abonos_atm" > ' || TRIM(vsruta_procesos) ||  '/load_archivocredito.sql';
	system vsql; 

	let vpaso= 27;		

--Carga la copia del archivo repaclaracionesdebito_AAAAMMDDcarga.txt a la tabla sc_abonos_atm
	
		let vsql = '';
		let vsql = 'dbaccess bdicheq ' || trim(vsruta_procesos) ||  '/load_archivocredito.sql';
		system vsql; */

	let vpaso= 28;
		
-- Eliminando archivo repaclaracionesdebito_AAAAMMDDcarga.txt

		let vsql = '';
		LET vsql = 'rm -f ' || TRIM(vsruta_procesos) ||'/'|| TRIM(vsnomarchivodebito)||TRIM(vamd)||'carga.txt';
		SYSTEM vsql;

/*   let vpaso= 29;

-- Eliminando archivo repaclaracionescredito_AAAAMMDDcarga.txt
		
		let vsql = '';
		LET vsql = 'rm -f ' || TRIM(vsruta_procesos) ||'/'|| TRIM(vsnomarchivocredito)||TRIM(vamd)||'carga.txt';
		SYSTEM vsql; */


	let vpaso= 28;
		
-- Eliminando archivo load_archivodebito.sql

		let vsql = '';
		LET vsql = 'rm -f ' || TRIM(vsruta_procesos) || '/'||'load_archivodebito.sql';
		SYSTEM vsql;

   let vpaso= 29;

/*-- Eliminando archivo load_archivocredito.sql
		
		let vsql = '';
		LET vsql = 'rm -f ' || TRIM(vsruta_procesos) || '/'||'load_archivocredito.sql';
		SYSTEM vsql;		
		*/
		
 let cCodret = '00000'; 
	let CVarDataErr = 'ARCHIVO CARGADO A TABLA '; 
				
------------------------------------------------------FIN DE CARGA DE ARCHIVO 


	RETURN cCodret,CVarDataErr;
	
END
END PROCEDURE;
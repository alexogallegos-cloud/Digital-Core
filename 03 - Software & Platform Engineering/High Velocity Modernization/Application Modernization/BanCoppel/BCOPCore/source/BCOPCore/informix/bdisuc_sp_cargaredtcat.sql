CREATE PROCEDURE "informix".sp_cargaredtcat ()
RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta ;


/*Definicion e inicializacion de variables*/
  
DEFINE fechahoy			date;
define fechaayer 		date;
DEFINE viSQLerr           INTEGER;
DEFINE NomArchivo			char(25); 
DEFINE vsSQL			char(500); 
DEFINE vsMensaje_Respuesta			char(250); 

define foliosuc		char(16);
define v1			integer;
define v2			integer;
define v3			integer;
define v4			integer;
define rvfolio		char(8);
define rvcodret		char(8);

define vaatm		char(4);
define vbi50		integer;
define vbi100		integer;
define vbi200		integer;
define vbi500		integer;
DEFINE vtotaldispensado			money(14,2);
define vtoterror    integer;
 
  
define vcantidad_2		integer;
define vcantidad_3		integer;
define vcantidad_4		integer;
define vcantidad_5		integer;
DEFINE vsaldo_total			money(14,2);

define insercion  char(300);



define vv1		char(15);
define vv2		char(15);
define vv3		char(15);
define vv4		char(15);
DEFINE vv5	char(15);
DEFINE vv6	char(15);
define i  integer;
define numvalida char(2);
define resp char(1);
define contbn integer;
define contml integer;

define vtreg integer;
define bol    integer;


let insercion = '';


let fechaayer='01/01/1900'; 
let fechahoy='01/01/1900';
let NomArchivo='';
let vsSQL='';
let vtoterror=0;

let vsMensaje_Respuesta='';
let foliosuc='';
let v1		=0;
let v2		=0;
let v3		=0;
let rvfolio	='';
let rvcodret='';
let vaatm ='';
let vbi50	  =0;
let vbi100	=0;
let vbi200	=0;
let vbi500	=0;
let vtotaldispensado =0;
let vcantidad_2	=0;
let vcantidad_3	=0;
let vcantidad_4	=0;
let vcantidad_5	=0;
let vsaldo_total	=0;

let vv1	='';
let vv2	='';
let vv3	='';
let vv4	='';
let vv5	='';
let vv6	='';
let i=1;
let numvalida='';
let resp='';
let contbn = 0;
let contml = 0;
let vtreg=0;
let bol=0;


 BEGIN

	ON EXCEPTION SET viSQLerr
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--LIMPIA LA TABLA
		--DELETE FROM BdiTarjeta:"informix".Td_Carga_Archivo;
		LET rvcodret = '00107';
		RETURN rvcodret, ('[' || viSQLerr ||  '] ERROR NO CONTROLADO. ARCHIVO (' || NomArchivo || ') ' || TRIM(vsMensaje_Respuesta) );
		
	END EXCEPTION;
	
-- extrae fecha de hoy
SELECT fecha_hoy,fecha_ant
into fechahoy,fechaayer
 FROM bdinteg:si_fechas;
 
 -- set debug file to 'CCO_corte.out';
--trace on; 
  
let NomArchivo = 'REDTCAT137D' ||replace( SUBSTR(fechaayer,9,2),'/','') ||  replace(SUBSTR(fechaayer,1,5),'/','')  ||'ED01.DAT';
 
    

 

LET vsMensaje_Respuesta = '1.LIMPIAR TABLA DE TRABAJO.';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--LIMPIA LA TABLA
	--truncate table bdisuc:ss_redcatfile ;
	delete from bdisuc:ss_redcatfile ;
	
	LET vsMensaje_Respuesta = '2.GENERAR COMANDO DE CARGA.';
	--CREA ARCHIVO DE INSTRUCCION DE CARGA 
	--LET vsSQL = 'echo "LOAD FROM  /resplogifx/archivoredtcat/''' || TRIM(NomArchivo) || ".DAT'" || ' INSERT INTO bdisuc:ss_redcatfile;">load_archivo.sql';
	LET vsSQL = 'echo "LOAD FROM  resplogifx/archivoredtcat/' || TRIM(NomArchivo) ||   ' INSERT INTO bdisuc:ss_redcatfile;">load_archivo.sql';
	
	SYSTEM vsSQL;
	 
			let vsSQL = '';
			let vsSQL= 'dbaccess bdisuc load_archivo.sql';
	system vsSQL;
			let vsSQL ='';
			let vsSQL ='rm  load_archivo.sql';
	system vsSQL;
	LET vsMensaje_Respuesta = '3.EJECUTAR CARGA DE ARCHIVO.';
	
 
 
		
	--borrar encabezado
		DELETE FROM bdisuc:ss_redcatfile WHERE  trim(columna1) = 'FIID';
	-- se copia contenido	
		
		
		insert into bdisuc:"informix".ss_redcatfile2 (fecha,nombrearchivo, atm, billete50, billete100, billete200, billete500,totaldispensado)
		select fechahoy as fecha,NomArchivo as nombrearchivo, atm, billete50, billete100, billete200, billete500,totaldispensado  
		from bdisuc:"informix".ss_redcatfile;
		
		
	foreach
	select trim(atm),trim(billete50)  ,trim(billete100) ,trim(billete200) ,trim(billete500), trim(totaldispensado) 
	into  vv1,vv2, vv3,vv4,vv5,vv6
	from  bdisuc:ss_redcatfile
	
	let i=2;
	let bol=0;
	WHILE  i <  7
      
	  
	  
	  if i=2  then
			execute procedure bdmis:"informix".sp_rcda_esnumerico(vv2)
			into resp;
	  
	  elif i=3 then
			execute procedure bdmis:"informix".sp_rcda_esnumerico(vv3)
			into resp;
	  
	  elif i=4 then
			execute procedure bdmis:"informix".sp_rcda_esnumerico(vv4)
			into resp;
	  
	  elif i=5 then
			execute procedure bdmis:"informix".sp_rcda_esnumerico(vv5)
			into resp;
	  
	  elif i=6 then
			execute procedure bdmis:"informix".sp_rcda_esnumerico(vv6)
			into resp;
	  
	  end if;
	  
	  if resp = 'F' then
		let bol = 1;
	  end if;	
	
	if i = 6 and bol = 1 then 
			DELETE FROM bdisuc:ss_redcatfile WHERE  trim(atm) = vv1; 
			update   bdisuc:"informix".ss_redcatfile2  set  integridad='F' where trim(atm) = vv1 and fecha = fechahoy; 
			let contml = contml + 1;
	end if;
	if i = 6 and bol = 0 then
			update   bdisuc:"informix".ss_redcatfile2  set  integridad='V' where trim(atm) = vv1 and fecha = fechahoy; 
		
	end if;	  
	  LET i = i + 1;
	  
   END WHILE; 
  end foreach;
	
	select count(*) 
	into vtreg
	from bdisuc:"informix".ss_redcatfile;
	
	let contbn= vtreg - contml;	
	-- se insertan en tabla correctas y fallidas( cantidades menores a 0 o letras para no tomarlas en cuenta)
	insert into bdisuc:"informix".cifrasredcat (fecha,nombrearchivo ,total,correctas,fallidas)
	VALUES(fechahoy,NomArchivo,vtreg,contbn,contml);
		
		
	 
foreach
		--select SUBSTR(trim(atm),3,4),billete50 /50,billete100/100,billete200 /200,billete500/500, totaldispensado 
		select trim(cc),nvl(billete50 /50,0),nvl(billete100/100,0),nvl(billete200 /200,0),nvl(billete500/500,0), totaldispensado 
		into vaatm,vbi50, vbi100,vbi200,vbi500,vtotaldispensado   --estos iran por parametro al sp de corte administrativo
		from bdisuc:ss_redcatfile,bdisuc:ss_relacionccid where trim(atm) = trim(ID)   order by 1 --cambiar nombre a ss_centrocostoid
		
		--actualiza el campo integridad de bdisuc:ss_redcatfile2
	--	update   bdisuc:"informix".ss_redcatfile2  set  integridad='V' where trim(cc) = vaatm; 
		
		  
			--   500       200        100		50         
	 	select nvl(cantidad_2,0),nvl(cantidad_3,0),nvl(cantidad_4,0),nvl(cantidad_5,0),  nvl(saldo_total,0) 
		into vcantidad_2,vcantidad_3,vcantidad_4,vcantidad_5,  vsaldo_total--NOTA 
		from bdisuc:ss_atm where cod_atm=vaatm ;
		
		insert into bdisuc:ss_corteadminview
		(fecha,atm,billete50ant,billete100ant,billete200ant,billete500ant, 
		billete50act,billete100act,billete200act,billete500act, totalant,totalact) 
		values(fechahoy,vaatm,vcantidad_5,vcantidad_4,vcantidad_3,vcantidad_2,                 
		vcantidad_5 - vbi50,vcantidad_4-vbi100,vcantidad_3-vbi200,vcantidad_2-vbi500, vsaldo_total,vsaldo_total-vtotaldispensado);
		
		
		  execute procedure   bdicheq:"informix".sp_random()
			 into v1;
			 execute procedure   bdicheq:"informix".sp_random()
			 into v2;
			 execute procedure   bdicheq:"informix".sp_random()
			 into v3;
			 execute procedure   bdicheq:"informix".sp_random()
			 into v4;
		let foliosuc ="informix" || LPAD(vaatm || SUBSTR(current hour to fraction(2) ,1,2) + SUBSTR(current hour to fraction(2) ,4,2)
					+ SUBSTR(current hour to fraction(2) ,7,2) + SUBSTR(current hour to fraction(2) ,10,2) + v1+ v2 + v3,8,v4);
					
		
let insercion=	"bdisuc:sp_corte_admin('001',"||vaatm||",'informix',"||foliosuc||",'0040','01',"||
vtotaldispensado||","||fechahoy||",'1000','500','200','100','50','20','','','','','','','','','','',"||vbi500||","||vbi200||","||vbi100||","||vbi50||",'','','','','','','','','','')";


execute PROCEDURE bdisuc:"informix".sp_corte_admin(	'001',vaatm,'informix',foliosuc,'0040','01',
vtotaldispensado,fechahoy,'1000','500','200','100','50','20','','','','','','','','','','',vbi500,vbi200,vbi100,vbi50,'','','','','','','','','','')
into rvcodret,rvfolio;

		 let vsSQL='PROCESO EXITOSO';
		 
		if rvcodret <> '000' then  

		let vtoterror=vtoterror + 1;
		let vsSQL='Error Corte administrativo sp_corte_admin, revisar tabla bitacora bdisuc:ss_bitacora_corteadmin';
		INSERT into bdisuc:ss_bitacora_corteadmin (CC,insercion,codret,folioretorno,fecha)
		 VALUES(vaatm,insercion,rvcodret,rvfolio,fechahoy);
		
		end if;
		
		
		
		
end foreach;
		if vtoterror = 0 then
		let vsSQL='PROCESO EXITOSO';
		INSERT into bdisuc:ss_bitacora_corteadmin (CC,insercion,codret,folioretorno,fecha)
		 VALUES('0000',vsSQL,rvcodret,vsSQL,fechahoy);
		
		end if;
		
		
		return rvcodret,vsSQL;
END;
END PROCEDURE;
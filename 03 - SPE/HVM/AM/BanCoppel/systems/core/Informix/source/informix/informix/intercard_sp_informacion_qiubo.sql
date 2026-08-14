CREATE PROCEDURE "informix".sp_informacion_qiubo(vdfechaIn DATETIME year to fraction(5),vdfechafin DATETIME year to fraction(5)) 
returning char (5), char(50);

/*
#####################################################################################
#   Creado por: Juan Fco. Ponce Damian												#
#   Fecha: 23/04/2014																#
#   Descripcion: Genera la información qiubo mensual								#
#####################################################################################
#   Modificado por: Juan Fco. Ponce Damian											#
#   Fecha de modificacion: 24/06/2014												#
#   Descripcion: se elimina el uso de tabla de paso y se realiza la generacion del  #
#	archivo directo																	#
#####################################################################################
*/

DEFINE viSqlErr     INTEGER;
DEFINE vsError      CHAR(50);
DEFINE vsCodret      CHAR(5);


--Variables de trabajo

DEFINE vimes INTEGER;
DEFINE vmes VARCHAR (10);
DEFINE vfechahora DATETIME YEAR TO FRACTION (5);
DEFINE vsSQL CHAR (2200) ;

  ON EXCEPTION SET viSqlErr
        
		LET vsError = 'ERROR NO CONTROLADO qiubo(' || viSqlErr || '). ' ;
		LET vsCodret = '1'||viSqlErr;
		
		RETURN vsCodret, vsError;
       
  END EXCEPTION;
--Set debug file to "/resplogifx/sp_informacion_qiubo.sql";
--trace on;

--manejo de errores
LET vsCodret = '00000';
LET vsError = 'PROCESO QIUBO EXITOSO';

--Variables de trabajo
LET vimes = MONTH (vdfechaIn);
LET vsSQL='';


	
	--Se extrae la primer fecha de intercard:movimiento
	set isolation to dirty read;
	SELECT min(fechahorainauth) INTO vfechahora	FROM intercard:movimiento ;
	--LET vfechahora= '2014-05-04 00:00:00';
	
	IF (vimes == 1 ) THEN
		LET vmes = 'enero';
		ELIF (vimes == 2 ) THEN
		LET vmes = 'febrero';
		ELIF (vimes == 3 ) THEN
		LET vmes = 'marzo';
		ELIF (vimes == 4 ) THEN
		LET vmes = 'abril';
		ELIF (vimes == 5 ) THEN
		LET vmes = 'mayo';
		ELIF (vimes == 6 ) THEN
		LET vmes = 'junio';
		ELIF (vimes == 7 ) THEN
		LET vmes = 'julio';
		ELIF (vimes == 8 ) THEN
		LET vmes = 'agosto';
		ELIF (vimes == 9 ) THEN
		LET vmes = 'septiembre';
		ELIF (vimes == 10 ) THEN
		LET vmes = 'octubre';
		ELIF (vimes == 11 ) THEN
		LET vmes = 'noviembre';
		ELIF (vimes == 12 ) THEN
		LET vmes = 'diciembre';
	ELSE
		LET vmes = 'nocembre';
	END IF;

	--GENERA EL ARCHIVO PARA EJECUTAR LA CARGA
	LET vsSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/compras_culiacan_qiubo_'||trim(vmes)||'.txt '||
	'select a.numtarjeta as Tarjeta,date(a.fechahorainauth) as Fecha,a.monto as Monto, '||
	'a.codgironeg'||'||''"'||'-'||'"''||'||'d.descgironeg as Giro,a.idretailer as NoAfiliacion  ,a.infreceptor as Nombre, '||
	'a.metodocaptura as MetodoCaptura, case when a.metodocaptura = ''"'||'05'||'"'' then ''"'||'Chip'||'"'' else ''"'||'Banda'||'"'' end as DescripcionMC '||
	'from intercard:movimientohistorico a inner join intercard:tarjeta b on a.numtarjeta=b.numtarjeta '||
	'inner join bdinteg:si_direcciones_actual c on c.numcte=b.numcliente and c.ciudad=''"'||'019'||'"'' and c.tipo_dir = ''"'||'1'||'"'' '||
	'left join intercard:gironegocio d on a.codgironeg = d.codgironeg where '||
	'a.fechahorainauth between ''"'||vdfechaIn||'"'' and ''"'||vfechahora||'"'' and a.prodind=''"'||'02'||'"'' '||
	'and a.codigoiso=''"'||'00'||'"'' and a.movreversado=''"'||'F'||'"'' and a.metodocaptura in (''"'||'05'||'"'',''"'||'90'||'"'') and '||
	'a.formato not in (''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'') and a.codtran not in (''"'||'94'||'"'',''"'||'95'||'"'') and a.codreversa = 0 '||
	'union all '||
	'select a.numtarjeta as Tarjeta,date(a.fechahorainauth) as Fecha,a.monto as Monto, '||
	'a.codgironeg'||'||''"'||'-'||'"''||'||'d.descgironeg as Giro,a.idretailer as NoAfiliacion  ,a.infreceptor as Nombre, '||
	'a.metodocaptura as MetodoCaptura, case when a.metodocaptura = ''"'||'05'||'"'' then ''"'||'Chip'||'"'' else ''"'||'Banda'||'"'' end as DescripcionMC '||
	'from intercard:movimiento a inner join intercard:tarjeta b on a.numtarjeta=b.numtarjeta '||
	'inner join bdinteg:si_direcciones_actual c on c.numcte=b.numcliente and c.ciudad=''"'||'019'||'"'' and c.tipo_dir = ''"'||'1'||'"'' '||
	'left join intercard:gironegocio d on a.codgironeg = d.codgironeg where '||
	'a.fechahorainauth between ''"'||vfechahora||'"'' and ''"'||vdfechafin||'"'' and a.prodind=''"'||'02'||'"'' '||
	'and a.codigoiso=''"'||'00'||'"''  and a.movreversado=''"'||'F'||'"'' and a.metodocaptura in (''"'||'05'||'"'',''"'||'90'||'"'') and '||
	'a.formato not in (''"'||'0221'||'"'',''"'||'0420'||'"'',''"'||'0421'||'"'') and a.codtran not in (''"'||'94'||'"'',''"'||'95'||'"'') and a.codreversa = 0 order by 2 ; " > load_archivo.sql';

	SYSTEM vsSQL;
	
	--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
	LET vsSQL = "dbaccess intercard load_archivo.sql";
	SYSTEM vsSQL;
	
RETURN vsCodret,vsError;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_incincrementos(pEmpresa CHAR(3))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;		  
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNum_cred  		CHAR(20);


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cNum_cred			= "";


       
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_incincrementos.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  FOREACH
	SELECT num_solicitud
	INTO cNum_cred
	FROM bdicred:"informix".sd_bitacora_aumlincred 
	WHERE empresa = pEmpresa
	AND status ='BC' 
	AND fecha_insert > mdy(5,7,2013)
	

	  EXECUTE PROCEDURE bdiburo:"informix".burocred(pEmpresa, "0001", "BC", cNum_cred, 0)
	    INTO cCodRet;	
	  
	 
  END FOREACH;	
  IF DBINFO("sqlca.sqlerrd2") =	0  THEN
	LET cCodRet             = "000001";
	LET cMensajeRet         = "No se encontro información, verifique...";
	RETURN cCodRet, cMensajeRet;
  END IF;
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion del historial de los status de la solicitud',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 18/02/2013',
'BD    : BDICRED',
'Version: 20130218.1210';

CREATE PROCEDURE "informix".sp_genera_reporte_tc_inactivas_pba(PEmpresa char(3))

returning
          char(06) as resultado,
          char(80) as mensaje;

define Sql_error Integer;
define cSql char(20000);
define cCodRet char(06);
define iCodRet integer;
define cMensajeRet CHAR(80);
define vfecha date;
define vreportes Integer;
--define vmes_fecha_aperturaes_t1 Integer;
--define vmes_fecha_aperturaes_t2 Integer;
define cNombreArchivo char(50);
define cNombreArchivo2 char(50);
define cNombreArchivo3 char(50);
define cNombreArchivo4 char(50);

let Sql_error = 0;
Let  cSql = '';
let cCodRet = '000000';
let iCodRet = 0;
let cMensajeRet = 'El proceso de REPORTES DE TC NUNCA E INACTIVAS se realizó correctamente';
let vfecha = date(1);
let vreportes = 0;
--let vmes_fecha_aperturaes_t1 = 0;
--let vmes_fecha_aperturaes_t2 = 0;
let cNombreArchivo = '';
let cNombreArchivo2 = '';
let cNombreArchivo3 = '';
let cNombreArchivo4 = '';

BEGIN
    on exception set iCodRet
            if iCodRet <> 0 then
            let cCodRet = iCodRet;
            let cMensajeRet ='Error al generar los REPORTES DE TC INACTIVAS ';
            return cCodRet,cMensajeRet ;
        end if;
    end exception;

--Set debug file to "sp_genera_reporte_tc_inactivas.out";
--Trace on;


truncate table bdicred:"informix".sd_clientesnunca drop storage;
truncate table bdicred:"informix".sd_totales_clientesnunca drop storage;

update statistics medium for table bdicred:"informix".sd_clientesnunca;
update statistics medium for table bdicred:"informix".sd_totales_clientesnunca;

--Se crea temporal con los creditos que fueron utilizados
/*
SELECT {+INDEX(bdicred:sd_movhis inx_movhis4)} num_credito 
FROM bdicred:sd_movhis 
WHERE empresa = '001' AND fecha_mov <= today  AND num_credito > '600000000000' AND REVERSADO IN ('N','S') AND codigo_fun != '008'
INTO temp temp_tc_utilizadas with no log;	

CREATE UNIQUE INDEX inx_temp_tc_utilizadas on temp_tc_utilizadas(num_credito);
UPDATE statistics medium FOR TABLE temp_tc_utilizadas;
*/
let vfecha = today;

if (day(vfecha) <= 20) then 

	if (month(vfecha) = 1) then
	   let vfecha = mdy( 12,20, year(vfecha) -1 );
	else
	   let vfecha = mdy( month(vfecha)-1,20, year(vfecha));
	end if;
else
	let vfecha = mdy( month(vfecha),20, year(vfecha));
end if;

set isolation to dirty read;
select {+INDEX(sd_maecredanexo idx_sd_maecredanexo1)} a.num_credito 
from bdicred:sd_maecredanexo a,
	 bdicred:sd_maesdoshist b,
	 bdicred:sd_maecred c
where a.empresa = PEmpresa
  and a.empresa = b.empresa
  and b.empresa = c.empresa
  and a.num_credito = b.num_credito
  and b.num_credito = c.num_credito
  and b.fecha = vfecha
      and a.fecha_proceso = b.fecha
  and c.fecha_apertura <= (vfecha - 6 units month)
  and (a.fecha_ult_pago is null or a.fecha_ult_pago < (vfecha -6 units month))
  and b.sdo_cap_insoluto <= 0
INTO temp tc_inactivas with no log;

CREATE UNIQUE INDEX tc_inactivas on tc_inactivas(num_credito);
UPDATE statistics medium FOR TABLE tc_inactivas;
--Se crea temporal con los creditos que fueron utilizados

------------------------------------------------------------------------------------------------------------------------------

--Se crea temporal con los creditos que fueron utilizados en los ultimos 6 mes_fecha_aperturaes
/*SELECT {+INDEX(bdicred:sd_movhis inx_movhis4)} num_credito 
FROM bdicred:sd_movhis 
WHERE empresa = '001' AND fecha_mov >= today - 6 units month  AND num_credito > '600000000000' AND REVERSADO IN ('N','S') AND codigo_fun != '008'
INTO temp temp_tc_utilizadas_6mes_fecha_aperturaes with no log;

CREATE UNIQUE INDEX inx_temp_tc_utilizadas_6mes_fecha_aperturaes on temp_tc_utilizadas_6mes_fecha_aperturaes(num_credito);
UPDATE statistics medium FOR TABLE temp_tc_utilizadas_6mes_fecha_aperturaes;
*/

set isolation to dirty read;
select {+INDEX(sd_maecredanexo idx_sd_maecredanexo3)} a.num_credito 
from bdicred:sd_maecredanexo a,
	 bdicred:sd_maesdoshist b,
	 bdicred:sd_maecred c
where a.empresa = PEmpresa
  and a.empresa = b.empresa
  and b.empresa = c.empresa
  and a.num_credito = b.num_credito
  and a.num_credito = c.num_credito
  and b.fecha = vfecha
  and c.fecha_apertura <= vfecha
  and (a.fecha_ult_pago is null or a.fecha_ult_pago = '')
  and b.sdo_cap_insoluto <= 0
INTO temp tc_nunca with no log;

CREATE UNIQUE INDEX idx_tc_nunca on tc_nunca(num_credito);
UPDATE statistics medium FOR TABLE tc_nunca;
--Se crea temporal con los creditos que fueron utilizados en los ultimos 6 mes_fecha_aperturaes

------------------------------------------------------------------------------------------------------------------------------

--Se insertan los creditos cuya tarjeta no ha sido utilizada
INSERT INTO bdicred:"informix".sd_clientesnunca
SELECT today,'1',year(a.fecha_apertura), month(a.fecha_apertura), a.num_credito, a.numcte, substr(b.num_tarjeta,13,4), g.monto_otorgado, a.sucursal, 
       c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, d.sexo, tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension, 
       trim(e.calle) || ' ' || e.numeroextcalle, e.colonia, f.nombre, e.cod_postal, e.observaciones
from bdicred:sd_maecred a
inner join bdicred:sd_tarjeta b on a.empresa = b.empresa and a.num_credito = b.num_credito and b.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where num_credito = a.num_credito and tipo_tarjeta = 'T')
inner join bdinteg:si_cliente c on c.numcte = a.numcte 
inner join bdinteg:si_ctepf d on d.numcte = a.numcte 
inner join bdinteg:si_direcciones_actual e on e.numcte = a.numcte and e.secuencia = (select max(secuencia) from bdinteg:si_direcciones_actual where numcte = e.numcte and tipo_dir = '1')
    and e.tipo_dir = '1'
inner join bdinteg:si_estados f on e.estado = f.estado
inner join bdicred:sd_maesdos g on a.empresa = g.empresa and a.num_credito = g.num_credito
left outer join bdinteg:si_telefonos_actual tel1 on tel1.numcte= a.numcte 
    and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = a.numcte and tipo_tel = 1 and cofetel ='V')
    and tel1.tipo_tel = 1 and tel1.cofetel ='V'
left outer join bdinteg:si_telefonos_actual tel2 on tel2.numcte= a.numcte 
    and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = a.numcte and tipo_tel = 2 and cofetel ='V')
    and tel2.tipo_tel = 2 and tel2.cofetel ='V'
left outer join bdinteg:si_telefonos_actual tel3 on tel3.numcte= a.numcte 
    and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = a.numcte and tipo_tel = 3 and cofetel ='V')
    and tel3.tipo_tel = 3 and tel3.cofetel ='V'
where a.empresa = '001'
and a.num_credito in (select num_credito from tc_nunca)
and a.status_cred = 'AA';

UPDATE statistics medium FOR TABLE bdicred:"informix".sd_clientesnunca;
--Se insertan los creditos cuya tarjeta no ha sido utilizada

------------------------------------------------------------------------------------------------------------------------------

--Se insertan los creditos cuya tarjeta no ha sido utilizada en los ultimos 6 mes_fecha_aperturaes
INSERT INTO bdicred:"informix".sd_clientesnunca
SELECT today, '2', year(a.fecha_apertura), month(a.fecha_apertura), a.num_credito, a.numcte, substr(b.num_tarjeta,13,4)ult_4_dig, g.monto_otorgado, a.sucursal, 
       c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, d.sexo, tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension, 
       trim(e.calle) || ' ' || e.numeroextcalle callenumero, e.colonia, f.nombre, e.cod_postal, e.observaciones
from bdicred:sd_maecred a 
inner join bdicred:sd_tarjeta b on a.empresa = b.empresa and a.num_credito = b.num_credito and b.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where num_credito = a.num_credito and tipo_tarjeta = 'T')
inner join bdinteg:si_cliente c on c.numcte = a.numcte  
inner join bdinteg:si_ctepf d on d.numcte = a.numcte 
inner join bdinteg:si_direcciones_actual e on e.numcte = a.numcte and e.secuencia = (select max(secuencia) from bdinteg:si_direcciones_actual where numcte = e.numcte and tipo_dir = '1')
    and e.tipo_dir = '1' 
inner join bdinteg:si_estados f on f.estado = e.estado
inner join bdicred:sd_maesdos g on g.empresa = a.empresa and g.num_credito = a.num_credito
left outer join bdinteg:si_telefonos_actual tel1 on tel1.empresa = a.empresa and tel1.numcte= a.numcte 
    and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = a.numcte and tipo_tel = 1 and cofetel ='V')
    and tel1.tipo_tel = 1 and tel1.cofetel ='V' 
left outer join bdinteg:si_telefonos_actual tel2 on tel2.empresa = a.empresa and tel2.numcte= a.numcte 
    and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = a.numcte and tipo_tel = 2 and cofetel ='V')
    and tel2.tipo_tel = 2 and tel2.cofetel ='V'
left outer join bdinteg:si_telefonos_actual tel3 on tel3.empresa = a.empresa and tel3.numcte= a.numcte 
    and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = a.numcte and tipo_tel = 3 and cofetel ='V')
    and tel3.tipo_tel = 3 and tel3.cofetel ='V'
where a.empresa = '001'
and a.num_credito in (select num_credito from tc_inactivas)
and a.status_cred = 'AA';

UPDATE statistics medium FOR TABLE bdicred:"informix".sd_clientesnunca;
--Se insertan los creditos cuya tarjeta no ha sido utilizada en los ultimos 6 mes_fecha_aperturaes

------------------------------------------------------------------------------------------------------------------------------


for vreportes in ( 2007 to year(today) )

	let cNombreArchivo = trim('Archivo_TC_Nunca' || LPAD(month(today),2,0) || vreportes || '.txt');

	let cSql = 'echo " Set Isolation to dirty read; Unload to ' || '/resplogifx/archivoscartera/Archivo_TC_Nunca.unl' || ' delimiter ' || ' ''|'' ' ||
	' select  numero_credito, numero_cliente,ultimos_4_digitos_tc, linea_credito, sucursal, apellido_paterno, apellido_materno, nombre1, nombre2, ' ||
	' sexo, tel_casa, tel_celular, tel_trabajo, extension, calle_numero, colonia, delegacion_municipio,codigo_postal, complemento_dir ' ||
	' from bdicred:sd_clientesnunca where tipo_cliente = ''1'' and anio_apertura = ' || vreportes || ' " ' ||
	' >/resplogifx/archivoscartera/Archivo_TC_Nunca.sql ';

	system cSql;
	let cSql='';
	let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_TC_Nunca.sql';
	system cSql;

	let cSql='';
	let csql = 'echo "Número de Credito'|| '|' || 'Número de Cliente'|| '|'|| 'Últimos 4 Digitos TC'|| '|'|| 'Línea de Crédito' || '|'|| 
			   'Sucursal' || '|'|| 'Apellido Paterno' || '|'|| 'Apellido Materno' || '|' || 'Primer Nombre'|| '|' || 'Segundo Nombre' || '|' || 
			   'Sexo' || '|' || 'Teléfono Casa' || '|' || 'Teléfono Celular' || '|' || 'Teléfono  Trabajo' || '|' || 'Ext' || '|' || 'Dirección Calle y Número' || '|' ||
			   'Dirección Colonia' || '|' || 'Dirección Delegación o Municipio' || '|' || 'Dirección CP' || '|' || 'Dirección Datos Complementarios' ||
				 ' " > /resplogifx/archivoscartera/'|| cNombreArchivo;

	system csql;

	let cSql='';
	let cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Archivo_TC_Nunca.unl >> /resplogifx/archivoscartera/"  || cNombreArchivo;
	system cSql;

	let cSql='';
	let cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Nunca.sql';
	system cSql;

	let cSql='';
	let cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Nunca.unl';
	system cSql;


	let cNombreArchivo2 = trim('Archivo_TC_Inactivas' || LPAD(month(today),2,0) || vreportes || '.txt');

	let cSql=''; 
	let cSql = 'echo " Set Isolation to dirty read; Unload to ' || '/resplogifx/archivoscartera/Archivo_TC_Inactivas.unl' || ' delimiter ' || ' ''|'' ' ||
	' select  numero_credito, numero_cliente,ultimos_4_digitos_tc, linea_credito, sucursal, apellido_paterno, apellido_materno, nombre1, nombre2, ' ||
	' sexo, tel_casa, tel_celular, tel_trabajo, extension, calle_numero, colonia, delegacion_municipio,codigo_postal, complemento_dir ' ||
	' from bdicred:sd_clientesnunca where tipo_cliente = ''2'' and anio_apertura = ' || vreportes || ' " ' ||
	' >/resplogifx/archivoscartera/Archivo_TC_Inactivas.sql ';

	system cSql;
	let cSql='';
	let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_TC_Inactivas.sql';
	system cSql;

	let cSql='';
	let csql = 'echo "Número de Crédito'|| '|' || 'Número de Cliente'|| '|'|| 'Ultimos 4 Digitos TC'|| '|'|| 'Línea de Crédito' || '|'|| 
			   'Sucursal' || '|'|| 'Apellido Paterno' || '|'|| 'Apellido Materno' || '|' || 'Primer Nombre'|| '|' || 'Segundo Nombre' || '|' || 
			   'Sexo' || '|' || 'Teléfono Casa' || '|' || 'Teléfono Celular' || '|' || 'Teléfono  Trabajo' || '|' || 'Ext' || '|' || 'Dirección Calle y Número' || '|' ||
			   'Dirección Colonia' || '|' || 'Dirección Delegación o Municipio' || '|' || 'Dirección CP' || '|' || 'Dirección Datos Complementarios' ||
				 ' " > /resplogifx/archivoscartera/'|| cNombreArchivo2;

	system csql;


	let cSql='';
	let cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Archivo_TC_Inactivas.unl >> /resplogifx/archivoscartera/"  || cNombreArchivo2;
	system cSql;

	let cSql='';
	let cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Inactivas.sql';
	system cSql;

	let cSql='';
	let cSql = 'rm /resplogifx/archivoscartera/Archivo_TC_Inactivas.unl';
	system cSql;

  	select tipo_cliente, anio_apertura anio, mes_apertura mes, sum(1) total 
	from bdicred:sd_clientesnunca
	where tipo_cliente = '1'
	and anio_apertura = vreportes
	group by tipo_cliente, anio_apertura,mes_apertura
	order by anio_apertura, mes_apertura
	into temp totales_ordenados_1;
	
	insert into bdicred:"informix".sd_totales_clientesnunca 
	select today,tipo_cliente, anio, 
	       (case when mes = 1  then 'ENERO'
			  	 when mes = 2  then 'FEBRERO'
				 when mes = 3  then 'MARZO'
				 when mes = 4  then 'ABRIL'
				 when mes = 5  then 'MAYO'
				 when mes = 6  then 'JUNIO'
				 when mes = 7  then 'JULIO'
				 when mes = 8  then 'AGOSTO'
				 when mes = 9  then 'SEPTIEMBRE'
				 when mes = 10 then 'OCTUBRE'
				 when mes = 11 then 'NOVIEMBRE'
				 when mes = 12 then 'DICIEMBRE'
			end),
 		   total
	from totales_ordenados_1
	where tipo_cliente = '1'
	and anio = vreportes;
	
	drop table totales_ordenados_1;
	
	select tipo_cliente, anio_apertura anio, mes_apertura mes, sum(1) total 
	from bdicred:sd_clientesnunca
	where tipo_cliente = '2'
	and anio_apertura = vreportes
	group by tipo_cliente, anio_apertura,mes_apertura
	order by anio_apertura, mes_apertura
	into temp totales_ordenados_2;
	
	insert into bdicred:"informix".sd_totales_clientesnunca 
	select today,tipo_cliente, anio, 
	       (case when mes = 1  then 'ENERO'
			  	 when mes = 2  then 'FEBRERO'
				 when mes = 3  then 'MARZO'
				 when mes = 4  then 'ABRIL'
				 when mes = 5  then 'MAYO'
				 when mes = 6  then 'JUNIO'
				 when mes = 7  then 'JULIO'
				 when mes = 8  then 'AGOSTO'
				 when mes = 9  then 'SEPTIEMBRE'
				 when mes = 10 then 'OCTUBRE'
				 when mes = 11 then 'NOVIEMBRE'
				 when mes = 12 then 'DICIEMBRE'
			end),
 		   total
	from totales_ordenados_2
	where tipo_cliente = '2'
	and anio = vreportes;
	
	drop table totales_ordenados_2;

end for;	

	

let cNombreArchivo3 = trim('Archivo_Concentrado_TC_Nunca' || LPAD(day(today),2,0) || LPAD(month(today),2,0) || year(today) || '.txt');
let cSql='';
let cSql = 'echo " Set Isolation to dirty read; Unload to ' || '/resplogifx/archivoscartera/Archivo_Concentrado_TC_Nunca.unl' || ' delimiter ' || ' ''|'' ' ||
           ' select anio_apertura, mes_apertura, cuantos from bdicred:"informix".sd_totales_clientesnunca where tipo_cliente = ''1'' ' ||
           ' " >/resplogifx/archivoscartera/Archivo_Concentrado_TC_Nunca.sql';
system cSql;

let cSql='';
let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_Concentrado_TC_Nunca.sql';
system cSql;

let cSql='';
let csql = 'echo "Año'|| '|' || 'Mes' || '|' || 'Número de Tarjetas " > /resplogifx/archivoscartera/'|| cNombreArchivo3;

system csql;

let cSql='';
let cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Archivo_Concentrado_TC_Nunca.unl >> /resplogifx/archivoscartera/"  || cNombreArchivo3;
system cSql;

let cSql='';
let cSql = 'rm /resplogifx/archivoscartera/Archivo_Concentrado_TC_Nunca.sql';
system cSql;

let cSql='';
let cSql = 'rm /resplogifx/archivoscartera/Archivo_Concentrado_TC_Nunca.unl';
system cSql;

let cNombreArchivo4 = trim('Archivo_Concentrado_TC_Inactivas' || LPAD(day(today),2,0) || LPAD(month(today),2,0) || year(today) || '.txt');
let cSql='';
let cSql = 'echo " Set Isolation to dirty read; Unload to ' || '/resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactivas.unl' || ' delimiter ' || ' ''|'' ' ||
           ' select year(today),  (case when month(today) = 1  then ''ENERO'' ' ||
									  ' when month(today) = 2  then ''FEBRERO'' ' ||
									  ' when month(today) = 3  then ''MARZO'' ' ||
									  ' when month(today) = 4  then ''ABRIL'' ' ||
									  ' when month(today) = 5  then ''MAYO'' ' ||
									  ' when month(today) = 6  then ''JUNIO'' ' ||
									  ' when month(today) = 7  then ''JULIO'' ' ||
									  ' when month(today) = 8  then ''AGOSTO'' ' ||
									  ' when month(today) = 9  then ''SEPTIEMBRE'' ' ||
									  ' when month(today) = 10 then ''OCTUBRE'' ' ||
									  ' when month(today) = 11 then ''NOVIEMBRE'' ' ||
									  ' when month(today) = 12 then ''DICIEMBRE'' ' ||
							      ' end), sum(cuantos::integer)cuantos from bdicred:"informix".sd_totales_clientesnunca where tipo_cliente = ''2'' ' ||
           ' " >/resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactivas.sql';
		   
system cSql;
let cSql='';
let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactivas.sql';
system cSql;

let cSql='';
let csql = 'echo "Año'|| '|' || 'Mes' || '|' || 'Número de Tarjetas " > /resplogifx/archivoscartera/'|| cNombreArchivo4;
system csql;

let cSql='';
let cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactivas.unl >> /resplogifx/archivoscartera/"  || cNombreArchivo4;
system cSql;

let cSql='';
let cSql = 'rm /resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactivas.sql';
system cSql;

let cSql='';
let cSql = 'rm /resplogifx/archivoscartera/Archivo_Concentrado_TC_Inactivas.unl';
system cSql;

/*
let cSql='';
let cSql = 'gzip -9' || cNombreArchivo4;

let cSql='';
let cSql = 'scp ' || trim(cNombreArchivo4) || '.gz'|| 'informix@10.36.193.214:/aplicacion/resplogifx/santiago';
*/
drop table tc_nunca;
drop table tc_inactivas;

return cCodRet,cMensajeRet ;

end;

end procedure;
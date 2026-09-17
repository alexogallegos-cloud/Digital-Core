CREATE PROCEDURE "informix".sp_genera_reporte_tc_inactivas(PEmpresa char(3))

returning
          char(06) as resultado,
          char(80) as mensaje;

define Sql_error Integer;
define cSql char(5000);
define cCodRet char(06);
define iCodRet,vTotal, isam_err  integer;
define cMensajeRet, cMensajeBita, error_info CHAR(80);
define vfecha date;
define vreportes Integer;
--define vmes_fecha_aperturaes_t1 Integer;
--define vmes_fecha_aperturaes_t2 Integer;
define cNombreArchivo char(50);
define cNombreArchivo2 char(50);
define cNombreArchivo3 char(50);
define cNombreArchivo4 char(50);
define vTipoCte, vSexo                                    char(1);
define vAnio, vParteNumTarjeta, vSucursal,vNumproceso     char(4);
define vExtension, vCodPostal                             char(5);
define vHora                                              char(8);
define vMes                                               char(12);
define vTelefono1, vTelefono2, vTelefono3                 char(13);
define vNumcredito, vNumcte                               char(20);
define vMontoOtorgado                                     decimal(18,2);
define vApellPaterno, vApellMaterno, vNombre1, vNombre2   char(26);
define vNomEstado                                         char(30);
define vCalleNumero                                       char(50);
define vColonia                                           char(60);
define vObservaciones                                     char(80);
define Vfechaapertura                                     date;

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
let vTipoCte = '';             let vAnio = '';            let vMes = '';              let vNumcredito = '';
let vNumcte = '';             let vParteNumTarjeta = '';  let vMontoOtorgado = 0;     let vSucursal = '';
let vApellPaterno = '';       let vApellMaterno = '';     let vNombre1 = '';          let vNombre2 = '';
let vSexo = '';               let vTelefono1 = '';        let vTelefono2 = '';        let vTelefono3 = '';
let vExtension = '';          let vCalleNumero = '';      let vColonia = '';          let vNomEstado = ''; 
let vCodPostal = '';          let vObservaciones = '';    let vNumproceso = '0050';   let vHora = '';
let isam_err = 0;             let error_info = '';                  
let cMensajeBita = '';        let vFechaapertura = date(1);

BEGIN
    on exception set iCodRet, isam_err, error_info
            if iCodRet <> 0 then
            let cCodRet = iCodRet;
            let cMensajeRet = 'Error al generar los REPORTES DE TC INACTIVAS. ' || error_info;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;
            
            INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
                 VALUES(PEmpresa, vNumproceso, today, cCodRet, cMensajeRet, 'informix', today, vHora);
            
            return cCodRet,cMensajeRet ;
        end if;
    end exception;

  --Set debug file to "/informix/macf/sp_genera_reporte_tc_inactivas.trc";
  --Trace on;

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;

  INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
      VALUES(PEmpresa, vNumproceso, today, cCodRet, 'Proceso Inicializado', 'informix', today, vHora);

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

/*
  if (day(vfecha) <= 20) then 
  	if (month(vfecha) = 1) then
  	   let vfecha = mdy( 12,20, year(vfecha) -1 );
  	else
  	   let vfecha = mdy( month(vfecha)-1,20, year(vfecha));
  	end if;
  else
	 let vfecha = mdy( month(vfecha),20, year(vfecha));
  end if;
*/
  ------------- ARMAR TBL BASE
  SELECT {+INDEX(bdicred:sd_maecred maesta)} a.empresa, a.num_credito, a.numcte, a.sucursal, a.fecha_apertura 
    FROM bdicred:sd_maecred a
	INNER JOIN bdicred:sd_maesdos maes ON maes.num_credito = a.num_credito
   WHERE a.empresa = PEmpresa
     AND a.status_cred IN ('AA','E1')
	 AND (maes.monto_vencido + maes.mto_venc_trasp) = 0
    INTO temp paso_cred1 WITH no log;
  
  CREATE UNIQUE INDEX inx_paso_cred1 ON paso_cred1(num_credito);

  UPDATE statistics medium FOR TABLE paso_cred1;

  -- CTES NUNCA
  SELECT b.empresa, a.num_credito, b.numcte, b.sucursal, b.fecha_apertura , '1' as tipo_cliente
    FROM bdicred:sd_indicador_cred a, paso_cred1 b
   WHERE a.empresa = PEmpresa
     AND a.num_credito = b.num_credito
     AND nvl(nvl(a.fecha_ultima_compra, a.f_primer_compra),date(1)) = date(1)
    INTO temp paso_ctesnunca WITH NO log;
    
  CREATE UNIQUE INDEX inx_paso_ctesnunca ON paso_ctesnunca(num_credito);
  
  UPDATE statistics medium FOR TABLE paso_ctesnunca;

  -- INACTIVAS
  INSERT INTO paso_ctesnunca
  SELECT b.empresa, a.num_credito, b.numcte, b.sucursal, b.fecha_apertura, '2' as tipo_cliente  --count(a.num_credito)
    FROM bdicred:sd_indicador_cred a, paso_cred1 b
   WHERE a.empresa = PEmpresa
     AND a.num_credito = b.num_credito
     AND nvl(nvl(a.fecha_ultima_compra, a.f_primer_compra),date(1)) > date(1)
     AND nvl(a.fecha_ultimo_pago,date(1)) <= today - 6 units month
     AND a.num_credito not in (select num_credito from paso_ctesnunca);
  


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

--Se crea temporal con los creditos que fueron utilizados en los ultimos 6 mes_fecha_aperturaes

------------------------------------------------------------------------------------------------------------------------------

  FOREACH WITH HOLD
        SELECT a.tipo_cliente, a.fecha_apertura, a.num_credito, a.numcte, substr(b.num_tarjeta,13,4), g.monto_otorgado, a.sucursal, 
               c.apell_paterno, c.apell_materno, c.nombre1, c.nombre2, d.sexo, tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension, 
               trim(e.calle) || ' ' || e.numeroextcalle, e.colonia, f.nombre, e.cod_postal, e.observaciones
          INTO vTipoCte, vFechaapertura, vNumcredito, vNumcte, vParteNumTarjeta, vMontoOtorgado, vSucursal, vApellPaterno, vApellMaterno, vNombre1, vNombre2, 
               vSexo, vTelefono1, vTelefono2, vTelefono3, vExtension, vCalleNumero, vColonia, vNomEstado, vCodPostal, vObservaciones   
          FROM paso_ctesnunca a  
        inner join bdicred:sd_tarjeta b on a.empresa = b.empresa and a.num_credito = b.num_credito and b.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a.empresa = empresa AND a.num_credito = num_credito and tipo_tarjeta = 'T')
        inner join bdinteg:si_cliente c on c.numcte = a.numcte 
        inner join bdinteg:si_ctepf d on d.numcte = a.numcte 
        inner join bdinteg:si_direcciones_actual e on e.numcte = a.numcte and e.tipo_dir = '1' 
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
       
        let vAnio = year(vFechaapertura);
        let vMes = lpad(month(vFechaapertura),2,'0');
        IF (vTelefono1 IS NULL) THEN let vTelefono1 = ''; END IF;              
        IF (vTelefono2 IS NULL) THEN let vTelefono2 = ''; END IF;
        IF (vTelefono3 IS NULL) THEN let vTelefono3 = ''; END IF;
        IF (vExtension IS NULL) THEN let vExtension = ''; END IF;        
        
        BEGIN WORK;
            INSERT INTO bdicred:"informix".sd_clientesnunca (fecha, tipo_cliente, anio_apertura, mes_apertura, numero_credito, numero_cliente, ultimos_4_digitos_tc, 
                   linea_credito, sucursal, apellido_paterno, apellido_materno, nombre1, nombre2, sexo, tel_casa, tel_celular, tel_trabajo, extension, calle_numero, 
                   colonia, delegacion_municipio, codigo_postal, complemento_dir) 
            VALUES(vfecha, vTipoCte, vAnio, vMes, vNumcredito, vNumcte, vParteNumTarjeta, vMontoOtorgado, vSucursal, vApellPaterno, vApellMaterno, vNombre1, vNombre2,
                       vSexo, vTelefono1, vTelefono2, vTelefono3, vExtension, vCalleNumero, vColonia, vNomEstado, vCodPostal, vObservaciones);
                   
       COMMIT WORK;
                   
  END FOREACH;


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
	
	system trim(cSql);  

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
	where tipo_cliente IN ('1','2')
	and anio_apertura = vreportes
	group by tipo_cliente, anio_apertura,mes_apertura
	order by anio_apertura, mes_apertura
	into temp totales_ordenados_1;
	
		FOREACH 
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
 		     into vfecha, vTipoCte, vAnio, vMes, vTotal
      	from totales_ordenados_1
      	where tipo_cliente IN('1', '2')
      	and anio = vreportes      	
      	
      	INSERT INTO bdicred:"informix".sd_totales_clientesnunca (fecha, tipo_cliente, anio_apertura, mes_apertura, cuantos) 
        VALUES(vfecha, vTipoCte, vAnio, vMes, vTotal); 
      	
	END FOREACH;
	
	drop table totales_ordenados_1;
 
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


SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora from sysmaster:sysshmvals;

INSERT INTO "informix".sd_bitacora_mec(empresa, num_proceso, fecha_ejecucion, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
    VALUES(PEmpresa, vNumproceso, today, cCodRet, 'Proceso Finalizado', 'informix', today, vHora);

return cCodRet,cMensajeRet ;

end;

end procedure;
CREATE PROCEDURE "informix".sp_validarlimpiartarjeta_n( pcNumTarjetaAnterior CHAR(16),
														pcNumTarjetaNuevo CHAR(16),
														pcTipoTarjeta CHAR (1), 
														piOpcion INTEGER)

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
--Asignacion de Variables.
LET cCodRet = "00000";
LET iSqlErr = 0;

	--SET DEBUG FILE TO "/tmp/sp_validarlimpiartarjeta_n.out";	--DSB20140318
	--TRACE ON;													--DSB20140318

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;								--DSB20140318	
	SET LOCK MODE TO WAIT 3;									--DSB20140318
	
	IF piOpcion = 1 THEN										--DSB20140318
		IF pcTipoTarjeta = '1' THEN
		--Validacion para verificar si la tarjeta a asignar no este asignada a otro cliente.
			IF EXISTS(SELECT tardeb.num_tarjeta FROM bdicheq:"informix".sc_tarjeta tardeb
					INNER JOIN "informix".tarjeta tar ON tardeb.num_tarjeta = tar.numtarjeta
					INNER JOIN "informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
					WHERE empresa = '001' AND tardeb.num_tarjeta = pcNumTarjetaNuevo AND tar.codstatustarjeta = 'ACT') THEN
				LET cCodRet = "00001";
			ELIF EXISTS(SELECT numtarjeta FROM "informix".tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND codstatustarjeta <> 'ACT')THEN
				IF EXISTS(SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = '001' and num_tarjeta = pcNumTarjetaNuevo)THEN
					LET cCodRet = "00002";
				END IF;
			END IF;
		ELSE
			IF EXISTS(SELECT tarcred.num_tarjeta FROM bdicred:"informix".sd_tarjeta tarcred
					INNER JOIN "informix".tarjeta tar ON tarcred.num_tarjeta = tar.numtarjeta
					INNER JOIN "informix".tarjetacuenta tarcta ON tarcta.numtarjeta = tar.numtarjeta
					WHERE empresa = '001' AND tarcred.num_tarjeta = pcNumTarjetaNuevo AND tar.codstatustarjeta = 'ACT') THEN
				LET cCodRet = "00001";
			ELIF EXISTS(SELECT numtarjeta FROM "informix".tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND codstatustarjeta <> 'ACT')THEN
				IF EXISTS(SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' and num_tarjeta = pcNumTarjetaNuevo)THEN
					LET cCodRet = "00002";
				END IF;
			END IF;
		END IF;

		IF cCodRet = "00000" THEN
		--Validacion para verificar si la tarjeta anterior esta completamente cancelada.
			IF EXISTS(SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaAnterior) THEN
				UPDATE bdicheq:"informix".sc_tarjeta SET status_tar = 'C' WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaAnterior;
			ELIF EXISTS(SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaAnterior) THEN
				UPDATE bdicred:"informix".sd_tarjeta SET status_tar = 'C' WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaAnterior;
			END IF;
						--Se comenta este bloque de codigo ya que la afectación de estas tablas se debe realizar por medio de interact rollback
	/*		IF EXISTS(SELECT fechaasignacion FROM "informix".tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND fechaasignacion IS NOT NULL) THEN
				UPDATE "informix".tarjeta
				SET codproductotarjeta = '',numcliente = '',titular = '',nombre = '',usuarioultmodif = '',
					fechaultmodif = '',fechanacimiento = '',numtarjetasustituta = '',codstatustarjeta = 'INA',
					codstatusasignada = 'NOA',fechaasignacion = ''
				WHERE numtarjeta = pcNumTarjetaNuevo; 

				DELETE FROM "informix".tarjetacuenta WHERE numtarjeta = pcNumTarjetaNuevo;
			END IF;*/
		END IF;
	ELSE 													--DSB20140318 {
		IF piOpcion = 2 THEN
		--Se agrega validación para solo eliminar de las bases de datos bdicred o bdicheq en caso de que la tarjeta no este asignada en intercard
			IF EXISTS(SELECT fechaasignacion FROM "informix".tarjeta WHERE numtarjeta = pcNumTarjetaNuevo AND fechaasignacion IS NULL) THEN
				IF pcTipoTarjeta = '1' THEN
					IF EXISTS (SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaNuevo) THEN
						DELETE FROM bdicheq:"informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaNuevo;
					END IF;
				ELSE
					IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaNuevo) THEN
						DELETE FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjetaNuevo;
					END IF;
				END IF;
			END IF;	
		END IF;
	END IF;													--DSB20140318 }
	
RETURN cCodRet;
END
END PROCEDURE

DOCUMENT
"Especificacion: Valida si la tarjeta este mal asignada, si es asi limpia los datos de la tarjeta",
"                para que se pueda volver a asignar",
"Base de Datos : intercard",
"Autor : Jesus Manuel Perea Heredia",
"Fecha : 19/Nov/2010",
"Descripcion: Valida si la tarjeta a asignar no cuente con una cuenta asignada,",
"asi como tambien que la tarjeta anterior se encuentre correctamente cancelada",
"finalmente valida si la tarjeta este mal asignada, si es asi limpia los datos de la tarjeta para que se pueda volver a asignar",
"Base de Datos : intercard",
"Autor : Marcos Cuevas",
"Fecha : 31/Dic/2010",
"Descripcion: Se elimina validacion debido a que estaba de mas.",
"Base de Datos : intercard",
"Autor : Marcos Cuevas",
"Fecha : 13/Enero/2011",
"Descripcion: Se actualiza a la nueva version de reglas.",
"Base de Datos : intercard",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011",
'Folio.........: 1399-INC_TarjetasIncompletasEnReposición',
'Autor.........: 95526749 - Jesús Horacio López González',
'Fecha.........: 18/03/2014 - DSB20140318',
'Modificación..: Se clona sp_validarlimpiartarjeta y se agrega parametro para limpiar la tabla sc_tarjeta o sd_tarjeta si ocurre un problema',
'                al momento de realizar el alta de la tarjeta mediante el Interact',
'Sustento......: INC-24-123 Suc. Reposición incompleta v1.0.pdf',
'Solicita......: Cutberto Gonzalez',
'BD............: INTERCARD';

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
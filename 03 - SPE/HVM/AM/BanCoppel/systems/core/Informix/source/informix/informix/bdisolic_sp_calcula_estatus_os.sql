CREATE PROCEDURE "informix".sp_calcula_estatus_os()
RETURNING CHAR(6), char(80)

--Autor: Jose Luis Pulido
--26-06-2009
--Almacena los datos de las solicitudes de credito con estatus enviada a orden de supervisión

--Modifico:Jose Luis Pulido
--Fecha de modificacion: 13-07-2009
--Cambios: Se cambio valor de validacion al momento de buscar las solicitudes con el estatus Orden de Supervision, para el tipo de estatus para dejarlo igual que el valor qeu tiene el catalogo de produccion

--Modifico:Jose Luis Pulido
--Fecha de modificacion: 22-07-2009
--Cambios: Se quitaron las consultas individuales y se dejo solo una consulta general.
--	        Se movio al principio la insercion del registro de inicio a la tabla de bitacora
--	        Se agrego la insercion de un registro en la tabla de bitacora cuando el proceso se ha finalizado con exito y cuando no existen solicitudes para procesar.

--Modifico:Jose Luis Pulido
--Fecha de modificacion: 12-08-2009
--Cambios: Se modifico la conversion a tipo fecha del campo fechaos de la tabla temporal tmpConsultaMonitor al momento de insertar en la tabla bdisolic:ss_solicitud_env_os 
-- 	        se estaban insertando todos los datos con el valor NULL.

--Modifico:René Chiquete Elizalde.
--Fecha de modificacion: 18-01-2010
--Cambios:  Se agrega campo numero_region a la consulta principal, el cual contendra el numero de region al que pertenece la orden de supervision.

--Modifico:René Chiquete Elizalde.
--Fecha de modificacion: 16-02-2010
--Cambios:  El valor que toma la variable vfechaOS cambio del campo fechaimpresion de la tabla bdisolic:ss_osclientesupervisar al valor del campo
--fecha_entrada de la tabla bdisolic:ss_autorizacion


DEFINE sCodRet CHAR(6);				--CODIGO DE RETORNO PERSONALIZADO
DEFINE iCodRet INTEGER ;			--CODIGO DE RETORNO INTERNO
DEFINE sErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
DEFINE cErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
DEFINE iIsamErr smallint;	 		--VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE dfecha_hoy date;				--FECHA ACTUAL
DEFINE sProceso char(20);	 		--PROCESO QUE SE MANDA A LA TABLA
DEFINE sRegistros SMALLINT;			--VARIABLE PARA OBTENER CUANTOS REGISTROS TRAE LA CONSULTA
DEFINE iSecuencia integer;			--SECUENCIA MAXIMA
DEFINE sTablaCreada SMALLINT ;		--PARA VERIFICAR SI SE CREO O NO LA TABLA TEMPORAL
DEFINE vnum_solicitud CHAR(20);		--NUMERO DE SOLICITUD
--DEFINE cSql CHAR(5000);				--VARIABLE PARA GUARDAR EL COMANDO QEU SE VA A EJECUTAR DESDE CON EL SYSTEM

LET sCodRet = '11111';
LET dfecha_hoy = DATE(1);
LET iCodRet =0;
LET sErrorInfo='';
LET cErrorInfo= 'PROCESO INICIALIZADO';
LET sProceso='CALCULA ESTATUS OS';
LET iSecuencia = 0;
LET sTablaCreada = 0;
LET vnum_solicitud = "";


--SET DEBUG FILE TO '/respaldosbd/ReneChiquete/PRUEBA.out';
--TRACE ON;


BEGIN
    ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
        LET SCodRet = iCodRet;
		LET cErrorInfo=sErrorInfo;
		
		if not exists (select proceso from bdisolic:ss_bitacora_os where fecha_insert=dfecha_hoy and trim(cod_ret) = '11111' 
                        and proceso ='CALCULA ESTATUS OS') then
			
            INSERT INTO bdisolic:ss_bitacora_os(proceso,cod_ret,mensaje,user_insert,fecha_insert,hora_insert) 
            VALUES(sProceso, sCodRet, trim(cErrorInfo), USER, dfecha_hoy, 
            (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals));

		else

            update bdisolic:ss_bitacora_os set proceso = sProceso, cod_ret = sCodRet, mensaje = cErrorInfo,
            hora_insert = (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals)
            where fecha_insert = dfecha_hoy  and cod_ret = '11111' and proceso ='CALCULA ESTATUS OS';
		end if;
	
		delete from bdisolic:ss_solicitud_env_os;
		
		 IF sTablaCreada = 1 THEN
            DROP TABLE tmpConsultaMonitor;
        END IF
        RETURN SCodRet, cErrorInfo;
    END Exception;

set isolation to dirty read;


	--OBTENEMOS LA FECHA DE HOY
	SELECT fecha_hoy into dfecha_hoy FROM bdicheq:sc_fechas WHERE empresa = '001';
	
	--SE INSERTA EL REGISTRO DE INICIO DEL PROCESO EN LA BITACORA
	if not exists (select proceso from bdisolic:ss_bitacora_os where fecha_insert=dfecha_hoy and cod_ret = '11111'
                    and proceso ='CALCULA ESTATUS OS') then

        INSERT INTO bdisolic:ss_bitacora_os(proceso,cod_ret,mensaje,user_insert,fecha_insert,hora_insert) 
        VALUES(sProceso, sCodRet, trim(cErrorInfo), USER, dfecha_hoy, 
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals));

	else

        update bdisolic:ss_bitacora_os set proceso = sProceso, cod_ret = sCodRet, mensaje = cErrorInfo,
            hora_insert = (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals)
            where fecha_insert = dfecha_hoy  and cod_ret = '11111' and proceso ='CALCULA ESTATUS OS';
	end if;
	
	if not exists (select proceso from bdisolic:ss_bitacora_os where fecha_insert=dfecha_hoy and cod_ret = '00000'
                    and proceso ='CALCULA ESTATUS OS') then
		
		--VALIDAMOS QUE EXISTAN SOLICITUDES CON EL STATUS ENVIADA A ORDEN DE SUPERVISION	
		select limit 1 num_solicitud INTO vnum_solicitud from bdisolic:ss_solicitudes 
		where empresa = '001' AND tipo_solicitud = 'T' and status_solicitud = 'OS';
		--VALIDAMOS QUE LA CONSULTA NOS REGRESE DATOS		
		LET sRegistros=dbinfo("sqlca.sqlerrd2");
		
		if sRegistros>0 then
			
			--ELIMINAMOS LAS SOLICITUDES ALMACENADAS PREVIAMENTE
			delete from bdisolic:ss_solicitud_env_os;
			
			--OBTENEMOS LOS DATOS DE LAS SOLICITUDES IY LOS INSERTAMOS EN LA TABLA TEMPORAL
			SELECT NVL(h.estatusos,0) estatusos, NVL(zon.numerocobranzas,0) numerocobranzas, NVL(trim(a.nombre),'') nombre, i.abrevia_prod, 
				trim(c.num_solicitud) num_solicitud, NVL(c.fecha_insert,'') as fechasolic, c.status_solicitud,
			    TRIM(NVL(d.razon_social,' ')) || TRIM(NVL(d.nombre1, ' ')) || ' ' || TRIM(NVL(d.nombre2, ' ')) || ' ' || TRIM(NVL(d.apell_paterno, ' ')) || ' ' || TRIM(NVL(d.apell_materno, ' ')) nombre_cliente, NVL(pf.fecha_nac,'') fecha_nac,
			    CASE WHEN NVL(folio,'0') ='0' THEN '0000-0' ELSE trim(c.sucursal || '-' || folio) END as folio,
			   NVL(CASE WHEN NVL((SELECT MAX(fecha_entrada) FROM bdisolic:ss_autorizacion 
							   WHERE num_solicitud = c.num_solicitud AND status_solicitud = c.status_solicitud),'01-01-1900'::DATE) = '01-01-1900'::DATE OR NVL(h.folio,0) =0 THEN
			        CASE WHEN TO_CHAR(NVL(h.fechasolicitud,'01-01-1900'::date),'%Y-%m-%d') = '01-01-1900' THEN null
			        ELSE TO_CHAR(h.fechasolicitud,'%m-%d-%Y')::Date
			        END
			    ELSE CASE WHEN TO_CHAR(NVL((SELECT MAX(fecha_entrada) FROM bdisolic:ss_autorizacion 
							   WHERE num_solicitud = c.num_solicitud AND status_solicitud = c.status_solicitud),'01-01-1900'::date),'%Y-%m-%d') = '01-01-1900' THEN null
			         ELSE TO_CHAR(NVL((SELECT MAX(fecha_entrada) FROM bdisolic:ss_autorizacion 
							   WHERE num_solicitud = c.num_solicitud AND status_solicitud = c.status_solicitud),'01-01-1900'::date),'%m-%d-%Y')::date END
			    END,'') as fechaOS,
			    CASE WHEN NVL((SELECT today - MAX(fecha_entrada) FROM bdisolic:ss_autorizacion 
							   WHERE num_solicitud = c.num_solicitud AND status_solicitud = c.status_solicitud),0) > 1000 THEN 1000
					 ELSE NVL((SELECT today - MAX(fecha_entrada) FROM bdisolic:ss_autorizacion 
							   WHERE num_solicitud = c.num_solicitud AND status_solicitud = c.status_solicitud),0) END as DIAS,
				NVL(cc.nombrecalle,'') as nombrecalle, 
				NVL(dir.numeroextcalle,'') as numeroextcalle, 
				NVL(dir.numerointcalle,'') as numerointcalle, NVL(dir.observaciones,'') as complemento,
			    NVL(lpad(dir.numerocolonia, 3, '0') || ' ' || trim(zon.nombrezona),'') as zona, 
				NVL(cd.numerociudad || '-' || trim(cd.inicialciudad),'') as ciudad,
			    NVL(cd.numeroestado || '-' || trim(cd.inicialestado),'') as estado, NVL(t1.telefono,'') as telefono1, 
				NVL(t2.telefono,'') as telefono2, NVL(t3.telefono,'') as telefono3, cd.numero_region as numero_region
		    FROM bdisolic:ss_solicitudes c
			    LEFT OUTER JOIN bdisolic:ss_osclientesupervisar h ON c.empresa = h.empresa AND c.num_solicitud = h.num_solicitud
			    LEFT OUTER JOIN bdinteg:si_sucursales a ON (a.empresa = c.empresa AND a.sucursal = c.sucursal)
			    LEFT OUTER JOIN bdicred:sd_definicion b ON (b.empresa = c.empresa AND b.num_producto = c.num_producto)
			    LEFT OUTER JOIN bdicred: sd_tipcred i ON i.empresa = b.empresa AND i.cod_tipcred = b.cod_tipcred
			    LEFT OUTER JOIN bdinteg:si_cliente d ON (d.numcte = c.numcte)
			    LEFT OUTER JOIN bdinteg:si_ctepf pf ON (pf.numcte = d.numcte)
			    --LEFT OUTER JOIN bdinteg:si_direcciones dir ON (d.numcte = dir.numcte AND 
					--	dir.secuencia = (select max(secuencia) from bdinteg:si_direcciones where numcte = d.numcte and tipo_dir = '1' ))
					LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (d.numcte = dir.numcte AND dir.tipo_dir = '1')
					LEFT OUTER JOIN bdinteg:si_telefonos_actual t1 ON (d.numcte = t1.numcte AND t1.tipo_tel = 1 AND t1.status_tel = 'A')
					LEFT OUTER JOIN bdinteg:si_telefonos_actual t2 ON (d.numcte = t2.numcte AND t2.tipo_tel = 2 AND t2.status_tel = 'A')
					LEFT OUTER JOIN bdinteg:si_telefonos_actual t3 ON (d.numcte = t3.numcte AND t3.tipo_tel = 3 AND t3.status_tel = 'A')
			    LEFT OUTER JOIN bdinteg:si_catciudades cd ON (cd.numerociudad = dir.numerociudad)
			    LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad  AND zon.numerocolonia = dir.numerocolonia)
			    LEFT OUTER JOIN bdinteg:si_catcalles cc ON (dir.numerocalle = cc.numerocalle)
		    WHERE c.empresa = '001' AND c.tipo_solicitud = 'T' AND c.status_solicitud = 'OS'
				AND NVL(h.fechasolicitud,CURRENT) = (SELECT NVL(MAX(fechasolicitud),CURRENT) FROM bdisolic:ss_osclientesupervisar
													 WHERE empresa = c.empresa AND num_solicitud = c.num_solicitud)
			INTO TEMP tmpConsultaMonitor;
			
			--INDICAMOS QUE SE HA CREADO LA TABLA TEMPORAL
			LET sTablaCreada = 1;
			
			--INSERTAMOS LOS DATOS EN LA TABLA ss_solicitud_env_os
			insert into bdisolic:ss_solicitud_env_os (matriz_impr, numero_cobranza, nombre_sucursal, producto, num_solicitud, fecha_solicitud, status_solicitud,
				nombre_cliente, fecha_nacimiento, folio_os, fecha_os, dias_os, nombre_calle, num_exterior, num_interior, comple_domicilio, nombre_colonia,
				nombre_ciudad, nombre_estado, tel_particular, tel_celular, tel_trabajo, numero_region)
			select estatusos, numerocobranzas, nombre, abrevia_prod, num_solicitud, fechasolic,
				   status_solicitud, nombre_cliente, fecha_nac, folio,
				   fechaos, dias, nombrecalle, numeroextcalle, numerointcalle, complemento,
				   zona, ciudad, estado, telefono1, telefono2, telefono3, nvl(numero_region,0)
			from tmpConsultaMonitor;

			--ELIMINAMOS LA TABLA TEMPORAL
			drop table tmpConsultaMonitor;
			
			--INDICAMOS QUE LA TABLA TEMPORAL YA NO EXISTE
			LET sTablaCreada = 0;
			LET sCodRet = '00000';
			LET cErrorInfo= 'PROCESO EXITOSO';
			
			--INSERTAMOS EN LA BITACORA EL REGISTRO QUE INDICA QUE EL PROCESO FINALIZO CON EXITO
			
            INSERT INTO bdisolic:ss_bitacora_os(proceso,cod_ret,mensaje,user_insert,fecha_insert,hora_insert) 
            VALUES(sProceso, sCodRet, trim(cErrorInfo), USER, dfecha_hoy, 
            (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals));

			
			return SCodRet, cErrorInfo;
			
		else --SI NO EXISTEN SOLICITUDES CON EL STATUS ENVIADA A ORDEN DE SUPERVISION
	        LET SCodRet = '00001';
			LET cErrorInfo='NO EXISTEN SOLICITUDES CON EL STATUS ENVIADA A ORDEN DE SUPERVISION';
			
			--SE INSERTA EL REGISTRO EN LA BITACORA
			if not exists (select proceso from bdisolic:ss_bitacora_os where fecha_insert=dfecha_hoy and trim(cod_ret) = '11111'
                            and proceso ='CALCULA ESTATUS OS') then

                INSERT INTO bdisolic:ss_bitacora_os(proceso,cod_ret,mensaje,user_insert,fecha_insert,hora_insert) 
                VALUES(sProceso, sCodRet, trim(cErrorInfo), USER, dfecha_hoy, 
                (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals));

			else

                update bdisolic:ss_bitacora_os set proceso = sProceso, cod_ret = sCodRet, mensaje = cErrorInfo,
                hora_insert = (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals)
                where fecha_insert = dfecha_hoy  and cod_ret = '11111' and proceso ='CALCULA ESTATUS OS';
			end if;

	        RETURN SCodRet, cErrorInfo;
			
		end if;
		
	else --SI EL PROCESO YA SE A EJECUTADO CON EXITO
		LET SCodRet = '00002';
		LET cErrorInfo='EL PROCESO YA HA SIDO EJECUTADO CON EXITO EL DIA DE HOY';
		
		--SE INSERTA EL REGISTRO EN LA BITACORA
		if not exists (select proceso from bdisolic:ss_bitacora_os where fecha_insert=dfecha_hoy and cod_ret = '11111'
                        and proceso ='CALCULA ESTATUS OS') then

            INSERT INTO bdisolic:ss_bitacora_os(proceso,cod_ret,mensaje,user_insert,fecha_insert,hora_insert) 
                VALUES(sProceso, sCodRet, trim(cErrorInfo), USER, dfecha_hoy, 
                (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals));
		else

            update bdisolic:ss_bitacora_os set proceso = sProceso, cod_ret = sCodRet, mensaje = cErrorInfo,
                hora_insert = (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND FROM sysmaster:sysshmvals)
                where fecha_insert = dfecha_hoy  and cod_ret = '11111' and proceso ='CALCULA ESTATUS OS';
		end if;
		
        RETURN SCodRet, cErrorInfo;
		
	end if;
	END ;
END PROCEDURE;
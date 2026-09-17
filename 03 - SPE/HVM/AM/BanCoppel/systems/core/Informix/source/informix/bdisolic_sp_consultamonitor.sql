CREATE PROCEDURE "informix".sp_consultamonitor( pEmpresa CHAR(3), pTipoSolicitud CHAR(1), pStatusSolicitud CHAR(2), pAgrupamiento CHAR(25),
												pCausa_Status CHAR(80), pFecha_Inicio CHAR(10), pFecha_Fin CHAR(10), pNumCte CHAR(9), pNumCred CHAR(12))
RETURNING CHAR(6), INT, SMALLINT, CHAR(40), CHAR(5), CHAR(20), DATE, CHAR(2), CHAR(170), DATE, CHAR(50), CHAR(20), INT, CHAR(30), CHAR(10), CHAR(10), CHAR(80), char(50), CHAR(10), CHAR(10), CHAR(13), CHAR(13), CHAR(13);

--Autor: Walber Castro
--27-03-2009
--Obtiene los datos de consulta para la aplicación Monitor de Solicitudes

--Modifico: Jose Luis Pulido
--Fecha: 15-05-2009
--Se quito la creacion de una tabla temporal para utilizar la consulta en todos los posibles casos de agrupamiento

--Modifico: Jose Luis Pulido
--Fecha:08/06/2009
--Se separo la consulta principal en varias consultas mas pequeñas para reducir el costo
--Se insertan los resultados en una tabla temporal y el ordenamiento se hace sobre esta

--Modificó: Héctor Manuel Bojórquez Ruelas
--Fecha: 05/Abril/2011
--Se modifica para agreagr nuevos filtros de busquedas de solicitudes los cuales son:
--el tipo de status de la solicitud, fecha de inicio y fecha fin en la que la siolicitud esta en su status actual

DEFINE cErrorInfo CHAR(80);			--CODIGO DE MENSAJE DE RETORNO PERSONALIZADO

DEFINE sCodRet CHAR(6);				--CODIGO DE RETORNO PERSONALIZADO
DEFINE iCodRet INTEGER ;			--CODIGO DE RETORNO INTERNO

DEFINE vTablaCreada SMALLINT ;		--SIRVE PARA VALIDAR SI LA TABLA TEMPORAL ESTA CREADA

DEFINE vestatusos INTEGER ;			--ESTATUS
DEFINE vnumerocobranzas SMALLINT ;	--NUMERO DE COBRANZAS
DEFINE vnombre CHAR(40);			--NOMBRE DE SUCURSAL
DEFINE vabrevia_prod CHAR(5);		--ABREVIATURA DE PRODUCTO
DEFINE vnum_solicitud CHAR(20);		--NUMERO DE SOLICITUD
DEFINE vfechasolic DATE ;			--FECHA DE REGISTRO
DEFINE vstatus_solicitud CHAR(2);	--ESTATUS DE SOLICITUD
DEFINE vnombre_cliente CHAR(170);	--NOMBRE DEL CLIENTE
DEFINE vfecha_nac DATE ;			--FECHA DE NACIMIENTO
DEFINE vfolio CHAR(50);				--FOLIO
DEFINE vfechaos CHAR(20) ;			--FECHA DE OS
DEFINE vdias INTEGER ;				--DIAS
DEFINE vnombrecalle CHAR(30);		--NOMBRE DE CALLE
DEFINE vnumeroextcalle CHAR(10);	--NUMERO EXTERIOR
DEFINE vnumerointcalle CHAR(10);	--NUMERO INTERIOR
DEFINE vcomplemento CHAR(80);		--COMPLEMENTO
DEFINE vzona char(50);				--COLONIA
DEFINE vciudad CHAR(10);			--CIUDAD
DEFINE vestado CHAR(10);			--ESTADO
DEFINE vtelefono1 CHAR(13);			--TELEFONO 1
DEFINE vtelefono2 CHAR(13);			--TELEFONO 2
DEFINE vtelefono3 CHAR(13);			--TELEFONO 3

DEFINE sempresa CHAR(3);			--EMPRESA
DEFINE snumcte CHAR(20);			--NUMERO DE CLIENTE
DEFINE stipo_solicitud CHAR(1);		--TIPO DE SOLICITUD
DEFINE sstatus_solicitud CHAR(2);	--ESTATUS DE SOLICITUD
DEFINE snum_producto CHAR(4);		--NUMERO DE PRODUCTO
DEFINE dfechasolicitud DATE ;		--FECHA DE SOLICITUD
DEFINE dfechaimpresion DATE ;		--FECHA DE IMPRESION
DEFINE ssucursal CHAR (4);			--SUCURSAL
DEFINE dtFechaIni DATE;
DEFINE dtFechaFin DATE;

LET cErrorInfo					= "PROCESO EXITOSO";
LET sCodRet = "000";
LET vTablaCreada = 0;
LET vestatusos = 0;
LET vnumerocobranzas = 0;
LET vnombre = "";
LET vabrevia_prod = "";
LET vnum_solicitud = "";
LET vfechasolic = "01-01-1900";
LET vstatus_solicitud ="";
LET vnombre_cliente ="";
LET vfecha_nac = "01-01-1900";
LET vfolio = "";
LET vfechaos = "01-01-1900";
LET vdias = 0;
LET vnombrecalle ="";
LET vnumeroextcalle ="";
LET vnumerointcalle ="";
LET vcomplemento ="";
LET vzona ="";
LET vciudad ="";
LET vestado ="";
LET vtelefono1 ="";
LET vtelefono2 ="";
LET vtelefono3 ="";

LET sempresa ="";
LET snumcte ="";
LET stipo_solicitud ="";
LET sstatus_solicitud ="";
LET snum_producto = "";
LET dfechasolicitud = "01-01-1900";
LET dfechaimpresion = "01-01-1900";
LET ssucursal = "";
LET dtFechaIni =pFecha_Inicio;
LET dtFechaFin = pFecha_Fin;

/*
--SET DEBUG FILE TO '/respaldosbd/hectorb/PRUEBA.out';
--TRACE ON;
*/
BEGIN
    ON EXCEPTION SET iCodRet
        Let SCodRet = iCodRet;
        IF vTablaCreada=1 THEN
            DROP TABLE bdisolic:tmpconsmonitor;
        END IF
        RETURN SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3;
    END Exception;

LET vTablaCreada = 0;
	--Preguntamos si existe la tabla temporal, si no existe la creamos, si existe primero la eliminamos y luego la creamos
    IF EXISTS(SELECT tabname FROM sysmaster:systabnames where tabname = 'tmpconsmonitor') THEN
        DROP TABLE bdisolic:tmpconsmonitor;
		create table bdisolic:tmpconsmonitor (estatusos integer,numerocobranzas smallint,nombre char(40),abrevia_prod char(5),num_solicitud char(20),
		fechasolic Date,status_solicitud char(2),nombre_cliente char(170),fecha_nac Date,folio char(50),fechaos char(20),dias integer,
		nombrecalle char(30),numeroextcalle char(10),numerointcalle char(10),complemento char(80),zona char(50),ciudad char(10),estado char(10),
		telefono1 CHAR(13),telefono2 CHAR(13),telefono3 CHAR(13));

		LET vTablaCreada = 1;
	ELSE
		create table bdisolic:tmpconsmonitor (estatusos integer,numerocobranzas smallint,nombre char(40),abrevia_prod char(5),num_solicitud char(20),
		fechasolic Date,status_solicitud char(2),nombre_cliente char(170),fecha_nac Date,folio char(50),fechaos char(20),dias integer,
		nombrecalle char(30),numeroextcalle char(10),numerointcalle char(10),complemento char(80),zona char(50),ciudad char(10),estado char(10),
		telefono1 CHAR(13),telefono2 CHAR(13),telefono3 CHAR(13));

		LET vTablaCreada = 1;
    END IF;
--SE AGREGA PARA INICIALIZAR LAS VARIABLES DE LA FECHA EN CASO DE QUE LLEGUEN VACIAS...HECTOR  BOJORQUEZ
	IF NVL(dtFechaIni,"") = "" THEN
		LET dtFechaIni = DATE(1);
	END IF;
	IF NVL(dtFechaFin,"") = "" THEN
		LET dtFechaFin = CURRENT;
	END IF;	

LET vTablaCreada = 1;
	--Comenzamos a llenar las variables
    FOREACH

		--Consulta que nos regresa la empresa, el numero de solicitud, numero de cliente, tipo de solicitud, numero de producto, fecha en que se dio de alta y sucursal
		--Se agrega nuevo filtro de busqueda de solicitudes de credito...Hector Bojorquez
        select c.empresa,c.num_solicitud,c.numcte,c.tipo_solicitud,c.status_solicitud,c.num_producto,NVL(c.fecha_insert,'') as fechasolic,c.sucursal
        into sempresa,vnum_solicitud,snumcte,stipo_solicitud,vstatus_solicitud,snum_producto,vfechasolic,ssucursal
        FROM bdisolic:ss_solicitudes c
		INNER JOIN bdisolic:ss_autorizacion aut ON (aut.num_solicitud= c.num_solicitud )
		AND aut.empresa= c.empresa
		AND aut.status_solicitud= c.status_solicitud
		AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
				   FROM bdisolic:ss_autorizacion aut_aux
				   WHERE aut_aux.empresa= c.empresa
				   AND aut_aux.num_solicitud= c.num_solicitud
				   AND aut_aux.status_solicitud= c.status_solicitud)
		AND aut.ejecutivo_auto= aut.ejecutivo_auto
        WHERE c.empresa = pEmpresa 
		AND c.num_solicitud = CASE WHEN(pNumCred <> "") THEN pNumCred ELSE c.num_solicitud END
		AND c.status_solicitud = CASE WHEN(pStatusSolicitud <> "") THEN pStatusSolicitud ELSE c.status_solicitud END
		AND c.tipo_solicitud = CASE WHEN(pTipoSolicitud <> "") THEN pTipoSolicitud ELSE c.tipo_solicitud END 
		AND c.numcte = CASE WHEN(pNumCte <> "") THEN pNumCte ELSE c.numcte END
		
		AND aut.causa_solicitud =  CASE WHEN(pCausa_Status <> "") THEN pCausa_Status ELSE aut.causa_solicitud END
		AND aut.fecha_entrada  BETWEEN dtFechaIni AND dtFechaFin

		--Consulta que nos regresa fecha de solicitud, fecha de impresion, folio, estatus y fecha de OS
		select nvl(fechasolicitud,'1900-01-01'),nvl(fechaimpresion,'1900-01-01'),
			CASE WHEN NVL(folio,'0') ='0' THEN '0000-0' ELSE trim(ssucursal || '-' || folio) END as folio,
			NVL(estatusos,0) estatusos,
			NVL(CASE WHEN NVL(fechaimpresion,'01-01-1900'::DATE) = '01-01-1900'::DATE OR NVL(folio,0) =0 THEN
                     CASE WHEN TO_CHAR(NVL(fechasolicitud,'01-01-1900'::DATE),'%Y/%m/%d') = '01-01-1900' THEN ''
                          ELSE TO_CHAR(fechasolicitud,'%Y/%m/%d')  END
                ELSE CASE WHEN TO_CHAR(NVL(fechaimpresion,'01-01-1900'::DATE),'%Y/%m/%d') = '01-01-1900' THEN ''
                          ELSE TO_CHAR(fechaimpresion,'%Y/%m/%d') END
                END,'') as fechaOS
		into dfechasolicitud,dfechaimpresion,vfolio,vestatusos,vfechaos
		from bdisolic:ss_osclientesupervisar
		where empresa=sempresa AND num_solicitud = vnum_solicitud
			AND NVL(fechasolicitud,CURRENT) = (SELECT NVL(MAX(fechasolicitud),CURRENT) FROM bdisolic:ss_osclientesupervisar
													WHERE empresa = sempresa AND num_solicitud = vnum_solicitud);

		--Consulta que nos regresa el nombre
	    SELECT NVL(trim(a.nombre),'') nombre
	    INTO vnombre--,vdias
	    FROM bdinteg:si_sucursales a
	    WHERE a.empresa = sempresa AND a.sucursal = ssucursal;

		--Consulta que nos regresa los dias
		SELECT  CASE WHEN NVL((today - MAX(fecha_entrada)),0) > 1000 THEN 1000 ELSE NVL((today - MAX(fecha_entrada)),0) END
		INTO vdias
		FROM bdisolic:ss_autorizacion
		WHERE empresa=sempresa and num_solicitud =  vnum_solicitud AND status_solicitud = sstatus_solicitud;

		----Consulta que nos regresa la abreviatura del producto
		SELECT i.abrevia_prod
		into vabrevia_prod
		FROM bdicred:sd_definicion b
			LEFT OUTER JOIN bdicred: sd_tipcred i ON i.empresa = b.empresa AND i.cod_tipcred = b.cod_tipcred
		WHERE b.empresa = sempresa  AND b.num_producto = snum_producto;

		--Consulta que nos regresa el nombre del cliente y la fecha de necimiento
	    SELECT TRIM(NVL(d.razon_social,' ')) || TRIM(NVL(d.nombre1, ' ')) || ' ' || TRIM(NVL(d.nombre2, ' ')) || ' ' || TRIM(NVL(d.apell_paterno, ' ')) || ' ' || TRIM(NVL(d.apell_materno, ' ')) nombre_cliente,NVL(pf.fecha_nac,'') fecha_nac
	    into vnombre_cliente,vfecha_nac
	    FROM bdinteg:si_cliente d
	        LEFT OUTER JOIN bdinteg:si_ctepf pf ON (pf.numcte = d.numcte)
	    WHERE d.numcte = snumcte;

		----Consulta que nos regresa el numero de cobranzas, nombre de callem numero exterior, numero interior, complemento, colonia, ciudad, estado, telefono 1, telefono 2 y telefono 3
	    SELECT NVL(zon.numerocobranzas,0) as numerocobranzas,/*NVL(cc.nombrecalle,'') as nombrecalle,*/
				NVL((select nombrecalle from bdinteg:si_catcalles where numerocalle = dir.numerocalle),'') as nombrecalle,
				NVL(dir.numeroextcalle,'') as numeroextcalle,
	           NVL(dir.numerointcalle,'') as numerointcalle, NVL(dir.observaciones,'') as complemento,
	           NVL(lpad(dir.numerocolonia, 3, '0') || ' ' || trim(zon.nombrezona),'') as zona,
			   NVL(cd.numerociudad || '-' || trim(cd.inicialciudad),'') as ciudad,
	           NVL(cd.numeroestado || '-' || trim(cd.inicialestado),'') as estado, NVL(t1.telefono,'') telefono1,
			   NVL(t2.telefono,'') telefono2, NVL(t3.telefono,'') telefono3
	    into vnumerocobranzas,vnombrecalle,vnumeroextcalle,vnumerointcalle,vcomplemento,vzona,vciudad,vestado, vtelefono1, vtelefono2, vtelefono3
	    FROM bdinteg:si_direcciones_actual dir
			LEFT OUTER JOIN bdinteg:si_catciudades cd ON (cd.numerociudad = dir.numerociudad)
			LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad  AND zon.numerocolonia = dir.numerocolonia)
			LEFT OUTER JOIN bdinteg:si_telefonos_actual t1 ON (dir.numcte = t1.numcte AND t1.tipo_tel = 1 AND t1.status_tel = 'A')
			LEFT OUTER JOIN bdinteg:si_telefonos_actual t2 ON (dir.numcte = t2.numcte AND t2.tipo_tel = 2 AND t2.status_tel = 'A')
			LEFT OUTER JOIN bdinteg:si_telefonos_actual t3 ON (dir.numcte = t3.numcte AND t3.tipo_tel = 3 AND t3.status_tel = 'A')
			--LEFT OUTER JOIN bdinteg:si_catcalles cc ON (dir.numerocalle = cc.numerocalle)
		WHERE (dir.numcte=snumcte AND  dir.tipo_dir = '1');  --dir.secuencia = ( select max(secuencia) from bdinteg:si_direcciones where numcte = snumcte and tipo_dir = '1' ));

		--insertamos en la tabla temporal
        insert into tmpconsmonitor
				values (vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
						vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
						vtelefono1,vtelefono2, vtelefono3);

	end FOREACH;

	--DESPLEGAMOS LA INFORMACION CONTENIDA EN LA TABLA TEMPORAL ORDENADA DEPENDIENDO EL TIPO DE ORDENAMIENTO SELECCIONADO
	IF pAgrupamiento = 'SUCURSAL' THEN
	    FOREACH
            SELECT NVL(estatusos,0) estatusos, NVL(numerocobranzas,0) numerocobranzas, NVL(nombre,'') nombre, NVL(abrevia_prod,'') abrevia_prod, NVL(num_solicitud,'') num_solicitud, NVL(fechasolic,'') fechasolic, NVL(status_solicitud,'') status_solicitud, NVL(nombre_cliente,'') nombre_cliente, NVL(fecha_nac,'') fecha_nac,
            NVL(folio,'') folio, NVL(fechaos,'') fechaos, NVL(dias,0) dias, NVL(nombrecalle,'') nombrecalle, NVL(numeroextcalle,'') numeroextcalle, NVL(numerointcalle,'') numerointcalle, NVL(complemento,'') complemento, NVL(zona,'') zona, NVL(ciudad,'') ciudad, NVL(estado,'') estado, NVL(telefono1,'') telefono1, NVL(telefono2,'') telefono2, NVL(telefono3,'') telefono3
            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3
            FROM bdisolic:tmpconsmonitor
			ORDER BY nombre, num_solicitud

            Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3 WITH RESUME;

        END FOREACH;
    ELIF pAgrupamiento = 'PRODUCTO' THEN
        FOREACH
            SELECT NVL(estatusos,0) estatusos, NVL(numerocobranzas,0) numerocobranzas, NVL(nombre,'') nombre, NVL(abrevia_prod,'') abrevia_prod, NVL(num_solicitud,'') num_solicitud, NVL(fechasolic,'') fechasolic, NVL(status_solicitud,'') status_solicitud, NVL(nombre_cliente,'') nombre_cliente, NVL(fecha_nac,'') fecha_nac,
            NVL(folio,'') folio, NVL(fechaos,'') fechaos, NVL(dias,0) dias, NVL(nombrecalle,'') nombrecalle, NVL(numeroextcalle,'') numeroextcalle, NVL(numerointcalle,'') numerointcalle, NVL(complemento,'') complemento, NVL(zona,'') zona, NVL(ciudad,'') ciudad, NVL(estado,'') estado, NVL(telefono1,'') telefono1, NVL(telefono2,'') telefono2, NVL(telefono3,'') telefono3
            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3
            FROM bdisolic:tmpconsmonitor
			ORDER BY abrevia_prod, num_solicitud
            Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3 WITH RESUME;

        END FOREACH;
    ELIF pAgrupamiento = 'CLIENTE' THEN
        FOREACH
            SELECT NVL(estatusos,0) estatusos, NVL(numerocobranzas,0) numerocobranzas, NVL(nombre,'') nombre, NVL(abrevia_prod,'') abrevia_prod, NVL(num_solicitud,'') num_solicitud, NVL(fechasolic,'') fechasolic, NVL(status_solicitud,'') status_solicitud, NVL(nombre_cliente,'') nombre_cliente, NVL(fecha_nac,'') fecha_nac,
            NVL(folio,'') folio, NVL(fechaos,'') fechaos, NVL(dias,0) dias, NVL(nombrecalle,'') nombrecalle, NVL(numeroextcalle,'') numeroextcalle, NVL(numerointcalle,'') numerointcalle, NVL(complemento,'') complemento, NVL(zona,'') zona, NVL(ciudad,'') ciudad, NVL(estado,'') estado, NVL(telefono1,'') telefono1, NVL(telefono2,'') telefono2, NVL(telefono3,'') telefono3
            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3
            FROM bdisolic:tmpconsmonitor
			ORDER BY nombre_cliente, num_solicitud

            Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3 WITH RESUME;

        END FOREACH;
    ELIF pAgrupamiento = 'STATUS' THEN
        FOREACH
            SELECT NVL(estatusos,0) estatusos, NVL(numerocobranzas,0) numerocobranzas, NVL(nombre,'') nombre, NVL(abrevia_prod,'') abrevia_prod, NVL(num_solicitud,'') num_solicitud, NVL(fechasolic,'') fechasolic, NVL(status_solicitud,'') status_solicitud, NVL(nombre_cliente,'') nombre_cliente, NVL(fecha_nac,'') fecha_nac,
            NVL(folio,'') folio, NVL(fechaos,'') fechaos, NVL(dias,0) dias, NVL(nombrecalle,'') nombrecalle, NVL(numeroextcalle,'') numeroextcalle, NVL(numerointcalle,'') numerointcalle, NVL(complemento,'') complemento, NVL(zona,'') zona, NVL(ciudad,'') ciudad, NVL(estado,'') estado, NVL(telefono1,'') telefono1, NVL(telefono2,'') telefono2, NVL(telefono3,'') telefono3
            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3
            FROM bdisolic:tmpconsmonitor
			ORDER BY status_solicitud, num_solicitud

            Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3 WITH RESUME;

        END FOREACH;
    ELIF pAgrupamiento = 'ESTADO' THEN
        FOREACH
            SELECT NVL(estatusos,0) estatusos, NVL(numerocobranzas,0) numerocobranzas, NVL(nombre,'') nombre, NVL(abrevia_prod,'') abrevia_prod, NVL(num_solicitud,'') num_solicitud, NVL(fechasolic,'') fechasolic, NVL(status_solicitud,'') status_solicitud, NVL(nombre_cliente,'') nombre_cliente, NVL(fecha_nac,'') fecha_nac,
            NVL(folio,'') folio, NVL(fechaos,'') fechaos, NVL(dias,0) dias, NVL(nombrecalle,'') nombrecalle, NVL(numeroextcalle,'') numeroextcalle, NVL(numerointcalle,'') numerointcalle, NVL(complemento,'') complemento, NVL(zona,'') zona, NVL(ciudad,'') ciudad, NVL(estado,'') estado, NVL(telefono1,'') telefono1, NVL(telefono2,'') telefono2, NVL(telefono3,'') telefono3
            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3
            FROM bdisolic:tmpconsmonitor
			ORDER BY estado, num_solicitud

            Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3 WITH RESUME;

        END FOREACH;
	ELSE ----Se agrega por modificacion hecha para el RQM 09-206 Canselaxion de solicitudes con mas de 30 días.
        FOREACH
			SELECT NVL(estatusos,0) estatusos, NVL(numerocobranzas,0) numerocobranzas, NVL(nombre,'') nombre, NVL(abrevia_prod,'') abrevia_prod, NVL(num_solicitud,'') num_solicitud, NVL(fechasolic,'') fechasolic, NVL(status_solicitud,'') status_solicitud, NVL(nombre_cliente,'') nombre_cliente, NVL(fecha_nac,'') fecha_nac,
            NVL(folio,'') folio, NVL(fechaos,'') fechaos, NVL(dias,0) dias, NVL(nombrecalle,'') nombrecalle, NVL(numeroextcalle,'') numeroextcalle, NVL(numerointcalle,'') numerointcalle, NVL(complemento,'') complemento, NVL(zona,'') zona, NVL(ciudad,'') ciudad, NVL(estado,'') estado, NVL(telefono1,'') telefono1, NVL(telefono2,'') telefono2, NVL(telefono3,'') telefono3
            INTO vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3
            FROM bdisolic:tmpconsmonitor	
			
			Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
            vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3 WITH RESUME;
		END FOREACH;
    END IF;

	--Eliminamos la tabla temporal.
    DROP TABLE bdisolic:tmpconsmonitor;
    LET vTablaCreada = 0;

	LET sCodRet='002';
	LET cErrorInfo='NO EXISTEN DATOS ALMACENADOS EN LA TABLA';
	
	Return SCodRet, vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente, vfecha_nac,
	vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado, vtelefono1, vtelefono2, vtelefono3;
END ;
END PROCEDURE ;
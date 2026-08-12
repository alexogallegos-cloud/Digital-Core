CREATE PROCEDURE "informix".sp_consultamonitor3(pUsuario CHAR(8), pEmpresa CHAR(3), pTipoSolicitud CHAR(1), pStatusSolicitud CHAR(2), pAgrupamiento CHAR(25),
												pCausa_Status CHAR(80), pFecha_Inicio CHAR(10), pFecha_Fin CHAR(10), pNumCte CHAR(9), pNumCred CHAR(12), pNombreReporte CHAR(100))
	RETURNING CHAR(5);

--Autor: Walber Castro
--27-03-2009
--Obtiene los datos de consulta para la aplicaciÃ³n Monitor de Solicitudes

--Modifico: Jose Luis Pulido
--Fecha: 15-05-2009
--Se quito la creacion de una tabla temporal para utilizar la consulta en todos los posibles casos de agrupamiento

--Modifico: Jose Luis Pulido
--Fecha:08/06/2009
--Se separo la consulta principal en varias consultas mas pequeÃ±as para reducir el costo
--Se insertan los resultados en una tabla temporal y el ordenamiento se hace sobre esta

--ModificÃ³: HÃ©ctor Manuel BojÃ³rquez Ruelas
--Fecha: 05/Abril/2011
--Se modifica para agreagr nuevos filtros de busquedas de solicitudes los cuales son:
--el tipo de status de la solicitud, fecha de inicio y fecha fin en la que la siolicitud esta en su status actual

DEFINE cErrorInfo CHAR(80);			

DEFINE cCodRet CHAR(5);				
DEFINE iCodRet INTEGER ;			

DEFINE vTablaCreada SMALLINT ;		

DEFINE vestatusos INTEGER ;			
DEFINE vnumerocobranzas SMALLINT ;	
DEFINE vnombre CHAR(40);			
DEFINE vabrevia_prod CHAR(5);		
DEFINE vnum_solicitud CHAR(20);		
DEFINE vfechasolic DATE ;			
DEFINE vstatus_solicitud CHAR(2);	
DEFINE vnombre_cliente CHAR(170);	
DEFINE vfecha_nac DATE ;			
DEFINE vfolio CHAR(50);				
DEFINE vfechaos CHAR(20) ;			
DEFINE vdias INTEGER ;				
DEFINE vnombrecalle CHAR(30);		
DEFINE vnumeroextcalle CHAR(10);	
DEFINE vnumerointcalle CHAR(10);	
DEFINE vcomplemento CHAR(80);		
DEFINE vzona char(50);				
DEFINE vciudad CHAR(10);			
DEFINE vestado CHAR(10);			
DEFINE vtelefono1 CHAR(13);			
DEFINE vtelefono2 CHAR(13);			
DEFINE vtelefono3 CHAR(13);			

DEFINE sempresa CHAR(3);			
DEFINE snumcte CHAR(20);			
DEFINE stipo_solicitud CHAR(1);		
DEFINE sstatus_solicitud CHAR(2);	
DEFINE snum_producto CHAR(4);		
DEFINE dfechasolicitud DATE ;		
DEFINE dfechaimpresion DATE ;		
DEFINE ssucursal CHAR (4);			
DEFINE dtFechaIni DATE;
DEFINE dtFechaFin DATE;

--
DEFINE bInTransaccion   BOOLEAN;
DEFINE iRow INTEGER;
DEFINE iContBloque INTEGER;
DEFINE iRecuperacion INTEGER;
DEFINE cCmd1 CHAR(2000);
DEFINE cCmd2 CHAR(500);
DEFINE iNoRegistros INTEGER;

LET cErrorInfo	= "PROCESO EXITOSO";
LET cCodRet = "00000";
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

--
LET bInTransaccion   = 'f';
LET iRow = 0;
LET iContBloque = 0;
LET iRecuperacion = 0;
LET cCmd1 = '';
LET cCmd2 = '';
LET iNoRegistros = 0;

BEGIN
    ON EXCEPTION SET iCodRet
        Let cCodRet = iCodRet;
        RETURN cCodRet;
    END Exception;
	
	ON EXCEPTION IN (-535)
		COMMIT WORK;
		BEGIN WORK;
		LET bInTransaccion = 't';                       
	END EXCEPTION WITH RESUME;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamonitor3.out';
	--TRACE ON; 

	IF NVL(dtFechaIni,"") = "" THEN
		LET dtFechaIni = DATE(1);
	END IF;
	IF NVL(dtFechaFin,"") = "" THEN
		LET dtFechaFin = CURRENT;
	END IF;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	-- OBTIENE DETALLE
	LET cCmd2 = " WHERE c.empresa = '"|| pEmpresa ||"'";
	IF pNumCte <> '' THEN	
		LET cCmd2 = ""||TRIM(cCmd2)||" AND c.numcte = '"|| pNumCte ||"'";
	END IF;
	IF pNumCred <> '' THEN	
		LET cCmd2 = ""||TRIM(cCmd2)||" AND c.num_solicitud = '"|| pNumCred ||"'";
	END IF;
	IF pStatusSolicitud <> '' THEN	
		LET cCmd2 = ""||TRIM(cCmd2)||" AND c.status_solicitud = '"|| pStatusSolicitud ||"'";
	END IF;
	IF pTipoSolicitud <> '' THEN	
		LET cCmd2 = ""||TRIM(cCmd2)||" AND c.tipo_solicitud = '"|| pTipoSolicitud ||"'";
	END IF;
	IF pCausa_Status <> '' THEN	
		LET cCmd2 = ""||TRIM(cCmd2)||" AND aut.causa_solicitud = '"|| pCausa_Status ||"'";
	END IF;
	LET cCmd2 = ""||TRIM(cCmd2)||" AND aut.fecha_entrada BETWEEN '"|| dtFechaIni ||"' AND '"|| dtFechaFin ||"'";
	
	LET cCmd1="SELECT {+INDEX (bdisolic:""informix"".ss_autorizacion idx_ss_solicitud_status_fecha)} ";
	LET cCmd1=""||TRIM(cCmd1)||" c.empresa,c.num_solicitud,c.numcte,c.tipo_solicitud,c.status_solicitud,c.num_producto,NVL(c.fecha_insert,'') as fechasolic,c.sucursal";
	LET cCmd1=""||TRIM(cCmd1)||" FROM bdisolic:ss_solicitudes c INNER JOIN bdisolic:ss_autorizacion aut ON aut.num_solicitud= c.num_solicitud";
	LET cCmd1=""||TRIM(cCmd1)||" AND aut.empresa= c.empresa AND aut.status_solicitud= c.status_solicitud";
	LET cCmd1=""||TRIM(cCmd1)||" AND aut.fecha_entrada=(SELECT {+INDEX (bdisolic:""informix"".ss_autorizacion empsolsta)} MAX(aut_aux.fecha_entrada)";
	LET cCmd1=""||TRIM(cCmd1)||" FROM bdisolic:ss_autorizacion aut_aux WHERE aut_aux.empresa= c.empresa";
	LET cCmd1=""||TRIM(cCmd1)||" AND aut_aux.num_solicitud= c.num_solicitud AND aut_aux.status_solicitud= c.status_solicitud) "||TRIM(cCmd2);
	
	PREPARE stmtId FROM TRIM(cCmd1);
	DECLARE selectQryCur CURSOR FOR stmtId;
	OPEN selectQryCur;
	FETCH selectQryCur INTO sempresa,vnum_solicitud,snumcte,stipo_solicitud,vstatus_solicitud,snum_producto,vfechasolic,ssucursal;
	
	BEGIN WORK;

	--FOREACH WITH HOLD
		
		--Consulta que nos regresa la empresa, el numero de solicitud, numero de cliente, tipo de solicitud, numero de producto, fecha en que se dio de alta y sucursal
		--Se agrega nuevo filtro de busqueda de solicitudes de credito...Hector Bojorquez		
		WHILE(SQLCODE == 0)	
			LET iNoRegistros = iNoRegistros + 1;
			
			--Consulta que nos regresa fecha de solicitud, fecha de impresion, folio, estatus y fecha de OS
			FOREACH
			SELECT {+INDEX (bdisolic:"informix".ss_osclientesupervisar idx_ss_osclientesupervisar)} 
				FIRST 1 
				nvl(fechasolicitud,'1900-01-01'),nvl(fechaimpresion,'1900-01-01'),
				CASE WHEN NVL(folio,'0') ='0' THEN '0000-0' ELSE trim(ssucursal || '-' || folio) END as folio,
				NVL(estatusos,0) estatusos,
				NVL(CASE WHEN NVL(fechaimpresion,'01-01-1900'::DATE) = '01-01-1900'::DATE OR NVL(folio,0) =0 THEN
						 CASE WHEN TO_CHAR(NVL(fechasolicitud,'01-01-1900'::DATE),'%Y/%m/%d') = '01-01-1900' THEN ''
							  ELSE TO_CHAR(fechasolicitud,'%Y/%m/%d')  END
					ELSE CASE WHEN TO_CHAR(NVL(fechaimpresion,'01-01-1900'::DATE),'%Y/%m/%d') = '01-01-1900' THEN ''
							  ELSE TO_CHAR(fechaimpresion,'%Y/%m/%d') END
					END,'') as fechaOS
				INTO dfechasolicitud,dfechaimpresion,vfolio,vestatusos,vfechaos
			--fechasolicitud,fechaimpresion,folio,estatusos
			--INTO dfechasolicitud,dfechaimpresion,vfolio,vestatusos
			FROM bdisolic:ss_osclientesupervisar
			where empresa=sempresa AND num_solicitud = vnum_solicitud
			ORDER BY fechasolicitud DESC
				--AND NVL(fechasolicitud,CURRENT) = (SELECT NVL(MAX(fechasolicitud),CURRENT) FROM bdisolic:ss_osclientesupervisar
				--										WHERE empresa = sempresa AND num_solicitud = vnum_solicitud);
			/*
			LET dfechasolicitud = nvl(dfechasolicitud,'1900-01-01');
			LET dfechaimpresion = nvl(dfechaimpresion,'1900-01-01');
			
			IF NVL(vfolio,'0') = '0' THEN
				LET vfolio = '0000-0';
			ELSE
				LET vfolio = trim(ssucursal || '-' || vfolio);
			END IF;
			
			LET vestatusos = NVL(vestatusos,0);
			
			IF dfechaimpresion = '1900-01-01'::DATE OR vfolio = '0000-0' THEN
				IF dfechasolicitud = '1900-01-01'::DATE THEN
					LET vfechaos = '';
				ELSE
					LET vfechaos = TO_CHAR(dfechasolicitud,'%Y/%m/%d');
				END IF;
			ELSE
				IF dfechaimpresion = '1900-01-01'::DATE THEN
					LET vfechaos = '';
				ELSE
					LET vfechaos = TO_CHAR(dfechaimpresion,'%Y/%m/%d');
				END IF;
			END IF;
			*/
			END FOREACH;
			
			--Consulta que nos regresa el nombre
			SELECT NVL(trim(a.nombre),'') nombre
			INTO vnombre--,vdias
			FROM bdinteg:si_sucursales a
			WHERE a.empresa = sempresa AND a.sucursal = ssucursal;

			--Consulta que nos regresa los dias
			SELECT {+INDEX (bdisolic:"informix".ss_autorizacion empsolsta)}
			CASE WHEN NVL((today - MAX(fecha_entrada)),0) > 1000 THEN 1000 ELSE NVL((today - MAX(fecha_entrada)),0) END
			INTO vdias
			FROM bdisolic:ss_autorizacion
			WHERE empresa=sempresa and num_solicitud =  vnum_solicitud AND status_solicitud = sstatus_solicitud;

			----Consulta que nos regresa la abreviatura del producto
			SELECT {+INDEX (bdicred:"informix".sd_definicion idx_sd_definicionb)}
			i.abrevia_prod
			INTO vabrevia_prod
			FROM bdicred:sd_definicion b
				LEFT OUTER JOIN bdicred: sd_tipcred i ON i.empresa = b.empresa AND i.cod_tipcred = b.cod_tipcred
			WHERE b.empresa = sempresa  AND b.num_producto = snum_producto;

			--Consulta que nos regresa el nombre del cliente y la fecha de necimiento
			SELECT TRIM(NVL(d.razon_social,' ')) || TRIM(NVL(d.nombre1, ' ')) || ' ' || TRIM(NVL(d.nombre2, ' ')) || ' ' || TRIM(NVL(d.apell_paterno, ' ')) || ' ' || TRIM(NVL(d.apell_materno, ' ')) nombre_cliente,NVL(pf.fecha_nac,'') fecha_nac
			INTO vnombre_cliente,vfecha_nac
			FROM bdinteg:si_cliente d
				LEFT OUTER JOIN bdinteg:si_ctepf pf ON (pf.numcte = d.numcte)
			WHERE d.numcte = snumcte;

			----Consulta que nos regresa el numero de cobranzas, nombre de callem numero exterior, numero interior, complemento, colonia, ciudad, estado, telefono 1, telefono 2 y telefono 3
			SELECT {+INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_ctetpo)}
			{+INDEX (bdinteg:"informix".si_catzonas idx_catzon1_ava)} 
			{+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_cte_cons)}
			{+INDEX (bdinteg:"informix".si_catciudades idx_ciudad)}
			NVL(zon.numerocobranzas,0) as numerocobranzas,/*NVL(cc.nombrecalle,'') as nombrecalle,*/
					NVL((select nombrecalle from bdinteg:si_catcalles where numerocalle = dir.numerocalle),'') as nombrecalle,
					NVL(dir.numeroextcalle,'') as numeroextcalle,
				   NVL(dir.numerointcalle,'') as numerointcalle, NVL(dir.observaciones,'') as complemento,
				   NVL(lpad(dir.numerocolonia, 3, '0') || ' ' || trim(zon.nombrezona),'') as zona,
				   NVL(cd.numerociudad || '-' || trim(cd.inicialciudad),'') as ciudad,
				   NVL(cd.numeroestado || '-' || trim(cd.inicialestado),'') as estado, NVL(t1.telefono,'') telefono1,
				   NVL(t2.telefono,'') telefono2, NVL(t3.telefono,'') telefono3
			INTO vnumerocobranzas,vnombrecalle,vnumeroextcalle,vnumerointcalle,vcomplemento,vzona,vciudad,vestado, vtelefono1, vtelefono2, vtelefono3
			FROM bdinteg:si_direcciones_actual dir
				LEFT OUTER JOIN bdinteg:si_catciudades cd ON (cd.numerociudad = dir.numerociudad)
				LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad  AND zon.numerocolonia = dir.numerocolonia)
				LEFT OUTER JOIN bdinteg:si_telefonos_actual t1 ON (dir.numcte = t1.numcte AND t1.tipo_tel = 1 AND t1.status_tel = 'A')
				LEFT OUTER JOIN bdinteg:si_telefonos_actual t2 ON (dir.numcte = t2.numcte AND t2.tipo_tel = 2 AND t2.status_tel = 'A')
				LEFT OUTER JOIN bdinteg:si_telefonos_actual t3 ON (dir.numcte = t3.numcte AND t3.tipo_tel = 3 AND t3.status_tel = 'A')
			WHERE (dir.numcte=snumcte AND  dir.tipo_dir = '1');  --dir.secuencia = ( select max(secuencia) from bdinteg:si_direcciones where numcte = snumcte and tipo_dir = '1' ));
			
			INSERT INTO bdicnweb:"informix".sw_cnt_detallemonitorsol (estatusos,numerocobranzas,nombre,abrevia_prod,num_solicitud,fechasolic,status_solicitud,nombre_cliente,
			fecha_nac,folio,fechaos,dias,nombrecalle,numeroextcalle,numerointcalle,complemento,zona,ciudad,estado,
			telefono1,telefono2,telefono3,nombreregion,num_cliente,usuario_insert,nombre_reporte,fecha_insert)			
			VALUES(vestatusos, vnumerocobranzas, vnombre, vabrevia_prod, vnum_solicitud, vfechasolic, vstatus_solicitud, vnombre_cliente,
			vfecha_nac, vfolio, vfechaos, vdias, vnombrecalle, vnumeroextcalle, vnumerointcalle, vcomplemento, vzona, vciudad, vestado,
			vtelefono1,vtelefono2, vtelefono3,"","",pUsuario,pNombreReporte,CURRENT);
			
			LET iRecuperacion = iRecuperacion + 1;		

			LET iContBloque = iContBloque + 1;
			IF iContBloque = 5000 THEN
				LET iContBloque = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		
			FETCH selectQryCur INTO sempresa,vnum_solicitud,snumcte,stipo_solicitud,vstatus_solicitud,snum_producto,vfechasolic,ssucursal;
		END WHILE;
		
		CLOSE selectQryCur;
		FREE selectQryCur;
		FREE stmtId;
		
		LET cCmd1 = '';
		LET cCmd2 = '';
		
	--END FOREACH;
	COMMIT WORK;
 
	IF bInTransaccion = 't' THEN
		BEGIN WORK;
	END IF;
	
	IF iRecuperacion = 0 THEN
		LET cCodRet = '00017';
	END IF;
	
	RETURN cCodRet;
			
END;
END PROCEDURE 

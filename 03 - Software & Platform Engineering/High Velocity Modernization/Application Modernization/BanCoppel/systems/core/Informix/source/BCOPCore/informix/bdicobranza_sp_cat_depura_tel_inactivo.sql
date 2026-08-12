CREATE PROCEDURE "informix".sp_cat_depura_tel_inactivo()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cTel				CHAR(13);
DEFINE cNumcte    CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumcte = '';


BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_cat_depura_tel_inactivo.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH 		
    
    SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} DISTINCT(telefono)
		INTO cTel
		FROM bdicobranza:cb_telefonos
		WHERE estatus = 'AC'
     AND fecha_insert >= '01-01-1900'  	
     

		IF EXISTS( SELECT 1 FROM bdicobranza:"informix".cb_registro_llamadas a	INNER	JOIN 
					bdicobranza:"informix".cb_cat_tipo_resultado b ON (a.codigo_resultado = b.codigo_resultado) 
					WHERE a.telefono= cTel AND b.genera_inactivacion = 'V' AND a.veces_marcado >= b.num_marca_inactiva) 
					THEN

						UPDATE bdicobranza:"informix".cb_telefonos SET estatus = 'IN' WHERE telefono = TRIM(cTel);
	
		ELSE
			CONTINUE FOREACH;
		END IF;
		
	END FOREACH;	
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Marca los telefonos como inactivos',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110608.1851';

CREATE PROCEDURE "informix".sp_generatelinactivos()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        		CHAR(5); 
DEFINE iSqlErr      		INTEGER;
DEFINE cTel					CHAR(13);
DEFINE cNumCte				CHAR(20);
DEFINE cFechaHoy			CHAR(10);
DEFINE cRuta				CHAR(100);
DEFINE cNombreCtes			CHAR(100);
DEFINE cNombreTels			CHAR(100);			
DEFINE cStatus				CHAR(2);
DEFINE cDescripcionStatus	CHAR(100);
DEFINE cDescTpoTel			CHAR(30);
DEFINE cDescripcionResult	CHAR(50);
DEFINE sTpoTel				SMALLINT;
DEFINE sNumMarcados			SMALLINT;
DEFINE cEstatus				CHAR(2); 
DEFINE sCodResultado		SMALLINT;
DEFINE vsSQL1 				CHAR(300);
DEFINE cSql3 				CHAR(900);
DEFINE vsSQL2				CHAR(300);
DEFINE cSql					CHAR(1500);
DEFINE DescContac			CHAR(14);
DEFINE cNombreTels2			CHAR(100);
DEFINE cNombreCtes2			CHAR(100);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumCte				= '';
LET cFechaHoy			= '';
LET  cRuta				= '';
LET cNombreCtes			= '';
LET cNombreTels			= '';	
LET cStatus				= '';
LET cDescripcionStatus	= '';
LET cDescTpoTel			= '';
LET cDescripcionResult	= '';
LET sTpoTel				= 0;
LET sNumMarcados		= 0;
LET cEstatus			= '';
LET sCodResultado		= 0;
LET vsSQL1  = '';
LET cSql	= '';
LET vsSQL2	= '';
LET cSql3	= '';
LET DescContac = '';
LET cNombreTels2	= '';
LET cNombreCtes2	= '';
		
BEGIN

ON EXCEPTION SET iSqlErr
	IF EXISTS (SELECT tabname  FROM sysmaster:"informix".systabnames where tabname = 'tmpctescat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmpctescat;
    END IF;
	
	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmptelscat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmptelscat;
    END IF;
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_generatelinactivos.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;	

	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmpctescat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmpctescat;
    END IF;
	
	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmptelscat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmptelscat;
    END IF;

	
	CREATE TABLE "informix".tmpctescat
	( cliente   CHAR(20),
	  Status	CHAR(14));
	 
	CREATE TABLE "informix".tmptelscat
	( cliente   CHAR(20),
	  telefono	CHAR(13),
	  tipo_tel	CHAR(30),
	  resultado	CHAR(40),
	  veces_marcado	SMALLINT,
	  status	CHAR(10));	 	  

	--Ruta archivo
	SELECT valor_alfabetico
	INTO	cRuta
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 21;
	
	--Nombre para el archivo de Clientes
	SELECT valor_alfabetico
	INTO cNombreCtes
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 22;
	
	--Nombre para el archivo de Telefonos
	SELECT valor_alfabetico
	INTO cNombreTels
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 23;
	
	SELECT fecha_hoy
	INTO cFechaHoy
	FROM bdicred:"informix".sd_fechas
  WHERE empresa = '001';	
	
	--Para clientes	
	--Inactivo		
	LET DescContac= 'NO CONTACTABLE';
	
	INSERT INTO  "informix".tmpctescat 
	SELECT distinct (tel.numcte), DescContac FROM bdicobranza:"informix".cb_telefonos tel
	INNER JOIN  bdisitesp:"informix".se_ctessitespcred  esp	ON ( tel.numcte = esp.numcte) WHERE esp.situacion= 'T'
	AND esp.causa = 1 AND tel.estatus= 'IN';			
	LET DescContac= '';
		
	
	--Activo
	LET DescContac= 'CONTACTABLE';
	INSERT INTO  "informix".tmpctescat 
	SELECT distinct(numcte), DescContac FROM bdicobranza:"informix".cb_telefonos WHERE estatus= 'AC';
		
	
	--Para Telefonos
	FOREACH 
		
		SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} distinct (numcte), telefono, tipo_telefono, numvecesmarcado, estatus, codigo_resultado
		INTO cNumCte, cTel, sTpoTel, sNumMarcados, cEstatus, sCodResultado
		FROM bdicobranza:"informix".cb_telefonos
		WHERE empresa = '001'
     AND estatus in('AC','IN', 'CA')
     AND fecha_insert >= '01-01-1900'	
     	
		
		SELECT descripcion
		INTO	cDescTpoTel
		FROM bdicobranza:"informix".cb_tipo_telefono
		WHERE empresa = '001'
      AND tipo_telefono = sTpoTel;
		
		SELECT  descripcion  
		INTO cDescripcionResult
		FROM bdicobranza:"informix".cb_cat_tipo_resultado
		WHERE codigo_resultado =NVL(sCodResultado,0);
		
		IF cEstatus = 'AC' THEN
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 1;
		
		ELIF cEstatus = 'IN' THEN
			
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 2;
		ELIF cEstatus = 'CA'	THEN
		
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 3;
			
		END IF;		
		
		INSERT INTO "informix".tmptelscat (cliente, telefono, tipo_tel, resultado, veces_marcado, status)
		VALUES (cNumCte, cTel, cDescTpoTel, cDescripcionResult, sNumMarcados, cDescripcionStatus);
		
	END FOREACH; 
	
	LET cNombreCtes =  TRIM(cNombreCtes)||lpad(DAY(cFechaHoy),2,0)||lpad(MONTH(cFechaHoy),2,0)||lpad(YEAR(cFechaHoy),4,0);
	LET cNombreTels =  TRIM(cNombreTels)||lpad(DAY(cFechaHoy),2,0)||lpad(MONTH(cFechaHoy),2,0)||lpad(YEAR(cFechaHoy),4,0);	
	
	--GENERA ARCHIVO CLIENTES
	let cRuta = TRIM(cRuta);
	let vsSQL1 = 	'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreCtes) ||"Temporal.sql" ;
	LET vsSQL1 = TRIM(vsSQL1);
	let cSql3 = ' SELECT cliente, status  FROM bdicobranza:"informix".tmpctescat;  '  ;
	LET vsSQL2 = ' " >' || TRIM(cRuta ) || 'ConsultaCtesCAT.sql';
	LET cSql = TRIM(vsSQL1) ||" "|| TRIM(cSql3) || "" || vsSQL2;
	SYSTEM cSql;
	LET vsSQL1 = "";
	LET vsSQL1 = "dbaccess bdicobranza " || trim(cRuta) ||  "ConsultaCtesCAT.sql";
	SYSTEM vsSQL1;
	LET cNombreCtes2 = "ConsultaCtesCAT.sql";
	
	LET vsSQL1 = "";
	LET vsSQL1 = "sed 's/|$//g' " || trim(cRuta) || TRIM(cNombreCtes) ||"Temporal.sql" || " > " || trim(cRuta) || TRIM(cNombreCtes) ||".xls" ;
	SYSTEM vsSQL1;	

	LET vsSQL1 = '';
	LET vsSQL1 = "rm -rf " || trim(cRuta) || "*.sql";
	SYSTEM vsSQL1;
	
	LET vsSQL1  = '';
	LET cSql	= '';
	LET vsSQL2	= '';
	LET cSql3	= '';	
	
	--GENERA ARCHIVO TELEFONOS
	
	let cRuta = TRIM(cRuta);
	let vsSQL1 = 	'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreTels) ||"Temporal.sql" ;
	LET vsSQL1 = TRIM(vsSQL1);
	let cSql3 = ' SELECT cliente, telefono, tipo_tel, resultado, veces_marcado, status FROM bdicobranza:"informix".tmptelscat;  '  ;
	LET vsSQL2 = ' " >' || TRIM(cRuta ) || 'ConsultaTelCAT.sql';
	LET cSql = TRIM(vsSQL1) ||" "|| TRIM(cSql3) || "" || vsSQL2;
	SYSTEM cSql;
	LET vsSQL1 = "";
	LET vsSQL1 = "dbaccess bdicobranza " || trim(cRuta) ||  "ConsultaTelCAT.sql";
	SYSTEM vsSQL1;
	LET cNombreTels2 = "ConsultaTelCAT.sql";
	
	LET vsSQL1 = "";
	LET vsSQL1 = "sed 's/|$//g' " || trim(cRuta) || TRIM(cNombreTels) ||"Temporal.sql" || " > " || trim(cRuta) || TRIM(cNombreTels) ||".xls" ;
	SYSTEM vsSQL1;	

	LET vsSQL1 = '';
	LET vsSQL1 = "rm -rf " || trim(cRuta) || "*.sql";
	SYSTEM vsSQL1;

	--ELIMINA TABLAS
	DROP TABLE bdicobranza:"informix".tmptelscat;
	DROP TABLE bdicobranza:"informix".tmpctescat;
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Genera 2 archivos, uno de clientes con los numeros de ctes y status, y otro de telefonos, con ctes, tel, tpo tel, resultado, veces marcado y estatus',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110620.1755';

create procedure "informix".sp_inserta_mensaje(pempresa  char(3), ptipomensaje smallint, pnumvencido  smallint, ptipomail smallint)
returning VARCHAR(6);
-- execute procedure "informix".sp_inserta_mensaje('001',5,2,0)

DEFINE pidtipomensaje	char (2);
DEFINE pnumvencidos     smallint;
DEFINE pnumcte          char(20);
DEFINE pnumcredito      char(20);
DEFINE pnombre          char(60);
DEFINE pemail           char (60);
DEFINE pmonto           decimal(18,2);
DEFINE psaldototal      decimal(18,2);
DEFINE ppagominimo      decimal(18,2);
DEFINE pmontoconvenio   decimal(18,2);
DEFINE pfechahoy		date;
DEFINE pvalor			smallint;
DEFINE vfecha			datetime year to second;
DEFINE pfecha			datetime year to second;
DEFINE pfechaprimercons datetime year to second;
DEFINE pfreestructu datetime year to second;
DEFINE cProceso  		char(4);
DEFINE cCod_ret  		smallint;
DEFINE cMensaje  		char (100);
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET        VARCHAR(6);
DEFINE P_MENSAJE        VARCHAR(80);
DEFINE v_longitud       INTEGER;  
DEFINE v_cuenta			INTEGER;  
DEFINE v_subcadena		CHAR(1);  
DEFINE v_mail_incorrecto CHAR(1);  
LET v_longitud          = 0;  
LET v_cuenta            = 1;   
LET v_subcadena         = ''; 

BEGIN

    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
            RETURNING P_COD_RET;
        RETURN P_COD_RET;
    END exception;
	
 --SET DEBUG FILE TO "/informix/Elizabeth/inserta_mensaje.out";
 --TRACE ON;

  let P_COD_RET = '111111';
  let cCod_ret = '';
  let cMensaje = '';
  let cProceso = '2030';
  let pmonto = 0;
  let vfecha = to_char(today, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S');
 
  --valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomensaje, '') = '' THEN
        LET cCod_Ret= '106007';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (pnumvencido, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomail, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING P_COD_RET;
			
	Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa;
	
    select id_tipo_mensaje
    into pidtipomensaje
    from bdicobranza:cb_mail_configuracion
    where tipo_mensaje = ptipomensaje
    and num_vencidos = pnumvencido
	and tipo_mail = ptipomail;

    DELETE FROM bdinteg:si_mensajes_enviar WHERE date(f_mensaje) = pfechahoy and id_tipo_mensaje = pidtipomensaje;
	
	--valida el tipo de mensaje para la busqueda  en el where del select mas adelante
	if (ptipomensaje = 1 and pnumvencido <=5) then -- obtiene los meses de vencidos para mensajes de mora
		let pvalor=pnumvencido;
	end if;
	if (ptipomensaje = 1 and ptipomail >= 30) then --obtiene el valor para tipo de mensaje para mensajes de remanente y compra mayor a $5,000
		let pvalor=ptipomail;
	end if;
	if (ptipomensaje = 3) then--obtiene el valor para tipo de mensaje para convenios
		let pvalor = ptipomail;
	end if;
	if (ptipomensaje = 2) then--obtiene el valor para mensajes a venta de cartera
		let pvalor = 5;
	end if;
	if (ptipomensaje = 4 and pnumvencido > 0 ) then --valor para mensajes en reestructura moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 4 and pnumvencido = 0  and ptipomail = 0) then --valor para mensajes en reestructura preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido <= 2 and ptipomail = 0) then --valor para mensajes en prestamo P moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then --valor para mensajes en prestamo P preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then --valor para mensajes en prestamo P autorizacion
		let pvalor = ptipomail;
	end if;
	
foreach
			
    select a.numcte, a.num_credito, a.email,a.pago_minimo,a.saldo_total
		, a.monto_convenio,
		to_char(a.fecha_convenio, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_convenio ,
		to_char(a.fecha_compac, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_compac , to_char(a.fecha_primercons, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_primercons,
		trim (e.apell_paterno) || ' ' || trim ( e.apell_materno) || ' ' || trim (e.nombre1) || ' ' || trim (e.nombre2) as nombre_cliente 
    into pnumcte,pnumcredito,pemail,ppagominimo,psaldototal,pmontoconvenio,pfreestructu,
		 pfecha,pfechaprimercons ,pnombre  
    from bdicobranza:cb_mail_cliente a, bdinteg:si_cliente  e 
    where a.empresa = e.empresa
		and a.numcte = e.numcte
		and a.tipo_mensaje = ptipomensaje
		and a.pagos_vencidos = pvalor --se obtine de las validaciones anteriores
		and  a.fecha_insert = pfechahoy
	--montos
	if (ptipomensaje = 1) then let pmonto = ppagominimo; end if;
    if (ptipomensaje = 3) then let pmonto = pmontoconvenio; end if;
	if (ptipomensaje = 2) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 4) then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0)  then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10)  then let pmonto = psaldototal; end if;
	--fechas
	if (ptipomensaje = 3) then let vfecha = pfecha; end if;
	if (ptipomensaje = 1 and ptipomail = 30) then let vfecha = pfechaprimercons; END IF;
	if (ptipomensaje = 4 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then let vfecha = pfreestructu; end if;
	
	LET v_longitud = length(pemail);
			FOR v_cuenta = 1 to v_longitud
				  LET v_subcadena = SUBSTR(pemail,v_cuenta,1);
					IF v_subcadena  in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',
                                 'U','V','W','X','Y','Z',
                                 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
                                 'u','v','w','x','y','z',
                                 '1','2','3','4','5','6','7','8','9','0','@','_','-','.') THEN
						LET v_mail_incorrecto = 'F'; 
					-- INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					--	VALUES(current, pnumcte, pnumcredito, pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
					
						CONTINUE FOR;
					ELSE
						LET v_mail_incorrecto   = 'T';
				    EXIT FOR;
				    END IF;
			END FOR
			
				IF v_mail_incorrecto = 'T' THEN
					INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					VALUES(current, pnumcte, pnumcredito,/* null,null,*/pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
				else
					insert into bdinteg:"informix".si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente,
																	  monto_reportar, id_tipo_mensaje, enviado )
					values(vfecha, pnumcte, pnumcredito,/*null,null,*/ pnombre,pemail, pmonto,pidtipomensaje,'F');
				END IF;
			
end foreach
   let P_COD_RET = '000000';

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
end
RETURN P_COD_RET;
END PROCEDURE;
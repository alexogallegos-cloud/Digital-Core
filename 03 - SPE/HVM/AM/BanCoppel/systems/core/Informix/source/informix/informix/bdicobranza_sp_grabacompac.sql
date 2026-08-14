CREATE PROCEDURE "informix".sp_grabacompac(
				pempresa char(3),
				pempleado_captura int,
				pnumcliente char(20),
        pnumcuenta char(20),
				ptipo_compac char(1),
				pplazo char(2),
				pimporte decimal,
				porigen	smallint,
				pefectuo_compac int,
				psucursal char(4),
        pfechasistema date,
        pquien_convenio char(15),
        pnom_convenio char(40),
        pemail char(60),
        preferenciacoppel char(20),
        pnombre_efectuo char(40)
) returning char(5);

define v_codret char(5);
define vcod_ret char(5);
define v_sqlerr integer;
define v_isamerr integer;
define v_pnumcliente char(20);
define v_Error char(20);
define vv_cod_ret char(5);
define vActivo char(1);
---------------------------------------------------
DEFINE cCodRet_1         CHAR(6);
DEFINE cMensajeRet_1     CHAR(80);
DEFINE dImpMensual       DECIMAL(18,2);
DEFINE dIntVdo           DECIMAL(18,2);
DEFINE dIntMoratorio     DECIMAL(18,2);
DEFINE dIvaIntVdo        DECIMAL(18,2);
DEFINE dPagosVdos        DECIMAL(18,2);
DEFINE dIvaIntMoratorio  DECIMAL(18,2);
DEFINE dIntMes_1         DECIMAL(18,2);
DEFINE dIvaIntMes_1      DECIMAL(18,2);
DEFINE dIntVig           DECIMAL(18,2);
DEFINE dIvaIntVig        DECIMAL(18,2);
DEFINE vcantReg		     SMALLINT;
---------------------------------------------------
let v_codret = "000";
let vv_cod_ret = "000";
let vcod_ret ="000";
let v_sqlerr = 0;
let v_isamerr = 0;
Let v_Error = '';
let v_pnumcliente = lpad(trim(pnumcliente), 9, '0');
let vActivo = '1';
---------------------------------------------------
LET cCodRet_1         = '';
LET cMensajeRet_1     = '';
LET dImpMensual		  = 0;
LET dIntVdo           = 0;
LET dIntMoratorio     = 0;
LET dIvaIntVdo        = 0;
LET dPagosVdos        = 0;
LET dIvaIntMoratorio  = 0;
LET dIntMes_1         = 0;
LET dIvaIntMes_1      = 0;
LET dIntVig           = 0;
LET dIvaIntVig        = 0;
LET vcantReg          = 0;
---------------------------------------------------

--SET DEBUG FILE TO "/aplicacion/Carlos/sp_grabacompac.out";
--TRACE ON;

--31/10/2008
--CAMBIO:
--Se comento la parte donde se valida si viene la referencia coppel ya que no es obligatoria.
--WALBERTO CASTRO
--19/11/2009
--Se agrego el campo CANAL a la tabla cb_compac_error para que el se guarde el registro de error del procedimiento.
--Armida Pazos

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 3;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         return v_codret;
      end if;
   end exception;

   --CHECAR VALORES NULOS
   IF pempresa IS NULL OR Trim(pempresa) = "" THEN
	   LET v_codret = "20001";
   ELIF pempleado_captura IS NULL THEN
	   LET v_codret = "20002";
   ELIF v_pnumcliente IS NULL OR Trim(v_pnumcliente) = "" THEN
	   LET v_codret = "20003";
   ELIF pnumcuenta IS NULL OR Trim(pnumcuenta) = "" THEN
	   LET v_codret = "20004";
   ELIF ptipo_compac IS NULL OR Trim(ptipo_compac) = "" THEN
	   LET v_codret = "20005";
   ELIF pplazo IS NULL OR Trim(pplazo) = "" THEN
	   LET v_codret = "20006";
   ELIF pimporte IS NULL THEN
	   LET v_codret = "20007";
   ELIF pimporte = 0 THEN --A.L.L valida que el iporte capturado no sea cero
	   LET v_codret = "20007";
   ELIF porigen IS NULL THEN
	   LET v_codret = "20008";
   ELIF pefectuo_compac IS NULL THEN
	   LET v_codret = "20009";
   ELIF psucursal IS NULL OR Trim(psucursal) = "" THEN
	   LET v_codret = "20010";   

   ELIF pquien_convenio IS NULL OR Trim(pquien_convenio) = "" THEN
	   LET v_codret = "20011";

   ELIF pnom_convenio IS NULL OR Trim(pnom_convenio) = "" THEN
	   --LET v_codret = "20012";
	   LET v_codret = "012";
	   RETURN v_codret;
 --IF preferenciacoppel IS NULL OR Trim(preferenciacoppel) = "" THEN
--	   LET v_codret = "014";
--	   RETURN v_codret;
   --END IF;

   ELIF pfechasistema IS NULL THEN
	    LET v_codret = "20013";
	

   ELIF pnombre_efectuo IS NULL OR Trim(pnombre_efectuo) = "" THEN
	    LET v_codret = "20014";
	

   --CHECAR SI EXISTEN LAS TABLAS
--jom   ELIF  NOT EXISTS (SELECT tabname FROM bdicobranza:systables WHERE tabname = 'cb_compac') THEN
--jom		LET v_codret = "20015";
		

--jom   ELIF NOT EXISTS (SELECT tabname FROM bdicobranza:systables WHERE tabname = 'cb_compac_his') THEN
--jom		LET v_codret = "20016";		
   END IF;
 
   ---Verificar si existe un compromiso vigente (20110124)
    CALL bdicobranza:"informix".sp_consultarcompromisovigente(pempresa, pnumcuenta)
    RETURNING vv_cod_ret, vActivo;
	
--jom	if (porigen = 4)	then
--jom		if (v_codret in("20011","20012","20014")) then
--jom			LET v_codret = '000';  
--jom		end if;
--jom	end if;
    
   IF v_codret = '000' and vActivo = '0' THEN
   
		IF porigen = 3 THEN
		
			EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(pEmpresa, pNumCuenta) 
			INTO cCodRet_1, cMensajeRet_1, dImpMensual, dIntVdo,
			dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio,
			dIntMes_1, dIvaIntMes_1, dIntVig, dIvaIntVig;
		
			insert into bdicobranza:cb_compac
				(empresa, sucursal, origen, empleado_captura, numcliente,
				numcuenta, plazo, importe, tipo_compac, activo,
				flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, hora_insert, pago_minimo)
			values (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, current,dImpMensual);
		
				 UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1,
                                                      monto_ult_convenio = pimporte,
                                                      fecha_ult_convenio = pfechasistema 	
				 WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
				 LET vCantReg = DBINFO("sqlca.sqlerrd2");

				 if vCantReg = 0 then
				    UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				    WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 end if;
		
		ELSE
   
			insert into bdicobranza:cb_compac
				 (empresa, sucursal, origen, empleado_captura, numcliente,
			numcuenta, plazo, importe, tipo_compac, activo,
			flag_pago, efectuo_compac, nombre_efectuo,
				 fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, hora_insert)
			 values (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
						pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
						 '0', pefectuo_compac, pnombre_efectuo,
						 pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, current);
			
				 UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1,
                                                      monto_ult_convenio = pimporte,
                                                      fecha_ult_convenio = pfechasistema 	
				 WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
				 LET vCantReg = DBINFO("sqlca.sqlerrd2");

				 if vCantReg = 0 then
				    UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				    WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 end if;			

		END IF;
  ELSE

  	
	
	  if vActivo = '1' then
	     LET v_Error = 'SUCURSAL';
         LET v_codret = "20017"; 
	  end if;

      IF porigen = 3 THEN 
	   	LET v_Error = 'CATONLINE';
        let v_codret = "000";
	  END IF;
	
		insert into bdicobranza:"informix".cb_compac_error
				(empresa, sucursal, origen, empleado_captura, numcliente,
	            numcuenta, plazo, importe, tipo_compac, activo,
	            flag_pago, efectuo_compac, nombre_efectuo,
				fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, codigo_error, canal, hora_insert)
		values (pempresa, psucursal, porigen, pempleado_captura,v_pnumcliente,
				pnumcuenta, pplazo, pimporte, ptipo_compac, '1',
				'0', pefectuo_compac, pnombre_efectuo,
				pfechasistema ,TODAY, pquien_convenio, pnom_convenio, pemail, preferenciacoppel, v_codret, v_Error, current);
  END IF;

--  if v_codret = '000' then  
--    execute procedure bdicred:sp_graba_indicador(pempresa, pnumcuenta,pimporte,'' , pfechasistema, 5) into vcod_ret;
--  end if;
  return v_codret;
end;
end procedure
DOCUMENT
'Fecha ModificaciÃ³n: 2013/11/29',
'Autor: Marco A. Campos',
'DESCRIPCION: Realizar validaciÃ³n de Nombre EfectuÃ³',
'Fecha Modificación: 2018/08/30',
'Autor: Marco A. Campos',
'DESCRIPCION: Actualización indicadores TRIAD';

CREATE PROCEDURE "informix".sp_cat_gp_pp_genarchbase(pempresa CHAR(3), 
                                                    ptipocobranza CHAR(1))
RETURNING CHAR(6);
--______________________________________________________________________________________________________________________________________________________________
-- Creado por: Abrham López López. Fecha: 01/11/2011. Descripción: Proceso para la generación del archivo ivr preventivo para prestamo personal
-- BT = Vencido, AA = Vigente, BA = Transitorio, FF = Liquidado, EX = IN = . Base de Datos: BDICOBRANZA. ptipocobranza = 'E'
-- Modificado por: MAHR. Abril 2012. Se cambia a sp_inserta_bitacora_cob para la correcta insercion de la bitacora.
--Modificado por: Abrham Lopez L. Mayo 08 de 2012
--Se mofica sp para agregarle la consulta que genera archivo IVR de Restructura.
--Modificado por: Abrham Lopez L. junio 05 de 2014
--Se mofica sp para eliminar el prefijo en los numeros celular.
-- execute PROCEDURE "informix".sp_cat_gp_pp_genarchbase('001', 'E')
/*________________________________________________________________________________________________________________________________________________*/

--Declaración de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_RetIB           CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE vproceso				CHAR(4);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(1500);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE vdia				    DATE;
DEFINE vhora				CHAR(8);
DEFINE ctipocampania        CHAR(1);
DEFINE pFecha               DATE;
define cfecha_insert        DATE;
DEFINE vTipoCobranza        CHAR(1);
DEFINE cNum_ProdCampa		CHAR(4);
DEFINE vFecha_insert		DATE;
DEFINE vcount				INTEGER;
DEFINE vnum_param			INTEGER;
DEFINE vregistra			CHAR(10);

--SET DEBUG FILE TO "sp_cat_gp_pp_genarchbase.out";
--TRACE ON; 

--Inicialización de variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_RetIB              = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '2003';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cnumcte                 = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "";
LET cdelimitador            = "";
LET vdia				    = DATE(1);
LET vhora				    = "";
LET ctipocampania           = "";
LET cfecha_insert           = "";
LET vTipoCobranza			= "";
LET cNum_ProdCampa			= "";
LET vFecha_insert			= "";
LET vcount					= 0;
LET vnum_param				= 0;
LET vregistra				= "";


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '01') Returning cCod_RetIB;

    --Sacar la fecha del día de hoy
    SELECT Fecha_Hoy
        INTO pFecha
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = '001';

    --Validación de la empresa
	SELECT empresa
        INTO cempresa
        FROM bdinteg:"informix".si_empresas
        WHERE empresa = pempresa;

    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
            INTO cMensaje
            FROM "informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
	END IF;

    --Obtener caracter delimitador
    SELECT valor_alfabetico
        INTO cdelimitador
        FROM "informix".cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 25;

    --Valida que exista el caracter
    IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
            INTO cMensaje
            FROM "informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    --Obtener ruta del archivo
	SELECT valor_alfabetico
        INTO cruta
        FROM "informix".cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 36;

    --Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
            INTO cMensaje
            FROM "informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '02') Returning cCod_RetIB;
        Return cCod_Ret;
    END IF;

    --Se saca el maximo de fecha insert	
	SELECT MAX(fecha_insert) 
        INTO cfecha_insert 
        FROM "informix".cb_cat_directorio_cte
		WHERE tipo_cobranza = ptipocobranza;

--temporal solo para pruebas
--LET cfecha_insert = today-1;
--temporal solo para pruebas

----------------------------------------------------------------------------------------------
---------------------------------------- ARCHIVOS IVR ----------------------------------------
FOREACH WITH HOLD
	SELECT valor_numerico INTO cNum_ProdCampa
	FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
	AND grupo_parametro = 'TIPOCOBCAT' AND valor_alfabetico = ptipocobranza

	IF (cNum_ProdCampa = "6300") THEN
		LET vnum_param = 49;
	ELIF (cNum_ProdCampa = "7600") THEN
		LET vnum_param = 75;
	ELIF (cNum_ProdCampa = "7700") THEN
		LET vnum_param = 76;
	ELIF (cNum_ProdCampa = "6011") THEN
		LET vnum_param = 51;
	ELIF (cNum_ProdCampa = "6800") THEN
		LET vnum_param = 78;
	ELSE
		CONTINUE FOREACH;
	END IF;

    --Obtener el nombre del archivo
	SELECT valor_alfabetico
        INTO cnombre
        FROM "informix".cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = vnum_param;

    --Validar que existe el archivo
    LET cnomarchivo1 =  TRIM(cnombre)||'Aux'||TO_CHAR(pFecha,'%d%m%Y')||'.txt';
    LET cnomarchivo =  TRIM(cnombre)||TO_CHAR(pFecha,'%d%m%Y')||'.txt';

    --Se ejecuta para ponerle el encabezado
	LET cSql='';
	LET csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
				 'prioridad'||','||'fechalimitepago'||','||'fechacorte'||'">'||TRIM(cruta)|| cnomarchivo;   
	system csql;

	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| TRIM(cdelimitador) || ''''||'';

	LET cSQL2 = " SELECT a.numcte as cliente,"
    || " TRIM (h.apell_paterno) ||' '|| TRIM (h.apell_materno)||' '|| TRIM(h.nombre1) ||' '|| TRIM(h.nombre2) as nombre,"
    || " a.num_producto as tipoproducto,"
    || " nvl(TRIM(substr(b.telefono,length(b.telefono)-9,10)),' ') as telcasa,"
	|| " nvl(TRIM(substr(d.telefono,length(d.telefono)-9,10)),' ') as telcelular,1,"
    || " (e.prox_fecha_pago) as fechalimitepago,"
	|| " (e.prox_fecha_pago) as fechacorte"
	|| " FROM 'informix'.cb_cat_directorio_cte a"
	|| " JOIN bdinteg:'informix'.si_cliente h ON (h.empresa = a.empresa AND h.numcte = a.numcte)"
	|| " LEFT OUTER JOIN bdinteg:'informix'.si_telefonos_actual b ON ( b.empresa = a.empresa AND b.numcte = a.numcte AND b.tipo_tel = 1 AND b.cofetel = 'V' AND length(nvl(b.telefono,'')) >= 10)"
	|| " LEFT OUTER JOIN bdinteg:'informix'.si_telefonos_actual d ON ( d.empresa = a.empresa AND d.numcte = a.numcte AND d.tipo_tel = 2 AND d.cofetel = 'V' AND length(nvl(d.telefono,'')) >= 10)"
	|| " JOIN bdicred:'informix'.sd_maecredanexocrd e ON (e.empresa= a.empresa AND e.num_credito = a.num_credito)"
	|| " WHERE a.empresa = '"|| pempresa || "'"
	|| " AND a.tipo_cobranza = '"|| ptipocobranza || "'"
	|| " AND a.fecha_insert = '"|| cfecha_insert || "'"
	|| " AND a.status_cliente = 'AC'"
	|| " AND a.num_producto = '"|| cNum_ProdCampa || "'"
	|| " AND ((nvl(b.telefono,'') <> '') OR (nvl(d.telefono,'') <> ''));";

	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_GenArchIVRpreventiva.sql';
    LET cSQL = TRIM(cSQL1) || cSQL2 || TRIM(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_GenArchIVRpreventiva.sql';
    System cSQL;

    LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchIVRpreventiva.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||TRIM(cDelimitador)||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    --Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_GenArchIVRpreventiva.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;

	LET cnombre, cnomarchivo1, cnomarchivo, cNum_ProdCampa, cSQL1, cSQL2, cSQL3 = "", "", "", "", "", "", "";
END FOREACH;
---------------------------------------- ARCHIVOS IVR ----------------------------------------
----------------------------------------------------------------------------------------------
LET cNum_ProdCampa = "";

FOREACH WITH HOLD
	SELECT valor_numerico INTO cNum_ProdCampa
	FROM bdicobranza:cb_param_campania WHERE empresa = pempresa AND tipo_campania = 1
	AND grupo_parametro = 'TIPOCOBCAT' AND valor_alfabetico = ptipocobranza

	IF (cNum_ProdCampa = "6300") THEN
		LET vregistra = "IVR_PP";
	ELIF (cNum_ProdCampa = "7600") THEN
		LET vregistra = "IVR_PP18";
	ELIF (cNum_ProdCampa = "7700") THEN
		LET vregistra = "IVR_PP24";
	ELIF (cNum_ProdCampa = "6011") THEN
		LET vregistra = "IVR_REEST";
	ELIF (cNum_ProdCampa = "6800") THEN
		LET vregistra = "IVR_PPDG";
	ELSE
		CONTINUE FOREACH;
	END IF;

	SELECT COUNT(*) INTO vcount
	FROM "informix".cb_cat_directorio_cte a
	JOIN bdinteg:"informix".si_cliente h ON (h.empresa = a.empresa AND h.numcte = a.numcte)
	LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual b ON ( b.empresa = a.empresa AND b.numcte = a.numcte AND b.tipo_tel = 1 AND b.cofetel = 'V' AND length(nvl(b.telefono,'')) >= 10)
	LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual d ON ( d.empresa = a.empresa AND d.numcte = a.numcte AND d.tipo_tel = 2 AND d.cofetel = 'V' AND length(nvl(d.telefono,'')) >= 10)
	JOIN bdicred:"informix".sd_maecredanexocrd e ON (e.empresa= a.empresa AND e.num_credito = a.num_credito)
	WHERE a.empresa = pempresa
	AND a.tipo_cobranza =  ptipocobranza
	AND a.fecha_insert =  cfecha_insert
	AND a.status_cliente = "AC"
	AND a.num_producto = cNum_ProdCampa
	AND ((nvl(b.telefono,"") <> "") OR (nvl(d.telefono,"") <> ""));

	CALL "informix".sp_latinia_contador_cobranza(vregistra,vcount,NULL) RETURNING cCod_ret;

	LET vcount, vregistra, cNum_ProdCampa = 0, "", "";
END FOREACH;

CALL "informix".sp_inserta_bitacora_cob(pempresa, vproceso, cCod_ret, cMensaje, '03') Returning cCod_RetIB;

RETURN cCod_ret;
END;
END PROCEDURE;
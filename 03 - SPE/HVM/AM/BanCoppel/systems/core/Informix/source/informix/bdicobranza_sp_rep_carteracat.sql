CREATE PROCEDURE "informix".sp_rep_carteracat()
RETURNING CHAR(6);
--   execute PROCEDURE "informix".sp_rep_carteracat();
--Creado por: maria elizabeth anzures ibarguen
--20-12-2011
--Proceso para la generación de archivo cartera cat

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE vproceso				CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte              CHAR(20);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pfechahoy			DATE;
DEFINE sPaso integer;
--variables
DEFINE VNombre_campana char (50);
DEFINE Vempresa char(3);
DEFINE Vfecha_llamada date;
DEFINE Vtipo_campania char(1);
DEFINE Vnumcte char(20);
DEFINE Vid_llamada char(100);
DEFINE Vtipo_telefono smallint;
DEFINE Vtelefono char(13);
DEFINE Vextension char(5);
DEFINE Vcodigo_resultado smallint;
DEFINE Vparentesco char(1);
DEFINE Vtipo_result char(50);
DEFINE VMonto_convenio decimal (18,2);
DEFINE VFecha_convenio date;
DEFINE Vfecha_llamar_despues date;
DEFINE Vhora_llamar_despues datetime hour to fraction ;
DEFINE Vejecutivo char(8);
DEFINE Vfh_movimiento datetime year to fraction ;
DEFINE Vfh_insert date;
DEFINE VNUmero_Llam smallint;
DEFINE VLlamadas_exitosas smallint;
DEFINE VLlamadas_no_exitosas smallint;
DEFINE VCiudad char(3);
DEFINE VEstado char(3);
DEFINE VRegion smallint;
DEFINE pfechacorte date;



--SET DEBUG FILE TO "/informix/Elizabeth/acrtera_archivo.out";
--TRACE ON; 

--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '2061';
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
LET cempresa                = "001";
LET cdelimitador            = "";
LET cCod_RetIB              = "000000";
LET sPaso = 0;
--VARIABLES
LET VNombre_campana = '';
LET Vempresa = '';
LET Vfecha_llamada = DATE(1);
LET Vtipo_campania = '';
LET Vnumcte = '';
LET Vid_llamada = '';
LET Vtipo_telefono = 0;
LET Vtelefono = '';
LET Vextension = '';
LET Vcodigo_resultado = 0;
LET Vparentesco = '';
LET Vtipo_result = '';
LET VMonto_convenio =0;
LET VFecha_convenio = DATE(1);
LET Vfecha_llamar_despues = DATE(1);
LET Vhora_llamar_despues = DATE(1) ;
LET Vejecutivo = '';
LET Vfh_movimiento = DATE(1) ;
LET Vfh_insert = DATE(1);
LET VNUmero_Llam = 0;
LET VLlamadas_exitosas = 0;
LET VLlamadas_no_exitosas = 0;
LET VCiudad = '';
LET VEstado = '';
LET VRegion = 0;
LET pfechacorte = date(1);

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02');
        RETURN cCod_ret;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
	
	Select Fecha_Hoy
        Into pfechacorte
    From bdicred:sd_fechas
    Where empresa = cempresa;
	
	--DROP TABLE sd_cartera_total_PPyR;
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'cb_archivo_cat ';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE cb_archivo_cat ;
            END IF;
	
	create TEMP table bdicobranza:cb_archivo_cat 
	(Nombre_campana char (50),
	empresa char(3),
	fecha_llamada date,
	tipo_campania char(1),
	numcte char(20),
	id_llamada char(100),
	tipo_telefono smallint,
	telefono char(13),
	extension char(5),
	codigo_resultado smallint,
	parentesco char(1),
	tipo_result char(50),
	Monto_convenio decimal (18,2),
	Fecha_convenio date,
	fecha_llamar_despues date,
	hora_llamar_despues datetime hour to fraction ,
	ejecutivo char(8),
	fh_movimiento datetime year to fraction ,
	fh_insert date,
	Numero_Llam smallint,
	Llamadas_exitosas smallint,
	Llamadas_no_exitosas smallint,
	Ciudad char(3),
	Estado char(3),
	Region smallint);
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 25;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	--Obtener ruta del archivo
	SELECT TRIM(valor_alfabetico)
	INTO cruta
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
    --WHERE empresa = '001'
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 34;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
	--Obtener el nombre del archivo
	SELECT TRIM(valor_alfabetico)
	INTO cnombre
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 32;
	
	Select Fecha_Hoy
        Into Vfh_insert
    From bdicred:sd_fechas
    Where empresa = cempresa;


-----------------------------BUSCA INFORMACION
FOREACH
				
	SELECT a.descripcion , b.empresa , b.fecha_llamada ,b.tipo_campania , b.numcte as numcte,
	b.id_llamada ,b.tipo_telefono , b.telefono , nvl(b.extension,0) ,
    b.codigo_resultado ,b.parentesco ,b.fecha_llamar_despues ,  b.hora_llamar_despues 
	,b.ejecutivo ,b.fh_movimiento ,c.estado ,c.ciudad ,d.numero_region
	INTO VNombre_campana , Vempresa , Vfecha_llamada , Vtipo_campania , Vnumcte ,
	Vid_llamada ,Vtipo_telefono , Vtelefono , Vextension ,
	Vcodigo_resultado , Vparentesco  ,Vfecha_llamar_despues,Vhora_llamar_despues,
	Vejecutivo,Vfh_movimiento,VEstado,VCiudad,VRegion
	FROM bdicobranza:cb_cat_resultado_llamada b, bdicobranza:cb_cat_tipo_resultado cod,
	bdinteg:si_direcciones_actual c , bdicobranza:cb_cat_campania a,	bdinteg:si_catciudades  d 
      WHERE b.codigo_resultado = cod.codigo_resultado
		and b.numcte = c.numcte
		and b.empresa = a.empresa 
		and b.tipo_campania  = a.tipo_cobranza
		and d.numerociudad = c.ciudad
        and a.modulo_cob = 3    
		and c.tipo_dir = 1
		and b.fecha_llamada = pfechacorte - 1 units day
				
		select fecha_compac, importe  
		into VFecha_convenio ,VMonto_convenio
		from bdicobranza:cb_compac
		where empresa = '001'
		and numcliente = Vnumcte
		and fecha_compac = (select max(fecha_compac)from bdicobranza:cb_compac where numcliente = Vnumcte); 
		
		select  sum(veces_marcado)   into VNUmero_Llam
		from bdicobranza:cb_registro_llamadas
		where empresa = '001'
		and numcte = Vnumcte;
		
		select count(veces_marcado) into VLlamadas_exitosas
		from bdicobranza:cb_registro_llamadas
		where empresa = '001'
		and veces_marcado in  (1,2,3,4,5)
		and numcte = Vnumcte;
		
		select count(veces_marcado) into VLlamadas_no_exitosas
		from bdicobranza:cb_registro_llamadas
		where empresa = '001'
		and veces_marcado in  (0,6,7,8,9,10,11,12,13,14,15,16,17,18)
		and numcte = Vnumcte;
		
		if (Vcodigo_resultado in (1,2,3,4,5)) then
			let Vtipo_result = 'EXITOSA';
		else
			let Vtipo_result = 'NO EXITOSA';
		end if;
		

	INSERT INTO bdicobranza:cb_archivo_cat 
		(Nombre_campana,empresa ,fecha_llamada ,tipo_campania ,numcte ,id_llamada ,
		tipo_telefono ,telefono ,extension ,codigo_resultado ,parentesco ,
		tipo_result ,Monto_convenio ,Fecha_convenio ,fecha_llamar_despues ,hora_llamar_despues ,ejecutivo ,
		fh_movimiento ,fh_insert ,Numero_Llam ,Llamadas_exitosas ,Llamadas_no_exitosas ,Ciudad ,Estado ,Region)
	VALUES 
		(VNombre_campana , Vempresa , Vfecha_llamada , Vtipo_campania , Vnumcte , Vid_llamada ,
		Vtipo_telefono , Vtelefono , Vextension , Vcodigo_resultado , Vparentesco , 
		Vtipo_result ,VMonto_convenio , VFecha_convenio , Vfecha_llamar_despues , Vhora_llamar_despues ,Vejecutivo , 
		Vfh_movimiento,Vfh_insert , VNUmero_Llam , VLlamadas_exitosas , VLlamadas_no_exitosas , VCiudad , VEstado , VRegion );
 
 END FOREACH;

 ----------------------------------CREAR ARCHIVO------------------------------
	
	LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.csv';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.csv';
	
	let cSql='';
	let csql = 'echo "Nombre_Campaña'||','||'Empresa'||','||'Fecha_Llamada'||','||'Tipo_Campania'||','||'Num_Cliente'||','||
				'Id_Llamada'||','||'Tipo_Telefono'||','||'Telefono'||','||'Extension'||','||'Codigo_Resultado'||','||
				'Parentesco'||','||'tipo_de_result'||','||'Monto_convenio'||','||'Fecha_convenio'||','||'Fecha_Llamar_Despues'||','||
				'Hora_Llamar_Despues'||','||'Ejecutivo'||','||'Fh_movimiento'||','||'fh_insert'||','||'Número_Llam '||','||
				'Llamadas_exitosas'||','||'Llamadas_no_exitosas'||','||'Ciudad'||','||'Estado'||','||'Región_de_cobranza'||' " >' ||TRIM(cruta)|| cnomarchivo;  ---se ejecuta para ponerle el encabezado 
	system csql;   
	
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " SELECT * FROM cb_archivoc_cat"; 
  
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_CarteraCAT.sql';
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_CarteraCAT.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_CarteraCAT.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_CarteraCAT.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;   

	CALL bdicobranza:"informix".inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03');

	RETURN cCod_ret;
END;
END PROCEDURE;
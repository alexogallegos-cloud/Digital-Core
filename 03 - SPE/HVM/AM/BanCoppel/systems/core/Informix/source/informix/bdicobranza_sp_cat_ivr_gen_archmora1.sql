CREATE PROCEDURE "informix".sp_cat_ivr_gen_archmora1(pempresa CHAR(3), 
						                                        pfechacorte DATE,
                                                    ptipocobranza char(1))
RETURNING CHAR(6);
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creado por: Abrham Lopez L Fecha: 24/05/2011. 
-- Descripcion: Proceso para la generación del archivo para campaña administrativa para los clientes con mora 1 en su Tarjeta de Credito.
-- execute procedure "informix".sp_cat_ivr_gen_archmora1('001', '07-12-2012','A');

--Modificado por: Abrham Lopez L. junio 05 de 2014
--Se mofica sp para eliminar el prefijo en los numeros celular.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--DECLARACION DE VARIABLES
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE Bit_Cod_ret          CHAR(6);  
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(30);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cNomArchSql			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE vfechacorte          DATE;
DEFINE vlFechaInsert        DATE;
DEFINE vTipo               SMALLINT;
DEFINE cNombreOriginal     CHAR(100);
DEFINE iParamPagvencidos   SMALLINT;
DEFINE vcount				INTEGER;

--SET DEBUG FILE TO "/informix/ALL/ivr_camp_preventiva.out";
--TRACE ON; 

--ICIALIZACION DE VARIABLES
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = '000000';
LET Bit_Cod_ret             = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '0220';
LET vempresa				= '001';
LET cruta                   = "";
LET cnombre					= "";
LET cnomarchivo             = "";
LET cnomarchivo1			= "";
LET cNomArchSql             = '';
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = "";
LET cNombreOriginal         = "";
LET iParamPagvencidos   	= 0;
LET vcount					=0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')  RETURNING Bit_Cod_ret; 
        RETURN cCod_ret;
    END EXCEPTION;

--A.L.L. DIRECTIVA PARA TABLAS BLOQUEADAS
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01') RETURNING Bit_Cod_ret;
    LET vTipo =1;	
--A.L.L. SE VALIDAN LOS PARAMETROS DE ENTRADA 
	IF NVL(pEmpresa,"") = "" OR NVL(pfechacorte, "") = "" THEN
        LET cCod_Ret= "104001";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret; 
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        Return cCod_Ret;
    ELSE
        LET vfechacorte =pfechacorte;
/*        SELECT MAX(FECHA_INSERT) INTO vlFechaInsert 
            FROM bdicobranza:"informix".CB_CAT_DIRECTORIO_CTE
            WHERE TIPO_COBRANZA =ptipocobranza; */
        SELECT MAX(FECHA_INSERT) INTO vlFechaInsert 
            FROM bdicobranza:"informix".CB_CAT_DIRECTORIO_CTE
            WHERE TIPO_COBRANZA =ptipocobranza
			AND num_producto = '6001';

		IF vlFechaInsert IS NULL OR vlFechaInsert = '' THEN
			LET vlFechaInsert = TODAY;
		END IF;			
			
        IF vfechacorte <> vlFechaInsert THEN
            LET vfechacorte = vlFechaInsert;
            LET vTipo =0;         
        END IF;      
    END IF;

--A.L.L. SE VALIDA LA EMPRESA
    SELECT empresa
        INTO cempresa
        FROM bdinteg:si_empresas
        WHERE empresa = pempresa;
	
    IF NVL (cempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
            INTO cMensaje
            FROM cb_errores
            WHERE origen = 3
            AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        Return cCod_Ret;
    END IF;
	
--A.L.L. SE OBTIENE EL CARACTER DELIMITADOR
    SELECT trim(valor_alfabetico)
        INTO cdelimitador
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 25;
	
--A.L.L. VALIDA QUE EXISTA EL CARACTER
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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        Return cCod_Ret;
    END IF;
	
--A.L.L. OBTENEMOS LA RUTA DEL ARCHIVO /home/syscobra/cat/envios/ 
	SELECT TRIM(valor_alfabetico)
        INTO cruta
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 3;
	
--A.L.L. VALIDA QUE EXISTA LA CARPETA
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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02') RETURNING Bit_Cod_ret;
        Return cCod_Ret;
    END IF;
	
--A.L.L. OBTENEMOS EL NOMBRE DEL ARCHIVO
	SELECT TRIM(valor_alfabetico)
        INTO cnombre
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 52;
		LET cNombreOriginal = cnombre;
		FOREACH
			SELECT valor_numerico
				INTO iParamPagvencidos
			FROM bdicobranza:cb_param_campania
			WHERE empresa = pempresa
			AND tipo_campania = 1
			AND grupo_parametro = 'ARCHIVOS_M'	

	
			--A.L.L. VALIDA QUE EXISTA EL ARCHIVO
				LET cnombre = TRIM(cNombreOriginal)||iParamPagvencidos;
				LET cnomarchivo1 =  trim(cnombre) ||'Aux_' || ptipocobranza || '_'||to_char(pfechacorte,'%d%m%Y')||'.txt';
				LET cnomarchivo =  trim(cnombre) || to_char(pfechacorte,'%d%m%Y')||'.txt';
				LET cNomArchSql = 'Ejecuta_' || ptipocobranza || '_' ||  'GenArchIVRpreventiva.sql';

			 --A.L.L. EJECUTAMOS PARA GENERAR LOS ENCABEZADOS DEL ARCHIVO 
				LET cSql='';
				LET csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
							 'prioridad'||','||'fechalimitepago'||','||'fechacorte'||'" >'||TRIM(cruta)|| cnomarchivo;			 
				SYSTEM csql; 
				
				LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

/*				LET cSQL2 = " select a.numcte as cliente, 'X', "
				|| " a.num_producto as tipoproducto, " 
				|| " trim(substr(b.telefono,length(b.telefono)-9,10)) as telcasa, " 
				|| " trim(substr(d.telefono,length(d.telefono)-9,10)) as telcelular,1, " 
				--|| " (case when d.carrier = 1 then 5 || trim(substr(d.telefono,length(d.telefono)-9,10))  when d.carrier = 2 then 1 || trim(substr(d.telefono,length(d.telefono)-9,10))  else 1 || trim(substr(d.telefono,length(d.telefono)-9,10)) end) as telcelular,1, "
				|| " (day(e.prox_fecha_pago))||'/'||lpad(month(e.prox_fecha_pago),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechalimitepago, "
				|| " (day(e.prox_fecha_pago+4 units day))||'/'||lpad(month(e.prox_fecha_pago-1 units month),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechacorte "
				|| " from bdicobranza:cb_cat_directorio_cte a "
				--|| " join bdicred:sd_maecred f on (a.empresa = f.empresa and a.numcte = f.numcte and f.num_producto = '6001') " 
				|| " left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 1 and b.cofetel = 'V') " 
				|| " left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 2 and d.cofetel = 'V') " 
				|| " join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito) "    
				|| " where a.empresa = '"||pempresa||"' "                    --'001' " 
				|| " and a.tipo_cobranza = '" || ptipocobranza || "' "       --'A' "
				|| " and a.pago_venc =  " || iParamPagvencidos || " "       --'A' "--JMAH
				--|| " and a.pago_venc = 1 "
				|| " and a.fecha_insert = '"|| vfechacorte || "' "           --'2012-08-21'  
				|| " and a.status_cliente = 'AC' " 
				|| " and a.num_producto = '6001' "
				|| " and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) "
				|| " and length(nvl(b.telefono,'')) >= 10 " 
				|| " and length(nvl(d.telefono,'')) >= 10 ";*/
				
				LET cSQL2 = " select a.numcte as cliente, 'X', "
				|| " a.num_producto as tipoproducto, " 
				|| " nvl(trim(substr(b.telefono,length(b.telefono)-9,10)),' ') as telcasa, " 
				|| " nvl(trim(substr(d.telefono,length(d.telefono)-9,10)),' ') as telcelular,1, " 
				|| " (day(e.prox_fecha_pago))||'/'||lpad(month(e.prox_fecha_pago),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechalimitepago, "
				|| " (day(e.prox_fecha_pago+4 units day))||'/'||lpad(month(e.prox_fecha_pago-1 units month),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechacorte "
				|| " from bdicobranza:cb_cat_directorio_cte a "
				|| " left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 1 and b.cofetel = 'V' and length(nvl(b.telefono,'')) >= 10) " 
				|| " left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 2 and d.cofetel = 'V' and length(nvl(d.telefono,'')) >= 10) " 
				|| " join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito) "    
				|| " where a.empresa = '"||pempresa||"' "                
				|| " and a.tipo_cobranza = '" || ptipocobranza || "' "    
				|| " and a.pago_venc =  " || iParamPagvencidos || " "   
				|| " and a.fecha_insert = '"|| vfechacorte || "' " 
				|| " and a.status_cliente = 'AC' " 
				|| " and a.num_producto = '6001' "
				|| " and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) ";

				LET cSQL3 = '">'||TRIM(cRuta)|| TRIM(cNomArchSql); 

				LET cSQL = trim(cSQL1) ||RTRIM(cSQL2)|| trim(cSQL3);
				System cSQL;

				LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomArchSql); 
				System cSQL;

				let cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || TRIM(cNomArchSql); 
				System cSQL;

				LET cSql = cSql;
				LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
				SYSTEM cSql;
			--A.L.L. BORRAMOS ARCHIVO DE CONTROL
				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cNomArchSql);
				SYSTEM cSQL;
			--A.L.L. BORRAMOS ARCHIVO DE CONTROL
				LET cSQL = '' ;
				LET cSQL = 'rm ' || TRIM(cruta) || TRIM(cnomarchivo1);
				SYSTEM cSQL; 
				LET cSQL = '' ;
		END FOREACH;
	
	
/*	select count(*) into vcount
	from bdicobranza:cb_cat_directorio_cte a 
	left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and 	b.numcte = a.numcte 	and b.tipo_tel = 1 and b.cofetel = 'V')  
	left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and 	d.tipo_tel = 2 and d.cofetel = 'V')  
	join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito)     
	where a.empresa = pempresa                  
		and a.tipo_cobranza = ptipocobranza     
		and a.pago_venc =   1        
		and a.fecha_insert =  vfechacorte        
		and a.status_cliente = 'AC'  
		and a.num_producto = '6001'
		and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) 
		and length(nvl(b.telefono,'')) >= 10  
		and length(nvl(d.telefono,'')) >= 10; */
		
	select count(*) into vcount
	from bdicobranza:cb_cat_directorio_cte a 
	left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 1 and b.cofetel = 'V' and length(nvl(b.telefono,'')) >= 10)  
	left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 2 and d.cofetel = 'V' and length(nvl(d.telefono,'')) >= 10)  
	join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito)     
	where a.empresa = pempresa                  
		and a.tipo_cobranza = ptipocobranza     
		and a.pago_venc =   1        
		and a.fecha_insert =  vfechacorte        
		and a.status_cliente = 'AC'  
		and a.num_producto = '6001'
		and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')); 
		
--		CALL bdicobranza:"informix".sp_latinia_contador_cobranza('IVR_MORA1',vcount) RETURNING cCod_ret;
		CALL bdicobranza:"informix".sp_latinia_contador_cobranza('IVR_MORA1',vcount,null) RETURNING cCod_ret;
	
	LET vcount = 0;
	
/*	select count(*) into vcount
	from bdicobranza:cb_cat_directorio_cte a 
	left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and 	b.numcte = a.numcte 	and b.tipo_tel = 1 and b.cofetel = 'V')  
	left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and 	d.tipo_tel = 2 and d.cofetel = 'V')  
	join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito)     
	where a.empresa = pempresa                  
		and a.tipo_cobranza = ptipocobranza     
		and a.pago_venc =   2        
		and a.fecha_insert =  vfechacorte        
		and a.status_cliente = 'AC' 
		and a.num_producto = '6001'
		and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) 
		and length(nvl(b.telefono,'')) >= 10  
		and length(nvl(d.telefono,'')) >= 10; */
		
	select count(*) into vcount
	from bdicobranza:cb_cat_directorio_cte a 
	left outer join bdinteg:si_telefonos_actual b on (b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 1 and b.cofetel = 'V' and length(nvl(b.telefono,'')) >= 10)  
	left outer join bdinteg:si_telefonos_actual d on (d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 2 and d.cofetel = 'V' and length(nvl(d.telefono,'')) >= 10)  
	join bdicred:sd_maecredanexo e on (e.empresa= a.empresa and e.num_credito = a.num_credito)     
	where a.empresa = pempresa                  
		and a.tipo_cobranza = ptipocobranza     
		and a.pago_venc =   2        
		and a.fecha_insert =  vfechacorte        
		and a.status_cliente = 'AC' 
		and a.num_producto = '6001'
		and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> ''));
		
--	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('IVR_MORA2',vcount) RETURNING cCod_ret;
	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('IVR_MORA2',vcount,null) RETURNING cCod_ret;
	
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03') RETURNING Bit_Cod_ret;

	RETURN cCod_ret;

END;
END PROCEDURE;
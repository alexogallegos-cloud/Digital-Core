CREATE PROCEDURE "informix".sp_monitoreo_trx_digitadas(pFechaInicio DATETIME YEAR TO FRACTION(5), pFechaFin DATETIME YEAR TO FRACTION(5))
    RETURNING CHAR(5) as CODIGO_RETORNO, CHAR(120) as MENSAJE_RETORNO;
    
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE vTrxDigitada VARCHAR(30);
    DEFINE vTipoCVV VARCHAR(15);
    DEFINE vCantidad INTEGER;
    DEFINE vTotalTrxs INTEGER;
    DEFINE vTotalTrxsRechazadas INTEGER;
    DEFINE vPorcentaje DECIMAL(15,2);
    DEFINE vPorcentajeDet DECIMAL(15,2);
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE vMotivo VARCHAR(120);
    DEFINE vCantidadTrxs INTEGER;
    
    
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN =  '/RESPALDOSNEW/monitoreo_transaccional/';
    LET vTrxDigitada = '';
    LET vTipoCVV = '';
    LET vCantidad = '';
    LET vTotalTrxs = 0;
    LET vTotalTrxsRechazadas = 0;
    LET vPorcentaje = 0.00;
    LET vPorcentajeDet = 0.00;
    LET vMotivo = '';
    LET vCantidadTrxs = 0;

    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_monitoreo_trx_digitadas.out";
    --TRACE ON;
	
	BEGIN 

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        DROP TABLE IF EXISTS tmp_movs_cvv;
        
        SELECT *
            FROM intercard:movimiento
        WHERE fechahorainauth >= pFechaInicio AND fechahorainauth <= pFechaFin
            AND tipotransaccionpos  = 'D'
              AND formato = '0200'  
            AND prodind = '02'
        INTO TEMP tmp_movs_cvv WITH NO LOG;
        
        LET vTotalTrxs = dbinfo("sqlca.sqlerrd2");

        SELECT COUNT(*)
            INTO vTotalTrxsRechazadas
        FROM tmp_movs_cvv
            WHERE codigoiso <> '00';

        --- Reporte general de la transaccionalidad por CVV dinamico
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_ORIGEN||'trxs_general_cvv_a.unl'||
            ' SELECT  ' ||
            ' CASE  ' ||
            ' WHEN codigoiso  = "00" THEN \"A\"   ' ||
            ' END as respuesta,   ' ||
            ' COUNT(*)::INTEGER as cantidad_transacciones,   ' ||
            ' CAST( ( ( (COUNT(*) * 100) /'|| vTotalTrxs||' ) ) as DECIMAL(5,2) ) as porcentaje  ' ||
            ' FROM intercard:movimiento  ' ||
            ' WHERE fechahorainauth  BETWEEN '''||pFechaInicio||''' AND '''||pFechaFin||''' '||
            " AND tipotransaccionpos  = 'D' "||
            " AND formato = '0200'  "||
            " AND prodind = '02'  "||
            " AND codigoiso = '00'  "||
            ' GROUP BY 1;' ||
            '" >'||RUTA_ORIGEN||'sct_trxs_general_a.sql';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'dbaccess intercard '||RUTA_ORIGEN||'sct_trxs_general_a.sql';
        SYSTEM vExecuteSQL;
        
        ---------------------------
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_ORIGEN||'trxs_general_cvv_r.unl'||
            ' SELECT  ' ||
            ' CASE  ' ||
            ' WHEN codigoiso  <> "00" THEN \"R\"   ' ||
            ' END as respuesta,   ' ||
            ' COUNT(*)::INTEGER as cantidad_transacciones,   ' ||
            ' CAST( ( ( (COUNT(*) * 100) /'|| vTotalTrxs||' ) ) as DECIMAL(5,2) ) as porcentaje  ' ||
            ' FROM intercard:movimiento  ' ||
            ' WHERE fechahorainauth  BETWEEN '''||pFechaInicio||''' AND '''||pFechaFin||''' '||
            " AND tipotransaccionpos  = 'D' "||
            " AND formato = '0200'  "||
            " AND prodind = '02'  "||
            " AND codigoiso <> '00'  "||
            ' GROUP BY 1;' ||
            '" >'||RUTA_ORIGEN||'sct_trxs_general_r.sql';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   'dbaccess intercard '||RUTA_ORIGEN||'sct_trxs_general_r.sql';
        SYSTEM vExecuteSQL;
        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL= 'echo '||'T\|'||vTotalTrxs||'\|'||
        ' >'||RUTA_ORIGEN||'sct_total_trxs.txt';
        SYSTEM vExecuteSQL;
        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL= ' paste -d " " '||RUTA_ORIGEN||'trxs_general_cvv_a.unl' ||' '||RUTA_ORIGEN||'trxs_general_cvv_r.unl'||' '||RUTA_ORIGEN||'sct_total_trxs.txt'||
        ' >'||RUTA_ORIGEN||'trxs_general_cvv.unl';
        SYSTEM vExecuteSQL;
        
        TRUNCATE TABLE intercard:tbl_paso_transaccionalidad;
        
        --Reporte detallado de los rechazos por CVV dinÃ¡mico
        FOREACH
            SELECT 
                    motivo,
                    COUNT(*) as cantidad_transacciones,
                    CAST( ( ( (COUNT(*) * 100) / vTotalTrxsRechazadas ) ) as DECIMAL(5,2) ) as porcentaje
                INTO vMotivo, vCantidadTrxs, vPorcentajeDet
                FROM intercard:movimiento
            WHERE fechahorainauth BETWEEN pFechaInicio AND pFechaFin
                AND codigoiso  <> '00'
            AND tipotransaccionpos  = 'D'
                AND formato = '0200'  
                    AND prodind = '02'
            GROUP BY 1
            
            
            INSERT INTO intercard:tbl_paso_transaccionalidad  (t_motivo, t_cantidad_transacciones, t_porcentaje)
                VALUES (vMotivo, vCantidadTrxs, vPorcentajeDet); 
            
        END FOREACH
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_ORIGEN||'trxs_detallado_01.unl'||
            ' SELECT t_motivo, t_cantidad_transacciones, t_porcentaje ' ||
            ' FROM intercard:tbl_paso_transaccionalidad ' ||
            ' ORDER BY 3 DESC; ' ||
            '" >'||RUTA_ORIGEN||'sct_trxs.sql';
        SYSTEM vExecuteSQL;
        
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_ORIGEN||'sct_trxs.sql';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL   =   '';
        LET vExecuteSQL   =   "sed = "||RUTA_ORIGEN||"trxs_detallado_01.unl | sed  'N;s/\n/\|/' > "||RUTA_ORIGEN||"trxs_detallado_res.txt";
        SYSTEM vExecuteSQL;

        

        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
	END
END PROCEDURE
---Base de datos intercard
---Armando Garcia Ortiz
---07 de junio el 2019
---Reporte utilizado para el monitoreo en pantalla
;

CREATE PROCEDURE "informix".sp_validatarjetacentralsuc(pNum_Tarjeta CHAR(16), pEstatusSucursal CHAR(7))
RETURNING CHAR(5) AS cCodRet, 
		CHAR(7) AS cDescStatus;
	
--Declaracion de variables-------------------------------------------------------- 
DEFINE cCodRet				CHAR(5);
DEFINE cDescStatus			CHAR(7);
DEFINE iSqlErr				INTEGER;
DEFINE cDescStatusCentral	CHAR(3);

--Inicializacion de Variables----------------------------------------------------- 
LET iSqlErr					=	0;
LET cCodRet					=	'00000';
LET cDescStatus				= 	'';
LET cDescStatusCentral		=	'';

--SET DEBUG FILE TO '/home/sysifx/respaldosbd/JuanCarlosVD/sp_ValidaTarjetaCentralSuc.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlerr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescStatus;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT codstatusasignada INTO cDescStatusCentral
	FROM intercard:"informix".tarjeta
	WHERE numtarjeta = pNum_Tarjeta;

	LET pEstatusSucursal = pEstatusSucursal;
	 
	IF NVL(pNum_Tarjeta,'') = '' OR NVL(pEstatusSucursal,'') = '' THEN
		LET cCodRet = '00001';
	ELSE
		IF cDescStatusCentral = 'NOA' AND pEstatusSucursal <> 'TPEND' THEN
			LET cDescStatus = 'TPEND';
		ELIF cDescStatusCentral = 'SIA' AND pEstatusSucursal <> 'T/A' THEN
			LET cDescStatus = 'T/A';
		END IF;
	END IF;

	RETURN cCodRet, cDescStatus;
		
END;
END PROCEDURE
DOCUMENT
'Autor: Juan Carlos Valenzuela',
'Folio: 514.1 -  RQM 06 220 4 Adendum Control y Admón. de Tarjetas ',
'Fecha: 27/05/2019',
'Modificación: El siguiente procedimiento es para validar los status de las tarjetas de sucursal con central',
'1.- Para los casos donde el estatus en central sea "NOA", en postgres deberá quedar el estatus en "TPEND"',
'2.- Para los casos donde el estatus en central sea "SIA", en postgres deberá quedar el estatus en "T/A"',
'Solicita: Abraham Narvaez', 
'Base de datos: intercard';

CREATE PROCEDURE "informix".sp_depuracion_tarjetapivote (piCommit integer)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
--Ãste SP depura de forma gradual todo lo que estÃ¡ en la tabla de tarjetapivote_depuracion de forma gradual
--Se va marcando las tarjetas que se van depurando y se marcan, si no existen tarjetas pendiente por depurar se indica

	--  Variables de Errores y datos de SP
	DEFINE  sql_err          integer;         DEFINE  isam_err     integer;        DEFINE  error_info        varchar(80);
	DEFINE  p_cod_ret        varchar(6);      DEFINE  p_mensaje    varchar(80);    DEFINE  vdfechaInicial    date;	
	DEFINE  vdfechaFinal       date;	
	
   	--  Variables para control de contadores
	DEFINE  vsflagentransaccion 	char(1); DEFINE 	vicontadorregistros 	integer;  DEFINE  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	DEFINE  vconsecutivo		integer;           DEFINE  varchivoorigen  	 CHAR(3);      DEFINE  vnombrearchivo   	   CHAR(23);
	DEFINE  vperiododepuracion  integer;           DEFINE  vmaxnumregistros  integer;      DEFINE  vsecuencia              varchar (7);
	DEFINE  vnumcuenta          varchar(13) ;      DEFINE  vnumtarjeta       varchar (16); DEFINE  vfechalocaltransaccion  varchar (4);
    DEFINE  vhoralocaltransaccion  varchar (6);
 
--- Variables Tabla Tarjeta 
    DEFINE     vnumtarjeta2                       	VARCHAR(16);    DEFINE     vcodstatustarjeta                  	VARCHAR(3);
    DEFINE     vcodproductotarjeta                	VARCHAR(3);     DEFINE     vnumcliente                        	VARCHAR(13);
    DEFINE     vtitular                           	VARCHAR(1);     DEFINE     vnombre                            	VARCHAR(104);
    DEFINE     vdireccion                         	VARCHAR(40);    DEFINE     vcoldeleg                          	VARCHAR(40);
    DEFINE     vciudad                            	VARCHAR(40);    DEFINE     vestado                            	VARCHAR(40);
    DEFINE     vcodpostal                         	VARCHAR(5);     DEFINE     vtelcasa                           	VARCHAR(20);
    DEFINE     vteloficina                        	VARCHAR(20);    DEFINE     vfechaexp                          	VARCHAR(4);
    DEFINE     vsefabricaplastico                 	VARCHAR(1);     DEFINE     vseimprimenip                      	VARCHAR(1);
    DEFINE     vacumdiarioretatmnac               	DECIMAL(19,4);  DEFINE     vacumdiarioretatmint               	DECIMAL(19,4);
    DEFINE     vacummensretatmnac                 	DECIMAL(19,4);  DEFINE     vacummensretatmint                 	DECIMAL(19,4);
    DEFINE     vacumdiariocompraposnac            	DECIMAL(19,4);  DEFINE     vacumdiariocompraposint            	DECIMAL(19,4);
    DEFINE     vacummenscompraposnac              	DECIMAL(19,4);  DEFINE     vacummenscompraposint              	DECIMAL(19,4);
    DEFINE     vacumcomconsatmnac                 	DECIMAL(19,4);  DEFINE     vacumcomconsatmint                 	DECIMAL(19,4);
    DEFINE     vacumcomretatmnac                  	DECIMAL(19,4);  DEFINE     vacumcomretatmint                  	DECIMAL(19,4);
    DEFINE     vacumcomcompraposnac               	DECIMAL(19,4);  DEFINE     vacumcomcompraposint               	DECIMAL(19,4);
    DEFINE     vacumcomrevatmnac                  	DECIMAL(19,4);  DEFINE     vacumcomrevatmint                  	DECIMAL(19,4);
    DEFINE     vacumcomrevposnac                  	DECIMAL(19,4);  DEFINE     vacumcomrevposint                  	DECIMAL(19,4);
    DEFINE     vacumcomfzdaposnac                 	DECIMAL(19,4);  DEFINE     vacumcomfzdaposint                 	DECIMAL(19,4);
    DEFINE     vcontcomconsatmnac                 	INTEGER;        DEFINE     vcontcomconsatmint                 	INTEGER;
    DEFINE     vcontcomretatmnac                  	INTEGER;        DEFINE     vcontcomretatmint                  	INTEGER;
    DEFINE     vcontcomcompraposnac               	INTEGER;        DEFINE     vcontcomcompraposint               	INTEGER;
    DEFINE     vcontcomrevatmnac                  	INTEGER;        DEFINE     vcontcomrevatmint                  	INTEGER;
    DEFINE     vcontcomrevposnac                  	INTEGER;        DEFINE     vcontcomrevposint                  	INTEGER;
    DEFINE     vcontcomfzdaposnac                 	INTEGER;        DEFINE     vcontcomfzdaposint                 	INTEGER;
    DEFINE     vconttranconsatmlibres             	INTEGER;        DEFINE     vconttranretatmlibres              	INTEGER;
    DEFINE     vconttrancompraposlibres           	INTEGER;        DEFINE     vcontmaxtranconsatmdiarias         	INTEGER;
    DEFINE     vcontmaxtranretatmdiarias          	INTEGER;        DEFINE     vcontmaxtrancompraposdiarias       	INTEGER;
    DEFINE     vcontmaxtranconsatmmens            	INTEGER;        DEFINE     vcontmaxtranretatmmens             	INTEGER;
    DEFINE     vcontmaxtrancompraposmens          	INTEGER;        DEFINE     vnumerolote                        	INTEGER;
    DEFINE     vcontmaxtranretatmnachd            	INTEGER;        DEFINE     vcontmaxtrancompraposnachd         	INTEGER;
    DEFINE     vcontmaxtranretatminthd            	INTEGER;        DEFINE     vcontmaxtrancompraposinthd         	INTEGER;
    DEFINE     vusuarioultmodif                   	VARCHAR(8);     DEFINE     vfechaultmodif                     	DATETIME YEAR to FRACTION(5);
    DEFINE     vacumretatmnachd                   	DECIMAL(19,4);  DEFINE     vacumretatminthd                   	DECIMAL(19,4);
    DEFINE     vacumcompraposnachd                	DECIMAL(19,4);  DEFINE     vacumcompraposinthd                	DECIMAL(19,4);
    DEFINE     vnumreporte                        	INTEGER;        DEFINE     venrenovacion                      	VARCHAR(1);
    DEFINE     vfechaexprenovacion                	VARCHAR(4);     DEFINE     vnumtarjetasustituta               	VARCHAR(16);
    DEFINE     vacumdiarioretatmpropio            	DECIMAL(19,4);  DEFINE     vacummensretatmpropio              	DECIMAL(19,4);
    DEFINE     vacumcomconsatmpropio              	DECIMAL(19,4);  DEFINE     vacumcomretatmpropio               	DECIMAL(19,4);
    DEFINE     vacumcomrevatmpropio               	DECIMAL(19,4);  DEFINE     vcontcomconsatmpropio              	INTEGER;
    DEFINE     vcontcomretatmpropio               	INTEGER;        DEFINE     vcontcomrevatmpropio               	INTEGER;  
	DEFINE     vconttranconsatmlibrespropio       	INTEGER;        DEFINE     vconttranretatmlibrespropio        	INTEGER;
    DEFINE     vcontmaxtranconsatmdiariopropio    	INTEGER;        DEFINE     vcontmaxtranretatmdiariaspropio    	INTEGER;
    DEFINE     vcontmaxtranconsatmmenspropio      	INTEGER;        DEFINE     vcontmaxtranretatmmenspropio       	INTEGER;
    DEFINE     vcontmaxtranretatmpropiohd         	INTEGER;        DEFINE     vacumretatmpropiohd                	DECIMAL(19,4);
    DEFINE     vnombrecorto                       	VARCHAR(18);    DEFINE     vfechanacimiento                   	DATETIME YEAR to FRACTION(5);
    DEFINE     vnombrepromotor                    	VARCHAR(60);    DEFINE     vcobracomreexptrj                  	VARCHAR(1);
    DEFINE     vcobracomreimpnip                  	VARCHAR(1);     DEFINE     vidpaq                             	VARCHAR(18);
    DEFINE     vcodstatusasignada                 	VARCHAR(3);     DEFINE     vfechaasignacion                   	DATETIME YEAR to FRACTION(5);
    DEFINE     vacumdiariocashbacknac             	MONEY;          DEFINE     vacummenscashbacknac               	MONEY;
    DEFINE     vacumdiariocashadvancenac          	MONEY;          DEFINE     vacummenscashadvancenac            	MONEY;
    DEFINE     vconttrancashbacklibres            	INTEGER;        DEFINE     vconttrancashadvancelibres         	INTEGER;
    DEFINE     vcontmaxtrancashbackdiarias        	INTEGER;        DEFINE     vcontmaxtrancashadvancediarias     	INTEGER;
    DEFINE     vcontmaxtrancashbackmens           	INTEGER;        DEFINE     vcontmaxtrancashadvancemens        	INTEGER;
    DEFINE     vsoportatranatmcajeropropio        	VARCHAR(1);     DEFINE     vsoportatranatmcajeroconvenio      	VARCHAR(1);
    DEFINE     vsoportetranatmcajerored           	VARCHAR(1);     DEFINE     vcontnipinvalido                   	INTEGER;
    DEFINE     vacumdiarioretatmconvenio          	DECIMAL(19,4);  DEFINE     vacummensualretatmconvenio         	DECIMAL(19,4);
    DEFINE     vacumcomconsatmconvenio            	DECIMAL(19,4);  DEFINE     vacumcomretatmconvenio             	DECIMAL(19,4);
    DEFINE     vacumcomrevatmconvenio             	DECIMAL(19,4);  DEFINE     vcontcomconsatmconvenio            	INTEGER;
    DEFINE     vcontcomretatmconvenio             	INTEGER;        DEFINE     vcontcomrevatmconvenio             	INTEGER;
    DEFINE     vconttranconsatmconveniolibres     	INTEGER;        DEFINE     vconttranretatmconveniolibres      	INTEGER;
    DEFINE     vcontmaxtranconsatmdconveniodiarias	INTEGER;        DEFINE     vcontmaxtranretatmconveniodiarias  	INTEGER;
    DEFINE     vcontmaxtranconsatmconveniomens    	INTEGER;        DEFINE     vcontmaxtranretatmconveniomens     	INTEGER;
    DEFINE     vsoportatranatmcajerointernacional 	VARCHAR(1);     DEFINE     vlimitemenscompraposnac            	DECIMAL(19,4);
    DEFINE     vlimitemenscompraposint            	DECIMAL(19,4);  DEFINE     vnumeroguia                        	INTEGER;
    DEFINE     vacumdiarioqps                     	DECIMAL(19,4);  DEFINE     vacumdiariocat                     	DECIMAL(19,4) ;
    DEFINE     vacumdiariomotovoz                 	DECIMAL(19,4);  DEFINE     vacumdiariomotoint                 	DECIMAL(19,4) ;
    DEFINE     vacummensualmotovoz                	DECIMAL(19,4);  DEFINE     vacummensualmotoint                	DECIMAL(19,4);
    DEFINE     vconttransmotovozdiario            	INTEGER ;       DEFINE     vconttransmotointdiario            	INTEGER ;
    DEFINE     vconttransmotovozmensual           	INTEGER ;       DEFINE     vconttransmotointmensual           	INTEGER ;
    DEFINE     vcontcvv2invalido                  	INTEGER ;       DEFINE     vacumdiariotag                     	DECIMAL(19,4) ;
    DEFINE     vacummensualtag                    	DECIMAL(19,4);  DEFINE     vconttransdiariotag                	INTEGER ;
    DEFINE     vconttransmensualtag               	INTEGER ;       DEFINE     vconttrancambionipdiario           	INTEGER ;
    DEFINE     vconttrandepositolibres            	INTEGER ;       DEFINE     vcontmaxtrandepositodiarias        	INTEGER ;
    DEFINE     vcontmaxtrandepositomens           	INTEGER ;       DEFINE     vacumdiariodepositonac             	MONEY ;
    DEFINE     vacummensdepositonac               	MONEY ;
--- Variables Tabla tarjetacuenta
   DEFINE vTarjetaCta  VARCHAR(16);           DEFINE vnumcuenta2 varchar(13);
-- Variables tabla hsmcard 		
	DEFINE vcard_no         	VARCHAR(20);  DEFINE vcard_offset     	VARCHAR(12);  DEFINE vexpirationdate  	VARCHAR(4);
    DEFINE vservice_code    	VARCHAR(3);   DEFINE vicvv            	VARCHAR(1);   DEFINE vbinarqc         	CHAR(6);
    DEFINE vcard_offset_old 	VARCHAR(12);  DEFINE vcard_type       	VARCHAR(1);   DEFINE vpin_offline     	VARCHAR(1);
    DEFINE vstatus_scripting	VARCHAR(1);   DEFINE vlast_script_send	VARCHAR(1);
--Variables Tabla info_tarjeta_pyt
    DEFINE vTarjetaPyT VARCHAR(16);        DEFINE vcount INTEGER;         
    --DEFINE vcodstatustarjeta  	VARCHAR(3);                      DEFINE vcodproductotarjeta	VARCHAR(3);  DEFINE vtitular    VARCHAR(1);
    --DEFINE vfechaasignacion   	DATETIME YEAR to FRACTION(5);    DEFINE vfechaultmodif     	DATETIME YEAR to FRACTION(5);
--Variables tabla detalle_maquila
    DEFINE  vTarjetadmaq   VARCHAR(16);  
    DEFINE  vsecuencia_maquila  INTEGER;      DEFINE  vclave_sucursal      VARCHAR(5);   DEFINE  vdomicilio_sucursal  	VARCHAR(150);
    DEFINE  vnumguia            INTEGER;      /*DEFINE  vnumtarjeta     VARCHAR(16);*/   DEFINE  vservicecode         	VARCHAR(3);
    DEFINE  vleyenda_tarjeta    VARCHAR(28);  DEFINE  vnumlote             	INTEGER;     DEFINE  vfecha_generacion    	DATETIME YEAR to FRACTION(5);
    DEFINE  vfecha_expiracion   VARCHAR(4);   DEFINE  vindicadortipoproceso	VARCHAR(2);  DEFINE  vflagprocesorealizado	CHAR(1);
    DEFINE  vprefijo_archivo    VARCHAR(10);  DEFINE  vsufijo_archivo      	VARCHAR(10); DEFINE  vconsecutivo_archivo 	VARCHAR(10);
    DEFINE  vprovedormaquila    INTEGER;      DEFINE  vtipomaquila         	VARCHAR(2);  DEFINE  vflagdiseno          	CHAR(1);
    DEFINE  vid_diseno          INTEGER;      DEFINE  vidsolicitud         	INTEGER;     DEFINE  vidsolmaquila        	INTEGER;
 --Variables Tabla flujotarjeta
    DEFINE vfecha     	DATETIME YEAR to FRACTION(5); /*DEFINE vnumtarjeta	VARCHAR(16);*/ DEFINE vcodflujo  	VARCHAR(3);
--Variables Tabla  sc_tarjeta/sd_tarjeta
    DEFINE  vTarjetasd           VARCHAR(16);    DEFINE  vTarjetasc          VARCHAR(16);  
    DEFINE  vempresa             CHAR(3);        DEFINE  vcuenta              	CHAR(20);       DEFINE  vsecuencia2           	SMALLINT;
    DEFINE  vnum_tarjeta         CHAR(20);       DEFINE  vnumcte              	CHAR(20);       DEFINE  vprodtarjeta         	CHAR(4);
    DEFINE  vexpiracion          DATE;           DEFINE  vtipo_tarjeta        	CHAR(1);        DEFINE  vnombre2              	CHAR(30);
    DEFINE  vstatus_tar          CHAR(1);        DEFINE  vlimite_aut          	MONEY;          DEFINE  vdisp_mes            	MONEY;
    DEFINE  vmotivo              CHAR(2);        DEFINE  vtipo_asignacion     	CHAR(1);        DEFINE  vcobro_comision      	CHAR(1);
    DEFINE  vgerente_autoriza    CHAR(8);        DEFINE  vbandera_cobro       	CHAR(1);        DEFINE  vbandera_bonificacion	CHAR(1);
    DEFINE  vcobro_tarjeta       DECIMAL(18,2);  DEFINE  viva_cobrotar    DECIMAL(18,2);        DEFINE  vfecha_insert        	DATE;
    DEFINE  vnum_credito     	 CHAR(20);       DEFINE   vlimite_aut2    DECIMAL(14,2);        DEFINE   vfolio_canc      	    CHAR(10); 
 
  --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>
	
	-- Variables Bandera de Actualizaciones
	DEFINE  vsflagborrado_tarjeta 	       char(1);  DEFINE  vsflagborrado_tarjetacuenta    char(1); DEFINE  vsflagborrado_hsmcard 	       char(1);
	DEFINE  vsflagborrado_info_tarjeta_pyt char(1);  DEFINE  vsflagborrado_detalle_maquila  char(1); DEFINE  vsflagborrado_flujotarjeta    char(1);
	DEFINE  vsflagborrado_sc_tarjeta 	   char(1);  DEFINE  vsflagborrado_sd_tarjeta 	    char(1);
	
	DEFINE  vsflaginsercion_tarjeta 	     char(1); DEFINE  vsflaginsercion_tarjetacuenta    char(1); DEFINE  vsflaginsercion_hsmcard 	     char(1);
	DEFINE  vsflaginsercion_info_tarjeta_pyt char(1); DEFINE  vsflaginsercion_detalle_maquila  char(1); DEFINE  vsflaginsercion_flujotarjeta 	 char(1);
	DEFINE  vsflaginsercion_sc_tarjeta 	     char(1); DEFINE  vsflaginsercion_sd_tarjeta 	   char(1);	
 
/* 
	SET DEBUG FILE TO "/informix/mgap/sp_depuracion_tarjetapivote.out";
    TRACE ON;
	
	SET DEBUG FILE TO "/resplogifx/sp_depuracion_tarjetapivote.out";
    TRACE ON;
*/

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
	INSERT INTO "informix".control_depuracion(numtarjeta, fechahoramodif, error_cod, error_desc)
   	VALUES (vnumtarjeta, current, P_COD_RET, P_MENSAJE );	
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vconsecutivo = 0;
	let 	varchivoorigen = '';    
    let 	vnombrearchivo = '';
	let     vperiododepuracion =0;
	let     vsecuencia='';
	let     vnumtarjeta='';
	let     vnumcuenta = '';
	let     vfechalocaltransaccion='';
	let     vhoralocaltransaccion='';
	let     vmaxnumregistros = piCommit;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let     p_cod_ret = '00000';
	let     p_mensaje = 'Proceso Exitoso';
	
	-------------------------
	--- Tabla Tarjeta
    LET     vnumtarjeta2                       	= '';   LET     vcodstatustarjeta                  	= '';  LET     vcodproductotarjeta                	= '';
    LET     vnumcliente                        	= '';   LET     vtitular                           	= '';  LET     vnombre                            	= '';
    LET     vdireccion                         	= '';   LET     vcoldeleg                          	= '';  LET     vciudad                            	= '';
    LET     vestado                            	= '';   LET     vcodpostal                         	= '';  LET     vtelcasa                           	= '';
    LET     vteloficina                        	= '';   LET     vfechaexp                          	= '';  LET     vsefabricaplastico                 	= '';
    LET     vseimprimenip                      	= '';   LET     vacumdiarioretatmnac               	= 0;   LET     vacumdiarioretatmint               	= 0; 
    LET     vacummensretatmnac                 	= 0;    LET     vacummensretatmint                 	= 0;   LET     vacumdiariocompraposnac            	= 0; 
    LET     vacumdiariocompraposint            	= 0;    LET     vacummenscompraposnac              	= 0;   LET     vacummenscompraposint              	= 0; 
    LET     vacumcomconsatmnac                 	= 0;    LET     vacumcomconsatmint                 	= 0;   LET     vacumcomretatmnac                  	= 0; 
    LET     vacumcomretatmint                  	= 0;    LET     vacumcomcompraposnac               	= 0;   LET     vacumcomcompraposint               	= 0; 
    LET     vacumcomrevatmnac                  	= 0;    LET     vacumcomrevatmint                  	= 0;   LET     vacumcomrevposnac                  	= 0; 
    LET     vacumcomrevposint                  	= 0;    LET     vacumcomfzdaposnac                 	= 0;   LET     vacumcomfzdaposint                 	= 0; 
    LET     vcontcomconsatmnac                 	= 0;    LET     vcontcomconsatmint                 	= 0;   LET     vcontcomretatmnac                  	= 0;
    LET     vcontcomretatmint                  	= 0;    LET     vcontcomcompraposnac               	= 0;   LET     vcontcomcompraposint               	= 0;
    LET     vcontcomrevatmnac                  	= 0;    LET     vcontcomrevatmint                  	= 0;   LET     vcontcomrevposnac                  	= 0;
    LET     vcontcomrevposint                  	= 0;    LET     vcontcomfzdaposnac                 	= 0;   LET     vcontcomfzdaposint                 	= 0;
    LET     vconttranconsatmlibres             	= 0;    LET     vconttranretatmlibres              	= 0;   LET     vconttrancompraposlibres           	= 0;    
	LET     vcontmaxtranconsatmdiarias         	= 0;    LET     vcontmaxtranretatmdiarias          	= 0;   LET     vcontmaxtrancompraposdiarias       	= 0;
    LET     vcontmaxtranconsatmmens            	= 0;    LET     vcontmaxtranretatmmens             	= 0;   LET     vcontmaxtrancompraposmens          	= 0;
    LET     vnumerolote                        	= 0;    LET     vcontmaxtranretatmnachd            	= 0;   LET     vcontmaxtrancompraposnachd         	= 0;
    LET     vcontmaxtranretatminthd            	= 0;    LET     vcontmaxtrancompraposinthd         	= 0;   LET     vusuarioultmodif                   	= '';
    LET     vfechaultmodif                     	= '';   LET     vacumretatmnachd                   	= 0;   LET     vacumretatminthd                   	= 0; 
    LET     vacumcompraposnachd                	= 0;    LET     vacumcompraposinthd                	= 0;   LET     vnumreporte                         = 0;
    LET     venrenovacion                      	= '';   LET     vfechaexprenovacion                	= '';  LET     vnumtarjetasustituta               	= '';
    LET     vacumdiarioretatmpropio            	= 0;    LET     vacummensretatmpropio              	= 0;   LET     vacumcomconsatmpropio              	= 0; 
    LET     vacumcomretatmpropio               	= 0;    LET     vacumcomrevatmpropio               	= 0;   LET     vcontcomconsatmpropio              	= 0;
    LET     vcontcomretatmpropio               	= 0;    LET     vcontcomrevatmpropio               	= 0;   LET     vconttranconsatmlibrespropio       	= 0;
    LET     vconttranretatmlibrespropio        	= 0;    LET     vcontmaxtranconsatmdiariopropio    	= 0;   LET     vcontmaxtranretatmdiariaspropio    	= 0;    
	LET     vcontmaxtranconsatmmenspropio      	= 0;    LET     vcontmaxtranretatmmenspropio       	= 0;   LET     vcontmaxtranretatmpropiohd         	= 0;
    LET     vacumretatmpropiohd                	= 0;    LET     vnombrecorto                       	= '';  LET     vfechanacimiento                    = '';
    LET     vnombrepromotor                    	= '';   LET     vcobracomreexptrj                  	= '';  LET     vcobracomreimpnip                  	= '';
    LET     vidpaq                             	= '';   LET     vcodstatusasignada                 	= '';  LET     vfechaasignacion                   	= '';
    LET     vacumdiariocashbacknac             	= 0;    LET     vacummenscashbacknac               	= 0;   LET     vacumdiariocashadvancenac          	= 0; 
	LET     vacummenscashadvancenac            	= 0;    LET     vconttrancashbacklibres            	= 0;   LET     vconttrancashadvancelibres         	= 0;
    LET     vcontmaxtrancashbackdiarias        	= 0;    LET     vcontmaxtrancashadvancediarias     	= 0;   LET     vcontmaxtrancashbackmens           	= 0;
    LET     vcontmaxtrancashadvancemens        	= 0;    LET     vsoportatranatmcajeropropio        	= '';  LET     vsoportatranatmcajeroconvenio      	= '';
    LET     vsoportetranatmcajerored           	= '';   LET     vcontnipinvalido                   	= 0;   LET     vacumdiarioretatmconvenio          	= 0; 
    LET     vacummensualretatmconvenio         	= 0;    LET     vacumcomconsatmconvenio            	= 0;   LET     vacumcomretatmconvenio             	= 0; 
    LET     vacumcomrevatmconvenio             	= 0;    LET     vcontcomconsatmconvenio            	= 0;   LET     vcontcomretatmconvenio             	= 0;
    LET     vcontcomrevatmconvenio             	= 0;    LET     vconttranconsatmconveniolibres     	= 0;   LET     vconttranretatmconveniolibres      	= 0;
    LET     vcontmaxtranconsatmdconveniodiarias	= 0;    LET     vcontmaxtranretatmconveniodiarias  	= 0;   LET     vcontmaxtranconsatmconveniomens    	= 0;
    LET     vcontmaxtranretatmconveniomens     	= 0;    LET     vsoportatranatmcajerointernacional 	= '';  LET     vlimitemenscompraposnac            	= 0; 
    LET     vlimitemenscompraposint            	= 0;    LET     vnumeroguia                        	= 0;   LET     vacumdiarioqps                     	= 0; 
    LET     vacumdiariocat                     	= 0;    LET     vacumdiariomotovoz                 	= 0;   LET     vacumdiariomotoint                 	= 0; 
    LET     vacummensualmotovoz                	= 0;    LET     vacummensualmotoint                	= 0;   LET     vconttransmotovozdiario            	= 0;
    LET     vconttransmotointdiario            	= 0;    LET     vconttransmotovozmensual           	= 0;   LET     vconttransmotointmensual           	= 0;
    LET     vcontcvv2invalido                  	= 0;    LET     vacumdiariotag                     	= 0;   LET     vacummensualtag                    	= 0;  
    LET     vconttransdiariotag                	= 0;    LET     vconttransmensualtag               	= 0;   LET     vconttrancambionipdiario           	= 0;
    LET     vconttrandepositolibres            	= 0;    LET     vcontmaxtrandepositodiarias        	= 0;   LET     vcontmaxtrandepositomens           	= 0;
    LET     vacumdiariodepositonac             	= 0;    LET     vacummensdepositonac               	= 0;
---Variables Tabla tarjetacuenta
    LET vTarjetaCta = '';          LET vnumcuenta2 = '';
-- Variables tabla hsmcard 	
    LET vcard_no         	='';   LET vcard_offset     	='';   LET vexpirationdate  	='';  LET vservice_code    	='';
    LET vicvv            	='';   LET vbinarqc         	='';   LET vcard_offset_old 	='';  LET vcard_type       	='';
    LET vpin_offline     	='';   LET vstatus_scripting	='';   LET vlast_script_send	='';	
--Variables Tabla info_tarjeta_pyt
    LET vTarjetaPyT = '';          LET vcount = 0;
	--LET vcodstatustarjeta  	= '';  LET vcodproductotarjeta	= '';  LET vtitular           	= '';LET vfechaasignacion   	= '';  LET vfechaultmodif     	= '';	
--Variables tabla detalle_maquila  
  LET  vTarjetadmaq = '';  
  LET  vsecuencia_maquila   	= 0;   LET  vclave_sucursal        = '';  LET  vdomicilio_sucursal = '';  LET  vnumguia           = 0;   --LET  vnumtarjeta          	= ''; 
  LET  vservicecode         	= '';  LET  vleyenda_tarjeta       = '';  LET  vnumlote            = 0;   LET  vfecha_generacion  = '';  LET  vfecha_expiracion    	= '';
  LET  vindicadortipoproceso	= '';  LET  vflagprocesorealizado  = '';  LET  vprefijo_archivo    = '';  LET  vsufijo_archivo    = '';  LET  vconsecutivo_archivo 	= '';
  LET  vprovedormaquila     	= 0;   LET  vtipomaquila           = '';  LET  vflagdiseno         = '';  LET  vid_diseno         = 0;   LET  vidsolicitud         	= 0;
  LET  vidsolmaquila        	= 0;
--Variables Tabla flujotarjeta
  LET vfecha     	= ''; /*LET vnumtarjeta	= '';*/  LET vcodflujo  	= '';
-- Variables Tabla  sc_tarjeta/sd_tarjeta
LET  vTarjetasd             = '';  LET  vTarjetasc              = '';
LET  vempresa             	= '';  LET  vcuenta              	= '';   LET  vsecuencia2           	= 0;  LET  vnum_tarjeta         = '';  LET  vnumcte              	= '';
LET  vprodtarjeta         	= '';  LET  vexpiracion          	= '';   LET  vtipo_tarjeta        	= ''; LET  vnombre2            	= '';  LET  vstatus_tar          	= '';  
LET  vlimite_aut          	= 0;   LET  vdisp_mes            	= 0;    LET  vmotivo              	= ''; LET  vtipo_asignacion     = '';  LET  vcobro_comision      	= '';
LET  vgerente_autoriza    	= '';  LET  vbandera_cobro       	= '';   LET  vbandera_bonificacion	= ''; LET  vcobro_tarjeta       = 0;   LET  viva_cobrotar        	= 0;
LET  vfecha_insert        	= '';  LET   vnum_credito     	    = '';   LET   vlimite_aut2      = 0;      LET   vfolio_canc      	= '';
	--------------------------
		
LET  vsflagborrado_tarjeta 	        = 'F';
LET  vsflagborrado_tarjetacuenta    = 'F';
LET  vsflagborrado_hsmcard 	        = 'F';
LET  vsflagborrado_info_tarjeta_pyt = 'F';
LET  vsflagborrado_detalle_maquila  = 'F';
LET  vsflagborrado_flujotarjeta 	= 'F';
LET  vsflagborrado_sc_tarjeta 	    = 'F';
LET  vsflagborrado_sd_tarjeta 	    = 'F';

LET  vsflaginsercion_tarjeta 	      = 'F';
LET  vsflaginsercion_tarjetacuenta    = 'F';
LET  vsflaginsercion_hsmcard 	      = 'F';
LET  vsflaginsercion_info_tarjeta_pyt = 'F';
LET  vsflaginsercion_detalle_maquila  = 'F';
LET  vsflaginsercion_flujotarjeta 	  = 'F';
LET  vsflaginsercion_sc_tarjeta 	  = 'F';
LET  vsflaginsercion_sd_tarjeta 	  = 'F';	
			
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	IF((select count(*)	 from "informix".tarjetapivote_depuracion  where estatus_depuracion = 'P') > 0) THEN
			    
		FOREACH CURSOR1 WITH HOLD
				FOR    
				select numcuenta, numtarjeta  INTO vnumcuenta, vnumtarjeta
			    from "informix".tarjetapivote_depuracion where estatus_depuracion = 'P' 
			
			    if(vsflagentransaccion = 'F') then
			    	begin work;
                    let vsflagentransaccion = 'V';
                end if;
		
	         --Se cambia el flujo, Inserta datos en la tablas historicas para su respaldo y Elimina los registros originales
	         --Se valida si una tarjeta estÃ¡ en la Historico previamente.

		        IF EXISTS(SELECT numtarjeta from tarjeta_historico tjt where tjt.numtarjeta = vnumtarjeta ) THEN
		                     let  vsflaginsercion_tarjeta 	      = 'V';					 
		                ELSE 
		
		            IF EXISTS(SELECT numtarjeta from tarjeta tjt where tjt.numtarjeta = vnumtarjeta ) THEN
		            
		                   SELECT 
		                   numtarjeta                         ,codstatustarjeta                  ,codproductotarjeta                 ,numcliente                        ,titular                           ,
		                   nombre                             ,direccion                         ,coldeleg                           ,ciudad                            ,estado                            ,
		                   codpostal                          ,telcasa                           ,teloficina                         ,fechaexp                          ,sefabricaplastico                 ,
		                   seimprimenip                       ,acumdiarioretatmnac               ,acumdiarioretatmint                ,acummensretatmnac                 ,acummensretatmint                 ,
		                   acumdiariocompraposnac             ,acumdiariocompraposint            ,acummenscompraposnac               ,acummenscompraposint              ,acumcomconsatmnac                 ,
		                   acumcomconsatmint                  ,acumcomretatmnac                  ,acumcomretatmint                   ,acumcomcompraposnac               ,acumcomcompraposint               ,
		                   acumcomrevatmnac                   ,acumcomrevatmint                  ,acumcomrevposnac                   ,acumcomrevposint                  ,acumcomfzdaposnac                 ,
		                   acumcomfzdaposint                  ,contcomconsatmnac                 ,contcomconsatmint                  ,contcomretatmnac                  ,contcomretatmint                  ,
		                   contcomcompraposnac                ,contcomcompraposint               ,contcomrevatmnac                   ,contcomrevatmint                  ,contcomrevposnac                  ,
		                   contcomrevposint                   ,contcomfzdaposnac                 ,contcomfzdaposint                  ,conttranconsatmlibres             ,conttranretatmlibres              ,
		                   conttrancompraposlibres            ,contmaxtranconsatmdiarias         ,contmaxtranretatmdiarias           ,contmaxtrancompraposdiarias       ,contmaxtranconsatmmens            ,
		                   contmaxtranretatmmens              ,contmaxtrancompraposmens          ,numerolote                         ,contmaxtranretatmnachd            ,contmaxtrancompraposnachd         ,
		                   contmaxtranretatminthd             ,contmaxtrancompraposinthd         ,usuarioultmodif                    ,fechaultmodif                     ,acumretatmnachd                   ,
		                   acumretatminthd                    ,acumcompraposnachd                ,acumcompraposinthd                 ,numreporte                        ,enrenovacion                      ,
		                   fechaexprenovacion                 ,numtarjetasustituta               ,acumdiarioretatmpropio             ,acummensretatmpropio              ,acumcomconsatmpropio              ,
		                   acumcomretatmpropio                ,acumcomrevatmpropio               ,contcomconsatmpropio               ,contcomretatmpropio               ,contcomrevatmpropio               ,
		                   conttranconsatmlibrespropio        ,conttranretatmlibrespropio        ,contmaxtranconsatmdiariopropio     ,contmaxtranretatmdiariaspropio    ,contmaxtranconsatmmenspropio      ,
		                   contmaxtranretatmmenspropio        ,contmaxtranretatmpropiohd         ,acumretatmpropiohd                 ,nombrecorto                       ,fechanacimiento                   ,
		                   nombrepromotor                     ,cobracomreexptrj                  ,cobracomreimpnip                   ,idpaq                             ,codstatusasignada                 ,
		                   fechaasignacion                    ,acumdiariocashbacknac             ,acummenscashbacknac                ,acumdiariocashadvancenac          ,acummenscashadvancenac            ,
		                   conttrancashbacklibres             ,conttrancashadvancelibres         ,contmaxtrancashbackdiarias         ,contmaxtrancashadvancediarias     ,contmaxtrancashbackmens           ,
		                   contmaxtrancashadvancemens         ,soportatranatmcajeropropio        ,soportatranatmcajeroconvenio       ,soportetranatmcajerored           ,contnipinvalido                   ,
		                   acumdiarioretatmconvenio           ,acummensualretatmconvenio         ,acumcomconsatmconvenio             ,acumcomretatmconvenio             ,acumcomrevatmconvenio             ,
		                   contcomconsatmconvenio             ,contcomretatmconvenio             ,contcomrevatmconvenio              ,conttranconsatmconveniolibres     ,conttranretatmconveniolibres      ,
		                   contmaxtranconsatmdconveniodiarias ,contmaxtranretatmconveniodiarias  ,contmaxtranconsatmconveniomens     ,contmaxtranretatmconveniomens     ,soportatranatmcajerointernacional ,
		                   limitemenscompraposnac             ,limitemenscompraposint            ,numeroguia                         ,acumdiarioqps                     ,acumdiariocat                     ,
		                   acumdiariomotovoz                  ,acumdiariomotoint                 ,acummensualmotovoz                 ,acummensualmotoint                ,conttransmotovozdiario            ,
		                   conttransmotointdiario             ,conttransmotovozmensual           ,conttransmotointmensual            ,contcvv2invalido                  ,acumdiariotag                     ,
		                   acummensualtag                     ,conttransdiariotag                ,conttransmensualtag                ,conttrancambionipdiario           ,conttrandepositolibres            ,
		                   contmaxtrandepositodiarias         ,contmaxtrandepositomens           ,acumdiariodepositonac              ,acummensdepositonac 
		                   
		                   INTO 
		                   vnumtarjeta2                       ,vcodstatustarjeta                  ,vcodproductotarjeta                ,vnumcliente                        ,vtitular                           ,
		                   vnombre                            ,vdireccion                         ,vcoldeleg                          ,vciudad                            ,vestado                            ,
		                   vcodpostal                         ,vtelcasa                           ,vteloficina                        ,vfechaexp                          ,vsefabricaplastico                 ,
		                   vseimprimenip                      ,vacumdiarioretatmnac               ,vacumdiarioretatmint               ,vacummensretatmnac                 ,vacummensretatmint                 ,
		                   vacumdiariocompraposnac            ,vacumdiariocompraposint            ,vacummenscompraposnac              ,vacummenscompraposint              ,vacumcomconsatmnac                 ,
		                   vacumcomconsatmint                 ,vacumcomretatmnac                  ,vacumcomretatmint                  ,vacumcomcompraposnac               ,vacumcomcompraposint               ,
		                   vacumcomrevatmnac                  ,vacumcomrevatmint                  ,vacumcomrevposnac                  ,vacumcomrevposint                  ,vacumcomfzdaposnac                 ,
		                   vacumcomfzdaposint                 ,vcontcomconsatmnac                 ,vcontcomconsatmint                 ,vcontcomretatmnac                  ,vcontcomretatmint                  ,
		                   vcontcomcompraposnac               ,vcontcomcompraposint               ,vcontcomrevatmnac                  ,vcontcomrevatmint                  ,vcontcomrevposnac                  ,
		                   vcontcomrevposint                  ,vcontcomfzdaposnac                 ,vcontcomfzdaposint                 ,vconttranconsatmlibres             ,vconttranretatmlibres              ,
		                   vconttrancompraposlibres           ,vcontmaxtranconsatmdiarias         ,vcontmaxtranretatmdiarias          ,vcontmaxtrancompraposdiarias       ,vcontmaxtranconsatmmens            ,
		                   vcontmaxtranretatmmens             ,vcontmaxtrancompraposmens          ,vnumerolote                        ,vcontmaxtranretatmnachd            ,vcontmaxtrancompraposnachd         ,
		                   vcontmaxtranretatminthd            ,vcontmaxtrancompraposinthd         ,vusuarioultmodif                   ,vfechaultmodif                     ,vacumretatmnachd                   ,
		                   vacumretatminthd                   ,vacumcompraposnachd                ,vacumcompraposinthd                ,vnumreporte                        ,venrenovacion                      ,
		                   vfechaexprenovacion                ,vnumtarjetasustituta               ,vacumdiarioretatmpropio            ,vacummensretatmpropio              ,vacumcomconsatmpropio              ,
		                   vacumcomretatmpropio               ,vacumcomrevatmpropio               ,vcontcomconsatmpropio              ,vcontcomretatmpropio               ,vcontcomrevatmpropio               ,
		                   vconttranconsatmlibrespropio       ,vconttranretatmlibrespropio        ,vcontmaxtranconsatmdiariopropio    ,vcontmaxtranretatmdiariaspropio    ,vcontmaxtranconsatmmenspropio      ,
		                   vcontmaxtranretatmmenspropio       ,vcontmaxtranretatmpropiohd         ,vacumretatmpropiohd                ,vnombrecorto                       ,vfechanacimiento                   ,
		                   vnombrepromotor                    ,vcobracomreexptrj                  ,vcobracomreimpnip                  ,vidpaq                             ,vcodstatusasignada                 ,
		                   vfechaasignacion                   ,vacumdiariocashbacknac             ,vacummenscashbacknac               ,vacumdiariocashadvancenac          ,vacummenscashadvancenac            ,
		                   vconttrancashbacklibres            ,vconttrancashadvancelibres         ,vcontmaxtrancashbackdiarias        ,vcontmaxtrancashadvancediarias     ,vcontmaxtrancashbackmens           ,
		                   vcontmaxtrancashadvancemens        ,vsoportatranatmcajeropropio        ,vsoportatranatmcajeroconvenio      ,vsoportetranatmcajerored           ,vcontnipinvalido                   ,
		                   vacumdiarioretatmconvenio          ,vacummensualretatmconvenio         ,vacumcomconsatmconvenio            ,vacumcomretatmconvenio             ,vacumcomrevatmconvenio             ,
		                   vcontcomconsatmconvenio            ,vcontcomretatmconvenio             ,vcontcomrevatmconvenio             ,vconttranconsatmconveniolibres     ,vconttranretatmconveniolibres      ,
		                   vcontmaxtranconsatmdconveniodiarias,vcontmaxtranretatmconveniodiarias  ,vcontmaxtranconsatmconveniomens    ,vcontmaxtranretatmconveniomens     ,vsoportatranatmcajerointernacional ,
		                   vlimitemenscompraposnac            ,vlimitemenscompraposint            ,vnumeroguia                        ,vacumdiarioqps                     ,vacumdiariocat                     ,
		                   vacumdiariomotovoz                 ,vacumdiariomotoint                 ,vacummensualmotovoz                ,vacummensualmotoint                ,vconttransmotovozdiario            ,
		                   vconttransmotointdiario            ,vconttransmotovozmensual           ,vconttransmotointmensual           ,vcontcvv2invalido                  ,vacumdiariotag                     ,
		                   vacummensualtag                    ,vconttransdiariotag                ,vconttransmensualtag               ,vconttrancambionipdiario           ,vconttrandepositolibres            ,
		                   vcontmaxtrandepositodiarias        ,vcontmaxtrandepositomens           ,vacumdiariodepositonac             ,vacummensdepositonac 
                           from tarjeta where numtarjeta = vnumtarjeta;
		            
		            
		                  insert into "informix".tarjeta_historico  values (
                          vnumtarjeta2                       ,vcodstatustarjeta                  ,vcodproductotarjeta                ,vnumcliente                        ,vtitular                           ,
                          vnombre                            ,vdireccion                         ,vcoldeleg                          ,vciudad                            ,vestado                            ,
                          vcodpostal                         ,vtelcasa                           ,vteloficina                        ,vfechaexp                          ,vsefabricaplastico                 ,
                          vseimprimenip                      ,vacumdiarioretatmnac               ,vacumdiarioretatmint               ,vacummensretatmnac                 ,vacummensretatmint                 ,
                          vacumdiariocompraposnac            ,vacumdiariocompraposint            ,vacummenscompraposnac              ,vacummenscompraposint              ,vacumcomconsatmnac                 ,
                          vacumcomconsatmint                 ,vacumcomretatmnac                  ,vacumcomretatmint                  ,vacumcomcompraposnac               ,vacumcomcompraposint               ,
                          vacumcomrevatmnac                  ,vacumcomrevatmint                  ,vacumcomrevposnac                  ,vacumcomrevposint                  ,vacumcomfzdaposnac                 ,
                          vacumcomfzdaposint                 ,vcontcomconsatmnac                 ,vcontcomconsatmint                 ,vcontcomretatmnac                  ,vcontcomretatmint                  ,
                          vcontcomcompraposnac               ,vcontcomcompraposint               ,vcontcomrevatmnac                  ,vcontcomrevatmint                  ,vcontcomrevposnac                  ,
                          vcontcomrevposint                  ,vcontcomfzdaposnac                 ,vcontcomfzdaposint                 ,vconttranconsatmlibres             ,vconttranretatmlibres              ,
                          vconttrancompraposlibres           ,vcontmaxtranconsatmdiarias         ,vcontmaxtranretatmdiarias          ,vcontmaxtrancompraposdiarias       ,vcontmaxtranconsatmmens            ,
                          vcontmaxtranretatmmens             ,vcontmaxtrancompraposmens          ,vnumerolote                        ,vcontmaxtranretatmnachd            ,vcontmaxtrancompraposnachd         ,
                          vcontmaxtranretatminthd            ,vcontmaxtrancompraposinthd         ,vusuarioultmodif                   ,vfechaultmodif                     ,vacumretatmnachd                   ,
                          vacumretatminthd                   ,vacumcompraposnachd                ,vacumcompraposinthd                ,vnumreporte                        ,venrenovacion                      ,
                          vfechaexprenovacion                ,vnumtarjetasustituta               ,vacumdiarioretatmpropio            ,vacummensretatmpropio              ,vacumcomconsatmpropio              ,
                          vacumcomretatmpropio               ,vacumcomrevatmpropio               ,vcontcomconsatmpropio              ,vcontcomretatmpropio               ,vcontcomrevatmpropio               ,
                          vconttranconsatmlibrespropio       ,vconttranretatmlibrespropio        ,vcontmaxtranconsatmdiariopropio    ,vcontmaxtranretatmdiariaspropio    ,vcontmaxtranconsatmmenspropio      ,
                          vcontmaxtranretatmmenspropio       ,vcontmaxtranretatmpropiohd         ,vacumretatmpropiohd                ,vnombrecorto                       ,vfechanacimiento                   ,
                          vnombrepromotor                    ,vcobracomreexptrj                  ,vcobracomreimpnip                  ,vidpaq                             ,vcodstatusasignada                 ,
                          vfechaasignacion                   ,vacumdiariocashbacknac             ,vacummenscashbacknac               ,vacumdiariocashadvancenac          ,vacummenscashadvancenac            ,
                          vconttrancashbacklibres            ,vconttrancashadvancelibres         ,vcontmaxtrancashbackdiarias        ,vcontmaxtrancashadvancediarias     ,vcontmaxtrancashbackmens           ,
                          vcontmaxtrancashadvancemens        ,vsoportatranatmcajeropropio        ,vsoportatranatmcajeroconvenio      ,vsoportetranatmcajerored           ,vcontnipinvalido                   ,
                          vacumdiarioretatmconvenio          ,vacummensualretatmconvenio         ,vacumcomconsatmconvenio            ,vacumcomretatmconvenio             ,vacumcomrevatmconvenio             ,
                          vcontcomconsatmconvenio            ,vcontcomretatmconvenio             ,vcontcomrevatmconvenio             ,vconttranconsatmconveniolibres     ,vconttranretatmconveniolibres      ,
                          vcontmaxtranconsatmdconveniodiarias,vcontmaxtranretatmconveniodiarias  ,vcontmaxtranconsatmconveniomens    ,vcontmaxtranretatmconveniomens     ,vsoportatranatmcajerointernacional ,
                          vlimitemenscompraposnac            ,vlimitemenscompraposint            ,vnumeroguia                        ,vacumdiarioqps                     ,vacumdiariocat                     ,
                          vacumdiariomotovoz                 ,vacumdiariomotoint                 ,vacummensualmotovoz                ,vacummensualmotoint                ,vconttransmotovozdiario            ,
                          vconttransmotointdiario            ,vconttransmotovozmensual           ,vconttransmotointmensual           ,vcontcvv2invalido                  ,vacumdiariotag                     ,
                          vacummensualtag                    ,vconttransdiariotag                ,vconttransmensualtag               ,vconttrancambionipdiario           ,vconttrandepositolibres            ,
                          vcontmaxtrandepositodiarias        ,vcontmaxtrandepositomens           ,vacumdiariodepositonac             ,vacummensdepositonac);
		            END IF;
		   
		             let  vsflaginsercion_tarjeta 	      = 'V';
		   
		            IF EXISTS(SELECT numtarjeta from tarjeta_historico tjt where tjt.numtarjeta = vnumtarjeta ) THEN
		              delete from "informix".tarjeta	 
		               where numtarjeta = vnumtarjeta;
		               let  vsflagborrado_tarjeta 	        = 'V';
			            ELSE
			             let  vsflagborrado_tarjeta = 'F';
		            END IF;	 
					
		        END IF;
		        --------------------------------------------------------------------------------------------------------				
			    LET vTarjetaCta = '';                
                LET vTarjetaCta =  (SELECT  FIRST 1 numtarjeta from tarjetacuenta_historico cta where cta.numtarjeta = vnumtarjeta AND cta.numcuenta = vnumcuenta);
				
				IF (vTarjetaCta <> '' ) THEN
				
				     LET  vsflaginsercion_tarjetacuenta = 'V';	
					 
					  ELSE 	 
                            SELECT COUNT(*) into vcount  from tarjetacuenta cta where cta.numtarjeta = vnumtarjeta AND cta.numcuenta = vnumcuenta; 
                            IF   vcount > 0 THEN 
                            
                                SELECT FIRST 1 numcuenta,numtarjeta
                                        INTO   vnumcuenta2,vnumtarjeta2
                                FROM tarjetacuenta WHERE numtarjeta = vnumtarjeta AND numcuenta = vnumcuenta;
                    
                                insert into "informix".tarjetacuenta_historico values ( vnumcuenta2,vnumtarjeta2);
                            
                            END IF;
                       		
                            let  vsflaginsercion_tarjetacuenta = 'V';
                       
                       IF (vTarjetaCta <> '' ) THEN
                          delete  from "informix".tarjetacuenta 	 
                          where numtarjeta = vnumtarjeta;
                          let  vsflagborrado_tarjetacuenta = 'V';		   
                        ELSE
                          let  vsflagborrado_tarjetacuenta = 'F';		   
                        END IF; 
					
		        END IF;   	 
		        ------------------------------------------------------------------------------------------------------------
		        IF EXISTS(SELECT card_no from hsmcard_historico hsm where hsm.card_no = vnumtarjeta ) THEN
		           let  vsflaginsercion_hsmcard 	      = 'V';
		        ELSE   ---------------
                
                    IF EXISTS(SELECT card_no from hsmcard hsm where hsm.card_no = vnumtarjeta ) THEN
                
		                SELECT  card_no,card_offset,expirationdate,service_code,icvv,binarqc,card_offset_old,card_type,pin_offline,status_scripting,last_script_send 
		                        INTO 
		                        vcard_no,vcard_offset,vexpirationdate,vservice_code,vicvv,vbinarqc,vcard_offset_old,vcard_type,vpin_offline,vstatus_scripting,vlast_script_send 
		                FROM hsmcard where  card_no = vnumtarjeta;
		                        
		                  insert into "informix".hsmcard_historico 
		                  values (vcard_no,vcard_offset,vexpirationdate,vservice_code,vicvv,vbinarqc,vcard_offset_old,vcard_type,vpin_offline,vstatus_scripting,vlast_script_send);
                    END IF; 			
		        	
		           let  vsflaginsercion_hsmcard 	    = 'V';
		           
		            IF EXISTS(SELECT card_no from hsmcard_historico hsm where hsm.card_no = vnumtarjeta ) THEN
		              delete from "informix".hsmcard 	 
		              where card_no = vnumtarjeta;
		              let  vsflagborrado_hsmcard  = 'V';
		             ELSE
		              let  vsflagborrado_hsmcard  = 'F';
		            END IF;
				   
		        END IF;
		        ----------  
		        LET vTarjetaPyT = '';                
                LET vTarjetaPyT =  (SELECT  FIRST 1 numtarjeta from info_tarjeta_pyt_historico pyt where pyt.numtarjeta = vnumtarjeta);
				
				IF (vTarjetaPyT <> '' ) THEN
				
				     LET  vsflaginsercion_info_tarjeta_pyt = 'V';	
					 
					  ELSE 	 
                            SELECT COUNT(*) into vcount  from info_tarjeta_pyt pyt where pyt.numtarjeta = vnumtarjeta; 
                            IF   vcount > 0 THEN 
                            
                                SELECT FIRST 1 numtarjeta,codstatustarjeta,codproductotarjeta,titular,fechaasignacion,fechaultmodif 
                                        INTO  vnumtarjeta2,vcodstatustarjeta,vcodproductotarjeta,vtitular,vfechaasignacion,vfechaultmodif
                                FROM info_tarjeta_pyt WHERE numtarjeta = vnumtarjeta;
                    
                                insert into "informix".info_tarjeta_pyt_historico values ( vnumtarjeta2,vcodstatustarjeta,vcodproductotarjeta,vtitular,vfechaasignacion,vfechaultmodif );
                            
                            END IF;
                       		
                            let  vsflaginsercion_info_tarjeta_pyt = 'V';
                       
                       IF (vTarjetaPyT <> '' ) THEN
                          delete  from "informix".info_tarjeta_pyt 	 
                          where numtarjeta = vnumtarjeta;
                          let  vsflagborrado_info_tarjeta_pyt = 'V';		   
                        ELSE
                          let  vsflagborrado_info_tarjeta_pyt = 'F';		   
                        END IF; 
					
		        END IF;   
	            ------------------------------------------------------------------------------------------------------
				LET vTarjetadmaq = '';                
                LET vTarjetadmaq =  (SELECT  FIRST 1 numtarjeta from detalle_maquila_historico maq where maq.numtarjeta = vnumtarjeta);				
				
				IF (vTarjetadmaq <> '' ) THEN
				
				     LET  vsflaginsercion_detalle_maquila = 'V';	
					 
					 	ELSE 	 
                            SELECT COUNT(*) into vcount  from detalle_maquila maq where maq.numtarjeta = vnumtarjeta; 
                            IF   vcount > 0 THEN 
				
				             SELECT FIRST 1 secuencia_maquila,clave_sucursal,domicilio_sucursal,numguia,numtarjeta,servicecode,leyenda_tarjeta,numlote,fecha_generacion,fecha_expiracion,
		        	         indicadortipoproceso,flagprocesorealizado,prefijo_archivo,sufijo_archivo,consecutivo_archivo,provedormaquila,tipomaquila,flagdiseno,id_diseno,idsolicitud,idsolmaquila
							 INTO 
		        			 vsecuencia_maquila,vclave_sucursal,vdomicilio_sucursal,vnumguia,vnumtarjeta2,vservicecode,vleyenda_tarjeta,vnumlote,vfecha_generacion,vfecha_expiracion,
		        			 vindicadortipoproceso,vflagprocesorealizado,vprefijo_archivo,vsufijo_archivo,vconsecutivo_archivo,vprovedormaquila,vtipomaquila,vflagdiseno,vid_diseno,vidsolicitud,vidsolmaquila
		                     FROM detalle_maquila where numtarjeta = vnumtarjeta;
							 
							insert into "informix".detalle_maquila_historico 
		                    values ( vsecuencia_maquila,vclave_sucursal,vdomicilio_sucursal,vnumguia,vnumtarjeta2,vservicecode,vleyenda_tarjeta,vnumlote,vfecha_generacion,vfecha_expiracion,
		                    vindicadortipoproceso,vflagprocesorealizado,vprefijo_archivo,vsufijo_archivo,vconsecutivo_archivo,vprovedormaquila,vtipomaquila,vflagdiseno,vid_diseno,vidsolicitud,vidsolmaquila); 
							 
							END IF; 
							
							 LET  vsflaginsercion_detalle_maquila = 'V';	
							 
							IF (vTarjetadmaq <> '' ) THEN
							  delete  from "informix".detalle_maquila 
                              where numtarjeta = vnumtarjeta;	
                              let  vsflagborrado_detalle_maquila = 'V';				
                             ELSE							  
							  let  vsflagborrado_detalle_maquila = 'F';
							END IF;  
				 
				 END IF;			
							
				-----------------------------
		
		        IF EXISTS(SELECT numtarjeta from flujotarjeta_historico flu where flu.numtarjeta = vnumtarjeta ) THEN
		           let  vsflaginsercion_flujotarjeta 	  = 'V';
		        ELSE  -----------------------------------
		        	    IF EXISTS(SELECT numtarjeta from flujotarjeta flu where flu.numtarjeta = vnumtarjeta ) THEN
		        		
		                   SELECT fecha,numtarjeta,codflujo INTO vfecha,vnumtarjeta,vcodflujo FROM flujotarjeta where numtarjeta = vnumtarjeta;
		              
		                  insert into "informix".flujotarjeta_historico  values (vfecha,vnumtarjeta,vcodflujo);		
		        		  
                        END IF;				  
                      ----------------------------------- 
		           let  vsflaginsercion_flujotarjeta 	  = 'V';
		           
		           IF EXISTS(SELECT numtarjeta from flujotarjeta_historico flu where flu.numtarjeta = vnumtarjeta ) THEN
		              delete from "informix".flujotarjeta	 	 
		              where numtarjeta = vnumtarjeta;
		              let  vsflagborrado_flujotarjeta 	= 'V';
		           ELSE	  
		              let  vsflagborrado_flujotarjeta 	= 'F';
		           END IF; 
				   
		        END IF;
		        --------------------------------------------------------------------------------------------------------------------------------------------
				LET vTarjetasc = '';                
                LET vTarjetasc =  (SELECT  FIRST 1 num_tarjeta from bdicheq:"informix".sc_tarjeta_historico chq where chq.num_tarjeta = vnumtarjeta AND cuenta  = vnumcuenta);				
				
				IF (vTarjetasc <> '' ) THEN
				
				     LET  vsflaginsercion_sc_tarjeta = 'V';	
					 
					 	ELSE 	 
                            SELECT COUNT(*) into vcount  from bdicheq:"informix".sc_tarjeta  chq where chq.num_tarjeta = vnumtarjeta AND  cuenta  = vnumcuenta;  
                            IF   vcount > 0 THEN 
				
				             SELECT FIRST 1 empresa,cuenta,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,disp_mes,motivo,tipo_asignacion,cobro_comision,
		        	          gerente_autoriza,bandera_cobro,bandera_bonificacion,cobro_tarjeta,iva_cobrotar,fecha_insert
							 INTO 
		        			 vempresa,vcuenta,vsecuencia2,vnum_tarjeta,vnumcte,vprodtarjeta,vexpiracion,vtipo_tarjeta,vnombre2,vstatus_tar,vlimite_aut,vdisp_mes,vmotivo,vtipo_asignacion,vcobro_comision,
		        	         vgerente_autoriza,vbandera_cobro,vbandera_bonificacion,vcobro_tarjeta,viva_cobrotar,vfecha_insert 
		                     FROM bdicheq:"informix".sc_tarjeta  where num_tarjeta = vnumtarjeta AND  cuenta  = vnumcuenta;
							 
							insert into bdicheq:"informix".sc_tarjeta_historico							
		                    values (vempresa,vcuenta,vsecuencia2,vnum_tarjeta,vnumcte,vprodtarjeta,vexpiracion,vtipo_tarjeta,vnombre2,vstatus_tar,vlimite_aut,vdisp_mes,vmotivo,vtipo_asignacion,vcobro_comision,
		        	                vgerente_autoriza,vbandera_cobro,vbandera_bonificacion,vcobro_tarjeta,viva_cobrotar,vfecha_insert);							  							 
							END IF; 
							
							 LET  vsflaginsercion_sc_tarjeta = 'V';	
							 
							IF (vTarjetasc <> '' ) THEN
							  delete from bdicheq:"informix".sc_tarjeta
							  where num_tarjeta = vnumtarjeta;
							  let  vsflagborrado_sc_tarjeta 	    = 'V';   
							  ELSE
							  let  vsflagborrado_sc_tarjeta 	    = 'F';	
                            END IF;							  
 
				 END IF;	
                -----------------------------------------------------------------------------------------------------						
				LET vTarjetasd = '';                
                LET vTarjetasd =  (SELECT  FIRST 1 num_tarjeta from bdicred:"informix".sd_tarjeta_historico crd where crd.num_tarjeta = vnumtarjeta AND num_credito  = vnumcuenta);				
				
				IF (vTarjetasd <> '' ) THEN
				
				     LET  vsflaginsercion_sd_tarjeta = 'V';	
					 
					 	ELSE 	 
                            SELECT COUNT(*) into vcount  from bdicred:"informix".sd_tarjeta  crd where crd.num_tarjeta = vnumtarjeta AND  num_credito  = vnumcuenta;  
                            IF   vcount > 0 THEN 
				
				             SELECT FIRST 1 empresa,num_credito,secuencia,num_tarjeta,numcte,prodtarjeta,expiracion,tipo_tarjeta,nombre,status_tar,limite_aut,
                			 disp_mes,motivo,tipo_asignacion,cobro_comision,gerente_autoriza,folio_canc
							 INTO 
		        			 vempresa,vnum_credito,vsecuencia2,vnum_tarjeta,vnumcte,vprodtarjeta,vexpiracion,vtipo_tarjeta,vnombre2,vstatus_tar,vlimite_aut2,
		        			 vdisp_mes,vmotivo,vtipo_asignacion,vcobro_comision,vgerente_autoriza,vfolio_canc
		                     FROM bdicred:"informix".sd_tarjeta  where num_tarjeta = vnumtarjeta AND  num_credito  = vnumcuenta;
							 
							insert into bdicred:"informix".sd_tarjeta_historico							
		                    values ( vempresa,vnum_credito,vsecuencia2,vnum_tarjeta,vnumcte,vprodtarjeta,vexpiracion,vtipo_tarjeta,vnombre2,vstatus_tar,vlimite_aut2,
		                    vdisp_mes,vmotivo,vtipo_asignacion,vcobro_comision,vgerente_autoriza,vfolio_canc);
							 							 
							END IF; 
							
							 LET  vsflaginsercion_sd_tarjeta = 'V';	
							 
							IF (vTarjetasd <> '' ) THEN
							  delete from bdicred:"informix".sd_tarjeta
							  where num_tarjeta = vnumtarjeta;
							  let  vsflagborrado_sd_tarjeta 	    = 'V';
							  ELSE
							  let  vsflagborrado_sd_tarjeta 	    = 'F';	
                            END IF;							  
 
				 END IF;	
		        -----------------------------------------------------------------------------------------------------
		         --  Elimina datos de las tablas en lÃ­nea en caso de que haya quedado pendiente un borrado de una inserciÃ³n
		    
	            IF(vsflaginsercion_sd_tarjeta = 'V' and vsflagborrado_sd_tarjeta = 'F' ) THEN
		           delete from bdicred:"informix".sd_tarjeta	 
		           where num_tarjeta = vnumtarjeta;
		           let  vsflaginsercion_sd_tarjeta 	  = 'V';
		        END IF;
		        
		        IF(vsflaginsercion_sc_tarjeta = 'V' and vsflagborrado_sc_tarjeta = 'F') THEN
		           delete from bdicheq:"informix".sc_tarjeta	 	 
		           where num_tarjeta = vnumtarjeta;
		           let vsflagborrado_sc_tarjeta = 'V';
		        END IF;
		        
		        IF(vsflaginsercion_flujotarjeta = 'V' AND vsflagborrado_flujotarjeta = 'F')THEN
		           delete from "informix".flujotarjeta	 	 
		           where numtarjeta = vnumtarjeta;
		           let vsflagborrado_flujotarjeta = 'V';
		        END IF;
		        
		        IF(vsflaginsercion_detalle_maquila  = 'V' AND vsflagborrado_detalle_maquila  = 'F')THEN
		           delete from "informix".detalle_maquila 	 
		           where numtarjeta = vnumtarjeta;
		           let vsflagborrado_detalle_maquila  = 'V';
		        END IF;
		        
		        IF(vsflaginsercion_info_tarjeta_pyt = 'V' and vsflagborrado_info_tarjeta_pyt = 'F')THEN
		           delete  from "informix".info_tarjeta_pyt 	 
		           where numtarjeta = vnumtarjeta;
		           let vsflagborrado_info_tarjeta_pyt = 'V';
		        END IF;
		        
		        IF(vsflaginsercion_hsmcard = 'V' and vsflagborrado_hsmcard = 'F')THEN
		           delete from "informix".hsmcard 	 
		           where card_no = vnumtarjeta;
		           let vsflagborrado_hsmcard = 'V';
		        END IF;
		        
		        IF(vsflaginsercion_tarjetacuenta = 'V' and vsflagborrado_tarjetacuenta = 'F')THEN
		           delete from "informix".tarjetacuenta	 
		           where numtarjeta = vnumtarjeta;
		           let vsflagborrado_tarjetacuenta = 'V';
		        END IF;
		        
		        IF (vsflaginsercion_tarjeta = 'V' and vsflagborrado_tarjeta = 'F') THEN
		           delete from "informix".tarjeta	 
		           where numtarjeta = vnumtarjeta;
		           let vsflagborrado_tarjeta = 'V';
		        END IF;
		
		    --Si llego a Ã©ste punto no hay error en el proceso y se actualiza la tarjeta si al menos una tabla se depuro
				
		    IF(vsflagborrado_tarjeta = 'V'            or vsflagborrado_tarjetacuenta   = 'V' or vsflagborrado_hsmcard    = 'V' or vsflagborrado_info_tarjeta_pyt = 'V'   or
	           vsflagborrado_detalle_maquila  = 'V'   or vsflagborrado_flujotarjeta    = 'V' or vsflagborrado_sc_tarjeta = 'V' or vsflagborrado_sd_tarjeta = 'V'         or
		       vsflaginsercion_tarjeta  = 'V'         or vsflaginsercion_tarjetacuenta = 'V' or vsflaginsercion_hsmcard  = 'V' or vsflaginsercion_info_tarjeta_pyt = 'V' or
	           vsflaginsercion_detalle_maquila  = 'V' or vsflaginsercion_flujotarjeta  = 'V' or vsflaginsercion_sc_tarjeta = 'V' or vsflaginsercion_sd_tarjeta = 'V')  THEN
		       
	           update "informix".tarjetapivote_depuracion
		       set estatus_depuracion = 'V' 
		       where numtarjeta =  vnumtarjeta; 		
		    
		      ELSE -- En caso de que algun registro no haya sido actualizado (insertado o borrado) guardaremos ese registro en una tabla para reiniciar desde ese punto
            
  			         IF (vsflaginsercion_tarjeta = 'F') THEN     
		    	         let     P_COD_RET = '00001';
	                     let     P_MENSAJE = 'Error en insercion de TARJETA';    
		    	      ELIF (vsflaginsercion_tarjetacuenta = 'F') THEN
		    	         let     P_COD_RET = '00002';
	                     let     P_MENSAJE = 'Error en insercion de TARJETACUENTA';
		    	      ELIF (vsflaginsercion_hsmcard = 'F') THEN
		    	         let     P_COD_RET = '00003';
	                     let     P_MENSAJE = 'Error en insercion de HSMCARD';  
                     ELIF (vsflaginsercion_info_tarjeta_pyt = 'F') THEN
		    	         let     P_COD_RET = '00004';
	                     let     P_MENSAJE = 'Error en insercion de INFO_TARJETA_PYT'; 	
                     ELIF (vsflaginsercion_detalle_maquila = 'F') THEN
		    	         let     P_COD_RET = '00005';
	                     let     P_MENSAJE = 'Error en insercion de DETALLE_MAQUILA'; 
                     ELIF (vsflaginsercion_flujotarjeta = 'F') THEN
		    	         let     P_COD_RET = '00006';
	                     let     P_MENSAJE = 'Error en insercion de FLUJOTARJETA'; 			
                     ELIF (vsflaginsercion_sc_tarjeta = 'F') THEN
		    	         let     P_COD_RET = '00007';
	                     let     P_MENSAJE = 'Error en insercion de SC_TARJETA'; 	
                     ELIF (vsflaginsercion_sd_tarjeta = 'F') THEN
		    	         let     P_COD_RET = '00008';
	                     let     P_MENSAJE = 'Error en insercion de SD_TARJETA'; 			   
		    	      ELIF (vsflagborrado_tarjeta = 'F') THEN
		    	         let     P_COD_RET = '00009';
	                     let     P_MENSAJE = 'Error en borrado de TARJETA';
		    	      ELIF (vsflagborrado_tarjetacuenta = 'F') THEN
		    	         let     P_COD_RET = '00010';
	                     let     P_MENSAJE = 'Error en borrado de TARJETACUENTA';
		    	      ELIF (vsflagborrado_hsmcard = 'F') THEN
		    	         let     P_COD_RET = '00011';
	                     let     P_MENSAJE = 'Error en borrado de HSMCARD';
		    	      ELIF (vsflagborrado_info_tarjeta_pyt = 'F') THEN
		    	         let     P_COD_RET = '00012';
	                     let     P_MENSAJE = 'Error en borrado de INFO_TARJETA_PYT';   
		    	      ELIF (vsflagborrado_detalle_maquila = 'F') THEN     
		    	         let     P_COD_RET = '00013';
	                     let     P_MENSAJE = 'Error en borrado de DETALLE_MAQUILA'; 
                     ELIF (vsflagborrado_flujotarjeta = 'F') THEN     
		    	         let     P_COD_RET = '00014';
	                     let     P_MENSAJE = 'Error en borrado de FLUJOTARJETA';   			   
		    	      ELIF (vsflagborrado_sc_tarjeta = 'F') THEN     
		    	         let     P_COD_RET = '00015';
	                     let     P_MENSAJE = 'Error en borrado de SC_TARJETA';   	
                     ELIF (vsflagborrado_sd_tarjeta = 'F') THEN     
		    	         let     P_COD_RET = '00016';
	                     let     P_MENSAJE = 'Error en borrado de SD_TARJETA'; 			   
		    	    END IF;
		    	      	
		    	      INSERT INTO "informix".control_depuracion(numtarjeta, fechahoramodif, error_cod, error_desc)
      	              VALUES (vnumtarjeta, current, P_COD_RET, P_MENSAJE );		
				
		    END IF;
				
		        let vicontadorregistros = vicontadorregistros + 1;

			if (vicontadorregistros = vmaxnumregistros) then
				--commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				commit work;
				--continue foreach;
			end if;	
			
		END FOREACH;
		
		    if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
   
				let vsflagentransaccion = 'F';
		    end if;

	END IF;
	
		RETURN 	P_COD_RET,P_MENSAJE;	
END;

END PROCEDURE;
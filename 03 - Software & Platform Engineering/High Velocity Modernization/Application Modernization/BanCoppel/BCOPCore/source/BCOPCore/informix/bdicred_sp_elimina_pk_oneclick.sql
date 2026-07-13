CREATE PROCEDURE "informix".sp_elimina_pk_oneclick()
RETURNING  CHAR(05) AS codret,
           CHAR(100) AS descripcion;
		   
		    DEFINE vCodRet CHAR(5);
			DEFINE iSqlErr INTEGER;
		    DEFINE vpk VARCHAR(20);
            DEFINE vDescripcion CHAR(100);
			DEFINE vSql CHAR(200);
			DEFINE cRutaCarga CHAR(500);
			
			
			LET vCodRet = '00000';
			LET iSqlErr = 0;
			LET vpk = "";
			LET vDescripcion = 'Proceso Completado.';
			LET vSql='';
			LET cRutaCarga ='';
			
            --SET DEBUG FILE TO '/home/sif0001/MiguelE/sp_elimina_pk.out';
            --TRACE ON;
            
           BEGIN
                ON EXCEPTION SET iSqlErr
			 	IF iSqlErr <> 0 THEN
                        LET vCodRet = iSqlErr;
						LET vDescripcion = 'Proceso no completado,ocurrio una excepcion.';
						RETURN vCodRet,vDescripcion;
				END IF;
                END EXCEPTION;
				
				SET ISOLATION DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
			    SELECT TRIM(valor) INTO cRutaCarga FROM  bdicred:"informix".sd_pre_aprobados_param WHERE codparam=7;
				
				SELECT  c.constrname INTO vpk
                FROM sysconstraints c, systables t, OUTER (sysreferences r, systables t2, sysconstraints c2)
                WHERE t.tabname = 'sd_pre_aprobados_his' AND t.tabid = c.tabid AND r.constrid = c.constrid AND t2.tabid = r.ptabid
                AND c2.constrid = r.constrid AND c.constrtype='P';
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				   LET vCodRet = '00001';
                   LET vDescripcion = 'La tabla no tiene llaves primarias.';
				ELSE
					LET vSql = 'echo "ALTER TABLE sd_pre_aprobados_his DROP CONSTRAINT '||vpk||'">'||TRIM(cRutaCarga)||'elimina_pk.sql'; --> cRutaCarga||elimina_pk.sql; u861_4707
					SYSTEM vSql;
					
					LET vSql='';
					
					LET vSql='dbaccess bdicred '||TRIM(cRutaCarga)||'elimina_pk.sql';
	                SYSTEM vSql;
					
					LET vSql = '';
                    LET vSql ='rm ' || TRIM(cRutaCarga) || 'elimina_pk.sql';
                    SYSTEM vSql;
					
				END IF;
				
			RETURN vCodRet,vDescripcion;
	
		END;
END PROCEDURE
DOCUMENT
'AUTOR : 90120580 - Miguel Angel Espinoza Salmoran.',
'DESCRIPCION: Elimina llave primaria de la tabla historica de oneclick',
'FOLIO: OneClick PreAprobados',
'FECHA : 09-01-2023',
'VERSION: 20230901.1414',
'BD: bdicred',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".cons_cre_bpi(pempresa char(3),
                                     pnum_cte char(20),
                                     pmoneda char(2))
   returning char(5),char(20),char(20), char(2),char(20),char(1),char(50),char(1),char(20);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_numcte,v_cuenta, v_numtarjeta char(20);
   define v_status_tar char(1);
   define v_status_cred char(2);
   define v_nombre_prod char(50);
   define v_secuencia integer;
   DEFINE vstatus_serv CHAR(1);
   define iCont		integer;
   define v_num_producto char(4);
   define v_nom_prod char(50);
   define v_cuenta_clabe char(20);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_cuenta      = null;
   let v_numcte = " ";
   let v_numtarjeta = " ";
   let v_status_tar = ' ';
   let v_status_cred = " ";
   let v_nombre_prod = " ";
   LET vstatus_serv	= "";
   let iCont =0;
   let v_num_producto='';
   let v_nom_prod ='';
   let v_cuenta_clabe ='';
   
   -- *****************************************************************************************************        
   -- Obejtivo:            Consulta de Estados de Cuenta Electronicos
   -- Creado por:			Autor desconocido
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2014/03/24    
   -- RazÃ??Ã?Â³n:				Se agrega parÃ??Ã?Â¡metro de salida del status del servicio
   --						de emisiÃ??Ã?Â³n de estados de cuenta CFDI
   -- *****************************************************************************************************
   -- Obejtivo:            Mostrar mas de 1 tarjeta en bpi (VISA y PLATINO)
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2015/01/12    
   -- RazÃ??Ã?Â³n:				Se agrega FOREACH para recorrer todas las posibles cuentas de credito de un cliente.
   --						
   -- *****************************************************************************************************
   -- Obejtivo:				Consultar productos de credito y prestamo
   -- Modificacion por:		Gabriela Aguilar
   -- Ultima Modificacion:	20/02/2016
   -- RazÃ??Ã?Â³n:				Se agrega busqueda en la tabla sd_maecred para obtener las cuentas de productos 
   --						prestamo personal y prestamo directo nÃ??Ã?Â³mina ('6400', '7600','7700','6300' )
   -- *****************************************************************************************************
   -- Obejtivo:				SE MODIFICA PARA QUE EN PRUEBAS TRAIGA 20 REGISTROS EN LUGAR DE 10
   -- Modificacion por:		Berenice Noriega Guevara
   -- Ultima Modificacion:	19-Noviembre-2019
   -- *****************************************************************************************************

--set debug file to "/home/informix/gaby/cons_cre_bpi.out";
--trace on;

LET v_numcte = pnum_cte;

begin
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv,v_cuenta_clabe;
      end if
   end exception;


       SET ISOLATION DIRTY READ ;
       set lock mode to wait 3;
		--Se agrega FOREACH para consultar mas de 1 tarjeta de credito.
	   FOREACH
       SELECT mc.num_credito, 
              mc.status_cred, 
              -- NVL(tr.num_tarjeta,''), NVL(tr.status_tar,''), 
              mc.cuenta_clabe,
			  tr.num_tarjeta, 
			  tr.status_tar, 
              df.num_producto, 
			  df.nombre_prod
        into v_cuenta, 
             v_status_cred,
             v_cuenta_clabe,
             v_numtarjeta, 
             v_status_tar, 
             v_num_producto, 
			 v_nom_prod
       FROM bdicred:"informix".sd_maecred mc
       JOIN  bdicred:"informix".sd_tarjeta tr on (tr.empresa = pempresa and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT', 'E1','E2','E3') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = pempresa and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
       JOIN bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
       WHERE mc.numcte = pnum_cte AND mc.num_producto = df.num_producto
	 UNION
	   SELECT mc.num_credito, 
              mc.status_cred,
              mc.cuenta_clabe,
              "NO APLICA", "", 
             df.num_producto, df.nombre_prod        
       FROM bdicred:"informix".sd_maecred mc
       JOIN bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
       WHERE mc.numcte = pnum_cte
			 AND mc.num_producto='7800'
			 AND mc.status_cred IN('AA','BA','BT','VP','E1','E2','E3')
	 UNION
			SELECT mcr.num_credito,  mcr.status_cred, mcr.cuenta_clabe, '', '', df.num_producto, df.nombre_prod
			FROM bdicred:"informix".sd_maecredcrd mcr
			JOIN bdicred:"informix".sd_definicion df 
				ON (df.num_producto = mcr.num_producto)
			WHERE mcr.numcte = pnum_cte and df.num_producto in ('6400', '7600','7700','6300' )
			AND mcr.status_cred IN('AA','BA','BT','VP','E1','E2','E3')

			-- Si es Nulo se asigna vacio.
			LET v_numtarjeta = NVL(v_numtarjeta, "");
			LET v_status_tar = NVL(v_status_tar, "");
            LET v_cuenta_clabe = NVL(v_cuenta_clabe, "");
			
			IF v_numtarjeta = "" THEN
				LET v_numtarjeta = "No Aplica";
			END IF;

       LET v_nombre_prod = TRIM(v_num_producto) || ' ' || TRIM(v_nom_prod);

	 --Se busca para saber si tiene activo el servicio de estados de cuenta CFDI
	  SELECT status_serv_elec
	  INTO vstatus_serv
	  FROM bdiedoelec:"informix".edelec_alta_serv
	  WHERE cuenta = v_cuenta;
	
	  LET vstatus_serv = NVL(vstatus_serv,"");
	  
	  LET iCont = iCont + 1;
	  --IF(iCont < 10 ) THEN
	  IF(iCont < 20 ) THEN
		--return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"") WITH RESUME;
		return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod, vstatus_serv, v_cuenta_clabe WITH RESUME;
	  END IF;	
    END FOREACH;
    
	IF ( iCont = 0 ) THEN
        LET cod_ret = '101'; --- Cliente No tiene cuentas
        --RETURN cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"");
		RETURN cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv,v_cuenta_clabe;
    END IF  

end
end PROCEDURE

DOCUMENT
'MODIFICADO POR: COPPEL y PATRICIA DEL RAZO-GM3',
'VALIDACION FUNCIONALIDAD POR: MARCELA PEREZ GM3',
'FECHA DE MODIFICACION: 26 DE DICIEMBRE DE 2018',
'VoBo: Juan Olivarez-GM2',
'VoBo: Alejandro Sanchez-GM1',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_depura_edoctas_norevolventes(pFecha DATE)
--EXECUTE PROCEDURE sp_depura_edoctas_norevolventes(mdy('01','18','2020'));

RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);    -- mensaje

DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCredito  VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
--Pruebas IPCB
DEFINE iDepura			integer;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE cFechaInicial	DATE;
DEFINE cFechaFinal		DATE;

DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso	CHAR(1);
DEFINE iCuentasProcesadas	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(150);
DEFINE v_ruta       VARCHAR(255);
DEFINE v_sql        CHAR(1200);
DEFINE v_sql1       CHAR(500);
DEFINE v_sql2       CHAR(500);
DEFINE cReinicio	CHAR(02);
DEFINE cNumCredito	CHAR(20);
DEFINE cBandera		CHAR(1);

-- declaracion de tablas operativas
DEFINE iTotalSdEncabezadoEdoctacrd 		INTEGER;
DEFINE iTotalSdEncabezado2Edoctacrd 	INTEGER;
DEFINE iTotalsdDetalleEdoctacrd 		INTEGER;
DEFINE iTotalSdAclaracionesEdoctacrd 	INTEGER;
DEFINE iTotalSdPieEdoctacrd 			INTEGER;
DEFINE iTotalSdMensajesEdoctacrd 		INTEGER;
DEFINE iTotalSdValedoctacrd 			INTEGER;
-- declaracion de tablas clonadas
DEFINE iTotalSdEncabezadoEdoctacrdClon 		INTEGER;
DEFINE iTotalSdEncabezado2EdoctacrdClon 	INTEGER;
DEFINE iTotalsdDetalleEdoctacrdClon 		INTEGER;
DEFINE iTotalSdAclaracionesEdoctacrdClon 	INTEGER;
DEFINE iTotalSdPieEdoctacrdClon 			INTEGER;
DEFINE iTotalSdMensajesEdoctacrdClon 		INTEGER;
DEFINE iTotalSdValedoctacrdClon 			INTEGER;
-- declaracion de tablas historicas
DEFINE iTotalSdEncabezadoEdoctacrdHist 		INTEGER;
DEFINE iTotalSdEncabezado2EdoctacrdHist 	INTEGER;
DEFINE iTotalsdDetalleEdoctacrdHist 		INTEGER;
DEFINE iTotalSdAclaracionesEdoctacrdHist 	INTEGER;
DEFINE iTotalSdPieEdoctacrdHist 			INTEGER;
DEFINE iTotalSdMensajesEdoctacrdHist 		INTEGER;
DEFINE iTotalSdValedoctacrdHist 			INTEGER;

DEFINE dFechaIni	DATE;
DEFINE dFechaFin	DATE;
--DEFINE icontador	CHAR(20);
DEFINE dFechaEmision DATE;

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCredito  = '';
LET vNumCredAux  = '';
LET dFechaDepura = DATE(1);
--Pruebas IPCB
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET cFechaInicial	= 0;
LET cFechaFinal		= 0;

LET iCuentasProcesadas	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET cProceso		= '0104';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= 'Migracion EXITOSA. ';
LET v_ruta      	= "/resplogifx/archivoscartera/";

LET v_sql       	= "";
LET v_sql1      	= "";
LET v_sql2      	= "";
LET cReinicio 		= '';
LET cNumCredito 	= '';
LET cBandera		= '0';

LET iTotalSdEncabezadoEdoctacrd 	= 0;
LET iTotalSdEncabezado2Edoctacrd 	= 0;
LET iTotalsdDetalleEdoctacrd 		= 0;
LET iTotalSdAclaracionesEdoctacrd 	= 0;
LET iTotalSdPieEdoctacrd 			= 0;
LET iTotalSdMensajesEdoctacrd 		= 0;
LET iTotalSdValedoctacrd 			= 0;

LET iTotalSdEncabezadoEdoctacrdClon 	= 0;
LET iTotalSdEncabezado2EdoctacrdClon 	= 0;
LET iTotalsdDetalleEdoctacrdClon 		= 0;
LET iTotalSdAclaracionesEdoctacrdClon 	= 0;
LET iTotalSdPieEdoctacrdClon 			= 0;
LET iTotalSdMensajesEdoctacrdClon 		= 0;
LET iTotalSdValedoctacrdClon 			= 0;

LET iTotalSdEncabezadoEdoctacrdHist 	= 0;
LET iTotalSdEncabezado2EdoctacrdHist 	= 0;
LET iTotalsdDetalleEdoctacrdHist 		= 0;
LET iTotalSdAclaracionesEdoctacrdHist 	= 0;
LET iTotalSdPieEdoctacrdHist 			= 0;
LET iTotalSdMensajesEdoctacrdHist 		= 0;
LET iTotalSdValedoctacrdHist 			= 0;

LET dFechaIni	= DATE(1);
LET dFechaFin	= DATE(1);
LET dFechaEmision = DATE(1);

--LET icontador=0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCredito;
				if cBandera = '1' then
					ROLLBACK WORK;
				end if;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;
            RETURN cCodRet,cMensaje;
		END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
--SET DEBUG FILE TO '/informix/Ulises/sp_depura_edocta_norevolventes.out';
--TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
		
	--IF pFecha IS NULL OR pFecha = '' THEN
	IF pFecha = date(1) THEN
		SELECT fecha_hoy INTO pFecha
		FROM bdicred:sd_fechas;
		LET pFecha = MDY(MONTH(pFecha),18,YEAR(pFecha)) - 3 UNITS MONTH;
	ELSE
		LET pFecha = MDY(MONTH(pFecha),18,YEAR(pFecha));

		IF  pFecha > MDY(MONTH(TODAY),18,YEAR(TODAY)) - 3 UNITS MONTH THEN
		   LET P_MENSAJE  = 'No hay informacion a depurar con esta fecha';
		   LET P_COD_RET = '000000'; 
		   RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;
		
--	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE today INTO cFechaInicial from sysmaster:sysshmvals;
--	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

--	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
--	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
    SELECT valor
      INTO cReinicio
      FROM bdicred:"informix".sd_param
     WHERE empresa = '001' AND cod_param = '063';
	 
	 -- Si no existe el parametro 063 insertar informacion.
 
	 IF cReinicio IS NULL THEN
		LET cReinicio = '0';
		BEGIN WORK;
		INSERT INTO bdicred:"informix".sd_param(empresa,cod_param,descripcion,valor,user_insert,fecha_insert)
		VALUES ('001','063','Control reinicio depuracion edos cta NO REVOL OLTP',cReinicio,USER,today);
		COMMIT WORK;
	
	ELIF cReinicio = '' THEN
		LET cReinicio = '0';
		BEGIN WORK;
		UPDATE bdicred:"informix".sd_param SET valor = cReinicio
		WHERE cod_param = '063';
		COMMIT WORK;
	END IF;
	
	LET dFechaIni = MDY(MONTH(pFecha),1,YEAR(pFecha));
	LET dFechaFin = (dFechaIni + 1 UNITS MONTH) - 1 UNITS DAY;

-----------------INICIA DESCARGA DE INFORMACION DE TABLAS OPERATIVAS -------------------------------------------------------------
	If cReinicio = '0' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicio de descargas de tablas operativas', '02') RETURNING P_COD_RET;
		truncate table sd_encabezado_edoctacrd_clon;
		truncate table sd_encabezado2_edoctacrd_clon;
		truncate table sd_detalle_edoctacrd_clon;
		truncate table sd_aclaraciones_edoctacrd_clon;
		truncate table sd_mensajes_edoctacrd_clon;
		truncate table sd_pie_edoctacrd_clon;
		truncate table sd_valedoctacrd_clon;
		
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';

        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_encabezado_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_encabezado_edoctacrd where fecha_emision >= '''||dFechaIni||''' and fecha_emision <= '''||dFechaFin||'''; " > '||v_ruta ||'queryEncabezado.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "||v_ruta||"queryEncabezado.sql";
        system v_sql;

		LET cReinicio = '1';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_encabezado_edoctacrd', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '1' then
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';
		
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_encabezado2_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_encabezado2_edoctacrd where fecha_emision >= '''||dFechaIni||''' and fecha_emision <= '''||dFechaFin||'''; " > '||v_ruta ||'queryEncabezado2.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryEncabezado2.sql";
        system v_sql;

		LET cReinicio = '2';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_encabezado2_edoctacrd', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '2' then
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';
		
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_detalle_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_detalle_edoctacrd where fecha_emision >= '''||dFechaIni||''' and fecha_emision <= '''||dFechaFin||'''; " > '||v_ruta ||'queryDetalle.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryDetalle.sql";
        system v_sql;

		LET cReinicio = '3';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_detalle_edoctacrd', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '3' then
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';
		
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_pie_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_pie_edoctacrd where fecha_emision >= '''||dFechaIni||''' and fecha_emision <= '''||dFechaFin||'''; " > '||v_ruta ||'queryPie.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryPie.sql";
        system v_sql;

		LET cReinicio = '4';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_pie_edoctacrd', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '4' then
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';
		
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_mensajes_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_mensajes_edoctacrd where fecha_emision >= '''||dFechaIni||''' and fecha_emision <= '''||dFechaFin||'''; " > '||v_ruta ||'queryMensajes.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryMensajes.sql";
        system v_sql;

		LET cReinicio = '5';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_mensajes_edoctacrd', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '5' then
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';
		
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_valedoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_valedoctacrd where fecha_proc >= '''||dFechaIni||''' and fecha_proc <= '''||dFechaFin||'''; " > '||v_ruta ||'queryValedocta.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryValedocta.sql";
        system v_sql;

		LET cReinicio = '6';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_valedoctacrd', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '6' then
        LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';
		
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'sd_aclaraciones_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdicred:sd_aclaraciones_edoctacrd where fecha_emision >= '''||dFechaIni||''' and fecha_emision <= '''||dFechaFin||'''; " > '||v_ruta ||'queryAclaraciones.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryAclaraciones.sql";
        system v_sql;

		LET cReinicio = '7';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina descarga de tabla sd_aclaraciones_edoctacrd', '02') RETURNING P_COD_RET;
	end if;
	
----------------- INICIA CARGA DE INFORMACION A TABLAS CLONADAS -------------------------------------------------------------
	If cReinicio = '7' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia carga de informacion a tablas clon', '02') RETURNING P_COD_RET;
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_encabezado_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 30; INSERT INTO sd_encabezado_edoctacrd_clon; " > '||v_ruta ||'queryCargaEncabezadoClon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaEncabezadoClon.sql -l '||v_ruta||'sd_encabezado_edoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '8';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_encabezado_edoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '8' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_encabezado2_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 33; INSERT INTO sd_encabezado2_edoctacrd_clon; " > '||v_ruta ||'queryCargaEncabezado2Clon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaEncabezado2Clon.sql -l '||v_ruta||'sd_encabezado2_edoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '9';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_encabezado2_edoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '9' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_detalle_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 8; INSERT INTO sd_detalle_edoctacrd_clon; " > '||v_ruta ||'queryCargaDetalleClon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaDetalleClon.sql -l '||v_ruta||'sd_detalle_edoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '10';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_detalle_edoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '10' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_aclaraciones_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 9; INSERT INTO sd_aclaraciones_edoctacrd_clon; " > '||v_ruta ||'queryCargaAclaracionesClon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaAclaracionesClon.sql -l '||v_ruta||'sd_aclaraciones_edoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '11';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_aclaraciones_edoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '11' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_pie_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 8; INSERT INTO sd_pie_edoctacrd_clon; " > '||v_ruta ||'queryCargaPieClon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaPieClon.sql -l '||v_ruta||'sd_pie_edoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '12';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_pie_edoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '12' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_mensajes_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 7; INSERT INTO sd_mensajes_edoctacrd_clon; " > '||v_ruta ||'queryCargaMensajesClon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaMensajesClon.sql -l '||v_ruta||'sd_mensajes_edoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '13';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_mensajes_edoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;

	If cReinicio = '13' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_valedoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 7; INSERT INTO sd_valedoctacrd_clon; " > '||v_ruta ||'queryCargaValedoctaClon.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaValedoctaClon.sql -l '||v_ruta||'sd_valedoctacrd_clon.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '14';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_valedoctacrd_clon', '02') RETURNING P_COD_RET;
	end if;
	
		-- GENERA CIFRAS DE CONTROL PARA COMPARAR QUE TENGA LA MISMA INFORMACION EN LAS TABLAS OPERATIVAS Y CLONADAS Y MIGREN A LAS HISTORICAS
	If cReinicio = '14' then
		select count(*) into iTotalSdEncabezadoEdoctacrd from bdicred:sd_encabezado_edoctacrd where fecha_emision = pFecha;
		select count(*) into iTotalSdEncabezado2Edoctacrd from bdicred:sd_encabezado2_edoctacrd where fecha_emision = pFecha;
		select count(*) into iTotalsdDetalleEdoctacrd from bdicred:sd_detalle_edoctacrd where fecha_emision = pFecha;
		select count(*) into iTotalSdAclaracionesEdoctacrd from bdicred:sd_aclaraciones_edoctacrd where fecha_emision = pFecha;
		select count(*) into iTotalSdPieEdoctacrd from bdicred:sd_pie_edoctacrd where fecha_emision = pFecha;
		select count(*) into iTotalSdMensajesEdoctacrd from bdicred:sd_mensajes_edoctacrd where fecha_emision = pFecha;
		select count(*) into iTotalSdValedoctacrd from bdicred:sd_valedoctacrd where fecha_proc = pFecha;

		select count(*) into iTotalSdEncabezadoEdoctacrdClon from bdicred:sd_encabezado_edoctacrd_clon where fecha_emision = pFecha;
		select count(*) into iTotalSdEncabezado2EdoctacrdClon from bdicred:sd_encabezado2_edoctacrd_clon where fecha_emision = pFecha;
		select count(*) into iTotalsdDetalleEdoctacrdClon from bdicred:sd_detalle_edoctacrd_clon where fecha_emision = pFecha;
		select count(*) into iTotalSdAclaracionesEdoctacrdClon from bdicred:sd_aclaraciones_edoctacrd_clon where fecha_emision = pFecha;
		select count(*) into iTotalSdPieEdoctacrdClon from bdicred:sd_pie_edoctacrd_clon where fecha_emision = pFecha;
		select count(*) into iTotalSdMensajesEdoctacrdClon from bdicred:sd_mensajes_edoctacrd_clon where fecha_emision = pFecha;
		select count(*) into iTotalSdValedoctacrdClon from bdicred:sd_valedoctacrd_clon where fecha_proc = pFecha;
		
		select count(*) into iTotalSdEncabezadoEdoctacrdHist from bdicred:sd_encabezado_edoctacrd_hist where fecha_emision = pFecha;
		select count(*) into iTotalSdEncabezado2EdoctacrdHist from bdicred:sd_encabezado2_edoctacrd_hist where fecha_emision = pFecha;
		select count(*) into iTotalsdDetalleEdoctacrdHist from bdicred:sd_detalle_edoctacrd_hist where fecha_emision = pFecha;
		select count(*) into iTotalSdAclaracionesEdoctacrdHist from bdicred:sd_aclaraciones_edoctacrd_hist where fecha_emision = pFecha;
		select count(*) into iTotalSdPieEdoctacrdHist from bdicred:sd_pie_edoctacrd_hist where fecha_emision = pFecha;
		select count(*) into iTotalSdMensajesEdoctacrdHist from bdicred:sd_mensajes_edoctacrd_hist where fecha_emision = pFecha;
		select count(*) into iTotalSdValedoctacrdHist from bdicred:sd_valedoctacrd_hist where fecha_proc = pFecha;

		LET cMensaje = 'TOTAL Cuentas a depurar : ' ||iTotalSdEncabezadoEdoctacrd;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas EncabezadoEdoctacrd: ' ||iTotalSdEncabezadoEdoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas EncabezadoEdoctacrdClon: ' ||iTotalSdEncabezadoEdoctacrdClon ||'   Cuentas cargadas EncabezadoEdoctacrdHist: ' ||iTotalSdEncabezadoEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas Encabezado2Edoctacrd: ' ||iTotalSdEncabezado2Edoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas Encabezado2EdoctacrdClon: ' ||iTotalSdEncabezado2EdoctacrdClon ||'   Cuentas cargadas Encabezado2EdoctacrdHist: ' ||iTotalSdEncabezado2EdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas DetalleEdoctacrd: ' ||iTotalsdDetalleEdoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas DetalleEdoctacrdClon: ' ||iTotalsdDetalleEdoctacrdClon ||'   Cuentas cargadas DetalleEdoctacrdHist: ' ||iTotalsdDetalleEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas AclaracionesEdoctacrd: ' ||iTotalSdAclaracionesEdoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas AclaracionesEdoctacrdClon: ' ||iTotalSdAclaracionesEdoctacrdClon ||'   Cuentas cargadas AclaracionesEdoctacrdHist: ' ||iTotalSdAclaracionesEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas PieEdoctacrd: ' ||iTotalSdPieEdoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas PieEdoctacrdClon: ' ||iTotalSdPieEdoctacrdClon ||'   Cuentas cargadas PieEdoctacrdHist: ' ||iTotalSdPieEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas MensajesEdoctacrd: ' ||iTotalSdMensajesEdoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas MensajesEdoctacrdClon: ' ||iTotalSdMensajesEdoctacrdClon ||'   Cuentas cargadas MensajesEdoctacrdHist: ' ||iTotalSdMensajesEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		LET cMensaje = '      Cuentas respaldadas ValedoctaEdoctacrd: ' ||iTotalSdValedoctacrd;
		LET cMensaje = trim(cMensaje) ||'   Cuentas cargadas ValedoctaEdoctacrdClon: ' ||iTotalSdValedoctacrdClon ||'   Cuentas cargadas ValedoctaEdoctacrdHist: ' ||iTotalSdValedoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
		
		if iTotalSdEncabezadoEdoctacrd != iTotalSdEncabezadoEdoctacrdClon and iTotalSdEncabezadoEdoctacrdHist > '0' then
			LET cCodRet = '000010';
			LET P_MENSAJE = 'ERROR en cifras de control EncabezadoEdoctacrd ' || iTotalSdEncabezadoEdoctacrd || ' -- ' || iTotalSdEncabezadoEdoctacrdClon || ' -- ' || iTotalSdEncabezadoEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		elif iTotalSdEncabezado2Edoctacrd != iTotalSdEncabezado2EdoctacrdClon and iTotalSdEncabezado2EdoctacrdHist > '0' then
			LET cCodRet = '000020';
			LET P_MENSAJE = 'ERROR en cifras de control Encabezado2Edoctacrd ' || iTotalSdEncabezado2Edoctacrd || ' -- ' || iTotalSdEncabezado2EdoctacrdClon || ' -- ' || iTotalSdEncabezado2EdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		elif iTotalsdDetalleEdoctacrd != iTotalsdDetalleEdoctacrdClon and iTotalsdDetalleEdoctacrdHist > '0' then
			LET cCodRet = '000030';
			LET P_MENSAJE = 'ERROR en cifras de control DetalleEdoctacrd ' || iTotalsdDetalleEdoctacrd || ' -- ' || iTotalsdDetalleEdoctacrdClon || ' -- ' || iTotalsdDetalleEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		elif iTotalSdPieEdoctacrd != iTotalSdPieEdoctacrdClon and iTotalSdPieEdoctacrdHist > '0' then
			LET cCodRet = '000020';
			LET P_MENSAJE = 'ERROR en cifras de control PieEdoctacrd ' || iTotalSdPieEdoctacrd || ' -- ' || iTotalSdPieEdoctacrdClon || ' -- ' || iTotalSdPieEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		elif iTotalSdMensajesEdoctacrd != iTotalSdMensajesEdoctacrdClon and iTotalSdMensajesEdoctacrdHist > '0' then
			LET cCodRet = '000050';
			LET P_MENSAJE = 'ERROR en cifras de control MensajesEdoctacrd ' || iTotalSdMensajesEdoctacrd || ' -- ' || iTotalSdMensajesEdoctacrdClon || ' -- ' || iTotalSdMensajesEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		elif iTotalSdValedoctacrd != iTotalSdValedoctacrdClon and iTotalSdValedoctacrdHist > '0' then
			LET cCodRet = '000060';
			LET P_MENSAJE = 'ERROR en cifras de control ValedoctaEdoctacrd ' || iTotalSdValedoctacrd || ' -- ' || iTotalSdValedoctacrdClon || ' -- ' || iTotalSdValedoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		elif iTotalSdAclaracionesEdoctacrd != iTotalSdAclaracionesEdoctacrdClon and iTotalSdAclaracionesEdoctacrdHist > '0' then
			LET cCodRet = '000070';
			LET P_MENSAJE = 'ERROR en cifras de control AclaracionesEdoctacrd ' || iTotalSdAclaracionesEdoctacrd || ' -- ' || iTotalSdAclaracionesEdoctacrdClon || ' -- ' || iTotalSdAclaracionesEdoctacrdHist;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(P_MENSAJE), '02') RETURNING P_COD_RET;
			RETURN cCodRet,P_MENSAJE;
		end if;
		LET cReinicio = '15';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
	end if;
	
----------------- INICIA CARGA DE INFORMACION A TABLAS HISTORICAS -------------------------------------------------------------	
	If cReinicio = '15' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia carga de informacion a tablas historicas', '02') RETURNING P_COD_RET;
		LET v_sql = '';
		
		LET v_sql = ' echo "FILE '||v_ruta||'sd_encabezado_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 30; INSERT INTO sd_encabezado_edoctacrd_hist; " > '||v_ruta ||'queryCargaEncabezadoHist.sql';
		system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaEncabezadoHist.sql -l '||v_ruta||'sd_encabezado_edoctacrd_hist.log -n 1000 -r';
		system v_sql;

		LET cReinicio = '16';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_encabezado_edoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '16' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_encabezado2_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 33; INSERT INTO sd_encabezado2_edoctacrd_hist; " > '||v_ruta ||'queryCargaEncabezado2.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaEncabezado2.sql -l '||v_ruta||'sd_encabezado2_edoctacrd_hist.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '17';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_encabezado2_edoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '17' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_detalle_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 8; INSERT INTO sd_detalle_edoctacrd_hist; " > '||v_ruta ||'queryCargaDetalle.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaDetalle.sql -l '||v_ruta||'sd_detalle_edoctacrd_hist.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '18';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_detalle_edoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '18' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_aclaraciones_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 9; INSERT INTO sd_aclaraciones_edoctacrd_hist; " > '||v_ruta ||'queryCargaAclaraciones.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaAclaraciones.sql -l '||v_ruta||'sd_aclaraciones_edoctacrd_hist.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '19';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_aclaraciones_edoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '19' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_pie_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 8; INSERT INTO sd_pie_edoctacrd_hist; " > '||v_ruta ||'queryCargaPie.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaPie.sql -l '||v_ruta||'sd_pie_edoctacrd_hist.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '20';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_pie_edoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '20' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_mensajes_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 7; INSERT INTO sd_mensajes_edoctacrd_hist; " > '||v_ruta ||'queryCargaMensajes.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaMensajes.sql -l '||v_ruta||'sd_mensajes_edoctacrd_hist.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '21';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_mensajes_edoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	If cReinicio = '21' then
		LET v_sql = '';
		
        LET v_sql = ' echo "FILE '||v_ruta||'sd_valedoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl DELIMITER '''||'|'||''' 7; INSERT INTO sd_valedoctacrd_hist; " > '||v_ruta ||'queryCargaValedocta.sql';
        system v_sql;

		LET v_sql = 'dbload -d bdicred -c '||v_ruta||'queryCargaValedocta.sql -l '||v_ruta||'sd_valedoctacrd_hist.log -n 1000 -r';
        system v_sql;

		LET cReinicio = '22';
		LET cBandera = '0';
		BEGIN WORK;
		LET cBandera = '1';
		update bdicred:"informix".sd_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='063';
		COMMIT WORK;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina carga a tabla sd_valedoctacrd_hist', '02') RETURNING P_COD_RET;
	end if;
	
	-- INICIA LA DEPURACION DE TABLAS OPERATIVAS
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia depuracion de tablas operativas', '02') RETURNING P_COD_RET;
	
	select num_credito,fecha_emision from bdicred:sd_encabezado_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin
	into temp cuentas_adepurar with no log;
	
	UPDATE STATISTICS MEDIUM FOR TABLE cuentas_adepurar;
	
	LET cBandera = '0';
	FOREACH WITH HOLD
		SELECT num_credito,fecha_emision INTO cNumCredito,dFechaEmision FROM cuentas_adepurar

--		IF icontador=1 then
			BEGIN WORK;
			LET cBandera = '1';
--		END IF;
		
		delete from bdicred:sd_encabezado_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
		delete from bdicred:sd_encabezado2_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
		delete from bdicred:sd_detalle_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
		delete from bdicred:sd_aclaraciones_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
		delete from bdicred:sd_pie_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
		delete from bdicred:sd_mensajes_edoctacrd where fecha_emision = dFechaEmision and num_credito = cNumCredito;
		delete from bdicred:sd_valedoctacrd where fecha_proc = dFechaEmision and num_credito = cNumCredito;
		
--		IF icontador >= 1000 THEN
           COMMIT WORK;
---           LET icontador = 1;
		   LET cBandera = '0';
--		ELSE
           --LET icontador = icontador + 1;
--		END IF;
	END FOREACH;
	
--	LET cBandera = '0';
	BEGIN WORK;
	LET cBandera = '1';
	delete from bdicred:sd_encabezado_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin;
	delete from bdicred:sd_encabezado2_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin;
	delete from bdicred:sd_detalle_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin;
	delete from bdicred:sd_aclaraciones_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin;
	delete from bdicred:sd_pie_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin;
	delete from bdicred:sd_mensajes_edoctacrd where fecha_emision >= dFechaIni and fecha_emision <= dFechaFin;
	delete from bdicred:sd_valedoctacrd where fecha_proc >= dFechaIni and fecha_proc <= dFechaFin;
	COMMIT WORK;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Termina depuracion de tablas operativas', '02') RETURNING P_COD_RET;

	LET cReinicio = '0';
		
	update bdicred:"informix".sd_param
	set valor = cReinicio
	where empresa = '001' AND cod_param='063';

	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Actualiza estadisticas', '02') RETURNING P_COD_RET;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_encabezado_edoctacrd;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_encabezado2_edoctacrd;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_detalle_edoctacrd;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_aclaraciones_edoctacrd;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_pie_edoctacrd;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_mensajes_edoctacrd;
	UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_valedoctacrd;
	
	-- Compactacion de archivos
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_encabezado_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_encabezado2_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_detalle_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_aclaraciones_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_pie_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_mensajes_edoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	LET v_sql = '';
	LET v_sql = "gzip " ||v_ruta||'sd_valedoctacrd_'||to_char(pFecha, '%d%m%Y')||'.unl';
	SYSTEM v_sql;
	
	-- Eliminacion de querys de descarga
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryEncabezado.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryEncabezado2.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryDetalle.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryPie.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryMensajes.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryValedocta.sql';
    SYSTEM v_sql;
	
	LET v_sql = '';
    LET v_sql = "rm "||v_ruta||'queryAclaraciones.sql';
    SYSTEM v_sql;
	
    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

	LET P_MENSAJE = P_MENSAJE || ' ' || P_COD_RET;
	
    RETURN P_COD_RET,P_MENSAJE;

    END
END PROCEDURE;
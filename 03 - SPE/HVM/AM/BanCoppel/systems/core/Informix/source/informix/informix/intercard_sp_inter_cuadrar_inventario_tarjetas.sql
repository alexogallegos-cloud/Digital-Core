CREATE PROCEDURE "informix".sp_inter_cuadrar_inventario_tarjetas()
    RETURNING VARCHAR (5) as rCodigoRetorno, VARCHAR(150) as rMensajeRespuesta, INTEGER as rTopSucursales;

    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);
    
    DEFINE vCODIGO_RETORNO CHAR(5);
    DEFINE vMENSAJE_RETORNO CHAR(120);
    DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE PREFIJO_SCRIPTS VARCHAR(10);
    DEFINE vExecuteSQL LVARCHAR(800);
    DEFINE vClaveSucursal VARCHAR(7);
    DEFINE vClaveTipoTarjeta VARCHAR(2);
    DEFINE vTotalTarjetasExistentes INTEGER;
    DEFINE vTotalTarjetasSolicitadas INTEGER;
    DEFINE vFechaHoy VARCHAR(8);
    DEFINE vClaveSucursalProd VARCHAR(7);
    DEFINE vTipoTarjetaProd VARCHAR(2);
    DEFINE vExistenciasProd INTEGER;
    DEFINE vSolicitadasProd INTEGER;
    DEFINE vConteoDif_Existencias INTEGER;
    DEFINE vConteoDif_Solicitadas INTEGER;
    DEFINE vExisteSucursal INTEGER;
    DEFINE vTopSucursalesMax INTEGER;
    
    LET SQLERR = '';
    LET ISAM_ERR = '';
    LET ERROR_INFO = '';
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET PREFIJO_SCRIPTS = 'inv_suc_';
    
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vExecuteSQL = '';
    LET vClaveTipoTarjeta = '';
    LET vTotalTarjetasExistentes = 0;
    LET vTotalTarjetasSolicitadas = 0;
    LET vFechaHoy = '';
    LET vClaveSucursalProd = 0;
    LET vTipoTarjetaProd = '';
    LET vExistenciasProd = 0;
    LET vSolicitadasProd = 0;
    LET vConteoDif_Existencias = 0;
    LET vConteoDif_Solicitadas = 0;
    LET vClaveSucursal = '';
    LET vExisteSucursal = 0;
    LET vTopSucursalesMax = 0;
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_inter_cuadrar_inventario_tarjetas.out";
    --TRACE ON;

    BEGIN 
        
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_inter_cuadrar_inventario_tarjetas.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = vMENSAJE_RETORNO;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO, vTopSucursalesMax;
            END IF;

        END EXCEPTION
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        LET vFechaHoy = LPAD(DAY(today),2,'0')||MONTH(today)||YEAR(today);
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; ' ||
                ' UNLOAD TO '||RUTA_ORIGEN||'prod_tarjetas_exist_solic_'||vFechaHoy||'.txt '||
                '    SELECT * '||
                '        FROM intercard:\"informix\".sucursal_tipotarjeta;" >'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'inventario_sucursales.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||"inventario_sucursales.sql";
        SYSTEM vExecuteSQL;
        
        ---Crear temporal con cifras considerando el Universo Productivo
        DROP TABLE IF EXISTS tbl_sucursales_enoper;
        SELECT t.*,ts.descripcion
            FROM intercard:sucursal_tipotarjeta t 
                INNER JOIN intercard:sucursal s
                    ON (t.clave_sucursal = s.clave_sucursal) 
                INNER JOIN intercard:tipo_sucursal ts
                    ON (s.tipo_sucursal = ts.tipo_sucursal)
            WHERE s.enoperacion = 'V'
                INTO TEMP tbl_sucursales_enoper WITH NO LOG;

        ---Obtener las tarjetas en existencia.
        SELECT t.numtarjeta, l.numerolote, 
                l.clave_sucursal, l.clave_tipotarjeta
        FROM "informix".lote l 
            INNER JOIN "informix".tarjeta t
        ON (t.numerolote=l.numerolote)
        WHERE t.codstatusasignada = 'NOA' 
            AND t.codstatustarjeta = 'INA'
            AND l.tipoenvio = 'S'
        INTO TEMP tmp_tarjetas_en_suc WITH NO LOG;

        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'Actualizacion Tarjetas Existencia.';
        
        FOREACH curIterarExistentes WITH HOLD FOR
                    
            SELECT a.clave_sucursal, a.clave_tipotarjeta, t.clave_sucursal, t.existencia, COUNT(numtarjeta) as num_tarjetas_existentes
                INTO vClaveSucursal, vClaveTipoTarjeta, vClaveSucursalProd, vExistenciasProd, vTotalTarjetasExistentes
            FROM tmp_tarjetas_en_suc a INNER JOIN tbl_sucursales_enoper t
                ON (a.clave_sucursal = t.clave_sucursal)
            WHERE a.clave_tipotarjeta = t.clave_tipotarjeta
            GROUP BY a.clave_sucursal, a.clave_tipotarjeta, t.clave_sucursal, t.existencia
                ORDER BY 1, 2
            
            --Si las cifras estan cuadradas (productivas contra inventario) no aplica la actualizacion
            IF ( vExistenciasProd = vTotalTarjetasExistentes ) THEN
                CONTINUE FOREACH;
            END IF
            
            UPDATE intercard:"informix".sucursal_tipotarjeta 
                SET  existencia = vTotalTarjetasExistentes
            WHERE clave_tipotarjeta = vClaveTipoTarjeta
                AND clave_sucursal = vClaveSucursal;
                
            SELECT COUNT(*) 
                INTO vExisteSucursal 
            FROM intercard:"informix".tbl_bitacora_cambios_invent_tarjetas 
                WHERE clave_sucursal = vClaveSucursal 
                    AND fecha_ejecucion = today;
            
            LET vConteoDif_Existencias = vConteoDif_Existencias + 1;
            
            IF ( vExisteSucursal = 0 AND vConteoDif_Existencias >= 1) THEN
                INSERT INTO intercard:"informix".tbl_bitacora_cambios_invent_tarjetas (clave_sucursal, contador_cambios_existencias, contador_cambios_solicitadas, fecha_ejecucion) 
                    VALUES ( vClaveSucursal, vConteoDif_Existencias, vConteoDif_Solicitadas, today );
            ELSE
                UPDATE intercard:"informix".tbl_bitacora_cambios_invent_tarjetas
                    SET contador_cambios_existencias = contador_cambios_existencias + vConteoDif_Existencias
                WHERE clave_sucursal = vClaveSucursal
                    AND fecha_ejecucion = today;
                
            END IF
            
            LET vExisteSucursal = 0;
            LET vConteoDif_Existencias = 0;
            LET vConteoDif_Solicitadas = 0;
            
        END FOREACH
        
        ---Obtener las tarjetas previamente solicitadas.
        SELECT
            t.numtarjeta, l.numerolote, 
            l.clave_sucursal, l.clave_tipotarjeta
        FROM "informix".lote l 
            INNER JOIN "informix".tarjeta t
        ON (t.numerolote = l.numerolote)
        WHERE t.codstatusasignada = 'NOE' 
            AND t.codstatustarjeta = 'INA'
            AND l.tipoenvio = 'S'
        INTO TEMP tmp_tarjetas_solicitadas WITH NO LOG;

        LET vExisteSucursal = 0;
        LET vConteoDif_Existencias = 0;
        LET vConteoDif_Solicitadas = 0;
        
        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'Actualizacion Tarjetas Solicitadas.';
        
        FOREACH curIterarSolicitadas WITH HOLD FOR
        
            SELECT a.clave_sucursal, a.clave_tipotarjeta, t.solicitadas, COUNT(numtarjeta) as num_tarjetas_solicitadas
                INTO vClaveSucursal, vClaveTipoTarjeta, vSolicitadasProd, vTotalTarjetasSolicitadas
            FROM tmp_tarjetas_solicitadas a INNER JOIN tbl_sucursales_enoper t
                ON (a.clave_sucursal = t.clave_sucursal)
            WHERE a.clave_tipotarjeta = t.clave_tipotarjeta
                GROUP BY a.clave_sucursal, a.clave_tipotarjeta, t.solicitadas
            ORDER BY 1, 2

            --Si las cifras estan cuadradas (productivas contra inventario) no aplica la actualizacion
            IF ( vSolicitadasProd = vTotalTarjetasSolicitadas ) THEN
                CONTINUE FOREACH;
            END IF
            
            UPDATE intercard:"informix".sucursal_tipotarjeta
                SET solicitadas = vTotalTarjetasSolicitadas
            WHERE clave_tipotarjeta = vClaveTipoTarjeta
                AND clave_sucursal = vClaveSucursal;
            
            SELECT COUNT(*) 
                INTO vExisteSucursal 
            FROM intercard:"informix".tbl_bitacora_cambios_invent_tarjetas 
                WHERE clave_sucursal = vClaveSucursal 
                    AND fecha_ejecucion = today;
            
            LET vConteoDif_Solicitadas = vConteoDif_Solicitadas + 1;
            
            IF ( vExisteSucursal = 0 AND vConteoDif_Solicitadas >= 1) THEN
                INSERT INTO intercard:"informix".tbl_bitacora_cambios_invent_tarjetas (clave_sucursal, contador_cambios_existencias, contador_cambios_solicitadas, fecha_ejecucion) 
                    VALUES ( vClaveSucursal, vConteoDif_Existencias, vConteoDif_Solicitadas, today );
            ELSE
                UPDATE intercard:"informix".tbl_bitacora_cambios_invent_tarjetas
                    SET contador_cambios_solicitadas = contador_cambios_solicitadas + vConteoDif_Solicitadas
                WHERE clave_sucursal = vClaveSucursal
                    AND fecha_ejecucion = today;
                
            END IF

            LET vExisteSucursal = 0;
            LET vConteoDif_Existencias = 0;
            LET vConteoDif_Solicitadas = 0;
            
        END FOREACH
        
        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'Actualizacion Cifras Negativas.';
        
        LET vExisteSucursal = 0;
        LET vConteoDif_Existencias = 0;
        LET vConteoDif_Solicitadas = 0;
        
        FOREACH curIterarExistenciasNegativas WITH HOLD FOR
            
            SELECT clave_sucursal, clave_tipotarjeta, existencia, solicitadas
                INTO vClaveSucursal, vTipoTarjetaProd, vExistenciasProd, vSolicitadasProd
            FROM intercard:"informix".sucursal_tipotarjeta
                ORDER BY clave_sucursal


            IF ( vExistenciasProd < 0  ) THEN
                UPDATE intercard:"informix".sucursal_tipotarjeta 
                    SET existencia = 0
                WHERE clave_sucursal = vClaveSucursal
                    AND clave_tipotarjeta = vTipoTarjetaProd;
                    
                LET vConteoDif_Existencias = vConteoDif_Existencias + 1;
            END IF 
            
            IF ( vSolicitadasProd < 0  ) THEN
                
                UPDATE intercard:"informix".sucursal_tipotarjeta 
                    SET  solicitadas = 0
                WHERE clave_sucursal = vClaveSucursal
                    AND clave_tipotarjeta = vTipoTarjetaProd;
                    
                LET vConteoDif_Solicitadas = vConteoDif_Solicitadas + 1;
                
            END IF
            
            SELECT COUNT(*) 
                INTO vExisteSucursal 
            FROM intercard:"informix".tbl_bitacora_cambios_invent_tarjetas 
                WHERE clave_sucursal = vClaveSucursal 
                    AND fecha_ejecucion = today;
            
            IF ( vExisteSucursal = 0 AND ( vConteoDif_Solicitadas >= 1 OR vConteoDif_Existencias >= 1 ) ) THEN
                INSERT INTO intercard:"informix".tbl_bitacora_cambios_invent_tarjetas (clave_sucursal, contador_cambios_existencias, contador_cambios_solicitadas, fecha_ejecucion) 
                    VALUES ( vClaveSucursal, vConteoDif_Existencias, vConteoDif_Solicitadas, today );
            ELSE
                UPDATE intercard:"informix".tbl_bitacora_cambios_invent_tarjetas
                    SET contador_cambios_existencias = contador_cambios_existencias + vConteoDif_Existencias,
                    contador_cambios_solicitadas = contador_cambios_solicitadas + vConteoDif_Solicitadas
                WHERE clave_sucursal = vClaveSucursal
                    AND fecha_ejecucion = today;
                
            END IF

            LET vExisteSucursal = 0;
            LET vConteoDif_Existencias = 0;
            LET vConteoDif_Solicitadas = 0;

        END FOREACH
        
        SELECT valores 
            INTO vTopSucursalesMax
        FROM intercard:"informix".tbl_inter_parametros
            WHERE cond_busqueda = 'top_inventario_suc';

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; ' ||
                ' UNLOAD TO '||RUTA_ORIGEN||'cuadre_tarjetas_exist_solic_'||vFechaHoy||'.txt '||
                '    SELECT * '||
                '        FROM intercard:\"informix\".sucursal_tipotarjeta;" >'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'cuadre_inventario_sucursales.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||"cuadre_inventario_sucursales.sql";
        SYSTEM vExecuteSQL;


        LET vCODIGO_RETORNO = '00000';
        LET vMENSAJE_RETORNO = 'Actualizacion finalizada.';
        
        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO, vTopSucursalesMax;
        
    END
END PROCEDURE
DOCUMENT
'#1',
'Base de datos: intercard',
'Armando García Ortiz',
'Coordinación de Tarjetas. Gerencia de Mantenimiento 1',
'Fecha de creación: 10 de junio del 2022',
'Implementación para actualizar las cifras de tarjetas empleadas para el inventario de las sucursales.',
'La ejecucion de este proceso se realiza mediante un job a petición del usuario.',
'#2',
'Armando García Ortiz',
'Fecha de modificación: 05 de julio del 2022',
'Actualización y cambio del tipo de dato para las variables de tarjetas existentes y solicitadas',
'Este proceso es ejecutado mediante el job 1051_PROCESO_AUTOMATICO_CUADRAR_INVENTARIO_TARJETAS_PRO'
;

CREATE PROCEDURE "informix".sp_carga_ctes_enrola()
    
    RETURNING VARCHAR(5) as codigo, VARCHAR(100) as mensajedesc, 
        
	INTEGER  as enrolados , INTEGER as noenrolados, INTEGER as yaenrolados;
	
	
    DEFINE CODIGO_RETORNO VARCHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(100);
	DEFINE vTransac SMALLINT;
	DEFINE isam_err  INTEGER;
	DEFINE vsqlerr   INTEGER;
	DEFINE error_info VARCHAR(80);
	DEFINE RUTA_LOAD VARCHAR(30);
	DEFINE NOMBREARCHIVO CHAR(45);
    DEFINE vSufReporte VARCHAR(6);
    DEFINE vFechaHoy VARCHAR(10);
    DEFINE dFechaHoraInicio DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaHoraFin DATETIME YEAR TO FRACTION(5);
	DEFINE cSQL LVARCHAR(1000);
	DEFINE iContReg INTEGER;
	DEFINE vNumtarjeta VARCHAR (16);
	DEFINE vNumtar VARCHAR (16);
	DEFINE vNumcliente VARCHAR (20);
	DEFINE vTitular VARCHAR(1);
	DEFINE vFechaExp date;
	DEFINE vNumtarCVV2 VARCHAR(16);
	DEFINE iNumenrolados INTEGER;
	DEFINE iNumnoenrolados INTEGER;
	DEFINE iNumyaenrolados INTEGER;
	DEFINE vTabla VARCHAR (50);
	DEFINE vCampo VARCHAR (50);
	DEFINE rCodigoRetorno VARCHAR (80);
    DEFINE vPrimerNombre VARCHAR(26);
	DEFINE vSegundoNombre VARCHAR(26);
	DEFINE vPrimerApellido VARCHAR(26);
	DEFINE vSegundoApellido VARCHAR(26);
    DEFINE vNumTelefono VARCHAR(13);
	DEFINE vCorreoElect VARCHAR(100);
	DEFINE VALIDAR_NO VARCHAR(1);
	DEFINE vNumcuenta VARCHAR(20); 
	DEFINE vDebitocredito VARCHAR(1);
	DEFINE pTipoMsj VARCHAR(1);
	DEFINE pIdMsj VARCHAR(10);
	DEFINE pIdPlantilla VARCHAR(12);
	DEFINE pNumclt VARCHAR(20);
	DEFINE pNumcta VARCHAR(20);
	DEFINE pNumTarjeta VARCHAR(16);
	DEFINE vCod_est_tarjeta VARCHAR(3);
	DEFINE pTipoproc VARCHAR(1);
	DEFINE pStr1 VARCHAR(30);
	DEFINE pStr2 VARCHAR(30);
	DEFINE pStr3 VARCHAR(30);
	DEFINE pStr4 VARCHAR (30);
	DEFINE pStr5 VARCHAR(150);
	DEFINE pStr6 VARCHAR(100);
	DEFINE pStr7 VARCHAR(60);
	DEFINE pStr8 VARCHAR(60);
	DEFINE pStr9 VARCHAR(15);
	DEFINE pStr10 VARCHAR(100);
	DEFINE pcorreo_alterno VARCHAR(100);
	DEFINE pcelular_alterno VARCHAR(10);
	DEFINE pImporte1 money (16,2);
	DEFINE pImporte2 money (16,2);
	DEFINE pImporte3 money (16,2);
	DEFINE pImporte4 money (16,2);
	DEFINE pImporte5 money (16,2);
	DEFINE vEnrolado VARCHAR(1);
	DEFINE pfecha1 datetime year to fraction(3);
	DEFINE pfecha2 datetime year to fraction(3);
	DEFINE iConta_plantillas INTEGER;
	DEFINE iNum_renglon INTEGER;
	DEFINE vIdMsj VARCHAR(10);
	DEFINE vIdPlantilla VARCHAR(12);
	DEFINE vTipoproc VARCHAR(1);
	DEFINE iExisten_ctes INTEGER;
		
	
	LET pTipoMsj = '';
	LET  pIdMsj = '';
	LET  pIdPlantilla = '';
	LET pNumclt = '';
	LET pNumcta = '';
	LET pNumTarjeta = '';
	LET pTipoproc = '';
	LET pStr1 = '';
	LET pStr2 = '';
	LET pStr3 = '';
	LET pStr4 = '';
	LET pStr5 = '';
	LET pStr6 = '';
	LET pStr7 = '';
	LET pStr8 = '';
	LET pStr9 = '';
	LET pStr10 = '';
	LET pcorreo_alterno = '';
	LET pcelular_alterno = '';
	LET pImporte1 = '';
	LET pImporte2 = '';
	LET pImporte3 = '';
	LET pImporte4 = '';
	LET pImporte5 = '';
	LET pfecha1 = '';
	LET pfecha2 = '';
	
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
	LET RUTA_LOAD = '/RESPALDOSNEW/';
	LET NOMBREARCHIVO = 'enrolactes.txt';
    LET vFechaHoy = '';
	LET dFechaHoraInicio = '';
	LET dFechaHoraFin = '';
	LET cSQL = '';
	LET iContReg = 0;
	LET vNumtarjeta ='';
	LET vNumcliente='';
	LET vFechaExp = '';
	LET vNumtarCVV2='';
	LET iNumenrolados = 0;
	LET iNumnoenrolados = 0;
	LET iNumyaenrolados = 0;
	LET vtransac = 0;
	
    LET vPrimerNombre = '';
	LET vSegundoNombre = '';
	LET vPrimerApellido = '';
	LET vSegundoApellido = '';
    LET vNumTelefono = '';
	LET vCorreoElect = '';
	LET VALIDAR_NO ='N';
	LET vNumcuenta = '';
	LET  vDebitocredito = '';
	LET vCod_est_tarjeta = '';
	LET vNumtar = '';
	LET iConta_plantillas = 0;
	LET iNum_renglon = 0;
	LET vIdMsj = '';
	LET vIdPlantilla = '';
	LET vTipoproc ='';
	LET iExisten_ctes = 0;
    
    --SET DEBUG FILE TO '/ifxsif01/ilopez/RQM_06_881_Proceso_de_Automatizacion_de_CVV2_dinamico/PRODUCCION/sp_carga_ctes_enrola.out';
    --TRACE ON ;
	--TRACE PROCEDURE;
   
BEGIN	

	--Manejo del error
	ON EXCEPTION SET vsqlerr,isam_err, error_info
        IF vsqlerr <> 0 THEN
			LET  CODIGO_RETORNO = vsqlerr;
			LET  MENSAJE_RETORNO  = error_info;
			--LET  dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
			--LET  dFechaHoraFin = CURRENT YEAR TO FRACTION(5);
			IF vTransac <> 0 THEN --VALIDA SI SE REALIZA EL ROLLBACK
				LET  CODIGO_RETORNO = vsqlerr;
				LET  MENSAJE_RETORNO  = error_info;
				--LET  dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
				--LET  dFechaHoraFin = CURRENT YEAR TO FRACTION(5);
				--ROLLBACK WORK;
			END IF;
				
			RETURN CODIGO_RETORNO,MENSAJE_RETORNO,iNumenrolados, iNumnoenrolados,iNumyaenrolados;			
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    LET dFechaHoraInicio = CURRENT YEAR TO FRACTION(5);
	--Limpiamos tabla para insertar nuevamente los clientes a enrolar.
	TRUNCATE TABLE enrolactescvv2;
	--Se carga la tabla intercard:enrolactescvv2 con el archivo  /RESPALDOSNEW/enrolactes.txt
	LET cSQL = '';
	LET cSQL = "echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(RUTA_LOAD)||TRIM(NOMBREARCHIVO)||" INSERT INTO intercard:enrolactescvv2(";
	LET cSQL = TRIM(cSQL)||"numcte)' | dbaccess sysmaster > /dev/null 2>&1";
	SYSTEM TRIM(cSQL);
		
	-------------------------------------------------------------------
	
	LET iContReg = 0;
	LET vNumcliente = '';
	LET vNumTarjeta = '';
	TRUNCATE TABLE num_ctes;
	--Sacamos los clientes distintos para no repetir nÃºmero cliente en el archivo del usuario
	FOREACH num_clientes WITH HOLD FOR
			
			SELECT distinct(numcte)
			INTO vNumcliente
			FROM enrolactescvv2
			
			IF iContReg=1 THEN
			BEGIN WORK;
			END IF		

			LET vNumcliente = vNumcliente;
	
		
			 INSERT INTO num_ctes(numcte)
			 VALUES(vNumcliente);
		
	
			IF iContReg >= 500 THEN
				COMMIT WORK;
			LET iContReg=1;		
			ELSE
			LET iContReg = iContReg + 1 ;
			END IF;
		
			CONTINUE FOREACH;
	END FOREACH;
	
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
	--Buscamos los clientes Y SUS TARJETAS
	TRUNCATE TABLE ctes_sus_tarjetas;
	LET iContReg = 0;
	LET vNumcliente = '';
	LET vNumtarjeta = '';
	FOREACH cte_tarjetaS WITH HOLD FOR
			SELECT tar.numtarjeta,cte.numcte
			INTO vNumtarjeta,vNumcliente
			FROM intercard:num_ctes cte LEFT JOIN intercard:tarjeta tar
			ON cte.numcte=tar.numcliente
							
			IF iContReg=1 THEN
			BEGIN WORK;
			END IF		
		
			INSERT INTO intercard:ctes_sus_tarjetas(numero_cliente,num_tarjeta)
				VALUES(vNumcliente,vNumtarjeta);
				
			IF iContReg >= 500 THEN
				COMMIT WORK;
			LET iContReg=1;		
			ELSE
			LET iContReg = iContReg + 1 ;
			END IF;
		
			CONTINUE FOREACH;
	END FOREACH;
	
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
	----------------------------------------------------------------------------------------------------------------------
	--Buscamos las tarjetas ya enroladas en la tabla tarjeta_indicadores
	TRUNCATE TABLE ctes_ya_enrolado;
	TRUNCATE TABLE ctes_no_enrolado;
	LET iContReg = 0;
	LET iNumyaenrolados = 0;
	LET vNumcliente = '';
	LET vNumtarjeta = '';
	LET vEnrolado ='';
	LET vNumtarCVV2 ='';
	FOREACH cte_tarjeta WITH HOLD FOR
		
			SELECT cte.numcte,tar.numtarjeta
			INTO vNumcliente,vNumtarjeta
			FROM intercard:num_ctes cte LEFT JOIN intercard:tarjeta tar
			ON cte.numcte = tar.numcliente 
			
			SELECT numtarjeta,cvv2dinamico
			INTO vNumtarCVV2,vEnrolado
			FROM intercard:tarjeta_indicadores
			WHERE numtarjeta=vNumTarjeta;
			
			
			IF iContReg=1 THEN
			BEGIN WORK;
			END IF		
		
			IF vNumtarCVV2 IS NOT NULL AND vEnrolado ='V' THEN 
			 
			INSERT INTO intercard:ctes_ya_enrolado(numero_cliente,num_tarjeta,enrolado)
				VALUES(vNumcliente,vNumtarjeta,'S');
			END IF;
			
			IF vNumtarCVV2 IS NULL OR vEnrolado ='F' THEN
			INSERT INTO intercard:ctes_no_enrolado(numero_cliente,num_tarjeta,enrolado)
				VALUES(vNumcliente,vNumtarjeta,'N');
			
			END IF;
			
			IF iContReg >= 500 THEN
				COMMIT WORK;
			LET iContReg=1;		
			ELSE
			LET iContReg = iContReg + 1 ;
			END IF;
		
			CONTINUE FOREACH;
	END FOREACH;
	
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
	SELECT COUNT(*)
	INTO iNumyaenrolados
	FROM ctes_ya_enrolado;
	
	--Verificamos si tiene el cliente tarjetas ACTIVAS
	LET vFechaExp =(extend(today, year to month) +0 units month)::date;
	
	LET vNumcliente='';
	TRUNCATE TABLE cte_tar_noact;
	LET iContReg = 0;
	--CLIENTES CON TARJETA DIFERENTE DEL ESTATUS  'ACT','INA'
	FOREACH cte_sin_tar WITH HOLD FOR
			
			SELECT DISTINCT(tar.numtarjeta),enr.numero_cliente,tar.codstatustarjeta	
			INTO vNumtarjeta,vNumcliente,vCod_est_tarjeta
			FROM intercard:ctes_no_enrolado enr LEFT JOIN intercard:tarjeta tar
			ON enr.numero_cliente = tar.numcliente --AND enr.num_tarjeta = tar.numtarjeta
			WHERE tar.codstatustarjeta NOT IN ('ACT','INA')
			AND tar.codstatusasignada='SIA' 
			AND (SUBSTR(tar.fechaexp,3,2)||'/'||'01'||'/'||'20'||SUBSTR(tar.fechaexp,1,2) )::date >= vFechaExp
			
			IF iContReg=1 THEN
			BEGIN WORK;
			END IF		
		
			 INSERT INTO cte_tar_noact(numerotarjeta,numcte,estatus_tar)
			 VALUES(vNumtarjeta,vNumcliente,vCod_est_tarjeta);
		
	
			IF iContReg >= 500 THEN
				--BEGIN;
				COMMIT WORK;
			LET iContReg=1;		
			ELSE
			LET iContReg = iContReg + 1 ;
			END IF;
		
			CONTINUE FOREACH;
	END FOREACH;	
	
	IF iContReg > 1 THEN
		COMMIT WORK;
			
	END IF;	
	--NÃºmero de no enrolados
	SELECT count(*) 
	INTO iNumnoenrolados
	FROM cte_tar_noact;
	
	----------------------------------------------------------------------------------------------------------------------------------------
	TRUNCATE TABLE tabla_enrolados;
	
	LET vNumTarjeta ='';
	LET vNumtarCVV2='';
	LET vNumcliente = '';
	LET vTitular ='';
	LET vTabla ='intercard.tarjeta_indicadores';                        
	LET vCampo = 'tarjeta_indicadores.cvv2dinamico';
	LET vEnrolado ='';
	LET iContReg = 0;
	
	--CLIENTES CON NÃMERO DE TARJETA QUE CUMPLE CON 'ACT' , INA , y 'SIA'
	FOREACH cte_tarjeta WITH HOLD FOR
			
			SELECT enr.numero_cliente,tar.numtarjeta,tar.codstatustarjeta	
			INTO vNumcliente,vNumtarjeta,vCod_est_tarjeta
			FROM intercard:ctes_no_enrolado enr LEFT JOIN intercard:tarjeta tar
			ON enr.numero_cliente = tar.numcliente-- AND enr.num_tarjeta = tar.numtarjeta
			WHERE tar.codstatustarjeta IN ('ACT','INA')
			AND tar.codstatusasignada='SIA' 
			AND (SUBSTR(tar.fechaexp,3,2)||'/'||'01'||'/'||'20'||SUBSTR(tar.fechaexp,1,2) )::date >= vFechaExp
				
			IF iContReg=1 THEN
			BEGIN WORK;
			END IF		
	
			SELECT numtarjeta,cvv2dinamico
			INTO vNumtarCVV2,vEnrolado
			FROM intercard:tarjeta_indicadores
			WHERE numtarjeta=vNumTarjeta;
			
			--LET vNumcliente = vNumcliente;
			--LET vNumTarjeta = vNumTarjeta;
			
			--Insertamos registro nuevo de la tarjeta con el valor 'V' Ã³ Actualizamos a 'V' en la tabla tarjeta_indicadores
			IF vNumtarCVV2 IS NULL  THEN 
				INSERT INTO intercard:tarjeta_indicadores(numtarjeta,cvv2dinamico) VALUES (vNumTarjeta,'V');
				INSERT INTO intercard:bitacoracambiostarjeta (secuencial,tarjeta,numcliente,titular,tabla,campo,valoranterior,valornuevo,fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  
				VALUES (0,vNumTarjeta,vNumcliente,vTitular,vTabla,vCampo,'F','V',CURRENT year to fraction(3),USER ,'9','inserta activa cvv2 dinamico' );
				
				
				 INSERT INTO intercard:tabla_enrolados(numerotarjeta,numcte)
					VALUES(vNumtarjeta,vNumcliente);
				
				
				--LET iNumenrolados = iNumenrolados + 1;
							
			ELIF vNumtarCVV2 IS NOT NULL AND vEnrolado ='F'  THEN
				UPDATE intercard:tarjeta_indicadores SET cvv2dinamico='V'
				WHERE numtarjeta = vNumTarjeta;
				INSERT INTO intercard:bitacoracambiostarjeta (secuencial,tarjeta,numcliente,titular,tabla,campo,valoranterior,valornuevo,fechacambio,usuariocambio,identificadorcambio,descripcioncambio)  
				VALUES (0,vNumTarjeta,vNumcliente,vTitular,vTabla,vCampo,'F','V',CURRENT year to fraction(3),USER ,'9','update activa cvv2 dinamico');
				
				 INSERT INTO intercard:tabla_enrolados(numerotarjeta,numcte)
					VALUES(vNumtarjeta,vNumcliente);
				
				--LET iNumenrolados = iNumenrolados + 1;
				
			END IF;
				
				IF iContReg >= 500 THEN
					COMMIT WORK;
				LET iContReg=1;		
				ELSE
				LET iContReg = iContReg + 1 ;
				END IF;
			
			CONTINUE FOREACH;
	END FOREACH;
	
	
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
	--Contamos en NÃºmero de enrolados
	SELECT COUNT(*) INTO iNumenrolados FROM tabla_enrolados;
	---SI NO HAY QUE ENROLAR, TERMINA
	
	IF iNumenrolados = 0 THEN
		LET CODIGO_RETORNO  = '00000';
		LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
		RETURN CODIGO_RETORNO, MENSAJE_RETORNO, iNumenrolados, iNumnoenrolados,iNumyaenrolados;
	
	END IF;

	TRUNCATE TABLE cte_sin_info;
	TRUNCATE TABLE info_cte_enrolado;
	
	LET vNumTarjeta ='';
	LET vNumcliente = '';
	--Buscamos por cada nÃºmero de cliente su informaciÃ³n=>Nombre,Apellido,email y telÃ©fono
	LET iContReg =0;
	FOREACH cteinfoenrolar WITH HOLD FOR
	
		SELECT numerotarjeta,numcte
		INTO vNumTarjeta,vNumcliente
		FROM intercard:tabla_enrolados
		WHERE 1=1
	
	
		IF iContReg=1 THEN
			BEGIN WORK;
		END IF
			
				EXECUTE PROCEDURE intercard:"informix".sp_intercard_info_ctes_por_notif(vNumcliente,VALIDAR_NO)
				INTO CODIGO_RETORNO,MENSAJE_RETORNO,vNumcliente,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect;
					
				--Si no hay informacion del cliente se guardan esos clientes para observaciones.
				IF CODIGO_RETORNO = '00001' THEN
				
					INSERT INTO intercard:cte_sin_info(numcte)
					VALUES(vNumcliente);
				
				END IF;
				
				INSERT INTO intercard:info_cte_enrolado(Numerocliente,Numtarjeta,Primernombre,Segundonombre,Primerapellido,Segundoapellido,Numtelefono,Correoelect)
				VALUES(vNumcliente,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect);
	 

		IF iContReg >= 500 THEN
				
				COMMIT WORK;	
			LET iContReg=1;
		
		ELSE
		LET iContReg = iContReg + 1 ;
		END IF;
			
		CONTINUE FOREACH;
	END FOREACH;
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	----------------------Buscamos el nÃºmero de cuenta en bdicheq:sc_tarjeta y bdicred_sd_tarjeta---------------------------------------------------------------------------------
	
	LET vNumcliente = '';
	LET vNumcuenta = '';
	LET vNumTarjeta = '';
	LET vPrimerNombre = '';
	LET vSegundoNombre = '';
	LET vPrimerApellido = '';
	LET vSegundoApellido = '';
	LET vNumTelefono = '';
	LET vCorreoElect = '';
	LET vDebitocredito = '';
	LET iContReg =0;
	TRUNCATE TABLE info_cte_enrolado2;
	
	FOREACH buscacuenta WITH HOLD FOR
		--buscamos la cuenta de DÃ©bito
		SELECT a.numerocliente,b.cuenta,a.numtarjeta,INITCAP(a.primernombre),INITCAP(a.segundonombre),INITCAP(a.primerapellido),INITCAP(a.segundoapellido),a.numtelefono,a.correoelect,'D'
		INTO vNumcliente,vNumcuenta,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect,vDebitocredito
		FROM intercard:info_cte_enrolado a LEFT JOIN bdicheq:sc_tarjeta b
		ON a.numtarjeta = b.num_tarjeta
		WHERE b.cuenta IS NOT NULL OR  b.cuenta <>''
	
		IF iContReg=1 THEN
			BEGIN WORK;
		END IF
			
			
			INSERT INTO intercard:info_cte_enrolado2(numerocliente,numcuenta,numtarjeta,primernombre,segundonombre,primerapellido,segundoapellido,numtelefono,correoelect,debitocredito)
			VALUES(vNumcliente,vNumcuenta,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect,vDebitocredito);
			
				
		IF iContReg >= 500 THEN
				COMMIT WORK;
			LET iContReg=1;
		
		ELSE
		LET iContReg = iContReg + 1 ;
		END IF;

		CONTINUE FOREACH;

	END FOREACH;
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
	LET vNumcliente = '';
	LET vNumcuenta = '';
	LET vNumTarjeta = '';
	LET vPrimerNombre = '';
	LET vSegundoNombre = '';
	LET vPrimerApellido = '';
	LET vSegundoApellido = '';
	LET vNumTelefono = '';
	LET vCorreoElect = '';
	LET  vDebitocredito = '';
	LET iContReg =0;
	
	
	FOREACH buscacuenta WITH HOLD FOR
		--buscamos la cuenta(num de crÃ©dito) de CrÃ©dito
		SELECT a.numerocliente,b.num_credito,a.numtarjeta,INITCAP(a.primernombre),INITCAP(a.segundonombre),INITCAP(a.primerapellido),INITCAP(a.segundoapellido),a.numtelefono,a.correoelect,'C'
		INTO vNumcliente,vNumcuenta,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect,vDebitocredito
		FROM intercard:info_cte_enrolado a LEFT JOIN bdicred:sd_tarjeta b
		ON a.numtarjeta = b.num_tarjeta
		WHERE b.num_credito IS NOT NULL OR  b.num_credito <>''
	
		IF iContReg=1 THEN
			BEGIN WORK;
		END IF
			
			
			INSERT INTO intercard:info_cte_enrolado2(numerocliente,numcuenta,numtarjeta,primernombre,segundonombre,primerapellido,segundoapellido,numtelefono,correoelect,debitocredito)
			VALUES(vNumcliente,vNumcuenta,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect,vDebitocredito);
			
				
		IF iContReg >= 500 THEN
				COMMIT WORK;
			LET iContReg=1;
		
		ELSE
		LET iContReg = iContReg + 1 ;
		END IF;

		CONTINUE FOREACH;

	END FOREACH;
	IF iContReg > 1 THEN
		COMMIT WORK;
	END IF;
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------ENVÃO LATINIA------------------------------------------------------------------------------------------------
	
	TRUNCATE TABLE error_envio_latinia;
	
	--/ENVIO SMS PARA CADA PLANTILLA REGISTRADA EN intercard:plantilla_sms--INICIO
	LET iContReg = 0;
	LET iConta_plantillas = 0;
	LET vNumcliente = '';
	LET vNumcuenta ='';
	LET vNumTarjeta = '';
	LET vPrimerNombre = '';
	LET vSegundoNombre = '';
	LET vPrimerApellido ='';
	LET vSegundoApellido = '';
	LET vNumTelefono = '';
	LET vCorreoElect = '';
	LET vDebitocredito = '';
	
		SELECT COUNT(*) 
		INTO iConta_plantillas
		FROM plantilla_sms
		WHERE activado = '1';
		
		LET iNum_renglon = 0;
		LET vIdMsj = '';
		LET vIdPlantilla = '';
		LET vTipoproc ='';
		
		WHILE ( iNum_renglon <= iConta_plantillas - 1) LOOP
					
					
			SELECT SKIP iNum_renglon FIRST 1 idMsj,plantilla,tipoproc
			INTO vIdMsj,vIdPlantilla,vTipoproc
			FROM plantilla_sms
			WHERE activado = '1';
	
	
					FOREACH sendlatinia WITH HOLD FOR
						
						SELECT numerocliente,numcuenta,numtarjeta,primernombre,segundonombre,primerapellido,segundoapellido,numtelefono,correoelect,debitocredito
						INTO vNumcliente,vNumcuenta,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect,vDebitocredito
						FROM intercard:info_cte_enrolado2
						WHERE 1=1
						
						IF iContReg=1 THEN
							BEGIN WORK;
						END IF
							
						--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(    '2', 'CMPS_BATCH', 'SORO_HR_AZUL', '000000000',vNumcuenta,pNumTarjeta,  '1'    ,''   ,NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL,  NULL ,    NULL       ,'5541905065'    ,         0    ,         0       ,0        ,0       ,    0     ,current,current)
						--														pTipoMsj,        pIdMsj,   pIdPlantilla,  pNumclt   ,pNumcta   ,pNumTarjeta,pTipoproc,pStr1,pStr2,pStr3,pStr4,pStr5,pStr6,pStr7,pStr8,pStr9,pStr10,pcorreo_alterno,pcelular_alterno,pImporte1 money, pImporte2 money,pImporte3,pImporte4,pImporte5,pfecha1,pfecha2
						
						--Tipo 2  SMS
			  --ejemplo EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', 'CMPS_BATCH', 'SORO_HR_AZUL', '000000000',NULL,NULL,'1','IVAN',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'5541905065',0,0,0,0,0,current,current);
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', vIdMsj,vIdPlantilla, '000000000',NULL,NULL,vTipoproc,vPrimerNombre,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,vNumTelefono,1,0,0,0,0,current,current)
						--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2',vIdMsj,vIdPlantilla,'000000000','','','2',vPrimerNombre,'','','','','','','','','','',vNumTelefono,1,0,0,0,0,current,current)
						INTO CODIGO_RETORNO;
					
						
							IF CODIGO_RETORNO <> '00000' THEN
							
								INSERT INTO intercard:error_envio_latinia(numerocliente,numcuenta,numtarjeta,numtelefono,email_sms,debitocredito)
																VALUES(vNumcliente,vNumcuenta,vNumTarjeta,vNumTelefono,'SMS',vDebitocredito);
							
								LET CODIGO_RETORNO = '00022';
								LET MENSAJE_RETORNO = 'ERROR ENVIO LATINIA';
								
								RETURN CODIGO_RETORNO, MENSAJE_RETORNO, iNumenrolados, iNumnoenrolados,iNumyaenrolados;
							
							END IF;
							
							
						
						/*--Tipo 1 : Correo
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CMPC_BATCH', 'CMC_TP_FE_BC', '000000000','','','1','','6044','','','','','','','','',vCorreoElect,'',0,0,0,0,0,current,current)
																			--pTipoMsj,pIdMsj,pIdPlantilla,pNumclt,pNumcta,pNumTarjeta,pTipoproc,pStr1,pStr2,pStr3,pStr4,pStr5,pStr6,pStr7,pStr8,pStr9,pStr10,pcorreo_alterno,pcelular_alterno,pImporte1 money, pImporte2 money,pImporte3,pImporte4,pImporte5,pfecha1,pfecha2
						INTO CODIGO_RETORNO;
						
							
							IF CODIGO_RETORNO <> '00000' THEN
							
								INSERT INTO intercard:error_envio_latinia(numerocliente,numcuenta,numtarjeta,numtelefono,email_sms,debitocredito)
																	VALUES(vNumcliente,vNumcuenta,vNumTarjeta,vNumTelefono,'EMAIL',vDebitocredito);
									
								LET CODIGO_RETORNO = '00022';
								LET MENSAJE_RETORNO = 'ERROR ENVIO LATINIA';
								
								RETURN CODIGO_RETORNO, MENSAJE_RETORNO, iNumenrolados, iNumnoenrolados,iNumyaenrolados;
							END IF;*/
						
						
						IF iContReg >= 500 THEN
							COMMIT WORK;
						LET iContReg=1;
						
						ELSE
						LET iContReg = iContReg + 1 ;
						END IF;
							
						CONTINUE FOREACH;
					
					END FOREACH;
					LET iNum_renglon = iNum_renglon + 1;
					LET iNum_renglon = iNum_renglon;
	
	
		END LOOP;
		
		IF iContReg >= 1 THEN
			--BEGIN WORK;
			COMMIT WORK;
		END IF;	
	--/ENVIO SMS PARA CADA PLANTILLA REGISTRADA EN intercard:plantilla_sms-- FIN
	

	--/ENVIO E-MAIL PARA CADA PLANTILLA REGISTRADA EN intercard:plantilla_email--INICIO
	LET iContReg = 0;
	LET iConta_plantillas = 0;
	LET vNumcliente = '';
	LET vNumcuenta ='';
	LET vNumTarjeta = '';
	LET vPrimerNombre = '';
	LET vSegundoNombre = '';
	LET vPrimerApellido ='';
	LET vSegundoApellido = '';
	LET vNumTelefono = '';
	LET vCorreoElect = '';
	LET vDebitocredito = '';
		
		SELECT COUNT(*) 
		INTO iConta_plantillas
		FROM plantilla_email
		WHERE activado = '1';
		
		LET iNum_renglon = 0;
		LET vIdMsj = '';
		LET vIdPlantilla = '';
		LET vTipoproc = '';
		
		WHILE ( iNum_renglon <= iConta_plantillas - 1) LOOP
					
					
			SELECT SKIP iNum_renglon FIRST 1 idMsj,plantilla,tipoproc
			INTO vIdMsj,vIdPlantilla,vTipoproc
			FROM plantilla_email
			WHERE activado = '1';
	
	
					FOREACH sendlatinia WITH HOLD FOR
						
						SELECT numerocliente,numcuenta,numtarjeta,primernombre,segundonombre,primerapellido,segundoapellido,numtelefono,correoelect,debitocredito
						INTO vNumcliente,vNumcuenta,vNumTarjeta,vPrimerNombre,vSegundoNombre,vPrimerApellido,vSegundoApellido,vNumTelefono,vCorreoElect,vDebitocredito
						FROM intercard:info_cte_enrolado2
						WHERE 1=1
						
						IF iContReg=1 THEN
							BEGIN WORK;
						END IF
							
						
						--Tipo 1 : Correo
						--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CMPC_BATCH', 'CMC_TP_FE_BC', '000000000','','','1','','6044','','','','','','','','',vCorreoElect,'',0,0,0,0,0,current,current)
	--ejemplo Armando   EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CMPC_BATCH', 'CMC_TP_FE_BC', '000000000','','','1','IVAN','6044','','','','','','','','','ilopez@bancoppel.com','',0,0,0,0,0,current,current);
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',vIdMsj,vIdPlantilla,'000000000','','',vTipoproc,vPrimerNombre,'','','','','','','','','',vCorreoElect,'',1,0,0,0,0,current,current)
																			--pTipoMsj,pIdMsj,pIdPlantilla,pNumclt,pNumcta,pNumTarjeta,pTipoproc,pStr1,pStr2,pStr3,pStr4,pStr5,pStr6,pStr7,pStr8,pStr9,pStr10,pcorreo_alterno,pcelular_alterno,pImporte1 money, pImporte2 money,pImporte3,pImporte4,pImporte5,pfecha1,pfecha2
						INTO CODIGO_RETORNO;
						
							
							IF CODIGO_RETORNO <> '00000' THEN
							
								INSERT INTO intercard:error_envio_latinia(numerocliente,numcuenta,numtarjeta,numtelefono,email_sms,debitocredito)
																	VALUES(vNumcliente,vNumcuenta,vNumTarjeta,vNumTelefono,'EMAIL',vDebitocredito);
									
								LET CODIGO_RETORNO = '00022';
								LET MENSAJE_RETORNO = 'ERROR ENVIO LATINIA';
								
								RETURN CODIGO_RETORNO, MENSAJE_RETORNO, iNumenrolados, iNumnoenrolados,iNumyaenrolados;
							END IF;
						
						
						IF iContReg >= 500 THEN
							COMMIT WORK;
						LET iContReg=1;
						
						ELSE
						LET iContReg = iContReg + 1 ;
						END IF;
							
						CONTINUE FOREACH;
					
					END FOREACH;
					LET iNum_renglon = iNum_renglon + 1;
					LET iNum_renglon = iNum_renglon;
	
		END LOOP;
		
		IF iContReg >= 1 THEN
			COMMIT WORK;
		END IF;	
	
	--/ENVIO E-MAIL PARA CADA PLANTILLA REGISTRADA EN intercard:plantilla_email  FIN
	
	-------------------------------------------------------------------------------------------------------------------------------------------
	SELECT DBINFO('utc_to_datetime', sh_curtime ) INTO dFechaHoraFin	FROM sysmaster:sysshmvals;

	LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    --RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, dFechaHoraInicio, dFechaHoraFin;
	RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, iNumenrolados, iNumnoenrolados,iNumyaenrolados;

END;
END PROCEDURE
DOCUMENT 'AUTOR: IVAN LOPEZ ESCORZA',
'FECHA: 11/AGO/2022',
'MODULO: TARJETAS',
'DESCRIPCION: SPL encargado de automatizar el CVV2 dinamico',
'BD: intercard';

CREATE PROCEDURE "informix".sp_generartarjetas_imagenes(v_indicadortipoproceso varchar(1))
returning varchar(6), varchar(80);

define  p_cod_ret                                 varchar(6);
define  p_mensaje                                 varchar(80);
define  p_cod_ret2                                varchar(6);
define  p_mensaje2                                varchar(80);
define  sql_err                                   integer;
define  isam_err                                  integer;
define  error_info                                varchar(80);
define  v_sucursal                                varchar(5);
define v_tipoimagen                               varchar(2);
---------------------------------
define v_icvv                                     varchar(1);
---------------------------------
define v_cantidad                                 integer;
define v_codproducto                              varchar(3);
define v_tipotarjeta                              varchar(3);
define v_clavetipotarjeta                         varchar(3);
define v_fechaexp                                 varchar(4);
define v_consecutivoguia                          integer;
define v_signumlote                               integer;
define v_contarjeta                               integer;
define v_contxguia                                integer;
define v_signumtarjeta                            integer;
define v_bin                                      varchar(6);
define v_resultmod                                integer;
define v_temp                                     integer;
define v_tempstr                                  varchar(50);
define v_suma                                     integer;
define v_digitoverificador                        integer;
define v_numcuentaasociada                        varchar(13);
define v_numtarjetapormaquilar                    varchar(16);
define v_soportacajeropropio                      varchar(1);
define v_soportacajeroconvenio                    varchar(1);
define v_soportacajerored                         varchar(1);
define v_soportainternacional                     varchar(1);
define v_servicecode                              varchar(3);
define v_contadorxguia                            integer;
define i,j                                        integer;
define v_numtarjetasindigver                      varchar(15);
define prueba                                     integer;
define prueba0                                    integer;
define v_signumtarjetacadena                      varchar(30);
define  v_flagindicadorprocesomaq                 char;
define v_consecutivomaquila                       integer;
define  v_leyendatarjeta                          varchar(28);
define v_direccionsucursal                        varchar(150);
define v_fechahorageneracionproceso               datetime day to fraction;
define v_maxtarjxguia                             integer;
define  ld_detallemaq                             varchar(16);
define v_temconsecutivoguia                       integer;
define v_consecutivo_actual                       integer;
define v_secuencia                                integer;
define v_contadorfinal                            integer;
define temp_consecutivoguia                       integer;
define temp_signumlote                            integer;
define temp_consecutivomaquila                    integer;
define v_prefijo                                  varchar(10);
define v_sufijo                                   varchar(10);
define v_claveproductoimagen                      varchar(3);
define v_consecutivo_archivointeger               integer;
define v_consecutivo_archivocadena                varchar(10);
define v_date                                     date;
define v_registros                                integer;
define v_solicitadas                              integer;
define v_encontro                                 varchar(1);
define v_inserto                                  varchar(1);
define v_banderiar                                varchar(50);
define v_consecutivo_archivo                      varchar(10);
define v_consecutivo                      integer;
define v_tipo                                     varchar(1);
define v_nombre									  varchar(21);
define v_loteactual                               integer;
define tarjetaActual							  varchar(8);
define tarjetaPasada							  varchar(8);
define v_fecha_generacion                         date;
define v_solicitadaslote                          integer;
/*JQL-DebitoChip-20110714 Begin*/
define v_chip                      varchar(6);
/*JQL-DebitoChip-20110714 End*/
/*JQL-DebitoChip-20131211 Begin*/
define v_IdProveedor							  integer;
/*JQL-DebitoChip-20131211 End*/
/*20160906.JHAP.Begin*/
define v_idsolicitud integer;
define v_numcliente varchar(13);
define v_numcuenta varchar(13);
define v_existenumcuenta int;
define v_codprodcta varchar(4);
define v_titular varchar(1);
define v_usuario varchar(10);
define v_tipoenvio varchar(1);
define v_codestatusasignada varchar(3);
define v_fechaasignacion varchar(25);
define v_fechanacimiento varchar(19);
define v_numfolioasignacion int;
define v_canal varchar(30);
define v_numtarjetasustituta varchar(16);
define v_descripcion varchar(60);
define v_flagdiseno varchar(1);
define v_id_diseno int;
define v_mensajeerr varchar(100);
/*20160906.JHAP.End*/
/*20180125.JHAP.Begin*/
define v_EsCVV2Dinamico varchar(100);
/*20180125.JHAP.End*/
/*20181007.JDSO.Begin*/
define v_tipotarjetaAux varchar(3);
/*20181007.JDSO.End*/
/*JDSO-PINOFFLINE-20190414 Begin*/
define v_TecnologiaTarjeta varchar(1);
/*JDSO-PINOFFLINE-20190414 End*/
	--	set debug file to "/tmp/sp_generartarjetas.out";
	--	trace on;
	
let v_solicitadaslote=0;
let tarjetaPasada="";
let tarjetaActual="";
let v_loteactual=0;
let v_nombre="";
let v_tipo="";
let v_clavetipotarjeta="";
let  v_sucursal="";
let  v_tipoimagen="";
let  v_cantidad=0;
let  v_codproducto="";
let  v_tipotarjeta="";
let  v_fechaexp="";
let  v_consecutivoguia=0;
let  v_signumlote=0;
let  v_contarjeta=0;
let  v_contxguia=0;
let  v_signumtarjeta=0;
let  v_bin="";
let  v_resultmod=0;
let  v_temp=0;
let  v_tempstr="";
let  v_suma=0;
let  v_digitoverificador=0;
let  v_numcuentaasociada="";
let  v_numtarjetapormaquilar="";
let  v_soportacajeropropio="";
let  v_soportacajeroconvenio="";
let  v_soportacajerored="";
let  v_soportainternacional="";
let  v_servicecode="";
let  v_contadorxguia=0;
let i=1;
let j=1;
let v_numtarjetasindigver="";
let prueba=0;
let prueba0=0;
let v_signumtarjetacadena="";
let v_consecutivomaquila=0;
let  v_leyendatarjeta="";
let v_direccionsucursal="";
let v_fechahorageneracionproceso= current day to fraction;
let v_maxtarjxguia=0;
let  ld_detallemaq="";
let v_temconsecutivoguia=0;
let v_consecutivo_actual=0;
let v_secuencia=0;
let v_contadorfinal=0;
let temp_consecutivoguia=0;
let temp_signumlote=0;
let temp_consecutivomaquila=0;
let v_prefijo="";
let v_sufijo="";
let v_claveproductoimagen="";
let v_consecutivo_archivointeger=0;
let v_consecutivo_archivocadena="";
let v_registros=0;
let v_solicitadas=0;
let v_date= current day to day;
let v_fecha_generacion=current day to day;
let v_encontro= 'F';
let v_inserto= 'F';
let v_banderiar="";
let v_consecutivo_archivo="";
let v_consecutivo="";
/*JDSO-PINOFFLINE-20190414 Begin*/
let v_TecnologiaTarjeta = "";
/*JDSO-PINOFFLINE-20190414 End*/

/*JQL-DebitoChip-20110714 Begin*/
let v_chip="";
/*JQL-DebitoChip-20110714 End*/
/*JQL-DebitoChip-20131211 Begin*/
let v_IdProveedor=0;
/*JQL-DebitoChip-20131211 End*/
/*20160906.JHAP.Begin*/
let v_idsolicitud=0;
LET v_codestatusasignada = "";
LET v_numcliente = ""; 
LET v_numcuenta = "";
LET v_existenumcuenta = 0;
LET v_codprodcta = "";
LET v_titular = "";
LET v_usuario = "";
LET v_tipoenvio = "";
LET v_fechaasignacion = "";
LET v_fechanacimiento = "";
LET v_canal = "";
LET v_numfolioasignacion=0;
LET v_numtarjetasustituta = "";
LET v_descripcion = "";
LET v_flagdiseno = "";
LET v_id_diseno = 0;
LET v_mensajeerr = "";
/*20160906.JHAP.End*/
/*20181007.JDSO.Begin*/
let v_tipotarjetaAux = "";
/*20181007.JDSO.End*/

--	set debug file to '/tmp/sp_generartarjetas.out';
--	trace on;
	
begin

  on exception set  sql_err  , isam_err, error_info
        Let  p_cod_ret   = sql_err  ;
        Let  p_mensaje  = error_info ;
        ROLLBACK WORK;
        return p_cod_ret, p_mensaje;
  end exception;

  Let  p_cod_ret = '000';
  Let  p_mensaje = 'PROCESO EXITOSO';


BEGIN WORK;

        -- SELECT max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq where fecha_generacion=v_date;

        -- if cast(v_consecutivo_archivocadena as integer) > 0 then
            -- let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
            -- let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));

            -- while (length(v_consecutivo_archivocadena) < 2)
                -- let v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
            -- end while;
            -- let v_consecutivo_archivo=v_consecutivo_archivocadena;
        -- else
            -- let v_consecutivo_archivo = '01';
        -- end if;


	foreach
	/* 20170626.FB.Begin */  
	     /* RQM10907.20170324.JHAP.Begin */      
           /*SELECT distinct clave_sucursal INTO v_sucursal FROM solicitud_maquila order by clave_sucursal */ 
              /*SELECT distinct clave_sucursal, clave_tipotarjeta INTO v_sucursal, v_clavetipotarjeta FROM solicitud_maquila WHERE flagprocesorealizado='F' order by clave_sucursal, clave_tipotarjeta*/
         /* RQM10907.20170324.JHAP.End */ 
	    SELECT  {+AVOID_FULL(solicitud_maquila)} distinct clave_sucursal INTO v_sucursal FROM solicitud_maquila order by clave_sucursal
     /* 20170626.FB.End */ 		
			/*20181007.JDSO.Begin*/
			let v_tipotarjetaAux = "";
			/*20181007.JDSO.End*/
            foreach
                    /*se obtiene los valores de la tabla solicitud maquila, los valores son la clave de la sucursal, tipo de imagen (00,01,02), la cantidad de tarjetas a
                    generar, el producto de las tarjetas (001,501),el tipo de tarjeta (c,d),y por ultimo fechaexp mismas que se guardan en las siguientes variables: v_sucursal, v_tipoimagen,
                    v_cantidad, v_codproducto, v_tipotarjeta y  v_fechaexp */
                    /*20160906.JHAP.Begin*/
                    /*SELECT (sm.clave_tipotarjeta), (sm.cantidad),trim(sm.codproductotarjeta),trim(sm.fechaexp),trim (sm.tipomaquila), trim(sm.nom_cliente),(sm.fecha_generacion),consecutivo
                    INTO  v_clavetipotarjeta,v_cantidad,v_codproducto, v_fechaexp ,v_tipo, v_nombre, v_fecha_generacion,v_consecutivo
                    FROM solicitud_maquila sm where sm.clave_sucursal=v_sucursal and sm.indicadortipoproceso=v_indicadortipoproceso and sm.flagprocesorealizado= 'F'
                    ORDER BY clave_tipotarjeta , tipomaquila ASC*/
                    
                    /* RQM10907.20170324.JHAP.Begin */ 
                    /* RQM10907.20170619.JHAP.Begin */ 
                    /*SELECT (sm.clave_tipotarjeta), (sm.cantidad),trim(sm.codproductotarjeta),trim(sm.fechaexp),trim (sm.tipomaquila), trim(sm.nom_cliente),(sm.fecha_generacion),sm.consecutivo,st.idsolicitud, NVL(st.tipoenvio,''), sm.flagdiseno, sm.id_diseno
                    INTO  v_clavetipotarjeta,v_cantidad,v_codproducto, v_fechaexp ,v_tipo, v_nombre, v_fecha_generacion,v_consecutivo, v_idsolicitud, v_tipoenvio, v_flagdiseno, v_id_diseno
                    FROM solicitud_maquila sm 
                    LEFT OUTER JOIN solicitudtarjeta st ON  sm.clave_sucursal=st.sucursal AND sm.fecha_generacion=st.fechasolicitud 
                                                        AND sm.tipomaquila=st.tipomaquila AND sm.clave_tipotarjeta=st.clave_tipotarjeta 
                                                        AND sm.codproductotarjeta=st.codproductotarjeta AND sm.usuario=LEFT(st.usuario,8)
                                                        AND estatusproceso = 'F' 
                    WHERE sm.clave_sucursal=v_sucursal AND sm.indicadortipoproceso=v_indicadortipoproceso AND sm.flagprocesorealizado= 'F' 
                    ORDER BY sm.clave_tipotarjeta , sm.tipomaquila ASC*/
                    SELECT (sm.clave_tipotarjeta), (sm.cantidad),trim(sm.codproductotarjeta),trim(sm.fechaexp),trim (sm.tipomaquila), trim(sm.nom_cliente),(sm.fecha_generacion),sm.consecutivo,st.idsolicitud, NVL(st.tipoenvio,'S'), sm.flagdiseno, sm.id_diseno
                    INTO  v_clavetipotarjeta,v_cantidad,v_codproducto, v_fechaexp ,v_tipo, v_nombre, v_fecha_generacion,v_consecutivo, v_idsolicitud, v_tipoenvio, v_flagdiseno, v_id_diseno
                    FROM solicitud_maquila sm 
                    LEFT OUTER JOIN solicitudtarjeta st ON  sm.clave_sucursal=st.sucursal AND sm.fecha_generacion=st.fechasolicitud 
                                                        AND sm.tipomaquila=st.tipomaquila AND sm.clave_tipotarjeta=st.clave_tipotarjeta 
                                                        AND sm.codproductotarjeta=st.codproductotarjeta AND sm.usuario=LEFT(st.usuario,8)
                                                        AND estatusproceso = 'F' 
                    WHERE sm.clave_sucursal=v_sucursal AND sm.indicadortipoproceso=v_indicadortipoproceso AND sm.flagprocesorealizado= 'F' 
                    ORDER BY sm.clave_tipotarjeta , sm.tipomaquila ASC
                    /* RQM10907.20170619.JHAP.End */ 
                    /*SELECT (sm.cantidad),trim(sm.codproductotarjeta),trim(sm.fechaexp),trim (sm.tipomaquila), trim(sm.nom_cliente),(sm.fecha_generacion),sm.consecutivo,st.idsolicitud, NVL(st.tipoenvio,''), sm.flagdiseno, sm.id_diseno
                    INTO  v_cantidad,v_codproducto, v_fechaexp ,v_tipo, v_nombre, v_fecha_generacion,v_consecutivo, v_idsolicitud, v_tipoenvio, v_flagdiseno, v_id_diseno
                    FROM solicitud_maquila sm 
                    LEFT OUTER JOIN solicitudtarjeta st ON  sm.clave_sucursal=st.sucursal AND sm.fecha_generacion=st.fechasolicitud 
                                                        AND sm.tipomaquila=st.tipomaquila AND sm.clave_tipotarjeta=st.clave_tipotarjeta 
                                                        AND sm.codproductotarjeta=st.codproductotarjeta AND sm.usuario=LEFT(st.usuario,8)
                                                        AND estatusproceso = 'F' 
                    WHERE sm.clave_sucursal=v_sucursal AND sm.clave_tipotarjeta=v_clavetipotarjeta 
                    AND sm.indicadortipoproceso=v_indicadortipoproceso AND sm.flagprocesorealizado= 'F' 
                    ORDER BY sm.clave_tipotarjeta , sm.tipomaquila ASC*/
                    /* RQM10907.20170324.JHAP.End */ 
                    /*20160906.JHAP.End*/
					
					
					IF v_indicadortipoproceso = 'P' THEN 
						IF v_fecha_generacion = v_date THEN
							CONTINUE FOREACH;						
						END IF;                         
                    END IF ;
					
		   /* IF v_indicadortipoproceso = 'A' THEN 
			 let v_tipo = "A"  ;                 
                    END IF ;*/
			
	       /*SELECT 'Tipo Envio: '  || v_tipoenvio INTO v_mensajeerr FROM parametros;*/
			
                    /*20160906.JHAP.Begin*/		
	            IF v_tipoenvio <> 'D' THEN
	            /*20160906.JHAP.End*/
	            
                            SELECT count(*) INTO v_registros FROM sucursal_tipotarjeta where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
                            if v_registros >0 then
                                /*SELECT solicitadas INTO v_solicitadas FROM sucursal_tipotarjeta where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;*/
                                update sucursal_tipotarjeta set solicitadas=solicitadas+v_cantidad where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;
                                let v_solicitadas=0;
                            else
                                insert INTO sucursal_tipotarjeta(clave_sucursal,clave_tipotarjeta,existencia,solicitadas) values (v_sucursal,v_clavetipotarjeta,0,v_cantidad);
                            end if;
                    
                    /*20160906.JHAP.Begin*/
                    END IF;
                    /*20160906.JHAP.End*/
                    
                    /*se obtiene el consecutivo guia y el siguente numero de lote de la tabla parametros*/
                    /*SELECT consecutivoguia,signumlote,consecutivoarchivomaquila INTO v_consecutivoguia,v_signumlote,v_consecutivomaquila  FROM parametros;*/
                    SELECT maxtarjxguia,consecutivoguia,signumlote INTO v_maxtarjxguia, v_consecutivoguia,v_signumlote  FROM paraminventarios;
					
					/*20181007.JDSO.Begin*/
					if  v_tipotarjetaAux =  v_clavetipotarjeta THEN
						let v_signumlote = v_signumlote -1;
					END IF ;
					/*20181007.JDSO.End*/
					
					
					SELECT provedormaquila INTO v_IdProveedor FROM tipotarjeta WHERE clave_tipotarjeta = v_clavetipotarjeta;
					
					/* 20170626.FB.Begin */  
					/*SELECT max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq WHERE fecha_generacion=v_date AND provedormaquila = v_IdProveedor;*/  
					 SELECT {+AVOID_FULL(bitacora_archivo_maq)} max(consecutivo_archivo) INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq WHERE fecha_generacion=v_date AND provedormaquila = v_IdProveedor;
					/* 20170626.FB.End */
					
					if cast(v_consecutivo_archivocadena as integer) > 0 then
						let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
						let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));
						while (length(v_consecutivo_archivocadena) < 2)
							let v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
						end while;
						let v_consecutivo_archivo=v_consecutivo_archivocadena;
					else
						let v_consecutivo_archivo = '01';
					end if;
					
                    /*JQL-DebitoChip-20110714 Begin*/
                    /*SELECT trim(tt.tipo) INTO v_tipotarjeta FROM tipotarjeta tt where tt.clave_tipotarjeta=v_clavetipotarjeta;*/
                    SELECT trim(tt.tipo), trim(tt.bin), trim(tt.chip) INTO v_tipotarjeta, v_bin, v_chip FROM tipotarjeta tt where tt.clave_tipotarjeta=v_clavetipotarjeta;
                    /*JQL-DebitoChip-20110714 End*/

                    /* se obtiene el maximo de tarjetas por guia para la sucursal*/
                    /*SELECT maxtarjxguia INTO v_maxtarjxguia FROM paraminventarios;*/

                    /* se obtiene el consecutivo con el cual iniciara la generacion de las tarjetas dependiendo de su bin y su tipo de imagen en la tabla
                        consecutivoproductoimagen*/
                    /* se obtiene el servicecode correspondiente de la tarjeta generada y se guarda el valor en la variable v_servicecode*/
                    
                    /*JQL-DebitoChip-20110714 Begin*/
                    SELECT servicecode,prefijo  INTO v_servicecode,v_prefijo FROM bines where bin=v_bin;
                    /*JQL-DebitoChip-20110714 End*/
                    
                    SELECT clave,consecutivo,leyendatarjeta,consecutivo_actual INTO v_claveproductoimagen,v_signumtarjeta, v_leyendatarjeta, v_consecutivo_actual  FROM tipotarjeta where  clave_tipotarjeta=v_clavetipotarjeta;
                    SELECT producto, sufijo INTO v_tipoimagen, v_sufijo FROM productoimagen where clave=v_claveproductoimagen;
					
					/* RQM10907.20170327.JHAP.Begin */
					/*if v_tipo <> 'E' then*/
					if v_tipo = 'N' then
					/* RQM10907.20170327.JHAP.End */
					/*Entra a Maquilas SIN Enbozar*/
					
						let v_nombre = null;
						
						/* sp_generartarjetas.30092015.JHAP.Begin
						--SE AGREGA PROVEEDOR A LA TABLA LOTE
						INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila)
						VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo);
						*/
						/* RQM10907.20170619.JHAP.Begin */ 	
						/*INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor)
						VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor);*/
						/*20181007.JDSO.Begin*/
						/*
						INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor, tipoenvio)
						VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor, v_tipoenvio);
						*/
						/*20181007.JDSO.End*/
						/* RQM10907.20170619.JHAP.End */ 
						/* sp_generartarjetas.30092015.JHAP.End */
						/*20181007.JDSO.Begin*/
						/*INSERT INTO flujolote(numerolote,codflujo,fecha) values (v_signumlote,'GAM',v_fechahorageneracionproceso);*/
						
									
						
						/*20181007.JDSO.Begin*/
						if v_tipotarjetaAux = "" OR v_tipotarjetaAux <>  v_clavetipotarjeta THEN
							let v_tipotarjetaAux = v_clavetipotarjeta;
							INSERT INTO flujolote(numerolote,codflujo,fecha) values (v_signumlote,'GAM',v_fechahorageneracionproceso);
							INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor, tipoenvio)
							VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor, v_tipoenvio);
							UPDATE paraminventarios SET signumlote = v_signumlote+1;
						ELSE
							UPDATE lote SET cantidadtarjetassol = cantidadtarjetassol + v_cantidad WHERE numerolote = v_signumlote;
						END IF ;
						/*20181007.JDSO.End*/
						
						
						
						

						/*Entra a Maquilas Enbozadas*/ 
						
					else
						
						/* RQM10907.20170410.JHAP.Begin */
						/* CAMBIO NO CONSIDERADO EN LA ADECUACION PARA RQM10907 */
						/*let v_leyendatarjeta = v_nombre;*/
						if v_tipo = 'E' then
							let v_leyendatarjeta = v_nombre;
						else
							let v_nombre = null;
						end if
						/* RQM10907.20170410.JHAP.End */
						
						/* RQM10907.20170619.JHAP.Begin */
						/* CASO NO CONSIDERADO, TARJETAS A DOMICILIO DEBEN ESTAR EN UN LOTE SEPARADO*/
						/* PARA EVITAR PROBLEMAS EN RECEPCION  DE TARJETAS */
						/*SELECT numerolote , cantidadtarjetassol INTO v_loteactual , v_solicitadaslote FROM lote WHERE clave_tipotarjeta = v_clavetipotarjeta AND clave_sucursal = v_sucursal AND fechageneracion >= TODAY;*/
						SELECT numerolote, cantidadtarjetassol INTO v_loteactual , v_solicitadaslote FROM lote WHERE clave_tipotarjeta = v_clavetipotarjeta AND clave_sucursal = v_sucursal AND tipoenvio = v_tipoenvio AND fechageneracion >= TODAY;
						/* RQM10907.20170619.JHAP.End */
							if  v_loteactual <> 0  then
								
								let v_signumlote = v_loteactual;
								
								/* RQM10907.20170327.JHAP.Begin */
								/*UPDATE lote SET cantidadtarjetassol =  v_solicitadaslote + 1 WHERE numerolote = v_loteactual AND fechageneracion >= TODAY;*/
								UPDATE lote SET cantidadtarjetassol =  v_solicitadaslote + v_cantidad WHERE numerolote = v_loteactual AND fechageneracion >= TODAY;
								/* RQM10907.20170327.JHAP.End */
								
							else 
										/* sp_generartarjetas.30092015.JHAP.Begin
						    	SE AGREGA PROVEEDOR A LA TABLA LOTE
									INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila)
									VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo);
									*/
									/* RQM10907.20170619.JHAP.Begin */ 
									/*INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor)
									VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor);*/
									INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,clave_tipotarjeta,clave_sucursal,tipomaquila, idProveedor, tipoenvio)
						                        VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,v_clavetipotarjeta,v_sucursal,v_tipo, v_IdProveedor, v_tipoenvio);
						                        /* RQM10907.20170619.JHAP.End */ 
									/* sp_generartarjetas.30092015.JHAP.End */
									
								INSERT INTO flujolote(numerolote,codflujo,fecha) values (v_signumlote,'GAM',v_fechahorageneracionproceso);
								
								UPDATE paraminventarios SET signumlote = v_signumlote+1 ;
								
								
							end if 
					end if 
					
                    /*SELECT max(consecutivo_archivo) 
                    INTO v_consecutivo_archivocadena FROM bitacora_archivo_maq where prefijo_archivo=v_prefijo and sufijo_archivo=v_sufijo and fecha_generacion= v_date;*/

                    /* if cast(v_consecutivo_archivocadena as integer) > 0 then
                    if  v_inserto= 'F' then
                        let  v_consecutivo_archivointeger= cast(v_consecutivo_archivocadena as integer)+1;
                        let v_consecutivo_archivocadena= cast(v_consecutivo_archivointeger as varchar(10));
                        while (length(v_consecutivo_archivocadena) < 2)
                                                let  v_consecutivo_archivocadena= "0" || v_consecutivo_archivocadena;
                        end while;
                        insert INTO bitacora_archivo_maq(prefijo_archivo,sufijo_archivo,fecha_generacion,consecutivo_archivo,cantregistros_archivo,
                                                                                        cantsucursales_archivo, cantguias_archivo, indicadortipoproceso,flagprocesorealizado)
                        values (v_prefijo,v_sufijo,v_fechahorageneracionproceso,v_consecutivo_archivocadena,0,0,0,v_indicadortipoproceso,'F');
                        let  v_inserto= 'V';
                        let v_banderiar= 'por aqui paso';
                    end if;
                            let v_banderiar= 'aqui va';
                            let v_inserto= 'F';
                    else
                            let v_banderiar= 'aqui entro';
                            let v_consecutivo_archivocadena= '01';
                            insert INTO bitacora_archivo_maq(prefijo_archivo,sufijo_archivo,fecha_generacion,consecutivo_archivo,cantregistros_archivo,
                                                                                        cantsucursales_archivo, cantguias_archivo, indicadortipoproceso,flagprocesorealizado)
                            values (v_prefijo,v_sufijo,v_fechahorageneracionproceso,v_consecutivo_archivocadena,0,0,0,v_indicadortipoproceso,'F');
                            let v_inserto= 'V';
                    end if;*/

                    /*se obtiene los parametros de soporta cajero propio, soporta cajero convenio , soporta cajero red y
                    por ultimo si soporta cajero internacional  de la tabla producto tarjeta indicandole que tipo de producto (001,501)
                    es la tarjeta que generamos  y se guardan en las siguiente variables:  v_soportcajeropropio,
                    v_soportcajeroconvenio, v_soportcajerored, v_soportinternacional*/
                    SELECT soportatranatmcajeropropio,soportatranatmcajeroconvenio,soportatranatmcajerored,soportatranatminternacional
                    INTO v_soportacajeropropio, v_soportacajeroconvenio, v_soportacajerored, v_soportainternacional FROM productotarjeta
                    where codproductotarjeta= v_codproducto;

                    /* RQM10907.20170607.JHAP.Begin */
                    /* CAMBIO NO CONSIDERADO EN LA ADECUACION PARA RQM10907 */
                    IF v_tipoenvio <> 'D' THEN
                        /*se obtiene el domicilio de la sucursal*/
                        SELECT direccion_sucursal INTO v_direccionsucursal FROM sucursal where clave_sucursal= v_sucursal;
                    ELSE
                        /*se obtiene el domicilio del cliente*/
                        SELECT TRIM(direccion_calle1) || ', ' || TRIM(direccion_calle2) || ', ' || TRIM(direccion_colonia) || ', ' || TRIM(direccion_municipio) || ', ' || TRIM(direccion_estado) || ', ' || TRIM(direccion_cp) INTO v_direccionsucursal FROM solicitudtarjeta WHERE idsolicitud= v_idsolicitud;
                    END IF;
                    /* RQM10907.20170607.JHAP.End */

                    /*inicia el proceso por cada SELECTe obtiene los datos anteriores y genera las tarjetas insertandolas en la tabla tarjetas, y hsmcard */
                    /*let v_contarjeta=0;*/
                    /*let v_contxguia=0;*/
---------------------------------
                    /*JQL-DebitoChip-20110714 Begin*/
                    /*if v_tipotarjeta = 'C' then
					let v_icvv = 'V';
					else
					 let v_icvv = 'F';
					end if;*/
							if v_chip = 'V' then
					 let v_icvv = 'V';
					else
					 let v_icvv = 'F';
					end if;
                    /*JQL-DebitoChip-20110714 End*/
---------------------------------
                    for i=1 to v_cantidad

                        let v_contadorfinal=v_contadorfinal+1;

                        /* se realiza una condiciÃ?Â³ara identificar cuando incrementar la guia ya que por el momento las guias se generaran de 1000 tarjetas
                        como maximo */
                        /*if v_contarjeta < v_maxtarjxguia+1 and v_contxguia < v_maxtarjxguia  then*/
                        if v_contarjeta < v_maxtarjxguia+1 and v_contxguia < v_maxtarjxguia  then
                            let v_contarjeta = v_contarjeta +1;
                        else
                            let v_contarjeta=0;
                            let v_contxguia=0;

                            UPDATE paraminventarios SET consecutivoguia=v_consecutivoguia+1;
                            SELECT consecutivoguia  INTO v_temconsecutivoguia FROM paraminventarios;
                            /*update parametros set consecutivoguia=v_consecutivoguia+1;
                            SELECT consecutivoguia  INTO v_temconsecutivoguia FROM parametros;*/
                            let v_consecutivoguia=v_temconsecutivoguia;
                        end if;

                        /* se realiza un ciclo para agregarle el 0 a la cadena de bin + el tipo de imagen serian 8 primeros caracteres despues le agrega 0 ceros
                        hasta llegar a la longitud de 15 y que solo falte el ultimo digito verificador por concatenar*/
                        let v_signumtarjetacadena=cast(v_signumtarjeta as varchar(30));

                        /* let prueba0=15 - length(v_bin||v_tipoimagen);
                        let prueba = length(trim(cast(v_signumtarjeta as varchar(30))));*/

                        while length(v_signumtarjetacadena)  <  (15 - length(v_bin||v_tipoimagen))
                                let  v_signumtarjetacadena="0" || v_signumtarjetacadena;
                        end while;

                        let v_numtarjetasindigver=v_bin||v_tipoimagen||v_signumtarjetacadena;

                        if length(v_numtarjetasindigver) <> 15 then
                            Let  p_cod_ret = '001';
                            Let  p_mensaje = 'ERROR AL GENERAR LA LONGITUD DE LA TARJETA DE 15 CARACTERES';
                            ROLLBACK WORK;
                        else
                            let v_suma=0;

                            /* se realiza un ciclo para generar el digito verificar para el num de tarjeta y al final de este ciclo se graba la concatenacion
                            del bin + el tipo de imagen + el siguiente numero de tarjeta a maquilar  + el digito verificador es decir se graba el numero de
                            tarjeta por generar de 16 caracteres en la variable v_numtarjetapormaquilar */

                            for j=1 to length(v_numtarjetasindigver)
                                    /*SELECT mod(j,2) INTO v_resultmod FROM parametros;*/
                                    let  v_resultmod=mod(j,2);
                                    if v_resultmod=0 then
                                            let v_temp = cast(substr(v_numtarjetasindigver, j, 1)as integer) * 1;
                                    else
                                            let v_temp = cast(substr(v_numtarjetasindigver,j, 1)as integer) * 2;
                                    end if;

                                    if v_temp >= 10 Then
                                        let v_tempstr = Trim(cast(v_temp as varchar(30)));
                                        let v_temp = cast(substr(v_tempstr, 1, 1) as integer) + cast(substr(v_tempstr, 2, 1) as integer);
                                    end if;
                                    let v_suma = v_suma + v_temp;
                            end for

                            if 10 - mod(v_suma,10) = 10 Then
                                            let v_digitoverificador = 0;
                            else
                                            let v_digitoverificador = 10 - mod(v_suma,10);
                            end if;

                            let v_numtarjetapormaquilar=v_bin||v_tipoimagen||v_signumtarjetacadena||v_digitoverificador;

                            /* se verifica si hay alguna cuenta asociada a ese num de tarjeta generado realizando una consulta a la tabla tarjetacuenta*/

                            /*   SELECT NumCuenta INTO v_numcuentaasociada FROM tarjetacuenta where NumTarjeta =v_numtarjetapormaquilar;

                            if  length(v_numcuentaasociada ) >= 9 and  length(v_numcuentaasociada ) <= 13 then
                                        let v_signumtarjeta = cast(v_signumtarjeta as integer) + 1;
                            else

                            end if; */
                            let v_signumtarjeta=v_signumtarjeta+1;

                            if v_soportacajeropropio <> 'null' and  v_soportacajeroconvenio <> 'null' and v_soportacajerored<> 'null'
                                and v_soportainternacional<> 'null' then

                                let v_numtarjetapormaquilar = v_numtarjetapormaquilar;
                                
                                /*20160906.JHAP.Begin*/                                
                                IF v_tipo = 'E' AND v_idsolicitud > 0 THEN
                                
                                        /* SE OBTIENEN DATOS PARA PRESONALIZAR EL REGISTO DE TARJETA */
                                        SELECT numcliente, numcuenta, titular, usuario, tipoenvio, CURRENT, canal, NVL(numtarjeta,''), codprodcta
                                        INTO v_numcliente, v_numcuenta, v_titular, v_usuario, v_tipoenvio, v_fechaasignacion, v_canal, v_numtarjetasustituta, v_codprodcta
                                        FROM solicitudtarjeta
                                        WHERE estatusproceso = 'F' AND  idsolicitud= v_idsolicitud;
                                        
                                        IF v_tipoenvio = 'D' THEN
                                                LET v_codestatusasignada = 'SIA';
                                                LET v_fechanacimiento = '1900-01-01 00:00:00';
												/*20180125.JHAP.Begin*/
												SELECT count (*) cuantos
												INTO v_EsCVV2Dinamico
												FROM tarjeta_indicadores ti, tarjeta tj
												WHERE tj.numcliente = v_numcliente and ti.cvv2dinamico = 'V' and tj.numtarjeta = ti.numtarjeta;
												IF v_EsCVV2Dinamico <> '0' THEN
													INSERT INTO tarjeta_indicadores (numtarjeta, enviosmsecommerce, cvv2dinamico) VALUES (v_numtarjetapormaquilar, 'F', 'V');
												END IF;
												/*20180125.JHAP.End*/
                                        ELSE
                                                LET v_codestatusasignada = 'NOE';
                                                LET v_usuario = null;
                                                LET v_fechaasignacion = null;
                                                LET v_fechanacimiento = '';
                                        END IF;
                                        
                                        IF v_numtarjetasustituta = '' THEN
                                                LET v_numtarjetasustituta = null;                                      
                                        
                                                INSERT INTO Tarjeta (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
                                                                    Ciudad,Estado,CodPostal,TelCasa,TelOficina, NumeroLote, FechaExp, SeFabricaPlastico, SeImprimeNIP,
                                                                    CobraComReexpTrj,CobraComReimpNIP,EnRenovacion,NombreCorto,FechaNacimiento,NombrePromotor,
                                                                    CodStatusAsignada, contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
                                                                    acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
                                                                    acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
                                                                    acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
                                                                    acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
                                                                    contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
                                                                    contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
                                                                    conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
                                                                    contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
                                                                    contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
                                                                    acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
                                                                    contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
                                                                    contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
                                                                    acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
                                                                    conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
                                                                    contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
                                                                    soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
                                                                    acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
                                                                    contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
                                                                    contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
                                                                    contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint,numeroguia, usuarioultmodif, fechaultmodif, fechaasignacion, numtarjetasustituta)
                                                                    VALUES  (v_numtarjetapormaquilar,v_codproducto,'INA', v_numcliente, v_titular,v_nombre,'','','','','','','',v_signumlote, v_fechaexp,'V','V','F','F','F','',v_fechanacimiento,'',v_codestatusasignada,0,0.0000,
                                                                    0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
                                                                    0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0000,0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,
                                                                    0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,v_soportacajeropropio, v_soportacajeroconvenio,
                                                                    v_soportainternacional,
                                                                    v_soportacajerored ,0.0000, 0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0, v_consecutivoguia, v_usuario, v_fechaasignacion, v_fechaasignacion, v_numtarjetasustituta);
                                        
                                                LET v_numtarjetasustituta = '';                                      
                                        ELSE
                                                INSERT INTO Tarjeta (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
                                                    Ciudad,Estado,CodPostal,TelCasa,TelOficina, NumeroLote, FechaExp, SeFabricaPlastico, SeImprimeNIP,
                                                    CobraComReexpTrj,CobraComReimpNIP,EnRenovacion,NombreCorto,FechaNacimiento,NombrePromotor,
                                                    CodStatusAsignada, contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
                                                    acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
                                                    acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
                                                    acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
                                                    acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
                                                    contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
                                                    contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
                                                    conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
                                                    contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
                                                    contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
                                                    acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
                                                    contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
                                                    contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
                                                    acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
                                                    conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
                                                    contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
                                                    soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
                                                    acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
                                                    contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
                                                    contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
                                                    contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint,
                                                    acumdiariomotovoz, acumdiariomotoint, acummensualmotovoz, conttransmotovozdiario, conttransmotointdiario,
                                                    conttransmotovozmensual, conttransmotointmensual, contcvv2invalido, acumdiariotag, acummensualtag, conttransdiariotag, conttransmensualtag,
                                                    numeroguia, usuarioultmodif, fechaultmodif, fechaasignacion, numtarjetasustituta)
                                                SELECT v_numtarjetapormaquilar,v_codproducto,'INA',v_numcliente, v_titular,v_nombre,'','','','','','','',
                                                    v_signumlote, v_fechaexp,'V','V','F','F','F','',v_fechanacimiento,'',v_codestatusasignada, 
                                                    contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
                                                    acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
                                                    acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
                                                    acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
                                                    acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
                                                    contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
                                                    contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
                                                    conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
                                                    contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
                                                    contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
                                                    acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
                                                    contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
                                                    contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
                                                    acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
                                                    conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
                                                    contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
                                                    soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
                                                    acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
                                                    contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
                                                    contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
                                                    contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint, 
                                                    acumdiariomotovoz, acumdiariomotoint, acummensualmotovoz, conttransmotovozdiario, conttransmotointdiario,
                                                    conttransmotovozmensual, conttransmotointmensual, contcvv2invalido, acumdiariotag, acummensualtag, conttransdiariotag, conttransmensualtag,
                                                    v_consecutivoguia, v_usuario, v_fechaasignacion, v_fechaasignacion, v_numtarjetasustituta
                                                    FROM Tarjeta WHERE NumTarjeta = v_numtarjetasustituta;
                                              
                                             END IF;
             
                                             IF v_tipoenvio = 'D' THEN
                                             
                                                IF v_numtarjetasustituta = '' THEN
                                                        LET v_descripcion = 'ASIGNACIÃ??N DE TARJETA A DOMICILIO';
                                                ELSE
                                                        LET v_descripcion = 'REPOSICIÃ??N DE TARJETA A DOMICILIO';
                                                        
                                                        /* RQM10907.20170619.JHAP.Begin */ 
                                                        UPDATE tarjeta SET numtarjetasustituta = v_numtarjetapormaquilar WHERE numtarjeta = v_numtarjetasustituta;
                                                        /* RQM10907.20170619.JHAP.End */ 
                                                END IF;
                                                
                                                
                                                /* ISSUE.20221018.JHAP.Begin*/
                                                /*SELECT folioasignacionactivacion INTO v_numfolioasignacion  FROM paraminventarios;*/
                                                SELECT secuencia_folioasignacionactivacion.NEXTVAL INTO v_numfolioasignacion  FROM paraminventarios;
                                                /* ISSUE.20221018.JHAP.End*/
                                                
                                                INSERT INTO bitasignacionactivaciontarjeta (numfolio, numcliente, numcuenta, numtarjeta, descripcion, usuario, canal, sucursal, fecharegistro) 
                                                VALUES (v_numfolioasignacion, v_numcliente, v_numcuenta, v_numtarjetapormaquilar,v_descripcion, v_usuario,v_canal,v_sucursal,v_fechaasignacion);
                                                
                                                /* ISSUE.20221018.JHAP.Begin*/
                                                /*UPDATE paraminventarios SET folioasignacionactivacion = folioasignacionactivacion + 1 ;*/
                                                /* ISSUE.20221018.JHAP.End*/
                                                
                                                INSERT INTO tarjetacuenta (NumCuenta, NumTarjeta) VALUES (v_numcuenta, v_numtarjetapormaquilar);
                                                
                                                SELECT COUNT(numcuenta) INTO v_existenumcuenta FROM cuenta WHERE numcuenta = v_numcuenta;
                                                IF v_existenumcuenta = 0 THEN
                                                        INSERT INTO Cuenta (NumCuenta, CodStatusCuenta, CodProdCta, Saldo, SaldoActualizado)
                	                                VALUES (v_numcuenta, 'A', v_codprodcta, 0.00, 'V');
                                                END IF;
                                             END IF;
                                             
                                             LET v_codestatusasignada = "";
                                             LET v_numcliente = ""; 
                                             LET v_numcuenta = "";
                                             LET v_titular = "";
                                             LET v_usuario = null;
                                             LET v_tipoenvio = "";
                                             LET v_fechaasignacion = null;
                                             LET v_canal = "";
                                             LET v_codprodcta = "";
                                             LET v_existenumcuenta = 0;
                                             LET v_numtarjetasustituta = "";
                                             LET v_descripcion = "";
                                             
                                
                                ELSE
                                /*20160906.JHAP.End*/
                                
                                        /*al verificar que los campos o parametros que nos indica que tipo de cajero soporta esta tarjeta son diferentes de null
                                        , es decir tienen un F o un V entonces insertamos la tarjeta generada, con sus datos correspondientes en la tabla tarjeta */
                                        INSERT INTO Tarjeta (NumTarjeta,CodProductoTarjeta,CodStatusTarjeta,NumCliente,Titular,Nombre,Direccion,ColDeleg,
                                                            Ciudad,Estado,CodPostal,TelCasa,TelOficina, NumeroLote, FechaExp, SeFabricaPlastico, SeImprimeNIP,
                                                            CobraComReexpTrj,CobraComReimpNIP,EnRenovacion,NombreCorto,FechaNacimiento,NombrePromotor,
                                                            CodStatusAsignada, contnipinvalido,acumdiarioretatmnac,acumdiarioretatmint,acummensretatmnac,
                                                            acummensretatmint,acumdiariocompraposnac,acumdiariocompraposint,acummenscompraposnac,
                                                            acummenscompraposint,acumcomconsatmnac,acumcomconsatmint,acumcomretatmnac,acumcomretatmint,
                                                            acumcomcompraposnac,acumcomcompraposint,acumcomrevatmnac,acumcomrevatmint,acumcomrevposnac,
                                                            acumcomrevposint,acumcomfzdaposnac,acumcomfzdaposint,contcomconsatmnac,contcomconsatmint,
                                                            contcomretatmnac,contcomretatmint,contcomcompraposnac,contcomcompraposint,contcomrevatmnac,
                                                            contcomrevatmint,contcomrevposnac,contcomrevposint,contcomfzdaposnac,contcomfzdaposint,
                                                            conttranconsatmlibres,conttranretatmlibres,conttrancompraposlibres,contmaxtranconsatmdiarias,
                                                            contmaxtranretatmdiarias,contmaxtrancompraposdiarias,contmaxtranconsatmmens,contmaxtranretatmmens,
                                                            contmaxtrancompraposmens,acumdiarioretatmpropio,acummensretatmpropio,acumcomconsatmpropio,
                                                            acumcomretatmpropio,acumcomrevatmpropio,contcomconsatmpropio,contcomretatmpropio,
                                                            contcomrevatmpropio,conttranconsatmlibrespropio,conttranretatmlibrespropio,contmaxtranconsatmdiariopropio,
                                                            contmaxtranretatmdiariaspropio,contmaxtranconsatmmenspropio,contmaxtranretatmmenspropio,
                                                            acumdiariocashbacknac,acummenscashbacknac,acumdiariocashadvancenac,acummenscashadvancenac,
                                                            conttrancashbacklibres,conttrancashadvancelibres,contmaxtrancashbackdiarias,contmaxtrancashadvancediarias,
                                                            contmaxtrancashbackmens,contmaxtrancashadvancemens,soportatranatmcajeropropio,soportatranatmcajeroconvenio,
                                                            soportatranatmcajerointernacional,soportetranatmcajerored,acumdiarioretatmconvenio,acummensualretatmconvenio,
                                                            acumcomconsatmconvenio,acumcomretatmconvenio,acumcomrevatmconvenio,contcomconsatmconvenio,
                                                            contcomretatmconvenio, contcomrevatmconvenio,conttranconsatmconveniolibres,conttranretatmconveniolibres,
                                                            contmaxtranconsatmdconveniodiarias, contmaxtranretatmconveniodiarias,contmaxtranconsatmconveniomens,
                                                            contmaxtranretatmconveniomens,limitemenscompraposnac,limitemenscompraposint,numeroguia)
                                                VALUES  (v_numtarjetapormaquilar,v_codproducto,'INA', '','',v_nombre,'','','','','','','',v_signumlote, v_fechaexp,'V','V','F','F','F','','','','NOE',0,0.0000,
                                                            0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,0.0000,
                                                            0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0000,0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,
                                                            0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,v_soportacajeropropio, v_soportacajeroconvenio,
                                                            v_soportainternacional,
                                                            v_soportacajerored ,0.0000, 0.0000,0.0000,0.0000,0.0000,0,0,0,0,0,0,0,0,0,0,0, v_consecutivoguia);
                                /*20160906.JHAP.Begin*/
                                END IF;
                                /*20160906.JHAP.End*/
                                                        /* se inserta la tarjeta generada, el codigo defaul de offset ('0000FFFFFFFF''), la fecha de expiracion de la tarjeta y finalmente
                                                    el servicecode obtenio anteriormente, en la tabla hsmcard*/
---------------------------------
                                /*SELECT 'ANTES DE INSERT hsmcard' INTO v_mensajeerr FROM parametros;*/
                                
                                SELECT v_numtarjetapormaquilar || '-' || v_fechaexp || '-' || v_servicecode || '-' || v_icvv  INTO v_mensajeerr FROM parametros;
                                /*JDSO-PINOFFLINE-20190414 Begin*/
								SELECT card_type INTO v_TecnologiaTarjeta FROM tipotarjeta WHERE clave_tipotarjeta = v_clavetipotarjeta;
								/*  
                                INSERT INTO hsmcard (card_no,card_offset,expirationdate,service_code,icvv)
                                VALUES (v_numtarjetapormaquilar,'0000FFFFFFFF',v_fechaexp,v_servicecode,v_icvv);
								*/
								INSERT INTO hsmcard (card_no,card_offset,expirationdate,service_code,icvv, card_type)
                                VALUES (v_numtarjetapormaquilar,'0000FFFFFFFF',v_fechaexp,v_servicecode,v_icvv, v_TecnologiaTarjeta);
                                /*JDSO-PINOFFLINE-20190414 End*/     
                                /*SELECT 'DESPUES DE INSERT hsmcard ' INTO v_mensajeerr FROM parametros;*/
---------------------------------

                                /* se inserta en flujo tarjeta*/
                                /*insert INTO flujotarjeta (fecha,numtarjeta,codflujo)
                                values (v_fechahorageneracionproceso,v_numtarjetapormaquilar,'GAM');*/

                                /*Se inserta la informaciÃ?Â³ecesaria en la tabla detalle_maquila para la generacion de los archivos para gemalto*/
                                /*SELECT 'ANTES DE INSERT detalle_maquila_transitorio ' INTO v_mensajeerr FROM parametros;*/
                                
                                INSERT INTO detalle_maquila_transitorio (prefijo_archivo,sufijo_archivo,secuencia_maquila,clave_sucursal,domicilio_sucursal,numguia,numtarjeta,
                                            servicecode,leyenda_tarjeta,numlote,fecha_generacion,fecha_expiracion,consecutivo_archivo,
                                            indicadortipoproceso,flagprocesorealizado,provedormaquila, tipomaquila, idsolicitud, idsolmaquila, flagdiseno, id_diseno)
                                    VALUES(v_prefijo, v_sufijo, v_consecutivo_actual,v_sucursal, v_direccionsucursal,v_consecutivoguia,v_numtarjetapormaquilar,
                                            v_servicecode,v_leyendatarjeta,v_signumlote, v_fechahorageneracionproceso,v_fechaexp,v_consecutivo_archivo,v_indicadortipoproceso, 'F',v_IdProveedor,v_tipo,
                                            v_idsolicitud, v_consecutivo, v_flagdiseno, v_id_diseno);
                                            
                                /*SELECT 'DESPUES DE INSERT detalle_maquila_transitorio ' INTO v_mensajeerr FROM parametros;*/
                                /*20160906.JHAP.Begin*/
                                /*
                                IF v_tipo = 'E' AND v_idsolicitud > 0 THEN
                                        INSERT INTO detalle_maquila (prefijo_archivo,sufijo_archivo,secuencia_maquila,clave_sucursal,domicilio_sucursal,numguia,numtarjeta,
                                        servicecode,leyenda_tarjeta,numlote,fecha_generacion,fecha_expiracion,consecutivo_archivo,
                                        indicadortipoproceso,flagprocesorealizado,provedormaquila, tipomaquila, idsolicitud, idsolmaquila, flagdiseno, id_diseno)
                                        VALUES(v_prefijo, v_sufijo, v_consecutivo_actual,v_sucursal, v_direccionsucursal,v_consecutivoguia,v_numtarjetapormaquilar,
                                        v_servicecode,v_leyendatarjeta,v_signumlote, v_fechahorageneracionproceso,v_fechaexp,v_consecutivo_archivo,v_indicadortipoproceso, 'F',v_IdProveedor,v_tipo, v_idsolicitud, v_consecutivo,
                                        v_flagdiseno, v_id_diseno);
                                END IF ;
                                */
                                /*20160906.JHAP.End*/
                                
                                /* se guarda la cantidad de tarjetas que hemos generado en la variable v_contadorxguia y se iguala a la variable
                                v_contxguia para saber cuando hemos llegado a las 1000 y es necesario actualizar el consecutivoguia */
                                /*SELECT count(*) valor INTO v_contadorxguia FROM tarjeta where numeroguia=v_consecutivoguia;*/

                                /* let v_consecutivomaquila= v_consecutivomaquila+1;*/
                                let v_contxguia=v_contxguia+1;
                                let v_consecutivo_actual=v_consecutivo_actual+1;

                            else
                                    Let  p_cod_ret = '003';
                                    Let  p_mensaje = 'ERROR AL OBTENER LOS CAJEROS QUE ACEPTARA LA TARJETA GENERADA';
                                    ROLLBACK WORK;
                            end if;

                       end if;

                    end for

                    /*actualiza cada bloque de insert*/

                    UPDATE tipotarjeta SET consecutivo=v_signumtarjeta, consecutivo_actual= v_consecutivo_actual where clave_tipotarjeta=v_clavetipotarjeta;

                    /* se actualiza el consecutivo de la imagen y bin que generamos en la tabla consecutivoproductoimagen para saber cual sera
                    el siguiente num de tarjeta a maquilar*/
                    /*update consecutivoproductoimagen set consecutivo = v_signumtarjeta where tipo =v_tipotarjeta And producto =v_tipoimagen;*/

                    /* se realiza una insercion a la tabla lotes nuevos de los lotes generados por cada lote generado */
                    /*insert INTO  LotesNuevos (CodProductoTarjeta, NumeroLote,clave_sucursal)
                    values (v_codproducto,v_signumlote, v_sucursal);*/
                    /*INSERT INTO lote(numerolote,fechageneracion,cantidadtarjetassol,fecharecpsuc,cantidadtarjetasrecsuc,clave_tipotarjeta,clave_sucursal)
                    VALUES(v_signumlote,v_fechahorageneracionproceso,v_cantidad,null,0,v_clavetipotarjeta,v_sucursal);*/

			
					/*UPDATE paraminventarios SET  consecutivoarchivomaquila=v_consecutivomaquila ;*/
					
						
				
					

                    /* update parametros set signumlote = v_signumlote+1,consecutivoarchivomaquila=v_consecutivomaquila, flagprocesomaq=0;*/
					
                    /* se actualiza la bandera para identificar que el proceso ya se realizo con un 1 */

                    UPDATE solicitud_maquila SET flagprocesorealizado= 'V' where clave_sucursal=v_sucursal AND clave_tipotarjeta=v_clavetipotarjeta
                    AND cantidad=v_cantidad AND codproductotarjeta=v_codproducto AND fechaexp=v_fechaexp AND indicadortipoproceso=v_indicadortipoproceso AND consecutivo=v_consecutivo;
                    
                    /*20160906.JHAP.Begin*/
                    IF v_tipo = 'E' AND v_idsolicitud > 0 THEN
                    
                        UPDATE solicitudtarjeta SET estatusproceso = 'V' WHERE idsolicitud = v_idsolicitud;
                    
                    END IF;
                    /*20160906.JHAP.End*/
                    
            end foreach;
				
				
				
			/*update parametros set consecutivoguia=v_consecutivoguia+1;*/
			UPDATE paraminventarios SET consecutivoguia=v_consecutivoguia+1;
			let v_contarjeta=0;
			let v_contxguia=0;
    end foreach;
        /*update parametros set consecutivoarchivomaquila=v_consecutivomaquila+v_contadorfinal;*/
        /*update paraminventarios set consecutivoarchivomaquila=v_consecutivomaquila+v_contadorfinal;*/
    UPDATE paraminventarios SET consecutivoarchivomaquila=consecutivoarchivomaquila+v_contadorfinal;
	
	/*SELECT solicitadas INTO v_solicitadas FROM sucursal_tipotarjeta where clave_sucursal=v_sucursal and clave_tipotarjeta=v_clavetipotarjeta;*/
	
    /*JAGA-20120704 Begin*/

    /*
    else
           let  p_cod_ret = '004';
           let  p_mensaje = 'ACTUALMENTE SE ESTA EJECUTANDO EL PROCESO, REINTENTAR MAS TARDE ';
           ROLLBACK WORK;
    end if; */
    /*JAGA-20120704 end*/

    UPDATE paraminventarios SET consecutivoguia=v_consecutivoguia;

    COMMIT WORK;
	
 
	
	
	
    /*update paraminventarios set consecutivoguia=temp_consecutivoguia;*/
    /*update paraminventarios set consecutivoguia=v_consecutivoguia+1;*/

    /*BEGIN WORK;

--    set debug file to '/tmp/sp_generatarjetasxmaquilar.out';
--    trace on;

        Execute Procedure intercard:sp_generasecuencia() INTO p_cod_ret2,p_mensaje2;

    COMMIT WORK;*/

                                   /* delete FROM resumen_maquila;*/
    -- if p_cod_ret= "000" then
     --   update paraminventarios set flagprocesomaq= 'F';
    -- end if;

    return p_cod_ret, p_mensaje;
end;
end procedure;
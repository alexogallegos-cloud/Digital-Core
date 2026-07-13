CREATE PROCEDURE "informix".sp_actualizacion_productointercard()
RETURNING VARCHAR(5), VARCHAR(255);  

--*************************************************************************************************************************************^***
 -- DESCRIPCION: ACTUALIZA EL CÃDIGO DE PRODUCTO DE TARJETAS DE CRÃDITO A LAS CUALES SE LES AUMENTO LA LINEA DE CRÃDITO Y NO HAN SIDO     *
 -- ASIGNADAS AL NUEVO GRUPO DE SEGMENTACIÃN AL QUE PERTENECEN.                                                                           *
 -- AUTOR : Esmeralda J. Figueroa Acosta                                                                                                  *
 -- FECHA : 28/Diciembre/2016                                                                                                             *
 -- BD: intercard                                                                                                                         *
--*****************************************************************************************************************************************
	
    DEFINE vnumcredito              CHAR(20);
    DEFINE vestatuscredito          CHAR(2);
    DEFINE vnumtarjeta              VARCHAR(16);
    DEFINE vcodestatustarjeta       CHAR(3);
    DEFINE vcodproductoanterior     VARCHAR(3);
    DEFINE vcodproductonuevo        VARCHAR(3);
    DEFINE vmontoortorgado          DECIMAL(18,2);
	DEFINE vfecha                   DATETIME YEAR TO FRACTION(5);
	DEFINE vfecha2                  VARCHAR(20);
	DEFINE vsql                     CHAR(1150);
-- VARIABLES PARA EL CONTROL DE ERRORES
	DEFINE  sql_err                 INTEGER;
	DEFINE  isam_err                INTEGER;
	DEFINE  error_info              VARCHAR(80);
	DEFINE  p_cod_ret               VARCHAR(6);
	DEFINE  p_mensaje               VARCHAR(80);
	
--  VARIABLE PARA CONTROL DE CONTADORES
    define  vsflagentransaccion 	CHAR(1);
    define 	vicontadorregistros 	INTEGER;
    define  vmaxnumregistros integer; 


    --SET DEBUG FILE TO "/informix/Esmeralda/trace.out";
    --TRACE ON;	

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION; 

-- INICIALIZACIÃN DE VARIABLES PARA QUERYS
    LET vnumcredito            = '';
    LET vestatuscredito        = '';
    LET vnumtarjeta            = '';
    LET vcodestatustarjeta     = '';
    LET vcodproductoanterior   = '';
    LET vcodproductonuevo      = '';
    LET vmontoortorgado        =  0;
    LET p_cod_ret              = '00000';
    LET p_mensaje              = 'Proceso Exitoso';
    LET vsflagentransaccion    = 'F';
    LET	vicontadorregistros    =   0;
    LET vmaxnumregistros       = 1000;
	LET vfecha				   = sysdate; 
	LET vfecha2                = '';
	LET vfecha2                = SUBSTR(EXTEND(vfecha - 0 UNITS MONTH, YEAR TO SECOND),1,19);
	LET vfecha2                = SUBSTR(vfecha2,1,10)||'_'||SUBSTR(vfecha2,12,2)||SUBSTR(vfecha2,15,2)||SUBSTR(vfecha2,18,2);
	
	
        -- VERIFICA SI EXISTE LA TABLA TEMPORAL, DE SER ASÃ LA ELIMINA
		SET ISOLATION TO DIRTY READ ;
        IF EXISTS ( SELECT dbsname, tabname FROM  sysmaster:SysTabNames  WHERE tabname = 'tmp_actualizacion_productointercard' AND dbsname= 'intercard') THEN
            DROP TABLE intercard:tmp_actualizacion_productointercard;
        END IF;	
		
		--CREACIÃN DE TABLA TEMPORAL PARA EL ALMACENAMIENTO DE LA INFORMACIÃN A ACTUALIZAR
		CREATE TABLE informix.tmp_actualizacion_productointercard ( 
		num_credito               CHAR(20),
		status_cred       		  CHAR(2),
		num_tarjeta   		      CHAR(16),
		codstatustarjeta          CHAR(3),
		codproductotar_actual     VARCHAR(3),
		codproductotar_nuevo      VARCHAR(3),
		monto_otorgado            DECIMAL(18,2)
		)EXTENT SIZE 1650 NEXT SIZE 165 LOCK MODE ROW;
		
        --OBTIENE EL LISTADO DE TODAS LAS CUENTAS QUE NECESITAN ACTUALIZACIÃN DE PRODUCTO INTERCARD Y LAS INSERTA EN LA TABLA TEMPORAL
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
		INSERT INTO tmp_actualizacion_productointercard(num_credito,status_cred,num_tarjeta,codstatustarjeta,codproductotar_actual,codproductotar_nuevo,monto_otorgado)  
        SELECT
            cred.num_credito AS numero_credito,
            cred.status_cred AS estatus_credito,
            tar.numtarjeta AS numero_tarjeta,
            tar.codstatustarjeta AS estatus_tarjeta, 
            tar.codproductotarjeta AS codigo_producto_Actual,
            CASE
                WHEN tar.codproductotarjeta = '001' and  sdos.monto_otorgado > 15000 and sdos.monto_otorgado <= 60000 THEN '003'
                WHEN tar.codproductotarjeta = '001' and  sdos.monto_otorgado > 60000 THEN '002'
                WHEN tar.codproductotarjeta = '003' and  sdos.monto_otorgado > 60000 THEN '002'
            ELSE 'N/A'
            END AS ProductoIntercard_Nuevo,
            sdos.monto_otorgado AS lineacredito_actual
        FROM bdicred:sd_maesdos sdos
            INNER JOIN bdicred:sd_maecred cred ON sdos.num_credito= cred.num_credito
            INNER JOIN bdicred:sd_tarjeta stj ON cred.num_credito = stj.num_credito
            INNER JOIN intercard:tarjetacuenta cta ON stj.num_tarjeta = cta.numtarjeta
            INNER JOIN intercard:tarjeta tar ON cta.numtarjeta = tar.numtarjeta
            INNER JOIN intercard:segmentoproducto seg ON tar.codproductotarjeta = seg.codproductotarjeta
        WHERE tar.codproductotarjeta IN ('001','003') 
            AND cred.status_cred IN ('AA','E1') 
			AND (sdos.monto_vencido + sdos.mto_venc_trasp) = 0
            AND tar.codstatustarjeta = 'ACT'
			AND tar.codstatusasignada = 'SIA'
            AND ((tar.codproductotarjeta = '001' and  sdos.monto_otorgado > 15000 and sdos.monto_otorgado <= 60000)
            OR (tar.codproductotarjeta = '001' and  sdos.monto_otorgado > 60000)
            OR (tar.codproductotarjeta = '003' and  sdos.monto_otorgado > 60000));
        	
       
	   -- RECORRE CADA REGISTRO DE LA TABLA TEMPORAL PARA REALIZAR LA ACTUALIZACIÃN DEL CÃDIGO DE PRODUCTO DE LAS CUENTAS EN LA TABLA INTERCARD:TARJETA
       SET LOCK MODE TO WAIT 3;
	   SET ISOLATION TO DIRTY READ;
	   FOREACH cursor1 WITH HOLD
        FOR 
			
            SELECT num_credito,num_tarjeta,codstatustarjeta,codproductotar_nuevo   
                INTO vnumcredito,vnumtarjeta,vcodestatustarjeta,vcodproductonuevo
            FROM tmp_actualizacion_productointercard
            

        --ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (vsFlagEnTransaccion = 'F') THEN
			 BEGIN WORK;
			 LET vsFlagEnTransaccion = 'V';
		END IF;
   
		IF (vcodestatustarjeta = 'ACT') THEN
			UPDATE intercard:tarjeta SET codproductotarjeta=vcodproductonuevo
			WHERE numtarjeta=vnumtarjeta;
        END IF;   
		
           LET vicontadorregistros = vicontadorregistros + 1;   
               IF (vicontadorregistros = vmaxnumregistros) then
                    COMMIT WORK;
                    LET vsflagentransaccion = 'F';
                    LET vicontadorregistros = 0;
                    CONTINUE FOREACH;
                END IF;		
       END FOREACH;
	   
	   
       --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
       IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN 
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
       END IF;
       
	        --GENERACIÃN DE REPORTE DE LAS CUENTAS DE TARJETAs ACTUALIZADAS
	        LET vsql = ''; 	   
			LET vsql=  'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 4; UNLOAD TO /resplogifx/actualizacion_codproductotar_'||vfecha2||'.unl SELECT num_credito,status_cred,num_tarjeta,codstatustarjeta,codproductotar_actual,codproductotar_nuevo,monto_otorgado FROM tmp_actualizacion_productointercard; " >/resplogifx/retx.sql'; 
			SYSTEM vsql;
			LET vsql ='';
			LET vsql= 'dbaccess intercard /resplogifx/retx.sql';
			SYSTEM vsql;
			LET vsql ='rm /resplogifx/retx.sql';
			SYSTEM vsql;
			LET vsql ='';
			LET vsql = "sed 's/|$//g' /resplogifx/actualizacion_codproductotar_"||vfecha2||".unl"; 
			SYSTEM vsql;
			LET vsql ='';
			
	  DROP TABLE tmp_actualizacion_productointercard;
	   
	   RETURN P_COD_RET,P_MENSAJE; 
END;  
END PROCEDURE;
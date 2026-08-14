CREATE PROCEDURE "informix".sp_reporte_controltarjetas(psSucursal CHAR(5)) 
                returnING VARCHAR(5) AS CodRetorno, VARCHAR(50) AS DescRetorno;


    /*VARIABLES PARA RETORNO*/
    DEFINE CodRetorno               	 VARCHAR(5);
    DEFINE DescRetorno              	 VARCHAR(50);

    /*VARIABLES PARA CONTROL DE ERRORES*/
    DEFINE viSqlErr                 	 INTEGER;
    DEFINE viSamErr                      INTEGER;

    /*VARIABLES PARA EL CONTROL DE CONTADORES*/
    DEFINE  vsflagentransaccion     	 CHAR(1);
    DEFINE 	vicontadorregistros 		 INTEGER;
    DEFINE  vicontadorregistros2 		 INTEGER;

    -- variable proceso
    DEFINE vcenoperacion                    CHAR(1);

    DEFINE v_empresa                        char (3);
    DEFINE v_sucursal                       CHAR(5);
    DEFINE v_numtarjeta                     varchar (16);
    DEFINE v_numerolote                     integer;
    DEFINE v_codstatustarjeta               varchar(3);
    DEFINE v_clave_tipotarjeta              integer;
    DEFINE v_banderaregistro                integer;
    define v1                               char(10);
    define v2                               char(10);


    --SET DEBUG FILE TO "/ifxsif01/_argoz/lecciones/exp_sp_reporte_controltarjetas.out";
    --TRACE ON;


    /*INICIALIZACION VARIABLES*/

    LET 	CodRetorno = '00000';
    LET 	DescRetorno = 'Ejecucion de proceso exitosa.';
    LET  viSqlErr = 0;
    LET 	viSamErr = 0;
    LET 	vsflagentransaccion = 'F';
    LET	vicontadorregistros = 0;
    LET  vicontadorregistros2 = 0;	
    LET v_empresa   = '';
    LET v_sucursal    = '';
    LET v_numtarjeta           = '';
    LET v_numerolote    = '';
    LET v_codstatustarjeta  = 0;
    LET v_clave_tipotarjeta         = 0;
    LET v_banderaregistro        = 0;
    LET vcenoperacion        = '';
    LET v1                   = '';
    LET v2                   = '';

BEGIN

	ON EXCEPTION
		SET viSqlErr, viSamErr
		LET CodRetorno = viSqlErr;
		LET DescRetorno = viSamErr;
		return CodRetorno, DescRetorno;
	END EXCEPTION;

	
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;	
	/*Control y Admon. de Tarjetas ActualizaciÃ³n Inventario Sucursal */  

-- PASO 1
--validacion Parametro
   select enoperacion into vcenoperacion
   from "informix".sucursal
   where clave_sucursal= psSucursal;
   


--return cCodRet,
   if (vcenoperacion='F')
   then
   LET DescRetorno = "Error, la sucursal no se encuentra en operacion";
   LET CodRetorno = '00001';
		return CodRetorno, DescRetorno;
   end if;
   


    --validacion existencia sucursal--return cCodRet,
    if(vcenoperacion = "") or (vcenoperacion is NULL)
    then
    LET DescRetorno = "Error, la sucursal no existe";
    LET CodRetorno = '00002';
    return CodRetorno, DescRetorno;
    end if;


        
--paso 2   
-- Validar existencia de registro de sucursal en control_inventario

select first 1 tt_sucursal
into v_sucursal
from "informix".control_inventario
where tt_sucursal = psSucursal;

    IF (v_sucursal <> '') THEN
        delete "informix".control_inventario
            where tt_sucursal = v_sucursal;
    END IF;

    -- paso 3 alimentacion tabla control_inventario		
    INSERT  INTO "informix".control_inventario(tt_empresa, tt_sucursal, tt_numerotarjeta, 
        tt_numerolote, tt_statustarjeta,tt_tipotarjeta, tt_banderaregistro) 
    select '001', psSucursal , tjt.numtarjeta, lte.numerolote, tjt.codstatustarjeta, 
          case tpo.tipo
              when 'D' then '1'
              when 'C' then '2'
          end as tipotarjeta, 0
    from tarjeta tjt,lote lte, tipotarjeta tpo
    where tjt.numerolote = lte.numerolote
       and lte.clave_tipotarjeta = tpo.clave_tipotarjeta
       and lte.clave_sucursal= psSucursal 
       and tjt.codstatustarjeta='INA'
       and tjt.codstatusasignada='NOA'
    order by lte.numerolote, tjt.numtarjeta;

			
INSERT  INTO "informix".control_inventario_ejecucion(tt_clave_sucursal, tt_clave_tipotarjeta, tt_usuario, tt_fechahora, tt_inventario) 
		select ci.tt_sucursal,ci.tt_tipotarjeta, user, current, count (*) from "informix".control_inventario ci
        where 	ci.tt_sucursal=psSucursal
group by 1,2,3,4;				 
	
		return CodRetorno, DescRetorno;
END;
END PROCEDURE;
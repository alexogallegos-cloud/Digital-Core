CREATE PROCEDURE "informix".sp_corrige_segmento( )
RETURNING	CHAR(6)		AS	CODIGO_RET;

--DEFINICION DE VARIABLES
DEFINE cCod_ret             CHAR(6);
DEFINE sSql_err             INTEGER;
DEFINE sIsam_err            INTEGER;
DEFINE cError_info          CHAR(40);
DEFINE vNumTarjeta	    	CHAR(20);
DEFINE iContador			INTEGER;

-- INICIALIZAR VARIABLES
LET cCod_ret            = '000000';
LET sSql_err			= 0;
LET sIsam_err			= 0;
LET cError_info         = '';
LET vNumTarjeta			= '';
Let iContador			= 0;

BEGIN

ON EXCEPTION SET sSql_err, sIsam_err, cError_info		
	IF sSql_err <> 0 THEN
		ROLLBACK;
		TRACE ON;
		LET cCod_ret = sSql_err;
		RETURN	NVL(TRIM(cCod_ret), '');
	END IF;	  
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;

--SET DEBUG FILE TO "/informix/c91691184/Cutberto/sp_corrige_segmento.out";
--TRACE ON;

FOREACH with hold
	select 	tjt.numtarjeta
	INTO 	vNumTarjeta
	from intercard:"informix".tarjeta tjt inner join bdicred:"informix".sd_tarjeta tar on
	tar.num_tarjeta = tjt.numtarjeta
	inner join bdicred:"informix".sd_maecred b ON
	b.empresa = tar.empresa and b.num_credito = tar.num_credito
	inner join bdicred:"informix".sd_maesdos a ON
	a.empresa = b.empresa and a.num_credito = b.num_credito 
	where a.monto_otorgado >15000 and  a.monto_otorgado <=60000   
	and b.status_cred in ('AA','BA','BT','E1','E2','E3') 
	and tar.status_tar = 'A'
	and codproductotarjeta <> '003'
	and tjt.codstatustarjeta in('ACT','BLT','BLO') 

	if iContador = 0 THEN

		BEGIN;

	END IF;

	update intercard:"informix".tarjeta 
	set  codproductotarjeta = '003' 
	where numtarjeta = trim(vNumTarjeta);

	Let iContador = iContador + 1;

	if iContador = 1000 THEN

		COMMIT;
		Let iContador = 0;

	end if;

END FOREACH;

	if iContador > 0 THEN

		COMMIT;

	end if;

	RETURN	NVL(TRIM(cCod_ret), '');

END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDURE QUE ASIGNARA EL SEGMENTO CORRECTO',
'FECHA DE CREACION: 07-05-2013',
'BASE DE DATOS: INTERCARD',
'AUTOR: CUTBERTO GONZALEZ',
'VERSION: 20130507.1310';

CREATE PROCEDURE "informix".sp_obtencion_tarjetapivote(psProceso char(3), pdFechaPivoteInicial date, pdFechaPivoteFinal date, psLimpiaTabla char(1))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
--Este SP obtiene a partir de una Fecha Inicial, Fecha Final, y un tipo de proceso definido un rango de tarjetas a limpiar
--la tabla de tarjetas Pivote se quedarÃÂ¡ poblada hasta que todas las tarjetas estÃÂ©n depuradas y se indique el parÃÂ¡metro psLimpiaTabla = 'V'
--piProceso : Indica el proceso de DepuraciÃÂ³n a Ejecutar 
--            EXP - Tarjetas Expiradas
--            CAN - Tarjetas NO Operables por Estatus CAN , DES, EXT, ROB, FAL, DAN
--            BEN - Tarjetas de Cuentas en Beneficencia PÃÂºblica
--            VND - Tarjetas de Cuentas en Cartera Vendida
--pdFechaPivote : Indica la fecha Pivote a partir del cual se va a depurar las tablas, es decir, a partir de ÃÂ©sta fecha se mantendran los datos
--piCommit : Indica cada cuantos Registros realizarÃÂ¡ el Commit
--pLimpiaTabla : 'V' Indica que se limpiara la tabla pivote tarjetapivote_depuracion para repoblarla de cero
--               'F' Indica que no se llevarÃÂ¡ limpieza de la tabla pivote tarjetapivote_depuracion y partira de la misma para la depuraciÃÂ³n.

	--  Variables de Errores y datos de SP
	define  sql_err          integer; 
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	define  vdfechaInicial       date;	
	define  vdfechaFinal       date;	
	
   	--  Variables para control de contadores
	--define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vconsecutivo		integer;
	define 	varchivoorigen  	CHAR(3);
    define  vdtFechaPivoteInicial DATETIME YEAR to FRACTION(5);    
	define  vdtFechaPivoteFinal   DATETIME YEAR to FRACTION(5);    
    define 	vnombrearchivo   	CHAR(23);
	--define  vperiododepuracion  integer;
	--define  vmaxnumregistros integer;
	define  vsecuencia  varchar (7);
	define  vnumcuenta varchar(13) ;
	define  vnumtarjeta  varchar (16);		
	--define  vfechalocaltransaccion  varchar (4);
	--define  vhoralocaltransaccion  varchar (6);
	
	--Variables para obtenciÃÂ³n de Periodos de ExtracciÃÂ³n
	define vfechaExpiracionInicial varchar(4);
	define vfechaExpiracionFinal varchar(4);
   	
    --SET DEBUG FILE TO "/resplogifx/sp_obtencion_tarjetapivote.out";
    --TRACE ON;


BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vconsecutivo = 0;
	let 	varchivoorigen = '';    
    let 	vnombrearchivo = '';
--let     vperiododepuracion =0;
	let     vsecuencia='';
	let     vnumtarjeta='';
	let     vnumcuenta = '';
--let     vfechalocaltransaccion='';
--let     vhoralocaltransaccion='';
--let     vmaxnumregistros=0;
--let 	  vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let     p_cod_ret = '00000';
	let     p_mensaje = 'Proceso Exitoso';
	
    LET vfechaExpiracionInicial =  ((substring(LPAD(year(pdFechaPivoteInicial),4,0)from 3 for 2)) || LPAD(month(pdFechaPivoteInicial),2,0) );  ---'aamm'
	LET vfechaExpiracionFinal = ((substring(LPAD(year(pdFechaPivoteFinal),4,0)from 3 for 2)) || LPAD(month(pdFechaPivoteFinal),2,0));  ---'aamm'

    LET vdtFechaPivoteInicial = pdFechaPivoteInicial;
	LET vdtFechaPivoteInicial = SUBSTRING(vdtFechaPivoteInicial FROM 1 FOR 10) || ' 00:00:00';
    LET vdtFechaPivoteFinal = pdFechaPivoteFinal;
	LET vdtFechaPivoteFinal = SUBSTRING(vdtFechaPivoteFinal FROM 1 FOR 10) || ' 23:59:59';
	
--De acuerdo al tipo de proceso se llenarÃÂ¡ la tabla de depuraciÃÂ³n de tarjetas

    IF (psLimpiaTabla = 'V') THEN
	   truncate table tarjetapivote_depuracion;
	END IF;
     
--------------------------------------------------------------------------------------------------------------	 
  
	drop table if exists  intercard:"informix".paso_cruzado;
	
	set isolation to dirty read;  
	set lock mode to wait 3; 
 
	select   a.num_tarjeta
    from bdicred:sd_tarjeta a
        inner join intercard:tarjetacuenta b
            on (a.num_tarjeta = b.numtarjeta)  
        inner join bdicred:sd_maecred c
            on (a.num_credito = c.num_credito)
        inner join bdicred:sd_maecred d
            on (b.numcuenta = d.num_credito)   
    where (d.status_cred = 'CV' and c.status_cred IN ('AA', 'BA', 'BT', 'FC', 'FI','E1','E2','E3'))
    AND a.empresa = c.empresa
    AND c.empresa = d.empresa
    AND (a.status_tar IN ('A', 'I', 'C'))
    AND a.num_credito <> b.numcuenta
	into temp paso_cruzado with no log;
	
	--new
	drop table if exists  intercard:"informix".paso_creditoactivo;
 
    select  a.num_tarjeta  
    from bdicred:sd_tarjeta  a 
    inner join bdicred:sd_maecred b on a.num_credito=b.num_credito
    WHERE a.tipo_tarjeta = 'T'
    AND status_cred in ('AA', 'BA', 'BT','E1','E2','E3')
    into temp paso_creditoactivo with no log;
 
        SET PDQPRIORITY 0;
        CREATE INDEX "informix".idx_tmp_paso_cruzado_1
        ON informix.paso_cruzado(num_tarjeta) ONLINE;
		   
        SET PDQPRIORITY 0;
        CREATE INDEX "informix".idx_tmp_paso_creditoactivo_1
        ON informix.paso_creditoactivo(num_tarjeta) ONLINE;
--------------------------------------------------------------------------------------------------------------
	
	--new pivote 
	drop table if exists  intercard:"informix".tarjeta_temp_paso;	
     
	IF psProceso = 'EXP' THEN 
	
	        Select numtarjeta,fechaexp 
			FROM  "informix".tarjeta  
	 		where fechaexp >= vfechaExpiracionInicial and
                  fechaexp <= vfechaExpiracionFinal    
            into temp tarjeta_temp_paso with no log;				  
	 	 
	 ELIF psProceso = 'CAN' THEN
	 
	       	Select numtarjeta, numcliente, fechaultmodif, codstatustarjeta
			FROM  "informix".tarjeta 
			WHERE fechaultmodif >= vdtFechaPivoteInicial and
                  fechaultmodif <= vdtFechaPivoteFinal   and
			      codstatustarjeta in('CAN','DES','EXT','ROB','FAL','DAN')
            into temp tarjeta_temp_paso with no log;	
				
	END IF;	
		
	    SET PDQPRIORITY 0;
        CREATE INDEX "informix".idx_tmp_paso_tarjeta1
        ON informix.tarjeta_temp_paso (numtarjeta) ONLINE;	
		
-------------------------------------------------------------------------------------------------------------- 	 
 
    IF psProceso = 'EXP' THEN  -- Tarjetas Expiradas

	FOREACH CUSOR1 WITH HOLD FOR			  					  
		    SELECT --{+INDEX("informix".tarjeta idx_tarjeta2)}
			       tjt.numtarjeta, cta.numcuenta 
			INTO vnumtarjeta, vnumcuenta
			FROM "informix".tarjeta_temp_paso tjt, "informix".tarjetacuenta cta
			WHERE tjt.fechaexp >= vfechaExpiracionInicial and
                  tjt.fechaexp <= vfechaExpiracionFinal and
				  tjt.numtarjeta = cta.numtarjeta 
					  
        		IF NOT EXISTS ( SELECT numtarjeta FROM tarjetapivote_depuracion
				                WHERE numtarjeta = vnumtarjeta and
								      numcuenta = vnumcuenta) THEN
								
								IF NOT EXISTS  ( SELECT num_tarjeta FROM paso_cruzado  -- mgap
								   WHERE num_tarjeta =  vnumtarjeta)  THEN 
	 
								    IF NOT EXISTS  ( SELECT num_tarjeta FROM paso_creditoactivo  -- credito activo 
								                     WHERE num_tarjeta =  vnumtarjeta)  THEN 
								
								      INSERT INTO "informix".tarjetapivote_depuracion(numcuenta,numtarjeta)
     								  VALUES (vnumcuenta,vnumtarjeta);
                                
								    END IF;	
								
								END IF;								--
                END IF;    								  
		END FOREACH;
					  
				
	ELIF psProceso = 'CAN' THEN  -- Tarjetas NO Operables por Estatus CAN , DES, EXT, ROB, FAL, DAN
	
	    FOREACH CUSOR2 WITH HOLD FOR			  					  
		    SELECT --{+INDEX("informix".tarjeta idx_tarjetacteconfirmado)}
			       tjt.numtarjeta, cta.numcuenta 
			INTO vnumtarjeta, vnumcuenta
			FROM "informix".tarjeta_temp_paso tjt, "informix".tarjetacuenta cta
			WHERE tjt.numcliente = tjt.numcliente and
			      tjt.fechaultmodif >= vdtFechaPivoteInicial and
                  tjt.fechaultmodif <= vdtFechaPivoteFinal and
				  tjt.numtarjeta = cta.numtarjeta and
			      tjt.codstatustarjeta in('CAN','DES','EXT','ROB','FAL','DAN')
					  
        		IF NOT EXISTS ( SELECT numtarjeta FROM tarjetapivote_depuracion
				                WHERE numtarjeta = vnumtarjeta and
								      numcuenta = vnumcuenta) THEN
								
								
								IF NOT EXISTS  ( SELECT num_tarjeta FROM paso_cruzado  -- mgap
								   WHERE num_tarjeta =  vnumtarjeta)  THEN 
	 
								    IF NOT EXISTS  ( SELECT num_tarjeta FROM paso_creditoactivo  -- credito activo 
								                     WHERE num_tarjeta =  vnumtarjeta)  THEN 
								
								      INSERT INTO "informix".tarjetapivote_depuracion(numcuenta,numtarjeta)
     								  VALUES (vnumcuenta,vnumtarjeta);
                                
								    END IF;	
								
								END IF;								--
                END IF;    								  
		END FOREACH;
	
	
	ELIF psProceso = 'BEN' THEN  -- Tarjetas de Cuentas en Beneficencia PÃÂºblica
			
        FOREACH CUSOR3 WITH HOLD FOR			  					  
		    SELECT /*{+INDEX(bdicheq:"informix".sc_maechq idx_sc_maechq2)}
			       {+INDEX(bdicheq:"informix".sc_maechq ix174_2)}
				   {+INDEX(bdicheq:"informix".sc_maechq 174_183)}
				   {+INDEX("informix".tarjeta 144_89)}		*/		  
			       tjt.numtarjeta, cta.numcuenta 
			INTO vnumtarjeta, vnumcuenta
			FROM "informix".tarjeta tjt, "informix".tarjetacuenta cta, bdicheq:"informix".sc_maechq chq
			WHERE chq.status_cta = '2' and 
			      chq.motivo = '14' and	
			      chq.cuenta = cta.numcuenta and
                  cta.numtarjeta = tjt.numtarjeta and	              				  			  
				  chq.fec_cancelac >= pdFechaPivoteInicial and
                  chq.fec_cancelac <= pdFechaPivoteFinal
					  
        		IF NOT EXISTS ( SELECT numtarjeta FROM tarjetapivote_depuracion
				                WHERE numtarjeta = vnumtarjeta and
								      numcuenta = vnumcuenta) THEN
								
								IF NOT EXISTS  ( SELECT num_tarjeta FROM paso_cruzado  -- mgap
								   WHERE num_tarjeta =  vnumtarjeta)  THEN 
								
								    INSERT INTO "informix".tarjetapivote_depuracion(numcuenta,numtarjeta)
   								    VALUES (vnumcuenta,vnumtarjeta);
								
								END IF;			 --	 
								
                END IF;    								  
		END FOREACH;
			
	ELIF psProceso = 'VND' THEN  -- Tarjetas de Cuentas en Cartera Vendida			
			
		FOREACH CUSOR4 WITH HOLD FOR			  					  
		    SELECT --{+INDEX(bdicred:"informix".idx_sd_maecred_vendida)}
			        tjt.numtarjeta, cta.numcuenta 
			INTO vnumtarjeta, vnumcuenta
			FROM "informix".tarjeta tjt, "informix".tarjetacuenta cta,  bdicred:"informix".sd_maecred crd , bdicred:"informix".sd_maecred_vendida ven                
			WHERE ven.fecha >= pdFechaPivoteInicial and
                  ven.fecha <= pdFechaPivoteFinal and
				  ven.num_credito = crd.num_credito and
                  ven.num_credito  = cta.numcuenta and
                  crd.num_credito = cta.numcuenta and
				  cta.numtarjeta = tjt.numtarjeta and 	
                  crd.status_cred = 'CV'
				  
					  
        		IF NOT EXISTS ( SELECT numtarjeta FROM tarjetapivote_depuracion
				                WHERE numtarjeta = vnumtarjeta and
								      numcuenta = vnumcuenta) THEN
								
								IF NOT EXISTS  ( SELECT num_tarjeta FROM paso_cruzado  -- mgap
								   WHERE num_tarjeta =  vnumtarjeta)  THEN 
								
								    INSERT INTO "informix".tarjetapivote_depuracion(numcuenta,numtarjeta)   								      
									VALUES (vnumcuenta,vnumtarjeta);
								
								END IF;			 --	 
                END IF;    								  
		END FOREACH;         
					 										 
    END IF;

RETURN 	P_COD_RET,P_MENSAJE;		
	
END;

END PROCEDURE;
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

CREATE PROCEDURE "informix".sp_reportemontosxsegmento (empresa varchar (3))
returning VARCHAR (5), VARCHAR(50);

--############################################################################################################
--### Creado por: FRG																			  			##
--##  Fecha: Oct/2015																			 			##
--##  Descripcion: Se genera SP para generar reporte de total de crÃ©ditos por montos de credito otorgado. 	##
--##  BD: intercard                                                                                         ##
--############################################################################################################

DEFINE iSqlErr          		INTEGER;
DEFINE iIsamErr         		INTEGER;
DEFINE cInfoErr					VARCHAR(100);
DEFINE cCodret          		VARCHAR(5);
DEFINE cMensRet         		VARCHAR(50);
DEFINE cempresa					VARCHAR(3);
DEFINE dmpiso1					DECIMAL(19,2);
DEFINE dmtecho1					DECIMAL(19,2);
DEFINE dmpiso2					DECIMAL(19,2);
DEFINE dmtecho2					DECIMAL(19,2);
DEFINE dmpiso3					DECIMAL(19,2);
DEFINE dmtecho3					DECIMAL(19,2);
DEFINE rpt_mayoratecho3			CHAR (12);
DEFINE ccodproductotarjeta    	VARCHAR(3);
DEFINE dcmmonto_otorgado		DECIMAL(19,2);
DEFINE itotal_creditos			INTEGER;
DEFINE vsql	            		CHAR(1150);
DEFINE dfecha					DATE;
DEFINE rpt_fecha				CHAR (6);
DEFINE icontrango1				INTEGER;
DEFINE icontrango2				INTEGER;
DEFINE icontrango3				INTEGER;
DEFINE icontrango4				INTEGER;

--		Set debug file to "/informix/frg/SegmentacionProds/sp_reportemontosxsegmento.out";
--		trace on;

LET iSqlErr					= 0;
LET iIsamErr				= 0;
LET cInfoErr 				= '';
LET cCodret 				= '00000';
LET cMensRet 				= 'Ejecucion sp_reportemontosxsegmento exitosa.';
LET cempresa				= empresa;
LET dmpiso1					= 0;
LET dmtecho1				= 0;
LET dmpiso2					= 0;
LET dmtecho2				= 0;
LET dmpiso3					= 0;
LET dmtecho3				= 0;
LET rpt_mayoratecho3		= 'Mayor_Techo3';
LET ccodproductotarjeta    	= '';
LET dcmmonto_otorgado		= 0;
LET itotal_creditos			= 0;
LET vsql 					= '';
LET dfecha					= current;
LET icontrango1				= 0;
LET icontrango2				= 0;
LET icontrango3				= 0;
LET icontrango4				= 0;
LET rpt_fecha				= '';

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
				RETURN cCodret,cMensRet;
			END IF;
		END EXCEPTION;

		set isolation to dirty read;
		select fecha_hoy::date into dfecha from bdinteg: si_fechas where empresa = cempresa;
		
		LET dfecha = substr (dfecha, 0,2)||substr (dfecha, 4,2)||substr (dfecha, 7,4);
		LET rpt_fecha = substr (dfecha, 0,2)||substr (dfecha, 4,2)||substr (dfecha, 9,2);

/*
		begin;
		drop table "informix".rpt_montosxsegmento;
		commit;
*/
		CREATE TABLE "informix".rpt_montosxsegmento
		( 
			codproductotarjeta          CHAR(3),
			rango						CHAR(17),
			monto_otorgado        	  	DECIMAL(19,4),
			total_creditos				INTEGER,
			primary key (codproductotarjeta, monto_otorgado, total_creditos)
		) EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;


	set isolation to dirty read;
	insert into "informix".rpt_montosxsegmento (codproductotarjeta, rango, monto_otorgado, total_creditos)
	select tar.codproductotarjeta, 
		case 
			when sd.monto_otorgado between 0 and 999.99 then
				'0.00-999.99'
			when sd.monto_otorgado between 1000 and 15000.99 then
				'1000.00-15000.99'
			when sd.monto_otorgado between 15001 and 60000 then
				'15001-60000'
			when sd.monto_otorgado > 60000 then
				'>60000'
			else 'No Identificado.'
		end as rango, sd.monto_otorgado,
		count(*) as Total_Creditos
    from 
		intercard:"informix".tarjeta tar, 
        intercard:"informix".tarjetacuenta tc, 
        bdicred:"informix".sd_maesdos sd, 
        bdicred:"informix".sd_maecred macrd
	where 
		tc.numcuenta = sd.num_credito
		and tc.numtarjeta = tar.numtarjeta
        and macrd.status_cred in ('AA','BT','BA','E1','E2','E3')
        and macrd.empresa = '001'
		and macrd.num_credito =  sd.num_credito
        and tar.codstatustarjeta in ('ACT','BLO','BLT')
        and tar.codproductotarjeta in ('001','002','003')                                          
        group by 1, 2,3
		order by 1, 2;

/*-----------------------------------------------------------------------------------------------------------------
	GENERACIÃN DE REPORTE codproductotarjeta vs montos:
-------------------------------------------------------------------------------------------------------------------*/

		let rpt_mayoratecho3 = 'Mayor_Techo3';
		let vsql = ''; 	   
		let vsql = 'echo "Cod_Producto_Tarjeta|Rango|Monto_Otorgado|Total_Creditos|">/resplogifx/Rpt_MontoProducto_'||rpt_fecha||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
		let vsql=  'echo "UNLOAD TO /resplogifx/Rpt_MontoProducto.unl SELECT * from rpt_montosxsegmento;">/resplogifx/rptcdprodtarjeta.sql'; 
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess intercard /resplogifx/rptcdprodtarjeta.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm /resplogifx/rptcdprodtarjeta.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' /resplogifx/Rpt_MontoProducto.unl >>/resplogifx/Rpt_MontoProducto_"||rpt_fecha||".unl";
		system vsql;
		let vsql ='rm /resplogifx/Rpt_MontoProducto.unl';
		system vsql;

	begin;
		drop table "informix".rpt_montosxsegmento;
	commit;


	RETURN cCodret,cMensRet;

    END;
END PROCEDURE;
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
CREATE PROCEDURE "informix".sp_validaaumentolincred(chempresa char (3))
returning char (5),char(50);

--############################################################################################################
--### Creado por: FRG																			  			##
--##  Fecha: Sep/2015																			 			##
--##  Descripcion: Se genera SP para validar y ajustar el intercard: tarjeta.segmentoproducto de las 	 	##
--## 			tarjetas de los crÃ©ditos del mes anterior que hayan tenido un aumento en la lÃ­nea de 		##
--## 			crÃ©dito otorgada.															         		##
--##  BD: intercard                                                                                         ##
--############################################################################################################

DEFINE iSqlErr          		INTEGER;
DEFINE iIsamErr         		INTEGER;
DEFINE cInfoErr					CHAR(100);
DEFINE cCodret          		CHAR(5);
DEFINE cMensRet         		CHAR(50);
DEFINE cEmpresa          		CHAR(3);
DEFINE cPeriodo					CHAR(6);
DEFINE vfechainicio             CHAR(10);
DEFINE vfechafin                CHAR(10);
DEFINE dFecha_Inicio			DATE;
DEFINE dFecha_Fin	    		DATE;
DEFINE dMesAnt					CHAR(2);
DEFINE vsql	            		CHAR(1150);
DEFINE vTotalRegistros		    INTEGER;
DEFINE RUTA_ORIGEN 				VARCHAR(80);
DEFINE vsecuencial					INTEGER;
DEFINE vcuenta                      VARCHAR(13);
DEFINE vtarjeta						VARCHAR(16);
DEFINE vdescvaloranterior        	VARCHAR(50);
DEFINE vdescvalornuevo				VARCHAR(50);
DEFINE vvaloranterior				VARCHAR(50);
DEFINE vvalornuevo   				VARCHAR(50);
DEFINE vfechacambio					DATE;
DEFINE vtabla        				VARCHAR(100);
DEFINE videntificadorcambio         VARCHAR(5);
DEFINE icommit					    INTEGER;

		--Set debug file to "/informix/ecy/segmentacion/sp_reporteaumentalinea.out";
		--trace on;



--		Set debug file to "/informix/ecy/sp_validaaumentolincred.out";
--		trace on;

LET cInfoErr 				= '';
LET cCodret 				= '00000';
LET cMensRet 				= 'Ejecucion sp_validaaumentolincred exitosa.';
LET cEmpresa 				= chempresa;
LET cPeriodo		        = '';
LET vfechainicio            = '';
LET vfechafin               = '';
LET dFecha_Inicio 			= CURRENT;
LET dFecha_Fin 				= CURRENT;
LET dMesAnt 				= '';
LET vsql 					= '';
LET vTotalRegistros		    = 0;
LET RUTA_ORIGEN = '/resplogifx/';
LET vsecuencial				=0;	
LET vcuenta                 ='';
LET vtarjeta				='';
LET vdescvaloranterior      ='';
LET vdescvalornuevo			='';
LET vvaloranterior			='';
LET vvalornuevo   			='';
LET vfechacambio			= CURRENT;
LET vtabla        			='';
LET videntificadorcambio    ='';
LET icommit				    =0;

BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
				--	Set debug file to "/informix/frg/sp_validaaumentolincred.out";
				--	trace on;
				RETURN cCodret,cMensRet;
			END IF;
		END EXCEPTION;

/*-----------------------------------------------------------------------------------------------------------------
			CALCULO DE FECHAS (MES ANTERIOR):
-----------------------------------------------------------------------------------------------------------------*/

		set isolation to dirty read;
		SET LOCK MODE TO WAIT 3; -- mgap
		select pri_dia_mes, ult_dia_mes    
			into dFecha_Fin, dFecha_Inicio
		from bdinteg: "informix".si_fechas
			where empresa = cEmpresa;
			
		LET dFecha_Fin = substr (dFecha_Fin, 0,2)||substr (dFecha_Fin, 4,2)||substr (dFecha_Fin, 7,4);  

		select substr (extend(pri_dia_mes) - 1 units month, 6, 2)   
			into dMesAnt
		from bdinteg: "informix".si_fechas
			where empresa = cEmpresa;
			
		IF SUBSTR(dFecha_Fin,1,2) =  '01' THEN   		     
		     LET dFecha_Inicio = '01'||dMesAnt||YEAR(dFecha_Fin) - 1;   
		 ELSE 
		    LET dFecha_Inicio = '01'||dMesAnt||substr (dFecha_Fin, 7,4);  		    
		END IF; 
		
		LET cPeriodo = substr (dFecha_Inicio, 7,4)||dMesAnt;
		
		
		


/*-----------------------------------------------------------------------------------------------------------------
			CALCULO DE FECHAS (MES ANTERIOR):
-----------------------------------------------------------------------------------------------------------------*/
		SELECT (extend(today, year to month) -1 units month)::date AS FECHAINICIO,
				(extend(today, year to month) -0 units month)::date -1 AS FECHA_FIN
		INTO vfechainicio,vfechafin
		FROM systables 
		WHERE tabid = 1;
		

/*-----------------------------------------------------------------------------------------------------------------
			TABLA TEMPORAL PARA REPORTE
-----------------------------------------------------------------------------------------------------------------*/
		
	   DROP TABLE IF EXISTS tbl_reportecambio;
	   
	   CREATE TABLE "informix".tbl_reportecambio
		( 
			secuencial					INTEGER,
			cuenta                      VARCHAR(13),
			tarjeta						VARCHAR(16),
			descvaloranterior        	VARCHAR(50),
			descvalornuevo				VARCHAR(50),
			valoranterior				VARCHAR(50),
			valornuevo   				VARCHAR(50),
			fechacambio					DATE,
			tabla        				VARCHAR(100),
			identificadorcambio         VARCHAR(5),
			
			PRIMARY key (fechacambio,secuencial)
		) EXTENT SIZE 280 NEXT SIZE 280 LOCK MODE ROW;
		
		CREATE INDEX "informix".idx_tmp_reportecambio
           ON "informix".tbl_reportecambio(tarjeta,tabla,identificadorcambio);
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3; -- mgap
	FOREACH WITH HOLD 
		SELECT {+AVOID_FULL (intercard:bitacoracambiostarjeta)} {+INDEX(intercard:bitacoracambiostarjeta idx_bitcambiostjt_01)} {+INDEX(intercard:bitacoracambiostarjeta idx_bitcambiostjt_02)} 
		secuencial, cuenta, tarjeta, descvaloranterior, descvalornuevo, valoranterior, valornuevo,fechacambio,tabla,identificadorcambio
		INTO 
			vsecuencial, vcuenta, vtarjeta, vdescvaloranterior, vdescvalornuevo, vvaloranterior, vvalornuevo,vfechacambio,vtabla,videntificadorcambio
		FROM intercard:bitacoracambiostarjeta 
		WHERE fechacambio::date >= vfechainicio
		    AND fechacambio::date <= vfechafin
			AND tabla in ('Intercard:tarjeta','Intercard:bitacoracambiostarjeta')
			AND campo = 'codproductotarjeta'
			AND identificadorcambio in ('2')
			AND descvaloranterior is not null 
			AND descvalornuevo is not null 
			AND descvaloranterior <> '' 
			AND descvalornuevo <> '' 
		
		BEGIN WORK;
				if icommit = 1000
					then
						COMMIT WORK;
						LET icommit = 0;
						CONTINUE FOREACH;
					else
				end if;
			
				INSERT INTO tbl_reportecambio (secuencial, cuenta, tarjeta, descvaloranterior, descvalornuevo, valoranterior, valornuevo,fechacambio,tabla,identificadorcambio )
				VALUES (vsecuencial, vcuenta, vtarjeta, vdescvaloranterior, vdescvalornuevo, vvaloranterior, vvalornuevo,vfechacambio,vtabla,videntificadorcambio);
		
				LET icommit = icommit+1;
				
		COMMIT WORK;
		
		
		
		END FOREACH;
		
			
		
/*-----------------------------------------------------------------------------------------------------------------
	Genera Reporte de intercard: tarjeta.segmentoproducto actualizadas: BIN426807
-------------------------------------------------------------------------------------------------------------------*/

			let vsql = ''; 	   
			let vsql = 'echo "Num_Credito         |Num_Tarjeta         |LineaCredito_Anterior |LineaCredito_Nueva|CodProdSegmento_Anterior|CodProdSegmento_Actual|">'||RUTA_ORIGEN||'BIN426807-6000'||'_'||cPeriodo||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO '||RUTA_ORIGEN||'BIN426807-6000.unl SELECT {+AVOID_FULL (intercard:tbl_reportecambio)} cuenta, tarjeta, descvaloranterior, descvalornuevo, valoranterior, valornuevo from intercard:tbl_reportecambio where tarjeta like ''"'||'426807%'||'"'' and tabla = ''"'||'Intercard:tarjeta'||'"'' and identificadorcambio=''"'||'2'||'"'' order by cuenta;">'||RUTA_ORIGEN||'rptactsgmtoproda.sql';
			
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard '||RUTA_ORIGEN||'rptactsgmtoproda.sql';
			system vsql;
			let vsql = '';
			
			let vsql ='rm '||RUTA_ORIGEN||'rptactsgmtoproda.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' "||RUTA_ORIGEN||'BIN426807-6000.unl >>'||RUTA_ORIGEN||'BIN426807-6000'||'_'||cPeriodo||".unl";
			system vsql;
			let vsql ='rm '||RUTA_ORIGEN||'BIN426807-6000.unl';
			system vsql;
		--END IF;

/*-----------------------------------------------------------------------------------------------------------------
	Genera Reporte de intercard: tarjeta.segmentoproducto actualizadas: BIN510148
-------------------------------------------------------------------------------------------------------------------*/

		let vsql = ''; 	   
		let vsql = 'echo "Num_Credito         |Num_Tarjeta         |LineaCredito_Anterior |LineaCredito_Nueva|CodProdSegmento_Anterior|CodProdSegmento_Actual|">'||RUTA_ORIGEN||'BIN510148-8100'||'_'||cPeriodo||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
		let vsql=  'echo "UNLOAD TO '||RUTA_ORIGEN||'BIN510148-8100.unl SELECT {+AVOID_FULL (intercard:tbl_reportecambio)} cuenta, tarjeta, descvaloranterior, descvalornuevo, 1, 5 from intercard:tbl_reportecambio where tarjeta like ''"'||'510148%'||'"'' and tabla = ''"'||'Intercard:tarjeta'||'"'' and identificadorcambio=''"'||'2'||'"'' order by cuenta;">'||RUTA_ORIGEN||'rptactsgmtoprodb.sql';
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess intercard '||RUTA_ORIGEN||'rptactsgmtoprodb.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm '||RUTA_ORIGEN||'rptactsgmtoprodb.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||RUTA_ORIGEN||'BIN510148-8100.unl >>'||RUTA_ORIGEN||'BIN510148-8100'||'_'||cPeriodo||".unl";
		system vsql;
		let vsql ='rm '||RUTA_ORIGEN||'BIN510148-8100.unl';
		system vsql;

		
/*-----------------------------------------------------------------------------------------------------------------
	Genera Reporte de intercard: tarjeta.segmentoproducto actualizadas: BIN554948
-------------------------------------------------------------------------------------------------------------------*/

		let vsql = ''; 	   
		let vsql = 'echo "Num_Credito         |Num_Tarjeta         |LineaCredito_Anterior |LineaCredito_Nueva|CodProdSegmento_Anterior|CodProdSegmento_Actual|">'||RUTA_ORIGEN||'BIN554948-7000'||'_'||cPeriodo||'.unl';
		system vsql;
		let vsql = '';
		let vsql = '';
		let vsql ='echo "UNLOAD TO '||RUTA_ORIGEN||'BIN554948-7000.unl SELECT {+AVOID_FULL (intercard:tbl_reportecambio)} cuenta, tarjeta, descvaloranterior, descvalornuevo, 5, 6 from intercard:tbl_reportecambio where tarjeta like ''"'||'554948%'||'"'' and tabla = ''"'||'Intercard:tarjeta'||'"'' and identificadorcambio=''"'||'2'||'"'' order by cuenta;">'||RUTA_ORIGEN||'rptactsgmtoprodc.sql';
		system vsql;
		let vsql ='';
		let vsql= 'dbaccess intercard '||RUTA_ORIGEN||'rptactsgmtoprodc.sql';
		system vsql;
		let vsql = '';
		let vsql ='rm '||RUTA_ORIGEN||'rptactsgmtoprodc.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||RUTA_ORIGEN||'BIN554948-7000.unl >>'||RUTA_ORIGEN||'BIN554948-7000'||'_'||cPeriodo||".unl";
		system vsql;
		let vsql ='rm '||RUTA_ORIGEN||'BIN554948-7000.unl';
		system vsql;

	    DROP TABLE IF EXISTS tbl_reportecambio;
		
		/*begin;
			DROP TABLE IF EXISTS "informix".tbl_reportecambio;
		commit;*/

	RETURN cCodret,cMensRet;

END;
END PROCEDURE;
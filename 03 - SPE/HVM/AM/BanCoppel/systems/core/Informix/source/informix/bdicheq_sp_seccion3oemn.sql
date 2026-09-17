CREATE PROCEDURE "informix".sp_seccion3oemn()
RETURNING CHAR(5), CHAR(5);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
	
	DEFINE vcuenta 			VARCHAR(20);
	DEFINE vnum_cte 		VARCHAR(20);
	DEFINE vsucursal 		VARCHAR(4);
	DEFINE vcp 				VARCHAR(5);
	DEFINE vtpo_persona 	VARCHAR(2);
	DEFINE vsexo 			CHAR(1);
	
	DEFINE vNombreTabla1 VARCHAR(200);
	DEFINE vNombreTabla2 VARCHAR(200);
	DEFINE vNombreTabla3 VARCHAR(200);
	DEFINE vNombreTabla4 VARCHAR(200);
	DEFINE vNombreTabla5 VARCHAR(200);
	
	DEFINE dFecha_inicio DATE;
	DEFINE dFecha_fin_mes DATE;
	DEFINE dFecha_inicio_extendida VARCHAR(50);
	DEFINE dFecha_fin_extendida VARCHAR(50);
	DEFINE vMes_anio VARCHAR(20);
	DEFINE vAnio_mes VARCHAR(6);
	DEFINE vPrimer_dia_Mes_Actual VARCHAR(10);
	DEFINE vUltimo_dia_mes_anterior VARCHAR(2);
	DEFINE vcampo_statuscta VARCHAR (15);
	
	DEFINE vInstitucion 	VARCHAR(6);
	DEFINE dFecha 			DATE;
	DEFINE vTipooper 		VARCHAR(3);
	DEFINE vCajero 			VARCHAR(16);
	DEFINE vTipocta 		VARCHAR(1);
	DEFINE vNivelcta 		VARCHAR(1);
	DEFINE mMonto 			MONEY(14,2);
	DEFINE iNum_oper 		BIGINT;
    DEFINE vexiste          CHAR(6);
    DEFINE vexiste_suc      INTEGER;
	DEFINE cCmd1			CHAR(1500);
    DEFINE vconmovhis       CHAR(10);
    DEFINE vfecha_ejecucion DATE;
    DEFINE vfechconmovhisold CHAR(10);
    DEFINE vbandera         SMALLINT;
	DEFINE iContReg 		INTEGER;
	DEFINE vsql             LVARCHAR(1500);
	DEFINE RUTA_DESTINO 	VARCHAR(80);
	DEFINE vult_mes_ant    	DATE;
	DEFINE vaniomes      	VARCHAR(6);
	DEFINE TIPO_PLANTILLA   VARCHAR(30);
	DEFINE cRutaInformix 	VARCHAR(100);
	DEFINE pempresa 		VARCHAR(3);
	
	LET vInstitucion='';
	LET dFecha='';
	LET vTipooper='';
	LET vCajero='';
	LET vTipocta ='';
	LET vNivelcta ='';
	LET mMonto=0.00;
	LET iNum_oper=0;
	LET cCmd1='';
	LET iContReg=0;
	LET dFecha_inicio='';
	LET dFecha_fin_mes='';
	LET dFecha_inicio_extendida='';
	LET dFecha_fin_extendida='';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
	
	LET vcuenta='';
	LET vnum_cte='';
	LET vsucursal='';
	LET vcp='';
	LET vtpo_persona='';
	LET vsexo='';
	LET vAnio_mes='';
	LET vPrimer_dia_Mes_Actual='';
	LET vUltimo_dia_mes_anterior='';
	LET vcampo_statuscta='statuscta';
	LET vNombreTabla1='';
	LET vNombreTabla2='';
	LET vNombreTabla3='';
	LET vNombreTabla4='';
	LET vNombreTabla5='';
	LET vMes_anio='';
    LET vexiste  = '';
    LET vexiste_suc = 0; 
    LET vconmovhis    = '';
    LET vfecha_ejecucion = '';
    LET vfechconmovhisold = '';
    
    LET vbandera = 0;
	
	LET vsql = '';
	LET RUTA_DESTINO   = '/resplogifx/conciliachq/';
	LET TIPO_PLANTILLA = 'seccion3oemn';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET vult_mes_ant = '';
	LET vaniomes ='';
	LET pempresa ='001';
		
    BEGIN

				ON EXCEPTION SET sql_err, isam_err, desc_err
					SET DEBUG FILE TO "/home/sysrepaut/sp_seccion3oemn.err";
					TRACE ON;
					IF sql_err <> 0 THEN
						LET vcodret1 = sql_err;
						LET vcodret2 = isam_err;
						--LET vcodret3 = desc_err;
						RETURN vcodret1, vcodret2;
					END IF;
				END EXCEPTION;
				
				-- SET DEBUG FILE TO "/ifxsif01/ilopez/SECCION3/sp_seccion3oemn.out";
				-- TRACE ON;

				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				SELECT pri_dia_mes - 1 units day
				INTO vult_mes_ant
				FROM bdicheq:sc_fechas
				WHERE empresa = pempresa;
				 
				 
				--SE GENERA LA FECHA FIN DE MES
				LET dFecha_inicio=LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
				LET dFecha_Inicio=dFecha_Inicio -1 UNITS MONTH;
				LET dFecha_fin_mes=LPAD(MONTH(dFecha_Inicio),2,0)||'/'||DAY(LAST_DAY(dFecha_Inicio))||'/'||YEAR(dFecha_Inicio);
				LET vAnio_mes=YEAR(dFecha_fin_mes)||LPAD(MONTH(dFecha_fin_mes),2,0);
				LET vUltimo_dia_mes_anterior=LPAD(DAY(dFecha_fin_mes),2,0);
				LET vPrimer_dia_Mes_Actual=LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
				--LET vMes_anio=to_char(dFecha_inicio,'%m%Y');
				
				--CAMBIAMOS FECHA A FRACTION 5
				LET dFecha_inicio_extendida=YEAR(dFecha_Inicio) || '-' || LPAD ( MONTH(dFecha_Inicio), 2, '0') || '-' ||
							LPAD ( DAY (dFecha_Inicio), 2, '0') || ' 00:00:00.00000';
							
				LET dFecha_inicio_extendida= CAST (dFecha_inicio_extendida AS DATETIME year to fraction(5));
				
				
				LET dFecha_fin_extendida=YEAR(dFecha_fin_mes) || '-' || LPAD ( MONTH(dFecha_fin_mes), 2, '0') || '-' ||
							LPAD ( DAY (dFecha_fin_mes), 2, '0') || ' 23:59:59.00000';
							
				
				LET dFecha_fin_extendida=CAST (dFecha_fin_extendida AS DATETIME year to fraction(5));
				

				--PASO 1
					--SELECT  tabname INTO vNombreTabla1 FROM bdicheq:"informix".systables WHERE tabname = 'misenmissintf_creddeb';
						--IF dbinfo("sqlca.sqlerrd2")= 1 THEN
							--DROP TABLE misenmissintf_creddeb;
						--END IF;
				 
				DROP TABLE IF EXISTS  misenmissintf_creddeb;
				CREATE TABLE bdicheq:"informix".misenmissintf_creddeb (
				institucion VARCHAR(6),
				fecha DATE,
				tipooper VARCHAR(3),
				cajero VARCHAR(16),
				tipocta VARCHAR(1),
				nivelcta VARCHAR(1),
				monto money(14,2)
				);

				CREATE INDEX idx_tipooper1 ON misenmissintf_creddeb(tipooper) USING BTREE;
				UPDATE STATISTICS MEDIUM FOR TABLE misenmissintf_creddeb;

				LET iContReg = 1;	
				FOREACH WITH HOLD
							
				--CREDITO MISENMIS SIN TRANSFER
				--2,200,000 REGISTROS
				SELECT '040137',dFecha_fin_mes,'111',idterminal, '8' tipocta, '4' nivelcta,monto
					INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto
					FROM bditarjeta:"informix".td_txns_atms_exitosas
					WHERE creditodebito='C'
					AND tipotran = 'MM'
					AND codtran = '01'
					AND fechahoramov >= dFecha_inicio_extendida 
					and fechahoramov <= dFecha_fin_extendida
					and numtarjetamovi not like ('40081904%')	
							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".misenmissintf_creddeb(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto);
								
								
								IF iContReg >= 1000 THEN
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
				
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;

						
				FOREACH WITH HOLD
							
				--DEBITO MISENMIS SIN TRANSFER		
				--2,200,000 REGISTROS
				SELECT '040137',dFecha_fin_mes,'104',idterminal, '8' tipocta, '4' nivelcta,monto
					INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto
					FROM bditarjeta:"informix".td_txns_atms_exitosas
					WHERE creditodebito <> 'C'
					AND tipotran = 'MM'
					AND codtran = '01'
					AND fechahoramov >= dFecha_inicio_extendida 
					and fechahoramov <= dFecha_fin_extendida
					and numtarjetamovi not like ('40081904%')	
							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".misenmissintf_creddeb(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto);
								
								
								IF iContReg >= 1000 THEN
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

							

				--PASO 2
				
						--SELECT  tabname INTO vNombreTabla2 FROM bdicheq:"informix".systables WHERE tabname = 'seccion3oemn';
						--IF dbinfo("sqlca.sqlerrd2")= 1 THEN
							--DROP TABLE seccion3oemn;
						--END IF;
				 
				 DROP TABLE IF EXISTS seccion3oemn;
						CREATE TABLE bdicheq:"informix".seccion3oemn (
						institucion VARCHAR(6),
						fecha DATE,
						tipooper VARCHAR(3),
						cajero VARCHAR(16),
						tipocta VARCHAR(1),
						nivelcta VARCHAR(1),
						monto money(14,2),
						num_oper BIGINT
						);
				
							CREATE INDEX idx_tipooper2 ON seccion3oemn(tipooper) USING BTREE;
							UPDATE STATISTICS MEDIUM FOR TABLE seccion3oemn;
				
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
				FOREACH WITH HOLD
							--Con tipooper 111
							SELECT institucion,fecha,tipooper,cajero,'6','4',sum(monto),count(*) 
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
								FROM misenmissintf_creddeb
								WHERE tipooper='111'
								group by 1,2,3,4,5,6
					
							
							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".seccion3oemn(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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
				
				
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
				FOREACH WITH HOLD
							--Con tipooper <> 111
							SELECT institucion,fecha,tipooper,cajero,'7', '4',sum(monto),count(*) 
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
								FROM misenmissintf_creddeb
								WHERE tipooper <>'111'
								group by 1,2,3,4,5,6
				
							
							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".seccion3oemn(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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
				
				


				--PASO 3 --MISENMIN CON TRANSFER 
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
				FOREACH WITH HOLD
								
								SELECT '040137', dFecha_fin_mes,'104',idterminal,'8','2',sum(monto),count(*)
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
									FROM bditarjeta:"informix".td_txns_atms_exitosas
									WHERE tipotran = 'MM'
									AND codtran = '01'
									AND fechahoramov >= dFecha_inicio_extendida 
									and fechahoramov <= dFecha_fin_extendida
									and numtarjetamovi like ('40081904%')
									GROUP BY 2,4
									--GROUP BY idterminal,dFecha_fin_mes

							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".seccion3oemn(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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


				
				--PASO 4  SUSENMIS
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
				FOREACH WITH HOLD
								
								SELECT '040137', dFecha_fin_mes,'0', idterminal, '0', '0',sum(monto),count(*)
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
									FROM bditarjeta:"informix".td_txns_atms_exitosas
									WHERE tipotran = 'SM'
									AND codtran = '01'
									AND fechahoramov >= dFecha_inicio_extendida 
									and fechahoramov <= dFecha_fin_extendida
									GROUP BY 2,4
									--GROUP BY idterminal,dFecha_fin_mes

							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".seccion3oemn(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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

				
				--PASO 5
				--CAJA GENERAL------
				--SELECT  tabname INTO vNombreTabla3 FROM bdicheq:"informix".systables WHERE tabname = 'caja3';
					--	IF dbinfo("sqlca.sqlerrd2")= 1 THEN
						--	DROP TABLE caja3;
						--END IF;
				 
				DROP TABLE IF EXISTS caja3;
				CREATE TABLE bdicheq:"informix".caja3 (
				institucion VARCHAR(6),
				fecha DATE,
				tipooper VARCHAR(3),
				cajero VARCHAR(4),
				tipocta VARCHAR(1),
				nivelcta VARCHAR(1),
				monto money(14,2),
				num_oper BIGINT
				);
		
							CREATE INDEX idx_cajero ON caja3(cajero) USING BTREE;
							UPDATE STATISTICS MEDIUM FOR TABLE caja3;
							
							
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
					FOREACH WITH HOLD
								
							
							--Tipo Oper 24
							SELECT  '040137',dFecha_fin_mes,'24',sucursal,'0','0',sum(monto),count(*)
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
								FROM bdisuc:ss_operaciones
								where  fecha_operacion between dFecha_Inicio and dFecha_fin_mes
								and cod_trans='0036'---dotacion efectivo
								and reversado <> '8'
								group by sucursal


								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".caja3(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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
				
				
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
					FOREACH WITH HOLD
		
							--Tipo Oper 124
							SELECT  '040137',dFecha_fin_mes,'124',sucursal,'0','0',sum(monto),count(*)
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
								FROM bdisuc:ss_operaciones
								where  fecha_operacion between dFecha_Inicio and dFecha_fin_mes
								and cod_trans='0041'---dotacion efectivo
								and reversado <> '8'
								group by sucursal


								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".caja3(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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
				
				
				
				--PASO 6
				LET iContReg = 1;
				LET vInstitucion='';
				LET dFecha='';
				LET vTipooper='';
				LET vCajero='';
				LET vTipocta ='';
				LET vNivelcta ='';
				LET mMonto=0.00;
				LET iNum_oper=0;
				
				
				FOREACH WITH HOLD
								
							
								SELECT a.institucion,a.fecha,a.tipooper,b.id,a.tipocta,a.nivelcta,NVL(ROUND(monto),0),num_oper
								INTO vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper
								FROM caja3 a, bdisuc:ss_relacionccid  b
								where a.cajero=b.cc

							
								IF iContReg=1 THEN
									BEGIN WORK;
								END IF	
								INSERT INTO bdicheq:"informix".seccion3oemn(institucion,fecha,tipooper,cajero,tipocta,nivelcta,monto,num_oper)
									VALUES(vInstitucion,dFecha,vTipooper,vCajero,vTipocta,vNivelcta,mMonto,iNum_oper);
								
								
								IF iContReg >= 1000 THEN
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
				
		
			--Generar el archivo en /resplogifx/conciliachq
					/*LET cCmd1 ="";
					LET cCmd1 ="SELECT institucion,fecha,tipooper,cajero,tipocta,nivelcta,NVL(ROUND(sum(monto)),0),sum(num_oper)";
					LET cCmd1 =""||TRIM(cCmd1)||" FROM seccion3oemn WHERE monto>=1 and num_oper > 0";
					LET cCmd1 =""||TRIM(cCmd1)||" and num_oper > 0 GROUP BY 1,2,3,4,5,6;";
					LET cCmd1 =" "||TRIM(cCmd1);
			
					LET vsql = '';
					LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/seccion3oemn.csv'||' DELIMITER '';'' '||TRIM(cCmd1)||' " > '||'/resplogifx/conciliachq/seccion3oemn.sql';
					SYSTEM TRIM(vsql);
					
					LET vsql = '';
					LET vsql = 'chmod 777 '||'/resplogifx/conciliachq/seccion3oemn.sql';
					SYSTEM TRIM(vsql);
					
					LET vsql = '';
					LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/seccion3oemn.sql"; 
					SYSTEM TRIM(vsql);  
					
					-- Eliminamos el archivo query.sql
					LET vsql = '';
					LET vsql = 'rm -rf /resplogifx/conciliachq/seccion3oemn.sql';
					SYSTEM TRIM(vsql);*/
					
					
			LET vaniomes ='';
			LET vaniomes = TO_CHAR(vult_mes_ant, '%Y%m');
             ----------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
			let vsql = 'echo "Institucion|Fecha|Tipooper|Cajero|Tipocta|Nivelcta|Monto|Num_oper ">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vaniomes||'.csv';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'reg_seccion3oemn_'||vaniomes||'.txt   '||
			           ' SELECT institucion,fecha,tipooper,cajero,tipocta,nivelcta,NVL(ROUND(sum(monto)),0),sum(num_oper)'||
					   ' FROM seccion3oemn WHERE monto>=1 and num_oper > 0 and num_oper > 0 GROUP BY 1,2,3,4,5,6; ">'||RUTA_DESTINO||'seccoemn.sql';    
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'seccoemn.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess bdicheq '||RUTA_DESTINO||'seccoemn.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt al archivo csv
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'reg_seccion3oemn_'||vaniomes||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vaniomes||'.csv';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'seccoemn.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'reg_seccion3oemn_'||vaniomes||'.txt';
		    system vsql;

				
				--DROP TABLE seccion3oemn;
				--DROP TABLE caja3;
				--DROP TABLE misenmissintf_creddeb;

    END;

    RETURN vcodret1, vcodret2;

END PROCEDURE;
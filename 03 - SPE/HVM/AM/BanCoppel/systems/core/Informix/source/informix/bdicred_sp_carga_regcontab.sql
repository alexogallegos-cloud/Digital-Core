CREATE PROCEDURE "informix".sp_carga_regcontab() 
RETURNING CHAR(6), CHAR(50);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCodRetP CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cDatosCarga CHAR (50);
DEFINE cBitCarga CHAR (50);
DEFINE vnum_cred CHAR (20);
DEFINE vnum_producto CHAR (4);
DEFINE vsucursal CHAR(4);
DEFINE vsaldo_cred DECIMAL(18,2);
DEFINE vreserva_calif DECIMAL(18,2);
DEFINE vreserva_int DECIMAL(18,2);
DEFINE vgrado_riesgo VARCHAR(3);
DEFINE vNvoPeriodo INTEGER;
DEFINE vDivisa CHAR(2);
DEFINE dtCargaAct DATETIME YEAR TO SECOND;
DEFINE dtCargaIni DATETIME YEAR TO SECOND;
DEFINE dtCargaFin DATETIME YEAR TO SECOND;
DEFINE wBegin                CHAR(1);
DEFINE cArchivo_dbld      CHAR(50);
DEFINE cArchivo_log       CHAR(50);
DEFINE dtFechaHoy			DATE;
DEFINE dtFechaPase    DATE;
DEFINE cMensajeRet 		CHAR(50);
DEFINE cMensajeRetP		CHAR(50);
DEFINE iExiste			INTEGER;
DEFINE v_band_regcontab	INTEGER;
DEFINE v_band_tdc	INTEGER;
DEFINE v_band_pp	INTEGER;
DEFINE v_cod_param CHAR(3);
DEFINE v_band_sdo1	INTEGER;
DEFINE v_band_sdo2	INTEGER;
DEFINE v_band_sdo3	INTEGER;
DEFINE contador_commit   INTEGER;
DEFINE val_trans_Commit   SMALLINT;

LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCodRetP = '00000';
LET cCadena = '';
LET cRuta = '';
LET cDatosCarga = '';
LET cBitCarga = '';
LET vnum_cred = '';
LET vnum_producto ='';
LET vsucursal ='';
LET vsaldo_cred =0;
LET vreserva_calif =0;
LET vreserva_int =0;
LET vgrado_riesgo ='';
LET vNvoPeriodo =0;
LET vDivisa ='';
LET wBegin = '';
LET dtCargaAct = CURRENT;
LET cArchivo_dbld    = "f_datoscarga.com";
LET cArchivo_log     = "f_datoscarga.log";
LET vsucursal = '';
LET dtFechaHoy			= DATE(1);
LET dtFechaPase		= DATE(1);
LET cMensajeRet 		= '';
LET cMensajeRetP 		= 'PROCESO EXITOSO';
LET iExiste			=0;
LET v_band_regcontab	=0;
LET v_band_tdc	=0;
LET v_band_pp	=0;
LET v_cod_param ='';
LET  v_band_sdo1 = 0;
LET  v_band_sdo2 = 0;
LET  v_band_sdo3 = 0;
LET contador_commit   =0;
LET val_trans_Commit  =0;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		
		IF (val_trans_Commit = -1) THEN
		        rollback work;
        END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

  --SET DEBUG FILE TO '/resplogifx/archivoscontabilidad/sp_carga_datos_reg.out';
  --TRACE ON;

    LET cBitCarga="bit_";
    LET cRuta="/resplogifx/archivoscontabilidad/";                                              
 
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy, pri_dia_mes - 1 units day 
	INTO dtFechaHoy, dtFechaPase
	  FROM "informix".sd_fechas WHERE empresa = '001';	
	  
	IF NVL(cRuta,'') <> '' THEN
	
				
		FOREACH WITH HOLD
			SELECT valor, cod_param INTO cDatosCarga, v_cod_param
			FROM sd_param 
			WHERE cod_param IN('RS1','RS2','RS3','RS4','RS5','RS6')		

					
			IF NVL(cDatosCarga,'') <> '' THEN
				LET cDatosCarga = TRIM(cDatosCarga)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||'.unl';                
				LET cBitCarga= TRIM(cBitCarga)||TRIM(cDatosCarga);
				TRUNCATE TABLE sd_cargadatosregcontab;
											
				
			   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cDatosCarga) ||' DELIMITER '|| "'" || '|' || "'" || ' 5;' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
			   system ' echo "INSERT INTO sd_cargadatosregcontab;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
			   system 'chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

			   system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_datoscarga.sh';
			   system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_datoscarga.sh'; 
			   system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';
			   system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';             
			   system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';          
			   system ' echo "update statistics medium for table sd_cargadatosregcontab; ' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';           
			   system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_datoscarga.sh';           
			   system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_datoscarga.sh';
			   system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_datoscarga.sh';     
				
				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002';
			END IF;			
					
			IF cCodRet = '000000' THEN 	
				
				SELECT COUNT(*) INTO iExiste
				FROM sd_cargadatosregcontab;
					
				IF iExiste>0 THEN	
					IF v_cod_param='RS1' THEN
						DELETE FROM sd_datosregcontab WHERE num_producto = '7800' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif WHERE num_producto ='7800' AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS2' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto= '6400' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto= '6400' AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS3' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto IN('6300','7600','7700') and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto IN('6300','7600','7700') AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS4' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto ='6800' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto= '6800' AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS5' THEN
						DELETE FROM sd_datosregcontab WHERE num_producto ='6011' and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif_cnr WHERE num_producto = '6011' AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					ELIF v_cod_param='RS6' THEN	
						DELETE FROM sd_datosregcontab WHERE num_producto IN('6001','7000','8100','8500') and fecha_reg=dtFechaHoy;
						DELETE FROM sd_movhis_calif WHERE num_producto IN ('6001','7000','8100','8500') AND empresa='001' AND num_credito is not null AND fecha_mov=dtFechaPase;
					END IF;
						
					FOREACH WITH HOLD
						
						SELECT  num_credito,saldo_cred,reserva_calif,reserva_int,  nvl(replace(replace(grado_riesgo, '"|"'," "), '"\"'," ")," ") 
						INTO vnum_cred,vsaldo_cred,vreserva_calif,vreserva_int,vgrado_riesgo
						FROM sd_cargadatosregcontab 
						
						IF (val_trans_Commit = 0) THEN
							BEGIN WORK;
							LET contador_commit = 0;
							LET val_trans_Commit = -1;
						END IF;         
			
						IF (SELECT COUNT(*) FROM bdicred:sd_maecred WHERE num_credito=vnum_cred) > 0 THEN
							SELECT num_producto,sucursal,divisa
							INTO vnum_producto,vsucursal,vDivisa
							FROM bdicred:sd_maecred 						
							WHERE num_credito=vnum_cred;
						ELSE
							SELECT num_producto,sucursal,divisa
							INTO vnum_producto,vsucursal,vDivisa
							FROM bdicred:sd_maecredcrd						
							WHERE num_credito=vnum_cred;
						END IF;											
						
						LET v_band_regcontab=0;
						LET cCodRet='00000';
						LET cMensajeRet='';
						
						--Determina GRADO RIESGO Bancoppel
						IF trim(vgrado_riesgo)= 'A-1' THEN
							LET vNvoPeriodo= 0;
						ELIF trim(vgrado_riesgo)= 'A-2' THEN
							LET vNvoPeriodo= 1;
						ELIF trim(vgrado_riesgo)= 'B-1' THEN
							LET vNvoPeriodo= 2;
						ELIF trim(vgrado_riesgo)= 'B-2' THEN
							LET vNvoPeriodo= 3;
						ELIF trim(vgrado_riesgo)= 'B-3' THEN
							LET vNvoPeriodo= 4;
						ELIF trim(vgrado_riesgo)= 'C-1' THEN
							LET vNvoPeriodo= 5;
						ELIF trim(vgrado_riesgo)= 'C-2' THEN
							LET vNvoPeriodo= 6;
						ELIF trim(vgrado_riesgo) matches '[D]*' THEN
							LET vNvoPeriodo= 7;
						ELIF trim(vgrado_riesgo) matches '[E]*' THEN
							LET vNvoPeriodo= 8;
						END IF;
						
						IF vnum_producto IN('6001','7000','7800','8100','8500') THEN
							IF vReserva_calif>0 THEN
								LET v_band_sdo1=0;
								
							-- Genera Movimiento para Contabilidad					
								EXECUTE PROCEDURE genmov_calif ('001',
															   vnum_cred,
															   vnum_producto,
															   vNvoPeriodo,
															   "091",
															   dtFechaPase,
															   vReserva_calif,
															   "CalifCartReserva",
															   vSucursal,
															   vDivisa,
															   "0000")  
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;						
								ELSE
									LET v_band_regcontab=1;
								END IF;
							ELSE
								LET v_band_sdo1=1;
							END IF;
														
							IF vsaldo_cred > 0 THEN
								LET cMensajeRet='';
								LET v_band_sdo2=0;

								EXECUTE PROCEDURE genmov_calif ('001',
															  vnum_cred,
															  vnum_producto,
															  vNvoPeriodo,
															  "090",
															  dtFechaPase,
															  vsaldo_cred,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;								
								ELSE
									LET v_band_regcontab=2;
								END IF;
							ELSE
								LET v_band_sdo2=1;
							END IF;									
						
							IF vReserva_int > 0 THEN
									LET cMensajeRet='';
									LET v_band_sdo3=0;
									EXECUTE PROCEDURE genmov_calif('001',
															  vnum_cred,
															  vnum_producto,
															  0,
															  "094",
															  dtFechaPase,
															  vReserva_int,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
									INTO cCodRet, cMensajeRet;
									IF TRIM(cCodRet) <> "00000" THEN
										LET v_band_regcontab=0;
									ELSE
										LET v_band_regcontab=3;
									END IF;
							ELSE
								LET v_band_sdo3=1;
							END IF;
						ELIF vnum_producto IN('6011') THEN
							IF vReserva_calif > 0 THEN	
								
								LET v_band_sdo1=0;
							-- Genera Movimiento para Contabilidad					
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															   vnum_cred,
															   vnum_producto,
															   vNvoPeriodo,
															   "091",
															   dtFechaPase,
															   vReserva_calif,
															   "CalifCartReserva",
															   vSucursal,
															   vDivisa,
															   "0000")  
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;						
								ELSE
									LET v_band_regcontab=1;
								END IF;
							ELSE
								LET v_band_sdo1=1;
							END IF;							
							
							IF vsaldo_cred>0 THEN
								LET cMensajeRet='';
								LET v_band_sdo2=0;
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															  vnum_cred,
															  vnum_producto,
															  vNvoPeriodo,
															  "090",
															  dtFechaPase,
															  vsaldo_cred,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;								
								ELSE
									LET v_band_regcontab=2;
								END IF;
							ELSE
								LET v_band_sdo2=1;
							END IF;							
							
							IF vReserva_int > 0 THEN
									LET cMensajeRet='';
									LET v_band_sdo3=0;
									EXECUTE PROCEDURE genmov_calif_cnr('001',
															  vnum_cred,
															  vnum_producto,
															  0,
															  "094",
															  dtFechaPase,
															  vReserva_int,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
									INTO cCodRet, cMensajeRet;
									IF TRIM(cCodRet) <> "00000" THEN
										LET v_band_regcontab=0;
									ELSE
										LET v_band_regcontab=3;										
									END IF;
							ELSE
								LET v_band_sdo3=1;
							END IF;							
						ELSE
							IF vReserva_calif > 0 THEN	
								
								LET v_band_sdo1=0;
							-- Genera Movimiento para Contabilidad					
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															   vnum_cred,
															   vnum_producto,
															   vNvoPeriodo,
															   "101",
															   dtFechaPase,
															   vReserva_calif,
															   "CalifCartReserva",
															   vSucursal,
															   vDivisa,
															   "0000")  
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;						
								ELSE
									LET v_band_regcontab=1;
								END IF;
							ELSE	
								LET v_band_sdo1=1;
							END IF;							
							
							IF vsaldo_cred>0 THEN
								LET cMensajeRet='';
								LET v_band_sdo2=0;
								EXECUTE PROCEDURE genmov_calif_cnr ('001',
															  vnum_cred,
															  vnum_producto,
															  vNvoPeriodo,
															  "100",
															  dtFechaPase,
															  vsaldo_cred,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
								INTO cCodRet, cMensajeRet;
								IF TRIM(cCodRet) <> "00000" THEN
									LET v_band_regcontab=0;								
								ELSE
									LET v_band_regcontab=2;
								END IF;
							ELSE
								LET v_band_sdo2=1;
							END IF;							
							
							IF vReserva_int > 0 THEN
									LET cMensajeRet='';
									LET v_band_sdo3=0;
									EXECUTE PROCEDURE genmov_calif_cnr('001',
															  vnum_cred,
															  vnum_producto,
															  0,
															  "104",
															  dtFechaPase,
															  vReserva_int,
															  "CalifCart",
															  vSucursal,
															  vDivisa,
															  "0000")
									INTO cCodRet, cMensajeRet;
									IF TRIM(cCodRet) <> "00000" THEN
										LET v_band_regcontab=0;
									ELSE
										LET v_band_regcontab=3;										
									END IF;
							ELSE
								LET v_band_sdo3=1;
							END IF;						
						END IF;
						
						IF v_band_sdo1=1 AND v_band_sdo2=1 AND v_band_sdo3=1 THEN
							LET cCodRet='00001';
							LET cMensajeRet='SALDOS EN CEROS';
							LET v_band_sdo1=0;
							LET v_band_sdo2=0;
							LET v_band_sdo3=0;
						END IF;
						
						INSERT INTO sd_datosregcontab(num_credito,saldo_cred,reserva_calif,reserva_int,grado_riesgo,num_producto,sucursal,fecha_reg,band_regcontab,cod_ret,descripcion)
						VALUES(vnum_cred,vsaldo_cred,vReserva_calif,vReserva_int,trim(vgrado_riesgo),vnum_producto,vSucursal,dtFechaHoy,v_band_regcontab,cCodRet,cMensajeRet);
	
						LET contador_commit = contador_commit  + 1;
			
						IF (contador_commit >= 5000) THEN
							COMMIT WORK;
							LET contador_commit = 0; 
							BEGIN WORK;
						END IF;     
					END FOREACH 
					IF val_trans_Commit = -1 THEN
						COMMIT WORK;
						LET contador_commit = 0;
						LET val_trans_Commit = 0;
					END IF;
					LET cCadena = '';
					LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCarga)  ||'  delimiter ''|'' SELECT * FROM bdicred:"informix".sd_datosregcontab where fecha_reg='''||dtFechaHoy||''' and num_credito in(SELECT num_credito From sd_cargadatosregcontab)" >'||TRIM(cRuta)||'bit_carga.sql';
					SYSTEM cCadena;				
					LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_carga.sql';
					System cCadena;				
					let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_carga.sql';
					System cCadena;				
					LET cCadena = '' ;
					LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_carga.sql';
					SYSTEM cCadena;	
					
				ELSE 
					LET cDatosCarga = '';                
					LET cBitCarga="bit_";
					CONTINUE FOREACH;
				END IF;
			END IF;
			
			LET cDatosCarga = '';                
			LET cBitCarga="bit_";
					
		END FOREACH		
		
	END IF;
	RETURN cCodRetP, cMensajeRetP;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 29/oct/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_pases_regcontab() 
RETURNING CHAR(6), CHAR(50);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE dtFechaHoy			DATE;
DEFINE dtFechaPase    DATE;
DEFINE cMensajeRet 		CHAR(50);


LET iSqlErr = 0;
LET cCodRet = '000001';
LET dtFechaHoy			= DATE(1);
LET dtFechaPase		= DATE(1);
LET cMensajeRet 		= '';



BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
   	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/resplogifx/archivoscredito/sp_pases_regcontab.out';
	--TRACE ON;

    
	--SE OBTIENE LA FECHA HOY.
	SELECT fecha_hoy, pri_dia_mes - 1 units day 
	INTO dtFechaHoy, dtFechaPase
	  FROM "informix".sd_fechas WHERE empresa = '001';	
	  
	
	EXECUTE PROCEDURE bdicred:"informix".pasecont_movcalif('001',dtFechaPase,dtFechaHoy,'informix','califcar','PaseCont') 
	INTO cCodRet, cMensajeRet;

	EXECUTE PROCEDURE bdicred:"informix".paseprest_movcalif('001',dtFechaPase,dtFechaHoy,'informix','califcnr','PaseCont') 
	INTO cCodRet, cMensajeRet;

	IF cCodRet <> '000' THEN
		RETURN cCodRet, cMensajeRet;
	ELSE			
		LET cMensajeRet='SE REALIZARON LOS PASES CORRECTAMENTE';
	END IF;
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 29/oct/2019',
'BD    : BDICRED';

CREATE PROCEDURE "informix".pasecont_movcalif(pempresa     CHAR(3),
                                     fecha_pase   DATE,
									 pfecha_captura DATE,
                                     pusuario     CHAR(8),
                                     pusuariopase CHAR(8),
                                     pproceso     CHAR(10))
   RETURNING CHAR(5), varchar(80);

   DEFINE wcod_ret                      CHAR(5);
   DEFINE P_MENSAJE                     VARCHAR(80);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;

   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wproceso                      CHAR(10);
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(50);
   DEFINE wnumpolmn                     SMALLINT;
   DEFINE wnumpoldl                     SMALLINT;
   DEFINE wfecha                        CHAR(10);
   DEFINE wbanco                        CHAR(3);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   SMALLINT;
   DEFINE wnum_cuota                    SMALLINT;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wapell_paterno                CHAR(15);
   DEFINE wapell_materno                CHAR(15);
   DEFINE wnombre1                      CHAR(15);
   DEFINE wnombre2                      CHAR(15);
   DEFINE wrazon_social                 CHAR(40);
   DEFINE wabreviatura                  CHAR(50);
   DEFINE wsecuencia                    SMALLINT;
   DEFINE wvaloriza                     CHAR(1);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);

   DEFINE wamayor                       CHAR(4);
   DEFINE wasub1                        CHAR(3);
   DEFINE wasub2                        CHAR(3);
   DEFINE wasub3                        CHAR(3);
   DEFINE wasub4                        CHAR(3);
   DEFINE wasector                      CHAR(3);

   DEFINE wmonto                        MONEY(14,2);
{****************************************************************************
 **      TERMINA REGISTRO DE PASE CONTABLE                                 **
 **      INICIA REGISTRO DETPOL                                            **
 ****************************************************************************}

   DEFINE detusuario                    CHAR(11);
   DEFINE detcontrol_poliza             SMALLINT;
   DEFINE detfecha_captura              DATE;
   DEFINE detsecuencia                  INTEGER;
   DEFINE detempresa                    CHAR(3);
   DEFINE detmayor                      CHAR(4);
   DEFINE detsub1                       CHAR(3);
   DEFINE detsub2                       CHAR(3);
   DEFINE detsub3                       CHAR(3);
   DEFINE detsub4                       CHAR(3);
   DEFINE detsector                     CHAR(3);
   DEFINE detciudad                     CHAR(3);
   DEFINE detsucursal                   CHAR(4);
   DEFINE detnro_auxiliar               CHAR(9);
   DEFINE detnaturaleza                 CHAR(1);
   DEFINE detmonto                      MONEY(14,2);
   DEFINE detdescripcion_det            CHAR(50);
   DEFINE detfecha_valida               DATE;
   DEFINE detmoneda                     CHAR(2);
   DEFINE detvalor_cambio               MONEY(12,7);
   DEFINE detvalor_div_cambio           MONEY(12,7);
   DEFINE detmca_aplica                 CHAR(1);
   DEFINE detpoliza_usuario             CHAR(11);
   DEFINE dettipo_mov                   CHAR(1);
   
{***************************************************************************
 **   TERMINA REGISTRO DE DETPOL                                          **
 **   INICIA REGISTRO DE ENCABEZADO DE POLIZA                             **
 ***************************************************************************}

   DEFINE polcifra_control              MONEY(14,2);
   DEFINE polcargo                      MONEY(14,2);
   DEFINE polabono                      MONEY(14,2);
{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE dsecuencia                    INTEGER;
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wsucorigen			CHAR(4);
   DEFINE dccosto_orig			CHAR(4);
   DEFINE icontador INTEGER;


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET wcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN wcod_ret, P_MENSAJE;
   END EXCEPTION;


   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

--  SET DEBUG FILE TO "pasecont.out";
--  TRACE ON;


   LET wbegin = "S";
   LET wnum_cuota = 0;
   LET wproceso = ""; --NULL;
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   --LET detusuario = 'credito';
   LET detusuario = pusuariopase;
    LET icontador=1;

   BEGIN WORK;
      LET wcod_ret = "000";
      LET wproceso = pproceso;  -- "PaseCont";
 
	let fecha_pase = fecha_pase;	

      IF fecha_pase IS NULL OR fecha_pase = " "THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM sd_fechas
          WHERE empresa = pempresa;
      ELSE
	LET wfecha_hoy = fecha_pase;
      END IF


      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN wcod_ret, P_MENSAJE;
      END IF

--      SELECT proceso
--        INTO wproceso
--        FROM sd_contproc
--       WHERE empresa = pempresa
--         AND proceso = wproceso
--         AND fecha = fecha_pase;

      SELECT proceso
        INTO wproceso
        FROM bdinteg:sx_contproc
       WHERE empresa = pempresa
         AND proceso = wproceso
         AND sistema = "06"
         AND fecha = fecha_pase;


      --borra lo existente en la base de contabilidad
      delete from bdicont:co_poldet
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_detpol
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_poliza
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      SELECT ejecutivo
        INTO wejecutivo
        FROM bdinteg:si_ejecut
       WHERE empresa = pempresa
         AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET wcod_ret = "090";
         LET P_MENSAJE = 'Usuario no Valido para ejecutar el proceso';
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN wcod_ret, P_MENSAJE;
      END IF;

      if wproceso is NULL then

        LET wproceso = pproceso;   --"PaseCont";

        INSERT INTO sd_contproc
        VALUES (pempresa, wproceso, fecha_pase, "I", USER,
                CURRENT, CURRENT, "  ", "Proceso Iniciado");
                
        INSERT INTO bdinteg:sx_contproc 
	   (empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,
	    hora_fin,codret)
        VALUES 
	   (pempresa, wproceso, fecha_pase, "06","I", USER,CURRENT, 
	    CURRENT, "  ");
                
      else
        UPDATE sd_contproc
               set ejecutivo = user
                  ,hora_inicio = current
                  ,hora_fin = current
                  ,status_proc = 'I'
                  ,mensaje = 'PROCESO INICIADO'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   fecha = fecha_pase;
        
        UPDATE bdinteg:sx_contproc
               set ejecutivo = user
                  ,hora_ini = current
                  ,hora_fin = current
                  ,status_proc = 'I'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   sistema = "06"
        AND   fecha = fecha_pase;

      end if;

   commit work;
   LET wbegin = "N";

{************************************************************************
 ** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS         **
 ** NECESARIOS PARA EL PASE CONTABLE                                   **
 ************************************************************************}

      CREATE TEMP TABLE tdetpol
         ( usuario               CHAR(11)  NOT NULL ,
          control_poliza        SMALLINT NOT NULL ,
          fecha_captura         DATE     NOT NULL ,
          secuencia             INTEGER  NOT NULL ,
          empresa               CHAR(3),
          ccmayor               CHAR(4),
          ccsub                 CHAR(3),
          ccsubsub              CHAR(3),
          ccssubsub             CHAR(3),
          ccsssubsub            CHAR(3),
          sector                CHAR(3),
          ciudad                CHAR(3),
          sucursal              CHAR(4),
          nro_auxiliar          CHAR(9),
          naturaleza            CHAR(1),
          monto                 MONEY(19,2),
          descripcion_det       CHAR(50),
          fecha_valida          DATE,
          moneda                CHAR(2),
          valor_cambio          MONEY(12,7),
          valor_div_cambio      MONEY(12,7),
          mca_aplic             CHAR(1),
          poliza_usuario        CHAR(11),
          tipo_mov              CHAR(1),
          ccosto_orig           CHAR(4)) with no log;

      SET ISOLATION TO DIRTY READ;

      SELECT valor
        INTO wbanco
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param = "5";

      SELECT valor
        INTO wdivisa_cambio
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param  = "17";

      SELECT tipo_cpa_mn_div
        INTO valor_cambio
        FROM bdinteg:si_tpcambio
       WHERE empresa = pempresa
         AND divisa = wdivisa_cambio
         AND fecha_tpcambio = wfecha_hoy
         AND clase_tpcambio = "O";

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF  (nrows = 0) THEN
      {   SELECT tipo_cpa_mn_div
           INTO valor_cambio
           FROM bdinteg:si_histdiv
          WHERE empresa = pempresa
            AND divisa = wdivisa_cambio
            AND fecha_tc = wfecha_hoy
            AND clase_tpcambio = "O";}

         LET nrows = dbinfo("sqlca.sqlerrd2");
--         IF (nrows = 0) THEN
--            LET wcod_ret ="017";
--            IF (wbegin = "S") THEN
--               ROLLBACK WORK;
--               BEGIN WORK;
--            ELSE
--               ROLLBACK WORK;
--            END IF;
--            RETURN wcod_ret, P_MENSAJE;
--         END IF;
      END IF;

      LET wusuario = pusuariopase;   --"credito";  
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_hoy;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

      SELECT MAX(control_poliza)
        INTO wnumpolmn
        FROM bdicont:co_detpol
       WHERE usuario = wusuario
         AND fecha_captura = wfecha_hoy
         AND moneda = "00"
         AND empresa = pempresa;

      IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN
         LET wnumpolmn = 1;
      ELSE
         LET wnumpolmn = wnumpolmn + 1;
      END IF;

      LET wnumpoldl = wnumpolmn + 1;
      IF pusuariopase = "califcar" OR pusuariopase  = "canccart" then
        SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis_calif a,sd_maecred b,bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
			AND c.empresa=a.empresa
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = fecha_pase
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
		UNION
		SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis_calif_cnr a,sd_maecredcrd b,bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
			AND c.empresa=a.empresa
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = fecha_pase
            AND a.monto > 0
			AND a.num_producto='6011'
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      ELSE
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis a, sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
			AND c.empresa=a.empresa
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) NOT IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov =fecha_pase
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      END IF


      FOREACH
         SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           INTO wregional, wsucursal, wdivisa, wcodigo_fun,
                wcodigo_ref, wsucorigen, wabreviatura, wsecuencia, wvaloriza, 
	            wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                wmonto
           FROM x a, sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun
            AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa
            AND c.numero = b.transacc
            AND c.sistema = "06"
            AND d.empresa = b.empresa
            AND d.producto = a.num_producto
            AND d.sistema = c.sistema
            AND d.transaccion = b.transacc
            AND d.secuencia>0
          ORDER BY 1,2,3,4,5,6

            LET wdescripcion_det = wabreviatura;

            IF (wvaloriza = "S" AND wsecuencia = 2
                AND wdivisa <> "00") THEN
               LET wmonto = wmonto * valor_cambio;
               LET wdivisa = "00";
            END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;


   LET wcmayor = trim(wcmayor);
   IF wcmayor[1,2] = "95" THEN

           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal 
	--	wsucorigen
               );
   ELSE
     
           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
  
   END IF; 

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;

  LET wamayor = trim(wamayor); 
  IF wamayor[1,2] = "95" THEN

            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal
	--	wsucorigen
               );
   ELSE
            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                pfecha_captura,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
   END IF;

      END FOREACH;

      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET detsecuencia = 1;
      LET detvalor_cambio = 0;
      LET detvalor_div_cambio = 0;
      LET detmca_aplica = " ";
      LET dettipo_mov = " ";


      FOREACH with hold
         SELECT usuario, control_poliza, fecha_captura ,
            empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector, ciudad, sucursal, nro_auxiliar, naturaleza, sum(monto),
            descripcion_det, fecha_valida, moneda, ccosto_orig
         INTO detusuario, detcontrol_poliza, detfecha_captura,
            detempresa, detmayor, detsub1, detsub2, detsub3, detsub4,
            detsector, detciudad, detsucursal, detnro_auxiliar,
            detnaturaleza, detmonto, detdescripcion_det, detfecha_valida,
            detmoneda, dccosto_orig
         FROM
            tdetpol
         GROUP BY
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19
         ORDER BY
            11, 12, 5, 6, 7, 8, 9, 10

         IF (detmoneda = "00") THEN
            LET detcontrol_poliza = wnumpolmn;
            LET detsecuencia = wsecuenciamn;
            LET wsecuenciamn = wsecuenciamn + 1;
         ELSE
            LET detcontrol_poliza = wnumpoldl;
            LET detsecuencia = wsecuenciadl;
            LET wsecuenciadl = wsecuenciadl + 1;
         END IF;
            
        IF icontador=1 then
          BEGIN WORK;
        END IF;

         LET detpoliza_usuario = detusuario;
         INSERT INTO
            bdicont:co_poldet
         VALUES
           (detusuario,
            detfecha_captura,
            detsecuencia,
            detempresa,
            detmayor,
            detsub1,
            detsub2,
            detsub3,
            detsub4,
            detsector,
            detciudad,
            detsucursal,
			detnro_auxiliar,
            detnaturaleza,
            detmonto,
            detdescripcion_det,
            detfecha_valida,
            detmoneda,
	    	dccosto_orig);

    IF icontador>=70000 then
        COMMIT WORK; 
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

      END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

      DROP TABLE tdetpol;
      DROP TABLE x;

--   IF (wbegin = "S") THEN
--      COMMIT WORK;
--      BEGIN WORK;
--   ELSE
--      COMMIT WORK;
--   END IF;

   --EJECUTA EL PROCESO DE AUDITOR
   EXECUTE PROCEDURE BDICONT:AUDITAPASE(pfecha_captura,PEMPRESA,detusuario)
           INTO WCOD_RET;

    IF wcod_ret = "00000" THEN
       LET wcod_ret = "000";
    END IF	

   let v_error = wcod_ret;

   IF v_error = 0 then
      UPDATE sd_contproc
      SET status_proc = "F",
          mensaje = 'PROCESO EXITOSO',
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "F",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   ELSE
      UPDATE sd_contproc
      SET status_proc = "C",
          mensaje = 'ERROR: ' || P_MENSAJE,
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "C",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   END IF;

--   commit work;
   RETURN wcod_ret, P_MENSAJE;

END PROCEDURE;
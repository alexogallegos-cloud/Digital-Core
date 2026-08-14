CREATE PROCEDURE "informix".sp_altas_idbox2_totales(
                                        pFechIni DATE, 
                                        pFechFin DATE,
                                        pUsuario CHAR(8))
        
		RETURNING  INTEGER as CodErr, 
		INTEGER as total_registros;
        
        DEFINE iSqlErr 			INTEGER;
        DEFINE  i_NoRegistros   INTEGER;
		DEFINE bInTransaccion   BOOLEAN;
		DEFINE iRow INTEGER;
		DEFINE iContBloque INTEGER;
		
		--- SI_CLIENTE
		DEFINE cEmpresa        	CHAR(3);
		DEFINE cNumcte         	CHAR(20);
		DEFINE cStatuscte     	CHAR(2);
		DEFINE cSucursal       	CHAR(4);
		DEFINE cEjecutivo      	CHAR(8);
		DEFINE cTpopersona    	CHAR(2);
		DEFINE cTipocliente   	CHAR(1);
		DEFINE cApellpaterno  	CHAR(26);
		DEFINE cApellmaterno  	CHAR(26);
		DEFINE cNombre1        	CHAR(26);
		DEFINE cNombre2        	CHAR(26);
		DEFINE cRazonsocial   	CHAR(60);
		DEFINE cRfc            	CHAR(13);
		DEFINE cSector         	CHAR(2);
		DEFINE cSegmento       	CHAR(3);
		DEFINE cActividadprinc	CHAR(3);
		DEFINE cGrupo          	CHAR(3);
		DEFINE cSubgrupo       	CHAR(3);
		DEFINE cResidencia     	CHAR(1);
		DEFINE dFechaalta     	DATE;
		DEFINE cApellcasada   	CHAR(26);
		DEFINE cDistrito       	CHAR(2);
		DEFINE cNumcteref     	CHAR(20);
		DEFINE cString1        	CHAR(20);
		DEFINE cString2        	CHAR(60);
		DEFINE iNumeric1       	SMALLINT;
		DEFINE iNumeric2       	INTEGER;
		DEFINE dMoney1         	MONEY;
		DEFINE dDate1          	DATE;
		DEFINE cPuestoppes    	CHAR(1);
		DEFINE cFamiliarppes  	CHAR(1);
		DEFINE cActividadesp  	CHAR(11);
		DEFINE cEjecutautoriza	CHAR(8);
		DEFINE cUserinsert    	CHAR(8);
		DEFINE dFechainsert   	DATE;
		DEFINE cRfcalterno    	CHAR(13);
		DEFINE cTpobiometria  	CHAR(1);
		DEFINE cClientepros   	CHAR(1);
		DEFINE iEnviomovtos   	SMALLINT;
		--- SI_BITACORA_IFE
		DEFINE cNumcteb                 CHAR(9);
		DEFINE cEjecutivob              CHAR(8);
		DEFINE cSucursalb               CHAR(5);
		DEFINE cCadenaanverso         	LVARCHAR(2048);
		DEFINE cCadenareverso         	LVARCHAR(2048);
		DEFINE cFlagidbox             	CHAR(1);
		DEFINE cFlagws                	CHAR(1);
		DEFINE cFlagcaptura           	CHAR(1);
		DEFINE cResultado              	CHAR(50);
		DEFINE cCausarechazo          	CHAR(100);
		DEFINE dFecha                  	DATETIME YEAR to FRACTION(3);
		DEFINE cCodrespife           	CHAR(10);
		DEFINE cRespife               	CHAR(50);
		DEFINE cTimeife               	CHAR(30);
		DEFINE cAccessife             	CHAR(30);
		DEFINE cStampife              	CHAR(30);
		DEFINE cOcrife                	CHAR(1);
		DEFINE cAppatife              	CHAR(1);
		DEFINE cApmatife              	CHAR(1);
		DEFINE cNombreife             	CHAR(1);
		DEFINE cCallenumife           	CHAR(1);
		DEFINE cColcpife              	CHAR(1);
		DEFINE cMpoentife             	CHAR(1);
		DEFINE cFolionalife           	CHAR(1);
		DEFINE cAnioregife            	CHAR(1);
		DEFINE cEmisionife            	CHAR(1);
		DEFINE cCveelecife            	CHAR(1);
		DEFINE cCurpife               	CHAR(1);
		DEFINE cEstado                 	CHAR(1);
		DEFINE cMpioife               	CHAR(1);
		DEFINE cLocalidadife          	CHAR(1);
		DEFINE cSeccionife            	CHAR(1);
		DEFINE cAnioemisionife        	CHAR(1);
		DEFINE cVigenciaife           	CHAR(1);
		DEFINE cEdadife               	CHAR(1);
		DEFINE cSexoife               	CHAR(1);
		DEFINE cAnsi2ife              	CHAR(1);
		DEFINE cAnsi7ife              	CHAR(1);
		DEFINE cModeloife             	CHAR(25);
		DEFINE cActualizado            	CHAR(1);
		DEFINE cTestuvreflecanv     	CHAR(20);
		DEFINE cTestuvshapeanv      	CHAR(20);
		DEFINE cTestirinkanv        	CHAR(20);
		DEFINE cTestuvreflectancerev	CHAR(20);
		DEFINE cTestirinkrev        	CHAR(20);
		DEFINE cTmpansi2ife           	LVARCHAR(2048);
		DEFINE iCompansi2ife          	INTEGER;
		DEFINE cTmpansi7ife           	LVARCHAR(2048);
		DEFINE iCompansi7ife          	INTEGER;
		DEFINE cIdsolmovil           	CHAR(20);
		--- SW_TMP_IDBX
		DEFINE iTotalAltas	INTEGER;
		DEFINE iTotalIdbx	INTEGER;
        
        LEt iSqlErr          = 0;
        LET i_NoRegistros    = 0;	
		LET bInTransaccion   = 'f';
		LET iRow = 0;
		LET iContBloque = 0;		
		
		--- SI_CLIENTE
		LET cEmpresa           = '';
		LET cNumcte            = '';
		LET cStatuscte     	   = '';
		LET cSucursal          = '';
		LET cEjecutivo         = '';
		LET cTpopersona    	   = '';
		LET cTipocliente   	   = '';
		LET cApellpaterno  	   = '';
		LET cApellmaterno  	   = '';
		LET cNombre1           = '';
		LET cNombre2           = '';
		LET cRazonsocial   	   = '';
		LET cRfc               = '';
		LET cSector            = '';
		LET cSegmento          = '';
		LET cActividadprinc	   = '';
		LET cGrupo             = '';
		LET cSubgrupo          = '';
		LET cResidencia        = '';
		LET dFechaalta     	   = '';
		LET cApellcasada   	   = '';
		LET cDistrito          = '';
		LET cNumcteref     	   = '';
		LET cString1           = '';
		LET cString2           = '';
		LET iNumeric1          = 0;
		LET iNumeric2          = 0;
		LET dMoney1            = 0;
		LET dDate1             = '';
		LET cPuestoppes    	   = '';
		LET cFamiliarppes  	   = '';
		LET cActividadesp  	   = '';
		LET cEjecutautoriza	   = '';
		LET cUserinsert    	   = '';
		LET dFechainsert   	   = '';
		LET cRfcalterno    	   = '';
		LET cTpobiometria  	   = '';
		LET cClientepros   	   = '';
		LET iEnviomovtos   	   = 0;
		---SI_BITACORA_IFE
		LET cNumcteb                = '';
		LET cEjecutivob             = '';
		LET cSucursalb              = '';
		LET cCadenaanverso         	= '';
		LET cCadenareverso         	= '';
		LET cFlagidbox             	= '';
		LET cFlagws                	= '';
		LET cFlagcaptura           	= '';
		LET cResultado              = '';
		LET cCausarechazo          	= '';
		LET dFecha                  = '';
		LET cCodrespife           	= '';
		LET cRespife               	= '';
		LET cTimeife               	= '';
		LET cAccessife             	= '';
		LET cStampife              	= '';
		LET cOcrife                	= '';
		LET cAppatife              	= '';
		LET cApmatife              	= '';
		LET cNombreife             	= '';
		LET cCallenumife           	= '';
		LET cColcpife              	= '';
		LET cMpoentife             	= '';
		LET cFolionalife           	= '';
		LET cAnioregife            	= '';
		LET cEmisionife            	= '';
		LET cCveelecife            	= '';
		LET cCurpife               	= '';
		LET cEstado                 = '';
		LET cMpioife               	= '';
		LET cLocalidadife          	= '';
		LET cSeccionife            	= '';
		LET cAnioemisionife        	= '';
		LET cVigenciaife           	= '';
		LET cEdadife               	= '';
		LET cSexoife               	= '';
		LET cAnsi2ife              	= '';
		LET cAnsi7ife              	= '';
		LET cModeloife             	= '';
		LET cActualizado            = '';
		LET cTestuvreflecanv     	= '';
		LET cTestuvshapeanv      	= '';
		LET cTestirinkanv        	= '';
		LET cTestuvreflectancerev	= '';
		LET cTestirinkrev        	= '';
		LET cTmpansi2ife           	= '';
		LET iCompansi2ife          	= 0;
		LET cTmpansi7ife           	= '';
		LET iCompansi7ife          	= 0;
		LET cIdsolmovil           	= '';
		--- SW_TMP_IDBX
		LET iTotalAltas = 0;
		LET iTotalIdbx = 0;

        BEGIN
			ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					RETURN iSqlErr, i_NoRegistros;          
				END IF;
			END EXCEPTION;         
			
			ON EXCEPTION IN (-535)
				COMMIT WORK;
				BEGIN WORK;
				LET bInTransaccion = 't';                       
			END EXCEPTION WITH RESUME;
			
			--SET DEBUG FILE TO '/tmp/mfinis/rcf/sucursal/sp_altas_idbox2_totales.out';
			--TRACE ON;
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

		
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1,
				nombre2, razon_social, rfc, sector, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada,
				distrito, numcte_ref, string1, string2, numeric1, numeric2, money1, date1, puesto_ppes, familiar_ppes, actividad_esp,
				ejecut_autoriza, user_insert, fecha_insert, rfc_alterno, tpo_biometria, cliente_pros, envio_movtos
				INTO cEmpresa,cNumcte,cStatuscte,cSucursal,cEjecutivo,cTpopersona,cTipocliente,cApellpaterno,cApellmaterno,cNombre1,
				cNombre2,cRazonsocial,cRfc,cSector,cSegmento,cActividadprinc,cGrupo,cSubgrupo,cResidencia,dFechaalta,cApellcasada,
				cDistrito,cNumcteref,cString1,cString2,iNumeric1,iNumeric2,dMoney1,dDate1,cPuestoppes,cFamiliarppes,cActividadesp,
				cEjecutautoriza,cUserinsert,dFechainsert,cRfcalterno,cTpobiometria,cClientepros,iEnviomovtos
				FROM bdinteg:"informix".si_cliente
			    WHERE tipo_cliente='1'
				AND si_cliente.fecha_insert
				BETWEEN pFechIni AND pFechFin				
				
				INSERT INTO bdicnweb:"informix".sw_si_clientetmp_idbox(empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1,
				nombre2, razon_social, rfc, sector, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada,
				distrito, numcte_ref, string1, string2, numeric1, numeric2, money1, date1, puesto_ppes, familiar_ppes, actividad_esp,
				ejecut_autoriza, user_insert, fecha_insert, rfc_alterno, tpo_biometria, cliente_pros, envio_movtos, usuario) 
				VALUES(cEmpresa,cNumcte,cStatuscte,cSucursal,cEjecutivo,cTpopersona,cTipocliente,cApellpaterno,cApellmaterno,cNombre1,
				cNombre2,cRazonsocial,cRfc,cSector,cSegmento,cActividadprinc,cGrupo,cSubgrupo,cResidencia,dFechaalta,cApellcasada,
				cDistrito,cNumcteref,cString1,cString2,iNumeric1,iNumeric2,dMoney1,dDate1,cPuestoppes,cFamiliarppes,cActividadesp,
				cEjecutautoriza,cUserinsert,dFechainsert,cRfcalterno,cTpobiometria,cClientepros,iEnviomovtos,pUsuario);
				
				LET iContBloque = iContBloque + 1;
				IF iContBloque = 5000 THEN
					LET iContBloque = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;		
			COMMIT WORK;
			
			LET iRow = 0;
		    LET iContBloque = 0;
		
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura,
				resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife,
				appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife,
				emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife,
				vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, test_uv_reflec_anv,
				test_uv_shape_anv, test_ir_ink_anv, test_uv_reflectance_rev, test_ir_ink_rev, tmpansi2_ife, compansi2_ife,
				tmpansi7_ife, compansi7_ife, id_sol_movil
				INTO cNumcteb,cEjecutivob,cSucursalb,cCadenaanverso,cCadenareverso,cFlagidbox,cFlagws,cFlagcaptura,
				cResultado,cCausarechazo,dFecha,cCodrespife,cRespife,cTimeife,cAccessife,cStampife,cOcrife,
				cAppatife,cApmatife,cNombreife,cCallenumife,cColcpife,cMpoentife,cFolionalife,cAnioregife,
				cEmisionife,cCveelecife,cCurpife,cEstado,cMpioife,cLocalidadife,cSeccionife,cAnioemisionife,
				cVigenciaife,cEdadife,cSexoife,cAnsi2ife,cAnsi7ife,cModeloife,cActualizado,cTestuvreflecanv,
				cTestuvshapeanv,cTestirinkanv,cTestuvreflectancerev,cTestirinkrev,cTmpansi2ife,iCompansi2ife,
				cTmpansi7ife,iCompansi7ife,cIdsolmovil
				FROM bdinteg:"informix".si_bitacora_ife
			    WHERE DATE(fecha) BETWEEN pFechIni AND pFechFin AND modelo_ife<>''				
				
				INSERT INTO bdicnweb:"informix".sw_si_bitacoraifetmp_idbox(numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura,
				resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife,
				appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife,
				emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife,
				vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, test_uv_reflec_anv,
				test_uv_shape_anv, test_ir_ink_anv, test_uv_reflectance_rev, test_ir_ink_rev, tmpansi2_ife, compansi2_ife,
				tmpansi7_ife, compansi7_ife, id_sol_movil, usuario) 
				VALUES(cNumcteb,cEjecutivob,cSucursalb,cCadenaanverso,cCadenareverso,cFlagidbox,cFlagws,cFlagcaptura,
				cResultado,cCausarechazo,dFecha,cCodrespife,cRespife,cTimeife,cAccessife,cStampife,cOcrife,
				cAppatife,cApmatife,cNombreife,cCallenumife,cColcpife,cMpoentife,cFolionalife,cAnioregife,
				cEmisionife,cCveelecife,cCurpife,cEstado,cMpioife,cLocalidadife,cSeccionife,cAnioemisionife,
				cVigenciaife,cEdadife,cSexoife,cAnsi2ife,cAnsi7ife,cModeloife,cActualizado,cTestuvreflecanv,
				cTestuvshapeanv,cTestirinkanv,cTestuvreflectancerev,cTestirinkrev,cTmpansi2ife,iCompansi2ife,
				cTmpansi7ife,iCompansi7ife,cIdsolmovil,pUsuario);
	
				LET iContBloque = iContBloque + 1;
				IF iContBloque = 5000 THEN
					LET iContBloque = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;		
			COMMIT WORK;
			
			LET iRow = 0;
		    LET iContBloque = 0;
			LET cSucursal = '';
			
			BEGIN WORK;
			FOREACH WITH HOLD 
				--SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal2)} 0, a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb, pUsuario as usuario
				SELECT a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb
				INTO cSucursal,iTotalAltas,iTotalIdbx
				FROM "informix".si_sucursales a
				LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE SI_CLIENTE EN UN RANGO DE FECHAS
							SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total FROM 
									(SELECT DISTINCT (sicte.numcte), sucursal 
									FROM bdicnweb:"informix".sw_si_clientetmp_idbox  AS sicte  
										INNER JOIN "informix".si_ctepf si_ctepf 
												ON sicte.numcte = si_ctepf.numcte  
									WHERE tipo_cliente='1' AND sicte.fecha_insert BETWEEN pFechIni AND pFechFin ) clientes
							INNER JOIN
							-- OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
									(SELECT numcte, sucursal 
									FROM bdicnweb:"informix".sw_si_bitacoraifetmp_idbox
									WHERE DATE(fecha) BETWEEN pFechIni AND pFechFin AND modelo_ife<>'') bitacora
							ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
							GROUP BY clientes.sucursal
						) b ON a.sucursal=b.sucursal
				LEFT JOIN ( --OBTENIENDO ALTAS POR SUCURSAL
							SELECT sucursal, COUNT(DISTINCT (sicte.numcte)) AS total
							FROM bdicnweb:"informix".sw_si_clientetmp_idbox  AS sicte 
							INNER JOIN "informix".si_ctepf si_ctepf 
									ON sicte.numcte = si_ctepf.numcte  
							WHERE tipo_cliente='1' AND sicte.fecha_insert BETWEEN pFechIni AND pFechFin
							GROUP BY sucursal
						)C ON a.sucursal=C.sucursal
				WHERE a.empresa ='001'
				AND a.sucursal IN (SELECT DISTINCT(sucursal) FROM "informix".si_bitacora_ife)
				
				INSERT INTO bdicnweb:"informix".sw_tmp_idbx(sucursal, altas_total, tot_idb, usuario) 
				VALUES(cSucursal, iTotalAltas, iTotalIdbx, pUsuario);
				
				LET iContBloque = iContBloque + 1;
				IF iContBloque = 5000 THEN
					LET iContBloque = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;		
			COMMIT WORK;
			
			SELECT COUNT(*) 
			INTO i_NoRegistros
			FROM bdicnweb:"informix".sw_tmp_idbx 
			WHERE usuario=pUsuario;                                                                  
	
			RETURN iSqlErr, i_NoRegistros;                                          
		END
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 20/10/2016',
'DESCRIPCION: Se realizo la modificacion para insertar datos a tabla fisica',
'BD: bdinteg',
'AUTOR: Luis Ignacio PÃÆÃÂ©rez Cano',
'FECHA: 13/07/2017',
'DESCRIPCION: Se ajusta la consulta agregando INNER JOIN con la tabla si_ctepf y la condiciÃÆÃÂ³n modelo_ife<>''',
'se elimina ademas la condiciÃÆÃÂ³n sucursal=S',
'BD: bdinteg',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 01/08/2019',
'DESCRIPCION: Se realiza optimizacion de consulta si_cliente y si_bitacora_ife',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtiene_ultimas_img_digi_cte_soc(pEmpresa CHAR(3), cNumCte CHAR(10))
--DATOS A REGRESAR---
RETURNING
CHAR(5)      AS cCodRet,
CHAR(5)	 AS CodigoDoc,
SMALLINT AS sSecuenciaIdentAnverso,
CHAR(20)  AS    cDescripIden,
SMALLINT AS sSecuenciaIdentReverso,
CHAR(20)  AS    cDescripIde2,
CHAR(5) AS cCodDctoComprobante,
SMALLINT AS sSecuenciaMaxComprobante;

---DECLARACIONES
DEFINE iSqlErr         	 INTEGER;
DEFINE cCodRet         	 CHAR(5);
DEFINE CodigoDoc         	 CHAR(5);
DEFINE sSecuenciaIdentReverso        SMALLINT;
DEFINE sSecuenciaIdentAnverso        SMALLINT;
DEFINE cDescripIden CHAR(20);
DEFINE cDescripIde2 CHAR(20);

DEFINE cCodDctoComprobante CHAR(5);
DEFINE sSecuenciaMaxComprobante SMALLINT;
DEFINE iMulti_Img INTEGER;

---INICIALIZACIONES
LET iSqlErr = 0;
LET cCodRet = "00000";
LET sSecuenciaIdentAnverso = 0;
LET CodigoDoc = "";
LET sSecuenciaMaxComprobante = 0;
LET cCodDctoComprobante = "";
LET sSecuenciaIdentReverso = 0;
LET iMulti_Img = 0;
LET cDescripIden = "";
LET cDescripIde2 = "";

BEGIN
	ON EXCEPTION SET iSqlErr
		IF 	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,CodigoDoc,sSecuenciaIdentAnverso,cDescripIden,sSecuenciaIdentReverso,cDescripIde2,cCodDctoComprobante,sSecuenciaMaxComprobante;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/JesusRubio/sp_obtiene_datos.out";
	--TRACE ON;

		IF (NVL(pEmpresa,'') = "" OR NVL(cNumCte,'') = "") THEN
			LET cCodRet = "00024"; --PARAMETROS VACIOS
			RETURN cCodRet,CodigoDoc,sSecuenciaIdentAnverso,cDescripIden,sSecuenciaIdentReverso,cDescripIde2,cCodDctoComprobante,sSecuenciaMaxComprobante;
		ELSE

			CALL bdidigital@coppelimg_tcp:sp_obtiene_ultimas_img_digi_cte(pEmpresa,cNumCte) 
				RETURNING cCodRet,CodigoDoc,sSecuenciaIdentAnverso,cDescripIden,sSecuenciaIdentReverso,cDescripIde2,cCodDctoComprobante,sSecuenciaMaxComprobante;
										
		END IF;

	RETURN cCodRet,CodigoDoc,sSecuenciaIdentAnverso,cDescripIden,sSecuenciaIdentReverso,cDescripIde2,cCodDctoComprobante,sSecuenciaMaxComprobante;

END;
END PROCEDURE
DOCUMENT
'Autor: Coordinacion Credito consumo',
'Fecha: 15/08/19',
'Modificacion: Se crea SP clon para consultar expediente con la misma logica que el SIF',
'Solicita: Atencion de incidencias',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_monitor_folio_pba1()
RETURNING CHAR(5);
--Declaracion de variables
DEFINE vcodret           CHAR(5);
DEFINE vcodretdet        CHAR(5);
DEFINE iSecuencia        INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE sid               INTEGER;
DEFINE snumcte           CHAR(20);
DEFINE sfolio            CHAR(12);
DEFINE sstatus_valua     INTEGER;
DEFINE sempresa          CHAR(3);
DEFINE svalor_param      INTEGER;
DEFINE svalor_param2     INTEGER;
DEFINE svalor_param3     CHAR(12);
DEFINE sfecha_insert     DATE;
DEFINE svt_consecu       FLOAT;
DEFINE svt_base1         CHAR(10);
DEFINE svt_base2         CHAR(4);
DEFINE svt_fecha_hoy     CHAR(10);
DEFINE svt_year          CHAR(4);
DEFINE svt_mes           CHAR(2);
DEFINE svt_dia           CHAR(2);
DEFINE svt_fecha_opera   CHAR(6);
DEFINE svt_cosec_deta    CHAR(4);
DEFINE svt_fecha_opera2  CHAR(10);
DEFINE svt_cuantos       INTEGER;
DEFINE svt_bandera       INTEGER;
DEFINE svt_FechaInsercion CHAR(19);
DEFINE svt_segundos      CHAR(2);
DEFINE svt_minutos       CHAR(2);
DEFINE svte_segundos     INTEGER;
DEFINE svte_minutos      INTEGER;
DEFINE vt_fech_hora      CHAR(19);
DEFINE CsubConsec		 CHAR(4);


--Inicializacion de variables

LET vcodret              = '000';
LET vcodretdet           = "000";
LET iSecuencia           = 0;
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET svalor_param2        = 0;
LET sfecha_insert        = "";
LET svt_consecu          = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET svt_base1            = "";
LET svt_base2            = "";
LET svt_fecha_hoy        = "";
LET svt_year             = "";
LET svt_mes              = "";
LET svt_dia              = "";
LET svt_fecha_opera      = "";
LET svalor_param3        = "";
LET svt_cosec_deta       = "";
LET svt_fecha_opera2     = "";
LET svt_cuantos          = 0;
LET svt_bandera          = 0;
LET svt_segundos         = " ";
LET svt_minutos          = " ";
LET svte_segundos        = 0;
LET svte_minutos         = 0;
LET CsubConsec			 =0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
SET debug FILE TO '/tmp/sp_monitor_folio.out';
TRACE ON;

BEGIN
	 ON EXCEPTION SET iSqlErr
		 IF iSqlErr <> 0 THEN
		LET vcodret = iSqlErr;
		RETURN vCodret;
		END IF;
	 END EXCEPTION

	SELECT MIN(empresa)
	INTO sempresa
	FROM si_empresas;

	SELECT fecha_hoy INTO svt_fecha_hoy
	FROM si_fechas
	WHERE empresa = sempresa;

	SELECT MAX(valor) INTO svalor_param
	FROM si_param
	where empresa = sempresa
	AND cod_param = "341";

	SELECT valor INTO svt_fecha_opera2
	FROM si_param
	where empresa = sempresa
	AND cod_param = "342";

	--Valida dia de operacion
	IF svt_fecha_hoy != svt_fecha_opera2 THEN

	   LET svt_fecha_opera2 = svt_fecha_hoy;
	   LET svalor_param    = "0";

	   --Actualiza e Valor en la tabla de parametros.
	   UPDATE si_param
	   SET(valor)=(svt_fecha_opera2)
	   WHERE empresa = sempresa
	   AND cod_param = "342";

	   UPDATE si_param
	   SET(valor)=(svalor_param)
	   WHERE empresa = sempresa
	   AND cod_param = "341";

	END IF;


	LET svt_year = svt_fecha_hoy[9,10];
	LET svt_mes  = svt_fecha_hoy[1,2];
	LET svt_dia  = svt_fecha_hoy[4,5];

	LET svt_fecha_opera = TRIM(svt_dia)||''||TRIM(svt_mes)||''||TRIM(svt_year);


   ---Ejecuta Cursor principal para revisar numero de folio para solicitud movil
	 FOREACH
			SELECT id, numcte, folio,status_valua,fecha_insert
			INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert
			FROM bdinteg:si_solicitud_movil
			WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
			AND bdinteg:si_solicitud_movil.status_valua = 0
			AND folio IS NULL
			ORDER BY id

			--Actualiza el valor del parametro
			IF svalor_param = 0 THEN
			   LET svalor_param = 1;
			ELSE
			   LET svalor_param = svalor_param + 1;
			END IF;

			---Arma el Nuevo Folio
			LET svt_consecu=0;
			WHILE svt_consecu<10000
				CALL sp_random() RETURNING svt_consecu;

				LET CsubConsec=SUBSTR(svt_consecu,1,4);

				IF EXISTS (SELECT numcte FROM si_solicitud_movil WHERE SUBSTR(folio,7,4)=SUBSTR(CsubConsec,1,4) and fecha_insert=svt_fecha_hoy) THEN
				   LET svt_consecu=0;
				END IF;

			END WHILE;    
			--LET svalor_param=svalor_param;

			IF LENGTH(CsubConsec)=3 THEN
			  LET CsubConsec='0'||CsubConsec;
			ELIF LENGTH(CsubConsec)=2 THEN
			  LET CsubConsec='00'||CsubConsec;
			ELIF LENGTH(CsubConsec)=1 THEN
			  LET CsubConsec='000'||CsubConsec;
			ELIF LENGTH(CsubConsec)=0 THEN
			  LET CsubConsec='0000';  
			END IF;


			IF LENGTH(svalor_param::CHAR(4))=4 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,2);
			ELIF LENGTH(svalor_param::CHAR(4))=3 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,3);
			ELIF LENGTH(svalor_param::CHAR(4))=2 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			ELIF LENGTH(svalor_param::CHAR(4))=1 THEN
				LET svt_cosec_deta = '0'||svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			END IF


			LET svalor_param3 = TRIM(svt_fecha_opera)||''||TRIM(svt_base2)||''||TRIM(svt_cosec_deta);

		   ---Valida si ya existe el folio
			SELECT count(*) INTO svt_cuantos
			FROM si_solicitud_movil
			WHERE folio = svalor_param3;

			IF svt_cuantos > 0 THEN
				IF svalor_param = 0 THEN
					LET svalor_param = 1;
				ELSE
				   LET svalor_param = svalor_param + 1;
				END IF;

			IF LENGTH(svalor_param::CHAR(4))=4 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,2);
			ELIF LENGTH(svalor_param::CHAR(4))=3 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,3);
			ELIF LENGTH(svalor_param::CHAR(4))=2 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			ELIF LENGTH(svalor_param::CHAR(4))=1 THEN
				LET svt_cosec_deta = '0'||svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			END IF

				LET svalor_param3 = TRIM(svt_fecha_opera)||''||TRIM(svt_base2)||''||TRIM(svt_cosec_deta);
			END IF;


			SELECT DBINFO('utc_to_datetime',sh_curtime) INTO vt_fech_hora
			FROM sysmaster:"informix".sysshmvals;

			--Actualiza el numero de folio del nuevo registro
			UPDATE si_solicitud_movil
			SET(folio,fecha_folio)=(svalor_param3,vt_fech_hora)
			WHERE id = sid;

			--LET svt_bandera = 1;

		  UPDATE si_param
		  SET(valor)=(svalor_param)
		  WHERE empresa = sempresa
		  AND cod_param = "341";

	 END FOREACH;

RETURN vcodret;
END;
END PROCEDURE
;
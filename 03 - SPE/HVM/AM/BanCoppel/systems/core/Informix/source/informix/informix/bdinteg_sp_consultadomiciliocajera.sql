CREATE PROCEDURE "informix".sp_consultadomiciliocajera( pModo SMALLINT, pCliente CHAR(20) )
	--- pModo = 1 - Consulta de Domicilio Personal
	--- pModo = 2 - Consulta de Domicilio del Trabajo
	RETURNING CHAR(6) AS cCodRet ,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,CHAR(26) AS cNombre1,
		CHAR(26) AS cNombre2,CHAR(15) AS cNombreCiudad,CHAR(30) AS cNombreZona,CHAR(10) AS cNumeroExterior,CHAR(10) AS cNumeroInterior,
		CHAR(6) AS cDepto,CHAR(1) AS cRumbo,CHAR(30) AS cNombreCalle,CHAR(5) AS cCodigoPostal,CHAR(80) AS cObservaciones,CHAR(13) AS cTelefonoParticular,
		CHAR(13)AS cTelefonoCelular,CHAR(13) AS cTelefonoTrabajo,CHAR(13) AS cTelefonoReferencia,CHAR(40) AS cEntreCalles,CHAR(2) AS cEstado,
		CHAR(30) AS cNombreEstado,CHAR(60) AS cLugarTrabajo,CHAR(2) AS cUnidad,CHAR(3) AS cCiudad,INTEGER AS iColonia,INTEGER AS iCalle,INTEGER AS iManzana,
		INTEGER AS iOtros,INTEGER AS iAndador,INTEGER AS iEtapa,INTEGER AS iLote,INTEGER AS iEdificio,INTEGER AS iEntrada,INTEGER AS iCiudadCoppel, CHAR(100) AS cEmail;
			  
			  
		DEFINE isqlerr INTEGER;
		DEFINE cCodRet CHAR(6);
		DEFINE cApellidoPaterno CHAR(26);
		DEFINE cApellidoMaterno CHAR(26);
		DEFINE cNombre1 CHAR(26);
		DEFINE cNombre2 CHAR(26);
		DEFINE cNombreCiudad CHAR(15);
		DEFINE cNombreZona CHAR(30);
		DEFINE cNumeroExterior CHAR(10);
		DEFINE cNumeroInterior CHAR(10);
		DEFINE cDepto CHAR(6);
		DEFINE cRumbo CHAR(1);
		DEFINE cNombreCalle CHAR(30);
		DEFINE cCodigoPostal CHAR(5);
		DEFINE cObservaciones CHAR(80);
		DEFINE cTelefonoParticular CHAR(13);
		DEFINE cTelefonoCelular CHAR(13);
		DEFINE cTelefonoReferencia CHAR(13);
		DEFINE cTelefonoTrabajo CHAR(13);
		DEFINE cEntreCalles CHAR(40);
		DEFINE cCiudad CHAR(3);
		DEFINE iColonia INTEGER ;
		DEFINE iCalle INTEGER ;
		DEFINE cUnidad CHAR(2);
		DEFINE iManzana INTEGER ;
		DEFINE iOtros INTEGER ;
		DEFINE iAndador INTEGER ;
		DEFINE iEtapa INTEGER ;
		DEFINE iLote INTEGER ;
		DEFINE iEdificio INTEGER ;
		DEFINE iEntrada INTEGER ;
		DEFINE cEstado CHAR(2);
		DEFINE cNombreEstado CHAR(30);
		DEFINE cLugarTrabajo CHAR(60);
		DEFINE iCiudadCoppel INTEGER ;
		DEFINE cEmail CHAR(100);
		
		DEFINE cNumSolicitud CHAR(20);
		DEFINE cNumSolicitud2 CHAR(20);
		DEFINE dFecha1 DATE;
		DEFINE dFecha2 DATE;
		DEFINE cProducto CHAR(4);

		LET isqlerr = 0;
		LET cCodRet = "";
		LET cApellidoPaterno = " ";
		LET cApellidoMaterno = " ";
		LET cNombre1 = " ";
		LET cNombre2 = " ";
		LET cNombreCiudad = " ";
		LET cNombreZona = " ";
		LET cNumeroExterior = " ";
		LET cNumeroInterior = " ";
		LET cDepto = " ";
		LET cRumbo = " ";
		LET cNombreCalle = " ";
		LET cCodigoPostal = " ";
		LET cObservaciones = " ";
		LET cTelefonoParticular = " ";
		LET cTelefonoCelular = " ";
		LET cTelefonoReferencia = " ";
		LET cTelefonoTrabajo = " ";
		LET cEntreCalles = " ";
		LET cCiudad = "";
		LET iColonia = 0;
		LET iCalle = 0;
		LET cUnidad= "N";
		LET iManzana = 0;
		LET iOtros = 0;
		LET iAndador = 0;
		LET iEtapa = 0;
		LET iLote = 0;
		LET iEdificio = 0;
		LET iEntrada = 0;
		LET cEstado = " ";
		LET cNombreEstado = " ";
		LET cLugarTrabajo = " ";
		LET iCiudadCoppel = 0;
		LET cEmail = " ";

		LET cNumSolicitud = '';
		LET cNumSolicitud2 = '';
		LET dFecha1 = '01/01/1900';
		LET dFecha2 = '01/01/1900';
		LET cProducto = '';

		--SET DEBUG FILE TO "/respaldosbd/AnahiLeyva/sp_consultadomiciliocajera.out";
		--TRACE ON;
		
		BEGIN

		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN
				LET cCodRet = isqlerr;
				RETURN cCodRet,cApellidoPaterno,cApellidoMaterno,cNombre1,cNombre2,cNombreCiudad,cNombreZona,cNumeroExterior,cNumeroInterior,cDepto,cRumbo,
						cNombreCalle,cCodigoPostal,cObservaciones,cTelefonoParticular,cTelefonoCelular,cTelefonoTrabajo,cTelefonoReferencia,cEntreCalles,
						cEstado,cNombreEstado,cLugarTrabajo,cUnidad,cCiudad,iColonia,iCalle,iManzana,iOtros,iAndador,iEtapa,iLote,iEdificio,iEntrada,iCiudadCoppel,cEmail;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;   
		
		--Se obtiene numero de solicitud
			SELECT limit 1 fecha_apertura, num_credito 		
			INTO dFecha1, cNumsolicitud
			FROM bdicred:"informix".sd_maecred 
			WHERE numcte   =  pCliente 
			AND fecha_apertura = (SELECT MAX(fecha_apertura)
								FROM bdicred:"informix".sd_maecred 
								WHERE numcte   =  pCliente );
			
			SELECT  limit 1 fecha_apertura, num_credito, num_producto 
			INTO dFecha2, cNumsolicitud2, cProducto
			FROM bdicred:"informix".sd_maecredcrd
			WHERE numcte = pCliente
			AND  fecha_apertura = (SELECT MAX (fecha_apertura) 
								FROM bdicred:"informix".sd_maecredcrd
								WHERE numcte   =  pCliente );
		
		IF dFecha1 IS NULL OR dFecha1 = "" THEN
			LET dFecha1 = '01/01/1900';
		END IF;
		
		IF dFecha2 IS NULL OR dFecha2 = ""  THEN
			LET dFecha2 = '01/01/1900';
		END IF;
		
		IF dfecha1 < dFecha2 THEN		
			IF cProducto = '6011' THEN
				SELECT num_credito 		
				INTO cNumsolicitud
				FROM bdicred:"informix".sd_maecred 
				WHERE credito_externo =  cNumsolicitud2;
			ELSE
				LET cNumsolicitud = cNumsolicitud2;
			END IF;
		END IF;		
			
		IF NVL(cNumSolicitud, '') <> '' THEN
			--Obtener el numero de telefono		
			SELECT telefono_ref 
			INTO cTelefonoReferencia  
			FROM bdisolic:"informix".ss_refpersonales 
			WHERE numcte = pCliente AND num_solicitud = cNumSolicitud
			AND numcte_ref = 'R1';

			IF NVL(cTelefonoReferencia,'') = '' THEN
				SELECT  first 1 b.telefono1 
				INTO  cTelefonoReferencia 
				FROM bdinteg:"informix".si_refclientes a, bdinteg:"informix".si_refdirecciones b
				WHERE a.empresa = '001'
				  and a.num_solicitud = cNumSolicitud
				  and a.numcte = pCliente
				  AND a.numcte = b.numcte 
				  AND a.secuencia = b.secuencia ;
			END IF;
			let cTelefonoReferencia = nvl(cTelefonoReferencia,'');
			--IF NVL(cTelefonoReferencia,'') <> '' THEN
				SELECT '000',NVL(t1.apell_paterno,''), NVL(t1.apell_materno,''), NVL(t1.nombre1,''), NVL(t1.nombre2,''), 
				NVL(t2.ciudad,0), NVL(t2.numerocolonia,0), NVL(t2.numeroextcalle,''), NVL(t2.numerointcalle,''),NVL(t2.departamento,''), 
				NVL(t2.puntocardinal,''), NVL(t2.numerocalle,0), NVL(t2.cod_postal,''), NVL(t2.observaciones,''), NVL(t2.manzana,0)::INTEGER, 
				NVL(t2.otros,0)::INTEGER, NVL(t2.andador,0)::INTEGER, NVL(t2.etapa,0)::INTEGER, NVL(t2.lote,0)::INTEGER, NVL(t2.edificio,0)::INTEGER,
				NVL(t2.entrada,0)::INTEGER, NVL(t9.telefono,''), NVL(t92.telefono,''), NVL(t93.telefono,''),
				--t7.telefono_ref as referencia, 
				NVL(t3.nombre,''), NVL(t4.nombrecalle,''), NVL(t5.nombrezona,''), NVL(t2.entre_calles,''), NVL(t2.estado,''), NVL(t6.nombre,''),--<--si_estados
				NVL((SELECT nombre_empresa
							FROM "informix".SI_INGRESOS ING1 
							WHERE ING1.tipo_ingreso = 'T'
							AND ING1.sec_ingreso = ( SELECT MAX(ING2.sec_ingreso)
														FROM "informix".si_ingresos ING2 
														WHERE t1.EMPRESA = ING2.EMPRESA 
														AND t1.NUMCTE = ING2.NUMCTE 
														AND ING2.tipo_ingreso = 'T') 
							AND t1.EMPRESA = ING1.EMPRESA 
							AND t1.NUMCTE = ING1.NUMCTE),''),
							NVL(t2.unidadhabitac,'N'), NVL(t3.ciudad_coppel,0)::INTEGER, NVL(t10.correo_elec,'')
				INTO cCodRet ,cApellidoPaterno, cApellidoMaterno, cNombre1, cNombre2, 
				cCiudad, iColonia, cNumeroExterior, cNumeroInterior, cDepto, 
				cRumbo, iCalle, cCodigoPostal, cObservaciones, iManzana, 
				iOtros, iAndador, iEtapa, iLote, iEdificio,
				iEntrada, cTelefonoParticular, cTelefonoCelular, cTelefonoTrabajo, 
				--cTelefonoReferencia, 
				cNombreCiudad, cNombreCalle, cNombreZona, cEntreCalles, cEstado, cNombreEstado, 
				cLugarTrabajo, 
				cUnidad, iCiudadCoppel, cEmail
				FROM "informix".si_cliente t1
				LEFT JOIN "informix".si_direcciones_actual t2 ON (t1.numcte = t2.numcte AND t2.tipo_dir = pModo) --- AND t2.secuencia = (SELECT MAX(t6.secuencia) FROM bdinteg:si_direcciones t6 WHERE t6.numcte = t1.numcte AND t6.tipo_dir = t2.tipo_dir )) 
				LEFT JOIN "informix".si_ciudades t3 ON t2.ciudad = t3.ciudad AND t2.estado = t3.estado
				LEFT JOIN "informix".si_catcalles t4 ON t2.numerocalle = t4.numerocalle
				LEFT JOIN "informix".si_catzonas t5 ON t2.numerociudad = t5.numerociudad AND t2.numerocolonia = t5.numerocolonia
				LEFT JOIN "informix".si_estados t6 ON t2.estado = t6.estado
				--2014/06/09
				--LEFT JOIN bdisolic:"informix".ss_refpersonales t7 ON (t1.numcte = t7.numcte AND t7.numcte_ref = 'R1')
				--JOIN bdicred:"informix".sd_maecred t8 ON (t1.numcte = t8.numcte AND t7.num_solicitud = t8.num_credito)
				LEFT OUTER JOIN "informix".si_telefonos_actual t9 ON ( t9.numcte = t1.numcte AND t9.tipo_tel = 1 )
				LEFT OUTER JOIN "informix".si_telefonos_actual t92 ON ( t92.numcte = t1.numcte AND t92.tipo_tel = 2 )
				LEFT OUTER JOIN "informix".si_telefonos_actual t93 ON ( t93.numcte = t1.numcte AND t93.tipo_tel = 3 )
				LEFT JOIN "informix".si_correos t10 ON ( t10.numcte = t1.numcte 
				AND t10.secuencia = (SELECT MAX(secuencia)
									FROM "informix".si_correos
									WHERE numcte = pCliente
									AND tipo_correo = pModo ))
				WHERE t1.numcte = pCliente;
			--ELSE
				--LET cCodRet = '002' ;  --- No existe el cliente en el catalogo de telefonos
			--END IF;
		ELSE
			LET cCodRet = '001' ;  --- No existe el cliente en el catalogo
		END IF ;
		RETURN cCodRet,cApellidoPaterno,cApellidoMaterno,cNombre1,cNombre2,cNombreCiudad,cNombreZona,cNumeroExterior,cNumeroInterior,cDepto,cRumbo,
			   cNombreCalle,cCodigoPostal,cObservaciones,cTelefonoParticular,cTelefonoCelular,cTelefonoTrabajo,cTelefonoReferencia,cEntreCalles,
			   cEstado,cNombreEstado,cLugarTrabajo,cUnidad,cCiudad,iColonia,iCalle,iManzana,iOtros,iAndador,iEtapa,iLote,iEdificio,iEntrada,iCiudadCoppel, cEmail with resume;
		END
	END PROCEDURE
	DOCUMENT
	'06/Febrero/2008',
	'Walber Castro',
	'Obtiene los datos del domicilio del cliente',
	'*********************************************',
	'17/Junio/2008',
	'Walber Castro',
	'Se corrige como toma el nombre de la empresa por el maximo de secuencia de la si_ingresos.',
	'*********************************************',
	'11/Julio/2008',
	'Walber Castro',
	'Se agrega el parametro de ciudad coppel.',
	'*********************************************',
	'10/Sept/2008',
	'Walber Castro',
	'Se modifica el ON de las tablas si_cliente join di_direcciones',
	'para que se obtengan los datos del cliente aun cuando no haya',
	'informaci?n del domicilio del trabajo.',
	'**********************************************',
	'2009-01-07',
	'Marcos Cuevas',
	'Se agrego la validacion de tipo ingreso en las consulta ala si_ingresos',
	'2011-02-03  Por MACF',
	'*************************************************************************************************************************',
	'Se modifica para obtener el tel?fono de la Referencia, siempre y cuando el Cliente haya ingresado una solicitud de TDC',
	'******************************************************************************************************************************',
	' 2011-07-05 Se modifica para que solo obtenga info de la solicitud y/o credito aprobado - Marco A. Campos',
	'*************************************************************************************************************************',
	' 2013-08-27 Se modifica para a?adir retorno y consulta de email de cte '' Hugo G. Vazquez',
	'*************************************************************************************************************************',
	' 2014-06-09 ',
	' Descripcion: Se sustituye tabla ss_refpersonales',
	' Modifico: Victor Hugo Nu?ez',
	'*************************************************************************************************************************';

CREATE PROCEDURE "informix".sp_actualizactecpl_club
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplProspecto	CHAR(20),
	pCteCplTitular		CHAR(20)
)

RETURNING
	CHAR(06) AS cCodRet;

--VARIABLES
	DEFINE vcCodRet		CHAR(06);
	DEFINE iSql_err		INTEGER;

--INICIALIZACIÓN DE VARIABLES
	LET vcCodRet = '000000';
	LET iSql_err = 0;

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_actualizactecpl_club_out.sql';
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
	END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARÁMETROS VACÍOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplProspecto), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '000001';
			RETURN vcCodRet;
		END IF;
		
		--BÚSQUEDA DE DATOS
		UPDATE "informix".si_club_proteccion
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		UPDATE "informix".si_club_beneficiario
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		UPDATE "informix".si_club_servicio
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		UPDATE "informix".si_club_bitacora
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		RETURN vcCodRet;
	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - José Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripción:	Actualiza el cliente prospecto por el cliente titular Coppel en todas las tablas del club de protección',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_consulsolicporenviar_club(pEmpresa CHAR(3))

	RETURNING CHAR(5),    --Código Retorno
	          CHAR(20),   --Número de Cliente 
              CHAR(20),   --Número de Solicitud
              CHAR(1050); --Trama de envió de cliente 
	
	--DECLARACION DE VARIABLES
	DEFINE iSqlErr          INTEGER;
	DEFINE vCodRet          CHAR(5);    --Código Retorno
	DEFINE vNumCte          CHAR(20);   --Número Cliente
	DEFINE vNumSolicitud    CHAR(20);   --Número Solicitud
	DEFINE vTrama           CHAR(1050); --Trama Alta Cliente
	DEFINE vCodRet2         CHAR(5);    --Código Retorno 2
	DEFINE iClave       	SMALLINT;   --Clave
	DEFINE cSubClave    	CHAR(5);    --SubClave
	DEFINE cIP          	CHAR(1);    --IP
	DEFINE cMac    	        CHAR(1);    --MAC
	DEFINE cOperador  	    CHAR(8);    --Operador
	
	--INICIALIZACION DE VARIABLES
	LET vCodRet         = '00000'; --CONSULTA REGISTROS POR ENVIAR.
	LET iSqlErr			= 0;
	LET vNumCte         = '';
	LET vNumSolicitud   = '';
	LET vTrama          = '';
	LET vCodRet2        = '00000';
	LET iClave          = 90;
	LET cSubClave       = "0015";
	LET cIP    	        = " ";
	LET cMac            = " ";
	LET cOperador       = "informix";
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;
	
	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_consulsolicporenviar_club_out.sql';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
				LET vCodret = iSqlErr;
				RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
		   END IF;
		END EXCEPTION;
		
		IF pEmpresa = '' OR pEmpresa IS NULL THEN
			LET vCodRet = '00001'; --PARAMETRO DE ENTRADA VACIO.
			RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
		ELSE
			IF EXISTS (SELECT 1 FROM "informix".si_clientescoppelporenviar WHERE empresa = pEmpresa AND status = 0) THEN
				FOREACH
					
					SELECT	numcte, num_solicitud 
					INTO	vNumCte, vNumSolicitud
					FROM	"informix".si_clientescoppelporenviar
					WHERE	empresa = pEmpresa
					AND		status = 0
					
					EXECUTE PROCEDURE "informix".sp_altactecoppelnuevoparametrico_club(pEmpresa, vNumCte, vNumSolicitud)
					INTO vCodRet2, vTrama;
					
					LET vCodRet = '00000';
					
					IF vCodRet2 <> '00000' THEN
						LET vCodRet = '00003'; --ERROR EN EL TRAMA DE ENVIO DEL CLIENTE.
					END IF;
					
					LET vTrama = iClave ||"|"|| TRIM(cSubClave) ||"|"|| TRIM(vTrama) ||"|"|| cIP ||"|"|| cMac ||"|"|| cOperador ||"|";
					
					RETURN vCodret, vNumCte, vNumSolicitud, vTrama WITH RESUME;
					
				END FOREACH;
			ELSE
				LET vCodRet = '00002'; --NO HAY REGISTROS PARA ENVIAR A COPPEL.
				RETURN vCodret, vNumCte, vNumSolicitud, vTrama;
			END IF;
		END IF;
	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - José Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripción:	Se clona sp_consulsolicporenviar.sql para adaptarlo a la trama de Club de Protección',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_consultaorigenpoliza_club
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pTipoCte INTEGER
)
RETURNING CHAR(6) AS CodRet,
		  CHAR(1) AS OrigenPoliza;

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE cOrigenPol CHAR(1);
DEFINE sExiste SMALLINT;
DEFINE cCteBanco CHAR(20);

LET cCodRet = '000000';
LET iSql_err = 0;
LET cOrigenPol = '';
LET sExiste = 0;
LET cCteBanco = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet, cOrigenPol;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_consultaorigenpoliza_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pTipoCte,0) <> 0  THEN
		IF pTipoCte = 2 THEN
			SELECT  numcte_banco
			INTO cCteBanco
			FROM "informix".si_relacion_ctebcplcpl 
			WHERE empresa = pEmpresa
			AND cliente = pNumCte;
			
			IF NVL(cCteBanco,'') = '' THEN
				LET cOrigenPol = 'N';
			END IF;
		ELSE
			LET cCteBanco = pNumCte;
		END IF;
		IF pTipoCte = 1 OR cOrigenPol <> 'N' THEN
			SELECT  COUNT(numcte)
			INTO sExiste
			FROM "informix".si_club_proteccion
			WHERE empresa = pEmpresa
			AND numcte = cCteBanco
			AND aceptada = '1';
			IF sExiste > 0 THEN
				LET cOrigenPol = 'S';
			ELSE
				LET cOrigenPol = 'N';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '000001'; 
	END IF;	
	RETURN cCodRet, cOrigenPol;
END;
END PROCEDURE
DOCUMENT
"Folio:1606",
"Proyecto: ClubDeProteccion",
"Autor:95572503 Obed Vega",
"Fecha:02/Jul/2014",
"Descripción: Se crea SP para validar si una póliza del Club de Proteccion nació en BanCoppel",
"Sustento: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_consultaplan_club
(
   pEmpresa CHAR(3),
   pTipoPlan CHAR(1)   
)
RETURNING CHAR(6) AS CodRet,
		  CHAR(1) as TipoPlan,
		  CHAR(40) as Descripcion,
		  MONEY(14,2) as Monto;

DEFINE	cCodRet CHAR(6);
DEFINE	iSql_err INTEGER;
DEFINE	cTipoPlan CHAR(1);
DEFINE	cDes CHAR(40);
DEFINE	mMonto MONEY(14,2);

LET cCodRet = '000000';
LET iSql_err = 0;
LET cTipoPlan = '';
LET cDes = '';
LET mMonto = 0.0;


BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet,cTipoPlan,cDes,mMonto;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_consultaplan_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pTipoPlan,'') <> ''  THEN
		SELECT tipoplan,descripcion,monto
		INTO cTipoPlan,cDes,mMonto
		FROM "informix".si_club_planes
		WHERE empresa = pEmpresa
		AND tipoplan = pTipoPlan;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			RETURN cCodRet,NVL(cTipoPlan,''),NVL(cDes,''),NVL(mMonto,0.0);
		END IF
	ELSE
		LET cCodRet = '000001'; 
	END IF;	
	RETURN cCodRet,cTipoPlan,cDes,mMonto;
END;
END PROCEDURE
DOCUMENT
"Folio:1606",
"Proyecto: ClubDeProteccion",
"Autor:95572503 Obed Vega",
"Fecha:15/Jul/2014",
"Descripción: Se crea SP para retornar la informacion de un plan en específico",
"Sustento: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf",
"Solicita: Rodolfo Gómez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_guardacteprospecto_club
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplTitular		CHAR(20),
	pCteCplProspecto	CHAR(20)
)

RETURNING
	CHAR(06) AS cCodRet

	--VARIABLES
	DEFINE vcCodRet		CHAR(06);
	DEFINE vcCteBanCpl	CHAR(20);
	DEFINE iSql_err		INTEGER;

	--INICIALIZACIÓN
	LET vcCodRet	= '000000';
	LET vcCteBanCpl	= '';
	LET iSql_err 	= 0;

	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_guardacteprospecto_club_out.sql';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARÁMETROS VACÍOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '000001';
			RETURN vcCodRet;
		END IF;
		
		--BÚSQUEDA DE DATOS
		SELECT ctebancpl
		INTO vcCteBanCpl
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESÓ DATOS
		IF DBINFO("sqlca.sqlerrd2") = 1 THEN
			LET vcCodRet = '000002';
			RETURN vcCodRet;
		ELSE
			INSERT INTO "informix".si_club_hiscteprospecto(empresa, ctebancpl, ctecpltitular, ctecplprospecto)
			VALUES (pEmpresa, pCteBanCpl, pCteCplTitular, pCteCplProspecto);
			
			RETURN vcCodRet;
		END IF;
	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - José Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripción:	Guarda la relación del cliente bancoppel con el clinente Coppel titular y prospecto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_inserta_respuesta_club
(
	pEmpresa 			CHAR(03),
	pSucursal 			CHAR(04),
	pNumCteBancoppel	CHAR(20),
	pNumCteCoppel		CHAR(20),
	pRespuesta			CHAR(01)
)

RETURNING
	CHAR(06) AS cCodRet;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet = '000000';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_inserta_respuesta_club.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	LET pEmpresa  			= TRIM(pEmpresa);
	LET pSucursal 			= TRIM(pSucursal);
	LET pNumCteBancoppel 	= TRIM(pNumCteBancoppel);
	LET pNumCteCoppel 		= TRIM(pNumCteCoppel);
	LET pRespuesta 			= TRIM(pRespuesta);
	
	IF NVL(pEmpresa, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pNumCteBancoppel, '') = '' OR NVL(pNumCteCoppel, '') = '' OR NVL(pRespuesta, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet;
	END IF;
	
	INSERT INTO "informix".si_club_bitacora(empresa, sucursal, numcte, numcte_coppel, respuesta, fecha)
	VALUES(pEmpresa, pSucursal, pNumCteBancoppel, pNumCteCoppel, pRespuesta, CURRENT);
	RETURN cCodRet;

END;
END PROCEDURE

DOCUMENT
'Inserta la respuesta en la tabla si_club_bitacora cuando el cliente contesta el cuestionario de salud cuando se le ofrece el Club de Protección coppel',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-02',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_obtienecteprospecto_club
(
	pEmpresa 	CHAR(03),
	pCteBanCpl	CHAR(20)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(20) AS cCteCplTitular,
	CHAR(20) AS cCteCplProspecto

--VARIABLES
DEFINE vcCodRet				CHAR(06);
DEFINE vcCteCplTitular		CHAR(15);
DEFINE vcCteCplProspecto	CHAR(15);
DEFINE iSql_err				INTEGER;

--INICIALIZACIÓN DE VARIABLES
LET vcCodRet			= '000000';
LET vcCteCplProspecto	= '';
LET vcCteCplTitular		= '';
LET iSql_err			= 0;

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_obtienecteprospecto_club_out.sql';
--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet, vcCteCplTitular, vcCteCplProspecto;
			END IF;
	END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARÁMETROS VACÍOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' THEN
			LET vcCodRet = '000001';
			RETURN vcCodRet, vcCteCplTitular, vcCteCplProspecto;
		END IF;
		
		--BÚSQUEDA DE DATOS
		SELECT ctecpltitular, ctecplprospecto
		INTO vcCteCplTitular, vcCteCplProspecto
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESÓ DATOS
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET vcCodRet = '000002';
			LET vcCteCplProspecto = '';
			LET vcCteCplTitular = '';
		END IF;
		RETURN vcCodRet, vcCteCplTitular, vcCteCplProspecto;
	END;
END PROCEDURE

DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - José Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripción:	Retorna el número de cliente titular y prospecto Coppel de un cliente relacionado BanCoppel',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_parentesco_club
(
	pEmpresa CHAR(03)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(01) AS cParentesco,
	CHAR(30) AS cDescripcion;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);
DEFINE cParentesco	CHAR(01);
DEFINE cDescripcion CHAR(30);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet			= '000000';
LET cParentesco		= '';
LEt cDescripcion	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_error_trama_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cParentesco, cDescripcion;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	LET pEmpresa = TRIM(pEmpresa);
	
	IF NVL(pEmpresa, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet, cParentesco, cDescripcion;
	END IF;
	
	FOREACH
		SELECT parentesco, descripcion
		INTO cParentesco, cDescripcion
		FROM "informix".si_club_parentesco
		WHERE empresa = pEmpresa
		RETURN cCodRet, cParentesco, cDescripcion WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		RETURN cCodRet, cParentesco, cDescripcion;
	END IF

END;
END PROCEDURE

DOCUMENT
'Retorna el catálogo de parentescos en la definición de los',
'beneficiarios de la póliza del club de protección.',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-06',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_relaciona_ctebancplcpl_club(pEmpresa CHAR(3), pCteBanCoppel CHAR(20), pCteCoppel CHAR(20), pCteCoppelNvo CHAR(20), pTipoCteCpl CHAR(1),pOpcion CHAR(1))
RETURNING CHAR(6) AS Codigo_retorno;

--DEFINICION DE VARIABLES
DEFINE cCodret			 CHAR(6);
DEFINE iSqlErr INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_relaciona_ctebancplcpl_club.out';
    --TRACE ON;
	
	BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
	
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCteBanCoppel,'')) ='' OR TRIM(NVL(pCteCoppel,''))='' OR TRIM(NVL(pTipoCteCpl,''))='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN --Se actualiza la bandera del tipo de cliente coppel desde el soltarc y apertc
				
				SELECT numcte_banco
				INTO pCteBanCoppel
				FROM "informix".si_relacion_ctebcplcpl
				WHERE numcte_banco = TRIM(NVL(pCteBanCoppel,''))
				AND cliente = TRIM(NVL(pCteCoppel,''))
				AND empresa= TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '000002'; --Relación  CteBancoppel - CteCoppel no encontrado
				ELSE
					UPDATE "informix".si_relacion_ctebcplcpl
					SET cliente_prosp = pTipoCteCpl
					WHERE numcte_banco = pCteBanCoppel
					AND cliente = TRIM(NVL(pCteCoppel,''))
					AND empresa= TRIM(NVL(pEmpresa,''));
				END IF
			ELIF TRIM(NVL(pOpcion,''))='2' THEN  --Se actualiza la bandera y guarda el numero de cliente coppel prospecto desde el Alta del Club
				IF TRIM(NVL(pCteCoppelNvo,''))='' THEN
					LET cCodret = '000001'; --Parámetros de entrada vacíos
				ELSE	
					SELECT numcte_banco
					INTO pCteBanCoppel
					FROM "informix".si_relacion_ctebcplcpl
					WHERE numcte_banco = TRIM(NVL(pCteBanCoppel,''))
					AND empresa= TRIM(NVL(pEmpresa,''));
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '000002'; --Cliente Bancoppel no encontrado
					ELSE
						UPDATE "informix".si_relacion_ctebcplcpl
						SET cliente=pCteCoppelNvo, cliente_prosp = pTipoCteCpl
						WHERE numcte_banco = TRIM(NVL(pCteBanCoppel,''))
						AND empresa= TRIM(NVL(pEmpresa,''));
					END IF
				END IF
			END IF
		END IF
		RETURN cCodret;
	END
END PROCEDURE
DOCUMENT
"Descripción: Actualiza el tipo de cliente coppel relacionado (titular o prospecto)", 
"también cambia la clave del cliente prospecto por la clave de cliente titular coppel",
"Autor : Leslie Rendón",
"FECHA : 02/07/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_servicio_club
(
	pEmpresa 	CHAR(03),
	pCodServAu	CHAR(05)
)

RETURNING
	CHAR(06) AS cCodRet,
	CHAR(40) AS cEncabezado,
	CHAR(30) AS cProducto;

--DECLARACIÓN DE VARIABLES
DEFINE iSql_err			INTEGER;
DEFINE cCodRet			CHAR(06);
DEFINE cEncabezado		CHAR(40);
DEFINE cProducto 		CHAR(40);

DEFINE vccod_tipserv	CHAR(02);
DEFINE vcnombre_serv	CHAR(40);
DEFINE vcactivo			CHAR(01);
DEFINe vcdescripcion	CHAR(40);
DEFINe vcactivoTipo		CHAR(01);

--INICIALIZACIÓN DE VARIABLES
LET cCodRet			= '000000';
LET cEncabezado		= '';
LEt cProducto		= '';

LET vccod_tipserv	= '';
LET vcnombre_serv	= '';
LET vcactivo		= '';
LET vcdescripcion	= '';
LET vcactivoTipo	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_servicio_club.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cEncabezado, cProducto;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	LET pEmpresa 	= TRIM(pEmpresa);
	LET cEncabezado = TRIM(cEncabezado);
	LET cProducto 	= TRIM(cProducto);
		
	--VALIDAR PARÁMETROS VACÍOS Y NULOS
	IF NVL(pEmpresa, '') = '' OR NVL(pCodServAu, '') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet, cEncabezado, cProducto;
	END IF;
	
	--BÚSQUEDA DE DATOS
	SELECT cod_tipserv, nombre_serv_au, activo
	INTO vccod_tipserv, vcnombre_serv, vcactivo
	FROM "informix".si_servicios_au
	WHERE empresa = pEmpresa AND cod_serv_au = pCodServAu;
	
	--SI NO REGRESÓ DATOS
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000003';
		RETURN cCodRet, cEncabezado, cProducto;
	END IF
	
	--SI REGRESÓ DATOS Y EL CAMPO ES DIFERENTE A 1
	LET vcactivo = NVL(TRIM(vcactivo), '');
	IF vcactivo = 1 THEN
		SELECT descripcion, activo
		INTO vcdescripcion, vcactivoTipo
		FROM "informix".si_tipo_servicios_au
		WHERE empresa = pEmpresa AND cod_tipserv = vccod_tipserv;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			RETURN cCodRet, cEncabezado, cProducto;
		ELSE
			IF vcactivoTipo = 1 THEN
				LET cProducto	= vcnombre_serv;
				LET cEncabezado = vcdescripcion;
			ELSE
				LET cCodRet = '000004';
				RETURN cCodRet, cEncabezado, cProducto;
			END IF
		END IF
	ELSE
		LET cCodRet = '000004';
		RETURN cCodRet, cEncabezado, cProducto;
	END IF
	RETURN cCodRet, cEncabezado, cProducto;
	
END;
END PROCEDURE

DOCUMENT
'Retorna la descripción para el encabezado y descripción del producto del club de protección.',
'AUTOR : 95579737 - José Ernesto Raygoza Villa',
'FECHA : --/--/2014-04',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_confirmaimportarcofetel()
RETURNING CHAR(5)

------------------------------------------------------------
-- REALIZO: Mohamed Carreón
-- FECHA:      2009-02-14
--FUNCION: Carga el archivo de la COFETEL a
--                    la tabla  si_cattelefonos
-------------------------------------------------------------

--Definición de variables
DEFINE cCodret CHAR(5) ;
DEFINE iSqlErr INTEGER ;
DEFINE cSql CHAR(200);

--Inicializaciòn de variables
LET cCodret ='000';
LET iSqlErr = 0;
LET cSql = '';

--	SET DEBUG FILE TO "/tmp/has/sp_ConfirmaImportarCofetel.out";
--	TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr
    IF iSqlErr <> 0 THEN
        LET cCodret = iSqlErr;
        RETURN cCodret;
    END IF;
END EXCEPTION;

    DELETE FROM bdinteg:si_cattelefono;

	INSERT INTO bdinteg: si_cattelefono(clavecensal, poblacion, municipio, estado, presuscripcion, region, asl, nir, serie, numeracion_inicial, numeracion_final, ocupacion, tipored, modalidad, razonsocial, fecha_asignacion, fecha_consolidacion, fecha_migracion, nir_anterior)
	SELECT clavecensal, poblacion, municipio, estado, presuscripcion, region, asl, nir, serie, numeracion_inicial, numeracion_final, ocupacion, tipored, modalidad, razonsocial, fecha_asignacion, fecha_consolidacion, fecha_migracion, nir_anterior  
	FROM bdinteg: tmp_si_cattelefono;

RETURN cCodret;

END;
END PROCEDURE;
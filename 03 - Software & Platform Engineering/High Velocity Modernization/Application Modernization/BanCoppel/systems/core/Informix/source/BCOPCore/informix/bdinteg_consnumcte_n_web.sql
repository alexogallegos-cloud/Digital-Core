CREATE PROCEDURE "informix".consnumcte_n_web(pEmpresa CHAR(3),
											 pNumcte char(20))

--DATOS A REGRESAR---
	RETURNING CHAR(5)   AS Retorno,
			  CHAR(20)  AS NumeroCliente,
			  CHAR(20)  AS NumeroClienteRef,
			  CHAR(1)	AS TipoCliente,
			  CHAR(26)  AS Nombre1,
			  CHAR(26)  AS Nombre2,
			  CHAR(26)  AS ApellidoPat,
			  CHAR(26)  AS ApellidoMat,
			  DATE      AS FechaNac,
			  CHAR(13)  AS RFC,
			  CHAR(20)  AS Curp,
			  CHAR(1)	AS Sexo,
			  CHAR(2)	AS EdoCivil,
			  CHAR(3)	AS Nacionalidad,
			  CHAR(2)	AS LugarNacimiento,
			  CHAR(18)  AS No_fm3,
			  CHAR(2)	AS Escolaridad,
			  CHAR(2)	AS HabitaEn,
			  CHAR(2)	AS CodIdentificacion,
			  CHAR(20)	AS NumIdentificacion,
			  CHAR(60)	AS String2, 
			  CHAR(60)	AS Email,
			  CHAR(2)	AS UserInsert,
			  DATE      AS FechaInsert,
			  CHAR(3)	AS IdentPaisNac,
			  INTEGER	AS PuestoEspecial,
			  INTEGER	AS Puesto,
			  CHAR(2)	AS Estado,
			  SMALLINT  AS NumeroCiudad,
			  CHAR(5)   AS Delegacion,
			  INTEGER	AS Colonia,
			  INTEGER	AS Calle,
			  CHAR(10)  AS NumeroExterior,
			  CHAR(10)  AS NumeroInterior,
			  CHAR(6)   AS Departamento,
			  CHAR(5)   AS CP,
			  CHAR(1)   AS PuntoCardinal,
			  SMALLINT  AS Manzana,
			  SMALLINT  AS Otros,
			  SMALLINT  AS Andador,
			  SMALLINT  AS Etapa,
			  SMALLINT  AS Edificio,
			  SMALLINT  AS Entrada,
			  SMALLINT  AS Lote,
			  CHAR(80)  AS Observaciones,
			  CHAR(40)  AS EntreCalles,
			  CHAR(13)  AS TelCasa,
			  CHAR(13)  AS TelCelular,
			  SMALLINT  AS Carrier,
			  CHAR(3)   AS Ciudad,
			  CHAR(1)   AS UnidadHabitacional;
			

-- DEFINICION DE VARIABLES
	DEFINE iSqlErr			    INTEGER;
	 -- si_cliente
    DEFINE vcodret 				CHAR(5);
    DEFINE vempresa 			CHAR(3);
    DEFINE vnumcte 				CHAR(20);
    DEFINE vstatus_cte 			CHAR(2);
    DEFINE vsucursal 			CHAR(4);
    DEFINE vejecutivo 			CHAR(8);
    DEFINE vtpo_persona 		CHAR(2);
    DEFINE vtipo_cliente 		CHAR(1);
    DEFINE vapell_paterno 		CHAR(26);
    DEFINE vapell_materno 		CHAR(26);
    DEFINE vnombre1 			CHAR(26);
    DEFINE vnombre2 			CHAR(26);
    DEFINE vrazon_social 		CHAR(60);
    DEFINE vrfc 				CHAR(13);
    DEFINE vsector 				CHAR(2);
    DEFINE vsegmento 			CHAR(3);
    DEFINE vactividad_princ 	CHAR(3);
    DEFINE vgrupo 				CHAR(3);
    DEFINE vsubgrupo 			CHAR(3);
    DEFINE vresidencia 			CHAR(1);
    DEFINE vfecha_alta 			DATE ;
    DEFINE vapell_casada 		CHAR(26);
    DEFINE vdistrito 			CHAR(2);
    DEFINE vnumcte_ref 			CHAR(20);
    DEFINE vstring1 			CHAR(20);
    DEFINE vstring2 			CHAR(60);
    DEFINE vnumeric1 			SMALLINT ;
    DEFINE vnumeric2 			INTEGER ;
    DEFINE vmoney1 				MONEY(14,2);
    DEFINE vdate1 				DATE ;
    DEFINE vpuesto_ppes 		CHAR(1);
    DEFINE vfamiliar_ppes 		CHAR(1);
    DEFINE vactividad_esp 		CHAR(11);
    DEFINE vejecut_autoriza 	CHAR(8);
    DEFINE vuser_insert 		CHAR(8);
    DEFINE vfecha_insert 		DATE;
    DEFINE vrfc_alterno 		CHAR(13);
	DEFINE vid_pais 			CHAR(03);
    -- si_ctepf
    DEFINE vpfempresa 			CHAR(3);
    DEFINE vpfnumcte 			CHAR(20);
    DEFINE vpffecha_nac 		DATE;
    DEFINE vpflugar_nac 		CHAR(2);
    DEFINE vpfnacionalidad 		CHAR(3);
    DEFINE vpfno_fm3 			CHAR(18);
    DEFINE vpfestado_civil 		CHAR(2);
    DEFINE vpfregim_matrimonio 	CHAR(1);
    DEFINE vpfprofesion 		CHAR(3);
    DEFINE vpfsexo 				CHAR(1);
    DEFINE vpfcurp 				CHAR(20);
    DEFINE vpfcodidentifi 		CHAR(2);
    DEFINE vpfnumidentifi 		CHAR(20);
    DEFINE vpfno_imss 			CHAR(12);
    DEFINE vpfdependientes 		SMALLINT ;
    DEFINE vpftutor 			CHAR(60);
    DEFINE vpfemail 			CHAR(60);
    DEFINE vpfpfnom_conyuge 	CHAR(60);
    DEFINE vpfseguro_defunc 	CHAR(1);
    DEFINE vpfescolaridad 		CHAR(2);
    DEFINE vpfhabita_en 		CHAR(2);
    DEFINE vpfanios_habita 		SMALLINT ;
    DEFINE vpfnombre_prop 		CHAR(60);
    DEFINE vpfimp_hipo_renta 	MONEY(16,2);
    DEFINE vpfactividadogiro 	CHAR(30);
    DEFINE vpfnumeroife 		CHAR(20);
    DEFINE vpfnumerotutor 		CHAR(20);
    DEFINE vpfnumeroconyuge 	CHAR(20);
    DEFINE vpfstring1 			CHAR(20);
    DEFINE vpfstring2 			CHAR(20);
    DEFINE vpfnumeric1 			INTEGER ;
    DEFINE vpfnumeric2 			INTEGER ;
    DEFINE vpfmoney1 			MONEY(14,2);
    DEFINE vpfdate1 			DATE;
    DEFINE vpfuser_insert 		CHAR(8);
    DEFINE vpffecha_insert 		DATE;
	DEFINE vpid_pais 			CHAR(03);
	-- sp_consbco_dirtel
	DEFINE vcCodRet         	CHAR(5);
	DEFINE vcNumPros        	CHAR(20);
    DEFINE vcEstado         	CHAR(2);
    DEFINE viCiudad         	SMALLINT;
    DEFINE vcMunicipio      	CHAR(5);
    DEFINE viColonia        	INTEGER;
    DEFINE viCalle          	INTEGER;
    DEFINE vcNumExt         	CHAR(10);
    DEFINE vcNumInt         	CHAR(10);
    DEFINE vcDepto          	CHAR(6);
    DEFINE vcCodPos         	CHAR(5);
    DEFINE vcPuntoCard      	CHAR(1);
    DEFINE viManzana        	SMALLINT;
    DEFINE viOtros          	SMALLINT;
    DEFINE viAndador        	SMALLINT;
    DEFINE viEtapa          	SMALLINT;
    DEFINE viEdificio       	SMALLINT;
    DEFINE viEntrada        	SMALLINT;
    DEFINE viLote           	SMALLINT;
    DEFINE vcObservaciones  	CHAR(80);
    DEFINE vcEntreCalles    	CHAR(40);
    DEFINE vcTelCasa        	CHAR(13);
    DEFINE vcTelCelular     	CHAR(13);
    DEFINE viCarrier        	SMALLINT;
    DEFINE vcTelTrabajo     	CHAR(13);
    DEFINE vcExtTrabajo     	CHAR(5);
    DEFINE vcCiudad         	CHAR(3);
    DEFINE vcUnidadHab      	CHAR(1);
	--sp_ConsultaIngresosCliente
	DEFINE cCodRet 				CHAR(5);
	DEFINE cEmpres 				CHAR(3);
	DEFINE cNumCte 				CHAR(20);
	DEFINE sSecIng 				SMALLINT;
	DEFINE cTipIng 				CHAR(1);
	DEFINE cNomEmp 				CHAR(60);
	DEFINE cPuesto 				CHAR(3);
	DEFINE cPutEsp 				CHAR(2);
	DEFINE dAntigd 				DECIMAL(4,2);
	DEFINE cNomDep 				CHAR(40);
	DEFINE cJefInm 				CHAR(60);
	DEFINE mIngMen 				MONEY(14,2);
	DEFINE cUsrInt 				CHAR(8);
	DEFINE dFecInt 				DATE;
	DEFINE iCvePst 				INTEGER;
	DEFINE iCveOPt 				INTEGER;
	DEFINE iCveSOP 				INTEGER;
	DEFINE iSisCot 				INTEGER;
	DEFINE iNumELa 				INTEGER;
	DEFINE iPerios 				INTEGER;
	DEFINE iTipIEx 				INTEGER;

		
	
--INICIALIZACION DE VARIABLES
	LET vcodret 				= "00000";
	LET iSqlErr	        		= 0;
	 -- si_cliente
    LET vempresa  				= "";
    LET vnumcte  				= "";
    LET vstatus_cte  			= "";
    LET vsucursal 				= "";
    LET vejecutivo 				= "";
    LET vtpo_persona 			= "";
    LET vtipo_cliente 			= "";
    LET vapell_paterno 			= "";
    LET vapell_materno 			= "";
    LET vnombre1 				= "";
    LET vnombre2 				= "";
    LET vrazon_social 			= "";
    LET vrfc 					= "";
    LET vsector 				= "";
    LET vsegmento 				= "";
    LET vactividad_princ 		= "";
    LET vgrupo 					= "";
    LET vsubgrupo 				= "";
    LET vresidencia 			= "";
    LET vfecha_alta 			= "";
    LET vapell_casada  			= "";
    LET vdistrito 				= "";
    LET vnumcte_ref 			= "";
    LET vstring1 				= "";
    LET vstring2  				= "";
    LET vnumeric1  				= 0;
    LET vnumeric2  				= 0;
    LET vmoney1 				= 0;
    LET vdate1  				= "";
    LET vpuesto_ppes 			= "";
    LET vfamiliar_ppes 			= "";
    LET vactividad_esp 			= "";
    LET vejecut_autoriza  		= "";
    LET vuser_insert 			= "";
    LET vfecha_insert 			= "";
    LET vrfc_alterno 			= "";
	LET vid_pais 				= '';	
    -- si_ctepf
    LET vpfempresa  			= "";
    LET vpfnumcte  				= "";
    LET vpffecha_nac  			= "";
    LET vpflugar_nac  			= "";
    LET vpfnacionalidad  		= "";
    LET vpfno_fm3  				= "";
    LET vpfestado_civil 		= "";
    LET vpfregim_matrimonio 	= "";
    LET vpfprofesion  			= "";
    LET vpfsexo 				= "";
    LET vpfcurp  				= "";
    LET vpfcodidentifi 			= "";
    LET vpfnumidentifi  		= "";
    LET vpfno_imss  			= "";
    LET vpfdependientes 		= 0;
    LET vpftutor  				= "";
    LET vpfemail  				= "";
    LET vpfpfnom_conyuge  		= "";
    LET vpfseguro_defunc 		= "";
    LET vpfescolaridad 			= "";
    LET vpfhabita_en 			= "";
    LET vpfanios_habita  		= 0;
    LET vpfnombre_prop 			= "";
    LET vpfimp_hipo_renta  		= 0;
    LET vpfactividadogiro 		= "";
    LET vpfnumeroife 			= "";
    LET vpfnumerotutor 			= "";
    LET vpfnumeroconyuge 		= "";
    LET vpfstring1 				= "";
    LET vpfstring2 				= "";
    LET vpfnumeric1 			= 0;
    LET vpfnumeric2 			= 0;
    LET vpfmoney1 				= 0;
    LET vpfdate1 				= "";
    LET vpfuser_insert 			= "";
    LET vpffecha_insert 		= "";
	LET vpid_pais 				= '';	
	--sp_consbco_dirtel
	LET vcNumPros       		= '';
    LET vcEstado        		= ''; 
    LET viCiudad        		= 0; 
    LET vcMunicipio     		= ''; 
    LET viColonia       		= 0; 
    LET viCalle         		= 0; 
    LET vcNumExt        		= ''; 
    LET vcNumInt        		= ''; 
    LET vcDepto         		= ''; 
    LET vcCodPos        		= ''; 
    LET vcPuntoCard     		= ''; 
    LET viManzana       		= 0;  
    LET viOtros         		= 0;  
    LET viAndador       		= 0;  
    LET viEtapa         		= 0;  
    LET viEdificio      		= 0;  
    LET viEntrada       		= 0;  
    LET viLote          		= 0;  
    LET vcObservaciones 		= '';
    LET vcEntreCalles   		= ''; 
    LET vcTelCasa       		= ''; 
    LET vcTelCelular    		= ''; 
    LET viCarrier       		= 0;  
    LET vcTelTrabajo    		= '';
    LET vcExtTrabajo    		= '';
    LET vcCiudad        		= '';
    LET vcUnidadHab     		= '';
	--sp_ConsultaIngresosCliente
	LET cCodRet 				= '00000';
	LET cEmpres 				= '';
	LET cNumCte 				= '';
	LET sSecIng 				= 0;
	LET cTipIng 				= '';
	LET cNomEmp 				= '';
	LET cPuesto 				= '';
	LET cPutEsp 				= '';
	LET dAntigd 				= 0;
	LET cNomDep 				= '';
	LET cJefInm 				= '';
	LET mIngMen 				= 0;
	LET cUsrInt 				= '';
	LET dFecInt 				= DATE(1);
	LET iCvePst 				= 0;
	LET iCveOPt 				= 0;
	LET iCveSOP 				= 0;
	LET iSisCot 				= 0;
	LET iNumELa 				= 0;
	LET iPerios 				= 0;
	LET iTipIEx 				= 0;
	
	--SET DEBUG FILE TO '/informix/consnumcte_n_web.out';
	--TRACE ON;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION; 
		
	Call bdinteg:"informix".consnumcte_n_v1(pEmpresa,pNumcte)
	 RETURNING 	vcodret,vempresa, vnumcte, vstatus_cte, vsucursal, vejecutivo, vtpo_persona, vtipo_cliente, vapell_paterno, vapell_materno, vnombre1, vnombre2,
                vrazon_social, vrfc, vsector, vsegmento, vactividad_princ, vgrupo, vsubgrupo, vresidencia, vfecha_alta, vapell_casada, vdistrito, vnumcte_ref,
                vstring1, vstring2, vnumeric1, vnumeric2, vmoney1, vdate1, vpuesto_ppes, vfamiliar_ppes, vactividad_esp, vejecut_autoriza, vuser_insert, 
                vfecha_insert, vrfc_alterno, vid_pais,		--DSB230162JERV1694 vid_pais,
                vpfempresa, vpfnumcte, vpffecha_nac, vpflugar_nac, vpfnacionalidad, vpfno_fm3, vpfestado_civil, vpfregim_matrimonio, vpfprofesion, vpfsexo, 
                vpfcurp, vpfcodidentifi, vpfnumidentifi, vpfno_imss, vpfdependientes, vpftutor, vpfemail, vpfpfnom_conyuge, vpfseguro_defunc, vpfescolaridad,
                vpfhabita_en, vpfanios_habita, vpfnombre_prop, vpfimp_hipo_renta, vpfactividadogiro, vpfnumeroife, vpfnumerotutor, vpfnumeroconyuge, 
                vpfstring1, vpfstring2, vpfnumeric1, vpfnumeric2, vpfmoney1, vpfdate1, vpfuser_insert, vpffecha_insert, vpid_pais;	
				
                IF vcodret = "00001" THEN
                LET vcodret = cCodRet;
							LET vnumcte = '';
							LET vnumcte_ref = '';
							LET vtipo_cliente = '';
							LET vnombre1 = '';
							LET vnombre2 = '';
							LET vapell_paterno = '';
							LET vapell_materno = '';
							LET vpffecha_nac = '';
							LET vrfc = '';
							LET vpfcurp = '';
							LET vpfsexo = '';
							LET vpfestado_civil = '';
							LET vpfnacionalidad = '';
							LET vpflugar_nac = '';
							LET vpfno_fm3 = '';
							LET vpfescolaridad = '';
							LET vpfhabita_en = '';
							LET vpfcodidentifi = '';
							LET vpfnumidentifi = '';
							LET vstring2 = '';
							LET vpfemail = '';
							LET vpfuser_insert = '';
							LET vpffecha_insert = '';
							LET vpid_pais = '';
					RETURN vcodret,vnumcte,vnumcte_ref,vtipo_cliente,vnombre1,vnombre2,vapell_paterno,vapell_materno,vpffecha_nac,vrfc,vpfcurp,vpfsexo,vpfestado_civil,vpfnacionalidad,vpflugar_nac,vpfno_fm3,vpfescolaridad,vpfhabita_en,vpfcodidentifi,vpfnumidentifi,vstring2, vpfemail,vpfuser_insert,vpffecha_insert,vpid_pais,iCveSOP,iCveOPt,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab;  			
			END IF;

				IF vcodret = "00000" THEN
				 Call bdinteg:"informix".sp_ConsultaIngresosCliente(2, pNumCte, 'T')
					RETURNING cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
					iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
					
                    Call bdinteg:"informix".sp_consbco_dirtel( pEmpresa, pNumCte, 1)
							RETURNING vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
									  viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
								ELIF cCodRet = "00001" THEN
										Call bdinteg:"informix".sp_consbco_dirtel( pEmpresa, pNumCte, 1)
											RETURNING vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
													  viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
														  LET iCveOPt = '';
														  LET iCveSOP = ''; 
							ELSE
						/* 	LET vcodret = cCodRet;
							LET vnumcte = '';
							LET vnumcte_ref = '';
							LET vtipo_cliente = '';
							LET vnombre1 = '';
							LET vnombre2 = '';
							LET vapell_paterno = '';
							LET vapell_materno = '';
							LET vpffecha_nac = '';
							LET vrfc = '';
							LET vpfcurp = '';
							LET vpfsexo = '';
							LET vpfestado_civil = '';
							LET vpfnacionalidad = '';
							LET vpflugar_nac = '';
							LET vpfno_fm3 = '';
							LET vpfescolaridad = '';
							LET vpfhabita_en = '';
							LET vpfcodidentifi = '';
							LET vpfnumidentifi = '';
							LET vstring2 = '';
							LET vpfemail = '';
							LET vpfuser_insert = '';
							LET vpffecha_insert = '';
							LET vpid_pais = '';
							 RETURN vcodret,vnumcte,vnumcte_ref,vtipo_cliente,vnombre1,vnombre2,vapell_paterno,vapell_materno,vpffecha_nac,vrfc,vpfcurp,vpfsexo,vpfestado_civil,vpfnacionalidad,vpflugar_nac,vpfno_fm3,vpfescolaridad,vpfhabita_en,vpfcodidentifi,vpfnumidentifi,vstring2, vpfemail,vpfuser_insert,vpffecha_insert,vpid_pais,iCveSOP,iCveOPt,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab; */
					
                        return vcodret,vnumcte,vnumcte_ref,vtipo_cliente,vnombre1,vnombre2,vapell_paterno,vapell_materno,vpffecha_nac,vrfc,vpfcurp,vpfsexo,vpfestado_civil,vpfnacionalidad,vpflugar_nac,vpfno_fm3,vpfescolaridad,vpfhabita_en,vpfcodidentifi,vpfnumidentifi,vstring2, vpfemail,vpfuser_insert,vpffecha_insert,vpid_pais,iCveSOP,iCveOPt,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab;
                    END IF;		 
								
							 
					IF vcCodRet = "00000" THEN 
							 RETURN vcodret,vnumcte,vnumcte_ref,vtipo_cliente,vnombre1,vnombre2,vapell_paterno,vapell_materno,vpffecha_nac,vrfc,vpfcurp,vpfsexo,vpfestado_civil,vpfnacionalidad,vpflugar_nac,vpfno_fm3,vpfescolaridad,vpfhabita_en,vpfcodidentifi,vpfnumidentifi,vstring2, vpfemail,vpfuser_insert,vpffecha_insert,vpid_pais,iCveSOP,iCveOPt,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab; 
								ELIF cCodRet = "00111" THEN
									 return vcodret,vnumcte,vnumcte_ref,vtipo_cliente,vnombre1,vnombre2,vapell_paterno,vapell_materno,vpffecha_nac,vrfc,vpfcurp,vpfsexo,vpfestado_civil,vpfnacionalidad,vpflugar_nac,vpfno_fm3,vpfescolaridad,vpfhabita_en,vpfcodidentifi,vpfnumidentifi,vstring2, vpfemail,vpfuser_insert,vpffecha_insert,vpid_pais,iCveSOP,iCveOPt,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab;
                   
							ELSE
						/* 	LET vcodret = vcCodRet;
							RETURN vcodret,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''; */
							-- 26, 27
								 RETURN vcodret,vnumcte,vnumcte_ref,vtipo_cliente,vnombre1,vnombre2,vapell_paterno,vapell_materno,vpffecha_nac,vrfc,vpfcurp,vpfsexo,vpfestado_civil,vpfnacionalidad,vpflugar_nac,vpfno_fm3,vpfescolaridad,vpfhabita_en,vpfcodidentifi,vpfnumidentifi,vstring2, vpfemail,vpfuser_insert,vpffecha_insert,vpid_pais,iCveSOP,iCveOPt,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab;  			
							END IF;
                           
END;
END PROCEDURE           
DOCUMENT
"DESCRIPCION: ...",
"REALIZÃ: Jorge Lara",
"FECHA: 27/Abril/2017",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_actualiza_mensajes_cel_web( pNumCte CHAR(20), -- NO. CLIENTE
                                                       pSmsCel CHAR(1) ) -- INDICADOR SMS
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vcTipoMns        CHAR(1);
    DEFINE vcPlanMns        CHAR(10);
    DEFINE vcProcMns        CHAR(1);
    DEFINE vCodRetRegEven   CHAR(5);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte     = 0;
    LET vcTipoMns      = '';
    LET vcPlanMns      = '';
    LET vcProcMns      = '';
    LET vCodRetRegEven = '';
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_mensajes_cel.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualiza_mensajes_cel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) OR
       ( pSmsCel is null OR pSmsCel = '' ) THEN
        LET vcodret1 = '00110'; --- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_ctepf
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1;
    END IF;
    
    UPDATE si_ctepf
       SET sms_cel = pSmsCel
     WHERE numcte = pNumCte;
     
    IF ( ( dbinfo('sqlca.sqlerrd2') = 0 ) AND pSmsCel = 'S' ) THEN
        -- // OBTIENE PARAMETROS PARA MENSAJE DE LATINIA
        SELECT valor
          INTO vcTipoMns
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 85;
        
        SELECT valor
          INTO vcPlanMns
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 86;
           
        SELECT valor
          INTO vcProcMns
          FROM bdinteg:"informix".si_param
         WHERE cod_param = 87;
             
        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
        ( vcTipoMns, vcPlanMns, pNumCte, '', '', vcProcMns, '', CURRENT, '', '', '', '', '', '', '', '', '', '', 1, 0, 0, 0, 0, CURRENT, '' )
        INTO vCodRetRegEven;
    END IF;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;
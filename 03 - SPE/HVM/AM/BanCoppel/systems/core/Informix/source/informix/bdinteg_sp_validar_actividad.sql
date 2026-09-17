CREATE PROCEDURE "informix".sp_validar_actividad(ptrans char (3),pCliente CHAR(11), pTarjeta CHAR(16), pCuenta CHAR(12))
       RETURNING CHAR(5) as codret, char(1) as Validacion;

DEFINE iSqlErr		INTEGER;
DEFINE codret          CHAR(5);
DEFINE sErrProc		CHAR(5);
DEFINE Validacion char(1);
DEFINE iExists		      INTEGER;
DEFINE iExistsA		      INTEGER;
DEFINE iExistsB		      INTEGER;
DEFINE ExisteR            INTEGER;
define iRegistro          integer;
define iRegistroA          integer;
define iRegistroB         integer;
define iRegistroC         integer;
define ValidarTarjeta integer;
define BanderaCliente integer;


LET iSqlErr          =0;
LET codret          ='00000';
LET sErrProc         ='';
LET Validacion          = 0;
let ExisteR =             0;
LET iRegistro         = 0;
let iRegistroA  = 0;
let iRegistroB   = 0;
Let iRegistroC   = 0;
LET ValidarTarjeta = 0;
let BanderaCliente = 0;


BEGIN
	 ON EXCEPTION SET iSqlErr

	 IF iSqlErr <> 0 THEN
		RETURN iSqlErr, Validacion;
        END IF;

        END EXCEPTION;

--SET DEBUG FILE TO '/informix/FernandoGarcia/sp_validar_Actividad.sql';
--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		 


 select  count (*) into  iRegistro  From bdicheq:sc_maechq where cuenta = pCuenta;
select count(*) into iRegistroA From  bdicred:sd_maecred where num_credito= pCuenta;
	select count(*) into iRegistroB from bdicheq:sc_tarjeta where num_tarjeta = pTarjeta;	
	 select count(*) into iRegistroC from  bdicred:sd_tarjeta where  num_tarjeta = pTarjeta;
if  (pCliente <> '') then

     select count(*) into  BanderaCliente from bdinteg:si_cliente   where tpo_persona <> '01' and len(rfc) <> '13'  and numcte = pCliente;

   elif (pCuenta <> '') then

   
  	        if (ptrans = '204' or ptrans = '223') then
                select   count (*)  into BanderaCliente  from bdinteg:si_cliente   as cli
                left  join  bdicheq:sc_maechq as mae
                on  mae.num_cte = cli.numcte
                where tpo_persona <> '01' and len(rfc) <> '13'  and cuenta = pCuenta;

    
            end if;
           


   elif (pTarjeta <> '') then
              	if (ptrans = '204' or ptrans = '223') then
                   select  count (*)  into BanderaCliente  from bdinteg:si_cliente   as cli
                  left  join  bdicheq:sc_tarjeta  as mae
                    on  mae.numcte = cli.numcte
                   where     mae.num_tarjeta = pTarjeta  and
                 tpo_persona <> '01' and len(rfc) <> '13';
            	
                elif (ptrans = '600' or ptrans = '603') then --CREDITO

                select  count (*)  into BanderaCliente  from bdinteg:si_cliente   as cli
                left join bdicred:sd_tarjeta as maecred
                   on  maecred.numcte = cli.numcte
                    where     maecred.num_tarjeta = pTarjeta and
                 tpo_persona <> '01' and len(rfc) <> '13';
                end if;
end if;


	  if ( BanderaCliente > 0 ) then 	
         let Validacion = 1;
        RETURN codret, Validacion;
     end if;  
if (iRegistro > 0  or iRegistroA  > 0   or iRegistroB  > 0  or iRegistroC  > 0 ) then       
        --BUSCANDO POR NUMERO DE CLIENTE
		select  count(*) into iExists from bdinteg:si_ingresos where numcte = pCliente and claveopcionpuesto   is not null and numcte <> ''  and sec_ingreso = '1';
	    IF   (iExists > 0) THEN 
		 let Validacion = 1;
                  
		  end if;
		IF (iExists <= 0) THEN
			--buscando por Numero cuenta
			if (ptrans = '204' or ptrans = '223') then  --CAPTACION
			       
                      select count(*) into iExistsA from bdicheq:sc_maechq  as ma
                      inner join bdinteg:si_ingresos as ing on ma.num_cte = ing.numcte
                      where cuenta = pCuenta and ing.claveopcionpuesto   is not null; 
                
                     
			elif (ptrans = '600' or ptrans = '603') then --CREDITO
			     
			          select count(*) into iExistsA from bdicred:sd_maecred  as ma
                      inner join bdinteg:si_ingresos as ing on ma.numcte = ing.numcte
                      where num_credito= pCuenta and ing.claveopcionpuesto   is not null  and ing.sec_ingreso = '1';  
                  
			end if;   
			   IF (iExistsA > 0) then 
			     let  Validacion = 1;
			   
			   end if;
			IF (iExistsA <= 0) THEN
				--BUSCANDO POR NUMERO TARJETA
					if (ptrans = '204' or ptrans = '223') then   --CAPTACION

				    select count(*) into ValidarTarjeta from  bdicred:sd_tarjeta    where      num_tarjeta = pTarjeta;    
					    if ( ValidarTarjeta  = 0 ) then 
				            select count(*) into iExistsB from bdicheq:sc_tarjeta as starjeta
                            inner join bdinteg:si_ingresos as ing on starjeta.numcte = ing.numcte
				            where      num_tarjeta = pTarjeta and ing.claveopcionpuesto   is not null and ing.sec_ingreso = '1'; 
							else
							 let iExistsB = 1;
                                    
                                             end if;
						  
						  
				    elif  (ptrans = '600' or ptrans = '603') then --CREDITO

					       select count(*) into ValidarTarjeta from  bdicheq:sc_tarjeta    where      num_tarjeta = pTarjeta;    
					    if ( ValidarTarjeta  = 0 ) then 
					        select count(*) into iExistsB  from  bdicred:sd_tarjeta as sdtarjeta
                                                inner join bdinteg:si_ingresos as ing on sdtarjeta.numcte = ing.numcte
				                 where      num_tarjeta = pTarjeta and ing.claveopcionpuesto   is not null and ing.sec_ingreso = '1';
                                               
			          	else
							 let iExistsB = 1;
                                    
                              end if;                                               
			          
			        end if;  		
							
							
		      IF (iExistsB > 0) then 
			      let Validacion = 1;
			   
			   end if;
				   
			END IF;
		END IF;
ELSE
		  let Validacion = 1;
End IF;

		
        RETURN codret, Validacion;
end
END PROCEDURE
document
'Folio.........: RQM 11 175',
'Autor.........: 90261955 - Fernando Daniel Garcia Montes',
'Fecha.........: 13/02/2023',
'Modificación..: Se crea procedimiento para consultar si el cliente cuenta con actividad o subactividad ',
'Sustento......: RQM 11 175 Actualizacion del dato Actividad del cliente en sucursal',
'Solicita......:  PLD',
'BD............: bdinteg',
'*************************************************************************************************************************'

;

CREATE PROCEDURE "informix".sp_gen_usuario_ios_pentesting( pempresa CHAR(3) )
RETURNING CHAR(5) AS codret, CHAR(20) AS numcte, CHAR(20) AS NumCta;

	DEFINE cCodRet CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	
	DEFINE cNumCta CHAR(20);
	DEFINE cCtaClabe CHAR(18);
	DEFINE cCteNuevo CHAR(2);
	DEFINE cNombreCte CHAR(104);
	DEFINE cFechaNac CHAR(10);
	DEFINE cTelMovil CHAR(10);
	DEFINE vgenfolio CHAR(1);
	
	DEFINE pTp_persona CHAR(2);
	DEFINE pTp_cliente CHAR(1);
	DEFINE pPaterno CHAR(26);
	DEFINE pMaterno CHAR(26);
	DEFINE pNombre1 CHAR(26);
	DEFINE pNombre2 CHAR(26);
	DEFINE pRfc CHAR(13);
	DEFINE pNumcte_ref CHAR(20);
	DEFINE pFecha_nac DATE;
	DEFINE pLugar_nac CHAR(2);
	DEFINE pNacionalidad CHAR(3);
	DEFINE pEstado_civil CHAR(1);
	DEFINE pSexo CHAR(1);
	DEFINE pCurp CHAR(20);
	DEFINE pCodidentif CHAR(1);
	DEFINE pNumidentif CHAR(30);
	DEFINE pActividad SMALLINT;
	DEFINE pSubactividad SMALLINT;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cTelMovil = '';
	LET vgenfolio = 'F';
	
	LET cNumCta = '';
	LET cCtaClabe = '';
	LET cCteNuevo = '';
	LET cNombreCte = '';
	LET cFechaNac = '';
	
	LET pTp_persona = '01';
	LET pTp_cliente = '2';
	LET pPaterno = 'USER';
	LET pMaterno = 'BANCOPPEL';
	LET pNombre1 = 'IOS';
	LET pNombre2 = '';
	LET pRfc     = 'UEBI7101192C3';
	LET pNumcte_ref = '';
	LET pFecha_nac = '01-19-1971';
	LET pLugar_nac = '02';
	LET pNacionalidad = '001';
	LET pEstado_civil = 'S';
	LET pSexo = 'M';
	LET pCurp = 'UEBI710119HDFSNS04';
	LET pCodidentif = 'A';
	LET pNumidentif = '2454015358571';
	LET pActividad = 0;
	LET pSubactividad = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlerr <> 0 THEN
				--ROLLBACK WORK;
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet,cNumCte,cNumCta;
		END EXCEPTION;
    
		--SET DEBUG FILE TO '/ifxsif01/ireb/n2/sp_gen_usuario_ios_pentesting.out';
		--TRACE ON;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gen_usuario_huawei_pentesting.out';
		--TRACE ON;
    
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
    
	
		----PASO 1: GENERAR EL NÃMERO DE CLIENTE AL CLIENTE
		EXECUTE PROCEDURE "informix".sp_ctanvl2_gencte(pTp_persona,pTp_cliente,pPaterno,pMaterno,pNombre1,pNombre2,pRfc,pNumcte_ref,pFecha_nac,pLugar_nac,pNacionalidad,pEstado_civil,pSexo,
		pCurp,pCodidentif,pNumidentif,pActividad,pSubactividad)
		--EXECUTE PROCEDURE "informix".sp_ctanvl2_gencte('01','2','USER','BANCOPPEL','IOS','','UEBI7101192C3','','01-19-1971','02','001','S','F','UEBI710119MDFSNS08','A','2454015358571',0,0)
		INTO cCodRetSp, cNumCte;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		--EXECUTE PROCEDURE "informix".sp_ctanvl2_gencte('01','2','USER','BANCOPPEL','IOS','','UEBI7101192C3','','01-19-1971','02','001','S','F','UEBI710119MDFSNS08','A','2454015358571',0,0);
		--INTO cCodRet, cNumCte;
		
		IF iCodRetSp <> 0 THEN
			LET cCodRet = '111';
			--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencte';
			RETURN cCodRet,cNumCte,cNumCta;
		ELIF iCodRetSp = 0 THEN
			
			----PASO 2: DAR DE ALTA EL DOMICLIO DEL CLIENTE
			EXECUTE PROCEDURE sp_ctanvl2_regdomicilio(cNumCte,'C MIXCOAC Y COCOYOC 22 D','','00000','','02','028','21448','028','','','','001',134176,14,'N',0,0,0,0,'')
			INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			
			IF iCodRetSp <> 0 THEN
				LET cCodRet = '112';
				--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_regdomicilio';
				RETURN cCodRet,cNumCte,cNumCta;
			ELIF iCodRetSp = 0 THEN
				
				----PASO 3: DAR DE ALTA EL TELEFONO DEL CLIENTE
				EXECUTE PROCEDURE "informix".sp_ctanvl2_regtelefonos(cNumCte,'5511357181',2,0)
				INTO cCodRetSp;
				
				--LET iCodRetSp = cCodRetSp::INTEGER;
				LET iCodRetSp = 0;
				IF iCodRetSp <> 0 THEN
					LET cCodRet = cCodRetSp; --'113';
					--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_regtelefonos';
					RETURN cCodRet,cNumCte,cNumCta;
				ELIF iCodRetSp = 0 THEN
					
					----PASO 4: DAR DE ALTA EL CORREO
					--CREATE PROCEDURE "informix".sp_ctanvl2_regcorreos(pNumCte CHAR(20),pCorreoElec CHAR(100),pTipoCorreo SMALLINT)
					EXECUTE PROCEDURE "informix".sp_ctanvl2_regcorreos(cNumCte,'emartinez@bancoppel.com',1)
					INTO cCodRetSp;
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp <> 0 THEN
						LET cCodRet = '114';
						--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_regcorreos';
						RETURN cCodRet,cNumCte,cNumCta;
					ELIF iCodRetSp = 0 THEN
						
						----PASO 5: DAR DE ALTA LA CUENTA
						EXECUTE PROCEDURE "informix".sp_ctanvl2_gencta(cNumCte)
						INTO cCodRetSp, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
					
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp <> 0 THEN
							LET cCodRet = '115';
							--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencta';
							RETURN cCodRet,cNumCte,cNumCta;
						ELIF iCodRetSp = 0 THEN
							LET cCodRet = '00000';
						END IF;
							--IF cCodRet <> '00000' THEN
							--	LET cCodRet = '368';
							--END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	
	RETURN cCodRet,cNumCte,cNumCta;
    
	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Pablo Humberto Lavalle Cambranis',
'FECHA: 02/04/2023',
'DESCRIPCION: SPL encargado de dar de alta el usuario ios';

CREATE PROCEDURE "informix".sp_gen_usuario_huawei_pentesting( pempresa CHAR(3) )
RETURNING CHAR(5) AS codret, CHAR(20) AS numcte, CHAR(20) AS NumCta;

	DEFINE cCodRet CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumCte CHAR(20);
	
	DEFINE cNumCta CHAR(20);
	DEFINE cCtaClabe CHAR(18);
	DEFINE cCteNuevo CHAR(2);
	DEFINE cNombreCte CHAR(104);
	DEFINE cFechaNac CHAR(10);
	DEFINE cTelMovil CHAR(10);
	DEFINE vgenfolio CHAR(1);
	
	DEFINE pTp_persona CHAR(2);
	DEFINE pTp_cliente CHAR(1);
	DEFINE pPaterno CHAR(26);
	DEFINE pMaterno CHAR(26);
	DEFINE pNombre1 CHAR(26);
	DEFINE pNombre2 CHAR(26);
	DEFINE pRfc CHAR(13);
	DEFINE pNumcte_ref CHAR(20);
	DEFINE pFecha_nac DATE;
	DEFINE pLugar_nac CHAR(2);
	DEFINE pNacionalidad CHAR(3);
	DEFINE pEstado_civil CHAR(1);
	DEFINE pSexo CHAR(1);
	DEFINE pCurp CHAR(20);
	DEFINE pCodidentif CHAR(1);
	DEFINE pNumidentif CHAR(30);
	DEFINE pActividad SMALLINT;
	DEFINE pSubactividad SMALLINT;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cNumCte = '';
	LET cTelMovil = '';
	LET vgenfolio = 'F';
	
	LET cNumCta = '';
	LET cCtaClabe = '';
	LET cCteNuevo = '';
	LET cNombreCte = '';
	LET cFechaNac = '';
	
	LET pTp_persona = '01';
	LET pTp_cliente = '2';
	LET pPaterno = 'USER';
	LET pMaterno = 'BANCOPPEL';
	LET pNombre1 = 'HUAWEI';
	LET pNombre2 = '';
	LET pRfc     = 'UEBH710119EZ6';
	LET pNumcte_ref = '';
	LET pFecha_nac = '01-19-1971';
	LET pLugar_nac = '02';
	LET pNacionalidad = '001';
	LET pEstado_civil = 'S';
	LET pSexo = 'M';
	LET pCurp = 'UEBH710119HDFSNW08';
	LET pCodidentif = 'A';
	LET pNumidentif = '2454015358571';
	LET pActividad = 0;
	LET pSubactividad = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlerr <> 0 THEN
				--ROLLBACK WORK;
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet,cNumCte,cNumCta;
		END EXCEPTION;
    
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gen_usuario_huawei_pentesting.out';
		--TRACE ON;
		
		--SET DEBUG FILE TO '/ifxsif01/ireb/n2/sp_gen_usuario_huawei_pentesting.out';
		--TRACE ON;
    
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
    
	
		----PASO 1: GENERAR EL NÃMERO DE CLIENTE AL CLIENTE
		EXECUTE PROCEDURE "informix".sp_ctanvl2_gencte(pTp_persona,pTp_cliente,pPaterno,pMaterno,pNombre1,pNombre2,pRfc,pNumcte_ref,pFecha_nac,pLugar_nac,pNacionalidad,pEstado_civil,pSexo,
		pCurp,pCodidentif,pNumidentif,pActividad,pSubactividad)
		--EXECUTE PROCEDURE "informix".sp_ctanvl2_gencte('01','2','USER','BANCOPPEL','IOS','','UEBI7101192C3','','01-19-1971','02','001','S','F','UEBI710119MDFSNS08','A','2454015358571',0,0)
		INTO cCodRetSp, cNumCte;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		
		--EXECUTE PROCEDURE "informix".sp_ctanvl2_gencte('01','2','USER','BANCOPPEL','IOS','','UEBI7101192C3','','01-19-1971','02','001','S','F','UEBI710119MDFSNS08','A','2454015358571',0,0);
		--INTO cCodRet, cNumCte;
		
		IF iCodRetSp <> 0 THEN
			LET cCodRet = '111';
			--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencte';
			RETURN cCodRet,cNumCte,cNumCta;
		ELIF iCodRetSp = 0 THEN
			
			----PASO 2: DAR DE ALTA EL DOMICLIO DEL CLIENTE
			EXECUTE PROCEDURE sp_ctanvl2_regdomicilio(cNumCte,'C MIXCOAC Y COCOYOC 22 D','','00000','','02','028','21448','028','','','','001',134176,14,'N',0,0,0,0,'')
			INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			
			IF iCodRetSp <> 0 THEN
				LET cCodRet = '112';
				--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_regdomicilio';
				RETURN cCodRet,cNumCte,cNumCta;
			ELIF iCodRetSp = 0 THEN
				
				----PASO 3: DAR DE ALTA EL TELEFONO DEL CLIENTE
				EXECUTE PROCEDURE "informix".sp_ctanvl2_regtelefonos(cNumCte,'5536743206',2,0)
				INTO cCodRetSp;
				
				--LET iCodRetSp = cCodRetSp::INTEGER;
				LET iCodRetSp = 0;
				IF iCodRetSp <> 0 THEN
					LET cCodRet = cCodRetSp; --'113';
					--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_regtelefonos';
					RETURN cCodRet,cNumCte,cNumCta;
				ELIF iCodRetSp = 0 THEN
					
					----PASO 4: DAR DE ALTA EL CORREO
					--CREATE PROCEDURE "informix".sp_ctanvl2_regcorreos(pNumCte CHAR(20),pCorreoElec CHAR(100),pTipoCorreo SMALLINT)
					EXECUTE PROCEDURE "informix".sp_ctanvl2_regcorreos(cNumCte,'lbarragan@bancoppel.com',1)
					INTO cCodRetSp;
					
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp <> 0 THEN
						LET cCodRet = '114';
						--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_regcorreos';
						RETURN cCodRet,cNumCte,cNumCta;
					ELIF iCodRetSp = 0 THEN
						
						----PASO 5: DAR DE ALTA LA CUENTA
						EXECUTE PROCEDURE "informix".sp_ctanvl2_gencta(cNumCte)
						INTO cCodRetSp, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
					
						LET iCodRetSp = cCodRetSp::INTEGER;
						IF iCodRetSp <> 0 THEN
							LET cCodRet = '115';
							--RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencta';
							RETURN cCodRet,cNumCte,cNumCta;
						ELIF iCodRetSp = 0 THEN
							LET cCodRet = '00000';
						END IF;
							--IF cCodRet <> '00000' THEN
							--	LET cCodRet = '368';
							--END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	
	RETURN cCodRet,cNumCte,cNumCta;
    
	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Pablo Humberto Lavalle Cambranis',
'FECHA: 02/04/2023',
'DESCRIPCION: SPL encargado de dar de alta el usuario ios';

CREATE PROCEDURE "informix".sp_registro_aut_envio_edocta(pNumCte CHAR(10), pSucursal CHAR(4), pEjecutivo CHAR(10), pStatus CHAR(1), pProducto CHAR(10),pNumSolicitud CHAR(30))
        RETURNING CHAR (5), CHAR (1);

                --************************************************************************************************************************************
                --*                                     DEFNICION DE VARIBLES
                --************************************************************************************************************************************

                DEFINE cod_ret          CHAR(5);
                DEFINE vsqlerr          INTEGER;
                DEFINE rstatus          CHAR(1);
                DEFINE dfecha           DATE;
                DEFINE existeAutorizacion INTEGER;
                --************************************************************************************************************************************
                --*                                     ASIGANACION DE VARIABLES
                --************************************************************************************************************************************

                LET cod_ret             = "00000";
                LET vsqlerr             = 0;
                LET rstatus             = "1";
                LET dfecha              = TODAY;
                LET existeAutorizacion  = 0;
                --************************************************************************************************************************************
                --*                                     CONTROL DE ERRORES
                --************************************************************************************************************************************

                BEGIN
                        ON EXCEPTION SET vsqlerr
                        IF vsqlerr != 0 THEN
                                LET cod_ret = vsqlerr;
                                LET rstatus = "0";
                                RETURN vsqlerr, rstatus;
                        END IF;
                        END EXCEPTION;

                        --SET DEBUG FILE TO "/home/sysifx/sp_registro_aut_envio_edocta.out";
                        --TRACE ON;

                        SET LOCK MODE TO WAIT 3;
                        SET ISOLATION TO DIRTY READ;

                        --********************************************************************************************************************************
                        --*                                 PROGRAMA PRINCIPAL
                        --********************************************************************************************************************************

                        IF NVL(pNumCte, '') <> "" AND NVL (pStatus, '') <> "" THEN

										DELETE FROM "informix".si_autorizacion_envio_edocta
                                        WHERE numcte=pNumCte
                                        AND producto='' AND num_solicitud=''
                                        AND fecha_autorizacion <> dfecha;
										
                                        SELECT count(numcte) INTO existeAutorizacion
                                        FROM bdinteg:"informix".si_autorizacion_envio_edocta
                                        WHERE numcte=pNumCte
                                        AND sucursal=pSucursal;

                                    
                                        IF existeAutorizacion > 0 then
                                                -- ya existe el cliente autorizado- se valida si es una nueva solicitud.
                                                IF pStatus='1' AND pProducto= '' AND pNumSolicitud = '' THEN
                                                                SELECT count(numcte) INTO existeAutorizacion -- Se valida si ya se encuentra un registro iniciado
                                                                FROM bdinteg:"informix".si_autorizacion_envio_edocta
                                                                WHERE numcte=pNumCte
                                                                AND sucursal=pSucursal
                                                                AND producto='' AND num_solicitud='';

                                                                IF existeAutorizacion =0  THEN
                                                                        INSERT INTO bdinteg:"informix".si_autorizacion_envio_edocta(numcte,sucursal,ejecutivo,fecha_autorizacion,status_autorizacion,producto,num_solicitud)
                                                                        VALUES(pNumCte,pSucursal,pEjecutivo,dfecha,pStatus,"","");
                                                                END IF;

                                                ELSE
                                                        -- ya hay una solicitud iniciada- sin producto y solicitud.
                                                                UPDATE bdinteg:"informix".si_autorizacion_envio_edocta
                                                                SET fecha_autorizacion=CURRENT, producto=pProducto, num_solicitud=pNumSolicitud
                                                                WHERE numcte=pNumCte AND sucursal=pSucursal
                                                                AND producto='' AND num_solicitud=''
                                                                AND fecha_autorizacion=dfecha;
                                                END IF;
                                        ELSE
											IF pStatus='1' AND pProducto= '' AND pNumSolicitud = '' THEN
                                                INSERT INTO bdinteg:"informix".si_autorizacion_envio_edocta(numcte,sucursal,ejecutivo,fecha_autorizacion,status_autorizacion,producto,num_solicitud)
                                                VALUES(pNumCte,pSucursal,pEjecutivo,dfecha,pStatus,"","");
											END IF;
												
                                        END IF;
                        ELSE
                                LET cod_ret = "00001";
                                LET rstatus = "0";
                        END IF;

                        RETURN  cod_ret, rstatus;
                END;
        END PROCEDURE

        DOCUMENT
        '----------------------------------------------------------------------------',
        '--Autor: 90225188 Jose Natanael Ortiz Rodriguez',
        '--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
        '--Fecha: 26/09/2022.',
        '--Solicita:',
        '--Descripcion: Se crea procedimiento almacenado para registrar la autorizacion',
        '--de envio de estado de cuenta por medios electronicos',
        '--Modificacion: se modifica para validaciones',
        '--BD: bdinteg.',
        '-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctanvl2_genportada_benef( pNumCte CHAR(20),pNumCta CHAR(20) )
RETURNING CHAR(5) AS codret,
          CHAR(104) AS nombre_benef,
          CHAR(10) AS porcentaje,
          CHAR(40) AS parentesco;
	
    DEFINE cCodRet       CHAR(5);
    DEFINE cCodRet2      CHAR(5);
    DEFINE cCodRet3      CHAR(50);
    DEFINE iSqlErr       INTEGER;
    DEFINE iSamErr       INTEGER;
    DEFINE cDesErr       CHAR(50);
    DEFINE cNombreBenef  CHAR(104);
    DEFINE cPorcentaje   CHAR(10);
    DEFINE cParentesco   CHAR(40);
    DEFINE iRecuperacion INTEGER;

    LET cCodRet = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
    LET cNombreBenef = '';
    LET cPorcentaje = '';
    LET cParentesco = '';
    LET iRecuperacion = 0;
	
	BEGIN
	
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr 
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_genportada_benef.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet, cNombreBenef, cPorcentaje, cParentesco;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_genportada_benef.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA CAMPOS REQUERIDOS
    IF ( pNumCte IS NULL OR pNumCte = '' OR pNumCta IS NULL OR pNumCta = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet, cNombreBenef, cPorcentaje, cParentesco;
    END IF;
    
    FOREACH
        SELECT TRIM(TRIM(cte.nombre1)||' '||TRIM(cte.nombre2))||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno), ben.porcentaje, par.descripcion
          INTO cNombreBenef, cPorcentaje, cParentesco
          FROM bdinteg:si_cliente AS cte, 
               bdicheq:sc_beneficiario AS ben, 
               bdinteg:si_parentesco AS par
         WHERE cte.numcte = pNumCte 
           AND ben.cuenta = pNumCta
           AND ben.numcte = cte.numcte 
           AND ben.parentesco = par.parentesco
        
        LET iRecuperacion = iRecuperacion + 1;
        RETURN cCodRet, cNombreBenef, cPorcentaje, cParentesco WITH RESUME;
    END FOREACH;
    
    IF NVL(iRecuperacion,0) = 0 THEN
        LET cCodRet = '001';
        RETURN cCodRet, cNombreBenef, cPorcentaje, cParentesco;
    END IF;
		
	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 15/07/2020',
'DESCRIPCION: SPL encargado de consultar el detalle de la informacion que sera implementada para la generacion de la portada.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_relacion_consultadatosrpt (pDescripcion CHAR(20),pFechaIni CHAR(10),pFechaFin CHAR(10))
	RETURNING
	CHAR(6)  AS COD_RET, 
	CHAR(80) AS MENSAJE_RETORNO,
	CHAR(20) AS NUM_CLIENTE,
	CHAR(107) AS NOMBRE_CLIENTE,
	/*CHAR(10)*/ DATE AS FECHA_NAC,
	CHAR(100)  AS DESCRIPCION_TIPO_RELACION_INICIAL,
	CHAR(20) AS NUM_CLIENTE_COPPEL,
	CHAR(104) AS NOMBRE_CLIENTE_COPPEL,
	CHAR(10) AS FECHA_NAC_COPPEL,
	CHAR(10)  AS MODIFICACION,
	CHAR(10) AS FECHA_RELACION,
	CHAR(100)  AS DESCRIPCION_TIPO_RELACION,
	CHAR(107) AS NOMBRE_ANALISTA;
	
-- Modificado por: Abrham López López, 26 Marzo 2013 Se modifica proceso para que solo traiga en el roporte movimientos hechos 
-- por mesa de control y el campo FECHA_NAC se cambio a DATE para que ponga correcta la fecha en pantalla con formato dd/mm/aaaa
	
---DECLARACIONES
DEFINE iSqlErr         	 INTEGER;
DEFINE iIsamErr        	 INTEGER;
DEFINE cErrorInfo      	 CHAR(80);
DEFINE cCodRet         	 CHAR(6);
DEFINE cMensajeRet     	 CHAR(80);

DEFINE cNumcte      	 CHAR(20);
DEFINE cNumSol      	 CHAR(20);
DEFINE cNombreCte      	 CHAR(107);
DEFINE dtFechaNac     	 CHAR(10);
DEFINE iTipoRelFin       SMALLINT;
DEFINE iTipoRelIni       SMALLINT;
DEFINE cDesTipoRelFin    CHAR(100);
DEFINE cDesTipoRelIni    CHAR(100);
DEFINE cDesModificacion  CHAR(10);

DEFINE cNomEmpleado      CHAR(107);
DEFINE cNumRef      	 CHAR(20);
DEFINE cNombre_coppel    CHAR(107);
DEFINE dtFechaNacCoppel  CHAR(10);
DEFINE dtFechaRelacion   CHAR(10);
DEFINE iContadorReg  	 INTEGER;
DEFINE cNumEmp  	     CHAR(10);
DEFINE vStatus           CHAR(1);
DEFINE sTipoRel          CHAR(1);
DEFINE iSecuencia        INTEGER;
DEFINE dFechaNacCoppel   DATE;
DEFINE cCliente          CHAR(20);

---INICIALIZACIONES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet        	= "PROCESO EXITOSO";   

LET cNumcte      		= "";
LET cNumSol      		= "";
LET cNombreCte      	= "";
LET dtFechaNac      	= "";
LET iTipoRelFin        	= 0;
LET iTipoRelIni        	= 0;
LET cDesTipoRelFin     	= "";
LET cDesTipoRelIni     	= "";
LET cDesModificacion  	= "";
LET cNomEmpleado    	= "";
LET cNumRef      		= "";
LET cNombre_coppel  	= "";
LET dtFechaNacCoppel    = "";
LET dtFechaRelacion     = "";
LET iContadorReg    	= 0;
LET cNumEmp    	        = "";
LET iSecuencia          = 0;
LET dFechaNacCoppel     = DATE(1);
LET cCliente            = "";
	
BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet,"","","","","","","","","","","";		 
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/gpe/sp_relacion_consultadatosrpt.out";
	--TRACE ON;
	
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF  NVL(pFechaIni,"") =  ""  OR  NVL(pFechaFin,"") =  "" THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
	/*ELSE
	IF pDescripcion = '' THEN
		LET	vStatus = '';
	ELIF pDescripcion = 'RELACION' THEN
		LET	vStatus = '1';
	ELSE
		LET	vStatus = '0';
	END IF;*/
	ELSE
	IF pDescripcion = 'GENERAL' THEN
		LET	vStatus = '';
	ELIF pDescripcion = 'RELACION' THEN
		LET	vStatus = '1';
	ELIF pDescripcion = 'SEPARACION' THEN
		LET	vStatus = '0';
	END IF;
	
           IF vStatus = '1' THEN
		      LET vStatus = '3';
		   END IF;
	
		FOREACH WITH HOLD
			
			SELECT {+INDEX(bdinteg:si_relacion_ctebcplcpl ix_relacion_ctebcplcpl3)} 
			a.fecha_insert,a.numcte_banco,a.cliente,a.tipo_relacion,a.definicion,a.tipo_re_ini, a.numempleado,status
            INTO dtFechaRelacion,cNumcte,cNumRef,iTipoRelFin,cDesModificacion,iTipoRelIni,cNumEmp, sTipoRel
            FROM bdinteg:"informix".si_relacion_ctebcplcpl a,
            bdicobranza:"informix".cb_param c            
            WHERE a.tipo_relacion  = vStatus
			AND a.status =  vStatus          
            AND a.fecha_insert BETWEEN pFechaIni AND pFechaFin	
            AND c.empresa = '001'
            AND c.cod_param IN (43,44)
            AND c.valor  = a.definicion
            order by a.fecha_insert
			
			IF sTipoRel =0 AND iTipoRelIni NOT IN ('2','3') THEN
				CONTINUE foreach;
			END IF;
			IF sTipoRel =1 AND iTipoRelFin <> 3 THEN
				CONTINUE foreach;
			END IF;
			--
			
			IF pDescripcion = 'SEPARACION' THEN
			
				SELECT MAX(secuencia)
				INTO iSecuencia
				FROM bdinteg:"informix".si_relacion_ctebcplcpl_hist
				WHERE empresa = '001'
				AND numcte_banco= cNumcte
				AND cliente <> '';
				
				IF NVL(iSecuencia,0) > 0 THEN
					SELECT cliente
					INTO cCliente
					FROM bdinteg:"informix".si_relacion_ctebcplcpl_hist
					WHERE empresa = '001'
					AND numcte_banco= cNumcte
					AND secuencia = iSecuencia;
					
					LET cNumRef = cCliente;
					LET iSecuencia = 0;
				END IF;
			END IF;
			
			SELECT MAX (secuencia)
			INTO iSecuencia
			FROM bdisolic:"informix".ss_respuesta_conscoppel
			WHERE empresa = '001'
			AND numcte = cNumcte 
			AND numcte_ref= cNumRef;
			
			IF NVL(iSecuencia,0) > 0 THEN
			
				SELECT fechanaccop
				INTO dFechaNacCoppel
				FROM bdisolic:"informix".ss_respuesta_conscoppel
				WHERE empresa = '001'
				AND numcte = cNumcte 
				AND numcte_ref= cNumRef
				AND secuencia = iSecuencia;
				
				LET dtFechaNacCoppel = dFechaNacCoppel;
				
			END IF;
			
			IF NVL(cNumEmp,"") <> "" THEN
				SELECT nombre
					INTO cNomEmpleado
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = '001' 
				AND  ejecutivo = cNumEmp;
			END IF;

			SELECT valor_alfabetico
				INTO cDesTipoRelFin
			FROM  bdicobranza:"informix".cb_param_campania
			WHERE grupo_parametro ="TIPO_RELAC"
			AND valor_numerico = NVL(iTipoRelFin,0);	
			
			
			SELECT valor_alfabetico
				INTO cDesTipoRelIni
			FROM  bdicobranza:"informix".cb_param_campania
			WHERE grupo_parametro ="TIPO_RELAC"
			AND valor_numerico = NVL(iTipoRelIni,0);
			
			
	  --	IF  NVL(cNumRef,"")  <> ""THEN 
				--obtiene la información del cliente
				SELECT TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno),b.fecha_nac
					INTO cNombreCte,dtFechaNac
				FROM bdinteg:"informix".si_cliente a,
					 bdinteg:"informix".si_ctepf b 
				WHERE a.empresa = b.empresa
				AND a.numcte = b.numcte
				AND a.numcte = cNumcte;
			--- AND a.numcte_ref = cNumRef; 
				
				let cNombre_coppel = ' ';					
				IF EXISTS (SELECT nombre_coppel FROM bdisolic:"informix".ss_bitacora_precal WHERE empresa = '001' 	AND num_referencia = cNumRef ) THEN
					
					SELECT nombre_coppel
						INTO cNombre_coppel
					FROM bdisolic:"informix".ss_bitacora_precal 
					WHERE empresa = '001' 
					AND num_referencia = cNumRef 
					/*AND ROWID = (SELECT MAX(ROWID)
									FROM  bdisolic:"informix".ss_bitacora_precal aux2
									WHERE aux2.empresa = '001' 
									AND aux2.num_referencia = cNumRef);		*/
					AND consecutivo = (SELECT MAX(consecutivo)
									FROM  bdisolic:"informix".ss_bitacora_precal aux2
									WHERE aux2.empresa = '001' 
									AND aux2.num_referencia = cNumRef);	
				END IF;
		--	END IF;
		
			LET iContadorReg = iContadorReg+1;
			RETURN cCodRet,cMensajeRet,NVL(cNumcte,""),NVL(cNombreCte,""),NVL(dtFechaNac,""),NVL(cDesTipoRelIni,""),NVL(cNumRef,""),NVL(cNombre_coppel,""),	
				NVL(dtFechaNacCoppel,""),NVL(cDesModificacion,""),NVL(dtFechaRelacion,""),NVL(cDesTipoRelFin,""),NVL(cNomEmpleado,"") WITH RESUME;
		END FOREACH;
	END IF;	
	IF iContadorReg = 0 THEN 
		IF cCodRet = "000000" THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'No se encontraron registros del periodo indicado';
		END IF;
		RETURN cCodRet,cMensajeRet,cNumcte,cNombreCte,dtFechaNac,NVL(cDesTipoRelIni,""),NVL(cNumRef,""),NVL(cNombre_coppel,""),	
			NVL(dtFechaNacCoppel,""),NVL(cDesModificacion,""),NVL(dtFechaRelacion,""),NVL(cDesTipoRelFin,""),NVL(cNomEmpleado,"");
	END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta para obtener la información general del cliente en bancoppel y coppel de acuerdo a los tipos de reportes', 
'AUTOR: Jesús Aguilar ',
'FECHA: 26 ABRIL 2012',
'BD: BDINTEG',
'VERSION: 20120426.1641',
'DESCRIPCION: se modifica para retornar la fecha necimiento coppel', 
'AUTOR: Felipe Urias ',
'FECHA: 08 Enero 2015',
'BD: BDINTEG',
'VERSION: 20150108.1025';

CREATE PROCEDURE "informix".sp_ctanvl2_generapdf_pba(pNumCte CHAR(20),pNumCta CHAR(20))
	RETURNING CHAR(5);

	DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
	DEFINE cCommand CHAR(500);
	DEFINE cSQL CHAR(500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNomReporte CHAR(40);
	--- DEFINE cComponente CHAR(20);
	DEFINE cCmd1 CHAR(500);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cFechaHr CHAR(14);
	DEFINE cNomPortada CHAR(40);
	DEFINE cNomPortadaB CHAR(40);
	DEFINE cNomContrato CHAR(40);
	DEFINE cNomCaratura CHAR(40);

	DEFINE cProducto CHAR(40);
	DEFINE cNombreCte CHAR(107);
	DEFINE cFechaNac CHAR(10);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(50);
	DEFINE cOperacion CHAR(30);
	DEFINE cFechaOpe CHAR(30);
	DEFINE cFolioOpe CHAR(20);
	DEFINE cCuenta CHAR(20);
	DEFINE cCtaClabe CHAR(20);
	DEFINE cTitular CHAR(104);
	DEFINE cAutorizaRevoc CHAR(2);
	DEFINE cReca CHAR(100);
	DEFINE cNombreBenef CHAR(104);
	DEFINE cPorcentaje CHAR(10);
	DEFINE cParentesco CHAR(40);
	DEFINE cProdCap CHAR(100);
	DEFINE cProdNom CHAR(100);
	DEFINE cProdGen CHAR(100);
	DEFINE cFecha CHAR(10);
	DEFINE cProd CHAR(4);
	DEFINE cNumCta CHAR(20);
	DEFINE cRutaArchivoImg CHAR(200);
	DEFINE cNombreArchivoImg CHAR(200);
    DEFINE cCorreoElec CHAR(50);
	DEFINE iCounter INTEGER;
	DEFINE cRcan CHAR(50);
	DEFINE cVar1 CHAR(50);
	DEFINE cVar2 CHAR(50);
	DEFINE cVar3 CHAR(50);
	DEFINE cVar4 CHAR(50);
	DEFINE cVar5 CHAR(50);
	DEFINE cVar6 CHAR(80);

	LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
	LET cCommand = '';
	LET cSQL = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET cCodRet = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
	--- LET cRutaArchivo = '/tmp/mfinis/caratulasCuentaNivel2/';
    LET cRutaArchivo = '/RESPALDOSNEW/DoctosCtaNvl2/';
	LET cNomReporte = '';
	--- LET cComponente = '';
	LET cCmd1 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cFechaHr = TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cNomPortada = '';
	LET cNomPortadaB = '';
	LET cNomContrato = '';
	LET cNomCaratura = '';

	LET cProducto = '';
	LET cNombreCte = '';
	LET cFechaNac = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET cOperacion = ' ';
	LET cFechaOpe = '';
	LET cFolioOpe = '';
	LET cCuenta = '';
	LET cCtaClabe = '';
	LET cTitular = '';
	LET cAutorizaRevoc = '';
	LET cReca = '';
	LET cNombreBenef = '';
	LET cPorcentaje = '';
	LET cParentesco = '';
	LET cProdCap = '';
	LET cProdNom = '';
	LET cProdGen = '';
	LET cFecha = '';
	LET cProd = '';
	LET cNumCta =pNumCta;
	LET cRutaArchivoImg = '';
	LET cNombreArchivoImg = '';
    LET cCorreoElec = '';
	LET iCounter = 0;
	LET cRcan = '';
	LET cVar1 = '';
	LET cVar2 = '';
	LET cVar3 = '';
	LET cVar4 = '';
	LET cVar5 = '';
	LET cVar6 = '';
	
	BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_generapdf_pba.err';
        TRACE ON;
        IF iSqlerr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_generapdf_pba.out';
    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA CAMPOS REQUERIDOS
    IF pNumCte IS NULL OR pNumCte = '' OR pNumCta IS NULL OR pNumCta = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    /* ###################################################################
    SELECT {+INDEX (bdinteg:"informix".si_param ix_si_param)} valor 
      INTO cRutaArchivo
      FROM bdinteg:"informix".si_param 
     WHERE cod_param = 487;
    ################################################################### */

    -- // SE DEFINE NOMENCLATURA DEL REPORTE
    LET cNomReporte = 'reportes'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
    LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomReporte);
    SYSTEM TRIM(cCommand);

    -- // EJECUTA PORTADA
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_genportada(pNumCte,pNumCta)
    INTO cCodRetSp,cProducto,cNombreCte,cFechaNac,cRfc,cSucursal,cOperacion,cFechaOpe,cFolioOpe,cCuenta,cCtaClabe,cTitular,cAutorizaRevoc,cReca,cProd;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_genportada';
    ELIF iCodRetSp = 0 THEN

        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomPortada = 'portada'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomPortada);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (producto,nombre_cte,fecha_nac,rfc,sucursal,operacion,fecha_ope,folio_ope,cuenta,cta_clabe,titular,autoriza_revoc,reca)
        VALUES
        (cProducto,cNombreCte,cFechaNac,cRfc,cSucursal,cOperacion,cFechaOpe,cFolioOpe,cCuenta,cCtaClabe,cTitular,cAutorizaRevoc,cReca);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT producto,nombre_cte,fecha_nac,rfc,sucursal,operacion,fecha_ope,folio_ope,cuenta,cta_clabe,titular,autoriza_revoc,reca";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomPortada)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');

        DELETE FROM bdinteg:"informix".si_ctanvl2_retornosbenef;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomPortadaB = 'portadabenef'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomPortadaB);
        SYSTEM TRIM(cCommand);

        FOREACH
            EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_genportada_benef(pNumCte,pNumCta)
            INTO cCodRetSp,cNombreBenef,cPorcentaje,cParentesco

            LET iCodRetSp = cCodRetSp::INTEGER;
            IF iCodRetSp < 0 THEN
                RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_genportada_benef';
            ELIF iCodRetSp = 0 THEN
                INSERT INTO bdinteg:"informix".si_ctanvl2_retornosbenef
                (nombre_benef,porcentaje,parentesco)
                VALUES
                (cNombreBenef,cPorcentaje,cParentesco);
                
                LET iCounter = iCounter + 1;
            END IF;
        END FOREACH;


        IF iCounter > 0 THEN
            LET cCmd1 ="";
            LET cCmd1 ="SELECT nombre_benef,porcentaje,parentesco";
            LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornosbenef;";
            SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomPortadaB)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
        END IF;
    END IF;

    -- // EJECUTA CONTRATO
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_gencontrato(pNumCte,pNumCta)
    INTO cCodRetSp,cProdCap,cProdNom,cProdGen,cNombreCte,cFecha,cSucursal,cProducto;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencontrato';
    ELIF iCodRetSp = 0 THEN
        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomContrato = 'contrato'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomContrato);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (prod_cap,prod_nom,prod_gen,nombre_cte,fecha,sucursal,producto)
        VALUES
        (cProdCap,cProdNom,cProdGen,cNombreCte,cFecha,cSucursal,cProducto);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT prod_cap,prod_nom,prod_gen,nombre_cte,fecha,sucursal,producto";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomContrato)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
    END IF;

    -- // EJECUTA CARATULA
    EXECUTE PROCEDURE bdinteg:"informix".sp_ctanvl2_gencaratula(pNumCte,pNumCta)
    INTO cCodRetSp,cProducto;

    LET iCodRetSp = cCodRetSp::INTEGER;
    
    IF iCodRetSp < 0 THEN
        RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_ctanvl2_gencaratula';
    ELIF iCodRetSp = 0 THEN
        DELETE FROM bdinteg:"informix".si_ctanvl2_retornos;
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            --- LET cCodRet = '00862';
        END IF;

        LET cNomCaratura = 'caratula'||TRIM(pNumCte)||'_'||TRIM(cFechaHr)||'.txt';
        LET cCommand = 'rm -rf '||TRIM(cRutaArchivo)||TRIM(cNomCaratura);
        SYSTEM TRIM(cCommand);

        INSERT INTO bdinteg:"informix".si_ctanvl2_retornos
        (producto)
        VALUES
        (cProducto);

        LET cCmd1 ="";
        LET cCmd1 ="SELECT producto";
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_ctanvl2_retornos;";

        SYSTEM TRIM('echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaArchivo)||TRIM(cNomCaratura)||' ' || TRIM(cCmd1)||'" | '||TRIM(cRutaInformix)||'dbaccess bdinteg > /dev/null 2>&1');
    END IF;

    SELECT correo_elec 
      INTO cCorreoElec
      FROM bdinteg:"informix".si_correos 
     WHERE empresa = '001' 
       AND numcte = pNumCte 
       AND status_correo = 'A';
    
    SELECT SUBSTR(valor,62,29) 
      INTO cRcan
      FROM bdinteg:si_param 
     WHERE cod_param = 486;
    
    SELECT valor 
      INTO cVar1
      FROM bdinteg:si_param 
     WHERE cod_param = 496;
    
    SELECT valor 
      INTO cVar2
      FROM bdinteg:si_param 
     WHERE cod_param = 497;
    
    SELECT valor 
      INTO cVar3
      FROM bdinteg:si_param 
     WHERE cod_param = 498;
    
    SELECT valor 
      INTO cVar4
      FROM bdinteg:si_param 
     WHERE cod_param = 499;
    
    SELECT valor 
      INTO cVar5
      FROM bdinteg:si_param 
     WHERE cod_param = 500;
    
    SELECT valor 
      INTO cVar6
      FROM bdinteg:si_param 
     WHERE cod_param = 504;

    -- // java7 ---> java8
    --- LET cCommand = "/usr/java7/bin/java -jar /tmp/mfinis/caratulasCuentaNivel2/componente/Caratulas.jar '"||TRIM(pNumCte)||"' '"|| TRIM(pNumCta)||"' > /tmp/mfinis/caratulasCuentaNivel2/reportes.txt";
    LET cCommand = "/usr/java8/bin/java -jar "||TRIM(cRutaArchivo)||"componente/Caratulas.jar '"||TRIM(pNumCte)||"' '"|| TRIM(pNumCta)||"' '"|| TRIM(cNomPortada)||"' '"|| TRIM(cNomPortadaB)||"' '"|| TRIM(cNomContrato)||"' '"|| TRIM(cNomCaratura)||"' '"|| TRIM(cRutaArchivo)||"' '"||TRIM(cNomReporte)||"' '"||TRIM(cCorreoElec)||"' '"||TRIM(cRcan)||"'";
    SYSTEM(cCommand);

    --- LET cCommand = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaArchivo)||TRIM(cNomReporte);
    --- SYSTEM(cCommand);

    LET cCommand = 'echo "SET ISOLATION TO DIRTY READ; LOAD FROM '||TRIM(cRutaArchivo)||TRIM(cNomReporte)||' DELIMITER ''|'' INSERT INTO si_ctanvl2_ctrlrep(nom_reporte,fecha_gen,error,archivo_log)"  > '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM cCommand;

    LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF/imagenes';
    --- LET cRutaArchivoImg = TRIM(cRutaArchivo)||'caratulasPDF';
    LET cRutaArchivoImg = TRIM(cRutaArchivoImg);

    LET cNombreArchivoImg = TRIM(pNumCte)||'_'|| TRIM(cNumCta)||'.txt';
    LET cNombreArchivoImg = TRIM(cNombreArchivoImg);

    LET cCommand = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM(cCommand);

    LET cSQL = TRIM(cRutaInformix)||'dbaccess bdinteg '||TRIM(cRutaArchivo)||'reportesPDF_'||TRIM(cNomReporte)||'.sql';
    SYSTEM cSQL;

    EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimgleerarchivo(cRutaArchivoImg, cNombreArchivoImg) 
    INTO cCodRetSp;

    EXECUTE PROCEDURE bdinteg:"informix".sp_insertarimg(pNumCte, cNumCta, cProd) 
    INTO cCodRetSp;
    
    -- // ---> java8
    LET cCommand = "/usr/java8/bin/java -jar "||TRIM(cRutaArchivo)||"componente/EnvioImagenes.jar '"||TRIM(cRutaArchivoImg)||"' '"|| TRIM(cNombreArchivoImg)||"' '"|| TRIM(cVar6)||"' '"|| TRIM(cVar1)||"' '"|| TRIM(cVar2)||"' '"|| TRIM(cVar3)||"' '"|| TRIM(cVar4)||"' '"||TRIM(cVar5)||"'";
    SYSTEM(cCommand);
    
    RETURN cCodRet;

	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 20/07/2020',
'DESCRIPCION: SPL encargado de realizar la ejecucion del componente Caratulas.jar para la generacion de los reportes en formato PDF.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 17/08/2020',
'DESCRIPCION: Se modifica para proporcionar correo electronico al componente de caratulas.jar.',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 12/11/2021',
'DESCRIPCION: Se modifica para implementar el servicio web de insersion de imagen',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_insertarimg( pNumCte CHAR(20), pNumCta CHAR(20), pNumProd CHAR(4) )
RETURNING CHAR(5) AS codret;
    
	DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
	DEFINE iSqlErr          INTEGER;
	DEFINE iSamErr	        INTEGER;
	DEFINE cDesErr	        CHAR(50);
	DEFINE cCmd             CHAR(2000);
	DEFINE cScriptCarga     CHAR(600);
	DEFINE cRutaInformix    CHAR(100);
	DEFINE ven_transacc     SMALLINT;
	DEFINE bInTransaction   BOOLEAN;
	DEFINE cCampos          CHAR(1024);
	DEFINE cTablaDst        CHAR(150);
	DEFINE cBaseDatos       CHAR(50);
	DEFINE cUsrBin          CHAR(15);
	DEFINE cRuta            CHAR(100);
    DEFINE iId              INTEGER;
	
	LET cCodRet        = '00000';
	LET cCodRet2       = '';
    LET cCodRet3       = '';
	LET iSqlErr        = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
	LET bInTransaction = 'f';
	LET ven_transacc   = 0;
	LET cCmd           = '';
	LET cScriptCarga   = '';
	LET cRutaInformix  = '/ifxsif01/bin/';
	LET cCampos        = '';
	LET cTablaDst      = 'si_ctanvl2_rutaimg';
	LET cBaseDatos     = 'bdinteg';
	LET cUsrBin        = '/usr/bin/';
	LET cRuta          = '';
    LET iId            = 0;
	
	BEGIN		
	
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_insertarimg.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_insertarimg.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH
        --- Select substr(ruta, CHARINDEX('.',ruta)-1,1) as id, ruta 
        Select 1 as id, ruta 
          into iId, cRuta 
          from bdinteg:si_ctanvl2_rutaimg
         where ruta like '%Por%'
        
        /* ##############################################################################################################################################
        insert into bdidigital@coppelimg_crx:"informix".dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '168', iId, 'PORTADA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_insertarimgdigital(TRIM(pNumCte), TRIM(cRuta), iId, '168') 
        into cCodret;
        ############################################################################################################################################## */
        
        insert into bdidigital@coppelimg_crx:dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '0168', iId, 'PORTADA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        INSERT INTO bdidigital@coppelimg_crx:dg_expediente_img1 
        ( empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        VALUES 
        ( '001', TRIM(pNumCte), '0168', iId, null, 'png', ' ', 'informix', CURRENT, ' ', ' ' ); 
        
        --- RETURN cCodret WITH RESUME;
    END FOREACH;

    FOREACH
        --- Select substr(ruta, CHARINDEX('.',ruta)-1,1) as id, ruta 
        Select 1 as id, ruta 
          into iId, cRuta 
          from bdinteg:si_ctanvl2_rutaimg
         where ruta like '%Car%'
        
        /* ##############################################################################################################################################
        insert into bdidigital@coppelimg_crx:"informix".dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '167', iId, 'CARATULA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, '', '' );
        
        EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_insertarimgdigital(TRIM(pNumCte), TRIM(cRuta), iId, '167') 
        into cCodret;
        ############################################################################################################################################## */
        
        insert into bdidigital@coppelimg_crx:dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '0167', iId, 'CARATULA CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, '', '' );
        
        INSERT INTO bdidigital@coppelimg_crx:dg_expediente_img1 
        ( empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        VALUES 
        ( '001', TRIM(pNumCte), '0167', iId, null, 'png', ' ', 'informix', CURRENT, ' ', ' ' ); 
        
        --- RETURN cCodret WITH RESUME;
    END FOREACH;

    FOREACH
        --- Select substr(ruta, CHARINDEX('.',ruta)-1,1) as id, ruta 
        Select 1 as id, ruta 
          into iId, cRuta 
          from bdinteg:si_ctanvl2_rutaimg
         where ruta like '%Con%'
        
        /* ##############################################################################################################################################
        insert into bdidigital@coppelimg_crx:"informix".dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '166', iId, 'CONTRATO CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".sp_insertarimgdigital(TRIM(pNumCte), TRIM(cRuta), iId, '166') 
        into cCodret;
        ############################################################################################################################################## */
        
        insert into bdidigital@coppelimg_crx:dg_expediente 
        ( empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        values 
        ( '001', TRIM(pNumCte), TRIM(pNumCta), TRIM(pNumProd), '0166', iId, 'CONTRATO CUENTA DIGITAL BANCOPPEL', ' ', 'informix', today, ' ', ' ' ); 
        
        INSERT INTO bdidigital@coppelimg_crx:dg_expediente_img1 
        ( empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif ) 
        VALUES 
        ( '001', TRIM(pNumCte), '0166', iId, null, 'png', ' ', 'informix', CURRENT, ' ', ' ' ); 
        
        --- RETURN cCodret WITH RESUME;
    END FOREACH;
    
    RETURN cCodret;
    
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen',
'FECHA: 05/04/2021',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION:',
'BD: bdinteg';

CREATE PROCEDURE "informix".limpia_cadenaweb(Ccadena CHAR(100)) 
    returning CHAR(100);
    
    define i integer;
    define Cregreso CHAR(100);
    
    LET i = 0;
    LET Cregreso = '';           
    BEGIN
   
     --SET DEBUG FILE TO "/informix/vic/limpia_cadena_web.out";
     --TRACE ON;
    
        LET Ccadena = trim(Ccadena);
        LET Ccadena = replace(Ccadena,'ÃÂ','A');
        LET Ccadena = replace(Ccadena,'ÃÂ','E');
        LET Ccadena = replace(Ccadena,'ÃÂ','I');
        LET Ccadena = replace(Ccadena,'ÃÂ','O');
        LET Ccadena = replace(Ccadena,'ÃÂ','U');
			
        LET Ccadena = replace(Ccadena,'á','A');
        LET Ccadena = replace(Ccadena,'é','E');
        LET Ccadena = replace(Ccadena,'í','I');
        LET Ccadena = replace(Ccadena,'ó','O');
        LET Ccadena = replace(Ccadena,'ú','U');
        
        LET Ccadena = replace(Ccadena,'Á','A');
        LET Ccadena = replace(Ccadena,'É','E');
        LET Ccadena = replace(Ccadena,'Í','I');
        LET Ccadena = replace(Ccadena,'Ó','O');
        LET Ccadena = replace(Ccadena,'Ú','U');
		
        LET Ccadena = replace(Ccadena,'¾','N');        
        LET Ccadena = replace(Ccadena,'¡','I');
        LET Ccadena = replace(Ccadena,'¤','N');
        LET Ccadena = replace(Ccadena,'§','5');
        LET Ccadena = replace(Ccadena,'ª','A');
        LET Ccadena = replace(Ccadena,'°','RO');
        LET Ccadena = replace(Ccadena,'´',' ');
        LET Ccadena = replace(Ccadena,'·','A');
        LET Ccadena = replace(Ccadena,'ê','U');
        LET Ccadena = replace(Ccadena,'Ñ','N');
        LET Ccadena = replace(Ccadena,'ñ','N');
        LET Ccadena = replace(Ccadena,'Ô','I');
        LET Ccadena = replace(Ccadena,'Ö','E');
        LET Ccadena = replace(Ccadena,'Ü','U');
        LET Ccadena = replace(Ccadena,'Þ','I');
        LET Ccadena = replace(Ccadena,'?','U');
        LET Ccadena = replace(Ccadena,'µ','A');
        LET Ccadena = replace(Ccadena,'¢','O');
        LET Ccadena = replace(Ccadena,'£','U');
        LET Ccadena = replace(Ccadena,'¦','A');
        LET Ccadena = replace(Ccadena,'¥','N');        
                
        
        
        --LET Ccadena = replace(Ccadena,'#','Ã?Ã?');
		--LET Ccadena = trim(Ccadena); -- mover tempo Aqui
		
        For i=1 to length(Ccadena)
        
            IF upper(substr(Ccadena, i,1)) between chr(65) and chr(90) THEN
                continue;
            ELIF upper(substr(Ccadena, i,1)) between chr(48) and chr(57) THEN
                continue;
           -- ELIF upper(substr(Ccadena, i,1)) IN (chr(58),chr(44),chr(45),chr(46),chr(40),chr(41),chr(32),chr(164),chr(165),chr(209),chr(241), chr(13)) THEN
            ELIF upper(substr(Ccadena, i,1)) IN (chr(58),chr(44),chr(45),chr(46),chr(40),chr(41),chr(32),chr(164),chr(165),chr(209),chr(241)) THEN
                continue;
            ELSE
               LET Ccadena = replace(Ccadena,substr(Ccadena,i,1),'');
            END IF;
           
        End For;
        
        LET Ccadena = replace(Ccadena,chr(165),chr(35));
        LET Ccadena = replace(Ccadena,chr(164),chr(35));
        LET Ccadena = replace(Ccadena,chr(209),chr(35));
        LET Ccadena = replace(Ccadena,chr(241),chr(35));
        --LET Ccadena = replace(Ccadena,chr(46),chr(35)); --MACF
        --LET Ccadena = replace(Ccadena,chr(177),chr(35)); --MACF
        
            
        --LET Cregreso = substr(Ccadena, i-1, 1);
        return trim(Ccadena);
    END;
    
END PROCEDURE;
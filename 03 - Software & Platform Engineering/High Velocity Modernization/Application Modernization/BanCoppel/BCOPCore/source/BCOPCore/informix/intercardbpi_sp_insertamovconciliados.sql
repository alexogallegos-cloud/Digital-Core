CREATE PROCEDURE "informix".sp_insertamovconciliados
( 
psclaveautdetransaccion CHAR (7),
pscodigoiso CHAR	(2), 
pscodrespbase24 CHAR	(3), 
pscodret CHAR	(5), 
pscodretsurcharge CHAR	(5), 
pscodreversa CHAR	(1), 
pscodtran CHAR	(2), 
psesconvenio CHAR	(1), 
psespropio CHAR	(1), 
pdtfechaapllib DATETIME YEAR TO FRACTION,
psfechadeconciliacion CHAR  (19) ,
pdtfechadereportebre DATETIME YEAR TO FRACTION, 
psfechadetransaccion CHAR	(10), 
pdtfechahorainauth DATETIME YEAR TO FRACTION, 
psfechalocaltransaccion CHAR	(4), 
psformato CHAR	(4), 
psfuenteid CHAR	(3), 
pshoradetransaccion CHAR	(8), 
pshoralocaltransaccion CHAR	(6), 
psidcomercio CHAR	(10), 
psidreceptor CHAR	(4), 
pmmontocashback MONEY, 
pmmontocomcashback MONEY, 
pmmontocomisioncobrada MONEY,
pmmontodetransaccion MONEY,
pmmontorealrevfzda MONEY,
pmmontoretenido MONEY,
pmmontosurcharge MONEY,
psmovreversado CHAR	(1), 
psnacint CHAR	(1), 
psnombrecomercio CHAR	(30), 
psnumctachequesafectada CHAR	(13), 
psnumerotarjeta CHAR	(16), 
psprodind CHAR	(2), 
psreferencia CHAR	(16), 
psreftransaccion CHAR	(23), 
psregistrado CHAR	(1), 
psrfc CHAR	(26), 
pssecenviadacentral CHAR	(7), 
pssecsurcharge CHAR	(7), 
--pisectrancon INT,       --no se pide, se obtienen el el sp
pssecuenciacashback CHAR	(7), 
pssecuenciacomcashback CHAR	(7), 
pssecuenciacomision CHAR	(7), 
pistatconsurcharge INTEGER ,
psstatuscentral CHAR (5), 
psstatuscomision CHAR	(1), 
pistatusdeconciliacion INTEGER ,
psstatustarjeta CHAR	(3), 
pstipoenviadacentral CHAR	(1), 
pstipomovimiento CHAR	(3), 
pstiporecibidacentral CHAR	(1), 
pstnrcobrocomisionctaindividual CHAR	(1), 
pmtnrmontocomisionctaindividual MONEY )

RETURNING CHAR (2000) ;

/*  DEFINICION DE VARIABLES */
DEFINE vsSalida CHAR (2000) ;

DEFINE vsCodStatusTarjeta  CHAR (3) ;
DEFINE vsFechaTran CHAR (12) ;
DEFINE vsFechaTar CHAR (12) ;
DEFINE vsfechalocaltransaccion CHAR (4) ;

DEFINE viSectrancon INT ;   
DEFINE vsNombreComercio     CHAR (30) ;
--DEFINE viRetorno INTEGER ;
    
DEFINE visqlerr   INTEGER ;
 
/* INICIALIZACION DE VARIABLES */
LET vsSalida = '' ;    

LET visqlerr = 0 ;

LET vsCodStatusTarjeta = '' ;
LET vsFechaTran = '' ;
LET vsFechaTar = '' ;
LET vsfechalocaltransaccion = '' ;
    
LET vsNombreComercio     = '' ;
LET viSectrancon  = 0 ;
    
BEGIN       
        --TOMA Y ACTUALIZA LA SECUECIA CORESPONDIENTE PARA LA TRANSACCION ACTUAL DEL CAMPO SECTRANCON

    LET vsSalida  = 'PROCEDURE sp_InsertaMovConciliados -- PROCEDURE sp_GetSecuenciaTrancon()' ;
    EXECUTE PROCEDURE sp_GetSecuenciaTrancon() INTO viSectrancon, vsSalida ;

        --Error reportado por Mario Ducklaud. El archivo POS de PROSA (325)
        --puede contener el caracter (') dentro del nombre del Comercio. Se
        --valida esta situacion con las siguientes lineas de codigo.
        LET  vsNombreComercio = REPLACE ( psnombrecomercio, "'", ' ' ) ;
        LET vsfechalocaltransaccion = SUBSTRING ( psfechalocaltransaccion FROM 3 FOR 2 ) || SUBSTRING ( psfechalocaltransaccion FROM 1 FOR 2 ) ;

     LET vsSalida = 'INSERT INTO MovConciliados ( claveautdetransaccion, codigoiso, codrespbase24, codret, codretsurcharge, codreversa, codtran , '
        || 'esconvenio, espropio, fechaapllib, fechadeconciliacion, fechadereportebre, fechadetransaccion, fechahorainauth, fechalocaltransaccion, formato, '
        || 'fuenteid, horadetransaccion, horalocaltransaccion, idcomercio, idreceptor, montocashback, montocomcashback, montocomisioncobrada, '
        || 'montodetransaccion, montorealrevfzda, montoretenido, montosurcharge, movreversado, nacint, nombrecomercio, numctachequesafectada, '
        || 'numerotarjeta, prodind, referencia, reftransaccion, registrado, rfc, secenviadacentral, secsurcharge, sectrancon, secuenciacashback, '
        || 'secuenciacomcashback, secuenciacomision, statconsurcharge, statuscentral, statuscomision, statusdeconciliacion, statustarjeta, '
        || 'tipoenviadacentral, tipomovimiento, tiporecibidacentral, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual ) VALUES ( "' 
        || NVL(psclaveautdetransaccion, ' ' )  || '", "' || NVL(pscodigoiso, ' ') || '", "' || NVL(pscodrespbase24, ' ') || '", "' 
        || NVL(pscodret, ' ') || '", "'|| NVL(pscodretsurcharge, ' ') || '", "' || NVL(pscodreversa, ' ') || '", "' 
        || NVL(pscodtran, ' ') || '", "' || NVL(psesconvenio, ' ') || '", "' || NVL(psespropio, ' ') || '", '
        || NVL(pdtfechaapllib, 'NULL' ) || ', "' || NVL(psfechadeconciliacion, ' ') || '", ' || NVL(pdtfechadereportebre, 'NULL') || ', "' 
        || NVL(psfechadetransaccion, ' ') || '", ' || NVL(pdtfechahorainauth, 'NULL') || ', "'
        || NVL(psfechalocaltransaccion, ' ') || '", "' || NVL(psformato, ' ') || '", "' || NVL(psfuenteid, ' ') || '", "' 
        || NVL(pshoradetransaccion, ' ') || '", "' || NVL(pshoralocaltransaccion, ' ') || '", "'
        || NVL(psidcomercio, ' ') || '", "' || NVL(psidreceptor, ' ') || '", ' || REPLACE (NVL(pmmontocashback, 0), '$', ' ' ) || ', ' 
        || REPLACE ( NVL(pmmontocomcashback, 0), '$', ' ' ) || ', ' || REPLACE ( NVL(pmmontocomisioncobrada, 0), '$', ' ') || ', ' 
        || REPLACE (NVL(pmmontodetransaccion, 0), '$', ' ' ) || ', ' || REPLACE ( NVL(pmmontorealrevfzda, 0), '$', ' ' ) || ', ' 
        || REPLACE (NVL(pmmontoretenido, 0), '$', ' ' ) || ', ' || REPLACE ( NVL(pmmontosurcharge, 0), '$', ' ' ) || ', "' 
        || NVL(psmovreversado, 'F') || '", "' || NVL(psnacint, 'F' ) || '", "' || NVL(vsNombreComercio, ' ') ||  '", "'
        || NVL(psnumctachequesafectada, ' ') ||  '", "' || NVL(psnumerotarjeta, ' ') ||  '", "'
        || NVL(psprodind, ' ') ||  '", "' || NVL(psreferencia, ' ') ||  '", "' || NVL(psreftransaccion, ' ') ||  '", "'
        || NVL(psregistrado, ' ') ||  '", "' || NVL(psrfc, ' ') ||  '", "' || NVL(pssecenviadacentral, ' ') || '", "'
        || NVL(pssecsurcharge, ' ') ||  '", ' || NVL(viSectrancon, 0 ) ||  ', "' || NVL(pssecuenciacashback, ' ') ||  '", "'
        || NVL(pssecuenciacomcashback, ' ') ||  '", "' || NVL(pssecuenciacomision, ' ') ||  '", '
        || NVL(pistatconsurcharge, 0) || ', "'  || NVL(psstatuscentral, ' ') || '", "'
        || NVL(psstatuscomision, ' ') || '", '|| NVL(pistatusdeconciliacion, 0) || ', "' 
        || NVL(psstatustarjeta, ' ') || '", "' || NVL(pstipoenviadacentral, ' ') || '", "'
        || NVL(pstipomovimiento, ' ') || '", "' || NVL(pstiporecibidacentral, ' ') || '", "'
        || NVL(pstnrcobrocomisionctaindividual, ' ') || '", ' 
        || REPLACE ( NVL(pmtnrmontocomisionctaindividual, 0 ), '$', ' ' ) || ' ) ;'  ;

        INSERT INTO MovConciliados ( 
        claveautdetransaccion, codigoiso, codrespbase24, codret, codretsurcharge, codreversa, codtran , esconvenio,/* */ espropio, fechaapllib, 
        fechadeconciliacion, fechadereportebre, fechadetransaccion, fechahorainauth, fechalocaltransaccion, formato, fuenteid, horadetransaccion, 
        horalocaltransaccion, idcomercio, idreceptor, montocashback, montocomcashback, montocomisioncobrada, montodetransaccion, 
        montorealrevfzda, montoretenido, montosurcharge, movreversado, nacint, nombrecomercio, numctachequesafectada, numerotarjeta,
        prodind, referencia, reftransaccion, registrado, rfc, secenviadacentral, secsurcharge, sectrancon, secuenciacashback, secuenciacomcashback,     
        secuenciacomision, statconsurcharge, statuscentral, statuscomision, statusdeconciliacion, statustarjeta, tipoenviadacentral, tipomovimiento, 
        tiporecibidacentral, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual)
        VALUES (
            psclaveautdetransaccion, 
            pscodigoiso ,
            pscodrespbase24 ,
            pscodret ,
            pscodretsurcharge ,
            pscodreversa ,
            pscodtran ,
            psesconvenio ,  
            psespropio ,
            pdtfechaapllib ,
            psfechadeconciliacion ,
            pdtfechadereportebre ,
            psfechadetransaccion , 
            pdtfechahorainauth ,
            vsfechalocaltransaccion, 
            psformato ,
            psfuenteid ,
            pshoradetransaccion ,
            pshoralocaltransaccion ,
            psidcomercio ,
            psidreceptor ,
            pmmontocashback ,
            pmmontocomcashback ,
            pmmontocomisioncobrada ,
            pmmontodetransaccion ,
            pmmontorealrevfzda ,
            pmmontoretenido ,
            pmmontosurcharge ,
            psmovreversado ,
            psnacint ,
            vsNombreComercio ,
            psnumctachequesafectada ,
            psnumerotarjeta ,
            psprodind ,
            psreferencia ,
            psreftransaccion ,
            psregistrado ,
            psrfc ,
            pssecenviadacentral ,
            pssecsurcharge ,
            viSectrancon ,
            pssecuenciacashback ,
            pssecuenciacomcashback ,
            pssecuenciacomision ,
            pistatconsurcharge ,
            psstatuscentral ,
            psstatuscomision ,
            pistatusdeconciliacion ,
            psstatustarjeta ,
            pstipoenviadacentral ,
            pstipomovimiento ,
            pstiporecibidacentral ,
            pstnrcobrocomisionctaindividual ,
            pmtnrmontocomisionctaindividual ) ;
        
  

    RETURN vsSalida  ;

END 

END PROCEDURE 



;
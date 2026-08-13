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
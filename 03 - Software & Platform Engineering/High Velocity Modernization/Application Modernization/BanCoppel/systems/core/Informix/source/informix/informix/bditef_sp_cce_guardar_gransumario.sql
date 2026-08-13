CREATE PROCEDURE "informix".sp_cce_guardar_gransumario
(
pNumArchivo			CHAR(22), 
pTipoRegistro		CHAR(2), 
pSentido			CHAR(1), 
pCodOperacion		CHAR(2), 
pNumOperaciones		CHAR(7), 
pNumBloques			CHAR(2), 
pNroBanco			CHAR(3), 
pFolio				CHAR(9), 
pFecha				CHAR(8), 
pImporteTotal		DECIMAL(19,2),
pTotRegTruncIMG		CHAR(7)
) 
RETURNING
	CHAR(6) 		AS cod_ret;
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_guardar_gransumario.out';
--	TRACE ON;


	INSERT INTO bditef:cce_gransumario 
	(nombrearchivo, tipo_registro, sentido, cod_operacion, num_operaciones, num_bloques, num_banco, folio,fecha, importe_total, total_reg_ti) 
	VALUES
	(
	pNumArchivo, 
	pTipoRegistro, 
	pSentido, 
	pCodOperacion, 
	pNumOperaciones, 
	pNumBloques, 
	pNroBanco, 
	pFolio, 
	pFecha, 
	pImporteTotal, 
	pTotRegTruncIMG
	);
		
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que guarda datos del gran sumario para código 40, 46 y 47',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_cce_guardar_sumario
(
pNomArchivo 		CHAR(22), 
pTipoRegistro		CHAR(2), 
pNumSecuencia		CHAR(7), 
pCodOperacion		CHAR(2), 
pTotRegs			CHAR(7), 
pImporte			DECIMAL(19,2), 
pTotRegTrunImg		CHAR(7)
) 
RETURNING
	CHAR(6) 		AS cod_ret;
	
	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
--	SET DEBUG FILE TO '/respaldosbd/has/sp_cce_guardar_sumario.out';
--	TRACE ON;


	INSERT INTO bditef:cce_sumario 
	(
	nombrearchivo, tipo_registro, num_bloque, num_secuencia, cod_operacion, total_registros, importe, total_reg_trunc)
	VALUES
	(
	pNomArchivo, pTipoRegistro, "00001", pNumSecuencia, pCodOperacion, pTotRegs, pImporte, pTotRegTrunImg
	);

		
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que guarda datos del sumario para código 40, 46 y 47',
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

create procedure "informix".cons_dir_cte( pcliente char(20), pnum_regs smallint )
RETURNING char(5), char(30), char(10), char(10), char(6), char(30), char(60), char(30), char(80),
          char(40), char(5), char(13), char(13), char(13), char(10), char(10), char(10);
    
    DEFINE v_codret         char(5);
    DEFINE v_calle		    char(30);
    DEFINE v_numext	    	char(10);
    DEFINE v_numint       	char(10);
    DEFINE v_depto	      	char(6);
    DEFINE v_colonia       	char(30);
    DEFINE v_ciudad	     	char(60);
    DEFINE v_estado	   	    char(30);
    DEFINE v_obs	   	    char(80);   
    DEFINE v_entrecalles   	char(40);   
    DEFINE v_cp	   	        char(5);   
    DEFINE v_tel1   	    char(13);   
    DEFINE v_tel2   	    char(13);   
    DEFINE v_tel3   	    char(13);   
    DEFINE v_ext 	  	    char(10);
    DEFINE v_tpdir 	  	    char(1);
    DEFINE v_tipodir  	    char(10);
    DEFINE v_fechacap  	    char(10);
    DEFINE v_contador       smallint;
    DEFINE sql_err          int;    
    DEFINE isam_err         int;   
    
    LET v_codret = "000";
    LET v_calle  = '  ';
    LET v_numext = '';
    LET v_numint = ' ';
    LET v_depto	 = ' ';
    LET v_colonia = ' ';
    LET v_ciudad = ' ';
    LET v_estado = ' ';
    LET v_obs = ' ';
    LET v_entrecalles = ' ';
    LET v_cp = ' ';
    LET v_tel1 = ' ';
    LET v_tel2 = ' ';
    LET v_tel3 = ' ';
    LET v_ext = ' ';
    LET v_tpdir = ' ';
    LET v_tipodir = ' ';
    LET v_fechacap = ' ';
    LET v_contador = 0;
    LET sql_err = 0;
    LET isam_err = 0;
    
    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, v_obs,
                   v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
        end if;
    end exception;
    
    -- // Valida la informacion de entrada
    IF pcliente is null then
        LET v_codret = 110; 
        RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, v_obs,
               v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // direcciones completas del cliente
    FOREACH
        select cal.nombrecalle as calle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zon.nombrezona as colonia,
               nvl(cds.nombre," ") as cd, edo.nombre as edo, dir.observaciones, dir.entre_calles, dir.cod_postal,
               tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension,
               dir.fecha_insert, decode(dir.tipo_dir, '1', 'Particular', '2', 'Oficina')
          into v_calle, v_numext, v_numint, v_depto, v_colonia,
               v_ciudad, v_estado, v_obs, v_entrecalles, v_cp,
               v_tel1, v_tel2, v_tel3, v_ext,
               v_fechacap, v_tipodir
          from bdinteg:si_direcciones dir
          left outer join bdinteg:si_estados edo on(edo.estado=dir.estado)
          left outer join bdinteg:si_ciudades cds on(cds.ciudad=dir.ciudad and cds.estado = dir.estado and cds.pais = 1)
          left outer join bdinteg:si_catzonas zon on (zon.numerociudad=dir.numerociudad and zon.numerocolonia = dir.numerocolonia)
          left outer join bdinteg:si_catcalles cal on(cal.numerocalle=dir.numerocalle)
          left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = dir.numcte and tel1.tipo_tel = 1)
          left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = dir.numcte and tel2.tipo_tel = 2)
          left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = dir.numcte and tel3.tipo_tel = 3)
         where dir.numcte = pcliente
         order by dir.secuencia 
        
        LET v_contador = v_contador + 1;
        
        IF v_contador < pnum_regs then
            CONTINUE FOREACH;
        END IF;    
        
        RETURN v_codret, v_calle, v_numext, v_numint, v_depto, v_colonia, v_ciudad, v_estado, v_obs,
               v_entrecalles, v_cp, v_tel1, v_tel2, v_tel3, v_ext, v_fechacap, v_tipodir WITH resume;
    END FOREACH		
    
    END; 
    
END PROCEDURE;
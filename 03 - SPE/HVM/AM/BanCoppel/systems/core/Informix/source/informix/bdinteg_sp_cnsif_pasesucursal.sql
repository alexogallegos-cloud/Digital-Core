CREATE PROCEDURE "informix".sp_cnsif_pasesucursal(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10), Num_Sucursal CHAR (4))
							
				returning CHAR(5)  AS Cod_Retorno,
				          CHAR(3)  AS Id_Plaza,
                          CHAR(4)  AS No_Sucursal,
						  CHAR(40) AS Nom_Sucursal,
						  CHAR(40) AS Gte_Sucursal,
						  CHAR(14) AS Tel_Sucursal,
						  CHAR (8) AS Estat_Suc;
										
DEFINE cCodRet          CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE Id_Plaza         CHAR(3);
DEFINE No_Sucursal      CHAR(4);
DEFINE Nom_Sucursal     CHAR(40);
DEFINE Gte_Sucursal     CHAR(40);
DEFINE Tel_Sucursal     CHAR(14);
DEFINE Estat_Suc		CHAR(8);
DEFINE fechadia			DATE;
DEFINE Flag_abrio		INTEGER;
DEFINE Flag_cerro		INTEGER;

DEFINE cCodRetPtf varchar(5); 
DEFINE cIdptf varchar(5); 
DEFINE cTipos varchar(1); 
DEFINE cClavesit char(3); 
DEFINE cFechasit date; 
DEFINE cCalles varchar(100); 
DEFINE cNumext varchar(6); 
DEFINE cNumint varchar(5); 
DEFINE cCvecol char(8); 
DEFINE cColonias varchar(100); 
DEFINE cCvemun char(5); 
DEFINE cMunicipio varchar(60); 
DEFINE cVelocalidades char(14); 
DEFINE cLocalidades varchar(60); 
DEFINE cCps char(5);                     
DEFINE cCiudades char(3); 
DEFINE cEstados INTEGER; 
DEFINE cLatitudes varchar(10); 
DEFINE cLongitudes varchar(11); 
DEFINE cTels1 varchar(14); 
DEFINE cTels2 varchar(14); 


	    --SET DEBUG FILE TO "/informix/VILLELA/sp_cnsif_pasesucursal.out";
		--TRACE ON;

--inicializando variables
LET cCodRet 	    = "00000";
LET iSql_err 	    =  0;
LET Id_Plaza 	    =  '';
LET No_Sucursal     = '0000';
LET Nom_Sucursal    =  '';
LET Gte_Sucursal    =  '';
LET Tel_Sucursal    =  '';
LET Estat_Suc		=  '';
LET fechadia	    = '01-01-1900';
LET Flag_abrio	    = 0;
LET Flag_cerro 	    = 0;

LET cCodRetPtf = '';
LET cIdptf = ''; 
LET cTipos = ''; 
LET cClavesit = ''; 
LET cFechasit = ''; 
LET cCalles = ''; 
LET cNumext = ''; 
LET cNumint = ''; 
LET cCvecol = ''; 
LET cColonias = ''; 
LET cCvemun = ''; 
LET cMunicipio = ''; 
LET cVelocalidades = ''; 
LET cLocalidades = ''; 
LET cCps = ''; 		
LET cCiudades = ''; 
LET cEstados = 0; 
LET cLatitudes = ''; 
LET cLongitudes = ''; 
LET cTels1 = ''; 
LET cTels2 = ''; 

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, Id_Plaza, Num_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
		END IF;
	END EXCEPTION;

	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_monitorsucursales.out";
	--  TRACE ON;

	SET LOCK MODE TO WAIT 3;
	
    IF 	cID_USUARIOC = '' 	OR
        cID_FUNCIONC = '' 	OR
        Num_Sucursal = ''   THEN 
            LET cCodRet = "00054";
            RETURN cCodRet, Id_Plaza, Num_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
    END IF;	

 	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = "00028" THEN 
		RETURN cCodRet, Id_Plaza, Num_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
	END IF;	
	
	EXECUTE FUNCTION bdinteg:"informix".sp_si_ptf(Num_Sucursal) 
	INTO 
	cCodRetPtf, cIdptf, cTipos, cClavesit, cFechasit, cCalles, cNumext, cNumint, cCvecol, cColonias, cCvemun, cMunicipio, 
	cVelocalidades, cLocalidades, cCps, cCiudades, cEstados, cLatitudes, cLongitudes, cTels1, cTels2;   
	
	SELECT fecha_hoy INTO fechadia
	FROM bdinteg:"informix".si_fechas;	
	
	SET ISOLATION TO DIRTY READ;
	SELECT 
	C.plaza, cIdptf, C.nombre, C.gerente, A.tel1, 
	B.suc_abrio, B.suc_cerro
	INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Flag_abrio, Flag_cerro
	FROM bdinteg:si_ptf A, 
	bdisuc:ss_pase_sucursal B,
     bdinteg: si_sucursales C
	WHERE B.fecha_pase =  fechadia   
	AND TRIM (A.id_ptf) = Num_Sucursal
	AND TRIM (B.sucursal) = TRIM (A.id_ptf)
    AND A.id_ptf = C.sucursal
    AND A.tipo=C.tipo;

	/*SET ISOLATION TO DIRTY READ;
	SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)}
	A.plaza, cIdptf, A.nombre, A.gerente, cTels1, 
	B.suc_abrio, B.suc_cerro
	INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Flag_abrio, Flag_cerro
	FROM bdinteg:si_sucursales A, 
	bdisuc:ss_pase_sucursal B
	WHERE B.fecha_pase = fechadia 
	AND TRIM (A.sucursal) = Num_Sucursal 
	AND TRIM (B.sucursal) = TRIM (A.sucursal);*/

	
    IF Id_Plaza IS NULL OR Id_Plaza='' THEN
        LET cCodRet = "00105";
        RETURN cCodRet, Id_Plaza, Num_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
    END IF;
	IF Flag_abrio = '1' AND Flag_cerro = '0' THEN 
        LET Estat_Suc = 'ABIERTA';
	ELSE
        IF Flag_abrio = '1' AND Flag_cerro = '1' THEN 
            LET Estat_Suc = 'CERRADA';
        ELSE
            LET Estat_Suc = '';
        END IF;
	END IF;
	RETURN cCodRet, Id_Plaza, Num_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc;
END
END PROCEDURE
DOCUMENT
"Autor: frg",
"FUNCIONAMIENTO: Consulta detalle de Sucursales de acuerdo a criterios (Numero de Sucursal).",
"FECHA : 18-07-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_quitar_acentos (cadena lvarchar) 
RETURNING lvarchar;

--DefiniciÃ³n de Variables 
 DEFINE s_cadena lvarchar;
 DEFINE s_cadena2 lvarchar;
 DEFINE s_cadena_total lvarchar;
 DEFINE s_cadena_tam int;
 DEFINE s_long_cadena int;
 DEFINE s_ascii INTEGER;

 --Asignacion Inicial
 LET s_cadena = '';
 LET s_cadena2 = '';
 LET s_cadena_tam = 0;
 LET s_long_cadena = 1;
 LET s_ascii = 0; 
 LET s_cadena = cadena;
 LET s_cadena_total = '';
 
 BEGIN

 SET ISOLATION TO DIRTY READ;
 SET LOCK MODE TO WAIT 3;
 
IF (NVL(s_cadena,'') <> '') THEN
  LET s_cadena_tam = LENGTH(s_cadena);
    --Ciclo de AnÃ¡lisis
  WHILE (s_long_cadena <= s_cadena_tam)
   LET s_cadena2 = SUBSTR(s_cadena,s_long_cadena,1);
   LET s_ascii = ASCII(s_cadena2);
    IF s_ascii BETWEEN 65 AND 90 OR s_ascii BETWEEN 97 AND 122 THEN
     LET s_long_cadena = ( s_long_cadena + 1);
     LET s_cadena_total = s_cadena_total || s_cadena2;
    ELSE
     IF(s_ascii BETWEEN 224 AND 229) THEN 
      LET s_cadena2 = 'a';
       LET s_long_cadena = ( s_long_cadena + 1);
       LET s_cadena_total = s_cadena_total || s_cadena2;
      ELSE 
       IF(s_ascii BETWEEN 192 AND 197) THEN 
        LET s_cadena2 = 'A';
        LET s_long_cadena = ( s_long_cadena + 1);
        LET s_cadena_total = s_cadena_total || s_cadena2;
       ELSE
        IF(s_ascii BETWEEN 232 AND 235) THEN 
         LET s_cadena2 = 'e';
         LET s_long_cadena = ( s_long_cadena + 1);
         LET s_cadena_total = s_cadena_total || s_cadena2;
        ELSE 
         IF(s_ascii BETWEEN 200 AND 203) THEN 
          LET s_cadena2 = 'E';
          LET s_long_cadena = ( s_long_cadena + 1);
          LET s_cadena_total = s_cadena_total || s_cadena2;
         ELSE
          IF(s_ascii BETWEEN 236 AND 239) THEN 
           LET s_cadena2 = 'i';
           LET s_long_cadena = ( s_long_cadena + 1);
           LET s_cadena_total = s_cadena_total || s_cadena2;
          ELSE 
           IF(s_ascii BETWEEN 204 AND 207) THEN 
            LET s_cadena2 = 'I';
            LET s_long_cadena = ( s_long_cadena + 1);
            LET s_cadena_total = s_cadena_total || s_cadena2;
           ELSE
            IF(s_ascii BETWEEN 242 AND 246)THEN 
             LET s_cadena2 = 'o';
             LET s_long_cadena = ( s_long_cadena + 1);
             LET s_cadena_total = s_cadena_total || s_cadena2;
            ELSE 
             IF(s_ascii BETWEEN 210 AND 214) THEN 
              LET s_cadena2 = 'O';
              LET s_long_cadena = ( s_long_cadena + 1);
              LET s_cadena_total = s_cadena_total || s_cadena2;
             ELSE
              IF(s_ascii BETWEEN 249 AND 252)THEN 
               LET s_cadena2 = 'u';
               LET s_long_cadena = ( s_long_cadena + 1);
               LET s_cadena_total = s_cadena_total || s_cadena2;
              ELSE 
               IF(s_ascii BETWEEN 217 AND 220) THEN 
                LET s_cadena2 = 'U';
                LET s_long_cadena = ( s_long_cadena + 1);
                LET s_cadena_total = s_cadena_total || s_cadena2;
               ELSE
                IF s_ascii = 209 THEN 
                 LET s_cadena2 = 'N';
                 LET s_long_cadena = ( s_long_cadena + 1);
                 LET s_cadena_total = s_cadena_total || s_cadena2;
                ELSE 
                 IF s_ascii = 241 THEN 
                  LET s_cadena2 = 'n';
                  LET s_long_cadena = ( s_long_cadena + 1);
                  LET s_cadena_total = s_cadena_total || s_cadena2;
                 ELSE 
                  IF s_ascii = 199 THEN 
                   LET s_cadena2 = 'C';
                   LET s_long_cadena = ( s_long_cadena + 1);
                   LET s_cadena_total = s_cadena_total || s_cadena2;
                  ELSE
                   IF s_ascii = 231 THEN 
                    LET s_cadena2 = 'c';
                    LET s_long_cadena = ( s_long_cadena + 1);
                    LET s_cadena_total = s_cadena_total || s_cadena2;
                   ELSE 
                    IF s_ascii = 221 or s_ascii = 159 THEN 
                     LET s_cadena2 = 'Y';
                     LET s_long_cadena = ( s_long_cadena + 1);
                     LET s_cadena_total = s_cadena_total || s_cadena2;
                    ELSE
                     IF s_ascii = 142 THEN 
                      LET s_cadena2 = 'Z';
                      LET s_long_cadena = ( s_long_cadena + 1);
                      LET s_cadena_total = s_cadena_total || s_cadena2;
                     ELSE
                      IF s_ascii = 158 THEN 
                       LET s_cadena2 = 'z';
                       LET s_long_cadena = ( s_long_cadena + 1);
                       LET s_cadena_total = s_cadena_total || s_cadena2;
                      ELSE
                       IF s_ascii = 138 THEN 
                        LET s_cadena2 = 'S';
                        LET s_long_cadena = ( s_long_cadena + 1);
                        LET s_cadena_total = s_cadena_total || s_cadena2;
                       ELSE
                        IF s_ascii = 154 THEN 
                         LET s_cadena2 = 's';
                         LET s_long_cadena = ( s_long_cadena + 1);
                         LET s_cadena_total = s_cadena_total || s_cadena2;
                         ELSE 
						  --2018-09-21: GM3 PDRH Ini.- Anexo de cÃ³digo para ASCII 32 
                          IF s_ascii = 32 THEN
                           LET s_cadena2 = ' ';
                           LET s_long_cadena = ( s_long_cadena + 1);
                           LET s_cadena_total = s_cadena_total || s_cadena2;
						 --2018-09-21: Fin GM3 PDRH.
						 ELSE
                          LET s_cadena2 = '';
                          LET s_long_cadena = ( s_long_cadena + 1);
                         END IF;
						END IF 
                       END IF;
                      END IF;
                     END IF;
                    END IF;
                   END IF; 
                  END IF;
                 END IF;
                END IF;
               END IF;
              END IF;
             END IF;
            END IF;
           END IF;
          END IF;
         END IF;
        END IF;
       END IF;
      END IF; 
     END IF; 
    END WHILE;
   END IF;
  RETURN s_cadena_total;
 END;  

END PROCEDURE
DOCUMENT
'CREADO POR: PATRICIA DEL RAZO',
'FECHA DE CREACION: 21 DE DICIEMBRE DEL 2017',
'OBJETIVO: SE CREA PROCESO PARA QUITAR CARACTERES ESPECIALES',
'		   NO SE MANEJAN CODIGOS DE RETORNO POR QUE SOLO SE ',
'		   NECECITA REGRESAR LA CADENA SIN CARACTERES ESPECIALES',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consultarcatsucur_3(p_sEmpresa CHAR(3), p_sSucursal CHAR(4), p_sTipoSucursal CHAR(2))
    RETURNING       CHAR(6) AS retorno,
                            CHAR(3) AS empresa,
                            CHAR(4) AS sucursal,
                            CHAR(40) AS nombre,
                            CHAR(40) AS direccion1,
                            CHAR(40) AS direccion2,
                            CHAR(14) AS telefono,
                            CHAR(40) AS gerente,
                            CHAR(40) AS subgerente,
                            CHAR(2) AS tpo_sucursal;

    DEFINE iSqlErr                  INTEGER;
    DEFINE v_sValRetorno    CHAR(6);
    DEFINE v_sEmpresa               CHAR(3);
    DEFINE v_sSucursal              CHAR(4);
    DEFINE v_sNombre                CHAR(40);
    DEFINE v_sDireccion1    CHAR(40);
    DEFINE v_sDireccion2    CHAR(40);
    DEFINE v_sTelefono1             CHAR(14);
    DEFINE v_sGerente               CHAR(40);
    DEFINE v_sSubgerente    CHAR(40);
    DEFINE v_sTipo_sucursal CHAR(2);

    LET v_sValRetorno = '000001';

    BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                        RETURN iSqlErr,'','','','','','','','','';
                END IF;
        END EXCEPTION;

		--SET DEBUG FILE TO "/informix/VILLELA/sp_generarchivo_cecoban.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

        --DEBE PROPORCIONARSE LA EMPRESA
        IF NVL(p_sEmpresa,'') = '' THEN
                RETURN v_sValRetorno,'','','','','','','','','';
        END IF;

        IF p_sSucursal = '' THEN
                LET p_sSucursal = NULL;
        END IF;

        IF p_sTipoSucursal = '' THEN
                LET p_sTipoSucursal = NULL;
        END IF;

        FOREACH
				
		    ---SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} suc.empresa, ptf.id_ptf, suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1,
		    SELECT suc.empresa, ptf.id_ptf, suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1,
			(select 'COL. '||loc.desc_colonia||' C.P. '||loc.cp 
			 from  bdinteg: si_localidades loc
			where loc.cve_localidad_cnbv=ptf.cve_localidad
			and   loc.cve_estado= ptf.cve_estado
			and   loc.cve_mun=ptf.cve_mun
			and   loc.cve_col=ptf.cve_col) as direccion2,
			 ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
			 INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
			  FROM bdinteg: si_ptf ptf,
				   bdinteg:si_sucursales  suc
			 WHERE ptf.id_ptf=suc.sucursal
			 and   ptf.tipo=suc.tipo
			and ptf.id_ptf = NVL(p_sSucursal, ptf.id_ptf) 
			AND suc.tpo_sucursal = NVL(p_sTipoSucursal,suc.tpo_sucursal)
			AND empresa = p_sEmpresa 
			ORDER BY ptf.id_ptf
		
              /*  SELECT empresa, sucursal, nombre, direccion1, direccion2, telefono1, gerente, subger, tpo_sucursal
                INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
                FROM bdinteg:si_sucursales
                WHERE sucursal = NVL(p_sSucursal, sucursal) 
                  AND empresa = p_sEmpresa 
                  AND tpo_sucursal = NVL(p_sTipoSucursal,tpo_sucursal)
                  ORDER BY sucursal*/
				  
                LET p_sTipoSucursal = p_sTipoSucursal;
                LET v_sValRetorno = '000000';

                RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente,
                v_sTipo_sucursal WITH RESUME;
        END FOREACH;
    END;
END PROCEDURE;
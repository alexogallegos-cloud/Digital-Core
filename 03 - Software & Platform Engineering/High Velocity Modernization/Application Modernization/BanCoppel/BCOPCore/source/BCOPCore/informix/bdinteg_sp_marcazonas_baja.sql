CREATE PROCEDURE "informix".sp_marcazonas_baja(p_Usuario   CHAR(8))
RETURNING CHAR(5) AS Cod_Ret;
---------------------------------------------------------------------------------------------------------------------------------
--DECLARACIONES
DEFINE v_cod_ret				CHAR(5);
DEFINE iSqlErr					INTEGER;
DEFINE iSamErr					INTEGER;
DEFINE s_DescCiudad				CHAR(100);
DEFINE p_FechaHoy				DATE;
DEFINE i_CveEstado				INTEGER;
DEFINE i_CiudadCoppel			INTEGER;
DEFINE s_BandExisteSimilar		CHAR(1);
DEFINE i_CveEstadoAnte			INTEGER;

DEFINE s_Asenta					CHAR(60);
DEFINE i_NumColonia				INTEGER;
DEFINE s_CodigoPostal			CHAR(5);
DEFINE s_TipoAsenta				CHAR(25);
DEFINE s_Municipio				CHAR(40);
DEFINE s_MarcaUniHab			CHAR(1);
DEFINE i_NvaColonia				INTEGER;

DEFINE maxColonia               INTEGER;

DEFINE cEmpresa                 CHAR(3);
DEFINE iRegistros               INTEGER;
DEFINE iIdRegistro				INTEGER;

DEFINE cPobZona					CHAR(27);
DEFINE cMunZona					CHAR(27);
DEFINE cNombreZona				CHAR(32);
DEFINE iCodPst					INTEGER;
DEFINE cCiudad					CHAR(100);
DEFINE cMunicipio				CHAR(40);
DEFINE iNumCiudad				INTEGER;
DEFINE cNomCol					CHAR(60);
DEFINE cNombreProceso           CHAR(30);
DEFINE vMensaje  	            CHAR(80);
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE c_Cve_estado             CHAR(2);
DEFINE c_CodPst                 CHAR(5); 

DEFINE c_nomzona_spmx           CHAR(60);
DEFINE c_pobzona_spmx           CHAR(100);
DEFINE c_mnpio_spmx             CHAR(50);
DEFINE i_d_codigo               INTEGER;
DEFINE i_Result_1               INTEGER;
DEFINE v_fechamax_ejec          DATE;
DEFINE v_fecha_baja             DATE;
DEFINE i_Cont_upd_baja          INTEGER;
DEFINE i_cont_spmx              INTEGER;
DEFINE v_f_inserta              DATE;
DEFINE c_Usuario                CHAR(8);

-----------------------------------------------------------------------------------------------------------------------------------------------------------
--INICIALIZACIONES	
LET v_cod_ret				    = "00000";
LET iSqlErr					    = 0;
LET iSamErr					    = 0;
LET s_DescCiudad			    = "";
LET p_FechaHoy				    = DATE(1);
LET i_CveEstado				    = 0;
LET i_CiudadCoppel			    = 0;
LET s_BandExisteSimilar		    = "F";
LET i_CveEstadoAnte			    = 0;
LET s_Asenta				    = "";
LET i_NumColonia			    = 0;
LET s_CodigoPostal			    = "";
LET s_TipoAsenta			    = "";
LET s_Municipio				    = "";
LET s_MarcaUniHab			    = "";
LET i_NvaColonia			    = 0;
LET maxColonia                  = 0;
LET cEmpresa                    = "001";
LET iRegistros                  = 0;
LET cPobZona					= "";
LET cMunZona					= "";
LET cNombreZona					= "";
LET iCodPst						= 0;
LET cCiudad						= "";
LET cMunicipio					= "";
LET iNumCiudad					= 0;
LET cNomCol						= "";
LET cNombreProceso              = 'MARCA ZONAS BAJA';
LET vMensaje                    = ''; 
LET ERROR_INFO                  = '';
LET c_Cve_estado                = '';
LET c_CodPst                    = '';
LET c_nomzona_spmx              = '';
LET c_pobzona_spmx              = ''; 
LET c_mnpio_spmx                = ''; 
LET i_d_codigo                  = 0;
LET i_Result_1                  = 0;
LET v_fechamax_ejec             = DATE(1);
LET v_fecha_baja                = DATE(1);
LET i_Cont_upd_baja             = 0;
LET i_cont_spmx                 = 0;
LET v_f_inserta                 = DATE(1);
LET c_Usuario                   = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET pdqpriority 20;

BEGIN

ON EXCEPTION SET iSqlErr, iSamErr, ERROR_INFO
    LET v_cod_ret = iSqlErr;
	LET vMensaje  = iSamErr || '-' || ERROR_INFO;
	
	INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
              VALUES(cNombreProceso, v_cod_ret, vMensaje, 0 ,user, p_FechaHoy,
              (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
	
    RETURN v_cod_ret;
END EXCEPTION;


 --SET DEBUG FILE TO "/ifxsif01/macf/sp_conciliar_colonias_sepomex.out";
 --TRACE ON;

   LET c_Usuario = p_Usuario;


 --OBTIENE LA FECHA DEL SISTEMA
 SELECT fecha_hoy
   INTO p_FechaHoy
   FROM si_fechas
  WHERE empresa = cEmpresa; 
 
  --LET p_FechaHoy = MDY('07','24','2022');  ---  SOLO TEST MACF
 
   SELECT max(fecha_ejecucion) into v_fechamax_ejec
    FROM bdinteg:si_catsepomex;
 
  LET iNumCiudad = 0;
  LET i_NumColonia = 0;
  LET iRegistros = 0;
  
  FOREACH WITH HOLD
		
			select a.estado, TRIM(a.d_ciudad) INTO c_Cve_estado, s_DescCiudad
			  from bdinteg:si_ciudades a
			       inner join bdinteg:si_catsepomex b on a.d_ciudad = b.d_ciudad and a.estado = b.c_estado
			 where a.ciudad_coppel > 0 
			    and a.elegir is null
			 group by 1,2 order by 1,2
  
            FOREACH WITH HOLD
			
			    SELECT a.numerociudad,  a.numerocolonia, a.nombrezona, a.poblacionzona, a.municipiozona,  TRIM(a.nomzona_spmx), TRIM(a.mnpio_spmx), TRIM(a.pobzona_spmx), a.codigopostalzona, a.f_inserta 
				  INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, c_nomzona_spmx, c_mnpio_spmx, c_pobzona_spmx, iCodPst, v_f_inserta
				  FROM bdinteg:si_catzonas a
				                  inner join bdinteg:si_ciudades b on a.numerociudad = b.ciudad_coppel and nvl(b.d_ciudad,'') <> '' and b.elegir is null
				   WHERE b.d_ciudad = s_DescCiudad
                     AND b.estado = c_Cve_estado
					 AND NVL(a.nomzona_spmx,'') <> '' AND NVL(a.mnpio_spmx,'') <> '' AND  NVL(a.pobzona_spmx,'') <> ''
  
                LET s_CodigoPostal = lpad(iCodPst,5,'0');
  
          IF c_Cve_estado <> '09' THEN
  
					SELECT count(*) INTO i_cont_spmx
					  FROM bdinteg:si_catsepomex
					 WHERE d_codigo = s_CodigoPostal
					   AND d_asenta = c_nomzona_spmx
					   AND d_ciudad = s_DescCiudad
					   AND d_mnpio = c_mnpio_spmx
					   AND c_estado = c_Cve_estado;

					IF i_cont_spmx <= 0 THEN
					
					   BEGIN;

						 UPDATE bdinteg:si_catzonas
							SET nomzona_spmx = null, mnpio_spmx = null, pobzona_spmx = null, fecha_baja = today, usr_modifica = c_Usuario
						  WHERE	numerociudad = iNumCiudad AND numerocolonia = i_NumColonia; 
						 
					   COMMIT;
								 
					END IF;

					LET i_cont_spmx = 0;
					LET s_CodigoPostal = '';
				ELSE

				   SELECT count(*) INTO i_cont_spmx
					  FROM bdinteg:si_catsepomex
					 WHERE d_codigo = s_CodigoPostal
					   AND d_asenta = c_nomzona_spmx
					   --AND d_ciudad = s_DescCiudad
					   AND d_mnpio = c_mnpio_spmx
					   AND c_estado = c_Cve_estado;

					IF i_cont_spmx <= 0 THEN
					
					   BEGIN;

						 UPDATE bdinteg:si_catzonas
							SET nomzona_spmx = null, mnpio_spmx = null, pobzona_spmx = null, fecha_baja = today, usr_modifica = c_Usuario
						  WHERE	numerociudad = iNumCiudad AND numerocolonia = i_NumColonia; 
						 
					   COMMIT;
								 
					END IF;

					LET i_cont_spmx = 0;
					LET s_CodigoPostal = '';
				
				END IF;
				
			END FOREACH;
  END FOREACH;				   
  
  RETURN v_cod_ret;
END
END PROCEDURE;
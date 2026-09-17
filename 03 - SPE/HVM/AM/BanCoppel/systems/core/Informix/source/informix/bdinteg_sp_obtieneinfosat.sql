CREATE PROCEDURE "informix".sp_obtieneinfosat()
    returning 	CHAR(5)  AS Cod_Retorno;

DEFINE Cod_Retorno          CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE cNUMCTE              CHAR(50);
DEFINE cNombre1             CHAR(26);
DEFINE cNombre2             CHAR(26);
DEFINE Nombre               CHAR(52);
DEFINE NombreComp           CHAR(52);
DEFINE cApell_paterno       CHAR(26);
DEFINE cApell_materno       CHAR(26);
DEFINE cRfc                 CHAR(50);
DEFINE cRfc_Alterno         CHAR(50);
DEFINE RFC_Act              CHAR(50);
DEFINE Fec_Act_RFC          DATE;
DEFINE dfecha_nac           DATE;
DEFINE cSexo                CHAR(50);
DEFINE vtipo_dir            CHAR(1);
DEFINE vsecuencia           INTEGER;
DEFINE vnumeroextcalle      CHAR(10);
DEFINE vnumerointcalle      CHAR(10);
DEFINE vdepartamento        CHAR(6);
DEFINE vcod_postal          CHAR(50);
DEFINE vnumcalle            INTEGER;
DEFINE vnumerociudad        SMALLINT;
DEFINE vnumerocolonia       INT;
DEFINE vCveCiudad           CHAR(3);
DEFINE vCveEstado           CHAR(3);
DEFINE vCvePais             CHAR(3);
DEFINE vcvemunicipio        CHAR(5);
DEFINE vcodrett             CHAR(5);
DEFINE vTelefono            CHAR(13);
DEFINE vTipoTel             SMALLINT;
DEFINE vSecuenciaTel        SMALLINT;
DEFINE vStatus_Tel          CHAR(1);
DEFINE vExtensionTel        CHAR(5);
DEFINE vCarrier             SMALLINT;
DEFINE vNombreCarrier       CHAR(20);
DEFINE StatusValidacion     SMALLINT;
DEFINE vtelefono1           CHAR(13);
DEFINE vtelefono2           CHAR(13);
DEFINE vtelefono3           CHAR(13);
DEFINE vextension           CHAR(5);
DEFINE vpais                CHAR(20);
DEFINE vestado              CHAR(30);
DEFINE vciudad              CHAR(60);
DEFINE vCdCoppel            SMALLINT;
DEFINE vcolonia             CHAR(60);
DEFINE vcalle               CHAR(60);
DEFINE vmunicipio           CHAR(60);
DEFINE vCurp                CHAR(50);
DEFINE vcodret              CHAR(5);
DEFINE email                CHAR(100);
DEFINE vtipocorreo          CHAR(5);
DEFINE vstatuscorreo        CHAR(5);
DEFINE ultcte		        CHAR(9);
DEFINE iContador            INTEGER;
DEFINE sCommit              SMALLINT;



LET Cod_Retorno          ="00000";
LET cNUMCTE              ="";
LET cNombre1             ="";
LET cNombre2             ="";
LET Nombre               ="";
LET NombreComp           ="";
LET cApell_paterno       ="";
LET cApell_materno       ="";
LET cRfc                 ="";
LET cRfc_Alterno         ="";
LET RFC_Act              ="";
LET Fec_Act_RFC          ="";
LET dfecha_nac           ="";
LET cSexo                ="";
LET vtipo_dir            ="";
LET vsecuencia           =0;
LET vnumeroextcalle      ="";
LET vnumerointcalle      ="";
LET vdepartamento        ="";
LET vcod_postal          ="";
LET vnumcalle            =0;
LET vnumerociudad        =0;
LET vnumerocolonia       =0;
LET vCveCiudad           ="";
LET vCveEstado           ="";
LET vCvePais             ="";
LET vcvemunicipio        ="";
LET vcodrett             ="";
LET vTelefono            ="";
LET vTipoTel             =0;
LET vSecuenciaTel        =0;
LET vStatus_Tel          ="";
LET vExtensionTel        ="";
LET vCarrier             =0;
LET vNombreCarrier       ="";
LET StatusValidacion     =0;
LET vtelefono1           ="";
LET vtelefono2           ="";
LET vtelefono3           ="";
LET vextension           ="";
LET vpais                ="";
LET vestado              ="";
LET vciudad              ="";
LET vCdCoppel            =0;
LET vcolonia             ="";
LET vcalle               ="";
LET vmunicipio           ="";
LET vCurp                ="";
LET vcodret              ="";
LET email                ="";
LET vtipocorreo          ="";
LET vstatuscorreo        ="";
LET vsqlerr              =0;
LET ultcte				 ="";
LET iContador = 0;
LET sCommit = 0;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         let vcodret = vsqlerr;
         return vcodret;
      END IF;
   END EXCEPTION;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "/informix/OMC/sp_obtieneinfosat.out";
--TRACE ON;
	
   --TRUNCATE si_ctessat_tmp;
	
   FOREACH Cursor_SAT WITH HOLD FOR
                SELECT numcte INTO cNUMCTE FROM si_ctessat Where empresa='001' and estatus_proc=0

                SELECT  CL.nombre1, CL.nombre2, CL.apell_paterno, CL.apell_materno, CL.rfc, CL.rfc_alterno, PF.fecha_nac, PF.sexo, PF.curp
                    INTO
                    cNombre1, cNombre2, cApell_paterno, cApell_materno, cRfc, cRfc_Alterno, dfecha_nac, cSexo, vCurp
                    FROM si_cliente CL
                     LEFT JOIN si_ctepf PF
                       ON PF.numcte = CL.numcte
                    WHERE CL.empresa = '001' AND CL.numcte=cNUMCTE;

                LET NombreComp=TRIM(cNombre1)||' '||TRIM(cNombre2);
                
                IF TRIM(cSexo)='M' THEN
                   LET cSexo='H';
                ELIF TRIM(cSexo)='F' THEN
                   LET cSexo='M';
                END IF;

                IF cRfc_Alterno='' OR cRfc_Alterno IS NULL THEN
                    LET cRfc_Alterno=cRfc;
                END IF;

				             

				SELECT first 1 DI.tipo_dir, DI.secuencia, DI.numeroextcalle, DI.numerointcalle,DI.departamento,
									DI.cod_postal, DI.numerocalle,DI.numerociudad,DI.numerocolonia,
									DI.ciudad,DI.estado,DI.pais,DI.municipio
				INTO   vtipo_dir, vsecuencia, vnumeroextcalle, vnumerointcalle, vdepartamento,
									vcod_postal,vnumcalle,vnumerociudad,vnumerocolonia,
									vCveCiudad,vCveEstado,vCvePais,vcvemunicipio
				  FROM si_direcciones_actual DI
				    WHERE DI.numcte = cNUMCTE
				    AND tipo_dir = 1;
				


                IF TRIM(vnumeroextcalle)='' THEN
                    LET vnumeroextcalle=NULL;
                END IF;

                IF TRIM(vnumerointcalle)='' THEN
                    LET vnumerointcalle=NULL;
                END IF;

                IF TRIM(vdepartamento)='' THEN
                    LET vdepartamento=NULL;
                END IF;

                IF TRIM(vcod_postal)='' THEN
                    LET vcod_postal=NULL;
                END IF;

               
                SELECT first 1 telefono
                INTO vTelefono
                FROM "informix".si_telefonos_actual
                WHERE numcte = cNUMCTE
                AND tipo_tel = 1
                AND status_tel='A';

             
				LET vtelefono1 = vTelefono;

				SELECT nombre
				INTO vpais
				FROM si_paises
				WHERE pais = vCvePais;
                
                IF TRIM(vpais)='' THEN
                   LET vpais=NULL;
                END IF
                    
				SELECT TRIM(nombre)
				INTO vestado
				FROM si_estados
				WHERE estado = vCveEstado;

                IF TRIM(vestado)='' THEN
                   LET vestado=NULL;
                END IF;

				SELECT TRIM(nombre), ciudad_coppel
				INTO vciudad,vCdCoppel
				FROM si_ciudades
				WHERE estado = vCveEstado
				AND ciudad = vCveCiudad;
                
                IF TRIM(vciudad)='' THEN
                   LET vciudad=NULL;
                END IF;

				SELECT TRIM(nombrezona)
				INTO vcolonia
				FROM si_catzonas
				WHERE numerociudad = vnumerociudad
				AND numerocolonia = vnumerocolonia;
                
                IF TRIM(vcolonia)='' THEN
                   LET vcolonia=NULL; 
                END IF;

				SELECT TRIM(nombrecalle)
				INTO vcalle
				FROM si_catcalles
				WHERE numerocalle = vnumcalle;
                
                IF TRIM(vcalle)='' THEN
                   LET vCalle=NULL; 
                END IF;

				
				SELECT TRIM(municipiozona)
				INTO vmunicipio
				FROM si_catzonas
				WHERE numerociudad = vnumerociudad
				AND numerocolonia  = vnumerocolonia;
				
                IF TRIM(vmunicipio)='' THEN
                   LET vmunicipio=NULL;
                END IF;

                IF TRIM(cRfc_Alterno)='' THEN
                    LET cRfc_Alterno=NULL;
                END IF;

		
        SELECT first 1 correo_elec
        INTO email
        FROM "informix".si_correos
        WHERE numcte = cNUMCTE
        AND tipo_correo = 1
        AND status_correo = 'A';

        IF TRIM(email)='' THEN
            LET email=NULL;
        END IF;    

		IF TRIM(vCurp)='' THEN
            LET vCurp=NULL;
        END IF;

        IF (sCommit = 0) THEN
            BEGIN WORK;
			LET iContador = 0;
			LET sCommit = -1;
        END IF;

		INSERT INTO si_ctessat_tmp (numcte, rfc, rfc_act, fec_act, nombre, ap_pat, ap_mat, nom_comp,
		curp, fec_nac, genero, calle, num_ext, num_int, colonia, localidad, municipio, cod_pos, dom_completo, telefono, email, tipo_persona)
		VALUES (cNUMCTE, cRfc_Alterno, NULL, NULL, NombreComp, cApell_paterno, cApell_Materno, NULL, TRIM(vCurp), TO_CHAR(dfecha_nac,'%Y%m%d'), cSexo,
		vcalle, vnumeroextcalle, vnumerointcalle, vcolonia, NULL, vmunicipio, vcod_postal, NULL, vtelefono1,TRIM(email), 'PERSONA FISICA');

		UPDATE si_ctessat SET estatus_proc=1, fecha_proc=current WHERE CURRENT OF Cursor_SAT;
        
		LET iContador = iContador  + 1;	
		
        --Ejecutar un commit cada 10000 registros.
        IF (iContador >= 10000) THEN
             COMMIT WORK;	
             LET iContador = 0;				
             BEGIN WORK;
        END IF;

    END FOREACH;
	
    IF sCommit = -1 THEN
        COMMIT WORK;                
    END IF;
    LET sCommit = 0;
	
RETURN Cod_Retorno;
END;
END PROCEDURE;
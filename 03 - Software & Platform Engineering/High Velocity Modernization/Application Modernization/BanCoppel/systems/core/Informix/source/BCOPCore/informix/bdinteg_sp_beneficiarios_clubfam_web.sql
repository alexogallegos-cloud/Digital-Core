CREATE PROCEDURE "informix".sp_beneficiarios_clubfam_web(pEmpresa CHAR(3), pCteBanCoppel CHAR(20), pCteCoppel CHAR(20), pSecuencia INTEGER, 
pNomBenef1 CHAR(26),pNomBene1 CHAR(26), pAPaternoBenef1 CHAR(26), pAMaternoBenef1 CHAR(26), pPorcentaje DECIMAL(5,2), pParentesco CHAR(1),
pFecNac1 DATE, pTel1 CHAR(10) , pNomBenef2 CHAR(26),pNomBene2 CHAR(26), pAPaternoBenef2 CHAR(26), pAMaternoBenef2 CHAR(26), pPorcentaje2 CHAR(26),
pParentesco2 CHAR(1), pFecNac2 DATE, pTel2 CHAR(10), pNomBenef3 CHAR(26), pNomBene3 CHAR(26),pAPaternoBenef3 CHAR(26),pAMaternoBenef3 CHAR(26),
pPorcentaje3 DECIMAL(5,2), pParentesco3 CHAR(1), pFecNac3 DATE, pTel3 CHAR(10), pEjecutivo CHAR(8), pBorrarRegistros CHAR(1), pSucCambio CHAR(4), 
pTipoMov CHAR(1))
RETURNING CHAR(6) AS codRet;

--DEFINICION DE VARIABLES
DEFINE cCodret	CHAR(5);
DEFINE iSqlErr INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodret	= '00000';
LET iSqlErr = 0;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF NVL(pSecuencia,0)=0 OR TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCteBanCoppel,''))='' 
		OR TRIM(NVL(pCteCoppel,''))='' OR TRIM(NVL(pEjecutivo,''))='' OR TRIM(NVL(pBorrarRegistros,''))='' THEN
			LET cCodret = '00001';
		ELSE
			IF pSecuencia>3 THEN
				LET cCodret = '00002';
			ELSE
					IF pSecuencia>=1 THEN
						IF  TRIM(NVL(pNomBenef1,''))='' OR TRIM(NVL(pAPaternoBenef1,''))='' 
						OR NVL(pPorcentaje,0)=0 OR TRIM(NVL(pParentesco,''))='' OR TRIM(NVL(pFecNac1,''))= '' OR TRIM(NVL(pTel1 , ''))='' THEN
							LET cCodret = '00001';
						END IF
					END IF
					IF pSecuencia>=2 THEN
						IF TRIM(NVL(pNomBenef2,''))='' OR TRIM(NVL(pAPaternoBenef2,''))='' OR TRIM(NVL(pParentesco2,''))='' 
						OR TRIM(NVL(pFecNac2,''))='' OR TRIM(NVL(pTel2 , ''))='' THEN
							LET cCodret = '00001';
						END IF
					END IF
					IF pSecuencia=3 THEN
						IF TRIM(NVL(pNomBenef3,''))='' OR TRIM(NVL(pAPaternoBenef3,''))='' OR NVL(pPorcentaje3,0)=0 OR TRIM(NVL(pParentesco3,''))='' 
						OR TRIM(NVL(pFecNac3,''))='' OR TRIM(NVL(pTel2 , ''))='' THEN
							LET cCodret = '00001';
						END IF
					END IF
					IF TRIM(NVL(pTipoMov,''))='C' THEN
						IF TRIM(NVL(pSucCambio,''))='' THEN
							LET cCodret = '00001';
						END IF
					END IF
					IF cCodret='00000' THEN
						IF pSecuencia<=3 THEN
							IF TRIM(NVL(pBorrarRegistros,'')) = 'S' THEN
								DELETE bdinteg:"informix".si_club_beneficiario
								WHERE empresa=TRIM(pEmpresa) AND numcte=TRIM(pCteBanCoppel)
								AND numcte_coppel = TRIM(pCteCoppel);
							END IF
							IF pSecuencia >=1 THEN
								INSERT INTO bdinteg:"informix".si_club_beneficiario (empresa,numcte,numcte_coppel,secuencia,primer_nombre,segundo_nombre,apell_paterno,apell_materno,porcentaje,parentesco,fecha_nacimiento, telefono, ejecutivo_modificacion,fecha_modificacion,ejecutivo_insert,fecha_insert,suc_cambio,tipo_mov) 
								VALUES(pEmpresa,pCteBanCoppel,pCteCoppel,1,pNomBenef1,pNomBene1,pAPaternoBenef1,pAMaternoBenef1,pPorcentaje,pParentesco,pFecNac1, pTel1,pEjecutivo, CURRENT,pEjecutivo,CURRENT,pSucCambio,pTipoMov);
							END IF
							IF pSecuencia >=2 THEN
								INSERT INTO bdinteg:"informix".si_club_beneficiario (empresa,numcte,numcte_coppel,secuencia,primer_nombre,segundo_nombre,apell_paterno,apell_materno,porcentaje,parentesco,fecha_nacimiento, telefono, ejecutivo_modificacion,fecha_modificacion,ejecutivo_insert,fecha_insert,suc_cambio,tipo_mov) 
								VALUES(pEmpresa,pCteBanCoppel,pCteCoppel,2,pNomBenef2,pNomBene2,pAPaternoBenef2,pAMaternoBenef2,pPorcentaje2,pParentesco2,pFecNac2, pTel2,pEjecutivo, CURRENT,pEjecutivo,CURRENT,pSucCambio,pTipoMov);
							END IF
							IF pSecuencia >=3 THEN
								INSERT INTO bdinteg:"informix".si_club_beneficiario (empresa,numcte,numcte_coppel,secuencia,primer_nombre,segundo_nombre,apell_paterno,apell_materno,porcentaje,parentesco,fecha_nacimiento, telefono, ejecutivo_modificacion,fecha_modificacion,ejecutivo_insert,fecha_insert,suc_cambio,tipo_mov) 
								VALUES(pEmpresa,pCteBanCoppel,pCteCoppel,3,pNomBenef3,pNomBene3,pAPaternoBenef3,pAMaternoBenef3,pPorcentaje3,pParentesco3,pFecNac3, pTel3, pEjecutivo, CURRENT,pEjecutivo,CURRENT,pSucCambio,pTipoMov);
							END IF
						END IF
					END IF
			END IF
		END IF
		RETURN cCodret;
END
END PROCEDURE;
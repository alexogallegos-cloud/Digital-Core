CREATE FUNCTION "informix".syn_sign( pmsg LVARCHAR(3000), OUT psign LVARCHAR(512), pKey INTEGER  )
RETURNING INTEGER;
  DEFINE cCodRet INTEGER;
  DEFINE l_type integer;
  DEFINE l_idmsg INTEGER;
  DEFINE l_Key  INTEGER;
  DEFINE l_msg LVARCHAR(3000);
  DEFINE l_sign LVARCHAR(512);
  DEFINE vsqlerr INTEGER;
  DEFINE iTransaccion INTEGER;
  DEFINE AL_SHA256 INTEGER;
  DEFINE AL_SHA512 INTEGER;


  LET l_type = 1;
  LET l_idmsg = 0;
  LET cCodRet = 200;
  LET l_msg = pmsg;
  LET l_Key = pKey;
  LET iTransaccion = 0;
  LET AL_SHA256 = 1;
  LET AL_SHA512 = 0;
  
Begin

  ON EXCEPTION SET vsqlerr
     IF vsqlerr <> 0 THEN
        return vsqlerr;
     END IF;
  END EXCEPTION WITH RESUME;

  ON EXCEPTION IN (-535)
     LET iTransaccion = 1;
     COMMIT WORK;
     BEGIN WORK;
  END EXCEPTION WITH RESUME;

  --SET DEBUG FILE TO "/informix/ifg/syn_verify_err.out";
  --TRACE ON;
  
  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  SELECT FIRST 1 seq_signmsgs.NEXTVAL
    INTO l_idmsg
  FROM tblhorario;

  IF (l_idmsg IS NULL ) THEN
    RETURN cCodRet;
  END IF;
  
  INSERT INTO secSigns (idsign, typesing, msg, msgsign,idkey,returncode) VALUES (l_idmsg,l_type, l_msg,null,l_Key,null);

  BEGIN WORK;

  --SYSTEM '/resplogifx/conciliachq/intersv/syn_procsign intercard ' || l_type || ' ' || l_idmsg ;
  --SYSTEM '/resplogifx/conciliachq/intersv/syn_proc.sh ' || l_type || ' ' || l_idmsg || ' 1';
  --SYSTEM '/informix/extend/syn_proc.sh ' || l_type || ' ' || l_idmsg || ' ' || AL_SHA256;
    SYSTEM '/RESPALDOSNEW/extend/./syn_proc.sh ' || l_type || ' ' || l_idmsg || ' ' || AL_SHA256;

  SELECT msgsign,returncode
    INTO l_sign, cCodRet
    FROM secSigns
   WHERE idsign = l_idmsg;

  LET psign = l_sign;

  IF (iTransaccion = 0 ) THEN
     COMMIT WORK;
  END IF;

  RETURN cCodRet;

end;

End FUNCTION;
CREATE FUNCTION "informix".syn_verify2
(pmsg LVARCHAR(3000), p_sign LVARCHAR(512), pKey INTEGER)
RETURNING INTEGER as RetCode;
  DEFINE RetCode INTEGER;
  DEFINE l_type integer;
  DEFINE l_idmsg INTEGER;
  DEFINE l_Key  INTEGER;
  DEFINE l_msg LVARCHAR(3000);
  DEFINE l_sign LVARCHAR(512);
  DEFINE vsqlerr INTEGER;
  DEFINE iTransaccion INTEGER;
  DEFINE AL_SHA256 INTEGER;
  DEFINE AL_SHA512 INTEGER;

  LET RetCode =200;
  LET l_type = 2;
  LET l_idmsg = 0;
  LET l_msg = pmsg;
  LET l_sign = p_sign;
  LET l_Key = pKey;
  LET iTransaccion = 0;
  LET AL_SHA256 = 1;
  LET AL_SHA512 = 0;
  
   -- SET DEBUG FILE TO "/informix/ifg/syn_verify_err.out";
   -- TRACE ON;
begin

    ON EXCEPTION SET vsqlerr
          SET DEBUG FILE TO "/resplogifx/conciliachq/intersvsyn_verify_err.out";
          TRACE ON;
          IF vsqlerr <> 0 THEN
             return vsqlerr;
          END IF;
        END EXCEPTION;
  
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  SELECT FIRST 1 seq_signmsgs.NEXTVAL
		INTO l_idmsg
	  FROM tblhorario;

	  IF (l_idmsg IS NULL ) THEN
		RETURN RetCode;
	  END IF;
	  
	  INSERT INTO secSigns (idsign, typesing, msg, msgsign,idkey,returncode) VALUES (l_idmsg,l_type, l_msg,p_sign,l_Key,null);
	   
	  SYSTEM '/RESPALDOSNEW/extend/./syn_proc.sh ' || l_type || ' ' || l_idmsg || ' ' || AL_SHA512;
	  
	  SELECT idsign,returncode
		INTO l_sign, RetCode
	  FROM secSigns
	  WHERE idsign = l_idmsg;
  
  RETURN RetCode;
END;
END FUNCTION;
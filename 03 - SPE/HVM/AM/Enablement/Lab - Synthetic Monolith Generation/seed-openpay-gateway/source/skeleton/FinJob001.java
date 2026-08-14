package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : JOB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 7    LOC approx: 279
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinEntity;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Scheduled
public class FinJob001 {

    // Collaborators (match the graph call edges):
    private final FinService052 finService052;
    private final FinService110 finService110;
    private final FinService128 finService128;
    private final FinService140 finService140;
    private final FinService192 finService192;
    private final NotificationService notificationService;
    private final VaultService vaultService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}

package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : JOB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 6    LOC approx: 142
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinEntity;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Scheduled
public class FinJob003 {

    // Collaborators (match the graph call edges):
    private final ApiKeyService apiKeyService;
    private final FinService024 finService024;
    private final FinService078 finService078;
    private final FinService085 finService085;
    private final FinService267 finService267;
    private final FinService291 finService291;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}

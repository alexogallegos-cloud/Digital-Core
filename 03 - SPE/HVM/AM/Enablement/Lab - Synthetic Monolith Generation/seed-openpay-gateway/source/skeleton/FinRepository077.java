package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : REPO                 ACCESS : inquiry (read-only)
//  FAN-IN    : 2    FAN-OUT : 2    LOC approx: 237
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinEntity;
import com.openpay.dto.FinRequest;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Repository
public class FinRepository077 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;
    private final MoneyUtils moneyUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}

package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 5    FAN-OUT : 9    LOC approx: 726
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinRequest;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Service
public class FinService292 {

    // Collaborators (match the graph call edges):
    private final FinRepository062 finRepository062;
    private final FinRepository085 finRepository085;
    private final FinService085 finService085;
    private final FinService151 finService151;
    private final FinService227 finService227;
    private final FinService275 finService275;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}

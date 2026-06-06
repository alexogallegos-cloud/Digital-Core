package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 6    LOC approx: 320
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinEntity;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;

@Service
public class FinService192 {

    // Collaborators (match the graph call edges):
    private final FinRepository085 finRepository085;
    private final FinService070 finService070;
    private final FinService277 finService277;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}

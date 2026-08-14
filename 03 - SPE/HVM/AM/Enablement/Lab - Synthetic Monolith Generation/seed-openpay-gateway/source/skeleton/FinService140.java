package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 6    FAN-OUT : 7    LOC approx: 146
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.FinEntity;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@Service
public class FinService140 {

    // Collaborators (match the graph call edges):
    private final CmpService215 cmpService215;
    private final FinRepository062 finRepository062;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final RbacService rbacService;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}

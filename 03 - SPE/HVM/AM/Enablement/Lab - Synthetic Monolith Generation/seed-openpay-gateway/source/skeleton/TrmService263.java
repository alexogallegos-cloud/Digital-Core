package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 8    LOC approx: 348
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmEntity;
import com.openpay.dto.TrmRequest;
import com.openpay.dto.TrmResponse;

@Service
public class TrmService263 {

    // Collaborators (match the graph call edges):
    private final BinManagerService binManagerService;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final StringUtils stringUtils;
    private final TrmRepository017 trmRepository017;
    private final TrmRepository084 trmRepository084;
    private final TrmService242 trmService242;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}

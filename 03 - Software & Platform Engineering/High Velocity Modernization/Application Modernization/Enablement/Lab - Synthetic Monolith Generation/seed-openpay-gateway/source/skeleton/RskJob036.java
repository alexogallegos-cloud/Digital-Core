package com.openpay.manager.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : risk-fraud
//  LAYER     : JOB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 6    LOC approx: 305
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskEntity;

@Scheduled
public class RskJob036 {

    // Collaborators (match the graph call edges):
    private final RbacService rbacService;
    private final RskService008 rskService008;
    private final RskService009 rskService009;
    private final RskService111 rskService111;
    private final RskService231 rskService231;
    private final RskService251 rskService251;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}

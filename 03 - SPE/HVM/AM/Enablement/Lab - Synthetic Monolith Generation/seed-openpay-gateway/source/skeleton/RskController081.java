package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : WEB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 4    LOC approx: 247
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskEntity;
import com.openpay.dto.RskRequest;
import com.openpay.dto.RskResponse;
import com.openpay.dto.TransactionDTO;

@RestController
public class RskController081 {

    // Collaborators (match the graph call edges):
    private final CmpService171 cmpService171;
    private final ConfigService configService;
    private final RskService043 rskService043;
    private final RskService258 rskService258;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}

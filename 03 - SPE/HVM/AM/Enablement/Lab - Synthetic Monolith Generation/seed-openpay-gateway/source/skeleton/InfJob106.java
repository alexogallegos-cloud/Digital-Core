package com.openpay.manager.infra;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : infra
//  LAYER     : JOB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 8    LOC approx: 349
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.InfResponse;
import com.openpay.dto.ResponseEnvelope;

@Scheduled
public class InfJob106 {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final InfService020 infService020;
    private final InfService035 infService035;
    private final InfService211 infService211;
    private final InfService214 infService214;
    private final InfService271 infService271;
    private final InfService276 infService276;
    private final NotificationService notificationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}

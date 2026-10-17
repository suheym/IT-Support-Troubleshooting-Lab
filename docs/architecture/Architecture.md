
# IT Support & Troubleshooting Lab - Architecture

## Host environment

- Host OS: Windows 11
- Hardware: HP Victus 15, AMD Ryzen 5 5600H, 16 GB RAM
- Hypervisor: Oracle VirtualBox 7.2.20

## Architecture diagram

```mermaid
flowchart TB
    HOST["Windows 11 Host<br/>HP Victus 15<br/>VirtualBox 7.2.20"]

    subgraph VMS["Virtual Machines"]
        DC["LAB-DC01<br/>Windows Server 2025 Standard Evaluation<br/>AD DS · DNS · DHCP<br/>Group Policy · SMB File Share"]
        CLIENT["LAB-CLIENT01<br/>Windows 11 Pro<br/>Domain-joined client"]
    end

    subgraph LABNET["Internal Network IT-LAB - 192.168.50.0/24"]
        DCNIC["Server lab adapter<br/>192.168.50.10"]
        CLINIC["Client lab adapter<br/>192.168.50.100<br/>DNS: 192.168.50.10"]
    end

    DC --> DCNIC
    CLINIC --> CLIENT
    DCNIC --- CLINIC

    HOST --> VMS

    DC -. "Secondary adapter<br/>10.0.3.15<br/>Gateway: 10.0.3.2" .- NETDC["Server secondary network"]
    CLIENT -. "Secondary adapter<br/>10.0.2.15<br/>Gateway: 10.0.2.2" .- NETCLIENT["Client secondary network"]

    CLIENT -->|"Domain authentication · DNS · Group Policy"| DC
    CLIENT -->|"SMB access: DeptShare"| DC

    classDef server fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef client fill:#dcfce7,stroke:#16a34a,color:#111827
    classDef network fill:#f3f4f6,stroke:#6b7280,color:#111827

    class DC,DCNIC server
    class CLIENT,CLINIC client
    class NETDC,NETCLIENT network
```

## Verified network details

| Component | Adapter | IPv4 address | Gateway |
|---|---|---|---|
| LAB-DC01 | Ethernet | 192.168.50.10 | None shown |
| LAB-DC01 | Ethernet 2 | 10.0.3.15 | 10.0.3.2 |
| LAB-CLIENT01 | Ethernet | 10.0.2.15 | 10.0.2.2 |
| LAB-CLIENT01 | Ethernet 2 | 192.168.50.100 | None shown |

The client lab adapter uses `192.168.50.10` for DNS. The server's lab adapter reports loopback DNS addresses (`::1` and `127.0.0.1`).

VirtualBox attachment modes have been verified: LAB-DC01 Adapter 1 uses Internal Network IT-LAB and Adapter 2 uses NAT. LAB-CLIENT01 Adapter 1 uses NAT and Adapter 2 uses Internal Network IT-LAB.

## Domain and services

- Active Directory domain: `ad.lab`
- Domain controller: `LAB-DC01`
- DHCP scope: `192.168.50.100`-`192.168.50.199`
- SMB share: `\\LAB-DC01\DeptShare`
- Client computer: `LAB-CLIENT01`

This diagram represents the observed lab configuration. It does not imply that the lab network has internet connectivity or a default gateway.


Use cases PostgreSQL
====================

Azure PostgreSQL
----------------
| This article applies to the DRCP enabled component Azure PostgreSQL and the corresponding Azure Database for PostgreSQL flexible server.
| `Azure Database for PostgreSQL flexible server <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/service-overview>`__ is a relational database service based on the `open source PostgreSQL database engine <https://www.postgresql.org>`__ .
| It's a fully managed database-as-a-service that can handle workloads with predictable performance, security, high availability, and dynamic scalability.

Scope
^^^^^
See article :doc:`Security baseline PostgreSQL <Security-Baseline>` for an actual overview of the scope of this component.

Some highlights are:

    - Local authentication isn't allowed. Only Microsoft Entra ID accounts.
    - All PostgreSQL extentions are disabled.
    - Zone redundancy for Production usage is a must.

Follow-up
---------

Connectivity
^^^^^^^^^^^^
DRCP enforced VNet integration for secure connectivity. This means you need to create an empty subnet in the VNet for
binding and delegation with Azure PostgreSQL. It's also possible to use Private Links.

Authentication
^^^^^^^^^^^^^^

**Microsoft Entra ID Administrator**

There must be a minimum of one Microsoft Entra ID Administrator in a DevOps team, who is the owner of the database. Best
practice is to assign the Azure DevOps deployment service principal as Microsoft Entra ID Administrator, to enable
deployments and configuration of the database from the Azure DevOps project.

For more information see
`Microsoft Entra authentication with Azure Database for PostgreSQL - Flexible Server <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-azure-ad-authentication>`__ and `Use Microsoft Entra ID for authentication with Azure Database for PostgreSQL - Flexible Server <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-configure-sign-in-azure-ad-authentication>`__.

**Access & schema management**

DRCP advises to use roles for authorization and limit privileges.

See best practices on `Access control <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/security-overview#access-control>`__.

High Availability
^^^^^^^^^^^^^^^^^

**Zone redundancy & backup redundancy**

Zone redundancy for the database server is possible as HA option which automatically elevates the backup data to Zone
Redundant Storage (ZRS). The Backup redundancy option is automatically mirrored with the Zone redundancy option.

Without zone redundancy the backup data is in the same zone as the database server which could result in data loss in
case of zone failure.

DRCP is enforcing zone redundancy for Production usage which ensures the backup data is also available in the other zone.
`More information about availability database server and backup data <https://learn.microsoft.com/en-us/azure/reliability/reliability-postgresql-flexible-server#high-availability-features>`__.

Backup
^^^^^^

**Backup frequency**

Azure PostgreSQL uses backups that are snapshot based and schedules the first snapshot backup directly after creating
a server.

The component retains the snapshot backup once a day. With no further modifications to any databases on the server
after the last snapshot backup, snapshot backups are temporarily suspended. When modification does happen on any
database on the server, a new snapshot automatically starts and captures the latest changes.

The first snapshot is a full backup and consecutive snapshots are differential backups. The default backup retention
period is 7 days and is configurable to a maximum of 35 days.

DevOps teams should configure backup of PostgreSQL databases, according to their needs. Extend this backup
configuration to limit risks of data loss.
`More information about backup <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore>`__.

**Long Term Retention (LTR) backups**

DRCP doesn't support Azure Backup and at the moment
`the LTR functionality is in preview <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore#long-term-retention>`__.






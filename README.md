# Libraries - Ansible

David Williamson @ Varilink Computing Ltd

------

A library of Ansible roles that are used in playbooks that automate the management of Varilink Computing Ltd's IT services. We either use those services internally within Varilink Computing Ltd or to provide to our customers.

The services are:

- Backup for the hosts that we operate.
- Calendars, including task lists, for our staff.
- DNS lookup on our internal network.
- Dynamic DNS lookup for services hosted on our internal network that we expose externally via our ISP's dynamically provisioned IP address.
- A mail both for our own domain and the domains of our clients.
- WordPress hosting for our own website and those of our clients.

My [Services - Docker](https://github.com/varilink/services-docker) provides the automated means to test these Ansible roles in a container environment and so is an ideal place to start if you want to understand them better.

## Roles

The table [List of Roles](#list-of-roles) below lists the roles defined in this repository by **Role Name**. They are either **Deployed** *explicitly* to a host, let's call them *primary* roles, or only as a *dependency* of primary role. The table indicates which is which and also for the primary roles, which roles are pulled in as their **Dependencies**.

The table also indicates the deployment **Levels** that are encapsulated in each role. To illustrate with an example, the `wordpress_apache` role's *main* task list deploys the core WordPress *host* service, whereas its *create-site-stack* task list deploys a WordPress *site* on to that *host* service.

The deployment levels implemented by roles within this repository are:

- host - As above, the core service onto which a domain, project or site can be configured.
- domain - For example, the configuration of a mail service for example.com.
- project - For example, the dynamic DNS entry that must be configured for external backup clients to connect to our on-site backup storage daemon.
- site - As above, the configuration of a WordPress site; for example, test.example.com or www.example.com.

### List of Roles

| Role Name         | Deployed   | Dependencies                       | Levels                 |
| ------------------| ---------- | ---------------------------------- | ---------------------- |
| backup_client     | explicitly |                                    | host                   |
| backup_director   | explicitly | backup_dropbox <sup>1</sup><br>mta | host                   |
| backup_dropbox    | dependency |                                    | host                   |
| backup_storage    | explicitly | backup_dropbox <sup>1</sup>        | host                   |
| calendar          | explicitly |                                    | host<br>domain         |
| database          | explicitly |                                    | host<br>site           |
| dns               | explicitly |                                    | host<br>domain<br>site |
| dns_api           | dependency |                                    | host                   |
| dns_client        | explicitly |                                    | host                   |
| dynamic_dns       | explicitly | dns_api <sup>2</sup>               | host<br>project        |
| mail              | dependency |                                    | host                   |
| mail_certificates | explicitly | dns_api <sup>2</sup>               | host<br>domain         |
| mail_external     | explicitly | mail<br>mta                        | host<br>domain         |
| mail_internal     | explicitly | mail<br>mta                        | host<br>domain         |
| mta               | dependency |                                    | host                   |
| reverse_proxy     | explicitly |                                    | host<br>site           |
| wordpress         | dependency | mta                                | host<br>site           |
| wordpress_apache  | explicitly | wordpress                          | host<br>site           |
| wordpress_nginx   | explicitly | wordpress                          | host<br>site           |

<sup>1</sup> Only if the backup service is integrated with Dropbox - see [Integration with Third-Party Cloud Services](#integration-with-third-party-cloud-services) below.

<sup>2</sup> Only if integration with the Linode domain management services is enabled - see [Integration with Third-Party Cloud Services](#integration-with-third-party-cloud-services) below.

### Role Descriptions

`backup_client`<br>
Backup client service using the Bacula file daemon. This is deployed to every host that is backed up in my automated, backup schedule. It facilitates communication with the host by the backup director and backup storage services so that they may backup the host.

`backup_director`<br>
Backup director service using the Bacula Director with a MySQL catalogue store.

`backup_dropbox`<br>
Dropbox integration service for making off-site copies of backups. This must be pulled in as a dependency of both the `backup_director` and `backup_storage` roles if backup integration with Dropbox is enabled.

`backup_storage`<br>
Backup storage service using the Bacula storage daemon.

`calendar`<br>
CalDAV based calendar service (including task lists) using Radicale.

`database`<br>
Database service based using MariaDB. This is used by both the backup_director service, to store the Bacula, backup catalogue and for the databases of WordPress sites.

`dns`<br>
A DNS service using Dnsmasq. We run Dnsmasq on our office network to supplement our ISP's DNS service with additional features.

`dns_api`<br>
A very simple role that merely deploys the key for API access to Linode hosted DNS zones for use by both the mail_certificates and dynamic_dns roles, if integration with the Linode domain management service is enabled - see [Integration with Third-Party Cloud Services](#integration-with-third-party-cloud-services) below.

We deploy this to a single host on our office network so that we're only holding our API access tokens in on place and that is on an internal host on the office network.

`dns_client`<br>
Role that configures hosts on our internal, office network to use the DNS service provided on that network by the dns role.

`dynamic_dns`<br>
Keeps our Linode based DNS zones up to date with the dynamic IP address provided by our ISP for the office network for services that are hosted on-premise and exposed externally.

`mail`<br>
Implements a mail server using Dovecot for hosts that provide a mail service.

`mail_certificates`<br>
Provides SSL certificates that are obtained from Let's Encrypt for encrypting IMAP and SMTP connections.

`mail_external`<br>
External (to the office network) mail service using Exim and Dovecot.

`mail_internal`<br>
Internal (to the office network) mail service using Exim and Dovecot with Fetchmail integration to the external mail service.

`mta`<br>
Implements a Mail Transfer Agent using Exim4 for all hosts that need to send or receive emails.

`reverse_proxy`<br>
Reverse proxy service using Nginx.

`wordpress`<br>
Base WordPress service - see also `wordpress_apache` and `wordpress_nginx` roles.

`wordpress_apache`<br>
WordPress service variant using Apache as a webserver.

`wordpress_nginx`<br>
WordPress service variant using Nginx as a webserver.

## Integration with Third-Party Cloud Services

The roles in this repository support integration with four Cloud service providers as follows:

**Dropbox**<br>
The backup service can use a Dropbox account to make off-site copies of backup media for on-site hosts for disaster recovery purposes. To eanble this integration, you must:

1. Create a Dropbox account to use.
2. Create a top-level folder within your Dropbox account, which will be where the backup will write its off-site copies to. By default this is expected to be `bacula` but you can change the name by setting a different value for the `backup_copy_folder` directory.
3. Set the `backup_linked_to_dropbox` variables to a boolean true YAML value, I recommend `yes`.

After you've deployed the `backup_director` and `backup_storage` roles with the Drobpox integration enabled, you will have to link the hosts for those roles to your Dropbox account - see [Dropbox Headless install via command line](https://www.dropbox.com/en_GB/install-linux). You will need to run the Dropbox daemon and "copy and paste a link in a working browser to create a new account or add your server to an existing account" when prompted.

It's possible to rehearse this using my [Services - Docker](https://github.com/varilink/services-docker) repository - see [Enabling Integration with Third-Party Cloud Services](https://github.com/varilink/services-docker#enabling-integration-with-third-party-cloud-services) and [Activating Backup Synchronisation with Dropbox](https://github.com/varilink/services-docker#activating-backup-synchronisation-with-dropbox) in that repository's README.

**Let's Encrypt**<br>

The WordPress hosting and mail services both support integration with Let's Encrypt to obtain TLS certificates. In the case of the mail service this relies on Linode integration (see below) being enabled to support validation via the [Let's Encrypt DNS-01 challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge). Certificates for the WordPress hosting service are validated via the [Let's Encrypt HTTP-01 challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) and so don't required Linode integration.

Both the WordPress hosting and mail services can also use self-signed certificates, though of course these are suboptimal compared to those provided by a certification authority.

In the context of Let's Encrypt integration and the use of SSL more generally, see the [Variables](#variables):

- `host_enabled_for_ssl`
- `mail_uses_ca`
- `wordpress_site_uses_ca`
- `wordpress_site_uses_ssl`

**Linode**<br>
Linode is our preferred partner for Linux virtual hosts and also domain zone management. The `dynamic_dns` and `mail_certificates` roles both support the use of the Linode API service to automate the management of DNS records.

To enable this integration you must:

1. Have an account with Linode.
2. Create an API personal access token with *Read Only" access to the "Account" scope and *Read/Write* access to the *Domains* scope.
3. Set the variable `dns_linode_key` to the key of the API token that you just created.

Since you can't enable this integration without executing these steps, it is disabled by default. If you don't enable it then both the `dynamic_dns` and `mail_certificates` roles are rendered completely redundant and there's no point deploying them.

**Mailgun**<br>
Our mail service uses Mailgun as a smarthost when sending emails externally from our domain or our customers' domains, to enhance deliverability and for access to their service monitoring and management tools. Just as with the Linode integration, this requires that you have a Mailgun account and so is disabled by default.

To use this integration you must:

1. Have an account with Mailgun.
2. Register each domain that you want to use in the list of *Sending domains* in the Mailgun dashboard.
3. Configure the `domain_smarthost_username` and `domain_smarthost_userpass` variables with the SMTP credentials configured in Mailgun for the domain when you deploy a domain using the `mail_certificates` role.

Without this integration in place the `mail_certificates` role will still send emails externally but will do so directly from the host it resides on, which is likely to have an adverse impact on email deliverability.

## Variables

The roles in this repository use a number of variables, over and above any Ansible built-in variables that they use. Some of these are internal to the roles only, i.e. it's never necessary for playbooks or the inventories used by those playbooks to set values for them. Others could or must have their values set by playbooks that use these roles or their associated inventories.

The table [List of Variables](#list-of-variables) below contains:

- The variables by **Name** that could or must have their values set by playbooks that use the roles in this repository or the inventories used by those playbooks.

- The roles that each of those variables is **Used In**, as opposed to *set by*; for example, role A declares role B as one of its dependencies and, in doing so, role A sets the value of a variable that role B uses but that role A does not use. In that example, this table would identify role B as a role that it is *used in* but not role A.

- Whether it is **Mandatory** for playbooks or inventories used by those playbooks to set a value for the variable. The default behaviour if a value is not set is described within the list of [Variable Descriptions](#variable-descriptions) that follow the table.

- The **Scope(s)** where **I set** the variable in playbooks or inventories used by those playbooks, which is one or more of:

> - *all* = In the all group of the inventory.
> - *host* = In vars for a specific host in the inventory.

### List of Variables

| Name                                   | Used In                                                                                                                  | Mandatory | Scope(s)             |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- | -------------------- |
| admin_user                             | backup_client<br>mail<br>mta<br>wordpress                                                                                | Yes       | all                  |
| admin_user_email                       | backup_director<br>backup_storage<br>mail_certificates<br>wordpress                                                      | Yes       | all                  |
| backup_archive_media_directory         | backup_dropbox<br>backup_storage                                                                                         | No        | all                  |
| backup_client_director_password        | backup_client<br>backup_director                                                                                         | Yes       | host                 |
| backup_client_monitor_password         | backup_client                                                                                                            | Yes       | host                 |
| backup_copy_folder                     | backup_director<br>backup_dropbox                                                                                        | No        | all                  |
| backup_database_host                   | backup_director                                                                                                          | No        | all                  |
| backup_database_password               | backup_director<br>database                                                                                              | No        | all                  |
| backup_database_user                   | backup_director<br>database                                                                                              | No        | all                  |
| backup_director_console_password       | backup_director                                                                                                          | Yes       | all                  |
| backup_director_host                   | backup_director<br>database                                                                                              | No        | all                  |
| backup_director_monitor_password       | backup_director                                                                                                          | Yes       | all                  |
| backup_director_name                   | backup_client<br>backup_director<br>backup_storage                                                                       | Yes       | all                  |
| backup_director_schedules_active       | backup_director                                                                                                          | No        | all                  |
| backup_linked_to_dropbox               | backup_director                                                                                                          | No        | all                  |
| backup_monitor_name                    | backup_client<br>backup_director<br>backup_storage                                                                       | Yes       | all                  |
| backup_storage_director_password       | backup_director<br>backup_storage                                                                                        | Yes       | all                  |
| backup_storage_host                    | backup_director                                                                                                          | Yes       | all                  |
| backup_storage_monitor_password        | backup_storage                                                                                                           | Yes       | all                  |
| backup_storage_name                    | backup_storage                                                                                                           | Yes       | all                  |
| database_expose_externally             | database                                                                                                                 | No        | all                  |
| dns_client_nameservers                 | dns_client                                                                                                               | Yes       | external<br>internal |
| dns_client_options                     | dns_client                                                                                                               | No        |                      |
| dns_host_patterns                      | dns                                                                                                                      | Yes       | external             |
| dns_linode_key                         | dns_api<br>dynamic_dns                                                                                                   | Yes       | all (private)        |
| dns_upstream_nameservers               | dns                                                                                                                      | Yes       | external<br>internal |
| domain_country                         | mail_external                                                                                                            | No        |                      |
| domain_linode_dynamic_dns_records      | dynamic_dns                                                                                                              |           |                      |
| domain_locality                        | mail_external                                                                                                            | No        |                      |
| domain_name                            | dns<br>dynamic_dns<br>mail<br>mail_certificates<br>mail_external<br>reverse_proxy<br>wordpress_apache<br>wordpress_nginx | Yes       |                      |
| domain_organisation                    | mail_external<br>wordpress                                                                                               | Yes       |                      |
| domain_organisation_unit               | mail_external                                                                                                            | No        |                      |
| domain_smarthost_username              | mail_external                                                                                                            | Yes       |                      |
| domain_smarthost_userpass              | mail_external                                                                                                            | Yes       |                      |
| domain_state                           | mail_external                                                                                                            | No        |                      |
| domain_users                           | mail_external<br>mail_internal                                                                                           | Yes       |                      |
| dynamic_dns_crontab_stride             | dynamic_dns                                                                                                              | No        |                      |
| dynamic_dns_records_dir                | dynamic_dns                                                                                                              |           |                      |
| home_domain                            | backup_director<br>backup_storage<br>dns<br>dns_client<br>mail<br>mail_external<br>mail_internal<br>mta                  | Yes       |                      |
| host_enabled_for_ssl                          | reverse_proxy                                                                                                            |           |                      |
| hosts_to_roles_map                     | backup_director<br>domain.yml                                                                                            | Yes       |                      |
| mail_uses_ca                           | mail_certificates<br>mail_external                                                                                       | No        |                      |
| mta_smarthost_hostname                 | mta                                                                                                                      | Yes       |                      |
| mta_smarthost_port                     | mta                                                                                                                      | Yes       |                      |
| mta_smarthost_username                 | mta                                                                                                                      | Yes       |                      |
| mta_smarthost_userpass                 | mta                                                                                                                      | Yes       |                      |
| office_subnet                          | mail_internal                                                                                                            | Yes       |                      |
| unsafe_writes                          | dns_client                                                                                                               | No        |                      |
| wordpress_expose_externally            | wordpress_apache                                                                                                         | No        |                      |
| wordpress_site_admin_email             | wordpress                                                                                                                | No        |                      |
| wordpress_site_admin_password          | wordpress                                                                                                                | Yes       |                      |
| wordpress_site_admin_user              | wordpress                                                                                                                | No        |                      |
| wordpress_site_client_max_body_size    | wordpress_nginx                                                                                                          | No        |                      |
| wordpress_site_database_host           | database<br>wordpress                                                                                                    | No        |                      |
| wordpress_site_database_password       | database<br>wordpress                                                                                                    | Yes       |                      |
| wordpress_site_dns_host                | wordpress_nginx                                                                                                          | No        |                      |
| wordpress_site_expose_externally       | wordpress_apache                                                                                                         | No        |                      |
| wordpress_site_plugins                 | wordpress                                                                                                                | No        |                      |
| wordpress_site_reverse_proxy_pass_port | reverse_proxy<br>wordpress_apache                                                                                        | Yes       |                      |
| wordpress_site_subdomain               | dns<br>reverse_proxy<br>wordpress<br>wordpress_apache<br>wordpress_nginx                                                 | Yes       |                      |
| wordpress_site_uses_ssl                | reverse_proxy<br>wordpress_nginx                                                                                         | No        |                      |

### Variable Descriptions

A description of each of the variables in the table above now follows.

`admin_user`<br>
The operating system user login for the main admin user who supports the Varilink services. Of course this is always a user in the `home_domain`.

`admin_user_email`<br>
The email address for the `admin_user`. This is not simply `admin_user`@`home_domain` since we use first names only for our office network logins but we use `fname.lname` for our email addresses.

`backup_archive_media_directory`<br>
The directory that the backup storage daemon uses to store archive media in. This defaults to `/var/local/bacula` unless an alternative value is provided via the playbook or inventory.

`backup_client_director_password`<br>
The password that the backup director must use to connect to a backup client. For good security, this should be unique to each backup client and meet length and complexity standards.

`backup_client_monitor_password`<br>
The password that the backup monitor must use to connect to a backup client. For good security, this should be unique to each backup client and meet length and complexity standards. Unlike the backup director, the backup monitor is a desktop application and so there is no role in this library corresponding to it.

`backup_copy_folder`<br>
The top-level folder within Dropbox for off-site copies of backup files. This defaults to `bacula` unless and alternative value if provided via the playbook or inventory.

`backup_database_host`<br>
The host of the database that's used to store the backup catalogue. This can be omitted in which case the backup director will assume that the backup database is co-located on the same host as itself and use a local socket connection to the database.

`backup_database_password`<br>
The password that the backup director uses to connect to the backup database. If this is omitted it will default to "bacula". A more secure value should be provided.

`backup_database_user`<br>
The user that the backup director uses to connect to the backup database.  If this is omitted it will default to "bacula". A more secure value should be provided.

`backup_director_console_password`<br>
The password that the backup console must use to connect to the backup director. The backup console is a desktop application and so there is no role in this library corresponding to it.

`backup_director_host`<br>
The host of the backup director. This is used when creating the backup user account in the backup database. If it is omitted then it will be assumed that the backup director is co-located with the host of the backup database.

`backup_director_monitor_password`<br>
The password that the backup monitor must use to connect to the backup director. For good security, this should meet length and complexity standards. The backup monitor is a desktop application and so there is no role in this library corresponding to it.

`backup_director_name`<br>
The name by which the backup director identifies itself to backup clients and the backup storage daemon.

`backup_director_schedules_active`<br>
Whether the backup schedules are active or not. By default this is set to the boolean true value. It only needs to be set in a playbook or inventory if a value that Jinja evaluates to false is required in order to disable automatic backup job scheduling. This can be useful during testing of backup jobs when it's convenient to run them manually instead.

`backup_linked_to_dropbox`

`backup_monitor_name`<br>
The name by which the backup monitor identifies itself to backup clients, the backup director and the backup storage daemon.

`backup_storage_director_password`<br>
The password that the backup director must use to connect to the backup storage daemon. For good security, this should meet length and complexity standards.

`backup_storage_host`<br>
The host of the storage daemon that the backup director must connect to.

`backup_storage_monitor_password`<br>
The password that the backup monitor must use to connect to the backup storage daemon. For good security, this should meet length and complexity standards.

`backup_storage_name`<br>
The name by which the backup storage daemon identifies itself.

`database_expose_externally`<br>
Whether to expose the database service on a database host to the external network interface or not.

If this isn't set then it defaults to the boolean value false, meaning that the database service is not exposed to the external network interface. This is fine so long as services that use that database are on the same host. If that's the case then obviously for security reasons the database service should not be exposed externally.

If services external to the database host use its database service then this should be set to a value that Jinja understands to be true.

`dns_client_nameservers`<br>
The IP addresses of DNS nameservers that a DNS client should use. These are used in the `/etc/resolv.conf` file for each host.

`dns_client_options`<br>
Options to be set in the `/etc/resolv.conf` file for each host. If this is provided then it must be an array of strings, each of which will be added after `option` in a line within `/etc/resolv.conf`. This variable can be omitted if there are no options to set.

`dns_host_patterns`<br>
An array of pattern strings to match hostnames to and their corresponding descriptions. These are used to determine the hosts that a DNS server will provide resolution services for. Each member of the array must be a dictionary object with two attributes, `string` and `description`.

`dns_linode_key`<br>
The personal access token used to access the Linode DNS API service. This is self-evidently highly sensitive data.

`dns_upstream_nameservers`<br>
The IP addresses of upstream nameservers to configure in the DNS service. As the name suggests, these are the nameservers that Dnsmasq passes requests to that it is not configured to answer directly itself.

`domain_country`

`domain_linode_dynamic_dns_records`

`domain_locality`

`domain_name`<br>
The name of a domain corresponding to either our own internal services (`varilink.co.uk`) or those of a customer (e.g. `bennerleyviaduct.org.uk`).

`domain_organisation`<br>
The name of a domain's organisation for either our own internal services ("Varilink Computing Ltd") or those of a customer (e.g. "The Friends of Bennerley Viaduct").

`domain_organisation_unit`

`domain_smarthost_username`<br>
The username to use when connecting to our email gateway provider to send emails externally for a domain.

`domain_smarthost_userpass`<br>
The password to use when connecting to our email gateway provider to send emails externally for a domain.

`domain_state`

`domain_users`<br>
An array of users for either our own internal services domain (`varilink.co.uk`) or a customer domain (e.g. `bennerleyviaduct.org.uk`). Each entry in the domain can contain the following attributes:
- username
- passwd
- email
- fname
- lname

`dynamic_dns_crontab_stride`<br>
How many minutes within an hour between updates to dynamic DNS records. If this isn't set by a playbook or inventory then it takes the role's default value, which is fifteen minutes.

`dynamic_dns_records_dir`<br>
The directory that holds dynamic DNS entries for each supported domain. If this isn't set by a playbook or inventory then it takes the role's default value, which is `/usr/local/etc/dynamic-dns-domains`.

`home_domain`<br>
The home domain for any inventory as opposed to any customer domains that are served. In our case we set this to `varilink.co.uk`.

`host_enabled_for_ssl`<br>
This variable determines whether or not the capability to enable SSL for WordPress sites is enabled when the `reverse_proxy` role is deployed to a host. We serve all our WordPress sites from behind a reverse proxy, with the reverse proxy handling SSL if it is required for the site.

By default this is set to `yes`, which YAML recognises as boolean truth. It can be overridden to `no` on hosts on the internal network that will never serve WordPress sites externally and having so few staff that's what we do.

`hosts_to_roles_map`

`mail_uses_ca`<br>
Whether to use a Certification Authority or not (self-signed) for mail certificates. By default this is set to the boolean *true*, i.e. we do use a Certification Authority.

It's possible to override this to a value that Jinja evaluates as false in order to use self-signed certificates instead. This is sometimes useful during testing to avoid repeated requests to Let's Encrypt that might breach the threshold allowed for. The override can be applied at inventory level or for selected domains.

`mta_smarthost_hostname`<br>
The hostname of the smarthost that a host uses to relay emails. In our chosen topography for email services the mapping of hosts to smarthosts is as follows:
- All hosts on the internal office network with the exception of our internal mail server use our internal mail server as a smarthost.
- Our internal mail server uses our external mail servers as a smart host.
- All hosts on the Internet, external to our internal office network, with the exception of our external mail server use our external mail server as a smarthost.
- Our external mail server uses our email gateway service provider's smarthost.

`mta_smarthost_port`<br>
The port that a host uses when connecting to a smarthost to relay emails.

`mta_smarthost_username`<br>
The username that a host uses when connecting to a smarthost to relay emails.

`mta_smarthost_userpass`<br>

The password that a host uses when connecting to a smarthost to relay emails.

`office_subnet`<br>
The IP address mask for the office network. The internal mail server relays email unconditionally for clients on this network.

`unsafe_writes`<br>
If set to a true value, this enables the dns_client role to write to `/etc/hosts and /etc/resolv.conf` in an unsafe manner. This is necessary only in a Docker container environment because of the way that Docker mounts a copy of the host's `/etc/resolv.conf` file within containers. Hence this variable defaults to a false value, which is the value it should have in all other scenarios.

`wordpress_expose_externally`<br>
Whether to expose an Apache based WordPress service on the external network interface or not.

When we use Apache for WordPress sites we do so behind an Nginx reverse proxy, usually with both on the same host. Where this is the case, the Apache service should listen on the local network interface only, since it is only the reverse proxy on the same host that accesses it. For this reason a default value of *false* is set for this variable.

If a host for Apache WordPress sites is paired with an Nginx reverse proxy on another host, then this variable should be set to *true*, so that the Apache service listens on external interfaces and thus is available to the Nginx service.

Whatever is set for this variable on a host, it can be countermanded at a WordPress site level using the `wordpress_site_expose_externally` variable.

`wordpress_site_admin_email`<br>
When each WordPress site is created so is an initial administrator user account. This variable sets the email address for that account. It can be omitted, in which case the value of the `admin_user_email` variable will be used instead.

`wordpress_site_admin_password`<br>
The name of the administrator user account referred to in the description of the `wordpress_site_admin_email` variable. This can not be omitted.

`wordpress_site_admin_user`<br>
The name of the administrator user account referred to in the description of the `wordpress_site_admin_email` variable. This can also be omitted, in which case the value of the `admin_user` variable will be used instead.

`wordpress_site_client_max_body_size`<br>
If this variable is set then it dictates the maximum size for file uploads in WordPress in the web server(s). The value must still be adjusted in WordPress itself. If it isn't set then the default values apply.

`wordpress_site_database_host`<br>
The host that a WordPress site should use for its database. If this is omitted then it will be assumed that is the same host as the WordPress site is on.

`wordpress_site_database_password`<br>
The password that a WordPress site should use to connect to its database.

`wordpress_site_dns_host`<br>
The DNS host that provides domain resolution services for a WordPress site. The value of this variable is used to target a DNS host for adding DNS entries for the WordPress site using the `site_dns` role.

This variable only needs to be set if that is required. It could be for example that for a particular WordPress site we rely solely on manual DNS settings using Linode's DNS manager.

`wordpress_site_expose_externally`<br>
Whether an Apache based WordPress site is exposed on the external network interface - see `wordpress_expose_externally`. If this is omitted then the value of `wordpress_expose_externally` will apply.

`wordpress_site_plugins`<br>
If this is defined it should be a dictionary object, the keys of which are the names of plugins to be installed and activated for a WordPress site. Each of these may optionally have a `version` attribute set, which will of course dictate the version of the plugin to be installed. Note that any plugins that are present that are not listed in a provided `wordpress_site_plugins` variable will be deactivated if necessary and uninstalled.

`wordpress_site_reverse_proxy_pass_port`<br>
The port associated with a WordPress site that uses Apache. We implement our Apache WordPress service behind and Nginx reverse proxy, so this is the port that the reverse proxy will pass requests to for that WordPress site.

`wordpress_site_subdomain`<br>
The subdomain of a WordPress site. There can be multiple WordPress sites for a domain, each distinguished by a separate subdomain; for example 'www', 'test', etc.

`wordpress_site_uses_ca`

`wordpress_site_uses_ssl`<br>
This variable controls whether a WordPress site uses SSL or not. By default it is set to the same value as the variable `host_enabled_for_ssl`, so if a reverse proxy host is enabled for SSL then by default all the WordPress sites that it serves use SSL and if it isn't then by default all the WordPress sites that it serves don't use SSL.

If a reverse proxy host is enabled for SSL then its possible to override the default value of `wordpress_site_uses_ssl` when deploying WordPress sites to it. If you set the variable to `no` then the deployed WordPress site will **not** use SSL. You might do this for a reverse proxy host that serves some WordPress sites that are exposed externally and others that are only exposed internally.

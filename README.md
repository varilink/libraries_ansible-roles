# Libraries - Ansible

David Williamson @ Varilink Computing Ltd

------

## Overview

A library of Ansible [Roles](#roles) and [Common Task Lists](#common_task_lists) that are used in playbooks that automate the management of IT services that we use directly or to manage services that we provide to our customers.

## Roles

### Role Types and Dependencies

The roles in this library are one of three types:

1. *Host* - used by our [Services - Ansible](https://github.com/varilink/services-ansible) repo to deploy internal office and customer hosting services.

2. *Domain* - used in multiple Varilink projects' Ansible repos to deploy domain services such as an `@customer.com` email service for our customers.

3. *Site* - used in multiple Varilink projects' Ansible repos to deploy site services for our customers. There can be more than one site service for a customer's domain; for example `test.customer.com` and `www.customer.com`.

Each role can pull in one or more other roles. These can be registered as `dependencies` in the `meta/main.yml` file within the role as described under [Using role dependencies](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#using-role-dependencies) in the Ansible documentation. Alternatively other roles can be pulled in via tasks using either the [`import_role`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/import_role_module.html) or [`include_role`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_role_module.html) modules. This approach is needed when behaviour that can't be achieved using `dependencies` is required; for example pulling in the dependency when `tasks/main.yml` is executed but not when `tasks/delete.yml` is executed, or when tasks in the role pulled in must be delayed rather than run before the tasks in the role that has a dependency on it.

Some roles are only ever deployed *as a dependency only*, that is they are never *explicitly* deployed in playbooks but only when they are pulled in as a dependency of another role that is explicitly deployed.

The table below lists every role in this library and for each on gives that role's type, depedencies if it has any and how they are implemented and whether the role is deployed explicitly or as a dependency only.

| Role Name               | Type   | Dependencies                                                                                 | Deployed             |
| ----------------------- | ------ | -------------------------------------------------------------------------------------------- | -------------------- |
| backup_client           | Host   |                                                                                              | Explicitly           |
| backup_director         | Host   | backup_dropbox (task in `main.yml`)                                                          | Explicitly           |
| backup_dropbox          | Host   |                                                                                              | As a dependency only |
| backup_storage          | Host   | backup_dropbox (task in `main.yml`)                                                          | Explicitly           |
| calendar                | Host   |                                                                                              | Explicitly           |
| database                | Host   |                                                                                              | Explicitly           |
| dns                     | Host   |                                                                                              | Explicitly           |
| dns_api                 | Host   |                                                                                              | As a dependency only |
| dns_client              | Host   |                                                                                              | Explicitly           |
| domain_dns              | Domain | dns (`dependencies`)                                                                         | Explicitly           |
| domain_mail_certificate | Domain | mail_certificates (`dependencies`)                                                           | Explicitly           |
| domain_mail_external    | Domain | mail_external (`dependencies`)                                                               | Explicitly           |
| domain_mail_internal    | Domain | mail_internal (`dependencies`)                                                               | Explicitly           |
| dynamic_dns             | Host   | dns_api (`dependencies`)                                                                     | Explicitly           |
| home_domain_users       | Domain | mta (`dependencies`)                                                                         | As a dependency only |
| mail                    | Host   |                                                                                              | As a dependency only |
| mail_certificates       | Host   | dns_api (`dependencies`)                                                                     | Explicitly           |
| mail_external           | Host   | mail (`dependencies`)<br>mta (`dependencies`)                                                | Explicitly           |
| mail_internal           | Host   | mail (`dependencies`)<br>mta (`dependencies`)                                                | Explicitly           |
| mta                     | Host   |                                                                                              | As a dependency only |
| reverse_proxy           | Host   |                                                                                              | Explicitly           |
| site_dns                | Site   | dns (task in `main.yml` and `delete.yml`)                                                    | Explicitly           |
| site_reverse_proxy      | Site   | reverse_proxy (`dependencies`)                                                               | Explicitly           |
| site_wordpress          | Site   |                                                                                              | As a dependency only |
| site_wordpress_apache   | Site   | site_wordpress (`dependencies`)<br>wordpress_apache (`dependencies`)                         | Explicitly           |
| site_wordpress_database | Site   | database (task in `main.yml`)                                                                | Explicitly           |
| site_wordpress_nginx    | Site   | site_wordpress (task in `main.yml`)<br>wordpress_nginx (task in `main.yml` and `delete.yml`) | Explicitly           |
| wordpress               | Host   | mta (`dependencies`)                                                                         | As a dependency only |
| wordpress_apache        | Host   | wordpress (`dependencies`)                                                                   | Explicitly           |
| wordpress_nginx         | Host   | wordpress (task in `main.yml`)                                                               | Explicitly           |

### Role Descriptions

`backup_client`

Backup client service using the Bacula file daemon. This is deployed to every host that is backed up in my automated, backup schedule. It facilitates communication with the host by the Bacula Director and Bacula Storage Daemon services so that they may backup the host.

`backup_director`

Backup director service using the Bacula Director with a MySQL catalogue store.

`backup_dropbox`

Dropbox integration service for making off-site copies of backups. This is pulled in as a dependency by both the backup_director and backup_storage roles.

`backup_storage`

Backup storage service using the Bacula storage daemon.

`calendar`

CalDAV based calendar service using Radicale.

`database`

Database service based using MariaDB. This is used by both the backup_director service, to store the Bacula, backup catalogue and by web services, e.g. those based on WordPress, for website databases.

`dns`

A DNS service using Dnsmasq. We run Dnsmasq on our office network to supplement our ISP's DNS service with additional features.

`dns_api`

A very simple role that merely deploys the key for API access to Linode hosted DNS zones for use by both the email_certificates and dynamic_dns roles. We deploy this to a single host on our office network so that we're only holding our API access tokens in on place and that is on an internal host on the office network.

`dns_client`

Role that configures hosts on our internal, office network to use the DNS service provided on that network by the dns role.

`domain_dns`

Configures the DNS entries for a project domain on the internal DNS service.

`domain_dynamic_dns`

Configures the dynamic DNS entries for a project domain on our ISP's DNS service.

`domain_mail_certificate`

Generates and deploys an mail certificate for a project domain using the mail_certificates service.

`domain_mail_external`

Configures a domain on the host of the mail_external role so that we can provide a mail service for that domain.

`domain_mail_internal`

Configures a domain on the host of the mail_internal role so that we can provide a mail service for that domain.

`home_domain_users`

Creates operating system accounts for all our office staff on any host that requires them.

`dynamic_dns`

Keeps our Linode based DNS zones up to date with the dynamic IP address provided by our ISP for the office network for services that are hosted on-premise and exposed externally.

`mail`

Implements a mail server using Dovecot for hosts that provide a mail service.

`mail_certificates`

Provides SSL certificates that are either self-signed or obtained from Let's Encrypt for encrypting IMAP and SMTP connections.

`mail_external`

External (to the office network) mail service using Exim and Dovecot.

`mail_internal`

Internal (to the office network) mail service using Exim and Dovecot with Fetchmail integration to the external mail service.

`mta`

Implements a Mail Transfer Agent using Exim4 for all hosts.

`reverse_proxy`

Reverse proxy service using Nginx.

`site_reverse_proxy`

Configures a project domain on the reverse proxy using the reverse_proxy service.

`site_wordpress`

Configures a WordPress site on the WordPress service.

`site_wordpress_database`

Configures a WordPress site on the database service.

`wordpress`

WordPress service using Apache and PHP.

### Role Variables

The roles in this repo use a number of variables over and above any Ansible built-in variables. Some of these are internal to the roles only, i.e. it's never necessary for playbooks or the inventories used by those playbooks to set values for them. even if they are variables that are passed from one role to another role. Others could or must have their values set by playbooks that use these roles or their associated inventories.

The table below contains:
- All the variables that could or must have their values set by playbooks that use the roles in this repo.

- The roles that each of those variables is **used in**, as opposed to set by; for example, role A might declare role B as one of its dependencies and, in doing so, role A may set the value of a variable that role B uses but that role A does not use. In that example, the variable would identify role B as a role that it is *used in* but not role A.

- Whether playbooks or inventories used by those playbooks must (mandatory=yes) or could (optional, or mandatory=no) set a value for the variable. The default behaviour if a value is not set is described within the variable definitions that follow this table.

| Variable                               | Used in Role(s)                                                                                                                                                 | Mandatory? |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| admin_user                             | backup_client<br>backup_director<br>backup_storage<br>home_domain_admin_user                                                                                    | Yes        |
| admin_user_email                       | mail_certificates                                                                                                                                               | Yes        |
| backup_archive_media_directory         | backup_dropbox<br>backup_storage                                                                                                                                | No         |
| backup_client_director_password        | backup_client<br>backup_director                                                                                                                                | Yes        |
| backup_client_monitor_password         | backup_client                                                                                                                                                   | Yes        |
| backup_copy_folder                     | backup_director<br>backup_dropbox                                                                                                                               | No         |
| backup_database_host                   | backup_director                                                                                                                                                 | No         |
| backup_database_password               | backup_director<br>database                                                                                                                                     | No         |
| backup_database_user                   | backup_director<br>database                                                                                                                                     | No         |
| backup_director_console_password       | backup_director                                                                                                                                                 | Yes        |
| backup_director_host                   | database                                                                                                                                                        | No         |
| backup_director_monitor_password       | backup_director                                                                                                                                                 | Yes        |
| backup_director_name                   | backup_client<br>backup_director<br>backup_storage                                                                                                              | Yes        |
| backup_director_schedules_active       | backup_director                                                                                                                                                 | No         |
| backup_monitor_name                    | backup_client<br>backup_director<br>backup_storage                                                                                                              | Yes        |
| backup_storage_director_password       | backup_director<br>backup_storage                                                                                                                               | Yes        |
| backup_storage_monitor_password        | backup_storage                                                                                                                                                  | Yes        |
| backup_storage_host                    | backup_director                                                                                                                                                 | Yes        |
| backup_storage_name                    | backup_storage                                                                                                                                                  | Yes        |
| database_expose_externally             | database                                                                                                                                                        | No         |
| dns_client_nameservers                 | dns_client                                                                                                                                                      | Yes        |
| dns_client_options                     | dns_client                                                                                                                                                      | No         |
| dns_host_patterns                      | dns                                                                                                                                                             | Yes        |
| dns_linode_key                         | dns_api<br>dynamic_dns                                                                                                                                          | Yes        |
| dns_upstream_nameservers               | dns                                                                                                                                                             | Yes        |
| domain_name                            | domain_dns<br>domain_mail_certificate<br>domain_mail_external<br>domain_mail_internal<br>dynamic_dns<br>site_dns<br>site_reverse_proxy<br>site_wordpress_apache | Yes        |
| domain_organisation                    | site_wordpress                                                                                                                                                  | Yes        |
| domain_smarthost_username              | domain_mail_external                                                                                                                                            | Yes        |
| domain_smarthost_userpass              | domain_mail_external                                                                                                                                            | Yes        |
| domain_users                           | domain_mail_external<br>domain_mail_internal<br>home_domain_users                                                                                               | Yes        |
| dynamic_dns_crontab_stride             | dynamic_dns                                                                                                                                                     | No         |
| dynamic_dns_domains_dir                | dynamic_dns                                                                                                                                                     | No         |
| home_domain                            | backup_director<br>backup_storage<br>dns<br>dns_client<br>domain_dns<br>domain_mail_external<br>domain_mail_internal<br>mail_external<br>mail_internal<br>mta   | Yes        |
| mail_uses_ca                           | domain_mail_certificate<br>domain_mail_external<br>mail_certificates                                                                                            | No         |
| mta_smarthost_hostname                 | mta                                                                                                                                                             | Yes        |
| mta_smarthost_port                     | mta                                                                                                                                                             | Yes        |
| mta_smarthost_username                 | mta                                                                                                                                                             | Yes        |
| mta_smarthost_userpass                 | mta                                                                                                                                                             | Yes        |
| office_subnet                          | mail_internal                                                                                                                                                   | Yes        |
| reverse_proxy_uses_ssl                 | reverse_proxy<br>site_reverse_proxy                                                                                                                             | No         |
| unsafe_writes                          | dns_client                                                                                                                                                      | No         |
| wordpress_expose_externally            | site_wordpress_apache                                                                                                                                           | No         |
| wordpress_site_admin_email             | site_wordpress                                                                                                                                                  | No         |
| wordpress_site_admin_password          | site_wordpress                                                                                                                                                  | Yes        |
| wordpress_site_admin_user              | site_wordpress                                                                                                                                                  | No         |
| wordpress_site_client_max_body_size    | site_wordpress_nginx                                                                                                                                            | No         |
| wordpress_site_dns_host                | site_dns                                                                                                                                                        | No         |
| wordpress_site_expose_externally       | site_wordpress_apache                                                                                                                                           | No         |
| wordpress_site_plugins                 | site_wordpress                                                                                                                                                  | No         |
| wordpress_site_subdomain               | site_dns<br>site_reverse_proxy<br>site_wordpress_apache                                                                                                         | Yes        |
| wordpress_site_uses_ssl                | site_reverse_proxy                                                                                                                                              | No         |
| wordpress_site_database_host           | site_wordpress<br>site_wordpress_database                                                                                                                       | No         |
| wordpress_site_database_password       | site_wordpress<br>site_wordpress_database                                                                                                                       | Yes        |
| wordpress_site_reverse_proxy_pass_port | site_reverse_proxy<br>site_wordpress_apache                                                                                                                     | Yes        |

A description of each of the variables in the table above now follows.

`admin_user`

The operating system user login for the main admin user who supports the Varilink services. Of course this is always a user in the `home_domain`.

`admin_user_email`

The email address for the `admin_user`. This is not simply `admin_user`@`home_domain` since we use first names only for our office network logins but we use `fname.lname` for our email addresses.

`backup_archive_media_directory`

The directory that the backup storage daemon uses to store archive media in. This defaults to `/var/local/bacula` unless an alternative value is provided via the playbook or inventory.

`backup_client_director_password`

The password that the backup director must use to connect to a backup client. For good security, this should be unique to each backup client and meet length and complexity standards.

`backup_client_monitor_password`

The password that the backup monitor must use to connect to a backup client. For good security, this should be unique to each backup client and meet length and complexity standards. Unlike the backup director, the backup monitor is a desktop application and so there is no role in this library corresponding to it.

`backup_copy_folder`

The top-level folder within Dropbox for off-site copies of backup files. This defaults to `bacula` unless and alternative value if provided via the playbook or inventory.

`backup_database_host`

The host of the database that's used to store the backup catalogue. This can be omitted in which case the backup director will assume that the backup database is co-located on the same host as itself and use a local socket connection to the database.

`backup_database_password`

The password that the backup director uses to connect to the backup database. If this is omitted it will default to "bacula". A more secure value should be provided.

`backup_database_user`

The user that the backup director uses to connect to the backup database.  If this is omitted it will default to "bacula". A more secure value should be provided.

`backup_director_console_password`

The password that the backup console must use to connect to the backup director. The backup console is a desktop application and so there is no role in this library corresponding to it.

`backup_director_host`

The host of the backup director. This is used when creating the backup user account in the backup database. If it is omitted then it will be assumed that the backup director is co-located with the host of the backup database.

`backup_director_monitor_password`

The password that the backup monitor must use to connect to the backup director. For good security, this should meet length and complexity standards. The backup monitor is a desktop application and so there is no role in this library corresponding to it.

`backup_director_name`

The name by which the backup director identifies itself to backup clients and the backup storage daemon.

`backup_director_schedules_active`

Whether the backup schedules are active or not. By default this is set to the boolean true value. It only needs to be set in a playbook or inventory if a value that Jinja evaluates to false is required in order to disable automatic backup job scheduling. This can be useful during testing of backup jobs when it's convenient to run them manually instead.

`backup_monitor_name`

The name by which the backup monitor identifies itself to backup clients, the backup director and the backup storage daemon.

`backup_storage_director_password`

The password that the backup director must use to connect to the backup storage daemon. For good security, this should meet length and complexity standards.

`backup_storage_monitor_password`

The password that the backup monitor must use to connect to the backup storage daemon. For good security, this should meet length and complexity standards.

`backup_storage_host`

The host of the storage daemon that the backup director must connect to.

`backup_storage_name`

The name by which the backup storage daemon identifies itself.

`database_expose_externally`

Whether to expose the database service on a database host to the external network interface or not.

If this isn't set then it defaults to the boolean value false, meaning that the database service is not exposed to the external network interface. This is fine so long as services that use that database are on the same host. If that's the case then obviously for security reasons the database service should not be exposed externally.

If services external to the database host use its database service then this should be set to a value that Jinja understands to be true.

`dns_client_nameservers`

The IP addresses of DNS nameservers that a DNS client should use. These are used in the `/etc/resolv.conf` file for each host.

`dns_client_options`

Options to be set in the `/etc/resolv.conf` file for each host. If this is provided then it must be an array of strings, each of which will be added after `option` in a line within `/etc/resolv.conf`. This variable can be omitted if there are no options to set.

`dns_host_patterns`

An array of pattern strings to match hostnames to and their corresponding descriptions. These are used to determine the hosts that a DNS server will provide resolution services for. Each member of the array must be a dictionary object with two attributes, `string` and `description`.

`dns_linode_key`

The personal access token used to access the Linode DNS API service. This is self-evidently highly sensitive data.

`dns_upstream_nameservers`

The IP addresses of upstream nameservers to configure in the DNS service. As the name suggests, these are the nameservers that Dnsmasq passes requests to that it is not configured to answer directly itself.

`domain_name`

The name of a domain corresponding to either our own internal services (`varilink.co.uk`) or those of a customer (e.g. `bennerleyviaduct.org.uk`).

`domain_organisation`

The name of a domain's organisation for either our own internal services ("Varilink Computing Ltd") or those of a customer (e.g. "The Friends of Bennerley Viaduct").

`domain_smarthost_username`

The username to use when connecting to our email gateway provider to send emails externally for a domain.

`domain_smarthost_userpass`

The password to use when connecting to our email gateway provider to send emails externally for a domain.

`domain_users`

An array of users for either our own internal services domain (`varilink.co.uk`) or a customer domain (e.g. `bennerleyviaduct.org.uk`). Each entry in the domain can contain the following attributes:
- username
- passwd
- email
- fname
- lname

`dynamic_dns_crontab_stride`

How many minutes within an hour between updates to dynamic DNS records. If this isn't set by a playbook or inventory then it takes the role's default value, which is fifteen minutes.

`dynamic_dns_domains_dir`

The directory that holds dynamic DNS entries for each supported domain. If this isn't set by a playbook or inventory then it takes the role's default value, which is `/usr/local/etc/dynamic-dns-domains`.

`home_domain`

The home domain for any inventory as opposed to any customer domains that are served. In our case we set this to `varilink.co.uk`.

`mail_uses_ca`

Whether to use a Certification Authority or not (self-signed) for mail certificates. By default this is set to the boolean *true*, i.e. we do use a Certification Authority.

It's possible to override this to a value that Jinja evaluates as false in order to use self-signed certificates instead. This is sometimes useful during testing to avoid repeated requests to Let's Encrypt that might breach the threshold allowed for. The override can be applied at inventory level or for selected domains.

`mta_smarthost_hostname`

The hostname of the smarthost that a host uses to relay emails. In our chosen topography for email services the mapping of hosts to smarthosts is as follows:
- All hosts on the internal office network with the exception of our internal mail server use our internal mail server as a smarthost.
- Our internal mail server uses our external mail servers as a smart host.
- All hosts on the Internet, external to our internal office network, with the exception of our external mail server use our external mail server as a smarthost.
- Our external mail server uses our email gateway service provider's smarthost.

`mta_smarthost_port`

The port that a host uses when connecting to a smarthost to relay emails.

`mta_smarthost_username`

The username that a host uses when connecting to a smarthost to relay emails.

`mta_smarthost_userpass`

The password that a host uses when connecting to a smarthost to relay emails.

`office_subnet`

The IP address mask for the office network. The internal mail server relays email unconditionally for clients on this network.

`reverse_proxy_uses_ssl`

Whether a reverse proxy host uses SSL, if it's externally facing then the answer should be "Yes" but if it's internally facing only then we may choose that it doesn't.

This is defaulted to boolean *true* so that configuring a reverse proxy host to not use SSL must be done explicitly, by setting a value that Jinja recognises as false.

Whatever the value of this variable, SSL can be required or not for proxied WordPress sites via the `wordpress_site_uses_ssl` variable.

`unsafe_writes`

If set to a true value, this enables the dns_client role to write to `/etc/hosts and /etc/resolv.conf` in an unsafe manner. This is necessary only in a Docker container environment because of the way that Docker mounts a copy of the host's `/etc/resolv.conf` file within containers. Hence this variable defaults to a false value, which is the value it should have in all other scenarios.

`wordpress_expose_externally`

Whether to expose an Apache based WordPress service on the external network interface or not.

When we use Apache for WordPress sites we do so behind an Nginx reverse proxy, usually with both on the same host. Where this is the case, the Apache service should listen on the local network interface only, since it is only the reverse proxy on the same host that accesses it. For this reason a default value of *false* is set for this variable.

If a host for Apache WordPress sites is paired with an Nginx reverse proxy on another host, then this variable should be set to *true*, so that the Apache service listens on external interfaces and thus is available to the Nginx service.

Whatever is set for this variable on a host, it can be countermanded at a WordPress site level using the `wordpress_site_expose_externally` variable.

`wordpress_site_admin_email`

When each WordPress site is created so is an initial administrator user account. This variable sets the email address for that account. It can be omitted, in which case the value of the `admin_user_email` variable will be used instead.

`wordpress_site_admin_password`

The name of the administrator user account referred to in the description of the `wordpress_site_admin_email` variable. This can not be omitted.

`wordpress_site_admin_user`

The name of the administrator user account referred to in the description of the `wordpress_site_admin_email` variable. This can also be omitted, in which case the value of the `admin_user` variable will be used instead.

`wordpress_site_client_max_body_size`

If this variable is set then it dictates the maximum size for file uploads in WordPress in the web server(s). The value must still be adjusted in WordPress itself. If it isn't set then the default values apply.

`wordpress_site_dns_host`

The DNS host that provides domain resolution services for a WordPress site. The value of this variable is used to target a DNS host for adding DNS entries for the WordPress site using the `site_dns` role.

This variable only needs to be set if that is required. It could be for example that for a particular WordPress site we rely solely on manual DNS settings using Linode's DNS manager.

`wordpress_site_expose_externally`

Whether an Apache based WordPress site is exposed on the external network interface - see `wordpress_expose_externally`. If this is omitted then the value of `wordpress_expose_externally` will apply.

`wordpress_site_plugins`

If this is defined it should be a dictionary object, the keys of which are the names of plugins to be installed and activated for a WordPress site. Each of these may optionally have a `version` attribute set, which will of course dictate the version of the plugin to be installed. Note that any plugins that are present that are not listed in a provided `wordpress_site_plugins` variable will be deactivated if necessary and uninstalled.

`wordpress_site_subdomain`

The subdomain of a WordPress site. There can be multiple WordPress sites for a domain, each distinguished by a separate subdomain; for example 'www', 'test', etc.

`wordpress_site_uses_ssl`

Whether a WordPress site uses SSL or not - see `reverse_proxy_uses_ssl`. If this variable is omitted then the value of `wordpress_site_uses_ssl` will apply.

`wordpress_site_database_host`

The host that a WordPress site should use for its database. If this is omitted then it will be assumed that is the same host as the WordPress site is on.

`wordpress_site_database_password`

The password that a WordPress site should use to connect to its database.

`wordpress_site_reverse_proxy_pass_port`

The port associated with a WordPress site that uses Apache. We implement our Apache WordPress service behind and Nginx reverse proxy, so this is the port that the reverse proxy will pass requests to for that WordPress site.

### Setting Role Variable Values

To use this repo it is necessary to set values for the variables described above correctly and to carefully choose where to set them, since Ansible offers a multitude of options in this respect. There follows a guide on where to define those variables in playbooks and the inventories that those playbooks use.

For a real-world example of defining values for the variables used in this library, see my [Services - Docker](https://github.com/varilink/services-docker) repo. Since this repo is only used for testing this library, it is able to make public more than those repos that deploy to our live server estate can.

#### Host Roles

Within the inventory I assign variable values for either groups or hosts. Where values are assigned is dictated by the scope that the value is valid for and not the scope of usage. For example, if a value is good wherever it miay be used then it is set in the "All" group even though it may not be used by all the hosts. There is a hierarchy to value assignment, so I may set a value for the group All and override it for specific hosts rather than put those hosts in separate groups.

This table below shows where variables should be assigned in the host inventory for a playbook that uses this role library. The meaning of the columns in this table are:
- Group/Host = Variable assignment at group or host level.
- Group or Host Role Name = For a group, the name of the group. For a host, the name of a role that is deployed to the host.
- Mandatory/Optional = Whether it is mandatory or optional to set the varaible here in the inventory. Optional only applies when choosing to override a role's default value for the variable.
- Variables = The list of variables that values should be assigned to.

You can see this in action in the inventory variables within my [Services - Docker](https://github.com/varilink/services-docker) repository, so that's a good guide for further understanding.

| Group/Host | Group or Host Role Name | Mandatory/Optional | Variables                                                                                                                                                                                                                                                                                                                                                                       |
| ---------- | ----------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Group      | all                     | Mandatory          | backup_database_host<br />backup_database_password<br />backup_database_username<br />backup_director_console_password<br />backup_director_name<br />backup_monitor_name<br />backup_storage_host<br />backup_storage_name<br />backup_storage_password<br />dns_linode_key<br />home_domain<br />home_domain_admin_user<br />home_domain_admin_user_passwd<br />office_subnet |
|            |                         | Optional           | backup_copy_folder<br />backup_director_schedules_active<br />dynamic_dns_crontab_stride<br />mail_uses_ca<br />unsafe_writes                                                                                                                                                                                                                                                   |
|            | external                | Mandatory          | dns_resolvers<br />mta_smarthost                                                                                                                                                                                                                                                                                                                                                |
|            | internal                | Mandatory          | dns_resolvers<br />mta_smarthost                                                                                                                                                                                                                                                                                                                                                |
| Host       | backup_client           | Mandatory          | backup_client_director_password<br />backup_client_monitor_password                                                                                                                                                                                                                                                                                                             |
|            | database                | Optional           | database_expose_externally                                                                                                                                                                                                                                                                                                                                                      |
|            | dns                     | Mandatory          | dns_group<br />dns_resolvers<br />dns_upstream_nameservers                                                                                                                                                                                                                                                                                                                      |
|            |                         | Optional           | dns_mx_host                                                                                                                                                                                                                                                                                                                                                                     |
|            | mail_externl            | Mandatory          | mta_local_interfaces<br />mta_relay_nets<br />mta_smarthost                                                                                                                                                                                                                                                                                                                     |
|            | mail_internal           | Mandatory          | mta_smarthost                                                                                                                                                                                                                                                                                                                                                                   |
|            | reverse_proxy           | Optional           | reverse_proxy_uses_ssl                                                                                                                                                                                                                                                                                                                                                          |
|            | wordpress               | Optional           | wordpress_expose_externally                                                                                                                                                                                                                                                                                                                                                     |

#### Domain / Site Roles

| Name   | Description | Used in Role(s)                                                                                                         |
| ------ | ----------- | ----------------------------------------------------------------------------------------------------------------------- |
| domain |             | domain_mail<br />domain_mail_certificate<br />domain_reverse_proxy<br />domain_wordpress<br />domain_wordpress_database |






## Common Task Lists

The task lists are contained in folders that start with an underscore, so that they are not confused with the roles since this is invalid in Ansible role names.











-----




that are maintained by Varilink to automate the maintenance of the IT services that we use.







A library of Ansible roles maintained and used by Varilink. The *primary* roles fall into two categories, which are used in two different places in the Varilink GitHub repositories:

1. Host roles, used in the [Services - Ansible](https://github.com/varilink/services-ansible) repository to deploy hosting services across the Varilink server estate.

2. Domain roles, used in multiple Varilink projects' Ansible repositories, which use them to deploy projects (or "sites") in test and live environments.

My [Services - Docker](https://github.com/varilink/services-docker) repository provides a Docker Compose wrapper that facilitates the testing of the Ansible roles defined here using Docker containers as the Ansible deployment targets.

The word *primary* above refers to those roles that are explicitly deployed in playbooks. There are other roles containing functionality that is common to more than one primary role, which are only ever pulled into a deployment as dependencies. These roles are not explicitly deployed.

There follows lists of the *Host Roles*, *Domain Roles* and *Common Functionality Foles* that are defined in this repository, along with a brief description of each.

## Roles in this Repository

### Host Roles

### Domain Roles

### Common Functionality Roles




Something about tags set for each role to isolate tasks.

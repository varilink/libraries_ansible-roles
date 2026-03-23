# Libraries - Ansible Roles

David Williamson @ Varilink Computing Ltd

------

A library of Ansible roles that are used in playbooks to automate the management of Varilink Computing Ltd's IT services. We either use those services internally within Varilink Computing Ltd or to provide services to our customers.

The services are:

- Backup of the hosts that we operate.
- Calendars, including task lists, for our staff.
- DNS lookup, both via our internal network's DNS service and our external DNS provider using their APIs.
- Dynamic DNS lookup for services hosted on our internal network that we expose externally via our ISP's dynamically provisioned IP address.
- Staff file shares on our office network.
- A private Git origin for repositories that we choose not to push to GitHub, even as private GitHub repositories.
- Mail for our own domain and for the domains of our customers.
- Monitoring and alerting for our hosts and services.
- WordPress hosting of our own website and those of our customers.

This library of Ansible roles is used by the playbooks in our [Libraries - Ansible Playbooks](https://github.com/varilink/libraries_ansible-playbooks) and examining both repositories together is much more instructive than examining either repository in isolation. My [Services - Docker](https://github.com/varilink/services-docker) repository provides the automated means to test these Ansible playbooks and roles in container based test environments and so is an ideal place to start if you want to understand them better - see also my blog post [Testing Ansible Roles Using Containers](https://www.varilink.co.uk/testing-ansible-roles-using-containers/).

## Roles

The table [List of Roles](#list-of-roles) below lists the roles defined in this repository by **Role Name**. It indicates whether each role is **Deployed** *explicitly* to a host or only as a *dependency* of another role and also, for each role, which other roles are pulled in as **Dependencies**.

Explicitly deployed roles are those that are imported directly into playbooks in the [Libraries - Ansible Playbooks](https://github.com/varilink/libraries_ansible-playbooks) repository; principally the [`install-services.yml`](https://github.com/varilink/libraries_ansible-playbooks/blob/main/install-services.yml) playbook. Those that are instead deployed as dependencies are imported by other roles. Note that design choice to implement role dependences using the `import_role` module rather than as meta role dependencies, preferring control over declarative dependency management.

Role dependencies in a broader sense are also implemented in playbooks. Again if you examine the [`install-services.yml`](https://github.com/varilink/libraries_ansible-playbooks/blob/main/install-services.yml) playbook, you will note, for example, that the play that imports the [backup_director](#backup_director) role first imports the [database](#database) role, because the Bacula director requires a database to store its catalog in. These dependences are **not** shown in the [List of Roles](#list-of-roles) table as it only shows dependencies implemented by the import of one role from within another role. This is to a degree an arbitrary distinction, which is an implementation detail. Implementing role dependencies in the playbook does provide the option to distribute service across hosts; for example to locate the Bacula director's database on a different host to the Bacula director service itself.

Where **Deployed** is shown as "N/A" (not applicable) the role actually defines no tasks and so I highlight that it isn't deployed as such to any host. These roles exist solely to provide other, non-task, shared artefacts that can be imported to other roles; for example, variables. Roles that do not provide tasks are never shown in the "Dependencies" column either.

Some roles that do define tasks are imported into some roles to execute those tasks but imported into other roles with `tasks_from: none` where `tasks/none.yml` in the role being imported contains an empty task list. Where this happens, the import is of course to provide access to other artefacts; for example handlers, that are defined in the role being imported. Where this is the case, we do not show a relationship between the two roles in the **Dependencies** column. In summary, the **Dependencies** column only ever shows task dependencies.

The table also indicates the deployment **Levels** that are encapsulated within each role; for example, the [wordpress_apache](#wordpress_apache) role's *main* task list deploys the core WordPress *host* service, whereas its *create-site* task list deploys a WordPress *site* on to that *host* service.

The deployment levels implemented by roles within this repository are:

- host - As above, the core service onto which a domain, project, site or user can be configured.
- domain - For example, the configuration of the mail service or the creation of all required dynamic DNS records for example.com.
- site - As above, the configuration of a WordPress site; for example, test.example.com or www.example.com.
- user - Tasks that are applied per user.

### List of Roles

| Role Name         | Deployed   | Dependencies                                      | Levels                 |
| ------------------| ---------- | ------------------------------------------------- | ---------------------- |
| backup            | N/A        |                                                   | N/A                    |
| backup_client     | explicitly |                                                   | host                   |
| backup_director   | explicitly | backup_dropbox <sup>1</sup><br>mta                | host                   |
| backup_dropbox    | dependency |                                                   | host                   |
| backup_storage    | explicitly | backup_dropbox <sup>1</sup>                       | host                   |
| backup_web        | explicitly | nginx<br>php_fpm                                  | host                   |
| calendar          | explicitly |                                                   | host<br>domain         |
| database          | explicitly |                                                   | host<br>site           |
| dns               | explicitly |                                                   | host<br>domain<br>site |
| dns_api           | explicitly |                                                   | host                   |
| dns_client        | explicitly |                                                   | host                   |
| dynamic_dns       | explicitly | dns_api <sup>2</sup>                              | host<br>domain         |
| file_share        | explicitly | staff_user                                        | host<br>user           |
| git_origin        | explicitly |                                                   | host                   |
| influxdata        | dependency |                                                   | host                   |
| mail              | dependency | database<br>mta<br>nginx<br>php_fpm<br>staff_user | host<br>user           |
| mail_certificates | explicitly | dns_api <sup>2</sup>                              | host<br>domain         |
| mail_external     | explicitly | mail                                              | host<br>domain         |
| mail_internal     | explicitly | mail                                              | host<br>domain         |
| monitor_client    | explicitly | influxdata                                        | host                   |
| monitor_dashboard | explicitly |                                                   | host                   |
| monitor_gateway   | explicitly | nginx                                             | host                   |
| monitor_server    | explicitly | influxdata                                        | host                   |
| mta               | explicitly |                                                   | host                   |
| nginx             | dependency |                                                   | host<br>site           |
| php_fpm           | dependency |                                                   | host                   |
| reverse_proxy     | explicitly | nginx                                             | host<br>site           |
| staff_user        | dependency |                                                   | user                   |
| wordpress         | dependency |                                                   | host<br>site           |
| wordpress_apache  | explicitly | wordpress                                         | host<br>site           |

> <sup>1</sup> Only if the backup service is integrated with [Dropbox](https://www.dropbox.com/) for offline copy of backup media - see [Integration with Third-Party Cloud Services](#integration-with-third-party-cloud-services) below.

> <sup>2</sup> Only if integration with the [Akamai](https://www.linode.com/) (formerly Linode) domain management services is enabled - see [Integration with Third-Party Cloud Services](#integration-with-third-party-cloud-services) below.

### Role Descriptions and Notes

For each of the roles listed in the table [List of Roles](https://github.com/varilink/libraries_ansible-roles?tab=readme-ov-file#list-of-roles) above there follows:
1. A brief descripton of the role.
2. **Optionally** (not for every role) a note or notes by topic that pertain to the use of the role.

#### backup

This role exists solely to provide the configuration for backing up the Bacula configuration. It is imported by the [backup_client](#backup_client), [backup_director](#backup_director) and [backup_storage](#backup_storage).

#### backup_client

Backup client based on the [Bacula Client](https://bacula.org/whitepapers/ConceptGuide.pdf#section.1.4) - see [What is Bacula?](https://bacula.org/whitepapers/ConceptGuide.pdf#chapter.1)

This is deployed to every host that is backed up in my automated, backup schedule. It facilitates communication with the host by the [backup_director](#backup_director) and [backup_storage](#backup_storage) roles so that they may backup the host.

#### backup_director

Backup director service based on the [Bacula Director](https://bacula.org/whitepapers/ConceptGuide.pdf#section.1.2) and using MariaDB to store its [Catalog](https://bacula.org/whitepapers/ConceptGuide.pdf#section.1.6).

##### Automated, role based, Bacula FileSet configuration

The [backup_director](#backup_director) role deploys a `bacula-dir.conf` file that defines a Bacula FileSet specific to each host that is backed up. It does this, first by reference to the [hosts_to_roles_map](#hosts_to_roles_map) variable and then by reference to the variables defined in the `vars/bacula-fileset.yml` file of roles that contain one.

If a role contains a `vars/bacula-fileset.yml` file then it must contain a single variable who name is the name of the role. That variable must be a dictionary variable that contains one or both of included_files and included_roles keys. The values for those keys must be arrays with the contents as follows:

**included_files**

The items in the included_files list are used by the [backup_director](#backup_director) role to build Include blocks within the FileSet for hosts that the role is deployed to. Those items can be one of two types:

1. A string

Items that are strings will all be used in a single Include block as the values of File options within that Include block.

For example:

```yaml
- "/etc/dovecot/"
- "/etc/roundcube/"
```

Is translated into an Include block as follows:

```conf
Include {

  File = /etc/dovecot/
  File = /etc/roundcube

  Options { 

    Compression = GZIP
    Signature = MD5

  }

}
```

2. An array

The items of the array must be a string and another array of dictionary variables. These array items in included_files will be translated one-to-one to Include blocks, **not** combined into a single block. The subitems are used in that Include block as follows:
- The string as above is used as the value of a File option.
- The array of dictionary variables are used as options within an Options block or blocks for the Include block. There will be a separate Options block created for any dictionary variable that contains the key "Exclude" with a positive value.

For example:

```yaml
- ["/home/",
    [ 
      {
        RegExDir: '"^/home/[^/]+$"',
        WildDir: '"/home/*/Maildir"',
        Wild: '"/home/*/Maildir/*"'
      },
      {
        Exclude: "yes",
        Wild: '"/home/*"'
      }
    ]
  ]
```

Is translated into an Include block as follows:

```conf
Include {

  File = /home/

  Options {

    Compression = GZIP
    Signature = MD5
    RegExDir = "^/home/[^/]+$"
    WildDir = "/home/*/Maildir"
    Wild = "/home/*/Maildir/*"

  }

  Options {

    Exclude = yes
    Wild = "/home/*"

  }
}
```

**included_roles**

The items in the included_roles list are used by the [backup_director](#backup_director) role to supplement the list of roles for hosts taken from the [host_to_roles_map](#host_to_roles_map). When it produces the FileSet for a host it drills-down from the list of roles for that host in the [host_to_roles_map](#host_to_roles_map) by following any chain of included_roles and add those included roles to the list. Roles in included_roles can themselves provide a list of roles in their own included_roles.

The purpose of this facility is to be able to specify common included_files values for more than one role but associating that list with a role that is included into other roles via included_roles. For example, the [backup_client](#backup_client), [backup_director](#backup_director) and [backup_storage](#backup_storage) roles all take their configuration from the `/etc/bacula/` directory. So, `/etc/bacula/` is specified in the included_file for the [backup](#backup) role and that role is then specified in included_roles for the [backup_client](#backup_client), [backup_director](#backup_director) and [backup_storage](#backup_storage) roles.

#### backup_dropbox

[Dropbox](https://www.dropbox.com/) integration for making off-site copies of the backup media created by backups of on-site hosts for disaster recovery purposes. This is a dependency of both the [backup_director](#backup_director) and [backup_storage](#backup_storage) roles if backup integration with [Dropbox](https://www.dropbox.com/) is enabled.

#### backup_storage

Backup storage service based on the [Bacula Storage](https://bacula.org/whitepapers/ConceptGuide.pdf#section.1.5) component.

#### backup_web

Installs the [Bacula-Web](https://www.bacula-web.org/) open source reporting and monitoring tool for Bacula. We use this to provide a web dashboard and reports for the backup service.

#### calendar

[CalDAV](https://en.wikipedia.org/wiki/CalDAV) based calendar service (including task lists) based on the [Radicale](https://radicale.org/) CalDAV and CardDAV server.

#### database

Database service based on the [MariaDB server](https://mariadb.org/). This is used by the:
- [backup_director](#backup_director) role to store its catalog.
- [wordpress](#wordpress) role for its site databases.
- [mail_external](#mail_external) and [mail_internal](#mail_internal) roles for their Roundcube database.

#### dns

[DNS](https://en.wikipedia.org/wiki/Domain_Name_System) service based on [Dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html). We run Dnsmasq on our office network to supplement our ISP's DNS service with additional lookups for hosts, services and projects that are required on that office network.

#### dns_api

A very simple role that merely deploys the key for API access to [Akamai](https://www.linode.com/) (formerly Linode) hosted DNS zones for use by both the [mail_certificates](#mail_certificates) and [dynamic_dns](#dynamic_dns) roles, if integration with the Akamai domain management service is enabled - see [Integration with Third-Party Cloud Services](#integration-with-third-party-cloud-services) below.

We deploy this to a single host on our office network so that we're only holding our API access tokens in one place and that is not on a public network.

#### dns_client

Role that configures hosts on our office network to use the DNS service provided on that network by the [dns](#dns) role.

#### dynamic_dns

Keeps our [Akamai](https://www.linode.com/) based DNS zones up to date with the dynamic IP address provided by our ISP. We do this so that we may expose some services that are hosted on our office network externally without requiring a fixed IP address for our Internet connection.

#### file_share

Provide the file share service to our staff users using the [Samba](https://www.samba.org/) implementatin of the SMB and Active Directory protocols for Linux.

#### git_origin

Implements our internal Git remote repository service that we use instead of [GitHub](https://github.com/) for our private Git repositories.

#### influxdata

Implements the [InfluxDB](https://www.influxdata.com/) time series database which our monitoring service uses.

#### mail

Implements an IMAP mail server based on [Dovecot](https://www.dovecot.org/) along with a [Roundcube](https://roundcube.net/) webmail services for hosts that provide a mail service, either internally using our own domain or for customer domains.

In our mail architecture we have two such hosts, one on our office network for our internal staff using the [mail_internal](#mail_internal) role and one hosted externally using the [mail_external](#mail_external).

#### mail_certificates

Provides SSL certificates that are obtained from [Let's Encrypt](https://letsencrypt.org/) for encrypting IMAP and SMTP connections to our mail services.

#### mail_external

External (to the office network) mail service using [Exim](https://www.exim.org/) as a Mail Transfer Agent. [Dovecot](https://www.dovecot.org/) as an IMAP mail server and [Roundcube](https://roundcube.net/) as a webmail service, via the [mta](#mta) and [mail][#mail] roles respectively.

#### mail_internal

Internal (to the office network) mail service using Exim, Dovecot and Roundcube exactly as the [mail_external](#mail_external) role does. It integrates with the [mail_external](#mail_external) role by using it as an SMTP relay for sending emails from our office network to recipients outside of that network and using [Fetchmail](https://www.fetchmail.info/) to fetch emails sent to us.

#### monitor_client

Implements the [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) agent for collecting metrics and the [InfluxDB](https://www.influxdata.com/) time series database to store those metrics to any host that our monitoring service reports on.

#### monitor_dashboard

Installs [Grafana](https://grafana.com/) as the visualisatin tool to provide the dashboards for our monitoring service.

#### monitor_gateway

Implements a monitoring network gateway that our external hosts that are monitored use to route their collected metrics towards the monitoring server on our office network.

#### monitor_server

Implements the [InfluxDB](https://www.influxdata.com/) time series database to hold the collected metrics from all monitored hosts from where the monitoring dashboard can access that data.

#### mta

Implements a [Mail Transfer Agent](https://en.wikipedia.org/wiki/Message_transfer_agent) using Exim4 for all hosts that need to send or receive emails.

#### nginx

Implements [NGINX](https://nginx.org/), which we use as a reverse proxy for our WordPress service and our onsite [InfluxDB](https://www.influxdata.com/) time series database and also as the web server layer for our [Roundcube](https://roundcube.net/) webmail and [Bacula-Web](https://www.bacula-web.org/) open source reporting and monitoring tool for Bacula services.

#### php_fpm

A PHP-FPM (FastCGI Process Manager) which we use for our [Roundcube](https://roundcube.net/) webmail and [Bacula-Web](https://www.bacula-web.org/) open source reporting and monitoring tool for Bacula services that are based on PHP.

#### reverse_proxy

Reverse proxy service based on [Nginx](https://www.nginx.com/). In our WordPress architecture we use a reverse proxy in front of the WordPress sites.

#### staff_user

This role implements a set of tasks that are common to the creation of operating system user accounts for our staff users. Both our file share and mail server services require that staff user accounts be created on the hosts for those services.

#### wordpress

Base WordPress service - see also [wordpress_apache](#wordpress_apache) and [wordpress_nginx](#wordpress_nginx) roles. This role implements the common aspects of our WordPress hosting.

#### wordpress_apache

[WordPress](https://en.wikipedia.org/wiki/WordPress) service variant using [Apache](https://httpd.apache.org/) as a web server with mod_php.

## Integration with Third-Party Cloud Services

The roles in this repository support integration with four Cloud service providers as follows:

### Akamai

[Akamai](https://www.linode.com/) (formerly Linode) is our preferred partner for Linux virtual hosts and also domain zone management. The [dynamic_dns](#dynamic_dns) and [mail_certificates](#mail_certificates) roles both support the use of the Linode API service to automate the management of DNS records.

To enable this integration you must:

1. Create an account with Akamai, I believe this must be specifically via [linode.com](https://www.linode.com/) for access to the Linode API service.

2. Create an API personal access token with *Read Only* access to the *Account* scope and *Read/Write* access to the *Domains* scope. Those access levels and scopes are features of the [Linode v4 API service](https://www.linode.com/docs/api/).

3. Set the variable [dns_linode_key](#dns_linode_key) to the key of the API token that you just created.

Since you can't enable this integration without executing these steps, it is disabled by default. If you don't enable it then both the [dynamic_dns](#dynamic_dns) and [mail_certificates](#mail_certificates) roles are rendered completely redundant and there's no point deploying them to live environments.

### Dropbox

The backup service can use a [Dropbox](https://www.dropbox.com/) account to make off-site copies of backup media for on-site hosts for disaster recovery purposes. To enable this integration, you must:

1. Create a Dropbox account to use. Since you must of course have a Dropbox account for this integration to work, it is disabled by default.

2. Create a top-level folder within your Dropbox account, which will be where the backup service will write its off-site copies to. By default this is expected to be `bacula` but you can change the name by setting a different value for the `backup_copy_folder` directory.

3. Set the `backup_linked_to_dropbox` variables to a boolean true YAML value, I recommend `yes` for readability.

After you've deployed the [backup_director](#backup_director) and [backup_storage](#backup_storage) roles with the Drobpox integration enabled, you will have to link the hosts for those roles to your Dropbox account - see [Dropbox Headless install via command line](https://www.dropbox.com/en_GB/install-linux). You will need to run the Dropbox daemon and "copy and paste a link in a working browser to create a new account or add your server to an existing account" when prompted.

It's possible to rehearse this using my [Services - Docker](https://github.com/varilink/services-docker) repository.

### Let's Encrypt

The WordPress hosting and mail services both support integration with Let's Encrypt to obtain TLS certificates. In the case of the mail service this relies on Akamai integration (see above) being enabled to support validation via the [Let's Encrypt DNS-01 challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge). Certificates for the WordPress hosting service are validated via the [Let's Encrypt HTTP-01 challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) and so don't require Akamai integration.

Both the WordPress hosting and mail services can also use self-signed certificates, though of course these are suboptimal compared to those provided by a certification authority.

In the context of Let's Encrypt integration and the use of SSL more generally, see the following variables in the [Variables](#variables) section below:

- [host_enabled_for_ssl](#host_enabled_for_ssl)
- [mail_uses_ca](#mail_uses_ca)

### Mailgun

Our mail service uses [Mailgun](https://www.mailgun.com/) as an Exim *smarthost* (SMTP relay) when sending emails externally from our domain or our customers' domains, to enhance deliverability and for access to their service monitoring and management tools. Just as with the Dropbox and Akamai integration, this requires that you have a Mailgun account and so is disabled by default.

To use this integration you must:

1. Have an account with Mailgun.

2. Register each domain that you want to use in the list of *Sending domains* in the Mailgun dashboard.

3. Configure the [domain_smarthost_username](#domain_smarthost_username) and [domain_smarthost_userpass](#domain_smarthost_userpass) variables with the SMTP credentials configured in Mailgun for the domain when you deploy a domain using the [mail_certificates](#mail_certificates) role.

Without this integration in place the [mail_certificates](#mail_certificates) role will still send emails externally but will do so directly from the host it resides on, which is likely to have an adverse impact on email deliverability and could well get you blacklisted.

## Variables

The roles in this repository use a number of variables, over and above any Ansible built-in variables that they use. Some of these are internal to the roles only, i.e. it's never necessary for playbooks or the inventories used by those playbooks to set values for them. Others could or must have their values set by playbooks that use these roles or their associated inventories.

The table [List of Variables](#list-of-variables) below contains:

- The variables by **Name** that could or must have their values set by playbooks that use the roles in this repository or the inventories used by those playbooks. In other words, the variables that are internal to roles only are not listed in the table as we don't really need to know about them to use this roles library.

- The roles that each of those variables is **Used In**, as opposed to *set by*; for example, role A declares role B as one of its dependencies and, in doing so, role A sets the value of a variable that role B uses but that role A does not use. In that example, this table would identify role B as a role that it is *used in* but not role A.

- Whether it is **Mandatory** for playbooks or inventories used by those playbooks to set a value for the variable. The default behaviour if a value is not set is described within the list of [Variable Descriptions](#variable-descriptions) that follow the table.

- **Where Set** (short for "Where (the variable is) set"), specifically in my [Services - Docker](https://github.com/varilink/services-docker) repository. I use that repository to test the roles within this library in three [Test Environments](https://github.com/varilink/services-docker#test-environments) that [Services - Docker](https://github.com/varilink/services-docker) implements, which are *distributed*, *now* and *to-be*.

Since the test environments in my [Services - Docker](https://github.com/varilink/services-docker) repository are used for desktop based testing only and not any live services, I can share the values for variables set within them openly, whereas I could not for a live environment since they would in that environment be sensitive data. Thus [Services - Docker](https://github.com/varilink/services-docker) serves as a useful illustration of how to set the variables used by the roles in this library for anybody wanting to use those roles themselves.

The values used in the **Where Set** column are one or more of:
- *default* = Not set in a test environment's inventory or playbooks and so the default value set in the role applies.
- *extra* = Set at playbook execution time via the `--extra-vars` option.
- *inventory/all* = Set within the all group of the inventory for test environments.
- *inventory/external* = Set within the external group of the inventory for test environments.
- *inventory/internal* = Set within the internal group of the inventory for test environments.
- *host(s)* = Set for one or more specific hosts in the inventory for test environments.
- *my-roles* = Set in the my-roles wrapper to this role library in [Services - Docker ](https://github.com/varilink/services-docker). This equates to setting a common value for the variable in the all group of the inventory for all [Services - Docker](https://github.com/varilink/services-docker) test environments without having to repeat it for all three.
- *nowhere* = The variable is optional and no value is set, either in a role nor in the inventories and playbooks for test environments.
- *playbook* = Set directly within project playbooks.
- *projects/all* = Set within the all group of project playbooks for test environments.
- *projects/host(s)* = Set for one or more specific host(s) within project playbooks for test environments.

### List of Variables

| Name                                   | Used In                                                                                                                                                             | Mandatory | Where Set                                                                                 |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------------------------------------------------------------------- |
| admin_user                             | backup_client<br>monitor_server<br>mta<br>wordpress                                                                                                                 | Yes       | inventory/all <sup>1</sup>                                                                |
| admin_user_email                       | backup_director<br>backup_storage<br>mail_certificates<br>nginx<br>wordpress                                                                                        | Yes       | inventory/all                                                                             |
| backup_archive_media_directory         | backup_dropbox<br>backup_storage                                                                                                                                    | No        | default                                                                                   |
| backup_client_director_password        | backup_client<br>backup_director                                                                                                                                    | Yes       | inventory/host(s) <sup>2</sup>                                                            |
| backup_client_monitor_password         | backup_client                                                                                                                                                       | Yes       | inventory/host(s) <sup>2</sup>                                                            |
| backup_copy_folder                     | backup_director<br>backup_dropbox                                                                                                                                   | No        | inventory/all <sup>3</sup>                                                                |
| backup_database_host                   | backup_director<br>backup_web                                                                                                                                       | No        | inventory/all <sup>4</sup>                                                                |
| backup_database_password               | backup_director<br>backup_web<br>database                                                                                                                           | No        | default <sup>5</sup>                                                                      |
| backup_database_user                   | backup_director<br>backup_web<br>database                                                                                                                           | No        | default <sup>5</sup>                                                                      |
| backup_director_console_password       | backup_director                                                                                                                                                     | Yes       | inventory/all                                                                             |
| backup_director_monitor_password       | backup_director                                                                                                                                                     | Yes       | inventory/all                                                                             |
| backup_director_name                   | backup_client<br>backup_director<br>backup_storage                                                                                                                  | Yes       | inventory/all                                                                             |
| backup_director_schedules_active       | backup_director                                                                                                                                                     | No        | inventory/all <sup>6</sup>                                                                |
| backup_linked_to_dropbox               | backup_director<br>backup_storage                                                                                                                                   | No        | default <sup>7</sup>                                                                      |
| backup_monitor_name                    | backup_client<br>backup_director<br>backup_storage                                                                                                                  | Yes       | inventory/all                                                                             |
| backup_storage_director_password       | backup_director<br>backup_storage                                                                                                                                   | Yes       | inventory/all                                                                             |
| backup_storage_host                    | backup_director                                                                                                                                                     | No        | inventory/all <sup>4</sup>                                                                |
| backup_storage_monitor_password        | backup_storage                                                                                                                                                      | Yes       | inventory/all                                                                             |
| backup_storage_name                    | backup_storage                                                                                                                                                      | Yes       | inventory/all                                                                             |
| database_expose_externally             | database                                                                                                                                                            | No        | inventory/all <sup>4</sup>                                                                |
| dns_client_nameservers                 | dns<br>dns_client                                                                                                                                                   | Yes       | inventory/external<br>inventory/internal<br>inventory/host(s) <sup>8</sup>                |
| dns_client_options                     | dns_client                                                                                                                                                          | No        | nowhere                                                                                   |
| dns_linode_key                         | dns_api<br>dynamic_dns                                                                                                                                              | Yes       | inventory/all <sup>7</sup>                                                                |
| dns_upstream_nameservers               | dns                                                                                                                                                                 | Yes       | inventory/external<br>inventory/internal <sup>10</sup>                                    |
| domain_country                         | mail_external                                                                                                                                                       | No        | projects/all                                                                              |
| domain_locality                        | mail_external                                                                                                                                                       | No        | projects/all                                                                              |
| domain_name                            | backup_web<br>dns<br>dns_api<br>dynamic_dns<br>mail<br>mail_certificates<br>mail_external<br>mail_internal<br>monitor_server<br>nginx<br>reverse_proxy<br>wordpress | Yes       | projects/all                                                                              |
| domain_organisation                    | mail_external<br>wordpress                                                                                                                                          | Yes       | projects/all                                                                              |
| domain_organisation_unit               | mail_external                                                                                                                                                       | No        | nowhere                                                                                   |
| domain_smarthost_username              | mail_external                                                                                                                                                       | No        | nowhere <sup>11</sup>                                                                     |
| domain_smarthost_userpass              | mail_external                                                                                                                                                       | No        | nowhere <sup>11</sup>                                                                     |
| domain_state                           | mail_external                                                                                                                                                       | No        | projects/all                                                                              |
| domain_users                           | file_share<br>mail_external<br>mail_internal                                                                                                                        | Yes       | projects/all                                                                              |
| dynamic_dns_crontab_stride             | dynamic_dns                                                                                                                                                         | No        | default                                                                                   |
| dynamic_dns_records_dir                | dynamic_dns                                                                                                                                                         | No        | default                                                                                   |
| home_domain                            | backup_director<br>backup_storage<br>database<br>dns<br>dns_client<br>mail<br>mail_internal<br>monitor_client<br>monitor_dashboard<br>monitor_gateway<br>mta        | Yes       | inventory/all                                                                             |
| host_enabled_for_ssl                   | nginx<br>reverse_proxy                                                                                                                                              | No        | inventory/internal<br>inventory/host(s) <sup>12</sup>                                     |
| hosts_to_roles_map                     | backup_director<br>mail_internal                                                                                                                                    | Yes       | inventory/all                                                                             |
| mail_uses_ca                           | mail_certificates<br>mail_external<br>mail_internal                                                                                                                 | No        | default <sup>13</sup>                                                                     |
| office_subnet                          | mail_internal                                                                                                                                                       | Yes       | inventory/all                                                                             |
| playbook_subdomains                    | wordpress                                                                                                                                                           | No        | playbook                                                                                  |
| run_subdomains                         | wordpress                                                                                                                                                           | No        | extra                                                                                     |
| subdomains_filter                      | wordpress                                                                                                                                                           | No        | playbook                                                                                  |
| unsafe_writes                          | dns<br>dns_client                                                                                                                                                   | No        | my-roles                                                                                  |

These are notes for the **Where Set** entries above. Where there is more than one **Where Set** for a variable, the notes apply collectively to them all.

> <sup>1</sup> Variables set here are not necessarily used by all hosts in the test environment. I operate the principle that if a single value applies wherever the variable is used, then that value is set in the *all* group. Since I apply that principle throughout I do not repeat this note on other entries.

> <sup>2</sup> The values set are unique to each host that is to be backed up.

> <sup>3</sup> I use the same Dropbox account for live use and for testing using [Services - Docker](https://github.com/varilink/services-docker). In live, I let the role default value for [backup_copy_folder](#backup_copy_folder) apply and so must override that default in test to keep live and test separate.

> <sup>4</sup> Only set for the *distributed* test environment where services are not co-hosted and so they must be configured with the other host(s) that they must connect to over the network.

> <sup>5</sup> The role's default credentials are insecure and so in a live environment it is recommended to set more secure values.

> <sup>6</sup> The role default is that backup schedules are active, but I make them inactive in test environments because I want to execute backups manually there and not have them run automatically.

> <sup>7</sup> Since integration with third-party Cloud services that require accounts with services providers are disabled by default in the test environments.

> <sup>8</sup> The DNS servers on the internal and external networks in the test environments are exceptions from the values that are applied to all other hosts on each of those networks.

> <sup>9</sup> The role's default value applies to the hosts on the internal network in test environments.

> <sup>10</sup> Though the variable is only actually used by the DNS servers on each network in the test environment; see also <sup>1</sup>.

> <sup>11</sup> These must be set to integrate the [mail_external](#mail_external) role with a Cloud email relay provider, we use Mailgun. This is disabled by default in the test environments but is strongly recommended for live use.

> <sup>12</sup> In the test environments and in the live environment, I choose to not use SSL for websites on the internal network. A single host on the internal network has the value overriden back to true. This is the host for websites that are exposed externally from the internal network.

> <sup>13</sup> The test environments use self-signed certificates so that they're not reliant on Let's Encrypt integration. In live use, it is recommended to use certification authority certificates.

> <sup>14</sup> Defaults to the value set for [admin_user_email](#admin-user-email).

> <sup>15</sup> The playbook entries 

### Variable Descriptions

A description of each of the variables in the table above now follows.

#### admin_user

The operating system user login for the main admin user who supports the Varilink services. Of course this is always a user in the `home_domain`.

#### admin_user_email

The email address for the `admin_user`. This is not simply `admin_user`@`home_domain` since we use first names only for our office network logins but we use `fname.lname` for our email addresses.

#### backup_archive_media_directory

The directory that the backup storage daemon uses to store archive media in. This defaults to `/var/local/bacula` unless an alternative value is provided via the playbook or inventory.

#### backup_client_director_password

The password that the backup director must use to connect to a backup client. For good security, this should be unique to each backup client and meet length and complexity standards.

#### backup_client_monitor_password

The password that the backup monitor must use to connect to a backup client. For good security, this should be unique to each backup client and meet length and complexity standards. Unlike the backup director, the backup monitor is a desktop application and so there is no role in this library corresponding to it.

#### backup_copy_folder

The top-level folder within Dropbox for off-site copies of backup files. This defaults to `bacula` unless and alternative value if provided via the playbook or inventory.

#### backup_database_host

The host of the database that's used to store the backup catalogue. This can be omitted in which case the backup director will assume that the backup database is co-located on the same host as itself and use a local socket connection to the database.

#### backup_database_password

The password that the backup director uses to connect to the backup database. If this is omitted it will default to "bacula". A more secure value should be provided.

#### backup_database_user

The user that the backup director uses to connect to the backup database.  If this is omitted it will default to "bacula". A more secure value should be provided.

#### backup_director_console_password

The password that the backup console must use to connect to the backup director. The backup console is a desktop application and so there is no role in this library corresponding to it.

#### backup_director_monitor_password

The password that the backup monitor must use to connect to the backup director. For good security, this should meet length and complexity standards. The backup monitor is a desktop application and so there is no role in this library corresponding to it.

#### backup_director_name

The name by which the backup director identifies itself to backup clients and the backup storage daemon.

#### backup_director_schedules_active

Whether the backup schedules are active or not. By default this is set to the boolean true value. It only needs to be set in a playbook or inventory if a value that Jinja evaluates to false is required in order to disable automatic backup job scheduling. This can be useful during testing of backup jobs when it's convenient to run them manually instead.

#### backup_linked_to_dropbox

This boolean indicates whether the backup service's integration with Dropbox should be enabled or not. This is defaulted within the roles that use it to a false value so that backup integration with Dropbox is only enabled if this is done explicitly within environments.

#### backup_monitor_name

The name by which the backup monitor identifies itself to backup clients, the backup director and the backup storage daemon.

#### backup_storage_director_password

The password that the backup director must use to connect to the backup storage daemon. For good security, this should meet length and complexity standards.

#### backup_storage_host

The host of the storage daemon that the backup director must connect to.

#### backup_storage_monitor_password

The password that the backup monitor must use to connect to the backup storage daemon. For good security, this should meet length and complexity standards.

#### backup_storage_name

The name by which the backup storage daemon identifies itself.

#### database_expose_externally

Whether to expose the database service on a database host to the external network interface or not.

If this isn't set then it defaults to the boolean value false, meaning that the database service is not exposed to the external network interface. This is fine so long as services that use that database are on the same host. If that's the case then obviously for security reasons the database service should not be exposed externally.

If services external to the database host use its database service then this should be set to a value that Jinja understands to be true.

#### dns_client_nameservers

The IP addresses of DNS nameservers that a DNS client should use. These are used in the `/etc/resolv.conf` file for each host.

#### dns_client_options

Options to be set in the `/etc/resolv.conf` file for each host. If this is provided then it must be an array of strings, each of which will be added after `option` in a line within `/etc/resolv.conf`. This variable can be omitted if there are no options to set.

#### dns_linode_key

The personal access token used to access the Linode DNS API service. This is self-evidently highly sensitive data.

#### dns_upstream_nameservers

The IP addresses of upstream nameservers to configure in the DNS service. As the name suggests, these are the nameservers that Dnsmasq passes requests to that it is not configured to answer directly itself.

#### domain_country

The domain country code that will be used in self-certified SSL certificates.

#### domain_locality

The domain locality code that will be used in self-certified SSL certificates.

#### domain_name

The name of a domain corresponding to either our own internal services (`varilink.co.uk`) or those of a customer (e.g. `bennerleyviaduct.org.uk`).

#### domain_organisation

The name of a domain's organisation for either our own internal services ("Varilink Computing Ltd") or those of a customer (e.g. "The Friends of Bennerley Viaduct"). This is used in generated, self-signed SSL certificates.

#### domain_organisation_unit

The domain organisation unit that will be used in generated, self-signed SSL certificates.

#### domain_smarthost_username

The username to use when connecting to our email gateway provider to send emails externally for a domain.

#### domain_smarthost_userpass

The password to use when connecting to our email gateway provider to send emails externally for a domain.

#### domain_state

The domain state that will be used in generated, self-signed SSL certificates.

#### domain_users

An array of users for either our own internal services domain (`varilink.co.uk`) or a customer domain (e.g. `bennerleyviaduct.org.uk`). Each entry in the domain can contain the following attributes:
- username
- passwd
- email
- fname
- lname

#### dynamic_dns_crontab_stride

How many minutes within an hour between updates to dynamic DNS records. If this isn't set by a playbook or inventory then it takes the role's default value, which is fifteen minutes.

#### dynamic_dns_records_dir

The directory that holds dynamic DNS entries for each supported domain. If this isn't set by a playbook or inventory then it takes the role's default value, which is `/usr/local/etc/dynamic-dns-domains`.

#### home_domain

The home domain for any inventory as opposed to any customer domains that are served. In our case we set this to `varilink.co.uk` when we use this roles library.

#### host_enabled_for_ssl

This variable determines whether or not the capability to enable SSL for WordPress sites is enabled when the `reverse_proxy` role is deployed to a host. We serve all our WordPress sites from behind a reverse proxy, with the reverse proxy handling SSL if it is required for the site.

By default this is set to `yes`, which YAML recognises as boolean truth. It can be overridden to `no` on hosts on the internal network that will never serve WordPress sites externally and having so few staff that's what we do.

#### hosts_to_roles_map

This is a dictionary object, the keys of which are the names of each host in the inventory. Each host entry should have its value set to the list of roles that are **explicitly** deployed to that host by the `install-services.yml` playbook within the [Libraries - Ansible Playbooks](https://github.com/varilink/libraries_ansible-playbooks) - see the [`install-services.yml`](https://github.com/varilink/libraries_ansible-playbooks#install-servicesyml)

The hosts_to_roles_map should be defined within the *all* group of the hosts inventory, to make it universally available. See [`install-services.yml`](https://github.com/varilink/libraries_ansible-playbooks#install-servicesyml) within the [Libraries - Ansible Playbooks](https://github.com/varilink/libraries_ansible-playbooks) for an analysis of which roles should be mapped to which hosts.

While we keep the inventory for our live hosts private, you can also examine how hosts_to_roles_map is set within the [all group in the hosts inventory for the *now* environment](https://github.com/varilink/services_docker/blob/main/envs/now/inventory/group_vars/all/public.yml) in the [Services - Docker](https://github.com/varilink/services_docker) repository. Note that while the *now* [Services - Docker](https://github.com/varilink/services_docker) environment mirrors our current, live environment, the host `dns-external` defined in the *now* environment does not have an equivalent in our current live environemnt. It only exists in the *now* environemt to emulate Internet DNS servers that we might use but aren't in our hosts estate.

The hosts_to_roles_map is used to:
1. Build host specific Bacula FileSet configurations in the backup_director role.
2. Identify the host that is the target for fetchmail polls in the mail_internal role.

#### mail_uses_ca

Whether to use a Certification Authority or not (self-signed) for mail certificates. By default this is set to the boolean *true*, i.e. we do use a Certification Authority.

It's possible to override this to a value that Jinja evaluates as false in order to use self-signed certificates instead. This is sometimes useful during testing to avoid repeated requests to Let's Encrypt that might breach the threshold allowed for. The override can be applied at inventory level or for selected domains.

#### office_subnet

The IP address mask for the office network. The internal mail server relays email unconditionally for clients on this network.

#### playbook_subdomains

See [Controlling the WordPress Sites Impacted by Project Playbooks](#controlling-the-wordpress-sites-impacted-by-project-playbooks) below.

#### run_subdomains

See [Controlling the WordPress Sites Impacted by Project Playbooks](#controlling-the-wordpress-sites-impacted-by-project-playbooks) below.

#### subdomains_filter

See [Controlling the WordPress Sites Impacted by Project Playbooks](#controlling-the-wordpress-sites-impacted-by-project-playbooks) below.

#### unsafe_writes

If set to a true value, this enables the dns_client role to write to `/etc/hosts` and `/etc/resolv.conf` in an unsafe manner. This is necessary only in a Docker container environment because of the way that Docker mounts a copy of the host's `/etc/resolv.conf` file within containers. Hence this variable defaults to a false value, which is the value it should have in all other scenarios.

### Controlling the WordPress Sites Impacted by Project Playbooks

Under [List of Roles](#list-of-roles) above there are six roles that support the *site* deployment level:
- database
- dns
- reverse_proxy
- wordpress
- wordpress_apache
- wordpress_nginx

To manage WordPress sites these roles should be used in projects that typically manage sites that correspond to one or more subdomains of a project domain; for example *dev*, *test* and *www* subdomains for the domain *example.com*, which therefore corresponds to the WordPress sites *dev.example.com*, *test.example.com* and *www.example.com*. Using these roles, you can act on multiple WordPress sites for a project domain in a single playbook run.

Between them, three of the variables listed under [Variable Descriptions](#variable-descriptions) above control the WordPress sites for a project domain that a playbook run will act upon in coordination with the variables whose names start `wordpress_site_` that are defined within the project's inventory. Those three variables are:
- `playbook_subdomains`
- `run_subdomains`
- `subdomains_filter`

When set, each of these variables takes as its value a comma separated list of domains; for example "www", "dev,test", etc. Use these variables as follows:

> `playbook_subdomains`<br>
> Set this in the playbook at playbook level to make setting `run_subdomains` (see below) optional. This is purely a convenience when testing ahead of go-live. For live WordPress sites it is recommended not to define this variable so that on each playbook run a conscious choice must be made of the subdomains to act upon so that you don't inadvertently impact live sites.

> `run_subdomains`<br>
> Set this via `--extra-vars` when running a playbook. This should be made mandatory by not defining `playbook_subdomains` (see above) for playbooks that might impact live sites. The subdomains scope of a playbook run is either the value of `playbook_subdomains` (if `run_subdomains` is not defined) or `run_subdomains` (if `playbook_subdomains` is not defined) or the intersection of the two if both are defined. When both are defined, `run_subdomains` provides a means to filter down the subdomains scope of a playbook defined by `playbook_subdomains`.

> `subdomains_filter`<br>
> Set this at play or task level within playbooks to further filter down the subdomains scope of the playbook for specific tasks only a subset of that scope applies.

A good way to understand how to use these variables is to examine the playbooks in the following folders in my [Services - Docker](https://github.com/varilink/services-docker) repository:
- `envs/distributed/playbooks/customer/`
- `envs/now/playbooks/customer/`
- `envs/to-be/playbooks/customer/`

# Libraries - Ansible

David Williamson @ Varilink Computing Ltd

------

## Overview

A library of Ansible roles maintained and used by Varilink. These fall into two categories, which are used in two different places in the Varilink GitHub repositories:

1. Host roles, used in the [Services - Ansible](https://github.com/varilink/services-ansible) repository to deploy hosting services across the Varilink server estate.

2. Domain roles, used in multiple Varilink projects' Ansible repositories, which use them to deploy projects (or "sites") in test and live environments.

My [Services - Docker](https://github.com/varilink/services-docker) repository provides a Docker Compose wrapper that facilitates the testing of the Ansible roles defined here using Docker containers as the Ansible deployment targets.

There follows a list of the Host Roles and Domain Roles that are defined in this repository along with a brief description of each.

## Host Roles

### backup_client

Backup client service using the Bacula file daemon. This is deployed to every host that is backed up in my automated, backup schedule. It facilitates communication with the host by the Bacula Director and Bacula Storage Daemon services so that they may backup the host.

### backup_director

Backup director service using the Bacula Director with a MySQL catalogue store.

### backup_dropbox

Dropbox integration service for making off-site copies of backups. This is pulled in as a dependency by both the backup_director and backup_storage roles.

### backup_storage

Backup storage service using the Bacula storage daemon.

### calendar

CalDAV based calendar service using Radicale.

### database

Database service based using MariaDB. This is used by both the backup_director service, to store the Bacula, backup catalogue and by web services, e.g. those based on WordPress, for website databases.

### dns

A DNS service using Dnsmasq. We run Dnsmasq on our office network to supplement our ISP's DNS service with additional features.

### dns_api

A very simple role that merely deploys the key for API access to Linode hosted DNS zones for use by both the email_certificates and dynamic_dns roles. We deploy this to a single host on our office network so that we're only holding our API access tokens in on place and that is on an internal host on the office network.

### dns_client

Role that configures hosts on our internal, office network to use the DNS service provided on that network by the dns role.

### dynamic_dns

Keeps our Linode based DNS zones up to date with the dynamic IP address provided by our ISP for the office network for services that are hosted on-premise and exposed externally.

### email

Implements a Mail Transport Agent using Exim4 for all hosts and an email server using Dovecot that hosts acting as email servers can selectively import.

### email_certificates

Provides SSL certificates that are either self-signed or obtained from Let's Encrypt for encrypting IMAP and SMTP connections.

### email_external

External (to the office network) email service using Exim and Dovecot.

### email_internal

Internal (to the office network) email service using Exim and Dovecot with Fetchmail integration to the external email service.

### reverse_proxy

Reverse proxy service using Nginx.

### wordpress

WordPress service using Apache and PHP.

## Domain Roles

### domain_email_certificate

Generates and deploys an email certificate for a project domain using the email_certificates service.

### domain_email_external

Configures a domain on the host of the email_external role so that we can provide an email service for that domain.

### domain_email_internal

Configures a domain on the host of the email_internal role so that we can provide an email service for that domain.

### domain_reverse_proxy

Configures a project domain on the reverse proxy using the reverse_proxy service.

### domain_wordpress

Configures a WordPress site on the WordPress service.

### domain_wordpress_database

Configures a WordPress site on the database service.

### home_domain_users

Creates operating system accounts for all our office staff on any host that requires them.

## Variables

The roles in this repository use a number of variables over and above any Ansible built-in variables. To use this repository its necessary to define them correctly and cognisant of where to define them, since Ansible offers a multitude of options in this respect.

There follows:

1. A `Register of Variables` that identifies each of the non built-in variables used in this Ansible roles library.

2. A `Where to Define` guide that for each variable gives advice on where to define it amongst the options that Ansible offers.

For a real-world example of defining values for the variables used in this role library see my [Services - Docker](https://github.com/varilink/services-docker) repository.

### Register of Variables

The table below lists every non builtin variable used this role library along with its description and which roles it is **used** in. Note that emphasis on **used**, a variable may be defined in one role, either in that roles's `vars/` or `defaults/` folders or in `vars` specified for a dependency, and used in other roles. What is listed below is specifically the roles that a varialbe is used in. Note that in general variables are prefixed with the name of the primary role that they are applicable to, with a few exceptions.

| Variable                         | Description                                                                                                                                                          | Used in Role(s)                                                                                                                                                            |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| backup_client_director_password  | The password that the backup director must use to connect to a backup client.                                                                                        | backup_client<br />backup_director                                                                                                                                         |
| backup_client_monitor_password   | The password that the backup monitor must use to connect to a backup client.                                                                                         | backup_client                                                                                                                                                              |
| backup_copy_folder               | The Dropbox folder for offsite copies of backup files.                                                                                                               | backup_director<br />backup_dropbox                                                                                                                                        |
| backup_database_host             | The host of the database that's used to store the backup catalogue.                                                                                                  | backup_director                                                                                                                                                            |
| backup_database_password         | The password that the backup director uses to connect to the backup database.                                                                                        | backup_director<br />database                                                                                                                                              |
| backup_database_username         | The username that the backup director uses to connect to the backup database.                                                                                        | backup_director<br />database                                                                                                                                              |
| backup_director_console_password | The password that the backup console must use to connect to the backup director.                                                                                     | backup_director                                                                                                                                                            |
| backup_director_name             | The name by which the backup director identifies itself to backup clients and the backup storage daemon.                                                             | backup_client<br />backup_director<br />backup_storage                                                                                                                     |
| backup_director_schedules_active | Whether the backup schedules are active or not.                                                                                                                      | backup_director                                                                                                                                                            |
| backup_monitor_name              | The name by which the backup monitor identifies itself to backup clients.                                                                                            | backup_client                                                                                                                                                              |
| backup_storage_host              | The host of the storage daemon that the backup director must connect to.                                                                                             | backup_director                                                                                                                                                            |
| backup_storage_name              | The name by which the backup storage daemon identifies itself.                                                                                                       | backup_storage                                                                                                                                                             |
| backup_storage_password          | The password that the backup director must use to connect to the backup storage daemon.                                                                              | backup_director<br />backup_storage                                                                                                                                        |
| database_expose_externally       | Whether to expose the database service on an external network interface or not.                                                                                      | database                                                                                                                                                                   |
| dns_group                        | The Ansible group of hosts that the DNS server provides look-ups to.                                                                                                 | dns                                                                                                                                                                        |
| dns_linode_base_url              | The base URL for the DNS API service.                                                                                                                                | dynamic_dns                                                                                                                                                                |
| dns_linode_key                   | The personal access token used to access the DNS API service.                                                                                                        | dns_api<br />dynamic_dns                                                                                                                                                   |
| dns_mx_host                      | The name of an MX host to configure in the DNS service.                                                                                                              | dns                                                                                                                                                                        |
| dns_resolvers                    | The IP addresses of DNS resolvers that a DNS client should use.                                                                                                      | dns_client                                                                                                                                                                 |
| dns_upstream_nameservers         | The IP addresses of upstream nameservers to configure in the DNS service.                                                                                            | dns                                                                                                                                                                        |
| domain                           | A dictionary object that contains the specification of a domain for configuring its email and/or web services.                                                       | domain_email_certificate<br />domain_email_external<br />domain_reverse_proxy<br />domain_wordpress<br />domain_wordpress_database<br />dynamic_dns<br />home_domain_users |
| dynamic_dns_crontab_stride       | How many minutes within an hour between updates to dynamic DNS records.                                                                                              | dynamic_dns                                                                                                                                                                |
| email_exim_configtype            | The mail server configuration type.                                                                                                                                  | email                                                                                                                                                                      |
| email_exim_hide_mailname         | Whether to hide the the domain name used to qualify mail addresses without a domain name in the From: lines of outgoing messages.                                    | email                                                                                                                                                                      |
| email_exim_local_interfaces      | IP addresses to listen on for incoming SMTP connections.                                                                                                             | email                                                                                                                                                                      |
| email_exim_localdelivery         | Format used to store locally delivered email.                                                                                                                        | email                                                                                                                                                                      |
| email_exim_other_hostnames       | Recipient domains for which the host should consider itself to be the final destination.                                                                             | email                                                                                                                                                                      |
| email_exim_relay_nets            | IP address ranges for which the host will unconditionally relay mail, functioning as a smarthost.                                                                    | email                                                                                                                                                                      |
| email_exim_smarthost             | Details of the smarthost or smarthosts that a host uses to relay emails.                                                                                             | email                                                                                                                                                                      |
| email_exim_use_split_config      | Whether or not to split the Exim configuration into multiple files.                                                                                                  | email                                                                                                                                                                      |
| email_uses_ca                    | Whether to use a Certification Authority or not (self-signed) for email certificates. This is set at an inventory level but can be overridden for selected domains.  | domain_email_certificate<br />email_certificates                                                                                                                           |
| home_domain                      | The home domain for any inventory as opposed to any client domains that are served.                                                                                  | dns<br />dns_client<br />domain_email_external<br />domain_email_internal<br />email                                                                                       |
| home_domain_admin_user           | The admin user for hosts in home domain.                                                                                                                             | email<br/>home_domain_users                                                                                                                                                |
| office_subnet                    | The IP address mask for the office network.                                                                                                                          | email_internal                                                                                                                                                             |
| reverse_proxy_uses_ssl           | Whether a reverse proxy uses SSL, if it's externally facing then the answer is "Yes" but if it's internally facing only then we may choose that it doesn't.          | domain_reverse_proxy<br />reverse_proxy                                                                                                                                    |
| unsafe_writes                    | If set to true this enables the dns_client role to write to /etc/hosts and /etc/resolv.conf in an unsafe manner, which is necessary only in a container environment. | dns<br />dns_client                                                                                                                                                        |

### Setting Variable Values

#### Within this Roles' Library

Values for the above variables are either set within this roles library itself or within the inventory for playbooks that use this roles library. There are three scenarios in which values are set within this roles library itself:

1. `vars/` folder of a role

The variable value that is set is never overridden. This scenario serves only to set a fixed value in a variable rather than hard-coding it; for example because it might be referenced multiple times in the role.

2. `defaults/` folder of a role

A sensible default value is set for the variable that may be optionally overridden in playbook inventory variables.

3. `meta/` folder of a role with the `vars` assigned to a role dependency

The variable is used by a role that provides common functionality for other roles to incorporate as a dependency. Those other roles specify values in the `vars` variable of their role dependency declaration.

| Role                 | Folder      | Variable(s)                                                                                                                                                                                               |
| -------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| backup_dropbox       | `defaults/` | backup_copy_folder                                                                                                                                                                                        |
| dns                  | `defaults/` | dns_group<br />unsafe_writes                                                                                                                                                                              |
| dns_api              | `vars/`     | dns_linode_base_url                                                                                                                                                                                       |
| domain_reverse_proxy | `defaults/` | reverse_proxy_uses_ssl                                                                                                                                                                                    |
| dynamic_dns          | `defaults/` | dynamic_dns_crontab_stride                                                                                                                                                                                |
| email                | `defaults/` | email_exim_configtype<br />email_exim_hide_mailname<br />email_exim_local_interfaces<br />email_exim_localdelivery<br />email_exim_other_hostnames<br />email_exim_relay_nets<br />home_domain_admin_user |
| email_certificates   | `defaults/` | email_users_ca                                                                                                                                                                                            |
| email_external       | `meta/`     | email_exim_configtype<br />email_exim_hide_mailname<br />email_exim_local_delivery<br />email_exim_other_hostnames                                                                                        |
| email_internal       | `meta/`     | email_exim_configtype<br />email_exim_hide_mailname<br />email_exim_local_delivery<br />email_exim_local_interfaces<br />email_exim_other_hostnames<br />email_exim_relay_nets                            |
| reverse_proxy        | `defaults/` | reverse_proxy_uses_ssl                                                                                                                                                                                    |
| wordpress            | `defaults/` | wordpress_expose_externally                                                                                                                                                                               |

#### Within the Inventory for Playbooks

Within the inventory I assign variable values for either groups or hosts. Where values are assigned is dictated by the scope that the value is valid for and not the scope of usage. For example, if a value is good wherever it miay be used then it is set in the "All" group even though it may not be used by all the hosts. There is a hierarchy to value assignment, so I may set a value for the group All and override it for specific hosts rather than put those hosts in separate groups.

This table below shows where variables should be assigned in the host inventory for a playbook that uses this role library. The meaning of the columns in this table are:
- Group/Host = Variable assignment at group or host level.
- Group or Host Role Name = For a group, the name of the group. For a host, the name of a role that is deployed to the host.
- Mandatory/Optional = Whether it is mandatory or optional to set the varaible here in the inventory. Optional only applies when choosing to override a role's default value for the variable.
- Variables = The list of variables that values should be assigned to.

You can see this in action in the inventory variables within my [Services - Docker](https://github.com/varilink/services-docker) repository, so that's a good guide for further understanding.

| Group/Host | Group or Host Role Name | Mandatory/Optional | Variables                                                                                                                                                                                                                                                                                                                                    |
| ---------- | ----------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Group      | all                     | Mandatory          | backup_database_host<br />backup_database_password<br />backup_database_username<br />backup_director_console_password<br />backup_director_name<br />backup_monitor_name<br />backup_storage_host<br />backup_storage_name<br />backup_storage_password<br />dns_linode_key<br />home_domain<br />home_domain_admin_user<br />office_subnet |
|            |                         | Optional           | backup_copy_folder<br />backup_director_schedules_active<br />dynamic_dns_crontab_stride<br />email_uses_ca<br />unsafe_writes                                                                                                                                                                                                               |
|            | external                | Mandatory          | dns_resolvers<br />email_exim_smarthost                                                                                                                                                                                                                                                                                                      |
|            | internal                | Mandatory          | dns_resolvers<br />email_exim_smarthost                                                                                                                                                                                                                                                                                                      |
| Host       | backup_client           | Mandatory          | backup_client_director_password<br />backup_client_monitor_password                                                                                                                                                                                                                                                                          |
|            | database                | Optional           | database_expose_externally                                                                                                                                                                                                                                                                                                                   |
|            | dns                     | Mandatory          | dns_group<br />dns_resolvers<br />dns_upstream_nameservers                                                                                                                                                                                                                                                                                   |
|            |                         | Optional           | dns_mx_host                                                                                                                                                                                                                                                                                                                                  |
|            | email_externl           | Mandatory          | email_exim_local_interfaces<br />email_exim_relay_nets<br />email_exim_smarthost                                                                                                                                                                                                                                                             |
|            | email_internal          | Mandatory          | email_exim_smarthost                                                                                                                                                                                                                                                                                                                         |
|            | reverse_proxy           | Optional           | reverse_proxy_uses_ssl                                                                                                                                                                                                                                                                                                                       |
|            | wordpress               | Optionally         | wordpress_expose_externally                                                                                                                                                                                                                                                                                                                  |

#### Within a Domain Specification

| Name   | Description | Used in Role(s)                                                                                                           |
| ------ | ----------- | ------------------------------------------------------------------------------------------------------------------------- |
| domain |             | domain_email<br />domain_email_certificate<br />domain_reverse_proxy<br />domain_wordpress<br />domain_wordpress_database |


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

Backup client service using the Bacula file daemon. This is deployed to every host that is in my automated, backup schedule.

### backup_director

Backup director service using the Bacula Director with a MySQL catalogue store.

### backup_dropbox

Dropbox integration service for making off-site copies of backups. This is pulled in as a dependency by both the backup_director and backup_storage roles.

### backup_storage

Backup storage service using the Bacula storage daemon.

### calendar

CalDAV service using Radicale.

### database

Database service based using MariaDB.

### dns

DNS service using Dnsmasq.

### dns_api

A very simple role that merely deploys the key for API access to Linode hosted DNS zones for use by both the domain_email_certificates and dynamic_dns roles.

### dns_client

Role that configures hosts to use the service deployed by the dns role.

### dynamic_dns

Keeps the Linode hosted DNS zones up to date with the dynamic IP address provided by our ISP for the office network for services that are hosted on-premise and exposed externally.

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

### domain_reverse_proxy

Configures a project domain on the reverse proxy using the reverse_proxy service.

### domain_wordpress

Configures a WordPress site on the WordPress service.

### domain_wordpress_database

Configures a WordPress site on the database service.

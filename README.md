# Libraries - Ansible

David Williamson @ Varilink Computing Ltd

------

## Table of Contents

[TOC]

## Overview

A library of Ansible roles maintained and used by Varilink. These fall into two categories, which are used in two different places in the Varilink GitHub repositories:

1. Host roles, used in the [Services - Ansible](https://github.com/varilink/services-ansible) repository to deploy hosting services across the Varilink server estate.

2. Project roles, used in multiple Varilink projects' Ansible repositories, which use them to deploy projects (or "sites") in test and live environments.

My [Services - Docker](https://github.com/varilink/services-docker) repository provides a Docker Compose wrapper that facilitates the testing of the Ansible roles defined here using Docker containers as the Ansible deployment targets.

There follows a list of the Host Roles and Project Roles that are defined in this repository along with a brief description of each and a link to each role's Ansible artefacts. If there is a README file provided alongside each role's Ansible artefacts this will contain further description of that role.

## Host Roles

### Backup Client ([backup_client](https://github.com/varilink/libraries-ansible/tree/main/backup_client))

Backup client service using the Bacula file daemon. This is deployed to every host that is in my automated, backup schedule.

### Backup Director ([backup_director](https://github.com/varilink/libraries-ansible/tree/main/backup_director))

Backup director service using the Bacula Director with a MySQL catalogue store.

### Backup Dropbox ([backup_dropbox](https://github.com/varilink/libraries-ansible/tree/main/backup_dropbox))

Dropbox integration service for making off-site copies of backups.

### Backup Storage ([backup_storage](https://github.com/varilink/libraries-ansible/tree/main/backup_storage))

Backup storage service using the Bacula storage daemon.

### Calendar ([calendar](https://github.com/varilink/libraries-ansible/tree/main/calendar))

CalDAV service using Radicale.

### Database ([database](https://github.com/varilink/libraries-ansible/tree/main/database))

Database service based using MariaDB.

### DNS External ([dns_external](https://github.com/varilink/libraries-ansible/tree/main/dns_external))

Externally facing Dynamic DNS service for internal (to the office) network services that are not at a fixed IP address.

### DNS Internal ([dns_internal](https://github.com/varilink/libraries-ansible/tree/main/dns_internal))

Internal (to the office network) DNS service using dnsmasq.

### Email Client ([email_client](https://github.com/varilink/libraries-ansible/tree/main/email_client))

Email client service for servers to send emails using Exim.

### Email External ([email_external](https://github.com/varilink/libraries-ansible/tree/main/email_external))

External (to the office network) email service using Exim and Dovecot.

### Email Internal ([email_internal](https://github.com/varilink/libraries-ansible/tree/main/email_internal))

Internal (to the office network) email service using Exim and Dovecot with Fetchmail integration to the external email service.

### Reverse Proxy ([reverse_proxy](https://github.com/varilink/libraries-ansible/tree/main/reverse_proxy))

Reverse proxy service using Nginx.

### WordPress ([wordpress](https://github.com/varilink/libraries-ansible/tree/main/wordpress))

WordPress service using Apache and PHP.

## Project Roles

### Reverse Proxy Site ([reverse_proxy_site](https://github.com/varilink/libraries-ansible/tree/main/reverse_proxy_site))

Project role that configures a website on the reverse proxy service.

### WordPress Database ([wordpress_database](https://github.com/varilink/libraries-ansible/tree/main/wordpress_database))

Configures a WordPress site on the database service.

### WordPress Site ([wordpress_site](https://github.com/varilink/libraries-ansible/tree/main/wordpress_site))

Configures a WordPress site on the WordPress service.

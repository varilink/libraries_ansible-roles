# Libraries - Ansible

David Williamson @ Varilink Computing Ltd

------

## DNS Internal

### Description

This service uses [Dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) to provide a DNS service for an office network that augments a public DNS service with DNS entries for services running on that office network.

### Variables

```yaml
unsafe_writes: ...
dns_internal_domain: ...
dns_internal_upstream_nameservers: ...
```

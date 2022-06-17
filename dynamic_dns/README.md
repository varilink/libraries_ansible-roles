# Libraries - Ansible

David Williamson @ Varilink Computing Ltd

------

## DNS External

### Description

This service uses the Dynamic DNS API of my chosen hosting provider to keep DNS entries that correspond to services hosted on my office network refreshed with the current IP address provided by my ISP. It does this by running a scheduled Perl script on a nominated "DNS gateway" server.

### Variables

```yaml
dns_external_api:
  key: ...
  url: ...
dns_external_domains:
  - name: ...
    id: ...
    resources:
      - name: ...
        id: ...
```

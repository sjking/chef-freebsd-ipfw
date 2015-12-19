# Chef FreeBSD IPFW Cookbook

Configures the ipfw firewall in FreeBSD with custom rules.

## Configuration

Firewall rules are file resources. A firewall rule file in the cookbook is
referenced by a data bag item that is named after the hostname for the node
that references it. For example, say we have a node we are managing with this
cookbook with the hostname `example.com`. Then we would place a databag item
called `firewall/default/example.com.json` with the following contents:

    {
      "hostname": "example.com",
      "rules": "webserver_vm.rules"
    }

The "rules" property names the rules file to be used for the node with hostname
`example.com` in this example.

## Example rules

The provided rules `webserver_vm.rules` in this cookbook is used for testing
with test kitchen. For further reading, consult the [FreeBSD documentation on
ipfw](https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/firewalls-ipfw.html).
The example firewall rules provided in this cookbook is adapted from the
FreeBSD IPFW documentation.

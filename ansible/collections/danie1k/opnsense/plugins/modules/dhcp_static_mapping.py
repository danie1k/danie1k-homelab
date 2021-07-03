import collections
from typing import Dict, Tuple
from ipaddress import IPv4Network, IPv4Address
from ansible.module_utils.basic import AnsibleModule
from randmac import RandMac
from twill.commands import go, fv, submit
from twill.browser import browser

try:
    from ansible_collections.danie1k.opnsense.plugins.module_utils.opnsense import (
        Changed, NotChanged, NotFound, OpnSenseError, Opnsense
    )
except ImportError:
    import os
    import sys
    sys.path.append(os.path.join(os.path.dirname(__file__), os.pardir))
    from module_utils.opnsense import Changed, NotChanged, NotFound, OpnSenseError, Opnsense


DOCUMENTATION = r''
RETURN = r''

AUTO = "auto"
ABSENT = "absent"
PRESENT = "present"

StaticMapping = collections.namedtuple("StaticMapping", "static_arp mac_address ip_address hostname description")
StaticMapping.XPATHS = (
    ("//text()[contains(.,'DHCP Static Mappings for this interface')]/ancestor::tr/following-sibling::tr[position()>1]/td[1]/i", lambda i: (bool(i),)),
    ("//text()[contains(.,'DHCP Static Mappings for this interface')]/ancestor::tr/following-sibling::tr[position()>1]/td[2]/text()", lambda i: tuple(map(str.strip, i))),
    ("//text()[contains(.,'DHCP Static Mappings for this interface')]/ancestor::tr/following-sibling::tr[position()>1]/td[3]/text()", lambda i: tuple(map(str.strip, i))),
    ("//text()[contains(.,'DHCP Static Mappings for this interface')]/ancestor::tr/following-sibling::tr[position()>1]/td[4]/text()", lambda i: tuple(map(str.strip, i))),
    ("//text()[contains(.,'DHCP Static Mappings for this interface')]/ancestor::tr/following-sibling::tr[position()>1]/td[5]/text()", lambda i: tuple(map(str.strip, i))),
)

class Dhcpv4(Opnsense):
    __interface: str = None

    def __init__(self, interface: str, **kwargs) -> None:
        self.__interface = interface
        super().__init__(**kwargs)

    # Interface general

    @property
    def interface_ip_range(self) -> Tuple[IPv4Address]:
        go(f"{self._base_url}/services_dhcp.php?if={self.__interface}")
        subnet, mask = map(
            str.strip,
            browser.xpath("//td[contains(text(),'Subnet')]/following-sibling::td/text()"),
        )
        return tuple(filter(
            lambda i: not(str(i).endswith('.0') or str(i).endswith('.1')),
            iter(IPv4Network(f"{subnet}/{mask}")),
        ))

    # DHCP only

    @property
    def dhcp__ip_range(self) -> Tuple[IPv4Address]:
        go(f"{self._base_url}/services_dhcp.php?if={self.__interface}")

        range_from, range_to = map(
            IPv4Address,
            browser.xpath("//td[contains(text(),'Range')]/following-sibling::td//tbody//td/input/@value"),
        )
        number_of_ips = int(range_to) - int(range_from)
        return tuple(range_from + i for i in range(0, number_of_ips + 1))

    # Static Mappings

    @property
    def static__ip_range(self) -> Tuple[IPv4Address]:
        _all_interface_ips = set(self.interface_ip_range)
        _dhcp_ips = set(self.dhcp__ip_range)
        _static_reserved_ips = set(self.static__reserved_ips)
        return tuple(sorted(_all_interface_ips - _dhcp_ips - _static_reserved_ips))

    @property
    def static__mappings_list(self) -> Tuple[StaticMapping]:
        _url = f"{self._base_url}/services_dhcp.php?if={self.__interface}"
        go(_url)

        if browser.url != _url:
            raise NotFound(f"Interface {self.__interface} not found!")

        return tuple(map(
            lambda i: StaticMapping(*i),
            zip(*(callback(browser.xpath(xpath)) for xpath, callback in StaticMapping.XPATHS)),
        ))

    @property
    def static__reserved_hostnames(self) -> Tuple[str]:
        return tuple(item.hostname for item in self.static__mappings_list)

    @property
    def static__reserved_ips(self) -> Tuple[IPv4Address]:
        return tuple(IPv4Address(item.ip_address) for item in self.static__mappings_list)

    @property
    def static__reserved_macs(self) -> Tuple[str]:
        return tuple(item.mac_address for item in self.static__mappings_list)

    # OPERATIONS

    def apply_changes(self) -> None:
        _url = f"{self._base_url}/services_dhcp.php?if={self.__interface}"
        go(_url)

        if browser.xpath("//text()[contains(.,'Apply changes')]"):
            form = browser.form(3)
            # Focus on form
            browser.clicked(form, browser.form_field(form, "apply"))
            # Apply changes static mapping
            submit("apply")

    def add_new_mapping(self, item: StaticMapping) -> None:
        _url = f"{self._base_url}/services_dhcp_edit.php?if={self.__interface}"

        if item.ip_address != AUTO:
            _ip_address = item.ip_address
        else:
            available_static_ips = self.static__ip_range
            if not available_static_ips:
                raise OpnSenseError("Unable to automatically find free IP address!")
            _ip_address = str(available_static_ips[0])

        go(_url)

        if item.mac_address != AUTO:
            _mac_address = item.mac_address
        else:
            _mac_address = str(RandMac("00:00:00:00:00:00", True))

        fv("iform", "mac", _mac_address)

        fv("iform", "ipaddr", _ip_address)

        if item.hostname.strip():
            fv("iform", "hostname", item.hostname.strip())

        if item.description.strip():
            fv("iform", "descr", item.description.strip())

        fv("iform", "arp_table_static_entr", item.static_arp)

        submit("Save")

        if browser.url == _url:
            # Try to get errors
            _expected_error_message = "The following input errors were detected:"
            _errors = map(
                str.strip,
                browser.xpath(f"//text()[contains(.,'{_expected_error_message}')]/ancestor::p/following-sibling::ul/li/text()"),
            )
            raise OpnSenseError(f"{_expected_error_message} {('; '.join(_errors)).lower()}")

    def remove_mapping(self, mac_address: str) -> None:
        raise NotImplementedError # TODO: remove_mapping


def do_stuff(
    opnsense: Dict[str, str],
    apply_changes_immediately: bool,
    description: str,
    hostname: str,
    interface: str,
    state: str,
    static_arp: bool,
    ip_address: str = None,
    mac_address: str = None,
):
    dhcpv4 = Dhcpv4(
        base_url=opnsense["url"],
        username=opnsense["username"],
        password=opnsense["password"],
        interface=interface,
    )

    description = description.strip()
    hostname = hostname.strip()
    ip_address = ip_address.strip() if ip_address else AUTO
    mac_address = mac_address.strip() if mac_address else AUTO

    if state == PRESENT and hostname in dhcpv4.static__reserved_hostnames:
        for i in dhcpv4.static__mappings_list:
            if i.hostname == hostname:
                raise NotChanged(mapping=i)

    if mac_address != AUTO:
        if mac_address in dhcpv4.static__reserved_macs:
            if state == PRESENT:
                for i in dhcpv4.static__mappings_list:
                    if i.mac_address == mac_address:
                        raise NotChanged(mapping=i)
            else:
                dhcpv4.remove_mapping(mac_address)
                raise Changed

    if ip_address != AUTO:
        if IPv4Address(ip_address) in dhcpv4.dhcp__ip_range:
            raise OpnSenseError(f"Given IP address ({ip_address}) is reserved for DHCP!")

        if IPv4Address(ip_address) in dhcpv4.static__reserved_ips:
            raise OpnSenseError(f"Given IP address ({ip_address}) is already statically mapped!")

    item_to_add = StaticMapping(
        static_arp=static_arp,
        mac_address=mac_address,
        ip_address=ip_address,
        hostname=hostname,
        description=description,
    )

    dhcpv4.add_new_mapping(item_to_add)

    # TODO: Force update?

    if apply_changes_immediately:
        dhcpv4.apply_changes()

    for i in dhcpv4.static__mappings_list:
        if i.hostname == hostname:
            return i


def main():
    module = AnsibleModule(
        argument_spec={
            "opnsense": {
                "type": "dict",
                "options": {
                    "url": {"type": "str", "required": True},
                    "username": {"type": "str", "required": True},
                    "password": {"type": "str", "required": True},
                },
            },
            "apply_changes_immediately": {"type": "bool", "default": True},
            "description": {"type": "str", "default": ""},
            "hostname": {"type": "str", "default": ""},
            "interface": {"type": "str"},
            "ip_address": {"type": "str", "required": False},
            "mac_address": {"type": "str", "required": False},
            "state": {"type": "str", "default": PRESENT, "choices": (ABSENT, PRESENT)},
            "static_arp": {"type": "bool", "default": False},
        },
        required_if=(
            ("state", ABSENT, ("ip_address",)),
        ),
        supports_check_mode=False
    )

    try:
        result = do_stuff(**module.params)
    except OpnSenseError as ex:
        module.fail_json(msg=str(ex))
    except NotChanged as ex:
        module.exit_json(changed=False, **ex.mapping._asdict())
    else:
        module.exit_json(changed=True, **result._asdict())


if __name__ == '__main__':
    main()

import collections
from typing import Dict, Tuple
from ansible.module_utils.basic import AnsibleModule
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

HostOverride = collections.namedtuple("HostOverride", "host domain ip_address description")
HostOverride.XPATHS = (
    (
        "//text()[contains(.,'Host Overrides')]/ancestor::tr/following-sibling::tr[position()>1 and position()<last()]/td[1]/text()",
        lambda i: tuple(map(str.strip, i)),
    ),
    (
        "//text()[contains(.,'Host Overrides')]/ancestor::tr/following-sibling::tr[position()>1 and position()<last()]/td[2]/text()",
        lambda i: tuple(map(str.strip, i)),
    ),
    (
        "//text()[contains(.,'Host Overrides')]/ancestor::tr/following-sibling::tr[position()>1 and position()<last()]/td[4]/text()",
        lambda i: tuple(map(str.strip, i)),
    ),
    (
        "//text()[contains(.,'Host Overrides')]/ancestor::tr/following-sibling::tr[position()>1 and position()<last()]/td[5]",
        lambda i: tuple(map(str.strip, map(lambda j: j.text if j.text else "", i))),
    ),
)


class UnboundDns(Opnsense):

    # Overrides

    @property
    def overrides__list(self) -> Tuple[HostOverride]:
        _url = f"{self._base_url}/services_unbound_overrides.php"
        go(_url)

        if browser.url != _url:
            raise NotFound(f"Unbound DNS page not found!")

        return tuple(map(
            lambda i: HostOverride(*i),
            zip(*(callback(browser.xpath(xpath)) for xpath, callback in HostOverride.XPATHS)),
        ))

    # OPERATIONS

    def apply_changes(self) -> None:
        _url = f"{self._base_url}/services_unbound_overrides.php"
        go(_url)

        if browser.xpath("//text()[contains(.,'Apply changes')]"):
            form = browser.form(3)
            # Focus on form
            browser.clicked(form, browser.form_field(form, "apply"))
            # Apply changes static mapping
            submit("apply")

    def add_new_override(self, item: HostOverride) -> None:
        _url = f"{self._base_url}/services_unbound_host_edit.php"
        go(_url)

        fv("iform", "host", item.host)
        fv("iform", "domain", item.domain)
        fv("iform", "ip", item.ip_address)
        fv("iform", "descr", item.description)
        submit("Save")

        if browser.url == _url:
            # Try to get errors
            _expected_error_message = "The following input errors were detected:"
            _errors = map(
                str.strip,
                browser.xpath(f"//text()[contains(.,'{_expected_error_message}')]/ancestor::p/following-sibling::ul/li/text()"),
            )
            raise OpnSenseError(f"{_expected_error_message} {('; '.join(_errors)).lower()}")


def do_stuff(
    opnsense: Dict[str, str],
    apply_changes_immediately: bool,
    description: str,
    domain: str,
    host: str,
    state: str,
    ip_address: str = None,
):
    unbounddns = UnboundDns(
        base_url=opnsense["url"],
        username=opnsense["username"],
        password=opnsense["password"],
    )

    description = description.strip()
    domain = domain.strip()
    host = host.strip()
    ip_address = ip_address.strip()

    if state == PRESENT:
        _found = False
        for i in unbounddns.overrides__list:
            if i.host == host and i.domain == domain and i.ip_address == ip_address:
                raise NotChanged(mapping=i)

    if state == ABSENT:
        raise NotImplementedError  # TODO: state == ABSENT

    item_to_add = HostOverride(
        description=description,
        domain=domain,
        host=host,
        ip_address=ip_address,
    )
    unbounddns.add_new_override(item_to_add)

    # TODO: Force update?

    if apply_changes_immediately:
        unbounddns.apply_changes()

    return item_to_add


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
            "domain": {"type": "str"},
            "host": {"type": "str"},
            "ip_address": {"type": "str", "required": False},
            "state": {"type": "str", "default": PRESENT, "choices": (ABSENT, PRESENT)},
        },
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


# do_stuff(
#     opnsense={
#         "url": "https://router.allanite.it/",
#         "username": "root",
#         "password": "kg4W$57^qXf",
#     },
#     description="",
#     apply_changes_immediately=True,
#     domain="allanite.it",
#     host="hello2",
#     ip_address="157.16.100.2",
#     state="present",
# )

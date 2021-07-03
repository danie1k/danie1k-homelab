from twill.commands import fv, go, submit


class Changed(Exception):
    pass


class NotChanged(Exception):
    def __init__(self, mapping) -> None:
        self.mapping = mapping
        super().__init__()


class OpnSenseError(Exception):
    pass


class NotFound(OpnSenseError):
    pass


class Opnsense:
    _base_url: str = None

    def __init__(self, base_url: str, username: str, password: str) -> None:
        self._base_url = base_url
        go(self._base_url)

        # TODO: `if browser.url != url:`
        # TODO: Check if login for is available

        # Log in to OPNsense
        fv("iform", "usernamefld", username)
        fv("iform", "passwordfld", password)
        submit("0")

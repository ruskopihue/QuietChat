"""Translations: every language has exactly the English strings, and the addon runs in each."""

import os
import re
import unittest

from lupa import lua51

from wow import ROOT, Addon, addon_files

# Records what a locale file sets, in place of AceLocale (which only keeps the client's language)
RECORDER = r"""
RECORDED = {}
local proxy = setmetatable({}, { __newindex = function(_, key, value) RECORDED[key] = value end })
local AceLocale = { NewLocale = function() return proxy end }
function LibStub() return AceLocale end
"""

LOCALE_FILES = {os.path.basename(path)[:-4]: path for path in addon_files() if path.startswith("Locales/")}
CODE_FILES = [path for path in addon_files() if not path.startswith("Locales/")]
# L["..."] or L['...'], the way the code looks strings up
LOOKUP = re.compile(r"""\bL\[\s*("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')\s*\]""")
# Clients that use another client's translation (AceLocale maps enGB to enUS itself)
SHARED_CLIENTS = {"enGB": "enUS", "esMX": "esES"}


def read_locale(path):
    lua = lua51.LuaRuntime()
    lua.execute(RECORDER)
    with open(os.path.join(ROOT, path), encoding="utf-8") as f:
        lua.execute(f.read())
    return dict(lua.globals().RECORDED.items())


def code_lookups():
    """Every string the code looks up, as Lua reads it (escapes resolved)."""
    lua = lua51.LuaRuntime()
    keys = set()
    for path in CODE_FILES:
        with open(os.path.join(ROOT, path), encoding="utf-8") as f:
            for literal in LOOKUP.findall(f.read()):
                keys.add(lua.eval(literal))
    return keys


def placeholders(text):
    return re.findall(r"%.", text)


ENGLISH = read_locale(LOCALE_FILES["enUS"])
TRANSLATIONS = {locale: read_locale(path) for locale, path in LOCALE_FILES.items() if locale != "enUS"}


class Strings(unittest.TestCase):
    def test_english_is_the_base(self):
        self.assertTrue(all(value is True for value in ENGLISH.values()))

    def test_code_and_english_have_the_same_strings(self):
        used = code_lookups()
        self.assertEqual(sorted(used - ENGLISH.keys()), [], "looked up in the code but missing from enUS.lua")
        self.assertEqual(sorted(ENGLISH.keys() - used), [], "in enUS.lua but no longer used by the code")

    def test_translations_have_exactly_the_english_strings(self):
        for locale, strings in TRANSLATIONS.items():
            with self.subTest(locale=locale):
                self.assertEqual(sorted(ENGLISH.keys() - strings.keys()), [], "not translated")
                self.assertEqual(sorted(strings.keys() - ENGLISH.keys()), [], "not in English (outdated?)")
                for key, value in strings.items():
                    self.assertIsInstance(value, str, key)
                    self.assertNotEqual(value.strip(), "", key)

    def test_translations_keep_the_placeholders(self):
        for locale, strings in TRANSLATIONS.items():
            for key, value in strings.items():
                with self.subTest(locale=locale, key=key):
                    self.assertEqual(placeholders(value), placeholders(key))


class EachClient(unittest.TestCase):
    """The addon loads, prints its help and builds its panel in every client language."""

    def clients(self):
        clients = {locale: locale for locale in LOCALE_FILES}
        for client, uses in SHARED_CLIENTS.items():
            if uses in LOCALE_FILES:
                clients[client] = uses
        return clients

    def test_runs_in_each_language(self):
        for client, locale in self.clients().items():
            with self.subTest(client=client):
                addon = Addon(with_options=True, locale=client)
                addon.command("foreign")
                addon.is_hidden("wts stuff", at=0)
                addon.is_hidden("kek", language="Orcish", at=1)
                addon.is_hidden("LFM ICC", at=2)
                addon.is_hidden("LFM ICC", at=3)
                self.assertIn("/qc config", addon.command(""))
                self.assertIn("/qc words", addon.command("remove nope"))
                options = addon.options()
                options.args.log.args.messages.name(None)
                # The client's own translation is the one in use
                expected = TRANSLATIONS.get(locale, {}).get("General", "General")
                self.assertEqual(options.args.general.name, expected)


if __name__ == "__main__":
    unittest.main()

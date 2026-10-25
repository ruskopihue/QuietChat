import unittest

from wow import Addon

DEFAULTS = ["wts", "wtb", "recruiting", "lfw"]


class SettingsPanel(unittest.TestCase):
    def setUp(self):
        self.addon = Addon(with_options=True)
        # Validated by the real AceConfigRegistry, so a malformed table fails here
        self.options = self.addon.options()

    def info(self, key):
        return self.addon.lua_list([key])

    def keywords_page(self):
        return self.addon.options().args.keywords

    def test_registers_three_pages(self):
        panels = [(p.name, p.parent, p.path) for p in self.addon.g.PANELS.values()]
        self.assertEqual(
            panels,
            [
                ("QuietChat", None, "general"),
                ("Keywords", "QuietChat", "keywords"),
                ("Blocked messages", "QuietChat", "log"),
            ],
        )

    def test_toggles_read_and_write_settings(self):
        general = self.options.args.general
        self.assertTrue(general.get(self.info("active")))
        general.set(self.info("blockForeign"), True)
        self.assertTrue(self.addon.db.blockForeign)

    def test_other_options_disabled_when_filter_off(self):
        general = self.options.args.general
        general.set(self.info("active"), False)
        self.assertTrue(general.args.blockForeign.disabled(None))

    def test_slider_saves_without_forcing_a_redraw(self):
        # A redraw during a drag destroys the slider, so panel changes must not request one
        before = self.addon.g.REDRAWS
        self.options.args.general.args.repeatWindow.set(self.info("repeatWindow"), 30)
        self.assertEqual(self.addon.db.repeatWindow, 30)
        self.assertEqual(self.addon.g.REDRAWS, before)

    def test_keyword_box_shows_one_per_line(self):
        box = self.keywords_page().args.words
        self.assertEqual(box.get(None), "\n".join(DEFAULTS))
        self.assertIn("(4)", box.name)

    def test_keyword_box_validation(self):
        validate = self.keywords_page().args.words.validate
        self.assertTrue(validate(None, "wts\n\n  Gold*  \nWTS\n"))
        error = validate(None, "wts\na*b\n*\nfine")
        self.assertIn("a*b", error)
        self.assertNotIn("fine", error)

    def test_keyword_box_saves_cleaned_list(self):
        box = self.keywords_page().args.words
        box.set(None, "  WTS \r\n\r\nGold   Selling\nicc*\nwts\n")
        self.assertEqual(self.addon.keywords, ["wts", "gold selling", "icc*"])
        box.set(None, "")
        self.assertEqual(self.addon.keywords, [])

    def test_warns_about_invalid_saved_keywords(self):
        self.assertIsNone(self.keywords_page().args.invalid)
        self.addon.lua.execute('table.insert(QuietChat.db.words, "bad*word")')
        self.assertIn("bad*word", self.keywords_page().args.invalid.name)

    def test_reset_button(self):
        self.addon.command("add extra")
        self.keywords_page().args.reset.func()
        self.assertEqual(self.addon.keywords, DEFAULTS)

    def test_log_page(self):
        log = self.addon.options().args.log
        self.assertIn("Nothing", log.args.messages.name(None))
        self.addon.is_hidden("WTS stuff")
        log = self.addon.options().args.log
        self.assertIn("WTS stuff", log.args.messages.name(None))
        self.assertIn("last 1 ", log.args.intro.name)

    def test_log_page_says_why(self):
        self.addon.command("foreign")
        self.addon.is_hidden("WTS stuff", at=0)
        self.addon.is_hidden("kek", language="Orcish", at=1)
        self.addon.is_hidden("LFM ICC", at=2)
        self.addon.is_hidden("LFM ICC", at=3)
        page = self.addon.options().args.log.args.messages.name(None)
        for why in ['(keyword "wts")', "(Orcish)", "(repeat)"]:
            with self.subTest(why=why):
                self.assertIn(why, page)

    def test_slash_commands_redraw_the_panel(self):
        before = self.addon.g.REDRAWS
        self.addon.command("add icc*")
        self.assertGreater(self.addon.g.REDRAWS, before)

    def test_config_command_opens_panel(self):
        self.addon.command("config")
        self.assertGreater(self.addon.g.OPENED, 0)


if __name__ == "__main__":
    unittest.main()

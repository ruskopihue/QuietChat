import unittest

from wow import Addon

SHADOWMOURNE = "|cffa335ee|Hitem:49623:0|h[Shadowmourne]|h|r"


class KeywordMatching(unittest.TestCase):
    def setUp(self):
        self.addon = Addon()
        self.addon.command("repeat 0")  # keep the repeat filter out of these tests

    def hidden(self, msg):
        return self.addon.is_hidden(msg)

    def test_default_keywords(self):
        self.assertEqual(self.addon.keywords, ["wts", "wtb", "recruiting", "lfw"])

    def test_whole_words_only(self):
        self.addon.command("add hell")
        for msg, expected in [
            ("what the hell", True),
            ("HELL!!", True),
            ("hello, how are you?", False),
            ("shell game", False),
        ]:
            with self.subTest(msg=msg):
                self.assertEqual(self.hidden(msg), expected)

    def test_digits_are_part_of_a_word(self):
        self.addon.command("add icc")
        self.assertTrue(self.hidden("LFM ICC 25"))
        self.assertFalse(self.hidden("LFM ICC25"))
        self.assertFalse(self.hidden("wts2 items"))
        self.assertTrue(self.hidden("[WTS]"))

    def test_star_matches_inside_words(self):
        self.addon.command("add hell*")
        self.addon.command("add *gold*")
        for msg, expected in [
            ("hello there", True),
            ("shell game", False),
            ("cheap megagoldfarm", True),
            ("goldselling", True),
        ]:
            with self.subTest(msg=msg):
                self.assertEqual(self.hidden(msg), expected)

    def test_phrases_ignore_extra_spaces(self):
        self.addon.command("add gold selling")
        self.assertTrue(self.hidden("buy gold    selling now"))
        self.assertFalse(self.hidden("gold and selling"))

    def test_keywords_with_symbols(self):
        self.addon.command("add [wts")
        self.assertTrue(self.hidden("hi [wts there"))

    def test_non_ascii_letters_are_part_of_a_word(self):
        self.addon.command("add se")
        self.assertFalse(self.hidden("señor"))
        self.assertTrue(self.hidden("se ñor"))

    def test_links_match_visible_text_only(self):
        self.addon.command("add item")
        self.addon.command("add hell")
        self.assertFalse(self.hidden("check " + SHADOWMOURNE + " ok"))
        two_links = "|cffa335ee|Hitem:1:0|h[A]|h|r and |cffa335ee|Hitem:2:0|h[Hell Blade]|h|r"
        self.assertTrue(self.hidden(two_links))

    def test_exempt_players(self):
        self.addon.g.FRIENDS[1] = "Buddy"
        self.addon.g.GUILD["Guildie"] = True
        self.addon.g.GROUP["Healer"] = True
        for player in ["Me", "Buddy", "Guildie", "Healer"]:
            with self.subTest(player=player):
                self.assertFalse(self.addon.is_hidden("wts stuff", player=player))
        self.assertTrue(self.addon.is_hidden("wts stuff", player="Stranger"))

    def test_exempt_players_skip_the_repeat_filter_too(self):
        self.addon.g.GUILD["Guildie"] = True
        self.assertFalse(self.addon.is_hidden("LFM ICC", player="Guildie", at=0))
        self.assertFalse(self.addon.is_hidden("LFM ICC", player="Guildie", at=1))

    def test_disabled_filter_hides_nothing(self):
        self.addon.command("toggle")
        self.assertFalse(self.hidden("wts stuff"))

    def test_whispers_are_never_filtered(self):
        self.assertIsNone(self.addon.g.FILTERS["CHAT_MSG_WHISPER"])


class ForeignLanguages(unittest.TestCase):
    def test_blocks_unknown_languages_when_enabled(self):
        addon = Addon()
        self.assertFalse(addon.is_hidden("kek", language="Orcish"))
        addon.command("foreign")
        self.assertTrue(addon.is_hidden("kek", language="Orcish"))
        self.assertFalse(addon.is_hidden("hello", language="Common"))
        self.assertFalse(addon.is_hidden("hello again", language=""))


class Commands(unittest.TestCase):
    def setUp(self):
        self.addon = Addon()

    def test_add_normalizes(self):
        self.assertIn("Added", self.addon.command("add  Gold   Selling "))
        self.assertIn("gold selling", self.addon.keywords)

    def test_add_rejects_misplaced_star(self):
        for keyword in ["a*b", "*", "**x"]:
            with self.subTest(keyword=keyword):
                self.assertIn("Use * only at the start or end", self.addon.command("add " + keyword))
        self.assertEqual(len(self.addon.keywords), 4)

    def test_add_rejects_duplicates(self):
        self.assertIn("already a keyword", self.addon.command("add WTS"))

    def test_remove_by_word(self):
        self.assertIn("Removed", self.addon.command("remove LFW"))
        self.assertIn("Removed", self.addon.command("remove  wts "))
        self.assertEqual(self.addon.keywords, ["wtb", "recruiting"])

    def test_remove_rejects_unknown_words(self):
        # Numbers are words like any other, not positions in the list
        for arg in ["1", "nope"]:
            with self.subTest(arg=arg):
                self.assertIn("is not a keyword", self.addon.command("remove " + arg))
        self.assertEqual(len(self.addon.keywords), 4)

    def test_reset_restores_defaults(self):
        self.addon.command("add extra")
        self.addon.command("default")
        self.assertEqual(self.addon.keywords, ["wts", "wtb", "recruiting", "lfw"])
        # The defaults list itself must not change when keywords are added afterwards
        self.addon.command("add another")
        self.addon.command("default")
        self.assertEqual(self.addon.keywords, ["wts", "wtb", "recruiting", "lfw"])

    def test_commands_ignore_case(self):
        self.assertIn("disabled", self.addon.command("TOGGLE"))

    def test_help_uses_new_slash_command(self):
        output = self.addon.command("")
        self.assertIn("/qc config", output)
        self.assertNotIn("/cf", output)

    def test_removed_settings_are_gone(self):
        output = self.addon.command("")
        for removed in ["/qc log", "/qc verbose", "/qc whispers", "number"]:
            with self.subTest(removed=removed):
                self.assertNotIn(removed, output)


if __name__ == "__main__":
    unittest.main()

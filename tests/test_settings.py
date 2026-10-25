import unittest

from wow import Addon


class SavedSettings(unittest.TestCase):
    """The saved settings file may be from an older version or edited by hand."""

    def test_missing_settings_get_defaults(self):
        addon = Addon(saved="{ active = false }")
        self.assertFalse(addon.db.active)
        self.assertFalse(addon.db.blockForeign)
        self.assertEqual(addon.db.repeatWindow, 15)
        self.assertEqual(addon.keywords, ["wts", "wtb", "recruiting", "lfw"])

    def test_wrong_types_get_defaults(self):
        addon = Addon(saved='{ active = "yes", blockForeign = 1, repeatWindow = "30", words = "wts" }')
        self.assertTrue(addon.db.active)
        self.assertFalse(addon.db.blockForeign)
        self.assertEqual(addon.db.repeatWindow, 15)
        self.assertEqual(addon.keywords, ["wts", "wtb", "recruiting", "lfw"])
        # And the filter runs instead of failing on every message
        self.assertFalse(addon.is_hidden("hello there"))
        self.assertTrue(addon.is_hidden("hello there", at=1))

    def test_keywords_are_normalized_and_non_text_dropped(self):
        addon = Addon(saved='{ words = { "  Gold   Selling ", 42, "", "   ", { "x" }, "wts" } }')
        self.assertEqual(addon.keywords, ["gold selling", "wts"])

    def test_settings_from_before_1_0_are_dropped(self):
        addon = Addon(saved='{ verbose = true, whispers = true, words = { "gold" } }')
        self.assertIsNone(addon.db.verbose)
        self.assertIsNone(addon.db.whispers)
        self.assertEqual(addon.keywords, ["gold"])


if __name__ == "__main__":
    unittest.main()

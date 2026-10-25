import unittest

from wow import Addon

LFM = "LFM ICC25 hc 8/12 NEED ALL 6kgs+ (DBW trink reserved)"


class RepeatFilter(unittest.TestCase):
    """Default window: a player's message shows once every 15 seconds."""

    def setUp(self):
        self.addon = Addon()

    def send(self, msg, at, player="Fulgetrak", **kwargs):
        return self.addon.is_hidden(msg, player=player, event="CHAT_MSG_CHANNEL", at=at, **kwargs)

    def test_burst_across_channels_shows_once(self):
        self.assertFalse(self.send(LFM, 0, channel="6. Global"))
        self.assertTrue(self.send(LFM, 1, channel="2. Trade"))
        self.assertTrue(self.addon.is_hidden(LFM, player="Fulgetrak", event="CHAT_MSG_YELL", at=2))

    def test_case_spacing_and_symbols_are_ignored(self):
        self.assertFalse(self.send(LFM, 0))
        self.assertTrue(self.send(LFM.upper() + " !!!", 1))
        self.assertTrue(self.send(LFM.replace(" ", "   "), 2))

    def test_symbol_only_messages_are_never_repeats(self):
        for at, msg in enumerate([":)", "?", "!!!", ":)", "<3"]):
            with self.subTest(msg=msg):
                self.assertFalse(self.send(msg, at))

    def test_symbols_dont_break_the_next_real_repeat(self):
        self.assertFalse(self.send(":)", 0))
        self.assertFalse(self.send(LFM, 1))
        self.assertTrue(self.send(LFM, 2))

    def test_changed_numbers_are_a_new_message(self):
        self.assertFalse(self.send(LFM, 0))
        self.assertFalse(self.send(LFM.replace("8/12", "9/12"), 1))

    def test_other_players_are_independent(self):
        self.assertFalse(self.send(LFM, 0))
        self.assertFalse(self.send(LFM, 1, player="Someone"))

    def test_window_counts_from_the_shown_copy(self):
        self.assertFalse(self.send(LFM, 0))
        self.assertTrue(self.send(LFM, 14))
        self.assertFalse(self.send(LFM, 16))  # next round shows again
        self.assertTrue(self.send(LFM, 17))

    def test_several_chat_frames_are_not_repeats(self):
        self.assertFalse(self.send(LFM, 0, frames=3))

    def test_works_without_line_ids(self):
        self.assertFalse(self.send(LFM, 0, frames=3, line_id=False))
        self.assertTrue(self.send(LFM, 1, frames=3, line_id=False))

    def test_friends_and_self_are_exempt(self):
        self.addon.g.FRIENDS[1] = "Buddy"
        for player in ["Buddy", "Me"]:
            with self.subTest(player=player):
                self.assertFalse(self.send("hi all", 0, player=player))
                self.assertFalse(self.send("hi all", 1, player=player))

    def test_zero_turns_it_off(self):
        self.addon.command("repeat 0")
        self.assertFalse(self.send(LFM, 0))
        self.assertFalse(self.send(LFM, 1))

    def test_custom_window(self):
        self.addon.command("repeat 120")
        self.assertFalse(self.send(LFM, 0))
        self.assertTrue(self.send(LFM, 110))
        self.assertFalse(self.send(LFM, 121))

    def test_repeat_command(self):
        self.assertIn("15s", self.addon.command("repeat"))
        self.assertIn("Usage", self.addon.command("repeat abc"))
        self.assertIn("shown", self.addon.command("repeat 0"))

    def test_hidden_repeats_are_logged(self):
        self.send(LFM, 0)
        self.send(LFM, 1)
        self.assertIn("(repeat)", self.addon.addon.messageLog[1])


if __name__ == "__main__":
    unittest.main()
